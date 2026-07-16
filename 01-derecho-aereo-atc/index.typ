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
  title: [Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo],
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

#heading(level: 1, numbering: none)[Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo]
<derecho-aéreo-y-procedimientos-de-control-de-tránsito-aéreo>
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
#strong[#emph[Tema 1 de 9 del examen teórico para la Licencia de Piloto de Planeador (SPL)]]

Un planeador opera en un sistema de espacios aéreos y responsabilidades legales que existen para que cada vuelo sea predecible. Ignorar ese sistema no te hace más libre; te hace más expuesto.

Catorce capítulos convierten el marco normativo en criterio operativo: qué documentos van en la cabina, qué espacio aéreo requiere autorización, qué activa la fase de alerta SAR y por qué reportar un incidente es la única forma de que el sistema aprenda.

El cielo tiene reglas. Aprende a usarlas antes de despegar.

= Derecho internacional: convenios, acuerdos y organizaciones
<derecho-internacional-convenios-acuerdos-y-organizaciones>
#quote(block: true)[
Entender el marco legal no es burocracia: es el cimiento de tu seguridad y de tu libertad para volar más allá de nuestras fronteras.

En este capítulo aprenderás:

- De dónde salen las normas: el Convenio de Chicago y la OACI.
- Qué papel juega EASA y cómo nos afectan las leyes comunes europeas.
- Qué es obligatorio (normativa vinculante) y qué es recomendado (estándares no vinculantes).
- Los tres reglamentos que te acompañarán toda tu vida de piloto: Part-SFCL, Part-SAO y SERA.
]

== El origen de las normas: Convenio de Chicago y OACI
<el-origen-de-las-normas-convenio-de-chicago-y-oaci>
El acta de nacimiento del derecho aéreo moderno es el #strong[Convenio de Chicago de 1944]. Allí las naciones acordaron unificar las normas de aviación a nivel global, y de ese acuerdo salen los principios que hoy nos permiten volar de forma segura y ordenada entre países distintos.

Del convenio nació la #strong[OACI] (Organización de Aviación Civil Internacional, #strong[ICAO]), una agencia especializada de la ONU. Su trabajo consiste en desarrollar los principios y técnicas de la navegación aérea internacional, fomentar el transporte aéreo entre países y velar por la seguridad operacional (#strong[safety]) en todo el mundo.

La OACI fija los estándares mínimos que sus 193 estados miembros deben cumplir. Ahora bien, no es una "policía mundial": cada país es soberano para adoptar estas normas en su legislación, aunque el Convenio le obliga a notificar las diferencias cuando no cumple un estándar.

Para que el transporte aéreo internacional fuera posible, el Convenio de Chicago sentó las bases de las #strong[libertades del aire] (ver #ref(<fig-01-cap01-chicago-freedoms>, supplement: [Figura])): acuerdos que dan a las aeronaves de un Estado permiso para entrar en el espacio aéreo de otro o sobrevolarlo. La conferencia de Chicago definió las cinco primeras en acuerdos anejos al Convenio (el sobrevuelo, la escala técnica y los derechos comerciales básicos), pero el derecho aéreo ha seguido evolucionando y hoy se reconocen nueve.

#figure([
#box(image("imagenes/01-cap01-libertades-chicago.jpg"))
], caption: figure.caption(
position: bottom, 
[
Las libertades del aire según el Convenio de Chicago
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap01-chicago-freedoms>


== La autoridad en Europa: EASA y el sistema común
<la-autoridad-en-europa-easa-y-el-sistema-común>
En Europa hemos ido un paso más allá de la simple cooperación. Los estados miembros de la Unión Europea han cedido competencias a una autoridad común: #strong[EASA] (Agencia de la Unión Europea para la Seguridad Aérea).

En la práctica, esto significa que casi todo lo que te afecta como piloto (licencias, operaciones, aeronavegabilidad) se decide a nivel europeo y es #strong[directamente aplicable] en España, sin que el gobierno español tenga que transcribirlo a una ley nacional.

¿Y entonces, qué papel juega AESA? La #strong[AESA] (Agencia Estatal de Seguridad Aérea) es el organismo público español, adscrito al Ministerio de Transportes y Movilidad Sostenible, que actúa como tu autoridad competente directa: emite tu licencia, inspecciona tu club y vigila el cumplimiento en territorio español. Pero lo hace aplicando e interpretando las reglas comunes europeas.

== Estructura normativa: normativa vinculante y estándares no vinculantes
<estructura-normativa-normativa-vinculante-y-estándares-no-vinculantes>
La normativa de EASA se organiza en capas con distinta fuerza legal (#ref(<fig-01-cap01-hard-soft-law>, supplement: [Figura])). Conviene tener claro desde el principio qué es obligatorio por ley y qué es una recomendación estándar.

=== Normativa vinculante: lo que es ley
<normativa-vinculante-lo-que-es-ley>
Es la normativa de obligado cumplimiento. Nadie queda eximido de ella salvo que la autoridad le conceda una exención por escrito. Tiene dos niveles:

- #strong[Reglamento Base] (#strong[Basic Regulation]): la "Constitución" de la seguridad aérea en Europa, actualmente el Reglamento (UE) 2018/1139. Establece los principios esenciales y los objetivos de alto nivel.
- #strong[Reglamentos de Ejecución] (#strong[Implementing Rules], IRs): las leyes detalladas que desarrollan el reglamento base. Por ejemplo, el Reglamento (UE) 2018/1976 (actualizado por el 2020/358) regula específicamente las licencias de planeador.

#block[
#callout(
body: 
[
El Reglamento (UE) 2018/1139 (Reglamento Base) establece las normas comunes en el ámbito de la aviación civil y crea la Agencia de la Unión Europea para la Seguridad Aérea (EASA). Es la norma de mayor rango en el sistema europeo.

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
=== Estándares no vinculantes: cómo cumplir la ley
<estándares-no-vinculantes-cómo-cumplir-la-ley>
Son documentos que ayudan a cumplir la ley sin ser ley en sí mismos. Que no te engañe la etiqueta de "no vinculantes": en aviación se siguen casi a rajatabla.

- #strong[AMC] (#strong[Acceptable Means of Compliance], Medios Aceptables de Cumplimiento): métodos y procedimientos que EASA publica como forma segura de cumplir la normativa vinculante. Si sigues los AMC, automáticamente cumples la norma. Si prefieres hacerlo de otra forma, tendrás que demostrar, con bastante papeleo, que tu método es igual de seguro.
- #strong[GM] (#strong[Guidance Material], Material Guía): explicaciones, interpretaciones y ejemplos para entender los requisitos. No obliga; ayuda.
- #strong[CS] (#strong[Certification Specifications]): estándares técnicos para certificar aeronaves y productos. El que nos toca es el CS-22, el de planeadores.

#figure([
#box(image("imagenes/01-cap01-estructura-normativa-easa.jpg"))
], caption: figure.caption(
position: bottom, 
[
Estructura normativa EASA: normativa vinculante vs estándares no vinculantes
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap01-hard-soft-law>


#block[
#callout(
body: 
[
- #strong[Normativa vinculante (Reglamentos)] = #strong[QUÉ] debes cumplir (obligatorio).
- #strong[Estándares no vinculantes (AMC/GM)] = #strong[CÓMO] cumplirlo de forma estándar (recomendado).

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
== Las 3 normas de referencia del piloto de planeador
<las-3-normas-de-referencia-del-piloto-de-planeador>
De toda la sopa de letras normativa, hay tres reglamentos que acabarás conociendo de memoria. Son tu marco de referencia diario.

=== 1. Part-SFCL (Licencias)
<part-sfcl-licencias>
El #strong[Sailplane Flight Crew Licensing] regula todo lo relativo a tu licencia: los requisitos para obtener la SPL (#strong[Sailplane Pilot License]), la experiencia reciente que necesitas para mantenerla, las habilitaciones (TMG, acrobacia, remolque…​) y los privilegios de instructores y examinadores. Nace del Reglamento de Ejecución (UE) 2018/1976 y sus modificaciones, como el 2020/358.

=== 2. Part-SAO (Operaciones)
<part-sao-operaciones>
El #strong[Sailplane Air Operations] regula cómo se opera el planeador de forma segura: las responsabilidades del piloto al mando, los documentos que debes llevar a bordo, los procedimientos de emergencia, el transporte de pasajeros y el uso de aeródromos. Sale del mismo reglamento que el Part-SFCL.

#block[
#callout(
body: 
[
Según SAO.GEN.130 (Part-SAO), el piloto al mando es responsable de la seguridad de la aeronave y de todas las personas a bordo durante las operaciones. Esta responsabilidad no se delega: tú eres la autoridad final en tu cabina.

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
=== 3. SERA (Reglas del Aire)
<sera-reglas-del-aire>
El #strong[Standardised European Rules of the Air] es el código de circulación del cielo: prioridades de paso, niveles de crucero, mínimos de visibilidad y distancia a nubes (VMC), señales y luces. Al ser un reglamento de ejecución de la UE, se aplica #strong[directamente] en España, sin necesidad de norma nacional que lo transponga; el Real Decreto 552/2014 lo #strong[complementa y desarrolla] en los aspectos que SERA deja a cada Estado.

#block[
#callout(
body: 
[
SERA.3210 establece las prioridades de paso para evitar colisiones. Un planeador siempre tiene prioridad sobre aeronaves de motor (aviones, helicópteros), pero debe ceder el paso a globos. Conoce estas reglas de memoria.

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
#strong[Resumen del Capítulo: Marco Normativo]

La "ley del aire" que te permite volar se organiza así:

- #strong[OACI y Convenio de Chicago (1944)]: el tratado fundador. Fija los estándares mundiales mínimos.
- #strong[EASA]: nuestra autoridad común europea. Redacta normas que todos los países de la UE cumplen por igual; AESA las aplica en España.
- #strong[Normativa vinculante] (Reglamentos): es ley, obligatoria al 100%. Ahí están Part-SFCL, Part-SAO y SERA.
- #strong[Estándares no vinculantes] (AMC/GM): no son ley estricta, pero sí la forma estándar y segura de hacer las cosas. Síguelos y no tendrás problemas.
- Tus normas de cabecera: #strong[Part-SFCL] (tu licencia), #strong[SERA] (cómo volar) y #strong[Part-SAO] (cómo operar tu planeador).

= Aeronavegabilidad
<aeronavegabilidad>
#quote(block: true)[
Un planeador sano es un planeador seguro; aprende a verificar la "salud técnica" de tu aeronave antes de cada vuelo.

En este capítulo aprenderás:

- La diferencia entre el Certificado de Aeronavegabilidad (#strong[Certificate of Airworthiness], CofA) y el Certificado de Revisión de Aeronavegabilidad (ARC, #strong[Airworthiness Review Certificate]), y qué exige la ley para volar con ellos en regla.
- El marco de mantenimiento de la aviación ligera (Part-ML) desde su cara jurídica ---el detalle técnico se ve en el Libro 8---.
- Lo que te toca a ti: inspección pre-vuelo, verificación de documentos y reporte de defectos.
]

== Concepto de aeronavegabilidad
<concepto-de-aeronavegabilidad>
La aeronavegabilidad es, en pocas palabras, la salud técnica de tu aeronave. Un planeador es aeronavegable cuando cumple con el diseño aprobado por la autoridad (tiene sus papeles en regla) y está en condiciones de operar de manera segura, sin defectos peligrosos.

Como piloto, eres el último eslabón de la cadena de seguridad. Da igual lo bien diseñado que esté el avión: si no se mantiene correctamente, deja de ser seguro.

== Certificado de aeronavegabilidad (CofA)
<certificado-de-aeronavegabilidad-cofa>
El #strong[Certificado de Aeronavegabilidad] (CofA) es el documento que emite la autoridad del estado de matrícula (AESA en España) certificando que la aeronave cumple con las normas de seguridad vigentes.

El CofA de las aeronaves EASA tiene validez #strong[ilimitada]: no caduca, siempre que la aeronave se mantenga aeronavegable conforme a su programa de mantenimiento y nadie lo revoque (#ref(<fig-01-cap02-cofa-example>, supplement: [Figura])). Eso sí, para ser válido debe ir siempre acompañado de un ARC en vigor. Sin ARC, el CofA es papel mojado.

#figure([
#box(image("imagenes/01-cap02-certificado-aeronavegabilidad.jpg"))
], caption: figure.caption(
position: bottom, 
[
Certificado de Aeronavegabilidad EASA
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap02-cofa-example>


== La "ITV" anual: Certificado de Revisión de Aeronavegabilidad (ARC)
<la-itv-anual-certificado-de-revisión-de-aeronavegabilidad-arc>
El #strong[ARC] (#strong[Airworthiness Review Certificate], Certificado de Revisión de Aeronavegabilidad) confirma que, en un momento dado, alguien revisó la documentación y el estado físico del avión y todo estaba correcto.

Su validez es de #strong[un año], así que toca renovarlo o prorrogarlo anualmente. En un entorno controlado (gestionado por una CAMO o, en aviación ligera, por una CAO), el ARC admite dos prórrogas consecutivas sin revisión física completa, es decir, 1 año + 1 año + 1 año. Al tercer año, revisión a fondo sin excusas (#ref(<fig-01-cap02-arc-process>, supplement: [Figura])). El régimen técnico que sostiene el ARC ---el programa de mantenimiento, el programa mínimo de inspección y las directivas de aeronavegabilidad--- se desarrolla en el #strong[Libro 8 --- Conocimientos generales de la aeronave], capítulo 9; aquí interesa su cara jurídica: sin ARC en vigor no puedes volar.

#block[
#callout(
body: 
[
Nunca vueles si el ARC está caducado. Es ilegal y, lo más importante, significa que nadie ha certificado oficialmente que el avión es seguro para volar en el último año. Además, muy probablemente tu aseguradora rechazará la cobertura si ocurre algo: la mayoría de las pólizas la condicionan a que la aeronave esté aeronavegable.

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
#box(image("imagenes/01-cap02-ciclo-arc.jpg"))
], caption: figure.caption(
position: bottom, 
[
Ciclo de vida del ARC y sus prórrogas
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap02-arc-process>


== Mantenimiento de planeadores: Part-ML
<mantenimiento-de-planeadores-part-ml>
Desde el punto de vista legal basta con que retengas el marco: los planeadores se mantienen bajo la #strong[Part-ML] (Anexo Vb del Reglamento (UE) 1321/2014), una normativa simplificada para la aviación ligera que descansa sobre un #strong[Programa de Mantenimiento (AMP)] y que, en ciertas tareas sencillas, permite al #strong[piloto-propietario] firmar el mantenimiento él mismo. El desarrollo de todo esto ---cómo funciona el AMP, el programa mínimo de inspección, qué tareas puede firmar el piloto-propietario y con qué condiciones, las directivas de aeronavegabilidad (AD) y los boletines de servicio (SB)--- corresponde a su asignatura natural, #strong[Conocimientos generales de la aeronave]: se estudia en el #strong[Libro 8], capítulo 9.

== Responsabilidades del piloto
<responsabilidades-del-piloto>
No eres mecánico, pero sí el responsable final de aceptar el avión para el vuelo. Tres tareas son tuyas y de nadie más.

=== 1. Inspección pre-vuelo
<inspección-pre-vuelo>
Antes de cada vuelo te toca una inspección exterior e interior, siguiendo la lista de chequeo del #strong[Manual de Vuelo del Planeador (AFM)]. Es una obligación legal, pero sobre todo es sentido común.

=== 2. Verificación de documentación
<verificación-de-documentación>
Antes de despegar, comprueba que la documentación obligatoria está a bordo y en vigor. Según la normativa de operaciones de planeadores (Part-SAO), esto incluye:

- #strong[Documentos de la aeronave]: CofA, ARC, Certificado de Matrícula, Seguro, Licencia de Estación de Radio.
- #strong[Documentos de la operación]: Manual de Vuelo (AFM), listas de chequeo.
- #strong[Documentos del piloto]: tu licencia (SPL) y tu certificado médico.

=== 3. Reporte de defectos
<reporte-de-defectos>
Si encuentras algo mal durante la pre-vuelo o durante el vuelo, anótalo en el #strong[Technical Log Book (Diario de a bordo)]. El siguiente piloto te lo agradecerá.

#block[
#callout(
body: 
[
¿Ves una muesca en el gelcoat? No es solo estética: si afecta al perfil, afecta al vuelo. Ante la duda, pregunta. Es mejor ser un piloto curioso que un piloto en apuros.

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
#strong[Resumen del Capítulo: Aeronavegabilidad]

La aeronavegabilidad es la salud de tu aeronave. Para volar legal y seguro:

- #strong[CofA]: acredita que el diseño del avión es idóneo y seguro. Lo emite EASA/AESA y no caduca si el avión se mantiene correctamente.
- #strong[ARC]: la "ITV" anual. Confirma que el avión está revisado y apto. Verifica su fecha de validez antes de volar.
- #strong[Part-ML]: el marco de mantenimiento de los planeadores; permite al piloto-propietario certificar tareas sencillas. Su desarrollo técnico (AMP, programa mínimo de inspección, AD/SB) está en el #strong[Libro 8], capítulo 9.
- #strong[Tu parte]: hacer la inspección pre-vuelo, verificar que la documentación (CofA, ARC, seguro…​) está a bordo y en vigor, y anotar cualquier defecto en el Diario de a bordo.

= Marcas de nacionalidad y matrícula de aeronaves
<marcas-de-nacionalidad-y-matrícula-de-aeronaves>
#quote(block: true)[
Tu planeador tiene una identidad legal única; identificarlo correctamente es el primer paso de cualquier operación.

En este capítulo aprenderás:

- Cómo leer e interpretar las marcas de matrícula (EC-ABC).
- Para qué sirve la placa de identificación ignífuga y dónde encontrarla.
- Por qué tu planeador lleva la bandera de España.
]

== El DNI de tu planeador: nacionalidad y matrícula
<el-dni-de-tu-planeador-nacionalidad-y-matrícula>
Toda aeronave civil debe estar registrada en un país y llevar sus marcas de identidad bien visibles. Es como la matrícula de un coche, pero con rango internacional.

En España, la marca de nacionalidad es #NormalTok("EC");, seguida de un guion y tres letras: por ejemplo, #NormalTok("EC-BOH");. Estas marcas las asigna el Estado (AESA) y son únicas para cada aeronave.

#block[
#callout(
body: 
[
El artículo 20 del Convenio de Chicago establece que toda aeronave empleada en la navegación aérea internacional debe llevar las correspondientes marcas de nacionalidad y matrícula. En España, las matrículas comienzan por #strong[EC-].

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
== Ubicación y dimensiones de las marcas
<ubicación-y-dimensiones-de-las-marcas>
No basta con pintar las letras donde quepan: su posición y tamaño están regulados para que sean legibles desde el suelo o desde otras aeronaves.

Según la normativa española (y el Anexo 7 de OACI), en los aerodinos (aviones y planeadores):

+ #strong[En las alas]: en la superficie inferior (intradós) del ala izquierda, o abarcando ambas alas, con una altura mínima de #strong[50 centímetros].
+ #strong[En la cola o el fuselaje]: en ambos lados del fuselaje (entre las alas y la cola) o en las superficies verticales de cola, con una altura mínima de #strong[30 centímetros].

Si el planeador es muy estilizado y no caben marcas de este tamaño, la autoridad puede aceptar dimensiones reducidas, siempre que sigan siendo legibles (#ref(<fig-01-cap03-matricula-ubicacion>, supplement: [Figura])).

#figure([
#box(image("imagenes/01-cap03-ubicacion-matricula.jpg"))
], caption: figure.caption(
position: bottom, 
[
Ubicación de marcas de matrícula en un planeador
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap03-matricula-ubicacion>


== La placa de identificación (Fireproof Plate)
<la-placa-de-identificación-fireproof-plate>
Además de la pintura, tu planeador necesita una identidad "indestructible": una #strong[placa de identificación] de #strong[material ignífugo] (acero inoxidable, titanio…​) fijada a la estructura, normalmente cerca de la entrada de la cabina, de forma que sea legible.

En ella van grabados la marca de nacionalidad, la matrícula y los datos de fabricante, modelo y número de serie (#ref(<fig-01-cap03-placa-ignifuga>, supplement: [Figura])). Su razón de ser es sombría pero importante: si hay un accidente con fuego, la placa debe sobrevivir para que la aeronave pueda identificarse.

#block[
#callout(
body: 
[
Nunca pintes encima de la placa de identificación ni la cubras. Su función es vital en caso de investigación de accidentes. Si restauras el planeador, asegúrate de que la placa sigue ahí y es legible.

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
#box(image("imagenes/01-cap03-placa-ignifuga.jpg"))
], caption: figure.caption(
position: bottom, 
[
Ejemplo de placa de identificación ignífuga
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap03-placa-ignifuga>


== La bandera de España
<la-bandera-de-españa>
Junto a las letras, es obligatorio llevar la #strong[bandera de España], normalmente en la deriva o en el fuselaje, por encima de la matrícula y paralela a la línea de vuelo. Es el símbolo de la nacionalidad de la aeronave y de la soberanía del estado que la registra.

#block[
#callout(
body: 
[
#strong[EC] = Nemotecnia #emph[#strong[E]spaña #strong[C]ivil]. La marca oficial OACI para España es "EC".

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
#strong[Resumen del Capítulo: Marcas y Matrícula]

Tu planeador tiene una identidad legal única que debe ser visible y resistente:

- #strong[Nacionalidad y matrícula]: en España, #strong[EC-] seguida de tres letras (ej: EC-BOH).
- #strong[Marcas pintadas]: en el fuselaje o la cola (y bajo las alas en algunos casos), más la bandera de España.
- #strong[Placa de identificación]: de material ignífugo, con la matrícula grabada, fijada a la estructura cerca de la entrada.

= Licencias de personal
<licencias-de-personal>
#quote(block: true)[
Tu licencia es un privilegio, no un derecho; mantenerla activa requiere experiencia continua y aptitud médica.

En este capítulo aprenderás:

- Qué es la licencia SPL: validez, privilegios y normativa aplicable (Part-SFCL).
- Las diferencias entre el certificado médico LAPL y el Clase 2, y cuánto duran.
- La regla "5 horas - 15 lanzamientos - 2 vuelos" para mantenerte legal.
- Qué necesitas, además de la licencia, para llevar a alguien contigo.
]

== La licencia SPL (Sailplane Pilot Licence)
<la-licencia-spl-sailplane-pilot-licence>
Para volar un planeador legalmente en Europa necesitas una licencia #strong[SPL] (#strong[Sailplane Pilot Licence]), regulada por la Part-SFCL del Reglamento (UE) 2018/1976 (actualizado por el 2020/358).

Puedes obtenerla a los 16 años, aunque ya a los 14 puedes volar solo como alumno. Te da derecho a actuar como piloto al mando (PIC) en planeadores y motoveleros, y en teoría es #strong[vitalicia]: el papel no caduca.

Pero que el papel no caduque no significa que puedas volar siempre. Para ejercer tus privilegios debes cumplir dos condiciones #strong[sine qua non]: tener un #strong[certificado médico válido] y cumplir los requisitos de #strong[experiencia reciente].

== El certificado médico
<el-certificado-médico>
Sin médico, no hay vuelo. Controlar la fecha de caducidad es responsabilidad tuya.

Vale tanto un certificado #strong[Clase 2] como un #strong[LAPL] (#strong[Light Aircraft Pilot Licence]). Para la mayoría de pilotos deportivos, el LAPL es suficiente y menos exigente. Su validez depende de tu edad: #strong[60 meses] (5 años) si tienes menos de 40, y #strong[24 meses] (2 años) a partir de los 40 (#ref(<fig-01-cap04-medical-validity>, supplement: [Figura])). Ojo con el matiz de MED.A.045: un certificado emitido #strong[antes] de cumplir los 40 deja de ser válido cuando cumples los #strong[42], aunque los 60 meses no hayan vencido. Si te lo expidieron a los 39, no te vale hasta los 44: caduca a los 42.

#block[
#callout(
body: 
[
Si tu salud cambia (operación, enfermedad grave, embarazo, nuevas gafas), tu certificado médico puede quedar en suspenso. Consulta siempre con un Médico Examinador Aéreo (AME) antes de volver a volar.

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
#box(image("imagenes/01-cap04-validez-medical.jpg"))
], caption: figure.caption(
position: bottom, 
[
Validez de certificados médicos según edad
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap04-medical-validity>


== Experiencia reciente: la regla de los 24 meses
<experiencia-reciente-la-regla-de-los-24-meses>
Para volar solo o con pasajeros debes demostrar que estás al día. La normativa SFCL establece una ventana móvil de los #strong[últimos 24 meses], dentro de los cuales, para mantener activos tus privilegios en planeadores (excluyendo TMG), debes haber completado:

+ #strong[5 horas] de vuelo como piloto al mando (o doble mando).
+ #strong[15 lanzamientos].
+ #strong[2 vuelos de entrenamiento] con un instructor.

=== ¿Qué pasa si no cumplo?
<qué-pasa-si-no-cumplo>
No pierdes la licencia; tus privilegios quedan "dormidos". Para despertarlos tienes dos caminos: pasar una #strong[verificación de competencia] (#strong[proficiency check]) con un examinador, o volar con instructor en doble mando hasta completar lo que te falte (#ref(<fig-01-cap04-recencia-flow>, supplement: [Figura])).

#block[
#callout(
body: 
[
- #strong[5 , 15 , 2]
- #strong[5] horas, #strong[15] despegues, #strong[2] vuelos con instructor. (En los últimos 2 años).

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
#box(image("imagenes/01-cap04-recencia-requisitos.jpg"))
], caption: figure.caption(
position: bottom, 
[
Diagrama de flujo: ¿Puedo volar hoy?
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap04-recencia-flow>


== Transporte de pasajeros
<transporte-de-pasajeros>
Llevar a alguien contigo es una gran responsabilidad, y la licencia recién sacada no te lo permite de inmediato. Primero debes completar #strong[10 horas] de vuelo o #strong[30 lanzamientos] como piloto al mando #strong[después] de obtener la licencia y, además, un #strong[vuelo de entrenamiento] en el que demuestres a un instructor FI(S) tu competencia para el transporte de pasajeros (salvo que ya seas titular de un certificado FI(S)).

Y una vez cumplido eso, hay un requisito de recencia: #strong[3 lanzamientos en los últimos 90 días]. Si llevas tres meses sin volar, haz unos vuelos solo antes de invitar a nadie.

#block[
#callout(
body: 
[
Reglamentos (UE) 2018/1976 y 2020/358 (SFCL.115): el titular de una SPL solo transportará pasajeros si, tras obtener la licencia, ha completado 10 horas de vuelo o 30 lanzamientos como PIC #strong[y un vuelo de entrenamiento demostrando la competencia a un FI(S)] (o posee certificado FI(S)), además de cumplir la recencia de SFCL.160(e). El incumplimiento implica sanción y pérdida de cobertura del seguro.

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
#strong[Resumen del Capítulo: Licencias]

Para pilotar legalmente necesitas tres cosas:

- #strong[Licencia SPL]: tu título de piloto, regido por la Part-SFCL. Vale de por vida, pero sus atribuciones dependen del médico y de la experiencia reciente.
- #strong[Certificado médico]: Clase 2 o LAPL. Sin médico en vigor, la licencia es papel mojado.
- #strong[Experiencia reciente]: en los últimos 24 meses, 5 horas de vuelo (como PIC, doble mando o con FI(S)), 15 lanzamientos y 2 vuelos de entrenamiento con un FI(S). Si no llegas, vuela con instructor hasta cumplirlos o supera una verificación de competencia con un FE(S).
- #strong[Pasajeros]: requieren experiencia extra (10 h o 30 lanzamientos tras la licencia), un vuelo de entrenamiento con un FI(S) demostrando competencia (salvo que ya seas FI(S)) y 3 lanzamientos en los últimos 90 días.

= Reglas del aire
<reglas-del-aire>
#quote(block: true)[
El cielo no tiene señales de STOP, pero tiene reglas estrictas; dominar el reglamento SERA es esencial para evitar colisiones.

En este capítulo aprenderás:

- El reglamento SERA, el código de circulación aéreo europeo.
- El principio de "ver y evitar" del vuelo visual (VFR).
- Quién cede el paso a quién (globos \> planeadores \> motor).
- Cuándo puedes volar bajo (laderas, tomas fuera de campo) y cuándo no.
]

== El código de circulación del cielo: SERA
<el-código-de-circulación-del-cielo-sera>
En Europa volamos bajo un reglamento unificado: #strong[SERA] (#strong[Standardised European Rules of the Air]), directamente aplicable en España como reglamento de la UE y complementado por el Real Decreto 552/2014. Da igual si vuelas en Albacete o en Alemania: las reglas básicas son las mismas.

El principio fundamental es #strong[VFR] (#strong[Visual Flight Rules]): volamos basándonos en referencias visuales externas.

== Principio básico: "ver y evitar"
<principio-básico-ver-y-evitar>
En vuelo visual, tú eres el único responsable de no chocar. El control de tráfico (ATC) puede ayudarte, pero la responsabilidad final es tuya. Eso exige un escaneo constante del cielo (la técnica del barrido visual) y algo de gimnasia: mueve el avión o la cabeza para ver detrás de los montantes o bajo el morro, porque los puntos ciegos existen.

#block[
#callout(
body: 
[
La mayoría de colisiones ocurren en días claros y cerca de los aeródromos. Nunca asumas que el otro te ha visto. Si tienes dudas, cede el paso.

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
== Prioridades de paso (Right of Way)
<prioridades-de-paso-right-of-way>
¿Quién pasa primero cuando dos aeronaves se encuentran? SERA.3210 lo deja claro.

=== 1. La jerarquía de maniobrabilidad
<la-jerarquía-de-maniobrabilidad>
La regla básica: quien menos capacidad de maniobra tiene, prioridad lleva.

+ #strong[Globos]: máxima prioridad, apenas pueden maniobrar.
+ #strong[Planeadores]: solo bajamos; no podemos mantener nivel indefinidamente.
+ #strong[Dirigibles].
+ #strong[Aviones con motor y ultraligeros]: tienen motor y maniobran a voluntad.

Hay una excepción: las aeronaves de motor deben ceder el paso a las que remolcan a otra aeronave u objetos (la pancarta o el propio conjunto remolcador-planeador), porque su maniobrabilidad está muy reducida. A ti como velero libre la norma no te obliga, pero la prudencia sí: apártate de un tren de remolque en cuanto lo veas.

=== 2. Situaciones de conflicto
<situaciones-de-conflicto>
- #strong[De frente] (#strong[head-on]): ambos viran a su #strong[derecha].

- #strong[Convergencia]: en rutas que se cruzan al mismo nivel, tiene prioridad quien viene por la #strong[derecha]. Ojo: si tú vienes por la derecha pero vuelas a motor y el otro es un planeador, el planeador manda por jerarquía.

- #strong[Alcance]: si alcanzas a otro por detrás, el de delante tiene prioridad. Rebásalo por su #strong[derecha]. Con una excepción hecha a nuestra medida: un planeador que adelanta a otro planeador puede hacerlo #strong[por la derecha o por la izquierda] (útil en ladera, donde solo un lado es seguro).

- #strong[En ladera]: si dos planeadores se encuentran en rumbo de colisión volando una ladera, #strong[tiene prioridad el que lleva la montaña a su derecha]. El otro debe separarse de la ladera para dejar paso (#ref(<fig-01-cap05-prioridades-ladera>, supplement: [Figura])).

#figure([
#box(image("imagenes/01-cap05-preferencias-paso-ladera.jpeg"))
], caption: figure.caption(
position: bottom, 
[
Preferencia de paso en vuelo de ladera
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap05-prioridades-ladera>


- #strong[Aterrizaje]: el velero más bajo tiene prioridad para aterrizar (pero no vale picar para colarse). Además, según SERA.3210, los planeadores en final y aterrizaje siempre tienen preferencia sobre las aeronaves de motor (#ref(<fig-01-cap05-prioridades>, supplement: [Figura])).

#figure([
#box(image("imagenes/01-cap05-prioridades-paso.jpg"))
], caption: figure.caption(
position: bottom, 
[
Reglas de prioridad de paso: Frente y Convergencia
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap05-prioridades>


== Alturas mínimas de vuelo
<alturas-mínimas-de-vuelo>
Para proteger a las personas y bienes en tierra, SERA.5005 establece alturas mínimas. Salvo para despegar o aterrizar, no puedes volar por debajo de:

+ #strong[300 m] sobre el obstáculo más alto en un radio de 600 m, cuando sobrevuelas aglomeraciones (ciudades, pueblos, gente reunida).
+ #strong[150 m] sobre tierra o agua, en campo abierto.

=== Excepciones para el vuelo a vela
<excepciones-para-el-vuelo-a-vela>
La norma reconoce nuestra operativa particular:

- #strong[Vuelo de ladera]: puedes volar por debajo de 150 m si lo necesitas para sustentarte en la ladera, siempre que no pongas en peligro a nadie.
- #strong[Entrenamiento de tomas fuera de campo]: se permite bajar hasta #strong[50 m] para simular una toma, manteniendo 150 m de distancia horizontal con cualquier persona, vehículo o edificio (#ref(<fig-01-cap05-alturas-minimas>, supplement: [Figura])).

#figure([
#box(image("imagenes/01-cap05-alturas-minimas.jpg"))
], caption: figure.caption(
position: bottom, 
[
Alturas mínimas de seguridad
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap05-alturas-minimas>


#block[
#callout(
body: 
[
#strong[Globo \> Planeador \> Motor.] Si tiene motor, te cede el paso. Si es un globo, tú cedes. Si vais de frente, #strong[siempre a la derecha].

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
#strong[Resumen del Capítulo: Reglas del Aire]

El reglamento #strong[SERA] es el código de circulación del cielo:

- #strong[VFR]: volamos viendo y siendo vistos. Ojos fuera.
- #strong[Prioridad de paso]: globos \> planeadores \> motor (cede quien más maniobra tiene). En convergencia, paso para el que viene por la derecha. En ladera, prioridad para quien lleva la montaña a su derecha. En aterrizaje, el velero más bajo manda, y los planeadores tienen preferencia sobre los aviones a motor.
- #strong[Alturas mínimas]: 150 m en general, 300 m sobre zonas pobladas. Los planeadores pueden volar más bajo en ladera (sin riesgo para personas o bienes) y bajar hasta 50 m entrenando tomas fuera de campo, a 150 m de personas y vehículos.

= Procedimientos para navegación aérea: operaciones de aeronaves
<procedimientos-para-navegación-aérea-operaciones-de-aeronaves>
#quote(block: true)[
Navegar seguro exige reglas precisas; domina los mínimos VMC y los niveles de crucero para compartir el cielo eficientemente.

En este capítulo aprenderás:

- Los mínimos meteorológicos (VMC): cuándo es legal volar visual y qué excepciones tenemos los planeadores.
- La regla semicircular: cómo elegir tu altitud de crucero según el rumbo.
- La diferencia crítica entre QNH (altitud), QFE (altura) y QNE (niveles de vuelo).
- Cuándo es obligatorio el oxígeno para esquivar la hipoxia silenciosa.
]

== Mínimos VFR: Visibilidad y Distancia a Nubes
<mínimos-vfr-visibilidad-y-distancia-a-nubes>
Para volar visual (VFR) necesitas unas condiciones meteorológicas mínimas (#strong[VMC]). Si el tiempo baja de esos mínimos, el vuelo VFR está prohibido. La regla general se divide por altitud.

=== Por debajo de 3.000 ft AMSL (o 1.000 ft AGL)
<por-debajo-de-3.000-ft-amsl-o-1.000-ft-agl>
Es la zona donde solemos movernos los planeadores, y los mínimos dependen del espacio aéreo en que estés:

- #strong[Espacio aéreo controlado (Clases B, C, D, E)]: visibilidad de 5 km y distancia a nubes de 1.500 m en horizontal y 1.000 ft en vertical.
- #strong[Espacio aéreo no controlado (Clases F, G)]: visibilidad de 5 km, libre de nubes y a la vista de la superficie.

Hay una excepción interesante en espacio no controlado: si vuelas a menos de 140 kt (como un planeador), la normativa permite reducir la visibilidad mínima a #strong[1.500 m], siempre que tu velocidad te deje ver otros tráficos u obstáculos con tiempo de sobra para evitar la colisión (#ref(<fig-01-cap06-vmc-minima>, supplement: [Figura])).

=== Por encima de 3.000 ft AMSL (hasta FL 100)
<por-encima-de-3.000-ft-amsl-hasta-fl-100>
Visibilidad de 5 km y distancia a nubes de 1.500 m en horizontal y 1.000 ft en vertical, estés en el espacio aéreo que estés. Y un dato para los días grandes de onda: por encima de FL 100, la visibilidad mínima sube a #strong[8 km].

#figure([
#box(image("imagenes/01-cap06-minimos-vmc.jpg"))
], caption: figure.caption(
position: bottom, 
[
Mínimos VMC (Visual Meteorological Conditions) para vuelo visual (VFR).
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap06-vmc-minima>


== Regla semicircular de niveles de crucero
<regla-semicircular-de-niveles-de-crucero>
Para evitar encuentros frontales en ruta, cada uno vuela a una altitud según su derrota magnética. En España, desde 2019, la regla semicircular para vuelos VFR por encima de #strong[3.000 ft AGL] se orienta #strong[Norte-Sur]:

- #strong[Derrotas hacia el norte (270° a 089°)]: altitudes o niveles #strong[pares] + 500 ft (4.500 ft, 6.500 ft, FL 45, FL 65…​).
- #strong[Derrotas hacia el sur (090° a 269°)]: altitudes o niveles #strong[impares] + 500 ft (3.500 ft, 5.500 ft, FL 35, FL 55…​).

#block[
#set enum(numbering: "(1)", start: 1)
+
]

#block[
#callout(
body: 
[
#strong[Norte Par / Sur Impar] Hacia el #strong[N]orte → Niveles #strong[P]ares. Hacia el #strong[S]ur → Niveles #strong[I]mpares.

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
#box(image("imagenes/01-cap06-regla-semicircular.jpg"))
], caption: figure.caption(
position: bottom, 
[
Regla semicircular de niveles de crucero VFR (Norte-Sur)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap06-semicircular>


== Reglaje de altímetro: QNH, QFE y QNE
<reglaje-de-altímetro-qnh-qfe-y-qne>
Tu altímetro mide presión, no altura. Según qué presión le pongas en la ventanilla de Kollsman, te contará una historia u otra:

- #strong[QNH]: presión al nivel del mar. El altímetro marca #strong[altitud] (sobre el mar). Es lo que usamos para navegar y respetar circuitos; en el suelo marca la elevación del campo.
- #strong[QFE]: presión del aeródromo. El altímetro marca #strong[altura] sobre el campo; en el suelo marca cero. Poco usado en travesía, útil en vuelo local o competición.
- #strong[QNE]: presión estándar (1013,2 hPa). El altímetro marca #strong[niveles de vuelo (FL)]. Se usa por encima de la altitud de transición (6.000 ft en general en España, con excepciones como Madrid a 13.000 ft o Granada a 7.000 ft) para que todos los aviones compartan la misma referencia, haga la meteo que haga. Un matiz: a diferencia del QNH y el QFE, el QNE no es una presión que te reporte nadie, sino la #strong[lectura del altímetro con 1013,2 hPa calados]\; por eso se habla de «calar estándar», no de «poner el QNE».

#block[
#callout(
body: 
[
Como regla mnemotécnica en inglés:

- #strong[QNH] = #emph[#strong[N]autical #strong[H]eight] (Altitud sobre el nivel del mar).
- #strong[QFE] = #emph[#strong[F]ield #strong[E]levation] (Altura sobre el campo de vuelo).

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
Por debajo de la #strong[Altitud de Transición] (6.000 ft en la mayor parte de España, salvo excepciones como Madrid o Granada), volamos con #strong[QNH] (Altitud). Por encima, calamos #strong[1013] y volamos en #strong[Niveles de Vuelo (FL)].

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
== Oxígeno suplementario
<oxígeno-suplementario>
A medida que subes hay menos oxígeno, y la hipoxia es un enemigo silencioso: te sientes eufórico, pierdes juicio y te desmayas sin previo aviso. Por eso la norma dice dos cosas:

+ El piloto al mando debe asegurar que todos los ocupantes usen oxígeno suplementario siempre que determine que su falta puede afectar a sus facultades.
+ Si el piloto no puede determinar ese efecto, según EASA el oxígeno #strong[deberá] usarse siempre por encima de los #strong[10.000 ft].

#block[
#callout(
body: 
[
#strong[AMC1 SAO.OP.150:] El piloto al mando debe asegurarse de que todos los ocupantes utilicen oxígeno suplementario siempre que la altitud de presión sea superior a los #strong[10.000 ft], en los casos en que no pueda determinar cómo la falta de oxígeno puede afectar a las personas a bordo.

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
La norma legal es el mínimo. Fisiológicamente, muchos pilotos sufren deterioro a partir de 8.000-9.000 ft, especialmente de noche o ante fatiga. En vuelos de onda, conecta el oxígeno y úsalo antes de alcanzar los 10.000 ft.

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
== Instrumentos mínimos a bordo
<instrumentos-mínimos-a-bordo>
La misma normativa de operaciones fija el equipamiento mínimo del planeador según el tipo de vuelo.

#block[
#callout(
body: 
[
#strong[SAO.IDE.105 a)]: todo planeador debe llevar medios para medir y mostrar la hora (en horas y minutos), la altitud de presión y la velocidad aerodinámica indicada; los planeadores motorizados añaden el rumbo magnético. #strong[SAO.IDE.105 b)]: para volar en condiciones de nebulosidad o de noche se añaden medios para medir y mostrar la velocidad vertical, la actitud ---o el viraje y el resbale--- y el rumbo magnético.

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
En la práctica: de día y en VFR bastan un reloj de pulsera, el altímetro y el anemómetro. La brújula se suma en los motorizados (TMG). Y el vuelo en nube o nocturno exige además el variómetro, un indicador de actitud o de viraje y resbale, y el rumbo magnético.

Queda un procedimiento operativo del syllabus que esta colección desarrolla en otros volúmenes: el #strong[plan de vuelo]. Su operativa por radio está en el #strong[Libro 4 --- Comunicaciones] (cap. 3), el formulario OACI casilla a casilla en el #strong[Libro 7 --- Planificación] (cap. 4) y su relación con los servicios ATS en el #strong[Libro 9 --- Navegación] (cap. 7).

#strong[Resumen del Capítulo: Procedimientos para la Navegación]

- #strong[Mínimos VMC]: regla general, 5 km de visibilidad y nubes a 1.500 m en horizontal / 1.000 ft en vertical. Por debajo de 3.000 ft AMSL (o 1.000 ft AGL) en espacio no controlado basta con 5 km, libre de nubes y suelo a la vista; y volando a menos de 140 kt, la visibilidad puede reducirse a 1.500 m. Por encima de FL 100, 8 km.
- #strong[Regla semicircular (España, Norte-Sur)]: hacia el Norte (270°-089°), pares + 500 ft; hacia el Sur (090°-269°), impares + 500 ft. «Norte Par / Sur Impar».
- #strong[Altímetro]: QNH = altitud (navegación y circuitos); QFE = altura sobre el campo; QNE (1013) = niveles de vuelo por encima de la altitud de transición (6.000 ft en general en España).
- #strong[Oxígeno]: según SAO.OP.150, el comandante debe garantizar su uso cuando determine que la falta de oxígeno puede disminuir las facultades o ser dañina. Si no puede valorar ese efecto, el AMC1 SAO.OP.150 fija la regla por defecto: usar oxígeno por encima de 10.000 ft. Fisiológicamente, conéctalo antes.
- #strong[Pre-vuelo (SAO.GEN.130)]: antes de iniciar el vuelo, el piloto al mando comprueba que el planeador es aeronavegable, está matriculado y lleva los instrumentos y equipos necesarios instalados y operativos; también verifica masa, centrado, estiba y límites del AFM.
- #strong[Instrumentos mínimos (SAO.IDE.105)]: hora, altitud de presión y velocidad indicada; los TMG añaden rumbo magnético. En nube o de noche: velocidad vertical, actitud o viraje/resbale, y rumbo magnético.

= Reglamentación de tránsito aéreo: estructura del espacio aéreo
<reglamentación-de-tránsito-aéreo-estructura-del-espacio-aéreo>
#quote(block: true)[
El cielo está dividido en "cajones" invisibles; saber en cuál estás es la clave para evitar infracciones y peligros.

En este capítulo aprenderás:

- Las clases de espacio aéreo: qué cambia entre el controlado (A-E) y el no controlado (G).
- Cuándo necesitas autorización, radio y transponder para entrar.
- Cómo operar en las zonas RMZ (radio obligatoria) y TMZ (transponder obligatorio).
- Dónde está prohibido o es peligroso volar: las áreas P, R y D.
]

== El mapa de carreteras del cielo
<el-mapa-de-carreteras-del-cielo>
El aire no es libre, o al menos no todo. Para ordenar el tráfico, el espacio aéreo se divide en #strong[clases] (de la A a la G) y #strong[zonas]. Saber dónde estás es vital para no infringir la ley ni ponerte en peligro.

== Espacio aéreo controlado vs no controlado
<espacio-aéreo-controlado-vs-no-controlado>
Esta es la gran división. En el #strong[controlado], alguien (ATC) te separa de otros aviones, o al menos te vigila. En el #strong[no controlado] vas por tu cuenta, eso sí, con la radio a mano.

=== Clases de espacio aéreo (SERA.6001)
<clases-de-espacio-aéreo-sera.6001>
La OACI define 7 clases, pero en España usamos principalmente las clases #strong[A, C, D y E] (controladas) y la #strong[G] (no controlada) (#ref(<fig-01-cap07-clases-espacio>, supplement: [Figura])).

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Clase], [Tipo], [Requisitos para VFR (Planeadores)],),
  table.hline(),
  [#strong[A]], [#strong[Controlado] (Exclusivo IFR)], [#strong[PROHIBIDO VFR]. No puedes entrar. (Ej: Madrid TMA Area A). #strong[Requisitos]: Autorización + Radio + Transponder.],
  [#strong[C]], [#strong[Controlado]], [#strong[Separación]: ATC te separa del IFR. De otros VFR solo recibes información de tráfico (y asesoramiento anticolisión si lo pides): #strong[de los VFR te separas tú]. #strong[Requisitos]: Autorización + Radio + Transponder.],
  [#strong[D]], [#strong[Controlado]], [#strong[Separación]: ninguna para el VFR. ATC te da información de tráfico del IFR y de otros VFR, pero #strong[ver y evitar es cosa tuya]. #strong[Requisitos]: Autorización + Radio + Transponder (generalmente).],
  [#strong[E]], [#strong[Controlado] (Para IFR)], [#strong[Híbrido]: Controlado para IFR, "libre" para VFR. #strong[VFR]: No necesitas autorización ni radio (aunque es muy recomendable). ATC no te separa de nadie, pero da información de tráfico si puede.],
  [#strong[G]], [#strong[NO Controlado]], [#strong[Libre]: Vuelas bajo tu responsabilidad. #strong[Servicio]: Solo Información de Vuelo (FIS) si la pides.],
)
#block[
#callout(
body: 
[
Aunque la normativa OACI define teóricamente las clases #strong[B] y #strong[F], en la práctica no se utilizan para la aviación general o la formación en España. El espacio aéreo español es mayoritariamente Clase G (espacio no controlado fuera de rutas/aeropuertos) o Clases A, C, D y E (en rutas y entornos aeroportuarios).

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
#box(image("imagenes/01-cap07-clases-espacio-aereo.jpg"))
], caption: figure.caption(
position: bottom, 
[
Resumen visual de clases de espacio aéreo utilizadas en España (A,C,D,E,G)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap07-clases-espacio>


== Zonas especiales: RMZ y TMZ
<zonas-especiales-rmz-y-tmz>
A veces el espacio es Clase G, libre, pero la autoridad quiere un poco de orden sin llegar a controlarlo todo. Para eso existen dos figuras:

- #strong[RMZ] (#strong[Radio Mandatory Zone]): espacio no controlado donde es #strong[obligatorio llevar radio y comunicar]. Antes de entrar debes decir quién eres, dónde estás y qué quieres.
- #strong[TMZ] (#strong[Transponder Mandatory Zone]): es obligatorio llevar el #strong[transponder] encendido y monitorizar la frecuencia de radio correspondiente.

#block[
#callout(
body: 
[
Si ves una RMZ en el mapa, no entres mudo. Llama a la frecuencia indicada e informa: "Ibiza Información, EC-BOH, planeador, entrando en RMZ sector norte…​".

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
== Zonas Prohibidas, Restringidas y Peligrosas
<zonas-prohibidas-restringidas-y-peligrosas>
El espacio aéreo puede tener "candados" por seguridad o defensa, marcados con códigos como LER71:

- #strong[P] (#strong[Prohibited]) - Prohibida: no se entra jamás. Piensa en el Palacio Real o en centrales nucleares.
- #strong[R] (#strong[Restricted]) - Restringida: entrada sujeta a condiciones. Normalmente se puede pasar si está inactiva o con permiso especial (parques naturales, zonas de maniobras militares).
- #strong[D] (#strong[Dangerous]) - Peligrosa: hay un peligro no específico (pruebas de explosivos, actividades de riesgo). Puedes entrar bajo tu responsabilidad, pero mejor evítalas (#ref(<fig-01-cap07-zonas-prd>, supplement: [Figura])).

#figure([
#box(image("imagenes/01-cap07-zonas-prd.png"))
], caption: figure.caption(
position: bottom, 
[
Carta aeronáutica VFR mostrando zonas LEP141 (Prohibida, rojo, por central nuclear de Almaraz); LER170 y LER71C (Restringidas); LED125 (Peligrosa).
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap07-zonas-prd>


#block[
#callout(
body: 
[
Infringir una zona P o R activa puede llevar a sanciones graves e incluso a la interceptación por aviones militares. Planifica tu vuelo y comprueba los NOTAM para saber si las zonas R están activas. Las señales de interceptación y el procedimiento de respuesta (SERA.11015) se estudian en el Libro 4 (#emph[Comunicaciones]), capítulo 8.

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
#strong[Resumen del Capítulo: Espacio Aéreo]

El cielo está dividido en "cajones" con distintas reglas. No entres sin permiso donde no debes:

- #strong[Clases controladas]: la clase A es solo IFR; en C y D el VFR necesita autorización ATC y comunicación bilateral; en E el VFR no necesita autorización ni radio obligatoria. La separación la garantiza ATC según la clase: IFR siempre, y puede incluir VFR en las clases más restrictivas.
- #strong[Clase G (no controlada)]: vuelas bajo tu responsabilidad, con "ver y evitar". Puedes recibir servicio de información de vuelo (FIS) si está disponible y lo solicitas, pero nadie te separa.
- #strong[Autorizaciones ATC]: una autorización o instrucción no elimina la responsabilidad del piloto al mando. Si no puedes cumplirla con seguridad, comunícalo de inmediato y coordina una alternativa segura.
- #strong[Zonas especiales]: en una #strong[RMZ] es obligatorio llevar radio y contactar; en una #strong[TMZ], llevar el transponder encendido y mantener escucha en la frecuencia apropiada.

= Servicio de Tránsito Aéreo (
<servicio-de-tránsito-aéreo>
#quote(block: true)[
Los Servicios de Tránsito Aéreo están para ayudarte, pero debes saber qué pedir: Control, Información o Alerta.

En este capítulo aprenderás:

- Los tres servicios ATS: Control (ATC), Información (FIS) y Alerta (ALRS).
- Cuándo te separan ellos (ATC) y cuándo te separas tú (FIS).
- El protocolo de búsqueda y salvamento: INCERFA, ALERFA y DETRESFA.
]

== ¿Para qué sirve el ATS?
<para-qué-sirve-el-ats>
El objetivo de los Servicios de Tránsito Aéreo (#strong[ATS], #strong[Air Traffic Services]) va más allá de "vigilar". Según SERA.7001, sus misiones son prevenir colisiones (entre aeronaves y con obstáculos), acelerar y mantener ordenado el movimiento del tráfico, asesorar y dar información útil para la seguridad, y notificar y auxiliar en emergencias.

Para todo eso, el ATS se divide en tres servicios muy distintos entre sí. Saber cuál estás recibiendo en cada momento marca la diferencia.

== 1. Servicio de CONTROL (ATC)
<servicio-de-control-atc>
El servicio de primera división. Su misión principal es #strong[separar] aeronaves.

Lo prestan los controladores aéreos (ATCO), y de ellos recibes #strong[autorizaciones] (instrucciones obligatorias) e información de tráfico. La responsabilidad de que no choques, bajo ciertas reglas, es del controlador.

Se organiza en tres dependencias según la fase de vuelo (#ref(<fig-01-cap08-dependencias-atc>, supplement: [Figura])):

+ #strong[Torre] (TWR): controla el aeródromo y el circuito (despegues, aterrizajes, rodaje).
+ #strong[Aproximación] (APP): controla la entrada y salida de la zona del aeropuerto.
+ #strong[Centro de Control de Área] (ACC): controla los aviones en ruta, arriba del todo.

#figure([
#box(image("imagenes/01-cap08-dependencias-atc.jpg"))
], caption: figure.caption(
position: bottom, 
[
Estructura de dependencias ATC
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap08-dependencias-atc>


== 2. Servicio de INFORMACIÓN DE VUELO (FIS)
<servicio-de-información-de-vuelo-fis>
Es lo que recibimos los planeadores la mayor parte del tiempo, en Clase G o E. Lo prestan controladores o técnicos de información (FISO), y lo que te dan es #strong[asesoramiento e información]: si hay tráfico, qué tiempo hace, si hay áreas peligrosas activas…​

Aquí la responsabilidad es #strong[tuya]. El FIS te avisa ("tráfico a las 12"), pero quien ve y evita eres tú. No te separan de nadie.

#block[
#callout(
body: 
[
- #strong[ATC]: "Vire rumbo 360 por tráfico". (Orden obligatoria, ellos te separan).
- #strong[FIS]: "Tráfico convergiendo a su derecha". (Información, TÚ decides qué hacer para no chocar).

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
== 3. Servicio de ALERTA (ALRS)
<servicio-de-alerta-alrs>
Tu seguro de vida. Se activa cuando hay una emergencia o se teme por la seguridad de una aeronave, y funciona en tres fases de preocupación creciente (#ref(<fig-01-cap08-fases-emergencia>, supplement: [Figura])):

+ #strong[INCERFA (Fase de Incertidumbre)]: el "¿dónde estará?". Se empieza a recabar información. Se declara reglamentariamente ante cualquiera de estas tres situaciones:

- #strong[Falta de comunicación]: no se ha recibido ninguna comunicación de la aeronave en los 30 minutos siguientes a la hora prevista, o desde el primer intento fallido de contactarla (lo que ocurra primero).
- #strong[Retraso en la llegada]: la aeronave no llega en los 30 minutos siguientes a su hora prevista de llegada (ETA).
- #strong[Dudas sobre la seguridad]: existen sospechas o dudas fundamentadas sobre la seguridad de la aeronave y sus ocupantes.

#block[
#set enum(numbering: "1.", start: 2)
+ #strong[ALERFA (Fase de Alerta)]: sigue sin haber noticias, o se sabe que hay problemas aunque no una catástrofe. Se avisa a los servicios de rescate (SAR) para que estén listos.
+ #strong[DETRESFA (Fase de Peligro/Socorro)]: accidente confirmado, combustible agotado o situación crítica inminente. Salen los medios de rescate: helicópteros y aviones SAR.
]

#figure([
#box(image("imagenes/01-cap08-fases-emergencia.jpg"))
], caption: figure.caption(
position: bottom, 
[
Fases de emergencia del Servicio de Alerta
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap08-fases-emergencia>


#block[
#callout(
body: 
[
Si tienes una emergencia real y #strong[NO] has presentado Plan de Vuelo ni estás en contacto radio, el Servicio de Alerta tardará mucho más en activarse (solo cuando tu familia avise de que no has vuelto). ¡Usa la radio y el Plan de Vuelo!

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
Dos remisiones útiles dentro de la colección: las #strong[señales luminosas] con las que una torre puede dirigirte sin radio se estudian en el #strong[Libro 4 --- Comunicaciones], capítulo 7; y el #strong[plan de vuelo], que alimenta este servicio de alerta, en los Libros 4 (operativa), 7 (formulario) y 9 (uso de los ATS).

#strong[Resumen del Capítulo: Servicios de Tránsito Aéreo (ATS)]

El ATS te ofrece tres tipos de ayuda:

- #strong[Control (ATC)]: te dan órdenes (autorizaciones) para separarte de otros aviones. Son la TWR, la APP y el ACC, y solo opera en espacio aéreo controlado.
- #strong[Información de vuelo (FIS)]: te dan información útil (meteo, peligros, tráficos cercanos), pero el responsable de evitar colisiones eres tú. "Información de tráfico" no es "separación".
- #strong[Alerta (ALRS)]: avisa a búsqueda y salvamento (SAR) si no llegas a tiempo o tienes una emergencia.

= Servicios de Información Aeronáutica (AIS)
<servicios-de-información-aeronáutica-ais>
#quote(block: true)[
La información es seguridad; un piloto que ignora los NOTAM es un piloto que vuela a ciegas hacia el peligro.

En este capítulo aprenderás:

- Las tres fuentes de información: AIP (permanente), NOTAM (urgente) y AIC (informativo).
- El deber legal del piloto de consultar la información disponible antes del vuelo.
- Cómo usar ENAIRE Insignia para ver las restricciones sobre el mapa.
]

== La información es seguridad
<la-información-es-seguridad>
Antes de despegar, el piloto debe "familiarizarse con toda la información disponible". No es un consejo: es una #strong[obligación legal] (SERA.2010). Para que puedas cumplirla, los estados prestan los Servicios de Información Aeronáutica (#strong[AIS]).

En España, el proveedor principal es #strong[ENAIRE], y todo se agrupa en el "Paquete de Información Aeronáutica Integrada" (IAIP).

== El manual AIP (Publicación de Información Aeronáutica)
<el-manual-aip-publicación-de-información-aeronáutica>
El #strong[AIP] es la "biblia" de la aviación de un país: contiene la información permanente esencial para navegar, organizada en tres volúmenes (#ref(<fig-01-cap09-estructura-aip>, supplement: [Figura])):

+ #strong[GEN (Generalidades)]: reglamentos, señales de socorro, tablas de conversión, salida y puesta de sol, servicios disponibles.
+ #strong[ENR (En Ruta)]: estructura del espacio aéreo (vías aéreas, zonas prohibidas y restringidas), radioayudas, alertas para la navegación.
+ #strong[AD (Aeródromos)]: datos detallados de cada aeropuerto: pistas, frecuencias, horarios, mapas de aproximación y rodaje.

#figure([
#box(image("imagenes/01-cap09-estructura-aip.jpg"))
], caption: figure.caption(
position: bottom, 
[
Estructura del AIP España
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap09-estructura-aip>


=== El ciclo AIRAC
<el-ciclo-airac>
El AIP no cambia cada día. Las actualizaciones importantes y previsibles (nuevas rutas, frecuencias) se publican siguiendo el sistema #strong[AIRAC] (Reglamentación y Control de Información Aeronáutica), que garantiza que los cambios llegan a todos con antelación suficiente antes de entrar en vigor.

== Noticias urgentes: NOTAM (Notice To AirMen)
<noticias-urgentes-notam-notice-to-airmen>
#figure([
#box(image("imagenes/01-cap09-ejemplo-notam.jpg"))
], caption: figure.caption(
position: bottom, 
[
Decodificación básica de un NOTAM
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap09-ejemplo-notam>


Hay cosas que no pueden esperar al ciclo AIRAC: una grúa en final de pista, un VOR inoperativo, un festival aéreo el sábado…​ Para eso existen los #strong[NOTAM]: avisos temporales (generalmente de 3 meses como máximo) sobre el establecimiento, estado o modificación de cualquier instalación, servicio o procedimiento aeronáutico, o sobre un peligro para la navegación (#ref(<fig-01-cap09-ejemplo-notam>, supplement: [Figura])).

Consultar los NOTAM de tu aeródromo de salida, destino, alternativos y la ruta antes de #strong[cada] vuelo es obligatorio.

== Circulares de Información Aeronáutica (AIC)
<circulares-de-información-aeronáutica-aic>
Son avisos que no justifican un NOTAM (no afectan a la operación de forma urgente y directa) pero conviene conocer: asuntos administrativos como nuevas tasas, recomendaciones de seguridad estacionales, prevención de engelamiento o explicaciones técnicas.

#block[
#callout(
body: 
[
En España, puedes consultar todo esto gratis en los portales #strong[ICARO] e #strong[Insignia] de ENAIRE. Insignia es una herramienta visual fantástica para ver NOTAMs sobre el mapa. Acostúmbrate a usarla.

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
#strong[Resumen del Capítulo: Servicio de Información Aeronáutica (AIS)]

La información es seguridad. Tus fuentes:

- #strong[AIP]: el "manual gordo" y permanente. Mapas, frecuencias, zonas peligrosas, horarios de aeropuertos. Es la base.
- #strong[NOTAM]: la actualidad. Avisos temporales urgentes (una pista cerrada, un festival aéreo, una restricción temporal). Consultarlos antes de cada vuelo es obligatorio.
- #strong[AIC]: circulares informativas sobre seguridad y cambios administrativos.

= Aeródromos y campos de despegue externos
<aeródromos-y-campos-de-despegue-externos>
#quote(block: true)[
En el circuito de tránsito, las reglas visuales reinan supremas; aprende a leer las señales del suelo cuando la radio calla.

En este capítulo aprenderás:

- El circuito de tránsito: sus fases (viento en cola, base, final) y el sentido de viraje.
- El área de señales: la "T" de aterrizaje, la manga de viento y los símbolos de prohibición en el suelo.
- Normas básicas para moverse por el aeródromo con seguridad.
]

== El aeródromo: territorio de reglas visuales
<el-aeródromo-territorio-de-reglas-visuales>
Un aeródromo es mucho más que una pista. Es un sistema organizado para que aviones rápidos y planeadores lentos convivan sin chocar, y se apoya en dos pilares: el #strong[circuito de tránsito] y las #strong[señales visuales].

== El circuito de tránsito (Traffic Pattern)
<el-circuito-de-tránsito-traffic-pattern>
Para ordenar el tráfico, todos volamos un rectángulo imaginario alrededor de la pista. Los virajes se hacen a la #strong[izquierda] salvo que se indique lo contrario (#ref(<fig-01-cap10-circuito-transito>, supplement: [Figura])). En planeador, el tramo de viento en cola suele volarse a unos #strong[200-300 metros AGL], y lo ideal es incorporarse al circuito a 45º de ese tramo.

=== Fases clave para el planeador
<fases-clave-para-el-planeador>
+ #strong[Viento en cola] (#strong[downwind]): vuelas paralelo a la pista, en sentido contrario al aterrizaje. Aquí va el chequeo pre-aterrizaje.
+ #strong[Tramo base]: viras 90º hacia la pista y haces el último ajuste de altura y velocidad. Altura mínima de inicio: 150 m.
+ #strong[Final]: enfilado a pista, con frenos fuera.

#figure([
#box(image("imagenes/01-cap10-circuito-transito.jpg"))
], caption: figure.caption(
position: bottom, 
[
Circuito de tránsito estándar (Virajes a izquierda)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap10-circuito-transito>


== El área de señales
<el-área-de-señales>
#figure([
#box(image("imagenes/01-cap10-manga-viento.png"))
], caption: figure.caption(
position: bottom, 
[
Manga de viento
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap10-manga-viento>


Si no tienes radio (o te falla), el suelo te habla. Las #strong[señales luminosas] que la torre puede dirigirte con lámpara se estudian en el #strong[Libro 4 --- Comunicaciones], capítulo 7 (fallo de comunicaciones); las del suelo las tienes aquí. En el #strong[área de señales], un cuadrado bordeado de blanco cerca de la torre o la pista, encontrarás símbolos vitales (#ref(<fig-01-cap10-area-senales>, supplement: [Figura])):

#table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([Señal], [Significado],),
  table.hline(),
  [#strong[Manga de Viento]], [Indica dirección (de dónde viene) e intensidad. (Cada franja roja/blanca suele estimar unos 3 nudos, 5,5 km/h).],
  [#strong['T' de Aterrizaje]], [Indica la dirección de aterrizaje/despegue. La 'T' representa un avión: la barra vertical es el fuselaje, la horizontal las alas. #strong[Aterriza paralelo al palo vertical, hacia la T].],
  [#strong[Flecha Derecha]], [→ #strong[Atención]: Virajes a la #strong[DERECHA]. El circuito no es estándar.],
  [#strong[Cruz Roja con Diagonales]], [\(Cuadrado rojo con aspa amarilla). #strong[PROHIBIDO ATERRIZAR]. El aeródromo está cerrado o la pista inutilizable.],
  [#strong[Diagonal Única]], [\(Cuadrado rojo con una diagonal amarilla). #strong[PRECAUCIÓN]. El área de maniobras está en mal estado.],
  [#strong[Doble Cruz Blanca]], [#strong[Planeadores en actividad]. ¡Ojo! Indica que se realizan operaciones de vuelo a vela.],
  [#strong[Mancuerna (Pesas)]], [\(Blanca). Aterrizaje, despegue y rodaje #strong[SOLO en pistas y calles pavimentadas]. No pises la hierba.],
)
#figure([
#box(image("imagenes/01-cap10-senales-aerodromo.png"))
], caption: figure.caption(
position: bottom, 
[
El lenguaje del suelo: Área de señales
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap10-area-senales>


#block[
#callout(
body: 
[
Antes de despegar o al llegar a un campo nuevo, #strong[busca siempre el área de señales]. Te dará información (pista en uso y sentido de giro) de un solo vistazo, incluso sin radio.

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
== Campos de despegue externos y tomas fuera de aeródromo
<campos-de-despegue-externos-y-tomas-fuera-de-aeródromo>
El vuelo a vela no siempre empieza ni termina en un aeródromo. El syllabus incluye los #strong[campos de despegue externos] ---terrenos no certificados desde los que se opera ocasionalmente--- y, por la propia naturaleza del planeador, las #strong[tomas fuera de campo]. Su técnica se estudia en el #strong[Libro 6 --- Procedimientos operativos], capítulo 5; aquí interesa su cara legal:

- #strong[Permiso del propietario del terreno]: despegar desde un campo externo exige el consentimiento previo de quien tiene la disponibilidad del terreno, además de cumplir las condiciones que fije la normativa nacional para vuelos fuera de aeródromo.
- #strong[Responsabilidad del piloto al mando]: eres responsable de verificar que el terreno es adecuado y la operación segura (dimensiones, obstáculos, personas ajenas). Un campo externo no tiene área de señales, ni servicio de información, ni nadie que haya inspeccionado la superficie por ti.
- #strong[Tras una toma fuera de campo]: la aeronave puede haber causado daños (cultivos, cercados) de los que respondes civilmente; el seguro obligatorio de responsabilidad civil cubre precisamente estos supuestos. Localiza al propietario, documenta el estado del terreno y acuerda la retirada del planeador --- la parte operativa y de trato con el propietario se desarrolla en el Libro 6.

#strong[Resumen del Capítulo: Aeródromos]

En tierra, las reglas visuales mandan:

- #strong[Circuito de tránsito]: virajes a la #strong[izquierda], salvo señal en contrario.
- #strong[Área de señales]: la manga de viento indica dirección e intensidad; la T tumbada, la dirección de aterrizaje y despegue; la flecha derecha avisa de virajes a la derecha; la cruz roja con diagonales amarillas prohíbe aterrizar; el panel rojo con una sola diagonal pide precaución por mal estado del área de maniobras; y la doble cruz blanca anuncia planeadores en actividad.

= Búsqueda y salvamento
<búsqueda-y-salvamento>
#quote(block: true)[
Cuando todo lo demás falla, el Sistema de Búsqueda y Salvamento es tu última línea de defensa; permite que te encuentren.

En este capítulo aprenderás:

- Quién coordina el rescate en España (los RCC).
- Las fases de emergencia: INCERFA (duda), ALERFA (preocupación) y DETRESFA (peligro inminente).
- El código visual de supervivencia (V, X, N, Y) para comunicarte sin radio.
]

== Cuando todo falla: el sistema SAR
<cuando-todo-falla-el-sistema-sar>
El Servicio de Búsqueda y Salvamento (#strong[SAR], #strong[Search and Rescue]) es tu red de seguridad final. En España es responsabilidad del #strong[Ejército del Aire], con apoyo de otros medios, y su misión es simple: encontrarte y salvarte.

=== Organización
<organización>
Quien mueve los hilos es el #strong[RCC] (Centro Coordinador de Salvamento). En España hay tres principales:

+ #strong[RCC Madrid] (Base Aérea de Torrejón): cubre la mayor parte de la península.
+ #strong[RCC Canarias] (Base Aérea de Gando): cubre el archipiélago y una inmensa zona del Atlántico.
+ #strong[RCC Palma] (Base Aérea de Son San Juan): cubre el Mediterráneo y Baleares.

Existen también #strong[RSC] (subcentros) para zonas específicas.

== Las fases de emergencia (repaso SAR)
<las-fases-de-emergencia-repaso-sar>
El SAR no sale a buscar "porque sí". Actúa escalonadamente según la gravedad, en fases que activa el ATC o el propio RCC:

+ #strong[INCERFA (Incertidumbre)]: "¿alguien sabe algo?". Por ejemplo, 30 minutos sin noticias. El RCC empieza a preguntar.
+ #strong[ALERFA (Alerta)]: "algo va mal". Por ejemplo, un fallo de comunicaciones confirmado. Se preparan los equipos SAR.
+ #strong[DETRESFA (Socorro)]: peligro grave. Una señal de baliza ELT, un accidente avistado. Despegan los medios: aviones y helicópteros (#ref(<fig-01-cap11-actuacion-accidente>, supplement: [Figura])).

#figure([
#box(image("imagenes/01-cap11-actuacion-accidente.jpg"))
], caption: figure.caption(
position: bottom, 
[
Cadena de supervivencia en caso de accidente
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap11-actuacion-accidente>


== El lenguaje de la supervivencia: señales tierra-aire
<el-lenguaje-de-la-supervivencia-señales-tierra-aire>
Si estás en tierra y te busca un avión, tienes que comunicarte. Sin radio, usa el #strong[Código de Señales Visuales]: hazlas grandes (mínimo 2,5 m) y con contraste, usando telas, piedras o surcos (#ref(<fig-01-cap11-senales-tierra-aire>, supplement: [Figura])).

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Símbolo], [Significado], [Mnemotecnia],),
  table.hline(),
  [#strong[V]], [#strong[Necesito AYUDA] (Require Assistance)], ["V" de "Venid".],
  [#strong[X]], [#strong[Necesito Ayuda MÉDICA] (Require Medical Assistance)], [Una cruz, como en una ambulancia o farmacia.],
  [#strong[N]], [#strong[NO] / Negativo], ["N" de No.],
  [#strong[Y]], [#strong[SÍ] / Afirmativo], ["Y" de Yes.],
  [#strong[→]], [#strong[Procedemos en esta dirección]], [Flecha indicando rumbo.],
)
#figure([
#box(image("imagenes/01-cap11-senales-socorro.jpg"))
], caption: figure.caption(
position: bottom, 
[
Código de señales visuales de socorro
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap11-senales-tierra-aire>


#block[
#callout(
body: 
[
Si volando interceptas una señal de socorro (visual o en 121.5 MHz):

+ #strong[Anota la posición].
+ #strong[No satures la frecuencia] (escucha primero).
+ #strong[Notifica al ATC] o a quien puedas inmediatamente.
+ Si es posible, mantente en la zona hasta ser relevado (sin ponerte en peligro).

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
#strong[Resumen del Capítulo: Búsqueda y Salvamento (SAR)]

Si algo sale mal, el SAR te buscará. Conoce las fases:

- #strong[INCERFA (Incertidumbre)]: la aeronave no establece comunicaciones tras 30 minutos de intentos, llega 30 minutos después de su hora prevista, o hay dudas sobre su seguridad.
- #strong[ALERFA (Alerta)]: hay temor por la seguridad de la aeronave (se sabe que tiene dificultades), no aterriza dentro de los 5 minutos tras su ETA autorizado, o se presume interferencia ilícita (secuestro).
- #strong[DETRESFA (Socorro)]: peligro grave e inminente. Combustible agotado, posible aterrizaje forzoso o necesidad de ayuda inmediata.
- #strong[Señales tierra-aire]: #strong[V] = necesito ayuda; #strong[X] = necesito ayuda médica; #strong[N] = no; #strong[Y] = sí.

= Seguridad
<seguridad>
#quote(block: true)[
La seguridad de la aviación no es solo para grandes aerolíneas; proteger tu aeronave de actos ilícitos es una responsabilidad fundamental del piloto.

En este capítulo aprenderás:

- La diferencia entre evitar accidentes (#strong[safety]) y prevenir actos criminales (#strong[security]).
- Cómo asegurar tu aeronave en tierra y comprobar que nadie la ha manipulado.
- Qué artículos están prohibidos a bordo por riesgo para la seguridad.
]

== Safety vs Security: ¿No es lo mismo?
<safety-vs-security-no-es-lo-mismo>
En español usamos "seguridad" para todo, pero en aviación conviven dos conceptos muy distintos (#ref(<fig-01-cap12-safety-vs-security>, supplement: [Figura])):

+ #strong[Seguridad operacional] (#strong[safety]): prevenir #strong[accidentes] no intencionados. Que no se pare el motor, que no choques, que el mantenimiento esté bien hecho. Es "volar seguro".
+ #strong[Seguridad de la aviación] (#strong[security]): protegerse contra #strong[actos ilícitos] intencionados. Que no te roben el avión, que nadie ponga una bomba, evitar secuestros. Es protección física.

#figure([
#box(image("imagenes/01-cap12-safety-security.jpg"))
], caption: figure.caption(
position: bottom, 
[
Diferencia entre Safety y Security
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap12-safety-vs-security>


== Tu responsabilidad en aviación general
<tu-responsabilidad-en-aviación-general>
Aunque vueles un planeador en un campo pequeño, la #strong[security] también va contigo:

- #strong[Control de acceso]: no dejes tu aeronave abierta o accesible a cualquiera. Si tienes hangar, ciérralo. Si no, asegura la cabina.
- #strong[Inspección pre-vuelo con ojos de security]: además de mirar si hay aceite, mira si alguien ha tocado algo. ¿Hay objetos extraños en la cabina? ¿Signos de forzamiento?
- #strong[Documentación]: lleva siempre tu identificación (DNI, licencia). La Guardia Civil o la autoridad del aeropuerto pueden pedírtela en cualquier momento, en zona de aire o de tierra.

== Mercancías peligrosas (Dangerous Goods)
<mercancías-peligrosas-dangerous-goods>
Son artículos o sustancias que pueden poner en riesgo la salud, la seguridad o la propiedad. La regla general es simple: #strong[prohibido] llevarlas a bordo (#ref(<fig-01-cap12-mercancias-peligrosas>, supplement: [Figura])). Se admiten cantidades razonables de lo necesario para el vuelo o la seguridad (oxígeno medicinal aprobado, baterías de litio de uso personal bajo ciertas condiciones), siempre con precaución extrema.

#figure([
#box(image("imagenes/01-cap12-mercancias-peligrosas.jpg"))
], caption: figure.caption(
position: bottom, 
[
Etiquetado de mercancías peligrosas
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap12-mercancias-peligrosas>


#block[
#callout(
body: 
[
Si ves a alguien merodeando por los hangares, manipulando aviones ajenos o comportándose de forma sospechosa en el aeródromo, #strong[avisa inmediatamente] al responsable del campo o a las fuerzas de seguridad. La seguridad es cosa de todos.

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
#strong[Resumen del Capítulo: Seguridad (Security)]

Ojo a la diferencia en inglés:

- #strong[SAFETY]: seguridad operacional. Que no te accidentes volando.
- #strong[SECURITY]: seguridad física. Que no te roben el avión ni pongan una bomba.
- #strong[Tu deber]: no dejar el avión abierto o accesible a desconocidos, no llevar mercancías peligrosas (salvo excepciones aprobadas) y respetar las zonas restringidas de los aeropuertos.

= Notificación de accidentes
<notificación-de-accidentes>
#quote(block: true)[
Notificar sucesos no busca culpables, sino aprender de los errores para mantener los cielos seguros para todos.

En este capítulo aprenderás:

- Las diferencias legales entre accidente, incidente grave e incidente.
- Cuándo debes reportar un suceso a la CIAIAC y a AESA, y sus plazos: sin demora a la primera, 72 horas a la segunda.
- El principio de "cultura justa": reportar errores honestos sin miedo al castigo.
]

== Definiciones clave (Reglamento UE 996/2010 y 376/2014)
<definiciones-clave-reglamento-ue-9962010-y-3762014>
En aviación no todo es un accidente. Hay matices legales que importan (#ref(<fig-01-cap13-piramide-sucesos>, supplement: [Figura])):

+ #strong[ACCIDENTE]: alguien sufre lesiones mortales o graves; la aeronave sufre daños estructurales importantes o fallos que afectan a su resistencia o capacidad de vuelo; o la aeronave desaparece o queda inaccesible.
+ #strong[INCIDENTE GRAVE]: un suceso con alta probabilidad de haber acabado en accidente. El clásico "casi pasa".
+ #strong[INCIDENTE]: cualquier otro suceso que afecte o pueda afectar a la seguridad, sin llegar a lo anterior.

#figure([
#box(image("imagenes/01-cap13-piramide-sucesos.jpg"))
], caption: figure.caption(
position: bottom, 
[
Pirámide de gravedad de sucesos (Heinrich)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap13-piramide-sucesos>


== El deber de notificar: sistema SNS
<el-deber-de-notificar-sistema-sns>
Para mejorar la seguridad, el Estado necesita datos. No para castigar, sino para prevenir. Por eso conviven dos sistemas:

- #strong[Notificación obligatoria]: todos los accidentes e incidentes graves deben notificarse.
- #strong[Notificación voluntaria]: si te pasa algo que no es obligatorio reportar pero crees que otros pueden aprender de ello, repórtalo igualmente.

=== ¿A quién y cuándo?
<a-quién-y-cuándo>
+ #strong[CIAIAC] (Comisión de Investigación): investiga las causas técnicas, para que no vuelva a pasar.
+ #strong[AESA] (Agencia Estatal de Seguridad Aérea): supervisa el cumplimiento normativo.

Los plazos no son iguales: a la CIAIAC, comunica el accidente o incidente grave #strong[sin demora] (Reglamento (UE) 996/2010, art. 9); a AESA, notifica el suceso lo antes posible y, en todo caso, en un máximo de #strong[72 horas] (Reglamento (UE) 376/2014) (#ref(<fig-01-cap13-flujo-notificacion>, supplement: [Figura])).

#block[
#callout(
body: 
[
La normativa europea promueve la "Cultura Justa". El objetivo de notificar #strong[NO es buscar culpables] (salvo negligencia grave o dolo), sino #strong[aprender]. No tengas miedo a reportar tus errores; es la única forma de que el sistema mejore.

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
#box(image("imagenes/01-cap13-flujo-notificacion.jpg"))
], caption: figure.caption(
position: bottom, 
[
Proceso de notificación de un suceso
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap13-flujo-notificacion>


#block[
#callout(
body: 
[
Si sufres o presencias un accidente:

+ Prioridad: #strong[Salvar vidas] y evitar más peligros (fuego, etc.).
+ Después: #strong[NO TOQUES NADA]. Preservar los restos es vital para la investigación de la CIAIAC. Solo muévelos si es imprescindible para sacar a víctimas o evitar un incendio.

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
#strong[Resumen del Capítulo: Accidentes e Incidentes]

- #strong[Accidente]: hay lesiones mortales o graves, daños estructurales al avión, o la aeronave desaparece o queda inaccesible.
- #strong[Incidente grave]: las circunstancias indican que hubo alta probabilidad de accidente, o el suceso puso (o pudo poner) en peligro la seguridad de la operación.
- #strong[Obligación]: comunicarlo #strong[sin demora] a la #strong[CIAIAC]\; notificar el suceso a #strong[AESA] en un plazo máximo de #strong[72 horas].
- #strong[Pruebas]: no toques nada, salvo para salvar vidas o evitar otro peligro. Preservar los restos es vital para la investigación.

= Derecho nacional
<derecho-nacional>
#quote(block: true)[
Más allá de las normas europeas, la legislación nacional rige nuestra actividad; conocer la Ley de Seguridad Aérea evita costosas sorpresas legales.

En este capítulo aprenderás:

- El papel de la Ley de Seguridad Aérea (LSA 21/2003) en España.
- Quién es quién entre la DGAC y AESA: una define la política, la otra vigila su cumplimiento.
- El régimen sancionador: infracciones leves, graves y muy graves, y sus consecuencias.
]

== La legislación española: el marco nacional
<la-legislación-española-el-marco-nacional>
Además de la normativa europea (EASA/SERA), en España existe legislación propia que complementa y desarrolla el marco comunitario. La ley principal es la #strong[Ley 21/2003, de 7 de julio, de Seguridad Aérea (LSA)].

== La Dirección General de Aviación Civil (DGAC)
<la-dirección-general-de-aviación-civil-dgac>
La #strong[Dirección General de Aviación Civil (DGAC)] es el órgano directivo del Ministerio de Transportes y Movilidad Sostenible encargado de diseñar la estrategia y dirigir la política aeronáutica.

Mientras AESA supervisa y sanciona, la DGAC juega en el terreno político y normativo: diseña la estrategia del sector aéreo, elabora y propone la normativa nacional, representa a España en organismos como la OACI y coordina a los distintos organismos del sector.

#block[
#callout(
body: 
[
Podríamos decir que la #strong[DGAC] escribe las "reglas del juego" (política y estrategia) y #strong[AESA] es el "árbitro" que asegura que se cumplan en el día a día (supervisión y sanción).

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
== AESA: el policía del aire español
<aesa-el-policía-del-aire-español>
La #strong[Agencia Estatal de Seguridad Aérea (AESA)], creada por Real Decreto 184/2008, vela por el cumplimiento de la normativa de aviación civil en España. Vigila que operadores, pilotos, talleres de mantenimiento y aeródromos cumplan las normas; regula el transporte aéreo, la navegación aérea y la seguridad aeroportuaria; analiza los riesgos para la seguridad del transporte aéreo; y tiene potestad para imponer #strong[sanciones] cuando se infringen las normas.

== Infracciones y sanciones
<infracciones-y-sanciones>
La LSA clasifica las infracciones por gravedad (#ref(<fig-01-cap14-infracciones>, supplement: [Figura])):

=== Infracciones leves
<infracciones-leves>
- Retrasos no justificados en la presentación de documentación.
- Incumplimientos menores de trámites administrativos que no afecten a la seguridad.
- Incumplimientos menores de documentación.

=== Infracciones graves
<infracciones-graves>
- Volar sin licencia válida para el tipo de aeronave.
- Incumplir las reglas del aire sin causar riesgo grave.
- No llevar la documentación obligatoria a bordo.

=== Infracciones muy graves
<infracciones-muy-graves>
- Volar bajo los efectos del #strong[alcohol o drogas].
- #strong[Negligencia grave] que cause un accidente o la muerte de una persona.
- Operar una aeronave sin #strong[Certificado de Aeronavegabilidad] válido.
- #strong[Falsificar] títulos, licencias o documentación aeronáutica.

#figure([
#box(image("imagenes/01-cap14-escala-infracciones.jpg"))
], caption: figure.caption(
position: bottom, 
[
Escala de infracciones aeronáuticas
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap14-infracciones>


#block[
#callout(
body: 
[
Las sanciones económicas pueden ser #strong[muy elevadas], incluso para pilotos privados. Volar sin licencia, sin seguro, o bajo los efectos del alcohol puede costarte miles de euros y la inhabilitación para volar. El desconocimiento de la ley #strong[NO] te exime de su cumplimiento.

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
Ante cualquier duda sobre la legalidad de una operación (ej: volar cerca de un aeropuerto controlado, llevar pasajeros sin recencia), #strong[pregunta antes a tu club, instructor o a AESA]. Es mejor preguntar que enfrentarse a un expediente sancionador.

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
#strong[Resumen del Capítulo: Derecho Nacional]

Además de Europa, en España manda la #strong[Ley de Seguridad Aérea (LSA 21/2003)].

- Establece el régimen de infracciones y sanciones: las #strong[muy graves] (muerte o accidente) pueden acarrear la inhabilitación.
- #strong[DGAC]: define la política aeronáutica (las "reglas del juego").
- #strong[AESA]: vigila y sanciona (el "árbitro").

#show: appendices.with("Apéndices", hide-parent: true)
#heading(level: 1, numbering: none)[Apéndices]
= Syllabus Oficial EASA - Derecho Aéreo
<syllabus-oficial-easa---derecho-aéreo>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (ATC)] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- 1.1. Derecho internacional: convenios, acuerdos y organizaciones.
- 1.2. Aeronavegabilidad (Airworthiness) de aeronaves.
- 1.3. Marcas de nacionalidad y matrícula de aeronaves.
- 1.4. Licencias de personal.
- 1.5. Reglas del aire.
- 1.6. Procedimientos para navegación aérea: operaciones de aeronaves.
- 1.7. Reglamentación de tránsito aéreo: estructura del espacio aéreo.
- 1.8. Servicio de Tránsito Aéreo (ATS) y Gestión del Tránsito Aéreo (ATM).
- 1.9. Servicios de Información Aeronáutica (AIS).
- 1.10. Aeródromos y campos de despegue externos.
- 1.11. Búsqueda y salvamento (Search and Rescue).
- 1.12. Seguridad (Security).
- 1.13. Notificación de accidentes.
- 1.14. Derecho nacional.

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

== Ponte a prueba
<ponte-a-prueba>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/01-derecho-aereo-atc/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

= Glosario de términos
<glosario-de-términos>
Este glosario contiene las definiciones y acrónimos más relevantes del marco normativo aeronáutico (EASA, OACI, normativa nacional) aplicables a la licencia de piloto de planeador (SPL).

/ \*\*\*\*ACC (Centro de Control de Área / Area Control Centre)\*\*\*\*: #block[
Dependencia ATS que presta el servicio de control a los vuelos en ruta dentro de un área de control (CTA), en las fases altas del vuelo. Es la más elevada de las tres dependencias de control, por encima de la aproximación (APP) y la torre (TWR). (Mencionado en: cap. 8)
]

/ \*\*\*\*AESA (Agencia Estatal de Seguridad Aérea)\*\*\*\*: #block[
Autoridad de aviación civil en España, encargada de supervisar y aplicar la normativa aeronáutica nacional, trabajando junto con EASA y emitiendo las licencias de vuelo para pilotos (SPL), así como supervisando la expedición de certificados médicos por parte de centros y médicos examinadores autorizados. (Mencionado en: cap. 1, cap. 2, cap. 3, cap. 13, cap. 14)
]

/ \*\*\*\*AIP (Publicación de Información Aeronáutica)\*\*\*\*: #block[
Manual básico que contiene información aeronáutica de carácter duradero y esencial para la navegación aérea, estructurado en Generalidades (GEN), En Ruta (ENR) y Aeródromos (AD). (Mencionado en: cap. 9)
]

/ \*\*\*\*APP (Control de Aproximación / Approach Control)\*\*\*\*: #block[
Dependencia ATS que controla las aeronaves en las fases de salida y llegada, en la zona intermedia entre el aeródromo (TWR) y la ruta (ACC). (Mencionado en: cap. 8)
]

/ \*\*\*\*ARC (Certificado de Revisión de la Aeronavegabilidad / Airworthiness Review Certificate)\*\*\*\*: #block[
Certificado de validez anual que confirma que la aeronave y sus registros han superado la revisión de aeronavegabilidad reglamentaria, acreditando que es segura para volar. (Mencionado en: cap. 2)
]

/ \*\*\*\*ATS (Servicios de Tránsito Aéreo / Air Traffic Services)\*\*\*\*: #block[
Término genérico que engloba el control de tránsito aéreo (ATC), el servicio de información de vuelo (FIS) y el servicio de alerta. (Mencionado en: cap. 8, 11)
]

/ \*\*\*\*ATC (Control de Tránsito Aéreo / Air Traffic Control)\*\*\*\*: #block[
Servicio de tránsito aéreo responsable de dirigir el tráfico de aeronaves para prevenir colisiones entre aeronaves y entre estas y los obstáculos en el área de maniobras, así como de organizar y agilizar el flujo del tránsito aéreo. (Mencionado en: cap. 8, cap. 11)
]

/ \*\*\*\*ATZ (Aerodrome Traffic Zone)\*\*\*\*: #block[
Zona de Tránsito de Aeródromo. Espacio aéreo de dimensiones definidas establecido alrededor de un aeródromo para la protección del tránsito del aeródromo.
]

/ \*\*\*\*AWY (Airway)\*\*\*\*: #block[
Aerovía. Área de control o porción de la misma dispuesta en forma de corredor.
]

/ \*\*\*\*CAA (Civil Aviation Authority)\*\*\*\*: #block[
Autoridad o Administración de Aviación Civil. En España, las funciones recaen en la DGAC (políticas) y AESA (supervisión e inspección).
]

/ \*\*\*\*CAMO (Continuing Airworthiness Management Organisation)\*\*\*\*: #block[
Organización de Gestión del Mantenimiento de la Aeronavegabilidad Continuada. Entidad responsable de planificar y controlar el mantenimiento de las aeronaves. (Mencionado en: cap. 2)
]

/ \*\*\*\*CAO (Combined Airworthiness Organisation)\*\*\*\*: #block[
Organización Combinada de Aeronavegabilidad. Regulada por la Part-CAO, es una entidad con privilegios para el mantenimiento y gestión de aeronavegabilidad de aeronaves no complejas (como planeadores), simplificando y sustituyendo a las antiguas CAMO. (Mencionado en: cap. 2)
]

/ \*\*\*\*CAVOK (Ceiling And Visibility OK)\*\*\*\*: #block[
Término meteorológico aeronáutico que indica condiciones VFR óptimas: visibilidad horizontal de 10 km o más, ausencia de nubes por debajo de 5.000 ft (o la altitud mínima de sector, la mayor de ambas), ausencia de cumulonimbos (CB) o cúmulos en torre (TCU), y ausencia de fenómenos significativos.
]

/ \*\*\*\*CIAIAC (Comisión de Investigación de Accidentes e Incidentes de Aviación Civil)\*\*\*\*: #block[
Organismo oficial español encargado de investigar las causas de accidentes e incidentes de aviación civil para emitir recomendaciones que prevengan futuros percances. (Mencionado en: cap. 13)
]

/ \*\*\*\*CPL (Commercial Pilot Licence)\*\*\*\*: #block[
Licencia de Piloto Comercial para aviones o helicópteros (Part-FCL). En el mundo del planeador, los privilegios comerciales se integran en la propia SPL --- no existe una CPL(S) independiente.
]

/ \*\*\*\*CTA (Control Area)\*\*\*\*: #block[
Área de Control. Espacio aéreo controlado que se extiende hacia arriba desde un límite especificado sobre el terreno (nunca inferior a 200 metros / 700 pies). #emph[Nota: Aunque coloquialmente se suele expandir como "Controlled Traffic Area", la denominación oficial OACI (Doc 8400) es #strong[Control Area].]
]

/ \*\*\*\*CTR (Zona de control / Control Zone)\*\*\*\*: #block[
Espacio aéreo controlado que se extiende hacia arriba desde la superficie terrestre hasta un límite superior definido, establecido para proteger las trayectorias de las aeronaves en despegue y aterrizaje.
]

/ \*\*\*\*Certificado de Aeronavegabilidad\*\*\*\*: #block[
Documento técnico que identifica una aeronave, define sus características y expresa su calificación para ser utilizada, emitido por la autoridad correspondiente tras comprobar que cumple el diseño aprobado y es segura para operar. (Mencionado en: cap. 2, cap. 14)
]

/ \*\*\*\*DGAC (Dirección General de Aviación Civil)\*\*\*\*: #block[
Órgano directivo del Ministerio de Transportes encargado de establecer las políticas y normativas de aviación civil en España. (Mencionado en: cap. 14)
]

/ \*\*\*\*DME (Distance Measuring Equipment)\*\*\*\*: #block[
Equipo Radiotelemétrico. Sistema de navegación por radio que permite a la aeronave determinar la distancia oblicua a una radiobaliza terrestre.
]

/ \*\*\*\*EASA (Agencia de la Unión Europea para la Seguridad Aérea / European Union Aviation Safety Agency)\*\*\*\*: #block[
Agencia de la Unión Europea responsable de establecer el marco normativo común para regular y supervisar la seguridad de la aviación civil, incluyendo requisitos médicos (Part-MED) y licencias (SFCL). (Mencionado en: cap. 1, cap. 6, cap. 14)
]

/ \*\*\*\*EET (Estimated Elapsed Time)\*\*\*\*: #block[
Duración Prevista de un vuelo, desde el despegue hasta llegar sobre un punto de notificación, destino o límite del espacio aéreo controlado.
]

/ \*\*\*\*EOBT (Hora estimada fuera de calzos / Estimated Off-Block Time)\*\*\*\*: #block[
Hora prevista en que la aeronave inicia el movimiento para la salida (rodaje o remolque), constituyendo la referencia para calcular los plazos de presentación de los planes de vuelo.
]

/ \*\*\*\*ETA (Estimated Time of Arrival)\*\*\*\*: #block[
Hora Prevista de Llegada. En vuelos VFR, es la hora a la que se prevé que la aeronave llegue sobre el aeródromo.
]

/ \*\*\*\*ETD (Estimated Time of Departure)\*\*\*\*: #block[
Hora Prevista de Salida. La hora a la que se estima que la aeronave iniciará el despegue.
]

/ \*\*\*\*FCL (Flight Crew Licensing / Licencias de la Tripulación de Vuelo)\*\*\*\*: #block[
Normativa europea referente a las Licencias de Tripulación de Vuelo (parte del Reglamento (UE) No 1178/2011).
]

/ \*\*\*\*FIC (Flight Information Centre)\*\*\*\*: #block[
Centro de Información de Vuelo. Dependencia establecida para prestar servicio de información de vuelo y servicio de alerta.
]

/ \*\*\*\*FIS (Servicio de Información de Vuelo / Flight Information Service)\*\*\*\*: #block[
Servicio cuya finalidad es facilitar asesoramiento e información útiles para la realización segura y eficaz de los vuelos, sin proporcionar instrucciones de control ni separación obligatoria. (Mencionado en: cap. 7, cap. 8)
]

/ \*\*\*\*FIR (Flight Information Region)\*\*\*\*: #block[
Región de Información de Vuelo. Espacio aéreo de dimensiones definidas, dentro del cual se facilitan los servicios de información de vuelo y alerta.
]

/ \*\*\*\*HJ (Hora de Sol)\*\*\*\*: #block[
Indica el período comprendido desde el orto hasta el ocaso, durante el cual están permitidos (con carácter general) los vuelos VFR de planeadores si no existe habilitación de vuelo nocturno.
]

/ \*\*\*\*LAPL (Light Aircraft Pilot License)\*\*\*\*: #block[
Licencia de Piloto de Aeronave Ligera. Licencia europea pensada para la aviación general no comercial, con requisitos médicos y de formación menos estrictos que las licencias completas. (Mencionado en: cap. 4)
]

/ \*\*\*\*OACI (Organización de Aviación Civil Internacional / ICAO)\*\*\*\*: #block[
Agencia especializada de las Naciones Unidas creada en 1944 para establecer las normas y métodos recomendados (SARPS) que garanticen la seguridad, protección, regularidad y eficiencia de la aviación civil global. (Mencionado en: cap. 1, cap. 3, cap. 7, cap. 14)
]

/ \*\*\*\*PIC (Piloto al mando / Pilot in Command)\*\*\*\*: #block[
Piloto responsable directo del funcionamiento, operación y seguridad de la aeronave durante el tiempo de vuelo. (Mencionado en: cap. 4)
]

/ \*\*\*\*PPL (Private Pilot License)\*\*\*\*: #block[
Licencia de Piloto Privado.
]

/ \*\*\*\*SPIC (Student Pilot-in-Command / Alumno piloto al mando)\*\*\*\*: #block[
Alumno piloto que actúa como piloto al mando en un vuelo con un instructor a bordo, quien únicamente observa y no interviene ni influye en el control de la aeronave.
]

/ \*\*\*\*SPL (Licencia de Piloto de Planeador / Sailplane Pilot Licence)\*\*\*\*: #block[
Licencia oficial de la Unión Europea (regida por Part-SFCL) que certifica que el titular cumple con los requisitos teóricos y prácticos para actuar como piloto de planeadores. (Mencionado en: cap. 1, cap. 2, cap. 4)
]

/ \*\*\*\*TMA (Terminal Manoeuvring Area)\*\*\*\*: #block[
Área de Maniobras Terminales. Área de control establecida generalmente en la confluencia de rutas ATS (aerovías) en las inmediaciones de uno o más aeródromos principales, con altura mínima habitualmente de 1000 pies o más. (Mencionado en: cap. 7)
]

/ \*\*\*\*TMG (Motovelero de turismo / Touring Motor Glider)\*\*\*\*: #block[
Planeador propulsado equipado estructuralmente con motor y hélice no retráctil que le permiten el despegue autónomo y el crucero, compartiendo características con aviones ligeros. (Mencionado en: cap. 1, cap. 4)
]

/ \*\*\*\*TR (Type Rating / Habilitación de Tipo)\*\*\*\*: #block[
Habilitación de Tipo. Anotación en la licencia que certifica la capacitación del piloto para operar un tipo o variante específica de aeronave. No aplicable a planeadores ni motoveleros (TMG) ---que se rigen por habilitaciones de clase o atribuciones---, pero sí a aeronaves complejas.
]

/ \*\*\*\*RMZ (Zona de radio obligatoria / Radio Mandatory Zone)\*\*\*\*: #block[
Espacio aéreo de dimensiones definidas en el que el equipo de radio y su uso son obligatorios: exige mantener escucha permanente en la frecuencia establecida y comunicar intenciones antes de entrar. (Mencionado en: cap. 7)
]

/ \*\*\*\*TMZ (Zona de transpondedor obligatorio / Transponder Mandatory Zone)\*\*\*\*: #block[
Espacio aéreo de dimensiones definidas en el que es obligatorio portar y operar un transpondedor con transmisión de altitud (Modo C o S). (Mencionado en: cap. 7)
]

/ \*\*\*\*TWR (Torre de Control / Aerodrome Control Tower)\*\*\*\*: #block[
Dependencia ATS que controla el tránsito en el aeródromo y su circuito: rodaje, alineamiento, despegues y aterrizajes. Es la más baja de las tres dependencias de control, por debajo de la aproximación (APP) y el centro de control de área (ACC). (Mencionado en: cap. 8)
]

/ \*\*\*\*VFR (Reglas de vuelo visual / Visual Flight Rules)\*\*\*\*: #block[
Conjunto de normas que rigen los vuelos operados con referencia visual constante al terreno, recayendo la responsabilidad de la separación en el principio de "ver y evitar" bajo mínimos meteorológicos visuales (VMC). (Mencionado en: cap. 5, cap. 6)
]

/ \*\*\*\*Zona peligrosa ( D )\*\*\*\*: #block[
Área del espacio aéreo de dimensiones definidas (D de Danger) en la que pueden existir o desarrollarse actividades peligrosas para el vuelo en momentos específicos. (Mencionado en: cap. 7)
]

/ \*\*\*\*Zona prohibida ( P )\*\*\*\*: #block[
Área del espacio aéreo de dimensiones definidas (P de Prohibited) sobre territorio terrestre o aguas jurisdiccionales, cuyo vuelo está totalmente vedado. (Mencionado en: cap. 7)
]

/ \*\*\*\*Zona restringida ( R )\*\*\*\*: #block[
Área del espacio aéreo (R de Restricted) en la que el vuelo de aeronaves está sometido a condiciones restrictivas especificadas. (Mencionado en: cap. 7)
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
