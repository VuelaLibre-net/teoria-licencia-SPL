"""Muestras de casting con VoxCPM2 fuera de VoiceStudio.

En una GPU de 6 GB, VoxCPM2 (2B) no cabe junto al proceso principal de
VoiceStudio. Este script lo carga solo, con VoiceStudio CERRADO, usando el
entorno que instaló el propio VoiceStudio:

    ~/.omnivoice/engines/voxcpm2/voxcpm2/.venv/bin/python \
        tools/audio/voxcpm2_muestras.py trabajo.json

`trabajo.json` lo escribe `casting.py sintetizar --motor voxcpm2 --externo`:
una lista de {texto, referencia, referencia_texto, destino}.
"""

import json
import sys
import time

import soundfile as sf
from voxcpm import VoxCPM


def main():
    trabajo = json.load(open(sys.argv[1], encoding="utf-8"))
    modelo = VoxCPM.from_pretrained("openbmb/VoxCPM2", load_denoiser=False, optimize=False)
    sr = getattr(modelo.tts_model, "sample_rate", 48000)
    for t in trabajo:
        t0 = time.time()
        # Clonado «definitivo» de VoxCPM2: la referencia con su transcripción
        # como prefijo (continuación) y además como referencia de timbre.
        wav = modelo.generate(text=t["texto"], prompt_wav_path=t["referencia"], prompt_text=t["referencia_texto"],
                              reference_wav_path=t["referencia"], cfg_value=2.0, inference_timesteps=10)
        sf.write(t["destino"], wav, sr)
        print(json.dumps({"destino": t["destino"], "segundos": round(time.time() - t0, 1),
                          "duracion": round(len(wav) / sr, 1)}), flush=True)


if __name__ == "__main__":
    main()
