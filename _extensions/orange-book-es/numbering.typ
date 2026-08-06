// Numbering tied to the current chapter, with a part prefix in the complete
// manual. Source .qmd remains shared with the nine standalone books.
#let chapter-number(it, parentheses: false) = context {
  let appendix = appendix-state.at(here()) != none
  let part = if manual-completo-state.at(here()) {
    part-counter.at(here()).first()
  } else {
    none
  }
  let number = numero-encabezado(
    (counter(heading).at(here()).first(), it),
    part: part,
    appendix: appendix,
  )
  if parentheses { "(" + number + ")" } else { number }
}

#let equation-numbering = it => chapter-number(it, parentheses: true)
#let callout-numbering = it => chapter-number(it)
#let subfloat-numbering(n-super, subfloat-idx) = context {
  let appendix = appendix-state.at(here()) != none
  let part = if manual-completo-state.at(here()) {
    part-counter.at(here()).first()
  } else {
    none
  }
  numero-encabezado(
    (counter(heading).at(here()).first(), n-super, subfloat-idx),
    part: part,
    appendix: appendix,
  )
}
// Theorem configuration for theorion
// Chapter-based numbering (H1 = chapters)
#let theorem-inherited-levels = 1

// Appendix-aware theorem numbering
#let theorem-numbering(loc) = {
  if appendix-state.at(loc) != none { "A.1" } else { "1.1" }
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
