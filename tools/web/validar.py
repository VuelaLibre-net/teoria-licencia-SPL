#!/usr/bin/env python3
"""Verifica los paquetes web antes de entregarlos al sitio Astro."""
from __future__ import annotations

import json
import re
import sys
import tarfile
from pathlib import Path
from urllib.parse import urlsplit


PICTURE_RE = re.compile(r"<picture\b[^>]*>(?P<content>.*?)</picture\s*>", re.IGNORECASE | re.DOTALL)
TAG_RE = re.compile(r"<(?P<name>img|source)\b[^>]*>", re.IGNORECASE)
ATTR_RE = re.compile(
    r"\b(?P<name>[\w:-]+)\s*=\s*(?:\"(?P<double>[^\"]*)\"|'(?P<single>[^']*)')",
    re.IGNORECASE,
)
RASTER_SUFFIXES = {".jpg", ".jpeg", ".png"}


def attribute(tag: str, name: str) -> str | None:
    for match in ATTR_RE.finditer(tag):
        if match.group("name").lower() == name:
            return match.group("double") if match.group("double") is not None else match.group("single")
    return None


def local_asset(url: str, archive: Path) -> str:
    parsed = urlsplit(url)
    path = Path(parsed.path)
    if parsed.scheme or parsed.netloc or path.is_absolute() or not parsed.path or ".." in path.parts:
        raise ValueError(f"{archive}: ruta de imagen insegura: {url}")
    return f"quarto/{path.as_posix()}"


def srcset_urls(srcset: str, archive: Path) -> list[str]:
    urls = []
    for entry in srcset.split(","):
        parts = entry.strip().split()
        if len(parts) != 2 or not parts[1].endswith("w") or not parts[1][:-1].isdigit():
            raise ValueError(f"{archive}: srcset inválido: {entry}")
        urls.append(parts[0])
    if not urls:
        raise ValueError(f"{archive}: srcset vacío")
    return urls


def validate_picture(picture: str, names: set[str], archive: Path) -> None:
    tags = list(TAG_RE.finditer(picture))
    sources = [tag.group(0) for tag in tags if tag.group("name").lower() == "source"]
    image_tags = [tag.group(0) for tag in tags if tag.group("name").lower() == "img"]
    if len(image_tags) != 1:
        raise ValueError(f"{archive}: picture sin una imagen fallback única")

    formats = {attribute(source, "type"): source for source in sources}
    for media_type in ("image/avif", "image/webp"):
        source = formats.get(media_type)
        if source is None:
            raise ValueError(f"{archive}: picture sin fuente {media_type}")
        if attribute(source, "sizes") != "(max-width: 768px) 100vw, 768px":
            raise ValueError(f"{archive}: sizes responsive inesperado")
        srcset = attribute(source, "srcset")
        if srcset is None:
            raise ValueError(f"{archive}: fuente {media_type} sin srcset")
        for url in srcset_urls(srcset, archive):
            if local_asset(url, archive) not in names:
                raise ValueError(f"{archive}: variante ausente: {url}")

    image = image_tags[0]
    src = attribute(image, "src")
    if src is None or local_asset(src, archive) not in names:
        raise ValueError(f"{archive}: fallback de imagen ausente")
    if attribute(image, "alt") is None:
        raise ValueError(f"{archive}: imagen responsive sin texto alternativo")
    if attribute(image, "width") is None or attribute(image, "height") is None:
        raise ValueError(f"{archive}: imagen responsive sin dimensiones")


def validate_responsive_images(content: str, names: set[str], archive: Path) -> None:
    pictures = list(PICTURE_RE.finditer(content))
    for picture in pictures:
        validate_picture(picture.group(0), names, archive)

    without_pictures = PICTURE_RE.sub("", content)
    for image in TAG_RE.finditer(without_pictures):
        if image.group("name").lower() != "img":
            continue
        src = attribute(image.group(0), "src")
        if src and Path(urlsplit(src).path).suffix.lower() in RASTER_SUFFIXES:
            raise ValueError(f"{archive}: imagen raster sin picture responsive: {src}")


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
            if manifest.get("schemaVersion") != 2:
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
                content = tar.extractfile(f"quarto/{html}").read().decode("utf-8")
                if 'role="doc-toc"' in content or 'id="TOC"' in content:
                    sys.exit(f"{archive}: {html} conserva el índice local de Quarto")
                try:
                    validate_responsive_images(content, names, archive)
                except ValueError as error:
                    sys.exit(str(error))
            required = {"licencia.qmd", "dedicatoria.qmd", "reconocimientos.qmd"}
            if not required.issubset({page.get("source") for page in pages}):
                sys.exit(f"{archive}: faltan preliminares web obligatorios")
            total += len(pages)
    if total != 141:
        sys.exit(f"Se esperaban 141 páginas web y hay {total}")
    print(f"9 paquetes web válidos con {total} páginas.")


if __name__ == "__main__":
    main()
