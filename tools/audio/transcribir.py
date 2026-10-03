#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["faster-whisper>=1.0", "numpy"]
# ///
"""Transcribe audios cortos en CPU con faster-whisper: una línea por fichero.

    transcribir.py [--modelo medium] audio1.wav [audio2.wav …]

Lo usa casting.py para la transcripción de una referencia recortada. Va en
CPU a propósito: la GPU de 6 GB la ocupa VoiceStudio, y su propio reconocedor
(large-v3) se cuelga cuando compite con el modelo de voz.
"""

import argparse
import subprocess
import sys

import numpy as np
from faster_whisper import WhisperModel


def audio(ruta):
    """Mono a 16 kHz con el ffmpeg del sistema. faster-whisper decodifica con
    PyAV, y su llamada se rompe con PyAV 15+ (`metadata_errors`)."""
    r = subprocess.run(["ffmpeg", "-v", "error", "-i", ruta, "-ac", "1", "-ar", "16000", "-f", "f32le", "-"],
                       capture_output=True, check=True)
    return np.frombuffer(r.stdout, dtype=np.float32).copy()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--modelo", default="medium")
    ap.add_argument("audios", nargs="+")
    a = ap.parse_args()
    modelo = WhisperModel(a.modelo, device="cpu", compute_type="int8")
    for ruta in a.audios:
        segmentos, _ = modelo.transcribe(audio(ruta), language="es", beam_size=5, vad_filter=False)
        texto = " ".join(s.text.strip() for s in segmentos).strip()
        print(texto, flush=True)
        print(f"  {ruta}: {texto[:70]}", file=sys.stderr)


if __name__ == "__main__":
    main()
