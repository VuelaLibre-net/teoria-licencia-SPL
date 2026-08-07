// Los arcos de colores del anemómetro (cap06 del libro 8): cada párrafo se
// compone sobre el color del arco que describe, con una tinta que contraste.
//
// NO son admonitions ni una nueva categoría del temario: son envoltorios de
// maqueta, como `postit` o `ejercicio`, y el color aquí no clasifica nada —ES
// el contenido: el lector ve el arco que va a encontrarse en la esfera.
//
// Verde y rojo son los mismos de las señales luminosas de la Torre en
// postit.lua (luz-verde/luz-roja) y el amarillo, el del borde del post-it:
// la paleta de la colección, no colores nuevos. El arco blanco necesita un
// borde gris —fondo blanco sobre papel blanco no se ve— y los demás lo llevan
// también, un punto más oscuro que su fondo, para que los cuatro bloques
// formen serie.
//
// `breakable: true` como en ejercicio.typ: son párrafos cortos, pero uno que
// caiga a final de página no debe empujarse entero y dejar un hueco.

#let arco(fondo, tinta, borde, body) = block(
  breakable: true,
  width: 100%,
  fill: fondo,
  stroke: 0.5pt + borde,
  radius: 2pt,
  inset: (x: 0.6cm, y: 0.4cm),
  above: 0.9em,
  below: 0.9em,
  {
    set par(first-line-indent: 0em)
    set text(fill: tinta)
    // Los enlaces del glosario (glosario-enlaces.lua) se pintan de azul. Sobre
    // el verde o el rojo de estos bloques quedarían ilegibles, así que aquí
    // toman la tinta del bloque y conservan el subrayado para seguir
    // reconociéndose como enlace.
    show link: it => underline(text(fill: tinta, it))
    body
  },
)

#let arco-blanco(body) = arco(white, black, luma(150), body)
#let arco-verde(body) = arco(rgb("#2e7d32"), white, rgb("#1b5e20"), body)
#let arco-amarillo(body) = arco(rgb("#FBC02D"), black, rgb("#c49000"), body)
#let arco-rojo(body) = arco(rgb("#c62828"), white, rgb("#8e1b1b"), body)
