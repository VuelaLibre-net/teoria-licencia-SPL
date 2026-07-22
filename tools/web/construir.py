#!/usr/bin/env python3
"""Construye el paquete HTML que consume vuelalibre.net para un libro SPL.

Quarto sigue siendo quien interpreta los .qmd y resuelve su semántica. Este
script sólo decide qué páginas se publican, escribe el manifiesto que las
describe y empaqueta la salida para que el sitio no tenga que conocer Quarto.
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path


EXCLUDED = {
    "index.qmd",
    "epigrafe.qmd",
    "colofon.qmd",
    "contracubierta.qmd",
}
PRELIMINAR = {"licencia.qmd", "dedicatoria.qmd", "reconocimientos.qmd"}


def read_book_config(config: Path) -> tuple[str, list[str]]:
    text = config.read_text(encoding="utf-8")
    title = re.search(r'^  title: *"?([^"\n]+)"?\s*$', text, re.M)
    if title is None:
        raise ValueError(f"{config}: falta book.title")

    section = re.search(r"^  chapters:\n(.*?)(?=^format:)", text, re.M | re.S)
    if section is None:
        raise ValueError(f"{config}: falta book.chapters")
    pages = re.findall(r"^[ \t]*- ([^\n]+\.qmd)\s*$", section.group(1), re.M)
    if not pages:
        raise ValueError(f"{config}: no hay .qmd en chapters/appendices")
    if len(pages) != len(set(pages)):
        raise ValueError(f"{config}: repite entradas de libro")
    return title.group(1).strip(), pages


def page_kind(source: str) -> str:
    if source in PRELIMINAR:
        return "frontmatter"
    if source == "introduccion.qmd":
        return "introduction"
    if source.startswith("cap"):
        return "chapter"
    if source.startswith("apendice"):
        return "appendix"
    return Path(source).stem


def page_slug(source: str) -> str:
    stem = Path(source).stem
    return re.sub(r"^cap\d\d-", "", stem)


def page_title(source: Path) -> str:
    for line in source.read_text(encoding="utf-8").splitlines():
        if line.startswith("# "):
            return re.sub(r"\s+\{[^}]+\}\s*$", "", line[2:]).strip()
    raise ValueError(f"{source}: falta H1")


def main() -> None:
    parser = argparse.ArgumentParser(description="Construye el paquete web de un libro SPL.")
    parser.add_argument("book", type=Path)
    parser.add_argument("version")
    parser.add_argument("edition_date", help="Fecha ISO de la edición")
    parser.add_argument("status")
    parser.add_argument("status_note")
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    book = args.book.resolve()
    config = book / "_quarto.yml"
    if not config.is_file():
        sys.exit(f"construir.py: no existe {config}")
    title, sources = read_book_config(config)
    published = [source for source in sources if source not in EXCLUDED]
    if not published:
        sys.exit(f"construir.py: {book.name} no aporta páginas publicables")

    with tempfile.TemporaryDirectory(prefix="manual-web-") as temporary:
        temporary_path = Path(temporary)
        quarto_output = temporary_path / "quarto"
        command = [
            "quarto",
            "render",
            str(book),
            "--to",
            "html",
            "--output-dir",
            str(quarto_output),
            "--metadata",
            f"fecha-actualizacion={args.edition_date}",
            "--metadata",
            f"version-quarto={subprocess.check_output(['quarto', '--version'], text=True).strip()}",
            "--metadata",
            f"estado={args.status}",
            "--metadata",
            f"estado-nota={args.status_note}",
            "--metadata",
            "toc=false",
        ]
        subprocess.run(command, check=True)

        pages = []
        for order, source in enumerate(published, start=1):
            html = Path(source).with_suffix(".html").as_posix()
            if not (quarto_output / html).is_file():
                sys.exit(f"construir.py: Quarto no generó {html}")
            pages.append(
                {
                    "source": source,
                    "html": html,
                    "slug": page_slug(source),
                    "title": page_title(book / source),
                    "kind": page_kind(source),
                    "order": order,
                }
            )

        number = int(book.name.split("-", 1)[0])
        manifest = {
            "schemaVersion": 1,
            "book": {
                "sourceSlug": book.name,
                "siteSlug": book.name.split("-", 1)[1],
                "number": number,
                "title": title,
                "version": args.version,
                "editionDate": args.edition_date,
                "status": args.status or "Completado",
                "statusNote": args.status_note,
            },
            "pages": pages,
        }
        (temporary_path / "manifest.json").write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )

        args.output.parent.mkdir(parents=True, exist_ok=True)
        with tarfile.open(args.output, "w:gz") as archive:
            archive.add(temporary_path / "manifest.json", arcname="manifest.json")
            archive.add(quarto_output, arcname="quarto")


if __name__ == "__main__":
    main()
