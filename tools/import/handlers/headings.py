# Manejador de cabeceras y secciones para el conversor DocBook a Quarto Markdown

def handle_section(node, ctx, convert_node):
    """
    Traduce un nodo <section> de DocBook a Quarto.
    Calcula el nivel de la cabecera (# a #####) según la profundidad de anidación.
    """
    # Incrementar profundidad en el contexto (las secciones empiezan en nivel 2, 
    # ya que el nivel 1 (#) es para el título del capítulo).
    if not hasattr(ctx, 'section_depth'):
        ctx.section_depth = 1 # Empieza en 1, así la primera sección será nivel 2 (##)
    
    ctx.section_depth += 1
    
    # Buscar el título de la sección
    title_text = "Sección"
    title_node = None
    for child in node:
        tag = child.tag.split('}', 1)[1] if child.tag.startswith('{') else child.tag
        if tag == 'title':
            title_node = child
            break
            
    if title_node is not None:
        # Cargar los elementos inline del título (por si contiene negrita, etc.)
        from docbook_to_qmd import process_inline_elements
        title_text = process_inline_elements(title_node, ctx).strip()
    
    # Generar la cabecera Markdown
    if getattr(ctx, 'in_bibliography', False):
        section_md = [f"\n\n**{title_text}**\n\n"]
    else:
        header_prefix = "#" * min(ctx.section_depth, 6)
        section_md = [f"\n{header_prefix} {title_text}\n"]
    
    # Procesar los elementos hijos (saltando el título que ya procesamos)
    for child in node:
        tag = child.tag.split('}', 1)[1] if child.tag.startswith('{') else child.tag
        if tag == 'title':
            continue
        content = convert_node(child, ctx)
        if content:
            section_md.append(content)
            
    # Decrementar profundidad al salir
    ctx.section_depth -= 1
    
    return "".join(section_md)
