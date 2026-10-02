# Changelog — 05. Principles of Flight (English edition)

This log exists so that **a reviewer does not have to reread the whole book**. Each entry says what
changed, in which chapter, and whether the change affects the technical content or only the layout.

**How to read it if you are reviewing:** go to the entry for the version you last reviewed and read
only the "What to reread" lines of the later entries. If you have not reviewed any, start with the
oldest.

The English edition is a translation of the Spanish book `05-principios-vuelo`. Each `.qmd` records
in its front matter the Spanish file it comes from (`origen`) and the commit of that file it was
translated from (`origen-commit`). Terminology follows `en/terminologia.yml`.

## [In progress]

**What to reread:** **cap03, phugoid mode**, the glossary entries *Phugoid* and *Spiral dive*, the licence and the bibliography. The rest is wording only.

### Fixed

Ported from the Spanish edition, where these errors have been corrected at the same time:

* **cap03 and Glossary, phugoid mode** — the period did not match (30–60 seconds in the chapter,
  30–50 in the glossary), and neither figure suits a sailplane. The period is proportional to
  speed (Lanchester's approximation, T ≈ 0.45·V with V in m/s), so at normal sailplane speeds it
  is about 10 to 15 seconds. Both texts now say so.
* **Glossary, Spiral dive** — the recovery started with “open the airbrakes”, the opposite of
  cap07. It now follows cap07: level the wings, ease out of the dive and, only if the speed is
  approaching V~NE~, extend the airbrakes smoothly.
* **All chapters and the glossary** — `origen-commit` updated to the corrected Spanish text.
* **Bibliography and licence** — ported from the Spanish edition: SERA applies directly in Spain;
  new entries for Royal Decree 1180/2018 (which repealed Royal Decree 552/2014) and for the other
  regulations cited in the collection, with links to their consolidated versions; Annexes 17 and 18
  among the most relevant; and the syllabus is attributed to Part-SFCL, not “EASA-FCL”.
  The list of other regulations is no longer described as “consolidated versions”: the links go
  to the original act, from which EUR-Lex and the BOE give access to the consolidated one.

### Changed

* **cap01–cap04, cap06 and cap07** — a dozen sentences made shorter and more direct. Content,
  figures and terminology unchanged.
* **Introduction and cap01–cap07** — a second pass on the prose: about forty sentences made
  shorter and more direct, with fewer passives and set phrases. Content, figures and terminology
  unchanged.
* **cap02, reference to Book 8** — the title of Book 8 now reads as on its cover and title
  page: *Aircraft General Knowledge, Airframe, Systems and Emergency Equipment*.

### Layout and production

* **Covers** — front and back covers in English.

## [0.8.0] — 28 September 2026

**What to reread:** **the whole book.** First complete translation, from Spanish version 1.0-rc.8.

### Added

* **Front matter, chapters 1–7, the appendix, glossary and bibliography** — translated from the
  Spanish edition, in British English with EASA/ICAO terminology.
* **Chapter titles** — taken verbatim from the subject list of AMC1 SFCL.130 (ED Decision
  2020/004/R), items 5.1 to 5.7. The syllabus appendix quotes that list rather than translating
  the Spanish one back.
* **Epigraph** — George Cayley's words are quoted in full from the original English of *On Aerial
  Navigation* (1809). The Spanish edition gives only the first half, ending in an ellipsis.
* **Regulatory quote** — cap03 quotes SAO.GEN.130(d)(4) in the official English text of
  Regulation (EU) 2018/1976, taken from the Easy Access Rules for Sailplanes.
* **CS-22 figures** — the load factors in cap05 and in the glossary (+5.3g/−2.65g at V~A~,
  +4.0g/−1.5g at V~D~ for category U; +7.0g/−5.0g for category A) and the references to
  CS 22.1505, CS 22.1545 and CS 22.1585(o)(2) were checked against CS-22 Amendment 3. They are
  paraphrases, not quotes.
* **Speed symbols** — the Spanish subscripts V~z min~ and V~max planeo~ become V~min sink~ and
  V~best glide~. V~A~, V~D~, V~G~, V~NE~ and V~RA~ do not change.
* **Deriva** — in cap03 the Spanish word means the fin (vertical stabiliser), and the English text
  says so. The glossary keeps the heading *Drift*, which `en/terminologia.yml` shares with book 09,
  and its definition now separates drift from the fin.
* **Glossary** — 39 entries in English alphabetical order; 6 of them reuse the English definition
  already published in books 03 and 07, where the Spanish text is identical. Eleven headings were
  missing from `en/terminologia.yml` and have been added (angle of attack, autorotation, spin,
  ground effect, graveyard spiral, adverse yaw, stall, spiral dive, lift, wingtip vortices and
  relative airflow). These headings are still proposals pending review: Autorotation, Bernoulli's
  theorem, Best glide speed (V~G~), Boundary layer, Centre of pressure (CP), Control
  effectiveness, Critical angle of attack, Differential aileron, Dihedral (dihedral angle), Drift,
  Dynamic stability, Glide ratio (L/D), Induced drag, Load factor (n), Parasite drag, Phugoid
  (phugoid mode), Polar curve (speed polar), Relative airflow (relative wind), Spin
  (autorotation), Spiral instability, Static stability, V-n diagram (flight envelope) and
  Weathercock stability.
* **Anki decks** — the 56 cards of the seven chapters, with the same ids as the Spanish decks.

### Pending

* **Figures** — all 14 figures still carry Spanish text.
* **Covers** — front and back covers are still the Spanish ones.
* **Carried over from the Spanish edition**, to be fixed there first and then ported:
  * the glossary entry *Deriva* mixes drift and the fin in a single definition.
