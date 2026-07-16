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

# Datos que el colofón no puede saber por sí mismo y se inyectan al compilar.
#
# La fecha sale del último commit que tocó el libro, no del mtime: en un clon
# recién hecho los ficheros llevan la fecha del clonado, no la de su edición.
# Si git no responde (tarball sin historia), se cae a hoy.
#
# El mes se traduce con una tabla y no con LC_TIME=es_ES: si el runner no tiene
# ese locale, `date` no falla, escribe el mes en inglés y nadie se entera.
#
# Todo en sh portable: make usa /bin/sh, donde no existen ni ${var:5:2} ni
# $((10#08)) (bashismos). `expr` interpreta los ceros a la izquierda en decimal,
# que es justo lo que hace falta para los meses 01-09.
MESES = enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre
fecha_libro = $$(iso=$$(git log -1 --format=%cs -- $(1)/ 2>/dev/null || date +%F); \
	y=$$(echo $$iso | cut -d- -f1); m=$$(echo $$iso | cut -d- -f2); d=$$(echo $$iso | cut -d- -f3); \
	set -- $(MESES); shift $$(expr $$m - 1); \
	echo "$$(expr $$d + 0) de $$1 de $$y")
version_quarto = $$(quarto --version 2>/dev/null || echo "?")
version_libro = $$(sed -n 's/^version: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/p' $(1)/_quarto.yml | head -1)

# Estado editorial del libro, deducido de su versión. Se calcula AQUÍ y no en
# Typst porque el Makefile es el único punto por el que pasan los dos formatos:
# el EPUB no ejecuta nada de la extensión typst y se quedaba sin enterarse del
# estado. Una sola fuente para PDF y EPUB.
#
#   >= 1.0.0        completado (cadena vacía: apaga la marca y la nota)
#   1.x-rc.n        en revisión   (un candidato es ANTERIOR a la 1.x.0)
#   0.9.x           en revisión
#   0.8.x           creando ilustraciones
#   0.7.x y menos   en desarrollo
estado_libro = $$(v=$(call version_libro,$(1)); \
	case "$$v" in *-*) pre=1 ;; *) pre=0 ;; esac; \
	base=$${v%%-*}; may=$$(echo "$$base" | cut -d. -f1); men=$$(echo "$$base" | cut -d. -f2); \
	case "$$may$$men" in *[!0-9]*|"") echo ""; exit ;; esac; \
	if [ "$$may" -ge 1 ] && [ "$$pre" -eq 0 ]; then echo ""; \
	elif [ "$$may" -ge 1 ] || [ "$$men" -ge 9 ]; then echo "En revisión"; \
	elif [ "$$men" -ge 8 ]; then echo "Creando ilustraciones"; \
	else echo "En desarrollo"; fi)

nota_libro = $$(case "$(call estado_libro,$(1))" in \
	"En revisión") echo "Edición pendiente de revisión técnica por instructores. El contenido puede cambiar antes de la versión definitiva." ;; \
	"Creando ilustraciones") echo "El texto está completo; las ilustraciones aún se están elaborando." ;; \
	"En desarrollo") echo "Texto e ilustraciones en elaboración. Contenido provisional, sujeto a cambios." ;; \
	*) echo "" ;; esac)

# Compila el PDF del libro usando Typst via Quarto
$(PDF_OUT)/%.pdf: %/index.qmd
	@mkdir -p $(PDF_OUT)
	@echo "==> [Quarto] Renderizando PDF (Typst) para $*..."
	quarto render $*/ --to orange-book-es-typst \
	  --metadata fecha-actualizacion="$(call fecha_libro,$*)" \
	  --metadata version-quarto="$(call version_quarto)" \
	  --metadata estado="$(call estado_libro,$*)" \
	  --metadata estado-nota="$(call nota_libro,$*)"
	@mv $*/_book/*.pdf $@
	@echo "✓ PDF generado en $@"

# Compila el EPUB del libro usando Pandoc via Quarto
$(EPUB_OUT)/%.epub: %/index.qmd
	@mkdir -p $(EPUB_OUT)
	@echo "==> [Quarto] Renderizando EPUB para $*..."
	quarto render $*/ --to epub \
	  --metadata fecha-actualizacion="$(call fecha_libro,$*)" \
	  --metadata version-quarto="$(call version_quarto)" \
	  --metadata estado="$(call estado_libro,$*)" \
	  --metadata estado-nota="$(call nota_libro,$*)"
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
