# Contribuir a los manuales SPL

Gracias por ayudar a mejorar esta colección. El objetivo del repositorio es publicar manuales teóricos SPL claros, verificables y fáciles de mantener.

## Antes de abrir una issue

Usa el formulario **Corrección o mejora de un libro**. Incluye siempre:

- Libro afectado.
- Capítulo, sección, página, figura o tabla.
- Tipo de mejora: ortografía, formato, técnica, normativa, didáctica u otra.
- Texto actual en `Donde dice`.
- Texto propuesto en `Debería decir`.
- Fuente o referencia si el cambio es técnico, legal o reglamentario.

Si el reporte no tiene información suficiente, se marcará con `needs info` hasta que pueda revisarse.

## Etiquetas

Las issues creadas desde el formulario reciben automáticamente `contenido` y `needs triage`. Después de revisarlas se pueden ajustar con estas etiquetas:

- `ortografia`: erratas y correcciones gramaticales.
- `formato`: maquetación, PDF, EPUB o Markdown/RAG.
- `tecnica`: teoría, procedimientos o seguridad de vuelo.
- `normativa`: leyes, reglamentos o referencias oficiales.
- `didactica`: claridad, estructura o explicación para el alumno.
- `needs info`: falta información para poder actuar.
- `high priority`: error crítico o urgente.
- `help wanted`: tarea abierta a colaboración externa.
- `good first issue`: tarea acotada para nuevos colaboradores.

## Preparar el entorno local

Necesitas Quarto CLI 1.9.17 o superior. Para reproducir los PDF oficiales usa también Typst 0.15 y exporta el binario antes de compilar:

```bash
export QUARTO_TYPST="$(which typst)"
```

Comandos útiles:

```bash
make                       # Compila los 9 libros: PDF, EPUB y Markdown/RAG
make 05-principios-vuelo   # Compila un solo libro
make rag                   # Sólo Markdown/RAG
make clean                 # Borra entregables y cachés, no toca los .qmd
```

## Cómo editar contenido

Los ficheros `.qmd` de cada libro son la fuente canónica. No se generan desde otro formato.

Reglas editoriales importantes:

- Mantener el texto, los comentarios y los commits en español.
- Usar solo referencias cruzadas `@fig-...` y `@tbl-...`.
- No usar `@cap-...`, `@sec-...` ni `@glos-...`.
- Los IDs de figuras y tablas deben empezar por `fig-` o `tbl-`.
- No cambiar la estructura de preliminares sin revisar la maqueta PDF y EPUB.
- Si cambias contenido de un libro, actualiza su `CHANGELOG-NN.md` con una línea clara de `Qué releer`.

## Pull requests

Un Pull Request debe ser pequeño y revisable. Incluye:

- Qué libro y capítulo cambia.
- Qué problema corrige.
- Qué fuente justifica el cambio, si es técnico o normativo.
- Qué comando de verificación has ejecutado.

Antes de pedir revisión, compila al menos el libro afectado:

```bash
make 09-navegacion
```

Si el cambio afecta a la extensión de maquetado o al Makefile, ejecuta una compilación más amplia o explica por qué no lo has hecho.

## Estilo de los cambios

Preferimos cambios mínimos, concretos y fáciles de revisar. No reescribas un capítulo entero para corregir una errata. No mezcles cambios de contenido, formato y normativa en un mismo PR si pueden separarse.

Para correcciones normativas o técnicas, enlaza la fuente oficial siempre que sea posible.
