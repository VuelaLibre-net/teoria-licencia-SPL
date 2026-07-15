# Manejador de imágenes y figuras para el conversor DocBook a Quarto Markdown

import shutil
from pathlib import Path

DB_NS = 'http://docbook.org/ns/docbook'

def handle_figure(node, ctx):
    """
    Traduce un nodo <figure> o <informalfigure> de DocBook a sintaxis de imagen de Quarto.
    Registra la imagen física detectada en el contexto para copiarla después.
    """
    # Buscar el nodo <imagedata> dentro de <mediaobject>/<imageobject>/<imagedata>
    imagedata = None
    mediaobject = node.find(f'{{{DB_NS}}}mediaobject')
    if mediaobject is not None:
        imageobject = mediaobject.find(f'{{{DB_NS}}}imageobject')
        if imageobject is not None:
            imagedata = imageobject.find(f'{{{DB_NS}}}imagedata')
            
    if imagedata is None:
        return "" # No se encontró imagen válida
        
    fileref = imagedata.get('fileref')
    if not fileref:
        return ""
        
    # Obtener el nombre del archivo de imagen
    # Habitualmente es "imagenes/nombre.jpg" o similar
    img_path = Path(fileref)
    img_filename = img_path.name
    
    # Registrar la imagen física para copiarla al final
    ctx.imagenes_detectadas.add(img_filename)
    
    # Buscar el título de la figura (caption)
    title_node = node.find(f'{{{DB_NS}}}title')
    caption_text = ""
    if title_node is not None and title_node.text:
        caption_text = title_node.text.strip()
        
    # Obtener el ID de la figura para referencias cruzadas
    fig_id = node.get('{http://www.w3.org/XML/1998/namespace}id') or node.get('id')
    
    # Procesar atributos como ancho (width) si existen
    attrs = []
    if fig_id:
        # Quarto requiere que los IDs de figura empiecen con fig- para numeración automática
        clean_id = fig_id
        if not clean_id.startswith('fig-'):
            # Si empieza por _fig- o similar, normalizar
            if clean_id.startswith('_fig-'):
                clean_id = clean_id[1:]
            elif clean_id.startswith('_'):
                clean_id = 'fig-' + clean_id[1:]
            else:
                clean_id = 'fig-' + clean_id
        attrs.append(f"#{clean_id}")
        
    width = imagedata.get('width')
    if width:
        # Limpiar width por si tiene formato pdfwidth=75% etc
        if '%' in width:
            attrs.append(f"width='{width}'")
            
    # Formatear la cadena de atributos en Quarto: {#fig-id width=75%}
    attr_str = ""
    if attrs:
        attr_str = "{" + " ".join(attrs) + "}"
        
    # Ruta de destino final en Quarto (siempre en la carpeta local de imágenes)
    dest_path = f"imagenes/{img_filename}"
    
    # Construir marcado de Quarto
    if caption_text:
        return f"\n![{caption_text}]({dest_path}){attr_str}\n"
    else:
        return f"\n![]({dest_path}){attr_str}\n"

def copy_images(ctx):
    """
    Copia las imágenes físicas detectadas desde el repositorio oficial de origen
    al directorio de destino de Quarto.
    """
    if not ctx.imagenes_detectadas:
        print("  No se detectaron imágenes para copiar.")
        return
        
    src_img_dir = ctx.source_dir / 'imagenes'
    dest_img_dir = ctx.output_dir / 'imagenes'
    
    # Crear carpeta de destino
    dest_img_dir.mkdir(parents=True, exist_ok=True)
    
    copied_count = 0
    missing_images = []
    
    print(f"  Copiando imágenes desde {src_img_dir} a {dest_img_dir}...")
    for img_name in sorted(ctx.imagenes_detectadas):
        src_file = src_img_dir / img_name
        dest_file = dest_img_dir / img_name
        
        if src_file.exists():
            shutil.copy2(src_file, dest_file)
            copied_count += 1
        else:
            # Intentar buscar directamente en el directorio raíz por si acaso
            fallback_file = ctx.source_dir / img_name
            if fallback_file.exists():
                shutil.copy2(fallback_file, dest_file)
                copied_count += 1
            else:
                missing_images.append(img_name)
                
    print(f"  ✓ {copied_count} imágenes copiadas con éxito.")
    if missing_images:
        print(f"  ⚠ Advertencia: {len(missing_images)} imágenes no encontradas en origen:")
        for img in missing_images:
            print(f"    - {img}")
