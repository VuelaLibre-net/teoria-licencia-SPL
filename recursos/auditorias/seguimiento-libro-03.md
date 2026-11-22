# Seguimiento de la auditoría del libro 03

Estado de cada hallazgo de `informe-auditoria-libro-03-meteorologia-2026-11-21.md`. El informe no se
toca: es el registro de lo que se encontró. Aquí se anota qué se ha hecho con cada hallazgo.

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
| 4 | Derivados en otros libros (04, 05, 06 y 07) y texto común a los nueve |
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
| TEC-01 | Figura de la base de los cúmulos incoherente | 2 | figura | | fase 2: figura marcada con `.corregir` |
| TEC-02 | CAPE «sin el riesgo de tormenta severa» | 2 | parcial | | fase 2: cap03 (Airmanship y regla de oro), cap10 (regla de oro) y Anki `cape-en-contexto-volovelista` y `dia-termonuclear`; la banda de buen día, pregunta al meteorólogo (con COH-02) |
| TEC-03 | Lluvia engelante: hielo claro y salida | 2 | parcial | | fase 2: cap05, glosario y lección 05 (retroalimentación de la opción C); Anki y resumen ya eran correctos; redacción operativa, pregunta al FI(S); `en/`, en la fase 6 |
| TEC-04 | Figura del frente frío invertida | 2 | figura | | fase 2: figura marcada con `.corregir` |
| TEC-05 | Figura SIGWX: unidades, V5, nivel, frentes | 2 | figura | | fase 2: figura marcada con `.corregir`; el pie dice que es una recreación de un mapa SWL |

## Medias

| ID | Hallazgo | Fase | Estado | Commit | Nota |
| --- | --- | --- | --- | --- | --- |
| TEC-06 | Figura ISA mal trazada | 3 | figura | | fase 3: figura marcada con `.corregir` |
| SYL-01 | 3.1: estructura de la atmósfera y altitudes de presión y densidad | 3 | aplicado | | fase 3: cap01 (composición, capas, tropopausa, altitudes de presión y de densidad) y dos entradas del glosario; post-it sin cambios, sin tarjeta nueva |
| TEC-07 | Föhn: 10–15 °C no reproducible | 3 | parcial | | fase 3: cap02, post-it, glosario, Anki y lección 02 P9; Föhn mayor por otros mecanismos y el Tiétar, pregunta al meteorólogo |
| TEC-08 | Brisa marina sólo «suave y continua» | 3 | aplicado | | fase 3: cap02, post-it, Anki `convergencia-de-brisa`, lección 02 y examen-50 |
| COH-01 | Figuras del GFH del cap02 mal enlazadas | 3 | aplicado | | fase 3: remisiones corregidas y apartado nuevo de calles de nubes y convergencias del relieve |
| PED-01 | Figura de isobaras | 3 | figura | | fase 3: figura marcada con `.corregir` |
| TEC-09 | Fórmula de la base sin paréntesis | 3 | aplicado | | fase 3: fórmula con paréntesis en notación matemática |
| TEC-10 | «Altitud» de la base, es altura AGL | 3 | aplicado | | fase 3: cap03, glosario (Cúmulo) y Anki; la figura, con TEC-01 |
| TEC-11 | Estabilidad absoluta y condicional | 3 | aplicado | | fase 3: cap03 y Anki `estabilidad-atmosferica` |
| TEC-12 | Fórmulas del TT y del K perdidas | 3 | aplicado | | fase 3: fórmulas del TT y del K restituidas |
| TEC-13 | Escala del TT atribuida a Miller | 3 | parcial | | fase 3: escala atribuida al oeste de EE. UU. y fila 52 corregida; calibración regional, pregunta al meteorólogo |
| TEC-14 | «El K es más representativo en montaña» | 3 | parcial | | fase 3: retirada la regla llano/montaña en cap03 y Anki `tt-y-k`; pregunta al meteorólogo |
| COH-02 | Bandas de los índices contradictorias | 3 | parcial | | fase 3: bandas dentro de los umbrales de sus tablas, tramos, día termonuclear y Anki; la banda de buen día, pregunta al meteorólogo (con TEC-02) |
| TEC-15 | Signo del LI | 3 | aplicado | | fase 3 |
| TEC-16 | Clasificación de nubes y piso del Ns | 3 | figura | | fase 3: tabla de tres pisos (con PED-08); figuras de familias y del frente ocluido marcadas con `.corregir` |
| COH-03 | Neblina o bruma (BR): umbral y nombre | 3 | parcial | | fase 3: cap04, glosario (Niebla) y Anki; el tope de 5.000 m en el Anexo 3, pregunta al meteorólogo |
| TEC-17 | Niebla de advección: estación | 3 | parcial | | fase 3: «sobre todo en verano» (IGN); validación, pregunta al meteorólogo |
| TEC-18 | Downburst y microrráfaga | 3 | aplicado | | fase 3: cap05, cap09 y glosario (Downburst y Virga) |
| SYL-02 | 3.5: formación y tipos de precipitación | 3 | aplicado | | fase 3: apartado nuevo en cap05; post-it sin cambios |
| PED-02 | Cifras de seguridad sin fuente | 3 | parcial | | fase 3: cap04, cap05, cap06, cap07, cap08 y cap09 como orientación, con Anki; Cb alineado con la FAA en el post-it, lección 09 y examen-50 P32; validación, pregunta al FI(S) |
| TEC-19 | Frente cálido «estabiliza completamente» | 3 | figura | | fase 3: cap06, post-it, Anki `frente-calido`, lección 06 y examen-50; figura marcada con `.corregir` |
| TEC-20 | Frente estacionario | 3 | aplicado | | fase 3 |
| TEC-21 | Pm «primavera-verano» | 3 | parcial | | fase 3: «en primavera»; validación, pregunta al meteorólogo |
| TEC-22 | Baja Térmica «permanente» | 3 | parcial | | fase 3: cap08, post-it, Anki y lección 08; validación, pregunta al meteorólogo |
| COH-04 | Figura del ciclo de la tormenta | 3 | figura | | fase 3: figura marcada con `.corregir` |
| TEC-23 | Granizo bajo el yunque | 3 | aplicado | | fase 3: cap09 |
| COH-05 | Figura de la estela atribuida a la NASA | 3 | figura | | fase 3: figura marcada con `.corregir`; el pie ya no la atribuye a la NASA; sustituir por NASA L90-5919 con su crédito |
| TEC-24 | SPECI | 3 | aplicado | | fase 3: cap10, glosario y Anki `speci` |
| TEC-25 | SKC | 3 | aplicado | | fase 3: cap10 y glosario (NSC) |
| NOR-01 | AIRMET, GAMET y SWL hasta FL150 | 3 | aplicado | | fase 3: cap10, post-it, glosario (AIRMET, GAMET) y Anki `sigmet-airmet-nivel` |
| NOR-02 | «Obligatorio» y «vinculante» | 3 | aplicado | | fase 3: cap10 y Anki `aemet-ama-fuente-oficial`; lección 10 y examen-50 (P32 y dos fundamentos más) citan SAO.OP.120(b), SAO.OP.135 y SERA.2010(b) |
| SYL-03 | 3.10: radar, satélite y cartas | 3 | parcial | | fase 3: apartado nuevo en cap10; validación, pregunta al FI(S) |
| TEC-26 | CAPE desde el LFC (glosario) | 3 | aplicado | | fase 3: glosario (CAPE), con las bandas de TEC-02 |
| COH-06 | Dorsal (glosario) | 3 | aplicado | | fase 3: glosario (Dorsal) |
| TEC-27 | Fenómenos SIGMET (glosario) | 3 | aplicado | | fase 3: glosario (SIGMET) |
| TEC-28 | Estela: entrar alineado (glosario) | 3 / 4 | parcial | | fase 3: glosario del 03; el 06, en la fase 4 |
| COH-07 | Bibliografía sin fuentes meteorológicas | 3 | aplicado | | fase 3: bloque «Meteorología» sólo en la bibliografía del 03 |
| PED-03 | Reconocimientos: alcance de la validación | 4 | pendiente | | común a los nueve libros |

## Bajas

| ID | Fase | Estado | Commit | Nota |
| --- | --- | --- | --- | --- |
| PED-04 | 5 | pendiente | | |
| PED-05 | 5 | pendiente | | |
| PED-06 | 5 | parcial | | fase 3: el 0,5 °C/1.000 ft en el cuerpo; el post-it, en la fase 5 |
| PED-07 | 5 | pendiente | | |
| PED-08 | 3 | aplicado | | fase 3: con TEC-16 |
| TEC-29 | 5 | pendiente | | requiere experto |
| TEC-30 | 5 | pendiente | | |
| TEC-31 | 5 | pendiente | | |
| TEC-32 | 5 | pendiente | | |
| COH-08 | 5 | pendiente | | |
| TEC-33 | 5 | pendiente | | |
| COH-09 | 5 | pendiente | | |
| COH-10 | 5 | pendiente | | |
| TEC-34 | 5 | pendiente | | |
| TEC-35 | 5 | pendiente | | |
| TEC-36 | 5 | pendiente | | |
| TEC-37 | 5 | pendiente | | |
| PED-09 | 5 | pendiente | | |
| TEC-38 | 5 | pendiente | | requiere experto |
| TEC-39 | 5 | pendiente | | |
| COH-11 | 5 | pendiente | | no verificable |
| PED-10 | 5 | pendiente | | |
| PED-11 | 4 | pendiente | | también el 05 |
| TEC-40 | 5 | pendiente | | |
| TEC-41 | 5 | pendiente | | requiere experto |
| TEC-42 | 3 | aplicado | | fase 3: con TEC-12 |
| PED-12 | 4 | pendiente | | común a los nueve libros |
| PED-13 | 4 | pendiente | | común a los nueve libros |
| PED-14 | 5 | pendiente | | |
| PED-15 | 5 | pendiente | | |
| COH-12 | 4 | pendiente | | libro 07 |
| PED-16 | 5 | pendiente | | |

## Fuera de alcance: libro 04

Dos errores verificados durante la auditoría, que se corrigen en la fase 4 por decisión de Ramón
(22 de noviembre de 2026):

| Ubicación | Error | Fuente | Estado | Commit |
| --- | --- | --- | --- | --- |
| `04-comunicaciones/cap04-…:65` | SIGMET «hasta 4 horas (6 h en zonas oceánicas)» | MET.OR.250 c); AIP GEN 3.5 §8.1: 6 h sólo para cenizas volcánicas y ciclones tropicales | pendiente | |
| `04-comunicaciones/cap04-…:27`, `:57`, `:84`; `04-comunicaciones/glosario.qmd:120` | VOLMET con «METAR, TAF y SIGMET» | AIP GEN 3.5 §7: «Informe MET, QNH y TREND» | pendiente | |

## Banco de examen

Las correcciones de `examenes/` van en su rama local `auditoria-03`, que sale de `main` (`4d4a947`)
y no tiene remoto.

| Fase | Commit en `examenes/` | Preguntas |
| --- | --- | --- |
| 2 | `96c1a4d` | lección 05: retroalimentación de la opción C de la lluvia engelante (`c05-q07`) |
| 3 | `7f4b848` | lecciones 02, 06, 08, 09 y 10 y examen-50: citas de los post-it corregidos (Foehn, brisa, frente cálido, Baja Térmica, Cb), margen de los Cb (P32) y briefing meteorológico con SAO.OP.120(b), SAO.OP.135 y SERA.2010(b) |

`make check` y `make lecciones-check` fallan desde antes de esta corrección, en todos los libros
menos el 01, porque las lecciones anotan versiones anteriores a la v0.9.9 (las del 03, la
1.0-rc.16). La línea de versión se actualiza al revalidar las citas contra los post-it; mientras,
el JSON web se regenera con `node scripts/export_lecciones_json.js`.

## Edición inglesa

Pendiente (fase 6). `en/03-meteorology/` va además un commit por detrás en cap03 y cap07 (`457008f`,
notación de la rc.18).

## Figuras marcadas para corregir

Cada figura con un error lleva la clase `.corregir`, la marca «EN REVISIÓN» encima y, al final del
pie, *(CORREGIR: …)*; en inglés, «IN REVIEW» y *(FIX: …)*. Al entregar la figura nueva se quitan la
clase y la nota, y se anota aquí.

| Capítulo | Figura | Hallazgo | Marcada en | Sustituida en |
| --- | --- | --- | --- | --- |
| cap03 | `03-cap03-base-cumulos-dalr-nca` | TEC-01 | fase 2 | |
| cap06 | `03-cap06-frente-frio-estructura` | TEC-04 | fase 2 | |
| cap10 | `03-cap10-sigwx` | TEC-05 | fase 2 | |
| cap01 | `03-cap01-atmosfera-isa` | TEC-06 | fase 3 | |
| cap02 | `03-cap02-gradiente-isobaras` | PED-01 | fase 3 | |
| cap04 | `03-cap04-familias-nubes-perfil` | TEC-16 | fase 3 | |
| cap06 | `03-cap06-frente-ocluido` | TEC-16, TEC-30 | fase 3 | |
| cap06 | `03-cap06-frente-calido-nubes` | TEC-19 | fase 3 | |
| cap09 | `03-cap09-ciclo-tormenta` | COH-04 | fase 3 | |
| cap09 | `03-cap09-estela-turbulenta` | COH-05 | fase 3 | |

## Preguntas abiertas

| Pregunta | A quién | Hallazgo | Respuesta |
| --- | --- | --- | --- |
| ¿Qué combinación de CAPE, TT, K y LI es buen día de vuelo a vela en la Península sin riesgo de sobredesarrollo? | meteorólogo, FI(S) de travesía | TEC-02, COH-02 | |
| ¿Hay calibración regional de los umbrales del TT y del K para la Península? | meteorólogo | TEC-13, TEC-14 | |
| Estación de la niebla de advección costera; situación típica de primavera y verano; Baja Térmica; anticiclón invernal | meteorólogo de AEMET | TEC-17, TEC-21, TEC-22, TEC-32 | |
| ¿«Pantano barométrico» es sinónimo de «collado»? | meteorólogo de AEMET | COH-11 | |
| Tope de 5.000 m de BR en el Anexo 3 o la OMM-306 | meteorólogo aeronáutico | COH-03 | |
| Masa ártica y engelamiento severo | meteorólogo | TEC-31 | |
| Redacción correcta del CCL | meteorólogo | TEC-37 | |
| Símbolo rojo del mapa SWL | meteorólogo de AEMET | TEC-05 | |
| Föhn mayor que el del mecanismo descrito; microclima del Tiétar | meteorólogo | TEC-07 | |
| Salida de una lluvia engelante en planeador | FI(S) | TEC-03 | |
| Margen con lluvia, separación de un Cb, 500 km, 300 ft a sotavento, bases y térmicas postfrontales | FI(S) | PED-02 | |
| Regla del TT en llano y el K en montaña | FI(S), meteorólogo | TEC-14 | |
| Criterio de viento para la onda a nivel de las cimas | FI(S) de onda | TEC-38 | |
| Restitución, térmicas bajo Föhn, burbuja y columna por la hora, aterrizaje antes de las 16:00, zonas de onda del cap08, térmica del centro del valle | FI(S) de montaña | informe, «Pendiente de verificar» | |
| Lluvia y capa límite; hielo y bataneo | FI(S) o aerodinamicista | TEC-29, TEC-41 | |
| Procedencia de la figura de la estela | Ramón | COH-05 | No se sabe; sustituir por la NASA L90-5919 (22-11-2026) |
