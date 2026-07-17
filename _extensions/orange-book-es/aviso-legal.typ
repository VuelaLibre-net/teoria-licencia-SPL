// Cajas de la página de créditos: la exención de responsabilidad, el aval y la
// banda con el nombre de la licencia.
//
// ⚠️ El import propio no es redundante. Quarto coloca los `include-in-header`
// (esto) ANTES de su `#import "@preview/fontawesome:0.5.0": *` en el index.typ
// generado —línea ~480 frente a ~653—, y Typst usa ámbito léxico: una función
// definida aquí no vería los `fa-*` de aquel import. Sin esta línea, el render
// muere con `unknown variable: fa-exclamation-triangle`. Importar dos veces el
// mismo paquete no molesta.
#import "@preview/fontawesome:0.5.0": fa-creative-commons, fa-creative-commons-by, fa-exclamation-triangle

// La exención NO es una quinta admonition, y por eso no usa `::: {.callout-*}`.
// La colección tiene 319 admonitions y exactamente cuatro títulos —Seguridad,
// Normativa, Regla de oro, Airmanship—: es una taxonomía cerrada del temario, y
// un aviso legal no pertenece a ella. Es la misma razón por la que «más allá del
// examen» tiene su propio color y no es un recuadro más.
//
// Lo que sí toma prestada es la paleta de `callout-warning` (fondo #fcefdc,
// acento #EB9113): es la que el ojo ya asocia a «cuidado» en este libro, y
// repetirla evita inventar un quinto color.
#let aviso-legal(body) = block(
  fill: rgb("#fcefdc"),
  stroke: 1pt + rgb("#EB9113"),
  radius: 4pt,
  inset: (x: 0.5cm, y: 0.35cm),
  width: 100%,
  above: 0.5em,
  below: 0.9em,
  breakable: true,
  grid(
    columns: (auto, 1fr),
    gutter: 0.55cm,
    // El icono va centrado sobre el alto del texto, no pegado arriba: el bloque
    // es una unidad y el triángulo la señala entera.
    align(horizon, text(size: 22pt, fill: rgb("#EB9113"), fa-exclamation-triangle())),
    {
      // Dentro de una caja, la sangría de primera línea descoloca el primer
      // renglón contra el borde.
      set par(first-line-indent: 0em)
      set list(spacing: 0.6em, marker: [--])
      body
    },
  ),
)

// El aval, en gris: es información institucional, no una advertencia.
//
// luma(243) es el mismo gris de «más allá del examen», y por el mismo motivo:
// por encima de ~luma(235) el fondo compite con el texto en impresión y por
// debajo de ~luma(248) no se distingue del papel.
//
// Sin logotipo a propósito. El único disponible no es el de AESA sino la banda
// entera del Estado (escudo + Ministerio + AESA), y afirmaría un respaldo más
// amplio del que el propio texto acota: avala «el programa», y «el desarrollo
// del contenido es responsabilidad exclusiva de los autores».
#let aval(body) = block(
  fill: luma(243),
  stroke: (left: 3pt + rgb("#0074D9")),
  radius: (right: 2pt),
  inset: (x: 0.5cm, y: 0.35cm),
  width: 100%,
  above: 0.5em,
  below: 0.9em,
  breakable: true,
  {
    set par(first-line-indent: 0em)
    body
  },
)

// La banda con el nombre de la licencia, encabezando sus condiciones.
//
// Los glifos de Creative Commons son de la fuente *Brands*; el triángulo de
// arriba es de *Free-Solid*. Quarto entrega las dos a Typst con --font-paths,
// pero ningún PDF de la colección usaba un glifo Brands hasta ahora: si algún
// día dejaran de llegar, Typst NO falla, cae a otra fuente en silencio y salen
// cuadraditos. Se comprueba mirando la página, no el código de salida.
#let licencia-cc(body) = block(
  fill: rgb("#EAF2FB"),
  radius: 3pt,
  inset: (x: 0.5cm, y: 0.4cm),
  width: 100%,
  above: 0.5em,
  below: 0.9em,
  breakable: false,
  grid(
    columns: (auto, 1fr),
    gutter: 0.45cm,
    align(horizon, text(size: 15pt, fill: rgb("#0074D9"))[
      #fa-creative-commons()#h(0.12em)#fa-creative-commons-by()
    ]),
    align(horizon, {
      set par(first-line-indent: 0em)
      body
    }),
  ),
)
