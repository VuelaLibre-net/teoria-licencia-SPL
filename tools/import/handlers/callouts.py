# Manejador de bloques de llamada (Callouts/Admonitions) para el conversor DocBook a Quarto Markdown

def handle_callout(node, ctx, convert_node):
    """
    Traduce admonitions de DocBook (note, warning, caution, important) a bloques de llamada de Quarto.
    """
    tag = node.tag.split('}', 1)[1] if node.tag.startswith('{') else node.tag
    
    # Mapeo de tipos de admonition a Quarto callouts
    callout_mapping = {
        'note': 'note',
        'warning': 'warning',
        'caution': 'warning',
        'important': 'important',
        'tip': 'tip'
    }
    
    callout_type = callout_mapping.get(tag, 'note')
    
    # Procesar todo el contenido interior del bloque
    content_parts = []
    for child in node:
        content = convert_node(child, ctx)
        if content:
            content_parts.append(content)
            
    body = "".join(content_parts).strip()
    
    # Envolver en la sintaxis de bloques de llamada de Quarto
    # Se añade un salto de línea y delimitador
    return f"\n::: {{.callout-{callout_type}}}\n{body}\n:::\n"
