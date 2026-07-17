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

Sin cambios desde la 1.0-rc.6.

## [1.0-rc.6] — 17 de julio de 2026

**Qué releer:** **El `cap08` entero, más los títulos tocados y el epígrafe.** El resto del temario no
cambia ni una línea.

El `cap08` sí: estrena un apartado sobre **Gestión del Tránsito Aéreo (ATM)** que antes no existía.
El syllabus 1.8 lo pide junto al ATS y el capítulo sólo desarrollaba el ATS —tampoco lo hacía el
AsciiDoc del que viene: «ATM» aparecía en toda la colección únicamente en esa línea del syllabus—.
**Es contenido nuevo y necesita revisión técnica**, no sólo de estilo.

Los títulos de capítulo se comían el paréntesis en inglés que trae el syllabus. El syllabus es la
raíz del proyecto y el título copia su entrada; sólo se le aplica la norma española de mayúsculas y
los términos ingleses van en cursiva. El CI lo comprueba ahora en los 76 capítulos de la colección.

### Cambiado

* **Título del libro** — recupera el «(ATC)» que su cubierta y su apéndice ya llevaban:
  «Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (ATC)».
* **Títulos de `cap02`, `cap08`, `cap11` y `cap12`** — pasan a decir lo que dice el syllabus:
  «Aeronavegabilidad (*airworthiness*) de aeronaves», «Búsqueda y salvamento (*search and
  rescue*)», «Seguridad (*security*)». El `cap08` conserva su texto y sólo ajusta las
  mayúsculas a la norma española.
* **cap08, «Servicio de Tránsito Aéreo (ATS) y Gestión del Tránsito Aéreo (ATM)»** — el título
  estaba truncado en «Servicio de Tránsito Aéreo (»: el importador de AsciiDoc se atragantó con las
  macros que iban dentro del paréntesis. Ahora es **idéntico a la entrada 1.8 del syllabus**, con sus
  mayúsculas: el syllabus es la raíz del proyecto y el título lo copia, no al revés.
* **cap08, apartado nuevo «La gestión del tránsito aéreo (ATM)»** — el capítulo cubre ya lo que su
  título promete: qué es el ATM y sus tres patas (ATS, ASM y ATFM), el concepto de uso flexible del
  espacio aéreo (FUA) con sus tres niveles y las estructuras que sólo existen a ratos (TSA, TRA,
  CDR), y la gestión de afluencia (ATFM), que no afecta a un planeador en Clase G. El resumen del
  capítulo lo recoge.
* **Epígrafe** — el libro abre ahora con una cita propia, de un anónimo de la tradición oral de la
  seguridad aérea, elegida para esta asignatura. Los 9 libros compartían la misma cita de Frank
  Borman, que además pertenece a Factores Humanos.

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
  (`01-derecho-aereo-atc-1.0-rc.5-260716.pdf`), para identificarlos sin abrirlos.
* **Cada libro se publica también como un solo Markdown** (`make rag`, a
  `build/rag/01-derecho-aereo-atc-1.0-rc.5-260716.md`), para cargarlo como fuente en un asistente de
  estudio con recuperación (NotebookLM y similares). No es el libro en crudo: un RAG no ve la
  maqueta, sino trozos sueltos de texto, y cada trozo tiene que explicarse solo. Los recuadros
  conservan su etiqueta como texto, el resumen de cada capítulo pasa a ser un apartado propio, las
  referencias a figuras se resuelven a «figura 5.1» y las ilustraciones se sustituyen por su pie. El
  temario entra íntegro —capítulos, apéndices, glosario y bibliografía—; quedan fuera los
  preliminares, el colofón y la guía de lectura, que explica la maqueta y es idéntica en los nueve.
* Los EPUB se publicaban como **XHTML mal formado**: unos comentarios del CSS abrían etiquetas que
  nunca cerraban y un lector estricto podía rechazarlos. Corregido, y el CI lo comprueba ahora.
* Cada libro abre con su propia cita, así que el guardián que exigía epígrafes idénticos se ha
  invertido: ahora exige que los 9 sean distintos.

### Estado en esta versión

* 14 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **En revisión**, deducido de la versión 1.0-rc.6.
* La marca de agua y el aviso del EPUB desaparecen solos al pasar a `1.0.0`.

## [1.0-rc.5] — 16 de julio de 2026

Versión base del registro. Lo anterior a esta fecha no está detallado entrada por entrada: el libro
se escribió antes de que existiera este fichero.

**Qué releer:** **Todo el temario.** Es la primera revisión técnica completa del libro: no hay una versión revisada anterior con la que comparar.

### Estado en esta versión

* 14 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **En revisión**, deducido de la versión 1.0-rc.5.
* La marca de agua y el aviso del EPUB desaparecen solos al pasar a `1.0.0`.
