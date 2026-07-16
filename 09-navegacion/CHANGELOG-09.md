# Registro de cambios — 09. Navegación

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

**Qué releer:** **El epígrafe y el alcance de las secciones marcadas; ni una línea del temario.** El
texto de los capítulos no cambia. Lo que cambia es la cita con la que abre el libro y qué queda
señalado como ajeno al examen: las dos son decisiones editoriales, y se confirman en un minuto.

### Cambiado

* **cap06, «Los Registradores IGC (Loggers)»** — la sección queda marcada entera como «Más allá del
  examen», sobre fondo gris. Antes la marca era sólo una entradilla al principio y no se veía dónde
  acababa el material avanzado. El resumen del capítulo queda fuera del gris, como manda la
  convención: este material no se recoge en el post-it.
* **Epígrafe** — el libro abre ahora con una cita propia, de Séneca,
  elegida para esta asignatura. Los 9 libros compartían la misma cita de Frank Borman,
  que además pertenece a Factores Humanos.

### Maqueta y producción

Nada de esto altera lo que el lector aprende; el revisor puede saltárselo.

* Los entregables llevan ahora la versión y la fecha en el nombre
  (`09-navegacion-0.8.1-26-07-16.pdf`), para identificarlos sin abrirlos.
* Los EPUB se publicaban como **XHTML mal formado**: unos comentarios del CSS abrían etiquetas que
  nunca cerraban y un lector estricto podía rechazarlos. Corregido, y el CI lo comprueba ahora.
* Cada libro abre con su propia cita, así que el guardián que exigía epígrafes idénticos se ha
  invertido: ahora exige que los 9 sean distintos.

## [0.8.1] — 16 de julio de 2026

Versión base del registro. Lo anterior a esta fecha no está detallado entrada por entrada: el libro
se escribió antes de que existiera este fichero.

**Qué releer:** **Nada todavía.** El libro aún no ha entrado en revisión técnica (estado: Creando ilustraciones). Este registro empieza a contar desde aquí.

### Estado en esta versión

* 7 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **Creando ilustraciones**, deducido de la versión 0.8.1.
* El texto está completo; faltan ilustraciones. La marca de agua lo advierte en cada página.
