#!/usr/bin/env python3
"""Montaje final del audiolibro: fragmentos de voz + silencios + earcons + máster.

Cada fragmento del guion se sintetiza aparte (audio.py, POST /generate, con
caché propia) y aquí se montan:

  1. cada fragmento de voz, sin el silencio que el motor deje en sus bordes;
  2. tras él, exactamente el silencio que pide el guion (`pausa`, en ms);
  3. delante de los bloques marcados, su earcon (earcons.py);
  4. una pista del guion = un capítulo del fichero, que empieza en su earcon;
  5. máster en dos pasadas con loudnorm (ACX: -19 LUFS, -3 dBTP) y MP3 o M4B
     con capítulos, metadatos y portada.

No se usa el render por capítulos de VoiceStudio (/longform/render): con los
motores que corren en proceso aparte (CosyVoice3) crea una instancia —y un
proceso de 3,5 GB— por capítulo sin cerrar las anteriores, y a la segunda se
queda sin VRAM (VoiceStudio 0.5.6, audiobook.py::_build_synth).
"""

import json
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

import earcons as E

SR = 44100
LOUDNESS = {"acx": (-19.0, -3.0, 11.0), "podcast": (-16.0, -1.5, 11.0)}

# Recorte de los bordes de cada fragmento: el silencio que el motor deja al
# principio y al final no debe sumarse a la pausa del guion.
RECORTE = ("silenceremove=start_periods=1:start_threshold=-50dB:start_silence=0.05,"
           "areverse,silenceremove=start_periods=1:start_threshold=-50dB:start_silence=0.08,areverse")


def _ff(*args):
    subprocess.run(["ffmpeg", "-v", "error", "-y", *args], check=True)


def _duracion(ruta):
    r = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(ruta)],
                       capture_output=True, text=True, check=True)
    return float(r.stdout.strip())


def _escape(v):
    return re.sub(r"([=;#\\\n])", r"\\\1", str(v))


def _ffmetadata(capitulos_ms, meta):
    lineas = [";FFMETADATA1"]
    claves = {"title": "title", "author": "artist", "album": "album", "narrator": "composer",
              "year": "date", "genre": "genre", "description": "comment"}
    for k, tag in claves.items():
        if meta.get(k):
            lineas.append(f"{tag}={_escape(meta[k])}")
    for titulo, ini, fin in capitulos_ms:
        lineas += ["[CHAPTER]", "TIMEBASE=1/1000", f"START={ini}", f"END={fin}", f"title={_escape(titulo)}"]
    return "\n".join(lineas) + "\n"


def montar(pistas, destino, formato="mp3", bitrate="128k", meta=None, portada=None, loudness="acx"):
    """`pistas`: [{"titulo": str, "piezas": [("voz", ruta_wav) | ("silencio", ms) |
    ("earcon", nombre)]}]. Devuelve {"duracion_s", "capitulos"}."""
    destino = Path(destino)
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        tonos = E.escribir(tmp / "earcons")
        silencios = {}

        def silencio(ms):
            if ms not in silencios:
                ruta = tmp / f"sil{ms}.wav"
                _ff("-f", "lavfi", "-i", f"anullsrc=r={SR}:cl=mono", "-t", f"{ms / 1000:.3f}",
                    "-c:a", "pcm_s16le", str(ruta))
                silencios[ms] = (ruta, ms / 1000)
            return silencios[ms]

        lista, caps, t, n = [], [], 0.0, 0
        for pista in pistas:
            ini = t
            for tipo, valor in pista["piezas"]:
                if tipo == "earcon":
                    ruta, dur = tonos[valor], _duracion(tonos[valor])
                elif tipo == "silencio":
                    if valor <= 0:
                        continue
                    ruta, dur = silencio(int(valor))
                else:
                    ruta = tmp / f"v{n:05d}.wav"
                    n += 1
                    _ff("-i", str(valor), "-ac", "1", "-ar", str(SR), "-af", RECORTE, "-c:a", "pcm_s16le", str(ruta))
                    dur = _duracion(ruta)
                lista.append(ruta)
                t += dur
            caps.append((pista["titulo"], int(ini * 1000), int(t * 1000)))
        (tmp / "lista.txt").write_text("".join(f"file '{p}'\n" for p in lista))
        crudo = tmp / "crudo.wav"
        _ff("-f", "concat", "-safe", "0", "-i", str(tmp / "lista.txt"), "-c:a", "pcm_s16le", str(crudo))
        ffmeta = tmp / "meta.txt"
        ffmeta.write_text(_ffmetadata(caps, meta or {}), encoding="utf-8")

        # Máster en dos pasadas: medir y aplicar los valores medidos.
        filtro = ""
        if loudness in LOUDNESS:
            i, tp, lra = LOUDNESS[loudness]
            r = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", str(crudo), "-af",
                                f"loudnorm=I={i}:TP={tp}:LRA={lra}:print_format=json", "-f", "null", "-"],
                               capture_output=True, text=True, check=True)
            m = json.loads(r.stderr[r.stderr.rindex("{"):])
            filtro = (f"loudnorm=I={i}:TP={tp}:LRA={lra}:measured_I={m['input_i']}:measured_TP={m['input_tp']}:"
                      f"measured_LRA={m['input_lra']}:measured_thresh={m['input_thresh']}:"
                      f"offset={m['target_offset']}:linear=true,aresample={SR}")

        destino.parent.mkdir(parents=True, exist_ok=True)
        salida_tmp = tmp / f"salida.{'mp3' if formato == 'mp3' else 'm4b'}"
        cmd = ["-i", str(crudo), "-i", str(ffmeta)]
        con_portada = portada and Path(portada).exists() and formato != "mp3"
        if con_portada:
            cmd += ["-i", str(portada)]
        cmd += ["-map", "0:a", "-map_metadata", "1", "-map_chapters", "1"]
        if filtro:
            cmd += ["-af", filtro]
        if formato == "mp3":
            cmd += ["-c:a", "libmp3lame", "-b:a", bitrate, "-ar", str(SR), "-id3v2_version", "3"]
        else:
            cmd += ["-c:a", "aac", "-b:a", bitrate, "-ar", str(SR)]
            if con_portada:
                cmd += ["-map", "2:v", "-c:v", "copy", "-disposition:v:0", "attached_pic"]
            cmd += ["-movflags", "+faststart", "-f", "mp4"]
        _ff(*cmd, str(salida_tmp))
        # shutil.move y no Path.replace: /tmp suele estar en otro sistema de
        # ficheros que build/, y entre discos replace falla (EXDEV).
        shutil.move(str(salida_tmp), str(destino))
    return {"duracion_s": t, "capitulos": len(caps)}
