#!/usr/bin/env python3
r"""Comprueba que las velocidades con subíndice no queden como texto literal.

Pandoc acepta `V~A~`, pero si el subíndice contiene espacios hay que escaparlos:
`V~z\ min~`, no `V~z min~`. La segunda forma se publica literalmente como
`V~z min~` en PDF, EPUB y RAG, sin que Quarto falle.

Se miran dos cosas:

1. La fuente: cualquier espacio sin escapar dentro de `V~...~` es un error.
2. El AST de Pandoc: después de parsear, no debe quedar ningún texto `V~...~`.

La segunda comprobación evita depender sólo de una regex sobre Markdown: si Pandoc
no ha creado un nodo Subscript, el defecto llegará a los entregables.
"""
import glob
import json
import re
import subprocess
import sys


LITERAL_SUBINDICE = re.compile(r"V~[^~\n]*~")


def espacio_sin_escapar(texto):
    """Devuelve True si hay un espacio no escapado dentro de un subíndice."""
    escapado = False
    for ch in texto:
        if escapado:
            escapado = False
            continue
        if ch == "\\":
            escapado = True
            continue
        if ch.isspace():
            return True
    return False


def grupos_sospechosos(linea):
    """Localiza grupos `V~...~` cuyo interior contiene espacios sin escapar."""
    i = 0
    while True:
        inicio = linea.find("V~", i)
        if inicio == -1:
            return
        fin = linea.find("~", inicio + 2)
        if fin == -1:
            i = inicio + 2
            continue
        interior = linea[inicio + 2 : fin]
        if espacio_sin_escapar(interior):
            yield linea[inicio : fin + 1]
        i = fin + 1


def texto(nodo):
    """Aplana bloques inline del AST a texto visible."""
    if isinstance(nodo, list):
        return "".join(texto(n) for n in nodo)
    if isinstance(nodo, dict):
        t = nodo.get("t")
        if t == "Str":
            return nodo.get("c", "")
        if t in ("Space", "SoftBreak", "LineBreak"):
            return " "
        if t in ("Code", "RawInline", "Math"):
            return ""
        c = nodo.get("c")
        return texto(c) if isinstance(c, (list, dict)) else ""
    return ""


def bloques_con_literal(nodo, hallazgos):
    if isinstance(nodo, list):
        for n in nodo:
            bloques_con_literal(n, hallazgos)
        return
    if not isinstance(nodo, dict):
        return
    if nodo.get("t") in ("Para", "Plain", "Header"):
        plano = texto(nodo.get("c", []))
        for m in LITERAL_SUBINDICE.finditer(plano):
            hallazgos.append(m.group(0))
    else:
        for v in nodo.values():
            if isinstance(v, (list, dict)):
                bloques_con_literal(v, hallazgos)


def linea_de(ruta, fragmento):
    with open(ruta, encoding="utf-8") as f:
        for n, linea in enumerate(f, 1):
            if fragmento in linea:
                return n
    # En la fuente puede estar escapado y en el AST no; al menos apunta al fichero.
    return 1


def main():
    ficheros = sorted(glob.glob("0*/*.qmd"))
    if not ficheros:
        print("::error::No se encontró ningún .qmd; el guardián no comprobaría nada")
        return 1

    errores = 0
    for ruta in ficheros:
        with open(ruta, encoding="utf-8") as f:
            for n, linea in enumerate(f, 1):
                for frag in grupos_sospechosos(linea):
                    print(
                        f"::error file={ruta},line={n}::Subíndice de velocidad "
                        f"con espacios sin escapar: «{frag}». Usa «{frag.replace(' ', r'\ ')}»."
                    )
                    errores += 1

        r = subprocess.run(
            ["quarto", "pandoc", ruta, "--from=markdown", "--to=json"],
            capture_output=True,
            text=True,
        )
        if r.returncode != 0:
            print(f"::error file={ruta}::No se pudo analizar: {r.stderr.strip()[:200]}")
            errores += 1
            continue

        hallazgos = []
        bloques_con_literal(json.loads(r.stdout).get("blocks", []), hallazgos)
        for frag in hallazgos:
            n = linea_de(ruta, frag)
            print(
                f"::error file={ruta},line={n}::Pandoc no ha convertido «{frag}» "
                "en subíndice; revisa la sintaxis Markdown."
            )
            errores += 1

    print(f"Analizados {len(ficheros)} .qmd; {errores} problemas de subíndices.")
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
