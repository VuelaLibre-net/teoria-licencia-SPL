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

## [0.9.3] — 4 de agosto de 2026

> **La ampliación más grande que ha tenido este libro.** Pasa de 6.800 a 15.200 palabras y de 7 a 15
> figuras, con 20 ejercicios resueltos y 4 tablas donde no había ninguna. Se mantiene en **En
> revisión**: el material es nuevo y todavía no lo ha visto un instructor. La `0.9.2` no llegó a
> publicarse; su contenido sale en esta versión.

**Qué releer:** **los siete capítulos.** El libro pasa de 6.800 a unas 14.800 palabras y de 7 a 15 figuras. Lo sustancial es nuevo, no reescrito: **20 ejercicios resueltos** repartidos por los siete capítulos, **cuatro tablas** (equivalencias de unidades en cap01, tablilla de desvíos en cap02, lecturas de carta en cap03 y servicios por clase de espacio aéreo en cap07) y tres apartados que no existían: **el computador de vuelo** (cap04), **el cono de alcance y el error deliberado** (cap05) y **la altitud geométrica del GNSS frente a la barométrica** (cap06). Si sólo vas a releer dos cosas: el cap04 entero y el apartado del cono de alcance del cap05, porque son los que traen cálculo nuevo.

### Añadido

* **Todos los capítulos — 20 ejercicios resueltos** en un bloque nuevo, `::: {.ejercicio}`. Enunciado con cifras, procedimiento paso a paso y resultado. Cubren cadena de rumbos en los dos sentidos, descomposición del viento, tramo completo de la planificación al ETA, recálculo de ETA en vuelo, regla del 1 en 60 con ángulo de cierre, alcance de planeo con viento y con fineza degradada, lectura de cuadrícula AMA, escala de carta, conversión de unidades, hora del ocaso, DOP y deducción del viento a partir del GNSS.
* **cap01 — tabla de equivalencias** (NM, km, sm, nudos, pies, grado de latitud) con sus atajos mentales; apartado sobre cómo se escriben y se leen las coordenadas; cifra concreta de la diferencia entre ortodrómica y loxodrómica (97 m en 500 km a 41º N); conversión local↔UTC.
* **cap02 — la tablilla de desvíos como tabla**, con las doce filas y la explicación de sus signos; el origen físico común de los dos errores dinámicos; la magnitud del error de viraje, del orden de la latitud del lugar.
* **cap03 — tabla de lecturas de carta** (zonas P/R/D, límites verticales, obstáculos, AMA, tendidos, parques eólicos); de dónde salen los 5 km y las 2,7 NM por centímetro; la preparación de la carta en tierra.
* **cap04 — apartado nuevo «El computador de vuelo»**: cara de cálculo y cara del viento con su procedimiento, y su relación con los ordenadores de planeo actuales. Separación explícita entre trayectoria y rumbo; la regla del reloj para descomponer el viento; distinción entre ETE y ETA; el **ángulo de cierre** en la regla del 1 en 60, que faltaba.
* **cap05 — apartado nuevo «El cono de alcance»** ($D = h \cdot L/D$, corregido por viento con el factor GS/TAS y con margen de llegada) y **«El error deliberado»**; cadencia de fijación de posición; el apartado del desvío. Se marca el reparto con el Libro 7, que conserva la polar, el seguimiento del planeo final y el punto de no retorno.
* **cap06 — la altitud del GNSS no es la del altímetro**: geométrica sobre el elipsoide frente a barométrica, con la advertencia de que los límites de espacio aéreo y la AMA se comprueban con el altímetro. La DOP como multiplicador del error.
* **cap07 — tabla de servicios por clase de espacio aéreo** al VFR, concordante con la del Libro 1, cap07; regla de uso del squawk y el riesgo de pasar por 7500 al girar las ruedas; el reloj del plan de vuelo en UTC.
* **cap03 y cap07 — las fuentes oficiales, con sus enlaces.** Aportación del instructor revisor. En cap03, de dónde se descarga la carta vigente ([https://aip.enaire.es/AIP/CartasInsigniaImpresas-es.html](https://aip.enaire.es/AIP/CartasInsigniaImpresas-es.html)) y por qué una carta vieja no avisa de que lo es. En cap07, apartado nuevo sobre qué es un NOTAM y dónde se consulta y se presenta el plan de vuelo: **Insignia VFR** de ENAIRE ([https://insigniavfr.enaire.es/](https://insigniavfr.enaire.es/)), con la advertencia de que las aplicaciones de planificación que todo el mundo usa **no son fuente oficial**. Son los primeros enlaces en el cuerpo de un capítulo de la colección; siguen el patrón de `bibliografia.qmd`, que imprime la URL para que sirva también en papel.
* **Glosario** — diez entradas nuevas: AIP y NOTAM (copiadas literales del libro 1), altitud geométrica, coeficiente de planeo (copiada literal de los libros 5 y 7), componente cruzada, computador de vuelo, cono de alcance, error deliberado, ETA y ETE. De 53 a 63.

### Cambiado

* **cap01, cap04 y cap05 — sustituidas las tres ilustraciones provisionales** que seguían pendientes desde la auditoría de julio (`09-cap01-coordenadas`, `09-cap04-triangulo-viento`, `09-cap05-triangulacion`). El triángulo de velocidades va ahora **acotado en km/h y en nudos**, que era lo que pedía el informe.
* **cap02 — el error de viraje** deja de ser sólo cualitativo: se añade su magnitud aproximada y el procedimiento de nivelar y ajustar después.

### Maqueta y producción

* **Bloque `.ejercicio` nuevo** en los cuatro entregables: `ejercicio.typ` para el PDF, `epub-estilos.html` para el EPUB, `tools/rag/rag.lua` para el Markdown de RAG —donde cada ejercicio se asciende a apartado propio para que el troceador lo recupere entero— y `book-web.css` en el repositorio del sitio. No es un quinto recuadro del temario: la taxonomía de cuatro títulos no se toca.
* **Ocho figuras nuevas y dos sustituidas**, generadas por código desde `tools/figuras/`, con la paleta y la tipografía de `GUIA_ILUSTRACIONES.md`. Se estrena `09-navegacion/prompts/` con una ficha por figura.
* **Guardián nuevo en el CI**: el número de bloques `.ejercicio` de los `.qmd` debe coincidir con el de apartados del Markdown para RAG. Se amplía también la lista de TeX crudo vigilado.
* **Los decimales de las fórmulas, corregidos.** `0{,}75` llegaba a Typst como `0 comma 75`, y `comma` es un operador que compone con espacio detrás: los 67 decimales de la colección salían impresos como «0, 75». Ahora se escriben `\text{0,75}`, que Typst compone pegado. Afecta también al libro 07.
* **`\mathbf` se colaba sin traducir en el Markdown para RAG** —23 veces— porque no estaba en la lista de TeX crudo que vigila el CI. Traducido en el filtro y añadido al guardián, junto con `\mathit` y `\quad`.
* **Las matemáticas del paquete web, en MathML.** Quarto las emitía en TeX crudo y cargaba MathJax desde un CDN; el sitio publica el cuerpo de la página dentro de su propia plantilla, así que ese script nunca llegaba y el lector veía el TeX. Ahora las resuelve pandoc al compilar y el paquete queda autocontenido.

## [0.9.1] — 2 de agosto de 2026

**Qué releer:** **Glosario, entradas «IGC», «Espacio aéreo controlado» y «FPL».** El fichero `.igc` no es «infalsificable»: la firma hace detectable la manipulación. «Espacio aéreo controlado» sólo hablaba de las clases C y D: añade la A, donde no se admite VFR, y la B.

### Cambiado

* **Glosario, entradas «FPL», «IAS» y «Squawk»** — «FPL» adopta la del libro 04, que detalla espacios aéreos y contenido del plan, sin perder la obligación en vuelos que cruzan frontera. «IAS» conserva el encadenado IAS → TAS → GS y añade la referencia a los límites aerodinámicos del libro 03. En «Squawk», el 7600 se glosa como «fallo de radio, NORDO».
* **Glosario, entrada «FPL»** — se ancla en **SERA.4001 b)** y se añade el caso de las áreas o rutas designadas por la autoridad competente. El resto queda igual, verificado contra el Reglamento.
* **Glosario, rótulos de `SERA` y `Transpondedor`** — `SERA` pone el español delante, como el libro 01; `Transpondedor` recoge la sigla XPDR, que sólo estaba en el libro 04.
* **Glosario, rótulos de `AMA`, `DOP`, `GNSS` y `GPS`** — completan el par español/inglés. `GNSS` y `GPS` estaban cada uno en un idioma distinto siendo entradas contiguas.

### Corregido

* **Glosario, entrada «IGC»** — el fichero `.igc` no es «infalsificable»: la firma digital hace **detectable** cualquier manipulación, que es una propiedad distinta y más modesta.
* **Glosario, entrada «Espacio aéreo controlado»** — sólo hablaba de las clases C y D. Añade que en clase A no se admite VFR y que la clase B también exige autorización, con la nota de que en España no se emplea.
## [0.9.0] — 1 de agosto de 2026

**Qué releer:** **cap01, cap02, cap04, cap05, cap06 y cap07.** Se incorporan e integran nuevas ilustraciones y gráficos en español para coordenadas, tablilla de desvíos, triángulo de viento, triangulación, dispositivo GNSS en cabina e interacción con ATC/ATS, y se aclara la responsabilidad del PIC en aeródromos no controlados.

### Añadido

* **cap01, cap02, cap04, cap05, cap06, cap07** — sustitución e integración de nuevas ilustraciones técnicas en español (`09-cap01-coordenadas.jpg`, `09-cap02-tablilla-desvios.jpg`, `09-cap04-triangulo-viento.jpg`, `09-cap05-triangulacion.jpg`, `09-cap06-gnss-cabina.jpg`, `09-cap07-atc.jpg`).
* **cap07** — precisión sobre la responsabilidad del PIC respecto a las decisiones en aeródromos no controlados aun contando con servicios de información.

### Estado en esta versión

* 7 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **En revisión**, deducido de la versión 0.9.0.
* El texto y las ilustraciones principales están completos; pasa a fase de revisión técnica.

## [0.8.8] — 29 de julio de 2026

**Qué releer:** **cap04, terminología de la brújula**, y **cap01 y cap03, sus resúmenes.** Se matizan dos afirmaciones que el postit daba
como absolutas y el cuerpo del capítulo ya enunciaba con más precisión: la equivalencia entre minuto
de latitud y milla náutica, y la relación entre línea recta y ortodrómica en la proyección Lambert.
No cambia ningún dato: cambia el grado de certeza con que se enuncian.

### Cambiado

* **cap04** — corregido un falso amigo: *compass* se había traducido como «compás», que en español
  es el instrumento de dibujo. El instrumento magnético es la **brújula**, y así lo llama el resto
  del libro (el cap02 se titula «Magnetismo y brújulas»). Afecta al enunciado y a la solución del
  ejercicio 1, a la regla nemotécnica —ahora «Oeste, la brújula marca de más», que pierde la rima
  con «compás»— y al resumen, donde **CH** pasa a leerse «Rumbo de Brújula».
* **cap01** — el resumen decía «1 minuto de Latitud es **siempre** 1 Milla Náutica». Ahora dice que
  **equivale** a 1 NM y explica por qué: la milla náutica se definió como el minuto de arco de
  meridiano. Misma precisión en la entradilla de objetivos y en el cuerpo del capítulo.
* **cap03** — el resumen decía «una línea recta **es** una ortodrómica». Ahora dice que **se
  aproxima mucho** a una ortodrómica, que es lo que ya afirmaba el cuerpo del capítulo («se aproxima
  mucho a un círculo máximo»).

## [0.8.7] — 27 de julio de 2026

**Qué releer:** **cap04, cadena de rumbos y ejercicios.** Se retiran atribuciones concluyentes sobre bancos y tipos de preguntas de examen. El contenido técnico no cambia.

### Cambiado

* **cap04** — se conservan las notaciones alternativas y los ejercicios de estima sin atribuirlos a bancos ni preguntas de examen.

### Maqueta y producción

* **Maquetación Typst** — corrección del solapamiento en páginas de parte, ajuste de la marca de agua «En revisión» y ordenación del índice alfabético sin tildes.

## [0.8.6] — 22 de julio de 2026

**Qué releer:** **Glosario.** Se normalizan las referencias a capítulos en las definiciones. El temario no cambia.

### Cambiado

* **Glosario** — se eliminan las referencias redundantes a capítulos en las definiciones de términos y acrónimos.

## [0.8.5] — 19 de julio de 2026

**Qué releer:** **cap04, navegación por estima.** Se restauran las fórmulas de rumbos, deriva, velocidad suelo y tiempo que la migración dejó duplicadas o eliminó. **Preliminares, página de licencia.** Cambia el aviso de estado editorial.

### Cambiado

* **cap04** — las fórmulas `stem` originales se restituyen como matemáticas Quarto: cadena TC→TH→MH→CH, ejemplo de variación y desvío, componentes del viento, deriva, velocidad suelo, tiempo/distancia/velocidad y resumen.

### Maqueta y producción

* **Marca de agua** — «CREANDO ILUSTRACIONES» se compone ahora en dos líneas para evitar que la palabra se rompa.
* **Licencia** — el aviso de «Creando ilustraciones» añade «NO HA SIDO REVISADO» para dejar claro que el texto aún no ha pasado revisión técnica.
* **Post-it** — se cambia `text()` por `set text` para que las matemáticas dentro de los post-it funcionen con el motor matemático de Typst.
* **RAG** — se añade un filtro `Math` en `rag.lua` que convierte las fórmulas TeX a texto legible en el Markdown para RAG.

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

**Qué releer:** **Glosario:** 8 definiciones alineadas con el libro 1. **Preliminares, página de licencia.** Normalizadas las remisiones a otros libros en `cap04` y `cap07`. El temario no cambia.

### Cambiado

* **cap04**, **cap07** — referencias a otros libros: se completa el título donde antes solo aparecía el número.
* **Glosario** — 8 definiciones (AGL, AMSL, ATC, ATS, EOBT, FIS, SERA, TMZ) normalizadas con el glosario canónico del libro 1; retiradas las etiquetas `(Mencionado en: ...)`.
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

* **Título de `cap04`** — «Navegación por estima (*dead reckoning*)», como en el syllabus.
* **cap06, «Los Registradores IGC (Loggers)»** — la sección queda marcada entera como «Más allá del
  examen», sobre fondo gris. Antes la marca era sólo una entradilla al principio y no se veía dónde
  acababa el material avanzado. El resumen del capítulo queda fuera del gris, como manda la
  convención: este material no se recoge en el post-it.
* **Epígrafe** — el libro abre ahora con una cita propia, de Séneca,
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
  (`09-navegacion-0.8.1-260716.pdf`), para identificarlos sin abrirlos.
* **Cada libro se publica también como un solo Markdown** (`make rag`, a
  `build/rag/09-navegacion-0.8.1-260716.md`), para cargarlo como fuente en un asistente de estudio
  con recuperación (NotebookLM y similares). No es el libro en crudo: un RAG no ve la maqueta, sino
  trozos sueltos de texto, y cada trozo tiene que explicarse solo. Los recuadros conservan su
  etiqueta como texto, el resumen de cada capítulo pasa a ser un apartado propio, las referencias a
  figuras se resuelven a «figura 5.1» y las ilustraciones se sustituyen por su pie. El temario entra
  íntegro —capítulos, apéndices, glosario y bibliografía—; quedan fuera los preliminares, el colofón
  y la guía de lectura, que explica la maqueta y es idéntica en los nueve.
* Los EPUB se publicaban como **XHTML mal formado**: unos comentarios del CSS abrían etiquetas que
  nunca cerraban y un lector estricto podía rechazarlos. Corregido, y el CI lo comprueba ahora.
* Cada libro abre con su propia cita, así que el guardián que exigía epígrafes idénticos se ha
  invertido: ahora exige que los 9 sean distintos.

### Estado en esta versión

* 7 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **Creando ilustraciones**, deducido de la versión 0.8.2.
* El texto está completo; faltan ilustraciones. La marca de agua lo advierte en cada página.

## [0.8.1] — 16 de julio de 2026

Versión base del registro. Lo anterior a esta fecha no está detallado entrada por entrada: el libro
se escribió antes de que existiera este fichero.

**Qué releer:** **Nada todavía.** El libro aún no ha entrado en revisión técnica (estado: Creando ilustraciones). Este registro empieza a contar desde aquí.

### Estado en esta versión

* 7 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **Creando ilustraciones**, deducido de la versión 0.8.1.
* El texto está completo; faltan ilustraciones. La marca de agua lo advierte en cada página.
