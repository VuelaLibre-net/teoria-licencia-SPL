# Registro de cambios — 08. Conocimientos Generales de la Aeronave

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

**Qué releer:** **cap04, pesaje y documentación.** Se retira una atribución concluyente sobre el formato del examen. El contenido técnico no cambia.

### Cambiado

* **cap04** — la remisión al ejemplo de masa y centrado del Libro 7 deja de presentarlo como ejemplo de examen.

### Maqueta y producción

* **Índice alfabético** — la ordenación española ignora las tildes y la diéresis de las vocales.

## [0.8.6] — 22 de julio de 2026

**Qué releer:** **Glosario.** Se normalizan las referencias a capítulos en las definiciones. El temario no cambia.

### Cambiado

* **Glosario** — se eliminan las referencias redundantes a capítulos en las definiciones de términos y acrónimos.

### Maqueta y producción

* **Créditos** — se añade un espaciado vertical (`v(1.5em)`) al bloque de créditos en la maquetación Typst para evitar que queden demasiado juntos con el contenido adyacente.
* **Colofón** — se homogeneiza el texto del colofón en todos los libros para que sea idéntico al de Derecho Aéreo, incluyendo la referencia dinámica al repositorio y el uso de Quarto y la extensión `orange-book-es`.
* **Índice alfabético** — generación automática de un índice de términos al final del libro para la versión PDF (Typst), utilizando el paquete `in-dexter` y referenciando los términos del glosario a 3 columnas.
* **Enlaces al glosario** — enlace automático en el PDF (Typst) de la primera aparición de cada término y acrónimo del glosario en el cuerpo de cada capítulo.

## [0.8.5] — 19 de julio de 2026

**Qué releer:** **Preliminares, página de licencia.** Cambia el aviso de estado editorial. El temario no cambia.

### Maqueta y producción

* **Marca de agua** — «CREANDO ILUSTRACIONES» se compone ahora en dos líneas para evitar que la palabra se rompa.
* **Licencia** — el aviso de «Creando ilustraciones» añade «NO HA SIDO REVISADO» para dejar claro que el texto aún no ha pasado revisión técnica.

## [0.8.4] — 18 de julio de 2026

**Qué releer:** **Preliminares, página de licencia.** El temario no cambia.

### Cambiado

* **Licencia** — la mención institucional pasa de «avalado por AESA» a «temarios validados por
  AESA», siguiendo la formulación indicada por AESA.

## [0.8.3] — 18 de julio de 2026

**Qué releer:** **Glosario:** 9 definiciones alineadas con el libro 1. **Preliminares, página de licencia.** Normalizadas las remisiones a otros libros en `cap04`, `cap06`, `cap09` y `cap11`. El temario no cambia.

### Cambiado

* **cap04**, **cap06**, **cap09**, **cap11** — referencias a otros libros: se completa el título donde antes solo aparecía el número.
* **Glosario** — 9 definiciones (AD, AFM, ARC, CoA, CS-22, ELT, Part-ML, SB, TMG) normalizadas con el glosario canónico del libro 1; retiradas las etiquetas `(Mencionado en: ...)`.
* **Licencia** — el libro pasa a **CC BY-SA 4.0**: mantiene atribución y añade la
  obligación de compartir las adaptaciones bajo la misma licencia o una compatible.

## [0.8.2] — 17 de julio de 2026

**Qué releer:** **Los títulos de capítulo tocados y el epígrafe.** El cuerpo del temario no cambia ni
una línea; los dos se comprueban de un vistazo.

Los títulos de capítulo se comían el paréntesis en inglés que trae el syllabus. El syllabus es la
raíz del proyecto y el título copia su entrada; sólo se le aplica la norma española de mayúsculas y
los términos ingleses van en cursiva. El CI lo comprueba ahora en los 76 capítulos de la colección.

### Cambiado

* **Título del libro** — recupera su nombre completo, «Conocimientos Generales de la Aeronave,
  Estructura, Sistemas y Equipo de Emergencia», que es lo que dicen su cubierta, su apéndice y
  el AMC1 SFCL.130 (*aircraft general knowledge, airframe and systems and emergency
  equipment*). El `title:` se comía media asignatura.
* **Títulos de `cap01`, `cap11`, `cap12` y `cap14`** — «Estructura (*airframe*)», «Sistemas de
  lastre con agua (*water ballast systems*)», «Baterías (rendimiento y limitaciones
  operativas)» y «Equipo de evacuación de emergencia (*emergency bail-out aid*)».
* **Epígrafe** — el libro abre ahora con una cita propia, de Antoine de Saint-Exupéry,
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
  (`08-aeronave-sistemas-0.8.1-260716.pdf`), para identificarlos sin abrirlos.
* **Cada libro se publica también como un solo Markdown** (`make rag`, a
  `build/rag/08-aeronave-sistemas-0.8.1-260716.md`), para cargarlo como fuente en un asistente de
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
* Estado editorial: **Creando ilustraciones**, deducido de la versión 0.8.2.
* El texto está completo; faltan ilustraciones. La marca de agua lo advierte en cada página.

## [0.8.1] — 16 de julio de 2026

Versión base del registro. Lo anterior a esta fecha no está detallado entrada por entrada: el libro
se escribió antes de que existiera este fichero.

**Qué releer:** **Nada todavía.** El libro aún no ha entrado en revisión técnica (estado: Creando ilustraciones). Este registro empieza a contar desde aquí.

### Estado en esta versión

* 14 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **Creando ilustraciones**, deducido de la versión 0.8.1.
* El texto está completo; faltan ilustraciones. La marca de agua lo advierte en cada página.
