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

// El hueco entre entradas debe superar claramente al interlineado (0.65em) o el
// ojo no distingue dónde acaba una definición y empieza la siguiente. Se usa el
// mismo valor que las listas del cuerpo, por coherencia.
#show terms.item: it => block(breakable: false, below: 0.95em, width: 100%)[
  #text(weight: "bold")[#it.term]#h(0.35em)#sym.dash.em#h(0.35em)#_glosario-descripcion(it.description)
]
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
  title: [Meteorología],
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

#heading(level: 1, numbering: none)[Meteorología]
<meteorología>
Bienvenido a la versión digitalizada de este manual de formación SPL.

#heading(level: 1, numbering: none)[Información Legal y Licencia]
<información-legal-y-licencia>
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

#heading(level: 1, numbering: none)[Dedicatoria]
<dedicatoria>
#quote(block: true)[
#strong[A la memoria de Iñaqui Ulibarri García de la Cueva]

El maestro que nos regaló las alas y nos enseñó a volar con sabiduría.

Aún te sentimos en el asiento de atrás; nos acompañas en cada térmica y en cada decisión al mando que tomamos recordando tus lecciones.

Gracias por dejarnos tu inmensa pasión como la mejor de las herencias.
]

#quote(block: true)[
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

#heading(level: 1, numbering: none)[Índice de ilustraciones]
<índice-de-ilustraciones>
#strong[#emph[Tema 3 de 9 del examen teórico para la Licencia de Piloto de Planeador (SPL)]]

Hay pilotos que miran el cielo y ven nubes. Hay pilotos que miran el cielo y ven información.

Un planeador vuela sin motor, sin radar y sin potencia para escapar de lo que el tiempo tiene preparado. La única ventaja real del piloto de vela es anticiparse: reconocer el frente doce horas antes, saber que la virga esconde un downburst o identificar la inversión térmica invisible que limita el vuelo a mil pies aunque el sol caliente.

Diez capítulos cubren desde la física de la atmósfera hasta la lectura operativa de METAR, TAF y SIGWX, pasando por frentes, termodinámica y los peligros que la meteorología reserva para quien no la conoce.

El cielo habla. Aprende a escucharlo antes de despegar.

= La atmósfera
<la-atmósfera>
#quote(block: true)[
Sin entender la atmósfera, ningún mapa de previsión tiene sentido. En este capítulo aprenderás qué es la Atmósfera Estándar Internacional (ISA), por qué la presión, la temperatura y la densidad del aire cambian con la altitud, y cómo esos cambios afectan directamente al rendimiento de tu planeador y a tu propia fisiología en vuelo.
]

== La atmósfera estándar internacional (ISA)
<la-atmósfera-estándar-internacional-isa>
Para estandarizar el diseño de aeronaves y la calibración de instrumentos en todo el mundo, la Organización de Aviación Civil Internacional (OACI) definió la Atmósfera Estándar Internacional (ISA, por sus siglas en inglés: #strong[International Standard Atmosphere]). Es un modelo atmosférico ideal que asume #strong[aire seco] (0 % de humedad) y establece valores medios teóricos, ya que raramente encontrarás un día ISA "puro" en la realidad.

A nivel del mar (MSL), la atmósfera ISA establece las siguientes condiciones de referencia (#ref(<fig-03-cap01-atmosfera-isa>, supplement: [Figura])):

- Temperatura: 15 °C
- Presión atmosférica: 1013,25 hPa (equivalente a 29,92 inHg o 760 mm Hg)
- Densidad del aire: 1,225 kg/m#super[3]

El modelo ISA asume 0 % de humedad, lo que en la práctica significa que tampoco define un #strong[punto de rocío] (#strong[dew point]). En la realidad, el punto de rocío es la temperatura a la que hay que enfriar una masa de aire para que el vapor de agua que contiene comience a condensarse. Cuando la temperatura del aire y el punto de rocío se aproximan o igualan, la humedad relativa alcanza el 100 % y el aire se satura: se forman nubes o niebla. Para el piloto de planeador, la diferencia entre temperatura y punto de rocío es el dato clave para estimar la base de los cúmulos y la probabilidad de niebla matinal (ver Capítulo 3: Termodinámica).

#figure([
#box(image("imagenes/03-cap01-atmosfera-isa.jpg"))
], caption: figure.caption(
position: bottom, 
[
Temperaturas de la atmósfera estándar ISA
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap01-atmosfera-isa>


== Gradientes Estándar en Aviación
<gradientes-estándar-en-aviación>
A medida que ganamos altura, las condiciones atmosféricas cambian según unos patrones establecidos en el modelo ISA, conocidos como gradientes estándar. Estas reglas te permiten hacer cálculos mentales rápidos durante el vuelo.

- #strong[Gradiente térmico estándar]: La temperatura en la troposfera disminuye a razón de 2 °C por cada 1.000 pies de ascenso (o 6,5 °C por cada 1.000 metros).
- #strong[Gradiente de presión estándar]: La presión atmosférica disminuye aproximadamente 1 hPa por cada 30 pies de ascenso en las capas bajas de la atmósfera.

#block[
#callout(
body: 
[
Memoriza estas tres equivalencias del gradiente estándar ISA: #strong[2 °C / 1.000 pies] para la temperatura, y #strong[1 hPa / 30 pies] para la presión. En sistema métrico, si subes 90 metros, la presión cae 10 hPa; en pies, si subes 3.000 pies, cae 100 hPa. Si despegas de un aeródromo a 2.000 pies con QNH 1013 hPa y 20 °C, puedes estimar que a 5.000 pies la temperatura será unos 6 °C más fría (14 °C) y la presión habrá bajado unos 100 hPa.

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
== Densidad del aire y rendimiento del planeador
<densidad-del-aire-y-rendimiento-del-planeador>
El planeador vuela gracias a las moléculas de aire que inciden sobre sus alas. La sustentación (#strong[lift]) depende directamente de la densidad del aire.

Una menor densidad del aire (lo que equivale a una mayor "altitud de densidad") significa que hay menos moléculas interactuando con las alas, reduciendo el rendimiento general del planeador. Ciertas condiciones meteorológicas reducen peligrosamente la densidad del aire:

- Altas temperaturas (el aire se expande y se hace menos denso).
- Baja presión atmosférica.
- Alta humedad (el vapor de agua es menos denso que el aire seco).

#block[
#callout(
body: 
[
Un día caluroso en un aeródromo elevado (alta altitud de densidad) empeora drásticamente el rendimiento: el avión remolcador trepará mucho más despacio, el planeador necesitará más pista para despegar y en vuelo tendrás menor sustentación para el mismo ángulo de ataque.

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
== Presión parcial de oxígeno e hipoxia
<presión-parcial-de-oxígeno-e-hipoxia>
Aunque la proporción de oxígeno en el aire se mantiene constante en un 21 % a lo largo de la troposfera, la reducción de la presión atmosférica al ganar altura hace que la presión a la que ese oxígeno entra en nuestros pulmones disminuya. A 18.000 pies, la presión atmosférica es la mitad que a nivel del mar.

#block[
#callout(
body: 
[
La falta prolongada de oxígeno en los tejidos se conoce como #strong[hipoxia]. Dado su impacto crítico en la seguridad del vuelo (pérdida del conocimiento, degradación visual), los síntomas detallados, el cálculo del Tiempo de Conciencia Útil (TUC) y el uso de equipos de oxígeno se estudian en profundidad en el #strong[Libro 2 --- Factores humanos], capítulo 4.

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
#strong[Resumen del Capítulo: La Atmósfera]

- #strong[Atmósfera ISA]: Modelo ideal para estandarizar instrumentos y rendimiento (15°C, 1013,25 hPa, 0% humedad a MSL). Raramente encontrarás un día ISA "puro", pero es la referencia universal.
- #strong[Gradientes Estándar]: La temperatura cae 2°C por cada 1.000 ft. La presión cae 1 hPa por cada 30 ft #strong[o por cada 9 metros]. Ambas equivalencias son útiles: la primera en entornos anglosajones (altímetros en pies), la segunda cuando trabajas con altitudes en metros.
- #strong[Densidad y Rendimiento]: El planeador vuela gracias a las moléculas de aire. Menor densidad (alta elevación o día caluroso) significa menos sustentación y peor rendimiento: necesitas más pista para despegar y corres más con el mismo ángulo de ataque.
- #strong[Presión parcial de O#sub[2]]: Aunque la proporción de oxígeno se mantiene (21 %), la presión a la que entra en tus pulmones cae drásticamente con la altura, provocando hipoxia (cuyos efectos fisiológicos se detallan en el #strong[Libro 2 --- Factores humanos], capítulo 4).

= Viento
<viento>
#quote(block: true)[
El viento es la materia prima del vuelo a vela: a veces tu aliado, siempre un factor de seguridad que debes conocer y respetar. En este capítulo aprenderás por qué sopla el viento, cómo la rotación terrestre y el terreno lo transforman, y cuáles son los vientos locales ---anabáticos, catabáticos, Foehn, brisa marina--- que definen la meteorología de cada aeródromo.
]

== El Motor del Viento: La Fuerza de Gradiente
<el-motor-del-viento-la-fuerza-de-gradiente>
El viento es fundamentalmente aire en movimiento, y su motor principal son las diferencias de presión atmosférica en distintas zonas.

El aire fluye de forma natural desde las zonas de alta presión (anticiclones) hacia las zonas de baja presión (depresiones o borrascas). Esta tendencia a igualar las presiones genera lo que conocemos como #strong[Fuerza del Gradiente de Presión] (Fg). La regla es sencilla: cuanto mayor es la diferencia de presión en una distancia corta, mayor es la fuerza del gradiente. En los mapas meteorológicos, esto se visualiza con las isobaras (líneas que unen puntos de igual presión): cuanto más juntas estén las isobaras, más fuerte soplará el viento (#ref(<fig-03-cap02-gradiente-isobaras>, supplement: [Figura])).

#figure([
#box(image("imagenes/03-cap02-gradiente-isobaras.jpg"))
], caption: figure.caption(
position: bottom, 
[
La fuerza del gradiente de presión y las isobaras
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap02-gradiente-isobaras>


== La Fuerza de Coriolis y el Viento Geostrófico
<la-fuerza-de-coriolis-y-el-viento-geostrófico>
Si la Tierra no rotase, el viento fluiría directamente de las altas a las bajas presiones cruzando las isobaras perpendicularmente. Sin embargo, debido a la rotación terrestre, aparece una fuerza aparente llamada #strong[Fuerza de Coriolis] (Fc).

En el hemisferio norte, la fuerza de Coriolis desvía cualquier masa de aire en movimiento hacia la #strong[derecha]. A medida que el viento acelera impulsado por el gradiente de presión, Coriolis tira de él hacia la derecha. Por encima de unos 1.000 metros sobre el terreno (nivel de fricción), ambas fuerzas (gradiente y Coriolis) se equilibran. El resultado es que el viento deja de cruzar las isobaras y acaba soplando #strong[paralelo] a ellas. A este viento libre en altura se le denomina #strong[viento geostrófico].

#block[
#callout(
body: 
[
La Ley de Buys Ballot es una regla clásica que resume este efecto: en el hemisferio norte, si te pones de espaldas al viento, el centro de baja presión siempre estará a tu lado izquierdo.

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
== El Efecto de la Fricción en Superficie
<el-efecto-de-la-fricción-en-superficie>
Cerca del suelo (por debajo de esos 1.000 metros), entra en juego un tercer actor: el rozamiento con el terreno o fricción superficial. Los árboles, edificios, montañas y la propia textura del suelo "frenan" el flujo del aire.

Al reducirse la velocidad del viento por esta fricción, el efecto de Coriolis (que depende de la velocidad) también disminuye. Sin embargo, la fuerza del gradiente de presión se mantiene intacta. Como Coriolis ya no puede contrarrestar del todo al gradiente, el viento en superficie se desvía y #strong[cruza las isobaras hacia la baja presión] (típicamente con un ángulo de unos 30 grados respecto a las isobaras).

#block[
#callout(
body: 
[
Debido a la fricción, cuando te acercas al suelo para aterrizar experimentarás el "gradiente de viento" ( en capa límite). En los últimos metros, el viento no solo será más flojo que en el circuito, sino que su dirección cruzará más hacia la baja presión. Debes mantener tu velocidad de aproximación con un margen de seguridad adecuado para evitar la pérdida de sustentación en la recogida (#strong[flare]).

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
#box(image("imagenes/03-cap02-calles-nubes.jpg"))
], caption: figure.caption(
position: bottom, 
[
Circulación a través de una calle de nubes
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap02-calles-nubes>


#figure([
#box(image("imagenes/03-cap02-convergencia-topografica.jpg"))
], caption: figure.caption(
position: bottom, 
[
Convergencia inducida por flujo alrededor de topografía (vista desde arriba)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap02-convergencia-topografica>


== Brisas Locales: El Motor en la Montaña
<brisas-locales-el-motor-en-la-montaña>
El calentamiento desigual del terreno por el sol genera vientos locales fundamentales para el piloto de planeador, especialmente en áreas montañosas:

- #strong[Vientos Anabáticos (Brisas de Valle)]: De día, el sol calienta antes las laderas y crestas de las montañas que el fondo del valle. El aire en contacto con las cimas se calienta, se hace menos denso y sube, "succionando" aire más fresco del fondo del valle hacia arriba a lo largo de las vertientes. Estas brisas anabáticas son excelentes disparadores de corrientes térmicas (#strong[lift]). Busca siempre las laderas orientadas al sol (solanas) (#ref(<fig-03-cap02-vuelo-ladera>, supplement: [Figura])).
- #strong[Vientos Catabáticos (Brisas de Montaña)]: Al atardecer y durante la noche ocurre lo inverso. Las cimas se enfrían rápidamente emitiendo radiación al espacio. El aire frío y denso "resbala" ladera abajo acumulándose en el fondo del valle (#ref(<fig-03-cap02-ciclo-anabatico-catabatico>, supplement: [Figura])).

#figure([
#box(image("imagenes/03-cap02-ciclo-anabatico-catabatico.jpg"))
], caption: figure.caption(
position: bottom, 
[
Ciclo diurno de brisas de ladera: anabática (mañana) y catabática (tarde/noche)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap02-ciclo-anabatico-catabatico>


#figure([
#box(image("imagenes/03-cap02-vuelo-ladera.jpg"))
], caption: figure.caption(
position: bottom, 
[
Zona de ascendencia para planeo de ladera
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap02-vuelo-ladera>


#block[
#callout(
body: 
[
A última hora de la tarde, cuando los fríos vientos catabáticos bajan por ambas laderas de un valle, "estrujan" el aire residual cálido que queda en el centro, forzándolo a subir. Este fenómeno se conoce como #strong[restitución]. Crea zonas muy amplias y suaves de ascendencia en el centro del valle, permitiendo prolongar vuelos al atardecer en aire completamente calmado.

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
== Efecto Foehn y Stau: Cuando la Montaña Calienta el Aire
<efecto-foehn-y-stau-cuando-la-montaña-calienta-el-aire>
Cuando el viento húmedo del Atlántico choca con una cordillera, ocurre algo que parece casi magia: el mismo aire que llega frío y cargado de nubes por barlovento puede aterrizar en el valle de sotavento seco, transparente y diez grados más caliente. Esto es el #strong[efecto Foehn] (#strong[Foehn effect]), y su gemelo el #strong[Stau] (#strong[Stau effect]), y tienen consecuencias directas para el piloto.

El mecanismo es asimétrico: en la ladera de #strong[barlovento] (la que recibe el viento), el aire asciende enfriándose primero al ritmo DALR (3 °C/1.000 ft) hasta que alcanza el punto de rocío, condensa y precipita. A partir de ese nivel, sube ya saturado a solo 1,5 °C/1.000 ft (SALR), cediendo calor latente a la atmósfera. En sotavento, el aire ya ha perdido su humedad al barlovento y desciende #strong[seco] durante todo el recorrido, calentándose al DALR completo (3 °C/1.000 ft). El resultado: llega al valle de sotavento más caliente que cuando partió (#ref(<fig-03-cap02-fohn-stau>, supplement: [Figura])). Con desniveles de 1.500--2.000 m, la diferencia puede superar los 10--15 °C entre los dos valles.

La #strong[pared de Foehn] (#strong[Foehn wall]) es la acumulación de nubes que permanece estacionaria sobre la cresta del lado de barlovento, marcando visualmente la zona de precipitación. En sotavento: ventana despejada, temperatura alta y humedad baja. El #strong[Stau] es el nombre del mismo proceso visto desde el barlovento: acumulación de nubes y precipitación intensa mientras el otro valle disfruta del sol.

#figure([
#box(image("imagenes/03-cap02-fohn-stau.jpg"))
], caption: figure.caption(
position: bottom, 
[
Mecanismo del efecto Foehn: ascenso húmedo en barlovento y descenso seco en sotavento
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap02-fohn-stau>


Un ejemplo cercano: los naranjos y limoneros del #strong[Valle del Tiétar] (al pie sur de la Sierra de Gredos, en Ávila y Cáceres) deben su microclima mediterráneo al Foehn que baja por la vertiente de sotavento cuando el viento viene del norte. Mientras en el páramo castellano hace frío, en el Tiétar recogen naranjas.

#block[
#callout(
body: 
[
El sotavento de una cordillera bajo un Foehn activo puede esconder rotores de turbulencia severa en los niveles inferiores. No te confíes por ver cielos despejados y temperatura cálida en sotavento: mantén altitud al cruzar cordilleras en estas condiciones y evita las laderas de sotavento a baja altura.

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
Si a pie de pista el termómetro marca varios grados por encima de lo habitual para el mes, la humedad relativa es inusualmente baja y ves una masa de nubes estacionaria sobre la sierra al norte: estás bajo un Foehn. Las bases de nube serán muy altas y las térmicas explosivas. Aprovéchalo, pero vigila los rotores cerca del terreno en el sotavento.

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
== Brisas Marinas y Líneas de Convergencia: El Frente que No Aparece en el Mapa
<brisas-marinas-y-líneas-de-convergencia-el-frente-que-no-aparece-en-el-mapa>
Las #strong[brisas marinas] (#strong[sea breeze]) son el resultado del mismo principio que las brisas de montaña: calentamiento desigual. La tierra se calienta mucho más rápido que el mar durante el día. El aire cálido sobre el continente asciende, y el aire fresco marino avanza tierra adentro para rellenar ese hueco, formando un flujo que puede penetrar decenas de kilómetros al interior (#ref(<fig-03-cap02-brisa-marina>, supplement: [Figura])).

Lo más valioso para el volovelista no es el viento en sí, sino la #strong[línea de convergencia] que genera (#ref(<fig-03-cap02-convergencia-topografica>, supplement: [Figura])). Cuando ese aire frío y húmedo marino topa con la masa cálida y seca continental, se crea un límite nítido ---un minifrente--- donde el aire se ve forzado a ascender. Esa línea avanza lentamente tierra adentro durante la tarde y puede ofrecer ascendencias suaves y continuas durante kilómetros, perfectas para el vuelo de distancia.

#figure([
#box(image("imagenes/03-cap02-brisa-marina.jpg"))
], caption: figure.caption(
position: bottom, 
[
Frente de brisa marina
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap02-brisa-marina>


Identificar la línea de convergencia es cuestión de observación:

- Los cúmulos del lado marino tienen la #strong[base más baja] (aire húmedo, punto de rocío alto) que los del interior (aire seco, bases altas).
- La convergencia a veces genera una franja alargada de cúmulos algo más activos, o incluso una cortina de nubes (#strong[curtain cloud]) a lo largo del límite (#ref(<fig-03-cap02-calles-nubes>, supplement: [Figura])).
- A ras de suelo puede notarse como un cambio repentino de viento y frescor al cruzarla.

#block[
#callout(
body: 
[
En verano, los pilotos que operan desde Fuentemilanos (Segovia) trabajan frecuentemente la convergencia de brisa del SW que penetra desde el Atlántico a través del Sistema Central. La Baja Térmica Peninsular (ver capítulo de Climatología) actúa como un gran aspirador que succiona la brisa marina tierra adentro, creando líneas de convergencia NW--SE que funcionan como autopistas de ascendencias para el cross-country. Revisa modelos RASP o Skysight ---o su equivalente en Topmeteo o Meteo Parapente--- la tarde anterior para anticipar su posición.

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
#strong[Resumen del Capítulo: Viento]

- #strong[El motor del viento]: El aire fluye naturalmente de las Altas (H) a las Bajas (L) presiones debido a la fuerza de gradiente. Cuanto más juntas estén las isobaras, más fuerte soplará.
- #strong[Fuerza de Coriolis]: En el hemisferio norte, la rotación terrestre desvía el viento hacia la derecha. Por eso, en altura, el viento acaba soplando paralelo a las isobaras (viento geostrófico).
- #strong[Efecto de la Fricción]: Cerca del suelo, el rozamiento frena el viento y debilita el efecto Coriolis, haciendo que el viento cruce las isobaras hacia la baja presión. Al aterrizar, espera que el viento cambie de dirección e intensidad en los últimos metros.
- #strong[Brisas Locales]: El sol calienta las laderas antes que el valle, generando brisas ascendentes (anabáticas) de día. De noche, el aire frío baja (catabático). Conocer este ciclo es vital para encontrar ascendencias o evitar descendencias peligrosas en montaña.
- #strong[Efecto Foehn y Stau]: El aire que sube en barlovento precipita y cede calor latente (SALR). Al descender en sotavento ---ya seco--- se calienta al DALR completo, llegando hasta 15 °C más caliente. La "pared de Foehn" marca visualmente la cresta. Cuidado con los rotores en el sotavento.
- #strong[Brisas Marinas y Convergencias]: La brisa marina penetra tierra adentro creando una línea de convergencia (minifrente) con ascendencias excelentes para el cross-country. Identifícala por las diferentes alturas de base de los cúmulos a cada lado y por la franja de nubosidad activa sobre el límite.

= Termodinámica
<termodinámica>
#quote(block: true)[
La termodinámica es el motor invisible del vuelo sin motor: sin estabilidad inestable no hay térmicas, y sin térmicas no hay vuelo de distancia. En este capítulo aprenderás a interpretar la estabilidad atmosférica, a calcular la base de los cúmulos con una operación mental sencilla, a reconocer una inversión térmica y a leer los índices de sondeo que predicen si el día será excelente o decepcionante para volar.
]

== Estabilidad Atmosférica: El Combustible del Vuelo a Vela
<estabilidad-atmosférica-el-combustible-del-vuelo-a-vela>
La estabilidad de la atmósfera define cómo se comporta una masa de aire (una "burbuja" o parcela) cuando es empujada hacia arriba. El vuelo sin motor vive fundamentalmente de la inestabilidad (#ref(<fig-03-cap03-estabilidad>, supplement: [Figura])).

Podemos entenderlo imaginando una pelota en diferentes relieves:

- #strong[Atmósfera Estable]: Si empujas la pelota desde el fondo de un valle subiéndola por la ladera, volverá a caer al centro. En el aire, si el ambiente se enfría lentamente con la altura (gradiente térmico ambiental menor de 1 °C/100m), una burbuja que ascienda se enfriará más rápido que su entorno. Pronto estará más fría (y pesada) que el aire que la rodea, deteniendo su ascenso y hundiéndose de nuevo.
- #strong[Atmósfera Inestable]: Imagina la pelota en equilibrio precario en la cima de un monte; un pequeño empujón hará que caiga rodando sin parar. Si el aire ambiental se enfría muy rápido con la altura (mayor de 1 °C/100m), una burbuja que empiece a subir siempre se mantendrá más caliente (y ligera) que el aire a su alrededor, acelerando su ascenso. Esta es la condición ideal para la formación de fuertes térmicas.
- #strong[Estabilidad Condicional]: Depende de la humedad. Si el aire está seco, es estable; pero si está saturado de humedad, el calor liberado por la condensación (al formar nubes) hace que la burbuja se mantenga caliente y siga subiendo (inestable).

#figure([
#box(image("imagenes/03-cap03-estabilidad.jpg"))
], caption: figure.caption(
position: bottom, 
[
Aire inestable (A) y estable (B) para unos 3000 pies (unos 1000m).
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap03-estabilidad>


== Gradientes Adiabáticos y la Base de las Nubes
<gradientes-adiabáticos-y-la-base-de-las-nubes>
Cuando una burbuja de aire asciende impulsada por la convección, se expande a medida que encuentra menor presión atmosférica en altura. Esta expansión provoca que se enfríe de forma interna (proceso adiabático), sin intercambiar calor con el aire exterior. El ritmo al que se enfría depende de si el aire está seco o saturado de humedad.

- #strong[Gradiente Adiabático Seco (DALR - ]Dry Adiabatic Lapse Rate#strong[)]: Mientras la burbuja no alcance el 100% de humedad, se enfría a un ritmo constante de #strong[3 °C por cada 1.000 pies] (1 °C cada 100 metros).
- #strong[Gradiente Adiabático Saturado (SALR - ]Saturated Adiabatic Lapse Rate#strong[)]: Cuando la burbuja se enfría lo suficiente como para alcanzar su punto de rocío, el vapor de agua comienza a condensarse, formando la base de una nube (Nivel de Condensación por Ascenso o NCA). La condensación libera calor latente dentro de la burbuja. Por tanto, a partir de la base de la nube, la burbuja sigue subiendo, pero se enfría mucho más despacio, típicamente a #strong[1,5 °C por cada 1.000 pies] (0,5 °C cada 100 metros en niveles bajos).

#block[
#callout(
body: 
[
Puedes estimar fácilmente la altura de la base de los cúmulos restando la temperatura del punto de rocío a la temperatura ambiente en el suelo. Como los dejas atrás a razón de unos 2.5 °C por cada 1.000 pies de ascenso conjunto (el DALR menos la caída del punto de rocío), la fórmula es: #strong[\(T#sub[ambiente] - T#sub[rocío]) x 400 = Altitud de la base en pies.]

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
Para aplicar la fórmula, sigue estos pasos antes de cada vuelo:

+ Anota la temperatura ambiente en tierra (T) y la temperatura del punto de rocío (T#sub[rocío]) del METAR o la estación del aeródromo.
+ Calcula la diferencia: ΔT = T − T#sub[rocío].
+ Multiplica: ΔT × 400 = altura estimada de la base de los cúmulos en pies.

#emph[Ejemplo: T = 26 °C, T#sub[rocío] = 16 °C → (26 − 16) × 400 = #strong[4.000 ft] de base.] (véase #ref(<fig-03-cap03-base-cumulos-dalr-nca>, supplement: [Figura]))

#figure([
#box(image("imagenes/03-cap03-base-cumulos-dalr-nca.jpg"))
], caption: figure.caption(
position: bottom, 
[
Cálculo gráfico de la base de los cúmulos: gradiente DALR, punto de rocío y Nivel de Condensación por Ascenso (NCA)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap03-base-cumulos-dalr-nca>


== Inversiones Térmicas: La Tapadera Invisible
<inversiones-térmicas-la-tapadera-invisible>
Normalmente la temperatura disminuye con la altitud, pero en ocasiones ocurre lo contrario: encontramos capas donde #strong[la temperatura del aire aumenta a medida que subimos]. A esto se le llama una inversión térmica.

Una inversión térmica actúa como una tapadera o techo de cristal. Debido a que el aire por encima de la inversión está sorprendentemente caliente, cuando una térmica sube y choca contra esa capa, de repente se encuentra rodeada de aire más caliente (y por tanto más ligero) que ella misma. La térmica pierde su flotabilidad (#strong[buoyancy]) instantáneamente, deteniendo en seco el ascenso.

#block[
#callout(
body: 
[
Las inversiones no solo limitan la altura máxima a la que puedes trepar en un planeador, frenando la convección por completo, sino que también atrapan humo, bruma y humedad industrial cerca de la superficie, reduciendo drásticamente la visibilidad en vuelo por debajo de la capa de inversión.

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
== Convección: El Transporte Vertical de Calor
<convección-el-transporte-vertical-de-calor>
La convección es el proceso por el cual el calor se transporta verticalmente en la atmósfera, y es el mecanismo exacto que forma las térmicas.

El sol no calienta el aire directamente, sino que calienta la superficie de la tierra. Este calentamiento es muy desigual: un campo arado oscuro, una zona rocosa o un pueblo de tejados secos se calentará mucho más rápido que un bosque denso o un lago. El suelo caliente calienta por contacto la capa de aire inmediatamente superior.

Ese aire caliente, ahora menos denso y más ligero, tiende a subir por flotabilidad, formando una corriente convectiva o "térmica".Inicialmente, la burbuja se agarra al terreno por la fricción, aumentando su empuje ascensional hasta que finalmente se desprende y comienza a subir.

#block[
#callout(
body: 
[
Para encontrar las mejores térmicas, busca "fuentes" que se calienten rápido (suelos secos, campos cosechados, zonas rocosas al sol) y "disparadores" o puntos de ruptura que ayuden a la burbuja a desprenderse del suelo, como una cresta de una colina orientada al viento, o una línea de árboles al borde del campo soleado.

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
Los meteorólogos distinguen dos modelos conceptuales de cómo se organiza internamente ese flujo vertical:

- #strong[Modelo burbuja] (#strong[bubble model]): El calor se acumula sobre la fuente hasta que la burbuja se desprende, como si tirases de un globo. El ascenso es intermitente: el núcleo central sube más rápido que los bordes, que presentan subsidencia. El planeador debe buscar y mantenerse en el núcleo para aprovechar el ascenso máximo (#ref(<fig-03-cap03-modelo-burbuja>, supplement: [Figura])).

#figure([
#box(image("imagenes/03-cap03-modelo-burbuja.jpg"))
], caption: figure.caption(
position: bottom, 
[
El modelo de burbuja o anillo de vórtice de una térmica.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap03-modelo-burbuja>


- #strong[Modelo columna o pluma] (#strong[column/plume model]): En fuentes intensas y persistentes (una cantera, un pueblo grande, una ladera orientada al sol toda la mañana), el flujo convectivo es continuo, como el humo de una chimenea. El ascenso es más regular y predecible, ideal para el vuelo de distancia (#ref(<fig-03-cap03-modelo-columna>, supplement: [Figura])).

#figure([
#box(image("imagenes/03-cap03-modelo-columna.jpg"))
], caption: figure.caption(
position: bottom, 
[
El modelo de columna o pluma de una térmica.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap03-modelo-columna>


En los días reales coexisten ambas estructuras. Las primeras horas de la mañana tienden a producir burbujas aisladas; a medida que el calentamiento se consolida, pueden aparecer columnas duraderas. Reconocer cuál predomina ese día mejora el centrado de térmicas y reduce el tiempo perdido fuera de círculo (#ref(<fig-03-cap03-ciclo-vida-termica>, supplement: [Figura])).

#figure([
#box(image("imagenes/03-cap03-ciclo-vida-termica.png"))
], caption: figure.caption(
position: bottom, 
[
Ciclo de vida de una térmica típica con cúmulo.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap03-ciclo-vida-termica>


== Índices de estabilidad: el termómetro del día
<índices-de-estabilidad-el-termómetro-del-día>
#strong[↗ MÁS ALLÁ DEL EXAMEN.] Los índices de sondeo (TT, K, CAPE, LI) y los Skew-T no deberían ser materia de examen: son formación de vuelo de distancia. Estúdialos cuando domines el resto del temario; aquí están porque forman al piloto, no solo al aprobado.

Describir cualitativamente la atmósfera ("parece inestable", "hace buena cara") es útil, pero los pilotos de cross-country van un paso más allá: cuantifican la inestabilidad mediante índices derivados de los sondeos termodinámicos.

El instructor de vuelo experimentado maneja habitualmente dos parejas de índices:

- #strong[TT + K] como herramientas del día a día para decidir si vuelas y qué puedes esperar.
- #strong[CAPE + LI] como herramientas de análisis profundo cuando el día "tiene trampa".

La distinción clave que aporta la experiencia de campo: #strong[el TT (Total Totals) es especialmente fiable en el llano, mientras que el K es más representativo en montaña]. Cuando planifiques un vuelo en zona llana (Castilla, Aragón, La Mancha), mira el TT. Si volarás en entornos de cordillera (Pirineo, Sistema Central, Sistema Ibérico), dale más peso al K.

=== Total Totals (TT): el índice del llano
<total-totals-tt-el-índice-del-llano>
El índice Total Totals (TT) combina el gradiente vertical de temperatura con la humedad en capas bajas. Su fórmula:

#block[
#callout(
body: 
[
El gráfico TT + K que el instructor cuelga cada mañana en el hangar te da la fotografía rápida del día. El TT te dice cuánto "combustible" tiene la atmósfera para armar un Cb en el llano; el K te lo dice para la montaña. No confíes en uno solo: úsalos juntos antes de cada preflight.

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
Umbrales del TT y su interpretación para el vuelo a vela:

#table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([TT], [Condición para el vuelo a vela],),
  table.hline(),
  [\< 44], [Atmósfera estable; térmicas débiles o inexistentes],
  [44--48], [Inestabilidad moderada; convección posible sin tormenta],
  [\> 48], [Bastante inestable; desarrollo de Cb probable en el llano],
  [\> 52], [Tormenta muy probable: tormentas aisladas],
  [55], [Tormentas dispersas, algunas moderadas y alguna aislada severa],
  [58], [Tormentas moderadas dispersas, algunas severas y algún tornado aislado],
  [61], [Tormentas frecuentes moderadas; alguna severa o algún tornado],
  [64], [Tormentas frecuentes moderadas con tormentas severas y tornados],
)
Los umbrales clásicos de tormenta del TT proceden del trabajo de Robert C. Miller para el centro de alertas militares de EE. UU. (#emph[Notes on Analysis and Severe-Storm Forecasting Procedures of the Air Force Global Weather Central], 1972); los tramos «para el vuelo a vela» de las dos primeras filas son una adaptación operativa de esta colección, no de Miller.

#block[
#callout(
body: 
[
El TT presenta limitaciones: sobrestima la inestabilidad si la temperatura a 500 hPa es muy baja sin soporte convectivo en capas bajas, y no detecta bien la estabilidad fuerte o la humedad elevada por debajo de 850 hPa. En esas situaciones, refuerza el análisis con el K-Index y el CAPE.

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
=== K-Index: el índice de la montaña
<k-index-el-índice-de-la-montaña>
El K-Index combina el gradiente de temperatura entre 850 hPa y 500 hPa con la humedad en niveles medios y bajos. Es la métrica habitual para el pronóstico de actividad convectiva en entornos de montaña:

#table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([K], [Condición para el vuelo a vela],),
  table.hline(),
  [\< -10], [Térmicas inexistentes o muy débiles (atmósfera muy estable)],
  [-10 a 5], [Térmicas secas sin cúmulos; convección escasa],
  [5--15], [Buenas condiciones de vuelo a vela, cúmulos presentes],
  [15--20], [Excelente: bases altas, térmicas potentes, chubascos ocasionales],
  [20--30], [Excelente convección, pero riesgo creciente de chubascos y tormentas],
  [\> 30], [Alta probabilidad de tormentas (\> 60 %): no planifiques vuelos largos],
)
#block[
#callout(
body: 
[
El K-Index fue diseñado para predecir tormentas, no la calidad del vuelo a vela. Sus umbrales varían según la región y la estación: en zonas áridas como la Meseta Central, la baja humedad puede dar K bajos incluso con térmicas potentes. En montaña, si el nivel de 850 hPa queda cerca del suelo, el índice pierde representatividad. Úsalo siempre junto al TT y, si el día tiene pinta de complicarse, añade el CAPE.

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
=== CAPE y LI: profundizando cuando el día tiene trampa
<cape-y-li-profundizando-cuando-el-día-tiene-trampa>
- #strong[CAPE] (#strong[Convective Available Potential Energy], Energía Potencial Convectiva Disponible): Cuantifica la energía disponible para la convección. Es el área entre la curva de la parcela y la curva de estado en el diagrama termodinámico. Valores de referencia: 0 J/kg = estabilidad absoluta; 1.000--2.500 J/kg = excelente día de térmicas; \> 3.500 J/kg = convección severa probable.

#block[
#callout(
body: 
[
Los valores de CAPE que ves en manuales de meteorología general suelen clasificar 1.000--2.500 J/kg como "moderadamente inestable", reservando "muy inestable" para valores superiores. Para el volovelista, ese rango es perfectamente excelente: proporciona térmicas potentes y bases altas sin el riesgo de tormenta severa. Cuando consultes herramientas externas como Skysight o la Universidad de Wyoming, interpreta el CAPE en contexto aeronáutico, no según las escalas de meteorología convectiva para tormentas.

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
- #strong[LI (Índice de Levantamiento o ]Lifted Index#strong[)]: Diferencia entre la temperatura de la parcela y la del ambiente a 500 hPa, tras elevarla adiabáticamente desde el suelo. Valores negativos indican inestabilidad: cuanto más negativo, mayor el potencial convectivo.

#block[
#callout(
body: 
[
Día de convección excepcional --- conocido coloquialmente como «día termonuclear» en el argot de competición ---: TT entre 48 y 55, K entre 15 y 20, CAPE entre 1.000 y 2.500 J/kg, LI negativo y vientos flojos de componente variable. Son los días de récords de distancia. Puedes encontrar todos estos índices en cualquier sondeo online: gratuitamente en la Universidad de Wyoming, AEMET (AMA), Windy o Meteoblue; con previsiones orientadas al planeador en Skysight, Topmeteo o Meteo Parapente.

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
Las tablas de umbrales de los apartados anteriores tienen ocho tramos cada una porque describen todo el espectro, de la calma a la tormenta severa. Para el examen basta con quedarse con la banda útil de cada índice; las tablas completas son material de campo para cuando vueles de verdad:

#table(
  columns: 3,
  align: (auto,auto,auto,),
  table.header([Índice], [Banda de buen día térmico], [Señal de alarma (tormenta)],),
  table.hline(),
  [#strong[TT] (Total Totals)], [44--52], [\> 55],
  [#strong[K] (K-Index)], [15--25 (matizado en montaña)], [\> 25],
  [#strong[CAPE]], [1.000--2.500 J/kg], [\> 2.500--3.500 J/kg],
  [#strong[LI] (Lifted Index)], [ligeramente negativo], [muy negativo],
)
La regla de oro para el examen y para la cabina: un índice aislado no decide nada. TT y K dicen si el día vuela; CAPE y LI, cuánta energía tiene y si esa energía puede volverse contra ti en forma de tormenta.

#block[
#callout(
body: 
[
TT \> 55 o K \> 25 combinado con CAPE \> 2.500 J/kg señala alto riesgo de tormenta de evolución diurna. En estas condiciones, planifica el aterrizaje antes de las 16:00 h y ten siempre identificado un campo de aterrizaje alternativo en tierra antes de que se levante la convección.

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
#strong[Resumen del Capítulo: Termodinámica]

- #strong[Estabilidad Atmosférica]: Concepto clave. El aire es "estable" si una burbuja empujada hacia arriba tiende a volver a bajar, e "inestable" si sigue subiendo sola. El vuelo a vela vive de la inestabilidad.
- #strong[Gradientes Adiabáticos]: El aire seco se enfría 3°C por cada 1.000 ft al subir (DALR). El aire saturado (nube) se enfría solo la mitad, 1,5°C (SALR). Memoriza esto para predecir la base de las nubes y su desarrollo.
- #strong[Inversiones]: Son capas donde la temperatura #strong[sube] con la altura en lugar de bajar. Actúan como una tapadera invisible que frena las térmicas y atrapa la contaminación/bruma.
- #strong[Convección]: El sol calienta el suelo, el suelo calienta el aire, y este sube como una burbuja (modelo burbuja) o como una pluma continua (modelo columna). Cuanto más frío esté el aire arriba en comparación con el suelo, más fuerte será la térmica.

= Nubes y niebla
<nubes-y-niebla>
#quote(block: true)[
Las nubes son el lenguaje visual de la atmósfera: si sabes leerlas, te dicen dónde están las ascendencias, dónde está el peligro y cómo va a evolucionar el tiempo. En este capítulo aprenderás a identificar los tipos de nubes relevantes para el vuelo a vela, qué peligros asocia cada familia y cómo interpretar la niebla y la neblina para decidir si despegar o no.
]

== Interpretación de la nubosidad
<interpretación-de-la-nubosidad>
Para la tripulación de un planeador, las nubes son el mapa visual de la atmósfera. La tabla siguiente resume las cuatro familias principales y su relevancia operativa para el vuelo a vela (#ref(<fig-03-cap04-familias-nubes-perfil>, supplement: [Figura])):

#figure([
#box(image("imagenes/03-cap04-familias-nubes-perfil.png"))
], caption: figure.caption(
position: bottom, 
[
Perfil vertical de las cuatro familias de nubes con altitudes de base aproximadas
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap04-familias-nubes-perfil>


La OMM clasifica la nubosidad en #strong[diez géneros], repartidos en esas cuatro familias por la altura de su base:

Nubes altas (base \> 6.000 m)

Cirros (Ci), Cirrocúmulos (Cc), Cirroestratos (Cs)

Nubes medias (base 2.000--6.000 m)

Altocúmulos (Ac), Altoestratos (As), Nimboestratos (Ns)

Nubes bajas (base \< 2.000 m)

Estratos (St), Estratocúmulos (Sc)

Desarrollo vertical

Cúmulos (Cu), Cumulonimbos (Cb)

Para el vuelo a vela no todos pesan igual: los cúmulos marcan las térmicas, el cumulonimbo es el peligro máximo, los cirros anuncian la llegada de un frente y los nimboestratos traen precipitación persistente. Aun así conviene reconocer los diez, porque el examen los pregunta y porque cada uno cuenta algo del estado de la atmósfera.

== Peligros asociados al desarrollo vertical
<peligros-asociados-al-desarrollo-vertical>
En condiciones de alta inestabilidad atmosférica y humedad, un cúmulo puede continuar su desarrollo y evolucionar a y, finalmente, transformarse en un #strong[Cumulonimbus (Cb)].

El Cumulonimbus abarca una notable extensión vertical, culminando a menudo, al alcanzar la tropopausa, con un tope en forma de yunque. Esta configuración contiene energía masiva capaz de comprometer gravemente la seguridad del vuelo. Los riesgos asociados incluyen:

- #strong[Turbulencia severa:] Las corrientes ascendentes y descendentes que coexisten dentro y alrededor del Cb superan con facilidad los límites estructurales del planeador. El frente de ráfagas puede extenderse a kilómetros del núcleo y golpear sin previo aviso.
- #strong[Granizo:] Las corrientes ascendentes arrastran agua hasta las capas de congelación repetidas veces, formando granizo que alcanza tamaños considerables. Un impacto de granizo puede dañar seriamente la cúpula y las estructuras de fibra de la aeronave.
- #strong[Actividad eléctrica:] Un rayo que impacte en el planeador compromete la integridad de la aeronave y pone en riesgo directo a los ocupantes.
- #strong[Engelamiento masivo:] Al penetrar en las zonas superenfriadas del Cb, el borde de ataque acumula hielo claro en segundos, destruyendo el perfil laminar y disparando la velocidad de pérdida.

#block[
#callout(
body: 
[
El piloto debe evitar en todo momento volar en las inmediaciones de un Cumulonimbus. Se recomienda mantener una separación lateral de seguridad entre 10 y 20 millas náuticas. Si un sistema convectivo amenaza el aeródromo, inicie de inmediato el procedimiento de aterrizaje.

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
== Reducciones de visibilidad: Niebla y Neblina
<reducciones-de-visibilidad-niebla-y-neblina>
Una degradación significativa en la visibilidad penaliza las Reglas de Vuelo Visual (VFR).

- #strong[Neblina y bruma:] Reducen la visibilidad horizontal a valores entre 1.000 m y 3.000 m.
- #strong[Niebla:] Fenómeno de suspensión de agua al nivel del terreno que restringe la visibilidad inferior a los 1.000 m. En estas condiciones, está inhabilitada la operación VFR.

Resulta de particular interés la #strong[niebla de radiación]. Se forma en madrugadas invernales tras noches despejadas bajo condiciones anticiclónicas. El rápido enfriamiento del terreno arrastra térmicamente la capa inferior de aire, saturándola y originando espesos bancos de niebla localizados.

Otro tipo relevante para los operadores de aeródromos costeros y de valle es la #strong[niebla de advección] (#strong[advection fog]). A diferencia de la de radiación, no depende del enfriamiento nocturno del suelo: se forma cuando una masa de aire cálido y húmedo se desplaza horizontalmente sobre una superficie más fría (el mar frío, un valle nevado o una costa). El contraste de temperatura basta para saturar la base de esa masa y producir un banco de niebla denso que puede persistir día y noche mientras dure el flujo. Es característica del litoral galaico-cantábrico en invierno y de las costas mediterráneas en otoño con viento de levante.

#block[
#callout(
body: 
[
Presta especial atención a la tarde en los días que hayan empezado con niebla de radiación persistente. Al caer el sol, el enfriamiento nocturno puede reinstaurar la niebla en minutos y cerrarte el campo antes de que aterrices. En costas y valles con viento de componente mar, añade también el riesgo de niebla de advección: puede llegar sin previo aviso y a cualquier hora del día.

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
== Altocúmulos Lenticulares y vuelo de onda
<altocúmulos-lenticulares-y-vuelo-de-onda>
Las #strong[nubes lenticulares] (#strong[Altocumulus lenticularis]) exhiben formas alisadas y características convexas, similares a una lente. A pesar de formarse bajo vientos de intensidad notable en altura, su estructura permanece totalmente estacionaria respecto al relieve.

Estas formaciones son la prueba visible de un flujo laminar constante interactuando transversalmente y rebotando a sotavento de un obstáculo orográfico. En la práctica, señalan el sistema de #strong[Onda de Montaña], donde es posible remontar sin turbulencia sostenidamente ganando gran altitud en un plano de aire terso (#ref(<fig-03-cap04-nubes-onda-montana>, supplement: [Figura])).

#figure([
#box(image("imagenes/03-cap04-onda-montana.jpg"))
], caption: figure.caption(
position: bottom, 
[
Sistema de onda de montaña a sotavento.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap04-nubes-onda-montana>


#block[
#callout(
body: 
[
Bajo la zona de onda, a baja altura, se esconde el #strong[rotor]: un cilindro de turbulencia giratoria muy violento que se delata visualmente por fractocúmulos deshilachados e inestables. Si haces un remolque en zona de onda, el avión remolcador zarandeará con fuerza al atravesar el rotor. Mantén siempre altura suficiente para evitarlo y sigue las indicaciones del piloto remolcador en todo momento.

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
#strong[Resumen del Capítulo: Nubes y Niebla]

- #strong[Significado de las nubes]: Para el piloto de planeador, las nubes son el mapa del cielo. Los #strong[Cúmulos (Cu)] pequeños y algodónosos son nuestros mejores amigos (marcan térmicas). Los #strong[Cirros] altos suelen anunciar un frente (mal tiempo en 24-48h).
- #strong[Peligro de Desarrollo Vertical]: Si un cúmulo crece mucho verticalmente (#strong[Cu congestus]), vigílalo de cerca. Si pasa a #strong[Cumulonimbus (Cb)], aléjate millas: hay turbulencia severa, granizo y rayos que pueden destruir el planeador.
- #strong[Niebla vs Neblina]: Ambas reducen la visibilidad. La niebla (\< 1 km) es crítica para el aterrizaje y despegue. Hay dos tipos frecuentes: la #strong[de radiación] (noches frías y despejadas, suele disiparse con el sol por la mañana) y la #strong[de advección] (aire cálido sobre superficie fría, puede presentarse a cualquier hora y no depende de la noche).
- #strong[Nubes Lenticulares]: Tienen forma de lenteja o platillo y se quedan "quietas" aunque sople mucho viento. Indican #strong[Onda de Montaña], un fenómeno que permite subir muy alto pero advierte de turbulencia (rotores) muy peligrosa a baja altura.

= Precipitación
<precipitación>
#quote(block: true)[
La precipitación ---lluvia, granizo, lluvia engelante o virga--- no es solo un inconveniente: puede convertirse en una emergencia en pocos minutos. En este capítulo aprenderás cómo cada tipo de precipitación afecta al planeador aerodinámicamente, cuáles son los más peligrosos y qué decisiones debes tomar ante los primeros síntomas para mantenerte seguro.
]

== La lluvia y la degradación aerodinámica
<la-lluvia-y-la-degradación-aerodinámica>
Los planeadores están diseñados con perfiles laminares calibrados para una alta eficiencia. El impacto de la lluvia altera severamente el perfil aerodinámico al provocar que el flujo de aire se desprenda prematuramente y se vuelva turbulento a lo largo de las alas mojadas.

En vuelo con lluvia, las consecuencias son directas:

- #strong[Aumento de la velocidad de pérdida (stall speed):] El ala perderá su sustentación a una velocidad significativamente mayor que en configuración seca.
- #strong[Reducción del coeficiente de planeo:] El ratio de planeo (#strong[glide ratio]) se penaliza, lo que obliga a recalcular el cono de planeo y buscar alternativas de aterrizaje con menor alcance.
- #strong[Mayor tasa de descenso:] Se aprecia un incremento notorio en la tasa de caída o hundimiento (#strong[sink rate]) para lograr mantener una misma velocidad de vuelo.

#block[
#callout(
body: 
[
Con alas mojadas, añade siempre un margen mínimo de 5-10 kt sobre tu velocidad de aproximación estándar. Evita giros pronunciados: el riesgo de entrada en pérdida es significativamente mayor que en configuración seca y puede producirse sin advertencia previa.

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
== El granizo (GR) y nubes convectivas
<el-granizo-gr-y-nubes-convectivas>
El granizo nace dentro del Cumulonimbus (Cb). Las potentes corrientes ascendentes lanzan las gotas de agua hasta por encima del nivel de congelación, donde se congelan. Luego caen, son atrapadas de nuevo por la corriente y suben otra vez, ganando una capa de hielo en cada ciclo ---como una cebolla--- hasta que pesan demasiado para que la corriente las sostenga. El resultado son piedras que pueden superar los 2--3 cm de diámetro.

Para las aeronaves compuestas con perfiles ligeros de fibra, la aceleración cinética del granizo (sumada a la propia velocidad de la aeronave) presenta gran riesgo estructural. Resulta habitual constatar roturas y perforaciones en la cúpula (#strong[canopy]), daños en los recubrimientos protectores superficiales de #strong[gelcoat], o posibles delaminaciones de la matriz celular sintética en impactos directos severos.

#block[
#callout(
body: 
[
No asumas que el granizo cae solo bajo la vertical del Cb: el viento en altura puede expulsarlo decenas de kilómetros bajo el yunque extendido. Mantén siempre la distancia de seguridad del yunque, aunque el cielo por debajo parezca completamente despejado.

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
== Lluvia engelante (FZRA) y formación rápida de hielo
<lluvia-engelante-fzra-y-formación-rápida-de-hielo>
La #strong[lluvia engelante] (#strong[FZRA]) es lluvia que cae ya superenfriada: gotas líquidas por debajo de 0°C que aún no se han congelado, las #strong[gotículas superenfriadas]. El escenario clásico es un frente cálido en invierno, cuando la lluvia atraviesa una capa de aire bajo cero cerca del suelo. No hace falta estar dentro de una nube: al impactar contra cualquier superficie sólida del planeador ---borde de ataque, cúpula, morro--- las gotas se congelan en décimas de segundo formando hielo opaco o escarcha. Dentro de nube, entre 0°C y -15°C, esas mismas gotículas producen el engelamiento que se detalla en el capítulo 9.

El resultado es el #strong[engelamiento] (#strong[icing]), uno de los peligros más rápidos y graves del vuelo a vela:

- La cúpula de la cabina se opaca en segundos, eliminando toda referencia visual VFR.
- El hielo deforma el borde de ataque, destruye la sustentación laminar y eleva drásticamente la velocidad de pérdida.
- El peso añadido, distribuido asimétricamente en las puntas alares, incrementa el arrastre e introduce desequilibrios laterales difíciles de compensar.

Al primer síntoma de engelamiento ---escarcha en el borde del ala o en la cúpula--- gira 180° y desciende inmediatamente a niveles con temperatura positiva. No esperes: el engelamiento se acelera a medida que más superficie queda cubierta.

== Virga: La cortina descendente e invisibilidad
<virga-la-cortina-descendente-e-invisibilidad>
La #strong[Virga] es una cortina de precipitación que cae desde la base de una nube pero se evapora antes de llegar al suelo. Visualmente aparece como franjas grises o azuladas que se difuminan en el aire a media altura, sin tocar el terreno.

El peligro no está en la lluvia en sí, sino en lo que ocurre cuando esas gotas se evaporan: la evaporación enfría el aire circundante, que se vuelve más denso y cae en masa hacia el suelo formando una violenta corriente descendente ---el #strong[downburst] o #strong[microrráfaga] (#ref(<fig-03-cap05-virga-microrrafaga>, supplement: [Figura])).

#figure([
#box(image("imagenes/03-cap05-virga-microburst.jpg"))
], caption: figure.caption(
position: bottom, 
[
Peligro bajo la virga: el nacimiento de una microrráfaga
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap05-virga-microrrafaga>


Estas corrientes descendentes localizadas (#strong[microburst] / #strong[downdraft]) pueden alcanzar velocidades de descenso que superan la capacidad de ascenso del planeador. Volar bajo una virga, especialmente durante la aproximación final, puede causar un hundimiento irrecuperable antes del umbral. Ante cualquier cortina de virga visible, mantén siempre distancia de seguridad lateral y vertical.

#strong[Resumen del Capítulo: Precipitación]

- #strong[Lluvia y Performance]: Para un planeador, la lluvia es kryptonita. El agua en las alas arruina el perfil laminar, aumentando drásticamente la velocidad de pérdida y la tasa de descenso. Si llueve, añade velocidad de seguridad al aterrizar.
- #strong[Granizo (GR)]: Asociado a los Cumulonimbus (Cb). Puede encontrarse incluso fuera de la nube, bajo el yunque. Es destructivo para la estructura de fibra. NUNCA vueles debajo de un yunque de tormenta.
- #strong[Lluvia Engelante (FZRA)]: Gotas superenfriadas que se congelan al impactar. Es una emergencia grave: el hielo se acumula en segundos, pesando y deformando el perfil. Sal inmediatamente de esa zona (generalmente cambiando de altitud).
- #strong[Virga]: Cortina de lluvia que se evapora antes de tocar el suelo. Es un aviso visual de fuertes corrientes descendentes y posible turbulencia severa debajo de ella.

= Masas de aire y frentes
<masas-de-aire-y-frentes>
#quote(block: true)[
Un frente es la frontera entre dos masas de aire con propiedades distintas, y cruzarlo sin planificación puede convertir un buen vuelo en una emergencia. En este capítulo aprenderás a reconocer frentes fríos, cálidos y ocluidos antes de que lleguen a tu zona, y entenderás por qué la temperatura relativa de la masa de aire determina si tendrás térmicas o niebla bajo tus ruedas.
]

== Frentes fríos e inestabilidad
<frentes-fríos-e-inestabilidad>
Un #strong[frente frío] corresponde a la superficie de separación en la cual una masa de aire frío, al ser más densa, avanza en forma de cuña introduciéndose por debajo de una masa de aire cálido preexistente. Este proceso obliga al aire cálido a ascender de manera pronunciada.

El paso de un frente frío se caracteriza por un descenso abrupto de las temperaturas, una rolada brusca de viento (generalmente hacia el noroeste o norte), visibilidad reducida y precipitaciones organizadas, frecuentemente en forma de chubascos y nubes de gran desarrollo vertical como los Cumulonimbus (Cb) (#ref(<fig-03-cap06-frente-frio-estructura>, supplement: [Figura])).

Para el vuelo a vela, el interés meteorológico óptimo radica en la situación posterior al frente. Una vez despejada la barrera frontal, la región queda dominada por una masa de aire transicional netamente más fría que el terreno. Al calentarse su base por contacto con el suelo, se establece una marcada #strong[inestabilidad post-frontal].

#block[
#callout(
body: 
[
Las jornadas inmediatas tras el cruce de un frente frío intercontinental suelen ofrecer las mejores condiciones de vuelo térmico. Se caracterizan por una excelente visibilidad por ausencia de calima, presión atmosférica en aumento y un fuerte calentamiento diurno que detona corrientes ascendentes robustas marcadas por nubes Cúmulos (Cu) de contornos definidos.

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
#box(image("imagenes/03-cap06-frente-frio-estructura.png"))
], caption: figure.caption(
position: bottom, 
[
Estructura vertical de un frente frío: cuña de aire frío y nubosidad convectiva asociada
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap06-frente-frio-estructura>


== Frentes cálidos y subsidencia pre-frontal
<frentes-cálidos-y-subsidencia-pre-frontal>
Un #strong[frente cálido] se produce cuando una masa de aire cálido avanza y asciende suavemente sobre una masa de aire frío más densa y estacionaria que ocupa la cuenca inferior. Al presentar una pendiente mucho menor que la del frente frío, su evolución y desplazamiento resultan lentos y prolongados.

La proximidad de un frente cálido se anticipa visualmente horas o días antes mediante la aparición escalonada de nubes tipo #strong[Cirros (Ci)] (#ref(<fig-03-cap06-frente-calido-nubes>, supplement: [Figura])). Conforme el sistema avanza, la nubosidad se engrosa y desciende de altitud progresivamente, transitando a Cirroestratos, Altoestratos y concluyendo en una capa de Nimbostratos (Ns) y Estratos (St).

Un frente cálido degrada las condiciones VFR de forma progresiva:

- Genera precipitaciones continuas y lloviznas persistentes de amplia cobertura.
- Los techos nubosos descienden paulatinamente, ocultando elevaciones y relieves montañosos.
- La humedad constante propicia la formación de brumas y nieblas cálidas que deterioran de manera drástica la visibilidad en superficie.
- A nivel termodinámico, estabiliza completamente la masa de aire suprimiendo físicamente el desarrollo de corrientes convectivas o térmicas aprovechables.

#figure([
#box(image("imagenes/03-cap06-frente-calido-nubes.png"))
], caption: figure.caption(
position: bottom, 
[
Secuencia nubosa característica de la aproximación de un frente cálido (vista desde tierra)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap06-frente-calido-nubes>


== La oclusión y el frente estacionario
<la-oclusión-y-el-frente-estacionario>
Cuando un frente frío avanza más rápido que el cálido que tiene delante, termina alcanzándolo. Entonces el frente frío empuja desde atrás y pilla al aire cálido intermedio: lo pinza, lo levanta del suelo y lo obliga a ascender por completo. A este proceso se le llama #strong[frente ocluido] u oclusión (#ref(<fig-03-cap06-tipos-frentes>, supplement: [Figura])).

Operativamente, una oclusión es lo peor de los dos frentes combinado: la convección violenta del frente frío más la lluvia continua y los techos bajos del frente cálido. El aire cálido ya no toca el suelo, así que las térmicas desaparecen y la turbulencia convectiva puede aparecer embebida en capas densas sin aviso visual claro. Ante un frente ocluido, pospón el vuelo: las condiciones son complejas e impredecibles.

#figure([
#box(image("imagenes/03-cap06-frente-ocluido.png"))
], caption: figure.caption(
position: bottom, 
[
Estructura vertical interna de un frente ocluido (oclusión fría)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap06-tipos-frentes>


Existe un cuarto tipo de frente, menos frecuente pero que aparece en los mapas sinópticos: el #strong[frente estacionario]. Se forma cuando dos masas de aire de temperatura y densidad similar se encuentran y ninguna de las dos tiene fuerza suficiente para avanzar sobre la otra. El resultado es una frontera casi inmóvil entre ambas masas, que puede persistir durante días produciendo lluvias y nieblas persistentes a lo largo de su eje. En los mapas sinópticos se dibuja con el patrón alternado de triángulos azules y semicírculos rojos en lados opuestos de la línea frontal.

#block[
#callout(
body: 
[
#strong[SERA.5001] (Reglamento de Ejecución (UE) 923/2012) establece los mínimos meteorológicos para el vuelo VFR. En espacio aéreo de clase G, por debajo de 3.000 ft AMSL o 1.000 ft sobre el terreno, la visibilidad mínima general es de #strong[5 km], volando libre de nubes y con la superficie a la vista. Puede reducirse hasta #strong[1.500 m] para vuelos a 140 kt o menos, siempre que la velocidad permita ver el tráfico y los obstáculos con tiempo para evitar la colisión. La penetración inadvertida en IMC por un piloto VFR sin habilitación de vuelo instrumental constituye una infracción grave.

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
== Masas de aire y la temperatura relativa
<masas-de-aire-y-la-temperatura-relativa>
A nivel de formación convectiva, la temperatura absoluta de la masa de aire resulta secundaria, lo predominante es dictaminar la #strong[temperatura relativa de la masa de aire con respecto a la temperatura del suelo sobre el que transita].

- #strong[Aire frío deslizándose sobre suelo caliente = INESTABILIDAD.] Ocurre cuando aire marítimo fresco llega sobre mesetas continentales calentadas por el sol. La base de esa masa de aire se calienta por contacto con el suelo, se hace más ligera y asciende: se activan térmicas fuertes y aprovechables para el vuelo de distancia.
- #strong[Aire cálido deslizándose sobre suelo frío = ESTABILIDAD.] Sucede cuando una masa cálida avanza sobre el océano frío o sobre continentes nevados. La base de ese aire se enfría y se hace más densa al contacto con el suelo, formando una inversión estable que suprime cualquier térmica y propicia nieblas persistentes.

== Clasificación de las masas de aire
<clasificación-de-las-masas-de-aire>
Antes de hablar de temperatura relativa, es útil conocer de dónde viene el aire que tienes encima. Las masas de aire se clasifican por dos criterios: su #strong[latitud de origen] (determina su temperatura) y su #strong[trayectoria] (determina su humedad).

#table(
  columns: (25%, 25%, 25%, 25%),
  align: (auto,auto,auto,auto,),
  table.header([Sigla], [Tipo], [Temperatura], [Humedad y características para el vuelo a vela],),
  table.hline(),
  [#strong[Tc / Tm]], [Tropical (continental o marítimo)], [Cálido], [Tm: húmedo, bruma frecuente, térmicas débiles. Tc: caluroso y seco, inestabilidad fuerte en verano, excelentes térmicas en la Meseta.],
  [#strong[Pc / Pm]], [Polar (continental o marítimo)], [Frío], [Pm: húmedo, post-frontal clásico, bases de cúmulos bajas pero térmicas presentes. Pc: muy frío y seco, visibilidad excepcional.],
  [#strong[A]], [Ártico / Antártico], [Muy frío], [Irrupciones invernales desde el norte. Termómetros negativos en pista, engelamiento severo, vientos fuertes. No volar.],
)
La situación más frecuente en la Península Ibérica durante la temporada de vuelo (primavera-verano) es la llegada de #strong[masa polar marítima (Pm)] tras el paso de un frente frío. Al cruzar el Atlántico y calentarse por contacto con el suelo peninsular caliente, esta masa genera la combinación perfecta para el vuelo de cross-country: cielo azul, buena visibilidad, bases a 5.000-7.000 ft y térmicas de 3-4 m/s.

#block[
#callout(
body: 
[
No despegues con visibilidad marginal bajo una inversión: ante una rotura de cable o un desenganche de emergencia, el aterrizaje de vuelta a tierra se realizaría sin referencias visuales, con riesgo de impacto irremediable. Si tienes alguna duda sobre la visibilidad, pospón el vuelo.

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
#strong[Resumen del Capítulo: Masas de Aire y Frentes]

- #strong[Frente Frío]: El mejor amigo del volovelista (después de que pasa). Trae inestabilidad, cielo limpio y térmicas potentes (cielo de "post-frente"). Al cruzarlo, espera chubascos, rolada de viento y bajada de temperatura.
- #strong[Frente Cálido]: Malas noticias. Anunciado por cirros que bajan a estratos, trae lluvia continua, techos bajos y mala visibilidad. El aire es estable, así que olvídate de las térmicas.
- #strong[Oclusiones]: Cuando el frente frío alcanza al cálido. Generalmente significa tiempo revuelto, mezcla de nubes y precipitaciones. Poco aprovechable para el vuelo.
- #strong[Masas de Aire]: Lo que importa es la temperatura relativa. Aire frío sobre suelo caliente = inestabilidad (¡térmicas!). Aire cálido sobre suelo frío = estabilidad (capas, niebla, inversión).

= Sistemas de presión
<sistemas-de-presión>
#quote(block: true)[
Los anticiclones y las borrascas son los protagonistas del mapa sinóptico: determinan si tendrás viento, nubes, niebla o el cielo azul perfecto. En este capítulo aprenderás a interpretar la posición de los centros de presión, a anticipar las condiciones de vuelo con 24-48 horas de antelación y a reconocer las trampas del collado barométrico.
]

== Anticiclones (H)
<anticiclones-h>
Un #strong[anticiclón] (representado con una 'H' de #strong[High] o una 'A' en mapas sinópticos) es una amplia región atmosférica donde la presión es superior a la de su entorno. En estos sistemas, la densa masa de aire experimenta un suave descenso divergente en superficie, proceso conocido como #strong[subsidencia].

A medida que desciende, el aire se comprime y se calienta adiabáticamente, lo cual produce un marcado resecamiento e inhibe de forma drástica el desarrollo vertical de nubes convectivas. En el hemisferio norte, la circulación de este aire en superficie fluye hacia el exterior girando en sentido horario. Sus isobaras, habitualmente espaciadas, denotan áreas de calmas o vientos muy flojos.

Sus implicaciones para el vuelo varían notoriamente según la estacionalidad:

- #strong[En meses cálidos:] Resultan en cielos despejados e intensamente azules. No obstante, la fuerte subsidencia actúa como una tapadera altitudinal efectiva que frena abruptamente la ascensión de las térmicas, reduciendo con frecuencia el techo operativo.
- #strong[En meses fríos:] Propician una caída brusca de la temperatura nocturna por rápida irradiación infrarroja de la superficie terrestre. Esta influencia suele desencadenar persistentes y densas nieblas de radiación así como #strong[inversiones térmicas] sumamente estables que bloquean la visibilidad de los valles durante largas jornadas.

No todos los anticiclones son iguales. Según su mecanismo de formación se distinguen dos tipos con efectos muy distintos para el vuelo:

- #strong[Anticiclón dinámico o cálido] (#strong[warm high]): Se forma por subsidencia en la zona de contacto entre las celdas de Hadley y Ferrel (en torno a los 30° de latitud). El aire desciende desde la troposfera alta, se comprime y se calienta. Puede extenderse hasta la tropopausa. El #strong[anticiclón de las Azores] es el ejemplo ibérico por excelencia: en verano se instala sobre la Península y garantiza jornadas largas de vuelo con cielo azul y viento flojo.
- #strong[Anticiclón frío o termal] (#strong[cold high]): Se forma por enfriamiento intenso de grandes superficies continentales, que enfrían el aire en contacto con el suelo. Es denso y frío en las capas bajas pero tiene poca altura ---apenas llega a los 3.000-4.000 m. El anticiclón ibérico invernal es de este tipo: trae noches gélidas, nieblas de radiación persistentes en cuenca del Duero y del Ebro, e inversiones térmicas bajas que bloquean cualquier actividad convectiva.

#block[
#callout(
body: 
[
Para planificar el vuelo del día, mira el mapa sinóptico la noche anterior: si España está bajo una dorsal o anticiclón (H), planifica vuelo de distancia; si hay una vaguada o borrasca acercándose, no planifiques. El movimiento de las isobaras te da 24-48 horas de margen para decidir con criterio.

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
== Borrascas o Depresiones (L)
<borrascas-o-depresiones-l>
Las #strong[borrascas] (representadas con 'L' de #strong[Low] o 'B') son áreas de baja presión: zonas donde la presión es un #strong[mínimo relativo respecto a su entorno], con las isobaras cerradas alrededor del núcleo. Lo que las define es esa relación con lo que las rodea, no un umbral absoluto: existen borrascas con núcleo por encima de 1.013 hPa y anticiclones (sobre todo térmicos) con periferia por debajo de ese valor.

Al contrario que en el anticiclón, el gradiente de presión obliga al aire del entorno a converger hacia el centro de la borrasca y, desde allí, ascender. Ese ascenso enfría el aire y favorece la condensación, generando nubes extensas y frentes de precipitación activa.

En el hemisferio norte, las borrascas giran en sentido #strong[antihorario]. Sus isobaras muy apretadas son sinónimo de vientos fuertes y racheados: la operación VFR dentro de una borrasca activa es inviable. Sin embargo, la retaguardia post-frontal ---lo que queda tras el paso de la borrasca--- suele ofrecer las mejores jornadas de vuelo del año.

#block[
#callout(
body: 
[
Nunca salgas con previsión de borrasca activa en aproximación. Las condiciones VFR pueden degradarse rápidamente: nubosidad baja, visibilidad reducida y ráfagas que complican el aterrizaje. Cancela antes de salir si el mapa sinóptico muestra una depresión activa a menos de 500 km de tu zona de vuelo.

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
== Vaguadas y Dorsales: isobaras irregulares
<vaguadas-y-dorsales-isobaras-irregulares>
Los anticiclones y las borrascas no son siempre círculos perfectos: a menudo emiten "brazos" que se extienden por el mapa en forma de lengua.

- #strong[Vaguada (Surco):] Es una extensión alargada de baja presión que sale de una borrasca, como un tentáculo. Genera las mismas condiciones que su borrasca madre: inestabilidad, chubascos, turbulencia y ráfagas. En el mapa se reconoce como una curva en 'U' o 'V' de las isobaras apuntando hacia el ecuador.
- #strong[Dorsal (Cuña):] Es la extensión alargada de un anticiclón, que lleva consigo su subsidencia y su buen tiempo. Mientras la dorsal domina tu zona, el aire desciende, el cielo se despeja y las térmicas quedan limitadas en altura por esa misma subsidencia.

== Pantano barométrico en áreas de collado
<pantano-barométrico-en-áreas-de-collado>
Un #strong[collado] o #strong[pantano barométrico] se forma cuando dos centros de alta presión y dos de baja presión se sitúan alternados alrededor de un área central, anulando mutuamente sus gradientes. El resultado es una zona de vientos flojos y variables, sin dirección dominante clara ni isobaras con empuje apreciable.

Aunque parece inofensiva por su calma, esta configuración impone condiciones operativas específicas según la estación: 1. #strong[En verano:] Impide que los frentes fríos disipen el fuerte calentamiento diurno. Esta energía acumulada puede generar tormentas locales aisladas muy violentas y estáticas, que suelen producir fenómenos peligrosos como la virga. 2. #strong[En invierno:] La estabilidad absoluta favorece la formación de bancos de niebla densos y persistentes. Al quedar el aire gélido atrapado cerca del suelo por la subsidencia, la visibilidad puede quedar inhabilitada durante días.

#block[
#callout(
body: 
[
Cuando el mapa sinóptico muestre un collado centrado sobre tu zona de vuelo, no improvises: las condiciones evolucionan con lentitud e impredecibilidad. Espera a que el patrón se resuelva claramente ---hacia anticiclón o hacia situación post-frontal con viento del norte--- antes de comprometerte con un vuelo de distancia.

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
== Tabla de referencia: sistemas de presión y vuelo a vela
<tabla-de-referencia-sistemas-de-presión-y-vuelo-a-vela>
#table(
  columns: (20%, 20%, 20%, 20%, 20%),
  align: (auto,auto,auto,auto,auto,),
  table.header([Sistema], [Símbolo], [Circulación (H. Norte)], [Nubosidad típica], [Implicación para el velero],),
  table.hline(),
  [Anticiclón], [H / A], [Horaria, divergente en superficie (subsidencia)], [Escasa o nula], [Buen tiempo VFR; inversión limita el techo térmico. Niebla de radiación en invierno.],
  [Borrasca / Depresión], [L / B], [Antihoraria, convergente (ascendencia)], [Abundante; frentes activos], [Viento fuerte y racheado, precipitación, VFR inviable. Excelente post-frente.],
  [Vaguada (surco)], [---], [Inestabilidad local creciente], [Cumuliformes, chubascos], [Tormentas aisladas y turbulencia. Evitar o planificar antes del calentamiento diurno.],
  [Dorsal (cuña)], [---], [Subsidencia estable], [Escasa o nula], [Condiciones VFR favorables, térmicas moderadas. Sin riesgo convectivo significativo.],
  [Collado / Pantano barométrico], [---], [Flojas y variables, sin dirección dominante], [Variable (niebla en invierno; Cb estáticos en verano)], [Impredecible. No planifiques vuelos de distancia hasta que el patrón se resuelva.],
)
#strong[Resumen del Capítulo: Sistemas de Presión]

- #strong[Anticiclones (H)]: Zonas de alta presión donde el aire baja (subsidencia) y se seca. Garantizan estabilidad y buen tiempo, pero en invierno atrapan nieblas y contaminación. El viento gira en sentido horario (H. Norte).
- #strong[Borrascas (L)]: Zonas de baja presión donde el aire sube y condensa. Son fábricas de nubes, frentes y viento. El viento gira en sentido antihorario (H. Norte).
- #strong[Vaguadas y Dorsales]: Una vaguada es una "lengua" de baja presión (mal tiempo estirado); una dorsal es una "lengua" de alta presión (buen tiempo estirado).
- #strong[Collado]: Zona neutra entre dos altas y dos bajas cruzadas. Es como un pantano barométrico: vientos flojos, dirección variable y probabilidad de nieblas o tormentas estáticas en verano.

= Climatología
<climatología>
#quote(block: true)[
España ocupa una posición geográfica privilegiada para el vuelo a vela: orografía compleja, contrastes térmicos extremos entre mesetas y litoral, y mar perimetral en tres frentes. En este capítulo aprenderás qué define el clima aeronáutico de la Península Ibérica en cada estación, cómo actúan los vientos locales en los valles y qué papel juega la Baja Térmica Peninsular como motor de las mejores jornadas de cross-country estival.
]

== Circulación general de la atmósfera
<circulación-general-de-la-atmósfera>
Antes de entrar en la climatología local, conviene situar el contexto planetario. La atmósfera terrestre no circula al azar: el calor solar, la rotación de la Tierra y la diferencia de temperatura entre el ecuador y los polos organizan el flujo en tres bandas de circulación por hemisferio, llamadas #strong[celdas de circulación general].

- #strong[Celda de Hadley] (área tropical, 0--30° de latitud): El aire ecuatorial, muy calentado, asciende formando la #strong[Zona de Convergencia Intertropical (ZCIT)], la banda de inestabilidad más activa del planeta. En altura fluye hacia los polos y, al llegar a los 30°, se hunde y desciende (subsidencia) formando los anticiclones subtropicales (como el Anticiclón de las Azores, clave para el clima peninsular).
- #strong[Celda de Ferrel] (área templada, 30--60° de latitud): Por esta banda serpentea el #strong[chorro polar] (#strong[jet stream]) de poniente. Sus fluctuaciones son las que dirigen los frentes y borrascas hacia la Península Ibérica. Los pilotos que planifican vuelos de distancia en invierno o primavera notarán su influencia directa.
- #strong[Celda Polar] (área polar, 60--90° de latitud): Aire frío polar que desciende en los polos y fluye en superficie hacia latitudes medias, alimentándolas de las masas de aire ártico que nos llegan tras los frentes fríos invernales.

España se sitúa en el borde sur de la Celda de Ferrel, lo que la convierte en territorio de transición: puede recibir tanto la influencia anticiclónica subtropical (buen tiempo en verano) como el paso de los frentes atlánticos de la Celda de Ferrel (lluvias y viento en invierno). Esta posición fronteriza genera una variabilidad meteorológica excepcional, que es exactamente lo que hace que volar en la península sea tan técnicamente exigente y tan recompensante.

== España: origen de contrastes aeronáuticos
<españa-origen-de-contrastes-aeronáuticos>
Debido a su compleja orografía y situación geográfica, la península ibérica ofrece condiciones de clase mundial para la práctica del vuelo sin motor a lo largo de todo el año.

- #strong[Vuelo de Onda y Laderas:] Durante el invierno y la ventosa primavera, los grandes macizos montañosos actúan como gigantescos deflectores. Es especialmente destacable la #strong[Onda de Montaña] en el Sistema Central (zonas míticas como Fuentemilanos, Santo Tomé, Pedro Bernardo o Arcones) y en la potente "Convergencia Pirenaica". Estas condiciones permiten ascensos de onda espectaculares y vuelos de altitud y distancia extrema.
- #strong[Vuelo Térmico Puro:] En verano, las extensas llanuras interiores y mesetas (como La Mancha) se calientan intensamente por radiación solar, generando convecciones formidables y enormes líneas de convergencia (como la de los Montes de Toledo) ideales para maratones de cross-country.

#block[
#callout(
body: 
[
En España tienes temporada para casi todo el año: cuando el viento sopla fuerte en invierno, busca onda en el Sistema Central o los Pirineos; cuando el verano hornea las mesetas, busca térmicas en La Mancha. Conocer cuándo y dónde vale cada recurso define al piloto experimentado.

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
== Vientos locales y la dinámica de los valles
<vientos-locales-y-la-dinámica-de-los-valles>
Para un piloto de aviación de transporte el viento general lo es todo; para el piloto de planeador, que vuela pegado al terreno, #strong[cada valle tiene su propio dueño y señor atmosférico]. El Capítulo 2: Viento describe en detalle el ciclo anábático y catabático y el efecto Foehn; aquí nos centramos en cómo esos mecanismos definen el vuelo en el contexto ibérico concreto.

En zonas montañosas como el Sistema Central, los Pirineos o los Picos de Europa, los #strong[vientos anabáticos matinales] disparan las primeras térmicas antes incluso de que el sol alcance los 30° de elevación: las solanas orientadas al este son las primeras en activarse. Al atardecer, los #strong[catabáticos] que bajan por ambas laderas del valle pueden generar una zona de restitución en el centro ---esa ascendencia suave que a veces permite prolongar el vuelo hasta el oscurecer. Conocer cuál es la dirección catabática de tu aeródromo local es tan importante como saber la posición de la cabecera.

Los #strong[rotores de sotavento] son la trampa invisible de la climatología ibérica: con viento de componente norte en el Sistema Central o con Tramontana en el Pirineo, el rotor puede situarse exactamente sobre la vertical del aeródromo a alturas de circuito. Si el día presenta lenticulares en altura y ves fractocúmulos deshilachados a baja cota, trata esa zona como zona de turbulencia severa.

#block[
#callout(
body: 
[
Los vientos catabáticos y los rotores de sotavento pueden aparecer a baja altitud sin previo aviso visual. Nunca sobrevueles una ladera de sotavento a menos de 300 ft de separación vertical del terreno, y conoce los puntos conflictivos de tu aeródromo local antes de volar en condiciones de viento fuerte.

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
Antes de cada vuelo en zona montañosa, consulta la dirección del viento y compárala con el mapa orográfico de tu aeródromo. Los vientos del norte generan rotores en sectores distintos a los del sur o del oeste. Aprende los patrones locales y consulta a pilotos con experiencia en la zona.

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
== Estacionalidad aeronáutica: el calendario del piloto
<estacionalidad-aeronáutica-el-calendario-del-piloto>
La cambiante fisonomía de cada estación del año impone al velerista reglas de vuelo claras:

- #strong[Primavera:] Es el ansiado despertar. Los días se alargan radiantes y el creciente calentamiento del suelo dispara la inestabilidad, provocando potentes contrastes con el aire en altura aún frío del remanente invierno. Ofrece robustas térmicas de incipiente maduración diaria, aunque con la constante amenaza de pasos frontales y días inestables.
- #strong[Verano:] La temporada principal para el vuelo de distancia. Las fuertes térmicas elevan los techos de las nubes a cotas muy altas. Sin embargo, existe el riesgo de tormentas de evolución súbita que pueden obligar a aterrizajes preventivos por seguridad.
- #strong[Otoño:] Generalmente asociado a mayor estabilidad y lluvias. En el área mediterránea es la época de las DANA (Depresiones Aisladas en Niveles Altos), que generan tormentas severas y precipitaciones intensas, reduciendo significativamente las oportunidades de vuelo.
- #strong[Días Post-Frontales:] Con independencia de la estación, el día después del paso de un frente frío suele ofrecer condiciones excelentes. La atmósfera queda limpia, nítida y con visibilidad excepcional. El contraste térmico entre el aire gélido y el suelo reactiva las mejores corrientes ascendentes del año.

#block[
#callout(
body: 
[
Los días post-frontales son el estándar de oro del vuelo ibérico: cielo azul, térmicas puras y visibilidad excepcional. Aprende a identificarlos en la previsión: busca el paso de un frente frío activo seguido de aire polar y presión en subida. El día siguiente suele ser extraordinario.

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
En verano, las tormentas de evolución (#strong[air mass storms]) se desarrollan rápidamente durante las horas centrales del día a partir de cúmulos congestus. Si ves cúmulos que crecen verticalmente a ritmo acelerado, aterriza cuanto antes. No esperes a ver el yunque para decidir.

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
== La Baja Térmica Peninsular estival
<la-baja-térmica-peninsular-estival>
En los picos crudos del verano, la intensa radiación solar hornea la superficie de las vastas mesetas del interior peninsular. Este calentamiento brutal genera grandes columnas de aire cálido ascendentes, estableciendo una permanente #strong[baja térmica peninsular] en el centro de España.

Aunque barométricamente no es tan profunda como una fuerte borrasca polar, esta masa estancada ejerce una constante fuerza de succión. Como si fuera una gigantesca aspiradora, la baja térmica tira continuamente de las densas masas de aire frío y húmedo que reposan sobre el océano y los mares perimetrales, arrastrándolas hacia el interior terrestre.

Este imparable avance de aire marino forzado tierra adentro se convierte en extensos #strong[frentes de brisa] que penetran decenas de kilómetros. Al chocar contra la masa continental abrasadora y contra las barreras de los sistemas montañosos, levantan forzosamente el aire inestable en formidables #strong[líneas de convergencia]: autopistas invisibles de ascendencia que el piloto experimentado aprende a seguir en sus vuelos de distancia.

#block[
#callout(
body: 
[
Las líneas de convergencia generadas por la Baja Térmica Peninsular son autopistas de sustentación en verano. Identifícalas en las previsiones de modelos RASP o Skysight y planifica tu ruta de cross-country siguiéndolas: con brisa bien establecida, una sola línea de convergencia puede regalarte decenas de kilómetros sin perder altitud.

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
#strong[Resumen del Capítulo: Climatología]

- #strong[España, país de contrastes]: Tenemos condiciones mundiales para el vuelo. Viento y #strong[Onda de Montaña] en invierno/primavera (Pirineos, Sistema Central) y potentes #strong[Térmicas] en verano (La Mancha, zonas interiores).
- #strong[Vientos Locales]: Cada valle tiene su dueño. Los vientos anabáticos y catabáticos definen la mañana y la tarde en zonas montañosas. Los rotores de sotavento son la trampa invisible del piloto imprudente.
- #strong[Estacionalidad]: La primavera ofrece inestabilidad y buen vuelo local. El verano trae techos altos y tormentas secas de calor. El otoño suele traer lluvias y DANA.
- #strong[Baja Térmica Peninsular]: En verano, el sol calienta tanto el centro de España que se forma una baja presión permanente. Esto succiona aire del mar, reforzando las brisas costeras que penetran muy adentro y generan líneas de convergencia ideales para el cross-country.

= Peligros para el vuelo
<peligros-para-el-vuelo>
#quote(block: true)[
La meteorología peligrosa no siempre avisa con tiempo: un Cb puede crecer mientras haces el preflight, el hielo puede formarse en minutos y la cizalladura puede tirarte al suelo en los últimos metros de final. En este capítulo aprenderás a identificar y evitar los peligros meteorológicos más críticos para el vuelo a vela, y qué decisiones tomar cuando aparecen.
]

== Tormentas y nubes de desarrollo extremo (Cb)
<tormentas-y-nubes-de-desarrollo-extremo-cb>
El Cumulonimbus (Cb) representa la manifestación más severa de la inestabilidad atmosférica. Alberga en su volumen los meteoros más hostiles condensados en una misma depresión celular. Para cualquier aeronave, y en especial para un velero ligero, la doctrina de vuelo exige que #strong[jamás] se debe operar bajo un Cb, en su interior, ni en sus proximidades (con un margen de evitación recomendado de entre 10 y 20 NM) (#ref(<fig-03-cap09-cumulonimbus>, supplement: [Figura])).

- #strong[Peligros estructurales:] Estas inmensas formaciones convectivas desatan corrientes ascendentes y descendentes contiguas de virulencia extrema. La turbulencia cizallante generada (#strong[updrafts] y #strong[downdrafts]) puede exceder holgadamente los factores de carga límite de diseño de cualquier aeronave ligera, provocando fallos estructurales en vuelo.
- #strong[Fenómenos asociados:] Los Cb están perimetralmente flanqueados por turbonadas con fortísimos vientos racheados direccionales, alta densidad de descargas eléctricas (rayos), precipitación abundante y, con alta probabilidad, granizo. El impacto de granizo severo (diámetros \> 2 cm) destruye el perfil laminar y puede comprometer la integridad de la estructura del planeador.
- #strong[Identificación preventiva:] La acción fundamental es la anticipación. La detección visual del característico "yunque" expansivo en la tropopausa, o el profundo oscurecimiento de avance abovedado en la base (#strong[roll cloud]), exigen maniobra evasiva inmediata y la toma de decisión para aterrizar en campo o en el aeródromo alternativo despejado más cercano.

#figure([
#box(image("imagenes/03-cap09-cb.jpg"))
], caption: figure.caption(
position: bottom, 
[
Nube Cumulonimbus (Cb) en fase de madurez, mostrando su desarrollo vertical extremo (Foto: Pedro Berlinches, 2022)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap09-cumulonimbus>


#block[
#callout(
body: 
[
Las células de tormenta en desarrollo o incrustadas ("embedded Cb") dentro de capas nubosas densas (como frentes cálidos u ocluidos) pueden enmascarar su presencia. Ante pronósticos de sistemas tormentosos severos, alertas meteorológicas marcando núcleos intensos, o indicios de fuerte inestabilidad, debe priorizarse el retorno rápido y seguro a tierra.

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
=== El ciclo de vida de la célula tormentosa
<el-ciclo-de-vida-de-la-célula-tormentosa>
Una tormenta no es un objeto estático, sino un proceso con principio y fin. Entender sus tres fases ayuda a leer el cielo y a anticipar cuándo una célula es más peligrosa (#ref(<fig-03-cap09-ciclo-tormenta>, supplement: [Figura])):

+ #strong[Fase de desarrollo o cúmulo (cumulus stage)]: domina la corriente ascendente. Un cúmulo congestus crece rápidamente en vertical, alimentado por aire cálido y húmedo. Todavía no hay precipitación que llegue al suelo, pero la ascendencia ya es fuerte y desorganizada. Para el velero, la ascendencia es tentadora y engañosa: la nube aún está «cargándose».
+ #strong[Fase de madurez (mature stage)]: la más peligrosa. Coexisten la corriente ascendente y la descendente; comienza la precipitación, que arrastra aire frío hacia abajo y genera el frente de racha en superficie. Es la etapa del granizo, los rayos, la turbulencia extrema y el #strong[downburst]. La nube alcanza su máximo desarrollo vertical y aparece el yunque.
+ #strong[Fase de disipación (dissipating stage)]: domina la corriente descendente. El aire frío de la precipitación corta el suministro de aire cálido que alimentaba la célula, la ascendencia se apaga y la tormenta se deshace, dejando restos de yunque y precipitación débil. Sigue habiendo turbulencia residual.

#figure([
#box(image("imagenes/03-cap09-ciclo-tormenta.png"))
], caption: figure.caption(
position: bottom, 
[
Las tres fases del ciclo de vida de una célula tormentosa: desarrollo, madurez y disipación
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap09-ciclo-tormenta>


== Engelamiento en planeadores
<engelamiento-en-planeadores>
El engelamiento (#strong[icing]) es uno de los peligros más rápidos y silenciosos del vuelo a vela. Ocurre cuando el planeador entra en nubosidad o zonas de humedad visible con temperatura negativa ---el intervalo de mayor riesgo está entre 0 °C y -15 °C, con el máximo en torno a -10 °C, aunque puede aparecer a temperaturas más bajas. Las gotículas de agua superenfriadas se congelan en décimas de segundo al tocar el borde de ataque, la cúpula o cualquier superficie frontal de la aeronave.

No todo el hielo es igual. La escarcha aparte ---que no es engelamiento por gotícula superenfriada, sino depósito directo del vapor---, según la temperatura y el tamaño de las gotículas el engelamiento propiamente dicho adopta tres formas con efectos distintos:

- #strong[Escarcha (hoar frost)]: Cristales finos y blancos que se forman por congelación directa del vapor de agua (sublimación inversa) sobre superficies frías, sin gotícula superenfriada de por medio. Por eso, en rigor, no es engelamiento; es la forma más leve: degrada el perfil alar y puede opacar la cúpula, pero el proceso es más lento.
- #strong[Hielo opaco (rime ice)]: Se forma con gotículas pequeñas y temperaturas bajas, típicamente por debajo de -15 °C. Aspecto blanco y rugoso, se adhiere principalmente en el borde de ataque y aumenta el arrastre de forma notable.
- #strong[Hielo mixto]: Entre -10 °C y -15 °C conviven gotículas grandes y pequeñas, y el depósito combina lo peor de los otros dos: capas duras y transparentes con incrustaciones blancas y rugosas.
- #strong[Hielo claro (clear ice)]: El más peligroso. Se forma con gotículas grandes entre 0 °C y -10 °C. Se extiende en una capa transparente y dura por toda la superficie alar, añade peso, altera el equilibrio de la aeronave y destruye la sustentación laminar. Es difícil de detectar visualmente hasta que ya es grave.

En cualquiera de sus formas, las consecuencias son las mismas: la velocidad de pérdida (#strong[stall speed]) sube, la relación de planeo cae y la cúpula se opaca. El planeador no dispone de ningún sistema anti-hielo.

#block[
#callout(
body: 
[
Al primer síntoma de engelamiento ---escarcha en el borde del ala o cristales en la cúpula--- actúa de inmediato:

+ Gira 180° y sal de la zona de nubosidad.
+ Inicia el descenso hacia niveles con temperatura positiva.
+ No esperes: el engelamiento se acelera a medida que más superficie queda cubierta.

Un planeador con hielo estructural puede entrar en pérdida a velocidades muy superiores a las habituales, sin ningún síntoma previo de buffet.

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
== Turbulencias de estela y orográficas
<turbulencias-de-estela-y-orográficas>
No todas las turbulencias nacen de la meteorología: algunas las generan las propias aeronaves, y otras se esconden al abrigo de las montañas.

- #strong[Estela turbulenta (wake turbulence):] Las aeronaves grandes ---reactores pesados o turbohélices de gran tonelaje--- desprenden de las puntas de sus alas dos vórtices poderosos que giran como tornillos. Estos vórtices descienden lentamente por debajo de la senda de vuelo y pueden persistir varios minutos en zonas con poco viento. Si un planeador cruza esa estela, el vuelco puede ser instantáneo y superar la capacidad de los mandos para corregirlo. En un aeródromo con tráfico mixto, espera siempre al menos 3 minutos tras el despegue o aterrizaje de una aeronave pesada antes de usar la misma pista (#ref(<fig-03-cap09-estela-turbulenta>, supplement: [Figura])).

- #strong[Estela de helicópteros:] Los helicópteros generan flujos de aire extremadamente peligrosos debido a la enorme cantidad de energía concentrada por sus palas de rotor. Su peligro se divide en dos escenarios:

  - #strong[En vuelo estacionario o rodaje lento (hover):] El rotor proyecta un flujo descendente de alta velocidad (#strong[downwash] o #strong[rotor wash]) que impacta contra el suelo y se expande en forma de vórtices turbulentos hasta una distancia de al menos tres diámetros de rotor.
  - #strong[En vuelo de avance:] El rotor genera un par de vórtices de estela similares a los de un avión de ala fija, pero notablemente más concentrados e intensos a baja velocidad. Cruzar esta estela puede provocar una guiñada o un alabeo instantáneo e incontrolable para un planeador.

#figure([
#box(image("imagenes/03-cap09-estela-turbulenta.jpg"))
], caption: figure.caption(
position: bottom, 
[
Estudio de la NASA sobre los vórtices de las puntas de las alas, ilustra cualitativamente la turbulencia de estela.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap09-estela-turbulenta>


- #strong[Rotores (rotor turbulence):] A sotavento de una cordillera con viento fuerte, a baja altura se forma el #strong[rotor]: un cilindro de aire en rotación caótica e invisible desde fuera. Es la contrapartida peligrosa de la onda de montaña: mientras en la onda se sube con suavidad, a baja cota bajo esa misma onda el rotor puede arrebatarte el control del planeador con una única ráfaga. Si haces un remolque en zona de onda, sigue al avión remolcador con precisión, aprieta el arnés y no te acerques a la zona de rotor si puedes evitarlo (#ref(<fig-03-cap09-flujo-crestas>, supplement: [Figura])).

#figure([
#box(image("imagenes/03-cap09-flujo-crestas.jpg"))
], caption: figure.caption(
position: bottom, 
[
Flujo de aire a lo largo de diferentes crestas.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap09-flujo-crestas>


== Cizalladura (Windshear) en el circuito final
<cizalladura-windshear-en-el-circuito-final>
La #strong[cizalladura] (#strong[windshear]) es un cambio brusco de velocidad o dirección del viento que afecta al planeador en un espacio muy corto. Para el velero en aproximación es uno de los peligros más traicioneros: actúa en segundos, sin advertencia visual previa. Aparece asociada a frentes activos, zonas de convergencia, #strong[downbursts] e inversiones térmicas en capas bajas.

- #strong[Riesgo en final:] El planeador estima su energía de planeo sobre el viento de cara reinante. Si ese viento desaparece o gira a cola de forma súbita ---lo que ocurre al cruzar una cizalladura--- la velocidad aerodinámica (IAS) cae bruscamente, la sustentación se reduce y el planeador desciende de golpe. A escasa altura sobre el umbral no hay margen de recuperación: una pérdida de 10 kt de viento de cara en final puede llevar al aporrizaje (#strong[crash landing]) en pocos segundos.
- #strong[Reventones (Microbursts/Downbursts):] Íntimamente ligados a la base de cumulonimbos desarrollados que descargan lluvia intensa. Estas masas de aire frío se desploman verticalmente hacia el suelo, donde se expanden horizontalmente provocando ráfagas radiales opuestas. Entrar en una micro ráfaga durante la aproximación es extremadamente peligroso: primero el planeador experimenta una ganancia de sustentación engañosa por el viento de cara, para segundos después sufrir un hundimiento masivo por el aire descendente y el repentino viento de cola, que puede llevar a un aterrizaje forzado o accidente si no se tiene suficiente altitud y velocidad (#ref(<fig-03-cap09-cizalladura>, supplement: [Figura])).

#figure([
#box(image("imagenes/03-cap09-cizalladura.jpg"))
], caption: figure.caption(
position: bottom, 
[
Reventón (
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap09-cizalladura>


#strong[Resumen del Capítulo: Peligros para el Vuelo]

- #strong[Tormentas (Cb)]: La madre de todos los peligros. Jamás vueles bajo un Cb ni cerca de él (\< 10-20 NM). Turbulencia extrema, granizo y rayos. Si ves un yunque, da media vuelta.
- #strong[Ciclo de la tormenta]: tres fases. Desarrollo (cúmulo): ascendente dominante, sin lluvia. Madurez: ascendente y descendente juntas, granizo, rayos y #strong[downburst] --- la más peligrosa. Disipación: descendente dominante, la célula se deshace.
- #strong[Engelamiento]: El hielo destruye la aerodinámica y eleva la velocidad de pérdida sin aviso. Cuatro depósitos ---escarcha (en rigor no es engelamiento: es sublimación), hielo opaco, mixto y claro---; el #strong[clear ice] es el más peligroso por invisible e irregular. Mayor riesgo entre 0 y −15 °C. Ante hielo, sal de la nube y baja a aire cálido.
- #strong[Turbulencia]: La de estela de aviones pesados desciende lentamente y causa vuelco instantáneo (espera 3 minutos antes de usar la pista). El rotor de onda se forma a sotavento a baja cota con rotación caótica e invisible.
- #strong[Cizalladura (Windshear)]: Cambio brusco de viento en tramo final. Puede tirarte al suelo (caída de velocidad de cara). Los #strong[downbursts] (reventones) provocan primero viento de cara y luego un brusco hundimiento y viento de cola.

= Información meteorológica
<información-meteorológica>
#quote(block: true)[
Saber volar es necesario; saber leer el tiempo antes de despegar es imprescindible. En este capítulo aprenderás a interpretar METARs, TAFs, mapas SIGWX y sondeos termodinámicos aplicados al vuelo sin motor: desde descifrar un código de cuatro letras hasta decidir con criterio si el día merece o no sacar el planeador del hangar.
]

== Informes METAR y TAF
<informes-metar-y-taf>
Para la operativa del vuelo a vela, dada su intrínseca dependencia de los fenómenos atmosféricos, la capacidad de discernir e interpretar con precisión la información meteorológica aeronáutica es un requisito fundamental antes de iniciar cualquier vuelo. Los boletines estandarizados principales son el METAR y el TAF:

- #strong[METAR (Meteorological Aerodrome Report):] Consiste en un reporte observacional de las condiciones meteorológicas reales y presentes en el aeródromo. Se emite habitualmente en intervalos de 30 minutos (o 60 minutos según el aeródromo). Proporciona datos concisos sobre la dirección e intensidad del viento en superficie, visibilidad horizontal, nubosidad (cobertura y altitud de la base), temperatura ambiental, temperatura del punto de rocío y reglaje altimétrico (QNH). Frecuentemente, el mensaje concluye con un segmento de pronóstico a corto plazo tipo #NormalTok("TREND"); válido para las 2 horas posteriores (o la indicación #NormalTok("NOSIG"); si no se prevén cambios significativos).
- #strong[TAF (Terminal Aerodrome Forecast):] Es el pronóstico oficial del aeródromo. Elaborado por oficinas meteorológicas, anticipa la evolución temporal de la meteorología en la terminal para periodos de validez estandarizados que abarcan habitualmente 9, 24 o 30 horas. Emplea sintaxis de códigos de evolución y probabilidad, fundamentales para la planificación, tales como #NormalTok("TEMPO"); (fluctuaciones temporales moderadas), #NormalTok("BECMG"); (cambio gradual permanente) o #NormalTok("PROB"); (probabilidad porcentual del suceso).

Resulta imperativo para la tripulación asimilar esta codificación con fluidez. Es de especial relevancia operativa interpretar indicadores como:

- CAVOK (Ceiling And Visibility OK): Indica condiciones VFR óptimas: visibilidad horizontal igual o superior a 10 km, ausencia de nubes operativas por debajo de 5.000 ft (o por debajo de la altitud mínima en sector más alta, la que sea mayor), y ausencia de Cb o TCU (cúmulos de gran desarrollo) y de fenómenos meteorológicos significativos.
- NSC (No Significant Clouds): Ausencia de nubes por debajo de 5.000 ft y sin presencia de Cb ni TCU, aunque los criterios de visibilidad de CAVOK no se cumplan.
- Reducciones de visibilidad: Abreviaturas como #NormalTok("FG"); (Niebla / #strong[Fog]) o #NormalTok("BR"); (Neblina / #strong[Mist]) denotan condiciones de operatividad VFR marginal o restrictiva, condicionando temporalmente los despegues.

=== Ejemplo práctico de decodificación METAR
<ejemplo-práctico-de-decodificación-metar>
Veamos un ejemplo típico en un día de vuelo, paso a paso:

- #strong[METAR]: Tipo de informe (observación regular).
- #strong[LEMD]: Aeródromo (en este caso, Madrid-Barajas).
- #strong[241100Z]: Día 24 del mes, a las 11:00 UTC (hora Zulú).
- #strong[18002KT]: Viento proveniente de los 180° (sur) a 2 nudos.
- #strong[9999]: Visibilidad horizontal de 10 km o superior (excelente).
- #strong[FEW028]: Escasas nubes (#strong[Few], 1 a 2 octas) con base a 2.800 pies sobre el terreno.
- #strong[OVC040]: Cielo cubierto (#strong[Overcast], 8 octas) a 4.000 pies.
- #strong[16/09]: Temperatura ambiente 16 °C y temperatura del punto de rocío 9 °C. (Si aplicamos nuestra Regla de Oro termodinámica: (16 - 9) × 400 = 2.800 pies. Vemos que cuadra perfectamente con las nubes reportadas a 2.800 pies).
- #strong[Q1019]: Reglaje de altímetro (QNH) de 1019 hPa.
- #strong[NOSIG]: Pronóstico tipo TREND indicando que #strong[no] se esperan cambios #strong[sig]nificativos en las próximas 2 horas. El #NormalTok("="); marca el fin del mensaje.

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Aspecto], [METAR], [TAF],),
  table.hline(),
  [Tipo], [Observación real (estado actual del aeródromo)], [Pronóstico oficial (evolución esperada)],
  [Frecuencia de emisión], [Cada 30 min (o 60 min en aeródromos menores)], [1--2 veces al día (según aeródromo)],
  [Período de validez], [Instante puntual + TREND de 2 horas], [9, 24 ó 30 horas],
  [Quién lo emite], [Observador o estación automática del aeródromo], [Oficina meteorológica (AEMET)],
  [Uso principal], [Verificar las condiciones al despegar o al llegar], [Planificar el vuelo con antelación],
  [Indicadores clave], [#NormalTok("CAVOK");, #NormalTok("NSC");, #NormalTok("FG");, #NormalTok("BR");, #NormalTok("NOSIG");], [#NormalTok("TEMPO");, #NormalTok("BECMG");, #NormalTok("PROB30");, #NormalTok("PROB40");],
)
== Mapas de tiempo significativo (SIGWX)
<mapas-de-tiempo-significativo-sigwx>
Mientras que METAR y TAF cubren aeropuertos concretos, los #strong[Mapas de Tiempo Significativo (SIGWX)] muestran la meteorología esperada en grandes áreas de ruta. Son la vista de satélite de la planificación: te dicen dónde están los frentes, qué áreas de inestabilidad debes rodear y cuál es la posición de los niveles de congelación (#ref(<fig-03-cap10-sigwx>, supplement: [Figura])).

- Los SIGWX grafican la distribución de frentes (fríos, cálidos, estacionarios, ocluidos) y sistemas de presión, con sus desplazamientos previstos.
- Identifican ejes de inestabilidad como #strong[vaguadas] (#strong[troughs]), que preceden al desarrollo de cúmulos y chubascos.
- Los servicios asociados ---#strong[SIGMET], #strong[AIRMET] y #strong[GAMET]--- emiten alertas específicas: engelamiento severo (#NormalTok("SEV ICE");), turbulencia severa (#NormalTok("SEV TURB");), o peligros en ruta a baja altura (por debajo de FL100 ó FL150, que es donde volamos nosotros). Antes de un vuelo de distancia, revisar los SIGMET activos es obligatorio.

#figure([
#box(image("imagenes/03-cap10-sigwx.png"))
], caption: figure.caption(
position: bottom, 
[
Ejemplo de mapa de tiempo significativo (SIGWX) para niveles bajos.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap10-sigwx>


== Sondeos termodinámicos y curvas de temperatura
<sondeos-termodinámicos-y-curvas-de-temperatura>
#strong[↗ MÁS ALLÁ DEL EXAMEN.] Los sondeos Skew-T y los índices que se calculan sobre ellos (K, CAPE, LI) son formación de vuelo de distancia y no deberían ser materia de examen. Léelos como iniciación al cross-country.

El sondeo termodinámico es la radiografía del día: muestra cómo cambia la temperatura y la humedad con la altura en un punto geográfico dado. Se presenta en diagramas #strong[Skew-T log-P] o #strong[Stüve], accesibles gratuitamente a través de la Universidad de Wyoming, AEMET (AMA), Windy o Meteoblue, y también integrados en plataformas de pago especializadas como Skysight, Topmeteo o Meteo Parapente. Aprender a leer un sondeo te ahorrará remolques innecesarios y te avisa de las tormentas antes de que sean visibles desde el suelo (#ref(<fig-03-cap10-indices-estabilidad>, supplement: [Figura])).

#figure([
#box(image("imagenes/03-cap03-indices-estabilidad.jpg"))
], caption: figure.caption(
position: bottom, 
[
Representación de un sondeo con Windy.com sobre Fuentemilanos
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap10-indices-estabilidad>


- La línea azul muestra el punto de rocío
- la línea roja muestra la temperatura del aire
- la línea verde muestra la temperatura de una parcela ascendente
- el área rayada a lo largo del gráfico muestra la capa convectiva (nubes cúmulos)
- el gráfico del viento muestra el viento de 0-30 km/h en la parte izquierda (fondo blanco) y de 30 a la velocidad máxima en la parte derecha (fondo rojo)

Las tres lecturas clave son:

+ #strong[Base de los cúmulos (LCL):] La curva de estado y la curva del punto de rocío se cruzan a una altura: esa es la base de los cúmulos del día. Si el cruce está muy alto (\> 3.000 m), los cúmulos serán escasos o no llegarán a formarse: térmica seca, sin calle de nubes.
+ #strong[Techo térmico:] Traza la adiabática seca desde la temperatura máxima prevista. Donde esa línea vuelva a cruzar la curva de estado es el techo de las térmicas. Si ese techo sube hasta la #strong[curva de estado] muy por encima de la base, el día tendrá térmicas potentes; si el cruce es bajo, el vuelo térmico será débil.
+ #strong[Riesgo de sobredesarrollo (Cb):] Si la curva de estado se vuelve muy inestable por encima del nivel de condensación (LFC, #strong[Level of Free Convection]), los cúmulos del mediodía pueden convertirse en cumulonimbos por la tarde. Un CAPE por encima de 2.500 J/kg combinado con un K-Index por encima de 25 es la firma del día que puede acabar mal.

#block[
#callout(
body: 
[
El día de convección excepcional --- conocido coloquialmente como «día termonuclear» en el argot de competición --- tiene firma numérica precisa: K-Index entre 15 y 20, CAPE entre 1.000 y 2.500 J/kg, LI negativo, temperatura a 850 hPa varios grados por encima de la media en superficie, y vientos flojos. Busca estos índices directamente en el sondeo del día: gratuitamente en la Universidad de Wyoming, AEMET (AMA) o Windy; con más detalle soaring en Skysight, Topmeteo o Meteo Parapente.

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
== Análisis de datos y toma de decisiones
<análisis-de-datos-y-toma-de-decisiones>
Antes de salir a pista, cruza varias fuentes: es obligatorio y prudente. No te fies de un único modelo ni de un único parámetro.

- #strong[Contrasta lo que ves con lo que pronostica el modelo:] Si llegas al campo y la nubosidad está ya tapando la solana cuando el sondeo predecía actividad térmica hasta las 3 de la tarde, algo ha fallado. La realidad manda: cancela o espera.
- #strong[Criterio del comandante:] La última palabra siempre la tienes tú, no el modelo. Contrasta al menos dos fuentes independientes ---AEMET (AMA), Windy o Meteoblue para el pronóstico general; Skysight, Topmeteo o Meteo Parapente si quieres lectura orientada al vuelo a vela---, revisa el TAF del aeródromo base y de los alternos cercanos, y anota los índices K y CAPE del sondeo del día. Pero recuerda: ningún pronóstico favorable en el papel tiene más peso que lo que ves a pie de pista.

#block[
#callout(
body: 
[
AEMET ---y su plataforma aeronáutica AMA (#strong[Autoservicio Meteorológico Aeronáutico])--- es siempre la fuente pública, oficial y legalmente vinculante para tu planificación pre-vuelo (METAR, TAF, alertas, NOTAMs meteorológicos). Las plataformas generalistas como Windy o Meteoblue y las especializadas en vuelo a vela como Skysight, Topmeteo, los modelos RASP o Meteo Parapente se mencionan en este manual porque forman parte de la realidad operativa diaria, pero nunca deben sustituir al briefing meteorológico oficial de seguridad.

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
Si a pie de pista la meteorología real difiere del pronóstico favorable ---nubosidad baja inesperada, viento variable fuerte, bruma densa--- prevalece siempre lo que ves. Un vuelo cancelado nunca fue un accidente. La cultura #strong[No-Go] no es cobardía: es el criterio que define a un piloto maduro.

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
#strong[Resumen del Capítulo: Información Meteorológica]

- #strong[METAR y TAF]: Tus boletines de cabecera. METAR = foto actual (cada 30 min). TAF = pronóstico (para 9, 24 o 30h). Aprende a descodificarlos fluidamente (CAVOK indica visibilidad ≥10 km y sin nubes por debajo de 5000 ft; FG indica niebla; BR neblina).
- #strong[Mapas Significativos (SIGWX)]: Muestran frentes, zonas de turbulencia y engelamiento. Cruciales para planificar rutas largas.
- #strong[Toma de decisiones]: No te fíes de una sola fuente. Cruza datos: mapa de superficie + satélite + previsión local. Si la meteo pinta dudosa, el mejor vuelo es el que se queda en tierra (no-go).

#show: appendices.with("Apéndices", hide-parent: true)
#heading(level: 1, numbering: none)[Apéndices]
= Syllabus Oficial EASA - Meteorología
<syllabus-oficial-easa---meteorología>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Meteorología] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- 3.1. La atmósfera.
- 3.2. Viento.
- 3.3. Termodinámica.
- 3.4. Nubes y niebla.
- 3.5. Precipitación.
- 3.6. Masas de aire y frentes.
- 3.7. Sistemas de presión.
- 3.8. Climatología.
- 3.9. Peligros para el vuelo (Flight Hazards).
- 3.10. Información meteorológica.

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

== Ponte a prueba
<ponte-a-prueba>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/03-meteorologia/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

= Glosario de términos
<glosario-de-términos>
Este glosario contiene las definiciones y acrónimos más relevantes de la meteorología aeronáutica aplicables a la licencia de piloto de planeador (SPL), organizados según el programa de formación EASA AMC1 SFCL.130.

/ #strong[AIRMET (Airmen's Meteorological Information)]: #block[
Mensaje de información meteorológica para la aviación que alerta de fenómenos en ruta significativos para aeronaves que vuelan por debajo del FL100 (o FL150 en zonas montañosas). De especial relevancia para el vuelo VFR sin motor. (Mencionado en: cap. 10)
]

/ #strong[Altocúmulo lenticular (ACSL)]: #block[
Nube en forma de lenteja o platillo, estacionaria respecto al terreno a pesar de los vientos intensos. Su presencia indica flujo laminar de onda de montaña en la vertical. Es la señal visual que invita al vuelo de onda. (Mencionado en: cap. 4)
]

/ #strong[Anticiclón (H)]: #block[
Sistema de alta presión caracterizado por subsidencia (descenso suave y divergente del aire). Al descender, el aire se comprime y calienta, inhibiendo el desarrollo de nubes convectivas. En verano favorece las térmicas aunque limita su techo; en invierno puede atrapar nieblas y crear inversiones persistentes. (Mencionado en: cap. 7)
]

/ #strong[Atmósfera Estándar Internacional (ISA)]: #block[
Modelo idealizado de referencia que define los valores estándar de presión (1013,25 hPa), temperatura (15 °C) y densidad del aire a nivel del mar, con un gradiente térmico estándar de 2 °C/1.000 ft. Es la base de calibración de todos los instrumentos aeronáuticos. (Mencionado en: cap. 1)
]

/ #strong[Borrasca (Depresión / L)]: #block[
Sistema de baja presión atmosférica caracterizado por convergencia de aire en superficie que fuerza el ascenso, el enfriamiento y la formación de nubes, frentes y precipitación. Los vientos en superficie circulan en sentido antihorario en el hemisferio norte. La zona post-frontal es a menudo la más favorable para el vuelo a vela. (Mencionado en: cap. 7)
]

/ #strong[Brisa anabática (viento anabático)]: #block[
Corriente de aire ascendente que se desarrolla de día a lo largo de las laderas de montaña cuando el sol calienta las vertientes orientadas al sur antes que el fondo del valle. Es una de las principales fuentes de térmicas en terreno montañoso. (Mencionado en: cap. 2)
]

/ #strong[Brisa catabática (viento catabático)]: #block[
Corriente de aire descendente que se forma al atardecer y durante la noche cuando el aire en contacto con las laderas se enfría por radiación y desciende por gravedad. En la restitución de ambas laderas puede generar ascendencias suaves en el centro del valle. (Mencionado en: cap. 2)
]

/ #strong[Brisa marina (sea breeze)]: #block[
Viento que sopla desde el mar hacia la tierra durante el día, originado por el calentamiento diferencial entre la superficie terrestre (que se calienta más rápido) y el mar. Al encontrarse con la masa cálida continental genera una línea de convergencia que puede explotarse como fuente de ascendencias para el cross-country. (Mencionado en: cap. 2)
]

/ #strong[CAPE (Convective Available Potential Energy)]: #block[
Energía Potencial Convectiva Disponible. Cuantifica la flotabilidad acumulada de una parcela de aire desde la superficie hasta el nivel de equilibrio. Se representa como el área entre la curva de la parcela y la curva de estado en el sondeo termodinámico. Valores orientativos: \< 500 J/kg (día débil), 1.000--2.500 J/kg (excelente), \> 3.500 J/kg (convección severa probable). (Mencionado en: cap. 3, cap. 10)
]

/ #strong[CAVOK (Ceiling And Visibility OK)]: #block[
Término meteorológico aeronáutico que indica condiciones VFR óptimas: visibilidad horizontal de 10 km o más, ausencia de nubes por debajo de 5.000 ft (o la altitud mínima de sector, la mayor de ambas), ausencia de cumulonimbos (CB) o cúmulos en torre (TCU), y ausencia de fenómenos significativos. (Mencionado en: cap. 10)
]

/ #strong[Cizalladura (wind shear)]: #block[
Variación brusca de la velocidad y/o dirección del viento en una distancia corta, tanto en el plano horizontal como vertical. Especialmente peligrosa en la aproximación final, donde puede provocar una pérdida súbita de sustentación por caída de la velocidad indicada. (Mencionado en: cap. 9)
]

/ #strong[Collado barométrico (pantano barométrico)]: #block[
Región de transición entre dos anticiclones y dos borrascas opuestas en la que el gradiente de presión es prácticamente nulo. Genera vientos flojos y variables, visibilidad reducida por niebla o bruma en invierno, y riesgo de tormentas locales aisladas en verano. (Mencionado en: cap. 7)
]

/ #strong[Cumulonimbus (Cb)]: #block[
Nube de desarrollo vertical extremo que puede alcanzar la tropopausa. Representa el peligro meteorológico más grave para la aviación ligera: turbulencia severa, granizo, rayos, lluvia torrencial y microbursts. La distancia de seguridad recomendada es de al menos 10--20 NM. (Mencionado en: cap. 4, cap. 9)
]

/ #strong[Cúmulo (Cu)]: #block[
Nube convectiva de desarrollo vertical con base plana y contornos bien definidos. Su presencia indica inestabilidad y térmicas activas. La base de los cúmulos marca el nivel de condensación por ascenso (NCA/LCL) y puede calcularse con la fórmula: (T − Td) × 400 = altitud en pies. (Mencionado en: cap. 3, cap. 4)
]

/ #strong[Cúmulo congestus (Cu con)]: #block[
Fase de desarrollo vertical intenso del cúmulo, previa al cumulonimbus. Sus torres de "coliflor" con contornos aún definidos señalan convección vigorosa y riesgo de sobredesarrollo hacia Cb. Cuando la parte superior pierde definición y se hace fibrosa, el Cb ya está en marcha. (Mencionado en: cap. 4, cap. 9)
]

/ #strong[DALR (Dry Adiabatic Lapse Rate)]: #block[
Gradiente Adiabático Seco. Ritmo al que se enfría una parcela de aire sin saturar al ascender adiabáticamente: 3 °C por cada 1.000 ft. Es la clave del efecto Foehn en sotavento y de la fórmula de base de nubes. (Mencionado en: cap. 3, cap. 2)
]

/ #strong[DANA (Depresión Aislada en Niveles Altos)]: #block[
Sistema de baja presión que se desprende de la circulación general y queda aislado en altura sobre la Península Ibérica, especialmente en otoño. Genera precipitaciones intensas y tormentas severas que pueden durar días. Especialmente relevante en el área mediterránea. (Mencionado en: cap. 8)
]

/ #strong[Dorsal (cuña de altas presiones / ridge)]: #block[
Extensión de un anticiclón en forma de lengua hacia una zona de menor presión. Comparte las características del sistema origen: subsidencia, cielos despejados, buen tiempo y ausencia de ascendencias convectivas. (Mencionado en: cap. 7)
]

/ #strong[Downburst (microburst / microrráfaga)]: #block[
Corriente descendente violenta generada bajo un cumulonimbus o cúmulo congestus al precipitar. Al impactar con el suelo se expande horizontalmente en todas direcciones. Particularmente peligroso en la aproximación final: primero genera un viento de cara falso (ganancia de sustentación engañosa) y segundos después un viento de cola que puede provocar el impacto con el terreno. (Mencionado en: cap. 5, cap. 9)
]

/ #strong[Efecto Foehn (Foehn effect)]: #block[
Fenómeno por el que el aire que asciende en barlovento de una cordillera precipita y cede calor latente (siguiendo el SALR en la zona de nube), pero desciende en sotavento completamente seco, calentándose al DALR completo durante todo el descenso. La diferencia de temperatura entre los dos valles puede superar los 10--15 °C. La pared de Foehn (#strong[Foehn wall]) es la acumulación de nubes estacionaria sobre la cresta en barlovento. (Mencionado en: cap. 2)
]

/ #strong[Engelamiento (icing)]: #block[
Formación de hielo en las superficies del planeador al volar en zonas con humedad visible y temperatura negativa (especialmente entre 0 °C y −15 °C). Altera el perfil alar, aumenta la velocidad de pérdida (#strong[stall speed]) y puede opacificar la cúpula. Los planeadores no disponen de sistemas antihielo: la medida correctiva es descender a niveles de temperatura positiva. (Mencionado en: cap. 9)
]

/ #strong[Estabilidad atmosférica]: #block[
Propiedad de la atmósfera que describe la tendencia de una parcela de aire desplazada verticalmente a regresar a su posición original (estable) o a continuar alejándose (inestable). El vuelo a vela vive de la inestabilidad. Una atmósfera estable impide el desarrollo de térmicas; una inestable las fomenta. (Mencionado en: cap. 3)
]

/ #strong[Estabilidad condicional]: #block[
Estado de la atmósfera que es estable para parcelas de aire seco pero inestable para parcelas saturadas. Si el aire asciende lo suficiente para condensar, el calor latente liberado lo mantiene más caliente que el entorno y la inestabilidad se dispara. Es la clave del sobredesarrollo de cúmulos hacia cumulonimbus en días húmedos. (Mencionado en: cap. 3)
]

/ #strong[Frente cálido]: #block[
Superficie de separación entre una masa de aire cálido que avanza sobre una masa fría preexistente. El ascenso es gradual (pendiente suave), lo que produce precipitaciones débiles y continuas, techos nubosos bajos y estabilidad: condiciones operativas pobres para el vuelo a vela. Sus precursores son los cirros descendentes (Ci → Cs → As → Ns). (Mencionado en: cap. 6)
]

/ #strong[Frente frío]: #block[
Superficie de separación donde una masa de aire frío y denso avanza en cuña bajo el aire cálido, forzándolo a ascender bruscamente. El paso del frente trae precipitaciones convectivas, chubascos y vientos racheados. La fase post-frontal suele ser la mejor del año para el vuelo a vela: atmósfera limpia, inestable y con buenas térmicas bajo cúmulos bien definidos. (Mencionado en: cap. 6)
]

/ #strong[Frente ocluido (oclusión)]: #block[
Estructura frontal que se forma cuando un frente frío alcanza y fusiona con el frente cálido que le precede, pinzando el aire cálido intermedio y forzándolo a ascender. Genera condiciones complejas: precipitaciones extensas, núcleos convectivos embebidos y mala visibilidad. Poco o nada aprovechable para el vuelo a vela. (Mencionado en: cap. 6)
]

/ #strong[FZRA (Lluvia engelante / Freezing Rain)]: #block[
Precipitación líquida que cae a través de una capa con temperatura inferior a 0 °C. Las gotículas superenfriadas se congelan al impactar con las superficies del planeador, formando hielo opaco o transparente en el borde de ataque. Situación de emergencia: el único remedio es un cambio de rumbo 180° y descenso inmediato. (Mencionado en: cap. 5)
]

/ #strong[GAMET (General Area Meteorological Forecast)]: #block[
Pronóstico meteorológico de área para vuelos de aviación general por debajo del FL100, emitido por los proveedores meteorológicos nacionales. Informa de peligros como engelamiento, turbulencia, nieblas y tormentas en ruta. (Mencionado en: cap. 10)
]

/ #strong[Gotículas superenfriadas]: #block[
Gotículas de agua líquida que permanecen en estado líquido a temperaturas por debajo de 0 °C (hasta −40 °C). Son inestables: al impactar con cualquier superficie sólida se congelan casi instantáneamente. Son la causa principal del engelamiento en vuelo. (Mencionado en: cap. 5)
]

/ #strong[Granizo (GR)]: #block[
Precipitación sólida formada por capas alternas de hielo transparente y opaco, resultado de múltiples recirculaciones de las gotículas en las corrientes ascendentes de un cumulonimbus. Granos de más de 2 cm de diámetro pueden perforar la cúpula o dañar estructuralmente el fuselaje de fibra. El granizo puede caer lejos del núcleo visible del Cb, bajo el yunque. (Mencionado en: cap. 5, cap. 9)
]

/ #strong[Hipoxia]: #block[
Estado fisiológico de deficiencia de oxígeno en las células y tejidos del cuerpo humano, provocado al volar a gran altura por la reducción de la presión parcial de oxígeno en la atmósfera. (Mencionado en: cap. 1)
]

/ #strong[Inversión térmica]: #block[
Capa atmosférica en la que la temperatura aumenta con la altitud en lugar de disminuir. Actúa como techo invisible que frena las térmicas por completo, limita la altura máxima de vuelo y atrapa contaminación y bruma en los niveles inferiores, degradando la visibilidad. (Mencionado en: cap. 3)
]

/ #strong[IAS (Velocidad indicada / Indicated Air Speed)]: #block[
Velocidad de la aeronave respecto al aire circundante tal como la indica el anemómetro, sin correcciones por temperatura ni densidad. Es la referencia para todos los límites aerodinámicos y estructurales (VNE, VA, velocidades de pérdida y curva polar). (Mencionado en: cap. 9)
]

/ #strong[K-Index (índice K)]: #block[
Índice de estabilidad atmosférica que combina el gradiente vertical de temperatura entre 850 hPa y 500 hPa con la humedad en niveles medios. Es el indicador diario más usado por los volovelistas: K \< 5 (día débil), 5--15 (buenas térmicas), 15--20 (excelente), 20--30 (excelente con chubascos), \> 30 (alta probabilidad de tormentas). (Mencionado en: cap. 3, cap. 10)
]

/ #strong[LCL (Nivel de Condensación por Elevación / Lifted Condensation Level)]: #block[
Altitud a la que una parcela de aire, al ser elevada adiabáticamente, alcanza su punto de saturación y comienza a condensar. En la práctica, es la altura de la base de los cúmulos. En el sondeo Skew-T se obtiene donde la curva de temperatura de la parcela intersecta la curva del punto de rocío. (Mencionado en: cap. 3, cap. 10)
]

/ #strong[LFC (Nivel de Convección Libre / Level of Free Convection)]: #block[
Altitud por encima de la cual una parcela de aire levantada artificialmente se vuelve más cálida que el entorno y asciende libremente sin necesidad de fuerza externa. Su cruce indica que la convección puede dispararse de forma autónoma. Si es demasiado bajo en un día caluroso, el riesgo de sobredesarrollo hacia Cb es alto. (Mencionado en: cap. 10)
]

/ #strong[LI (Índice de Levantamiento / Lifted Index)]: #block[
Diferencia entre la temperatura del ambiente y la de una parcela elevada adiabáticamente desde la superficie hasta el nivel de 500 hPa. Valores negativos indican inestabilidad: cuanto más negativo, mayor el potencial convectivo y la fuerza de las térmicas. (Mencionado en: cap. 3, cap. 10)
]

/ #strong[Línea de convergencia]: #block[
Franja del espacio aéreo donde dos masas de aire de distinta procedencia se encuentran y el aire se ve forzado a ascender. Puede originarse por el choque de la brisa marina con la masa continental, por vientos catabáticos de dos laderas opuestas (restitución) o por diferencias orográficas. Ofrece ascendencias continuas y regulares, ideales para el vuelo de distancia. (Mencionado en: cap. 2, cap. 8)
]

/ #strong[Masa de aire]: #block[
Gran volumen de aire troposférico con propiedades físicas (temperatura y humedad) horizontalmente homogéneas adquiridas en su zona de origen. Su temperatura relativa respecto al suelo que sobrevuela determina si la atmósfera es inestable (aire frío sobre suelo caliente) o estable (aire cálido sobre suelo frío). (Mencionado en: cap. 6)
]

/ #strong[METAR (Meteorological Aerodrome Report)]: #block[
Informe meteorológico observacional codificado de un aeródromo que se emite a intervalos regulares (30 o 60 minutos), reportando viento, visibilidad, nubes, temperatura, punto de rocío y presión. (Mencionado en: cap. 10)
]

/ #strong[Microburst (microrráfaga)]: #block[
Ver Downburst.
]

/ #strong[Modelo burbuja (bubble model)]: #block[
Modelo conceptual de la térmica en el que el calor se acumula sobre la fuente hasta que la masa de aire se desprende formando un vórtice anular. El ascenso es intermitente y el núcleo central sube más rápido que los bordes. El planeador debe centrarse en el núcleo para obtener el máximo ascenso. (Mencionado en: cap. 3)
]

/ #strong[Modelo columna / pluma (column/plume model)]: #block[
Modelo conceptual de la térmica en el que fuentes de calor intensas y persistentes generan un flujo convectivo continuo, similar al humo de una chimenea. El ascenso es más regular y duradero que en el modelo burbuja. Favorece el vuelo de distancia al reducir las maniobras de centrado. (Mencionado en: cap. 3)
]

/ #strong[NCA (Nivel de Condensación por Ascenso)]: #block[
Ver LCL. En terminología española, equivalente al LCL: la altura a la que se forma la base de los cúmulos. Estimación rápida: (T − Td) × 400 = altura en pies. (Mencionado en: cap. 3)
]

/ #strong[Niebla]: #block[
Suspensión de gotículas de agua microscópicas que reduce la visibilidad por debajo de 1.000 m. Invalida las operaciones VFR. Se distingue de la bruma (#strong[mist]), que reduce la visibilidad entre 1.000 m y 5.000 m sin afectar el código CAVOK. En METAR se codifica como #NormalTok("FG"); (niebla) o #NormalTok("BR"); (bruma). (Mencionado en: cap. 4, cap. 10)
]

/ #strong[Niebla de radiación]: #block[
Niebla que se forma durante las noches despejadas de otoño e invierno cuando el suelo pierde calor por radiación hacia el espacio, enfría el aire en contacto hasta el punto de rocío y produce condensación. Puede ser muy densa y persistir hasta mediados de la mañana. Especialmente frecuente en anticiclones invernales con vientos flojos. (Mencionado en: cap. 4, cap. 7)
]

/ #strong[Niebla de advección]: #block[
Niebla que se forma cuando una masa de aire cálido y húmedo se desplaza horizontalmente sobre una superficie más fría (mar frío, valle nevado o costa), que enfría su base hasta la saturación. A diferencia de la de radiación, no depende del enfriamiento nocturno y puede persistir día y noche mientras dure el flujo. (Mencionado en: cap. 4)
]

/ #strong[NSC (No Significant Clouds)]: #block[
Indicador en METAR/TAF que señala ausencia de nubes por debajo de 5.000 ft y ausencia de cumulonimbus. A diferencia de CAVOK, no implica visibilidad ≥ 10 km. (Mencionado en: cap. 10)
]

/ #strong[Onda de montaña (wave soaring)]: #block[
Oscilación ondulatoria del flujo de aire que se genera a sotavento de una cordillera cuando el viento es perpendicular a la cresta, supera un umbral de velocidad y existe una capa estable a la altura de la cresta. Permite el ascenso laminar hasta grandes altitudes. Los altocúmulos lenticulares son su señal visual. Los rotores en la base son el principal peligro. (Mencionado en: cap. 4)
]

/ #strong[QNH]: #block[
Reglaje altimétrico que ajusta el altímetro para indicar la altitud sobre el nivel del mar en condiciones ISA. Es la referencia estándar para el vuelo VFR. (Mencionado en: cap. 1, cap. 10)
]

/ #strong[Rotor]: #block[
Vórtice turbulento de pequeña escala que se forma a sotavento del pie de una ladera o cordillera bajo la primera cresta de la onda de montaña. Genera turbulencia severa e impredecible a baja altura. Las nubes de rotor (#strong[rotor clouds]) son estratos irregulares bajo la onda que señalan esta zona peligrosa. (Mencionado en: cap. 4, cap. 9)
]

/ #strong[SALR (Saturated Adiabatic Lapse Rate)]: #block[
Gradiente Adiabático Saturado. Ritmo al que se enfría una parcela de aire saturada (en formación de nube) al ascender adiabáticamente: aproximadamente 1,5 °C por cada 1.000 ft. Es menor que el DALR porque la condensación libera calor latente que "frena" el enfriamiento. (Mencionado en: cap. 3, cap. 2)
]

/ #strong[SIGMET (Significant Meteorological Information)]: #block[
Mensaje de alerta que informa a las tripulaciones de fenómenos meteorológicos en ruta de gran relevancia para la seguridad: engelamiento severo (#NormalTok("SEV ICE");), turbulencia severa (#NormalTok("SEV TURB");), actividad de cenizas volcánicas o ciclones tropicales. (Mencionado en: cap. 10)
]

/ #strong[SIGWX (Significant Weather Chart)]: #block[
Mapa de Tiempo Significativo. Pronóstico a escala sinóptica que muestra la distribución de sistemas frontales, zonas de turbulencia e engelamiento, y otras áreas de meteorología significativa en una región geográfica. Imprescindible para la planificación de vuelos de distancia. (Mencionado en: cap. 10)
]

/ #strong[Sondeo termodinámico (Skew-T / Stüve)]: #block[
Diagrama que representa el perfil vertical de temperatura, temperatura del punto de rocío y viento en la atmósfera, obtenido mediante radiosondeo. Permite al piloto estimar la altura de las bases de cúmulos (LCL), el techo térmico, el riesgo de sobredesarrollo (LFC) y los índices de estabilidad (K-Index, CAPE, LI). (Mencionado en: cap. 10)
]

/ #strong[Stau]: #block[
Efecto complementario al Foehn: acumulación de nubes y precipitación intensa en la ladera de barlovento de una cordillera, donde el aire húmedo asciende y condensa. Mientras en barlovento llueve (Stau), en sotavento el cielo puede estar despejado y la temperatura es varios grados más alta (Foehn). (Mencionado en: cap. 2)
]

/ #strong[TAF (Terminal Aerodrome Forecast)]: #block[
Pronóstico meteorológico codificado que describe las condiciones meteorológicas esperadas en un aeródromo específico durante un periodo de tiempo determinado (típicamente 9, 24 o 30 horas). (Mencionado en: cap. 10)
]

/ #strong[Térmica]: #block[
Corriente convectiva ascendente de aire formada por el calentamiento diferencial del suelo. El sol calienta el terreno, el terreno calienta el aire en contacto y este asciende por flotabilidad. Es la fuente principal de sustentación en el vuelo a vela de distancia. Su intensidad depende del diferencial de temperatura suelo--atmósfera libre. (Mencionado en: cap. 3)
]

/ #strong[Tropopausa]: #block[
Límite superior de la troposfera, donde el gradiente térmico se anula y la temperatura se estabiliza. A media latitud se sitúa entre 8.000 m (invierno) y 12.000 m (verano). El yunque del cumulonimbus se extiende horizontalmente al alcanzar esta capa, que actúa como techo para la convección. (Mencionado en: cap. 1, cap. 4)
]

/ #strong[Troposfera]: #block[
Capa inferior de la atmósfera, desde el suelo hasta la tropopausa, donde se producen la totalidad de los fenómenos meteorológicos relevantes para la aviación. Contiene aproximadamente el 75 % de la masa del aire y casi todo el vapor de agua atmosférico. (Mencionado en: cap. 1)
]

/ #strong[Turbulencia de estela (wake turbulence)]: #block[
Vórtices tubulares contrarrotantes generados por el paso de aeronaves de ala fija al producir sustentación, o por el flujo y vórtices de rotor de los helicópteros. Descienden lentamente y persisten varios minutos después del paso de la aeronave. Cruzarlos perpendicularmente puede inducir un momento de balanceo que supere los alerones del planeador. La separación mínima recomendada es de al menos 3 minutos tras aeronaves pesadas y 3 diámetros de rotor en proximidad de helicópteros en estacionario. (Mencionado en: cap. 9)
]

/ #strong[Vaguada (surco de bajas presiones / trough)]: #block[
Extensión de una borrasca en forma de lengua alargada hacia una zona de mayor presión. Concentra los efectos de la baja presión: inestabilidad, cúmulos convectivos, chubascos y turbulencia. Genera líneas de convergencia dinámica. (Mencionado en: cap. 7)
]

/ #strong[Viento geostrófico]: #block[
Viento que sopla paralelo a las isobaras en niveles superiores a 1.000 m sobre el suelo, resultado del equilibrio entre la fuerza del gradiente de presión y la fuerza de Coriolis. En superficie, la fricción rompe este equilibrio y el viento cruza las isobaras hacia la baja presión con un ángulo de unos 30°. (Mencionado en: cap. 2)
]

/ #strong[Virga]: #block[
Precipitación que cae desde la base de una nube pero se evapora antes de alcanzar el suelo. La evaporación absorbe calor de la columna de aire, que se vuelve densa y desciende violentamente generando una microrráfaga (#strong[downburst]). La virga es un aviso visual de turbulencia severa y cizalladura debajo de ella, incluso en cielos aparentemente despejados. (Mencionado en: cap. 5, cap. 9)
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
