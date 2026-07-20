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
// Cajas de la página de créditos: la exención de responsabilidad, la validación y la
// banda con el nombre de la licencia.
//
// ⚠️ El import propio no es redundante. Quarto coloca los `include-in-header`
// (esto) ANTES de su `#import "@preview/fontawesome:0.5.0": *` en el index.typ
// generado —línea ~480 frente a ~653—, y Typst usa ámbito léxico: una función
// definida aquí no vería los `fa-*` de aquel import. Sin esta línea, el render
// muere con `unknown variable: fa-exclamation-triangle`. Importar dos veces el
// mismo paquete no molesta.
#import "@preview/fontawesome:0.5.0": fa-creative-commons, fa-creative-commons-by, fa-creative-commons-sa, fa-exclamation-triangle

// La exención NO es una quinta admonition, y por eso no usa `::: {.callout-*}`.
// La colección tiene 319 admonitions y exactamente cuatro títulos —Seguridad,
// Normativa, Regla de oro, Airmanship—: es una taxonomía cerrada del temario, y
// un aviso legal no pertenece a ella. Es la misma razón por la que «más allá del
// examen» tiene su propio color y no es un recuadro más.
//
// Lo que sí toma prestada es la paleta de `callout-warning` (fondo #fcefdc,
// acento #EB9113): es la que el ojo ya asocia a «cuidado» en este libro, y
// repetirla evita inventar un quinto color.
#let aviso-legal(body) = block(
  fill: rgb("#fcefdc"),
  stroke: 1pt + rgb("#EB9113"),
  radius: 4pt,
  inset: (x: 0.5cm, y: 0.35cm),
  width: 100%,
  above: 0.5em,
  below: 0.9em,
  breakable: true,
  grid(
    columns: (auto, 1fr),
    gutter: 0.55cm,
    // El icono va centrado sobre el alto del texto, no pegado arriba: el bloque
    // es una unidad y el triángulo la señala entera.
    align(horizon, text(size: 22pt, fill: rgb("#EB9113"), fa-exclamation-triangle())),
    {
      // Dentro de una caja, la sangría de primera línea descoloca el primer
      // renglón contra el borde.
      set par(first-line-indent: 0em)
      set list(spacing: 0.6em, marker: [--])
      body
    },
  ),
)

// La validación, en gris: es información institucional, no una advertencia.
//
// luma(243) es el mismo gris de «más allá del examen», y por el mismo motivo:
// por encima de ~luma(235) el fondo compite con el texto en impresión y por
// debajo de ~luma(248) no se distingue del papel.
//
// Sin logotipo a propósito. El único disponible no es el de AESA sino la banda
// entera del Estado (escudo + Ministerio + AESA), y afirmaría un respaldo más
// amplio que la validación de los temarios indicada en el texto.
#let aval(body) = block(
  fill: luma(243),
  stroke: (left: 3pt + rgb("#0074D9")),
  radius: (right: 2pt),
  inset: (x: 0.5cm, y: 0.35cm),
  width: 100%,
  above: 0.5em,
  below: 0.9em,
  breakable: true,
  {
    set par(first-line-indent: 0em)
    body
  },
)

// La banda con el nombre de la licencia, encabezando sus condiciones.
//
// Los glifos de Creative Commons son de la fuente *Brands*; el triángulo de
// arriba es de *Free-Solid*. Quarto entrega las dos a Typst con --font-paths,
// pero ningún PDF de la colección usaba un glifo Brands hasta ahora: si algún
// día dejaran de llegar, Typst NO falla, cae a otra fuente en silencio y salen
// cuadraditos. Se comprueba mirando la página, no el código de salida.
#let licencia-cc(body) = block(
  fill: rgb("#EAF2FB"),
  radius: 3pt,
  inset: (x: 0.5cm, y: 0.4cm),
  width: 100%,
  above: 0.5em,
  below: 0.9em,
  breakable: false,
  grid(
    columns: (auto, 1fr),
    gutter: 0.45cm,
    align(horizon, text(size: 15pt, fill: rgb("#0074D9"))[
      #fa-creative-commons()#h(0.12em)#fa-creative-commons-by()#h(0.12em)#fa-creative-commons-sa()
    ]),
    align(horizon, {
      set par(first-line-indent: 0em)
      body
    }),
  ),
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
// Alcance: esta regla es GLOBAL y alcanza a cualquier lista de definición del
// libro, no sólo al glosario. Los ': ' de los capítulos son pies de tabla de
// Quarto: comparten sintaxis pero no generan `terms`, así que no le afectan.
//
// La excepción son los créditos de los reconocimientos, que también son una
// lista de términos y no deben salir con este aspecto. `creditos()`, en
// preliminares.typ, redefine `terms.item` dentro de su bloque y sobrescribe
// esta regla sólo ahí. Si se añade otra lista de definición fuera del glosario,
// hereda esto salvo que haga lo mismo.
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
// Marca «Más allá del examen»: contenido que excede el mínimo del syllabus
// (índices de sondeo TT/K/CAPE/LI y Skew-T, triángulo FAI/AAT, registradores
// IGC y récords FAI…). Es formación real de vuelo de distancia, pero no hay
// certeza de que los examinadores la incluyan, y el alumno debe saberlo para no
// estudiarla con la misma prioridad. Por coherencia, este material tampoco se
// recoge en el resumen (`postit`) del capítulo.
//
// En el AsciiDoc original (aesa-spl-oficial/recursos/GUIA_ESTILO.md) la marca
// era sólo una entradilla en línea violeta, y **se descartó a propósito la
// variante en recuadro**: el estilo de sidebar de asciidoctor-pdf forzaba su
// propio color y no era fiable. Esa limitación era de la herramienta, no de la
// idea: aquí el fondo sí se controla, así que la sección avanzada entera —con
// sus subsecciones— va sobre gris y la entradilla se conserva dentro.
//
// El gris es luma(243): a partir de ~luma(235) el fondo empieza a competir con
// el texto en impresión, y por debajo de ~luma(248) no se distingue del papel.

// La sección avanzada completa. `breakable: true` es obligatorio: la sección de
// «Índices de estabilidad» (03, cap03) ocupa varias páginas y un bloque no
// partible la empujaría entera a la siguiente, dejando un hueco enorme.
//
// El `inset` negativo en horizontal no se usa: el bloque ocupa el ancho del
// texto y sangra hacia dentro, de modo que el gris no toca los márgenes ni pelea
// con marginalia.
#let mas-alla(body) = block(
  breakable: true,
  width: 100%,
  fill: luma(243),
  radius: 2pt,
  inset: (x: 0.6cm, top: 0.5cm, bottom: 0.6cm),
  above: 1.2em,
  below: 1.2em,
  body,
)

// La entradilla. Violeta #6A1B9A y cuerpo menor, tal cual el rol
// `mas-alla-tag` del tema original: es un color distinto de los cuatro de las
// admonitions a propósito, para que no se confunda con ellas. No lleva icono ni
// caja propia.
#let mas-alla-tag(body) = text(
  fill: rgb("#6A1B9A"),
  weight: "bold",
  size: 0.85em,
  body,
)
// Resumen de capítulo con aspecto de post-it, como en el AsciiDoc original.
//
// Colores tomados literalmente del tema de origen
// (aesa-spl-oficial/recursos/temas/pdf-theme.yml, rol `postit`):
//   fondo #FFF9C4, borde #FBC02D 1pt, radio 4pt, texto #5D4037 a 10.5pt.
//
// La única desviación es la fuente. El tema pedía Roboto; aquí se usa Libertinus
// Sans, que mantiene el contraste de palo seco contra el cuerpo en serifa.
//
// ⚠️ Este comentario decía que Libertinus Sans «viaja dentro de Typst». Era
// FALSO, y el error costó meses de PDF mal compuestos: Typst empotra Libertinus
// **Serif**, no Sans (`typst fonts --ignore-system-fonts` lo lista). Estaba en la
// máquina de desarrollo y no en el runner, así que los 76 post-it de la colección
// se publicaron en serifa —Typst no falla ante una fuente ausente: cae a otra en
// silencio— y el razonamiento por el que se descartó Roboto se aplicaba, sin que
// nadie lo viera, a la fuente que se eligió en su lugar.
//
// Ahora la fuente viaja en el repo (`recursos/fuentes/`) y el CI la instala antes
// de compilar. Cualquier fuente que no esté tumba el build: hay un guardián que
// falla si Typst avisa de `unknown font family`.
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
    // set text en vez de text(): la variante función envuelve el contenido en
    // un elemento de texto que interfiere con el motor matemático de Typst,
    // impidiendo que \sqrt, \times y otros comandos se compongan en su fuente
    // matemática (NewCMMath). Con set text, las propiedades se heredan en el
    // ámbito pero el motor matemático sigue funcionando independientemente.
    set text(font: "Libertinus Sans", size: 10.5pt, fill: rgb("#5D4037"))
    set par(first-line-indent: 0em)
    body
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
  // page() —la función, no el `set`— compone una página con sus propias reglas
  // sin tocar las del resto del libro. Así se quitan folio y encabezado, que por
  // convención no llevan las páginas de cortesía. El contador de página sigue
  // avanzando: la página se cuenta, sólo que no se imprime su número.
  page(header: none, footer: none, numbering: none)[
    // Centrada verticalmente: mismo muelle arriba que abajo.
    #v(1fr)
    #block(width: 100%, inset: (right: 0.5cm))[
      #set align(right)
      #set par(first-line-indent: 0em, justify: false, leading: 0.8em)
      #set text(size: 1.45em, style: "italic")
      #body
    ]
    #v(1fr)
  ]
}

// Epígrafe: la cita va en su propia página, más discreta que la dedicatoria y
// desplazada hacia el primer tercio, que es donde se coloca por convención.
#let epigrafe(body) = {
  pagebreak(to: "odd")
  page(header: none, footer: none, numbering: none)[
    #v(1fr)
    #block(width: 100%, inset: (left: 4cm))[
      #set align(left)
      #set par(first-line-indent: 0em, justify: false, leading: 0.75em)
      #set text(size: 1.05em, style: "italic")
      #body
    ]
    #v(3fr)
  ]
}

// Página de créditos. Letra menor que el cuerpo, como es costumbre, para que no
// compita con el contenido; sin justificar, porque a este cuerpo la justificación
// abre calles blancas.
//
// La página salía amontonada, y NO era la interlínea: a 8.5pt con leading 0.7em
// daba un 135,8 %, dentro de la banda 120-150 % que se recomienda. Amontonaban
// otras tres cosas —medidas, no supuestas—:
//
//   1. el cuerpo a 8.5pt, un 15 % menor que el libro;
//   2. `spacing: 0.9em` sobre 8.5pt = 7,65pt entre párrafos, frente a los 10,5pt
//      del libro: un 27 % más apretado en absoluto;
//   3. y sobre todo, que los rótulos de sección eran párrafos en negrita con la
//      misma separación que cualquier otro. Nada los distinguía del texto que
//      los rodeaba, así que las secciones no se veían.
//
// Comprimir tampoco hacía falta: medida sobre el PDF, la página ocupaba 17,5 de
// los 24,7 cm útiles. Sobraban 7,2 cm, casi un 30 % de la caja.
//
// Ahora 9.5pt con leading 0.75em = 140,8 %, la misma interlínea que el cuerpo
// del libro (medido con el método del CLAUDE.md: los porcentajes NO se deducen
// del valor de `leading`).
#let licencia(body) = {
  set par(first-line-indent: 0em, justify: false, leading: 0.75em, spacing: 1.05em)
  set text(size: 9.5pt)
  show strong: it => text(weight: "bold", it.body)
  set list(spacing: 0.75em, marker: [--])

  // Los rótulos de sección se escriben como `## Rótulo {.unnumbered .unlisted}`
  // y no como negrita suelta, para que el EPUB tenga un h2 real al que
  // engancharse: a una negrita no hay forma de darle estilo.
  //
  // ⚠️ orange-book trae UNA regla global `show heading:` que ramifica por nivel,
  // con una rama para los niveles 2-4 (lib.typ:459). Sin anularla, estos
  // rótulos saldrían compuestos como secciones de capítulo. La regla de aquí
  // devuelve un bloque —contenido que ya NO es un heading—, así que la de
  // orange-book deja de casar con él y no llega a aplicarse.
  //
  // Sans y mayúsculas con tracking: se ven de un vistazo sin necesidad de un
  // cuerpo grande, que en cuatro rótulos seguidos daría aspecto de escalera. La
  // separación la da el aire de encima, que es lo que faltaba.
  show heading.where(level: 2): it => block(width: 100%, above: 1.6em, below: 0.7em)[
    #text(
      font: "Libertinus Sans",
      size: 0.92em,
      weight: "bold",
      tracking: 0.08em,
      fill: rgb("#0074D9"),
      upper(it.body),
    )
    #v(0.3em, weak: true)
    #line(length: 100%, stroke: 0.5pt + luma(200))
  ]

  body
}

// Créditos personales de los reconocimientos: nombre destacado y, debajo y
// sangradas, las titulaciones y el cargo. Es la forma habitual del apartado en
// un libro técnico: el ojo baja por la columna de nombres, que es lo que se
// busca, y el detalle queda subordinado sin estorbar.
//
// Se apoya en la lista de definición de Pandoc —nombre = término, titulaciones
// = descripción— porque es lo que son, y porque así el EPUB recibe un <dl> sin
// necesidad de marcado propio. Pandoc funde las varias descripciones de una
// misma persona en un solo #block con un párrafo cada una.
//
// ⚠️ El `show terms.item` de glosario.typ es global y maquetaría esto en línea,
// como una entrada de glosario. La regla local de aquí lo sobrescribe DENTRO de
// este bloque y sólo aquí: fuera, el glosario conserva la suya. Por eso los
// créditos tienen que ir envueltos en `::: {.creditos}`; sin el envoltorio no
// hay ámbito que valga y saldrían con el aspecto del glosario.
#let creditos(body) = {
  v(1.5em)
  show terms.item: it => block(breakable: false, below: 1.15em, width: 100%)[
    // Sans y negrita: el nombre destaca sobre el cuerpo en serif sin recurrir a
    // un tamaño grande, que en una lista de siete daría aspecto de escalera.
    // Libertinus Sans no tiene semibold —Typst caería a bold en silencio—, así
    // que se pide bold, que es lo que de verdad se compone.
    #text(font: "Libertinus Sans", size: 1.05em, weight: "bold")[#it.term]
    #block(inset: (left: 1.2em), above: 0.35em)[
      #set par(first-line-indent: 0em, justify: false, leading: 0.55em, spacing: 0.45em)
      #set text(size: 0.85em, fill: luma(90))
      #it.description
    ]
  ]
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
  title: [Manual de formación teórica para la obtención de la Licencia de Piloto de Planeador (SPL)],
  author: "VuelaLibre.net",
  version: "0.8.5",
  fecha-actualizacion: "20 de julio de 2026",
  cubierta: image("recursos-completo/frente.jpg"),
  contracubierta: image("recursos-completo/reverso.jpg"),
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

#import "@preview/in-dexter:0.7.2": *
#heading(level: 1, numbering: none)[Información legal y licencia]
<información-legal-y-licencia>
#licencia[
Manual de formación teórica para la obtención de la #strong[Licencia de Piloto de Planeador (SPL)], conforme al syllabus del AMC1 SFCL.130 (EASA-FCL), adaptado a los requerimientos de AESA.

© 2026 VuelaLibre.net

Publicado por #strong[VuelaLibre.net] · #link("https://vuelalibre.net")

#heading(level: 2, outlined: false, numbering: none)[Licencia]
<licencia>
#licencia-cc[
Esta obra se distribuye bajo licencia #strong[Creative Commons Atribución-CompartirIgual 4.0 Internacional (CC BY-SA 4.0)].

]
#grid(columns: (1fr, 1fr), gutter: 1.2em, [
#strong[Se permite:]

- copiar y redistribuir el material en cualquier medio
- adaptar: remezclar, transformar y construir a partir del material
- el uso comercial

], [
#strong[Siempre que:]

- se otorgue el crédito correspondiente
- se proporcione un enlace a la licencia
- se indique si se realizaron cambios
- las adaptaciones se distribuyan bajo la misma licencia o una compatible

])
La atribución puede hacerse de cualquier manera razonable, pero no de una manera que sugiera que el licenciante lo respalda a usted o a su uso.

Texto completo de la licencia: #link("https://creativecommons.org/licenses/by-sa/4.0/deed.es")

#heading(level: 2, outlined: false, numbering: none)[Exención de responsabilidad --- uso bajo propio riesgo]
<exención-de-responsabilidad-uso-bajo-propio-riesgo>
#aviso-legal[
La aviación es una actividad que conlleva riesgos inherentes. Aunque se ha realizado un esfuerzo exhaustivo para garantizar la precisión técnica de este manual utilizando fuentes oficiales actualizadas:

- #strong[Los autores, editores y colaboradores NO asumen responsabilidad alguna] por daños personales, materiales o de cualquier otra índole que pudieran derivarse de interpretaciones erróneas o errores técnicos en el texto.
- Este manual es una #strong[herramienta de apoyo al estudio] y no sustituye en ningún caso ni a la instrucción teórica ni a la práctica obligatoria con un instructor de vuelo cualificado (FI(S)).
- En caso de discrepancia con la normativa vigente publicada por AESA o EASA, prevalecerá siempre el texto legal oficial de la autoridad aeronáutica.

]
#heading(level: 2, outlined: false, numbering: none)[Validación por AESA]
<validación-por-aesa>
#aval[
Los #strong[temarios de esta colección han sido validados por AESA] (Agencia Estatal de Seguridad Aérea), la autoridad aeronáutica civil de España, en cuanto a su adecuación al syllabus del AMC1 SFCL.130 para la formación teórica de la Licencia de Piloto de Planeador (SPL). El desarrollo del contenido es responsabilidad exclusiva de los autores.

]
]
#dedicatoria[
#strong[A la memoria de Iñaqui Ulibarri García de la Cueva]

El maestro que nos regaló las alas y nos enseñó a volar con sabiduría.

Aún te sentimos en el asiento de atrás; nos acompañas en cada térmica y en cada decisión al mando que tomamos recordando tus lecciones.

Gracias por dejarnos tu inmensa pasión como la mejor de las herencias.

]
= 
<section>
#block[
«Una vez que hayas probado el vuelo, caminarás por la tierra con la mirada levantada al cielo, porque ya has estado allí y allí deseas volver.»

--- Leonardo da Vinci

]
#heading(level: 1, numbering: none)[Reconocimientos]
<reconocimientos>
Este manual es el fruto de un esfuerzo colaborativo dentro de la comunidad de vuelo sin motor. Queremos expresar nuestro más sincero agradecimiento a:

- #strong[Agencia Estatal de Seguridad Aérea (AESA)] y #strong[EASA], por proporcionar el marco normativo y documental que garantiza la seguridad de nuestras operaciones.
- Los #strong[Instructores de Vuelo (FI(S))] y #strong[Examinadores (FE(S))] que han dedicado su tiempo a revisar técnicamente estas secciones para asegurar su rigor técnico.
- A la comunidad de #strong[VuelaLibre.net], por impulsar iniciativas que modernizan y democratizan el acceso a la formación aeronáutica de calidad.
- A todos los pilotos que, con su feedback constante, ayudan a que este manual sea una herramienta viva y en evolución.
- A los autores de los manuales internacionales clásicos, cuya estructura ha servido de base para organizar el conocimiento de una forma pedagógica y accesible para las nuevas generaciones de pilotos de planeador y, en especial a:

#creditos[
/ Iñaqui Ulibarri García de la Cueva: #block[
SPL · FI(S) · FE(S)

Campeón de España de Vuelo a Vela. Instructor y Examinador de Vuelo a Vela
]

/ Pedro Berlinches: #block[
SPL · FI(S) · PPL(A) · FES(A)

Instructor y Examinador de Vuelo a Vela
]

/ Luís Ferreira Escartín: #block[
SPL · FI(S) · FE(S)

Instructor y Examinador de Vuelo a Vela
]

/ Encarnación Novillo-Fertrell Vázquez: #block[
SPL · FI(S) · FE(S)

Instructora y Examinadora de Vuelo a Vela
]

/ Carlos Bravo Domínguez: #block[
SPL · FI(S) · FE(S)

Instructor y Examinador de Vuelo a Vela
]

/ Sergi Pujol Rodríguez: #block[
SPL · FI(S) · FE(S)

Instructor y Examinador de Vuelo a Vela
]

/ Ramón Gutiérrez Camus: #block[
SPL

Piloto de Vuelo a Vela. Edición técnica
]

]
#heading(level: 1, numbering: none)[Introducción a la colección]
<introducción-a-la-colección>
El vuelo sin motor es una de las formas más puras, bellas y exigentes de la aviación. Volar un planeador no consiste únicamente en pilotar una máquina eficiente; implica comprender de manera profunda la atmósfera, dominar la aerodinámica física de la aeronave y, sobre todo, aprender a gestionar los propios límites humanos dentro de un marco operativo seguro y regulado.

Este manual completo reúne en un único volumen las #strong[nueve asignaturas oficiales] del programa de estudios establecido por la Agencia de la Unión Europea para la Seguridad Aérea (EASA) para la obtención de la #strong[Licencia de Piloto de Planeador (SPL)], conforme al reglamento Part-SFCL:

+ #strong[Derecho Aéreo y ATC]: El marco legal y los procedimientos de tránsito que garantizan la seguridad y el orden en el espacio aéreo común.
+ #strong[Factores Humanos]: El estudio de los límites fisiológicos y psicológicos del piloto, y las herramientas de juicio para gestionar el riesgo en la cabina.
+ #strong[Meteorología]: La comprensión del motor atmosférico que proporciona la sustentación (térmicas, ondas de montaña, convergencias) y el análisis de la seguridad meteorológica.
+ #strong[Comunicaciones]: Los procedimientos y la fraseología estándar para la comunicación por radio en operaciones VFR.
+ #strong[Principios de Vuelo]: La física aerodinámica aplicada que explica cómo vuela y se controla un planeador.
+ #strong[Procedimientos Operativos]: Las mejores prácticas de operación segura, desde la preparación del vuelo hasta las emergencias y los aterrizajes fuera de campo.
+ #strong[Planificación y Rendimiento]: El cálculo de las velocidades óptimas de planeo (teoría McCready), el centrado de la aeronave y la preparación de vuelos de distancia.
+ #strong[Conocimientos Generales de la Aeronave]: La estructura, los sistemas de a bordo, la instrumentación de vuelo y los equipos específicos de los planeadores.
+ #strong[Navegación]: Los métodos de navegación visual, la lectura de cartas aeronáuticas, el uso de sistemas GNSS y la estimación de trayectorias en vuelo de distancia.

Cada una de estas materias está estructurada de forma secuencial, dividida en capítulos operativos y complementada con un apéndice de syllabus, un glosario consolidado y un índice de términos que facilitan tanto el estudio inicial como la consulta rápida en tu día a día como piloto en formación o instructor.

El cielo ofrece una libertad inmensa, pero esa libertad exige responsabilidad y preparación técnica. Este volumen aspira a ser el cimiento teórico de tu seguridad en el aire. ¡Buen vuelo!

#part[Parte 01: Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (ATC)]
= Derecho internacional: convenios, acuerdos y organizaciones
<derecho-internacional-convenios-acuerdos-y-organizaciones>
#quote(block: true)[
Entender el marco legal no es burocracia: es el cimiento de tu seguridad y de tu libertad para volar más allá de nuestras fronteras.

En este capítulo aprenderás:

- De dónde salen las normas: el Convenio de Chicago y la #link(<glosario-oaci>)[OACI]#index("OACI").
- Qué papel juega #link(<glosario-easa>)[EASA]#index("EASA") y cómo nos afectan las leyes comunes europeas.
- Qué es obligatorio (normativa vinculante) y qué es recomendado (estándares no vinculantes).
- Los tres reglamentos que te acompañarán toda tu vida de piloto: #link(<glosario-part-sfcl>)[Part-SFCL]#index("Part-SFCL"), #link(<glosario-part-sao>)[Part-SAO]#index("Part-SAO") y #link(<glosario-sera>)[SERA]#index("SERA").
]

== El origen de las normas: Convenio de Chicago y OACI
<el-origen-de-las-normas-convenio-de-chicago-y-oaci>
El acta de nacimiento del derecho aéreo moderno es el #strong[Convenio de Chicago de 1944]. Allí las naciones acordaron unificar las normas de aviación a nivel global, y de ese acuerdo salen los principios que hoy nos permiten volar de forma segura y ordenada entre países distintos.

Del convenio nació la #strong[OACI] (Organización de Aviación Civil Internacional, #strong[ICAO]), una agencia especializada de la ONU. Su trabajo consiste en desarrollar los principios y técnicas de la navegación aérea internacional, fomentar el transporte aéreo entre países y velar por la seguridad operacional (#strong[safety]) en todo el mundo.

La OACI fija los estándares mínimos que sus 193 estados miembros deben cumplir. Ahora bien, no es una "policía mundial": cada país es soberano para adoptar estas normas en su legislación, aunque el Convenio le obliga a notificar las diferencias cuando no cumple un estándar.

Para que el transporte aéreo internacional fuera posible, el Convenio de Chicago sentó las bases de las #strong[libertades del aire] (ver #ref(<fig-01-cap01-chicago-freedoms>, supplement: [Figura])): acuerdos que dan a las aeronaves de un Estado permiso para entrar en el espacio aéreo de otro o sobrevolarlo. La conferencia de Chicago definió las cinco primeras en acuerdos anejos al Convenio (el sobrevuelo, la #link(<glosario-escala>)[escala]#index("Escala") técnica y los derechos comerciales básicos), pero el derecho aéreo ha seguido evolucionando y hoy se reconocen nueve.

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap01-libertades-chicago.jpg"))
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

¿Y entonces, qué papel juega #link(<glosario-aesa>)[AESA]#index("AESA")? La #strong[AESA] (Agencia Estatal de Seguridad Aérea) es el organismo público español, adscrito al Ministerio de Transportes y Movilidad Sostenible, que actúa como tu autoridad competente directa: emite tu licencia, inspecciona tu club y vigila el cumplimiento en territorio español. Pero lo hace aplicando e interpretando las reglas comunes europeas.

== Estructura normativa: normativa vinculante y estándares no vinculantes
<estructura-normativa-normativa-vinculante-y-estándares-no-vinculantes>
La normativa de EASA se organiza en capas con distinta fuerza legal (#ref(<fig-01-cap01-hard-soft-law>, supplement: [Figura])). Conviene tener claro desde el principio qué es obligatorio por ley y qué es una recomendación estándar.

=== Normativa vinculante: lo que es ley
<normativa-vinculante-lo-que-es-ley>
Es la normativa de obligado cumplimiento. Nadie queda eximido de ella salvo que la autoridad le conceda una exención por escrito. Tiene dos niveles:

- #strong[Reglamento #link(<glosario-base>)[Base]#index("Tramo de base")] (#strong[Basic Regulation]): la "Constitución" de la seguridad aérea en Europa, actualmente el Reglamento (UE) 2018/1139. Establece los principios esenciales y los objetivos de alto nivel.
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

- #strong[#link(<glosario-amc>)[AMC]#index("AMC")] (#strong[Acceptable Means of Compliance], Medios Aceptables de Cumplimiento): métodos y procedimientos que EASA publica como forma segura de cumplir la normativa vinculante. Si sigues los AMC, automáticamente cumples la norma. Si prefieres hacerlo de otra forma, tendrás que demostrar, con bastante papeleo, que tu método es igual de seguro.
- #strong[#link(<glosario-gm>)[GM]#index("Material Guía")] (#strong[Guidance Material], Material Guía): explicaciones, interpretaciones y ejemplos para entender los requisitos. No obliga; ayuda.
- #strong[#link(<glosario-cs>)[CS]#index("CS")] (#strong[Certification Specifications]): estándares técnicos para certificar aeronaves y productos. El que nos toca es el #link(<glosario-cs-22>)[CS-22]#index("CS-22"), el de planeadores.

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap01-estructura-normativa-easa.jpg"))
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

=== 1. Part-SFCL (licencias)
<part-sfcl-licencias>
El #strong[Sailplane Flight Crew Licensing] regula todo lo relativo a tu licencia: los requisitos para obtener la #link(<glosario-spl>)[SPL]#index("SPL") (#strong[Sailplane Pilot Licence]), la experiencia reciente que necesitas para mantenerla, las habilitaciones (#link(<glosario-tmg>)[TMG]#index("TMG"), acrobacia, remolque…​) y los privilegios de instructores y examinadores. Nace del Reglamento de Ejecución (UE) 2018/1976 y sus modificaciones, como el 2020/358.

=== 2. Part-SAO (operaciones)
<part-sao-operaciones>
El #strong[Sailplane Air Operations] regula cómo se opera el planeador de forma segura: las responsabilidades del #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando"), los documentos que debes llevar a bordo, los procedimientos de emergencia, el transporte de pasajeros y el uso de aeródromos. Sale del mismo reglamento que el Part-#link(<glosario-sfcl>)[SFCL]#index("SFCL").

#block[
#callout(
body: 
[
Según #link(<glosario-sao>)[SAO]#index("SAO")​.GEN.130 (Part-SAO), el piloto al mando es responsable de la seguridad de la aeronave y de todas las personas a bordo durante las operaciones. Esta responsabilidad no se delega: tú eres la autoridad #link(<glosario-final>)[final]#index("Tramo final") en tu cabina.

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
El #strong[Standardised European Rules of the Air] es el código de circulación del cielo: prioridades de paso, niveles de crucero, mínimos de #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") y distancia a nubes (#link(<glosario-vmc>)[VMC]#index("VMC")), señales y luces. Al ser un reglamento de ejecución de la UE, se aplica #strong[directamente] en España, sin necesidad de norma nacional que lo transponga; el Real Decreto 552/2014 lo #strong[complementa y desarrolla] en los aspectos que SERA deja a cada Estado.

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
#postit[
#strong[Resumen del capítulo: marco normativo]

La "ley del aire" que te permite volar se organiza así:

- #strong[OACI y Convenio de Chicago (1944)]: el tratado fundador. Fija los estándares mundiales mínimos.
- #strong[EASA]: nuestra autoridad común europea. Redacta normas que todos los países de la UE cumplen por igual; AESA las aplica en España.
- #strong[Normativa vinculante] (Reglamentos): es ley, obligatoria al 100%. Ahí están Part-SFCL, Part-SAO y SERA.
- #strong[Estándares no vinculantes] (AMC/GM): no son ley estricta, pero sí la forma estándar y segura de hacer las cosas. Síguelos y no tendrás problemas.
- Tus normas de cabecera: #strong[Part-SFCL] (tu licencia), #strong[SERA] (cómo volar) y #strong[Part-SAO] (cómo operar tu planeador).

]
= Aeronavegabilidad (#emph[airworthiness]) de aeronaves
<aeronavegabilidad-airworthiness-de-aeronaves>
#quote(block: true)[
Un planeador sano es un planeador seguro; aprende a verificar la "salud técnica" de tu aeronave antes de cada vuelo.

En este capítulo aprenderás:

- La diferencia entre el Certificado de Aeronavegabilidad (#strong[Certificate of Airworthiness], #link(<glosario-cofa>)[CofA]#index("CofA")) y el Certificado de Revisión de Aeronavegabilidad (#link(<glosario-arc>)[ARC]#index("ARC"), #strong[Airworthiness Review Certificate]), y qué exige la ley para volar con ellos en regla.
- El marco de mantenimiento de la aviación ligera (#link(<glosario-part-ml>)[Part-ML]#index("Part-ML")) desde su cara jurídica ---el detalle técnico se ve en el Libro 8 --- Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia---.
- Lo que te toca a ti: inspección pre-vuelo, verificación de documentos y reporte de defectos.
]

== Concepto de aeronavegabilidad
<concepto-de-aeronavegabilidad>
La aeronavegabilidad es, en pocas palabras, la salud técnica de tu aeronave. Un planeador es aeronavegable cuando cumple con el diseño aprobado por la autoridad (tiene sus papeles en regla) y está en condiciones de operar de manera segura, sin defectos peligrosos.

Como piloto, eres el último eslabón de la cadena de seguridad. Da igual lo bien diseñado que esté el avión: si no se mantiene correctamente, deja de ser seguro.

== Certificado de aeronavegabilidad (CofA)
<certificado-de-aeronavegabilidad-cofa>
El #strong[Certificado de Aeronavegabilidad] (CofA) es el documento que emite la autoridad del Estado de matrícula (#link(<glosario-aesa>)[AESA]#index("AESA") en España) para certificar que la aeronave se ajusta al diseño aprobado y está en condiciones de operación segura.

El CofA de las aeronaves #link(<glosario-easa>)[EASA]#index("EASA") tiene validez #strong[ilimitada]: no caduca, siempre que la aeronave se mantenga aeronavegable conforme a su programa de mantenimiento y nadie lo revoque (#ref(<fig-01-cap02-cofa-example>, supplement: [Figura])). Eso sí, para ser válido debe ir siempre acompañado de un ARC en vigor. Sin ARC, el CofA es papel mojado.

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap02-certificado-aeronavegabilidad.jpg"))
], caption: figure.caption(
position: bottom, 
[
Certificado de Aeronavegabilidad EASA
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap02-cofa-example>


== La "ITV" anual: certificado de revisión de aeronavegabilidad (ARC)
<la-itv-anual-certificado-de-revisión-de-aeronavegabilidad-arc>
El #strong[ARC] (#strong[Airworthiness Review Certificate], Certificado de Revisión de Aeronavegabilidad) confirma que, en un #link(<glosario-momento>)[momento]#index("Momento") dado, alguien revisó la documentación y el estado físico del avión y todo estaba correcto.

Su validez es de #strong[un año], así que toca renovarlo o prorrogarlo anualmente. En un entorno controlado (gestionado por una #link(<glosario-camo>)[CAMO]#index("CAMO") o, en aviación ligera, por una #link(<glosario-cao>)[CAO]#index("CAO")), el ARC admite dos prórrogas consecutivas sin revisión física completa, es decir, 1 año + 1 año + 1 año. Al tercer año, revisión a fondo sin excusas (#ref(<fig-01-cap02-arc-process>, supplement: [Figura])). El régimen técnico que sostiene el ARC ---el programa de mantenimiento, el programa mínimo de inspección y las directivas de aeronavegabilidad--- se desarrolla en el #strong[Libro 8 --- Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia], capítulo 9; aquí interesa su cara jurídica: sin ARC en vigor no puedes volar.

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
#box(image("01-derecho-aereo-atc/imagenes/01-cap02-ciclo-arc.jpg"))
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
Desde el punto de vista legal basta con que retengas el marco: los planeadores se mantienen bajo la #strong[Part-ML] (Anexo Vb del Reglamento (UE) 1321/2014), una normativa simplificada para la aviación ligera que descansa sobre un #strong[Programa de Mantenimiento (#link(<glosario-amp>)[AMP]#index("AMP"))] y que, en ciertas tareas sencillas, permite al #strong[piloto-propietario] firmar el mantenimiento él mismo. El desarrollo de todo esto ---cómo funciona el AMP, el programa mínimo de inspección, qué tareas puede firmar el piloto-propietario y con qué condiciones, las directivas de aeronavegabilidad (#link(<glosario-ad>)[AD]#index("Aerodromos")) y los boletines de servicio (#link(<glosario-sb>)[SB]#index("SB"))--- corresponde a su asignatura natural, #strong[Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia]: se estudia en el #strong[Libro 8 --- Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia], capítulo 9.

== Responsabilidades del piloto
<responsabilidades-del-piloto>
No eres mecánico, pero sí el responsable #link(<glosario-final>)[final]#index("Tramo final") de aceptar el avión para el vuelo. Tres tareas son tuyas y de nadie más.

=== 1. Inspección pre-vuelo
<inspección-pre-vuelo>
Antes de cada vuelo te toca una inspección exterior e interior, siguiendo la lista de chequeo del #strong[Manual de Vuelo del Planeador (#link(<glosario-afm>)[AFM]#index("AFM"))]. Es una obligación legal, pero sobre todo es sentido común.

=== 2. Verificación de documentación
<verificación-de-documentación>
Antes de despegar, comprueba que la documentación obligatoria está a bordo y en vigor. Según la normativa de operaciones de planeadores (#link(<glosario-part-sao>)[Part-SAO]#index("Part-SAO")), esto incluye:

- #strong[Documentos de la aeronave]: CofA, ARC, Certificado de Matrícula, Seguro, Licencia de Estación de Radio.
- #strong[Documentos de la operación]: Manual de Vuelo (AFM), listas de chequeo.
- #strong[Documentos del piloto]: tu licencia (#link(<glosario-spl>)[SPL]#index("SPL")) y tu certificado médico.

=== 3. Reporte de defectos
<reporte-de-defectos>
Si encuentras algo mal durante la pre-vuelo o durante el vuelo, anótalo en el #strong[Technical Log Book (Diario de a bordo)]. El siguiente piloto te lo agradecerá.

#block[
#callout(
body: 
[
¿Ves una muesca en el #link(<glosario-gelcoat>)[gelcoat]#index("Gelcoat")? No es solo estética: si afecta al perfil, afecta al vuelo. Ante la duda, pregunta. Es mejor ser un piloto curioso que un piloto en apuros.

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
#strong[Resumen del capítulo: aeronavegabilidad]

La aeronavegabilidad es la salud de tu aeronave. Para volar legal y seguro:

- #strong[CofA]: acredita que la aeronave se ajusta al diseño aprobado y está en condiciones de operación segura. Lo expide el Estado de matrícula (AESA en España) y no caduca si el avión se mantiene correctamente.
- #strong[ARC]: la "ITV" anual. Confirma que el avión está revisado y apto. Verifica su fecha de validez antes de volar.
- #strong[Part-ML]: el marco de mantenimiento de los planeadores; permite al piloto-propietario certificar tareas sencillas. Su desarrollo técnico (AMP, programa mínimo de inspección, AD/SB) está en el #strong[Libro 8 --- Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia], capítulo 9.
- #strong[Tu parte]: hacer la inspección pre-vuelo, verificar que la documentación (CofA, ARC, seguro…​) está a bordo y en vigor, y anotar cualquier defecto en el Diario de a bordo.

]
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

En España, la marca de nacionalidad es #NormalTok("EC");, seguida de un guion y tres letras: por ejemplo, #NormalTok("EC-ABC");. Estas marcas las asigna el Estado (#link(<glosario-aesa>)[AESA]#index("AESA")) y son únicas para cada aeronave.

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

Según la normativa española (y el Anexo 7 de #link(<glosario-oaci>)[OACI]#index("OACI")), en los aerodinos (aviones y planeadores):

+ #strong[En las alas]: en la superficie inferior (intradós) del ala izquierda, o abarcando ambas alas, con una altura mínima de #strong[50 centímetros].
+ #strong[En la cola o el fuselaje]: en ambos lados del fuselaje (entre las alas y la cola) o en las superficies verticales de cola, con una altura mínima de #strong[30 centímetros].

Si el planeador es muy estilizado y no caben marcas de este tamaño, la autoridad puede aceptar dimensiones reducidas, siempre que sigan siendo legibles (#ref(<fig-01-cap03-matricula-ubicacion>, supplement: [Figura])).

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap03-ubicacion-matricula.jpg"))
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
#box(image("01-derecho-aereo-atc/imagenes/01-cap03-placa-ignifuga.jpg"))
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
Junto a las letras, es obligatorio llevar la #strong[bandera de España], normalmente en la #link(<glosario-deriva>)[deriva]#index("Deriva") o en el fuselaje, por encima de la matrícula y paralela a la línea de vuelo. Es el símbolo de la nacionalidad de la aeronave y de la soberanía del estado que la registra.

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
#postit[
#strong[Resumen del capítulo: marcas y matrícula]

Tu planeador tiene una identidad legal única que debe ser visible y resistente:

- #strong[Nacionalidad y matrícula]: en España, #strong[EC-] seguida de tres letras (ej: EC-ABC).
- #strong[Marcas pintadas]: en el fuselaje o la cola (y bajo las alas en algunos casos), más la bandera de España.
- #strong[Placa de identificación]: de material ignífugo, con la matrícula grabada, fijada a la estructura cerca de la entrada.

]
= Licencias de personal
<licencias-de-personal>
#quote(block: true)[
Tu licencia es un privilegio, no un derecho; mantenerla activa requiere experiencia continua y aptitud médica.

En este capítulo aprenderás:

- Qué es la licencia #link(<glosario-spl>)[SPL]#index("SPL"): validez, privilegios y normativa aplicable (#link(<glosario-part-sfcl>)[Part-SFCL]#index("Part-SFCL")).
- Las diferencias entre el certificado médico #link(<glosario-lapl>)[LAPL]#index("LAPL") y el Clase 2, y cuánto duran.
- La regla "5 horas - 15 lanzamientos - 2 vuelos" para mantenerte legal.
- Qué necesitas, además de la licencia, para llevar a alguien contigo.
]

== La licencia SPL (Sailplane Pilot Licence)
<la-licencia-spl-sailplane-pilot-licence>
Para volar un planeador legalmente en Europa necesitas una licencia #strong[SPL] (#strong[Sailplane Pilot Licence]), regulada por la Part-#link(<glosario-sfcl>)[SFCL]#index("SFCL") del Reglamento (UE) 2018/1976 (actualizado por el 2020/358).

Puedes obtenerla a los 16 años, aunque ya a los 14 puedes volar solo como alumno. Te da derecho a actuar como #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando") (PIC) en planeadores y motoveleros, y en teoría es #strong[vitalicia]: el papel no caduca.

Pero que el papel no caduque no significa que puedas volar siempre. Para ejercer tus privilegios debes cumplir dos condiciones #strong[sine qua non]: tener un #strong[certificado médico válido] y cumplir los requisitos de #strong[experiencia reciente].

== El certificado médico
<el-certificado-médico>
Sin médico, no hay vuelo. Controlar la fecha de caducidad es responsabilidad tuya.

Vale tanto un certificado #strong[Clase 2] como un #strong[LAPL] (#strong[Light Aircraft Pilot Licence]). Para la mayoría de pilotos deportivos, el LAPL es suficiente y menos exigente. Su validez depende de tu edad: #strong[60 meses] (5 años) si tienes menos de 40, y #strong[24 meses] (2 años) a partir de los 40 (#ref(<fig-01-cap04-medical-validity>, supplement: [Figura])). Ojo con el matiz de #link(<glosario-med>)[MED]#index("Part-MED")​.A.045: un certificado emitido #strong[antes] de cumplir los 40 deja de ser válido cuando cumples los #strong[42], aunque los 60 meses no hayan vencido. Si te lo expidieron a los 39, no te vale hasta los 44: caduca a los 42.

#block[
#callout(
body: 
[
Si tu salud cambia (operación, enfermedad grave, embarazo, nuevas gafas), tu certificado médico puede quedar en suspenso. Consulta siempre con un Médico Examinador Aéreo (#link(<glosario-ame>)[AME]#index("AME")) antes de volver a volar.

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
#box(image("01-derecho-aereo-atc/imagenes/01-cap04-validez-medical.jpg"))
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
Para volar solo o con pasajeros debes demostrar que estás al día. La normativa SFCL establece una ventana móvil de los #strong[últimos 24 meses], dentro de los cuales, para mantener activos tus privilegios en planeadores (excluyendo #link(<glosario-tmg>)[TMG]#index("TMG")), debes haber completado:

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
#box(image("01-derecho-aereo-atc/imagenes/01-cap04-recencia-requisitos.jpg"))
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
Llevar a alguien contigo es una gran responsabilidad, y la licencia recién sacada no te lo permite de inmediato. Primero debes completar #strong[10 horas] de vuelo o #strong[30 lanzamientos] como piloto al mando #strong[después] de obtener la licencia y, además, un #strong[vuelo de entrenamiento] en el que demuestres a un instructor #link(<glosario-fi>)[FI]#index("FI")\(S) tu competencia para el transporte de pasajeros (salvo que ya seas titular de un certificado FI(S)).

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
#postit[
#strong[Resumen del capítulo: licencias]

Para pilotar legalmente necesitas tres cosas:

- #strong[Licencia SPL]: tu título de piloto, regido por la Part-SFCL. Vale de por vida, pero sus atribuciones dependen del médico y de la experiencia reciente.
- #strong[Certificado médico]: Clase 2 o LAPL. Sin médico en vigor, la licencia es papel mojado.
- #strong[Experiencia reciente]: en los últimos 24 meses, 5 horas de vuelo (como PIC, doble mando o con FI(S)), 15 lanzamientos y 2 vuelos de entrenamiento con un FI(S). Si no llegas, vuela con instructor hasta cumplirlos o supera una verificación de competencia con un #link(<glosario-fe>)[FE]#index("FE")\(S).
- #strong[Pasajeros]: requieren experiencia extra (10 h o 30 lanzamientos tras la licencia), un vuelo de entrenamiento con un FI(S) demostrando competencia (salvo que ya seas FI(S)) y 3 lanzamientos en los últimos 90 días.

]
= Reglas del aire
<reglas-del-aire>
#quote(block: true)[
El cielo no tiene señales de STOP, pero tiene reglas estrictas; dominar el reglamento #link(<glosario-sera>)[SERA]#index("SERA") es esencial para evitar colisiones.

En este capítulo aprenderás:

- El reglamento SERA, el código de circulación aéreo europeo.
- El principio de "ver y evitar" del vuelo visual (#link(<glosario-vfr>)[VFR]#index("VFR")).
- Quién cede el paso a quién (globos \> planeadores \> motor).
- Cuándo puedes volar bajo (laderas, tomas fuera de campo) y cuándo no.
]

== El código de circulación del cielo: SERA
<el-código-de-circulación-del-cielo-sera>
En Europa volamos bajo un reglamento unificado: #strong[SERA] (#strong[Standardised European Rules of the Air]), directamente aplicable en España como reglamento de la UE y complementado por el Real Decreto 552/2014. Da igual si vuelas en Albacete o en Alemania: las reglas básicas son las mismas.

El principio fundamental es #strong[VFR] (#strong[Visual Flight Rules]): volamos basándonos en referencias visuales externas.

== Principio básico: "ver y evitar"
<principio-básico-ver-y-evitar>
En vuelo visual, tú eres el único responsable de no chocar. El control de tráfico (#link(<glosario-atc>)[ATC]#index("ATC")) puede ayudarte, pero la responsabilidad #link(<glosario-final>)[final]#index("Tramo final") es tuya. Eso exige un escaneo constante del cielo (la técnica del barrido visual) y algo de gimnasia: mueve el avión o la cabeza para ver detrás de los montantes o bajo el morro, porque los puntos ciegos existen.

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
#box(image("01-derecho-aereo-atc/imagenes/01-cap05-preferencias-paso-ladera.jpeg"))
], caption: figure.caption(
position: bottom, 
[
Preferencia de paso en #link(<glosario-vuelo-de-ladera>)[vuelo de ladera]#index("Vuelo de ladera")
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap05-prioridades-ladera>


- #strong[Aterrizaje]: el velero más bajo tiene prioridad para aterrizar (pero no vale picar para colarse). Además, según SERA.3210, los planeadores en final y aterrizaje siempre tienen preferencia sobre las aeronaves de motor (#ref(<fig-01-cap05-prioridades>, supplement: [Figura])).

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap05-prioridades-paso.jpg"))
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
#box(image("01-derecho-aereo-atc/imagenes/01-cap05-alturas-minimas.jpg"))
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
#postit[
#strong[Resumen del capítulo: reglas del aire]

El reglamento #strong[SERA] es el código de circulación del cielo:

- #strong[VFR]: volamos viendo y siendo vistos. Ojos fuera.
- #strong[Prioridad de paso]: globos \> planeadores \> motor (cede quien más maniobra tiene). En convergencia, paso para el que viene por la derecha. En ladera, prioridad para quien lleva la montaña a su derecha. En aterrizaje, el velero más bajo manda, y los planeadores tienen preferencia sobre los aviones a motor.
- #strong[Alturas mínimas]: 150 m en general, 300 m sobre zonas pobladas. Los planeadores pueden volar más bajo en ladera (sin riesgo para personas o bienes) y bajar hasta 50 m entrenando tomas fuera de campo, a 150 m de personas y vehículos.

]
= Procedimientos para navegación aérea: operaciones de aeronaves
<procedimientos-para-navegación-aérea-operaciones-de-aeronaves>
#quote(block: true)[
Navegar seguro exige reglas precisas; domina los mínimos #link(<glosario-vmc>)[VMC]#index("VMC") y los niveles de crucero para compartir el cielo eficientemente.

En este capítulo aprenderás:

- Los mínimos meteorológicos (VMC): cuándo es legal volar visual y qué excepciones tenemos los planeadores.
- La regla semicircular: cómo elegir tu altitud de crucero según el rumbo.
- La diferencia crítica entre #link(<glosario-qnh>)[QNH]#index("QNH") (altitud), #link(<glosario-qfe>)[QFE]#index("QFE") (altura) y #link(<glosario-qne>)[QNE]#index("QNE") (niveles de vuelo).
- Cuándo es obligatorio el oxígeno para esquivar la #link(<glosario-hipoxia>)[hipoxia]#index("Hipoxia") silenciosa.
]

== Mínimos VFR: visibilidad y distancia a nubes
<mínimos-vfr-visibilidad-y-distancia-a-nubes>
Para volar visual (#link(<glosario-vfr>)[VFR]#index("VFR")) necesitas unas condiciones meteorológicas mínimas (#strong[VMC]). Si el tiempo baja de esos mínimos, el vuelo VFR está prohibido. La regla general se divide por altitud.

=== Por debajo de 3.000 ft AMSL (o 1.000 ft AGL)
<por-debajo-de-3.000-ft-amsl-o-1.000-ft-agl>
Es la zona donde solemos movernos los planeadores, y los mínimos dependen del espacio aéreo en que estés:

- #strong[#link(<glosario-espacio-aereo-controlado>)[Espacio aéreo controlado]#index("Espacio aéreo controlado") (Clases B, C, #link(<glosario-zonas-p>)[D]#index("Zonas P"), E)]: #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") de 5 km y distancia a nubes de 1.500 m en horizontal y 1.000 ft en vertical.
- #strong[Espacio aéreo no controlado (Clases F, G)]: visibilidad de 5 km, libre de nubes y a la vista de la superficie.

Hay una excepción interesante en espacio no controlado: si vuelas a menos de 140 #link(<glosario-nudo>)[kt]#index("Nudo") (como un planeador), la normativa permite reducir la visibilidad mínima a #strong[1.500 m], siempre que tu velocidad te deje ver otros tráficos u obstáculos con tiempo de sobra para evitar la colisión (#ref(<fig-01-cap06-vmc-minima>, supplement: [Figura])).

=== Por encima de 3.000 ft AMSL (hasta FL 100)
<por-encima-de-3.000-ft-amsl-hasta-fl-100>
Visibilidad de 5 km y distancia a nubes de 1.500 m en horizontal y 1.000 ft en vertical, estés en el espacio aéreo que estés. Y un dato para los días grandes de onda: por encima de #link(<glosario-fl>)[FL]#index("Nivel de vuelo") 100, la visibilidad mínima sube a #strong[8 km].

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap06-minimos-vmc.jpg"))
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
Para evitar encuentros frontales en ruta, cada uno vuela a una altitud según su derrota magnética. En España, desde 2019, la regla semicircular para vuelos VFR por encima de #strong[3.000 ft #link(<glosario-agl>)[AGL]#index("AGL")] se orienta #strong[Norte-Sur]:

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
#box(image("01-derecho-aereo-atc/imagenes/01-cap06-regla-semicircular.jpg"))
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

- #strong[QNH]: reglaje altimétrico reducido al nivel medio del mar. El altímetro marca #strong[altitud] y, en el suelo, aproximadamente la elevación del campo. Es lo que usamos para navegar y respetar circuitos.
- #strong[QFE]: presión del aeródromo. El altímetro marca #strong[altura] sobre el campo; en el suelo marca cero. Poco usado en travesía, útil en vuelo local o competición.
- #strong[QNE]: indicación con el reglaje estándar (1013,25 hPa). El altímetro marca #strong[niveles de vuelo (FL)]. Se usa por encima de la altitud de transición (6.000 ft en general en España, con excepciones como Madrid a 13.000 ft o Granada a 7.000 ft) para que todos los aviones compartan la misma referencia, haga la meteo que haga. Un matiz: a diferencia del QNH y el QFE, el QNE no es una presión que te reporte nadie, sino la #strong[lectura del altímetro con 1013,25 hPa calados]\; por eso se habla de «calar estándar», no de «poner el QNE».

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
Por debajo de la #strong[Altitud de Transición] (6.000 ft en la mayor parte de España, salvo excepciones como Madrid o Granada), volamos con #strong[QNH] (Altitud). Por encima, calamos #strong[1013,25 hPa] y volamos en #strong[Niveles de Vuelo (FL)].

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

+ El #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando") debe asegurar que todos los ocupantes usen oxígeno suplementario siempre que determine que su falta puede afectar a sus facultades.
+ Si el piloto no puede determinar ese efecto, según #link(<glosario-easa>)[EASA]#index("EASA") el oxígeno #strong[deberá] usarse siempre por encima de los #strong[10.000 ft].

#block[
#callout(
body: 
[
#strong[AMC1 #link(<glosario-sao>)[SAO]#index("SAO")​.OP.150:] El piloto al mando debe asegurarse de que todos los ocupantes utilicen oxígeno suplementario siempre que la altitud de presión sea superior a los #strong[10.000 ft], en los casos en que no pueda determinar cómo la falta de oxígeno puede afectar a las personas a bordo.

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
La norma legal es el mínimo. Fisiológicamente, muchos pilotos sufren deterioro a partir de 8.000-9.000 ft, especialmente de noche o ante #link(<glosario-fatiga>)[fatiga]#index("Fatiga"). En vuelos de onda, conecta el oxígeno y úsalo antes de alcanzar los 10.000 ft.

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
En la práctica: de día y en VFR bastan un reloj de pulsera, el altímetro y el anemómetro. La brújula se suma en los motorizados (#link(<glosario-tmg>)[TMG]#index("TMG")). Y el vuelo en nube o nocturno exige además el #link(<glosario-variometro>)[variómetro]#index("Variómetro"), un indicador de actitud o de viraje y resbale, y el rumbo magnético.

Queda un procedimiento operativo del syllabus que esta colección desarrolla en otros volúmenes: el #strong[plan de vuelo]. Su operativa por radio está en el #strong[Libro 4 --- Comunicaciones] (cap. 3), el formulario #link(<glosario-oaci>)[OACI]#index("OACI") casilla a casilla en el #strong[Libro 7 --- Planificación y Rendimiento de Vuelo] (cap. 4) y su relación con los servicios #link(<glosario-ats>)[ATS]#index("ATS") en el #strong[Libro 9 --- Navegación] (cap. 7).

#postit[
#strong[Resumen del capítulo: procedimientos para la navegación]

- #strong[Mínimos VMC]: regla general, 5 km de visibilidad y nubes a 1.500 m en horizontal / 1.000 ft en vertical. Por debajo de 3.000 ft #link(<glosario-amsl>)[AMSL]#index("AMSL") (o 1.000 ft AGL) en espacio no controlado basta con 5 km, libre de nubes y suelo a la vista; y volando a menos de 140 kt, la visibilidad puede reducirse a 1.500 m. Por encima de FL 100, 8 km.
- #strong[Regla semicircular (España, Norte-Sur)]: hacia el Norte (270°-089°), pares + 500 ft; hacia el Sur (090°-269°), impares + 500 ft. «Norte Par / Sur Impar».
- #strong[Altímetro]: QNH = altitud (navegación y circuitos); QFE = altura sobre el campo; QNE (1013,25 hPa) = niveles de vuelo por encima de la altitud de transición (6.000 ft en general en España).
- #strong[Oxígeno]: según SAO.OP.150, el comandante debe garantizar su uso cuando determine que la falta de oxígeno puede disminuir las facultades o ser dañina. Si no puede valorar ese efecto, el AMC1 SAO.OP.150 fija la regla por defecto: usar oxígeno por encima de 10.000 ft. Fisiológicamente, conéctalo antes.
- #strong[Pre-vuelo (SAO.GEN.130)]: antes de iniciar el vuelo, el piloto al mando comprueba que el planeador es aeronavegable, está matriculado y lleva los instrumentos y equipos necesarios instalados y operativos; también verifica masa, centrado, estiba y límites del #link(<glosario-afm>)[AFM]#index("AFM").
- #strong[Instrumentos mínimos (SAO.IDE.105)]: hora, altitud de presión y velocidad indicada; los TMG añaden rumbo magnético. En nube o de noche: velocidad vertical, actitud o viraje/resbale, y rumbo magnético.

]
= Reglamentación de tránsito aéreo: estructura del espacio aéreo
<reglamentación-de-tránsito-aéreo-estructura-del-espacio-aéreo>
#quote(block: true)[
El cielo está dividido en "cajones" invisibles; saber en cuál estás es la clave para evitar infracciones y peligros.

En este capítulo aprenderás:

- Las clases de espacio aéreo: qué cambia entre el controlado (A-E) y el no controlado (G).
- Cuándo necesitas autorización, radio y transponder para entrar.
- Cómo operar en las zonas #link(<glosario-rmz>)[RMZ]#index("RMZ") (radio obligatoria) y #link(<glosario-tmz>)[TMZ]#index("TMZ") (transponder obligatorio).
- Dónde está prohibido o es peligroso volar: las áreas P, #link(<glosario-zonas-p>)[R]#index("Zonas P") y D.
]

== El mapa de carreteras del cielo
<el-mapa-de-carreteras-del-cielo>
El aire no es libre, o al menos no todo. Para ordenar el tráfico, el espacio aéreo se divide en #strong[clases] (de la A a la G) y #strong[zonas]. Saber dónde estás es vital para no infringir la ley ni ponerte en peligro.

== Espacio aéreo controlado vs no controlado
<espacio-aéreo-controlado-vs-no-controlado>
Esta es la gran división. En el #strong[controlado], alguien (#link(<glosario-atc>)[ATC]#index("ATC")) te separa de otros aviones, o al menos te vigila. En el #strong[no controlado] vas por tu cuenta, eso sí, con la radio a mano.

=== Clases de espacio aéreo (SERA.6001)
<clases-de-espacio-aéreo-sera.6001>
La #link(<glosario-oaci>)[OACI]#index("OACI") define 7 clases, pero en España usamos principalmente las clases #strong[A, C, D y E] (controladas) y la #strong[G] (no controlada) (#ref(<fig-01-cap07-clases-espacio>, supplement: [Figura])).

#table(
  columns: (33.33%, 33.33%, 33.33%),
  align: (auto,auto,auto,),
  table.header([Clase], [Tipo], [Requisitos para VFR (Planeadores)],),
  table.hline(),
  [#strong[A]], [#strong[Controlado] (Exclusivo #link(<glosario-ifr>)[IFR]#index("IFR"))], [#strong[PROHIBIDO VFR]. No puedes entrar. (Ej: Madrid #link(<glosario-tma>)[TMA]#index("TMA") Area A). #strong[Requisitos]: Autorización + Radio + Transponder.],
  [#strong[C]], [#strong[Controlado]], [#strong[Separación]: ATC te separa del IFR. De otros VFR solo recibes información de tráfico (y asesoramiento anticolisión si lo pides): #strong[de los VFR te separas tú]. #strong[Requisitos]: Autorización + Radio + Transponder.],
  [#strong[D]], [#strong[Controlado]], [#strong[Separación]: ninguna para el VFR. ATC te da información de tráfico del IFR y de otros VFR, pero #strong[ver y evitar es cosa tuya]. #strong[Requisitos]: Autorización + Radio + Transponder (generalmente).],
  [#strong[E]], [#strong[Controlado] (Para IFR)], [#strong[Híbrido]: Controlado para IFR, "libre" para VFR. #strong[VFR]: No necesitas autorización ni radio (aunque es muy recomendable). ATC no te separa de nadie, pero da información de tráfico si puede.],
  [#strong[G]], [#strong[NO Controlado]], [#strong[Libre]: Vuelas bajo tu responsabilidad. #strong[Servicio]: Solo Información de Vuelo (#link(<glosario-fis>)[FIS]#index("FIS")) si la pides.],
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
#box(image("01-derecho-aereo-atc/imagenes/01-cap07-clases-espacio-aereo.jpg"))
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
- #strong[TMZ] (#strong[Transponder Mandatory Zone]): es obligatorio llevar y operar el #strong[transponder] con las capacidades exigidas. La escucha o comunicación por radio solo es obligatoria si la zona también es RMZ o si así se publica.

#block[
#callout(
body: 
[
Si ves una RMZ en el mapa, no entres mudo. Llama a la frecuencia indicada e informa: "Juliana Información, EC-OJE, planeador, entrando en RMZ sector norte…​".

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
== Zonas prohibidas, restringidas y peligrosas
<zonas-prohibidas-restringidas-y-peligrosas>
El espacio aéreo puede tener "candados" por seguridad o defensa, marcados con códigos como LER71:

- #strong[P] (#strong[Prohibited]) - Prohibida: no se entra jamás. Piensa en el Palacio Real o en centrales nucleares.
- #strong[R] (#strong[Restricted]) - Restringida: entrada sujeta a condiciones. Normalmente se puede pasar si está inactiva o con permiso especial (parques naturales, zonas de maniobras militares).
- #strong[D] (#strong[Danger]) - Peligrosa: hay un peligro no específico (pruebas de explosivos, actividades de riesgo). Puedes entrar bajo tu responsabilidad, pero mejor evítalas (#ref(<fig-01-cap07-zonas-prd>, supplement: [Figura])).

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap07-zonas-prd.png"))
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
Infringir una zona P o R activa puede llevar a sanciones graves e incluso a la #link(<glosario-interceptacion>)[interceptación]#index("Interceptación") por aviones militares. Planifica tu vuelo y comprueba los #link(<glosario-notam>)[NOTAM]#index("NOTAM") para saber si las zonas R están activas. Las señales de interceptación y el procedimiento de respuesta (#link(<glosario-sera>)[SERA]#index("SERA")​.11015) se estudian en el Libro 4 (#emph[Comunicaciones]), capítulo 8.

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
#strong[Resumen del capítulo: espacio aéreo]

El cielo está dividido en "cajones" con distintas reglas. No entres sin permiso donde no debes:

- #strong[Clases controladas]: la clase A es solo IFR; en C y D el VFR necesita autorización ATC y comunicación bilateral; en E el VFR no necesita autorización ni radio obligatoria. La separación la garantiza ATC según la clase: IFR siempre, y puede incluir VFR en las clases más restrictivas.
- #strong[Clase G (no controlada)]: vuelas bajo tu responsabilidad, con "ver y evitar". Puedes recibir servicio de información de vuelo (FIS) si está disponible y lo solicitas, pero nadie te separa.
- #strong[Autorizaciones ATC]: una autorización o instrucción no elimina la responsabilidad del #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando"). Si no puedes cumplirla con seguridad, comunícalo de inmediato y coordina una alternativa segura.
- #strong[Zonas especiales]: en una #strong[RMZ] es obligatorio llevar radio y contactar; en una #strong[TMZ], llevar y operar el transponder según los requisitos publicados.

]
= Servicio de tránsito aéreo (ATS) y gestión del tránsito aéreo (ATM)
<servicio-de-tránsito-aéreo-ats-y-gestión-del-tránsito-aéreo-atm>
#quote(block: true)[
Los Servicios de Tránsito Aéreo están para ayudarte, pero debes saber qué pedir: Control, Información o Alerta. Y por encima de ellos hay un sistema mayor que decide qué espacio aéreo tienes disponible cada día.

En este capítulo aprenderás:

- Los tres servicios #link(<glosario-ats>)[ATS]#index("ATS"): Control (#link(<glosario-atc>)[ATC]#index("ATC")), Información (#link(<glosario-fis>)[FIS]#index("FIS")) y Alerta (#link(<glosario-alrs>)[ALRS]#index("ALRS")).
- Cuándo te separan ellos (ATC) y cuándo te separas tú (FIS).
- El protocolo de búsqueda y salvamento: #link(<glosario-incerfa>)[INCERFA]#index("INCERFA"), #link(<glosario-alerfa>)[ALERFA]#index("Fase de alerta") y #link(<glosario-detresfa>)[DETRESFA]#index("Fase de peligro").
- Qué es la gestión del tránsito aéreo (#link(<glosario-atm>)[ATM]#index("ATM")) y por qué el espacio aéreo que ves en la carta no es el que tendrás mañana.
]

== ¿Para qué sirve el ATS?
<para-qué-sirve-el-ats>
El objetivo de los Servicios de Tránsito Aéreo (#strong[ATS], #strong[Air Traffic Services]) va más allá de "vigilar". Según #link(<glosario-sera>)[SERA]#index("SERA")​.7001, sus misiones son prevenir colisiones (entre aeronaves y con obstáculos), acelerar y mantener ordenado el movimiento del tráfico, asesorar y dar información útil para la seguridad, y notificar y auxiliar en emergencias.

Para todo eso, el ATS se divide en tres servicios muy distintos entre sí. Saber cuál estás recibiendo en cada #link(<glosario-momento>)[momento]#index("Momento") marca la diferencia.

== 1. Servicio de control (ATC)
<servicio-de-control-atc>
El servicio de primera división. Su misión principal es #strong[separar] aeronaves.

Lo prestan los controladores aéreos (#link(<glosario-atco>)[ATCO]#index("ATCO")), y de ellos recibes #strong[autorizaciones] (instrucciones obligatorias) e información de tráfico. La responsabilidad de que no choques, bajo ciertas reglas, es del controlador.

Se organiza en tres dependencias según la fase de vuelo (#ref(<fig-01-cap08-dependencias-atc>, supplement: [Figura])):

+ #strong[Torre] (#link(<glosario-twr>)[TWR]#index("TWR")): controla el aeródromo y el circuito (despegues, aterrizajes, rodaje).
+ #strong[Aproximación] (#link(<glosario-app>)[APP]#index("APP")): controla la entrada y salida de la zona del aeropuerto.
+ #strong[Centro de Control de Área] (#link(<glosario-acc>)[ACC]#index("ACC")): controla los aviones en ruta, arriba del todo.

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap08-dependencias-atc.jpg"))
], caption: figure.caption(
position: bottom, 
[
Estructura de dependencias ATC
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap08-dependencias-atc>


== 2. Servicio de información de vuelo (FIS)
<servicio-de-información-de-vuelo-fis>
Es lo que recibimos los planeadores la mayor parte del tiempo, en Clase G o E. Lo prestan controladores o técnicos de información (#link(<glosario-fiso>)[FISO]#index("FISO")), y lo que te dan es #strong[asesoramiento e información]: si hay tráfico, qué tiempo hace, si hay áreas peligrosas activas…​

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
== 3. Servicio de alerta (ALRS)
<servicio-de-alerta-alrs>
Tu seguro de vida. Se activa cuando hay una emergencia o se teme por la seguridad de una aeronave, y funciona en tres fases de preocupación creciente (#ref(<fig-01-cap08-fases-emergencia>, supplement: [Figura])):

+ #strong[INCERFA (Fase de incertidumbre)]: existe incertidumbre sobre la seguridad de la aeronave y sus ocupantes. Se empieza a recabar información. Se declara reglamentariamente ante cualquiera de estas tres situaciones:

- #strong[Falta de comunicación]: no se ha recibido ninguna comunicación de la aeronave en los 30 minutos siguientes a la hora prevista, o desde el primer intento fallido de contactarla (lo que ocurra primero).
- #strong[Retraso en la llegada]: la aeronave no llega en los 30 minutos siguientes a su hora prevista de llegada (#link(<glosario-eta>)[ETA]#index("ETA")).
- #strong[Dudas sobre la seguridad]: existen sospechas o dudas fundamentadas sobre la seguridad de la aeronave y sus ocupantes.

#block[
#set enum(numbering: "1.", start: 2)
+ #strong[ALERFA (Fase de alerta)]: existe preocupación por la seguridad de la aeronave y sus ocupantes. Se avisa a los servicios de rescate (#link(<glosario-sar>)[SAR]#index("SAR")) para que estén listos.
+ #strong[DETRESFA (Fase de peligro)]: existe certeza razonable de que la aeronave y sus ocupantes están amenazados por un peligro grave e inminente y necesitan ayuda inmediata. Salen los medios de rescate: helicópteros y aviones SAR.
]

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap08-fases-emergencia.jpg"))
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
Dos remisiones útiles dentro de la colección: las #strong[señales luminosas] con las que una torre puede dirigirte sin radio se estudian en el #strong[Libro 4 --- Comunicaciones], capítulo 7; y el #strong[plan de vuelo], que alimenta este servicio de alerta, en los Libros 4 --- Comunicaciones (operativa), 7 --- Planificación y Rendimiento de Vuelo (formulario) y 9 --- Navegación (uso de los ATS).

== La gestión del tránsito aéreo (ATM)
<la-gestión-del-tránsito-aéreo-atm>
El ATS es la parte del sistema que te habla por radio. Pero por encima hay algo más grande: la #strong[Gestión del Tránsito Aéreo] (#strong[ATM]), que administra a la vez el tráfico y el espacio por el que vuela. Son tres patas:

- #strong[ATS]: los tres servicios que acabas de ver. La que te atiende.
- #strong[#link(<glosario-asm>)[ASM]#index("ASM")]: la gestión del espacio aéreo. Decide qué espacio hay disponible, para quién y cuándo.
- #strong[#link(<glosario-atfm>)[ATFM]#index("ATFM")]: la gestión de afluencia. Ajusta el número de aviones a lo que el sistema puede tragar.

De las tres, la que te toca de cerca es la segunda.

Durante décadas, el espacio militar era militar los siete días de la semana, se usara o no. Hoy rige el #strong[uso flexible del espacio aéreo] (#strong[#link(<glosario-fua>)[FUA]#index("FUA")]): el espacio es un recurso único que se reparte cada día según quién lo necesite de verdad. Una célula de gestión decide por la tarde qué zonas se activan mañana y cuáles se liberan, y lo publica.

De ahí salen zonas que existen sólo a ratos: las #strong[#link(<glosario-tsa>)[TSA]#index("TSA")] y las #strong[#link(<glosario-tra>)[TRA]#index("TRA")], reservadas por horas. Y rutas que sólo están abiertas cuando la zona que cruzan queda libre: las #strong[#link(<glosario-cdr>)[CDR]#index("CDR")].

#block[
#callout(
body: 
[
La carta te dice dónde está una zona. Nunca si hoy está activa. Eso lo dicen los #link(<glosario-notam>)[NOTAM]#index("NOTAM") y la publicación diaria del espacio aéreo, y se mira en la preparación del vuelo, no en el aire.

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
La afluencia es otra historia y apenas te afecta. Cuando hay más aviones que capacidad, el sistema reparte la escasez con #strong[slots]: horas de despegue asignadas que retienen al avión en tierra en vez de amontonarlo en el aire. Es cosa del tráfico #link(<glosario-ifr>)[IFR]#index("IFR") con plan de vuelo. Un planeador en #link(<glosario-vfr>)[VFR]#index("VFR") por Clase G ni los recibe ni los necesita; como mucho, explica por qué un aeródromo con tráfico comercial te hace esperar.

#block[
#callout(
body: 
[
El uso flexible del espacio aéreo lo establece el #strong[Reglamento (CE) n.º 2150/2005], que fija las normas comunes para repartirlo en la Unión Europea.

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
El espacio aéreo del que dispones hoy no es el de ayer. Repetir la travesía de la semana pasada sin mirar otra vez qué zonas están activas es volar con una foto vieja.

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
#strong[Resumen del capítulo: servicios de tránsito aéreo (ATS) y gestión del tránsito aéreo (ATM)]

El ATS te ofrece tres tipos de ayuda:

- #strong[Control (ATC)]: te dan órdenes (autorizaciones) para separarte de otros aviones. Son la TWR, la APP y el ACC, y solo opera en #link(<glosario-espacio-aereo-controlado>)[espacio aéreo controlado]#index("Espacio aéreo controlado").
- #strong[Información de vuelo (FIS)]: te dan información útil (meteo, peligros, tráficos cercanos), pero el responsable de evitar colisiones eres tú. "Información de tráfico" no es "separación".
- #strong[Alerta (ALRS)]: avisa a búsqueda y salvamento (SAR) si no llegas a tiempo o tienes una emergencia.

Y el ATS es sólo una de las tres patas del #strong[ATM]:

- #strong[ATM = ATS + ASM + ATFM]: los servicios que te atienden, la gestión del espacio aéreo y la de afluencia.
- #strong[Uso flexible (FUA)]: el espacio se reparte cada día, no de una vez para siempre. Hay zonas que existen sólo a ratos (TSA, TRA) y rutas abiertas sólo cuando aquellas se liberan (CDR).
- #strong[Lo que te toca a ti]: la carta dice dónde está una zona; los NOTAM dicen si hoy está activa. Los #emph[slots] del ATFM son cosa del tráfico IFR: a un planeador en Clase G no le afectan.

]
= Servicios de información aeronáutica (AIS)
<servicios-de-información-aeronáutica-ais>
#quote(block: true)[
La información es seguridad; un piloto que ignora los #link(<glosario-notam>)[NOTAM]#index("NOTAM") es un piloto que vuela a ciegas hacia el peligro.

En este capítulo aprenderás:

- Las tres fuentes de información: #link(<glosario-aip>)[AIP]#index("AIP") (permanente), NOTAM (urgente) y #link(<glosario-aic>)[AIC]#index("AIC") (informativo).
- El deber legal del piloto de consultar la información disponible antes del vuelo.
- Cómo usar ENAIRE Insignia para ver las restricciones sobre el mapa.
]

== La información es seguridad
<la-información-es-seguridad>
Antes de despegar, el piloto debe "familiarizarse con toda la información disponible". No es un consejo: es una #strong[obligación legal] (#link(<glosario-sera>)[SERA]#index("SERA")​.2010). Para que puedas cumplirla, los estados prestan los Servicios de Información Aeronáutica (#strong[#link(<glosario-ais>)[AIS]#index("AIS")]).

En España, el proveedor principal es #strong[ENAIRE], y todo se agrupa en la "Documentación integrada de información aeronáutica" (#link(<glosario-iaip>)[IAIP]#index("IAIP")).

== El manual AIP (Publicación de Información Aeronáutica)
<el-manual-aip-publicación-de-información-aeronáutica>
El #strong[AIP] es la "biblia" de la aviación de un país: contiene la información permanente esencial para navegar, organizada en tres volúmenes (#ref(<fig-01-cap09-estructura-aip>, supplement: [Figura])):

+ #strong[GEN (Generalidades)]: reglamentos, señales de socorro, tablas de conversión, salida y puesta de sol, servicios disponibles.
+ #strong[ENR (En Ruta)]: estructura del espacio aéreo (vías aéreas, zonas prohibidas y restringidas), radioayudas, alertas para la navegación.
+ #strong[#link(<glosario-ad>)[AD]#index("Aerodromos") (Aeródromos)]: datos detallados de cada aeropuerto: pistas, frecuencias, horarios, mapas de aproximación y rodaje.

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap09-estructura-aip.jpg"))
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
El AIP no cambia cada día. Las actualizaciones importantes y previsibles (nuevas rutas, frecuencias) se publican siguiendo el sistema #strong[#link(<glosario-airac>)[AIRAC]#index("AIRAC")] (Reglamentación y Control de la Información Aeronáutica), que garantiza que los cambios llegan a todos con antelación suficiente antes de entrar en vigor.

== Noticias urgentes: NOTAM (Notice to airmen)
<noticias-urgentes-notam-notice-to-airmen>
#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap09-ejemplo-notam.jpg"))
], caption: figure.caption(
position: bottom, 
[
Decodificación básica de un NOTAM
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-01-cap09-ejemplo-notam>


Hay cosas que no pueden esperar al ciclo AIRAC: una grúa en #link(<glosario-final>)[final]#index("Tramo final") de pista, un #link(<glosario-vor>)[VOR]#index("VOR") inoperativo, un festival aéreo el sábado…​ Para eso existen los #strong[NOTAM]: avisos temporales (generalmente de 3 meses como máximo) sobre el establecimiento, estado o modificación de cualquier instalación, servicio o procedimiento aeronáutico, o sobre un peligro para la navegación (#ref(<fig-01-cap09-ejemplo-notam>, supplement: [Figura])).

Consultar los NOTAM de tu aeródromo de salida, destino, alternativos y la ruta antes de #strong[cada] vuelo es obligatorio.

== Circulares de Información Aeronáutica (AIC)
<circulares-de-información-aeronáutica-aic>
Son avisos que no justifican un NOTAM (no afectan a la operación de forma urgente y directa) pero conviene conocer: asuntos administrativos como nuevas tasas, recomendaciones de seguridad estacionales, prevención de #link(<glosario-engelamiento>)[engelamiento]#index("Engelamiento") o explicaciones técnicas.

#block[
#callout(
body: 
[
En España, puedes consultar todo esto gratis en los portales #strong[ICARO] e #strong[Insignia] de ENAIRE. Insignia es una herramienta visual fantástica para ver los NOTAM sobre el mapa. Acostúmbrate a usarla.

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
#strong[Resumen del capítulo: servicio de información aeronáutica (AIS)]

La información es seguridad. Tus fuentes:

- #strong[AIP]: el "manual gordo" y permanente. Mapas, frecuencias, zonas peligrosas, horarios de aeropuertos. Es la #link(<glosario-base>)[base]#index("Tramo de base").
- #strong[NOTAM]: la actualidad. Avisos temporales urgentes (una pista cerrada, un festival aéreo, una restricción temporal). Consultarlos antes de cada vuelo es obligatorio.
- #strong[AIC]: circulares informativas sobre seguridad y cambios administrativos.

]
= Aeródromos y campos de despegue externos
<aeródromos-y-campos-de-despegue-externos>
#quote(block: true)[
En el circuito de tránsito, las reglas visuales reinan supremas; aprende a leer las señales del suelo cuando la radio calla.

En este capítulo aprenderás:

- El circuito de tránsito: sus fases (#link(<glosario-viento-en-cola>)[viento en cola]#index("Viento en cola"), #link(<glosario-base>)[base]#index("Tramo de base"), #link(<glosario-final>)[final]#index("Tramo final")) y el sentido de viraje.
- El área de señales: la "T" de aterrizaje, la manga de viento y los símbolos de prohibición en el suelo.
- Normas básicas para moverse por el aeródromo con seguridad.
]

== El aeródromo: territorio de reglas visuales
<el-aeródromo-territorio-de-reglas-visuales>
Un aeródromo es mucho más que una pista. Es un sistema organizado para que aviones rápidos y planeadores lentos convivan sin chocar, y se apoya en dos pilares: el #strong[circuito de tránsito] y las #strong[señales visuales].

== El circuito de tránsito (Traffic Pattern)
<el-circuito-de-tránsito-traffic-pattern>
Para ordenar el tráfico, todos volamos un rectángulo imaginario alrededor de la pista. Los virajes se hacen a la #strong[izquierda] salvo que se indique lo contrario (#ref(<fig-01-cap10-circuito-transito>, supplement: [Figura])). En planeador, el tramo de viento en cola suele volarse a unos #strong[200-300 metros #link(<glosario-agl>)[AGL]#index("AGL")], y lo ideal es incorporarse al circuito a 45º de ese tramo.

=== Fases clave para el planeador
<fases-clave-para-el-planeador>
+ #strong[Viento en cola] (#strong[downwind]): vuelas paralelo a la pista, en sentido contrario al aterrizaje. Aquí va el chequeo pre-aterrizaje.
+ #strong[Tramo base]: viras 90º hacia la pista y haces el último ajuste de altura y velocidad. Altura mínima de inicio: 150 m.
+ #strong[Final]: enfilado a pista, con frenos fuera.

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap10-circuito-transito.jpg"))
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
#box(image("01-derecho-aereo-atc/imagenes/01-cap10-manga-viento.png"))
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
#box(image("01-derecho-aereo-atc/imagenes/01-cap10-senales-aerodromo.png"))
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
- #strong[Responsabilidad del #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando")]: eres responsable de verificar que el terreno es adecuado y la operación segura (dimensiones, obstáculos, personas ajenas). Un campo externo no tiene área de señales, ni servicio de información, ni nadie que haya inspeccionado la superficie por ti.
- #strong[Tras una toma fuera de campo]: la aeronave puede haber causado daños (cultivos, cercados) de los que respondes civilmente; el seguro obligatorio de responsabilidad civil cubre precisamente estos supuestos. Localiza al propietario, documenta el estado del terreno y acuerda la retirada del planeador --- la parte operativa y de trato con el propietario se desarrolla en el #strong[Libro 6 --- Procedimientos Operativos].

#postit[
#strong[Resumen del capítulo: aeródromos]

En tierra, las reglas visuales mandan:

- #strong[Circuito de tránsito]: virajes a la #strong[izquierda], salvo señal en contrario.
- #strong[Área de señales]: la manga de viento indica dirección e intensidad; la T tumbada, la dirección de aterrizaje y despegue; la flecha derecha avisa de virajes a la derecha; la cruz roja con diagonales amarillas prohíbe aterrizar; el panel rojo con una sola diagonal pide precaución por mal estado del área de maniobras; y la doble cruz blanca anuncia planeadores en actividad.

]
= Búsqueda y salvamento (#emph[search and rescue])
<búsqueda-y-salvamento-search-and-rescue>
#quote(block: true)[
Cuando todo lo demás falla, el Sistema de Búsqueda y Salvamento es tu última línea de defensa; permite que te encuentren.

En este capítulo aprenderás:

- Quién coordina el rescate en España (los #link(<glosario-rcc>)[RCC]#index("RCC")).
- Las fases de emergencia: #link(<glosario-incerfa>)[INCERFA]#index("INCERFA") (duda), #link(<glosario-alerfa>)[ALERFA]#index("Fase de alerta") (preocupación) y #link(<glosario-detresfa>)[DETRESFA]#index("Fase de peligro") (peligro inminente).
- El código visual de supervivencia (V, X, N, Y) para comunicarte sin radio.
]

== Cuando todo falla: el sistema SAR
<cuando-todo-falla-el-sistema-sar>
El Servicio de Búsqueda y Salvamento (#strong[#link(<glosario-sar>)[SAR]#index("SAR")], #strong[Search and Rescue]) es tu red de seguridad #link(<glosario-final>)[final]#index("Tramo final"). En España es responsabilidad del #strong[Ejército del Aire], con apoyo de otros medios, y su misión es simple: encontrarte y salvarte.

=== Organización
<organización>
Quien mueve los hilos es el #strong[RCC] (Centro Coordinador de Salvamento). En España hay tres principales:

+ #strong[RCC Madrid] (#link(<glosario-base>)[Base]#index("Tramo de base") Aérea de Torrejón): cubre la mayor parte de la península.
+ #strong[RCC Canarias] (Base Aérea de Gando): cubre el archipiélago y una inmensa zona del Atlántico.
+ #strong[RCC Palma] (Base Aérea de Son San Juan): cubre el Mediterráneo y Baleares.

Existen también #strong[#link(<glosario-rsc>)[RSC]#index("RSC")] (subcentros) para zonas específicas.

== Las fases de emergencia (repaso SAR)
<las-fases-de-emergencia-repaso-sar>
El SAR no sale a buscar "porque sí". Actúa escalonadamente según la gravedad, en fases que activa el #link(<glosario-atc>)[ATC]#index("ATC") o el propio RCC:

+ #strong[INCERFA (Fase de incertidumbre)]: existe incertidumbre sobre la seguridad de la aeronave y sus ocupantes. El RCC empieza a recabar información.
+ #strong[ALERFA (Fase de alerta)]: existe preocupación por la seguridad de la aeronave y sus ocupantes. Se preparan los equipos SAR.
+ #strong[DETRESFA (Fase de peligro)]: existe certeza razonable de peligro grave e inminente y de que se necesita ayuda inmediata. Despegan los medios: aviones y helicópteros (#ref(<fig-01-cap11-actuacion-accidente>, supplement: [Figura])).

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap11-actuacion-accidente.jpg"))
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
#box(image("01-derecho-aereo-atc/imagenes/01-cap11-senales-socorro.jpg"))
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
#postit[
#strong[Resumen del capítulo: búsqueda y salvamento (SAR)]

Si algo sale mal, el SAR te buscará. Conoce las fases:

- #strong[INCERFA (Fase de incertidumbre)]: existe incertidumbre sobre la seguridad de la aeronave y sus ocupantes.
- #strong[ALERFA (Fase de alerta)]: existe preocupación por la seguridad de la aeronave y sus ocupantes.
- #strong[DETRESFA (Fase de peligro)]: existe certeza razonable de peligro grave e inminente y de que se necesita ayuda inmediata.
- #strong[Señales tierra-aire]: #strong[V] = necesito ayuda; #strong[X] = necesito ayuda médica; #strong[N] = no; #strong[Y] = sí.

]
= Seguridad (#emph[security])
<seguridad-security>
#quote(block: true)[
La seguridad de la aviación no es solo para grandes aerolíneas; proteger tu aeronave de actos ilícitos es una responsabilidad fundamental del piloto.

En este capítulo aprenderás:

- La diferencia entre evitar accidentes (#strong[safety]) y prevenir actos criminales (#strong[security]).
- Cómo asegurar tu aeronave en tierra y comprobar que nadie la ha manipulado.
- Qué artículos están prohibidos a bordo por riesgo para la seguridad.
]

== Safety vs security: ¿no es lo mismo?
<safety-vs-security-no-es-lo-mismo>
En español usamos "seguridad" para todo, pero en aviación conviven dos conceptos muy distintos (#ref(<fig-01-cap12-safety-vs-security>, supplement: [Figura])):

+ #strong[Seguridad operacional] (#strong[safety]): prevenir #strong[accidentes] no intencionados. Que no se pare el motor, que no choques, que el mantenimiento esté bien hecho. Es "volar seguro".
+ #strong[Seguridad de la aviación] (#strong[security]): protegerse contra #strong[actos ilícitos] intencionados. Que no te roben el avión, que nadie ponga una bomba, evitar secuestros. Es protección física.

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap12-safety-security.jpg"))
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
- #strong[Documentación]: lleva siempre tu identificación (DNI, licencia). La Guardia Civil o la autoridad del aeropuerto pueden pedírtela en cualquier #link(<glosario-momento>)[momento]#index("Momento"), en zona de aire o de tierra.

== Mercancías peligrosas (Dangerous Goods)
<mercancías-peligrosas-dangerous-goods>
Son artículos o sustancias que pueden poner en riesgo la salud, la seguridad o la propiedad. La regla general es simple: #strong[prohibido] llevarlas a bordo (#ref(<fig-01-cap12-mercancias-peligrosas>, supplement: [Figura])). Se admiten cantidades razonables de lo necesario para el vuelo o la seguridad (oxígeno medicinal aprobado, baterías de litio de uso personal bajo ciertas condiciones), siempre con precaución extrema.

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap12-mercancias-peligrosas.jpg"))
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
#postit[
#strong[Resumen del capítulo: seguridad (Security)]

Ojo a la diferencia en inglés:

- #strong[SAFETY]: seguridad operacional. Que no te accidentes volando.
- #strong[SECURITY]: seguridad física. Que no te roben el avión ni pongan una bomba.
- #strong[Tu deber]: no dejar el avión abierto o accesible a desconocidos, no llevar mercancías peligrosas (salvo excepciones aprobadas) y respetar las zonas restringidas de los aeropuertos.

]
= Notificación de accidentes
<notificación-de-accidentes>
#quote(block: true)[
Notificar sucesos no busca culpables, sino aprender de los errores para mantener los cielos seguros para todos.

En este capítulo aprenderás:

- Las diferencias legales entre accidente, incidente grave e incidente.
- Cuándo debes reportar un suceso a la #link(<glosario-ciaiac>)[CIAIAC]#index("CIAIAC") y a #link(<glosario-aesa>)[AESA]#index("AESA"), y sus plazos: sin demora a la primera, 72 horas a la segunda.
- El principio de "#link(<glosario-cultura-justa>)[cultura justa]#index("Cultura justa")": reportar errores honestos sin miedo al castigo.
]

== Definiciones clave (Reglamento UE 996/2010 y 376/2014)
<definiciones-clave-reglamento-ue-9962010-y-3762014>
En aviación no todo es un accidente. Hay matices legales que importan (#ref(<fig-01-cap13-piramide-sucesos>, supplement: [Figura])):

+ #strong[ACCIDENTE]: alguien sufre lesiones mortales o graves; la aeronave sufre daños estructurales importantes o fallos que afectan a su resistencia o capacidad de vuelo; o la aeronave desaparece o queda inaccesible.
+ #strong[INCIDENTE GRAVE]: un suceso con alta probabilidad de haber acabado en accidente. El clásico "casi pasa".
+ #strong[INCIDENTE]: cualquier otro suceso que afecte o pueda afectar a la seguridad, sin llegar a lo anterior.

#figure([
#box(image("01-derecho-aereo-atc/imagenes/01-cap13-piramide-sucesos.jpg"))
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
#box(image("01-derecho-aereo-atc/imagenes/01-cap13-flujo-notificacion.jpg"))
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
#postit[
#strong[Resumen del capítulo: accidentes e incidentes]

- #strong[Accidente]: hay lesiones mortales o graves, daños estructurales al avión, o la aeronave desaparece o queda inaccesible.
- #strong[Incidente grave]: las circunstancias indican que hubo alta probabilidad de accidente, o el suceso puso (o pudo poner) en peligro la seguridad de la operación.
- #strong[Obligación]: comunicarlo #strong[sin demora] a la #strong[CIAIAC]\; notificar el suceso a #strong[AESA] en un plazo máximo de #strong[72 horas].
- #strong[Pruebas]: no toques nada, salvo para salvar vidas o evitar otro peligro. Preservar los restos es vital para la investigación.

]
= Derecho nacional
<derecho-nacional>
#quote(block: true)[
Más allá de las normas europeas, la legislación nacional rige nuestra actividad; conocer la Ley de Seguridad Aérea evita costosas sorpresas legales.

En este capítulo aprenderás:

- El papel de la Ley de Seguridad Aérea (#link(<glosario-lsa>)[LSA]#index("LSA") 21/2003) en España.
- Quién es quién entre la #link(<glosario-dgac>)[DGAC]#index("DGAC") y #link(<glosario-aesa>)[AESA]#index("AESA"): una define la política, la otra vigila su cumplimiento.
- El régimen sancionador: infracciones leves, graves y muy graves, y sus consecuencias.
]

== La legislación española: el marco nacional
<la-legislación-española-el-marco-nacional>
Además de la normativa europea (#link(<glosario-easa>)[EASA]#index("EASA")/#link(<glosario-sera>)[SERA]#index("SERA")), en España existe legislación propia que complementa y desarrolla el marco comunitario. La ley principal es la #strong[Ley 21/2003, de 7 de julio, de Seguridad Aérea (LSA)].

== La Dirección General de Aviación Civil (DGAC)
<la-dirección-general-de-aviación-civil-dgac>
La #strong[Dirección General de Aviación Civil (DGAC)] es el órgano directivo del Ministerio de Transportes y Movilidad Sostenible encargado de diseñar la estrategia y dirigir la política aeronáutica.

Mientras AESA supervisa y sanciona, la DGAC juega en el terreno político y normativo: diseña la estrategia del sector aéreo, elabora y propone la normativa nacional, representa a España en organismos como la #link(<glosario-oaci>)[OACI]#index("OACI") y coordina a los distintos organismos del sector.

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
#box(image("01-derecho-aereo-atc/imagenes/01-cap14-escala-infracciones.jpg"))
], caption: figure.caption(
position: bottom, 
[
#link(<glosario-escala>)[Escala]#index("Escala") de infracciones aeronáuticas
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
#postit[
#strong[Resumen del capítulo: derecho nacional]

Además de Europa, en España manda la #strong[Ley de Seguridad Aérea (LSA 21/2003)].

- Establece el régimen de infracciones y sanciones: las #strong[muy graves] (muerte o accidente) pueden acarrear la inhabilitación.
- #strong[DGAC]: define la política aeronáutica (las "reglas del juego").
- #strong[AESA]: vigila y sanciona (el "árbitro").

]
#part[Parte 02: Factores Humanos]
= Factores humanos: conceptos básicos
<factores-humanos-conceptos-básicos>
#quote(block: true)[
La técnica con los mandos no basta: la mayoría de los accidentes en vuelo a vela tienen una causa humana, y casi todos son evitables. Este capítulo te da el marco para entender por qué erramos y cómo interponer barreras antes de que el error llegue a consecuencias.

En este capítulo aprenderás:

- #strong[El modelo #link(<glosario-shell>)[SHELL]#index("SHELL")]: cómo interactúas con el software, el hardware, el entorno y las demás personas.
- #strong[El error humano y el queso suizo]: por qué errar es inevitable y cómo se alinean los fallos.
- #strong[La #link(<glosario-cadena-del-error>)[cadena del error]#index("Cadena del error")]: por qué basta romper un eslabón para evitar el accidente.
- #strong[Las influencias en el comportamiento]: presión de grupo, #link(<glosario-cultura-justa>)[cultura justa]#index("Cultura justa") y la pirámide de Maslow.
]

== Introducción a los factores humanos y la seguridad en el vuelo
<introducción-a-los-factores-humanos-y-la-seguridad-en-el-vuelo>
El vuelo a vela exige la coordinación constante entre el piloto, la aeronave y un entorno en permanente cambio. Durante décadas, la formación de pilotos se centró casi exclusivamente en las habilidades de manejo de los mandos (#strong[stick and rudder skills]). La experiencia ha demostrado, sin embargo, que una técnica impecable no garantiza por sí sola la seguridad del vuelo. Aquí entran en juego los #strong[factores humanos].

La Organización de Aviación Civil Internacional (#link(<glosario-oaci>)[OACI]#index("OACI") (Organización de Aviación Civil Internacional)) define los factores humanos como los elementos medioambientales, organizativos, laborales y las características individuales que influyen en el comportamiento dentro del entorno aeronáutico, con efecto directo sobre la salud y la seguridad operacional. En términos prácticos, se trata de comprender cómo interactúa el piloto con la aeronave, los procedimientos, la meteorología y el resto de personas implicadas en la operación.

El piloto no es infalible. Existen limitaciones inherentes en la percepción, la memoria y la capacidad de procesar información compleja bajo presión. La disciplina de los factores humanos no pretende transformar al piloto en un agente sin errores, sino enseñarle a #strong[reconocer sus limitaciones fisiológicas y psicológicas], aceptarlas y aplicar estrategias contrastadas para gestionarlas en beneficio de la toma de decisiones aeronáuticas (#strong[Aeronautical Decision-Making], #link(<glosario-adm>)[ADM]#index("ADM")).

== El factor humano en los accidentes de aviación
<el-factor-humano-en-los-accidentes-de-aviación>
A medida que la tecnología aeronáutica ha avanzado, la proporción de accidentes debidos a fallos mecánicos ha disminuido de forma significativa. Las estadísticas actuales reflejan que #strong[el factor humano es la causa principal o un elemento contribuyente en aproximadamente el 90 % de los accidentes en la aviación general y el vuelo a vela]. Este dato es, ante todo, pedagógico: la inmensa mayoría de estos accidentes son previsibles y, por tanto, #strong[evitables].

El desglose del componente humano en la siniestralidad del vuelo a vela muestra las siguientes proporciones habituales:

- #strong[Toma de decisiones inadecuada (aprox. 40 %):] Factor predominante. Incluye continuar el vuelo hacia condiciones meteorológicas adversas o posponer en exceso la búsqueda de un aterrizaje fuera de campo.
- #strong[Errores de pilotaje (aprox. 30 %):] Fallos en la técnica de vuelo o en el manejo de los mandos, con frecuencia relacionados con estados de distracción.
- #strong[Preparación deficiente antes del vuelo (aprox. 12 %):] Omisiones críticas durante el #link(<glosario-rigging>)[montaje]#index("Rigging") o la verificación previa al despegue, como no conectar correctamente los mandos o no asegurar la cabina.
- #strong[#link(<glosario-conciencia-situacional>)[Conciencia situacional]#index("Conciencia situacional") insuficiente (aprox. 6 %):] Pérdida de percepción espacial o visual del tránsito, con riesgo de colisión en vuelo (#strong[mid-air collision]).

#block[
#callout(
body: 
[
El análisis del Informe de Seguridad de #link(<glosario-easa>)[EASA]#index("EASA") (European Union Aviation Safety Agency) indica que las fases más críticas del vuelo en planeador son el aterrizaje (aproximadamente el 50 % de los accidentes) y el despegue (21 %). Mantenga el máximo nivel de atención durante estos periodos, con la cabina libre de distracciones y todos los sistemas verificados.

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
Los accidentes con consecuencias fatales (hasta un 26 % según datos de EASA (European Union Aviation Safety Agency)) tienen como causa principal la pérdida de control en vuelo, que con frecuencia #link(<glosario-deriva>)[deriva]#index("Deriva") en pérdida aerodinámica y barrena (#strong[stall and spin]), especialmente peligrosas a baja altura en el #link(<glosario-circuito-de-trafico>)[circuito de tráfico]#index("Circuito de tráfico"). Otras causas graves incluyen las colisiones contra el terreno (17 %) y las emergencias mal gestionadas en lanzamientos a #link(<glosario-torno>)[torno]#index("Torno") incompletos (10 %).

Conocer estas estadísticas permite al piloto priorizar la atención en las fases y situaciones de mayor riesgo, y adoptar criterios de decisión más conservadores donde la experiencia demuestra que los márgenes son más estrechos.

== Modelos conceptuales: el modelo SHELL
<modelos-conceptuales-el-modelo-shell>
El vuelo a vela no ocurre en el vacío; es una actividad donde el ser humano interactúa constantemente con su entorno. Para comprender esta interacción, la OACI utiliza el #strong[Modelo SHELL], un marco conceptual desarrollado originariamente por el psicólogo Elwyn Edwards en 1972 (como modelo SHEL) y refinado después por Frank Hawkins, que añadió la segunda L de las otras personas. Su nombre es un acrónimo de sus componentes, que encajan entre sí como las piezas de un rompecabezas con el factor humano siempre en el centro (#ref(<fig-02-cap01-modelo-shell>, supplement: [Figura])):

- #strong[Software (S):] Los elementos no materiales. Incluye la reglamentación aplicable, manuales de vuelo, procedimientos normativos, listas de chequeo (#strong[checklists]) y la simbología aeronáutica.
- #strong[Hardware (H):] La máquina. Abarca el propio velero, los instrumentos de a bordo y cualquier otra herramienta o equipo físico.
- #strong[Environment (E):] El entorno donde se opera. Implica tanto las condiciones externas (meteorología, #link(<glosario-cavok>)[visibilidad]#index("Visibilidad"), turbulencia) como las internas de la cabina (ruido, temperatura, ergonomía).
- #strong[Liveware (L - otras personas):] Las personas con las que interactúas en el desarrollo del vuelo, como tu instructor, personal de pista, controladores u otros pilotos.
- #strong[Liveware (L - yo central):] Tú, el #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando") (#strong[Pilot in Command]). Se refiere a tus capacidades físicas y cognitivas, nivel de entrenamiento, experiencia, así como tu estado de #link(<glosario-fatiga>)[fatiga]#index("Fatiga") o estrés.

#figure([
#box(image("02-factores-humanos/imagenes/02-cap01-modelo-shell.png"))
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
#box(image("02-factores-humanos/imagenes/02-cap01-queso-suizo.png"))
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

Según el #link(<glosario-momento>)[momento]#index("Momento") en que se manifiestan respecto al accidente, los errores se distinguen en:

- #strong[Errores latentes:] Vulnerabilidades preexistentes en el sistema, como una instrucción inicial deficiente o un procedimiento inadecuado que favorece el fallo.
- #strong[Errores activos:] La equivocación inmediata que precipita la cadena del accidente, como intentar un viraje a baja velocidad y baja altura.

#block[
#callout(
body: 
[
Para reducir la probabilidad de error, utilice las listas de verificación aunque conozca el procedimiento de memoria, solicite la evaluación del instructor con regularidad y esté atento a factores que degradan el rendimiento, como la fatiga o la #link(<glosario-complacencia>)[complacencia]#index("Complacencia") derivada de la experiencia acumulada.

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
#box(image("02-factores-humanos/imagenes/02-cap01-cadena-error.jpg"))
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

La conclusión práctica es clara: la seguridad ocupa la #link(<glosario-base>)[base]#index("Tramo de base") de la pirámide y no puede subordinarse a ningún objetivo de orden superior (#ref(<fig-02-cap01-piramide-maslow>, supplement: [Figura])).

#figure([
#box(image("02-factores-humanos/imagenes/02-cap01-piramide-maslow.png"))
], caption: figure.caption(
position: bottom, 
[
La pirámide de Maslow aplicada a un piloto de planeadores
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap01-piramide-maslow>


#postit[
#strong[Resumen del capítulo: conceptos básicos de factores humanos]

- #strong[Modelo SHELL]: Marco conceptual fundamental que analiza la interacción entre el piloto (Liveware) y otros elementos: Software (procedimientos), Hardware (la aeronave), Environment (el entorno) y otro Liveware (otras personas).
- #strong[Gestión del error]: Se asume que el error humano es inevitable. El objetivo de la seguridad no es eliminarlo por completo, sino detectarlo a tiempo y gestionar sus consecuencias antes de que afecten a la seguridad del vuelo.
- #strong[Cadena del error]: Los accidentes rara vez ocurren por una sola causa. Son la suma de pequeños errores y condiciones latentes. Tu trabajo es romper esa cadena en cuanto detectes el primer eslabón.
- #strong[Influencias en el comportamiento]: El comportamiento mental bajo presión, nuestra motivación diaria aplicada al vuelo frente a una base de necesidades insatisfechas (Pirámide de Maslow), así como la presión directa de compañeros de hangar, alteran profundamente nuestra capacidad mental como comandantes. Debemos respaldar una rigurosa "cultura justa" para permitir el libre reporte de errores técnicos sin represión ajena, aprendiendo en colectivo en lugar de esconder daños fatales.

]
= Fisiología aeronáutica básica y mantenimiento de salud
<fisiología-aeronáutica-básica-y-mantenimiento-de-salud>
#quote(block: true)[
Este capítulo aborda cómo el entorno del vuelo afecta al organismo humano y los determinantes de la condición física del piloto de planeador. Repasaremos su impacto en los sentidos, el desgaste provocado por la altitud y las directrices normativas innegociables para preservar la seguridad operacional antes de situarse a los mandos.
]

== Aptitud para el vuelo y la evaluación personal (lista de chequeo IMSAFE)
<aptitud-para-el-vuelo-y-la-evaluación-personal-lista-de-chequeo-imsafe>
Como piloto de planeador, el estado de salud física y mental es el componente más crítico para la seguridad del vuelo. La normativa europea establece claramente que un piloto debe abstenerse de volar si está incapacitado por cualquier causa, como una lesión, enfermedad, medicación, #link(<glosario-fatiga>)[fatiga]#index("Fatiga") o los efectos de cualquier sustancia psicoactiva, o si simplemente se siente indispuesto.

#block[
#callout(
body: 
[
Es obligatorio consultar con un Médico Examinador Aéreo (#link(<glosario-ame>)[AME]#index("AME")) o médico general si se ha sufrido una lesión importante, cirugía, inicio de medicación regular, embarazo, o uso por primera vez de lentes correctoras. Estas situaciones requieren una nueva evaluación de la aptitud médica; el piloto debe abstenerse de volar al mando hasta que se resuelva la causa y recupere la condición apta (#strong[#link(<glosario-med>)[MED]#index("Part-MED")​.A.020 Decrease in medical fitness]).

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
Para ayudar a evaluar sistemáticamente la condición individual antes de acceder a la cabina, la aviación ha estandarizado una lista de chequeo personal conocida por el acrónimo mnemotécnico #strong[#link(<glosario-imsafe>)[IMSAFE]#index("IMSAFE")] (del inglés "I am safe" - #strong[Estoy a salvo]). Esta revisión es tan vital como la propia inspección prevuelo del planeador (#ref(<fig-02-cap02-imsafe-checklist>, supplement: [Figura])):

#figure([
#box(image("02-factores-humanos/imagenes/02-cap02-imsafe.jpg"))
], caption: figure.caption(
position: bottom, 
[
Evaluación personal del piloto antes del vuelo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-02-cap02-imsafe-checklist>


- #strong[I - #emph[Illness] (Enfermedad):] ¿Tiene algún síntoma actual? Incluso un resfriado puede agravarse con los cambios de presión en vuelo (#link(<glosario-disbarismos>)[disbarismos]#index("Disbarismos")) y mermar la capacidad de atención. No vuele si presenta fiebre o proceso vírico.
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
Una percepción correcta de los colores es obligatoria. Durante el reconocimiento médico inicial deberá superar pruebas como el test de Ishihara. Si no demuestra discriminación de color segura, la licencia de piloto de planeador ---regida por la normativa Part-SFCL--- quedará restringida al vuelo diurno (#strong[Day] #link(<glosario-vfr>)[VFR]#index("VFR")).

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
#box(image("02-factores-humanos/imagenes/02-cap02-escaneo-visual.jpg"))
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

- #strong[Aproximación de agujero negro (Black Hole Approach):] Al realizar el #link(<glosario-final>)[tramo final]#index("Tramo final") hacia una pista iluminada rodeada de terreno muy oscuro y sin referencias luminosas laterales (como un lago), el cerebro pierde la percepción real de profundidad. La ilusión lleva a creer que vuelas más alto de lo real y que la senda es más empinada de lo normal. Esto genera el impulso de picar el morro para «corregirla», con riesgo de impacto antes del umbral. La medida correctiva es mantener la velocidad indicada por el anemómetro e ignorar la sensación hasta recuperar referencias visuales de textura en tierra.
- #strong[Ilusión autocinética:] Al fijar la mirada sobre una luz aislada en la oscuridad durante varios segundos, los micromovimientos involuntarios del ojo producen la falsa percepción de que la luz se desplaza. Esto puede confundir al piloto respecto a si se trata de otra aeronave en movimiento. El remedio es mantener el escaneo visual activo, evitando fijar la vista en un foco único durante más de unos pocos segundos.

#figure([
#box(image("02-factores-humanos/imagenes/02-cap02-ilusiones-opticas.png"))
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

Los sentidos humanos evolucionaron para el movimiento bidimensional sobre el terreno bajo una gravedad constante. Al volar sin referencias visuales fiables del horizonte, el cerebro es susceptible de generar ilusiones que producen #strong[#link(<glosario-desorientacion-espacial>)[desorientación espacial]#index("Desorientación espacial")]: una falsa apreciación de la posición u orientación real en el espacio.

- #strong[Ilusiones vestibulares:] Un viraje prolongado y estable en #link(<glosario-termica>)[térmica]#index("Térmica") puede engañar a los canales semicirculares, induciendo la percepción de que el planeador está nivelado o virando apenas (ilusión de estabilidad). En sentido contrario, la turbulencia severa puede impulsar al piloto a tirar bruscamente de la palanca cuando el avión se mantiene de hecho en actitud normal.
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
La #link(<glosario-cinetosis>)[cinetosis]#index("Cinetosis") (#strong[motion sickness]), o mareo en vuelo, es una reacción fisiológica que se produce cuando el cerebro recibe señales contradictorias de los distintos sentidos. En la cabina de un planeador, el malestar suele aparecer cuando lo que perciben los ojos no coincide con lo que el sistema vestibular del oído interno registra en cuanto a aceleraciones y giros.

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
#box(image("02-factores-humanos/imagenes/02-cap02-cinetosis-fijacion.jpg"))
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
Aunque el velero puro carece de motor, una parte significativa de la flota actual está compuesta por motoveleros (#strong[Touring Motor Gliders], #link(<glosario-tmg>)[TMG]#index("TMG")) o planeadores con motor retráctil. En estas aeronaves, al encender la calefacción de cabina ---que suele extraer calor directamente del tubo de escape--- existe riesgo de #strong[intoxicación por #link(<glosario-monoxido-de-carbono>)[monóxido de carbono]#index("Monóxido de carbono") (CO)]. Durante la fase de despegue en remolque, también pueden inhalarse gases de escape del avión remolcador.

El monóxido de carbono es inodoro, incoloro e insípido. Su afinidad por la hemoglobina es unas 200 veces superior a la del oxígeno: al inhalarlo, se une a la hemoglobina e impide el transporte de O₂ al cerebro, produciendo #strong[#link(<glosario-hipoxia>)[hipoxia]#index("Hipoxia") anémica] sin necesidad de estar a gran altitud. Como referencia habitual en la literatura aeromédica, fumar unos pocos cigarrillos antes del vuelo eleva la saturación de CO en hemoglobina hasta un nivel que degrada la visión nocturna de forma equivalente a volar ya a varios miles de pies, aun a cota baja. (Las cifras exactas varían según la fuente y el número de cigarrillos; el mensaje operativo ---fumar antes de volar recorta tu visión nocturna--- no cambia.)

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
El vuelo a vela implica, con frecuencia, alcanzar grandes altitudes. Recuerde que el gradiente térmico de la atmósfera estándar reduce la temperatura exterior a razón de unos 2 °C por cada 1.000 ft. A 4.000 m se pueden registrar --20 °C, y en las proximidades de la #link(<glosario-tropopausa>)[tropopausa]#index("Tropopausa"), valores de --50 °C o inferiores.

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
#box(image("02-factores-humanos/imagenes/02-cap02-curva-estres.png"))
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
Una de las manifestaciones físicas del estrés agudo ---no de una falta real de oxígeno--- es la #strong[#link(<glosario-hiperventilacion>)[hiperventilación]#index("Hiperventilación")]: una respiración excesivamente rápida y profunda desencadenada por la ansiedad.

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
La #link(<glosario-cupula>)[cúpula]#index("Cúpula") de plexiglás actúa como un invernadero durante los meses de verano. Al volar en térmica, con ropa de vuelo y el paracaídas a la espalda, la temperatura en cabina puede elevarse considerablemente.

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
#strong[AMC1 #link(<glosario-sao>)[SAO]#index("SAO")​.GEN.130(f)] (ED Decision 2019/001/#link(<glosario-zonas-p>)[R]#index("Zonas P")) concreta la regla «de la botella al mando» (#strong[bottle to throttle]) para las tripulaciones de planeador: nada de alcohol en las #strong[8 horas previas] al vuelo, y una alcoholemia al inicio del vuelo que no supere #strong[0,2 g/l] ---o el límite nacional, si es más estricto.

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
Circula la idea de que en España se exige «cero alcohol» para volar. No es así: #strong[España no ha fijado un límite nacional más estricto] ---así lo indica el propio material de #link(<glosario-aesa>)[AESA]#index("AESA") sobre las pruebas de alcoholemia en rampa, cuyo formulario recoge «Límite Nacional Reglamentario (no definido en España)»---, de modo que se aplica el umbral de 0,2 g/l de la norma #link(<glosario-easa>)[EASA]#index("EASA"). No lo confundas con el tráfico rodado. Dicho esto, ese 0,2 g/l es un límite legal, no un objetivo: la única práctica segura es subirte al planeador sin nada de alcohol en el cuerpo.

=== Automedicación, antihistamínicos y analgésicos
<automedicación-antihistamínicos-y-analgésicos>
Dejando a un lado las drogas ilegales, que invalidan automáticamente el certificado médico EASA, el mayor peligro oculto en la aviación general es la #strong[automedicación].

Medicamentos de venta libre ---como los #strong[antihistamínicos] para la alergia estacional o las pastillas contra el mareo--- resultan incompatibles con el vuelo. Estas sustancias enlentecen los reflejos y producen somnolencia que el piloto a menudo no percibe como tal.

#strong[La regla básica es sencilla: si el prospecto del medicamento desaconseja conducir vehículos o manejar maquinaria pesada, está totalmente prohibido volar bajo sus efectos].

=== Dopaje y autorización terapéutica (AUT)
<dopaje-y-autorización-terapéutica-aut>
El vuelo a vela de competición está regulado internacionalmente y se somete a controles estrictos regidos por la #strong[Agencia Mundial Antidopaje (#link(<glosario-wada>)[WADA]#index("WADA"))] al igual que cualquier otro deporte de alto rendimiento.

#block[
#callout(
body: 
[
Para volar en campeonatos bajo un tratamiento médico sin arriesgarte a una descalificación (hay controles al aterrizar), debes justificar la medicación tramitando previamente una #strong[Autorización de Uso Terapéutico (#link(<glosario-aut>)[AUT]#index("AUT") / TUE)]. Este documento oficial eximirá al competidor de sanciones en controles antidopaje deportivos.

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
#strong[Resumen del capítulo: fisiología aeronáutica]

- #strong[Aptitud IMSAFE:] Revise el estado con la lista #strong[Illness], #strong[Medication], #strong[Stress], #strong[Alcohol], #strong[Fatigue], #strong[Eating] antes del despegue. Ante dudas, cancele el vuelo (#strong[NO-GO]). Si concurren problemas médicos importantes, consulte a un médico examinador aéreo (AME).
- #strong[Disbarismos:] Los gases corporales se expanden al ascender. No vuele nunca con resfriados o congestión nasal; el dolor en los tímpanos y senos paranasales por el cambio de presión le incapacitará para pilotar.
- #strong[Ilusiones sensoriales:] El oído interno engañará cuando se pierdan las referencias visuales exteriores. Si existe desorientación sin un horizonte claro, ignore las sensaciones y confíe ciegamente en los instrumentos.
- #strong[Monóxido de carbono (CO):] Gas letal, inodoro, incoloro e insípido que solo puede detectarse con un detector específico. Es un peligro real en motoveleros (TMG) por los gases del motor y el sistema de calefacción de cabina. Ante el menor síntoma o aviso del detector, corte la calefacción, abra la ventilación y aterrice inmediatamente.
- #strong[Hipotermia:] La inactividad en la cabina y el frío en altitud robarán el calor rápidamente, minando los reflejos y lucidez. Vuele siempre con ropa de abrigo puesta por capas y evita el calzado apretado para no limitar la circulación.
- #strong[Estrés e hiperventilación:] El pánico puede hacer jadear al implicado sin control, alterando el nivel de dióxido de carbono en la sangre, provocando entumecimiento y ceguera. Para frenarlo, ralentice conscientemente la respiración prolongando la exhalación, hable en voz alta o cante para regularse.
- #strong[Deshidratación:] La cabina cerrada es un invernadero y se pierden líquidos rápidamente. Cuando siente sed, ya tiene un déficit que merma las capacidades cognitivas. Beba agua regularmente desde el despegue para anticiparse a los dolores de cabeza o a un mortal golpe de calor.
- #strong[Fatiga:] El cansancio bloquea el tiempo de reacción y nubla la toma de decisiones. El café o una bebida no previenen sus efectos ocultos sobre la atención. La fatiga solo se cura de una manera: durmiendo para dar pie al necesario descanso reparador.
- #strong[Normativa EASA, medicación y alcohol:] La regla no tiene excepciones: #strong[«de la botella al mando»], 8 horas sin alcohol y alcoholemia inferior a 0,2 g/l (AMC1 SAO.GEN.130(f)). No se automedique; hasta las inocentes pastillas de la alergia o del mareo adormecen de forma incapacitante para volar.

]
= Psicología aeronáutica básica
<psicología-aeronáutica-básica>
#quote(block: true)[
Volar bien es, sobre todo, decidir bien. Este capítulo trata el instrumento que de verdad pilota el planeador ---tu mente---: cómo procesa la información, cómo decide bajo presión y qué actitudes y trampas psicológicas conviene reconocer en uno mismo.

En este capítulo aprenderás:

- #strong[El procesamiento de la información]: percepción, atención y los tipos de memoria.
- #strong[La #link(<glosario-conciencia-situacional>)[conciencia situacional]#index("Conciencia situacional")]: qué es y qué la degrada.
- #strong[La toma de decisiones (#link(<glosario-adm>)[ADM]#index("ADM"))]: el modelo #link(<glosario-decide>)[DECIDE]#index("DECIDE") y la gestión de riesgos con #link(<glosario-pave>)[PAVE]#index("PAVE").
- #strong[Las cinco actitudes peligrosas] y sus antídotos.
- #strong[La carga de trabajo y el #link(<glosario-srm>)[SRM]#index("SRM")]: visión de túnel, sobrecarga y gestión de recursos del piloto solo.
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
#box(image("02-factores-humanos/imagenes/02-cap03-memoria-tipos.jpg"))
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

En la cabina del planeador, esto implica construir y mantener durante el vuelo una imagen mental precisa de lo que ocurre: la variación y tendencia del viento, la posición real frente al campo de aterrizaje, la ocupación del #link(<glosario-circuito-de-trafico>)[circuito de tráfico]#index("Circuito de tráfico"), las condiciones del resto de las aeronaves y las variables propias de altitud y energía.

#block[
#callout(
body: 
[
La pérdida de la conciencia situacional suele ser el eslabón inicial en la mayoría de las cadenas de accidentes en el vuelo a vela. Una sobrecarga cualitativa de la atención, el pánico derivado de un fenómeno no comprendido, la #link(<glosario-fatiga>)[fatiga]#index("Fatiga") o la incomodidad en un asiento mal ajustado erosionan drásticamente la capacidad de asimilar el cuadro informativo completo que define una situación de vuelo segura.

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

Durante un vuelo en #link(<glosario-termica>)[térmica]#index("Térmica") o en el trayecto #link(<glosario-final>)[final]#index("Tramo final") del aterrizaje, el piloto interactúa con el entorno evaluando escenarios y peligros, definiendo planes, gestionando el nivel de riesgo y obrando en consecuencia. Uno de los esquemas estructurales más aceptados en la aviación civil para entrenar y modelar la ADM de manera natural es el #strong[modelo DECIDE] (#ref(<fig-02-cap03-decide>, supplement: [Figura])):

- #strong[#link(<glosario-zonas-p>)[D]#index("Zonas P")]etectar errores que requieren solución o un cambio que solicita atención.
- #strong[E]studiar y recopilar activamente toda la información del evento suscitado.
- #strong[C]onsiderar la mejor opción o todas las vías posibles para resolver el potencial peligro.
- #strong[I]mplementar de manera metódica, rápida o pausada, la mejor opción.
- #strong[D]eterminar objetivamente cuáles serían los resultados del proceso o de la decisión tomada.
- #strong[E]valuar lo aprendido, valorando si el curso forjado corrige el #link(<glosario-desvio>)[desvío]#index("Desvío"), y comunicar las conclusiones.

#figure([
#box(image("02-factores-humanos/imagenes/02-cap03-decide.jpg"))
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
"¿De qué sirve? Todo está perdido". Ante la adversidad o la complejidad de una pérdida en ruta, el piloto cree que no tiene control sobre la situación y abandona el pilotaje para convertirse en un mero pasajero de la tragedia. A veces se entrelaza con una #link(<glosario-complacencia>)[complacencia]#index("Complacencia") ciega frente a problemas menores.

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
#box(image("02-factores-humanos/imagenes/02-cap03-vision-tunel.jpg"))
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

La capacidad de la mente humana para procesar simultáneamente esta incesante catarata de eventos es esencialmente finita; es como un vaso de agua que solo puede admitir cierto volumen. Durante un remolque turbulento, de espaldas al sol, tratando de ubicar a otro velero que notifica en #link(<glosario-base>)[base]#index("Tramo de base"), el vaso cognitivo puede desbordarse estrepitosamente. A esto se le conoce como #strong[sobrecarga cualitativa]. Cuando la complejidad de la tarea de vuelo #link(<glosario-escala>)[escala]#index("Escala") superando el rendimiento y el entrenamiento del piloto en ese lapso preciso, el margen de seguridad desaparece y el accidente latente ocupa su lugar.

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

A diferencia del vuelo con tripulación múltiple donde las tareas se delegan, el piloto de planeador gestiona integralmente el vuelo operando como único nodo de decisión. Tu trabajo exige emplear todos los elementos disponibles para no exceder tu capacidad de procesamiento. Los recursos del SRM incluyen tu propio equipo (instrumentación, #link(<glosario-compensador>)[compensador]#index("Compensador") de abordo), las comunicaciones de radio (consultas al #link(<glosario-atc>)[ATC]#index("ATC") o información meteorológica), y herramientas en tierra (un buen prevuelo o un instructor en radio).

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

#postit[
#strong[Resumen del capítulo: psicología aeronáutica]

- #strong[Conciencia situacional]: Es la capacidad precisa de percibir lo que ocurre, comprender su significado y proyectar su estado futuro. Perderla es el primer eslabón de la mayoría de las cadenas de accidentes.
- #strong[Toma de decisiones (ADM)]: Proceso mental sistemático (como el modelo DECIDE) utilizado por los pilotos para elegir consistentemente la mejor opción de acción en respuesta a un conjunto de circunstancias.
- #strong[Estrés]: Es la respuesta del cuerpo ante una demanda física o psicológica. Un nivel moderado mejora el rendimiento (alerta), pero el estrés excesivo o crónico bloquea la capacidad de tomar decisiones y fija la atención en detalles irrelevantes (visión de túnel).
- #strong[Carga de trabajo y Rendimiento]: Tu capacidad de procesamiento es limitada (como un vaso de agua). Si la complejidad del vuelo (mal tiempo, tráfico, avería) llena el vaso, te desbordas. Simplifica la tarea (aviate, navigate, communicate) para recuperar margen de seguridad.
- #strong[Procesamiento de Información]: Comprende la percepción (interpretación del medio ambiente), atención (foco) y las memorias sensorial, a corto plazo y a largo plazo. Un exceso de información externa sin asimilar puede generar sobrecarga cualitativa.
- #strong[Gestión de Riesgos (PAVE)]: Evaluar sistemáticamente factores críticos divididos en Piloto, Aeronave, Medio Ambiente (#strong[Environment]) y Operación o Presiones Externas.
- #strong[Actitudes Peligrosas]: Las cinco actitudes a evitar son la antiautoridad, la impulsividad, la invulnerabilidad, la arrogancia (exceso de confianza) y la resignación.
- #strong[Gestión de Recursos (SRM)]: La habilidad del piloto solitario para usar integralmente el equipo a bordo, la información, las comunicaciones y la ayuda externa para no exceder su capacidad límite.
- #strong[Complacencia e Indisciplina]: La complacencia surge por el exceso de rutina generando una falsa sensación de seguridad, mientras que la indisciplina contagia una mala cultura de seguridad en el aeródromo al ignorar las normas.

]
= Uso de oxígeno
<uso-de-oxígeno>
#quote(block: true)[
A medida que el planeador gana altitud, la presión atmosférica desciende y el oxígeno disponible para el organismo disminuye. Este capítulo explica los mecanismos que provocan la #link(<glosario-hipoxia>)[hipoxia]#index("Hipoxia") y la #link(<glosario-hiperventilacion>)[hiperventilación]#index("Hiperventilación"), describe sus síntomas y tratamientos, y detalla los requisitos reglamentarios y los equipos de oxígeno que el piloto debe conocer para operar con seguridad en altitud.
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
Los pulmones contienen millones de alvéolos recubiertos de capilares. Al inspirar, el oxígeno llega a esos alvéolos y, impulsado por la presión barométrica, cruza hacia la sangre. En la sangre, la #strong[hemoglobina] de los glóbulos rojos transporta el oxígeno hasta el cerebro, la retina y los músculos, y recoge el dióxido de carbono (#link(<glosario-monoxido-de-carbono>)[CO]#index("Monóxido de carbono")#sub[2]) de desecho, que se exhala en la siguiente respiración.

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
Los síntomas de la hipoxia varían entre individuos y dependen de factores como el nivel de #link(<glosario-fatiga>)[fatiga]#index("Fatiga"), el tabaquismo, la ingesta de alcohol o la aclimatación a la altitud. El piloto a menudo no percibe sus propios síntomas.

El síntoma más peligroso ---y el primero en aparecer según el programa AESA--- es la #strong[euforia]: el piloto se siente excepcionalmente bien y no detecta el peligro. A continuación aparecen irritabilidad, dificultad para hablar, pérdida de memoria a corto plazo, disminución de la capacidad de cálculo y somnolencia. En fases avanzadas se produce #strong[#link(<glosario-cianosis>)[cianosis]#index("Cianosis")]: coloración azulada en labios y uñas, y finalmente pérdida de conciencia (#ref(<fig-02-cap04-cianosis>, supplement: [Figura])).

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
#box(image("02-factores-humanos/imagenes/02-cap02-sintomas-hipoxia.jpg"))
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
El #link(<glosario-tuc>)[TUC]#index("TUC") es el intervalo que transcurre desde que se interrumpe el suministro de oxígeno hasta que el piloto pierde la capacidad de tomar medidas protectoras. A mayor altitud, menor tiempo disponible para reaccionar.

La siguiente tabla muestra los valores de referencia (#ref(<fig-02-cap04-hipoxia-tiempo-conciencia>, supplement: [Figura])):

#figure([
#box(image("02-factores-humanos/imagenes/02-cap04-hipoxia-tiempo-conciencia.png"))
], caption: figure.caption(
position: bottom, 
[
Tiempo de conciencia útil (#emph[Time of Useful Consciousness]) según la altitud
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
Disponga de un #emph[checklist] de emergencia para hipoxia, ya que el razonamiento puede estar deteriorado en el #link(<glosario-momento>)[momento]#index("Momento") en que más lo necesita. Si lleva #link(<glosario-pulsioximetro>)[pulsioxímetro]#index("Pulsioxímetro") a bordo, compruebe la saturación (SpO#sub[2]) ante cualquier duda.

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
#strong[#link(<glosario-sao>)[SAO]#index("SAO")​.OP.150:] «El #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando") deberá garantizar que todas las personas a bordo utilicen oxígeno suplementario cuando determine que, a la altitud de vuelo prevista, la falta de oxígeno podría ocasionar la disminución de sus facultades o resultarles dañina.»

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
- #strong[Sistema a demanda pulsada (#emph[Electronic Demand System], #link(<glosario-eds>)[EDS]#index("EDS")):] Detecta el inicio de cada inspiración mediante sensores barométricos y libera únicamente el volumen necesario, interrumpiendo el flujo durante la exhalación. Puede multiplicar por tres o cuatro la autonomía de la botella respecto al flujo continuo. El principal inconveniente es su dependencia de pilas de 9 V, que pueden fallar a temperaturas muy bajas; se recomienda conectarlo a la batería principal del planeador y usar la pila como respaldo.

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
#box(image("02-factores-humanos/imagenes/02-cap04-pulsioximetro.jpg"))
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
#postit[
#strong[Resumen del capítulo: uso de oxígeno]

- #strong[Leyes de los gases:] La presión atmosférica disminuye con la altitud (ley de Dalton), reduciendo la capacidad del oxígeno para transferirse a la sangre. Los gases corporales se expanden al ascender (ley de Boyle); no vuele con congestión nasal intensa para evitar #link(<glosario-disbarismos>)[barotraumas]#index("Disbarismos") dolorosos.
- #strong[Sistema respiratorio e hipoxia:] La hemoglobina transporta el oxígeno desde los alvéolos al cerebro. Cuando la presión es insuficiente, los glóbulos rojos llegan vacíos al cerebro y se produce hipoxia.
- #strong[Clases de hipoxia:] Existen cuatro tipos: #strong[hipóxica] (baja presión atmosférica, la más frecuente en planeador), #strong[hipémica] (monóxido de carbono o tabaquismo), #strong[estancada] (fuerzas G elevadas en virajes cerrados) e #strong[histotóxica] (alcohol, drogas o medicamentos).
- #strong[Síntomas y diagnóstico:] El primer síntoma es la euforia; el piloto no percibe el peligro por sí mismo. Posteriormente aparecen somnolencia, dificultad para calcular, cianosis y pérdida de conciencia. El pulsioxímetro detecta la hipoxia antes de que los síntomas sean evidentes.
- #strong[Tiempo útil de conciencia (TUC):] A 25.000 ft, el TUC es de 3 a 5 minutos; a 30.000 ft, de 1 a 2 minutos. Un descenso largo puede superar el TUC disponible: actúe siempre antes de necesitarlo.
- #strong[Normativa (SAO.OP.150 y su #link(<glosario-amc>)[AMC]#index("AMC")):] El oxígeno suplementario es obligatorio cuando el piloto determine que su falta puede disminuir las facultades de los ocupantes; cuando no pueda determinarlo, la regla por defecto del AMC es usarlo siempre por encima de #strong[10.000 ft]. En vuelo nocturno o al atardecer se #strong[recomienda] (no es norma) desde los #strong[5.000 ft].
- #strong[Sistemas de oxígeno:] El flujo continuo es sencillo pero consume más oxígeno y reseca las mucosas. El sistema a demanda pulsada (EDS) multiplica la autonomía de la botella, pero depende de pilas que pueden fallar con el frío. Use siempre oxígeno de aviación seco; no medicinal.
- #strong[Seguridad del equipo:] No use grasas ni cremas cerca de conexiones de oxígeno: riesgo de combustión explosiva. Verifique la presión de la botella antes de cada vuelo (entre 150 y 200 bar).
- #strong[Hiperventilación:] Causada por estrés o ansiedad, no por falta de oxígeno. Al exhalar CO#sub[2] en exceso, los vasos cerebrales se contraen, produciendo síntomas similares a la hipoxia (hormigueo, calambres, mareo). Tratamiento: reducir el ritmo respiratorio, hablar en voz alta o reinhalar CO#sub[2] cubriendo parcialmente la boca.
- #strong[Pulsioxímetro:] Mantenga la saturación (SpO#sub[2]) por encima del #strong[90%]\; por debajo de ese umbral, active el oxígeno y descienda de inmediato.

]
#part[Parte 03: Meteorología]
= La atmósfera
<la-atmósfera>
#quote(block: true)[
Sin entender la atmósfera, ningún mapa de previsión tiene sentido. En este capítulo aprenderás qué es la #link(<glosario-atmosfera-estandar-internacional>)[Atmósfera Estándar Internacional]#index("Atmósfera Estándar Internacional") (ISA), por qué la presión, la temperatura y la densidad del aire cambian con la altitud, y cómo esos cambios afectan directamente al rendimiento de tu planeador y a tu propia fisiología en vuelo.
]

== La atmósfera estándar internacional (ISA)
<la-atmósfera-estándar-internacional-isa>
Para estandarizar el diseño de aeronaves y la calibración de instrumentos en todo el mundo, la Organización de Aviación Civil Internacional (#link(<glosario-oaci>)[OACI]#index("OACI")) definió la Atmósfera Estándar Internacional (ISA, por sus siglas en inglés: #strong[International Standard Atmosphere]). Es un modelo atmosférico ideal que asume #strong[aire seco] (0 % de humedad) y establece valores medios teóricos, ya que raramente encontrarás un día ISA "puro" en la realidad.

A nivel del mar (MSL), la atmósfera ISA establece las siguientes condiciones de referencia (#ref(<fig-03-cap01-atmosfera-isa>, supplement: [Figura])):

- Temperatura: 15 °C
- Presión atmosférica: 1013,25 hPa (equivalente a 29,92 inHg o 760 mm Hg)
- Densidad del aire: 1,225 kg/m#super[3]

El modelo ISA asume 0 % de humedad, lo que en la práctica significa que tampoco define un #strong[punto de rocío] (#strong[dew point]). En la realidad, el punto de rocío es la temperatura a la que hay que enfriar una #link(<glosario-masa-de-aire>)[masa de aire]#index("Masa de aire") para que el vapor de agua que contiene comience a condensarse. Cuando la temperatura del aire y el punto de rocío se aproximan o igualan, la humedad relativa alcanza el 100 % y el aire se satura: se forman nubes o #link(<glosario-niebla>)[niebla]#index("Niebla"). Para el piloto de planeador, la diferencia entre temperatura y punto de rocío es el dato clave para estimar la #link(<glosario-base>)[base]#index("Tramo de base") de los cúmulos y la probabilidad de niebla matinal (ver Capítulo 3: Termodinámica).

#figure([
#box(image("03-meteorologia/imagenes/03-cap01-atmosfera-isa.jpg"))
], caption: figure.caption(
position: bottom, 
[
Temperaturas de la atmósfera estándar ISA
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap01-atmosfera-isa>


== Gradientes estándar en aviación
<gradientes-estándar-en-aviación>
A medida que ganamos altura, las condiciones atmosféricas cambian según unos patrones establecidos en el modelo ISA, conocidos como gradientes estándar. Estas reglas te permiten hacer cálculos mentales rápidos durante el vuelo.

- #strong[Gradiente térmico estándar]: La temperatura en la #link(<glosario-troposfera>)[troposfera]#index("Troposfera") disminuye a razón de 2 °C por cada 1.000 pies de ascenso (o 6,5 °C por cada 1.000 metros).
- #strong[Gradiente de presión estándar]: La presión atmosférica disminuye aproximadamente 1 hPa por cada 30 pies de ascenso en las capas bajas de la atmósfera.

#block[
#callout(
body: 
[
Memoriza estas tres equivalencias del gradiente estándar ISA: #strong[2 °C / 1.000 pies] para la temperatura, y #strong[1 hPa / 30 pies] para la presión. En sistema métrico, si subes 90 metros, la presión cae 10 hPa; en pies, si subes 3.000 pies, cae 100 hPa. Si despegas de un aeródromo a 2.000 pies con #link(<glosario-qnh>)[QNH]#index("QNH") 1013 hPa y 20 °C, puedes estimar que a 5.000 pies la temperatura será unos 6 °C más fría (14 °C) y la presión habrá bajado unos 100 hPa.

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
La falta prolongada de oxígeno en los tejidos se conoce como #strong[#link(<glosario-hipoxia>)[hipoxia]#index("Hipoxia")]. Dado su impacto crítico en la seguridad del vuelo (pérdida del conocimiento, degradación visual), los síntomas detallados, el cálculo del Tiempo de Conciencia Útil (#link(<glosario-tuc>)[TUC]#index("TUC")) y el uso de equipos de oxígeno se estudian en profundidad en el #strong[Libro 2 --- Factores humanos], capítulo 4.

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
#strong[Resumen del capítulo: la atmósfera]

- #strong[Atmósfera ISA]: Modelo ideal para estandarizar instrumentos y rendimiento (15°C, 1013,25 hPa, 0% humedad a MSL). Raramente encontrarás un día ISA "puro", pero es la referencia universal.
- #strong[Gradientes Estándar]: La temperatura cae 2°C por cada 1.000 ft. La presión cae 1 hPa por cada 30 ft #strong[o por cada 9 metros]. Ambas equivalencias son útiles: la primera en entornos anglosajones (altímetros en pies), la segunda cuando trabajas con altitudes en metros.
- #strong[Densidad y Rendimiento]: El planeador vuela gracias a las moléculas de aire. Menor densidad (alta elevación o día caluroso) significa menos sustentación y peor rendimiento: necesitas más pista para despegar y corres más con el mismo ángulo de ataque.
- #strong[Presión parcial de O#sub[2]]: Aunque la proporción de oxígeno se mantiene (21 %), la presión a la que entra en tus pulmones cae drásticamente con la altura, provocando hipoxia (cuyos efectos fisiológicos se detallan en el #strong[Libro 2 --- Factores humanos], capítulo 4).

]
= Viento
<viento>
#quote(block: true)[
El viento es la materia prima del vuelo a vela: a veces tu aliado, siempre un factor de seguridad que debes conocer y respetar. En este capítulo aprenderás por qué sopla el viento, cómo la rotación terrestre y el terreno lo transforman, y cuáles son los vientos locales ---anabáticos, catabáticos, Foehn, brisa marina--- que definen la meteorología de cada aeródromo.
]

== El motor del viento: la fuerza de gradiente
<el-motor-del-viento-la-fuerza-de-gradiente>
El viento es fundamentalmente aire en movimiento, y su motor principal son las diferencias de presión atmosférica en distintas zonas.

El aire fluye de forma natural desde las zonas de alta presión (anticiclones) hacia las zonas de baja presión (depresiones o borrascas). Esta tendencia a igualar las presiones genera lo que conocemos como #strong[Fuerza del Gradiente de Presión] (Fg). La regla es sencilla: cuanto mayor es la diferencia de presión en una distancia corta, mayor es la fuerza del gradiente. En los mapas meteorológicos, esto se visualiza con las isobaras (líneas que unen puntos de igual presión): cuanto más juntas estén las isobaras, más fuerte soplará el viento (#ref(<fig-03-cap02-gradiente-isobaras>, supplement: [Figura])).

#figure([
#box(image("03-meteorologia/imagenes/03-cap02-gradiente-isobaras.jpg"))
], caption: figure.caption(
position: bottom, 
[
La fuerza del gradiente de presión y las isobaras
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap02-gradiente-isobaras>


== La fuerza de Coriolis y el viento geostrófico
<la-fuerza-de-coriolis-y-el-viento-geostrófico>
Si la Tierra no rotase, el viento fluiría directamente de las altas a las bajas presiones cruzando las isobaras perpendicularmente. Sin embargo, debido a la rotación terrestre, aparece una fuerza aparente llamada #strong[Fuerza de Coriolis] (Fc).

En el hemisferio norte, la fuerza de Coriolis desvía cualquier #link(<glosario-masa-de-aire>)[masa de aire]#index("Masa de aire") en movimiento hacia la #strong[derecha]. A medida que el viento acelera impulsado por el gradiente de presión, Coriolis tira de él hacia la derecha. Por encima de unos 1.000 metros sobre el terreno (nivel de fricción), ambas fuerzas (gradiente y Coriolis) se equilibran. El resultado es que el viento deja de cruzar las isobaras y acaba soplando #strong[paralelo] a ellas. A este viento libre en altura se le denomina #strong[#link(<glosario-viento-geostrofico>)[viento geostrófico]#index("Viento geostrófico")].

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
== El efecto de la fricción en superficie
<el-efecto-de-la-fricción-en-superficie>
Cerca del suelo (por debajo de esos 1.000 metros), entra en juego un tercer actor: el rozamiento con el terreno o fricción superficial. Los árboles, edificios, montañas y la propia textura del suelo "frenan" el flujo del aire.

Al reducirse la velocidad del viento por esta fricción, el efecto de Coriolis (que depende de la velocidad) también disminuye. Sin embargo, la fuerza del gradiente de presión se mantiene intacta. Como Coriolis ya no puede contrarrestar del todo al gradiente, el viento en superficie se desvía y #strong[cruza las isobaras hacia la baja presión] (típicamente con un ángulo de unos 30 grados respecto a las isobaras).

#block[
#callout(
body: 
[
Debido a la fricción, cuando te acercas al suelo para aterrizar experimentarás el "gradiente de viento" (#emph[#link(<glosario-cizalladura>)[wind shear]#index("Cizalladura")] en #link(<glosario-capa-limite>)[capa límite]#index("Capa límite")). En los últimos metros, el viento no solo será más flojo que en el circuito, sino que su dirección cruzará más hacia la baja presión. Debes mantener tu velocidad de aproximación con un margen de seguridad adecuado para evitar la pérdida de sustentación en la recogida (#strong[flare]).

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
#box(image("03-meteorologia/imagenes/03-cap02-calles-nubes.jpg"))
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
#box(image("03-meteorologia/imagenes/03-cap02-convergencia-topografica.jpg"))
], caption: figure.caption(
position: bottom, 
[
Convergencia inducida por flujo alrededor de topografía (vista desde arriba)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap02-convergencia-topografica>


== Brisas locales: el motor en la montaña
<brisas-locales-el-motor-en-la-montaña>
El calentamiento desigual del terreno por el sol genera vientos locales fundamentales para el piloto de planeador, especialmente en áreas montañosas:

- #strong[Vientos Anabáticos (Brisas de Valle)]: De día, el sol calienta antes las laderas y crestas de las montañas que el fondo del valle. El aire en contacto con las cimas se calienta, se hace menos denso y sube, "succionando" aire más fresco del fondo del valle hacia arriba a lo largo de las vertientes. Estas brisas anabáticas son excelentes disparadores de corrientes térmicas (#strong[lift]). Busca siempre las laderas orientadas al sol (solanas) (#ref(<fig-03-cap02-vuelo-ladera>, supplement: [Figura])).
- #strong[Vientos Catabáticos (Brisas de Montaña)]: Al atardecer y durante la noche ocurre lo inverso. Las cimas se enfrían rápidamente emitiendo radiación al espacio. El aire frío y denso "resbala" ladera abajo acumulándose en el fondo del valle (#ref(<fig-03-cap02-ciclo-anabatico-catabatico>, supplement: [Figura])).

#figure([
#box(image("03-meteorologia/imagenes/03-cap02-ciclo-anabatico-catabatico.jpg"))
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
#box(image("03-meteorologia/imagenes/03-cap02-vuelo-ladera.jpg"))
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
== Efecto Foehn y Stau: cuando la montaña calienta el aire
<efecto-foehn-y-stau-cuando-la-montaña-calienta-el-aire>
Cuando el viento húmedo del Atlántico choca con una cordillera, ocurre algo que parece casi magia: el mismo aire que llega frío y cargado de nubes por barlovento puede aterrizar en el valle de sotavento seco, transparente y diez grados más caliente. Esto es el #strong[#link(<glosario-efecto-foehn>)[efecto Foehn]#index("Efecto Foehn")] (#strong[Foehn effect]), y su gemelo el #strong[#link(<glosario-stau>)[Stau]#index("Stau")] (#strong[Stau effect]), y tienen consecuencias directas para el piloto.

El mecanismo es asimétrico: en la ladera de #strong[barlovento] (la que recibe el viento), el aire asciende enfriándose primero al ritmo #link(<glosario-dalr>)[DALR]#index("DALR") (3 °C/1.000 ft) hasta que alcanza el punto de rocío, condensa y precipita. A partir de ese nivel, sube ya saturado a solo 1,5 °C/1.000 ft (#link(<glosario-salr>)[SALR]#index("SALR")), cediendo calor latente a la atmósfera. En sotavento, el aire ya ha perdido su humedad al barlovento y desciende #strong[seco] durante todo el recorrido, calentándose al DALR completo (3 °C/1.000 ft). El resultado: llega al valle de sotavento más caliente que cuando partió (#ref(<fig-03-cap02-fohn-stau>, supplement: [Figura])). Con desniveles de 1.500--2.000 m, la diferencia puede superar los 10--15 °C entre los dos valles.

La #strong[pared de Foehn] (#strong[Foehn wall]) es la acumulación de nubes que permanece estacionaria sobre la cresta del lado de barlovento, marcando visualmente la zona de precipitación. En sotavento: ventana despejada, temperatura alta y humedad baja. El #strong[Stau] es el nombre del mismo proceso visto desde el barlovento: acumulación de nubes y precipitación intensa mientras el otro valle disfruta del sol.

#figure([
#box(image("03-meteorologia/imagenes/03-cap02-fohn-stau.jpg"))
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
== Brisas marinas y líneas de convergencia: el frente que no aparece en el mapa
<brisas-marinas-y-líneas-de-convergencia-el-frente-que-no-aparece-en-el-mapa>
Las #strong[brisas marinas] (#strong[#link(<glosario-brisa-marina>)[sea breeze]#index("Brisa marina")]) son el resultado del mismo principio que las brisas de montaña: calentamiento desigual. La tierra se calienta mucho más rápido que el mar durante el día. El aire cálido sobre el continente asciende, y el aire fresco marino avanza tierra adentro para rellenar ese hueco, formando un flujo que puede penetrar decenas de kilómetros al interior (#ref(<fig-03-cap02-brisa-marina>, supplement: [Figura])).

Lo más valioso para el volovelista no es el viento en sí, sino la #strong[#link(<glosario-linea-de-convergencia>)[línea de convergencia]#index("Línea de convergencia")] que genera (#ref(<fig-03-cap02-convergencia-topografica>, supplement: [Figura])). Cuando ese aire frío y húmedo marino topa con la masa cálida y seca continental, se crea un límite nítido ---un minifrente--- donde el aire se ve forzado a ascender. Esa línea avanza lentamente tierra adentro durante la tarde y puede ofrecer ascendencias suaves y continuas durante kilómetros, perfectas para el vuelo de distancia.

#figure([
#box(image("03-meteorologia/imagenes/03-cap02-brisa-marina.jpg"))
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

- Los cúmulos del lado marino tienen la #strong[#link(<glosario-base>)[base]#index("Tramo de base") más baja] (aire húmedo, punto de rocío alto) que los del interior (aire seco, bases altas).
- La convergencia a veces genera una franja alargada de cúmulos algo más activos, o incluso una cortina de nubes (#strong[curtain cloud]) a lo largo del límite (#ref(<fig-03-cap02-calles-nubes>, supplement: [Figura])).
- A ras de suelo puede notarse como un cambio repentino de viento y frescor al cruzarla.

#block[
#callout(
body: 
[
En verano, los pilotos que operan desde Fuentemilanos (Segovia) trabajan frecuentemente la convergencia de brisa del SW que penetra desde el Atlántico a través del Sistema Central. La Baja #link(<glosario-termica>)[Térmica]#index("Térmica") Peninsular (ver capítulo de Climatología) actúa como un gran aspirador que succiona la brisa marina tierra adentro, creando líneas de convergencia NW--SE que funcionan como autopistas de ascendencias para el cross-country. Revisa modelos RASP o Skysight ---o su equivalente en Topmeteo o Meteo Parapente--- la tarde anterior para anticipar su posición.

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
#strong[Resumen del capítulo: viento]

- #strong[El motor del viento]: El aire fluye naturalmente de las Altas (H) a las Bajas (L) presiones debido a la fuerza de gradiente. Cuanto más juntas estén las isobaras, más fuerte soplará.
- #strong[Fuerza de Coriolis]: En el hemisferio norte, la rotación terrestre desvía el viento hacia la derecha. Por eso, en altura, el viento acaba soplando paralelo a las isobaras (viento geostrófico).
- #strong[Efecto de la Fricción]: Cerca del suelo, el rozamiento frena el viento y debilita el efecto Coriolis, haciendo que el viento cruce las isobaras hacia la baja presión. Al aterrizar, espera que el viento cambie de dirección e intensidad en los últimos metros.
- #strong[Brisas Locales]: El sol calienta las laderas antes que el valle, generando brisas ascendentes (anabáticas) de día. De noche, el aire frío baja (catabático). Conocer este ciclo es vital para encontrar ascendencias o evitar descendencias peligrosas en montaña.
- #strong[Efecto Foehn y Stau]: El aire que sube en barlovento precipita y cede calor latente (SALR). Al descender en sotavento ---ya seco--- se calienta al DALR completo, llegando hasta 15 °C más caliente. La "pared de Foehn" marca visualmente la cresta. Cuidado con los rotores en el sotavento.
- #strong[Brisas Marinas y Convergencias]: La brisa marina penetra tierra adentro creando una línea de convergencia (minifrente) con ascendencias excelentes para el cross-country. Identifícala por las diferentes alturas de base de los cúmulos a cada lado y por la franja de nubosidad activa sobre el límite.

]
= Termodinámica
<termodinámica>
#quote(block: true)[
La termodinámica es el motor invisible del vuelo sin motor: sin estabilidad inestable no hay térmicas, y sin térmicas no hay vuelo de distancia. En este capítulo aprenderás a interpretar la #link(<glosario-estabilidad-atmosferica>)[estabilidad atmosférica]#index("Estabilidad atmosférica"), a calcular la #link(<glosario-base>)[base]#index("Tramo de base") de los cúmulos con una operación mental sencilla, a reconocer una #link(<glosario-inversion-termica>)[inversión térmica]#index("Inversión térmica") y a leer los índices de sondeo que predicen si el día será excelente o decepcionante para volar.
]

== Estabilidad atmosférica: el combustible del vuelo a vela
<estabilidad-atmosférica-el-combustible-del-vuelo-a-vela>
La estabilidad de la atmósfera define cómo se comporta una #link(<glosario-masa-de-aire>)[masa de aire]#index("Masa de aire") (una "burbuja" o parcela) cuando es empujada hacia arriba. El vuelo sin motor vive fundamentalmente de la inestabilidad (#ref(<fig-03-cap03-estabilidad>, supplement: [Figura])).

Podemos entenderlo imaginando una pelota en diferentes relieves:

- #strong[Atmósfera Estable]: Si empujas la pelota desde el fondo de un valle subiéndola por la ladera, volverá a caer al centro. En el aire, si el ambiente se enfría lentamente con la altura (gradiente térmico ambiental menor de 1 °C/100m), una burbuja que ascienda se enfriará más rápido que su entorno. Pronto estará más fría (y pesada) que el aire que la rodea, deteniendo su ascenso y hundiéndose de nuevo.
- #strong[Atmósfera Inestable]: Imagina la pelota en equilibrio precario en la cima de un monte; un pequeño empujón hará que caiga rodando sin parar. Si el aire ambiental se enfría muy rápido con la altura (mayor de 1 °C/100m), una burbuja que empiece a subir siempre se mantendrá más caliente (y ligera) que el aire a su alrededor, acelerando su ascenso. Esta es la condición ideal para la formación de fuertes térmicas.
- #strong[#link(<glosario-estabilidad-condicional>)[Estabilidad Condicional]#index("Estabilidad condicional")]: Depende de la humedad. Si el aire está seco, es estable; pero si está saturado de humedad, el calor liberado por la condensación (al formar nubes) hace que la burbuja se mantenga caliente y siga subiendo (inestable).

#figure([
#box(image("03-meteorologia/imagenes/03-cap03-estabilidad.jpg"))
], caption: figure.caption(
position: bottom, 
[
Aire inestable (A) y estable (B) para unos 3000 pies (unos 1000m).
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap03-estabilidad>


== Gradientes adiabáticos y la base de las nubes
<gradientes-adiabáticos-y-la-base-de-las-nubes>
Cuando una burbuja de aire asciende impulsada por la convección, se expande a medida que encuentra menor presión atmosférica en altura. Esta expansión provoca que se enfríe de forma interna (proceso adiabático), sin intercambiar calor con el aire exterior. El ritmo al que se enfría depende de si el aire está seco o saturado de humedad.

- #strong[Gradiente Adiabático Seco (#link(<glosario-dalr>)[DALR]#index("DALR") - #emph[Dry Adiabatic Lapse Rate])]: Mientras la burbuja no alcance el 100% de humedad, se enfría a un ritmo constante de #strong[3 °C por cada 1.000 pies] (1 °C cada 100 metros).
- #strong[Gradiente Adiabático Saturado (#link(<glosario-salr>)[SALR]#index("SALR") - #emph[Saturated Adiabatic Lapse Rate])]: Cuando la burbuja se enfría lo suficiente como para alcanzar su punto de rocío, el vapor de agua comienza a condensarse, formando la base de una nube (Nivel de Condensación por Ascenso o #link(<glosario-nca>)[NCA]#index("NCA")). La condensación libera calor latente dentro de la burbuja. Por tanto, a partir de la base de la nube, la burbuja sigue subiendo, pero se enfría mucho más despacio, típicamente a #strong[1,5 °C por cada 1.000 pies] (0,5 °C cada 100 metros en niveles bajos).

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

+ Anota la temperatura ambiente en tierra (T) y la temperatura del punto de rocío (T#sub[rocío]) del #link(<glosario-metar>)[METAR]#index("METAR") o la estación del aeródromo.
+ Calcula la diferencia: ΔT = T − T#sub[rocío].
+ Multiplica: ΔT × 400 = altura estimada de la base de los cúmulos en pies.

#emph[Ejemplo: T = 26 °C, T#sub[rocío] = 16 °C → (26 − 16) × 400 = #strong[4.000 ft] de base.] (véase #ref(<fig-03-cap03-base-cumulos-dalr-nca>, supplement: [Figura]))

#figure([
#box(image("03-meteorologia/imagenes/03-cap03-base-cumulos-dalr-nca.jpg"))
], caption: figure.caption(
position: bottom, 
[
Cálculo gráfico de la base de los cúmulos: gradiente DALR, punto de rocío y Nivel de Condensación por Ascenso (NCA)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap03-base-cumulos-dalr-nca>


== Inversiones térmicas: la tapadera invisible
<inversiones-térmicas-la-tapadera-invisible>
Normalmente la temperatura disminuye con la altitud, pero en ocasiones ocurre lo contrario: encontramos capas donde #strong[la temperatura del aire aumenta a medida que subimos]. A esto se le llama una inversión #link(<glosario-termica>)[térmica]#index("Térmica").

Una inversión térmica actúa como una tapadera o techo de cristal. Debido a que el aire por encima de la inversión está sorprendentemente caliente, cuando una térmica sube y choca contra esa capa, de repente se encuentra rodeada de aire más caliente (y por tanto más ligero) que ella misma. La térmica pierde su flotabilidad (#strong[buoyancy]) instantáneamente, deteniendo en seco el ascenso.

#block[
#callout(
body: 
[
Las inversiones no solo limitan la altura máxima a la que puedes trepar en un planeador, frenando la convección por completo, sino que también atrapan humo, bruma y humedad industrial cerca de la superficie, reduciendo drásticamente la #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") en vuelo por debajo de la capa de inversión.

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
== Convección: el transporte vertical de calor
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

- #strong[#link(<glosario-modelo-burbuja>)[Modelo burbuja]#index("Modelo burbuja")] (#strong[bubble model]): El calor se acumula sobre la fuente hasta que la burbuja se desprende, como si tirases de un globo. El ascenso es intermitente: el núcleo central sube más rápido que los bordes, que presentan subsidencia. El planeador debe buscar y mantenerse en el núcleo para aprovechar el ascenso máximo (#ref(<fig-03-cap03-modelo-burbuja>, supplement: [Figura])).

#figure([
#box(image("03-meteorologia/imagenes/03-cap03-modelo-burbuja.jpg"))
], caption: figure.caption(
position: bottom, 
[
El modelo de burbuja o anillo de vórtice de una térmica.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap03-modelo-burbuja>


- #strong[#link(<glosario-modelo-columna>)[Modelo columna]#index("Modelo columna") o pluma] (#strong[column/plume model]): En fuentes intensas y persistentes (una cantera, un pueblo grande, una ladera orientada al sol toda la mañana), el flujo convectivo es continuo, como el humo de una chimenea. El ascenso es más regular y predecible, ideal para el vuelo de distancia (#ref(<fig-03-cap03-modelo-columna>, supplement: [Figura])).

#figure([
#box(image("03-meteorologia/imagenes/03-cap03-modelo-columna.jpg"))
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
#box(image("03-meteorologia/imagenes/03-cap03-ciclo-vida-termica.png"))
], caption: figure.caption(
position: bottom, 
[
Ciclo de vida de una térmica típica con #link(<glosario-cumulo>)[cúmulo]#index("Cúmulo").
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap03-ciclo-vida-termica>


#mas-alla[
== Índices de estabilidad: el termómetro del día
<índices-de-estabilidad-el-termómetro-del-día>
#mas-alla-tag[#strong[↗ MÁS ALLÁ DEL EXAMEN.]] Los índices de sondeo (TT, K, #link(<glosario-cape>)[CAPE]#index("CAPE"), #link(<glosario-li>)[LI]#index("Lifted Index")) y los #link(<glosario-sondeo-termodinamico>)[Skew-T]#index("Sondeo termodinámico") no deberían ser materia de examen: son formación de vuelo de distancia. Estúdialos cuando domines el resto del temario; aquí están porque forman al piloto, no solo al aprobado.

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
El gráfico TT + K que el instructor cuelga cada mañana en el hangar te da la fotografía rápida del día. El TT te dice cuánto "combustible" tiene la atmósfera para armar un #link(<glosario-cumulonimbus>)[Cb]#index("Cumulonimbus") en el llano; el K te lo dice para la montaña. No confíes en uno solo: úsalos juntos antes de cada preflight.

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
El TT presenta limitaciones: sobrestima la inestabilidad si la temperatura a 500 hPa es muy baja sin soporte convectivo en capas bajas, y no detecta bien la estabilidad fuerte o la humedad elevada por debajo de 850 hPa. En esas situaciones, refuerza el análisis con el #link(<glosario-k-index>)[K-Index]#index("índice K") y el CAPE.

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
- #strong[LI (Índice de Levantamiento o #emph[Lifted Index])]: Diferencia entre la temperatura de la parcela y la del ambiente a 500 hPa, tras elevarla adiabáticamente desde el suelo. Valores negativos indican inestabilidad: cuanto más negativo, mayor el potencial convectivo.

#block[
#callout(
body: 
[
Día de convección excepcional --- conocido coloquialmente como «día termonuclear» en el argot de competición ---: TT entre 48 y 55, K entre 15 y 20, CAPE entre 1.000 y 2.500 J/kg, LI negativo y vientos flojos de componente variable. Son los días de récords de distancia. Puedes encontrar todos estos índices en cualquier sondeo online: gratuitamente en la Universidad de Wyoming, AEMET (#link(<glosario-ama>)[AMA]#index("AMA")), Windy o Meteoblue; con previsiones orientadas al planeador en Skysight, Topmeteo o Meteo Parapente.

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
]
#postit[
#strong[Resumen del capítulo: termodinámica]

- #strong[Estabilidad Atmosférica]: Concepto clave. El aire es "estable" si una burbuja empujada hacia arriba tiende a volver a bajar, e "inestable" si sigue subiendo sola. El vuelo a vela vive de la inestabilidad.
- #strong[Gradientes Adiabáticos]: El aire seco se enfría 3°C por cada 1.000 ft al subir (DALR). El aire saturado (nube) se enfría solo la mitad, 1,5°C (SALR). Memoriza esto para predecir la base de las nubes y su desarrollo.
- #strong[Inversiones]: Son capas donde la temperatura #strong[sube] con la altura en lugar de bajar. Actúan como una tapadera invisible que frena las térmicas y atrapa la contaminación/bruma.
- #strong[Convección]: El sol calienta el suelo, el suelo calienta el aire, y este sube como una burbuja (modelo burbuja) o como una pluma continua (modelo columna). Cuanto más frío esté el aire arriba en comparación con el suelo, más fuerte será la térmica.

]
= Nubes y niebla
<nubes-y-niebla>
#quote(block: true)[
Las nubes son el lenguaje visual de la atmósfera: si sabes leerlas, te dicen dónde están las ascendencias, dónde está el peligro y cómo va a evolucionar el tiempo. En este capítulo aprenderás a identificar los tipos de nubes relevantes para el vuelo a vela, qué peligros asocia cada familia y cómo interpretar la #link(<glosario-niebla>)[niebla]#index("Niebla") y la neblina para decidir si despegar o no.
]

== Interpretación de la nubosidad
<interpretación-de-la-nubosidad>
Para la tripulación de un planeador, las nubes son el mapa visual de la atmósfera. La tabla siguiente resume las cuatro familias principales y su relevancia operativa para el vuelo a vela (#ref(<fig-03-cap04-familias-nubes-perfil>, supplement: [Figura])):

#figure([
#box(image("03-meteorologia/imagenes/03-cap04-familias-nubes-perfil.png"))
], caption: figure.caption(
position: bottom, 
[
Perfil vertical de las cuatro familias de nubes con altitudes de #link(<glosario-base>)[base]#index("Tramo de base") aproximadas
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

Cúmulos (#link(<glosario-cumulo>)[Cu]#index("Cúmulo")), Cumulonimbos (#link(<glosario-cumulonimbus>)[Cb]#index("Cumulonimbus"))

Para el vuelo a vela no todos pesan igual: los cúmulos marcan las térmicas, el cumulonimbo es el peligro máximo, los cirros anuncian la llegada de un frente y los nimboestratos traen precipitación persistente. Aun así conviene reconocer los diez, porque el examen los pregunta y porque cada uno cuenta algo del estado de la atmósfera.

== Peligros asociados al desarrollo vertical
<peligros-asociados-al-desarrollo-vertical>
En condiciones de alta inestabilidad atmosférica y humedad, un cúmulo puede continuar su desarrollo y evolucionar a #emph[#link(<glosario-cumulo-congestus>)[Cúmulo Congestus]#index("Cúmulo congestus")] y, finalmente, transformarse en un #strong[Cumulonimbus (Cb)].

El Cumulonimbus abarca una notable extensión vertical, culminando a menudo, al alcanzar la #link(<glosario-tropopausa>)[tropopausa]#index("Tropopausa"), con un tope en forma de yunque. Esta configuración contiene energía masiva capaz de comprometer gravemente la seguridad del vuelo. Los riesgos asociados incluyen:

- #strong[Turbulencia severa:] Las corrientes ascendentes y descendentes que coexisten dentro y alrededor del Cb superan con facilidad los límites estructurales del planeador. El frente de ráfagas puede extenderse a kilómetros del núcleo y golpear sin previo aviso.
- #strong[#link(<glosario-granizo>)[Granizo]#index("Granizo"):] Las corrientes ascendentes arrastran agua hasta las capas de congelación repetidas veces, formando granizo que alcanza tamaños considerables. Un impacto de granizo puede dañar seriamente la #link(<glosario-cupula>)[cúpula]#index("Cúpula") y las estructuras de fibra de la aeronave.
- #strong[Actividad eléctrica:] Un rayo que impacte en el planeador compromete la integridad de la aeronave y pone en riesgo directo a los ocupantes.
- #strong[#link(<glosario-engelamiento>)[Engelamiento]#index("Engelamiento") masivo:] Al penetrar en las zonas superenfriadas del Cb, el borde de ataque acumula hielo claro en segundos, destruyendo el perfil laminar y disparando la velocidad de pérdida.

#block[
#callout(
body: 
[
El piloto debe evitar en todo #link(<glosario-momento>)[momento]#index("Momento") volar en las inmediaciones de un Cumulonimbus. Se recomienda mantener una separación lateral de seguridad entre 10 y 20 millas náuticas. Si un sistema convectivo amenaza el aeródromo, inicie de inmediato el procedimiento de aterrizaje.

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
== Reducciones de visibilidad: niebla y neblina
<reducciones-de-visibilidad-niebla-y-neblina>
Una degradación significativa en la #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") penaliza las Reglas de Vuelo Visual (#link(<glosario-vfr>)[VFR]#index("VFR")).

- #strong[Neblina y bruma:] Reducen la visibilidad horizontal a valores entre 1.000 m y 3.000 m.
- #strong[Niebla:] Fenómeno de suspensión de agua al nivel del terreno que restringe la visibilidad inferior a los 1.000 m. En estas condiciones, está inhabilitada la operación VFR.

Resulta de particular interés la #strong[#link(<glosario-niebla-de-radiacion>)[niebla de radiación]#index("Niebla de radiación")]. Se forma en madrugadas invernales tras noches despejadas bajo condiciones anticiclónicas. El rápido enfriamiento del terreno arrastra térmicamente la capa inferior de aire, saturándola y originando espesos bancos de niebla localizados.

Otro tipo relevante para los operadores de aeródromos costeros y de valle es la #strong[#link(<glosario-niebla-de-adveccion>)[niebla de advección]#index("Niebla de advección")] (#strong[advection fog]). A diferencia de la de radiación, no depende del enfriamiento nocturno del suelo: se forma cuando una #link(<glosario-masa-de-aire>)[masa de aire]#index("Masa de aire") cálido y húmedo se desplaza horizontalmente sobre una superficie más fría (el mar frío, un valle nevado o una costa). El contraste de temperatura basta para saturar la base de esa masa y producir un banco de niebla denso que puede persistir día y noche mientras dure el flujo. Es característica del litoral galaico-cantábrico en invierno y de las costas mediterráneas en otoño con viento de levante.

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
== Altocúmulos lenticulares y vuelo de onda
<altocúmulos-lenticulares-y-vuelo-de-onda>
Las #strong[nubes lenticulares] (#strong[Altocumulus lenticularis]) exhiben formas alisadas y características convexas, similares a una lente. A pesar de formarse bajo vientos de intensidad notable en altura, su estructura permanece totalmente estacionaria respecto al relieve.

Estas formaciones son la prueba visible de un flujo laminar constante interactuando transversalmente y rebotando a sotavento de un obstáculo orográfico. En la práctica, señalan el sistema de #strong[#link(<glosario-onda-de-montana>)[Onda de Montaña]#index("Onda de montaña")], donde es posible remontar sin turbulencia sostenidamente ganando gran altitud en un plano de aire terso (#ref(<fig-03-cap04-nubes-onda-montana>, supplement: [Figura])).

#figure([
#box(image("03-meteorologia/imagenes/03-cap04-onda-montana.jpg"))
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
Bajo la zona de onda, a baja altura, se esconde el #strong[#link(<glosario-rotor>)[rotor]#index("Rotor")]: un cilindro de turbulencia giratoria muy violento que se delata visualmente por fractocúmulos deshilachados e inestables. Si haces un remolque en zona de onda, el avión remolcador zarandeará con fuerza al atravesar el rotor. Mantén siempre altura suficiente para evitarlo y sigue las indicaciones del piloto remolcador en todo momento.

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
#strong[Resumen del capítulo: nubes y niebla]

- #strong[Significado de las nubes]: Para el piloto de planeador, las nubes son el mapa del cielo. Los #strong[Cúmulos (Cu)] pequeños y algodónosos son nuestros mejores amigos (marcan térmicas). Los #strong[Cirros] altos suelen anunciar un frente (mal tiempo en 24-48h).
- #strong[Peligro de Desarrollo Vertical]: Si un cúmulo crece mucho verticalmente (#strong[Cu congestus]), vigílalo de cerca. Si pasa a #strong[Cumulonimbus (Cb)], aléjate millas: hay turbulencia severa, granizo y rayos que pueden destruir el planeador.
- #strong[Niebla vs Neblina]: Ambas reducen la visibilidad. La niebla (\< 1 km) es crítica para el aterrizaje y despegue. Hay dos tipos frecuentes: la #strong[de radiación] (noches frías y despejadas, suele disiparse con el sol por la mañana) y la #strong[de advección] (aire cálido sobre superficie fría, puede presentarse a cualquier hora y no depende de la noche).
- #strong[Nubes Lenticulares]: Tienen forma de lenteja o platillo y se quedan "quietas" aunque sople mucho viento. Indican #strong[Onda de Montaña], un fenómeno que permite subir muy alto pero advierte de turbulencia (rotores) muy peligrosa a baja altura.

]
= Precipitación
<precipitación>
#quote(block: true)[
La precipitación ---lluvia, #link(<glosario-granizo>)[granizo]#index("Granizo"), lluvia engelante o virga--- no es solo un inconveniente: puede convertirse en una emergencia en pocos minutos. En este capítulo aprenderás cómo cada tipo de precipitación afecta al planeador aerodinámicamente, cuáles son los más peligrosos y qué decisiones debes tomar ante los primeros síntomas para mantenerte seguro.
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
Con alas mojadas, añade siempre un margen mínimo de 5-10 #link(<glosario-nudo>)[kt]#index("Nudo") sobre tu velocidad de aproximación estándar. Evita giros pronunciados: el riesgo de entrada en pérdida es significativamente mayor que en configuración seca y puede producirse sin advertencia previa.

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
El granizo nace dentro del #link(<glosario-cumulonimbus>)[Cumulonimbus]#index("Cumulonimbus") (Cb). Las potentes corrientes ascendentes lanzan las gotas de agua hasta por encima del nivel de congelación, donde se congelan. Luego caen, son atrapadas de nuevo por la corriente y suben otra vez, ganando una capa de hielo en cada ciclo ---como una cebolla--- hasta que pesan demasiado para que la corriente las sostenga. El resultado son piedras que pueden superar los 2--3 cm de diámetro.

Para las aeronaves compuestas con perfiles ligeros de fibra, la aceleración cinética del granizo (sumada a la propia velocidad de la aeronave) presenta gran riesgo estructural. Resulta habitual constatar roturas y perforaciones en la #link(<glosario-cupula>)[cúpula]#index("Cúpula") (#strong[canopy]), daños en los recubrimientos protectores superficiales de #strong[#link(<glosario-gelcoat>)[gelcoat]#index("Gelcoat")], o posibles delaminaciones de la matriz celular sintética en impactos directos severos.

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
La #strong[lluvia engelante] (#strong[#link(<glosario-fzra>)[FZRA]#index("Freezing Rain")]) es lluvia que cae ya superenfriada: gotas líquidas por debajo de 0°C que aún no se han congelado, las #strong[#link(<glosario-goticulas-superenfriadas>)[gotículas superenfriadas]#index("Gotículas superenfriadas")]. El escenario clásico es un #link(<glosario-frente-calido>)[frente cálido]#index("Frente cálido") en invierno, cuando la lluvia atraviesa una capa de aire bajo cero cerca del suelo. No hace falta estar dentro de una nube: al impactar contra cualquier superficie sólida del planeador ---borde de ataque, cúpula, morro--- las gotas se congelan en décimas de segundo formando hielo opaco o escarcha. Dentro de nube, entre 0°C y -15°C, esas mismas gotículas producen el #link(<glosario-engelamiento>)[engelamiento]#index("Engelamiento") que se detalla en el capítulo 9.

El resultado es el #strong[engelamiento] (#strong[icing]), uno de los peligros más rápidos y graves del vuelo a vela:

- La cúpula de la cabina se opaca en segundos, eliminando toda referencia visual #link(<glosario-vfr>)[VFR]#index("VFR").
- El hielo deforma el borde de ataque, destruye la sustentación laminar y eleva drásticamente la velocidad de pérdida.
- El peso añadido, distribuido asimétricamente en las puntas alares, incrementa el arrastre e introduce desequilibrios laterales difíciles de compensar.

Al primer síntoma de engelamiento ---escarcha en el borde del ala o en la cúpula--- gira 180° y desciende inmediatamente a niveles con temperatura positiva. No esperes: el engelamiento se acelera a medida que más superficie queda cubierta.

== Virga: la cortina descendente e invisibilidad
<virga-la-cortina-descendente-e-invisibilidad>
La #strong[#link(<glosario-virga>)[Virga]#index("Virga")] es una cortina de precipitación que cae desde la #link(<glosario-base>)[base]#index("Tramo de base") de una nube pero se evapora antes de llegar al suelo. Visualmente aparece como franjas grises o azuladas que se difuminan en el aire a media altura, sin tocar el terreno.

El peligro no está en la lluvia en sí, sino en lo que ocurre cuando esas gotas se evaporan: la evaporación enfría el aire circundante, que se vuelve más denso y cae en masa hacia el suelo formando una violenta corriente descendente ---el #strong[#link(<glosario-downburst>)[downburst]#index("microrráfaga")] o #strong[#link(<glosario-microburst>)[microrráfaga]#index("microrráfaga")] (#ref(<fig-03-cap05-virga-microrrafaga>, supplement: [Figura])).

#figure([
#box(image("03-meteorologia/imagenes/03-cap05-virga-microburst.jpg"))
], caption: figure.caption(
position: bottom, 
[
Peligro bajo la virga: el nacimiento de una microrráfaga
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap05-virga-microrrafaga>


Estas corrientes descendentes localizadas (#strong[microburst] / #strong[downdraft]) pueden alcanzar velocidades de descenso que superan la capacidad de ascenso del planeador. Volar bajo una virga, especialmente durante la aproximación #link(<glosario-final>)[final]#index("Tramo final"), puede causar un hundimiento irrecuperable antes del umbral. Ante cualquier cortina de virga visible, mantén siempre distancia de seguridad lateral y vertical.

#postit[
#strong[Resumen del capítulo: precipitación]

- #strong[Lluvia y Performance]: Para un planeador, la lluvia es kryptonita. El agua en las alas arruina el perfil laminar, aumentando drásticamente la velocidad de pérdida y la tasa de descenso. Si llueve, añade velocidad de seguridad al aterrizar.
- #strong[Granizo (GR)]: Asociado a los Cumulonimbus (Cb). Puede encontrarse incluso fuera de la nube, bajo el yunque. Es destructivo para la estructura de fibra. NUNCA vueles debajo de un yunque de tormenta.
- #strong[Lluvia Engelante (FZRA)]: Gotas superenfriadas que se congelan al impactar. Es una emergencia grave: el hielo se acumula en segundos, pesando y deformando el perfil. Sal inmediatamente de esa zona (generalmente cambiando de altitud).
- #strong[Virga]: Cortina de lluvia que se evapora antes de tocar el suelo. Es un aviso visual de fuertes corrientes descendentes y posible turbulencia severa debajo de ella.

]
= Masas de aire y frentes
<masas-de-aire-y-frentes>
#quote(block: true)[
Un frente es la frontera entre dos masas de aire con propiedades distintas, y cruzarlo sin planificación puede convertir un buen vuelo en una emergencia. En este capítulo aprenderás a reconocer frentes fríos, cálidos y ocluidos antes de que lleguen a tu zona, y entenderás por qué la temperatura relativa de la #link(<glosario-masa-de-aire>)[masa de aire]#index("Masa de aire") determina si tendrás térmicas o #link(<glosario-niebla>)[niebla]#index("Niebla") bajo tus ruedas.
]

== Frentes fríos e inestabilidad
<frentes-fríos-e-inestabilidad>
Un #strong[#link(<glosario-frente-frio>)[frente frío]#index("Frente frío")] corresponde a la superficie de separación en la cual una masa de aire frío, al ser más densa, avanza en forma de cuña introduciéndose por debajo de una masa de aire cálido preexistente. Este proceso obliga al aire cálido a ascender de manera pronunciada.

El paso de un frente frío se caracteriza por un descenso abrupto de las temperaturas, una rolada brusca de viento (generalmente hacia el noroeste o norte), #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") reducida y precipitaciones organizadas, frecuentemente en forma de chubascos y nubes de gran desarrollo vertical como los #link(<glosario-cumulonimbus>)[Cumulonimbus]#index("Cumulonimbus") (Cb) (#ref(<fig-03-cap06-frente-frio-estructura>, supplement: [Figura])).

Para el vuelo a vela, el interés meteorológico óptimo radica en la situación posterior al frente. Una vez despejada la barrera frontal, la región queda dominada por una masa de aire transicional netamente más fría que el terreno. Al calentarse su #link(<glosario-base>)[base]#index("Tramo de base") por contacto con el suelo, se establece una marcada #strong[inestabilidad post-frontal].

#block[
#callout(
body: 
[
Las jornadas inmediatas tras el cruce de un frente frío intercontinental suelen ofrecer las mejores condiciones de vuelo térmico. Se caracterizan por una excelente visibilidad por ausencia de calima, presión atmosférica en aumento y un fuerte calentamiento diurno que detona corrientes ascendentes robustas marcadas por nubes Cúmulos (#link(<glosario-cumulo>)[Cu]#index("Cúmulo")) de contornos definidos.

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
#box(image("03-meteorologia/imagenes/03-cap06-frente-frio-estructura.png"))
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
Un #strong[#link(<glosario-frente-calido>)[frente cálido]#index("Frente cálido")] se produce cuando una masa de aire cálido avanza y asciende suavemente sobre una masa de aire frío más densa y estacionaria que ocupa la cuenca inferior. Al presentar una pendiente mucho menor que la del frente frío, su evolución y desplazamiento resultan lentos y prolongados.

La proximidad de un frente cálido se anticipa visualmente horas o días antes mediante la aparición escalonada de nubes tipo #strong[Cirros (Ci)] (#ref(<fig-03-cap06-frente-calido-nubes>, supplement: [Figura])). Conforme el sistema avanza, la nubosidad se engrosa y desciende de altitud progresivamente, transitando a Cirroestratos, Altoestratos y concluyendo en una capa de Nimbostratos (Ns) y Estratos (St).

Un frente cálido degrada las condiciones #link(<glosario-vfr>)[VFR]#index("VFR") de forma progresiva:

- Genera precipitaciones continuas y lloviznas persistentes de amplia cobertura.
- Los techos nubosos descienden paulatinamente, ocultando elevaciones y relieves montañosos.
- La humedad constante propicia la formación de brumas y nieblas cálidas que deterioran de manera drástica la visibilidad en superficie.
- A nivel termodinámico, estabiliza completamente la masa de aire suprimiendo físicamente el desarrollo de corrientes convectivas o térmicas aprovechables.

#figure([
#box(image("03-meteorologia/imagenes/03-cap06-frente-calido-nubes.png"))
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
Cuando un frente frío avanza más rápido que el cálido que tiene delante, termina alcanzándolo. Entonces el frente frío empuja desde atrás y pilla al aire cálido intermedio: lo pinza, lo levanta del suelo y lo obliga a ascender por completo. A este proceso se le llama #strong[#link(<glosario-frente-ocluido>)[frente ocluido]#index("Frente ocluido")] u oclusión (#ref(<fig-03-cap06-tipos-frentes>, supplement: [Figura])).

Operativamente, una oclusión es lo peor de los dos frentes combinado: la convección violenta del frente frío más la lluvia continua y los techos bajos del frente cálido. El aire cálido ya no toca el suelo, así que las térmicas desaparecen y la turbulencia convectiva puede aparecer embebida en capas densas sin aviso visual claro. Ante un frente ocluido, pospón el vuelo: las condiciones son complejas e impredecibles.

#figure([
#box(image("03-meteorologia/imagenes/03-cap06-frente-ocluido.png"))
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
#strong[#link(<glosario-sera>)[SERA]#index("SERA")​.5001] (Reglamento de Ejecución (UE) 923/2012) establece los mínimos meteorológicos para el vuelo VFR. En espacio aéreo de clase G, por debajo de 3.000 ft #link(<glosario-amsl>)[AMSL]#index("AMSL") o 1.000 ft sobre el terreno, la visibilidad mínima general es de #strong[5 km], volando libre de nubes y con la superficie a la vista. Puede reducirse hasta #strong[1.500 m] para vuelos a 140 #link(<glosario-nudo>)[kt]#index("Nudo") o menos, siempre que la velocidad permita ver el tráfico y los obstáculos con tiempo para evitar la colisión. La penetración inadvertida en IMC por un piloto VFR sin habilitación de vuelo instrumental constituye una infracción grave.

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
- #strong[Aire cálido deslizándose sobre suelo frío = ESTABILIDAD.] Sucede cuando una masa cálida avanza sobre el océano frío o sobre continentes nevados. La base de ese aire se enfría y se hace más densa al contacto con el suelo, formando una inversión estable que suprime cualquier #link(<glosario-termica>)[térmica]#index("Térmica") y propicia nieblas persistentes.

== Clasificación de las masas de aire
<clasificación-de-las-masas-de-aire>
Antes de hablar de temperatura relativa, es útil conocer de dónde viene el aire que tienes encima. Las masas de aire se clasifican por dos criterios: su #strong[#link(<glosario-latitud>)[latitud]#index("Latitud") de origen] (determina su temperatura) y su #strong[trayectoria] (determina su humedad).

#table(
  columns: (25%, 25%, 25%, 25%),
  align: (auto,auto,auto,auto,),
  table.header([Sigla], [Tipo], [Temperatura], [Humedad y características para el vuelo a vela],),
  table.hline(),
  [#strong[Tc / Tm]], [Tropical (continental o marítimo)], [Cálido], [Tm: húmedo, bruma frecuente, térmicas débiles. Tc: caluroso y seco, inestabilidad fuerte en verano, excelentes térmicas en la Meseta.],
  [#strong[Pc / Pm]], [Polar (continental o marítimo)], [Frío], [Pm: húmedo, post-frontal clásico, bases de cúmulos bajas pero térmicas presentes. Pc: muy frío y seco, visibilidad excepcional.],
  [#strong[A]], [Ártico / Antártico], [Muy frío], [Irrupciones invernales desde el norte. Termómetros negativos en pista, #link(<glosario-engelamiento>)[engelamiento]#index("Engelamiento") severo, vientos fuertes. No volar.],
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
#postit[
#strong[Resumen del capítulo: masas de aire y frentes]

- #strong[Frente Frío]: El mejor amigo del volovelista (después de que pasa). Trae inestabilidad, cielo limpio y térmicas potentes (cielo de "post-frente"). Al cruzarlo, espera chubascos, rolada de viento y bajada de temperatura.
- #strong[Frente Cálido]: Malas noticias. Anunciado por cirros que bajan a estratos, trae lluvia continua, techos bajos y mala visibilidad. El aire es estable, así que olvídate de las térmicas.
- #strong[Oclusiones]: Cuando el frente frío alcanza al cálido. Generalmente significa tiempo revuelto, mezcla de nubes y precipitaciones. Poco aprovechable para el vuelo.
- #strong[Masas de Aire]: Lo que importa es la temperatura relativa. Aire frío sobre suelo caliente = inestabilidad (¡térmicas!). Aire cálido sobre suelo frío = estabilidad (capas, niebla, inversión).

]
= Sistemas de presión
<sistemas-de-presión>
#quote(block: true)[
Los anticiclones y las borrascas son los protagonistas del mapa sinóptico: determinan si tendrás viento, nubes, #link(<glosario-niebla>)[niebla]#index("Niebla") o el cielo azul perfecto. En este capítulo aprenderás a interpretar la posición de los centros de presión, a anticipar las condiciones de vuelo con 24-48 horas de antelación y a reconocer las trampas del #link(<glosario-collado-barometrico>)[collado barométrico]#index("Collado barométrico").
]

== Anticiclones (H)
<anticiclones-h>
Un #strong[#link(<glosario-anticiclon>)[anticiclón]#index("Anticiclón")] (representado con una 'H' de #strong[High] o una 'A' en mapas sinópticos) es una amplia región atmosférica donde la presión es superior a la de su entorno. En estos sistemas, la densa #link(<glosario-masa-de-aire>)[masa de aire]#index("Masa de aire") experimenta un suave descenso divergente en superficie, proceso conocido como #strong[subsidencia].

A medida que desciende, el aire se comprime y se calienta adiabáticamente, lo cual produce un marcado resecamiento e inhibe de forma drástica el desarrollo vertical de nubes convectivas. En el hemisferio norte, la circulación de este aire en superficie fluye hacia el exterior girando en sentido horario. Sus isobaras, habitualmente espaciadas, denotan áreas de calmas o vientos muy flojos.

Sus implicaciones para el vuelo varían notoriamente según la estacionalidad:

- #strong[En meses cálidos:] Resultan en cielos despejados e intensamente azules. No obstante, la fuerte subsidencia actúa como una tapadera altitudinal efectiva que frena abruptamente la ascensión de las térmicas, reduciendo con frecuencia el techo operativo.
- #strong[En meses fríos:] Propician una caída brusca de la temperatura nocturna por rápida irradiación infrarroja de la superficie terrestre. Esta influencia suele desencadenar persistentes y densas nieblas de radiación así como #strong[inversiones térmicas] sumamente estables que bloquean la #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") de los valles durante largas jornadas.

No todos los anticiclones son iguales. Según su mecanismo de formación se distinguen dos tipos con efectos muy distintos para el vuelo:

- #strong[Anticiclón dinámico o cálido] (#strong[warm high]): Se forma por subsidencia en la zona de contacto entre las celdas de Hadley y Ferrel (en #link(<glosario-torno>)[torno]#index("Torno") a los 30° de #link(<glosario-latitud>)[latitud]#index("Latitud")). El aire desciende desde la #link(<glosario-troposfera>)[troposfera]#index("Troposfera") alta, se comprime y se calienta. Puede extenderse hasta la #link(<glosario-tropopausa>)[tropopausa]#index("Tropopausa"). El #strong[anticiclón de las Azores] es el ejemplo ibérico por excelencia: en verano se instala sobre la Península y garantiza jornadas largas de vuelo con cielo azul y viento flojo.
- #strong[Anticiclón frío o termal] (#strong[cold high]): Se forma por enfriamiento intenso de grandes superficies continentales, que enfrían el aire en contacto con el suelo. Es denso y frío en las capas bajas pero tiene poca altura ---apenas llega a los 3.000-4.000 m. El anticiclón ibérico invernal es de este tipo: trae noches gélidas, nieblas de radiación persistentes en cuenca del Duero y del Ebro, e inversiones térmicas bajas que bloquean cualquier actividad convectiva.

#block[
#callout(
body: 
[
Para planificar el vuelo del día, mira el mapa sinóptico la noche anterior: si España está bajo una #link(<glosario-dorsal>)[dorsal]#index("Dorsal") o anticiclón (H), planifica vuelo de distancia; si hay una #link(<glosario-vaguada>)[vaguada]#index("Vaguada") o #link(<glosario-borrasca>)[borrasca]#index("Depresión") acercándose, no planifiques. El movimiento de las isobaras te da 24-48 horas de margen para decidir con criterio.

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
== Borrascas o depresiones (L)
<borrascas-o-depresiones-l>
Las #strong[borrascas] (representadas con 'L' de #strong[Low] o 'B') son áreas de baja presión: zonas donde la presión es un #strong[mínimo relativo respecto a su entorno], con las isobaras cerradas alrededor del núcleo. Lo que las define es esa relación con lo que las rodea, no un umbral absoluto: existen borrascas con núcleo por encima de 1.013 hPa y anticiclones (sobre todo térmicos) con periferia por debajo de ese valor.

Al contrario que en el anticiclón, el gradiente de presión obliga al aire del entorno a converger hacia el centro de la borrasca y, desde allí, ascender. Ese ascenso enfría el aire y favorece la condensación, generando nubes extensas y frentes de precipitación activa.

En el hemisferio norte, las borrascas giran en sentido #strong[antihorario]. Sus isobaras muy apretadas son sinónimo de vientos fuertes y racheados: la operación #link(<glosario-vfr>)[VFR]#index("VFR") dentro de una borrasca activa es inviable. Sin embargo, la retaguardia post-frontal ---lo que queda tras el paso de la borrasca--- suele ofrecer las mejores jornadas de vuelo del año.

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
== Vaguadas y dorsales: isobaras irregulares
<vaguadas-y-dorsales-isobaras-irregulares>
Los anticiclones y las borrascas no son siempre círculos perfectos: a menudo emiten "brazos" que se extienden por el mapa en forma de lengua.

- #strong[Vaguada (Surco):] Es una extensión alargada de baja presión que sale de una borrasca, como un tentáculo. Genera las mismas condiciones que su borrasca madre: inestabilidad, chubascos, turbulencia y ráfagas. En el mapa se reconoce como una curva en 'U' o 'V' de las isobaras apuntando hacia el ecuador.
- #strong[Dorsal (Cuña):] Es la extensión alargada de un anticiclón, que lleva consigo su subsidencia y su buen tiempo. Mientras la dorsal domina tu zona, el aire desciende, el cielo se despeja y las térmicas quedan limitadas en altura por esa misma subsidencia.

== Pantano barométrico en áreas de collado
<pantano-barométrico-en-áreas-de-collado>
Un #strong[collado] o #strong[pantano barométrico] se forma cuando dos centros de alta presión y dos de baja presión se sitúan alternados alrededor de un área central, anulando mutuamente sus gradientes. El resultado es una zona de vientos flojos y variables, sin dirección dominante clara ni isobaras con empuje apreciable.

Aunque parece inofensiva por su calma, esta configuración impone condiciones operativas específicas según la estación: 1. #strong[En verano:] Impide que los frentes fríos disipen el fuerte calentamiento diurno. Esta energía acumulada puede generar tormentas locales aisladas muy violentas y estáticas, que suelen producir fenómenos peligrosos como la #link(<glosario-virga>)[virga]#index("Virga"). 2. #strong[En invierno:] La estabilidad absoluta favorece la formación de bancos de niebla densos y persistentes. Al quedar el aire gélido atrapado cerca del suelo por la subsidencia, la visibilidad puede quedar inhabilitada durante días.

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
  [Anticiclón], [H / A], [Horaria, divergente en superficie (subsidencia)], [Escasa o nula], [Buen tiempo VFR; inversión limita el techo térmico. #link(<glosario-niebla-de-radiacion>)[Niebla de radiación]#index("Niebla de radiación") en invierno.],
  [Borrasca / Depresión], [L / B], [Antihoraria, convergente (ascendencia)], [Abundante; frentes activos], [Viento fuerte y racheado, precipitación, VFR inviable. Excelente post-frente.],
  [Vaguada (surco)], [---], [Inestabilidad local creciente], [Cumuliformes, chubascos], [Tormentas aisladas y turbulencia. Evitar o planificar antes del calentamiento diurno.],
  [Dorsal (cuña)], [---], [Subsidencia estable], [Escasa o nula], [Condiciones VFR favorables, térmicas moderadas. Sin riesgo convectivo significativo.],
  [Collado / Pantano barométrico], [---], [Flojas y variables, sin dirección dominante], [Variable (niebla en invierno; #link(<glosario-cumulonimbus>)[Cb]#index("Cumulonimbus") estáticos en verano)], [Impredecible. No planifiques vuelos de distancia hasta que el patrón se resuelva.],
)
#postit[
#strong[Resumen del capítulo: sistemas de presión]

- #strong[Anticiclones (H)]: Zonas de alta presión donde el aire baja (subsidencia) y se seca. Garantizan estabilidad y buen tiempo, pero en invierno atrapan nieblas y contaminación. El viento gira en sentido horario (H. Norte).
- #strong[Borrascas (L)]: Zonas de baja presión donde el aire sube y condensa. Son fábricas de nubes, frentes y viento. El viento gira en sentido antihorario (H. Norte).
- #strong[Vaguadas y Dorsales]: Una vaguada es una "lengua" de baja presión (mal tiempo estirado); una dorsal es una "lengua" de alta presión (buen tiempo estirado).
- #strong[Collado]: Zona neutra entre dos altas y dos bajas cruzadas. Es como un pantano barométrico: vientos flojos, dirección variable y probabilidad de nieblas o tormentas estáticas en verano.

]
= Climatología
<climatología>
#quote(block: true)[
España ocupa una posición geográfica privilegiada para el vuelo a vela: orografía compleja, contrastes térmicos extremos entre mesetas y litoral, y mar perimetral en tres frentes. En este capítulo aprenderás qué define el clima aeronáutico de la Península Ibérica en cada estación, cómo actúan los vientos locales en los valles y qué papel juega la Baja #link(<glosario-termica>)[Térmica]#index("Térmica") Peninsular como motor de las mejores jornadas de cross-country estival.
]

== Circulación general de la atmósfera
<circulación-general-de-la-atmósfera>
Antes de entrar en la climatología local, conviene situar el contexto planetario. La atmósfera terrestre no circula al azar: el calor solar, la rotación de la Tierra y la diferencia de temperatura entre el ecuador y los polos organizan el flujo en tres bandas de circulación por hemisferio, llamadas #strong[celdas de circulación general].

- #strong[Celda de Hadley] (área tropical, 0--30° de #link(<glosario-latitud>)[latitud]#index("Latitud")): El aire ecuatorial, muy calentado, asciende formando la #strong[Zona de Convergencia Intertropical (ZCIT)], la banda de inestabilidad más activa del planeta. En altura fluye hacia los polos y, al llegar a los 30°, se hunde y desciende (subsidencia) formando los anticiclones subtropicales (como el #link(<glosario-anticiclon>)[Anticiclón]#index("Anticiclón") de las Azores, clave para el clima peninsular).
- #strong[Celda de Ferrel] (área templada, 30--60° de latitud): Por esta banda serpentea el #strong[chorro polar] (#strong[jet stream]) de poniente. Sus fluctuaciones son las que dirigen los frentes y borrascas hacia la Península Ibérica. Los pilotos que planifican vuelos de distancia en invierno o primavera notarán su influencia directa.
- #strong[Celda Polar] (área polar, 60--90° de latitud): Aire frío polar que desciende en los polos y fluye en superficie hacia latitudes medias, alimentándolas de las masas de aire ártico que nos llegan tras los frentes fríos invernales.

España se sitúa en el borde sur de la Celda de Ferrel, lo que la convierte en territorio de transición: puede recibir tanto la influencia anticiclónica subtropical (buen tiempo en verano) como el paso de los frentes atlánticos de la Celda de Ferrel (lluvias y viento en invierno). Esta posición fronteriza genera una variabilidad meteorológica excepcional, que es exactamente lo que hace que volar en la península sea tan técnicamente exigente y tan recompensante.

== España: origen de contrastes aeronáuticos
<españa-origen-de-contrastes-aeronáuticos>
Debido a su compleja orografía y situación geográfica, la península ibérica ofrece condiciones de clase mundial para la práctica del vuelo sin motor a lo largo de todo el año.

- #strong[#link(<glosario-vuelo-de-onda>)[Vuelo de Onda]#index("Vuelo de onda") y Laderas:] Durante el invierno y la ventosa primavera, los grandes macizos montañosos actúan como gigantescos deflectores. Es especialmente destacable la #strong[#link(<glosario-onda-de-montana>)[Onda de Montaña]#index("Onda de montaña")] en el Sistema Central (zonas míticas como Fuentemilanos, Santo Tomé, Pedro Bernardo o Arcones) y en la potente "Convergencia Pirenaica". Estas condiciones permiten ascensos de onda espectaculares y vuelos de altitud y distancia extrema.
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
Para un piloto de aviación de transporte el viento general lo es todo; para el piloto de planeador, que vuela pegado al terreno, #strong[cada valle tiene su propio dueño y señor atmosférico]. El Capítulo 2: Viento describe en detalle el ciclo anábático y catabático y el #link(<glosario-efecto-foehn>)[efecto Foehn]#index("Efecto Foehn")\; aquí nos centramos en cómo esos mecanismos definen el vuelo en el contexto ibérico concreto.

En zonas montañosas como el Sistema Central, los Pirineos o los Picos de Europa, los #strong[vientos anabáticos matinales] disparan las primeras térmicas antes incluso de que el sol alcance los 30° de elevación: las solanas orientadas al este son las primeras en activarse. Al atardecer, los #strong[catabáticos] que bajan por ambas laderas del valle pueden generar una zona de restitución en el centro ---esa ascendencia suave que a veces permite prolongar el vuelo hasta el oscurecer. Conocer cuál es la dirección catabática de tu aeródromo local es tan importante como saber la posición de la cabecera.

Los #strong[rotores de sotavento] son la trampa invisible de la climatología ibérica: con viento de componente norte en el Sistema Central o con Tramontana en el Pirineo, el #link(<glosario-rotor>)[rotor]#index("Rotor") puede situarse exactamente sobre la vertical del aeródromo a alturas de circuito. Si el día presenta lenticulares en altura y ves fractocúmulos deshilachados a baja cota, trata esa zona como zona de turbulencia severa.

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
- #strong[Otoño:] Generalmente asociado a mayor estabilidad y lluvias. En el área mediterránea es la época de las #link(<glosario-dana>)[DANA]#index("DANA") (Depresiones Aisladas en Niveles Altos), que generan tormentas severas y precipitaciones intensas, reduciendo significativamente las oportunidades de vuelo.
- #strong[Días Post-Frontales:] Con independencia de la estación, el día después del paso de un #link(<glosario-frente-frio>)[frente frío]#index("Frente frío") suele ofrecer condiciones excelentes. La atmósfera queda limpia, nítida y con #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") excepcional. El contraste térmico entre el aire gélido y el suelo reactiva las mejores corrientes ascendentes del año.

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
== La baja térmica peninsular estival
<la-baja-térmica-peninsular-estival>
En los picos crudos del verano, la intensa radiación solar hornea la superficie de las vastas mesetas del interior peninsular. Este calentamiento brutal genera grandes columnas de aire cálido ascendentes, estableciendo una permanente #strong[baja térmica peninsular] en el centro de España.

Aunque barométricamente no es tan profunda como una fuerte #link(<glosario-borrasca>)[borrasca]#index("Depresión") polar, esta masa estancada ejerce una constante fuerza de succión. Como si fuera una gigantesca aspiradora, la baja térmica tira continuamente de las densas masas de aire frío y húmedo que reposan sobre el océano y los mares perimetrales, arrastrándolas hacia el interior terrestre.

Este imparable avance de aire marino forzado tierra adentro se convierte en extensos #strong[frentes de brisa] que penetran decenas de kilómetros. Al chocar contra la masa continental abrasadora y contra las barreras de los sistemas montañosos, levantan forzosamente el aire inestable en formidables #strong[líneas de convergencia]: autopistas invisibles de ascendencia que el piloto experimentado aprende a seguir en sus vuelos de distancia.

#block[
#callout(
body: 
[
Las líneas de convergencia generadas por la Baja Térmica Peninsular son autopistas de sustentación en verano. Identifícalas en las previsiones de modelos RASP o Skysight y planifica tu ruta de cross-country siguiéndolas: con brisa bien establecida, una sola #link(<glosario-linea-de-convergencia>)[línea de convergencia]#index("Línea de convergencia") puede regalarte decenas de kilómetros sin perder altitud.

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
#strong[Resumen del capítulo: climatología]

- #strong[España, país de contrastes]: Tenemos condiciones mundiales para el vuelo. Viento y #strong[Onda de Montaña] en invierno/primavera (Pirineos, Sistema Central) y potentes #strong[Térmicas] en verano (La Mancha, zonas interiores).
- #strong[Vientos Locales]: Cada valle tiene su dueño. Los vientos anabáticos y catabáticos definen la mañana y la tarde en zonas montañosas. Los rotores de sotavento son la trampa invisible del piloto imprudente.
- #strong[Estacionalidad]: La primavera ofrece inestabilidad y buen vuelo local. El verano trae techos altos y tormentas secas de calor. El otoño suele traer lluvias y DANA.
- #strong[Baja Térmica Peninsular]: En verano, el sol calienta tanto el centro de España que se forma una baja presión permanente. Esto succiona aire del mar, reforzando las brisas costeras que penetran muy adentro y generan líneas de convergencia ideales para el cross-country.

]
= Peligros para el vuelo (#emph[flight hazards])
<peligros-para-el-vuelo-flight-hazards>
#quote(block: true)[
La meteorología peligrosa no siempre avisa con tiempo: un #link(<glosario-cumulonimbus>)[Cb]#index("Cumulonimbus") puede crecer mientras haces el preflight, el hielo puede formarse en minutos y la #link(<glosario-cizalladura>)[cizalladura]#index("Cizalladura") puede tirarte al suelo en los últimos metros de #link(<glosario-final>)[final]#index("Tramo final"). En este capítulo aprenderás a identificar y evitar los peligros meteorológicos más críticos para el vuelo a vela, y qué decisiones tomar cuando aparecen.
]

== Tormentas y nubes de desarrollo extremo (Cb)
<tormentas-y-nubes-de-desarrollo-extremo-cb>
El Cumulonimbus (Cb) representa la manifestación más severa de la inestabilidad atmosférica. Alberga en su volumen los meteoros más hostiles condensados en una misma #link(<glosario-borrasca>)[depresión]#index("Depresión") celular. Para cualquier aeronave, y en especial para un velero ligero, la doctrina de vuelo exige que #strong[jamás] se debe operar bajo un Cb, en su interior, ni en sus proximidades (con un margen de evitación recomendado de entre 10 y 20 #link(<glosario-milla-nautica>)[NM]#index("Milla náutica")) (#ref(<fig-03-cap09-cumulonimbus>, supplement: [Figura])).

- #strong[Peligros estructurales:] Estas inmensas formaciones convectivas desatan corrientes ascendentes y descendentes contiguas de virulencia extrema. La turbulencia cizallante generada (#strong[updrafts] y #strong[downdrafts]) puede exceder holgadamente los factores de #link(<glosario-carga-limite>)[carga límite]#index("Carga límite") de diseño de cualquier aeronave ligera, provocando fallos estructurales en vuelo.
- #strong[Fenómenos asociados:] Los Cb están perimetralmente flanqueados por turbonadas con fortísimos vientos racheados direccionales, alta densidad de descargas eléctricas (rayos), precipitación abundante y, con alta probabilidad, #link(<glosario-granizo>)[granizo]#index("Granizo"). El impacto de granizo severo (diámetros \> 2 cm) destruye el perfil laminar y puede comprometer la integridad de la estructura del planeador.
- #strong[Identificación preventiva:] La acción fundamental es la anticipación. La detección visual del característico "yunque" expansivo en la #link(<glosario-tropopausa>)[tropopausa]#index("Tropopausa"), o el profundo oscurecimiento de avance abovedado en la #link(<glosario-base>)[base]#index("Tramo de base") (#strong[roll cloud]), exigen maniobra evasiva inmediata y la toma de decisión para aterrizar en campo o en el aeródromo alternativo despejado más cercano.

#figure([
#box(image("03-meteorologia/imagenes/03-cap09-cb.jpg"))
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

+ #strong[Fase de desarrollo o #link(<glosario-cumulo>)[cúmulo]#index("Cúmulo") (cumulus stage)]: domina la corriente ascendente. Un #link(<glosario-cumulo-congestus>)[cúmulo congestus]#index("Cúmulo congestus") crece rápidamente en vertical, alimentado por aire cálido y húmedo. Todavía no hay precipitación que llegue al suelo, pero la ascendencia ya es fuerte y desorganizada. Para el velero, la ascendencia es tentadora y engañosa: la nube aún está «cargándose».
+ #strong[Fase de madurez (mature stage)]: la más peligrosa. Coexisten la corriente ascendente y la descendente; comienza la precipitación, que arrastra aire frío hacia abajo y genera el frente de racha en superficie. Es la etapa del granizo, los rayos, la turbulencia extrema y el #strong[#link(<glosario-downburst>)[downburst]#index("microrráfaga")]. La nube alcanza su máximo desarrollo vertical y aparece el yunque.
+ #strong[Fase de disipación (dissipating stage)]: domina la corriente descendente. El aire frío de la precipitación corta el suministro de aire cálido que alimentaba la célula, la ascendencia se apaga y la tormenta se deshace, dejando restos de yunque y precipitación débil. Sigue habiendo turbulencia residual.

#figure([
#box(image("03-meteorologia/imagenes/03-cap09-ciclo-tormenta.png"))
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
El #link(<glosario-engelamiento>)[engelamiento]#index("Engelamiento") (#strong[icing]) es uno de los peligros más rápidos y silenciosos del vuelo a vela. Ocurre cuando el planeador entra en nubosidad o zonas de humedad visible con temperatura negativa ---el intervalo de mayor riesgo está entre 0 °C y -15 °C, con el máximo en #link(<glosario-torno>)[torno]#index("Torno") a -10 °C, aunque puede aparecer a temperaturas más bajas. Las gotículas de agua superenfriadas se congelan en décimas de segundo al tocar el borde de ataque, la #link(<glosario-cupula>)[cúpula]#index("Cúpula") o cualquier superficie frontal de la aeronave.

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

- #strong[#link(<glosario-estela-turbulenta>)[Estela turbulenta]#index("Estela turbulenta") (#link(<glosario-turbulencia-de-estela>)[wake turbulence]#index("Turbulencia de estela")):] Las aeronaves grandes ---reactores pesados o turbohélices de gran tonelaje--- desprenden de las puntas de sus alas dos vórtices poderosos que giran como tornillos. Estos vórtices descienden lentamente por debajo de la senda de vuelo y pueden persistir varios minutos en zonas con poco viento. Si un planeador cruza esa estela, el vuelco puede ser instantáneo y superar la capacidad de los mandos para corregirlo. En un aeródromo con tráfico mixto, espera siempre al menos 3 minutos tras el despegue o aterrizaje de una aeronave pesada antes de usar la misma pista (#ref(<fig-03-cap09-estela-turbulenta>, supplement: [Figura])).

- #strong[Estela de helicópteros:] Los helicópteros generan flujos de aire extremadamente peligrosos debido a la enorme cantidad de energía concentrada por sus palas de #link(<glosario-rotor>)[rotor]#index("Rotor"). Su peligro se divide en dos escenarios:

  - #strong[En vuelo estacionario o rodaje lento (hover):] El rotor proyecta un flujo descendente de alta velocidad (#strong[downwash] o #strong[rotor wash]) que impacta contra el suelo y se expande en forma de vórtices turbulentos hasta una distancia de al menos tres diámetros de rotor.
  - #strong[En vuelo de avance:] El rotor genera un par de vórtices de estela similares a los de un avión de ala fija, pero notablemente más concentrados e intensos a baja velocidad. Cruzar esta estela puede provocar una guiñada o un alabeo instantáneo e incontrolable para un planeador.

#figure([
#box(image("03-meteorologia/imagenes/03-cap09-estela-turbulenta.jpg"))
], caption: figure.caption(
position: bottom, 
[
Estudio de la NASA sobre los vórtices de las puntas de las alas, ilustra cualitativamente la turbulencia de estela.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap09-estela-turbulenta>


- #strong[Rotores (rotor turbulence):] A sotavento de una cordillera con viento fuerte, a baja altura se forma el #strong[rotor]: un cilindro de aire en rotación caótica e invisible desde fuera. Es la contrapartida peligrosa de la #link(<glosario-onda-de-montana>)[onda de montaña]#index("Onda de montaña"): mientras en la onda se sube con suavidad, a baja cota bajo esa misma onda el rotor puede arrebatarte el control del planeador con una única ráfaga. Si haces un remolque en zona de onda, sigue al avión remolcador con precisión, aprieta el arnés y no te acerques a la zona de rotor si puedes evitarlo (#ref(<fig-03-cap09-flujo-crestas>, supplement: [Figura])).

#figure([
#box(image("03-meteorologia/imagenes/03-cap09-flujo-crestas.jpg"))
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

- #strong[Riesgo en final:] El planeador estima su energía de planeo sobre el viento de cara reinante. Si ese viento desaparece o gira a cola de forma súbita ---lo que ocurre al cruzar una cizalladura--- la velocidad aerodinámica (#link(<glosario-ias>)[IAS]#index("IAS")) cae bruscamente, la sustentación se reduce y el planeador desciende de golpe. A escasa altura sobre el umbral no hay margen de recuperación: una pérdida de 10 #link(<glosario-nudo>)[kt]#index("Nudo") de viento de cara en final puede llevar al aporrizaje (#strong[crash landing]) en pocos segundos.
- #strong[Reventones (Microbursts/Downbursts):] Íntimamente ligados a la base de cumulonimbos desarrollados que descargan lluvia intensa. Estas masas de aire frío se desploman verticalmente hacia el suelo, donde se expanden horizontalmente provocando ráfagas radiales opuestas. Entrar en una micro ráfaga durante la aproximación es extremadamente peligroso: primero el planeador experimenta una ganancia de sustentación engañosa por el viento de cara, para segundos después sufrir un hundimiento masivo por el aire descendente y el repentino viento de cola, que puede llevar a un aterrizaje forzado o accidente si no se tiene suficiente altitud y velocidad (#ref(<fig-03-cap09-cizalladura>, supplement: [Figura])).

#figure([
#box(image("03-meteorologia/imagenes/03-cap09-cizalladura.jpg"))
], caption: figure.caption(
position: bottom, 
[
Reventón (#strong[downburst]) en la aproximación final: el aire descendente se expande en superficie y cambia bruscamente el viento de cara a cola
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap09-cizalladura>


#postit[
#strong[Resumen del capítulo: peligros para el vuelo]

- #strong[Tormentas (Cb)]: La madre de todos los peligros. Jamás vueles bajo un Cb ni cerca de él (\< 10-20 NM). Turbulencia extrema, granizo y rayos. Si ves un yunque, da media vuelta.
- #strong[Ciclo de la tormenta]: tres fases. Desarrollo (cúmulo): ascendente dominante, sin lluvia. Madurez: ascendente y descendente juntas, granizo, rayos y #strong[downburst] --- la más peligrosa. Disipación: descendente dominante, la célula se deshace.
- #strong[Engelamiento]: El hielo destruye la aerodinámica y eleva la velocidad de pérdida sin aviso. Cuatro depósitos ---escarcha (en rigor no es engelamiento: es sublimación), hielo opaco, mixto y claro---; el #strong[clear ice] es el más peligroso por invisible e irregular. Mayor riesgo entre 0 y −15 °C. Ante hielo, sal de la nube y baja a aire cálido.
- #strong[Turbulencia]: La de estela de aviones pesados desciende lentamente y causa vuelco instantáneo (espera 3 minutos antes de usar la pista). El rotor de onda se forma a sotavento a baja cota con rotación caótica e invisible.
- #strong[Cizalladura (Windshear)]: Cambio brusco de viento en tramo final. Puede tirarte al suelo (caída de velocidad de cara). Los #strong[downbursts] (reventones) provocan primero viento de cara y luego un brusco hundimiento y viento de cola.

]
= Información meteorológica
<información-meteorológica>
#quote(block: true)[
Saber volar es necesario; saber leer el tiempo antes de despegar es imprescindible. En este capítulo aprenderás a interpretar METARs, TAFs, mapas #link(<glosario-sigwx>)[SIGWX]#index("SIGWX") y sondeos termodinámicos aplicados al vuelo sin motor: desde descifrar un código de cuatro letras hasta decidir con criterio si el día merece o no sacar el planeador del hangar.
]

== Informes METAR y TAF
<informes-metar-y-taf>
Para la operativa del vuelo a vela, dada su intrínseca dependencia de los fenómenos atmosféricos, la capacidad de discernir e interpretar con precisión la información meteorológica aeronáutica es un requisito fundamental antes de iniciar cualquier vuelo. Los boletines estandarizados principales son el #link(<glosario-metar>)[METAR]#index("METAR") y el #link(<glosario-taf>)[TAF]#index("TAF"):

- #strong[METAR (Meteorological Aerodrome Report):] Consiste en un reporte observacional de las condiciones meteorológicas reales y presentes en el aeródromo. Se emite habitualmente en intervalos de 30 minutos (o 60 minutos según el aeródromo). Proporciona datos concisos sobre la dirección e intensidad del viento en superficie, #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") horizontal, nubosidad (cobertura y altitud de la #link(<glosario-base>)[base]#index("Tramo de base")), temperatura ambiental, temperatura del punto de rocío y reglaje altimétrico (#link(<glosario-qnh>)[QNH]#index("QNH")). Frecuentemente, el mensaje concluye con un segmento de pronóstico a corto plazo tipo #NormalTok("TREND"); válido para las 2 horas posteriores (o la indicación #NormalTok("NOSIG"); si no se prevén cambios significativos).
- #strong[TAF (Terminal Aerodrome Forecast):] Es el pronóstico oficial del aeródromo. Elaborado por oficinas meteorológicas, anticipa la evolución temporal de la meteorología en la terminal para periodos de validez estandarizados que abarcan habitualmente 9, 24 o 30 horas. Emplea sintaxis de códigos de evolución y probabilidad, fundamentales para la planificación, tales como #NormalTok("TEMPO"); (fluctuaciones temporales moderadas), #NormalTok("BECMG"); (cambio gradual permanente) o #NormalTok("PROB"); (probabilidad porcentual del suceso).

Resulta imperativo para la tripulación asimilar esta codificación con fluidez. Es de especial relevancia operativa interpretar indicadores como:

- CAVOK (Ceiling And Visibility OK): Indica condiciones #link(<glosario-vfr>)[VFR]#index("VFR") óptimas: visibilidad horizontal igual o superior a 10 km, ausencia de nubes operativas por debajo de 5.000 ft (o por debajo de la altitud mínima en sector más alta, la que sea mayor), y ausencia de #link(<glosario-cumulonimbus>)[Cb]#index("Cumulonimbus") o TCU (cúmulos de gran desarrollo) y de fenómenos meteorológicos significativos.
- #link(<glosario-nsc>)[NSC]#index("NSC") (No Significant Clouds): Ausencia de nubes por debajo de 5.000 ft y sin presencia de Cb ni TCU, aunque los criterios de visibilidad de CAVOK no se cumplan.
- Reducciones de visibilidad: Abreviaturas como #NormalTok("FG"); (#link(<glosario-niebla>)[Niebla]#index("Niebla") / #strong[Fog]) o #NormalTok("BR"); (Neblina / #strong[Mist]) denotan condiciones de operatividad VFR marginal o restrictiva, condicionando temporalmente los despegues.

=== Ejemplo práctico de decodificación METAR
<ejemplo-práctico-de-decodificación-metar>
Veamos un ejemplo típico en un día de vuelo, paso a paso:

- #strong[METAR]: Tipo de informe (observación regular).
- #strong[LEMD]: Aeródromo (en este caso, Madrid-Barajas).
- #strong[241100Z]: Día 24 del mes, a las 11:00 #link(<glosario-utc>)[UTC]#index("Hora Zulu") (hora Zulú).
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
- Los servicios asociados ---#strong[#link(<glosario-sigmet>)[SIGMET]#index("SIGMET")], #strong[#link(<glosario-airmet>)[AIRMET]#index("AIRMET")] y #strong[#link(<glosario-gamet>)[GAMET]#index("GAMET")]--- emiten alertas específicas: #link(<glosario-engelamiento>)[engelamiento]#index("Engelamiento") severo (#NormalTok("SEV ICE");), turbulencia severa (#NormalTok("SEV TURB");), o peligros en ruta a baja altura (por debajo de FL100 ó FL150, que es donde volamos nosotros). Antes de un vuelo de distancia, revisar los SIGMET activos es obligatorio.

#figure([
#box(image("03-meteorologia/imagenes/03-cap10-sigwx.png"))
], caption: figure.caption(
position: bottom, 
[
Ejemplo de mapa de tiempo significativo (SIGWX) para niveles bajos.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-03-cap10-sigwx>


#mas-alla[
== Sondeos termodinámicos y curvas de temperatura
<sondeos-termodinámicos-y-curvas-de-temperatura>
#mas-alla-tag[#strong[↗ MÁS ALLÁ DEL EXAMEN.]] Los sondeos #link(<glosario-sondeo-termodinamico>)[Skew-T]#index("Sondeo termodinámico") y los índices que se calculan sobre ellos (K, #link(<glosario-cape>)[CAPE]#index("CAPE"), #link(<glosario-li>)[LI]#index("Lifted Index")) son formación de vuelo de distancia y no deberían ser materia de examen. Léelos como iniciación al cross-country.

El sondeo termodinámico es la radiografía del día: muestra cómo cambia la temperatura y la humedad con la altura en un punto #link(<glosario-norte-verdadero>)[geográfico]#index("Norte verdadero") dado. Se presenta en diagramas #strong[Skew-T log-P] o #strong[Stüve], accesibles gratuitamente a través de la Universidad de Wyoming, AEMET (#link(<glosario-ama>)[AMA]#index("AMA")), Windy o Meteoblue, y también integrados en plataformas de pago especializadas como Skysight, Topmeteo o Meteo Parapente. Aprender a leer un sondeo te ahorrará remolques innecesarios y te avisa de las tormentas antes de que sean visibles desde el suelo (#ref(<fig-03-cap10-indices-estabilidad>, supplement: [Figura])).

#figure([
#box(image("03-meteorologia/imagenes/03-cap03-indices-estabilidad.jpg"))
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

+ #strong[Base de los cúmulos (#link(<glosario-lcl>)[LCL]#index("LCL")):] La curva de estado y la curva del punto de rocío se cruzan a una altura: esa es la base de los cúmulos del día. Si el cruce está muy alto (\> 3.000 m), los cúmulos serán escasos o no llegarán a formarse: #link(<glosario-termica>)[térmica]#index("Térmica") seca, sin calle de nubes.
+ #strong[Techo térmico:] Traza la adiabática seca desde la temperatura máxima prevista. Donde esa línea vuelva a cruzar la curva de estado es el techo de las térmicas. Si ese techo sube hasta la #strong[curva de estado] muy por encima de la base, el día tendrá térmicas potentes; si el cruce es bajo, el vuelo térmico será débil.
+ #strong[Riesgo de sobredesarrollo (Cb):] Si la curva de estado se vuelve muy inestable por encima del nivel de condensación (#link(<glosario-lfc>)[LFC]#index("LFC"), #strong[Level of Free Convection]), los cúmulos del mediodía pueden convertirse en cumulonimbos por la tarde. Un CAPE por encima de 2.500 J/kg combinado con un #link(<glosario-k-index>)[K-Index]#index("índice K") por encima de 25 es la firma del día que puede acabar mal.

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
#postit[
#strong[Resumen del capítulo: información meteorológica]

- #strong[METAR y TAF]: Tus boletines de cabecera. METAR = foto actual (cada 30 min). TAF = pronóstico (para 9, 24 o 30h). Aprende a descodificarlos fluidamente (CAVOK indica visibilidad ≥10 km y sin nubes por debajo de 5000 ft; FG indica niebla; BR neblina).
- #strong[Mapas Significativos (SIGWX)]: Muestran frentes, zonas de turbulencia y engelamiento. Cruciales para planificar rutas largas.
- #strong[Toma de decisiones]: No te fíes de una sola fuente. Cruza datos: mapa de superficie + satélite + previsión local. Si la meteo pinta dudosa, el mejor vuelo es el que se queda en tierra (no-go).

]
#part[Parte 04: Comunicaciones]
= Definiciones
<definiciones>
#quote(block: true)[
En este capítulo aprenderás el lenguaje que se usa en la radio aeronáutica: qué es la #link(<glosario-colacion>)[colación]#index("Colación") y por qué no es opcional, cómo funciona la fraseología estándar, las reglas para decir números, horas y frecuencias, cómo manejar bien la disciplina de radio y cómo identificarte correctamente ante los servicios de tránsito aéreo.
]

== Introducción a las comunicaciones aeronáuticas
<introducción-a-las-comunicaciones-aeronáuticas>
La radio es el canal principal entre tú y los servicios de tránsito aéreo. Todo lo que ocurre en el #link(<glosario-espacio-aereo-controlado>)[espacio aéreo controlado]#index("Espacio aéreo controlado") pasa por ahí, en tiempo real. La regulación no es cosa de cada país: el #strong[Anexo 10 al Convenio sobre Aviación Civil Internacional] de la #link(<glosario-oaci>)[OACI]#index("OACI") (#emph[International Civil Aviation Organization]) fija los estándares técnicos y procedimentales que todos los Estados miembro aplican.

Las comunicaciones de voz van en la banda de #link(<glosario-vhf>)[VHF]#index("VHF") (#emph[Very High Frequency]), entre #strong[118 MHz y 136,975 MHz], con modulación de amplitud (AM). Las ondas VHF no doblan el horizonte: su alcance depende de la línea de visión (#emph[line of sight]), así que cuanto más alto vueles, más lejos llegas. En zonas montañosas o a baja altura puede que necesites un #strong[relay], otra estación que retransmita tu mensaje. El espaciado de canales en Europa es #strong[8,33 kHz] (la parte técnica y la normativa están en el capítulo 9).

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
Hablar por radio con el #link(<glosario-atc>)[ATC]#index("ATC") no es una conversación. Es un procedimiento, y tiene sus reglas. La más importante es la #strong[colación] (#strong[readback]): repetir al controlador sus propias palabras, exactamente como las dijo.

¿Por qué? Porque es la única forma que tiene el Controlador de Tráfico Aéreo (#emph[Air Traffic Controller], ATC) de saber que recibiste la instrucción correctamente. Si no escucha tu colación, no sabe si llegaste, si entendiste, o si captaste algo diferente.

Por normativa de la OACI (Anexo 10) y del #link(<glosario-sera>)[SERA]#index("SERA") (#emph[Standardised European Rules of the Air]), es #strong[obligatorio] colacionar:

- Todas las autorizaciones y permisos (despegues, aterrizajes, cruces de pista).
- Instrucciones de rumbo, velocidad, altitud o #link(<glosario-fl>)[nivel de vuelo]#index("Nivel de vuelo").
- La pista en servicio (#strong[runway in use]).
- El ajuste del altímetro (#strong[#link(<glosario-qnh>)[QNH]#index("QNH")] o #link(<glosario-qfe>)[QFE]#index("QFE")). A un QNH nunca se responde con «Recibido»: repites el valor numérico, sin excepción.
- El código del #link(<glosario-transpondedor>)[transpondedor]#index("Transpondedor") (#strong[#link(<glosario-squawk>)[squawk]#index("Squawk") code]), cuando el ATC te asigne uno.
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

- #strong[Afirma]: «Sí», «El permiso ha sido concedido» o «Es correcto». Es la palabra normalizada en español por la fraseología oficial (Guía de fraseología y comunicaciones de #link(<glosario-aesa>)[AESA]#index("AESA")), equivalente del #strong[AFFIRM] inglés: la OACI lo acortó desde #strong[Affirmative] precisamente para que no se confundiera con #strong[Negative] cuando hay ruido en la frecuencia. En la práctica oirás también «Afirmo»; lo que hay que evitar siempre es «Afirmativo».
- #strong[Negativo]: «No», «El permiso no ha sido concedido» o «Incorrecto».
- #strong[Wilco] (#strong[Will comply]): «Entendido, actuaré en consecuencia». Lo usas cuando recibes una instrucción larga que no exige readback obligatorio.
- #strong[Solicito]: Para pedir una autorización, un servicio o información. Por ejemplo: «Solicito autorización de rodaje».
- #strong[Recibido] (#strong[Roger]): «He recibido tu transmisión». Ojo: no es una respuesta a una pregunta, y no sustituye a una colación cuando esta es obligatoria.

#block[
#callout(
body: 
[
La frecuencia de radio es un recurso compartido. Un mensaje breve, preciso y sin vacilaciones libera la frecuencia para otros tráficos y para emergencias. Planifique el mensaje antes de pulsar el #link(<glosario-ptt>)[PTT]#index("PTT"): quién llama, a quién, qué necesita.

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
#box(image("04-comunicaciones/imagenes/04-cap01-disciplina-radio.jpg"))
], caption: figure.caption(
position: bottom, 
[
Pulsa el PTT (#emph[Push-to-Talk]) de la palanca y espera un segundo antes de hablar; habla con un volumen normal y mantén el micrófono cerca de la boca sin tocarla. Cuando termines, suelta el PTT y asegúrate de que ya no estás emitiendo (se apagará el indicador #emph[TX]).
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
En aviación la hora es siempre #strong[#link(<glosario-utc>)[UTC]#index("Hora Zulu")] (#emph[Coordinated Universal Time]), también llamada Zulú. Si no hay riesgo de confusión, basta transmitir los minutos. Si puede haber ambigüedad, usas los cuatro dígitos:

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

+ #strong[Piensa]: Antes de pulsar, organiza mentalmente lo que vas a decir. Anótalo si hace falta. Los mensajes llenos de «ehm…​» y pausas bloquean la frecuencia. Si ya presentaste un plan de vuelo #link(<glosario-vfr>)[VFR]#index("VFR"), no repitas datos que el controlador ya tiene salvo que te los pida.
+ #strong[Escucha]: Sintoniza la frecuencia y escucha unos segundos antes de transmitir. No interrumpas ni «pises» una transmisión en curso. Si hay tráfico activo, espera tu turno.
+ #strong[Pulsa y cuenta uno]: Pulsa el botón de PTT (#emph[Push-To-Talk]) un segundo #strong[antes] de hablar (#ref(<fig-04-cap01-microfono>, supplement: [Figura])). Así la primera sílaba no se corta mientras el transmisor abre la portadora.
+ #strong[Habla]: Claro, constante, sin prisas. Menos de 100 palabras por minuto, volumen uniforme. Cuando termines, suelta el PTT de inmediato.

#block[
#callout(
body: 
[
Para verificar la calidad de la señal de radio, utilice la #link(<glosario-escala>)[escala]#index("Escala") normalizada del 1 (ilegible) al 5 (perfectamente legible). La prueba de radio no debe superar los 10 segundos. Si no obtiene respuesta tras la primera llamada a una torre, espere un mínimo de 10 segundos antes de reintentar, para no interferir con otras gestiones del controlador.

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
Tu indicativo (#strong[callsign]) es tu nombre en el espacio aéreo. El ATC necesita saber en todo #link(<glosario-momento>)[momento]#index("Momento") con quién habla. Nunca transmitas sin identificarte, y nunca uses un indicativo que no sea el tuyo.

En planeadores, el indicativo es la matrícula asignada por la autoridad de registro. Las matrículas civiles siguen el esquema OACI de prefijos nacionales: en España es #strong[EC-] seguido de tres letras, por ejemplo «EC-DPE». Alemania usa «D-», Francia «F-». Hay combinaciones prohibidas porque pueden confundirse con señales de socorro o urgencia internacionales (SOS, PAN, MAY).

Cómo identificarte:

- #strong[Primer contacto]: Matrícula completa, deletreada con el alfabeto fonético OACI. «#emph[Eco Charlie Delta Papa Eco]».
- #strong[Matrícula abreviada]: En contactos posteriores puedes usar la primera letra del prefijo nacional más las dos últimas letras de la matrícula. «#emph[Eco Papa Eco]».
- #strong[Quién abre la puerta]: Solo puedes abreviar si la dependencia ya usó la matrícula abreviada al dirigirse a ti. Hasta entonces, indicativo completo siempre.

Añade siempre tu indicativo al #link(<glosario-final>)[final]#index("Tramo final") de cada colación. Así el controlador confirma que la instrucción la recibió la aeronave correcta, no otra que también escuchó.

#figure([
#table(
  columns: 6,
  align: (auto,auto,auto,auto,auto,auto,),
  table.header([Letra], [Palabra], [Letra], [Palabra], [Letra], [Palabra],),
  table.hline(),
  [A], [Alfa], [J], [Juliett], [S], [Sierra],
  [B], [Bravo], [K], [Kilo], [T], [Tango],
  [C], [Charlie], [L], [Lima], [U], [Uniform],
  [#link(<glosario-zonas-p>)[D]#index("Zonas P")], [Delta], [M], [Mike], [V], [Victor],
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
#strong[Resumen del capítulo: definiciones y técnica]

- #strong[Introducción]: Las comunicaciones aeronáuticas de voz se realizan en VHF (118--136,975 MHz), reguladas por el Anexo 10 de la OACI. El espaciado de canales en Europa es de 8,33 kHz (Reglamento UE 1079/2012). La estación en tierra es la «estación aeronáutica»; el piloto opera desde la «estación de aeronave».
- #strong[La colación (readback)]: Repetir textualmente las instrucciones del ATC es obligatorio para: autorizaciones, rumbos/altitudes, pista en uso, QNH, cambios de frecuencia, transferencias ATC y código de transpondedor cuando sea asignado.
- #strong[Fraseología estándar]: La radio no admite lenguaje coloquial. Términos clave: #strong[Afirma], #strong[Negativo], #strong[Wilco], #strong[Solicito], #strong[Recibido]. «Recibido» nunca sustituye a una colación obligatoria, y «Afirmativo» se evita siempre.
- #strong[Disciplina de radio]: Piensa → Escucha → Pulsa y cuenta uno → Habla. Menos de 100 palabras por minuto, mensaje preparado antes de pulsar el PTT.
- #strong[Transmisión de números, horas y frecuencias]: Números dígito a dígito («#emph[tres cuatro]», nunca «treinta y cuatro»); centenas y miles exactos como unidades («#emph[dos mil seiscientos]»). Horas en UTC, normalmente solo los minutos. Frecuencias con «coma»: «#emph[uno dos cuatro coma cuatro cero]». Colaciona siempre el nuevo canal antes de cambiar.
- #strong[Identificación]: La matrícula es el nombre de la aeronave. Primer contacto: matrícula completa en fonético. Matrícula abreviada: solo cuando la torre la use primero.

]
= Comunicaciones VFR
<comunicaciones-vfr>
#quote(block: true)[
Volar en #link(<glosario-vfr>)[VFR]#index("VFR") te pone en tres escenarios muy distintos, y en cada uno la radio se usa de otra manera. En un campo sin torre eres tú quien canta y quien mira. En uno controlado no te mueves sin que te lo autoricen. Y en ruta, el que te habla te informa, pero no te separa. Este capítulo recorre los tres.
]

== Comunicaciones VFR en aeródromos no controlados
<comunicaciones-vfr-en-aeródromos-no-controlados>
=== Autoinformación en aeródromos sin torre de control
<autoinformación-en-aeródromos-sin-torre-de-control>
#emph[En el campo sin torre, el piloto actúa como su propio controlador.]

La mayoría de los aeródromos desde los que vuelan los planeadores ---aeroclubs, pistas forestales, aeródromos privados--- son #strong[aeródromos no controlados]. Operan en espacio aéreo Clase G y no hay ninguna torre de Control de Tráfico Aéreo (#link(<glosario-atc>)[ATC]#index("ATC")) que te autorice, te separe o te asigne rumbos.

Aquí la seguridad la pone la #strong[#link(<glosario-autoinformacion>)[autoinformación]#index("Autoinformación")] (#strong[broadcast]): tú transmites tu posición, altitud e intenciones a la frecuencia del campo para que todos sepan dónde estás. Nadie te va a dar permiso para despegar ni aterrizar. Informas y tú decides.

Dos cosas básicas:

- #strong[A quién llamas]: Al nombre del aeródromo, no a «Torre». #emph[«Fuentemilanos, buenos días…​»] o #emph[«Santa Cilia, tráfico…​»]
- #strong[Qué dices]: Indicativo, posición, altitud e intención. #emph[«…​velero Eco Papa Eco, a 5 minutos al este del campo a 1.500 metros, notificaré entrando al circuito.»]

#block[
#callout(
body: 
[
Aunque en algunos campos exista un operador de radio prestando un servicio #link(<glosario-afis>)[AFIS]#index("AFIS") (#strong[Aerodrome Flight Information Service]), este operador #strong[no proporciona control], solo información (viento, pista en uso, meteorología). La decisión #link(<glosario-final>)[final]#index("Tramo final") y la responsabilidad de la separación siguen siendo íntegramente del #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando").

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
=== Ver y evitar (#emph[See and Avoid])
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
Un error fatal es iniciar un viraje (por ejemplo, de tramo #link(<glosario-base>)[base]#index("Tramo de base") a final) confiando únicamente en que "nadie ha cantado posición por la radio". Asegúrate siempre visualmente de que la pista y la aproximación final están libres de tráfico antes de virar.

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
#box(image("04-comunicaciones/imagenes/04-cap02-frecuencia-correcta.jpg"))
], caption: figure.caption(
position: bottom, 
[
Escucha activa de la frecuencia antes de la llegada: A lo largo del tiempo ha ido escuchando los eventos 1, 2, 3, etc.
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap02-escucha-previa>


=== La frecuencia correcta y el momento adecuado
<la-frecuencia-correcta-y-el-momento-adecuado>
Al aproximarte a cualquier aeródromo, controlado o no, sintoniza la frecuencia del campo #strong[al menos 10 minutos o 10 millas antes] de llegar. Y luego escucha antes de abrir la boca.

Con solo escuchar unos minutos puedes deducir (#ref(<fig-04-cap02-escucha-previa>, supplement: [Figura])):

- #strong[Pista en servicio]: Las notificaciones de otros tráficos te lo dicen sin preguntar.
- #strong[Viento]: Otros pilotos suelen comentarlo en base o en final.
- #strong[Densidad de tráfico]: Sabrás cuántos aviones hay en el circuito, si hay remolcadores activos o veleros termando cerca.

Cuando ya tienes esa imagen mental, pulsa el #link(<glosario-ptt>)[PTT]#index("PTT"). Tu primera llamada llegará con datos concretos, sin que nadie tenga que repetirte lo que ya podías haber escuchado.

=== El circuito estándar y sus notificaciones
<el-circuito-estándar-y-sus-notificaciones>
El #strong[circuito de tránsito] (#strong[traffic pattern]) es el patrón rectangular que organiza el tráfico alrededor del aeródromo. Sin él, cada piloto llegaría como le pareciera.

Salvo que la carta de aproximación visual (#emph[#link(<glosario-vac>)[VAC]#index("VAC")]) del aeródromo indique otra cosa, por obstáculos o restricciones de ruido, el circuito estándar #link(<glosario-oaci>)[ICAO]#index("OACI")/#link(<glosario-easa>)[EASA]#index("EASA") #strong[es siempre a izquierdas]. El motivo es práctico: en aviones convencionales el comandante se sienta a la izquierda, y en planeadores en tándem la #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") hacia ese lado suele ser mejor. Con el circuito a izquierdas, la pista queda siempre a la vista.

Las notificaciones que haces durante el circuito son estas:

+ #strong[Entrada al circuito]: Avisa antes de entrar a las inmediaciones. #emph["Fuentemilanos, Eco Papa Eco, a tres minutos, notificaré entrando en circuito"].
+ #strong[#link(<glosario-viento-en-cola>)[Viento en cola]#index("Viento en cola")] (#strong[Downwind]): El tramo paralelo a la pista pero en sentido contrario al aterrizaje. A la altura de los números de pista o a mitad del tramo, cantas: #emph["Fuentemilanos, Eco Papa Eco, viento en cola pista 16"]. En planeador, esta notificación tiene que hacerse desde una posición que te garantice llegar a la pista planeando.
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
Según el Reglamento #link(<glosario-sera>)[SERA]#index("SERA") (artículo SERA.3210), el orden de prioridad de paso ---de mayor a menor--- es: globos \> planeadores \> dirigibles \> aeronaves con motor. El planeador tiene prioridad sobre todo aerodino propulsado por motor y #strong[cede el paso a los globos]. Esta prioridad aplica en vuelo y en las inmediaciones del aeródromo; nunca justifica descuidar la vigilancia visual activa.

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
=== Coordinación con el remolcador y el torno
<coordinación-con-el-remolcador-y-el-torno>
El lanzamiento no tiene equivalente en ningún otro tipo de aviación: tu despegue depende de coordinar con alguien que está fuera de la aeronave. Hacerlo bien marca la diferencia.

==== Lanzamiento con torno (#emph[winch launch])
<lanzamiento-con-torno-winch-launch>
Si el campo tiene radio tierra-aire con el #link(<glosario-torno>)[torno]#index("Torno"), la secuencia es:

+ #link(<glosario-cupula>)[Cúpula]#index("Cúpula") cerrada, aeronave lista. Transmites:

#emph[«Torno, velero EC-DPE, doble mando, listo para tensar.»] 2. El operador tensa suavemente. #link(<glosario-aerofrenos>)[Aerofrenos]#index("Aerofrenos") replegados, alas niveladas, confirmas:

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
Si el cable se rompe o el torno falla, baja el morro de inmediato para recuperar velocidad. A baja altura ---por debajo de unos #strong[150 m #link(<glosario-agl>)[AGL]#index("AGL")] en torno--- no vires: aterriza recto al frente en el terreno disponible. Intentar regresar a la pista de origen a baja altura es la causa más frecuente de accidentes mortales en lanzamiento con torno. Las franjas de decisión completas por altura (recto al frente, circuito abreviado o circuito normal) se desarrollan en el #strong[Libro 6 --- Procedimientos operativos], capítulo 7.

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
==== Lanzamiento con remolcador (#emph[aerotow])
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
== Comunicaciones VFR en aeródromos controlados
<comunicaciones-vfr-en-aeródromos-controlados>
=== Autorización (#emph[Clearance]) en espacio controlado
<autorización-clearance-en-espacio-controlado>
Un #strong[aeródromo controlado] tiene Torre de Control (#link(<glosario-twr>)[TWR]#index("TWR")), y eso cambia las reglas por completo: aquí no das un paso sin autorización explícita.

En #link(<glosario-espacio-aereo-controlado>)[espacio aéreo controlado]#index("Espacio aéreo controlado") como un #link(<glosario-ctr>)[CTR]#index("Zona de control"), solo el controlador puede emitir instrucciones y separar el tráfico. Tú necesitas una #strong[autorización] (#strong[clearance]) para cada fase:

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
=== El plan de vuelo (FPL)
<el-plan-de-vuelo-fpl>
Para entrar en espacio aéreo donde se te presta servicio de control ---clases B, C y #link(<glosario-zonas-p>)[D]#index("Zonas P"), o cualquier aeródromo controlado--- tienes que presentar un #strong[Plan de Vuelo (#link(<glosario-fpl>)[FPL]#index("FPL"))] ante los servicios #link(<glosario-ats>)[ATS]#index("ATS") correspondientes, con la antelación respecto a la hora estimada de salida (#link(<glosario-eobt>)[EOBT]#index("EOBT")) que fijan el #link(<glosario-aip>)[AIP]#index("AIP")-España y la VAC del aeródromo. La clase E es la excepción dentro del espacio controlado: al VFR no se le presta allí servicio de control, así que no necesita plan de vuelo, ni radio, ni autorización (SERA.4001 b)).

El planeador vuela casi siempre en Clase G. Pero si necesitas cruzar un CTR o entrar donde te controlen, presenta el FPL con tiempo. Los plazos y formatos están en el AIP-España (ENR 1.10) y son vinculantes, así que consúltalos antes de cada vuelo que implique espacio controlado.

#block[
#callout(
body: 
[
Si surge la necesidad imprevista de entrar en espacio controlado sin plan de vuelo previo, es posible abrirlo en el aire (#link(<glosario-afil>)[AFIL]#index("AFIL") --- Airborne Flight Plan) contactando por radio a la dependencia ATC y facilitando tipo de aeronave, posición, intenciones y tiempos estimados. Esta opción depende de la disponibilidad del servicio y de la carga de trabajo del controlador.

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
#box(image("04-comunicaciones/imagenes/04-cap02-puntos-notificacion.jpg"))
], caption: figure.caption(
position: bottom, 
[
Puntos de notificación visual (VFR) en un CTR
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap02-puntos-notificacion>


=== Puntos de notificación visual
<puntos-de-notificación-visual>
El CTR (#emph[Control Zone]) protege las llegadas y salidas #link(<glosario-ifr>)[IFR]#index("IFR"). No lo confundas con la #link(<glosario-atz>)[ATZ]#index("ATZ") (#emph[Aerodrome Traffic Zone]), que es un espacio aéreo distinto y más pequeño. Para no meterte en medio del tráfico IFR, el vuelo VFR entra y sale del CTR por rutas y puntos fijos (#ref(<fig-04-cap02-puntos-notificacion>, supplement: [Figura])).

Esos son los #strong[puntos de notificación visual]: referencias físicas en el terreno ---un pueblo, un cruce de autopista, un lago--- por las que pasas y desde las que llamas a la Torre. Los encontrarás en la Carta de Aproximación Visual (VAC) del aeródromo, normalmente nombrados con letras fonéticas según su orientación geográfica: Noviembre para el norte, Sierra para el sur, Eco para el este.

Llama a la Torre entre 3 y 5 minutos antes de llegar al punto de entrada al CTR:

#emph[---"Jerez Torre, EC-DPE, sobre punto Sierra a 1000 pies, para entrar en zona y aterrizar."] #emph[---"EC-DPE, recibido, autorizado a entrar en zona por punto Sierra a 1000 pies o inferior, notifique viento en cola derecha pista 02."]

Desde ese #link(<glosario-momento>)[momento]#index("Momento") sigues las instrucciones de la Torre en altitud y ruta. Nada de improvisar.

=== Colacionar todo en espacio controlado
<colacionar-todo-en-espacio-controlado>
Ya lo vimos en el capítulo 1: la #strong[#link(<glosario-colacion>)[colación]#index("Colación")] (#strong[readback]) no es opcional. En espacio controlado lo es todavía menos, porque el controlador separa el tráfico basándose en que tú vas a hacer exactamente lo que has repetido.

Cualquier instrucción del ATC que afecte a tu trayectoria, pista activa, ajuste de presión o identificación de radar #strong[la colacionas] palabra por palabra, y cierras con tu indicativo.

Si la Torre dice: #emph["Eco Papa Eco, autorizado a aterrizar pista 36."]

Tu colación es: #emph["Autorizado a aterrizar pista 36, Eco Papa Eco."] El viento no hace falta colacionarlo, pero la autorización de pista sí.

#block[
#callout(
body: 
[
Cuando anotes mentalmente o en tu pernera la instrucción dada por un controlador, si se compone de autorización de pista de aterrizaje o despegue, rumbo o altitud a mantener, #link(<glosario-qnh>)[QNH]#index("QNH"), o el código del #link(<glosario-transpondedor>)[transpondedor]#index("Transpondedor"), tu respuesta por radio #strong[NO puede ser "Wilco"] o #strong["Copiado"]. Debes recitar esos parámetros tal y como te los han dado.

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
=== Ejercicios de fraseología
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

== Comunicaciones VFR con ATC (en ruta)
<comunicaciones-vfr-con-atc-en-ruta>
=== Servicio de información de vuelo (FIS)
<servicio-de-información-de-vuelo-fis-1>
En ruta por espacio aéreo no controlado ---Clase G en su mayor parte--- no hay ninguna Torre mirándote. Pero tienes una herramienta útil: el #strong[Servicio de Información de Vuelo (#link(<glosario-fis>)[FIS]#index("FIS"))] (#emph[Flight Information Service]).

Lo más importante que tienes que saber sobre el FIS: te da #strong[asesoramiento, no control]. No te va a dar rumbos obligatorios ni altitudes que tengas que seguir. Su trabajo es darte información para que tú, como piloto al mando, decidas. La separación sigue siendo tuya.

Lo que puedes pedirle o recibir:

- #strong[Información de tráfico]: Te avisarán de aeronaves conocidas cerca de tu posición o ruta. (En Estados Unidos a esto lo llaman #strong[Flight Following]\; en Europa bajo SERA/EASA es oficialmente el FIS).
- #strong[Meteorología]: #link(<glosario-metar>)[METAR]#index("METAR"), #link(<glosario-taf>)[TAF]#index("TAF"), alertas #link(<glosario-sigmet>)[SIGMET]#index("SIGMET") o #link(<glosario-airmet>)[AIRMET]#index("AIRMET") en ruta o en tus aeródromos de destino y alternativo.
- #strong[Estado de espacios aéreos]: Zonas restringidas, peligrosas o militares activadas o desactivadas.

Para contactar, sintoniza la frecuencia de "Información" de tu zona (#strong[Madrid Información], #strong[Zaragoza Información]…) e identifícate con tu indicativo, tipo de aeronave, posición, ruta y lo que necesitas:

#emph["Madrid Información, velero EC-DPE, sobre la sierra de Ayllón a 2000 metros, rumbo sur hacia Fuentemilanos, solicito información de tráfico."]

#block[
#callout(
body: 
[
En travesías de vuelo a vela (#strong[cross-country]), mantener la escucha en la frecuencia del FIS regional correspondiente proporciona una capa adicional de seguridad, especialmente en días con desarrollo tormentoso donde la información meteorológica en tiempo real es crítica. Además, estar en contacto con el FIS acelera la activación de los servicios de Búsqueda y Salvamento (#link(<glosario-sar>)[SAR]#index("SAR")) ante una toma en campo fuera de aeródromo.

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
=== Cambio y abandono de frecuencia
<cambio-y-abandono-de-frecuencia>
No desaparezcas de una frecuencia sin decir nada. El controlador de Torre, Aproximación o Información te tiene en pantalla o en su ficha de vuelo, y da por hecho que sigues a la escucha. Si te esfumas, empieza a preocuparse.

Cuando necesites cambiar de frecuencia, hay dos casos (#ref(<fig-04-cap02-cambio-frecuencia>, supplement: [Figura])):

- #strong[Si estás bajo control ATC]: Pide permiso. #emph["Torre, EC-DPE, solicito abandonar frecuencia para pasar a operaciones de club en 123.400"].
- #strong[Si estás en frecuencia de Información (FIS)]: No es control, así que solo avisas. #emph["Madrid Información, EC-DPE, abandonamos su frecuencia para pasar con Fuentemilanos 123.500. Buen día"].

#figure([
#box(image("04-comunicaciones/imagenes/04-cap02-cambio-frecuencia.jpg"))
], caption: figure.caption(
position: bottom, 
[
Transición ordenada entre dependencias y frecuencias
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap02-cambio-frecuencia>


=== El transpondedor en ruta: código #emph[squawk]
<el-transpondedor-en-ruta-código-squawk>
Si tu planeador tiene #strong[transpondedor], emite un código de cuatro dígitos (#emph[#link(<glosario-squawk>)[squawk]#index("Squawk")]) que el ATC usa para identificarte en pantalla. En VFR, el código por defecto es #strong[7000], salvo que el ATC te asigne uno distinto. Los códigos de emergencia los encontrarás en el capítulo 9.

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
=== Zonas de radio obligatoria (RMZ)
<zonas-de-radio-obligatoria-rmz>
Algunos sectores de clase E, F o G llevan una obligación adicional: son #strong[Zonas de Radio Obligatoria (#link(<glosario-rmz>)[RMZ]#index("RMZ"))] (#emph[Radio Mandatory Zone]). Dentro de una RMZ la radio no es optativa aunque el espacio aéreo no sea controlado; es una obligación publicada en el AIP.

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
#strong[Resumen del capítulo: comunicaciones VFR]

#strong[En aeródromos no controlados]

- #strong[Autoinformación]: En el campo sin torre, tú eres el controlador. Transmite «al aire» tu posición e intenciones. «Fuentemilanos, velero EC-BRT, viento en cola pista 34».
- #strong[Ver y Evitar]: La radio ayuda, pero tus ojos mandan. No asumas que todos tienen radio o te han escuchado. Busca activamente otros tráficos.
- #strong[La Frecuencia Correcta]: Sintoniza la frecuencia del campo 10 minutos antes. Escuchar a otros te dirá pista en uso, viento y densidad de tráfico.
- #strong[Circuito Estándar]: Si nadie indica lo contrario, el circuito es a izquierdas. Notifica: entrada, viento en cola, base y final.
- #strong[Lanzamiento (torno/remolcador)]: Con torno: «Listo tensando» → «Remolcando x3» → «Cable libre». Abortar: «Stop torno x3». Fallo bajo (por debajo de 150 m en torno): recto al frente, nunca regreses virando.

#strong[En aeródromos controlados]

- #strong[Autorización (Clearance)]: En espacio controlado, la palabra de la Torre es ley. Necesitas autorización explícita para todo: arrancar, rodar, despegar, entrar en zona. Si no oyes «autorizado», no te muevas.
- #strong[Plan de Vuelo (FPL)]: Tu billete de entrada. Preséntalo con al menos 60 minutos de antelación; los plazos exactos, en el AIP-España ENR 1.10.
- #strong[Puntos de Notificación]: Son las puertas de entrada/salida visual al CTR (Sierra, Norte, Eco…​). Conócelos bien en la carta VAC y notifica sobre ellos con precisión.
- #strong[Colacionar Todo]: En controlado es vital. Repite cada instrucción, sin el viento y con tu indicativo al final. «Autorizado a aterrizar pista 36, Eco Papa Eco».

#strong[Con ATC, en ruta]

- #strong[Servicio de Información de Vuelo (FIS)]: Es un servicio de asesoramiento, no de control. Te informan sobre tráficos y meteorología (si tienen carga de trabajo), pero la separación sigue siendo tu responsabilidad. "Para información, contacto con Madrid Información…​".
- #strong[Cambio de Frecuencia]: Nunca te "esfumes" de una frecuencia controlada o de información. Solicita el cambio o avisa de que abandonas la frecuencia. "Madrid, EC-DPE para pasar a frecuencia de club 123.500".
- #strong[Transpondedor en ruta]: Si dispones de transpondedor, código VFR por defecto: #strong[7000]. Emergencias: #strong[7700] (emergencia activa --- #strong[Mayday]) y #strong[7600] (fallo de radio --- ver cap. 7). Solo usar ante la emergencia real.

]
= Procedimientos operativos generales
<procedimientos-operativos-generales>
#quote(block: true)[
Aquí están los procedimientos que usarás en cada vuelo: cómo estructurar una llamada, cuándo pedir una prueba de radio, cómo hacer un reporte de posición, qué hacer cuando dos aeronaves transmiten a la vez, el #link(<glosario-ptt>)[PTT]#index("PTT") atascado, la prioridad de los mensajes de emergencia, cómo usar bien el micrófono y qué tipos de radio existen.
]

== Esquema de las comunicaciones
<esquema-de-las-comunicaciones>
Toda transmisión aeronáutica sigue el mismo patrón. Memorizarlo como secuencia fija te libera para concentrarte en volar.

La llamada inicial va siempre en este orden:

+ #strong[A quién se llama]: nombre de la dependencia («Jerez Torre», «Madrid Información»).
+ #strong[Quién llama]: indicativo completo de la aeronave («Eco Charlie Delta Papa Eco»).
+ #strong[Dónde está]: posición o fase del vuelo («sobre punto Sierra», «en #link(<glosario-viento-en-cola>)[viento en cola]#index("Viento en cola") pista tres cuatro»).
+ #strong[Qué necesita]: solicitud o intención («solicito datos», «listo para el despegue»).

#emph[Ejemplo de primera llamada en aeródromo controlado:] #emph[--- «Sabadell Torre, Delta Kilo India Alfa Victor, en punto de espera pista uno dos, listo para salida.»]

El controlador responde. A partir del segundo intercambio puedes abreviar el indicativo a las tres últimas letras, pero solo si la dependencia lo ha iniciado primero.

Al #strong[colacionar] una instrucción, el indicativo va al #link(<glosario-final>)[final]#index("Tramo final"):

#emph[--- «Autorizado despegar pista uno dos, viento cero nueve cero grados seis nudos, Alfa Victor.»]

En #strong[#link(<glosario-autoinformacion>)[autoinformación]#index("Autoinformación")] (aeródromo no controlado), sin interlocutor designado, el indicativo va al principio:

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
Algunos instructores recomiendan abrir la #strong[primera] comunicación con una estación con un simple #emph[«buenos días»] o #emph[«buenas tardes»] antes del mensaje: #emph[«Fuentemilanos tráfico, buenos días, Eco Charlie Delta Papa Eco…»]. No forma parte de la fraseología #link(<glosario-oaci>)[OACI]#index("OACI") ---que busca economía de palabras--- y por eso se reservaría al #strong[primer contacto], no a cada transmisión; pero al otro lado de la radio hay una persona, y ese saludo engrasa la relación con la torre, el #link(<glosario-fis>)[FIS]#index("FIS") o el resto de tráficos de tu campo. Con una salvedad: en frecuencia saturada o en una emergencia, la cortesía sobra y vas directo al grano.

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

La calidad de la recepción se evalúa con una #link(<glosario-escala>)[escala]#index("Escala") de legibilidad del 1 al 5:

- #strong[1:] Ilegible (audio incomprensible o portadora pura).
- #strong[2:] Legible de vez en cuando (muy entrecortado).
- #strong[3:] Legible con dificultad (ruido de fondo muy alto, pero se entiende).
- #strong[4:] Legible (buena calidad, leve ruido).
- #strong[5:] Perfectamente legible (audio nítido, sin ruidos).

#strong[Ejemplo de comunicación:] #emph[---"Fuentemilanos, buenas tardes, Eco Charlie Delta Papa Eco, solicito prueba de radio en 123.400."] #emph[---"Eco Papa Eco, le recibo 5."] #emph[---"Cinco, gracias, Eco Papa Eco."]

La prueba no debe durar más de 10 segundos. Normalmente basta con pronunciar los números lenta y claramente.

== Reportes de posición
<reportes-de-posición>
Un reporte de posición (#strong[position report]) le dice al #link(<glosario-atc>)[ATC]#index("ATC") o a otras aeronaves dónde estás. Lo emites al pasar por puntos de notificación obligatoria, cuando el FIS te lo pide o como actualización espontánea en travesía.

La estructura mínima tiene tres elementos:

+ #strong[Identificativo] de la aeronave.
+ #strong[Posición]: punto de notificación, localidad o referencia geográfica reconocible.
+ #strong[Altitud o #link(<glosario-fl>)[nivel de vuelo]#index("Nivel de vuelo")] con referencia altimétrica (#link(<glosario-qnh>)[QNH]#index("QNH") o FL).

Si el FIS o el ATC lo requieren, añades:

+ #strong[Hora #link(<glosario-utc>)[UTC]#index("Hora Zulu")] de paso por el punto.
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

El remedio es simple: #strong[comprobación visual después de cada transmisión] (#ref(<fig-04-cap03-luz-tx>, supplement: [Figura])). La mayoría de radios de panel tienen un indicador #strong[TX] en pantalla que se ilumina mientras transmites. Comprueba siempre que #strong[se apaga] al soltar el botón.

#figure([
#box(image("04-comunicaciones/imagenes/04-cap03-luz-tx.jpg"))
], caption: figure.caption(
position: bottom, 
[
Comprobación del indicador de transmisión (TX)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap03-luz-tx>


== Jerarquía y prioridad de mensajes
<jerarquía-y-prioridad-de-mensajes>
No todos los mensajes son iguales. La OACI establece un orden de prioridad claro para que lo más urgente siempre pase primero:

+ #strong[Mensajes de SOCORRO (#link(<glosario-mayday>)[MAYDAY]#index("MAYDAY"))]: Prioridad absoluta. Indican que la aeronave o las personas a bordo están en peligro grave e inminente ---fuego, rotura estructural, emergencia médica extrema--- y necesitan ayuda inmediata. Si escuchas un Mayday, calla. Silencio total en esa frecuencia, salvo que la aeronave en peligro se dirija a ti o que estés en posición de retransmitir su llamada a una torre lejana. La frase para imponer el silencio es: #emph[«Cesen transmisiones, Mayday»] (#emph[«Stop transmitting, Mayday»]).
+ #strong[Mensajes de URGENCIA (#link(<glosario-pan-pan>)[PAN PAN]#index("PAN PAN"))]: Segunda prioridad. Hay un problema serio ---motor fallando en un motovelero que aún vuela, pérdida de posición crítica, pasajero indispuesto sin riesgo vital inmediato--- pero no se necesita salvamento en ese segundo exacto. Da prioridad sobre el tráfico ordinario y exige no interferir, aunque sin el silencio total que impone el Mayday.
+ #strong[Comunicaciones de radiogoniometría (#link(<glosario-vdf>)[VDF]#index("VDF"))]: Peticiones de rumbo, marcación o demora magnética (solicitudes de #link(<glosario-qdm>)[QDM]#index("QDM") o QDR).
+ #strong[Mensajes de seguridad de vuelo]: Avisos de tráfico ATC, separación e información meteorológica urgente (#link(<glosario-sigmet>)[SIGMET]#index("SIGMET")/#link(<glosario-airmet>)[AIRMET]#index("AIRMET")).
+ #strong[Mensajes meteorológicos] regulares: #link(<glosario-metar>)[METAR]#index("METAR"), #link(<glosario-taf>)[TAF]#index("TAF") y pronósticos en ruta.
+ #strong[Comunicaciones de regularidad del vuelo]: Cierre de plan de vuelo, confirmaciones de posición y coordinaciones operativas.

#block[
#callout(
body: 
[
La transmisión maliciosa o falsa de señales de emergencia (Mayday / Pan Pan) constituye una infracción penal grave en todas las jurisdicciones de la #link(<glosario-easa>)[EASA]#index("EASA"), sancionada con multas elevadas y la retirada de la licencia aeronaútica, además del riesgo operacional real que genera al desviar recursos de emergencia. Utilícelas exclusivamente cuando la situación real lo requiera.

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
Las radios #link(<glosario-vhf>)[VHF]#index("VHF") aeronáuticas van de #strong[118 MHz a 136,975 MHz] con modulación de amplitud (AM). Hay dos tipos según cómo van instaladas:

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
#strong[Resumen del capítulo: procedimientos operativos generales]

- #strong[Esquema de llamada]: A quién → Quién soy → Dónde estoy → Qué necesito. Al colacionar, el indicativo va al final. En autoinformación, el indicativo va al principio.
- #strong[Prueba de radio (radio check)]: Realízala solo si tienes dudas sobre la integridad del equipo. Usa la escala de legibilidad del 1 (ilegible) al 5 (perfecto): «Le recibo 5».
- #strong[Reportes de posición]: Identificativo + posición + altitud (QNH o FL). En travesía añade hora UTC y siguiente punto estimado. Actualiza al FIS si te apartas de tu ruta.
- #strong[Llamadas simultáneas]: Si la frecuencia está activa, espera. Tras una llamada sin respuesta, aguarda 10 segundos antes de reintentar. El ATC decide el turno cuando varias aeronaves llaman a la vez.
- #strong[Micrófono bloqueado]: Comprueba que la luz TX se apaga al soltar el PTT. Un PTT atascado anula la frecuencia para todos los usuarios.
- #strong[Prioridad de mensajes]: SOCORRO (Mayday) tiene prioridad absoluta e impone silencio total; URGENCIA (Pan Pan) pide prioridad sin exigir ese silencio. Ante un Mayday ajeno, calla salvo que puedas asistir o retransmitir.
- #strong[Técnica de micrófono]: Micrófono cerca de los labios pero sin tocarlos. Volumen normal y constante. Gritar satura la señal y reduce la inteligibilidad.
- #strong[Equipos de radio]: Panel (6--10 W, antena exterior) o portátil (1--5 W, respaldo). Obligatorio espaciado 8,33 kHz (Reglamento UE 1079/2012); el marcado #strong[ETSO-C169a] certifica que la radio cumple esa canalización.

]
= Términos de información meteorológica relevantes (VFR)
<términos-de-información-meteorológica-relevantes-vfr>
#quote(block: true)[
La radio aeronáutica tiene su propio vocabulario meteorológico, y conocerlo te ahorra malentendidos en vuelo. En este capítulo verás qué son el #link(<glosario-atis>)[ATIS]#index("ATIS") y el #link(<glosario-volmet>)[VOLMET]#index("VOLMET"), qué significa #link(<glosario-cavok>)[CAVOK]#index("Visibilidad"), cómo funcionan el #link(<glosario-qnh>)[QNH]#index("QNH") y el #link(<glosario-qfe>)[QFE]#index("QFE"), por qué el viento de la Torre y el de los mapas se miden diferente, y cuándo tienes que emitir un #link(<glosario-airep>)[AIREP]#index("AIREP").
]

== ATIS: el servicio automático de información terminal
<atis-el-servicio-automático-de-información-terminal>
Sin el #strong[ATIS] (#strong[Automatic Terminal Information Service]), los controladores de Torre en aeródromos con tráfico medio o alto pasarían la mitad del día repitiendo lo mismo a cada aeronave que se aproxima. El ATIS existe para librarles de eso.

Es una grabación de voz ---normalmente sintética--- que suena en bucle continuo en una frecuencia #link(<glosario-vhf>)[VHF]#index("VHF") propia, separada de la frecuencia de control (#ref(<fig-04-cap04-atis-escucha>, supplement: [Figura])). Te dice:

- #strong[Pista en servicio] para despegues y aterrizajes.
- #strong[Condiciones meteorológicas] actuales: viento, visibilidad, nubes, temperatura, punto de rocío y QNH.
- #strong[Información operativa:] obras en calles de rodaje, avisos de #link(<glosario-cizalladura>)[cizalladura]#index("Cizalladura") o presencia de aves.

Cada boletín lleva una letra del alfabeto fonético como #strong[código de información] («Información Bravo», por ejemplo). Cuando cambian significativamente las condiciones o la pista en uso, el boletín avanza a la siguiente letra («Información Charlie»).

#block[
#callout(
body: 
[
Escucha el ATIS completo #strong[antes] de llamar a la Torre. Luego incluye el código en tu primera llamada: #emph[«Jerez #link(<glosario-twr>)[TWR]#index("TWR"), velero EC-DPE, a 10 millas al norte, con información Bravo, solicito…​»] El controlador sabe que ya tienes todos los datos y puede ir directo al grano.

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
#box(image("04-comunicaciones/imagenes/04-cap04-atis-escucha.jpg"))
], caption: figure.caption(
position: bottom, 
[
Secuencia de escucha del ATIS antes del contacto con Torre
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap04-atis-escucha>


== VOLMET: información meteorológica para aeronaves en vuelo
<volmet-información-meteorológica-para-aeronaves-en-vuelo>
El ATIS te da el tiempo de un aeropuerto concreto. El #strong[VOLMET] (de #strong[VOL METéorologique]) te da el tiempo de una región entera.

Es otra emisión pregrabada en bucle, pero en lugar de un aeródromo emite #link(<glosario-metar>)[METAR]#index("METAR"), pronósticos #link(<glosario-taf>)[TAF]#index("TAF") y avisos #link(<glosario-sigmet>)[SIGMET]#index("SIGMET") de #strong[un conjunto de aeropuertos de una misma región].

En travesías largas (#strong[cross-country]), cuando el tiempo empieza a empeorar y estás valorando un alternativo a decenas de kilómetros, el VOLMET regional te dice exactamente cómo está ese campo sin tener que llamar a nadie. Tomas la decisión con datos reales y la frecuencia de control queda libre.

== Conceptos clave en las transmisiones meteorológicas
<conceptos-clave-en-las-transmisiones-meteorológicas>
Por radio, el tiempo no se describe con palabras propias: se usa terminología estandarizada que cualquier piloto entiende igual, con cualquier acento y con cualquier nivel de ruido de fondo.

=== CAVOK
<cavok>
Probablemente la palabra más bienvenida que puedes escuchar en el ATIS. #emph[Ceiling and Visibility OK] (techo y visibilidad correctos) significa que se cumplen tres condiciones a la vez:

+ #strong[Visibilidad] de 10 kilómetros o más.
+ #strong[Ninguna nube] convectiva (ni #link(<glosario-cumulonimbus>)[Cumulonimbus]#index("Cumulonimbus") CB, ni Cumulus Congestus TCU) y ninguna capa de nubes por debajo de 5.000 pies o de la altitud mínima del sector, lo que sea mayor.
+ #strong[Sin fenómenos] meteorológicos significativos en el aeródromo o cercanías: sin precipitaciones, tormentas, #link(<glosario-niebla>)[niebla]#index("Niebla") somera ni ventisca baja.

=== El ajuste QNH y QFE
<el-ajuste-qnh-y-qfe>
El altímetro del planeador es un barómetro: necesita una presión de referencia en la ventanilla para saber a qué altitud estás.

- El #strong[QNH] es la presión atmosférica reducida al nivel medio del mar. Mételo en el altímetro y te dará #strong[la altitud real] sobre el nivel del mar. Es el ajuste que usas en ruta y para respetar los límites verticales de los espacios aéreos (los techos de los #link(<glosario-ctr>)[CTR]#index("Zona de control") van en altitud QNH).
- El #strong[QFE] es la presión a la elevación del aeródromo. Con el QFE puesto, el altímetro marca #strong[cero pies] en tierra: te indica altura sobre el campo, no altitud. En veleros casi no se usa ya, salvo en operaciones muy locales o acrobacia en aeródromo. El QNH es el ajuste de referencia en las comunicaciones #link(<glosario-ats>)[ATS]#index("ATS") (#ref(<fig-04-cap04-qnh-qfe>, supplement: [Figura])).

#figure([
#box(image("04-comunicaciones/imagenes/04-cap04-qnh-qfe.png"))
], caption: figure.caption(
position: bottom, 
[
Comparación del altímetro con ajuste QNH y QFE
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap04-qnh-qfe>


=== La dualidad del viento: magnético frente a geográfico
<la-dualidad-del-viento-magnético-frente-a-geográfico>
Cuando calculas el planeo #link(<glosario-final>)[final]#index("Tramo final") o la componente cruzada, necesitas saber en qué referencia está expresado el viento. No siempre es la misma (#ref(<fig-04-cap04-viento-magnetico-geografico>, supplement: [Figura])).

- #strong[Viento radiado (Torre / ATIS):] La dirección del viento en las operaciones de aproximación y despegue va referida al #strong[#link(<glosario-norte-magnetico>)[Norte Magnético]#index("Norte magnético")] («Viento 240 grados, 15 nudos»). Tiene sentido: tanto la brújula de cabina como la numeración de las pistas usan la #link(<glosario-variacion-magnetica>)[declinación]#index("Variación magnética") magnética, así que puedes comparar directamente la orientación de la pista con el viento sin hacer correcciones.
- #strong[Viento escrito (mapas meteorológicos / METAR en texto / VOLMET):] Si consultas el viento en una web de meteo, en un mapa de vientos en altura (GRIB) o en un METAR/TAF en formato texto ---incluyendo el que difunde el VOLMET---, la dirección viene referida al #strong[Norte #link(<glosario-norte-verdadero>)[Geográfico]#index("Norte verdadero") (verdadero)]. El VOLMET retransmite METAR y TAF en texto, así que su viento también es #strong[verdadero], distinto del viento operativo que te da la Torre.

#figure([
#box(image("04-comunicaciones/imagenes/04-cap04-viento-mag-geo.jpg"))
], caption: figure.caption(
position: bottom, 
[
Diferencia entre viento magnético (radio) y geográfico (mapas)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap04-viento-magnetico-geografico>


=== SIGMET y AIRMET
<sigmet-y-airmet>
Dos tipos de avisos meteorológicos que aparecen en el VOLMET y en los briefings prevuelo:

- #strong[SIGMET] (#strong[Significant Meteorological Information]): aviso emitido por los centros meteorológicos de vigilancia para fenómenos severos en ruta ---tormentas eléctricas, #link(<glosario-engelamiento>)[engelamiento]#index("Engelamiento") intenso, turbulencia severa, cenizas volcánicas---. Cubre grandes áreas y tiene validez de hasta 4 horas (6 h en zonas oceánicas). Su uso obliga a tomarse muy en serio la decisión de vuelo.
- #strong[#link(<glosario-airmet>)[AIRMET]#index("AIRMET")] (#strong[Airman's Meteorological Information]): aviso de menor severidad, dirigido especialmente a la aviación de bajo nivel y la aviación general. Cubre fenómenos moderados ---turbulencia moderada, engelamiento moderado, visibilidad reducida--- que no alcanzan el umbral del SIGMET.

Ambos los encontrarás en el VOLMET regional o en el briefing meteorológico prevuelo. Si un SIGMET activo afecta a tu ruta, evalúa si las condiciones son operables antes de salir.

== AIREP: el informe meteorológico especial en vuelo
<airep-el-informe-meteorológico-especial-en-vuelo>
El #strong[AIREP] (#strong[Aircraft Report]) es el informe que tú, como piloto, transmites al #link(<glosario-fis>)[FIS]#index("FIS") o al #link(<glosario-atc>)[ATC]#index("ATC") cuando encuentras en ruta condiciones meteorológicas peligrosas que no estaban pronosticadas.

Si te metes en turbulencia fuerte, engelamiento, tormenta, #link(<glosario-granizo>)[granizo]#index("Granizo") u ondas orográficas intensas, emites un AIREP especial con tu posición y altitud. Así el ATC puede avisar a los demás tráficos en esa zona.

#block[
#callout(
body: 
[
El Reglamento #link(<glosario-sera>)[SERA]#index("SERA") obliga al piloto en mando a notificar sin demora cualquier condición meteorológica peligrosa que pueda afectar a la seguridad de otras aeronaves.

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
- #strong[CAVOK]: #strong[Ceiling and Visibility OK] (visibilidad ≥ 10 km, sin nubes bajas, sin fenómenos). Las mejores condiciones posibles para #link(<glosario-vfr>)[VFR]#index("VFR").
- #strong[QNH]: Presión de referencia para leer la altitud sobre el nivel del mar. Fundamental para respetar los límites verticales de los espacios aéreos.
- #strong[Viento]: La Torre y el ATIS facilitan el viento referido al Norte Magnético (igual que la numeración de pistas). En mapas, METAR/TAF en texto y VOLMET el viento viene referido al Norte Geográfico (verdadero).
- #strong[AIREP]: Informe emitido obligatoriamente por el piloto en vuelo para notificar a otras aeronaves sobre fenómenos meteorológicos severos no pronosticados.

]
= Acciones ante fallo de comunicaciones
<acciones-ante-fallo-de-comunicaciones>
#quote(block: true)[
Quedarse sin radio en vuelo ---situación NORDO--- tiene un protocolo concreto. Aquí verás qué hacer con el #link(<glosario-transpondedor>)[transpondedor]#index("Transpondedor"), cómo gestionar el vuelo hasta tierra, qué significan las señales de luces de la Torre y cómo transmitir cuando solo falla el receptor.
]

== El código 7600: señal de fallo de radio
<el-código-7600-señal-de-fallo-de-radio>
Perder toda la radio en vuelo ---técnicamente, pérdida de comunicaciones bidireccionales o situación #strong[#link(<glosario-nordo>)[NORDO]#index("No Radio")] (#strong[No Radio])--- es un problema serio, especialmente cerca de #link(<glosario-espacio-aereo-controlado>)[espacio aéreo controlado]#index("Espacio aéreo controlado"). No entres en pánico: hay un procedimiento.

Primero repasa lo básico: volumen, silenciador (#strong[squelch]), conectores de los auriculares (#strong[jacks]), fusibles y frecuencias alternativas. Si nada funciona, ve al transpondedor.

Pon el #strong[código 7600] ahora.

Con ese código, el radar secundario de vigilancia (#link(<glosario-ssr>)[SSR]#index("SSR")) de los centros de control muestra tu aeronave con una alerta especial en pantalla. Los controladores del sector saben que estás NORDO y empiezan a coordinar: despejan el espacio aéreo a tu alrededor y te siguen visualmente.

== Procedimiento estándar en vuelo VFR
<procedimiento-estándar-en-vuelo-vfr>
Con la situación NORDO declarada, el plan es este:

+ #strong[Mantén #link(<glosario-vmc>)[VMC]#index("VMC").] No entres en nubes bajo ningún concepto. Necesitas #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") y contacto visual con el suelo y otros tráficos.
+ #strong[Rodea las zonas controladas.] Si tu ruta cruzaba un #link(<glosario-ctr>)[CTR]#index("Zona de control"), quédate fuera. Sin radio no puedes obtener autorización.
+ #strong[Aterriza en el aeródromo adecuado más cercano.] Preferiblemente uno no controlado: te integras en el circuito visual con los ojos bien abiertos y aterrizas.
+ #strong[Llama por teléfono en cuanto estés en tierra.] Contacta con la dependencia #link(<glosario-atc>)[ATC]#index("ATC") correspondiente para confirmar el aterrizaje. Si no lo haces, los servicios #link(<glosario-ats>)[ATS]#index("ATS") activarán la fase de Búsqueda y Salvamento (#link(<glosario-sar>)[SAR]#index("SAR")).

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
#box(image("04-comunicaciones/imagenes/04-cap05-senales-luces.jpg"))
], caption: figure.caption(
position: bottom, 
[
Señales con pistola de luces desde la Torre de Control
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap05-pistola-luces>


== Señales luminosas de la torre (Reglamento SERA)
<señales-luminosas-de-la-torre-reglamento-sera>
Desde los primeros aeródromos, las torres de control tienen focos direccionales con filtros de color ---la «pistola de luces»--- precisamente para esto: guiar a aeronaves sin radio (#ref(<fig-04-cap05-pistola-luces>, supplement: [Figura])). Memoriza estas señales. Si algún día las necesitas, no habrá tiempo para buscarlas.

#block[
#callout(
body: 
[
Las señales luminosas de la Torre de Control están reguladas por el Reglamento de Ejecución (UE) n.º 923/2012 ---Reglas Europeas Estandarizadas del Aire (#strong[#link(<glosario-sera>)[SERA]#index("SERA")])---. Su correcto conocimiento e interpretación es obligatorio para todo piloto que opere en espacios aéreos con servicio ATC (Fuente: documentación oficial SERA, #link(<glosario-easa>)[EASA]#index("EASA") / #link(<glosario-aesa>)[AESA]#index("AESA")).

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

- #text(fill: rgb("#2e7d32"))[●] #strong[Luz verde fija]: Autorizado a aterrizar.
- #text(fill: rgb("#c62828"))[●] #strong[Luz roja fija]: Ceda el paso a otras aeronaves y continúe en circuito de espera.
- #text(fill: rgb("#2e7d32"))[●●●] #strong[Serie de destellos verdes]: Regrese para aterrizar.
- #text(fill: rgb("#c62828"))[●●●] #strong[Serie de destellos rojos]: Aeródromo peligroso o inseguro, no aterrice.
- ○○○ #strong[Serie de destellos blancos]: Aterrice en este aeródromo.
- #text(fill: rgb("#c62828"))[★] #strong[Luz pirotécnica roja]: A pesar de las instrucciones previas, no aterrice por el #link(<glosario-momento>)[momento]#index("Momento").

#strong[Señales para aeronaves en tierra:]

- #text(fill: rgb("#2e7d32"))[●] #strong[Luz verde fija]: Autorizado para despegar.
- #text(fill: rgb("#c62828"))[●] #strong[Luz roja fija]: Alto.
- #text(fill: rgb("#2e7d32"))[●●●] #strong[Serie de destellos verdes]: Autorizado para rodar.
- #text(fill: rgb("#c62828"))[●●●] #strong[Serie de destellos rojos]: Apártese del área de aterrizaje en uso.
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
A veces el fallo es solo del receptor: tu voz sale al exterior con normalidad, pero no recibes nada. No puedes saberlo con certeza desde el aire, pero si sospechas que es así, aplica la #strong[#link(<glosario-transmision-a-ciegas>)[transmisión a ciegas]#index("Transmisión a ciegas")] (#strong[blind transmission]).

La idea es simple: sigues transmitiendo posición e intenciones en la frecuencia correcta, pero cada mensaje va precedido de un aviso:

#emph[«Transmitiendo a ciegas debido a fallo del receptor. Transmitiendo a ciegas. Torre de San Javier, planeador EC-EPE, a 5 millas del punto Sierra a 2.000 pies, intención entrar en zona y proceder a inicial de pista 23 para toma completa.»]

Transmite cada mensaje completo dos veces: sin acuse de recibo, la repetición es tu única garantía de que llegue entero. Y repite el aviso en cada cambio de tramo del circuito o al iniciar el descenso en #link(<glosario-final>)[final]#index("Tramo final"). El controlador puede estar recibiéndote perfectamente en tierra y coordinando el tráfico a partir de lo que narras, aunque tú no puedas confirmarlo.

#postit[
#strong[Resumen del capítulo: fallo de comunicaciones]

- #strong[Código 7600]: Al confirmar el fallo de radio, seleccione 7600 en el transpondedor. La aeronave aparecerá destacada en la pantalla del radar secundario (SSR) como situación NORDO.
- #strong[Procedimiento en vuelo]: Mantenga VMC. Aterrice preferentemente en un aeródromo no controlado. Si debe acudir a uno controlado, sobrevuele la Torre por zona no operativa, efectúe balanceos de alas y observe las señales de luces. Notifique por teléfono en cuanto tome tierra.
- #strong[Señales de luces (SERA)]: #emph[Verde fija] (vuelo) = autorizado a aterrizar. #emph[Roja fija] (vuelo) = ceda el paso. #emph[Destellos rojos] (vuelo) = aeródromo peligroso. #emph[Destellos verdes] (vuelo) = regrese para aterrizar. #emph[Destellos blancos] (vuelo) = aterrice en este aeródromo. Las señales equivalentes en tierra tienen significados distintos: #emph[verde fija] = autorizado para despegar; #emph[destellos verdes] = autorizado para rodar.
- #strong[Transmisión a ciegas]: Si solo falla el receptor, transmita posición e intenciones en la frecuencia correcta precediendo el mensaje con «Transmitiendo a ciegas debido a fallo del receptor». Repítalo en cada cambio de tramo.

]
= Procedimientos de socorro (#emph[distress]) y urgencia (#emph[urgency])
<procedimientos-de-socorro-distress-y-urgencia-urgency>
#quote(block: true)[
#link(<glosario-mayday>)[MAYDAY]#index("MAYDAY") y #link(<glosario-pan-pan>)[PAN PAN]#index("PAN PAN") no son sinónimos. Este capítulo explica cuándo usar cada uno, qué decir exactamente y en qué frecuencia. Son los dos mensajes más importantes que puedes transmitir por radio, y esperas no necesitarlos nunca. Por eso los tienes que saber de memoria. Cierra el capítulo otro procedimiento que también esperas no usar jamás: qué hacer si una aeronave militar te intercepta.
]

== MAYDAY: situación de socorro
<mayday-situación-de-socorro>
#strong[MAYDAY] es la palabra de mayor prioridad en la radio aeronáutica. Viene del francés #emph[m'aider], «ayudadme», pronunciado en inglés.

Úsala cuando hay #strong[peligro grave e inminente y necesitas asistencia inmediata]. La vida de los ocupantes o la integridad del planeador están en riesgo ahora mismo.

En vuelo a vela, eso significa: fuego a bordo, rotura estructural severa (#link(<glosario-cupula>)[cúpula]#index("Cúpula"), timón, ala), incapacitación médica del piloto, o pérdida de altitud sin campo disponible que exige actuar ya.

La palabra se repite #strong[tres veces] para que destaque sobre el tráfico normal y las interferencias:

#emph[«Mayday, Mayday, Mayday…​»]

#block[
#callout(
body: 
[
La transmisión maliciosa o falsa de un mensaje de socorro MAYDAY moviliza recursos de búsqueda y salvamento (#link(<glosario-sar>)[SAR]#index("SAR")) estatales. Según la Ley de Seguridad Aérea, simular emergencias o proporcionar información falsa que comprometa la seguridad se tipifica como infracción muy grave, conlleva sanciones económicas elevadas y puede resultar en la revocación de la licencia de vuelo.

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
La declaración de un MAYDAY impone, según la normativa internacional (#link(<glosario-oaci>)[OACI]#index("OACI")/#link(<glosario-easa>)[EASA]#index("EASA")), un #strong[silencio de radio absoluto] para todas las demás estaciones áreas y terrestres operando en esa frecuencia. Ningún otro tráfico debe transmitir a menos que sea para ofrecer ayuda directa a la aeronave en peligro o para retransmitir su mensaje a la Torre de Control (#strong[Mayday relay]).

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

El PAN PAN dice que tienes un problema serio que necesita #strong[atención prioritaria] del #link(<glosario-atc>)[ATC]#index("ATC"), pero no estás en peligro inmediato de accidente ni necesitas salvamento en los próximos segundos.

En planeador: entrar involuntariamente en IMC sin poder salir a #link(<glosario-vfr>)[VFR]#index("VFR") de inmediato, una indisposición médica que obliga a desviar el vuelo, o una pérdida progresiva de altura que te da tiempo a planificar el aterrizaje fuera de aeródromo y coordinarlo con el ATC o el #link(<glosario-fis>)[FIS]#index("FIS").

El PAN PAN te da prioridad en las comunicaciones. No exige silencio total al resto de tráficos, a diferencia del MAYDAY.

== Estructura del mensaje de emergencia
<estructura-del-mensaje-de-emergencia>
Con el corazón acelerado y las manos ocupadas, puede costar estructurar un mensaje. Pero los servicios de control y salvamento (SAR) necesitan información concreta para localizarte y ayudarte. Esta es la secuencia (#ref(<fig-04-cap06-llamada-emergencia>, supplement: [Figura])):

+ #strong[A QUIÉN:] Nombre de la dependencia #link(<glosario-ats>)[ATS]#index("ATS").
+ #strong[QUIÉN:] Tipo de aeronave e indicativo completo.
+ #strong[DÓNDE:] Posición actual, altitud o #link(<glosario-fl>)[nivel de vuelo]#index("Nivel de vuelo"), y rumbo.
+ #strong[QUÉ PASA:] Naturaleza de la emergencia.
+ #strong[QUÉ SOLICITA:] Intenciones del piloto y tipo de ayuda requerida.
+ #strong[PERSONAS:] Personas a bordo (vital para los servicios de rescate).

#emph[Ejemplo de mensaje de socorro (MAYDAY):] #emph[«Mayday, Mayday, Mayday. Madrid Información. Velero ASK-21, EC-EPE. A 5 millas al este de Fuentemilanos, 2.800 metros. Impacto con ave y rotura masiva del timón de profundidad. El piloto y el pasajero van a saltar en paracaídas. 2 personas a bordo.»]

#emph[Ejemplo de mensaje de urgencia (PAN PAN):] #emph[«Pan Pan, Pan Pan, Pan Pan. Madrid Información. Velero ASK-21, EC-EPE. Sobre el embalse de Pinilla, 2.200 metros #link(<glosario-qnh>)[QNH]#index("QNH") 1018. Pérdida de altura progresiva sin #link(<glosario-termica>)[térmica]#index("Térmica") disponible. Planificando aterrizaje fuera de aeródromo en 10 minutos. 2 personas a bordo. Solicito información de campos en el área.»]

#figure([
#box(image("04-comunicaciones/imagenes/04-cap06-estructura-emergencia.jpg"))
], caption: figure.caption(
position: bottom, 
[
Estructura de la llamada de emergencia
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap06-llamada-emergencia>


== La frecuencia adecuada
<la-frecuencia-adecuada>
Hay una idea muy extendida que dice que en cualquier emergencia lo primero es cambiar a 121.500 MHz. Es un error.

#strong[La mejor frecuencia para declarar una emergencia es en la que ya estás.]

Si estás hablando con «Zaragoza Torre» o escuchando «Madrid Información», emite ahí. El controlador ya te tiene en pantalla y la comunicación está establecida. Cambiar de frecuencia en medio de una emergencia añade trabajo y arriesga perder el contacto.

Ahora bien, si vuelas en una zona remota sin contacto ATS y nadie responde a tu llamada local, entonces sí: cambia a #strong[121.500 MHz].

Esa frecuencia la escuchan continuamente los vuelos de líneas aéreas en crucero, las estaciones militares de defensa aérea y los centros de control de área. Un MAYDAY en 121.500 MHz tiene muchas probabilidades de ser escuchado y retransmitido (#strong[relay]) a los servicios de rescate.

== Interceptación: si un caza aparece a tu lado
<interceptación-si-un-caza-aparece-a-tu-lado>
Un planeador rara vez provoca una #link(<glosario-interceptacion>)[interceptación]#index("Interceptación") (#strong[interception]), pero alguna vez ya ha ocurrido: infringir una #link(<glosario-zona-prohibida>)[zona prohibida]#index("P de Prohibited") o restringida activa, cruzar un #link(<glosario-ctr>)[CTR]#index("Zona de control") sin autorización o aparecer como un eco sin identificar cerca de una zona sensible puede hacer que la defensa aérea envíe una aeronave militar a identificarte. El #strong[Libro 1 --- Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (ATC)] ya te avisa de ese riesgo al estudiar las #link(<glosario-zonas-p>)[zonas P]#index("Zonas P") y R; aquí aprenderás las señales y la respuesta correcta. No es un adorno del temario: la normativa exige llevar a bordo una copia de estas señales (#link(<glosario-sao>)[SAO]#index("SAO")​.GEN.155, véase el #strong[Libro 6 --- Procedimientos Operativos], capítulo 1).

=== Las señales del interceptor
<las-señales-del-interceptor>
El interceptor se comunica contigo con maniobras, no con palabras. Las tres series que debes reconocer, conforme a la tabla S11-1 de #link(<glosario-sera>)[SERA]#index("SERA"):

+ Alabea y enciende y apaga las luces de navegación a intervalos irregulares, desde una posición ligeramente por encima, por delante y normalmente a tu izquierda. Después, vira lentamente en horizontal hacia el rumbo deseado.

«Ha sido interceptado. Sígame.»

Alabea, enciende y apaga las luces de navegación si dispones de ellas, y síguele.

#block[
#set enum(numbering: "1.", start: 2)
+ Se aleja bruscamente de ti con un viraje ascendente de 90° o más, sin cruzar tu línea de vuelo.
]

«Prosiga.»

Alabea: «Comprendido, lo cumpliré».

#block[
#set enum(numbering: "1.", start: 3)
+ Despliega el tren de aterrizaje, lleva los faros de aterrizaje encendidos de forma continua y sobrevuela la pista en servicio.
]

«Aterrice en este aeródromo.»

Despliega el tren (si es replegable), sigue al interceptor y, tras sobrevolar la pista, aterriza si es seguro.

Si el interceptor es mucho más rápido que tú ---lo será siempre---, la norma ya lo prevé: hará circuitos de hipódromo a tu alrededor y alabeará cada vez que te adelante. No lo interpretes como una señal nueva; sigue siendo la serie 1.

#figure([
#box(image("04-comunicaciones/imagenes/04-cap06-interceptacion-serie1.png"))
], caption: figure.caption(
position: bottom, 
[
Serie 1: el interceptor se coloca por delante y a tu izquierda, alabea y vira hacia el rumbo que debes seguir
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap06-interceptacion-serie1>


=== Qué debes hacer
<qué-debes-hacer>
Si te interceptan, aplica de inmediato los cuatro pasos de SERA.11015:

+ #strong[Sigue las instrucciones visuales] del interceptor, interpretándolas y respondiendo según las tablas de señales.
+ #strong[Notifica], si es posible, a la dependencia de servicios de tránsito aéreo con la que estés en contacto.
+ #strong[Intenta la radio]: llamada general en #strong[121,500 MHz], indicando tu identidad y la índole del vuelo (por ejemplo: #emph[«Aeronave interceptada, velero EC-EPE, vuelo VFR de Fuentemilanos a Santo Tomé, escucho»]).
+ #strong[Selecciona 7700 en modo A] en el #link(<glosario-transpondedor>)[transpondedor]#index("Transpondedor"), salvo que el ATS te instruya otra cosa.

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
#strong[Las instrucciones del interceptor prevalecen sobre cualquier otra fuente, incluido el ATC], mientras solicitas aclaración ---en la duda, obedece al que lleva misiles---. Un interceptor armado que cree que no cooperas es el escenario más peligroso en el que puede meterse una aeronave civil: mantén una trayectoria suave y predecible, no hagas maniobras bruscas y responde a cada señal.

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
Un velero sin luces de navegación tiene pocas opciones de señalización: tu respuesta visible es el #strong[alabeo amplio y claro]. Compensa el resto con la radio (121,500 MHz) y el transpondedor (7700). Y recuerda que la mejor interceptación es la que no ocurre: comprueba los #link(<glosario-notam>)[NOTAM]#index("NOTAM") y el estado de las zonas P y R antes de cada vuelo de travesía.

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
- #strong[Interceptación (SERA.11015)]: interceptor alabeando por delante y a tu izquierda = «Sígame» (responde alabeando y siguiéndole); viraje ascendente brusco de 90° o más = «Prosiga»; tren desplegado y faros encendidos sobre la pista = «Aterrice en este aeródromo». Procedimiento: seguir las instrucciones visuales + notificar al ATS + llamada en 121,500 MHz + #link(<glosario-squawk>)[squawk]#index("Squawk") 7700. #strong[Las instrucciones del interceptor prevalecen sobre cualquier otra fuente, incluido el ATC], mientras se solicita aclaración. A bordo debe llevarse copia de las señales (SAO.GEN.155).

]
= Principios generales de propagación VHF y asignación de frecuencias
<principios-generales-de-propagación-vhf-y-asignación-de-frecuencias>
#quote(block: true)[
La radio #link(<glosario-vhf>)[VHF]#index("VHF") funciona como una linterna: ilumina en línea recta y la montaña te deja a oscuras. En este capítulo verás por qué la altitud es tu mejor aliada para el alcance, qué cambió con el espaciado a 8,33 kHz, cómo ajustar bien el #strong[squelch], qué hacer cuando una sierra te bloquea la señal, y qué frecuencias necesitas conocer de memoria. También cuándo es obligatorio el #link(<glosario-transpondedor>)[transpondedor]#index("Transpondedor") y qué significan los códigos #strong[#link(<glosario-squawk>)[squawk]#index("Squawk")].
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
Durante décadas, el espectro VHF de aviación se dividió en canales separados por 25 kHz. Funcionó bien hasta que el crecimiento del tráfico aéreo en Europa dejó sin canales suficientes para nuevos sectores de #link(<glosario-atc>)[ATC]#index("ATC"), aproximaciones y aeródromos.

La solución fue reducir el espaciado de cada canal de 25 kHz a #strong[8,33 kHz]. Con eso, el número de canales disponibles en la misma porción del espectro se triplicó.

El Reglamento de ejecución (UE) N.º 1079/2012 impuso la transición en toda Europa. En España, desde el #strong[31 de diciembre de 2022], los vuelos #link(<glosario-vfr>)[VFR]#index("VFR") tienen que ir equipados con radios «compatibles con 8,33» (#strong[8,33 compliant]). Los #link(<glosario-ifr>)[IFR]#index("IFR") cumplieron antes.

#block[
#callout(
body: 
[
Si tu velero lleva una radio antigua de 25 kHz ---la que solo marca diales acabados en .000, .025, .050 o .075---, la regla general en Europa es que ya no basta: para operar con las dependencias modernas del ATC necesitas un equipo capaz de sintonizar el espaciado de 8,33 kHz. Hay una excepción que conviene conocer: el #link(<glosario-aip>)[AIP]#index("AIP")-España (ENR 1.8) mantiene, comunicadas a la Comisión (Reg. 2023/1770 y 2023/1771), unas #strong[sub-bandas nacionales en 25 kHz para comunicaciones aire-aire y aire-tierra hasta el 31-12-2028] ---precisamente las de vuelo a vela que aparecen en la tabla de este capítulo (122,600; 123,375; 123,400; 123,450; 123,500)---. Así que como afirmación legal la frase exige el matiz de la exención; como recomendación práctica, equipa 8,33 sin dudarlo: sin él no te comunicarás con la mayoría de las dependencias del ATC.

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
#box(image("04-comunicaciones/imagenes/04-cap07-bloqueo-montana.jpg"))
], caption: figure.caption(
position: bottom, 
[
Bloqueo orográfico de la señal VHF
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-04-cap07-bloqueo-montana>


== Bloqueo en montaña y relé de radio (#emph[relay])
<bloqueo-en-montaña-y-relé-de-radio-relay>
El vuelo a vela lleva a menudo a los planeadores a entornos orográficos complejos: laderas de los Pirineos, valles del Gredos, cajones del Sistema Central. Lejos de las llanuras y muy por debajo de las crestas.

Las ondas VHF viajan en línea recta y no atraviesan la roca. Si bajas por debajo de la cresta que te separa de la torre de control o del repetidor #link(<glosario-fis>)[FIS]#index("FIS") de ENAIRE más cercano, sufrirás un #strong[bloqueo orográfico] total (#ref(<fig-04-cap07-bloqueo-montana>, supplement: [Figura])). Da igual cuánta potencia tenga tu radio: la señal se estrella contra la piedra.

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
  [#strong[123,500]], [Aeródromo no controlado genérico], [#link(<glosario-autoinformacion>)[Autoinformación]#index("Autoinformación") en aeródromos sin torre o con #link(<glosario-afis>)[AFIS]#index("AFIS") donde no hay frecuencia específica publicada.],
)
Las frecuencias de #strong[FIS regionales] de España (Madrid, Barcelona, Sevilla, Palma de Mallorca, Gran Canaria) varían por sector y altitud. Se publican en el AIP España (GEN 3.3) y en las cartas de navegación #link(<glosario-oaci>)[OACI]#index("OACI") 1:500.000. Cada aeródromo con torre o AFIS tiene su propia frecuencia, publicada en la carta #link(<glosario-vac>)[VAC]#index("VAC") del aeródromo. La propia tabla de arriba procede del AIP-España (GEN 3.4 y ENR 1.8).

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
El #strong[transpondedor] (#emph[XPDR]) responde automáticamente a los radares terrestres emitiendo un código de cuatro dígitos (#emph[squawk]). Así el controlador ve tu aeronave identificada en pantalla.

Llevarlo operativo es obligatorio dentro de una #strong[#link(<glosario-tmz>)[TMZ]#index("TMZ")] (#emph[Transponder Mandatory Zone]) y allí donde lo exijan la clase de espacio aéreo o el AIP-España (ENR 1.6): las clases A y C lo requieren, y la #link(<glosario-zonas-p>)[D]#index("Zonas P") generalmente (véase la tabla del #strong[Libro 1 --- Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (ATC)], capítulo 7). Fuera de esos espacios sigue siendo muy recomendable en cualquier zona con tráfico: si está instalado y operativo, la práctica correcta es llevarlo encendido y en modo ALT (transmisión de altitud).

- #strong[7000]: Código VFR estándar.
- #strong[7500]: Interferencia ilícita (secuestro). Solo ante una amenaza real a la integridad de la aeronave. Su uso activa protocolos inmediatos de defensa aérea.
- #strong[7600]: Fallo de radio (#link(<glosario-nordo>)[NORDO]#index("No Radio")).
- #strong[7700]: Emergencia general.
- #strong[Botón IDENT]: Hace parpadear tu etiqueta en el radar. Púlsalo #strong[solo] cuando el controlador lo pida expresamente («#emph[Squawk ident]»).

#postit[
#strong[Resumen del capítulo: principios de propagación VHF]

- #strong[Alcance Visual]: Las ondas VHF viajan en línea recta. Si hay una montaña entre la antena y tú, no te oirán. La altura es tu aliada: a mayor altitud, mayor alcance (1.23 × √H).
- #strong[Separación 8.33 kHz]: El espacio aéreo está saturado. Para meter más canales, se redujo el ancho de banda. Asegúrate de que tu radio es "8.33 compliant" o no podrás sintonizar muchas frecuencias modernas.
- #strong[Squelch]: Es la "puerta de ruido". Ajústalo justo hasta que desaparezca el ruido de fondo ("siseo"). Si lo cierras demasiado, bloquearás señales débiles pero importantes.
- #strong[Bloqueo]: En valles profundos, puedes perder contacto con la red de repetidores. Ten previsto un plan de comunicaciones (o un relé con otro avión) si vuelas bajo en montaña.
- #strong[Frecuencias clave]: 121,500 MHz (emergencia internacional, escucha permanente). 122,600 / 123,375 / 123,400 MHz (vuelo a vela). 123,450 MHz (charla entre pilotos). 123,500 MHz (aeródromo no controlado genérico). FIS regionales: consultar AIP España GEN 3.3.
- #strong[Transpondedor (XPDR)]: Responde automáticamente al radar secundario (#link(<glosario-ssr>)[SSR]#index("SSR")). Códigos: #strong[7000] (VFR estándar), #strong[7600] (fallo de radio --- NORDO), #strong[7700] (emergencia activa). Obligatorio en zonas TMZ (#link(<glosario-sera>)[SERA]#index("SERA")​.6005 b) --- descritas en AIP-España ENR 2.1, carta ENR 6--- y donde lo exijan la clase de espacio aéreo o el AIP (ENR 1.6): clases A y C, y D generalmente. Botón #strong[IDENT]: solo cuando lo pida el ATC.

]
#part[Parte 05: Principios de Vuelo]
= Aerodinámica (flujo de aire)
<aerodinámica-flujo-de-aire>
#quote(block: true)[
La aerodinámica es el fundamento invisible de todo lo que hace un planeador en el aire. En este capítulo aprenderás cómo la diferencia de presión entre extradós e intradós genera sustentación, qué es la #link(<glosario-capa-limite>)[capa límite]#index("Capa límite") y por qué un solo mosquito aplastado en el borde de ataque puede degradar el rendimiento de un perfil laminar, y cómo las dos grandes familias de resistencia aerodinámica determinan la velocidad óptima de planeo.
]

== Principio de Bernoulli y sustentación
<principio-de-bernoulli-y-sustentación>
La sustentación se genera por una diferencia de presiones entre la parte superior (extradós) y la inferior (intradós) del ala.

Cuando el planeador avanza, el aire fluye sobre el perfil curvado del extradós acelerándose, mientras que el aire que pasa por el intradós viaja a menor velocidad. Según el #link(<glosario-bernoulli-teorema-de>)[teorema de Bernoulli]#index("Bernoulli, teorema de"), cuando la velocidad de un fluido aumenta, su presión estática disminuye: el extradós queda con menos presión que el intradós, y esa diferencia crea la fuerza neta ascendente que contrarresta el peso del planeador.

#block[
#callout(
body: 
[
La sustentación admite dos descripciones del #strong[mismo] fenómeno, no dos fuerzas que se sumen: la diferencia de presión (Bernoulli) y la deflexión del aire hacia abajo en el borde de salida (acción-reacción, tercera ley de Newton). El ala que acelera el aire por arriba es la misma que lo desvía hacia abajo; ambas miradas dan la misma fuerza.

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
== La capa límite
<la-capa-límite>
La capa límite es la fina lámina de aire en contacto directo con la piel del ala. El rozamiento viscoso frena esa capa progresivamente hasta que la velocidad llega a cero sobre la superficie misma. Tiene dos regímenes:

- #strong[Laminar:] el flujo se desliza en láminas paralelas y ordenadas. Genera la mínima fricción posible y es el objetivo principal del diseño de los planeadores modernos.
- #strong[Turbulenta:] el flujo se desordena en pequeños remolinos. El rozamiento aumenta mucho respecto al régimen laminar, la capa se engrosa y el planeo se resiente. Tiene, eso sí, una virtud: al llevar más energía, se aferra mejor al perfil y tarda más en desprenderse. Por eso muchos planeadores montan turbuladores (esa cinta en zigzag que habrás visto en algún Discus): fuerzan la transición a turbulenta justo donde conviene evitar que el flujo se separe.

El punto de la cuerda donde el flujo laminar pasa a ser turbulento se llama #strong[punto de transición] (#ref(<fig-05-cap01-capa-limite>, supplement: [Figura])). Para mantener la capa límite laminar sobre la mayor superficie posible, las alas deben estar completamente limpias; un simple mosquito aplastado en el borde de ataque basta para provocar una transición prematura a capa turbulenta. Si el ángulo de ataque aumenta en exceso, el flujo entra en fase de #strong[separación]: se desprende del ala y provoca una caída masiva de sustentación con un gran aumento de resistencia (#strong[stall] o pérdida).

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap01-capa-limite.jpg"))
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
El #link(<glosario-centro-de-presiones>)[centro de presiones]#index("Centro de Presiones") (CP) es el punto de la cuerda alar donde actúa la fuerza neta de sustentación. No es fijo: se desplaza con el ángulo de ataque.

La regla:

- Más ángulo de ataque → CP avanza hacia el borde de ataque.
- Bajas el morro → CP retrocede.

Ese vaivén continuo afecta directamente al equilibrio en cabeceo.

#block[
#callout(
body: 
[
Debido a la movilidad del CP, el diseño de la aeronave obliga a situar el centro de gravedad (#link(<glosario-cg>)[CG]#index("CG")) por delante del centro de presiones en las condiciones normales de vuelo. Esa configuración proporciona #strong[estabilidad longitudinal positiva]. Para contrarrestar la tendencia a picar (hundir el morro) que produce el CG adelantado, el estabilizador horizontal genera una fuerza descendente que mantiene el equilibrio en cabeceo.

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
== Tipos de resistencia y curva de resistencias
<tipos-de-resistencia-y-curva-de-resistencias>
Todo lo que mantiene al planeador en el aire tiene su precio: la resistencia al avance (#strong[drag]). Se divide en dos componentes:

- #strong[#link(<glosario-resistencia-parasita>)[Resistencia parásita]#index("Resistencia parásita"):] la que produce cualquier objeto sólido al moverse a través de un fluido. Crece con el cuadrado de la velocidad (si la velocidad se duplica, la resistencia se cuadruplica). Se compone de:

  - Fricción superficial de las alas y fuselaje.
  - Resistencia de forma (perfil de las piezas).
  - Resistencia de interferencia (donde dos superficies ortogonales se unen, como el encastre del plano con el fuselaje).

- #strong[#link(<glosario-resistencia-inducida>)[Resistencia inducida]#index("Resistencia inducida"):] el subproducto directo de generar sustentación. La diferencia de presión entre extradós e intradós hace que el aire fluya en sentido contrario alrededor de las puntas del ala, desde la zona de alta presión (intradós) hacia la de baja presión (extradós). Ese rodeo genera #strong[torbellinos helicoidales] que se desprenden de cada punta y que, al inclinar levemente hacia atrás el vector de sustentación resultante, crean una fuerza opositora al avance: la resistencia inducida (#ref(<fig-05-cap01-vortices-punta-ala>, supplement: [Figura])). Al contrario que la parásita, es máxima a velocidades bajas (y altos ángulos de ataque) y disminuye a medida que el planeador acelera.

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap01-vortices-punta-ala.png"))
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

La suma de ambas resistencias en función de la velocidad forma una curva en "U". El punto más bajo de esa curva es la velocidad donde la resistencia aerodinámica total es mínima. Volando exactamente a esa velocidad, el planeador alcanza la mejor relación sustentación/resistencia (L/#link(<glosario-zonas-p>)[D]#index("Zonas P")): el ángulo de planeo óptimo para maximizar el alcance horizontal.

== El efecto suelo
<el-efecto-suelo>
Cuando el planeador vuela a muy baja altura sobre la pista ---generalmente por debajo de una envergadura de ala sobre el terreno---, entra en una zona de influencia aerodinámica denominada #strong[efecto suelo]. El terreno actúa como una barrera física que interrumpe la formación normal de los torbellinos de punta de ala y reduce la intensidad del flujo descendente que los alimenta (#strong[downwash]).

El resultado es una reducción significativa de la resistencia inducida que mejora transitoriamente la relación L/D del planeador (#ref(<fig-05-cap01-efecto-suelo>, supplement: [Figura])):

- Durante el aterrizaje, el planeador "flota" más de lo esperado: al caer la resistencia inducida, apenas decelera y el ala sigue sustentando a velocidades algo inferiores a las que necesitaría en vuelo libre. Un piloto que entra largo o demasiado rápido puede consumir cientos de metros de pista sin posarse.
- Durante el despegue en aeroplano remolcado, el planeador puede despegar a velocidades ligeramente más bajas de las normales. Una vez que abandona el efecto suelo, la resistencia inducida recupera su valor normal y puede producirse una ligera pérdida de ascenso si la velocidad no es suficiente.

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap01-efecto-suelo.jpg"))
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
El efecto suelo puede sorprender al piloto inexperto: el planeador parece no querer posarse durante la toma. Si estás entrando en la zona de contacto con exceso de velocidad o inercia, resiste la tentación de picar el morro para forzar el aterrizaje. Usa los frenos aerodinámicos para controlar el planeo y déjalo posarse solo cuando esté listo, asegurándote antes de tener pista suficiente.

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
#strong[Resumen del capítulo: aerodinámica y flujo de aire]

- #strong[Principio de Bernoulli]: la #link(<glosario-base>)[base]#index("Tramo de base") del vuelo. El aire se acelera sobre la superficie curva del ala (extradós) y su presión disminuye, generando una fuerza neta hacia arriba. Es la misma sustentación que describe la deflexión del aire hacia abajo (Newton): dos miradas de un único fenómeno, no dos fuerzas que se sumen.
- #strong[Capa límite]: esa fina capa de aire pegada al ala. Si es #strong[laminar] (ordenada), la resistencia es mínima: el santo grial de los veleros modernos. Si se vuelve #strong[turbulenta], la resistencia sube, pero el ala sigue sustentando. Solo cuando el flujo se #strong[separa] del perfil la sustentación se desploma: eso es la pérdida.
- #strong[Centro de presiones (CP)]: el punto donde se aplica la fuerza de sustentación. Cuidado: se mueve con el ángulo de ataque (adelante con altos ángulos, atrás con bajos), lo que afecta a la estabilidad.
- #strong[Tipos de resistencia]: #strong[parásita] (roce con el aire, sube con la velocidad) e #strong[inducida] (precio por generar sustentación, baja con la velocidad). La inducida viene de los torbellinos de punta de ala que inclinan el vector de sustentación. Los planeadores la minimizan con alta razón de aspecto (alas largas y estrechas) y winglets en las puntas.
- #strong[Efecto suelo]: por debajo de una envergadura de altura sobre el terreno, los vórtices de punta se comprimen, la resistencia inducida cae y el planeador "flota" con más eficiencia de la normal. Útil conocerlo: explica por qué en el aterrizaje el planeador no se posa si entras rápido o largo.

]
= Mecánica de vuelo
<mecánica-de-vuelo>
#quote(block: true)[
Sin motor, la gravedad es tu único combustible. En este capítulo aprenderás a interpretar la #link(<glosario-curva-polar>)[curva polar]#index("Curva polar") de tu planeador para extraer el máximo rendimiento, a ajustar la velocidad según el viento y las descendencias, y a entender el #link(<glosario-factor-de-carga>)[factor de carga]#index("Factor de carga") para volar en viraje sin comprometer la estructura ni acercarte a la pérdida sin darte cuenta.
]

== El motor es la gravedad
<el-motor-es-la-gravedad>
Un planeador no tiene motor. Una vez suelto del remolque, su único combustible es la altura que lleva bajo las alas.

El vuelo planeando es un intercambio permanente: la energía potencial (altitud) se convierte en cinética (velocidad). Para que el ala siga sustentando, el planeador baja levemente el morro frente a la #link(<glosario-masa-de-aire>)[masa de aire]#index("Masa de aire"). Esa inclinación hace que una componente del peso apunte hacia adelante a lo largo de la trayectoria, actuando como tracción y equilibrando la resistencia aerodinámica (#strong[drag]).

#block[
#callout(
body: 
[
La velocidad te da el mando del planeador; la altura es tu reserva de energía. Cediendo altura ganas velocidad (palanca adelante) y, gastando el exceso de velocidad, puedes recuperar algo de trayectoria ascendente (palanca atrás). Pero ese intercambio dura poco: la reserva solo se rellena subiendo en una ascendencia.

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
== La curva polar
<la-curva-polar>
La curva polar es el DNI de rendimiento de tu planeador. Muestra la relación entre velocidad (km/h) y tasa de descenso (m/s) en aire en calma. Conocerla es obligatorio, porque de ella salen las dos velocidades clave para operar (#ref(<fig-05-cap02-curva-polar>, supplement: [Figura])):

- #strong[#link(<glosario-velocidad-de-minimo-descenso>)[Velocidad de mínimo descenso]#index("Velocidad de mínimo descenso") (V#sub[z~min]):] está en el pico superior de la curva (el punto del eje Y más próximo a cero). Volando a esta velocidad pierdes la mínima altura por unidad de tiempo, así que es la que maximiza tu permanencia en el aire. Es tu referencia al virar de forma pronunciada dentro del núcleo de una #link(<glosario-termica>)[térmica]#index("Térmica") o en una espera.
- #strong[Velocidad de máximo planeo (V#sub[max~planeo], también llamada de mejor planeo o de fineza):] se obtiene trazando una tangente desde el origen de coordenadas (0,0) hasta tocar la curva. Da la mejor relación entre distancia avanzada y altura perdida. Es la velocidad para las transiciones limpias y para conseguir el mayor recorrido posible sobre el terreno.

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap02-curva-polar.jpg"))
], caption: figure.caption(
position: bottom, 
[
La curva #link(<glosario-polar-de-velocidades>)[polar de velocidades]#index("Polar de velocidades") de un planeador
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap02-curva-polar>


== Eficiencia y el coeficiente de planeo (L/D)
<eficiencia-y-el-coeficiente-de-planeo-ld>
El coeficiente de planeo (L/#link(<glosario-zonas-p>)[D]#index("Zonas P")) expresa cuántos metros avanza el planeador por cada metro de altura perdida en aire en calma. Un planeador de escuela como el ASK 21 ronda 35:1 (recorre 35 km por cada kilómetro vertical cedido). Los de regata de clase abierta superan 60:1 gracias a su gran envergadura y perfil laminar.

En el aire real, las cifras del manual se quedan en teoría: el viento y las masas de aire en movimiento obligan a ajustar las velocidades.

- #strong[Viento de cara:] con viento en contra, el avance sobre el terreno disminuye aunque mantengas la misma velocidad aerodinámica. Vuela más rápido que la V#sub[max~planeo]: como regla práctica, suma un 50% de la componente frontal del viento a tu velocidad de transición (#ref(<fig-05-cap02-curva-polar-viento-de-cara>, supplement: [Figura])).

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap02-curva-polar-viento-de-cara.png"))
], caption: figure.caption(
position: bottom, 
[
La curva polar de velocidades de un planeador con viento de cara
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap02-curva-polar-viento-de-cara>


- #strong[Viento de cola:] con viento a favor, el terreno avanza más deprisa de lo que la polar indica. Puedes volar algo más despacio que la V#sub[max~planeo] en calma, pero nunca por debajo de la V#sub[z~min]. No es un ajuste grande; el margen sobre la pérdida siempre tiene prioridad.
- #strong[Aire descendente:] cuando atraviesas una masa de aire que baja, tu tasa de descenso real aumenta en esa misma cantidad. La velocidad óptima de cruce sube por encima de la V#sub[max~planeo]: vuela más rápido para salir cuanto antes de esa zona y limitar la altura perdida en ella.

#block[
#callout(
body: 
[
Acostúmbrate a planificar los tramos finales y las tomas fuera de aeródromo con el L/D del manual recortado. Contar con la mitad del valor publicado en el Manual de Vuelo (#link(<glosario-afm>)[AFM]#index("AFM")) te protege de quedarte bajo y corto cuando se suman el viento de cara, el aire que baja y la suciedad o los mosquitos acumulados en el borde de ataque, que merman el rendimiento más de lo que parece.

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
=== El lastre de agua y la curva polar
<el-lastre-de-agua-y-la-curva-polar>
Algunos planeadores llevan depósitos de agua en las alas. El lastre no cambia la forma del ala: simplemente pesa más, y eso empuja la curva polar hacia la derecha. La V#sub[max~planeo] y la V#sub[z~min] suben, y la tasa de descenso mínima también sube un poco.

¿Para qué sirve? En un día de térmicas fuertes con largas etapas entre ellas, el planeador lastrado cruza más rápido manteniendo el mismo planeo; en regata eso se traduce en minutos ganados. El precio: en térmicas débiles sube peor, porque necesita más velocidad y el círculo se come más altura. Antes de aterrizar, el lastre se larga.

El punto clave, y el que suele caer en el examen: #strong[el lastre no cambia el L/D máximo]. La fineza máxima es la misma con y sin agua; lo único que cambia es la velocidad a la que se obtiene, que sube con el peso. Por eso el planeador lastrado vuela más rápido «por el mismo planeo». El cálculo de masa y centrado que hace posible cargar ese lastre se desarrolla en el #strong[Libro 7 --- Planificación y Rendimiento de Vuelo], capítulo 2.

=== Aerofrenos y flaps: modificar la polar a voluntad
<aerofrenos-y-flaps-modificar-la-polar-a-voluntad>
Dos dispositivos permiten al piloto cambiar la forma de la curva polar cuando le conviene:

- #strong[#link(<glosario-aerofrenos>)[Aerofrenos]#index("Aerofrenos") (airbrakes o spoilers)]: al extenderse, destruyen sustentación y añaden mucha resistencia. La polar entera se desploma: para una misma velocidad, la tasa de descenso se dispara. Son la herramienta de control de senda en la aproximación ---permiten bajar sin acelerar--- y su efecto operativo en el circuito se detalla en el #strong[Libro 6 --- Procedimientos operativos].
- #strong[#link(<glosario-flaps>)[Flaps]#index("Flaps")]: modifican la curvatura del perfil. En posición positiva aumentan la sustentación y desplazan la polar hacia velocidades bajas (útil en térmica); en posición negativa la reducen y la desplazan hacia velocidades altas (útil en transición rápida). No todos los veleros los llevan.

La descripción constructiva de estos dispositivos ---cómo son y cómo se accionan--- corresponde al #strong[Libro 8 --- Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia], capítulo 5; aquí interesa su efecto aerodinámico sobre la polar y la pérdida.

== El factor de carga (n)
<el-factor-de-carga-n>
El #strong[factor de carga] (n) indica cuántas veces el peso del planeador está cargando sobre la estructura en cada #link(<glosario-momento>)[momento]#index("Momento"). Se expresa en unidades #strong[g].

En vuelo recto y nivelado la sustentación iguala exactamente al peso: #strong[n = 1g]. En cuanto el planeador se inclina en un viraje, la fuerza centrífuga se suma a la gravedad y el factor de carga sube. En un viraje de 60° de inclinación, la estructura ---y el piloto--- soportan #strong[2g]: el planeador pesa estructuralmente el doble, y el ala debe generar el doble de sustentación. A 75° la carga llega casi a 4g (#ref(<fig-05-cap02-factor-de-carga-alabeo>, supplement: [Figura])).

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap02-factor-de-carga-alabeo.png"))
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
Cuando el factor de carga sube, la velocidad de pérdida (#strong[stall]) también sube ---y lo hace más rápido de lo que parece. La relación es con la raíz cuadrada del factor #strong[n]: en un viraje de 60° donde soportamos #strong[2g], nuestra velocidad de pérdida aumenta un #strong[41%]. Si normalmente perdemos a 60 km/h, en ese viraje la pérdida llega a 85 km/h, aunque el mando responda con aparente normalidad.

El patrón más letal de la estadística de accidentes en planeador es siempre el mismo: maniobra de aterrizaje, altura escasa, velocidad baja, y de repente una pisada brusca de pedales con alabeo exagerado. La pérdida llega sin avisar, y a esa altura no hay margen para recuperar.

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
#strong[Resumen del capítulo: mecánica de vuelo]

- #strong[El motor es la gravedad]: el planeador siempre cae a través de la masa de aire. Convertimos altura (energía potencial) en velocidad (cinética) bajando el morro. La componente del peso hacia adelante actúa como "tracción".
- #strong[La curva polar]: es el DNI del planeador. Relaciona velocidad horizontal con tasa de caída. Te dice a qué velocidad volar para llegar más lejos (máximo planeo) o para mantenerte más tiempo (mínimo descenso).
- #strong[Eficiencia (L/D)]: la fineza. Un planeador 35:1 avanza 35 km por cada kilómetro de altura en aire calmo. Pero ojo: el viento de cara y las descendencias destruyen ese número en la práctica. Ajusta la velocidad de transición según el viento (más rápido con viento de cara y en aire descendente; algo más despacio con viento de cola) y descuenta siempre un margen de seguridad del L/D publicado.
- #strong[#link(<glosario-lastre-de-agua>)[Lastre de agua]#index("Lastre de agua")]: desplaza la polar a la derecha: suben la V#sub[max~planeo] y la V#sub[z~min]. Ventajoso en condiciones fuertes y largas transiciones; penaliza en térmicas débiles. Se larga antes del aterrizaje.
- #strong[Factor de carga (n)]: en giros o maniobras bruscas, el peso aparente aumenta (n \> 1g) y con él la velocidad de pérdida. Recuerda: en un viraje de 60° pesas el doble (2g) y tu velocidad de pérdida sube un 41%.

]
= Estabilidad
<estabilidad>
#quote(block: true)[
Un planeador bien diseñado quiere volver al equilibrio cuando algo lo perturba. En este capítulo aprenderás qué hace que un planeador sea estable longitudinal, lateral y direccionalmente, por qué la posición del Centro de Gravedad es el parámetro más crítico que debes verificar antes de cada vuelo, y cómo el #link(<glosario-diedro>)[ángulo diedro]#index("ángulo diedro") y la #link(<glosario-deriva>)[deriva]#index("Deriva") trabajan juntos para mantenerte nivelado y alineado sin esfuerzo.
]

== La estabilidad estática
<la-estabilidad-estática>
La estabilidad de una aeronave es su capacidad inherente para recuperar el equilibrio tras una perturbación atmosférica. Cuando una racha de viento desplaza al planeador de su actitud nivelada, la respuesta inmediata de la máquina sin intervención del piloto se define como #strong[#link(<glosario-estabilidad-estatica>)[estabilidad estática]#index("Estabilidad estática")].

Según su diseño, el comportamiento del planeador puede clasificarse en tres tipos:

- #strong[Estabilidad estática positiva:] el planeador tiende a regresar por sí solo a su posición inicial tras ser perturbado. Es la condición de diseño fundamental para la seguridad en aeronaves civiles.
- #strong[Estabilidad estática neutra:] la aeronave no intenta corregir la perturbación, pero tampoco la amplifica. Si una racha sube el morro 5 grados, el planeador se mantiene en esa nueva actitud sin retornar a la anterior ni seguir subiendo.
- #strong[Estabilidad estática negativa (inestabilidad):] la aeronave tiende a alejarse cada vez más de su posición de equilibrio original. Es una condición peligrosa: una pequeña perturbación de morro arriba haría que el planeador siguiera encabritándose de forma progresiva y acelerada.

#block[
#callout(
body: 
[
Los veleros de escuela suelen diseñarse con una estabilidad estática positiva muy marcada para facilitar el aprendizaje y perdonar errores del alumno. Sin embargo, esto los hace más "pesados" o perezosos de mando. Los veleros de alta competición o acrobacia reducen esta estabilidad para ganar agilidad y respuesta inmediata.

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
== La estabilidad dinámica
<la-estabilidad-dinámica>
La estabilidad estática describe solo la #strong[reacción inicial] de la aeronave: si tiende a volver o a alejarse. La #strong[#link(<glosario-estabilidad-dinamica>)[estabilidad dinámica]#index("Estabilidad dinámica")] describe lo que ocurre a continuación, cuando el planeador comienza a oscilar mientras intenta regresar al equilibrio.

Según cómo evolucionen esas oscilaciones en el tiempo, el comportamiento puede clasificarse en tres tipos (#ref(<fig-05-cap03-estabilidad-dinamica>, supplement: [Figura])):

- #strong[Amortiguada (positiva):] las oscilaciones van reduciéndose progresivamente hasta que el planeador recupera su actitud original. Es la condición de diseño deseada.
- #strong[Neutra:] las oscilaciones se mantienen constantes en amplitud, sin crecer ni decrecer. El planeador nunca vuelve al equilibrio exacto, pero tampoco empeora.
- #strong[Divergente (negativa):] las oscilaciones crecen en amplitud con cada ciclo. Una perturbación pequeña se convierte en un movimiento cada vez mayor hasta perder el control.

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap03-estabilidad-dinamica.png"))
], caption: figure.caption(
position: bottom, 
[
Respuesta dinámica de una aeronave: oscilación neutra, positiva y negativa
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap03-estabilidad-dinamica>


Dos modos de oscilación merecen atención especial en un planeador:

- #strong[#link(<glosario-fugoide>)[Modo fugoide]#index("modo fugoide"):] una oscilación longitudinal lenta y de gran periodo (típicamente 30-60 segundos). El planeador sube y baja intercambiando altitud y velocidad en ciclos suaves. Su amortiguamiento es débil, pero el ciclo es tan lento que lo corriges sin darte cuenta con los pequeños ajustes de palanca de siempre; solo aflora si sueltas los mandos un buen rato.
- #strong[#link(<glosario-tendencia-espiral>)[Tendencia espiral]#index("Tendencia espiral"):] una inestabilidad dinámica lateral. La mayoría de los planeadores son estáticamente estables en alabeo, pero dinámicamente tienden a una ligera #strong[divergencia espiral]: si se les abandona con un pequeño ángulo de inclinación, el alabeo crece lentamente hasta convertirse en una espiral descendente. Por eso el piloto debe vigilar siempre la actitud lateral, especialmente en nube o al perder las referencias visuales del horizonte.

#block[
#callout(
body: 
[
La tendencia espiral es el origen de la mayoría de los incidentes por pérdida de control en condiciones de #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") reducida. Un planeador abandonado con cinco grados de alabeo puede, en cuestión de minutos, desarrollar una espiral descendente fatal. Nunca vueles sin referencias visuales del horizonte real.

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
== Estabilidad longitudinal: el papel del CG
<estabilidad-longitudinal-el-papel-del-cg>
La estabilidad longitudinal controla el cabeceo. El parámetro que lo determina es la posición del Centro de Gravedad (#link(<glosario-cg>)[CG]#index("CG")) respecto al #link(<glosario-centro-de-presiones>)[Centro de Presiones]#index("Centro de Presiones") (CP).

Para que el planeador sea estable en cabeceo, el #strong[CG debe situarse por delante del CP] en las condiciones normales de vuelo. Esa configuración crea un #link(<glosario-momento>)[momento]#index("Momento") natural de "morro abajo". Para equilibrar el vuelo, el estabilizador horizontal genera una fuerza hacia abajo, manteniendo el planeador nivelado.

- #strong[CG demasiado adelantado:] aumenta la estabilidad, pero hace al planeador excesivamente "cabezón" y difícil de maniobrar, especialmente durante el despegue y el aterrizaje. La eficiencia L/#link(<glosario-zonas-p>)[D]#index("Zonas P") disminuye por el aumento de resistencia en la cola para compensar el peso del morro.
- #strong[CG demasiado atrasado:] es la condición crítica y peligrosa. Si el CG queda por detrás de los límites permitidos, el planeador se vuelve inestable: ante cualquier perturbación el morro tiende a subir de forma descontrolada. Y hay algo peor: si la pérdida degenera en barrena, el CG atrasado tiende a aplanarla, y una barrena plana deja a los mandos sin autoridad para romperla.

#block[
#callout(
body: 
[
El Reglamento (UE) 2018/1976, #link(<glosario-part-sao>)[Part-SAO]#index("Part-SAO"), punto #link(<glosario-sao>)[SAO]#index("SAO")​.GEN.130 d)4), establece que el #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando") deberá "iniciar un vuelo únicamente tras cerciorarse de que \[…​\] la masa del planeador y la ubicación de su centro de gravedad permiten efectuar el vuelo dentro de los límites definidos por el manual de vuelo de la aeronave (#link(<glosario-afm>)[AFM]#index("AFM"))".

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
== Estabilidad lateral: el efecto diedro
<estabilidad-lateral-el-efecto-diedro>
La estabilidad lateral es la tendencia del planeador a nivelar sus alas tras una perturbación que cause un alabeo no deseado. El principal recurso de diseño para lograr esto es el #strong[ángulo diedro].

El diedro es el ángulo hacia arriba que forman las alas respecto a la horizontal, otorgando al planeador una forma vista de frente similar a una "V" muy abierta (#ref(<fig-05-cap03-efecto-diedro>, supplement: [Figura])).

Cuando una racha inclina un ala (por ejemplo, la izquierda), el planeador comienza a resbalar lateralmente hacia ese lado. Debido al ángulo diedro, el ala que baja recibe el flujo de aire con un ángulo de ataque efectivo mayor que el ala que sube. Esto genera un exceso de sustentación en el ala bajada que empuja al planeador de vuelta a su posición nivelada de forma automática.

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap03-efecto-diedro.jpg"))
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
#box(image("05-principios-vuelo/imagenes/05-cap03-efecto-veleta.png"))
], caption: figure.caption(
position: bottom, 
[
#link(<glosario-efecto-veleta>)[Efecto veleta]#index("Efecto veleta"): la deriva realinea el morro con el viento relativo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap03-efecto-veleta>


#postit[
#strong[Resumen del capítulo: estabilidad]

- #strong[Estabilidad estática]: es la tendencia inicial. Si sueltas los mandos tras un bache y el avión tiende a volver a su posición original, es estable. Si tiende a alejarse más (divergencia), es inestable y peligroso.
- #strong[Estabilidad dinámica]: describe lo que pasa #strong[después] de la reacción inicial. ¿Las oscilaciones se amortiguan (bueno), se mantienen iguales (neutro) o crecen (peligroso)? El modo fugoide es una oscilación longitudinal lenta e inocua. La #strong[tendencia espiral] (divergencia lateral lenta) es la más importante: si sueltas los mandos con un pequeño alabeo, la espiral crece sola.
- #strong[El CG es el rey]: la posición del centro de gravedad determina la estabilidad longitudinal. CG adelantado = muy estable pero "pesado". CG atrasado = muy sensible e inestable (riesgo de barrena plana irrecuperable).
- #strong[Estabilidad lateral (diedro)]: la forma en "V" de las alas ayuda a nivelar el avión solo. Si un ala baja, el diedro hace que tenga más ángulo de ataque efectivo y suba.
- #strong[Estabilidad direccional]: la deriva (cola vertical) actúa como una veleta, manteniendo el morro apuntando al viento relativo y evitando el vuelo cruzado.

]
= Control
<control>
#quote(block: true)[
Los mandos de un planeador son mucho más que palancas y pedales: son el canal de comunicación entre el piloto y la aeronave. En este capítulo aprenderás a entender la guiñada adversa y cómo combatirla con coordinación pie-mano, por qué el #link(<glosario-compensador>)[compensador]#index("Compensador") es una herramienta fundamental de pilotaje y no un descanso para el brazo, y qué información te transmiten los mandos a través de su dureza o blandura.
]

== Guiñada adversa: el precio del alabeo
<guiñada-adversa-el-precio-del-alabeo>
En los planeadores, la guiñada adversa es un efecto secundario aerodinámico muy pronunciado al intentar virar usando los alerones, debido a su gran envergadura.

Al accionar la palanca lateralmente para iniciar un giro, el alerón del ala exterior baja para aumentar la sustentación y levantar ese lado. El problema es que, al crear más sustentación, también genera una gran cantidad de #strong[#link(<glosario-resistencia-inducida>)[resistencia inducida]#index("Resistencia inducida")]. Esta resistencia frena el ala que sube y tira de ella hacia atrás, haciendo guiñar el morro del planeador en dirección opuesta al giro deseado (#ref(<fig-05-cap04-guinada-adversa>, supplement: [Figura])).

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap04-guinada-adversa.png"))
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
La solución a la guiñada adversa es la #strong[Coordinación Pie-Mano]. Se debe aplicar palanca y pedal hacia el mismo lado y al mismo tiempo. El timón de dirección contrarresta el freno abrupto del ala exterior, forzando al morro a seguir la curva suavemente sin derrapar.

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
== Mando diferencial de alerones
<mando-diferencial-de-alerones>
Para mitigar la guiñada adversa de manera mecánica, los planeadores utilizan el #strong[#link(<glosario-mando-diferencial-de-alerones>)[mando diferencial de alerones]#index("Mando diferencial de alerones")].

Este sistema ajusta el varillaje de modo que el alerón que sube (en el ala interior del giro) recorra un ángulo mayor que el alerón que baja (en el ala exterior). Al subir más el alerón interior, se genera intencionadamente una mayor #link(<glosario-resistencia-parasita>)[resistencia parásita]#index("Resistencia parásita") en ese lado que ayuda a compensar la resistencia inducida del ala exterior. Aunque este diseño reduce notablemente la tendencia del morro a salirse del giro, no la elimina por completo; el piloto debe seguir aplicando siempre el timón de dirección (pedal) para mantener un viraje coordinado.

== El hilo de lana: tu indicador de coordinación
<el-hilo-de-lana-tu-indicador-de-coordinación>
En el parabrisas de casi todos los planeadores hay, pegado en el centro, un trocito de hilo de lana o cinta fina: el #strong[hilo de coordinación] (#strong[yaw string]). Es el indicador más directo que existe, más fiable incluso que la bola del inclinómetro.

Hilo recto: vuelo coordinado. Cuando se desvía, el hilo se va hacia el mismo lado al que apunta el morro respecto a la trayectoria: hilo a la izquierda, morro a la izquierda del viento relativo. Lo que eso significa depende del sentido del viraje. Hilo caído hacia el interior del giro: derrape (#strong[skid]), llevas demasiado pedal interior. Hilo hacia el exterior: resbale (#strong[slip]), te falta pedal. La corrección es siempre la misma: pisa el pedal contrario al lado del hilo, nunca la palanca.

El derrape es el que hay que evitar: el ala interior va más lenta y puede alcanzar el #link(<glosario-angulo-de-ataque-critico>)[ángulo de ataque crítico]#index("Ángulo de ataque crítico") sin previo aviso, iniciando una pérdida asimétrica. El resbale es más aparatoso ---el fuselaje ofrece más resistencia y el viraje es ineficiente---, pero rara vez es peligroso por sí solo. La #ref(<fig-05-cap04-hilo-lana-estados>, supplement: [Figura]) resume los tres estados del hilo y su lectura.

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap04-hilo-lana-estados.png"))
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
Vuela con el hilo recto. Si se mueve, corrígelo con el pedal. Y si el hilo está torcido y los mandos están blandos al mismo tiempo, actúa: estás a punto de entrar en pérdida.

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
== El compensador (trim)
<el-compensador-trim>
El compensador (trim) no es solo un alivio para el brazo. Es, de hecho, un mando aerodinámico: equilibra las fuerzas en la cola y permite que el planeador mantenga por sí solo una actitud de morro y velocidad constantes sin que tengas que empujar ni tirar.

#block[
#callout(
body: 
[
Acostúmbrate a usar el compensador constantemente. Después de cambiar el régimen de vuelo (por ejemplo, de termicar a velocidad lenta a volar recto a mayor velocidad), primero establece la nueva actitud con la palanca y luego ajusta el trim hasta que no sientas fuerza en la mano.

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
== La eficacia de mando
<la-eficacia-de-mando>
Los mandos te proporcionan información vital sobre la velocidad del planeador a través de su resistencia física.

Cuando vuelas rápido, el flujo de aire golpea con fuerza las superficies de control. Los mandos se sentirán #strong[duros] y muy reactivos.

Sin embargo, a medida que reduces la velocidad acercándote a la entrada en pérdida, el flujo de aire disminuye. Los mandos pierden eficacia y se vuelven blandos o #strong["chiclosos"]. Esta falta de respuesta es una advertencia física directa de que estás volando demasiado lento y cerca del límite de sustentación.

#postit[
#strong[Resumen del capítulo: control]

- #strong[Guiñada adversa]: el efecto secundario más molesto en los veleros de gran envergadura. Al alabear para girar, el ala que sube tiene más resistencia y frena ese lado, metiendo el morro #strong[al revés] del giro. #strong[Antídoto]: pie y mano juntos (coordinación).
- #strong[Hilo de lana (yaw string)]: indicador de coordinación en el parabrisas. Recto = vuelo coordinado. Hilo hacia el interior del viraje = derrape (#strong[skid]); hacia el exterior = resbale (#strong[slip]). El derrape es el peligroso: el ala interior puede entrar en pérdida asimétrica. Corrígelo pisando el pedal contrario al lado del hilo.
- #strong[Compensador (trim)]: no es solo para descansar el brazo. Es fundamental para mantener una velocidad constante sin esfuerzo. Compensa siempre que cambies de régimen de vuelo (de termicar a planear rápido).
- #strong[#link(<glosario-eficacia-de-mando>)[Eficacia de mando]#index("Eficacia de mando")]: los mandos "hablan". Si están duros, vas rápido. Si están blandos y "chiclosos", estás cerca de la pérdida. Escucha lo que te dicen a través de la mano.
- #strong[Mando diferencial]: diseño de los alerones para reducir la guiñada adversa (el alerón que sube lo hace más que el que baja), pero aun así necesitarás pie.

]
= Limitaciones (factor de carga y maniobras)
<limitaciones-factor-de-carga-y-maniobras>
#quote(block: true)[
Todo planeador tiene límites estructurales que no deben franquearse: hacerlo puede destruir la aeronave en segundos. En este capítulo aprenderás a interpretar el #link(<glosario-diagrama-v-n>)[diagrama V-n]#index("Diagrama V-n"), a entender por qué la Velocidad de Maniobra protege la estructura en turbulencia, qué significa la línea roja del anemómetro y por qué el #link(<glosario-factor-de-carga>)[factor de carga]#index("Factor de carga") eleva la velocidad de pérdida en los virajes.
]

== El diagrama V-n: el mapa de tu supervivencia
<el-diagrama-v-n-el-mapa-de-tu-supervivencia>
El diagrama V-n, también conocido como envolvente de vuelo, es la representación gráfica de los límites estructurales de tu planeador. Relaciona la velocidad a la que vuelas (V) con el factor de carga en Gs (n) que la estructura está soportando (#ref(<fig-05-cap05-diagrama-vn>, supplement: [Figura])).

Este diagrama delimita el espacio de operaciones seguras. Mientras te mantengas dentro de sus límites, la estructura aguantará. Si lo superas ---por exceso de G o de velocidad--- el planeador sufrirá deformaciones permanentes o rotura estructural.

Bajo la normativa #link(<glosario-cs>)[CS]#index("CS")-22, los planeadores de categoría Utility (U) están diseñados para soportar de +5,3g a −2,65g a la velocidad de maniobra (V#sub[A]); ambos límites se estrechan a medida que aumenta la velocidad, hasta +4,0g y −1,5g a la velocidad de picado (V#sub[#link(<glosario-zonas-p>)[D]#index("Zonas P")]). Los de categoría Acrobática (A) soportan de +7,0g a −5,0g. Estos factores de carga solo son válidos si se respetan las limitaciones de velocidad.

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap05-diagrama-vn.png"))
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
La velocidad de maniobra (V#sub[A]) es la velocidad máxima a la que puedes aplicar deflexiones totales en los mandos sin causar daños estructurales.

Si vuelas a la V#sub[A] o por debajo de ella y aplicas una deflexión brusca a los mandos, el planeador simplemente #strong[entrará en pérdida] antes de generar suficientes Gs para superar su límite de carga estructural. El ala dejará de volar y descargará la fuerza, protegiendo al planeador. Sin embargo, si vuelas más rápido que la V#sub[A] y haces un movimiento brusco, el planeador no entrará en pérdida a tiempo; generará una fuerza G extrema que sobrepasará los límites de la estructura y la romperá.

La V#sub[A] es un límite estructural, no una marca del anemómetro. La marca que ves en la esfera es la #strong[V#sub[RA]], la velocidad máxima en aire turbulento (#strong[#link(<glosario-vra>)[rough air speed]#index("Rough Air Speed")]): en ella termina el arco verde y empieza el amarillo, según CS 22.1545. En muchos veleros la V#sub[A] y la V#sub[RA] casi coinciden, pero la certificación las distingue, y conviene que tú también: la V#sub[A] te protege frente a la deflexión completa de un mando; la V#sub[RA], frente a las ráfagas del aire turbulento; y la #link(<glosario-vne>)[VNE]#index("VNE") es el límite absoluto donde acaba el arco amarillo con su línea roja.

#block[
#callout(
body: 
[
En turbulencia fuerte, reduce enseguida la velocidad por debajo de la V#sub[A] para proteger la estructura. Tu referencia visual está en el anemómetro: quédate en el arco verde, que termina en la V#sub[RA] (velocidad máxima en aire turbulento). El arco amarillo, de la V#sub[RA] a la VNE, es solo para aire en calma.

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
La V#sub[A] #strong[no te protege de entradas combinadas simultáneas en más de un eje]. Los requisitos de certificación cubren deflexiones completas en un único mando a la vez. Si aplicas timón de profundidad a fondo y pedal a fondo #strong[al mismo tiempo] ---aunque estés por debajo de V#sub[A]--- puedes generar una carga estructural que supere el límite de diseño. En turbulencia, mantén los mandos suaves y evita movimientos bruscos coordinados en múltiples ejes simultáneamente.

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
== La línea roja: velocidad de nunca exceder (VNE)
<la-línea-roja-velocidad-de-nunca-exceder-vne>
La línea roja en el anemómetro indica la VNE (velocidad de nunca exceder). Es un límite absoluto que no se cruza nunca, principalmente por el riesgo de #strong[#link(<glosario-flutter>)[flutter]#index("Flutter")] (flameo).

El flutter es una vibración aeroelástica en las alas o superficies de control que, si ocurre, puede desintegrar el planeador en cuestión de segundos.

#block[
#callout(
body: 
[
La VNE disminuye con la altitud: en aire menos denso, la velocidad aerodinámica verdadera (#link(<glosario-tas>)[TAS]#index("True Air Speed")) ---de la que depende el flutter--- aumenta respecto a la indicada (#link(<glosario-ias>)[IAS]#index("IAS")) que lees en el anemómetro. Presta atención a la tabla de correcciones de VNE por altitud en la cabina. Este efecto es crítico en el #link(<glosario-vuelo-de-onda>)[vuelo de onda]#index("Vuelo de onda"), donde se alcanzan grandes altitudes; su relación con la meteorología de onda se trata en el #strong[Libro 3 --- Meteorología].

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
Cerca de la VNE, mantén las deflexiones de mando limitadas a aproximadamente #strong[un tercio] de su recorrido total. A esa velocidad, la presión dinámica es tan elevada que una deflexión completa genera cargas que pueden superar la envolvente estructural incluso sin turbulencia. No uses la VNE como velocidad de crucero: es un límite absoluto de emergencia, no un régimen habitual.

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
== La trampa del factor de carga y la pérdida
<la-trampa-del-factor-de-carga-y-la-pérdida>
En vuelo recto y nivelado, el factor de carga es 1 G. Al inclinarte en un viraje, la fuerza centrífuga se suma a la gravedad y el factor de carga sube. En un viraje cerrado de 60°, el planeador experimenta 2 G: la estructura soporta el doble del peso normal.

#block[
#callout(
body: 
[
La velocidad de pérdida aumenta con el factor de carga. En un viraje de 60º (2 Gs), la velocidad de pérdida #strong[sube un 41%]. Un planeador que entra en pérdida a 70 km/h en vuelo nivelado lo hará a casi 100 km/h en ese viraje cerrado. Un uso brusco de los mandos en esta situación puede llevar a una pérdida crítica.

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
#strong[Resumen del capítulo: limitaciones y maniobras]

- #strong[Diagrama V-n]: el mapa de seguridad de tu estructura. Muestra los Gs que aguantas a cada velocidad. Salirte de la "caja" significa romper el planeador. Límites #link(<glosario-cs-22>)[CS-22]#index("CS-22"): cat. U +5,3g / −2,65g en V#sub[A], que se estrechan a +4,0g / −1,5g en V#sub[D]\; cat. A +7,0g / −5,0g.
- #strong[Velocidad de maniobra (V#sub[A])]: la velocidad "segura" para turbulencia o mandazos individuales. Si vas más lento de V#sub[A], el planeador entrará en pérdida antes de romperse. Si vas más rápido, una deflexión brusca puede dañar la estructura. Pero cuidado: la V#sub[A] no protege de entradas combinadas simultáneas en más de un eje. En turbulencia fuerte, quédate en el arco verde del anemómetro.
- #strong[Marcas del anemómetro (CS 22.1545)]: el arco verde termina en la #strong[V#sub[RA]] (velocidad máxima en aire turbulento), donde empieza el arco amarillo, que acaba en la línea roja de la VNE. La V#sub[A] es un límite estructural y #strong[no] es una marca del anemómetro, aunque en muchos veleros su valor sea parecido al de la V#sub[RA].
- #strong[VNE (velocidad de nunca exceder)]: la #strong[línea roja] del anemómetro (CS 22.1505). No es una recomendación, es un límite físico. Pasarla invita al #strong[flutter] (vibración aeroelástica), que puede desintegrar el planeador en segundos. Cerca de la VNE, limita las deflexiones de mando a un tercio de su recorrido.
- #strong[Factor de carga y pérdida]: las Gs "engordan" al planeador. En un viraje de 60° (2 Gs), la velocidad de pérdida sube un 41%.

]
= Pérdida de sustentación (#emph[stalling]) y autorrotación (#emph[spinning])
<pérdida-de-sustentación-stalling-y-autorrotación-spinning>
#quote(block: true)[
La pérdida de sustentación y la barrena son las situaciones más temidas por el piloto novel y las más practicadas en formación. En este capítulo aprenderás a reconocer los síntomas que avisan antes de que llegue la pérdida, a ejecutar la recuperación de forma correcta ---aunque vaya contra el instinto--- y a distinguir una pérdida limpia de una autorrotación para aplicar la técnica adecuada en cada caso.
]

== La pérdida de sustentación (stall)
<la-pérdida-de-sustentación-stall>
La pérdida de sustentación ocurre cuando el ala del planeador supera su #strong[#link(<glosario-angulo-de-ataque-critico>)[Ángulo de Ataque Crítico]#index("Ángulo de ataque crítico")] (aproximadamente entre 15º y 18º). Al alcanzar este punto crítico de inclinación respecto al viento relativo, el flujo de aire es incapaz de seguir la curvatura superior del ala (extradós) y se desprende de forma turbulenta, provocando una caída masiva de sustentación y un gran aumento de resistencia.

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
Durante la recuperación de una pérdida, la palanca debe mantenerse siempre rigurosamente centrada en el eje lateral (cero alerones). Intentar levantar instintivamente un ala caída usando los alerones empeorará el escenario: el alerón que baja aumentará el ángulo de ataque local de esa ala caída, profundizando aún más su pérdida e iniciando violentamente la temida autorrotación o barrena. Usa siempre y exclusivamente el pedal contrario (timón de dirección) para evitar la guiñada y sostener las alas.

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
== La pérdida acelerada: el peligro del viraje
<la-pérdida-acelerada-el-peligro-del-viraje>
La velocidad de pérdida que indica el Manual de Vuelo es para vuelo recto y nivelado a 1g. Cada vez que el #link(<glosario-factor-de-carga>)[factor de carga]#index("Factor de carga") sube, esa velocidad sube con él ---en proporción a su raíz cuadrada. En un viraje de 60° (2g), la velocidad de pérdida crece un 41%. Un planeador que en línea recta pierde sustentación a 70 km/h lo hará a casi 100 km/h en ese viraje. A 100 km/h nadie espera entrar en pérdida.

Esta #strong[pérdida acelerada] es traicionera porque el morro no tiene que estar especialmente alto. Con una actitud de morro aparentemente normal, tirar de palanca en un viraje cerrado puede superar el ángulo de ataque crítico sin que el piloto lo note hasta que el ala cede.

#block[
#callout(
body: 
[
El escenario estadísticamente más letal: el viraje del tramo #strong[#link(<glosario-base>)[base]#index("Tramo de base") a #link(<glosario-final>)[final]#index("Tramo final")] en el #link(<glosario-circuito-de-trafico>)[circuito de tráfico]#index("Circuito de tráfico"), a menos de 150 metros de altura. El piloto mete pedal para cuadrar la final, el morro se desvía hacia un lado, compensa tirando de palanca… y el planeador entra en pérdida asimétrica sin margen de recuperación. Volar el circuito coordinado y con margen de velocidad no es una exigencia técnica: es lo que separa un aterrizaje normal de un accidente.

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
La salida de una barrena exige una técnica metódica, contraintuitiva y aprendida de memoria. Consulta siempre el Manual de Vuelo (#link(<glosario-afm>)[AFM]#index("AFM")) de tu planeador concreto; la secuencia clásica universal es:

+ #strong[Pedal contrario a fondo:] identifica la dirección de la rotación y pisa con decisión el pedal opuesto hasta el tope (si giras hacia la derecha, pedal izquierdo a fondo). Esto frena la guiñada que alimenta el giro.
+ #strong[Palanca al centro y adelante:] centra los alerones (neutro lateral) y empuja la palanca hacia adelante para reducir el ángulo de ataque y romper la pérdida profunda en ambas alas por igual.
+ #strong[Recuperación del picado:] en cuanto cese la rotación, #strong[neutraliza el pedal] antes de tirar de la palanca. Si mantienes el pedal contrario aplicado mientras recuperas del picado, la guiñada resultante puede iniciar una rotación en sentido opuesto. Una vez centrados los pedales, tira #strong[gradualmente] de la palanca para salir del picado con suavidad progresiva: una recuperación brusca puede sobrecargar la estructura o provocar una segunda pérdida.

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap06-recuperacion-barrena.png"))
], caption: figure.caption(
position: bottom, 
[
Método estándar de recuperación de una barrena (método universal, pero ¡Consulta el manual de TU planeador!)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-05-cap06-recuperacion-barrena>


#postit[
#strong[Resumen del capítulo: pérdida y autorrotación]

- #strong[Pérdida (stall)]: el ala se "rinde" al superar el ángulo de ataque crítico (≈ 15-18°). La pérdida comienza en el encastre y progresa hacia las puntas: por eso los alerones conservan algo de autoridad al inicio. Avisos: morro alto, mandos blandos y bataneo; al ceder el ala, cae el morro.
- #strong[Pérdida acelerada]: en un viraje cerrado (60° → 2g), la velocidad de pérdida sube un 41%. El ala puede entrar en pérdida con el morro en actitud aparentemente normal. El viraje #strong[base-final] en el circuito es el escenario más letal.
- #strong[Recuperación de la pérdida]: palanca adelante (bajar el morro) es la única cura. No uses los alerones para levantar un ala caída: profundizan la pérdida e inician la barrena.
- #strong[Barrena (autorrotación)]: pérdida agravada y asimétrica con tres fases: #strong[incipiente] (recuperable antes de un giro), #strong[desarrollada] (movimiento constante) y #strong[recuperación] (cesa la rotación). Cada vuelta cuesta 50-100 m de altura.
- #strong[Salida de barrena]: consulta siempre el AFM de tu planeador. La secuencia estándar: 1. pie contrario a la rotación (a fondo); 2. palanca al centro y adelante; 3. cuando pare el giro, #strong[neutraliza el pedal] y entonces recupera suavemente del picado.

]
= Picado en espiral (#emph[spiral dive])
<picado-en-espiral-spiral-dive>
#quote(block: true)[
El picado en espiral engaña al instinto del piloto: parece que hay que tirar de la palanca, pero esa reacción puede ser mortal. En este capítulo aprenderás a distinguirlo de una barrena, a entender por qué intentar subir el morro sin nivelar primero las alas agrava la situación, y a ejecutar la secuencia de recuperación correcta ---nivelar las alas, recuperar suave del picado y controlar la velocidad--- de forma procedimental y sin margen de error.
]

== Diferencias críticas: no es una barrena
<diferencias-críticas-no-es-una-barrena>
Es vital no confundir un picado en espiral (o espiral descendente) con una barrena.

En una barrena, el planeador está en pérdida asimétrica, cae verticalmente guiñando y su velocidad aerodinámica es baja y constante. Por el contrario, en un picado en espiral #strong[el planeador está volando]\; ninguna de sus alas está en pérdida. El planeador describe una trayectoria curva descendente cada vez más pronunciada en la que tanto la velocidad como el #link(<glosario-factor-de-carga>)[factor de carga]#index("Factor de carga") (fuerzas G) aumentan de forma constante y rápida.

Aplicar la técnica de recuperación de la barrena (pisar el pedal contrario a fondo) en un picado en espiral es un error gravísimo que puede sobrecargar la cola y el timón a esas altas velocidades.

La herramienta de diagnóstico más rápida y fiable es el #strong[anemómetro] (#ref(<fig-05-cap07-espiral-vs-barrena>, supplement: [Figura])):

- #strong[Velocidad alta o creciendo] → espiral descendente. El planeador vuela y acelera.
- #strong[Velocidad baja y constante, en #link(<glosario-torno>)[torno]#index("Torno") a la de pérdida o incluso menos] → barrena. El ala está en pérdida y la velocidad no puede aumentar.

#figure([
#box(image("05-principios-vuelo/imagenes/05-cap07-espiral-vs-barrena.png"))
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
Nunca tires de la palanca de mando para intentar frenar un picado si las alas del planeador se encuentran inclinadas.

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
== La causa típica: pérdida de referencia visual
<la-causa-típica-pérdida-de-referencia-visual>
La situación clásica que desencadena una espiral descendente es la pérdida accidental de referencias visuales exteriores (#link(<glosario-vmc>)[VMC]#index("VMC")), como introducirse inadvertidamente en la #link(<glosario-base>)[base]#index("Tramo de base") de una nube mientras se vira en una #link(<glosario-termica>)[térmica]#index("Térmica") fuerte.

Al perder el horizonte visual, el oído interno se desorienta rápidamente. El planeador, que habitualmente no es estable en espiral (tiende a aumentar gradualmente su ángulo de alabeo si se dejan sueltos los mandos en un viraje), comenzará a inclinarse y a bajar el morro de forma progresiva. El piloto desorientado no lo percibe hasta que el fuerte ruido aerodinámico y el aumento de la velocidad en el anemómetro revelan que el planeador está cayendo aceleradamente.

== Procedimiento de salida (recuperación)
<procedimiento-de-salida-recuperación>
La salida de un picado en espiral debe ejecutarse de forma procedimental, luchando activamente contra el instinto de tirar de la palanca en un primer #link(<glosario-momento>)[momento]#index("Momento"):

+ #strong[Nivelar las alas:] es lo primero, porque el alabeo es lo que sostiene y aprieta la espiral. Aplica palanca lateral y pedal hacia el lado contrario del viraje, con decisión, hasta poner las alas completamente horizontales respecto a tu referencia o a los instrumentos.
+ #strong[Recuperar el picado:] solo cuando las alas estén a 0º de inclinación lateral, tira de la palanca con firmeza pero con suavidad para elevar el morro. Hazlo de forma progresiva, vigilando no superar factores de carga excesivos al salir de la trayectoria de picado.
+ #strong[Controlar la velocidad:] si la velocidad se aproxima a la V#sub[NE] (Velocidad Nunca Exceder), extiende los #link(<glosario-aerofrenos>)[aerofrenos]#index("Aerofrenos") para frenar la aceleración; pero hazlo con suavidad, porque a alta velocidad y con factor de carga elevado una extensión brusca añade carga a la estructura.

#postit[
#strong[Resumen del capítulo: picado en espiral]

- #strong[Diagnóstico rápido --- mira el anemómetro]: velocidad alta o creciendo = espiral (el planeador vuela y acelera). Velocidad baja y constante = barrena (el ala está en pérdida, no puede acelerar). No las confundas: la técnica es opuesta.
- #strong[El peligro del instinto]: si tiras de la palanca para subir el morro sin nivelar antes las alas, solo cierras más la espiral y aumentas las Gs hasta el fallo estructural.
- #strong[Cómo salir]: 1. nivela las alas (alerones y pie coordinados al lado contrario del viraje) ---es lo primero, el alabeo sostiene la espiral---; 2. recupera suave del picado; 3. si la velocidad se acerca a la #link(<glosario-vne>)[VNE]#index("VNE"), frena con aerofrenos (suavemente).
- #strong[Causa típica]: pérdida de referencia visual (nubes, noche) y distracción. El planeador tiene #link(<glosario-tendencia-espiral>)[tendencia espiral]#index("Tendencia espiral")\; si lo dejas solo con un pequeño alabeo, la espiral crece sola.

]
#part[Parte 06: Procedimientos Operativos]
= Requisitos generales
<requisitos-generales>
#quote(block: true)[
Antes de despegar, el piloto de planeador debe cumplir con un conjunto de requisitos legales y de seguridad que no son mera burocracia: son la primera línea de defensa frente al accidente. Conocer exactamente qué documentos deben ir a bordo, cuáles son las responsabilidades del #link(<glosario-pic>)[Piloto al Mando]#index("Piloto al mando") y cuándo tienes derecho a llevar pasajeros te protege a ti, a los demás y a tu licencia.

En este capítulo aprenderás:

- #strong[La documentación obligatoria]: qué debe ir en la cabina y qué puede quedarse en el aeródromo.
- #strong[Los documentos de la aeronave (#link(<glosario-sao>)[SAO]#index("SAO")​.GEN.155)]: qué debe estar en regla antes de cada vuelo.
- #strong[Las responsabilidades del PIC]: desde la inspección prevuelo hasta la decisión #link(<glosario-final>)[final]#index("Tramo final") de no volar.
- #strong[El chequeo #link(<glosario-imsafe>)[IMSAFE]#index("IMSAFE")]: la herramienta de autoevaluación que puede salvarte la vida.
- #strong[Los requisitos para llevar pasajeros]: experiencia, recencia y verificación.
]

== Documentación obligatoria
<documentación-obligatoria>
Para operar un planeador de forma legal y segura, es imprescindible que tanto la aeronave como el piloto estén en regla antes de salir a pista. Dos reglamentos se reparten la tarea: #strong[#link(<glosario-part-sfcl>)[Part-SFCL]#index("Part-SFCL")] (#link(<glosario-sfcl>)[SFCL]#index("SFCL")​.045) fija los documentos del piloto, y #strong[#link(<glosario-part-sao>)[Part-SAO]#index("Part-SAO")] (SAO.GEN.155) los de la aeronave. Ambos permiten dejar los documentos en el aeródromo cuando el vuelo se mantiene a la vista del campo o dentro de una zona determinada por la autoridad competente.

No confundas «que no pase nada» con «que esté bien». Volar sin la documentación correcta convierte cualquier incidente menor en un problema legal de primera magnitud.

=== Documentos que deben ir a bordo
<documentos-que-deben-ir-a-bordo>
Salvo que vueles a la vista del aeródromo o en una zona autorizada por la autoridad, los siguientes documentos deben acompañarte en la cabina:

- #strong[Licencia del piloto (#link(<glosario-spl>)[SPL]#index("SPL") (Sailplane Pilot Licence)):] original y en vigor. Una fotocopia no tiene validez legal.
- #strong[Certificado médico:] clase 1, 2 o #link(<glosario-lapl>)[LAPL]#index("LAPL") según corresponda, siempre en vigor.
- #strong[Documento de identificación:] DNI, pasaporte o documento oficial con fotografía.
- #strong[Manual de vuelo (#link(<glosario-afm>)[AFM]#index("AFM")):] el manual específico del modelo de planeador que operas.
- #strong[Cartas aeronáuticas:] actualizadas y adecuadas para la ruta prevista.
- #strong[Libro de vuelo (logbook):] datos suficientes ---o el propio libro--- para demostrar que cumples los requisitos de la normativa, la experiencia reciente incluida.
- #strong[Señales de #link(<glosario-interceptacion>)[interceptación]#index("Interceptación"):] una copia de los procedimientos y señales visuales internacionales de interceptación (#link(<glosario-sera>)[SERA]#index("SERA")​.11015; las señales y la respuesta correcta se estudian en el #strong[Libro 4 --- Comunicaciones], capítulo 8).

El resto de los papeles de la aeronave ---certificado de matrícula, certificado de aeronavegabilidad con sus anexos, #link(<glosario-arc>)[ARC]#index("ARC"), licencia de radio si lleva equipo, certificado del seguro y diario de a bordo--- no necesitan volar contigo: SAO.GEN.155 exige que estén disponibles en el aeródromo o lugar de operación.

#block[
#callout(
body: 
[
Antes de cada vuelo, verifica los cuatro pilares documentales de la aeronave según #strong[SAO.GEN.155]: #strong[aeronavegabilidad] (certificado de aeronavegabilidad + ARC en vigor), #strong[matrícula] (certificado de matrícula visible), #strong[manual de vuelo] (AFM a bordo) y #strong[pesada y centrado] (dentro de los límites del manual). Si alguno falla, el planeador no vuela.

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
== Responsabilidad del piloto al mando (PIC)
<responsabilidad-del-piloto-al-mando-pic>
El #strong[Piloto al Mando] (PIC) es la máxima autoridad a bordo y el responsable final de la seguridad de la operación, desde el #link(<glosario-momento>)[momento]#index("Momento") en que firma la autorización de vuelo hasta que el planeador queda correctamente asegurado en tierra. Esta responsabilidad no se comparte, no se delega y no tiene excepciones.

Eso significa que, aunque el mecánico del club haya revisado el planeador, aunque el instructor te haya autorizado el vuelo y aunque el pronóstico del tiempo sea favorable, #strong[la decisión final es siempre tuya]. Si algo no te cuadra, la única respuesta correcta es no volar.

Sus funciones principales incluyen:

+ #strong[Inspección prevuelo:] verificar que el planeador ha sido inspeccionado según el AFM y es apto para el vuelo. No firmes la inspección si no la has hecho tú mismo o si hay algo que no entiendes.
+ #strong[Carga y centrado:] asegurarse de que la masa total y la posición del centro de gravedad (#link(<glosario-cg>)[CG]#index("CG")) están dentro de los límites permitidos. Un CG fuera de rango puede hacer el planeador irrecuperable en pérdida.
+ #strong[Briefing de seguridad:] informar a los pasajeros sobre el uso de cinturones, paracaídas (si procede), salidas de emergencia y comportamiento en cabina.
+ #strong[Aptitud psicofísica:] no volar si se sospecha cualquier incapacidad física o mental, por mínima que sea.

=== El chequeo IMSAFE
<el-chequeo-imsafe>
Antes de subir al cockpit, realiza este auto-examen de honestidad. No es una formalidad: es la primera ---y más importante--- verificación del día.

- #strong[I] (#strong[Illness / Enfermedad]): ¿Sufro alguna enfermedad o síntoma, por leve que sea? Un resfriado puede impedir que se igualen las presiones en el oído medio al ascender.
- #strong[M] (#strong[Medication / Medicación]): ¿He tomado medicamentos que puedan afectar mis reflejos, la visión o el nivel de alerta?
- #strong[S] (#strong[Stress / Estrés]): ¿Estoy bajo una presión personal o profesional excesiva que ocupe parte de mi atención?
- #strong[A] (#strong[Alcohol]): ¿He consumido alcohol en las últimas 8-24 horas? Incluso una copa la noche anterior puede afectar al rendimiento cognitivo.
- #strong[F] (#strong[Fatigue / #link(<glosario-fatiga>)[Fatiga]#index("Fatiga")]): ¿He descansado lo suficiente? La fatiga es uno de los factores más frecuentes y más infravalorados en los accidentes.
- #strong[E] (#strong[Emotion / Eating]): ¿Estoy emocionalmente estable? ¿He comido y estoy correctamente hidratado?

Una sola respuesta negativa en cualquiera de estos puntos es razón suficiente para no volar ese día. No existen los vuelos «de desconexión» cuando el piloto no está al cien por cien.

#block[
#callout(
body: 
[
Haz el chequeo #strong[IMSAFE] en voz alta o por escrito antes de salir de casa. La dinámica del aeródromo ---el entusiasmo del grupo, el buen tiempo, la presión social--- puede llevar a minimizar síntomas que en casa te parecerían evidentes. Decidir en frío, antes de llegar al campo, es siempre más fácil que decir «no» delante de tus compañeros cuando el remolcador ya está preparado.

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
== Transporte de pasajeros
<transporte-de-pasajeros-1>
Llevar a una persona en tu planeador es una responsabilidad añadida de considerable peso. No es solo cuestión de técnica: es la seguridad de alguien que ha depositado su confianza en ti y que, probablemente, no sabría qué hacer si tú quedases incapacitado.

Para poder ejercer esta atribución, la normativa #strong[Part-SFCL] exige que el piloto cumpla con requisitos estrictos de experiencia reciente:

- #strong[Licencia:] debes ser titular de la SPL (Sailplane Pilot Licence) ---no alumno piloto en instrucción--- y con todos los privilegios en vigor.
- #strong[Experiencia:] haber realizado al menos #strong[10 horas de vuelo o 30 lanzamientos] como PIC después de la emisión de la licencia.
- #strong[Recencia:] haber realizado al menos #strong[3 lanzamientos como PIC en los últimos 90 días] para poder llevar pasajeros.
- #strong[Verificación:] haber realizado un vuelo de entrenamiento en el que demuestres a un instructor #link(<glosario-fi>)[FI]#index("FI")\(S) la competencia necesaria para el transporte de pasajeros (salvo que seas titular de un certificado FI(S)).

#block[
#callout(
body: 
[
Como PIC tienes el derecho y el deber de denegar el transporte a cualquier pasajero o equipaje que consideres que puede representar un peligro para la seguridad del vuelo. Esta decisión no admite presiones externas: si el peso del pasajero más el equipo supera los límites de la aeronave, o si el pasajero muestra un comportamiento que puede comprometer tu concentración, la respuesta es un «no» firme y sin negociación.

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
Según el Reglamento (UE) 2018/1976, el titular de una SPL (Sailplane Pilot Licence) solo transportará pasajeros si cumple dos condiciones: haber completado, tras la emisión de la licencia, al menos 10 horas de vuelo o 30 lanzamientos o despegues y aterrizajes como PIC en planeadores, además de un vuelo de entrenamiento demostrando la competencia a un FI(S) (SFCL.115(a)(2)); y haber realizado, en los 90 días anteriores, al menos 3 lanzamientos como PIC en planeador ---en #link(<glosario-tmg>)[TMG]#index("TMG"), 3 despegues y aterrizajes--- (SFCL.160(e)).

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
== Operaciones en tierra y preparación
<operaciones-en-tierra-y-preparación>
La seguridad y la preservación del material de vuelo comienzan mucho antes del despegue, con una meticulosa preparación y manipulación en tierra. Los planeadores, debido a sus grandes envergaduras, estructuras ligeras y superficies de control desmontables, son especialmente vulnerables al viento, las colisiones terrestres y los descuidos en el ensamblaje.

=== Montaje y almacenamiento (#emph[assembly] & #emph[storage])
<montaje-y-almacenamiento-assembly-storage>
El #link(<glosario-rigging>)[montaje]#index("Rigging") (#emph[rigging]) y desmontaje (#emph[de-rigging]) del planeador son operaciones habituales en el aeródromo que exigen método y concentración:

- #strong[Evita distracciones:] las interrupciones en el proceso de montaje son la causa número uno de pasadores no asegurados o mandos no conectados. Si te interrumpen, detente y vuelve a empezar la lista de comprobación de montaje desde el primer paso.
- #strong[Inventario de herramientas:] utiliza cunas o paneles específicos para colocar los pernos, pasadores y herramientas de montaje. Al terminar, realiza un inventario estricto: un destornillador o pasador olvidado dentro de la estructura de las alas o el fuselaje puede bloquear el movimiento de los mandos en vuelo.
- #strong[Cuidado al encintar uniones:] el uso de cinta adhesiva plástica para sellar las juntas de unión (como las raíces alares o el #emph[turtle deck]) reduce la resistencia y evita turbulencias. Asegúrate de que los extremos de la cinta queden bien pegados y no interfieran con el recorrido libre de alerones o #link(<glosario-aerofrenos>)[aerofrenos]#index("Aerofrenos").

=== Comprobación de mandos positiva (#strong[positive control check - PCC])
<comprobación-de-mandos-positiva-positive-control-check---pcc>
Tras cada montaje de la aeronave, es obligatorio y vital realizar una #strong[comprobación de mandos positiva] (#strong[positive control check]):

+ El piloto se sienta en cabina y sujeta firmemente los mandos de vuelo.
+ Un ayudante en tierra sujeta físicamente cada superficie de control (un alerón, el elevador, el timón de dirección y los aerofrenos) y aplica resistencia.
+ El piloto intenta mover la palanca y los pedales. Si el mando se mueve en cabina mientras la superficie exterior está bloqueada por el ayudante, significa que la conexión de las transmisiones no es firme y el planeador #strong[no es aeronavegable].

=== Remolque por carretera (#emph[trailering])
<remolque-por-carretera-trailering>
El transporte del planeador en su remolque exige que las piezas encajen de forma precisa y firme:

- #strong[Evita rozaduras (chafing):] los planos y el fuselaje deben apoyarse en cunas acolchadas y específicas para el modelo, bloqueados firmemente para que las vibraciones en carretera no desgasten la fibra ni las superficies de control.
- #strong[Cierre del carro:] asegura los cierres del carro y comprueba que las luces de señalización y los frenos del remolque funcionan correctamente antes de salir a la carretera.

=== Anclaje y aseguramiento (#emph[tiedown & securing])
<anclaje-y-aseguramiento-tiedown-securing>
Cuando el planeador se deja estacionado y desatendido en el aeródromo, debe protegerse contra ráfagas de viento y el rebufo de aviones motorizados (#strong[propeller blast]):

- #strong[#link(<glosario-cupula>)[Cúpula]#index("Cúpula") cerrada:] mantén siempre la cúpula cerrada y bloqueada. Un golpe de viento o la turbulencia de otra aeronave puede arrancarla de cuajo.
- #strong[Posición de cara al viento:] estaciona el planeador con el morro apuntando directamente al viento dominante siempre que sea posible.
- #strong[Puntos de amarre:] utiliza cuerdas, cadenas o cinchas tensadas desde los extremos alares y el fuselaje hasta anclajes de tierra estables. Si se prevén vientos fuertes, coloca un soporte acolchado bajo la cola para reducir el ángulo de ataque de las alas y evitar que estas generen sustentación.
- #strong[Bloqueadores y fundas:] instala bloqueadores de mandos (#strong[gust locks]) externos para evitar que el viento golpee las superficies de control contra sus topes. Coloca fundas protectoras en la cúpula contra los rayos UV y en los puertos de pitot y #link(<glosario-energia-total>)[energía total]#index("Energía total") para evitar la entrada de insectos y suciedad.

=== Traslado en tierra (#emph[ground handling])
<traslado-en-tierra-ground-handling>
El movimiento del planeador sobre el terreno requiere de un protocolo de equipo claro:

- #strong[Briefing y señales:] todo el personal que ayude a mover la aeronave debe conocer las órdenes y señales.
- #strong[Remolque con vehículo:] al remolcar el planeador con un coche en el aeródromo, #strong[la #link(<glosario-longitud>)[longitud]#index("Longitud") de la cuerda de remolque debe superar la mitad de la envergadura del velero]. Si una punta de ala se detiene por un obstáculo o si el #strong[wing walker] suelta el ala, esta longitud evita que el planeador pivote bruscamente y golpee el vehículo tractor con el ala opuesta.
- #strong[Velocidad de traslado:] nunca superes la velocidad de una caminata rápida. Utiliza siempre al menos un #strong[wing walker] para guiar el ala y vigilar los obstáculos.

=== Inspección prevuelo detallada (#strong[preflight walk-around check])
<inspección-prevuelo-detallada-preflight-walk-around-check>
Antes del primer despegue del día, el piloto al mando debe realizar una inspección de 360 grados alrededor de la aeronave siguiendo un orden lógico y utilizando la lista de comprobación oficial de su AFM (#ref(<fig-06-cap01-inspeccion-prevuelo>, supplement: [Figura])):

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap01-prevuelo.jpg"))
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
+ #strong[Ala izquierda:] borde de ataque limpio. Holguras y conexiones de los alerones y #link(<glosario-flaps>)[flaps]#index("Flaps"). Estado y blocaje de los aerofrenos. Patín o rueda de punta de ala.
+ #strong[Fuselaje izquierdo:] ausencia de grietas en la estructura de fibra. Estado de las antenas.
+ #strong[Cola (empennage):] fijación del estabilizador horizontal y vertical. Libre movimiento y holguras del timón de dirección y profundidad. Estado de las tomas de estática de cola y la sonda de energía total (TE).
+ #strong[Fuselaje derecho:] inspección simétrica al lado izquierdo.
+ #strong[Ala derecha:] inspección simétrica al ala izquierda.
+ #strong[Tren de aterrizaje y ganchos:] presión y estado del neumático principal y de cola. Funcionamiento del freno de rueda. Comprobación de que el gancho de morro y el gancho de CG están limpios y operan libremente.

=== Lista de comprobación antes del despegue (CB-SIFT-CBE)
<lista-de-comprobación-antes-del-despegue-cb-sift-cbe>
Inmediatamente antes del enganche del cable y del despegue, el piloto debe realizar y verbalizar la lista de comprobación de cabina según su AFM, adaptada al español #strong[#link(<glosario-cumulonimbus>)[CB]#index("Cumulonimbus")-SIFT-CBE]:

- #strong[C] (#strong[Controls]): mandos libres y con movimientos correctos (recorrido completo confirmado visualmente).
- #strong[B] (#strong[Ballast]): masa total y posición del centro de gravedad dentro de límites.
- #strong[S] (#strong[Straps]): cinturones y arneses de hombros ajustados y trabados.
- #strong[I] (#strong[Instruments]): altímetro calado en #link(<glosario-qfe>)[QFE]#index("QFE") o #link(<glosario-qnh>)[QNH]#index("QNH"), #link(<glosario-variometro>)[variómetro]#index("Variómetro") ajustado, radio en frecuencia activa, #link(<glosario-flarm>)[FLARM]#index("FLARM") encendido y sin alarmas de fallo.
- #strong[F] (#strong[Flaps]): posición de flaps ajustada para despegue si corresponde.
- #strong[T] (#strong[#link(<glosario-compensador>)[Trim]#index("Compensador")]): compensador de cabeceo ajustado en la posición de despegue.
- #strong[C] (#strong[Canopy]): cúpula cerrada y con cerrojos blocados (comprobación visual y física empujándola ligeramente).
- #strong[B] (#strong[Brakes]): aerofrenos cerrados y firmemente blocados.
- #strong[E] (#strong[Eventualities / Eventualidades]): repaso del viento actual y del briefing de emergencias en el despegue (acciones ante #link(<glosario-fallo-de-lanzamiento>)[fallo de lanzamiento]#index("Fallo de lanzamiento")).

#block[
#callout(
body: 
[
En la mayoría de los aeroclubs de habla hispana, especialmente en centros históricos como Ocaña o Fuentemilanos, los instructores han utilizado tradicionalmente la regla mnemotécnica #strong[CRISE] (o #strong[CRIS]):

- #strong[C] (#strong[Mandos / Controles]): palanca libre, pedales ajustados y aerofrenos cerrados y asegurados.
- #strong[#link(<glosario-zonas-p>)[R]#index("Zonas P")] (#strong[Reglajes / Arneses]): cinturones ajustados, paracaídas colocado y comodidad del piloto en cabina.
- #strong[I] (#strong[Instrumentos]): altímetro a cero (QFE) o calado en QNH, variómetro y vario eléctrico encendidos, y FLARM configurado.
- #strong[S] (#strong[Seguridad exterior]): cúpula cerrada y pestillada, ventanilla cerrada, pista despejada y viento evaluado.
- #strong[E] (#strong[Emergencias]): briefing mental de rotura de cable y planificación inmediata ante un fallo en el despegue.

Ambas mnemotécnicas (la europea CB-SIFT-CBE y la tradicional CRISE) persiguen el mismo fin de seguridad: no conectar el cable del planeador a pista hasta que no se haya realizado una verificación física e instrumental completa en cabina.

]
, 
title: 
[
Airmanship: LA REGLA TRADICIONAL CRISE
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
#strong[Resumen del capítulo: requisitos generales]

- #strong[Los papeles del planeador (SAO.GEN.155)]: antes de cada vuelo verifica los cuatro pilares documentales de la aeronave: aeronavegabilidad (certificado + ARC), matrícula, manual de vuelo (AFM) y pesada y centrado. Si falta alguno, el planeador no vuela.
- #strong[Tus papeles]: licencia (SPL (Sailplane Pilot Licence)) en vigor, certificado médico vigente, DNI y datos del libro de vuelo (SFCL.045). Si eres alumno, en las travesías en solitario lleva el médico, el DNI y la prueba de la autorización de tu instructor (SFCL.125).
- #strong[Responsabilidad del PIC]: tú eres la última autoridad. Si el velero no está en condiciones, la meteo es marginal o tú no estás al 100 % (IMSAFE), la decisión de no volar es tuya.
- #strong[IMSAFE]: #strong[Illness, Medication, Stress, Alcohol, Fatigue, Emotion/Eating]. Un solo «sí» es suficiente para quedarte en tierra.
- #strong[Pasajeros]: licencia SPL (Sailplane Pilot Licence) (no alumno), 3 lanzamientos en los últimos 90 días, 10 horas o 30 lanzamientos tras la licencia, y un vuelo de verificación con instructor.
- #strong[Operaciones en tierra]: comprobación de mandos positiva (#link(<glosario-pcc>)[PCC]#index("PCC")) tras cada montaje. Anclaje de cara al viento con cúpulas cerradas. Regla de la cuerda larga (más de media envergadura) para remolcar con coche.
- #strong[Prevuelo y CB-SIFT-CBE]: inspección prevuelo sistemática de 360 grados. Checklist de cabina estricto CB-SIFT-CBE antes de conectar el cable de lanzamiento.

]
= Métodos de lanzamiento
<métodos-de-lanzamiento>
#quote(block: true)[
El lanzamiento es la fase de mayor energía del vuelo de planeador y, junto con el aterrizaje, la de mayor riesgo estadístico. En cuestión de segundos, el piloto pasa de estar parado en tierra a volar a velocidades considerables, dependiendo de un cable o de un avión remolcador. No hay margen para la improvisación: los procedimientos son exactos, la comunicación es precisa y las reacciones de emergencia deben ser instintivas.

En este capítulo aprenderás:

- #strong[El lanzamiento por #link(<glosario-torno>)[torno]#index("Torno")]: dinámica, fraseología y procedimiento de emergencia ante rotura de cable.
- #strong[El remolque por avión (#link(<glosario-aerotow>)[aerotow]#index("Aerotow"))]: posiciones en remolque, señales visuales y cómo actuar si no puedes soltar.
- #strong[Las reglas generales de seguridad]: ganchos, velocidades y comprobaciones previas al enganche.
]

== El lanzamiento por torno (#emph[winch])
<el-lanzamiento-por-torno-winch>
El #strong[lanzamiento por torno] es el método más rápido y económico para poner un planeador en el aire. Un motor potente situado en el extremo opuesto de la pista enrolla un cable a gran velocidad, arrastrando al planeador desde el reposo hasta velocidades de despegue en apenas tres o cuatro segundos. La sensación es la de una catapulta: la aceleración es tan brusca que los pilotos noveles suelen sorprenderse ante su intensidad.

Durante el ascenso, el ángulo de cabeceo aumenta rápidamente hasta superar los 40-45°. Esta actitud, que en cualquier otra situación sería alarmante, es completamente normal en el torno: el cable tirando desde adelante y abajo impone esa geometría. El planeador sube a razón de 10-15 metros por segundo y alcanza entre 300 y 500 metros en menos de un minuto (#ref(<fig-06-cap02-torno-fases>, supplement: [Figura])). Durante la trepada, la tracción del cable carga el ala y eleva su velocidad de pérdida, así que se vuela más deprisa que en vuelo libre: como referencia, entre 1,3 y 1,6 veces la velocidad mínima de vuelo recto, sin superar nunca la velocidad máxima de torno que fija el #link(<glosario-afm>)[AFM]#index("AFM").

=== Procedimiento y fraseología
<procedimiento-y-fraseología>
La comunicación entre el piloto y el operador del torno (tornero) es vital. Una orden malentendida puede resultar en una tracción inesperada. La secuencia estándar es:

+ #strong[«Listo para tensar el cable»]: el piloto indica que está preparado. El tornero comienza a recoger cable lentamente, sin tensión brusca.
+ #strong[«Cable en tensión»]: el piloto confirma que el cable está tirando de forma suave y uniforme.
+ #strong[«Remolque, remolque, remolque»]: el piloto autoriza la máxima potencia. El planeador acelera rápidamente: controla el alabeo con los alerones y mantén el eje con los pedales.
+ #strong[«Velero libre»]: tras la suelta del cable ---al #link(<glosario-final>)[final]#index("Tramo final") de la trepada, típicamente a 300-400 metros, o de inmediato ante cualquier duda---, el piloto confirma que el cable se ha desenganchado y que vuela libre.

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap02-torno-fases.jpg"))
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
La rotura de cable durante el ascenso es una de las emergencias más exigentes del vuelo de planeador. La reacción debe ser #strong[instintiva e inmediata, sin dudar]. En el #link(<glosario-momento>)[momento]#index("Momento") en que la tensión desaparece, el morro del planeador tiende a subir peligrosamente ---el efecto del cable queda anulado de golpe--- y la velocidad cae con rapidez. Si no se actúa en los dos primeros segundos, la pérdida aerodinámica (#strong[stall]) a baja altura puede ser fatal.

#block[
#callout(
body: 
[
Si el cable se rompe durante el ascenso, la prioridad #strong[absoluta e inmediata] es #strong[bajar el morro] a actitud de planeo para recuperar velocidad y evitar la pérdida. Solo una vez que la velocidad es segura, activa la suelta de emergencia del cable remanente y decide: aterrizar recto en la pista restante (baja altura), realizar un giro de 180° (altura media) o completar un circuito abreviado (altura suficiente). #strong[En lanzamiento por torno, nunca intentes retornar a pista si estás por debajo de 150 metros]: es la maniobra más letal del vuelo sin motor.

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
== Remolque por avión (#emph[aerotow])
<remolque-por-avión-aerotow>
En el #strong[remolque por avión], una aeronave motorizada tira del planeador mediante un cable de entre 30 y 60 metros. Este método ofrece una ventaja decisiva sobre el torno: permite elegir con precisión la altura de suelta y el lugar #link(<glosario-norte-verdadero>)[geográfico]#index("Norte verdadero") exacto ---sobre la ladera idónea, la primera #link(<glosario-termica>)[térmica]#index("Térmica") del día o el punto de inicio de la tarea prevista---. La penalización es el coste y el consumo de tiempo.

La posición correcta de remolque es fundamental tanto para la seguridad como para la comodidad del piloto del remolcador (#ref(<fig-06-cap02-aerotow-posicion>, supplement: [Figura])):

- #strong[Posición alta]: el planeador vuela justo por encima de la estela del remolcador, usando como referencia visual las ruedas del remolcador apoyadas en el horizonte. Desde esta posición, el planeador queda fuera del rebufo de la hélice y no ejerce fuerza de cabeceo sobre la cola del remolcador.
- #strong[Zona a evitar]: la zona inmediatamente detrás del remolcador y debajo de su estabilizador es extremadamente turbulenta por la estela de hélice. Atravesarla durante un vuelo normal es incómodo; durante una emergencia del remolcador, puede ser peligroso.

=== Señales visuales en vuelo
<señales-visuales-en-vuelo>
Aunque se use la radio, las señales visuales son el estándar internacional de seguridad aeronáutica ante el fallo de las comunicaciones:

- #strong[Balanceo de alas del remolcador:] ¡Suelta el cable inmediatamente! Es una orden de seguridad de obligado cumplimiento: el remolcador tiene una emergencia.
- #strong[Movimiento de timón del remolcador («fishtail»):] algo va mal en tu planeador --- revísalo. Lo más habitual: los #link(<glosario-aerofrenos>)[aerofrenos]#index("Aerofrenos") se han desplegado sin que te des cuenta.
- #strong[El planeador se sitúa bajo y al lado izquierdo del remolcador y alabea:] el piloto del planeador no puede soltar el cable y solicita que el remolcador le lleve de vuelta al aeródromo.

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap02-aerotow-posicion.jpg"))
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
Durante el remolque, mantén siempre el avión remolcador #strong[en tu campo de visión], preferiblemente en «posición alta» (las ruedas del remolcador apoyadas en el horizonte). Si el remolcador desaparece de tu campo de visión, has entrado en posición demasiado alta: el planeador estará levantando la cola del remolcador y puedes empujar su morro hacia el suelo. Ante cualquier duda, suelta el cable: siempre es la decisión más segura.

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
=== La maniobra «Boxing the Wake» (hacer la caja a la estela)
<la-maniobra-boxing-the-wake-hacer-la-caja-a-la-estela>
«Boxing the wake» (rodear la estela) es un ejercicio de entrenamiento avanzado de remolque que demuestra la coordinación y la capacidad del piloto para maniobrar de forma controlada alrededor de la turbulencia del remolcador (#strong[#link(<glosario-estela-turbulenta>)[wake turbulence]#index("Estela turbulenta")]).

La estela del remolcador consta de dos componentes: el rebufo de la hélice (#strong[propwash]), que genera una turbulencia ligera en el centro, y los vórtices de punta de ala (#strong[wingtip vortices]), que inducen fuertes momentos de alabeo en los bordes.

La maniobra consiste en volar un patrón rectangular ---un cuadro--- alrededor de la estela del remolcador: partiendo de la posición alta estándar, se cruza la estela hacia la posición baja y desde ahí se recorren las cuatro esquinas del rectángulo (baja izquierda, alta izquierda, alta derecha, baja derecha) con mandos coordinados, manteniendo constante la distancia a la estela, para cerrar cruzando de nuevo hacia la posición alta (#ref(<fig-06-cap02-boxing-wake>, supplement: [Figura])). Cada tramo es un ejercicio de control fino: desplazamientos limpios sin recortar las esquinas ni penetrar en los vórtices de punta de ala.

No es materia de examen ni algo que se aprenda de un libro: es un ejercicio de vuelo que se practica #strong[con instructor], que te enseñará el ritmo y los límites en tu tipo de planeador. Empieza siempre fuera del circuito y por encima de una altura de seguridad de referencia de #strong[300 m #link(<glosario-agl>)[AGL]#index("AGL")].

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap02-boxing-wake.jpg"))
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
Evita realizar un cuadro demasiado estrecho o recortar las esquinas, ya que el planeador penetrará en los vórtices de punta de ala de forma descontrolada. Esto puede provocar un alabeo violento e imprevisto. Si pierdes el control o el remolcador desaparece de tu vista, suelta el cable inmediatamente.

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
=== Corrección de cable flojo (#strong[slack line])
<corrección-de-cable-flojo-slack-line>
El aflojamiento del cable de remolque (#strong[#link(<glosario-cable-flojo>)[cable flojo]#index("Cable flojo")] o #strong[slack line] o seno en el cable) es un fenómeno común durante el remolque por avión, provocado por ráfagas de viento, térmicas, virajes cerrados por el interior del radio del remolcador o reducciones bruscas de potencia del avión tractor.

El peligro reside en que, cuando el planeador desacelera y el cable se afloja, la cuerda puede enredarse en las alas o en el tren del planeador. Además, al acelerar de nuevo, el cable se tensará de golpe, provocando un tirón violento (#strong[snap]) que puede romper el #link(<glosario-fusible-de-seguridad>)[fusible de seguridad]#index("Fusible de seguridad") o causar daños estructurales en el planeador o en el remolcador.

Para corregir un cable flojo, aplica la siguiente técnica según su severidad:

- #strong[Seno leve:] si la comba en el cable es pequeña, mantén una trayectoria de vuelo estabilizada directamente detrás del remolcador. El propio planeo del velero reabsorberá el exceso de velocidad de forma natural y suave.
- #strong[Seno moderado:] si el cable está visiblemente combado, #strong[realiza un #link(<glosario-resbale-lateral>)[resbale lateral]#index("Resbale lateral") (sideslip) suave] apuntando el morro ligeramente hacia afuera de la trayectoria para aumentar la resistencia aerodinámica, o bien #strong[abre los aerofrenos de forma muy gradual e intermitente]. Esto ralentizará el planeador y estirará el cable con suavidad.
- #strong[Seno crítico:] si el cable forma un bucle grande y pierdes de vista el cable o el avión remolcador, #strong[suelta el cable de inmediato]. Es muy peligroso esperar a que se tense de golpe a gran velocidad.

== El autolanzamiento (#emph[self-launch])
<el-autolanzamiento-self-launch>
El #strong[#link(<glosario-self-launch>)[autolanzamiento]#index("Autolanzamiento")] es el método empleado por los planeadores motorizados (#strong[motorgliders]) o planeadores autónomos equipados con motores retráctiles o hélices frontales plegables. Este método proporciona al piloto una independencia absoluta, permitiéndole despegar y ascender sin necesidad de torno ni de avión remolcador.

Sin embargo, la operación con motor introduce una serie de riesgos específicos que deben gestionarse con rigor:

- #strong[La tendencia al encabritado (pitch-up tendency):] en la mayoría de los planeadores con motor retráctil, el motor se despliega en un mástil vertical sobre el fuselaje. La fuerza de tracción actúa muy por encima del eje longitudinal de la aeronave: al aplicar potencia genera un potente par de picado, y al reducirla o cortarla en el aire, un encabritado brusco. El piloto debe contrarrestar esta tendencia de forma activa y decidida con el timón de profundidad.
- #strong[Resistencia aerodinámica del motor:] si el motor falla en vuelo o se apaga y queda desplegado sin retraerse, la polar de planeo se degrada de forma drástica (la tasa de descenso puede llegar a duplicarse). Volar con el motor fuera equivale a volar con los aerofrenos parcialmente abiertos.
- #strong[El dilema del arranque a baja altura:] la causa principal de accidentes en planeadores motorizados es el intento del piloto de arrancar el motor en vuelo cuando se encuentra a muy baja altura para evitar un aterrizaje fuera de campo. Si el motor no arranca (debido al enfriamiento por viento, fallos eléctricos o falta de combustible), el piloto se queda sin motor y sin la altitud necesaria para planificar un aterrizaje fuera de campo seguro.

#block[
#callout(
body: 
[
Establece siempre una altura mínima de seguridad para el arranque del motor en vuelo (típicamente #strong[300 metros AGL]). Si desciendes por debajo de esa altura y el motor no arranca al primer intento, desiste inmediatamente, olvídate del motor y concéntrate exclusivamente en realizar un aterrizaje fuera de campo controlado. Muchos accidentes graves ocurren por intentar solucionar fallos del motor a escasos metros del suelo.

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
=== Métodos de lanzamiento secundarios
<métodos-de-lanzamiento-secundarios>
Además del torno, el remolque por avión y el autolanzamiento, existen otros dos métodos contemplados en el syllabus, de uso poco común en la actualidad pero con gran relevancia en la historia del vuelo sin motor o en ubicaciones de montaña específicas:

- #strong[Remolque por vehículo (car launch):] similar al torno, pero en lugar de un motor fijo enrollando un cable, es un coche o camión el que corre por una pista larga tirando del cable enganchado al planeador. Requiere una coordinación precisa de velocidad entre el conductor del vehículo y el planeador, y pistas extremadamente largas (más de 1.500 metros).
- #strong[Lanzamiento por goma (bungee launch):] es el método fundacional del vuelo sin motor. Se utiliza en laderas empinadas y con vientos fuertes de cara. El planeador se sujeta por la cola, mientras un equipo de personas estira una goma elástica gruesa unida al gancho de morro del planeador. Cuando la goma está tensa, se libera el planeador y este sale catapultado directamente hacia la ascendencia dinámica de la ladera.

== Reglas generales de seguridad
<reglas-generales-de-seguridad>
Independientemente del método de lanzamiento, existen reglas de seguridad comunes que deben verificarse antes de cada vuelo:

+ #strong[Ganchos de remolque adecuados:] si el planeador dispone de gancho de morro (para aerotow) y gancho de centro de gravedad (para torno), asegúrate de usar el correcto para cada método. Usar el gancho equivocado puede generar geometrías de tracción peligrosas o impedir la suelta.
+ #strong[Velocidades de remolque (V#sub[T]):] nunca excedas la velocidad máxima de remolque especificada en el AFM. Un remolque demasiado rápido genera oscilaciones que pueden superar los límites estructurales del planeador. Uno demasiado lento pone al remolcador al borde de la pérdida.
+ #strong[Comprobaciones previas al enganche:] antes de enganchar el cable, verifica:

- Aerofrenos cerrados y blocados.
- #link(<glosario-compensador>)[Compensador]#index("Compensador") en posición de despegue.
- Cabina libre de objetos sueltos y bien cerrada.
- Mandos libres y correctamente conectados (movimiento cruzado confirmado).
- Cinturones ajustados y trabados.

#block[
#callout(
body: 
[
Realiza siempre una comprobación de mandos cruzada (#strong[cross-check]) con otro piloto o el jefe de fila antes del lanzamiento. Un mando de alerones o timón no conectado correctamente puede ser imposible de detectar durante la inspección individual. Esta sencilla verificación elimina una de las causas más frecuentes de accidentes en el despegue.

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
=== Inspección del equipo de lanzamiento
<inspección-del-equipo-de-lanzamiento>
Antes de cada jornada de vuelo y en cada inspección prevuelo individual, el piloto y el personal de pista deben verificar el estado de los equipos de remolque y torno:

- #strong[Ganchos de remolque:] comprueba visualmente que las mandíbulas del gancho de morro (para remolque por avión) y de #link(<glosario-cg>)[CG]#index("CG") (para torno) estén limpias de tierra, óxido o grasa vieja. Acciona la anilla de suelta desde la cabina y verifica que el gancho se abre de forma instantánea y completa, y que el muelle lo retorna a su posición cerrada.
- #strong[Anillas de remolque:] inspecciona las anillas metálicas en los extremos del cable. En Europa, el sistema estándar es el #strong[doble anillo Tost]. Comprueba que las anillas no presenten grietas, abolladuras, soldaduras desgastadas o deformaciones elípticas.
- #strong[Cables y cuerdas de remolque:] revisa la cuerda de nailon o el cable de acero en toda su #link(<glosario-longitud>)[longitud]#index("Longitud"). Debe estar libre de nudos. #strong[Un solo #link(<glosario-nudo>)[nudo]#index("Nudo") en la cuerda de remolque reduce su resistencia estructural hasta en un 50 %] y crea un punto de alta fricción propenso a la rotura. Comprueba que no haya filamentos deshilachados y que la cuerda no presente decoloración por exposición prolongada a la radiación UV.

#block[
#callout(
body: 
[
El sistema de doble anilla Tost es el único homologado para ganchos Tost. El uso accidental de una anilla simple de tipo americano (Schweizer) en un gancho Tost grasping-style puede provocar que el gancho no se libere al accionar el tirador en vuelo, resultando en un arrastre incontrolable. Verifica siempre la compatibilidad del cable antes de enganchar.

]
, 
title: 
[
Seguridad: INCOMPATIBILIDAD DE ANILLAS
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

La obligación operativa del piloto es montar #strong[exactamente el fusible de seguridad especificado en el AFM] de su planeador: ni más resistente, ni más débil. Como referencia de diseño, la norma de certificación #strong[#link(<glosario-easa>)[EASA]#index("EASA") #link(<glosario-cs>)[CS]#index("CS") 22.581(b)] asume que la resistencia nominal última del cable o fusible no es inferior a 1,3 veces el peso máximo del planeador ni a 500 daN, valores con los que se dimensiona estructuralmente el #link(<glosario-gancho-de-remolque>)[gancho de remolque]#index("Gancho de remolque").

En los clubes europeos se utiliza el sistema estandarizado de la firma Tost. Es fundamental entender que #strong[la selección del fusible correcto depende obligatoriamente tanto del peso del planeador como del método de lanzamiento]:

- #strong[En remolque por avión (aerotow):] las aceleraciones son progresivas y las tensiones del cable son de menor magnitud. Para proteger el gancho de morro de sobretensiones peligrosas para la estabilidad, se emplean fusibles de menor resistencia:
- #strong[Verde (300 daN):] para monoplazas estándar y ligeros.
- #strong[Blanco (500 daN):] para biplazas de instrucción y veleros pesados.
- #strong[En lanzamiento por torno (winch):] la aceleración es muy brusca y las tensiones del cable durante el ascenso empinado son muy elevadas debido a la geometría del tiro. Se requieren fusibles de mayor resistencia para evitar roturas prematuras en plena trepada:
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
Nunca instales un fusible de seguridad de resistencia superior a la especificada en el AFM de tu planeador, ni realices puenteos en el cable utilizando mosquetones o grilletes sin fusible. En caso de una sobretensión brusca (como una ráfaga o un tirón por cable flojo), la rotura de las alas o del morro del planeador ocurrirá antes de que el cable se rompa. Asimismo, utilizar un fusible excesivamente resistente en remolque por avión puede causar daños graves en el gancho de morro y en la estructura del fuselaje antes de romperse.

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
=== El briefing de emergencia en el despegue (#emph[takeoff emergency briefing])
<el-briefing-de-emergencia-en-el-despegue-takeoff-emergency-briefing>
La preparación mental es el factor de seguridad más eficaz contra las emergencias en el despegue. La metodología internacional exige que, inmediatamente antes de cada despegue (justo antes de enganchar el cable o de solicitar tensión), el #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando") realice ---y verbalice en voz alta si vuela en biplaza--- el #strong[briefing de emergencia en el despegue] (#strong[takeoff emergency briefing]).

Este briefing estructura la toma de decisiones inmediata en caso de una rotura de cable o fallo de motor según tres franjas de altura preestablecidas:

+ #strong[Velocidades de seguridad:] confirmar la velocidad mínima a mantener ante cualquier fallo: la velocidad de aproximación segura que indica el AFM de tu planeador.
+ #strong[Fallo a baja altura:] definir la altura límite por debajo de la cual el aterrizaje se realizará recto y sin virar, identificando zonas libres de obstáculos fuera de la pista si es necesario.
+ #strong[Fallo a altura crítica y retorno:] definir la altura mínima para intentar un viraje de retorno seguro ---como referencia, 150 metros AGL en lanzamiento por torno y 70 metros AGL en remolque por avión (ver )--- y decidir previamente hacia qué lado se virará, considerando la dirección y fuerza del viento actual para contrarrestar la #link(<glosario-deriva>)[deriva]#index("Deriva").

#block[
#callout(
body: 
[
No comiences la carrera de despegue sin haber verbalizado o repasado mentalmente tu #strong[emergency briefing]. En caso de rotura de cable a baja altura, no hay tiempo para pensar qué hacer; la acción correcta (bajar el morro, estabilizar la velocidad y la trayectoria) debe estar precargada en la mente y ejecutarse como una respuesta refleja.

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
#strong[Resumen del capítulo: métodos de lanzamiento]

- #strong[Torno (winch)]: aceleración brutal de 0 a 100 en 3 segundos. Si se rompe el cable, lo primero es #strong[bajar el morro] para recuperar velocidad. Solo entonces suelta el cable remanente y decide si aterrizar recto, hacer 180° o un circuito corto, según la altura disponible.
- #strong[Remolque (aerotow)]: mantén la «posición alta» (rueda del remolcador en el horizonte). Si el remolcador alabea sus alas, es una orden de suelta inmediata: tiene una emergencia. Si no puedes soltar, vuela a un lado y alabea. Si se forma un #strong[cable flojo (slack line)], corrígelo con un resbale suave o con aerofrenos graduales. Entrena la maniobra #strong[«Boxing the Wake»] a partir de 300 m AGL.
- #strong[Autolanzamiento (self-launch)]: ofrece total independencia. Cuidado con el par de cabeceo del motor sobre mástil: aplicar potencia pica el morro y reducirla o cortarla lo #strong[encabrita]. Respeta la altura de seguridad de 300 m para arrancar el motor en vuelo; por debajo, concéntrate en el aterrizaje fuera de campo.
- #strong[Emergency briefing]: briefing mental y verbalizado antes de cada despegue. Define velocidades de seguridad y acciones precisas ante fallos a baja, media y alta altura según el viento.
- #strong[Comprobaciones previas]: ganchos correctos, velocidades respetadas, mandos libres y comprobación cruzada. Realiza la inspección de cuerdas (sin nudos), anillas dobles Tost compatibles y fusibles de seguridad (#strong[weak links]) de resistencia por código de colores (ej. azul = 600 daN para monoplazas en torno).

]
= Técnicas de planeo
<técnicas-de-planeo>
#quote(block: true)[
El vuelo de planeador es, en esencia, una conversación permanente con la atmósfera. El piloto que aprende a escuchar el aire ---las variaciones del #link(<glosario-variometro>)[variómetro]#index("Variómetro"), el comportamiento del planeador en distintas masas de aire, los indicios sutiles que anuncian una térmica--- desarrolla una capacidad que trasciende la técnica y se convierte en instinto. Esta sección recorre las tres grandes familias de sustentación dinámica: #link(<glosario-termica>)[térmica]#index("Térmica"), ladera y onda, junto con la gestión del #link(<glosario-lastre-de-agua>)[lastre de agua]#index("Lastre de agua") para condiciones específicas.

En este capítulo aprenderás:

- #strong[Centrado de térmicas]: cómo detectar el núcleo y cómo desplazar el viraje hacia él.
- #strong[El anillo MacCready]: qué es y cómo te dice exactamente a qué velocidad volar entre térmicas.
- #strong[#link(<glosario-vuelo-de-ladera>)[Vuelo de ladera]#index("Vuelo de ladera") (#link(<glosario-dorsal>)[ridge]#index("Dorsal") soaring)]: técnica, reglas de tráfico y márgenes de seguridad.
- #strong[#link(<glosario-vuelo-de-onda>)[Vuelo de onda]#index("Vuelo de onda") (#link(<glosario-onda-de-montana>)[wave soaring]#index("Onda de montaña"))]: identificación, condiciones ideales y riesgos del #link(<glosario-rotor>)[rotor]#index("Rotor").
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
#box(image("06-procedimientos-operativos/imagenes/06-cap03-centrado-termica.jpg"))
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
Si al atravesar una térmica un ala sube, el núcleo está de ese lado: #strong[vira hacia el ala que sube]. Una vez establecido el giro, no inviertas nunca el sentido: ajusta. Cierra el viraje cuando el vario sube, ábrelo cuando baja. Con el tiempo, este ajuste se vuelve automático y no necesitas calcularlo conscientemente.

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
=== La velocidad entre térmicas: el anillo MacCready
<la-velocidad-entre-térmicas-el-anillo-maccready>
El anillo MacCready es el selector de velocidades óptimas entre térmicas. Responde a la pregunta: «¿A qué velocidad debo volar para llegar lo más lejos posible antes de la próxima térmica?»

La lógica es la siguiente: si esperas encontrar térmicas de 2 m/s en el tramo siguiente, no tiene sentido volar a la velocidad de planeo óptimo (V#sub[G] (Velocidad de Planeo Óptimo)). Es más eficiente aumentar la velocidad ---sacrificando algo de planeo--- para llegar antes al núcleo de la próxima térmica. El anillo traduce esa lógica en una instrucción directa de velocidad.

- #strong[Ajusta el anillo] al valor de ascenso que esperas en la próxima térmica (p.~ej., 2 m/s).
- #strong[Vuela a la velocidad que marque el anillo] en el vario. En masas de aire descendente, volarás más rápido; en ascendente, más despacio.
- El resultado es el #strong[menor tiempo posible] para completar la travesía ---no el mayor planeo instantáneo.

=== El hilo de lana lateral como medidor del ángulo de ataque (técnica complementaria)
<el-hilo-de-lana-lateral-como-medidor-del-ángulo-de-ataque-técnica-complementaria>
El #strong[hilo de lana central] pegado en el centro de la #link(<glosario-cupula>)[cúpula]#index("Cúpula") es el instrumento rey y de obligada consulta para el control de la guiñada (vuelo coordinado). Sin embargo, en algunos entornos y escuelas se enseña de manera complementaria y no estándar el uso de un #strong[hilo de lana lateral] (#strong[side string]) como un indicador analógico e indirecto del ángulo de ataque (α, #strong[alfa]) de las alas.

A diferencia del anemómetro, cuya velocidad de pérdida indicada varía según el peso total de la aeronave (como por el uso de lastre de agua) o por la carga aerodinámica en viraje (#link(<glosario-factor-de-carga>)[factor de carga]#index("Factor de carga") G), #strong[el ala entra en pérdida siempre al mismo ángulo de ataque físico]. El hilo de lana lateral busca medir la dirección del flujo de aire local sobre el lateral de la cabina, el cual varía de forma proporcional a la actitud del perfil de la aeronave respecto al viento relativo.

Esta técnica tiene limitaciones operativas que conviene conocer:

- #strong[Errores por guiñada:] si el planeador no vuela en perfecta coordinación (bola y lanita central centradas), el flujo de aire lateral se deforma drásticamente y la lectura del hilo lateral queda inservible.
- #strong[Calibración específica:] requiere que un instructor o piloto experimentado marque de forma empírica en el cristal las marcas físicas del #strong[ángulo de planeo óptimo] (V#sub[G] (Velocidad de Planeo Óptimo)) y del #strong[ángulo de pérdida (stall)] para cada modelo concreto de cabina.

Su utilidad se restringe exclusivamente al vuelo térmico lento para ayudar al alumno a visualizar la cercanía del planeador al coeficiente de sustentación máximo y prevenir pérdidas secundarias en virajes cerrados.

#block[
#callout(
body: 
[
En el vuelo rápido (#strong[high-speed flight]), el hilo de lana lateral pierde toda precisión debido a que los ángulos de ataque son extremadamente pequeños. En este rango, el anemómetro y la observación del horizonte son los únicos métodos de referencia válidos para evitar exceder la V#sub[NE] (Velocidad Nunca Exceder). El hilo de lana lateral es una herramienta didáctica complementaria para el vuelo térmico lento, nunca un sustituto de los instrumentos primarios de vuelo ni del hilo de lana central de coordinación.

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
== Vuelo de ladera y de onda
<vuelo-de-ladera-y-de-onda>
=== Vuelo de ladera (#emph[ridge soaring])
<vuelo-de-ladera-ridge-soaring>
El #strong[vuelo de ladera] (#strong[ridge soaring]) aprovecha la deflexión ascendente que el viento genera al chocar contra una montaña o colina. Mientras el viento sopla de frente a la ladera con suficiente velocidad, el aire es forzado a ascender y genera una banda de ascenso que el planeador puede explotar de forma continua.

- #strong[Técnica:] vuela paralelo a la cresta, siempre por el lado de barlovento (el lado de donde viene el viento), a una distancia de seguridad que permita virar hacia el valle en cualquier #link(<glosario-momento>)[momento]#index("Momento").
- #strong[Tráfico:] si dos planeadores se cruzan en la misma ladera, el que tiene la montaña a su #strong[derecha] tiene preferencia. El otro debe separarse hacia el valle. Los giros se hacen siempre #strong[hacia fuera de la montaña] (hacia el valle).

#block[
#callout(
body: 
[
Nunca vires hacia la ladera si no tienes espacio garantizado para completar el viraje con margen. A sotavento de la montaña ---detrás de la cresta--- el aire puede descender con violencia incluso en condiciones de vuelo aparentemente buenas en barlovento. Una entrada accidental en la zona de rotor a baja altura sobre el terreno puede ser irrecuperable.

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
=== Vuelo de onda (#emph[wave soaring])
<vuelo-de-onda-wave-soaring>
El #strong[vuelo de onda] (#strong[wave soaring]) ocurre cuando, con viento fuerte y condiciones atmosféricas estables, el flujo de aire desviado hacia arriba por una cordillera genera un sistema de ondas de presión a sotavento, similar a las ondas que forma una piedra en el agua. Estas ondas pueden extenderse decenas o cientos de kilómetros y alcanzar altitudes estratosféricas (#ref(<fig-06-cap03-onda-esquema>, supplement: [Figura])).

- #strong[Identificación:] la señal visual más característica son las #strong[nubes lenticulares] (#strong[lenticular clouds]): nubes con forma de lenteja o sombrero que permanecen estáticas sobre el terreno mientras el viento las atraviesa continuamente.
- #strong[Características:] el ascenso en la cresta de la onda es suave, constante y de gran amplitud. Es la vía hacia altitudes que ninguna térmica puede alcanzar.
- #strong[Zona de rotor:] inmediatamente debajo de las nubes de rotor ---las nubes fragmentadas y agitadas visibles bajo el nivel de la onda--- el aire es violentamente turbulento. Esta zona puede dañar estructuralmente el planeador y es obligatorio evitarla.

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap03-onda-esquema.png"))
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
El vuelo de onda a gran altitud requiere equipamiento específico: oxígeno a partir de los 3.000-4.000 metros según la autonomía y condición del piloto, ropa de abrigo adecuada y un altímetro calibrado. Antes de un vuelo de onda planificado, consulta el espacio aéreo: es frecuente que las altitudes de onda coincidan con zonas restringidas o reservadas para el tráfico controlado, que requieren autorización previa.

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
== Gestión del lastre de agua (#emph[water ballast])
<gestión-del-lastre-de-agua-water-ballast>
El #strong[lastre de agua] consiste en depósitos situados en las alas del planeador que pueden llenarse de agua antes del vuelo. Al aumentar la masa del planeador, su #link(<glosario-curva-polar>)[curva polar]#index("Curva polar") se desplaza hacia velocidades más altas: el planeador vuela más rápido entre térmicas con el mismo ángulo de planeo.

La analogía más útil es la del ciclista: en un descenso largo, ir cargado permite llegar más rápido al fondo sin pedalear. Con lastre, el planeador «cae» más rápido pero a igual planeo, lo que es ventajoso cuando las térmicas son fuertes y los planeos entre térmicas son largos.

- #strong[Cuándo usarlo:] solo en días de térmicas fuertes (por encima de 2-3 m/s) y vuelos largos donde los planeos entre térmicas son significativos. En días débiles, el lastre penaliza más que ayuda.
- #strong[Vaciado:] si la meteorología empeora o antes del aterrizaje, el lastre debe vaciarse completamente. Abre las válvulas con tiempo suficiente: el vaciado completo suele tardar entre 3 y 8 minutos según el planeador.
- #strong[Hielo:] si vuelas a gran altitud con lastre, añade anticongelante al agua para evitar que se congele y dañe los depósitos o los sistemas de vaciado.

#block[
#callout(
body: 
[
Un planeador con lastre de agua tiene una #strong[velocidad de pérdida significativamente mayor] ---hasta 15-20 km/h más que sin lastre---. Ajusta todas tus velocidades de referencia (despegue, aproximación, circuito) en consecuencia. #strong[Nunca aterrices con lastre completo], salvo que una avería del vaciado te obligue --- y entonces, extrema la suavidad de la toma: la inercia adicional puede superar la resistencia estructural de las alas y provocar un fallo catastrófico.

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
#strong[Resumen del capítulo: técnicas de planeo]

- #strong[Centrado de térmica]: siente el empujón en el asiento. Si el ala derecha sube, el núcleo está a la derecha: vira a la derecha. Cierra el viraje cuando el vario sube, ábrelo cuando baja. Con práctica, este ciclo se vuelve automático.
- #strong[Hilo de lana lateral (side string)]: técnica complementaria opcional para visualizar de forma didáctica el ángulo de ataque en vuelo lento; no sustituye al hilo central ni al anemómetro.
- #strong[Anillo MacCready]: tu selector de velocidad óptima. Pon el anillo en el valor de ascenso que esperas encontrar (p.~ej., 2 m/s) y vuela a la velocidad que te marque. Acelera en corrientes descendentes, aminora en corrientes ascendentes.
- #strong[Ladera]: mantente pegado a barlovento con vía de escape hacia el valle siempre disponible. Si tienes la ladera a tu derecha, tienes preferencia. Nunca vires hacia el monte.
- #strong[Onda]: la autopista al cielo. Sube en la zona laminar, delante de la nube de rotor. Requiere oxígeno y ropa de abrigo. Cuidado al bajar: el rotor puede romperte el planeador en segundos.
- #strong[Lastre de agua]: más masa = más velocidad sin perder planeo. Útil en días fuertes y travesías largas. Vacíalo antes de aterrizar y ajusta siempre las velocidades de referencia: con lastre, la pérdida llega mucho antes.

]
= Circuitos y aterrizaje
<circuitos-y-aterrizaje>
#quote(block: true)[
El #link(<glosario-circuito-de-trafico>)[circuito de tráfico]#index("Circuito de tráfico") es el corazón del vuelo de planeador: el #link(<glosario-momento>)[momento]#index("Momento") en que toda la energía acumulada durante la travesía se convierte en un aterrizaje preciso y seguro. A diferencia de un avión con motor, el planeador no tiene segunda oportunidad si la primera aproximación sale mal ---no hay potencia para rectificar. El circuito exige planificación anticipada, visión tridimensional del espacio y la capacidad de tomar decisiones mientras el suelo se acerca.

En este capítulo aprenderás:

- #strong[La estructura del circuito estándar]: los cuatro tramos y las alturas de referencia en cada uno.
- #strong[La lista de comprobación FUSTALL]: qué verificar antes de aterrizar y en qué orden.
- #strong[Gestión de la velocidad con viento]: cómo calcular la velocidad de aproximación correcta.
- #strong[El uso eficaz de los #link(<glosario-aerofrenos>)[aerofrenos]#index("Aerofrenos")]: cómo utilizarlos para clavar el punto de toma.
- #strong[Las correcciones en circuito]: cómo adaptarse cuando la energía no coincide con el plan.
]

== Estructura del circuito de tráfico
<estructura-del-circuito-de-tráfico>
El #strong[circuito de tráfico] es un procedimiento estandarizado que organiza la llegada al aeródromo de forma predecible y segura para todos los participantes. Su geometría rectangular permite que el piloto tenga siempre #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") de la pista y pueda ajustar la energía disponible en cada tramo.

Los cuatro tramos estándar son (#ref(<fig-06-cap04-circuito-estandar>, supplement: [Figura])):

+ #strong[Viento cruzado (crosswind):] Tramo perpendicular a la pista, realizado justo tras el despegue o al entrar en el circuito desde la travesía. La altura recomendada al completar el giro a viento cruzado es de 250-300 metros (#link(<glosario-qfe>)[QFE]#index("QFE")).
+ #strong[#link(<glosario-viento-en-cola>)[Viento en cola]#index("Viento en cola")] (#strong[downwind]): Tramo paralelo a la pista en dirección contraria al aterrizaje. Se vuela a una distancia lateral de 200-400 metros de la pista, a una altura de 200-300 metros. Es el tramo donde se realizan las comprobaciones de la lista FUSTALL (ver sección siguiente).
+ #strong[#link(<glosario-base>)[Tramo de base]#index("Tramo de base")] (#strong[base leg]): Tramo perpendicular a la pista, iniciado cuando el punto de toma queda a unos 45° detrás del ala del piloto. La altura recomendada al inicio de la base es de 150 metros.
+ #strong[#link(<glosario-final>)[Final]#index("Tramo final")] (#strong[final leg]): Tramo alineado con la pista, desde el que se realiza el descenso y la toma. Los aerofrenos se gestionan de forma continua durante este tramo para clavar el punto de toma.

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap04-circuito-estandar.jpg"))
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
Antes de entrar en el tramo de viento en cola, abre los grifos del #link(<glosario-lastre-de-agua>)[lastre de agua]#index("Lastre de agua") ---aunque no lo lleves, para consolidar el hábito: el vaciado completo lleva varios minutos---. Ya en el viento en cola, ejecuta la lista #strong[FUSTALL] antes de continuar hacia la base y el final:

- #strong[F] (#strong[#link(<glosario-flaps>)[Flaps]#index("Flaps")]): flaps en la posición de aterrizaje, si el planeador dispone de ellos.
- #strong[U] (#strong[Undercarriage / Tren de aterrizaje]): tren fuera y blocado. Comprueba visualmente la posición del indicador y, si el planeador lo tiene, el aviso sonoro.
- #strong[S] (#strong[Speed / Velocidad]): establece la velocidad de aproximación recomendada por el #link(<glosario-afm>)[AFM]#index("AFM") (ver sección siguiente para la corrección por viento).
- #strong[T] (#strong[#link(<glosario-compensador>)[Trim]#index("Compensador") / Compensador]): compensa el planeador a la velocidad de aproximación elegida.
- #strong[A] (#strong[Airbrakes / Aerofrenos]): verifica que los aerofrenos se mueven libremente y vuélvelos a cerrar para el tramo de base.
- #strong[L] (#strong[Landing area / Zona de aterrizaje]): escanea la zona de toma y el circuito completo: viento, otras aeronaves y personal en pista. ¿Hay otro planeador en final?
- #strong[L] (#strong[Land / Aterriza]): con todo verificado, dedica el resto del circuito exclusivamente a volar y aterrizar el planeador.

#block[
#callout(
body: 
[
Haz el FUSTALL siempre en el mismo punto del viento en cola ---por ejemplo, cuando la cabecera de la pista quede a la altura del ala---. La repetición convierte la lista en un hábito y hace prácticamente imposible omitirla. Un piloto que improvisa el momento del chequeo acaba por no hacerlo.

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
En muchos clubes europeos se enseña la mnemotecnia abreviada #strong[WULF] para el mismo chequeo de viento en cola: #strong[W] (#strong[Water ballast]): lastre de agua vaciado; #strong[U] (#strong[Undercarriage]): tren fuera y blocado; #strong[L] (#strong[Loose articles / Look-out]): objetos sueltos asegurados y vigilancia exterior; #strong[F] (#strong[Flaps]): flaps en posición de aterrizaje. Ambas listas persiguen lo mismo: llegar al tramo de base con la configuración completa y la atención puesta fuera de la cabina.

]
, 
title: 
[
Airmanship: LA REGLA TRADICIONAL WULF
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
Entrar en final lento con viento en cara es una de las combinaciones más peligrosas en el vuelo de planeador. El gradiente de viento próximo al suelo puede robarte los últimos 15-20 km/h de velocidad en décimas de segundo, llevándote directamente a la pérdida a una altura donde la recuperación es imposible. La velocidad adicional en final no es un lujo: es un seguro de vida.

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
== Uso de los aerofrenos
<uso-de-los-aerofrenos>
Los #strong[aerofrenos] son el control de planeo del planeador: permiten aumentar la tasa de descenso sin cambiar la actitud ni la velocidad. Son el instrumento que transforma la energía potencial sobrante en frenado aerodinámico y permiten clavar el punto de toma con precisión (#ref(<fig-06-cap04-aerofrenos-angulo>, supplement: [Figura])).

La estrategia más fiable para usar los aerofrenos es la siguiente:

- #strong[Aproximación estándar:] entra en final con los aerofrenos al #strong[50 %]. Esta posición central te da margen en ambas direcciones: si estás alto, abres más; si estás bajo, cierras.
- #strong[Ajuste continuo:] los aerofrenos se usan durante todo el final para mantener el punto de referencia estático en el parabrisas. Si el punto sube hacia ti, estás bajo: cierra aerofrenos. Si el punto baja, estás alto: abre más.
- #strong[Viraje de base a final:] evita usar los aerofrenos completamente abiertos durante el viraje. Una tasa de descenso elevada combinada con un alabeo pronunciado aumenta la #link(<glosario-carga-alar>)[carga alar]#index("Carga alar") efectiva y puede acercar peligrosamente el planeador a la velocidad de pérdida.
- #strong[Toma de tierra:] una vez que el planeador ha tocado, mantén los aerofrenos abiertos para evitar que vuelva a saltar (#strong[balonazo]) y para mejorar la eficacia del freno de rueda.

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap04-aerofrenos-angulo.jpg"))
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
Si en el viraje de base a final observas que vas a pasar de largo el punto de toma con los aerofrenos completamente abiertos, no cierres los frenos bruscamente cerca del suelo: el planeador sufrirá un balonazo repentino. En su lugar, si el campo lo permite, prolonga el giro de base o realiza una S suave en final para aumentar la distancia recorrida. Si nada funciona, estás en una situación de campo largo: aterriza y rueda hasta el final de la pista.

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
== El resbale lateral (#emph[sideslip])
<el-resbale-lateral-sideslip>
El #strong[#link(<glosario-resbale-lateral>)[resbale lateral]#index("Resbale lateral")] (conocido como #strong[sideslip] en la terminología internacional) es una maniobra operativa avanzada que permite aumentar drásticamente la tasa de descenso del planeador sin incrementar su velocidad de avance. Consiste en provocar un resbale de forma deliberada exponiendo el lateral del fuselaje a la corriente de aire, lo que genera una gran resistencia aerodinámica.

Es el recurso definitivo de control de senda en las siguientes situaciones:

- Fallo o atasco de los aerofrenos en la aproximación.
- Aproximaciones excesivamente altas a campos desconocidos durante un aterrizaje fuera de campo.
- Ajustes rápidos de altura en días de turbulencias severas o #link(<glosario-cizalladura>)[cizalladura]#index("Cizalladura").

Para realizar un resbale de forma segura, aplica la siguiente técnica:

+ #strong[Entrada:] inicia un viraje suave hacia un lado y, de inmediato, aplica timón de dirección en sentido opuesto (cruza los mandos: alerón a un lado, pedal al contrario). El fuselaje se orientará oblicuo respecto a la trayectoria real de vuelo.
+ #strong[Dirección del viento:] orienta siempre la dirección del resbale de modo que #strong[el ala baja apunte hacia el viento] (si el viento viene de la izquierda, realiza un resbale con alabeo a la izquierda y pedal derecho). Esto ayuda a contrarrestar la #link(<glosario-deriva>)[deriva]#index("Deriva") lateral y mejora el control.
+ #strong[Control de velocidad:] como el aire incide de lado sobre el fuselaje, la presión estática y dinámica en las tomas del planeador se altera y #strong[el anemómetro muestra indicaciones erróneas o nulas]. Controla la velocidad de aproximación de forma exclusivamente visual, manteniendo el morro en una actitud ligeramente picada respecto al horizonte.
+ #strong[Salida:] para finalizar la maniobra, relaja primero la presión en la palanca de profundidad (morro abajo) y luego neutraliza suavemente los alerones y el pedal de dirección. El planeador volverá de inmediato al vuelo coordinado en la senda deseada.

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap04-resbale-lateral.png"))
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
Debido a que el flujo de aire está desprendido y el anemómetro no es fiable durante el resbale, existe riesgo de entrada en pérdida si el piloto tira excesivamente de la palanca de profundidad. Mantén siempre una actitud de morro netamente baja. Practica la maniobra a altura de seguridad antes de intentarla en circuito.

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
=== Aterrizaje con viento de cola (#strong[downwind landing])
<aterrizaje-con-viento-de-cola-downwind-landing>
Aunque la regla de oro de la aviación exige aterrizar siempre de cara al viento para reducir la carrera en tierra, existen situaciones operativas (como una fuerte pendiente cuesta arriba en un aterrizaje fuera de campo o restricciones de obstáculos en la aproximación) que pueden obligar al piloto a realizar un aterrizaje con viento de cola.

El viento de cola altera radicalmente las referencias sensoriales del piloto y la física de la toma:

- #strong[Aumento de la velocidad sobre el suelo (groundspeed):] si tu velocidad de aproximación indicada es de 90 km/h y tienes un viento de cola de 20 km/h, tu velocidad real respecto al suelo será de 110 km/h. La carrera de aterrizaje se alargará mucho más y exigirá más distancia y un uso eficaz del freno de rueda.
- #strong[La ilusión visual de velocidad:] al ver pasar el suelo a gran velocidad durante el final y la toma, tu cerebro interpretará falsamente que vas demasiado rápido. La reacción instintiva y peligrosa es tirar de la palanca de mando para frenar el velero. Esto reducirá la velocidad indicada por debajo de la de seguridad y puede provocar una pérdida (#strong[stall]) y entrada en barrena (#strong[spin]) a escasos metros del suelo.
- #strong[Senda de aproximación plana:] al desplazarte más rápido sobre el terreno, tu ángulo de descenso aparente será mucho más plano. Mantén una senda conservadora utilizando los aerofrenos con precisión.

#block[
#callout(
body: 
[
Cuando vueles una aproximación con viento de cola, #strong[fía tu control de velocidad exclusivamente al anemómetro], ignorando la velocidad aparente con la que pasa el terreno bajo la cabina. Mantén la velocidad de aproximación recomendada y prepárate para una carrera de rodaje muy larga y un frenado enérgico.

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
=== Oscilaciones inducidas por el piloto (#emph[PIO]) en cabeceo
<oscilaciones-inducidas-por-el-piloto-pio-en-cabeceo>
Las oscilaciones inducidas por el piloto (#strong[pilot-induced oscillations - PIO]) son fluctuaciones rápidas e incontroladas en la actitud de cabeceo del planeador cerca del suelo, generadas por la reacción tardía del piloto ante pequeños desvíos de trayectoria.

Durante la fase final de aproximación y la toma de tierra, a bajas velocidades, la efectividad de los mandos de vuelo se reduce y existe un ligero retraso (#strong[control lag]) entre el movimiento de la palanca y la respuesta física de la aeronave. Si el planeador sufre una pequeña ráfaga de viento y se encabrita, un piloto fatigado o de reflejos tardíos puede empujar la palanca hacia adelante con fuerza; cuando el planeador responde y empieza a picar, el piloto tira con fuerza hacia atrás. Este ciclo de correcciones excesivas y desfasadas se amplifica rápidamente:

- #strong[Consecuencias:] las oscilaciones pueden terminar en un contacto extremadamente duro del tren de aterrizaje principal o de la rueda de morro contra la pista, con daños estructurales severos en el fuselaje o lesiones a la tripulación.
- #strong[Corrección en vuelo:] en el momento en que sientas que inicias una oscilación en cabeceo cerca de la pista, #strong[congela la palanca de mando] en una posición estable y neutral. Deja que el planeador se estabilice solo por su #link(<glosario-estabilidad-estatica>)[estabilidad estática]#index("Estabilidad estática") longitudinal y, si es necesario, abre o mantén los aerofrenos al 50 % para asentar la aeronave con suavidad (#ref(<fig-06-cap04-pio-cabeceo>, supplement: [Figura])).

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap04-pio-cabeceo.png"))
], caption: figure.caption(
position: bottom, 
[
Oscilación inducida por el piloto (PIO): correcciones desfasadas que se amplifican
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-06-cap04-pio-cabeceo>


#postit[
#strong[Resumen del capítulo: circuitos y aterrizaje]

- #strong[Circuito estándar]: cuatro tramos ---cruzado, viento en cola, base y final--- con alturas de referencia: 250-300, 200-300 y 150 metros hasta la toma. El circuito no es un ritual, es un gestor de energía.
- #strong[FUSTALL en el viento en cola]: #strong[Flaps], #strong[Undercarriage] (tren fuera y blocado), #strong[Speed] (velocidad de aproximación), #strong[Trim], #strong[Airbrakes] (aerofrenos libres y cerrados), #strong[Landing area] (viento y tráfico), #strong[Land]. Lastre de agua vaciado antes de entrar al circuito. Hazlo siempre en el mismo punto del recorrido.
- #strong[Velocidad de aproximación]: calcula tu velocidad base (1,5 V#sub[S]) y #strong[súmale la mitad del viento y de la racha]. Entrar lento con viento es receta para un accidente por cizalladura.
- #strong[Aerofrenos]: entra en final con el 50 % sacados. Si el punto de toma sube en el parabrisas, cierra; si baja, abre. Nunca cierres bruscamente cerca del suelo: balonazo y golpe de cola.
- #strong[Resbale lateral (sideslip)]: método de descenso rápido de emergencia cruzando mandos. Recuerda: #strong[ala baja al viento], actitud visual de morro bajo (el anemómetro no es fiable por el flujo cruzado) y salida relajando primero la palanca.
- #strong[Viento de cola y PIOs]: en tomas con viento de cola, ignora la velocidad visual del suelo (evita pérdidas de sustentación) y prepárate para un rodaje largo. Si el velero oscila en cabeceo (#strong[PIO]) cerca del suelo, congela la palanca y deja actuar su estabilidad estática.

]
= Aterrizaje fuera de campo (#emph[outlanding])
<aterrizaje-fuera-de-campo-outlanding>
#quote(block: true)[
El #strong[aterrizaje fuera de campo] (#strong[#link(<glosario-outlanding>)[outlanding]#index("Outlanding")]) es una realidad estadística del vuelo de travesía. No es un fallo, ni un accidente: es un procedimiento previsto, entrenado y perfectamente ejecutable cuando se hace con la cabeza fría y la altitud adecuada. La diferencia entre un aterrizaje fuera de campo que se cuenta en el hangar y uno que se convierte en accidente reside en un único factor: el #link(<glosario-momento>)[momento]#index("Momento") en que el piloto toma la decisión.

En este capítulo aprenderás:

- #strong[La decisión de aterrizar]: cuándo y por qué la demora es la causa número uno de accidentes en campo.
- #strong[#link(<glosario-las-7-s>)[Las 7 S]#index("Las 7 S") de selección de campo]: los siete criterios que evalúas en segundos para elegir el campo correcto.
- #strong[El análisis de superficies]: qué tipo de terreno es apto y cuáles son los engaños más frecuentes.
- #strong[La técnica de aproximación fuera de campo]: cómo adaptar el circuito estándar a un terreno desconocido.
- #strong[Procedimientos post-aterrizaje]: cómo asegurar el planeador, coordinar el rescate y gestionar la supervivencia y la relación con el propietario del terreno.
]

== La decisión de aterrizar fuera de campo
<la-decisión-de-aterrizar-fuera-de-campo>
El mayor enemigo del piloto en una situación de campo no es el terreno: es la esperanza. La esperanza de que aparecerá una #link(<glosario-termica>)[térmica]#index("Térmica") salvadora. De que ese campo que viste hace diez minutos todavía está dentro del alcance. De que bajar un poco más para buscar ascendencia no tiene consecuencias.

La estadística es contundente: la causa número uno de accidentes graves en vuelo de travesía no es la falta de campos disponibles, sino la #strong[demora en tomar la decisión de aterrizar]. El piloto que espera demasiado llega al campo elegido sin altura suficiente para inspeccionarlo correctamente, sin margen para rectificar una aproximación mal planificada y sin energía para evitar un obstáculo no visto.

La herramienta más útil para combatir este sesgo cognitivo es fijar de antemano una #strong[#link(<glosario-altura-de-decision>)[altura de decisión]#index("Altura de decisión")]. O mejor: una escalera de tres peldaños que convierte el descenso en un plan por fases, en lugar de un ultimátum:

- #strong[600 metros sobre el terreno:] selecciona la zona general donde vas a aterrizar. Puedes seguir buscando térmicas, pero solo las que te dejen siempre esa zona al alcance.
- #strong[450 metros:] elige el campo definitivo y evalúa sus 7 S (siguiente sección). Si pruebas una térmica, que sea sobre el propio campo.
- #strong[300 metros:] comprométete con el circuito. El juego térmico ha terminado; a partir de aquí, toda tu atención es para el aterrizaje.

#block[
#callout(
body: 
[
Retrasar la decisión de aterrizar buscando una «térmica de rescate» a baja altura es el patrón más documentado en los accidentes graves de vuelo sin motor. Una vez fijada la altura de decisión, respétala sin excepciones. El planeador se puede reparar. El piloto, no siempre.

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
#box(image("06-procedimientos-operativos/imagenes/06-cap05-7s-campo.jpg"))
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
+ #strong[Circuito estándar:] realiza un circuito lo más estándar posible. No inventes aproximaciones directas o curvas. El circuito estándar te da tiempo para inspeccionar el terreno en el #link(<glosario-viento-en-cola>)[viento en cola]#index("Viento en cola") y ajustar la energía en la #link(<glosario-base>)[base]#index("Tramo de base").
+ #strong[Configuración:] tren de aterrizaje fuera y blocado, arneses ajustados al máximo. En caso de impacto, el arnés bien apretado es la diferencia entre una contusión y una lesión grave.
+ #strong[Velocidad:] mantén una velocidad ligeramente superior a la habitual ---añade 10-15 km/h sobre tu velocidad normal--- para tener mejor control ante las turbulencias mecánicas de los árboles y edificios cercanos.
+ #strong[La toma:] toca tierra con la mínima velocidad posible y mantén el planeador recto. Una vez en tierra, frena con decisión: es preferible romper el tren de aterrizaje contra un surco que intentar flotar sobre un obstáculo y entrar en pérdida.

#block[
#callout(
body: 
[
Si durante el rodaje ves que vas a chocar contra un obstáculo insalvable a alta velocidad, puedes provocar un «caballito» deliberado bajando un ala al suelo. El planeador pivotará sobre esa ala y se detendrá bruscamente, sacrificando la estructura del ala para salvar al piloto. Esta maniobra solo se usa como último recurso, cuando la alternativa es el impacto frontal a velocidad.

]
, 
title: 
[
Seguridad: EL «CABALLITO» (GROUND LOOP)
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
- #strong[Bloqueadores de mandos (gust locks):] asegura la palanca de mandos con el cinturón de seguridad y coloca bloqueadores externos en las superficies de control (timón, profundidad y alerones) si dispones de ellos, para evitar que el viento golpee las superficies contra sus topes físicos.
- #strong[Protección de la cabina y #link(<glosario-cupula>)[cúpula]#index("Cúpula"):] cierra y bloquea la cúpula inmediatamente. Si el sol es intenso, coloca la funda protectora de la cúpula para evitar el efecto invernadero en el interior de la cabina (que puede deformar instrumentos o resinas de la estructura o, incluso, provocar un incendio por efecto lupa) y el envejecimiento acelerado por la radiación UV.
- #strong[Fundas de protección:] coloca las fundas en las tomas de Pitot y de presión estática/total (#link(<glosario-energia-total>)[TE]#index("Energía total")) para evitar la entrada de insectos o suciedad del campo, que inutilizarían los instrumentos en el próximo vuelo.

=== Comunicaciones y localización
<comunicaciones-y-localización>
La tripulación de carretera (#strong[retrieve crew]) o tu club de vuelo necesitan saber exactamente dónde estás. No confíes en referencias visuales vagas como «cerca de un granero rojo». Sigue este protocolo de comunicación:

- #strong[Obtención de coordenadas:] lee las coordenadas geográficas exactas en tu sistema de navegación o en el teléfono móvil utilizando el #link(<glosario-gps>)[GPS]#index("GPS"). Anota las coordenadas en formato estándar (grados decimales o grados, minutos y segundos) y la altitud.
- #strong[Llamada de estado:] contacta por teléfono o, si no hay cobertura móvil, utiliza la radio de aviación en la frecuencia de tu club o del aeródromo local para informar de que la toma ha sido segura y sin daños personales.
- #strong[Uso de rastreadores satelitales:] si vuelas en zonas montañosas o remotas sin cobertura telefónica, activa el mensaje de «llegada segura» (#strong[OK]) en tu dispositivo de seguimiento por satélite (tipo SPOT o Garmin inReach) para que tus contactos reciban tu ubicación exacta en tiempo real.
- #strong[Balizas de emergencia (#link(<glosario-elt>)[ELT]#index("ELT")/#link(<glosario-plb>)[PLB]#index("PLB")):] en caso de aterrizaje de emergencia con lesiones o daños graves que impidan otras comunicaciones, asegúrate de que la baliza transmisora de localización de emergencia (#strong[Emergency Locator Transmitter - ELT]) de 406 MHz se ha activado (o activa manualmente tu radiobaliza personal PLB). No la actives para un aterrizaje preventivo normal sin daños.

=== Supervivencia en zonas remotas
<supervivencia-en-zonas-remotas>
Si has tomado tierra en una región montañosa, desértica o boscosa de difícil acceso, el rescate puede demorarse varias horas o incluso pasar la noche. Aplica la siguiente regla de oro de la supervivencia aeronáutica:

#block[
#callout(
body: 
[
#strong[Permanece siempre junto al planeador]. Una aeronave de color blanco o brillante de 15 metros de envergadura es infinitamente más fácil de avistar desde el aire por los equipos de rescate que un piloto caminando solo por el bosque o la montaña. Abandonar el velero para buscar ayuda a pie multiplica el riesgo de desorientación, hipotermia y retraso en la localización.

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
- #strong[Uso del cockpit como refugio:] el habitáculo del planeador proporciona una excelente protección contra el viento, la lluvia y el frío. Utiliza los cojines y el espacio interior para aislarte del suelo húmedo o del frío de la estructura.
- #strong[El #link(<glosario-paracaidas-de-emergencia>)[paracaídas de emergencia]#index("Paracaídas de emergencia"):] la tela de nailon de tu paracaídas de emergencia es una herramienta de supervivencia valiosísima. Puedes extraerla del arnés y usar su gran superficie para montar un refugio tipo tienda contra el velero, envolverte en ella para conservar el calor corporal (actúa como un cortavientos eficaz) o extenderla en el suelo como señal visual de alto contraste para las búsquedas aéreas.

=== Relación con el propietario del terreno
<relación-con-el-propietario-del-terreno>
El aterrizaje fuera de campo se realiza amparado por el estado de necesidad de la seguridad aeronáutica, pero no debes olvidar que te encuentras en una propiedad privada:

- #strong[Minimización de daños:] al desmontar el planeador para introducirlo en el remolque, procura no pisar cultivos altos ni dañar vallas o cercados. Si es necesario, traslada las piezas a pie por los bordes de la parcela.
- #strong[Trato diplomático:] cuando el agricultor o el dueño de la finca se presente, muéstrate educado y agradecido. Explica con calma que se ha tratado de un aterrizaje preventivo por falta de sustentación (una situación normal y segura) y que no tenías motor para regresar. La inmensa mayoría de las personas son comprensivas si se les trata con cortesía y respeto por su propiedad.

#postit[
#strong[Resumen del capítulo: aterrizaje fuera de campo]

- #strong[La decisión (600/450/300 m)]: a 600 m sobre el terreno, elige la zona; a 450 m, el campo; a 300 m, comprométete con el circuito y olvida las térmicas. Retrasar esta decisión buscando un «milagro rasante» es la causa número 1 de accidentes graves.
- #strong[Selección del campo (7 S)]: tamaño, forma, pendiente, superficie, alrededores, animales y sol. Un campo grande, llano, con viento en cara y sin obstáculos en la aproximación es tu seguro de vida.
- #strong[El circuito]: hazlo #strong[estándar]. No inventes aproximaciones directas raras. El viento en cola sirve para inspeccionar el terreno; la base, para ajustar la altura; el #link(<glosario-final>)[final]#index("Tramo final"), para clavar la toma.
- #strong[En tierra]: frena a fondo. Es mejor romper el tren en un surco que intentar flotar sobre un obstáculo y entrar en pérdida a tres metros del suelo.
- #strong[Procedimientos post-toma]: asegura el planeador contra el viento (pesos en planos, cúpula cerrada, fundas de pitot), transmite tus coordenadas GPS exactas, permanece junto a la aeronave si estás en zona aislada (usa la tela del paracaídas como refugio) y mantén un trato respetuoso y educado con el agricultor.

]
= Procedimientos operativos especiales y peligros
<procedimientos-operativos-especiales-y-peligros>
#quote(block: true)[
El vuelo de planeador se desarrolla en un entorno compartido con otras aeronaves, con fauna aérea, con fenómenos meteorológicos que pueden aparecer en minutos y con una orografía que puede ser tan aliada como adversaria. Conocer los procedimientos específicos para cada uno de estos escenarios ---y entender por qué están diseñados así--- es lo que separa al piloto reactivo del piloto preventivo.

En este capítulo aprenderás:

- #strong[Vigilancia exterior y colisiones]: la regla de los 3 segundos y las técnicas de escaneo visual.
- #strong[#link(<glosario-flarm>)[FLARM]#index("FLARM")]: cómo funciona, qué detecta y, sobre todo, qué no detecta.
- #strong[Peligros de la fauna]: cómo coexistir con las aves sin asumir riesgos innecesarios.
- #strong[Estelas turbulentas y #link(<glosario-engelamiento>)[engelamiento]#index("Engelamiento")]: dos amenazas silenciosas en vuelo.
- #strong[Viento cruzado]: técnica de despegue y aterrizaje en condiciones exigentes.
- #strong[Riesgos en montaña]: horizonte falso, reglas de preferencia y la prohibición absoluta de virar hacia la ladera.
- #strong[#link(<glosario-amerizaje>)[Amerizaje]#index("Amerizaje") (ditching)]: qué hacer si el agua es inevitable.
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
<técnicas-de-escaneo-visual-1>
- #strong[Vigilancia activa:] dedica el 95 % del tiempo a mirar fuera de la cabina. Los instrumentos solo necesitan miradas breves y periódicas.
- #strong[Barrido sectorial:] divide el horizonte en sectores de 15-20° (#ref(<fig-06-cap06-escaneo-visual>, supplement: [Figura])). Mueve los ojos de sector en sector, deteniéndote brevemente en cada uno. La visión periférica detecta el movimiento, pero para resolver si es una aeronave necesitas mirar directamente.
- #strong[Antes de virar:] mira siempre hacia el lado del viraje y al sector contrario antes de inclinar el planeador.
- #strong[Puntos ciegos:] las alas, el fuselaje y el capó ocultan parte del cielo. Mueve ligeramente el morro o alabea suavemente para «limpiar» las zonas ciegas de forma periódica.

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap06-escaneo-visual.jpg"))
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
El #strong[FLARM] es un sistema de alerta de colisión diseñado específicamente para el vuelo sin motor y la aviación general ligera. Opera enviando la posición #link(<glosario-gps>)[GPS]#index("GPS") del planeador y su vector de movimiento predicho mediante una señal de radio corta a todos los equipos FLARM cercanos. Cada equipo recibe estas posiciones, calcula si las trayectorias convergen y, si detecta riesgo de colisión, emite una alerta sonora y visual con la dirección e intensidad del peligro.

- #strong[¿Qué detecta?] Aeronaves equipadas con FLARM o dispositivos compatibles (PowerFLARM, SoftRF, FANET), algunos aviones con ADS-B Out, y obstáculos fijos programados en su #link(<glosario-base>)[base]#index("Tramo de base") de datos (cables de teleférico, antenas, tendidos eléctricos en zonas de vuelo de competición).
- #strong[¿Qué NO detecta?] Aeronaves sin FLARM ni ADS-B (muchos aviones ultraligeros, helicópteros militares, parapentes, globos sin equipar), objetos no incluidos en su base de datos, y tráfico fuera de su alcance de radio (habitualmente 3-5 km horizontal).

=== Procedimiento operativo ante alertas FLARM
<procedimiento-operativo-ante-alertas-flarm>
Para que el FLARM cumpla con su función de seguridad sin generar distracciones fatales en cabina, el piloto debe seguir el siguiente protocolo de comportamiento estandarizado ante una alerta:

+ #strong[Lectura rápida y anuncio:] capta la advertencia visual con una mirada rápida y precisa al instrumento y verbalízala en voz alta (p.~ej., «Tráfico a la una en punto, más alto»). Esto asegura que la tripulación (si vuela en biplaza) comparte la #link(<glosario-conciencia-situacional>)[conciencia situacional]#index("Conciencia situacional").
+ #strong[Búsqueda visual exterior proactiva:] dirige de inmediato la atención hacia el exterior de la cabina, enfocando la mirada en el sector indicado por la alerta. #strong[Nunca te quedes mirando fijamente la pantalla del FLARM] intentando interpretar símbolos o trayectorias; el instrumento te dice dónde buscar, pero la colisión solo se evita mirando afuera.
+ #strong[Confirmación visual:] mantén el rumbo y la actitud hasta confirmar el contacto visual con la aeronave conflictiva.
+ #strong[Nada de maniobras evasivas bruscas «a ciegas»:] si no logras establecer contacto visual con el tráfico, #strong[evita los virajes o cambios de altitud violentos] basados únicamente en la indicación de la pantalla del FLARM. Un viraje brusco sin ver al otro planeador puede llevarte a interceptar su trayectoria de evasión o a colisionar con un tercer planeador no equipado que se encuentre fuera del radar. Ante la duda, realiza cambios suaves y predecibles de actitud para aumentar tu #link(<glosario-cavok>)[visibilidad]#index("Visibilidad").

#block[
#callout(
body: 
[
El FLARM es una herramienta de seguridad extraordinariamente útil, (obligatoria para competición oficial desde un regional hasta los mundiales) pero #strong[nunca sustituye a la vigilancia visual]. Considéralo como un complemento que te avisa de los peligros que ya conoce, no como un sistema que elimina todos los riesgos. Ante una alerta FLARM, reacciona buscando visualmente la aeronave conflictiva: el sistema te indica la dirección, pero la maniobra #link(<glosario-final>)[final]#index("Tramo final") es responsabilidad tuya.

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
== Peligros de la fauna: aves
<peligros-de-la-fauna-aves>
Las aves ---especialmente los buitres, alimoches y cigüeñas negras--- son compañeros frecuentes en las térmicas y en el #link(<glosario-vuelo-de-ladera>)[vuelo de ladera]#index("Vuelo de ladera") y travesía. Son maestros del vuelo térmico y excelentes indicadores de la calidad del ascenso. Sin embargo, una colisión con un buitre leonado (6-10 kg de masa y una envergadura de casi 2,5 metros) puede destruir el borde de ataque, penetrar en la cabina o dañar de forma catastrófica los mandos de vuelo.

+ #strong[Trátalos como tráfico:] no intentes «perseguirlos», asustarlos ni acorralarlos con el planeador. Un ave asustada puede maniobrar de forma brusca e impredecible.
+ #strong[Evita cambios bruscos:] el ave suele esquivarte si mantienes una trayectoria predecible. Los cambios repentinos de dirección pueden llevarla directamente hacia ti.
+ #strong[Síguelas, no te juntes:] las aves indican el mejor núcleo de la #link(<glosario-termica>)[térmica]#index("Térmica"), pero mantén siempre una distancia de seguridad. Compartir el viraje con una bandada de buitres a corta distancia crea un entorno de visibilidad reducida y maniobra imprevisible.

#block[
#callout(
body: 
[
En la península ibérica, el encuentro con buitres leonados en térmica es diario durante la temporada de vuelo. Los instructores de la escuela española enseñan una regla de oro de seguridad ante una trayectoria de colisión inminente con un buitre: #strong[esquiva siempre al ave volando por encima de ella:]

El instinto de escape natural de un buitre asustado ante una amenaza de gran tamaño es #strong[plegar sus alas y arrojarse en picado hacia abajo] para ganar velocidad de escape rápida. Si el piloto intenta esquivar al buitre picando el planeador (por debajo), existe una altísima probabilidad de interceptar la trayectoria de caída del ave y chocar frontalmente. Ante la duda, mantén tu trayectoria coordinada o tira suavemente de la palanca para pasar por encima de su cota.

]
, 
title: 
[
Airmanship: EL COMPORTAMIENTO DE LOS BUITRES
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
Los tendidos eléctricos y los cables de telecomunicaciones son invisibles desde el aire en muchas condiciones de luz. Son el mayor riesgo no detectado en el vuelo de travesía y campo. El FLARM puede incluir su posición en zonas de competición, pero en vuelo libre la responsabilidad de detectarlos es exclusivamente visual: identifica los postes de hormigón o madera y traza mentalmente la línea entre ellos antes de sobrevolarla.

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
== Estelas turbulentas y engelamiento
<estelas-turbulentas-y-engelamiento>
=== Estelas turbulentas (#emph[wake turbulence])
<estelas-turbulentas-wake-turbulence>
Las #strong[estelas turbulentas] ---los vórtices de punta de ala generados por aeronaves pesadas--- son invisibles, persistentes y extraordinariamente peligrosas para un planeador. Se forman en el #link(<glosario-momento>)[momento]#index("Momento") del despegue y durante toda la fase de vuelo, descendiendo lentamente y desplazándose lateralmente con el viento.

- Evita volar por debajo y detrás de aeronaves pesadas o del propio avión remolcador.
- En el despegue por #link(<glosario-aerotow>)[aerotow]#index("Aerotow"), mantén la posición alta para no cruzar la estela del remolcador.
- En zonas de tránsito aéreo intenso, mantén una conciencia situacional activa sobre el tráfico de aerolíneas a niveles superiores.
- #strong[Peligro especial de helicópteros:] Los helicópteros generan estelas turbulentas extremadamente potentes debido a la carga de sus palas de #link(<glosario-rotor>)[rotor]#index("Rotor"). En vuelo estacionario o en rodaje lento (#strong[hover]), el flujo de aire descendente (#strong[downwash]) se expande radialmente en superficie y puede volcar un planeador a ras de suelo; mantén siempre una separación mínima de #strong[tres diámetros de rotor]. En vuelo de avance, generan vórtices de estela muy intensos debido a sus bajas velocidades operativas; evita volar por debajo o detrás de ellos y extrema la precaución en circuitos mixtos, ya que el #link(<glosario-atc>)[ATC]#index("ATC") no siempre emite avisos de estela para helicópteros de tonelaje ligero o medio.

#block[
#callout(
body: 
[
La #link(<glosario-turbulencia-de-estela>)[turbulencia de estela]#index("Turbulencia de estela") generada por helicópteros es desproporcionada en comparación con su peso. Dado que los planeadores tienen gran envergadura y poca #link(<glosario-carga-alar>)[carga alar]#index("Carga alar"), son extremadamente vulnerables. Nunca intentes aterrizar o despegar inmediatamente detrás de un helicóptero en movimiento y evita cruzar zonas donde se haya realizado vuelo estacionario reciente.

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
El agua en las alas ---por humedad, rocío o lluvia suave--- tiene un efecto similar al engelamiento leve: aumenta la resistencia y la velocidad de pérdida entre un 5-10 %. Aumenta tu velocidad de aproximación y de circuito si las alas están mojadas o si has volado en condiciones de humedad elevada. Este efecto es especialmente traicionero en el aterrizaje.

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
== Despegue y aterrizaje con viento cruzado
<despegue-y-aterrizaje-con-viento-cruzado>
Operar con viento cruzado exige una coordinación técnica activa de mandos para evitar que el planeador se desvíe de la pista o sufra daños estructurales en el ala de barlovento:

=== Despegue con viento cruzado
<despegue-con-viento-cruzado>
Mantén el #strong[alerón completamente hacia el lado del viento] al inicio de la carrera para evitar que el ala de barlovento se levante prematuramente. Usa el pedal contrario para mantener el eje longitudinal sobre la pista. A medida que ganas velocidad y los mandos se hacen más eficaces, reduce gradual y proporcionalmente la deflexión de alerones. Eleva el planeador sin viento lateral buscando la velocidad correcta y gira con proa al viento una vez en vuelo.

=== Aterrizaje con viento cruzado
<aterrizaje-con-viento-cruzado>
En final, utiliza la técnica del #strong[«cangrejo»]: apunta el morro hacia el viento para compensar la #link(<glosario-deriva>)[deriva]#index("Deriva") y mantener la trayectoria sobre tierra alineada con la pista. Justo antes de tocar tierra, usa el pedal para alinear el morro con la pista y el alerón para bajar el ala que recibe el viento, asegurando que la rueda principal toca sin deriva lateral (#ref(<fig-06-cap06-viento-cruzado>, supplement: [Figura])). Una toma con deriva lateral significativa puede romper el tren de aterrizaje o provocar un derrape que lleve el planeador fuera de la pista.

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap06-viento-cruzado.png"))
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

+ #strong[Tren de aterrizaje fuera:] consulta el #link(<glosario-afm>)[AFM]#index("AFM") de tu aeronave por si contempla el caso, pero la doctrina moderna de planeador ---confirmada por los ensayos de amerizaje y las notas de seguridad de DG Flugzeugbau--- es amerizar con el #strong[tren extendido]. La rueda frena el planeador al contacto con el agua y limita la profundidad de inmersión, sin riesgo apreciable de capotaje. Con el tren retraído ocurre lo contrario de lo que dicta la intuición: el morro bucea y la cabina puede quedar empujada bajo el agua. La vieja regla del «tren arriba» viene de los aviones con motor, no del planeador.
+ #strong[Configuración:] ameriza paralelo a las olas o al oleaje si es posible, con los #link(<glosario-aerofrenos>)[aerofrenos]#index("Aerofrenos") desplegados para reducir la velocidad al máximo.
+ #strong[Abandono inmediato:] sal de la cabina en cuanto te detengas. El planeador se hundirá en cuestión de segundos: la cabina de compuesto y la estructura rígida pierden flotabilidad con rapidez.

#postit[
#strong[Resumen del capítulo: procedimientos especiales y peligros]

- #strong[Vigilancia visual]: el FLARM ayuda, pero no lo ve todo. El 95 % del tiempo, mira fuera. Barre el horizonte en sectores. Antes de virar, mira siempre hacia el lado del viraje.
- #strong[Viento cruzado]: alerón al viento en el despegue para que no levante el plano, pie contrario para no irte de la pista. En el aterrizaje, «cangrejo» hasta el final y alinear con el pie antes de tocar.
- #strong[Vuelo en montaña]: horizonte falso. Las cumbres te engañan; si las usas como referencia, volarás con el morro muy alto y entrarás en pérdida. Tu horizonte real es la base de la montaña o el valle.
- #strong[Engelamiento y lluvia]: cualquier contaminación del borde de ataque sube la velocidad de pérdida. Añade velocidad al circuito y a la aproximación. Si se acumula hielo, desciende de inmediato.
- #strong[Amerizaje]: si no queda otra opción, #strong[tren fuera] ---la rueda frena el planeador al contacto y evita que la cabina bucee---, paralelo a las olas y a velocidad mínima. En cuanto el planeador se pare, sal: se hunde en segundos.

]
= Procedimientos de emergencia
<procedimientos-de-emergencia>
#quote(block: true)[
Las emergencias en vuelo no se gestionan con improvisación: se gestionan con entrenamiento. La diferencia entre una emergencia que termina con el planeador en tierra y los tripulantes ilesos, y una que termina en accidente, suele medirse en uno o dos segundos de reacción y en si el procedimiento correcto estaba automatizado o no. Este capítulo describe las emergencias más frecuentes en el vuelo sin motor y el procedimiento exacto para cada una.

En este capítulo aprenderás:

- #strong[Emergencias en el lanzamiento]: cómo actuar ante una rotura de cable, un fallo de remolque o una suelta atascada (#strong[#link(<glosario-fallo-de-suelta>)[towhook jam]#index("Fallo de suelta")]).
- #strong[Fuego a bordo]: procedimiento en planeadores motorizados y gestión de la evacuación de humos.
- #strong[Fallos estructurales y de mandos]: qué hacer cuando un mando no responde, ante vibraciones anormales o desequilibrios de lastre.
- #strong[Fallo de instrumentos y sistemas]: cómo responder a la obstrucción de tomas de presión y a la apertura accidental de la #link(<glosario-cupula>)[cúpula]#index("Cúpula") en vuelo.
]

== Emergencias en el lanzamiento
<emergencias-en-el-lanzamiento>
La fase de lanzamiento concentra el mayor riesgo del vuelo de planeador. La combinación de baja altura, alta velocidad de aceleración y dependencia de un sistema externo ---el cable de #link(<glosario-torno>)[torno]#index("Torno") o el avión remolcador--- crea una ventana de vulnerabilidad en la que cualquier fallo exige una respuesta #strong[instintiva, inmediata y sin vacilación].

La regla de oro universal ante cualquier emergencia en el lanzamiento es:

- #strong[Primero:] bajar el morro a actitud de planeo para recuperar velocidad y evitar la pérdida.
- #strong[Segundo:] soltar el cable (si no se ha soltado automáticamente).
- #strong[Tercero:] evaluar la altura disponible y decidir la opción de aterrizaje.

Este orden de prioridades es invariable. No importa cuál sea la emergencia específica: la velocidad siempre es el primer recurso que hay que asegurar.

=== Rotura de cable o fallo de remolque
<rotura-de-cable-o-fallo-de-remolque>
Ante un #strong[#link(<glosario-fallo-de-lanzamiento>)[fallo de lanzamiento]#index("Fallo de lanzamiento")] ---rotura del cable de torno o fallo del motor del remolcador---, la reacción del piloto debe ser inmediata y automatizada. La metodología internacional estructura la respuesta de emergencia en torno a la mnemotecnia de #strong[las 3 P]:

+ #strong[Palanca:] empuja la palanca de mando adelante de inmediato (morro abajo) para estabilizar el planeador en actitud de planeo normal. En la actitud empinada de ascenso, la velocidad cae drásticamente y un retraso de más de dos segundos en bajar el morro causará una pérdida inminente.
+ #strong[Pulsador:] tira de la anilla de suelta del cable con fuerza dos o tres veces. Así te aseguras de que el cable roto se desengancha por completo del planeador y no arrastras restos que puedan engancharse en obstáculos del terreno (vallas, cultivos) durante la aproximación.
+ #strong[Pensar:] evalúa la altura disponible, la pista restante y el viento para ejecutar la decisión correspondiente en décimas de segundo.

La toma de decisiones táctica depende directamente de la altura #link(<glosario-agl>)[AGL]#index("AGL") alcanzada en el #link(<glosario-momento>)[momento]#index("Momento") del fallo y del método de lanzamiento utilizado, ya que la velocidad de ascenso y la distancia horizontal a la pista difieren drásticamente entre el torno y el avión tractor (#ref(<fig-06-cap07-emergencia-altura>, supplement: [Figura])):

- #strong[En lanzamiento por torno (winch):] la trayectoria de trepada es muy empinada y el planeador gana altura muy cerca del inicio de la pista. Las franjas de decisión de seguridad son:
- #strong[Baja altura (menos de 150 m AGL):] mantén el planeador recto por derecho, estabiliza la velocidad de planeo de seguridad y aterriza en la pista restante o en los campos de parada libre al frente. #strong[Está terminantemente prohibido intentar virar de vuelta a pista por debajo de esta cota] debido a la alta actitud de morro y el peligro inminente de barrena.
- #strong[Altura crítica (entre 150 m y 200 m AGL):] si no queda suficiente pista por delante, vuela a velocidad segura y realiza un circuito abreviado y muy recortado. Vira inicialmente con un alabeo coordinado medio (máximo 30°), adaptándolo al viento reinante para asegurar el #link(<glosario-final>)[tramo final]#index("Tramo final") de cara al viento.
- #strong[Altura de seguridad (más de 200 m AGL):] estabiliza la velocidad de planeo y realiza un #link(<glosario-circuito-de-trafico>)[circuito de tráfico]#index("Circuito de tráfico") abreviado estándar.
- #strong[En remolque por avión (#link(<glosario-aerotow>)[aerotow]#index("Aerotow")):] el despegue es más tendido y el planeador se desplaza horizontalmente lejos de la pista de salida. Las franjas de decisión son:
- #strong[Baja altura (menos de 70 m, ≈230 ft AGL):] aterriza recto por delante en la pista restante o en campos libres al frente, esquivando obstáculos con pequeños cambios de rumbo (máximo 30°).
- #strong[Altura crítica (entre 70 m ≈230 ft y 150 m ≈490 ft AGL):] evalúa la #link(<glosario-longitud>)[longitud]#index("Longitud") de pista y el viento. Si es necesario retornar, inicia el viraje #strong[hacia la componente de viento cruzado], coordinado y con un alabeo franco de unos 45°: el viento te devuelve hacia la prolongación de la pista durante el giro, mientras que virar a favor del viento alarga el recorrido y la altura perdida. Si el retorno no sale a cuenta, realiza una aproximación recortada al campo alternativo más seguro.
- #strong[Altura de seguridad (más de 150 m ≈ 500 ft AGL):] realiza un circuito recortado o normal de aproximación.

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap07-emergencia-altura.jpg"))
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
Ante un fallo de lanzamiento a altura crítica, #strong[un aterrizaje fuera de los límites del aeródromo (aterrizaje forzoso recto por delante) es siempre preferible a intentar un viraje de retorno forzado a baja altura]. Forzar el viraje para "salvar" el planeador y volver a la pista es la causa principal de pérdidas y barrenas fatales.

]
, 
title: 
[
Airmanship: LA DECISIÓN DE ATERRIZAR FUERA
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
Intentar regresar al aeródromo virando 180° a baja altura ---lo que en aviación se conoce como «la maniobra imposible»--- es la causa documentada de la mayoría de los accidentes graves en el despegue. La geometría del planeo no lo permite: el viraje a baja altura consume una energía y altura que no existen. #strong[Si estás por debajo de la altura crítica establecida (150 m en torno y 70 m en avión) y no hay espacio de pista por delante, aterriza recto en campo abierto. ¡Siempre!]

]
, 
title: 
[
Seguridad: «LA MANIOBRA IMPOSIBLE»
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
Cuando vueles una aproximación con el cable colgando, #strong[bajo ninguna circunstancia realices una aproximación baja]. El cable podría engancharse en una valla o línea eléctrica antes del umbral de la pista, lo que provocaría una deceleración violenta y un impacto del planeador contra el suelo sin control (#strong[pitch-up] o pérdida instantánea). Mantén un margen de altura generoso hasta superar el umbral.

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
Familiarízate con la posición de las válvulas de combustible y el extintor de tu planeador motorizado antes del primer vuelo. Una emergencia de fuego no deja tiempo para buscar manuales ni para recordar dónde están los controles de emergencia. La memoria muscular se entrena en tierra, no en vuelo.

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
== Fallos estructurales y de mandos
<fallos-estructurales-y-de-mandos>
=== Bloqueo o fallo de mandos
<bloqueo-o-fallo-de-mandos>
Un bloqueo parcial de mandos en vuelo ---por un objeto suelto en la cabina, una rotura interna o un fallo mecánico--- no implica necesariamente la pérdida de control total. Los planeadores modernos tienen superficies redundantes que pueden sustituirse parcialmente:

- #strong[Bloqueo de alerones:] el timón de dirección (pedal) provoca un alabeo secundario por #strong[efecto #link(<glosario-diedro>)[diedro]#index("ángulo diedro")] (#emph[dihedral effect]): al guiñar, el ala adelantada gana incidencia y genera más sustentación, lo que induce un alabeo que puede permitirte nivelar las alas y realizar un aterrizaje controlado. La respuesta es menor que con alerones, pero existe.
- #strong[Bloqueo de timón de profundidad:] el #link(<glosario-compensador>)[compensador]#index("Compensador") de profundidad ---si el planeador lo tiene--- puede controlar el cabeceo. Ajusta la velocidad abriendo o cerrando #link(<glosario-aerofrenos>)[aerofrenos]#index("Aerofrenos").
- #strong[Bloqueo total de mandos:] si ninguna superficie responde y el vuelo no es controlable, el procedimiento es el abandono de la aeronave (ver Capítulo 8: #link(<glosario-paracaidas-de-emergencia>)[Paracaídas de emergencia]#index("Paracaídas de emergencia")).

=== Flutter (vibración estructural)
<flutter-vibración-estructural>
El #strong[#link(<glosario-flutter>)[flutter]#index("Flutter")] es una vibración aeroelástica autosustentada que se produce a altas velocidades, cuando la respuesta aerodinámica y la inercia estructural del ala o del timón entran en resonancia. No es un traqueteo suave: es una vibración explosiva que puede destruir la superficie afectada en cuestión de segundos.

Las causas más frecuentes son el exceso de velocidad ---superar la V#sub[NE] (Velocidad Nunca Exceder) o aproximarse a ella en vuelo descendente---, el daño estructural previo o el mal equilibrado de una superficie de control tras una reparación.

#block[
#callout(
body: 
[
Si experimentas una vibración fuerte y descontrolada, #strong[reduce la velocidad de inmediato]: sube el morro suavemente y abre los aerofrenos para frenar aerodinámicamente. El #emph[flutter] solo ocurre a altas velocidades y puede destruir el planeador en segundos. Nunca intentes aumentar la velocidad para «salir» de una vibración: es la acción exactamente contraria a lo que necesitas. Tras cualquier episodio de vibración anormal, el planeador debe ser inspeccionado por un técnico antes de volar de nuevo.

]
, 
title: 
[
Seguridad: FLUTTER
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
=== Fallo de instrumentos de vuelo (Pitot o estática)
<fallo-de-instrumentos-de-vuelo-pitot-o-estática>
El bloqueo de las tomas de presión de tu planeador (normalmente debido a agua de lluvia condensada, insectos o por haber olvidado retirar las fundas prevuelo) altera por completo las indicaciones del panel de instrumentos. Debes saber identificar qué toma está obstruida y cómo volar de forma segura sin referencias instrumentales fiables.

- #strong[Fallo del tubo de Pitot (presión total):]
- #strong[Síntoma:] el anemómetro cae a cero en vuelo nivelado, o bien se comporta de forma invertida, actuando como un altímetro (la velocidad indicada aumenta al subir y disminuye al descender).
- #strong[Técnica de vuelo:] vuela de forma puramente visual controlando la #strong[actitud de cabeceo] respecto al horizonte. Sintoniza el #strong[sonido del viento] alrededor de la cabina (abre ligeramente la ventanilla lateral de tormenta o las ventilaciones para familiarizarte con el tono correspondiente a la velocidad de planeo óptimo). Presta atención al #strong[tacto y resistencia de los mandos] (a menor velocidad, la palanca se siente más blanda y con menos respuesta).
- #strong[Fallo de las tomas de presión estática:]
- #strong[Síntoma:] el altímetro se congela en un valor fijo y el #link(<glosario-variometro>)[variómetro]#index("Variómetro") se queda a cero, sin responder a los ascensos o descensos. El anemómetro también dará indicaciones erróneas debido a la presión estática atrapada en las tuberías instrumentales.
- #strong[Técnica de vuelo:] si tu planeador dispone de una toma de #strong[presión estática alterna] en cabina, conéctala mediante la válvula correspondiente.

#block[
#callout(
body: 
[
En caso de fallo instrumental completo en circuito de tráfico, confía plenamente en tu estimación visual del ángulo de planeo respecto al punto de toma. Mantén una actitud de morro conservadora, previene el pérdida asegurando una buena corriente de aire (sonido del viento consistente en cabina) y no intentes corregir visualmente basándote en un anemómetro que sabes bloqueado.

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
=== Apertura involuntaria de la cúpula en vuelo
<apertura-involuntaria-de-la-cúpula-en-vuelo>
Si la cúpula de tu planeador no quedó correctamente pestillada en los chequeos prevuelo (lista #NormalTok("CB-SIFT-CBE");), puede abrirse repentinamente en vuelo debido a las fuerzas aerodinámicas o a las turbulencias. Esto suele ocurrir durante la fase de remolque o poco después de la suelta. El ruido del viento y el torbellino de aire repentino dentro de la cabina pueden provocar pánico e inducir al piloto a cometer errores graves.

El procedimiento de seguridad exige las siguientes acciones inmediatas:

+ #strong[Vuela el planeador primero (Aviate):] tu prioridad absoluta es mantener el control de la aeronave. Ignora la cúpula por completo en los primeros segundos. #strong[No intentes cerrarla ni sujetarla] si estás a baja altura o en pleno viraje: perderías la atención al pilotaje y podrías inducir una actitud inusual o una pérdida. Tu planeador puede seguir volando perfectamente con la cúpula abierta.
+ #strong[Resiste el ruido y el torbellino:] el ruido será ensordecedor y habrá objetos sueltos volando en cabina, pero el planeador seguirá volando perfectamente. Si llevas gafas de sol y cinturones de seguridad bien ajustados, estarás seguro.
+ #strong[Establece una senda de planeo más pronunciada:] una cúpula abierta o parcialmente desprendida genera un #strong[incremento masivo de la resistencia aerodinámica] (#strong[drag]). Tu ángulo de planeo se deteriorará considerablemente. Para mantener la velocidad de seguridad, deberás adoptar una actitud de morro más baja (senda de aproximación más pronunciada y mayor tasa de descenso).
+ #strong[Planifica el aterrizaje:] si estás en el despegue, continúa el remolque estabilizado hasta una altura segura si es posible, o suelta y haz un circuito normal. Vuela un circuito de tráfico adaptado a una mayor tasa de descenso y aterriza en el aeródromo lo antes posible. Solo intenta cerrar la cúpula si estás a gran altura de seguridad, en vuelo coordinado y con una sola mano, sin dejar de pilotar.

#block[
#callout(
body: 
[
Nunca dejes de pilotar para intentar sujetar o cerrar una cúpula que se abre en circuito o a baja altura. Muchos accidentes mortales se han producido porque el piloto soltó la palanca de mandos para agarrar la cúpula con ambas manos, entrando el planeador en pérdida y barrena incontrolada o levantando la cola del remolcador y estrellándolo contra el suelo. Deja que la cúpula flote o se desprenda si es necesario; ¡concéntrate únicamente en volar!

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
=== Vaciado asimétrico del lastre de agua (#emph[asymmetrical water ballast])
<vaciado-asimétrico-del-lastre-de-agua-asymmetrical-water-ballast>
El uso de #link(<glosario-lastre-de-agua>)[lastre de agua]#index("Lastre de agua") (#strong[water ballast]) en las alas mejora el rendimiento a altas velocidades en vuelo de travesía. Sin embargo, si al iniciar el vaciado (#strong[dumping]) una de las válvulas de las alas se bloquea o tiene fugas, el planeador sufrirá un vaciado asimétrico. Esto genera un desequilibrio de peso lateral considerable, con un ala mucho más pesada que la otra.

El piloto debe gestionar esta asimetría aplicando la siguiente técnica:

- #strong[Efecto en el control:] el planeador tenderá a alabear con fuerza hacia el lado del ala que conserva el agua. Necesitarás aplicar una presión constante y significativa de alerón y timón de dirección (mando cruzado continuo) para mantener las alas niveladas, lo que reduce la efectividad del control lateral restante.
- #strong[Velocidad de aproximación más alta:] incrementa tu velocidad de aproximación estándar en al menos #strong[15-20 km/h] por encima de la velocidad calculada para el circuito. La velocidad adicional es indispensable para que los alerones conserven la autoridad necesaria para contrarrestar la tendencia al alabeo del plano pesado, y para prevenir una pérdida de ala (#strong[tip stall]) en el ala cargada durante los virajes.
- #strong[Planificación del circuito:] evita virajes pronunciados (alabeo máximo de 15° a 20°). Realiza giros suaves y coordinados hacia el circuito de tráfico. Siempre que sea posible, planifica los virajes hacia el lado del ala ligera: virar hacia el lado del ala pesada dificulta la recuperación del alabeo.
- #strong[Aterrizaje con alas niveladas:] durante la recogida y la toma de tierra, tu objetivo prioritario es mantener las alas perfectamente niveladas en el momento del contacto. Toca primero con el tren principal y, una vez en el suelo, haz todo lo posible para evitar que el ala cargada de agua caiga y toque el terreno mientras el velero aún se desplaza a gran velocidad: provocaría un caballito (#strong[ground loop]) violento (#ref(<fig-06-cap07-lastre-asimetrico>, supplement: [Figura])).

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap07-lastre-asimetrico.png"))
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
Un ala cargada con decenas de litros de agua tiene una velocidad de pérdida muy superior al ala vacía. En caso de vaciado asimétrico, si permites que la velocidad caiga demasiado en el tramo final o en el viraje de #link(<glosario-base>)[base]#index("Tramo de base"), el ala pesada entrará en pérdida de forma asimétrica y repentina, provocando una barrena (#strong[spin]) instantánea e irrecuperable a baja altura. Mantener la velocidad recomendada en circuito es tu defensa absoluta.

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
Las alturas de decisión que aparecen en este capítulo (150 y 200 m en torno; 70 y 150 m en remolque) y la escalera de decisión del aterrizaje fuera de campo son #strong[valores formativos de referencia], no cifras normativas: la cota crítica real de cada planeador la fijan su #link(<glosario-afm>)[AFM]#index("AFM") y las instrucciones locales del campo (longitud de pista, obstáculos, viento habitual). Apréndelas como orden de magnitud y ajústalas a tu aeronave y a tu aeródromo con tu instructor.

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
#postit[
#strong[Resumen del capítulo: procedimientos de emergencia]

- #strong[Regla universal]: ante cualquier emergencia en el lanzamiento, lo primero siempre es #strong[bajar el morro] para recuperar velocidad y evitar la pérdida. Después, suelta el cable y decide.

- #strong[Rotura de cable según el método de lanzamiento]:

  - #strong[Torno (winch)]:
  - #strong[\< 150 m]: aterriza recto por derecho. No intentes virar.
  - #strong[150 - 200 m]: circuito abreviado recortado adaptado al viento.
  - #strong[\> 200 m]: circuito de tráfico normal.
  - #strong[Avión (aerotow)]:
  - #strong[\< 70 m]: aterriza recto por delante.
  - #strong[70 - 150 m]: retorno o circuito recortado (el viraje de retorno se inicia hacia el viento cruzado, con alabeo franco de unos 45°).
  - #strong[\> 150 m]: circuito abreviado o normal.

- #strong[«La maniobra imposible»]: intentar volver a pista a baja altura es letal. Si estás por debajo de la cota crítica (150 m en torno / 70 m en avión) y no hay pista, aterriza de frente.

- #strong[Fallo de gancho (aerotow)]: si no puedes soltar, sitúate #strong[bajo y a la izquierda] del remolcador y alabea para avisarle; nunca por encima, que le levantarías la cola (#strong[kiting]). Él soltará. Aterriza con el cable colgando planeando una final alta para librar vallas y obstáculos.

- #strong[Flutter]: ante una vibración destructiva, #strong[sube el morro y abre los aerofrenos] para reducir la velocidad de inmediato. Nunca aceleres. Inspección obligatoria en tierra.

- #strong[Fallos de instrumentos]: con el pitot bloqueado, vuela por actitud visual de cabeceo y por el sonido del viento en cabina.

- #strong[Apertura de cúpula]: vuela el planeador primero (#strong[Aviate]). No intentes cerrarla si estás bajo. Baja el morro para contrarrestar el aumento de resistencia.

- #strong[Lastre asimétrico]: vuela 15-20 km/h más rápido en circuito para mantener la efectividad de los alerones y mantén las alas niveladas al tocar el suelo.

]
= Uso y aterrizaje con paracaídas de emergencia
<uso-y-aterrizaje-con-paracaídas-de-emergencia>
#quote(block: true)[
El #strong[#link(<glosario-paracaidas-de-emergencia>)[paracaídas de emergencia]#index("Paracaídas de emergencia")] es el último recurso del piloto cuando el planeador ha dejado de ser un medio de transporte seguro. No es un equipo que se usa «por si acaso»: se usa cuando la alternativa es morir dentro de la aeronave. Entender cuándo la situación justifica el salto, cómo ejecutar la secuencia de abandono y cómo gestionar el descenso y la toma marcan la diferencia entre sobrevivir y no hacerlo. Además, este capítulo cubre el mantenimiento correcto del paracaídas: un equipo descuidado es un equipo que puede no abrirse.

En este capítulo aprenderás:

- #strong[La decisión de saltar]: en qué situaciones el abandono del planeador es la única opción correcta.
- #strong[La altura mínima de abandono]: por qué 150 metros es el umbral que no puede reducirse.
- #strong[El procedimiento de salto]: la secuencia exacta de cinco pasos para abandonar la cabina.
- #strong[El descenso y la toma de tierra]: cómo aterrizar con paracaídas, con viento y ante obstáculos.
- #strong[El mantenimiento del paracaídas]: cuidados, almacenamiento y caducidad de la inspección.
]

== La decisión de abandono (#emph[bail-out])
<la-decisión-de-abandono-bail-out>
El #strong[abandono del planeador] (#strong[#link(<glosario-bail-out>)[bail-out]#index("Bail-out")]) es una decisión que se toma cuando el planeador ha dejado de ser controlable y ya no existe alternativa de aterrizaje seguro. Las situaciones que justifican el bail-out son:

- #strong[Fallo estructural:] rotura de un elemento portante ---ala, fuselaje, timón--- que hace al planeador ingobernable.
- #strong[Colisión en vuelo:] daños que impiden el vuelo controlado.
- #strong[Incendio irrefrenable:] fuego que no se extingue y hace la cabina inhabitable.
- #strong[Pérdida de control irrecuperable:] barrena (#strong[spin]) o espiral descontrolada de la que no es posible salir con los medios disponibles.

La clave psicológica del bail-out es entender que #strong[si el planeador aún vuela de forma controlada, el piloto debe quedarse dentro]. Un planeador con mandos parciales, un fallo de motor en un autolanzable o un vuelo degradado por #link(<glosario-engelamiento>)[engelamiento]#index("Engelamiento") no justifican el salto: esas situaciones se gestionan buscando el aterrizaje más próximo. El paracaídas solo es la solución cuando el planeador ya no es una solución.

=== Altura mínima de abandono
<altura-mínima-de-abandono>
Se recomienda iniciar el abandono con un mínimo de #strong[150 metros] sobre el terreno. Esta cifra no es arbitraria:

- Un paracaídas de emergencia necesita entre 50 y 90 metros para abrirse completamente desde el #link(<glosario-momento>)[momento]#index("Momento") en que se acciona la anilla.
- El proceso de abandono ---desmontar la #link(<glosario-cupula>)[cúpula]#index("Cúpula"), soltar cinturones, saltar y alejarse del planeador--- consume entre 5 y 10 segundos adicionales.
- Con 150 metros de altura disponibles y un proceso de abandono que consume los primeros 100 metros, quedan apenas 50 metros de margen de seguridad antes de tocar tierra.

Por debajo de 150 metros, el paracaídas puede no tener tiempo suficiente para abrirse completamente. Por encima de 500 metros, el salto ofrece un margen de seguridad mucho mayor.

#block[
#callout(
body: 
[
En una barrena o espiral descontrolada, las fuerzas G pueden ser muy elevadas ---hasta 3-4 G centrífugos--- y dificultar enormemente la salida de la cabina. Actúa con decisión y rapidez: cada segundo de demora es altura que se pierde. Si las fuerzas G te impiden moverte, aprovecha el instante de menor G al inicio de cada rotación para empujar la cúpula y saltar.

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
== Procedimiento de salto
<procedimiento-de-salto>
La secuencia estándar para abandonar la cabina debe practicarse en tierra hasta convertirla en un acto reflejo. Los cinco pasos son (#ref(<fig-06-cap08-secuencia-salto>, supplement: [Figura])):

+ #strong[Desmontar la cúpula:] acciona la palanca de emergencia de la cúpula (normalmente roja o amarilla) y empújala hacia fuera con fuerza. La cúpula puede resistir por la presión dinámica del aire: empuja desde el borde de salida hacia adelante, no directamente hacia arriba.
+ #strong[Soltar los arneses:] abre la hebilla central de los cinturones de seguridad. En la mayoría de los planeadores modernos, una sola palanca libera todos los arneses simultáneamente.
+ #strong[Saltar:] salta hacia el #strong[lado interior de la rotación] si el planeador gira (donde la velocidad relativa es menor), o por el lateral más despejado de obstáculos. Empuja con fuerza para alejarte del fuselaje y, especialmente, de la cola del planeador: el estabilizador horizontal puede golpearte al saltar.
+ #strong[Separación del planeador:] cuenta «#strong[mil uno, mil dos, mil tres]» para asegurarte de estar completamente separado del planeador antes de abrir el paracaídas. Si el paracaídas se abre mientras todavía estás junto al planeador, la campana puede engancharse en la estructura.
+ #strong[Apertura del paracaídas:]

- #strong[Manual:] tira con fuerza de la anilla de apertura, la #link(<glosario-zonas-p>)[D]#index("Zonas P") metálica situada normalmente a la altura del pecho en el #strong[lado izquierdo] del arnés: se tira con la mano derecha, cruzando el brazo. Localízala en tu propio equipo antes de cada vuelo. No sueltes la anilla: guárdala en la mano para que no sea un proyectil si hay otra persona cerca.
- #strong[Automático (cinta estática):] el paracaídas se abre automáticamente cuando el cable de apertura unido al planeador alcanza su extensión máxima. No es necesario tirar de nada.

#figure([
#box(image("06-procedimientos-operativos/imagenes/06-cap08-secuencia-salto.jpg"))
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
Asegúrate de estar completamente separado del planeador antes de tirar de la anilla. Si la campana se abre junto al planeador, puede engancharse en el estabilizador, el fuselaje o las superficies de control, impidiendo una apertura completa.

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
== Descenso y toma de tierra
<descenso-y-toma-de-tierra>
Una vez abierto el paracaídas, el piloto desciende a una velocidad vertical de aproximadamente 5-7 m/s ---equivalente a saltar al suelo desde una altura de 1,5 metros---. Es una toma de tierra que exige una preparación física y mental precisa para evitar lesiones.

=== Direccionamiento de la campana en el aire
<direccionamiento-de-la-campana-en-el-aire>
Muchos pilotos creen erróneamente que un paracaídas de emergencia redondo o cuadrado no ofrece ningún tipo de control. Aunque no permite un planeo controlado como una campana de salto deportivo, #strong[sí es posible girar la campana en el aire para orientarse cara al viento]:

- #strong[Técnica:] agarra con fuerza las líneas de suspensión traseras o las bandas de las hombreras (del arnés). Si tiras hacia abajo de la banda de la hombrera derecha, la campana girará hacia la derecha; si tiras de la izquierda, rotará a la izquierda.
- #strong[Aterrizar cara al viento:] utiliza esta capacidad de giro para orientarte de cara al viento dominante durante el descenso #link(<glosario-final>)[final]#index("Tramo final"). Al tomar tierra de cara al viento minimizas la velocidad horizontal sobre el suelo (#link(<glosario-deriva>)[deriva]#index("Deriva") lateral), lo que reduce drásticamente la inercia del impacto y la probabilidad de sufrir fracturas o esguinces.

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
Nunca vueles con un paracaídas cuya tarjeta de inspección esté caducada, aunque sea por un solo día. Del mismo modo, si el paracaídas ha estado expuesto a humedad intensa, a productos químicos (gasolina, aceites, disolventes) o a cualquier impacto mecánico, debe ser inspeccionado por un técnico antes de volver a usarlo. La tarjeta de inspección en vigor no es una formalidad burocrática: es la única garantía objetiva de que el equipo funciona.

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
#strong[Resumen del capítulo: paracaídas de emergencia]

- #strong[Cuándo saltar]: solo cuando el planeador es irrecuperable: fallo estructural, colisión en vuelo, fuego incontrolable o barrena irrecuperable. Si el planeador vuela de forma controlable, quédate dentro.
- #strong[Altura mínima]: 150 m #link(<glosario-agl>)[AGL]#index("AGL"). Por debajo de esta cota, el paracaídas puede no tener tiempo suficiente para abrirse del todo.
- #strong[Secuencia de salto]: (1) desprender la cúpula, (2) soltar los arneses, (3) saltar alejándote de la cola por el interior del giro, (4) contar «mil uno, mil dos, mil tres», (5) tirar de la anilla (en paracaídas manuales).
- #strong[Descenso y toma de tierra]: gira la campana en el aire tirando de las bandas de las hombreras para #strong[aterrizar cara al viento] y reducir el impacto horizontal. Adopta la posición PLF (pies y rodillas juntos y flexionados) y rueda al tocar el suelo. Con viento, tira de los cordones inferiores para colapsar la campana.
- #strong[Mantenimiento]: plegado e inspección obligatorios cada 6-12 meses según el fabricante, por un técnico certificado. Protégelo de la radiación UV, la humedad y los contaminantes químicos. Es tu último recurso: cuídalo.

]
#part[Parte 07: Planificación y Rendimiento de Vuelo]
= Masa y centro de gravedad
<masa-y-centro-de-gravedad>
#quote(block: true)[
La masa y el centrado son los cimientos de la seguridad de cada vuelo. Los números que apuntas en el hangar tienen consecuencias físicas muy concretas: de ellos depende que el planeador responda como un guante o que se convierta en una máquina imprevisible.

En este capítulo aprenderás:

- #strong[El centro de gravedad y la estabilidad]: por qué un #link(<glosario-cg>)[CG]#index("CG") atrasado puede hacer una barrena irrecuperable y qué precio pagas por un CG adelantado.
- #strong[El cálculo de masa y centrado]: la línea de referencia (#strong[#link(<glosario-datum>)[datum]#index("Datum")]), el #link(<glosario-brazo-de-palanca>)[brazo de palanca]#index("Brazo de palanca") y el #link(<glosario-momento>)[momento]#index("Momento"), con un ejemplo numérico como el del examen.
- #strong[La gestión del #link(<glosario-mtow>)[MTOW]#index("MTOW")]: qué le ocurre al planeador cuando lo sobrecargas.
- #strong[El #link(<glosario-lastre-de-agua>)[lastre de agua]#index("Lastre de agua") y el #link(<glosario-lastre-de-cola>)[lastre de cola]#index("Lastre de cola")]: cuándo te ayudan y cómo gestionarlos con seguridad.
]

== Centro de gravedad (CG) y estabilidad
<centro-de-gravedad-cg-y-estabilidad>
El centro de gravedad es el punto donde se concentra todo el peso del planeador. De su posición respecto al #link(<glosario-centro-de-presiones>)[centro de presiones]#index("Centro de Presiones") depende la estabilidad longitudinal: dónde esté el CG decide cómo responde el avión a la palanca.

=== El peligro del CG atrasado
<el-peligro-del-cg-atrasado>
Tener el CG cerca del límite posterior es la condición más crítica en un planeador. El avión se vuelve muy sensible al mando de profundidad y tiende a subir el morro por sí solo, obligándote a volar con el #link(<glosario-compensador>)[compensador]#index("Compensador") adelantado. El verdadero problema, sin embargo, aparece en la pérdida: con un CG excesivamente atrasado, el planeador puede entrar en barrena plana, o el timón de profundidad puede quedarse sin autoridad para bajar el morro y recuperar velocidad. En el peor de los casos, la barrena no se recupera.

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
#box(image("07-planificacion-rendimiento/imagenes/07-cap01-datum-momento.png"))
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

Los pesos y brazos de partida salen de la #strong[ficha de pesaje] oficial del planeador, que se actualiza tras cada pesada o reparación mayor. El procedimiento de pesado y la documentación asociada se estudian en el #strong[Libro 8 --- Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia], capítulo 4.

== Gestión de la masa: MTOW y sobrecarga
<gestión-de-la-masa-mtow-y-sobrecarga>
El peso máximo al despegue (MTOW, #emph[Maximum Take-Off Weight]) no es una sugerencia: es un límite estructural. Un planeador pesado necesita más carrera de despegue y una velocidad de remolque mayor, típicamente 10-20 km/h extra. Volará más deprisa en crucero, sí, pero su régimen de ascenso en #link(<glosario-termica>)[térmica]#index("Térmica") se resiente. Y por encima del MTOW los márgenes desaparecen: el planeador sufre más con la turbulencia fuerte y los límites de #link(<glosario-factor-de-carga>)[factor de carga]#index("Factor de carga") se alcanzan mucho antes, con el consiguiente riesgo de #link(<glosario-fatiga>)[fatiga]#index("Fatiga") o de fallo estructural.

#figure([
#box(image("07-planificacion-rendimiento/imagenes/07-cap01-limites-cg.jpg"))
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
El agua permite "engañar" a la polar, pero exige una gestión impecable. Al aumentar la #link(<glosario-carga-alar>)[carga alar]#index("Carga alar"), el planeador alcanza velocidades de crucero mucho mayores con el mismo ángulo de planeo, y eso lo convierte en el arma ideal para días de térmicas potentes. La contrapartida es que el régimen de ascenso empeora: si las térmicas bajan de 1,5 m/s, el peso extra te hunde antes de que puedas subir.

Y una obligación que no admite descuidos: tira el agua antes de aterrizar. El peso adicional en la toma puede dañar seriamente el tren de aterrizaje y el fuselaje. El vaciado tarda entre 3 y 8 minutos según el planeador, así que planifícalo antes de entrar en el #link(<glosario-circuito-de-trafico>)[circuito de tráfico]#index("Circuito de tráfico").

=== El lastre de cola: el contrapeso inteligente
<el-lastre-de-cola-el-contrapeso-inteligente>
Muchos planeadores modernos llevan un pequeño depósito de agua en la #link(<glosario-deriva>)[deriva]#index("Deriva"): el lastre de cola (#emph[fin ballast] o #emph[tail tank]). Su función no es añadir peso, sino recolocar el CG. Los tanques principales de las alas suelen quedar algo por delante del centro de gravedad, de modo que al llenarlos el CG se adelanta y aparece resistencia de compensación (#emph[trim drag]). Unos pocos litros en la cola devuelven el CG a su posición óptima, cerca del límite posterior, donde la resistencia es mínima.

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
Los dos cálculos que más caen en el examen de esta asignatura son el centrado y el planeo #link(<glosario-final>)[final]#index("Tramo final"). Aquí tienes uno de cada, resueltos paso a paso. Intenta hacerlos tú antes de leer la solución.

#strong[Ejercicio 1 --- Centrado con lastre de cola.]

Un monoplaza tiene un rango de CG permitido de +0,25 m a +0,38 m. Con las alas cargadas de agua, la hoja de centrado queda así: planeador + agua de alas = 380 kg con brazo +0,50 m; piloto + paracaídas = 80 kg con brazo −0,45 m. El manual permite añadir hasta 6 litros (6 kg) de lastre de cola con un brazo de +3,90 m. ¿Dónde queda el CG sin lastre de cola? ¿Y cuánto lo recoloca añadir los 6 litros?

#strong[Solución.] Momento del planeador con agua: 380 × (+0,50) = +190,0 kg·m. Momento del piloto: 80 × (−0,45) = −36,0 kg·m. Sin lastre de cola: masa 460 kg, momento +154,0 kg·m, CG = 154,0 / 460 = #strong[\+0,335 m] (dentro de rango, pero adelantado respecto al óptimo, cerca del posterior).

Con 6 kg en la cola: momento adicional 6 × (+3,90) = +23,4 kg·m. Masa 466 kg, momento +177,4 kg·m, CG = 177,4 / 466 = #strong[\+0,381 m]. El lastre de cola ha llevado el CG de +0,335 a +0,381 m, justo en el límite posterior, donde la resistencia de compensación es mínima. Lección: unos pocos litros muy alejados del #emph[datum] mueven el CG mucho (su brazo es enorme), y por eso hay que vaciarlos con las alas: solos, dejarían el CG fuera de rango por detrás.

#strong[Ejercicio 2 --- Planeo final con viento.]

Estás a 1.200 m sobre el terreno, a 18 km del aeródromo. Tu planeador tiene una fineza de 30 en aire en calma, pero soplan 20 km/h de viento de cara y vuelas el planeo a 100 km/h. ¿Llegas con la altura de seguridad de 300 m?

#strong[Solución.] Con viento de cara, la fineza sobre el suelo cae en proporción a tu velocidad real de avance. A 100 km/h en el aire con 20 km/h de cara, avanzas sobre el suelo a 100 − 20 = 80 km/h, así que la fineza efectiva es 30 × (80 / 100) = #strong[24]. Los 18 km de distancia exigen entonces 18 / 24 = 0,75 km = #strong[750 m] de planeo puro. Partiendo de 1.200 m, al llegar sobre el campo te quedan 1.200 − 750 = #strong[450 m], por encima de los 300 m de seguridad: #strong[llegas, con 150 m de margen.] Si el viento arreciara a 40 km/h, la fineza efectiva bajaría a 30 × (60 / 100) = 18, necesitarías 18 / 18 = 1.000 m y llegarías justo con 200 m: momento de subir una térmica más antes de comprometerte con el planeo final.

#postit[
#strong[Resumen del capítulo: masa y centro de gravedad]

- #strong[CG atrasado]: es la condición más peligrosa. El avión se vuelve inestable (quiere subir el morro solo) y la recuperación de una pérdida o barrena puede ser imposible. Si eres ligero, usa lastre fijado mecánicamente, nunca improvisado.
- #strong[CG adelantado]: el avión es muy estable (pesado de morro), pero menos eficiente por la resistencia del timón de profundidad deflectado, y con una velocidad de pérdida más alta.
- #strong[Cálculo del CG]: CG = Σ Momentos / Σ Pesos. Cada peso se multiplica por su brazo (distancia al #emph[datum]) y la suma de momentos se divide entre la masa total. Los datos de partida salen de la ficha de pesaje oficial.
- #strong[Peso máximo (MTOW)]: un planeador sobrecargado necesita más pista para despegar, tiene una velocidad de pérdida mayor y sufre más fatiga estructural con menos Gs.
- #strong[Lastre de agua]: permite volar más rápido con el mismo ángulo de planeo (ideal para días fuertes), pero empeora el régimen de ascenso en térmica. Y recuerda: el agua se tira antes de aterrizar.
- #strong[Lastre de cola]: no añade rendimiento por sí mismo; recoloca el CG cuando llenas las alas. Vacíalo siempre junto con los tanques principales: agua solo en la cola equivale a un CG atrasado extremo.

]
= Polar de velocidades (#emph[speed polar]) de planeadores o velocidad de crucero
<polar-de-velocidades-speed-polar-de-planeadores-o-velocidad-de-crucero>
#quote(block: true)[
Entender la polar de tu planeador es como conocer de memoria el mapa de potencia de un motor. En el vuelo sin motor, la gravedad es nuestro combustible y la aerodinámica nuestro acelerador. La polar te dice exactamente cuánto pagas en altura por cada kilómetro por hora de velocidad que ganas.

En este capítulo aprenderás:

- #strong[La #link(<glosario-curva-polar>)[curva polar]#index("Curva polar")]: las dos velocidades que debes saber de memoria (mínimo descenso y máximo planeo).
- #strong[La #link(<glosario-teoria-maccready>)[teoría MacCready]#index("Teoría MacCready")]: cómo ajustar tu velocidad de crucero a la fuerza del día.
- #strong[El efecto del peso]: cómo el #link(<glosario-lastre-de-agua>)[lastre de agua]#index("Lastre de agua") desplaza la polar sin cambiar el planeo máximo.
- #strong[El efecto del viento y el aire descendente]: cuándo acelerar y cuándo conservar.
- #strong[#link(<glosario-ias>)[IAS]#index("IAS") y #link(<glosario-tas>)[TAS]#index("True Air Speed") en altura]: por qué el anemómetro te "miente" en aeródromos altos y en #link(<glosario-vuelo-de-onda>)[vuelo de onda]#index("Vuelo de onda").
- #strong[El planeo #link(<glosario-final>)[final]#index("Tramo final")]: gestión de energía con margen de seguridad.
]

== La polar: tu curva de rendimiento
<la-polar-tu-curva-de-rendimiento>
La curva polar representa la tasa de descenso frente a la velocidad aire. Es el ADN de tu planeador: cada modelo tiene la suya, y de ella salen las dos velocidades que importan (#ref(<fig-07-cap02-polar-anotada>, supplement: [Figura])).

- #strong[#link(<glosario-velocidad-de-minimo-descenso>)[Velocidad de mínimo descenso]#index("Velocidad de mínimo descenso")]: el punto más alto de la curva. A esa velocidad pierdes los mínimos metros por segundo; es la ideal para aguantar en el aire mientras esperas una #link(<glosario-termica>)[térmica]#index("Térmica").
- #strong[Velocidad de máximo planeo (L/#link(<glosario-zonas-p>)[D]#index("Zonas P"))]: el punto donde la tangente desde el origen toca la curva. A esa velocidad recorres la mayor distancia posible por cada metro de altura perdido; es tu velocidad de planeo en aire en calma.

#figure([
#box(image("07-planificacion-rendimiento/imagenes/07-cap02-polar-anotada.png"))
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
¿Recuerdas el lastre de agua del capítulo anterior? Aquí está la explicación gráfica de por qué funciona. Al aumentar el peso (#link(<glosario-carga-alar>)[carga alar]#index("Carga alar")), la curva polar completa se desplaza hacia la derecha y hacia abajo, deslizándose a lo largo de la tangente desde el origen (#ref(<fig-07-cap02-polar-peso>, supplement: [Figura])). Las consecuencias son tres, y las tres caen en el examen:

- #strong[El planeo máximo (L/D) no cambia]: la tangente desde el origen toca la nueva curva con la misma pendiente. Un planeador de fineza 40 sigue teniendo fineza 40 cargado de agua.
- #strong[Ese planeo se alcanza a más velocidad]: si en vacío tu máximo planeo era a 95 km/h, con lastre puede ser a 110 km/h. Recorres los mismos kilómetros por metro de altura, pero más deprisa. Por eso el agua gana carreras en días fuertes.
- #strong[El mínimo descenso empeora]: la parte alta de la curva baja. En térmicas débiles, el planeador cargado sube peor o no sube. Es la otra cara de la moneda: el lastre es un préstamo que pagas en cada térmica floja.

#figure([
#box(image("07-planificacion-rendimiento/imagenes/07-cap02-polar-peso.png"))
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
- #strong[El anillo MacCready]: es el dial que rodea al #link(<glosario-variometro>)[variómetro]#index("Variómetro"). Ajusta el triángulo a la trepada esperada y el anillo te marca la velocidad que optimiza tu media de crucero.

== El efecto del viento y del aire descendente
<el-efecto-del-viento-y-del-aire-descendente>
La polar del manual de vuelo está trazada para aire en calma. En el mundo real, la #link(<glosario-masa-de-aire>)[masa de aire]#index("Masa de aire") se mueve, y la velocidad óptima se mueve con ella (#ref(<fig-07-cap02-polar-viento>, supplement: [Figura])).

- #strong[Viento de cara]: tu cono de alcance se encoge y necesitas penetrar. Vuela más rápido que la velocidad de máximo planeo; una regla práctica es sumarle la mitad de la velocidad del viento.
- #strong[Viento de cola]: un regalo de la naturaleza. Vuela a la velocidad de máximo planeo, o un poco menos, y deja que el viento te empuje.
- #strong[Aire descendente (hundimiento)]: acelera. Cuanto antes salgas de la zona que te hunde, menos altura total pierdes.

#figure([
#box(image("07-planificacion-rendimiento/imagenes/07-cap02-polar-viento.png"))
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

¿Por qué te importa esto en España? Porque buena parte de los aeródromos de vuelo a vela de la meseta están en #link(<glosario-torno>)[torno]#index("Torno") a los 1.000 m de elevación, y en vuelo de térmica o de onda operarás habitualmente entre 2.000 y 4.000 m:

- #strong[Las velocidades de la polar se vuelan en IAS]: el máximo planeo y el mínimo descenso ocurren a la misma IAS de siempre; no tienes que corregir nada en el anemómetro para planear bien.
- #strong[Pero recorres más terreno del que crees]: a 3.000 m, una IAS de 100 km/h son unos 120 km/h de TAS. Tu planeo final cubre más kilómetros por minuto y tu #link(<glosario-deriva>)[deriva]#index("Deriva") con viento también es mayor de lo que sugiere el instrumento.
- #strong[En la aproximación a un aeródromo alto, la sensación engaña]: con la IAS de aproximación correcta, el suelo pasa más deprisa de lo habitual y la carrera de aterrizaje será más larga. No "frenes" el avión por debajo de la velocidad indicada del manual: la pérdida ocurre a la misma IAS de siempre.

#block[
#callout(
body: 
[
Las limitaciones de velocidad de tu planeador (V#sub[NE] (Velocidad Nunca Exceder), V#sub[A] (Velocidad de Maniobra) en aire turbulento) figuran en el #strong[manual de vuelo aprobado (#link(<glosario-afm>)[AFM]#index("AFM"))] y derivan de la certificación europea #strong[#link(<glosario-cs>)[CS]#index("CS")-22] para planeadores. Atención al volar alto: el #strong[#link(<glosario-flutter>)[flutter]#index("Flutter")] depende de la TAS, por lo que la V#sub[NE] #strong[indicada] disminuye con la altitud. Esta reducción está prescrita por la norma #strong[CS 22.1505], que obliga a que dicha tabla figure como placa visible en la cabina. El AFM incluye una tabla de V#sub[NE] por altitudes ---por ejemplo, un planeador con V#sub[NE] de 250 km/h a nivel del mar puede quedar limitado a unos 200 km/h indicados a 6.000 m---. Consúltala antes de cualquier vuelo de onda.

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
#strong[Resumen del capítulo: #link(<glosario-polar-de-velocidades>)[polar de velocidades]#index("Polar de velocidades") y MacCready]

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

#mas-alla[
== Triángulo FAI y AAT: dos formas de competir
<triángulo-fai-y-aat-dos-formas-de-competir>
#mas-alla-tag[#strong[↗ MÁS ALLÁ DEL EXAMEN.]] Los tipos de tarea de competición (triángulo FAI, AAT) y la estrategia de regata no deberían ser materia de examen. Se incluyen porque son el paso natural del vuelo de distancia; léelos como iniciación.

Según el tipo de tarea, tu estrategia mental cambia por completo (#ref(<fig-07-cap03-fai-vs-aat>, supplement: [Figura])).

- #strong[Triángulo FAI]: los puntos de viraje son fijos y precisos. La navegación es rígida: pasas por el vértice o la tarea no vale.
- #strong[Tarea de área asignada (AAT)]: alrededor de cada punto hay un sector circular grande, y tú decides dónde virar dentro de él. Si el día está mejor de lo previsto, vete al fondo del área para sumar distancia; si se está cerrando, toca el borde más cercano y vuelve a casa antes de que se agote la #link(<glosario-termica>)[térmica]#index("Térmica").

#figure([
#box(image("07-planificacion-rendimiento/imagenes/07-cap03-fai-vs-aat.png"))
], caption: figure.caption(
position: bottom, 
[
Triángulo FAI con vértices fijos frente a tarea AAT con áreas asignadas
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap03-fai-vs-aat>


]
== Meteorología: tu motor invisible
<meteorología-tu-motor-invisible>
Antes de despegar debes conocer el ciclo de vida del cielo de ese día.

- #strong[La ventana de convección] (#ref(<fig-07-cap03-ventana-conveccion>, supplement: [Figura])): identifica la hora de disparo de las primeras térmicas (el #strong[trigger]) y la hora a la que muere la convección. Planifica el paso por las zonas difíciles (sombras, montañas) durante las horas de máxima insolación.
- #strong[Sondeo y #link(<glosario-base>)[base]#index("Tramo de base") de nube]: la altura de la inversión y la base de nube definen tu espacio de trabajo. Cuanto mayor sea el margen entre la base y el suelo, más segura será tu progresión.

#figure([
#box(image("07-planificacion-rendimiento/imagenes/07-cap03-ventana-conveccion.png"))
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
Recuerda siempre verificar los #link(<glosario-notam>)[NOTAM]#index("NOTAM") y los espacios aéreos controlados en tu ruta. Una tarea que cruce un #link(<glosario-tma>)[TMA]#index("TMA") sin autorización es una tarea fallida, independientemente de la distancia recorrida.

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
El Reglamento (UE) 2018/1976 (#strong[#link(<glosario-part-sao>)[Part-SAO]#index("Part-SAO")]), que regula las operaciones de planeadores en Europa, establece en #strong[#link(<glosario-sao>)[SAO]#index("SAO")​.IDE.125] que los planeadores que operen sobre zonas donde la búsqueda y el salvamento serían especialmente difíciles deben llevar el equipo de salvamento y señalización adecuado al área sobrevolada. Su AMC1 concreta el mínimo: un #strong[#link(<glosario-elt>)[ELT]#index("ELT")], una #strong[baliza personal de localización (#link(<glosario-plb>)[PLB]#index("PLB"))] o localizador equivalente registrado, equipo para hacer señales de socorro y el equipo de supervivencia apropiado a la ruta. Para vuelos sobre agua aplica además #strong[SAO.IDE.120]: el #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando") debe valorar antes del vuelo los riesgos de supervivencia en caso de #link(<glosario-amerizaje>)[amerizaje]#index("Amerizaje").

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
- #strong[#link(<glosario-altura-de-decision>)[Altura de decisión]#index("Altura de decisión")]: fija un punto en el que dejas de buscar la siguiente térmica y te concentras solo en elegir un campo para aterrizar. No esperes a estar a 100 metros para mirar dónde. Los criterios para elegir y evaluar el campo desde el aire ---la regla de las #strong[7 S]--- los tienes desarrollados en el #strong[Libro 6 --- Procedimientos operativos], capítulo 5; repásalos antes de cada travesía.

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
#strong[Resumen del capítulo: planificación de tareas]

- #strong[Velocidad media]: no gana el que corre más, sino el que para menos. Evita virar térmicas flojas; la clave está en la consistencia y en elegir la ruta bajo las calles de nubes.
- #strong[Meteorología]: estudia el sondeo antes de despegar. ¿A qué hora empieza la convección? ¿Cuándo muere? Planifica la ventana de vuelo para cruzar lo difícil en las horas centrales.
- #strong[Orografía]: la ruta más corta sobre el mapa rara vez es la más rápida sobre el terreno. Evita los valles ciegos, marca puntos de escape en cada tramo y traza la tarea a lo largo de convergencias y ondas, no perpendicular a ellas.
- #strong[Equipo de supervivencia]: sobre zonas donde el rescate sería difícil, el Part-SAO (SAO.IDE.125) exige ELT o PLB, equipo de señales y supervivencia adecuados a la ruta. Agua, abrigo y baliza: menos de dos kilos que pueden salvarte la vida.
- #strong[Mínimos personales]: fíjalos antes de salir. ¿Altura mínima para seguir en ruta? ¿Térmica mínima aceptable? Si bajas de ahí, cambia el chip de competición a supervivencia.

]
= Plan de vuelo ICAO (#emph[ATS flight plan])
<plan-de-vuelo-icao-ats-flight-plan>
#quote(block: true)[
El plan de vuelo (#link(<glosario-fpl>)[FPL]#index("FPL")) es mucho más que un trámite administrativo: es tu seguro de vida en los vuelos de distancia. En vuelo local no suele hacer falta, pero en cuanto decides alejarte del cono de seguridad de tu aeródromo se convierte en la única forma de que los servicios de búsqueda y rescate (#link(<glosario-sar>)[SAR]#index("SAR")) sepan dónde buscarte si no regresas.

En este capítulo aprenderás:

- #strong[Cuándo es obligatorio el FPL] según #link(<glosario-sera>)[SERA]#index("SERA")​.4001 y su aplicación en España.
- #strong[Las casillas clave del formulario #link(<glosario-oaci>)[ICAO]#index("OACI")] para un planeador, incluida la información suplementaria (casilla 19).
- #strong[Cómo abrir un plan de vuelo en el aire (#link(<glosario-afil>)[AFIL]#index("AFIL"))] con los centros de información de vuelo españoles.
- #strong[Las particularidades de los motoveleros (#link(<glosario-tmg>)[TMG]#index("TMG"))] y la autonomía de combustible.
- #strong[El cierre del plan]: el paso que nunca, jamás, puedes olvidar.
]

== ¿Cuándo es obligatorio?
<cuándo-es-obligatorio>
Según el reglamento #strong[SERA.4001] (SERA (Standardised European Rules of the Air)) y su aplicación en España, un planeador necesita plan de vuelo en estos casos:

- #strong[Vuelos transfronterizos]: siempre que cruces una frontera internacional.
- #strong[Servicio de control]: el plan de vuelo es obligatorio para todo vuelo al que se preste servicio de control de tránsito aéreo ---en la práctica, #strong[clases B, C y #link(<glosario-zonas-p>)[D]#index("Zonas P")]--- y cuando el origen o el destino sea un #strong[aeródromo controlado]. Atención al matiz de la clase E: es espacio controlado, pero al #link(<glosario-vfr>)[VFR]#index("VFR") no se le presta allí servicio de control, así que no necesita plan de vuelo, ni radio, ni autorización (SERA.4001 b)).
- #strong[Cuando lo requiera la autoridad #link(<glosario-ats>)[ATS]#index("ATS")]: en zonas o rutas designadas, para facilitar los servicios de información, alerta y SAR o la coordinación con unidades militares.
- #strong[Vuelo VFR nocturno]: si el vuelo va a salir de las inmediaciones del aeródromo (caso excepcional en planeador, pero es pregunta de examen).
- #strong[Sobre el mar]: en España, para vuelos que se alejen más de 12 millas náuticas de la costa (supuesto nacional; consulta el valor vigente en el #link(<glosario-aip>)[AIP]#index("AIP")-España, ENR 1.10).
- #strong[Vuelo de distancia]: no es obligatorio en espacio G (no controlado), pero sí muy recomendable: es lo que activa los servicios de alerta si no apareces.

#block[
#callout(
body: 
[
Los plazos de presentación (AIP-España, ENR 1.10) dependen de qué pidas y desde dónde salgas. Si solicitas #strong[servicio de control de tránsito aéreo], presenta el FPL al menos #strong[60 minutos antes] de la hora estimada de fuera de calzos (#link(<glosario-eobt>)[EOBT]#index("EOBT")); desde un aeródromo controlado que no opere H24, el mínimo se reduce a #strong[30 minutos]. Si despegas de un #strong[aeródromo no controlado] y solo solicitas servicio de información y alerta, basta con presentarlo #strong[antes de la salida]. En vuelo (#strong[AFIL]), debe transmitirse con antelación suficiente para que la dependencia ATS lo reciba antes de entrar en #link(<glosario-espacio-aereo-controlado>)[espacio aéreo controlado]#index("Espacio aéreo controlado").

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
- #strong[Casilla 19 (información suplementaria)]: no se transmite con el mensaje FPL, pero es la información que usará el SAR si no apareces: autonomía (#NormalTok("E/");, en planeador, las horas hasta la puesta de sol), personas a bordo (#NormalTok("P/");), equipo de radio de emergencia (#NormalTok("R/");), equipo de supervivencia (#NormalTok("S/");) y si llevas #strong[#link(<glosario-elt>)[ELT]#index("ELT")] o baliza personal (#link(<glosario-plb>)[PLB]#index("PLB")). Rellénala con el mismo cuidado que el resto: puede acortar tu rescate en horas.

#figure([
#box(image("07-planificacion-rendimiento/imagenes/07-cap04-fpl-casillas.png"))
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

+ Sintoniza el #strong[Centro de Información de Vuelo (#link(<glosario-fic>)[FIC]#index("FIC"))] de tu región: en España, #strong[Madrid Información], #strong[Barcelona Información] o #strong[Canarias Información] (consulta la frecuencia del sector en el AIP de ENAIRE o en la carta de navegación; varía según la zona).
+ En el primer contacto, indica: identificación, tipo de aeronave (GLID), posición y altitud, intenciones (ruta y destino) y la petición expresa de #strong[abrir plan de vuelo en el aire].
+ Ten preparados los datos del formulario antes de transmitir: el operador te pedirá esencialmente las mismas casillas que en tierra (velocidad, ruta, destino, autonomía y personas a bordo).
+ Recuerda el plazo: el AFIL debe transmitirse #strong[con antelación suficiente] para que la dependencia lo reciba antes de que entres en espacio aéreo controlado.

#block[
#callout(
body: 
[
El FIC no es solo para abrir planes de vuelo. En travesía por zonas como el Sistema Central, mantener escucha con Madrid Información te da tráfico esencial, #link(<glosario-notam>)[NOTAM]#index("NOTAM") de última hora y un canal ya abierto si las cosas se tuercen. Apunta las frecuencias de los sectores de tu ruta en la planificación, junto a los puntos de escape.

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
#strong[Resumen del capítulo: plan de vuelo ICAO]

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
- #strong[El cálculo mental en cabina]: reglas rápidas de alcance y de #link(<glosario-deriva>)[deriva]#index("Deriva") sin depender del #link(<glosario-gps>)[GPS]#index("GPS").
- #strong[El monitoreo del planeo #link(<glosario-final>)[final]#index("Tramo final") en 3 puntos]: cómo detectar una descendencia continua antes de que sea tarde.
- #strong[El punto de no retorno (PNR)] y el cambio de mentalidad que implica cruzarlo.
- #strong[El factor humano]: cómo la #link(<glosario-hipoxia>)[hipoxia]#index("Hipoxia") y la deshidratación degradan justo las capacidades que la replanificación necesita.
]

== El cono de alcance: tu burbuja de seguridad
<el-cono-de-alcance-tu-burbuja-de-seguridad>
Imagina que de tu planeador baja un cono invertido hasta el suelo. Todo lo que quede dentro de ese círculo es terreno alcanzable si no encuentras ni una #link(<glosario-termica>)[térmica]#index("Térmica") más (#ref(<fig-07-cap05-cono-alcance>, supplement: [Figura])).

- #strong[La forma del cono]: en aire en calma es un círculo perfecto. Con viento de cara fuerte se deforma en una elipse que se encoge por delante y se estira por detrás.
- #strong[El horizonte de decisión]: no esperes a que tu destino esté en el borde del cono. Si el objetivo queda fuera de tu alcance visual o instrumental, toca replanificar.

#figure([
#box(image("07-planificacion-rendimiento/imagenes/07-cap05-cono-alcance.png"))
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
Calcular el planeo final una sola vez y volarlo a fe ciega es apostar la tarea ---y el planeador--- a que la #link(<glosario-masa-de-aire>)[masa de aire]#index("Masa de aire") no cambie. El método profesional verifica el margen en tres puntos (#ref(<fig-07-cap05-planeo-3-puntos>, supplement: [Figura])):

+ #strong[Al iniciar el planeo final]: anota tu altura de llegada prevista (por ejemplo, llegada calculada con +300 m sobre el campo).
+ #strong[En el punto medio del tramo]: recalcula. Si el margen se mantiene en #link(<glosario-torno>)[torno]#index("Torno") a +300 m, la masa de aire se comporta como esperabas. Si ha bajado a +150 m y sigue cayendo, estás atravesando descendencia o más viento de cara del previsto. Acelera la decisión, no el planeador: busca ya tu alternativa.
+ #strong[A unos 5 km del destino]: última verificación con margen real para incorporarte al circuito. A esta distancia el resultado ya no es una estimación: es una realidad.

La fuerza del método está en la tendencia: una lectura te dice dónde estás; dos lecturas comparadas te dicen hacia dónde vas. Una descendencia continua de 0,5 m/s se pierde entre el ruido del #link(<glosario-variometro>)[variómetro]#index("Variómetro"), pero salta a la vista al comparar el margen del punto inicial con el del punto medio.

#figure([
#box(image("07-planificacion-rendimiento/imagenes/07-cap05-planeo-3-puntos.png"))
], caption: figure.caption(
position: bottom, 
[
Monitoreo del planeo final en 3 puntos: la tendencia delata el problema
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-07-cap05-planeo-3-puntos>


- #strong[Caja de seguridad]: durante todo el planeo final, mantén al menos un aeródromo alternativo o un campo conocido dentro del cono de alcance con una llegada mínima de 300 m #link(<glosario-agl>)[AGL]#index("AGL"). El día que el margen del punto medio se desplome, agradecerás tener la alternativa ya elegida.

== Punto de no retorno (PNR)
<punto-de-no-retorno-pnr>
El PNR es el #link(<glosario-momento>)[momento]#index("Momento") del vuelo en el que ya no tienes altura para volver al aeródromo de salida ni a la última zona segura que dejaste atrás.

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

- #strong[La regla del circuito]: fija una altura (300 m, por ejemplo) en la que, si no has encontrado térmica, abandonas la búsqueda y te incorporas al #link(<glosario-circuito-de-trafico>)[circuito de tráfico]#index("Circuito de tráfico") del aeródromo o campo elegido.
- #strong[Replanifica a tiempo]: si la ruta planificada está bloqueada por sombras, lluvia o espacio aéreo, no esperes a estar bajo para decidir. Desvíate pronto: es mejor hacer 10 km de más con altura que 5 km directos contra el suelo.

== El factor humano: tu calculadora también se degrada
<el-factor-humano-tu-calculadora-también-se-degrada>
Todo lo anterior ---reglas mentales, método de los 3 puntos, decisión del PNR--- depende de un único instrumento: tu cerebro. Y ese instrumento pierde precisión justo cuando más lo necesitas:

- #strong[Hipoxia]: en vuelos de onda por encima de 3.000 m sin oxígeno suplementario, la capacidad de cálculo mental y el juicio se degradan de forma traicionera: el primer síntoma es, precisamente, no notar los síntomas. Un planeo final calculado con hipoxia incipiente es un planeo final mal calculado.
- #strong[Deshidratación y #link(<glosario-fatiga>)[fatiga]#index("Fatiga")]: tras 4 o 5 horas de tarea bajo la cubierta, la deshidratación enlentece las decisiones y favorece la fijación: seguir hacia el objetivo "porque era el plan" en lugar de replanificar. La demora en aceptar una toma fuera de campo es exactamente el error que este capítulo intenta evitar.

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
#strong[Resumen del capítulo: monitoreo y replanificación]

- #strong[Cono de alcance]: visualiza el cono bajo el planeador; lo que queda fuera es inalcanzable. Ten siempre una opción de aterrizaje segura dentro del cono.
- #strong[Cálculo mental]: 1 km de altura da 20-30 km de alcance, según el viento y el avión; con viento de cara fuerte, divide por dos. Para la deriva: a 100 km/h, cada 10 km/h de viento cruzado pide unos 6° de corrección.
- #strong[Planeo final en 3 puntos]: verifica el margen de llegada al inicio, en el punto medio y a 5 km del destino. La tendencia entre lecturas delata a tiempo la descendencia continua o el viento imprevisto.
- #strong[Punto de no retorno]: llega un momento en que ya no vuelves a casa. Tenlo identificado. A partir de ahí, tu objetivo es el siguiente aeródromo o campo seguro.
- #strong[Factor humano]: hipoxia, deshidratación y fatiga degradan el cálculo mental y retrasan la decisión de aterrizar fuera. Bebe de forma programada, usa oxígeno en vuelos altos y añade margen cuando lleves horas de tarea (detalles en el #strong[Libro 2 --- Factores humanos], capítulo 4).
- #strong[Altura de seguridad (#emph[safety height])]: fija un margen intocable para llegar al campo (300 m, por ejemplo). Esa altura es para el circuito, no para planear. Si el calculador dice que llegas con 0 m, no llegas.

]
#part[Parte 08: Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia]
= Estructura (#emph[airframe])
<estructura-airframe>
#quote(block: true)[
La estructura del planeador es lo primero que inspeccionas cada mañana y lo último que debe fallarte en vuelo. Saber de qué está hecho tu velero y cómo se comporta cada material ante el sol, la humedad o un golpe es la #link(<glosario-base>)[base]#index("Tramo de base") de toda la inspección prevuelo.

En este capítulo aprenderás:

- #strong[Los materiales de construcción]: #link(<glosario-composite>)[composite]#index("Composite") (fibra de vidrio y carbono), madera y tela, y metal, con los puntos débiles de cada uno.
- #strong[El #link(<glosario-gelcoat>)[gelcoat]#index("Gelcoat") y el #link(<glosario-poliuretano>)[poliuretano]#index("Poliuretano")]: por qué los planeadores son blancos, cómo cuidar su "piel" y por qué la pintura de PU va sustituyendo al gelcoat.
- #strong[El #link(<glosario-larguero>)[larguero]#index("Larguero") y la #link(<glosario-estructura-sandwich>)[estructura sándwich]#index("Estructura sándwich")]: dónde reside la resistencia del ala y por qué un golpe pequeño puede esconder una delaminación.
- #strong[La #link(<glosario-cupula>)[cúpula]#index("Cúpula") (canopy)]: cierre, ventilación y suelta de emergencia.
- #strong[El #link(<glosario-gancho-de-remolque>)[gancho de remolque]#index("Gancho de remolque")]: gancho de morro, gancho de #link(<glosario-cg>)[CG]#index("CG") y el mecanismo de suelta automática.
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
#box(image("08-aeronave-sistemas/imagenes/08-cap01-estructura-ala.jpg"))
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
El gancho de suelta (#emph[release hook]) es el punto donde el planeador se une al cable del #link(<glosario-torno>)[torno]#index("Torno") o a la cuerda de remolque. Casi todos montan ganchos de la marca Tost, y hay dos ubicaciones con funciones distintas:

- #strong[Gancho de morro] (#emph[nose hook]): en la proa, pensado para el remolque por avión. Como la tracción va alineada con el eje longitudinal, resulta más fácil mantener la posición tras el remolcador.
- #strong[Gancho de CG] (#emph[CG hook]): bajo el fuselaje, cerca del centro de gravedad, es el adecuado para el lanzamiento por torno. Permite rotar a la actitud de subida pronunciada sin que el cable tire del morro hacia abajo.

El gancho de CG incorpora una suelta automática (#emph[back-release]): si el cable tira hacia atrás y abajo, como ocurre al sobrevolar el torno al #link(<glosario-final>)[final]#index("Tramo final") del lanzamiento, el gancho libera el cable por sí solo aunque el piloto no accione la suelta.

Muchos planeadores de escuela montan los dos ganchos, y la regla es sencilla: morro para avión, CG para torno. La autoridad sobre qué gancho corresponde a cada método de lanzamiento es siempre el manual de vuelo (#link(<glosario-afm>)[AFM]#index("AFM")). Usar el de CG para remolque por avión está permitido en algunos modelos, pero exige más atención: la tendencia a encabritarse es mayor y una posición alta respecto al remolcador puede acabar provocando una suelta automática involuntaria.

#block[
#callout(
body: 
[
No te lances nunca en torno con el gancho de morro. Al quedar el enganche por delante del centro de gravedad, el cable tira del morro hacia el suelo en lugar de dejar rotar el planeador a la subida; para contrarrestarlo tendrías que tirar a fondo de profundidad, y eso sobrecarga el estabilizador horizontal y el timón en una fase de cargas ya muy altas. A esto se suma que el gancho de morro no da la suelta automática (#strong[back-release]) del de CG, así que un #link(<glosario-fallo-de-suelta>)[fallo de suelta]#index("Fallo de suelta") es mucho más peligroso. Por estas razones, en los tipos así certificados el AFM prohíbe de forma expresa el lanzamiento por torno con el gancho de morro.

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

- #strong[El #link(<glosario-factor-de-carga>)[factor de carga]#index("Factor de carga") (n)]: qué significa "tirar de g" y cómo lo provocan los virajes y las recogidas.
- #strong[Las categorías de diseño] Utilitaria y Acrobática según #link(<glosario-cs>)[CS]#index("CS")-22 y sus límites en g.
- #strong[#link(<glosario-carga-limite>)[Carga límite]#index("Carga límite") y #link(<glosario-carga-de-rotura>)[carga de rotura]#index("Carga de rotura")]: qué protege el factor de seguridad de 1,5 y qué no.
- #strong[La #link(<glosario-fatiga>)[fatiga]#index("Fatiga") estructural] de los composites y sus inspecciones de vida útil.
- #strong[El flameo (#link(<glosario-flutter>)[flutter]#index("Flutter"))]: la vibración que puede desintegrar un planeador en segundos.
]

Un planeador no solo tiene que ser aerodinámicamente eficiente; también tiene que aguantar las fuerzas de la atmósfera y las maniobras del piloto. Ese diseño estructural se rige por normas estrictas (como la #link(<glosario-cs-22>)[CS-22]#index("CS-22") de #link(<glosario-easa>)[EASA]#index("EASA") (European Union Aviation Safety Agency)), que fijan cuánta carga debe soportar la aeronave antes de sufrir daños.

== El factor de carga (n)
<el-factor-de-carga-n-1>
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

- #strong[Categoría Utilitaria (U)]: para el vuelo normal, #link(<glosario-termica>)[térmica]#index("Térmica") y navegación. Certificada para soportar +5,3g y -2,65g a la velocidad de maniobra. Esos límites se estrechan al aumentar la velocidad hasta +4,0g y -1,5g a la velocidad de picado (V#sub[#link(<glosario-zonas-p>)[D]#index("Zonas P")]); la envolvente completa (el #link(<glosario-diagrama-v-n>)[diagrama V-n]#index("Diagrama V-n")) se detalla en el #strong[Libro 5 --- Principios de vuelo], capítulo 5.
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
#box(image("08-aeronave-sistemas/imagenes/08-cap02-diagrama-vn.jpg"))
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
- #strong[#link(<glosario-tren-retractil>)[Tren retráctil]#index("Tren retráctil")]: el estándar en veleros de rendimiento. Esconder la rueda dentro del fuselaje elimina una buena parte de la resistencia aerodinámica. El mecanismo suele ser manual, con una palanca en el lado derecho de la cabina.

#block[
#callout(
body: 
[
Trata la gestión del tren retráctil como algo sagrado: se guarda solo tras soltar el remolque y alcanzar una altura segura, y se vuelve a sacar al entrar en el tramo de #link(<glosario-viento-en-cola>)[viento en cola]#index("Viento en cola") (#emph[downwind]), sin excepción. Que forme parte de tu chequeo mental antes de aterrizar.

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
- #strong[Accionamiento]: en la mayoría de los planeadores el freno entra al llevar la palanca de #link(<glosario-aerofrenos>)[aerofrenos]#index("Aerofrenos") hasta el #link(<glosario-final>)[final]#index("Tramo final") de su recorrido. En otros está en los pedales o en una maneta independiente.

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

¿Y si el tren no sale? Si el mando está agarrotado, a veces un tirón suave (un picado y una recogida) ayuda a que la gravedad fuerce la extensión. Y si al final tienes que aterrizar con el tren dentro, hazlo sobre hierba: los daños suelen quedarse en raspones del #link(<glosario-gelcoat>)[gelcoat]#index("Gelcoat") del fuselaje, sin comprometer la seguridad del piloto.

#figure([
#box(image("08-aeronave-sistemas/imagenes/08-cap03-mecanismo-tren.jpg"))
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
<masa-y-centro-de-gravedad-1>
#quote(block: true)[
El planeador que despega sobrecargado o mal centrado ya lleva el accidente a bordo. Este capítulo trata la masa y el centrado desde el punto de vista de los sistemas del avión: dónde va el lastre, qué dice la placa de limitaciones y cuándo hay que volver a pesar la aeronave.

En este capítulo aprenderás:

- #strong[La masa máxima al despegue (#link(<glosario-mtow>)[MTOW]#index("MTOW"))] y la diferencia con la masa máxima sin agua.
- #strong[Los límites del centro de gravedad]: qué ocurre con un #link(<glosario-cg>)[CG]#index("CG") demasiado adelantado o, peor, demasiado retrasado.
- #strong[La gestión del lastre]: plomos de morro, depósito de cola y los límites del maletero.
- #strong[El pesaje de la aeronave]: cuándo se repite y dónde se documenta.
]

Volar dentro de los límites de peso y equilibrio no es opcional: es un requisito legal y de seguridad. En un coche, la carga solo afecta al consumo. En un planeador decide si la aeronave es estable y controlable o si se convierte en una trampa el día que entres en pérdida.

== Masa y peso máximo
<masa-y-peso-máximo>
Cada planeador tiene definida una #strong[masa máxima al despegue] (#emph[MTOW, Maximum Take-Off Weight]). Superarla somete a la estructura a esfuerzos para los que no se diseñó, recorta el margen de seguridad en maniobra y empeora el ascenso.

Conviene distinguir la masa máxima total de la masa máxima sin agua: el agua va en las alas y no castiga la unión de la raíz del ala con el fuselaje igual que lo hace el peso en la cabina. En la documentación de certificación #link(<glosario-cs>)[CS]#index("CS")-22, este concepto aparece como #strong[masa máxima de las partes que no sustentan] (#emph[Maximum weight of non-lifting parts]).

== El centro de gravedad (CG)
<el-centro-de-gravedad-cg>
El #strong[centro de gravedad] es el punto donde se concentra, en teoría, todo el peso de la aeronave. Para que el planeador sea estable, ese punto tiene que caer dentro de un rango muy estrecho fijado por el fabricante.

- #strong[Límite delantero]: con el CG muy adelantado (piloto pesado o mucho lastre en el morro), el planeador es muy estable pero "pesado" de mandos. En la toma puede faltarte profundidad para hacer la recogida y acabas golpeando con la rueda de morro.
- #strong[Límite trasero]: es el peligroso. Un CG retrasado (piloto ligero sin lastre) vuelve inestable al planeador. Si entras en pérdida, el morro tiende a subir solo y puede meterte en una barrena (#strong[spin]) irrecuperable.

#block[
#callout(
body: 
[
La certificación #link(<glosario-cs-22>)[CS-22]#index("CS-22") exige una placa de limitaciones visible en cabina con las cargas mínima y máxima del asiento. Comprueba siempre el peso mínimo en cabina: si el tuyo (con paracaídas y ropa) queda por debajo de ese mínimo, es obligatorio instalar lastre antes de despegar, según indique el Manual de Vuelo.

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
Muchos planeadores modernos tienen compartimentos en el morro para alojar pesas de plomo. Algunos modelos de competición llevan incluso tanques de agua en la #link(<glosario-deriva>)[deriva]#index("Deriva") (en la cola) para contrarrestar el agua de las alas y mantener el CG en su punto óptimo de rendimiento.

El maletero, normalmente detrás del piloto, tiene límites de carga muy estrictos (a menudo menos de 10-15 kg). Cualquier objeto pesado ahí tiene un #link(<glosario-brazo-de-palanca>)[brazo de palanca]#index("Brazo de palanca") grande y retrasa bastante el CG.

== Pesaje y documentación
<pesaje-y-documentación>
Con el tiempo, las reparaciones, la pintura o los cambios de instrumentos alteran el peso en vacío del planeador. Determinar ese peso en vacío y su CG mediante pesaje es un requisito de certificación (CS 22.29). El procedimiento y la periodicidad del repesaje los fija el manual de mantenimiento del fabricante y el programa de mantenimiento de la aeronave: no hay un plazo universal, aunque muchos programas lo exigen tras reparaciones estructurales, repintados o cambios de equipo. Los datos del último pesaje quedan en el Certificado de Pesaje, dentro de la documentación de la aeronave.

#figure([
#box(image("08-aeronave-sistemas/imagenes/08-cap04-calculo-cg.jpg"))
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
El cálculo numérico de masa y centrado (#link(<glosario-datum>)[datum]#index("Datum"), brazos y momentos) se desarrolla con un ejemplo completo de examen en el #strong[Libro 7 --- Planificación y Rendimiento de Vuelo], capítulo 1. Aquí nos interesa la parte física: dónde está cada lastre y qué sistemas lo gestionan.

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
- #strong[#link(<glosario-lastre-de-cola>)[Lastre de cola]#index("Lastre de cola")]: depósito de agua o pesas en la deriva para ajustar el CG óptimo. Cuidado: olvidar vaciarlo con un piloto ligero delante es una emergencia grave (CG peligrosamente atrasado).
- #strong[Pesaje]: tras reparaciones, repintado o cambios de equipo, según el manual de mantenimiento. El resultado vive en el Certificado de Pesaje.

]
= Mandos de vuelo
<mandos-de-vuelo>
#quote(block: true)[
Entre tu mano y el alerón hay varios metros de varillas, rótulas y cables. Conocer ese recorrido es lo que te permite detectar en tierra la holgura, el roce o el mando invertido que en vuelo ya no tendría remedio.

En este capítulo aprenderás:

- #strong[Los mandos primarios]: alerones, profundidad y dirección, y cómo se transmiten (varillas y cables).
- #strong[Los #link(<glosario-aerofrenos>)[aerofrenos]#index("Aerofrenos")]: el mando azul y su efecto sobre la senda de planeo.
- #strong[Los #link(<glosario-flaps>)[flaps]#index("Flaps")]: posiciones positivas y negativas en veleros de rendimiento.
- #strong[El #link(<glosario-compensador>)[compensador]#index("Compensador") (trim)]: de muelles o de pestaña, y por qué es tu mejor aliado.
- #strong[La comprobación de libertad y sentido de mandos] antes de cada despegue.
]

Un planeador se pilota con la punta de los dedos. Esa precisión de los mandos es lo que te deja centrar una #link(<glosario-termica>)[térmica]#index("Térmica") estrecha o clavar una aproximación. Y entender cómo viaja tu movimiento desde la cabina hasta las superficies de control es lo que te permite cazar cualquier anomalía antes de despegar.

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
<el-compensador-trim-1>
El mando verde, o el pulsador eléctrico que libera la carga de la palanca, es tu mejor aliado. El compensador no "vuela" el avión: alivia la presión que tendrías que hacer sobre el elevador para mantener una velocidad dada.

- #strong[Trim de muelles]: el más común; unos resortes "sujetan" la palanca en la posición deseada.
- #strong[Trim de pestaña]: una pequeña superficie en el borde de salida del elevador que se mueve en sentido contrario.

#block[
#callout(
body: 
[
Los mandos de cabina siguen un código de colores casi universal que conviene reconocer al instante: #strong[azul] para los aerofrenos, #strong[verde] para el compensador, #strong[amarillo] para la suelta del cable de remolque y #strong[rojo] para las palancas de emergencia (suelta de #link(<glosario-cupula>)[cúpula]#index("Cúpula"), aperturas). Localízalos en cada planeador antes de volar.

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
#box(image("08-aeronave-sistemas/imagenes/08-cap05-sistema-mandos.jpg"))
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

- #strong[El #link(<glosario-sistema-pitot-estatica>)[sistema pitot-estática]#index("Sistema pitot-estática")]: las tomas de presión que alimentan los instrumentos básicos.
- #strong[El trío básico]: anemómetro (y sus arcos de colores), altímetro y #link(<glosario-variometro>)[variómetro]#index("Variómetro").
- #strong[El equipamiento mínimo exigido]: qué instrumentos obliga a llevar la norma según el tipo de vuelo.
- #strong[El variómetro de #link(<glosario-energia-total>)[energía total]#index("Energía total")]: por qué ignora los "palancazos" y solo marca el aire que sube.
- #strong[La aviónica de seguridad]: radio #link(<glosario-vhf>)[VHF]#index("VHF"), #link(<glosario-transpondedor>)[transpondedor]#index("Transpondedor") y #link(<glosario-flarm>)[FLARM]#index("FLARM").
]

Los instrumentos son los "sentidos" del piloto. Buena parte del vuelo sin motor se basa en la percepción (el ruido del aire, la posición del morro, la presión en el asiento), pero los instrumentos aportan la precisión que hace falta para exprimir el rendimiento y volar seguro.

== Tomas de presión: pitot y estáticas
<tomas-de-presión-pitot-y-estáticas>
Casi todos los instrumentos básicos funcionan midiendo presiones de aire:

- #strong[Toma pitot]: normalmente en el morro o en el borde de ataque de la #link(<glosario-deriva>)[deriva]#index("Deriva"). Mide la presión total (estática más dinámica) que produce el movimiento.
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
+ #strong[Anemómetro (velocímetro)]: muestra la velocidad indicada (#emph[#link(<glosario-ias>)[IAS]#index("IAS")]). Es el instrumento más importante para la seguridad; si falla, guíate por el ruido del aire y la actitud del morro.
+ #strong[Altímetro]: funciona como un barómetro calibrado en pies o metros. Indica la altura sobre una referencia (#link(<glosario-qnh>)[QNH]#index("QNH") o #link(<glosario-qfe>)[QFE]#index("QFE")).
+ #strong[Variómetro]: indica la velocidad vertical. En un planeador es vital para saber si estás en aire que sube (#link(<glosario-termica>)[térmica]#index("Térmica")) o que baja.

=== Los arcos de colores del anemómetro
<los-arcos-de-colores-del-anemómetro>
La esfera del anemómetro lleva marcas de color que resumen las limitaciones de velocidad del planeador:

- #strong[Arco verde]: rango de operación normal, desde 1,1 veces la velocidad de pérdida hasta la #strong[V#sub[RA]], la velocidad máxima en aire turbulento (#link(<glosario-cs>)[CS]#index("CS") 22.1545). No la confundas con la velocidad de maniobra (V#sub[A]): esa es un límite estructural que no se marca en la esfera (se estudia en el #strong[Libro 5 --- Principios de vuelo], capítulo 5).
- #strong[Arco amarillo]: rango de precaución, de la V#sub[RA] a la V#sub[NE]. Solo con aire en calma y movimientos de mando suaves.
- #strong[Línea roja radial]: la V#sub[NE] (Velocidad Nunca Exceder). Es un límite absoluto, nunca un objetivo.
- #strong[Triángulo amarillo]: en muchos veleros marca la velocidad de aproximación recomendada con masa máxima sin lastre.

Estas marcas se complementan con las velocidades de remolque y #link(<glosario-torno>)[torno]#index("Torno") indicadas en la placa de limitaciones y en el Manual de Vuelo. Y ojo en #link(<glosario-vuelo-de-onda>)[vuelo de onda]#index("Vuelo de onda") a gran altitud: la V#sub[NE] #strong[indicada] disminuye; el porqué se explica en el #strong[Libro 5 --- Principios de Vuelo], capítulo 5.

== Instrumentos exigidos por la normativa
<instrumentos-exigidos-por-la-normativa>
No todos los instrumentos del panel son obligatorios. La normativa europea fija un mínimo que depende del tipo de vuelo, y obliga a llevar más cuanto peores son las condiciones de #link(<glosario-cavok>)[visibilidad]#index("Visibilidad").

#block[
#callout(
body: 
[
#strong[#link(<glosario-sao>)[SAO]#index("SAO")​.IDE.105] exige a todo planeador medios para medir y mostrar la hora (en horas y minutos), la altitud de presión y la velocidad aerodinámica indicada. Los planeadores motorizados llevan además rumbo magnético.

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
Si tiras de la palanca, el planeador sube pero pierde velocidad. Un variómetro normal marcaría ascenso, cuando en realidad no has encontrado ninguna térmica: solo has cambiado velocidad por altura. El #strong[variómetro de energía total] (compensado con un Venturi o una antena especial) ignora esos cambios provocados por el piloto y solo marca ascenso cuando es la #link(<glosario-masa-de-aire>)[masa de aire]#index("Masa de aire") la que de verdad te empuja hacia arriba.

Los variómetros electrónicos modernos añaden señales acústicas (pitidos) que te dejan centrar la térmica sin apartar la vista del cielo, lo que también mejora la vigilancia del tráfico.

== Aviónica: comunicación y seguridad
<aviónica-comunicación-y-seguridad>
- #strong[Radio VHF]: fundamental para coordinarte en el aeródromo y con el control de tráfico. Úsala con brevedad para ahorrar batería.
- #strong[Transpondedor]: hace visible al planeador para los radares de los controladores y para los sistemas anticolisión (TCAS) de los aviones comerciales.
- #strong[FLARM]: el sistema estrella del vuelo sin motor. Avisa de otros planeadores cercanos y de posibles rumbos de colisión con señales visuales y sonoras.

Algunos planeadores montan además una brújula magnética y, como "instrumento" más barato y fiable de todos, el hilo de lana pegado a la #link(<glosario-cupula>)[cúpula]#index("Cúpula"), que canta el vuelo cruzado mejor que cualquier aguja. El magnetismo y el uso de la brújula se tratan en el #strong[Libro 9 --- Navegación], capítulo 2; el hilo de lana, en el #strong[Libro 5 --- Principios de vuelo], capítulo 4.

#figure([
#box(image("08-aeronave-sistemas/imagenes/08-cap06-panel-pitot.jpg"))
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
Cada vez que montas un planeador estás reconstruyendo una aeronave. Los accidentes por conexiones olvidadas se repiten desde hace décadas, y todos comparten el mismo patrón: prisa, distracción y ninguna verificación #link(<glosario-final>)[final]#index("Tramo final").

En este capítulo aprenderás:

- #strong[El proceso de #link(<glosario-rigging>)[montaje]#index("Rigging")]: el orden correcto y los cuidados con tetones y bulones.
- #strong[Las conexiones de mandos]: automáticas y manuales (#link(<glosario-lhotellier>)[L'Hotellier]#index("L’Hotellier")), y por qué las segundas exigen pin de seguridad.
- #strong[Los pasadores y seguros] de la unión ala-fuselaje.
- #strong[El Positive Control Check (#link(<glosario-pcc>)[PCC]#index("PCC"))]: la verificación con asistente que cierra el montaje.
- #strong[El cintado]: por qué las cintas de las juntas no son estética.
]

El montaje o #strong[rigging] es una de las fases más críticas para la seguridad. Un planeador mal ensamblado se comporta de forma imprevisible o, en el peor de los casos, sufre un fallo catastrófico en vuelo. Tus mejores herramientas son la disciplina y seguir al pie de la letra el Manual de Vuelo (#link(<glosario-afm>)[AFM]#index("AFM")).

== El proceso de montaje
<el-proceso-de-montaje>
Cada modelo tiene sus particularidades, pero el orden general suele ser este:

+ #strong[Fuselaje]: se saca del remolque y se asegura en su cuna o borriqueta, en posición vertical.
+ #strong[Alas]: se insertan los largueros en el fuselaje en el orden exacto especificado por el manual de vuelo (dependiendo del diseño de solapamiento de los largueros, primero la izquierda o la derecha). Antes de introducirlas, limpia y engrasa ligeramente los tetones y bulones de unión.
+ #strong[Estabilizador horizontal]: el plano de profundidad se monta al final, asegurando su fijación mecánica.

== Conexiones de mandos
<conexiones-de-mandos>
Según la antigüedad del planeador, las conexiones de alerones, #link(<glosario-aerofrenos>)[aerofrenos]#index("Aerofrenos") y profundidad pueden ser de dos tipos:

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
#box(image("08-aeronave-sistemas/imagenes/08-cap07-conectores-mandos.jpg"))
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
- #strong[Bulones principales]: son el seguro de vida de las alas. Deben entrar limpios y quedar asegurados (imperdibles o seguros #link(<glosario-zonas-p>)[R]#index("Zonas P")).
- #strong[L'Hotellier]: conexión manual crítica. Pin de seguridad siempre; el clic del muelle no basta.
- #strong[Cintado]: tapar las juntas ala-fuselaje no es solo estética; reduce el ruido y mejora bastante el rendimiento a baja velocidad.
- #strong[Carga suelta]: un clásico error mortal es dejar herramientas o pesos sueltos en el fuselaje tras el montaje. Pueden desplazarse en vuelo y bloquear los mandos.

]
= Manuales y documentos
<manuales-y-documentos>
#quote(block: true)[
Un planeador legalmente impecable importa tanto como uno mecánicamente impecable: sin los papeles en regla, ni el seguro ni el certificado de aeronavegabilidad te cubren.

En este capítulo aprenderás:

- #strong[El Manual de Vuelo (#link(<glosario-afm>)[AFM]#index("AFM"))]: qué contiene y por qué es el documento maestro.
- #strong[La documentación a bordo y en el aeródromo] según #link(<glosario-sao>)[SAO]#index("SAO")​.GEN.155, y la excepción para vuelos locales.
- #strong[Las listas de chequeo]: #link(<glosario-cumulonimbus>)[CB]#index("Cumulonimbus")-SIFT-CBE y la disciplina de leer, comprobar y confirmar.
- #strong[El diario de la aeronave]: la historia clínica del planeador.
]

Volar no es solo pilotar: también es gestionar la parte legal y la información técnica de la aeronave. El piloto que no conoce las limitaciones de su máquina, o que vuela sin los papeles en regla, se expone a riesgos operativos y a sanciones.

== El manual de vuelo (AFM / SFM)
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
- Información sobre procedimientos y señales visuales de #link(<glosario-interceptacion>)[interceptación]#index("Interceptación").
- Detalles del plan de vuelo #link(<glosario-ats>)[ATS]#index("ATS") presentado, si procede.
- Licencia de piloto, certificado médico, documento de identidad con fotografía y datos suficientes del libro de vuelo (los exige la normativa de licencias, #link(<glosario-sfcl>)[SFCL]#index("SFCL")​.045).

#strong[En el aeródromo o lugar de operación (disponibles):]

- Certificado de matrícula (CoR).
- Certificado de aeronavegabilidad (#link(<glosario-coa>)[CoA]#index("CoA")) con sus anexos y el certificado de revisión (#link(<glosario-arc>)[ARC]#index("ARC")).
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
+ #strong[Chequeo de #link(<glosario-viento-en-cola>)[viento en cola]#index("Viento en cola")]: antes de la toma (mnemotecnias FUSTALL o WULF, detalladas en el #strong[Libro 6 --- Procedimientos operativos], capítulo 4).

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
#box(image("08-aeronave-sistemas/imagenes/08-cap08-documentos-bordo.jpg"))
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

- #strong[El #link(<glosario-coa>)[CoA]#index("CoA") y el #link(<glosario-arc>)[ARC]#index("ARC")]: los dos certificados que permiten despegar legalmente, y cómo se renueva o prorroga el ARC.
- #strong[#link(<glosario-part-ml>)[Part-ML]#index("Part-ML") y Part-#link(<glosario-cao>)[CAO]#index("CAO")]: el marco simplificado de mantenimiento de la aviación ligera europea.
- #strong[El mantenimiento del piloto-propietario]: qué tareas puedes firmar tú mismo y con qué condiciones.
- #strong[Las #link(<glosario-ad>)[AD]#index("Aerodromos") y los #link(<glosario-sb>)[SB]#index("SB")]: las órdenes de obligado cumplimiento y las recomendaciones del fabricante.
]

La #strong[aeronavegabilidad] es la condición legal y técnica que certifica que una aeronave es segura para volar. No es algo estático: mantener un planeador aeronavegable exige vigilancia constante, un programa de mantenimiento riguroso y cumplir al pie de la letra la normativa europea.

== El CoA y el ARC: la "ITV" del cielo
<el-coa-y-el-arc-la-itv-del-cielo>
Para que un planeador despegue legalmente necesita dos documentos clave:

+ #strong[Certificado de aeronavegabilidad (CoA)]: es el "DNI" técnico de la aeronave. Describe sus características y certifica que el modelo es apto para el vuelo. Suele ser vitalicio, siempre que el avión se mantenga como debe.
+ #strong[Certificado de revisión de la aeronavegabilidad (ARC)]: es la validación periódica del CoA, con validez de un año. Lo emite una organización autorizada (#link(<glosario-camo>)[CAMO]#index("CAMO") o CAO) o personal de certificación independiente tras revisar la aeronave y sus registros.

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
Este capítulo es el desarrollo técnico completo del CoA y el ARC; su vertiente jurídica ---qué documentos son obligatorios a bordo y la responsabilidad legal de volar con ellos en vigor--- se estudia en el #strong[Libro 1 --- Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (#link(<glosario-atc>)[ATC]#index("ATC"))], capítulo 2.

== Normativa EASA: Part-ML y Part-CAO
<normativa-easa-part-ml-y-part-cao>
La aviación ligera se rige por normas simplificadas, que recortan la carga burocrática sin bajar la guardia en seguridad:

- #strong[Part-ML]: la normativa específica para veleros y aviones ligeros. Permite que el Programa de Mantenimiento de la Aeronave (#link(<glosario-amp>)[AMP]#index("AMP")) lo declare el propio propietario, que asume así más responsabilidad sobre su avión.
- #strong[Part-CAO]: regula a las organizaciones autorizadas a hacer el mantenimiento y a gestionar la aeronavegabilidad de forma combinada.

Cuando el AMP se basa en el #strong[Programa Mínimo de Inspección (MIP)] que recoge la propia Part-ML (ML.A.302), este fija un suelo regulatorio: una inspección al menos #strong[anual o cada 100 horas de vuelo, lo que antes se cumpla]. El AMP puede ser más exigente ---lo que diga el fabricante---, pero nunca menos que ese mínimo.

== Mantenimiento del piloto-propietario
<mantenimiento-del-piloto-propietario>
#link(<glosario-easa>)[EASA]#index("EASA") te deja, como piloto y propietario, hacer ciertas tareas de mantenimiento sencillas sin pasar por un taller certificado: cambiar neumáticos, limpiar filtros, sustituir bujías (en motoveleros) o lubricar, entre otras. Las recoge el Apéndice II de Part-ML, junto con lo que diga el programa de mantenimiento de tu aeronave.

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
#box(image("08-aeronave-sistemas/imagenes/08-cap09-ciclo-mantenimiento.jpg"))
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

- #strong[Inspección diaria (DI)]: es cosa del piloto. Sigue la lista: presión de ruedas, estado del #link(<glosario-gancho-de-remolque>)[gancho de remolque]#index("Gancho de remolque"), bisagras de mandos, limpieza de pitot y estática.
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

- #strong[Las configuraciones motorizadas]: #link(<glosario-sustentador>)[sustentador]#index("Sustentador") (#strong[turbo]), autolanzable y motovelero de turismo (#link(<glosario-tmg>)[TMG]#index("TMG")).
- #strong[Los tipos de motor]: dos tiempos, cuatro tiempos y eléctricos (#link(<glosario-fes>)[FES]#index("FES")).
- #strong[Los sistemas del motor de combustión]: encendido por magnetos, carburación y #link(<glosario-engelamiento>)[engelamiento]#index("Engelamiento"), y combustible.
- #strong[El mástil retráctil y las hélices] plegables o posicionables, y el paso de pala.
- #strong[La gestión del motor en vuelo]: secuencia de arranque, alturas de decisión e instrumentación.
]

El motor ha cambiado el vuelo sin motor: ha roto la dependencia absoluta de los medios de lanzamiento externos y ha aportado una red de seguridad frente a las tomas fuera de campo. A cambio, añade complejidad mecánica y nuevas responsabilidades al piloto.

== Turbo o autolanzable
<turbo-o-autolanzable>
No todos los motores cumplen la misma función:

- #strong[Sustentador o "turbo"]: un motor pequeño (casi siempre de dos tiempos) sin potencia para despegar. Su misión es sostener el vuelo y devolverte a casa si fallan las térmicas.
- #strong[Autolanzable] (#emph[#link(<glosario-self-launch>)[self-launch]#index("Autolanzamiento")]): un motor potente que permite despegar solo desde la pista. Alcanzada la altura deseada, se apaga y se guarda por completo.
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
Los motoveleros usan AVGAS (gasolina de aviación, con plomo) o MOGAS (gasolina de automoción), siempre el que indique el #link(<glosario-afm>)[AFM]#index("AFM"). Antes de volar se drena una muestra para descartar agua o impurezas, que pueden parar el motor: el agua, más densa, se deposita en el fondo del #emph[tester]. En cuanto a la cantidad, la norma (#link(<glosario-sao>)[SAO]#index("SAO")​.OP.120) exige combustible suficiente para completar el vuelo con seguridad; la práctica prudente es no despegar nunca con menos de 30-45 minutos de reserva.

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
#box(image("08-aeronave-sistemas/imagenes/08-cap10-motor-retractil.jpg"))
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
= Sistemas de lastre con agua (#emph[water ballast systems])
<sistemas-de-lastre-con-agua-water-ballast-systems>
#quote(block: true)[
El agua en las alas es el "#link(<glosario-sustentador>)[turbo]#index("Sustentador")" de los días de térmicas fuertes: más #link(<glosario-carga-alar>)[carga alar]#index("Carga alar"), más velocidad de crucero. Pero un sistema de lastre mal gestionado convierte esa ventaja en una emergencia.

En este capítulo aprenderás:

- #strong[Para qué sirve el lastre]: carga alar y desplazamiento de la #link(<glosario-polar-de-velocidades>)[polar de velocidades]#index("Polar de velocidades").
- #strong[Los componentes del sistema]: tanques o bolsas, válvulas de descarga y respiraderos.
- #strong[El llenado y el vaciado]: simetría, tiempos y comprobaciones.
- #strong[Los riesgos]: congelación, vaciado asimétrico y aterrizaje con agua.
- #strong[El #link(<glosario-lastre-de-cola>)[lastre de cola]#index("Lastre de cola")]: el contrapeso que restaura el centrado óptimo.
]

El #link(<glosario-lastre-de-agua>)[lastre de agua]#index("Lastre de agua") (#strong[water ballast]) es lo que permite a los planeadores de competición ajustar su peso a las condiciones del día. Con más peso, el velero vuela más rápido perdiendo menos altura, algo decisivo para hacer grandes distancias cuando las térmicas son potentes.

== Para qué sirve: carga alar y velocidad
<para-qué-sirve-carga-alar-y-velocidad>
Añadir agua aumenta la #strong[carga alar], y eso desplaza la polar de velocidades hacia la derecha: la velocidad de planeo óptima sube y las transiciones entre térmicas son mucho más rápidas. Tiene un precio: el planeador trepa peor en las térmicas flojas y su velocidad de pérdida es mayor. El efecto del lastre sobre la polar se desarrolla en el #strong[Libro 7 --- Planificación y Rendimiento de Vuelo], capítulo 2.

== Componentes del sistema
<componentes-del-sistema>
El sistema es sencillo de concepto, pero exige un mantenimiento escrupuloso:

- #strong[Tanques o bolsas]: en el interior de las alas, cerca del #link(<glosario-larguero>)[larguero]#index("Larguero"). Pueden ser bolsas de goma o compartimentos estancos integrados en la estructura.
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
Para compensar el desplazamiento del centro de gravedad que provoca el agua de las alas, algunos planeadores llevan un pequeño depósito en la #link(<glosario-deriva>)[deriva]#index("Deriva"). Al llenar ese tanque de cola, se recupera el equilibrio óptimo del velero para volar rápido.

#figure([
#box(image("08-aeronave-sistemas/imagenes/08-cap11-lastre-agua.jpg"))
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
= Baterías (rendimiento y limitaciones operativas)
<baterías-rendimiento-y-limitaciones-operativas>
#quote(block: true)[
Un planeador vuela sin motor, pero no sin electricidad: la radio, el #link(<glosario-flarm>)[FLARM]#index("FLARM"), el #link(<glosario-transpondedor>)[transpondedor]#index("Transpondedor") y los variómetros dependen de la batería. Gestionarla bien es gestionar tu seguridad.

En este capítulo aprenderás:

- #strong[Los tipos de batería]: plomo-ácido (gel/AGM) y litio (#link(<glosario-lifepo4>)[LiFePO4]#index("LiFePO4")), con sus ventajas y sus precauciones.
- #strong[La fijación de la batería]: por qué la certificación exige soportes a prueba de impacto.
- #strong[La gestión de la energía en vuelo]: amperios-hora, consumos y el efecto del frío.
- #strong[La protección del sistema]: fusibles y disyuntores.
]

El planeador vuela sin motor, pero no sin electricidad. La radio, el transpondedor, el FLARM y los variómetros electrónicos necesitan una fuente de energía fiable. En vuelos largos, gestionar la batería es tan importante como gestionar el combustible en un avión a motor.

== Tipos de baterías
<tipos-de-baterías>
En la aviación de recreo predominan dos tecnologías:

- #strong[Plomo-ácido (gel/AGM)]: las más comunes por su bajo coste y su fiabilidad. Van selladas y no necesitan mantenimiento, pero pesan lo suyo (entre 2,5 y 4 kg por unidad).
- #strong[Litio (LiFePO4)]: mucho más ligeras y con una descarga más plana (mantienen el voltaje casi hasta el #link(<glosario-final>)[final]#index("Tramo final")). A cambio, piden cargadores específicos y un manejo cuidadoso para evitar incendios por cortocircuito.

== Ubicación y seguridad estructural
<ubicación-y-seguridad-estructural>
La batería suele ir en la sección central del fuselaje, detrás del piloto, o en un compartimento del morro (para ayudar al centrado).

Por su densidad de peso, su fijación es un punto crítico de inspección. Una batería mal sujeta se convierte en un proyectil mortal en un aterrizaje brusco o un accidente.

#block[
#callout(
body: 
[
#strong[#link(<glosario-cs>)[CS]#index("CS") 22.561(d)] exige que la estructura de soporte retenga cualquier masa que pueda lesionar a un ocupante si se suelta en un aterrizaje de emergencia, soportando las fuerzas de inercia últimas de #strong[CS 22.561(b)(1)]: 15g hacia delante, 9g hacia abajo, 7,5g hacia arriba y 6g lateral. No sujetes nunca la batería con gomas elásticas ni montajes improvisados: usa los soportes o cinchas aprobados por el fabricante y comprueba su firmeza en cada inspección prevuelo.

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

Pero el rendimiento cae mucho con el frío: a 0 °C te queda en #link(<glosario-torno>)[torno]#index("Torno") al 80 % de la capacidad nominal. Si planeas un vuelo largo en altura, despega con las baterías al 100 %.

Y si vas a volar en nubes (con la habilitación correspondiente), no despegues sin las baterías prácticamente llenas: sin referencias visuales, tus instrumentos son lo único que te mantiene con las alas niveladas, y quedarte sin energía dentro de una nube es una emergencia mayor. La norma no fija un porcentaje concreto; la gestión de la energía disponible es responsabilidad tuya (#link(<glosario-sao>)[SAO]#index("SAO")​.OP.145 en los motorizados).

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
#box(image("08-aeronave-sistemas/imagenes/08-cap12-sistema-electrico.jpg"))
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
El #link(<glosario-paracaidas-de-emergencia>)[paracaídas de emergencia]#index("Paracaídas de emergencia") es el único equipo del planeador que esperas no usar jamás, y justo por eso exige un mantenimiento y un ajuste impecables.

En este capítulo aprenderás:

- #strong[El paracaídas como sistema]: campana, contenedor, anilla y los enemigos del nylon.
- #strong[El mantenimiento]: replegado periódico, vida útil y cuidado diario.
- #strong[La colocación y el ajuste del arnés]: por qué un arnés flojo lesiona.
- #strong[La secuencia de abandono], en resumen; su entrenamiento completo está en el #strong[Libro 6 --- Procedimientos operativos], capítulo 8.
]

El paracaídas de emergencia es el equipo que ningún piloto quiere estrenar, pero que todos tienen que saber manejar a la perfección. En el vuelo sin motor, donde el riesgo de colisión en #link(<glosario-termica>)[térmica]#index("Térmica") es real, es tu última línea de defensa.

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
El abandono del planeador (#strong[#link(<glosario-bail-out>)[bail-out]#index("Bail-out")]) ante una emergencia que lo deje ingobernable (una colisión, una rotura estructural) exige una secuencia clarísima en tu cabeza:

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
#box(image("08-aeronave-sistemas/imagenes/08-cap13-secuencia-salto.jpg"))
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
- #strong[Secuencia]: cabina, cinturones, saltar, anilla. Mínimo recomendado: 150 m #link(<glosario-agl>)[AGL]#index("AGL"). El procedimiento completo se entrena con el #strong[Libro 6 --- Procedimientos operativos], capítulo 8.

]
= Equipo de evacuación de emergencia (#emph[emergency bail-out aid])
<equipo-de-evacuación-de-emergencia-emergency-bail-out-aid>
#quote(block: true)[
Si el vuelo termina mal y lejos de casa, tu supervivencia depende de lo que llevabas puesto y de lo que cargaste en el fuselaje antes de despegar.

En este capítulo aprenderás:

- #strong[Las balizas de localización]: #link(<glosario-elt>)[ELT]#index("ELT") fijo y #link(<glosario-plb>)[PLB]#index("PLB") portátil, y por qué deben emitir en 406 MHz.
- #strong[Los sistemas de oxígeno]: flujo continuo y #link(<glosario-eds>)[EDS]#index("EDS"), y cuándo exige la norma usarlos.
- #strong[El kit de supervivencia esencial] para vuelos de montaña o sobre zonas despobladas.
]

En una situación extrema, el equipo de emergencia y tu capacidad de supervivencia deciden si el rescate sale bien. Ir preparado para lo peor es lo que te permite volar tranquilo.

== Balizas de localización: ELT y PLB
<balizas-de-localización-elt-y-plb>
Si tienes un accidente o una toma forzosa en una zona remota, necesitas que los servicios de búsqueda y rescate (#link(<glosario-sar>)[SAR]#index("SAR")) te encuentren rápido.

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
A medida que subes, la presión atmosférica baja y a tus pulmones les llegan menos moléculas de oxígeno. Eso provoca la #strong[#link(<glosario-hipoxia>)[hipoxia]#index("Hipoxia")], con síntomas traicioneros: euforia, falta de concentración, visión de túnel. La fisiología completa de la hipoxia, el tiempo de conciencia útil y la regla «oxígeno al 100 % y desciende» se estudian en el #strong[Libro 2 --- Factores humanos, capítulo 4]. Aquí nos centramos en el equipo y en la norma.

#block[
#callout(
body: 
[
#strong[#link(<glosario-sao>)[SAO]#index("SAO")​.OP.150 (uso de oxígeno suplementario)]: «El #link(<glosario-pic>)[piloto al mando]#index("Piloto al mando") se asegurará de que todas las personas a bordo utilicen oxígeno suplementario siempre que determine que, a la altitud del vuelo previsto, la falta de oxígeno podría provocar un deterioro de sus facultades o afectarles perjudicialmente.»

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
Como buena práctica fisiológica, que no como requisito normativo, muchos pilotos usan oxígeno desde altitudes menores (en #link(<glosario-torno>)[torno]#index("Torno") a 5.000 ft) al atardecer, porque la visión es lo primero que se resiente con la falta de oxígeno.

== Equipos de oxígeno
<equipos-de-oxígeno>
+ #strong[Flujo continuo]: el oxígeno sale sin parar de un depósito a través de una cánula o una máscara. Es sencillo, pero poco eficiente: gasta mucho gas.
+ #strong[Sistemas EDS (Electronic Delivery System)]: dispositivos que detectan tu inspiración y sueltan un pulso de oxígeno justo cuando lo necesitas. Multiplican por tres o cuatro la duración de la botella.

== Kit de supervivencia esencial
<kit-de-supervivencia-esencial>
No despegues sin un kit básico de supervivencia, sobre todo si vuelas sobre montaña o zonas despobladas. Debería llevar:

- #strong[Agua]: al menos 1 o 2 litros. La deshidratación nubla el juicio.
- #strong[Señalización]: un espejo de señales y un silbato.
- #strong[Protección #link(<glosario-termica>)[térmica]#index("Térmica")]: una manta de supervivencia (foil) para no entrar en hipotermia si te toca pasar la noche fuera.
- #strong[Energía]: un teléfono móvil con la batería cargada y, a poder ser, una batería externa (powerbank).

#figure([
#box(image("08-aeronave-sistemas/imagenes/08-cap14-equipo-supervivencia.jpg"))
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

- #strong[ELT / PLB]: tu baliza de salvación. Las de 406 MHz con #link(<glosario-gps>)[GPS]#index("GPS") mandan tu posición exacta al satélite en minutos. Las antiguas de 121.5 MHz ya no se vigilan por satélite.
- #strong[Oxígeno]: la regla es SAO.OP.150: el piloto valora el riesgo de hipoxia; si no puede valorarlo, oxígeno siempre por encima de 10.000 ft (AMC1). Los sistemas EDS (a demanda) ahorran mucho oxígeno. La fisiología se estudia en el #strong[Libro 2 --- Factores humanos], capítulo 4.
- #strong[Kit de supervivencia]: agua, abrigo, espejo de señales, móvil cargado. Si aterrizas en una ladera remota, pueden tardar horas o días en sacarte. Vístete para la temperatura de fuera, no para la de cabina.

]
#part[Parte 09: Navegación]
= Fundamentos de navegación
<fundamentos-de-navegación>
#quote(block: true)[
Navegar es, en esencia, llevar el planeador de un punto a otro con seguridad y sin malgastar energía. Para eso hacen falta dos cosas: entender cómo nos movemos sobre la esfera terrestre y saber medir nuestra posición y el tiempo.

En este capítulo aprenderás:

- #strong[El sistema de coordenadas]: #link(<glosario-latitud>)[latitud]#index("Latitud") y #link(<glosario-longitud>)[longitud]#index("Longitud"), y por qué un minuto de latitud es siempre una #link(<glosario-milla-nautica>)[milla náutica]#index("Milla náutica").
- #strong[#link(<glosario-ortodromica>)[Ortodrómica]#index("Ortodrómica") y #link(<glosario-loxodromica>)[loxodrómica]#index("Línea de rumbo")]: la ruta más corta frente a la de rumbo constante, y cuál vuelas en realidad.
- #strong[El tiempo en aviación]: qué es #link(<glosario-utc>)[UTC]#index("Hora Zulu") (hora Zulu) y por qué toda la aviación trabaja con él.
- #strong[#link(<glosario-orto>)[Orto]#index("Orto"), #link(<glosario-ocaso>)[ocaso]#index("Ocaso") y vuelo diurno]: dónde está el límite legal de la luz para un planeador.
- #strong[Las unidades náuticas]: la milla náutica y el #link(<glosario-nudo>)[nudo]#index("Nudo"), y cómo pensar en ellas de cabeza.
]

== El sistema de coordenadas: latitud y longitud
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
#box(image("09-navegacion/imagenes/09-cap01-coordenadas.jpg"))
], caption: figure.caption(
position: bottom, 
[
Sistema de coordenadas terrestres (Latitud y Longitud)
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap01-coordenadas>


== Ortodrómica y loxodrómica
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

También lo conocemos como #strong[Hora Zulu (Z)]. Es la hora en el meridiano 0º (Greenwich). Cuando recibes un #link(<glosario-metar>)[METAR]#index("METAR") o un #link(<glosario-notam>)[NOTAM]#index("NOTAM"), la hora siempre vendrá en formato Zulu.

#block[
#callout(
body: 
[
#strong[#link(<glosario-sao>)[SAO]#index("SAO")​.IDE.105] exige que todo planeador lleve un medio para medir y mostrar la hora en horas y minutos. Llévalo ajustado a UTC o ten clara la diferencia horaria del día (en España, +1h en invierno y +2h en verano respecto a UTC).

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

No confundas el ocaso con el principio de la noche. Para la aviación, la #strong[noche] es el periodo entre el #link(<glosario-final>)[final]#index("Tramo final") del #strong[#link(<glosario-crepusculo-civil>)[crepúsculo civil]#index("Crepúsculo civil")] vespertino y el inicio del matutino, y el crepúsculo civil termina (o empieza) cuando el centro del sol está #strong[6º por debajo del horizonte]. Es decir: tras el ocaso aún queda un rato de luz utilizable antes de que, oficialmente, sea de noche.

#block[
#callout(
body: 
[
El vuelo en planeador se realiza en condiciones visuales (#link(<glosario-vfr>)[VFR]#index("VFR")) y, con carácter general, #strong[de día]. La operación nocturna en #link(<glosario-vmc>)[VMC]#index("VMC") solo está al alcance del titular #link(<glosario-spl>)[SPL]#index("SPL") con privilegios de motovelero de turismo (#link(<glosario-tmg>)[TMG]#index("TMG")) y la correspondiente #strong[habilitación de vuelo nocturno], además del equipamiento de luces exigido. Consulta siempre la hora del ocaso al planificar: en altura tendrás luz un rato más, pero una vez abajo la oscuridad llega rápido. Las horas oficiales de orto y ocaso para cada aeródromo se publican en el #link(<glosario-aip>)[AIP]#index("AIP")-España (GEN 2.7).

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
En el entorno internacional, y especialmente en España bajo normativa #link(<glosario-easa>)[EASA]#index("EASA"), utilizamos unidades náuticas para la navegación horizontal:

- #strong[Milla Náutica (NM)]: 1 NM = 1852 metros.
- #strong[Nudo (kt)]: Es una unidad de velocidad que equivale a 1 milla náutica por hora.

Aunque es común ver anemómetros en kilómetros por hora (km/h) en muchos planeadores europeos de diseño clásico, la navegación y las cartas aeronáuticas se basan en millas náuticas y nudos. Aprender a pasar de unos a otros mentalmente es una habilidad muy útil en el hangar.

#postit[
#strong[Resumen del capítulo: fundamentos de navegación]

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

- #strong[El #link(<glosario-norte-verdadero>)[norte verdadero]#index("Norte verdadero") y el magnético]: la variación (#link(<glosario-variacion-magnetica>)[declinación]#index("Variación magnética")) y la regla "Declinación Oeste, rumbo suma".
- #strong[El #link(<glosario-desvio>)[desvío]#index("Desvío") y la tablilla]: por qué el propio planeador engaña a la brújula y cómo se compensa.
- #strong[Los errores de viraje]: por qué la brújula se adelanta o se retrasa al virar hacia el Norte o el Sur.
- #strong[Los errores de aceleración (#link(<glosario-ands>)[ANDS]#index("ANDS"))]: las lecturas falsas al acelerar o frenar en rumbos Este-Oeste.
]

== Norte verdadero vs.~norte magnético
<norte-verdadero-vs.-norte-magnético>
Aunque solemos pensar en "el Norte" como un punto único, en navegación distinguimos dos:

- #strong[Norte Verdadero (Geográfico)]: Es el punto por donde pasa el eje de rotación de la Tierra. Es el norte que verás en los mapas y cartas aeronáuticas.
- #strong[#link(<glosario-norte-magnetico>)[Norte Magnético]#index("Norte magnético")]: Es el punto hacia el que apuntan las agujas de nuestras brújulas. Curiosamente, este punto no es fijo y se desplaza ligeramente cada año.

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
== El desvío y la tablilla
<el-desvío-y-la-tablilla>
El planeador no es un entorno magnéticamente puro. Los tubos de acero del fuselaje, los altavoces de la radio y los instrumentos electrónicos generan sus propios campos magnéticos que "engañan" a la brújula. Este error local se llama #strong[Desvío].

Para compensarlo, cada aeronave debe tener una #strong[#link(<glosario-tablilla-de-desvios>)[Tablilla de Desvíos]#index("Tablilla de desvíos")] instalada a la vista del piloto (#ref(<fig-09-cap02-tablilla-desvios>, supplement: [Figura])).

#figure([
#box(image("09-navegacion/imagenes/09-cap02-tablilla-desvios.jpg"))
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

=== Errores de viraje
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
=== Errores de aceleración (ANDS)
<errores-de-aceleración-ands>
Si aceleramos o frenamos mientras volamos con rumbos Este u Oeste, la inercia del sistema pendular de la brújula provoca lecturas falsas:

- #strong[Acelerar]: La brújula indica un viraje hacia el Norte.
- #strong[Decelerar]: La brújula indica un viraje hacia el Sur.

Recordamos esto con la regla inglesa #strong[ANDS]: #strong[A]ccelerate #strong[N]orth, #strong[#link(<glosario-zonas-p>)[D]#index("Zonas P")]ecelerate #strong[S]outh. Es decir: al #strong[acelerar], la brújula tiende al #strong[Norte]\; al #strong[decelerar], tiende al #strong[Sur].

#postit[
#strong[Resumen del capítulo: magnetismo y brújulas]

- #strong[Norte Verdadero vs Magnético]: La brújula apunta al Norte Magnético, que no coincide con el Geográfico (Verdadero). La diferencia es la #strong[Variación (o Declinación)]. Regla: "Declinación Oeste, Rumbo Suma".
- #strong[Desvío]: El propio avión tiene campos magnéticos (tubos de acero, radios) que afectan a la brújula. Este error es el #strong[Desvío] y se corrige con la tablilla de desvíos de la cabina.
- #strong[Errores de la Brújula]: La brújula solo dice la verdad en vuelo recto y nivelado (y no acelerado).
- #strong[#link(<glosario-error-de-viraje>)[Error de Viraje]#index("Error de viraje")]: Al virar al Norte, la brújula se queda atrás (vas corto: NO te pases); al Sur se adelanta (déjala pasar: SÍ te pasas).
- #strong[Error de Aceleración]: Al acelerar en rumbos E/W, marca viraje al Norte; al frenar, al Sur (regla #strong[ANDS]: #strong[Accelerate North, Decelerate South]).

]
= Cartas aeronáuticas
<cartas-aeronáuticas>
#quote(block: true)[
Una carta aeronáutica no es un simple mapa; es un instrumento de vuelo que debemos aprender a leer con la misma fluidez que el #link(<glosario-variometro>)[variómetro]#index("Variómetro"). En España, nuestra referencia fundamental es la serie de cartas #link(<glosario-vfr>)[VFR]#index("VFR") 1:500.000 publicadas por ENAIRE.

En este capítulo aprenderás:

- #strong[La #link(<glosario-proyeccion-lambert>)[proyección Lambert]#index("Proyección Lambert")]: por qué la cartografía aeronáutica la eligió y qué ventajas tiene para volar.
- #strong[La #link(<glosario-escala>)[escala]#index("Escala") 1:500.000]: cómo traducir los centímetros del papel a kilómetros y millas del terreno.
- #strong[La simbología]: espacios aéreos, #link(<glosario-zonas-p>)[zonas P]#index("Zonas P")/R/D, obstáculos y la diferencia entre #link(<glosario-amsl>)[AMSL]#index("AMSL") y #link(<glosario-agl>)[AGL]#index("AGL").
- #strong[El relieve y la Altitud Mínima de Área (#link(<glosario-ama>)[AMA]#index("AMA"))]: la red de seguridad que te da la carta sobre el terreno.
]

== La proyección conforme de Lambert
<la-proyección-conforme-de-lambert>
Representar una superficie esférica sobre un papel plano siempre introduce deformaciones, y cada familia de proyecciones decide qué sacrificar. Las #strong[cilíndricas] (como la Mercator/UTM) mantienen los rumbos como líneas rectas pero deforman mucho las distancias al alejarse del ecuador; las #strong[azimutales] proyectan sobre un plano tangente; y las #strong[cónicas], sobre un cono. La aviación en latitudes medias eligió la cónica conforme de #strong[Lambert].

Se la llama "conforme" porque conserva con gran fidelidad los ángulos y las formas del terreno.

Para nosotros, tiene dos ventajas clave: \* #strong[Escala constante]: Podemos usar una regla de navegación en cualquier parte de la carta y la medida será fiable. \* #strong[Líneas rectas]: Una línea recta trazada en esta carta se aproxima mucho a un círculo máximo (#link(<glosario-ortodromica>)[ortodrómica]#index("Ortodrómica")), que es la ruta más corta sobre la Tierra.

== Entendiendo la escala
<entendiendo-la-escala>
La escala estándar que manejamos es #strong[1:500.000]. Esto significa que cualquier distancia medida sobre el papel es 500.000 veces mayor en la realidad.

Para facilitar el cálculo mental en cabina, recuerda: \* #strong[1 cm en la carta = 5 kilómetros] en el terreno. \* #strong[1 cm en la carta ≈ 2.7 Millas Náuticas (#link(<glosario-milla-nautica>)[NM]#index("Milla náutica"))].

Con una simple regla de navegación medimos sobre la carta y trasladamos la distancia al terreno; la barra de escala de la #ref(<fig-09-cap03-carta-enaire>, supplement: [Figura]) permite hacerlo de un vistazo.

== Simbología y espacios aéreos
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
== El relieve y la altitud mínima de área (AMA)
<el-relieve-y-la-altitud-mínima-de-área-ama>
El terreno se representa mediante #strong[#link(<glosario-tintas-hipsometricas>)[tintas hipsométricas]#index("Tintas hipsométricas")] (cambios de color: verde para valles, marrones para montañas) y curvas de nivel.

En cada cuadrícula de la carta (formada por paralelos y meridianos cada 30 minutos), verás un número grande acompañado de uno más pequeño en superíndice (ej: 4#super[7], que se lee 4.700 ft). Es la #strong[Altitud Mínima de Área (AMA)] (#ref(<fig-09-cap03-carta-enaire>, supplement: [Figura])).

#figure([
#box(image("09-navegacion/imagenes/09-cap03-carta-enaire-ama.png"))
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
La AMA garantiza una separación mínima de #strong[1000 pies] (o 2000 pies en zonas de alta montaña) sobre el obstáculo más alto de ese cuadrante. Es tu "red de seguridad" si pierdes la #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") o necesitas navegar con seguridad sobre el relieve.

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
#strong[Resumen del capítulo: cartas aeronáuticas]

- #strong[Proyección Lambert]: Es la estándar para cartas VFR (1:500.000). Es "conforme" (mantiene las formas) y una línea recta es una ortodrómica (ruta más corta). La escala es prácticamente constante entre los dos paralelos estándar de la proyección (la zona útil de la carta).
- #strong[Simbología]: Debes leer una carta con fluidez. Conoce los símbolos de obstáculos (la cifra sin paréntesis es la altitud sobre el nivel del mar ---AMSL---; la que va entre paréntesis es la altura sobre el terreno ---AGL---), los espacios aéreos (clases A a G) y las zonas P/R/D (prohibida, restringida, peligrosa), además de los aeródromos.
- #strong[Escala]: 1:500.000 significa que 1 cm en el papel son 5 km en la realidad.
- #strong[Elevaciones]: Las tintas hipsométricas (colores del terreno) te dan una idea rápida del relieve. La #strong[Altitud Mínima de Área (AMA)] ---no "cota máxima"--- es el número grande en cada recuadro. Proporciona separación mínima de 1000 ft sobre el obstáculo más alto de esa zona.

]
= Navegación por estima (#emph[dead reckoning])
<navegación-por-estima-dead-reckoning>
#quote(block: true)[
Navegar a estima consiste en deducir dónde estás partiendo de un punto conocido y aplicando rumbo, velocidad y tiempo transcurrido. Es lo que te permite alejarte del campo sabiendo siempre dónde estás, aunque el #link(<glosario-gnss>)[GNSS]#index("GNSS") se apague.

En este capítulo aprenderás:

- #strong[El #link(<glosario-triangulo-de-velocidades>)[triángulo de velocidades]#index("Triángulo de velocidades")]: #link(<glosario-tas>)[TAS]#index("True Air Speed"), viento y #link(<glosario-gs>)[GS]#index("Velocidad suelo"), y la diferencia entre #link(<glosario-ias>)[IAS]#index("IAS"), TAS y GS.
- #strong[La #link(<glosario-deriva>)[deriva]#index("Deriva") y el ángulo de corrección (#link(<glosario-wca>)[WCA]#index("WCA"))]: cómo "meter el morro al viento" para no salirte de ruta.
- #strong[La cadena de rumbos]: pasar de la trayectoria de la carta al número de la brújula con la convención (W−/E+), con un ejemplo resuelto.
- #strong[El cálculo de deriva y velocidad suelo]: las fórmulas mentales rápidas, con ejemplos numéricos.
- #strong[Tiempo, velocidad y distancia]: la aritmética que cierra la estima.
- #strong[La #link(<glosario-regla-del-1-en-60>)[regla del 1 en 60]#index("Regla del 1 en 60")]: corregir el rumbo sobre la marcha sin transportador.
]

== El triángulo de velocidades
<el-triángulo-de-velocidades>
Todo en navegación por estima se resume en un triángulo vectorial compuesto por tres elementos:

+ #strong[TAS (Velocidad Verdadera)]: Tu velocidad respecto a la #link(<glosario-masa-de-aire>)[masa de aire]#index("Masa de aire"). Es el vector que marca hacia dónde apunta el planeador.
+ #strong[Viento]: La dirección e intensidad de la masa de aire en la que flotas.
+ #strong[GS (Velocidad Suelo)]: Es la resultante. Tu velocidad real sobre el terreno y la trayectoria que realmente vas a "dibujar" en el mapa.

La suma vectorial de estos tres elementos es la #link(<glosario-base>)[base]#index("Tramo de base") de todos los cálculos de este capítulo (véase #ref(<fig-09-cap04-triangulo-velocidades>, supplement: [Figura])).

#block[
#callout(
body: 
[
No confundas las tres velocidades que entran en juego: la #strong[IAS] (indicada) es la que marca el anemómetro; la #strong[TAS] (verdadera) es la IAS corregida por densidad ---crece aproximadamente un #strong[2 % por cada 300 m] de altitud, unos 6,5-7 % por cada 1.000 m---; y la #strong[GS] (suelo) es la TAS combinada con el viento. En navegación siempre razonamos con #strong[TAS] y #strong[GS], nunca con la IAS a secas. (El #strong[Libro 7 --- Planificación y Rendimiento de Vuelo] usa esta misma regla en su forma «2 % por 300 m».)

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
#box(image("09-navegacion/imagenes/09-cap04-triangulo-viento.jpg"))
], caption: figure.caption(
position: bottom, 
[
El triángulo de viento en navegación aérea
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap04-triangulo-velocidades>


== Deriva y ángulo de corrección (WCA)
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
== La cadena de rumbos: de la carta a la brújula
<la-cadena-de-rumbos-de-la-carta-a-la-brújula>
Para saber qué número exacto debemos ver en nuestra brújula para seguir una línea trazada en el mapa, seguimos este proceso lógico:

+ #strong[TC (Trayectoria Verdadera)]: El ángulo medido en la carta con el transportador.
+ #strong[TH (Rumbo Verdadero de Proa)]: Aplicamos el WCA ($T C plus.minus W C A = T H$).
+ #strong[MH (Rumbo Magnético)]: Aplicamos la #link(<glosario-variacion-magnetica>)[Variación magnética]#index("Variación magnética") ($T H plus.minus V A R = M H$).
+ #strong[CH (Rumbo de Brújula)]: Aplicamos el #link(<glosario-desvio>)[Desvío]#index("Desvío") de nuestra aeronave ($M H plus.minus D E V = C H$).

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
El signo es lo que más despista. La regla es sencilla: sobre el rumbo verdadero, una variación o desvío al #strong[Oeste (W) suma] grados, y al #strong[Este (E) resta]. En las fórmulas lo escribimos como #strong[\(W −) / (E +)]: el valor Oeste entra con signo negativo dentro del paréntesis y, al restarlo, acaba sumando. En algunos bancos de preguntas de examen la misma idea se expresa como $M H = T C + V A R_W$ o $M H = T C - V A R_E$\; es la misma convención con distinta notación.

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

$ M H = T C - V A R = 100 - \( - 5 \) = 105^compose $

$ C H = M H - D E V = 105 - \( + 2 \) = 103^compose $

Volaremos, por tanto, con la brújula marcando #strong[103º]. Fíjate en cómo la Variación Oeste #strong[aumentó] el rumbo (de 100 a 105) y el Desvío Este lo #strong[redujo] (de 105 a 103): exactamente lo que predice la convención (W −) / (E +).

== Cálculo de la deriva y la velocidad suelo
<cálculo-de-la-deriva-y-la-velocidad-suelo>
Cuando preparamos el vuelo en tierra rara vez dibujamos el triángulo con regla: estimamos la deriva con dos fórmulas mentales muy rápidas.

Primero descomponemos el viento respecto a nuestra trayectoria, siendo $alpha$ el ángulo entre el rumbo y la dirección de donde viene el viento:

$ V_(c r u z a d o) = V dot.op sin alpha #h(2em) V_(f r e n t e) = V dot.op cos alpha $

La #strong[componente cruzada] es la que nos saca de ruta; la #strong[componente de frente/cola] solo cambia nuestra velocidad suelo. Con la componente cruzada y nuestra TAS, el ángulo de deriva (#strong[Drift Angle]) sale de una variante de la regla 1-en-60:

$ D A = frac(V_(c r u z a d o) dot.op 60, T A S) $

Y la velocidad suelo resultante es:

$ G S = T A S plus.minus V dot.op cos alpha $

\(signo #strong[−] con viento de cara, #strong[\+] con viento de cola).

#block[
#callout(
body: 
[
Volamos a #strong[TAS = 60 #link(<glosario-nudo>)[kt]#index("Nudo")] con un viento cruzado de #strong[20 kt]. La deriva será $D A = \( 20 times 60 \) \/ 60 = 20^compose$. Si ese mismo viento de 20 kt fuera de cara, nuestra velocidad suelo bajaría a #strong[40 kt]\; de cola, subiría a #strong[80 kt]. Con TAS baja, ¡el viento manda!

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
La aritmética básica de la estima cierra el triángulo: con dos datos obtienes el tercero a partir de $G S = D \/ T$.

$ T = frac(D, G S) #h(2em) D = G S dot.op T #h(2em) G S = D / T $

Ejemplo: si planeamos un tramo de #strong[45 #link(<glosario-milla-nautica>)[NM]#index("Milla náutica")] y esperamos una velocidad suelo de #strong[90 kt], tardaremos $T = 45 \/ 90 = 0 \, 5 med upright(h) = 30$ minutos. Convertir las horas decimales a minutos es solo multiplicar la parte decimal por 60 (0,5 h × 60 = 30 min).

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
== La regla del 1 en 60
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

#strong[Solución.] El viento es 100 % cruzado, así que la componente cruzada es los 18 km/h completos. Con la fórmula mental de deriva, $D A = \( V_(c r u z a d o) times 60 \) \/ T A S = \( 18 times 60 \) \/ 90 = 1080 \/ 90 = 12^compose$. El viento viene de la izquierda (del oeste hacia un rumbo norte), así que empujaría hacia la derecha; para compensarlo, mete morro al viento: vuela un rumbo verdadero de #strong[348°] (000° − 12°). Fíjate en la lección del planeador: con TAS baja, un viento moderado produce una deriva grande (aquí, 12° por solo 18 km/h de viento).

#postit[
#strong[Resumen del capítulo: #link(<glosario-navegacion-a-estima>)[navegación a estima]#index("Navegación a estima")]

- #strong[El Triángulo de Velocidades]: Es la base de todo. Tres vectores: #strong[TAS] (Tu velocidad real aire), #strong[Viento] (Velocidad del aire) y #strong[GS] (Tu velocidad suelo). Si conoces dos, calculas el tercero.
- #strong[Deriva (Drift)]: El ángulo que el viento te desvía de tu rumbo. Debes corregirlo "metiendo morro al viento" (#strong[Ángulo de Corrección de Deriva - WCA]).
- #strong[La Fórmula Mágica]: TC (Rumbo Verdadero) $plus.minus$ WCA = TH (Rumbo Verdadero de Proa). TH $plus.minus$ VAR = MH (Rumbo Magnético). MH $plus.minus$ DEV = CH (Rumbo de Compás). Convención de signos: #strong[\(W −) / (E +)].
- #strong[Deriva y velocidad suelo]: $D A = \( V_(c r u z a d o) times 60 \) \/ T A S$ y $G S = T A S plus.minus V dot.op cos alpha$. Con TAS baja, un viento moderado produce mucha deriva.
- #strong[Tiempo/distancia/velocidad]: $T = D \/ G S$. Pasa horas decimales a minutos multiplicando por 60.
- #strong[Regla del 60]: Si te desvías 1 milla en 60 millas de vuelo, tu error de rumbo es 1 grado. Útil para correcciones mentales rápidas.

]
= Navegación en vuelo
<navegación-en-vuelo>
#quote(block: true)[
En el aire, la teoría del papel se vuelve oficio: comparar lo que ves por la #link(<glosario-cupula>)[cúpula]#index("Cúpula") con lo que habías planificado. Y en planeador esto exige un punto extra de atención, porque no podemos perdernos mientras además gestionamos la energía y buscamos la siguiente #link(<glosario-termica>)[térmica]#index("Térmica").

En este capítulo aprenderás:

- #strong[Las tres formas de navegar]: estima, observada y visual, y cómo se combinan en vuelo.
- #strong[La técnica mapa-terreno]: busca en el mapa lo que ves fuera, nunca al revés.
- #strong[La #link(<glosario-triangulacion>)[triangulación]#index("Triangulación")]: cruzar dos líneas de posición para fijar dónde estás con certeza.
- #strong[La gestión de la incertidumbre de posición (#link(<glosario-uop>)[UOP]#index("UOP"))]: qué hacer cuando dudas de dónde estás.
]

== Tres formas de navegar
<tres-formas-de-navegar>
En la práctica combinamos tres técnicas que se complementan:

- #strong[Navegación a la estima] (#strong[#link(<glosario-navegacion-a-estima>)[dead reckoning]#index("Navegación a estima")]): deducimos la posición a partir del rumbo, la velocidad y el tiempo (el capítulo anterior). Es nuestra #link(<glosario-base>)[base]#index("Tramo de base") de cálculo, pero los pequeños errores se acumulan.
- #strong[#link(<glosario-navegacion-observada>)[Navegación observada]#index("Navegación observada")]: fijamos la posición reconociendo el terreno (ríos, carreteras, pueblos) y comparándolo con la carta.
- #strong[Navegación visual]: la combinación de las dos anteriores ---calculamos a la estima y #strong[confirmamos] con referencias del terreno--- y es la que realmente usamos en vuelo a vela.

== La técnica mapa-terreno
<la-técnica-mapa-terreno>
La regla de oro de la navegación visual es: #strong[nunca busques en el terreno lo que ves en el mapa; busca en el mapa lo que ves en el terreno.]

- #strong[Selecciona referencias grandes]: Autopistas, líneas de costa, grandes lagos o ciudades. Los ríos pequeños pueden ser confusos si serpentean mucho o están secos.
- #strong[Orientación del mapa]: Vuela siempre con el mapa orientado en el sentido de tu vuelo ("arriba" es hacia donde vas). De esta forma, si ves una montaña a tu izquierda en el terreno, debe estar a la izquierda en tu mapa.

== Triangulación: saber dónde estás con certeza
<triangulación-saber-dónde-estás-con-certeza>
No confíes en una sola referencia. Para confirmar tu posición, usa la técnica de la triangulación o líneas de posición:

+ Identifica una referencia lineal y bien definida (una carretera nacional, un río o una vía de tren, por ejemplo).
+ Busca una segunda referencia que cruce o esté alineada con un punto notable (ej: "estoy sobre la carretera N-VI, justo cuando el pueblo X queda a mis 3").

El cruce de esas dos líneas de posición fija tu posición con bastante certeza (#ref(<fig-09-cap05-triangulacion>, supplement: [Figura])).

#figure([
#box(image("09-navegacion/imagenes/09-cap05-triangulacion.jpg"))
], caption: figure.caption(
position: bottom, 
[
Técnica de triangulación visual en vuelo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap05-triangulacion>


== Gestión de la incertidumbre (UOP)
<gestión-de-la-incertidumbre-uop>
Si en algún #link(<glosario-momento>)[momento]#index("Momento") no estás seguro de tu posición exacta (Uncertainty of Position), mantén la calma y sigue este protocolo:

- #strong[No zigzaguees]: Mantén el rumbo que tenías. Si empiezas a dar vueltas a ciegas, te perderás más rápido y gastarás altura preciosa.
- #strong[Confía en tu estima]: Mira el reloj. Si llevas 10 minutos volando a 100 km/h, busca referencias a unos 15-20 km de tu último punto conocido.
- #strong[Busca "Handrails" (#link(<glosario-handrail>)[pasamanos]#index("Pasamanos"))]: Vuela hacia la referencia más grande y lineal que veas (una costa, una cordillera principal).

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
Si tienes radio y estás en contacto con un servicio #link(<glosario-atc>)[ATC]#index("ATC"), no dudes en preguntar: "Madrid, EC-XYZ, dudo de mi posición, solicito vector o confirmación". No hay vergüenza en pedir ayuda antes de que la situación sea crítica.

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
#strong[Resumen del capítulo: navegación en vuelo]

- #strong[Referencias Visuales]: Usa objetos grandes, lineales y con contraste (ríos, autopistas, líneas de costa). Oriente la carta siempre en el sentido del vuelo (lo que ves a la derecha en el suelo, a la derecha en el papel).
- #strong[Triangulación]: No te fíes de una sola referencia. Cruza al menos dos "líneas de posición" (ej. el cruce de una carretera y el eje de una montaña) para saber dónde estás con certeza.
- #strong[La Regla 1:60]: Si te desvías 1 #link(<glosario-milla-nautica>)[NM]#index("Milla náutica") de tu ruta tras haber volado 60 NM, tu error de rumbo es de 1º. Puedes usar esta proporción para corregir el rumbo mentalmente sin transportador.
- #strong[Incertidumbre de Posición]: Si te pierdes, NO SIGAS VOLANDO A CIEGAS. Mantén el rumbo, busca referencias grandes, confía en tu estima inicial y, si es necesario, vuela hacia un lugar conocido (un río, una costa) o aterriza con seguridad antes de quedarte sin altura.

]
= Uso de GNSS
<uso-de-gnss>
#quote(block: true)[
El Sistema Global de Navegación por Satélite (#link(<glosario-gnss>)[GNSS]#index("GNSS")) ---que agrupa redes como el #link(<glosario-gps>)[GPS]#index("GPS") estadounidense o el europeo Galileo--- ha cambiado por completo el vuelo a vela. Nos da posición, altitud y #link(<glosario-gs>)[velocidad suelo]#index("Velocidad suelo") con una precisión que hace años parecía impensable. Aun así, en el hangar lo resumimos en una frase: el GPS es un criado excelente, pero un amo pésimo.

En este capítulo aprenderás:

- #strong[Cómo funciona el GNSS]: por qué necesitas captar cuatro satélites para una posición en tres dimensiones.
- #strong[El #link(<glosario-datum>)[datum]#index("Datum") WGS-84]: el "idioma" #link(<glosario-norte-verdadero>)[geográfico]#index("Norte verdadero") común entre el receptor y la carta de papel.
- #strong[Los registradores #link(<glosario-igc>)[IGC]#index("Logger")]: la prueba digital del vuelo para validar récords y medallas FAI.
- #strong[Las limitaciones y fuentes de error]: por qué el GPS es una ayuda y nunca un sustituto de la carta.
]

== ¿Cómo funciona el GNSS?
<cómo-funciona-el-gnss>
Para que tu dispositivo te dé una posición tridimensional (#link(<glosario-latitud>)[latitud]#index("Latitud"), #link(<glosario-longitud>)[longitud]#index("Longitud") y altitud), necesita "ver" al menos #strong[4 satélites]. Con tres satélites sabría dónde estás sobre el mapa, pero no sabría a qué altura vuelas.

La mayoría de los receptores modernos combinan señales de varias constelaciones para mejorar la precisión: \* #strong[GPS]: El sistema original norteamericano. \* #strong[Galileo]: El sistema europeo, más reciente y con mayor precisión civil. \* #strong[GLONASS]: El sistema ruso.

=== El datum WGS-84
<el-datum-wgs-84>
Para que el GPS y la carta de papel se entiendan, deben usar el mismo "idioma" geográfico o #strong[Datum]. El estándar mundial que usamos es el #strong[WGS-84]. Asegúrate siempre de que tu dispositivo está configurado en este sistema; un datum incorrecto podría desplazar tu posición real varios cientos de metros respecto a lo que ves en pantalla.

#mas-alla[
== Los registradores IGC (loggers)
<los-registradores-igc-loggers>
#mas-alla-tag[#strong[↗ MÁS ALLÁ DEL EXAMEN.]] Los registradores IGC y la validación de récords y medallas FAI no deberían ser materia de examen. Se incluyen como iniciación al vuelo deportivo de distancia; no los estudies con la prioridad del resto del temario.

En el mundo del planeador, el GNSS no solo sirve para navegar. Usamos dispositivos certificados llamados #strong[registradores IGC] (#strong[Loggers]) que graban cada segundo de nuestro vuelo.

Estos archivos digitales (.igc) son la prueba de que has pasado por los puntos de viraje de una tarea y sirven para validar récords y medallas de la FAI. Al aterrizar, puedes volcar el vuelo en programas de análisis para aprender de tus decisiones y ver exactamente dónde encontraste esa #link(<glosario-termica>)[térmica]#index("Térmica") tan buena.

Los equipos modernos integran el GNSS con un #strong[mapa móvil] que muestra ruta, espacios aéreos y datos de planeo (#ref(<fig-09-cap06-gnss-cabina>, supplement: [Figura])).

#figure([
#box(image("09-navegacion/imagenes/09-cap06-gnss-cabina.jpg"))
], caption: figure.caption(
position: bottom, 
[
Dispositivo GNSS moderno integrado en el panel de un planeador
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap06-gnss-cabina>


]
== Limitaciones y conciencia situacional
<limitaciones-y-conciencia-situacional>
El GPS puede fallar. Y fallará en el #link(<glosario-momento>)[momento]#index("Momento") más inoportuno.

- #strong[Fallo de energía]: La batería de tu PDA o tablet puede agotarse o el cable de carga puede soltarse con las turbulencias.
- #strong[Pérdida de señal]: En valles profundos o debido a interferencias, puedes perder la cobertura de satélites temporalmente.
- #strong[#link(<glosario-base>)[Base]#index("Tramo de base") de datos desactualizada]: Si no actualizas los espacios aéreos de tu dispositivo, podrías entrar en una #link(<glosario-zona-prohibida>)[zona prohibida]#index("P de Prohibited") sin saberlo.

Además, la propia señal tiene fuentes de error que degradan la precisión aunque el equipo funcione: el #strong[retardo ionosférico y troposférico] (la señal se frena al atravesar la atmósfera), el #strong[#link(<glosario-multitrayecto>)[multitrayecto]#index("Multitrayecto")] (rebotes de la señal en el terreno o en estructuras), las pequeñas #strong[derivas de los relojes] y la #strong[geometría de los satélites] (si están mal repartidos en el cielo, la #strong[dilución de la precisión] o #link(<glosario-dop>)[DOP]#index("DOP") empeora). En condiciones normales la precisión ronda unos pocos metros, más que suficiente para volar, pero conviene saber que no es infalible.

#block[
#callout(
body: 
[
El GNSS no te exime de saber navegar visualmente: el vuelo #link(<glosario-vfr>)[VFR]#index("VFR") se apoya en referencias del terreno, con o sin pantalla. Y tenlo presente en el examen de pericia de la #link(<glosario-spl>)[SPL]#index("SPL"): el examinador puede apagarte el dispositivo para comprobar que sabes volver al aeródromo con el mapa y la brújula.

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
#strong[Resumen del capítulo: uso del GNSS (GPS)]

- #strong[Ayuda, no sustituto]: El GPS es una herramienta fabulosa para la #link(<glosario-conciencia-situacional>)[conciencia situacional]#index("Conciencia situacional"), pero nunca debe sustituir a la navegación visual y a la carta. Las baterías fallan, las señales se pierden y los dispositivos se cuelgan.
- #strong[Fuentes de Error]: El GPS puede fallar por falta de satélites (necesitas 4 para posición 3D), interferencias o errores en la base de datos. Verifica siempre que el destino y las coordenadas son correctos.
- #strong[Backup]: Lleva siempre una carta de papel y una brújula. Si el GPS muere en medio de un vuelo de distancia, debes ser capaz de volver a casa "a la vieja usanza".
- #strong[Configuración]: Asegúrate de que tu datum (usualmente WGS84) y las unidades (#link(<glosario-milla-nautica>)[NM]#index("Milla náutica"), kts, m) coinciden con tu planificación y con lo que esperas ver en los instrumentos.

]
= Uso de ATS
<uso-de-ats>
#quote(block: true)[
El vuelo a vela sabe a libertad, pero el cielo lo compartimos con mucho más tráfico. Los Servicios de Tránsito Aéreo (#link(<glosario-ats>)[ATS]#index("ATS")) están ahí para que esa convivencia sea segura y ordenada.

En este capítulo aprenderás:

- #strong[#link(<glosario-atc>)[ATC]#index("ATC") frente a #link(<glosario-fis>)[FIS]#index("FIS")]: quién da órdenes obligatorias y quién facilita información.
- #strong[El #link(<glosario-transpondedor>)[transpondedor]#index("Transpondedor")]: los códigos #link(<glosario-squawk>)[squawk]#index("Squawk") y cuándo es obligatorio llevarlo encendido.
- #strong[El plan de vuelo (#link(<glosario-fpl>)[FPL]#index("FPL"))]: cuándo es obligatorio, su ciclo de vida y por qué hay que cerrarlo al aterrizar.
- #strong[Los espacios aéreos especiales]: qué te exigen y qué servicios recibes en cada clase.
]

== ATC vs.~FIS: ¿quién es quién?
<atc-vs.-fis-quién-es-quién>
Conviene tener clara la diferencia entre "el control" y "la información":

- #strong[ATC (Control de Tráfico Aéreo)]: Su función es separar tráficos mediante instrucciones obligatorias. Interactuarás con ellos en aeródromos controlados y espacios aéreos de clase C y #link(<glosario-zonas-p>)[D]#index("Zonas P") (#ref(<fig-09-cap07-control-aereo>, supplement: [Figura])).
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
== El transpondedor: hazte visible
<el-transpondedor-hazte-visible>
El transpondedor es el equipo que permite a los radares del ATC "verte" e identificar tu altitud.

- #strong[Squawk 7000]: Es el código estándar para vuelos #link(<glosario-vfr>)[VFR]#index("VFR") en España.
- #strong[7700]: Emergencia general.
- #strong[7600]: Fallo de radio.
- #strong[7500]: Interferencia ilícita (secuestro).

#block[
#callout(
body: 
[
Si tu transpondedor está instalado y operativo, la práctica correcta es #strong[mantenerlo encendido y en modo "ALT"] (transmisión de altitud) para que el radar te vea. Su uso es #strong[obligatorio en las zonas de uso de transpondedor (#link(<glosario-tmz>)[TMZ]#index("TMZ")) y allí donde lo exijan la clase de espacio aéreo o el #link(<glosario-aip>)[AIP]#index("AIP")-España (ENR 1.6)] ---las clases A y C lo requieren, y la D generalmente; véase la tabla del #strong[Libro 1 --- Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (ATC)], capítulo 7---, y muy recomendable en cualquier espacio con tráfico. Solo en planeadores con batería muy limitada cabe valorar apagarlo fuera de esos espacios, y siempre como decisión deliberada: #strong[nunca en una TMZ, en espacio controlado ni en zonas de tráfico intenso].

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
<el-plan-de-vuelo-fpl-1>
El Plan de Vuelo (FPL) es tu contrato de seguridad con el sistema. En él indicas quién eres, qué planeador vuelas, tu ruta y cuánta autonomía tienes.

#block[
#callout(
body: 
[
Según el reglamento #strong[#link(<glosario-sera>)[SERA]#index("SERA")] (SERA.4001 b)), es obligatorio presentar un FPL si vas a cruzar fronteras, si se te presta servicio de control de tránsito aéreo (clases B, C y D) o si despegas o aterrizas en un aeródromo controlado. Ojo con la clase E: es espacio controlado, pero al VFR no se le presta servicio de control, así que no necesita plan de vuelo, ni radio, ni autorización. Y lo más importante de todo: si presentaste plan, #strong[DEBES notificar tu llegada] para cerrarlo. Si no lo haces, se activarán los servicios de búsqueda y rescate (#link(<glosario-sar>)[SAR]#index("SAR")) innecesariamente.

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
El plan no es un papel que se entrega y se olvida. Tiene un ciclo de vida con cuatro mensajes asociados que comunicas a la misma dependencia donde lo presentaste: #strong[DEP] (salida), #strong[DLA] (demora), #strong[CHG] (cambio) y #strong[CNL] (cancelación). Y, según el AIP (ENR 1.10), un FPL VFR debe presentarse con cierta antelación a la #link(<glosario-eobt>)[EOBT]#index("EOBT") (hora estimada fuera de calzos): típicamente al menos #strong[60 minutos antes] si solicitas servicio de control, o antes de la salida si solo pides información de vuelo y alerta.

#figure([
#box(image("09-navegacion/imagenes/09-cap07-atc.jpg"))
], caption: figure.caption(
position: bottom, 
[
Interacción con el control de tráfico aéreo
]), 
kind: "quarto-float-fig", 
supplement: "Figura", 
)
<fig-09-cap07-control-aereo>


== Operando en espacios especiales
<operando-en-espacios-especiales>
No todas las zonas del cielo son iguales:

- #strong[Clase G (Espacio fuera de control)]: Puedes volar libremente bajo reglas VFR sin radio obligatoria (aunque muy recomendada). Recibes servicio de información de vuelo (FIS).
- #strong[Clase E]: Controlado, pero el VFR #strong[no] necesita autorización ni radio obligatoria; recibes información de tráfico en la medida de lo posible.
- #strong[Clases C y D (Espacio Controlado)]: #strong[OBLIGATORIO] contacto radio y autorización previa del ATC para entrar. En clase C, además, el control separa tu VFR del tráfico #link(<glosario-ifr>)[IFR]#index("IFR")\; en clase D nadie te separa: solo recibes información de tráfico, y ver y evitar sigue siendo cosa tuya.
- #strong[Zonas Prohibidas/Restringidas (P/R)]: Evítalas a menos que tengas una autorización específica. Un "salto" de un segundo en una #link(<glosario-zona-prohibida>)[zona Prohibida]#index("P de Prohibited") puede acarrear sanciones graves.

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
#strong[Resumen del capítulo: uso de los ATS]

- #strong[Dependencias]: El ATC (Control) gestiona aeródromos y espacios controlados. El FIS (Información) te ayuda en ruta con meteo y tráfico. Mantén contacto con FIS cuando sea posible; es una capa extra de seguridad.
- #strong[Transpondedor]: Es tu #link(<glosario-cavok>)[visibilidad]#index("Visibilidad") para el radar. En VFR pon 7000. Si tienes una emergencia: 7700. Si pierdes la radio: 7600. Si está operativo, llévalo encendido y en ALT (obligatorio en TMZ y donde lo exija la clase de espacio aéreo --- AIP ENR 1.6); vigila el consumo de batería.
- #strong[Plan de Vuelo]: Fundamental para que te busquen si no llegas. Se activa al despegar y #strong[ES OBLIGATORIO notificar tu llegada] a la dependencia ATS del aeródromo de destino tan pronto como sea posible (SERA).
- #strong[Espacios Aéreos]: Conoce dónde estás. En Clase C o D necesitas autorización radio. En Clase G eres libre, pero el FIS sigue estando ahí para ayudarte.

]
#show: appendices.with("Apéndices", hide-parent: true)
#heading(level: 1, numbering: none)[Apéndices]
#heading(level: 1, numbering: none)[Syllabus oficial EASA]
<syllabus-oficial-easa>
El siguiente programa de estudios (Syllabus) unificado corresponde a la totalidad de las materias teóricas exigidas para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

#heading(level: 2, outlined: false, numbering: none)[1. Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (ATC)]
<derecho-aéreo-y-procedimientos-de-control-de-tránsito-aéreo-atc>
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

#heading(level: 3, outlined: false, numbering: none)[Ponte a prueba]
<ponte-a-prueba>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/01-derecho-aereo-atc/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

#heading(level: 2, outlined: false, numbering: none)[2. Factores Humanos]
<factores-humanos>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Factores Humanos] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- 2.1. Factores humanos: conceptos básicos.
- 2.2. Fisiología aeronáutica básica y mantenimiento de salud.
- 2.3. Psicología aeronáutica básica.
- 2.4. Uso de oxígeno.

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

#heading(level: 3, outlined: false, numbering: none)[Ponte a prueba]
<ponte-a-prueba-1>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/02-factores-humanos/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

#heading(level: 2, outlined: false, numbering: none)[3. Meteorología]
<meteorología>
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

#heading(level: 3, outlined: false, numbering: none)[Ponte a prueba]
<ponte-a-prueba-2>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/03-meteorologia/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

#heading(level: 2, outlined: false, numbering: none)[4. Comunicaciones]
<comunicaciones>
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

#heading(level: 3, outlined: false, numbering: none)[Ponte a prueba]
<ponte-a-prueba-3>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/04-comunicaciones/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

#heading(level: 2, outlined: false, numbering: none)[5. Principios de Vuelo]
<principios-de-vuelo>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Principios de Vuelo] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- 5.1. Aerodinámica (flujo de aire).
- 5.2. Mecánica de vuelo.
- 5.3. Estabilidad.
- 5.4. Control.
- 5.5. Limitaciones (factor de carga y maniobras).
- 5.6. Pérdida de sustentación (Stalling) y autorrotación (Spinning).
- 5.7. Picado en espiral (Spiral Dive).

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

#heading(level: 3, outlined: false, numbering: none)[Ponte a prueba]
<ponte-a-prueba-4>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/05-principios-vuelo/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

#heading(level: 2, outlined: false, numbering: none)[6. Procedimientos Operativos]
<procedimientos-operativos>
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

#heading(level: 3, outlined: false, numbering: none)[Ponte a prueba]
<ponte-a-prueba-5>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/06-procedimientos-operativos/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

#heading(level: 2, outlined: false, numbering: none)[7. Planificación y Rendimiento de Vuelo]
<planificación-y-rendimiento-de-vuelo>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Planificación y Rendimiento de Vuelo] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- #strong[7.1. Masa y centro de gravedad.]
- #strong[7.2. Polar de velocidades (Speed Polar) de planeadores o velocidad de crucero.]
- #strong[7.3. Planificación de vuelo y definición de tareas.]
- #strong[7.4. Plan de vuelo ICAO (ATS Flight Plan).]
- #strong[7.5. Monitoreo del vuelo y replanificación en vuelo.]

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

#heading(level: 3, outlined: false, numbering: none)[Ponte a prueba]
<ponte-a-prueba-6>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/07-planificacion-rendimiento/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

#heading(level: 2, outlined: false, numbering: none)[8. Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia]
<conocimientos-generales-de-la-aeronave-estructura-sistemas-y-equipo-de-emergencia>
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

#heading(level: 3, outlined: false, numbering: none)[Ponte a prueba]
<ponte-a-prueba-7>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/08-aeronave-sistemas/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

#heading(level: 2, outlined: false, numbering: none)[9. Navegación]
<navegación>
El siguiente programa de estudios (Syllabus) corresponde a la asignatura de #strong[Navegación] para la obtención de la licencia de piloto de planeador (SPL), conforme al AMC1 SFCL.130.

- 9.1. Fundamentos de navegación.
- 9.2. Magnetismo y brújulas.
- 9.3. Cartas aeronáuticas.
- 9.4. Navegación por estima (Dead Reckoning).
- 9.5. Navegación en vuelo.
- 9.6. Uso de GNSS.
- 9.7. Uso de ATS.

Este manual ha sido estructurado siguiendo fielmente este syllabus oficial para garantizar que cubres todos los puntos necesarios para el examen teórico.

#heading(level: 3, outlined: false, numbering: none)[Ponte a prueba]
<ponte-a-prueba-8>
La teoría se afianza respondiendo preguntas. Esta asignatura cuenta con su propio test de autoevaluación en línea, con preguntas tipo examen. Por ejemplo:

#link("https://vuelalibre.net/tests/09-navegacion/")

Consulta a tu instructor, quien te indicará cuál es el banco de preguntas o el formato más adecuado, y sigue su recomendación. Te será de gran utilidad tanto para afianzar los conocimientos de cada capítulo como para tu repaso general antes de presentarte al examen teórico.

= Glosario de términos
<glosario-de-términos>
Este glosario unificado contiene las definiciones y acrónimos más relevantes del marco normativo aeronáutico (EASA, OACI, normativa nacional) aplicables a la licencia de piloto de planeador (SPL) de todas las asignaturas.

/ #strong[ACC (Centro de Control de Área / Area Control Centre)] <glosario-acc>: #block[
Dependencia ATS que presta el servicio de control de área a los vuelos bajo su jurisdicción.
]

/ #strong[AD (Directiva de Aeronavegabilidad / Airworthiness Directive; Aeródromos)] <glosario-ad>: #block[
Abreviatura dependiente del contexto: una directiva de aeronavegabilidad es un requisito obligatorio para corregir una condición insegura; AD también identifica la sección de aeródromos del AIP.
]

/ #strong[ADM (Aeronautical Decision-Making)] <glosario-adm>: #block[
Toma de decisiones aeronáuticas. Proceso mental sistemático (por ejemplo, mediante el modelo DECIDE) empleado por el piloto para elegir la opción más segura como respuesta a un conjunto de circunstancias.
]

/ #strong[Aerofrenos (Spoilers)] <glosario-aerofrenos>: #block[
Superficies móviles situadas generalmente en el extradós alar, accionadas por el piloto, cuya función es destruir la sustentación y aumentar la resistencia aerodinámica para controlar la senda de aproximación.
]

/ #strong[Aerotow (Remolque por avión)] <glosario-aerotow>: #block[
Método de lanzamiento en el que una aeronave a motor remolca al planeador mediante un cable flexible de longitud normalizada (generalmente entre 30 y 60 metros) hasta una altitud determinada.
]

/ #strong[AESA (Agencia Estatal de Seguridad Aérea)] <glosario-aesa>: #block[
Autoridad española responsable de la supervisión de la seguridad de la aviación civil y de la aplicación de la normativa aeronáutica dentro de sus competencias.
]

/ #strong[AFIL (Airborne Flight Plan --- Plan de Vuelo en Vuelo)] <glosario-afil>: #block[
Plan de vuelo presentado desde el aire, sin haberlo tramitado antes del despegue. El piloto contacta con la dependencia ATC o FIS durante el vuelo para dar los datos del plan y solicitar entrada en espacio controlado.
]

/ #strong[AFIS (Aerodrome Flight Information Service)] <glosario-afis>: #block[
Servicio de información de aeródromo. El operador AFIS da a los pilotos información sobre viento, pista en uso y tráfico conocido, pero no emite autorizaciones ni controla el tráfico. La separación sigue siendo responsabilidad del piloto al mando.
]

/ #strong[AFM (Manual de Vuelo de la Aeronave / Aircraft Flight Manual)] <glosario-afm>: #block[
Documento aprobado que contiene las limitaciones, los procedimientos y los datos necesarios para operar la aeronave.
]

/ #strong[AGL (Sobre el nivel del terreno / Above Ground Level)] <glosario-agl>: #block[
Altura referida a la superficie del terreno situada debajo de la aeronave o del punto considerado.
]

/ #strong[AIC (Circular de Información Aeronáutica / Aeronautical Information Circular)] <glosario-aic>: #block[
Publicación con información aeronáutica que no reúne las condiciones para incluirla en el AIP o en un NOTAM.
]

/ #strong[AIP (Publicación de Información Aeronáutica / Aeronautical Information Publication)] <glosario-aip>: #block[
Publicación oficial que contiene información aeronáutica duradera y esencial para la navegación aérea, organizada en Generalidades (GEN), En Ruta (ENR) y Aeródromos (AD).
]

/ #strong[AIRAC (Reglamentación y Control de la Información Aeronáutica / Aeronautical Information Regulation and Control)] <glosario-airac>: #block[
Sistema de fechas comunes para publicar y hacer efectivos cambios aeronáuticos importantes y previsibles.
]

/ #strong[AIREP (Aircraft Report --- Informe Meteorológico en Vuelo)] <glosario-airep>: #block[
Informe meteorológico oral que el piloto transmite por radio al FIS o ATC al encontrar condiciones peligrosas no pronosticadas: turbulencia fuerte, engelamiento severo, ondas orográficas intensas, tormentas o ceniza volcánica. Obligatorio conforme al Reglamento SERA y la normativa EASA Part-SAO.
]

/ #strong[AIRMET (Airmen's Meteorological Information)] <glosario-airmet>: #block[
Mensaje de información meteorológica para la aviación que alerta de fenómenos en ruta significativos para aeronaves que vuelan por debajo del FL100 (o FL150 en zonas montañosas). De especial relevancia para el vuelo VFR sin motor.
]

/ #strong[AIS (Servicio de Información Aeronáutica / Aeronautical Information Service)] <glosario-ais>: #block[
Servicio encargado de facilitar la información aeronáutica necesaria para la seguridad, regularidad y eficiencia de la navegación aérea.
]

/ #strong[ALERFA (Fase de alerta / Alert Phase)] <glosario-alerfa>: #block[
Fase declarada cuando existe preocupación por la seguridad de una aeronave y sus ocupantes.
]

/ #strong[ALRS (Servicio de alerta / Alerting Service)] <glosario-alrs>: #block[
Servicio ATS que notifica a los organismos correspondientes las aeronaves que necesitan búsqueda y salvamento y coopera con ellos.
]

/ #strong[Altocúmulo lenticular (ACSL)] <glosario-altocumulo-lenticular>: #block[
Nube en forma de lenteja o platillo, estacionaria respecto al terreno a pesar de los vientos intensos. Su presencia indica flujo laminar de onda de montaña en la vertical. Es la señal visual que invita al vuelo de onda.
]

/ #strong[Altura de decisión (Decision Height / DH)] <glosario-altura-de-decision>: #block[
Límite de altura preestablecido sobre el terreno por debajo del cual el piloto abandona la búsqueda de térmicas y se centra exclusivamente en el aterrizaje. En travesía se aplica como escalera: a 600 metros se elige la zona de aterrizaje, a 450 metros el campo definitivo y a 300 metros el piloto se compromete con el circuito.
]

/ #strong[AMA (Altitud Mínima de Área)] <glosario-ama>: #block[
Cifra impresa en cada cuadrícula de la carta (paralelos y meridianos cada 30') que indica una altitud de seguridad sobre el obstáculo más alto del recuadro, con un margen mínimo de 1000 ft (2000 ft en alta montaña). Se lee como millares y centenares de pies.
]

/ #strong[AMC (Medios Aceptables de Cumplimiento / Acceptable Means of Compliance)] <glosario-amc>: #block[
Medios no vinculantes publicados por EASA que ofrecen una forma reconocida de demostrar el cumplimiento de una norma.
]

/ #strong[AME (Médico Examinador Aéreo / Aero-Medical Examiner)] <glosario-ame>: #block[
Médico autorizado para realizar reconocimientos y emitir o tramitar certificados médicos aeronáuticos dentro de sus atribuciones.
]

/ #strong[Amerizaje (Ditching)] <glosario-amerizaje>: #block[
Aterrizaje forzoso y controlado de una aeronave terrestre sobre una superficie de agua.
]

/ #strong[AMP (Programa de Mantenimiento de la Aeronave / Aircraft Maintenance Programme)] <glosario-amp>: #block[
Programa que establece las tareas y los intervalos de mantenimiento aplicables a una aeronave.
]

/ #strong[AMSL (Sobre el nivel medio del mar / Above Mean Sea Level)] <glosario-amsl>: #block[
Altitud referida al nivel medio del mar.
]

/ #strong[ANDS (Error de aceleración de la brújula)] <glosario-ands>: #block[
Regla mnemotécnica inglesa #emph[Accelerate North, Decelerate South]: en rumbos Este u Oeste, al acelerar la brújula tiende a marcar viraje al Norte y al decelerar, al Sur.
]

/ #strong[Anticiclón (H)] <glosario-anticiclon>: #block[
Sistema de alta presión caracterizado por subsidencia (descenso suave y divergente del aire). Al descender, el aire se comprime y calienta, inhibiendo el desarrollo de nubes convectivas. En verano favorece las térmicas aunque limita su techo; en invierno puede atrapar nieblas y crear inversiones persistentes.
]

/ #strong[APP (Control de Aproximación / Approach Control)] <glosario-app>: #block[
Dependencia ATS que presta servicio de control a los vuelos controlados que llegan a uno o más aeródromos o salen de ellos.
]

/ #strong[ARC (Certificado de Revisión de la Aeronavegabilidad / Airworthiness Review Certificate)] <glosario-arc>: #block[
Certificado que acredita que la aeronave ha superado la revisión de aeronavegabilidad exigida y mantiene su validez durante el periodo aplicable.
]

/ #strong[ASM (Gestión del espacio aéreo / Airspace Management)] <glosario-asm>: #block[
Función que administra el uso del espacio aéreo según las necesidades de sus distintos usuarios.
]

/ #strong[ATC (Control de Tránsito Aéreo / Air Traffic Control)] <glosario-atc>: #block[
Servicio de tránsito aéreo destinado a prevenir colisiones y a acelerar y mantener ordenadamente el movimiento del tránsito aéreo.
]

/ #strong[ATCO (Controlador de Tránsito Aéreo / Air Traffic Control Officer)] <glosario-atco>: #block[
Persona habilitada para prestar servicios de control de tránsito aéreo dentro de sus atribuciones.
]

/ #strong[ATFM (Gestión de Afluencia del Tránsito Aéreo / Air Traffic Flow Management)] <glosario-atfm>: #block[
Función que ajusta la demanda de tránsito aéreo a la capacidad disponible del sistema.
]

/ #strong[ATIS (Automatic Terminal Information Service --- Servicio Automático de Información Terminal)] <glosario-atis>: #block[
Grabación de voz en bucle continuo en una frecuencia VHF propia del aeródromo. Informa de la pista en servicio, condiciones meteorológicas (viento, visibilidad, nubes, QNH) e información operativa (obras, NOTAM, etc.). Cada boletín lleva una letra del alfabeto fonético que cambia cuando hay novedades significativas. Escúchalo antes de llamar a la Torre.
]

/ #strong[ATM (Gestión del Tránsito Aéreo / Air Traffic Management)] <glosario-atm>: #block[
Gestión integrada del tránsito y del espacio aéreo mediante los servicios de tránsito aéreo (ATS), la gestión del espacio aéreo (ASM) y la gestión de afluencia (ATFM).
]

/ #strong[Atmósfera Estándar Internacional (ISA)] <glosario-atmosfera-estandar-internacional>: #block[
Modelo idealizado de referencia que define los valores estándar de presión (1013,25 hPa), temperatura (15 °C) y densidad del aire a nivel del mar, con un gradiente térmico estándar de 2 °C/1.000 ft. Es la base de calibración de todos los instrumentos aeronáuticos.
]

/ #strong[ATS (Servicios de Tránsito Aéreo / Air Traffic Services)] <glosario-ats>: #block[
Término genérico que engloba el control de tránsito aéreo (ATC), el servicio de información de vuelo (FIS) y el servicio de alerta (ALRS).
]

/ #strong[ATZ (Zona de tránsito de aeródromo / Aerodrome Traffic Zone)] <glosario-atz>: #block[
Espacio aéreo de dimensiones definidas establecido alrededor de un aeródromo para la protección de su tránsito.
]

/ #strong[AUT / TUE (Autorización de Uso Terapéutico)] <glosario-aut>: #block[
#strong[Therapeutic Use Exemption]. Permiso oficial emitido por una organización antidopaje o autoridad aeronáutica (como WADA) que permite a un piloto de competición utilizar una medicación específica que normalmente requeriría su suspensión en un control antidopaje, salvaguardando su salud de base.
]

/ #strong[Autoinformación (broadcast)] <glosario-autoinformacion>: #block[
En aeródromos no controlados, cada piloto transmite voluntariamente su posición, altitud e intenciones en la frecuencia del aeródromo. No hay interlocutor que emita autorizaciones: la separación depende de todos los pilotos en la frecuencia.
]

/ #strong[AWY (Aerovía / Airway)] <glosario-awy>: #block[
Área de control o parte de ella dispuesta en forma de corredor.
]

/ #strong[Bail-out (Abandono del planeador)] <glosario-bail-out>: #block[
Procedimiento de emergencia que consiste en el salto en paracaídas desde una aeronave en vuelo cuando esta ya no es controlable o segura.
]

/ #strong[Base (Tramo de base / Base leg)] <glosario-base>: #block[
Tramo del circuito de tráfico perpendicular a la prolongación del eje de la pista que conecta el tramo de viento en cola con el tramo final.
]

/ #strong[Bernoulli, teorema de] <glosario-bernoulli-teorema-de>: #block[
Principio de la física de fluidos que establece que, en un fluido en movimiento, un aumento de la velocidad del flujo se corresponde con una disminución de la presión estática. En aerodinámica explica parte de la sustentación: el aire que acelera sobre el extradós genera una zona de baja presión que aspira el ala hacia arriba. Se complementa con el efecto acción-reacción de Newton (deflexión del flujo hacia abajo en el borde de salida).
]

/ #strong[Borrasca (Depresión / L)] <glosario-borrasca>: #block[
Sistema de baja presión atmosférica caracterizado por convergencia de aire en superficie que fuerza el ascenso, el enfriamiento y la formación de nubes, frentes y precipitación. Los vientos en superficie circulan en sentido antihorario en el hemisferio norte. La zona post-frontal es a menudo la más favorable para el vuelo a vela.
]

/ #strong[Brazo de palanca (Arm)] <glosario-brazo-de-palanca>: #block[
Distancia horizontal medida desde el datum (línea de referencia) hasta el centro de gravedad de un elemento o peso a bordo del planeador.
]

/ #strong[Brisa anabática (viento anabático)] <glosario-brisa-anabatica>: #block[
Corriente de aire ascendente que se desarrolla de día a lo largo de las laderas de montaña cuando el sol calienta las vertientes orientadas al sur antes que el fondo del valle. Es una de las principales fuentes de térmicas en terreno montañoso.
]

/ #strong[Brisa catabática (viento catabático)] <glosario-brisa-catabatica>: #block[
Corriente de aire descendente que se forma al atardecer y durante la noche cuando el aire en contacto con las laderas se enfría por radiación y desciende por gravedad. En la restitución de ambas laderas puede generar ascendencias suaves en el centro del valle.
]

/ #strong[Brisa marina (sea breeze)] <glosario-brisa-marina>: #block[
Viento que sopla desde el mar hacia la tierra durante el día, originado por el calentamiento diferencial entre la superficie terrestre (que se calienta más rápido) y el mar. Al encontrarse con la masa cálida continental genera una línea de convergencia que puede explotarse como fuente de ascendencias para el cross-country.
]

/ #strong[CAA (Autoridad de Aviación Civil / Civil Aviation Authority)] <glosario-caa>: #block[
Denominación genérica de la autoridad aeronáutica de un Estado; en España, las competencias se reparten principalmente entre la DGAC y AESA.
]

/ #strong[Cable flojo (Slack line)] <glosario-cable-flojo>: #block[
Pérdida temporal de tensión en el cable de remolque durante el lanzamiento por avión, lo que puede provocar enredos o tirones violentos al tensarse de nuevo.
]

/ #strong[Cadena del error] <glosario-cadena-del-error>: #block[
Sucesión de pequeñas decisiones erróneas, condiciones previas y errores latentes que, al alinearse e interactuar (como en el #strong[modelo del queso suizo]), desencadenan un accidente o incidente.
]

/ #strong[CAMO (Organización de Gestión del Mantenimiento de la Aeronavegabilidad Continuada / Continuing Airworthiness Management Organisation)] <glosario-camo>: #block[
Organización aprobada para gestionar la aeronavegabilidad continuada de aeronaves dentro de sus atribuciones.
]

/ #strong[CAO (Organización Combinada de Aeronavegabilidad / Combined Airworthiness Organisation)] <glosario-cao>: #block[
Organización aprobada que puede ejercer privilegios de mantenimiento y de gestión de la aeronavegabilidad continuada dentro de su ámbito de aprobación.
]

/ #strong[Capa límite] <glosario-capa-limite>: #block[
Delgada capa de aire que fluye directamente en contacto con la superficie del ala, donde la velocidad cae gradualmente desde la del flujo libre hasta cero en la superficie sólida. Puede ser #strong[laminar] (flujo ordenado, mínima resistencia) o #strong[turbulenta] (flujo caótico, mayor resistencia). El punto de transición entre ambos regímenes determina el rendimiento del perfil: un simple mosquito aplastado en el borde de ataque puede adelantarlo y degradar el planeo de forma medible.
]

/ #strong[CAPE (Convective Available Potential Energy)] <glosario-cape>: #block[
Energía Potencial Convectiva Disponible. Cuantifica la flotabilidad acumulada de una parcela de aire desde la superficie hasta el nivel de equilibrio. Se representa como el área entre la curva de la parcela y la curva de estado en el sondeo termodinámico. Valores orientativos: \< 500 J/kg (día débil), 1.000--2.500 J/kg (excelente), \> 3.500 J/kg (convección severa probable).
]

/ #strong[Carga alar] <glosario-carga-alar>: #block[
Relación entre la masa total del planeador y la superficie de sus alas. Se expresa en kg/m² e influye directamente en las velocidades de crucero y de pérdida.
]

/ #strong[Carga de rotura (Ultimate load)] <glosario-carga-de-rotura>: #block[
Carga a la que la estructura falla de forma catastrófica. Se obtiene multiplicando la carga límite por el factor de seguridad de 1,5 establecido en CS 22.303.
]

/ #strong[Carga límite (Limit load)] <glosario-carga-limite>: #block[
Carga máxima que la estructura puede soportar sin sufrir deformación permanente. Tras alcanzarla, la aeronave debe recuperar su forma original sin daños.
]

/ #strong[CAVOK (Visibilidad, nubes y tiempo presente mejores que los valores o condiciones prescritos)] <glosario-cavok>: #block[
Término de los informes meteorológicos que sustituye determinados datos de visibilidad, tiempo presente y nubes cuando se cumplen simultáneamente las condiciones establecidas.
]

/ #strong[CDR (Ruta condicional / Conditional Route)] <glosario-cdr>: #block[
Ruta ATS disponible únicamente cuando se cumplen las condiciones publicadas.
]

/ #strong[Centro de Presiones (CP)] <glosario-centro-de-presiones>: #block[
Punto de la cuerda aerodinámica donde se considera aplicado el vector resultante de la sustentación total del ala. No es fijo: se desplaza hacia adelante al aumentar el ángulo de ataque y hacia atrás al disminuirlo. Su movilidad obliga a situar el CG delante de su rango de movimiento para mantener la estabilidad longitudinal.
]

/ #strong[CG (Centro de gravedad)] <glosario-cg>: #block[
Punto teórico donde se considera aplicada la resultante de todas las fuerzas de gravedad que actúan sobre el planeador. Su ubicación longitudinal es clave para la estabilidad y el control del vuelo.
]

/ #strong[CIAIAC (Comisión de Investigación de Accidentes e Incidentes de Aviación Civil)] <glosario-ciaiac>: #block[
Organismo oficial español encargado de investigar accidentes e incidentes graves de aviación civil con finalidad preventiva.
]

/ #strong[Cianosis] <glosario-cianosis>: #block[
Coloración azulada en la piel, labios y yemas de los dedos producida por una acusada deficiencia de oxígeno en la sangre, siendo uno de los síntomas físicos avanzados propios de la hipoxia.
]

/ #strong[Cinetosis] <glosario-cinetosis>: #block[
Mareo producido por el movimiento (#strong[motion sickness]), desencadenado en vuelo por un conflicto entre la información percibida por el sistema visual (que observa una cabina inmóvil) y el sistema vestibular del oído interno (que registra las aceleraciones y giros de la aeronave).
]

/ #strong[Circuito de tráfico (Circuito de aeródromo)] <glosario-circuito-de-trafico>: #block[
Trayectoria patrón y ordenada que describe una aeronave para realizar una aproximación y aterrizaje seguro. En planeadores consta típicamente de viento cruzado, viento en cola, base y final.
]

/ #strong[Cizalladura (wind shear)] <glosario-cizalladura>: #block[
Variación brusca de la velocidad y/o dirección del viento en una distancia corta, tanto en el plano horizontal como vertical. Especialmente peligrosa en la aproximación final, donde puede provocar una pérdida súbita de sustentación por caída de la velocidad indicada.
]

/ #strong[CoA (Certificado de Aeronavegabilidad)] <glosario-coa>: #block[
Documento que certifica que una aeronave se ajusta al diseño aprobado y se considera apta para el vuelo mientras se mantenga aeronavegable y cumpla los requisitos aplicables.
]

/ #strong[CofA (Certificado de Aeronavegabilidad / Certificate of Airworthiness)] <glosario-cofa>: #block[
Documento que certifica que una aeronave se ajusta al diseño aprobado y se considera apta para el vuelo mientras se mantenga aeronavegable y cumpla los requisitos aplicables.
]

/ #strong[Colación (readback)] <glosario-colacion>: #block[
El piloto repite textualmente al controlador las instrucciones o autorizaciones recibidas, confirmando que las ha escuchado y entendido. Obligatoria para autorizaciones de pista, rumbos, altitudes, QNH, códigos de transpondedor y cambios de frecuencia. Responder solo «Recibido» o «Wilco» en estos casos es una desviación del procedimiento OACI/EASA.
]

/ #strong[Collado barométrico (pantano barométrico)] <glosario-collado-barometrico>: #block[
Región de transición entre dos anticiclones y dos borrascas opuestas en la que el gradiente de presión es prácticamente nulo. Genera vientos flojos y variables, visibilidad reducida por niebla o bruma en invierno, y riesgo de tormentas locales aisladas en verano.
]

/ #strong[Compensador (Trim)] <glosario-compensador>: #block[
Dispositivo (de muelles o de pestaña aerodinámica) que alivia la presión que el piloto debe mantener sobre la palanca para conservar una velocidad determinada. Se acciona con el mando verde o un pulsador eléctrico.
]

/ #strong[Complacencia] <glosario-complacencia>: #block[
Estado mental limitante originado por la rutina y la familiaridad con el entorno, que genera una falsa sensación de seguridad e induce a omitir procedimientos básicos como las listas de comprobación.
]

/ #strong[Composite (Material compuesto)] <glosario-composite>: #block[
Material formado por fibras (vidrio o carbono) embebidas en resina. Domina la construcción de planeadores modernos por su relación resistencia/peso y su acabado aerodinámico liso (GRP: fibra de vidrio; CRP: fibra de carbono).
]

/ #strong[Conciencia situacional] <glosario-conciencia-situacional>: #block[
#strong[Situational Awareness]. Percepción completa y asimilación adecuada de los elementos del vuelo en el presente, comprensión analítica de su estatus actual y proyección fiel de su tendencia hacia el futuro.
]

/ #strong[CPL (Licencia de Piloto Comercial / Commercial Pilot Licence)] <glosario-cpl>: #block[
Licencia que permite ejercer atribuciones de piloto comercial dentro de las condiciones aplicables; no existe una CPL(S) independiente para planeadores.
]

/ #strong[Crepúsculo civil] <glosario-crepusculo-civil>: #block[
Periodo de transición entre el día y la noche. Para la aviación, la noche comienza al final del crepúsculo civil vespertino y termina al inicio del matutino, cuando el centro del sol está 6º por debajo del horizonte.
]

/ #strong[CS (Especificaciones de Certificación / Certification Specifications)] <glosario-cs>: #block[
Especificaciones técnicas empleadas en la certificación de aeronaves, productos y equipos.
]

/ #strong[CS-22 (Especificaciones de Certificación para Planeadores y Planeadores Propulsados / Certification Specifications for Sailplanes and Powered Sailplanes)] <glosario-cs-22>: #block[
Especificaciones EASA aplicables al diseño y la certificación de planeadores y planeadores propulsados.
]

/ #strong[CTA (Área de control / Control Area)] <glosario-cta>: #block[
Espacio aéreo controlado que se extiende hacia arriba desde un límite especificado sobre el terreno.
]

/ #strong[CTR (Zona de control / Control Zone)] <glosario-ctr>: #block[
Espacio aéreo controlado que se extiende hacia arriba desde la superficie terrestre hasta un límite superior definido.
]

/ #strong[Cultura justa (Just Culture)] <glosario-cultura-justa>: #block[
Paradigma organizacional que reconoce la inevitabilidad del error humano no intencionado, tratándolo como una oportunidad de aprendizaje colectivo sin represalias, oponiéndose a todo encubrimiento o sanción punitiva irracional.
]

/ #strong[Cumulonimbus (Cb)] <glosario-cumulonimbus>: #block[
Nube de desarrollo vertical extremo que puede alcanzar la tropopausa. Representa el peligro meteorológico más grave para la aviación ligera: turbulencia severa, granizo, rayos, lluvia torrencial y microbursts. La distancia de seguridad recomendada es de al menos 10--20 NM.
]

/ #strong[Curva polar] <glosario-curva-polar>: #block[
Gráfica característica de cada modelo de planeador que relaciona la velocidad horizontal indicada (eje X, en km/h) con la tasa de descenso vertical (eje Y, en m/s) en condiciones de aire en calma. De ella se extraen la velocidad de mínimo descenso (vértice superior) y la velocidad de mejor planeo (tangente desde el origen). Es el "DNI" del planeador y la referencia para adaptar la velocidad al viento y a las zonas de ascenso o descenso.
]

/ #strong[Cúmulo (Cu)] <glosario-cumulo>: #block[
Nube convectiva de desarrollo vertical con base plana y contornos bien definidos. Su presencia indica inestabilidad y térmicas activas. La base de los cúmulos marca el nivel de condensación por ascenso (NCA/LCL) y puede calcularse con la fórmula: (T − Td) × 400 = altitud en pies.
]

/ #strong[Cúmulo congestus (Cu con)] <glosario-cumulo-congestus>: #block[
Fase de desarrollo vertical intenso del cúmulo, previa al cumulonimbus. Sus torres de "coliflor" con contornos aún definidos señalan convección vigorosa y riesgo de sobredesarrollo hacia Cb. Cuando la parte superior pierde definición y se hace fibrosa, el Cb ya está en marcha.
]

/ #strong[Cúpula (Canopy)] <glosario-cupula>: #block[
Cubierta transparente de plexiglás de la cabina. Incorpora pestillos de bloqueo, ventilación y un mecanismo de suelta de emergencia que libera la cúpula completa para permitir el salto en paracaídas.
]

/ #strong[DALR (Dry Adiabatic Lapse Rate)] <glosario-dalr>: #block[
Gradiente Adiabático Seco. Ritmo al que se enfría una parcela de aire sin saturar al ascender adiabáticamente: 3 °C por cada 1.000 ft. Es la clave del efecto Foehn en sotavento y de la fórmula de base de nubes.
]

/ #strong[DANA (Depresión Aislada en Niveles Altos)] <glosario-dana>: #block[
Sistema de baja presión que se desprende de la circulación general y queda aislado en altura sobre la Península Ibérica, especialmente en otoño. Genera precipitaciones intensas y tormentas severas que pueden durar días. Especialmente relevante en el área mediterránea.
]

/ #strong[Datum (Línea de referencia)] <glosario-datum>: #block[
Plano vertical imaginario a partir del cual se miden todas las distancias horizontales para calcular el centrado y el brazo de palanca de los componentes del planeador.
]

/ #strong[Datum WGS-84 (World Geodetic System 1984)] <glosario-datum-wgs-84>: #block[
Sistema geodésico de referencia mundial sobre el que el GNSS y la cartografía expresan las coordenadas. Configurar el receptor en un datum distinto puede desplazar la posición mostrada varios cientos de metros.
]

/ #strong[DECIDE] <glosario-decide>: #block[
Modelo estandarizado para la toma de decisiones aeronáuticas: Detectar, Estudiar, Considerar, Implementar, Determinar y Evaluar.
]

/ #strong[Deriva] <glosario-deriva>: #block[
Desviación lateral de la trayectoria del planeador respecto al suelo provocada por el viento de costado (en navegación). En aerodinámica, se refiere a la superficie fija vertical de la cola (estabilizador vertical) que aporta estabilidad de guiñada.
]

/ #strong[Desorientación espacial] <glosario-desorientacion-espacial>: #block[
Falsa apreciación de la posición, actitud o movimiento de la aeronave como consecuencia de ilusiones sensoriales originadas en el oído interno, obligando al piloto a desconfiar de sus sentidos y ampararse en los instrumentos.
]

/ #strong[Desvío] <glosario-desvio>: #block[
Error local de la brújula causado por los campos magnéticos del propio planeador (tubos de acero, radio, instrumentos). Se corrige consultando la tablilla de desvíos de la cabina.
]

/ #strong[DETRESFA (Fase de peligro / Distress Phase)] <glosario-detresfa>: #block[
Fase declarada cuando existe certeza razonable de que una aeronave y sus ocupantes están amenazados por un peligro grave e inminente y necesitan ayuda inmediata.
]

/ #strong[DGAC (Dirección General de Aviación Civil)] <glosario-dgac>: #block[
Órgano directivo encargado de formular la política del sector aéreo y ejercer las funciones que le atribuye la normativa española.
]

/ #strong[Diagrama V-n (envolvente de vuelo)] <glosario-diagrama-v-n>: #block[
Representación gráfica de los límites estructurales del planeador que relaciona la velocidad (V) con el factor de carga en Gs (n). Define la "caja" de operaciones seguras: dentro de la envolvente la estructura aguanta; fuera, se producen deformaciones permanentes o roturas. Según CS-22: categoría U (#emph[Utility]) soporta de +5,3g a −2,65g a la velocidad V#sub[A], límites que se estrechan a +4,0g y −1,5g a V#sub[D]\; categoría A (#emph[Acrobática]) de +7,0g a −5,0g. Estos límites solo son válidos respetando también los límites de velocidad.
]

/ #strong[Diedro (ángulo diedro)] <glosario-diedro>: #block[
Ángulo hacia arriba que forman las alas respecto al plano horizontal, dando al planeador una forma de "V" abierta vista de frente. Proporciona estabilidad lateral: cuando un ala baja por una perturbación, recibe el flujo de aire con mayor ángulo de ataque efectivo, genera más sustentación y vuelve a la posición nivelada sin intervención del piloto.
]

/ #strong[Disbarismos (Barotraumas)] <glosario-disbarismos>: #block[
Alteraciones orgánicas o dolor neurálgico originados por la expansión y contracción de pequeños volúmenes de gas atrapados en el cuerpo (senos paranasales, oído medio, intestinos) frente a los inevitables cambios en la presión atmosférica por la Ley de Boyle.
]

/ #strong[DME (Equipo Radiotelemétrico / Distance Measuring Equipment)] <glosario-dme>: #block[
Radioayuda que permite a una aeronave determinar la distancia oblicua respecto de una estación terrestre.
]

/ #strong[DOP (Dilución de la precisión)] <glosario-dop>: #block[
Degradación de la precisión del GNSS debida a la geometría de los satélites visibles: cuando están mal repartidos en el cielo, la posición calculada es menos precisa.
]

/ #strong[Dorsal (cuña de altas presiones / ridge)] <glosario-dorsal>: #block[
Extensión de un anticiclón en forma de lengua hacia una zona de menor presión. Comparte las características del sistema origen: subsidencia, cielos despejados, buen tiempo y ausencia de ascendencias convectivas.
]

/ #strong[Downburst (microburst / microrráfaga)] <glosario-downburst>: #block[
Corriente descendente violenta generada bajo un cumulonimbus o cúmulo congestus al precipitar. Al impactar con el suelo se expande horizontalmente en todas direcciones. Particularmente peligroso en la aproximación final: primero genera un viento de cara falso (ganancia de sustentación engañosa) y segundos después un viento de cola que puede provocar el impacto con el terreno.
]

/ #strong[EASA (Agencia de la Unión Europea para la Seguridad Aérea / European Union Aviation Safety Agency)] <glosario-easa>: #block[
Agencia de la Unión Europea que desarrolla y supervisa el marco común de seguridad de la aviación civil dentro de sus competencias.
]

/ #strong[EDS (Sistema de Oxígeno a Demanda / Electronic Delivery System)] <glosario-eds>: #block[
Sistema electrónico de suministro de oxígeno a demanda que detecta la inspiración del piloto y libera un pulso de oxígeno en ese instante, multiplicando la autonomía de la botella de oxígeno al interrumpir el flujo durante la exhalación.
]

/ #strong[EET (Duración prevista / Estimated Elapsed Time)] <glosario-eet>: #block[
Tiempo que se estima necesario para llegar desde un punto de referencia a otro durante un vuelo.
]

/ #strong[Efecto Foehn (Foehn effect)] <glosario-efecto-foehn>: #block[
Fenómeno por el que el aire que asciende en barlovento de una cordillera precipita y cede calor latente (siguiendo el SALR en la zona de nube), pero desciende en sotavento completamente seco, calentándose al DALR completo durante todo el descenso. La diferencia de temperatura entre los dos valles puede superar los 10--15 °C. La pared de Foehn (#strong[Foehn wall]) es la acumulación de nubes estacionaria sobre la cresta en barlovento.
]

/ #strong[Efecto veleta] <glosario-efecto-veleta>: #block[
Tendencia del planeador a alinearse automáticamente con la dirección del viento relativo gracias a la deriva. La distancia entre el CG y la deriva actúa como brazo de palanca que amplifica la fuerza correctora. Es el mecanismo que proporciona la estabilidad direccional del planeador.
]

/ #strong[Eficacia de mando] <glosario-eficacia-de-mando>: #block[
Grado de respuesta de las superficies de control en función de la velocidad de vuelo. A alta velocidad, la presión dinámica es mayor y los mandos están duros y muy reactivos. A baja velocidad, disminuye y los mandos se vuelven blandos o "chiclosos". Esta pérdida de eficacia próxima a la velocidad de pérdida es una advertencia física directa: el ala se acerca al ángulo de ataque crítico.
]

/ #strong[ELT (Transmisor Localizador de Emergencia / Emergency Locator Transmitter)] <glosario-elt>: #block[
Baliza de aeronave destinada a transmitir una señal de emergencia y facilitar su localización.
]

/ #strong[Energía total (Variómetro de energía total / TE)] <glosario-energia-total>: #block[
Variómetro compensado (mediante sonda o antena TE) que descuenta las variaciones de altura provocadas por los cambios de velocidad del propio piloto, indicando únicamente el movimiento real de la masa de aire.
]

/ #strong[Engelamiento (icing)] <glosario-engelamiento>: #block[
Formación de hielo en las superficies del planeador al volar en zonas con humedad visible y temperatura negativa (especialmente entre 0 °C y −15 °C). Altera el perfil alar, aumenta la velocidad de pérdida (#strong[stall speed]) y puede opacificar la cúpula. Los planeadores no disponen de sistemas antihielo: la medida correctiva es descender a niveles de temperatura positiva.
]

/ #strong[EOBT (Hora estimada fuera de calzos / Estimated Off-Block Time)] <glosario-eobt>: #block[
Hora prevista en la que la aeronave iniciará el movimiento asociado a la salida.
]

/ #strong[Error de viraje (regla "NO me paso / SÍ me paso")] <glosario-error-de-viraje>: #block[
Error de la brújula al virar hacia rumbos Norte o Sur por efecto del #emph[dip] magnético: al Norte la brújula se queda atrás (hay que sacar el viraje antes, "NO me paso") y al Sur se adelanta (hay que dejarla pasar, "SÍ me paso").
]

/ #strong[Escala] <glosario-escala>: #block[
Relación entre una distancia medida en la carta y la distancia real en el terreno. En la carta VFR estándar 1:500.000, 1 cm equivale a 5 km.
]

/ #strong[Espacio aéreo controlado] <glosario-espacio-aereo-controlado>: #block[
Volumen de espacio aéreo (clases A a E) en el que se presta servicio de control. En clases C y D el VFR necesita autorización ATC y comunicación radio para entrar.
]

/ #strong[Estabilidad atmosférica] <glosario-estabilidad-atmosferica>: #block[
Propiedad de la atmósfera que describe la tendencia de una parcela de aire desplazada verticalmente a regresar a su posición original (estable) o a continuar alejándose (inestable). El vuelo a vela vive de la inestabilidad. Una atmósfera estable impide el desarrollo de térmicas; una inestable las fomenta.
]

/ #strong[Estabilidad condicional] <glosario-estabilidad-condicional>: #block[
Estado de la atmósfera que es estable para parcelas de aire seco pero inestable para parcelas saturadas. Si el aire asciende lo suficiente para condensar, el calor latente liberado lo mantiene más caliente que el entorno y la inestabilidad se dispara. Es la clave del sobredesarrollo de cúmulos hacia cumulonimbus en días húmedos.
]

/ #strong[Estabilidad dinámica] <glosario-estabilidad-dinamica>: #block[
Comportamiento de la aeronave en el tiempo tras una perturbación. Si las oscilaciones se amortiguan progresivamente, la estabilidad dinámica es #strong[positiva]\; si se mantienen, es #strong[neutra]\; si crecen, es #strong[negativa] o divergente. Modos relevantes para el planeador: el fugoide (oscilación longitudinal lenta e inocua) y la tendencia espiral (divergencia lateral que puede derivar en picado en espiral si no se supervisa).
]

/ #strong[Estabilidad estática] <glosario-estabilidad-estatica>: #block[
Tendencia inicial de la aeronave a responder a una perturbación. Si tiende a volver a su posición de equilibrio, la estabilidad estática es #strong[positiva]\; si se queda en la nueva posición, es #strong[neutra]\; si se aleja aún más del equilibrio, es #strong[negativa]. La estabilidad estática positiva es la condición de diseño fundamental de todos los planeadores civiles de entrenamiento.
]

/ #strong[Estela turbulenta (Wake turbulence)] <glosario-estela-turbulenta>: #block[
Turbulencia invisible y peligrosa (vórtices de punta de ala o flujo descendente de rotor) generada por el paso de aeronaves de gran masa o helicópteros en sustentación, que puede desestabilizar o dañar gravemente a un planeador que la atraviese.
]

/ #strong[Estructura sándwich] <glosario-estructura-sandwich>: #block[
Técnica constructiva con dos capas finas y rígidas de fibra separadas por un núcleo ligero de espuma o nido de abeja. Logra gran rigidez con peso mínimo, pero es vulnerable a impactos puntuales que pueden causar delaminación interna invisible desde el exterior.
]

/ #strong[ETA (Hora prevista de llegada / Estimated Time of Arrival)] <glosario-eta>: #block[
Hora a la que se prevé que la aeronave llegue al punto o lugar de referencia correspondiente.
]

/ #strong[ETD (Hora prevista de salida / Estimated Time of Departure)] <glosario-etd>: #block[
Hora a la que se estima que la aeronave iniciará la salida.
]

/ #strong[Factor de carga (n)] <glosario-factor-de-carga>: #block[
Relación entre la sustentación aerodinámica total y el peso del planeador, expresada en unidades #emph[g]. En vuelo recto y nivelado: n = 1g. En un viraje de 60° de inclinación: n = 2g. El factor de carga eleva la velocidad de pérdida en proporción a su raíz cuadrada: a 2g, sube un 41%. Deflexiones bruscas y maniobras mal coordinadas en turbulencia pueden superar los límites del diagrama V-n.
]

/ #strong[Fallo de lanzamiento] <glosario-fallo-de-lanzamiento>: #block[
Interrupción involuntaria de la tracción durante el despegue (por ejemplo, rotura de cable en torno o remolque, o fallo de motor del avión remolcador) que exige la ejecución inmediata del briefing de emergencia preestablecido.
]

/ #strong[Fallo de suelta (Towhook jam)] <glosario-fallo-de-suelta>: #block[
Emergencia en remolque por avión en la que la anilla de suelta del planeador no libera el cable al ser accionada. Exige señalizar la situación al remolcador (posición elevada y lateral con balanceo de alas) para que este libere el cable desde su extremo, y planificar una aproximación final más alta de lo habitual con el cable colgando para librar los obstáculos previos a la pista.
]

/ #strong[Fatiga] <glosario-fatiga>: #block[
Deterioro fisiológico del rendimiento físico o mental provocado por pérdida de sueño, ritmos circadianos alterados o esfuerzo mental sostenido; reduce drásticamente el tiempo de reacción o la capacidad para evaluar riesgos con sensatez.
]

/ #strong[FCL (Licencias de la Tripulación de Vuelo / Flight Crew Licensing)] <glosario-fcl>: #block[
Parte del Reglamento (UE) n.º 1178/2011 relativa a las licencias de tripulación de vuelo; es distinta de la Part-SFCL específica para planeadores.
]

/ #strong[FE(S) (Examinador de Vuelo de Planeadores / Flight Examiner (Sailplanes))] <glosario-fe>: #block[
Examinador autorizado para realizar pruebas y verificaciones de competencia de planeadores dentro de sus atribuciones.
]

/ #strong[FES (Front Electric Sustainer)] <glosario-fes>: #block[
Sistema de propulsión eléctrica con hélice plegable montada en el morro y baterías de litio. De arranque instantáneo y gran fiabilidad, la hélice se pliega contra el fuselaje por la presión del aire al detenerse el motor.
]

/ #strong[FI(S) (Instructor de Vuelo de Planeadores / Flight Instructor (Sailplanes))] <glosario-fi>: #block[
Instructor autorizado para impartir instrucción de vuelo en planeadores dentro de sus atribuciones.
]

/ #strong[FIC (Centro de Información de Vuelo / Flight Information Centre)] <glosario-fic>: #block[
Dependencia establecida para prestar servicio de información de vuelo y servicio de alerta.
]

/ #strong[Final (Tramo final / Final approach leg)] <glosario-final>: #block[
Tramo alineado con el eje de la pista en el sentido del aterrizaje, desde el cual se gestiona el descenso mediante los aerofrenos hasta la toma y parada de la aeronave.
]

/ #strong[FIR (Región de Información de Vuelo / Flight Information Region)] <glosario-fir>: #block[
Espacio aéreo de dimensiones definidas dentro del cual se facilitan servicios de información de vuelo y alerta.
]

/ #strong[FIS (Servicio de Información de Vuelo / Flight Information Service)] <glosario-fis>: #block[
Servicio cuya finalidad es facilitar asesoramiento e información útiles para la realización segura y eficaz de los vuelos.
]

/ #strong[FISO (Operador del Servicio de Información de Vuelo / Flight Information Service Officer)] <glosario-fiso>: #block[
Personal habilitado para prestar el servicio de información de vuelo dentro de sus atribuciones.
]

/ #strong[FL (Nivel de vuelo / Flight Level)] <glosario-fl>: #block[
Superficie de presión constante expresada en centenas de pies y referida al reglaje altimétrico estándar de 1013,25 hPa.
]

/ #strong[Flaps] <glosario-flaps>: #block[
Superficies del borde de salida que modifican la curvatura del ala: posiciones positivas para térmica y aterrizaje, negativas para reducir resistencia en transiciones rápidas. Presentes en veleros de alta competición.
]

/ #strong[FLARM] <glosario-flarm>: #block[
Sistema electrónico de alerta de tráfico y prevención de colisiones de corto alcance diseñado especialmente para planeadores, que transmite la posición GPS tridimensional proyectada a otras aeronaves equipadas.
]

/ #strong[Flutter (Flameo aeroelástico)] <glosario-flutter>: #block[
Fenómeno físico de oscilaciones aeroelásticas autoexcitadas e inestables que afectan a las superficies sustentadoras o de control del planeador al superar la VNE, pudiendo destruir la estructura en segundos debido a la interacción del flujo de aire a alta velocidad con la flexibilidad estructural.
]

/ #strong[FPL (Flight Plan --- Plan de Vuelo)] <glosario-fpl>: #block[
Datos del vuelo previsto que el piloto presenta ante las autoridades ATS antes de operar donde se preste servicio de control de tránsito aéreo (clases B, C y D, o aeródromos controlados; en clase E el VFR no necesita plan de vuelo, ni radio, ni autorización). Incluye tipo de aeronave, indicativo, aeródromo de origen y destino, ruta prevista, nivel de crucero y hora estimada.
]

/ #strong[Frente cálido] <glosario-frente-calido>: #block[
Superficie de separación entre una masa de aire cálido que avanza sobre una masa fría preexistente. El ascenso es gradual (pendiente suave), lo que produce precipitaciones débiles y continuas, techos nubosos bajos y estabilidad: condiciones operativas pobres para el vuelo a vela. Sus precursores son los cirros descendentes (Ci → Cs → As → Ns).
]

/ #strong[Frente frío] <glosario-frente-frio>: #block[
Superficie de separación donde una masa de aire frío y denso avanza en cuña bajo el aire cálido, forzándolo a ascender bruscamente. El paso del frente trae precipitaciones convectivas, chubascos y vientos racheados. La fase post-frontal suele ser la mejor del año para el vuelo a vela: atmósfera limpia, inestable y con buenas térmicas bajo cúmulos bien definidos.
]

/ #strong[Frente ocluido (oclusión)] <glosario-frente-ocluido>: #block[
Estructura frontal que se forma cuando un frente frío alcanza y fusiona con el frente cálido que le precede, pinzando el aire cálido intermedio y forzándolo a ascender. Genera condiciones complejas: precipitaciones extensas, núcleos convectivos embebidos y mala visibilidad. Poco o nada aprovechable para el vuelo a vela.
]

/ #strong[FUA (Uso flexible del espacio aéreo / Flexible Use of Airspace)] <glosario-fua>: #block[
Concepto por el que el espacio aéreo se gestiona como un recurso común y se asigna dinámicamente según las necesidades.
]

/ #strong[Fugoide (modo fugoide)] <glosario-fugoide>: #block[
Modo de oscilación longitudinal lento y de largo período (30-50 segundos) en el que el planeador intercambia altitud y velocidad en ciclos suaves. Generalmente bien amortiguado y apenas perceptible si el piloto mantiene los mandos sujetos. No es peligroso por sí mismo, pero puede desconcertar al piloto inexperto que intenta corregirlo con entradas bruscas.
]

/ #strong[Fusible de seguridad (Weak link)] <glosario-fusible-de-seguridad>: #block[
Eslabón o fusible metálico calibrado intercalado en el cable de remolque o torno, diseñado para romperse ante una sobretensión que supere los límites estructurales calculados antes de dañar al planeador o a la aeronave remolcadora.
]

/ #strong[FZRA (Lluvia engelante / Freezing Rain)] <glosario-fzra>: #block[
Precipitación líquida que cae a través de una capa con temperatura inferior a 0 °C. Las gotículas superenfriadas se congelan al impactar con las superficies del planeador, formando hielo opaco o transparente en el borde de ataque. Situación de emergencia: el único remedio es un cambio de rumbo 180° y descenso inmediato.
]

/ #strong[GAMET (General Area Meteorological Forecast)] <glosario-gamet>: #block[
Pronóstico meteorológico de área para vuelos de aviación general por debajo del FL100, emitido por los proveedores meteorológicos nacionales. Informa de peligros como engelamiento, turbulencia, nieblas y tormentas en ruta.
]

/ #strong[Gancho de remolque (Towhook)] <glosario-gancho-de-remolque>: #block[
Mecanismo de enganche y suelta rápida del cable de lanzamiento, habitualmente del fabricante Tost. El gancho de morro se usa para remolque por avión; el gancho de CG, para torno, e incorpora suelta automática (#strong[back-release]) si el cable tira hacia atrás y abajo.
]

/ #strong[Gelcoat] <glosario-gelcoat>: #block[
Capa exterior de resina de poliéster que protege la estructura de fibra contra la humedad y da el acabado liso característico. Sus enemigos son la radiación UV y los cambios bruscos de temperatura, que provocan el craqueado superficial.
]

/ #strong[GM (Material Guía / Guidance Material)] <glosario-gm>: #block[
Material explicativo no vinculante que ayuda a interpretar los requisitos y los medios aceptables de cumplimiento.
]

/ #strong[GNSS (Sistema Global de Navegación por Satélite)] <glosario-gnss>: #block[
Término genérico para los sistemas de posicionamiento por satélite (GPS, Galileo, GLONASS, BeiDou). Necesita captar al menos cuatro satélites para una posición tridimensional.
]

/ #strong[Gotículas superenfriadas] <glosario-goticulas-superenfriadas>: #block[
Gotículas de agua líquida que permanecen en estado líquido a temperaturas por debajo de 0 °C (hasta −40 °C). Son inestables: al impactar con cualquier superficie sólida se congelan casi instantáneamente. Son la causa principal del engelamiento en vuelo.
]

/ #strong[GPS (Global Positioning System)] <glosario-gps>: #block[
Sistema de posicionamiento por satélite original, operado por Estados Unidos. Es la constelación más conocida dentro del GNSS.
]

/ #strong[Granizo (GR)] <glosario-granizo>: #block[
Precipitación sólida formada por capas alternas de hielo transparente y opaco, resultado de múltiples recirculaciones de las gotículas en las corrientes ascendentes de un cumulonimbus. Granos de más de 2 cm de diámetro pueden perforar la cúpula o dañar estructuralmente el fuselaje de fibra. El granizo puede caer lejos del núcleo visible del Cb, bajo el yunque.
]

/ #strong[GS (Velocidad suelo / Ground Speed)] <glosario-gs>: #block[
Velocidad real sobre el terreno, resultado de combinar la TAS con el viento. Es la que determina cuánto tardas en recorrer un tramo.
]

/ #strong[Handrail (Pasamanos)] <glosario-handrail>: #block[
Referencia lineal grande y bien definida (una costa, una cordillera, una autopista) que se sigue para reorientarse cuando hay incertidumbre de posición.
]

/ #strong[Hiperventilación] <glosario-hiperventilacion>: #block[
Respiración anormalmente rápida desencadenada por el estrés, el pánico o la ansiedad, generando una expulsión drástica de dióxido de carbono que provoca el estrechamiento de los vasos sanguíneos en el cerebro, reduciendo el flujo de oxígeno a pesar de volar a altitudes seguras.
]

/ #strong[Hipoxia] <glosario-hipoxia>: #block[
Estado de déficit de oxígeno cerebral. Existen cuatro tipos: hipóxica (falta de presión transferencial en altitud), hipémica (mermas de transporte por CO), estancada e histotóxica (intoxicación orgánica celular por alcohol o drogas).
]

/ #strong[HJ (Periodo diurno, de orto a ocaso)] <glosario-hj>: #block[
Código que indica el periodo comprendido entre el orto y el ocaso.
]

/ #strong[IAIP (Documentación integrada de información aeronáutica / Integrated Aeronautical Information Package)] <glosario-iaip>: #block[
Conjunto coordinado de publicaciones y productos de información aeronáutica, incluido el AIP y sus actualizaciones.
]

/ #strong[IAS (Velocidad indicada / Indicated Air Speed)] <glosario-ias>: #block[
Velocidad de la aeronave respecto al aire circundante tal como la indica el anemómetro, sin correcciones por temperatura ni densidad. Es la referencia para todos los límites aerodinámicos y estructurales (VNE, VA, velocidades de pérdida y curva polar).
]

/ #strong[IFR (Reglas de vuelo por instrumentos / Instrument Flight Rules)] <glosario-ifr>: #block[
Reglas aplicables a los vuelos operados conforme al régimen de vuelo por instrumentos.
]

/ #strong[IGC (Registrador de vuelo / Logger)] <glosario-igc>: #block[
Dispositivo certificado que graba la traza GPS del vuelo en un archivo #NormalTok(".igc");, prueba del paso por los puntos de viraje para validar récords y medallas FAI.
]

/ #strong[IMSAFE] <glosario-imsafe>: #block[
Acrónimo nemotécnico de autoevaluación psicofísica recomendado antes de cada vuelo: Illness (Enfermedad), Medication (Medicación), Stress (Estrés), Alcohol (Alcohol), Fatigue (Fatiga) y Eating (Alimentación).
]

/ #strong[INCERFA (Fase de incertidumbre / Uncertainty Phase)] <glosario-incerfa>: #block[
Fase declarada cuando existe incertidumbre sobre la seguridad de una aeronave y sus ocupantes.
]

/ #strong[Interceptación (interception)] <glosario-interceptacion>: #block[
Maniobra por la que una aeronave militar identifica a una aeronave civil y le da instrucciones mediante señales visuales o radio, regulada por SERA.11015. La aeronave interceptada debe seguir las instrucciones visuales del interceptor, notificarlo al ATS si es posible, intentar contacto en 121,5 MHz y seleccionar 7700 en el transpondedor; las instrucciones del interceptor prevalecen sobre las de cualquier otra fuente mientras se solicita aclaración.
]

/ #strong[Inversión térmica] <glosario-inversion-termica>: #block[
Capa atmosférica en la que la temperatura aumenta con la altitud en lugar de disminuir. Actúa como techo invisible que frena las térmicas por completo, limita la altura máxima de vuelo y atrapa contaminación y bruma en los niveles inferiores, degradando la visibilidad.
]

/ #strong[IR (Reglas de Ejecución / Implementing Rules)] <glosario-ir>: #block[
Requisitos jurídicamente vinculantes que desarrollan el Reglamento Base europeo de aviación civil.
]

/ #strong[Isógona (línea isogónica)] <glosario-isogona>: #block[
Línea de la carta que une los puntos con igual valor de variación (declinación) magnética.
]

/ #strong[K-Index (índice K)] <glosario-k-index>: #block[
Índice de estabilidad atmosférica que combina el gradiente vertical de temperatura entre 850 hPa y 500 hPa con la humedad en niveles medios. Es el indicador diario más usado por los volovelistas: K \< 5 (día débil), 5--15 (buenas térmicas), 15--20 (excelente), 20--30 (excelente con chubascos), \> 30 (alta probabilidad de tormentas).
]

/ #strong[LAPL (Licencia de Piloto de Aeronave Ligera / Light Aircraft Pilot Licence)] <glosario-lapl>: #block[
Licencia europea para determinadas operaciones no comerciales con aeronaves ligeras, sujeta a las atribuciones y limitaciones aplicables.
]

/ #strong[Larguero (Spar)] <glosario-larguero>: #block[
Viga principal que recorre el ala de punta a punta y soporta las cargas de flexión en vuelo. Un daño estructural en el larguero deja el ala fuera de servicio.
]

/ #strong[Las 7 S] <glosario-las-7-s>: #block[
Regla nemotécnica utilizada para evaluar sistemáticamente la aptitud de un campo desde el aire en un aterrizaje fuera de campo: #strong[Size] (Tamaño), #strong[Shape] (Forma), #strong[Slope] (Pendiente), #strong[Surface] (Superficie), #strong[Surroundings] (Alrededores/Obstáculos), #strong[Stock] (Ganado/Animales) y #strong[Sun] (Posición del Sol).
]

/ #strong[Lastre de agua (Water ballast)] <glosario-lastre-de-agua>: #block[
Agua cargada en tanques específicos situados en las alas para aumentar la masa del planeador y su carga alar, desplazando la curva polar de velocidades hacia valores más altos para volar más rápido con el mismo ángulo de planeo.
]

/ #strong[Lastre de cola (Fin ballast)] <glosario-lastre-de-cola>: #block[
Pequeño depósito de agua o soporte de pesas en la deriva que compensa el desplazamiento del CG producido por el lastre de las alas o por un piloto pesado, restaurando el centrado óptimo. Olvidar vaciarlo con un piloto ligero genera un CG peligrosamente retrasado.
]

/ #strong[Latitud] <glosario-latitud>: #block[
Coordenada que mide la distancia angular al norte o al sur del Ecuador (latitud 0º), formada por los paralelos. Un minuto de latitud equivale a una milla náutica.
]

/ #strong[LCL (Nivel de Condensación por Elevación / Lifted Condensation Level)] <glosario-lcl>: #block[
Altitud a la que una parcela de aire, al ser elevada adiabáticamente, alcanza su punto de saturación y comienza a condensar. En la práctica, es la altura de la base de los cúmulos. En el sondeo Skew-T se obtiene donde la curva de temperatura de la parcela intersecta la curva del punto de rocío.
]

/ #strong[LFC (Nivel de Convección Libre / Level of Free Convection)] <glosario-lfc>: #block[
Altitud por encima de la cual una parcela de aire levantada artificialmente se vuelve más cálida que el entorno y asciende libremente sin necesidad de fuerza externa. Su cruce indica que la convección puede dispararse de forma autónoma. Si es demasiado bajo en un día caluroso, el riesgo de sobredesarrollo hacia Cb es alto.
]

/ #strong[LI (Índice de Levantamiento / Lifted Index)] <glosario-li>: #block[
Diferencia entre la temperatura del ambiente y la de una parcela elevada adiabáticamente desde la superficie hasta el nivel de 500 hPa. Valores negativos indican inestabilidad: cuanto más negativo, mayor el potencial convectivo y la fuerza de las térmicas.
]

/ #strong[LiFePO4 (Batería de litio-ferrofosfato)] <glosario-lifepo4>: #block[
Tecnología de batería ligera con curva de descarga plana (mantiene el voltaje hasta casi agotarse). Requiere cargadores específicos y un manejo cuidadoso para evitar incendios por cortocircuito.
]

/ #strong[Longitud] <glosario-longitud>: #block[
Coordenada que mide la distancia angular al este o al oeste del meridiano de Greenwich (longitud 0º), formada por los meridianos. A diferencia de la latitud, un minuto de longitud varía con la latitud.
]

/ #strong[Loxodrómica (Línea de rumbo)] <glosario-loxodromica>: #block[
Trayectoria que corta todos los meridianos con el mismo ángulo, es decir, de rumbo constante. Es algo más larga que la ortodrómica, pero más cómoda de volar; es la que usamos en planeador.
]

/ #strong[LSA (Ley de Seguridad Aérea)] <glosario-lsa>: #block[
Denominación abreviada de la Ley 21/2003, de 7 de julio, de Seguridad Aérea.
]

/ #strong[Línea de convergencia] <glosario-linea-de-convergencia>: #block[
Franja del espacio aéreo donde dos masas de aire de distinta procedencia se encuentran y el aire se ve forzado a ascender. Puede originarse por el choque de la brisa marina con la masa continental, por vientos catabáticos de dos laderas opuestas (restitución) o por diferencias orográficas. Ofrece ascendencias continuas y regulares, ideales para el vuelo de distancia.
]

/ #strong[L'Hotellier (Conector)] <glosario-lhotellier>: #block[
Conector manual de rótula usado en las conexiones de mandos de muchos planeadores. Crítico para la seguridad: exige pin de seguridad (imperdible) además del muelle, y ha sido causa de numerosos accidentes por olvido de conexión.
]

/ #strong[Mando diferencial de alerones] <glosario-mando-diferencial-de-alerones>: #block[
Sistema de varillaje que hace que el alerón que sube (ala interior del giro) recorra un ángulo mayor que el alerón que baja (ala exterior). Al generar más resistencia parásita en el ala interior, compensa parcialmente la resistencia inducida del ala exterior y reduce la guiñada adversa de forma mecánica. No la elimina completamente: la coordinación pie-mano sigue siendo necesaria.
]

/ #strong[Masa de aire] <glosario-masa-de-aire>: #block[
Gran volumen de aire troposférico con propiedades físicas (temperatura y humedad) horizontalmente homogéneas adquiridas en su zona de origen. Su temperatura relativa respecto al suelo que sobrevuela determina si la atmósfera es inestable (aire frío sobre suelo caliente) o estable (aire cálido sobre suelo frío).
]

/ #strong[MAYDAY] <glosario-mayday>: #block[
Señal internacional de socorro por radio, repetida tres veces. Se usa solo cuando hay peligro grave e inminente y se necesita asistencia inmediata. Impone silencio de radio absoluto en la frecuencia a todas las estaciones no implicadas. Usarlo de forma falsa o maliciosa es una infracción muy grave según la normativa EASA.
]

/ #strong[MED (Part-MED)] <glosario-med>: #block[
Subparte de la normativa europea (EASA) que estipula y rige exhaustivamente todas las condiciones fisiológicas y médicas que debe cumplir un piloto para mantener y ejercer las atribuciones de su licencia de vuelo.
]

/ #strong[METAR (Meteorological Aerodrome Report)] <glosario-metar>: #block[
Informe meteorológico observacional codificado de un aeródromo que se emite a intervalos regulares (30 o 60 minutos), reportando viento, visibilidad, nubes, temperatura, punto de rocío y presión.
]

/ #strong[Microburst (microrráfaga)] <glosario-microburst>: #block[
Ver Downburst.
]

/ #strong[Milla náutica (NM)] <glosario-milla-nautica>: #block[
Unidad de distancia de la navegación, igual a 1852 m, equivalente a un minuto de arco de latitud medido sobre un meridiano.
]

/ #strong[Modelo burbuja (bubble model)] <glosario-modelo-burbuja>: #block[
Modelo conceptual de la térmica en el que el calor se acumula sobre la fuente hasta que la masa de aire se desprende formando un vórtice anular. El ascenso es intermitente y el núcleo central sube más rápido que los bordes. El planeador debe centrarse en el núcleo para obtener el máximo ascenso.
]

/ #strong[Modelo columna / pluma (column/plume model)] <glosario-modelo-columna>: #block[
Modelo conceptual de la térmica en el que fuentes de calor intensas y persistentes generan un flujo convectivo continuo, similar al humo de una chimenea. El ascenso es más regular y duradero que en el modelo burbuja. Favorece el vuelo de distancia al reducir las maniobras de centrado.
]

/ #strong[Momento] <glosario-momento>: #block[
Efecto de giro o tendencia rotacional ejercida por un peso en función de su brazo de palanca respecto al datum. Se calcula multiplicando la masa del objeto por su brazo de palanca.
]

/ #strong[Monóxido de carbono (CO)] <glosario-monoxido-de-carbono>: #block[
Gas letal, inodoro e invisible derivado de los sistemas de escape. Se une a la hemoglobina bloqueando el transporte de oxígeno (hipoxia anémica), afectando a los pilotos de motovelero (TMG) incluso a baja altitud.
]

/ #strong[MTOW (Masa Máxima al Despegue / Maximum Take-Off Weight)] <glosario-mtow>: #block[
Masa máxima autorizada o certificada con la que el planeador puede iniciar el vuelo, determinada por límites estructurales y de rendimiento aerodinámico.
]

/ #strong[Multitrayecto] <glosario-multitrayecto>: #block[
Fuente de error del GNSS por la que la señal de un satélite llega al receptor tras rebotar en el terreno o en estructuras, falseando ligeramente la medida de distancia.
]

/ #strong[Navegación a estima (Dead Reckoning)] <glosario-navegacion-a-estima>: #block[
Método de deducir la posición a partir de un punto conocido aplicando rumbo, velocidad y tiempo transcurrido. Sus pequeños errores se acumulan, así que se confirma con referencias del terreno.
]

/ #strong[Navegación observada] <glosario-navegacion-observada>: #block[
Técnica de fijar la posición reconociendo accidentes del terreno (ríos, carreteras, pueblos) y comparándolos con la carta.
]

/ #strong[NCA (Nivel de Condensación por Ascenso)] <glosario-nca>: #block[
Ver LCL. En terminología española, equivalente al LCL: la altura a la que se forma la base de los cúmulos. Estimación rápida: (T − Td) × 400 = altura en pies.
]

/ #strong[Niebla] <glosario-niebla>: #block[
Suspensión de gotículas de agua microscópicas que reduce la visibilidad por debajo de 1.000 m. Invalida las operaciones VFR. Se distingue de la bruma (#strong[mist]), que reduce la visibilidad entre 1.000 m y 5.000 m sin afectar el código CAVOK. En METAR se codifica como #NormalTok("FG"); (niebla) o #NormalTok("BR"); (bruma).
]

/ #strong[Niebla de advección] <glosario-niebla-de-adveccion>: #block[
Niebla que se forma cuando una masa de aire cálido y húmedo se desplaza horizontalmente sobre una superficie más fría (mar frío, valle nevado o costa), que enfría su base hasta la saturación. A diferencia de la de radiación, no depende del enfriamiento nocturno y puede persistir día y noche mientras dure el flujo.
]

/ #strong[Niebla de radiación] <glosario-niebla-de-radiacion>: #block[
Niebla que se forma durante las noches despejadas de otoño e invierno cuando el suelo pierde calor por radiación hacia el espacio, enfría el aire en contacto hasta el punto de rocío y produce condensación. Puede ser muy densa y persistir hasta mediados de la mañana. Especialmente frecuente en anticiclones invernales con vientos flojos.
]

/ #strong[NORDO (No Radio)] <glosario-nordo>: #block[
Situación en que una aeronave ha perdido todas las comunicaciones bidireccionales por radio. El procedimiento: seleccionar 7600 en el transpondedor, mantenerse en VMC, aterrizar en el aeródromo adecuado más cercano y notificar por teléfono al aterrizar.
]

/ #strong[Norte magnético] <glosario-norte-magnetico>: #block[
Punto hacia el que apuntan las agujas de la brújula. No coincide con el norte verdadero y se desplaza ligeramente cada año.
]

/ #strong[Norte verdadero (Geográfico)] <glosario-norte-verdadero>: #block[
Punto por el que pasa el eje de rotación de la Tierra. Es el norte de referencia de los mapas y las cartas aeronáuticas.
]

/ #strong[NOTAM (Notice to airmen)] <glosario-notam>: #block[
Aviso distribuido por telecomunicaciones que contiene información aeronáutica cuyo conocimiento oportuno es esencial para las operaciones.
]

/ #strong[NSC (No Significant Clouds)] <glosario-nsc>: #block[
Indicador en METAR/TAF que señala ausencia de nubes por debajo de 5.000 ft y ausencia de cumulonimbus. A diferencia de CAVOK, no implica visibilidad ≥ 10 km.
]

/ #strong[Nudo (kt)] <glosario-nudo>: #block[
Unidad de velocidad igual a una milla náutica por hora (1 kt = 1,852 km/h).
]

/ #strong[OACI / ICAO (Organización de Aviación Civil Internacional / International Civil Aviation Organization)] <glosario-oaci>: #block[
Agencia especializada de las Naciones Unidas que establece normas y métodos recomendados para la aviación civil internacional.
]

/ #strong[Ocaso] <glosario-ocaso>: #block[
Atardecer: instante en que el borde superior del disco solar desaparece por el horizonte oeste. No marca todavía el inicio de la noche aeronáutica (ver crepúsculo civil).
]

/ #strong[Onda de montaña (wave soaring)] <glosario-onda-de-montana>: #block[
Oscilación ondulatoria del flujo de aire que se genera a sotavento de una cordillera cuando el viento es perpendicular a la cresta, supera un umbral de velocidad y existe una capa estable a la altura de la cresta. Permite el ascenso laminar hasta grandes altitudes. Los altocúmulos lenticulares son su señal visual. Los rotores en la base son el principal peligro.
]

/ #strong[Orto] <glosario-orto>: #block[
Amanecer: instante en que el borde superior del disco solar asoma por el horizonte este.
]

/ #strong[Ortodrómica (Círculo máximo)] <glosario-ortodromica>: #block[
Trayectoria más corta entre dos puntos de la esfera terrestre. Su inconveniente es que el rumbo cambia continuamente al cruzar los meridianos.
]

/ #strong[Outlanding (Aterrizaje fuera de campo / Toma fuera de campo)] <glosario-outlanding>: #block[
Procedimiento operativo planificado y ejecutado de aterrizaje preventivo fuera de un aeródromo autorizado, realizado en campos abiertos o agrícolas aptos debido a la ausencia de ascendencias térmicas o pérdida de altura utilizable.
]

/ #strong[PAN PAN] <glosario-pan-pan>: #block[
Señal internacional de urgencia por radio, repetida tres veces. Se usa cuando hay un problema serio de seguridad que necesita atención prioritaria del ATC, pero sin peligro grave e inminente ni necesidad de salvamento inmediato. A diferencia del MAYDAY, no impone silencio de radio al resto del tráfico.
]

/ #strong[Paracaídas de emergencia] <glosario-paracaidas-de-emergencia>: #block[
Dispositivo individual de salvamento de accionamiento manual que el piloto de planeador lleva integrado como respaldo obligatorio o recomendado en el cockpit.
]

/ #strong[Part-ML (Parte de mantenimiento de aeronaves ligeras)] <glosario-part-ml>: #block[
Parte del régimen europeo de aeronavegabilidad continuada aplicable a aeronaves ligeras, incluidos muchos planeadores.
]

/ #strong[Part-SAO (Operaciones de Planeadores / Sailplane Air Operations)] <glosario-part-sao>: #block[
Parte del Reglamento (UE) 2018/1976 que contiene los requisitos operativos aplicables a los planeadores.
]

/ #strong[Part-SFCL (Licencias de Tripulación de Vuelo de Planeadores / Sailplane Flight Crew Licensing)] <glosario-part-sfcl>: #block[
Parte del Reglamento (UE) 2018/1976 que regula las licencias, atribuciones, instructores y examinadores de planeadores.
]

/ #strong[PAVE] <glosario-pave>: #block[
Esquema simplificado y fundamental para ejecutar la evaluación sistemática y mitigación profiláctica de los riesgos de cualquier vuelo, dividido en: Piloto, Aeronave (#strong[Aircraft]), Entorno (#strong[enVironment]) y Presiones Externas.
]

/ #strong[PCC (Comprobación de mandos positiva / Positive Control Check)] <glosario-pcc>: #block[
Verificación obligatoria tras el montaje del planeador en la que un asistente sujeta físicamente cada superficie de mando en el exterior mientras el piloto acciona los controles en cabina para verificar la integridad y correcto sentido del movimiento.
]

/ #strong[PIC (Piloto al mando / Pilot in Command)] <glosario-pic>: #block[
Piloto designado para el mando y encargado de la realización segura del vuelo.
]

/ #strong[PLB (Personal Locator Beacon)] <glosario-plb>: #block[
Baliza de localización personal portátil, de activación manual, que el piloto lleva consigo (bolsillo o arnés del paracaídas) y que transmite en 406 MHz a la red satelital de rescate.
]

/ #strong[Polar de velocidades] <glosario-polar-de-velocidades>: #block[
Gráfico o curva matemática que relaciona la velocidad indicada (IAS) del planeador con su velocidad o tasa de caída (sink rate). Define las velocidades operativas óptimas.
]

/ #strong[Poliuretano (PU)] <glosario-poliuretano>: #block[
Sistema de pintura acrílica de poliuretano que sustituye cada vez más al gelcoat de poliéster en los veleros modernos. Se aplica en capa fina (menos peso) y es más elástico, así que resiste mucho mejor el craqueado por UV y conserva el brillo más años; a cambio, deja menos margen para reparar a base de lijar y pulir.
]

/ #strong[PPL (Licencia de Piloto Privado / Private Pilot Licence)] <glosario-ppl>: #block[
Licencia que permite ejercer atribuciones de piloto privado dentro de las condiciones aplicables.
]

/ #strong[Proyección Lambert (cónica conforme)] <glosario-proyeccion-lambert>: #block[
Proyección cartográfica empleada en las cartas aeronáuticas de latitudes medias. Es "conforme" (conserva ángulos y formas), su escala es prácticamente constante y una línea recta se aproxima a una ortodrómica.
]

/ #strong[PTT (Push-to-Talk --- Pulsar para Hablar)] <glosario-ptt>: #block[
Botón de transmisión. Al pulsarlo, la radio pasa de recepción a emisión. Al soltarlo, vuelve a escuchar. En planeadores suele estar en la palanca de mando. Si se queda atascado, provoca la situación de micrófono bloqueado.
]

/ #strong[Pulsioxímetro] <glosario-pulsioximetro>: #block[
Dispositivo de dedo recomendado en vuelos a gran altura que muestra la saturación de oxígeno en sangre (SpO₂). Permite al piloto detectar la hipoxia de forma objetiva antes de que aparezcan los primeros síntomas.
]

/ #strong[QDM] <glosario-qdm>: #block[
Código Q con el rumbo magnético que debe seguir la aeronave para llegar a la estación de radiogoniometría (VDF). Si estás desorientado, pide un QDM al FIS y te darán el rumbo para llegar a la estación.
]

/ #strong[QFE (Reglaje altimétrico referido a un datum de aeródromo)] <glosario-qfe>: #block[
Reglaje que hace que el altímetro indique la altura respecto del datum para el que se ha calculado y, en ese punto, marque aproximadamente cero.
]

/ #strong[QNE (Indicación con el reglaje altimétrico estándar)] <glosario-qne>: #block[
Indicación obtenida al calar 1013,25 hPa, empleada para expresar niveles de vuelo; no es una presión comunicada por una estación.
]

/ #strong[QNH (Reglaje altimétrico reducido al nivel medio del mar)] <glosario-qnh>: #block[
Reglaje que permite al altímetro indicar altitud y, en tierra, aproximadamente la elevación del punto considerado.
]

/ #strong[RCC (Centro Coordinador de Salvamento / Rescue Coordination Centre)] <glosario-rcc>: #block[
Dependencia responsable de coordinar las operaciones de búsqueda y salvamento dentro de una región asignada.
]

/ #strong[Regla del 1 en 60] <glosario-regla-del-1-en-60>: #block[
Aproximación de cálculo mental: desviarse 1 NM de la ruta tras volar 60 NM equivale a un error de rumbo de 1º. Sirve para corregir el rumbo sobre la marcha.
]

/ #strong[Resbale lateral (Sideslip)] <glosario-resbale-lateral>: #block[
Maniobra aerodinámica coordinada de forma cruzada (alerón a un lado, pedal al opuesto) por la cual se presenta el fuselaje de lado a la corriente libre, generando un incremento drástico de la resistencia aerodinámica que incrementa la tasa de descenso sin aumentar la velocidad.
]

/ #strong[Resistencia inducida] <glosario-resistencia-inducida>: #block[
Componente de la resistencia aerodinámica que es subproducto directo de generar sustentación. Las diferencias de presión entre extradós e intradós hacen que el aire fluya alrededor de las puntas del ala formando torbellinos helicoidales que inclinan el vector de sustentación hacia atrás, creando una fuerza opuesta al avance. Es máxima a velocidades bajas; disminuye al aumentar la velocidad. Las alas de gran envergadura (alta relación de aspecto) la reducen notablemente.
]

/ #strong[Resistencia parásita] <glosario-resistencia-parasita>: #block[
Componente de la resistencia aerodinámica debida al movimiento del planeador a través del aire, independientemente de la sustentación generada. Incluye la fricción superficial, la resistencia de forma y la resistencia de interferencia entre superficies. Aumenta con el cuadrado de la velocidad: si la velocidad se dobla, la resistencia parásita se cuadruplica. A alta velocidad domina sobre la resistencia inducida.
]

/ #strong[Rigging (Montaje)] <glosario-rigging>: #block[
Proceso de ensamblaje del planeador (fuselaje, alas y estabilizador) con la conexión de sus superficies de mando. Fase crítica de seguridad que exige método, ausencia de distracciones y verificación final con PCC.
]

/ #strong[RMZ (Zona de radio obligatoria / Radio Mandatory Zone)] <glosario-rmz>: #block[
Espacio aéreo de dimensiones definidas en el que es obligatorio llevar y utilizar equipo de radio conforme a los requisitos publicados.
]

/ #strong[Rotor] <glosario-rotor>: #block[
Vórtice turbulento de pequeña escala que se forma a sotavento del pie de una ladera o cordillera bajo la primera cresta de la onda de montaña. Genera turbulencia severa e impredecible a baja altura. Las nubes de rotor (#strong[rotor clouds]) son estratos irregulares bajo la onda que señalan esta zona peligrosa.
]

/ #strong[RSC (Subcentro de Salvamento / Rescue Sub-Centre)] <glosario-rsc>: #block[
Dependencia subordinada a un RCC que coordina operaciones de búsqueda y salvamento en una parte de su región.
]

/ #strong[SALR (Saturated Adiabatic Lapse Rate)] <glosario-salr>: #block[
Gradiente Adiabático Saturado. Ritmo al que se enfría una parcela de aire saturada (en formación de nube) al ascender adiabáticamente: aproximadamente 1,5 °C por cada 1.000 ft. Es menor que el DALR porque la condensación libera calor latente que "frena" el enfriamiento.
]

/ #strong[SAO (Sailplane Air Operations)] <glosario-sao>: #block[
Normativa operativa específica de EASA para pilotos al mando de planeadores. Fija reglas como la obligatoriedad del oxígeno por encima de 10.000 ft de altitud.
]

/ #strong[SAR (Búsqueda y salvamento / Search and Rescue)] <glosario-sar>: #block[
Organización y operaciones destinadas a localizar y auxiliar aeronaves y personas en peligro.
]

/ #strong[SB (Boletín de Servicio / Service Bulletin)] <glosario-sb>: #block[
Comunicación del fabricante con instrucciones, inspecciones o modificaciones cuya obligatoriedad depende del marco aplicable.
]

/ #strong[Self-launch (Autolanzamiento)] <glosario-self-launch>: #block[
Capacidad de despegue y ascenso autónomo del planeador utilizando una unidad de potencia auxiliar motora integrada en la estructura (motoveleros TMG o veleros de motor retráctil).
]

/ #strong[SERA (Reglas Europeas Estandarizadas del Aire / Standardised European Rules of the Air)] <glosario-sera>: #block[
Reglas del aire comunes establecidas por el Reglamento de Ejecución (UE) n.º 923/2012.
]

/ #strong[SFCL (Sailplane Flight Crew Licensing)] <glosario-sfcl>: #block[
Marco normativo europeo (EASA) que regula las licencias, el programa de estudios y la instrucción de vuelo para pilotos de planeador (SPL).
]

/ #strong[SHELL] <glosario-shell>: #block[
Modelo conceptual desarrollado por la OACI interconectando de forma unificada y armónica todos los vértices relativos al operador: #strong[Software] (Procedimientos normativos), #strong[Hardware] (La Aeronave), #strong[Environment] (El Entorno físico), #strong[Liveware] interior y #strong[Liveware] externo (El piloto con respecto a otras personas).
]

/ #strong[SIGMET (Significant Meteorological Information)] <glosario-sigmet>: #block[
Mensaje de alerta que informa a las tripulaciones de fenómenos meteorológicos en ruta de gran relevancia para la seguridad: engelamiento severo (#NormalTok("SEV ICE");), turbulencia severa (#NormalTok("SEV TURB");), actividad de cenizas volcánicas o ciclones tropicales.
]

/ #strong[SIGWX (Significant Weather Chart)] <glosario-sigwx>: #block[
Mapa de Tiempo Significativo. Pronóstico a escala sinóptica que muestra la distribución de sistemas frontales, zonas de turbulencia e engelamiento, y otras áreas de meteorología significativa en una región geográfica. Imprescindible para la planificación de vuelos de distancia.
]

/ #strong[Sistema pitot-estática] <glosario-sistema-pitot-estatica>: #block[
Conjunto de tomas de presión que alimenta los instrumentos básicos: el tubo Pitot mide la presión total (estática + dinámica) y las tomas estáticas, la presión ambiental. Su bloqueo (insectos, agua, hielo) deja al piloto sin indicación de velocidad y altura.
]

/ #strong[SNS (Sistema de Notificación de Sucesos)] <glosario-sns>: #block[
Sistema español para recibir y gestionar notificaciones de sucesos de aviación civil con fines de seguridad.
]

/ #strong[Sondeo termodinámico (Skew-T / Stüve)] <glosario-sondeo-termodinamico>: #block[
Diagrama que representa el perfil vertical de temperatura, temperatura del punto de rocío y viento en la atmósfera, obtenido mediante radiosondeo. Permite al piloto estimar la altura de las bases de cúmulos (LCL), el techo térmico, el riesgo de sobredesarrollo (LFC) y los índices de estabilidad (K-Index, CAPE, LI).
]

/ #strong[SPIC (Alumno piloto al mando / Student Pilot-in-Command)] <glosario-spic>: #block[
Alumno piloto que actúa como piloto al mando en un vuelo con un instructor que únicamente observa y no influye en el control de la aeronave.
]

/ #strong[SPL (Licencia de Piloto de Planeador / Sailplane Pilot Licence)] <glosario-spl>: #block[
Licencia de la Unión Europea, regulada por la Part-SFCL, que permite ejercer las atribuciones de piloto de planeador dentro de las condiciones aplicables.
]

/ #strong[Squawk] <glosario-squawk>: #block[
Código de cuatro dígitos en base octal (0--7) que el transpondedor emite al ser interrogado por el radar secundario (SSR), permitiendo al controlador identificar la aeronave en pantalla. Código VFR estándar en Europa: 7000. Los códigos 7700 (emergencia), 7600 (NORDO) y 7500 (interferencia ilícita) son de uso exclusivo en esas situaciones.
]

/ #strong[SRM (Single-Pilot Resource Management)] <glosario-srm>: #block[
Gestión de recursos para pilotos solitarios. Habilidad para administrar todos los recursos disponibles (instrumentos, ATC, listas de chequeo) para operar de forma segura, reduciendo la carga de trabajo y minimizando el riesgo de errores sistemáticos.
]

/ #strong[SSR (Secondary Surveillance Radar --- Radar Secundario de Vigilancia)] <glosario-ssr>: #block[
Radar que interroga a los transpondedores a bordo y obtiene información codificada: código #strong[squawk] (Modo A), altitud barométrica (Modo C) e identidad extendida (Modo S). Complementa al radar primario añadiendo en pantalla la etiqueta con número de vuelo y altitud.
]

/ #strong[Stau] <glosario-stau>: #block[
Efecto complementario al Foehn: acumulación de nubes y precipitación intensa en la ladera de barlovento de una cordillera, donde el aire húmedo asciende y condensa. Mientras en barlovento llueve (Stau), en sotavento el cielo puede estar despejado y la temperatura es varios grados más alta (Foehn).
]

/ #strong[Sustentador (Turbo)] <glosario-sustentador>: #block[
Motor auxiliar de baja potencia, generalmente de dos tiempos y escamoteable, incapaz de despegar por sí solo pero suficiente para mantener el vuelo y regresar a la base si fallan las térmicas.
]

/ #strong[Tablilla de desvíos] <glosario-tablilla-de-desvios>: #block[
Tarjeta instalada a la vista del piloto que indica la corrección a aplicar a la brújula en cada rumbo para compensar el desvío propio de la aeronave.
]

/ #strong[TAF (Terminal Aerodrome Forecast)] <glosario-taf>: #block[
Pronóstico meteorológico codificado que describe las condiciones meteorológicas esperadas en un aeródromo específico durante un periodo de tiempo determinado (típicamente 9, 24 o 30 horas).
]

/ #strong[TAS (Velocidad verdadera / True Air Speed)] <glosario-tas>: #block[
Velocidad real respecto a la masa de aire. Es la IAS corregida por densidad (crece aproximadamente un 2 % por cada 300 m de altitud, unos 6,5-7 % por cada 1.000 m) y el vector que marca hacia dónde apunta el morro.
]

/ #strong[Tendencia espiral] <glosario-tendencia-espiral>: #block[
Característica de estabilidad dinámica lateral presente en la mayoría de los planeadores: si se les abandona con un pequeño ángulo de inclinación, el alabeo crece lentamente hasta desarrollar un picado en espiral. El planeador es estáticamente estable en alabeo pero dinámicamente divergente en espiral cuando se deja sin supervisión. Es la causa fundamental de los accidentes por pérdida de control en condiciones de visibilidad reducida.
]

/ #strong[Teoría MacCready (Anillo MacCready)] <glosario-teoria-maccready>: #block[
Método de optimización de velocidad de vuelo que indica la velocidad óptima a volar entre térmicas dada la intensidad esperada de la siguiente corriente térmica ascendente.
]

/ #strong[Tintas hipsométricas] <glosario-tintas-hipsometricas>: #block[
Sistema de coloreado del terreno en la carta (verdes para los valles, marrones para las montañas) que da una idea rápida del relieve.
]

/ #strong[TMA (Área de Control Terminal / Terminal Control Area)] <glosario-tma>: #block[
Área de control establecida normalmente en la confluencia de rutas ATS, en las inmediaciones de uno o más aeródromos importantes, cuyos límites son los publicados para cada TMA.
]

/ #strong[TMG (Motovelero de turismo / Touring Motor Glider)] <glosario-tmg>: #block[
Planeador propulsado equipado con motor y hélice no retráctiles que puede despegar y ascender por sus propios medios.
]

/ #strong[TMZ (Zona de transpondedor obligatorio / Transponder Mandatory Zone)] <glosario-tmz>: #block[
Espacio aéreo en el que es obligatorio llevar y operar un transpondedor con las capacidades exigidas; no impone por sí solo comunicación o escucha radio, salvo que también sea RMZ o así se publique.
]

/ #strong[Torno (Lanzamiento por torno / Winch)] <glosario-torno>: #block[
Método de lanzamiento en el que un planeador es acelerado a alta velocidad sobre la pista mediante el enrollado rápido de un cable por un motor potente estacionario en el extremo de la pista, elevándolo hasta la altura de suelta en un ascenso muy inclinado.
]

/ #strong[TR (Habilitación de tipo / Type Rating)] <glosario-tr>: #block[
Anotación en la licencia que acredita la capacitación para operar un tipo de aeronave cuando la normativa exige esa habilitación.
]

/ #strong[TRA (Área temporalmente reservada / Temporary Reserved Area)] <glosario-tra>: #block[
Volumen de espacio aéreo reservado temporalmente para una actividad determinada, cuyo tránsito por otras aeronaves puede autorizarse conforme a las condiciones aplicables.
]

/ #strong[Transmisión a ciegas (blind transmission)] <glosario-transmision-a-ciegas>: #block[
Procedimiento para cuando sospechas que tu receptor ha fallado pero el emisor sigue funcionando. Transmites regularmente posición e intenciones en la frecuencia correcta, precediendo cada mensaje con «Transmitiendo a ciegas debido a fallo del receptor», aunque no llegue ninguna respuesta.
]

/ #strong[Transpondedor (XPDR --- Transponder)] <glosario-transpondedor>: #block[
Equipo de a bordo que responde automáticamente a las interrogaciones del radar secundario (SSR) emitiendo un código #strong[squawk] y, según el modo, la altitud barométrica o datos extendidos de identificación. Opera en la banda UHF (1.030/1.090 MHz), independientemente de la radio de voz. Imprescindible para ser visible por el TCAS de otros tráficos.
]

/ #strong[Tren retráctil] <glosario-tren-retractil>: #block[
Tren de aterrizaje que se recoge dentro del fuselaje para eliminar resistencia aerodinámica, habitualmente mediante una palanca manual. Su gestión disciplinada (extensión en viento en cola, siempre) forma parte de las listas de chequeo.
]

/ #strong[Triangulación (Líneas de posición)] <glosario-triangulacion>: #block[
Técnica de fijar la posición cruzando al menos dos líneas de posición (por ejemplo, una carretera y la alineación con un pueblo).
]

/ #strong[Triángulo de velocidades (Triángulo del viento)] <glosario-triangulo-de-velocidades>: #block[
Suma vectorial de la TAS, el viento y la GS que está en la base de todos los cálculos de la navegación a estima.
]

/ #strong[Tropopausa] <glosario-tropopausa>: #block[
Límite superior de la troposfera, donde el gradiente térmico se anula y la temperatura se estabiliza. A media latitud se sitúa entre 8.000 m (invierno) y 12.000 m (verano). El yunque del cumulonimbus se extiende horizontalmente al alcanzar esta capa, que actúa como techo para la convección.
]

/ #strong[Troposfera] <glosario-troposfera>: #block[
Capa inferior de la atmósfera, desde el suelo hasta la tropopausa, donde se producen la totalidad de los fenómenos meteorológicos relevantes para la aviación. Contiene aproximadamente el 75 % de la masa del aire y casi todo el vapor de agua atmosférico.
]

/ #strong[TSA (Área temporalmente segregada / Temporary Segregated Area)] <glosario-tsa>: #block[
Volumen de espacio aéreo reservado temporalmente y segregado del resto del tránsito mientras está activo.
]

/ #strong[TUC (Time of Useful Consciousness)] <glosario-tuc>: #block[
Tiempo útil de conciencia. Intervalo crítico en el que el piloto retiene sus capacidades cognitivas y motoras para tomar medidas correctivas tras una interrupción del suministro de oxígeno a gran altitud. Se reduce rápidamente a mayor altura.
]

/ #strong[Turbulencia de estela (wake turbulence)] <glosario-turbulencia-de-estela>: #block[
Vórtices tubulares contrarrotantes generados por el paso de aeronaves de ala fija al producir sustentación, o por el flujo y vórtices de rotor de los helicópteros. Descienden lentamente y persisten varios minutos después del paso de la aeronave. Cruzarlos perpendicularmente puede inducir un momento de balanceo que supere los alerones del planeador. La separación mínima recomendada es de al menos 3 minutos tras aeronaves pesadas y 3 diámetros de rotor en proximidad de helicópteros en estacionario.
]

/ #strong[TWR (Torre de Control de Aeródromo / Aerodrome Control Tower)] <glosario-twr>: #block[
Dependencia ATS establecida para prestar servicio de control al tránsito de aeródromo.
]

/ #strong[Térmica] <glosario-termica>: #block[
Corriente convectiva ascendente de aire formada por el calentamiento diferencial del suelo. El sol calienta el terreno, el terreno calienta el aire en contacto y este asciende por flotabilidad. Es la fuente principal de sustentación en el vuelo a vela de distancia. Su intensidad depende del diferencial de temperatura suelo--atmósfera libre.
]

/ #strong[UOP (Incertidumbre de posición / Uncertainty of Position)] <glosario-uop>: #block[
Situación en la que el piloto no está seguro de su posición exacta. El protocolo es mantener el rumbo, confiar en la estima, buscar referencias grandes y, si persiste, asegurar una toma.
]

/ #strong[UTC (Tiempo Universal Coordinado / Hora Zulu)] <glosario-utc>: #block[
Referencia horaria única de la aviación, correspondiente a la hora del meridiano de Greenwich. Evita las confusiones por husos horarios y cambios estacionales; en España la hora local es UTC+1 en invierno y UTC+2 en verano.
]

/ #strong[VA (Velocidad de maniobra / Maneuvering Speed)] <glosario-va>: #block[
Velocidad máxima a la que pueden aplicarse deflexiones totales en un solo mando sin causar daños estructurales. Por debajo de VA, ante una deflexión brusca completa, el planeador entra en pérdida antes de generar suficientes Gs para superar su límite de carga. Por encima de VA, esa protección desaparece. Importante: la VA no cubre entradas simultáneas en más de un eje de control; incluso por debajo de VA, combinar timón y palanca a fondo puede superar los límites estructurales.
]

/ #strong[VAC (Visual Approach Chart --- Carta de Aproximación Visual)] <glosario-vac>: #block[
Carta de un aeródromo concreto con los puntos de notificación visual del CTR, frecuencias de la Torre, rutas preferentes de acceso y salida VFR y obstáculos del entorno. Publicada en el AIP España para cada aeródromo.
]

/ #strong[Vaguada (surco de bajas presiones / trough)] <glosario-vaguada>: #block[
Extensión de una borrasca en forma de lengua alargada hacia una zona de mayor presión. Concentra los efectos de la baja presión: inestabilidad, cúmulos convectivos, chubascos y turbulencia. Genera líneas de convergencia dinámica.
]

/ #strong[Variación magnética (Declinación)] <glosario-variacion-magnetica>: #block[
Diferencia angular entre el norte verdadero y el norte magnético en un punto dado. En la carta se representa con las líneas isógonas. Regla de cálculo: "Declinación Oeste, rumbo suma".
]

/ #strong[Variómetro] <glosario-variometro>: #block[
Instrumento que indica la velocidad vertical del planeador. Es la herramienta esencial del vuelo sin motor para detectar y centrar ascendencias; en su variante de energía total descuenta las maniobras del piloto.
]

/ #strong[VDF (VHF Direction Finding --- Radiogoniometría VHF)] <glosario-vdf>: #block[
Sistema que determina el rumbo de una aeronave a partir de la dirección de su señal radio. Los códigos Q asociados (QDM, QDR, QTE) permiten al FIS indicar al piloto el rumbo para llegar o alejarse de la estación, útil en caso de desorientación.
]

/ #strong[Velocidad de mejor planeo (V#sub[G])] <glosario-velocidad-de-mejor-planeo>: #block[
Velocidad a la que el planeador obtiene su máxima distancia recorrida por unidad de altura perdida en aire en calma (máxima fineza, correspondiente al L/D máximo determinado por la tangente a la curva polar).
]

/ #strong[Velocidad de mínimo descenso (Minimum Sink Speed)] <glosario-velocidad-de-minimo-descenso>: #block[
Velocidad a la que el planeador pierde la menor cantidad de altura posible por unidad de tiempo (obtenida en el vértice superior de la curva polar), óptima para centrar y explotar térmicas débiles.
]

/ #strong[VFR (Reglas de vuelo visual / Visual Flight Rules)] <glosario-vfr>: #block[
Reglas aplicables a vuelos realizados con referencias visuales y dentro de los mínimos meteorológicos y operativos correspondientes; la separación proporcionada por ATC depende de la clase de espacio aéreo y de los tráficos implicados.
]

/ #strong[VHF (Very High Frequency --- Muy Alta Frecuencia)] <glosario-vhf>: #block[
Banda de radiofrecuencia entre 30 MHz y 300 MHz. Las comunicaciones aeronáuticas civiles de voz van en la sub-banda de 118,000 a 136,975 MHz con modulación de amplitud (AM). Las ondas VHF viajan en línea recta (#strong[line of sight]), por lo que el alcance crece con la altitud. Espaciado de canales en Europa: 8,33 kHz desde el Reglamento (UE) n.º 1079/2012.
]

/ #strong[Viento en cola (Tramo de viento en cola / Downwind)] <glosario-viento-en-cola>: #block[
Tramo del circuito de tráfico aéreo paralelo a la pista activa realizado en sentido contrario a la dirección de aterrizaje, donde se ejecutan las comprobaciones previas al aterrizaje (lista FUSTALL).
]

/ #strong[Viento geostrófico] <glosario-viento-geostrofico>: #block[
Viento que sopla paralelo a las isobaras en niveles superiores a 1.000 m sobre el suelo, resultado del equilibrio entre la fuerza del gradiente de presión y la fuerza de Coriolis. En superficie, la fricción rompe este equilibrio y el viento cruza las isobaras hacia la baja presión con un ángulo de unos 30°.
]

/ #strong[Virga] <glosario-virga>: #block[
Precipitación que cae desde la base de una nube pero se evapora antes de alcanzar el suelo. La evaporación absorbe calor de la columna de aire, que se vuelve densa y desciende violentamente generando una microrráfaga (#strong[downburst]). La virga es un aviso visual de turbulencia severa y cizalladura debajo de ella, incluso en cielos aparentemente despejados.
]

/ #strong[VMC (Condiciones meteorológicas visuales / Visual Meteorological Conditions)] <glosario-vmc>: #block[
Condiciones de visibilidad y distancia a nubes iguales o superiores a los mínimos aplicables.
]

/ #strong[VNE (Velocidad de nunca exceder / Never Exceed Speed)] <glosario-vne>: #block[
Límite absoluto de velocidad del planeador, indicado por la línea roja en el anemómetro. Superarla expone el planeador al riesgo de flutter aeroelástico, que puede desintegrar la estructura en segundos, sin previo aviso. La VNE disminuye con la altitud porque la TAS crece respecto a la IAS en aire menos denso. Cerca de la VNE, las deflexiones de mando deben limitarse a un tercio de su recorrido total. Regulada en CS-22.1505.
]

/ #strong[VOLMET] <glosario-volmet>: #block[
Emisión meteorológica continua para aeronaves en vuelo. Retransmite METAR, TAF y SIGMET de varios aeropuertos de una región en bucle. A diferencia del ATIS, que cubre un solo aeródromo, el VOLMET permite evaluar condiciones en múltiples alternos sin saturar la frecuencia de control.
]

/ #strong[VOR (Radiofaro omnidireccional VHF / VHF Omnidirectional Radio Range)] <glosario-vor>: #block[
Radioayuda que proporciona radiales magnéticos respecto de una estación terrestre.
]

/ #strong[VRA (Velocidad máxima en aire turbulento / Rough Air Speed)] <glosario-vra>: #block[
Velocidad máxima a la que puede volarse en aire turbulento. Es la marca que separa los arcos del anemómetro según CS 22.1545: en la VRA termina el arco verde (operación normal) y empieza el amarillo (precaución, solo aire en calma). No debe confundirse con la VA, que es un límite estructural frente a deflexiones de mando y no se marca en la esfera, aunque en muchos veleros ambas tengan valores próximos.
]

/ #strong[Vuelo de ladera (Ridge soaring)] <glosario-vuelo-de-ladera>: #block[
Técnica de planeo que consiste en volar aprovechando el viento dinámico ascendente desviado hacia arriba por el relieve de una montaña o cordillera en la cara de barlovento.
]

/ #strong[Vuelo de onda (Wave soaring)] <glosario-vuelo-de-onda>: #block[
Técnica de planeo que aprovecha el flujo ondulatorio estacionario y laminar (onda orográfica) que se genera a sotavento de un sistema montañoso en condiciones de fuerte viento estable, permitiendo alcanzar grandes altitudes en el lado ascendente de las ondas.
]

/ #strong[WADA (World Anti-Doping Agency)] <glosario-wada>: #block[
Agencia Mundial Antidopaje. Organización internacional que regula y controla exhaustivamente el consumo de sustancias y dopaje en deportistas de competición, siendo los campeonatos de vuelo a vela sometidos también a este mismo estándar.
]

/ #strong[WCA (Ángulo de corrección de deriva / Wind Correction Angle)] <glosario-wca>: #block[
Ángulo que se aplica al rumbo, apuntando el morro hacia el viento, para compensar la deriva y mantener la trayectoria deseada sobre el terreno.
]

/ #strong[Zona peligrosa (D de Danger)] <glosario-zona-peligrosa>: #block[
Área del espacio aéreo de dimensiones definidas en la que pueden existir o desarrollarse actividades peligrosas para el vuelo en momentos específicos.
]

/ #strong[Zona prohibida (P de Prohibited)] <glosario-zona-prohibida>: #block[
Área del espacio aéreo de dimensiones definidas sobre territorio terrestre o aguas jurisdiccionales cuyo vuelo está prohibido.
]

/ #strong[Zona restringida (R de Restricted)] <glosario-zona-restringida>: #block[
Área del espacio aéreo de dimensiones definidas en la que el vuelo está sometido a condiciones restrictivas especificadas.
]

/ #strong[Zonas P/R/D] <glosario-zonas-p>: #block[
Zonas de la carta con restricciones de uso del espacio aéreo: P (prohibida), R (restringida) y D (peligrosa), identificadas con una letra y un número (p.~ej. LER-71). No son clases de espacio aéreo.
]

/ #strong[Ángulo de ataque crítico] <glosario-angulo-de-ataque-critico>: #block[
Ángulo de ataque máximo que el ala puede soportar antes de que el flujo de aire se desprenda del extradós y la sustentación se destruya. Para la mayoría de los perfiles de planeador se sitúa entre 15° y 18°. Su superación, sea cual sea la velocidad, el peso o la altitud, provoca siempre la pérdida (#strong[stall]).
]

= Bibliografía y fuentes
<bibliografía-y-fuentes>
Esta bibliografía es común a los nueve libros del manual de formación #link(<glosario-spl>)[SPL]#index("SPL"). Reúne las fuentes normativas, los manuales técnicos y los apuntes de instrucción que se han utilizado como referencia para elaborar el contenido de la colección.

#strong[Apuntes de instrucción (DTO Fuentemilanos)]

Apuntes de teoría de #strong[Iñaqui Ulibarri García de la Cueva] para la Organización de Formación Declarada (DTO) de Fuentemilanos, organizados por asignatura del temario SPL.

#strong[Normativa y reglamentación]

- #strong[Easy Access Rules for Sailplanes]. Agencia de la Unión Europea para la Seguridad Aérea (#link(<glosario-easa>)[EASA]#index("EASA")). Compendio consolidado del Reglamento (UE) 2018/1976 ---que contiene la #strong[#link(<glosario-part-sfcl>)[Part-SFCL]#index("Part-SFCL")] (licencias) y la #strong[#link(<glosario-part-sao>)[Part-SAO]#index("Part-SAO")] (operaciones)--- junto con sus #link(<glosario-amc>)[AMC]#index("AMC") y #link(<glosario-gm>)[GM]#index("Material Guía"). #link("https://www.easa.europa.eu/sites/default/files/dfu/Sailplane%20Rule%20Book.pdf")
- #strong[Reglamento de Ejecución (UE) n.º 923/2012 --- #link(<glosario-sera>)[SERA]#index("SERA")] (#emph[Standardised European Rules of the Air]). Reglas del aire comunes para la Unión Europea (versión consolidada). En España se aplica mediante el Real Decreto 552/2014. #link("https://eur-lex.europa.eu/legal-content/ES/TXT/PDF/?uri=CELEX:02012R0923-20250501")
- #strong[Ley 21/2003, de 7 de julio, de Seguridad Aérea]. Jefatura del Estado (España). Publicada en el BOE núm. 162, de 8 de julio de 2003. Marco legal nacional que complementa la normativa europea.

#strong[Anexos al Convenio de Chicago (#link(<glosario-oaci>)[OACI]#index("OACI"))]

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

#heading(level: 1, outlined: false, numbering: none)[Índice alfabético]
<indice-alfabetico>
#columns(3, gutter: 15pt)[
  #show par: pad.with(left: 0.65em)
  #make-index(title: none)
]
#colofon[
#strong[Colofón]

Este manual se compone a partir de fuentes en Quarto Markdown, sin intermediarios: los ficheros #NormalTok(".qmd"); de este repositorio son la versión canónica.

Compuesto con Quarto 1.9.38 y la extensión #NormalTok("orange-book-es");, un derivado en español del paquete #NormalTok("orange-book");. La familia tipográfica es Libertinus.

#strong[Versión 0.8.5] · Última actualización: 20 de julio de 2026

https:\/\/github.com/VuelaLibre-net/teoria-licencia-SPL

]



