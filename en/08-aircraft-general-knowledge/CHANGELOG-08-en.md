# Changelog — 08. Aircraft General Knowledge, Airframe, Systems and Emergency Equipment (English edition)

This log exists so that **a reviewer does not have to reread the whole book**. Each entry says what
changed, in which chapter, and whether the change affects the technical content or only the layout.

**How to read it if you are reviewing:** go to the entry for the version you last reviewed and read
only the "What to reread" lines of the later entries. If you have not reviewed any, start with the
oldest.

The English edition is a translation of the Spanish book `08-aeronave-sistemas`. Each `.qmd`
records in its front matter the Spanish file it comes from (`origen`) and the commit of that file it
was translated from (`origen-commit`). Terminology follows `en/terminologia.yml`.

## [In progress]

**What to reread:** **cap09, Minimum Inspection Programme**, and its Anki card. The rest is wording
only.

### Fixed

* **cap09 and its Anki deck, Minimum Inspection Programme (ML.A.302)** — the floor of “every year
  or every 100 h, whichever comes first” was applied to every sailplane. The Part-ML MIP requires
  an annual inspection for sailplanes and powered sailplanes, with no hours limit; the 100 h limit
  applies only to touring motor gliders (TMG). Corrected in the Spanish edition at the same time.

### Changed

* **cap01, cap02, cap04, cap06, cap09, cap10, cap12 and cap13** — a pass on the prose: about fifteen
  long sentences split or made more direct. Content, figures and terminology unchanged.
* **Introduction and cap01–cap03, cap05–cap08, cap10, cap11, cap13 and cap14** — a second pass on
  the prose: about thirty set phrases made plainer and more direct. Content, figures and
  terminology unchanged.
* **cap04 and its Anki deck** — the Spanish *Certificado de Pesaje* is called the weighing record,
  as in book 07.

## [0.8.0] — 30 September 2026

**What to reread:** **the whole book.** First complete translation, from Spanish version 0.9.6 plus
the ballast glossary entry and the corrected epigraph.

### Added

* **Front matter, chapters 1–14, the appendix, glossary and bibliography** — translated from the
  Spanish edition, in British English with EASA/ICAO terminology.
* **Title** — *Aircraft General Knowledge, Airframe, Systems and Emergency Equipment*, as on the
  cover. AMC1 SFCL.130 names the subject “Aircraft general knowledge, airframe and systems and
  emergency equipment”; the references to Book 8 in the other English books now use the cover
  title too.
* **Chapter titles** — taken verbatim from the subject list of AMC1 SFCL.130 (ED Decision
  2020/004/R), items 8.1 to 8.14. The syllabus appendix quotes that list rather than translating
  the Spanish one back.
* **Epigraph** — Antoine de Saint-Exupéry's words from *Wind, Sand and Stars* (1939), quoted in
  their English edition. The Spanish edition attributed to him a sentence whose second half does
  not appear in *Terre des hommes*; it has been corrected in the same change.
* **Regulatory quote** — cap14 quotes SAO.OP.150 in the official English text of Regulation (EU)
  2018/1976, the same wording as book 02.
* **Regulation** — the requirements the chapters cite (SAO.IDE.105, SAO.GEN.155, SAO.OP.120,
  SAO.OP.145, SFCL.045, and CS 22.29, 22.303, 22.337, 22.561, 22.711, 22.713, 22.780, 22.1545 and
  22.1555) were checked against the Easy Access Rules for Sailplanes and CS-22 Amendment 3. They
  are paraphrases, not quotes.
* **Mass** — the Spanish MTOW (*Maximum Take-Off Weight*) becomes MTOM (*maximum take-off mass*),
  as EASA writes it and as `en/terminologia.yml` decides.
* **Spanish context** — the Spanish ITV (periodic roadworthiness test) is kept with a gloss, and
  CRISE is presented as a mnemonic built on Spanish words, as in book 06.
* **Glossary** — 46 entries in English alphabetical order; 24 of them reuse the English definition
  already published in books 01 to 07, where the Spanish text is identical. The new heading
  *Ballast* has been added to `en/terminologia.yml`. These headings are still proposals pending
  review: FLARM, Flaps, Gelcoat, Hypoxia, L'Hotellier connector, LiFePO4 (lithium iron phosphate
  battery), Load factor (n), Part-ML (Maintenance of light aircraft), Pitot-static system,
  Polyurethane (PU), Retractable undercarriage, Sandwich construction and Variometer.
* **Anki decks** — the 81 cards of the fourteen chapters, with the same ids as the Spanish decks.

### Pending

* **Figures** — all 22 figures still carry Spanish text.
* **Carried over from the Spanish edition**, to be fixed there first and then ported:
  * the load factor table in cap02 has no `{#tbl-…}` identifier, so the PDF drops its caption and
    the table is missing from the list of tables;
  * the chapters use straight quotes ("…") in 27 places instead of «…».
