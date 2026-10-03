#!/usr/bin/env python3
"""Cliente mínimo de la API REST de VoiceStudio, sin dependencias.

`make` no puede hablar MCP, así que la cadena usa la API REST que hay detrás:
la misma que usan la aplicación y el servidor MCP. La dirección se cambia con
VOICESTUDIO_URL (por defecto http://127.0.0.1:3900).
"""

import json
import mimetypes
import os
import urllib.error
import urllib.request
import uuid
from pathlib import Path

BASE = os.environ.get("VOICESTUDIO_URL", "http://127.0.0.1:3900").rstrip("/")


class ErrorVoiceStudio(SystemExit):
    pass


def _pedir(metodo, ruta, cuerpo=None, cabeceras=None, timeout=60):
    req = urllib.request.Request(BASE + ruta, data=cuerpo, method=metodo, headers=cabeceras or {})
    try:
        return urllib.request.urlopen(req, timeout=timeout)
    except urllib.error.HTTPError as e:
        raise ErrorVoiceStudio(f"VoiceStudio {metodo} {ruta}: {e.code} {e.read().decode(errors='replace')[:500]}")
    except urllib.error.URLError as e:
        raise ErrorVoiceStudio(
            f"VoiceStudio no responde en {BASE} ({e.reason}). ¿Está abierta la aplicación?")


def get_json(ruta):
    with _pedir("GET", ruta) as r:
        return json.load(r)


def post_json(ruta, datos, timeout=60):
    with _pedir("POST", ruta, json.dumps(datos).encode(), {"Content-Type": "application/json"}, timeout) as r:
        return json.load(r)


def put_json(ruta, datos, timeout=60):
    with _pedir("PUT", ruta, json.dumps(datos).encode(), {"Content-Type": "application/json"}, timeout) as r:
        return json.load(r)


def _multipart(campos, ficheros=None):
    frontera = uuid.uuid4().hex
    partes = []
    for k, v in campos.items():
        if v is None:
            continue
        partes.append(f'--{frontera}\r\nContent-Disposition: form-data; name="{k}"\r\n\r\n{v}\r\n'.encode())
    for k, ruta in (ficheros or {}).items():
        tipo = mimetypes.guess_type(str(ruta))[0] or "application/octet-stream"
        partes.append(
            f'--{frontera}\r\nContent-Disposition: form-data; name="{k}"; filename="{Path(ruta).name}"\r\n'
            f"Content-Type: {tipo}\r\n\r\n".encode() + Path(ruta).read_bytes() + b"\r\n")
    partes.append(f"--{frontera}--\r\n".encode())
    return b"".join(partes), {"Content-Type": f"multipart/form-data; boundary={frontera}"}


def post_multipart(ruta, campos, ficheros=None, timeout=300):
    cuerpo, cab = _multipart(campos, ficheros)
    with _pedir("POST", ruta, cuerpo, cab, timeout) as r:
        return json.load(r)


# --- operaciones -----------------------------------------------------------

def salud():
    return get_json("/health")


def perfiles():
    """Nombre → id de los perfiles de voz. Un nombre repetido es un error:
    no habría forma de saber cuál de los dos quiere el reparto."""
    ids = {}
    for p in get_json("/profiles"):
        if p["name"] in ids:
            raise ErrorVoiceStudio(f"Hay dos perfiles llamados «{p['name']}» en VoiceStudio; borra uno.")
        ids[p["name"]] = p["id"]
    return ids


def disenar_voz(nombre, diseno, idioma="Spanish", semilla=42):
    """Crea un perfil diseñado, como la herramienta design_voice del MCP."""
    attrs = post_json("/design/describe", {"description": diseno})
    return post_multipart("/profiles", {
        "name": nombre, "kind": "design", "instruct": attrs.get("instruct", diseno),
        "language": idioma, "seed": semilla,
        "vd_states": json.dumps(attrs.get("attrs", {})),
    })


def generar(texto, perfil, destino, motor=None, idioma="es", num_step=None, guidance_scale=None,
            seed=None, speed=None):
    """Una locución por POST /generate (la vía principal de VoiceStudio, que
    reutiliza un solo proceso del motor). Escribe el WAV en `destino`."""
    campos = {"text": texto, "profile_id": perfil, "language": idioma, "wav_bits": "16"}
    for k, v in (("engine", motor), ("num_step", num_step), ("guidance_scale", guidance_scale),
                 ("seed", seed), ("speed", speed)):
        if v is not None:
            campos[k] = v
    cuerpo, cab = _multipart(campos)
    with _pedir("POST", "/generate", cuerpo, cab, timeout=900) as r:
        tipo = r.headers.get("Content-Type", "")
        datos = r.read()
    destino = Path(destino)
    destino.parent.mkdir(parents=True, exist_ok=True)
    tmp = destino.with_suffix(".part")
    if tipo.startswith("audio/"):
        tmp.write_bytes(datos)
    else:
        info = json.loads(datos)
        ident = info.get("id") or info.get("audio_id")
        with _pedir("GET", f"/audio/{ident}.wav", timeout=120) as r:
            tmp.write_bytes(r.read())
    tmp.replace(destino)
    return destino


def motor_activo():
    return get_json("/engines/tts")["active"]


def seleccionar_motor(motor):
    """Fija el motor TTS activo de VoiceStudio. La síntesis lo pasa en cada
    petición a /generate; esto sólo deja la interfaz de VoiceStudio en el
    mismo motor que el libro."""
    if motor_activo() != motor:
        post_json("/engines/select", {"family": "tts", "backend_id": motor})
        if motor_activo() != motor:
            raise ErrorVoiceStudio(f"VoiceStudio no acepta {motor} como motor activo")
