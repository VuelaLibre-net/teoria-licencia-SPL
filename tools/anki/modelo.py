"""Tipos de nota, identificadores y conversión de markdown para los mazos Anki.

Vive aparte de `construir.py` porque `extraer.py` necesita las mismas reglas de
nomenclatura (los slugs de mazo y de tarjeta) y una segunda copia divergiría sin
dar error: el .apkg se generaría igual, sólo que reimportarlo duplicaría las
tarjetas en vez de actualizarlas.

⚠️ Los identificadores de Anki NO pueden ser aleatorios. genanki los pide como
enteros y su ejemplo usa `random.randrange`, pero un id nuevo en cada compilación
hace que Anki trate el tipo de nota (o el mazo) como otro distinto: al reimportar
el mazo, el alumno se encuentra "SPL Básica-2" y las tarjetas duplicadas, con su
historial de repaso perdido. Aquí se derivan de un hash del nombre, así que el
mismo nombre da siempre el mismo id y la reimportación actualiza en su sitio.

⚠️ Y por lo mismo, el GUID de cada nota se deriva de `libro/capítulo/id`, no de
su contenido. Con el GUID por defecto de genanki —hash de los campos— corregir
una errata en el reverso crearía una tarjeta nueva y dejaría la vieja huérfana.
"""

from __future__ import annotations

import hashlib
import html
import re

import genanki

# --- IDENTIFICADORES ESTABLES ---------------------------------------------
# Anki espera enteros de 32 bits para modelos y mazos. Se toman los 8 primeros
# dígitos hexadecimales del sha1 del nombre y se fuerza el bit 30 para que
# caigan en el mismo rango que usa genanki (2^30 .. 2^31).


def id_estable(nombre: str) -> int:
    return (int(hashlib.sha1(nombre.encode("utf-8")).hexdigest()[:8], 16) % (1 << 30)) + (1 << 30)


def guid(libro: str, capitulo: int, id_tarjeta: str) -> str:
    return genanki.guid_for(f"{libro}/cap{capitulo:02d}/{id_tarjeta}")


# --- MARKDOWN -> HTML ------------------------------------------------------
# Un subconjunto propio en vez de pandoc, a propósito: son ~800 tarjetas y una
# invocación de pandoc por campo tarda más que compilar el PDF. El subconjunto
# cubre lo que aparece de verdad en los campos —negrita, cursiva, código,
# viñetas y saltos de párrafo—; cualquier cosa fuera de él sale literal, que es
# visible al primer repaso y no rompe nada.
#
# ⚠️ El orden importa: primero se escapa el HTML (o un `<` del texto rompería la
# tarjeta), después se aplican los marcadores. Si se invierte, la etiqueta que
# genera la negrita se escaparía a sí misma y saldría `&lt;b&gt;` en pantalla.

_EN_LINEA = (
    (re.compile(r"\*\*(.+?)\*\*", re.S), r"<b>\1</b>"),
    (re.compile(r"(?<![\w*])\*([^*\n]+?)\*(?![\w*])"), r"<i>\1</i>"),
    (re.compile(r"`([^`\n]+?)`"), r"<code>\1</code>"),
    (re.compile(r"==(.+?)=="), r"<mark>\1</mark>"),
)


def markdown_a_html(texto: str) -> str:
    """Convierte el subconjunto de markdown que usan los campos de las tarjetas."""
    escapado = html.escape(texto.strip(), quote=False)
    for patron, reemplazo in _EN_LINEA:
        escapado = patron.sub(reemplazo, escapado)

    # Un salto de línea suelto es un espacio, como en markdown: los campos se
    # escriben con las líneas partidas para que el YAML se lea, y la tarjeta debe
    # reflowear al ancho de la pantalla. Unirlos con <br> congelaba los cortes del
    # fichero fuente dentro de la tarjeta.
    salida: list[str] = []
    for parrafo in re.split(r"\n\s*\n", escapado):
        lineas = [l.strip() for l in parrafo.strip().split("\n") if l.strip()]
        if not lineas:
            continue
        if all(l.startswith(("* ", "- ")) for l in lineas):
            salida.append("<ul>" + "".join(f"<li>{l[2:]}</li>" for l in lineas) + "</ul>")
        else:
            salida.append("<p>" + " ".join(lineas) + "</p>")
    return "".join(salida)


# --- TIPOS DE NOTA ---------------------------------------------------------
# Dos, no más: uno de pregunta-respuesta y uno de hueco. Es la misma taxonomía
# cerrada que sigue el resto de la colección con las admonitions; un tercer tipo
# "de definición" o "de cifra" sería una variante de estos dos con otro CSS y
# obligaría a mantener tres plantillas sincronizadas.
#
# El campo `Fuente` es obligatorio y va al pie del reverso: sin él, una tarjeta
# que el alumno recuerda mal no se puede contrastar con el manual, que es lo
# único que la hace corregible.

_CSS = """
.card {
  font-family: "Libertinus Serif", Georgia, serif;
  font-size: 20px;
  text-align: left;
  color: #1a1a1a;
  background-color: #fdfdfa;
  padding: 1.2em;
  line-height: 1.5;
}
.card.nightMode { color: #e8e8e8; background-color: #201f1c; }
b { color: #003366; }
.nightMode b { color: #8ab4e8; }
code { font-family: "DejaVu Sans Mono", monospace; font-size: 0.85em; }
mark { background: #ffe680; color: inherit; }
.nightMode mark { background: #6b5b00; color: #f5f5f5; }
ul { margin: 0.4em 0 0.4em 1.1em; padding: 0; }
li { margin-bottom: 0.3em; }
hr#answer { border: none; border-top: 1px solid #c8c8c0; margin: 1em 0; }
.fuente {
  font-family: "Libertinus Sans", "DejaVu Sans", sans-serif;
  font-size: 0.62em;
  color: #77776e;
  margin-top: 1.4em;
}
.nightMode .fuente { color: #8a8a80; }
.cloze { font-weight: bold; color: #003366; }
.nightMode .cloze { color: #8ab4e8; }
"""

BASICA = genanki.Model(
    id_estable("SPL Básica"),
    "SPL Básica",
    fields=[{"name": "Anverso"}, {"name": "Reverso"}, {"name": "Fuente"}],
    templates=[
        {
            "name": "Tarjeta",
            "qfmt": "{{Anverso}}",
            "afmt": '{{FrontSide}}<hr id="answer">{{Reverso}}'
            '<div class="fuente">{{Fuente}}</div>',
        }
    ],
    css=_CSS,
)

CLOZE = genanki.Model(
    id_estable("SPL Cloze"),
    "SPL Cloze",
    model_type=genanki.Model.CLOZE,
    fields=[{"name": "Texto"}, {"name": "Extra"}, {"name": "Fuente"}],
    templates=[
        {
            "name": "Hueco",
            "qfmt": "{{cloze:Texto}}",
            "afmt": "{{cloze:Texto}}{{#Extra}}<hr id=\"answer\">{{Extra}}{{/Extra}}"
            '<div class="fuente">{{Fuente}}</div>',
        }
    ],
    css=_CSS,
)

MODELOS = {"basica": BASICA, "cloze": CLOZE}
