#!/usr/bin/env python3
"""Cliente mínimo de la API REST de VoiceStudio, sin dependencias.

`make` no puede hablar MCP, así que la cadena usa la API REST que hay detrás:
la misma que usan la aplicación y el servidor MCP. La dirección se cambia con
VOICESTUDIO_URL (por defecto http://127.0.0.1:3900).
"""

import json
import mimetypes
import os
import sys
import time
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


def subir_portada(ruta):
    return post_multipart("/audiobook/cover", {}, {"cover": ruta})["path"]


def descargar_modelo_voz():
    """Libera la VRAM del modelo de voz; se recarga solo en la siguiente síntesis."""
    try:
        with _pedir("POST", "/model/unload/tts", b"", {"Content-Type": "application/json"}):
            pass
    except ErrorVoiceStudio:
        pass  # si ya estaba descargado o no se puede, el reconocedor lo intentará igual


def transcribir(ruta, idioma="es"):
    return post_multipart("/transcribe", {"language": idioma}, {"audio": ruta}, timeout=1800)


def renderizar(peticion, progreso=None):
    """POST /longform/render y sigue el SSE hasta `done`. Devuelve el evento
    final. Cualquier capítulo fallido aborta: un audiolibro con un hueco en
    silencio es peor que no tenerlo."""
    cuerpo = json.dumps(peticion).encode()
    r = _pedir("POST", "/longform/render", cuerpo,
               {"Content-Type": "application/json", "Accept": "text/event-stream"}, timeout=3600)
    # Un `chapter_error` no corta el stream: el servidor sigue con las demás
    # pistas (y cortar la conexión cancelaría el trabajo). Se apuntan y se
    # falla al final, con las pistas buenas ya en la caché para el reintento.
    final, fallos = None, []
    with r:
        for linea in r:
            linea = linea.decode("utf-8", errors="replace").strip()
            if not linea.startswith("data:"):
                continue
            ev = json.loads(linea[5:].strip())
            tipo = ev.get("type")
            if progreso:
                progreso(ev)
            if tipo == "chapter_error":
                fallos.append(f"pista {ev.get('index', 0) + 1}: {ev.get('error')}")
            elif tipo == "error":
                raise ErrorVoiceStudio(f"VoiceStudio: {ev.get('error') or ev}")
            elif tipo == "stopped":
                raise ErrorVoiceStudio(f"VoiceStudio detuvo el render: {ev}")
            elif tipo == "done":
                final = ev
    if fallos or (final and final.get("failed_chapters")):
        raise ErrorVoiceStudio("VoiceStudio no pudo sintetizar:\n  " + "\n  ".join(fallos or [str(final)]))
    if not final:
        raise ErrorVoiceStudio("VoiceStudio cerró la conexión sin terminar el render.")
    return final


def descargar(salida_servidor, destino):
    destino = Path(destino)
    destino.parent.mkdir(parents=True, exist_ok=True)
    tmp = destino.with_suffix(destino.suffix + ".part")
    with _pedir("GET", "/audio/" + urllib.request.quote(salida_servidor), timeout=600) as r, tmp.open("wb") as f:
        while bloque := r.read(1 << 20):
            f.write(bloque)
    tmp.replace(destino)
    return destino


def progreso_consola(ev):
    t = ev.get("type")
    if t == "started":
        progreso_consola.t0 = time.time()
        print(f"   · {ev.get('chapters')} pistas en cola", file=sys.stderr)
    elif t == "chapter":
        dt = time.time() - getattr(progreso_consola, "t0", time.time())
        print(f"   · pista {ev.get('index', 0) + 1}/{ev.get('total')} ({dt:.0f} s)", file=sys.stderr)
    elif t in ("assembling", "mastering"):
        print(f"   · {'montando' if t == 'assembling' else 'masterizando'}…", file=sys.stderr)
    elif t == "routing_notice":
        print(f"   ! {ev.get('message') or ev}", file=sys.stderr)
