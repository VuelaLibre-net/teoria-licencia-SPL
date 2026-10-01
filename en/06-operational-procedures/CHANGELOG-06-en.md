# Changelog — 06. Operational Procedures (English edition)

This log exists so that **a reviewer does not have to reread the whole book**. Each entry says what
changed, in which chapter, and whether the change affects the technical content or only the layout.

**How to read it if you are reviewing:** go to the entry for the version you last reviewed and read
only the "What to reread" lines of the later entries. If you have not reviewed any, start with the
oldest.

The English edition is a translation of the Spanish book `06-procedimientos-operativos`. Each
`.qmd` records in its front matter the Spanish file it comes from (`origen`) and the commit of that
file it was translated from (`origen-commit`). Terminology follows `en/terminologia.yml`.

## [In progress]

**What to reread:** the glossary entry *Release failure (towhook jam)*, the winch calls in cap02, the licence and the bibliography. The rest is wording only.

### Fixed

* **cap01** — the cross-reference to interception in Book 4 is chapter 6 (only the source is
  updated: the English already said so).
* **Bibliography and licence** — ported from the Spanish edition: SERA applies directly in Spain;
  new entries for Royal Decree 1180/2018 (which repealed Royal Decree 552/2014) and for the other
  regulations cited in the collection, with links to their consolidated versions; Annexes 17 and 18
  among the most relevant; and the syllabus is attributed to Part-SFCL, not “EASA-FCL”.
* **Glossary, Release failure (towhook jam)** — the signal to the tug was described from “a raised
  position to the side”, the opposite of cap07. It now says what the chapter says: low and to the
  left of the tug, rocking the wings, and never above it, because climbing above the tug lifts its
  tail (kiting) and can drive it into the ground. Corrected in the Spanish edition at the same time.

### Changed

* **cap02, winch calls** — given first in English and then in Spanish, in italics, as in
  Book 4. The full-power call is now the standard “All out, all out, all out” instead of a literal
  “Launch, launch, launch”, and “Glider free” becomes “Glider released”.
* **cap01–cap08** — a pass on the prose: over twenty long sentences split into shorter ones.
  Content, figures and terminology unchanged.
* **Introduction and cap01–cap08** — a second pass on the prose: the chapter openings rewritten
  more directly and about twenty set phrases made plainer. Content, figures and terminology
  unchanged.

### Layout and production

* **Covers** — front and back covers in English.

## [0.8.0] — 28 September 2026

**What to reread:** **the whole book.** First complete translation, from Spanish version 1.0-rc.3
plus the corrected epigraph.

### Added

* **Front matter, chapters 1–8, the appendix, glossary and bibliography** — translated from the
  Spanish edition, in British English with EASA/ICAO terminology.
* **Chapter titles** — taken verbatim from the subject list of AMC1 SFCL.130 (ED Decision
  2020/004/R), items 6.1 to 6.8. The syllabus appendix quotes that list rather than translating
  the Spanish one back.
* **Epigraph** — Wilbur Wright's words, from a letter to his father of 23 September 1900, quoted
  in their original English. The Spanish edition attributed an unsourced sentence to Neil
  Armstrong; it has been corrected in the same change.
* **Regulation** — the requirements in cap01 (SFCL.045, SFCL.115(a)(2), SFCL.125, SFCL.160(e),
  SAO.GEN.130(d)(4) and SAO.GEN.155) were checked against the official English text in the Easy
  Access Rules for Sailplanes, and the weak link reference in cap02 against CS 22.581(b)(2) of
  CS-22 Amendment 3. They are paraphrases, not quotes.
* **Mnemonics** — CB-SIFT-CBE, FUSTALL, WULF, the 7 S and IMSAFE are built on English words and are
  used as they are. CRISE and the “3 P” of the cable-break drill come from Spanish words: they keep
  their letters, and each letter carries its English gloss.
* **Winch radio calls** — as in book 04, the calls between pilot and winch driver are given in
  Spanish, as they are heard at Spanish airfields, in italics between «angle quotes», followed by
  their English translation.
* **Bibliography** — the common bibliography plus the two entries specific to this book: CS-22
  Amendment 3 and the Tost catalogue.
* **Glossary** — 34 entries in English alphabetical order; 7 of them reuse the English definition
  already published in books 01, 02, 03, 05 and 07, where the Spanish text is identical. These
  headings are still proposals pending review in `en/terminologia.yml`: CB-SIFT-CBE, CRISE,
  Decision height, Emergency parachute, FLARM, FUSTALL, IMSAFE, Launch failure, The 7 S, Thermal,
  Traffic circuit (aerodrome circuit) and WULF.
* **Anki decks** — the 74 cards of the eight chapters, with the same ids as the Spanish decks.

### Pending

* **Figures** — all 20 figures still carry Spanish text.
* **Covers** — front and back covers are still the Spanish ones.
* **Carried over from the Spanish edition**, to be fixed there first and then ported:
  * cap01 sends the reader to chapter 8 of book 04 for the interception signals; book 04 has seven
    chapters and they are in chapter 6, which is what the English text says;
  * cap01 says that a single unfavourable IMSAFE answer is enough not to fly, while its summary
    and the Anki card speak of a single “yes”; both wordings are kept;
  * three table captions have no `{#tbl-…}` identifier (Tost weak links in cap02, surfaces in
    cap05, the symptom → action table in cap07), so the PDF drops them and the tables are missing
    from the list of tables;
  * cap07 uses straight quotes in one place ("salvar") instead of «…».
