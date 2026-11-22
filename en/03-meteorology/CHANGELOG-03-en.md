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

**What to reread:** the whole book. The corrections from the audit of the Spanish edition
(21 November 2026) have been ported: they change figures, thresholds and rules of thumb in every
chapter. Chapters cap03 and cap07 are also brought up to date with the Spanish wording of their
formulas and table labels.

### Fixed

* **cap05, freezing rain** — it forms clear ice, not opaque ice; the escape is to leave the area towards air with no precipitation, because the warmer air is usually above and descending may not get you out. Also in the glossary.
* **cap03, CAPE and stability indices** — a CAPE of 1,000–2,500 J/kg no longer rules out thunderstorms; the TT and K formulas are restored; the TT scale is attributed to the western United States (AWS/TR-79/006) with Miller's lower scale as a comparison; the flat-country/mountain rule for TT and K is removed; one band per index in the summary table; the LI sign is corrected; the three stabilities (absolute, conditional) are defined against the dry and saturated lapse rates; the cumulus-base formula gives height above the aerodrome, also in the summary.
* **cap10, METAR and TAF** — SPECI is issued for improvement as well as deterioration and, in Spain, not for wind; SKC is a US code; NSC is what a human observer writes; `VVnnn`/`VV///`, `NSW` and `WS R18` corrected; TAF in Spain is 24 or 30 hours, renewed every 6 hours; AIRMET and GAMET up to FL150 in Spain; the obligation to study the reports is SERA.2010(b), and AEMET is the official source as designated provider, not a “binding” one; the 850 hPa offset depends on the airfield's altitude and the CCL is qualified.
* **cap01** — lower density does not mean less lift but more true airspeed for the same indicated airspeed.
* **cap02** — Foehn warming is of the order of 5–10 °C, with a worked example; the surface wind crosses the isobars by 10–45° depending on the surface; the sea breeze has turbulent thermals and can kill the day's thermals; figure references corrected and a new section on cloud streets and terrain-induced convergence.
* **cap04** — the WMO's three étages with their heights; mist (BR) from 1,000 to 5,000 m, distinct from haze; Cb avoidance is a guide (the FAA's 20 NM for severe thunderstorms), not a rule; advection fog typical of coasts in summer.
* **cap05 to cap09** — downburst and microburst distinguished; the rain margin comes from the AFM; the warm front can hide embedded Cb; occlusions are cold or warm; air masses classified by source region; the winter anticyclone, the pressure-system table, the east-facing slopes, autumn and the Iberian thermal low (almost permanent in summer); rime and clear ice; rotor clouds; hail under the anvil; wind shear on final.
* **Glossary** — new entries: CCL, density altitude, dew point, equilibrium level, pressure altitude, stationary front, TCU, Total Totals and TREND; corrections to AIRMET, buffet, CAPE, cumulus, downburst, Foehn, fog, GAMET, K-Index, NSC, ridge, rotor, SIGMET, SPECI, TAF, virga and wake turbulence; the introduction says it is in alphabetical order.
* **Appendices and epigraph** — AEMET's AMA is listed as the official source with its low-level products; the wave wind criterion refers to summit height; the syllabus appendix gives the exam format (AMC1 SFCL.135); the epigraph names its source.

### Added

* **cap01** — composition and layers of the atmosphere; pressure altitude and density altitude.
* **cap05** — how precipitation forms and what types there are.
* **cap10** — radar, satellite and weather charts.
* **Bibliography** — a “Meteorology” section with Part-MET, AIP España GEN 3.5, the WMO Cloud Atlas, FAA AC 00-6B and AC 00-24C, AWS/TR-79/006 and the National Atlas of Spain. Annex 3 joins the ICAO annexes most relevant to the glider pilot, and the editions of the Glider Flying Handbook (2024), the Easy Access Rules for Sailplanes (September 2020 revision) and Reichmann's Spanish edition (Paraninfo, 1992) are given. Ported from the Spanish edition.
* **Anki** — the cards of cap01 to cap10 follow the changes above; the ids are unchanged.

### Layout and production

* **Figures under review** — twelve figures carry the class `.corregir`, the “IN REVIEW” watermark and a *(FIX: …)* note at the end of the caption until they are redrawn; the filter is enabled in `_quarto.yml`.
* **Acknowledgements** — the ✓ legend now says that the review is an instructor's judgement and does not certify every technical or regulatory statement; the sentence on the classic manuals no longer runs into the list of names.

## [0.8.3] — 21 November 2026

**What to reread:** nothing. The content is unchanged since `0.8.2`: only the PDF index, which is
layout.

### Layout and production

* **PDF index** — every entry now uses the glossary headword instead of the longest search key or a stray piece of its definition. Acronyms are listed both under the acronym and under its expansion (“CTR” and “Control Zone”). The change is in the shared filter `glosario-enlaces.lua` and affects every book (#46). The word “visibility” no longer links to the CAVOK glossary entry.

## [0.8.2] — 18 November 2026

**What to reread:** nothing. The content does not change from `0.8.1`: only the acknowledgements.

### Layout and production

* **Acknowledgements** — Luís Ferreira, Encarnación Novillo-Fertrell, Carlos Bravo and Sergi Pujol now carry the ✓ for validating the Spanish edition of this book.

## [0.8.1] — 2 October 2026

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
