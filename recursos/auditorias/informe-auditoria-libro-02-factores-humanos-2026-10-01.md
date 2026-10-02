# Auditoría del libro 02: *Factores Humanos*

**Libro:** 02. Factores Humanos
**Fuente:** `02-factores-humanos/`: `cap01…cap04-*.qmd`, `licencia.qmd`, `reconocimientos.qmd`, `introduccion.qmd`, `epigrafe.qmd`, `dedicatoria.qmd`, `colofon.qmd`, `apendice-syllabus-oficial-easa---factores-humanos.qmd`, `glosario.qmd`, `bibliografia.qmd`
**Versión:** 1.0-rc.13 (`02-factores-humanos/_quarto.yml:6`)
**Estado editorial:** En revisión (`make estados`)
**Fecha:** 2026-10-01
**Modalidad:** completa (libro entero, capítulo a capítulo)
**Base de comparación:** `main` en `40eeec2`. El `[En curso]` de `CHANGELOG-02.md` ya incluye cuatro correcciones que vienen de la auditoría del libro 01 (NOR-02, NOR-10, NOR-18 y NOR-19); se concilian, no se redescubren.
**Diff revisado:** no aplica; la modalidad es completa. Informe anterior conciliado: `aesa-spl-oficial/recursos/auditorias/informe-evaluacion-libro-02-factores-humanos-spl.md`, de julio de 2026, sobre el PDF v1.0.2.
**Verificación externa:** completa en lo normativo; en lo técnico, con las limitaciones de «Alcance y límites». Buena parte de la evidencia de este libro es médica y de factores humanos, no normativa: se apoya en OACI (Doc 8984 y 9683), en manuales y circulares de la FAA y en literatura revisada por pares. Varios puntos clínicos y de técnica de vuelo quedan como `requiere experto`.

**Derivados revisados:**
- mazos Anki `tools/anki/mazos/02-factores-humanos/cap01…cap04.yml` y su espejo `tools/anki/mazos/en/02-human-performance/`;
- las 15 figuras de `02-factores-humanos/imagenes/`, abiertas una a una;
- el banco de examen `examenes/json/factores-humanos.json` (40 preguntas), las lecciones `examenes/lecciones/02-factores-leccion-01…04.md` y el examen `examenes/oficial/02-factores-examen-50.md` con su distribución (repositorio git propio, excluido del principal);
- la edición inglesa `en/02-human-performance/`, rastreada como derivado y no auditada como traducción. Sus 14 `.qmd` están al día con el original: ningún fichero español tiene commits posteriores a su `origen-commit`;
- los capítulos de otros libros que tratan la misma materia: `01/cap06` y `cap13`, `03/cap01`, `06/cap01` y `cap03`, `07/cap05`, `08/cap14` y los glosarios 03, 06 y 08.

---

## Resumen ejecutivo

El libro conserva lo que el informe de julio valoró bien. Los cuatro capítulos siguen uno a uno los cuatro epígrafes del AMC1 SFCL.130. La adaptación al vuelo a vela es genuina: CO del remolcador y del motovelero, cinetosis programando el ordenador en térmica, frío en onda, presión del grupo en el club. El capítulo de oxígeno es un modelo de rigor normativo: cita SAO.OP.150 literalmente y presenta su AMC como regla por defecto. Desde julio se han resuelto H3, H4b (en parte), H4c, H4d, H6 y H8, y en el cuerpo del texto, H1.

Esta auditoría, más profunda que la de julio y apoyada en fuentes vigentes a 1 de octubre de 2026, **no encuentra bloqueantes**, pero sí nueve hallazgos altos de tres tipos.

**Modelos que se memorizan mal:**
- **DECIDE** (cap03) tiene los pasos 4 y 5 cambiados en el texto y en la figura; el glosario se corrigió en la rc.12 y el capítulo no.
- **Maslow** (cap01): el texto pone la seguridad en la base de la pirámide, contra Maslow y contra la propia figura.
- **Vigilancia antes de virar** (cap02): se manda mirar al lado contrario del viraje y no se despeja el sector hacia el que se vira.

**Mensajes de seguridad y normativos erróneos:**
- **Hiperventilación** (cap04): un recuadro prohíbe dar oxígeno, cuando la OACI y la FAA mandan lo contrario ante la duda.
- **Límite de la cánula:** el capítulo no dice que, según la doctrina FAA y el fabricante, la cánula no sirve por encima de unos 18.000 ft.
- **Alcohol** (cap02): el AMC («should») se presenta como «límite legal» y «regla sin excepciones», sin citar la norma vinculante, que castiga la merma de facultades y no una tasa.
- **Visión del color** (cap02): se presenta como obligatoria para la SPL, cuando con certificado LAPL sólo se evalúa si se pide habilitación nocturna.

**Figuras que contradicen el texto:**
- La de **IMSAFE** dice «24 h» de alcohol frente a las 8 h del texto, y su regla «si alguna respuesta es NO, no vuele» se invierte en dos preguntas.
- La del **tiempo útil de conciencia** rotula «el oxígeno es obligatorio por encima de 3.000 m» (H1 persistente) y da cifras que no coinciden con el resumen ni con la fuente.

Además hay un problema transversal de **trazabilidad**: la bibliografía no recoge ninguna fuente de factores humanos ni de medicina aeronáutica, y el banco de examen atribuye al Doc 9683 de la OACI, en 29 de sus 40 fundamentos, contenido que ese documento no tiene.

**Acción prioritaria:** corregir los tres mensajes de seguridad (hiperventilación, cánula y vigilancia antes de virar) y los dos modelos (DECIDE y Maslow), retirar o marcar las figuras de IMSAFE y TUC, y reformular la fuerza jurídica del alcohol y el requisito de visión del color. Casi todas tienen texto sustitutivo verificado.

| Dimensión | Veredicto | Motivo breve |
| --- | --- | --- |
| Calidad pedagógica | requiere correcciones | TEC-01, TEC-02, TEC-03 y TEC-04 consolidan modelos o hábitos falsos (Maslow, vigilancia, DECIDE, hiperventilación). Varios resúmenes introducen materia ausente del cuerpo o borran condiciones. |
| Fiabilidad técnica | requiere correcciones (además, incompleto) | Nueve hallazgos altos; TEC-05 tiene verificación parcial. Varios puntos clínicos esperan a un médico aeronáutico. |
| Cobertura del syllabus | correcto con mejoras | Los cuatro epígrafes están cubiertos. Falta el gas disuelto en toda la colección: ley de Henry, enfermedad descompresiva, buceo y donación de sangre (SYL-01). |
| Coherencia y derivados | requiere correcciones | Figuras contra texto (COH-01 a COH-05). Anki, banco, lecciones, examen-50 y `en/` repiten los errores. El banco cita el Doc 9683 sin base (COH-10). |

**Recomendación editorial:** **apto con correcciones.** No hay bloqueantes. Las altas deben resolverse antes de la versión 1.0, y TEC-05 necesita el visto bueno de un FI(S) con experiencia de onda.

### Veredicto por capítulo

| Cap. | Título | Peor hallazgo | Recomendación |
| --- | --- | --- | --- |
| 01 | Factores humanos: conceptos básicos | alta (TEC-01) | apto con correcciones |
| 02 | Fisiología aeronáutica básica y mantenimiento de salud | alta (COH-01, NOR-01, NOR-02, TEC-02) | apto con correcciones |
| 03 | Psicología aeronáutica básica | alta (TEC-03) | apto con correcciones |
| 04 | Uso de oxígeno | alta (COH-02, TEC-04, TEC-05, parcial) | apto con correcciones |
| — | Glosario | media (NOR-03, NOR-06, SYL-01, derivados) | apto con correcciones |
| — | Bibliografía | media (NOR-07) | apto con correcciones |
| — | Apéndice del syllabus | baja (PED-06) | apto |
| — | Preliminares (`introduccion.qmd`, `epigrafe.qmd`) | media (TEC-06, derivado) | apto con correcciones |

---

## Hallazgos

Los hallazgos van ordenados por severidad y, dentro de cada severidad, por orden de aparición en el libro. Cuando varios capítulos o bloques comparten una misma causa, se agrupan en un único hallazgo con todas sus ubicaciones. Los de severidad baja se recogen en una tabla compacta al final.

### Alta

#### [TEC-01] Maslow: la seguridad no es la base de la pirámide

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia, pedagogía
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `02-factores-humanos/cap01-factores-humanos-conceptos-basicos.qmd:113` (también `:109` y `:111`)

> La conclusión práctica es clara: la seguridad ocupa la base de la pirámide y no puede subordinarse a ningún objetivo de orden superior (@fig-02-cap01-piramide-maslow).

**Problema:**
- En la jerarquía de Maslow la base son las necesidades fisiológicas; la seguridad es el segundo nivel. La figura a la que remite el texto lo dibuja bien («Fisiológicas 1», «Seguridad 2»), así que texto y figura se contradicen.
- La línea 109 mezcla «salud, alimentación, seguridad física» en un único nivel básico y omite la pertenencia.
- La línea 111 («supera el nivel básico de seguridad») y la propia figura, que mete «Seguridad operacional (SMS)» en el segundo nivel, confunden la necesidad de sentirse a salvo de Maslow con la seguridad operacional del vuelo.

**Impacto:** si el examen pregunta qué ocupa la base de la pirámide, el alumno contestará mal. El mensaje práctico («la seguridad del vuelo no se subordina a la ambición») es válido, pero no es de Maslow.

**Evidencia:** FAA, *Aviation Instructor's Handbook*, FAA-H-8083-9B (2020), cap. 2, «Security»: «Once the physiological needs are met, the need for security becomes active». El mismo capítulo advierte de que el modelo apenas tiene apoyo empírico. https://www.faa.gov/sites/faa.gov/files/regulations_policies/handbooks_manuals/aviation/aviation_instructors_handbook/aviation_instructors_handbook.pdf (consultado el 2026-10-01; copia en `recursos/fuentes/faa/`).

**Propuesta:** línea 113: «La conclusión práctica: las necesidades de los niveles inferiores —fisiológicas (descanso, hidratación, alimentación) y de seguridad— deben estar cubiertas antes de perseguir objetivos de orden superior; ningún logro justifica sacrificarlas». En la línea 109, citar los cinco niveles en el orden de la figura. Al rehacer la figura, sustituir «Seguridad operacional (SMS)» por necesidades de seguridad personal.

**Derivados afectados:**
- figura `02-cap01-piramide-maslow.png`: orden correcto; sólo el rótulo SMS;
- examen-50, pregunta 7: el enunciado dice «supera el nivel básico de seguridad» y el fundamento llama a la seguridad «el que sostiene todo lo demás». La respuesta D no cambia;
- `factores-humanos-c01-q09`: comprobado sin cambio;
- edición inglesa: `en/02-human-performance/cap01-human-factors-basic-concepts.qmd:118` («So safety sits at the base of the pyramid»).

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-02.md`.

#### [COH-01] La figura IMSAFE dice «24 h» de alcohol y su regla final se invierte en dos preguntas

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, técnica, pedagogía
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** figura `02-factores-humanos/imagenes/02-cap02-imsafe.jpg`, citada en `cap02-fisiologia-aeronautica-basica-y-mantenimiento-de-salud.qmd:15`; texto que contradice en `:20`

> se requiere un margen mínimo de 8 horas desde la última copa.

**Problema:**
- La figura rotula «ALCOHOL ¿He consumido alcohol? (24 h mín. antes del vuelo)». El texto, el recuadro de normativa (`:219`), el resumen, Anki y el banco dicen 8 h.
- El cuadro «RECUERDE» dice «Si alguna respuesta es "NO", no vuele». Pero las preguntas S («¿Tengo preocupaciones o presiones…?») y A («¿He consumido alcohol?») están formuladas en positivo: con ellas, responder «NO» es justo lo que permite volar.

**Impacto:** el alumno ve dos plazos distintos para la misma regla en la misma página, y si aplica literalmente la regla de la figura entiende al revés dos de las seis comprobaciones.

**Evidencia:**
- AMC1 SAO.GEN.130(f) & SAO.GEN.135(b), ED Decision 2019/001/R: «no alcohol should be consumed less than 8 hours prior to a flight». Easy Access Rules for Sailplanes (PDF del 02-11-2022), copia local `recursos/fuentes/easa/easa-easy-access-rules-sailplanes-2022-11.pdf`.
- FAA, AIM 8-1-1 c) 3): «an excellent rule is to allow at least 12 to 24 hours between "bottle and throttle"». Es una recomendación prudente de otra jurisdicción, no la regla EASA. https://www.faa.gov/air_traffic/publications/atpubs/aim_html/chap8_section_1.html (consultado el 2026-10-01).

**Propuesta:** marcar la figura con `.corregir` y la nota «(CORREGIR: plazo del alcohol, 8 h según el AMC; polaridad de las preguntas S y A)» hasta rehacerla. Al rehacerla: «¿He bebido en las últimas 8 h?» y las seis preguntas con la misma polaridad, o la regla «si alguna respuesta es desfavorable, no vuele», como ya dice el texto (`:25`). Si se quiere mencionar el margen de 12–24 h, hacerlo en el texto como recomendación de la FAA.

**Derivados afectados:**
- la misma imagen en la edición inglesa (`en/02-human-performance/cap02-…qmd:20`);
- `06-procedimientos-operativos/cap01-requisitos-generales.qmd:59` («¿He consumido alcohol en las últimas 8-24 horas?»), una tercera versión del plazo;
- banco `factores-humanos-c02-q01` y examen-50 P9, de forma indirecta.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-02.md` (y de `CHANGELOG-06.md` si se toca el libro 06).

#### [NOR-01] El AMC del alcohol se presenta como límite legal y falta la norma vinculante (H5)

**Categoría:** normativa
**Dimensiones afectadas:** normativa, técnica, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado en la fuerza jurídica; no verificable la cita del formulario de AESA
**Ubicación:** `cap02-fisiologia-aeronautica-basica-y-mantenimiento-de-salud.qmd:20`, `:219`, `:222`, `:251`

> Dicho esto, ese 0,2 g/l es un límite legal, no un objetivo: la única práctica segura es subirte al planeador sin nada de alcohol en el cuerpo.

> La regla no tiene excepciones: **«de la botella al mando»**, 8 horas sin alcohol antes del vuelo, nada de alcohol durante el vuelo y alcoholemia inferior a 0,2 g/l

**Problema:**
1. La designación del AMC es correcta desde la rc.10, pero todo su texto está en condicional («should»). El capítulo lo convierte en «se requiere», «la norma EASA», «límite legal» y «no tiene excepciones». Es el mismo error que el libro corrigió para el oxígeno (NOR-10 del libro 01).
2. No se cita la norma vinculante, que no fija una tasa sino la merma de facultades:
   - SAO.GEN.130 f) 1): el piloto al mando no ejercerá funciones si está incapacitado, incluidos «the effects of any psychoactive substance», o si «feels otherwise unfit»;
   - SAO.GEN.135 b), con el mismo contenido para cualquier tripulante;
   - SERA.2020, de aplicación directa;
   - Ley 209/1964, art. 31: delito del comandante que emprenda el vuelo bajo la influencia de bebidas alcohólicas que puedan afectar a su capacidad. El libro 01 (`cap14:50`) ya lo enseña.

   Con una alcoholemia inferior a 0,2 g/l y las facultades disminuidas también se infringe la norma.
3. El «formulario» de AESA citado en `:222` no se ha podido localizar. Las inspecciones de rampa pertenecen al régimen de operaciones aéreas, no a Part-SAO, así que aunque exista no prueba la tasa aplicable a los planeadores.
4. Lo que sí se sostiene es que España no fija una tasa numérica más estricta: no aparece ninguna en la Ley 21/2003 (consolidada a 30-09-2025; sólo los arts. 25.2 d), que faculta para hacer pruebas, y 34.4.ª) ni en el RD 1180/2018.

**Impacto:** el alumno aprende que por debajo de 0,2 g/l está a salvo jurídicamente, y no distingue entre AMC y reglamento.

**Evidencia:**
- Easy Access Rules for Sailplanes (PDF del 02-11-2022), SAO.GEN.130 f), SAO.GEN.135 b) y AMC1 SAO.GEN.130(f) & SAO.GEN.135(b): «The pilot-in-command and any other crew member should observe the following restrictions: (a) no alcohol should be consumed less than 8 hours prior to a flight; (b) the blood alcohol level should not exceed the lower of the national requirements or 0.2 grams of alcohol in 1 litre of blood at the start of a flight; and (c) no alcohol should be consumed during the flight».
- SERA.2020, Easy Access Rules for SERA (agosto de 2025), copia local.
- Ley 209/1964, art. 31 (BOE-A-1964-21509), y Ley 21/2003, arts. 25.2 d) y 34 (BOE-A-2003-13616), copias locales en `recursos/fuentes/espana/`.
- Todo consultado el 2026-10-01.

**Propuesta:**
- Recuadro de normativa: «La norma (SAO.GEN.130 f) y SERA.2020) prohíbe volar bajo los efectos de cualquier sustancia psicoactiva que merme las facultades. El AMC1 SAO.GEN.130(f) y SAO.GEN.135(b), medio aceptable de cumplimiento, concreta cómo cumplirla: …».
- `:20`: «el AMC fija un margen mínimo de 8 horas».
- `:222`: suprimir la referencia al formulario (o aportar URL y fecha), sustituir «límite legal» por «cifra de referencia del AMC» y añadir que en España volar bajo la influencia del alcohol puede ser delito (Ley 209/1964, art. 31), con remisión al libro 01, cap. 14.
- `:251`: suprimir «La regla no tiene excepciones».

**Derivados afectados:**
- Anki `alcohol-botella-al-mando` (ES y EN);
- banco `factores-humanos-c02-q10` («¿Qué limitación impone la normativa europea…?»; su fundamento sitúa el AMC en el «Anexo II del Reglamento»), lección 02 P10, examen-50 P9 y P29;
- edición inglesa `en/…/cap02-…qmd:224-227`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-02.md`.

#### [NOR-02] La percepción del color no es obligatoria con certificado LAPL, y la restricción es de Part-MED, no de Part-SFCL

**Categoría:** normativa
**Dimensiones afectadas:** normativa, técnica
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap02-fisiologia-aeronautica-basica-y-mantenimiento-de-salud.qmd:44`

> Una percepción correcta de los colores es obligatoria. Durante el reconocimiento médico inicial deberá superar pruebas como el test de Ishihara. Si no demuestra discriminación de color segura, la licencia de piloto de planeador —regida por la normativa Part-SFCL— quedará restringida al vuelo diurno (**Day** VFR).

**Problema:**
- Para la SPL basta como mínimo el certificado médico LAPL (MED.A.030 c) 1)).
- El test de Ishihara en el reconocimiento inicial y la restricción a vuelo diurno son de MED.B.075, que está en la sección 2 de la subparte B: «Requisitos médicos para los certificados médicos de clase 1 y clase 2».
- El reconocimiento LAPL (MED.B.095, sección 3) sólo exige «capacidad visual». La percepción segura de los colores se exige si la licencia LAPL tiene habilitación nocturna (MED.A.030 d)), y el AMC14 MED.B.095 la evalúa sólo para quien la solicita.
- La limitación, cuando procede, afecta al certificado médico y viene de Part-MED, no de Part-SFCL.
- El recuadro lleva el rótulo «Normativa», así que transmite una obligación que no existe para la mayoría de los alumnos.

**Impacto:** error normativo en un recuadro de normativa, reforzado por una tarjeta Anki.

**Evidencia:**
- Reglamento (UE) 1178/2011, anexo IV (Part-MED), consolidado a 30-04-2026 (CELEX 02011R1178-20260430), copia local `recursos/fuentes/ue/reg-1178-2011-aircrew-part-med-consol-2026-04-30.xhtml`. MED.A.030 c) 1): para una SPL «el piloto deberá estar en posesión, como mínimo, de un certificado médico para licencias LAPL válido»; MED.A.030 d): «si la licencia PPL o LAPL tiene habilitación para vuelo nocturno, el titular de la licencia deberá gozar de una percepción de los colores segura»; MED.B.075 b) 3) ii): los solicitantes sin percepción segura «ejercerán las atribuciones de la licencia considerada únicamente en vuelo diurno» (clase 2).
- EASA, AMC & GM to Part-MED, Issue 2 (ED Decision 2019/002/R), AMC14 MED.B.095: «Applicants for a night rating should correctly identify 9 of the first 15 plates of the 24-plate edition of Ishihara pseudoisochromatic plates». La Amendment 1 (ED Decision 2025/002/R, 05-02-2025) no modifica ese AMC. Copias en `recursos/fuentes/easa/`.
- Consultado el 2026-10-01.

**Propuesta:** «Con certificado médico LAPL —el mínimo para la SPL— la visión del color sólo se evalúa si se solicita habilitación nocturna. Con certificado de clase 2, el reconocimiento inicial incluye el test de Ishihara y, si no se demuestra una percepción segura, el certificado limita las atribuciones al vuelo diurno (MED.B.075, Part-MED).»

**Derivados afectados:** Anki `vision-de-color-ishihara` («La licencia Part-SFCL queda restringida…»), en ES y EN; `en/…/cap02-…qmd:49`. Ninguna pregunta del banco.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-02.md`.

#### [TEC-02] Antes de virar se manda mirar al lado opuesto y no se despeja el sector hacia el que se vira

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad, pedagogía
**Severidad:** alta
**Confianza:** moderada
**Verificación:** confirmado en lo documental; la secuencia concreta que se enseña requiere un FI(S)
**Ubicación:** `cap02-fisiologia-aeronautica-basica-y-mantenimiento-de-salud.qmd:60`

> Antes de iniciar un viraje (por ejemplo, a la derecha), acostúmbrese a mirar brevemente hacia atrás por el lado exterior opuesto. Esto asegura que no haya tráfico acercándose por el ángulo muerto antes de inclinar las alas e iniciar el giro.

**Problema:** la doctrina de vuelo a vela manda despejar primero el espacio hacia el que se vira. El recuadro sólo menciona el lado contrario y lo presenta como garantía («asegura»). La tarjeta Anki deja esa mirada como única respuesta a «¿Qué se hace antes de iniciar un viraje?».

**Impacto:** se refuerza un hábito de vigilancia incompleto justo antes de la maniobra con más riesgo de colisión en térmica.

**Evidencia:** FAA, *Glider Flying Handbook*, FAA-H-8083-13B (diciembre de 2024), cap. 7, «Roll-In»: «Before starting any turn, the pilot should clear the airspace in the direction of the turn»; y en un escenario posterior: «VISUALLY CLEAR THE AIRSPACE BEFORE TURNING!». https://www.faa.gov/sites/faa.gov/files/Glider-Flying-Handbook.pdf (consultado el 2026-10-01; copia en `recursos/fuentes/faa/`). Los documentos *Lookout* y *Turning* de la BGA no se pudieron abrir (403).

**Propuesta:** «Antes de virar, despeje primero el sector hacia el que va a virar —por delante, por encima y por debajo, y hasta atrás—; compruebe también el lado opuesto y por detrás.» **Pregunta al FI(S):** ¿qué secuencia de vigilancia antes del viraje enseña la DTO? Debe coincidir con el libro 06 y con la figura de escaneo, que ya dice «durante un giro el punto de escaneo es a lo largo del horizonte».

**Derivados afectados:** Anki `angulo-muerto-antes-de-virar` (ES y EN); `en/…/cap02-…qmd:65`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-02.md`.

#### [TEC-03] DECIDE: los pasos 4 y 5 están cambiados en el capítulo y en la figura, y el glosario ya dice otra cosa

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia, pedagogía
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap03-psicologia-aeronautica-basica.qmd:47-52`; figura `02-factores-humanos/imagenes/02-cap03-decide.jpg`

> * **I**mplementar de manera metódica, rápida o pausada, la mejor opción.
> * **D**eterminar objetivamente cuáles serían los resultados del proceso o de la decisión tomada.

**Problema:**
- El modelo es *Detect, Estimate, Choose, Identify, Do, Evaluate*. El libro pone «Implementar» donde va *Identify* (identificar las acciones posibles) y «Determinar resultados» donde va *Do* (ejecutar). Además desvirtúa la E inicial (*Estimate*, estimar si hace falta reaccionar) como «Estudiar y recopilar».
- La rc.12 corrigió exactamente esto en el glosario (`glosario.qmd:39`), pero no tocó el capítulo ni la figura, que reproduce el orden erróneo en sus seis viñetas y lleva la palabra «TURBULENCE» en inglés.

**Impacto:** el alumno memoriza que se ejecuta antes de identificar soluciones y que los resultados se «determinan» después de actuar, y estudia dos versiones distintas del modelo en el mismo libro.

**Evidencia:** FAA, *Pilot's Handbook of Aeronautical Knowledge*, FAA-H-8083-25C (2023), cap. 2, «The DECIDE Model»: «DECIDE means to Detect, Estimate, Choose a course of action, Identify solutions, Do the necessary actions, and Evaluate the effects of the actions.» https://www.faa.gov/sites/faa.gov/files/FAA-H-8083-25C.pdf (consultado el 2026-10-01; copia en `recursos/fuentes/faa/`).

**Propuesta:** sustituir las seis viñetas por el orden del glosario. Sirve de modelo la edición inglesa (`en/02-human-performance/cap03-basic-aviation-psychology.qmd:52-57`), que ya está bien. Marcar la figura con `.corregir` y la nota «(CORREGIR: orden Detectar-Estimar-Elegir-Identificar-Hacer-Evaluar)» hasta rehacerla.

**Derivados afectados:**
- figura, también en `en/02-human-performance/imagenes/` (fichero idéntico);
- glosario: ya correcto;
- Anki `adm-decide`: no enumera los pasos, sin cambio;
- banco `c03-q03`, lección 03 P3 y examen-50 P34: la respuesta no depende del orden y la retroalimentación ya usa el de la FAA. Sin cambio.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-02.md`.

#### [COH-02] Figura del tiempo útil de conciencia: rotula «obligatorio» y sus cifras no cuadran con el resumen ni con la fuente (H1, H4a, H7)

**Categoría:** coherencia
**Dimensiones afectadas:** normativa, técnica, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** figura `02-factores-humanos/imagenes/02-cap04-hipoxia-tiempo-conciencia.png`, citada en `cap04-uso-de-oxigeno.qmd:52-54`; resumen `:176`

> La siguiente tabla muestra los valores de referencia (@fig-02-cap04-hipoxia-tiempo-conciencia):

**Problema:**
1. El rótulo rojo de la figura dice «POR ENCIMA DE 3.000 m (≈ 10.000 ft) EL OXÍGENO SUPLEMENTARIO ES OBLIGATORIO». Contradice SAO.OP.150 y su AMC1, y el propio texto: «El umbral de los 10.000 ft no es, por tanto, un límite legal incondicional» (`:130`). Es H1, corregido en el cuerpo y persistente en lo que más se ve.
2. La figura da ≈5 min a 22.000 ft y ≈3 min a 25.000 ft. El PHAK da 5 a 10 min y 3 a 5 min, y el resumen del capítulo (`:176`) dice 3 a 5 min (H4a).
3. «≤ 3.000 m … Sin síntomas de hipoxia» contradice el recuadro de vuelo nocturno (`:133`): la visión nocturna se degrada desde unos 5.000 ft.
4. El cuerpo llama «tabla» a una figura y no da ninguna cifra; el resumen introduce valores que el cuerpo no tiene.
5. Las tablas de las fuentes discrepan entre sí. La OACI (Doc 8984, parte II, cap. 1) da a 25.000 ft «2.5 minutes or less». Ninguna tabla es «la» oficial, y la AC 61-107B advierte de que son valores medios con gran variación individual.

**Impacto:** el alumno memoriza una obligación legal que no existe, y cifras distintas según mire la figura, el resumen o Anki.

**Evidencia:**
- Easy Access Rules for Sailplanes, SAO.OP.150 y AMC1 SAO.OP.150: «should ensure … when the pressure altitude is above 10 000 ft».
- FAA-H-8083-25C, cap. 17, tabla de tiempo útil de conciencia: 22.000 ft, 5 a 10 min; 25.000 ft, 3 a 5 min; 28.000 ft, 2½ a 3 min; 30.000 ft, 1 a 2 min; 35.000 ft, 30 a 60 s.
- FAA AC 61-107B CHG 1, fig. 2-3.
- OACI, Doc 8984, 3.ª ed. (2012), parte II, cap. 1.
- FAA, AIM 8-1-2 b): «a deterioration in night vision occurs at a cabin pressure altitude as low as 5,000 feet».
- Todo consultado el 2026-10-01; copias en `recursos/fuentes/faa/` y `oaci/`.

**Propuesta:**
- Marcar la figura con `.corregir` y la nota «(CORREGIR: el rótulo "obligatorio" y los valores a 22.000 y 25.000 ft)».
- Rehacerla con la tabla del PHAK citada en el pie, el rótulo «Por encima de 10.000 ft de altitud de presión: regla por defecto del AMC1 SAO.OP.150» y la nota de variabilidad individual.
- En el cuerpo, «figura» en vez de «tabla», con dos o tres valores y su fuente.

**Derivados afectados:**
- resumen (`:176`);
- Anki `tuc` (cifras compatibles con el PHAK; falta la fuente);
- banco `c04-q07` y examen-50 P44: la respuesta (3 a 5 min) es compatible con el PHAK, pero el fundamento atribuye la tabla al «OACI Doc. 9683», que no la contiene (COH-10);
- la misma figura en `en/`; `en/…/cap04-use-of-oxygen.qmd:181`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-02.md`.

#### [TEC-04] El recuadro prohíbe dar oxígeno ante una hiperventilación, en contra de la OACI y la FAA

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado como contradicción con la doctrina documental; la redacción clínica final requiere un médico aeronáutico
**Ubicación:** `cap04-uso-de-oxigeno.qmd:118-120`

> No aporte oxígeno suplementario si diagnostica hiperventilación y no está a gran altitud: añadir más oxígeno agravaría el desequilibrio de CO~2~ y empeoraría los síntomas. Si no puede confirmar que está por debajo de 10.000 ft, priorice el tratamiento de la hipoxia.

**Problema:**
- Respirar oxígeno no elimina CO₂: la hipocapnia la producen el ritmo y la profundidad de la ventilación, no la fracción de oxígeno inspirada. La afirmación causal no tiene base en las fuentes consultadas.
- La doctrina de la OACI y de la FAA es la contraria: ante la duda, oxígeno al 100 %, comprobar el equipo y después controlar la respiración.
- La hiperventilación es además una respuesta temprana a la hipoxia, así que las dos pueden darse a la vez.

**Impacto:** un piloto por debajo de 10.000 ft con hormigueo y ansiedad, pero quizá con hipoxia real (de noche, fumador, CO del motovelero), aprende a **no** usar el oxígeno que lleva. Es una decisión de seguridad aprendida al revés.

**Evidencia:**
- OACI, Doc 8984, *Manual of Civil Aviation Medicine*, 3.ª ed. (2012), parte V, cap. 2, § 30: «In an individual who is behaving in an unusual manner, and you suspect hyperventilation or hypoxia (the initial symptoms are similar), assume the condition is hypoxia and supply oxygen. Select 100 per cent oxygen, check the oxygen supply, oxygen equipment and flow mechanism.» https://www.icao.int/sites/default/files/publications/DocSeries/8984_cons_en.pdf.
- FAA, AIM 8-1-3 c): «hyperventilation and hypoxia can occur at the same time. Therefore, if a pilot is using an oxygen system when symptoms are experienced, the oxygen regulator should immediately be set to deliver 100 percent oxygen».
- FAA AC 61-107B CHG 1, 2-7 d) 1).
- Consultados el 2026-10-01; copias en `recursos/fuentes/oaci/` y `faa/`.

**Propuesta (sujeta a validación aeromédica):** sustituir el recuadro por «Ante la duda entre hipoxia e hiperventilación, trate primero la hipoxia: active o aumente el oxígeno y compruebe el equipo; después, controle el ritmo respiratorio. El oxígeno no empeora una hiperventilación.»

**Derivados afectados:**
- Anki `no-dar-oxigeno-en-hiperventilacion`: retirarla o invertirla, sin cambiar su `id`;
- banco `c02-q08`: el distractor C («Conectando el oxígeno suplementario a flujo máximo») queda en tensión con la doctrina; examen-50 P50;
- `en/…/cap04-use-of-oxygen.qmd:124`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-02.md`.

#### [TEC-05] Falta el límite de la cánula (unos 18.000 ft), y la «doctrina FAA» de FL250 mezcla sistemas

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad
**Severidad:** alta
**Confianza:** moderada
**Verificación:** parcial. Lo confirman la FAA y el fabricante, pero el límite es doctrina FAA y del fabricante, no una regla EASA; su traslado a la práctica en la UE requiere un FI(S) con experiencia de onda.
**Ubicación:** `cap04-uso-de-oxigeno.qmd:142`

> Según la doctrina FAA, no se recomienda por encima de **25.000 ft (FL250)**; más arriba se requieren sistemas de demanda con máscara.

**Problema:**
- La FAA da para el flujo continuo «typically used at 28,000 feet and lower», y para la mascarilla con bolsa de reinhalación «up to 25,000 feet».
- La **cánula**, que es la interfaz habitual en planeador y la que nombra el propio capítulo, está limitada en EE. UU. a 18.000 ft. El manual del EDS de Mountain High dice lo mismo: por encima de 18.000 ft, mascarilla.
- Los «sistemas de demanda con máscara» (*diluter-demand*) no son el EDS de pulsos con cánula de la viñeta siguiente, así que el alumno no sabe qué hacer en onda por encima de FL180.
- No se menciona un oxígeno de respaldo, que el fabricante recomienda a quien vuela habitualmente por encima de 18.000 ft.

**Impacto:** vuelo de onda a FL200–250 con cánula, con riesgo de hipoxia si se respira por la boca o se habla.

**Evidencia:**
- FAA/CAMI, *Oxygen Equipment: Use in General Aviation Operations*, apartados «Continuous flow» y «Nasal cannulas»: la cánula está «restricted by federal aviation regulations to 18,000 feet». https://www.faa.gov/pilots/safety/pilotsafetybrochures/media/oxygen_equipment.pdf.
- FAA-H-8083-25C, cap. 7: los aviones con oxígeno certificados por encima de 18.000 ft deben llevar mascarillas en vez de cánulas.
- Mountain High, *MH EDS 2G User Manual* (fuente de fabricante, secundaria).
- Consultados el 2026-10-01; copias en `recursos/fuentes/faa/` y `otras/`.

**Propuesta:** «La cánula sólo es adecuada hasta unos 18.000 ft (FL180); por encima, use mascarilla. El flujo continuo con mascarilla se emplea típicamente hasta 25.000–28.000 ft (FAA). Lleve un oxígeno de respaldo en vuelos de onda altos.» Validación de un FI(S) de onda.

**Derivados afectados:**
- `08-aeronave-sistemas/cap14-equipo-de-evacuacion-de-emergencia.qmd:43` («a través de una cánula o una máscara», sin límite);
- banco `c04-q09` (la opción C dice que ningún sistema tiene límite superior de empleo; aceptable para la pregunta, conviene revisarla);
- `en/…/cap04-use-of-oxygen.qmd:147`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-02.md` (y de `CHANGELOG-08.md`).

### Media

#### [TEC-06] Las estadísticas de siniestralidad: fuente de 2019 sin fecha, un blog generalizado a la aviación general y un 26 % mal leído

**Categoría:** técnica
**Dimensiones afectadas:** técnica, trazabilidad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `introduccion.qmd:5`; `cap01-factores-humanos-conceptos-basicos.qmd:24`, `:26-31`, `:34`, `:37`

> Las estadísticas actuales reflejan que **el factor humano es la causa principal o un elemento contribuyente en aproximadamente el 90 % de los accidentes en la aviación general y el vuelo a vela**.

> Los accidentes con consecuencias fatales (hasta un 26 % según datos de EASA (European Union Aviation Safety Agency)) tienen como causa principal la pérdida de control en vuelo

**Problema:**
- **El 90 % y el reparto 40/30/12/6** (que suma 88 %) son la taxonomía de un análisis personal: C. Ceipek, «Does Soaring Have To Be So Dangerous?» (19-11-2019), unos 247 informes de Alemania, EE. UU. y Austria, sólo de planeador. El libro los presenta como «estadísticas actuales» y «proporciones habituales» y los extiende a la aviación general, que el estudio no trata. Para el conjunto de la aviación, la FAA da «approximately 80 percent». La introducción (`:5`) repite el 90 % sin fuente.
- **El 26 %** es el porcentaje de accidentes *mortales* clasificados como pérdida y barrena en 2014-2018 (ASR 2019, fig. 67). Tal como está escrito se lee «hasta un 26 % de los accidentes son mortales»; la proporción real es del 11,6 % (187 de 1.609 en 2014-2023, ASR 2025). Además, EASA separa la pérdida y barrena de otras pérdidas de control, y el libro las funde.
- **Las fases** (50 % aterrizaje, 21 % despegue) son reproducibles con la ASR 2019 (promedio 2008-2017), pero falta decir el periodo y la edición. La ASR 2025 ya clasifica por áreas de riesgo.

**Impacto:** cifras sin trazabilidad que el alumno memoriza como hechos, y una idea falsa de cuántos accidentes son mortales.

**Evidencia:**
- EASA, *Annual Safety Review 2019*, cap. 5, figs. 65 y 67: «Percentage of sailplane fatal accidents by safety issue, 2014-2018», con Stall/Spin ≈26 %, Collision with Hill ≈17 %, Incomplete Winch Launch ≈10 %, sobre 105 accidentes mortales. Leído de la gráfica, con ±1 punto.
- EASA, *Annual Safety Review 2025*, cap. 5, tabla 5.1 (187 mortales y 1.422 no mortales en 2014-2023) y fig. 5.7.
- C. Ceipek, *Chess in the Air*, https://www.chessintheair.com/does-soaring-have-to-be-so-dangerous.
- FAA-H-8083-25C, cap. 2: «approximately 80 percent of all aviation accidents are related to human factors».
- Consultados el 2026-10-01; copias de las ASR en `recursos/fuentes/easa/`.

**Propuesta:** atribuir y acotar: «Un análisis de unos 250 informes de accidentes de planeador (Alemania, EE. UU. y Austria; Ceipek, 2019) atribuye cerca del 90 % a errores del piloto, con este reparto aproximado…»; para la aviación en general, el 80 % de la FAA. «Según la *Annual Safety Review 2019* de EASA, de los accidentes mortales de planeador entre 2014 y 2018, alrededor del 26 % se debieron a pérdida y barrena, el 17 % a colisión con la ladera y el 10 % a lanzamientos a torno incompletos.» En `:34`, «(promedio 2008-2017, accidentes con fase conocida)». En la introducción, citar la fuente o decir «la gran mayoría».

**Derivados afectados:** Anki `fases-criticas-accidentes` (sin fecha); `en/…/cap01-…qmd:29`, `:33`, `:39`, `:42`; `en/…/introduction.qmd`. Ninguna pregunta del banco.

#### [TEC-07] La definición de «factores humanos» que se atribuye a la OACI es de la HSE británica

**Categoría:** técnica
**Dimensiones afectadas:** técnica, trazabilidad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap01-factores-humanos-conceptos-basicos.qmd:18`

> La Organización de Aviación Civil Internacional (OACI (Organización de Aviación Civil Internacional)) define los factores humanos como los elementos medioambientales, organizativos, laborales y las características individuales que influyen en el comportamiento dentro del entorno aeronáutico, con efecto directo sobre la salud y la seguridad operacional.

**Problema:** es una traducción casi literal de la definición de la HSE británica (HSG48). La OACI, en el Doc 9683, define los factores humanos de otra forma. La línea tiene además la sigla desarrollada dos veces.

**Impacto:** atribución institucional falsa en la primera definición del libro.

**Evidencia:**
- UK HSE, HSG48, página de introducción: «Human factors refer to environmental, organisational and job factors, and human and individual characteristics, which influence behaviour at work in a way which can affect health and safety». https://www.hse.gov.uk/humanfactors/introduction.htm.
- OACI, Doc 9683-AN/950, *Human Factors Training Manual*, 1.ª ed. (1998), § 1.2.6: «Human Factors is about people in their living and working situations; about their relationship with machines, with procedures and with the environment about them; and also about their relationships with other people.» Copia publicada por la Oficina Federal de Aviación Civil suiza.
- Consultados el 2026-10-01; copias en `recursos/fuentes/otras/` y `oaci/`.

**Propuesta:** «Según el Manual de instrucción sobre factores humanos de la OACI (Doc 9683), los factores humanos tratan de las personas en su entorno de vida y de trabajo: su relación con las máquinas, con los procedimientos y con el entorno, y sus relaciones con otras personas». La definición enlaza además con SHELL. Quitar la sigla duplicada.

**Derivados afectados:** `en/…/cap01-…qmd:23`.

#### [COH-03] La figura del queso suizo usa los niveles de HFACS, se los atribuye a Reason y empareja mal los ejemplos

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, técnica
**Severidad:** media
**Confianza:** moderada
**Verificación:** parcial (el informe HFACS de la FAA no se pudo descargar; sólo su ficha)
**Ubicación:** figura `02-factores-humanos/imagenes/02-cap01-queso-suizo.png`, citada en `cap01-…qmd:61`; texto en `:59`

> James Reason ilustró este proceso con el **modelo del queso suizo**: cada capa del sistema de seguridad (instrucción, procedimientos, listas de verificación, supervisión) actúa como una barrera con agujeros.

**Problema:**
- Las capas de la figura («Influencias organizacionales / Supervisión insegura / Precondiciones para actos inseguros / Actos inseguros») son los cuatro niveles de HFACS (Shappell y Wiegmann, FAA, 2000), una taxonomía posterior basada en Reason. No coinciden con las capas que enumera el texto.
- Los ejemplos están mal emparejados: «Planificación de ruta deficiente» cuelga de las influencias organizacionales y «Falta de chequeo meteorológico» de la supervisión, y los dos son actos del piloto. «Aterrizaje fuera de aeródromo», una maniobra normal del vuelo a vela, aparece como acto inseguro.
- «Supervisión insegura» aparece dos veces.

**Evidencia:** FAA Office of Aerospace Medicine, DOT/FAA/AM-00/7 (febrero de 2000), *The Human Factors Analysis and Classification System—HFACS*, basado en «Reason's (1990) model of latent and active failures» (ficha consultada el 2026-10-01). OACI Doc 9683, § 2.4.

**Propuesta:** rehacer la figura con las capas del texto, o nombrar HFACS en el texto. En los dos casos, emparejar bien los ejemplos y quitar el rótulo duplicado. Mientras, `.corregir`.

**Derivados afectados:** la misma figura en `en/`.

#### [COH-04] La figura de la cadena del error contradice la definición de error latente

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, pedagogía
**Severidad:** media
**Confianza:** moderada
**Verificación:** confirmado
**Ubicación:** figura `02-factores-humanos/imagenes/02-cap01-cadena-error.jpg`, citada en `cap01-…qmd:83`; texto en `:70`

> * **Errores latentes:** Vulnerabilidades preexistentes en el sistema, como una instrucción inicial deficiente o un procedimiento inadecuado que favorece el fallo.

**Problema:**
- La figura rotula «ERROR LATENTE (Falta de atención en el montaje)». Según el texto y según la OACI, un despiste del propio piloto en el montaje es un fallo activo, no una condición latente del sistema.
- La lista de chequeo dibujada tiene texto sin sentido («Vortigenerizador», «Pernos de ale.» repetido, «Consígnas»).
- El texto no enseña a leer la figura.

**Evidencia:** OACI Doc 9683, § 2.4.3: las *latent failures* «are most likely bred by decision-makers, regulators and other people far removed in time and space from the event»; las *active failures* son «errors and violations having an immediate adverse effect, generally associated with the operational personnel».

**Propuesta:** `.corregir` con «(CORREGIR: el despiste en el montaje es un error activo; ejemplo latente: instrucción de montaje deficiente o lista de chequeo inadecuada)», y limpiar el texto de la lista al rehacerla.

**Derivados afectados:** la misma figura en `en/`.

#### [NOR-03] La cultura justa no excluye la «negligencia deliberada», sino la negligencia grave

**Categoría:** normativa
**Dimensiones afectadas:** normativa, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap01-factores-humanos-conceptos-basicos.qmd:101`; `glosario.qmd:35-36`

> sin represalias, siempre que no medie negligencia deliberada ni violación consciente de procedimientos.

**Problema:** la cultura justa está definida en el Derecho de la UE. Su límite es la negligencia grave, las infracciones intencionadas y los actos destructivos; «negligencia deliberada» es casi una contradicción. Falta además la condición de que las acciones sean «acordes con su experiencia y capacitación». El libro 01 lo dice bien (`01-derecho-aereo-atc/cap13-notificacion-de-accidentes.qmd:38`, «salvo negligencia grave o dolo»). La entrada del glosario no menciona ningún límite.

**Evidencia:** Reglamento (UE) 376/2014, art. 2.12, consolidado a 11-09-2018 (copia local en `recursos/fuentes/ue/`): «"cultura justa": aquella en la que no se castigue a los operadores y demás personal de primera línea por sus acciones, omisiones o decisiones cuando sean acordes con su experiencia y capacitación, pero en la cual no se toleren la negligencia grave, las infracciones intencionadas ni los actos destructivos».

**Propuesta:** «…sin represalias por acciones u omisiones acordes con su experiencia y formación; no ampara la negligencia grave, las infracciones intencionadas ni los actos destructivos (Reglamento (UE) 376/2014, art. 2.12)». Añadir el límite al glosario.

**Derivados afectados:** glosario `:36`; Anki `cultura-justa` (sin límites); `en/…/cap01-…qmd:106` («deliberate negligence»); banco `c01-q10` («negligencia manifiesta», matiz); examen-50 P6 tiene el fundamento correcto.

#### [NOR-04] MED.A.020 aparece incompleto y limitado a volar «al mando»

**Categoría:** normativa
**Dimensiones afectadas:** normativa
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap02-fisiologia-aeronautica-basica-y-mantenimiento-de-salud.qmd:10`

> Es obligatorio consultar con un Médico Examinador Aéreo (AME) o médico general si se ha sufrido una lesión importante, cirugía, inicio de medicación regular, embarazo, o uso por primera vez de lentes correctoras.

**Problema:**
- Faltan dos supuestos de la letra b): enfermedad importante que implique incapacidad e ingreso hospitalario o en clínica.
- «Lesión importante» omite «que implique una incapacidad para trabajar como miembro de una tripulación», y «cirugía» omite «o procedimiento médico invasivo».
- Para la LAPL, el «médico general» es el GMP que firmó el certificado (letra c) 2)).
- La norma impide ejercer cualquier atribución de la licencia, no sólo volar «al mando» (y a un alumno, volar solo). Tampoco se cita la letra a): medicamentos que puedan interferir, con o sin receta.

**Evidencia:** MED.A.020 a) a c), Part-MED consolidada a 30-04-2026 (copia local).

**Propuesta:** enumerar los supuestos de la letra b), sustituir «volar al mando» por «ejercer las atribuciones de la licencia (los alumnos, volar solos) hasta que el AME, el AeMC o el GMP le declare apto», y citar la letra a) 2).

**Derivados afectados:** Anki `cuando-consultar-ame`; examen-50 P11 (respuesta aceptable, pero su fundamento descarta al médico de cabecera, que para la LAPL puede ser el GMP); `en/`.

#### [TEC-08] Las cifras de «ver y evitar» no tienen fuente y el tiempo de reacción se subestima en un factor de cuatro

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap02-…qmd:49`, `:64`

> Un buen piloto dedica más del 95% de su tiempo a mirar fuera de la cabina, limitando la consulta de los instrumentos a vistazos rápidos de 2 a 4 segundos.

> Un piloto necesita al menos 3 segundos para reaccionar y ejecutar una maniobra evasiva, que deberá realizarse preferentemente **virando hacia la derecha**.

**Problema:**
- La FAA tabula 12,5 s desde ver el objeto hasta que la aeronave empieza a moverse. Con «al menos 3 segundos» el alumno deduce que le basta detectar el tráfico tres segundos antes.
- El 95 % no tiene fuente. El AIM recomienda 4 a 5 s de cabina por cada 16 s fuera, entre un 76 y un 80 % del tiempo fuera.
- «Preferentemente» suaviza una obligación: SERA.3210 c) 1) dice que cada aeronave «shall alter its heading to the right».

**Evidencia:** FAA AC 90-48E (20-10-2022), tabla 1: «TOTAL Time Before Aircraft Begins to Move 12.5». FAA, AIM 8-1-6 c): «no more than 4 to 5 seconds on the instrument panel for every 16 seconds outside». SERA.3210 c) 1). Consultados el 2026-10-01; copias en `recursos/fuentes/faa/` y `ue/`.

**Propuesta:** «Entre ver un punto y que el planeador empiece a apartarse pasan unos 12,5 s (FAA, AC 90-48E): hay que detectar pronto. En un encuentro frontal, SERA obliga a ambos a virar a la derecha.» Sustituir el 95 % por la proporción del AIM o retirarlo.

**Derivados afectados:** Anki `colision-frontal`; `en/…/cap02-…qmd:69`.

#### [COH-05] La figura de escaneo no ilustra el «método horario» que anuncian el texto y el pie

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, pedagogía
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado (contraste interno)
**Ubicación:** `cap02-…qmd:54`, `:57`

> 2. Realiza barridos visuales estructurados por sectores, desde las **9** hasta las **3**.

**Problema:** la figura se titula «El ciclo de escaneo: Mirar fuera – Actitud – Instrumentos», usa grados y no horas, e incluye mirar atrás y por encima, que el texto (de las 9 a las 3) no recoge. El texto no explica el ciclo ni su nota «el punto de escaneo es a lo largo del horizonte, NO debajo del ala». El pie promete un «método horario» que la figura no muestra. La lista mezcla tú y usted.

**Impacto:** el alumno memoriza un sector de 180° cuando la figura, que es mejor que el texto, pide mirar también atrás.

**Propuesta:** ampliar el paso 2 a «desde atrás por la izquierda hasta atrás por la derecha (más allá de las 9 y de las 3), y por encima»; cambiar el pie por «Ciclo de escaneo: mirar fuera, actitud, instrumentos». Coordinar con TEC-02.

**Derivados afectados:** `en/…/cap02-…qmd:56-62`.

#### [SYL-01] El gas disuelto no aparece en la colección: ley de Henry, enfermedad descompresiva, buceo y donación de sangre

**Categoría:** syllabus
**Dimensiones afectadas:** cobertura, seguridad
**Severidad:** media
**Confianza:** moderada
**Verificación:** confirmado en cuanto a la ausencia; su exigibilidad es interpretable, porque el syllabus sólo da títulos
**Ubicación:** `cap02-…qmd:219` (única mención, para descartarla); `cap04-uso-de-oxigeno.qmd:5-17`; `glosario.qmd:44-45`

> No lo confundas con el AMC1 SAO.GEN.130(f) a secas, que trata del buceo y la donación de sangre.

**Problema:**
- Ningún capítulo de la colección enseña lo que dicen el AMC1 y el GM1 SAO.GEN.130(f): dejar un tiempo razonable tras el buceo o la donación de sangre, con 24 h como mínimo adecuado. Un `grep` de «descompres», «buceo» y «Henry» en los nueve libros no da resultados de contenido.
- El cap04 explica Dalton y Boyle (gas atrapado), pero no el gas que sale de solución. En onda por encima de unos 25.000 ft aparece el riesgo de enfermedad descompresiva, y bucear antes de volar lo agrava.
- El glosario iguala «disbarismo» con «barotrauma» y deja fuera la enfermedad descompresiva.

**Evidencia:**
- Easy Access Rules for Sailplanes, GM1 SAO.GEN.130(f): «24 hours is a suitable minimum length of time to allow after normal recreational (sport) diving or normal blood donation before a flight».
- OACI Doc 8984, parte II, cap. 1: por encima de 25.000 ft, «the occurrence of bends … begins to be a threat».
- FAA-H-8083-25C, cap. 17, «Decompression Sickness After Scuba Diving».

**Propuesta:** un párrafo en el cap02 con la regla AMC/GM y su naturaleza no vinculante, y otro en el cap04 con la ley de Henry y la enfermedad descompresiva por encima de FL250. Glosario: «Disbarismos: trastornos por cambio de presión; incluyen los barotraumas (gas atrapado) y la enfermedad descompresiva (gas disuelto)».

**Derivados afectados:** glosario; posible tarjeta Anki nueva; `en/`.

#### [TEC-09] La mezcla de Selye con Yerkes-Dodson persiste en la figura y en la escala temporal (H2)

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía
**Severidad:** media
**Confianza:** moderada
**Verificación:** parcial; requiere un especialista en factores humanos para aceptar la analogía
**Ubicación:** `cap02-…qmd:160`, `:165`, `:183`; figura `02-factores-humanos/imagenes/02-cap02-curva-estres.png`

> Si el factor estresante no desaparece a los pocos minutos

> La mente sobrepasará la fase de alarma directamente al pánico.

**Problema:**
- La prosa ya separa los dos marcos (`:158`): lo corregido en julio se conserva.
- La figura rotula la rama descendente de Yerkes-Dodson como «Agotamiento y Pánico». El agotamiento es la tercera fase de Selye, un efecto de la duración del estrés, no de su intensidad. El eje se llama «Nivel de Estrés» mientras el pie y el texto hablan de nivel de activación.
- Selye sitúa la reacción de alarma entre 6 y 48 h y la resistencia a partir de las 48 h. «A los pocos minutos» traslada el síndrome a una escala que el modelo no describe.
- La línea 183 vuelve a enlazar una fase de Selye con el pánico, que es la sobreactivación de Yerkes-Dodson.

**Evidencia:** Rochette L. *et al.*, «Stress: Eight Decades after Its Definition by Hans Selye», *Brain Sci.* 2023;13(2):310 (PMC9954077): «alarm stage: 6–48 h, the second stage begins after 48 h» (consultado el 2026-10-01).

**Propuesta:** rótulo de la figura «Sobreactivación (ansiedad, pánico)», «Infraactivación (apatía)» a la izquierda y eje «Nivel de activación». Sustituir «a los pocos minutos» por «si se prolonga (horas o días)», o declarar la analogía. Línea 183: «pasará directamente a la sobreactivación (pánico)».

**Derivados afectados:** figura (también en `en/`); Anki `evitar-primeras-veces` («la mente salta de la alarma al pánico»).

#### [COH-06] Hiperventilación: el cuerpo, los resúmenes, el banco y el cap04 se contradicen en el tratamiento

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, técnica
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado en la contradicción; la técnica que se mantenga requiere un médico aeronáutico
**Ubicación:** `cap02-…qmd:176`, `:248`; `cap04-uso-de-oxigeno.qmd:113`, `:115`, `:180`

> también puede ser útil aguantar la respiración unos segundos para restaurar los niveles de CO₂ en sangre.

> provocando entumecimiento y ceguera. Para frenarlo, ralentice conscientemente la respiración prolongando la exhalación

**Problema:**
- El resumen del cap02 introduce «ceguera» y «prolongando la exhalación», que no están en el cuerpo. La FAA habla de alteraciones visuales, no de ceguera.
- El cuerpo del cap02 (`:176`) y el cap04 (`:113`, «reteniendo el aire unos segundos») recomiendan retener el aire, y el banco lo marca como incorrecto («La apnea forzada… no es la técnica indicada»).
- El cap04 da en el cuerpo «Cubra la nariz y la boca con una bolsa de mareo» (`:115`) y en el resumen «cubriendo parcialmente la boca» (`:180`).
- Los dos capítulos dan mecanismos distintos (vasoconstricción en el cap04, alcalosis en el cap02) sin decir que se complementan.

**Evidencia:** FAA-H-8083-25C, cap. 17, «Hyperventilation»: «slowing the breathing rate, breathing into a paper bag, or talking aloud»; síntomas: «Visual impairment». FAA, AIM 8-1-3 b): «paper bag held over the nose and mouth».

**Propuesta:** unificar cuerpo y resúmenes en «ritmo lento, hablar o cantar en voz alta y, si hace falta, bolsa sobre nariz y boca»; «alteraciones visuales» en vez de «ceguera». Decidir con un médico aeronáutico si se mantiene la apnea breve, y alinear el banco con lo que se decida.

**Derivados afectados:** Anki `hiperventilacion-tratamiento` («pérdida de visión»); banco `c02-q08` (opción D y su retroalimentación), examen-50 P24; `en/`.

#### [TEC-10] El epígrafe promete fatiga «aguda y crónica» y el texto afirma que sólo la cura el sueño

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap02-…qmd:186`, `:188`, `:195`

> **La fatiga solo se cura durmiendo.**

**Problema:** el capítulo no distingue nunca los dos tipos que anuncia el epígrafe, y llama a la fatiga «un factor crónico». Según la FAA, la aguda se cura con descanso y sueño, pero la crónica no, y requiere médico. La regla absoluta es falsa para la fatiga crónica.

**Evidencia:** FAA-H-8083-25C, cap. 17, «Fatigue»: «Rest after exertion and 8 hours of sound sleep ordinarily cures this condition» (aguda); «Chronic fatigue … is not relieved by proper diet and adequate rest and sleep and usually requires treatment by a physician».

**Propuesta:** dos frases que definan la fatiga aguda y la crónica; recuadro: «La fatiga aguda sólo se cura descansando y durmiendo; la crónica requiere consulta médica».

**Derivados afectados:** Anki `fatiga-solo-se-cura-durmiendo`; banco `c02-q09`, examen-50 P28 («único remedio efectivo»).

#### [TEC-11] La pérdida de 1 a 3 L/h y los 20 minutos de hidratación no tienen fuente

**Categoría:** técnica
**Dimensiones afectadas:** técnica
**Severidad:** media
**Confianza:** moderada
**Verificación:** requiere experto (médico aeronáutico)
**Ubicación:** `cap02-…qmd:202`, `:207`

> Es habitual perder entre 1 y 3 litros de agua por hora sin percibirse apenas.

**Problema:** 3 L/h es una tasa extrema para un piloto sentado. La FAA recomienda reponer 0,47 L/h con estrés térmico moderado y 0,95 L/h con estrés severo, y sitúa la absorción en unos 1,1 a 1,4 L/h. No menciona los 20 minutos de la línea 207.

**Evidencia:** FAA-H-8083-25C, cap. 17, «Dehydration and Heatstroke»: «The body normally absorbs water at a rate of 1.2 to 1.5 quarts per hour», «one quart per hour for severe heat stress … one pint per hour for moderate». La misma fuente confirma que la sed llega tarde.

**Propuesta:** pregunta al médico aeronáutico: ¿qué tasa de pérdida es realista en una cabina de plexiglás en verano? Mientras, usar las cifras de reposición de la FAA (0,5 a 1 L/h) y retirar los 20 minutos.

**Derivados afectados:** Anki `deshidratacion-retraso-sed`; examen-50 P25 (retroalimentación de la opción C).

#### [NOR-05] Medicación: reglas absolutas que no coinciden con Part-MED

**Categoría:** normativa
**Dimensiones afectadas:** normativa, técnica
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap02-…qmd:226`, `:228`, `:230`

> **La regla básica es sencilla: si el prospecto del medicamento desaconseja conducir vehículos o manejar maquinaria pesada, está totalmente prohibido volar bajo sus efectos**.

**Problema:**
- Part-MED no «invalida automáticamente» el certificado (`:226`): prohíbe ejercer las atribuciones (MED.A.020 a)) y califica como no apto el consumo problemático (MED.B.055); suspender o revocar lo decide el AME o la autoridad.
- No todos los antihistamínicos son incompatibles (`:228`): la GM1 MED.A.020 contempla los no sedantes, con consejo aeromédico.
- La «regla del prospecto» es una heurística útil, no una prohibición normativa, e invierte la lógica: un medicamento sin esa advertencia también puede ser incompatible.

**Evidencia:** MED.A.020 a) 2) y MED.B.055, Part-MED consolidada a 30-04-2026. AMC & GM to Part-MED, Issue 2, GM1 MED.A.020: las tres preguntas («Have I given this particular medication a personal trial on the ground…?») y «so-called non-sedative antihistamines, which do not degrade human performance, can be prescribed»; la Amendment 1 de 2025 no modifica esa GM.

**Propuesta:** sustituir la «regla básica» por la norma (no volar con un medicamento que pueda interferir: MED.A.020 a) 2)), las tres preguntas de la GM1 y el consejo del AME; presentar el prospecto como señal de alarma, no como criterio suficiente.

**Derivados afectados:** Anki `automedicacion` («¿Se puede volar automedicado? No.»); `en/…/cap02-…qmd:229-233`. Examen-50 P30, coherente.

#### [NOR-06] Dopaje y AUT: atribuciones y efectos exagerados

**Categoría:** normativa
**Dimensiones afectadas:** normativa, coherencia
**Severidad:** media
**Confianza:** moderada
**Verificación:** parcial (la página antidopaje de la FAI devolvió 403)
**Ubicación:** `cap02-…qmd:234`, `:237`; `glosario.qmd:104-105`

> Este documento oficial eximirá al competidor de sanciones en controles antidopaje deportivos.

**Problema:**
- La WADA no «rige» los controles: fija el Código, y los controles los realizan la FAI y las organizaciones nacionales antidopaje (en España, la CELAD).
- Una AUT sólo ampara el uso que coincide con lo autorizado (sustancia, dosis y vía); no exime de sanción en general. Existe además la AUT retroactiva.
- «Hay controles al aterrizar» no tiene fuente.
- La entrada «WADA» del glosario («regula y controla exhaustivamente») contradice la entrada «AUT / TUE», corregida en la rc.12.

**Evidencia:** Código Mundial Antidopaje 2021, arts. 4.4.1 («…shall not be considered an anti-doping rule violation if it is consistent with the provisions of a TUE»), 4.4.2, 4.4.3 y 4.4.5 (copia en `recursos/fuentes/otras/`; el Código revisado para 2027 aún no está en vigor).

**Propuesta:** «Las competiciones FAI aplican el Código Mundial Antidopaje; los controles los realizan la FAI o la organización nacional (en España, la CELAD). Quien compita bajo tratamiento con una sustancia prohibida necesita una AUT, que sólo ampara el uso autorizado.» Retirar la frase de los controles al aterrizar y corregir la entrada «WADA» del glosario.

**Derivados afectados:** Anki `aut-tue-competicion`; glosario `WADA`; `en/`.

#### [COH-07] Los resúmenes de disbarismos borran la condición crítica: el descenso

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, técnica
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap02-…qmd:244` (frente al cuerpo, `:84`); `cap04-uso-de-oxigeno.qmd:172`

> * **Disbarismos:** Los gases corporales se expanden al ascender. No vuele nunca con resfriados o congestión nasal; el dolor en los tímpanos y senos paranasales por el cambio de presión le incapacitará para pilotar.

**Problema:** el cuerpo del cap02 explica bien que el problema serio llega en el descenso, cuando el aire no puede volver a entrar en el oído medio. El resumen del cap02, el del cap04 y el banco atribuyen el riesgo a la expansión en el ascenso.

**Evidencia:** FAA-H-8083-25C, cap. 17, «Middle Ear and Sinus Problems»: el bloqueo de senos «occurs most frequently during descent».

**Propuesta:** «… No vuele con resfriado o congestión: en el descenso la presión no puede igualarse y el dolor de oídos y senos le incapacitará.»

**Derivados afectados:** Anki `disbarismos-congestion`; banco `c02-q03`, examen-50 P13; `06-procedimientos-operativos/cap01-requisitos-generales.qmd:56` («al ascender»); `en/`.

#### [TEC-12] Se llama «sobrecarga cualitativa» a lo que es sobrecarga cuantitativa

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** moderada
**Verificación:** parcial (fuente secundaria; requiere un manual de HPL o un especialista)
**Ubicación:** `cap03-psicologia-aeronautica-basica.qmd:19`, `:38`, `:121`, `:152`

> A esto se le conoce como **sobrecarga cualitativa**.

**Problema:** la distinción clásica es: cuantitativa, más tareas o información de las que caben en el tiempo disponible; cualitativa, una tarea demasiado difícil para la capacidad del sujeto. El ejemplo del vaso (remolque, sol, tráfico y radio a la vez) es cuantitativo, y la línea 121 mezcla después las dos.

**Evidencia:** Katz y Kahn (1978), *The Social Psychology of Organizations*, citado en Wikipedia, «Workload»: cuantitativa, «Having more work to do than can be accomplished comfortably»; cualitativa, «Having work that is too difficult» (fuente terciaria, consultada el 2026-10-01).

**Propuesta:** usar «sobrecarga» sin adjetivo, o definir los dos tipos una sola vez en la línea 121. **Criterio de aceptación:** que lo confirme un manual EASA de HPL o un especialista en factores humanos.

**Derivados afectados:** Anki `que-erosiona-la-conciencia-situacional` y `procesamiento-de-informacion`; banco `c03-q06` (sólo la retroalimentación); `en/…/cap03-…qmd:24`, `:126`, `:157`.

#### [COH-08] La conciencia situacional es el «6 %» en el cap01 y el «eslabón inicial de la mayoría» en el cap03

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, técnica
**Severidad:** media
**Confianza:** moderada
**Verificación:** no verificable (la afirmación del cap03 no tiene fuente)
**Ubicación:** `cap03-psicologia-aeronautica-basica.qmd:38`, frente a `cap01-…qmd:31`

> La pérdida de la conciencia situacional suele ser el eslabón inicial en la mayoría de las cadenas de accidentes en el vuelo a vela.

**Problema:** el alumno lee dos cifras incompatibles sobre el mismo concepto. El cap01 reduce la conciencia situacional a la vigilancia del tráfico (6 %); el cap03 la convierte en la causa inicial casi universal, sin fuente. Los estudios de Endsley sobre errores de conciencia situacional son de transporte comercial y militar, no de vuelo a vela.

**Propuesta:** «La pérdida de conciencia situacional aparece con frecuencia en las cadenas de accidentes…», y aclarar en el cap01 que el 6 % es una categoría propia del estudio citado. **Pregunta al especialista:** ¿hay datos de vuelo a vela que la sostengan como primer eslabón de la mayoría?

**Derivados afectados:** Anki `conciencia-situacional`; banco **`c03-q02`** y lección 03 P2 (la respuesta C depende directamente de esta frase); examen-50 P33 (fundamento); `en/…/cap03-…qmd:43`, `:153`.

#### [TEC-13] «Aviate, navigate, communicate»: comunicar no es «sólo si es estrictamente necesario»

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap03-psicologia-aeronautica-basica.qmd:124`

> (Primero vuela el avión con seguridad, luego preocúpate de hacia dónde, y, por último y de ser estrictamente necesario, coge la radio para contarlo).

**Problema:** la doctrina pone comunicar en tercer lugar, «as appropriate», no como algo excepcional. «Para contarlo» banaliza la llamada de socorro o urgencia y el aviso al torno o al remolcador. Dice además «avión».

**Evidencia:** FAA/GAJSC, *Safety Enhancement Topic* «Fly the Aircraft First» (enero de 2015): «figuring out where you are and where you're going (Navigate), and, as appropriate, talking to ATC or someone outside the airplane (Communicate)» (copia en `recursos/fuentes/faa/`).

**Propuesta:** «(primero vuela el planeador con seguridad, después decide hacia dónde y, en tercer lugar, comunica lo que sea necesario: pedir ayuda o avisar a quien deba saberlo)».

**Derivados afectados:** Anki `carga-de-trabajo-vaso`; `en/…/cap03-…qmd:129`. Banco `c03-q05` y examen-50 P39, sin cambio.

#### [TEC-14] «La ley de Dalton» se usa como causa de la caída de presión, y «los glóbulos rojos llegan vacíos»

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap04-uso-de-oxigeno.qmd:11`, `:23`, `:172`

> * **Leyes de los gases:** La presión atmosférica disminuye con la altitud (ley de Dalton), reduciendo la capacidad del oxígeno para transferirse a la sangre.

> Los glóbulos rojos llegan al cerebro prácticamente vacíos.

**Problema:**
- La presión baja con la altitud por el peso de la columna de aire. Dalton explica que la presión parcial de oxígeno es el 21 % de la total y baja con ella.
- `:11` dice que el oxígeno «no tiene fuerza suficiente para atravesar la membrana alveolar», una imagen de todo o nada; `:23` dice que no se «carga oxígeno en los alvéolos», cuando lo que no se carga es la sangre.
- «Prácticamente vacíos» es falso en el rango del planeador: la saturación ronda el 89 % a 10.000 ft y el 65 % a 20.000 ft.

**Impacto:** modelo de umbral («a partir de X no pasa oxígeno») en vez de una degradación progresiva, que es justo lo que hace insidiosa la hipoxia.

**Evidencia:** FAA-H-8083-25C, cap. 17, «Hypoxic Hypoxia»: la presión parcial del oxígeno «decreases proportionately as atmospheric pressure decreases». OACI Doc 8984, parte II, cap. 1 (saturaciones por altitud).

**Propuesta:** resumen: «La presión atmosférica disminuye con la altitud y, por la ley de Dalton, también la presión parcial de oxígeno (el 21 % de la total)…». `:23`: «…la menor presión parcial reduce la carga de oxígeno en la hemoglobina; la saturación cae de forma progresiva (≈89 % a 10.000 ft)».

**Derivados afectados:** Anki `ley-de-dalton` y `mecanismo-de-la-hipoxia`; banco `c04-q01` y `c04-q02` (retroalimentación); `en/`.

#### [TEC-15] «El primero en aparecer según el programa AESA es la euforia»: atribución sin rastro y orden que no es fijo

**Categoría:** técnica
**Dimensiones afectadas:** técnica, trazabilidad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap04-uso-de-oxigeno.qmd:40`, `:175`

> El síntoma más peligroso —y el primero en aparecer según el programa AESA— es la **euforia**

**Problema:** el syllabus (AMC1 SFCL.130) sólo enuncia «2.4 Use of oxygen», y no existe un «programa AESA» con ese contenido. Las fuentes dicen que la euforia es un síntoma temprano frecuente, no el primero, y que el orden varía de una persona a otra. El propio capítulo (`:38`) dice que los síntomas varían.

**Impacto:** el piloto espera sentirse eufórico, y si nota dolor de cabeza, hormigueo o somnolencia sin euforia puede descartar la hipoxia.

**Evidencia:** FAA/CAMI, *Hypoxia* (2020): «The order of symptoms varies among individuals». FAA-H-8083-25C, cap. 17: «The first symptoms of hypoxia can include euphoria». OACI Doc 8984, parte V, cap. 2, § 7: «A major early symptom».

**Propuesta:** «Uno de los primeros síntomas, y el más traicionero, suele ser la euforia… El orden varía de una persona a otra, pero en cada piloto tiende a repetirse: conocer los propios es la mejor alarma.»

**Derivados afectados:** Anki `primer-sintoma-hipoxia`; banco `c04-q05`, examen-50 P43; `en/`.

#### [TEC-16] «Oxígeno al 100 %» y «100 % de flujo» no son ajustes de los equipos de planeador

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía
**Severidad:** media
**Confianza:** moderada
**Verificación:** requiere experto (FI(S) con experiencia de onda)
**Ubicación:** `cap04-uso-de-oxigeno.qmd:43`, `:59`, `:74`, `:103`

> 1. Active el suministro de oxígeno al **100% de flujo** de forma inmediata.

**Problema:** «100 % oxygen» (AIM, OACI) es el ajuste de los reguladores *diluter-demand* de mascarilla, que dejan de mezclar aire de cabina. La cánula y el EDS siempre diluyen. El EDS tiene modos de pulsos y uno de flujo enriquecido, pero no «100 %», y el flujo continuo tiene un caudalímetro graduado en altitud. La regla de oro no dice qué mando tocar.

**Evidencia:** Mountain High, *MH EDS 2G User Manual*, «Modes of operation». FAA, AIM 8-1-3 c). FAA-H-8083-25C, cap. 7.

**Propuesta:** traducir la regla a los equipos reales: «aumente el aporte (modo de máximo flujo o mascarilla en el EDS; caudal de la altitud superior en flujo continuo), compruebe conexiones e indicador de flujo y descienda». Conservar el lema «oxígeno y desciende».

**Derivados afectados:** Anki del cap04 que repiten la regla; `08-aeronave-sistemas/cap14-equipo-de-evacuacion-de-emergencia.qmd:31` («oxígeno al 100 % y desciende»); `en/`.

#### [TEC-17] «Entre 150 y 200 bar» como comprobación prevuelo

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap04-uso-de-oxigeno.qmd:68`, `:179`

> * Verifique que el manómetro de la botella marca entre 150 y 200 bar.

**Problema:** la presión de llenado depende de la botella. Las de aviación de EE. UU. se llenan a 1.800–2.200 psi (124–152 bar), y una a 2.015 psi da 139 bar, que nunca entraría en la horquilla; algunas de carbono llegan a unos 207 bar. Con frío baja: 200 bar a 20 °C son unos 173 bar a −20 °C. El criterio correcto es tener presión suficiente para el vuelo previsto con reserva.

**Impacto:** o bien rechaza botellas válidas, o bien da por buena una botella a 150 bar que puede no bastar para un vuelo largo de onda con flujo continuo (unas 2 h con una botella de 2 L).

**Evidencia:** FAA-H-8083-25C, cap. 7: oxígeno almacenado «in high pressure system containers of 1,800–2,200 psi», y la presión baja con la temperatura. FAA/CAMI, *Oxygen Equipment*, «The PRICE check»: «ensure that there is enough oxygen pressure and quantity to complete the flight».

**Propuesta:** «Compruebe que la presión de la botella, según su capacidad y la temperatura, basta para el vuelo previsto con reserva (consulte la tabla de autonomía del fabricante).»

**Derivados afectados:** Anki `presion-de-la-botella`; banco `c04-q10` (su fundamento dice que la presión «debe encontrarse entre 150 y 200 bar»); `en/`.

#### [TEC-18] El diagnóstico diferencial asigna a la hiperventilación síntomas que también son de hipoxia

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad
**Severidad:** media
**Confianza:** moderada
**Verificación:** requiere experto (médico aeronáutico)
**Ubicación:** `cap04-uso-de-oxigeno.qmd:103-104`

> * Si está por debajo de 10.000 ft y experimenta hormigueo con sudoración y ansiedad: probable **hiperventilación**. Reduzca el ritmo respiratorio.

**Problema:** la FAA incluye el hormigueo, el entumecimiento y la sudoración entre los síntomas de hipoxia, y la hipoxia también se da por debajo de 10.000 ft (CO, de noche, fumadores). El propio capítulo (`:43`) lista el hormigueo como señal de hipoxia, así que se contradice. Es el mismo fondo que TEC-04, pero en la regla de diagnóstico.

**Evidencia:** FAA-H-8083-25C, cap. 17, «Symptoms of Hypoxia»: «Tingling in fingers and toes», «Numbness». FAA/CAMI, *Hypoxia*: «tingling or warm sensations, sweating». FAA AC 61-107B CHG 1, 2-7 d) 1).

**Propuesta:** reformular como orden de acción, no como diagnóstico: «1) oxígeno o descenso; 2) si no mejora, controle la respiración».

**Derivados afectados:** Anki del diferencial en el cap04; banco `c02-q08`; `en/…/cap04-…qmd:108`.

#### [TEC-19] El pulsioxímetro se presenta sin sus límites, y se sugiere medir a 5.000 m

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** parcial; los umbrales clínicos requieren un médico aeronáutico
**Ubicación:** `cap04-uso-de-oxigeno.qmd:157`, `:163`, `:166`, `:175`; `glosario.qmd:78`

> Es el instrumento más útil para detectar hipoxia antes de que los síntomas sean evidentes para el propio piloto.

> Registre sus valores de SpO~2~ a distintas altitudes durante los vuelos habituales (a 3.000 m, a 5.000 m)

**Problema:**
- La FAA advierte de que no debe usarse como único indicador.
- El CO da lecturas falsamente altas, porque la carboxihemoglobina se lee como saturada: es justo la hipoxia hipémica que el capítulo atribuye al remolcador y al motovelero.
- El frío (onda), el movimiento y la luz solar dan lecturas bajas o inestables.
- «A 5.000 m» (16.400 ft), sin precisar que es con el oxígeno conectado, invita a experimentar sin él.
- «Por debajo del 90 % … hipoxia franca» exagera: a 10.000 ft una persona sana marca en torno al 89 %.

**Evidencia:** FAA AC 61-107B CHG 1, 2-7 e): «The FAA cautions against relying on pulse oximeters as the sole indicator of hypoxia». OACI Doc 8984, parte II, cap. 1 (89 % a 10.000 ft). D. L. Johnson, «Does Your Pulse Oximeter Mean What It Says?», *Soaring*, junio de 2012 (secundaria).

**Propuesta:** «Es una ayuda, no un sustituto: con monóxido de carbono marca valores normales aunque haya hipoxia, y con frío o movimiento falla. Ante síntomas, actúe aunque la lectura sea buena.» En `:166`, «con su sistema de oxígeno funcionando».

**Derivados afectados:** glosario «Pulsioxímetro» («de forma objetiva»); Anki del pulsioxímetro en el cap04; banco `c04-q06`. El examen-50 P48 ya menciona límites que el libro no contiene.

#### [COH-09] Restos de H1 y de NOR-10 fuera del cuerpo: tarjeta Anki, examen y libro 06

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, normativa
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `tools/anki/mazos/02-factores-humanos/cap04.yml` (`sao-op-150-oxigeno`); `examenes/oficial/02-factores-examen-50.md` (pregunta 45); `06-procedimientos-operativos/cap03-tecnicas-de-planeo.qmd:91`

> El vuelo de onda a gran altitud requiere equipamiento específico: oxígeno a partir de los 3.000-4.000 metros según la autonomía y condición del piloto

**Problema:**
- La tarjeta pregunta «¿Cuándo es obligatorio el oxígeno suplementario?» y responde que, si no se puede determinar, «siempre por encima de 10.000 ft»: el AMC vuelve a presentarse como obligación.
- El examen-50 P45 pregunta por el «umbral diurno» del AMC1 SAO.OP.150, pero el AMC no distingue entre día y noche.
- El libro 06 da «3.000-4.000 metros»: 4.000 m son 13.123 ft, por encima de la regla por defecto (3.048 m), sin citarla.

**Propuesta:** tarjeta: «¿Qué exige SAO.OP.150 sobre el oxígeno, y qué regla por defecto da su AMC1?», con «debería» en el reverso (sin cambiar el `id`). P45: quitar «diurno». Libro 06: alinear con SAO.OP.150 y su AMC1.

**Derivados afectados:** los citados; mazo EN.

#### [COH-10] El banco de examen atribuye al Doc 9683 de la OACI contenido que ese documento no tiene

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, trazabilidad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado para la fisiología del cap04 (hipoxias, TUC, euforia, SpO₂); parcial para el resto
**Ubicación:** `examenes/json/factores-humanos.json`: 29 de las 40 preguntas citan «OACI Doc. 9683» en su fundamento; el examen-50 lo cita 30 veces

**Problema:** el Doc 9683 (*Human Factors Training Manual*, 1.ª ed. 1998) es un manual de formación que enumera temas: no tiene clasificación de hipoxias, tablas de tiempo útil de conciencia, «capítulo de hipoxia» ni umbrales de SpO₂. Eso está en el Doc 8984 o en los manuales de la FAA. Es plausible como fuente de los conceptos de factores humanos del cap01 y el cap03, pero no se ha comprobado pregunta a pregunta. En `c03-q02`, además, se cita junto al Anexo 19 para sostener una afirmación sin fuente (COH-08).

**Impacto:** el banco publicado da una trazabilidad aparente que no resiste la comprobación, y la presenta como fuente oficial.

**Evidencia:** OACI Doc 9683, índice y módulo 2 (copia en `recursos/fuentes/oaci/`); OACI Doc 8984, parte II, cap. 1, y parte V, cap. 2.

**Propuesta:** revisar los fundamentos del banco al regenerarlo, citando la fuente real (Doc 8984, PHAK, AIM o el apartado concreto del Doc 9683).

**Derivados afectados:** banco (`c01-q01` a `c04-q07`, 29 preguntas), lecciones 01 a 04 y examen-50.

#### [NOR-07] La bibliografía no tiene ninguna fuente de factores humanos ni de medicina aeronáutica

**Categoría:** normativa (trazabilidad)
**Dimensiones afectadas:** trazabilidad, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `02-factores-humanos/bibliografia.qmd` (todo el fichero; es común a los nueve libros, salvo 06, 07 y 08)

> Esta bibliografía es común a los nueve libros del manual de formación SPL.

**Problema:** no figuran el Doc 9683 ni el Doc 8984 de la OACI, el PHAK, el AIM, la AC 61-107B ni los folletos CAMI de la FAA, Reason (1990), Endsley (1995), la AC 60-22, las *Annual Safety Review* de EASA ni los AMC/GM de Part-MED. Ninguna cifra del libro (TUC, umbrales nocturnos, presiones, SpO₂, estadísticas) puede reconstruirse desde la bibliografía, y el banco suple la falta con una atribución errónea (COH-10).

**Propuesta:** añadir un bloque «Factores humanos y medicina aeronáutica» con las fuentes de la tabla final y su URL. Como la bibliografía es común, hay que decidir si el bloque va en las nueve o sólo en la del 02.

**Derivados afectados:** las bibliografías de la colección; `en/…/bibliography.qmd`.

### Baja

| ID | Ubicación | Problema | Propuesta | Confianza / verificación |
| --- | --- | --- | --- | --- |
| TEC-20 | `cap01:57`, `:43` | Reason: falta que la secuencia sea «planificada» y no atribuible al azar (EU-OSHA, OSHwiki, citando Reason 1990); `en/` ya dice «planned». SHELL: el Doc 9683 (§ 1.2.8) dice que Hawkins aportó un «modified diagram» (1975), no que «añadiera la segunda L». | «…desviación de una secuencia **planificada** de acciones…»; «desarrollado por Edwards (1972) como SHEL y representado por Hawkins (1975) con el diagrama que usa la OACI». | moderada / parcial (Edwards 1972 no accesible) |
| PED-01 | `cap01:18`, `:34`, `:37`; `cap03:109`, `:131`; `cap02:128`, `:165`, `:172`; `cap01:123` | Sigla desarrollada dos veces («OACI (Organización…)», «EASA (European…)»); «monomando» por «monoplaza»; «de abordo»; «abrevié»; «aterriceble»; «Paradojicamente»; resumen del cap01 confuso («represión ajena»); tú y usted mezclados en `cap02:51-55`. | Corregir. | alta / no aplicable |
| PED-02 | `cap03:65`, `:153` | PAVE: la «E» es *External pressures*; «u Operación» es un añadido sin fuente (FAA-H-8083-25C, cap. 2). | «E (*External pressures*, presiones externas)». Anki `pave`; examen-50 P35 (respuesta D). Glosario y `en/` ya correctos. | alta / confirmado |
| PED-03 | `cap03:119` | El modelo 3P es, en la FAA, un modelo de gestión de riesgos (percibir peligros con PAVE, procesar, actuar), no un «ciclo continuo» genérico; aparece aislado de PAVE. | Moverlo junto a PAVE y redactarlo como en el PHAK, cap. 2. | alta / confirmado |
| TEC-21 | `cap03:23`, `:25`; figura `02-cap03-memoria-tipos.jpg` | «200 ms» vale para la memoria icónica, no para toda la sensorial; «localizada en el hipocampo» simplifica en exceso; la figura da el 7±2 que el texto no explica (H7). | «menos de un segundo la visual, unos segundos la auditiva»; «en la que el hipocampo desempeña un papel clave», como `en/`; añadir «unos 7 elementos» (FAA-H-8083-9B, cap. 3). | moderada / parcial |
| PED-04 | figura `02-cap03-vision-tunel.jpg` (`cap03:117`) | La figura afirma que el estrés extremo reduce el campo visual periférico; el texto describe una fijación de la atención, y el examen-50 P37 da por incorrecto el distractor de la visión periférica. La escala del variómetro dibujado es incoherente. | Rótulo: «el estrés extremo estrecha la atención». Corregir la escala. | moderada / requiere experto |
| COH-11 | `cap02:13`, `:22`; `06/cap01:61`, `:172`; glosarios 02 y 06 | IMSAFE se presenta como estándar «de la aviación»; la FAA, origen del acrónimo, usa «E — Emotion», y el libro 06 usa «Emotion / Eating». | «la FAA difunde…»; «E — *Eating* (en la versión de la FAA, *Emotion*)». Banco `c02-q01`, examen-50 P9 y P12. | alta / confirmado |
| COH-12 | `cap02:69`; `cap04:133`; `01/cap06:79`; figura TUC | Degradación de la visión nocturna: 6.000 ft en el cap02, 5.000 ft en el cap04 (AIM 8-1-2 b)), 8.000–9.000 ft en el libro 01 y «sin síntomas» hasta 3.000 m en la figura. El recuadro del cap04 está bien rotulado como recomendación, pero sin fuente. | Unificar en unos 5.000 ft citando el AIM (COH-09 del libro 01). | alta / confirmado |
| TEC-22 | `cap02:73` | La corrección de la aproximación de agujero negro («mantener la velocidad indicada») no actúa sobre la ilusión, que afecta a la senda (FAA-H-8083-25C, cap. 17). | «Conocer la ilusión, contrastar la senda con referencias objetivas y no descender por debajo de la senda prevista». Valorar con un FI(S) su pertinencia para la SPL. | moderada / parcial |
| PED-05 | `cap02:76`; figura `02-cap02-ilusiones-opticas.png` | La figura muestra una ilusión vestibular (inclinado creyéndose nivelado), está bajo las ilusiones visuales y ningún `@fig` la cita. | Moverla tras `:98`, citarla y cambiar el pie. | alta / confirmado |
| TEC-23 | `cap02:139` | «Labios de color rojo intenso» como síntoma del CO para actuar: es un signo tardío y poco fiable; el PHAK cita dolor de cabeza, visión borrosa, mareo, somnolencia y pérdida de fuerza. | Sustituirlo por los síntomas del PHAK; preguntar al médico aeronáutico. Anki `monoxido-de-carbono`. | baja / requiere experto |
| TEC-24 | `cap04:34` | Hipoxia histotóxica por «relajantes musculares o antihistamínicos»: el PHAK la atribuye al alcohol, narcóticos y tóxicos; el AIM cita los antihistamínicos como factor que aumenta la susceptibilidad. | «alcohol, narcóticos o tóxicos; otros fármacos, como sedantes o antihistamínicos, aumentan la susceptibilidad». | moderada / requiere experto |
| TEC-25 | `cap04:142` | «Habitualmente 2 a 2,5 L/min»: en flujo continuo el caudal se ajusta a la altitud (caudalímetro graduado en altitud). | «…regulado por el piloto según la altitud». | moderada / parcial |
| TEC-26 | `cap04:143`; `glosario.qmd:50`; `08/cap14:44` | «*Electronic Demand System*»: el fabricante lo llama *Electronic Delivery System*, como ya dicen el glosario, el libro 08 y `en/`. Los equipos actuales usan pilas AA, no de 9 V, y conectarlo a la batería del planeador es una modificación de la aeronave (CS 22.1441: «Oxygen equipment must be approved»). El ahorro «por tres o cuatro» está dentro del 50–85 % del PHAK. | «Sistema de pulsos a demanda (EDS, denominación de un fabricante)…», «pilas», y retirar la recomendación de cableado o remitir al AFM y a Part-ML. | alta / confirmado |
| TEC-27 | `cap04:150` | «El oxígeno medicinal contiene mayor concentración de humedad»: la razón está discutida. CAMI dice que ni el medicinal ni el industrial sustituyen al de aviación porque no cumplen la misma norma. La regla práctica es correcta. | «Use oxígeno de aviación: el medicinal no está garantizado para uso aeronáutico». Retirar «98,5 %» de Anki o citar la norma. Banco `c04-q10` (D), examen-50 P49. | moderada / requiere experto |
| NOR-08 | `cap04:122-128` | No se cita SAO.IDE.115 (equipo de oxígeno cuando lo exige SAO.OP.150) ni CS 22.1441/1449 (equipo aprobado y medio para comprobar el flujo). | Una línea en el recuadro de normativa. | alta / confirmado |
| NOR-09 | `glosario.qmd:81`, `:84` | «Reglamento (UE) 2018/1976» es un Reglamento de Ejecución (NOR-24 del libro 01, no propagado). La entrada SFCL dice que regula «el programa de estudios», que está en el AMC1 SFCL.130. | Corregir; adoptar las entradas `Part-SAO` y `Part-SFCL` del libro 01. `en/…/glossary.qmd:77`. | alta / confirmado |
| NOR-10 | `bibliografia.qmd:20-30` | «Versiones consolidadas»: los enlaces apuntan a los actos base (CELEX 3…), no a los consolidados (CELEX 0…-AAAAMMDD). Los enlaces funcionan. NOR-18 del libro 01, aplicado en parte. | Enlazar el ELI o el CELEX consolidado, o quitar «versiones consolidadas». | alta / confirmado |
| COH-13 | figuras de `02-factores-humanos/imagenes/` | No existe `02-factores-humanos/prompts/`: ninguna de las 15 figuras tiene ficha `.prompt.md` de procedencia (`GUIA_ILUSTRACIONES.md`). `02-cap02-sintomas-hipoxia.jpg` sólo la usa el cap04. La foto del pulsioxímetro muestra una marca comercial. La de escaneo parece adaptada de material ajeno. | Crear las fichas al rehacer las figuras, renombrar la de cianosis y neutralizar la marca. | alta / confirmado |
| PED-06 | `apendice-…:10` | «para garantizar que cubres todos los puntos necesarios para el examen teórico»: promesa excesiva, porque el syllabus sólo da cuatro títulos. Se podría añadir el formato oficial (AMC1 SFCL.135: 10 preguntas en 20 minutos para *Human performance*). | «…sigue los epígrafes del syllabus oficial». | alta / no aplicable |
| PED-07 | `epigrafe.qmd:6` | «Frank Borman (1968)»: atribución muy difundida, pero no se localizó la fuente primaria ni la fecha. Es el mismo patrón que las citas de los libros 04 y 06 corregidas en septiembre. | Buscar la fuente primaria o quitar el año. | baja / no verificable |

---

## Comprobaciones cuantitativas

Modelo ISA troposférico: P = 1013,25 · (1 − 0,0065 · h / 288,15)^5,2559; fracción de oxígeno 0,2095.

| Ubicación | Datos y fórmula | Resultado recalculado | Valor publicado | Estado |
| --- | --- | --- | --- | --- |
| `cap01:24` | Proporción de accidentes con factor humano | Ceipek 2019 ≈90 % (sólo planeador, unos 247 informes); FAA ≈80 % (toda la aviación) | ≈90 % «aviación general y vuelo a vela» | alcance incorrecto (TEC-06) |
| `cap01:28-31` | 40 + 30 + 12 + 6 | 88 % (el resto, «no claro o inevitable» en la fuente) | 40/30/12/6 | coincide con una fuente que no se cita |
| `cap01:34` | ASR 2019, promedio 2008-2017: aterrizaje 99, despegue 42,9 de 199,8 | 49,5 % y 21,5 % | ≈50 % y 21 % | correcto, sin fecha |
| `cap01:37` | ASR 2019, fig. 67 (105 accidentes mortales, 2014-2018) | pérdida y barrena ≈26 %, ladera ≈17 %, torno ≈10 % | 26 / 17 / 10 | cifras correctas, mal leídas (TEC-06) |
| `cap01:37` | ASR 2025: 187 / (187 + 1.422) | 11,6 % de accidentes mortales | «hasta un 26 %» (lectura posible) | ambiguo (TEC-06) |
| `cap02:20`, `:219` | AMC: 8 h; 0,2 g/l | 0,2 g/l ≈ 0,02 % de alcohol en sangre | 8 h; 0,2 g/l | cifras correctas; fuerza jurídica mal (NOR-01) |
| figura IMSAFE | plazo del alcohol | 8 h (AMC); 12–24 h (recomendación del AIM) | «24 h mín.» | incorrecto (COH-01) |
| `cap02:49` | tiempo fuera de cabina: 16 / (16 + 4…5) | 76–80 % (AIM 8-1-6) | «más del 95%» | no reproducible (TEC-08) |
| `cap02:64` | 0,1 + 1,0 + 5,0 + 4,0 + 0,4 + 2,0 | 12,5 s (AC 90-48E) | «al menos 3 segundos» | engañoso (TEC-08) |
| `cap02:69` | degradación de la visión nocturna | 5.000 ft (AIM 8-1-2 b)) | 6.000 pies | discrepa (COH-12) |
| `cap02:134` | afinidad del CO por la hemoglobina | «about 200 times» (PHAK) | «unas 200 veces» | correcto |
| `cap02:134` | tabaco y altitud fisiológica | AIM 8-1-2: «several thousand feet»; PHAK: 5.000 a 8.000 ft | «varios miles de pies» | correcto (H4d) |
| `cap02:144` | 6,5 °C/km × 0,3048 km | 1,98 °C por 1.000 ft | «unos 2 °C» | correcto (H4c) |
| `cap02:144` | ISA a 4.000 m: 15 − 6,5 × 4 | −11 °C (−20 °C es ISA −9, posible en invierno) | «se pueden registrar –20 °C» | correcto |
| `cap02:165` | fases de Selye | alarma 6–48 h; resistencia desde 48 h | «a los pocos minutos» | discrepa (TEC-09) |
| `cap02:202` | reposición FAA: 1 pinta = 0,47 L/h; 1 cuarto = 0,95 L/h; absorción 1,14–1,42 L/h | — | 1–3 L/h | no reproducible (TEC-11) |
| `cap03:25` | memoria sensorial | icónica < 1 s; ecoica, segundos | 200 ms | parcial (TEC-21) |
| `cap03:26` | memoria a corto plazo | ≈30 s (FAA-H-8083-9B) | ≈30 s | correcto |
| `cap03:47-52` | pasos de DECIDE | D-E-C-I-D-E (FAA) | 4 y 5 cambiados | incorrecto (TEC-03) |
| `cap04:9` | composición del aire | N₂ 78,08 %, O₂ 20,95 % | 78 % y 21 % | correcto |
| `cap04:11` | presión parcial de O₂ = 0,2095 · P | 0 ft: 212 hPa; 10.000 ft: 146 hPa; 18.000 ft: 106 hPa; 25.000 ft: 79 hPa | — | coherente con «disminuye»; a 18.000 ft la presión es la mitad |
| `cap04:13` | Boyle: V/V₀ = P₀/P | 10.000 ft ×1,45; 18.000 ft ×2,00; 25.000 ft ×2,69 | sólo cualitativo | correcto |
| figura TUC | m → ft (÷ 0,3048) | 3.000 m = 9.843 ft; 5.500 m = 18.045 ft; 7.600 m = 24.934 ft; 9.100 m = 29.856 ft | ≈10.000, 18.000, 25.000, 30.000 ft | correcto como aproximación |
| figura TUC | PHAK: 22.000 ft 5–10 min; 25.000 ft 3–5 min; 30.000 ft 1–2 min; 35.000 ft 30–60 s | — | ≈5 min; ≈3 min; 1–2 min; 30–60 s | 22.000 y 25.000 ft no coinciden (COH-02) |
| `cap04:56` | (7.000 − 3.000) m / 5 m/s | 800 s = 13,3 min | «más de 13 minutos» | correcto |
| `cap04:142` (H4b) | 9.000 m → ft | 29.528 ft (cifra de julio) | ahora 25.000 ft | corregido; falta la cánula (TEC-05) |
| `cap04:143` | ahorro del EDS, PHAK 50–85 % | factor 2 a 6,7 | «tres o cuatro» | dentro del rango |
| `cap04:68` | psi → bar (× 0,06895); Gay-Lussac | 1.800–2.200 psi = 124–152 bar; 200 bar a 20 °C → 172,7 bar a −20 °C | «entre 150 y 200 bar» | incorrecto como criterio general (TEC-17) |
| `cap04:163` | SpO₂ frente a altitud (OACI Doc 8984) | 10.000 ft ≈89 %; 15.000 ft ≈80 %; 20.000 ft ≈65 % | «< 90 % hipoxia franca» | umbral razonable; «franca», exagerado (TEC-19) |

---

## Rastreo de derivados

La tabla recoge las proposiciones corregibles agrupadas por destino. Cada hallazgo ya indica sus derivados.

| Ruta | Proposición y ámbito | Origen canónico | Estado | Motivo |
| --- | --- | --- | --- | --- |
| `tools/anki/mazos/02-factores-humanos/cap01.yml` | `cultura-justa`, `fases-criticas-accidentes` | capítulo | afectado (menor) | NOR-03, TEC-06 |
| `tools/anki/mazos/02-factores-humanos/cap02.yml` | `vision-de-color-ishihara`, `alcohol-botella-al-mando`, `angulo-muerto-antes-de-virar`, `colision-frontal`, `disbarismos-congestion`, `hiperventilacion-tratamiento`, `fatiga-solo-se-cura-durmiendo`, `deshidratacion-retraso-sed`, `automedicacion`, `aut-tue-competicion`, `cuando-consultar-ame`, `monoxido-de-carbono`, `evitar-primeras-veces` | capítulo | afectado | NOR-01, NOR-02, NOR-04, NOR-05, NOR-06, TEC-02, TEC-08 a TEC-11, TEC-23, COH-06, COH-07 |
| `tools/anki/mazos/02-factores-humanos/cap03.yml` | `que-erosiona-la-conciencia-situacional`, `procesamiento-de-informacion`, `conciencia-situacional`, `carga-de-trabajo-vaso`, `pave` | capítulo | afectado | TEC-12, COH-08, TEC-13, PED-02 |
| `tools/anki/mazos/02-factores-humanos/cap04.yml` | `no-dar-oxigeno-en-hiperventilacion`, `tuc`, `ley-de-dalton`, `mecanismo-de-la-hipoxia`, `primer-sintoma-hipoxia`, `presion-de-la-botella`, `sao-op-150-oxigeno`, y las tarjetas del diferencial, del «100 %», del oxígeno medicinal y del pulsioxímetro | capítulo | afectado | TEC-04, COH-02, TEC-14 a TEC-19, COH-09, TEC-27 |
| `tools/anki/mazos/02-factores-humanos/*.yml`, resto (`imsafe`, `adm-decide`, `modelo-shell`, `srm`, `actitudes-peligrosas`, `mareo-y-biodramina`, `hipotermia-ropa`…) | — | Anki | comprobado sin cambio | correctas o independientes del error |
| `tools/anki/mazos/en/02-human-performance/` | mismos `id` | Anki ES | afectado | espejo del español |
| `examenes/json/factores-humanos.json` | `c02-q01`, `c02-q03`, `c02-q08`, `c02-q09`, `c02-q10`, `c03-q02`, `c03-q06`, `c04-q01`, `c04-q02`, `c04-q05`, `c04-q06`, `c04-q07`, `c04-q10` | banco (repositorio git propio, publicado en vuelalibre.net/examenes) | afectado | En `c03-q02` la respuesta correcta depende de una afirmación sin fuente (COH-08); en las demás, la retroalimentación, un distractor o el fundamento |
| `examenes/json/factores-humanos.json`, fundamentos | «OACI Doc. 9683» en 29 de 40 preguntas | banco | afectado | COH-10 |
| `examenes/lecciones/02-factores-leccion-01…04.md` | las mismas preguntas que el JSON | banco | afectado | idénticas a sus capítulos |
| `examenes/oficial/02-factores-examen-50.md` | P7, P9, P11, P12, P13, P24, P25, P28, P29, P33, P35, P43, P44, P45, P49, P50 | banco | afectado | TEC-01, NOR-01, NOR-04, COH-11, COH-07, COH-06, TEC-11, TEC-10, COH-08, PED-02, TEC-15, COH-02, COH-09, TEC-27, TEC-04 |
| `examenes/oficial/02-factores-examen-50.md` | P6, P30, P34, P37, P39, P48 | banco | comprobado sin cambio (P37 en tensión con la figura de visión de túnel) | P6 y P30 son el modelo correcto; P48 va por delante del libro |
| `en/02-human-performance/cap01…cap04-*.qmd`, `glossary.qmd`, `bibliography.qmd` | todos los hallazgos de sus capítulos | capítulo | afectado | traducción fiel y al día; arrastra los errores. Ya están bien en `en/`: DECIDE, PAVE, «planned» de Reason, «hipocampo» y «Electronic Delivery System» |
| `en/02-human-performance/imagenes/` | las 15 figuras | figura | afectado | ficheros idénticos a los españoles, con texto en español |
| `06-procedimientos-operativos/cap01-requisitos-generales.qmd:56`, `:59`, `:61`, `:172`; `06/glosario.qmd` | resfriado «al ascender»; alcohol «8-24 horas»; «Emotion / Eating» | capítulo | afectado | COH-07, COH-01, COH-11 |
| `06-procedimientos-operativos/cap03-tecnicas-de-planeo.qmd:91` | oxígeno «a partir de los 3.000-4.000 metros» | capítulo | afectado | COH-09 |
| `08-aeronave-sistemas/cap14-equipo-de-evacuacion-de-emergencia.qmd:31`, `:43` | regla «oxígeno al 100 % y desciende»; cánula sin límite | capítulo | afectado | TEC-16, TEC-05 |
| `08-aeronave-sistemas/cap14-…qmd:44`; `08/glosario.qmd` | EDS «Electronic Delivery System», ×3–4 | capítulo | comprobado sin cambio | es el modelo para TEC-26 |
| `01-derecho-aereo-atc/cap06-…qmd:79` | deterioro desde 8.000–9.000 ft | capítulo | afectado | COH-12 (COH-09 del libro 01) |
| `01-derecho-aereo-atc/cap13-notificacion-de-accidentes.qmd:38` | cultura justa «salvo negligencia grave o dolo» | capítulo | comprobado sin cambio | es el modelo para NOR-03 |
| `01-derecho-aereo-atc/cap14-derecho-nacional.qmd:50` | alcohol y Ley 209/1964, art. 31 | capítulo | comprobado sin cambio | el cap02 debería remitir aquí (NOR-01) |
| `03-meteorologia/cap01-la-atmosfera.qmd:49`, `:61`; glosarios 03 y 08 («Hipoxia») | 21 %; mitad de presión a 18.000 ft; definición de hipoxia | capítulo / glosario | comprobado sin cambio | coherentes con la ISA y con el glosario del 02 |
| `07-planificacion-rendimiento/cap05-…qmd` | hipoxia en onda; remisión al cap04 del libro 02 | capítulo | comprobado sin cambio | — |
| `06-procedimientos-operativos/cap07-procedimientos-de-emergencia.qmd` | *Aviate* primero | capítulo | comprobado sin cambio | — |
| Preliminares comunes (`licencia`, `dedicatoria`, `colofon`) | texto idéntico en los nueve libros | libro 01 | comprobado sin cambio | NOR-19 del libro 01, bien aplicado (md5 idéntico en los nueve) |
| Remisiones al libro 04 | — | — | no aplicable | el libro 02 no remite al libro 04 |

---

## Cobertura del syllabus

El syllabus aplicable es el AMC1 SFCL.130 (ED Decision 2020/004/R), recogido en las Easy Access Rules for Sailplanes. EASA mantiene como vigente la revisión de septiembre de 2020; el PDF publicado es del 02-11-2022 y coincide byte a byte con la copia local. No hay consolidaciones de Part-SAO ni de Part-SFCL posteriores al 15-11-2021. La asignatura (*2. Human performance*) tiene cuatro epígrafes **sin subepígrafes**, que el apéndice del libro (`apendice-…:5-8`) reproduce fielmente. La cobertura se juzga contra el epígrafe y contra la norma aplicable, no contra subapartados deducidos.

| Epígrafe oficial | Estado | Evidencia en el libro | Observación |
| --- | --- | --- | --- |
| 2.1 Factores humanos: conceptos básicos | cubierto | `cap01:14-124` | SHELL, error y violación, latente y activo, queso suizo, cadena del error, presión de grupo, cultura justa y Maslow. Las correcciones de TEC-01, TEC-06, TEC-07 y NOR-03 no afectan a la cobertura. |
| 2.2 Fisiología aeronáutica básica y mantenimiento de salud | cubierto, con un hueco | `cap02:5-252`; hipoxia y fuerzas G en `cap04:25-46` | Faltan el buceo y la donación de sangre, que trata la propia Part-SAO (SYL-01). La fatiga no distingue sus dos tipos (TEC-10). |
| 2.3 Psicología aeronáutica básica | cubierto | `cap03:15-157` | Procesamiento de la información, conciencia situacional, ADM (DECIDE), PAVE, actitudes peligrosas, estrés y carga de trabajo, 3P, SRM y complacencia. El estrés se repite con el cap02 sin remisión mutua. |
| 2.4 Uso de oxígeno | cubierto, con un hueco | `cap04:1-182` | Física, fisiología, cuatro hipoxias, TUC, hiperventilación, norma, equipo y pulsioxímetro. Falta el gas disuelto: ley de Henry y enfermedad descompresiva (SYL-01). Conecta con los ejercicios de vuelo 15a y 15c del mismo AMC. |
| AMC1 SFCL.130 a), *non-technical skills* integradas | cubierto | los cuatro capítulos | Buena adaptación a los riesgos del vuelo a vela. |

---

## Conciliación con el informe de julio (v1.0.2) y con el `[En curso]`

| ID | Hallazgo de julio | Estado | Comprobación en el texto actual |
| --- | --- | --- | --- |
| H1 | Umbral de 10.000 ft presentado como obligación general | corregido en el cuerpo; persistente en derivados | `cap04:124-130` y el resumen (`:177`) presentan bien el AMC. Persiste en el rótulo de la figura de TUC (COH-02), en la tarjeta `sao-op-150-oxigeno`, en el examen-50 P45 y en el libro 06 (COH-09). |
| H2 | Selye mezclado con Yerkes-Dodson | corregido en la prosa; persistente en la figura | La prosa separa los dos marcos (`cap02:158`). La figura rotula «Agotamiento y Pánico», la escala es de minutos y la línea 183 vuelve a mezclarlos (TEC-09). |
| H3 | Oxígeno nocturno desde 5.000 ft como norma | corregido y verificado | `cap04:133` («se recomienda —no lo exige la norma—») y `:177`. Falta citar el AIM y alinear las cifras de la colección (COH-12). |
| H4a | TUC del resumen frente a la figura | persistente | La figura da ≈3 min a 25.000 ft y el resumen 3 a 5; a 22.000 ft, ≈5 min frente a 5–10 del PHAK (COH-02). |
| H4b | Flujo continuo «no recomendado por encima de 9.000 m» | corregido en parte | Ahora dice 25.000 ft, compatible con la FAA para la mascarilla. Aparece un hallazgo nuevo: el límite de la cánula (TEC-05). |
| H4c | Gradiente de 2 °C por 1.000 ft | corregido y verificado (nunca fue erróneo) | `cap02:144`: 1,98 °C por 1.000 ft en la ISA. |
| H4d | «Tres cigarrillos ≈ 2.500 m» | corregido y verificado | Ahora «varios miles de pies», como el AIM 8-1-2. Mejora opcional: citar el AIM. |
| H5 | AMC1 SAO.GEN.130(f) y los 0,2 g/l | corregido en la designación (rc.10); persistente en la fuerza jurídica | El AMC se presenta como «límite legal» y «regla sin excepciones», sin la norma vinculante (NOR-01). |
| H6 | Enlazar los simuladores de examen | corregido y verificado | `apendice-…:16` enlaza a https://vuelalibre.net/examenes/02-factores-humanos/ (responde el 2026-10-01). El QR del PDF no se comprobó. |
| H7 | Cotejar con el texto las figuras con datos | persistente, y más amplio | Además de la de TUC (COH-02) y la curva de estrés (TEC-09), contradicen el texto las de IMSAFE (COH-01), DECIDE (TEC-03), cadena del error (COH-04), queso suizo (COH-03), escaneo (COH-05) e ilusiones (PED-05). La de Maslow es correcta y el texto la contradice (TEC-01). La de memoria coincide en las categorías (TEC-21). |
| H8 | Sin índice analítico, marca «BORRADOR», PDF pesado | corregido (maqueta) | La plantilla ya no imprime la marca. El PDF lleva índice alfabético (`02-factores-humanos/index.typ:3122`). El peso queda fuera de alcance. |
| — | Lo que julio dio por bueno | revisado de nuevo | Julio dio por buenos Maslow, DECIDE, la visión del color, el escaneo (95 %), la hiperventilación y las estadísticas, que no lo están (TEC-01, TEC-03, NOR-02, TEC-08, TEC-04, TEC-06). Siguen correctos SHELL en lo esencial, error y violación, latente y activo en el texto, las cinco actitudes, SRM, las cuatro hipoxias, Boyle, el CO, la hipotermia, la cinetosis y las grasas. |
| NOR-02 (libro 01) | SERA y el RD 1180/2018 en la bibliografía | corregido y verificado | `bibliografia.qmd:13-16`: SERA «se aplica directamente», con CELEX 02012R0923-20250501 (la última consolidación según el SPARQL de Cellar), y el RD 1180/2018. |
| NOR-10 (libro 01) | AMC1 SAO.OP.150 con «debería» en el cap04 | corregido y verificado en el cuerpo | `cap04:127` coincide con el «should» del AMC. La cita de SAO.OP.150 en `:125` es literal del texto español del Reglamento de Ejecución 2018/1976. Restos en la figura y en Anki (COH-02, COH-09). |
| NOR-18 (libro 01) | Lista de normas en la bibliografía | corregido en parte | La lista está y los enlaces funcionan, pero apuntan a los actos base (NOR-10 de este informe), y falta la bibliografía de factores humanos (NOR-07). |
| NOR-19 (libro 01) | «EASA-FCL» en la licencia | corregido y verificado | `licencia.qmd:10` dice «Part-SFCL», idéntico en los nueve libros. |

**Por qué el veredicto es más severo que en julio:**
- julio evaluó un PDF y verificó una muestra de afirmaciones;
- esta auditoría aplica la rúbrica de la skill `revision-capitulo-spl` capítulo a capítulo, abre las 15 figuras, contrasta cada cifra con fuente primaria vigente a octubre de 2026 y rastrea los derivados;
- julio dio por buenos modelos y reglas (Maslow, DECIDE, visión del color, hiperventilación) que no lo están.

---

## Lo que funciona

- **Rigor normativo del oxígeno.** La cita de SAO.OP.150 (`cap04:125`) es literal del texto español oficial, y la separación entre reglamento, AMC y lo no vinculante (`:127-130`) es un modelo para la colección: explica la obligación de fondo antes que la cifra. Conviene aplicar el mismo patrón al alcohol (NOR-01).
- **Adaptación genuina al vuelo a vela:** cinetosis programando el ordenador en térmica, CO en motoveleros y remolque, frío en onda, presión del grupo en el club (`cap01:95`) y el golpe en el estabilizador como ejemplo de cultura justa (`cap01:104`).
- **Mecanismos físicos bien explicados** donde suelen fallar: el oído medio, con el problema serio en el descenso (`cap02:84`); el CO, con unas 200 veces más afinidad por la hemoglobina; la Biodramina, incompatible con pilotar; el encuentro frontal sin movimiento lateral, que «sólo crece».
- **Mensajes de seguridad completos,** con condición, acción y razón: evitar la suma de «primeras veces» (`cap02:183`, `cap03:134`), el instinto de tirar de la palanca (`cap03:114`), el barotrauma (`cap04:15-17`), las grasas y el oxígeno (`cap04:152`) y la lista de hipoxia que anticipa el deterioro del juicio (`cap04:79`).
- **Cálculo operativo significativo:** el descenso de 7.000 a 3.000 m a 5 m/s frente al TUC disponible (`cap04:56`).
- **Definiciones fieles:** la conciencia situacional según Endsley (`cap03:33`), SRM y actitud según el PHAK, y las cinco actitudes peligrosas con sus antídotos.
- **Glosario** ya corregido en la rc.12 en DECIDE, SAO, hipoxia y AUT; coincide con los libros 03 y 08 en las entradas compartidas.
- **Las figuras de SHELL, Maslow, cinetosis y síntomas de hipoxia** son correctas y claras.

---

## Prioridades

1. **Altas, mensajes de seguridad:**
   - TEC-04: retirar la prohibición del oxígeno ante la hiperventilación, en el capítulo, Anki y `en/`, junto con TEC-18 (diferencial);
   - TEC-05: límite de la cánula y mascarilla por encima de FL180, con el libro 08;
   - TEC-02: vigilancia antes de virar, coordinada con COH-05.
2. **Altas, modelos y norma:**
   - TEC-03 (DECIDE) y TEC-01 (Maslow), con el examen-50 P7;
   - NOR-01 (alcohol), con `c02-q10`, P9 y P29;
   - NOR-02 (visión del color).
3. **Figuras altas:** COH-01 (IMSAFE) y COH-02 (TUC). Se pueden marcar con `.corregir` hasta que se rehagan.
4. **Medias de mayor retorno:**
   - COH-08, con `c03-q02`, porque una respuesta del banco depende de una afirmación sin fuente;
   - TEC-17 y TEC-19 (presión de la botella y pulsioxímetro);
   - TEC-14 y TEC-15 (Dalton y euforia);
   - NOR-03, NOR-04 y NOR-05 (cultura justa, MED.A.020, medicación);
   - COH-06 y COH-07 (hiperventilación y disbarismos en los resúmenes);
   - COH-09, COH-10 y NOR-07 (restos del AMC, Doc 9683 en el banco, bibliografía).
5. **Resto de medias:** estadísticas y definiciones del cap01 (TEC-06, TEC-07), figuras del cap01 (COH-03, COH-04), SYL-01, y TEC-08 a TEC-13.
6. **Bajas:** opcionales y agrupables por capítulo cuando se toque cada uno.

Cada corrección de contenido requiere su línea en `[En curso]` de `CHANGELOG-02.md` (y en los de los libros 06 y 08 cuando se toquen), la propagación a `en/` con su `origen-commit`, a Anki sin cambiar ningún `id` y a la sincronización del banco (repositorio aparte).

---

## Pendiente de verificar

- **Médico aeronáutico:**
  - TEC-04 y TEC-18: ¿puede afirmarse en algún caso que el oxígeno «agrava» una hiperventilación? Criterio: el recuadro coincide con el Doc 8984, parte V, § 30, o justifica la discrepancia con literatura revisada.
  - COH-06: ¿se recomienda la apnea breve o la bolsa? El banco debe quedar alineado con lo que se decida.
  - TEC-19: qué umbral de SpO₂ y qué redacción; criterio: umbral con fuente y advertencia sobre el CO y el frío.
  - TEC-11: tasa realista de pérdida hídrica en cabina y los 20 minutos.
  - TEC-23, TEC-24 y COH-12: signos del CO, ejemplos de hipoxia histotóxica y umbral nocturno único para la colección (5.000 o 6.000 ft).
- **FI(S) con experiencia de onda:**
  - TEC-05, TEC-16 y TEC-25: qué mandos se tocan en un EDS o en flujo continuo ante la sospecha de hipoxia, y a partir de qué altitud se exige mascarilla en el club o la DTO;
  - TEC-02: secuencia de vigilancia antes de virar que enseña la DTO;
  - TEC-22: pertinencia del agujero negro para una SPL.
- **Especialista en factores humanos o manual EASA de HPL:**
  - TEC-12: sobrecarga cuantitativa y cualitativa;
  - COH-08: datos de vuelo a vela sobre la conciencia situacional como primer eslabón;
  - TEC-09: si se acepta Selye a escala de minutos como analogía;
  - TEC-20: si el original de Edwards (1972) incluía la interfaz L-L;
  - PED-04: visión de túnel como estrechamiento atencional o periférico.
- **Autor:**
  - fuente del «formulario de AESA» sobre alcoholemia en rampa (NOR-01) y de «hay controles al aterrizar» (NOR-06);
  - fuente primaria de la cita de Borman (PED-07);
  - si el bloque de fuentes de factores humanos va en las nueve bibliografías o sólo en la del 02 (NOR-07).
- **Proveedor de gases o AESA:** situación en España del oxígeno medicinal frente al aeronáutico, y la especificación aplicable (TEC-27).
- **Fuentes no consultadas:** la FAA AC 60-22 (actitudes peligrosas), el informe HFACS completo y los documentos *Lookout* y *Turning* de la BGA.

---

## Fuentes consultadas

Todas se consultaron el 2026-10-01. Las copias están en `recursos/fuentes/` (véase su `README.md`).

| Fuente | Edición o vigencia | Apartados usados | Naturaleza | Fuerza |
| --- | --- | --- | --- | --- |
| EASA, Easy Access Rules for Sailplanes (https://www.easa.europa.eu/sites/default/files/dfu/Sailplane%20Rule%20Book.pdf) | revisión de septiembre de 2020; PDF del 02-11-2022; Reg. 2018/1976 consolidado a 15-11-2021 | AMC1 SFCL.130 y 135; SAO.GEN.130 f) y SAO.GEN.135 b) con su AMC1 y GM1; SAO.OP.150 y AMC1; SAO.IDE.115; CS 22.1441 y 1449 | primaria (compilación) | IR vinculante; AMC y GM no vinculantes |
| Reglamento de Ejecución (UE) 2018/1976, texto español consolidado | 15-11-2021 (el último, según SPARQL de Cellar) | SAO.OP.150, SAO.IDE.115 | primaria | vinculante |
| Reglamento (UE) 1178/2011, anexo IV (Part-MED), CELEX 02011R1178-20260430 | 30-04-2026 (el último) | MED.A.020, 030, MED.B.055, 075, 095 | primaria | vinculante |
| EASA, AMC & GM to Part-MED, Issue 2 (ED Decision 2019/002/R) y Amendment 1 (ED Decision 2025/002/R) | 28-01-2019; 05-02-2025 | GM1 MED.A.020; AMC14 MED.B.095 (la Amdt 1 no los modifica) | primaria | no vinculante |
| EASA, Easy Access Rules for SERA | agosto de 2025 | SERA.2020, SERA.3210 c) 1) | primaria (compilación) | vinculante |
| Reglamento (UE) 376/2014 | consolidado a 11-09-2018 | art. 2.12 | primaria | vinculante |
| Ley 21/2003 (BOE-A-2003-13616) | consolidada a 30-09-2025 | arts. 25.2 d), 34 | primaria | vinculante |
| Ley 209/1964 (BOE-A-1964-21509) | consolidada a 24-11-1995 | art. 31 | primaria | vinculante |
| RD 1180/2018 (BOE-A-2018-15406) | consolidado | búsqueda de «alcohol»: sin resultados | primaria | vinculante |
| EASA, *Annual Safety Review* 2019 y 2025 | 2019; 2025 | cap. 5: figs. 65 y 67; tabla 5.1, figs. 5.5 y 5.7 | primaria (estadística) | no aplicable |
| OACI, Doc 8984, *Manual of Civil Aviation Medicine* (https://www.icao.int/sites/default/files/publications/DocSeries/8984_cons_en.pdf) | 3.ª ed., 2012 | parte II, cap. 1; parte V, cap. 2, §§ 6-9 y 29-30 | primaria OACI | no vinculante |
| OACI, Doc 9683-AN/950, *Human Factors Training Manual* (copia de la Oficina Federal de Aviación Civil suiza) | 1.ª ed., 1998 | §§ 1.2.6-1.2.14, 2.4.3; módulo 2 | primaria OACI | no vinculante |
| FAA, *Pilot's Handbook of Aeronautical Knowledge*, FAA-H-8083-25C (https://www.faa.gov/sites/faa.gov/files/FAA-H-8083-25C.pdf) | 2023 | caps. 2, 7 y 17 | secundaria técnica (otra jurisdicción) | no vinculante en España |
| FAA, *Aviation Instructor's Handbook*, FAA-H-8083-9B | 2020 | caps. 2 (Maslow) y 3 (memoria) | secundaria | no vinculante |
| FAA, *Glider Flying Handbook*, FAA-H-8083-13B (https://www.faa.gov/sites/faa.gov/files/Glider-Flying-Handbook.pdf) | diciembre de 2024 | cap. 7, «Roll-In» | secundaria técnica | no vinculante |
| FAA, AIM, cap. 8, sección 1 | página en línea, fechada el 07-09-2026 | 8-1-1 a 8-1-3, 8-1-6, 8-1-8 | secundaria técnica | no vinculante |
| FAA, AC 61-107B CHG 1 | 29-03-2013, cambio 1 del 09-09-2015 | 2-7 (hiperventilación, TUC, pulsioxímetro, enfermedad descompresiva) | secundaria técnica | no vinculante |
| FAA, AC 90-48E | 20-10-2022 | tabla 1 | secundaria técnica | no vinculante |
| FAA/CAMI, *Hypoxia* y *Oxygen Equipment: Use in General Aviation Operations* | 2020; sin fecha visible | síntomas y su orden; cánula, mascarilla, flujo continuo, PRICE | secundaria técnica | no vinculante |
| FAA/GAJSC, *Fly the Aircraft First* | enero de 2015 | *aviate, navigate, communicate* | secundaria | no vinculante |
| UK HSE, HSG48 (página de introducción) | vigente | definición de factores humanos | primaria (HSE) | no aplicable |
| Código Mundial Antidopaje | 2021, vigente hasta la entrada en vigor del de 2027 | art. 4.4 | primaria deportiva | vinculante para los signatarios |
| Mountain High, *MH EDS 2G User Manual* | 2019 | modos, pilas, cánula, respaldo | fabricante (secundaria) | no vinculante |
| Rochette L. *et al.*, *Brain Sci.* 2023;13(2):310 | 2023 | cronología de Selye | literatura revisada por pares | no aplicable |
| EU-OSHA, OSHwiki «Human error» (cita de Reason, 1990) | vigente | definición de error | secundaria | no aplicable |
| C. Ceipek, *Chess in the Air* | 19-11-2019 | 90 % y reparto 40/30/12/6 | secundaria (blog) | no aplicable |
| FAA OAM, ficha DOT/FAA/AM-00/7 (HFACS) | febrero de 2000 | niveles de HFACS (sólo la ficha) | secundaria | no aplicable |
| Wikipedia, «Workload» (Katz y Kahn, 1978) | vigente | sobrecarga cualitativa y cuantitativa | terciaria | no aplicable |
| D. L. Johnson, «Does Your Pulse Oximeter Mean What It Says?», *Soaring* (reproducido por Mountain High) | junio de 2012 | límites del pulsioxímetro | secundaria | no aplicable |

---

## Alcance y límites

- **Revisado:**
  - los cuatro capítulos completos, incluidas aperturas, recuadros, tablas y resúmenes;
  - el apéndice del syllabus, el glosario, la bibliografía y los preliminares;
  - los cuatro mazos Anki (sólo `tarjetas`) y su espejo inglés;
  - las 15 figuras, abiertas una a una;
  - el banco de examen, las lecciones y el examen-50, como derivados.
- **Forma de trabajo:** la revisión se hizo en tres bloques en paralelo (cap01 y cap03; cap02; cap04 con glosario, bibliografía y preliminares) y después se consolidó. La consolidación incluyó una verificación propia en fuente primaria de todos los hallazgos altos: Doc 8984, § 30, y AIM 8-1-3 (TEC-04); folleto CAMI de equipos de oxígeno (TEC-05); tabla de TUC del PHAK y la figura (COH-02); figura IMSAFE y AMC1 SAO.GEN.130(f) (COH-01, NOR-01); MED.A.030, MED.B.075 y la estructura de secciones de Part-MED (NOR-02); *Glider Flying Handbook* 13B (TEC-02); PHAK, cap. 2 (TEC-03); *Aviation Instructor's Handbook* y la figura de Maslow (TEC-01). Las citas literales se cotejaron con el `.qmd` mediante `grep -n`.
- **Formato:** los hallazgos de severidad baja se presentan en una tabla compacta, sin el desarrollo completo de evidencia; sus fuentes están en la tabla general.
- **Fuera de alcance:**
  - la calidad de la traducción inglesa, que sólo se rastreó como derivado;
  - la maqueta y el PDF compilado (no se comprobó el QR del apéndice);
  - los capítulos de otros libros, salvo para comprobar coherencia y remisiones.
- **Fuentes inaccesibles:**
  - los originales de Edwards (1972), Hawkins (1975, 1987), Reason (1990), Maslow (1943), Benner (1975), Selye (1936) y Yerkes y Dodson (1908), que se suplieron con fuentes de la OACI, la FAA y literatura que los recoge;
  - la AC 60-22 de la FAA, el informe HFACS completo, los documentos de la BGA y la página antidopaje de la FAI (403);
  - la norma SAE AS8010 del oxígeno de aviación (de pago).
- **Jurisdicción:** buena parte de la evidencia técnica es de la FAA. No hay norma EASA sobre límites de la cánula, calidad del oxígeno o tiempo útil de conciencia, así que esos hallazgos se apoyan en doctrina de la OACI, la FAA y el fabricante, y su traslado a la práctica española requiere experto.
- **Límite de competencia:** esta revisión asistida no sustituye el visto bueno de un médico aeronáutico, de un FI(S) o FE(S) ni de un especialista en factores humanos en los puntos marcados como pendientes. La adecuación del temario al syllabus que declaran los preliminares no valida cada afirmación del desarrollo.
- **Sin cambios en las fuentes:** no se ha modificado ningún fichero del libro, glosario, Anki, figuras, banco ni CHANGELOG.
