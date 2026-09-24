# Changelog — 07. Flight Performance and Planning (English edition)

This log exists so that **a reviewer does not have to reread the whole book**. Each entry says what
changed, in which chapter, and whether the change affects the technical content or only the layout.

**How to read it if you are reviewing:** go to the entry for the version you last reviewed and read
only the "What to reread" lines of the later entries. If you have not reviewed any, start with the
oldest.

The English edition is a translation of the Spanish book `07-planificacion-rendimiento`. Each `.qmd`
records in its front matter the Spanish file it comes from (`origen`) and the commit of that file it
was translated from (`origen-commit`). Terminology follows `en/terminologia.yml`.

## [In progress]

**What to reread:** **introduction, box descriptions.** Each now opens with “These…”, and the
Airmanship one ends “airmanship sets the standard”. The rest is wording only.

### Changed

* **Introduction and cap01–cap05** — prose reworded to read less like a translation: Spanish-style
  dashed asides become commas, brackets or colons, and some literal phrasings are rewritten. No
  figures, formulas, regulatory quotes or glossary terms change.

### Layout and production

* **Covers** — front and back covers in English, in `recursos/covers/` like the Spanish ones.

## [0.8.0] — 24 September 2026

**What to reread:** **the whole book.** First complete translation, from Spanish version 1.0-rc.3.

### Added

* **Front matter, chapters 1–5, syllabus appendix, glossary and bibliography** — translated from the
  Spanish edition, in British English with EASA/ICAO terminology.
* **Chapter titles** — taken verbatim from the subject list of AMC1 SFCL.130 (ED Decision
  2020/004/R). Chapter 1 is therefore *Mass and balance*, where the Spanish reads *Masa y centro
  de gravedad*.
* **Syllabus appendix** — the item list is quoted from the original English AMC1 SFCL.130, not
  translated back from the Spanish.
* **cap01, cap02, glossary** — *MTOW* becomes **MTOM** (maximum take-off mass), the EASA term.
* **Licence page, validation by AESA** — adds that AESA's validation covers the original Spanish
  edition and that this translation has not been submitted to AESA.
* **Acknowledgements** — generated from the same reviewer list as the Spanish book; a ✓ marks the
  reviewers who validated the Spanish edition.
* **Anki decks** — the 42 cards of the five chapters, with the same ids as the Spanish decks.

### Pending

* **Figures** — the three charts drawn in code (cap01 loading envelope, cap02 IAS/TAS, cap05
  three-point method) are in English. The other seven still carry Spanish text: cap01 datum and
  moment table and CG limits chart; cap02 annotated polar, polar with weight and polar with wind;
  cap04 flight plan form; cap05 glide cone illustration.
* **Covers** — front and back covers are still the Spanish ones.
