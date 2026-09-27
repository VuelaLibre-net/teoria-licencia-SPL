# Changelog — 04. Communications (English edition)

This log exists so that **a reviewer does not have to reread the whole book**. Each entry says what
changed, in which chapter, and whether the change affects the technical content or only the layout.

**How to read it if you are reviewing:** go to the entry for the version you last reviewed and read
only the "What to reread" lines of the later entries. If you have not reviewed any, start with the
oldest.

The English edition is a translation of the Spanish book `04-comunicaciones`. Each `.qmd` records
in its front matter the Spanish file it comes from (`origen`) and the commit of that file it was
translated from (`origen-commit`). Terminology follows `en/terminologia.yml`.

## [In progress]

**What to reread:** nothing new in substance; wording only.

### Changed

* **cap01, cap02, cap03, cap04 and cap07** — a few sentences reworded to read more naturally.
  The Spanish radio phrases, figures, rules and terminology do not change.
* **Introduction and cap01–cap07** — a fuller pass on the English prose: about thirty sentences
  made shorter and more direct. The Spanish radio phrases, figures, rules and terminology do not
  change.

## [0.8.0] — 27 September 2026

**What to reread:** **the whole book.** First complete translation, from Spanish version 1.0-rc.15
plus the corrected epigraph.

### Added

* **Front matter, chapters 1–7, both appendices, glossary and bibliography** — translated from
  the Spanish edition, in British English with EASA/ICAO terminology.
* **Chapter titles** — taken verbatim from the subject list of AMC1 SFCL.130 (ED Decision
  2020/004/R), items 4.1 to 4.7. The syllabus appendix quotes that list, including items 4.2.1
  to 4.2.3, rather than translating the Spanish one back.
* **Radio phraseology stays in Spanish** — every radio example (ATC calls, readbacks, blind
  broadcasts, winch and aerotow calls, emergency messages and the exercise solutions) is given in
  Spanish, as it is heard and used at Spanish airfields, in italics between «angle quotes»,
  followed by its English translation in “inverted commas”. Single words such as *Afirma*,
  *Recibido* or *Solicito* carry their ICAO English equivalent (Affirm, Roger, Request). The
  introduction explains the convention to the reader. The ICAO phonetic alphabet table uses the
  ICAO spelling (Echo) and notes that Spanish phraseology writes *Eco*; the digits table shows the
  ICAO word next to the Spanish one.
* **Epigraph** — William H. Whyte's words (*Fortune*, 1950) are quoted in their original
  English. The Spanish edition attributed them to George Bernard Shaw; it has been corrected in the
  same change.
* **Regulatory quotes** — cap06 quotes SERA.11015(c) in the official English text of Implementing
  Regulation (EU) No 923/2012. The interception signals and phrases (Tables S11-1, S11-2 and
  S11-3) and the tower light signals use the official English wording; for series of white flashes
  in flight that adds “and proceed to apron”, which the Spanish chapter leaves out.
* **Frequencies and codes** — frequencies use the decimal point (122.600); Q codes, transponder
  codes, MAYDAY and PAN PAN are unchanged. Inside Spanish radio phrases the Spanish decimal comma
  is kept, because that is how the phrase is written in Spanish.
* **Glossary** — 39 entries in English alphabetical order; 20 of them reuse the English definition
  already published in books 01, 03 and 07, where the Spanish text is identical. These headings
  are still proposals pending review in `en/terminologia.yml`: MAYDAY, PAN PAN, QDM, QFE, QNH,
  Squawk and VOLMET.
* **Anki decks** — the 72 cards of the seven chapters, with the same ids as the Spanish decks.
  Phraseology cards keep the Spanish phrase with its translation.

### Pending

* **Figures** — all 12 figures still carry Spanish text.
* **Covers** — front and back covers are still the Spanish ones.
* **Carried over from the Spanish edition**, to be fixed there first and then ported:
  * cap01, cap02 and cap03 send the reader to “chapter 9” for VHF spacing and transponder codes,
    a leftover from when the book had nine chapters; the English text points to chapter 7;
  * cap01 has lost the arrow between each number and its spoken form (“«34»  «tres cuatro»”);
    the English text uses a colon;
  * cap02 expands CTR as «zona de tránsito de aeródromo»; the English text says control zone;
  * cap04 gives *Ceiling and Visibility OK* as the meaning of CAVOK, while the glossary warns
    that it is only a backronym; the English text says “read informally as”;
  * three table captions have no `{#tbl-…}` identifier (digits in cap01, wing-runner signals in
    cap02, frequencies in cap07), so the PDF drops them and the tables are missing from the list
    of tables.
