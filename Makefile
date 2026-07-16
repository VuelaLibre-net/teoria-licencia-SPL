# Makefile para la compilación de la colección de manuales SPL en Quarto
# Repositorio: VuelaLibre-net/teoria-licencia-SPL

# Directorios de salida
BUILD_DIR = build
PDF_OUT = $(BUILD_DIR)/pdf
EPUB_OUT = $(BUILD_DIR)/epub
TMP_DIR = tools/import/tmp

# Fuentes de origen (oficial)
OFICIAL_DIR = ../aesa-spl-oficial
LIBROS_DIR = $(OFICIAL_DIR)/libros

# Lista de libros oficiales en el repositorio de origen (01 al 09)
LIBROS = 01-derecho-aereo-atc \
         02-factores-humanos \
         03-meteorologia \
         04-comunicaciones \
         05-principios-vuelo \
         06-procedimientos-operativos \
         07-planificacion-rendimiento \
         08-aeronave-sistemas \
         09-navegacion

.PHONY: all clean clean-tmp test $(LIBROS)

# Evitar que GNU Make borre automáticamente los archivos intermedios (.qmd)
.SECONDARY:

# Por defecto, compilar toda la colección de libros (01 a 09)
all: $(LIBROS)

# --- REGLAS GENERALES PARA CUALQUIER LIBRO ---

# Compila el AsciiDoc original a DocBook XML intermedio
$(TMP_DIR)/%.xml: $(LIBROS_DIR)/%/index.adoc
	@mkdir -p $(TMP_DIR)
	@echo "==> [Asciidoctor] Compilando $* a DocBook XML..."
	asciidoctor -b docbook5 -o $@ $<

# Convierte el DocBook XML a Quarto Markdown (.qmd)
%/index.qmd: $(TMP_DIR)/%.xml tools/import/docbook_to_qmd.py $(wildcard tools/import/handlers/*.py)
	@echo "==> [Python] Traduciendo DocBook XML a Quarto Markdown..."
	python3 tools/import/docbook_to_qmd.py $< $*/

# Compila el PDF del libro usando Typst via Quarto
$(PDF_OUT)/%.pdf: %/index.qmd
	@mkdir -p $(PDF_OUT)
	@echo "==> [Quarto] Renderizando PDF (Typst) para $*..."
	quarto render $*/ --to orange-book-es-typst
	@mv $*/_book/*.pdf $@
	@echo "✓ PDF generado en $@"

# Compila el EPUB del libro usando Pandoc via Quarto
$(EPUB_OUT)/%.epub: %/index.qmd
	@mkdir -p $(EPUB_OUT)
	@echo "==> [Quarto] Renderizando EPUB para $*..."
	quarto render $*/ --to epub
	@mv $*/_book/*.epub $@
	@echo "✓ EPUB generado en $@"

# Regla estática para cada libro de la lista
$(LIBROS): %: $(PDF_OUT)/%.pdf $(EPUB_OUT)/%.epub

# --- UTILIDADES ---

# Ejecutar las pruebas unitarias del conversor
test:
	@echo "==> [Python] Ejecutando pruebas unitarias del conversor..."
	python3 -m unittest discover -s tests -p "test_*.py"

# Limpieza completa de builds y archivos convertidos
clean: clean-tmp
	rm -rf $(BUILD_DIR)
	@for libro in $(LIBROS); do \
		rm -rf $$libro/_book $$libro/*.qmd $$libro/_quarto.yml $$libro/imagenes/; \
	done

# Limpieza de archivos temporales
clean-tmp:
	rm -rf $(TMP_DIR)
