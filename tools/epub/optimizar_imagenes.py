#!/usr/bin/env python3
"""Convierte recursos raster de EPUB a WebP sin tocar PDF ni fuentes Quarto."""
from __future__ import annotations

import argparse
import io
import os
import re
import tempfile
import zipfile
from copy import copy
from dataclasses import dataclass
from pathlib import Path


MAX_WIDTH = 1200
LOSSY_QUALITY = 82
RASTER_SUFFIXES = {".jpg", ".jpeg", ".png"}
TEXT_SUFFIXES = {".css", ".html", ".ncx", ".opf", ".xhtml"}
ITEM_RE = re.compile(r"<item\b[^>]*>", re.IGNORECASE)
ATTR_RE = re.compile(
    r"\b(?P<name>[\w:-]+)\s*=\s*(?:\"(?P<double>[^\"]*)\"|'(?P<single>[^']*)')",
    re.IGNORECASE,
)
MEDIA_TYPE_RE = re.compile(
    r"(\bmedia-type\s*=\s*[\"'])image/(?:jpeg|png)([\"'])", re.IGNORECASE
)


@dataclass(frozen=True)
class Stats:
    images: int
    resized: int
    source_bytes: int
    webp_bytes: int


def attribute(tag: str, name: str) -> str | None:
    for match in ATTR_RE.finditer(tag):
        if match.group("name").lower() == name:
            return match.group("double") if match.group("double") is not None else match.group("single")
    return None


def webp_image(source_bytes: bytes, source_name: str) -> tuple[bytes, bool]:
    from PIL import Image, ImageOps

    with Image.open(io.BytesIO(source_bytes)) as source:
        image = ImageOps.exif_transpose(source)
        resized = image.width > MAX_WIDTH
        if resized:
            image = image.resize(
                (MAX_WIDTH, round(image.height * MAX_WIDTH / image.width)), Image.Resampling.LANCZOS
            )

        output = io.BytesIO()
        if Path(source_name).suffix.lower() == ".png":
            image.save(output, format="WEBP", lossless=True, method=6)
        else:
            image.convert("RGB").save(
                output, format="WEBP", quality=LOSSY_QUALITY, method=6
            )
    return output.getvalue(), resized


def rewrite_opf_media_types(content: str, webp_refs: set[str]) -> str:
    def rewrite_item(match: re.Match[str]) -> str:
        item = match.group(0)
        if attribute(item, "href") not in webp_refs:
            return item
        rewritten, count = MEDIA_TYPE_RE.subn(r"\1image/webp\2", item, count=1)
        if count != 1:
            raise ValueError(f"entrada OPF WebP sin media-type JPEG/PNG: {item}")
        return rewritten

    return ITEM_RE.sub(rewrite_item, content)


def rewrite_text(content: bytes, references: dict[str, str], is_opf: bool) -> bytes:
    text = content.decode("utf-8")
    for old, new in references.items():
        text = text.replace(old, new)
    if is_opf:
        text = rewrite_opf_media_types(text, set(references.values()))
    return text.encode("utf-8")


def optimize(epub: Path) -> Stats:
    if not epub.is_file():
        raise ValueError(f"no existe EPUB: {epub}")

    with zipfile.ZipFile(epub) as source:
        entries = source.infolist()
        images = [
            entry
            for entry in entries
            if entry.filename.startswith("EPUB/media/")
            and Path(entry.filename).suffix.lower() in RASTER_SUFFIXES
        ]
        if not images:
            raise ValueError(f"{epub}: no contiene imágenes raster EPUB")

        converted: dict[str, bytes] = {}
        references: dict[str, str] = {}
        resized = 0
        source_bytes = 0
        for entry in images:
            raw = source.read(entry)
            encoded, did_resize = webp_image(raw, entry.filename)
            target = str(Path(entry.filename).with_suffix(".webp"))
            if target in converted:
                raise ValueError(f"{epub}: nombres de imágenes WebP duplicados: {target}")
            converted[target] = encoded
            references[entry.filename.removeprefix("EPUB/")] = target.removeprefix("EPUB/")
            source_bytes += len(raw)
            resized += int(did_resize)

        with tempfile.NamedTemporaryFile(
            prefix=f".{epub.stem}-", suffix=".epub", dir=epub.parent, delete=False
        ) as temporary:
            output_path = Path(temporary.name)
        try:
            with zipfile.ZipFile(output_path, "w") as output:
                output.comment = source.comment
                image_names = {image.filename for image in images}
                for entry in entries:
                    if entry.filename in image_names:
                        target = str(Path(entry.filename).with_suffix(".webp"))
                        target_entry = copy(entry)
                        target_entry.filename = target
                        output.writestr(target_entry, converted[target])
                        continue

                    data = source.read(entry)
                    suffix = Path(entry.filename).suffix.lower()
                    if suffix in TEXT_SUFFIXES:
                        data = rewrite_text(data, references, suffix == ".opf")
                    target_entry = copy(entry)
                    if entry.filename == "mimetype":
                        target_entry.compress_type = zipfile.ZIP_STORED
                    output.writestr(target_entry, data)
            os.replace(output_path, epub)
        except Exception:
            output_path.unlink(missing_ok=True)
            raise

    return Stats(
        images=len(images),
        resized=resized,
        source_bytes=source_bytes,
        webp_bytes=sum(len(data) for data in converted.values()),
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Optimiza imágenes raster de un EPUB a WebP.")
    parser.add_argument("epub", type=Path)
    args = parser.parse_args()
    stats = optimize(args.epub)
    saved = 100 * (1 - stats.webp_bytes / stats.source_bytes)
    print(
        f"  🖼 {args.epub.name}: {stats.images} WebP, {stats.resized} redimensionadas, "
        f"{stats.source_bytes / 1024 / 1024:.1f} MiB → {stats.webp_bytes / 1024 / 1024:.1f} MiB "
        f"({saved:.0f}% menos)"
    )


if __name__ == "__main__":
    main()
