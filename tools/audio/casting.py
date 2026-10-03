#!/usr/bin/env python3
"""Casting del audiolibro: de grabaciones libres de hablantes peninsulares a
la voz de cada papel del reparto.

    casting.py preparar-cv <dir>    elige hablantes peninsulares de Common Voice
    casting.py preparar-mls <id…>   baja clips de hablantes de MLS (LibriVox)
    casting.py referencias [id …]   arma la referencia de 7–8,5 s de cada candidata
    casting.py clonar [id …]        crea en VoiceStudio el perfil «CAST <id>»
    casting.py sintetizar [--motor M] [id …]
                                    lee el guion de prueba con cada candidata
    casting.py medir                criba objetiva: duración, silencios, picos, WER
    casting.py panel --referencias  criba previa: escuchar las grabaciones originales
    casting.py criba votos.json     candidatas que pasan la criba (acento, toma)
    casting.py panel                página de escucha ciega (build/audio/casting/)
    casting.py elegir votos.json    reparto óptimo por papel a partir de los votos
    casting.py aplicar              lo lleva a VoiceStudio (SPL …) y a reparto.yml

Las candidatas están en casting.yml; las fuentes, en ~/.cache/spl-audio/fuentes
(fuera del repo). Todo lo que genera va a build/audio/casting/.
"""

import argparse
import csv
import json
import random
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path

import yaml

import cliente as C
from normalizar import normalizar

AQUI = Path(__file__).resolve().parent
RAIZ = AQUI.parents[1]
FUENTES = Path.home() / ".cache" / "spl-audio" / "fuentes"
SALIDA = RAIZ / "build" / "audio" / "casting"
PREFIJO = "CAST "

# Con 6 GB de VRAM, OmniVoice agota la memoria al CODIFICAR la referencia
# (el codificador acústico DAC la procesa entera de una vez): 8 s caben y
# 12 s ya no, aunque el texto a decir sea de tres palabras. El prompt se
# guarda en caché tras la primera vez. 7–8,5 s bastan para timbre y acento.
REF_MIN_S, REF_MAX_S = 7.0, 8.5
SNR_MIN_DB = 25.0


def candidatas(ids=None):
    todas = yaml.safe_load((AQUI / "casting.yml").read_text(encoding="utf-8"))["candidatas"]
    # Las de Common Voice y MLS se generan con `preparar-cv`/`preparar-mls` y
    # viven junto a sus audios, fuera del repo (FUENTES/<fuente>/candidatas.yml).
    for extra in sorted(FUENTES.glob("*/candidatas.yml")):
        todas += yaml.safe_load(extra.read_text(encoding="utf-8")) or []
    if ids:
        desconocidas = set(ids) - {c["id"] for c in todas}
        if desconocidas:
            raise SystemExit(f"casting: no hay candidatas {', '.join(sorted(desconocidas))} en casting.yml")
        todas = [c for c in todas if c["id"] in ids]
    return todas


# --- lectores de cada fuente -------------------------------------------------
# Devuelven la lista ordenada de (audio, texto) de una candidata. El orden
# importa: la referencia se arma con enunciados CONSECUTIVOS, que suenan como
# una lectura seguida y no como frases sueltas de sesiones distintas.

def _lector_davefx(c):
    d = FUENTES / c["ruta"]
    return [(a, a.with_suffix(".txt").read_text(encoding="utf-8").strip())
            for a in sorted(d.glob("*.webm")) if a.with_suffix(".txt").exists()]


def _lector_sharvard(c):
    textos = {}
    for linea in (FUENTES / "sharvard" / "Sharvard-phonemic.txt").read_text(encoding="utf-8").splitlines()[1:]:
        partes = linea.split("|")
        if len(partes) >= 2:
            t = partes[1].lower().strip()
            textos[partes[0]] = t[:1].upper() + t[1:] + "."
    d = FUENTES / c["ruta"]
    return [(a, textos[a.stem]) for a in sorted(d.glob("s*.wav")) if a.stem in textos]


def _lector_carpeta(c):
    """Genérico: pares audio + .txt con el mismo nombre (MLS, LibriVox, CV
    preparados por `preparar_*`)."""
    d = FUENTES / c["ruta"]
    salida = []
    for a in sorted(d.iterdir()):
        if a.suffix.lower() in (".wav", ".flac", ".mp3", ".opus", ".ogg", ".webm") and a.with_suffix(".txt").exists():
            salida.append((a, a.with_suffix(".txt").read_text(encoding="utf-8").strip()))
    return salida


LECTORES = {"davefx": _lector_davefx, "sharvard": _lector_sharvard, "carpeta": _lector_carpeta}


# --- medidas -------------------------------------------------------------------

def medir_clip(ruta):
    """Duración, pico, saturación y SNR de un clip.

    La SNR sale de tramas de 20 ms: la voz es el percentil 90 de su energía y
    el ruido el percentil 2 (las pausas: hay pocas, porque los corpus recortan cada frase al ras). Es tosca, pero separa una toma de
    estudio de un micro de portátil, y no depende del suelo de ruido de
    `astats`, que en un clip muy recortado sale casi al azar. La saturación
    es la fracción de muestras pegadas al máximo (se admite < 1 %); un pico algo por encima de 0 dBFS en
    Opus es sólo el decodificador, no un recorte."""
    import numpy as np
    r = subprocess.run(["ffmpeg", "-v", "error", "-i", str(ruta), "-ac", "1", "-ar", "24000",
                        "-f", "f32le", "-"], capture_output=True, check=True)
    x = np.frombuffer(r.stdout, dtype=np.float32)
    if x.size == 0:
        return {"dur": 0.0, "pico": None, "saturadas": 0.0, "snr": None}
    n = 480
    tramas = x[: x.size // n * n].reshape(-1, n)
    energia = 10 * np.log10(np.mean(tramas ** 2, axis=1) + 1e-12)
    snr = float(np.percentile(energia, 90) - np.percentile(energia, 2)) if len(energia) > 10 else None
    pico = float(20 * np.log10(np.max(np.abs(x)) + 1e-12))
    saturadas = float(np.mean(np.abs(x) >= 0.999))
    return {"dur": x.size / 24000, "pico": pico, "saturadas": saturadas, "snr": snr}


def _bueno(m):
    return m["dur"] >= 1.5 and (m["snr"] or 0) >= SNR_MIN_DB and m["saturadas"] < 0.01


def elegir_ventana(clips, max_clips=400):
    """La racha de clips consecutivos y buenos que sume REF_MIN–REF_MAX s con
    la mejor SNR mínima. Se miden como mucho `max_clips`."""
    medidas = []
    for audio, texto in clips[:max_clips]:
        medidas.append((audio, texto, medir_clip(audio)))
    mejor = None
    for i in range(len(medidas)):
        total, peor, j = 0.0, 999.0, i
        while j < len(medidas) and total < REF_MIN_S:
            m = medidas[j][2]
            if not _bueno(m):
                break
            total += m["dur"] + 0.3
            peor = min(peor, m["snr"])
            j += 1
        if REF_MIN_S <= total <= REF_MAX_S + 1.5 and (mejor is None or peor > mejor[0]):
            mejor = (peor, i, j)
    if not mejor:
        return None, medidas
    return medidas[mejor[1]:mejor[2]], medidas


def armar_referencia(ventana, destino):
    """Concatena los clips (sin silencios de borde, 300 ms entre ellos), los
    normaliza a -20 LUFS y los deja en WAV mono a 24 kHz, que es lo que el
    motor usa por dentro."""
    destino.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        partes = []
        for k, (audio, _, _) in enumerate(ventana):
            p = Path(tmp) / f"{k:03d}.wav"
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", str(audio), "-ac", "1", "-ar", "24000",
                            "-af", "silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.05,"
                                   "areverse,silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.1,"
                                   "areverse,apad=pad_dur=0.3",
                            str(p)], check=True)
            partes.append(p)
        lista = Path(tmp) / "lista.txt"
        lista.write_text("".join(f"file '{p}'\n" for p in partes))
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", str(lista),
                        "-af", "loudnorm=I=-20:TP=-2:LRA=11", "-ar", "24000", "-ac", "1",
                        "-c:a", "pcm_s16le", str(destino)], check=True)
    texto = " ".join(t for _, t, _ in ventana)
    destino.with_suffix(".txt").write_text(texto + "\n", encoding="utf-8")
    return texto


# --- órdenes ---------------------------------------------------------------------

def _corte_en_pausa(ruta):
    """Segundo en que cortar un clip largo: la pausa (≥ 200 ms bajo -40 dB
    respecto al pico de energía) más tardía entre REF_MIN_S y REF_MAX_S."""
    import numpy as np
    r = subprocess.run(["ffmpeg", "-v", "error", "-i", str(ruta), "-ac", "1", "-ar", "24000", "-f", "f32le", "-"],
                       capture_output=True, check=True)
    x = np.frombuffer(r.stdout, dtype=np.float32)
    n = 480  # 20 ms
    e = 10 * np.log10(np.mean(x[: x.size // n * n].reshape(-1, n) ** 2, axis=1) + 1e-12)
    silencio = e < e.max() - 40
    mejor, racha = None, 0
    for k, sil in enumerate(silencio):
        racha = racha + 1 if sil else 0
        t = (k - racha / 2) * n / 24000
        if racha >= 10 and REF_MIN_S <= t <= REF_MAX_S:
            mejor = t
    return mejor


def _recortar(clips):
    """Plan B para fuentes de clips largos (MLS: 10–20 s): el clip bueno que
    tenga una pausa entre REF_MIN_S y REF_MAX_S, cortado ahí. Su texto ya no
    es el del corpus; lo pone después transcribir.py."""
    for audio, _ in clips[:60]:
        m = medir_clip(audio)
        if not _bueno(m) or m["dur"] < REF_MIN_S:
            continue
        t = _corte_en_pausa(audio)
        if t:
            return audio, t, m
    return None


def cmd_referencias(a):
    filas, pendientes = [], []
    for c in candidatas(a.ids):
        lector = LECTORES[c.get("lector", "carpeta")]
        clips = lector(c)
        if not clips:
            print(f"✗ {c['id']}: sin clips en {FUENTES / c['ruta']}", file=sys.stderr)
            continue
        destino = SALIDA / "referencias" / f"{c['id']}.wav"
        ventana, medidas = elegir_ventana(clips)
        if ventana:
            armar_referencia(ventana, destino)
            snr_min = min(x[2]["snr"] for x in ventana)
        else:
            corte = _recortar(clips)
            if not corte:
                buenos = sum(_bueno(m) for _, _, m in medidas)
                print(f"✗ {c['id']}: ni racha de {REF_MIN_S:.0f}–{REF_MAX_S:.1f} s ni clip con pausa "
                      f"({buenos}/{len(medidas)} clips buenos)", file=sys.stderr)
                continue
            audio, t, m = corte
            with tempfile.TemporaryDirectory() as tmp:
                trozo = Path(tmp) / "trozo.wav"
                subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", str(audio), "-t", f"{t:.2f}", str(trozo)],
                               check=True)
                armar_referencia([(trozo, "", m)], destino)
            pendientes.append(destino)
            snr_min = m["snr"]
        filas.append((c["id"], c["sexo"], medir_clip(destino)["dur"], snr_min, c["licencia"], c["consentimiento"]))
    if pendientes:
        # Una sola carga del modelo para todas las referencias recortadas.
        print(f"==> transcribiendo {len(pendientes)} referencias recortadas (CPU)…", file=sys.stderr)
        r = subprocess.run([str(AQUI / "transcribir.py"), *map(str, pendientes)],
                           stdout=subprocess.PIPE, text=True, check=True)
        for ref, texto in zip(pendientes, r.stdout.splitlines()):
            ref.with_suffix(".txt").write_text(texto.strip() + "\n", encoding="utf-8")
    print(f"\n{'candidata':<16}{'sexo':<6}{'dur':>6}{'SNR':>7}  licencia / consentimiento")
    for f in filas:
        print(f"{f[0]:<16}{f[1]:<6}{f[2]:>5.1f}s{f[3]:>6.0f}dB  {f[4]} / {f[5]}")


def cmd_clonar(a):
    ids = C.perfiles()
    for c in candidatas(a.ids):
        ref = SALIDA / "referencias" / f"{c['id']}.wav"
        if not ref.exists():
            print(f"✗ {c['id']}: falta la referencia; lanza antes `casting.py referencias`", file=sys.stderr)
            continue
        nombre = PREFIJO + c["id"]
        if nombre in ids and a.rehacer:
            with C._pedir("DELETE", f"/profiles/{ids[nombre]}"):
                pass
        elif nombre in ids:
            print(f"✓ {nombre} ya existe ({ids[nombre]})")
            continue
        p = C.post_multipart("/profiles", {
            "name": nombre, "kind": "clone", "language": "Spanish",
            "ref_text": ref.with_suffix(".txt").read_text(encoding="utf-8").strip(),
        }, {"ref_audio": ref})
        print(f"+ {nombre} → {p.get('id')}")


def _liberar_vram():
    """Vacía la caché de CUDA de VoiceStudio. NO descarga el modelo: con
    /model/unload el siguiente render lo recarga sin que la copia anterior
    llegue a soltarse del todo, y con 6 GB dos copias no caben."""
    for ruta in ("/system/flush-memory",):
        try:
            with C._pedir("POST", ruta, b"", {"Content-Type": "application/json"}, timeout=120):
                pass
        except C.ErrorVoiceStudio:
            pass


def _hablar(texto, perfil, motor, destino, reintento=True):
    """Sintetiza por POST /generate, la vía principal de VoiceStudio.

    No se usa /v1/audio/speech (la compatible con OpenAI): carga su PROPIA
    copia del motor, que no aparece en /model/loaded ni se libera con «unload»,
    y con el modelo principal ya no caben los dos en 6 GB."""
    cuerpo, cab = C._multipart({
        "text": texto, "profile_id": perfil, "language": "es", "num_step": 32, "seed": 42,
        "engine": motor, "wav_bits": "16",
    })
    destino.parent.mkdir(parents=True, exist_ok=True)
    t0 = time.time()
    try:
        with C._pedir("POST", "/generate", cuerpo, cab, timeout=900) as r:
            tipo = r.headers.get("Content-Type", "")
            datos = r.read()
    except C.ErrorVoiceStudio as e:
        if not (reintento and "out of memory" in str(e)):
            raise
        print("   ! sin VRAM: recargo el modelo y repito", file=sys.stderr)
        _liberar_vram()
        return _hablar(texto, perfil, motor, destino, reintento=False)
    if tipo.startswith("audio/"):
        destino.write_bytes(datos)
    else:
        info = json.loads(datos)
        ident = info.get("id") or info.get("audio_id")
        with C._pedir("GET", f"/audio/{ident}.wav", timeout=120) as r:
            destino.write_bytes(r.read())
    return time.time() - t0


def cmd_sintetizar(a):
    muestras = yaml.safe_load((AQUI / "casting" / "guion_prueba.yml").read_text(encoding="utf-8"))["muestras"]
    ids = C.perfiles()
    registro = SALIDA / "sintesis.csv"
    filas = []
    if registro.exists():
        with registro.open() as f:
            filas = [r for r in csv.DictReader(f) if r["motor"] != a.motor or (a.ids and r["candidata"] not in a.ids)]
    for c in candidatas(a.ids):
        nombre = PREFIJO + c["id"]
        if nombre not in ids:
            print(f"✗ {c['id']}: no está clonada", file=sys.stderr)
            continue
        _liberar_vram()
        for m in muestras:
            destino = SALIDA / "muestras" / a.motor / c["id"] / f"{m['id']}.wav"
            seg = _hablar(normalizar(m["texto"]), ids[nombre], a.motor, destino)
            dur = medir_clip(destino)["dur"]
            filas.append({"motor": a.motor, "candidata": c["id"], "muestra": m["id"],
                          "segundos_render": f"{seg:.1f}", "duracion": f"{dur:.1f}"})
            print(f"  {a.motor} {c['id']:<14} {m['id']:<11} {dur:5.1f} s en {seg:5.1f} s")
    with registro.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["motor", "candidata", "muestra", "segundos_render", "duracion"])
        w.writeheader()
        w.writerows(filas)


def cmd_medir(a):
    """Criba objetiva de cada muestra. La velocidad (palabras por minuto) delata
    lo que el oído tarda en notar: una frase saltada la dispara, una repetida o
    un silencio a mitad la hunde. El WER sale de transcribir en CPU con
    transcribir.py (faster-whisper), no con el reconocedor de VoiceStudio, que
    compite por la GPU con el modelo de voz."""
    import verificar as V
    muestras = {m["id"]: normalizar(m["texto"]) for m in
                yaml.safe_load((AQUI / "casting" / "guion_prueba.yml").read_text(encoding="utf-8"))["muestras"]}
    wavs = sorted((SALIDA / "muestras").glob("*/*/*.wav"))
    textos = [""] * len(wavs)
    if not a.sin_asr:
        print(f"==> transcribiendo {len(wavs)} muestras en CPU…", file=sys.stderr)
        r = subprocess.run([str(AQUI / "transcribir.py"), "--modelo", a.modelo, *map(str, wavs)],
                           stdout=subprocess.PIPE, text=True, check=True)
        textos = r.stdout.splitlines()
    filas = []
    for wav, hip in zip(wavs, textos):
        motor, cand, muestra = wav.parts[-3], wav.parts[-2], wav.stem
        m = medir_clip(wav)
        palabras = len(muestras[muestra].split())
        ppm = palabras / max(m["dur"], 0.1) * 60
        r = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", str(wav), "-af",
                            "silencedetect=n=-45dB:d=0.9", "-f", "null", "-"], capture_output=True, text=True)
        huecos = len(re.findall(r"silence_end", r.stderr))
        w = "" if a.sin_asr else f"{V.wer(V._letras(muestras[muestra]), V._letras(hip, verbalizar=True)):.3f}"
        filas.append({"motor": motor, "candidata": cand, "muestra": muestra, "duracion": f"{m['dur']:.1f}",
                      "ppm": f"{ppm:.0f}", "huecos_0_9s": huecos, "pico_db": f"{m['pico']:.1f}", "wer": w,
                      "transcripcion": hip})
    out = SALIDA / "medidas.csv"
    with out.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(filas[0]))
        w.writeheader()
        w.writerows(filas)
    sexo = {c["id"]: c["sexo"] for c in candidatas()}
    print(f"{'motor':<11}{'candidata':<14}{'sexo':<5}{'ppm':>5}{'huecos':>7}{'pico':>7}{'WER':>6}{'peor':>6}")
    agregados = {}
    for f_ in filas:
        agregados.setdefault((f_["motor"], f_["candidata"]), []).append(f_)
    for (motor, cand), fs in sorted(agregados.items(), key=lambda kv: (kv[0][0], sexo.get(kv[0][1], ""), kv[0][1])):
        ppm = sum(float(x["ppm"]) for x in fs) / len(fs)
        huecos = sum(int(x["huecos_0_9s"]) for x in fs)
        pico = max(float(x["pico_db"]) for x in fs)
        wers = [float(x["wer"]) for x in fs if x["wer"]]
        wer = f"{sum(wers) / len(wers):.0%}" if wers else "—"
        peor = f"{max(wers):.0%}" if wers else "—"
        print(f"{motor:<11}{cand:<14}{sexo.get(cand, '?'):<5}{ppm:>5.0f}{huecos:>7}{pico:>7.1f}{wer:>6}{peor:>6}")
    print(f"\n→ {out}")


def _panel_referencias(a):
    """Criba previa: se escuchan las grabaciones ORIGINALES (las referencias)
    para descartar acentos no peninsulares y tomas malas antes de clonar y
    sintetizar. Se puntúa igual; aquí importan sobre todo acento y claridad."""
    cands = {c["id"]: c for c in candidatas()}
    refs = sorted(p for p in (SALIDA / "referencias").glob("*.wav") if p.stem in cands)
    rnd = random.Random(a.semilla)
    codigos = rnd.sample(range(100, 1000), len(refs))
    clave = {f"R{n}": {"motor": "original", "candidata": r.stem} for n, r in zip(codigos, refs)}
    (SALIDA / "clave-referencias.json").write_text(json.dumps(clave, ensure_ascii=False, indent=1))
    orden = list(clave.items())
    rnd.shuffle(orden)
    bloques = [{"id": "referencia", "papeles": ["criba de acento y toma"],
                "texto": "Grabaciones originales de cada candidata. Puntúa sobre todo el acento (5 = castellano "
                         "peninsular claro, 1 = claramente americano o regional muy marcado) y la claridad de la toma.",
                "items": [{"codigo": k, "sexo": cands[v["candidata"]]["sexo"],
                           "audio": f"referencias/{v['candidata']}.wav"} for k, v in orden]}]
    html = (AQUI / "casting" / "panel.html").read_text(encoding="utf-8")
    (SALIDA / "criba.html").write_text(html.replace("/*DATOS*/null", json.dumps(bloques, ensure_ascii=False)),
                                       encoding="utf-8")
    print(f"✓ {SALIDA / 'criba.html'} ({len(refs)} referencias). Exporta los votos y pásalos a `casting.py criba`.")


def cmd_criba(a):
    """Ordena las candidatas por la criba de referencias y propone las que
    pasan a clonarse: acento ≥ 4 y claridad ≥ 3."""
    votos = json.loads(Path(a.votos).read_text(encoding="utf-8")).get("referencia", {})
    clave = json.loads((SALIDA / "clave-referencias.json").read_text(encoding="utf-8"))
    sexo = {c["id"]: c["sexo"] for c in candidatas()}
    filas = []
    for codigo, notas in votos.items():
        cand = clave.get(codigo, {}).get("candidata")
        if cand:
            filas.append((notas.get("acento", 0), notas.get("claridad", 0), notas.get("naturalidad", 0), cand))
    pasan = []
    for ac, cl, na, cand in sorted(filas, reverse=True):
        ok = ac >= 4 and cl >= 3
        pasan += [cand] if ok else []
        print(f"{'✓' if ok else '·'} {cand:<14} {sexo.get(cand, '?')}  acento {ac}  claridad {cl}  naturalidad {na}")
    print("\nPasan:", " ".join(pasan) or "ninguna")


def cmd_panel(a):
    """Página de escucha ciega: cada (motor, candidata) recibe un código al
    azar; la clave vive aparte, en clave.json, y la página no la conoce."""
    if a.referencias:
        return _panel_referencias(a)
    muestras = yaml.safe_load((AQUI / "casting" / "guion_prueba.yml").read_text(encoding="utf-8"))["muestras"]
    voces = sorted({(w.parts[-3], w.parts[-2]) for w in (SALIDA / "muestras").glob("*/*/*.wav")})
    if a.solo:
        voces = [v for v in voces if v[1] in a.solo or f"{v[0]}/{v[1]}" in a.solo]
    rnd = random.Random(a.semilla)
    codigos = rnd.sample(range(100, 1000), len(voces))
    clave = {f"V{n}": {"motor": m, "candidata": c} for n, (m, c) in zip(codigos, voces)}
    (SALIDA / "clave.json").write_text(json.dumps(clave, ensure_ascii=False, indent=1))
    sexo = {c["id"]: c["sexo"] for c in candidatas()}
    bloques = []
    for m in muestras:
        orden = list(clave.items())
        rnd.shuffle(orden)
        items = [{"codigo": k, "sexo": sexo.get(v["candidata"], "?"),
                  "audio": f"muestras/{v['motor']}/{v['candidata']}/{m['id']}.wav"}
                 for k, v in orden if (SALIDA / "muestras" / v["motor"] / v["candidata"] / f"{m['id']}.wav").exists()]
        bloques.append({"id": m["id"], "papeles": m["papeles"], "texto": normalizar(m["texto"]), "items": items})
    html = (AQUI / "casting" / "panel.html").read_text(encoding="utf-8")
    html = html.replace("/*DATOS*/null", json.dumps(bloques, ensure_ascii=False))
    (SALIDA / "panel.html").write_text(html, encoding="utf-8")
    print(f"✓ {SALIDA / 'panel.html'} ({len(clave)} voces, {len(muestras)} muestras). "
          f"Ábrelo en el navegador; la clave está en clave.json.")


def cmd_preparar_cv(a):
    """Common Voice: elige los hablantes peninsulares con más clips validados
    de cada sexo y copia sus clips (con su frase) a FUENTES/cv/<id>/.

    `ruta` es la carpeta del idioma de la descarga de Mozilla (la que tiene
    validated.tsv y clips/). Los hablantes se nombran por las 8 primeras
    cifras de su client_id anónimo; los términos de Common Voice prohíben
    intentar identificarlos, y aquí no se hace."""
    import shutil
    raiz = Path(a.ruta)
    tsv = raiz / "validated.tsv"
    if not tsv.exists():
        raise SystemExit(f"casting: no encuentro {tsv}")
    por = {}
    with tsv.open(encoding="utf-8") as f:
        for r in csv.DictReader(f, delimiter="\t", quoting=csv.QUOTE_NONE):
            acento = (r.get("accents") or r.get("accent") or "").lower()
            if "peninsular" not in acento:
                continue
            g = (r.get("gender") or "").lower()
            sexo = "F" if g.startswith(("female", "fem")) else "M" if g.startswith(("male", "masc")) else None
            if not sexo:
                continue
            por.setdefault((r["client_id"], sexo, acento), []).append((r["path"], r["sentence"], int(r.get("up_votes") or 0)))
    elegidas = []
    for sexo in ("M", "F"):
        hablantes = sorted(((k, v) for k, v in por.items() if k[1] == sexo), key=lambda kv: -len(kv[1]))[:a.por_sexo]
        for (cid, _, acento), clips in hablantes:
            ident = f"cv-{sexo.lower()}-{cid[:8]}"
            dest = FUENTES / "cv" / ident
            dest.mkdir(parents=True, exist_ok=True)
            for ruta, frase, _ in clips[:300]:
                origen = raiz / "clips" / ruta
                if origen.exists() and not (dest / ruta).exists():
                    shutil.copy2(origen, dest / ruta)
                    (dest / ruta).with_suffix(".txt").write_text(frase, encoding="utf-8")
            elegidas.append({"id": ident, "sexo": sexo, "fuente": "Mozilla Common Voice (es)",
                             "url": "https://commonvoice.mozilla.org", "licencia": "CC0-1.0", "atribucion": None,
                             "consentimiento": "cc0-voluntario", "acento": acento, "lector": "carpeta",
                             "ruta": f"cv/{ident}"})
            print(f"  {ident}: {len(clips)} clips, {acento}")
    (FUENTES / "cv" / "candidatas.yml").write_text(yaml.safe_dump(elegidas, allow_unicode=True, sort_keys=False))
    print(f"✓ {len(elegidas)} candidatas en {FUENTES / 'cv' / 'candidatas.yml'}")


def tono_medio(ruta):
    """Mediana de la frecuencia fundamental (Hz) por autocorrelación, en las
    tramas con voz. Basta para separar voces masculinas (~85–155 Hz) de
    femeninas (~165–255 Hz) cuando la fuente no dice el sexo."""
    import numpy as np
    r = subprocess.run(["ffmpeg", "-v", "error", "-i", str(ruta), "-ac", "1", "-ar", "16000", "-f", "f32le", "-"],
                       capture_output=True, check=True)
    x = np.frombuffer(r.stdout, dtype=np.float32)
    n = 640
    f0 = []
    for i in range(0, x.size - n, n):
        t = x[i:i + n] - x[i:i + n].mean()
        if np.sqrt(np.mean(t ** 2)) < 0.02:
            continue
        ac = np.correlate(t, t, "full")[n - 1:]
        lo, hi = 16000 // 400, 16000 // 60
        k = lo + int(np.argmax(ac[lo:hi]))
        if ac[k] > 0.3 * ac[0]:
            f0.append(16000 / k)
    return float(np.median(f0)) if f0 else None


def _guardar_candidata(fuente, cand):
    ruta = FUENTES / fuente / "candidatas.yml"
    previas = (yaml.safe_load(ruta.read_text(encoding="utf-8")) or []) if ruta.exists() else []
    previas = [c for c in previas if c["id"] != cand["id"]] + [cand]
    ruta.write_text(yaml.safe_dump(previas, allow_unicode=True, sort_keys=False), encoding="utf-8")


def cmd_preparar_mls(a):
    """MLS (LibriVox) en español: baja N clips de cada lector con mls.py, que
    lee de Hugging Face sólo los grupos de filas de ese lector, y estima su
    sexo por el tono. MLS no anota acento: la escucha decide si es
    peninsular, y de momento se marcan como «por confirmar»."""
    destino = FUENTES / "mls"
    r = subprocess.run([str(AQUI / "mls.py"), "bajar", str(destino), *a.hablantes, "--clips", str(a.clips)],
                       stdout=subprocess.PIPE, text=True)
    if r.returncode != 0:
        raise SystemExit("casting: mls.py falló (¿`hf auth login`?)")
    for sp, info in json.loads(r.stdout).items():
        if not info["clips"]:
            print(f"  ✗ mls-{sp}: sin clips", file=sys.stderr)
            continue
        dest = destino / f"mls-{sp}"
        tonos = [t for t in (tono_medio(f) for f in sorted(dest.glob("*.opus"))[:8]) if t]
        tono = sorted(tonos)[len(tonos) // 2] if tonos else 0
        sexo = "F" if tono > 160 else "M"
        print(f"  mls-{sp}: {info['clips']} clips, tono ≈ {tono:.0f} Hz → {sexo}; {info['origen']}")
        _guardar_candidata("mls", {
            "id": f"mls-{sp}", "sexo": sexo, "fuente": f"Multilingual LibriSpeech (LibriVox), lector {sp}",
            "url": info["origen"], "licencia": "CC-BY-4.0 (corpus); grabación LibriVox de dominio público",
            "atribucion": None, "consentimiento": "pd-lectura", "acento": "por confirmar",
            "lector": "carpeta", "ruta": f"mls/mls-{sp}", "tono_hz": round(tono)})


CRITERIOS = ["naturalidad", "acento", "claridad", "papel"]
PESOS = {  # por papel: cuánto cuenta cada criterio
    "Narradora":   {"naturalidad": 3, "acento": 2, "claridad": 2, "papel": 2},
    "Locutor":     {"naturalidad": 2, "acento": 2, "claridad": 2, "papel": 3},
    "Instructor":  {"naturalidad": 3, "acento": 2, "claridad": 1, "papel": 3},
    "Alerta":      {"naturalidad": 1, "acento": 2, "claridad": 3, "papel": 3},
    "Divulgadora": {"naturalidad": 3, "acento": 2, "claridad": 1, "papel": 3},
}


# Sexo de cada papel del reparto (reparto.yml): Narradora y Divulgadora son
# voces femeninas; Locutor, Instructor y Alerta, masculinas.
SEXO_PAPEL = {"Narradora": "F", "Divulgadora": "F", "Locutor": "M", "Instructor": "M", "Alerta": "M"}


def _notas_por_papel(votos, clave):
    muestras = {m["id"]: m["papeles"] for m in
                yaml.safe_load((AQUI / "casting" / "guion_prueba.yml").read_text(encoding="utf-8"))["muestras"]}
    puntos = {}  # (papel, candidata, motor) -> [nota ponderada]
    for muestra, porcodigo in votos.items():
        for codigo, notas in porcodigo.items():
            v = clave.get(codigo)
            if not v:
                continue
            for papel in muestras.get(muestra, []):
                p = PESOS[papel]
                validas = {k: n for k, n in notas.items() if k in CRITERIOS and n}
                if validas:
                    nota = sum(p[k] * n for k, n in validas.items()) / sum(p[k] for k in validas)
                    puntos.setdefault((papel, v["candidata"], v["motor"]), []).append(nota)
    return {k: sum(v) / len(v) for k, v in puntos.items()}


def cmd_elegir(a):
    """Reparto óptimo: una voz distinta por papel, del sexo del papel, que
    maximice la suma de notas. Las voces `pd-lectura` (LibriVox, sin
    consentimiento expreso para clonar) restan `--penalizar-pd` puntos: sólo
    ganan si superan con claridad a las donadas."""
    import itertools
    votos = json.loads(Path(a.votos).read_text(encoding="utf-8"))
    clave = json.loads((SALIDA / "clave.json").read_text(encoding="utf-8"))
    cands = {c["id"]: c for c in candidatas()}
    notas = _notas_por_papel(votos, clave)
    def nota(papel, cand, motor):
        n = notas.get((papel, cand, motor))
        if n is None:
            return None
        return n - (a.penalizar_pd if cands[cand]["consentimiento"] == "pd-lectura" else 0)
    opciones = {}
    for papel in PESOS:
        filas = sorted(((nota(papel, c, m), c, m) for (pp, c, m) in notas
                        if pp == papel and cands[c]["sexo"] == SEXO_PAPEL[papel]), reverse=True)
        opciones[papel] = [f for f in filas if f[0] is not None][:6]
        print(f"\n{papel} ({SEXO_PAPEL[papel]}):")
        for n, c, m in opciones[papel][:4]:
            print(f"  {n:4.2f}  {c} ({m}) — {cands[c]['consentimiento']}")
    papeles = list(PESOS)
    mejor = None
    for combo in itertools.product(*(opciones[p] for p in papeles)):
        voces = [c for _, c, _ in combo]
        if len(set(voces)) < len(voces):
            continue
        total = sum(n for n, _, _ in combo)
        if mejor is None or total > mejor[0]:
            mejor = (total, combo)
    if not mejor:
        raise SystemExit("casting: no hay voces suficientes para cubrir los papeles sin repetir.")
    print("\nReparto propuesto:")
    eleccion = {}
    for papel, (n, c, m) in zip(papeles, mejor[1]):
        eleccion[papel] = {"candidata": c, "motor": m, "nota": round(n, 2)}
        print(f"  SPL {papel:<12} ← {c:<13} ({m}, {n:.2f}; {cands[c]['licencia']})")
    (SALIDA / "eleccion.json").write_text(json.dumps(eleccion, ensure_ascii=False, indent=1))
    print(f"\n→ {SALIDA / 'eleccion.json'}. Para aplicarlo: casting.py aplicar")


def cmd_aplicar(a):
    """Lleva la elección a VoiceStudio y al reparto:

      * borra los perfiles `SPL <papel>` anteriores (las voces diseñadas);
      * renombra el `CAST <candidata>` ganador a `SPL <papel>`;
      * anota en reparto.yml la fuente, la licencia y la atribución de cada voz,
        que guion.py lleva a los créditos hablados y audio.py al metadato.

    Los CAST que no ganan se quedan, para la ronda de motores."""
    eleccion = json.loads((SALIDA / "eleccion.json").read_text(encoding="utf-8"))
    cands = {c["id"]: c for c in candidatas()}
    ids = C.perfiles()
    for papel, e in eleccion.items():
        nombre, cast = f"SPL {papel}", PREFIJO + e["candidata"]
        if cast not in ids:
            if ids.get(nombre) and nombre in ids:
                print(f"✓ {nombre} ya es {e['candidata']}?  ({cast} no existe; no toco nada)")
                continue
            raise SystemExit(f"casting: falta el perfil {cast} en VoiceStudio")
        if nombre in ids:
            with C._pedir("DELETE", f"/profiles/{ids[nombre]}"):
                pass
            print(f"- {nombre} (voz anterior) borrada")
        with C._pedir("PUT", f"/profiles/{ids[cast]}", json.dumps({"name": nombre}).encode(),
                      {"Content-Type": "application/json"}):
            pass
        print(f"+ {nombre} ← {e['candidata']} ({ids[cast]})")

    # reparto.yml: se reescribe sólo el bloque `voces:`, conservando el resto
    # del fichero (comentarios incluidos).
    ruta = AQUI / "reparto.yml"
    texto = ruta.read_text(encoding="utf-8")
    ini = texto.index("\nvoces:\n") + 1
    fin = texto.index("\n# Rol ", ini)
    lineas = ["voces:"]
    for papel, e in eleccion.items():
        c = cands[e["candidata"]]
        lineas += [f"  SPL {papel}:",
                   f"    candidata: {c['id']}",
                   f"    fuente: {json.dumps(c['fuente'], ensure_ascii=False)}",
                   f"    url: {c['url']}",
                   f"    licencia: {json.dumps(c['licencia'], ensure_ascii=False)}",
                   f"    consentimiento: {c['consentimiento']}"]
        if c.get("atribucion"):
            lineas.append(f"    atribucion: {json.dumps(' '.join(c['atribucion'].split()), ensure_ascii=False)}")
    ruta.write_text(texto[:ini] + "\n".join(lineas) + "\n" + texto[fin:], encoding="utf-8")
    print(f"✓ {ruta} actualizado")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="orden", required=True)
    s = sub.add_parser("referencias")
    s.add_argument("ids", nargs="*")
    s = sub.add_parser("clonar")
    s.add_argument("--rehacer", action="store_true", help="borra y vuelve a crear los perfiles CAST")
    s.add_argument("ids", nargs="*")
    s = sub.add_parser("sintetizar")
    s.add_argument("--motor", default="omnivoice")
    s.add_argument("ids", nargs="*")
    s = sub.add_parser("medir")
    s.add_argument("--sin-asr", action="store_true")
    s.add_argument("--modelo", default="medium", help="modelo de faster-whisper (CPU)")
    s = sub.add_parser("panel")
    s.add_argument("--semilla", type=int, default=None)
    s.add_argument("--solo", nargs="*", help="candidatas (o motor/candidata) que entran en el panel")
    s.add_argument("--referencias", action="store_true", help="criba previa con las grabaciones originales")
    s = sub.add_parser("criba")
    s.add_argument("votos")
    s = sub.add_parser("preparar-cv")
    s.add_argument("ruta", help="carpeta es/ de la descarga de Common Voice (validated.tsv, clips/)")
    s.add_argument("--por-sexo", type=int, default=5)
    s = sub.add_parser("preparar-mls")
    s.add_argument("hablantes", nargs="+")
    s.add_argument("--clips", type=int, default=30)
    sub.add_parser("aplicar")
    s = sub.add_parser("elegir")
    s.add_argument("votos")
    s.add_argument("--penalizar-pd", type=float, default=0.0,
                   help="puntos que restan las voces de LibriVox sin consentimiento expreso")
    a = ap.parse_args()
    globals()["cmd_" + a.orden.replace("-", "_")](a)


if __name__ == "__main__":
    main()
