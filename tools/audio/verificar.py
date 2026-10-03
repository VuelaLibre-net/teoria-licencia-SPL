#!/usr/bin/env python3
"""QA automática del audio: lo que no hace falta escuchar entero para cazar.

    verificar.py <dir-mp3> <dir-guion> [cap01 …] [--sin-asr]

Por cada MP3:

  * Lo transcribe pista a pista en CPU con transcribir.py (faster-whisper; el
    reconocedor de VoiceStudio compite por la GPU con el modelo de voz y se
    cuelga) y lo compara palabra a palabra con el guion: el porcentaje de error (WER) delata
    frases saltadas, repetidas o inventadas por el motor. El reconocedor
    escribe cifras y siglas a su manera («3,000», «QNH»), así que ambos lados se
    reducen a letras antes de comparar y el umbral es generoso.
  * Mide con ffmpeg la sonoridad integrada (objetivo ACX: -19 LUFS), el pico
    verdadero y los silencios de más de 3 s, que en un audiolibro son un fallo.

Sale con código distinto de 0 si algo queda fuera de umbral.
"""

import json
import re
import subprocess
import sys
import tempfile
import unicodedata
from pathlib import Path

from guion import sin_etiquetas
from normalizar import normalizar

UMBRAL_WER = 0.12
UMBRAL_SILENCIO_S = 3.5  # las pausas pedagógicas llegan a 2,5 s


def _letras(t, verbalizar=False):
    # La transcripción trae cifras y siglas («1,013», «QNH»): se pasa por el
    # mismo normalizador que el guion para comparar en igualdad.
    if verbalizar:
        t = normalizar(t)
    t = unicodedata.normalize("NFD", t.lower())
    t = "".join(c for c in t if unicodedata.category(c) != "Mn")
    return re.sub(r"[^a-zñ ]+", " ", t).split()


def wer(ref, hip):
    """Distancia de edición por palabras, en proporción de la referencia."""
    a, b = ref, hip
    prev = list(range(len(b) + 1))
    for i, x in enumerate(a, 1):
        cur = [i] + [0] * len(b)
        for j, y in enumerate(b, 1):
            cur[j] = min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (x != y))
        prev = cur
    return prev[-1] / max(1, len(a))


def capitulos(mp3):
    r = subprocess.run(["ffprobe", "-v", "error", "-show_chapters", "-of", "json", str(mp3)],
                       capture_output=True, text=True, check=True)
    return [(float(c["start_time"]), float(c["end_time"])) for c in json.loads(r.stdout)["chapters"]]


def ffmpeg_medidas(mp3):
    r = subprocess.run(
        ["ffmpeg", "-hide_banner", "-nostats", "-i", str(mp3), "-af",
         f"silencedetect=n=-50dB:d={UMBRAL_SILENCIO_S},ebur128=peak=true", "-f", "null", "-"],
        capture_output=True, text=True)
    err = r.stderr
    integrado = re.findall(r"I:\s+(-?[\d.]+) LUFS", err)
    pico = re.findall(r"Peak:\s+(-?[\d.]+) dBFS", err)
    silencios = [float(x) for x in re.findall(r"silence_duration: ([\d.]+)", err)]
    return (float(integrado[-1]) if integrado else None,
            float(pico[-1]) if pico else None, silencios)


def main():
    sin_asr = "--sin-asr" in sys.argv
    sys.argv = [x for x in sys.argv if x != "--sin-asr"]
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    dir_mp3, dir_guion = Path(sys.argv[1]), Path(sys.argv[2])
    pedidos = sys.argv[3:]
    mp3s = sorted(dir_mp3.glob("*.mp3"))
    if pedidos:
        claves = []
        for p in pedidos:
            n = re.sub(r"\D", "", p)
            claves.append(f"cap{int(n):02d}-" if n else "introduccion")
        mp3s = [m for m in mp3s if any(k in m.name for k in claves)]
    if not mp3s:
        raise SystemExit(f"verificar: no hay MP3 en {dir_mp3}; genera antes con `make audio`.")
    mal = 0
    for mp3 in mp3s:
        stem = mp3.stem.split("-", 1)[1]
        pistas = json.loads((dir_guion / f"{stem}.json").read_text(encoding="utf-8"))
        print(f"==> {mp3.name}", file=sys.stderr)
        avisos = []
        # Se transcribe pista a pista (una por sección): trozos de pocos
        # minutos que el reconocedor aguanta, y el aviso dice DÓNDE escuchar.
        cortes = capitulos(mp3)
        if len(cortes) != len(pistas):
            avisos.append(f"{len(cortes)} capítulos en el MP3 y {len(pistas)} pistas en el guion")
        errores = total = 0
        with tempfile.TemporaryDirectory() as tmp:
            trozos = []
            for k, ((ini, fin), p) in enumerate(zip(cortes, pistas)):
                trozo = Path(tmp) / f"pista{k:03d}.wav"
                subprocess.run(["ffmpeg", "-v", "error", "-y", "-ss", str(ini), "-to", str(fin),
                                "-i", str(mp3), "-ac", "1", "-ar", "16000", str(trozo)], check=True)
                trozos.append((trozo, ini, p))
            textos = [] if sin_asr else subprocess.run(
                [str(Path(__file__).with_name("transcribir.py")), *(str(t) for t, _, _ in trozos)],
                stdout=subprocess.PIPE, text=True, check=True).stdout.splitlines()
            for (trozo, ini, p), texto in zip(trozos, textos):
                ref = _letras(" ".join(sin_etiquetas(f["texto"]) for f in p["fragmentos"]))
                hip = _letras(texto, verbalizar=True)
                w = wer(ref, hip)
                errores += w * len(ref)
                total += len(ref)
                marca = "✗" if w > UMBRAL_WER else "·"
                print(f"   {marca} {ini / 60:5.1f} min  WER {w:5.1%}  {p['titulo'][:60]}", file=sys.stderr)
                if w > UMBRAL_WER:
                    avisos.append(f"WER {w:.0%} en «{p['titulo']}» (min {ini / 60:.1f}): escúchalo")
        w = errores / total if total and not sin_asr else None
        lufs, pico, silencios = ffmpeg_medidas(mp3)
        if lufs is not None and not -21 <= lufs <= -17:
            avisos.append(f"sonoridad {lufs} LUFS fuera de -21…-17")
        if pico is not None and pico > -1:
            avisos.append(f"pico {pico} dBFS")
        if silencios:
            avisos.append(f"{len(silencios)} silencios > {UMBRAL_SILENCIO_S:.0f} s (máx. {max(silencios):.1f} s)")
        estado = "✗" if avisos else "✓"
        mal += bool(avisos)
        wer_txt = f"WER {w:.1%}" if w is not None else "sin WER"
        print(f"{estado} {mp3.name}: {wer_txt}, {lufs} LUFS, pico {pico} dBFS"
              + ("".join(f"\n    · {a}" for a in avisos)))
    if mal:
        raise SystemExit(f"verificar: {mal} de {len(mp3s)} fuera de umbral.")


if __name__ == "__main__":
    main()
