# Fuentes de las auditorías

Textos normativos, operativos y técnicos que se consultaron en las auditorías de la colección,
descargados de su publicador oficial. Se guardan para que cada hallazgo pueda reconstruirse con la
misma versión que se leyó, aunque el documento cambie después.

| Auditoría | Informe | Descarga |
| --- | --- | --- |
| Libro 01 | `recursos/auditorias/informe-auditoria-libro-01-derecho-aereo-2026-10-01.md` | 1 de octubre de 2026 |
| Libro 02 | `recursos/auditorias/informe-auditoria-libro-02-factores-humanos-2026-10-01.md` | 1 de octubre de 2026 |

La columna «Auditoría» de cada tabla dice qué informe usó cada documento.

Todos son **copias de documentación**, no textos auténticos. Valen el BOE y el Diario Oficial de la
UE. Antes de citar una cifra en un libro, hay que comprobar que la versión de aquí sigue vigente.

`SHA256SUMS` permite comprobar que nadie ha tocado un fichero: `sha256sum -c SHA256SUMS`.

## `ue/`: Unión Europea

Textos consolidados en español del repositorio Cellar de la Oficina de Publicaciones (el mismo
contenido que sirve EUR-Lex, que bloquea las descargas automáticas). La fecha del nombre es la de la
consolidación, que no es la fecha de descarga.

| Fichero | Norma | Consolidación | Apartados usados | Auditoría |
| --- | --- | --- | --- | --- |
| `reg-923-2012-sera-consol-2025-05-01.pdf` | Reglamento de Ejecución (UE) 923/2012, SERA | 01-05-2025 | 01: 2010, 3201, 3210, 3225, 4020, 5001, 5005, 6001, 6005, 7001, 8015, 10001, 11015; apéndices 1, 3 y 4. 02: 2020, 3210 | 01, 02 |
| `reg-2017-373-ats-ais-met-consol-2026-02-22.pdf` | Reglamento de Ejecución (UE) 2017/373 | 22-02-2026 | art. 2; anexo I def. 37; ATS.TR.400/405; AIS.OR.315/505; parte MET (CAVOK) | 01 |
| `reg-1178-2011-aircrew-part-med-consol-2026-04-30.pdf` (y `.xhtml`) | Reglamento (UE) 1178/2011, Parte MED | 30-04-2026 | 01: MED.A.020, 030, 045. 02: MED.A.020, 030; MED.B.055, 075, 095 | 01, 02 |
| `reg-1321-2014-aeronavegabilidad-part-ml-consol-2026-08-07.pdf` | Reglamento (UE) 1321/2014, Parte ML | 07-08-2026 | ML.A.403, 803, 901, 902 | 01 |
| `reg-748-2012-part-21-consol-2026-08-07.pdf` | Reglamento (UE) 748/2012, Parte 21 | 07-08-2026 | 21.A.181, 21.A.801; formulario EASA 25 | 01 |
| `reg-2018-1139-basico-easa-consol-2026-08-02.pdf` | Reglamento (UE) 2018/1139 | 02-08-2026 | art. 76 | 01 |
| `reg-2018-1976-part-sao-sfcl-consol-2021-11-15.pdf` | Reglamento de Ejecución (UE) 2018/1976 (Part-SAO, Part-SFCL) | 15-11-2021 | 01: SAO.GEN.150/155, SFCL.045/115/150/155/160. 02: SAO.GEN.130, SAO.OP.150, SAO.IDE.115 | 01, 02 |
| `reg-996-2010-investigacion-accidentes-consol-2024-05-19.pdf` | Reglamento (UE) 996/2010 | 19-05-2024 | arts. 2, 9, 13 | 01 |
| `reg-376-2014-notificacion-sucesos-consol-2018-09-11.pdf` (y `.xhtml`) | Reglamento (UE) 376/2014 | 11-09-2018 | 01: arts. 2, 4, 16. 02: art. 2.12 (cultura justa) | 01, 02 |
| `reg-2015-1018-lista-sucesos-consol-2026-08-17.pdf` | Reglamento de Ejecución (UE) 2015/1018 | 17-08-2026 | anexo V, sección 2 (planeadores) | 01 |
| `reg-300-2008-security-consol-2026-08-02.pdf` | Reglamento (CE) 300/2008 | 02-08-2026 | arts. 1, 3 | 01 |
| `reg-2015-1998-security-medidas-consol-2026-10-01.pdf` (y `.xhtml`) | Reglamento de Ejecución (UE) 2015/1998 | 01-10-2026 | vigencia | 01 |
| `reg-785-2004-seguros-consol-2020-07-30.pdf` | Reglamento (CE) 785/2004 | 30-07-2020 | art. 2 | 01 |
| `reg-2150-2005-uso-flexible-espacio-aereo.pdf` | Reglamento (CE) 2150/2005 (FUA) | texto original (sin consolidar) | arts. 1, 4-6 | 01 |

Cellar no ofrece PDF para tres consolidaciones: las de 1178/2011, 376/2014 y 2015/1998. De ellas se
guarda el XHTML original y un PDF impreso desde ese XHTML con Chrome. El PDF es sólo para leer con
comodidad: el XHTML es el texto descargado.

En Cellar existe una consolidación posterior del 2017/373, de fecha 04-10-2026. Aquí se guarda la de
22-02-2026, que es la que se citó en la auditoría del libro 01. Para el 2018/1976 y el 1178/2011, la
consulta SPARQL del 1 de octubre de 2026 no dio consolidaciones posteriores a las guardadas.

## `easa/`: EASA

| Fichero | Documento | Edición | Apartados usados | Auditoría |
| --- | --- | --- | --- | --- |
| `easa-easy-access-rules-sailplanes-2022-11.pdf` | Easy Access Rules for Sailplanes | revisión de septiembre de 2020; PDF del 02-11-2022 (incluye 2018/1976 mod. 2020/358 y las ED Decisions 2019/001/R y 2020/004/R) | 01: AMC1 SFCL.130 (syllabus); SAO y SFCL con sus AMC y GM. 02: AMC1 SFCL.130 y 135; SAO.GEN.130 f) y SAO.GEN.135 b) con su AMC1 y GM1; SAO.OP.150 y AMC1; SAO.IDE.115; CS 22.1441/1449 | 01, 02 |
| `easa-easy-access-rules-sera-2025-08.pdf` | Easy Access Rules for Standardised European Rules of the Air (SERA) | agosto de 2025 | 01: AMC1 y GM1 SERA.5005(f). 02: SERA.2020, SERA.3210 | 01, 02 |
| `easa-amc-gm-part-med-issue2-2019.pdf` | AMC & GM to Part-MED, Issue 2 (ED Decision 2019/002/R) | 28-01-2019 | GM1 MED.A.020; AMC14 MED.B.095 | 02 |
| `easa-amc-gm-part-med-issue2-amdt1-2025.pdf` | AMC & GM to Part-MED, Issue 2, Amendment 1 (anexo III de la ED Decision 2025/002/R) | 05-02-2025 | comprobación de que no modifica los apartados anteriores (sólo toca MED.B.010, 015, 055 y 070) | 02 |
| `easa-annual-safety-review-2019.pdf` | Annual Safety Review 2019 | 2019 | cap. 5 (planeadores), figs. 65 y 67 | 02 |
| `easa-annual-safety-review-2025.pdf` | Annual Safety Review 2025 | 2025 | cap. 5 (planeadores), tabla 5.1, figs. 5.5 y 5.7 | 02 |

Fuentes:
- <https://www.easa.europa.eu/en/downloads/94424/en> (el mismo PDF que <https://www.easa.europa.eu/sites/default/files/dfu/Sailplane%20Rule%20Book.pdf>);
- <https://www.easa.europa.eu/en/downloads/68174/en>;
- <https://www.easa.europa.eu/en/downloads/70485/en> y <https://www.easa.europa.eu/en/downloads/141596/en>;
- <https://www.easa.europa.eu/sites/default/files/dfu/Annual%20Safety%20Review%202019.pdf> y <https://www.easa.europa.eu/sites/default/files/dfu/annual_safety_review_2025.pdf>.

Las Easy Access Rules son una compilación, no una publicación oficial. La parte que reproduce el
reglamento es vinculante; los AMC y GM no lo son. La Amendment 1 de los AMC y GM de Part-MED sólo
recoge los cambios; no hay versión consolidada de la Issue 2 con ella incorporada.

## `espana/`: normativa española

PDF consolidados del BOE (`https://www.boe.es/buscar/pdf/AAAA/<id>-consolidado.pdf`), salvo el RD
552/2014, que, por estar derogado, no tiene consolidado y se guarda en su publicación original. Los
ficheros con `DEROGADO` en el nombre se conservan porque la auditoría constata precisamente su
derogación.

| Fichero | Norma | Identificador BOE | Apartados usados | Auditoría |
| --- | --- | --- | --- | --- |
| `rd-1180-2018-reglamento-del-aire.pdf` | Real Decreto 1180/2018 | BOE-A-2018-15406 | 01: arts. 6, 30, 33; anexo I; disposición derogatoria. 02: búsqueda de «alcohol» | 01, 02 |
| `rd-552-2014-reglamento-del-aire-DEROGADO.pdf` | Real Decreto 552/2014 (derogado por el RD 1180/2018) | BOE-A-2014-6856 | art. 15 | 01 |
| `ley-21-2003-seguridad-aerea.pdf` | Ley 21/2003, de Seguridad Aérea | BOE-A-2003-13616 | 01: arts. 3, 4 bis, 33-36, 44, 48, 50, 55, 56, 58. 02: arts. 25.2 d), 34 | 01, 02 |
| `ley-2-2024-autoridad-investigacion-accidentes.pdf` | Ley 2/2024 (Autoridad de investigación de accidentes) | BOE-A-2024-15937 | disposición adicional primera; arts. 9, 21 | 01 |
| `rd-141-2026-estatuto-autoridad-investigacion.pdf` | Real Decreto 141/2026 (Estatuto de la Autoridad) | BOE-A-2026-4518 | disposiciones adicionales y transitorias | 01 |
| `ley-48-1960-navegacion-aerea.pdf` | Ley 48/1960, sobre Navegación Aérea | BOE-A-1960-10905 | arts. 120, 127 | 01 |
| `ley-209-1964-penal-procesal-navegacion-aerea.pdf` | Ley 209/1964, Penal y Procesal de la Navegación Aérea | BOE-A-1964-21509 | art. 31 | 01, 02 |
| `rd-1189-2011-aerodromos-uso-restringido.pdf` | Real Decreto 1189/2011 (aeródromos de uso restringido y eventuales) | BOE-A-2011-14118 | arts. 1.2, 2 b), 16 | 01 |
| `rd-1029-2025-matriculacion-aeronaves.pdf` | Real Decreto 1029/2025 (matriculación) | BOE-A-2025-22950 | art. 4; disposición adicional segunda | 01 |
| `rd-384-2015-matriculacion-aeronaves-DEROGADO.pdf` | Real Decreto 384/2015 (derogado por el RD 1029/2025) | BOE-A-2015-6704 | — | 01 |
| `orden-fom-1687-2015-marcas-aeronaves.pdf` | Orden FOM/1687/2015 (marcas de nacionalidad y matrícula) | BOE-A-2015-8940 | arts. 4-5; anexo II | 01 |
| `rd-184-2008-estatuto-aesa.pdf` | Real Decreto 184/2008 (Estatuto de AESA) | BOE-A-2008-2595 | arts. 8-9 | 01 |
| `rd-253-2024-estructura-ministerio-transportes.pdf` | Real Decreto 253/2024 (estructura del Ministerio) | BOE-A-2024-4865 | art. 8 (DGAC) | 01 |
| `rd-1088-2020-notificacion-sucesos.pdf` | Real Decreto 1088/2020 (notificación de sucesos) | BOE-A-2020-15874 | arts. 1-3 | 01 |

## `oaci/`: OACI

| Fichero | Documento | Edición | Auditoría |
| --- | --- | --- | --- |
| `oaci-doc-7300-9-convenio-chicago.pdf` | Doc 7300/9, Convenio sobre Aviación Civil Internacional (en inglés) | 9.ª edición, 2006 | 01 |
| `oaci-doc-8984-medicina-aeronautica-3ed-2012.pdf` | Doc 8984, *Manual of Civil Aviation Medicine* (en inglés) | 3.ª edición, 2012 | 02 |
| `oaci-doc-9683-factores-humanos-1ed-1998.pdf` | Doc 9683-AN/950, *Human Factors Training Manual* (en inglés) | 1.ª edición, 1998 | 02 |

Fuentes:
- <https://www.icao.int/sites/default/files/publications/DocSeries/7300_cons.pdf>;
- <https://www.icao.int/sites/default/files/publications/DocSeries/8984_cons_en.pdf>;
- el Doc 9683, de la copia que publica la Oficina Federal de Aviación Civil suiza: <https://www.bazl.admin.ch/dam/de/sd-web/OT9uxJkwN3-x/icao_doc_9683_human_factors_training_manual.pdf>.

Los Doc 8984 y 9683 son manuales de orientación: no son vinculantes.

No se guardan los Anexos 7, 11, 12, 14, 17 y 18 ni el Doc 8400: son de pago, y la auditoría del
libro 01 los suplió con transposiciones de la UE y con el AIP. Tampoco la reproducción no oficial
del Anexo 7 que se consultó como orientación.

## `faa/`: Administración Federal de Aviación de EE. UU.

Manuales, circulares y folletos de la FAA. Son de otra jurisdicción y **no son vinculantes en
España**: la auditoría del libro 02 los usa como fuente técnica de fisiología, factores humanos y
equipos de oxígeno, donde no hay norma EASA. Los ficheros `.html` son instantáneas de una página en
línea que cambia; el nombre lleva la fecha de descarga.

| Fichero | Documento | Edición | Apartados usados | Auditoría |
| --- | --- | --- | --- | --- |
| `faa-h-8083-25c-phak-2023.pdf` | *Pilot's Handbook of Aeronautical Knowledge*, FAA-H-8083-25C | 2023 | caps. 2 (ADM, DECIDE, PAVE, 3P, IMSAFE), 7 (equipos de oxígeno) y 17 (medicina aeronáutica) | 02 |
| `faa-h-8083-9b-aviation-instructors-handbook-2020.pdf` | *Aviation Instructor's Handbook*, FAA-H-8083-9B | 2020 | caps. 2 (Maslow) y 3 (memoria) | 02 |
| `faa-h-8083-13b-glider-flying-handbook-2024.pdf` | *Glider Flying Handbook*, FAA-H-8083-13B | diciembre de 2024 | cap. 7 («Roll-In») | 02 |
| `faa-aim-cap8-seccion1-2026-10-01.html` | *Aeronautical Information Manual*, cap. 8, sección 1 | página fechada el 07-09-2026 | 8-1-1 a 8-1-3, 8-1-6, 8-1-8 | 02 |
| `faa-ac-61-107b-chg1-operaciones-gran-altitud.pdf` | AC 61-107B CHG 1, *Aircraft Operations at Altitudes Above 25,000 Feet MSL…* | 29-03-2013, cambio 1 del 09-09-2015 | 2-7 (hipoxia, hiperventilación, TUC, pulsioxímetro) | 02 |
| `faa-ac-90-48e-ver-y-evitar-2022.pdf` | AC 90-48E, *Pilots' Role in Collision Avoidance* | 20-10-2022 | tabla 1 (tiempo de reacción) | 02 |
| `faa-cami-hypoxia-2020.pdf` | CAMI, folleto *Hypoxia* | 2020 | síntomas y su orden | 02 |
| `faa-cami-oxygen-equipment.pdf` | CAMI, folleto *Oxygen Equipment: Use in General Aviation Operations* | sin fecha visible | cánula, mascarilla, flujo continuo, PRICE | 02 |
| `faa-gajsc-fly-the-aircraft-first-2015.pdf` | FAA/GAJSC, *Safety Enhancement Topic: Fly the Aircraft First* | enero de 2015 | *aviate, navigate, communicate* | 02 |

Fuentes, todas en `faa.gov` salvo la última, en `faasafety.gov`:
- <https://www.faa.gov/sites/faa.gov/files/FAA-H-8083-25C.pdf>;
- <https://www.faa.gov/sites/faa.gov/files/regulations_policies/handbooks_manuals/aviation/aviation_instructors_handbook/aviation_instructors_handbook.pdf>;
- <https://www.faa.gov/sites/faa.gov/files/Glider-Flying-Handbook.pdf>;
- <https://www.faa.gov/air_traffic/publications/atpubs/aim_html/chap8_section_1.html>;
- <https://www.faa.gov/documentLibrary/media/Advisory_Circular/AC_61-107B_CHG_1.pdf>;
- <https://www.faa.gov/documentLibrary/media/Advisory_Circular/AC_90-48E.pdf>;
- <https://www.faa.gov/pilots/safety/pilotsafetybrochures/media/hypoxia.pdf>;
- <https://www.faa.gov/pilots/safety/pilotsafetybrochures/media/oxygen_equipment.pdf>;
- <https://www.faasafety.gov/files/events/GL/GL09/2021/GL09109386/SE_Topic15-01_Fly_the_Aircraft_First.pdf>.

## `otras/`: otras fuentes

| Fichero | Documento | Edición | Naturaleza | Auditoría |
| --- | --- | --- | --- | --- |
| `wada-codigo-mundial-antidopaje-2021.pdf` | Agencia Mundial Antidopaje, Código Mundial Antidopaje | 2021, vigente hasta la entrada en vigor del Código de 2027 | primaria deportiva | 02 |
| `mountain-high-eds-2g-manual.pdf` | Mountain High, *MH EDS 2G User Manual* | 2019 | fabricante (secundaria) | 02 |
| `hse-hsg48-human-factors-introduction-2026-10-01.html` | UK Health and Safety Executive, HSG48, página de introducción a los factores humanos | página en línea | primaria (definición de la HSE) | 02 |

Fuentes:
- <https://www.wada-ama.org/sites/default/files/resources/files/2021_wada_code.pdf>. El 1 de octubre de 2026 el servidor respondía con un 202 vacío a la descarga automática; la copia es la que obtuvo ese mismo día el agente del bloque B de la auditoría;
- <https://www.mhoxygen.com/2016/download/870/eds-o2d1/27220/5md20-0003-00-1.pdf>;
- <https://www.hse.gov.uk/humanfactors/introduction.htm>.

## `aip/`: AIP España (ENAIRE)

Información aeronáutica **dinámica**: cambia con cada enmienda AIRAC. Estas copias muestran lo que
decía el AIP el 1 de octubre de 2026 (AMDT 411/26, AIRAC 09/26 en vigor desde ese día), y no deben
usarse como fuente vigente sin volver a descargarlas. Algunas secciones sólo pudieron descargarse en
su versión inglesa (`_en`). Todas se usaron en la auditoría del libro 01.

| Fichero | Sección | Usada en |
| --- | --- | --- |
| `aip-espana-GEN_2_2_es.pdf` | GEN 2.2, abreviaturas | glosario |
| `aip-espana-GEN_3_1_es.pdf` | GEN 3.1, servicios de información aeronáutica | cap09 (SUP, PIB, AIRAC) |
| `aip-espana-GEN_3_3_es.pdf` | GEN 3.3, servicios de tránsito aéreo | cap08 (AFIS, FIS en ruta) |
| `aip-espana-GEN_3_6_es.pdf` | GEN 3.6, búsqueda y salvamento | cap11 (ARCC, señales) |
| `aip-espana-ENR_1_2_en.pdf` | ENR 1.2, reglas de vuelo visual | cap05, cap06 |
| `aip-espana-ENR_1_4_en.pdf` | ENR 1.4, clasificación del espacio aéreo | cap07 |
| `aip-espana-ENR_1_6_es.pdf` | ENR 1.6, servicios radar y transpondedor | cap07 (transpondedor) |
| `aip-espana-ENR_1_7_es.pdf` | ENR 1.7, reglaje de altímetro y niveles de crucero | cap06 |
| `aip-espana-ENR_2_1_en.pdf` | ENR 2.1, FIR, CTA y TMA | cap07, cap11 |
| `aip-espana-ENR_5_1_en.pdf` | ENR 5.1, zonas prohibidas, restringidas y peligrosas | cap07 |
| `aip-espana-AD_2_LEZG_es.pdf` | AD 2-LEZG, aeródromo de Zaragoza | cap09 (ejemplo de NOTAM) |

## Qué no está aquí

Quedan fuera las fuentes que no son documentos estables:

- **Auditoría del libro 01:**
  - las páginas web de AESA, del Ministerio de Transportes y de Cospas-Sarsat;
  - la AC 150/5345-27F de la FAA;
  - el artículo de *Professional Safety* sobre Heinrich;
  - la prensa.
- **Auditoría del libro 02:**
  - el blog de C. Ceipek (*Chess in the Air*);
  - la ficha del informe HFACS de la FAA;
  - el artículo de Rochette *et al.* (2023) sobre Selye, de acceso abierto en PubMed Central;
  - la entrada de EU-OSHA sobre el error humano;
  - la de Wikipedia sobre la carga de trabajo;
  - las páginas de Mountain High, incluido el artículo de *Soaring* que reproducen.
