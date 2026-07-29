"""Genera fuentes responsive para las imágenes raster de un paquete web Quarto."""
from __future__ import annotations

import html
import re
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlsplit


RESPONSIVE_WIDTHS = (480, 768, 1200)
RESPONSIVE_SIZES = "(max-width: 768px) 100vw, 768px"
RASTER_SUFFIXES = {".jpg", ".jpeg", ".png"}
IMG_RE = re.compile(r"<img\b[^>]*>", re.IGNORECASE)
ATTR_RE = re.compile(
    r"\b(?P<name>[\w:-]+)\s*=\s*(?:\"(?P<double>[^\"]*)\"|'(?P<single>[^']*)')",
    re.IGNORECASE,
)


@dataclass(frozen=True)
class ImageStats:
    images: int = 0
    alt_added: int = 0
    dimensions_added: int = 0

    def __add__(self, other: "ImageStats") -> "ImageStats":
        return ImageStats(
            self.images + other.images,
            self.alt_added + other.alt_added,
            self.dimensions_added + other.dimensions_added,
        )


def _attribute(tag: str, name: str) -> str | None:
    for match in ATTR_RE.finditer(tag):
        if match.group("name").lower() == name:
            return match.group("double") if match.group("double") is not None else match.group("single")
    return None


def _set_attribute(tag: str, name: str, value: str) -> str:
    escaped = html.escape(value, quote=True)
    pattern = re.compile(
        rf"\b{re.escape(name)}\s*=\s*(?:\"[^\"]*\"|'[^']*')", re.IGNORECASE
    )
    if pattern.search(tag):
        return pattern.sub(f'{name}="{escaped}"', tag, count=1)
    return tag.replace("<img", f'<img {name}="{escaped}"', 1)


def _local_path(src: str) -> Path | None:
    parsed = urlsplit(src)
    if parsed.scheme or parsed.netloc or parsed.path.startswith("/"):
        return None
    path = Path(parsed.path)
    if not parsed.path or ".." in path.parts:
        raise ValueError(f"ruta de imagen insegura: {src}")
    return path


def _fallback_alt(path: Path) -> str:
    return f"Gráfico: {re.sub(r'[-_]+', ' ', path.stem)}"


def _variants(path: Path, source_dir: Path) -> tuple[int, int, dict[str, str]]:
    """Escribe AVIF y WebP sin ampliar la fuente y devuelve sus srcset."""
    from PIL import Image, ImageOps

    source_path = source_dir / path
    if not source_path.is_file():
        raise ValueError(f"no existe el recurso de imagen {source_path}")

    with Image.open(source_path) as source:
        source = ImageOps.exif_transpose(source)
        original_width, original_height = source.size
        widths = sorted({width for width in RESPONSIVE_WIDTHS if width < original_width} | {original_width})
        srcsets: dict[str, list[str]] = {"avif": [], "webp": []}

        for width in widths:
            height = round(original_height * width / original_width)
            resized = (
                source
                if width == original_width
                else source.resize((width, height), Image.Resampling.LANCZOS)
            )
            for image_format in srcsets:
                variant = path.with_name(f"{path.stem}-{width}w.{image_format}")
                output = source_dir / variant
                output.parent.mkdir(parents=True, exist_ok=True)
                resized.save(output, format=image_format.upper(), quality=82)
                srcsets[image_format].append(f"{variant.as_posix()} {width}w")

    return original_width, original_height, {
        image_format: ", ".join(variants) for image_format, variants in srcsets.items()
    }


def _transform_image(tag: str, source_dir: Path) -> tuple[str, ImageStats]:
    src = _attribute(tag, "src")
    if src is None:
        return tag, ImageStats()
    path = _local_path(src)
    if path is None or path.suffix.lower() not in RASTER_SUFFIXES:
        return tag, ImageStats()

    width, height, srcsets = _variants(path, source_dir)
    alt_added = 0
    dimensions_added = 0
    if _attribute(tag, "alt") is None:
        tag = _set_attribute(tag, "alt", _fallback_alt(path))
        alt_added = 1
    if _attribute(tag, "width") is None:
        tag = _set_attribute(tag, "width", str(width))
        dimensions_added += 1
    if _attribute(tag, "height") is None:
        tag = _set_attribute(tag, "height", str(height))
        dimensions_added += 1

    return (
        "<picture>"
        f'<source type="image/avif" srcset="{srcsets["avif"]}" sizes="{RESPONSIVE_SIZES}">'
        f'<source type="image/webp" srcset="{srcsets["webp"]}" sizes="{RESPONSIVE_SIZES}">'
        f"{tag}"
        "</picture>",
        ImageStats(images=1, alt_added=alt_added, dimensions_added=dimensions_added),
    )


def optimize_html_images(html_dir: Path) -> ImageStats:
    """Sustituye cada imagen raster local por un ``picture`` responsive."""
    total = ImageStats()
    for html_path in sorted(html_dir.glob("*.html")):
        content = html_path.read_text(encoding="utf-8")
        stats = ImageStats()

        def replace(match: re.Match[str]) -> str:
            nonlocal stats
            transformed, image_stats = _transform_image(match.group(0), html_dir)
            stats += image_stats
            return transformed

        transformed = IMG_RE.sub(replace, content)
        if transformed != content:
            html_path.write_text(transformed, encoding="utf-8")
        total += stats
    return total
