#!/usr/bin/env python3
"""Audiolibro de un libro SPL, o de algunos de sus capítulos.

Uso (lo llama el Makefile, que es quien sabe versión, fecha y estado):

    audio.py <libro> [cap01 cap02 … | intro] --version V --fecha F --sufijo S
             [--estado E] [--salida build/audio] [--solo-guion]

Sin capítulos hace el libro entero: un MP3 por capítulo y el M4B con
créditos, capítulos marcados y portada. Con capítulos, sólo sus MP3.

Cada salida lleva al lado una huella (`.huella`) de la petición exacta que la
produjo. Si la huella no cambia, no se vuelve a pedir nada: es lo que hace las
veces de la fecha de los otros entregables, y no se deja engañar por mtimes.
Cada fragmento sintetizado queda en ~/.cache/spl-audio/fragmentos/: si cambia
sólo un párrafo, los demás salen de ahí y rehacer el capítulo tras corregir una
sigla cuesta lo que tarda el montaje.
"""

import argparse
import hashlib
import json
import re
import subprocess
import sys
import time
from pathlib import Path

import guion as G
import cliente as C
import montaje as M

RAIZ = Path(__file__).resolve().parents[2]


def elegir(libro, pedidos):
    todos = G.ficheros_libro(libro)
    if not pedidos:
        return todos
    elegidos = []
    for p in pedidos:
        if p in ("intro", "introduccion"):
            clave = "introduccion.qmd"
        else:
            m = re.fullmatch(r"(?:cap)?0*(\d+)", p)
            if not m:
                raise SystemExit(f"audio: no entiendo «{p}»; usa cap01, 1 o intro.")
            clave = f"cap{int(m.group(1)):02d}-"
        hallados = [t for t in todos if Path(t[0]).name.startswith(clave)]
        if not hallados:
            raise SystemExit(f"audio: {libro} no tiene «{p}».")
        elegidos += [h for h in hallados if h not in elegidos]
    return elegidos


def parametros(cfg_sintesis):
    s = cfg_sintesis
    return {"motor": s.get("motor", "omnivoice"), "idioma": s["idioma"], "num_step": s.get("num_step"),
            "guidance_scale": s.get("guidance_scale"), "seed": s.get("seed"), "loudness": s.get("loudness")}


CACHE = Path.home() / ".cache" / "spl-audio" / "fragmentos"

# Las herramientas del montaje también entran en la huella: cambiar un earcon
# o el máster rehace el audio.
HERRAMIENTAS = hashlib.sha256(b"".join(
    (Path(__file__).with_name(n)).read_bytes() for n in ("earcons.py", "montaje.py"))).hexdigest()[:16]


def _clave(fr, voz, params):
    """Identidad de un fragmento sintetizado: texto, voz (perfil, grabación,
    transcripción e instrucción) y parámetros del motor. Igual clave, mismo
    audio: se reutiliza de la caché."""
    return hashlib.sha256(json.dumps(
        [fr["texto"], fr.get("velocidad"), voz.get("id"), voz.get("ref_audio_path"), voz.get("ref_text"),
         voz.get("instruct"), params], sort_keys=True, ensure_ascii=False).encode()).hexdigest()


def sintetizar(pistas, perfiles, params):
    """Sintetiza los fragmentos que falten en la caché y devuelve las pistas
    listas para montaje.montar. Un fragmento por petición a /generate: así
    VoiceStudio usa un solo proceso del motor (ver montaje.py)."""
    motor = params["motor"]
    plan, pendientes = [], []
    for p in pistas:
        piezas = []
        for fr in p["fragmentos"]:
            if fr.get("earcon"):
                piezas.append(("earcon", fr["earcon"]))
                continue
            voz = perfiles[fr["voz"]]
            k = _clave(fr, voz, params)
            ruta = CACHE / motor / k[:2] / f"{k}.wav"
            if not ruta.exists():
                pendientes.append((fr, voz, ruta))
            piezas += [("voz", ruta), ("silencio", fr.get("pausa", 0))]
        plan.append({"titulo": p["titulo"], "piezas": piezas})
    t0 = time.time()
    for n, (fr, voz, ruta) in enumerate(pendientes, 1):
        C.generar(fr["texto"], voz["id"], ruta, motor=motor, idioma=params["idioma"],
                  num_step=params.get("num_step"), guidance_scale=params.get("guidance_scale"),
                  seed=params.get("seed"), speed=fr.get("velocidad"))
        if n % 10 == 0 or n == len(pendientes):
            print(f"   · {n}/{len(pendientes)} fragmentos ({time.time() - t0:.0f} s)", file=sys.stderr)
    return plan, len(pendientes)


def producir(pistas, destino, perfiles, params, formato, bitrate, meta, portada=None, huella_extra=""):
    """Voz por fragmentos (con caché) + montaje propio con silencios, earcons
    y máster. Si la huella no cambia, no se hace nada."""
    portada_h = hashlib.sha256(Path(portada).read_bytes()).hexdigest()[:16] if portada and Path(portada).exists() else ""
    h = hashlib.sha256(json.dumps(
        [[[f.get("earcon"), f.get("texto"), f.get("voz"), f.get("pausa"), f.get("velocidad")] for f in p["fragmentos"]]
         for p in pistas] + [[p["titulo"] for p in pistas], formato, bitrate, meta, params, portada_h,
                             HERRAMIENTAS, huella_extra,
                             {n: [v.get("id"), v.get("ref_audio_path"), v.get("instruct")] for n, v in perfiles.items()}],
        sort_keys=True, ensure_ascii=False).encode()).hexdigest()
    marca = destino.with_name(destino.name + ".huella")
    if destino.exists() and marca.exists() and marca.read_text().strip() == h:
        print(f"✓ {destino} al día")
        return False
    print(f"==> [VoiceStudio] {destino.name}", file=sys.stderr)
    plan, nuevos = sintetizar(pistas, perfiles, params)
    print("   · montando y masterizando…", file=sys.stderr)
    r = M.montar(plan, destino, formato, bitrate, meta, portada, params.get("loudness"))
    marca.write_text(h + "\n")
    print(f"✓ {destino} ({r['duracion_s'] / 60:.1f} min, {r['capitulos']} capítulos, {nuevos} fragmentos nuevos)")
    return True


def descripcion(libro):
    """El blurb corto del media-kit: lo que leen Apple Books y compañía."""
    mk = RAIZ / "recursos" / "media-kit" / f"{Path(libro).name}.md"
    if not mk.exists():
        return None
    texto = mk.read_text(encoding="utf-8").split("## Blurb corto", 1)[-1].split("\n---", 1)[0]
    texto = re.sub(r"^#.*$|^>\s*", "", texto, flags=re.M)
    texto = re.sub(r"\*\*|\*", "", texto)
    return re.sub(r"\s+", " ", texto).strip() or None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("libro")
    ap.add_argument("caps", nargs="*")
    ap.add_argument("--version", required=True)
    ap.add_argument("--fecha", required=True)
    ap.add_argument("--sufijo", required=True)
    ap.add_argument("--estado", default="")
    ap.add_argument("--salida", default="build/audio")
    ap.add_argument("--solo-guion", action="store_true")
    a = ap.parse_args()

    libro = Path(a.libro)
    if not (libro / "_quarto.yml").exists():
        raise SystemExit(f"audio: {libro} no es un libro de la colección.")
    nombre = libro.name
    salida = Path(a.salida)
    dir_guion = salida / "guion" / nombre
    dir_libro = salida / f"{nombre}-{a.sufijo}"
    reparto = G.reparto()
    cfg_libro = G.config_libro(libro)
    titulo_libro = cfg_libro["book"]["title"]
    autor = cfg_libro["book"].get("author", "VuelaLibre.net")
    anio = a.fecha.split()[-1]

    # 1. Guion de cada fichero, con su guardián: nada de cifras ni Markdown
    #    sueltos, que el motor leería a su manera.
    elegidos = elegir(libro, a.caps)
    guiones = []
    for f, etiqueta in elegidos:
        pistas = G.guion_fichero(libro / f, etiqueta)
        malos = G.residuos(pistas)
        if malos:
            for t, frag in malos[:20]:
                print(f"✗ {f} [{t}] …{frag}…", file=sys.stderr)
            raise SystemExit(f"audio: {f} deja {len(malos)} restos sin verbalizar; "
                             "corrige normalizar.py, reglas.yml o pronunciacion.yml.")
        stem = Path(f).stem
        G.escribir(pistas, dir_guion / f"{stem}.json", dir_guion / f"{stem}.txt")
        n = G.palabras(pistas)
        print(f"✓ guion {dir_guion / stem}.txt ({n} palabras, ~{n / 150:.0f} min)")
        guiones.append((f, etiqueta, pistas))
    if a.solo_guion:
        return

    # 2. Voces: todas las del reparto tienen que existir en VoiceStudio, con
    #    su instrucción de estilo al día.
    subprocess.run([str(Path(__file__).with_name("voces.py"))], check=True, stdout=subprocess.DEVNULL)
    perfiles = {p["name"]: p for p in C.get_json("/profiles")}
    ids = {n: p["id"] for n, p in perfiles.items()}
    usadas = {fr["voz"] for _, _, ps in guiones for p in ps for fr in p["fragmentos"] if fr.get("voz")} | {
        reparto["roles"]["creditos"]["voz"]}
    faltan = sorted(usadas - ids.keys())
    if faltan:
        raise SystemExit("audio: faltan voces en VoiceStudio: " + ", ".join(faltan) +
                         ". Créalas con `make audio-voces CREAR=1`.")
    s = reparto["sintesis"]
    params = parametros(s)
    # El motor va en cada petición a /generate (y en la huella y la caché);
    # se deja también activo en VoiceStudio para que la interfaz lo muestre.
    motor = s.get("motor", "omnivoice")
    C.seleccionar_motor(motor)
    # Las instrucciones de estilo van en el perfil, no en la petición: entran
    # en la huella para que cambiarlas rehaga el audio.
    extra = motor + json.dumps({n: v.get("instruccion") for n, v in reparto["voces"].items()}, sort_keys=True)
    meta = {"author": autor, "album": titulo_libro, "year": anio, "genre": "Audiolibro; Aviación",
            "narrator": f"Voces sintéticas (VoiceStudio, {motor}) clonadas de grabaciones libres. "
                        + " ".join(G.atribuciones())}

    # 3. Un MP3 por fichero. Cada sección `##` es un capítulo del MP3.
    for f, etiqueta, pistas in guiones:
        stem = Path(f).stem
        num = nombre.split("-")[0]
        titulo = pistas[0]["titulo"] if pistas else stem
        producir(pistas, dir_libro / f"{num}-{stem}.mp3", perfiles, params, "mp3", s["mp3_bitrate"],
                 dict(meta, title=(f"{etiqueta}. " if etiqueta else "") + titulo), huella_extra=extra)

    # 4. El libro entero: M4B con créditos, un capítulo por fichero y cierre.
    if a.caps:
        return
    capitulos = [G.creditos_apertura(libro, a.version, a.fecha)]
    for _, etiqueta, pistas in guiones:
        todos = [fr for p in pistas for fr in p["fragmentos"]]
        titulo = pistas[0]["titulo"]
        capitulos.append({"titulo": f"{etiqueta}. {titulo}" if etiqueta else titulo, "fragmentos": todos})
    capitulos.append(G.creditos_cierre(libro))
    G.escribir(capitulos, dir_guion / "libro.json", dir_guion / "libro.txt")
    producir(capitulos, salida / f"{nombre}-{a.sufijo}.m4b", perfiles, params, "m4b", s["m4b_bitrate"],
             dict(meta, title=titulo_libro, description=descripcion(libro)),
             portada=libro / "cover" / "frente.jpg", huella_extra=extra)


if __name__ == "__main__":
    main()
