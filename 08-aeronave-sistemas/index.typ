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
  title: [Conocimientos Generales de la Aeronave],
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

#heading(level: 1, numbering: none)[Conocimientos Generales de la Aeronave]
<conocimientos-generales-de-la-aeronave>
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
#strong[#emph[Tema 8 de 9 del examen teórico para la Licencia de Piloto de Planeador (SPL)]]

Un planeador moderno de fibra de carbono es una obra de ingeniería de precisión. También es una máquina que falla de formas específicas y predecibles si no se mantiene o si el piloto no sabe qué está mirando en la inspección prevuelo.

La delaminación interna que el gelcoat disimula. El ARC caducado que convierte cada vuelo en un vuelo sin cobertura legal. La batería en mal estado que deja al piloto sin radio en el peor momento.

Catorce capítulos dan al piloto el conocimiento técnico para saber cuándo su planeador está en condiciones de volar y cuándo no.

El piloto que conoce su planeador por dentro nunca se lleva sorpresas de las que no puede recuperarse.

= Estructura
<estructura>
#quote(block: true)[
La estructura del planeador es lo primero que inspeccionas cada mañana y lo último que debe fallarte en vuelo. Saber de qué está hecho tu velero y cómo se comporta cada material ante el sol, la humedad o un golpe es la base de toda la inspección prevuelo.

En este capítulo aprenderás:

- #strong[Los materiales de construcción]: composite (fibra de vidrio y carbono), madera y tela, y metal, con los puntos débiles de cada uno.
- #strong[El gelcoat y el poliuretano]: por qué los planeadores son blancos, cómo cuidar su "piel" y por qué la pintura de PU va sustituyendo al gelcoat.
- #strong[El larguero y la estructura sándwich]: dónde reside la resistencia del ala y por qué un golpe pequeño puede esconder una delaminación.
- #strong[La cúpula (canopy)]: cierre, ventilación y suelta de emergencia.
- #strong[El gancho de remolque]: gancho de morro, gancho de CG y el mecanismo de suelta automática.
]

La estructura de un planeador busca dos cosas a la vez: la mejor aerodinámica posible y el menor peso posible. En un avión de motor, un exceso de potencia perdona ciertas ineficiencias. En vuelo sin motor no hay ese margen: cada gramo cuenta y cada imperfección en la superficie se paga en planeo.

== Materiales de construcción
<materiales-de-construcción>
Los materiales han ido cambiando con las décadas, desde el fresno y el abeto de los pioneros hasta la fibra de carbono de los veleros de competición de hoy.

=== Materiales compuestos (composites)
<materiales-compuestos-composites>
La gran mayoría de los planeadores modernos se fabrican con materiales compuestos, sobre todo plástico reforzado con fibra de vidrio (#emph[GRP, Glass Reinforced Plastic]) y plástico reforzado con fibra de carbono (#emph[CRP, Carbon Reinforced Plastic]).

- #strong[Fibra de vidrio]: el estándar de la industria desde finales de los años 50. Buena relación resistencia/peso y superficies que se moldean extremadamente lisas.
- #strong[Fibra de carbono]: más moderna y más cara. A igualdad de peso resiste mucho más que el acero y pesa bastante menos que la fibra de vidrio, así que se reserva para las piezas más cargadas y para los veleros de altas prestaciones.

#block[
#callout(
body: 
[
Los planeadores de composite son casi siempre blancos por una razón técnica, no estética: la resina epoxi que une las fibras pierde propiedades mecánicas si se calienta demasiado. El blanco refleja la radiación solar y mantiene la estructura dentro de sus límites térmicos.

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
=== Madera, tela y metal
<madera-tela-y-metal>
Menos comunes en los aeródromos de hoy, pero aún se ven joyas de la aviación clásica:

- #strong[Madera y tela]: estructuras de madera (como el Schleicher K8) revestidas de tela aeronáutica. Ligeras y fáciles de reparar, aunque la enteladura pide un mantenimiento más riguroso.
- #strong[Metal (aluminio)]: raro en planeadores puros; el ejemplo más famoso es el Let L-13 Blaník. Su construcción se parece a la de un avión convencional, con largueros, costillas y paños de aluminio remachados.

== El gelcoat: la piel del planeador
<el-gelcoat-la-piel-del-planeador>
El #strong[gelcoat] es una capa de resina de poliéster que cubre la estructura de fibra. Le da ese acabado brillante y liso tan característico, pero no es solo estética: es la barrera que protege la fibra de la humedad.

Tiene dos enemigos. La radiación ultravioleta y los cambios bruscos de temperatura. Con los años, el sol acaba provocando el "craqueado": una red de microfisuras en la superficie.

En los veleros modernos, ese gelcoat de poliéster está cediendo terreno frente a los sistemas de pintura de #strong[poliuretano] (PU) acrílico. La diferencia no es solo de fórmula. El PU se aplica como una capa de pintura fina, mucho más ligera que el grueso gelcoat (que en un planeador puede suponer varios kilos), y es bastante más elástico, así que resiste mucho mejor el craqueado por UV y conserva el brillo durante más años. A cambio, esa capa fina deja menos margen para reparar a base de lijar y pulir: un arañazo profundo o un repintado piden pistola y un acabado a juego, no el simple pulido que admite el gelcoat. Sea de poliéster o de poliuretano, el cuidado es el mismo (protegerlo del sol y limpiarlo con suavidad), pero en superficies de PU conviene evitar los pulimentos abrasivos pensados para gelcoat.

#block[
#callout(
body: 
[
Trata el gelcoat como tratarías tu propia piel. Protégelo del sol con fundas siempre que puedas y encéralo al menos una vez al año con ceras sin silicona para conservar su elasticidad y su protección UV.

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
== El larguero y la estructura sándwich
<el-larguero-y-la-estructura-sándwich>
Si el planeador fuera un cuerpo, el #strong[larguero] sería la columna vertebral. Es la pieza maestra que recorre el ala de punta a punta y soporta todas las cargas de flexión en vuelo. Un daño estructural en el larguero deja el ala fuera de servicio.

Para el resto del ala y del fuselaje se usa la #strong[estructura tipo sándwich]: dos capas finas y rígidas de fibra (las "tapas") con un núcleo ligero de espuma rígida (#emph[foam]) o nido de abeja entre ellas.

Así se consiguen grandes superficies con una rigidez enorme y un peso mínimo. El precio es la fragilidad frente a los golpes puntuales: un topetazo con el borde de un hangar puede delaminar el interior sin dejar apenas marca por fuera.

#figure([
#box(image("imagenes/08-cap01-estructura-ala.jpg"))
], caption: figure.caption(
position: bottom, 
[
Esquema de la estructura de un ala de materiales compuestos (larguero y sándwich)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap01-estructura-ala>


== La cúpula
<la-cúpula>
La cúpula de plexiglás es, junto con tus ojos, tu principal defensa anticolisión: a través de ella vigilas el tráfico todo el vuelo. Como componente estructural merece el mismo respeto que el ala.

- #strong[Cierre y bloqueo]: los pestillos laterales (o frontales) deben quedar bloqueados y verificados antes de despegar. Una cúpula que se abre en pleno remolque es una causa clásica de accidente, no tanto por el daño como por el pánico que provoca.
- #strong[Ventilación]: la ventanilla lateral y la toma de aire de cabina sirven para ventilar y desempañar. En invierno, el vaho te deja ciego en segundos justo durante el lanzamiento.
- #strong[Suelta de emergencia]: todas las cúpulas llevan un mecanismo de eyección (normalmente unos tiradores rojos) que libera la cúpula entera para poder saltar en paracaídas. Localízalo en cada planeador que vueles, porque no todos lo colocan en el mismo sitio.
- #strong[Cuidado del plexiglás]: se limpia solo con agua abundante, productos específicos y paños limpios de algodón, siempre a favor del flujo. Un trapo seco o un disolvente lo rayan para siempre.

== El gancho de remolque
<el-gancho-de-remolque>
El gancho de suelta (#emph[release hook]) es el punto donde el planeador se une al cable del torno o a la cuerda de remolque. Casi todos montan ganchos de la marca Tost, y hay dos ubicaciones con funciones distintas:

- #strong[Gancho de morro] (#emph[nose hook]): en la proa, pensado para el remolque por avión. Como la tracción va alineada con el eje longitudinal, resulta más fácil mantener la posición tras el remolcador.
- #strong[Gancho de CG] (#emph[CG hook]): bajo el fuselaje, cerca del centro de gravedad, es el adecuado para el lanzamiento por torno. Permite rotar a la actitud de subida pronunciada sin que el cable tire del morro hacia abajo.

El gancho de CG incorpora una suelta automática (#emph[back-release]): si el cable tira hacia atrás y abajo, como ocurre al sobrevolar el torno al final del lanzamiento, el gancho libera el cable por sí solo aunque el piloto no accione la suelta.

Muchos planeadores de escuela montan los dos ganchos, y la regla es sencilla: morro para avión, CG para torno. La autoridad sobre qué gancho corresponde a cada método de lanzamiento es siempre el manual de vuelo (AFM). Usar el de CG para remolque por avión está permitido en algunos modelos, pero exige más atención: la tendencia a encabritarse es mayor y una posición alta respecto al remolcador puede acabar provocando una suelta automática involuntaria.

#block[
#callout(
body: 
[
No te lances nunca en torno con el gancho de morro. Al quedar el enganche por delante del centro de gravedad, el cable tira del morro hacia el suelo en lugar de dejar rotar el planeador a la subida; para contrarrestarlo tendrías que tirar a fondo de profundidad, y eso sobrecarga el estabilizador horizontal y el timón en una fase de cargas ya muy altas. A esto se suma que el gancho de morro no da la suelta automática (#strong[back-release]) del de CG, así que un fallo de suelta es mucho más peligroso. Por estas razones, en los tipos así certificados el AFM prohíbe de forma expresa el lanzamiento por torno con el gancho de morro.

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
#block[
#callout(
body: 
[
El gancho de remolque es un mecanismo con desgaste y con revisiones propias: los Tost tienen una vida limitada en años y en número de lanzamientos, y al cumplirla deben revisarse o sustituirse según el manual del fabricante. En la inspección prevuelo, acciona la suelta con el cable de pruebas y comprueba que el gancho abre y cierra con franqueza, sin agarrotamientos.

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
#strong[Resumen del capítulo: estructura (airframe)]

- #strong[Materiales]: la mayoría, de fibra de vidrio y de carbono (composite) por su resistencia y su acabado liso. Los clásicos, de madera y tela. El metal es raro en planeadores puros (salvo el Blaník).
- #strong[Gelcoat]: la "piel" blanca del planeador. Sensible a los rayos UV y a los cambios bruscos de temperatura. Protégelo con fundas y no lo dejes al sol sin necesidad. En los veleros modernos lo sustituye cada vez más la pintura de poliuretano (PU): más ligera y elástica, resiste mejor el craqueado, pero se repara peor con lijado y pulido.
- #strong[Larguero]: la columna vertebral del ala. Soporta las cargas de vuelo. Si se daña, el ala es chatarra.
- #strong[Estructura sándwich]: dos capas duras con un núcleo ligero (espuma o nido de abeja). Muy rígida y ligera, pero delicada ante los golpes puntuales.
- #strong[Cúpula]: pestillos bloqueados antes de despegar, suelta de emergencia localizada y plexiglás limpio solo con agua y paños adecuados.
- #strong[Gancho de remolque]: morro para avión, CG para torno (lo manda el AFM). Nunca torno con el gancho de morro: tira del morro al suelo y sobrecarga la cola. El de CG tiene suelta automática (#strong[back-release]). Comprueba su funcionamiento en la inspección diaria.

]
= Diseño de sistemas, cargas y tensiones
<diseño-de-sistemas-cargas-y-tensiones>
#quote(block: true)[
Tu planeador es fuerte, pero no invencible. La certificación define con precisión cuánta carga aguanta la estructura y dónde están los límites que nunca debes explorar.

En este capítulo aprenderás:

- #strong[El factor de carga (n)]: qué significa "tirar de g" y cómo lo provocan los virajes y las recogidas.
- #strong[Las categorías de diseño] Utilitaria y Acrobática según CS-22 y sus límites en g.
- #strong[Carga límite y carga de rotura]: qué protege el factor de seguridad de 1,5 y qué no.
- #strong[La fatiga estructural] de los composites y sus inspecciones de vida útil.
- #strong[El flameo (flutter)]: la vibración que puede desintegrar un planeador en segundos.
]

Un planeador no solo tiene que ser aerodinámicamente eficiente; también tiene que aguantar las fuerzas de la atmósfera y las maniobras del piloto. Ese diseño estructural se rige por normas estrictas (como la CS-22 de EASA (European Union Aviation Safety Agency)), que fijan cuánta carga debe soportar la aeronave antes de sufrir daños.

== El factor de carga (n)
<el-factor-de-carga-n>
El #strong[factor de carga] (en "g") es la relación entre la sustentación total que generan las alas y el peso del planeador. En vuelo recto y nivelado vale 1g: las alas sostienen exactamente el peso del avión. En un viraje escarpado, o al tirar de la palanca para salir de un picado, ese valor sube y la estructura trabaja mucho más.

En el viraje, el factor de carga crece con la inclinación, porque las alas tienen que generar más sustentación para sostener el peso mientras curvan la trayectoria. La relación no es lineal:

#table(
  columns: 5,
  align: (auto,auto,auto,auto,auto,),
  table.header([Inclinación], [0°], [30°], [45°], [60°],),
  table.hline(),
  [Factor de carga], [1g], [1,15g], [1,41g], [2g],
)
A 60° de alabeo el planeador "pesa" el doble: un velero de 500 kg somete sus alas a 1.000 kg. Por eso un viraje muy escarpado, sobre todo a baja velocidad, acerca peligrosamente a la pérdida.

== Categorías de diseño
<categorías-de-diseño>
No todos los planeadores se diseñan para los mismos esfuerzos. La normativa europea distingue principalmente dos categorías:

- #strong[Categoría Utilitaria (U)]: para el vuelo normal, térmica y navegación. Certificada para soportar +5,3g y -2,65g a la velocidad de maniobra. Esos límites se estrechan al aumentar la velocidad hasta +4,0g y -1,5g a la velocidad de picado (V#sub[D]); la envolvente completa (el diagrama V-n) se detalla en el #strong[Libro 5 --- Principios de vuelo], capítulo 5.
- #strong[Categoría Acrobática (A)]: para maniobras extremas, con límites de +7g y -5g.

#block[
#callout(
body: 
[
#strong[CS 22.337 (factores de carga límite de maniobra)]: la categoría Utilitaria debe soportar +5,3 / -2,65 (a la velocidad de maniobra) y la Acrobática, +7,0 / -5,0. #strong[CS 22.303 (factor de seguridad)]: salvo indicación en contra, se aplica un factor de seguridad de 1,5 sobre las cargas límite para obtener las cargas últimas.

Los límites concretos de tu aeronave están en su Manual de Vuelo. Consúltalos antes de volar un modelo nuevo.

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
== Carga límite y carga de rotura
<carga-límite-y-carga-de-rotura>
En la certificación se manejan dos conceptos clave:

+ #strong[Carga límite]: el esfuerzo máximo que el planeador soporta sin deformación permanente. Tras alcanzarla, la estructura debe recuperar su forma original sin daños.
+ #strong[Carga de rotura (ultimate load)]: el valor al que la estructura falla de forma catastrófica. Por norma general se aplica un factor de seguridad de 1,5, así que un planeador con carga límite de 5,3g tendría una carga de rotura teórica de unos 8,0g.

#block[
#callout(
body: 
[
No uses nunca el factor de seguridad como "margen de maniobra". Ese 1,5 está para cubrir imperfecciones del material o condiciones atmosféricas imprevistas, no para que el piloto vuele fuera de límites.

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
== Fatiga y vida útil
<fatiga-y-vida-útil>
La fibra de vidrio y la de carbono resisten muy bien, pero no son eternas. Con los años y las horas de vuelo, las tensiones repetidas y los aterrizajes acaban generando microfisuras o delaminación.

Por eso los fabricantes establecen programas de inspección de vida útil. Es habitual que las aeronaves de fibra pasen revisiones estructurales profundas a las 3.000, 6.000 y 9.000 horas de vuelo para confirmar que la estructura sigue siendo segura.

== Flameo (flutter): la vibración mortal
<flameo-flutter-la-vibración-mortal>
El #strong[flameo] o #emph[flutter] es una vibración autoexcitada que aparece cuando las fuerzas aerodinámicas interactúan de forma descontrolada con la elasticidad del ala o de los timones. Es un fenómeno violentísimo, capaz de desintegrar una aeronave en segundos.

Tiene que ver directamente con la velocidad. La V#sub[NE] (Velocidad Nunca Exceder) se certifica precisamente con un margen de seguridad respecto a la velocidad a la que aparece el flameo. Pero ese margen no es un cheque en blanco: un planeador con holguras en los mandos, con masas de equilibrado mal ajustadas tras una reparación o con agua acumulada en las superficies de control puede entrar en flameo incluso por debajo de la V#sub[NE]. De ahí que el equilibrado de las superficies de control se verifique después de cualquier reparación o repintado.

#figure([
#box(image("imagenes/08-cap02-diagrama-vn.jpg"))
], caption: figure.caption(
position: bottom, 
[
El diagrama V-n o envolvente de vuelo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap02-diagrama-vn>


#postit[
#strong[Resumen del capítulo: cargas y diseño]

- #strong[Factor de carga (n)]: los planeadores son fuertes, no invencibles. Crece con la inclinación del viraje (a 60° de alabeo, 2g). Categoría Utilitaria: +5,3g / -2,65g. Categoría Acrobática: +7g / -5g (CS 22.337).
- #strong[Fatiga]: la fibra de vidrio dura muchísimo, pero se revisa periódicamente (3000h, 6000h…) en busca de microfisuras o delaminación.
- #strong[Carga límite y rotura]: la límite es la máxima sin deformación permanente; la de rotura es la que parte la estructura (1,5 veces la límite, CS 22.303). No te acerques a esos valores.
- #strong[Flameo (flutter)]: vibración autoexcitada mortal. La V#sub[NE] se fija con margen frente al flutter, pero las holguras o los desequilibrios en los mandos pueden provocarlo incluso por debajo. Respetar la V#sub[NE] es respetar tu vida.

]
= Tren de aterrizaje, ruedas, neumáticos y frenos
<tren-de-aterrizaje-ruedas-neumáticos-y-frenos>
#quote(block: true)[
Cada vuelo termina en el suelo, y el tren de aterrizaje es lo único que se interpone entre la estructura (y tu columna vertebral) y la pista.

En este capítulo aprenderás:

- #strong[Las configuraciones del tren]: fijo y retráctil, y la disciplina que exige cada uno.
- #strong[La amortiguación y los "elementos fusible"]: cómo el tren protege al piloto en un aterrizaje duro.
- #strong[El sistema de frenado]: tipos de freno, accionamiento y sus límites.
- #strong[El patín y la rueda de cola]: los puntos de desgaste que hay que vigilar.
- #strong[Qué hacer si el tren no sale]: la emergencia más benigna del catálogo, si la gestionas bien.
]

El tren de aterrizaje es la interfaz del planeador con el suelo. Pasamos casi todo el tiempo en el aire, pero una toma segura depende de que ese sistema funcione bien y de que el piloto lo gestione con disciplina.

== Configuraciones del tren
<configuraciones-del-tren>
Según el uso y las prestaciones del velero, hay dos tipos principales:

- #strong[Tren fijo]: habitual en planeadores de escuela (como el ASK-21). Suele ser una rueda principal robusta, a veces con una rueda de morro y otra de cola (o patín). Su gran ventaja es la simplicidad: no hay nada que olvidar sacar.
- #strong[Tren retráctil]: el estándar en veleros de rendimiento. Esconder la rueda dentro del fuselaje elimina una buena parte de la resistencia aerodinámica. El mecanismo suele ser manual, con una palanca en el lado derecho de la cabina.

#block[
#callout(
body: 
[
Trata la gestión del tren retráctil como algo sagrado: se guarda solo tras soltar el remolque y alcanzar una altura segura, y se vuelve a sacar al entrar en el tramo de viento en cola (#emph[downwind]), sin excepción. Que forme parte de tu chequeo mental antes de aterrizar.

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
== Suspensión y "elementos fusible"
<suspensión-y-elementos-fusible>
A diferencia de los aviones pesados, la amortiguación de muchos planeadores es básica: bloques de goma, ballestas de acero o, sin más, la elasticidad del propio neumático.

Aun así, el tren cumple una función de seguridad importante: trabaja como #strong[elemento fusible]. En un aterrizaje muy duro, el soporte del tren está pensado para romper antes que la estructura principal del fuselaje, absorbiendo parte de la energía del impacto y protegiendo la columna del piloto.

== Patín y rueda de cola
<patín-y-rueda-de-cola>
En la cola, los planeadores montan un patín (en los modelos clásicos) o una pequeña rueda de cola. Sirve para proteger el fuselaje en las tomas con el morro alto y durante el rodaje. Es un punto de desgaste constante: revisa en la inspección diaria la zapata del patín o la goma de la rueda y la firmeza de su anclaje al fuselaje. En las puntas de ala, muchos veleros llevan además ruedecillas o tacos de protección para los giros en tierra.

== El sistema de frenado
<el-sistema-de-frenado>
El freno de rueda es clave para detener la carrera de aterrizaje, sobre todo en pistas cortas o en tomas fuera de campo.

- #strong[Tipo de freno]: los modelos modernos llevan frenos de disco hidráulicos, muy eficaces; los más antiguos, de tambor.
- #strong[Accionamiento]: en la mayoría de los planeadores el freno entra al llevar la palanca de aerofrenos hasta el final de su recorrido. En otros está en los pedales o en una maneta independiente.

#block[
#callout(
body: 
[
No frenes con brusquedad al principio de la carrera de aterrizaje si llevas mucha velocidad: puedes provocar un capotaje (el morro se clava en el suelo) o hacer planos en la rueda por desgaste excesivo del neumático.

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
== Mantenimiento y emergencias
<mantenimiento-y-emergencias>
Un neumático con poca presión no solo aumenta la resistencia al rodaje, sino que puede desllantar en un aterrizaje con viento cruzado. Comprueba siempre el estado de la rueda y la limpieza de los cables de retracción: el barro o la hierba acumulada llegan a bloquear el mecanismo.

¿Y si el tren no sale? Si el mando está agarrotado, a veces un tirón suave (un picado y una recogida) ayuda a que la gravedad fuerce la extensión. Y si al final tienes que aterrizar con el tren dentro, hazlo sobre hierba: los daños suelen quedarse en raspones del gelcoat del fuselaje, sin comprometer la seguridad del piloto.

#figure([
#box(image("imagenes/08-cap03-mecanismo-tren.jpg"))
], caption: figure.caption(
position: bottom, 
[
Mecanismo típico de un tren de aterrizaje retráctil manual
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap03-mecanismo-tren>


#postit[
#strong[Resumen del capítulo: tren de aterrizaje]

- #strong[Configuraciones]: tren fijo (escuela, simple) o retráctil (rendimiento). El retráctil se saca sin falta en viento en cola: tren abajo y bloqueado.
- #strong[Amortiguación]: en muchos planeadores, la única suspensión es el neumático y tu cojín. El tren hace de "elemento fusible": en una toma muy dura rompe él antes que el fuselaje.
- #strong[Frenos]: de disco (eficaces, pero pueden calentarse) o de tambor. Entran al final del recorrido de los aerofrenos o con una maneta aparte. Comprueba que frenan bien antes de despegar.
- #strong[Patín de cola]: protege el fuselaje en tomas con el morro alto. Es un punto de desgaste a vigilar.
- #strong[Tren que no sale]: prueba un tirón suave; si no, toma sobre hierba con el tren dentro. Daños menores, piloto a salvo.

]
= Masa y centro de gravedad
<masa-y-centro-de-gravedad>
#quote(block: true)[
El planeador que despega sobrecargado o mal centrado ya lleva el accidente a bordo. Este capítulo trata la masa y el centrado desde el punto de vista de los sistemas del avión: dónde va el lastre, qué dice la placa de limitaciones y cuándo hay que volver a pesar la aeronave.

En este capítulo aprenderás:

- #strong[La masa máxima al despegue (MTOW)] y la diferencia con la masa máxima sin agua.
- #strong[Los límites del centro de gravedad]: qué ocurre con un CG demasiado adelantado o, peor, demasiado retrasado.
- #strong[La gestión del lastre]: plomos de morro, depósito de cola y los límites del maletero.
- #strong[El pesaje de la aeronave]: cuándo se repite y dónde se documenta.
]

Volar dentro de los límites de peso y equilibrio no es opcional: es un requisito legal y de seguridad. En un coche, la carga solo afecta al consumo. En un planeador decide si la aeronave es estable y controlable o si se convierte en una trampa el día que entres en pérdida.

== Masa y peso máximo
<masa-y-peso-máximo>
Cada planeador tiene definida una #strong[masa máxima al despegue] (#emph[MTOW, Maximum Take-Off Weight]). Superarla somete a la estructura a esfuerzos para los que no se diseñó, recorta el margen de seguridad en maniobra y empeora el ascenso.

Conviene distinguir la masa máxima total de la masa máxima sin agua: el agua va en las alas y no castiga la unión de la raíz del ala con el fuselaje igual que lo hace el peso en la cabina. En la documentación de certificación CS-22, este concepto aparece como #strong[masa máxima de las partes que no sustentan] (#emph[Maximum weight of non-lifting parts]).

== El centro de gravedad (CG)
<el-centro-de-gravedad-cg>
El #strong[centro de gravedad] es el punto donde se concentra, en teoría, todo el peso de la aeronave. Para que el planeador sea estable, ese punto tiene que caer dentro de un rango muy estrecho fijado por el fabricante.

- #strong[Límite delantero]: con el CG muy adelantado (piloto pesado o mucho lastre en el morro), el planeador es muy estable pero "pesado" de mandos. En la toma puede faltarte profundidad para hacer la recogida y acabas golpeando con la rueda de morro.
- #strong[Límite trasero]: es el peligroso. Un CG retrasado (piloto ligero sin lastre) vuelve inestable al planeador. Si entras en pérdida, el morro tiende a subir solo y puede meterte en una barrena (#strong[spin]) irrecuperable.

#block[
#callout(
body: 
[
La certificación CS-22 exige una placa de limitaciones visible en cabina con las cargas mínima y máxima del asiento. Comprueba siempre el peso mínimo en cabina: si el tuyo (con paracaídas y ropa) queda por debajo de ese mínimo, es obligatorio instalar lastre antes de despegar, según indique el Manual de Vuelo.

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
== Gestión del lastre y maleteros
<gestión-del-lastre-y-maleteros>
Muchos planeadores modernos tienen compartimentos en el morro para alojar pesas de plomo. Algunos modelos de competición llevan incluso tanques de agua en la deriva (en la cola) para contrarrestar el agua de las alas y mantener el CG en su punto óptimo de rendimiento.

El maletero, normalmente detrás del piloto, tiene límites de carga muy estrictos (a menudo menos de 10-15 kg). Cualquier objeto pesado ahí tiene un brazo de palanca grande y retrasa bastante el CG.

== Pesaje y documentación
<pesaje-y-documentación>
Con el tiempo, las reparaciones, la pintura o los cambios de instrumentos alteran el peso en vacío del planeador. Determinar ese peso en vacío y su CG mediante pesaje es un requisito de certificación (CS 22.29). El procedimiento y la periodicidad del repesaje los fija el manual de mantenimiento del fabricante y el programa de mantenimiento de la aeronave: no hay un plazo universal, aunque muchos programas lo exigen tras reparaciones estructurales, repintados o cambios de equipo. Los datos del último pesaje quedan en el Certificado de Pesaje, dentro de la documentación de la aeronave.

#figure([
#box(image("imagenes/08-cap04-calculo-cg.jpg"))
], caption: figure.caption(
position: bottom, 
[
Ejemplo de cálculo de peso y centrado
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap04-calculo-cg>


#block[
#callout(
body: 
[
El cálculo numérico de masa y centrado (datum, brazos y momentos) se desarrolla con un ejemplo completo de examen en el #strong[Libro 7 --- Planificación y rendimiento del vuelo], capítulo 1. Aquí nos interesa la parte física: dónde está cada lastre y qué sistemas lo gestionan.

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
#strong[Resumen del capítulo: masa y centrado (sistemas)]

- #strong[MTOW y masa sin agua]: dos límites distintos. El agua en las alas no castiga la raíz del ala como el peso en cabina.
- #strong[Límites de CG]: adelantado, mandos pesados y recogida corta; retrasado, inestable y barrena potencialmente irrecuperable. El trasero es el peligroso.
- #strong[Lastre fijo]: placas de plomo en el morro para corregir un CG atrasado (piloto ligero). Si no llegas al peso mínimo de la placa de limitaciones, lastre obligatorio.
- #strong[Lastre de cola]: depósito de agua o pesas en la deriva para ajustar el CG óptimo. Cuidado: olvidar vaciarlo con un piloto ligero delante es una emergencia grave (CG peligrosamente atrasado).
- #strong[Pesaje]: tras reparaciones, repintado o cambios de equipo, según el manual de mantenimiento. El resultado vive en el Certificado de Pesaje.

]
= Mandos de vuelo
<mandos-de-vuelo>
#quote(block: true)[
Entre tu mano y el alerón hay varios metros de varillas, rótulas y cables. Conocer ese recorrido es lo que te permite detectar en tierra la holgura, el roce o el mando invertido que en vuelo ya no tendría remedio.

En este capítulo aprenderás:

- #strong[Los mandos primarios]: alerones, profundidad y dirección, y cómo se transmiten (varillas y cables).
- #strong[Los aerofrenos]: el mando azul y su efecto sobre la senda de planeo.
- #strong[Los flaps]: posiciones positivas y negativas en veleros de rendimiento.
- #strong[El compensador (trim)]: de muelles o de pestaña, y por qué es tu mejor aliado.
- #strong[La comprobación de libertad y sentido de mandos] antes de cada despegue.
]

Un planeador se pilota con la punta de los dedos. Esa precisión de los mandos es lo que te deja centrar una térmica estrecha o clavar una aproximación. Y entender cómo viaja tu movimiento desde la cabina hasta las superficies de control es lo que te permite cazar cualquier anomalía antes de despegar.

== Los mandos primarios
<los-mandos-primarios>
Controlan el planeador en sus tres ejes:

- #strong[Alerones]: gobiernan el alabeo (eje longitudinal). Se mueven de forma asimétrica (uno sube, otro baja) para inclinar el velero.
- #strong[Elevador o timón de profundidad]: gobierna el cabeceo (eje transversal). Al tirar de la palanca, el elevador sube, la cola baja y el morro se levanta.
- #strong[Timón de dirección]: gobierna la guiñada (eje vertical) con los pedales. Es esencial para coordinar los virajes y compensar la guiñada adversa de los alerones.

La mayoría de los planeadores modernos usan varillas rígidas (#emph[push-rods]) para la profundidad y el alabeo, por su precisión y su falta de holguras, mientras que el timón de dirección suele ir con cables de acero de alta resistencia.

== Aerofrenos (spoilers)
<aerofrenos-spoilers>
El mando azul de la cabina acciona los aerofrenos. Su función es destruir parte de la sustentación y aumentar la resistencia, lo que te permite variar la pendiente de planeo sin tener que cambiar mucho la velocidad.

#block[
#callout(
body: 
[
Al sacar los aerofrenos, la mayoría de los planeadores bajan un poco el morro o vibran ligeramente. Anticípate y compensa ese cambio de actitud con el elevador para no perder la velocidad de aproximación.

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
== Los flaps
<los-flaps>
En los veleros de competición y en los biplazas de rendimiento, los flaps modifican la curvatura del ala:

- #strong[Posiciones positivas]: aumentan la sustentación; van bien para girar en térmicas lentas y para el aterrizaje.
- #strong[Posiciones negativas]: reducen la curvatura y la resistencia; permiten correr entre térmicas con una pérdida de altura mínima.

== El compensador (trim)
<el-compensador-trim>
El mando verde, o el pulsador eléctrico que libera la carga de la palanca, es tu mejor aliado. El compensador no "vuela" el avión: alivia la presión que tendrías que hacer sobre el elevador para mantener una velocidad dada.

- #strong[Trim de muelles]: el más común; unos resortes "sujetan" la palanca en la posición deseada.
- #strong[Trim de pestaña]: una pequeña superficie en el borde de salida del elevador que se mueve en sentido contrario.

#block[
#callout(
body: 
[
Los mandos de cabina siguen un código de colores casi universal que conviene reconocer al instante: #strong[azul] para los aerofrenos, #strong[verde] para el compensador, #strong[amarillo] para la suelta del cable de remolque y #strong[rojo] para las palancas de emergencia (suelta de cúpula, aperturas). Localízalos en cada planeador antes de volar.

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
#block[
#callout(
body: 
[
Antes de cada despegue, comprueba siempre la libertad y el sentido de los mandos. Lleva todas las superficies a sus topes y verifica a la vista que se mueven en la dirección correcta. Un mando invertido tras un mantenimiento es una emergencia crítica, y se manifiesta justo al despegar.

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
#figure([
#box(image("imagenes/08-cap05-sistema-mandos.jpg"))
], caption: figure.caption(
position: bottom, 
[
Esquema del sistema de varillas y cables de un planeador estándar
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap05-sistema-mandos>


#postit[
#strong[Resumen del capítulo: mandos de vuelo]

- #strong[Mandos primarios]: alerones (alabeo), profundidad (cabeceo) y dirección (guiñada). Varillas rígidas para alabeo y profundidad; cables para la dirección. Revisa holguras, tensión y deshilachados en la inspección.
- #strong[Código de colores]: azul (aerofrenos), verde (compensador), amarillo (suelta de remolque), rojo (emergencia). Casi universal; reconócelo al instante.
- #strong[Aerofrenos]: mando azul. Destruyen sustentación y aumentan resistencia para controlar la senda. Al sacarlos, el morro tiende a bajar: compensa con profundidad.
- #strong[Flaps]: positivos para térmica y aterrizaje; negativos para transiciones rápidas. Solo en veleros de rendimiento.
- #strong[Compensador (trim)]: mando verde. No vuela el avión: alivia la presión de palanca para una velocidad dada. Ajústalo en cada fase del vuelo.
- #strong[Libertad y sentido]: comprobación completa de mandos antes de cada despegue. Un mando invertido tras un mantenimiento es mortal.

]
= Instrumentos
<instrumentos>
#quote(block: true)[
El panel de un planeador es austero: tres instrumentos de presión, una radio y poco más. Por eso mismo, entender qué mide cada uno y cómo falla es imprescindible.

En este capítulo aprenderás:

- #strong[El sistema pitot-estática]: las tomas de presión que alimentan los instrumentos básicos.
- #strong[El trío básico]: anemómetro (y sus arcos de colores), altímetro y variómetro.
- #strong[El equipamiento mínimo exigido]: qué instrumentos obliga a llevar la norma según el tipo de vuelo.
- #strong[El variómetro de energía total]: por qué ignora los "palancazos" y solo marca el aire que sube.
- #strong[La aviónica de seguridad]: radio VHF, transpondedor y FLARM.
]

Los instrumentos son los "sentidos" del piloto. Buena parte del vuelo sin motor se basa en la percepción (el ruido del aire, la posición del morro, la presión en el asiento), pero los instrumentos aportan la precisión que hace falta para exprimir el rendimiento y volar seguro.

== Tomas de presión: pitot y estáticas
<tomas-de-presión-pitot-y-estáticas>
Casi todos los instrumentos básicos funcionan midiendo presiones de aire:

- #strong[Toma pitot]: normalmente en el morro o en el borde de ataque de la deriva. Mide la presión total (estática más dinámica) que produce el movimiento.
- #strong[Tomas estáticas]: pequeños orificios en los laterales del fuselaje que miden la presión ambiente del aire, sin influencia de la velocidad.

#block[
#callout(
body: 
[
Las tomas de presión son un imán para los insectos. Un nido de araña en el pitot hará que tu anemómetro marque cero en pleno despegue. Pon fundas protectoras en tierra y comprueba que las tomas están limpias en la inspección prevuelo. Y no soples nunca directamente en ellas: la sobrepresión revienta las delicadas membranas de los instrumentos.

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
== El trío básico: anemómetro, altímetro y variómetro
<el-trío-básico-anemómetro-altímetro-y-variómetro>
+ #strong[Anemómetro (velocímetro)]: muestra la velocidad indicada (#emph[IAS]). Es el instrumento más importante para la seguridad; si falla, guíate por el ruido del aire y la actitud del morro.
+ #strong[Altímetro]: funciona como un barómetro calibrado en pies o metros. Indica la altura sobre una referencia (QNH o QFE).
+ #strong[Variómetro]: indica la velocidad vertical. En un planeador es vital para saber si estás en aire que sube (térmica) o que baja.

=== Los arcos de colores del anemómetro
<los-arcos-de-colores-del-anemómetro>
La esfera del anemómetro lleva marcas de color que resumen las limitaciones de velocidad del planeador:

- #strong[Arco verde]: rango de operación normal, desde 1,1 veces la velocidad de pérdida hasta la #strong[V#sub[RA]], la velocidad máxima en aire turbulento (CS 22.1545). No la confundas con la velocidad de maniobra (V#sub[A]): esa es un límite estructural que no se marca en la esfera (se estudia en el #strong[Libro 5 --- Principios de vuelo], capítulo 5).
- #strong[Arco amarillo]: rango de precaución, de la V#sub[RA] a la V#sub[NE]. Solo con aire en calma y movimientos de mando suaves.
- #strong[Línea roja radial]: la V#sub[NE] (Velocidad Nunca Exceder). Es un límite absoluto, nunca un objetivo.
- #strong[Triángulo amarillo]: en muchos veleros marca la velocidad de aproximación recomendada con masa máxima sin lastre.

Estas marcas se complementan con las velocidades de remolque y torno indicadas en la placa de limitaciones y en el Manual de Vuelo. Y ojo en vuelo de onda a gran altitud: la V#sub[NE] #strong[indicada] disminuye; el porqué se explica en el #strong[Libro 5, capítulo 5].

== Instrumentos exigidos por la normativa
<instrumentos-exigidos-por-la-normativa>
No todos los instrumentos del panel son obligatorios. La normativa europea fija un mínimo que depende del tipo de vuelo, y obliga a llevar más cuanto peores son las condiciones de visibilidad.

#block[
#callout(
body: 
[
#strong[SAO.IDE.105] exige a todo planeador medios para medir y mostrar la hora (en horas y minutos), la altitud de presión y la velocidad aerodinámica indicada. Los planeadores motorizados llevan además rumbo magnético.

Para volar en condiciones de nebulosidad (nubes) o de noche se añaden tres: la velocidad vertical, la actitud o el viraje y resbale, y el rumbo magnético. El vuelo nocturno exige, además, luces de navegación, anticolisión, de aterrizaje y de cabina.

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
== Variómetro de energía total (TE)
<variómetro-de-energía-total-te>
Si tiras de la palanca, el planeador sube pero pierde velocidad. Un variómetro normal marcaría ascenso, cuando en realidad no has encontrado ninguna térmica: solo has cambiado velocidad por altura. El #strong[variómetro de energía total] (compensado con un Venturi o una antena especial) ignora esos cambios provocados por el piloto y solo marca ascenso cuando es la masa de aire la que de verdad te empuja hacia arriba.

Los variómetros electrónicos modernos añaden señales acústicas (pitidos) que te dejan centrar la térmica sin apartar la vista del cielo, lo que también mejora la vigilancia del tráfico.

== Aviónica: comunicación y seguridad
<aviónica-comunicación-y-seguridad>
- #strong[Radio VHF]: fundamental para coordinarte en el aeródromo y con el control de tráfico. Úsala con brevedad para ahorrar batería.
- #strong[Transpondedor]: hace visible al planeador para los radares de los controladores y para los sistemas anticolisión (TCAS) de los aviones comerciales.
- #strong[FLARM]: el sistema estrella del vuelo sin motor. Avisa de otros planeadores cercanos y de posibles rumbos de colisión con señales visuales y sonoras.

Algunos planeadores montan además una brújula magnética y, como "instrumento" más barato y fiable de todos, el hilo de lana pegado a la cúpula, que canta el vuelo cruzado mejor que cualquier aguja. El magnetismo y el uso de la brújula se tratan en el #strong[Libro 9 --- Navegación], capítulo 2; el hilo de lana, en el #strong[Libro 5 --- Principios de vuelo], capítulo 4.

#figure([
#box(image("imagenes/08-cap06-panel-pitot.jpg"))
], caption: figure.caption(
position: bottom, 
[
Esquema de conexiones del sistema pitot-estática e instrumentos
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap06-panel-pitot>


#postit[
#strong[Resumen del capítulo: instrumentos]

- #strong[Pitot y estática]: los sentidos del avión. El pitot (morro/cola) mide presión total; las estáticas (fuselaje), presión ambiente. Si se bloquean (insectos, agua), te quedas ciego de velocidad y altura.
- #strong[Anemómetro]: conoce tus arcos de color. Verde: normal, hasta la V#sub[RA] (velocidad máxima en aire turbulento). Amarillo: precaución, de la V#sub[RA] a la V#sub[NE] (solo aire calmo). Línea roja: V#sub[NE], peligro de muerte. Triángulo amarillo: velocidad de aproximación con masa máxima sin lastre.
- #strong[Equipamiento mínimo (SAO.IDE.105)]: hora, altitud de presión y velocidad indicada para todo planeador (más rumbo magnético si es motorizado). Para nubes o noche se añaden velocidad vertical, actitud/viraje-resbale y rumbo magnético.
- #strong[Altímetro]: recuerda calarlo. QNH para altitud sobre el nivel del mar (rutas, espacios aéreos); QFE para altura sobre el campo (circuito).
- #strong[Variómetro (energía total)]: la herramienta clave. Ignora los "palancazos" (que cambian velocidad por altura) y solo te dice si la masa de aire sube o baja.
- #strong[Aviónica]: radio VHF, transpondedor y FLARM. El FLARM es la red de seguridad anticolisión del vuelo sin motor.

]
= Montaje de la aeronave, conexión de superficies de control
<montaje-de-la-aeronave-conexión-de-superficies-de-control>
#quote(block: true)[
Cada vez que montas un planeador estás reconstruyendo una aeronave. Los accidentes por conexiones olvidadas se repiten desde hace décadas, y todos comparten el mismo patrón: prisa, distracción y ninguna verificación final.

En este capítulo aprenderás:

- #strong[El proceso de montaje]: el orden correcto y los cuidados con tetones y bulones.
- #strong[Las conexiones de mandos]: automáticas y manuales (L'Hotellier), y por qué las segundas exigen pin de seguridad.
- #strong[Los pasadores y seguros] de la unión ala-fuselaje.
- #strong[El Positive Control Check (PCC)]: la verificación con asistente que cierra el montaje.
- #strong[El cintado]: por qué las cintas de las juntas no son estética.
]

El montaje o #strong[rigging] es una de las fases más críticas para la seguridad. Un planeador mal ensamblado se comporta de forma imprevisible o, en el peor de los casos, sufre un fallo catastrófico en vuelo. Tus mejores herramientas son la disciplina y seguir al pie de la letra el Manual de Vuelo (AFM).

== El proceso de montaje
<el-proceso-de-montaje>
Cada modelo tiene sus particularidades, pero el orden general suele ser este:

+ #strong[Fuselaje]: se saca del remolque y se asegura en su cuna o borriqueta, en posición vertical.
+ #strong[Alas]: se insertan los largueros en el fuselaje en el orden exacto especificado por el manual de vuelo (dependiendo del diseño de solapamiento de los largueros, primero la izquierda o la derecha). Antes de introducirlas, limpia y engrasa ligeramente los tetones y bulones de unión.
+ #strong[Estabilizador horizontal]: el plano de profundidad se monta al final, asegurando su fijación mecánica.

== Conexiones de mandos
<conexiones-de-mandos>
Según la antigüedad del planeador, las conexiones de alerones, aerofrenos y profundidad pueden ser de dos tipos:

- #strong[Conexiones automáticas]: al encastrar el ala o el estabilizador, los mandos se conectan solos mediante embudos o rótulas integradas. Son las más seguras.
- #strong[Conexiones manuales (L'Hotellier)]: obligan al piloto a conectar a mano una rótula. Son conexiones críticas y han causado numerosos accidentes por olvido.

#block[
#callout(
body: 
[
Si tu planeador usa conectores L'Hotellier, el pin de seguridad (imperdible) que bloquea el conector es de obligado cumplimiento en los modelos afectados por la directiva de aeronavegabilidad correspondiente. No te fíes nunca del "clic" del muelle: es el pin el que garantiza que la unión no se suelte por las vibraciones del vuelo.

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
== Pasadores y seguros
<pasadores-y-seguros>
La unión principal entre las alas y el fuselaje se hace con bulones o pasadores (#emph[pins]). Deben entrar con suavidad; no uses fuerza bruta ni martillos, porque dañarías los casquillos. Una vez dentro, tienen que quedar bloqueados por sus propios seguros o por pasadores adicionales.

== El cintado de juntas
<el-cintado-de-juntas>
Después del montaje, las juntas entre ala y fuselaje, y las del estabilizador, se sellan con cinta adhesiva específica. No es por estética: el cintado elimina fugas de aire que generan resistencia y ruido, y mejora bastante el rendimiento a baja velocidad. Usa cinta en buen estado y vigila que no se despegue por los bordes; una cinta suelta vibrando en vuelo puede hacerte pensar en problemas más serios de los que hay.

== Verificación final: el Positive Control Check (PCC)
<verificación-final-el-positive-control-check-pcc>
Con el avión montado, no vueles nunca sin hacer un chequeo de mandos positivo con un asistente:

+ El piloto se sienta en la cabina y mueve los mandos.
+ El asistente sujeta con firmeza la superficie (el alerón, por ejemplo) e intenta impedir su movimiento.
+ Se trata de comprobar no solo que la superficie se mueve en el sentido correcto, sino que la conexión es firme, sólida y sin holguras.

#block[
#callout(
body: 
[
Si durante el montaje alguien te interrumpe para hablar, vuelve a empezar el paso en curso desde el principio. Las distracciones durante el rigging son la causa número uno de conexiones críticas olvidadas.

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
#figure([
#box(image("imagenes/08-cap07-conectores-mandos.jpg"))
], caption: figure.caption(
position: bottom, 
[
Comparativa de conector manual L'Hotellier y conector automático
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap07-conectores-mandos>


#postit[
#strong[Resumen del capítulo: montaje y rigging]

- #strong[Verificación de mandos]: tras montar, el test de "mando positivo" (PCC) es obligatorio. Una persona sujeta la superficie (el alerón) y tú intentas mover la palanca. Debe ofrecer resistencia sólida. Si se mueve libre, no está conectado.
- #strong[Bulones principales]: son el seguro de vida de las alas. Deben entrar limpios y quedar asegurados (imperdibles o seguros R).
- #strong[L'Hotellier]: conexión manual crítica. Pin de seguridad siempre; el clic del muelle no basta.
- #strong[Cintado]: tapar las juntas ala-fuselaje no es solo estética; reduce el ruido y mejora bastante el rendimiento a baja velocidad.
- #strong[Carga suelta]: un clásico error mortal es dejar herramientas o pesos sueltos en el fuselaje tras el montaje. Pueden desplazarse en vuelo y bloquear los mandos.

]
= Manuales y documentos
<manuales-y-documentos>
#quote(block: true)[
Un planeador legalmente impecable importa tanto como uno mecánicamente impecable: sin los papeles en regla, ni el seguro ni el certificado de aeronavegabilidad te cubren.

En este capítulo aprenderás:

- #strong[El Manual de Vuelo (AFM)]: qué contiene y por qué es el documento maestro.
- #strong[La documentación a bordo y en el aeródromo] según SAO.GEN.155, y la excepción para vuelos locales.
- #strong[Las listas de chequeo]: CB-SIFT-CBE y la disciplina de leer, comprobar y confirmar.
- #strong[El diario de la aeronave]: la historia clínica del planeador.
]

Volar no es solo pilotar: también es gestionar la parte legal y la información técnica de la aeronave. El piloto que no conoce las limitaciones de su máquina, o que vuela sin los papeles en regla, se expone a riesgos operativos y a sanciones.

== El Manual de Vuelo (AFM / SFM)
<el-manual-de-vuelo-afm-sfm>
El #strong[Manual de Vuelo] (#emph[AFM, Aircraft Flight Manual], también #emph[SFM, Sailplane Flight Manual], en los veleros) es el documento maestro. No es un manual de usuario genérico, sino un documento legalmente ligado a la matrícula de tu planeador. En él encontrarás:

- #strong[Limitaciones]: velocidades (V#sub[NE] (Velocidad Nunca Exceder), V#sub[A] (Velocidad de Maniobra)), factores de carga, pesos máximos.
- #strong[Procedimientos de emergencia]: qué hacer ante un fuego, una rotura de cable o un fallo de mandos.
- #strong[Rendimiento]: tablas de planeo, distancias de despegue y aterrizaje.
- #strong[Peso y centrado]: límites del centro de gravedad.

== Documentación a bordo y en el aeródromo
<documentación-a-bordo-y-en-el-aeródromo>
La normativa europea de operaciones con veleros distingue entre lo que debe ir en el planeador y lo que puede quedarse en el aeródromo:

#strong[A bordo en cada vuelo (originales o copias):]

- Manual de Vuelo (AFM) o documento equivalente.
- Cartas aeronáuticas actualizadas y adecuadas para la zona del vuelo.
- Información sobre procedimientos y señales visuales de interceptación.
- Detalles del plan de vuelo ATS presentado, si procede.
- Licencia de piloto, certificado médico, documento de identidad con fotografía y datos suficientes del libro de vuelo (los exige la normativa de licencias, SFCL.045).

#strong[En el aeródromo o lugar de operación (disponibles):]

- Certificado de matrícula (CoR).
- Certificado de aeronavegabilidad (CoA) con sus anexos y el certificado de revisión (ARC).
- Certificado de niveles de ruido (si es un motovelero).
- Licencia de estación de radio de la aeronave (si lleva equipo de radio).
- Seguro de responsabilidad civil en vigor.
- Libro de a bordo o registro equivalente.

#block[
#callout(
body: 
[
#strong[SAO.GEN.155] exige llevar a bordo en cada vuelo el AFM, las cartas actualizadas y la información de señales de interceptación; los certificados (matrícula, aeronavegabilidad, ARC, seguro, licencia de radio) pueden quedarse en el aeródromo. Hay una excepción: en los vuelos que se mantengan a la vista del aeródromo, o dentro de la distancia que fije la autoridad competente, toda la documentación (incluido el AFM) puede quedarse en tierra. Lo mismo vale para la licencia y el certificado médico del piloto (SFCL.045).

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
== Listas de chequeo (checklists)
<listas-de-chequeo-checklists>
La memoria humana falla, sobre todo bajo estrés o con distracciones. Usar listas de chequeo de forma sistemática es lo que separa a un piloto serio de un aficionado.

Hay varios tipos de chequeo:

+ #strong[Inspección prevuelo]: recorrido visual, exterior e interior, según el AFM.
+ #strong[Chequeo de cabina]: justo antes de despegar. La mnemotecnia europea estándar es #strong[CB-SIFT-CBE]\; en muchos clubes españoles se usa también la tradicional #strong[CRISE]. Ambas se desarrollan en el #strong[Libro 6 --- Procedimientos operativos], capítulo 1.
+ #strong[Chequeo de viento en cola]: antes de la toma (mnemotecnias FUSTALL o WULF, detalladas en el #strong[Libro 6 --- Procedimientos operativos], capítulo 4).

#block[
#callout(
body: 
[
No recites la lista de memoria. Lee cada punto, comprueba físicamente el mando o el instrumento y confirma en voz alta su estado. Si te saltas un paso, empieza la lista de nuevo.

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
== Diario de la aeronave y mantenimiento
<diario-de-la-aeronave-y-mantenimiento>
Cada hora de vuelo y cada aterrizaje quedan registrados en el #strong[Diario de la Aeronave]. Es lo que permite seguir las inspecciones del programa de mantenimiento, y es la historia clínica del planeador. No despegues si la aeronave tiene una avería abierta que afecte a la seguridad o si ya han vencido las horas o el plazo de la próxima inspección programada.

#figure([
#box(image("imagenes/08-cap08-documentos-bordo.jpg"))
], caption: figure.caption(
position: bottom, 
[
Documentación obligatoria del planeador y carpeta de a bordo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap08-documentos-bordo>


#postit[
#strong[Resumen del capítulo: documentación del avión]

- #strong[Manual de Vuelo (AFM)]: a bordo en cada vuelo (salvo vuelos a la vista del aeródromo). Contiene los límites (V#sub[NE], factores de carga), los procedimientos de emergencia y las tablas de carga. Léelo antes de volar un modelo nuevo.
- #strong[Certificados]: el avión necesita certificado de aeronavegabilidad, ARC en vigor, seguro y licencia de estación de radio. Pueden quedarse en el aeródromo (SAO.GEN.155). Sin ARC en vigor, el seguro no cubre nada.
- #strong[Chequeos]: CB-SIFT-CBE antes de despegar, FUSTALL/WULF en viento en cola. Lee, comprueba y confirma; nunca de memoria.
- #strong[Diario técnico]: antes de volar, mira que no haya averías pendientes que te afecten. Al acabar, anota tu vuelo y cualquier incidencia.

]
= Aeronavegabilidad y mantenimiento
<aeronavegabilidad-y-mantenimiento>
#quote(block: true)[
La aeronavegabilidad no es un papel que consigues una vez: es un estado que se mantiene vuelo a vuelo, inspección a inspección.

En este capítulo aprenderás:

- #strong[El CoA y el ARC]: los dos certificados que permiten despegar legalmente, y cómo se renueva o prorroga el ARC.
- #strong[Part-ML y Part-CAO]: el marco simplificado de mantenimiento de la aviación ligera europea.
- #strong[El mantenimiento del piloto-propietario]: qué tareas puedes firmar tú mismo y con qué condiciones.
- #strong[Las AD y los SB]: las órdenes de obligado cumplimiento y las recomendaciones del fabricante.
]

La #strong[aeronavegabilidad] es la condición legal y técnica que certifica que una aeronave es segura para volar. No es algo estático: mantener un planeador aeronavegable exige vigilancia constante, un programa de mantenimiento riguroso y cumplir al pie de la letra la normativa europea.

== El CoA y el ARC: la "ITV" del cielo
<el-coa-y-el-arc-la-itv-del-cielo>
Para que un planeador despegue legalmente necesita dos documentos clave:

+ #strong[Certificado de aeronavegabilidad (CoA)]: es el "DNI" técnico de la aeronave. Describe sus características y certifica que el modelo es apto para el vuelo. Suele ser vitalicio, siempre que el avión se mantenga como debe.
+ #strong[Certificado de revisión de la aeronavegabilidad (ARC)]: es la validación periódica del CoA, con validez de un año. Lo emite una organización autorizada (CAMO o CAO) o personal de certificación independiente tras revisar la aeronave y sus registros.

#block[
#callout(
body: 
[
Según #strong[ML.A.901], el ARC tiene validez anual, pero puede prorrogarse dos veces consecutivas (un año cada vez) sin revisión completa si la aeronave ha permanecido en un #strong[entorno controlado]: gestión continua por una CAMO/CAO y mantenimiento hecho por organizaciones aprobadas. Tras esas dos prórrogas toca revisión de aeronavegabilidad completa.

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
Este capítulo es el desarrollo técnico completo del CoA y el ARC; su vertiente jurídica ---qué documentos son obligatorios a bordo y la responsabilidad legal de volar con ellos en vigor--- se estudia en el #strong[Libro 1 --- Derecho aéreo], capítulo 2.

== Normativa EASA: Part-ML y Part-CAO
<normativa-easa-part-ml-y-part-cao>
La aviación ligera se rige por normas simplificadas, que recortan la carga burocrática sin bajar la guardia en seguridad:

- #strong[Part-ML]: la normativa específica para veleros y aviones ligeros. Permite que el Programa de Mantenimiento de la Aeronave (AMP) lo declare el propio propietario, que asume así más responsabilidad sobre su avión.
- #strong[Part-CAO]: regula a las organizaciones autorizadas a hacer el mantenimiento y a gestionar la aeronavegabilidad de forma combinada.

Cuando el AMP se basa en el #strong[Programa Mínimo de Inspección (MIP)] que recoge la propia Part-ML (ML.A.302), este fija un suelo regulatorio: una inspección al menos #strong[anual o cada 100 horas de vuelo, lo que antes se cumpla]. El AMP puede ser más exigente ---lo que diga el fabricante---, pero nunca menos que ese mínimo.

== Mantenimiento del piloto-propietario
<mantenimiento-del-piloto-propietario>
EASA te deja, como piloto y propietario, hacer ciertas tareas de mantenimiento sencillas sin pasar por un taller certificado: cambiar neumáticos, limpiar filtros, sustituir bujías (en motoveleros) o lubricar, entre otras. Las recoge el Apéndice II de Part-ML, junto con lo que diga el programa de mantenimiento de tu aeronave.

#block[
#callout(
body: 
[
Solo puedes firmar tareas de piloto-propietario si eres el propietario (o copropietario) legal de la aeronave y tienes una licencia de piloto válida (ML.A.803). Y todas las tareas deben quedar registradas y firmadas en el Diario de la Aeronave, con tu número de licencia.

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
== AD y SB: órdenes de obligado cumplimiento
<ad-y-sb-órdenes-de-obligado-cumplimiento>
La seguridad aérea es cosa de todos. Cuando se detecta un fallo de diseño o un problema en un modelo concreto, aparecen dos figuras:

- #strong[Directiva de aeronavegabilidad (AD)]: la emite EASA y es obligatoria por ley. Si un planeador tiene una AD pendiente y no se cumple en plazo, queda en tierra automáticamente (#emph[AOG, Aircraft On Ground]).
- #strong[Boletín de servicio (SB)]: lo emite el fabricante. Suelen ser recomendaciones de mejora. No siempre obligan por ley, pero ignorarlos puede afectar a la seguridad y al valor de reventa del avión.

#figure([
#box(image("imagenes/08-cap09-ciclo-mantenimiento.jpg"))
], caption: figure.caption(
position: bottom, 
[
El ciclo de la aeronavegabilidad: AMP, mantenimiento y ARC
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap09-ciclo-mantenimiento>


#postit[
#strong[Resumen del capítulo: mantenimiento y aeronavegabilidad]

- #strong[Inspección diaria (DI)]: es cosa del piloto. Sigue la lista: presión de ruedas, estado del gancho de remolque, bisagras de mandos, limpieza de pitot y estática.
- #strong[CoA y ARC]: el CoA es vitalicio; el ARC dura un año y se prorroga dos veces en entorno controlado (ML.A.901). Sin ARC en vigor, el avión no vuela.
- #strong[Mantenimiento programado]: la frecuencia concreta de inspecciones (por tiempo, ciclos u horas) la fija el AMP, según lo que diga el fabricante. Pero hay un suelo: si el AMP se basa en el Programa Mínimo de Inspección de Part-ML (ML.A.302), nunca puede ser menos restrictivo que #strong[una inspección anual o cada 100 h, lo que antes se cumpla].
- #strong[Mantenimiento por piloto-propietario]: tareas sencillas del Apéndice II de Part-ML, solo si eres propietario con licencia válida, y siempre registradas y firmadas (ML.A.803).
- #strong[Reporte de defectos]: si rompes algo o ves algo raro, anótalo. El siguiente piloto puede no verlo y matarse (un cable de timón deshilachado, por ejemplo).

]
= Estructura, motores y hélices
<estructura-motores-y-hélices>
#quote(block: true)[
El motor le ha dado al vuelo sin motor una red de seguridad contra el aterrizaje fuera de campo, y a cambio le ha sumado nuevos modos de fallo que el piloto tiene que dominar.

En este capítulo aprenderás:

- #strong[Las configuraciones motorizadas]: sustentador (#strong[turbo]), autolanzable y motovelero de turismo (TMG).
- #strong[Los tipos de motor]: dos tiempos, cuatro tiempos y eléctricos (FES).
- #strong[Los sistemas del motor de combustión]: encendido por magnetos, carburación y engelamiento, y combustible.
- #strong[El mástil retráctil y las hélices] plegables o posicionables, y el paso de pala.
- #strong[La gestión del motor en vuelo]: secuencia de arranque, alturas de decisión e instrumentación.
]

El motor ha cambiado el vuelo sin motor: ha roto la dependencia absoluta de los medios de lanzamiento externos y ha aportado una red de seguridad frente a las tomas fuera de campo. A cambio, añade complejidad mecánica y nuevas responsabilidades al piloto.

== Turbo o autolanzable
<turbo-o-autolanzable>
No todos los motores cumplen la misma función:

- #strong[Sustentador o "turbo"]: un motor pequeño (casi siempre de dos tiempos) sin potencia para despegar. Su misión es sostener el vuelo y devolverte a casa si fallan las térmicas.
- #strong[Autolanzable] (#emph[self-launch]): un motor potente que permite despegar solo desde la pista. Alcanzada la altura deseada, se apaga y se guarda por completo.
- #strong[Motovelero de turismo (TMG)]: aeronaves con motor fijo (no escamoteable), como la Super Dimona, a medio camino entre el avión ligero y el planeador.

== Tipos de motor
<tipos-de-motor>
+ #strong[Motores de 2 tiempos]: muy habituales en sistemas escamoteables por su ligereza y su potencia. Necesitan mezcla de gasolina y aceite, y son más ruidosos y vibran más que los de 4 tiempos.
+ #strong[Motores eléctricos (FES)]: la gran novedad. Usan una hélice plegable en el morro y baterías de litio. Son fiabilísimos, silenciosos y de arranque instantáneo.
+ #strong[Motores de 4 tiempos]: sobre todo en motoveleros TMG. Más pesados, pero más eficientes y mecánicamente más fiables.

== Sistemas del motor de combustión
<sistemas-del-motor-de-combustión>
Los motoveleros (TMG) y los autolanzables con motor de combustión añaden tres sistemas que el piloto debe entender, porque sus fallos tienen procedimientos propios.

=== Encendido: los magnetos
<encendido-los-magnetos>
El encendido lo generan los #emph[magnetos], no la batería. Un magneto es un generador autónomo: mientras el cigüeñal gire, produce por sí mismo la alta tensión que necesitan las bujías, con independencia de la batería y del alternador. Por eso el motor sigue funcionando aunque falle el sistema eléctrico. Los motores de aviación montan encendido #emph[dual] (dos magnetos y dos bujías por cilindro) por seguridad y rendimiento; antes del vuelo se hace la prueba de magnetos, comprobando la pequeña caída de RPM al dejar uno solo en funcionamiento.

#block[
#callout(
body: 
[
Como el magneto genera corriente por sí mismo, para detenerlo hay que poner a masa (cortocircuitar) su devanado primario. Un magneto con el cable de masa roto puede dejar el motor "vivo" aunque el contacto esté en #emph[OFF]: trata siempre la hélice como si pudiera arrancar.

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
=== Carburación y engelamiento
<carburación-y-engelamiento>
Muchos motores alimentan los cilindros con un carburador. Al expandirse el aire y vaporizarse el combustible, la mezcla se enfría, y esa caída de temperatura puede congelar la humedad del aire dentro del carburador: es el #emph[engelamiento del carburador]. El riesgo es mayor entre −7 °C y +21 °C con humedad alta, y su primer síntoma es una caída de RPM.

Para deshacerlo se usa la #emph[calefacción del carburador], que mete aire caliente del colector de escape. Resta potencia, así que se usa con criterio: nunca en el despegue, lo justo en tierra, en crucero solo si hay riesgo de engelamiento, y antes de reducir potencia en la aproximación.

=== Combustible
<combustible>
Los motoveleros usan AVGAS (gasolina de aviación, con plomo) o MOGAS (gasolina de automoción), siempre el que indique el AFM. Antes de volar se drena una muestra para descartar agua o impurezas, que pueden parar el motor: el agua, más densa, se deposita en el fondo del #emph[tester]. En cuanto a la cantidad, la norma (SAO.OP.120) exige combustible suficiente para completar el vuelo con seguridad; la práctica prudente es no despegar nunca con menos de 30-45 minutos de reserva.

== La hélice y el mástil (pylon)
<la-hélice-y-el-mástil-pylon>
En la mayoría de los autolanzables, el motor va montado en un mástil retráctil (#emph[pylon]) detrás del piloto.

- #strong[Hélices retráctiles]: las palas se paran en una posición vertical precisa (con un sensor de posición o un tope mecánico) para poder guardarse dentro del fuselaje.
- #strong[Hélices plegables (FES)]: en el morro, la fuerza centrífuga las abre al girar y la presión del aire las pliega contra el fuselaje cuando el motor se detiene.

Según el paso de pala, la hélice puede ser de #emph[paso fijo] (el ángulo de pala no cambia: sencilla y robusta) o de #emph[paso variable / velocidad constante] (un regulador ajusta el ángulo: paso corto y más RPM para el despegue, paso largo para el crucero eficiente).

== Gestión y operación del motor
<gestión-y-operación-del-motor>
Manejar el motor de un planeador exige disciplina. La secuencia de arranque (extracción, apertura de puertas, encendido de la bomba de combustible, arranque) tiene que estar perfectamente memorizada.

#block[
#callout(
body: 
[
Con el motor extraído, la relación de planeo cae en picado por la resistencia del mástil. Si el motor no arranca tras sacarlo, tienes que estar a altura suficiente para hacer la toma de emergencia con el motor fuera, o para retraerlo a tiempo. Elige siempre el campo antes de intentar el arranque: el motor es el plan B, nunca el plan A.

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
== Instrumentación y combustible
<instrumentación-y-combustible>
La unidad de control electrónica (como el ILEC) gestiona las RPM y las temperaturas de cilindro (CHT) y de gases de escape (EGT). El piloto de motovelero debe vigilar de cerca el nivel de combustible y la temperatura, porque un motor de dos tiempos es muy sensible al sobrecalentamiento.

#figure([
#box(image("imagenes/08-cap10-motor-retractil.jpg"))
], caption: figure.caption(
position: bottom, 
[
Esquema de un planeador con motor retráctil en posición de funcionamiento
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap10-motor-retractil>


#postit[
#strong[Resumen del capítulo: motoveleros y sistemas retráctiles]

- #strong[Complejidad]: un motor añade peso, complejidad y modos de fallo. El arranque en vuelo consume altura; por eso la cota mínima para intentarlo son 300 m (ver #strong[Libro 6 --- Procedimientos operativos], capítulo 2).
- #strong[Fallo de arranque]: ten siempre un campo elegido antes de intentar arrancar. Si el motor no sale o no prende, te queda un planeador con un "freno de aire" gigante (el pilón): el planeo se reduce a la mitad.
- #strong[Shock cooling]: no pares el motor de golpe tras una subida a plena potencia. Déjalo enfriar al ralentí, o planeando con el motor fuera unos minutos, para evitar grietas en la culata.
- #strong[Hélice]: asegúrate de que está frenada y vertical antes de retraer. El espejo es tu amigo. Paso fijo o paso variable (velocidad constante), según el modelo.
- #strong[Motor de combustión]: el encendido por magnetos es independiente de la batería (para pararlo, se pone a masa el primario). Vigila el engelamiento del carburador (−7 a +21 °C con humedad; primer síntoma, caída de RPM) y drena el combustible antes de volar.

]
= Sistemas de lastre con agua
<sistemas-de-lastre-con-agua>
#quote(block: true)[
El agua en las alas es el "turbo" de los días de térmicas fuertes: más carga alar, más velocidad de crucero. Pero un sistema de lastre mal gestionado convierte esa ventaja en una emergencia.

En este capítulo aprenderás:

- #strong[Para qué sirve el lastre]: carga alar y desplazamiento de la polar de velocidades.
- #strong[Los componentes del sistema]: tanques o bolsas, válvulas de descarga y respiraderos.
- #strong[El llenado y el vaciado]: simetría, tiempos y comprobaciones.
- #strong[Los riesgos]: congelación, vaciado asimétrico y aterrizaje con agua.
- #strong[El lastre de cola]: el contrapeso que restaura el centrado óptimo.
]

El lastre de agua (#strong[water ballast]) es lo que permite a los planeadores de competición ajustar su peso a las condiciones del día. Con más peso, el velero vuela más rápido perdiendo menos altura, algo decisivo para hacer grandes distancias cuando las térmicas son potentes.

== Para qué sirve: carga alar y velocidad
<para-qué-sirve-carga-alar-y-velocidad>
Añadir agua aumenta la #strong[carga alar], y eso desplaza la polar de velocidades hacia la derecha: la velocidad de planeo óptima sube y las transiciones entre térmicas son mucho más rápidas. Tiene un precio: el planeador trepa peor en las térmicas flojas y su velocidad de pérdida es mayor. El efecto del lastre sobre la polar se desarrolla en el #strong[Libro 7 --- Planificación y rendimiento], capítulo 2.

== Componentes del sistema
<componentes-del-sistema>
El sistema es sencillo de concepto, pero exige un mantenimiento escrupuloso:

- #strong[Tanques o bolsas]: en el interior de las alas, cerca del larguero. Pueden ser bolsas de goma o compartimentos estancos integrados en la estructura.
- #strong[Válvulas de descarga]: vacían el agua al exterior. Se accionan desde la cabina, normalmente con una palanca pequeña.
- #strong[Respiraderos]: orificios que dejan entrar aire mientras sale el agua. Si uno se bloquea, la succión puede dañar la estructura del ala.

== Llenado y vaciado
<llenado-y-vaciado>
El llenado se hace por unos orificios en el extradós del ala. Es clave que los dos planos carguen la misma cantidad de agua, para mantener la simetría lateral.

El vaciado en vuelo suele tardar entre 3 y 8 minutos, según el planeador. Al abrir las válvulas verás dos estelas de agua saliendo de las alas: la confirmación de que el sistema funciona.

#block[
#callout(
body: 
[
Vacía el lastre de agua antes de aterrizar; es una limitación operativa del Manual de Vuelo. El planeador no está diseñado para encajar las cargas de impacto de una toma con los tanques llenos. Además, aterrizar con agua alarga mucho la carrera de frenado y aumenta el riesgo de daños estructurales si chocas contra un obstáculo.

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
== Riesgos y limitaciones
<riesgos-y-limitaciones>
+ #strong[Congelación]: no cargues agua si vas a volar por encima de la cota de congelación (0 °C). Al congelarse, el agua aumenta de volumen y puede reventar los tanques o bloquear las válvulas.
+ #strong[Asimetría]: si una válvula se bloquea y solo se vacía un ala, tendrás un desequilibrio lateral peligroso. Vuela algo más rápido para conservar el control y prepárate para una toma con un ala "pesada".
+ #strong[Humedad]: vacía siempre los tanques después del vuelo y deja que se sequen, para evitar moho y corrosión en las válvulas.

== Lastre de cola
<lastre-de-cola>
Para compensar el desplazamiento del centro de gravedad que provoca el agua de las alas, algunos planeadores llevan un pequeño depósito en la deriva. Al llenar ese tanque de cola, se recupera el equilibrio óptimo del velero para volar rápido.

#figure([
#box(image("imagenes/08-cap11-lastre-agua.jpg"))
], caption: figure.caption(
position: bottom, 
[
Esquema del sistema de lastre de agua compartimentado
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap11-lastre-agua>


#postit[
#strong[Resumen del capítulo: lastre de agua]

- #strong[Para qué sirve]: aumentar la carga alar y desplazar la polar a la derecha (correr más con el mismo ángulo de planeo). Solo merece la pena con térmicas fuertes.
- #strong[Riesgo de hielo]: el agua se expande al congelarse. Si subes por encima de la isocero, puede reventar la estructura interna del ala. Vacía antes de subir.
- #strong[Vaciado asimétrico]: si una válvula falla y te quedas con agua en un solo ala, tienes una emergencia grave de control lateral. Aterriza con velocidad extra y cuidado: el avión querrá alabear hacia el ala pesada.
- #strong[Antes de aterrizar]: tira el agua. Aterrizar con lastre castiga el tren y la estructura sin necesidad, y sube la velocidad de toma.

]
= Baterías
<baterías>
#quote(block: true)[
Un planeador vuela sin motor, pero no sin electricidad: la radio, el FLARM, el transpondedor y los variómetros dependen de la batería. Gestionarla bien es gestionar tu seguridad.

En este capítulo aprenderás:

- #strong[Los tipos de batería]: plomo-ácido (gel/AGM) y litio (LiFePO4), con sus ventajas y sus precauciones.
- #strong[La fijación de la batería]: por qué la certificación exige soportes a prueba de impacto.
- #strong[La gestión de la energía en vuelo]: amperios-hora, consumos y el efecto del frío.
- #strong[La protección del sistema]: fusibles y disyuntores.
]

El planeador vuela sin motor, pero no sin electricidad. La radio, el transpondedor, el FLARM y los variómetros electrónicos necesitan una fuente de energía fiable. En vuelos largos, gestionar la batería es tan importante como gestionar el combustible en un avión a motor.

== Tipos de baterías
<tipos-de-baterías>
En la aviación de recreo predominan dos tecnologías:

- #strong[Plomo-ácido (gel/AGM)]: las más comunes por su bajo coste y su fiabilidad. Van selladas y no necesitan mantenimiento, pero pesan lo suyo (entre 2,5 y 4 kg por unidad).
- #strong[Litio (LiFePO4)]: mucho más ligeras y con una descarga más plana (mantienen el voltaje casi hasta el final). A cambio, piden cargadores específicos y un manejo cuidadoso para evitar incendios por cortocircuito.

== Ubicación y seguridad estructural
<ubicación-y-seguridad-estructural>
La batería suele ir en la sección central del fuselaje, detrás del piloto, o en un compartimento del morro (para ayudar al centrado).

Por su densidad de peso, su fijación es un punto crítico de inspección. Una batería mal sujeta se convierte en un proyectil mortal en un aterrizaje brusco o un accidente.

#block[
#callout(
body: 
[
#strong[CS 22.561(d)] exige que la estructura de soporte retenga cualquier masa que pueda lesionar a un ocupante si se suelta en un aterrizaje de emergencia, soportando las fuerzas de inercia últimas de #strong[CS 22.561(b)(1)]: 15g hacia delante, 9g hacia abajo, 7,5g hacia arriba y 6g lateral. No sujetes nunca la batería con gomas elásticas ni montajes improvisados: usa los soportes o cinchas aprobados por el fabricante y comprueba su firmeza en cada inspección prevuelo.

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
== Gestión de la energía en vuelo
<gestión-de-la-energía-en-vuelo>
La capacidad se mide en amperios-hora (Ah). Una batería de 12 Ah puede alimentar, en teoría, un equipo que consuma 1 amperio durante 12 horas.

Pero el rendimiento cae mucho con el frío: a 0 °C te queda en torno al 80 % de la capacidad nominal. Si planeas un vuelo largo en altura, despega con las baterías al 100 %.

Y si vas a volar en nubes (con la habilitación correspondiente), no despegues sin las baterías prácticamente llenas: sin referencias visuales, tus instrumentos son lo único que te mantiene con las alas niveladas, y quedarte sin energía dentro de una nube es una emergencia mayor. La norma no fija un porcentaje concreto; la gestión de la energía disponible es responsabilidad tuya (SAO.OP.145 en los motorizados).

== Protección del sistema: fusibles
<protección-del-sistema-fusibles>
Todo el sistema eléctrico tiene que ir protegido para evitar incendios.

- #strong[Fusibles]: se instalan lo más cerca posible del terminal positivo de la batería. Un valor típico en planeadores es de 5 amperios, aunque el correcto es siempre el que indique el esquema eléctrico de tu aeronave.
- #strong[Disyuntores (breakers)]: en planeadores con motor, por el alto consumo del arranque, se usan disyuntores que pueden rearmarse en vuelo.

#block[
#callout(
body: 
[
Lleva siempre fusibles de repuesto en el bolsillo de la cabina. Si uno se funde en vuelo, cámbialo una vez. Si vuelve a fundirse, desconecta el equipo afectado: tienes un cortocircuito serio que puede acabar en fuego eléctrico.

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
#figure([
#box(image("imagenes/08-cap12-sistema-electrico.jpg"))
], caption: figure.caption(
position: bottom, 
[
Diagrama del sistema eléctrico básico y ubicación de la batería
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap12-sistema-electrico>


#postit[
#strong[Resumen del capítulo: baterías y sistema eléctrico]

- #strong[Tipos]: plomo-ácido/gel (pesadas, robustas, baratas) frente a LiFePO4 (ligeras, voltaje constante, cargador específico).
- #strong[Fusibles]: imprescindibles. Lo más cerca posible del borne de la batería. Un cortocircuito en vuelo sin fusible es fuego en cabina en segundos.
- #strong[Efecto del frío]: las baterías pierden capacidad de golpe con el frío. Una que parece llena en tierra puede morirse rápido en onda a -20 ºC.
- #strong[Vuelo en nubes]: despega con las baterías prácticamente llenas. Sin referencias visuales, los instrumentos son tu vida, y ninguna norma te salvará de una batería vacía dentro de una nube.
- #strong[Fijación]: la batería es un proyectil de varios kilos. Su soporte debe aguantar 15g hacia delante (CS 22.561). Comprueba que su "cinturón de seguridad" está apretado y bloqueado antes de cada vuelo.

]
= Paracaídas de emergencia
<paracaídas-de-emergencia>
#quote(block: true)[
El paracaídas de emergencia es el único equipo del planeador que esperas no usar jamás, y justo por eso exige un mantenimiento y un ajuste impecables.

En este capítulo aprenderás:

- #strong[El paracaídas como sistema]: campana, contenedor, anilla y los enemigos del nylon.
- #strong[El mantenimiento]: replegado periódico, vida útil y cuidado diario.
- #strong[La colocación y el ajuste del arnés]: por qué un arnés flojo lesiona.
- #strong[La secuencia de abandono], en resumen; su entrenamiento completo está en el #strong[Libro 6 --- Procedimientos operativos], capítulo 8.
]

El paracaídas de emergencia es el equipo que ningún piloto quiere estrenar, pero que todos tienen que saber manejar a la perfección. En el vuelo sin motor, donde el riesgo de colisión en térmica es real, es tu última línea de defensa.

== El paracaídas: tu seguro de vida
<el-paracaídas-tu-seguro-de-vida>
Los paracaídas de planeador son de apertura manual. La campana va guardada en un contenedor que el piloto lleva a la espalda y que, de paso, hace de respaldo del asiento.

No es un objeto pasivo: es un sistema mecánico de precisión con cuidados propios.

- #strong[Humedad]: el sudor o la lluvia apelmazan la tela y retrasan la apertura.
- #strong[Rayos UV]: el sol degrada las fibras de nylon. Ten el paracaídas siempre en su bolsa o dentro de la cabina cerrada.

== Mantenimiento y plegado
<mantenimiento-y-plegado>
El aire atrapado entre los pliegues de la tela se va perdiendo con el tiempo. Por eso el fabricante exige un replegado periódico por personal certificado (normalmente cada 6 o 12 meses, según el modelo). Y los paracaídas tienen además una vida útil límite (suele ser de 15 o 20 años) marcada por el fabricante, pasada la cual se retiran del servicio.

#block[
#callout(
body: 
[
Un paracaídas plegado hace una semana se abre mucho antes que uno plegado hace un año. No apures los plazos de revisión: esos segundos de diferencia en la apertura pueden ser vitales a baja altura.

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
== Colocación y ajuste
<colocación-y-ajuste>
El paracaídas tiene que ir ajustado al cuerpo, no al asiento. Las perneras, apretadas (pero que te dejen caminar), y la cinta del pecho, cerrada. Si saltas con un arnés flojo, el tirón de la apertura puede causarte lesiones graves en la columna o los hombros.

== La secuencia de abandono (bailout)
<la-secuencia-de-abandono-bailout>
El abandono del planeador (#strong[bail-out]) ante una emergencia que lo deje ingobernable (una colisión, una rotura estructural) exige una secuencia clarísima en tu cabeza:

+ #strong[Lanzar la cabina]: tira del mando rojo de emergencia.
+ #strong[Soltar cinturones]: libera la hebilla central de seguridad.
+ #strong[Saltar]: impúlsate hacia fuera.
+ #strong[Tirar de la anilla]: agárrala con firmeza y tira con energía extendiendo el brazo.

El procedimiento completo (la decisión de abandono, la salida con fuerzas G, el descenso bajo la campana y la toma de tierra, incluidas las caídas en agua y sobre líneas eléctricas) se desarrolla en el #strong[Libro 6 --- Procedimientos operativos, capítulo 8]. Aquí nos quedamos con el equipo: si el paracaídas no está bien plegado, bien ajustado y dentro de su vida útil, la mejor técnica de salto no te servirá de nada.

#block[
#callout(
body: 
[
La altura mínima recomendada para un salto con garantías es de 150 metros sobre el terreno: la campana necesita entre 50 y 90 metros para desplegarse del todo, y el abandono se come los primeros 100. Por debajo de esa cota el margen es crítico. Si la emergencia ocurre alto, no lo dudes: cada segundo de demora es altura perdida.

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
#figure([
#box(image("imagenes/08-cap13-secuencia-salto.jpg"))
], caption: figure.caption(
position: bottom, 
[
Secuencia de abandono de emergencia y apertura del paracaídas
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap13-secuencia-salto>


#postit[
#strong[Resumen del capítulo: paracaídas (sistema)]

- #strong[Mantenimiento]: no es eterno. Pide plegado y aireación periódicos por un #strong[rigger] certificado (cada 6-12 meses según fabricante) y tiene una vida útil límite (15 o 20 años, por ejemplo).
- #strong[Ajuste]: arnés ceñido al cuerpo, perneras apretadas, pecho cerrado. Un arnés flojo convierte el tirón de apertura en lesión.
- #strong[Cuidado diario]: la luz UV, la humedad y la suciedad son sus enemigos. Llévalo siempre en su bolsa y no lo dejes tirado en la pista.
- #strong[Secuencia]: cabina, cinturones, saltar, anilla. Mínimo recomendado: 150 m AGL. El procedimiento completo se entrena con el #strong[Libro 6 --- Procedimientos operativos], capítulo 8.

]
= Equipo de evacuación de emergencia
<equipo-de-evacuación-de-emergencia>
#quote(block: true)[
Si el vuelo termina mal y lejos de casa, tu supervivencia depende de lo que llevabas puesto y de lo que cargaste en el fuselaje antes de despegar.

En este capítulo aprenderás:

- #strong[Las balizas de localización]: ELT fijo y PLB portátil, y por qué deben emitir en 406 MHz.
- #strong[Los sistemas de oxígeno]: flujo continuo y EDS, y cuándo exige la norma usarlos.
- #strong[El kit de supervivencia esencial] para vuelos de montaña o sobre zonas despobladas.
]

En una situación extrema, el equipo de emergencia y tu capacidad de supervivencia deciden si el rescate sale bien. Ir preparado para lo peor es lo que te permite volar tranquilo.

== Balizas de localización: ELT y PLB
<balizas-de-localización-elt-y-plb>
Si tienes un accidente o una toma forzosa en una zona remota, necesitas que los servicios de búsqueda y rescate (SAR) te encuentren rápido.

- #strong[ELT (Emergency Locator Transmitter)]: va instalada de forma fija en el planeador. Se activa sola por el impacto (G) o a mano.
- #strong[PLB (Personal Locator Beacon)]: baliza portátil que el piloto lleva en el bolsillo o en el paracaídas. Se activa a mano.

#block[
#callout(
body: 
[
Asegúrate de que tu baliza emite en 406 MHz. Las antiguas señales de 121.5 MHz ya no se vigilan por satélite; solo sirven para el rastreo cercano (#emph[homing]) de los equipos de rescate. Y la baliza debe estar registrada oficialmente.

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
== Sistemas de oxígeno e hipoxia
<sistemas-de-oxígeno-e-hipoxia>
A medida que subes, la presión atmosférica baja y a tus pulmones les llegan menos moléculas de oxígeno. Eso provoca la #strong[hipoxia], con síntomas traicioneros: euforia, falta de concentración, visión de túnel. La fisiología completa de la hipoxia, el tiempo de conciencia útil y la regla «oxígeno al 100 % y desciende» se estudian en el #strong[Libro 2 --- Factores humanos, capítulo 4]. Aquí nos centramos en el equipo y en la norma.

#block[
#callout(
body: 
[
#strong[SAO.OP.150 (uso de oxígeno suplementario)]: «El piloto al mando se asegurará de que todas las personas a bordo utilicen oxígeno suplementario siempre que determine que, a la altitud del vuelo previsto, la falta de oxígeno podría provocar un deterioro de sus facultades o afectarles perjudicialmente.»

El #strong[AMC1 SAO.OP.150] concreta el criterio: cuando el piloto no pueda valorar ese efecto, debe garantizar que todos los ocupantes usan oxígeno durante cualquier período en que la altitud de presión supere los 10.000 ft.

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
Como buena práctica fisiológica, que no como requisito normativo, muchos pilotos usan oxígeno desde altitudes menores (en torno a 5.000 ft) al atardecer, porque la visión es lo primero que se resiente con la falta de oxígeno.

== Equipos de oxígeno
<equipos-de-oxígeno>
+ #strong[Flujo continuo]: el oxígeno sale sin parar de un depósito a través de una cánula o una máscara. Es sencillo, pero poco eficiente: gasta mucho gas.
+ #strong[Sistemas EDS (Electronic Delivery System)]: dispositivos que detectan tu inspiración y sueltan un pulso de oxígeno justo cuando lo necesitas. Multiplican por tres o cuatro la duración de la botella.

== Kit de supervivencia esencial
<kit-de-supervivencia-esencial>
No despegues sin un kit básico de supervivencia, sobre todo si vuelas sobre montaña o zonas despobladas. Debería llevar:

- #strong[Agua]: al menos 1 o 2 litros. La deshidratación nubla el juicio.
- #strong[Señalización]: un espejo de señales y un silbato.
- #strong[Protección térmica]: una manta de supervivencia (foil) para no entrar en hipotermia si te toca pasar la noche fuera.
- #strong[Energía]: un teléfono móvil con la batería cargada y, a poder ser, una batería externa (powerbank).

#figure([
#box(image("imagenes/08-cap14-equipo-supervivencia.jpg"))
], caption: figure.caption(
position: bottom, 
[
Componentes esenciales del kit de supervivencia y baliza PLB
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-08-cap14-equipo-supervivencia>


#postit[
#strong[Resumen del capítulo: equipo de emergencia]

- #strong[ELT / PLB]: tu baliza de salvación. Las de 406 MHz con GPS mandan tu posición exacta al satélite en minutos. Las antiguas de 121.5 MHz ya no se vigilan por satélite.
- #strong[Oxígeno]: la regla es SAO.OP.150: el piloto valora el riesgo de hipoxia; si no puede valorarlo, oxígeno siempre por encima de 10.000 ft (AMC1). Los sistemas EDS (a demanda) ahorran mucho oxígeno. La fisiología se estudia en el #strong[Libro 2 --- Factores humanos], capítulo 4.
- #strong[Kit de supervivencia]: agua, abrigo, espejo de señales, móvil cargado. Si aterrizas en una ladera remota, pueden tardar horas o días en sacarte. Vístete para la temperatura de fuera, no para la de cabina.

]
#show: appendices.with("Apéndices", hide-parent: true)
#heading(level: 1, numbering: none)[Apéndices]
= Syllabus Oficial EASA - Conocimientos Generales de la Aeronave
<syllabus-oficial-easa---conocimientos-generales-de-la-aeronave>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- 8.1. Estructura (Airframe).
- 8.2. Diseño de sistemas, cargas y tensiones.
- 8.3. Tren de aterrizaje, ruedas, neumáticos y frenos.
- 8.4. Masa y centro de gravedad.
- 8.5. Mandos de vuelo.
- 8.6. Instrumentos.
- 8.7. Montaje de la aeronave, conexión de superficies de control.
- 8.8. Manuales y documentos.
- 8.9. Aeronavegabilidad y mantenimiento.
- 8.10. Estructura, motores y hélices.
- 8.11. Sistemas de lastre con agua (Water Ballast Systems).
- 8.12. Baterías (rendimiento y limitaciones operativas).
- 8.13. Paracaídas de emergencia.
- 8.14. Equipo de evacuación de emergencia (Emergency Bail-Out Aid).

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

== Ponte a prueba
<ponte-a-prueba>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/08-aeronave-sistemas/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

= Glosario de términos
<glosario-de-términos>
Este glosario contiene las definiciones y acrónimos más relevantes de Conocimientos Generales de la Aeronave aplicables a la licencia de piloto de planeador (SPL).

/ #strong[AD (Directiva de Aeronavegabilidad / Airworthiness Directive)]: #block[
Orden de obligado cumplimiento emitida por EASA cuando se detecta una condición insegura en un tipo de aeronave. Si no se cumple en el plazo indicado, la aeronave queda automáticamente en tierra (AOG). (Mencionado en: cap. 9)
]

/ #strong[Aerofrenos (Spoilers)]: #block[
Superficies móviles situadas generalmente en el extradós alar, accionadas por el piloto, cuya función es destruir la sustentación y aumentar la resistencia aerodinámica para controlar la senda de aproximación. (Mencionado en: cap. 5)
]

/ #strong[AFM (Manual de Vuelo / Aircraft Flight Manual)]: #block[
Documento maestro legalmente vinculado a la matrícula de la aeronave que recoge sus limitaciones (velocidades, factores de carga, pesos), procedimientos normales y de emergencia, datos de rendimiento y límites de centrado. En veleros se denomina también SFM (#strong[Sailplane Flight Manual]) o GFM (#strong[Glider Flight Manual]). (Mencionado en: cap. 8)
]

/ #strong[ARC (Certificado de Revisión de la Aeronavegabilidad / Airworthiness Review Certificate)]: #block[
Certificado de validez anual que confirma que la aeronave y sus registros han superado la revisión de aeronavegabilidad reglamentaria, acreditando que es segura para volar. (Mencionado en: cap. 9)
]

/ #strong[Bail-out (Abandono del planeador)]: #block[
Procedimiento de emergencia que consiste en el salto en paracaídas desde una aeronave en vuelo cuando esta ya no es controlable o segura. (Mencionado en: cap. 13)
]

/ #strong[Carga alar (Wing loading)]: #block[
Relación entre la masa total del planeador y la superficie de sus alas. Se expresa en kg/m² e influye directamente en las velocidades de crucero y de pérdida. (Mencionado en: cap. 11)
]

/ #strong[Carga de rotura (Ultimate load)]: #block[
Carga a la que la estructura falla de forma catastrófica. Se obtiene multiplicando la carga límite por el factor de seguridad de 1,5 establecido en CS 22.303. (Mencionado en: cap. 2)
]

/ #strong[Carga límite (Limit load)]: #block[
Carga máxima que la estructura puede soportar sin sufrir deformación permanente. Tras alcanzarla, la aeronave debe recuperar su forma original sin daños. (Mencionado en: cap. 2)
]

/ #strong[CG (Centro de gravedad)]: #block[
Punto teórico donde se considera aplicada la resultante de todas las fuerzas de gravedad que actúan sobre el planeador. Su ubicación longitudinal es clave para la estabilidad y el control del vuelo. (Mencionado en: cap. 4)
]

/ #strong[CoA (Certificado de Aeronavegabilidad)]: #block[
Documento generalmente vitalicio que certifica que la aeronave es conforme a su tipo certificado y apta para el vuelo, siempre que se mantenga adecuadamente y conserve un ARC en vigor. (Mencionado en: cap. 9)
]

/ #strong[Compensador (Trim)]: #block[
Dispositivo (de muelles o de pestaña aerodinámica) que alivia la presión que el piloto debe mantener sobre la palanca para conservar una velocidad determinada. Se acciona con el mando verde o un pulsador eléctrico. (Mencionado en: cap. 5)
]

/ #strong[Composite (Material compuesto)]: #block[
Material formado por fibras (vidrio o carbono) embebidas en resina. Domina la construcción de planeadores modernos por su relación resistencia/peso y su acabado aerodinámico liso (GRP: fibra de vidrio; CRP: fibra de carbono). (Mencionado en: cap. 1)
]

/ #strong[CS-22 (Certification Specifications for Sailplanes)]: #block[
Norma de certificación de EASA específica para planeadores y motoveleros. Define, entre otros, los factores de carga de diseño (CS 22.337), el factor de seguridad (CS 22.303) y los requisitos de retención de masas en cabina (CS 22.561). (Mencionado en: cap. 2)
]

/ #strong[Cúpula (Canopy)]: #block[
Cubierta transparente de plexiglás de la cabina. Incorpora pestillos de bloqueo, ventilación y un mecanismo de suelta de emergencia que libera la cúpula completa para permitir el salto en paracaídas. (Mencionado en: cap. 1)
]

/ #strong[EDS (Sistema de Oxígeno a Demanda / Electronic Delivery System)]: #block[
Sistema electrónico de suministro de oxígeno a demanda que detecta la inspiración del piloto y libera un pulso de oxígeno en ese instante, multiplicando la autonomía de la botella de oxígeno al interrumpir el flujo durante la exhalación. (Mencionado en: cap. 14)
]

/ #strong[ELT (Emergency Locator Transmitter)]: #block[
Baliza de emergencia instalada fijamente en la aeronave que se activa automáticamente por el impacto (o manualmente) y transmite en 406 MHz a la red satelital de búsqueda y rescate. (Mencionado en: cap. 14)
]

/ #strong[Energía total (Variómetro de energía total / TE)]: #block[
Variómetro compensado (mediante sonda o antena TE) que descuenta las variaciones de altura provocadas por los cambios de velocidad del propio piloto, indicando únicamente el movimiento real de la masa de aire. (Mencionado en: cap. 6)
]

/ #strong[Estructura sándwich]: #block[
Técnica constructiva con dos capas finas y rígidas de fibra separadas por un núcleo ligero de espuma o nido de abeja. Logra gran rigidez con peso mínimo, pero es vulnerable a impactos puntuales que pueden causar delaminación interna invisible desde el exterior. (Mencionado en: cap. 1)
]

/ #strong[Factor de carga (n)]: #block[
Relación entre la sustentación aerodinámica total y el peso del planeador, expresada en unidades #emph[g]. En vuelo recto y nivelado: n = 1g. En un viraje de 60° de inclinación: n = 2g. El factor de carga eleva la velocidad de pérdida en proporción a su raíz cuadrada: a 2g, sube un 41%. Deflexiones bruscas y maniobras mal coordinadas en turbulencia pueden superar los límites del diagrama V-n.~(Mencionado en: cap. 2)
]

/ #strong[FES (Front Electric Sustainer)]: #block[
Sistema de propulsión eléctrica con hélice plegable montada en el morro y baterías de litio. De arranque instantáneo y gran fiabilidad, la hélice se pliega contra el fuselaje por la presión del aire al detenerse el motor. (Mencionado en: cap. 10)
]

/ #strong[Flaps]: #block[
Superficies del borde de salida que modifican la curvatura del ala: posiciones positivas para térmica y aterrizaje, negativas para reducir resistencia en transiciones rápidas. Presentes en veleros de alta competición. (Mencionado en: cap. 5)
]

/ #strong[FLARM]: #block[
Sistema electrónico de alerta de tráfico y prevención de colisiones de corto alcance diseñado especialmente para planeadores, que transmite la posición GPS tridimensional proyectada a otras aeronaves equipadas. (Mencionado en: cap. 6)
]

/ #strong[Flutter (Flameo aeroelástico)]: #block[
Fenómeno físico de oscilaciones aeroelásticas autoexcitadas e inestables que afectan a las superficies sustentadoras o de control del planeador al superar la VNE, pudiendo destruir la estructura en segundos debido a la interacción del flujo de aire a alta velocidad con la flexibilidad estructural. (Mencionado en: cap. 2)
]

/ #strong[Gancho de remolque (Towhook)]: #block[
Mecanismo de enganche y suelta rápida del cable de lanzamiento, habitualmente del fabricante Tost. El gancho de morro se usa para remolque por avión; el gancho de CG, para torno, e incorpora suelta automática (#strong[back-release]) si el cable tira hacia atrás y abajo. (Mencionado en: cap. 1)
]

/ #strong[Gelcoat]: #block[
Capa exterior de resina de poliéster que protege la estructura de fibra contra la humedad y da el acabado liso característico. Sus enemigos son la radiación UV y los cambios bruscos de temperatura, que provocan el craqueado superficial. (Mencionado en: cap. 1)
]

/ #strong[Hipoxia]: #block[
Estado fisiológico de deficiencia de oxígeno en las células y tejidos del cuerpo humano, provocado al volar a gran altura por la reducción de la presión parcial de oxígeno en la atmósfera. (Mencionado en: cap. 14)
]

/ #strong[Larguero (Spar)]: #block[
Viga principal que recorre el ala de punta a punta y soporta las cargas de flexión en vuelo. Un daño estructural en el larguero deja el ala fuera de servicio. (Mencionado en: cap. 1)
]

/ #strong[Lastre de agua (Water ballast)]: #block[
Agua cargada en tanques específicos situados en las alas para aumentar la masa del planeador y su carga alar, desplazando la curva polar de velocidades hacia valores más altos para volar más rápido con el mismo ángulo de planeo. (Mencionado en: cap. 11)
]

/ #strong[Lastre de cola]: #block[
Pequeño depósito de agua o soporte de pesas en la deriva que compensa el desplazamiento del CG producido por el lastre de las alas o por un piloto pesado, restaurando el centrado óptimo. Olvidar vaciarlo con un piloto ligero genera un CG peligrosamente retrasado. (Mencionado en: cap. 4)
]

/ #strong[LiFePO4 (Batería de litio-ferrofosfato)]: #block[
Tecnología de batería ligera con curva de descarga plana (mantiene el voltaje hasta casi agotarse). Requiere cargadores específicos y un manejo cuidadoso para evitar incendios por cortocircuito. (Mencionado en: cap. 12)
]

/ #strong[L'Hotellier (Conector)]: #block[
Conector manual de rótula usado en las conexiones de mandos de muchos planeadores. Crítico para la seguridad: exige pin de seguridad (imperdible) además del muelle, y ha sido causa de numerosos accidentes por olvido de conexión. (Mencionado en: cap. 7)
]

/ #strong[MTOW (Masa Máxima al Despegue / Maximum Take-Off Weight)]: #block[
Masa máxima autorizada o certificada con la que el planeador puede iniciar el vuelo, determinada por límites estructurales y de rendimiento aerodinámico. (Mencionado en: cap. 4)
]

/ #strong[Part-ML]: #block[
Reglamento europeo de mantenimiento simplificado para aviación ligera (incluidos veleros). Permite al propietario declarar el programa de mantenimiento (AMP) y realizar tareas limitadas de piloto-propietario según su Apéndice II. (Mencionado en: cap. 9)
]

/ #strong[PCC (Comprobación de mandos positiva / Positive Control Check)]: #block[
Verificación obligatoria tras el montaje del planeador en la que un asistente sujeta físicamente cada superficie de mando en el exterior mientras el piloto acciona los controles en cabina para verificar la integridad y correcto sentido del movimiento. (Mencionado en: cap. 7)
]

/ #strong[PLB (Personal Locator Beacon)]: #block[
Baliza de localización personal portátil, de activación manual, que el piloto lleva consigo (bolsillo o arnés del paracaídas) y que transmite en 406 MHz a la red satelital de rescate. (Mencionado en: cap. 14)
]

/ #strong[Poliuretano (PU)]: #block[
Sistema de pintura acrílica de poliuretano que sustituye cada vez más al gelcoat de poliéster en los veleros modernos. Se aplica en capa fina (menos peso) y es más elástico, así que resiste mucho mejor el craqueado por UV y conserva el brillo más años; a cambio, deja menos margen para reparar a base de lijar y pulir. (Mencionado en: cap. 1)
]

/ #strong[Rigging (Montaje)]: #block[
Proceso de ensamblaje del planeador (fuselaje, alas y estabilizador) con la conexión de sus superficies de mando. Fase crítica de seguridad que exige método, ausencia de distracciones y verificación final con PCC. (Mencionado en: cap. 7)
]

/ #strong[SB (Boletín de Servicio / Service Bulletin)]: #block[
Comunicación del fabricante con mejoras o inspecciones recomendadas para un modelo. No siempre es legalmente obligatorio, pero ignorarlo puede afectar a la seguridad y al valor de la aeronave. (Mencionado en: cap. 9)
]

/ #strong[Sistema pitot-estática]: #block[
Conjunto de tomas de presión que alimenta los instrumentos básicos: el tubo Pitot mide la presión total (estática + dinámica) y las tomas estáticas, la presión ambiental. Su bloqueo (insectos, agua, hielo) deja al piloto sin indicación de velocidad y altura. (Mencionado en: cap. 6)
]

/ #strong[Sustentador (Turbo)]: #block[
Motor auxiliar de baja potencia, generalmente de dos tiempos y escamoteable, incapaz de despegar por sí solo pero suficiente para mantener el vuelo y regresar a la base si fallan las térmicas. (Mencionado en: cap. 10)
]

/ #strong[TMG (Motovelero de turismo / Touring Motor Glider)]: #block[
Planeador propulsado equipado estructuralmente con motor y hélice no retráctil que le permiten el despegue autónomo y el crucero, compartiendo características con aviones ligeros. (Mencionado en: cap. 10)
]

/ #strong[Transpondedor]: #block[
Equipo de a bordo que responde automáticamente a las interrogaciones del radar secundario (SSR) emitiendo un código #strong[squawk] y, según el modo, la altitud barométrica o datos extendidos de identificación. Opera en la banda UHF (1.030/1.090 MHz), independientemente de la radio de voz. Imprescindible para ser visible por el TCAS de otros tráficos. (Mencionado en: cap. 6)
]

/ #strong[Tren retráctil]: #block[
Tren de aterrizaje que se recoge dentro del fuselaje para eliminar resistencia aerodinámica, habitualmente mediante una palanca manual. Su gestión disciplinada (extensión en viento en cola, siempre) forma parte de las listas de chequeo. (Mencionado en: cap. 3)
]

/ #strong[Variómetro]: #block[
Instrumento que indica la velocidad vertical del planeador. Es la herramienta esencial del vuelo sin motor para detectar y centrar ascendencias; en su variante de energía total descuenta las maniobras del piloto. (Mencionado en: cap. 6)
]

/ #strong[VRA (Velocidad máxima en aire turbulento / Rough Air Speed)]: #block[
Velocidad máxima a la que puede volarse en aire turbulento. En la esfera del anemómetro es el límite entre el arco verde y el amarillo (CS 22.1545). No debe confundirse con la velocidad de maniobra (VA), que es un límite estructural y no se marca en la esfera; su tratamiento aerodinámico corresponde al #strong[Libro 5 --- Principios de vuelo], capítulo 5.
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



