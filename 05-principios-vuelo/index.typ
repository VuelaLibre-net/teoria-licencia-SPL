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
  title: [Principios de Vuelo],
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

#heading(level: 1, numbering: none)[Principios de Vuelo]
<principios-de-vuelo>
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
#strong[#emph[Tema 5 de 9 del examen teórico para la Licencia de Piloto de Planeador (SPL)]]

La aerodinámica de un planeador no tiene secretos. Tiene física. Y la física no negocia.

Cuando el ángulo de ataque supera el valor crítico, la sustentación colapsa independientemente de la altitud. Cuando el centrado está fuera de límites posteriores, la recuperación de una barrena puede ser imposible. Cuando el picado en espiral se inicia sin referencias exteriores, el anemómetro puede superar VNE antes de que el piloto comprenda qué está pasando.

Siete capítulos transforman la física del vuelo en criterio de pilotaje real: sustentación, resistencia, estabilidad, control, pérdida, barrena y espiral.

El planeador no vuela por arte de magia. Vuela porque alguien entendió la física antes de sentarse en la cabina.

= Aerodinámica (flujo de aire)
<aerodinámica-flujo-de-aire>
#quote(block: true)[
La aerodinámica es el fundamento invisible de todo lo que hace un planeador en el aire. En este capítulo aprenderás cómo la diferencia de presión entre extradós e intradós genera sustentación, qué es la capa límite y por qué un solo mosquito aplastado en el borde de ataque puede degradar el rendimiento de un perfil laminar, y cómo las dos grandes familias de resistencia aerodinámica determinan la velocidad óptima de planeo.
]

== Principio de Bernoulli y sustentación
<principio-de-bernoulli-y-sustentación>
La sustentación se genera por una diferencia de presiones entre la parte superior (extradós) y la inferior (intradós) del ala.

Cuando el planeador avanza, el aire fluye sobre el perfil curvado del extradós acelerándose, mientras que el aire que pasa por el intradós viaja a menor velocidad. Según el teorema de Bernoulli, cuando la velocidad de un fluido aumenta, su presión estática disminuye: el extradós queda con menos presión que el intradós, y esa diferencia crea la fuerza neta ascendente que contrarresta el peso del planeador.

#block[
#callout(
body: 
[
✦ #strong[REGLA DE ORO]

La sustentación admite dos descripciones del #strong[mismo] fenómeno, no dos fuerzas que se sumen: la diferencia de presión (Bernoulli) y la deflexión del aire hacia abajo en el borde de salida (acción-reacción, tercera ley de Newton). El ala que acelera el aire por arriba es la misma que lo desvía hacia abajo; ambas miradas dan la misma fuerza.

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
== La capa límite
<la-capa-límite>
La capa límite es la fina lámina de aire en contacto directo con la piel del ala. El rozamiento viscoso frena esa capa progresivamente hasta que la velocidad llega a cero sobre la superficie misma. Tiene dos regímenes:

- #strong[Laminar:] el flujo se desliza en láminas paralelas y ordenadas. Genera la mínima fricción posible y es el objetivo principal del diseño de los planeadores modernos.
- #strong[Turbulenta:] el flujo se desordena en pequeños remolinos. El rozamiento aumenta mucho respecto al régimen laminar, la capa se engrosa y el planeo se resiente. Tiene, eso sí, una virtud: al llevar más energía, se aferra mejor al perfil y tarda más en desprenderse. Por eso muchos planeadores montan turbuladores (esa cinta en zigzag que habrás visto en algún Discus): fuerzan la transición a turbulenta justo donde conviene evitar que el flujo se separe.

El punto de la cuerda donde el flujo laminar pasa a ser turbulento se llama #strong[punto de transición] (#ref(<fig-05-cap01-capa-limite>, supplement: [Figura])). Para mantener la capa límite laminar sobre la mayor superficie posible, las alas deben estar completamente limpias; un simple mosquito aplastado en el borde de ataque basta para provocar una transición prematura a capa turbulenta. Si el ángulo de ataque aumenta en exceso, el flujo entra en fase de #strong[separación]: se desprende del ala y provoca una caída masiva de sustentación con un gran aumento de resistencia (#strong[stall] o pérdida).

#figure([
#box(image("imagenes/05-cap01-capa-limite.jpg"))
], caption: figure.caption(
position: bottom, 
[
Capa límite laminar y turbulenta sobre un perfil alar.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap01-capa-limite>


== Centro de presiones (CP)
<centro-de-presiones-cp>
El centro de presiones (CP) es el punto de la cuerda alar donde actúa la fuerza neta de sustentación. No es fijo: se desplaza con el ángulo de ataque.

La regla:

- Más ángulo de ataque → CP avanza hacia el borde de ataque.
- Bajas el morro → CP retrocede.

Ese vaivén continuo afecta directamente al equilibrio en cabeceo.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Debido a la movilidad del CP, el diseño de la aeronave obliga a situar el centro de gravedad (CG) por delante del centro de presiones en las condiciones normales de vuelo. Esa configuración proporciona #strong[estabilidad longitudinal positiva]. Para contrarrestar la tendencia a picar (hundir el morro) que produce el CG adelantado, el estabilizador horizontal genera una fuerza descendente que mantiene el equilibrio en cabeceo.

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
== Tipos de resistencia y curva de resistencias
<tipos-de-resistencia-y-curva-de-resistencias>
Todo lo que mantiene al planeador en el aire tiene su precio: la resistencia al avance (#strong[drag]). Se divide en dos componentes:

- #strong[Resistencia parásita:] la que produce cualquier objeto sólido al moverse a través de un fluido. Crece con el cuadrado de la velocidad (si la velocidad se duplica, la resistencia se cuadruplica). Se compone de:

  - Fricción superficial de las alas y fuselaje.
  - Resistencia de forma (perfil de las piezas).
  - Resistencia de interferencia (donde dos superficies ortogonales se unen, como el encastre del plano con el fuselaje).

- #strong[Resistencia inducida:] el subproducto directo de generar sustentación. La diferencia de presión entre extradós e intradós hace que el aire fluya en sentido contrario alrededor de las puntas del ala, desde la zona de alta presión (intradós) hacia la de baja presión (extradós). Ese rodeo genera #strong[torbellinos helicoidales] que se desprenden de cada punta y que, al inclinar levemente hacia atrás el vector de sustentación resultante, crean una fuerza opositora al avance: la resistencia inducida (#ref(<fig-05-cap01-vortices-punta-ala>, supplement: [Figura])). Al contrario que la parásita, es máxima a velocidades bajas (y altos ángulos de ataque) y disminuye a medida que el planeador acelera.

#figure([
#box(image("imagenes/05-cap01-vortices-punta-ala.png"))
], caption: figure.caption(
position: bottom, 
[
Resistencia inducida por la producción de sustentación
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap01-vortices-punta-ala>


Hay dos razones por las que un planeador planea tan distinto a un avión de turismo. La primera es la #strong[razón de aspecto] (#strong[aspect ratio]): cuántas veces cabe la cuerda en la envergadura. Alas largas y estrechas forman vórtices de punta más débiles, así que la resistencia inducida cae. Un planeador de regata alcanza una razón de aspecto de 30:1 o más; un avión de turismo, entre 7 y 8. Esa diferencia explica buena parte de la brecha de rendimiento; el resto lo ponen los perfiles laminares y la limpieza aerodinámica del conjunto. La segunda es el uso de #strong[winglets]: las pequeñas aletas verticales en las puntas del ala que cortan el paso al aire que intenta rodear la punta de alta a baja presión. Reducen el vórtice sin estirar más la envergadura.

La suma de ambas resistencias en función de la velocidad forma una curva en "U". El punto más bajo de esa curva es la velocidad donde la resistencia aerodinámica total es mínima. Volando exactamente a esa velocidad, el planeador alcanza la mejor relación sustentación/resistencia (L/D): el ángulo de planeo óptimo para maximizar el alcance horizontal.

== El efecto suelo
<el-efecto-suelo>
Cuando el planeador vuela a muy baja altura sobre la pista ---generalmente por debajo de una envergadura de ala sobre el terreno---, entra en una zona de influencia aerodinámica denominada #strong[efecto suelo]. El terreno actúa como una barrera física que interrumpe la formación normal de los torbellinos de punta de ala y reduce la intensidad del flujo descendente que los alimenta (#strong[downwash]).

El resultado es una reducción significativa de la resistencia inducida que mejora transitoriamente la relación L/D del planeador (#ref(<fig-05-cap01-efecto-suelo>, supplement: [Figura])):

- Durante el aterrizaje, el planeador "flota" más de lo esperado: al caer la resistencia inducida, apenas decelera y el ala sigue sustentando a velocidades algo inferiores a las que necesitaría en vuelo libre. Un piloto que entra largo o demasiado rápido puede consumir cientos de metros de pista sin posarse.
- Durante el despegue en aeroplano remolcado, el planeador puede despegar a velocidades ligeramente más bajas de las normales. Una vez que abandona el efecto suelo, la resistencia inducida recupera su valor normal y puede producirse una ligera pérdida de ascenso si la velocidad no es suficiente.

#figure([
#box(image("imagenes/05-cap01-efecto-suelo.jpg"))
], caption: figure.caption(
position: bottom, 
[
El efecto suelo: reducción de torbellinos y mejora transitoria del planeo en proximidad al terreno.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap01-efecto-suelo>


#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

El efecto suelo puede sorprender al piloto inexperto: el planeador parece no querer posarse durante la toma. Si estás entrando en la zona de contacto con exceso de velocidad o inercia, resiste la tentación de picar el morro para forzar el aterrizaje. Usa los frenos aerodinámicos para controlar el planeo y déjalo posarse solo cuando esté listo, asegurándote antes de tener pista suficiente.

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
#strong[Resumen del Capítulo: Aerodinámica y Flujo de Aire]

- #strong[Principio de Bernoulli]: la base del vuelo. El aire se acelera sobre la superficie curva del ala (extradós) y su presión disminuye, generando una fuerza neta hacia arriba. Es la misma sustentación que describe la deflexión del aire hacia abajo (Newton): dos miradas de un único fenómeno, no dos fuerzas que se sumen.
- #strong[Capa límite]: esa fina capa de aire pegada al ala. Si es #strong[laminar] (ordenada), la resistencia es mínima: el santo grial de los veleros modernos. Si se vuelve #strong[turbulenta], la resistencia sube, pero el ala sigue sustentando. Solo cuando el flujo se #strong[separa] del perfil la sustentación se desploma: eso es la pérdida.
- #strong[Centro de presiones (CP)]: el punto donde se aplica la fuerza de sustentación. Cuidado: se mueve con el ángulo de ataque (adelante con altos ángulos, atrás con bajos), lo que afecta a la estabilidad.
- #strong[Tipos de resistencia]: #strong[parásita] (roce con el aire, sube con la velocidad) e #strong[inducida] (precio por generar sustentación, baja con la velocidad). La inducida viene de los torbellinos de punta de ala que inclinan el vector de sustentación. Los planeadores la minimizan con alta razón de aspecto (alas largas y estrechas) y winglets en las puntas.
- #strong[Efecto suelo]: por debajo de una envergadura de altura sobre el terreno, los vórtices de punta se comprimen, la resistencia inducida cae y el planeador "flota" con más eficiencia de la normal. Útil conocerlo: explica por qué en el aterrizaje el planeador no se posa si entras rápido o largo.

= Mecánica de vuelo
<mecánica-de-vuelo>
#quote(block: true)[
Sin motor, la gravedad es tu único combustible. En este capítulo aprenderás a interpretar la curva polar de tu planeador para extraer el máximo rendimiento, a ajustar la velocidad según el viento y las descendencias, y a entender el factor de carga para volar en viraje sin comprometer la estructura ni acercarte a la pérdida sin darte cuenta.
]

== El motor es la gravedad
<el-motor-es-la-gravedad>
Un planeador no tiene motor. Una vez suelto del remolque, su único combustible es la altura que lleva bajo las alas.

El vuelo planeando es un intercambio permanente: la energía potencial (altitud) se convierte en cinética (velocidad). Para que el ala siga sustentando, el planeador baja levemente el morro frente a la masa de aire. Esa inclinación hace que una componente del peso apunte hacia adelante a lo largo de la trayectoria, actuando como tracción y equilibrando la resistencia aerodinámica (#strong[drag]).

#block[
#callout(
body: 
[
✦ #strong[REGLA DE ORO]

La velocidad te da el mando del planeador; la altura es tu reserva de energía. Cediendo altura ganas velocidad (palanca adelante) y, gastando el exceso de velocidad, puedes recuperar algo de trayectoria ascendente (palanca atrás). Pero ese intercambio dura poco: la reserva solo se rellena subiendo en una ascendencia.

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
== La curva polar
<la-curva-polar>
La curva polar es el DNI de rendimiento de tu planeador. Muestra la relación entre velocidad (km/h) y tasa de descenso (m/s) en aire en calma. Conocerla es obligatorio, porque de ella salen las dos velocidades clave para operar (#ref(<fig-05-cap02-curva-polar>, supplement: [Figura])):

- #strong[Velocidad de mínimo descenso (V\~z min\~):] está en el pico superior de la curva (el punto del eje Y más próximo a cero). Volando a esta velocidad pierdes la mínima altura por unidad de tiempo, así que es la que maximiza tu permanencia en el aire. Es tu referencia al virar de forma pronunciada dentro del núcleo de una térmica o en una espera.
- #strong[Velocidad de máximo planeo (V\~max planeo\~, también llamada de mejor planeo o de fineza):] se obtiene trazando una tangente desde el origen de coordenadas (0,0) hasta tocar la curva. Da la mejor relación entre distancia avanzada y altura perdida. Es la velocidad para las transiciones limpias y para conseguir el mayor recorrido posible sobre el terreno.

#figure([
#box(image("imagenes/05-cap02-curva-polar.jpg"))
], caption: figure.caption(
position: bottom, 
[
La curva polar de velocidades de un planeador
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap02-curva-polar>


== Eficiencia y el coeficiente de planeo (L/D)
<eficiencia-y-el-coeficiente-de-planeo-ld>
El coeficiente de planeo (L/D) expresa cuántos metros avanza el planeador por cada metro de altura perdida en aire en calma. Un planeador de escuela como el ASK 21 ronda 35:1 (recorre 35 km por cada kilómetro vertical cedido). Los de regata de clase abierta superan 60:1 gracias a su gran envergadura y perfil laminar.

En el aire real, las cifras del manual se quedan en teoría: el viento y las masas de aire en movimiento obligan a ajustar las velocidades.

- #strong[Viento de cara:] con viento en contra, el avance sobre el terreno disminuye aunque mantengas la misma velocidad aerodinámica. Vuela más rápido que la V\~max planeo\~: como regla práctica, suma un 50% de la componente frontal del viento a tu velocidad de transición (#ref(<fig-05-cap02-curva-polar-viento-de-cara>, supplement: [Figura])).

#figure([
#box(image("imagenes/05-cap02-curva-polar-viento-de-cara.png"))
], caption: figure.caption(
position: bottom, 
[
La curva polar de velocidades de un planeador con viento de cara
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap02-curva-polar-viento-de-cara>


- #strong[Viento de cola:] con viento a favor, el terreno avanza más deprisa de lo que la polar indica. Puedes volar algo más despacio que la V\~max planeo\~ en calma, pero nunca por debajo de la V\~z min\~. No es un ajuste grande; el margen sobre la pérdida siempre tiene prioridad.
- #strong[Aire descendente:] cuando atraviesas una masa de aire que baja, tu tasa de descenso real aumenta en esa misma cantidad. La velocidad óptima de cruce sube por encima de la V\~max planeo\~: vuela más rápido para salir cuanto antes de esa zona y limitar la altura perdida en ella.

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

Acostúmbrate a planificar los tramos finales y las tomas fuera de aeródromo con el L/D del manual recortado. Contar con la mitad del valor publicado en el Manual de Vuelo (AFM) te protege de quedarte bajo y corto cuando se suman el viento de cara, el aire que baja y la suciedad o los mosquitos acumulados en el borde de ataque, que merman el rendimiento más de lo que parece.

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
=== El lastre de agua y la curva polar
<el-lastre-de-agua-y-la-curva-polar>
Algunos planeadores llevan depósitos de agua en las alas. El lastre no cambia la forma del ala: simplemente pesa más, y eso empuja la curva polar hacia la derecha. La V\~max planeo\~ y la V\~z min\~ suben, y la tasa de descenso mínima también sube un poco.

¿Para qué sirve? En un día de térmicas fuertes con largas etapas entre ellas, el planeador lastrado cruza más rápido manteniendo el mismo planeo; en regata eso se traduce en minutos ganados. El precio: en térmicas débiles sube peor, porque necesita más velocidad y el círculo se come más altura. Antes de aterrizar, el lastre se larga.

El punto clave, y el que suele caer en el examen: #strong[el lastre no cambia el L/D máximo]. La fineza máxima es la misma con y sin agua; lo único que cambia es la velocidad a la que se obtiene, que sube con el peso. Por eso el planeador lastrado vuela más rápido «por el mismo planeo». El cálculo de masa y centrado que hace posible cargar ese lastre se desarrolla en el #strong[Libro 7 --- Planificación y rendimiento], capítulo 2.

=== Aerofrenos y flaps: modificar la polar a voluntad
<aerofrenos-y-flaps-modificar-la-polar-a-voluntad>
Dos dispositivos permiten al piloto cambiar la forma de la curva polar cuando le conviene:

- #strong[Aerofrenos (]airbrakes\*\* o #strong[spoilers])#strong[: al extenderse, destruyen sustentación y añaden mucha resistencia. La polar entera se desploma: para una misma velocidad, la tasa de descenso se dispara. Son la herramienta de control de senda en la aproximación ---permiten bajar sin acelerar--- y su efecto operativo en el circuito se detalla en el ]Libro 6 --- Procedimientos operativos\*\*.
- #strong[Flaps]: modifican la curvatura del perfil. En posición positiva aumentan la sustentación y desplazan la polar hacia velocidades bajas (útil en térmica); en posición negativa la reducen y la desplazan hacia velocidades altas (útil en transición rápida). No todos los veleros los llevan.

La descripción constructiva de estos dispositivos ---cómo son y cómo se accionan--- corresponde al #strong[Libro 8 --- Conocimiento de la aeronave], capítulo 5; aquí interesa su efecto aerodinámico sobre la polar y la pérdida.

== El factor de carga (n)
<el-factor-de-carga-n>
El #strong[factor de carga] (n) indica cuántas veces el peso del planeador está cargando sobre la estructura en cada momento. Se expresa en unidades #strong[g].

En vuelo recto y nivelado la sustentación iguala exactamente al peso: #strong[n = 1g]. En cuanto el planeador se inclina en un viraje, la fuerza centrífuga se suma a la gravedad y el factor de carga sube. En un viraje de 60° de inclinación, la estructura ---y el piloto--- soportan #strong[2g]: el planeador pesa estructuralmente el doble, y el ala debe generar el doble de sustentación. A 75° la carga llega casi a 4g (#ref(<fig-05-cap02-factor-de-carga-alabeo>, supplement: [Figura])).

#figure([
#box(image("imagenes/05-cap02-factor-de-carga-alabeo.png"))
], caption: figure.caption(
position: bottom, 
[
El factor de carga en función del ángulo de alabeo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap02-factor-de-carga-alabeo>


#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Cuando el factor de carga sube, la velocidad de pérdida (#strong[stall]) también sube ---y lo hace más rápido de lo que parece. La relación es con la raíz cuadrada del factor #strong[n]: en un viraje de 60° donde soportamos #strong[2g], nuestra velocidad de pérdida aumenta un #strong[41%]. Si normalmente perdemos a 60 km/h, en ese viraje la pérdida llega a 85 km/h, aunque el mando responda con aparente normalidad.

El patrón más letal de la estadística de accidentes en planeador es siempre el mismo: maniobra de aterrizaje, altura escasa, velocidad baja, y de repente una pisada brusca de pedales con alabeo exagerado. La pérdida llega sin avisar, y a esa altura no hay margen para recuperar.

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
#strong[Resumen del Capítulo: Mecánica de Vuelo]

- #strong[El motor es la gravedad]: el planeador siempre cae a través de la masa de aire. Convertimos altura (energía potencial) en velocidad (cinética) bajando el morro. La componente del peso hacia adelante actúa como "tracción".
- #strong[La curva polar]: es el DNI del planeador. Relaciona velocidad horizontal con tasa de caída. Te dice a qué velocidad volar para llegar más lejos (máximo planeo) o para mantenerte más tiempo (mínimo descenso).
- #strong[Eficiencia (L/D)]: la fineza. Un planeador 35:1 avanza 35 km por cada kilómetro de altura en aire calmo. Pero ojo: el viento de cara y las descendencias destruyen ese número en la práctica. Ajusta la velocidad de transición según el viento (más rápido con viento de cara y en aire descendente; algo más despacio con viento de cola) y descuenta siempre un margen de seguridad del L/D publicado.
- #strong[Lastre de agua]: desplaza la polar a la derecha: suben la V\~max planeo\~ y la V\~z min\~. Ventajoso en condiciones fuertes y largas transiciones; penaliza en térmicas débiles. Se larga antes del aterrizaje.
- #strong[Factor de carga (n)]: en giros o maniobras bruscas, el peso aparente aumenta (n \> 1g) y con él la velocidad de pérdida. Recuerda: en un viraje de 60° pesas el doble (2g) y tu velocidad de pérdida sube un 41%.

= Estabilidad
<estabilidad>
#quote(block: true)[
Un planeador bien diseñado quiere volver al equilibrio cuando algo lo perturba. En este capítulo aprenderás qué hace que un planeador sea estable longitudinal, lateral y direccionalmente, por qué la posición del Centro de Gravedad es el parámetro más crítico que debes verificar antes de cada vuelo, y cómo el ángulo diedro y la deriva trabajan juntos para mantenerte nivelado y alineado sin esfuerzo.
]

== La estabilidad estática
<la-estabilidad-estática>
La estabilidad de una aeronave es su capacidad inherente para recuperar el equilibrio tras una perturbación atmosférica. Cuando una racha de viento desplaza al planeador de su actitud nivelada, la respuesta inmediata de la máquina sin intervención del piloto se define como #strong[estabilidad estática].

Según su diseño, el comportamiento del planeador puede clasificarse en tres tipos:

- #strong[Estabilidad estática positiva:] el planeador tiende a regresar por sí solo a su posición inicial tras ser perturbado. Es la condición de diseño fundamental para la seguridad en aeronaves civiles.
- #strong[Estabilidad estática neutra:] la aeronave no intenta corregir la perturbación, pero tampoco la amplifica. Si una racha sube el morro 5 grados, el planeador se mantiene en esa nueva actitud sin retornar a la anterior ni seguir subiendo.
- #strong[Estabilidad estática negativa (inestabilidad):] la aeronave tiende a alejarse cada vez más de su posición de equilibrio original. Es una condición peligrosa: una pequeña perturbación de morro arriba haría que el planeador siguiera encabritándose de forma progresiva y acelerada.

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

Los veleros de escuela suelen diseñarse con una estabilidad estática positiva muy marcada para facilitar el aprendizaje y perdonar errores del alumno. Sin embargo, esto los hace más "pesados" o perezosos de mando. Los veleros de alta competición o acrobacia reducen esta estabilidad para ganar agilidad y respuesta inmediata.

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
== La estabilidad dinámica
<la-estabilidad-dinámica>
La estabilidad estática describe solo la #strong[reacción inicial] de la aeronave: si tiende a volver o a alejarse. La #strong[estabilidad dinámica] describe lo que ocurre a continuación, cuando el planeador comienza a oscilar mientras intenta regresar al equilibrio.

Según cómo evolucionen esas oscilaciones en el tiempo, el comportamiento puede clasificarse en tres tipos (#ref(<fig-05-cap03-estabilidad-dinamica>, supplement: [Figura])):

- #strong[Amortiguada (positiva):] las oscilaciones van reduciéndose progresivamente hasta que el planeador recupera su actitud original. Es la condición de diseño deseada.
- #strong[Neutra:] las oscilaciones se mantienen constantes en amplitud, sin crecer ni decrecer. El planeador nunca vuelve al equilibrio exacto, pero tampoco empeora.
- #strong[Divergente (negativa):] las oscilaciones crecen en amplitud con cada ciclo. Una perturbación pequeña se convierte en un movimiento cada vez mayor hasta perder el control.

#figure([
#box(image("imagenes/05-cap03-estabilidad-dinamica.png"))
], caption: figure.caption(
position: bottom, 
[
Respuesta dinámica de una aeronave: oscilación neutra, positiva y negativa (
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap03-estabilidad-dinamica>


Dos modos de oscilación merecen atención especial en un planeador:

- #strong[Modo fugoide:] una oscilación longitudinal lenta y de gran periodo (típicamente 30-60 segundos). El planeador sube y baja intercambiando altitud y velocidad en ciclos suaves. Su amortiguamiento es débil, pero el ciclo es tan lento que lo corriges sin darte cuenta con los pequeños ajustes de palanca de siempre; solo aflora si sueltas los mandos un buen rato.
- #strong[Tendencia espiral:] una inestabilidad dinámica lateral. La mayoría de los planeadores son estáticamente estables en alabeo, pero dinámicamente tienden a una ligera #strong[divergencia espiral]: si se les abandona con un pequeño ángulo de inclinación, el alabeo crece lentamente hasta convertirse en una espiral descendente. Por eso el piloto debe vigilar siempre la actitud lateral, especialmente en nube o al perder las referencias visuales del horizonte.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

La tendencia espiral es el origen de la mayoría de los incidentes por pérdida de control en condiciones de visibilidad reducida. Un planeador abandonado con cinco grados de alabeo puede, en cuestión de minutos, desarrollar una espiral descendente fatal. Nunca vueles sin referencias visuales del horizonte real.

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
== Estabilidad longitudinal: el papel del CG
<estabilidad-longitudinal-el-papel-del-cg>
La estabilidad longitudinal controla el cabeceo. El parámetro que lo determina es la posición del Centro de Gravedad (CG) respecto al Centro de Presiones (CP).

Para que el planeador sea estable en cabeceo, el #strong[CG debe situarse por delante del CP] en las condiciones normales de vuelo. Esa configuración crea un momento natural de "morro abajo". Para equilibrar el vuelo, el estabilizador horizontal genera una fuerza hacia abajo, manteniendo el planeador nivelado.

- #strong[CG demasiado adelantado:] aumenta la estabilidad, pero hace al planeador excesivamente "cabezón" y difícil de maniobrar, especialmente durante el despegue y el aterrizaje. La eficiencia L/D disminuye por el aumento de resistencia en la cola para compensar el peso del morro.
- #strong[CG demasiado atrasado:] es la condición crítica y peligrosa. Si el CG queda por detrás de los límites permitidos, el planeador se vuelve inestable: ante cualquier perturbación el morro tiende a subir de forma descontrolada. Y hay algo peor: si la pérdida degenera en barrena, el CG atrasado tiende a aplanarla, y una barrena plana deja a los mandos sin autoridad para romperla.

#block[
#callout(
body: 
[
⚖ #strong[NORMATIVA]

El Reglamento (UE) 2018/1976, Part-SAO, punto SAO.GEN.130 d)4), establece que el piloto al mando deberá "iniciar un vuelo únicamente tras cerciorarse de que \[…​\] la masa del planeador y la ubicación de su centro de gravedad permiten efectuar el vuelo dentro de los límites definidos por el manual de vuelo de la aeronave (AFM)".

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
== Estabilidad lateral: el efecto diedro
<estabilidad-lateral-el-efecto-diedro>
La estabilidad lateral es la tendencia del planeador a nivelar sus alas tras una perturbación que cause un alabeo no deseado. El principal recurso de diseño para lograr esto es el #strong[ángulo diedro].

El diedro es el ángulo hacia arriba que forman las alas respecto a la horizontal, otorgando al planeador una forma vista de frente similar a una "V" muy abierta (#ref(<fig-05-cap03-efecto-diedro>, supplement: [Figura])).

Cuando una racha inclina un ala (por ejemplo, la izquierda), el planeador comienza a resbalar lateralmente hacia ese lado. Debido al ángulo diedro, el ala que baja recibe el flujo de aire con un ángulo de ataque efectivo mayor que el ala que sube. Esto genera un exceso de sustentación en el ala bajada que empuja al planeador de vuelta a su posición nivelada de forma automática.

#figure([
#box(image("imagenes/05-cap03-efecto-diedro.jpg"))
], caption: figure.caption(
position: bottom, 
[
Efecto autonivelador del diedro positivo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap03-efecto-diedro>


== Estabilidad direccional: el efecto veleta
<estabilidad-direccional-el-efecto-veleta>
La estabilidad direccional asegura que el planeador vuele alineado con el viento relativo, evitando el vuelo cruzado. Este efecto se consigue mediante el estabilizador vertical o deriva.

La deriva actúa exactamente como una veleta. Al estar situada a gran distancia por detrás del Centro de Gravedad, cualquier guiñada no deseada expone la superficie lateral de la cola al viento relativo. La presión del aire sobre la aleta genera una fuerza que empuja la cola de vuelta, alineando automáticamente el morro del planeador con la dirección del avance (#ref(<fig-05-cap03-efecto-veleta>, supplement: [Figura])).

#figure([
#box(image("imagenes/05-cap03-efecto-veleta.png"))
], caption: figure.caption(
position: bottom, 
[
Efecto veleta: la deriva realinea el morro con el viento relativo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap03-efecto-veleta>


#strong[Resumen del Capítulo: Estabilidad]

- #strong[Estabilidad estática]: es la tendencia inicial. Si sueltas los mandos tras un bache y el avión tiende a volver a su posición original, es estable. Si tiende a alejarse más (divergencia), es inestable y peligroso.
- #strong[Estabilidad dinámica]: describe lo que pasa #strong[después] de la reacción inicial. ¿Las oscilaciones se amortiguan (bueno), se mantienen iguales (neutro) o crecen (peligroso)? El modo fugoide es una oscilación longitudinal lenta e inocua. La #strong[tendencia espiral] (divergencia lateral lenta) es la más importante: si sueltas los mandos con un pequeño alabeo, la espiral crece sola.
- #strong[El CG es el rey]: la posición del centro de gravedad determina la estabilidad longitudinal. CG adelantado = muy estable pero "pesado". CG atrasado = muy sensible e inestable (riesgo de barrena plana irrecuperable).
- #strong[Estabilidad lateral (diedro)]: la forma en "V" de las alas ayuda a nivelar el avión solo. Si un ala baja, el diedro hace que tenga más ángulo de ataque efectivo y suba.
- #strong[Estabilidad direccional]: la deriva (cola vertical) actúa como una veleta, manteniendo el morro apuntando al viento relativo y evitando el vuelo cruzado.

= Control
<control>
#quote(block: true)[
Los mandos de un planeador son mucho más que palancas y pedales: son el canal de comunicación entre el piloto y la aeronave. En este capítulo aprenderás a entender la guiñada adversa y cómo combatirla con coordinación pie-mano, por qué el compensador es una herramienta fundamental de pilotaje y no un descanso para el brazo, y qué información te transmiten los mandos a través de su dureza o blandura.
]

== Guiñada adversa: el precio del alabeo
<guiñada-adversa-el-precio-del-alabeo>
En los planeadores, la guiñada adversa es un efecto secundario aerodinámico muy pronunciado al intentar virar usando los alerones, debido a su gran envergadura.

Al accionar la palanca lateralmente para iniciar un giro, el alerón del ala exterior baja para aumentar la sustentación y levantar ese lado. El problema es que, al crear más sustentación, también genera una gran cantidad de #strong[resistencia inducida]. Esta resistencia frena el ala que sube y tira de ella hacia atrás, haciendo guiñar el morro del planeador en dirección opuesta al giro deseado (#ref(<fig-05-cap04-guinada-adversa>, supplement: [Figura])).

#figure([
#box(image("imagenes/05-cap04-guinada-adversa.png"))
], caption: figure.caption(
position: bottom, 
[
La guiñada adversa: el morro guiña al lado contrario del giro
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap04-guinada-adversa>


#block[
#callout(
body: 
[
✦ #strong[REGLA DE ORO]

La solución a la guiñada adversa es la #strong[Coordinación Pie-Mano]. Se debe aplicar palanca y pedal hacia el mismo lado y al mismo tiempo. El timón de dirección contrarresta el freno abrupto del ala exterior, forzando al morro a seguir la curva suavemente sin derrapar.

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
== Mando diferencial de alerones
<mando-diferencial-de-alerones>
Para mitigar la guiñada adversa de manera mecánica, los planeadores utilizan el #strong[mando diferencial de alerones].

Este sistema ajusta el varillaje de modo que el alerón que sube (en el ala interior del giro) recorra un ángulo mayor que el alerón que baja (en el ala exterior). Al subir más el alerón interior, se genera intencionadamente una mayor resistencia parásita en ese lado que ayuda a compensar la resistencia inducida del ala exterior. Aunque este diseño reduce notablemente la tendencia del morro a salirse del giro, no la elimina por completo; el piloto debe seguir aplicando siempre el timón de dirección (pedal) para mantener un viraje coordinado.

== El hilo de lana: tu indicador de coordinación
<el-hilo-de-lana-tu-indicador-de-coordinación>
En el parabrisas de casi todos los planeadores hay, pegado en el centro, un trocito de hilo de lana o cinta fina: el #strong[hilo de coordinación] (#strong[yaw string]). Es el indicador más directo que existe, más fiable incluso que la bola del inclinómetro.

Hilo recto: vuelo coordinado. Cuando se desvía, el hilo se va hacia el mismo lado al que apunta el morro respecto a la trayectoria: hilo a la izquierda, morro a la izquierda del viento relativo. Lo que eso significa depende del sentido del viraje. Hilo caído hacia el interior del giro: derrape (#strong[skid]), llevas demasiado pedal interior. Hilo hacia el exterior: resbale (#strong[slip]), te falta pedal. La corrección es siempre la misma: pisa el pedal contrario al lado del hilo, nunca la palanca.

El derrape es el que hay que evitar: el ala interior va más lenta y puede alcanzar el ángulo de ataque crítico sin previo aviso, iniciando una pérdida asimétrica. El resbale es más aparatoso ---el fuselaje ofrece más resistencia y el viraje es ineficiente---, pero rara vez es peligroso por sí solo. La #ref(<fig-05-cap04-hilo-lana-estados>, supplement: [Figura]) resume los tres estados del hilo y su lectura.

#figure([
#box(image("imagenes/05-cap04-hilo-lana-estados.png"))
], caption: figure.caption(
position: bottom, 
[
Los tres estados del hilo de lana: coordinado, derrape y resbale
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap04-hilo-lana-estados>


#block[
#callout(
body: 
[
✦ #strong[REGLA DE ORO]

Vuela con el hilo recto. Si se mueve, corrígelo con el pedal. Y si el hilo está torcido y los mandos están blandos al mismo tiempo, actúa: estás a punto de entrar en pérdida.

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
== El compensador (trim)
<el-compensador-trim>
El compensador (trim) no es solo un alivio para el brazo. Es, de hecho, un mando aerodinámico: equilibra las fuerzas en la cola y permite que el planeador mantenga por sí solo una actitud de morro y velocidad constantes sin que tengas que empujar ni tirar.

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

Acostúmbrate a usar el compensador constantemente. Después de cambiar el régimen de vuelo (por ejemplo, de termicar a velocidad lenta a volar recto a mayor velocidad), primero establece la nueva actitud con la palanca y luego ajusta el trim hasta que no sientas fuerza en la mano.

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
== La eficacia de mando
<la-eficacia-de-mando>
Los mandos te proporcionan información vital sobre la velocidad del planeador a través de su resistencia física.

Cuando vuelas rápido, el flujo de aire golpea con fuerza las superficies de control. Los mandos se sentirán #strong[duros] y muy reactivos.

Sin embargo, a medida que reduces la velocidad acercándote a la entrada en pérdida, el flujo de aire disminuye. Los mandos pierden eficacia y se vuelven blandos o #strong["chiclosos"]. Esta falta de respuesta es una advertencia física directa de que estás volando demasiado lento y cerca del límite de sustentación.

#strong[Resumen del Capítulo: Control]

- #strong[Guiñada adversa]: el efecto secundario más molesto en los veleros de gran envergadura. Al alabear para girar, el ala que sube tiene más resistencia y frena ese lado, metiendo el morro #strong[al revés] del giro. #strong[Antídoto]: pie y mano juntos (coordinación).
- #strong[Hilo de lana (]yaw string#strong[)]: indicador de coordinación en el parabrisas. Recto = vuelo coordinado. Hilo hacia el interior del viraje = derrape (#strong[skid]); hacia el exterior = resbale (#strong[slip]). El derrape es el peligroso: el ala interior puede entrar en pérdida asimétrica. Corrígelo pisando el pedal contrario al lado del hilo.
- #strong[Compensador (trim)]: no es solo para descansar el brazo. Es fundamental para mantener una velocidad constante sin esfuerzo. Compensa siempre que cambies de régimen de vuelo (de termicar a planear rápido).
- #strong[Eficacia de mando]: los mandos "hablan". Si están duros, vas rápido. Si están blandos y "chiclosos", estás cerca de la pérdida. Escucha lo que te dicen a través de la mano.
- #strong[Mando diferencial]: diseño de los alerones para reducir la guiñada adversa (el alerón que sube lo hace más que el que baja), pero aun así necesitarás pie.

= Limitaciones (factor de carga y maniobras)
<limitaciones-factor-de-carga-y-maniobras>
#quote(block: true)[
Todo planeador tiene límites estructurales que no deben franquearse: hacerlo puede destruir la aeronave en segundos. En este capítulo aprenderás a interpretar el diagrama V-n, a entender por qué la Velocidad de Maniobra protege la estructura en turbulencia, qué significa la línea roja del anemómetro y por qué el factor de carga eleva la velocidad de pérdida en los virajes.
]

== El diagrama V-n: el mapa de tu supervivencia
<el-diagrama-v-n-el-mapa-de-tu-supervivencia>
El diagrama V-n, también conocido como envolvente de vuelo, es la representación gráfica de los límites estructurales de tu planeador. Relaciona la velocidad a la que vuelas (V) con el factor de carga en Gs (n) que la estructura está soportando (#ref(<fig-05-cap05-diagrama-vn>, supplement: [Figura])).

Este diagrama delimita el espacio de operaciones seguras. Mientras te mantengas dentro de sus límites, la estructura aguantará. Si lo superas ---por exceso de G o de velocidad--- el planeador sufrirá deformaciones permanentes o rotura estructural.

Bajo la normativa CS-22, los planeadores de categoría Utility (U) están diseñados para soportar de +5,3g a −2,65g a la velocidad de maniobra (V#sub[A]); ambos límites se estrechan a medida que aumenta la velocidad, hasta +4,0g y −1,5g a la velocidad de picado (V#sub[D]). Los de categoría Acrobática (A) soportan de +7,0g a −5,0g. Estos factores de carga solo son válidos si se respetan las limitaciones de velocidad.

#figure([
#box(image("imagenes/05-cap05-diagrama-vn.png"))
], caption: figure.caption(
position: bottom, 
[
El diagrama V-n o envolvente de vuelo: límites estructurales del planeador. Las líneas curvas amarillas representan la sustentación máxima que el planeador puede generar a diferentes velocidades del aire en Gs. (Fuente: FAA Glider Flying Handbook)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap05-diagrama-vn>


== Velocidad de maniobra (V#sub[A])
<velocidad-de-maniobra-va>
La velocidad de maniobra (V es la velocidad máxima a la que puedes aplicar deflexiones totales en los mandos sin causar daños estructurales.

Si vuelas a la V#sub[A] o por debajo de ella y aplicas una deflexión brusca a los mandos, el planeador simplemente #strong[entrará en pérdida] antes de generar suficientes Gs para superar su límite de carga estructural. El ala dejará de volar y descargará la fuerza, protegiendo al planeador. Sin embargo, si vuelas más rápido que la V#sub[A] y haces un movimiento brusco, el planeador no entrará en pérdida a tiempo; generará una fuerza G extrema que sobrepasará los límites de la estructura y la romperá.

La V#sub[A] es un límite estructural, no una marca del anemómetro. La marca que ves en la esfera es la #strong[V#sub[RA]], la velocidad máxima en aire turbulento (#strong[rough air speed]): en ella termina el arco verde y empieza el amarillo, según CS 22.1545. En muchos veleros la V#sub[A] y la V#sub[RA] casi coinciden, pero la certificación las distingue, y conviene que tú también: la V#sub[A] te protege frente a la deflexión completa de un mando; la V#sub[RA], frente a las ráfagas del aire turbulento; y la VNE es el límite absoluto donde acaba el arco amarillo con su línea roja.

#block[
#callout(
body: 
[
✦ #strong[REGLA DE ORO]

En turbulencia fuerte, reduce enseguida la velocidad por debajo de la V#sub[A] para proteger la estructura. Tu referencia visual está en el anemómetro: quédate en el arco verde, que termina en la V#sub[RA] (velocidad máxima en aire turbulento). El arco amarillo, de la V#sub[RA] a la VNE, es solo para aire en calma.

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
⚠ #strong[SEGURIDAD]

La V#sub[A] #strong[no te protege de entradas combinadas simultáneas en más de un eje]. Los requisitos de certificación cubren deflexiones completas en un único mando a la vez. Si aplicas timón de profundidad a fondo y pedal a fondo #strong[al mismo tiempo] ---aunque estés por debajo de V#sub[A]--- puedes generar una carga estructural que supere el límite de diseño. En turbulencia, mantén los mandos suaves y evita movimientos bruscos coordinados en múltiples ejes simultáneamente.

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
== La línea roja: velocidad de nunca exceder (VNE)
<la-línea-roja-velocidad-de-nunca-exceder-vne>
La línea roja en el anemómetro indica la VNE (velocidad de nunca exceder). Es un límite absoluto que no se cruza nunca, principalmente por el riesgo de #strong[flutter] (flameo).

El flutter es una vibración aeroelástica en las alas o superficies de control que, si ocurre, puede desintegrar el planeador en cuestión de segundos.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

La VNE disminuye con la altitud: en aire menos denso, la velocidad aerodinámica verdadera (TAS) ---de la que depende el flutter--- aumenta respecto a la indicada (IAS) que lees en el anemómetro. Presta atención a la tabla de correcciones de VNE por altitud en la cabina. Este efecto es crítico en el vuelo de onda, donde se alcanzan grandes altitudes; su relación con la meteorología de onda se trata en el #strong[Libro 3 --- Meteorología].

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
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

Cerca de la VNE, mantén las deflexiones de mando limitadas a aproximadamente #strong[un tercio] de su recorrido total. A esa velocidad, la presión dinámica es tan elevada que una deflexión completa genera cargas que pueden superar la envolvente estructural incluso sin turbulencia. No uses la VNE como velocidad de crucero: es un límite absoluto de emergencia, no un régimen habitual.

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
== La trampa del factor de carga y la pérdida
<la-trampa-del-factor-de-carga-y-la-pérdida>
En vuelo recto y nivelado, el factor de carga es 1 G. Al inclinarte en un viraje, la fuerza centrífuga se suma a la gravedad y el factor de carga sube. En un viraje cerrado de 60°, el planeador experimenta 2 G: la estructura soporta el doble del peso normal.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

La velocidad de pérdida aumenta con el factor de carga. En un viraje de 60º (2 Gs), la velocidad de pérdida #strong[sube un 41%]. Un planeador que entra en pérdida a 70 km/h en vuelo nivelado lo hará a casi 100 km/h en ese viraje cerrado. Un uso brusco de los mandos en esta situación puede llevar a una pérdida crítica.

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
#strong[Resumen del Capítulo: Limitaciones y Maniobras]

- #strong[Diagrama V-n]: el mapa de seguridad de tu estructura. Muestra los Gs que aguantas a cada velocidad. Salirte de la "caja" significa romper el planeador. Límites CS-22: cat. U +5,3g / −2,65g en V#sub[A], que se estrechan a +4,0g / −1,5g en V#sub[D]\; cat. A +7,0g / −5,0g.
- #strong[Velocidad de maniobra (V#sub[A])]: la velocidad "segura" para turbulencia o mandazos individuales. Si vas más lento de V#sub[A], el planeador entrará en pérdida antes de romperse. Si vas más rápido, una deflexión brusca puede dañar la estructura. Pero cuidado: la V#sub[A] no protege de entradas combinadas simultáneas en más de un eje. En turbulencia fuerte, quédate en el arco verde del anemómetro.
- #strong[Marcas del anemómetro (CS 22.1545)]: el arco verde termina en la #strong[V#sub[RA]] (velocidad máxima en aire turbulento), donde empieza el arco amarillo, que acaba en la línea roja de la VNE. La V#sub[A] es un límite estructural y #strong[no] es una marca del anemómetro, aunque en muchos veleros su valor sea parecido al de la V#sub[RA].
- #strong[VNE (velocidad de nunca exceder)]: la #strong[línea roja] del anemómetro (CS 22.1505). No es una recomendación, es un límite físico. Pasarla invita al #strong[flutter] (vibración aeroelástica), que puede desintegrar el planeador en segundos. Cerca de la VNE, limita las deflexiones de mando a un tercio de su recorrido.
- #strong[Factor de carga y pérdida]: las Gs "engordan" al planeador. En un viraje de 60° (2 Gs), la velocidad de pérdida sube un 41%.

= Pérdida de sustentación y autorrotación
<pérdida-de-sustentación-y-autorrotación>
#quote(block: true)[
La pérdida de sustentación y la barrena son las situaciones más temidas por el piloto novel y las más practicadas en formación. En este capítulo aprenderás a reconocer los síntomas que avisan antes de que llegue la pérdida, a ejecutar la recuperación de forma correcta ---aunque vaya contra el instinto--- y a distinguir una pérdida limpia de una autorrotación para aplicar la técnica adecuada en cada caso.
]

== La pérdida de sustentación (stall)
<la-pérdida-de-sustentación-stall>
La pérdida de sustentación ocurre cuando el ala del planeador supera su #strong[Ángulo de Ataque Crítico] (aproximadamente entre 15º y 18º). Al alcanzar este punto crítico de inclinación respecto al viento relativo, el flujo de aire es incapaz de seguir la curvatura superior del ala (extradós) y se desprende de forma turbulenta, provocando una caída masiva de sustentación y un gran aumento de resistencia.

Aprende a leer estos síntomas: el planeador avisa antes de que llegue la pérdida.

- Posición inusualmente alta del morro respecto al horizonte.
- Velocidad muy baja en el anemómetro.
- Mandos de vuelo excesivamente blandos, esponjosos y poco eficaces.
- Ausencia del ruido normal del aire fluyendo por la cabina.
- Vibraciones estructurales conocidas como "bataneo", causadas por el aire turbulento golpeando el fuselaje y la cola.

La pérdida no llega de golpe en toda la envergadura: empieza en el #strong[encastre] ---la raíz donde el ala se une al fuselaje--- y avanza hacia las puntas. Es un diseño deliberado: el perfil tiene más ángulo de incidencia en la raíz que en las puntas, así que la raíz entra en pérdida primero. Los alerones, que están en las puntas, conservan algo de autoridad durante los primeros instantes: es un margen de diseño que te permite mantener las alas niveladas mientras la pérdida avisa. Pero si un ala llega a caer, no intentes levantarla con el alerón --- se sostiene con el pedal, como verás más abajo.

== Recuperación de la pérdida
<recuperación-de-la-pérdida>
El instinto ante la caída es tirar de la palanca. En aviación, eso agrava la situación. La única salida es reducir el ángulo de ataque.

Empuja la palanca hacia #strong[adelante] hasta centrarla: el morro baja, el ángulo de ataque disminuye y el aire vuelve a adherirse al extradós. El planeador gana velocidad arrastrado por la gravedad. Cuando recuperes una velocidad segura ---el proceso consume típicamente entre 30 y 50 metros de altura--- tira suavemente de la palanca para nivelar.

#block[
#callout(
body: 
[
⚓ #strong[AIRMANSHIP / BUENAS PRÁCTICAS]

Durante la recuperación de una pérdida, la palanca debe mantenerse siempre rigurosamente centrada en el eje lateral (cero alerones). Intentar levantar instintivamente un ala caída usando los alerones empeorará el escenario: el alerón que baja aumentará el ángulo de ataque local de esa ala caída, profundizando aún más su pérdida e iniciando violentamente la temida autorrotación o barrena. Usa siempre y exclusivamente el pedal contrario (timón de dirección) para evitar la guiñada y sostener las alas.

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
== La pérdida acelerada: el peligro del viraje
<la-pérdida-acelerada-el-peligro-del-viraje>
La velocidad de pérdida que indica el Manual de Vuelo es para vuelo recto y nivelado a 1g. Cada vez que el factor de carga sube, esa velocidad sube con él ---en proporción a su raíz cuadrada. En un viraje de 60° (2g), la velocidad de pérdida crece un 41%. Un planeador que en línea recta pierde sustentación a 70 km/h lo hará a casi 100 km/h en ese viraje. A 100 km/h nadie espera entrar en pérdida.

Esta #strong[pérdida acelerada] es traicionera porque el morro no tiene que estar especialmente alto. Con una actitud de morro aparentemente normal, tirar de palanca en un viraje cerrado puede superar el ángulo de ataque crítico sin que el piloto lo note hasta que el ala cede.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

El escenario estadísticamente más letal: el viraje del tramo #strong[base a final] en el circuito de tráfico, a menos de 150 metros de altura. El piloto mete pedal para cuadrar la final, el morro se desvía hacia un lado, compensa tirando de palanca… y el planeador entra en pérdida asimétrica sin margen de recuperación. Volar el circuito coordinado y con margen de velocidad no es una exigencia técnica: es lo que separa un aterrizaje normal de un accidente.

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
== Barrena: la pérdida agravada y asimétrica
<barrena-la-pérdida-agravada-y-asimétrica>
La barrena (también llamada autorrotación) es una condición de vuelo extrema que resulta de una #strong[pérdida de sustentación asimétrica]: un ala entra en pérdida más profundamente que la otra.

Generalmente se desencadena en vuelo turbulento o cuando el piloto vuela descoordinado (con exceso de pedal o cruzando mandos) cerca de la velocidad de mínima sustentación. El ala interior al giro, que ya viaja más lenta, entra en pérdida del todo y cae bruscamente. Al caer, su ángulo de ataque aumenta aún más y la ancla en la pérdida, mientras el ala exterior sigue volando parcialmente. Ese desequilibrio acopla guiñada y alabeo en una rotación muy rápida y un descenso vertiginoso: hasta 100 metros perdidos por cada vuelta de unos 4 segundos.

=== Las tres fases de la barrena
<las-tres-fases-de-la-barrena>
Hay que conocer las tres fases porque actuar en la primera cuesta mucho menos altura que hacerlo en la tercera:

- #strong[Fase incipiente:] la barrena está arrancando. Las fuerzas aún no se han estabilizado y el giro todavía no es constante. Recuperar aquí ---antes del primer giro completo--- cuesta mucha menos altura.
- #strong[Fase desarrollada:] el giro se asienta: velocidad angular, velocidad aerodinámica y tasa de descenso se estabilizan. El movimiento se vuelve regular. A partir de aquí, salir puede costar uno o más giros adicionales.
- #strong[Fase de recuperación:] desde que pisas el pedal hasta que el giro para. Puede durar desde un cuarto de vuelta hasta varios giros, según el planeador. Cada vuelta son entre 50 y 100 metros menos.

== Recuperación de la barrena
<recuperación-de-la-barrena>
La salida de una barrena exige una técnica metódica, contraintuitiva y aprendida de memoria. Consulta siempre el Manual de Vuelo (AFM) de tu planeador concreto; la secuencia clásica universal es:

+ #strong[Pedal contrario a fondo:] identifica la dirección de la rotación y pisa con decisión el pedal opuesto hasta el tope (si giras hacia la derecha, pedal izquierdo a fondo). Esto frena la guiñada que alimenta el giro.
+ #strong[Palanca al centro y adelante:] centra los alerones (neutro lateral) y empuja la palanca hacia adelante para reducir el ángulo de ataque y romper la pérdida profunda en ambas alas por igual.
+ #strong[Recuperación del picado:] en cuanto cese la rotación, #strong[neutraliza el pedal] antes de tirar de la palanca. Si mantienes el pedal contrario aplicado mientras recuperas del picado, la guiñada resultante puede iniciar una rotación en sentido opuesto. Una vez centrados los pedales, tira #strong[gradualmente] de la palanca para salir del picado con suavidad progresiva: una recuperación brusca puede sobrecargar la estructura o provocar una segunda pérdida.

#figure([
#box(image("imagenes/05-cap06-recuperacion-barrena.png"))
], caption: figure.caption(
position: bottom, 
[
Método estándar de recuperación de una barrena (método universal)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap06-recuperacion-barrena>


#strong[Resumen del Capítulo: Pérdida y Autorrotación]

- #strong[Pérdida (]stall#strong[)]: el ala se "rinde" al superar el ángulo de ataque crítico (≈ 15-18°). La pérdida comienza en el encastre y progresa hacia las puntas: por eso los alerones conservan algo de autoridad al inicio. Avisos: morro alto, mandos blandos y bataneo; al ceder el ala, cae el morro.
- #strong[Pérdida acelerada]: en un viraje cerrado (60° → 2g), la velocidad de pérdida sube un 41%. El ala puede entrar en pérdida con el morro en actitud aparentemente normal. El viraje #strong[base-final] en el circuito es el escenario más letal.
- #strong[Recuperación de la pérdida]: palanca adelante (bajar el morro) es la única cura. No uses los alerones para levantar un ala caída: profundizan la pérdida e inician la barrena.
- #strong[Barrena (autorrotación)]: pérdida agravada y asimétrica con tres fases: #strong[incipiente] (recuperable antes de un giro), #strong[desarrollada] (movimiento constante) y #strong[recuperación] (cesa la rotación). Cada vuelta cuesta 50-100 m de altura.
- #strong[Salida de barrena]: consulta siempre el AFM de tu planeador. La secuencia estándar: 1. pie contrario a la rotación (a fondo); 2. palanca al centro y adelante; 3. cuando pare el giro, #strong[neutraliza el pedal] y entonces recupera suavemente del picado.

= Picado en espiral
<picado-en-espiral>
#quote(block: true)[
El picado en espiral engaña al instinto del piloto: parece que hay que tirar de la palanca, pero esa reacción puede ser mortal. En este capítulo aprenderás a distinguirlo de una barrena, a entender por qué intentar subir el morro sin nivelar primero las alas agrava la situación, y a ejecutar la secuencia de recuperación correcta ---nivelar las alas, recuperar suave del picado y controlar la velocidad--- de forma procedimental y sin margen de error.
]

== Diferencias críticas: no es una barrena
<diferencias-críticas-no-es-una-barrena>
Es vital no confundir un picado en espiral (o espiral descendente) con una barrena.

En una barrena, el planeador está en pérdida asimétrica, cae verticalmente guiñando y su velocidad aerodinámica es baja y constante. Por el contrario, en un picado en espiral #strong[el planeador está volando]\; ninguna de sus alas está en pérdida. El planeador describe una trayectoria curva descendente cada vez más pronunciada en la que tanto la velocidad como el factor de carga (fuerzas G) aumentan de forma constante y rápida.

Aplicar la técnica de recuperación de la barrena (pisar el pedal contrario a fondo) en un picado en espiral es un error gravísimo que puede sobrecargar la cola y el timón a esas altas velocidades.

La herramienta de diagnóstico más rápida y fiable es el #strong[anemómetro] (#ref(<fig-05-cap07-espiral-vs-barrena>, supplement: [Figura])):

- #strong[Velocidad alta o creciendo] → espiral descendente. El planeador vuela y acelera.
- #strong[Velocidad baja y constante, en torno a la de pérdida o incluso menos] → barrena. El ala está en pérdida y la velocidad no puede aumentar.

#figure([
#box(image("imagenes/05-cap07-espiral-vs-barrena.png"))
], caption: figure.caption(
position: bottom, 
[
Espiral descendente vs.~barrena: diagnóstico por actitud, altímetro y trayectoria.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap07-espiral-vs-barrena>


== El peligro mortal del instinto
<el-peligro-mortal-del-instinto>
La espiral descendente ha recibido el apodo de "espiral del cementerio" en la aviación general por una buena razón: engaña al instinto de supervivencia del piloto desorientado.

Cuando el piloto percibe el morro apuntando hacia abajo y la velocidad disparándose, el instinto inmediato es tirar de la palanca para subir. Sin embargo, en un picado en espiral el planeador está fuertemente ladeado. Si tiras de la palanca #strong[sin haber nivelado antes las alas], el efecto es catastrófico: al estar de lado, el timón de profundidad empuja el planeador hacia el centro del giro, cerrando aún más el radio. La espiral se aprieta, la velocidad crece y las fuerzas G aumentan hasta superar el límite de diseño y romper la estructura.

#block[
#callout(
body: 
[
⚠ #strong[SEGURIDAD]

Nunca tires de la palanca de mando para intentar frenar un picado si las alas del planeador se encuentran inclinadas.

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
== La causa típica: pérdida de referencia visual
<la-causa-típica-pérdida-de-referencia-visual>
La situación clásica que desencadena una espiral descendente es la pérdida accidental de referencias visuales exteriores (VMC), como introducirse inadvertidamente en la base de una nube mientras se vira en una térmica fuerte.

Al perder el horizonte visual, el oído interno se desorienta rápidamente. El planeador, que habitualmente no es estable en espiral (tiende a aumentar gradualmente su ángulo de alabeo si se dejan sueltos los mandos en un viraje), comenzará a inclinarse y a bajar el morro de forma progresiva. El piloto desorientado no lo percibe hasta que el fuerte ruido aerodinámico y el aumento de la velocidad en el anemómetro revelan que el planeador está cayendo aceleradamente.

== Procedimiento de salida (recuperación)
<procedimiento-de-salida-recuperación>
La salida de un picado en espiral debe ejecutarse de forma procedimental, luchando activamente contra el instinto de tirar de la palanca en un primer momento:

+ #strong[Nivelar las alas:] es lo primero, porque el alabeo es lo que sostiene y aprieta la espiral. Aplica palanca lateral y pedal hacia el lado contrario del viraje, con decisión, hasta poner las alas completamente horizontales respecto a tu referencia o a los instrumentos.
+ #strong[Recuperar el picado:] solo cuando las alas estén a 0º de inclinación lateral, tira de la palanca con firmeza pero con suavidad para elevar el morro. Hazlo de forma progresiva, vigilando no superar factores de carga excesivos al salir de la trayectoria de picado.
+ #strong[Controlar la velocidad:] si la velocidad se aproxima a la V#sub[NE] (Velocidad Nunca Exceder), extiende los aerofrenos para frenar la aceleración; pero hazlo con suavidad, porque a alta velocidad y con factor de carga elevado una extensión brusca añade carga a la estructura.

#strong[Resumen del Capítulo: Picado en Espiral]

- #strong[Diagnóstico rápido --- mira el anemómetro]: velocidad alta o creciendo = espiral (el planeador vuela y acelera). Velocidad baja y constante = barrena (el ala está en pérdida, no puede acelerar). No las confundas: la técnica es opuesta.
- #strong[El peligro del instinto]: si tiras de la palanca para subir el morro sin nivelar antes las alas, solo cierras más la espiral y aumentas las Gs hasta el fallo estructural.
- #strong[Cómo salir]: 1. nivela las alas (alerones y pie coordinados al lado contrario del viraje) ---es lo primero, el alabeo sostiene la espiral---; 2. recupera suave del picado; 3. si la velocidad se acerca a la VNE, frena con aerofrenos (suavemente).
- #strong[Causa típica]: pérdida de referencia visual (nubes, noche) y distracción. El planeador tiene tendencia espiral; si lo dejas solo con un pequeño alabeo, la espiral crece sola.

#show: appendices.with("Apéndices", hide-parent: true)
#heading(level: 1, numbering: none)[Apéndices]
= Syllabus Oficial EASA - Principios de Vuelo
<syllabus-oficial-easa---principios-de-vuelo>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Principios de Vuelo] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- 5.1. Aerodinámica (flujo de aire).
- 5.2. Mecánica de vuelo.
- 5.3. Estabilidad.
- 5.4. Control.
- 5.5. Limitaciones (factor de carga y maniobras).
- 5.6. Pérdida de sustentación (Stalling) y autorrotación (Spinning).
- 5.7. Picado en espiral (Spiral Dive).

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

== Ponte a prueba
<ponte-a-prueba>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/05-principios-vuelo/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

= Glosario de términos
<glosario-de-términos>
Este glosario recoge las definiciones y acrónimos esenciales de la aerodinámica y los principios de vuelo aplicables a la licencia de piloto de planeador (SPL), organizados según el programa de formación EASA AMC1 SFCL.130. Cada definición incluye una referencia al capítulo donde el concepto se trata en profundidad.

/ \*\*\*\*Ángulo de ataque (AoA / #emph[Angle of Attack])\*\*\*\*: #block[
Ángulo que forma la cuerda aerodinámica del ala con la dirección del viento relativo. Es el parámetro aerodinámico más importante: de él dependen directamente el coeficiente de sustentación y el coeficiente de resistencia. Aumenta al tirar de la palanca; disminuye al empujarla. No confundirlo con la actitud del morro: un planeador puede tener el morro bajo y un ángulo de ataque peligrosamente alto si la trayectoria de descenso es más pronunciada que la actitud. La referencia es siempre el viento relativo, no el horizonte. (Mencionado en: cap. 6)
]

/ \*\*\*\*Ángulo de ataque crítico\*\*\*\*: #block[
Ángulo de ataque máximo que el ala puede soportar antes de que el flujo de aire se desprenda del extradós y la sustentación se destruya. Para la mayoría de los perfiles de planeador se sitúa entre 15° y 18°. Su superación, sea cual sea la velocidad, el peso o la altitud, provoca siempre la pérdida (#strong[stall]). (Mencionado en: cap. 6)
]

/ \*\*\*\*Autorrotación (#emph[spin])\*\*\*\*: #block[
Ver Barrena. Movimiento autosostenido de rotación y descenso producido por una pérdida asimétrica entre las dos alas: la guiñada y el alabeo se realimentan entre sí sin intervención del piloto. (Mencionado en: cap. 6)
]

/ \*\*\*\*Barrena (autorrotación / #emph[spin])\*\*\*\*: #block[
Condición de vuelo resultado de una pérdida de sustentación asimétrica. Un ala entra en pérdida más profundamente que la otra, cae bruscamente y su mayor ángulo de ataque la ancla en la pérdida, mientras la otra ala continúa volando parcialmente. El desequilibrio genera un acoplamiento intenso de guiñada y alabeo: rotación rápida y descenso de hasta 100 m por vuelta, completando cada giro en unos 4 segundos. Recuperación (en orden inamovible): pedal contrario a la rotación a fondo, palanca al centro y adelante, centrar pedales al cesar la rotación y recuperar suavemente del picado. (Mencionado en: cap. 6)
]

/ \*\*\*\*Bernoulli, teorema de\*\*\*\*: #block[
Principio de la física de fluidos que establece que, en un fluido en movimiento, un aumento de la velocidad del flujo se corresponde con una disminución de la presión estática. En aerodinámica explica parte de la sustentación: el aire que acelera sobre el extradós genera una zona de baja presión que aspira el ala hacia arriba. Se complementa con el efecto acción-reacción de Newton (deflexión del flujo hacia abajo en el borde de salida). (Mencionado en: cap. 1)
]

/ \*\*\*\*Capa límite\*\*\*\*: #block[
Delgada capa de aire que fluye directamente en contacto con la superficie del ala, donde la velocidad cae gradualmente desde la del flujo libre hasta cero en la superficie sólida. Puede ser #strong[laminar] (flujo ordenado, mínima resistencia) o #strong[turbulenta] (flujo caótico, mayor resistencia). El punto de transición entre ambos regímenes determina el rendimiento del perfil: un simple mosquito aplastado en el borde de ataque puede adelantarlo y degradar el planeo de forma medible. (Mencionado en: cap. 1)
]

/ \*\*\*\*CG (Centro de gravedad)\*\*\*\*: #block[
Punto teórico donde se considera aplicada la resultante de todas las fuerzas de gravedad que actúan sobre el planeador. Su ubicación longitudinal es clave para la estabilidad y el control del vuelo. (Mencionado en: cap. 3)
]

/ \*\*\*\*Centro de Presiones (CP)\*\*\*\*: #block[
Punto de la cuerda aerodinámica donde se considera aplicado el vector resultante de la sustentación total del ala. No es fijo: se desplaza hacia adelante al aumentar el ángulo de ataque y hacia atrás al disminuirlo. Su movilidad obliga a situar el CG delante de su rango de movimiento para mantener la estabilidad longitudinal. (Mencionado en: cap. 1, cap. 3)
]

/ \*\*\*\*Coeficiente de planeo (L/D, #emph[finesse])\*\*\*\*: #block[
Relación entre la sustentación (#emph[Lift]) y la resistencia total (#emph[Drag]) de la aeronave, equivalente a la distancia horizontal recorrida por unidad de altura perdida en aire en calma (un planeador con L/D de 40 recorre 40 km por cada kilómetro de altura cedida). (Mencionado en: cap. 2)
]

/ \*\*\*\*Compensador (#emph[trim])\*\*\*\*: #block[
Superficie de control secundaria ---o mecanismo de ajuste sobre la superficie principal--- que permite aliviar la presión sobre la palanca una vez establecida la actitud deseada. No es un accesorio de comodidad: es un mando aerodinámico fundamental que permite mantener una velocidad constante sin esfuerzo sostenido. Debe ajustarse cada vez que se cambia el régimen de vuelo. (Mencionado en: cap. 4)
]

/ \*\*\*\*Curva polar\*\*\*\*: #block[
Gráfica característica de cada modelo de planeador que relaciona la velocidad horizontal indicada (eje X, en km/h) con la tasa de descenso vertical (eje Y, en m/s) en condiciones de aire en calma. De ella se extraen la velocidad de mínimo descenso (vértice superior) y la velocidad de mejor planeo (tangente desde el origen). Es el "DNI" del planeador y la referencia para adaptar la velocidad al viento y a las zonas de ascenso o descenso. (Mencionado en: cap. 2)
]

/ \*\*\*\*Diagrama V-n (envolvente de vuelo)\*\*\*\*: #block[
Representación gráfica de los límites estructurales del planeador que relaciona la velocidad (V) con el factor de carga en Gs (n). Define la "caja" de operaciones seguras: dentro de la envolvente la estructura aguanta; fuera, se producen deformaciones permanentes o roturas. Según CS-22: categoría U (#emph[Utility]) soporta de +5,3g a −2,65g a la velocidad V#sub[A], límites que se estrechan a +4,0g y −1,5g a V#sub[D]\; categoría A (#emph[Acrobática]) de +7,0g a −5,0g. Estos límites solo son válidos respetando también los límites de velocidad. (Mencionado en: cap. 5)
]

/ \*\*\*\*Diedro (ángulo diedro)\*\*\*\*: #block[
Ángulo hacia arriba que forman las alas respecto al plano horizontal, dando al planeador una forma de "V" abierta vista de frente. Proporciona estabilidad lateral: cuando un ala baja por una perturbación, recibe el flujo de aire con mayor ángulo de ataque efectivo, genera más sustentación y vuelve a la posición nivelada sin intervención del piloto. (Mencionado en: cap. 3)
]

/ \*\*\*\*Deriva\*\*\*\*: #block[
Desviación lateral de la trayectoria del planeador respecto al suelo provocada por el viento de costado (en navegación). En aerodinámica, se refiere a la superficie fija vertical de la cola (estabilizador vertical) que aporta estabilidad de guiñada. (Mencionado en: cap. 3)
]

/ \*\*\*\*Efecto suelo (#emph[ground effect])\*\*\*\*: #block[
Mejora transitoria de la eficiencia aerodinámica que experimenta el planeador cuando vuela por debajo de una envergadura de ala sobre el terreno. El suelo actúa como barrera que comprime los torbellinos de punta de ala, reduce el #emph[downwash] y disminuye la resistencia inducida. Como resultado, el planeador "flota" más de lo esperado: una entrada larga o con exceso de velocidad puede añadir centenares de metros de rodada. (Mencionado en: cap. 1)
]

/ \*\*\*\*Efecto veleta\*\*\*\*: #block[
Tendencia del planeador a alinearse automáticamente con la dirección del viento relativo gracias a la deriva. La distancia entre el CG y la deriva actúa como brazo de palanca que amplifica la fuerza correctora. Es el mecanismo que proporciona la estabilidad direccional del planeador. (Mencionado en: cap. 3)
]

/ \*\*\*\*Eficacia de mando\*\*\*\*: #block[
Grado de respuesta de las superficies de control en función de la velocidad de vuelo. A alta velocidad, la presión dinámica es mayor y los mandos están duros y muy reactivos. A baja velocidad, disminuye y los mandos se vuelven blandos o "chiclosos". Esta pérdida de eficacia próxima a la velocidad de pérdida es una advertencia física directa: el ala se acerca al ángulo de ataque crítico. (Mencionado en: cap. 4)
]

/ \*\*\*\*Espiral del cementerio (#emph[graveyard spiral])\*\*\*\*: #block[
Ver Picado en espiral. Nombre popular del picado en espiral, que alude a la tendencia mortal de tirar de la palanca sin nivelar previamente las alas, apretando la espiral hasta el fallo estructural. (Mencionado en: cap. 7)
]

/ \*\*\*\*Estabilidad dinámica\*\*\*\*: #block[
Comportamiento de la aeronave en el tiempo tras una perturbación. Si las oscilaciones se amortiguan progresivamente, la estabilidad dinámica es #strong[positiva]\; si se mantienen, es #strong[neutra]\; si crecen, es #strong[negativa] o divergente. Modos relevantes para el planeador: el fugoide (oscilación longitudinal lenta e inocua) y la tendencia espiral (divergencia lateral que puede derivar en picado en espiral si no se supervisa). (Mencionado en: cap. 3)
]

/ \*\*\*\*Estabilidad estática\*\*\*\*: #block[
Tendencia inicial de la aeronave a responder a una perturbación. Si tiende a volver a su posición de equilibrio, la estabilidad estática es #strong[positiva]\; si se queda en la nueva posición, es #strong[neutra]\; si se aleja aún más del equilibrio, es #strong[negativa]. La estabilidad estática positiva es la condición de diseño fundamental de todos los planeadores civiles de entrenamiento. (Mencionado en: cap. 3)
]

/ \*\*\*\*Factor de carga (n)\*\*\*\*: #block[
Relación entre la sustentación aerodinámica total y el peso del planeador, expresada en unidades #emph[g]. En vuelo recto y nivelado: n = 1g. En un viraje de 60° de inclinación: n = 2g. El factor de carga eleva la velocidad de pérdida en proporción a su raíz cuadrada: a 2g, sube un 41%. Deflexiones bruscas y maniobras mal coordinadas en turbulencia pueden superar los límites del diagrama V-n.~(Mencionado en: cap. 2, cap. 5)
]

/ \*\*\*\*Flutter (Flameo aeroelástico)\*\*\*\*: #block[
Fenómeno físico de oscilaciones aeroelásticas autoexcitadas e inestables que afectan a las superficies sustentadoras o de control del planeador al superar la VNE, pudiendo destruir la estructura en segundos debido a la interacción del flujo de aire a alta velocidad con la flexibilidad estructural. (Mencionado en: cap. 5)
]

/ \*\*\*\*Fugoide (modo fugoide)\*\*\*\*: #block[
Modo de oscilación longitudinal lento y de largo período (30-50 segundos) en el que el planeador intercambia altitud y velocidad en ciclos suaves. Generalmente bien amortiguado y apenas perceptible si el piloto mantiene los mandos sujetos. No es peligroso por sí mismo, pero puede desconcertar al piloto inexperto que intenta corregirlo con entradas bruscas. (Mencionado en: cap. 3)
]

/ \*\*\*\*Guiñada adversa (#emph[adverse yaw])\*\*\*\*: #block[
Efecto secundario indeseable al accionar los alerones para iniciar un viraje. El alerón que baja (ala exterior) genera más sustentación y también más resistencia inducida, frenando ese lado y tirando del morro en dirección contraria al giro. Es especialmente pronunciado en planeadores de gran envergadura. Se corrige con coordinación pie-mano: aplicar palanca y pedal en la misma dirección simultáneamente. (Mencionado en: cap. 4)
]

/ \*\*\*\*IAS (Velocidad indicada / Indicated Air Speed)\*\*\*\*: #block[
Velocidad de la aeronave respecto al aire circundante tal como la indica el anemómetro, sin correcciones por temperatura ni densidad. Es la referencia para todos los límites aerodinámicos y estructurales (VNE, VA, velocidades de pérdida y curva polar). (Mencionado en: cap. 5)
]

/ \*\*\*\*Mando diferencial de alerones\*\*\*\*: #block[
Sistema de varillaje que hace que el alerón que sube (ala interior del giro) recorra un ángulo mayor que el alerón que baja (ala exterior). Al generar más resistencia parásita en el ala interior, compensa parcialmente la resistencia inducida del ala exterior y reduce la guiñada adversa de forma mecánica. No la elimina completamente: la coordinación pie-mano sigue siendo necesaria. (Mencionado en: cap. 4)
]

/ \*\*\*\*Pérdida de sustentación (#emph[stall])\*\*\*\*: #block[
Condición aerodinámica que se produce cuando el ángulo de ataque supera el valor crítico (≈ 15°--18°) y el flujo de aire se desprende de forma turbulenta del extradós del ala. La sustentación cae drásticamente y la resistencia se dispara. Síntomas previos: morro alto, velocidad baja, mandos blandos y bataneo estructural. Recuperación: palanca adelante para reducir el ángulo de ataque. Nunca usar los alerones para levantar un ala caída durante la pérdida. (Mencionado en: cap. 6)
]

/ \*\*\*\*Picado en espiral (#emph[spiral dive])\*\*\*\*: #block[
Condición de vuelo en la que el planeador, inclinado lateralmente, describe una trayectoria curva descendente con velocidad y factor de carga crecientes. El planeador #emph[vuela] ---no está en pérdida---. Diagnóstico clave: velocidad alta o creciendo = espiral; velocidad baja y constante = barrena. El tratamiento es el opuesto en cada caso, por lo que confundirlos es letal. Recuperación de la espiral: abrir aerofrenos, nivelar alas primero, recuperar suavemente del picado. (Mencionado en: cap. 7)
]

/ \*\*\*\*Resistencia inducida\*\*\*\*: #block[
Componente de la resistencia aerodinámica que es subproducto directo de generar sustentación. Las diferencias de presión entre extradós e intradós hacen que el aire fluya alrededor de las puntas del ala formando torbellinos helicoidales que inclinan el vector de sustentación hacia atrás, creando una fuerza opuesta al avance. Es máxima a velocidades bajas; disminuye al aumentar la velocidad. Las alas de gran envergadura (alta relación de aspecto) la reducen notablemente. (Mencionado en: cap. 1)
]

/ \*\*\*\*Resistencia parásita\*\*\*\*: #block[
Componente de la resistencia aerodinámica debida al movimiento del planeador a través del aire, independientemente de la sustentación generada. Incluye la fricción superficial, la resistencia de forma y la resistencia de interferencia entre superficies. Aumenta con el cuadrado de la velocidad: si la velocidad se dobla, la resistencia parásita se cuadruplica. A alta velocidad domina sobre la resistencia inducida. (Mencionado en: cap. 1)
]

/ \*\*\*\*Sustentación (#emph[lift])\*\*\*\*: #block[
Fuerza aerodinámica perpendicular a la dirección del viento relativo que se opone al peso y mantiene al planeador en vuelo. Se genera por la diferencia de presión entre extradós (baja presión, flujo acelerado) e intradós (alta presión, flujo más lento), según el teorema de Bernoulli, combinada con la deflexión del flujo hacia abajo en el borde de salida (tercera ley de Newton). Depende de la densidad del aire, la velocidad al cuadrado, la superficie alar y el coeficiente de sustentación. (Mencionado en: cap. 1)
]

/ \*\*\*\*Tendencia espiral\*\*\*\*: #block[
Característica de estabilidad dinámica lateral presente en la mayoría de los planeadores: si se les abandona con un pequeño ángulo de inclinación, el alabeo crece lentamente hasta desarrollar un picado en espiral. El planeador es estáticamente estable en alabeo pero dinámicamente divergente en espiral cuando se deja sin supervisión. Es la causa fundamental de los accidentes por pérdida de control en condiciones de visibilidad reducida. (Mencionado en: cap. 3, cap. 7)
]

/ \*\*\*\*Torbellinos de punta de ala (#emph[wingtip vortices])\*\*\*\*: #block[
Vórtices helicoidales que se generan en cada punta de ala por la diferencia de presión entre extradós e intradós: el aire fluye alrededor de la punta desde la zona de alta presión (intradós) hacia la de baja (extradós). Al desprenderse hacia atrás inclinan el vector de sustentación, generando la resistencia inducida. A escala mayor, los torbellinos de punta de aeronaves pesadas constituyen la turbulencia de estela, cuya peligrosidad en entornos de aeródromo mixto no debe subestimarse. (Mencionado en: cap. 1)
]

/ \*\*\*\*VA (Velocidad de maniobra / Maneuvering Speed)\*\*\*\*: #block[
Velocidad máxima a la que pueden aplicarse deflexiones totales en un solo mando sin causar daños estructurales. Por debajo de VA, ante una deflexión brusca completa, el planeador entra en pérdida antes de generar suficientes Gs para superar su límite de carga. Por encima de VA, esa protección desaparece. Importante: la VA no cubre entradas simultáneas en más de un eje de control; incluso por debajo de VA, combinar timón y palanca a fondo puede superar los límites estructurales. (Mencionado en: cap. 5)
]

/ \*\*\*\*VRA (Velocidad máxima en aire turbulento / Rough Air Speed)\*\*\*\*: #block[
Velocidad máxima a la que puede volarse en aire turbulento. Es la marca que separa los arcos del anemómetro según CS 22.1545: en la VRA termina el arco verde (operación normal) y empieza el amarillo (precaución, solo aire en calma). No debe confundirse con la VA, que es un límite estructural frente a deflexiones de mando y no se marca en la esfera, aunque en muchos veleros ambas tengan valores próximos. (Mencionado en: cap. 5)
]

/ \*\*\*\*Velocidad de mínimo descenso (Minimum Sink Speed)\*\*\*\*: #block[
Velocidad a la que el planeador pierde la menor cantidad de altura posible por unidad de tiempo (obtenida en el vértice superior de la curva polar), óptima para centrar y explotar térmicas débiles. (Mencionado en: cap. 2)
]

/ \*\*\*\*Velocidad de mejor planeo (V#sub[G])\*\*\*\*: #block[
Velocidad a la que el planeador obtiene su máxima distancia recorrida por unidad de altura perdida en aire en calma (máxima fineza, correspondiente al L/D máximo determinado por la tangente a la curva polar). (Mencionado en: cap. 2)
]

/ \*\*\*\*VNE (Velocidad de nunca exceder / Never Exceed Speed)\*\*\*\*: #block[
Límite absoluto de velocidad del planeador, indicado por la línea roja en el anemómetro. Superarla expone el planeador al riesgo de flutter aeroelástico, que puede desintegrar la estructura en segundos, sin previo aviso. La VNE disminuye con la altitud porque la TAS crece respecto a la IAS en aire menos denso. Cerca de la VNE, las deflexiones de mando deben limitarse a un tercio de su recorrido total. Regulada en CS-22.1505. (Mencionado en: cap. 5)
]

/ \*\*\*\*Viento relativo (#emph[relative wind])\*\*\*\*: #block[
Dirección y velocidad del flujo de aire que incide sobre el ala, opuesta a la trayectoria de vuelo real del planeador. El ángulo de ataque se mide siempre respecto al viento relativo, nunca respecto al horizonte ni a la actitud del morro. Un planeador puede tener el morro arriba y aun así tener el viento relativo proveniente de arriba si la trayectoria real es ascendente; a la inversa, puede tener el morro bajo y un ángulo de ataque peligrosamente alto si la trayectoria de descenso es más pronunciada que la actitud. (Mencionado en: cap. 6)
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
