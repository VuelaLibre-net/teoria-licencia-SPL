#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["ctranslate2>=4.0,<5", "faster-whisper>=1.0", "numpy"]
# ///
"""Transcribe audios cortos en GPU con faster-whisper: una línea por fichero.

    transcribir.py [--modelo medium] audio1.wav [audio2.wav …]

Lo usa casting.py para la transcripción de una referencia recortada. VoiceStudio
debe estar parado para dejar suficiente VRAM disponible.
"""

import argparse
import os
import subprocess
import sys

import ctranslate2
import numpy as np
from faster_whisper import WhisperModel

VRAM_MIN_MB = {"tiny": 2048, "base": 2048, "small": 3072, "medium": 4096}


def comprobar_gpu(modelo):
    """Exige una GPU CUDA sin procesos de cálculo y con VRAM para el modelo."""
    try:
        gpus = ctranslate2.get_cuda_device_count()
    except RuntimeError as e:
        raise SystemExit(f"transcribir: no se puede comprobar la GPU CUDA: {e}") from e
    if not gpus:
        raise SystemExit(
            "transcribir: no hay una GPU CUDA disponible; comprueba el controlador antes de verificar.")

    visible = os.environ.get("CUDA_VISIBLE_DEVICES", "0").split(",", 1)[0].strip() or "0"
    try:
        memoria = subprocess.run(
            ["nvidia-smi", "--id", visible, "--query-gpu=memory.free", "--format=csv,noheader,nounits"],
            capture_output=True, text=True, check=True).stdout.strip().splitlines()[0]
        procesos = subprocess.run(
            ["nvidia-smi", "--id", visible, "--query-compute-apps=pid,process_name,used_memory",
             "--format=csv,noheader,nounits"], capture_output=True, text=True, check=True).stdout.strip()
        libre_mb = int(memoria)
    except (FileNotFoundError, IndexError, ValueError, subprocess.CalledProcessError) as e:
        raise SystemExit(f"transcribir: no se puede consultar la VRAM con nvidia-smi: {e}") from e

    necesaria_mb = VRAM_MIN_MB.get(modelo, 6144)
    problemas = []
    if procesos:
        detalle = "; ".join(line.strip() for line in procesos.splitlines())
        problemas.append(f"procesos de cálculo activos ({detalle})")
    if libre_mb < necesaria_mb:
        problemas.append(f"solo {libre_mb} MiB libres; {modelo} necesita al menos {necesaria_mb} MiB")
    if problemas:
        raise SystemExit("transcribir: la GPU no está libre: " + "; ".join(problemas) +
                         ". Detén VoiceStudio y vuelve a intentarlo.")


def audio(ruta):
    """Mono a 16 kHz con el ffmpeg del sistema. faster-whisper decodifica con
    PyAV, y su llamada se rompe con PyAV 15+ (`metadata_errors`)."""
    r = subprocess.run(["ffmpeg", "-v", "error", "-i", ruta, "-ac", "1", "-ar", "16000", "-f", "f32le", "-"],
                       capture_output=True, check=True)
    return np.frombuffer(r.stdout, dtype=np.float32).copy()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--modelo", default="medium")
    ap.add_argument("--comprobar-gpu", action="store_true")
    ap.add_argument("audios", nargs="*")
    a = ap.parse_args()
    comprobar_gpu(a.modelo)
    if a.comprobar_gpu:
        return
    if not a.audios:
        ap.error("indica al menos un fichero de audio")
    modelo = WhisperModel(a.modelo, device="cuda", compute_type="float16")
    for ruta in a.audios:
        segmentos, _ = modelo.transcribe(
            audio(ruta), language="es", beam_size=5, vad_filter=True,
            condition_on_previous_text=False)
        texto = " ".join(s.text.strip() for s in segmentos).strip()
        print(texto, flush=True)
        print(f"  {ruta}: {texto[:70]}", file=sys.stderr)


if __name__ == "__main__":
    main()
