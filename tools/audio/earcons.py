#!/usr/bin/env python3
"""Earcons del audiolibro: tonos sintéticos, limpios y breves (< 1,5 s) que
avisan de un cambio de jerarquía en el temario.

    earcons.py [destino]     escribe capitulo.wav, seccion.wav y aviso.wav

Se generan aquí, con numpy y siempre iguales, en vez de versionar audio o
depender de samples de terceros. Cambiar este fichero cambia la huella del
audio (audio.py la incluye), así que rehace los audiolibros.

  capitulo   nota grave de piano eléctrico (sol 2), 1,2 s: el punto y aparte
             entre capítulos.
  seccion    la misma familia, más aguda, corta y suave (0,6 s): separador
             de secciones.
  aviso      doble pulso neutro y muy sutil, antes de una caja de Seguridad.

Cada uno lleva su propio silencio de cola, para que la voz no arranque
pegada al tono. El nivel lo ajusta después la masterización del montaje.
"""

import sys
import wave
from pathlib import Path

import numpy as np

SR = 44100


def _piano_electrico(f0, dur, decaimiento):
    """Timbre tipo Rhodes: fundamental con armónicos que se apagan antes que
    ella y un «tine» inarmónico muy breve en el ataque, que es lo que le da el
    golpe seco sin sonar a timbre de puerta."""
    t = np.arange(int(SR * dur)) / SR
    env = np.exp(-t / decaimiento) * (1 - np.exp(-t / 0.004))  # ataque de 4 ms
    x = (np.sin(2 * np.pi * f0 * t)
         + 0.35 * np.exp(-t / (decaimiento * 0.5)) * np.sin(2 * np.pi * 2 * f0 * t)
         + 0.12 * np.exp(-t / (decaimiento * 0.3)) * np.sin(2 * np.pi * 3 * f0 * t)
         + 0.08 * np.exp(-t / 0.03) * np.sin(2 * np.pi * 14.2 * f0 * t))
    x = x * env
    # Desvanecimiento final de 80 ms: sin chasquido al cortar.
    n = int(SR * 0.08)
    x[-n:] *= np.linspace(1, 0, n)
    return x


def _pulso(f, dur):
    t = np.arange(int(SR * dur)) / SR
    env = np.sin(np.pi * t / dur) ** 2  # ventana de Hann: sin ataque duro
    return env * (np.sin(2 * np.pi * f * t) + 0.15 * np.sin(2 * np.pi * 2 * f * t))


def _silencio(s):
    return np.zeros(int(SR * s))


def earcons():
    capitulo = np.concatenate([_piano_electrico(98.0, 1.2, 0.45), _silencio(0.5)])
    seccion = np.concatenate([_piano_electrico(196.0, 0.6, 0.18) * 0.6, _silencio(0.35)])
    aviso = np.concatenate([_pulso(523.25, 0.11), _silencio(0.09), _pulso(523.25, 0.11), _silencio(0.35)]) * 0.45
    return {"capitulo": capitulo, "seccion": seccion, "aviso": aviso}


def escribir(destino):
    destino = Path(destino)
    destino.mkdir(parents=True, exist_ok=True)
    rutas = {}
    todos = earcons()
    # Una sola ganancia para los tres (el capítulo, a -6 dBFS de pico): así se
    # conserva que la sección y el aviso suenen más suaves que el capítulo.
    ganancia = 10 ** (-6 / 20) / max(1e-9, np.max(np.abs(todos["capitulo"])))
    for nombre, x in todos.items():
        x = x * ganancia
        pcm = (x * 32767).astype("<i2").tobytes()
        ruta = destino / f"{nombre}.wav"
        with wave.open(str(ruta), "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(SR)
            w.writeframes(pcm)
        rutas[nombre] = ruta
    return rutas


if __name__ == "__main__":
    for nombre, ruta in escribir(sys.argv[1] if len(sys.argv) > 1 else "build/audio/earcons").items():
        print(f"✓ {ruta}")
