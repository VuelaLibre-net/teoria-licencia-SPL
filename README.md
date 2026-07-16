# Colección de Manuales Teóricos SPL (Licencia de Piloto de Planeador) en Quarto

Este repositorio contiene la versión digitalizada de 9 libros que cubren el temario teórico para la obtención de la **Licencia de Piloto de Planeador (SPL)** de la **Agencia Estatal de Seguridad Aérea (AESA)**.

El contenido está en **Quarto Markdown (.qmd)** para la generación de entregables de alta calidad en formatos **PDF (mediante el motor Typst)** y **EPUB (mediante Pandoc)**.

---

## Estructura de la Colección

La biblioteca está organizada por asignaturas según el syllabus oficial de AESA/EASA:

1. **`01-derecho-aereo-atc`** - Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo
2. **`02-factores-humanos`** - Factores Humanos (Medicina y Psicología Aeronáutica)
3. **`03-meteorologia`** - Meteorología General y Aeronáutica
4. **`04-comunicaciones`** - Comunicaciones (Procedimientos de Radio y Fraseología VFR)
5. **`05-principios-vuelo`** - Principios de Vuelo (Aerodinámica y Estabilidad del Planeador)
6. **`06-procedimientos-operativos`** - Procedimientos Operativos y Emergencias
7. **`07-planificacion-rendimiento`** - Rendimiento y Planificación de Vuelo
8. **`08-aeronave-sistemas`** - Conocimientos Generales de la Aeronave, Estructura y Sistemas
9. **`09-navegacion`** - Navegación Visual, Estima e Instrumentos (GNSS)

---

## Requisitos Previos

Para poder compilar la colección completa, necesitarás contar con:

- **Quarto CLI** (versión 1.4 o superior): [Instrucciones de instalación](https://quarto.org/docs/get-started/)
- **Python 3** (para ejecutar la suite de importación/conversión)
---

## Instrucciones de Compilación

El proyecto incluye un [Makefile](file:///home/camus/ws/VuelaLibre.net/aesa-spl-quatro/Makefile) para automatizar el ciclo de vida de la compilación e importación de los libros:

### Compilar la colección completa
Genera los entregables en formatos PDF y EPUB para todos los libros:
```bash
make
```
Los archivos finales se guardarán en:
- `build/pdf/` - PDFs de alta calidad listos para impresión o consulta digital (Typst).
- `build/epub/` - Libros electrónicos adaptados para e-readers (Pandoc).

### Compilar un libro individual
Puedes compilar una única asignatura especificando su nombre de directorio. Por ejemplo:
```bash
make 05-principios-vuelo
```

### Ejecutar la suite de pruebas unitarias
Comprueba la consistencia sintáctica y semántica del conversor:
```bash
make test
```

### Limpiar la compilación
Elimina todos los entregables generados (`build/`), las cachés de Quarto y los archivos `.qmd` intermedios:
```bash
make clean
```

---

## Arquitectura de la Importación

La migración utiliza una canalización estructurada basada en un analizador de árbol de sintaxis XML (AST) para garantizar una traducción de calidad editorial:

1. **Compilación a DocBook XML:** Se toma la fuente `.adoc` y se genera un archivo XML que representa fielmente la semántica de la estructura del manual.
2. **Conversor Python:** El script `tools/import/docbook_to_qmd.py` procesa el XML y delega en manejadores modulares (`tools/import/handlers/`) para traducir títulos, tablas, figuras y callouts.
3. **Estructura del Libro:**
   - **Preliminares:** Colofón, Dedicatoria y Reconocimientos se separan en archivos unnumbered (`{.unnumbered}`).
   - **Ordenación Editorial (TOC):** Gracias a una extensión local de `orange-book` en `_extensions/orange-book-es/`, el contenido preliminar se imprime de forma limpia **antes** del Índice (*TOC*), y la lista de ilustraciones se sitúa **detrás** de este en el PDF.
   - **Capítulos:** La numeración real comienza en el primer tema académico (`cap01-`).
   - **Apéndices:** El Glosario, la Bibliografía (formateada sin secciones invasivas) y el Syllabus Oficial EASA se configuran como apéndices integrados en la estructura final de Quarto.
