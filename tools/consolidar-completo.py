#!/usr/bin/env python3
import os
import re
import sys
from pathlib import Path

# Lista ordenada de directorios de los 9 libros
LIBROS = [
    "01-derecho-aereo-atc",
    "02-factores-humanos",
    "03-meteorologia",
    "04-comunicaciones",
    "05-principios-vuelo",
    "06-procedimientos-operativos",
    "07-planificacion-rendimiento",
    "08-aeronave-sistemas",
    "09-navegacion"
]

def clean_id(s):
    """Limpia un texto para generar un identificador único uniforme (réplica de glosario-enlaces.lua)."""
    replacements = {
        "Á": "a", "É": "e", "Í": "i", "Ó": "o", "Ú": "u", "Ñ": "n", "Ü": "u",
        "á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "ñ": "n", "ü": "u"
    }
    for char, replacement in replacements.items():
        s = s.replace(char, replacement)
    s = s.lower()
    s = re.sub(r'[^a-z0-9\s\-]', '', s)
    s = re.sub(r'[\s\-]+', '-', s)
    return s.strip('-')

def get_term_id(term):
    """Extrae el identificador base del término (antes del primer paréntesis o barra /)."""
    first_part = term.split('(')[0]
    if '/' in first_part:
        first_part = first_part.split('/')[0]
    return clean_id(first_part.strip())

def version_to_tuple(v_str):
    """Convierte una cadena de versión semántica (ej. 1.0-rc.8 o 0.8.5) en una tupla comparable."""
    v_str = v_str.strip('"\'')
    if '-' in v_str:
        base, pre = v_str.split('-', 1)
    else:
        base, pre = v_str, None
    
    parts = base.split('.')
    major = int(parts[0]) if len(parts) > 0 else 0
    minor = int(parts[1]) if len(parts) > 1 else 0
    patch = int(parts[2]) if len(parts) > 2 else 0
    
    if pre:
        # Pre-releases (ej. rc.7) ordenan antes que las finales
        pre_digits = re.findall(r'\d+', pre)
        pre_num = int(pre_digits[0]) if pre_digits else 0
        return (major, minor, patch, 0, pre_num)
    else:
        # Versión final ordena después
        return (major, minor, patch, 1, 0)

def parse_glossary(content):
    """Extrae términos y definiciones de un archivo glosario.qmd."""
    entries = {}
    lines = content.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        # Coincide con términos tipo **Término**
        match_term = re.match(r'^\*\*([^*]+)\*\*$', line)
        if match_term:
            current_term = match_term.group(1).strip()
            i += 1
            definition_lines = []
            while i < len(lines):
                next_line = lines[i]
                if next_line.strip().startswith(':'):
                    # Quitar el ':' inicial
                    definition_lines.append(next_line.strip()[1:].strip())
                    i += 1
                    # Continuar leyendo definición multilinea
                    while i < len(lines):
                        sub_line = lines[i]
                        if sub_line.strip() == "":
                            break
                        if sub_line.strip().startswith('**'):
                            break
                        definition_lines.append(sub_line.strip())
                        i += 1
                    break
                elif next_line.strip() == "":
                    i += 1
                else:
                    break
            
            if definition_lines:
                entries[current_term] = "\n".join(definition_lines)
        else:
            i += 1
    return entries

def parse_syllabus(content):
    """Separa el cuerpo del syllabus y la sección 'Ponte a prueba'."""
    lines = content.split('\n')
    syllabus_lines = []
    ponte_a_prueba_lines = []
    
    in_ponte = False
    for line in lines:
        if line.strip().startswith('# '):
            continue
        if line.strip().startswith('## Ponte a prueba'):
            in_ponte = True
            continue
        
        if in_ponte:
            ponte_a_prueba_lines.append(line)
        else:
            syllabus_lines.append(line)
            
    return "\n".join(syllabus_lines).strip(), "\n".join(ponte_a_prueba_lines).strip()

def get_chapters_and_title(libro_dir):
    """Obtiene el título y los capítulos que empiezan por 'cap' de un libro en _quarto.yml."""
    yaml_path = Path(libro_dir) / "_quarto.yml"
    if not yaml_path.exists():
        return None, []
        
    content = yaml_path.read_text(encoding='utf-8')
    
    # Extraer título
    title_match = re.search(r'title:\s*"([^"]+)"', content)
    if not title_match:
        title_match = re.search(r"title:\s*'([^']+)'", content)
    if not title_match:
        title_match = re.search(r"title:\s*(.+)", content)
    title = title_match.group(1).strip() if title_match else libro_dir
    
    # Extraer capítulos
    chapters = []
    in_chapters = False
    for line in content.split('\n'):
        line_strip = line.strip()
        if line_strip == 'chapters:':
            in_chapters = True
            continue
        if in_chapters:
            if line_strip.startswith('-'):
                chapter_file = line_strip[1:].strip().strip('"\'')
                if chapter_file.startswith('cap'):
                    chapters.append(f"{libro_dir}/{chapter_file}")
            elif line_strip == '' or line.startswith('  ') == False:
                # Comentarios se ignoran
                if not line_strip.startswith('#') and line_strip != '':
                    in_chapters = False
                    
    return title, chapters

def get_version(libro_dir):
    """Obtiene el campo 'version' de _quarto.yml."""
    yaml_path = Path(libro_dir) / "_quarto.yml"
    if not yaml_path.exists():
        return None
    content = yaml_path.read_text(encoding='utf-8')
    match = re.search(r'^version:\s*["\']?([^"\']+)["\']?', content, re.M)
    return match.group(1) if match else None

def main():
    print("==> [Python] Iniciando consolidación del Manual Completo SPL...")
    
    # 1. Determinar menor versión
    versiones = {}
    for libro in LIBROS:
        v = get_version(libro)
        if v:
            versiones[libro] = v
            
    if not versiones:
        print("ERROR: No se encontraron versiones en los libros.")
        sys.exit(1)
        
    menor_libro = min(versiones.keys(), key=lambda k: version_to_tuple(versiones[k]))
    menor_version = versiones[menor_libro]
    print(f"✓ Versión menor detectada: {menor_version} (en {menor_libro})")
    
    # 2. Consolidar Glosario
    print("==> Consolidando glosarios...")
    global_glossary = {}      # term_id -> (original_term, definition)
    glossary_sources = {}     # term_id -> libro
    discrepancies = []
    
    for libro in LIBROS:
        glosario_path = Path(libro) / "glosario.qmd"
        if glosario_path.exists():
            content = glosario_path.read_text(encoding='utf-8')
            entries = parse_glossary(content)
            for term, def_text in entries.items():
                term_id = get_term_id(term)
                if not term_id:
                    continue
                clean_def = re.sub(r'\s+', ' ', def_text).strip()
                
                if term_id in global_glossary:
                    existing_term, existing_def = global_glossary[term_id]
                    existing_clean_def = re.sub(r'\s+', ' ', existing_def).strip()
                    
                    # Detectar discrepancia de definición o de título del término
                    if existing_clean_def != clean_def:
                        discrepancies.append((term_id, existing_term, term, glossary_sources[term_id], libro, existing_def, def_text))
                else:
                    global_glossary[term_id] = (term, def_text)
                    glossary_sources[term_id] = libro
                    
    # Reportar discrepancias de glosario si existen
    if discrepancies:
        print("\n" + "="*80)
        print("⚠️  ADVERTENCIA: Se han detectado discrepancias o duplicidades en las definiciones del glosario!")
        print("Para asegurar la coherencia del manual, edita las fuentes de los libros indicados:")
        for term_id, term1, term2, source1, source2, def1, def2 in discrepancies:
            print(f"\n- Conflicto ID: **{term_id}**")
            print(f"  * En {source1} como '{term1}': {def1}")
            print(f"  * En {source2} as '{term2}': {def2}")
        print("="*80 + "\n")
    else:
        print("✓ No se detectaron discrepancias en los glosarios.")
        
    # Escribir glosario consolidado
    glosario_unificado_path = Path("glosario.qmd")
    with open(glosario_unificado_path, "w", encoding="utf-8") as f:
        f.write("# Glosario de términos\n\n")
        f.write("Este glosario unificado contiene las definiciones y acrónimos más relevantes del marco normativo aeronáutico (EASA, OACI, normativa nacional) aplicables a la licencia de piloto de planeador (SPL) de todas las asignaturas.\n\n")
        
        # Ordenar por el término original de forma alfabética
        sorted_ids = sorted(global_glossary.keys(), key=lambda t_id: global_glossary[t_id][0].lower())
        for term_id in sorted_ids:
            term, def_text = global_glossary[term_id]
            f.write(f"**{term}**\n")
            # Respetamos el formato de definición con el carácter ':'
            f.write(f": {def_text}\n\n")
            
    print(f"✓ Glosario consolidado escrito en {glosario_unificado_path}")
    
    # 3. Consolidar Syllabus (apéndices)
    print("==> Consolidando programas de estudios (syllabus)...")
    syllabus_unificado_path = Path("apendice-syllabus-completo.qmd")
    
    with open(syllabus_unificado_path, "w", encoding="utf-8") as f:
        f.write("# Syllabus oficial EASA {.unnumbered}\n\n")
        f.write("El siguiente programa de estudios (Syllabus) unificado corresponde a la totalidad de las materias teóricas exigidas para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.\n\n")
        
        for idx, libro in enumerate(LIBROS, 1):
            # Encontrar el archivo de syllabus en el libro
            syl_files = list(Path(libro).glob("apendice-syllabus*.qmd"))
            if syl_files:
                syl_path = syl_files[0]
                content = syl_path.read_text(encoding='utf-8')
                body, ponte = parse_syllabus(content)
                
                # Obtener el título del libro
                title, _ = get_chapters_and_title(libro)
                
                # Escribir sección H2 que no entra en la tabla de contenidos (.unnumbered .unlisted)
                f.write(f"## {idx}. {title} {{.unnumbered .unlisted}}\n\n")
                f.write(f"{body}\n\n")
                
                if ponte:
                    f.write("### Ponte a prueba {.unnumbered .unlisted}\n\n")
                    f.write(f"{ponte}\n\n")
                    
    print(f"✓ Syllabus consolidado escrito en {syllabus_unificado_path}")
    
    # 4. Copiar preliminares comunes de referencia (desde Libro 1)
    print("==> Copiando preliminares comunes desde 01-derecho-aereo-atc...")
    preliminares = ["licencia.qmd", "dedicatoria.qmd", "reconocimientos.qmd", "bibliografia.qmd"]
    for file_name in preliminares:
        src = Path("01-derecho-aereo-atc") / file_name
        dest = Path(file_name)
        if src.exists():
            dest.write_text(src.read_text(encoding='utf-8'), encoding='utf-8')
            print(f"  * {file_name} copiado.")
            
    # 5. Estructurar capítulos por partes
    print("==> Construyendo la estructura de capítulos y partes...")
    chapters_yaml = []
    for idx, libro in enumerate(LIBROS, 1):
        title, chapters = get_chapters_and_title(libro)
        if chapters:
            part_str = f"    - part: \"Parte {idx:02d}: {title}\"\n      chapters:\n"
            for chap in chapters:
                part_str += f"        - {chap}\n"
            chapters_yaml.append(part_str)
            
    chapters_str = "".join(chapters_yaml)
    
    # 6. Escribir _quarto-completo.yml final
    template_path = Path("_quarto-completo-template.yml")
    if not template_path.exists():
        print(f"ERROR: No se encuentra la plantilla {template_path}")
        sys.exit(1)
        
    template = template_path.read_text(encoding='utf-8')
    final_config = template.replace("{version}", menor_version).replace("{chapters}", chapters_str)
    
    config_path = Path("_quarto-completo.yml")
    config_path.write_text(final_config, encoding='utf-8')
    print(f"✓ Configuración de Quarto generada en {config_path}")
    print("==> [Python] Consolidación completada correctamente.")

if __name__ == "__main__":
    main()
