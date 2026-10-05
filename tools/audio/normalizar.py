#!/usr/bin/env python3
"""Verbaliza el texto de un bloque del guion: lo que el motor de voz lee.

El motor (OmniVoice en VoiceStudio) tiene su propia normalización, pero es
conservadora a propósito y no sabe nada de aviación: deja «FL100» tal cual,
lee «2018/1139» como pueda y deletrea o no las siglas según le caiga. Aquí se
hace TODO antes de mandarle el texto, para que el guion legible (`capNN.txt`)
sea exactamente lo que suena y una pronunciación se corrija en un solo sitio:
`pronunciacion.yml` (siglas y palabras) o `reglas.yml` (unidades y signos).

El orden de las pasadas importa: los códigos (normas, METAR, niveles de vuelo)
se resuelven antes que los números sueltos, porque una vez convertidos sus
dígitos ya no se reconocerían como código.
"""

import re
import sys
from functools import lru_cache
from pathlib import Path

import yaml
from num2words import num2words

AQUI = Path(__file__).resolve().parent


@lru_cache(maxsize=None)
def _datos():
    reglas = yaml.safe_load((AQUI / "reglas.yml").read_text(encoding="utf-8"))
    lexico = yaml.safe_load((AQUI / "pronunciacion.yml").read_text(encoding="utf-8")) or {}
    # YAML lee `NO: no` como un booleano: una entrada así desaparecería del
    # léxico sin avisar. Se exige que todo sea texto.
    for seccion in ("siglas", "palabras"):
        for k, v in (lexico.get(seccion) or {}).items():
            if not isinstance(k, str) or not isinstance(v, str):
                raise SystemExit(f"pronunciacion.yml: «{k}: {v}» en {seccion} no es texto; entrecomíllalo.")
    return reglas, lexico.get("siglas") or {}, lexico.get("palabras") or {}


# --- números -------------------------------------------------------------

def _entero(n, genero="m", apocope=True):
    """«21» → «veintiún» delante de masculino, «veintiuna» de femenino."""
    t = num2words(int(n), lang="es")
    if genero == "f":
        t = re.sub(r"ientos\b", "ientas", t)
        t = re.sub(r"\buno$", "una", t)
        t = re.sub(r"iuno$", "iuna", t)
    elif apocope:
        t = re.sub(r"\buno$", "un", t)
        t = re.sub(r"iuno$", "iún", t)
    return t


def _digitos(s):
    reglas, _, _ = _datos()
    return " ".join(reglas["digitos"][int(c)] for c in s if c.isdigit())


def _decimal(entera, fraccion, genero="m"):
    """«1013,25» → «mil trece coma veinticinco»; «0,05» → «cero coma cero cinco».

    Los ceros de cola se caen (121,500 MHz se dice «ciento veintiuno coma
    cinco»), y una fracción con cero inicial o de más de tres cifras se lee
    dígito a dígito, que es como se dice en voz alta.
    """
    fraccion = fraccion.rstrip("0")
    e = _entero(entera, genero, apocope=False)
    if not fraccion:
        return e
    if fraccion.startswith("0") or len(fraccion) > 3:
        f = _digitos(fraccion)
    else:
        f = _entero(fraccion, "m", apocope=False)
    return f"{e} coma {f}"


def _numero(texto, genero="m", apocope=True):
    """Un número escrito como en el libro: «10 000», «5.000», «3,5», «090»."""
    t = re.sub(r"[\s  .]", "", texto) if re.fullmatch(
        r"\d{1,3}(?:[\s  .]\d{3})+(?:,\d+)?", texto) else texto
    if "," in t:
        entera, fraccion = t.split(",", 1)
        return _decimal(entera, fraccion, genero)
    # Un cero a la izquierda es un rumbo o un código («090»): cifra a cifra.
    if len(t) > 1 and t.startswith("0"):
        return _digitos(t)
    return _entero(t, genero, apocope)


# Palabras tras un número que no son lo contado: «uno de ellos», «el 1 y el 2».
FUNCIONALES = {"de", "del", "y", "o", "u", "a", "al", "en", "por", "para", "con",
               "que", "se", "es", "son", "sin", "entre", "hasta", "desde", "como"}

NUM = r"\d{1,3}(?:[   .]\d{3})+(?:,\d+)?|\d+(?:,\d+)?"


# --- siglas --------------------------------------------------------------

VOCALES = set("AEIOUÁÉÍÓÚ")


def deletrear(sigla):
    reglas, _, _ = _datos()
    return " ".join(reglas["letras"].get(c, c.lower()) for c in sigla)


def _pronunciable(s):
    """Heurística para siglas que no están en el léxico: se lee como palabra
    si tiene 4+ letras y alterna vocales sin tres consonantes seguidas (EASA,
    AESA); si no, se deletrea (VFR, ATC). Lo que importa de verdad va en
    pronunciacion.yml: esto es sólo la red de seguridad."""
    if len(s) < 4 or not any(c in VOCALES for c in s):
        return False
    # Una palabra española no acaba en dos consonantes: «LEMD» se deletrea.
    if s[-1] not in VOCALES and s[-2] not in VOCALES:
        return False
    return not re.search(r"[^AEIOU]{3}", s)


def sigla(s):
    _, siglas, _ = _datos()
    if s in siglas:
        return siglas[s]
    if _pronunciable(s):
        return s.lower()
    return deletrear(s)


def _codigo(tok):
    """Un código alfanumérico («Q1019», «18002KT», «LER71C», «PROB30»):
    las letras como sigla, las cifras de dos en adelante dígito a dígito."""
    partes = re.findall(r"[A-ZÑ]+|\d+", tok)
    salida = []
    for p in partes:
        if p.isdigit():
            salida.append(_entero(p, apocope=False) if len(p) <= 2 and not p.startswith("0") else _digitos(p))
        else:
            salida.append(sigla(p))
    return " ".join(salida)


# --- pasadas -------------------------------------------------------------

def _pasada_normas(t):
    # «SERA.3210», «SAO.GEN.130», «SFCL.045», con apartados «(b)(2)» detrás.
    def norma(m):
        partes = m.group(1).split(".")
        dichas = []
        for p in partes:
            if p.isdigit():
                dichas.append(_numero(p, apocope=False))
            elif re.fullmatch(r"[A-Z]+\d+", p):
                dichas.append(_codigo(p))
            else:
                dichas.append(sigla(p))
        apartados = re.findall(r"\(([a-z0-9]{1,4})\)", m.group(2) or "")
        dicho = " punto ".join(dichas)
        for a in apartados:
            dicho += ", " + (_entero(a, apocope=False) if a.isdigit() else
                             ("letra " + deletrear(a.upper()) if len(a) == 1 else a))
        return dicho
    t = re.sub(r"\b((?:[A-Z]{2,}\d*\.)+(?:[A-Z]{2,}|\d+[a-z]?))((?:\([a-z0-9]{1,4}\))*)",
               norma, t)
    # Reglamentos y directivas: «(UE) 2018/1139», «2020/358».
    t = re.sub(r"\((UE|CE|CEE)\)", lambda m: sigla(m.group(1)), t)
    t = re.sub(r"\b(\d{2,4})/(\d{1,4})\b",
               lambda m: f"{_numero(m.group(1), apocope=False)} barra {_numero(m.group(2), apocope=False)}", t)
    return t


def _pasada_aviacion(t):
    # Niveles de vuelo: «FL100», «FL 095» → «nivel de vuelo uno cero cero».
    t = re.sub(r"\bFL ?(\d{2,3})\b", lambda m: "nivel de vuelo " + _digitos(m.group(1)), t)
    # Horas: «11:00 UTC», «14:30».
    def hora(m):
        h, mi = int(m.group(1)), int(m.group(2))
        dicho = _entero(h, "f")
        return dicho + (" horas" if mi == 0 else " y " + _entero(mi, "m", apocope=False))
    t = re.sub(r"\b(\d{1,2}):(\d{2})\b", hora, t)
    # Ordinales: «1.º», «2.ª».
    def ordinal(m):
        o = num2words(int(m.group(1)), lang="es", to="ordinal")
        # «1.º piloto» → «primer piloto», como «tercer».
        if m.group(2):
            o = re.sub(r"(prim|terc)ero$", r"\1er", o)
        return o + (m.group(2) or "")
    t = re.sub(r"\b(\d+)\.º(\s+(?=[a-záéíóú]))?", ordinal, t)
    t = re.sub(r"\b(\d+)\.ª", lambda m: re.sub(r"o$", "a", num2words(int(m.group(1)), lang="es", to="ordinal")), t)
    # Temperaturas y valores negativos: «−5 °C», «-2», «M02/M05» se queda en código.
    t = re.sub(r"(?<![\w)])[−–-](?=\d)", "menos ", t)
    # Numeración de figuras, tablas y apartados: «figura 1.2», «3.1.4».
    t = re.sub(r"\b\d+(?:\.\d{1,2})+\b(?!\d)",
               lambda m: " punto ".join(_entero(x, apocope=False) for x in m.group(0).split(".")), t)
    # Matrículas y códigos con guion: «EC-OJE», «CS-22».
    t = re.sub(r"\b([A-Z]{1,3})-([A-Z]{2,4})\b", lambda m: deletrear(m.group(1)) + ", " + deletrear(m.group(2)), t)
    t = re.sub(r"\b([A-Z]{1,5})-(\d{1,4})\b", lambda m: sigla(m.group(1)) + " " + _numero(m.group(2), apocope=False), t)
    # Pares de códigos con barra: «M02/M05» (temperatura y rocío del METAR).
    t = re.sub(r"\b([A-Z]+\d+)/([A-Z]+\d+)\b", lambda m: _codigo(m.group(1)) + " barra " + _codigo(m.group(2)), t)
    # Códigos alfanuméricos sueltos: letras y cifras pegadas.
    t = re.sub(r"\b(?=[A-Z0-9]*\d)(?=[A-Z0-9]*[A-Z])[A-Z0-9]{2,}\b", lambda m: _codigo(m.group(0)), t)
    return t


def _pasada_formulas(t):
    """Dice las sumas y divisiones de las fórmulas cortas del texto."""
    def suma_division(m):
        numerador = m.group(1).strip()
        denominador = m.group(2).strip()
        return f"suma de {numerador} entre suma de {denominador}"

    t = re.sub(r"Σ\s*([^/.,;:!?]+?)\s*/\s*Σ\s*([^.,;:!?]+)", suma_division, t)
    # `stringify` une la variable y su subíndice Markdown: T~rocío~ → Trocío.
    t = re.sub(r"\bT(ambiente|rocío)\b", r"T \1", t)
    return t.replace("Σ", "suma de")


def _pasada_unidades(t):
    reglas, _, _ = _datos()
    for u in reglas["unidades"]:
        simbolo = re.escape(u["simbolo"])
        fin = r"(?![\w/])" if u["simbolo"][-1].isalnum() else ""
        patron = rf"(?<![\w,.])({NUM})\s?{simbolo}{fin}"

        def unidad(m, u=u):
            n = m.group(1)
            valor = re.sub(r"[   .]", "", n)
            uno = valor in ("1", "1,0")
            dicho = _numero(n, u["genero"])
            return f"{dicho} {u['singular'] if uno else u['plural']}"
        t = re.sub(patron, unidad, t)
    return t


def _pasada_numeros(t):
    reglas, _, _ = _datos()
    femeninos = set(reglas["femeninos"])
    # Rangos: «1–2 octas», «3-5 minutos» → «de una a dos octas».
    def rango(m):
        sig = m.group(3)
        g = "f" if sig and sig.lower() in femeninos else "m"
        return f"de {_numero(m.group(1), g)} a {_numero(m.group(2), g)}" + (f" {sig}" if sig else "")
    t = re.sub(rf"(?<![\w,.])({NUM})(?:\s?–\s?|-)({NUM})(?![\w,])(?:\s(\w+))?", rango, t)
    # Restas con espacios en fórmulas: «16 - 9».
    t = re.sub(rf"(?<=\d) [-−] (?=\d)", " menos ", t)

    def numero(m):
        sig = m.group(2)
        if not sig:
            return _numero(m.group(1), apocope=False)
        g = "f" if sig.lower() in femeninos else "m"
        # «un piloto», «veintiún estados»; pero «uno de ellos», «el 1 y el 2».
        apocope = sig[0].islower() and sig.lower() not in FUNCIONALES
        return _numero(m.group(1), g, apocope) + " " + sig
    return re.sub(rf"(?<![\w,])({NUM})(?![\w])(?:\s(\w+))?", numero, t)


def _pasada_lexico(t):
    _, _, palabras = _datos()
    # Palabras y expresiones (sobre todo inglés): sin distinguir mayúsculas,
    # las más largas primero para que «Basic Regulation» gane a «Regulation».
    for p in sorted(palabras, key=len, reverse=True):
        t = re.sub(rf"(?<!\w){re.escape(p)}(?!\w)", palabras[p], t, flags=re.IGNORECASE)
    # Siglas: palabras en mayúsculas de dos letras o más.
    t = re.sub(r"\b[A-ZÑÁÉÍÓÚÜ]{2,}\b", lambda m: sigla(m.group(0)), t)
    # Letras sueltas en mayúscula: «zona P o R», «clase G», «la letra D». Las
    # vocales y la Y se quedan, porque son palabras («A FL145», «Y por
    # encima…»); una consonante sola nunca lo es. Sin esto el motor lee «P o
    # R» a la inglesa («pi o ar»).
    t = re.sub(r"(?<![\w.-])([B-DF-HJ-NP-TV-XZÑ])(?![\w'-]|\.\w)", lambda m: deletrear(m.group(1)), t)
    return t


def _pasada_signos(t):
    reglas, _, _ = _datos()
    for s, dicho in reglas["signos"].items():
        t = t.replace(s, dicho)
    # La barra entre palabras («AMC/GM», «y/o») se dice «o».
    t = re.sub(r"(?<=\w)\s?/\s?(?=\w)", " o ", t)
    t = t.replace("/", " ")
    return t


def _pasada_puntuacion(t):
    # Los paréntesis y las rayas son incisos: se oyen como pausas, con comas.
    t = re.sub(r"\s*[(\[]\s*", ", ", t)
    t = re.sub(r"\s*[)\]]\s*(?=[.,;:!?])", "", t)
    t = re.sub(r"\s*[)\]]\s*", ", ", t)
    t = re.sub(r"\s*[—–]\s*", ", ", t)
    t = re.sub(r"[“”«»\"‘’*_`#|]", "", t)
    # El guion entre palabras no suena: «Part-SFCL», «Skew-T».
    t = re.sub(r"(?<=\w)-(?=\w)", " ", t)
    # Un «=» al final de un código (el fin de mensaje del METAR) no se dice.
    t = re.sub(r"\s*igual a\s*(?=[.;]|$)", "", t)
    t = re.sub(r"'", "", t)
    # Comas que se apilan o quedan delante o detrás de otro signo.
    t = re.sub(r"([.;:!?])\s*,\s*", r"\1 ", t)
    t = re.sub(r"(,\s*)+([.;:!?])", r"\2", t)
    t = re.sub(r"(\s*,\s*)+", ", ", t)
    t = re.sub(r",\s*([.;:!?])", r"\1", t)
    t = re.sub(r"^\s*,\s*", "", t)
    t = re.sub(r"\s+", " ", t).strip()
    t = re.sub(r",$", ".", t)
    if t and t[-1] not in ".!?:;…":
        t += "."
    return t


def _pasada_direcciones(t):
    """Una URL leída entera es ruido: se dice sólo el sitio, «easa punto
    europa punto eu». La dirección completa está en el libro."""
    def sitio(host):
        host = re.sub(r"^www\.", "", host)
        return " punto ".join(host.split("."))
    t = re.sub(r"https?://([\w.-]+)[^\s,;)»”]*", lambda m: sitio(m.group(1)), t)
    t = re.sub(r"\b((?:[a-z0-9-]+\.)+(?:net|com|org|es|eu|int|gov|aero))\b(?:/[^\s,;)»”]*)?",
               lambda m: sitio(m.group(1)), t)
    # «x3» en fraseología: repetir tres veces.
    t = re.sub(r"(?<!\w)[x×](\d)\b", lambda m: _entero(m.group(1), "f") + " veces", t)
    return t


def normalizar(texto):
    t = texto.replace("\u00a0", " ").replace("\u202f", " ")
    t = _pasada_direcciones(t)
    t = _pasada_normas(t)
    t = _pasada_aviacion(t)
    t = _pasada_formulas(t)
    t = _pasada_unidades(t)
    t = _pasada_numeros(t)
    t = _pasada_lexico(t)
    t = _pasada_signos(t)
    t = _pasada_puntuacion(t)
    # Una sigla verbalizada puede dejar mayúsculas iniciales sueltas; no
    # molestan al motor, pero sí el doble espacio.
    t = re.sub(r"\s+", " ", t).strip()
    # La mayúscula inicial no cambia el sonido, pero el motor la usa como
    # pista de comienzo de frase; tras verbalizar, una sigla la pierde.
    return t[:1].upper() + t[1:]


if __name__ == "__main__":
    for linea in (sys.argv[1:] or sys.stdin):
        print(normalizar(linea.rstrip("\n")))
