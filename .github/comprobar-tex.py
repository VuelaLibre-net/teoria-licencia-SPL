#!/usr/bin/env python3
r"""Caza fórmulas TeX que quedaron fuera de matemáticas.

El importador AsciiDoc→QMD no tradujo bien `stem:[...]`: los comandos TeX
quedaron como texto crudo (`\pm`, `\times`, `\sqrt{H}`) o se duplicaron
concatenados. Quarto compila, pero los escritores pierden símbolos o publican
basura como `\pm\pm`.

La comprobación consulta el AST de Pandoc. Sólo se consideran error los comandos
fuera de nodos `Math`; dentro de `$...$` o `$$...$$` son correctos.
"""
import glob
import json
import re
import subprocess
import sys


TEX_LITERAL = re.compile(
    r"\\(?:pm|alpha|times|cdot|cos|sin|sqrt|frac|qquad|mathrm)\b|[A-Za-z]+_\{[^}]+\}"
)


def texto_no_matematico(nodo):
    """Aplana texto visible, omitiendo matemáticas y código."""
    if isinstance(nodo, list):
        return "".join(texto_no_matematico(n) for n in nodo)
    if isinstance(nodo, dict):
        t = nodo.get("t")
        if t == "Math":
            return ""
        if t == "Str":
            return nodo.get("c", "")
        if t in ("Space", "SoftBreak", "LineBreak"):
            return " "
        if t == "RawInline":
            c = nodo.get("c") or []
            return c[1] if isinstance(c, list) and len(c) > 1 else ""
        if t in ("Code", "CodeBlock"):
            return ""
        c = nodo.get("c")
        return texto_no_matematico(c) if isinstance(c, (list, dict)) else ""
    return ""


def busca(nodo, hallazgos):
    if isinstance(nodo, list):
        for n in nodo:
            busca(n, hallazgos)
        return
    if not isinstance(nodo, dict):
        return
    if nodo.get("t") in ("Para", "Plain", "Header"):
        plano = texto_no_matematico(nodo.get("c", []))
        for m in TEX_LITERAL.finditer(plano):
            hallazgos.append(m.group(0))
        return
    if nodo.get("t") == "Math":
        return
    for v in nodo.values():
        if isinstance(v, (list, dict)):
            busca(v, hallazgos)


def linea_de(ruta, fragmento):
    with open(ruta, encoding="utf-8") as f:
        for n, linea in enumerate(f, 1):
            if fragmento in linea:
                return n
    return 1


def main():
    ficheros = sorted(glob.glob("0*/*.qmd"))
    if not ficheros:
        print("::error::No se encontró ningún .qmd; el guardián no comprobaría nada")
        return 1

    errores = 0
    for ruta in ficheros:
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
        busca(json.loads(r.stdout).get("blocks", []), hallazgos)
        for frag in hallazgos:
            n = linea_de(ruta, frag)
            print(
                f"::error file={ruta},line={n}::TeX fuera de matemáticas: «{frag}». "
                "Usa `$...$` o `$$...$$` para que llegue bien a PDF, EPUB y RAG."
            )
            errores += 1

    print(f"Analizados {len(ficheros)} .qmd; {errores} fragmentos TeX fuera de matemáticas.")
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
