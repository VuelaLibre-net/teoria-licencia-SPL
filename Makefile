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

# La extracción de la versión y la fecha se escriben UNA vez y se usan de dos
# maneras: dentro de las recetas (donde make deja que las expanda el shell) y al
# parsear el Makefile (donde hacen falta ya resueltas, para construir el nombre
# del fichero). Compartir el patrón evita que las dos formas divierjan, que es
# el modo de fallo habitual aquí: divergen y todo sigue compilando.
SED_VERSION = sed -n 's/^version: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/p'
GIT_FECHA_ISO = git log -1 --format=%cs --

fecha_libro = $$(iso=$$($(GIT_FECHA_ISO) $(1)/ 2>/dev/null || date +%F); \
	y=$$(echo $$iso | cut -d- -f1); m=$$(echo $$iso | cut -d- -f2); d=$$(echo $$iso | cut -d- -f3); \
	set -- $(MESES); shift $$(expr $$m - 1); \
	echo "$$(expr $$d + 0) de $$1 de $$y")
version_quarto = $$(quarto --version 2>/dev/null || echo "?")
version_libro = $$($(SED_VERSION) $(1)/_quarto.yml | head -1)

# --- NOMBRE DE LOS ENTREGABLES ---
# Los ficheros llevan versión y fecha: `09-navegacion-0.8.1-26-07-16.pdf`. Los
# dos datos están dentro del libro (portadilla y colofón), pero un PDF
# descargado se identifica por su nombre sin llegar a abrirlo, y así dos
# versiones del mismo libro no se pisan en la carpeta de descargas.
#
# La fecha es la MISMA del colofón —el último commit que tocó el libro—, no la
# de compilación: si fuera la de compilación, el nombre cambiaría en cada build
# sin que el libro hubiera cambiado, y dejaría de identificar nada.
#
# Estas versiones se resuelven al parsear (`$(shell ...)`) porque forman parte
# del nombre del objetivo, y make necesita saberlo antes de decidir qué hacer.
version_de = $(shell $(SED_VERSION) $(1)/_quarto.yml | head -1)
fecha_corta_de = $(shell iso=$$($(GIT_FECHA_ISO) $(1)/ 2>/dev/null); \
	[ -n "$$iso" ] || iso=$$(date +%F); echo "$${iso#??}")
sufijo_de = $(call version_de,$(1))-$(call fecha_corta_de,$(1))
pdf_de = $(PDF_OUT)/$(1)-$(call sufijo_de,$(1)).pdf
epub_de = $(EPUB_OUT)/$(1)-$(call sufijo_de,$(1)).epub

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

# Las reglas se generan una por libro, y no como regla de patrón, porque el
# nombre del entregable ya no se deduce del nombre del libro: lleva la versión y
# la fecha, que hay que resolver leyendo el _quarto.yml y git.
#
# Cualquier opción que se pase a `quarto render` hay que ponerla en las DOS
# recetas, la del PDF y la del EPUB. Nueve EPUB se publicaron con los shortcodes
# del colofón sin resolver por añadir --metadata sólo a una.
define reglas_de_libro
$(call pdf_de,$(1)): $(1)/index.qmd
	@mkdir -p $(PDF_OUT)
	@echo "==> [Quarto] Renderizando PDF (Typst) para $(1)..."
	quarto render $(1)/ --to orange-book-es-typst \
	  --metadata fecha-actualizacion="$$(call fecha_libro,$(1))" \
	  --metadata version-quarto="$$(call version_quarto)" \
	  --metadata estado="$$(call estado_libro,$(1))" \
	  --metadata estado-nota="$$(call nota_libro,$(1))"
	@mv $(1)/_book/*.pdf $$@
	@echo "✓ PDF generado en $$@"

$(call epub_de,$(1)): $(1)/index.qmd
	@mkdir -p $(EPUB_OUT)
	@echo "==> [Quarto] Renderizando EPUB para $(1)..."
	quarto render $(1)/ --to epub \
	  --metadata fecha-actualizacion="$$(call fecha_libro,$(1))" \
	  --metadata version-quarto="$$(call version_quarto)" \
	  --metadata estado="$$(call estado_libro,$(1))" \
	  --metadata estado-nota="$$(call nota_libro,$(1))"
	@mv $(1)/_book/*.epub $$@
	@echo "✓ EPUB generado en $$@"

.PHONY: $(1)
$(1): $(call pdf_de,$(1)) $(call epub_de,$(1))
endef

$(foreach libro,$(LIBROS),$(eval $(call reglas_de_libro,$(libro))))

# --- UTILIDADES ---

# Imprime "libro|versión|estado" para los 9 libros, una línea por libro.
#
# Existe para que el guardián del README (y quien quiera consultarlo a mano) lea
# el estado de la MISMA fuente que lo inyecta en los entregables, en vez de
# reimplementar la deducción de `estado_libro` en otro sitio. Dos copias de esta
# regla acabarían divergiendo, y aquí las divergencias no dan error: compilan.
#
# Los libros completados salen con el estado literal "Completado"; internamente
# `estado_libro` devuelve la cadena vacía, que es lo que apaga la marca de agua
# y la nota, pero como texto no serviría.
.PHONY: estados
estados:
	@for libro in $(LIBROS); do \
		v="$(call version_libro,$$libro)"; \
		e="$(call estado_libro,$$libro)"; \
		echo "$$libro|$$v|$${e:-Completado}"; \
	done

# Limpieza de los entregables y las cachés de Quarto.
# NO toca los .qmd, _quarto.yml ni imagenes/: son la fuente canónica de la
# colección, viven en git y no se regeneran a partir de nada.
clean:
	rm -rf $(BUILD_DIR)
	@for libro in $(LIBROS); do \
		rm -rf $$libro/_book $$libro/.quarto; \
	done
