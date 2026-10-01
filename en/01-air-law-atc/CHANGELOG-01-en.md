# Changelog — 01. Air Law and ATC Procedures (English edition)

This log exists so that **a reviewer does not have to reread the whole book**. Each entry says what
changed, in which chapter, and whether the change affects the technical content or only the layout.

**How to read it if you are reviewing:** go to the entry for the version you last reviewed and read
only the "What to reread" lines of the later entries. If you have not reviewed any, start with the
oldest.

The English edition is a translation of the Spanish book `01-derecho-aereo-atc`. Each `.qmd`
records in its front matter the Spanish file it comes from (`origen`) and the commit of that file it
was translated from (`origen-commit`). Terminology follows `en/terminologia.yml`.

## [In progress]

**What to reread:** **the whole book.** These are the corrections of the audit of 1 October 2026,
ported from the Spanish edition, and they touch all fourteen chapters, the glossary, the
bibliography and the licence. Three figures are withdrawn until they are redrawn (semicircular
rule, reporting flow and scale of infringements), and five carry a warning in their caption.

### Fixed

* **cap01–cap14, glossary and Anki decks** — ported from the Spanish edition, where the audit of the
  book was corrected. The main changes: Royal Decree 1180/2018 replaces the repealed 552/2014; the
  1,500 m visibility reduction does not apply to sailplanes in Spain; right of way by category
  applies only when converging; which documents go on board (SAO.GEN.155, SFCL.045); what ATC
  separates in each airspace class; the transponder rule (AIP ENR 1.6); launch-method recency
  (SFCL.155) and TMG privileges; emergency phases under ATS.TR.405; AFIS, SUP and PIB; all SERA
  ground signals and the legal basis of external take-off sites; ARCC coverage and beacons; dangerous
  goods under SAO.GEN.150; the accident investigation authority that replaced the CIAIAC; mandatory
  occurrence reporting under Regulation 2015/1018; and the infringements regime of Ley 21/2003.
* **Bibliography and licence** — ported from the Spanish edition: SERA applies directly in Spain;
  new entries for Royal Decree 1180/2018 (which repealed Royal Decree 552/2014) and for the other
  regulations cited in the collection, with links to their consolidated versions; Annexes 17 and 18
  among the most relevant; and the syllabus is attributed to Part-SFCL, not “EASA-FCL”.

### Changed

* **cap07 and cap08, radio examples** — the RMZ call and the ATC and FIS examples now carry
  their Spanish equivalent in italics after the English, as in Book 4.
* **cap01, cap02, cap04, cap05, cap09, cap14** — some literal phrasings reworded to read less
  like a translation. No figures, regulatory quotes or glossary terms change.
* **Epigraph and cap01–cap14, including the chapter summaries** — prose revised throughout for
  natural English: shorter sentences, fewer semicolon chains, no calques from the Spanish. The
  content is unchanged: same facts, figures, rules and terminology, and the same structure as the
  Spanish chapters.
* **cap02, reference to Book 8** — the title of Book 8 now reads as on its cover and title
  page: *Aircraft General Knowledge, Airframe, Systems and Emergency Equipment*.

### Layout and production

* **Covers** — front and back covers in English.

## [0.8.0] — 25 September 2026

**What to reread:** **the whole book.** First complete translation, from Spanish version 1.0-rc.14.

### Added

* **Front matter, chapters 1–14, syllabus appendix, glossary and bibliography** — translated from
  the Spanish edition, in British English with EASA/ICAO terminology.
* **Chapter titles** — taken verbatim from the subject list of AMC1 SFCL.130 (ED Decision
  2020/004/R), items 1.1 to 1.14. The syllabus appendix quotes that list rather than translating
  the Spanish one back.
* **Regulatory quotes** — cap05 (SERA.5005(f)) and cap09 (SERA.2010) quote the official English
  text of Regulation (EU) No 923/2012.
* **Spanish law** — Spanish laws and bodies keep their Spanish names with an English gloss on first
  mention (Ley 21/2003, Real Decreto 552/2014, AESA, DGAC, CIAIAC). The summaries of Spanish law in
  cap05 and cap14 are marked as unofficial translations.
* **Spanish mnemonics** — *EC = España Civil* (cap03) and *V for Venid* (cap11) are kept and
  explained; the semicircular rule (cap06) becomes “North Even / South Odd”.
* **Glossary** — 95 entries in English alphabetical order. These headings are still proposals
  pending review in `en/terminologia.yml`: AESA, CIAIAC, DGAC, HJ, LSA, Part-ML, QFE, QNE, QNH,
  occurrence reporting system (SNS), and the danger, prohibited and restricted areas.
* **Anki decks** — the 68 cards of the fourteen chapters, with the same ids as the Spanish decks.

### Pending

* **Figures** — all 29 figures still carry Spanish text.
* **Covers** — front and back covers are still the Spanish ones.
