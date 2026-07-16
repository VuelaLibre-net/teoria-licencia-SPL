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
// abre calles blancas; y con las líneas algo más sueltas, que a 0.85em el texto
// se cierra.
//
// Los rótulos de sección van a la altura del texto, no como encabezados: una
// página de créditos es una sola unidad, no un capítulo con apartados.
#let licencia(body) = {
  set par(first-line-indent: 0em, justify: false, leading: 0.7em, spacing: 0.9em)
  set text(size: 0.85em)
  show strong: it => text(weight: "bold", it.body)
  set list(spacing: 0.75em, marker: [--])
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
