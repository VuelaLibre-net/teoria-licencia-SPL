#!/usr/bin/env python3
"""Comprueba la estructura de los CHANGELOG de los libros.

Una línea en blanco entre dos viñetas convierte la lista en *loose*: Markdown
envuelve cada ítem en un párrafo y los separa más que a sus vecinos. El fichero
se sigue leyendo bien en bruto, así que el defecto sólo se ve al renderizarlo —en
GitHub, que es donde lo mira el revisor— y no rompe nada.

No es una regla de estilo inventada aquí: los CHANGELOG de este repo escriben sus
listas pegadas, y una viñeta suelta con aire de más se lee como si fuera de otra
sección. Al añadir entradas a mano es fácil dejarse el blanco; ha pasado cuatro
veces en un mismo día.

Cada registro abre además con un único ``[En curso]`` y no puede repetir una
versión. La web publica el fichero desde el tag de la release, por lo que una
entrada duplicada llega tal cual a producción aunque los libros compilen bien.

Sólo se mira dentro de las listas: el blanco que separa el párrafo introductorio
de la primera viñeta es correcto y tiene que quedarse.
"""
import glob
import re
import sys


def sueltas(ruta):
    """Blancos entre dos viñetas. Devuelve los números de línea (1-indexados)."""
    lineas = open(ruta, encoding="utf-8").read().split("\n")
    malas = []
    for i, linea in enumerate(lineas):
        if linea != "":
            continue
        anterior = lineas[i - 1] if i else ""
        # Una viñeta es `* …`; su continuación va sangrada. Si lo de antes es
        # cualquiera de las dos y lo de después abre otra viñeta, el blanco sobra.
        if not (anterior.startswith("* ") or anterior.startswith("  ")):
            continue
        siguiente = next((s for s in lineas[i + 1:] if s != ""), "")
        if siguiente.startswith("* "):
            malas.append(i + 1)
    return malas


def entradas_invalidas(ruta):
    """Errores en los H2 de versiones. Devuelve pares (línea, mensaje)."""
    lineas = open(ruta, encoding="utf-8").read().splitlines()
    entradas = [
        (i, m.group(1))
        for i, linea in enumerate(lineas, start=1)
        if (m := re.match(r"^## \[([^]]+)\]", linea))
    ]
    errores = []
    en_curso = [n for n, version in entradas if version == "En curso"]
    if len(en_curso) != 1:
        linea = en_curso[0] if en_curso else 1
        errores.append((linea, f"Debe haber un único «## [En curso]»; hay {len(en_curso)}."))
    elif entradas[0][1] != "En curso":
        errores.append((en_curso[0], "«## [En curso]» debe ser la primera entrada del registro."))

    vistas = {}
    for n, version in entradas:
        if version in vistas:
            errores.append((n, f"La entrada «{version}» ya aparece en la línea {vistas[version]}."))
        else:
            vistas[version] = n
    return errores


def main():
    ficheros = sorted(glob.glob("0*/CHANGELOG-*.md"))
    if len(ficheros) != 9:
        print(f"::error::Se esperaban 9 CHANGELOG y hay {len(ficheros)}: el guardián no comprobaría nada")
        return 1

    errores = 0
    for ruta in ficheros:
        for n in sueltas(ruta):
            print(f"::error file={ruta},line={n}::Línea en blanco entre dos viñetas: "
                  f"parte la lista en dos al renderizar. Quítala.")
            errores += 1
        for n, mensaje in entradas_invalidas(ruta):
            print(f"::error file={ruta},line={n}::{mensaje}")
            errores += 1

    print(f"Revisados {len(ficheros)} CHANGELOG; {errores} errores.")
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
