#!/usr/bin/env python3
"""Vuelca el material de un capítulo y arma el esqueleto de su mazo Anki.

No genera tarjetas: genera el fichero donde se escriben. La diferencia importa.

Se intentó primero la conversión mecánica y no vale, por la misma razón que dan
las guías de escritura de tarjetas y que sostiene la colección: una tarjeta
prueba UN hecho y su anverso es una pregunta con UNA respuesta. Una viñeta de
post-it es al menos tres hechos encadenados —«1 minuto de latitud equivale a 1
milla náutica, porque la milla se definió como el minuto de arco de meridiano; 1
minuto de longitud varía con la latitud»— y un recuadro de Seguridad es un
párrafo de prosa sin ninguna pregunta implícita. Partirlos exige criterio, y una
tarjeta mala memorizada es peor que no tenerla.

Así que esto escribe `tarjetas: []` y deja el material de origen como comentario
al pie, para redactar contra él sin abrir el .qmd. El fichero resultante es
fuente canónica igual que los .qmd: se edita a mano y no se regenera.

    tools/anki/extraer.py 09-navegacion            # los capítulos que falten
    tools/anki/extraer.py 09-navegacion --forzar   # rehace el esqueleto

⚠️ `--forzar` reescribe el fichero y se lleva por delante las tarjetas escritas.
Sin él, un capítulo que ya tiene mazo se salta.
"""

from __future__ import annotations

import argparse
import pathlib
import re
import sys

RAIZ = pathlib.Path(__file__).resolve().parents[2]
MAZOS = RAIZ / "tools" / "anki" / "mazos"

# El mapeo del temario, el mismo de CLAUDE.md. Se repite aquí y no se importa de
# ningún sitio porque no hay ningún sitio: vive en la prosa de los .qmd, en el
# título de cada callout. Lo que sí se comprueba es que el título encontrado esté
# en esta tabla (ver `validar.py`).
CATEGORIAS = {
    "callout-warning": "Seguridad",
    "callout-important": "Normativa",
    "callout-tip": "Regla de oro",
    "callout-note": "Airmanship",
}

RE_POSTIT = re.compile(r"::: \{\.postit\}\n(.*?)\n:::", re.S)
RE_CALLOUT = re.compile(r"::: \{\.(callout-\w+) title=\"([^\"]*)\"\}\n(.*?)\n:::", re.S)
RE_VINETA = re.compile(r"^\* (.+?)(?=\n\* |\n*\Z)", re.M | re.S)


def titulo_de(texto: str) -> str:
    m = re.search(r"^# (.+)$", texto, re.M)
    return m.group(1).strip() if m else "?"


def material_de(ruta: pathlib.Path) -> tuple[list[str], list[tuple[str, str]]]:
    """Devuelve (viñetas del post-it, [(categoría, texto)] de los recuadros)."""
    texto = ruta.read_text(encoding="utf-8")

    vinetas: list[str] = []
    postit = RE_POSTIT.search(texto)
    if postit:
        vinetas = [" ".join(v.split()) for v in RE_VINETA.findall(postit.group(1))]

    recuadros: list[tuple[str, str]] = []
    for clase, titulo, cuerpo in RE_CALLOUT.findall(texto):
        # El título puede llevar sufijo propio: `title="Seguridad: FLUTTER"`.
        categoria = titulo.split(":")[0].split("—")[0].strip()
        recuadros.append((categoria or CATEGORIAS.get(clase, "?"), " ".join(cuerpo.split())))

    return vinetas, recuadros


def envolver(texto: str, ancho: int = 92, sangria: str = "#     ") -> list[str]:
    palabras, linea, salida = texto.split(), "", []
    for p in palabras:
        if len(linea) + len(p) + 1 > ancho and linea:
            salida.append(sangria + linea)
            linea = p
        else:
            linea = f"{linea} {p}".strip()
    if linea:
        salida.append(sangria + linea)
    return salida


def esqueleto(libro: str, numero: int, titulo: str, vinetas, recuadros) -> str:
    lineas = [
        f"# Mazo Anki de {libro}, capítulo {numero}.",
        "#",
        "# Fuente canónica: se edita a mano. `extraer.py` sólo crea el esqueleto y",
        "# vuelca el material al pie; no vuelve a tocar este fichero.",
        "#",
        "# Cada tarjeta: id (slug estable, NO renombrar: es la identidad de la nota",
        "# en la colección del alumno), tipo (basica|cloze), y los campos.",
        f"libro: {libro}",
        f"capitulo: {numero}",
        # Entre comillas siempre: hay títulos con dos puntos («Derecho
        # internacional: convenios, acuerdos y organizaciones») y sin comillas
        # YAML los lee como un mapa anidado y aborta.
        'titulo: "{}"'.format(titulo.replace('"', "'")),
        "tarjetas: []",
        "",
        "# " + "=" * 74,
        "# MATERIAL DE ORIGEN — no lo lee ninguna herramienta, es para redactar.",
        "# " + "=" * 74,
    ]

    lineas.append("#")
    lineas.append(f"# POST-IT ({len(vinetas)} viñetas)")
    for i, v in enumerate(vinetas, 1):
        lineas.append(f"#  [{i}]")
        lineas.extend(envolver(v))
    if not vinetas:
        lineas.append("#   (el capítulo no tiene post-it)")

    lineas.append("#")
    lineas.append(f"# RECUADROS ({len(recuadros)})")
    for i, (categoria, cuerpo) in enumerate(recuadros, 1):
        lineas.append(f"#  [{categoria} {i}]")
        lineas.extend(envolver(cuerpo))
    if not recuadros:
        lineas.append("#   (el capítulo no tiene recuadros)")

    return "\n".join(lineas) + "\n"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("libro")
    ap.add_argument("--forzar", action="store_true", help="reescribe mazos ya existentes")
    args = ap.parse_args()

    origen = RAIZ / args.libro
    if not origen.is_dir():
        print(f"✗ No existe el libro {args.libro}", file=sys.stderr)
        return 1

    destino = MAZOS / args.libro
    destino.mkdir(parents=True, exist_ok=True)

    creados = saltados = 0
    for ruta in sorted(origen.glob("cap[0-9][0-9]-*.qmd")):
        numero = int(ruta.name[3:5])
        salida = destino / f"cap{numero:02d}.yml"
        if salida.exists() and not args.forzar:
            saltados += 1
            continue
        texto = ruta.read_text(encoding="utf-8")
        vinetas, recuadros = material_de(ruta)
        salida.write_text(
            esqueleto(args.libro, numero, titulo_de(texto), vinetas, recuadros),
            encoding="utf-8",
        )
        creados += 1

    print(f"✓ {args.libro}: {creados} esqueleto(s) en {destino.relative_to(RAIZ)}"
          + (f", {saltados} ya existente(s)" if saltados else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
