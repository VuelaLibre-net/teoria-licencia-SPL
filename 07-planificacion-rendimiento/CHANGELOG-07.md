# Registro de cambios — 07. Planificación y Rendimiento de Vuelo

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

### Cambiado

* **Glosario, entrada «FPL»** — se adopta la del libro 04, que detalla en qué espacios aéreos hace falta el plan de vuelo y qué datos incluye. Conserva la obligación en vuelos que cruzan frontera, que era lo propio de esta versión.
* **Glosario, entrada «FPL»** — se ancla en **SERA.4001 b)** y se añade el caso de las áreas o rutas designadas por la autoridad competente. El resto queda igual, verificado contra el Reglamento.

## [0.9.1] — 1 de agosto de 2026

**Qué releer:** **cap02, desplazamiento de la polar con el peso.** Se actualiza el gráfico explicativo del efecto del peso sobre la polar de velocidades (`07-cap02-polar-peso.png`).

### Cambiado

* **cap02** — regeneración y optimización visual del gráfico de desplazamiento de la curva polar según la carga y peso del planeador.

## [0.9.0] — 31 de julio de 2026

**Qué releer:** **cap01, datum y límites de peso y centrado; cap02, curva polar y sus tres figuras; cap03, triángulo FAI/AAT y ventana de convección; cap04, formulario FPL; cap05, monitoreo del planeo final.** Seis ilustraciones traducidas a español y unidades métricas, tres retiradas y una nueva.

### Cambiado

* **cap01, datum y momento** — la tabla de ejemplo estaba en inglés; ahora en español, mismos valores.
* **cap01, límites de peso y centrado** — la envolvente estaba en libras y en inglés; se sustituye por una en español y kilogramos.
* **cap02, curva polar** — se rehace con **tres** puntos numerados (1 pérdida, 2 mínimo descenso, 3 máximo planeo) en vez de dos con bocadillos en inglés, y en km/h y m/s en vez de nudos. Sigue el mismo criterio que la curva polar de 05-principios-vuelo. El pie pasa de «dos velocidades clave» a «tres velocidades clave».
* **cap02, desplazamiento de la polar con el peso** — tabla traducida a español, mismos valores (libras y nudos).
* **cap02, efecto del viento sobre la polar** — gráfico traducido a español y a km/h y m/s; se retira además un número residual superpuesto en la esquina que no pertenecía a la figura.
* **cap04, formulario de plan de vuelo** — sustituye el mockup «FIGURA PENDIENTE» por el formulario ICAO real, bilingüe (EN/ES) en cada casilla, cumplimentado con el mismo ejemplo que desarrolla el texto: casilla 8 (V, G), 9 (GLID), 15 (K0120, DCT VTC-1 DCT VTC-2 DCT), 16 (ZZZZ), 18 (DEST/AREA DE LA TAREA) y 19 (E/0430, P/1).

### Retirado

* **cap03, ventana de convección** — se retira la ilustración y su referencia; el texto que explica el concepto no cambia.
* **cap03, triángulo FAI frente a tarea AAT** — se retira la ilustración y su referencia; el texto de la sección (marcada «Más allá del examen») no cambia.
* **cap05, monitoreo del planeo final en 3 puntos** — se retira la ilustración y su referencia; el método de los tres puntos que explica el texto no cambia.

### Maqueta y producción

* **cap05, cono de alcance** — refinamiento artístico de la ilustración existente; mismo contenido.

## [0.8.9] — 28 de julio de 2026

**Qué releer:** **cap04, casillas 15 y 19 del plan de vuelo** (el apartado «Casillas clave» y la viñeta correspondiente del resumen). Se separa lo que exige el formulario de lo que hace el piloto de planeador. Lo que hay que escribir en cada casilla no cambia.

### Corregido

* **cap04, casilla 15** — el formulario **no pide la media de crucero**: el Apéndice 2 del Doc. 4444 de OACI dice «INSERT the **True airspeed** [...] expressed as K followed by 4 figures (e.g. K0830), or [...] N followed by 4 figures». La casilla pide TAS; lo que ocurre es que en un planeador la única cifra disponible de antemano es la media estimada de la tarea. Ahora el texto dice las dos cosas.
* **cap04, casilla 19** — `E/` es **autonomía de combustible**: «INSERT a 4-figure group giving the **fuel endurance** in hours and minutes». Anotar las horas de luz que quedan hasta la puesta de sol es un convenio del vuelo sin motor —el planeador puro no tiene combustible que declarar—, no una exigencia del formulario, y el libro lo daba por tal.

## [0.8.8] — 28 de julio de 2026

**Qué releer:** **Bibliografía.** Se incorporan dos fuentes que el libro ya venía aplicando sin citarlas. Ningún capítulo cambia.

### Añadido

* **Bibliografía** — **Doc. 4444 (PANS-ATM) de OACI**, cuyo **Apéndice 2** es el que fija el modelo de plan de vuelo y las instrucciones de cada casilla que explica `cap04` (K/N en la casilla 15, ZZZZ y DEST/ entre las casillas 16 y 18, E/ en la 19).
* **Bibliografía** — **Sporting Code Section 3 de la FAI** (Classes D & DM, edición 2025), que es donde están definidos el triángulo FAI y la tarea de área asignada (AAT) que describe `cap03`.

## [0.8.7] — 27 de julio de 2026

**Qué releer:** **cap01, cálculo de masa y centrado; cap02, efecto del peso sobre la polar; cap04, obligatoriedad del plan de vuelo.** Se retiran atribuciones concluyentes sobre qué contenido aparece en el examen. El contenido técnico no cambia.

### Cambiado

* **cap01** — los cálculos y ejercicios se presentan por su valor formativo, sin atribuirles frecuencia ni formato de examen.
* **cap02** — se conservan los tres efectos del peso sobre la polar sin afirmar que caen en el examen.
* **cap04** — se elimina la afirmación de que el vuelo VFR nocturno es pregunta de examen.

### Maqueta y producción

* **Maquetación Typst** — corrección del solapamiento en páginas de parte, ajuste de la marca de agua «En revisión» y ordenación del índice alfabético sin tildes.

## [0.8.6] — 22 de julio de 2026

**Qué releer:** **Glosario.** Se normalizan las referencias a capítulos en las definiciones. El temario no cambia.

### Cambiado

* **Glosario** — se eliminan las referencias redundantes a capítulos en las definiciones de términos y acrónimos.

## [0.8.5] — 19 de julio de 2026

**Qué releer:** **Preliminares, página de licencia.** Cambia el aviso de estado editorial. El temario no cambia.

### Maqueta y producción

* **Marca de agua** — «CREANDO ILUSTRACIONES» se compone ahora en dos líneas para evitar que la palabra se rompa.
* **Licencia** — el aviso de «Creando ilustraciones» añade «NO HA SIDO REVISADO» para dejar claro que el texto aún no ha pasado revisión técnica.

### Maqueta y producción

* **Créditos** — se añade un espaciado vertical (`v(1.5em)`) al bloque de créditos en la maquetación Typst para evitar que queden demasiado juntos con el contenido adyacente.
* **Colofón** — se homogeneiza el texto del colofón en todos los libros para que sea idéntico al de Derecho Aéreo, incluyendo la referencia dinámica al repositorio y el uso de Quarto y la extensión `orange-book-es`.
* **Índice alfabético** — generación automática de un índice de términos al final del libro para la versión PDF (Typst), utilizando el paquete `in-dexter` y referenciando los términos del glosario a 3 columnas.
* **Enlaces al glosario** — enlace automático en el PDF (Typst) de la primera aparición de cada término y acrónimo del glosario en el cuerpo de cada capítulo.
* **Glosario** — se eliminan las referencias redundantes a capítulos en las definiciones.

## [0.8.4] — 18 de julio de 2026

**Qué releer:** **Preliminares, página de licencia.** El temario no cambia.

### Cambiado

* **Licencia** — la mención institucional pasa de «avalado por AESA» a «temarios validados por
  AESA», siguiendo la formulación indicada por AESA.

## [0.8.3] — 18 de julio de 2026

**Qué releer:** **Preliminares, página de licencia.** Normalizadas las remisiones a otros libros en `cap01`. El temario no cambia.

### Cambiado

* **cap01** — referencias a otros libros: se completa el título donde antes solo aparecía el número.
* **Licencia** — el libro pasa a **CC BY-SA 4.0**: mantiene atribución y añade la
  obligación de compartir las adaptaciones bajo la misma licencia o una compatible.

## [0.8.2] — 17 de julio de 2026

**Qué releer:** **Los títulos tocados, el epígrafe y el alcance de las secciones marcadas; ni una
línea del temario.** El texto de los capítulos no cambia. Lo que cambia son decisiones editoriales
—la cita de apertura y qué queda señalado como ajeno al examen—, y se confirman en un minuto.

Los títulos de capítulo se comían el paréntesis en inglés que trae el syllabus. El syllabus es la
raíz del proyecto y el título copia su entrada; sólo se le aplica la norma española de mayúsculas y
los términos ingleses van en cursiva. El CI lo comprueba ahora en los 76 capítulos de la colección.

### Cambiado

* **Títulos de `cap02` y `cap04`** — «Polar de velocidades (*speed polar*) de planeadores o
  velocidad de crucero» y «Plan de vuelo ICAO (*ATS flight plan*)», como en el syllabus.
* **cap03, «Triángulo FAI y AAT: dos formas de competir»** — la sección queda marcada entera como
  «Más allá del examen», sobre fondo gris. Antes la marca era sólo una entradilla al principio y no
  se veía dónde acababa el material avanzado. El resumen del capítulo queda fuera del gris, como
  manda la convención: este material no se recoge en el post-it.
* **Epígrafe** — el libro abre ahora con una cita propia, de Alan Lakein,
  elegida para esta asignatura. Los 9 libros compartían la misma cita de Frank Borman,
  que además pertenece a Factores Humanos.

### Maqueta y producción

Nada de esto altera lo que el lector aprende; el revisor puede saltárselo.

* **Los post-it y los créditos se componían en serifa, no en palo seco.** Typst no empotra
  Libertinus Sans —sólo la Serif—, la fuente estaba en la máquina de desarrollo y no en el servidor
  que publica, y Typst no avisa cuando le falta una: compone con otra y sigue. Los PDF publicados
  llevaban meses así. Ahora la fuente viaja en el repositorio y el CI falla si alguna no llega.
  Cambia el aspecto de los resúmenes de capítulo y de los créditos; el texto no.
* **La página de créditos se rediseña.** Salía amontonada y con un tercio del papel en blanco
  debajo. No era la interlínea —135,8 %, dentro de la banda recomendada—: eran el cuerpo a 8,5 pt,
  los párrafos un 27 % más juntos que en el libro y, sobre todo, unos rótulos de sección que eran
  negrita suelta, sin nada que los separase del texto. Ahora los rótulos son encabezados de verdad
  (en el EPUB también se pueden estilar, que antes no), la licencia lleva su distintivo de Creative
  Commons y sus condiciones a dos columnas, la exención de responsabilidad va en un recuadro ámbar y
  el aval en uno gris. Sigue cabiendo en una página, y ahora el CI lo comprueba.
* **Se retira «Fuentes y agradecimientos» de la página de créditos.** No se pierde nada: la
  bibliografía ya acredita el *Glider Flying Handbook* de la FAA —y dice que es la fuente de buena
  parte de las ilustraciones—, y los reconocimientos ya acreditan a Iñaqui Ulibarri con sus
  credenciales. Era una duplicación, y es la que hacía que la página no cerrase.
* El índice, la lista de ilustraciones y la de tablas bajan de cuerpo. Estaban a 15/13/11/11 pt
  con el texto del libro a 10: hasta la subsección más profunda era mayor que lo que se lee.
* La banda azul de la portadilla crece si el título no cabe en una línea. Tenía altura fija y
  el título del libro 8 la desbordaba, dejando la nota de estado y la versión pisándose fuera
  del recuadro.
* Se normalizan los títulos de capítulos, secciones, portadillas y apéndices a la capitalización
  propia del español.
* Los entregables llevan ahora la versión y la fecha en el nombre
  (`07-planificacion-rendimiento-0.8.1-260716.pdf`), para identificarlos sin abrirlos.
* **Cada libro se publica también como un solo Markdown** (`make rag`, a
  `build/rag/07-planificacion-rendimiento-0.8.1-260716.md`), para cargarlo como fuente en un
  asistente de estudio con recuperación (NotebookLM y similares). No es el libro en crudo: un RAG no
  ve la maqueta, sino trozos sueltos de texto, y cada trozo tiene que explicarse solo. Los recuadros
  conservan su etiqueta como texto, el resumen de cada capítulo pasa a ser un apartado propio, las
  referencias a figuras se resuelven a «figura 5.1» y las ilustraciones se sustituyen por su pie. El
  temario entra íntegro —capítulos, apéndices, glosario y bibliografía—; quedan fuera los
  preliminares, el colofón y la guía de lectura, que explica la maqueta y es idéntica en los nueve.
* Los EPUB se publicaban como **XHTML mal formado**: unos comentarios del CSS abrían etiquetas que
  nunca cerraban y un lector estricto podía rechazarlos. Corregido, y el CI lo comprueba ahora.
* Cada libro abre con su propia cita, así que el guardián que exigía epígrafes idénticos se ha
  invertido: ahora exige que los 9 sean distintos.

### Estado en esta versión

* 5 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **Creando ilustraciones**, deducido de la versión 0.8.2.
* El texto está completo; faltan ilustraciones. La marca de agua lo advierte en cada página.

## [0.8.1] — 16 de julio de 2026

Versión base del registro. Lo anterior a esta fecha no está detallado entrada por entrada: el libro
se escribió antes de que existiera este fichero.

**Qué releer:** **Nada todavía.** El libro aún no ha entrado en revisión técnica (estado: Creando ilustraciones). Este registro empieza a contar desde aquí.

### Estado en esta versión

* 5 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **Creando ilustraciones**, deducido de la versión 0.8.1.
* El texto está completo; faltan ilustraciones. La marca de agua lo advierte en cada página.
