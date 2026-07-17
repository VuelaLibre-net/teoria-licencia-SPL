#!/usr/bin/env python3
"""Caza las listas «loose» en los CHANGELOG de los libros.

Una línea en blanco entre dos viñetas convierte la lista en *loose*: Markdown
envuelve cada ítem en un párrafo y los separa más que a sus vecinos. El fichero
se sigue leyendo bien en bruto, así que el defecto sólo se ve al renderizarlo —en
GitHub, que es donde lo mira el revisor— y no rompe nada.

No es una regla de estilo inventada aquí: los CHANGELOG de este repo escriben sus
listas pegadas, y una viñeta suelta con aire de más se lee como si fuera de otra
sección. Al añadir entradas a mano es fácil dejarse el blanco; ha pasado cuatro
veces en un mismo día.

Sólo se mira dentro de las listas: el blanco que separa el párrafo introductorio
de la primera viñeta es correcto y tiene que quedarse.
"""
import glob
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

    print(f"Revisados {len(ficheros)} CHANGELOG; {errores} listas partidas.")
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
