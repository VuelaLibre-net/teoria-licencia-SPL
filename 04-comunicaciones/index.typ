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
  title: [Comunicaciones],
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

#heading(level: 1, numbering: none)[Comunicaciones]
<comunicaciones>
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
#strong[#emph[Tema 4 de 9 del examen teórico para la Licencia de Piloto de Planeador (SPL)]]

La radio paraliza a más alumnos de vuelo que la pérdida aerodinámica. No porque la física sea difícil, sino porque nadie les ha explicado el sistema: qué dice el piloto, qué responde el controlador y por qué cada elemento de esa conversación tiene una razón de seguridad detrás.

Una colación incorrecta puede significar que el controlador crea que has salido de la pista cuando todavía estás en ella. Una llamada de emergencia mal formulada puede retrasar la respuesta SAR los minutos que marcan la diferencia.

Nueve capítulos convierten el protocolo de radio en un instrumento de vuelo más: uno que, cuando lo dominas, libera toda tu atención para lo que importa.

= Definiciones y técnica de comunicación
<definiciones-y-técnica-de-comunicación>
#quote(block: true)[
En este capítulo aprenderás el lenguaje que se usa en la radio aeronáutica: qué es la colación y por qué no es opcional, cómo funciona la fraseología estándar, las reglas para decir números, horas y frecuencias, cómo manejar bien la disciplina de radio y cómo identificarte correctamente ante los servicios de tránsito aéreo.
]

== Introducción a las comunicaciones aeronáuticas
<introducción-a-las-comunicaciones-aeronáuticas>
La radio es el canal principal entre tú y los servicios de tránsito aéreo. Todo lo que ocurre en el espacio aéreo controlado pasa por ahí, en tiempo real. La regulación no es cosa de cada país: el #strong[Anexo 10 al Convenio sobre Aviación Civil Internacional] de la OACI (#emph[International Civil Aviation Organization]) fija los estándares técnicos y procedimentales que todos los Estados miembro aplican.

Las comunicaciones de voz van en la banda de VHF (#emph[Very High Frequency]), entre #strong[118 MHz y 136,975 MHz], con modulación de amplitud (AM). Las ondas VHF no doblan el horizonte: su alcance depende de la línea de visión (#emph[line of sight]), así que cuanto más alto vueles, más lejos llegas. En zonas montañosas o a baja altura puede que necesites un #strong[relay], otra estación que retransmita tu mensaje. El espaciado de canales en Europa es #strong[8,33 kHz] (la parte técnica y la normativa están en el capítulo 9).

En el vocabulario OACI, la estación en tierra es la #strong[estación aeronáutica] (#strong[aeronautical station]), identificada por el sufijo «Radio» en las llamadas. Tú, desde el planeador, operas como #strong[estación de aeronave] (#strong[aircraft station]).

#block[
#callout(
body: 
[
El #strong[Anexo 10 de la OACI] (Volumen II, Comunicaciones) es la norma de referencia internacional para las telecomunicaciones aeronáuticas. El equipo de radio debe estar homologado y calibrado según sus especificaciones antes de cualquier vuelo en espacio aéreo controlado.

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
== La colación (#emph[readback])
<la-colación-readback>
Hablar por radio con el ATC no es una conversación. Es un procedimiento, y tiene sus reglas. La más importante es la #strong[colación] (#strong[readback]): repetir al controlador sus propias palabras, exactamente como las dijo.

¿Por qué? Porque es la única forma que tiene el Controlador de Tráfico Aéreo (#emph[Air Traffic Controller], ATC) de saber que recibiste la instrucción correctamente. Si no escucha tu colación, no sabe si llegaste, si entendiste, o si captaste algo diferente.

Por normativa de la OACI (Anexo 10) y del SERA (#emph[Standardised European Rules of the Air]), es #strong[obligatorio] colacionar:

- Todas las autorizaciones y permisos (despegues, aterrizajes, cruces de pista).
- Instrucciones de rumbo, velocidad, altitud o nivel de vuelo.
- La pista en servicio (#strong[runway in use]).
- El ajuste del altímetro (#strong[QNH] o QFE). A un QNH nunca se responde con «Recibido»: repites el valor numérico, sin excepción.
- El código del transpondedor (#strong[squawk code]), cuando el ATC te asigne uno.
- Las instrucciones de cambio de frecuencia.
- Las transferencias a otras dependencias ATC.

#block[
#callout(
body: 
[
La obligación de colacionar autorizaciones e instrucciones críticas está establecida en el Anexo 10 al Convenio sobre Aviación Civil Internacional de la OACI. Las comunicaciones grabadas se conservan un mínimo de 30 días, y pueden retenerse indefinidamente si son relevantes para una investigación o reclamación. Una colación incorrecta o ausente constituye una desviación de los procedimientos estándar y puede dar lugar a incidente o accidente.

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
#block[
#callout(
body: 
[
La omisión de la colación de una autorización de despegue o aterrizaje es una de las causas más frecuentes de incursiones en pista (#strong[runway incursions]). Si el controlador no escucha la colación correcta, puede autorizar simultáneamente a otra aeronave a operar en la misma pista. Ante cualquier duda sobre una instrucción recibida, solicite confirmación inmediata antes de ejecutarla.

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
== Fraseología estándar
<fraseología-estándar>
En la radio no hay sitio para el lenguaje coloquial. Cada palabra tiene un significado exacto, y usarla mal crea ambigüedad donde no puede haberla. La #strong[fraseología estándar] existe precisamente para eso: transmitir información sin margen de error y sin bloquear la frecuencia más de lo necesario.

Los términos que tienes que conocer desde el primer día:

- #strong[Afirma]: «Sí», «El permiso ha sido concedido» o «Es correcto». Es la palabra normalizada en español por la fraseología oficial (Guía de fraseología y comunicaciones de AESA), equivalente del #strong[AFFIRM] inglés: la OACI lo acortó desde #strong[Affirmative] precisamente para que no se confundiera con #strong[Negative] cuando hay ruido en la frecuencia. En la práctica oirás también «Afirmo»; lo que hay que evitar siempre es «Afirmativo».
- #strong[Negativo]: «No», «El permiso no ha sido concedido» o «Incorrecto».
- #strong[Wilco] (#strong[Will comply]): «Entendido, actuaré en consecuencia». Lo usas cuando recibes una instrucción larga que no exige readback obligatorio.
- #strong[Solicito]: Para pedir una autorización, un servicio o información. Por ejemplo: «Solicito autorización de rodaje».
- #strong[Recibido] (#strong[Roger]): «He recibido tu transmisión». Ojo: no es una respuesta a una pregunta, y no sustituye a una colación cuando esta es obligatoria.

#block[
#callout(
body: 
[
La frecuencia de radio es un recurso compartido. Un mensaje breve, preciso y sin vacilaciones libera la frecuencia para otros tráficos y para emergencias. Planifique el mensaje antes de pulsar el PTT: quién llama, a quién, qué necesita.

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
#box(image("imagenes/04-cap01-disciplina-radio.jpg"))
], caption: figure.caption(
position: bottom, 
[
Pulsa el PTT (
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap01-microfono>


== Transmisión de números, horas y frecuencias
<transmisión-de-números-horas-y-frecuencias>
Un número mal entendido en la radio puede ser un QNH erróneo, una frecuencia equivocada o un nivel de vuelo que no es el tuyo. Las reglas de la OACI para transmitir cifras cierran esa puerta.

=== Transmisión de números
<transmisión-de-números>
Los números van #strong[dígito a dígito], sin agrupar:

- «34» «#emph[tres cuatro]» (nunca «treinta y cuatro»)
- «2576» «#emph[dos cinco siete seis]»

La excepción: centenas y miles exactos se dicen como unidades:

- «200» «#emph[dos cientos]»
- «2000» «#emph[dos mil]»
- «2600» «#emph[dos mil seiscientos]»
- «25000» «#emph[dos cinco mil]»

=== Transmisión de horas
<transmisión-de-horas>
En aviación la hora es siempre #strong[UTC] (#emph[Coordinated Universal Time]), también llamada Zulú. Si no hay riesgo de confusión, basta transmitir los minutos. Si puede haber ambigüedad, usas los cuatro dígitos:

- 09:20 «#emph[dos cero]» o «#emph[cero nueve dos cero]» si puede confundirse
- 17:55 «#emph[cinco cinco]» o «#emph[uno siete cinco cinco]»

=== Transmisión de frecuencias
<transmisión-de-frecuencias>
Dígito a dígito, con la palabra #strong[«coma»] para el decimal:

- 123.500 «#emph[uno dos tres coma cinco cero cero]»
- 124.400 «#emph[uno dos cuatro coma cuatro cero cero]»

#block[
#callout(
body: 
[
Antes de abandonar una frecuencia, colaciona siempre el nuevo valor completo. Así ambas partes confirman que el piloto ha comprendido el canal correcto antes de cambiar de dial.

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
== Disciplina de radio: piensa, escucha y luego habla
<disciplina-de-radio-piensa-escucha-y-luego-habla>
Tener buen equipo no basta. La calidad de tus comunicaciones depende sobre todo de ti. La #strong[disciplina de radio] es lo que hace que la frecuencia funcione para todos.

Cuatro pasos, siempre en este orden:

+ #strong[Piensa]: Antes de pulsar, organiza mentalmente lo que vas a decir. Anótalo si hace falta. Los mensajes llenos de «ehm…​» y pausas bloquean la frecuencia. Si ya presentaste un plan de vuelo VFR, no repitas datos que el controlador ya tiene salvo que te los pida.
+ #strong[Escucha]: Sintoniza la frecuencia y escucha unos segundos antes de transmitir. No interrumpas ni «pises» una transmisión en curso. Si hay tráfico activo, espera tu turno.
+ #strong[Pulsa y cuenta uno]: Pulsa el botón de PTT (#emph[Push-To-Talk]) un segundo #strong[antes] de hablar (#ref(<fig-04-cap01-microfono>, supplement: [Figura])). Así la primera sílaba no se corta mientras el transmisor abre la portadora.
+ #strong[Habla]: Claro, constante, sin prisas. Menos de 100 palabras por minuto, volumen uniforme. Cuando termines, suelta el PTT de inmediato.

#block[
#callout(
body: 
[
Para verificar la calidad de la señal de radio, utilice la escala normalizada del 1 (ilegible) al 5 (perfectamente legible). La prueba de radio no debe superar los 10 segundos. Si no obtiene respuesta tras la primera llamada a una torre, espere un mínimo de 10 segundos antes de reintentar, para no interferir con otras gestiones del controlador.

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
== Identificación de la aeronave
<identificación-de-la-aeronave>
Tu indicativo (#strong[callsign]) es tu nombre en el espacio aéreo. El ATC necesita saber en todo momento con quién habla. Nunca transmitas sin identificarte, y nunca uses un indicativo que no sea el tuyo.

En planeadores, el indicativo es la matrícula asignada por la autoridad de registro. Las matrículas civiles siguen el esquema OACI de prefijos nacionales: en España es #strong[EC-] seguido de tres letras, por ejemplo «EC-DPE». Alemania usa «D-», Francia «F-». Hay combinaciones prohibidas porque pueden confundirse con señales de socorro o urgencia internacionales (SOS, PAN, MAY).

Cómo identificarte:

- #strong[Primer contacto]: Matrícula completa, deletreada con el alfabeto fonético OACI. «#emph[Eco Charlie Delta Papa Eco]».
- #strong[Matrícula abreviada]: En contactos posteriores puedes usar la primera letra del prefijo nacional más las dos últimas letras de la matrícula. «#emph[Eco Papa Eco]».
- #strong[Quién abre la puerta]: Solo puedes abreviar si la dependencia ya usó la matrícula abreviada al dirigirse a ti. Hasta entonces, indicativo completo siempre.

Añade siempre tu indicativo al final de cada colación. Así el controlador confirma que la instrucción la recibió la aeronave correcta, no otra que también escuchó.

#figure([
#table(
  columns: 6,
  align: (auto,auto,auto,auto,auto,auto,),
  table.header([Letra], [Palabra], [Letra], [Palabra], [Letra], [Palabra],),
  table.hline(),
  [A], [Alfa], [J], [Juliett], [S], [Sierra],
  [B], [Bravo], [K], [Kilo], [T], [Tango],
  [C], [Charlie], [L], [Lima], [U], [Uniform],
  [D], [Delta], [M], [Mike], [V], [Victor],
  [E], [Eco], [N], [November], [W], [Whiskey],
  [F], [Foxtrot], [O], [Oscar], [X], [X-ray],
  [G], [Golf], [P], [Papa], [Y], [Yankee],
  [H], [Hotel], [Q], [Quebec], [Z], [Zulu],
  [I], [India], [R], [Romeo], [], [],
)
], caption: figure.caption(
position: top, 
[
Alfabeto fonético OACI
]), 
kind: "quarto-float-tbl", 
supplement: "Tabla", 
)
<tbl-tabla-alfabeto-fonetico>


#table(
  columns: (16.67%, 16.67%, 16.67%, 16.67%, 16.67%, 16.67%),
  align: (auto,auto,auto,auto,auto,auto,),
  table.header([Dígito], [Pronunciación], [Dígito], [Pronunciación], [Dígito], [Pronunciación],),
  table.hline(),
  [0 (#emph[Zero])], [Cero], [4 (#emph[Four])], [Cuatro], [8 (#emph[Eight])], [Ocho],
  [1 (#emph[One])], [Uno], [5 (#emph[Five])], [Cinco], [9 (#emph[Niner])], [Nueve (\*)],
  [2 (#emph[Two])], [Dos], [6 (#emph[Six])], [Seis], [], [],
  [3 (#emph[Three])], [Tres], [7 (#emph[Seven])], [Siete], [], [],
)
#block[
#callout(
body: 
[
\(\*) En frecuencias internacionales, el dígito 9 se pronuncia #strong[«Niner»] para evitar confusiones con «Nein» (no, en alemán). El alfabeto fonético OACI está diseñado para ser reconocible en cualquier idioma y en condiciones de radio degradadas. Memorícelo hasta que el deletreo sea automático.

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
#strong[Resumen del capítulo: Definiciones y técnica]

- #strong[Introducción]: Las comunicaciones aeronáuticas de voz se realizan en VHF (118--136,975 MHz), reguladas por el Anexo 10 de la OACI. El espaciado de canales en Europa es de 8,33 kHz (Reglamento UE 1079/2012). La estación en tierra es la «estación aeronáutica»; el piloto opera desde la «estación de aeronave».
- #strong[La colación (readback)]: Repetir textualmente las instrucciones del ATC es obligatorio para: autorizaciones, rumbos/altitudes, pista en uso, QNH, cambios de frecuencia, transferencias ATC y código de transpondedor cuando sea asignado.
- #strong[Fraseología estándar]: La radio no admite lenguaje coloquial. Términos clave: #strong[Afirma], #strong[Negativo], #strong[Wilco], #strong[Solicito], #strong[Recibido]. «Recibido» nunca sustituye a una colación obligatoria, y «Afirmativo» se evita siempre.
- #strong[Disciplina de radio]: Piensa → Escucha → Pulsa y cuenta uno → Habla. Menos de 100 palabras por minuto, mensaje preparado antes de pulsar el PTT.
- #strong[Transmisión de números, horas y frecuencias]: Números dígito a dígito («#emph[tres cuatro]», nunca «treinta y cuatro»); centenas y miles exactos como unidades («#emph[dos mil seiscientos]»). Horas en UTC, normalmente solo los minutos. Frecuencias con «coma»: «#emph[uno dos cuatro coma cuatro cero]». Colaciona siempre el nuevo canal antes de cambiar.
- #strong[Identificación]: La matrícula es el nombre de la aeronave. Primer contacto: matrícula completa en fonético. Matrícula abreviada: solo cuando la torre la use primero.

]
= Comunicaciones VFR en aeródromos no controlados
<comunicaciones-vfr-en-aeródromos-no-controlados>
#quote(block: true)[
La mayoría de los vuelos de planeador salen de campos sin torre. Aquí verás cómo mantenerte situado mediante la autoinformación, por qué tus ojos siempre van antes que la radio, cómo sacarle partido a la escucha activa y qué cantas en cada punto del circuito.
]

== Autoinformación en aeródromos sin torre de control
<autoinformación-en-aeródromos-sin-torre-de-control>
#emph[En el campo sin torre, el piloto actúa como su propio controlador.]

La mayoría de los aeródromos desde los que vuelan los planeadores ---aeroclubs, pistas forestales, aeródromos privados--- son #strong[aeródromos no controlados]. Operan en espacio aéreo Clase G y no hay ninguna torre de Control de Tráfico Aéreo (ATC) que te autorice, te separe o te asigne rumbos.

Aquí la seguridad la pone la #strong[autoinformación] (#strong[broadcast]): tú transmites tu posición, altitud e intenciones a la frecuencia del campo para que todos sepan dónde estás. Nadie te va a dar permiso para despegar ni aterrizar. Informas y tú decides.

Dos cosas básicas:

- #strong[A quién llamas]: Al nombre del aeródromo, no a «Torre». #emph[«Fuentemilanos, buenos días…​»] o #emph[«Santa Cilia, tráfico…​»]
- #strong[Qué dices]: Indicativo, posición, altitud e intención. #emph[«…​velero Eco Papa Eco, a 5 minutos al este del campo a 1.500 metros, notificaré entrando al circuito.»]

#block[
#callout(
body: 
[
Aunque en algunos campos exista un operador de radio prestando un servicio AFIS (#strong[Aerodrome Flight Information Service]), este operador #strong[no proporciona control], solo información (viento, pista en uso, meteorología). La decisión final y la responsabilidad de la separación siguen siendo íntegramente del piloto al mando.

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
== Ver y evitar (#emph[See and Avoid])
<ver-y-evitar-see-and-avoid>
La radio te ayuda a saber dónde buscar. Nada más. El vuelo VFR (#strong[Visual Flight Rules]) se llama así por algo: la responsabilidad de ver y esquivar es tuya, siempre, y #strong[nunca la delega en la radio].

Tres cosas que no puedes olvidar:

+ #strong[No asumas que todos tienen radio]: En muchos campos pequeños operan ultraligeros, parapentes y aeronaves sin radio a bordo, o con la radio apagada.
+ #strong[No asumas que te han escuchado]: Un piloto puede estar distraído, en otra frecuencia, o con el equipo fallando.
+ #strong[Tus ojos mandan]: La radio te dice dónde #strong[buscar], pero mantén el barrido visual (#strong[scanning]) activo antes de cualquier maniobra, especialmente al incorporarte al circuito.

#block[
#callout(
body: 
[
Un error fatal es iniciar un viraje (por ejemplo, de tramo base a final) confiando únicamente en que "nadie ha cantado posición por la radio". Asegúrate siempre visualmente de que la pista y la aproximación final están libres de tráfico antes de virar.

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
#box(image("imagenes/04-cap02-frecuencia-correcta.jpg"))
], caption: figure.caption(
position: bottom, 
[
Escucha activa de la frecuencia antes de la llegada
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap02-escucha-previa>


== La frecuencia correcta y el momento adecuado
<la-frecuencia-correcta-y-el-momento-adecuado>
Al aproximarte a cualquier aeródromo, controlado o no, sintoniza la frecuencia del campo #strong[al menos 10 minutos o 10 millas antes] de llegar. Y luego escucha antes de abrir la boca.

Con solo escuchar unos minutos puedes deducir (#ref(<fig-04-cap02-escucha-previa>, supplement: [Figura])):

- #strong[Pista en servicio]: Las notificaciones de otros tráficos te lo dicen sin preguntar.
- #strong[Viento]: Otros pilotos suelen comentarlo en base o en final.
- #strong[Densidad de tráfico]: Sabrás cuántos aviones hay en el circuito, si hay remolcadores activos o veleros termando cerca.

Cuando ya tienes esa imagen mental, pulsa el PTT. Tu primera llamada llegará con datos concretos, sin que nadie tenga que repetirte lo que ya podías haber escuchado.

== El circuito estándar y sus notificaciones
<el-circuito-estándar-y-sus-notificaciones>
El #strong[circuito de tránsito] (#strong[traffic pattern]) es el patrón rectangular que organiza el tráfico alrededor del aeródromo. Sin él, cada piloto llegaría como le pareciera.

Salvo que la carta de aproximación visual (#emph[VAC]) del aeródromo indique otra cosa, por obstáculos o restricciones de ruido, el circuito estándar ICAO/EASA #strong[es siempre a izquierdas]. El motivo es práctico: en aviones convencionales el comandante se sienta a la izquierda, y en planeadores en tándem la visibilidad hacia ese lado suele ser mejor. Con el circuito a izquierdas, la pista queda siempre a la vista.

Las notificaciones que haces durante el circuito son estas:

+ #strong[Entrada al circuito]: Avisa antes de entrar a las inmediaciones. #emph["Fuentemilanos, Eco Papa Eco, a tres minutos, notificaré entrando en circuito"].
+ #strong[Viento en cola] (#strong[Downwind]): El tramo paralelo a la pista pero en sentido contrario al aterrizaje. A la altura de los números de pista o a mitad del tramo, cantas: #emph["Fuentemilanos, Eco Papa Eco, viento en cola pista 16"]. En planeador, esta notificación tiene que hacerse desde una posición que te garantice llegar a la pista planeando.
+ #strong[Tramo base] (#strong[Base leg]): El tramo perpendicular a la línea central, donde configuras el planeador para el aterrizaje. #emph["Fuentemilanos, Eco Papa Eco, virando a base 16"].
+ #strong[Final] (#strong[Final approach]): Alineado con la pista, tras el último viraje. #emph["Fuentemilanos, Eco Papa Eco, en final 16"].
+ #strong[Pista libre] (#strong[Runway vacated]): Ya en tierra y fuera de la pista activa. #emph["Fuentemilanos, Eco Papa Eco, pista 16 libre"].

#block[
#callout(
body: 
[
En campos con mucha actividad de vuelo a vela, el circuito de planeadores puede discurrir por un lado de la pista y el de aviones con motor (incluidos los remolcadores) por el contrario. Consulta siempre la carta del aeródromo antes del vuelo.

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
Según el Reglamento SERA (artículo SERA.3210), el orden de prioridad de paso ---de mayor a menor--- es: globos \> planeadores \> dirigibles \> aeronaves con motor. El planeador tiene prioridad sobre todo aerodino propulsado por motor y #strong[cede el paso a los globos]. Esta prioridad aplica en vuelo y en las inmediaciones del aeródromo; nunca justifica descuidar la vigilancia visual activa.

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
#block[
#callout(
body: 
[
SERA no incluye a parapentes y alas delta en esa jerarquía con esa literalidad, pero el criterio operativo prudente es tratarlos como a un planeador y, además, cederles el paso: maniobran bastante peor que tú y descienden sin poder remontar. Ante la duda, sepárate.

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
== Coordinación con el remolcador y el torno
<coordinación-con-el-remolcador-y-el-torno>
El lanzamiento no tiene equivalente en ningún otro tipo de aviación: tu despegue depende de coordinar con alguien que está fuera de la aeronave. Hacerlo bien marca la diferencia.

=== Lanzamiento con torno (#emph[winch launch])
<lanzamiento-con-torno-winch-launch>
Si el campo tiene radio tierra-aire con el torno, la secuencia es:

+ Cúpula cerrada, aeronave lista. Transmites:

#emph[«Torno, velero EC-DPE, doble mando, listo para tensar.»] 2. El operador tensa suavemente. Aerofrenos replegados, alas niveladas, confirmas:

#emph[«Remolcando, remolcando, remolcando.»] --- El torno aplica potencia a fondo. 3. Al soltar el cable: #emph[«Velero libre, Eco Papa Eco.»] 4. Si algo va mal: #emph[«Stop torno, stop torno, stop torno.»]

Sin radio tierra-aire, el ayudante de ala (#strong[wing runner]) coordina con señales visuales:

#table(
  columns: 2,
  align: (auto,auto,),
  table.header([Señal], [Significado],),
  table.hline(),
  [Ala en tierra (no nivelada)], [Planeador no listo --- no tensar],
  [Alas niveladas + aerofrenos fuera], [Tensar cable suavemente],
  [Alas niveladas + aerofrenos replegados], [Cable tenso OK --- lanzar],
)
#block[
#callout(
body: 
[
Si el cable se rompe o el torno falla, baja el morro de inmediato para recuperar velocidad. A baja altura ---por debajo de unos #strong[150 m AGL] en torno--- no vires: aterriza recto al frente en el terreno disponible. Intentar regresar a la pista de origen a baja altura es la causa más frecuente de accidentes mortales en lanzamiento con torno. Las franjas de decisión completas por altura (recto al frente, circuito abreviado o circuito normal) se desarrollan en el #strong[Libro 6 --- Procedimientos operativos], capítulo 7.

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
=== Lanzamiento con remolcador (#emph[aerotow])
<lanzamiento-con-remolcador-aerotow>
La fraseología varía según el aeródromo; consulta siempre las instrucciones locales. Una secuencia habitual:

#emph[--- Piloto planeador: «Remolcadora Delta Victor Yankee, planeador Eco Papa Eco, doble mando, listo tensando.»]

#emph[--- Remolcador: «Eco Papa Eco, tensando.»]

#emph[--- Piloto planeador: «Remolcando.»]

Al soltar: #emph[--- «Remolcadora Delta Victor Yankee, velero libre.»]

Si el planeador #strong[no puede largar el cable], la señal de socorro en vuelo es: alabear fuertemente y situarse bajo y a la izquierda del remolcador, para que este pueda largarlo desde su extremo.

#block[
#callout(
body: 
[
Antes de subir al planeador, acuerda siempre con el piloto remolcador la altitud de suelta y la dirección de alejamiento. Así el remolcador puede regresar a la pista sin cruzarse con el velero que inicia su vuelo.

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
#strong[Resumen del Capítulo: Aeródromos No Controlados]

- #strong[Autoinformación]: En el campo sin torre, tú eres el controlador. Transmite «al aire» tu posición e intenciones. «Fuentemilanos, velero EC-BRT, viento en cola pista 34».
- #strong[Ver y Evitar]: La radio ayuda, pero tus ojos mandan. No asumas que todos tienen radio o te han escuchado. Busca activamente otros tráficos.
- #strong[La Frecuencia Correcta]: Sintoniza la frecuencia del campo 10 minutos antes. Escuchar a otros te dirá pista en uso, viento y densidad de tráfico.
- #strong[Circuito Estándar]: Si nadie indica lo contrario, el circuito es a izquierdas. Notifica: entrada, viento en cola, base y final.
- #strong[Lanzamiento (torno/remolcador)]: Con torno: «Listo tensando» → «Remolcando x3» → «Cable libre». Abortar: «Stop torno x3». Fallo bajo (por debajo de 150 m en torno): recto al frente, nunca regreses virando.

]
= Comunicaciones VFR en aeródromos controlados
<comunicaciones-vfr-en-aeródromos-controlados>
#quote(block: true)[
En un aeródromo controlado no te mueves sin que la Torre te lo diga. Aquí verás cómo funciona el sistema de autorizaciones, para qué sirve el plan de vuelo VFR, qué son los puntos de notificación visual y por qué en espacio controlado colacionas absolutamente todo.
]

== Autorización (#emph[Clearance]) en espacio controlado
<autorización-clearance-en-espacio-controlado>
Un #strong[aeródromo controlado] tiene Torre de Control (TWR), y eso cambia las reglas por completo: aquí no das un paso sin autorización explícita.

En espacio aéreo controlado como un CTR, solo el controlador puede emitir instrucciones y separar el tráfico. Tú necesitas una #strong[autorización] (#strong[clearance]) para cada fase:

- Puesta en marcha (si aplica a motoveleros).
- Rodaje (#strong[taxi]) por las calles de rodadura hacia la pista.
- Entrar y alinear en la pista activa.
- Despegue.
- Entrada, vuelo o cruce en la zona de tránsito de aeródromo (CTR).
- Aterrizaje.

#block[
#callout(
body: 
[
Una autorización para "entrar y alinear" o "entrar y mantener" en la pista activa #strong[nunca] es una autorización para despegar. Debes esperar inmóvil en la cabecera hasta escuchar explícitamente las palabras: #emph["Autorizado a despegar"] (#strong[Cleared for take-off]). Si tienes alguna duda, pregunta: "Confirme autorizado a despegar".

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
== El plan de vuelo (FPL)
<el-plan-de-vuelo-fpl>
Para entrar en espacio aéreo donde se te presta servicio de control ---clases B, C y D, o cualquier aeródromo controlado--- tienes que presentar un #strong[Plan de Vuelo (FPL)] ante los servicios ATS correspondientes, con la antelación respecto a la hora estimada de salida (EOBT) que fijan el AIP-España y la VAC del aeródromo. La clase E es la excepción dentro del espacio controlado: al VFR no se le presta allí servicio de control, así que no necesita plan de vuelo, ni radio, ni autorización (SERA.4001 b)).

El planeador vuela casi siempre en Clase G. Pero si necesitas cruzar un CTR o entrar donde te controlen, presenta el FPL con tiempo. Los plazos y formatos están en el AIP-España (ENR 1.10) y son vinculantes, así que consúltalos antes de cada vuelo que implique espacio controlado.

#block[
#callout(
body: 
[
Si surge la necesidad imprevista de entrar en espacio controlado sin plan de vuelo previo, es posible abrirlo en el aire (AFIL --- Airborne Flight Plan) contactando por radio a la dependencia ATC y facilitando tipo de aeronave, posición, intenciones y tiempos estimados. Esta opción depende de la disponibilidad del servicio y de la carga de trabajo del controlador.

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
Los plazos exactos de presentación del plan de vuelo están especificados en el #strong[AIP-España ENR 1.10] y pueden variar según el tipo de operación y la dependencia ATC. Consúltalo antes de cada vuelo que implique espacio controlado; el incumplimiento puede resultar en la denegación de la autorización.

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
#figure([
#box(image("imagenes/04-cap03-puntos-notificacion.jpg"))
], caption: figure.caption(
position: bottom, 
[
Puntos de notificación visual (VFR) en un CTR
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap03-puntos-notificacion>


== Puntos de notificación visual
<puntos-de-notificación-visual>
El CTR (#emph[Control Zone]) protege las llegadas y salidas IFR. No lo confundas con la ATZ (#emph[Aerodrome Traffic Zone]), que es un espacio aéreo distinto y más pequeño. Para no meterte en medio del tráfico IFR, el vuelo VFR entra y sale del CTR por rutas y puntos fijos (#ref(<fig-04-cap03-puntos-notificacion>, supplement: [Figura])).

Esos son los #strong[puntos de notificación visual]: referencias físicas en el terreno ---un pueblo, un cruce de autopista, un lago--- por las que pasas y desde las que llamas a la Torre. Los encontrarás en la Carta de Aproximación Visual (VAC) del aeródromo, normalmente nombrados con letras fonéticas según su orientación geográfica: Noviembre para el norte, Sierra para el sur, Eco para el este.

Llama a la Torre entre 3 y 5 minutos antes de llegar al punto de entrada al CTR:

#emph[---"Jerez Torre, EC-DPE, sobre punto Sierra a 1000 pies, para entrar en zona y aterrizar."] #emph[---"EC-DPE, recibido, autorizado a entrar en zona por punto Sierra a 1000 pies o inferior, notifique viento en cola derecha pista 02."]

Desde ese momento sigues las instrucciones de la Torre en altitud y ruta. Nada de improvisar.

== Colacionar todo en espacio controlado
<colacionar-todo-en-espacio-controlado>
Ya lo vimos en el capítulo 1: la #strong[colación] (#strong[readback]) no es opcional. En espacio controlado lo es todavía menos, porque el controlador separa el tráfico basándose en que tú vas a hacer exactamente lo que has repetido.

Cualquier instrucción del ATC que afecte a tu trayectoria, pista activa, ajuste de presión o identificación de radar #strong[la colacionas] palabra por palabra, y cierras con tu indicativo.

Si la Torre dice: #emph["Eco Papa Eco, autorizado a aterrizar pista 36."]

Tu colación es: #emph["Autorizado a aterrizar pista 36, Eco Papa Eco."] El viento no hace falta colacionarlo, pero la autorización de pista sí.

#block[
#callout(
body: 
[
Cuando anotes mentalmente o en tu pernera la instrucción dada por un controlador, si se compone de autorización de pista de aterrizaje o despegue, rumbo o altitud a mantener, QNH, o el código del transpondedor, tu respuesta por radio #strong[NO puede ser "Wilco"] o #strong["Copiado"]. Debes recitar esos parámetros tal y como te los han dado.

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
== Ejercicios de fraseología
<ejercicios-de-fraseología>
En comunicaciones, la teoría no basta: hay que practicar la voz. Completa estas transmisiones antes de mirar la solución; imagina que eres el planeador #strong[EC-EPE] («Eco Papa Eco»).

#strong[Ejercicio 1 --- Colación de autorización.]

La Torre te dice: #emph[«Eco Papa Eco, ruede al punto de espera pista 30, QNH 1019, notifique listo.»] ¿Cuál es tu colación correcta?

#strong[Solución.] #emph[«Al punto de espera pista 30, QNH 1019, notificaré listo, Eco Papa Eco.»] Se colacionan la instrucción de rodaje, la pista y el QNH; el indicativo cierra la transmisión. Un simple «Recibido» aquí sería una desviación del procedimiento.

#strong[Ejercicio 2 --- Primer contacto en un CTR.]

Vas a entrar en el CTR de un aeródromo controlado desde el punto visual November. Ordena y completa tu llamada inicial con estos elementos: intenciones, indicativo, posición y altitud, y a quién llamas.

#strong[Solución.] El orden es #strong[a quién → quién soy → dónde estoy → qué quiero]: #emph[«Torre de \[aeródromo\], Eco Papa Eco, planeador, sobre November, 900 metros QNH, solicito entrada al CTR para tránsito hacia el sur.»] Espera su autorización antes de penetrar en el CTR: en espacio controlado se entra con clearance, no por iniciativa propia.

#strong[Ejercicio 3 --- «Alinear ≠ despegar».]

La Torre transmite: #emph[«Eco Papa Eco, entre y mantenga posición pista 30.»] ¿Puedes iniciar el despegue? ¿Qué colacionas?

#strong[Solución.] No.~«Entre y mantenga posición» (#strong[line up and wait]) te autoriza a ocupar la pista, pero #strong[no] a despegar; para eso hace falta un «autorizado a despegar» explícito. Colación: #emph[«Entro y mantengo posición pista 30, Eco Papa Eco.»]

#postit[
#strong[Resumen del Capítulo: Aeródromos Controlados]

- #strong[Autorización (Clearance)]: En espacio controlado, la palabra de la Torre es ley. Necesitas autorización explícita para todo: arrancar, rodar, despegar, entrar en zona. Si no oyes «autorizado», no te muevas.
- #strong[Plan de Vuelo (FPL)]: Tu billete de entrada. Preséntalo con al menos 60 minutos de antelación; los plazos exactos, en el AIP-España ENR 1.10.
- #strong[Puntos de Notificación]: Son las puertas de entrada/salida visual al CTR (Sierra, Norte, Eco…​). Conócelos bien en la carta VAC y notifica sobre ellos con precisión.
- #strong[Colacionar Todo]: En controlado es vital. Repite cada instrucción, sin el viento y con tu indicativo al final. «Autorizado a aterrizar pista 36, Eco Papa Eco».

]
= Comunicaciones VFR con ATC (en ruta)
<comunicaciones-vfr-con-atc-en-ruta>
#quote(block: true)[
En cuanto sales del circuito y te metes en ruta, las reglas cambian un poco. Aquí verás cómo usar el Servicio de Información de Vuelo (FIS), cómo cambiar de frecuencia sin desaparecer del radar y qué hacer con el transpondedor y las zonas de radio obligatoria.
]

== Servicio de Información de Vuelo (FIS)
<servicio-de-información-de-vuelo-fis>
En ruta por espacio aéreo no controlado ---Clase G en su mayor parte--- no hay ninguna Torre mirándote. Pero tienes una herramienta útil: el #strong[Servicio de Información de Vuelo (FIS)] (#emph[Flight Information Service]).

Lo más importante que tienes que saber sobre el FIS: te da #strong[asesoramiento, no control]. No te va a dar rumbos obligatorios ni altitudes que tengas que seguir. Su trabajo es darte información para que tú, como piloto al mando, decidas. La separación sigue siendo tuya.

Lo que puedes pedirle o recibir:

- #strong[Información de tráfico]: Te avisarán de aeronaves conocidas cerca de tu posición o ruta. (En Estados Unidos a esto lo llaman #strong[Flight Following]\; en Europa bajo SERA/EASA es oficialmente el FIS).
- #strong[Meteorología]: METAR, TAF, alertas SIGMET o AIRMET en ruta o en tus aeródromos de destino y alternativo.
- #strong[Estado de espacios aéreos]: Zonas restringidas, peligrosas o militares activadas o desactivadas.

Para contactar, sintoniza la frecuencia de "Información" de tu zona (#strong[Madrid Información], #strong[Zaragoza Información]…) e identifícate con tu indicativo, tipo de aeronave, posición, ruta y lo que necesitas:

#emph["Madrid Información, velero EC-DPE, sobre la sierra de Ayllón a 2000 metros, rumbo sur hacia Fuentemilanos, solicito información de tráfico."]

#block[
#callout(
body: 
[
En travesías de vuelo a vela (#strong[cross-country]), mantener la escucha en la frecuencia del FIS regional correspondiente proporciona una capa adicional de seguridad, especialmente en días con desarrollo tormentoso donde la información meteorológica en tiempo real es crítica. Además, estar en contacto con el FIS acelera la activación de los servicios de Búsqueda y Salvamento (SAR) ante una toma en campo fuera de aeródromo.

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
== Cambio y abandono de frecuencia
<cambio-y-abandono-de-frecuencia>
No desaparezcas de una frecuencia sin decir nada. El controlador de Torre, Aproximación o Información te tiene en pantalla o en su ficha de vuelo, y da por hecho que sigues a la escucha. Si te esfumas, empieza a preocuparse.

Cuando necesites cambiar de frecuencia, hay dos casos (#ref(<fig-04-cap04-cambio-frecuencia>, supplement: [Figura])):

- #strong[Si estás bajo control ATC]: Pide permiso. #emph["Torre, EC-DPE, solicito abandonar frecuencia para pasar a operaciones de club en 123.500"].
- #strong[Si estás en frecuencia de Información (FIS)]: No es control, así que solo avisas. #emph["Madrid Información, EC-DPE, abandonamos su frecuencia para pasar con Fuentemilanos 123.500. Buen día"].

#figure([
#box(image("imagenes/04-cap04-cambio-frecuencia.jpg"))
], caption: figure.caption(
position: bottom, 
[
Transición ordenada entre dependencias y frecuencias
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap04-cambio-frecuencia>


== El transpondedor en ruta: código #emph[squawk]
<el-transpondedor-en-ruta-código-squawk>
Si tu planeador tiene #strong[transpondedor], emite un código de cuatro dígitos () que el ATC usa para identificarte en pantalla. En VFR, el código por defecto es #strong[7000], salvo que el ATC te asigne uno distinto. Los códigos de emergencia los encontrarás en el capítulo 9.

#block[
#callout(
body: 
[
Los códigos 7600 (fallo de radio) y 7700 (emergencia) activan alertas inmediatas en todos los centros de control. Selecciónelos únicamente ante la situación real que corresponda y extreme la precaución al cambiar de código para no activarlos accidentalmente.

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
== Zonas de radio obligatoria (RMZ)
<zonas-de-radio-obligatoria-rmz>
Algunos sectores de clase E, F o G llevan una obligación adicional: son #strong[Zonas de Radio Obligatoria (RMZ)] (#emph[Radio Mandatory Zone]). Dentro de una RMZ la radio no es optativa aunque el espacio aéreo no sea controlado; es una obligación publicada en el AIP.

Antes de entrar y mientras estés dentro tienes que:

+ Escuchar permanentemente la frecuencia designada para esa RMZ.
+ Establecer contacto bidireccional con la dependencia ATS correspondiente antes de entrar.
+ Seguir las instrucciones o recomendaciones del servicio prestado.

Las RMZ activas en España aparecen en la carta #strong[ENR 6.12]. Revísala en la planificación prevuelo, sobre todo en travesías que pasen cerca de grandes aeropuertos en espacio no controlado.

#block[
#callout(
body: 
[
Las RMZ están reguladas por el Reglamento SERA y permiten al Estado miembro establecer requisitos de radio en espacio aéreo donde el servicio de control no es obligatorio. Sus límites y condiciones aparecen referenciados en la #strong[carta ENR 6.12] (carta de zonas de radio obligatoria).

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
#postit[
#strong[Resumen del Capítulo: Comunicaciones en Ruta]

- #strong[Servicio de Información de Vuelo (FIS)]: Es un servicio de asesoramiento, no de control. Te informan sobre tráficos y meteorología (si tienen carga de trabajo), pero la separación sigue siendo tu responsabilidad. "Para información, contacto con Madrid Información…​".
- #strong[Cambio de Frecuencia]: Nunca te "esfumes" de una frecuencia controlada o de información. Solicita el cambio o avisa de que abandonas la frecuencia. "Madrid, EC-DPE para pasar a frecuencia de club 123.500".
- #strong[Transpondedor en ruta]: Si dispones de transpondedor, código VFR por defecto: #strong[7000]. Emergencias: #strong[7700] (emergencia activa --- #strong[Mayday]) y #strong[7600] (fallo de radio --- ver cap. 7). Solo usar ante la emergencia real.

]
= Procedimientos operativos generales
<procedimientos-operativos-generales>
#quote(block: true)[
Aquí están los procedimientos que usarás en cada vuelo: cómo estructurar una llamada, cuándo pedir una prueba de radio, cómo hacer un reporte de posición, qué hacer cuando dos aeronaves transmiten a la vez, el PTT atascado, la prioridad de los mensajes de emergencia, cómo usar bien el micrófono y qué tipos de radio existen.
]

== Esquema de las comunicaciones
<esquema-de-las-comunicaciones>
Toda transmisión aeronáutica sigue el mismo patrón. Memorizarlo como secuencia fija te libera para concentrarte en volar.

La llamada inicial va siempre en este orden:

+ #strong[A quién se llama]: nombre de la dependencia («Jerez Torre», «Madrid Información»).
+ #strong[Quién llama]: indicativo completo de la aeronave («Eco Charlie Delta Papa Eco»).
+ #strong[Dónde está]: posición o fase del vuelo («sobre punto Sierra», «en viento en cola pista tres cuatro»).
+ #strong[Qué necesita]: solicitud o intención («solicito datos», «listo para el despegue»).

#emph[Ejemplo de primera llamada en aeródromo controlado:] #emph[--- «Sabadell Torre, Delta Kilo India Alfa Victor, en punto de espera pista uno dos, listo para salida.»]

El controlador responde. A partir del segundo intercambio puedes abreviar el indicativo a las tres últimas letras, pero solo si la dependencia lo ha iniciado primero.

Al #strong[colacionar] una instrucción, el indicativo va al final:

#emph[--- «Autorizado despegar pista uno dos, viento cero nueve cero grados seis nudos, Alfa Victor.»]

En #strong[autoinformación] (aeródromo no controlado), sin interlocutor designado, el indicativo va al principio:

#emph[--- «Eco Charlie Delta Papa Eco, en viento en cola derecha pista tres cuatro, intención aterrizaje.»]

#block[
#callout(
body: 
[
Antes de pulsar el PTT compón mentalmente el mensaje completo: #emph[¿A quién? → ¿Quién soy? → ¿Dónde estoy? → ¿Qué necesito?] Un mensaje estructurado ocupa menos tiempo en frecuencia y reduce los errores de comprensión del controlador.

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
Algunos instructores recomiendan abrir la #strong[primera] comunicación con una estación con un simple #emph[«buenos días»] o #emph[«buenas tardes»] antes del mensaje: #emph[«Fuentemilanos tráfico, buenos días, Eco Charlie Delta Papa Eco…»]. No forma parte de la fraseología OACI ---que busca economía de palabras--- y por eso se reservaría al #strong[primer contacto], no a cada transmisión; pero al otro lado de la radio hay una persona, y ese saludo engrasa la relación con la torre, el FIS o el resto de tráficos de tu campo. Con una salvedad: en frecuencia saturada o en una emergencia, la cortesía sobra y vas directo al grano.

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
== Prueba de radio (#emph[radio check])
<prueba-de-radio-radio-check>
Si tienes dudas sobre tu equipo de radio, puedes pedir una #strong[prueba de radio] a la torre o dependencia de información más cercana.

Ojo: si acabas de hablar con la torre y te han respondido con normalidad, no pidas un #strong[radio check] por sistema. Úsalo solo cuando tengas una razón real para dudar de tu equipo.

La calidad de la recepción se evalúa con una escala de legibilidad del 1 al 5:

- #strong[1:] Ilegible (audio incomprensible o portadora pura).
- #strong[2:] Legible de vez en cuando (muy entrecortado).
- #strong[3:] Legible con dificultad (ruido de fondo muy alto, pero se entiende).
- #strong[4:] Legible (buena calidad, leve ruido).
- #strong[5:] Perfectamente legible (audio nítido, sin ruidos).

#strong[Ejemplo de comunicación:] #emph[---"Fuentemilanos, buenas tardes, Eco Charlie Delta Papa Eco, solicito prueba de radio en 123.400."] #emph[---"Eco Papa Eco, le recibo 5."] #emph[---"Cinco, gracias, Eco Papa Eco."]

La prueba no debe durar más de 10 segundos. Normalmente basta con pronunciar los números lenta y claramente.

== Reportes de posición
<reportes-de-posición>
Un reporte de posición (#strong[position report]) le dice al ATC o a otras aeronaves dónde estás. Lo emites al pasar por puntos de notificación obligatoria, cuando el FIS te lo pide o como actualización espontánea en travesía.

La estructura mínima tiene tres elementos:

+ #strong[Identificativo] de la aeronave.
+ #strong[Posición]: punto de notificación, localidad o referencia geográfica reconocible.
+ #strong[Altitud o nivel de vuelo] con referencia altimétrica (QNH o FL).

Si el FIS o el ATC lo requieren, añades:

+ #strong[Hora UTC] de paso por el punto.
+ #strong[Siguiente punto de notificación] y hora estimada de llegada.

#emph[Ejemplo en campo no controlado (autoinformación):] #emph[--- «Buitrago, velero Eco Charlie Delta Papa Eco, sobre el embalse de Riosequillo, mil quinientos pies QNH, estimado Buitrago en cero cinco.»]

#emph[Ejemplo con FIS en travesía:] #emph[--- «Madrid Información, Eco Charlie Delta Papa Eco, sobre Somosierra, nivel de vuelo cero ocho cero, estimado Aranda en tres cinco.»]

#block[
#callout(
body: 
[
En travesías en planeador, actualiza tu posición al FIS siempre que te apartes significativamente de tu ruta prevista o cambies de sector. Un FIS informado puede coordinar con mayor rapidez una búsqueda si dejases de contactar.

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
== Llamadas simultáneas y espera en frecuencia
<llamadas-simultáneas-y-espera-en-frecuencia>
Cuando dos aeronaves transmiten a la vez, las señales se superponen y lo que llega al otro lado es audio distorsionado o ininteligible. Eso es el #strong[bloqueo mutuo].

Si ocurre, el controlador puede responder: #emph[«Estación llamando a \[dependencia\], identifíquese»], o repetir el único fragmento que logró descifrar. En ese caso:

- Escucha si tu indicativo fue mencionado.
- Espera a que la frecuencia quede libre.
- Retransmite tu mensaje completo.

Si no obtienes respuesta, espera #strong[al menos 10 segundos] antes de volver a intentarlo. Reintentar antes puede pisar a otra aeronave que esté recibiendo instrucciones.

#block[
#callout(
body: 
[
Antes de pulsar el PTT escucha siempre la frecuencia unos segundos. Una transmisión que «pisa» a otra bloquea ambas comunicaciones. Si la frecuencia está activa, espera a que la conversación concluya antes de empezar la tuya.

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
== El micrófono bloqueado (PTT atascado)
<el-micrófono-bloqueado-ptt-atascado>
Es un problema más habitual de lo que parece, y más serio de lo que parece: el #strong[micrófono bloqueado] o PTT atascado. En los planeadores el botón PTT suele estar integrado en la palanca de mando, justo donde cualquier presión accidental puede activarlo.

Si el botón se queda mecánicamente pulsado ---fallo del muelle, el cable del auricular tirando de él, o la pierna apoyada sobre un PTT portátil--- tu radio entra en #strong[transmisión continua] y emite portadora sin parar.

Las consecuencias son graves:

+ #strong[Bloqueo total]: Mientras emites, #strong[nadie más puede hablar ni recibir en esa frecuencia] en decenas o cientos de kilómetros, según tu altitud. Estás cortando las comunicaciones del ATC y las de emergencia de otros.
+ #strong[Sordera autoinducida]: Tu radio está transmitiendo, así que no recibes nada. Tú tampoco te enteras de lo que pasa en la frecuencia.

El remedio es simple: #strong[comprobación visual después de cada transmisión] (#ref(<fig-04-cap05-luz-tx>, supplement: [Figura])). La mayoría de radios de panel tienen un indicador #strong[TX] en pantalla que se ilumina mientras transmites. Comprueba siempre que #strong[se apaga] al soltar el botón.

#figure([
#box(image("imagenes/04-cap05-luz-tx.jpg"))
], caption: figure.caption(
position: bottom, 
[
Comprobación del indicador de transmisión (TX)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap05-luz-tx>


== Jerarquía y prioridad de mensajes
<jerarquía-y-prioridad-de-mensajes>
No todos los mensajes son iguales. La OACI establece un orden de prioridad claro para que lo más urgente siempre pase primero:

+ #strong[Mensajes de SOCORRO (MAYDAY)]: Prioridad absoluta. Indican que la aeronave o las personas a bordo están en peligro grave e inminente ---fuego, rotura estructural, emergencia médica extrema--- y necesitan ayuda inmediata. Si escuchas un Mayday, calla. Silencio total en esa frecuencia, salvo que la aeronave en peligro se dirija a ti o que estés en posición de retransmitir su llamada a una torre lejana. La frase para imponer el silencio es: #emph[«Cesen transmisiones, Mayday»] (#emph[«Stop transmitting, Mayday»]).
+ #strong[Mensajes de URGENCIA (PAN PAN)]: Segunda prioridad. Hay un problema serio ---motor fallando en un motovelero que aún vuela, pérdida de posición crítica, pasajero indispuesto sin riesgo vital inmediato--- pero no se necesita salvamento en ese segundo exacto. Da prioridad sobre el tráfico ordinario y exige no interferir, aunque sin el silencio total que impone el Mayday.
+ #strong[Comunicaciones de radiogoniometría (VDF)]: Peticiones de rumbo, marcación o demora magnética (solicitudes de QDM o QDR).
+ #strong[Mensajes de seguridad de vuelo]: Avisos de tráfico ATC, separación e información meteorológica urgente (SIGMET/AIRMET).
+ #strong[Mensajes meteorológicos] regulares: METAR, TAF y pronósticos en ruta.
+ #strong[Comunicaciones de regularidad del vuelo]: Cierre de plan de vuelo, confirmaciones de posición y coordinaciones operativas.

#block[
#callout(
body: 
[
La transmisión maliciosa o falsa de señales de emergencia (Mayday / Pan Pan) constituye una infracción penal grave en todas las jurisdicciones de la EASA, sancionada con multas elevadas y la retirada de la licencia aeronaútica, además del riesgo operacional real que genera al desviar recursos de emergencia. Utilícelas exclusivamente cuando la situación real lo requiera.

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
== Técnica de micrófono
<técnica-de-micrófono>
Usar bien el micrófono del casco (#strong[headset]) o el de perilla (#strong[boom mic]) es más sencillo de lo que parece, pero hay tres cosas que marcan la diferencia entre un audio limpio y una transmisión que el controlador tiene que pedirte que repitas.

- #strong[Proximidad física]: El micrófono, por el lado de la espuma, a #strong[un centímetro de los labios sin tocarlos]. Demasiado lejos y tu voz se pierde en el ruido de cabina. Rozándolo, genera estática.
- #strong[Posicionamiento lateral]: Pon la cápsula ligeramente ladeada, paralela a la comisura de la boca, no enfrente del orificio frontal. Así el aire que sale al pronunciar consonantes oclusivas ("P", "T", "Ca") pasa por encima de la cápsula en lugar de golpear el diafragma y producir esos chasquidos que distorsionan el audio (#strong[plosive sounds]).
- #strong[Volumen constante]: Habla en volumen normal de conversación. Trata el micrófono igual que el de tu smartphone. #strong[No grites]. Aunque haya turbulencia o ruido de cabina, gritar satura la señal y la hace más ilegible, no más clara (#strong[clipping]). Si el volumen habitual no llega, ajusta la ganancia del micrófono en el panel o revisa los conectores del cable (#strong[jack plugs]).

== Equipos de radio
<equipos-de-radio>
Las radios VHF aeronáuticas van de #strong[118 MHz a 136,975 MHz] con modulación de amplitud (AM). Hay dos tipos según cómo van instaladas:

#strong[Radio de panel] (#strong[panel-mounted]): fija en el tablero, conectada a la antena exterior de la aeronave. Más potencia (6--10 W típicamente), mejor alcance y controles más cómodos en vuelo. Es el estándar en planeadores biplaza y monoplazas de competición.

#strong[Radio portátil] (#strong[handheld]): autónoma con batería propia. Menos potencia (1--5 W) y antena interna menos eficiente que la exterior, lo que recorta el alcance desde baja altitud. Se usa como respaldo ante fallo de la instalación fija o de la batería del planeador.

=== Funciones clave
<funciones-clave>
- #strong[Doble escucha (dual watch)]: monitoriza dos frecuencias simultáneamente y transmite solo en la primaria. Útil para escuchar el FIS mientras trabajas con la torre.
- #strong[Squelch]: cierra el altavoz cuando la señal baja de un umbral mínimo, eliminando el ruido de fondo. Si lo cierras demasiado, puedes perder señales débiles de aeronaves lejanas.
- #strong[Selector de canal]: confirma siempre visualmente la frecuencia en pantalla antes de transmitir.

=== Obligatoriedad del espaciado 8,33 kHz
<obligatoriedad-del-espaciado-833-khz>
Los detalles técnicos y la normativa sobre el espaciado de canales VHF se desarrollan en el capítulo 9. Como regla práctica para la operación: compruebe que su equipo es #strong[8,33 kHz compliant] antes de volar --- una radio de 25 kHz no puede sintonizar la mayoría de frecuencias modernas del ATC europeo. En la práctica, ese requisito se reconoce por el marcado #strong[ETSO-C169a], el estándar técnico europeo que certifica una radio VHF para el espaciado de 8,33 kHz.

#postit[
#strong[Resumen del Capítulo: Procedimientos Operativos Generales]

- #strong[Esquema de llamada]: A quién → Quién soy → Dónde estoy → Qué necesito. Al colacionar, el indicativo va al final. En autoinformación, el indicativo va al principio.
- #strong[Prueba de radio (radio check)]: Realízala solo si tienes dudas sobre la integridad del equipo. Usa la escala de legibilidad del 1 (ilegible) al 5 (perfecto): «Le recibo 5».
- #strong[Reportes de posición]: Identificativo + posición + altitud (QNH o FL). En travesía añade hora UTC y siguiente punto estimado. Actualiza al FIS si te apartas de tu ruta.
- #strong[Llamadas simultáneas]: Si la frecuencia está activa, espera. Tras una llamada sin respuesta, aguarda 10 segundos antes de reintentar. El ATC decide el turno cuando varias aeronaves llaman a la vez.
- #strong[Micrófono bloqueado]: Comprueba que la luz TX se apaga al soltar el PTT. Un PTT atascado anula la frecuencia para todos los usuarios.
- #strong[Prioridad de mensajes]: SOCORRO (Mayday) tiene prioridad absoluta e impone silencio total; URGENCIA (Pan Pan) pide prioridad sin exigir ese silencio. Ante un Mayday ajeno, calla salvo que puedas asistir o retransmitir.
- #strong[Técnica de micrófono]: Micrófono cerca de los labios pero sin tocarlos. Volumen normal y constante. Gritar satura la señal y reduce la inteligibilidad.
- #strong[Equipos de radio]: Panel (6--10 W, antena exterior) o portátil (1--5 W, respaldo). Obligatorio espaciado 8,33 kHz (Reglamento UE 1079/2012); el marcado #strong[ETSO-C169a] certifica que la radio cumple esa canalización.

]
= Términos de información meteorológica relevantes para VFR
<términos-de-información-meteorológica-relevantes-para-vfr>
#quote(block: true)[
La radio aeronáutica tiene su propio vocabulario meteorológico, y conocerlo te ahorra malentendidos en vuelo. En este capítulo verás qué son el ATIS y el VOLMET, qué significa CAVOK, cómo funcionan el QNH y el QFE, por qué el viento de la Torre y el de los mapas se miden diferente, y cuándo tienes que emitir un AIREP.
]

== ATIS: el servicio automático de información terminal
<atis-el-servicio-automático-de-información-terminal>
Sin el #strong[ATIS] (#strong[Automatic Terminal Information Service]), los controladores de Torre en aeródromos con tráfico medio o alto pasarían la mitad del día repitiendo lo mismo a cada aeronave que se aproxima. El ATIS existe para librarles de eso.

Es una grabación de voz ---normalmente sintética--- que suena en bucle continuo en una frecuencia VHF propia, separada de la frecuencia de control (#ref(<fig-04-cap06-atis-escucha>, supplement: [Figura])). Te dice:

- #strong[Pista en servicio] para despegues y aterrizajes.
- #strong[Condiciones meteorológicas] actuales: viento, visibilidad, nubes, temperatura, punto de rocío y QNH.
- #strong[Información operativa:] obras en calles de rodaje, avisos de cizalladura o presencia de aves.

Cada boletín lleva una letra del alfabeto fonético como #strong[código de información] («Información Bravo», por ejemplo). Cuando cambian significativamente las condiciones o la pista en uso, el boletín avanza a la siguiente letra («Información Charlie»).

#block[
#callout(
body: 
[
Escucha el ATIS completo #strong[antes] de llamar a la Torre. Luego incluye el código en tu primera llamada: #emph[«Jerez TWR, velero EC-DPE, a 10 millas al norte, con información Bravo, solicito…​»] El controlador sabe que ya tienes todos los datos y puede ir directo al grano.

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
#box(image("imagenes/04-cap06-atis-escucha.jpg"))
], caption: figure.caption(
position: bottom, 
[
Secuencia de escucha del ATIS antes del contacto con Torre
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap06-atis-escucha>


== VOLMET: información meteorológica para aeronaves en vuelo
<volmet-información-meteorológica-para-aeronaves-en-vuelo>
El ATIS te da el tiempo de un aeropuerto concreto. El #strong[VOLMET] (de #strong[VOL METéorologique]) te da el tiempo de una región entera.

Es otra emisión pregrabada en bucle, pero en lugar de un aeródromo emite METAR, pronósticos TAF y avisos SIGMET de #strong[un conjunto de aeropuertos de una misma región].

En travesías largas (#strong[cross-country]), cuando el tiempo empieza a empeorar y estás valorando un alternativo a decenas de kilómetros, el VOLMET regional te dice exactamente cómo está ese campo sin tener que llamar a nadie. Tomas la decisión con datos reales y la frecuencia de control queda libre.

== Conceptos clave en las transmisiones meteorológicas
<conceptos-clave-en-las-transmisiones-meteorológicas>
Por radio, el tiempo no se describe con palabras propias: se usa terminología estandarizada que cualquier piloto entiende igual, con cualquier acento y con cualquier nivel de ruido de fondo.

=== CAVOK
<cavok>
Probablemente la palabra más bienvenida que puedes escuchar en el ATIS. (techo y visibilidad correctos) significa que se cumplen tres condiciones a la vez:

+ #strong[Visibilidad] de 10 kilómetros o más.
+ #strong[Ninguna nube] convectiva (ni Cumulonimbus CB, ni Cumulus Congestus TCU) y ninguna capa de nubes por debajo de 5.000 pies o de la altitud mínima del sector, lo que sea mayor.
+ #strong[Sin fenómenos] meteorológicos significativos en el aeródromo o cercanías: sin precipitaciones, tormentas, niebla somera ni ventisca baja.

=== El ajuste QNH y QFE
<el-ajuste-qnh-y-qfe>
El altímetro del planeador es un barómetro: necesita una presión de referencia en la ventanilla para saber a qué altitud estás.

- El #strong[QNH] es la presión atmosférica reducida al nivel medio del mar. Mételo en el altímetro y te dará #strong[la altitud real] sobre el nivel del mar. Es el ajuste que usas en ruta y para respetar los límites verticales de los espacios aéreos (los techos de los CTR van en altitud QNH).
- El #strong[QFE] es la presión a la elevación del aeródromo. Con el QFE puesto, el altímetro marca #strong[cero pies] en tierra: te indica altura sobre el campo, no altitud. En veleros casi no se usa ya, salvo en operaciones muy locales o acrobacia en aeródromo. El QNH es el ajuste de referencia en las comunicaciones ATS (#ref(<fig-04-cap06-qnh-qfe>, supplement: [Figura])).

#figure([
#box(image("imagenes/04-cap06-qnh-qfe.jpg"))
], caption: figure.caption(
position: bottom, 
[
Comparación del altímetro con ajuste QNH y QFE
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap06-qnh-qfe>


=== La dualidad del viento: magnético frente a geográfico
<la-dualidad-del-viento-magnético-frente-a-geográfico>
Cuando calculas el planeo final o la componente cruzada, necesitas saber en qué referencia está expresado el viento. No siempre es la misma (#ref(<fig-04-cap06-viento-magnetico-geografico>, supplement: [Figura])).

- #strong[Viento radiado (Torre / ATIS):] La dirección del viento en las operaciones de aproximación y despegue va referida al #strong[Norte Magnético] («Viento 240 grados, 15 nudos»). Tiene sentido: tanto la brújula de cabina como la numeración de las pistas usan la declinación magnética, así que puedes comparar directamente la orientación de la pista con el viento sin hacer correcciones.
- #strong[Viento escrito (mapas meteorológicos / METAR en texto / VOLMET):] Si consultas el viento en una web de meteo, en un mapa de vientos en altura (GRIB) o en un METAR/TAF en formato texto ---incluyendo el que difunde el VOLMET---, la dirección viene referida al #strong[Norte Geográfico (verdadero)]. El VOLMET retransmite METAR y TAF en texto, así que su viento también es #strong[verdadero], distinto del viento operativo que te da la Torre.

#figure([
#box(image("imagenes/04-cap06-viento-mag-geo.jpg"))
], caption: figure.caption(
position: bottom, 
[
Diferencia entre viento magnético (radio) y geográfico (mapas)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap06-viento-magnetico-geografico>


=== SIGMET y AIRMET
<sigmet-y-airmet>
Dos tipos de avisos meteorológicos que aparecen en el VOLMET y en los briefings prevuelo:

- #strong[SIGMET] (#strong[Significant Meteorological Information]): aviso emitido por los centros meteorológicos de vigilancia para fenómenos severos en ruta ---tormentas eléctricas, engelamiento intenso, turbulencia severa, cenizas volcánicas---. Cubre grandes áreas y tiene validez de hasta 4 horas (6 h en zonas oceánicas). Su uso obliga a tomarse muy en serio la decisión de vuelo.
- #strong[AIRMET] (#strong[Airman's Meteorological Information]): aviso de menor severidad, dirigido especialmente a la aviación de bajo nivel y la aviación general. Cubre fenómenos moderados ---turbulencia moderada, engelamiento moderado, visibilidad reducida--- que no alcanzan el umbral del SIGMET.

Ambos los encontrarás en el VOLMET regional o en el briefing meteorológico prevuelo. Si un SIGMET activo afecta a tu ruta, evalúa si las condiciones son operables antes de salir.

== AIREP: el informe meteorológico especial en vuelo
<airep-el-informe-meteorológico-especial-en-vuelo>
El #strong[AIREP] (#strong[Aircraft Report]) es el informe que tú, como piloto, transmites al FIS o al ATC cuando encuentras en ruta condiciones meteorológicas peligrosas que no estaban pronosticadas.

Si te metes en turbulencia fuerte, engelamiento, tormenta, granizo u ondas orográficas intensas, emites un AIREP especial con tu posición y altitud. Así el ATC puede avisar a los demás tráficos en esa zona.

#block[
#callout(
body: 
[
El Reglamento SERA obliga al piloto en mando a notificar sin demora cualquier condición meteorológica peligrosa que pueda afectar a la seguridad de otras aeronaves.

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
#postit[
#strong[Resumen del capítulo: terminología meteorológica]

- #strong[ATIS]: Voz automática en aeropuertos. Escucharla antes de llamar proporciona pista en uso, viento, QNH y el #strong[código de información] (p.~ej., «Información Bravo»). Ahorra tiempo al controlador y agiliza la comunicación.
- #strong[VOLMET]: Emisora dedicada a difundir METAR, TAF y SIGMET de varios aeropuertos en bucle. Permite planificar la llegada o seleccionar un alternativo sin saturar la frecuencia de control.
- #strong[Conceptos clave]:
- #strong[CAVOK]: #strong[Ceiling and Visibility OK] (visibilidad ≥ 10 km, sin nubes bajas, sin fenómenos). Las mejores condiciones posibles para VFR.
- #strong[QNH]: Presión de referencia para leer la altitud sobre el nivel del mar. Fundamental para respetar los límites verticales de los espacios aéreos.
- #strong[Viento]: La Torre y el ATIS facilitan el viento referido al Norte Magnético (igual que la numeración de pistas). En mapas, METAR/TAF en texto y VOLMET el viento viene referido al Norte Geográfico (verdadero).
- #strong[AIREP]: Informe emitido obligatoriamente por el piloto en vuelo para notificar a otras aeronaves sobre fenómenos meteorológicos severos no pronosticados.

]
= Acciones ante fallo de comunicaciones
<acciones-ante-fallo-de-comunicaciones>
#quote(block: true)[
Quedarse sin radio en vuelo ---situación NORDO--- tiene un protocolo concreto. Aquí verás qué hacer con el transpondedor, cómo gestionar el vuelo hasta tierra, qué significan las señales de luces de la Torre y cómo transmitir cuando solo falla el receptor.
]

== El código 7600: señal de fallo de radio
<el-código-7600-señal-de-fallo-de-radio>
Perder toda la radio en vuelo ---técnicamente, pérdida de comunicaciones bidireccionales o situación #strong[NORDO] (#strong[No Radio])--- es un problema serio, especialmente cerca de espacio aéreo controlado. No entres en pánico: hay un procedimiento.

Primero repasa lo básico: volumen, silenciador (#strong[squelch]), conectores de los auriculares (#strong[jacks]), fusibles y frecuencias alternativas. Si nada funciona, ve al transpondedor.

Pon el #strong[código 7600] ahora.

Con ese código, el radar secundario de vigilancia (SSR) de los centros de control muestra tu aeronave con una alerta especial en pantalla. Los controladores del sector saben que estás NORDO y empiezan a coordinar: despejan el espacio aéreo a tu alrededor y te siguen visualmente.

== Procedimiento estándar en vuelo VFR
<procedimiento-estándar-en-vuelo-vfr>
Con la situación NORDO declarada, el plan es este:

+ #strong[Mantén VMC.] No entres en nubes bajo ningún concepto. Necesitas visibilidad y contacto visual con el suelo y otros tráficos.
+ #strong[Rodea las zonas controladas.] Si tu ruta cruzaba un CTR, quédate fuera. Sin radio no puedes obtener autorización.
+ #strong[Aterriza en el aeródromo adecuado más cercano.] Preferiblemente uno no controlado: te integras en el circuito visual con los ojos bien abiertos y aterrizas.
+ #strong[Llama por teléfono en cuanto estés en tierra.] Contacta con la dependencia ATC correspondiente para confirmar el aterrizaje. Si no lo haces, los servicios ATS activarán la fase de Búsqueda y Salvamento (SAR).

#block[
#callout(
body: 
[
Si no tienes más remedio que aterrizar en un aeródromo controlado, acércate a la Torre por zonas que no interfieran con las operaciones y haz balanceos de alas (#strong[wing rock]) para que te vean. Luego colócate paralelo a la pista, por delante de la torre, y mira las señales luminosas del ATC.

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
#box(image("imagenes/04-cap07-senales-luces.jpg"))
], caption: figure.caption(
position: bottom, 
[
Señales con pistola de luces desde la Torre de Control
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap07-pistola-luces>


== Señales luminosas de la Torre (Reglamento SERA)
<señales-luminosas-de-la-torre-reglamento-sera>
Desde los primeros aeródromos, las torres de control tienen focos direccionales con filtros de color ---la «pistola de luces»--- precisamente para esto: guiar a aeronaves sin radio (#ref(<fig-04-cap07-pistola-luces>, supplement: [Figura])). Memoriza estas señales. Si algún día las necesitas, no habrá tiempo para buscarlas.

#block[
#callout(
body: 
[
Las señales luminosas de la Torre de Control están reguladas por el Reglamento de Ejecución (UE) n.º 923/2012 ---Reglas Europeas Estandarizadas del Aire (#strong[SERA])---. Su correcto conocimiento e interpretación es obligatorio para todo piloto que opere en espacios aéreos con servicio ATC (Fuente: documentación oficial SERA, EASA / AESA).

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
#strong[Señales para aeronaves en vuelo:]

- ● #strong[Luz verde fija]: Autorizado a aterrizar.
- ● #strong[Luz roja fija]: Ceda el paso a otras aeronaves y continúe en circuito de espera.
- ●●● #strong[Serie de destellos verdes]: Regrese para aterrizar.
- ●●● #strong[Serie de destellos rojos]: Aeródromo peligroso o inseguro, no aterrice.
- ○○○ #strong[Serie de destellos blancos]: Aterrice en este aeródromo.
- ★ #strong[Luz pirotécnica roja]: A pesar de las instrucciones previas, no aterrice por el momento.

#strong[Señales para aeronaves en tierra:]

- ● #strong[Luz verde fija]: Autorizado para despegar.
- ● #strong[Luz roja fija]: Alto.
- ●●● #strong[Serie de destellos verdes]: Autorizado para rodar.
- ●●● #strong[Serie de destellos rojos]: Apártese del área de aterrizaje en uso.
- ○○○ #strong[Serie de destellos blancos]: Regrese al punto de partida en el aeródromo.

#block[
#callout(
body: 
[
Al recibir una señal de la Torre en vuelo, acusa recibo de la única forma posible: de día, guiñadas con el timón o balanceos de alas bien visibles. De noche, encendiendo y apagando las luces de aterrizaje o de navegación. En tierra, moviendo los alerones o el timón de dirección.

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
== La transmisión a ciegas (#emph[blind transmission])
<la-transmisión-a-ciegas-blind-transmission>
A veces el fallo es solo del receptor: tu voz sale al exterior con normalidad, pero no recibes nada. No puedes saberlo con certeza desde el aire, pero si sospechas que es así, aplica la #strong[transmisión a ciegas] (#strong[blind transmission]).

La idea es simple: sigues transmitiendo posición e intenciones en la frecuencia correcta, pero cada mensaje va precedido de un aviso:

#emph[«Transmitiendo a ciegas debido a fallo del receptor. Transmitiendo a ciegas. Torre de San Javier, planeador EC-EPE, a 5 millas del punto Sierra a 2.000 pies, intención entrar en zona y proceder a inicial de pista 23 para toma completa.»]

Transmite cada mensaje completo dos veces: sin acuse de recibo, la repetición es tu única garantía de que llegue entero. Y repite el aviso en cada cambio de tramo del circuito o al iniciar el descenso en final. El controlador puede estar recibiéndote perfectamente en tierra y coordinando el tráfico a partir de lo que narras, aunque tú no puedas confirmarlo.

#postit[
#strong[Resumen del capítulo: fallo de comunicaciones]

- #strong[Código 7600]: Al confirmar el fallo de radio, seleccione 7600 en el transpondedor. La aeronave aparecerá destacada en la pantalla del radar secundario (SSR) como situación NORDO.
- #strong[Procedimiento en vuelo]: Mantenga VMC. Aterrice preferentemente en un aeródromo no controlado. Si debe acudir a uno controlado, sobrevuele la Torre por zona no operativa, efectúe balanceos de alas y observe las señales de luces. Notifique por teléfono en cuanto tome tierra.
- #strong[Señales de luces (SERA)]: #emph[Verde fija] (vuelo) = autorizado a aterrizar. #emph[Roja fija] (vuelo) = ceda el paso. #emph[Destellos rojos] (vuelo) = aeródromo peligroso. #emph[Destellos verdes] (vuelo) = regrese para aterrizar. #emph[Destellos blancos] (vuelo) = aterrice en este aeródromo. Las señales equivalentes en tierra tienen significados distintos: #emph[verde fija] = autorizado para despegar; #emph[destellos verdes] = autorizado para rodar.
- #strong[Transmisión a ciegas]: Si solo falla el receptor, transmita posición e intenciones en la frecuencia correcta precediendo el mensaje con «Transmitiendo a ciegas debido a fallo del receptor». Repítalo en cada cambio de tramo.

]
= Procedimientos de socorro y urgencia
<procedimientos-de-socorro-y-urgencia>
#quote(block: true)[
MAYDAY y PAN PAN no son sinónimos. Este capítulo explica cuándo usar cada uno, qué decir exactamente y en qué frecuencia. Son los dos mensajes más importantes que puedes transmitir por radio, y esperas no necesitarlos nunca. Por eso los tienes que saber de memoria. Cierra el capítulo otro procedimiento que también esperas no usar jamás: qué hacer si una aeronave militar te intercepta.
]

== MAYDAY: situación de socorro
<mayday-situación-de-socorro>
#strong[MAYDAY] es la palabra de mayor prioridad en la radio aeronáutica. Viene del francés #emph[m'aider], «ayudadme», pronunciado en inglés.

Úsala cuando hay #strong[peligro grave e inminente y necesitas asistencia inmediata]. La vida de los ocupantes o la integridad del planeador están en riesgo ahora mismo.

En vuelo a vela, eso significa: fuego a bordo, rotura estructural severa (cúpula, timón, ala), incapacitación médica del piloto, o pérdida de altitud sin campo disponible que exige actuar ya.

La palabra se repite #strong[tres veces] para que destaque sobre el tráfico normal y las interferencias:

#emph[«Mayday, Mayday, Mayday…​»]

#block[
#callout(
body: 
[
La transmisión maliciosa o falsa de un mensaje de socorro MAYDAY moviliza recursos de búsqueda y salvamento (SAR) estatales. Según la Ley de Seguridad Aérea, simular emergencias o proporcionar información falsa que comprometa la seguridad se tipifica como infracción muy grave, conlleva sanciones económicas elevadas y puede resultar en la revocación de la licencia de vuelo.

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
La declaración de un MAYDAY impone, según la normativa internacional (OACI/EASA), un #strong[silencio de radio absoluto] para todas las demás estaciones áreas y terrestres operando en esa frecuencia. Ningún otro tráfico debe transmitir a menos que sea para ofrecer ayuda directa a la aeronave en peligro o para retransmitir su mensaje a la Torre de Control (#strong[Mayday relay]).

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
== PAN PAN: situación de urgencia
<pan-pan-situación-de-urgencia>
Un escalón por debajo está la #strong[urgencia]. Se declara con #strong[PAN PAN], también tres veces: #emph[«Pan Pan, Pan Pan, Pan Pan»]. Del francés #emph[panne], avería.

El PAN PAN dice que tienes un problema serio que necesita #strong[atención prioritaria] del ATC, pero no estás en peligro inmediato de accidente ni necesitas salvamento en los próximos segundos.

En planeador: entrar involuntariamente en IMC sin poder salir a VFR de inmediato, una indisposición médica que obliga a desviar el vuelo, o una pérdida progresiva de altura que te da tiempo a planificar el aterrizaje fuera de aeródromo y coordinarlo con el ATC o el FIS.

El PAN PAN te da prioridad en las comunicaciones. No exige silencio total al resto de tráficos, a diferencia del MAYDAY.

== Estructura del mensaje de emergencia
<estructura-del-mensaje-de-emergencia>
Con el corazón acelerado y las manos ocupadas, puede costar estructurar un mensaje. Pero los servicios de control y salvamento (SAR) necesitan información concreta para localizarte y ayudarte. Esta es la secuencia (#ref(<fig-04-cap08-llamada-emergencia>, supplement: [Figura])):

+ #strong[A QUIÉN:] Nombre de la dependencia ATS.
+ #strong[QUIÉN:] Tipo de aeronave e indicativo completo.
+ #strong[DÓNDE:] Posición actual, altitud o nivel de vuelo, y rumbo.
+ #strong[QUÉ PASA:] Naturaleza de la emergencia.
+ #strong[QUÉ SOLICITA:] Intenciones del piloto y tipo de ayuda requerida.
+ #strong[PERSONAS:] Personas a bordo (vital para los servicios de rescate).

#emph[Ejemplo de mensaje de socorro (MAYDAY):] #emph[«Mayday, Mayday, Mayday. Madrid Información. Velero ASK-21, EC-EPE. A 5 millas al este de Fuentemilanos, 2.800 metros. Impacto con ave y rotura masiva del timón de profundidad. El piloto y el pasajero van a saltar en paracaídas. 2 personas a bordo.»]

#emph[Ejemplo de mensaje de urgencia (PAN PAN):] #emph[«Pan Pan, Pan Pan, Pan Pan. Madrid Información. Velero ASK-21, EC-EPE. Sobre el embalse de Pinilla, 2.200 metros QNH 1018. Pérdida de altura progresiva sin térmica disponible. Planificando aterrizaje fuera de aeródromo en 10 minutos. 2 personas a bordo. Solicito información de campos en el área.»]

#figure([
#box(image("imagenes/04-cap08-estructura-emergencia.jpg"))
], caption: figure.caption(
position: bottom, 
[
Estructura de la llamada de emergencia
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap08-llamada-emergencia>


== La frecuencia adecuada
<la-frecuencia-adecuada>
Hay una idea muy extendida que dice que en cualquier emergencia lo primero es cambiar a 121.500 MHz. Es un error.

#strong[La mejor frecuencia para declarar una emergencia es en la que ya estás.]

Si estás hablando con «Zaragoza Torre» o escuchando «Madrid Información», emite ahí. El controlador ya te tiene en pantalla y la comunicación está establecida. Cambiar de frecuencia en medio de una emergencia añade trabajo y arriesga perder el contacto.

Ahora bien, si vuelas en una zona remota sin contacto ATS y nadie responde a tu llamada local, entonces sí: cambia a #strong[121.500 MHz].

Esa frecuencia la escuchan continuamente los vuelos de líneas aéreas en crucero, las estaciones militares de defensa aérea y los centros de control de área. Un MAYDAY en 121.500 MHz tiene muchas probabilidades de ser escuchado y retransmitido (#strong[relay]) a los servicios de rescate.

== Interceptación: si un caza aparece a tu lado
<interceptación-si-un-caza-aparece-a-tu-lado>
Un planeador rara vez provoca una interceptación (#strong[interception]), pero puede ocurrir: infringir una zona prohibida o restringida activa, cruzar un CTR sin autorización o aparecer como un eco sin identificar cerca de una zona sensible puede hacer que la defensa aérea envíe una aeronave militar a identificarte. El Libro 1 ya te avisa de ese riesgo al estudiar las zonas P y R; aquí aprenderás las señales y la respuesta correcta. No es un adorno del temario: la normativa exige llevar a bordo una copia de estas señales (SAO.GEN.155, véase el Libro 6, capítulo 1), y las preguntas sobre interceptación caen en el examen.

=== Las señales del interceptor
<las-señales-del-interceptor>
El interceptor se comunica contigo con maniobras, no con palabras. Las tres series que debes reconocer, conforme a la tabla S11-1 de SERA:

1

Alabea y enciende y apaga las luces de navegación a intervalos irregulares, desde una posición ligeramente por encima, por delante y normalmente a tu izquierda. Después, vira lentamente en horizontal hacia el rumbo deseado.

«Ha sido interceptado. Sígame.»

Alabea, enciende y apaga las luces de navegación si dispones de ellas, y síguele.

2

Se aleja bruscamente de ti con un viraje ascendente de 90° o más, sin cruzar tu línea de vuelo.

«Prosiga.»

Alabea: «Comprendido, lo cumpliré».

3

Despliega el tren de aterrizaje, lleva los faros de aterrizaje encendidos de forma continua y sobrevuela la pista en servicio.

«Aterrice en este aeródromo.»

Despliega el tren (si es replegable), sigue al interceptor y, tras sobrevolar la pista, aterriza si es seguro.

Si el interceptor es mucho más rápido que tú ---lo será siempre---, la norma ya lo prevé: hará circuitos de hipódromo a tu alrededor y alabeará cada vez que te adelante. No lo interpretes como una señal nueva; sigue siendo la serie 1.

#figure([
#box(image("imagenes/04-cap08-interceptacion-serie1.png"))
], caption: figure.caption(
position: bottom, 
[
Serie 1: el interceptor se coloca por delante y a tu izquierda, alabea y vira hacia el rumbo que debes seguir
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap08-interceptacion-serie1>


=== Qué debes hacer
<qué-debes-hacer>
Si te interceptan, aplica de inmediato los cuatro pasos de SERA.11015:

+ #strong[Sigue las instrucciones visuales] del interceptor, interpretándolas y respondiendo según las tablas de señales.
+ #strong[Notifica], si es posible, a la dependencia de servicios de tránsito aéreo con la que estés en contacto.
+ #strong[Intenta la radio]: llamada general en #strong[121,500 MHz], indicando tu identidad y la índole del vuelo (por ejemplo: #emph[«Aeronave interceptada, velero EC-EPE, vuelo VFR de Fuentemilanos a Santo Tomé, escucho»]).
+ #strong[Selecciona 7700 en modo A] en el transpondedor, salvo que el ATS te instruya otra cosa.

#block[
#callout(
body: 
[
SERA.11015 c): «Si alguna instrucción recibida por radio de cualquier fuente estuviera en conflicto con las instrucciones dadas por la aeronave interceptora mediante señales visuales, la aeronave interceptada requerirá aclaración inmediatamente mientras continúa cumpliendo con las instrucciones visuales dadas por la aeronave interceptora.» La misma regla se aplica si el conflicto es con instrucciones dadas por radio por el interceptor (SERA.11015 d)).

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
#block[
#callout(
body: 
[
#strong[Las instrucciones del interceptor prevalecen sobre cualquier otra fuente, incluido el ATC], mientras solicitas aclaración. Un interceptor armado que cree que no cooperas es el escenario más peligroso en el que puede meterse una aeronave civil: mantén una trayectoria suave y predecible, no hagas maniobras bruscas y responde a cada señal.

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
=== Si no puedes cumplir
<si-no-puedes-cumplir>
También el interceptado tiene señales propias (tabla S11-2 de SERA): encender y apagar #strong[todas las luces disponibles a intervalos regulares] significa «imposible cumplir» (serie 5), y hacerlo #strong[a intervalos irregulares] significa «en peligro» (serie 6). Si logras contacto por radio pero no hay idioma común, la norma prevé frases estándar (tabla S11-3): el interceptor usará FOLLOW («sígame»), DESCEND («descienda») o YOU LAND («aterrice»); tú responderás WILCO («cumpliré»), CAN NOT («imposible cumplir»), AM LOST («posición desconocida») o MAYDAY.

#block[
#callout(
body: 
[
Un velero sin luces de navegación tiene pocas opciones de señalización: tu respuesta visible es el #strong[alabeo amplio y claro]. Compensa el resto con la radio (121,500 MHz) y el transpondedor (7700). Y recuerda que la mejor interceptación es la que no ocurre: comprueba los NOTAM y el estado de las zonas P y R antes de cada vuelo de travesía.

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
#strong[Resumen del capítulo: procedimientos de socorro y urgencia]

- #strong[MAYDAY (x3)]: Exclusivo para situaciones de peligro #strong[GRAVE E INMINENTE] con riesgo vital (fuego, colisión, fallo estructural). Otorga prioridad absoluta e impone silencio total de radio al resto de tráficos.
- #strong[PAN PAN (x3)]: Situación de #strong[URGENCIA]. Requiere asistencia prioritaria (enfermo a bordo, desorientación, avería no crítica) pero no existe riesgo inmediato de accidente. Pide prioridad, no silencio total.
- #strong[Estructura del mensaje]: A QUIÉN (Estación) + QUIÉN (Indicativo) + DÓNDE (Posición) + QUÉ PASA (Problema) + QUÉ SOLICITA (Intenciones y asistencia).
- #strong[Frecuencia recomendada]: La mejor frecuencia es aquella donde el vuelo ya está establecido en contacto. Si falla o no hay respuesta, pasar a la frecuencia internacional de emergencia 121.500 MHz.
- #strong[Interceptación (SERA.11015)]: interceptor alabeando por delante y a tu izquierda = «Sígame» (responde alabeando y siguiéndole); viraje ascendente brusco de 90° o más = «Prosiga»; tren desplegado y faros encendidos sobre la pista = «Aterrice en este aeródromo». Procedimiento: seguir las instrucciones visuales + notificar al ATS + llamada en 121,500 MHz + squawk 7700. #strong[Las instrucciones del interceptor prevalecen sobre cualquier otra fuente, incluido el ATC], mientras se solicita aclaración. A bordo debe llevarse copia de las señales (SAO.GEN.155).

]
= Principios generales de propagación VHF y asignación de frecuencias
<principios-generales-de-propagación-vhf-y-asignación-de-frecuencias>
#quote(block: true)[
La radio VHF funciona como una linterna: ilumina en línea recta y la montaña te deja a oscuras. En este capítulo verás por qué la altitud es tu mejor aliada para el alcance, qué cambió con el espaciado a 8,33 kHz, cómo ajustar bien el #strong[squelch], qué hacer cuando una sierra te bloquea la señal, y qué frecuencias necesitas conocer de memoria. También cuándo es obligatorio el transpondedor y qué significan los códigos #strong[squawk].
]

== Alcance visual: la línea recta de las ondas VHF
<alcance-visual-la-línea-recta-de-las-ondas-vhf>
Las comunicaciones aeronáuticas de voz se transmiten en la banda de #strong[Muy Alta Frecuencia (VHF)] (#emph[Very High Frequency]), entre los 118.000 MHz y los 136.975 MHz, con modulación de amplitud (AM).

Las ondas VHF #strong[se propagan en línea recta], exactamente como un haz de luz. A esto se le llama propagación por línea de mira (#strong[Line of Sight]). La consecuencia es inmediata: si algo sólido se interpone entre tu antena y la del receptor, la comunicación se corta. Sin más.

Las ondas de baja frecuencia rebotan en la ionosfera y pueden rodear el horizonte. Las VHF no. No atraviesan la tierra ni se doblan sobre ella. Una montaña, un edificio o la propia curvatura terrestre las paran en seco.

Por eso #strong[la altitud es tu mejor aliada para el alcance de la radio]. Cuanto más alto vueles, más lejos «verá» tu antena por encima de la curvatura terrestre y de los obstáculos. Hay una fórmula para estimarlo sobre terreno llano:

#NormalTok("Alcance Máximo [NM] = 1.23 × √H [pies]");

#emph[Ejemplo práctico: a 10.000 pies de altura, la raíz cuadrada es 100. Multiplicado por 1,23, el alcance teórico hacia una estación en el suelo es de unas 123 millas náuticas, unos 228 km.]

== La separación de canales a 8,33 kHz
<la-separación-de-canales-a-833-khz>
Durante décadas, el espectro VHF de aviación se dividió en canales separados por 25 kHz. Funcionó bien hasta que el crecimiento del tráfico aéreo en Europa dejó sin canales suficientes para nuevos sectores de ATC, aproximaciones y aeródromos.

La solución fue reducir el espaciado de cada canal de 25 kHz a #strong[8,33 kHz]. Con eso, el número de canales disponibles en la misma porción del espectro se triplicó.

El Reglamento de ejecución (UE) N.º 1079/2012 impuso la transición en toda Europa. En España, desde el #strong[31 de diciembre de 2022], los vuelos VFR tienen que ir equipados con radios «compatibles con 8,33» (#strong[8,33 compliant]). Los IFR cumplieron antes.

#block[
#callout(
body: 
[
Si tu velero lleva una radio antigua de 25 kHz ---la que solo marca diales acabados en .000, .025, .050 o .075---, la regla general en Europa es que ya no basta: para operar con las dependencias modernas del ATC necesitas un equipo capaz de sintonizar el espaciado de 8,33 kHz. Hay una excepción que conviene conocer: el AIP-España (ENR 1.8) mantiene, comunicadas a la Comisión (Reg. 2023/1770 y 2023/1771), unas #strong[sub-bandas nacionales en 25 kHz para comunicaciones aire-aire y aire-tierra hasta el 31-12-2028] ---precisamente las de vuelo a vela que aparecen en la tabla de este capítulo (122,600; 123,375; 123,400; 123,450; 123,500)---. Así que como afirmación legal la frase exige el matiz de la exención; como recomendación práctica, equipa 8,33 sin dudarlo: sin él no te comunicarás con la mayoría de las dependencias del ATC.

]
, 
title: 
[
Normativa: RADIOS 8,33 kHz
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
== El #emph[squelch]: la puerta del ruido
<el-squelch-la-puerta-del-ruido>
Casi todas las radios aeronáuticas tienen un control giratorio, o un menú digital, etiquetado como #strong[Squelch] (Silenciador).

El #strong[squelch] es un circuito electrónico que actúa como una puerta de ruido. Cuando nadie transmite en la frecuencia, la antena capta estática: ese siseo molesto de fondo. El squelch lo silencia. Solo cuando llega una señal suficientemente fuerte ---una voz--- la puerta se abre y el audio llega a tus auriculares o altavoces.

#strong[Ajuste correcto:]

+ Baja el squelch hasta que escuches el ruido estático fuerte continuo («siseo»).
+ Súbelo lentamente #strong[justo hasta el punto] en que el ruido desaparece.

#block[
#callout(
body: 
[
No subas el squelch más allá del punto donde cesa el ruido. Si lo dejas «al máximo», las señales débiles de planeadores lejanos o de un ATC distante no tendrán fuerza suficiente para abrir la puerta. Creerás que la frecuencia está en silencio cuando en realidad alguien te está llamando.

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
#box(image("imagenes/04-cap09-bloqueo-montana.jpg"))
], caption: figure.caption(
position: bottom, 
[
Bloqueo orográfico de la señal VHF
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap09-bloqueo-montana>


== Bloqueo en montaña y relé de radio (#emph[relay])
<bloqueo-en-montaña-y-relé-de-radio-relay>
El vuelo a vela lleva a menudo a los planeadores a entornos orográficos complejos: laderas de los Pirineos, valles del Gredos, cajones del Sistema Central. Lejos de las llanuras y muy por debajo de las crestas.

Las ondas VHF viajan en línea recta y no atraviesan la roca. Si bajas por debajo de la cresta que te separa de la torre de control o del repetidor FIS de ENAIRE más cercano, sufrirás un #strong[bloqueo orográfico] total (#ref(<fig-04-cap09-bloqueo-montana>, supplement: [Figura])). Da igual cuánta potencia tenga tu radio: la señal se estrella contra la piedra.

En alta montaña, anticipa esto con dos medidas:

+ #strong[Anticipa la falta de cobertura]: Si tienes que notificar un informe de posición al FIS, hazlo #strong[antes] de meterte en ese valle o detrás de esa cordillera.
+ #strong[El avión puente (Relay)]: En una emergencia desde el fondo de un cajón sin cobertura, recuerda que por encima de ti hay planeadores de tu propio club a más altura, o aviones comerciales en ruta. Ellos «ven» tanto tu posición en el valle como la torre lejana. Úsalos como #strong[estaciones relé]. Emite: #emph[«Tráfico en 123,500, aquí Eco Papa Eco en emergencia en el fondo del valle del Jerte, ¿alguien puede retransmitir mi Mayday a Madrid Información?»] Sus ondas llegarán libres de obstáculos hasta la torre, y ellos retransmitirán tu llamada.

== Frecuencias usuales en aviación deportiva
<frecuencias-usuales-en-aviación-deportiva>
Saberte de memoria las frecuencias más habituales te permite sintonizarlas sin consultar la carta y reaccionar rápido ante cualquier cambio o emergencia.

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Frecuencia (MHz)], [Uso], [Ámbito],),
  table.hline(),
  [#strong[121,500]], [Emergencia aeronáutica internacional], [Internacional. Escuchada las 24 h por vuelos de línea en altitud de crucero, instalaciones militares de defensa aérea y centros de control de área.],
  [#strong[122,600]], [Vuelo a vela (frecuencia principal)], [España. Coordinación entre planeadores en área de vuelo libre y notificación entre pilotos.],
  [#strong[123,375]], [Vuelo a vela (alternativa)], [Frecuencia alternativa de coordinación entre planeadores cuando 122,600 está saturada.],
  [#strong[123,400]], [Vuelo a vela (alternativa)], [Segunda frecuencia alternativa de coordinación para planeadores.],
  [#strong[123,450]], [Frecuencia de «charla» (#strong[air-to-air])], [Comentarios de vuelo y coordinación informal entre pilotos. No debe usarse para gestiones con ATC ni FIS.],
  [#strong[123,500]], [Aeródromo no controlado genérico], [Autoinformación en aeródromos sin torre o con AFIS donde no hay frecuencia específica publicada.],
)
Las frecuencias de #strong[FIS regionales] de España (Madrid, Barcelona, Sevilla, Palma de Mallorca, Gran Canaria) varían por sector y altitud. Se publican en el AIP España (GEN 3.3) y en las cartas de navegación OACI 1:500.000. Cada aeródromo con torre o AFIS tiene su propia frecuencia, publicada en la carta VAC del aeródromo. La propia tabla de arriba procede del AIP-España (GEN 3.4 y ENR 1.8).

#block[
#callout(
body: 
[
Con el espaciado de 8,33 kHz, las cartas y las radios muestran #strong[canales], no frecuencias exactas: verás diales acabados en .005, .010, .015… y a veces un sufijo «C». No es un error de sintonía; es la nomenclatura del canal, que no coincide con la frecuencia real. Sintoniza el canal tal como figura en la carta.

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
Antes de cada travesía, anota las frecuencias de FIS de los sectores que atravesarás. En una zona con cobertura degradada o tras una emergencia, buscar la frecuencia en el mapa es tiempo que no tienes.

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
== El transpondedor: identificación secundaria en vuelo
<el-transpondedor-identificación-secundaria-en-vuelo>
El #strong[transpondedor] (#emph[XPDR]) responde automáticamente a los radares terrestres emitiendo un código de cuatro dígitos (). Así el controlador ve tu aeronave identificada en pantalla.

Llevarlo operativo es obligatorio dentro de una #strong[TMZ] (#emph[Transponder Mandatory Zone]) y allí donde lo exijan la clase de espacio aéreo o el AIP-España (ENR 1.6): las clases A y C lo requieren, y la D generalmente (véase la tabla del #strong[Libro 1 --- Derecho aéreo], capítulo 7). Fuera de esos espacios sigue siendo muy recomendable en cualquier zona con tráfico: si está instalado y operativo, la práctica correcta es llevarlo encendido y en modo ALT (transmisión de altitud).

- #strong[7000]: Código VFR estándar.
- #strong[7500]: Interferencia ilícita (secuestro). Solo ante una amenaza real a la integridad de la aeronave. Su uso activa protocolos inmediatos de defensa aérea.
- #strong[7600]: Fallo de radio (NORDO).
- #strong[7700]: Emergencia general.
- #strong[Botón IDENT]: Hace parpadear tu etiqueta en el radar. Púlsalo #strong[solo] cuando el controlador lo pida expresamente («#emph[Squawk ident]»).

#postit[
#strong[Resumen del Capítulo: Principios de Propagación VHF]

- #strong[Alcance Visual]: Las ondas VHF viajan en línea recta. Si hay una montaña entre la antena y tú, no te oirán. La altura es tu aliada: a mayor altitud, mayor alcance (1.23 1.23 ).
- #strong[Separación 8.33 kHz]: El espacio aéreo está saturado. Para meter más canales, se redujo el ancho de banda. Asegúrate de que tu radio es "8.33 compliant" o no podrás sintonizar muchas frecuencias modernas.
- #strong[Squelch]: Es la "puerta de ruido". Ajústalo justo hasta que desaparezca el ruido de fondo ("siseo"). Si lo cierras demasiado, bloquearás señales débiles pero importantes.
- #strong[Bloqueo]: En valles profundos, puedes perder contacto con la red de repetidores. Ten previsto un plan de comunicaciones (o un relé con otro avión) si vuelas bajo en montaña.
- #strong[Frecuencias clave]: 121,500 MHz (emergencia internacional, escucha permanente). 122,600 / 123,375 / 123,400 MHz (vuelo a vela). 123,450 MHz (charla entre pilotos). 123,500 MHz (aeródromo no controlado genérico). FIS regionales: consultar AIP España GEN 3.3.
- #strong[Transpondedor (XPDR)]: Responde automáticamente al radar secundario (SSR). Códigos: #strong[7000] (VFR estándar), #strong[7600] (fallo de radio --- NORDO), #strong[7700] (emergencia activa). Obligatorio en zonas TMZ (SERA.6005 b) --- descritas en AIP-España ENR 2.1, carta ENR 6--- y donde lo exijan la clase de espacio aéreo o el AIP (ENR 1.6): clases A y C, y D generalmente. Botón #strong[IDENT]: solo cuando lo pida el ATC.

]
#show: appendices.with("Apéndices", hide-parent: true)
#heading(level: 1, numbering: none)[Apéndices]
= Syllabus Oficial EASA - Comunicaciones
<syllabus-oficial-easa---comunicaciones>
Este es el programa oficial de la asignatura Comunicaciones para la licencia SPL, conforme al AMC1 SFCL.130.

- 4.1. Definiciones.

- 4.2. Comunicaciones VFR:

  - 4.2.1. Comunicaciones VFR en aeródromos no controlados.
  - 4.2.2. Comunicaciones VFR en aeródromos controlados.
  - 4.2.3. Comunicaciones VFR con ATC (en ruta).

- 4.3. Procedimientos operativos generales.

- 4.4. Términos de información meteorológica relevantes (VFR).

- 4.5. Acciones ante fallo de comunicaciones.

- 4.6. Procedimientos de socorro (Distress) y urgencia (Urgency).

- 4.7. Principios generales de propagación VHF y asignación de frecuencias.

Este manual sigue punto por punto este syllabus. Si lo has leído entero, tienes todo lo que el examen teórico puede pedirte en comunicaciones.

== Ponte a prueba
<ponte-a-prueba>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/04-comunicaciones/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

= Códigos Q esenciales para el piloto de planeador
<códigos-q-esenciales-para-el-piloto-de-planeador>
Los #strong[códigos Q] son abreviaturas de tres letras que empiezan por «Q», nacidas para simplificar las comunicaciones en código Morse. Solo unos pocos han sobrevivido en el VHF moderno y en la documentación aeronáutica.

Como piloto de planeador los verás sobre todo en dos sitios: #strong[altimetría] (QNH, QFE) y #strong[radiogoniometría] (QDM, QDR), más el código de pista #strong[QFU]. Los cinco de uso real en vuelo a vela están en las tablas siguientes.

== Códigos de altimetría
<códigos-de-altimetría>
#table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([Código], [Significado],),
  table.hline(),
  [#strong[QNH]], [Reglaje de la subescala del altímetro para indicar la altitud sobre el nivel medio del mar (MSL). Es el reglaje estándar para VFR por debajo de la altitud de transición. Con QNH, el altímetro muestra la altitud AMSL en vuelo, que es la que necesitas para respetar los techos de los espacios aéreos. Cuando el ATC te facilite un QNH, repite el valor numérico completo; no basta con «Recibido».],
  [#strong[QFE]], [Presión atmosférica en la elevación del aeródromo o en el umbral de pista. Con el altímetro calado a QFE, marca cero pies en tierra en ese aeródromo. En vuelo indica la altura sobre ese aeródromo de referencia, no sobre el terreno que estás sobrevolando. Poco habitual en la aviación europea actual; el QNH es el ajuste de referencia en las comunicaciones ATS.],
)
== Códigos de radiogoniometría y pista
<códigos-de-radiogoniometría-y-pista>
Aparecen cuando pides orientación a una estación de tierra mediante radiogoniómetro (VDF --- #emph[VHF Direction Finding]), o cuando se informa sobre la pista en uso.

#table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([Código], [Significado],),
  table.hline(),
  [#strong[QDM]], [Rumbo magnético para dirigirse #strong[hacia] la estación transmisora.],
  [#strong[QDR]], [Rumbo magnético #strong[desde] la estación (marcación o radial).],
  [#strong[QFU]], [Dirección magnética de la pista en uso. Es el número de pista multiplicado por diez (pista 23 → QFU 230°). Aparece en comunicaciones AFIS o en campos con mucho ruido de fondo donde el número de pista puede confundirse.],
)
#block[
#callout(
body: 
[
En travesía con visibilidad reducida o tras una desorientación, pedir un QDM al FIS más cercano es una herramienta de navegación válida y recomendable. No la reserves solo para emergencias: úsala si tienes dudas sobre tu posición.

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
= Glosario de términos
<glosario-de-términos>
Acrónimos y términos técnicos de comunicaciones aeronáuticas para la licencia SPL, según normativa EASA y OACI.

/ #strong[AFIL (Airborne Flight Plan --- Plan de Vuelo en Vuelo)]: #block[
Plan de vuelo presentado desde el aire, sin haberlo tramitado antes del despegue. El piloto contacta con la dependencia ATC o FIS durante el vuelo para dar los datos del plan y solicitar entrada en espacio controlado. (Mencionado en: cap. 3)
]

/ #strong[AFIS (Aerodrome Flight Information Service)]: #block[
Servicio de información de aeródromo. El operador AFIS da a los pilotos información sobre viento, pista en uso y tráfico conocido, pero no emite autorizaciones ni controla el tráfico. La separación sigue siendo responsabilidad del piloto al mando. (Mencionado en: cap. 2)
]

/ #strong[AIREP (Aircraft Report --- Informe Meteorológico en Vuelo)]: #block[
Informe meteorológico oral que el piloto transmite por radio al FIS o ATC al encontrar condiciones peligrosas no pronosticadas: turbulencia fuerte, engelamiento severo, ondas orográficas intensas, tormentas o ceniza volcánica. Obligatorio conforme al Reglamento SERA y la normativa EASA Part-SAO. (Mencionado en: cap. 6)
]

/ #strong[ATC (Control de Tránsito Aéreo / Air Traffic Control)]: #block[
Servicio de tránsito aéreo responsable de dirigir el tráfico de aeronaves para prevenir colisiones entre aeronaves y entre estas y los obstáculos en el área de maniobras, así como de organizar y agilizar el flujo del tránsito aéreo. (Mencionado en: cap. 1, cap. 2, cap. 3, cap. 4, cap. 5, cap. 7)
]

/ #strong[ATIS (Automatic Terminal Information Service --- Servicio Automático de Información Terminal)]: #block[
Grabación de voz en bucle continuo en una frecuencia VHF propia del aeródromo. Informa de la pista en servicio, condiciones meteorológicas (viento, visibilidad, nubes, QNH) e información operativa (obras, NOTAM, etc.). Cada boletín lleva una letra del alfabeto fonético que cambia cuando hay novedades significativas. Escúchalo antes de llamar a la Torre. (Mencionado en: cap. 6)
]

/ #strong[ATS (Servicios de Tránsito Aéreo / Air Traffic Services)]: #block[
Término genérico que engloba el control de tránsito aéreo (ATC), el servicio de información de vuelo (FIS) y el servicio de alerta. (Mencionado en: cap. 3, cap. 7, cap. 8)
]

/ #strong[Autoinformación (broadcast)]: #block[
En aeródromos no controlados, cada piloto transmite voluntariamente su posición, altitud e intenciones en la frecuencia del aeródromo. No hay interlocutor que emita autorizaciones: la separación depende de todos los pilotos en la frecuencia. (Mencionado en: cap. 2)
]

/ #strong[CAVOK (Ceiling And Visibility OK)]: #block[
Término meteorológico aeronáutico que indica condiciones VFR óptimas: visibilidad horizontal de 10 km o más, ausencia de nubes por debajo de 5.000 ft (o la altitud mínima de sector, la mayor de ambas), ausencia de cumulonimbos (CB) o cúmulos en torre (TCU), y ausencia de fenómenos significativos. (Mencionado en: cap. 6)
]

/ #strong[Colación (readback)]: #block[
El piloto repite textualmente al controlador las instrucciones o autorizaciones recibidas, confirmando que las ha escuchado y entendido. Obligatoria para autorizaciones de pista, rumbos, altitudes, QNH, códigos de transpondedor y cambios de frecuencia. Responder solo «Recibido» o «Wilco» en estos casos es una desviación del procedimiento OACI/EASA. (Mencionado en: cap. 1, cap. 3)
]

/ #strong[CTR (Zona de control / Control Zone)]: #block[
Espacio aéreo controlado que se extiende hacia arriba desde la superficie terrestre hasta un límite superior definido, establecido para proteger las trayectorias de las aeronaves en despegue y aterrizaje. (Mencionado en: cap. 3)
]

/ #strong[EOBT (Hora estimada fuera de calzos / Estimated Off-Block Time)]: #block[
Hora prevista en que la aeronave inicia el movimiento para la salida (rodaje o remolque), constituyendo la referencia para calcular los plazos de presentación de los planes de vuelo. (Mencionado en: cap. 3)
]

/ #strong[FIS (Servicio de Información de Vuelo / Flight Information Service)]: #block[
Servicio cuya finalidad es facilitar asesoramiento e información útiles para la realización segura y eficaz de los vuelos, sin proporcionar instrucciones de control ni separación obligatoria. (Mencionado en: cap. 4)
]

/ #strong[FPL (Flight Plan --- Plan de Vuelo)]: #block[
Datos del vuelo previsto que el piloto presenta ante las autoridades ATS antes de operar donde se preste servicio de control de tránsito aéreo (clases B, C y D, o aeródromos controlados; en clase E el VFR no necesita plan de vuelo, ni radio, ni autorización). Incluye tipo de aeronave, indicativo, aeródromo de origen y destino, ruta prevista, nivel de crucero y hora estimada. (Mencionado en: cap. 3)
]

/ #strong[Interceptación (interception)]: #block[
Maniobra por la que una aeronave militar identifica a una aeronave civil y le da instrucciones mediante señales visuales o radio, regulada por SERA.11015. La aeronave interceptada debe seguir las instrucciones visuales del interceptor, notificarlo al ATS si es posible, intentar contacto en 121,5 MHz y seleccionar 7700 en el transpondedor; las instrucciones del interceptor prevalecen sobre las de cualquier otra fuente mientras se solicita aclaración. (Mencionado en: cap. 8)
]

/ #strong[MAYDAY]: #block[
Señal internacional de socorro por radio, repetida tres veces. Se usa solo cuando hay peligro grave e inminente y se necesita asistencia inmediata. Impone silencio de radio absoluto en la frecuencia a todas las estaciones no implicadas. Usarlo de forma falsa o maliciosa es una infracción muy grave según la normativa EASA. (Mencionado en: cap. 5, cap. 8)
]

/ #strong[METAR (Meteorological Aerodrome Report)]: #block[
Informe meteorológico observacional codificado de un aeródromo que se emite a intervalos regulares (30 o 60 minutos), reportando viento, visibilidad, nubes, temperatura, punto de rocío y presión. (Mencionado en: cap. 4, cap. 6)
]

/ #strong[NORDO (No Radio)]: #block[
Situación en que una aeronave ha perdido todas las comunicaciones bidireccionales por radio. El procedimiento: seleccionar 7600 en el transpondedor, mantenerse en VMC, aterrizar en el aeródromo adecuado más cercano y notificar por teléfono al aterrizar. (Mencionado en: cap. 7)
]

/ #strong[OACI (Organización de Aviación Civil Internacional / ICAO)]: #block[
Agencia especializada de las Naciones Unidas creada en 1944 para establecer las normas y métodos recomendados (SARPS) que garanticen la seguridad, protección, regularidad y eficiencia de la aviación civil global. (Mencionado en: cap. 1)
]

/ #strong[PAN PAN]: #block[
Señal internacional de urgencia por radio, repetida tres veces. Se usa cuando hay un problema serio de seguridad que necesita atención prioritaria del ATC, pero sin peligro grave e inminente ni necesidad de salvamento inmediato. A diferencia del MAYDAY, no impone silencio de radio al resto del tráfico. (Mencionado en: cap. 5, cap. 8)
]

/ #strong[PTT (Push-to-Talk --- Pulsar para Hablar)]: #block[
Botón de transmisión. Al pulsarlo, la radio pasa de recepción a emisión. Al soltarlo, vuelve a escuchar. En planeadores suele estar en la palanca de mando. Si se queda atascado, provoca la situación de micrófono bloqueado. (Mencionado en: cap. 1, cap. 5)
]

/ #strong[QDM]: #block[
Código Q con el rumbo magnético que debe seguir la aeronave para llegar a la estación de radiogoniometría (VDF). Si estás desorientado, pide un QDM al FIS y te darán el rumbo para llegar a la estación. (Mencionado en: apéndice)
]

/ #strong[QFE]: #block[
Código Q con la presión exacta a la altura de la pista del aeródromo. Con el QFE en el altímetro, este marca cero en la cabecera de pista: indica altura sobre el campo, no altitud. Está en desuso en la aviación europea, salvo operaciones muy locales. (Mencionado en: cap. 1, cap. 6)
]

/ #strong[QNH]: #block[
Reglaje altimétrico que ajusta el altímetro para indicar la altitud sobre el nivel del mar en condiciones ISA. Es la referencia estándar para el vuelo VFR. (Mencionado en: cap. 1, cap. 6)
]

/ #strong[RMZ (Zona de radio obligatoria / Radio Mandatory Zone)]: #block[
Espacio aéreo de dimensiones definidas en el que el equipo de radio y su uso son obligatorios: exige mantener escucha permanente en la frecuencia establecida y comunicar intenciones antes de entrar. (Mencionado en: cap. 4)
]

/ #strong[SAR (Search and Rescue --- Búsqueda y Salvamento)]: #block[
Servicio de búsqueda y salvamento aéreo. Se activa cuando una aeronave no contacta con los servicios ATS en el tiempo previsto tras el aterrizaje, o ante un MAYDAY. El piloto al mando debe notificar la finalización del vuelo para no movilizar los recursos SAR innecesariamente. (Mencionado en: cap. 4, cap. 7, cap. 8)
]

/ #strong[SERA (Standardised European Rules of the Air --- Reglas Europeas Estandarizadas del Aire)]: #block[
Reglamento de Ejecución (UE) n.º 923/2012 con las reglas del aire comunes para toda la Unión Europea. Define procedimientos de comunicaciones, señales luminosas de la Torre, códigos de transpondedor de emergencia, la obligatoriedad de la colación y otros procedimientos operativos de aplicación directa en Europa. (Mencionado en: cap. 1, cap. 7)
]

/ #strong[Squawk]: #block[
Código de cuatro dígitos en base octal (0--7) que el transpondedor emite al ser interrogado por el radar secundario (SSR), permitiendo al controlador identificar la aeronave en pantalla. Código VFR estándar en Europa: 7000. Los códigos 7700 (emergencia), 7600 (NORDO) y 7500 (interferencia ilícita) son de uso exclusivo en esas situaciones. (Mencionado en: cap. 4, cap. 9)
]

/ #strong[SSR (Secondary Surveillance Radar --- Radar Secundario de Vigilancia)]: #block[
Radar que interroga a los transpondedores a bordo y obtiene información codificada: código #strong[squawk] (Modo A), altitud barométrica (Modo C) e identidad extendida (Modo S). Complementa al radar primario añadiendo en pantalla la etiqueta con número de vuelo y altitud. (Mencionado en: cap. 7, cap. 9)
]

/ #strong[TAF (Terminal Aerodrome Forecast)]: #block[
Pronóstico meteorológico codificado que describe las condiciones meteorológicas esperadas en un aeródromo específico durante un periodo de tiempo determinado (típicamente 9, 24 o 30 horas). (Mencionado en: cap. 4, cap. 6)
]

/ #strong[TMZ (Zona de transpondedor obligatorio / Transponder Mandatory Zone)]: #block[
Espacio aéreo de dimensiones definidas en el que es obligatorio portar y operar un transpondedor con transmisión de altitud (Modo C o S). (Mencionado en: cap. 9)
]

/ #strong[Transpondedor (XPDR --- Transponder)]: #block[
Equipo de a bordo que responde automáticamente a las interrogaciones del radar secundario (SSR) emitiendo un código #strong[squawk] y, según el modo, la altitud barométrica o datos extendidos de identificación. Opera en la banda UHF (1.030/1.090 MHz), independientemente de la radio de voz. Imprescindible para ser visible por el TCAS de otros tráficos. (Mencionado en: cap. 4, cap. 7, cap. 9)
]

/ #strong[Transmisión a ciegas (blind transmission)]: #block[
Procedimiento para cuando sospechas que tu receptor ha fallado pero el emisor sigue funcionando. Transmites regularmente posición e intenciones en la frecuencia correcta, precediendo cada mensaje con «Transmitiendo a ciegas debido a fallo del receptor», aunque no llegue ninguna respuesta. (Mencionado en: cap. 7)
]

/ #strong[TWR (Torre de Control de Aeródromo)]: #block[
Dependencia ATS que controla los vuelos en la zona de tránsito y el área de maniobras. Emite autorizaciones de rodaje, alineamiento, despegue y aterrizaje, y señales luminosas a aeronaves sin radio. (Mencionado en: cap. 3)
]

/ #strong[VAC (Visual Approach Chart --- Carta de Aproximación Visual)]: #block[
Carta de un aeródromo concreto con los puntos de notificación visual del CTR, frecuencias de la Torre, rutas preferentes de acceso y salida VFR y obstáculos del entorno. Publicada en el AIP España para cada aeródromo. (Mencionado en: cap. 3)
]

/ #strong[VDF (VHF Direction Finding --- Radiogoniometría VHF)]: #block[
Sistema que determina el rumbo de una aeronave a partir de la dirección de su señal radio. Los códigos Q asociados (QDM, QDR, QTE) permiten al FIS indicar al piloto el rumbo para llegar o alejarse de la estación, útil en caso de desorientación. (Mencionado en: cap. 5, apéndice)
]

/ #strong[VFR (Reglas de vuelo visual / Visual Flight Rules)]: #block[
Conjunto de normas que rigen los vuelos operados con referencia visual constante al terreno, recayendo la responsabilidad de la separación en el principio de "ver y evitar" bajo mínimos meteorológicos visuales (VMC). (Mencionado en: cap. 2, cap. 3)
]

/ #strong[VHF (Very High Frequency --- Muy Alta Frecuencia)]: #block[
Banda de radiofrecuencia entre 30 MHz y 300 MHz. Las comunicaciones aeronáuticas civiles de voz van en la sub-banda de 118,000 a 136,975 MHz con modulación de amplitud (AM). Las ondas VHF viajan en línea recta (#strong[line of sight]), por lo que el alcance crece con la altitud. Espaciado de canales en Europa: 8,33 kHz desde el Reglamento (UE) n.º 1079/2012. (Mencionado en: cap. 1, cap. 9)
]

/ #strong[VMC (Visual Meteorological Conditions --- Condiciones Meteorológicas Visuales)]: #block[
Condiciones con visibilidad y distancia a nubes iguales o superiores a los mínimos reglamentarios para VFR en la clase de espacio aéreo correspondiente. Mantenerse en VMC es la prioridad absoluta en situación NORDO. Meterse en nubes bajo VFR es una de las causas más frecuentes de accidente en aviación general. (Mencionado en: cap. 7)
]

/ #strong[VOLMET]: #block[
Emisión meteorológica continua para aeronaves en vuelo. Retransmite METAR, TAF y SIGMET de varios aeropuertos de una región en bucle. A diferencia del ATIS, que cubre un solo aeródromo, el VOLMET permite evaluar condiciones en múltiples alternos sin saturar la frecuencia de control. (Mencionado en: cap. 6)
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
