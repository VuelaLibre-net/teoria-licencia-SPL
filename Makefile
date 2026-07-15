# Makefile para la compilación de la colección de manuales SPL en Quarto
# Repositorio: VuelaLibre-net/teoria-licencia-SPL

.PHONY: all clean clean-tmp libro-05 test

# Directorios de salida
BUILD_DIR = build
PDF_OUT = $(BUILD_DIR)/pdf
EPUB_OUT = $(BUILD_DIR)/epub
TMP_DIR = tools/import/tmp

# Fuentes de origen (oficial)
OFICIAL_DIR = ../aesa-spl-oficial
LIBROS_DIR = $(OFICIAL_DIR)/libros

# Libros disponibles (01 al 09)
LIBROS = 01 02 03 04 05 06 07 08 09

# Por defecto, compilar el piloto libro-05
all: libro-05

# --- PIPELINE PARA EL LIBRO PILOTO (LIBRO-05) ---

# Compila el AsciiDoc original a DocBook XML
$(TMP_DIR)/libro-05.xml: $(LIBROS_DIR)/05-*/index.adoc $(wildcard $(LIBROS_DIR)/05-*/capitulos/*.adoc)
	@mkdir -p $(TMP_DIR)
	@echo "==> [Asciidoctor] Compilando 05-principios-vuelo a DocBook XML..."
	asciidoctor -b docbook5 -o $@ $<

# Convierte el DocBook XML a Quarto Markdown (.qmd)
# Esta regla depende del script conversor y del XML intermedio
libro-05/index.qmd: $(TMP_DIR)/libro-05.xml tools/import/docbook_to_qmd.py $(wildcard tools/import/handlers/*.py)
	@echo "==> [Python] Traduciendo DocBook XML a Quarto Markdown..."
	python3 tools/import/docbook_to_qmd.py $< libro-05/

# Compila el PDF del libro 05 usando Typst via Quarto
$(PDF_OUT)/libro-05.pdf: libro-05/index.qmd
	@mkdir -p $(PDF_OUT)
	@echo "==> [Quarto] Renderizando PDF (Typst) para Libro 05..."
	quarto render libro-05/ --to typst
	@mv libro-05/_book/*.pdf $@
	@echo "✓ PDF generado en $@"

# Compila el EPUB del libro 05 usando Pandoc via Quarto
$(EPUB_OUT)/libro-05.epub: libro-05/index.qmd
	@mkdir -p $(EPUB_OUT)
	@echo "==> [Quarto] Renderizando EPUB para Libro 05..."
	quarto render libro-05/ --to epub
	@mv libro-05/_book/*.epub $@
	@echo "✓ EPUB generado en $@"

# Target completo para el libro 05 (compila conversión, PDF y EPUB)
libro-05: $(PDF_OUT)/libro-05.pdf $(EPUB_OUT)/libro-05.epub

# --- UTILIDADES ---

# Ejecutar las pruebas unitarias del conversor
test:
	@echo "==> [Python] Ejecutando pruebas unitarias del conversor..."
	python3 -m unittest discover -s tests -p "test_*.py"

# Limpieza completa de builds y archivos intermedios
clean: clean-tmp
	rm -rf $(BUILD_DIR)
	rm -rf libro-05/_book libro-05/*.qmd libro-05/_quarto.yml libro-05/imagenes/

# Limpieza de archivos temporales de compilación intermedia
clean-tmp:
	rm -rf $(TMP_DIR)
