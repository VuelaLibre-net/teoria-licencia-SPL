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
Y si cambia sólo un párrafo, VoiceStudio reutiliza de su caché todos los demás
fragmentos, así que rehacer un capítulo tras corregir una sigla cuesta segundos.
"""

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

import guion as G
import cliente as C

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


def base_peticion(cfg_sintesis):
    s = cfg_sintesis
    return {
        "language": s["idioma"], "num_step": s["num_step"], "guidance_scale": s["guidance_scale"],
        "seed": s["seed"], "trim_edges": s["trim_edges"], "loudness": s["loudness"],
    }


def spans(pistas, ids):
    for p in pistas:
        yield p["titulo"], [
            {"voice_id": ids[f["voz"]], "text": f["texto"], "pause_ms_after": f["pausa"],
             "speed": f.get("velocidad")}
            for f in p["fragmentos"]]


def huella(peticion):
    # La portada se sube en cada ejecución con un nombre nuevo: entra su
    # contenido, no su ruta en el servidor.
    p = dict(peticion)
    p.pop("cover_path", None)
    return hashlib.sha256(json.dumps(p, sort_keys=True, ensure_ascii=False).encode()).hexdigest()


def producir(peticion, destino, huella_extra=""):
    h = huella(peticion) + huella_extra
    marca = destino.with_name(destino.name + ".huella")
    if destino.exists() and marca.exists() and marca.read_text().strip() == h:
        print(f"✓ {destino} al día")
        return False
    print(f"==> [VoiceStudio] {destino.name}", file=sys.stderr)
    final = C.renderizar(peticion, C.progreso_consola)
    C.descargar(final["output"], destino)
    marca.write_text(h + "\n")
    cache = final.get("cached_chapters", 0)
    print(f"✓ {destino} ({final.get('duration_s', 0) / 60:.1f} min, {cache} pistas de caché)")
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

    # 2. Voces: todas las del reparto tienen que existir en VoiceStudio.
    ids = C.perfiles()
    usadas = {fr["voz"] for _, _, ps in guiones for p in ps for fr in p["fragmentos"]} | {
        reparto["roles"]["creditos"]["voz"]}
    faltan = sorted(usadas - ids.keys())
    if faltan:
        raise SystemExit("audio: faltan voces en VoiceStudio: " + ", ".join(faltan) +
                         ". Créalas con `make audio-voces CREAR=1`.")
    s = reparto["sintesis"]
    base = base_peticion(s)
    meta = {"author": autor, "album": titulo_libro, "year": anio, "genre": "Audiolibro; Aviación",
            "narrator": "Voces sintéticas (VoiceStudio, OmniVoice) clonadas de grabaciones libres. "
                        + " ".join(G.atribuciones())}

    # 3. Un MP3 por fichero. Cada sección `##` es un capítulo del MP3.
    for f, etiqueta, pistas in guiones:
        stem = Path(f).stem
        num = nombre.split("-")[0]
        titulo = pistas[0]["titulo"] if pistas else stem
        pet = dict(base, format="mp3", bitrate=s["mp3_bitrate"],
                   chapters=[{"title": t, "spans": sp} for t, sp in spans(pistas, ids)],
                   metadata=dict(meta, title=(f"{etiqueta}. " if etiqueta else "") + titulo))
        producir(pet, dir_libro / f"{num}-{stem}.mp3")

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
    portada = libro / "cover" / "frente.jpg"
    pet = dict(base, format="m4b", bitrate=s["m4b_bitrate"],
               chapters=[{"title": t, "spans": sp} for t, sp in spans(capitulos, ids)],
               metadata=dict(meta, title=titulo_libro, description=descripcion(libro)))
    extra = hashlib.sha256(portada.read_bytes()).hexdigest()[:16] if portada.exists() else ""
    destino = salida / f"{nombre}-{a.sufijo}.m4b"
    marca = destino.with_name(destino.name + ".huella")
    if not (destino.exists() and marca.exists() and marca.read_text().strip() == huella(pet) + extra):
        if portada.exists():
            pet["cover_path"] = C.subir_portada(portada.resolve())
    producir(pet, destino, extra)


if __name__ == "__main__":
    main()
