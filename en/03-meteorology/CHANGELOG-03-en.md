# Changelog — 03. Meteorology (English edition)

This log exists so that **a reviewer does not have to reread the whole book**. Each entry says what
changed, in which chapter, and whether the change affects the technical content or only the layout.

**How to read it if you are reviewing:** go to the entry for the version you last reviewed and read
only the "What to reread" lines of the later entries. If you have not reviewed any, start with the
oldest.

The English edition is a translation of the Spanish book `03-meteorologia`. Each `.qmd` records in
its front matter the Spanish file it comes from (`origen`) and the commit of that file it was
translated from (`origen-commit`). Terminology follows `en/terminologia.yml`.

## [In progress]

**What to reread:** **cap06, VFR minima in class G**, the glossary entry *CAVOK*, the licence and the bibliography. The rest is wording only.

### Fixed

* **cap06 and its Anki deck, VFR minima** — the 1,500 m visibility reduction does not apply to
  sailplanes in Spain (Royal Decree 1180/2018, Article 30); the lower band uses whichever of
  3,000 ft AMSL or 1,000 ft above terrain is higher; and flying into IMC no longer has a fixed
  severity of infringement. Ported from the Spanish edition.
* **Glossary, CAVOK** — the full conditions of Implementing Regulation (EU) 2017/373.
* **Bibliography and licence** — ported from the Spanish edition: SERA applies directly in Spain;
  new entries for Royal Decree 1180/2018 (which repealed Royal Decree 552/2014) and for the other
  regulations cited in the collection, with links to their consolidated versions; Annexes 17 and 18
  among the most relevant; and the syllabus is attributed to Part-SFCL, not “EASA-FCL”.
  The list of other regulations is no longer described as “consolidated versions”: the links go
  to the original act, from which EUR-Lex and the BOE give access to the consolidated one.


### Changed

* **cap01–cap10, including the chapter summaries** — prose revised for natural English: shorter
  sentences, plainer wording, fewer calques from the Spanish. The content is unchanged: same
  facts, figures, rules and terminology, and the same structure as the Spanish chapters.
* **Introduction and cap01–cap10** — a second pass on the prose: about fifty sentences made
  shorter and more direct, with fewer set phrases. Content, figures and terminology unchanged.

### Layout and production

* **Covers** — front and back covers in English.

## [0.8.0] — 27 September 2026

**What to reread:** **the whole book.** First complete translation, from Spanish version 1.0-rc.16.

### Added

* **Front matter, chapters 1–10, both appendices, glossary and bibliography** — translated from
  the Spanish edition, in British English with EASA/ICAO terminology.
* **Chapter titles** — taken verbatim from the subject list of AMC1 SFCL.130 (ED Decision
  2020/004/R), items 3.1 to 3.10. The syllabus appendix quotes that list rather than translating
  the Spanish one back.
* **Epigraph** — Wilbur Wright's words (1900, letter to Octave Chanute) are quoted in their
  original English, not translated back from the Spanish.
* **Regulation** — the cap06 box summarising SERA.5001 is a paraphrase, not a quote. Its figures
  (5 km, 1,500 m at 140 kt or less, 3,000 ft AMSL or 1,000 ft above terrain, whichever is higher)
  were checked against the official English text of Implementing Regulation (EU) No 923/2012.
* **Weather codes** — METAR, TAF, SPECI, SIGMET, AIRMET, GAMET and SIGWX groups are ICAO codes and
  stay as they are; only the explanations are translated. CAVOK keeps its ICAO name, and the
  chapter and glossary still warn that *Ceiling And Visibility OK* is a backronym.
* **Spanish context** — AEMET and its AMA service, ENAIRE, the Iberian thermal low, Fuentemilanos
  and the other Spanish sites are kept, with an English gloss where needed: the book is still for
  pilots who fly in Spain. DANA becomes *cut-off low (DANA)*.
* **Weather sources appendix** — the tool descriptions and group labels are translated; tool
  names and addresses do not change.
* **Glossary** — 65 entries in English alphabetical order. The Spanish glossary has 66: its NCA
  entry is the Spanish name for the LCL, so in English it is folded into *LCL (Lifted
  Condensation Level)*, as `en/terminologia.yml` already says. These headings are still proposals
  pending review in `en/terminologia.yml`: advection fog, air mass, altocumulus lenticularis
  (ACSL), anabatic wind, anticyclone (High, H), atmospheric stability, col (barometric col), cold
  front, conditional instability, convergence line, cumulonimbus (Cb), cumulus (Cu), cumulus
  congestus (Cu con), cut-off low (DANA), depression (Low, L), fog, geostrophic wind, hail (GR),
  hypoxia, International Standard Atmosphere (ISA), katabatic wind, LCL (Lifted Condensation
  Level), occluded front (occlusion), QNH, radiation fog, rotor, Stau (upslope cloud),
  supercooled droplets, temperature inversion, thermal, thermodynamic diagram (Skew-T / Stüve),
  tropopause, troposphere, virga and warm front.
* **Anki decks** — the 73 cards of the ten chapters, with the same ids as the Spanish decks.

### Pending

* **Figures** — all 26 figures still carry Spanish text.
* **Covers** — front and back covers are still the Spanish ones.
* **Carried over from the Spanish edition**, to be fixed there first and then ported:
  * five table captions have no `{#tbl-…}` identifier (three in cap03, one each in cap06 and
    cap07), so the PDF drops them and the tables are missing from the list of tables;
  * cap03 announces the Total Totals formula (“Its formula:”) but the formula itself is missing;
  * cap04 says a table sums up the four cloud families, but what follows is a figure; the English
    text says “figure”.
