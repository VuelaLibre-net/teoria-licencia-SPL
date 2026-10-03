#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["huggingface_hub>=1.0", "pyarrow>=15"]
# ///
"""Baja clips de lectores concretos de Multilingual LibriSpeech (español) sin
descargar el corpus entero (30 ficheros de ~480 MB).

    mls.py indice                      qué lectores hay y cuánto audio tiene cada uno
    mls.py bajar <destino> <id> [--clips N]

Lee los parquet de facebook/multilingual_librispeech a través de HfFileSystem
(la sesión de `hf auth login`). Cada fichero trae, por grupo de filas, el
mínimo y el máximo de `speaker_id`: con los metadatos —unos KB— se sabe qué
grupos contienen a un lector, y sólo ésos se leen. El índice se guarda en
`<destino>/../indice.json` para no volver a recorrer los 30 ficheros.

Lo usa casting.py preparar-mls; corre con `uv run` y sus dependencias van
declaradas arriba, para no ensuciar el Python del sistema con pyarrow.
"""

import argparse
import json
import sys
from pathlib import Path

import pyarrow.parquet as pq
from huggingface_hub import HfFileSystem

REPO = "datasets/facebook/multilingual_librispeech/spanish"


def ficheros(fs):
    return sorted(p for p in fs.ls(REPO, detail=False) if "/train-" in p and p.endswith(".parquet"))


def indice(fs, cache):
    """{lector: [[fichero, grupo, filas, segundos], …]} a partir de metadatos."""
    if cache.exists():
        return json.loads(cache.read_text())
    salida = {}
    for p in ficheros(fs):
        with fs.open(p, block_size=1 << 20) as f:
            meta = pq.ParquetFile(f).metadata
            cols = {meta.schema.column(i).path: i for i in range(meta.num_columns)}
            for g in range(meta.num_row_groups):
                rg = meta.row_group(g)
                st = rg.column(cols["speaker_id"]).statistics
                if not (st and st.has_min_max):
                    continue
                durst = rg.column(cols["audio_duration"]).statistics
                media = (durst.min + durst.max) / 2 if durst and durst.has_min_max else 15
                # Un grupo con dos lectores (frontera entre ambos) se apunta a
                # los dos; al leer se filtra fila a fila.
                for lector in {st.min, st.max}:
                    salida.setdefault(str(lector), []).append([p, g, rg.num_rows, round(rg.num_rows * media)])
        print(f"  {Path(p).name}", file=sys.stderr)
    cache.parent.mkdir(parents=True, exist_ok=True)
    cache.write_text(json.dumps(salida))
    return salida


def bajar(fs, idx, destino, lector, n):
    destino.mkdir(parents=True, exist_ok=True)
    hechos = 0
    origen = ""
    for p, g, _, _ in idx.get(lector, []):
        with fs.open(p, block_size=1 << 20) as f:
            t = pq.ParquetFile(f).read_row_group(
                g, columns=["audio", "original_path", "transcript", "speaker_id", "file"]).to_pylist()
        for fila in t:
            if fila["speaker_id"] != lector:
                continue
            audio = destino / fila["file"]
            if not audio.exists():
                audio.write_bytes(fila["audio"]["bytes"])
            audio.with_suffix(".txt").write_text(fila["transcript"], encoding="utf-8")
            origen = origen or fila["original_path"]
            hechos += 1
            if hechos >= n:
                return hechos, origen
    return hechos, origen


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="orden", required=True)
    s = sub.add_parser("indice")
    s.add_argument("cache", type=Path)
    s = sub.add_parser("bajar")
    s.add_argument("destino", type=Path, help="carpeta donde crear mls-<id>/")
    s.add_argument("lectores", nargs="+")
    s.add_argument("--clips", type=int, default=30)
    a = ap.parse_args()
    fs = HfFileSystem()
    if a.orden == "indice":
        idx = indice(fs, a.cache)
        for lector, grupos in sorted(idx.items(), key=lambda kv: -sum(g[3] for g in kv[1])):
            print(f"{lector}\t{sum(g[3] for g in grupos) / 3600:.1f} h")
        return
    idx = indice(fs, a.destino / "indice.json")
    resultado = {}
    for lector in a.lectores:
        n, origen = bajar(fs, idx, a.destino / f"mls-{lector}", lector, a.clips)
        resultado[lector] = {"clips": n, "origen": origen}
        print(f"  mls-{lector}: {n} clips", file=sys.stderr)
    print(json.dumps(resultado))


if __name__ == "__main__":
    main()
