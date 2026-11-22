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

**What to reread:** nothing of substance; only the bibliography and the acknowledgements.

### Fixed

* **Bibliography** — Annex 3 joins the ICAO annexes most relevant to the glider pilot; the editions of the Glider Flying Handbook (2024), the Easy Access Rules for Sailplanes (September 2020 revision) and Reichmann's Spanish edition (Paraninfo, 1992) are given. Ported from the Spanish edition.
* **Acknowledgements** — the ✓ legend now says that the review is an instructor's judgement and does not certify every technical or regulatory statement; the sentence on the classic manuals no longer runs into the list of names.

## [0.8.3] — 21 November 2026

**What to reread:** the **21 figures** the audit marked for redrawing (issue #58), in cap01–cap14,
with their captions; no figure in the book is “IN REVIEW” any more, and those 21 now carry English
labels (the other eight still carry Spanish text). In the text, only the new sentence that opens
“Conflict situations” (cap05), the captions of the Certificate of Airworthiness (cap02) and the
occurrence pyramid (cap13), and one conversion in the signals table (cap10).

### Fixed

* **cap06, cap13 and cap14, priority figures** — the three figures that were withdrawn after the
  audit are redrawn, with English labels, and lose the “IN REVIEW” mark and the note in the
  caption. The semicircular rule splits the levels North-South, as in Spain (even + 500 ft from
  270° to 089°, odd + 500 ft from 090° to 269°), not East-West. The occurrence reporting process
  adds the occurrences listed in Regulation 2015/1018 to the mandatory ones and says who each one
  goes to and by when. The scale of infringements grades the same conduct by what it causes
  (Article 44 of Ley 21/2003), with the fines for a private individual and the penalties on the
  licence. They are now drawn by code (`tools/figuras/01_derecho_aereo.py`) and change from JPEG
  to PNG. Issue #58.
* **cap01–cap13, eleven more figures** — redrawn by code with the same script, with English labels,
  and stripped of the mark and the note: the EASA regulatory structure (CS shown apart, as
  certification specifications); the Certificate of Airworthiness (EASA Form 25 for a glider, based
  on Regulation 2018/1139, with no coat of arms or signature, and a new caption explaining
  SAO.GEN.155(c)); the ARC cycle (valid until the third year); medical validity (the rules at 42
  and 51); recency (now with the launch-method rule, SFCL.155); VMC minima (the lower band ends at
  3,000 ft AMSL or 1,000 ft AGL, whichever is higher); the emergency phases (SAR units are
  dispatched in DETRESFA and the RCC is informed from INCERFA); the NOTAM (runway 12R/30L and CLSD);
  the windsock (correctly rounded conversions and the 3 kt as a rough guide); aerodrome signals
  (SERA shapes, the dumb-bell and the yellow cross with their right meaning, and three signals that
  were missing); and the occurrence pyramid (Regulation 996/2010 categories, Heinrich as a note,
  and a new caption). All are now PNG; the windsock and the signals already were. The English text
  of EASA Form 25 is still to be checked against EUR-Lex. Issue #58.
* **cap10** — in the signals table, 3 knots are 5.6 km/h, not 5.5.
* **cap01–cap12, six illustrations** — redrawn with an image generator (ChatGPT), now with English
  labels, and stripped of the mark and the note: the freedoms of the air (the aircraft's country is
  always the “home country”, also in the fifth freedom, whose leg between B and C is highlighted);
  right of way (labelled panels and clear headings, with the glider that gives way in amber);
  minimum heights (the 300 m are measured from the highest obstacle and the ridge-soaring glider
  flies on the windward side); ATC units (the ACC away from the airport and the tower with the
  circuit); the traffic circuit (a glider, with no IP or “joining leg”); and safety versus security
  (no workplace safety or cybersecurity). In cap05, the reference to the right-of-way figure moves
  from the landing case, which it does not show, to the sentence that opens “Conflict situations”.
  Issue #58.
* **cap03, location of registration marks** — the drawing is kept, now with English labels, and
  loses the mark and the note in the caption. Issue #58.

### Layout and production

* **PDF index** — every entry now uses the glossary headword instead of the longest search key or a stray piece of its definition. Acronyms are listed both under the acronym and under its expansion (“CTR” and “Control Zone”). The change is in the shared filter `glosario-enlaces.lua` and affects every book (#46). The word “visibility” no longer links to the CAVOK glossary entry.

## [0.8.2] — 18 November 2026

**What to reread:** nothing. The content does not change from `0.8.1`: only the acknowledgements.

### Layout and production

* **Acknowledgements** — Luís Ferreira, Encarnación Novillo-Fertrell, Carlos Bravo and Sergi Pujol now carry the ✓ for validating the Spanish edition of this book.

## [0.8.1] — 2 October 2026

**What to reread:** **the whole book.** These are the corrections of the audit of 1 October 2026,
ported from the Spanish edition, and they touch all fourteen chapters, the glossary, the
bibliography and the licence. The 21 figures that have to be redrawn carry an “IN REVIEW”
watermark and end their caption with *(FIX: …)*, saying what is wrong; they include the three that
had been withdrawn (semicircular rule, reporting flow and scale of infringements).

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
  The list of other regulations is no longer described as “consolidated versions”: the links go
  to the original act, from which EUR-Lex and the BOE give access to the consolidated one.

### Changed

* **Figures to be redrawn: “IN REVIEW” watermark and caption note** — the 21 figures in which the
  audit found an error carry a diagonal “IN REVIEW” watermark in the PDF, the EPUB and the web
  edition, and their caption ends with *(FIX: …)*, saying what is wrong. The note is left out of the
  list of figures. The warnings some captions already carried now use this format. The three
  figures that had been withdrawn come back marked in the same way. Each mark and note goes when
  its figure is replaced.
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
