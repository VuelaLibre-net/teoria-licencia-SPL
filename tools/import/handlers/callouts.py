# Manejador de bloques de llamada (Callouts/Admonitions) para el conversor DocBook a Quarto Markdown

import re

# Mapeo de tipos de admonition de DocBook a callouts de Quarto
CALLOUT_MAPPING = {
    'note': 'note',
    'warning': 'warning',
    'caution': 'warning',
    'important': 'important',
    'tip': 'tip'
}

# Título editorial de cada tipo. Sustituye al que Quarto pone por defecto según
# el idioma ("Advertencia", "Importante", "Tip"), que no se corresponde con la
# categoría que usa el temario.
CALLOUT_TITLES = {
    'note': 'Airmanship',
    'warning': 'Seguridad',
    'caution': 'Seguridad',
    'important': 'Normativa',
    'tip': 'Regla de oro'
}

# El AsciiDoc de origen repite la categoría como primer párrafo del bloque, con
# su icono: "⚠ *SEGURIDAD*". Se reconoce para retirarla del cuerpo, porque esa
# información pasa al título del callout y de lo contrario saldría duplicada.
SOURCE_LABELS = {
    'note': ('AIRMANSHIP', 'AIRMANSHIP / BUENAS PRÁCTICAS'),
    'warning': ('SEGURIDAD',),
    'caution': ('SEGURIDAD',),
    'important': ('NORMATIVA',),
    'tip': ('REGLA DE ORO',)
}

# Icono inicial + etiqueta, con sufijo opcional tras ':' o '—'
# ("⚠ SEGURIDAD: FLUTTER" -> etiqueta 'SEGURIDAD', sufijo 'FLUTTER').
_LABEL_RE = re.compile(
    r'^[\W_]*(?P<label>[^:—]+?)\s*(?:(?P<sep>[:—])\s*(?P<suffix>.+?))?\s*$',
    re.DOTALL
)

def _strip_ns(tag):
    return tag.split('}', 1)[1] if tag.startswith('{') else tag

def _extract_title(node, tag):
    """Calcula el título del callout y localiza la línea-etiqueta a retirar.

    Devuelve (título, nodo_etiqueta). El nodo_etiqueta es None cuando el bloque
    no empieza por la etiqueta esperada: en ese caso no se retira nada, porque
    ese primer párrafo es contenido real.
    """
    base = CALLOUT_TITLES.get(tag, '')
    children = list(node)
    if not children:
        return base, None

    first = children[0]
    if _strip_ns(first.tag) not in ('simpara', 'para'):
        return base, None

    match = _LABEL_RE.match("".join(first.itertext()))
    if not match:
        return base, None

    label = re.sub(r'\s+', ' ', match.group('label') or '').strip().upper()
    if label not in SOURCE_LABELS.get(tag, ()):
        return base, None

    suffix = (match.group('suffix') or '').strip()
    if not suffix:
        return base, first

    # El sufijo distingue el bloque ("FLUTTER", "RADIOS 8,33 kHz") y se conserva
    # respetando el separador que traía el origen.
    separator = match.group('sep')
    title = f"{base}: {suffix}" if separator == ':' else f"{base} {separator} {suffix}"
    return title, first

def handle_callout(node, ctx, convert_node):
    """
    Traduce admonitions de DocBook (note, warning, caution, important, tip) a
    bloques de llamada de Quarto, con el título editorial que corresponda y sin
    la línea-etiqueta (icono + categoría) que arrastra el AsciiDoc de origen.
    """
    tag = _strip_ns(node.tag)
    callout_type = CALLOUT_MAPPING.get(tag, 'note')
    title, label_node = _extract_title(node, tag)

    # Procesar el contenido interior, omitiendo la línea-etiqueta
    content_parts = []
    for child in node:
        if child is label_node:
            continue
        content = convert_node(child, ctx)
        if content:
            content_parts.append(content)

    body = "".join(content_parts).strip()

    attrs = f".callout-{callout_type}"
    if title:
        # Unas comillas dobles cerrarían el atributo antes de tiempo.
        attrs += ' title="{}"'.format(title.replace('"', "'"))

    return f"\n::: {{{attrs}}}\n{body}\n:::\n"
