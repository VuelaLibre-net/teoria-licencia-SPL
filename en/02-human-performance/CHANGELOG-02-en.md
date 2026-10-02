# Changelog — 02. Human Performance (English edition)

This log exists so that **a reviewer does not have to reread the whole book**. Each entry says what
changed, in which chapter, and whether the change affects the technical content or only the layout.

**How to read it if you are reviewing:** go to the entry for the version you last reviewed and read
only the "What to reread" lines of the later entries. If you have not reviewed any, start with the
oldest.

The English edition is a translation of the Spanish book `02-factores-humanos`. Each `.qmd`
records in its front matter the Spanish file it comes from (`origen`) and the commit of that file it
was translated from (`origen-commit`). Terminology follows `en/terminologia.yml`.

## [In progress]

**What to reread:** **the whole book.** The corrections of the audit of book 02 (1 October 2026) are ported from the Spanish edition and touch the four chapters, the glossary, the bibliography, the syllabus appendix, the introduction and the epigraph. Also **cap04, the oxygen AMC**, and the licence.

### Fixed

* **Audit of book 02, ported from the Spanish edition** — the same corrections as in the Spanish
  book, chapter by chapter:
  * cap01: Maslow's hierarchy has physiological needs at its base, not safety; the accident
    statistics are attributed and dated (Ceipek 2019, FAA, EASA Annual Safety Review 2019); the
    definition of human factors is ICAO's (Doc 9683), not the UK HSE's; just culture does not cover
    gross negligence (Regulation (EU) No 376/2014); Reason's “planned” sequence; SHELL without
    crediting Hawkins with the second L.
  * cap02: IMSAFE as an FAA checklist, whose E is *Emotion*; alcohol under SAO.GEN.130(f) and
    SERA.2020, with the AMC as an acceptable means of compliance, not a legal limit; colour
    perception only for a night rating with an LAPL certificate; clear the sector you are turning
    into first; MED.A.020 in full; See and Avoid with FAA figures; Selye without a timescale of
    minutes; acute and chronic fatigue; dehydration, medication and doping; dysbarism in the
    descent; diving and blood donation; night vision from about 5,000 ft; black-hole approach;
    carbon monoxide symptoms; the illusions figure moved and cited.
  * cap03: DECIDE in the right order; work overload, not “qualitative”; loss of situational
    awareness “often appears” in accident chains; communicate is third, not last; 3P next to PAVE;
    sensory and short-term memory.
  * cap04: time of useful consciousness with the FAA values; if in doubt, oxygen first, including
    for hyperventilation; cannula only up to about 18,000 ft; Dalton and partial pressure; gradual
    hypoxia; euphoria as one of the first symptoms; “oxygen and descend”; cylinder pressure enough
    with a reserve; order of action for hypoxia or hyperventilation; pulse oximeter limits; Henry's
    law; histotoxic hypoxia; continuous-flow setting, EDS, batteries and wiring; aviation oxygen
    without the moisture argument; SAO.IDE.115 and CS 22.1441/1449.
  * Glossary (just culture, dysbarism, pulse oximeter, WADA, IMSAFE, SAO and SFCL), syllabus
    appendix (examination format, AMC1 SFCL.135), introduction (no 90 % figure) and epigraph (no
    year for the Borman quote).
  * Bibliography: a human performance and aviation medicine section of its own.

  Anki cards updated to match, with no `id` changed.
* **cap04, AMC1 SAO.OP.150** — the 10,000 ft threshold is an acceptable means of compliance
  (“should”), not binding like the regulation. Ported from the Spanish edition.
* **Bibliography and licence** — ported from the Spanish edition: SERA applies directly in Spain;
  new entries for Royal Decree 1180/2018 (which repealed Royal Decree 552/2014) and for the other
  regulations cited in the collection, with links to their consolidated versions; Annexes 17 and 18
  among the most relevant; and the syllabus is attributed to Part-SFCL, not “EASA-FCL”.
  The list of other regulations is no longer described as “consolidated versions”: the links go
  to the original act, from which EUR-Lex and the BOE give access to the consolidated one.


### Changed

* **Figures to be redrawn: “IN REVIEW” mark and note in the caption** — eight figures with errors
  found in the audit carry the diagonal “IN REVIEW” mark and a caption ending in *(FIX: …)*:
  IMSAFE, Maslow's pyramid, the Swiss cheese model, the error chain, the stress curve, DECIDE,
  tunnel vision and time of useful consciousness. The mark and the note are removed when each
  figure is replaced.
* **cap01, cap02, cap03** — a few sentences reworded to read more naturally. No figures,
  regulatory quotes or glossary terms change.
* **Introduction and cap01–cap04, including the chapter summaries** — prose revised throughout
  for natural English: shorter sentences, plainer wording, no calques from the Spanish. The
  content is unchanged: same facts, figures, rules and terminology, and the same structure as the
  Spanish chapters.

### Layout and production

* **Covers** — front and back covers in English.

## [0.8.0] — 25 September 2026

**What to reread:** **the whole book.** First complete translation, from Spanish version 1.0-rc.13.

### Added

* **Front matter, chapters 1–4, syllabus appendix, glossary and bibliography** — translated from
  the Spanish edition, in British English with EASA/ICAO terminology.
* **Chapter titles** — taken verbatim from the subject list of AMC1 SFCL.130 (ED Decision
  2020/004/R), items 2.1 to 2.4. The syllabus appendix quotes that list rather than translating
  the Spanish one back.
* **Epigraph** — Frank Borman's words are quoted in their original English, not translated back
  from the Spanish.
* **Regulatory quotes** — cap04 quotes SAO.OP.150 in the official English text of Regulation (EU)
  2018/1976, as published in the EASA Easy Access Rules for Sailplanes. The AMC1 SAO.OP.150 oxygen
  threshold (cap04) and the AMC1 SAO.GEN.130(f) & SAO.GEN.135(b) alcohol limits (cap02) were
  checked against the same source.
* **Spanish context** — the AESA alcohol-test form quoted in cap02 is marked as an unofficial
  translation; the travel-sickness brand Biodramina is kept, glossed as dimenhydrinate.
* **Mnemonics** — IMSAFE, PAVE, SHELL and the “3 P” model are English originals and are used
  as such. DECIDE follows the original English steps (Detect, Estimate, Choose, Identify, Do,
  Evaluate), as the Spanish glossary already did; the Spanish chapter used its own adaptation.
  The antidotes to the five hazardous attitudes use the standard English phrases.
* **EDS** — cap04 calls it *Electronic Delivery System*, as the glossary and
  `en/terminologia.yml` do; the Spanish chapter says *Electronic Demand System*.
* **Glossary** — 34 entries in English alphabetical order. These headings are still proposals
  pending review in `en/terminologia.yml`: AESA, carbon monoxide (CO), complacency, cyanosis,
  DECIDE, dysbarism (barotrauma), error chain, fatigue, hyperventilation, hypoxia, IMSAFE, motion
  sickness, Part-MED, PAVE, pulse oximeter, SHELL, situational awareness and spatial
  disorientation.
* **Anki decks** — the 53 cards of the four chapters, with the same ids as the Spanish decks.

### Pending

* **Figures** — all 15 figures still carry Spanish text.
* **Covers** — front and back covers are still the Spanish ones.
