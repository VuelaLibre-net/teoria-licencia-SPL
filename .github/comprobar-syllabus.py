#!/usr/bin/env python3
"""Comprueba que el índice de cada libro calca su syllabus.

El syllabus es la raíz del proyecto: el temario sale del AMC1 SFCL.130 y la
estructura del libro lo copia, no al revés.

  * Cada entrada de primer nivel (4.1, 4.2…) es un capítulo, en el mismo orden.
  * Si una entrada tiene subentradas (4.2 -> 4.2.1, 4.2.2, 4.2.3), son las
    secciones H2 de ese capítulo, en el mismo orden. Sólo se miran los H2 de los
    capítulos cuya entrada tiene hijas: el resto organiza sus secciones como le
    conviene.

Desalinearse no da ningún síntoma —el libro compila igual de bien— y un título
recortado puede tapar un hueco de contenido: el cap08 del libro 01 prometía ATS
y ATM y sólo desarrollaba el ATS.

Se comparan las PALABRAS, no los bytes: el título aplica la norma española de
mayúsculas y pone en cursiva los términos ingleses, mientras que el apéndice
reproduce el syllabus tal cual. Se ignoran mayúsculas y cursivas, y se exige que
no falte ni sobre una palabra.

Dos trampas que este fichero evita a propósito, y que costaron dos análisis
equivocados antes de existir:

1. Una entrada con subentradas NO es materia de un capítulo por sí sola.
   Emparejar «capítulo N con entrada N» daba los 7 capítulos del libro 04 por
   mal titulados cuando estaban bien.
2. El syllabus del libro 07 escribe sus entradas en negrita (`* **7.1. …**`). Un
   parser que no lo contemple no encuentra ninguna entrada, no compara nada y
   pasa en verde. De ahí que se exija que cada libro dé entradas y que su número
   cuadre con el de capítulos.
"""

import pathlib
import re
import sys

ENTRADA = re.compile(r'^\s*\* \*{0,2}(\d+(?:\.\d+)+)\.\s*(.+?)\*{0,2}\s*$', re.M)


def entradas(texto):
    """[(clave, título)] tal como aparecen en el apéndice.

    Se le quita la puntuación final: el punto con el que acaba cada entrada y
    los dos puntos de las que anuncian una sublista («4.2. Comunicaciones VFR:»).
    Ninguno es parte del título del capítulo.
    """
    return [(c, t.rstrip('.: ').strip()) for c, t in ENTRADA.findall(texto)]


def palabras(s):
    """Sólo las palabras: sin cursivas, sin mayúsculas, sin espacios de más."""
    return re.sub(r'\s+', ' ', s.replace('*', '')).strip().lower()


def encabezados(texto, nivel):
    marca = '#' * nivel
    return [l[nivel + 1:].strip() for l in texto.split('\n')
            if l.startswith(marca + ' ')]


def comprobar_libro(d):
    errores = 0
    syls = list(d.glob('apendice-syllabus*.qmd'))
    if not syls:
        print(f"::error::{d} no tiene apéndice de syllabus")
        return 1
    syl = syls[0]

    todas = entradas(syl.read_text(encoding='utf-8'))
    if not todas:
        print(f"::error file={syl}::El syllabus no da ni una entrada; la "
              f"comprobación pasaría en vacío. ¿Ha cambiado su formato?")
        return 1

    principales = [(c, t) for c, t in todas if c.count('.') == 1]
    hijas = {}
    for c, t in todas:
        if c.count('.') == 2:
            hijas.setdefault(c.rsplit('.', 1)[0], []).append((c, t))

    caps = sorted(d.glob('cap*.qmd'))
    if len(principales) != len(caps):
        print(f"::error file={syl}::{len(principales)} entradas de primer nivel "
              f"y {len(caps)} capítulos: el índice no calca el syllabus")
        return 1

    for (clave, ent), p in zip(principales, caps):
        texto = p.read_text(encoding='utf-8')
        h1 = encabezados(texto, 1)
        if len(h1) != 1:
            print(f"::error file={p}::Tiene {len(h1)} encabezados de nivel 1 y "
                  f"debe tener exactamente 1")
            errores = 1
            continue
        if palabras(h1[0]) != palabras(ent):
            print(f"::error file={p}::El título no dice lo que la entrada "
                  f"{clave} del syllabus")
            print(f"    syllabus: {ent}")
            print(f"    título  : {h1[0]}")
            errores = 1

        if clave in hijas:
            esperadas = [t for _, t in hijas[clave]]
            h2 = encabezados(texto, 2)
            if [palabras(x) for x in h2] != [palabras(x) for x in esperadas]:
                print(f"::error file={p}::Las secciones no calcan las "
                      f"subentradas de {clave} del syllabus")
                for x in esperadas:
                    print(f"    syllabus: {x}")
                for x in h2:
                    print(f"    sección : {x}")
                errores = 1

    return errores


def main():
    libros = sorted(p for p in pathlib.Path('.').glob('0*-*') if p.is_dir())
    if len(libros) != 9:
        print(f"::error::Se han encontrado {len(libros)} libros y se esperan 9")
        return 1
    return max(comprobar_libro(d) for d in libros)


if __name__ == '__main__':
    sys.exit(main())
