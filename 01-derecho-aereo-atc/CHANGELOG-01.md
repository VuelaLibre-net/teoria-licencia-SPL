# Registro de cambios — 01. Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo

Este registro existe para que **un revisor no tenga que releer el libro entero**. Cada entrada dice
qué cambió, en qué capítulo, y si el cambio toca el contenido técnico o sólo la maqueta.

**Cómo leerlo si vas a revisar:** ve a la entrada de la versión que revisaste por última vez y lee
sólo las líneas "Qué releer" de las entradas posteriores. Si no revisaste ninguna, empieza por la
más antigua.

**Cómo escribirlo si cambias algo:** añade la línea bajo la versión en curso, nombrando el capítulo
(`cap07`, "Glosario", "Preliminares"). Un cambio que no altere lo que el lector aprende va en
*Maqueta y producción*, que el revisor puede saltarse. La versión sale de `version:` en
`_quarto.yml`, y de ella el estado editorial del libro (ver el README de la colección). **El CI
exige que la versión en curso tenga su entrada aquí**: subir la versión sin registrar qué cambió
rompe la compilación.

## [En curso]

Cambios ya en `main` —y por tanto en los entregables que compila el CI— a los que todavía no se les
ha asignado número: el `version:` de `_quarto.yml` no se ha movido.

**Qué releer:** **El título del `cap08` y el epígrafe.** El cuerpo del temario no cambia ni una
línea. Pero al arreglar el título salió a la luz un hueco que conviene decidir antes de dar el libro
por revisado: **el syllabus 1.8 pide «Servicio de Tránsito Aéreo (ATS) **y Gestión del Tránsito
Aéreo (ATM)**» y el capítulo sólo desarrolla el ATS.** En toda la colección, «ATM» aparece
únicamente en esa línea del syllabus.

### Cambiado

* **cap08, «Servicio de tránsito aéreo (ATS)»** — el título estaba truncado en «Servicio de Tránsito
  Aéreo (»: el importador de AsciiDoc se atragantó con las macros que iban dentro del paréntesis. El
  original rezaba «…(ATS) y Gestión del Tránsito Aéreo (ATM)», pero **ese `.adoc` tampoco tenía
  contenido de ATM**, así que el nuevo título describe lo que el capítulo da en vez de prometer lo
  que no da. Se pasa a sentence case, como los otros 13 títulos del libro.
* **Epígrafe** — el libro abre ahora con una cita propia, de un anónimo de la tradición oral de la
  seguridad aérea, elegida para esta asignatura. Los 9 libros compartían la misma cita de Frank
  Borman, que además pertenece a Factores Humanos.

### Hueco conocido

* **cap08 no cubre la Gestión del Tránsito Aéreo (ATM)**, que el syllabus 1.8 incluye junto al ATS.
  No es una pérdida de la migración: el AsciiDoc del que viene tampoco lo trataba. Requiere decidir
  si se escribe la parte de ATM o si el syllabus del apéndice se matiza.

### Maqueta y producción

Nada de esto altera lo que el lector aprende; el revisor puede saltárselo.

* Los entregables llevan ahora la versión y la fecha en el nombre
  (`01-derecho-aereo-atc-1.0-rc.5-26-07-16.pdf`), para identificarlos sin abrirlos.
* Los EPUB se publicaban como **XHTML mal formado**: unos comentarios del CSS abrían etiquetas que
  nunca cerraban y un lector estricto podía rechazarlos. Corregido, y el CI lo comprueba ahora.
* Cada libro abre con su propia cita, así que el guardián que exigía epígrafes idénticos se ha
  invertido: ahora exige que los 9 sean distintos.

## [1.0-rc.5] — 16 de julio de 2026

Versión base del registro. Lo anterior a esta fecha no está detallado entrada por entrada: el libro
se escribió antes de que existiera este fichero.

**Qué releer:** **Todo el temario.** Es la primera revisión técnica completa del libro: no hay una versión revisada anterior con la que comparar.

### Estado en esta versión

* 14 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **En revisión**, deducido de la versión 1.0-rc.5.
* La marca de agua y el aviso del EPUB desaparecen solos al pasar a `1.0.0`.
