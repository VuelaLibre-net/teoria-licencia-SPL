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
#import "@preview/orange-book:0.7.1": book, part, chapter, appendices

#show: book.with(
  title: [Procedimientos Operativos],
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

#heading(level: 1, numbering: none)[Procedimientos Operativos]
<procedimientos-operativos>
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
#strong[#emph[Tema 6 de 9 del examen teórico para la Licencia de Piloto de Planeador (SPL)]]

Hay vuelos que salen exactamente como estaban planificados. Y hay vuelos que no.

Para los segundos ---un lanzamiento que no progresa, un campo fuera más corto de lo que parecía, un tren de aterrizaje que no baja--- la técnica de pilotaje no es suficiente. Lo que salva el vuelo es tener el procedimiento correcto ejecutado en el tiempo correcto.

Ocho capítulos cubren desde la documentación previa al vuelo hasta el paracaídas de emergencia, pasando por todos los métodos de lanzamiento, las técnicas de planeo y los escenarios que el piloto competente llega preparado para gestionar.

La técnica te lleva al aire. Los procedimientos te traen de vuelta.

= Requisitos generales
<requisitos-generales>
#quote(block: true)[
Antes de despegar, el piloto de planeador debe cumplir con un conjunto de requisitos legales y de seguridad que no son mera burocracia: son la primera línea de defensa frente al accidente. Conocer exactamente qué documentos deben ir a bordo, cuáles son las responsabilidades del Piloto al Mando y cuándo tienes derecho a llevar pasajeros te protege a ti, a los demás y a tu licencia.

En este capítulo aprenderás:

- #strong[La documentación obligatoria]: qué debe ir en la cabina y qué puede quedarse en el aeródromo.
- #strong[Los documentos de la aeronave (SAO.GEN.155)]: qué debe estar en regla antes de cada vuelo.
- #strong[Las responsabilidades del PIC]: desde la inspección prevuelo hasta la decisión final de no volar.
- #strong[El chequeo IMSAFE]: la herramienta de autoevaluación que puede salvarte la vida.
- #strong[Los requisitos para llevar pasajeros]: experiencia, recencia y verificación.
]

== Documentación obligatoria
<documentación-obligatoria>
Para operar un planeador de forma legal y segura, es imprescindible que tanto la aeronave como el piloto estén en regla antes de salir a pista. Dos reglamentos se reparten la tarea: #strong[Part-SFCL] (SFCL.045) fija los documentos del piloto, y #strong[Part-SAO] (SAO.GEN.155) los de la aeronave. Ambos permiten dejar los documentos en el aeródromo cuando el vuelo se mantiene a la vista del campo o dentro de una zona determinada por la autoridad competente.

No confundas «que no pase nada» con «que esté bien». Volar sin la documentación correcta convierte cualquier incidente menor en un problema legal de primera magnitud.

=== Documentos que deben ir a bordo
<documentos-que-deben-ir-a-bordo>
Salvo que vueles a la vista del aeródromo o en una zona autorizada por la autoridad, los siguientes documentos deben acompañarte en la cabina:

- #strong[Licencia del piloto (SPL (Sailplane Pilot Licence)):] original y en vigor. Una fotocopia no tiene validez legal.
- #strong[Certificado médico:] clase 1, 2 o LAPL según corresponda, siempre en vigor.
- #strong[Documento de identificación:] DNI, pasaporte o documento oficial con fotografía.
- #strong[Manual de vuelo (AFM):] el manual específico del modelo de planeador que operas.
- #strong[Cartas aeronáuticas:] actualizadas y adecuadas para la ruta prevista.
- #strong[Libro de vuelo (]logbook#strong[):] datos suficientes ---o el propio libro--- para demostrar que cumples los requisitos de la normativa, la experiencia reciente incluida.
- #strong[Señales de interceptación:] una copia de los procedimientos y señales visuales internacionales de interceptación (SERA.11015; las señales y la respuesta correcta se estudian en el Libro 4, #emph[Comunicaciones], capítulo 8).

El resto de los papeles de la aeronave ---certificado de matrícula, certificado de aeronavegabilidad con sus anexos, ARC, licencia de radio si lleva equipo, certificado del seguro y diario de a bordo--- no necesitan volar contigo: SAO.GEN.155 exige que estén disponibles en el aeródromo o lugar de operación.

#block[
#callout(
body: 
[
✦ #strong[REGLA DE ORO]

Antes de cada vuelo, verifica los cuatro pilares documentales de la aeronave según #strong[SAO.GEN.155]: #strong[aeronavegabilidad] (certificado de aeronavegabilidad + ARC en vigor), #strong[matrícula] (certificado de matrícula visible), #strong[manual de vuelo] (AFM a bordo) y #strong[pesada y centrado] (dentro de los límites del manual). Si alguno falla, el planeador no vuela.

]
, 
title: 
[
Tip
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
== Responsabilidad del Piloto al Mando (PIC)
<responsabilidad-del-piloto-al-mando-pic>
El #strong[Piloto al Mando] (PIC) es la máxima autoridad a bordo y el responsable final de la seguridad de la operación, desde el momento en que firma la autorización de vuelo hasta que el planeador queda correctamente asegurado en tierra. Esta responsabilidad no se comparte, no se delega y no tiene excepciones.

Eso significa que, aunque el mecánico del club haya revisado el planeador, aunque el instructor te haya autorizado el vuelo y aunque el pronóstico del tiempo sea favorable, #strong[la decisión final es siempre tuya]. Si algo no te cuadra, la única respuesta correcta es no volar.

Sus funciones principales incluyen:

+ #strong[Inspección prevuelo:] verificar que el planeador ha sido inspeccionado según el AFM y es apto para el vuelo. No firmes la inspección si no la has hecho tú mismo o si hay algo que no entiendes.
+ #strong[Carga y centrado:] asegurarse de que la masa total y la posición del centro de gravedad (CG) están dentro de los límites permitidos. Un CG fuera de rango puede hacer el planeador irrecuperable en pérdida.
+ #strong[Briefing de seguridad:] informar a los pasajeros sobre el uso de cinturones, paracaídas (si procede), salidas de emergencia y comportamiento en cabina.
+ #strong[Aptitud psicofísica:] no volar si se sospecha cualquier incapacidad física o mental, por mínima que sea.

=== El chequeo IMSAFE
<el-chequeo-imsafe>
Antes de subir al cockpit, realiza este auto-examen de honestidad. No es una formalidad: es la primera ---y más importante--- verificación del día.

- #strong[I] (#strong[Illness / Enfermedad]): ¿Sufro alguna enfermedad o síntoma, por leve que sea? Un resfriado puede impedir que se igualen las presiones en el oído medio al ascender.
- #strong[M] (#strong[Medication / Medicación]): ¿He tomado medicamentos que puedan afectar mis reflejos, la visión o el nivel de alerta?
- #strong[S] (#strong[Stress / Estrés]): ¿Estoy bajo una presión personal o profesional excesiva que ocupe parte de mi atención?
- #strong[A] (#strong[Alcohol]): ¿He consumido alcohol en las últimas 8-24 horas? Incluso una copa la noche anterior puede afectar al rendimiento cognitivo.
- #strong[F] (#strong[Fatigue / Fatiga]): ¿He descansado lo suficiente? La fatiga es uno de los factores más frecuentes y más infravalorados en los accidentes.
- #strong[E] (#strong[Emotion / Eating]): ¿Estoy emocionalmente estable? ¿He comido y estoy correctamente hidratado?

Una sola respuesta negativa en cualquiera de estos puntos es razón suficiente para no volar ese día. No existen los vuelos «de desconexión» cuando el piloto no está al cien por cien.

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

Haz el chequeo #strong[IMSAFE] en voz alta o por escrito antes de salir de casa. La dinámica del aeródromo ---el entusiasmo del grupo, el buen tiempo, la presión social--- puede llevar a minimizar síntomas que en casa te parecerían evidentes. Decidir en frío, antes de llegar al campo, es siempre más fácil que decir «no» delante de tus compañeros cuando el remolcador ya está preparado.

]
, 
title: 
[
Nota
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
== Transporte de pasajeros
<transporte-de-pasajeros>
Llevar a una persona en tu planeador es una responsabilidad añadida de considerable peso. No es solo cuestión de técnica: es la seguridad de alguien que ha depositado su confianza en ti y que, probablemente, no sabría qué hacer si tú quedases incapacitado.

Para poder ejercer esta atribución, la normativa #strong[Part-SFCL] exige que el piloto cumpla con requisitos estrictos de experiencia reciente:

- #strong[Licencia:] debes ser titular de la SPL (Sailplane Pilot Licence) ---no alumno piloto en instrucción--- y con todos los privilegios en vigor.
- #strong[Experiencia:] haber realizado al menos #strong[10 horas de vuelo o 30 lanzamientos] como PIC después de la emisión de la licencia.
- #strong[Recencia:] haber realizado al menos #strong[3 lanzamientos como PIC en los últimos 90 días] para poder llevar pasajeros.
- #strong[Verificación:] haber realizado un vuelo de entrenamiento en el que demuestres a un instructor FI(S) la competencia necesaria para el transporte de pasajeros (salvo que seas titular de un certificado FI(S)).

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Como PIC tienes el derecho y el deber de denegar el transporte a cualquier pasajero o equipaje que consideres que puede representar un peligro para la seguridad del vuelo. Esta decisión no admite presiones externas: si el peso del pasajero más el equipo supera los límites de la aeronave, o si el pasajero muestra un comportamiento que puede comprometer tu concentración, la respuesta es un «no» firme y sin negociación.

]
, 
title: 
[
Advertencia
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
⚖ #strong[NORMATIVA]

Según el Reglamento (UE) 2018/1976, el titular de una SPL (Sailplane Pilot Licence) solo transportará pasajeros si cumple dos condiciones: haber completado, tras la emisión de la licencia, al menos 10 horas de vuelo o 30 lanzamientos o despegues y aterrizajes como PIC en planeadores, además de un vuelo de entrenamiento demostrando la competencia a un FI(S) (SFCL.115(a)(2)); y haber realizado, en los 90 días anteriores, al menos 3 lanzamientos como PIC en planeador ---en TMG, 3 despegues y aterrizajes--- (SFCL.160(e)).

]
, 
title: 
[
Importante
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
== Operaciones en tierra y preparación
<operaciones-en-tierra-y-preparación>
La seguridad y la preservación del material de vuelo comienzan mucho antes del despegue, con una meticulosa preparación y manipulación en tierra. Los planeadores, debido a sus grandes envergaduras, estructuras ligeras y superficies de control desmontables, son especialmente vulnerables al viento, las colisiones terrestres y los descuidos en el ensamblaje.

=== Montaje y almacenamiento (#emph[assembly] & #emph[storage])
<montaje-y-almacenamiento-assembly-storage>
El montaje (#emph[rigging]) y desmontaje (#emph[de-rigging]) del planeador son operaciones habituales en el aeródromo que exigen método y concentración:

- #strong[Evita distracciones:] las interrupciones en el proceso de montaje son la causa número uno de pasadores no asegurados o mandos no conectados. Si te interrumpen, detente y vuelve a empezar la lista de comprobación de montaje desde el primer paso.
- #strong[Inventario de herramientas:] utiliza cunas o paneles específicos para colocar los pernos, pasadores y herramientas de montaje. Al terminar, realiza un inventario estricto: un destornillador o pasador olvidado dentro de la estructura de las alas o el fuselaje puede bloquear el movimiento de los mandos en vuelo.
- #strong[Cuidado al encintar uniones:] el uso de cinta adhesiva plástica para sellar las juntas de unión (como las raíces alares o el #emph[turtle deck]) reduce la resistencia y evita turbulencias. Asegúrate de que los extremos de la cinta queden bien pegados y no interfieran con el recorrido libre de alerones o aerofrenos.

=== Comprobación de mandos positiva (#strong[positive control check - PCC])
<comprobación-de-mandos-positiva-positive-control-check---pcc>
Tras cada montaje de la aeronave, es obligatorio y vital realizar una #strong[comprobación de mandos positiva] (#strong[positive control check]):

+ El piloto se sienta en cabina y sujeta firmemente los mandos de vuelo.
+ Un ayudante en tierra sujeta físicamente cada superficie de control (un alerón, el elevador, el timón de dirección y los aerofrenos) y aplica resistencia.
+ El piloto intenta mover la palanca y los pedales. Si el mando se mueve en cabina mientras la superficie exterior está bloqueada por el ayudante, significa que la conexión de las transmisiones no es firme y el planeador #strong[no es aeronavegable].

=== Remolque por carretera (#emph[trailering])
<remolque-por-carretera-trailering>
El transporte del planeador en su remolque exige que las piezas encajen de forma precisa y firme:

- #strong[Evita rozaduras (]chafing#strong[):] los planos y el fuselaje deben apoyarse en cunas acolchadas y específicas para el modelo, bloqueados firmemente para que las vibraciones en carretera no desgasten la fibra ni las superficies de control.
- #strong[Cierre del carro:] asegura los cierres del carro y comprueba que las luces de señalización y los frenos del remolque funcionan correctamente antes de salir a la carretera.

=== Anclaje y aseguramiento (#emph[tiedown & securing])
<anclaje-y-aseguramiento-tiedown-securing>
Cuando el planeador se deja estacionado y desatendido en el aeródromo, debe protegerse contra ráfagas de viento y el rebufo de aviones motorizados (#strong[propeller blast]):

- #strong[Cúpula cerrada:] mantén siempre la cúpula cerrada y bloqueada. Un golpe de viento o la turbulencia de otra aeronave puede arrancarla de cuajo.
- #strong[Posición de cara al viento:] estaciona el planeador con el morro apuntando directamente al viento dominante siempre que sea posible.
- #strong[Puntos de amarre:] utiliza cuerdas, cadenas o cinchas tensadas desde los extremos alares y el fuselaje hasta anclajes de tierra estables. Si se prevén vientos fuertes, coloca un soporte acolchado bajo la cola para reducir el ángulo de ataque de las alas y evitar que estas generen sustentación.
- #strong[Bloqueadores y fundas:] instala bloqueadores de mandos (#strong[gust locks]) externos para evitar que el viento golpee las superficies de control contra sus topes. Coloca fundas protectoras en la cúpula contra los rayos UV y en los puertos de pitot y energía total para evitar la entrada de insectos y suciedad.

=== Traslado en tierra (#emph[ground handling])
<traslado-en-tierra-ground-handling>
El movimiento del planeador sobre el terreno requiere de un protocolo de equipo claro:

- #strong[Briefing y señales:] todo el personal que ayude a mover la aeronave debe conocer las órdenes y señales.
- #strong[Remolque con vehículo:] al remolcar el planeador con un coche en el aeródromo, #strong[la longitud de la cuerda de remolque debe superar la mitad de la envergadura del velero]. Si una punta de ala se detiene por un obstáculo o si el #strong[wing walker] suelta el ala, esta longitud evita que el planeador pivote bruscamente y golpee el vehículo tractor con el ala opuesta.
- #strong[Velocidad de traslado:] nunca superes la velocidad de una caminata rápida. Utiliza siempre al menos un #strong[wing walker] para guiar el ala y vigilar los obstáculos.

=== Inspección prevuelo detallada (#strong[preflight walk-around check])
<inspección-prevuelo-detallada-preflight-walk-around-check>
Antes del primer despegue del día, el piloto al mando debe realizar una inspección de 360 grados alrededor de la aeronave siguiendo un orden lógico y utilizando la lista de comprobación oficial de su AFM (#ref(<fig-06-cap01-inspeccion-prevuelo>, supplement: [Figura])):

#figure([
#box(image("imagenes/06-cap01-prevuelo.jpg"))
], caption: figure.caption(
position: bottom, 
[
Inspección prevuelo detallada en sentido horario
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap01-inspeccion-prevuelo>


+ #strong[Cabina y morro:] cúpula limpia y sin grietas. Mandos libres, cinturones en buen estado, batería cargada y fijada. Tomas de pitot y estática libres de obstrucciones.
+ #strong[Ala izquierda:] borde de ataque limpio. Holguras y conexiones de los alerones y flaps. Estado y blocaje de los aerofrenos. Patín o rueda de punta de ala.
+ #strong[Fuselaje izquierdo:] ausencia de grietas en la estructura de fibra. Estado de las antenas.
+ #strong[Cola (]empennage#strong[):] fijación del estabilizador horizontal y vertical. Libre movimiento y holguras del timón de dirección y profundidad. Estado de las tomas de estática de cola y la sonda de energía total (TE).
+ #strong[Fuselaje derecho:] inspección simétrica al lado izquierdo.
+ #strong[Ala derecha:] inspección simétrica al ala izquierda.
+ #strong[Tren de aterrizaje y ganchos:] presión y estado del neumático principal y de cola. Funcionamiento del freno de rueda. Comprobación de que el gancho de morro y el gancho de CG están limpios y operan libremente.

=== Lista de comprobación antes del despegue (CB-SIFT-CBE)
<lista-de-comprobación-antes-del-despegue-cb-sift-cbe>
Inmediatamente antes del enganche del cable y del despegue, el piloto debe realizar y verbalizar la lista de comprobación de cabina según su AFM, adaptada al español #strong[CB-SIFT-CBE]:

- #strong[C] (#strong[Controls]): mandos libres y con movimientos correctos (recorrido completo confirmado visualmente).
- #strong[B] (#strong[Ballast]): masa total y posición del centro de gravedad dentro de límites.
- #strong[S] (#strong[Straps]): cinturones y arneses de hombros ajustados y trabados.
- #strong[I] (#strong[Instruments]): altímetro calado en QFE o QNH, variómetro ajustado, radio en frecuencia activa, FLARM encendido y sin alarmas de fallo.
- #strong[F] (#strong[Flaps]): posición de flaps ajustada para despegue si corresponde.
- #strong[T] (#strong[Trim]): compensador de cabeceo ajustado en la posición de despegue.
- #strong[C] (#strong[Canopy]): cúpula cerrada y con cerrojos blocados (comprobación visual y física empujándola ligeramente).
- #strong[B] (#strong[Brakes]): aerofrenos cerrados y firmemente blocados.
- #strong[E] (#strong[Eventualities / Eventualidades]): repaso del viento actual y del briefing de emergencias en el despegue (acciones ante fallo de lanzamiento).

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS: LA REGLA TRADICIONAL CRISE]

En la mayoría de los aeroclubs de habla hispana, especialmente en centros históricos como Ocaña o Fuentemilanos, los instructores han utilizado tradicionalmente la regla mnemotécnica #strong[CRISE] (o #strong[CRIS]):

- #strong[C] (#strong[Mandos / Controles]): palanca libre, pedales ajustados y aerofrenos cerrados y asegurados.
- #strong[R] (#strong[Reglajes / Arneses]): cinturones ajustados, paracaídas colocado y comodidad del piloto en cabina.
- #strong[I] (#strong[Instrumentos]): altímetro a cero (QFE) o calado en QNH, variómetro y vario eléctrico encendidos, y FLARM configurado.
- #strong[S] (#strong[Seguridad exterior]): cúpula cerrada y pestillada, ventanilla cerrada, pista despejada y viento evaluado.
- #strong[E] (#strong[Emergencias]): briefing mental de rotura de cable y planificación inmediata ante un fallo en el despegue.

Ambas mnemotécnicas (la europea CB-SIFT-CBE y la tradicional CRISE) persiguen el mismo fin de seguridad: no conectar el cable del planeador a pista hasta que no se haya realizado una verificación física e instrumental completa en cabina.

]
, 
title: 
[
Nota
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
#strong[Resumen del Capítulo: Requisitos generales]

- #strong[Los papeles del planeador (SAO.GEN.155)]: antes de cada vuelo verifica los cuatro pilares documentales de la aeronave: aeronavegabilidad (certificado + ARC), matrícula, manual de vuelo (AFM) y pesada y centrado. Si falta alguno, el planeador no vuela.
- #strong[Tus papeles]: licencia (SPL (Sailplane Pilot Licence)) en vigor, certificado médico vigente, DNI y datos del libro de vuelo (SFCL.045). Si eres alumno, en las travesías en solitario lleva el médico, el DNI y la prueba de la autorización de tu instructor (SFCL.125).
- #strong[Responsabilidad del PIC]: tú eres la última autoridad. Si el velero no está en condiciones, la meteo es marginal o tú no estás al 100 % (IMSAFE), la decisión de no volar es tuya.
- #strong[IMSAFE]: #strong[Illness, Medication, Stress, Alcohol, Fatigue, Emotion/Eating]. Un solo «sí» es suficiente para quedarte en tierra.
- #strong[Pasajeros]: licencia SPL (Sailplane Pilot Licence) (no alumno), 3 lanzamientos en los últimos 90 días, 10 horas o 30 lanzamientos tras la licencia, y un vuelo de verificación con instructor.
- #strong[Operaciones en tierra]: comprobación de mandos positiva (PCC) tras cada montaje. Anclaje de cara al viento con cúpulas cerradas. Regla de la cuerda larga (más de media envergadura) para remolcar con coche.
- #strong[Prevuelo y CB-SIFT-CBE]: inspección prevuelo sistemática de 360 grados. Checklist de cabina estricto CB-SIFT-CBE antes de conectar el cable de lanzamiento.

= Métodos de lanzamiento
<métodos-de-lanzamiento>
#quote(block: true)[
El lanzamiento es la fase de mayor energía del vuelo de planeador y, junto con el aterrizaje, la de mayor riesgo estadístico. En cuestión de segundos, el piloto pasa de estar parado en tierra a volar a velocidades considerables, dependiendo de un cable o de un avión remolcador. No hay margen para la improvisación: los procedimientos son exactos, la comunicación es precisa y las reacciones de emergencia deben ser instintivas.

En este capítulo aprenderás:

- #strong[El lanzamiento por torno]: dinámica, fraseología y procedimiento de emergencia ante rotura de cable.
- #strong[El remolque por avión (]aerotow#strong[)]: posiciones en remolque, señales visuales y cómo actuar si no puedes soltar.
- #strong[Las reglas generales de seguridad]: ganchos, velocidades y comprobaciones previas al enganche.
]

== El lanzamiento por torno (#emph[winch])
<el-lanzamiento-por-torno-winch>
El #strong[lanzamiento por torno] es el método más rápido y económico para poner un planeador en el aire. Un motor potente situado en el extremo opuesto de la pista enrolla un cable a gran velocidad, arrastrando al planeador desde el reposo hasta velocidades de despegue en apenas tres o cuatro segundos. La sensación es la de una catapulta: la aceleración es tan brusca que los pilotos noveles suelen sorprenderse ante su intensidad.

Durante el ascenso, el ángulo de cabeceo aumenta rápidamente hasta superar los 40-45°. Esta actitud, que en cualquier otra situación sería alarmante, es completamente normal en el torno: el cable tirando desde adelante y abajo impone esa geometría. El planeador sube a razón de 10-15 metros por segundo y alcanza entre 300 y 500 metros en menos de un minuto (#ref(<fig-06-cap02-torno-fases>, supplement: [Figura])). Durante la trepada, la tracción del cable carga el ala y eleva su velocidad de pérdida, así que se vuela más deprisa que en vuelo libre: como referencia, entre 1,3 y 1,6 veces la velocidad mínima de vuelo recto, sin superar nunca la velocidad máxima de torno que fija el AFM.

=== Procedimiento y fraseología
<procedimiento-y-fraseología>
La comunicación entre el piloto y el operador del torno (tornero) es vital. Una orden malentendida puede resultar en una tracción inesperada. La secuencia estándar es:

+ #strong[«Listo para tensar el cable»]: el piloto indica que está preparado. El tornero comienza a recoger cable lentamente, sin tensión brusca.
+ #strong[«Cable en tensión»]: el piloto confirma que el cable está tirando de forma suave y uniforme.
+ #strong[«Remolque, remolque, remolque»]: el piloto autoriza la máxima potencia. El planeador acelera rápidamente: controla el alabeo con los alerones y mantén el eje con los pedales.
+ #strong[«Velero libre»]: tras la suelta del cable ---al final de la trepada, típicamente a 300-400 metros, o de inmediato ante cualquier duda---, el piloto confirma que el cable se ha desenganchado y que vuela libre.

#figure([
#box(image("imagenes/06-cap02-torno-fases.jpg"))
], caption: figure.caption(
position: bottom, 
[
Fases del lanzamiento por torno o vehiculo y actitud del planeador
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap02-torno-fases>


=== Emergencia por rotura de cable
<emergencia-por-rotura-de-cable>
La rotura de cable durante el ascenso es una de las emergencias más exigentes del vuelo de planeador. La reacción debe ser #strong[instintiva e inmediata, sin dudar]. En el momento en que la tensión desaparece, el morro del planeador tiende a subir peligrosamente ---el efecto del cable queda anulado de golpe--- y la velocidad cae con rapidez. Si no se actúa en los dos primeros segundos, la pérdida aerodinámica (#strong[stall]) a baja altura puede ser fatal.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Si el cable se rompe durante el ascenso, la prioridad #strong[absoluta e inmediata] es #strong[bajar el morro] a actitud de planeo para recuperar velocidad y evitar la pérdida. Solo una vez que la velocidad es segura, activa la suelta de emergencia del cable remanente y decide: aterrizar recto en la pista restante (baja altura), realizar un giro de 180° (altura media) o completar un circuito abreviado (altura suficiente). #strong[En lanzamiento por torno, nunca intentes retornar a pista si estás por debajo de 150 metros]: es la maniobra más letal del vuelo sin motor.

]
, 
title: 
[
Advertencia
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
== Remolque por avión (#emph[aerotow])
<remolque-por-avión-aerotow>
En el #strong[remolque por avión], una aeronave motorizada tira del planeador mediante un cable de entre 30 y 60 metros. Este método ofrece una ventaja decisiva sobre el torno: permite elegir con precisión la altura de suelta y el lugar geográfico exacto ---sobre la ladera idónea, la primera térmica del día o el punto de inicio de la tarea prevista---. La penalización es el coste y el consumo de tiempo.

La posición correcta de remolque es fundamental tanto para la seguridad como para la comodidad del piloto del remolcador (#ref(<fig-06-cap02-aerotow-posicion>, supplement: [Figura])):

- #strong[Posición alta]: el planeador vuela justo por encima de la estela del remolcador, usando como referencia visual las ruedas del remolcador apoyadas en el horizonte. Desde esta posición, el planeador queda fuera del rebufo de la hélice y no ejerce fuerza de cabeceo sobre la cola del remolcador.
- #strong[Zona a evitar]: la zona inmediatamente detrás del remolcador y debajo de su estabilizador es extremadamente turbulenta por la estela de hélice. Atravesarla durante un vuelo normal es incómodo; durante una emergencia del remolcador, puede ser peligroso.

=== Señales visuales en vuelo
<señales-visuales-en-vuelo>
Aunque se use la radio, las señales visuales son el estándar internacional de seguridad aeronáutica ante el fallo de las comunicaciones:

- #strong[Balanceo de alas del remolcador:] ¡Suelta el cable inmediatamente! Es una orden de seguridad de obligado cumplimiento: el remolcador tiene una emergencia.
- #strong[Movimiento de timón del remolcador («fishtail»):] algo va mal en tu planeador --- revísalo. Lo más habitual: los aerofrenos se han desplegado sin que te des cuenta.
- #strong[El planeador se sitúa bajo y al lado izquierdo del remolcador y alabea:] el piloto del planeador no puede soltar el cable y solicita que el remolcador le lleve de vuelta al aeródromo.

#figure([
#box(image("imagenes/06-cap02-aerotow-posicion.jpg"))
], caption: figure.caption(
position: bottom, 
[
Posición correcta del planeador en remolque por avión
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap02-aerotow-posicion>


#block[
#callout(
body: 
[
✦ #strong[REGLA DE ORO]

Durante el remolque, mantén siempre el avión remolcador #strong[en tu campo de visión], preferiblemente en «posición alta» (las ruedas del remolcador apoyadas en el horizonte). Si el remolcador desaparece de tu campo de visión, has entrado en posición demasiado alta: el planeador estará levantando la cola del remolcador y puedes empujar su morro hacia el suelo. Ante cualquier duda, suelta el cable: siempre es la decisión más segura.

]
, 
title: 
[
Tip
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
=== La maniobra «Boxing the Wake» (hacer la caja a la estela)
<la-maniobra-boxing-the-wake-hacer-la-caja-a-la-estela>
«Boxing the wake» (rodear la estela) es un ejercicio de entrenamiento avanzado de remolque que demuestra la coordinación y la capacidad del piloto para maniobrar de forma controlada alrededor de la turbulencia del remolcador (#strong[wake turbulence]).

La estela del remolcador consta de dos componentes: el rebufo de la hélice (#strong[propwash]), que genera una turbulencia ligera en el centro, y los vórtices de punta de ala (#strong[wingtip vortices]), que inducen fuertes momentos de alabeo en los bordes.

La maniobra consiste en volar un patrón rectangular ---un cuadro--- alrededor de la estela del remolcador: partiendo de la posición alta estándar, se cruza la estela hacia la posición baja y desde ahí se recorren las cuatro esquinas del rectángulo (baja izquierda, alta izquierda, alta derecha, baja derecha) con mandos coordinados, manteniendo constante la distancia a la estela, para cerrar cruzando de nuevo hacia la posición alta (#ref(<fig-06-cap02-boxing-wake>, supplement: [Figura])). Cada tramo es un ejercicio de control fino: desplazamientos limpios sin recortar las esquinas ni penetrar en los vórtices de punta de ala.

No es materia de examen ni algo que se aprenda de un libro: es un ejercicio de vuelo que se practica #strong[con instructor], que te enseñará el ritmo y los límites en tu tipo de planeador. Empieza siempre fuera del circuito y por encima de una altura de seguridad de referencia de #strong[300 m AGL].

#figure([
#box(image("imagenes/06-cap02-boxing-wake.jpg"))
], caption: figure.caption(
position: bottom, 
[
Maniobra de entrenamiento para rodear la estela (Boxing the Wake)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap02-boxing-wake>


#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Evita realizar un cuadro demasiado estrecho o recortar las esquinas, ya que el planeador penetrará en los vórtices de punta de ala de forma descontrolada. Esto puede provocar un alabeo violento e imprevisto. Si pierdes el control o el remolcador desaparece de tu vista, suelta el cable inmediatamente.

]
, 
title: 
[
Advertencia
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
=== Corrección de cable flojo (#strong[slack line])
<corrección-de-cable-flojo-slack-line>
El aflojamiento del cable de remolque (#strong[cable flojo] o #strong[slack line] o seno en el cable) es un fenómeno común durante el remolque por avión, provocado por ráfagas de viento, térmicas, virajes cerrados por el interior del radio del remolcador o reducciones bruscas de potencia del avión tractor.

El peligro reside en que, cuando el planeador desacelera y el cable se afloja, la cuerda puede enredarse en las alas o en el tren del planeador. Además, al acelerar de nuevo, el cable se tensará de golpe, provocando un tirón violento (#strong[snap]) que puede romper el fusible de seguridad o causar daños estructurales en el planeador o en el remolcador.

Para corregir un cable flojo, aplica la siguiente técnica según su severidad:

- #strong[Seno leve:] si la comba en el cable es pequeña, mantén una trayectoria de vuelo estabilizada directamente detrás del remolcador. El propio planeo del velero reabsorberá el exceso de velocidad de forma natural y suave.
- #strong[Seno moderado:] si el cable está visiblemente combado, #strong[realiza un resbale lateral (]sideslip#strong[) suave] apuntando el morro ligeramente hacia afuera de la trayectoria para aumentar la resistencia aerodinámica, o bien #strong[abre los aerofrenos de forma muy gradual e intermitente]. Esto ralentizará el planeador y estirará el cable con suavidad.
- #strong[Seno crítico:] si el cable forma un bucle grande y pierdes de vista el cable o el avión remolcador, #strong[suelta el cable de inmediato]. Es muy peligroso esperar a que se tense de golpe a gran velocidad.

== El autolanzamiento (#emph[self-launch])
<el-autolanzamiento-self-launch>
El #strong[autolanzamiento] es el método empleado por los planeadores motorizados (#strong[motorgliders]) o planeadores autónomos equipados con motores retráctiles o hélices frontales plegables. Este método proporciona al piloto una independencia absoluta, permitiéndole despegar y ascender sin necesidad de torno ni de avión remolcador.

Sin embargo, la operación con motor introduce una serie de riesgos específicos que deben gestionarse con rigor:

- #strong[La tendencia al encabritado (]pitch-up tendency#strong[):] en la mayoría de los planeadores con motor retráctil, el motor se despliega en un mástil vertical sobre el fuselaje. La fuerza de tracción actúa muy por encima del eje longitudinal de la aeronave: al aplicar potencia genera un potente par de picado, y al reducirla o cortarla en el aire, un encabritado brusco. El piloto debe contrarrestar esta tendencia de forma activa y decidida con el timón de profundidad.
- #strong[Resistencia aerodinámica del motor:] si el motor falla en vuelo o se apaga y queda desplegado sin retraerse, la polar de planeo se degrada de forma drástica (la tasa de descenso puede llegar a duplicarse). Volar con el motor fuera equivale a volar con los aerofrenos parcialmente abiertos.
- #strong[El dilema del arranque a baja altura:] la causa principal de accidentes en planeadores motorizados es el intento del piloto de arrancar el motor en vuelo cuando se encuentra a muy baja altura para evitar un aterrizaje fuera de campo. Si el motor no arranca (debido al enfriamiento por viento, fallos eléctricos o falta de combustible), el piloto se queda sin motor y sin la altitud necesaria para planificar un aterrizaje fuera de campo seguro.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Establece siempre una altura mínima de seguridad para el arranque del motor en vuelo (típicamente #strong[300 metros AGL]). Si desciendes por debajo de esa altura y el motor no arranca al primer intento, desiste inmediatamente, olvídate del motor y concéntrate exclusivamente en realizar un aterrizaje fuera de campo controlado. Muchos accidentes graves ocurren por intentar solucionar fallos del motor a escasos metros del suelo.

]
, 
title: 
[
Advertencia
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
=== Métodos de lanzamiento secundarios
<métodos-de-lanzamiento-secundarios>
Además del torno, el remolque por avión y el autolanzamiento, existen otros dos métodos contemplados en el syllabus, de uso poco común en la actualidad pero con gran relevancia en la historia del vuelo sin motor o en ubicaciones de montaña específicas:

- #strong[Remolque por vehículo (]car launch#strong[):] similar al torno, pero en lugar de un motor fijo enrollando un cable, es un coche o camión el que corre por una pista larga tirando del cable enganchado al planeador. Requiere una coordinación precisa de velocidad entre el conductor del vehículo y el planeador, y pistas extremadamente largas (más de 1.500 metros).
- #strong[Lanzamiento por goma (]bungee launch#strong[):] es el método fundacional del vuelo sin motor. Se utiliza en laderas empinadas y con vientos fuertes de cara. El planeador se sujeta por la cola, mientras un equipo de personas estira una goma elástica gruesa unida al gancho de morro del planeador. Cuando la goma está tensa, se libera el planeador y este sale catapultado directamente hacia la ascendencia dinámica de la ladera.

== Reglas generales de seguridad
<reglas-generales-de-seguridad>
Independientemente del método de lanzamiento, existen reglas de seguridad comunes que deben verificarse antes de cada vuelo:

+ #strong[Ganchos de remolque adecuados:] si el planeador dispone de gancho de morro (para aerotow) y gancho de centro de gravedad (para torno), asegúrate de usar el correcto para cada método. Usar el gancho equivocado puede generar geometrías de tracción peligrosas o impedir la suelta.
+ #strong[Velocidades de remolque (V#sub[T]):] nunca excedas la velocidad máxima de remolque especificada en el AFM. Un remolque demasiado rápido genera oscilaciones que pueden superar los límites estructurales del planeador. Uno demasiado lento pone al remolcador al borde de la pérdida.
+ #strong[Comprobaciones previas al enganche:] antes de enganchar el cable, verifica:

- Aerofrenos cerrados y blocados.
- Compensador en posición de despegue.
- Cabina libre de objetos sueltos y bien cerrada.
- Mandos libres y correctamente conectados (movimiento cruzado confirmado).
- Cinturones ajustados y trabados.

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

Realiza siempre una comprobación de mandos cruzada (#strong[cross-check]) con otro piloto o el jefe de fila antes del lanzamiento. Un mando de alerones o timón no conectado correctamente puede ser imposible de detectar durante la inspección individual. Esta sencilla verificación elimina una de las causas más frecuentes de accidentes en el despegue.

]
, 
title: 
[
Nota
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
=== Inspección del equipo de lanzamiento
<inspección-del-equipo-de-lanzamiento>
Antes de cada jornada de vuelo y en cada inspección prevuelo individual, el piloto y el personal de pista deben verificar el estado de los equipos de remolque y torno:

- #strong[Ganchos de remolque:] comprueba visualmente que las mandíbulas del gancho de morro (para remolque por avión) y de CG (para torno) estén limpias de tierra, óxido o grasa vieja. Acciona la anilla de suelta desde la cabina y verifica que el gancho se abre de forma instantánea y completa, y que el muelle lo retorna a su posición cerrada.
- #strong[Anillas de remolque:] inspecciona las anillas metálicas en los extremos del cable. En Europa, el sistema estándar es el #strong[doble anillo Tost]. Comprueba que las anillas no presenten grietas, abolladuras, soldaduras desgastadas o deformaciones elípticas.
- #strong[Cables y cuerdas de remolque:] revisa la cuerda de nailon o el cable de acero en toda su longitud. Debe estar libre de nudos. #strong[Un solo nudo en la cuerda de remolque reduce su resistencia estructural hasta en un 50 %] y crea un punto de alta fricción propenso a la rotura. Comprueba que no haya filamentos deshilachados y que la cuerda no presente decoloración por exposición prolongada a la radiación UV.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD: INCOMPATIBILIDAD DE ANILLAS]

El sistema de doble anilla Tost es el único homologado para ganchos Tost. El uso accidental de una anilla simple de tipo americano (Schweizer) en un gancho Tost grasping-style puede provocar que el gancho no se libere al accionar el tirador en vuelo, resultando en un arrastre incontrolable. Verifica siempre la compatibilidad del cable antes de enganchar.

]
, 
title: 
[
Advertencia
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
=== Fusibles de seguridad (#strong[weak links])
<fusibles-de-seguridad-weak-links>
El #strong[fusible de seguridad] (#strong[weak link] o eslabón débil) es un dispositivo metálico calibrado que se intercala en el cable de remolque, diseñado para romperse antes de que una tensión excesiva e imprevista en el cable provoque daños estructurales en el planeador o en el avión remolcador.

La obligación operativa del piloto es montar #strong[exactamente el fusible de seguridad especificado en el AFM] de su planeador: ni más resistente, ni más débil. Como referencia de diseño, la norma de certificación #strong[EASA CS 22.581(b)] asume que la resistencia nominal última del cable o fusible no es inferior a 1,3 veces el peso máximo del planeador ni a 500 daN, valores con los que se dimensiona estructuralmente el gancho de remolque.

En los clubes europeos se utiliza el sistema estandarizado de la firma Tost. Es fundamental entender que #strong[la selección del fusible correcto depende obligatoriamente tanto del peso del planeador como del método de lanzamiento]:

- #strong[En remolque por avión (]aerotow#strong[):] las aceleraciones son progresivas y las tensiones del cable son de menor magnitud. Para proteger el gancho de morro de sobretensiones peligrosas para la estabilidad, se emplean fusibles de menor resistencia:
- #strong[Verde (300 daN):] para monoplazas estándar y ligeros.
- #strong[Blanco (500 daN):] para biplazas de instrucción y veleros pesados.
- #strong[En lanzamiento por torno (]winch#strong[):] la aceleración es muy brusca y las tensiones del cable durante el ascenso empinado son muy elevadas debido a la geometría del tiro. Se requieren fusibles de mayor resistencia para evitar roturas prematuras en plena trepada:
- #strong[Blanco (500 daN):] para torno en monoplazas muy ligeros.
- #strong[Azul (600 daN):] para la mayoría de los monoplazas estándar (ej. LS4, Astir, Discus).
- #strong[Rojo (750 daN):] para monoplazas pesados y biplazas de escuela ligeros (ej. K-21 con un tripulante).
- #strong[Marrón (850 daN):] para biplazas de escuela y veleros de alto rendimiento de gran peso.
- #strong[Negro (1000 daN):] para biplazas de alto rendimiento muy pesados (ej. Duo Discus, DG-1000) o veleros motorizados cargados.

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Color], [Resistencia nominal (daN)], [Aplicación típica (según AFM)],),
  table.hline(),
  [#strong[Verde] (No.~7)], [300 daN], [Remolque por avión de monoplazas ligeros/estándar.],
  [#strong[Amarillo] (No.~6)], [400 daN], [Veleros clásicos de madera y tela (ej. Ka-8) en remolque.],
  [#strong[Blanco] (No.~5)], [500 daN], [Remolque por avión de biplazas; lanzamiento por torno de monoplazas ligeros.],
  [#strong[Azul] (No.~4)], [600 daN], [Lanzamiento por torno de monoplazas estándar y de competición.],
  [#strong[Rojo] (No.~3)], [750 daN], [Lanzamiento por torno de biplazas de escuela ligeros / monoplazas pesados.],
  [#strong[Marrón] (No.~2)], [850 daN], [Lanzamiento por torno de biplazas de escuela y veleros de alto rendimiento.],
  [#strong[Negro] (No.~1)], [1000 daN], [Lanzamiento por torno de biplazas pesados cargados o motoveleros.],
)
Los colores, numeración y resistencias nominales corresponden al catálogo de fusibles de seguridad de Tost Flugzeuggerätebau; la aplicación concreta la fija siempre el AFM de cada planeador.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Nunca instales un fusible de seguridad de resistencia superior a la especificada en el AFM de tu planeador, ni realices puenteos en el cable utilizando mosquetones o grilletes sin fusible. En caso de una sobretensión brusca (como una ráfaga o un tirón por cable flojo), la rotura de las alas o del morro del planeador ocurrirá antes de que el cable se rompa. Asimismo, utilizar un fusible excesivamente resistente en remolque por avión puede causar daños graves en el gancho de morro y en la estructura del fuselaje antes de romperse.

]
, 
title: 
[
Advertencia
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
=== El briefing de emergencia en el despegue (#emph[takeoff emergency briefing])
<el-briefing-de-emergencia-en-el-despegue-takeoff-emergency-briefing>
La preparación mental es el factor de seguridad más eficaz contra las emergencias en el despegue. La metodología internacional exige que, inmediatamente antes de cada despegue (justo antes de enganchar el cable o de solicitar tensión), el piloto al mando realice ---y verbalice en voz alta si vuela en biplaza--- el #strong[briefing de emergencia en el despegue] (#strong[takeoff emergency briefing]).

Este briefing estructura la toma de decisiones inmediata en caso de una rotura de cable o fallo de motor según tres franjas de altura preestablecidas:

+ #strong[Velocidades de seguridad:] confirmar la velocidad mínima a mantener ante cualquier fallo: la velocidad de aproximación segura que indica el AFM de tu planeador.
+ #strong[Fallo a baja altura:] definir la altura límite por debajo de la cual el aterrizaje se realizará recto y sin virar, identificando zonas libres de obstáculos fuera de la pista si es necesario.
+ #strong[Fallo a altura crítica y retorno:] definir la altura mínima para intentar un viraje de retorno seguro ---como referencia, 150 metros AGL en lanzamiento por torno y 70 metros AGL en remolque por avión (ver )--- y decidir previamente hacia qué lado se virará, considerando la dirección y fuerza del viento actual para contrarrestar la deriva.

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

No comiences la carrera de despegue sin haber verbalizado o repasado mentalmente tu #strong[emergency briefing]. En caso de rotura de cable a baja altura, no hay tiempo para pensar qué hacer; la acción correcta (bajar el morro, estabilizar la velocidad y la trayectoria) debe estar precargada en la mente y ejecutarse como una respuesta refleja.

]
, 
title: 
[
Nota
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
#strong[Resumen del Capítulo: Métodos de lanzamiento]

- #strong[Torno (]winch#strong[)]: aceleración brutal de 0 a 100 en 3 segundos. Si se rompe el cable, lo primero es #strong[bajar el morro] para recuperar velocidad. Solo entonces suelta el cable remanente y decide si aterrizar recto, hacer 180° o un circuito corto, según la altura disponible.
- #strong[Remolque (]aerotow#strong[)]: mantén la «posición alta» (rueda del remolcador en el horizonte). Si el remolcador alabea sus alas, es una orden de suelta inmediata: tiene una emergencia. Si no puedes soltar, vuela a un lado y alabea. Si se forma un #strong[cable flojo (]slack line#strong[)], corrígelo con un resbale suave o con aerofrenos graduales. Entrena la maniobra #strong[«Boxing the Wake»] a partir de 300 m AGL.
- #strong[Autolanzamiento (]self-launch#strong[)]: ofrece total independencia. Cuidado con el par de cabeceo del motor sobre mástil: aplicar potencia pica el morro y reducirla o cortarla lo #strong[encabrita]. Respeta la altura de seguridad de 300 m para arrancar el motor en vuelo; por debajo, concéntrate en el aterrizaje fuera de campo.
- #strong[Emergency briefing]: briefing mental y verbalizado antes de cada despegue. Define velocidades de seguridad y acciones precisas ante fallos a baja, media y alta altura según el viento.
- #strong[Comprobaciones previas]: ganchos correctos, velocidades respetadas, mandos libres y comprobación cruzada. Realiza la inspección de cuerdas (sin nudos), anillas dobles Tost compatibles y fusibles de seguridad (#strong[weak links]) de resistencia por código de colores (ej. azul = 600 daN para monoplazas en torno).

= Técnicas de planeo
<técnicas-de-planeo>
#quote(block: true)[
El vuelo de planeador es, en esencia, una conversación permanente con la atmósfera. El piloto que aprende a escuchar el aire ---las variaciones del variómetro, el comportamiento del planeador en distintas masas de aire, los indicios sutiles que anuncian una térmica--- desarrolla una capacidad que trasciende la técnica y se convierte en instinto. Esta sección recorre las tres grandes familias de sustentación dinámica: térmica, ladera y onda, junto con la gestión del lastre de agua para condiciones específicas.

En este capítulo aprenderás:

- #strong[Centrado de térmicas]: cómo detectar el núcleo y cómo desplazar el viraje hacia él.
- #strong[El anillo MacCready]: qué es y cómo te dice exactamente a qué velocidad volar entre térmicas.
- #strong[Vuelo de ladera (]ridge soaring#strong[)]: técnica, reglas de tráfico y márgenes de seguridad.
- #strong[Vuelo de onda (]wave soaring#strong[)]: identificación, condiciones ideales y riesgos del rotor.
- #strong[Lastre de agua]: cuándo usarlo, cuándo vaciarlo y qué cambia en la aerodinámica del planeador.
]

== Vuelo en térmicas
<vuelo-en-térmicas>
Las #strong[térmicas] son columnas de aire ascendente generadas por el calentamiento diferencial del suelo. Cuando el sol calienta la superficie ---especialmente sobre terrenos oscuros como campos arados, asfalto o laderas orientadas al sur---, el aire más cálido y ligero asciende en forma de burbuja o columna. Este ascenso es la fuente de energía principal del vuelo de travesía (#strong[cross-country]).

Piénsalo como una olla de agua hirviendo: el calor sube desde el fondo en corrientes irregulares e intermitentes. La térmica aerológica funciona de manera similar: no es un tubo uniforme de aire ascendente, sino una masa de geometría variable, con un núcleo de ascenso máximo rodeado de aire más tranquilo y, en los bordes externos, frecuentemente descendente.

=== El centrado de la térmica
<el-centrado-de-la-térmica>
Detectar una térmica es solo el primer paso. Lo realmente difícil ---y lo que distingue a un buen piloto de uno extraordinario--- es centrarla con eficiencia. La técnica básica es el #strong[desplazamiento del círculo] hacia el núcleo (#ref(<fig-06-cap03-centrado-termica>, supplement: [Figura])):

+ Cuando el vario empiece a subir con fuerza, espera #strong[2-3 segundos] para asegurarte de que estás dentro del núcleo y no en el borde inicial.
+ Inicia un viraje coordinado con un alabeo de entre #strong[30° y 45°]. El planeador tardará entre 15 y 25 segundos en completar cada vuelta.
+ Observa el vario durante el giro: si el ascenso es mayor en un sector del círculo, el núcleo está desplazado hacia ese lado. Ensancha el viraje durante 2-3 segundos en esa dirección ---reduciendo el alabeo momentáneamente--- y vuelve a cerrarlo. Estarás «transportando» el centro del giro hacia el núcleo.

¿Y si entraste girando hacia el lado equivocado y el vario se hunde nada más establecer el viraje? Ahí entra la #strong[técnica de los 270 grados]: recuerda en qué punto del giro tuviste el ascenso máximo, completa 270° de viraje, vuela recto durante 2-4 segundos hacia ese punto y vuelve a virar en el mismo sentido. Es más eficaz que invertir el giro, que consume tiempo, cubre más distancia y suele alejarte del núcleo.

#figure([
#box(image("imagenes/06-cap03-centrado-termica.jpg"))
], caption: figure.caption(
position: bottom, 
[
Técnica de centrado de la térmica: desplazamiento del viraje hacia el núcleo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap03-centrado-termica>


#block[
#callout(
body: 
[
✦ #strong[REGLA DE ORO]

Si al atravesar una térmica un ala sube, el núcleo está de ese lado: #strong[vira hacia el ala que sube]. Una vez establecido el giro, no inviertas nunca el sentido: ajusta. Cierra el viraje cuando el vario sube, ábrelo cuando baja. Con el tiempo, este ajuste se vuelve automático y no necesitas calcularlo conscientemente.

]
, 
title: 
[
Tip
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
=== La velocidad entre térmicas: el anillo MacCready
<la-velocidad-entre-térmicas-el-anillo-maccready>
El anillo MacCready es el selector de velocidades óptimas entre térmicas. Responde a la pregunta: «¿A qué velocidad debo volar para llegar lo más lejos posible antes de la próxima térmica?»

La lógica es la siguiente: si esperas encontrar térmicas de 2 m/s en el tramo siguiente, no tiene sentido volar a la velocidad de planeo óptimo (V#sub[G] (Velocidad de Planeo Óptimo)). Es más eficiente aumentar la velocidad ---sacrificando algo de planeo--- para llegar antes al núcleo de la próxima térmica. El anillo traduce esa lógica en una instrucción directa de velocidad.

- #strong[Ajusta el anillo] al valor de ascenso que esperas en la próxima térmica (p.~ej., 2 m/s).
- #strong[Vuela a la velocidad que marque el anillo] en el vario. En masas de aire descendente, volarás más rápido; en ascendente, más despacio.
- El resultado es el #strong[menor tiempo posible] para completar la travesía ---no el mayor planeo instantáneo.

=== El hilo de lana lateral como medidor del ángulo de ataque (técnica complementaria)
<el-hilo-de-lana-lateral-como-medidor-del-ángulo-de-ataque-técnica-complementaria>
El #strong[hilo de lana central] pegado en el centro de la cúpula es el instrumento rey y de obligada consulta para el control de la guiñada (vuelo coordinado). Sin embargo, en algunos entornos y escuelas se enseña de manera complementaria y no estándar el uso de un #strong[hilo de lana lateral] (#strong[side string]) como un indicador analógico e indirecto del ángulo de ataque (α, #strong[alfa]) de las alas.

A diferencia del anemómetro, cuya velocidad de pérdida indicada varía según el peso total de la aeronave (como por el uso de lastre de agua) o por la carga aerodinámica en viraje (factor de carga G), #strong[el ala entra en pérdida siempre al mismo ángulo de ataque físico]. El hilo de lana lateral busca medir la dirección del flujo de aire local sobre el lateral de la cabina, el cual varía de forma proporcional a la actitud del perfil de la aeronave respecto al viento relativo.

Esta técnica tiene limitaciones operativas que conviene conocer:

- #strong[Errores por guiñada:] si el planeador no vuela en perfecta coordinación (bola y lanita central centradas), el flujo de aire lateral se deforma drásticamente y la lectura del hilo lateral queda inservible.
- #strong[Calibración específica:] requiere que un instructor o piloto experimentado marque de forma empírica en el cristal las marcas físicas del #strong[ángulo de planeo óptimo] (V#sub[G] (Velocidad de Planeo Óptimo)) y del #strong[ángulo de pérdida (stall)] para cada modelo concreto de cabina.

Su utilidad se restringe exclusivamente al vuelo térmico lento para ayudar al alumno a visualizar la cercanía del planeador al coeficiente de sustentación máximo y prevenir pérdidas secundarias en virajes cerrados.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

En el vuelo rápido (#strong[high-speed flight]), el hilo de lana lateral pierde toda precisión debido a que los ángulos de ataque son extremadamente pequeños. En este rango, el anemómetro y la observación del horizonte son los únicos métodos de referencia válidos para evitar exceder la V#sub[NE] (Velocidad Nunca Exceder). El hilo de lana lateral es una herramienta didáctica complementaria para el vuelo térmico lento, nunca un sustituto de los instrumentos primarios de vuelo ni del hilo de lana central de coordinación.

]
, 
title: 
[
Advertencia
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
== Vuelo de ladera y de onda
<vuelo-de-ladera-y-de-onda>
=== Vuelo de ladera (#emph[ridge soaring])
<vuelo-de-ladera-ridge-soaring>
El #strong[vuelo de ladera] (#strong[ridge soaring]) aprovecha la deflexión ascendente que el viento genera al chocar contra una montaña o colina. Mientras el viento sopla de frente a la ladera con suficiente velocidad, el aire es forzado a ascender y genera una banda de ascenso que el planeador puede explotar de forma continua.

- #strong[Técnica:] vuela paralelo a la cresta, siempre por el lado de barlovento (el lado de donde viene el viento), a una distancia de seguridad que permita virar hacia el valle en cualquier momento.
- #strong[Tráfico:] si dos planeadores se cruzan en la misma ladera, el que tiene la montaña a su #strong[derecha] tiene preferencia. El otro debe separarse hacia el valle. Los giros se hacen siempre #strong[hacia fuera de la montaña] (hacia el valle).

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Nunca vires hacia la ladera si no tienes espacio garantizado para completar el viraje con margen. A sotavento de la montaña ---detrás de la cresta--- el aire puede descender con violencia incluso en condiciones de vuelo aparentemente buenas en barlovento. Una entrada accidental en la zona de rotor a baja altura sobre el terreno puede ser irrecuperable.

]
, 
title: 
[
Advertencia
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
=== Vuelo de onda (#emph[wave soaring])
<vuelo-de-onda-wave-soaring>
El #strong[vuelo de onda] (#strong[wave soaring]) ocurre cuando, con viento fuerte y condiciones atmosféricas estables, el flujo de aire desviado hacia arriba por una cordillera genera un sistema de ondas de presión a sotavento, similar a las ondas que forma una piedra en el agua. Estas ondas pueden extenderse decenas o cientos de kilómetros y alcanzar altitudes estratosféricas (#ref(<fig-06-cap03-onda-esquema>, supplement: [Figura])).

- #strong[Identificación:] la señal visual más característica son las #strong[nubes lenticulares] (#strong[lenticular clouds]): nubes con forma de lenteja o sombrero que permanecen estáticas sobre el terreno mientras el viento las atraviesa continuamente.
- #strong[Características:] el ascenso en la cresta de la onda es suave, constante y de gran amplitud. Es la vía hacia altitudes que ninguna térmica puede alcanzar.
- #strong[Zona de rotor:] inmediatamente debajo de las nubes de rotor ---las nubes fragmentadas y agitadas visibles bajo el nivel de la onda--- el aire es violentamente turbulento. Esta zona puede dañar estructuralmente el planeador y es obligatorio evitarla.

#figure([
#box(image("imagenes/06-cap03-onda-esquema.png"))
], caption: figure.caption(
position: bottom, 
[
Esquema de la onda orográfica y sus zonas de vuelo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap03-onda-esquema>


#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

El vuelo de onda a gran altitud requiere equipamiento específico: oxígeno a partir de los 3.000-4.000 metros según la autonomía y condición del piloto, ropa de abrigo adecuada y un altímetro calibrado. Antes de un vuelo de onda planificado, consulta el espacio aéreo: es frecuente que las altitudes de onda coincidan con zonas restringidas o reservadas para el tráfico controlado, que requieren autorización previa.

]
, 
title: 
[
Nota
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
== Gestión del lastre de agua (#emph[water ballast])
<gestión-del-lastre-de-agua-water-ballast>
El #strong[lastre de agua] consiste en depósitos situados en las alas del planeador que pueden llenarse de agua antes del vuelo. Al aumentar la masa del planeador, su curva polar se desplaza hacia velocidades más altas: el planeador vuela más rápido entre térmicas con el mismo ángulo de planeo.

La analogía más útil es la del ciclista: en un descenso largo, ir cargado permite llegar más rápido al fondo sin pedalear. Con lastre, el planeador «cae» más rápido pero a igual planeo, lo que es ventajoso cuando las térmicas son fuertes y los planeos entre térmicas son largos.

- #strong[Cuándo usarlo:] solo en días de térmicas fuertes (por encima de 2-3 m/s) y vuelos largos donde los planeos entre térmicas son significativos. En días débiles, el lastre penaliza más que ayuda.
- #strong[Vaciado:] si la meteorología empeora o antes del aterrizaje, el lastre debe vaciarse completamente. Abre las válvulas con tiempo suficiente: el vaciado completo suele tardar entre 3 y 8 minutos según el planeador.
- #strong[Hielo:] si vuelas a gran altitud con lastre, añade anticongelante al agua para evitar que se congele y dañe los depósitos o los sistemas de vaciado.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Un planeador con lastre de agua tiene una #strong[velocidad de pérdida significativamente mayor] ---hasta 15-20 km/h más que sin lastre---. Ajusta todas tus velocidades de referencia (despegue, aproximación, circuito) en consecuencia. #strong[Nunca aterrices con lastre completo], salvo que una avería del vaciado te obligue --- y entonces, extrema la suavidad de la toma: la inercia adicional puede superar la resistencia estructural de las alas y provocar un fallo catastrófico.

]
, 
title: 
[
Advertencia
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
#strong[Resumen del Capítulo: Técnicas de planeo]

- #strong[Centrado de térmica]: siente el empujón en el asiento. Si el ala derecha sube, el núcleo está a la derecha: vira a la derecha. Cierra el viraje cuando el vario sube, ábrelo cuando baja. Con práctica, este ciclo se vuelve automático.
- #strong[Hilo de lana lateral (]side string#strong[)]: técnica complementaria opcional para visualizar de forma didáctica el ángulo de ataque en vuelo lento; no sustituye al hilo central ni al anemómetro.
- #strong[Anillo MacCready]: tu selector de velocidad óptima. Pon el anillo en el valor de ascenso que esperas encontrar (p.~ej., 2 m/s) y vuela a la velocidad que te marque. Acelera en corrientes descendentes, aminora en corrientes ascendentes.
- #strong[Ladera]: mantente pegado a barlovento con vía de escape hacia el valle siempre disponible. Si tienes la ladera a tu derecha, tienes preferencia. Nunca vires hacia el monte.
- #strong[Onda]: la autopista al cielo. Sube en la zona laminar, delante de la nube de rotor. Requiere oxígeno y ropa de abrigo. Cuidado al bajar: el rotor puede romperte el planeador en segundos.
- #strong[Lastre de agua]: más masa = más velocidad sin perder planeo. Útil en días fuertes y travesías largas. Vacíalo antes de aterrizar y ajusta siempre las velocidades de referencia: con lastre, la pérdida llega mucho antes.

= Circuitos y aterrizaje
<circuitos-y-aterrizaje>
#quote(block: true)[
El circuito de tráfico es el corazón del vuelo de planeador: el momento en que toda la energía acumulada durante la travesía se convierte en un aterrizaje preciso y seguro. A diferencia de un avión con motor, el planeador no tiene segunda oportunidad si la primera aproximación sale mal ---no hay potencia para rectificar. El circuito exige planificación anticipada, visión tridimensional del espacio y la capacidad de tomar decisiones mientras el suelo se acerca.

En este capítulo aprenderás:

- #strong[La estructura del circuito estándar]: los cuatro tramos y las alturas de referencia en cada uno.
- #strong[La lista de comprobación FUSTALL]: qué verificar antes de aterrizar y en qué orden.
- #strong[Gestión de la velocidad con viento]: cómo calcular la velocidad de aproximación correcta.
- #strong[El uso eficaz de los aerofrenos]: cómo utilizarlos para clavar el punto de toma.
- #strong[Las correcciones en circuito]: cómo adaptarse cuando la energía no coincide con el plan.
]

== Estructura del circuito de tráfico
<estructura-del-circuito-de-tráfico>
El #strong[circuito de tráfico] es un procedimiento estandarizado que organiza la llegada al aeródromo de forma predecible y segura para todos los participantes. Su geometría rectangular permite que el piloto tenga siempre visibilidad de la pista y pueda ajustar la energía disponible en cada tramo.

Los cuatro tramos estándar son (#ref(<fig-06-cap04-circuito-estandar>, supplement: [Figura])):

+ #strong[Viento cruzado (]crosswind#strong[):] Tramo perpendicular a la pista, realizado justo tras el despegue o al entrar en el circuito desde la travesía. La altura recomendada al completar el giro a viento cruzado es de 250-300 metros (QFE).
+ #strong[Viento en cola] (#strong[downwind]): Tramo paralelo a la pista en dirección contraria al aterrizaje. Se vuela a una distancia lateral de 200-400 metros de la pista, a una altura de 200-300 metros. Es el tramo donde se realizan las comprobaciones de la lista FUSTALL (ver sección siguiente).
+ #strong[Tramo de base] (#strong[base leg]): Tramo perpendicular a la pista, iniciado cuando el punto de toma queda a unos 45° detrás del ala del piloto. La altura recomendada al inicio de la base es de 150 metros.
+ #strong[Final] (#strong[final leg]): Tramo alineado con la pista, desde el que se realiza el descenso y la toma. Los aerofrenos se gestionan de forma continua durante este tramo para clavar el punto de toma.

#figure([
#box(image("imagenes/06-cap04-circuito-estandar.jpg"))
], caption: figure.caption(
position: bottom, 
[
Estructura del circuito estándar de tráfico para planeador
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap04-circuito-estandar>


=== La lista de comprobación FUSTALL
<la-lista-de-comprobación-fustall>
Antes de entrar en el tramo de viento en cola, abre los grifos del lastre de agua ---aunque no lo lleves, para consolidar el hábito: el vaciado completo lleva varios minutos---. Ya en el viento en cola, ejecuta la lista #strong[FUSTALL] antes de continuar hacia la base y el final:

- #strong[F] (#strong[Flaps]): flaps en la posición de aterrizaje, si el planeador dispone de ellos.
- #strong[U] (#strong[Undercarriage / Tren de aterrizaje]): tren fuera y blocado. Comprueba visualmente la posición del indicador y, si el planeador lo tiene, el aviso sonoro.
- #strong[S] (#strong[Speed / Velocidad]): establece la velocidad de aproximación recomendada por el AFM (ver sección siguiente para la corrección por viento).
- #strong[T] (#strong[Trim / Compensador]): compensa el planeador a la velocidad de aproximación elegida.
- #strong[A] (#strong[Airbrakes / Aerofrenos]): verifica que los aerofrenos se mueven libremente y vuélvelos a cerrar para el tramo de base.
- #strong[L] (#strong[Landing area / Zona de aterrizaje]): escanea la zona de toma y el circuito completo: viento, otras aeronaves y personal en pista. ¿Hay otro planeador en final?
- #strong[L] (#strong[Land / Aterriza]): con todo verificado, dedica el resto del circuito exclusivamente a volar y aterrizar el planeador.

#block[
#callout(
body: 
[
✦ #strong[REGLA DE ORO]

Haz el FUSTALL siempre en el mismo punto del viento en cola ---por ejemplo, cuando la cabecera de la pista quede a la altura del ala---. La repetición convierte la lista en un hábito y hace prácticamente imposible omitirla. Un piloto que improvisa el momento del chequeo acaba por no hacerlo.

]
, 
title: 
[
Tip
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
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS: LA REGLA TRADICIONAL WULF]

En muchos clubes europeos se enseña la mnemotecnia abreviada #strong[WULF] para el mismo chequeo de viento en cola: #strong[W] (#strong[Water ballast]): lastre de agua vaciado; #strong[U] (#strong[Undercarriage]): tren fuera y blocado; #strong[L] (#strong[Loose articles / Look-out]): objetos sueltos asegurados y vigilancia exterior; #strong[F] (#strong[Flaps]): flaps en posición de aterrizaje. Ambas listas persiguen lo mismo: llegar al tramo de base con la configuración completa y la atención puesta fuera de la cabina.

]
, 
title: 
[
Nota
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
== Gestión de la velocidad y el viento
<gestión-de-la-velocidad-y-el-viento>
La velocidad durante el circuito debe ser constante y segura. Como referencia general, se utiliza la #strong[Velocidad de Aproximación Recomendada] del AFM, o en su defecto, #strong[1,5 veces la velocidad de pérdida] (1,5 V#sub[S]): el margen es mayor que en un avión con motor porque el planeador afronta el gradiente de viento y la recogida sin potencia para corregir.

El viento modifica esta ecuación de forma importante:

- #strong[Viento de cara en final:] añade a tu velocidad base la #strong[mitad de la velocidad del viento] (y la mitad de la racha máxima prevista). Un viento de 20 km/h justifica añadir 10 km/h a tu velocidad normal.
- #strong[Gradiente de viento:] cerca del suelo, el viento pierde velocidad de forma brusca. Si entras en final demasiado lento, puedes sufrir una pérdida repentina de sustentación justo cuando menos lo esperas ---a escasos metros del suelo---. Entra siempre con un pequeño exceso de velocidad y deja que se consuma durante el planeo final.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Entrar en final lento con viento en cara es una de las combinaciones más peligrosas en el vuelo de planeador. El gradiente de viento próximo al suelo puede robarte los últimos 15-20 km/h de velocidad en décimas de segundo, llevándote directamente a la pérdida a una altura donde la recuperación es imposible. La velocidad adicional en final no es un lujo: es un seguro de vida.

]
, 
title: 
[
Advertencia
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
== Uso de los aerofrenos
<uso-de-los-aerofrenos>
Los #strong[aerofrenos] son el control de planeo del planeador: permiten aumentar la tasa de descenso sin cambiar la actitud ni la velocidad. Son el instrumento que transforma la energía potencial sobrante en frenado aerodinámico y permiten clavar el punto de toma con precisión (#ref(<fig-06-cap04-aerofrenos-angulo>, supplement: [Figura])).

La estrategia más fiable para usar los aerofrenos es la siguiente:

- #strong[Aproximación estándar:] entra en final con los aerofrenos al #strong[50 %]. Esta posición central te da margen en ambas direcciones: si estás alto, abres más; si estás bajo, cierras.
- #strong[Ajuste continuo:] los aerofrenos se usan durante todo el final para mantener el punto de referencia estático en el parabrisas. Si el punto sube hacia ti, estás bajo: cierra aerofrenos. Si el punto baja, estás alto: abre más.
- #strong[Viraje de base a final:] evita usar los aerofrenos completamente abiertos durante el viraje. Una tasa de descenso elevada combinada con un alabeo pronunciado aumenta la carga alar efectiva y puede acercar peligrosamente el planeador a la velocidad de pérdida.
- #strong[Toma de tierra:] una vez que el planeador ha tocado, mantén los aerofrenos abiertos para evitar que vuelva a saltar (#strong[balonazo]) y para mejorar la eficacia del freno de rueda.

#figure([
#box(image("imagenes/06-cap04-aerofrenos-angulo.jpg"))
], caption: figure.caption(
position: bottom, 
[
Efecto de los aerofrenos en el ángulo de planeo durante el final
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap04-aerofrenos-angulo>


#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

Si en el viraje de base a final observas que vas a pasar de largo el punto de toma con los aerofrenos completamente abiertos, no cierres los frenos bruscamente cerca del suelo: el planeador sufrirá un balonazo repentino. En su lugar, si el campo lo permite, prolonga el giro de base o realiza una S suave en final para aumentar la distancia recorrida. Si nada funciona, estás en una situación de campo largo: aterriza y rueda hasta el final de la pista.

]
, 
title: 
[
Nota
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
== El resbale lateral (#emph[sideslip])
<el-resbale-lateral-sideslip>
El #strong[resbale lateral] (conocido como #strong[sideslip] en la terminología internacional) es una maniobra operativa avanzada que permite aumentar drásticamente la tasa de descenso del planeador sin incrementar su velocidad de avance. Consiste en provocar un resbale de forma deliberada exponiendo el lateral del fuselaje a la corriente de aire, lo que genera una gran resistencia aerodinámica.

Es el recurso definitivo de control de senda en las siguientes situaciones:

- Fallo o atasco de los aerofrenos en la aproximación.
- Aproximaciones excesivamente altas a campos desconocidos durante un aterrizaje fuera de campo.
- Ajustes rápidos de altura en días de turbulencias severas o cizalladura.

Para realizar un resbale de forma segura, aplica la siguiente técnica:

+ #strong[Entrada:] inicia un viraje suave hacia un lado y, de inmediato, aplica timón de dirección en sentido opuesto (cruza los mandos: alerón a un lado, pedal al contrario). El fuselaje se orientará oblicuo respecto a la trayectoria real de vuelo.
+ #strong[Dirección del viento:] orienta siempre la dirección del resbale de modo que #strong[el ala baja apunte hacia el viento] (si el viento viene de la izquierda, realiza un resbale con alabeo a la izquierda y pedal derecho). Esto ayuda a contrarrestar la deriva lateral y mejora el control.
+ #strong[Control de velocidad:] como el aire incide de lado sobre el fuselaje, la presión estática y dinámica en las tomas del planeador se altera y #strong[el anemómetro muestra indicaciones erróneas o nulas]. Controla la velocidad de aproximación de forma exclusivamente visual, manteniendo el morro en una actitud ligeramente picada respecto al horizonte.
+ #strong[Salida:] para finalizar la maniobra, relaja primero la presión en la palanca de profundidad (morro abajo) y luego neutraliza suavemente los alerones y el pedal de dirección. El planeador volverá de inmediato al vuelo coordinado en la senda deseada.

#figure([
#box(image("imagenes/06-cap04-resbale-lateral.png"))
], caption: figure.caption(
position: bottom, 
[
El resbale lateral: mandos cruzados para descender más sin acelerar
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap04-resbale-lateral>


#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Debido a que el flujo de aire está desprendido y el anemómetro no es fiable durante el resbale, existe riesgo de entrada en pérdida si el piloto tira excesivamente de la palanca de profundidad. Mantén siempre una actitud de morro netamente baja. Practica la maniobra a altura de seguridad antes de intentarla en circuito.

]
, 
title: 
[
Advertencia
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
=== Aterrizaje con viento de cola (#strong[downwind landing])
<aterrizaje-con-viento-de-cola-downwind-landing>
Aunque la regla de oro de la aviación exige aterrizar siempre de cara al viento para reducir la carrera en tierra, existen situaciones operativas (como una fuerte pendiente cuesta arriba en un aterrizaje fuera de campo o restricciones de obstáculos en la aproximación) que pueden obligar al piloto a realizar un aterrizaje con viento de cola.

El viento de cola altera radicalmente las referencias sensoriales del piloto y la física de la toma:

- #strong[Aumento de la velocidad sobre el suelo (]groundspeed#strong[):] si tu velocidad de aproximación indicada es de 90 km/h y tienes un viento de cola de 20 km/h, tu velocidad real respecto al suelo será de 110 km/h. La carrera de aterrizaje se alargará mucho más y exigirá más distancia y un uso eficaz del freno de rueda.
- #strong[La ilusión visual de velocidad:] al ver pasar el suelo a gran velocidad durante el final y la toma, tu cerebro interpretará falsamente que vas demasiado rápido. La reacción instintiva y peligrosa es tirar de la palanca de mando para frenar el velero. Esto reducirá la velocidad indicada por debajo de la de seguridad y puede provocar una pérdida (#strong[stall]) y entrada en barrena (#strong[spin]) a escasos metros del suelo.
- #strong[Senda de aproximación plana:] al desplazarte más rápido sobre el terreno, tu ángulo de descenso aparente será mucho más plano. Mantén una senda conservadora utilizando los aerofrenos con precisión.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Cuando vueles una aproximación con viento de cola, #strong[fía tu control de velocidad exclusivamente al anemómetro], ignorando la velocidad aparente con la que pasa el terreno bajo la cabina. Mantén la velocidad de aproximación recomendada y prepárate para una carrera de rodaje muy larga y un frenado enérgico.

]
, 
title: 
[
Advertencia
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
=== Oscilaciones inducidas por el piloto (#emph[PIO]) en cabeceo
<oscilaciones-inducidas-por-el-piloto-pio-en-cabeceo>
Las oscilaciones inducidas por el piloto (#strong[pilot-induced oscillations - PIO]) son fluctuaciones rápidas e incontroladas en la actitud de cabeceo del planeador cerca del suelo, generadas por la reacción tardía del piloto ante pequeños desvíos de trayectoria.

Durante la fase final de aproximación y la toma de tierra, a bajas velocidades, la efectividad de los mandos de vuelo se reduce y existe un ligero retraso (#strong[control lag]) entre el movimiento de la palanca y la respuesta física de la aeronave. Si el planeador sufre una pequeña ráfaga de viento y se encabrita, un piloto fatigado o de reflejos tardíos puede empujar la palanca hacia adelante con fuerza; cuando el planeador responde y empieza a picar, el piloto tira con fuerza hacia atrás. Este ciclo de correcciones excesivas y desfasadas se amplifica rápidamente:

- #strong[Consecuencias:] las oscilaciones pueden terminar en un contacto extremadamente duro del tren de aterrizaje principal o de la rueda de morro contra la pista, con daños estructurales severos en el fuselaje o lesiones a la tripulación.
- #strong[Corrección en vuelo:] en el momento en que sientas que inicias una oscilación en cabeceo cerca de la pista, #strong[congela la palanca de mando] en una posición estable y neutral. Deja que el planeador se estabilice solo por su estabilidad estática longitudinal y, si es necesario, abre o mantén los aerofrenos al 50 % para asentar la aeronave con suavidad (#ref(<fig-06-cap04-pio-cabeceo>, supplement: [Figura])).

#figure([
#box(image("imagenes/06-cap04-pio-cabeceo.png"))
], caption: figure.caption(
position: bottom, 
[
Oscilación inducida por el piloto (PIO): correcciones desfasadas que se amplifican
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap04-pio-cabeceo>


#strong[Resumen del Capítulo: Circuitos y aterrizaje]

- #strong[Circuito estándar]: cuatro tramos ---cruzado, viento en cola, base y final--- con alturas de referencia: 250-300, 200-300 y 150 metros hasta la toma. El circuito no es un ritual, es un gestor de energía.
- #strong[FUSTALL en el viento en cola]: #strong[Flaps], #strong[Undercarriage] (tren fuera y blocado), #strong[Speed] (velocidad de aproximación), #strong[Trim], #strong[Airbrakes] (aerofrenos libres y cerrados), #strong[Landing area] (viento y tráfico), #strong[Land]. Lastre de agua vaciado antes de entrar al circuito. Hazlo siempre en el mismo punto del recorrido.
- #strong[Velocidad de aproximación]: calcula tu velocidad base (1,5 V#sub[S]) y #strong[súmale la mitad del viento y de la racha]. Entrar lento con viento es receta para un accidente por cizalladura.
- #strong[Aerofrenos]: entra en final con el 50 % sacados. Si el punto de toma sube en el parabrisas, cierra; si baja, abre. Nunca cierres bruscamente cerca del suelo: balonazo y golpe de cola.
- #strong[Resbale lateral (]sideslip#strong[)]: método de descenso rápido de emergencia cruzando mandos. Recuerda: #strong[ala baja al viento], actitud visual de morro bajo (el anemómetro no es fiable por el flujo cruzado) y salida relajando primero la palanca.
- #strong[Viento de cola y PIOs]: en tomas con viento de cola, ignora la velocidad visual del suelo (evita pérdidas de sustentación) y prepárate para un rodaje largo. Si el velero oscila en cabeceo (#strong[PIO]) cerca del suelo, congela la palanca y deja actuar su estabilidad estática.

= Aterrizaje fuera de campo (
<aterrizaje-fuera-de-campo>
#quote(block: true)[
El #strong[aterrizaje fuera de campo] (#strong[outlanding]) es una realidad estadística del vuelo de travesía. No es un fallo, ni un accidente: es un procedimiento previsto, entrenado y perfectamente ejecutable cuando se hace con la cabeza fría y la altitud adecuada. La diferencia entre un aterrizaje fuera de campo que se cuenta en el hangar y uno que se convierte en accidente reside en un único factor: el momento en que el piloto toma la decisión.

En este capítulo aprenderás:

- #strong[La decisión de aterrizar]: cuándo y por qué la demora es la causa número uno de accidentes en campo.
- #strong[Las 7 S de selección de campo]: los siete criterios que evalúas en segundos para elegir el campo correcto.
- #strong[El análisis de superficies]: qué tipo de terreno es apto y cuáles son los engaños más frecuentes.
- #strong[La técnica de aproximación fuera de campo]: cómo adaptar el circuito estándar a un terreno desconocido.
- #strong[Procedimientos post-aterrizaje]: cómo asegurar el planeador, coordinar el rescate y gestionar la supervivencia y la relación con el propietario del terreno.
]

== La decisión de aterrizar fuera de campo
<la-decisión-de-aterrizar-fuera-de-campo>
El mayor enemigo del piloto en una situación de campo no es el terreno: es la esperanza. La esperanza de que aparecerá una térmica salvadora. De que ese campo que viste hace diez minutos todavía está dentro del alcance. De que bajar un poco más para buscar ascendencia no tiene consecuencias.

La estadística es contundente: la causa número uno de accidentes graves en vuelo de travesía no es la falta de campos disponibles, sino la #strong[demora en tomar la decisión de aterrizar]. El piloto que espera demasiado llega al campo elegido sin altura suficiente para inspeccionarlo correctamente, sin margen para rectificar una aproximación mal planificada y sin energía para evitar un obstáculo no visto.

La herramienta más útil para combatir este sesgo cognitivo es fijar de antemano una #strong[altura de decisión]. O mejor: una escalera de tres peldaños que convierte el descenso en un plan por fases, en lugar de un ultimátum:

- #strong[600 metros sobre el terreno:] selecciona la zona general donde vas a aterrizar. Puedes seguir buscando térmicas, pero solo las que te dejen siempre esa zona al alcance.
- #strong[450 metros:] elige el campo definitivo y evalúa sus 7 S (siguiente sección). Si pruebas una térmica, que sea sobre el propio campo.
- #strong[300 metros:] comprométete con el circuito. El juego térmico ha terminado; a partir de aquí, toda tu atención es para el aterrizaje.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Retrasar la decisión de aterrizar buscando una «térmica de rescate» a baja altura es el patrón más documentado en los accidentes graves de vuelo sin motor. Una vez fijada la altura de decisión, respétala sin excepciones. El planeador se puede reparar. El piloto, no siempre.

]
, 
title: 
[
Advertencia
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
== Criterios de selección: las 7 S
<criterios-de-selección-las-7-s>
Para evaluar si un campo es apto en los pocos segundos que tienes disponibles, utiliza la regla de las #strong[7 S]. Este método te obliga a evaluar los factores correctos en el orden correcto, evitando que la urgencia te lleve a pasar por alto un riesgo crítico (#ref(<fig-06-cap05-7s-seleccion-campo>, supplement: [Figura])):

+ #strong[S] (#strong[Size / Tamaño]): busca el campo más grande posible. Un campo de 400 metros es ideal para la mayoría de los planeadores modernos; menos de 200 metros es crítico y requiere una técnica impecable.
+ #strong[S] (#strong[Shape / Forma]): un campo largo y estrecho es mejor que uno corto y ancho. La forma debe permitir una aproximación limpia desde la dirección del viento sin obstáculos.
+ #strong[S] (#strong[Slope / Pendiente]): aterriza siempre cuesta arriba si hay pendiente, aunque eso signifique aterrizar con viento de cola ligero. Una pendiente descendente puede impedir que el planeador se detenga en la distancia disponible.
+ #strong[S] (#strong[Surface / Superficie]): analiza la textura y el color del terreno. El rastrojo o el barbecho son superficies ideales. Los cultivos altos, los viñedos y los arrozales son trampas que no perdonan.
+ #strong[S] (#strong[Surroundings / Alrededores]): evalúa los obstáculos en la senda de aproximación. La #strong[regla 1:10] es tu referencia: un obstáculo de 10 metros de altura consume 100 metros de pista efectiva. Cables de alta tensión, árboles altos y edificios pueden eliminar de golpe la mitad del campo disponible.
+ #strong[S] (#strong[Stock / Animales]): evita campos con ganado. Las vacas, ovejas o caballos son impredecibles y pueden cruzarse en la trayectoria de rodaje con consecuencias graves para el planeador y el piloto.
+ #strong[S] (#strong[Sun / Sol]): ten en cuenta la posición del sol. Aterrizar de cara al sol bajo puede cegarte por completo y ocultar obstáculos críticos ---especialmente los cables de alta tensión, que son invisibles en contraluz.

#figure([
#box(image("imagenes/06-cap05-7s-campo.jpg"))
], caption: figure.caption(
position: bottom, 
[
Las 7 S de selección de campo: infografía de evaluación rápida
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap05-7s-seleccion-campo>


== Análisis de superficies comunes
<análisis-de-superficies-comunes>
#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Tipo de campo], [Idoneidad], [Consideraciones clave],),
  table.hline(),
  [#strong[Barbecho]], [Excelente], [Terreno nivelado y compacto. Poco riesgo de irregularidades. Primera opción.],
  [#strong[Rastrojo]], [Muy bueno], [Restos de cereal ya segado. Superficie dura y segura. Rodaje corto.],
  [#strong[Cereal verde bajo (\< 20 cm)]], [Bueno], [Acepta tomas normales. Si el cereal supera los 20 cm, puede enganchar un ala y provocar una guiñada brusca.],
  [#strong[Cereal alto o maduro]], [Evitar], [Alto riesgo de «caballito» al enganchar el ala. Oculta irregularidades del terreno.],
  [#strong[Arado reciente]], [Aceptable con precaución], [Aterriza siempre paralelo a los surcos. La carrera será muy corta. Riesgo de volcar si los surcos son profundos.],
  [#strong[Pasto / Pradera]], [Engañoso], [Puede ocultar piedras, zanjas, cercas de alambre ocultas o ganado no visible desde el aire.],
  [#strong[Viñedo]], [Inaceptable], [Los postes y alambres de las hileras destruirán el planeador con certeza.],
  [#strong[Arrozal]], [Inaceptable], [El terreno está inundado. El contacto con el agua a velocidad de aterrizaje provocará el vuelco.],
)
== Técnica de aproximación y toma en campo desconocido
<técnica-de-aproximación-y-toma-en-campo-desconocido>
La aproximación a un campo no conocido debe ser más conservadora que la habitual. Los márgenes de error son menores: no conoces el nivel exacto del terreno, la textura real de la superficie ni si hay obstáculos ocultos.

+ #strong[Inspección previa:] si la altura lo permite, realiza una pasada sobre el campo a distancia de seguridad para verificar obstáculos no visibles desde lejos: cables finos, zanjas, desniveles o ganado. Nunca desciendas por debajo de la altura de los árboles para inspeccionar: el margen de recuperación es nulo.
+ #strong[Circuito estándar:] realiza un circuito lo más estándar posible. No inventes aproximaciones directas o curvas. El circuito estándar te da tiempo para inspeccionar el terreno en el viento en cola y ajustar la energía en la base.
+ #strong[Configuración:] tren de aterrizaje fuera y blocado, arneses ajustados al máximo. En caso de impacto, el arnés bien apretado es la diferencia entre una contusión y una lesión grave.
+ #strong[Velocidad:] mantén una velocidad ligeramente superior a la habitual ---añade 10-15 km/h sobre tu velocidad normal--- para tener mejor control ante las turbulencias mecánicas de los árboles y edificios cercanos.
+ #strong[La toma:] toca tierra con la mínima velocidad posible y mantén el planeador recto. Una vez en tierra, frena con decisión: es preferible romper el tren de aterrizaje contra un surco que intentar flotar sobre un obstáculo y entrar en pérdida.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD: EL «CABALLITO» (]GROUND LOOP#strong[)]

Si durante el rodaje ves que vas a chocar contra un obstáculo insalvable a alta velocidad, puedes provocar un «caballito» deliberado bajando un ala al suelo. El planeador pivotará sobre esa ala y se detendrá bruscamente, sacrificando la estructura del ala para salvar al piloto. Esta maniobra solo se usa como último recurso, cuando la alternativa es el impacto frontal a velocidad.

]
, 
title: 
[
Advertencia
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
== Procedimientos post-aterrizaje fuera de campo
<procedimientos-post-aterrizaje-fuera-de-campo>
Una vez que el planeador se ha detenido de forma segura y el flujo de adrenalina comienza a estabilizarse, el vuelo no ha terminado. Un aterrizaje fuera de campo (#strong[outlanding]) exitoso requiere una serie de acciones coordinadas para asegurar la integridad de la aeronave, gestionar las comunicaciones de rescate, garantizar tu supervivencia si estás en una zona aislada y mantener una relación respetuosa con los propietarios del terreno.

=== Aseguramiento del planeador
<aseguramiento-del-planeador>
Inmediatamente después de salir de la cabina y verificar que te encuentras ileso, tu primera prioridad es asegurar el planeador para evitar daños causados por el viento o por curiosos:

- #strong[Orientación respecto al viento:] si hay viento fuerte y es posible pivotar el planeador físicamente sin dañar la estructura, oriéntalo con el ala que tiene el viento de cara en el suelo, o bien perpendicular al viento.
- #strong[Lastre improvisado:] coloca un peso seguro (como un saco de tierra o de arena, o una bolsa de transporte pesada) sobre el extremo del plano apoyado en el suelo para evitar que el viento levante el ala y vuelque la aeronave. Nunca uses piedras angulosas o ramas que puedan arañar o perforar la fibra de vidrio.
- #strong[Bloqueadores de mandos (]gust locks#strong[):] asegura la palanca de mandos con el cinturón de seguridad y coloca bloqueadores externos en las superficies de control (timón, profundidad y alerones) si dispones de ellos, para evitar que el viento golpee las superficies contra sus topes físicos.
- #strong[Protección de la cabina y cúpula:] cierra y bloquea la cúpula inmediatamente. Si el sol es intenso, coloca la funda protectora de la cúpula para evitar el efecto invernadero en el interior de la cabina (que puede deformar instrumentos o resinas de la estructura o, incluso, provocar un incendio por efecto lupa) y el envejecimiento acelerado por la radiación UV.
- #strong[Fundas de protección:] coloca las fundas en las tomas de Pitot y de presión estática/total (TE) para evitar la entrada de insectos o suciedad del campo, que inutilizarían los instrumentos en el próximo vuelo.

=== Comunicaciones y localización
<comunicaciones-y-localización>
La tripulación de carretera (#strong[retrieve crew]) o tu club de vuelo necesitan saber exactamente dónde estás. No confíes en referencias visuales vagas como «cerca de un granero rojo». Sigue este protocolo de comunicación:

- #strong[Obtención de coordenadas:] lee las coordenadas geográficas exactas en tu sistema de navegación o en el teléfono móvil utilizando el GPS. Anota las coordenadas en formato estándar (grados decimales o grados, minutos y segundos) y la altitud.
- #strong[Llamada de estado:] contacta por teléfono o, si no hay cobertura móvil, utiliza la radio de aviación en la frecuencia de tu club o del aeródromo local para informar de que la toma ha sido segura y sin daños personales.
- #strong[Uso de rastreadores satelitales:] si vuelas en zonas montañosas o remotas sin cobertura telefónica, activa el mensaje de «llegada segura» (#strong[OK]) en tu dispositivo de seguimiento por satélite (tipo SPOT o Garmin inReach) para que tus contactos reciban tu ubicación exacta en tiempo real.
- #strong[Balizas de emergencia (ELT/PLB):] en caso de aterrizaje de emergencia con lesiones o daños graves que impidan otras comunicaciones, asegúrate de que la baliza transmisora de localización de emergencia (#strong[Emergency Locator Transmitter - ELT]) de 406 MHz se ha activado (o activa manualmente tu radiobaliza personal PLB). No la actives para un aterrizaje preventivo normal sin daños.

=== Supervivencia en zonas remotas
<supervivencia-en-zonas-remotas>
Si has tomado tierra en una región montañosa, desértica o boscosa de difícil acceso, el rescate puede demorarse varias horas o incluso pasar la noche. Aplica la siguiente regla de oro de la supervivencia aeronáutica:

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

#strong[Permanece siempre junto al planeador]. Una aeronave de color blanco o brillante de 15 metros de envergadura es infinitamente más fácil de avistar desde el aire por los equipos de rescate que un piloto caminando solo por el bosque o la montaña. Abandonar el velero para buscar ayuda a pie multiplica el riesgo de desorientación, hipotermia y retraso en la localización.

]
, 
title: 
[
Advertencia
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
- #strong[Uso del cockpit como refugio:] el habitáculo del planeador proporciona una excelente protección contra el viento, la lluvia y el frío. Utiliza los cojines y el espacio interior para aislarte del suelo húmedo o del frío de la estructura.
- #strong[El paracaídas de emergencia:] la tela de nailon de tu paracaídas de emergencia es una herramienta de supervivencia valiosísima. Puedes extraerla del arnés y usar su gran superficie para montar un refugio tipo tienda contra el velero, envolverte en ella para conservar el calor corporal (actúa como un cortavientos eficaz) o extenderla en el suelo como señal visual de alto contraste para las búsquedas aéreas.

=== Relación con el propietario del terreno
<relación-con-el-propietario-del-terreno>
El aterrizaje fuera de campo se realiza amparado por el estado de necesidad de la seguridad aeronáutica, pero no debes olvidar que te encuentras en una propiedad privada:

- #strong[Minimización de daños:] al desmontar el planeador para introducirlo en el remolque, procura no pisar cultivos altos ni dañar vallas o cercados. Si es necesario, traslada las piezas a pie por los bordes de la parcela.
- #strong[Trato diplomático:] cuando el agricultor o el dueño de la finca se presente, muéstrate educado y agradecido. Explica con calma que se ha tratado de un aterrizaje preventivo por falta de sustentación (una situación normal y segura) y que no tenías motor para regresar. La inmensa mayoría de las personas son comprensivas si se les trata con cortesía y respeto por su propiedad.

#strong[Resumen del Capítulo: Aterrizaje fuera de campo]

- #strong[La decisión (600/450/300 m)]: a 600 m sobre el terreno, elige la zona; a 450 m, el campo; a 300 m, comprométete con el circuito y olvida las térmicas. Retrasar esta decisión buscando un «milagro rasante» es la causa número 1 de accidentes graves.
- #strong[Selección del campo (7 S)]: tamaño, forma, pendiente, superficie, alrededores, animales y sol. Un campo grande, llano, con viento en cara y sin obstáculos en la aproximación es tu seguro de vida.
- #strong[El circuito]: hazlo #strong[estándar]. No inventes aproximaciones directas raras. El viento en cola sirve para inspeccionar el terreno; la base, para ajustar la altura; el final, para clavar la toma.
- #strong[En tierra]: frena a fondo. Es mejor romper el tren en un surco que intentar flotar sobre un obstáculo y entrar en pérdida a tres metros del suelo.
- #strong[Procedimientos post-toma]: asegura el planeador contra el viento (pesos en planos, cúpula cerrada, fundas de pitot), transmite tus coordenadas GPS exactas, permanece junto a la aeronave si estás en zona aislada (usa la tela del paracaídas como refugio) y mantén un trato respetuoso y educado con el agricultor.

= Procedimientos operativos especiales y peligros
<procedimientos-operativos-especiales-y-peligros>
#quote(block: true)[
El vuelo de planeador se desarrolla en un entorno compartido con otras aeronaves, con fauna aérea, con fenómenos meteorológicos que pueden aparecer en minutos y con una orografía que puede ser tan aliada como adversaria. Conocer los procedimientos específicos para cada uno de estos escenarios ---y entender por qué están diseñados así--- es lo que separa al piloto reactivo del piloto preventivo.

En este capítulo aprenderás:

- #strong[Vigilancia exterior y colisiones]: la regla de los 3 segundos y las técnicas de escaneo visual.
- #strong[FLARM]: cómo funciona, qué detecta y, sobre todo, qué no detecta.
- #strong[Peligros de la fauna]: cómo coexistir con las aves sin asumir riesgos innecesarios.
- #strong[Estelas turbulentas y engelamiento]: dos amenazas silenciosas en vuelo.
- #strong[Viento cruzado]: técnica de despegue y aterrizaje en condiciones exigentes.
- #strong[Riesgos en montaña]: horizonte falso, reglas de preferencia y la prohibición absoluta de virar hacia la ladera.
- #strong[Amerizaje (]ditching#strong[)]: qué hacer si el agua es inevitable.
]

== Vigilancia exterior y colisiones
<vigilancia-exterior-y-colisiones>
La colisión en el aire (#strong[mid-air collision]) es uno de los peligros más graves para el planeador, especialmente en zonas de alta concentración de aeronaves como térmicas fuertes, laderas populares o las proximidades del aeródromo en las horas punta del día.

El problema físico es implacable: a 150 km/h, dos planeadores que se acercan de frente tienen una velocidad relativa de cierre de 300 km/h ---83 metros por segundo---. Esto significa que si se detectan mutuamente a 300 metros de distancia, tienen algo menos de #strong[cuatro segundos] para reaccionar. En realidad, la mitad de ese tiempo ---unos dos segundos--- se consume en el proceso perceptivo y de decisión, antes de que el planeador haya cambiado ni un metro su trayectoria.

=== La regla de los 3 segundos
<la-regla-de-los-3-segundos>
Para evitar una colisión, un piloto necesita aproximadamente #strong[3 segundos] desde que detecta visualmente la aeronave conflictiva hasta que su planeador ha respondido físicamente a la maniobra de evasión:

- #strong[1,5 segundos] para detectar la otra aeronave, reconocer el peligro, decidir la maniobra y ejecutarla.
- #strong[1,5 segundos] para que el planeador responda físicamente y comience a cambiar su trayectoria.

Esta regla tiene una consecuencia directa: las aeronaves deben detectarse a #strong[mucho más de 250 metros] para que la evasión sea posible con margen. Y eso solo ocurre si el piloto mira activamente hacia fuera.

=== Técnicas de escaneo visual
<técnicas-de-escaneo-visual>
- #strong[Vigilancia activa:] dedica el 95 % del tiempo a mirar fuera de la cabina. Los instrumentos solo necesitan miradas breves y periódicas.
- #strong[Barrido sectorial:] divide el horizonte en sectores de 15-20° (#ref(<fig-06-cap06-escaneo-visual>, supplement: [Figura])). Mueve los ojos de sector en sector, deteniéndote brevemente en cada uno. La visión periférica detecta el movimiento, pero para resolver si es una aeronave necesitas mirar directamente.
- #strong[Antes de virar:] mira siempre hacia el lado del viraje y al sector contrario antes de inclinar el planeador.
- #strong[Puntos ciegos:] las alas, el fuselaje y el capó ocultan parte del cielo. Mueve ligeramente el morro o alabea suavemente para «limpiar» las zonas ciegas de forma periódica.

#figure([
#box(image("imagenes/06-cap06-escaneo-visual.jpg"))
], caption: figure.caption(
position: bottom, 
[
Técnica de escaneo visual sectorial en el horizonte
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap06-escaneo-visual>


== Ayudas electrónicas: FLARM
<ayudas-electrónicas-flarm>
El #strong[FLARM] es un sistema de alerta de colisión diseñado específicamente para el vuelo sin motor y la aviación general ligera. Opera enviando la posición GPS del planeador y su vector de movimiento predicho mediante una señal de radio corta a todos los equipos FLARM cercanos. Cada equipo recibe estas posiciones, calcula si las trayectorias convergen y, si detecta riesgo de colisión, emite una alerta sonora y visual con la dirección e intensidad del peligro.

- #strong[¿Qué detecta?] Aeronaves equipadas con FLARM o dispositivos compatibles (PowerFLARM, SoftRF, FANET), algunos aviones con ADS-B Out, y obstáculos fijos programados en su base de datos (cables de teleférico, antenas, tendidos eléctricos en zonas de vuelo de competición).
- #strong[¿Qué NO detecta?] Aeronaves sin FLARM ni ADS-B (muchos aviones ultraligeros, helicópteros militares, parapentes, globos sin equipar), objetos no incluidos en su base de datos, y tráfico fuera de su alcance de radio (habitualmente 3-5 km horizontal).

=== Procedimiento operativo ante alertas FLARM
<procedimiento-operativo-ante-alertas-flarm>
Para que el FLARM cumpla con su función de seguridad sin generar distracciones fatales en cabina, el piloto debe seguir el siguiente protocolo de comportamiento estandarizado ante una alerta:

+ #strong[Lectura rápida y anuncio:] capta la advertencia visual con una mirada rápida y precisa al instrumento y verbalízala en voz alta (p.~ej., «Tráfico a la una en punto, más alto»). Esto asegura que la tripulación (si vuela en biplaza) comparte la conciencia situacional.
+ #strong[Búsqueda visual exterior proactiva:] dirige de inmediato la atención hacia el exterior de la cabina, enfocando la mirada en el sector indicado por la alerta. #strong[Nunca te quedes mirando fijamente la pantalla del FLARM] intentando interpretar símbolos o trayectorias; el instrumento te dice dónde buscar, pero la colisión solo se evita mirando afuera.
+ #strong[Confirmación visual:] mantén el rumbo y la actitud hasta confirmar el contacto visual con la aeronave conflictiva.
+ #strong[Nada de maniobras evasivas bruscas «a ciegas»:] si no logras establecer contacto visual con el tráfico, #strong[evita los virajes o cambios de altitud violentos] basados únicamente en la indicación de la pantalla del FLARM. Un viraje brusco sin ver al otro planeador puede llevarte a interceptar su trayectoria de evasión o a colisionar con un tercer planeador no equipado que se encuentre fuera del radar. Ante la duda, realiza cambios suaves y predecibles de actitud para aumentar tu visibilidad.

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

El FLARM es una herramienta de seguridad extraordinariamente útil, (obligatoria para competición oficial desde un regional hasta los mundiales) pero #strong[nunca sustituye a la vigilancia visual]. Considéralo como un complemento que te avisa de los peligros que ya conoce, no como un sistema que elimina todos los riesgos. Ante una alerta FLARM, reacciona buscando visualmente la aeronave conflictiva: el sistema te indica la dirección, pero la maniobra final es responsabilidad tuya.

]
, 
title: 
[
Nota
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
== Peligros de la fauna: aves
<peligros-de-la-fauna-aves>
Las aves ---especialmente los buitres, alimoches y cigüeñas negras--- son compañeros frecuentes en las térmicas y en el vuelo de ladera y travesía. Son maestros del vuelo térmico y excelentes indicadores de la calidad del ascenso. Sin embargo, una colisión con un buitre leonado (6-10 kg de masa y una envergadura de casi 2,5 metros) puede destruir el borde de ataque, penetrar en la cabina o dañar de forma catastrófica los mandos de vuelo.

+ #strong[Trátalos como tráfico:] no intentes «perseguirlos», asustarlos ni acorralarlos con el planeador. Un ave asustada puede maniobrar de forma brusca e impredecible.
+ #strong[Evita cambios bruscos:] el ave suele esquivarte si mantienes una trayectoria predecible. Los cambios repentinos de dirección pueden llevarla directamente hacia ti.
+ #strong[Síguelas, no te juntes:] las aves indican el mejor núcleo de la térmica, pero mantén siempre una distancia de seguridad. Compartir el viraje con una bandada de buitres a corta distancia crea un entorno de visibilidad reducida y maniobra imprevisible.

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS: EL COMPORTAMIENTO DE LOS BUITRES]

En la península ibérica, el encuentro con buitres leonados en térmica es diario durante la temporada de vuelo. Los instructores de la escuela española enseñan una regla de oro de seguridad ante una trayectoria de colisión inminente con un buitre: #strong[esquiva siempre al ave volando por encima de ella:]

El instinto de escape natural de un buitre asustado ante una amenaza de gran tamaño es #strong[plegar sus alas y arrojarse en picado hacia abajo] para ganar velocidad de escape rápida. Si el piloto intenta esquivar al buitre picando el planeador (por debajo), existe una altísima probabilidad de interceptar la trayectoria de caída del ave y chocar frontalmente. Ante la duda, mantén tu trayectoria coordinada o tira suavemente de la palanca para pasar por encima de su cota.

]
, 
title: 
[
Nota
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
⚠ #strong[SEGURIDAD]

Los tendidos eléctricos y los cables de telecomunicaciones son invisibles desde el aire en muchas condiciones de luz. Son el mayor riesgo no detectado en el vuelo de travesía y campo. El FLARM puede incluir su posición en zonas de competición, pero en vuelo libre la responsabilidad de detectarlos es exclusivamente visual: identifica los postes de hormigón o madera y traza mentalmente la línea entre ellos antes de sobrevolarla.

]
, 
title: 
[
Advertencia
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
== Estelas turbulentas y engelamiento
<estelas-turbulentas-y-engelamiento>
=== Estelas turbulentas (#emph[wake turbulence])
<estelas-turbulentas-wake-turbulence>
Las #strong[estelas turbulentas] ---los vórtices de punta de ala generados por aeronaves pesadas--- son invisibles, persistentes y extraordinariamente peligrosas para un planeador. Se forman en el momento del despegue y durante toda la fase de vuelo, descendiendo lentamente y desplazándose lateralmente con el viento.

- Evita volar por debajo y detrás de aeronaves pesadas o del propio avión remolcador.
- En el despegue por aerotow, mantén la posición alta para no cruzar la estela del remolcador.
- En zonas de tránsito aéreo intenso, mantén una conciencia situacional activa sobre el tráfico de aerolíneas a niveles superiores.
- #strong[Peligro especial de helicópteros:] Los helicópteros generan estelas turbulentas extremadamente potentes debido a la carga de sus palas de rotor. En vuelo estacionario o en rodaje lento (#strong[hover]), el flujo de aire descendente (#strong[downwash]) se expande radialmente en superficie y puede volcar un planeador a ras de suelo; mantén siempre una separación mínima de #strong[tres diámetros de rotor]. En vuelo de avance, generan vórtices de estela muy intensos debido a sus bajas velocidades operativas; evita volar por debajo o detrás de ellos y extrema la precaución en circuitos mixtos, ya que el ATC no siempre emite avisos de estela para helicópteros de tonelaje ligero o medio.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

La turbulencia de estela generada por helicópteros es desproporcionada en comparación con su peso. Dado que los planeadores tienen gran envergadura y poca carga alar, son extremadamente vulnerables. Nunca intentes aterrizar o despegar inmediatamente detrás de un helicóptero en movimiento y evita cruzar zonas donde se haya realizado vuelo estacionario reciente.

]
, 
title: 
[
Advertencia
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
=== Engelamiento (#emph[icing])
<engelamiento-icing>
El #strong[engelamiento] es la acumulación de hielo en el borde de ataque, que altera drásticamente el perfil aerodinámico del ala: aumenta la resistencia, reduce la sustentación y eleva la velocidad de pérdida de forma significativa. Una capa de hielo de apenas 2 milímetros puede incrementar la velocidad de pérdida en un 20-30 % y hacer el planeador prácticamente inmanejable.

- Si vuelas en onda, cerca de nubes o a grandes altitudes con temperatura bajo cero, vigila el borde de ataque periódicamente.
- Ante los primeros indicios de acumulación (cambio de maniobrabilidad, aumento del ruido aerodinámico), desciende de inmediato a aire más cálido.
- Vuela con un margen de velocidad extra durante todo el tiempo que dure la posible contaminación.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

El agua en las alas ---por humedad, rocío o lluvia suave--- tiene un efecto similar al engelamiento leve: aumenta la resistencia y la velocidad de pérdida entre un 5-10 %. Aumenta tu velocidad de aproximación y de circuito si las alas están mojadas o si has volado en condiciones de humedad elevada. Este efecto es especialmente traicionero en el aterrizaje.

]
, 
title: 
[
Advertencia
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
== Despegue y aterrizaje con viento cruzado
<despegue-y-aterrizaje-con-viento-cruzado>
Operar con viento cruzado exige una coordinación técnica activa de mandos para evitar que el planeador se desvíe de la pista o sufra daños estructurales en el ala de barlovento:

=== Despegue con viento cruzado
<despegue-con-viento-cruzado>
Mantén el #strong[alerón completamente hacia el lado del viento] al inicio de la carrera para evitar que el ala de barlovento se levante prematuramente. Usa el pedal contrario para mantener el eje longitudinal sobre la pista. A medida que ganas velocidad y los mandos se hacen más eficaces, reduce gradual y proporcionalmente la deflexión de alerones. Eleva el planeador sin viento lateral buscando la velocidad correcta y gira con proa al viento una vez en vuelo.

=== Aterrizaje con viento cruzado
<aterrizaje-con-viento-cruzado>
En final, utiliza la técnica del #strong[«cangrejo»]: apunta el morro hacia el viento para compensar la deriva y mantener la trayectoria sobre tierra alineada con la pista. Justo antes de tocar tierra, usa el pedal para alinear el morro con la pista y el alerón para bajar el ala que recibe el viento, asegurando que la rueda principal toca sin deriva lateral (#ref(<fig-06-cap06-viento-cruzado>, supplement: [Figura])). Una toma con deriva lateral significativa puede romper el tren de aterrizaje o provocar un derrape que lleve el planeador fuera de la pista.

#figure([
#box(image("imagenes/06-cap06-viento-cruzado.png"))
], caption: figure.caption(
position: bottom, 
[
Aterrizaje con viento cruzado: «cangrejo» en final y alineación antes de la toma
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap06-viento-cruzado>


== Riesgos en vuelo de montaña y ladera
<riesgos-en-vuelo-de-montaña-y-ladera>
=== Horizonte falso
<horizonte-falso>
En valles estrechos y en vuelo de ladera, las cumbres circundantes pueden confundir al sistema visual del piloto y sustituir al horizonte real. Si el piloto usa las laderas como referencia de horizonte en lugar del horizonte astronómico verdadero, puede terminar volando con un ángulo de ataque peligrosamente alto ---creyendo que está en actitud normal--- y aproximarse a la pérdida sin percibirlo.

La corrección es siempre mirar el horizonte real: la línea que separa el cielo del terreno más distante, generalmente en el valle o en la llanura al fondo.

=== Reglas de preferencia en ladera
<reglas-de-preferencia-en-ladera>
Si dos planeadores se cruzan en la misma ladera, el que tiene la montaña a su #strong[derecha] tiene preferencia de paso. El otro debe separarse hacia el valle para crear espacio. Esta regla es idéntica al derecho de paso marítimo en aguas costeras: el que no tiene maniobra (está entre el otro y la roca) tiene preferencia; el que puede maniobrar, se aparta.

=== Prohibición absoluta de virar hacia la montaña
<prohibición-absoluta-de-virar-hacia-la-montaña>
Nunca vires hacia la ladera si no tienes garantizado el espacio para completar el viraje con margen de seguridad. Un planeador que entra en pérdida o barrena virando hacia la roca, a baja altura, no tiene ninguna posibilidad de recuperación. La montaña no da segundas oportunidades.

== Amerizaje (#emph[ditching])
<amerizaje-ditching>
Aunque el planeador opera principalmente sobre tierra, el vuelo de travesía puede llevar al piloto sobre grandes masas de agua ---lagos, pantanos, ríos--- en caso de agotamiento de sustentación. Si el #strong[amerizaje] es inevitable:

+ #strong[Tren de aterrizaje fuera:] consulta el AFM de tu aeronave por si contempla el caso, pero la doctrina moderna de planeador ---confirmada por los ensayos de amerizaje y las notas de seguridad de DG Flugzeugbau--- es amerizar con el #strong[tren extendido]. La rueda frena el planeador al contacto con el agua y limita la profundidad de inmersión, sin riesgo apreciable de capotaje. Con el tren retraído ocurre lo contrario de lo que dicta la intuición: el morro bucea y la cabina puede quedar empujada bajo el agua. La vieja regla del «tren arriba» viene de los aviones con motor, no del planeador.
+ #strong[Configuración:] ameriza paralelo a las olas o al oleaje si es posible, con los aerofrenos desplegados para reducir la velocidad al máximo.
+ #strong[Abandono inmediato:] sal de la cabina en cuanto te detengas. El planeador se hundirá en cuestión de segundos: la cabina de compuesto y la estructura rígida pierden flotabilidad con rapidez.

#strong[Resumen del Capítulo: Procedimientos especiales y peligros]

- #strong[Vigilancia visual]: el FLARM ayuda, pero no lo ve todo. El 95 % del tiempo, mira fuera. Barre el horizonte en sectores. Antes de virar, mira siempre hacia el lado del viraje.
- #strong[Viento cruzado]: alerón al viento en el despegue para que no levante el plano, pie contrario para no irte de la pista. En el aterrizaje, «cangrejo» hasta el final y alinear con el pie antes de tocar.
- #strong[Vuelo en montaña]: horizonte falso. Las cumbres te engañan; si las usas como referencia, volarás con el morro muy alto y entrarás en pérdida. Tu horizonte real es la base de la montaña o el valle.
- #strong[Engelamiento y lluvia]: cualquier contaminación del borde de ataque sube la velocidad de pérdida. Añade velocidad al circuito y a la aproximación. Si se acumula hielo, desciende de inmediato.
- #strong[Amerizaje]: si no queda otra opción, #strong[tren fuera] ---la rueda frena el planeador al contacto y evita que la cabina bucee---, paralelo a las olas y a velocidad mínima. En cuanto el planeador se pare, sal: se hunde en segundos.

= Procedimientos de emergencia
<procedimientos-de-emergencia>
#quote(block: true)[
Las emergencias en vuelo no se gestionan con improvisación: se gestionan con entrenamiento. La diferencia entre una emergencia que termina con el planeador en tierra y los tripulantes ilesos, y una que termina en accidente, suele medirse en uno o dos segundos de reacción y en si el procedimiento correcto estaba automatizado o no. Este capítulo describe las emergencias más frecuentes en el vuelo sin motor y el procedimiento exacto para cada una.

En este capítulo aprenderás:

- #strong[Emergencias en el lanzamiento]: cómo actuar ante una rotura de cable, un fallo de remolque o una suelta atascada (#strong[towhook jam]).
- #strong[Fuego a bordo]: procedimiento en planeadores motorizados y gestión de la evacuación de humos.
- #strong[Fallos estructurales y de mandos]: qué hacer cuando un mando no responde, ante vibraciones anormales o desequilibrios de lastre.
- #strong[Fallo de instrumentos y sistemas]: cómo responder a la obstrucción de tomas de presión y a la apertura accidental de la cúpula en vuelo.
]

== Emergencias en el lanzamiento
<emergencias-en-el-lanzamiento>
La fase de lanzamiento concentra el mayor riesgo del vuelo de planeador. La combinación de baja altura, alta velocidad de aceleración y dependencia de un sistema externo ---el cable de torno o el avión remolcador--- crea una ventana de vulnerabilidad en la que cualquier fallo exige una respuesta #strong[instintiva, inmediata y sin vacilación].

La regla de oro universal ante cualquier emergencia en el lanzamiento es:

- #strong[Primero:] bajar el morro a actitud de planeo para recuperar velocidad y evitar la pérdida.
- #strong[Segundo:] soltar el cable (si no se ha soltado automáticamente).
- #strong[Tercero:] evaluar la altura disponible y decidir la opción de aterrizaje.

Este orden de prioridades es invariable. No importa cuál sea la emergencia específica: la velocidad siempre es el primer recurso que hay que asegurar.

=== Rotura de cable o fallo de remolque
<rotura-de-cable-o-fallo-de-remolque>
Ante un #strong[fallo de lanzamiento] ---rotura del cable de torno o fallo del motor del remolcador---, la reacción del piloto debe ser inmediata y automatizada. La metodología internacional estructura la respuesta de emergencia en torno a la mnemotecnia de #strong[las 3 P]:

+ #strong[Palanca:] empuja la palanca de mando adelante de inmediato (morro abajo) para estabilizar el planeador en actitud de planeo normal. En la actitud empinada de ascenso, la velocidad cae drásticamente y un retraso de más de dos segundos en bajar el morro causará una pérdida inminente.
+ #strong[Pulsador:] tira de la anilla de suelta del cable con fuerza dos o tres veces. Así te aseguras de que el cable roto se desengancha por completo del planeador y no arrastras restos que puedan engancharse en obstáculos del terreno (vallas, cultivos) durante la aproximación.
+ #strong[Pensar:] evalúa la altura disponible, la pista restante y el viento para ejecutar la decisión correspondiente en décimas de segundo.

La toma de decisiones táctica depende directamente de la altura AGL alcanzada en el momento del fallo y del método de lanzamiento utilizado, ya que la velocidad de ascenso y la distancia horizontal a la pista difieren drásticamente entre el torno y el avión tractor (#ref(<fig-06-cap07-emergencia-altura>, supplement: [Figura])):

- #strong[En lanzamiento por torno (]winch#strong[):] la trayectoria de trepada es muy empinada y el planeador gana altura muy cerca del inicio de la pista. Las franjas de decisión de seguridad son:
- #strong[Baja altura (menos de 150 m AGL):] mantén el planeador recto por derecho, estabiliza la velocidad de planeo de seguridad y aterriza en la pista restante o en los campos de parada libre al frente. #strong[Está terminantemente prohibido intentar virar de vuelta a pista por debajo de esta cota] debido a la alta actitud de morro y el peligro inminente de barrena.
- #strong[Altura crítica (entre 150 m y 200 m AGL):] si no queda suficiente pista por delante, vuela a velocidad segura y realiza un circuito abreviado y muy recortado. Vira inicialmente con un alabeo coordinado medio (máximo 30°), adaptándolo al viento reinante para asegurar el tramo final de cara al viento.
- #strong[Altura de seguridad (más de 200 m AGL):] estabiliza la velocidad de planeo y realiza un circuito de tráfico abreviado estándar.
- #strong[En remolque por avión (]aerotow#strong[):] el despegue es más tendido y el planeador se desplaza horizontalmente lejos de la pista de salida. Las franjas de decisión son:
- #strong[Baja altura (menos de 70 m, ≈230 ft AGL):] aterriza recto por delante en la pista restante o en campos libres al frente, esquivando obstáculos con pequeños cambios de rumbo (máximo 30°).
- #strong[Altura crítica (entre 70 m ≈230 ft y 150 m ≈490 ft AGL):] evalúa la longitud de pista y el viento. Si es necesario retornar, inicia el viraje #strong[hacia la componente de viento cruzado], coordinado y con un alabeo franco de unos 45°: el viento te devuelve hacia la prolongación de la pista durante el giro, mientras que virar a favor del viento alarga el recorrido y la altura perdida. Si el retorno no sale a cuenta, realiza una aproximación recortada al campo alternativo más seguro.
- #strong[Altura de seguridad (más de 150 m ≈ 500 ft AGL):] realiza un circuito recortado o normal de aproximación.

#figure([
#box(image("imagenes/06-cap07-emergencia-altura.jpg"))
], caption: figure.caption(
position: bottom, 
[
Opciones de aterrizaje según la altura y el método de lanzamiento en caso de rotura de cable
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap07-emergencia-altura>


#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS: LA DECISIÓN DE ATERRIZAR FUERA]

Ante un fallo de lanzamiento a altura crítica, #strong[un aterrizaje fuera de los límites del aeródromo (aterrizaje forzoso recto por delante) es siempre preferible a intentar un viraje de retorno forzado a baja altura]. Forzar el viraje para "salvar" el planeador y volver a la pista es la causa principal de pérdidas y barrenas fatales.

]
, 
title: 
[
Nota
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
⚠ #strong[SEGURIDAD: «LA MANIOBRA IMPOSIBLE»]

Intentar regresar al aeródromo virando 180° a baja altura ---lo que en aviación se conoce como «la maniobra imposible»--- es la causa documentada de la mayoría de los accidentes graves en el despegue. La geometría del planeo no lo permite: el viraje a baja altura consume una energía y altura que no existen. #strong[Si estás por debajo de la altura crítica establecida (150 m en torno y 70 m en avión) y no hay espacio de pista por delante, aterriza recto en campo abierto. ¡Siempre!]

]
, 
title: 
[
Advertencia
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
=== Fallo de suelta / gancho atascado (#emph[towhook jam])
<fallo-de-suelta-gancho-atascado-towhook-jam>
Si durante un remolque por avión intentas soltarte y la anilla de suelta no responde (el cable permanece enganchado), te encuentras ante un #strong[fallo de suelta]. Es una emergencia coordinada de alta prioridad que requiere una señalización visual estandarizada para comunicarte con el piloto del remolcador.

Aplica de inmediato el siguiente procedimiento:

+ #strong[Señala la emergencia:] avisa al remolcador por radio o, si no responde, desplázate a una posición #strong[baja y al lado izquierdo] del remolcador y balancea las alas de forma repetida y pronunciada. Nunca te eleves por encima de la posición normal de remolque para llamar la atención: subir tira de la cola del remolcador hacia arriba (#strong[kiting]) y puede clavar su morro contra el suelo. Es la emergencia más letal que existe para el piloto remolcador.
+ #strong[Respuesta del remolcador:] el piloto del avión remolcador, al ver tu señal, intentará activar su propia suelta para liberar el cable desde su lado.
+ #strong[Liberación del cable:] si el remolcador logra soltar el cable, regresarás al aeródromo con el cable de remolque colgando del gancho de tu planeador.
+ #strong[Aproximación y aterrizaje con cable:] cuando vueles de regreso con el cable colgando (que suele tener entre 50 y 60 metros de longitud), planifica una aproximación final significativamente más alta de lo habitual. Es crítico para garantizar que el cable colgante libre con seguridad cualquier obstáculo previo a la pista (vallas del aeródromo, setos, carreteras, cables telefónicos o de alta tensión).
+ #strong[Si el remolcador tampoco puede soltar:] en el caso extremo de que ambos ganchos estén atascados, deberás realizar un descenso y aterrizaje coordinado y simultáneo en formación con el avión remolcador, siguiendo las instrucciones de radio.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Cuando vueles una aproximación con el cable colgando, #strong[bajo ninguna circunstancia realices una aproximación baja]. El cable podría engancharse en una valla o línea eléctrica antes del umbral de la pista, lo que provocaría una deceleración violenta y un impacto del planeador contra el suelo sin control (#strong[pitch-up] o pérdida instantánea). Mantén un margen de altura generoso hasta superar el umbral.

]
, 
title: 
[
Advertencia
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
== Fuego a bordo
<fuego-a-bordo>
En planeadores motorizados (#strong[Motorsegler]) o autolanzables, el incendio es una amenaza de gravedad extrema. Los materiales compuestos de la estructura ---carbono, fibra de vidrio, resinas--- generan humos altamente tóxicos que pueden incapacitar al piloto en menos de treinta segundos.

La prioridad es triple y simultánea: #strong[eliminar el combustible], #strong[limpiar la cabina de humo] y #strong[aterrizar de inmediato].

+ #strong[Motor:] corta el encendido, cierra las válvulas de combustible y desconecta el sistema eléctrico para eliminar posibles arcos que realimenten el fuego.
+ #strong[Ventilación:] si el humo no es denso, abre las tomas de aire de cabina para dirigir el flujo de humo hacia fuera. Si el humo es denso e irrespirable, considera desmontar la cúpula en vuelo para crear ventilación forzada.
+ #strong[Aterrizaje:] aterriza de inmediato en el campo más cercano. No intentes llegar al aeródromo si eso retrasa la toma en varios minutos. Un planeador con fuego activo no es un planeador seguro.

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

Familiarízate con la posición de las válvulas de combustible y el extintor de tu planeador motorizado antes del primer vuelo. Una emergencia de fuego no deja tiempo para buscar manuales ni para recordar dónde están los controles de emergencia. La memoria muscular se entrena en tierra, no en vuelo.

]
, 
title: 
[
Nota
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
== Fallos estructurales y de mandos
<fallos-estructurales-y-de-mandos>
=== Bloqueo o fallo de mandos
<bloqueo-o-fallo-de-mandos>
Un bloqueo parcial de mandos en vuelo ---por un objeto suelto en la cabina, una rotura interna o un fallo mecánico--- no implica necesariamente la pérdida de control total. Los planeadores modernos tienen superficies redundantes que pueden sustituirse parcialmente:

- #strong[Bloqueo de alerones:] el timón de dirección (pedal) provoca un alabeo secundario por #strong[efecto diedro] (#emph[dihedral effect]): al guiñar, el ala adelantada gana incidencia y genera más sustentación, lo que induce un alabeo que puede permitirte nivelar las alas y realizar un aterrizaje controlado. La respuesta es menor que con alerones, pero existe.
- #strong[Bloqueo de timón de profundidad:] el compensador de profundidad ---si el planeador lo tiene--- puede controlar el cabeceo. Ajusta la velocidad abriendo o cerrando aerofrenos.
- #strong[Bloqueo total de mandos:] si ninguna superficie responde y el vuelo no es controlable, el procedimiento es el abandono de la aeronave (ver Capítulo 8: Paracaídas de emergencia).

=== Flutter (vibración estructural)
<flutter-vibración-estructural>
El #strong[flutter] es una vibración aeroelástica autosustentada que se produce a altas velocidades, cuando la respuesta aerodinámica y la inercia estructural del ala o del timón entran en resonancia. No es un traqueteo suave: es una vibración explosiva que puede destruir la superficie afectada en cuestión de segundos.

Las causas más frecuentes son el exceso de velocidad ---superar la V#sub[NE] (Velocidad Nunca Exceder) o aproximarse a ella en vuelo descendente---, el daño estructural previo o el mal equilibrado de una superficie de control tras una reparación.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD: ]FLUTTER\*\*\*\*

Si experimentas una vibración fuerte y descontrolada, #strong[reduce la velocidad de inmediato]: sube el morro suavemente y abre los aerofrenos para frenar aerodinámicamente. El #emph[flutter] solo ocurre a altas velocidades y puede destruir el planeador en segundos. Nunca intentes aumentar la velocidad para «salir» de una vibración: es la acción exactamente contraria a lo que necesitas. Tras cualquier episodio de vibración anormal, el planeador debe ser inspeccionado por un técnico antes de volar de nuevo.

]
, 
title: 
[
Advertencia
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
=== Fallo de instrumentos de vuelo (Pitot o Estática)
<fallo-de-instrumentos-de-vuelo-pitot-o-estática>
El bloqueo de las tomas de presión de tu planeador (normalmente debido a agua de lluvia condensada, insectos o por haber olvidado retirar las fundas prevuelo) altera por completo las indicaciones del panel de instrumentos. Debes saber identificar qué toma está obstruida y cómo volar de forma segura sin referencias instrumentales fiables.

- #strong[Fallo del tubo de Pitot (presión total):]
- #strong[Síntoma:] el anemómetro cae a cero en vuelo nivelado, o bien se comporta de forma invertida, actuando como un altímetro (la velocidad indicada aumenta al subir y disminuye al descender).
- #strong[Técnica de vuelo:] vuela de forma puramente visual controlando la #strong[actitud de cabeceo] respecto al horizonte. Sintoniza el #strong[sonido del viento] alrededor de la cabina (abre ligeramente la ventanilla lateral de tormenta o las ventilaciones para familiarizarte con el tono correspondiente a la velocidad de planeo óptimo). Presta atención al #strong[tacto y resistencia de los mandos] (a menor velocidad, la palanca se siente más blanda y con menos respuesta).
- #strong[Fallo de las tomas de presión estática:]
- #strong[Síntoma:] el altímetro se congela en un valor fijo y el variómetro se queda a cero, sin responder a los ascensos o descensos. El anemómetro también dará indicaciones erróneas debido a la presión estática atrapada en las tuberías instrumentales.
- #strong[Técnica de vuelo:] si tu planeador dispone de una toma de #strong[presión estática alterna] en cabina, conéctala mediante la válvula correspondiente.

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

En caso de fallo instrumental completo en circuito de tráfico, confía plenamente en tu estimación visual del ángulo de planeo respecto al punto de toma. Mantén una actitud de morro conservadora, previene el pérdida asegurando una buena corriente de aire (sonido del viento consistente en cabina) y no intentes corregir visualmente basándote en un anemómetro que sabes bloqueado.

]
, 
title: 
[
Nota
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
=== Apertura involuntaria de la cúpula en vuelo
<apertura-involuntaria-de-la-cúpula-en-vuelo>
Si la cúpula de tu planeador no quedó correctamente pestillada en los chequeos prevuelo (lista #NormalTok("CB-SIFT-CBE");), puede abrirse repentinamente en vuelo debido a las fuerzas aerodinámicas o a las turbulencias. Esto suele ocurrir durante la fase de remolque o poco después de la suelta. El ruido del viento y el torbellino de aire repentino dentro de la cabina pueden provocar pánico e inducir al piloto a cometer errores graves.

El procedimiento de seguridad exige las siguientes acciones inmediatas:

+ #strong[Vuela el planeador primero (]Aviate#strong[):] tu prioridad absoluta es mantener el control de la aeronave. Ignora la cúpula por completo en los primeros segundos. #strong[No intentes cerrarla ni sujetarla] si estás a baja altura o en pleno viraje: perderías la atención al pilotaje y podrías inducir una actitud inusual o una pérdida. Tu planeador puede seguir volando perfectamente con la cúpula abierta.
+ #strong[Resiste el ruido y el torbellino:] el ruido será ensordecedor y habrá objetos sueltos volando en cabina, pero el planeador seguirá volando perfectamente. Si llevas gafas de sol y cinturones de seguridad bien ajustados, estarás seguro.
+ #strong[Establece una senda de planeo más pronunciada:] una cúpula abierta o parcialmente desprendida genera un #strong[incremento masivo de la resistencia aerodinámica] (#strong[drag]). Tu ángulo de planeo se deteriorará considerablemente. Para mantener la velocidad de seguridad, deberás adoptar una actitud de morro más baja (senda de aproximación más pronunciada y mayor tasa de descenso).
+ #strong[Planifica el aterrizaje:] si estás en el despegue, continúa el remolque estabilizado hasta una altura segura si es posible, o suelta y haz un circuito normal. Vuela un circuito de tráfico adaptado a una mayor tasa de descenso y aterriza en el aeródromo lo antes posible. Solo intenta cerrar la cúpula si estás a gran altura de seguridad, en vuelo coordinado y con una sola mano, sin dejar de pilotar.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Nunca dejes de pilotar para intentar sujetar o cerrar una cúpula que se abre en circuito o a baja altura. Muchos accidentes mortales se han producido porque el piloto soltó la palanca de mandos para agarrar la cúpula con ambas manos, entrando el planeador en pérdida y barrena incontrolada o levantando la cola del remolcador y estrellándolo contra el suelo. Deja que la cúpula flote o se desprenda si es necesario; ¡concéntrate únicamente en volar!

]
, 
title: 
[
Advertencia
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
=== Vaciado asimétrico del lastre de agua (#emph[asymmetrical water ballast])
<vaciado-asimétrico-del-lastre-de-agua-asymmetrical-water-ballast>
El uso de lastre de agua (#strong[water ballast]) en las alas mejora el rendimiento a altas velocidades en vuelo de travesía. Sin embargo, si al iniciar el vaciado (#strong[dumping]) una de las válvulas de las alas se bloquea o tiene fugas, el planeador sufrirá un vaciado asimétrico. Esto genera un desequilibrio de peso lateral considerable, con un ala mucho más pesada que la otra.

El piloto debe gestionar esta asimetría aplicando la siguiente técnica:

- #strong[Efecto en el control:] el planeador tenderá a alabear con fuerza hacia el lado del ala que conserva el agua. Necesitarás aplicar una presión constante y significativa de alerón y timón de dirección (mando cruzado continuo) para mantener las alas niveladas, lo que reduce la efectividad del control lateral restante.
- #strong[Velocidad de aproximación más alta:] incrementa tu velocidad de aproximación estándar en al menos #strong[15-20 km/h] por encima de la velocidad calculada para el circuito. La velocidad adicional es indispensable para que los alerones conserven la autoridad necesaria para contrarrestar la tendencia al alabeo del plano pesado, y para prevenir una pérdida de ala (#strong[tip stall]) en el ala cargada durante los virajes.
- #strong[Planificación del circuito:] evita virajes pronunciados (alabeo máximo de 15° a 20°). Realiza giros suaves y coordinados hacia el circuito de tráfico. Siempre que sea posible, planifica los virajes hacia el lado del ala ligera: virar hacia el lado del ala pesada dificulta la recuperación del alabeo.
- #strong[Aterrizaje con alas niveladas:] durante la recogida y la toma de tierra, tu objetivo prioritario es mantener las alas perfectamente niveladas en el momento del contacto. Toca primero con el tren principal y, una vez en el suelo, haz todo lo posible para evitar que el ala cargada de agua caiga y toque el terreno mientras el velero aún se desplaza a gran velocidad: provocaría un caballito (#strong[ground loop]) violento (#ref(<fig-06-cap07-lastre-asimetrico>, supplement: [Figura])).

#figure([
#box(image("imagenes/06-cap07-lastre-asimetrico.png"))
], caption: figure.caption(
position: bottom, 
[
Vaciado asimétrico del lastre: el ala cargada cae y exige mando cruzado sostenido
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap07-lastre-asimetrico>


#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Un ala cargada con decenas de litros de agua tiene una velocidad de pérdida muy superior al ala vacía. En caso de vaciado asimétrico, si permites que la velocidad caiga demasiado en el tramo final o en el viraje de base, el ala pesada entrará en pérdida de forma asimétrica y repentina, provocando una barrena (#strong[spin]) instantánea e irrecuperable a baja altura. Mantener la velocidad recomendada en circuito es tu defensa absoluta.

]
, 
title: 
[
Advertencia
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
⚖ #strong[NORMATIVA]

Las alturas de decisión que aparecen en este capítulo (150 y 200 m en torno; 70 y 150 m en remolque) y la escalera de decisión del aterrizaje fuera de campo son #strong[valores formativos de referencia], no cifras normativas: la cota crítica real de cada planeador la fijan su AFM y las instrucciones locales del campo (longitud de pista, obstáculos, viento habitual). Apréndelas como orden de magnitud y ajústalas a tu aeronave y a tu aeródromo con tu instructor.

]
, 
title: 
[
Importante
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
Como ficha de repaso rápido, esta tabla resume la respuesta inmediata a cada emergencia del capítulo (el detalle está en cada apartado):

#table(
  columns: (50%, 50%),
  align: (auto,auto,),
  table.header([Situación], [Acción inmediata],),
  table.hline(),
  [Rotura de cable (cualquier método)], [Baja el morro para recuperar velocidad; luego suelta y decide según la altura.],
  [Fallo de suelta / gancho atascado], [Sitúate bajo y a la izquierda del remolcador y alabea; nunca por encima (#strong[kiting]).],
  [Fuego a bordo], [Corta el circuito eléctrico o el combustible según el origen; aterriza cuanto antes.],
  [Bloqueo de mandos], [Sustituye el mando perdido (diedro con alabeo, cabeceo con trim + aerofrenos).],
  [Flutter], [Sube el morro y abre aerofrenos para frenar de inmediato; nunca aceleres.],
  [Fallo de pitot / estática], [Vuela por actitud visual y sonido del aire; ignora el instrumento afectado.],
  [Apertura de cúpula en vuelo], [Vuela primero el planeador; baja el morro; no intentes cerrarla si estás bajo.],
  [Vaciado asimétrico del lastre], [+15-20 km/h en circuito, virajes suaves hacia el ala ligera, alas niveladas al tocar.],
)
#strong[Resumen del Capítulo: Procedimientos de emergencia]

- #strong[Regla universal]: ante cualquier emergencia en el lanzamiento, lo primero siempre es #strong[bajar el morro] para recuperar velocidad y evitar la pérdida. Después, suelta el cable y decide.

- #strong[Rotura de cable según el método de lanzamiento]:

  - #strong[Torno (]winch#strong[)]:
  - #strong[\< 150 m]: aterriza recto por derecho. No intentes virar.
  - #strong[150 - 200 m]: circuito abreviado recortado adaptado al viento.
  - #strong[\> 200 m]: circuito de tráfico normal.
  - #strong[Avión (]aerotow#strong[)]:
  - #strong[\< 70 m]: aterriza recto por delante.
  - #strong[70 - 150 m]: retorno o circuito recortado (el viraje de retorno se inicia hacia el viento cruzado, con alabeo franco de unos 45°).
  - #strong[\> 150 m]: circuito abreviado o normal.

- #strong[«La maniobra imposible»]: intentar volver a pista a baja altura es letal. Si estás por debajo de la cota crítica (150 m en torno / 70 m en avión) y no hay pista, aterriza de frente.

- #strong[Fallo de gancho (aerotow)]: si no puedes soltar, sitúate #strong[bajo y a la izquierda] del remolcador y alabea para avisarle; nunca por encima, que le levantarías la cola (#strong[kiting]). Él soltará. Aterriza con el cable colgando planeando una final alta para librar vallas y obstáculos.

- \*\*\*\*Flutter\*\*\*\*: ante una vibración destructiva, #strong[sube el morro y abre los aerofrenos] para reducir la velocidad de inmediato. Nunca aceleres. Inspección obligatoria en tierra.

- #strong[Fallos de instrumentos]: con el pitot bloqueado, vuela por actitud visual de cabeceo y por el sonido del viento en cabina.

- #strong[Apertura de cúpula]: vuela el planeador primero (#strong[Aviate]). No intentes cerrarla si estás bajo. Baja el morro para contrarrestar el aumento de resistencia.

- #strong[Lastre asimétrico]: vuela 15-20 km/h más rápido en circuito para mantener la efectividad de los alerones y mantén las alas niveladas al tocar el suelo.

= Uso y aterrizaje con paracaídas de emergencia
<uso-y-aterrizaje-con-paracaídas-de-emergencia>
#quote(block: true)[
El #strong[paracaídas de emergencia] es el último recurso del piloto cuando el planeador ha dejado de ser un medio de transporte seguro. No es un equipo que se usa «por si acaso»: se usa cuando la alternativa es morir dentro de la aeronave. Entender cuándo la situación justifica el salto, cómo ejecutar la secuencia de abandono y cómo gestionar el descenso y la toma marcan la diferencia entre sobrevivir y no hacerlo. Además, este capítulo cubre el mantenimiento correcto del paracaídas: un equipo descuidado es un equipo que puede no abrirse.

En este capítulo aprenderás:

- #strong[La decisión de saltar]: en qué situaciones el abandono del planeador es la única opción correcta.
- #strong[La altura mínima de abandono]: por qué 150 metros es el umbral que no puede reducirse.
- #strong[El procedimiento de salto]: la secuencia exacta de cinco pasos para abandonar la cabina.
- #strong[El descenso y la toma de tierra]: cómo aterrizar con paracaídas, con viento y ante obstáculos.
- #strong[El mantenimiento del paracaídas]: cuidados, almacenamiento y caducidad de la inspección.
]

== La decisión de abandono (#emph[bail-out])
<la-decisión-de-abandono-bail-out>
El #strong[abandono del planeador] (#strong[bail-out]) es una decisión que se toma cuando el planeador ha dejado de ser controlable y ya no existe alternativa de aterrizaje seguro. Las situaciones que justifican el bail-out son:

- #strong[Fallo estructural:] rotura de un elemento portante ---ala, fuselaje, timón--- que hace al planeador ingobernable.
- #strong[Colisión en vuelo:] daños que impiden el vuelo controlado.
- #strong[Incendio irrefrenable:] fuego que no se extingue y hace la cabina inhabitable.
- #strong[Pérdida de control irrecuperable:] barrena (#strong[spin]) o espiral descontrolada de la que no es posible salir con los medios disponibles.

La clave psicológica del bail-out es entender que #strong[si el planeador aún vuela de forma controlada, el piloto debe quedarse dentro]. Un planeador con mandos parciales, un fallo de motor en un autolanzable o un vuelo degradado por engelamiento no justifican el salto: esas situaciones se gestionan buscando el aterrizaje más próximo. El paracaídas solo es la solución cuando el planeador ya no es una solución.

=== Altura mínima de abandono
<altura-mínima-de-abandono>
Se recomienda iniciar el abandono con un mínimo de #strong[150 metros] sobre el terreno. Esta cifra no es arbitraria:

- Un paracaídas de emergencia necesita entre 50 y 90 metros para abrirse completamente desde el momento en que se acciona la anilla.
- El proceso de abandono ---desmontar la cúpula, soltar cinturones, saltar y alejarse del planeador--- consume entre 5 y 10 segundos adicionales.
- Con 150 metros de altura disponibles y un proceso de abandono que consume los primeros 100 metros, quedan apenas 50 metros de margen de seguridad antes de tocar tierra.

Por debajo de 150 metros, el paracaídas puede no tener tiempo suficiente para abrirse completamente. Por encima de 500 metros, el salto ofrece un margen de seguridad mucho mayor.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

En una barrena o espiral descontrolada, las fuerzas G pueden ser muy elevadas ---hasta 3-4 G centrífugos--- y dificultar enormemente la salida de la cabina. Actúa con decisión y rapidez: cada segundo de demora es altura que se pierde. Si las fuerzas G te impiden moverte, aprovecha el instante de menor G al inicio de cada rotación para empujar la cúpula y saltar.

]
, 
title: 
[
Advertencia
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
== Procedimiento de salto
<procedimiento-de-salto>
La secuencia estándar para abandonar la cabina debe practicarse en tierra hasta convertirla en un acto reflejo. Los cinco pasos son (#ref(<fig-06-cap08-secuencia-salto>, supplement: [Figura])):

+ #strong[Desmontar la cúpula:] acciona la palanca de emergencia de la cúpula (normalmente roja o amarilla) y empújala hacia fuera con fuerza. La cúpula puede resistir por la presión dinámica del aire: empuja desde el borde de salida hacia adelante, no directamente hacia arriba.
+ #strong[Soltar los arneses:] abre la hebilla central de los cinturones de seguridad. En la mayoría de los planeadores modernos, una sola palanca libera todos los arneses simultáneamente.
+ #strong[Saltar:] salta hacia el #strong[lado interior de la rotación] si el planeador gira (donde la velocidad relativa es menor), o por el lateral más despejado de obstáculos. Empuja con fuerza para alejarte del fuselaje y, especialmente, de la cola del planeador: el estabilizador horizontal puede golpearte al saltar.
+ #strong[Separación del planeador:] cuenta «#strong[mil uno, mil dos, mil tres]» para asegurarte de estar completamente separado del planeador antes de abrir el paracaídas. Si el paracaídas se abre mientras todavía estás junto al planeador, la campana puede engancharse en la estructura.
+ #strong[Apertura del paracaídas:]

- #strong[Manual:] tira con fuerza de la anilla de apertura, la D metálica situada normalmente a la altura del pecho en el #strong[lado izquierdo] del arnés: se tira con la mano derecha, cruzando el brazo. Localízala en tu propio equipo antes de cada vuelo. No sueltes la anilla: guárdala en la mano para que no sea un proyectil si hay otra persona cerca.
- #strong[Automático (cinta estática):] el paracaídas se abre automáticamente cuando el cable de apertura unido al planeador alcanza su extensión máxima. No es necesario tirar de nada.

#figure([
#box(image("imagenes/06-cap08-secuencia-salto.jpg"))
], caption: figure.caption(
position: bottom, 
[
Secuencia de cinco pasos para el abandono del planeador
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap08-secuencia-salto>


#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Asegúrate de estar completamente separado del planeador antes de tirar de la anilla. Si la campana se abre junto al planeador, puede engancharse en el estabilizador, el fuselaje o las superficies de control, impidiendo una apertura completa.

]
, 
title: 
[
Advertencia
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
== Descenso y toma de tierra
<descenso-y-toma-de-tierra>
Una vez abierto el paracaídas, el piloto desciende a una velocidad vertical de aproximadamente 5-7 m/s ---equivalente a saltar al suelo desde una altura de 1,5 metros---. Es una toma de tierra que exige una preparación física y mental precisa para evitar lesiones.

=== Direccionamiento de la campana en el aire
<direccionamiento-de-la-campana-en-el-aire>
Muchos pilotos creen erróneamente que un paracaídas de emergencia redondo o cuadrado no ofrece ningún tipo de control. Aunque no permite un planeo controlado como una campana de salto deportivo, #strong[sí es posible girar la campana en el aire para orientarse cara al viento]:

- #strong[Técnica:] agarra con fuerza las líneas de suspensión traseras o las bandas de las hombreras (del arnés). Si tiras hacia abajo de la banda de la hombrera derecha, la campana girará hacia la derecha; si tiras de la izquierda, rotará a la izquierda.
- #strong[Aterrizar cara al viento:] utiliza esta capacidad de giro para orientarte de cara al viento dominante durante el descenso final. Al tomar tierra de cara al viento minimizas la velocidad horizontal sobre el suelo (deriva lateral), lo que reduce drásticamente la inercia del impacto y la probabilidad de sufrir fracturas o esguinces.

=== Posición de aterrizaje estándar
<posición-de-aterrizaje-estándar>
- Junta las piernas y mantén las rodillas ligeramente flexionadas.
- Mantén los pies paralelos y juntos, apuntando ligeramente hacia abajo.
- Al tocar el suelo, rueda inmediatamente hacia un lado para disipar la energía del impacto en cinco puntos sucesivos (pie, pantorrilla, muslo, cadera y hombro) en lo que en paracaidismo se conoce como el #strong[PLF] (#strong[Parachute Landing Fall]): la técnica de rodamiento de aterrizaje.

=== Viento fuerte y arrastre
<viento-fuerte-y-arrastre>
Con viento fuerte, el paracaídas continuará inflado y tirando tras la toma, pudiendo arrastrar al piloto por el suelo. Para colapsar la campana y detener el arrastre:

- #strong[Tira de los cordones inferiores:] agarra y tira con fuerza de las líneas de suspensión que están en contacto con el suelo (el borde trasero de la campana) para deshinchar el paracaídas e impedir que el aire vuelva a hincharlo.
- #strong[Sistema de suelta rápida:] si tu arnés dispone de hebillas de liberación rápida de la campana (#strong[canopy quick-release]), actívalas inmediatamente después del contacto con el suelo.

=== Aterrizaje con obstáculos
<aterrizaje-con-obstáculos>
- #strong[Árboles:] cruza las piernas con fuerza para proteger la ingle, y protege tu cara y cabeza con los brazos cruzados. Los árboles amortiguan el impacto, pero crean riesgo de heridas penetrantes por ramas.
- #strong[Agua:] prepara la suelta durante el descenso (localiza las hebillas y afloja lo que puedas sin comprometer la sujeción) y #strong[libera el arnés en el momento del contacto con el agua], no antes: la estimación visual de la altura sobre una superficie de agua es muy engañosa y soltar prematuramente puede significar una caída libre desde mucho más alto de lo que crees. Una vez en el agua, aléjate nadando de la campana empapada para no quedar atrapado bajo ella.
- #strong[Líneas eléctricas:] si vas a caer sobre una línea eléctrica, junta los pies y mantén brazos y piernas recogidos para minimizar el área de contacto, y sobre todo #strong[no puentees dos conductores a la vez] con el cuerpo, la campana o las cuerdas. No te confíes por tocar un solo cable: el contacto con un único conductor también es letal si existe un camino a tierra ---y con una campana y unas cuerdas húmedas rozando otro cable, la estructura o el suelo, ese camino casi siempre existe. La única defensa es minimizar el contacto y no crear un puente entre conductores.

== Inspección y mantenimiento del paracaídas
<inspección-y-mantenimiento-del-paracaídas>
El paracaídas es un equipo de supervivencia que requiere cuidados específicos y revisiones periódicas obligatorias. Un paracaídas mal mantenido puede simplemente no abrirse ---o abrirse de forma parcial--- en el momento crítico.

- #strong[Plegado y revisión periódica:] un técnico certificado debe plegarlo (#strong[packed]) y revisarlo con la periodicidad marcada en la tarjeta de inspección, normalmente cada #strong[6 o 12 meses según el fabricante], y siempre tras cada uso.
- #strong[Almacenamiento:] guárdalo siempre en un lugar seco y fresco, dentro de su bolsa de transporte. La humedad hace que los cordones y la tela se peguen entre sí, impidiendo una apertura limpia.
- #strong[Radiación UV:] evita la exposición directa al sol. La radiación UV degrada el nailon de la campana y los cordones, y reduce la resistencia a la tracción de forma progresiva e invisible.
- #strong[Sudor y contaminantes:] usa siempre una funda o cobertor de paracaídas durante el vuelo para protegerlo del sudor, el calor de la espalda y posibles derrames de combustible o aceite.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Nunca vueles con un paracaídas cuya tarjeta de inspección esté caducada, aunque sea por un solo día. Del mismo modo, si el paracaídas ha estado expuesto a humedad intensa, a productos químicos (gasolina, aceites, disolventes) o a cualquier impacto mecánico, debe ser inspeccionado por un técnico antes de volver a usarlo. La tarjeta de inspección en vigor no es una formalidad burocrática: es la única garantía objetiva de que el equipo funciona.

]
, 
title: 
[
Advertencia
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
#strong[Resumen del Capítulo: Paracaídas de emergencia]

- #strong[Cuándo saltar]: solo cuando el planeador es irrecuperable: fallo estructural, colisión en vuelo, fuego incontrolable o barrena irrecuperable. Si el planeador vuela de forma controlable, quédate dentro.
- #strong[Altura mínima]: 150 m AGL. Por debajo de esta cota, el paracaídas puede no tener tiempo suficiente para abrirse del todo.
- #strong[Secuencia de salto]: (1) desprender la cúpula, (2) soltar los arneses, (3) saltar alejándote de la cola por el interior del giro, (4) contar «mil uno, mil dos, mil tres», (5) tirar de la anilla (en paracaídas manuales).
- #strong[Descenso y toma de tierra]: gira la campana en el aire tirando de las bandas de las hombreras para #strong[aterrizar cara al viento] y reducir el impacto horizontal. Adopta la posición PLF (pies y rodillas juntos y flexionados) y rueda al tocar el suelo. Con viento, tira de los cordones inferiores para colapsar la campana.
- #strong[Mantenimiento]: plegado e inspección obligatorios cada 6-12 meses según el fabricante, por un técnico certificado. Protégelo de la radiación UV, la humedad y los contaminantes químicos. Es tu último recurso: cuídalo.

#show: appendices.with("Apéndices", hide-parent: true)
#heading(level: 1, numbering: none)[Apéndices]
= Syllabus Oficial EASA - Procedimientos Operativos
<syllabus-oficial-easa---procedimientos-operativos>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Procedimientos Operativos] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- 6.1. Requisitos generales.
- 6.2. Métodos de lanzamiento.
- 6.3. Técnicas de planeo.
- 6.4. Circuitos y aterrizaje.
- 6.5. Aterrizaje fuera de campo (Outlanding).
- 6.6. Procedimientos operativos especiales y peligros.
- 6.7. Procedimientos de emergencia.
- 6.8. Uso y aterrizaje con paracaídas de emergencia.

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

== Ponte a prueba
<ponte-a-prueba>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/06-procedimientos-operativos/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

= Glosario de términos
<glosario-de-términos>
Este glosario contiene las definiciones y acrónimos más relevantes de Procedimientos Operativos aplicables a la licencia de piloto de planeador (SPL).

/ \*\*\*\*Aerofrenos (Spoilers)\*\*\*\*: #block[
Superficies móviles situadas generalmente en el extradós alar, accionadas por el piloto, cuya función es destruir la sustentación y aumentar la resistencia aerodinámica para controlar la senda de aproximación. (Mencionado en: cap. 4)
]

/ \*\*\*\*Aerotow (Remolque por avión)\*\*\*\*: #block[
Método de lanzamiento en el que una aeronave a motor remolca al planeador mediante un cable flexible de longitud normalizada (generalmente entre 30 y 60 metros) hasta una altitud determinada. (Mencionado en: cap. 2)
]

/ \*\*\*\*Altura de decisión (Decision Height / DH)\*\*\*\*: #block[
Límite de altura preestablecido sobre el terreno por debajo del cual el piloto abandona la búsqueda de térmicas y se centra exclusivamente en el aterrizaje. En travesía se aplica como escalera: a 600 metros se elige la zona de aterrizaje, a 450 metros el campo definitivo y a 300 metros el piloto se compromete con el circuito. (Mencionado en: cap. 5)
]

/ \*\*\*\*Amerizaje (Ditching)\*\*\*\*: #block[
Aterrizaje forzoso y controlado de una aeronave terrestre sobre una superficie de agua. (Mencionado en: cap. 6)
]

/ \*\*\*\*Bail-out (Abandono del planeador)\*\*\*\*: #block[
Procedimiento de emergencia que consiste en el salto en paracaídas desde una aeronave en vuelo cuando esta ya no es controlable o segura. (Mencionado en: cap. 8)
]

/ \*\*\*\*Base (Tramo de base / Base leg)\*\*\*\*: #block[
Tramo del circuito de tráfico perpendicular a la prolongación del eje de la pista que conecta el tramo de viento en cola con el tramo final. (Mencionado en: cap. 4)
]

/ \*\*\*\*Cable flojo (Slack line)\*\*\*\*: #block[
Pérdida temporal de tensión en el cable de remolque durante el lanzamiento por avión, lo que puede provocar enredos o tirones violentos al tensarse de nuevo. (Mencionado en: cap. 2)
]

/ \*\*\*\*Circuito de tráfico (Circuito de aeródromo)\*\*\*\*: #block[
Trayectoria patrón y ordenada que describe una aeronave para realizar una aproximación y aterrizaje seguro. En planeadores consta típicamente de viento cruzado, viento en cola, base y final. (Mencionado en: cap. 4)
]

/ \*\*\*\*Engelamiento (Icing)\*\*\*\*: #block[
Formación y acumulación de hielo sobre la estructura del planeador (borde de ataque, cúpula o superficies de control) al volar a través de humedad visible con temperaturas bajo cero, degradando drásticamente el rendimiento aerodinámico y aumentando la velocidad de pérdida. (Mencionado en: cap. 6)
]

/ \*\*\*\*Estela turbulenta (Wake turbulence)\*\*\*\*: #block[
Turbulencia invisible y peligrosa (vórtices de punta de ala o flujo descendente de rotor) generada por el paso de aeronaves de gran masa o helicópteros en sustentación, que puede desestabilizar o dañar gravemente a un planeador que la atraviese. (Mencionado en: cap. 6)
]

/ \*\*\*\*Fallo de lanzamiento\*\*\*\*: #block[
Interrupción involuntaria de la tracción durante el despegue (por ejemplo, rotura de cable en torno o remolque, o fallo de motor del avión remolcador) que exige la ejecución inmediata del briefing de emergencia preestablecido. (Mencionado en: cap. 7)
]

/ \*\*\*\*Fallo de suelta (Towhook jam)\*\*\*\*: #block[
Emergencia en remolque por avión en la que la anilla de suelta del planeador no libera el cable al ser accionada. Exige señalizar la situación al remolcador (posición elevada y lateral con balanceo de alas) para que este libere el cable desde su extremo, y planificar una aproximación final más alta de lo habitual con el cable colgando para librar los obstáculos previos a la pista. (Mencionado en: cap. 7)
]

/ \*\*\*\*Final (Tramo final / Final approach leg)\*\*\*\*: #block[
Tramo alineado con el eje de la pista en el sentido del aterrizaje, desde el cual se gestiona el descenso mediante los aerofrenos hasta la toma y parada de la aeronave. (Mencionado en: cap. 4)
]

/ \*\*\*\*FLARM\*\*\*\*: #block[
Sistema electrónico de alerta de tráfico y prevención de colisiones de corto alcance diseñado especialmente para planeadores, que transmite la posición GPS tridimensional proyectada a otras aeronaves equipadas. (Mencionado en: cap. 6)
]

/ \*\*\*\*Flutter (Flameo aeroelástico)\*\*\*\*: #block[
Fenómeno físico de oscilaciones aeroelásticas autoexcitadas e inestables que afectan a las superficies sustentadoras o de control del planeador al superar la VNE, pudiendo destruir la estructura en segundos debido a la interacción del flujo de aire a alta velocidad con la flexibilidad estructural. (Mencionado en: cap. 7)
]

/ \*\*\*\*Fusible de seguridad (Weak link)\*\*\*\*: #block[
Eslabón o fusible metálico calibrado intercalado en el cable de remolque o torno, diseñado para romperse ante una sobretensión que supere los límites estructurales calculados antes de dañar al planeador o a la aeronave remolcadora. (Mencionado en: cap. 2)
]

/ \*\*\*\*IMSAFE\*\*\*\*: #block[
Acrónimo nemotécnico de autoevaluación psicofísica recomendado antes de cada vuelo: Illness (Enfermedad), Medication (Medicación), Stress (Estrés), Alcohol (Alcohol), Fatigue (Fatiga) y Eating (Alimentación). (Mencionado en: cap. 1)
]

/ \*\*\*\*Las 7 S\*\*\*\*: #block[
Regla nemotécnica utilizada para evaluar sistemáticamente la aptitud de un campo desde el aire en un aterrizaje fuera de campo: #strong[Size] (Tamaño), #strong[Shape] (Forma), #strong[Slope] (Pendiente), #strong[Surface] (Superficie), #strong[Surroundings] (Alrededores/Obstáculos), #strong[Stock] (Ganado/Animales) y #strong[Sun] (Posición del Sol). (Mencionado en: cap. 5)
]

/ \*\*\*\*Lastre de agua (Water ballast)\*\*\*\*: #block[
Agua cargada en tanques específicos situados en las alas para aumentar la masa del planeador y su carga alar, desplazando la curva polar de velocidades hacia valores más altos para volar más rápido con el mismo ángulo de planeo. (Mencionado en: cap. 3)
]

/ \*\*\*\*Outlanding (Aterrizaje fuera de campo / Toma fuera de campo)\*\*\*\*: #block[
Procedimiento operativo planificado y ejecutado de aterrizaje preventivo fuera de un aeródromo autorizado, realizado en campos abiertos o agrícolas aptos debido a la ausencia de ascendencias térmicas o pérdida de altura utilizable. (Mencionado en: cap. 5)
]

/ \*\*\*\*Paracaídas de emergencia\*\*\*\*: #block[
Dispositivo individual de salvamento de accionamiento manual que el piloto de planeador lleva integrado como respaldo obligatorio o recomendado en el cockpit. (Mencionado en: cap. 8)
]

/ \*\*\*\*PCC (Comprobación de mandos positiva / Positive Control Check)\*\*\*\*: #block[
Verificación obligatoria tras el montaje del planeador en la que un asistente sujeta físicamente cada superficie de mando en el exterior mientras el piloto acciona los controles en cabina para verificar la integridad y correcto sentido del movimiento. (Mencionado en: cap. 1)
]

/ \*\*\*\*PIC (Piloto al mando / Pilot in Command)\*\*\*\*: #block[
Piloto responsable directo del funcionamiento, operación y seguridad de la aeronave durante el tiempo de vuelo. (Mencionado en: cap. 1)
]

/ \*\*\*\*Resbale lateral (Sideslip)\*\*\*\*: #block[
Maniobra aerodinámica coordinada de forma cruzada (alerón a un lado, pedal al opuesto) por la cual se presenta el fuselaje de lado a la corriente libre, generando un incremento drástico de la resistencia aerodinámica que incrementa la tasa de descenso sin aumentar la velocidad. (Mencionado en: cap. 4)
]

/ \*\*\*\*Self-launch (Autolanzamiento)\*\*\*\*: #block[
Capacidad de despegue y ascenso autónomo del planeador utilizando una unidad de potencia auxiliar motora integrada en la estructura (motoveleros TMG o veleros de motor retráctil). (Mencionado en: cap. 2)
]

/ \*\*\*\*Térmica\*\*\*\*: #block[
Columna o burbuja de aire caliente ascendente que se origina por el calentamiento solar desigual de la superficie del terreno y que constituye la fuente de sustentación fundamental para el vuelo sin motor. (Mencionado en: cap. 3)
]

/ \*\*\*\*Torno (Lanzamiento por torno / Winch)\*\*\*\*: #block[
Método de lanzamiento en el que un planeador es acelerado a alta velocidad sobre la pista mediante el enrollado rápido de un cable por un motor potente estacionario en el extremo de la pista, elevándolo hasta la altura de suelta en un ascenso muy inclinado. (Mencionado en: cap. 2)
]

/ \*\*\*\*Viento en cola (Tramo de viento en cola / Downwind)\*\*\*\*: #block[
Tramo del circuito de tráfico aéreo paralelo a la pista activa realizado en sentido contrario a la dirección de aterrizaje, donde se ejecutan las comprobaciones previas al aterrizaje (lista FUSTALL). (Mencionado en: cap. 4)
]

/ \*\*\*\*Vuelo de ladera (Ridge soaring)\*\*\*\*: #block[
Técnica de planeo que consiste en volar aprovechando el viento dinámico ascendente desviado hacia arriba por el relieve de una montaña o cordillera en la cara de barlovento. (Mencionado en: cap. 3)
]

/ \*\*\*\*Vuelo de onda (Wave soaring)\*\*\*\*: #block[
Técnica de planeo que aprovecha el flujo ondulatorio estacionario y laminar (onda orográfica) que se genera a sotavento de un sistema montañoso en condiciones de fuerte viento estable, permitiendo alcanzar grandes altitudes en el lado ascendente de las ondas. (Mencionado en: cap. 3)
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
