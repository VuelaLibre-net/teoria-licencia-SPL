# Manejador de tablas para el conversor DocBook a Quarto Markdown

DB_NS = 'http://docbook.org/ns/docbook'

def handle_table(node, ctx, convert_node):
    """
    Traduce una tabla de DocBook a una tabla de tuberías (GFM) de Quarto.
    Soporta leyendas de tabla (captions) y referencias cruzadas mediante IDs {#tbl-id}.
    """
    tgroup = node.find(f'{{{DB_NS}}}tgroup')
    if tgroup is None:
        return ""
        
    thead = tgroup.find(f'{{{DB_NS}}}thead')
    tbody = tgroup.find(f'{{{DB_NS}}}tbody')
    
    # Determinar el número de columnas a partir de colspecs
    colspecs = tgroup.findall(f'{{{DB_NS}}}colspec')
    col_count = len(colspecs)
    
    # Extraer cabecera
    from docbook_to_qmd import process_inline_elements
    headers = []
    if thead is not None:
        row = thead.find(f'{{{DB_NS}}}row')
        if row is not None:
            for entry in row.findall(f'{{{DB_NS}}}entry'):
                # Procesar el contenido de la celda de cabecera
                entry_text = process_inline_elements(entry, ctx).strip()
                # Reemplazar saltos de línea para no romper la fila
                entry_text = entry_text.replace('\n', ' ')
                headers.append(entry_text)
                
    # Extraer filas del cuerpo
    rows = []
    if tbody is not None:
        for row in tbody.findall(f'{{{DB_NS}}}row'):
            row_cells = []
            for entry in row.findall(f'{{{DB_NS}}}entry'):
                entry_text = process_inline_elements(entry, ctx).strip()
                entry_text = entry_text.replace('\n', ' ')
                row_cells.append(entry_text)
            if row_cells:
                rows.append(row_cells)
                
    # Si no hay cabecera pero hay filas, usar la primera fila como cabecera (exigencia GFM)
    if not headers and rows:
        headers = rows.pop(0)
    elif not headers and not rows:
        return "" # Tabla vacía
        
    # Si no coincide la longitud del col_count, reajustar
    col_count = max(len(headers), max((len(r) for r in rows), default=0))
    
    # Rellenar cabeceras vacías si es necesario
    while len(headers) < col_count:
        headers.append("")
        
    # Construir líneas de la tabla en Markdown
    table_lines = []
    
    # Línea de cabeceras
    table_lines.append("| " + " | ".join(headers) + " |")
    
    # Línea de separación (alineación por defecto a la izquierda)
    separators = ["---"] * col_count
    table_lines.append("| " + " | ".join(separators) + " |")
    
    # Líneas del cuerpo
    for r in rows:
        # Rellenar celdas vacías si la fila es corta
        while len(r) < col_count:
            r.append("")
        table_lines.append("| " + " | ".join(r) + " |")
        
    table_md = "\n".join(table_lines)
    
    # Agregar leyenda (caption) e ID en formato de Quarto si existen
    title_node = node.find(f'{{{DB_NS}}}title')
    caption_text = title_node.text.strip() if title_node is not None and title_node.text else ""
    
    tbl_id = node.get('{http://www.w3.org/XML/1998/namespace}id') or node.get('id')
    
    caption_line = ""
    if caption_text or tbl_id:
        # Quarto requiere que los IDs de tabla empiecen con tbl- para referencias cruzadas
        attr_str = ""
        if tbl_id:
            clean_id = tbl_id
            if not clean_id.startswith('tbl-'):
                if clean_id.startswith('_tbl-'):
                    clean_id = clean_id[1:]
                elif clean_id.startswith('_'):
                    clean_id = 'tbl-' + clean_id[1:]
                else:
                    clean_id = 'tbl-' + clean_id
            attr_str = f" {{#{clean_id}}}"
        
        caption_line = f"\n: {caption_text}{attr_str}\n"
        
    return f"\n{table_md}\n{caption_line}"
