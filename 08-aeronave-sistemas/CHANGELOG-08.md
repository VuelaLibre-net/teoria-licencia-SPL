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

**Qué releer:** **cap06, arcos de colores del anemómetro y figura del FLARM; cap07 y cap11, ubicación de dos figuras; cap08 y cap09, la sigla del certificado de aeronavegabilidad; cap13, primer párrafo.** En cap06 se añade el arco blanco, que faltaba. En cap07 la figura de los conectores pasa junto al tipo manual que ilustra, con su referencia `@fig` y un pie que ya no compara los dos tipos. En cap11 se adelanta a la descripción del sistema. En cap13 se matiza que «la mayoría» de los paracaídas de planeador son de apertura manual.

### Añadido

* **cap06, «Los arcos de colores del anemómetro» y su post-it** — el **arco blanco**, que no estaba descrito: rango de uso de las posiciones positivas de flap, de 1,1 V~S0~ a la V~FE~, superpuesto a la parte baja del arco verde. Se advierte de que las posiciones negativas, las de correr entre térmicas (capítulo 5), quedan fuera del arco y su límite sale de la placa de limitaciones y del Manual de Vuelo, no de la esfera. Los arcos se reordenan como en la esfera, de despacio a deprisa —blanco, verde, amarillo, roja—, en el apartado y en el post-it, y el triángulo amarillo pasa a párrafo aparte: es una marca suelta, no un arco.

### Corregido

* **cap06, figura de la unidad FLARM** (`#fig-08-cap06-4-2-ver-y-evitar`) — el rótulo «encima» quedaba pegado al círculo de las once del anillo de direcciones, de modo que el LED rojo parecía ser el suyo. El pie dice que el tráfico está **abajo** a las once, así que la figura contradecía al texto justo en lo que venía a explicar. Ahora «encima» lleva su propio testigo, apagado, separado del anillo.
* **cap08 y cap09, sigla del certificado de aeronavegabilidad** — cuatro apariciones de `CoA` pasan a `CofA`, la forma que la 0.9.1 ya fijó en el glosario y que usa el libro 01. Una de ellas era el **título** del apartado de cap09 («El CofA y el ARC: la "ITV" del cielo»), que se contradecía con el párrafo de cierre del propio apartado y con el post-it, escritos ya en la forma nueva.

### Maqueta y producción

* **cap06, arcos del anemómetro** — cada arco se compone sobre el color que describe, con tinta que contraste (envoltorios `arco-*` nuevos: `arcos.typ` en el PDF, CSS en el EPUB, desenvueltos en el Markdown para RAG). El CSS del paquete web vive en vuelalibre.net y va en su propio commit.
* **Apéndice del syllabus, «Ponte a prueba»** — el enlace pasa de `/tests/` a `/examenes/`; el PDF añade un QR hacia la misma página. No cambia lo que se estudia.

## [0.9.1] — 2 de agosto de 2026

**Qué releer:** **Glosario, entradas «Hipoxia», «V~RA~» y el certificado de aeronavegabilidad; cap05, encabezado de aerofrenos.** El certificado pasa de `CoA` a `CofA`, como en el libro 01, para no publicarse dos veces en el manual completo. Los aerofrenos se rotulan `airbrakes` y no `spoilers`, con el porqué en el glosario.

### Cambiado

* **Glosario, entradas «Hipoxia» y «V~RA~»** — «Hipoxia» gana los cuatro tipos del libro 02 sobre la redacción que ya tenía. «V~RA~» adopta la del libro 05: dice qué arco empieza y cuál acaba en esa marca, y que V~RA~ y V~A~ suelen andar próximas. Se pierde la remisión al «Libro 5, capítulo 5», que en el manual completo no tenía sentido.
* **Glosario, rótulos de `AD`, `AFM`, `CS-22`, `ELT` y `Part-ML`** — adoptan la forma completa del libro 01. Cuatro de ellos sólo llevaban el inglés o nada.
* **Glosario, entrada «Aerofrenos», y encabezado de cap05** — pasan de `(spoilers)` a `(airbrakes)`. La definición explica ahora por qué: el spoiler estropea la sustentación desde el extradós, mientras que los aerofrenos de planeador salen por arriba y por abajo y añaden además resistencia. El contenido del apartado no cambia.
* **Glosario, rótulos de `Carga alar`, `Lastre de agua`, `Lastre de cola` y `Transpondedor`** — misma forma que en los libros 06, 07 y 09.
* **Glosario, rótulos de `CG` y `PLB`** — añaden el desarrollo español o inglés que les faltaba. `FES` se deja como está: es el nombre comercial de un sistema.

### Corregido

* **Glosario, entrada del certificado de aeronavegabilidad** — pasa de `CoA` a `CofA`, la sigla que usa el libro 01 con la misma definición palabra por palabra. Con dos siglas distintas, el glosario del manual completo publicaba el mismo certificado dos veces.

### Maqueta y producción

* **Glosario** — `L’Hotellier` iba detrás de `LiFePO4`. Ninguna definición cambia.
## [0.9.0] — 1 de agosto de 2026

**Qué releer:** **cap01, gancho de remolque CG; cap05, aerofrenos, flaps y compensador; cap06, anemómetro, variómetro de energía total y FLARM; cap07, conectores L'Hotellier; cap10, motor retráctil; cap11, lastre de agua; cap14, comunicador satelital, sistema EDS y kit de supervivencia.** Se incorporan nuevas ilustraciones y esquemas en español, se ajustan dimensiones y pies de figura.

### Añadido

* **cap01** — figura del gancho de remolque de centro de gravedad (CG) (`#fig-08-cap01-planeador`) e imagen de cabina.
* **cap05** — figuras explicativas de aerofrenos extendidos (`#fig-08-cap05-8-5-3-1-el-aerofreno`), flaps (`#fig-08-cap05-8-5-3-2-flaps`) y compensador (`#fig-08-cap05-8-5-3-2-el-compensador-trim-tab-en-ingle`).
* **cap06** — figuras de anemómetro ADI2 (`#fig-08-cap06-8-6-4-2-anemometro`), sistema de variómetro de energía total (`#fig-08-cap06-un-sistema-de-variometro-de-energia-tota`) y unidad FLARM en cabina (`#fig-08-cap06-4-2-ver-y-evitar`).
* **cap14** — figuras de comunicador bidireccional vía satélite (`#fig-08-cap14-1-11-2-equipos-de-emergencia-a-bordo`) y sistema EDS de demanda de pulso electrónico (`#fig-08-cap14-sistema-de-demanda-de-pulso-electronico`).

### Cambiado

* **cap07** — actualización del pie de foto de la figura de conectores de mandos (`#fig-08-cap07-conectores-mandos`) especificando el orificio para el pin de seguridad.
* **cap10** — reubicación y actualización del pie de foto de la figura de motor retráctil (`#fig-08-cap10-motor-retractil`).
* **cap11** — actualización del pie de foto de la figura de manijas del sistema de lastre de agua (`#fig-08-cap11-lastre-agua`).
* **cap14** — ajuste de escala/ancho (`width="45%"`) en la figura del kit de supervivencia (`#fig-08-cap14-equipo-supervivencia`).

## [0.8.9] — 29 de julio de 2026

### Maqueta y producción

* **Glosario** — las tres velocidades V de las entradas de flutter y V~RA~ se escriben ya con subíndice (`V~NE~`, `V~A~`), como las componen CS-22 y 14 CFR §1.2 y como estaban en el resto de la colección. No cambia ningún dato.

## [0.8.8] — 28 de julio de 2026

**Qué releer:** **cap05, código de colores de la cabina** (el apartado del cuerpo y la viñeta del resumen). Los colores no cambian; cambia su rango: pasan de costumbre a requisito.

### Corregido

* **cap05** — el código de colores **no es «casi universal»: es normativo**. Lo fija **CS 22.780 «Colour marking and arrangement of cockpit controls»** con una tabla (suelta de remolque **amarillo**, aerofrenos **azul**, compensador **verde**, apertura de cúpula **blanco**, suelta de cúpula **rojo**), y **CS 22.1555(b)** obliga a marcar los mandos conforme a ella. La misma tabla **reserva** el amarillo y el rojo —«other controls [...] but **not yellow, red**»—, que es lo que permite al piloto fiarse del color a la primera. Presentarlo como una costumbre extendida invitaba a dudar de un dato que está certificado. Verificado contra CS-22 Amdt 3 (ED Decision 2021/013/R).

## [0.8.7] — 27 de julio de 2026

**Qué releer:** **cap04, pesaje y documentación.** Se retira una atribución concluyente sobre el formato del examen. El contenido técnico no cambia.

### Cambiado

* **cap04** — la remisión al ejemplo de masa y centrado del Libro 7 deja de presentarlo como ejemplo de examen.

### Maqueta y producción

* **Maquetación Typst** — corrección del solapamiento en páginas de parte, ajuste de la marca de agua «En revisión» y ordenación del índice alfabético sin tildes.

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
  parte de las ilustraciones—, y los reconocimientos ya acreditan a Iñaqui con sus
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
