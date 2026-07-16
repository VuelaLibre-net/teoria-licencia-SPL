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
  // Centrada verticalmente: mismo muelle arriba que abajo.
  v(1fr)
  block(width: 100%, inset: (right: 0.5cm))[
    #set align(right)
    #set par(first-line-indent: 0em, justify: false, leading: 0.8em)
    #set text(size: 1.45em, style: "italic")
    #body
  ]
  v(1fr)
}

// Epígrafe: la cita va en su propia página, más discreta que la dedicatoria y
// desplazada hacia el primer tercio, que es donde se coloca por convención.
#let epigrafe(body) = {
  pagebreak(to: "odd")
  v(1fr)
  block(width: 100%, inset: (left: 4cm))[
    #set align(left)
    #set par(first-line-indent: 0em, justify: false, leading: 0.75em)
    #set text(size: 1.05em, style: "italic")
    #body
  ]
  v(3fr)
}

// Página de créditos (verso de la portada): letra menor que el cuerpo, como es
// costumbre, para que no compita con el contenido.
#let licencia(body) = {
  set par(first-line-indent: 0em, justify: false)
  set text(size: 0.85em)
  body
}
