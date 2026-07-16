# Makefile para la compilación de la colección de manuales SPL en Quarto
# Repositorio: VuelaLibre-net/teoria-licencia-SPL

# Directorios de salida
BUILD_DIR = build
PDF_OUT = $(BUILD_DIR)/pdf
EPUB_OUT = $(BUILD_DIR)/epub

# Lista de libros de la colección (01 al 09)
LIBROS = 01-derecho-aereo-atc \
         02-factores-humanos \
         03-meteorologia \
         04-comunicaciones \
         05-principios-vuelo \
         06-procedimientos-operativos \
         07-planificacion-rendimiento \
         08-aeronave-sistemas \
         09-navegacion

.PHONY: all clean $(LIBROS)

# Por defecto, compilar toda la colección de libros (01 a 09)
all: $(LIBROS)

# --- REGLAS GENERALES PARA CUALQUIER LIBRO ---
# Los .qmd de cada libro son la fuente canónica: se editan a mano y ninguna
# regla los genera. Make sólo compila los entregables a partir de ellos.

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

# Limpieza de los entregables y las cachés de Quarto.
# NO toca los .qmd, _quarto.yml ni imagenes/: son la fuente canónica de la
# colección, viven en git y no se regeneran a partir de nada.
clean:
	rm -rf $(BUILD_DIR)
	@for libro in $(LIBROS); do \
		rm -rf $$libro/_book $$libro/.quarto; \
	done
