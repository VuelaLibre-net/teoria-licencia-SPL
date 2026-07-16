// Marca «Más allá del examen»: contenido que excede el mínimo del syllabus
// (índices de sondeo TT/K/CAPE/LI y Skew-T, triángulo FAI/AAT, registradores
// IGC y récords FAI…). Es formación real de vuelo de distancia, pero no hay
// certeza de que los examinadores la incluyan, y el alumno debe saberlo para no
// estudiarla con la misma prioridad. Por coherencia, este material tampoco se
// recoge en el resumen (`postit`) del capítulo.
//
// En el AsciiDoc original (aesa-spl-oficial/recursos/GUIA_ESTILO.md) la marca
// era sólo una entradilla en línea violeta, y **se descartó a propósito la
// variante en recuadro**: el estilo de sidebar de asciidoctor-pdf forzaba su
// propio color y no era fiable. Esa limitación era de la herramienta, no de la
// idea: aquí el fondo sí se controla, así que la sección avanzada entera —con
// sus subsecciones— va sobre gris y la entradilla se conserva dentro.
//
// El gris es luma(243): a partir de ~luma(235) el fondo empieza a competir con
// el texto en impresión, y por debajo de ~luma(248) no se distingue del papel.

// La sección avanzada completa. `breakable: true` es obligatorio: la sección de
// «Índices de estabilidad» (03, cap03) ocupa varias páginas y un bloque no
// partible la empujaría entera a la siguiente, dejando un hueco enorme.
//
// El `inset` negativo en horizontal no se usa: el bloque ocupa el ancho del
// texto y sangra hacia dentro, de modo que el gris no toca los márgenes ni pelea
// con marginalia.
#let mas-alla(body) = block(
  breakable: true,
  width: 100%,
  fill: luma(243),
  radius: 2pt,
  inset: (x: 0.6cm, top: 0.5cm, bottom: 0.6cm),
  above: 1.2em,
  below: 1.2em,
  body,
)

// La entradilla. Violeta #6A1B9A y cuerpo menor, tal cual el rol
// `mas-alla-tag` del tema original: es un color distinto de los cuatro de las
// admonitions a propósito, para que no se confunda con ellas. No lleva icono ni
// caja propia.
#let mas-alla-tag(body) = text(
  fill: rgb("#6A1B9A"),
  weight: "bold",
  size: 0.85em,
  body,
)
