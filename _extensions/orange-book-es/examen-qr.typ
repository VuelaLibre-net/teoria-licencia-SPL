// Código QR del enlace «Ponte a prueba» en los syllabus.
//
// Se genera como curva vectorial: no pierde definición al imprimir ni añade una
// imagen que tendrían que arrastrar los otros entregables.
#import "@preview/zebra:0.1.0": qrcode

#let examen-qr(url) = block(
  width: 100%,
  above: 1.2em,
  below: 1.2em,
  inset: 0.45cm,
  fill: luma(248),
  stroke: 0.5pt + luma(210),
  radius: 2pt,
  breakable: false,
  grid(
    columns: (3cm, 1fr),
    gutter: 0.7cm,
    align: (center, left),
    [
      #link(url)[
        #qrcode(url, width: 3cm, quiet-zone: true, background-fill: white)
      ]
    ],
    [
      #set text(size: 9pt)
      #link(url)[#url]
    ],
  ),
)
