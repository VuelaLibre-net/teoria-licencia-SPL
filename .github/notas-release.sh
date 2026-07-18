#!/usr/bin/env bash
# Genera el cuerpo de la release a partir de `make estados`, la única fuente
# de verdad de qué versión y qué estado tiene cada libro.
#
# Sólo emite lo DERIVABLE: la tabla de los nueve, el aviso de marca de agua, cómo
# descargar y la licencia. El «qué ha cambiado» de cada versión lo escribe una
# persona —un guión no lo puede inventar—, así que deja un hueco marcado. La
# release se crea en borrador para que se rellene antes de publicar.
#
# Uso: notas-release.sh <tag>   (p. ej. v0.9.0). Escribe el markdown a stdout.
set -euo pipefail

tag=${1:?falta el tag}

# estado editorial -> emoji y frase, como en el README. Es una copia, pero el
# guardián de la tabla del README ya obliga a que README y `make estados`
# concuerden, así que la fuente de la que esto copia está vigilada.
emoji_de() {
  case "$1" in
    "En revisión")           echo "🟡" ;;
    "Creando ilustraciones") echo "🎨" ;;
    "En desarrollo")         echo "🚧" ;;
    *)                       echo "✅" ;;   # Completado
  esac
}

titulo_de() {
  sed -n 's/^  title: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/p' "$1/_quarto.yml" | head -1
}

estados=$(make -s estados)
[ "$(printf '%s\n' "$estados" | wc -l)" -eq 9 ] \
  || { echo "notas-release.sh: make estados no devolvió 9 libros" >&2; exit 1; }

cat <<'CABECERA'
Los 9 manuales del temario teórico de la Licencia de Piloto de Planeador (SPL), conforme al syllabus AMC1 SFCL.130 (EASA-FCL) y adaptado a los requerimientos de AESA.

Cada asignatura, en tres formatos —PDF, EPUB y Markdown para asistentes de estudio—, descargable directamente y sin cuenta de GitHub. El nombre de cada fichero lleva la asignatura, su versión y su fecha, así que se identifica sin abrirlo.

## ⚠️ Ninguno de estos libros está terminado

Cada libro lleva **marca de agua en cada página** y una nota en la portadilla con su estado. No es un descuido: es la información más importante de esta entrega.

| # | Libro | Versión | Estado |
| --- | --- | --- | --- |
CABECERA

n=0
while IFS='|' read -r libro version estado; do
  n=$((n + 1))
  printf '| %d | %s | `%s` | %s %s |\n' "$n" "$(titulo_de "$libro")" "$version" "$(emoji_de "$estado")" "$estado"
done <<<"$estados"

cat <<'PIE'

**En revisión**: el texto está completo, pendiente de revisión técnica por instructores. **Creando ilustraciones**: el texto está completo y faltan ilustraciones.

Este manual es una **herramienta de apoyo al estudio**. No sustituye a la instrucción teórica ni a la práctica obligatoria con un instructor de vuelo cualificado, y ante cualquier discrepancia prevalece el texto legal de AESA o EASA.

## Qué ha cambiado en esta versión

<!-- ↓↓↓ ESCRIBE AQUÍ antes de publicar. La release está en borrador justamente para esto.
     Resume lo que un lector nota respecto a la versión anterior; el detalle está en cada
     <libro>/CHANGELOG-NN.md, en la línea «Qué releer». Borra este comentario al terminar. -->

## Licencia

**CC BY-SA 4.0.** Puedes copiar, redistribuir y adaptar, incluso comercialmente, citando la autoría y compartiendo las adaptaciones bajo la misma licencia o una compatible. El programa de la colección está avalado por AESA; el desarrollo del contenido es responsabilidad exclusiva de los autores.
PIE
