// Chapter-based numbering for books with appendix support
#let equation-numbering = it => {
  let pattern = if state("appendix-state", none).get() != none { "(A.1)" } else { "(1.1)" }
  numbering(pattern, counter(heading).get().first(), it)
}
#let callout-numbering = it => {
  let pattern = if state("appendix-state", none).get() != none { "A.1" } else { "1.1" }
  numbering(pattern, counter(heading).get().first(), it)
}
#let subfloat-numbering(n-super, subfloat-idx) = {
  let chapter = counter(heading).get().first()
  let pattern = if state("appendix-state", none).get() != none { "A.1a" } else { "1.1a" }
  numbering(pattern, chapter, n-super, subfloat-idx)
}
// Theorem configuration for theorion
// Chapter-based numbering (H1 = chapters)
#let theorem-inherited-levels = 1

// Appendix-aware theorem numbering
#let theorem-numbering(loc) = {
  if state("appendix-state", none).at(loc) != none { "A.1" } else { "1.1" }
}

// Theorem render function
// Note: brand-color is not available at this point in template processing
#let theorem-render(prefix: none, title: "", full-title: auto, body) = {
  block(
    width: 100%,
    inset: (left: 1em),
    stroke: (left: 2pt + black),
  )[
    #if full-title != "" and full-title != auto and full-title != none {
      strong[#full-title]
      linebreak()
    }
    #body
  ]
}
// Some definitions presupposed by pandoc's typst output.
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let fields = old_block.fields()
  let _ = fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => {
          let subfloat-idx = quartosubfloatcounter.get().first() + 1
          subfloat-numbering(n-super, subfloat-idx)
        })
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => block({
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          })

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let children = old_title_block.body.body.children
  let old_title = if children.len() == 1 {
    children.at(0)  // no icon: title at index 0
  } else {
    children.at(1)  // with icon: title at index 1
  }

  // TODO use custom separator if available
  // Use the figure's counter display which handles chapter-based numbering
  // (when numbering is a function that includes the heading counter)
  let callout_num = it.counter.display(it.numbering)
  let new_title = if empty(old_title) {
    [#kind #callout_num]
  } else {
    [#kind #callout_num: #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      if children.len() == 1 {
        new_title  // no icon: just the title
      } else {
        children.at(0) + new_title  // with icon: preserve icon block + new title
      }))

  align(left, block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1)))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}


// syntax highlighting functions from skylighting:
/* Function definitions for syntax highlighting generated by skylighting: */
#let EndLine() = raw("\n")
#let Skylighting(fill: none, number: false, start: 1, sourcelines) = {
   let blocks = []
   let lnum = start - 1
   let bgcolor = rgb("#f1f3f5")
   for ln in sourcelines {
     if number {
       lnum = lnum + 1
       blocks = blocks + box(width: if start + sourcelines.len() > 999 { 30pt } else { 24pt }, text(fill: rgb("#aaaaaa"), [ #lnum ]))
     }
     blocks = blocks + ln + EndLine()
   }
   block(fill: bgcolor, width: 100%, inset: 8pt, radius: 2pt, blocks)
}
#let AlertTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let AnnotationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let AttributeTok(s) = text(fill: rgb("#657422"),raw(s))
#let BaseNTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let BuiltInTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let CharTok(s) = text(fill: rgb("#20794d"),raw(s))
#let CommentTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let CommentVarTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ConstantTok(s) = text(fill: rgb("#8f5902"),raw(s))
#let ControlFlowTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let DataTypeTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DecValTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let DocumentationTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))
#let ErrorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let ExtensionTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let FloatTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let FunctionTok(s) = text(fill: rgb("#4758ab"),raw(s))
#let ImportTok(s) = text(fill: rgb("#00769e"),raw(s))
#let InformationTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let KeywordTok(s) = text(weight: "bold",fill: rgb("#003b4f"),raw(s))
#let NormalTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let OperatorTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let OtherTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let PreprocessorTok(s) = text(fill: rgb("#ad0000"),raw(s))
#let RegionMarkerTok(s) = text(fill: rgb("#003b4f"),raw(s))
#let SpecialCharTok(s) = text(fill: rgb("#5e5e5e"),raw(s))
#let SpecialStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let StringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let VariableTok(s) = text(fill: rgb("#111111"),raw(s))
#let VerbatimStringTok(s) = text(fill: rgb("#20794d"),raw(s))
#let WarningTok(s) = text(style: "italic",fill: rgb("#5e5e5e"),raw(s))



#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // Set document metadata for PDF accessibility
  set document(title: title, keywords: keywords)
  set document(
    author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)
  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
   }

  let has-title-block = title != none or (authors != none and authors != ()) or date != none or abstract != none
  if has-title-block {
    place(
      top,
      float: true,
      scope: "parent",
      clearance: 4mm,
      block(below: 1em, width: 100%)[

        #if title != none {
          align(center, block(inset: 2em)[
            #set par(leading: heading-line-height) if heading-line-height != none
            #set text(font: heading-family) if heading-family != none
            #set text(weight: heading-weight)
            #set text(style: heading-style) if heading-style != "normal"
            #set text(fill: heading-color) if heading-color != black

            #text(size: title-size)[#title #if thanks != none {
              footnote(thanks, numbering: "*")
              counter(footnote).update(n => n - 1)
            }]
            #(if subtitle != none {
              parbreak()
              text(size: subtitle-size)[#subtitle]
            })
          ])
        }

        #if authors != none and authors != () {
          let count = authors.len()
          let ncols = calc.min(count, 3)
          grid(
            columns: (1fr,) * ncols,
            row-gutter: 1.5em,
            ..authors.map(author =>
                align(center)[
                  #author.name \
                  #author.affiliation \
                  #author.email
                ]
            )
          )
        }

        #if date != none {
          align(center)[#block(inset: 1em)[
            #date
          ]]
        }

        #if abstract != none {
          block(inset: 2em)[
          #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
          ]
        }
      ]
    )
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  doc
}

#set table(
  inset: 6pt,
  stroke: none
)
// Presentación del glosario al estilo de glossarium
// (https://typst.app/universe/package/glossarium): término en negrita, raya y
// definición seguida, con las entradas sin partir entre páginas.
//
// No se usa el paquete en sí, a propósito: exige declarar las entradas como
// diccionarios de Typst, lo que sacaría el glosario de los .qmd —que son la
// fuente canónica— y del EPUB. Además su función principal (referenciar
// términos con @clave y generar retroenlaces) no tendría aquí nada que hacer:
// el contenido no lleva ni una sola referencia al glosario. Esto reproduce su
// aspecto sobre la lista de definición nativa, que sí sale en PDF y en EPUB.
//
// Alcance: todas las listas de términos de la colección salen del glosario. Los
// ': ' que aparecen en los capítulos son pies de tabla de Quarto, que comparten
// sintaxis pero no generan `terms`. Por eso esta regla no necesita acotarse.
//
// No se colorea el término: brand-color se define después de este include, así
// que no es legible desde aquí, y la negrita es además el estilo por defecto de
// glossarium. Si algún día se añade un _brand.yml, esto no desentonará.

// Pandoc envuelve cada definición en un #block, que forzaría un salto de línea
// tras el término. Se desenvuelve para que quede seguida, como en glossarium.
#let _glosario-descripcion(d) = {
  if d.func() == block and d.has("body") { d.body } else { d }
}

// El hueco entre entradas debe superar claramente al interlineado (hoy 0.75em)
// o el ojo no distingue dónde acaba una definición y empieza la siguiente. Se
// usa el mismo valor que las listas del cuerpo, por coherencia: si se toca el
// leading en lib.typ, hay que revisar este número.
#show terms.item: it => block(breakable: false, below: 1.2em, width: 100%)[
  #text(weight: "bold")[#it.term]#h(0.35em)#sym.dash.em#h(0.35em)#_glosario-descripcion(it.description)
]
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
#import "@preview/fontawesome:0.5.0": *
#let brand-color = (:)
#let brand-color-background = (:)
#let brand-logo = (:)

#set page(
  paper: "us-letter",
  margin: (bottom: 2.5cm,top: 2.5cm,),
  numbering: "1",
  columns: 1,
)
// Logo is handled by orange-book's cover page, not as a page background
// NOTE: marginalia.setup is called in typst-show.typ AFTER book.with()
// to ensure marginalia's margins override the book format's default margins
#import "@preview/orange-book-es:0.7.1": book, part, chapter, appendices

#show: book.with(
  title: [Planificación y Rendimiento de Vuelo],
  author: "VuelaLibre.net",
  lang: "es",
  main-color: brand-color.at("primary", default: blue),
  logo: {
    let logo-info = brand-logo.at("medium", default: none)
    if logo-info != none { image(logo-info.path, alt: logo-info.at("alt", default: none)) }
  },
  outline-depth: 3,
)


// Reset Quarto's custom figure counters at each chapter (level-1 heading).
// Orange-book only resets kind:image and kind:table, but Quarto uses custom kinds.
// This list is generated dynamically from crossref.categories.
#show heading.where(level: 1): it => {
  counter(figure.where(kind: "quarto-float-fig")).update(0)
  counter(figure.where(kind: "quarto-float-tbl")).update(0)
  counter(figure.where(kind: "quarto-float-lst")).update(0)
  counter(figure.where(kind: "quarto-callout-Note")).update(0)
  counter(figure.where(kind: "quarto-callout-Warning")).update(0)
  counter(figure.where(kind: "quarto-callout-Caution")).update(0)
  counter(figure.where(kind: "quarto-callout-Tip")).update(0)
  counter(figure.where(kind: "quarto-callout-Important")).update(0)
  counter(math.equation).update(0)
  it
}

#heading(level: 1, numbering: none)[Planificación y Rendimiento de Vuelo]
<planificación-y-rendimiento-de-vuelo>
Bienvenido a la versión digitalizada de este manual de formación SPL.

#heading(level: 1, numbering: none)[Información Legal y Licencia]
<información-legal-y-licencia>
#licencia[
#strong[Atribución y Fuentes]

#quote(block: true)[
El #strong[temario de esta colección ---el índice--- está avalado por AESA] (Agencia Estatal de Seguridad Aérea), la autoridad aeronáutica civil de España. Este aval certifica que el programa de formación teórica para la Licencia de Piloto de Planeador (SPL) es conforme al syllabus del AMC1 SFCL.130; no obstante, el desarrollo del contenido es responsabilidad exclusiva de los autores.

El contenido se basa en la síntesis de normativas oficiales, estándares de seguridad de la #strong[OACI] (Organización de Aviación Civil Internacional) y de #strong[EASA] (European Union Aviation Safety Agency), así como de las mejores prácticas de la comunidad de vuelo a vela española, recogidas por varios instructores, y recopiladas por el instructor Iñaqui Ulibarri García de la Cueva para los aeroclubs de Ocaña y Fuentemilanos.
]

#strong[EXENCIÓN DE RESPONSABILIDAD - USO BAJO PROPIO RIESGO]

La aviación es una actividad que conlleva riesgos inherentes. Aunque se ha realizado un esfuerzo exhaustivo para garantizar la precisión técnica de este manual utilizando fuentes oficiales actualizadas:

- #strong[Los autores, editores y colaboradores NO asumen responsabilidad alguna] por daños personales, materiales o de cualquier otra índole que pudieran derivarse de interpretaciones erróneas o errores técnicos en el texto.
- Este manual es una #strong[herramienta de apoyo al estudio] y no sustituye en ningún caso ni a la instrucción teórica ni a la práctica obligatoria con un instructor de vuelo cualificado (FI(S)).
- En caso de discrepancia con la normativa vigente publicada por AESA o EASA, prevalecerá siempre el texto legal oficial de la autoridad aeronáutica.

#strong[LICENCIA]

Esta obra se distribuye bajo licencia #strong[Creative Commons Atribución 4.0 Internacional (CC BY 4.0)].

Usted es libre de:

- #strong[Compartir]: Copiar y redistribuir el material en cualquier medio.
- #strong[Adaptar]: Remezclar, transformar y construir a partir del material para cualquier propósito incluso comercialmente.

Bajo los siguientes términos:

- #strong[Atribución]: Debe otorgar el crédito correspondiente, proporcionar un enlace a la licencia e indicar si se realizaron cambios. Puede hacerlo de cualquier manera razonable, pero no de una manera que sugiera que el licenciante lo respalda a usted o a su uso.

Más información: #link("https://creativecommons.org/licenses/by/4.0/deed.es")

#strong[Proyecto]

Manual de vuelo para la obtención de la licencia de piloto de planeador (SPL)

#strong[Coordinación]

VuelaLibre.net

#strong[Repositorio]

#link("https://github.com/VuelaLibreNet/manual-spl")

#strong[Licencia]

CC BY 4.0

#strong[Fuentes]

AESA, EASA, OACI, SERA, AMCs & GM, LSA, manuales de vuelo de Fuentemilanos, FAA Glider Flying Handbook, y manuales de vuelo de otros paises de la UE.

]
#dedicatoria[
#strong[A la memoria de Iñaqui Ulibarri García de la Cueva]

El maestro que nos regaló las alas y nos enseñó a volar con sabiduría.

Aún te sentimos en el asiento de atrás; nos acompañas en cada térmica y en cada decisión al mando que tomamos recordando tus lecciones.

Gracias por dejarnos tu inmensa pasión como la mejor de las herencias.

]
#epigrafe[
"Un buen piloto es aquel que utiliza su excelente juicio para evitar situaciones que requieran su excelente habilidad."

 --- Frank Borman, piloto del Apolo 8 y referente de la disciplina aeronáutica.

]
#heading(level: 1, numbering: none)[Reconocimientos]
<reconocimientos>
Este manual es el fruto de un esfuerzo colaborativo dentro de la comunidad de vuelo sin motor. Queremos expresar nuestro más sincero agradecimiento a:

- #strong[Agencia Estatal de Seguridad Aérea (AESA)] y #strong[EASA], por proporcionar el marco normativo y documental que garantiza la seguridad de nuestras operaciones.
- Los #strong[Instructores de Vuelo (FI(S))] y #strong[Examinadores (FE(S))] que han dedicado su tiempo a revisar técnicamente estas secciones para asegurar su rigor técnico.
- A la comunidad de #strong[VuelaLibre.net], por impulsar iniciativas que modernizan y democratizan el acceso a la formación aeronáutica de calidad.
- A todos los pilotos que, con su feedback constante, ayudan a que este manual sea una herramienta viva y en evolución.
- A los autores de los manuales internacionales clásicos, cuya estructura ha servido de base para organizar el conocimiento de una forma pedagógica y accesible para las nuevas generaciones de pilotos de planeador y, en especial a:

#emph[Iñaqui Ulibarri García de la Cueva] (SPL, FI(S), FE(S))

Campeón de España de Vuelo a Vela, Instructor y Examinador de Vuelo a Vela

Pedro Berlinches (SPL, FI(S), PPL(A), FES(A))

Instructor y Examinador de Vuelo a Vela

Luís Ferreira Escartín (SPL, FI(S), FE(S))

Instructor y Examinador de Vuelo a Vela

Encarnación Novillo-Fertrell Vázquez (SPL, FI(S), FE(S))

Instructora y Examinadora de Vuelo a Vela

Carlos Bravo Domínguez (SPL, FI(S), FE(S))

Instructor y Examinador de Vuelo a Vela

Sergi Pujol Rodríguez (SPL, FI(S), FE(S))

Instructor y Examinador de Vuelo a Vela

Ramón Gutiérrez Camus (SPL)

Piloto de Vuelo a Vela. Edición técnica

#heading(level: 1, numbering: none)[Introducción]
<introducción>
#strong[#emph[Tema 7 de 9 del examen teórico para la Licencia de Piloto de Planeador (SPL)]]

La diferencia entre el piloto que completa un vuelo de distancia y el que aterriza en el campo de un granjero no siempre está en la técnica. Muchas veces está en los cálculos que se hicieron ---o no se hicieron--- en tierra: la polar no consultada, el centrado calculado a ojo, el plan de vuelo que no se cerró al aterrizar fuera.

Cinco capítulos transforman la polar, el MacCready, la masa y el plan de vuelo ICAO en criterio de vuelo real.

Los mejores pilotos de distancia no improvisan. Calculan.

= Masa y centro de gravedad
<masa-y-centro-de-gravedad>
#quote(block: true)[
La masa y el centrado son los cimientos de la seguridad de cada vuelo. Los números que apuntas en el hangar tienen consecuencias físicas muy concretas: de ellos depende que el planeador responda como un guante o que se convierta en una máquina imprevisible.

En este capítulo aprenderás:

- #strong[El centro de gravedad y la estabilidad]: por qué un CG atrasado puede hacer una barrena irrecuperable y qué precio pagas por un CG adelantado.
- #strong[El cálculo de masa y centrado]: la línea de referencia (#strong[datum]), el brazo de palanca y el momento, con un ejemplo numérico como el del examen.
- #strong[La gestión del MTOW]: qué le ocurre al planeador cuando lo sobrecargas.
- #strong[El lastre de agua y el lastre de cola]: cuándo te ayudan y cómo gestionarlos con seguridad.
]

== Centro de gravedad (CG) y estabilidad
<centro-de-gravedad-cg-y-estabilidad>
El centro de gravedad es el punto donde se concentra todo el peso del planeador. De su posición respecto al centro de presiones depende la estabilidad longitudinal: dónde esté el CG decide cómo responde el avión a la palanca.

=== El peligro del CG atrasado
<el-peligro-del-cg-atrasado>
Tener el CG cerca del límite posterior es la condición más crítica en un planeador. El avión se vuelve muy sensible al mando de profundidad y tiende a subir el morro por sí solo, obligándote a volar con el compensador adelantado. El verdadero problema, sin embargo, aparece en la pérdida: con un CG excesivamente atrasado, el planeador puede entrar en barrena plana, o el timón de profundidad puede quedarse sin autoridad para bajar el morro y recuperar velocidad. En el peor de los casos, la barrena no se recupera.

¿Cómo se llega a esa situación? Casi siempre por una de estas tres vías: volar por debajo del peso mínimo del asiento delantero (pilotos ligeros), olvidar puesto el soporte de cola (#emph[dolly]) o instalar equipos pesados en la cola sin compensarlos.

#block[
#callout(
body: 
[
Si pesas poco, usa lastre de plomo o pesas fijas. Nunca despegues sin comprobar que tu peso entra en el margen permitido para el asiento que ocupas.

]
, 
title: 
[
Regla de oro
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
#block[
#callout(
body: 
[
El lastre de cabina debe ir siempre fijado mecánicamente en los soportes que el fabricante instala en el morro (planchas de plomo o pesas homologadas con su anclaje). Nunca improvises con sacos de arena, mochilas u objetos sueltos: en una turbulencia o en la rotación del despegue pueden desplazarse, bloquear los pedales o cambiar el centrado en el peor momento posible.

]
, 
title: 
[
Airmanship
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
=== CG adelantado: estabilidad a cambio de rendimiento
<cg-adelantado-estabilidad-a-cambio-de-rendimiento>
Volar con el morro pesado es más seguro que volar con la cola pesada, pero tiene su precio. El planeador se vuelve tan estable que insiste en mantener el morro bajo, y tendrás que sujetar la palanca atrás para conservar la actitud de vuelo. Para que el morro no caiga, el timón de profundidad vuela deflectado hacia arriba, y esa deflexión añade una resistencia (#emph[trim drag]) que empeora tu coeficiente de planeo. Hay un tercer efecto menos intuitivo: como la cola empuja hacia abajo, el ala necesita generar más sustentación para el mismo peso, así que la velocidad de pérdida efectiva aumenta. La #ref(<fig-07-cap01-limites-cg>, supplement: [Figura]) resume estos efectos de la posición del CG sobre la estabilidad longitudinal.

== Cálculo de masa y centrado
<cálculo-de-masa-y-centrado>
Saber que el CG atrasado es peligroso no basta. El examen y el vuelo real exigen saber dónde está el CG antes de despegar, y el cálculo se reduce a tres conceptos y una fórmula.

- #strong[Línea de referencia (#emph[Datum])]: un plano vertical imaginario que el fabricante define en el manual de vuelo, habitualmente el borde de ataque del ala en el encastre. Todas las distancias se miden desde aquí.
- #strong[Brazo de palanca (#emph[Arm])]: la distancia horizontal desde el #emph[datum] hasta el punto donde actúa cada peso. Por convenio, positiva hacia atrás y negativa hacia delante.
- #strong[Momento (#emph[Moment])]: el producto de cada peso por su brazo. Es la "fuerza de giro" que ese peso ejerce sobre el conjunto.

La posición del CG es la media ponderada de todos los momentos (#ref(<fig-07-cap01-datum-momento>, supplement: [Figura])):

#strong[CG = Σ Momentos / Σ Pesos]

#figure([
#box(image("imagenes/07-cap01-datum-momento.png"))
], caption: figure.caption(
position: bottom, 
[
Datum, brazo de palanca y momento: el balancín del centrado
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap01-datum-momento>


=== Ejemplo práctico de hoja de centrado
<ejemplo-práctico-de-hoja-de-centrado>
Imagina un monoplaza cuyo manual de vuelo da un rango de CG permitido de +0,25 m a +0,38 m detrás del #emph[datum]:

#table(
  columns: 4,
  align: (auto,auto,auto,auto,),
  table.header([Elemento], [Peso (kg)], [Brazo (m)], [Momento (kg·m)],),
  table.hline(),
  [Planeador en vacío (según ficha de pesaje)], [265], [+0,55], [+145,75],
  [Piloto + paracaídas], [85], [−0,45], [−38,25],
  [#strong[Total]], [#strong[350]], [---], [#strong[\+107,50]],
)
CG = 107,50 / 350 = #strong[\+0,31 m], dentro del rango permitido.

Repite ahora el cálculo con un piloto de 60 kg. Su momento baja a −27,00 kg·m, el total queda en 325 kg y +118,75 kg·m, y el CG se va a +0,37 m, rozando el límite posterior: ese piloto necesita lastre en el morro antes de despegar. Fíjate en la lección del ejemplo: cuanto menos pesa el piloto, más atrás se va el CG, porque el asiento está por delante del #emph[datum].

Los pesos y brazos de partida salen de la #strong[ficha de pesaje] oficial del planeador, que se actualiza tras cada pesada o reparación mayor. El procedimiento de pesado y la documentación asociada se estudian en el #strong[Libro 8 --- Conocimientos generales de la aeronave], capítulo 4.

== Gestión de la masa: MTOW y sobrecarga
<gestión-de-la-masa-mtow-y-sobrecarga>
El peso máximo al despegue (MTOW, #emph[Maximum Take-Off Weight]) no es una sugerencia: es un límite estructural. Un planeador pesado necesita más carrera de despegue y una velocidad de remolque mayor, típicamente 10-20 km/h extra. Volará más deprisa en crucero, sí, pero su régimen de ascenso en térmica se resiente. Y por encima del MTOW los márgenes desaparecen: el planeador sufre más con la turbulencia fuerte y los límites de factor de carga se alcanzan mucho antes, con el consiguiente riesgo de fatiga o de fallo estructural.

#figure([
#box(image("imagenes/07-cap01-limites-cg.jpg"))
], caption: figure.caption(
position: bottom, 
[
Efecto de la posición del CG en la estabilidad longitudinal
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap01-limites-cg>


== Lastre de agua: rendimiento a cambio de disciplina
<lastre-de-agua-rendimiento-a-cambio-de-disciplina>
El agua permite "engañar" a la polar, pero exige una gestión impecable. Al aumentar la carga alar, el planeador alcanza velocidades de crucero mucho mayores con el mismo ángulo de planeo, y eso lo convierte en el arma ideal para días de térmicas potentes. La contrapartida es que el régimen de ascenso empeora: si las térmicas bajan de 1,5 m/s, el peso extra te hunde antes de que puedas subir.

Y una obligación que no admite descuidos: tira el agua antes de aterrizar. El peso adicional en la toma puede dañar seriamente el tren de aterrizaje y el fuselaje. El vaciado tarda entre 3 y 8 minutos según el planeador, así que planifícalo antes de entrar en el circuito de tráfico.

=== El lastre de cola: el contrapeso inteligente
<el-lastre-de-cola-el-contrapeso-inteligente>
Muchos planeadores modernos llevan un pequeño depósito de agua en la deriva: el lastre de cola (#emph[fin ballast] o #emph[tail tank]). Su función no es añadir peso, sino recolocar el CG. Los tanques principales de las alas suelen quedar algo por delante del centro de gravedad, de modo que al llenarlos el CG se adelanta y aparece resistencia de compensación (#emph[trim drag]). Unos pocos litros en la cola devuelven el CG a su posición óptima, cerca del límite posterior, donde la resistencia es mínima.

Dos reglas innegociables al usarlo:

- Calcula la proporción según el manual de vuelo: cada modelo especifica cuántos litros de cola corresponden a cada llenado de alas y a cada peso de piloto.
- Vacíalo siempre junto con las alas, o antes. Aterrizar con agua solo en la cola es volar con un CG atrasado extremo, exactamente la condición de barrena irrecuperable que viste al principio del capítulo. Verifica en la lista de chequeo que la cola drena correctamente.

#block[
#callout(
body: 
[
Nunca aterrices con los tanques de agua llenos a menos que sea una emergencia absoluta. La energía del impacto aumenta drásticamente con el peso, y podrías romper el planeador de forma irreparable.

]
, 
title: 
[
Seguridad
]
, 
background_color: 
rgb("#fcefdc")
, 
icon_color: 
rgb("#EB9113")
, 
icon: 
fa-exclamation-triangle()
, 
body_background_color: 
white
)
]
== Ejercicios resueltos
<ejercicios-resueltos>
Los dos cálculos que más caen en el examen de esta asignatura son el centrado y el planeo final. Aquí tienes uno de cada, resueltos paso a paso. Intenta hacerlos tú antes de leer la solución.

#strong[Ejercicio 1 --- Centrado con lastre de cola.]

Un monoplaza tiene un rango de CG permitido de +0,25 m a +0,38 m. Con las alas cargadas de agua, la hoja de centrado queda así: planeador + agua de alas = 380 kg con brazo +0,50 m; piloto + paracaídas = 80 kg con brazo −0,45 m. El manual permite añadir hasta 6 litros (6 kg) de lastre de cola con un brazo de +3,90 m. ¿Dónde queda el CG sin lastre de cola? ¿Y cuánto lo recoloca añadir los 6 litros?

#strong[Solución.] Momento del planeador con agua: 380 × (+0,50) = +190,0 kg·m. Momento del piloto: 80 × (−0,45) = −36,0 kg·m. Sin lastre de cola: masa 460 kg, momento +154,0 kg·m, CG = 154,0 / 460 = #strong[\+0,335 m] (dentro de rango, pero adelantado respecto al óptimo, cerca del posterior).

Con 6 kg en la cola: momento adicional 6 × (+3,90) = +23,4 kg·m. Masa 466 kg, momento +177,4 kg·m, CG = 177,4 / 466 = #strong[\+0,381 m]. El lastre de cola ha llevado el CG de +0,335 a +0,381 m, justo en el límite posterior, donde la resistencia de compensación es mínima. Lección: unos pocos litros muy alejados del #emph[datum] mueven el CG mucho (su brazo es enorme), y por eso hay que vaciarlos con las alas: solos, dejarían el CG fuera de rango por detrás.

#strong[Ejercicio 2 --- Planeo final con viento.]

Estás a 1.200 m sobre el terreno, a 18 km del aeródromo. Tu planeador tiene una fineza de 30 en aire en calma, pero soplan 20 km/h de viento de cara y vuelas el planeo a 100 km/h. ¿Llegas con la altura de seguridad de 300 m?

#strong[Solución.] Con viento de cara, la fineza sobre el suelo cae en proporción a tu velocidad real de avance. A 100 km/h en el aire con 20 km/h de cara, avanzas sobre el suelo a 100 − 20 = 80 km/h, así que la fineza efectiva es 30 × (80 / 100) = #strong[24]. Los 18 km de distancia exigen entonces 18 / 24 = 0,75 km = #strong[750 m] de planeo puro. Partiendo de 1.200 m, al llegar sobre el campo te quedan 1.200 − 750 = #strong[450 m], por encima de los 300 m de seguridad: #strong[llegas, con 150 m de margen.] Si el viento arreciara a 40 km/h, la fineza efectiva bajaría a 30 × (60 / 100) = 18, necesitarías 18 / 18 = 1.000 m y llegarías justo con 200 m: momento de subir una térmica más antes de comprometerte con el planeo final.

#postit[
#strong[Resumen del Capítulo: Masa y Centro de Gravedad]

- #strong[CG atrasado]: es la condición más peligrosa. El avión se vuelve inestable (quiere subir el morro solo) y la recuperación de una pérdida o barrena puede ser imposible. Si eres ligero, usa lastre fijado mecánicamente, nunca improvisado.
- #strong[CG adelantado]: el avión es muy estable (pesado de morro), pero menos eficiente por la resistencia del timón de profundidad deflectado, y con una velocidad de pérdida más alta.
- #strong[Cálculo del CG]: CG = Σ Momentos / Σ Pesos. Cada peso se multiplica por su brazo (distancia al #emph[datum]) y la suma de momentos se divide entre la masa total. Los datos de partida salen de la ficha de pesaje oficial.
- #strong[Peso máximo (MTOW)]: un planeador sobrecargado necesita más pista para despegar, tiene una velocidad de pérdida mayor y sufre más fatiga estructural con menos Gs.
- #strong[Lastre de agua]: permite volar más rápido con el mismo ángulo de planeo (ideal para días fuertes), pero empeora el régimen de ascenso en térmica. Y recuerda: el agua se tira antes de aterrizar.
- #strong[Lastre de cola]: no añade rendimiento por sí mismo; recoloca el CG cuando llenas las alas. Vacíalo siempre junto con los tanques principales: agua solo en la cola equivale a un CG atrasado extremo.

]
= Polar de velocidades de planeadores o velocidad de crucero
<polar-de-velocidades-de-planeadores-o-velocidad-de-crucero>
#quote(block: true)[
Entender la polar de tu planeador es como conocer de memoria el mapa de potencia de un motor. En el vuelo sin motor, la gravedad es nuestro combustible y la aerodinámica nuestro acelerador. La polar te dice exactamente cuánto pagas en altura por cada kilómetro por hora de velocidad que ganas.

En este capítulo aprenderás:

- #strong[La curva polar]: las dos velocidades que debes saber de memoria (mínimo descenso y máximo planeo).
- #strong[La teoría MacCready]: cómo ajustar tu velocidad de crucero a la fuerza del día.
- #strong[El efecto del peso]: cómo el lastre de agua desplaza la polar sin cambiar el planeo máximo.
- #strong[El efecto del viento y el aire descendente]: cuándo acelerar y cuándo conservar.
- #strong[IAS y TAS en altura]: por qué el anemómetro te "miente" en aeródromos altos y en vuelo de onda.
- #strong[El planeo final]: gestión de energía con margen de seguridad.
]

== La polar: tu curva de rendimiento
<la-polar-tu-curva-de-rendimiento>
La curva polar representa la tasa de descenso frente a la velocidad aire. Es el ADN de tu planeador: cada modelo tiene la suya, y de ella salen las dos velocidades que importan (#ref(<fig-07-cap02-polar-anotada>, supplement: [Figura])).

- #strong[Velocidad de mínimo descenso]: el punto más alto de la curva. A esa velocidad pierdes los mínimos metros por segundo; es la ideal para aguantar en el aire mientras esperas una térmica.
- #strong[Velocidad de máximo planeo (L/D)]: el punto donde la tangente desde el origen toca la curva. A esa velocidad recorres la mayor distancia posible por cada metro de altura perdido; es tu velocidad de planeo en aire en calma.

#figure([
#box(image("imagenes/07-cap02-polar-anotada.png"))
], caption: figure.caption(
position: bottom, 
[
La curva polar y sus dos velocidades clave
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap02-polar-anotada>


#block[
#callout(
body: 
[
Aprende de memoria estos dos valores para tu modelo de planeador. En aire en calma no hay motivo para volar a velocidades intermedias si lo que buscas es llegar lejos o aguantar en el aire.

]
, 
title: 
[
Airmanship
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
== El efecto del peso: la polar se desplaza
<el-efecto-del-peso-la-polar-se-desplaza>
¿Recuerdas el lastre de agua del capítulo anterior? Aquí está la explicación gráfica de por qué funciona. Al aumentar el peso (carga alar), la curva polar completa se desplaza hacia la derecha y hacia abajo, deslizándose a lo largo de la tangente desde el origen (#ref(<fig-07-cap02-polar-peso>, supplement: [Figura])). Las consecuencias son tres, y las tres caen en el examen:

- #strong[El planeo máximo (L/D) no cambia]: la tangente desde el origen toca la nueva curva con la misma pendiente. Un planeador de fineza 40 sigue teniendo fineza 40 cargado de agua.
- #strong[Ese planeo se alcanza a más velocidad]: si en vacío tu máximo planeo era a 95 km/h, con lastre puede ser a 110 km/h. Recorres los mismos kilómetros por metro de altura, pero más deprisa. Por eso el agua gana carreras en días fuertes.
- #strong[El mínimo descenso empeora]: la parte alta de la curva baja. En térmicas débiles, el planeador cargado sube peor o no sube. Es la otra cara de la moneda: el lastre es un préstamo que pagas en cada térmica floja.

#figure([
#box(image("imagenes/07-cap02-polar-peso.png"))
], caption: figure.caption(
position: bottom, 
[
Desplazamiento de la curva polar con el peso (lastre de agua)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap02-polar-peso>


== Teoría MacCready: ajustar la velocidad al día
<teoría-maccready-ajustar-la-velocidad-al-día>
Paul MacCready revolucionó el vuelo a vela con una idea simple: la velocidad entre térmicas debe depender de lo fuerte que esperes que sea la siguiente.

- #strong[Día fuerte, vuela rápido]: si esperas subir a 3 m/s, no te importa perder altura deprisa para llegar antes a la siguiente nube. El tiempo ganado compensa la altura perdida.
- #strong[Día flojo, vuela despacio]: si la siguiente térmica es débil, conserva tu altura. Si subes poco, corre poco.
- #strong[El anillo MacCready]: es el dial que rodea al variómetro. Ajusta el triángulo a la trepada esperada y el anillo te marca la velocidad que optimiza tu media de crucero.

== El efecto del viento y del aire descendente
<el-efecto-del-viento-y-del-aire-descendente>
La polar del manual de vuelo está trazada para aire en calma. En el mundo real, la masa de aire se mueve, y la velocidad óptima se mueve con ella (#ref(<fig-07-cap02-polar-viento>, supplement: [Figura])).

- #strong[Viento de cara]: tu cono de alcance se encoge y necesitas penetrar. Vuela más rápido que la velocidad de máximo planeo; una regla práctica es sumarle la mitad de la velocidad del viento.
- #strong[Viento de cola]: un regalo de la naturaleza. Vuela a la velocidad de máximo planeo, o un poco menos, y deja que el viento te empuje.
- #strong[Aire descendente (hundimiento)]: acelera. Cuanto antes salgas de la zona que te hunde, menos altura total pierdes.

#figure([
#box(image("imagenes/07-cap02-polar-viento.png"))
], caption: figure.caption(
position: bottom, 
[
Efecto del viento sobre la velocidad óptima: la tangente se desplaza
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap02-polar-viento>


== IAS y TAS: cuando el anemómetro te "miente"
<ias-y-tas-cuando-el-anemómetro-te-miente>
La polar del manual de vuelo está trazada en velocidad indicada (#strong[IAS], #emph[Indicated Airspeed]), que es lo que marca tu anemómetro. Pero el anemómetro mide presión dinámica, no velocidad real: a medida que subes y el aire se hace menos denso, tu velocidad verdadera (#strong[TAS], #emph[True Airspeed]) es cada vez mayor que la indicada. La regla aproximada: la TAS supera a la IAS en un 2 % por cada 300 m de altitud.

¿Por qué te importa esto en España? Porque buena parte de los aeródromos de vuelo a vela de la meseta están en torno a los 1.000 m de elevación, y en vuelo de térmica o de onda operarás habitualmente entre 2.000 y 4.000 m:

- #strong[Las velocidades de la polar se vuelan en IAS]: el máximo planeo y el mínimo descenso ocurren a la misma IAS de siempre; no tienes que corregir nada en el anemómetro para planear bien.
- #strong[Pero recorres más terreno del que crees]: a 3.000 m, una IAS de 100 km/h son unos 120 km/h de TAS. Tu planeo final cubre más kilómetros por minuto y tu deriva con viento también es mayor de lo que sugiere el instrumento.
- #strong[En la aproximación a un aeródromo alto, la sensación engaña]: con la IAS de aproximación correcta, el suelo pasa más deprisa de lo habitual y la carrera de aterrizaje será más larga. No "frenes" el avión por debajo de la velocidad indicada del manual: la pérdida ocurre a la misma IAS de siempre.

#block[
#callout(
body: 
[
Las limitaciones de velocidad de tu planeador (V#sub[NE] (Velocidad Nunca Exceder), V#sub[A] (Velocidad de Maniobra) en aire turbulento) figuran en el #strong[manual de vuelo aprobado (AFM)] y derivan de la certificación europea #strong[CS-22] para planeadores. Atención al volar alto: el #strong[flutter] depende de la TAS, por lo que la V#sub[NE] #strong[indicada] disminuye con la altitud. Esta reducción está prescrita por la norma #strong[CS 22.1505], que obliga a que dicha tabla figure como placa visible en la cabina. El AFM incluye una tabla de V#sub[NE] por altitudes ---por ejemplo, un planeador con V#sub[NE] de 250 km/h a nivel del mar puede quedar limitado a unos 200 km/h indicados a 6.000 m---. Consúltala antes de cualquier vuelo de onda.

]
, 
title: 
[
Normativa
]
, 
background_color: 
rgb("#f7dddc")
, 
icon_color: 
rgb("#CC1914")
, 
icon: 
fa-exclamation()
, 
body_background_color: 
white
)
]
== Planeo final y seguridad
<planeo-final-y-seguridad>
El planeo final es el tramo desde la última térmica hasta el aeródromo: un ejercicio de gestión de energía donde el margen de error tiende a cero.

- #strong[Calculador de planeo]: mecánico o digital, ajústalo siempre con un margen de seguridad.
- #strong[Altura de seguridad (#emph[safety height])]: nunca planifiques llegar al aeródromo con cero metros. Fija una altura de llegada (300 m, por ejemplo) y trátala como sagrada: es para volar el circuito de aterrizaje, no para estirar el planeo.
- #strong[El cono de alcance]: imagina un cono invertido que baja de tu planeador hasta el suelo. Lo que quede fuera de ese círculo es inalcanzable. Con viento de cara, el círculo se convierte en una elipse desplazada; tenlo siempre presente.

#block[
#callout(
body: 
[
Si tu calculador de planeo dice que llegas "justo", en realidad #strong[no llegas]. El calculador no sabe si encontrarás un hundimiento inesperado ni si el viento en cara será más fuerte a baja altura. Busca una alternativa antes de que el cono de alcance se cierre.

]
, 
title: 
[
Seguridad
]
, 
background_color: 
rgb("#fcefdc")
, 
icon_color: 
rgb("#EB9113")
, 
icon: 
fa-exclamation-triangle()
, 
body_background_color: 
white
)
]
#postit[
#strong[Resumen del Capítulo: Polar de Velocidades y MacCready]

- #strong[La polar]: es tu curva de rendimiento. Conócela: te da la velocidad para aguantar más tiempo en el aire (mínimo descenso) y la velocidad para llegar más lejos (máximo planeo).
- #strong[Efecto del peso]: el lastre desplaza la polar a la derecha y abajo. El planeo máximo no cambia, pero se vuela a más velocidad; el mínimo descenso empeora. El agua es para días fuertes.
- #strong[Teoría MacCready]: ajusta la velocidad de crucero a la térmica que esperas. Día fuerte, vuela rápido (cambias altura por tiempo); día flojo, vuela despacio y conserva.
- #strong[Efecto del viento]: con viento de cara, vuela más rápido (suma medio viento a tu velocidad de máximo planeo) para penetrar mejor. Con viento de cola, vuela a máximo planeo y déjate empujar.
- #strong[IAS vs TAS]: la polar se vuela en IAS, pero en altura la TAS es mayor (\~2 % por cada 300 m). Recorres más terreno del que crees y la V#sub[NE] indicada disminuye con la altitud (flutter): consulta la tabla del AFM antes de volar en onda.
- #strong[Planeo final]: calcula la llegada con margen. Es mejor llegar a 200 m sobre el campo y usar los frenos que pasar a ras de los árboles rezando por una burbuja.

]
= Planificación de vuelo y definición de tareas
<planificación-de-vuelo-y-definición-de-tareas>
#quote(block: true)[
Volar distancia no es solo una cuestión de habilidad en la palanca; es un juego de estrategia donde la gestión del tiempo y la meteorología son tus principales recursos. Una tarea bien planificada es la mitad del éxito de un vuelo de campo.

En este capítulo aprenderás:

- #strong[La velocidad media]: el cálculo de la ventana de convección y el radio de acción real del día.
- #strong[Triángulo FAI y AAT]: dos tipos de tarea, dos estrategias mentales distintas.
- #strong[La planificación sobre la orografía española]: valles ciegos, puntos de escape y líneas de convergencia.
- #strong[El equipo de supervivencia]: qué exige la normativa europea cuando la ruta complica un eventual rescate.
- #strong[Los mínimos personales]: el "interruptor" que te convierte de competidor en superviviente.
]

== Velocidad media: la clave de la distancia
<velocidad-media-la-clave-de-la-distancia>
En el vuelo a vela, la velocidad media determina cuántos kilómetros puedes recorrer antes de que el sol baje y la convección muera. Y la forma de subirla es menos intuitiva de lo que parece.

- #strong[No pares en térmicas flojas]: la velocidad media no sube por volar más deprisa entre nubes, sino por no pararte a virar en ascendencias que están por debajo de la media del día.
- #strong[Consistencia]: mantener un flujo constante y aprovechar las calles de nubes para avanzar sin virar es lo que de verdad dispara la media.
- #strong[La ventana del día]: si el día ofrece 6 horas de convección y tu media es de 50 km/h, tu radio de acción real da para una tarea de unos 300 km. Intentar más es comprar papeletas para un aterrizaje fuera de campo.

== Triángulo FAI y AAT: dos formas de competir
<triángulo-fai-y-aat-dos-formas-de-competir>
#strong[↗ MÁS ALLÁ DEL EXAMEN.] Los tipos de tarea de competición (triángulo FAI, AAT) y la estrategia de regata no deberían ser materia de examen. Se incluyen porque son el paso natural del vuelo de distancia; léelos como iniciación.

Según el tipo de tarea, tu estrategia mental cambia por completo (#ref(<fig-07-cap03-fai-vs-aat>, supplement: [Figura])).

- #strong[Triángulo FAI]: los puntos de viraje son fijos y precisos. La navegación es rígida: pasas por el vértice o la tarea no vale.
- #strong[Tarea de área asignada (AAT)]: alrededor de cada punto hay un sector circular grande, y tú decides dónde virar dentro de él. Si el día está mejor de lo previsto, vete al fondo del área para sumar distancia; si se está cerrando, toca el borde más cercano y vuelve a casa antes de que se agote la térmica.

#figure([
#box(image("imagenes/07-cap03-fai-vs-aat.png"))
], caption: figure.caption(
position: bottom, 
[
Triángulo FAI con vértices fijos frente a tarea AAT con áreas asignadas
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap03-fai-vs-aat>


== Meteorología: tu motor invisible
<meteorología-tu-motor-invisible>
Antes de despegar debes conocer el ciclo de vida del cielo de ese día.

- #strong[La ventana de convección] (#ref(<fig-07-cap03-ventana-conveccion>, supplement: [Figura])): identifica la hora de disparo de las primeras térmicas (el #strong[trigger]) y la hora a la que muere la convección. Planifica el paso por las zonas difíciles (sombras, montañas) durante las horas de máxima insolación.
- #strong[Sondeo y base de nube]: la altura de la inversión y la base de nube definen tu espacio de trabajo. Cuanto mayor sea el margen entre la base y el suelo, más segura será tu progresión.

#figure([
#box(image("imagenes/07-cap03-ventana-conveccion.png"))
], caption: figure.caption(
position: bottom, 
[
La ventana de convección: el día térmico como línea temporal
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap03-ventana-conveccion>


#block[
#callout(
body: 
[
Recuerda siempre verificar los NOTAM y los espacios aéreos controlados en tu ruta. Una tarea que cruce un TMA sin autorización es una tarea fallida, independientemente de la distancia recorrida.

]
, 
title: 
[
Seguridad
]
, 
background_color: 
rgb("#fcefdc")
, 
icon_color: 
rgb("#EB9113")
, 
icon: 
fa-exclamation-triangle()
, 
body_background_color: 
white
)
]
== Planificar sobre la orografía española
<planificar-sobre-la-orografía-española>
En España, la mayoría de las tareas de distancia se juegan sobre terreno montañoso o en su área de influencia. La orografía no es solo un obstáculo: es a la vez tu fuente de energía y tu principal riesgo de planificación.

- #strong[Valles ciegos]: un valle que se estrecha y asciende sin campos aterrizables ni salida volable es una trampa clásica de montaña. Al trazar la ruta sobre la carta, identifica estos embudos y planifica el cruce de las sierras por collados con escapatoria a ambos lados. Regla práctica: nunca te comprometas con un valle sin tener resuelto cómo salir de él con la altura que tendrás en ese punto, no con la que te gustaría tener.
- #strong[Puntos de escape]: marca en la planificación los aeródromos y zonas de campos aterrizables que flanquean cada tramo de la ruta. Cada segmento de la tarea debe responder a la pregunta: "si la térmica muere aquí, ¿hacia dónde planeo?". Si un tramo no tiene respuesta, replantea la ruta o fija una altura mínima de cruce más exigente.
- #strong[Sistemas organizados de sustentación]: las mesetas generan #strong[líneas de convergencia] y las grandes cadenas (el Sistema Central es el ejemplo clásico) disparan #strong[ondas de montaña] a sotavento. Planificar la tarea a lo largo de estas estructuras ---en lugar de cruzarlas perpendicularmente--- multiplica la velocidad media. Los fenómenos en sí (convergencias, onda, efecto Föhn) los estudiaste en el #strong[Libro 3 --- Meteorología], capítulos 2 y 8; aquí la lección es estratégica: la ruta más corta sobre el mapa rara vez es la más rápida sobre el terreno.
- #strong[Zonas de sombra]: las caras norte y los valles profundos entran en sombra horas antes que las mesetas. Planifica el paso por las zonas comprometidas durante las horas centrales del día.

== Equipo de supervivencia: cuando la ruta complica el rescate
<equipo-de-supervivencia-cuando-la-ruta-complica-el-rescate>
Una tarea sobre sierras despobladas o grandes masas forestales exige preguntarse: si aterrizo fuera (o salto en paracaídas), ¿cuánto tardarán en encontrarme y qué necesito hasta entonces? La respuesta no es solo de sentido común: es un requisito normativo.

#block[
#callout(
body: 
[
El Reglamento (UE) 2018/1976 (#strong[Part-SAO]), que regula las operaciones de planeadores en Europa, establece en #strong[SAO.IDE.125] que los planeadores que operen sobre zonas donde la búsqueda y el salvamento serían especialmente difíciles deben llevar el equipo de salvamento y señalización adecuado al área sobrevolada. Su AMC1 concreta el mínimo: un #strong[ELT], una #strong[baliza personal de localización (PLB)] o localizador equivalente registrado, equipo para hacer señales de socorro y el equipo de supervivencia apropiado a la ruta. Para vuelos sobre agua aplica además #strong[SAO.IDE.120]: el piloto al mando debe valorar antes del vuelo los riesgos de supervivencia en caso de amerizaje.

]
, 
title: 
[
Normativa
]
, 
background_color: 
rgb("#f7dddc")
, 
icon_color: 
rgb("#CC1914")
, 
icon: 
fa-exclamation()
, 
body_background_color: 
white
)
]
En la práctica, para una travesía sobre el monte español: agua, ropa de abrigo (a 2.500 m hace frío incluso en julio), un PLB o ELT registrado, teléfono móvil cargado y un espejo de señales o chaleco reflectante pesan menos de dos kilos y caben detrás del respaldo. Inclúyelos en la lista de equipo de la tarea, no en la categoría de "ya si eso".

== Mínimos personales: el interruptor de seguridad
<mínimos-personales-el-interruptor-de-seguridad>
Un buen piloto sabe cuándo dejar de ser competidor para convertirse en superviviente.

- #strong[Mínima térmica aceptable]: por debajo de cierta altura (500 m sobre el suelo, por ejemplo), cualquier térmica es buena. Por encima, selecciona solo las mejores.
- #strong[Altura de decisión]: fija un punto en el que dejas de buscar la siguiente térmica y te concentras solo en elegir un campo para aterrizar. No esperes a estar a 100 metros para mirar dónde. Los criterios para elegir y evaluar el campo desde el aire ---la regla de las #strong[7 S]--- los tienes desarrollados en el #strong[Libro 6 --- Procedimientos operativos], capítulo 5; repásalos antes de cada travesía.

#block[
#callout(
body: 
[
Tus mínimos deben ser más conservadores si vuelas en zonas desconocidas o con planeadores de bajo rendimiento. La seguridad nunca es negociable.

]
, 
title: 
[
Airmanship
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
#postit[
#strong[Resumen del Capítulo: Planificación de Tareas]

- #strong[Velocidad media]: no gana el que corre más, sino el que para menos. Evita virar térmicas flojas; la clave está en la consistencia y en elegir la ruta bajo las calles de nubes.
- #strong[Meteorología]: estudia el sondeo antes de despegar. ¿A qué hora empieza la convección? ¿Cuándo muere? Planifica la ventana de vuelo para cruzar lo difícil en las horas centrales.
- #strong[Orografía]: la ruta más corta sobre el mapa rara vez es la más rápida sobre el terreno. Evita los valles ciegos, marca puntos de escape en cada tramo y traza la tarea a lo largo de convergencias y ondas, no perpendicular a ellas.
- #strong[Equipo de supervivencia]: sobre zonas donde el rescate sería difícil, el Part-SAO (SAO.IDE.125) exige ELT o PLB, equipo de señales y supervivencia adecuados a la ruta. Agua, abrigo y baliza: menos de dos kilos que pueden salvarte la vida.
- #strong[Mínimos personales]: fíjalos antes de salir. ¿Altura mínima para seguir en ruta? ¿Térmica mínima aceptable? Si bajas de ahí, cambia el chip de competición a supervivencia.

]
= Plan de vuelo ICAO
<plan-de-vuelo-icao>
#quote(block: true)[
El plan de vuelo (FPL) es mucho más que un trámite administrativo: es tu seguro de vida en los vuelos de distancia. En vuelo local no suele hacer falta, pero en cuanto decides alejarte del cono de seguridad de tu aeródromo se convierte en la única forma de que los servicios de búsqueda y rescate (SAR) sepan dónde buscarte si no regresas.

En este capítulo aprenderás:

- #strong[Cuándo es obligatorio el FPL] según SERA.4001 y su aplicación en España.
- #strong[Las casillas clave del formulario ICAO] para un planeador, incluida la información suplementaria (casilla 19).
- #strong[Cómo abrir un plan de vuelo en el aire (AFIL)] con los centros de información de vuelo españoles.
- #strong[Las particularidades de los motoveleros (TMG)] y la autonomía de combustible.
- #strong[El cierre del plan]: el paso que nunca, jamás, puedes olvidar.
]

== ¿Cuándo es obligatorio?
<cuándo-es-obligatorio>
Según el reglamento #strong[SERA.4001] (SERA (Standardised European Rules of the Air)) y su aplicación en España, un planeador necesita plan de vuelo en estos casos:

- #strong[Vuelos transfronterizos]: siempre que cruces una frontera internacional.
- #strong[Servicio de control]: el plan de vuelo es obligatorio para todo vuelo al que se preste servicio de control de tránsito aéreo ---en la práctica, #strong[clases B, C y D]--- y cuando el origen o el destino sea un #strong[aeródromo controlado]. Atención al matiz de la clase E: es espacio controlado, pero al VFR no se le presta allí servicio de control, así que no necesita plan de vuelo, ni radio, ni autorización (SERA.4001 b)).
- #strong[Cuando lo requiera la autoridad ATS]: en zonas o rutas designadas, para facilitar los servicios de información, alerta y SAR o la coordinación con unidades militares.
- #strong[Vuelo VFR nocturno]: si el vuelo va a salir de las inmediaciones del aeródromo (caso excepcional en planeador, pero es pregunta de examen).
- #strong[Sobre el mar]: en España, para vuelos que se alejen más de 12 millas náuticas de la costa (supuesto nacional; consulta el valor vigente en el AIP-España, ENR 1.10).
- #strong[Vuelo de distancia]: no es obligatorio en espacio G (no controlado), pero sí muy recomendable: es lo que activa los servicios de alerta si no apareces.

#block[
#callout(
body: 
[
Los plazos de presentación (AIP-España, ENR 1.10) dependen de qué pidas y desde dónde salgas. Si solicitas #strong[servicio de control de tránsito aéreo], presenta el FPL al menos #strong[60 minutos antes] de la hora estimada de fuera de calzos (EOBT); desde un aeródromo controlado que no opere H24, el mínimo se reduce a #strong[30 minutos]. Si despegas de un #strong[aeródromo no controlado] y solo solicitas servicio de información y alerta, basta con presentarlo #strong[antes de la salida]. En vuelo (#strong[AFIL]), debe transmitirse con antelación suficiente para que la dependencia ATS lo reciba antes de entrar en espacio aéreo controlado.

]
, 
title: 
[
Normativa
]
, 
background_color: 
rgb("#f7dddc")
, 
icon_color: 
rgb("#CC1914")
, 
icon: 
fa-exclamation()
, 
body_background_color: 
white
)
]
== Casillas clave para planeadores
<casillas-clave-para-planeadores>
Rellenar un formulario ICAO para un avión sin motor tiene sus peculiaridades (#ref(<fig-07-cap04-fpl-casillas>, supplement: [Figura])):

- #strong[Casilla 8 (reglas de vuelo y tipo de vuelo)]: la casilla lleva dos datos. Primero las #strong[reglas de vuelo]: #strong[V] (VFR) ---aunque vueles en competición, legalmente eres un vuelo visual---. Después el #strong[tipo de vuelo]: para un planeador deportivo, #strong[G] (aviación general). Así que en la casilla 8 va #strong[V] y #strong[G].
- #strong[Casilla 9 (tipo de aeronave)]: pon #strong[GLID] (#strong[glider]).
- #strong[Casilla 15 (velocidad y ruta)]: como velocidad, tu media de crucero estimada, con #strong[K] para km/h (ej. K0120) o #strong[N] para nudos (ej. N0065). Como ruta, los puntos de viraje o áreas (ej. DCT VTC-1 DCT VTC-2 DCT).
- #strong[Casilla 16 (destino y alternativos)]: si piensas aterrizar fuera, usa #strong[ZZZZ] y detalla el lugar en la casilla 18.
- #strong[Casilla 18 (otros datos)]: aquí desarrollas los ZZZZ de las casillas anteriores con nombre y coordenadas, por ejemplo #NormalTok("DEP/CAMPO DE SANTOS 4035N00407W"); o #NormalTok("DEST/AREA DE LA TAREA");. Si no hay nada que indicar, escribe #NormalTok("0"); (cero).
- #strong[Casilla 19 (información suplementaria)]: no se transmite con el mensaje FPL, pero es la información que usará el SAR si no apareces: autonomía (#NormalTok("E/");, en planeador, las horas hasta la puesta de sol), personas a bordo (#NormalTok("P/");), equipo de radio de emergencia (#NormalTok("R/");), equipo de supervivencia (#NormalTok("S/");) y si llevas #strong[ELT] o baliza personal (PLB). Rellénala con el mismo cuidado que el resto: puede acortar tu rescate en horas.

#figure([
#box(image("imagenes/07-cap04-fpl-casillas.png"))
], caption: figure.caption(
position: bottom, 
[
Formulario de plan de vuelo ICAO rellenado para un vuelo de distancia en planeador
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap04-fpl-casillas>


== Abrir el plan en el aire: el AFIL
<abrir-el-plan-en-el-aire-el-afil>
¿Y si despegas de un campo sin cobertura ni acceso a la aplicación ICARO de ENAIRE? El reglamento prevé la presentación del plan de vuelo #strong[en vuelo (AFIL, #emph[Air-Filed Flight Plan])], transmitiéndolo por radio a una dependencia ATS:

+ Sintoniza el #strong[Centro de Información de Vuelo (FIC)] de tu región: en España, #strong[Madrid Información], #strong[Barcelona Información] o #strong[Canarias Información] (consulta la frecuencia del sector en el AIP de ENAIRE o en la carta de navegación; varía según la zona).
+ En el primer contacto, indica: identificación, tipo de aeronave (GLID), posición y altitud, intenciones (ruta y destino) y la petición expresa de #strong[abrir plan de vuelo en el aire].
+ Ten preparados los datos del formulario antes de transmitir: el operador te pedirá esencialmente las mismas casillas que en tierra (velocidad, ruta, destino, autonomía y personas a bordo).
+ Recuerda el plazo: el AFIL debe transmitirse #strong[con antelación suficiente] para que la dependencia lo reciba antes de que entres en espacio aéreo controlado.

#block[
#callout(
body: 
[
El FIC no es solo para abrir planes de vuelo. En travesía por zonas como el Sistema Central, mantener escucha con Madrid Información te da tráfico esencial, NOTAM de última hora y un canal ya abierto si las cosas se tuercen. Apunta las frecuencias de los sectores de tu ruta en la planificación, junto a los puntos de escape.

]
, 
title: 
[
Airmanship
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
== Motoveleros (TMG)
<motoveleros-tmg>
Si vuelas un motovelero de turismo (TMG) y haces la navegación a motor, las reglas cambian: a efectos del plan de vuelo eres una aeronave propulsada normal. La autonomía que declares debe ser la de combustible real ---capacidad de los tanques y consumo del motor---, no las horas de sol que queden.

== Cierre del plan de vuelo: el paso crítico
<cierre-del-plan-de-vuelo-el-paso-crítico>
Un plan de vuelo abierto y no cerrado dispara una operación SAR: helicópteros y equipos de emergencia movilizados. Si es por un olvido, además del bochorno, las multas son severas.

- #strong[Cómo cerrar]: llama a la oficina ARO (oficina de notificación ATS), avisa a la torre de control por radio antes de aterrizar o usa una aplicación oficial como ICARO de ENAIRE.
- #strong[Plazos]: tienes 30 minutos desde la hora estimada de llegada antes de que empiecen a preocuparse. Si aterrizas en un campo sin cobertura, intenta avisar a alguien del club o busca un teléfono cuanto antes.

#block[
#callout(
body: 
[
Nunca te vayas a casa sin confirmar que tu plan de vuelo está cerrado. Si aterrizas fuera de campo, tu prioridad tras asegurar el avión es notificar tu estado y posición para evitar falsas alarmas SAR.

]
, 
title: 
[
Seguridad
]
, 
background_color: 
rgb("#fcefdc")
, 
icon_color: 
rgb("#EB9113")
, 
icon: 
fa-exclamation-triangle()
, 
body_background_color: 
white
)
]
#postit[
#strong[Resumen del Capítulo: Plan de Vuelo ICAO]

- #strong[¿Cuándo es obligatorio?]: al cruzar fronteras, cuando se te presta servicio de control (clases B, C y D; en la E el VFR vuela sin plan, sin radio y sin autorización), desde o hacia aeródromos controlados, en VFR nocturno fuera de las inmediaciones del aeródromo y cuando lo exija la autoridad ATS. Muy recomendable en vuelos de distancia para activar los servicios de alerta (SAR).
- #strong[Casillas clave]: velocidad (casilla 15): tu media de crucero, con #strong[K] para km/h (K0120) o #strong[N] para nudos (N0065). Destino fuera de aeródromo: ZZZZ en la casilla 16 y el detalle con coordenadas en la 18. Casilla 19: autonomía hasta la puesta de sol, personas a bordo, ELT/PLB y equipo de supervivencia; es lo que usará el SAR.
- #strong[AFIL]: sin cobertura en tierra, puedes abrir el plan por radio con el FIC (Madrid, Barcelona o Canarias Información), con antelación suficiente antes de entrar en espacio controlado.
- #strong[Motoveleros (TMG)]: si vuelas un TMG como avión de turismo, sigues las mismas reglas que una avioneta: declara autonomía de combustible real, no solar.
- #strong[Cierre del plan]: si aterrizas en un campo y te vas a cenar sin cerrar el plan, se activa una operación de búsqueda y rescate. Llama a la oficina de notificación de los servicios de tránsito aéreo (ARO) o a la torre en cuanto tengas cobertura.

]
= Monitoreo del vuelo y replanificación en vuelo
<monitoreo-del-vuelo-y-replanificación-en-vuelo>
#quote(block: true)[
Una vez que has despegado y tu tarea está en marcha, el plan de vuelo deja de ser una hoja estática y se convierte en un proceso vivo de seguimiento. La atmósfera cambia, y el piloto que no adapta su estrategia en vuelo es el que acaba aterrizando en un campo antes de tiempo.

En este capítulo aprenderás:

- #strong[El cono de alcance]: tu burbuja de seguridad y cómo la deforma el viento.
- #strong[El cálculo mental en cabina]: reglas rápidas de alcance y de deriva sin depender del GPS.
- #strong[El monitoreo del planeo final en 3 puntos]: cómo detectar una descendencia continua antes de que sea tarde.
- #strong[El punto de no retorno (PNR)] y el cambio de mentalidad que implica cruzarlo.
- #strong[El factor humano]: cómo la hipoxia y la deshidratación degradan justo las capacidades que la replanificación necesita.
]

== El cono de alcance: tu burbuja de seguridad
<el-cono-de-alcance-tu-burbuja-de-seguridad>
Imagina que de tu planeador baja un cono invertido hasta el suelo. Todo lo que quede dentro de ese círculo es terreno alcanzable si no encuentras ni una térmica más (#ref(<fig-07-cap05-cono-alcance>, supplement: [Figura])).

- #strong[La forma del cono]: en aire en calma es un círculo perfecto. Con viento de cara fuerte se deforma en una elipse que se encoge por delante y se estira por detrás.
- #strong[El horizonte de decisión]: no esperes a que tu destino esté en el borde del cono. Si el objetivo queda fuera de tu alcance visual o instrumental, toca replanificar.

#figure([
#box(image("imagenes/07-cap05-cono-alcance.png"))
], caption: figure.caption(
position: bottom, 
[
El cono de alcance para una fineza de 1:30 habiendo alcanzado 1000m
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap05-cono-alcance>


== Cálculo mental: reglas rápidas en cabina
<cálculo-mental-reglas-rápidas-en-cabina>
En momentos de estrés no siempre podrás fiarte del ordenador de vuelo. Tienes que saber estimar de cabeza:

- #strong[De km/h a metros por segundo]: divide entre 3,6. A 100 km/h avanzas unos 28 metros por segundo; en un minuto, casi 1,7 km.
- #strong[Alcance desde 1.000 m]: como aproximación conservadora, con finezas de 20 a 30 (las de un planeador de escuela o estándar), a 1.000 m de altura tienes un alcance de 20 a 30 km en aire en calma. Con viento de cara, divide ese alcance por dos para estar seguro.
- #strong[Margen para el circuito]: suma siempre 300 metros a tu cálculo. Si el aeródromo está a 20 km y tu planeador planea 1:30, necesitas unos 670 metros de planeo puro; con los 300 de seguridad, la cuenta sale en 1.000 metros redondos.

#block[
#callout(
body: 
[
#strong[La térmica es tu manga de viento.] Mientras espiraleas, tus círculos derivan con el viento: la dirección y la distancia que te desplazas en cada giro te dicen de dónde sopla y con cuánta fuerza, sin mirar ningún instrumento. Para corregir la deriva en planeo recto: a 100 km/h, cada #strong[10 km/h de viento cruzado ≈ 6° de corrección] hacia el viento. Con 20 km/h cruzados, apunta unos 12° al lado del viento y comprueba contra una referencia lejana del terreno que tu rumbo sobre el suelo se mantiene.

]
, 
title: 
[
Regla de oro
]
, 
background_color: 
rgb("#ccf1e3")
, 
icon_color: 
rgb("#00A047")
, 
icon: 
fa-lightbulb()
, 
body_background_color: 
white
)
]
== Monitoreo del planeo final: el método de los 3 puntos
<monitoreo-del-planeo-final-el-método-de-los-3-puntos>
Calcular el planeo final una sola vez y volarlo a fe ciega es apostar la tarea ---y el planeador--- a que la masa de aire no cambie. El método profesional verifica el margen en tres puntos (#ref(<fig-07-cap05-planeo-3-puntos>, supplement: [Figura])):

+ #strong[Al iniciar el planeo final]: anota tu altura de llegada prevista (por ejemplo, llegada calculada con +300 m sobre el campo).
+ #strong[En el punto medio del tramo]: recalcula. Si el margen se mantiene en torno a +300 m, la masa de aire se comporta como esperabas. Si ha bajado a +150 m y sigue cayendo, estás atravesando descendencia o más viento de cara del previsto. Acelera la decisión, no el planeador: busca ya tu alternativa.
+ #strong[A unos 5 km del destino]: última verificación con margen real para incorporarte al circuito. A esta distancia el resultado ya no es una estimación: es una realidad.

La fuerza del método está en la tendencia: una lectura te dice dónde estás; dos lecturas comparadas te dicen hacia dónde vas. Una descendencia continua de 0,5 m/s se pierde entre el ruido del variómetro, pero salta a la vista al comparar el margen del punto inicial con el del punto medio.

#figure([
#box(image("imagenes/07-cap05-planeo-3-puntos.png"))
], caption: figure.caption(
position: bottom, 
[
Monitoreo del planeo final en 3 puntos: la tendencia delata el problema
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap05-planeo-3-puntos>


- #strong[Caja de seguridad]: durante todo el planeo final, mantén al menos un aeródromo alternativo o un campo conocido dentro del cono de alcance con una llegada mínima de 300 m AGL. El día que el margen del punto medio se desplome, agradecerás tener la alternativa ya elegida.

== Punto de no retorno (PNR)
<punto-de-no-retorno-pnr>
El PNR es el momento del vuelo en el que ya no tienes altura para volver al aeródromo de salida ni a la última zona segura que dejaste atrás.

- #strong[Reconocimiento]: sé consciente del instante exacto en que cruzas esa línea invisible. A partir de ahí solo hay un camino: hacia delante, hacia el siguiente punto seguro (aeródromo alternativo o campo seleccionado).
- #strong[Cambio de chip]: cruzado el PNR, tu prioridad número uno deja de ser la tarea y pasa a ser la localización constante de campos aterrizables.

#block[
#callout(
body: 
[
Cantar en voz alta (o para ti mismo) "He cruzado el PNR" te ayuda mentalmente a dejar de mirar el GPS de la tarea y empezar a mirar seriamente el suelo.

]
, 
title: 
[
Airmanship
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
, 
body_background_color: 
white
)
]
== Altura de seguridad y replanificación
<altura-de-seguridad-y-replanificación>
La altura de seguridad (#emph[safety height]) no se negocia: es el margen que absorbe un error de cálculo o un hundimiento inesperado al llegar al campo.

- #strong[La regla del circuito]: fija una altura (300 m, por ejemplo) en la que, si no has encontrado térmica, abandonas la búsqueda y te incorporas al circuito de tráfico del aeródromo o campo elegido.
- #strong[Replanifica a tiempo]: si la ruta planificada está bloqueada por sombras, lluvia o espacio aéreo, no esperes a estar bajo para decidir. Desvíate pronto: es mejor hacer 10 km de más con altura que 5 km directos contra el suelo.

== El factor humano: tu calculadora también se degrada
<el-factor-humano-tu-calculadora-también-se-degrada>
Todo lo anterior ---reglas mentales, método de los 3 puntos, decisión del PNR--- depende de un único instrumento: tu cerebro. Y ese instrumento pierde precisión justo cuando más lo necesitas:

- #strong[Hipoxia]: en vuelos de onda por encima de 3.000 m sin oxígeno suplementario, la capacidad de cálculo mental y el juicio se degradan de forma traicionera: el primer síntoma es, precisamente, no notar los síntomas. Un planeo final calculado con hipoxia incipiente es un planeo final mal calculado.
- #strong[Deshidratación y fatiga]: tras 4 o 5 horas de tarea bajo la cubierta, la deshidratación enlentece las decisiones y favorece la fijación: seguir hacia el objetivo "porque era el plan" en lugar de replanificar. La demora en aceptar una toma fuera de campo es exactamente el error que este capítulo intenta evitar.

Los mecanismos fisiológicos, el Tiempo de Conciencia Útil y el uso del oxígeno se estudian en el #strong[Libro 2 --- Factores humanos], capítulo 4. Aquí quédate con la regla operativa: bebe de forma programada (no cuando tengas sed), usa oxígeno según el manual en vuelos altos y, si llevas muchas horas de tarea, desconfía de tus propias estimaciones y añade margen a todos los cálculos.

#block[
#callout(
body: 
[
Si tu ordenador de vuelo indica que llegas con 0 metros, #strong[no llegas]. Ese cálculo es teórico: en el mundo real el aire casi nunca está en calma absoluta. Lleva siempre un colchón de altura y no dejes que se consuma.

]
, 
title: 
[
Seguridad
]
, 
background_color: 
rgb("#fcefdc")
, 
icon_color: 
rgb("#EB9113")
, 
icon: 
fa-exclamation-triangle()
, 
body_background_color: 
white
)
]
#postit[
#strong[Resumen del Capítulo: Monitoreo y Replanificación]

- #strong[Cono de alcance]: visualiza el cono bajo el planeador; lo que queda fuera es inalcanzable. Ten siempre una opción de aterrizaje segura dentro del cono.
- #strong[Cálculo mental]: 1 km de altura da 20-30 km de alcance, según el viento y el avión; con viento de cara fuerte, divide por dos. Para la deriva: a 100 km/h, cada 10 km/h de viento cruzado pide unos 6° de corrección.
- #strong[Planeo final en 3 puntos]: verifica el margen de llegada al inicio, en el punto medio y a 5 km del destino. La tendencia entre lecturas delata a tiempo la descendencia continua o el viento imprevisto.
- #strong[Punto de no retorno]: llega un momento en que ya no vuelves a casa. Tenlo identificado. A partir de ahí, tu objetivo es el siguiente aeródromo o campo seguro.
- #strong[Factor humano]: hipoxia, deshidratación y fatiga degradan el cálculo mental y retrasan la decisión de aterrizar fuera. Bebe de forma programada, usa oxígeno en vuelos altos y añade margen cuando lleves horas de tarea (detalles en el #strong[Libro 2 --- Factores humanos], capítulo 4).
- #strong[Altura de seguridad (#emph[safety height])]: fija un margen intocable para llegar al campo (300 m, por ejemplo). Esa altura es para el circuito, no para planear. Si el calculador dice que llegas con 0 m, no llegas.

]
#show: appendices.with("Apéndices", hide-parent: true)
#heading(level: 1, numbering: none)[Apéndices]
= Syllabus Oficial EASA - Planificación y Rendimiento de Vuelo
<syllabus-oficial-easa---planificación-y-rendimiento-de-vuelo>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Planificación y Rendimiento de Vuelo] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- #strong[7.1. Masa y centro de gravedad.]
- #strong[7.2. Polar de velocidades (Speed Polar) de planeadores o velocidad de crucero.]
- #strong[7.3. Planificación de vuelo y definición de tareas.]
- #strong[7.4. Plan de vuelo ICAO (ATS Flight Plan).]
- #strong[7.5. Monitoreo del vuelo y replanificación en vuelo.]

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

== Ponte a prueba
<ponte-a-prueba>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/07-planificacion-rendimiento/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

= Glosario de términos
<glosario-de-términos>
Este glosario contiene las definiciones y acrónimos más relevantes de planificación y rendimiento de vuelo aplicables a la licencia de piloto de planeador (SPL).

/ #strong[Brazo de palanca (Arm)]: #block[
Distancia horizontal medida desde el datum (línea de referencia) hasta el centro de gravedad de un elemento o peso a bordo del planeador. (Mencionado en: cap. 1)
]

/ #strong[Carga alar]: #block[
Relación entre la masa total del planeador y la superficie de sus alas. Se expresa en kg/m² e influye directamente en las velocidades de crucero y de pérdida. (Mencionado en: cap. 2)
]

/ #strong[CG (Centro de gravedad)]: #block[
Punto teórico donde se considera aplicada la resultante de todas las fuerzas de gravedad que actúan sobre el planeador. Su ubicación longitudinal es clave para la estabilidad y el control del vuelo. (Mencionado en: cap. 1)
]

/ #strong[Coeficiente de planeo (L/D, #emph[finesse])]: #block[
Relación entre la sustentación (#emph[Lift]) y la resistencia total (#emph[Drag]) de la aeronave, equivalente a la distancia horizontal recorrida por unidad de altura perdida en aire en calma (un planeador con L/D de 40 recorre 40 km por cada kilómetro de altura cedida). (Mencionado en: cap. 2)
]

/ #strong[Datum (Línea de referencia)]: #block[
Plano vertical imaginario a partir del cual se miden todas las distancias horizontales para calcular el centrado y el brazo de palanca de los componentes del planeador. (Mencionado en: cap. 1)
]

/ #strong[FPL (Plan de vuelo / Flight Plan)]: #block[
Información estructurada que se suministra a los servicios de tránsito aéreo sobre un vuelo proyectado, siendo obligatorio en cruce de fronteras o espacio controlado. (Mencionado en: cap. 4)
]

/ #strong[Lastre de agua (Water ballast)]: #block[
Agua cargada en tanques específicos situados en las alas para aumentar la masa del planeador y su carga alar, desplazando la curva polar de velocidades hacia valores más altos para volar más rápido con el mismo ángulo de planeo. (Mencionado en: cap. 1)
]

/ #strong[Lastre de cola (Fin ballast)]: #block[
Pequeño depósito de agua o soporte de pesas en la deriva que compensa el desplazamiento del CG producido por el lastre de las alas o por un piloto pesado, restaurando el centrado óptimo. Olvidar vaciarlo con un piloto ligero genera un CG peligrosamente retrasado. (Mencionado en: cap. 1)
]

/ #strong[Momento]: #block[
Efecto de giro o tendencia rotacional ejercida por un peso en función de su brazo de palanca respecto al datum. Se calcula multiplicando la masa del objeto por su brazo de palanca. (Mencionado en: cap. 1)
]

/ #strong[MTOW (Masa Máxima al Despegue / Maximum Take-Off Weight)]: #block[
Masa máxima autorizada o certificada con la que el planeador puede iniciar el vuelo, determinada por límites estructurales y de rendimiento aerodinámico. (Mencionado en: cap. 1)
]

/ #strong[Polar de velocidades]: #block[
Gráfico o curva matemática que relaciona la velocidad indicada (IAS) del planeador con su velocidad o tasa de caída (sink rate). Define las velocidades operativas óptimas. (Mencionado en: cap. 2)
]

/ #strong[Teoría MacCready (Anillo MacCready)]: #block[
Método de optimización de velocidad de vuelo que indica la velocidad óptima a volar entre térmicas dada la intensidad esperada de la siguiente corriente térmica ascendente. (Mencionado en: cap. 2)
]

/ #strong[Velocidad de mejor planeo (V#sub[G])]: #block[
Velocidad a la que el planeador obtiene su máxima distancia recorrida por unidad de altura perdida en aire en calma (máxima fineza, correspondiente al L/D máximo determinado por la tangente a la curva polar). (Mencionado en: cap. 2)
]

/ #strong[Velocidad de mínimo descenso (Minimum Sink Speed)]: #block[
Velocidad a la que el planeador pierde la menor cantidad de altura posible por unidad de tiempo (obtenida en el vértice superior de la curva polar), óptima para centrar y explotar térmicas débiles. (Mencionado en: cap. 2)
]

= Bibliografía y fuentes
<bibliografía-y-fuentes>
Esta bibliografía es común a los nueve libros del manual de formación SPL. Reúne las fuentes normativas, los manuales técnicos y los apuntes de instrucción que se han utilizado como referencia para elaborar el contenido de la colección.

#strong[Apuntes de instrucción (DTO Fuentemilanos)]

Apuntes de teoría de #strong[Iñaqui Ulibarri García de la Cueva] para la Organización de Formación Declarada (DTO) de Fuentemilanos, organizados por asignatura del temario SPL.

#strong[Normativa y reglamentación]

- #strong[Easy Access Rules for Sailplanes]. Agencia de la Unión Europea para la Seguridad Aérea (EASA). Compendio consolidado del Reglamento (UE) 2018/1976 ---que contiene la #strong[Part-SFCL] (licencias) y la #strong[Part-SAO] (operaciones)--- junto con sus AMC y GM. #link("https://www.easa.europa.eu/sites/default/files/dfu/Sailplane%20Rule%20Book.pdf")
- #strong[Reglamento de Ejecución (UE) n.º 923/2012 --- SERA] (#emph[Standardised European Rules of the Air]). Reglas del aire comunes para la Unión Europea (versión consolidada). En España se aplica mediante el Real Decreto 552/2014. #link("https://eur-lex.europa.eu/legal-content/ES/TXT/PDF/?uri=CELEX:02012R0923-20250501")
- #strong[Ley 21/2003, de 7 de julio, de Seguridad Aérea]. Jefatura del Estado (España). Publicada en el BOE núm. 162, de 8 de julio de 2003. Marco legal nacional que complementa la normativa europea.

#strong[Anexos al Convenio de Chicago (OACI)]

La OACI desarrolla las normas y métodos recomendados (SARPS) mediante 19 anexos al Convenio sobre Aviación Civil Internacional. Los más relevantes para el piloto de planeador son los anexos 1, 2, 7, 8, 11, 12, 13, 14 y 15.

- Anexo 1 --- Licencias al personal
- Anexo 2 --- Reglamento del aire
- Anexo 3 --- Servicio meteorológico para la navegación aérea internacional
- Anexo 4 --- Cartas aeronáuticas
- Anexo 5 --- Unidades de medida que se emplearán en las operaciones aéreas y terrestres
- Anexo 6 --- Operación de aeronaves
- Anexo 7 --- Marcas de nacionalidad y de matrícula de las aeronaves
- Anexo 8 --- Aeronavegabilidad
- Anexo 9 --- Facilitación
- Anexo 10 --- Telecomunicaciones aeronáuticas
- Anexo 11 --- Servicios de tránsito aéreo
- Anexo 12 --- Búsqueda y salvamento
- Anexo 13 --- Investigación de accidentes e incidentes de aviación
- Anexo 14 --- Aeródromos
- Anexo 15 --- Servicios de información aeronáutica
- Anexo 16 --- Protección del medio ambiente
- Anexo 17 --- Seguridad: protección de la aviación civil internacional contra los actos de interferencia ilícita
- Anexo 18 --- Transporte sin riesgos de mercancías peligrosas por vía aérea
- Anexo 19 --- Gestión de la seguridad operacional

#strong[Manuales técnicos y métodos de formación]

- #strong[Glider Flying Handbook (FAA-H-8083-13B)]. Federal Aviation Administration (FAA), U.S. Department of Transportation. Obra en dominio público; fuente de buena parte de las ilustraciones técnicas de la colección. #link("https://www.faa.gov/regulations_policies/handbooks_manuals/aviation/glider_handbook")
- #strong[Methodik der Segelflugausbildung] (#emph[Segelflugrechte], Rev.~2). Deutscher Aero Club (DAeC), 2022. Metodología alemana de instrucción de vuelo a vela. #link("https://www.daec.de/media/files/2022/Sportarten/Segelflug/Methodik_der_Segelflugausbildung_Segelflugrechte_Rev.2.pdf")
- #strong[Vuelo sin motor: técnicas avanzadas]. Helmut Reichmann. Edición española de la obra de referencia internacional sobre la técnica del vuelo de distancia (orig. #emph[Streckensegelflug]\; ed.~inglesa, #emph[Cross-Country Soaring]). ISBN 978-84-283-1567-8.

#colofon[
#strong[Colofón]

Este manual se compone a partir de fuentes en Quarto Markdown, sin intermediarios: los ficheros #NormalTok(".qmd"); de este repositorio son la versión canónica.

Compuesto con Quarto 1.9.38 y la extensión #NormalTok("orange-book-es");, un derivado en español del paquete #NormalTok("orange-book");. La familia tipográfica es Libertinus.

#strong[Versión 0.8.1] · Última actualización: 16 de julio de 2026

https:\/\/github.com/VuelaLibre-net/teoria-licencia-SPL

]



