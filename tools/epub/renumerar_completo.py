#!/usr/bin/env python3
"""Aplica numeración por parte al texto ya resuelto del EPUB completo."""
from __future__ import annotations

import argparse
import os
import re
import tempfile
import zipfile
from pathlib import Path


LIMITES = (14, 18, 28, 35, 42, 50, 55, 69, 76)
ROMANOS = ("I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX")
REFERENCIA_RE = re.compile(r"\b(Figura|Tabla)(\s+)(\d+)\.(\d+)")
H1_RE = re.compile(r"<h1\b[^>]*>([IVX]+\.\d+)\s")
EJERCICIO_RE = re.compile(r"(<strong>Ejercicio\s+)\d+\.(\d+)(\s+—)")


def numero_compuesto(capitulo: int, orden: str) -> str:
    anterior = 0
    for parte, limite in enumerate(LIMITES):
        if capitulo <= limite:
            return f"{ROMANOS[parte]}.{capitulo - anterior}.{orden}"
        anterior = limite
    raise ValueError(f"Capítulo global fuera de rango: {capitulo}")


def renumerar_xhtml(texto: str) -> str:
    def referencia(match: re.Match[str]) -> str:
        return f"{match.group(1)}{match.group(2)}{numero_compuesto(int(match.group(3)), match.group(4))}"

    texto = REFERENCIA_RE.sub(referencia, texto)
    encabezado = H1_RE.search(texto)
    if encabezado:
        texto = EJERCICIO_RE.sub(
            lambda match: f"{match.group(1)}{encabezado.group(1)}.{match.group(2)}{match.group(3)}",
            texto,
        )
    return texto


def renumerar(epub: Path) -> None:
    with zipfile.ZipFile(epub) as original:
        entries = original.infolist()
        with tempfile.NamedTemporaryFile(dir=epub.parent, delete=False) as temporal:
            temporal_path = Path(temporal.name)
        try:
            with zipfile.ZipFile(temporal_path, "w") as salida:
                for entry in entries:
                    data = original.read(entry.filename)
                    if entry.filename.startswith("EPUB/text/") and entry.filename.endswith(".xhtml"):
                        data = renumerar_xhtml(data.decode("utf-8")).encode("utf-8")
                    salida.writestr(entry, data)
            os.replace(temporal_path, epub)
        finally:
            temporal_path.unlink(missing_ok=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("epub", type=Path)
    args = parser.parse_args()
    renumerar(args.epub)


if __name__ == "__main__":
    main()
