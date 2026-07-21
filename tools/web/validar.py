#!/usr/bin/env python3
"""Verifica los paquetes web antes de entregarlos al sitio Astro."""
from __future__ import annotations

import json
import sys
import tarfile
from pathlib import Path


def main() -> None:
    archives = sorted(Path("build/web").glob("*.web.tar.gz"))
    if len(archives) != 9:
        sys.exit(f"Se esperaban 9 paquetes web y hay {len(archives)}")
    total = 0
    for archive in archives:
        with tarfile.open(archive, "r:gz") as tar:
            names = {member.name for member in tar.getmembers() if member.isfile()}
            if "manifest.json" not in names:
                sys.exit(f"{archive}: falta manifest.json")
            manifest = json.load(tar.extractfile("manifest.json"))
            if manifest.get("schemaVersion") != 1:
                sys.exit(f"{archive}: schemaVersion incompatible")
            book = manifest.get("book", {})
            pages = manifest.get("pages", [])
            if not book.get("siteSlug") or not book.get("version"):
                sys.exit(f"{archive}: metadatos de libro incompletos")
            if len({page.get("slug") for page in pages}) != len(pages):
                sys.exit(f"{archive}: slugs de página duplicados")
            for page in pages:
                html = page.get("html")
                if not html or f"quarto/{html}" not in names:
                    sys.exit(f"{archive}: falta HTML para {page.get('source')}")
            required = {"licencia.qmd", "dedicatoria.qmd", "reconocimientos.qmd"}
            if not required.issubset({page.get("source") for page in pages}):
                sys.exit(f"{archive}: faltan preliminares web obligatorios")
            total += len(pages)
    if total != 140:
        sys.exit(f"Se esperaban 140 páginas web y hay {total}")
    print(f"9 paquetes web válidos con {total} páginas.")


if __name__ == "__main__":
    main()
