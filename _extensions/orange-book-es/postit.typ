// Resumen de capítulo con aspecto de post-it, como en el AsciiDoc original.
//
// Colores tomados literalmente del tema de origen
// (aesa-spl-oficial/recursos/temas/pdf-theme.yml, rol `postit`):
//   fondo #FFF9C4, borde #FBC02D 1pt, radio 4pt, texto #5D4037 a 10.5pt.
//
// La única desviación es la fuente. El tema pedía Roboto; aquí se usa Libertinus
// Sans, que viaja dentro de Typst. Roboto está en la máquina de desarrollo pero
// no en el runner del CI, y Typst no falla ante una fuente ausente: cae a otra
// en silencio, con lo que los entregables oficiales saldrían distintos sin que
// nadie se entere. Libertinus Sans mantiene el contraste de palo seco contra el
// cuerpo en serifa y renderiza igual en cualquier sitio.
//
// El bloque es partible a propósito: algunos resúmenes no caben en una página y
// un bloque no partible se saldría del papel.

#let postit(body) = block(
  fill: rgb("#FFF9C4"),
  stroke: 1pt + rgb("#FBC02D"),
  radius: 4pt,
  inset: 0.6cm,
  width: 100%,
  above: 1.4em,
  below: 1.4em,
  breakable: true,
  {
    // El cuerpo hereda la sangría de primera línea, que dentro de una caja
    // descoloca el primer renglón contra el borde.
    set par(first-line-indent: 0em)
    text(
      font: "Libertinus Sans",
      size: 10.5pt,
      fill: rgb("#5D4037"),
      body,
    )
  },
)
