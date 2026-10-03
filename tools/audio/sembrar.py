#!/usr/bin/env python3
"""Lista las siglas de la colección que aún no están en pronunciacion.yml.

    sembrar.py [NN …]     (sin argumentos, los nueve libros)

Para cada sigla da su número de apariciones, la lectura que le pondría hoy la
heurística (palabra o deletreo) y el desarrollo del glosario si lo tiene. La
salida es YAML listo para pegar en `siglas:` tras revisarlo: la heurística
acierta casi siempre con las que se deletrean (VFR, ATC) y falla con las que
el uso ha convertido en palabra con su propio acento (NOTAM → «nótam»).
"""

import re
import sys
from collections import Counter
from pathlib import Path

import normalizar as N

RAIZ = Path(__file__).resolve().parents[2]


def main():
    pedidos = sys.argv[1:]
    libros = [d for d in sorted(RAIZ.glob("0[1-9]-*"))
              if not pedidos or any(d.name.startswith(p.zfill(2)) for p in pedidos)]
    _, siglas, palabras = N._datos()
    cuenta, glosa = Counter(), {}
    for libro in libros:
        for qmd in libro.glob("cap*.qmd"):
            texto = re.sub(r"\(imagenes/[^)]*\)|\{#[^}]*\}|`[^`]*`", "", qmd.read_text(encoding="utf-8"))
            cuenta.update(re.findall(r"\b[A-ZÑ]{2,}\b", texto))
        glosario = libro / "glosario.qmd"
        if glosario.exists():
            for s, d in re.findall(r"^\*\*([A-ZÑ]{2,}) \(([^)]*)\)\*\*", glosario.read_text(encoding="utf-8"), re.M):
                glosa.setdefault(s, d)
    faltan = [(s, n) for s, n in cuenta.most_common()
              if s not in siglas and s not in palabras and s != "CORREGIR"]
    print(f"# {len(faltan)} siglas sin entrada ({sum(n for _, n in faltan)} apariciones)")
    for s, n in faltan:
        nota = f"  # {n}×" + (f" — {glosa[s]}" if s in glosa else "")
        print(f"  {s}: {N.sigla(s)}{nota}")


if __name__ == "__main__":
    main()
