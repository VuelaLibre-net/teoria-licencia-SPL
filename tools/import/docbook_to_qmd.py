#!/usr/bin/env python3
"""
Convertidor estructurado de DocBook XML (AST de AsciiDoc) a Quarto Markdown (.qmd).
Este script coordina el proceso de importación del libro, delega en manejadores modulares 
y escribe los archivos QMD finales y el archivo de configuración _quarto.yml.

Uso:
  python3 tools/import/docbook-to-qmd.py <archivo.xml> <directorio_salida> [--source-dir <directorio_origen>]
"""

import os
import sys
import argparse
import shutil
import re
import xml.etree.ElementTree as ET
from pathlib import Path

# Registrar ruta para poder importar los manejadores modulares
sys.path.insert(0, str(Path(__file__).resolve().parent))

# Importar los manejadores modulares (se crearán a continuación)
from handlers.headings import handle_section
from handlers.callouts import handle_callout
from handlers.figures import handle_figure, copy_images
from handlers.tables import handle_table

DB_NS = 'http://docbook.org/ns/docbook'

def strip_ns(tag):
    """Elimina el espacio de nombres de la etiqueta XML para facilitar comparaciones."""
    if tag.startswith('{'):
        return tag.split('}', 1)[1]
    return tag

class ConverterContext:
    """Contexto compartido durante la conversión para almacenar rutas, imágenes y metadatos."""
    def __init__(self, source_dir, output_dir):
        self.source_dir = Path(source_dir)
        self.output_dir = Path(output_dir)
        self.imagenes_detectadas = set()
        self.current_chapter_num = 0

def convert_node(node, ctx):
    """Función recursiva principal que traduce un nodo XML a Markdown."""
    tag = strip_ns(node.tag)
    
    # Manejar elementos estructurales grandes
    if tag == 'section':
        return handle_section(node, ctx, convert_node)
        
    elif tag in ['note', 'warning', 'caution', 'important', 'tip']:
        return handle_callout(node, ctx, convert_node)
        
    elif tag in ['figure', 'informalfigure']:
        return handle_figure(node, ctx)
        
    elif tag == 'table':
        return handle_table(node, ctx, convert_node)

    elif tag in ['indexterm', 'anchor']:
        return ""

    # Bloques de párrafo y texto
    elif tag == 'simpara' or tag == 'para':
        # Procesar hijos inline
        para_text = process_inline_elements(node, ctx)
        # Omitir párrafos vacíos o que sólo contengan espacios en blanco
        if not para_text.strip():
            return ""
        # Asegurar un espacio después del párrafo
        return f"\n{para_text}\n"

    elif tag == 'blockquote':
        body_parts = []
        if node.text:
            body_parts.append(node.text)
        for child in node:
            content = convert_node(child, ctx)
            if content:
                body_parts.append(content)
            if child.tail:
                body_parts.append(child.tail)
        body = "".join(body_parts).strip()
        quoted_lines = [f"> {line}" if line.strip() else ">" for line in body.split("\n")]
        return "\n" + "\n".join(quoted_lines) + "\n"

    elif tag == 'literallayout':
        # Preservar el formateado de literallayout usando el procesador inline
        text = process_inline_elements(node, ctx)
        return f"\n{text}\n"

    # Títulos dentro de bloques (las secciones se manejan en handle_section)
    elif tag == 'title':
        return "" # Los títulos de figuras/tablas se manejan en sus respectivos handlers

    # Listas
    elif tag == 'itemizedlist':
        items_text = []
        for item in node.findall(f'{{{DB_NS}}}listitem'):
            item_content = "".join(convert_node(child, ctx) for child in item).strip()
            # Sangrar multilíneas si las hay
            indented = "\n  ".join(item_content.split("\n"))
            items_text.append(f"* {indented}")
        return "\n" + "\n".join(items_text) + "\n"

    elif tag == 'orderedlist':
        items_text = []
        for idx, item in enumerate(node.findall(f'{{{DB_NS}}}listitem'), 1):
            item_content = "".join(convert_node(child, ctx) for child in item).strip()
            indented = "\n  ".join(item_content.split("\n"))
            items_text.append(f"{idx}. {indented}")
        return "\n" + "\n".join(items_text) + "\n"

    # Glosario y Bibliografía (estructuras específicas)
    elif tag == 'glossentry':
        term = node.find(f'{{{DB_NS}}}glossterm')
        definition = node.find(f'{{{DB_NS}}}glossdef')
        term_text = process_inline_elements(term, ctx) if term is not None else ""
        def_text = "".join(convert_node(child, ctx) for child in definition).strip() if definition is not None else ""
        if term_text:
            return f"\n**{term_text}**\n: {def_text}\n"
        return ""

    # Si es un contenedor genérico (como book, chapter, info, glossary, bibliography), procesar hijos
    else:
        result = []
        for child in node:
            content = convert_node(child, ctx)
            if content:
                result.append(content)
        return "".join(result)

def process_inline_elements(node, ctx):
    """Procesa elementos de texto plano y formateado inline (negrita, cursiva, enlaces, fórmulas)."""
    if node is None:
        return ""
    
    parts = []
    # Texto inicial del nodo
    if node.text:
        parts.append(node.text)
        
    for child in node:
        child_tag = strip_ns(child.tag)
        child_text = child.text if child.text else ""
        child_tail = child.tail if child.tail else ""
        
        # Ignorar indexterms y anchors por completo, pero conservar su tail
        if child_tag in ('indexterm', 'anchor'):
            if child_tail:
                parts.append(child_tail)
            continue
        
        # Formatear según etiqueta
        if child_tag == 'emphasis':
            role = child.get('role')
            inner = process_inline_elements(child, ctx) if len(child) > 0 else child_text
            if role == 'strong':
                formatted = f"**{inner}**"
            else:
                formatted = f"*{inner}*"
        elif child_tag == 'literal':
            formatted = f"`{child_text}`"
        elif child_tag == 'link':
            # Manejo de citas y referencias externas
            linkend = child.get('linkend')
            if linkend:
                # Citas inter-libro o internas: la premisa 4-B dicta simplificar citas a texto plano
                formatted = f"{child_text}"
            else:
                href = child.get('{http://www.w3.org/1999/xlink}href') or child.get('href')
                formatted = f"[{child_text}]({href})" if href else child_text
        elif child_tag == 'xref':
            # Referencias cruzadas internas del libro (a figuras, tablas)
            # Solo fig- y tbl- son prefijos reconocidos por Quarto como cross-refs.
            # Cualquier otro prefijo (cap-, glos-, ref-, sec-) se trata como citation
            # por Pandoc y rompe la compilación si no hay bibliografía.
            linkend = child.get('linkend', '')
            if linkend.startswith('fig-'):
                formatted = f"@{linkend}"
            elif linkend.startswith('tbl-'):
                formatted = f"@{linkend}"
            else:
                # Suprimir la referencia; el texto circundante ya provee contexto
                formatted = ""
        elif child_tag == 'superscript':
            formatted = f"^{child_text}^"
        elif child_tag == 'subscript':
            formatted = f"~{child_text}~"
        else:
            # Recursividad inline básica por si hay etiquetas anidadas
            formatted = process_inline_elements(child, ctx)
            
        parts.append(formatted)
        if child_tail:
            parts.append(child_tail)
            
    # Reemplazar espacios y caracteres huérfanos comunes
    result = "".join(parts).replace('\xa0', ' ').replace('{nbsp}', ' ')
    # Suprimir macros AsciiDoc que no se resuelven en DocBook (list-of::, etc.)
    result = re.sub(r'list-of::\w+\[\]', '', result)
    return result

def generate_quarto_yml(output_dir, title, chapters_list, appendices_list=None):
    """Escribe el fichero de configuración de Quarto."""
    yml_path = Path(output_dir) / '_quarto.yml'
    
    # Formatear el listado de capítulos para YAML
    chapters_yaml = "\n".join(f"    - {chap}" for chap in chapters_list)
    
    appendices_part = ""
    if appendices_list:
        appendices_yaml = "\n".join(f"    - {app}" for app in appendices_list)
        appendices_part = f"\n  appendices:\n{appendices_yaml}"
        
    content = f"""project:
  type: book
  output-dir: _book

book:
  title: "{title}"
  author: "VuelaLibre.net"
  chapters:
{chapters_yaml}{appendices_part}

format:
  typst:
    toc: true
    number-sections: true
    keep-typ: true
    margin:
      top: 2.5cm
      bottom: 2.5cm
      left: 3cm
      right: 3cm
  epub:
    toc: true
"""
    yml_path.write_text(content, encoding='utf-8')
    print(f"  ✓ Configuración generada en {yml_path}")

def main():
    parser = argparse.ArgumentParser(description="Conversor estructurado de DocBook XML a Quarto Markdown (.qmd)")
    parser.add_argument("xml_file", help="Ruta al archivo XML de DocBook")
    parser.add_argument("output_dir", help="Directorio de destino para los archivos Quarto")
    parser.add_argument("--source-dir", help="Directorio de origen de los archivos AsciiDoc (para copiar imágenes)")
    args = parser.parse_args()
    
    xml_path = Path(args.xml_file)
    output_dir = Path(args.output_dir)
    
    # Inferir el directorio de origen si no se proporciona
    if args.source_dir:
        source_dir = Path(args.source_dir)
    else:
        # Inferir de forma dinámica a partir del nombre del XML, por ejemplo, 
        # si es tools/import/tmp/05-principios-vuelo.xml -> ../aesa-spl-oficial/libros/05-principios-vuelo
        source_dir = Path("../aesa-spl-oficial/libros") / xml_path.stem
        
    if not xml_path.exists():
        print(f"Error: No se encuentra el XML en {xml_path}", file=sys.stderr)
        sys.exit(1)
        
    print(f"Iniciando conversión de {xml_path.name} a {output_dir}...")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Inicializar el contexto de conversión
    ctx = ConverterContext(source_dir, output_dir)
    
    # Cargar y parsear el XML
    tree = ET.parse(xml_path)
    root = tree.getroot()
    
    # Extraer el título del libro
    title_node = root.find(f'{{{DB_NS}}}info/{{{DB_NS}}}title')
    book_title = title_node.text.strip() if title_node is not None else "Asignatura SPL"
    
    # 1. Crear el index.qmd (Página de bienvenida base)
    index_file = output_dir / 'index.qmd'
    index_body = f"# {book_title} {{.unnumbered}}\n\nBienvenido a la versión digitalizada de este manual de formación SPL.\n"
    index_file.write_text(index_body, encoding='utf-8')
    
    chapters_list = ['index.qmd']
    appendices_list = []
    
    real_chapter_counter = 0
    
    # Procesar hijos del root de forma secuencial
    for child in root:
        tag = strip_ns(child.tag)
        child_id = child.attrib.get('{http://www.w3.org/XML/1998/namespace}id', '')
        
        # Ignorar info
        if tag == 'info':
            continue
            
        title_node = child.find(f'{{{DB_NS}}}title')
        title_text = title_node.text.strip() if title_node is not None and title_node.text else ""
        
        category = None
        filename = None
        
        # Categorizar el elemento según su etiqueta o ID
        if tag == 'colophon':
            category = 'preliminary'
            title_text = title_text or "Información Legal y Licencia"
            filename = 'colofon.qmd'
        elif tag == 'dedication':
            category = 'preliminary'
            title_text = title_text or "Dedicatoria"
            filename = 'dedicatoria.qmd'
        elif tag == 'preface':
            category = 'preliminary'
            title_text = title_text or "Prefacio"
            filename = 'prefacio.qmd'
        elif tag == 'chapter':
            if child_id == '_índice_de_ilustraciones' or "ilustraciones" in title_text.lower():
                category = 'preliminary'
                title_text = title_text or "Índice de ilustraciones"
                filename = 'indice-ilustraciones.qmd'
            elif child_id == 'glosario' or "glosario" in title_text.lower():
                category = 'appendix'
                title_text = title_text or "Glosario de términos"
                filename = 'glosario.qmd'
            elif child_id == 'bibliografia' or "bibliografía" in title_text.lower():
                category = 'appendix'
                title_text = title_text or "Bibliografía y fuentes"
                filename = 'bibliografia.qmd'
            else:
                category = 'chapter'
                real_chapter_counter += 1
                slug_title = title_text.lower().replace(' ', '-').replace('/', '-').replace(':', '')
                slug_title = "".join(c for c in slug_title if c.isalnum() or c == '-')
                filename = f"cap{real_chapter_counter:02d}-{slug_title}.qmd"
        elif tag == 'appendix':
            category = 'appendix'
            slug_title = title_text.lower().replace(' ', '-').replace('/', '-').replace(':', '')
            slug_title = "".join(c for c in slug_title if c.isalnum() or c == '-')
            filename = f"apendice-{slug_title}.qmd"
        elif tag == 'glossary':
            category = 'appendix'
            title_text = title_text or "Glosario de términos"
            filename = 'glosario.qmd'
        elif tag == 'bibliography':
            category = 'appendix'
            title_text = title_text or "Bibliografía y fuentes"
            filename = 'bibliografia.qmd'
            
        if not category or not filename:
            continue
            
        print(f"  -> Procesando {category}: {title_text} ({filename})")
        
        # Procesar contenido del elemento
        content = []
        if category == 'preliminary':
            content.append(f"# {title_text} {{.unnumbered}}\n")
        else:
            content.append(f"# {title_text}\n")
            
        ctx.in_bibliography = (filename == 'bibliografia.qmd')
        for child_el in child:
            if strip_ns(child_el.tag) == 'title':
                continue
            res = convert_node(child_el, ctx)
            if res:
                content.append(res)
        ctx.in_bibliography = False
                
        # Escribir qmd
        qmd_path = output_dir / filename
        qmd_path.write_text("".join(content), encoding='utf-8')
        
        # Registrar en la lista adecuada
        if category == 'preliminary':
            chapters_list.append(filename)
        elif category == 'chapter':
            chapters_list.append(filename)
        elif category == 'appendix':
            appendices_list.append(filename)
            
    # 4. Copiar todas las imágenes físicas detectadas
    copy_images(ctx)
    
    # 5. Generar _quarto.yml
    generate_quarto_yml(output_dir, book_title, chapters_list, appendices_list)
    print("Conversión terminada de forma correcta.")

if __name__ == "__main__":
    main()
