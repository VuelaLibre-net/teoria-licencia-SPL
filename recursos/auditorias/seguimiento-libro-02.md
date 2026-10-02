# Seguimiento de la auditoría del libro 02

Estado de cada hallazgo de `informe-auditoria-libro-02-factores-humanos-2026-10-01.md`. El informe
no se toca: es el registro de lo que se encontró. Aquí se anota qué se ha hecho con cada hallazgo.

**Estados posibles:**

| Estado | Significado |
| --- | --- |
| `pendiente` | Sin empezar. |
| `aplicado` | Corregido; la columna «Commit» dice dónde. |
| `parcial` | Aplicada la parte verificada; el resto espera a un experto o a una figura. |
| `figura` | Sólo falta la figura, que rehace Ramón. |
| `experto` | No se toca hasta tener respuesta. |
| `descartado` | Revisado y no se aplica; la nota dice por qué. |

**Fases:**

| Fase | Contenido |
| --- | --- |
| 1 | Bloqueantes y normas derogadas. **Sin contenido:** el informe no tiene bloqueantes ni normas derogadas. |
| 2 | Altas; marca `.corregir` en las figuras graves |
| 3 | Medias, capítulo a capítulo, con el glosario y la bibliografía |
| 4 | Derivados en otros libros (01, 06 y 08) |
| 5 | Bajas |
| 6 | Edición inglesa (skill `traduccion-spl`) |
| 7 | Fichas de las figuras que hay que rehacer y preguntas a expertos |

**Reglas de todas las fases:**

- Cada cambio de contenido lleva su línea en `[En curso]` del CHANGELOG del libro, sin subir la
  versión.
- Los `id` de Anki nunca se renombran. Una tarjeta que enseña algo falso se reescribe, no se borra.
- El banco de examen (`examenes/`, repositorio aparte) sale sólo de los post-it. Si cambia un
  post-it, se revisan sus preguntas y se regenera con `make web-json`. Los guardianes son
  `make check` y `make lecciones-check`.
- Las figuras las rehace Ramón. Mientras, llevan la clase `.corregir`, la marca «EN REVISIÓN» y, al
  final del pie, *(CORREGIR: …)* (ver `GUIA_ILUSTRACIONES.md`).
- En lo que «requiere experto» se aplica sólo la parte verificada en el informe, y el resto queda
  abajo como pregunta abierta.
- Cada fase se verifica compilando los libros tocados, con `make anki` y con los guardianes
  `.github/comprobar-*.py`.

## Altas

| ID | Hallazgo | Fase | Estado | Commit | Nota |
| --- | --- | --- | --- | --- | --- |
| TEC-01 | Maslow: la seguridad no es la base | 2 | aplicado | | fase 2: cap01 y examen-50 P7; fase 3: figura marcada por el rótulo SMS; `en/`, en la fase 6 |
| COH-01 | Figura IMSAFE: «24 h» y polaridad del «NO» | 2 | figura | | fase 2: figura marcada con `.corregir`; el plazo del libro 06, en la fase 4 |
| NOR-01 | Alcohol: AMC presentado como límite legal | 2 | parcial | | fase 2: cap02 (IMSAFE, recuadro, texto y post-it), Anki, lección 02 P10, examen-50 P9 y P29; queda abierta la fuente del «formulario de AESA», retirado del texto |
| NOR-02 | Visión del color con certificado LAPL | 2 | aplicado | | fase 2: cap02 y Anki |
| TEC-02 | Vigilancia antes de virar | 2 | parcial | | fase 2: cap02 y Anki con la regla del GFH; la secuencia exacta, pregunta al FI(S); la figura de escaneo, con COH-05 |
| TEC-03 | DECIDE: pasos 4 y 5 cambiados | 2 | figura | | fase 2: cap03 con el orden del glosario; figura marcada con `.corregir` |
| COH-02 | Figura del TUC: «obligatorio» y cifras | 2 | figura | | fase 2: cuerpo con la tabla del PHAK, Anki `tuc`, lección 04 P7; figura marcada con `.corregir` |
| TEC-04 | Hiperventilación: no prohibir el oxígeno | 2 | parcial | | fase 2: recuadro, regla de oro, post-it, Anki y lección 02 P8 con la doctrina OACI/FAA; redacción clínica, pregunta al médico aeronáutico |
| TEC-05 | Límite de la cánula (18.000 ft) | 2 / 4 | parcial | | fase 2: cap04, post-it, Anki y lección 04 P9; el libro 08, en la fase 4; validación, pregunta al FI(S) de onda |

## Medias

| ID | Hallazgo | Fase | Estado | Commit | Nota |
| --- | --- | --- | --- | --- | --- |
| TEC-06 | Estadísticas de siniestralidad | 3 | aplicado | | fase 3: cap01, introducción y Anki |
| TEC-07 | Definición de factores humanos (HSE, no OACI) | 3 | aplicado | | fase 3: cap01 con la definición del Doc 9683 |
| COH-03 | Figura del queso suizo (HFACS) | 3 | figura | | fase 3: figura marcada con `.corregir` |
| COH-04 | Figura de la cadena del error | 3 | figura | | fase 3: figura marcada con `.corregir` |
| NOR-03 | Cultura justa: negligencia grave | 3 | aplicado | | fase 3: cap01, glosario, Anki y examen-50 P6 |
| NOR-04 | MED.A.020 completo | 3 | aplicado | | fase 3: cap02, Anki y examen-50 P11 |
| TEC-08 | Ver y evitar: 12,5 s y proporción del AIM | 3 | aplicado | | fase 3: cap02 y Anki |
| COH-05 | Figura de escaneo y «método horario» | 3 | aplicado | | fase 3: paso del escaneo y pie de figura; la figura no necesita marca |
| SYL-01 | Gas disuelto: buceo, donación, Henry | 3 | aplicado | | fase 3: cap02 (buceo y donación), cap04 (Henry) y glosario; sin tarjeta nueva |
| TEC-09 | Selye y Yerkes-Dodson en la figura | 3 | parcial | | fase 3: cap02, Anki y figura marcada con `.corregir`; la analogía, pregunta al especialista |
| COH-06 | Tratamiento de la hiperventilación | 3 | parcial | | fase 3: cap02, cap04, Anki, lección 02 P8 y examen-50 P23 y P24; se retira la apnea; pregunta al médico aeronáutico |
| TEC-10 | Fatiga aguda y crónica | 3 | aplicado | | fase 3: cap02, post-it, Anki, lección 02 P9 y examen-50 P27, P28 y P31 |
| TEC-11 | Deshidratación: 1–3 L/h y 20 min | 3 | parcial | | fase 3: cifras de reposición de la FAA y sin los 20 min; la tasa de pérdida, pregunta al médico aeronáutico |
| NOR-05 | Medicación y Part-MED | 3 | aplicado | | fase 3: cap02 y Anki |
| NOR-06 | Dopaje y AUT | 3 | parcial | | fase 3: cap02, glosario y Anki; «controles al aterrizar» retirado a falta de fuente |
| COH-07 | Disbarismos: el descenso | 3 / 4 | aplicado | | fase 3: cap02, cap04, Anki, lección 02 P3 y examen-50 P13 a P15; el libro 06, en la fase 4 |
| TEC-12 | Sobrecarga cuantitativa | 3 | parcial | | fase 3: «sobrecarga de trabajo» en cap03, Anki y lección 03 P6; la definición, pregunta al especialista |
| COH-08 | Conciencia situacional: «primer eslabón» | 3 | aplicado | | fase 3: cap03, Anki, lección 03 P2 y examen-50 P33 |
| TEC-13 | *Aviate, navigate, communicate* | 3 | aplicado | | fase 3: cap03 y Anki |
| TEC-14 | Dalton y «glóbulos vacíos» | 3 | aplicado | | fase 3: cap04, Anki, lección 04 P1 y P2 y examen-50 P40 y P41 |
| TEC-15 | Euforia como «primer» síntoma | 3 | aplicado | | fase 3: cap04, Anki, lección 04 P5 y examen-50 P43 |
| TEC-16 | «Oxígeno al 100 %» en equipos de planeador | 3 / 4 | parcial | | fase 3: cap04 y Anki con «oxígeno y desciende»; el libro 08 en la fase 4; los mandos, pregunta al FI(S) de onda |
| TEC-17 | 150–200 bar | 3 | aplicado | | fase 3: cap04, post-it, Anki y lección 04 P10 |
| TEC-18 | Diferencial hipoxia/hiperventilación | 3 | parcial | | fase 3: cap04 y Anki como orden de actuación; pregunta al médico aeronáutico |
| TEC-19 | Pulsioxímetro sin límites | 3 | parcial | | fase 3: cap04, post-it, glosario, Anki y lección 04 P6; el umbral, pregunta al médico aeronáutico |
| COH-09 | Restos del AMC de oxígeno | 3 / 4 | parcial | | fase 3: Anki `sao-op-150-oxigeno` y examen-50 P45; el libro 06, en la fase 4 |
| COH-10 | Doc 9683 en el banco | 3 | aplicado | | fase 3: fundamentos de las lecciones 01 a 04 y del examen-50 con la fuente real; el Doc 9683 se conserva donde trata el tema |
| NOR-07 | Bibliografía de factores humanos | 3 | aplicado | | fase 3: bloque propio en la bibliografía del 02 (no en las demás, por decisión del autor) |

## Bajas

| ID | Fase | Estado | Commit | Nota |
| --- | --- | --- | --- | --- |
| TEC-20 | 5 | pendiente | | Reason «planificada»; SHELL, pregunta al especialista |
| PED-01 | 5 | pendiente | | erratas y siglas duplicadas |
| PED-02 | 5 | pendiente | | PAVE, Anki y examen-50 P35 |
| PED-03 | 5 | pendiente | | 3P junto a PAVE |
| TEC-21 | 5 | pendiente | | memoria sensorial e hipocampo |
| PED-04 | 5 | pendiente | | figura de visión de túnel con `.corregir`; pregunta al especialista |
| COH-11 | 5 / 4 | pendiente | | IMSAFE «Emotion»; libro 06 en la fase 4 |
| COH-12 | 5 / 4 | pendiente | | umbral nocturno único; libro 01 en la fase 4, tras el médico aeronáutico (COH-09 del libro 01) |
| TEC-22 | 5 | pendiente | | agujero negro |
| PED-05 | 5 | pendiente | | figura de ilusiones: mover, citar y nuevo pie |
| TEC-23 | 5 | experto | | signos del CO; médico aeronáutico |
| TEC-24 | 5 | experto | | hipoxia histotóxica; médico aeronáutico |
| TEC-25 | 5 | pendiente | | caudal según la altitud |
| TEC-26 | 5 | pendiente | | EDS: nombre, pilas y cableado |
| TEC-27 | 5 | pendiente | | oxígeno medicinal; retirar «98,5 %» de Anki |
| NOR-08 | 5 | pendiente | | SAO.IDE.115 y CS 22.1441/1449 |
| NOR-09 | 5 | pendiente | | glosario: Reglamento de Ejecución; Part-SAO y Part-SFCL como en el 01 |
| NOR-10 | 5 | pendiente | | enlaces consolidados en las bibliografías |
| COH-13 | 7 | pendiente | | fichas `.prompt.md`, nombre de la figura de cianosis y marca del pulsioxímetro |
| PED-06 | 5 | pendiente | | promesa del apéndice; formato del examen |
| PED-07 | 5 | pendiente | | cita de Borman; pregunta al autor |

## Banco de examen

Las correcciones de `examenes/` van en su rama local `auditoria-02`, que sale de
`auditoria-01-fuentes-legales` y no tiene remoto.

| Fase | Commit en `examenes/` | Preguntas |
| --- | --- | --- |
| 2 | `bcd67d2` | lección 02 P8 y P10; lección 04 P7 y P9; examen-50 P7, P9 y P29 |
| 3 | `9ad0ab1` | lecciones 01 a 04 y examen-50: preguntas y citas de los post-it corregidos, y fundamentos con su fuente real (COH-10) |

## Edición inglesa

Fase 6 pendiente. `en/02-human-performance/` está al día con el español a 1 de octubre de 2026
(ningún `origen-commit` desfasado), así que la fase 6 porta exactamente lo que cambien las fases 2 a
5. Ya están bien en inglés: DECIDE, PAVE, «planned» de Reason, el hipocampo y «Electronic Delivery
System».

## Figuras marcadas para corregir

Cada figura con un error lleva la clase `.corregir`, la marca «EN REVISIÓN» encima y, al final del
pie, *(CORREGIR: …)*; en inglés, «IN REVIEW» y *(FIX: …)*. Al entregar la figura nueva se quitan la
clase y la nota, y se anota aquí.

| Capítulo | Figura | Hallazgo | Marcada en | Sustituida en |
| --- | --- | --- | --- | --- |
| cap01 | `02-cap01-piramide-maslow` | TEC-01 (rótulo SMS) | fase 3 | |
| cap01 | `02-cap01-queso-suizo` | COH-03 | fase 3 | |
| cap01 | `02-cap01-cadena-error` | COH-04 | fase 3 | |
| cap02 | `02-cap02-imsafe` | COH-01 | fase 2 | |
| cap02 | `02-cap02-curva-estres` | TEC-09 | fase 3 | |
| cap03 | `02-cap03-decide` | TEC-03 | fase 2 | |
| cap03 | `02-cap03-vision-tunel` | PED-04 | | |
| cap04 | `02-cap04-hipoxia-tiempo-conciencia` | COH-02 | fase 2 | |
| cap04 | `02-cap04-pulsioximetro` | COH-13 (marca comercial) | | |

## Preguntas abiertas

| Pregunta | A quién | Hallazgo | Respuesta |
| --- | --- | --- | --- |
| ¿Puede el oxígeno «agravar» una hiperventilación en algún caso? Redacción final del recuadro | médico aeronáutico | TEC-04, TEC-18 | |
| ¿Apnea breve o bolsa sobre nariz y boca en la hiperventilación? | médico aeronáutico | COH-06 | |
| Umbral de SpO₂ y redacción de los límites del pulsioxímetro | médico aeronáutico | TEC-19 | |
| Tasa realista de pérdida hídrica en cabina; los 20 minutos | médico aeronáutico | TEC-11 | |
| Signos del CO; ejemplos de hipoxia histotóxica | médico aeronáutico | TEC-23, TEC-24 | |
| Umbral nocturno único para la colección (5.000 o 6.000 ft) | médico aeronáutico | COH-12 (y COH-09 del libro 01) | |
| Mandos del EDS y del flujo continuo ante sospecha de hipoxia; altitud a partir de la que se exige mascarilla | FI(S) con experiencia de onda | TEC-05, TEC-16, TEC-25 | |
| Secuencia de vigilancia antes de virar que enseña la DTO | FI(S) | TEC-02 | |
| ¿Tiene sentido el agujero negro para una SPL? | FI(S) | TEC-22 | |
| Sobrecarga cuantitativa y cualitativa | especialista en factores humanos o manual EASA de HPL | TEC-12 | |
| ¿Hay datos de vuelo a vela sobre la conciencia situacional como primer eslabón? | especialista en factores humanos | COH-08 | |
| ¿Se acepta Selye a escala de minutos como analogía? | especialista en factores humanos | TEC-09 | |
| ¿El original de Edwards (1972) incluía la interfaz L-L? | especialista en factores humanos | TEC-20 | |
| Visión de túnel: ¿estrechamiento atencional o periférico? | especialista en factores humanos | PED-04 | |
| Fuente del «formulario de AESA» sobre alcoholemia en rampa | autor | NOR-01 | |
| Fuente de «hay controles al aterrizar» | autor | NOR-06 | |
| Fuente primaria de la cita de Borman | autor | PED-07 | |
| ¿El bloque de fuentes de factores humanos va en las nueve bibliografías o sólo en la del 02? | autor | NOR-07 | |
| Oxígeno medicinal frente al aeronáutico en España; especificación aplicable | proveedor de gases o AESA | TEC-27 | |
