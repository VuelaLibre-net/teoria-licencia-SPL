#!/usr/bin/env python3
"""Arma el guion de un capítulo: qué se dice, con qué voz y con qué pausas.

    .qmd ─quarto pandoc + audio.lua─▶ bloques con rol ─reparto.yml + normalizar─▶ guion

El guion es una lista de «pistas» (los capítulos del fichero de audio, uno por
sección `##` del .qmd) con sus fragmentos. Se escribe en dos formas:

  * `capNN.json`, la que se manda a VoiceStudio;
  * `capNN.txt`, la que se lee para revisar: una línea por fragmento con la
    voz delante, el texto tal cual sonará y la pausa detrás.

Se deriva siempre del .qmd: las correcciones van al léxico (pronunciacion.yml),
a las reglas (reglas.yml) o al reparto, nunca al guion.
"""

import json
import re
import subprocess
from functools import lru_cache
from pathlib import Path

import yaml

from normalizar import normalizar, _entero

AQUI = Path(__file__).resolve().parent
FILTRO = AQUI / "audio.lua"


@lru_cache(maxsize=None)
def reparto():
    return yaml.safe_load((AQUI / "reparto.yml").read_text(encoding="utf-8"))


def config_libro(libro):
    return yaml.safe_load((Path(libro) / "_quarto.yml").read_text(encoding="utf-8"))


def ficheros_libro(libro):
    """Los .qmd que suenan, en el orden de _quarto.yml, con su número de
    capítulo (el mismo que numera figuras y tablas en el libro)."""
    cfg = config_libro(libro)["book"]
    salida, ncap = [], 0
    for f in cfg.get("chapters", []):
        nombre = Path(f).name
        if nombre.startswith("cap"):
            ncap += 1
            salida.append((f, str(ncap)))
        elif nombre == "introduccion.qmd":
            salida.append((f, ""))
    return salida


def _texto_qmd(ruta):
    texto = Path(ruta).read_text(encoding="utf-8")
    # De la introducción sólo suena el gancho propio del libro. La guía de
    # lectura que sigue a la marca explica la maqueta (colores, recuadros,
    # márgenes), que en audio no existe; es la misma poda que hace el RAG.
    if Path(ruta).name == "introduccion.qmd":
        texto = texto.split("<!-- GUÍA-DE-LECTURA", 1)[0]
    return texto


def bloques(ruta, etiqueta):
    """Lista de (rol, texto, atributos) que devuelve audio.lua."""
    r = subprocess.run(
        ["quarto", "pandoc", "--from=markdown", "--to=json",
         f"--lua-filter={FILTRO}", f"--metadata=etiqueta={etiqueta}"],
        input=_texto_qmd(ruta), capture_output=True, text=True, check=False,
    )
    if r.returncode != 0:
        raise SystemExit(f"guion: pandoc falló con {ruta}:\n{r.stderr}")
    doc = json.loads(r.stdout)
    salida = []
    for b in doc["blocks"]:
        attrs = dict(b["c"][0][2])
        contenido = b["c"][1]
        texto = contenido[0]["c"][0]["c"] if contenido else ""
        salida.append((attrs.pop("rol"), texto, attrs))
    return salida


def _rol_efectivo(rol, attrs):
    if rol == "seccion" and attrs.get("nivel", "2") != "2":
        return "subseccion"
    return rol


def _enfasis(texto, activo):
    """‹…› (la negrita del libro, ver audio.lua) → <strong>…</strong>, que
    CosyVoice3 dice con énfasis; o nada, si el papel no lo usa. Un énfasis
    que abarca la frase entera no aporta: se quita."""
    if not activo:
        texto = texto.replace("‹", "").replace("›", "")
        texto = re.sub(r",\s*([.;:!?])", r"\1", texto)
        texto = re.sub(r":\s*,\s*", ": ", texto)
        return re.sub(r"([.!?])\1+", r"\1", texto)
    t = re.sub(r"‹\s*([^‹›]*?)\s*›", lambda m: f"<strong>{m.group(1)}</strong>" if m.group(1) else "", texto)
    if re.fullmatch(r"<strong>[^<]*</strong>[.!?:;]?", t):
        t = re.sub(r"</?strong>", "", t)
    return t.replace("‹", "").replace("›", "")


def sin_etiquetas(texto):
    """El texto sin las etiquetas de control del motor (<strong>, [breath]):
    lo que de verdad se oye, para el WER y el guardián de residuos."""
    return re.sub(r"</?(?:strong|laughter)>|\[(?:breath|quick_breath|laughter|noise|cough|sigh|mn)\]", "", texto)


def _pista(titulo):
    return {"titulo": titulo, "fragmentos": []}


def _earcon(rol, attrs):
    """El earcon que va delante de un bloque, según `earcons:` de reparto.yml:
    por rol («seccion») o, para los rótulos, por su caja («caja-seguridad»)."""
    tabla = reparto().get("earcons") or {}
    if rol == "rotulo" and attrs.get("caja"):
        return tabla.get(f"caja-{attrs['caja']}")
    return tabla.get(rol)


def _pausa(rol, attrs, cfg):
    """Pausa tras un bloque. Las pedagógicas (`pausas:` de reparto.yml) mandan
    sobre la del rol: entre ítems de una lista, tras un procedimiento
    (lista numerada) y tras la solución de un ejercicio."""
    pausas = reparto().get("pausas") or {}
    p = cfg.get("pausa", 0)
    if attrs.get("item"):
        p = pausas.get("item_lista", p)
        if attrs.get("ultimo") and attrs["item"] != "-":
            p = pausas.get("fin_procedimiento", p)
    if rol == "fin-caja" and attrs.get("caja") == "ejercicio":
        p = pausas.get("fin_ejercicio", p)
    return p


def _anadir(pista, rol, texto, attrs=None):
    """Añade un fragmento (con su earcon delante, si le toca), o sólo su
    pausa si el rol no lleva texto."""
    attrs = attrs or {}
    cfg = reparto()["roles"][rol]
    frs = pista["fragmentos"]
    # La pausa previa va en el fragmento anterior, antes del earcon: el
    # silencio, luego el tono, luego la voz.
    if frs and cfg.get("pausa_antes") and not frs[-1].get("earcon"):
        frs[-1]["pausa"] = max(frs[-1]["pausa"], cfg["pausa_antes"])
    if "voz" not in cfg:
        if frs and not frs[-1].get("earcon"):
            frs[-1]["pausa"] = max(frs[-1]["pausa"], _pausa(rol, attrs, cfg))
        return
    dicho = (_con_etiquetas(texto, rol, f"[{pista['titulo']}]") if rol.startswith("podcast-")
             else normalizar(texto))
    if not dicho or dicho == ".":
        return
    dicho = _enfasis(dicho, cfg.get("enfasis", False))
    earcon = _earcon(rol, attrs)
    if earcon:
        frs.append({"earcon": earcon, "rol": "earcon", "texto": "", "pausa": 0})
    frs.append({
        "rol": rol,
        "voz": cfg["voz"],
        "velocidad": cfg.get("velocidad"),
        "texto": dicho,
        "pausa": _pausa(rol, attrs, cfg),
    })


def guion_fichero(ruta, etiqueta, literal=False):
    """Guion de un .qmd: lista de pistas, la primera con el título y la
    entradilla, y luego una por sección `##`. Si hay un guion de podcast
    para el fichero (`ruta_podcast`), se usa ése, salvo con `literal`."""
    if not literal and (podcast := ruta_podcast(ruta)):
        return guion_podcast(podcast)
    pistas = []
    actual = None
    for rol, texto, attrs in bloques(ruta, etiqueta):
        rol = _rol_efectivo(rol, attrs)
        if rol == "titulo-capitulo":
            titulo = texto
            if etiqueta:
                texto = f"Capítulo {_entero(int(etiqueta), apocope=False)}. {texto}"
            actual = _pista(titulo)
            pistas.append(actual)
        elif rol == "seccion":
            actual = _pista(texto)
            pistas.append(actual)
        elif actual is None:
            actual = _pista("")
            pistas.append(actual)
        _anadir(actual, rol, texto, attrs)
    # El último fragmento del fichero no necesita silencio detrás: lo pone el
    # reproductor o la pista siguiente.
    pistas = [p for p in pistas if p["fragmentos"]]
    for p in pistas:
        p["fragmentos"][-1]["pausa"] = max(p["fragmentos"][-1].get("pausa", 0), 1000)
    return pistas


def ruta_podcast(ruta):
    """El guion de podcast escrito a mano para un .qmd, si existe:
    tools/audio/podcast/<libro>/<stem>.yml. Es contenido editorial propio,
    no derivado: se edita, y el .qmd sigue siendo la fuente de los hechos."""
    ruta = Path(ruta)
    p = AQUI / "podcast" / ruta.resolve().parent.name / f"{ruta.stem}.yml"
    return p if p.exists() else None


ETIQUETA = re.compile(r"</?laughter>|\[(?:breath|quick_breath|laughter|noise|cough|sigh|mn|lipsmack)\]")


def _con_etiquetas(texto, rol, donde):
    """normalizar() convierte los corchetes en comas y rompería las etiquetas
    de CosyVoice3: se sustituyen por marcas de letras, se normaliza y se
    devuelven. Sólo valen las que `etiquetas:` de reparto.yml da al rol."""
    permitidas = (reparto().get("etiquetas") or {}).get(rol, [])
    guardadas = []

    def guardar(m):
        if m.group(0) not in permitidas:
            raise SystemExit(f"guion: {donde}: la etiqueta {m.group(0)} no vale para {rol} "
                             f"(permitidas: {' '.join(permitidas) or 'ninguna'}); ver reparto.yml")
        guardadas.append(m.group(0))
        return f" etq{'abcdefghijklmnopqrstuvwxyz'[len(guardadas) - 1]}etq "

    marcado = ETIQUETA.sub(guardar, texto)
    dicho = normalizar(marcado)
    for i, e in enumerate(guardadas):
        marca = f"etq{'abcdefghijklmnopqrstuvwxyz'[i]}etq"
        dicho = re.sub(rf"\s*[,.;:]?\s*{marca}\s*[,.;:]?\s*", f" {e} ", dicho, flags=re.IGNORECASE)
    dicho = re.sub(r"<laughter>\s+", "<laughter>", dicho)
    dicho = re.sub(r"\s+</laughter>", "</laughter>", dicho)
    return re.sub(r"\s+", " ", dicho).strip()


def guion_podcast(fichero):
    """Guion de un diálogo entre dos voces, de un YAML de `podcast/`:

        pistas:
          - titulo: Título de la sección (capítulo del MP3)
            turnos:
              - n: Lo que dice la Narradora.
              - l: Lo que dice el Locutor.   # `pausa: ms` tras el turno
                e: contento                  # emoción (`emociones:` de reparto.yml)
                v: 1.1                       # ritmo, 0,5–2,0 (se aplica en el montaje)
              - pausa: 2500                  # silencio suelto (pensar)

    Cada texto pasa por normalizar, como el del libro. La primera pista lleva
    el earcon de capítulo; las demás, el de sección."""
    datos = yaml.safe_load(Path(fichero).read_text(encoding="utf-8"))
    roles = {"n": "podcast-n", "l": "podcast-l"}
    tabla = reparto().get("earcons") or {}
    pistas = []
    for i, p in enumerate(datos["pistas"]):
        pista = _pista(p["titulo"])
        pistas.append(pista)
        earcon = tabla.get("titulo-capitulo" if i == 0 else "seccion")
        if earcon:
            pista["fragmentos"].append({"earcon": earcon, "rol": "earcon", "texto": "", "pausa": 0})
        for turno in p["turnos"]:
            frs = pista["fragmentos"]
            clave = next((k for k in roles if k in turno), None)
            if clave is None:
                if frs and "pausa" in turno:
                    frs[-1]["pausa"] = max(frs[-1].get("pausa", 0), turno["pausa"])
                continue
            n0 = len(frs)
            _anadir(pista, roles[clave], turno[clave])
            if len(frs) > n0:
                fr = frs[-1]
                if "pausa" in turno:
                    fr["pausa"] = turno["pausa"]
                if turno.get("e"):
                    emociones = reparto().get("emociones") or {}
                    if turno["e"] not in emociones:
                        raise SystemExit(f"guion: [{p['titulo']}] emoción «{turno['e']}» no está en "
                                         f"`emociones:` de reparto.yml ({', '.join(emociones)})")
                    fr["instruct"] = emociones[turno["e"]]
                if turno.get("v"):
                    if not 0.5 <= turno["v"] <= 2.0:
                        raise SystemExit(f"guion: [{p['titulo']}] v: {turno['v']} fuera de 0,5–2,0")
                    fr["ritmo"] = turno["v"]
    for p in pistas:
        p["fragmentos"][-1]["pausa"] = max(p["fragmentos"][-1].get("pausa", 0), 1000)
    return pistas


def atribuciones():
    """Las atribuciones que exigen las licencias de las voces (CC BY), sin
    repetir: dos papeles con la misma fuente se citan una vez."""
    vistas = []
    for voz in reparto()["voces"].values():
        t = voz.get("atribucion")
        if t and t not in vistas:
            vistas.append(t if t.endswith(".") else t + ".")
    return vistas


def creditos_apertura(libro, version, fecha):
    cfg = config_libro(libro)
    titulo = cfg["book"]["title"]
    autor = cfg["book"].get("author", "VuelaLibre.net")
    numero = int(Path(libro).name.split("-")[0])
    p = _pista("Créditos")
    for t in (
        f"{titulo}.",
        f"Tema {numero} de 9 del curso teórico para la Licencia de Piloto de Planeador.",
        f"Un manual de {autor}, versión {version}, actualizada el {fecha}.",
        "Se distribuye bajo licencia Creative Commons Atribución-CompartirIgual 4.0 Internacional.",
        "Este audiolibro está narrado con voces sintéticas, clonadas de grabaciones libres de "
        "hablantes peninsulares y generadas a partir del texto del libro. "
        "Las figuras y las tablas grandes se describen o se remiten al libro impreso.",
        *atribuciones(),
    ):
        _anadir(p, "creditos", t)
    p["fragmentos"][-1]["pausa"] = 1500
    return p


def creditos_cierre(libro):
    cfg = config_libro(libro)
    p = _pista("Fin")
    for t in (
        f"Aquí termina {cfg['book']['title']}.",
        "El libro completo, con sus figuras, tablas y ejercicios, está en vuelalibre punto net.",
    ):
        _anadir(p, "creditos", t)
    return p


def escribir(pistas, destino_json, destino_txt):
    destino_json.parent.mkdir(parents=True, exist_ok=True)
    destino_json.write_text(json.dumps(pistas, ensure_ascii=False, indent=1), encoding="utf-8")
    with destino_txt.open("w", encoding="utf-8") as f:
        for p in pistas:
            f.write(f"=== {p['titulo']}\n")
            for fr in p["fragmentos"]:
                if fr.get("earcon"):
                    f.write(f"♪ {fr['earcon']}\n")
                    continue
                v = f" ×{fr['velocidad']}" if fr.get("velocidad") else ""
                f.write(f"[{fr['voz'].removeprefix('SPL ')}{v}] {fr['texto']}  ‖{fr['pausa']}\n")
            f.write("\n")


def palabras(pistas):
    return sum(len(fr["texto"].split()) for p in pistas for fr in p["fragmentos"])


def residuos(pistas):
    """Lo que no debería llegar nunca al motor: cifras, marcas de Markdown,
    restos de TeX o de la nota CORREGIR. Lo usa el guardián de audio.py."""
    malos = []
    for p in pistas:
        for fr in p["fragmentos"]:
            texto = sin_etiquetas(fr["texto"])
            for m in re.finditer(r"[0-9*_\[\]{}\\#|<>$‹›]|CORREGIR", texto):
                malos.append((p["titulo"], texto[max(0, m.start() - 30):m.end() + 30]))
    return malos
