#!/usr/bin/env python3
"""Comprueba que el nombre de cada asignatura dice lo mismo en los tres sitios.

El mismo dato vive por triplicado y nada lo sincroniza:

  1. `title:` del `_quarto.yml`, que es lo que sale en la portadilla y en los
     metadatos del PDF y del EPUB.
  2. El apéndice del syllabus, que abre diciendo a qué asignatura corresponde.
  3. La tabla del README.

Divergir no da ningún síntoma: los nueve libros compilan igual. Y pasó de
verdad. El `title:` del libro 8 decía «Conocimientos Generales de la Aeronave»
mientras su propio apéndice —y su cubierta— decían «…, Estructura, Sistemas y
Equipo de Emergencia»: el título se comía media asignatura, que en el AMC1
SFCL.130 se llama AIRCRAFT GENERAL KNOWLEDGE, AIRFRAME AND SYSTEMS AND EMERGENCY
EQUIPMENT. El libro 1 se dejaba el «(ATC)» por el camino, y el README publicaba
nombres que no coincidían con ningún libro en 8 de los 9.

Lo que NO se comprueba aquí es la fidelidad al AMC1: el AMC se publica sólo en
inglés y el nombre en español es una decisión editorial. El libro 2 se llama
«Factores Humanos» a sabiendas de que EASA titula la asignatura HUMAN
PERFORMANCE, porque es como se la conoce en España. Eso lo decide una persona;
lo que un guardián puede exigir es que, decidido, no se contradiga a sí mismo.

La cubierta lleva el título impreso en la propia imagen y no se puede
comprobar desde aquí: si cambias un título, míralas.
"""

import pathlib
import re
import sys

TITULO_YML = re.compile(r'^  title: *"?([^"\n]+?)"?$', re.M)
ASIGNATURA = re.compile(r'asignatura de \*\*(.+?)\*\*|asignatura \*{0,2}(.+?)\*{0,2} para')


def fila_readme(readme, libro):
    m = re.search(rf'\|\s*\d+\s*\|\s*\*\*`{re.escape(libro)}`\*\*\s*\|\s*([^|]+?)\s*\|', readme)
    return m.group(1) if m else None


def main():
    raiz = pathlib.Path('.')
    readme = (raiz / 'README.md').read_text(encoding='utf-8')
    libros = sorted(p for p in raiz.glob('0*-*') if p.is_dir())
    if len(libros) != 9:
        print(f"::error::Se han encontrado {len(libros)} libros y se esperan 9")
        return 1

    errores = 0
    for d in libros:
        yml = (d / '_quarto.yml').read_text(encoding='utf-8')
        m = TITULO_YML.search(yml)
        if not m:
            print(f"::error file={d}/_quarto.yml::No tiene `title:`")
            errores = 1
            continue
        titulo = m.group(1).strip()

        syls = list(d.glob('apendice-syllabus*.qmd'))
        if not syls:
            print(f"::error::{d} no tiene apéndice de syllabus")
            errores = 1
            continue
        ma = ASIGNATURA.search(syls[0].read_text(encoding='utf-8'))
        if not ma:
            print(f"::error file={syls[0]}::No dice a qué asignatura corresponde; "
                  f"la comprobación pasaría en vacío. ¿Ha cambiado su redacción?")
            errores = 1
            continue
        apendice = (ma.group(1) or ma.group(2)).strip()

        fila = fila_readme(readme, d.name)
        if fila is None:
            print(f"::error file=README.md::La tabla no tiene fila para {d.name}")
            errores = 1
            continue

        if apendice != titulo:
            print(f"::error file={syls[0]}::El apéndice llama a la asignatura de "
                  f"otra forma que el `title:` del libro")
            print(f"    title:   {titulo}")
            print(f"    apéndice: {apendice}")
            errores = 1
        if fila != titulo:
            print(f"::error file=README.md::La tabla publica un nombre distinto "
                  f"del `title:` de {d.name}")
            print(f"    title:  {titulo}")
            print(f"    README: {fila}")
            errores = 1

    return errores


if __name__ == '__main__':
    sys.exit(main())
