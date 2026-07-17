# Registro de cambios — 04. Comunicaciones

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

**Qué releer:** **El capítulo 2 entero, los demás títulos y el epígrafe.** Ni una línea del temario
cambia de contenido, pero el libro cambia de estructura: los que eran capítulos 2, 3 y 4 son ahora
las secciones 2.1, 2.2 y 2.3 de un único capítulo «Comunicaciones VFR», y los que eran 5 a 9 pasan a
ser 3 a 7. Merece hojear el capítulo 2 para confirmar que las tres partes se leen seguidas.

Los títulos de capítulo se comían el paréntesis en inglés que trae el syllabus. El syllabus es la
raíz del proyecto y el título copia su entrada; sólo se le aplica la norma española de mayúsculas y
los términos ingleses van en cursiva. El CI lo comprueba ahora en los 76 capítulos de la colección.

### Cambiado

* **Estructura del libro: de 9 capítulos a 7** — el syllabus agrupa las comunicaciones VFR en la
  entrada 4.2, con tres subentradas. Ahora el libro hace lo mismo: «Comunicaciones VFR» es el
  capítulo 2 y aeródromos no controlados, controlados y ATC en ruta son sus secciones 2.1, 2.2 y
  2.3. Los capítulos 5 a 9 se renumeran a 3 a 7. El índice del libro calca ya el del syllabus.
  Los tres resúmenes se funden en el del capítulo 2, en tres bloques; sigue habiendo un post-it por
  capítulo. Las imágenes y sus referencias se renumeran con sus capítulos.
* **Títulos de `cap01`, `cap06` y `cap08`** — «Definiciones» (el syllabus 4.1 no dice más),
  «Términos de información meteorológica relevantes (VFR)» y «Procedimientos de socorro
  (*distress*) y urgencia (*urgency*)».
* **Epígrafe** — el libro abre ahora con una cita propia, de George Bernard Shaw,
  elegida para esta asignatura. Los 9 libros compartían la misma cita de Frank Borman,
  que además pertenece a Factores Humanos.

### Maqueta y producción

Nada de esto altera lo que el lector aprende; el revisor puede saltárselo.

* El pie de la figura del micrófono (`cap01`) estaba cortado: decía «Pulsa el PTT (» y ahí acababa.
  Se restaura entero desde el AsciiDoc de origen. El importador truncaba el pie en la primera marca
  de formato, y aquí caía dentro de un paréntesis, a la vista.
* El índice, la lista de ilustraciones y la de tablas bajan de cuerpo. Estaban a 15/13/11/11 pt
  con el texto del libro a 10: hasta la subsección más profunda era mayor que lo que se lee.
* La banda azul de la portadilla crece si el título no cabe en una línea. Tenía altura fija y
  el título del libro 8 la desbordaba, dejando la nota de estado y la versión pisándose fuera
  del recuadro.
* Se normalizan los títulos de capítulos, secciones, portadillas y apéndices a la capitalización
  propia del español.
* Los entregables llevan ahora la versión y la fecha en el nombre
  (`04-comunicaciones-1.0-rc.4-260716.pdf`), para identificarlos sin abrirlos.
* **Cada libro se publica también como un solo Markdown** (`make rag`, a
  `build/rag/04-comunicaciones-1.0-rc.4-260716.md`), para cargarlo como fuente en un asistente de
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

## [1.0-rc.4] — 16 de julio de 2026

Versión base del registro. Lo anterior a esta fecha no está detallado entrada por entrada: el libro
se escribió antes de que existiera este fichero.

**Qué releer:** **Todo el temario.** Es la primera revisión técnica completa del libro: no hay una versión revisada anterior con la que comparar.

### Estado en esta versión

* 9 capítulos y 4 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **En revisión**, deducido de la versión 1.0-rc.4.
* La marca de agua y el aviso del EPUB desaparecen solos al pasar a `1.0.0`.
