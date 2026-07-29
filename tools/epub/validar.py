#!/usr/bin/env python3
"""Verifica requisitos de imágenes WebP en EPUB generados por la colección."""
from __future__ import annotations

import argparse
import io
import re
import zipfile
from pathlib import Path
from xml.etree import ElementTree


MAX_WIDTH = 1200
RASTER_SUFFIXES = {".jpg", ".jpeg", ".png"}
IMAGE_REF_RE = re.compile(r"\b(?:src|href)=[\"'][^\"']+\.(?:jpe?g|png)[\"']", re.IGNORECASE)


def validate(epub: Path) -> int:
    from PIL import Image

    with zipfile.ZipFile(epub) as archive:
        entries = archive.infolist()
        if not entries or entries[0].filename != "mimetype" or entries[0].compress_type != zipfile.ZIP_STORED:
            raise ValueError(f"{epub}: mimetype debe ser primera entrada y no comprimirse")

        names = {entry.filename for entry in entries}
        originals = [
            name
            for name in names
            if name.startswith("EPUB/media/") and Path(name).suffix.lower() in RASTER_SUFFIXES
        ]
        if originals:
            raise ValueError(f"{epub}: imágenes raster originales aún presentes: {originals[:3]}")

        webps = sorted(
            name for name in names if name.startswith("EPUB/media/") and name.endswith(".webp")
        )
        if not webps:
            raise ValueError(f"{epub}: no contiene imágenes WebP")
        for name in webps:
            with Image.open(io.BytesIO(archive.read(name))) as image:
                if image.format != "WEBP":
                    raise ValueError(f"{epub}: {name} no es WebP")
                if image.width > MAX_WIDTH:
                    raise ValueError(f"{epub}: {name} tiene {image.width}px, máximo {MAX_WIDTH}px")

        opf = ElementTree.fromstring(archive.read("EPUB/content.opf"))
        namespace = {"opf": "http://www.idpf.org/2007/opf"}
        manifest = opf.find("opf:manifest", namespace)
        if manifest is None:
            raise ValueError(f"{epub}: OPF sin manifest")
        declared = {item.attrib.get("href"): item.attrib.get("media-type") for item in manifest}
        for name in webps:
            href = name.removeprefix("EPUB/")
            if declared.get(href) != "image/webp":
                raise ValueError(f"{epub}: OPF no declara {href} como image/webp")

        for name in names:
            if Path(name).suffix.lower() not in {".html", ".xhtml"}:
                continue
            if IMAGE_REF_RE.search(archive.read(name).decode("utf-8")):
                raise ValueError(f"{epub}: {name} aún referencia JPEG/PNG")
    return len(webps)


def main() -> None:
    parser = argparse.ArgumentParser(description="Valida imágenes WebP dentro de un EPUB.")
    parser.add_argument("epub", type=Path)
    args = parser.parse_args()
    count = validate(args.epub)
    print(f"  ✓ {args.epub.name}: {count} imágenes WebP válidas")


if __name__ == "__main__":
    main()
