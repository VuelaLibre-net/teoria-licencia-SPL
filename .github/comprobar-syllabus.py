#!/usr/bin/env python3
"""Comprueba que cada capítulo se titula como su entrada del syllabus.

El syllabus es la raíz del proyecto: el temario de cada libro sale del AMC1
SFCL.130 y el título del capítulo copia su entrada. Si se desalinean, el libro
compila igual de bien y nadie se entera; un título recortado puede además estar
tapando un hueco de contenido, como pasó con el cap08 del libro 01, que prometía
ATS y ATM y sólo desarrollaba el ATS.

Se comparan las PALABRAS, no los bytes: el título aplica la norma española de
mayúsculas y pone en cursiva los términos ingleses, mientras que el apéndice
reproduce el syllabus tal cual. Así que se ignoran mayúsculas y cursivas, y se
exige que no falte ni sobre una palabra.

Dos trampas que este fichero evita a propósito, y que costaron dos análisis
equivocados:

1. Una entrada con subentradas (4.2 -> 4.2.1, 4.2.2, 4.2.3) NO es materia de un
   capítulo: lo son sus hijas. El libro 04 mapea sus 9 capítulos a las hojas del
   syllabus, no a las entradas de primer nivel. Emparejar por número daba los 7
   capítulos por mal titulados cuando estaban bien.
2. El syllabus del libro 07 escribe sus entradas en negrita (`* **7.1. …**`). Un
   parser que no lo contemple no encuentra ninguna entrada, no compara nada y
   pasa en verde. Por eso se exige que cada libro dé al menos una entrada y que
   el número de entradas cuadre con el de capítulos.
"""

import pathlib
import re
import sys

ENTRADA = re.compile(r'^\s*\* \*{0,2}(\d+(?:\.\d+)+)\.\s*(.+?)\*{0,2}\s*$', re.M)


def hojas(texto: str):
    """Entradas del syllabus que no tienen subentradas."""
    ent = ENTRADA.findall(texto)
    claves = [c for c, _ in ent]
    return [(c, t.rstrip('.').strip()) for c, t in ent
            if not any(o != c and o.startswith(c + '.') for o in claves)]


def palabras(s: str) -> str:
    """Sólo las palabras: sin cursivas, sin mayúsculas, sin espacios de más."""
    return re.sub(r'\s+', ' ', s.replace('*', '')).strip().lower()


def main() -> int:
    errores = 0
    libros = sorted(p for p in pathlib.Path('.').glob('0*-*') if p.is_dir())
    if len(libros) != 9:
        print(f"::error::Se han encontrado {len(libros)} libros y se esperan 9")
        return 1

    for d in libros:
        syls = list(d.glob('apendice-syllabus*.qmd'))
        if not syls:
            print(f"::error::{d} no tiene apéndice de syllabus")
            errores = 1
            continue

        h = hojas(syls[0].read_text(encoding='utf-8'))
        caps = sorted(d.glob('cap*.qmd'))
        if not h:
            print(f"::error file={syls[0]}::El syllabus no da ni una entrada; "
                  f"la comprobación pasaría en vacío. ¿Ha cambiado su formato?")
            errores = 1
            continue
        if len(h) != len(caps):
            print(f"::error file={syls[0]}::{len(h)} entradas de syllabus y "
                  f"{len(caps)} capítulos: no se pueden emparejar")
            errores = 1
            continue

        for (clave, ent), p in zip(h, caps):
            titulo = p.read_text(encoding='utf-8').split('\n', 1)[0]
            if not titulo.startswith('# '):
                print(f"::error file={p}::La primera línea no es un H1")
                errores = 1
                continue
            titulo = titulo[2:].strip()
            if palabras(titulo) != palabras(ent):
                print(f"::error file={p}::El título no dice lo que la entrada "
                      f"{clave} del syllabus")
                print(f"    syllabus: {ent}")
                print(f"    título  : {titulo}")
                errores = 1

    return errores


if __name__ == '__main__':
    sys.exit(main())
