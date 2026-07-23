#!/bin/sh
# Construye el entregable RAG de UN libro: un solo Markdown con todo su
# contenido, pensado para cargarlo como fuente en NotebookLM y similares.
#
# Uso:  construir.sh <libro> <version> <fecha> <estado> <numero> <salida.md>
#
# No deduce nada por su cuenta: versión, fecha y estado se los pasa el Makefile,
# que es la única fuente legítima (el estado sale de `estado_libro`, y
# reimplementarlo aquí acabaría divergiendo sin dar error).
#
# Por qué esto y no `quarto render --to commonmark`: Quarto NO soporta ese
# formato en proyectos de libro. Avisa por stderr, lista los ficheros como si
# trabajara, sale con 0 y no escribe ni un byte. Y pandoc a secas deja los
# recuadros como `<div class="callout-warning" title="Seguridad">`, con la
# etiqueta —lo único que importa de ese bloque— dentro de un atributo HTML.
set -eu

libro=$1; version=$2; fecha=$3; estado=$4; numero=$5; salida=$6

aqui=$(dirname "$0")
filtro=$aqui/rag.lua

config="$libro/_quarto.yml"
if [ "$libro" = "." ] && [ -f "recursos-completo/_quarto-completo.yml" ]; then
  config="recursos-completo/_quarto-completo.yml"
fi

[ -f "$config" ] || { echo "construir.sh: no existe $config" >&2; exit 1; }

titulo=$(sed -n 's/^  title: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/p' "$config" | head -1)
repo=$(sed -n 's/^repo-url: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/p' "$config" | head -1)

[ -n "$titulo" ] || { echo "construir.sh: $libro sin title en $config" >&2; exit 1; }

# Los ficheros y su orden salen de _quarto.yml, no de un glob: es lo que Quarto
# compone y así el RAG no se desincroniza del libro publicado. Se descartan los
# preliminares y el cierre —portadilla, créditos, dedicatoria, epígrafe,
# reconocimientos, colofón y contracubierta—: no son materia, y nueve copias
# casi idénticas en el índice sólo empeoran la recuperación.
#
# El rango va de `chapters:` a `format:` de una vez, y NO en dos tramos
# (chapters y appendices por separado): `appendices:` cae dentro del primer
# tramo, así que pedir los dos mete cada apéndice DOS veces en el entregable.
lista=$(sed -n '/^  chapters:/,/^format:/p' "$config" \
  | sed -n 's/^[[:space:]]*- \(.*\.qmd\)$/\1/p' \
  | grep -vxE '(.*/)?(index|licencia|dedicatoria|epigrafe|reconocimientos|colofon|contracubierta)\.qmd')

[ -n "$lista" ] || { echo "construir.sh: $libro no aportó ningún .qmd" >&2; exit 1; }

# Un fichero repetido no da error por sí solo: se concatena dos veces y el
# entregable sale con el apéndice duplicado, más gordo y en verde. Pasó de
# verdad al escribir el sed de arriba.
repetidos=$(echo "$lista" | sort | uniq -d)
[ -z "$repetidos" ] || { echo "construir.sh: $libro repite ficheros: $repetidos" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

{
  echo "# $titulo"
  echo
  echo "- **Colección:** Manuales teóricos de la licencia SPL de planeador (EASA/AESA)."
  echo "- **Asignatura:** tema $numero de 9."
  echo "- **Versión:** $version — actualizado el $fecha."
  echo "- **Estado editorial:** ${estado:-Completado}."
  [ -n "$repo" ] && echo "- **Origen:** $repo"
  echo
  echo "Documento generado a partir del libro para su indexado por herramientas de"
  echo "recuperación. Conserva el texto íntegro, sus recuadros —marcados con la"
  echo "etiqueta del temario: Seguridad, Normativa, Regla de oro, Airmanship— y el"
  echo "resumen de cada capítulo. Las ilustraciones no se incluyen; sí sus pies."
  echo
} > "$tmp/salida.md"

ncap=0
napendice=0
for f in $lista; do
  [ -f "$libro/$f" ] || { echo "construir.sh: $libro/$f no existe" >&2; exit 1; }
  nombre=${f##*/}

  # La etiqueta con la que se numeran capítulo, secciones y figuras: "5" para
  # el capítulo 5, "A" para el primer apéndice, vacía para lo que no numera.
  case "$nombre" in
    cap*)
      ncap=$((ncap + 1)); etiqueta=$ncap ;;
    apendice*|glosario.qmd|bibliografia.qmd)
      napendice=$((napendice + 1))
      etiqueta=$(echo "$napendice" | awk '{printf "%c", 64 + $1}') ;;
    *)
      etiqueta="" ;;
  esac

  entrada=$libro/$f
  # De introduccion.qmd sólo entra la cabecera: el gancho propio del libro. La
  # cola —la guía de lectura— es idéntica en los 9 y explica la maqueta, que el
  # RAG no ve; nueve copias sólo darían trozos duplicados que compiten entre sí.
  if [ "$nombre" = "introduccion.qmd" ]; then
    sed '/GUÍA-DE-LECTURA/,$d' "$entrada" > "$tmp/introduccion.qmd"
    entrada=$tmp/introduccion.qmd
  fi

  # `quarto pandoc`, no `pandoc`: el del sistema puede no estar —el runner del
  # CI no lo trae— y, si está, no tiene por qué ser el mismo. Quarto empotra el
  # suyo, así que aquí y en el CI compila el mismo binario. Es el mismo motivo
  # por el que QUARTO_TYPST se fija a mano para los otros dos entregables.
  quarto pandoc "$entrada" \
    --from=markdown \
    --to=gfm \
    --wrap=none \
    --lua-filter="$filtro" \
    --metadata=etiqueta="$etiqueta" \
    >> "$tmp/salida.md"
  echo >> "$tmp/salida.md"
done

mkdir -p "$(dirname "$salida")"
mv "$tmp/salida.md" "$salida"
