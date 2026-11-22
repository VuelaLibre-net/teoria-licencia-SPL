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
| TEC-06 | Figura ISA mal trazada | 3 | pendiente | | |
| SYL-01 | 3.1: estructura de la atmósfera y altitudes de presión y densidad | 3 | pendiente | | |
| TEC-07 | Föhn: 10–15 °C no reproducible | 3 | pendiente | | |
| TEC-08 | Brisa marina sólo «suave y continua» | 3 | pendiente | | |
| COH-01 | Figuras del GFH del cap02 mal enlazadas | 3 | pendiente | | |
| PED-01 | Figura de isobaras | 3 | pendiente | | |
| TEC-09 | Fórmula de la base sin paréntesis | 3 | pendiente | | |
| TEC-10 | «Altitud» de la base, es altura AGL | 3 | pendiente | | |
| TEC-11 | Estabilidad absoluta y condicional | 3 | pendiente | | |
| TEC-12 | Fórmulas del TT y del K perdidas | 3 | pendiente | | |
| TEC-13 | Escala del TT atribuida a Miller | 3 | pendiente | | |
| TEC-14 | «El K es más representativo en montaña» | 3 | pendiente | | |
| COH-02 | Bandas de los índices contradictorias | 3 | pendiente | | la banda de buen día, con TEC-02 |
| TEC-15 | Signo del LI | 3 | pendiente | | |
| TEC-16 | Clasificación de nubes y piso del Ns | 3 | pendiente | | |
| COH-03 | Neblina o bruma (BR): umbral y nombre | 3 | pendiente | | |
| TEC-17 | Niebla de advección: estación | 3 | pendiente | | |
| TEC-18 | Downburst y microrráfaga | 3 | pendiente | | |
| SYL-02 | 3.5: formación y tipos de precipitación | 3 | pendiente | | |
| PED-02 | Cifras de seguridad sin fuente | 3 | pendiente | | validación, pregunta al FI(S) |
| TEC-19 | Frente cálido «estabiliza completamente» | 3 | pendiente | | |
| TEC-20 | Frente estacionario | 3 | pendiente | | |
| TEC-21 | Pm «primavera-verano» | 3 | pendiente | | |
| TEC-22 | Baja Térmica «permanente» | 3 | pendiente | | |
| COH-04 | Figura del ciclo de la tormenta | 3 | pendiente | | |
| TEC-23 | Granizo bajo el yunque | 3 | pendiente | | |
| COH-05 | Figura de la estela atribuida a la NASA | 3 | pendiente | | sustituir por NASA L90-5919 con su crédito |
| TEC-24 | SPECI | 3 | pendiente | | |
| TEC-25 | SKC | 3 | pendiente | | |
| NOR-01 | AIRMET, GAMET y SWL hasta FL150 | 3 | pendiente | | |
| NOR-02 | «Obligatorio» y «vinculante» | 3 | pendiente | | |
| SYL-03 | 3.10: radar, satélite y cartas | 3 | pendiente | | |
| TEC-26 | CAPE desde el LFC (glosario) | 3 | pendiente | | |
| COH-06 | Dorsal (glosario) | 3 | pendiente | | |
| TEC-27 | Fenómenos SIGMET (glosario) | 3 | pendiente | | |
| TEC-28 | Estela: entrar alineado (glosario) | 3 / 4 | pendiente | | el 06, en la fase 4 |
| COH-07 | Bibliografía sin fuentes meteorológicas | 3 | pendiente | | |
| PED-03 | Reconocimientos: alcance de la validación | 4 | pendiente | | común a los nueve libros |

## Bajas

| ID | Fase | Estado | Commit | Nota |
| --- | --- | --- | --- | --- |
| PED-04 | 5 | pendiente | | |
| PED-05 | 5 | pendiente | | |
| PED-06 | 5 | pendiente | | cambia el post-it del cap03 |
| PED-07 | 5 | pendiente | | |
| PED-08 | 3 | pendiente | | con TEC-16 |
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
| TEC-42 | 3 | pendiente | | con TEC-12 |
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
