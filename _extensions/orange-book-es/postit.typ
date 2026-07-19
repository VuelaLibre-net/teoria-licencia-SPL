// Resumen de capítulo con aspecto de post-it, como en el AsciiDoc original.
//
// Colores tomados literalmente del tema de origen
// (aesa-spl-oficial/recursos/temas/pdf-theme.yml, rol `postit`):
//   fondo #FFF9C4, borde #FBC02D 1pt, radio 4pt, texto #5D4037 a 10.5pt.
//
// La única desviación es la fuente. El tema pedía Roboto; aquí se usa Libertinus
// Sans, que mantiene el contraste de palo seco contra el cuerpo en serifa.
//
// ⚠️ Este comentario decía que Libertinus Sans «viaja dentro de Typst». Era
// FALSO, y el error costó meses de PDF mal compuestos: Typst empotra Libertinus
// **Serif**, no Sans (`typst fonts --ignore-system-fonts` lo lista). Estaba en la
// máquina de desarrollo y no en el runner, así que los 76 post-it de la colección
// se publicaron en serifa —Typst no falla ante una fuente ausente: cae a otra en
// silencio— y el razonamiento por el que se descartó Roboto se aplicaba, sin que
// nadie lo viera, a la fuente que se eligió en su lugar.
//
// Ahora la fuente viaja en el repo (`recursos/fuentes/`) y el CI la instala antes
// de compilar. Cualquier fuente que no esté tumba el build: hay un guardián que
// falla si Typst avisa de `unknown font family`.
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
    // set text en vez de text(): la variante función envuelve el contenido en
    // un elemento de texto que interfiere con el motor matemático de Typst,
    // impidiendo que \sqrt, \times y otros comandos se compongan en su fuente
    // matemática (NewCMMath). Con set text, las propiedades se heredan en el
    // ámbito pero el motor matemático sigue funcionando independientemente.
    set text(font: "Libertinus Sans", size: 10.5pt, fill: rgb("#5D4037"))
    set par(first-line-indent: 0em)
    body
  },
)
