# Registro de cambios — 03. Meteorología

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

**Qué releer:** **El alcance de las dos secciones marcadas, no su texto.** No cambia ni una palabra
del contenido; cambia qué queda señalado como ajeno al examen. Merece confirmar que el corte está
donde debe, sobre todo en `cap03`: allí el gris abarca también las tres subsecciones (TT, K-Index,
CAPE y LI), que es justo el material que la marca pretende cubrir.

### Cambiado

* **cap03, «Índices de estabilidad: el termómetro del día»** — la sección queda marcada entera como
  «Más allá del examen», sobre fondo gris, incluidas sus tres subsecciones. Antes la marca era sólo
  una entradilla al principio y no se veía dónde acababa el material avanzado.
* **cap10, «Sondeos termodinámicos y curvas de temperatura»** — igual, sin subsecciones.

En ambos, el resumen del capítulo queda fuera del gris, como manda la convención: este material no
se recoge en el post-it.

## [1.0-rc.4] — 16 de julio de 2026

Versión base del registro. Lo anterior a esta fecha no está detallado entrada por entrada: el libro
se escribió antes de que existiera este fichero.

**Qué releer:** **Todo el temario.** Es la primera revisión técnica completa del libro: no hay una versión revisada anterior con la que comparar.

### Estado en esta versión

* 10 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **En revisión**, deducido de la versión 1.0-rc.4.
* La marca de agua y el aviso del EPUB desaparecen solos al pasar a `1.0.0`.
