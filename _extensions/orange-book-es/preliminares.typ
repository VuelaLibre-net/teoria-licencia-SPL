// Dedicatoria y epígrafe, compuestos según la práctica editorial habitual:
// cada uno en su propia página impar (recto), sin título, y separados entre sí
// —juntarlos en la misma página es un error clásico—.
//
// Ambos llevan `pagebreak(to: "odd")` propio porque sus ficheros no tienen
// encabezado: el salto de página lo hace normalmente el `show heading` de
// orange-book sobre los H1, y aquí no hay ninguno.

// Dedicatoria: centrada verticalmente, alineada a la derecha y en cuerpo
// grande. Sin título: se reconoce por su posición y su forma, como en cualquier
// libro impreso.
#let dedicatoria(body) = {
  pagebreak(to: "odd")
  // page() —la función, no el `set`— compone una página con sus propias reglas
  // sin tocar las del resto del libro. Así se quitan folio y encabezado, que por
  // convención no llevan las páginas de cortesía. El contador de página sigue
  // avanzando: la página se cuenta, sólo que no se imprime su número.
  page(header: none, footer: none, numbering: none)[
    // Centrada verticalmente: mismo muelle arriba que abajo.
    #v(1fr)
    #block(width: 100%, inset: (right: 0.5cm))[
      #set align(right)
      #set par(first-line-indent: 0em, justify: false, leading: 0.8em)
      #set text(size: 1.45em, style: "italic")
      #body
    ]
    #v(1fr)
  ]
}

// Epígrafe: la cita va en su propia página, más discreta que la dedicatoria y
// desplazada hacia el primer tercio, que es donde se coloca por convención.
#let epigrafe(body) = {
  pagebreak(to: "odd")
  page(header: none, footer: none, numbering: none)[
    #v(1fr)
    #block(width: 100%, inset: (left: 4cm))[
      #set align(left)
      #set par(first-line-indent: 0em, justify: false, leading: 0.75em)
      #set text(size: 1.05em, style: "italic")
      #body
    ]
    #v(3fr)
  ]
}

// Página de créditos. Letra menor que el cuerpo, como es costumbre, para que no
// compita con el contenido; sin justificar, porque a este cuerpo la justificación
// abre calles blancas.
//
// La página salía amontonada, y NO era la interlínea: a 8.5pt con leading 0.7em
// daba un 135,8 %, dentro de la banda 120-150 % que se recomienda. Amontonaban
// otras tres cosas —medidas, no supuestas—:
//
//   1. el cuerpo a 8.5pt, un 15 % menor que el libro;
//   2. `spacing: 0.9em` sobre 8.5pt = 7,65pt entre párrafos, frente a los 10,5pt
//      del libro: un 27 % más apretado en absoluto;
//   3. y sobre todo, que los rótulos de sección eran párrafos en negrita con la
//      misma separación que cualquier otro. Nada los distinguía del texto que
//      los rodeaba, así que las secciones no se veían.
//
// Comprimir tampoco hacía falta: medida sobre el PDF, la página ocupaba 17,5 de
// los 24,7 cm útiles. Sobraban 7,2 cm, casi un 30 % de la caja.
//
// Ahora 9.5pt con leading 0.75em = 140,8 %, la misma interlínea que el cuerpo
// del libro (medido con el método del CLAUDE.md: los porcentajes NO se deducen
// del valor de `leading`).
#let licencia(body) = {
  set par(first-line-indent: 0em, justify: false, leading: 0.75em, spacing: 1.05em)
  set text(size: 9.5pt)
  show strong: it => text(weight: "bold", it.body)
  set list(spacing: 0.75em, marker: [--])

  // Los rótulos de sección se escriben como `## Rótulo {.unnumbered .unlisted}`
  // y no como negrita suelta, para que el EPUB tenga un h2 real al que
  // engancharse: a una negrita no hay forma de darle estilo.
  //
  // ⚠️ orange-book trae UNA regla global `show heading:` que ramifica por nivel,
  // con una rama para los niveles 2-4 (lib.typ:459). Sin anularla, estos
  // rótulos saldrían compuestos como secciones de capítulo. La regla de aquí
  // devuelve un bloque —contenido que ya NO es un heading—, así que la de
  // orange-book deja de casar con él y no llega a aplicarse.
  //
  // Sans y mayúsculas con tracking: se ven de un vistazo sin necesidad de un
  // cuerpo grande, que en cuatro rótulos seguidos daría aspecto de escalera. La
  // separación la da el aire de encima, que es lo que faltaba.
  show heading.where(level: 2): it => block(width: 100%, above: 1.6em, below: 0.7em)[
    #text(
      font: "Libertinus Sans",
      size: 0.92em,
      weight: "bold",
      tracking: 0.08em,
      fill: rgb("#0074D9"),
      upper(it.body),
    )
    #v(0.3em, weak: true)
    #line(length: 100%, stroke: 0.5pt + luma(200))
  ]

  body
}

// Créditos personales de los reconocimientos: nombre destacado y, debajo y
// sangradas, las titulaciones y el cargo. Es la forma habitual del apartado en
// un libro técnico: el ojo baja por la columna de nombres, que es lo que se
// busca, y el detalle queda subordinado sin estorbar.
//
// Se apoya en la lista de definición de Pandoc —nombre = término, titulaciones
// = descripción— porque es lo que son, y porque así el EPUB recibe un <dl> sin
// necesidad de marcado propio. Pandoc funde las varias descripciones de una
// misma persona en un solo #block con un párrafo cada una.
//
// ⚠️ El `show terms.item` de glosario.typ es global y maquetaría esto en línea,
// como una entrada de glosario. La regla local de aquí lo sobrescribe DENTRO de
// este bloque y sólo aquí: fuera, el glosario conserva la suya. Por eso los
// créditos tienen que ir envueltos en `::: {.creditos}`; sin el envoltorio no
// hay ámbito que valga y saldrían con el aspecto del glosario.
#let creditos(body) = {
  v(1.5em)
  show terms.item: it => block(breakable: false, below: 1.15em, width: 100%)[
    // Sans y negrita: el nombre destaca sobre el cuerpo en serif sin recurrir a
    // un tamaño grande, que en una lista de siete daría aspecto de escalera.
    // Libertinus Sans no tiene semibold —Typst caería a bold en silencio—, así
    // que se pide bold, que es lo que de verdad se compone.
    #text(font: "Libertinus Sans", size: 1.05em, weight: "bold")[#it.term]
    #block(inset: (left: 1.2em), above: 0.35em)[
      #set par(first-line-indent: 0em, justify: false, leading: 0.55em, spacing: 0.45em)
      #set text(size: 0.85em, fill: luma(90))
      #it.description
    ]
  ]
  body
}

// Colofón: notas de producción al final del libro. Es el sentido estricto del
// término, y por eso va aquí y no al principio (lo que hasta ahora se llamaba
// colofon.qmd era en realidad la página de créditos: ahora es licencia.qmd).
//
// La versión de Typst se toma de `sys.version`, o sea del compilador que está
// construyendo el libro de verdad: no puede quedarse desfasada. El resto de
// datos (versión del libro, fecha, URL, versión de Quarto) llegan como
// metadatos; el Makefile inyecta los dos que no son estáticos.
#let colofon(body) = {
  pagebreak(to: "odd")
  v(1fr)
  align(center)[
    #block(width: 78%)[
      #set align(center)
      #set par(first-line-indent: 0em, justify: false, leading: 0.8em)
      #set text(size: 0.9em)
      #body
      #v(0.4em)
      #text(size: 0.85em, style: "italic")[Motor tipográfico: Typst #sys.version.]
    ]
  ]
  v(1fr)
}
