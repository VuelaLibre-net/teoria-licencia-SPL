# Fuentes legales de la auditoría del libro 01

Textos normativos y operativos que se consultaron en la auditoría del libro 01
(`recursos/auditorias/informe-auditoria-libro-01-derecho-aereo-2026-10-01.md`), descargados el
**1 de octubre de 2026** de su publicador oficial. Se guardan para que cada hallazgo pueda
reconstruirse con la misma versión que se leyó, aunque la norma cambie después.

Todos son **copias de documentación**, no textos auténticos. Valen el BOE y el Diario Oficial de la
UE. Antes de citar una cifra en un libro, hay que comprobar que la versión de aquí sigue vigente.

`SHA256SUMS` permite comprobar que nadie ha tocado un fichero: `sha256sum -c SHA256SUMS`.

## `ue/`: Unión Europea

Textos consolidados en español del repositorio Cellar de la Oficina de Publicaciones (el mismo
contenido que sirve EUR-Lex, que bloquea las descargas automáticas). La fecha del nombre es la de la
consolidación, que no es la fecha de descarga.

| Fichero | Norma | Consolidación | Apartados usados en la auditoría |
| --- | --- | --- | --- |
| `reg-923-2012-sera-consol-2025-05-01.pdf` | Reglamento de Ejecución (UE) 923/2012, SERA | 01-05-2025 | 2010, 3201, 3210, 3225, 4020, 5001, 5005, 6001, 6005, 7001, 8015, 10001, 11015; apéndices 1, 3 y 4 |
| `reg-2017-373-ats-ais-met-consol-2026-02-22.pdf` | Reglamento de Ejecución (UE) 2017/373 | 22-02-2026 | art. 2; anexo I def. 37; ATS.TR.400/405; AIS.OR.315/505; parte MET (CAVOK) |
| `reg-1178-2011-aircrew-part-med-consol-2026-04-30.pdf` (y `.xhtml`) | Reglamento (UE) 1178/2011, Parte MED | 30-04-2026 | MED.A.020, 030, 045 |
| `reg-1321-2014-aeronavegabilidad-part-ml-consol-2026-08-07.pdf` | Reglamento (UE) 1321/2014, Parte ML | 07-08-2026 | ML.A.403, 803, 901, 902 |
| `reg-748-2012-part-21-consol-2026-08-07.pdf` | Reglamento (UE) 748/2012, Parte 21 | 07-08-2026 | 21.A.181, 21.A.801; formulario EASA 25 |
| `reg-2018-1139-basico-easa-consol-2026-08-02.pdf` | Reglamento (UE) 2018/1139 | 02-08-2026 | art. 76 |
| `reg-2018-1976-part-sao-sfcl-consol-2021-11-15.pdf` | Reglamento de Ejecución (UE) 2018/1976 (Part-SAO, Part-SFCL) | 15-11-2021 | SAO.GEN.150/155, SFCL.045/115/150/155/160 |
| `reg-996-2010-investigacion-accidentes-consol-2024-05-19.pdf` | Reglamento (UE) 996/2010 | 19-05-2024 | arts. 2, 9, 13 |
| `reg-376-2014-notificacion-sucesos-consol-2018-09-11.pdf` (y `.xhtml`) | Reglamento (UE) 376/2014 | 11-09-2018 | arts. 2, 4, 16 |
| `reg-2015-1018-lista-sucesos-consol-2026-08-17.pdf` | Reglamento de Ejecución (UE) 2015/1018 | 17-08-2026 | anexo V, sección 2 (planeadores) |
| `reg-300-2008-security-consol-2026-08-02.pdf` | Reglamento (CE) 300/2008 | 02-08-2026 | arts. 1, 3 |
| `reg-2015-1998-security-medidas-consol-2026-10-01.pdf` (y `.xhtml`) | Reglamento de Ejecución (UE) 2015/1998 | 01-10-2026 | vigencia |
| `reg-785-2004-seguros-consol-2020-07-30.pdf` | Reglamento (CE) 785/2004 | 30-07-2020 | art. 2 |
| `reg-2150-2005-uso-flexible-espacio-aereo.pdf` | Reglamento (CE) 2150/2005 (FUA) | texto original (sin consolidar) | arts. 1, 4-6 |

Cellar no ofrece PDF para tres consolidaciones: las de 1178/2011, 376/2014 y 2015/1998. De ellas se
guarda el XHTML original y un PDF impreso desde ese XHTML con Chrome. El PDF es sólo para leer con
comodidad: el XHTML es el texto descargado.

En Cellar existe una consolidación posterior del 2017/373, de fecha 04-10-2026. Aquí se guarda la de
22-02-2026, que es la que se citó en la auditoría.

## `easa/`: EASA

| Fichero | Documento | Edición | Apartados usados |
| --- | --- | --- | --- |
| `easa-easy-access-rules-sailplanes-2022-11.pdf` | Easy Access Rules for Sailplanes | PDF de noviembre de 2022 (incluye 2018/1976 mod. 2020/358, ED Decisions 2019/001/R y 2020/004/R) | AMC1 SFCL.130 (syllabus); SAO y SFCL con sus AMC y GM |
| `easa-easy-access-rules-sera-2025-08.pdf` | Easy Access Rules for Standardised European Rules of the Air (SERA) | agosto de 2025 | AMC1 y GM1 SERA.5005(f) |

Fuentes: <https://www.easa.europa.eu/en/downloads/94424/en> y <https://www.easa.europa.eu/en/downloads/68174/en>.
Las Easy Access Rules son una compilación, no una publicación oficial. La parte que reproduce el
reglamento es vinculante; los AMC y GM no lo son.

## `espana/`: normativa española

PDF consolidados del BOE (`https://www.boe.es/buscar/pdf/AAAA/<id>-consolidado.pdf`), salvo el RD
552/2014, que, por estar derogado, no tiene consolidado y se guarda en su publicación original. Los
ficheros con `DEROGADO` en el nombre se conservan porque la auditoría constata precisamente su
derogación.

| Fichero | Norma | Identificador BOE | Apartados usados |
| --- | --- | --- | --- |
| `rd-1180-2018-reglamento-del-aire.pdf` | Real Decreto 1180/2018 | BOE-A-2018-15406 | arts. 6, 30, 33; anexo I; disposición derogatoria |
| `rd-552-2014-reglamento-del-aire-DEROGADO.pdf` | Real Decreto 552/2014 (derogado por el RD 1180/2018) | BOE-A-2014-6856 | art. 15 |
| `ley-21-2003-seguridad-aerea.pdf` | Ley 21/2003, de Seguridad Aérea | BOE-A-2003-13616 | arts. 3, 4 bis, 33-36, 44, 48, 50, 55, 56, 58 |
| `ley-2-2024-autoridad-investigacion-accidentes.pdf` | Ley 2/2024 (Autoridad de investigación de accidentes) | BOE-A-2024-15937 | disposición adicional primera; arts. 9, 21 |
| `rd-141-2026-estatuto-autoridad-investigacion.pdf` | Real Decreto 141/2026 (Estatuto de la Autoridad) | BOE-A-2026-4518 | disposiciones adicionales y transitorias |
| `ley-48-1960-navegacion-aerea.pdf` | Ley 48/1960, sobre Navegación Aérea | BOE-A-1960-10905 | arts. 120, 127 |
| `ley-209-1964-penal-procesal-navegacion-aerea.pdf` | Ley 209/1964, Penal y Procesal de la Navegación Aérea | BOE-A-1964-21509 | art. 31 |
| `rd-1189-2011-aerodromos-uso-restringido.pdf` | Real Decreto 1189/2011 (aeródromos de uso restringido y eventuales) | BOE-A-2011-14118 | arts. 1.2, 2 b), 16 |
| `rd-1029-2025-matriculacion-aeronaves.pdf` | Real Decreto 1029/2025 (matriculación) | BOE-A-2025-22950 | art. 4; disposición adicional segunda |
| `rd-384-2015-matriculacion-aeronaves-DEROGADO.pdf` | Real Decreto 384/2015 (derogado por el RD 1029/2025) | BOE-A-2015-6704 | — |
| `orden-fom-1687-2015-marcas-aeronaves.pdf` | Orden FOM/1687/2015 (marcas de nacionalidad y matrícula) | BOE-A-2015-8940 | arts. 4-5; anexo II |
| `rd-184-2008-estatuto-aesa.pdf` | Real Decreto 184/2008 (Estatuto de AESA) | BOE-A-2008-2595 | arts. 8-9 |
| `rd-253-2024-estructura-ministerio-transportes.pdf` | Real Decreto 253/2024 (estructura del Ministerio) | BOE-A-2024-4865 | art. 8 (DGAC) |
| `rd-1088-2020-notificacion-sucesos.pdf` | Real Decreto 1088/2020 (notificación de sucesos) | BOE-A-2020-15874 | arts. 1-3 |

## `oaci/`: OACI

| Fichero | Documento | Edición |
| --- | --- | --- |
| `oaci-doc-7300-9-convenio-chicago.pdf` | Doc 7300/9, Convenio sobre Aviación Civil Internacional (en inglés) | 9.ª edición, 2006 |

Fuente: <https://www.icao.int/sites/default/files/publications/DocSeries/7300_cons.pdf>.

No se guardan los Anexos 7, 11, 12, 14, 17 y 18 ni el Doc 8400: son de pago, y la auditoría los
suplió con transposiciones de la UE y con el AIP. Tampoco la reproducción no oficial del Anexo 7 que
se consultó como orientación.

## `aip/`: AIP España (ENAIRE)

Información aeronáutica **dinámica**: cambia con cada enmienda AIRAC. Estas copias muestran lo que
decía el AIP el 1 de octubre de 2026 (AMDT 411/26, AIRAC 09/26 en vigor desde ese día), y no deben
usarse como fuente vigente sin volver a descargarlas. Algunas secciones sólo pudieron descargarse en
su versión inglesa (`_en`).

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

Sólo se guardan documentos legales u oficiales. Quedan fuera las fuentes secundarias de la auditoría:

- las páginas web de AESA, del Ministerio de Transportes y de Cospas-Sarsat;
- el *Glider Flying Handbook* y la AC 150/5345-27F de la FAA;
- el artículo de *Professional Safety* sobre Heinrich;
- la prensa.
