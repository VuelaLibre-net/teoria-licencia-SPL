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
  title: [Navegación],
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

#heading(level: 1, numbering: none)[Navegación]
<navegación>
Bienvenido a la versión digitalizada de este manual de formación SPL.

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

#heading(level: 1, numbering: none)[Introducción]
<introducción>
#strong[#emph[Tema 9 de 9 del examen teórico para la Licencia de Piloto de Planeador (SPL)]]

Un planeador no puede pedir más altura si la estimación fue mal. No puede esperar si la posición es incierta. No tiene margen para el "más o menos" cuando la térmica no aparece y el aeródromo alternativo está al límite del alcance.

Siete capítulos cubren desde el sistema de coordenadas hasta los servicios ATS en ruta, pasando por la cartografía, la brújula, la estima y el GPS: las herramientas que garantizan que siempre sabes dónde estás ---y dónde estarás.

La navegación en vuelo a vela no es saber dónde estás. Es saber siempre dónde estarás.

= Fundamentos de navegación
<fundamentos-de-navegación>
#quote(block: true)[
Navegar es, en esencia, llevar el planeador de un punto a otro con seguridad y sin malgastar energía. Para eso hacen falta dos cosas: entender cómo nos movemos sobre la esfera terrestre y saber medir nuestra posición y el tiempo.

En este capítulo aprenderás:

- #strong[El sistema de coordenadas]: latitud y longitud, y por qué un minuto de latitud es siempre una milla náutica.
- #strong[Ortodrómica y loxodrómica]: la ruta más corta frente a la de rumbo constante, y cuál vuelas en realidad.
- #strong[El tiempo en aviación]: qué es UTC (hora Zulu) y por qué toda la aviación trabaja con él.
- #strong[Orto, ocaso y vuelo diurno]: dónde está el límite legal de la luz para un planeador.
- #strong[Las unidades náuticas]: la milla náutica y el nudo, y cómo pensar en ellas de cabeza.
]

== El sistema de coordenadas: Latitud y Longitud
<el-sistema-de-coordenadas-latitud-y-longitud>
Para situarnos en cualquier parte del mundo, utilizamos una red imaginaria de líneas que envuelven la Tierra.

- #strong[Latitud (Paralelos)]: Son círculos paralelos al Ecuador que miden la distancia al norte o al sur. El Ecuador es la latitud 0º.
- #strong[Longitud (Meridianos)]: Son semicírculos que van de polo a polo. El Meridiano de Greenwich es la longitud 0º.

Esta red de paralelos y meridianos (#ref(<fig-09-cap01-coordenadas>, supplement: [Figura])) nos permite situar con precisión cualquier punto de la Tierra.

#block[
#callout(
body: 
[
Recuerda siempre esta equivalencia fundamental: #strong[1 minuto de latitud equivale a 1 milla náutica]. Esto te permite calcular distancias directamente sobre los meridianos de una carta aeronáutica.

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
#box(image("imagenes/09-cap01-coordenadas.jpg"))
], caption: figure.caption(
position: bottom, 
[
Sistema de coordenadas terrestres (Latitud y Longitud)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap01-coordenadas>


== Ortodrómica y Loxodrómica
<ortodrómica-y-loxodrómica>
Cuando trazas una línea en el mapa, conviene saber qué estás dibujando en realidad sobre una Tierra que es curva.

- #strong[Ortodrómica (Círculo Máximo)]: Es la distancia más corta entre dos puntos. Sin embargo, en un círculo máximo el rumbo cambia constantemente a medida que cruzamos meridianos.
- #strong[Loxodrómica (Línea de Rumbo)]: Es una línea que corta todos los meridianos con el mismo ángulo. Es más cómoda de volar porque mantenemos un rumbo constante, aunque el camino sea ligeramente más largo.

#block[
#callout(
body: 
[
En las distancias que manejamos habitualmente en vuelo a vela (vuelos de 300, 500 o incluso 1000 km), la diferencia entre la ruta ortodrómica y la loxodrómica es insignificante. Siempre volamos rumbos constantes (loxodrómicas) por sencillez.

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
== El tiempo en aviación: UTC y Zulu
<el-tiempo-en-aviación-utc-y-zulu>
Cruzar husos horarios y arrastrar los cambios de hora estacionales sería un lío al planificar un vuelo. Por eso la aviación trabaja con una sola referencia: el #strong[Tiempo Universal Coordinado (UTC)].

También lo conocemos como #strong[Hora Zulu (Z)]. Es la hora en el meridiano 0º (Greenwich). Cuando recibes un METAR o un NOTAM, la hora siempre vendrá en formato Zulu.

#block[
#callout(
body: 
[
#strong[SAO.IDE.105] exige que todo planeador lleve un medio para medir y mostrar la hora en horas y minutos. Llévalo ajustado a UTC o ten clara la diferencia horaria del día (en España, +1h en invierno y +2h en verano respecto a UTC).

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
== Orto, ocaso y vuelo diurno
<orto-ocaso-y-vuelo-diurno>
Planificar la hora de un vuelo a vela no es solo cuestión de térmicas: la luz del día marca un límite legal y de seguridad que conviene conocer.

- #strong[Orto]: el amanecer, cuando el borde superior del disco solar asoma por el horizonte este.
- #strong[Ocaso]: el atardecer, cuando el borde superior del disco solar desaparece por el horizonte oeste.

No confundas el ocaso con el principio de la noche. Para la aviación, la #strong[noche] es el periodo entre el final del #strong[crepúsculo civil] vespertino y el inicio del matutino, y el crepúsculo civil termina (o empieza) cuando el centro del sol está #strong[6º por debajo del horizonte]. Es decir: tras el ocaso aún queda un rato de luz utilizable antes de que, oficialmente, sea de noche.

#block[
#callout(
body: 
[
El vuelo en planeador se realiza en condiciones visuales (VFR) y, con carácter general, #strong[de día]. La operación nocturna en VMC solo está al alcance del titular SPL con privilegios de motovelero de turismo (TMG) y la correspondiente #strong[habilitación de vuelo nocturno], además del equipamiento de luces exigido. Consulta siempre la hora del ocaso al planificar: en altura tendrás luz un rato más, pero una vez abajo la oscuridad llega rápido. Las horas oficiales de orto y ocaso para cada aeródromo se publican en el AIP-España (GEN 2.7).

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
== Unidades de medida estándar
<unidades-de-medida-estándar>
En el entorno internacional, y especialmente en España bajo normativa EASA, utilizamos unidades náuticas para la navegación horizontal:

- #strong[Milla Náutica (NM)]: 1 NM = 1852 metros.
- #strong[Nudo (kt)]: Es una unidad de velocidad que equivale a 1 milla náutica por hora.

Aunque es común ver anemómetros en kilómetros por hora (km/h) en muchos planeadores europeos de diseño clásico, la navegación y las cartas aeronáuticas se basan en millas náuticas y nudos. Aprender a pasar de unos a otros mentalmente es una habilidad muy útil en el hangar.

#postit[
#strong[Resumen del Capítulo: Fundamentos de Navegación]

- #strong[Coordenadas]: Latitud (Paralelos, N/S) y Longitud (Meridianos, E/W). Recuerda: 1 minuto de Latitud es siempre 1 Milla Náutica. 1 minuto de Longitud varía con la latitud.
- #strong[Ortodrómica vs Loxodrómica]: La Ortodrómica es la distancia más corta (círculo máximo) pero cambia de rumbo continuamente. La Loxodrómica mantiene el rumbo constante (corta a los meridianos igual) pero es más larga. En distancias de planeador, la diferencia es despreciable.
- #strong[El Tiempo]: En aviación usamos UTC (Universal Time Coordinated) o "Zulu" para evitar confusiones con los husos horarios locales y cambios de hora.
- #strong[Unidades]: Acostúmbrate a pensar en Millas Náuticas (NM) y Nudos (kts). Son el estándar internacional y facilitan los cálculos mentales (1 grado de latitud = 60 NM).

]
= Magnetismo y brújulas
<magnetismo-y-brújulas>
#quote(block: true)[
La brújula magnética es probablemente el instrumento más sencillo y fiable de la cabina. No gasta batería ni depende del tubo pitot: se limita a alinearse con el campo magnético terrestre. Eso sí, para sacarle partido hay que conocer sus manías.

En este capítulo aprenderás:

- #strong[El norte verdadero y el magnético]: la variación (declinación) y la regla "Declinación Oeste, rumbo suma".
- #strong[El desvío y la tablilla]: por qué el propio planeador engaña a la brújula y cómo se compensa.
- #strong[Los errores de viraje]: por qué la brújula se adelanta o se retrasa al virar hacia el Norte o el Sur.
- #strong[Los errores de aceleración (ANDS)]: las lecturas falsas al acelerar o frenar en rumbos Este-Oeste.
]

== Norte Verdadero vs.~Norte Magnético
<norte-verdadero-vs.-norte-magnético>
Aunque solemos pensar en "el Norte" como un punto único, en navegación distinguimos dos:

- #strong[Norte Verdadero (Geográfico)]: Es el punto por donde pasa el eje de rotación de la Tierra. Es el norte que verás en los mapas y cartas aeronáuticas.
- #strong[Norte Magnético]: Es el punto hacia el que apuntan las agujas de nuestras brújulas. Curiosamente, este punto no es fijo y se desplaza ligeramente cada año.

La diferencia angular entre ambos se denomina #strong[Variación Magnética] o #strong[Declinación]. En las cartas aeronáuticas, verás unas líneas discontinuas llamadas #strong[isogónicas] que indican el valor de esta variación en cada zona.

#block[
#callout(
body: 
[
Para los cálculos, recuerda esta rima: #strong["Declinación Oeste, Rumbo Suma"] (si la variación es hacia el oeste, el rumbo magnético será mayor que el verdadero).

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
== El Desvío y la Tablilla
<el-desvío-y-la-tablilla>
El planeador no es un entorno magnéticamente puro. Los tubos de acero del fuselaje, los altavoces de la radio y los instrumentos electrónicos generan sus propios campos magnéticos que "engañan" a la brújula. Este error local se llama #strong[Desvío].

Para compensarlo, cada aeronave debe tener una #strong[Tablilla de Desvíos] instalada a la vista del piloto (#ref(<fig-09-cap02-tablilla-desvios>, supplement: [Figura])).

#figure([
#box(image("imagenes/09-cap02-tablilla-desvios.jpg"))
], caption: figure.caption(
position: bottom, 
[
Ejemplo de Tablilla de Desvíos de una brújula
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap02-tablilla-desvios>


== Errores dinámicos de la brújula
<errores-dinámicos-de-la-brújula>
La brújula magnética solo es totalmente fiable cuando volamos en línea recta, nivelados y a velocidad constante. En cualquier otro estado, sufre errores debidos al "dip" magnético (la inclinación de las líneas de fuerza hacia el suelo).

=== Errores de Viraje
<errores-de-viraje>
Cuando viramos para interceptar un rumbo Norte o Sur, la brújula se adelanta o se retrasa. El error es máximo al pasar por el N/S y nulo en el E/W.

- #strong[Viraje al Norte]: La brújula se queda atrás (indica menos viraje del real).
- #strong[Viraje al Sur]: La brújula se adelanta (indica más viraje del real).

#block[
#callout(
body: 
[
Usa el mnemotécnico #strong[NO me paso / Si me paso]: Al virar hacia el #strong[Norte], detén el viraje antes de que la brújula llegue al 360 (#strong[NO] llegues). Al virar hacia el #strong[Sur], deja que la brújula pase del 180 antes de nivelar (#strong[SI] pásate).

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
=== Errores de Aceleración (ANDS)
<errores-de-aceleración-ands>
Si aceleramos o frenamos mientras volamos con rumbos Este u Oeste, la inercia del sistema pendular de la brújula provoca lecturas falsas:

- #strong[Acelerar]: La brújula indica un viraje hacia el Norte.
- #strong[Decelerar]: La brújula indica un viraje hacia el Sur.

Recordamos esto con la regla inglesa #strong[ANDS]: #strong[A]ccelerate #strong[N]orth, #strong[D]ecelerate #strong[S]outh. Es decir: al #strong[acelerar], la brújula tiende al #strong[Norte]\; al #strong[decelerar], tiende al #strong[Sur].

#postit[
#strong[Resumen del Capítulo: Magnetismo y Brújulas]

- #strong[Norte Verdadero vs Magnético]: La brújula apunta al Norte Magnético, que no coincide con el Geográfico (Verdadero). La diferencia es la #strong[Variación (o Declinación)]. Regla: "Declinación Oeste, Rumbo Suma".
- #strong[Desvío]: El propio avión tiene campos magnéticos (tubos de acero, radios) que afectan a la brújula. Este error es el #strong[Desvío] y se corrige con la tablilla de desvíos de la cabina.
- #strong[Errores de la Brújula]: La brújula solo dice la verdad en vuelo recto y nivelado (y no acelerado).
- #strong[Error de Viraje]: Al virar al Norte, la brújula se queda atrás (vas corto: NO te pases); al Sur se adelanta (déjala pasar: SÍ te pasas).
- #strong[Error de Aceleración]: Al acelerar en rumbos E/W, marca viraje al Norte; al frenar, al Sur (regla #strong[ANDS]: #strong[Accelerate North, Decelerate South]).

]
= Cartas aeronáuticas
<cartas-aeronáuticas>
#quote(block: true)[
Una carta aeronáutica no es un simple mapa; es un instrumento de vuelo que debemos aprender a leer con la misma fluidez que el variómetro. En España, nuestra referencia fundamental es la serie de cartas VFR 1:500.000 publicadas por ENAIRE.

En este capítulo aprenderás:

- #strong[La proyección Lambert]: por qué la cartografía aeronáutica la eligió y qué ventajas tiene para volar.
- #strong[La escala 1:500.000]: cómo traducir los centímetros del papel a kilómetros y millas del terreno.
- #strong[La simbología]: espacios aéreos, zonas P/R/D, obstáculos y la diferencia entre AMSL y AGL.
- #strong[El relieve y la Altitud Mínima de Área (AMA)]: la red de seguridad que te da la carta sobre el terreno.
]

== La Proyección Conforme de Lambert
<la-proyección-conforme-de-lambert>
Representar una superficie esférica sobre un papel plano siempre introduce deformaciones, y cada familia de proyecciones decide qué sacrificar. Las #strong[cilíndricas] (como la Mercator/UTM) mantienen los rumbos como líneas rectas pero deforman mucho las distancias al alejarse del ecuador; las #strong[azimutales] proyectan sobre un plano tangente; y las #strong[cónicas], sobre un cono. La aviación en latitudes medias eligió la cónica conforme de #strong[Lambert].

Se la llama "conforme" porque conserva con gran fidelidad los ángulos y las formas del terreno.

Para nosotros, tiene dos ventajas clave: \* #strong[Escala constante]: Podemos usar una regla de navegación en cualquier parte de la carta y la medida será fiable. \* #strong[Líneas rectas]: Una línea recta trazada en esta carta se aproxima mucho a un círculo máximo (ortodrómica), que es la ruta más corta sobre la Tierra.

== Entendiendo la Escala
<entendiendo-la-escala>
La escala estándar que manejamos es #strong[1:500.000]. Esto significa que cualquier distancia medida sobre el papel es 500.000 veces mayor en la realidad.

Para facilitar el cálculo mental en cabina, recuerda: \* #strong[1 cm en la carta = 5 kilómetros] en el terreno. \* #strong[1 cm en la carta ≈ 2.7 Millas Náuticas (NM)].

Con una simple regla de navegación medimos sobre la carta y trasladamos la distancia al terreno; la barra de escala de la #ref(<fig-09-cap03-carta-enaire>, supplement: [Figura]) permite hacerlo de un vistazo.

== Simbología y Espacios Aéreos
<simbología-y-espacios-aéreos>
Una carta viene cargada de información, y parte del oficio es saber filtrarla. Lo que más nos interesa a los pilotos de planeador es esto:

- #strong[Espacios Aéreos]: Se representan con bordes de colores (azul, magenta, verde) y códigos que indican su clase (A, C, D…​) y sus límites verticales (ej: #NormalTok("FL100 / 2500ft");).
- #strong[Zonas restringidas]: Identificadas con letras (P - Prohibida, R - Restringida, D - Peligrosa) seguidas de un número (ej: #NormalTok("LER-71");).
- #strong[Obstáculos]: Torres, antenas y aerogeneradores. Verás dos números junto al símbolo de obstáculo: el que no tiene paréntesis es la altitud sobre el nivel del mar (AMSL); el que está entre paréntesis es la altura real sobre el terreno (AGL).

#block[
#callout(
body: 
[
Presta especial atención a los tendidos de alta tensión y los parques eólicos, especialmente si estás planificando un posible aterrizaje en campo. En la carta se representan con líneas negras finas con marcas transversales o símbolos de aspas.

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
== El relieve y la Altitud Mínima de Área (AMA)
<el-relieve-y-la-altitud-mínima-de-área-ama>
El terreno se representa mediante #strong[tintas hipsométricas] (cambios de color: verde para valles, marrones para montañas) y curvas de nivel.

En cada cuadrícula de la carta (formada por paralelos y meridianos cada 30 minutos), verás un número grande acompañado de uno más pequeño en superíndice (ej: 4#super[7], que se lee 4.700 ft). Es la #strong[Altitud Mínima de Área (AMA)] (#ref(<fig-09-cap03-carta-enaire>, supplement: [Figura])).

#figure([
#box(image("imagenes/09-cap03-carta-enaire-ama.png"))
], caption: figure.caption(
position: bottom, 
[
Carta de vuelo visual de ENAIRE del Pirineo aragonés (zona de Santa Cilia de Jaca): la cuadrícula AMA sobre terreno de alta montaña
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap03-carta-enaire>


#block[
#callout(
body: 
[
La AMA garantiza una separación mínima de #strong[1000 pies] (o 2000 pies en zonas de alta montaña) sobre el obstáculo más alto de ese cuadrante. Es tu "red de seguridad" si pierdes la visibilidad o necesitas navegar con seguridad sobre el relieve.

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
#strong[Resumen del Capítulo: Cartas Aeronáuticas]

- #strong[Proyección Lambert]: Es la estándar para cartas VFR (1:500.000). Es "conforme" (mantiene las formas) y una línea recta es una ortodrómica (ruta más corta). La escala es prácticamente constante entre los dos paralelos estándar de la proyección (la zona útil de la carta).
- #strong[Simbología]: Debes leer una carta con fluidez. Conoce los símbolos de obstáculos (la cifra sin paréntesis es la altitud sobre el nivel del mar ---AMSL---; la que va entre paréntesis es la altura sobre el terreno ---AGL---), los espacios aéreos (clases A a G) y las zonas P/R/D (prohibida, restringida, peligrosa), además de los aeródromos.
- #strong[Escala]: 1:500.000 significa que 1 cm en el papel son 5 km en la realidad.
- #strong[Elevaciones]: Las tintas hipsométricas (colores del terreno) te dan una idea rápida del relieve. La #strong[Altitud Mínima de Área (AMA)] ---no "cota máxima"--- es el número grande en cada recuadro. Proporciona separación mínima de 1000 ft sobre el obstáculo más alto de esa zona.

]
= Navegación por estima
<navegación-por-estima>
#quote(block: true)[
Navegar a estima consiste en deducir dónde estás partiendo de un punto conocido y aplicando rumbo, velocidad y tiempo transcurrido. Es lo que te permite alejarte del campo sabiendo siempre dónde estás, aunque el GNSS se apague.

En este capítulo aprenderás:

- #strong[El triángulo de velocidades]: TAS, viento y GS, y la diferencia entre IAS, TAS y GS.
- #strong[La deriva y el ángulo de corrección (WCA)]: cómo "meter el morro al viento" para no salirte de ruta.
- #strong[La cadena de rumbos]: pasar de la trayectoria de la carta al número de la brújula con la convención (W−/E+), con un ejemplo resuelto.
- #strong[El cálculo de deriva y velocidad suelo]: las fórmulas mentales rápidas, con ejemplos numéricos.
- #strong[Tiempo, velocidad y distancia]: la aritmética que cierra la estima.
- #strong[La regla del 1 en 60]: corregir el rumbo sobre la marcha sin transportador.
]

== El Triángulo de Velocidades
<el-triángulo-de-velocidades>
Todo en navegación por estima se resume en un triángulo vectorial compuesto por tres elementos:

+ #strong[TAS (Velocidad Verdadera)]: Tu velocidad respecto a la masa de aire. Es el vector que marca hacia dónde apunta el planeador.
+ #strong[Viento]: La dirección e intensidad de la masa de aire en la que flotas.
+ #strong[GS (Velocidad Suelo)]: Es la resultante. Tu velocidad real sobre el terreno y la trayectoria que realmente vas a "dibujar" en el mapa.

La suma vectorial de estos tres elementos es la base de todos los cálculos de este capítulo (véase #ref(<fig-09-cap04-triangulo-velocidades>, supplement: [Figura])).

#block[
#callout(
body: 
[
No confundas las tres velocidades que entran en juego: la #strong[IAS] (indicada) es la que marca el anemómetro; la #strong[TAS] (verdadera) es la IAS corregida por densidad ---crece aproximadamente un #strong[2 % por cada 300 m] de altitud, unos 6,5-7 % por cada 1.000 m---; y la #strong[GS] (suelo) es la TAS combinada con el viento. En navegación siempre razonamos con #strong[TAS] y #strong[GS], nunca con la IAS a secas. (El #strong[Libro 7 --- Planificación] usa esta misma regla en su forma «2 % por 300 m».)

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
#figure([
#box(image("imagenes/09-cap04-triangulo-viento.jpg"))
], caption: figure.caption(
position: bottom, 
[
El triángulo de viento en navegación aérea
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap04-triangulo-velocidades>


== Deriva y Ángulo de Corrección (WCA)
<deriva-y-ángulo-de-corrección-wca>
Si el viento sopla de costado, nos "arrastrará" fuera de nuestra ruta deseada. Este efecto se llama #strong[Deriva] (#strong[Drift]). Para compensarlo, debemos apuntar el morro del planeador ligeramente hacia el viento. Ese ajuste es el #strong[Ángulo de Corrección de Deriva] (#strong[Wind Correction Angle - WCA]).

#block[
#callout(
body: 
[
"Mete el morro al viento". Si el viento viene de la derecha, tu ángulo de corrección debe ser a la derecha (sumar grados a tu trayectoria deseada).

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
== La cadena de rumbos: De la carta a la brújula
<la-cadena-de-rumbos-de-la-carta-a-la-brújula>
Para saber qué número exacto debemos ver en nuestra brújula para seguir una línea trazada en el mapa, seguimos este proceso lógico:

+ #strong[TC (Trayectoria Verdadera)]: El ángulo medido en la carta con el transportador.
+ #strong[TH (Rumbo Verdadero de Proa)]: Aplicamos el WCA (TC WCA = TH).
+ #strong[MH (Rumbo Magnético)]: Aplicamos la Variación magnética (TH VAR = MH).
+ #strong[CH (Rumbo de Brújula)]: Aplicamos el Desvío de nuestra aeronave (MH DEV = CH).

#block[
#callout(
body: 
[
En el aire, solemos simplificar. Si el viento es suave, el WCA será pequeño. Pero nunca ignores la Variación si estás volando en zonas donde esta es significativa, ya que un error de 5 grados puede sacarte de ruta 8 km tras volar 100 km.

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
El signo es lo que más despista. La regla es sencilla: sobre el rumbo verdadero, una variación o desvío al #strong[Oeste (W) suma] grados, y al #strong[Este (E) resta]. En las fórmulas lo escribimos como #strong[\(W −) / (E +)]: el valor Oeste entra con signo negativo dentro del paréntesis y, al restarlo, acaba sumando. En algunos bancos de preguntas de examen la misma idea se expresa como MH = TC + VAR\_WMH = TC + VAR\_W o MH = TC - VAR\_EMH = TC - VAR\_E; es la misma convención con distinta notación.

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
=== Un ejemplo resuelto de la cadena de rumbos
<un-ejemplo-resuelto-de-la-cadena-de-rumbos>
Trazamos en la carta una trayectoria verdadera #strong[TC = 100º]. No hay viento (WCA = 0), la Variación de la zona es #strong[5º W] y el Desvío de nuestra brújula para ese rumbo es #strong[2º E]. ¿Qué número debemos ver en la brújula?

Volaremos, por tanto, con la brújula marcando #strong[103º]. Fíjate en cómo la Variación Oeste #strong[aumentó] el rumbo (de 100 a 105) y el Desvío Este lo #strong[redujo] (de 105 a 103): exactamente lo que predice la convención (W −) / (E +).

== Cálculo de la deriva y la velocidad suelo
<cálculo-de-la-deriva-y-la-velocidad-suelo>
Cuando preparamos el vuelo en tierra rara vez dibujamos el triángulo con regla: estimamos la deriva con dos fórmulas mentales muy rápidas.

Primero descomponemos el viento respecto a nuestra trayectoria, siendo el ángulo entre el rumbo y la dirección de donde viene el viento:

La #strong[componente cruzada] es la que nos saca de ruta; la #strong[componente de frente/cola] solo cambia nuestra velocidad suelo. Con la componente cruzada y nuestra TAS, el ángulo de deriva (#strong[Drift Angle]) sale de una variante de la regla 1-en-60:

Y la velocidad suelo resultante es:

\(signo #strong[−] con viento de cara, #strong[\+] con viento de cola).

#block[
#callout(
body: 
[
Volamos a #strong[TAS = 60 kt] con un viento cruzado de #strong[20 kt]. La deriva será DA = (20 ) / 60 = 20°DA = (20 ) / 60 = 20°. Si ese mismo viento de 20 kt fuera de cara, nuestra velocidad suelo bajaría a #strong[40 kt]\; de cola, subiría a #strong[80 kt]. Con TAS baja, ¡el viento manda!

]
, 
title: 
[
Regla de oro --- Ejemplo numérico
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
== Tiempo, velocidad y distancia
<tiempo-velocidad-y-distancia>
La aritmética básica de la estima cierra el triángulo: con dos datos obtienes el tercero a partir de GS = D / TGS = D / T.

Ejemplo: si planeamos un tramo de #strong[45 NM] y esperamos una velocidad suelo de #strong[90 kt], tardaremos T = 45 / 90 = 0{,}5~h = 30T = 45 / 90 = 0{,}5~h = 30 minutos. Convertir las horas decimales a minutos es solo multiplicar la parte decimal por 60 (0,5 h × 60 = 30 min).

#block[
#callout(
body: 
[
Lleva siempre el reloj en marcha desde el último punto conocido. El tiempo transcurrido, multiplicado por tu velocidad suelo estimada, es tu mejor aliado para saber #strong[dónde estarás] ---que es de lo que trata realmente la navegación a vela.

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
== La Regla del 1 en 60
<la-regla-del-1-en-60>
La #strong[regla del 1 en 60] es una de esas que parecen magia y caben en la cabeza: si te desvías #strong[1 milla náutica] de tu ruta tras haber volado #strong[60 millas], tu error de rumbo es justo #strong[1 grado].

Esta regla te permite corregir rumbos sobre la marcha: si tras 30 millas ves que estás 2 millas a la derecha, sabes que tu error de deriva es de 4 grados (2 millas en 30 es como 4 en 60).

== Ejercicios propuestos
<ejercicios-propuestos>
Resuélvelos con lápiz y papel antes de mirar la solución. Son exactamente del tipo que caen en el examen de navegación.

#strong[Ejercicio 1 --- Cadena de rumbos.]

Quieres volar un rumbo verdadero (TC) de 250°. La carta indica una variación magnética de 3°W y la tablilla de tu brújula da un desvío de 1°E para ese rumbo. No hay viento. ¿Qué rumbo de compás (CH) debes volar?

#strong[Solución.] Sin viento, no hay corrección de deriva, así que TH = TC = 250°. Aplica la variación con la convención (W +) sobre el verdadero para pasar a magnético: MH = 250° + 3° = 253°. Ahora el desvío, que es 1°E, resta: CH = 253° − 1° = #strong[252°]. Regla nemotécnica: «Oeste, el compás marca de más» (hay que sumar al verdadero para obtener lo que volarás).

#strong[Ejercicio 2 --- Deriva y rumbo a volar.]

Tu TAS es de 90 km/h y quieres seguir una ruta con rumbo verdadero 000° (al norte). Sopla un viento del oeste (270°) de 18 km/h, es decir, totalmente cruzado. ¿Cuántos grados de corrección de deriva necesitas y hacia dónde?

#strong[Solución.] El viento es 100 % cruzado, así que la componente cruzada es los 18 km/h completos. Con la fórmula mental de deriva, DA = (V\_{cruzado} )/TAS = (18 )/90 = 1.080/90 = 12°DA = (V\_{cruzado} )/TAS = (18 )/90 = 1.080/90 = 12°. El viento viene de la izquierda (del oeste hacia un rumbo norte), así que empujaría hacia la derecha; para compensarlo, mete morro al viento: vuela un rumbo verdadero de #strong[348°] (000° − 12°). Fíjate en la lección del planeador: con TAS baja, un viento moderado produce una deriva grande (aquí, 12° por solo 18 km/h de viento).

#postit[
#strong[Resumen del Capítulo: Navegación a Estima]

- #strong[El Triángulo de Velocidades]: Es la base de todo. Tres vectores: #strong[TAS] (Tu velocidad real aire), #strong[Viento] (Velocidad del aire) y #strong[GS] (Tu velocidad suelo). Si conoces dos, calculas el tercero.
- #strong[Deriva (Drift)]: El ángulo que el viento te desvía de tu rumbo. Debes corregirlo "metiendo morro al viento" (#strong[Ángulo de Corrección de Deriva - WCA]).
- #strong[La Fórmula Mágica]: TC (Rumbo Verdadero) WCA = TH (Rumbo Verdadero de Proa). TH VAR = MH (Rumbo Magnético). MH DEV = CH (Rumbo de Compás). Convención de signos: #strong[\(W −) / (E +)].
- #strong[Deriva y velocidad suelo]: DA = (V\_{cruzado} )/TASDA = (V\_{cruzado} )/TAS y GS = TAS V = TAS V . Con TAS baja, un viento moderado produce mucha deriva.
- #strong[Tiempo/distancia/velocidad]: T = D/GST = D/GS. Pasa horas decimales a minutos multiplicando por 60.
- #strong[Regla del 60]: Si te desvías 1 milla en 60 millas de vuelo, tu error de rumbo es 1 grado. Útil para correcciones mentales rápidas.

]
= Navegación en vuelo
<navegación-en-vuelo>
#quote(block: true)[
En el aire, la teoría del papel se vuelve oficio: comparar lo que ves por la cúpula con lo que habías planificado. Y en planeador esto exige un punto extra de atención, porque no podemos perdernos mientras además gestionamos la energía y buscamos la siguiente térmica.

En este capítulo aprenderás:

- #strong[Las tres formas de navegar]: estima, observada y visual, y cómo se combinan en vuelo.
- #strong[La técnica mapa-terreno]: busca en el mapa lo que ves fuera, nunca al revés.
- #strong[La triangulación]: cruzar dos líneas de posición para fijar dónde estás con certeza.
- #strong[La gestión de la incertidumbre de posición (UOP)]: qué hacer cuando dudas de dónde estás.
]

== Tres formas de navegar
<tres-formas-de-navegar>
En la práctica combinamos tres técnicas que se complementan:

- #strong[Navegación a la estima] (#strong[dead reckoning]): deducimos la posición a partir del rumbo, la velocidad y el tiempo (el capítulo anterior). Es nuestra base de cálculo, pero los pequeños errores se acumulan.
- #strong[Navegación observada]: fijamos la posición reconociendo el terreno (ríos, carreteras, pueblos) y comparándolo con la carta.
- #strong[Navegación visual]: la combinación de las dos anteriores ---calculamos a la estima y #strong[confirmamos] con referencias del terreno--- y es la que realmente usamos en vuelo a vela.

== La técnica Mapa-Terreno
<la-técnica-mapa-terreno>
La regla de oro de la navegación visual es: #strong[nunca busques en el terreno lo que ves en el mapa; busca en el mapa lo que ves en el terreno.]

- #strong[Selecciona referencias grandes]: Autopistas, líneas de costa, grandes lagos o ciudades. Los ríos pequeños pueden ser confusos si serpentean mucho o están secos.
- #strong[Orientación del mapa]: Vuela siempre con el mapa orientado en el sentido de tu vuelo ("arriba" es hacia donde vas). De esta forma, si ves una montaña a tu izquierda en el terreno, debe estar a la izquierda en tu mapa.

== Triangulación: Saber dónde estás con certeza
<triangulación-saber-dónde-estás-con-certeza>
No confíes en una sola referencia. Para confirmar tu posición, usa la técnica de la triangulación o líneas de posición:

+ Identifica una referencia lineal y bien definida (una carretera nacional, un río o una vía de tren, por ejemplo).
+ Busca una segunda referencia que cruce o esté alineada con un punto notable (ej: "estoy sobre la carretera N-VI, justo cuando el pueblo X queda a mis 3").

El cruce de esas dos líneas de posición fija tu posición con bastante certeza (#ref(<fig-09-cap05-triangulacion>, supplement: [Figura])).

#figure([
#box(image("imagenes/09-cap05-triangulacion.jpg"))
], caption: figure.caption(
position: bottom, 
[
Técnica de triangulación visual en vuelo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap05-triangulacion>


== Gestión de la Incertidumbre (UOP)
<gestión-de-la-incertidumbre-uop>
Si en algún momento no estás seguro de tu posición exacta (Uncertainty of Position), mantén la calma y sigue este protocolo:

- #strong[No zigzaguees]: Mantén el rumbo que tenías. Si empiezas a dar vueltas a ciegas, te perderás más rápido y gastarás altura preciosa.
- #strong[Confía en tu estima]: Mira el reloj. Si llevas 10 minutos volando a 100 km/h, busca referencias a unos 15-20 km de tu último punto conocido.
- #strong[Busca "Handrails" (pasamanos)]: Vuela hacia la referencia más grande y lineal que veas (una costa, una cordillera principal).

#block[
#callout(
body: 
[
Si la incertidumbre persiste y tu altura se reduce, deja de intentar navegar y concéntrate en aterrizar. #strong[Navegar es secundario; volar el planeador y asegurar una toma segura es lo primero.]

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
Si tienes radio y estás en contacto con un servicio ATC, no dudes en preguntar: "Madrid, EC-XYZ, dudo de mi posición, solicito vector o confirmación". No hay vergüenza en pedir ayuda antes de que la situación sea crítica.

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
#strong[Resumen del Capítulo: Navegación en Vuelo]

- #strong[Referencias Visuales]: Usa objetos grandes, lineales y con contraste (ríos, autopistas, líneas de costa). Oriente la carta siempre en el sentido del vuelo (lo que ves a la derecha en el suelo, a la derecha en el papel).
- #strong[Triangulación]: No te fíes de una sola referencia. Cruza al menos dos "líneas de posición" (ej. el cruce de una carretera y el eje de una montaña) para saber dónde estás con certeza.
- #strong[La Regla 1:60]: Si te desvías 1 NM de tu ruta tras haber volado 60 NM, tu error de rumbo es de 1º. Puedes usar esta proporción para corregir el rumbo mentalmente sin transportador.
- #strong[Incertidumbre de Posición]: Si te pierdes, NO SIGAS VOLANDO A CIEGAS. Mantén el rumbo, busca referencias grandes, confía en tu estima inicial y, si es necesario, vuela hacia un lugar conocido (un río, una costa) o aterriza con seguridad antes de quedarte sin altura.

]
= Uso de GNSS
<uso-de-gnss>
#quote(block: true)[
El Sistema Global de Navegación por Satélite (GNSS) ---que agrupa redes como el GPS estadounidense o el europeo Galileo--- ha cambiado por completo el vuelo a vela. Nos da posición, altitud y velocidad suelo con una precisión que hace años parecía impensable. Aun así, en el hangar lo resumimos en una frase: el GPS es un criado excelente, pero un amo pésimo.

En este capítulo aprenderás:

- #strong[Cómo funciona el GNSS]: por qué necesitas captar cuatro satélites para una posición en tres dimensiones.
- #strong[El datum WGS-84]: el "idioma" geográfico común entre el receptor y la carta de papel.
- #strong[Los registradores IGC]: la prueba digital del vuelo para validar récords y medallas FAI.
- #strong[Las limitaciones y fuentes de error]: por qué el GPS es una ayuda y nunca un sustituto de la carta.
]

== ¿Cómo funciona el GNSS?
<cómo-funciona-el-gnss>
Para que tu dispositivo te dé una posición tridimensional (latitud, longitud y altitud), necesita "ver" al menos #strong[4 satélites]. Con tres satélites sabría dónde estás sobre el mapa, pero no sabría a qué altura vuelas.

La mayoría de los receptores modernos combinan señales de varias constelaciones para mejorar la precisión: \* #strong[GPS]: El sistema original norteamericano. \* #strong[Galileo]: El sistema europeo, más reciente y con mayor precisión civil. \* #strong[GLONASS]: El sistema ruso.

=== El Datum WGS-84
<el-datum-wgs-84>
Para que el GPS y la carta de papel se entiendan, deben usar el mismo "idioma" geográfico o #strong[Datum]. El estándar mundial que usamos es el #strong[WGS-84]. Asegúrate siempre de que tu dispositivo está configurado en este sistema; un datum incorrecto podría desplazar tu posición real varios cientos de metros respecto a lo que ves en pantalla.

== Los Registradores IGC (Loggers)
<los-registradores-igc-loggers>
#strong[↗ MÁS ALLÁ DEL EXAMEN.] Los registradores IGC y la validación de récords y medallas FAI no deberían ser materia de examen. Se incluyen como iniciación al vuelo deportivo de distancia; no los estudies con la prioridad del resto del temario.

En el mundo del planeador, el GNSS no solo sirve para navegar. Usamos dispositivos certificados llamados #strong[registradores IGC] (#strong[Loggers]) que graban cada segundo de nuestro vuelo.

Estos archivos digitales (.igc) son la prueba de que has pasado por los puntos de viraje de una tarea y sirven para validar récords y medallas de la FAI. Al aterrizar, puedes volcar el vuelo en programas de análisis para aprender de tus decisiones y ver exactamente dónde encontraste esa térmica tan buena.

Los equipos modernos integran el GNSS con un #strong[mapa móvil] que muestra ruta, espacios aéreos y datos de planeo (#ref(<fig-09-cap06-gnss-cabina>, supplement: [Figura])).

#figure([
#box(image("imagenes/09-cap06-gnss-cabina.jpg"))
], caption: figure.caption(
position: bottom, 
[
Dispositivo GNSS moderno integrado en el panel de un planeador
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap06-gnss-cabina>


== Limitaciones y Conciencia Situacional
<limitaciones-y-conciencia-situacional>
El GPS puede fallar. Y fallará en el momento más inoportuno.

- #strong[Fallo de energía]: La batería de tu PDA o tablet puede agotarse o el cable de carga puede soltarse con las turbulencias.
- #strong[Pérdida de señal]: En valles profundos o debido a interferencias, puedes perder la cobertura de satélites temporalmente.
- #strong[Base de datos desactualizada]: Si no actualizas los espacios aéreos de tu dispositivo, podrías entrar en una zona prohibida sin saberlo.

Además, la propia señal tiene fuentes de error que degradan la precisión aunque el equipo funcione: el #strong[retardo ionosférico y troposférico] (la señal se frena al atravesar la atmósfera), el #strong[multitrayecto] (rebotes de la señal en el terreno o en estructuras), las pequeñas #strong[derivas de los relojes] y la #strong[geometría de los satélites] (si están mal repartidos en el cielo, la #strong[dilución de la precisión] o DOP empeora). En condiciones normales la precisión ronda unos pocos metros, más que suficiente para volar, pero conviene saber que no es infalible.

#block[
#callout(
body: 
[
El GNSS no te exime de saber navegar visualmente: el vuelo VFR se apoya en referencias del terreno, con o sin pantalla. Y tenlo presente en el examen de pericia de la SPL: el examinador puede apagarte el dispositivo para comprobar que sabes volver al aeródromo con el mapa y la brújula.

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
Lleva siempre una #strong[fuente de respaldo] (backup). Si confías en una tablet, ten tu teléfono con una app de navegación cargada y, por supuesto, la carta de papel doblada y lista en el bolsillo lateral de la cabina.

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
#postit[
#strong[Resumen del Capítulo: Uso del GNSS (GPS)]

- #strong[Ayuda, no sustituto]: El GPS es una herramienta fabulosa para la conciencia situacional, pero nunca debe sustituir a la navegación visual y a la carta. Las baterías fallan, las señales se pierden y los dispositivos se cuelgan.
- #strong[Fuentes de Error]: El GPS puede fallar por falta de satélites (necesitas 4 para posición 3D), interferencias o errores en la base de datos. Verifica siempre que el destino y las coordenadas son correctos.
- #strong[Backup]: Lleva siempre una carta de papel y una brújula. Si el GPS muere en medio de un vuelo de distancia, debes ser capaz de volver a casa "a la vieja usanza".
- #strong[Configuración]: Asegúrate de que tu datum (usualmente WGS84) y las unidades (NM, kts, m) coinciden con tu planificación y con lo que esperas ver en los instrumentos.

]
= Uso de ATS
<uso-de-ats>
#quote(block: true)[
El vuelo a vela sabe a libertad, pero el cielo lo compartimos con mucho más tráfico. Los Servicios de Tránsito Aéreo (ATS) están ahí para que esa convivencia sea segura y ordenada.

En este capítulo aprenderás:

- #strong[ATC frente a FIS]: quién da órdenes obligatorias y quién facilita información.
- #strong[El transpondedor]: los códigos squawk y cuándo es obligatorio llevarlo encendido.
- #strong[El plan de vuelo (FPL)]: cuándo es obligatorio, su ciclo de vida y por qué hay que cerrarlo al aterrizar.
- #strong[Los espacios aéreos especiales]: qué te exigen y qué servicios recibes en cada clase.
]

== ATC vs.~FIS: ¿Quién es quién?
<atc-vs.-fis-quién-es-quién>
Conviene tener clara la diferencia entre "el control" y "la información":

- #strong[ATC (Control de Tráfico Aéreo)]: Su función es separar tráficos mediante instrucciones obligatorias. Interactuarás con ellos en aeródromos controlados y espacios aéreos de clase C y D (#ref(<fig-09-cap07-control-aereo>, supplement: [Figura])).
- #strong[FIS (Servicio de Información de Vuelo)]: No dan órdenes, sino información útil (meteorología, tráficos conocidos, estado de aeródromos). En España, gran parte de nuestros vuelos de distancia se realizan bajo la vigilancia de un centro FIS.

#block[
#callout(
body: 
[
Llamar a los servicios FIS (como Madrid o Barcelona Información) es una excelente práctica. Además de darte tranquilidad, si tienes que realizar un aterrizaje en campo, ellos sabrán tu última posición conocida y podrán coordinar ayuda si fuera necesario.

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
== El Transpondedor: Hazte visible
<el-transpondedor-hazte-visible>
El transpondedor es el equipo que permite a los radares del ATC "verte" e identificar tu altitud.

- #strong[Squawk 7000]: Es el código estándar para vuelos VFR en España.
- #strong[7700]: Emergencia general.
- #strong[7600]: Fallo de radio.
- #strong[7500]: Interferencia ilícita (secuestro).

#block[
#callout(
body: 
[
Si tu transpondedor está instalado y operativo, la práctica correcta es #strong[mantenerlo encendido y en modo "ALT"] (transmisión de altitud) para que el radar te vea. Su uso es #strong[obligatorio en las zonas de uso de transpondedor (TMZ) y allí donde lo exijan la clase de espacio aéreo o el AIP-España (ENR 1.6)] ---las clases A y C lo requieren, y la D generalmente; véase la tabla del #strong[Libro 1 --- Derecho aéreo], capítulo 7---, y muy recomendable en cualquier espacio con tráfico. Solo en planeadores con batería muy limitada cabe valorar apagarlo fuera de esos espacios, y siempre como decisión deliberada: #strong[nunca en una TMZ, en espacio controlado ni en zonas de tráfico intenso].

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
== El Plan de Vuelo (FPL)
<el-plan-de-vuelo-fpl>
El Plan de Vuelo (FPL) es tu contrato de seguridad con el sistema. En él indicas quién eres, qué planeador vuelas, tu ruta y cuánta autonomía tienes.

#block[
#callout(
body: 
[
Según el reglamento #strong[SERA] (SERA.4001 b)), es obligatorio presentar un FPL si vas a cruzar fronteras, si se te presta servicio de control de tránsito aéreo (clases B, C y D) o si despegas o aterrizas en un aeródromo controlado. Ojo con la clase E: es espacio controlado, pero al VFR no se le presta servicio de control, así que no necesita plan de vuelo, ni radio, ni autorización. Y lo más importante de todo: si presentaste plan, #strong[DEBES notificar tu llegada] para cerrarlo. Si no lo haces, se activarán los servicios de búsqueda y rescate (SAR) innecesariamente.

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
El plan no es un papel que se entrega y se olvida. Tiene un ciclo de vida con cuatro mensajes asociados que comunicas a la misma dependencia donde lo presentaste: #strong[DEP] (salida), #strong[DLA] (demora), #strong[CHG] (cambio) y #strong[CNL] (cancelación). Y, según el AIP (ENR 1.10), un FPL VFR debe presentarse con cierta antelación a la EOBT (hora estimada fuera de calzos): típicamente al menos #strong[60 minutos antes] si solicitas servicio de control, o antes de la salida si solo pides información de vuelo y alerta.

#figure([
#box(image("imagenes/09-cap07-atc.jpg"))
], caption: figure.caption(
position: bottom, 
[
Interacción con el control de tráfico aéreo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap07-control-aereo>


== Operando en Espacios Especiales
<operando-en-espacios-especiales>
No todas las zonas del cielo son iguales:

- #strong[Clase G (Espacio fuera de control)]: Puedes volar libremente bajo reglas VFR sin radio obligatoria (aunque muy recomendada). Recibes servicio de información de vuelo (FIS).
- #strong[Clase E]: Controlado, pero el VFR #strong[no] necesita autorización ni radio obligatoria; recibes información de tráfico en la medida de lo posible.
- #strong[Clases C y D (Espacio Controlado)]: #strong[OBLIGATORIO] contacto radio y autorización previa del ATC para entrar. En clase C, además, el control separa tu VFR del tráfico IFR; en clase D nadie te separa: solo recibes información de tráfico, y ver y evitar sigue siendo cosa tuya.
- #strong[Zonas Prohibidas/Restringidas (P/R)]: Evítalas a menos que tengas una autorización específica. Un "salto" de un segundo en una zona Prohibida puede acarrear sanciones graves.

#block[
#callout(
body: 
[
Resumen de servicios al VFR según #strong[SERA.8001]: en #strong[C y D] hay autorización ATC y radio obligatoria; en #strong[E] ni autorización ni radio (solo información de tráfico si la hay); en #strong[F y G] solo servicio de información de vuelo. Saber qué te van a dar ---y qué te van a exigir--- en cada clase es parte de la planificación.

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
#strong[Resumen del Capítulo: Uso de los ATS]

- #strong[Dependencias]: El ATC (Control) gestiona aeródromos y espacios controlados. El FIS (Información) te ayuda en ruta con meteo y tráfico. Mantén contacto con FIS cuando sea posible; es una capa extra de seguridad.
- #strong[Transpondedor]: Es tu visibilidad para el radar. En VFR pon 7000. Si tienes una emergencia: 7700. Si pierdes la radio: 7600. Si está operativo, llévalo encendido y en ALT (obligatorio en TMZ y donde lo exija la clase de espacio aéreo --- AIP ENR 1.6); vigila el consumo de batería.
- #strong[Plan de Vuelo]: Fundamental para que te busquen si no llegas. Se activa al despegar y #strong[ES OBLIGATORIO notificar tu llegada] a la dependencia ATS del aeródromo de destino tan pronto como sea posible (SERA).
- #strong[Espacios Aéreos]: Conoce dónde estás. En Clase C o D necesitas autorización radio. En Clase G eres libre, pero el FIS sigue estando ahí para ayudarte.

]
#show: appendices.with("Apéndices", hide-parent: true)
#heading(level: 1, numbering: none)[Apéndices]
= Syllabus Oficial EASA - Navegación
<syllabus-oficial-easa---navegación>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Navegación] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- 9.1. Fundamentos de navegación.
- 9.2. Magnetismo y brújulas.
- 9.3. Cartas aeronáuticas.
- 9.4. Navegación por estima (Dead Reckoning).
- 9.5. Navegación en vuelo.
- 9.6. Uso de GNSS.
- 9.7. Uso de ATS.

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

== Ponte a prueba
<ponte-a-prueba>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/09-navegacion/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

= Glosario de términos
<glosario-de-términos>
Este glosario reúne las definiciones y acrónimos más relevantes de Navegación aplicables a la licencia de piloto de planeador (SPL).

/ #strong[AGL (Altura sobre el terreno / Above Ground Level)]: #block[
Altura medida desde la superficie del terreno. En los símbolos de obstáculo de la carta es la cifra que va entre paréntesis. (Mencionado en: cap. 3)
]

/ #strong[AMA (Altitud Mínima de Área)]: #block[
Cifra impresa en cada cuadrícula de la carta (paralelos y meridianos cada 30') que indica una altitud de seguridad sobre el obstáculo más alto del recuadro, con un margen mínimo de 1000 ft (2000 ft en alta montaña). Se lee como millares y centenares de pies. (Mencionado en: cap. 3)
]

/ #strong[AMSL (Altitud sobre el nivel del mar / Above Mean Sea Level)]: #block[
Altitud referida al nivel medio del mar. En los símbolos de obstáculo de la carta es la cifra que va sin paréntesis. (Mencionado en: cap. 3)
]

/ #strong[ANDS (Error de aceleración de la brújula)]: #block[
Regla mnemotécnica inglesa #emph[Accelerate North, Decelerate South]: en rumbos Este u Oeste, al acelerar la brújula tiende a marcar viraje al Norte y al decelerar, al Sur. (Mencionado en: cap. 2)
]

/ #strong[ATC (Control de Tránsito Aéreo / Air Traffic Control)]: #block[
Servicio de tránsito aéreo responsable de dirigir el tráfico de aeronaves para prevenir colisiones entre aeronaves y entre estas y los obstáculos en el área de maniobras, así como de organizar y agilizar el flujo del tránsito aéreo. El planeador interactúa con él en aeródromos controlados y en espacio aéreo clase C y D. (Mencionado en: cap. 7)
]

/ #strong[ATS (Servicios de Tránsito Aéreo / Air Traffic Services)]: #block[
Término genérico que engloba el control de tránsito aéreo (ATC), el servicio de información de vuelo (FIS) y el servicio de alerta. (Mencionado en: cap. 7)
]

/ #strong[Crepúsculo civil]: #block[
Periodo de transición entre el día y la noche. Para la aviación, la noche comienza al final del crepúsculo civil vespertino y termina al inicio del matutino, cuando el centro del sol está 6º por debajo del horizonte. (Mencionado en: cap. 1)
]

/ #strong[Datum WGS-84 (World Geodetic System 1984)]: #block[
Sistema geodésico de referencia mundial sobre el que el GNSS y la cartografía expresan las coordenadas. Configurar el receptor en un datum distinto puede desplazar la posición mostrada varios cientos de metros. (Mencionado en: cap. 6)
]

/ #strong[Deriva]: #block[
Desviación lateral de la trayectoria del planeador respecto al suelo provocada por el viento de costado (en navegación). En aerodinámica, se refiere a la superficie fija vertical de la cola (estabilizador vertical) que aporta estabilidad de guiñada. (Mencionado en: cap. 4)
]

/ #strong[Desvío]: #block[
Error local de la brújula causado por los campos magnéticos del propio planeador (tubos de acero, radio, instrumentos). Se corrige consultando la tablilla de desvíos de la cabina. (Mencionado en: cap. 2)
]

/ #strong[DOP (Dilución de la precisión)]: #block[
Degradación de la precisión del GNSS debida a la geometría de los satélites visibles: cuando están mal repartidos en el cielo, la posición calculada es menos precisa. (Mencionado en: cap. 6)
]

/ #strong[EOBT (Hora estimada fuera de calzos / Estimated Off-Block Time)]: #block[
Hora prevista en que la aeronave inicia el movimiento para la salida (rodaje o remolque), constituyendo la referencia para calcular los plazos de presentación de los planes de vuelo. (Mencionado en: cap. 7)
]

/ #strong[Error de viraje (regla "NO me paso / SÍ me paso")]: #block[
Error de la brújula al virar hacia rumbos Norte o Sur por efecto del #emph[dip] magnético: al Norte la brújula se queda atrás (hay que sacar el viraje antes, "NO me paso") y al Sur se adelanta (hay que dejarla pasar, "SÍ me paso"). (Mencionado en: cap. 2)
]

/ #strong[Escala]: #block[
Relación entre una distancia medida en la carta y la distancia real en el terreno. En la carta VFR estándar 1:500.000, 1 cm equivale a 5 km. (Mencionado en: cap. 3)
]

/ #strong[Espacio aéreo controlado]: #block[
Volumen de espacio aéreo (clases A a E) en el que se presta servicio de control. En clases C y D el VFR necesita autorización ATC y comunicación radio para entrar. (Mencionado en: cap. 7)
]

/ #strong[FIS (Servicio de Información de Vuelo / Flight Information Service)]: #block[
Servicio cuya finalidad es facilitar asesoramiento e información útiles para la realización segura y eficaz de los vuelos (meteorología, tráficos conocidos, estado de aeródromos), sin proporcionar instrucciones de control ni separación obligatoria. (Mencionado en: cap. 7)
]

/ #strong[FPL (Plan de vuelo / Flight Plan)]: #block[
Información estructurada que se suministra a los servicios de tránsito aéreo sobre un vuelo proyectado, siendo obligatorio en cruce de fronteras o espacio controlado. (Mencionado en: cap. 7)
]

/ #strong[GNSS (Sistema Global de Navegación por Satélite)]: #block[
Término genérico para los sistemas de posicionamiento por satélite (GPS, Galileo, GLONASS, BeiDou). Necesita captar al menos cuatro satélites para una posición tridimensional. (Mencionado en: cap. 6)
]

/ #strong[GPS (Global Positioning System)]: #block[
Sistema de posicionamiento por satélite original, operado por Estados Unidos. Es la constelación más conocida dentro del GNSS. (Mencionado en: cap. 6)
]

/ #strong[GS (Velocidad suelo / Ground Speed)]: #block[
Velocidad real sobre el terreno, resultado de combinar la TAS con el viento. Es la que determina cuánto tardas en recorrer un tramo. (Mencionado en: cap. 4)
]

/ #strong[Handrail (Pasamanos)]: #block[
Referencia lineal grande y bien definida (una costa, una cordillera, una autopista) que se sigue para reorientarse cuando hay incertidumbre de posición. (Mencionado en: cap. 5)
]

/ #strong[IAS (Velocidad indicada / Indicated Air Speed)]: #block[
Velocidad de la aeronave respecto al aire circundante tal como la indica el anemómetro, sin correcciones por temperatura ni densidad. En navegación es el punto de partida del cálculo: corregida por densidad da la TAS y, combinada con el viento, la GS; nunca se razona con la IAS a secas. (Mencionado en: cap. 4)
]

/ #strong[IGC (Registrador de vuelo / Logger)]: #block[
Dispositivo certificado que graba la traza GPS del vuelo en un archivo #NormalTok(".igc");, prueba del paso por los puntos de viraje para validar récords y medallas FAI. (Mencionado en: cap. 6)
]

/ #strong[Isógona (línea isogónica)]: #block[
Línea de la carta que une los puntos con igual valor de variación (declinación) magnética. (Mencionado en: cap. 2)
]

/ #strong[Latitud]: #block[
Coordenada que mide la distancia angular al norte o al sur del Ecuador (latitud 0º), formada por los paralelos. Un minuto de latitud equivale a una milla náutica. (Mencionado en: cap. 1)
]

/ #strong[Longitud]: #block[
Coordenada que mide la distancia angular al este o al oeste del meridiano de Greenwich (longitud 0º), formada por los meridianos. A diferencia de la latitud, un minuto de longitud varía con la latitud. (Mencionado en: cap. 1)
]

/ #strong[Loxodrómica (Línea de rumbo)]: #block[
Trayectoria que corta todos los meridianos con el mismo ángulo, es decir, de rumbo constante. Es algo más larga que la ortodrómica, pero más cómoda de volar; es la que usamos en planeador. (Mencionado en: cap. 1)
]

/ #strong[Milla náutica (NM)]: #block[
Unidad de distancia de la navegación, igual a 1852 m, equivalente a un minuto de arco de latitud medido sobre un meridiano. (Mencionado en: cap. 1)
]

/ #strong[Multitrayecto]: #block[
Fuente de error del GNSS por la que la señal de un satélite llega al receptor tras rebotar en el terreno o en estructuras, falseando ligeramente la medida de distancia. (Mencionado en: cap. 6)
]

/ #strong[Navegación a estima (Dead Reckoning)]: #block[
Método de deducir la posición a partir de un punto conocido aplicando rumbo, velocidad y tiempo transcurrido. Sus pequeños errores se acumulan, así que se confirma con referencias del terreno. (Mencionado en: cap. 4)
]

/ #strong[Navegación observada]: #block[
Técnica de fijar la posición reconociendo accidentes del terreno (ríos, carreteras, pueblos) y comparándolos con la carta. (Mencionado en: cap. 5)
]

/ #strong[Norte magnético]: #block[
Punto hacia el que apuntan las agujas de la brújula. No coincide con el norte verdadero y se desplaza ligeramente cada año. (Mencionado en: cap. 2)
]

/ #strong[Norte verdadero (Geográfico)]: #block[
Punto por el que pasa el eje de rotación de la Tierra. Es el norte de referencia de los mapas y las cartas aeronáuticas. (Mencionado en: cap. 2)
]

/ #strong[Nudo (kt)]: #block[
Unidad de velocidad igual a una milla náutica por hora (1 kt = 1,852 km/h). (Mencionado en: cap. 1)
]

/ #strong[Ocaso]: #block[
Atardecer: instante en que el borde superior del disco solar desaparece por el horizonte oeste. No marca todavía el inicio de la noche aeronáutica (ver crepúsculo civil). (Mencionado en: cap. 1)
]

/ #strong[Orto]: #block[
Amanecer: instante en que el borde superior del disco solar asoma por el horizonte este. (Mencionado en: cap. 1)
]

/ #strong[Ortodrómica (Círculo máximo)]: #block[
Trayectoria más corta entre dos puntos de la esfera terrestre. Su inconveniente es que el rumbo cambia continuamente al cruzar los meridianos. (Mencionado en: cap. 1)
]

/ #strong[Proyección Lambert (cónica conforme)]: #block[
Proyección cartográfica empleada en las cartas aeronáuticas de latitudes medias. Es "conforme" (conserva ángulos y formas), su escala es prácticamente constante y una línea recta se aproxima a una ortodrómica. (Mencionado en: cap. 3)
]

/ #strong[Regla del 1 en 60]: #block[
Aproximación de cálculo mental: desviarse 1 NM de la ruta tras volar 60 NM equivale a un error de rumbo de 1º. Sirve para corregir el rumbo sobre la marcha. (Mencionado en: cap. 4)
]

/ #strong[SERA (Standardised European Rules of the Air / Reglas Europeas Estandarizadas del Aire)]: #block[
Reglamento de Ejecución (UE) n.º 923/2012 con las reglas del aire comunes para toda la Unión Europea. En navegación fija, entre otras cosas, cuándo es obligatorio el plan de vuelo, los servicios por clase de espacio aéreo y el uso del transpondedor. (Mencionado en: cap. 7)
]

/ #strong[Squawk]: #block[
Código de cuatro dígitos en base octal (0--7) que el transpondedor emite al ser interrogado por el radar secundario (SSR), permitiendo al controlador identificar la aeronave en pantalla. Código VFR estándar en Europa: 7000. Los códigos 7700 (emergencia), 7600 (fallo de radio) y 7500 (interferencia ilícita) son de uso exclusivo en esas situaciones. (Mencionado en: cap. 7)
]

/ #strong[Tablilla de desvíos]: #block[
Tarjeta instalada a la vista del piloto que indica la corrección a aplicar a la brújula en cada rumbo para compensar el desvío propio de la aeronave. (Mencionado en: cap. 2)
]

/ #strong[TAS (Velocidad verdadera / True Air Speed)]: #block[
Velocidad real respecto a la masa de aire. Es la IAS corregida por densidad (crece aproximadamente un 2 % por cada 300 m de altitud, unos 6,5-7 % por cada 1.000 m) y el vector que marca hacia dónde apunta el morro. (Mencionado en: cap. 4)
]

/ #strong[Tintas hipsométricas]: #block[
Sistema de coloreado del terreno en la carta (verdes para los valles, marrones para las montañas) que da una idea rápida del relieve. (Mencionado en: cap. 3)
]

/ #strong[TMZ (Zona de transpondedor obligatorio / Transponder Mandatory Zone)]: #block[
Espacio aéreo de dimensiones definidas en el que es obligatorio portar y operar un transpondedor con transmisión de altitud (Modo C o S). (Mencionado en: cap. 7)
]

/ #strong[Transpondedor]: #block[
Equipo de a bordo que responde automáticamente a las interrogaciones del radar secundario (SSR) emitiendo un código #strong[squawk] y, según el modo, la altitud barométrica o datos extendidos de identificación. Opera en la banda UHF (1.030/1.090 MHz), independientemente de la radio de voz. Imprescindible para ser visible por el TCAS de otros tráficos. (Mencionado en: cap. 7)
]

/ #strong[Triangulación (Líneas de posición)]: #block[
Técnica de fijar la posición cruzando al menos dos líneas de posición (por ejemplo, una carretera y la alineación con un pueblo). (Mencionado en: cap. 5)
]

/ #strong[Triángulo de velocidades (Triángulo del viento)]: #block[
Suma vectorial de la TAS, el viento y la GS que está en la base de todos los cálculos de la navegación a estima. (Mencionado en: cap. 4)
]

/ #strong[UOP (Incertidumbre de posición / Uncertainty of Position)]: #block[
Situación en la que el piloto no está seguro de su posición exacta. El protocolo es mantener el rumbo, confiar en la estima, buscar referencias grandes y, si persiste, asegurar una toma. (Mencionado en: cap. 5)
]

/ #strong[UTC (Tiempo Universal Coordinado / Hora Zulu)]: #block[
Referencia horaria única de la aviación, correspondiente a la hora del meridiano de Greenwich. Evita las confusiones por husos horarios y cambios estacionales; en España la hora local es UTC+1 en invierno y UTC+2 en verano. (Mencionado en: cap. 1)
]

/ #strong[Variación magnética (Declinación)]: #block[
Diferencia angular entre el norte verdadero y el norte magnético en un punto dado. En la carta se representa con las líneas isógonas. Regla de cálculo: "Declinación Oeste, rumbo suma". (Mencionado en: cap. 2)
]

/ #strong[WCA (Ángulo de corrección de deriva / Wind Correction Angle)]: #block[
Ángulo que se aplica al rumbo, apuntando el morro hacia el viento, para compensar la deriva y mantener la trayectoria deseada sobre el terreno. (Mencionado en: cap. 4)
]

/ #strong[Zonas P/R/D]: #block[
Zonas de la carta con restricciones de uso del espacio aéreo: P (prohibida), R (restringida) y D (peligrosa), identificadas con una letra y un número (p.~ej. LER-71). No son clases de espacio aéreo. (Mencionado en: cap. 3)
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
