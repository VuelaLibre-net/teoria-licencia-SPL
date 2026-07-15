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
        
    elif tag in ['note', 'warning', 'caution', 'important']:
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
        # Asegurar un espacio después del párrafo
        return f"\n{para_text}\n"

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
        term_text = process_inline_elements(term, ctx) if term is not None else "Término sin nombre"
        def_text = "".join(convert_node(child, ctx) for child in definition).strip() if definition is not None else ""
        return f"\n### {term_text}\n\n{def_text}\n"

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
        
        # Formatear según etiqueta
        if child_tag == 'emphasis':
            role = child.get('role')
            if role == 'strong':
                formatted = f"**{child_text}**"
            else:
                formatted = f"*{child_text}*"
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
    return "".join(parts).replace('\xa0', ' ').replace('{nbsp}', ' ')

def generate_quarto_yml(output_dir, title, chapters_list):
    """Escribe el fichero de configuración de Quarto."""
    yml_path = Path(output_dir) / '_quarto.yml'
    
    # Formatear el listado de capítulos para YAML
    chapters_yaml = "\n".join(f"    - {chap}" for chap in chapters_list)
    
    content = f"""project:
  type: book
  output-dir: _book

book:
  title: "{title}"
  author: "VuelaLibre.net"
  chapters:
{chapters_yaml}

format:
  typst:
    toc: true
    number-sections: true
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
    
    # Colección de capítulos para generar _quarto.yml
    chapters_to_register = []
    
    # 1. Crear el index.qmd (Página de bienvenida / Prefacios)
    index_content = []
    preface_nodes = root.findall(f'{{{DB_NS}}}preface')
    for pref in preface_nodes:
        pref_title = pref.find(f'{{{DB_NS}}}title')
        pref_title_text = pref_title.text if pref_title is not None else "Prefacio"
        index_content.append(f"# {pref_title_text}\n")
        index_content.append("".join(convert_node(child, ctx) for child in pref if strip_ns(child.tag) != 'title'))
        
    # Escribir index.qmd base
    index_file = output_dir / 'index.qmd'
    index_body = "".join(index_content)
    if not index_body.strip():
        index_body = f"# {book_title}\n\nBienvenido a la versión digitalizada de este manual de formación SPL.\n"
    index_file.write_text(index_body, encoding='utf-8')
    chapters_to_register.append('index.qmd')
    
    # 2. Procesar cada Capítulo real (<chapter>)
    chapter_nodes = root.findall(f'{{{DB_NS}}}chapter')
    for idx, chap in enumerate(chapter_nodes, 1):
        ctx.current_chapter_num = idx
        chap_title = chap.find(f'{{{DB_NS}}}title')
        chap_title_text = chap_title.text if chap_title is not None else f"Capítulo {idx}"
        
        # Generar nombre del fichero qmd
        slug_title = chap_title_text.lower().replace(' ', '-').replace('/', '-').replace(':', '')
        slug_title = "".join(c for c in slug_title if c.isalnum() or c == '-')
        qmd_filename = f"cap{idx:02d}-{slug_title}.qmd"
        
        print(f"  -> Procesando capítulo {idx:02d}: {chap_title_text}")
        
        # Traducir contenido del capítulo
        chap_content = []
        chap_content.append(f"# {chap_title_text}\n")
        
        for child in chap:
            if strip_ns(child.tag) == 'title':
                continue
            content = convert_node(child, ctx)
            if content:
                chap_content.append(content)
                
        # Escribir qmd del capítulo
        qmd_path = output_dir / qmd_filename
        qmd_path.write_text("".join(chap_content), encoding='utf-8')
        chapters_to_register.append(qmd_filename)
        
    # 3. Procesar el Glosario si existe
    glossary_nodes = root.findall(f'{{{DB_NS}}}glossary')
    for idx, gloss in enumerate(glossary_nodes, 1):
        gloss_title = gloss.find(f'{{{DB_NS}}}title')
        gloss_title_text = gloss_title.text if gloss_title is not None else "Glosario"
        qmd_filename = "glosario.qmd"
        
        print(f"  -> Procesando {gloss_title_text}...")
        
        gloss_content = []
        gloss_content.append(f"# {gloss_title_text}\n")
        for child in gloss:
            if strip_ns(child.tag) == 'title':
                continue
            content = convert_node(child, ctx)
            if content:
                gloss_content.append(content)
                
        qmd_path = output_dir / qmd_filename
        qmd_path.write_text("".join(gloss_content), encoding='utf-8')
        chapters_to_register.append(qmd_filename)

    # 4. Copiar todas las imágenes físicas detectadas
    copy_images(ctx)
    
    # 5. Generar _quarto.yml
    generate_quarto_yml(output_dir, book_title, chapters_to_register)
    print("Conversión terminada de forma correcta.")

if __name__ == "__main__":
    main()
