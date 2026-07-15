# Makefile para la compilación de la colección de manuales SPL en Quarto
# Repositorio: VuelaLibre-net/teoria-licencia-SPL

.PHONY: all clean clean-tmp 05-principios-vuelo test

# Directorios de salida
BUILD_DIR = build
PDF_OUT = $(BUILD_DIR)/pdf
EPUB_OUT = $(BUILD_DIR)/epub
TMP_DIR = tools/import/tmp

# Fuentes de origen (oficial)
OFICIAL_DIR = ../aesa-spl-oficial
LIBROS_DIR = $(OFICIAL_DIR)/libros

# Libros disponibles (01 al 09)
LIBROS = 01-derecho-aereo \
         02-conocimiento-general \
         03-performance \
         04-factores-humanos \
         05-principios-vuelo \
         06-meteorologia \
         07-navegacion \
         08-procedimientos-operacionales \
         09-comunicaciones

# Por defecto, compilar el piloto 05-principios-vuelo
all: 05-principios-vuelo

# --- PIPELINE PARA EL LIBRO PILOTO (05-PRINCIPIOS-VUELO) ---

# Compila el AsciiDoc original a DocBook XML
$(TMP_DIR)/05-principios-vuelo.xml: $(LIBROS_DIR)/05-*/index.adoc $(wildcard $(LIBROS_DIR)/05-*/capitulos/*.adoc)
	@mkdir -p $(TMP_DIR)
	@echo "==> [Asciidoctor] Compilando 05-principios-vuelo a DocBook XML..."
	asciidoctor -b docbook5 -o $@ $<

# Convierte el DocBook XML a Quarto Markdown (.qmd)
# Esta regla depende del script conversor y del XML intermedio
05-principios-vuelo/index.qmd: $(TMP_DIR)/05-principios-vuelo.xml tools/import/docbook_to_qmd.py $(wildcard tools/import/handlers/*.py)
	@echo "==> [Python] Traduciendo DocBook XML a Quarto Markdown..."
	python3 tools/import/docbook_to_qmd.py $< 05-principios-vuelo/

# Compila el PDF del libro 05 usando Typst via Quarto
$(PDF_OUT)/05-principios-vuelo.pdf: 05-principios-vuelo/index.qmd
	@mkdir -p $(PDF_OUT)
	@echo "==> [Quarto] Renderizando PDF (Typst) para 05-principios-vuelo..."
	quarto render 05-principios-vuelo/ --to typst
	@mv 05-principios-vuelo/_book/*.pdf $@
	@echo "✓ PDF generado en $@"

# Compila el EPUB del libro 05 usando Pandoc via Quarto
$(EPUB_OUT)/05-principios-vuelo.epub: 05-principios-vuelo/index.qmd
	@mkdir -p $(EPUB_OUT)
	@echo "==> [Quarto] Renderizando EPUB para 05-principios-vuelo..."
	quarto render 05-principios-vuelo/ --to epub
	@mv 05-principios-vuelo/_book/*.epub $@
	@echo "✓ EPUB generado en $@"

# Target completo para el libro 05 (compila conversión, PDF y EPUB)
05-principios-vuelo: $(PDF_OUT)/05-principios-vuelo.pdf $(EPUB_OUT)/05-principios-vuelo.epub

# --- UTILIDADES ---

# Ejecutar las pruebas unitarias del conversor
test:
	@echo "==> [Python] Ejecutando pruebas unitarias del conversor..."
	python3 -m unittest discover -s tests -p "test_*.py"

# Limpieza completa de builds y archivos intermedios
clean: clean-tmp
	rm -rf $(BUILD_DIR)
	rm -rf 05-principios-vuelo/_book 05-principios-vuelo/*.qmd 05-principios-vuelo/_quarto.yml 05-principios-vuelo/imagenes/

# Limpieza de archivos temporales de compilación intermedia
clean-tmp:
	rm -rf $(TMP_DIR)
