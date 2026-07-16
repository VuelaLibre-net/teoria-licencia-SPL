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

#show terms.item: it => block(breakable: false, below: 0.85em, width: 100%)[
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
  title: [Factores Humanos],
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

#heading(level: 1, numbering: none)[Factores Humanos]
<factores-humanos>
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
#strong[#emph[Tema 2 de 9 del examen teórico para la Licencia de Piloto de Planeador (SPL)]]

El 90 % de los accidentes de vuelo a vela tienen un factor humano como causa principal. No es incompetencia: el ser humano tiene límites fisiológicos y psicológicos que no desaparecen cuando sube a un planeador. La fatiga que degrada la toma de decisiones. La presión de grupo que empuja a despegar cuando la decisión correcta es quedarse en tierra.

Cuatro bloques temáticos cubren desde el modelo SHELL hasta el chequeo IMSAFE: las herramientas que separan al piloto que gestiona sus límites del que los ignora.

El mayor riesgo en la cabina eres tú. Aprende a gestionarlo.

= Factores humanos: conceptos básicos
<factores-humanos-conceptos-básicos>
#quote(block: true)[
La técnica con los mandos no basta: la mayoría de los accidentes en vuelo a vela tienen una causa humana, y casi todos son evitables. Este capítulo te da el marco para entender por qué erramos y cómo interponer barreras antes de que el error llegue a consecuencias.

En este capítulo aprenderás:

- #strong[El modelo SHELL]: cómo interactúas con el software, el hardware, el entorno y las demás personas.
- #strong[El error humano y el queso suizo]: por qué errar es inevitable y cómo se alinean los fallos.
- #strong[La cadena del error]: por qué basta romper un eslabón para evitar el accidente.
- #strong[Las influencias en el comportamiento]: presión de grupo, cultura justa y la pirámide de Maslow.
]

== Introducción a los factores humanos y la seguridad en el vuelo
<introducción-a-los-factores-humanos-y-la-seguridad-en-el-vuelo>
El vuelo a vela exige la coordinación constante entre el piloto, la aeronave y un entorno en permanente cambio. Durante décadas, la formación de pilotos se centró casi exclusivamente en las habilidades de manejo de los mandos (#strong[stick and rudder skills]). La experiencia ha demostrado, sin embargo, que una técnica impecable no garantiza por sí sola la seguridad del vuelo. Aquí entran en juego los #strong[factores humanos].

La Organización de Aviación Civil Internacional (OACI (Organización de Aviación Civil Internacional)) define los factores humanos como los elementos medioambientales, organizativos, laborales y las características individuales que influyen en el comportamiento dentro del entorno aeronáutico, con efecto directo sobre la salud y la seguridad operacional. En términos prácticos, se trata de comprender cómo interactúa el piloto con la aeronave, los procedimientos, la meteorología y el resto de personas implicadas en la operación.

El piloto no es infalible. Existen limitaciones inherentes en la percepción, la memoria y la capacidad de procesar información compleja bajo presión. La disciplina de los factores humanos no pretende transformar al piloto en un agente sin errores, sino enseñarle a #strong[reconocer sus limitaciones fisiológicas y psicológicas], aceptarlas y aplicar estrategias contrastadas para gestionarlas en beneficio de la toma de decisiones aeronáuticas (#strong[Aeronautical Decision-Making], ADM).

== El factor humano en los accidentes de aviación
<el-factor-humano-en-los-accidentes-de-aviación>
A medida que la tecnología aeronáutica ha avanzado, la proporción de accidentes debidos a fallos mecánicos ha disminuido de forma significativa. Las estadísticas actuales reflejan que #strong[el factor humano es la causa principal o un elemento contribuyente en aproximadamente el 90 % de los accidentes en la aviación general y el vuelo a vela]. Este dato es, ante todo, pedagógico: la inmensa mayoría de estos accidentes son previsibles y, por tanto, #strong[evitables].

El desglose del componente humano en la siniestralidad del vuelo a vela muestra las siguientes proporciones habituales:

- #strong[Toma de decisiones inadecuada (aprox. 40 %):] Factor predominante. Incluye continuar el vuelo hacia condiciones meteorológicas adversas o posponer en exceso la búsqueda de un aterrizaje fuera de campo.
- #strong[Errores de pilotaje (aprox. 30 %):] Fallos en la técnica de vuelo o en el manejo de los mandos, con frecuencia relacionados con estados de distracción.
- #strong[Preparación deficiente antes del vuelo (aprox. 12 %):] Omisiones críticas durante el montaje o la verificación previa al despegue, como no conectar correctamente los mandos o no asegurar la cabina.
- #strong[Conciencia situacional insuficiente (aprox. 6 %):] Pérdida de percepción espacial o visual del tránsito, con riesgo de colisión en vuelo (#strong[mid-air collision]).

#block[
#callout(
body: 
[
El análisis del Informe de Seguridad de EASA (European Union Aviation Safety Agency) indica que las fases más críticas del vuelo en planeador son el aterrizaje (aproximadamente el 50 % de los accidentes) y el despegue (21 %). Mantenga el máximo nivel de atención durante estos periodos, con la cabina libre de distracciones y todos los sistemas verificados.

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
Los accidentes con consecuencias fatales (hasta un 26 % según datos de EASA (European Union Aviation Safety Agency)) tienen como causa principal la pérdida de control en vuelo, que con frecuencia deriva en pérdida aerodinámica y barrena (#strong[stall and spin]), especialmente peligrosas a baja altura en el circuito de tráfico. Otras causas graves incluyen las colisiones contra el terreno (17 %) y las emergencias mal gestionadas en lanzamientos a torno incompletos (10 %).

Conocer estas estadísticas permite al piloto priorizar la atención en las fases y situaciones de mayor riesgo, y adoptar criterios de decisión más conservadores donde la experiencia demuestra que los márgenes son más estrechos.

== Modelos conceptuales: el modelo SHELL
<modelos-conceptuales-el-modelo-shell>
El vuelo a vela no ocurre en el vacío; es una actividad donde el ser humano interactúa constantemente con su entorno. Para comprender esta interacción, la OACI utiliza el #strong[Modelo SHELL], un marco conceptual desarrollado originariamente por el psicólogo Elwyn Edwards en 1972 (como modelo SHEL) y refinado después por Frank Hawkins, que añadió la segunda L de las otras personas. Su nombre es un acrónimo de sus componentes, que encajan entre sí como las piezas de un rompecabezas con el factor humano siempre en el centro (#ref(<fig-02-cap01-modelo-shell>, supplement: [Figura])):

- #strong[Software (S):] Los elementos no materiales. Incluye la reglamentación aplicable, manuales de vuelo, procedimientos normativos, listas de chequeo (#strong[checklists]) y la simbología aeronáutica.
- #strong[Hardware (H):] La máquina. Abarca el propio velero, los instrumentos de a bordo y cualquier otra herramienta o equipo físico.
- #strong[Environment (E):] El entorno donde se opera. Implica tanto las condiciones externas (meteorología, visibilidad, turbulencia) como las internas de la cabina (ruido, temperatura, ergonomía).
- #strong[Liveware (L - otras personas):] Las personas con las que interactúas en el desarrollo del vuelo, como tu instructor, personal de pista, controladores u otros pilotos.
- #strong[Liveware (L - yo central):] Tú, el piloto al mando (#strong[Pilot in Command]). Se refiere a tus capacidades físicas y cognitivas, nivel de entrenamiento, experiencia, así como tu estado de fatiga o estrés.

#figure([
#box(image("imagenes/02-cap01-modelo-shell.png"))
], caption: figure.caption(
position: bottom, 
[
El Modelo SHELL de factores humanos
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap01-modelo-shell>


La clave de la seguridad radica en las interfaces de contacto entre tu «yo central» y el resto de los bloques. Si estas piezas no encajan de forma perfecta (por ejemplo, si la interfaz #strong[Liveware-Environment] es deficiente debido a interferencias de radio que dificultan la comunicación), se abrirá una puerta al error humano.

== El error humano: tipos y el modelo del queso suizo
<el-error-humano-tipos-y-el-modelo-del-queso-suizo>
Según James Reason, el error humano es cualquier desviación de una secuencia de acciones físicas o mentales que impide lograr el resultado deseado. La filosofía de seguridad aeronáutica moderna asume que #strong[errar es humano e inevitable]: el objetivo no es eliminar los errores por completo ---algo que no es posible---, sino detectarlos temprano e interponer barreras defensivas antes de que generen consecuencias.

James Reason ilustró este proceso con el #strong[modelo del queso suizo]: cada capa del sistema de seguridad (instrucción, procedimientos, listas de verificación, supervisión) actúa como una barrera con agujeros. Cuando los agujeros de todas las capas se alinean, el accidente se produce (#ref(<fig-02-cap01-queso-suizo>, supplement: [Figura])).

#figure([
#box(image("imagenes/02-cap01-queso-suizo.png"))
], caption: figure.caption(
position: bottom, 
[
El modelo del queso suizo de James Reason
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap01-queso-suizo>


Los fallos del piloto se clasifican en dos categorías según la intención del acto:

- #strong[Error:] Desviación involuntaria. El piloto falla sin pretenderlo, por falta de atención o por aplicar una técnica incorrecta.
- #strong[Violación:] Incumplimiento deliberado de una norma o procedimiento. Cuando se repite sin consecuencias, genera falsa confianza y normaliza la conducta de riesgo.

Según el momento en que se manifiestan respecto al accidente, los errores se distinguen en:

- #strong[Errores latentes:] Vulnerabilidades preexistentes en el sistema, como una instrucción inicial deficiente o un procedimiento inadecuado que favorece el fallo.
- #strong[Errores activos:] La equivocación inmediata que precipita la cadena del accidente, como intentar un viraje a baja velocidad y baja altura.

#block[
#callout(
body: 
[
Para reducir la probabilidad de error, utilice las listas de verificación aunque conozca el procedimiento de memoria, solicite la evaluación del instructor con regularidad y esté atento a factores que degradan el rendimiento, como la fatiga o la complacencia derivada de la experiencia acumulada.

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
== Prevención y mitigación del error
<prevención-y-mitigación-del-error>
Los accidentes rara vez tienen una causa única. La mayoría resultan de una sucesión de decisiones erróneas, condiciones previas y errores latentes que, alineados, forman la #strong[cadena del error] (#ref(<fig-02-cap01-cadena-error>, supplement: [Figura])). El modelo del queso suizo, descrito en la sección anterior, representa gráficamente este proceso.

La consecuencia práctica más importante es que #strong[basta con interrumpir un solo eslabón de la cadena para prevenir el accidente]. Una decisión conservadora, una verificación adicional o rechazar el vuelo ante una duda razonable son suficientes para detener el proceso antes de que derive en consecuencias.

#figure([
#box(image("imagenes/02-cap01-cadena-error.jpg"))
], caption: figure.caption(
position: bottom, 
[
Romper un eslabón de la cadena del error salva el vuelo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap01-cadena-error>


#block[
#callout(
body: 
[
#strong[Romper un solo eslabón salva el vuelo.] Ante cualquier señal de que la cadena del error ha comenzado ---condiciones meteorológicas que se deterioran, una avería sin resolver, fatiga elevada--- adopte la medida más conservadora disponible. Es la acción más eficaz al alcance del piloto.

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
== Influencias en el comportamiento humano
<influencias-en-el-comportamiento-humano>
El vuelo a vela tiene una fuerte dimensión social. El piloto opera en un entorno donde las interacciones con el club, la escuela, los instructores y los compañeros condicionan continuamente sus decisiones. Identificar estas influencias es el primer paso para neutralizar su efecto sobre la seguridad operacional.

=== El entorno social y la presión de los compañeros
<el-entorno-social-y-la-presión-de-los-compañeros>
En un aeródromo, una de las formas de influencia más comunes es la presión de los compañeros (#strong[peer pressure]). Cuando la mayoría de los pilotos del club decide despegar a pesar de un viento cruzado marginal o un pronóstico desfavorable, surge una presión implícita para no quedar al margen del grupo. Reconocer cuándo una decisión de vuelo se basa en la opinión ajena y no en el propio criterio técnico es fundamental. La firma en el libro del planeador es personal e intransferible: la responsabilidad de la decisión recae exclusivamente en el piloto al mando.

=== Cultura organizacional y cultura justa
<cultura-organizacional-y-cultura-justa>
La forma en que un club gestiona los errores define su #strong[cultura organizacional]. La respuesta histórica de la aviación al error fue punitiva: quien cometía un fallo era sancionado o reprendido. Lejos de mejorar la seguridad, ese enfoque incentivó el encubrimiento: los daños no se reportaban por temor al castigo y acababan produciendo accidentes en vuelos posteriores.

En la actualidad se promueve activamente la #strong[cultura justa] (#strong[Just Culture]): un marco que reconoce la inevitabilidad del error no intencionado y lo trata como una oportunidad de aprendizaje colectivo, sin represalias, siempre que no medie negligencia deliberada ni violación consciente de procedimientos.

#block[
#callout(
body: 
[
Fomente la cultura justa en su entorno inmediato. Si durante el remolque o guardado del planeador se produce un daño accidental ---por ejemplo, un golpe en el estabilizador al entrar al hangar--- notifíquelo de inmediato al instructor o mecánico responsable. Encubrirlo pone en riesgo al piloto que vuele esa aeronave a continuación sin conocer el daño preexistente.

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
=== Motivación y desempeño: la pirámide de Maslow
<motivación-y-desempeño-la-pirámide-de-maslow>
El rendimiento del piloto está estrechamente vinculado a su motivación y equilibrio psicológico. Abraham Maslow definió una jerarquía de necesidades humanas que va desde las más básicas ---salud, alimentación, seguridad física--- hasta las de orden superior ---reconocimiento, logro personal, autorrealización---. Esta jerarquía tiene una aplicación directa en el contexto aeronáutico.

Cuando la motivación por alcanzar un objetivo ---batir una marca personal, ganar una competición--- supera el nivel básico de seguridad, el piloto puede asumir riesgos injustificados: continuar hacia condiciones meteorológicas adversas, sobrevolar zonas sin alternativa de aterrizaje o ignorar señales de alarma. Del mismo modo, operar bajo un estado emocional negativo intenso ---estrés, conflicto personal o preocupación económica grave--- reduce la capacidad de atención y favorece la negligencia en las fases críticas del vuelo.

La conclusión práctica es clara: la seguridad ocupa la base de la pirámide y no puede subordinarse a ningún objetivo de orden superior (#ref(<fig-02-cap01-piramide-maslow>, supplement: [Figura])).

#figure([
#box(image("imagenes/02-cap01-piramide-maslow.png"))
], caption: figure.caption(
position: bottom, 
[
La pirámide de Maslow aplicada a un piloto de planeadores
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap01-piramide-maslow>


#strong[Resumen del Capítulo: Conceptos básicos de Factores Humanos]

- #strong[Modelo SHELL]: Marco conceptual fundamental que analiza la interacción entre el piloto (Liveware) y otros elementos: Software (procedimientos), Hardware (la aeronave), Environment (el entorno) y otro Liveware (otras personas).
- #strong[Gestión del error]: Se asume que el error humano es inevitable. El objetivo de la seguridad no es eliminarlo por completo, sino detectarlo a tiempo y gestionar sus consecuencias antes de que afecten a la seguridad del vuelo.
- #strong[Cadena del error]: Los accidentes rara vez ocurren por una sola causa. Son la suma de pequeños errores y condiciones latentes. Tu trabajo es romper esa cadena en cuanto detectes el primer eslabón.
- #strong[Influencias en el comportamiento]: El comportamiento mental bajo presión, nuestra motivación diaria aplicada al vuelo frente a una base de necesidades insatisfechas (Pirámide de Maslow), así como la presión directa de compañeros de hangar, alteran profundamente nuestra capacidad mental como comandantes. Debemos respaldar una rigurosa "cultura justa" para permitir el libre reporte de errores técnicos sin represión ajena, aprendiendo en colectivo en lugar de esconder daños fatales.

= Fisiología aeronáutica básica y mantenimiento de salud
<fisiología-aeronáutica-básica-y-mantenimiento-de-salud>
#quote(block: true)[
Este capítulo aborda cómo el entorno del vuelo afecta al organismo humano y los determinantes de la condición física del piloto de planeador. Repasaremos su impacto en los sentidos, el desgaste provocado por la altitud y las directrices normativas innegociables para preservar la seguridad operacional antes de situarse a los mandos.
]

== Aptitud para el vuelo y la evaluación personal (lista de chequeo IMSAFE)
<aptitud-para-el-vuelo-y-la-evaluación-personal-lista-de-chequeo-imsafe>
Como piloto de planeador, el estado de salud física y mental es el componente más crítico para la seguridad del vuelo. La normativa europea establece claramente que un piloto debe abstenerse de volar si está incapacitado por cualquier causa, como una lesión, enfermedad, medicación, fatiga o los efectos de cualquier sustancia psicoactiva, o si simplemente se siente indispuesto.

#block[
#callout(
body: 
[
Es obligatorio consultar con un Médico Examinador Aéreo (AME) o médico general si se ha sufrido una lesión importante, cirugía, inicio de medicación regular, embarazo, o uso por primera vez de lentes correctoras. Estas situaciones requieren una nueva evaluación de la aptitud médica; el piloto debe abstenerse de volar al mando hasta que se resuelva la causa y recupere la condición apta (#strong[MED.A.020 Decrease in medical fitness]).

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
Para ayudar a evaluar sistemáticamente la condición individual antes de acceder a la cabina, la aviación ha estandarizado una lista de chequeo personal conocida por el acrónimo mnemotécnico #strong[IMSAFE] (del inglés "I am safe" - #strong[Estoy a salvo]). Esta revisión es tan vital como la propia inspección prevuelo del planeador (#ref(<fig-02-cap02-imsafe-checklist>, supplement: [Figura])):

#figure([
#box(image("imagenes/02-cap02-imsafe.jpg"))
], caption: figure.caption(
position: bottom, 
[
Evaluación personal del piloto antes del vuelo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap02-imsafe-checklist>


- #strong[I - #emph[Illness] (Enfermedad):] ¿Tiene algún síntoma actual? Incluso un resfriado puede agravarse con los cambios de presión en vuelo (disbarismos) y mermar la capacidad de atención. No vuele si presenta fiebre o proceso vírico.
- #strong[M - #emph[Medication] (Medicación):] ¿Está tomando algún fármaco, con o sin receta? Muchos medicamentos de venta libre, como los antihistamínicos para la alergia, producen somnolencia y alteran el rendimiento cognitivo y motor.
- #strong[S - #emph[Stress] (Estrés):] ¿Existe alguna presión psicológica o emocional relevante? Problemas laborales, familiares o financieros graves reducen los recursos cognitivos disponibles, afectando la capacidad de juicio y el rendimiento en la cabina.
- #strong[A - #emph[Alcohol] (Alcohol):] ¿Ha consumido alcohol recientemente? Sus efectos residuales persisten mucho después de la ingesta. La norma en aviación es «de la botella al mando» (#strong[bottle to throttle]): se requiere un margen mínimo de 8 horas desde la última copa.
- #strong[F - #emph[Fatigue] (Fatiga):] ¿Ha descansado y dormido lo suficiente? La fatiga reduce el estado de alerta, la capacidad de decisión y los tiempos de reacción de forma significativa.
- #strong[E - #emph[Eating] (Alimentación):] ¿Ha comido y bebido adecuadamente en las últimas horas? Volar en ayunas reduce los niveles de glucosa y merma la concentración. En jornadas largas, la hidratación es tan importante como la alimentación; beba agua con regularidad para prevenir la deshidratación y el golpe de calor.

#block[
#callout(
body: 
[
Antes de cada vuelo, repase mentalmente la lista #strong[IMSAFE]. Si alguno de sus elementos resulta desfavorable, la única decisión de seguridad es cancelar el vuelo (#strong[NO-GO]).

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
== El sistema sensorial y la orientación
<el-sistema-sensorial-y-la-orientación>
=== La visión
<la-visión>
La visión es el sentido más importante para el piloto de planeador. Dado que nuestra evolución nos ha adaptado a movernos en dos dimensiones sobre el suelo, volar en un entorno tridimensional presenta desafíos únicos para nuestra percepción.

==== Anatomía visual básica
<anatomía-visual-básica>
El interior del ojo funciona de forma similar al sensor de una cámara de fotos. La luz entra y se proyecta sobre la #strong[retina], que contiene dos tipos principales de células fotorreceptoras:

- #strong[Conos:] Funcionan bien con buena iluminación. Nos permiten ver los detalles finos en el centro de nuestro campo visual y distinguir los colores (visión diurna).
- #strong[Bastones:] Se sitúan principalmente en la zona periférica de la retina. No distinguen colores, pero son muy sensibles a la luz tenue y excelentes para detectar el movimiento lateral (visión nocturna y periférica).

Existe un "punto ciego" anatómico en el lugar donde el nervio óptico se conecta con la retina, por lo que una imagen proyectada exactamente en esa pequeña área no será visible. Además, factores como la miopía, el exceso de sol, el tabaco o la fatiga reducen significativamente la agudeza visual.

#block[
#callout(
body: 
[
Una percepción correcta de los colores es obligatoria. Durante el reconocimiento médico inicial deberá superar pruebas como el test de Ishihara. Si no demuestra discriminación de color segura, la licencia de piloto de planeador ---regida por la normativa Part-SFCL--- quedará restringida al vuelo diurno (#strong[Day] VFR).

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
==== Técnicas de escaneo visual
<técnicas-de-escaneo-visual>
El método principal para prevenir colisiones en vuelo visual es la técnica de "Ver y Evitar" (#strong[See and Avoid]). Un buen piloto dedica más del 95% de su tiempo a mirar fuera de la cabina, limitando la consulta de los instrumentos a vistazos rápidos de 2 a 4 segundos.

Para escanear el cielo de forma eficaz, utiliza el método del reloj (#ref(<fig-02-cap02-escaneo-visual>, supplement: [Figura])):

+ Considere el morro del planeador como las #strong[12 en punto].
+ Realiza barridos visuales estructurados por sectores, desde las #strong[9] hasta las #strong[3].
+ Concéntrate especialmente en la franja de cielo más cercana a la línea del horizonte, ya que las aeronaves que vuelan a la misma altitud aparecerán mayoritariamente en esa zona.

#figure([
#box(image("imagenes/02-cap02-escaneo-visual.jpg"))
], caption: figure.caption(
position: bottom, 
[
Patrón de escaneo visual mediante el método horario
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap02-escaneo-visual>


#block[
#callout(
body: 
[
Antes de iniciar un viraje (por ejemplo, a la derecha), acostúmbrese a mirar brevemente hacia atrás por el lado exterior opuesto. Esto asegura que no haya tráfico acercándose por el ángulo muerto antes de inclinar las alas e iniciar el giro.

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
El riesgo más grave de colisión en vuelo libre se produce en trayectorias frontales, habituales en vuelos de ladera o calles de nubes. Al aproximarse de frente, el otro planeador carece de movimiento lateral apreciable en el campo visual y simplemente aumenta de tamaño de forma repentina. Un piloto necesita al menos 3 segundos para reaccionar y ejecutar una maniobra evasiva, que deberá realizarse preferentemente #strong[virando hacia la derecha].

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
==== Visión nocturna e ilusiones ópticas aeronáuticas
<visión-nocturna-e-ilusiones-ópticas-aeronáuticas>
La capacidad visual humana se degrada con la escasez luminosa y la disminución de oxígeno. A partir de altitudes relativamente bajas (6.000 pies), la cantidad de oxígeno en sangre se reduce lo suficiente como para afectar al funcionamiento de los bastones periféricos en vuelos con poca luz, limitando prematuramente la agudeza visual.

Por otro lado, la falta de texturas y contornos fiables en la oscuridad, en entornos nevados o sobre el agua facilita la aparición de peligrosas ilusiones en el cerebro del piloto:

- #strong[Aproximación de agujero negro (Black Hole Approach):] Al realizar el tramo final hacia una pista iluminada rodeada de terreno muy oscuro y sin referencias luminosas laterales (como un lago), el cerebro pierde la percepción real de profundidad. La ilusión lleva a creer que vuelas más alto de lo real y que la senda es más empinada de lo normal. Esto genera el impulso de picar el morro para «corregirla», con riesgo de impacto antes del umbral. La medida correctiva es mantener la velocidad indicada por el anemómetro e ignorar la sensación hasta recuperar referencias visuales de textura en tierra.
- #strong[Ilusión autocinética:] Al fijar la mirada sobre una luz aislada en la oscuridad durante varios segundos, los micromovimientos involuntarios del ojo producen la falsa percepción de que la luz se desplaza. Esto puede confundir al piloto respecto a si se trata de otra aeronave en movimiento. El remedio es mantener el escaneo visual activo, evitando fijar la vista en un foco único durante más de unos pocos segundos.

#figure([
#box(image("imagenes/02-cap02-ilusiones-opticas.png"))
], caption: figure.caption(
position: bottom, 
[
Ilusiones ópticas
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap02-ilusiones-opticas>


=== El oído y el sistema vestibular
<el-oído-y-el-sistema-vestibular>
Los disbarismos son una serie de alteraciones orgánicas secundarias a la expansión y contracción de los diminutos volúmenes de gas atrapados en el interior del cuerpo humano como consecuencia del cambio externo en la presión barométrica, cumpliendo rigurosamente la #strong[Ley de Boyle].

Al emprender un ascenso con el planeador, la presión atmosférica decae. El aire atrapado se expande buscando salir. Esto afecta sustancialmente tres regiones de la anatomía:

+ #strong[Oído medio:] El conducto que iguala la presión con el exterior es la trompa de Eustaquio. En subida, el aire en expansión suele escapar por ella sin gran esfuerzo, incluso con algo de congestión. El problema serio llega en el #strong[descenso]: con la trompa inflamada por un resfriado, el aire no consigue volver a entrar, el tímpano se deforma hacia dentro y aparece un dolor intolerable, la #strong[barotitis media].
+ #strong[Senos paranasales:] Al igual que en los oídos, la obstrucción temporal originará un intenso dolor neurálgico en la zona de las cejas o maxilares.
+ #strong[Tracto gastrointestinal y caries:] La ingestión de alimentos productores de gas antes de un vuelo desembocará en molestos retortijones en altura, de igual modo que una pequeña burbuja atrapada bajo un empaste dental puede ocasionar en ascenso un dantesco dolor de muelas "barodóntico".

#block[
#callout(
body: 
[
La congestión de vías altas (catarros, rinitis alérgicas fuertes) es una causa automática de auto-exclusión para volar (#strong[No-Go]). El atroz dolor del barotrauma provocado en un descenso anulará por completo la capacidad para gobernar con seguridad el planeador.

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
== Desorientación espacial e ilusiones sensoriales
<desorientación-espacial-e-ilusiones-sensoriales>
Durante un vuelo térmico bajo las nubes, la orientación precisa requiere integrar tres fuentes de información: la visión, el sistema propioceptivo (señales de músculos y tendones) y, de forma fundamental, el #strong[sistema vestibular] del oído interno, encargado de percibir la aceleración.

Los sentidos humanos evolucionaron para el movimiento bidimensional sobre el terreno bajo una gravedad constante. Al volar sin referencias visuales fiables del horizonte, el cerebro es susceptible de generar ilusiones que producen #strong[desorientación espacial]: una falsa apreciación de la posición u orientación real en el espacio.

- #strong[Ilusiones vestibulares:] Un viraje prolongado y estable en térmica puede engañar a los canales semicirculares, induciendo la percepción de que el planeador está nivelado o virando apenas (ilusión de estabilidad). En sentido contrario, la turbulencia severa puede impulsar al piloto a tirar bruscamente de la palanca cuando el avión se mantiene de hecho en actitud normal.
- #strong[Ilusiones ópticas:] Una perspectiva de aproximación inclinada, la falta de texturas en el suelo (nieve, agua) o una pista significativamente más ancha o estrecha que la habitual pueden producir sesgos perceptivos en la estimación de la altitud sobre el umbral.

#block[
#callout(
body: 
[
Cuando se pierde la referencia del horizonte y lo que el piloto «siente» contradice lo que señalan los instrumentos, debe ignorar el instinto. #strong[Confíe en los instrumentos] (anemómetro, hilo de lana, bola y horizonte artificial) y actúe en consecuencia.

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
== Cinetosis (motion sickness o mareo)
<cinetosis-motion-sickness-o-mareo>
La cinetosis (#strong[motion sickness]), o mareo en vuelo, es una reacción fisiológica que se produce cuando el cerebro recibe señales contradictorias de los distintos sentidos. En la cabina de un planeador, el malestar suele aparecer cuando lo que perciben los ojos no coincide con lo que el sistema vestibular del oído interno registra en cuanto a aceleraciones y giros.

Un caso típico: el piloto vira sostenidamente en una térmica y agacha la cabeza para programar el ordenador de vuelo. Los ojos, fijos en la pantalla estática, indican que no hay movimiento; pero el laberinto del oído interno continúa detectando variaciones de fuerza G y movimiento rotatorio. Este conflicto sensorial desencadena una respuesta de malestar que puede progresar hacia fatiga repentina, palidez, sudoración fría, náuseas y vómitos.

#block[
#callout(
body: 
[
El mareo puede afectar incluso a pilotos curtidos, especialmente tras períodos de inactividad o en condiciones de turbulencia severa. No es motivo de vergüenza: asúmalo con naturalidad y lleve siempre a bordo, al alcance de la mano, bolsas de mareo.

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
#box(image("imagenes/02-cap02-cinetosis-fijacion.jpg"))
], caption: figure.caption(
position: bottom, 
[
La fijación visual en el horizonte exterior previene la cinetosis (el mareo)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap02-cinetosis-fijacion>


Para prevenir y gestionar el fantasma del mareo en vuelo, interioriza y aplica en cabina las siguientes medidas (#ref(<fig-02-cap02-cinetosis-fijacion>, supplement: [Figura])):

- #strong[La mirada al horizonte:] El remedio más eficaz es la referencia visual exterior. Ante los primeros síntomas de malestar, levante la barbilla, busque el horizonte natural y fije la vista en un punto lejano. Evite mirar los instrumentos o leer documentos en la rodillera.
- #strong[Reducción del movimiento:] Limite los movimientos bruscos de cabeza. Las aceleraciones negativas prolongadas incrementan la susceptibilidad al mareo; evite transiciones de actitud extremas sin necesidad.
- #strong[Vuelos con pasajeros:] Con pasajeros sin experiencia a bordo, sea prudente. Limite los vuelos de familiarización a unos 30 minutos y realice virajes suaves para evitar una experiencia aérea desagradable.
- #strong[Hidratación:] La deshidratación en una cabina calentada por el sol bajo el plexiglás agrava el malestar. Lleve agua suficiente, beba con regularidad e incremente la ventilación facial para acceder a aire fresco.

#block[
#callout(
body: 
[
No ingiera fármacos antihistamínicos contra el mareo (como la #strong[Biodramina]) antes de pilotar. Su formulación está contraindicada en aviación: producen somnolencia profunda que compromete gravemente los tiempos de reacción y el estado de alerta necesarios para la seguridad del vuelo.

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
Si a pesar de las precauciones la cinetosis resulta limitante bajo los mandos, la prioridad es la seguridad. En bipuesto, transfiera los mandos al piloto calificado a bordo anunciando «#strong[tienes los mandos]» o «#strong[tuyo]». En monoplaza, estabilice el planeador en vuelo recto y nivelado para reducir el conflicto sensorial del oído interno, abra la ventilación al máximo y abrevié la misión buscando aterrizaje inmediato.

== Intoxicación por monóxido de carbono (riesgos en motoveleros o remolcadores)
<intoxicación-por-monóxido-de-carbono-riesgos-en-motoveleros-o-remolcadores>
Aunque el velero puro carece de motor, una parte significativa de la flota actual está compuesta por motoveleros (#strong[Touring Motor Gliders], TMG) o planeadores con motor retráctil. En estas aeronaves, al encender la calefacción de cabina ---que suele extraer calor directamente del tubo de escape--- existe riesgo de #strong[intoxicación por monóxido de carbono (CO)]. Durante la fase de despegue en remolque, también pueden inhalarse gases de escape del avión remolcador.

El monóxido de carbono es inodoro, incoloro e insípido. Su afinidad por la hemoglobina es unas 200 veces superior a la del oxígeno: al inhalarlo, se une a la hemoglobina e impide el transporte de O₂ al cerebro, produciendo #strong[hipoxia anémica] sin necesidad de estar a gran altitud. Como referencia habitual en la literatura aeromédica, fumar unos pocos cigarrillos antes del vuelo eleva la saturación de CO en hemoglobina hasta un nivel que degrada la visión nocturna de forma equivalente a volar ya a varios miles de pies, aun a cota baja. (Las cifras exactas varían según la fuente y el número de cigarrillos; el mensaje operativo ---fumar antes de volar recorta tu visión nocturna--- no cambia.)

Los síntomas iniciales son inespecíficos: dolor de cabeza o debilidad muscular leve que progresa rápidamente hacia náuseas, desorientación, visión borrosa y euforia inapropiada. Sin intervención, desemboca en pérdida de consciencia.

#block[
#callout(
body: 
[
En motoveleros, lleve instalado un detector de monóxido de carbono en el panel y verifique su fecha de caducidad. Ante cualquier síntoma (dolor de cabeza, labios de color rojo intenso) o si el parche cambia de color, actúe de inmediato: #strong[corte la calefacción], abra la ventilación al máximo, utilice oxígeno suplementario si dispone de él y aterrice sin dilación.

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
== Hipotermia y frío en altitud
<hipotermia-y-frío-en-altitud>
El vuelo a vela implica, con frecuencia, alcanzar grandes altitudes. Recuerde que el gradiente térmico de la atmósfera estándar reduce la temperatura exterior a razón de unos 2 °C por cada 1.000 ft. A 4.000 m se pueden registrar --20 °C, y en las proximidades de la tropopausa, valores de --50 °C o inferiores.

La posición de pilotaje semirreclinada y la escasa actividad muscular favorecen la aparición de #strong[hipotermia] (temperatura corporal central inferior a 35 °C). Además, la irradiación solar directa puede crear una sensación de confort térmico en el tronco, mientras los pies y piernas, en la sombra del panel frontal, quedan expuestos a temperaturas muy bajas con riesgo de congelación.

Los síntomas hipotérmicos comienzan con temblores musculares, y progresan hacia letargo, confusión mental y alteraciones del habla. El riesgo adicional es que el frío reduce la capacidad del piloto para percibir su propio deterioro. Las bajas temperaturas también pueden inutilizar las baterías de los instrumentos electrónicos ---incluido el regulador de oxígeno--- complicando una situación ya de por sí delicada.

#block[
#callout(
body: 
[
Para volar en onda invernal, abríguese siempre #strong[por capas]. Evite tajantemente el calzado o calcetines que aprieten excesivamente; el pie inmovilizado sobre los pedales necesita un flujo sanguíneo sin restricciones para no congelarse. Elija botas lo suficientemente holgadas, suelas térmicas y guantes que permitan plena libertad de movimiento sobre la palanca de mandos.

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
== Estrés fisiológico y sus efectos
<estrés-fisiológico-y-sus-efectos>
El estrés en la cabina no siempre es un enemigo. En su justa medida, un nivel moderado de tensión ---como el que se siente justo antes del despegue en una competición o al afrontar tu primer vuelo de ladera--- resulta positivo y necesario. Activa el sistema nervioso, eleva el nivel de alerta y afina la capacidad de reacción, llevándole al punto de rendimiento máximo.

Conviene distinguir dos marcos complementarios, porque describen cosas distintas. El primero, la #strong[curva de Yerkes-Dodson], relaciona el nivel de activación con el rendimiento: en forma de U invertida, muy poca tensión da un piloto apático y demasiada, uno bloqueado; el máximo está en el punto medio (#ref(<fig-02-cap02-curva-estres>, supplement: [Figura])).

#figure([
#box(image("imagenes/02-cap02-curva-estres.png"))
], caption: figure.caption(
position: bottom, 
[
Relación entre el nivel de activación y el rendimiento del piloto (curva de Yerkes-Dodson)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap02-curva-estres>


El segundo marco, el #strong[Síndrome General de Adaptación] de Hans Selye, describe cómo responde el organismo cuando la tensión se prolonga, atravesando tres fases consecutivas:

+ #strong[Fase de alarma (reacción):] Ante un elemento novedoso o una amenaza abrupta, el cuerpo libera adrenalina de golpe. El ritmo cardíaco y respiratorio se disparan, las pupilas se dilatan y el cerebro entra en estado de máxima alerta preparándose para reaccionar o huir.
+ #strong[Fase de resistencia (adaptación):] Si el factor estresante no desaparece a los pocos minutos (por ejemplo, lidiando con descendencias fuertes sistemáticas y lejos de un campo aterriceble seguro), el cuerpo intenta amoldarse y mantener la compostura mediante un esfuerzo fisiológico activo para regularse.
+ #strong[Fase de agotamiento:] Cuando la situación supera al piloto en intensidad o duración, las reservas de energía de la fase dos se vacían. El agotamiento entra en escena, provocando un deterioro rápido y catastrófico de la capacidad analítica y merma en la pericia a los mandos.

=== Hiperventilación
<hiperventilación>
Una de las manifestaciones físicas del estrés agudo ---no de una falta real de oxígeno--- es la #strong[hiperventilación]: una respiración excesivamente rápida y profunda desencadenada por la ansiedad.

Esta respiración acelerada elimina grandes cantidades de dióxido de carbono (CO₂) de la sangre, aumentando su pH (alcalosis respiratoria). Paradojicamente, aunque los pulmones mueven más aire, la falta de CO₂ impide que la hemoglobina libere el oxígeno en los tejidos cerebrales.

Los #strong[síntomas] son característicos: hormigueo y entumecimiento en manos y pies, calambres alrededor de la boca, palpitaciones, náuseas, palidez y una sensación de asfixia a pesar de estar respirando. Sin intervención, puede derivar en somnolencia y pérdida de consciencia.

El tratamiento inmediato consiste en reducir conscientemente el ritmo respiratorio. Hablar o cantar en voz alta regula el ciclo ventilatorio; también puede ser útil aguantar la respiración unos segundos para restaurar los niveles de CO₂ en sangre.

=== Exceso de confianza, presión y toma de decisiones
<exceso-de-confianza-presión-y-toma-de-decisiones>
El estrés prolongado tiene efectos corrosivos sobre la seguridad: puede generar #strong[exceso de confianza] o anular el análisis crítico. La presión ---ganar una manga, seguir a un piloto más experimentado, o el simple deseo de llegar a destino--- induce a asumir riesgos que, en tierra, consideraría inaceptables. Evalúe sus capacidades con rigor y honestidad. Los mejores pilotos de competición tienen un rasgo en común: son exigentes con la revisión crítica de sus propias decisiones tras el aterrizaje.

#block[
#callout(
body: 
[
Para mantener el estrés dentro del rango operativo de seguridad, es vital #strong[evitar la suma de numerosas "primeras veces"] en un mismo despegue. Volar un modelo de velero totalmente nuevo para ti, despegando en remolque desde un aeródromo que no conoces y encarando un día de un vendaval racheado cruzado es una convergencia explosiva de factores inéditos. La mente sobrepasará la fase de alarma directamente al pánico. Intente siempre que la progresión añada estas variables de una en una.

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
== Fatiga (aguda y crónica) y su impacto en el rendimiento
<fatiga-aguda-y-crónica-y-su-impacto-en-el-rendimiento>
Si el estrés agudo es una amenaza inmediata, la fatiga es un factor crónico que deteriora el rendimiento mental y físico antes de que aparezcan signos evidentes como el bostezo.

La fatiga degrada de forma global las capacidades del piloto: reduce la capacidad analítica, entorpece el razonamiento, ralentiza la toma de decisiones, empeora el tiempo de reacción y disminuye la atención sostenida necesaria para detectar otros tráficos.

Conviene tener presente que volar tras un día laboral agotador afecta al circuito de llegada del mismo modo que hacerlo con déficit de sueño. Un error habitual es subestimar el papel de los ritmos circadianos en el rendimiento del piloto.

#block[
#callout(
body: 
[
#strong[La fatiga solo se cura durmiendo.] El café y las bebidas energéticas enmascaran temporalmente los síntomas, pero no restauran las capacidades cognitivas. Si la fatiga afecta a la atención o el razonamiento, la decisión es #strong[NO-GO] (cancelación del vuelo).

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
== Deshidratación, golpe de calor y exposición al sol
<deshidratación-golpe-de-calor-y-exposición-al-sol>
La cúpula de plexiglás actúa como un invernadero durante los meses de verano. Al volar en térmica, con ropa de vuelo y el paracaídas a la espalda, la temperatura en cabina puede elevarse considerablemente.

Bajo estas condiciones, y con una tasa respiratoria mayor por la altitud, el cuerpo se refrigera sudando de forma intensa. Es habitual perder entre 1 y 3 litros de agua por hora sin percibirse apenas.

Una deshidratación progresiva espesa la sangre y perjudica la circulación. Los primeros síntomas son dolor de cabeza y fatiga creciente. Si el proceso continúa, aparecen calambres musculares y, en casos graves, un #strong[golpe de calor] que puede producir taquicardia y pérdida de consciencia (#strong[black out]) sobre los mandos.

#block[
#callout(
body: 
[
El mecanismo biológico de la #strong[sed] tiene un imperdonable retraso biológico. Cuando siente la boca seca, la deshidratación ya ha mermado el rendimiento cognitivo. Además, el agua que se beba en la cabina tardará unos 20 minutos en hidratar el flujo sanguíneo de forma efectiva. #strong[Adelántese bebiendo de forma regular durante todo el vuelo; nunca espere a tener sed].

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
== Efectos del alcohol, drogas, automedicación y dopaje
<efectos-del-alcohol-drogas-automedicación-y-dopaje>
La normativa aeronáutica prohíbe volar bajo los efectos de sustancias psicoactivas. La seguridad en la cabina exige que el juicio y los reflejos del piloto operen sin ninguna merma.

=== La regla «de la botella al mando»
<la-regla-de-la-botella-al-mando>
El alcohol es el depresor del sistema nervioso central más extendido. Sus efectos sobre el tiempo de reacción se agravan en altitud por la menor oxigenación en sangre (hipoxia hipobárica).

#block[
#callout(
body: 
[
#strong[AMC1 SAO.GEN.130(f)] (ED Decision 2019/001/R) concreta la regla «de la botella al mando» (#strong[bottle to throttle]) para las tripulaciones de planeador: nada de alcohol en las #strong[8 horas previas] al vuelo, y una alcoholemia al inicio del vuelo que no supere #strong[0,2 g/l] ---o el límite nacional, si es más estricto.

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
Circula la idea de que en España se exige «cero alcohol» para volar. No es así: #strong[España no ha fijado un límite nacional más estricto] ---así lo indica el propio material de AESA sobre las pruebas de alcoholemia en rampa, cuyo formulario recoge «Límite Nacional Reglamentario (no definido en España)»---, de modo que se aplica el umbral de 0,2 g/l de la norma EASA. No lo confundas con el tráfico rodado. Dicho esto, ese 0,2 g/l es un límite legal, no un objetivo: la única práctica segura es subirte al planeador sin nada de alcohol en el cuerpo.

=== Automedicación, antihistamínicos y analgésicos
<automedicación-antihistamínicos-y-analgésicos>
Dejando a un lado las drogas ilegales, que invalidan automáticamente el certificado médico EASA, el mayor peligro oculto en la aviación general es la #strong[automedicación].

Medicamentos de venta libre ---como los #strong[antihistamínicos] para la alergia estacional o las pastillas contra el mareo--- resultan incompatibles con el vuelo. Estas sustancias enlentecen los reflejos y producen somnolencia que el piloto a menudo no percibe como tal.

#strong[La regla básica es sencilla: si el prospecto del medicamento desaconseja conducir vehículos o manejar maquinaria pesada, está totalmente prohibido volar bajo sus efectos].

=== Dopaje y autorización terapéutica (AUT)
<dopaje-y-autorización-terapéutica-aut>
El vuelo a vela de competición está regulado internacionalmente y se somete a controles estrictos regidos por la #strong[Agencia Mundial Antidopaje (WADA)] al igual que cualquier otro deporte de alto rendimiento.

#block[
#callout(
body: 
[
Para volar en campeonatos bajo un tratamiento médico sin arriesgarte a una descalificación (hay controles al aterrizar), debes justificar la medicación tramitando previamente una #strong[Autorización de Uso Terapéutico (AUT / TUE)]. Este documento oficial eximirá al competidor de sanciones en controles antidopaje deportivos.

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
#strong[Resumen del capítulo: Fisiología aeronáutica]

- #strong[Aptitud IMSAFE:] Revise el estado con la lista #strong[Illness], #strong[Medication], #strong[Stress], #strong[Alcohol], #strong[Fatigue], #strong[Eating] antes del despegue. Ante dudas, cancele el vuelo (#strong[NO-GO]). Si concurren problemas médicos importantes, consulte a un médico examinador aéreo (AME).
- #strong[Disbarismos:] Los gases corporales se expanden al ascender. No vuele nunca con resfriados o congestión nasal; el dolor en los tímpanos y senos paranasales por el cambio de presión le incapacitará para pilotar.
- #strong[Ilusiones sensoriales:] El oído interno engañará cuando se pierdan las referencias visuales exteriores. Si existe desorientación sin un horizonte claro, ignore las sensaciones y confíe ciegamente en los instrumentos.
- #strong[Monóxido de carbono (CO):] Gas letal, inodoro, incoloro e insípido que solo puede detectarse con un detector específico. Es un peligro real en motoveleros (TMG) por los gases del motor y el sistema de calefacción de cabina. Ante el menor síntoma o aviso del detector, corte la calefacción, abra la ventilación y aterrice inmediatamente.
- #strong[Hipotermia:] La inactividad en la cabina y el frío en altitud robarán el calor rápidamente, minando los reflejos y lucidez. Vuele siempre con ropa de abrigo puesta por capas y evita el calzado apretado para no limitar la circulación.
- #strong[Estrés e hiperventilación:] El pánico puede hacer jadear al implicado sin control, alterando el nivel de dióxido de carbono en la sangre, provocando entumecimiento y ceguera. Para frenarlo, ralentice conscientemente la respiración prolongando la exhalación, hable en voz alta o cante para regularse.
- #strong[Deshidratación:] La cabina cerrada es un invernadero y se pierden líquidos rápidamente. Cuando siente sed, ya tiene un déficit que merma las capacidades cognitivas. Beba agua regularmente desde el despegue para anticiparse a los dolores de cabeza o a un mortal golpe de calor.
- #strong[Fatiga:] El cansancio bloquea el tiempo de reacción y nubla la toma de decisiones. El café o una bebida no previenen sus efectos ocultos sobre la atención. La fatiga solo se cura de una manera: durmiendo para dar pie al necesario descanso reparador.
- #strong[Normativa EASA, medicación y alcohol:] La regla no tiene excepciones: #strong[«de la botella al mando»], 8 horas sin alcohol y alcoholemia inferior a 0,2 g/l (AMC1 SAO.GEN.130(f)). No se automedique; hasta las inocentes pastillas de la alergia o del mareo adormecen de forma incapacitante para volar.

= Psicología aeronáutica básica
<psicología-aeronáutica-básica>
#quote(block: true)[
Volar bien es, sobre todo, decidir bien. Este capítulo trata el instrumento que de verdad pilota el planeador ---tu mente---: cómo procesa la información, cómo decide bajo presión y qué actitudes y trampas psicológicas conviene reconocer en uno mismo.

En este capítulo aprenderás:

- #strong[El procesamiento de la información]: percepción, atención y los tipos de memoria.
- #strong[La conciencia situacional]: qué es y qué la degrada.
- #strong[La toma de decisiones (ADM)]: el modelo DECIDE y la gestión de riesgos con PAVE.
- #strong[Las cinco actitudes peligrosas] y sus antídotos.
- #strong[La carga de trabajo y el SRM]: visión de túnel, sobrecarga y gestión de recursos del piloto solo.
]

== Procesamiento de la información: atención, memoria y percepción
<procesamiento-de-la-información-atención-memoria-y-percepción>
Para operar un planeador de forma segura, el cerebro del piloto procesa información continuamente mediante tres mecanismos entrelazados: percepción, atención y memoria.

#strong[La percepción] es la capacidad de interpretar los elementos ambientales y los cambios en las variables de vuelo (variación del viento, proximidad del terreno). A diferencia del entorno en tierra, el entorno aéreo carece de las referencias habituales de profundidad y tamaño. Esto hace que interpretar las distancias sea más exigente, y un exceso de información, sin las señales habituales, puede provocar una sobrecarga cualitativa.

#strong[La atención] es el filtro que permite centrarse en la información relevante de la cabina y el entorno exterior. La atención no es inagotable; puede verse erosionada rápidamente por factores biológicos o psicológicos, impidiendo percibir el cuadro completo de la situación.

#strong[La memoria], localizada de forma clave en el hipocampo, permite codificar, almacenar y recuperar información vital. En la cabina se utilizan distintos sistemas (#ref(<fig-02-cap03-memoria-tipos>, supplement: [Figura])):

- #strong[Memoria sensorial:] Retiene información por apenas 200 milisegundos tras percibirla por los sentidos.
- #strong[Memoria a corto plazo:] Dura unos 30 segundos; es la «memoria RAM» del piloto, esencial para interactuar con el entorno táctico inmediato.
- #strong[Memoria a largo plazo:] Es el almacén de conocimiento a largo plazo. Se divide en no declarativa (procedimental o inconsciente, como el tacto mecánico de la palanca) y declarativa (explícita, combinando la memoria episódica con la memoria semántica, como las velocidades del manual o experiencias pasadas).

#figure([
#box(image("imagenes/02-cap03-memoria-tipos.jpg"))
], caption: figure.caption(
position: bottom, 
[
Diagrama de los tipos de memoria humana.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap03-memoria-tipos>


== Conciencia situacional (#strong[Situational Awareness]) y factores que la reducen
<conciencia-situacional-situational-awareness-y-factores-que-la-reducen>
La conciencia situacional (#strong[Situational Awareness]) es la percepción y asimilación adecuada de los elementos del entorno en un volumen de tiempo y espacio, la comprensión analítica de su significado y, fundamentalmente, la proyección de su estado o ubicación en el futuro más próximo.

En la cabina del planeador, esto implica construir y mantener durante el vuelo una imagen mental precisa de lo que ocurre: la variación y tendencia del viento, la posición real frente al campo de aterrizaje, la ocupación del circuito de tráfico, las condiciones del resto de las aeronaves y las variables propias de altitud y energía.

#block[
#callout(
body: 
[
La pérdida de la conciencia situacional suele ser el eslabón inicial en la mayoría de las cadenas de accidentes en el vuelo a vela. Una sobrecarga cualitativa de la atención, el pánico derivado de un fenómeno no comprendido, la fatiga o la incomodidad en un asiento mal ajustado erosionan drásticamente la capacidad de asimilar el cuadro informativo completo que define una situación de vuelo segura.

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
== Toma de decisiones aeronáuticas (#strong[Aeronautical Decision-Making] --- ADM)
<toma-de-decisiones-aeronáuticas-aeronautical-decision-making-adm>
La Toma de Decisiones Aeronáuticas (ADM, por las siglas de #strong[Aeronautical Decision Making]) es el proceso mental, sistemático y repetible, empleado por el piloto para decantarse por el mejor camino de acción posible como respuesta a unas circunstancias dadas en la cabina del planeador.

Durante un vuelo en térmica o en el trayecto final del aterrizaje, el piloto interactúa con el entorno evaluando escenarios y peligros, definiendo planes, gestionando el nivel de riesgo y obrando en consecuencia. Uno de los esquemas estructurales más aceptados en la aviación civil para entrenar y modelar la ADM de manera natural es el #strong[modelo DECIDE] (#ref(<fig-02-cap03-decide>, supplement: [Figura])):

- #strong[D]etectar errores que requieren solución o un cambio que solicita atención.
- #strong[E]studiar y recopilar activamente toda la información del evento suscitado.
- #strong[C]onsiderar la mejor opción o todas las vías posibles para resolver el potencial peligro.
- #strong[I]mplementar de manera metódica, rápida o pausada, la mejor opción.
- #strong[D]eterminar objetivamente cuáles serían los resultados del proceso o de la decisión tomada.
- #strong[E]valuar lo aprendido, valorando si el curso forjado corrige el desvío, y comunicar las conclusiones.

#figure([
#box(image("imagenes/02-cap03-decide.jpg"))
], caption: figure.caption(
position: bottom, 
[
Modelo DECIDE para la toma de decisiones aeronáuticas
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap03-decide>


== Gestión de riesgos y modelos de evaluación (modelo PAVE)
<gestión-de-riesgos-y-modelos-de-evaluación-modelo-pave>
La gestión de riesgos es el escudo que protege tu proceso de toma de decisiones. Todo vuelo entraña ciertos peligros; tu misión no es evitarlos todos (algo imposible), sino identificarlos, evaluarlos y mitigarlos de manera sistemática.

El #strong[modelo PAVE] divide los riesgos del vuelo en cuatro elementos fundamentales y fácilmente evaluables:

- #strong[P (Piloto):] Estado fisiológico y psicológico. ¿Está el piloto descansado? ¿Sufre fatiga o estrés? ¿Cumple los requisitos de experiencia reciente?
- #strong[A (Aeronave):] Estado del planeador. ¿Es el equipo adecuado para el vuelo previsto? ¿Están los instrumentos operativos y las revisiones vigentes?
- #strong[V (enVironment --- Entorno):] Meteorología, aeródromos de alternativa, orografía, densidad de tráfico y espacio aéreo.
- #strong[E (Presiones externas u Operación):] Factores como la necesidad de finalizar un curso, la presión de no decepcionar a un pasajero o la urgencia ante una ventana meteorológica en cierre.

#block[
#callout(
body: 
[
Desglosar mentalmente tu vuelo usando PAVE antes del despegue te permite detectar y cortar la cadena de errores antes de sentarte en la cabina.

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
== Reconocimiento y mitigación de actitudes peligrosas
<reconocimiento-y-mitigación-de-actitudes-peligrosas>
Tus actitudes (la predisposición motivacional hacia tu entorno) marcan cómo reaccionas ante los riesgos. En la instrucción aeronáutica se identifican clásicamente cinco actitudes peligrosas que debes saber reconocer y neutralizar en ti mismo.

=== Antiautoridad (#strong[anti-authority])
<antiautoridad-anti-authority>
"No me digan lo que tengo que hacer" o simple indisciplina. Un piloto con antiautoridad rechaza los estándares establecidos, las normas o los consejos de instructores veteranos por considerarlos innecesarios o excesivos.

#strong[Antídoto:] Sigue las reglas imperativas; generalmente tienen detrás un rastro de sangre. Cumplir la norma es el factor de seguridad más básico.

=== Impulsividad (#strong[impulsivity])
<impulsividad-impulsivity>
"Tengo que hacer algo, y tiene que ser ya mismo". Ante un problema, el piloto siente una presión acuciante por actuar inmediatamente sin pararse a pensar en las consecuencias.

#strong[Antídoto:] Salvo contadas emergencias extremas, tómate un segundo para aplicar el modelo DECIDE. "No tan deprisa, piensa primero".

=== Invulnerabilidad (#strong[invulnerability])
<invulnerabilidad-invulnerability>
"A mí no me va a pasar". El piloto es consciente de la existencia de riesgos, pero se siente mágicamente protegido o ajeno a que un accidente pueda ocurrirle a él.

#strong[Antídoto:] Los accidentes le ocurren a cualquiera que exponga su aeronave a una situación donde no existe margen de seguridad. "Podría pasarme a mí".

=== Arrogancia o exceso de confianza (#emph[Macho])
<arrogancia-o-exceso-de-confianza-macho>
"Yo sí que puedo hacerlo". El piloto trata de impresionar para demostrar su supuesto mayor nivel de pericia buscando rizos o saltándose directrices, en un exceso de confianza sobre su pilotaje. Bravuconería.

#strong[Antídoto:] Aceptar tus limitaciones operativas es la mayor muestra de #strong[airmanship], de buen aviador. Correr riesgos innecesarios es un rasgo de inmadurez.

=== Resignación (#strong[resignation])
<resignación-resignation>
"¿De qué sirve? Todo está perdido". Ante la adversidad o la complejidad de una pérdida en ruta, el piloto cree que no tiene control sobre la situación y abandona el pilotaje para convertirse en un mero pasajero de la tragedia. A veces se entrelaza con una complacencia ciega frente a problemas menores.

#strong[Antídoto:] Nunca dejes de volar la aeronave. Siempre hay alguna acción que puede mejorar la situación, confía en tu entrenamiento. "Yo no tengo por qué rendirme, puedo cambiar esto".

== Gestión de la carga de trabajo y el estrés psicológico en vuelo
<gestión-de-la-carga-de-trabajo-y-el-estrés-psicológico-en-vuelo>
El estrés es la respuesta biológica no específica con la que el cuerpo humano reacciona ante cualquier demanda física, ambiental o psicológica que se le impone. En la aviación, actúa como un sistema arcaico de alarma que nos advierte de un posible peligro.

A diferencia del imaginario popular, no todo el estrés es perjudicial. Un nivel de estrés moderado (como el que sufres la primera vez que sales en monomando) es altamente positivo: aumenta tu nivel de alerta, agudiza tus sentidos y optimiza tu velocidad de reacción, llevándote a tu punto máximo de rendimiento.

Sin embargo, si la presión psicológica continúa aumentando (por ejemplo, te metes inadvertidamente en condiciones instrumentales severas ignorando tus límites), este estrés tolerable se transforma rápidamente en pánico. El rendimiento cae en picado y el piloto sufre una intensa saturación sensorial. El cerebro, incapaz de procesar el abrumador cuadro informativo de la cabina, se bloquea y focaliza absolutamente toda su atención residual en un solo detalle del vuelo (a menudo el más insignificante), anulando cualquier otra entrada visual o cognitiva sensata. A este fenómeno letal se le denomina informalmente #strong[visión de túnel] (#ref(<fig-02-cap03-vision-tunel>, supplement: [Figura])).

#block[
#callout(
body: 
[
Bajo condiciones de estrés extremo y pánico, instintos básicos de supervivencia como intentar "alejarse del suelo tirando fuertemente de la palanca" pueden superar tu raciocinio. Esta maniobra instintiva y abrupta a baja altura gastará toda la energía de tu planeador, precipitándote irremediablemente a una pérdida de control o barrena irrecuperable. Conoce tus límites y no te metas en escenarios para los que no estás sobradamente preparado.

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
#box(image("imagenes/02-cap03-vision-tunel.jpg"))
], caption: figure.caption(
position: bottom, 
[
Esquema conceptual de la visión de túnel bajo estrés extremo.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap03-vision-tunel>


Todo lo que se hace en el aire queda regido por un ciclo continuo conocido como el modelo de las «3 P»: #strong[Percibir, Procesar y Actuar] (#strong[Perform]). Cada segundo en vuelo, el piloto percibe información del entorno, la procesa cognitivamente y actúa en consecuencia.

La capacidad de la mente humana para procesar simultáneamente esta incesante catarata de eventos es esencialmente finita; es como un vaso de agua que solo puede admitir cierto volumen. Durante un remolque turbulento, de espaldas al sol, tratando de ubicar a otro velero que notifica en base, el vaso cognitivo puede desbordarse estrepitosamente. A esto se le conoce como #strong[sobrecarga cualitativa]. Cuando la complejidad de la tarea de vuelo escala superando el rendimiento y el entrenamiento del piloto en ese lapso preciso, el margen de seguridad desaparece y el accidente latente ocupa su lugar.

#block[
#callout(
body: 
[
Cuando notes que tu vaso se está desbordando, detente un segundo, respira, y reduce la carga mental simplificando radicalmente tus prioridades según el antiguo adagio de la aviación: #strong[Aviate, Navigate, Communicate] (Primero vuela el avión con seguridad, luego preocúpate de hacia dónde, y, por último y de ser estrictamente necesario, coge la radio para contarlo).

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
== Gestión de recursos para pilotos solos (#strong[Single-Pilot Resource Management] --- SRM)
<gestión-de-recursos-para-pilotos-solos-single-pilot-resource-management-srm>
El SRM es el arte de gestionar hábilmente todos los recursos a bordo y fuera del planeador (información, equipos, y ayudas humanas) antes y durante el vuelo, garantizando una operación segura del piloto en solitario.

A diferencia del vuelo con tripulación múltiple donde las tareas se delegan, el piloto de planeador gestiona integralmente el vuelo operando como único nodo de decisión. Tu trabajo exige emplear todos los elementos disponibles para no exceder tu capacidad de procesamiento. Los recursos del SRM incluyen tu propio equipo (instrumentación, compensador de abordo), las comunicaciones de radio (consultas al ATC o información meteorológica), y herramientas en tierra (un buen prevuelo o un instructor en radio).

#block[
#callout(
body: 
[
Es preferible anticiparse en tierra que reaccionar en el aire. Evitar enfrentarse a muchas situaciones nuevas simultáneamente (un velero nuevo en un aeródromo desconocido y con mal tiempo) es la mayor muestra de que sabes gestionar tus recursos usando como base el sentido común.

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
== Complacencia y falta de disciplina operativa
<complacencia-y-falta-de-disciplina-operativa>
Dos de los peores y más insidiosos enemigos relacionados con las actitudes peligrosas son la complacencia y la indisciplina operativa.

#strong[La complacencia] nace de una falsa sensación de seguridad generada por la excesiva rutina y la familiaridad del entorno. Pensamientos como "he aterrizado aquí miles de veces" llevan a obviar la lista de comprobación prevuelo o a desatender la vigilancia del tráfico. Aunque tu nivel de destreza sea excelente, no bajes nunca la guardia.

#strong[La indisciplina], ligada íntimamente a la actitud de antiautoridad, implica apartarse deliberadamente de los estándares y procedimientos que te enseñaron. Este factor se vuelve epidémico: una mala práctica vista repetidas veces en un campo de vuelo termina normalizándose en la mentalidad de todos sus pilotos, propagando conductas letales entre los alumnos y mermando gravemente la cultura de seguridad de todo el aeroclub.

#strong[Resumen del Capítulo: Psicología Aeronáutica]

- #strong[Conciencia situacional]: Es la capacidad precisa de percibir lo que ocurre, comprender su significado y proyectar su estado futuro. Perderla es el primer eslabón de la mayoría de las cadenas de accidentes.
- #strong[Toma de decisiones (ADM)]: Proceso mental sistemático (como el modelo DECIDE) utilizado por los pilotos para elegir consistentemente la mejor opción de acción en respuesta a un conjunto de circunstancias.
- #strong[Estrés]: Es la respuesta del cuerpo ante una demanda física o psicológica. Un nivel moderado mejora el rendimiento (alerta), pero el estrés excesivo o crónico bloquea la capacidad de tomar decisiones y fija la atención en detalles irrelevantes (visión de túnel).
- #strong[Carga de trabajo y Rendimiento]: Tu capacidad de procesamiento es limitada (como un vaso de agua). Si la complejidad del vuelo (mal tiempo, tráfico, avería) llena el vaso, te desbordas. Simplifica la tarea (aviate, navigate, communicate) para recuperar margen de seguridad.
- #strong[Procesamiento de Información]: Comprende la percepción (interpretación del medio ambiente), atención (foco) y las memorias sensorial, a corto plazo y a largo plazo. Un exceso de información externa sin asimilar puede generar sobrecarga cualitativa.
- #strong[Gestión de Riesgos (PAVE)]: Evaluar sistemáticamente factores críticos divididos en Piloto, Aeronave, Medio Ambiente (#strong[Environment]) y Operación o Presiones Externas.
- #strong[Actitudes Peligrosas]: Las cinco actitudes a evitar son la antiautoridad, la impulsividad, la invulnerabilidad, la arrogancia (exceso de confianza) y la resignación.
- #strong[Gestión de Recursos (SRM)]: La habilidad del piloto solitario para usar integralmente el equipo a bordo, la información, las comunicaciones y la ayuda externa para no exceder su capacidad límite.
- #strong[Complacencia e Indisciplina]: La complacencia surge por el exceso de rutina generando una falsa sensación de seguridad, mientras que la indisciplina contagia una mala cultura de seguridad en el aeródromo al ignorar las normas.

= Uso de oxígeno
<uso-de-oxígeno>
#quote(block: true)[
A medida que el planeador gana altitud, la presión atmosférica desciende y el oxígeno disponible para el organismo disminuye. Este capítulo explica los mecanismos que provocan la hipoxia y la hiperventilación, describe sus síntomas y tratamientos, y detalla los requisitos reglamentarios y los equipos de oxígeno que el piloto debe conocer para operar con seguridad en altitud.
]

== La atmósfera y las leyes de los gases
<la-atmósfera-y-las-leyes-de-los-gases>
Para entender cómo afecta la altitud en la cabina de un planeador ---que no está presurizada---, es necesario comprender dos principios básicos de física.

La atmósfera está compuesta por un 78% de nitrógeno y un 21% de oxígeno. Ese porcentaje se mantiene constante conforme se gana altura, pero lo que cambia de forma significativa es la #strong[presión atmosférica].

La #strong[ley de Dalton] establece que la presión total de una mezcla de gases es la suma de las presiones parciales de cada componente. Al ascender, la columna de aire sobre nosotros es menor, por lo que la presión general disminuye. A nivel del mar, esa presión «empuja» las moléculas de oxígeno a través de los alvéolos pulmonares hacia la sangre con eficacia. A gran altitud, la presión es tan baja que el oxígeno no tiene fuerza suficiente para atravesar la membrana alveolar: el piloto respira un 21% de oxígeno pero sufre privación de oxígeno a nivel celular.

La #strong[ley de Boyle] indica que el volumen de un gas confinado aumenta si la presión exterior disminuye. Al ascender, cualquier bolsa de aire atrapada en el organismo ---estómago, intestinos, senos paranasales u oídos--- se expande para igualar la presión exterior.

#block[
#callout(
body: 
[
No vuele con un resfriado severo o congestión nasal, especialmente si prevé techos térmicos elevados o vuelos de onda. El aire atrapado en los senos paranasales o en el oído medio se expande al ascender y puede causar un dolor intenso y agudo (barotrauma) que incapacita para pilotar con seguridad.

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
== El sistema respiratorio
<el-sistema-respiratorio>
Los pulmones contienen millones de alvéolos recubiertos de capilares. Al inspirar, el oxígeno llega a esos alvéolos y, impulsado por la presión barométrica, cruza hacia la sangre. En la sangre, la #strong[hemoglobina] de los glóbulos rojos transporta el oxígeno hasta el cerebro, la retina y los músculos, y recoge el dióxido de carbono (CO#sub[2]) de desecho, que se exhala en la siguiente respiración.

En altitud, los pulmones y el corazón funcionan con normalidad, pero la presión insuficiente impide cargar oxígeno en los alvéolos. Los glóbulos rojos llegan al cerebro prácticamente vacíos. Ese déficit de oxígeno cerebral es la #strong[hipoxia].

== Hipoxia
<hipoxia>
=== Clases de hipoxia
<clases-de-hipoxia>
Aunque el vuelo a gran altitud es la causa más común, la hipoxia puede originarse en cuatro mecanismos distintos:

+ #strong[Hipoxia hipóxica:] La presión atmosférica es insuficiente para transferir oxígeno a la sangre. Es la forma más frecuente en pilotos de planeador. Se corrige iniciando el descenso o activando el suministro de oxígeno suplementario.
+ #strong[Hipoxia hipémica (o anémica):] La sangre pierde capacidad de transporte de oxígeno. Ocurre principalmente por inhalación de #strong[monóxido de carbono (CO)] procedente del escape del remolcador o por tabaquismo intenso, ya que el CO desplaza al oxígeno en la hemoglobina.
+ #strong[Hipoxia estancada (o isquémica):] La circulación sanguínea se detiene o reduce en el cerebro. En planeador puede producirse durante virajes cerrados con elevadas fuerzas G positivas, que desplazan la sangre hacia las extremidades inferiores y vacían de riego la cabeza, provocando visión en túnel o pérdida temporal de visión (#strong[grey-out]).
+ #strong[Hipoxia histotóxica:] Las células cerebrales son incapaces de asimilar el oxígeno que reciben, por estar intoxicadas. El consumo de #strong[alcohol, drogas o ciertos medicamentos] (relajantes musculares o antihistamínicos, entre otros) produce este efecto.

=== Fases y síntomas
<fases-y-síntomas>
Los síntomas de la hipoxia varían entre individuos y dependen de factores como el nivel de fatiga, el tabaquismo, la ingesta de alcohol o la aclimatación a la altitud. El piloto a menudo no percibe sus propios síntomas.

El síntoma más peligroso ---y el primero en aparecer según el programa AESA--- es la #strong[euforia]: el piloto se siente excepcionalmente bien y no detecta el peligro. A continuación aparecen irritabilidad, dificultad para hablar, pérdida de memoria a corto plazo, disminución de la capacidad de cálculo y somnolencia. En fases avanzadas se produce #strong[cianosis]: coloración azulada en labios y uñas, y finalmente pérdida de conciencia (#ref(<fig-02-cap04-cianosis>, supplement: [Figura])).

#block[
#callout(
body: 
[
La euforia es el síntoma más traicionero de la hipoxia: el piloto no sospecha que está en peligro. Si percibe visión borrosa, hormigueo en las extremidades, euforia injustificada o dolor de cabeza tras un ascenso rápido a gran altitud, asuma hipoxia. Active el suministro de oxígeno al 100% e inicie el descenso de inmediato.

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
#box(image("imagenes/02-cap02-sintomas-hipoxia.jpg"))
], caption: figure.caption(
position: bottom, 
[
Cianosis: coloración azulada en extremidades por falta de oxígeno
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap04-cianosis>


=== Tiempo útil de conciencia (#emph[Time of Useful Consciousness], TUC)
<tiempo-útil-de-conciencia-time-of-useful-consciousness-tuc>
El TUC es el intervalo que transcurre desde que se interrumpe el suministro de oxígeno hasta que el piloto pierde la capacidad de tomar medidas protectoras. A mayor altitud, menor tiempo disponible para reaccionar.

La siguiente tabla muestra los valores de referencia (#ref(<fig-02-cap04-hipoxia-tiempo-conciencia>, supplement: [Figura])):

#figure([
#box(image("imagenes/02-cap04-hipoxia-tiempo-conciencia.png"))
], caption: figure.caption(
position: bottom, 
[
Tiempo de conciencia útil (
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap04-hipoxia-tiempo-conciencia>


Un descenso desde 7.000 m hasta 3.000 m a 5 m/s de tasa de descenso tarda más de 13 minutos, tiempo con frecuencia superior al TUC disponible a esa altitud. Iniciar el descenso sin oxígeno puede ser demasiado tarde.

#block[
#callout(
body: 
[
Ante cualquier fallo en el suministro de oxígeno o sospecha de hipoxia, aplique la regla: #strong[«Oxígeno al 100% y desciende»]. Active el flujo completo y baje por debajo de los 10.000 ft sin dudarlo. A partir de cierta altitud, el TUC no permite pensar ni actuar correctamente.

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
=== Prevención y tratamiento
<prevención-y-tratamiento>
La mejor prevención es anticipar las situaciones de riesgo y operar el equipo de oxígeno de forma rutinaria y automatizada.

Antes del vuelo, compruebe el equipo:

- Verifique que el manómetro de la botella marca entre 150 y 200 bar.
- Compruebe que la cánula o mascarilla está bien conectada, sin pliegues ni obstrucciones.
- Confirme que el regulador de flujo funciona correctamente.

Si aparecen síntomas de hipoxia durante el vuelo:

+ Active el suministro de oxígeno al #strong[100% de flujo] de forma inmediata.
+ Compruebe que la cánula o mascarilla sella correctamente y no tiene fugas.
+ Si los síntomas no remiten en pocos segundos, inicie el descenso por debajo de los 10.000 ft.

#block[
#callout(
body: 
[
Disponga de un #emph[checklist] de emergencia para hipoxia, ya que el razonamiento puede estar deteriorado en el momento en que más lo necesita. Si lleva pulsioxímetro a bordo, compruebe la saturación (SpO#sub[2]) ante cualquier duda.

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
== Hiperventilación
<hiperventilación-1>
=== Causas y mecanismo
<causas-y-mecanismo>
La hiperventilación es una respiración anormalmente rápida o profunda que no está causada por falta de oxígeno, sino por situaciones de estrés o ansiedad. En el planeador puede desencadenarse por turbulencias intensas, situaciones fuera de campo complicadas o decisiones difíciles en vuelo.

Al hiperventilar, el piloto expulsa CO#sub[2] en exceso. El organismo regula el flujo sanguíneo cerebral en función del nivel de CO#sub[2] disuelto en sangre: cuando ese nivel cae (hipocapnia), los vasos sanguíneos cerebrales se contraen, reduciendo el aporte de oxígeno al cerebro a pesar de que los pulmones están cargados de él. El resultado paradójico es que el piloto se asfixia con los pulmones llenos.

=== Síntomas
<síntomas>
Los síntomas de la hiperventilación son similares a los de la hipoxia, lo que dificulta el diagnóstico diferencial:

- Hormigueo y entumecimiento en manos, pies y alrededor de la boca.
- Calambres o espasmos musculares.
- Sensación de no poder tomar aire y palpitaciones.
- Mareo, náuseas y somnolencia.
- En casos graves, pérdida de conciencia.

#block[
#callout(
body: 
[
Para distinguir hipoxia de hiperventilación, evalúe dos factores: #strong[altitud] y #strong[estado emocional].

- Si está por encima de 10.000 ft y se siente eufórico o aletargado: probable #strong[hipoxia]. Aplique oxígeno al 100% y descienda.
- Si está por debajo de 10.000 ft y experimenta hormigueo con sudoración y ansiedad: probable #strong[hiperventilación]. Reduzca el ritmo respiratorio.

En caso de duda a gran altitud, priorice el tratamiento de la hipoxia.

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
=== Tratamiento
<tratamiento>
El objetivo es restablecer el nivel de CO#sub[2] en sangre. Para ello:

+ #strong[Reduzca el ritmo respiratorio:] Haga inspiraciones lentas y profundas, reteniendo el aire unos segundos antes de exhalar.
+ #strong[Hable en voz alta:] Recite el #emph[checklist] o cuente en voz alta. Hablar obliga a controlar la exhalación y dificulta el jadeo.
+ #strong[En casos graves:] Cubra la nariz y la boca con una bolsa de mareo para reinhalar parte del CO#sub[2] exhalado y restablecer el equilibrio.
+ Si la hiperventilación persiste, dé por concluido el vuelo y regrese al campo.

#block[
#callout(
body: 
[
No aporte oxígeno suplementario si diagnostica hiperventilación y no está a gran altitud: añadir más oxígeno agravaría el desequilibrio de CO#sub[2] y empeoraría los síntomas. Si no puede confirmar que está por debajo de 10.000 ft, priorice el tratamiento de la hipoxia.

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
== Requisitos normativos para el uso de oxígeno
<requisitos-normativos-para-el-uso-de-oxígeno>
#block[
#callout(
body: 
[
#strong[SAO.OP.150:] «El piloto al mando deberá garantizar que todas las personas a bordo utilicen oxígeno suplementario cuando determine que, a la altitud de vuelo prevista, la falta de oxígeno podría ocasionar la disminución de sus facultades o resultarles dañina.»

#strong[AMC1 SAO.OP.150:] cuando el piloto no pueda determinar ese efecto, el oxígeno deberá usarse siempre que la altitud de presión supere los #strong[10.000 ft].

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
El umbral de los 10.000 ft no es, por tanto, un límite legal incondicional: es la regla por defecto cuando no puedes valorar cómo afecta la falta de oxígeno a los ocupantes. La obligación de fondo es la primera: evaluar y garantizar.

#block[
#callout(
body: 
[
Para vuelos #strong[nocturnos o al atardecer] se recomienda ---no lo exige la norma--- iniciar el uso de oxígeno desde los #strong[5.000 ft]: la visión nocturna es especialmente sensible a la falta de oxígeno, porque los bastones de la retina periférica son las primeras células en verse afectadas.

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
== Equipos y sistemas de oxígeno en planeadores
<equipos-y-sistemas-de-oxígeno-en-planeadores>
=== Tipos de sistemas
<tipos-de-sistemas>
En los planeadores se utilizan principalmente dos tipos de sistemas:

- #strong[Sistema de flujo continuo:] Suministra un caudal constante de oxígeno regulado por el piloto (habitualmente 2 a 2,5 L/min). Es sencillo, fiable y económico, pero consume oxígeno también durante la exhalación, lo que limita la autonomía y reseca las mucosas nasales. Según la doctrina FAA, no se recomienda por encima de #strong[25.000 ft (FL250)]\; más arriba se requieren sistemas de demanda con máscara.
- #strong[Sistema a demanda pulsada (#emph[Electronic Demand System], EDS):] Detecta el inicio de cada inspiración mediante sensores barométricos y libera únicamente el volumen necesario, interrumpiendo el flujo durante la exhalación. Puede multiplicar por tres o cuatro la autonomía de la botella respecto al flujo continuo. El principal inconveniente es su dependencia de pilas de 9 V, que pueden fallar a temperaturas muy bajas; se recomienda conectarlo a la batería principal del planeador y usar la pila como respaldo.

=== Inspección, uso, mantenimiento y seguridad
<inspección-uso-mantenimiento-y-seguridad>
Antes de cada vuelo en altitud, compruebe visualmente la botella, las conexiones y los tubos. Verifique la presión con el manómetro y asegúrese de que la cánula o mascarilla no presenta pliegues.

#block[
#callout(
body: 
[
#strong[Oxígeno de aviación, no medicinal.] El oxígeno medicinal contiene mayor concentración de humedad, que puede congelarse en el regulador a temperaturas de altitud elevadas y bloquear el flujo. Utilice exclusivamente oxígeno etiquetado como «para uso aeronáutico» (oxígeno seco, pureza superior al 98,5%).

#strong[Prohibido el contacto con grasas.] No aplique cremas hidratantes, protectores solares ni lubricantes cerca de las conexiones, reguladores o boquillas. El oxígeno a presión en contacto con sustancias grasas puede provocar una combustión explosiva sin necesidad de llama o chispa.

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
== Pulsioxímetro
<pulsioxímetro>
El pulsioxímetro es un dispositivo no invasivo que mide la saturación de oxígeno en sangre (SpO#sub[2]) y la frecuencia cardíaca en tiempo real (#ref(<fig-02-cap04-pulsioximetro>, supplement: [Figura])). Es el instrumento más útil para detectar hipoxia antes de que los síntomas sean evidentes para el propio piloto.

#figure([
#box(image("imagenes/02-cap04-pulsioximetro.jpg"))
], caption: figure.caption(
position: bottom, 
[
Pulsioxímetro de dedo mostrando lectura de saturación de oxígeno y frecuencia cardíaca
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap04-pulsioximetro>


Coloque el pulsioxímetro en el dedo índice antes del despegue y mantenga la lectura visible durante el vuelo. Para vuelos de onda, fíjelo con velcro en la cabina o utilice un guante adaptado que permita leerlo sin quitarse el equipo de frío.

Un valor de SpO#sub[2] por debajo del #strong[90%] indica hipoxia franca y requiere acción inmediata: activar el oxígeno suplementario e iniciar el descenso.

#block[
#callout(
body: 
[
Registre sus valores de SpO#sub[2] a distintas altitudes durante los vuelos habituales (a 3.000 m, a 5.000 m) para conocer su respuesta individual y tener referencias personales. No todos los pilotos responden igual a la altitud.

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
#strong[Resumen del capítulo: Uso de oxígeno]

- #strong[Leyes de los gases:] La presión atmosférica disminuye con la altitud (ley de Dalton), reduciendo la capacidad del oxígeno para transferirse a la sangre. Los gases corporales se expanden al ascender (ley de Boyle); no vuele con congestión nasal intensa para evitar barotraumas dolorosos.
- #strong[Sistema respiratorio e hipoxia:] La hemoglobina transporta el oxígeno desde los alvéolos al cerebro. Cuando la presión es insuficiente, los glóbulos rojos llegan vacíos al cerebro y se produce hipoxia.
- #strong[Clases de hipoxia:] Existen cuatro tipos: #strong[hipóxica] (baja presión atmosférica, la más frecuente en planeador), #strong[hipémica] (monóxido de carbono o tabaquismo), #strong[estancada] (fuerzas G elevadas en virajes cerrados) e #strong[histotóxica] (alcohol, drogas o medicamentos).
- #strong[Síntomas y diagnóstico:] El primer síntoma es la euforia; el piloto no percibe el peligro por sí mismo. Posteriormente aparecen somnolencia, dificultad para calcular, cianosis y pérdida de conciencia. El pulsioxímetro detecta la hipoxia antes de que los síntomas sean evidentes.
- #strong[Tiempo útil de conciencia (TUC):] A 25.000 ft, el TUC es de 3 a 5 minutos; a 30.000 ft, de 1 a 2 minutos. Un descenso largo puede superar el TUC disponible: actúe siempre antes de necesitarlo.
- #strong[Normativa (SAO.OP.150 y su AMC):] El oxígeno suplementario es obligatorio cuando el piloto determine que su falta puede disminuir las facultades de los ocupantes; cuando no pueda determinarlo, la regla por defecto del AMC es usarlo siempre por encima de #strong[10.000 ft]. En vuelo nocturno o al atardecer se #strong[recomienda] (no es norma) desde los #strong[5.000 ft].
- #strong[Sistemas de oxígeno:] El flujo continuo es sencillo pero consume más oxígeno y reseca las mucosas. El sistema a demanda pulsada (EDS) multiplica la autonomía de la botella, pero depende de pilas que pueden fallar con el frío. Use siempre oxígeno de aviación seco; no medicinal.
- #strong[Seguridad del equipo:] No use grasas ni cremas cerca de conexiones de oxígeno: riesgo de combustión explosiva. Verifique la presión de la botella antes de cada vuelo (entre 150 y 200 bar).
- #strong[Hiperventilación:] Causada por estrés o ansiedad, no por falta de oxígeno. Al exhalar CO#sub[2] en exceso, los vasos cerebrales se contraen, produciendo síntomas similares a la hipoxia (hormigueo, calambres, mareo). Tratamiento: reducir el ritmo respiratorio, hablar en voz alta o reinhalar CO#sub[2] cubriendo parcialmente la boca.
- #strong[Pulsioxímetro:] Mantenga la saturación (SpO#sub[2]) por encima del #strong[90%]\; por debajo de ese umbral, active el oxígeno y descienda de inmediato.

#show: appendices.with("Apéndices", hide-parent: true)
#heading(level: 1, numbering: none)[Apéndices]
= Syllabus Oficial EASA - Factores Humanos
<syllabus-oficial-easa---factores-humanos>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Factores Humanos] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- 2.1. Factores humanos: conceptos básicos.
- 2.2. Fisiología aeronáutica básica y mantenimiento de salud.
- 2.3. Psicología aeronáutica básica.
- 2.4. Uso de oxígeno.

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

== Ponte a prueba
<ponte-a-prueba>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/02-factores-humanos/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

= Glosario de términos
<glosario-de-términos>
Este glosario contiene las definiciones y acrónimos más relevantes de Factores Humanos y Fisiología aplicables a la licencia de piloto de planeador (SPL).

/ #strong[ADM (Aeronautical Decision-Making)]: #block[
Toma de decisiones aeronáuticas. Proceso mental sistemático (por ejemplo, mediante el modelo DECIDE) empleado por el piloto para elegir la opción más segura como respuesta a un conjunto de circunstancias. (Mencionado en: cap. 3)
]

/ #strong[AESA (Agencia Estatal de Seguridad Aérea)]: #block[
Autoridad de aviación civil en España, encargada de supervisar y aplicar la normativa aeronáutica nacional, trabajando junto con EASA y emitiendo las licencias de vuelo para pilotos (SPL), así como supervisando la expedición de certificados médicos por parte de centros y médicos examinadores autorizados. (Mencionado en: cap. 4)
]

/ #strong[AME (Aero-Medical Examiner)]: #block[
Médico Examinador Aéreo. Médico especialista certificado y autorizado por AESA para llevar a cabo los reconocimientos físicos y psicológicos necesarios para emitir o renovar el certificado médico aeronáutico. (Mencionado en: cap. 2)
]

/ #strong[ATC (Control de Tránsito Aéreo / Air Traffic Control)]: #block[
Servicio de tránsito aéreo responsable de dirigir el tráfico de aeronaves para prevenir colisiones entre aeronaves y entre estas y los obstáculos en el área de maniobras, así como de organizar y agilizar el flujo del tránsito aéreo. (Mencionado en: cap. 3)
]

/ #strong[AUT / TUE (Autorización de Uso Terapéutico)]: #block[
#strong[Therapeutic Use Exemption]. Permiso oficial emitido por una organización antidopaje o autoridad aeronáutica (como WADA) que permite a un piloto de competición utilizar una medicación específica que normalmente requeriría su suspensión en un control antidopaje, salvaguardando su salud de base. (Mencionado en: cap. 2)
]

/ #strong[Cadena del error]: #block[
Sucesión de pequeñas decisiones erróneas, condiciones previas y errores latentes que, al alinearse e interactuar (como en el #strong[modelo del queso suizo]), desencadenan un accidente o incidente. (Mencionado en: cap. 1)
]

/ #strong[Cianosis]: #block[
Coloración azulada en la piel, labios y yemas de los dedos producida por una acusada deficiencia de oxígeno en la sangre, siendo uno de los síntomas físicos avanzados propios de la hipoxia. (Mencionado en: cap. 4)
]

/ #strong[Cinetosis]: #block[
Mareo producido por el movimiento (#strong[motion sickness]), desencadenado en vuelo por un conflicto entre la información percibida por el sistema visual (que observa una cabina inmóvil) y el sistema vestibular del oído interno (que registra las aceleraciones y giros de la aeronave). (Mencionado en: cap. 2)
]

/ #strong[Complacencia]: #block[
Estado mental limitante originado por la rutina y la familiaridad con el entorno, que genera una falsa sensación de seguridad e induce a omitir procedimientos básicos como las listas de comprobación. (Mencionado en: cap. 3)
]

/ #strong[Conciencia situacional]: #block[
#strong[Situational Awareness]. Percepción completa y asimilación adecuada de los elementos del vuelo en el presente, comprensión analítica de su estatus actual y proyección fiel de su tendencia hacia el futuro. (Mencionado en: cap. 3)
]

/ #strong[Cultura justa (Just Culture)]: #block[
Paradigma organizacional que reconoce la inevitabilidad del error humano no intencionado, tratándolo como una oportunidad de aprendizaje colectivo sin represalias, oponiéndose a todo encubrimiento o sanción punitiva irracional. (Mencionado en: cap. 1)
]

/ #strong[DECIDE]: #block[
Modelo estandarizado para la toma de decisiones aeronáuticas: Detectar, Estudiar, Considerar, Implementar, Determinar y Evaluar. (Mencionado en: cap. 3)
]

/ #strong[Desorientación espacial]: #block[
Falsa apreciación de la posición, actitud o movimiento de la aeronave como consecuencia de ilusiones sensoriales originadas en el oído interno, obligando al piloto a desconfiar de sus sentidos y ampararse en los instrumentos. (Mencionado en: cap. 2)
]

/ #strong[Disbarismos (Barotraumas)]: #block[
Alteraciones orgánicas o dolor neurálgico originados por la expansión y contracción de pequeños volúmenes de gas atrapados en el cuerpo (senos paranasales, oído medio, intestinos) frente a los inevitables cambios en la presión atmosférica por la Ley de Boyle. (Mencionado en: cap. 2)
]

/ #strong[EASA (Agencia de la Unión Europea para la Seguridad Aérea / European Union Aviation Safety Agency)]: #block[
Agencia de la Unión Europea responsable de establecer el marco normativo común para regular y supervisar la seguridad de la aviación civil, incluyendo requisitos médicos (Part-MED) y licencias (SFCL). (Mencionado en: cap. 1)
]

/ #strong[EDS (Sistema de Oxígeno a Demanda / Electronic Delivery System)]: #block[
Sistema electrónico de suministro de oxígeno a demanda que detecta la inspiración del piloto y libera un pulso de oxígeno en ese instante, multiplicando la autonomía de la botella de oxígeno al interrumpir el flujo durante la exhalación. (Mencionado en: cap. 4)
]

/ #strong[Fatiga]: #block[
Deterioro fisiológico del rendimiento físico o mental provocado por pérdida de sueño, ritmos circadianos alterados o esfuerzo mental sostenido; reduce drásticamente el tiempo de reacción o la capacidad para evaluar riesgos con sensatez. (Mencionado en: cap. 2)
]

/ #strong[Hiperventilación]: #block[
Respiración anormalmente rápida desencadenada por el estrés, el pánico o la ansiedad, generando una expulsión drástica de dióxido de carbono que provoca el estrechamiento de los vasos sanguíneos en el cerebro, reduciendo el flujo de oxígeno a pesar de volar a altitudes seguras. (Mencionado en: cap. 2, cap. 4)
]

/ #strong[Hipoxia]: #block[
Estado de déficit de oxígeno cerebral. Existen cuatro tipos: hipóxica (falta de presión transferencial en altitud), hipémica (mermas de transporte por CO), estancada e histotóxica (intoxicación orgánica celular por alcohol o drogas). (Mencionado en: cap. 4)
]

/ #strong[IMSAFE]: #block[
Acrónimo nemotécnico de autoevaluación psicofísica recomendado antes de cada vuelo: Illness (Enfermedad), Medication (Medicación), Stress (Estrés), Alcohol (Alcohol), Fatigue (Fatiga) y Eating (Alimentación). (Mencionado en: cap. 2)
]

/ #strong[MED (Part-MED)]: #block[
Subparte de la normativa europea (EASA) que estipula y rige exhaustivamente todas las condiciones fisiológicas y médicas que debe cumplir un piloto para mantener y ejercer las atribuciones de su licencia de vuelo. (Mencionado en: cap. 2)
]

/ #strong[Monóxido de carbono (CO)]: #block[
Gas letal, inodoro e invisible derivado de los sistemas de escape. Se une a la hemoglobina bloqueando el transporte de oxígeno (hipoxia anémica), afectando a los pilotos de motovelero (TMG) incluso a baja altitud. (Mencionado en: cap. 2)
]

/ #strong[OACI (Organización de Aviación Civil Internacional / ICAO)]: #block[
Agencia especializada de las Naciones Unidas creada en 1944 para establecer las normas y métodos recomendados (SARPS) que garanticen la seguridad, protección, regularidad y eficiencia de la aviación civil global. (Mencionado en: cap. 1)
]

/ #strong[PAVE]: #block[
Esquema simplificado y fundamental para ejecutar la evaluación sistemática y mitigación profiláctica de los riesgos de cualquier vuelo, dividido en: Piloto, Aeronave (#strong[Aircraft]), Entorno (#strong[enVironment]) y Presiones Externas. (Mencionado en: cap. 3)
]

/ #strong[Pulsioxímetro]: #block[
Dispositivo de dedo recomendado en vuelos a gran altura que muestra la saturación de oxígeno en sangre (SpO₂). Permite al piloto detectar la hipoxia de forma objetiva antes de que aparezcan los primeros síntomas. (Mencionado en: cap. 4)
]

/ #strong[SAO (Sailplane Air Operations)]: #block[
Normativa operativa específica de EASA para pilotos al mando de planeadores. Fija reglas como la obligatoriedad del oxígeno por encima de 10.000 ft de altitud. (Mencionado en: cap. 4)
]

/ #strong[SFCL (Sailplane Flight Crew Licensing)]: #block[
Marco normativo europeo (EASA) que regula las licencias, el programa de estudios y la instrucción de vuelo para pilotos de planeador (SPL). (Mencionado en: el temario general)
]

/ #strong[SHELL]: #block[
Modelo conceptual desarrollado por la OACI interconectando de forma unificada y armónica todos los vértices relativos al operador: #strong[Software] (Procedimientos normativos), #strong[Hardware] (La Aeronave), #strong[Environment] (El Entorno físico), #strong[Liveware] interior y #strong[Liveware] externo (El piloto con respecto a otras personas). (Mencionado en: cap. 1)
]

/ #strong[SPL (Licencia de Piloto de Planeador / Sailplane Pilot Licence)]: #block[
Licencia oficial de la Unión Europea (regida por Part-SFCL) que certifica que el titular cumple con los requisitos teóricos y prácticos para actuar como piloto de planeadores. (Mencionado en: el temario general)
]

/ #strong[SRM (Single-Pilot Resource Management)]: #block[
Gestión de recursos para pilotos solitarios. Habilidad para administrar todos los recursos disponibles (instrumentos, ATC, listas de chequeo) para operar de forma segura, reduciendo la carga de trabajo y minimizando el riesgo de errores sistemáticos. (Mencionado en: cap. 3)
]

/ #strong[TMG (Motovelero de turismo / Touring Motor Glider)]: #block[
Planeador propulsado equipado estructuralmente con motor y hélice no retráctil que le permiten el despegue autónomo y el crucero, compartiendo características con aviones ligeros. (Mencionado en: cap. 2)
]

/ #strong[TUC (Time of Useful Consciousness)]: #block[
Tiempo útil de conciencia. Intervalo crítico en el que el piloto retiene sus capacidades cognitivas y motoras para tomar medidas correctivas tras una interrupción del suministro de oxígeno a gran altitud. Se reduce rápidamente a mayor altura. (Mencionado en: cap. 4)
]

/ #strong[VFR (Reglas de vuelo visual / Visual Flight Rules)]: #block[
Conjunto de normas que rigen los vuelos operados con referencia visual constante al terreno, recayendo la responsabilidad de la separación en el principio de "ver y evitar" bajo mínimos meteorológicos visuales (VMC). (Mencionado en: cap. 2)
]

/ #strong[WADA (World Anti-Doping Agency)]: #block[
Agencia Mundial Antidopaje. Organización internacional que regula y controla exhaustivamente el consumo de sustancias y dopaje en deportistas de competición, siendo los campeonatos de vuelo a vela sometidos también a este mismo estándar. (Mencionado en: cap. 2)
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
