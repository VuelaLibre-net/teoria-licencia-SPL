# Auditoría del libro 03: *Meteorología*

**Libro:** 03. Meteorología
**Fuente:** `03-meteorologia/`: `cap01…cap10-*.qmd`, `introduccion.qmd`, `licencia.qmd`, `dedicatoria.qmd`, `epigrafe.qmd`, `reconocimientos.qmd`, `colofon.qmd`, `contracubierta.qmd`, `apendice-syllabus-oficial-easa---meteorologia.qmd`, `apendice-fuentes-meteorologia.qmd`, `glosario.qmd`, `bibliografia.qmd`
**Versión:** 1.0-rc.19 (`03-meteorologia/_quarto.yml:6`)
**Estado editorial:** Candidato de versión (`make estados`)
**Fecha:** 2026-11-21
**Modalidad:** completa (libro entero, capítulo a capítulo)
**Base de comparación:** `main` en `34a083c`. El `[En curso]` de `CHANGELOG-03.md` está vacío. La rc.17 (2 de octubre de 2026) ya aplicó a este libro siete correcciones que venían de las auditorías de los libros 01 y 02; se concilian, no se redescubren.
**Diff revisado:** no aplica; la modalidad es completa. Informe anterior conciliado: `aesa-spl-oficial/recursos/auditorias/informe-evaluacion-libro-03-meteorologia-spl.md`, de julio de 2026, sobre el PDF v1.0.2.
**Verificación externa:** completa en lo normativo (Part-MET consolidado a 04-10-2026, AIP España GEN 3.5 AIRAC AMDT 10/26, SERA, Part-SAO) y en la mayor parte de lo técnico. Incompleta en tres frentes: el Anexo 3 de la OACI es de pago; el MeteoGlosario de AEMET, el Manual de claves OMM-306 y el glosario de la AMS no fueron accesibles; y varias heurísticas de vuelo a vela y de climatología española quedan como `requiere experto`.

**Derivados revisados:**
- mazos Anki `tools/anki/mazos/03-meteorologia/cap01…cap10.yml` (73 tarjetas) y su espejo `tools/anki/mazos/en/03-meteorology/`;
- las 26 figuras de `03-meteorologia/imagenes/`, abiertas una a una (el libro no tiene fichas `.prompt.md` en `prompts/`, a diferencia del 02 tras su fase 7);
- el banco de examen `examenes/json/meteorologia.json` (87 preguntas, generado desde la rc.16), las lecciones `examenes/lecciones/03-meteorologia-leccion-01…05.md` y el examen `examenes/oficial/03-meteorologia-examen-50.md` con su distribución (repositorio git propio, excluido del principal);
- la edición inglesa `en/03-meteorology/` (0.8.3), rastreada como derivado y no auditada como traducción. Dos ficheros van un commit por detrás del español: `cap03` y `cap07` no recogen `457008f` (cambio de notación de la rc.18);
- los capítulos de otros libros que tratan la misma materia: `04/cap04` (términos meteorológicos VFR), `02/cap04`, `05/cap05`, `06/cap03` y `cap06`, `07/cap03`, y los glosarios de los nueve libros.

---

## Resumen ejecutivo

El libro conserva lo que el informe de julio valoró: los diez capítulos siguen uno a uno los diez epígrafes del AMC1 SFCL.130, el anclaje en la climatología ibérica es real (nieblas del Duero y del Ebro, DANA, Baja Térmica), la decodificación del METAR termina en una decisión de vuelo y la mayoría de las cifras nucleares (ISA, DALR, ×400, CAVOK, octas, validez del METAR, TEMPO, PROB) son correctas. Desde julio se han resuelto H1, H2, H3 y H4 en el texto, H6 en el rótulo y H7.

Esta auditoría, más profunda que la de julio y con fuentes vigentes a 21 de noviembre de 2026, **no encuentra bloqueantes**, pero sí cinco hallazgos altos, cuatro de ellos en figuras:

**Mensajes de seguridad:**
- **Lluvia engelante** (cap05 y glosario): dice que forma «hielo opaco o escarcha» y manda descender a temperatura positiva. En la FZRA se forma hielo claro y el aire cálido está arriba; la FAA advierte que descender puede no sacar de ella (TEC-03).
- **CAPE** (cap03, `.mas-alla`): presenta 1.000–2.500 J/kg como «excelente» y «sin el riesgo de tormenta severa». El NWS lo clasifica como moderadamente inestable, con corrientes de tormenta (TEC-02).

**Figuras que enseñan lo contrario del texto:**
- **Base de los cúmulos** (cap03): las curvas no cuadran con los datos del recuadro; la parcela llega al NCA más fría que el ambiente (TEC-01).
- **Frente frío** (cap06): la cuña fría está dibujada en el lado prefrontal y el terreno se rotula «más frío que el aire post-frontal», al revés del mecanismo que el capítulo enseña (TEC-04).
- **SIGWX** (cap10): los rótulos dan las alturas en «hectopiescales (hPa)», V5 «entre 5 y 8 km» y llaman «frente frío» a un festón de nubes, contra la leyenda de la propia carta y el AIP (TEC-05).

Entre los 38 hallazgos medios destacan tres grupos: la **sección de índices de sondeo** del cap03 (fórmulas del TT y del K perdidas al importar, signo del LI invertido, escala de Miller mal atribuida, bandas que se contradicen entre tablas); **datos del producto español** que el libro da con la regla genérica de la UE (AIRMET, GAMET y SWL hasta FL150 en toda la FIR; SPECI; SKC, que no existe en el METAR europeo); y **lagunas de syllabus** (estructura de la atmósfera y altitudes de presión y densidad en 3.1; formación de la precipitación en 3.5; radar, satélite y cartas en 3.10).

**Acción prioritaria:** corregir el mensaje de la lluvia engelante en el capítulo, el glosario, el banco y `en/`; retirar «sin el riesgo de tormenta severa» del CAPE; marcar con `.corregir` las tres figuras altas hasta que se rehagan; y resolver en bloque la sección de índices del cap03 y los niveles de AIRMET y GAMET.

| Dimensión | Veredicto | Motivo breve |
| --- | --- | --- |
| Calidad pedagógica | correcto con mejoras | Buena progresión y buenos ejemplos operativos. Figuras mal enlazadas o sin explicar (COH-01), simplificaciones sin dominio de validez (TEC-11, PED-02) y un post-it del cap03 sin la fórmula de la base (PED-06). |
| Fiabilidad técnica | requiere correcciones (además, incompleto) | Cinco hallazgos altos; TEC-02 con verificación parcial. Varias heurísticas de vuelo a vela y de climatología esperan a un meteorólogo o a un FI(S). |
| Cobertura del syllabus | correcto con mejoras | Los diez epígrafes están presentes. 3.1, 3.5 y 3.10 son parciales (SYL-01 a SYL-03); 3.4 y 3.8 tienen lagunas menores. |
| Coherencia y derivados | requiere correcciones | Glosario contra capítulo (LI, CAPE, BR, dorsal, altura/altitud), figuras contra texto (TEC-01, TEC-04, TEC-05, COH-04) y errores copiados en Anki, banco, lecciones, examen-50 y `en/`. |

**Recomendación editorial:** **apto con correcciones.** No hay bloqueantes. Las altas deben resolverse antes de la versión 1.0; TEC-02 necesita además el visto bueno de un meteorólogo o un FI(S) de travesía sobre qué banda de CAPE es «buen día» en la Península.

### Veredicto por capítulo

| Cap. | Título | Peor hallazgo | Recomendación |
| --- | --- | --- | --- |
| 01 | La atmósfera | media (TEC-06, SYL-01) | apto con correcciones |
| 02 | Viento | media (TEC-07, TEC-08, COH-01, PED-01) | apto con correcciones |
| 03 | Termodinámica | alta (TEC-01, TEC-02, parcial) | apto con correcciones |
| 04 | Nubes y niebla | media (TEC-16, COH-03, TEC-17) | apto con correcciones |
| 05 | Precipitación | alta (TEC-03) | apto con correcciones |
| 06 | Masas de aire y frentes | alta (TEC-04) | apto con correcciones |
| 07 | Sistemas de presión | media (PED-02, derivado de COH-06) | apto con correcciones |
| 08 | Climatología | media (TEC-22) | apto con correcciones |
| 09 | Peligros para el vuelo | media (COH-04, TEC-23, COH-05) | apto con correcciones |
| 10 | Información meteorológica | alta (TEC-05) | apto con correcciones |
| — | Glosario | media (TEC-25 a TEC-28, COH-03, COH-06, derivados de TEC-03 y NOR-01) | apto con correcciones |
| — | Bibliografía | media (COH-07) | apto con correcciones |
| — | Apéndice A (syllabus) | baja (PED-15) | apto |
| — | Apéndice B (fuentes de meteorología) | baja (TEC-38, TEC-39) | apto |
| — | Preliminares e introducción | media (PED-03) | apto con correcciones |

---

## Hallazgos

Los hallazgos van ordenados por severidad y, dentro de cada severidad, por orden de aparición en el libro. Cuando varios capítulos o bloques comparten una misma causa, se agrupan en un único hallazgo con todas sus ubicaciones. Los de severidad baja se recogen en una tabla compacta al final.

### Alta

#### [TEC-01] La figura del cálculo gráfico de la base de los cúmulos contradice sus propios datos

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `03-meteorologia/imagenes/03-cap03-base-cumulos-dalr-nca.jpg`, citada en `cap03-termodinamica.qmd:40`

> Cálculo gráfico de la base de los cúmulos: gradiente DALR, punto de rocío y Nivel de Condensación por Ascenso (NCA)

**Problema:** el recuadro de la figura da T = 26 °C y T~rocío~ = 16 °C en superficie, y el ejemplo concluye 4.000 ft de base. Las curvas dicen otra cosa:
- la línea rotulada «Temperatura ambiente (T)» sale de **13 °C** en el suelo y pasa por 7 °C en el NCA;
- la curva verde de la burbuja empieza en el NCA a **0 °C**; con el DALR debería estar a 26 − 3 × 4 = **14 °C**;
- la parcela queda así **más fría** que el ambiente en el NCA (0 °C frente a 7 °C): es una atmósfera estable, sin cúmulo, lo contrario de lo que se quiere enseñar;
- el tramo saturado baja 1,5 °C cada 2.000 ft (0 → −1,5 → −3,0 → −4,5 °C), es decir, 0,75 °C/1.000 ft, aunque el rótulo dice 1,5 °C/1.000 ft;
- el punto de rocío cae de 16 a 6 °C en unos 2.400 ft (unos 4 °C/1.000 ft) cuando la doctrina da 0,5 °C/1.000 ft;
- el recuadro conserva «2.5 °C» con punto decimal (la rc.18 lo pasó a coma en el texto) y el eje dice «ALTITUD» (ver TEC-10).

**Impacto:** es la figura de la destreza de cálculo más examinable del libro. Quien lea el gráfico aprende curvas imposibles y confunde la curva de estado con la de la parcela.

**Evidencia:** FAA, *Aviation Weather*, AC 00-6B (23-08-2016), §11.2: la parcela no saturada se enfría «approximately 3 °C per 1,000 feet» y «the dewpoint decreases approximately 0.5 °C per 1,000 feet»; §11.3: la parcela saturada, entre unos 1,2 y 3 °C/1.000 ft. https://www.faa.gov/documentLibrary/media/Advisory_Circular/AC_00-6B.pdf (consultado el 2026-11-21). Cálculo reproducible: parcela en el NCA, 26 − 12 = 14 °C; punto de rocío, 16 − 2 = 14 °C; coinciden a 4.000 ft. Comprobado sobre la imagen en la consolidación.

**Propuesta:** rehacer las curvas: parcela de 26 °C en superficie a 14 °C a 4.000 ft y desde ahí unos 1,5 °C/1.000 ft; punto de rocío de 16 a 14 °C; curva ambiente distinta, más fría que la parcela por encima del NCA; «2,5 °C» con coma y eje «Altura (ft AGL)». Mientras tanto, marcar la figura `.corregir`.

**Derivados afectados:** figura; edición inglesa si la reutiliza.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-03.md`.

#### [TEC-02] El CAPE de 1.000–2.500 J/kg se presenta como «excelente» y «sin el riesgo de tormenta severa»

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad, coherencia
**Severidad:** alta
**Confianza:** moderada
**Verificación:** parcial (la clasificación del NWS está confirmada; la banda útil para el vuelo a vela requiere experto)
**Ubicación:** `cap03-termodinamica.qmd:142`, `:145`, `:151` y `:160`, dentro de `.mas-alla`

> Para el volovelista, ese rango es perfectamente excelente: proporciona térmicas potentes y bases altas sin el riesgo de tormenta severa.

**Problema:** el texto reconoce que la meteorología clasifica ese rango como «moderadamente inestable», pero lo convierte en ausencia de riesgo. Que haya o no tormenta depende del disparo, la humedad, la inhibición y la cizalladura; el CAPE por sí solo no la descarta. La «Regla de oro» del «día termonuclear» (`:151`) y la tabla resumen (`:160`) heredan el mismo rango, y `cap10:128` lo repite.

**Impacto:** enseña a leer un CAPE compatible con tormentas como garantía de día seguro, justo en el apartado que el alumno usará para decidir un vuelo de distancia.

**Evidencia:**
- NWS Louisville, «Stability indices», https://www.weather.gov/lmk/indices (consultado el 2026-11-21): «CAPE = 1000 to 2500: Moderately unstable»; «a range of CAPE of 1500-2500 J/kg gives a w-max range of about 50-70 m/s (100-140 kts)» en tormenta; la forma del área positiva, además del valor, decide el tipo de convección.
- NWS Houston, formación sobre Skew-T, https://www.weather.gov/source/zhu/ZHU_Training_Page/convective_parameters/skewt/skewtinfo.html: «1,500 to 2,500 (Large CAPE)».

**Propuesta:** sustituir la última frase por «puede dar térmicas potentes y bases altas, pero también tormentas si hay disparo y humedad: el CAPE por sí solo no descarta la tormenta». Pregunta para un meteorólogo o un FI(S) de travesía: qué banda de CAPE, combinada con TT, K y LI, es buen día en la Península sin entrar en riesgo de sobredesarrollo. Criterio de aceptación: la banda de «buen día» queda por debajo de los umbrales de tormenta de sus propias tablas (ver COH-02).

**Derivados afectados:** Anki `cap03.yml` (tarjeta del CAPE, «sin riesgo de tormenta severa», y tarjeta del día termonuclear); `cap10-informacion-meteorologica.qmd:128`; glosario «CAPE» (`glosario.qmd:33`, ver además TEC-26); `en/03-meteorology/cap03-thermodynamics.qmd:150`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-03.md`.

#### [TEC-03] Lluvia engelante: hielo equivocado y una salida («descender») que en la FZRA no existe

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado (la redacción operativa final, con un FI(S))
**Ubicación:** `cap05-precipitacion.qmd:34` y `:42`; `glosario.qmd:87`

> las gotas se congelan en décimas de segundo formando hielo opaco o escarcha

> gira 180° y desciende inmediatamente a niveles con temperatura positiva

> el único remedio es un cambio de rumbo 180° y descenso inmediato

**Problema:**
- **Tipo de hielo.** La FZRA está formada por gotas superenfriadas grandes, que producen hielo claro (*glaze*), no opaco ni escarcha. El propio libro asocia el hielo claro a las gotículas grandes (`cap09:42`).
- **Maniobra de salida.** El escenario que describe la línea 34 («la lluvia atraviesa una capa de aire bajo cero cerca del suelo») tiene el aire positivo **arriba** y el aire bajo cero hasta el suelo. «Descender a niveles con temperatura positiva» es imposible en ese escenario, y el glosario lo eleva a «único remedio».

**Impacto:** el alumno aprende a reconocer el hielo equivocado y memoriza una maniobra que, en la FZRA clásica, mete al planeador más hondo en la capa fría. Es un mensaje de seguridad.

**Evidencia:** FAA AC 00-6B (23-08-2016), consultada el 2026-11-21, comprobada en la consolidación:
- §14, fig. 14-4: «Freezing rain occurs when there is a deep layer aloft with above freezing temperatures and with a shallow layer of below freezing air at the surface».
- §18.3.7: «A favored location for severe clear icing is freezing rain and/or freezing drizzle below a front… Icing in freezing precipitation is especially dangerous because it often extends horizontally over a broad area and a pilot may be unable to escape it by descending to a lower altitude».
- FAA PHAK H-8083-25C (2023), cap. 12: los gránulos de hielo indican que hay lluvia engelante a mayor altitud.

**Propuesta:** línea 34: «…formando **hielo claro** (transparente), el más peligroso». Línea 42 y glosario: «sal de la zona de inmediato (giro de 180°) hacia aire sin precipitación: en la lluvia engelante el aire más cálido suele estar encima, y descender puede no sacarte de la capa bajo cero; si no puedes salir, aterriza». La redacción operativa, con un FI(S).

**Derivados afectados:**
- banco `meteorologia-c05-q07`: la respuesta correcta (D, «normalmente cambiando de altitud») es válida, pero el comentario del distractor C («la salida suele estar hacia abajo, en aire más cálido») es erróneo; se repite en `examenes/lecciones/03-meteorologia-leccion-05.md:307`;
- edición inglesa: `en/03-meteorology/cap05-precipitation.qmd:39` («opaque ice or rime») y `en/03-meteorology/glossary.qmd:86`;
- Anki `cap05.yml`, `lluvia-engelante` («cambiando de altitud»): correcta, comprobada sin cambio;
- `06-procedimientos-operativos/cap06-…:98` («desciende de inmediato a aire más cálido») trata el engelamiento en nube, no la FZRA: comprobado sin cambio.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-03.md`.

#### [TEC-04] La figura del frente frío dibuja la cuña fría en el lado prefrontal

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `03-meteorologia/imagenes/03-cap06-frente-frio-estructura.png`, citada en `cap06-masas-de-aire-y-frentes.qmd:21`

> Estructura vertical de un frente frío: cuña de aire frío y nubosidad convectiva asociada

**Problema:** la figura rotula «Zona Post-Frente» a la izquierda y «Pre-Frontal» a la derecha, pero:
- la «Masa de aire frío (polar/ártico, más densa…)» está a la **derecha** del eje superficial del frente, bajo la masa cálida, es decir, en el lado prefrontal; la zona postfrontal queda sin aire frío;
- los triángulos azules apuntan hacia la zona postfrontal, no hacia el aire cálido al que avanza el frente;
- la etiqueta «Terreno (más frío que el aire post-frontal inicialmente)» contradice el texto (`cap06:15`: la masa postfrontal es «netamente más fría que el terreno») y el mecanismo de la inestabilidad postfrontal que el capítulo enseña;
- en menor grado, «Viento SE» en el sector prefrontal, cuando el sector cálido trae viento S-SW.

**Impacto:** es la figura del fenómeno que el libro presenta como el mejor aliado del volovelista. Enseña al revés la geometría del frente y la causa de las térmicas postfrontales.

**Evidencia:**
- FAA AC 00-6B, §10.2: la superficie frontal «slopes over the colder (denser) air mass».
- FAA PHAK H-8083-25C, cap. 12: el aire frío avanza deslizándose bajo el cálido; una masa de aire que pasa sobre una superficie más cálida se calienta desde abajo y se vuelve inestable; tras el frente frío, el viento rola a W-NW.
- Comprobado sobre la imagen en la consolidación (2026-11-21).

**Propuesta:** rehacer la figura (las figuras las rehace Ramón): cuña fría detrás del frente, apoyada en el suelo del lado postfrontal; aire cálido delante, forzado a ascender; triángulos hacia el aire cálido; «Terreno más cálido que el aire postfrontal». Mientras tanto, marcarla `.corregir`.

**Derivados afectados:** figura; edición inglesa si reutiliza la imagen.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-03.md`.

#### [TEC-05] La figura SIGWX enseña a leer mal la carta: unidades, V5, nivel, frentes y simbología

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado (el símbolo rojo, parcial)
**Ubicación:** `03-meteorologia/imagenes/03-cap10-sigwx.png`, citada en `cap10-informacion-meteorologica.qmd:102`

> Ejemplo de mapa de tiempo significativo (SIGWX) para niveles bajos.

**Problema:** los rótulos explicativos que rodean el mapa contradicen la leyenda interna de la propia carta, el AIP y el capítulo:
- **Unidades verticales.** «Altitud de la base inferior y de la cima de las nubes (en hectopiescales)» y «Altitudes en hectopiescales (hPa). Ej.: 100 = FL100». La leyenda interna dice «Altitudes en hectopies»: son centenas de pies, no hPa.
- **V5.** «V5: visibilidad entre 5 y 8 km en superficie», frente a la leyenda interna («1000 m ≤ Visibilidad <5000 m») y el AIP.
- **Nivel.** «Válido para información de vuelo en ruta (planos altos)» describe una carta que va de la superficie a FL150.
- **Frentes.** «Línea azul: frente frío» señala un festón de nubosidad rotulado «BKN/OVC CU AC».
- **Octas.** «OVC: 8 octas o más».
- **Tormentas.** El rótulo «Probabilidad de tormentas (CB) y altitud de la base y cima (en hPa)» apunta a un símbolo rojo en forma de Ψ que parece de engelamiento; queda por cotejar con la simbología del Anexo 3.
- **Procedencia.** La imagen lleva los logotipos de AEMET y del Gobierno de España y el pie no dice si es un documento real o una recreación anotada, como pide `GUIA_ILUSTRACIONES.md`.

**Impacto:** el alumno aprende a leer bases y cimas en hPa, a tomar zonas nubosas por frentes y un rango de visibilidad falso. Son errores de interpretación examinables y operativos en el producto que más usará el piloto de planeador.

**Evidencia:** AIP España GEN 3.5 §3.6.2, «Mapas de tiempo significativo de niveles bajos (SWL)», AIRAC AMDT 10/26, WEF 29-OCT-26: «Límites verticales: desde superficie hasta FL150»; «V5: 1000 m < Visibilidad < 5000 m». https://aip.enaire.es/AIP/contenido_AIP/GEN/LE_GEN_3_5_es.pdf (consultado el 2026-11-21). Leyenda interna de la figura, comprobada sobre la imagen en la consolidación.

**Propuesta:** marcar la figura `.corregir` ya. Sustituirla por un mapa SWL real de AEMET con permiso y crédito, o por una recreación sin logotipos oficiales. Rótulos: «centenas de pies (FL)», «V5: 1.000–5.000 m», «festón: zona de nubosidad», «OVC: 8 octas». Pie: «Ejemplo (recreación) de mapa SWL de AEMET, de la superficie a FL150».

**Derivados afectados:** figura; edición inglesa si reutiliza la imagen. La tarjeta Anki `sigwx` no está afectada.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-03.md`.

### Media

#### [TEC-06] La figura ISA está mal trazada

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado (medido sobre la imagen ampliada)
**Ubicación:** `03-meteorologia/imagenes/03-cap01-atmosfera-isa.jpg`, citada en `cap01-la-atmosfera.qmd:12` y `:20`

> Temperaturas de la atmósfera estándar ISA

**Problema:** el punto «Nivel del mar: 15,0 °C» está dibujado sobre la marca de 10 °C; la recta corta el eje hacia 6–7 °C; el codo «Tropopausa: −56,5 °C» queda hacia −58 °C; la pendiente resultante es de unos 5,8 °C/km en lugar de 6,5; el eje dice «Altura (m)».

**Impacto:** es la única representación de la tropopausa en el capítulo, porque el texto no da 11 km, 36.090 ft ni −56,5 °C (ver SYL-01).

**Evidencia:** FAA AC 00-6B, tabla 1-2, «Selected Properties of the Standard Atmosphere»: 15 °C, 6,5 °C/1.000 m, tropopausa a 11.000 m / 36.089 ft y −56,5 °C. Cálculo: 15 − 6,5 × 11 = −56,5 °C.

**Propuesta:** retrazar el perfil (15 °C a 0 m, −56,5 °C a 11.000 m y vertical después) con eje «Altitud (m)».

**Derivados afectados:** figura; edición inglesa si la reutiliza.

#### [SYL-01] Epígrafe 3.1 parcial: faltan la estructura de la atmósfera y las altitudes de presión y de densidad

**Categoría:** syllabus
**Dimensiones afectadas:** syllabus, pedagogía
**Severidad:** media
**Confianza:** moderada
**Verificación:** confirmado en la ausencia; el alcance exacto requiere experto
**Ubicación:** `cap01-la-atmosfera.qmd`, en particular `:26`, `:37` y `:44`

**Problema:** el capítulo usa «troposfera» y «altitud de densidad» sin definirlas. No da la composición del aire (sólo el 21 % de O~2~), ni las capas, ni la tropopausa ISA en el texto, ni la altitud de presión. En toda la colección ningún capítulo define la altitud de presión ni la de densidad, y el cap01 no remite al libro 01 para la altimetría.

**Impacto:** el alumno llega al cap10 y a los libros 05 y 07 sin el concepto de altitud de densidad, que el propio cap01 invoca para explicar el rendimiento.

**Evidencia:** FAA AC 00-6B, cap. 1 (composición y tabla 1-2); FAA PHAK H-8083-25C, cap. 4: «Pressure Altitude…»; «Density altitude is pressure altitude corrected for nonstandard temperature».

**Propuesta:** un párrafo sobre composición y capas con la tropopausa ISA, y dos definiciones (altitud de presión referida a 1013,25 hPa; altitud de densidad), con remisión al libro 01 para el reglaje del altímetro.

**Derivados afectados:** glosario (sin entradas de altitud de presión ni de densidad); Anki (tarjetas nuevas); banco (preguntas nuevas desde el post-it).

#### [TEC-07] Föhn: «más de 10–15 °C» no sale con el mecanismo descrito, y el resumen lo convierte en «hasta 15 °C»

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** moderada
**Verificación:** parcial (el cálculo está confirmado; si otros mecanismos dan diferencias mayores, lo dirá un meteorólogo)
**Ubicación:** `cap02-viento.qmd:59` y `:100`

> Con desniveles de 1.500–2.000 m, la diferencia puede superar los 10–15 °C entre los dos valles.

**Problema:** con las cifras del propio libro (DALR 3 y SALR 1,5 °C/1.000 ft), la ganancia máxima es de 1,5 °C por cada 1.000 ft de ascenso saturado. Aun saturando desde el fondo del valle, 1.500 m dan 7,4 °C y 2.000 m, 9,8 °C. Con el DALR de 9,8 °C/km y un SALR realista de 4–5 °C/km salen 7–12 °C. El resumen (`:100`) dice «llegando hasta 15 °C más caliente», cuando el cuerpo dice «superar». La línea 59 dice además que el aire «cede calor latente a la atmósfera»: lo libera en la propia parcela.

**Evidencia:** FAA AC 00-6B, §11.2-11.3 (DALR 9,8 °C/km; SALR de 4 a 9,8 °C/km). Cálculo reproducible en «Comprobaciones cuantitativas».

**Propuesta:** un ejemplo numérico cerrado (valle a 15 °C, base a 500 m, cresta a 2.000 m: sotavento a unos 22 °C) y «del orden de 5–10 °C con este mecanismo». Si se quieren cifras mayores, citar la fuente y el mecanismo adicional.

**Derivados afectados:** glosario «Efecto Foehn» (`glosario.qmd:66`); Anki `cap02.yml` (tarjeta del Föhn, «hasta 15 ºC»); `examenes/lecciones/03-meteorologia-leccion-02.md:372`; `en/03-meteorology/cap02-wind.qmd:64` y `:105`. La figura `03-cap02-fohn-stau.jpg` (15 → 25 °C) sólo es compatible con unos 2.000 m saturados.

#### [TEC-08] La brisa marina se presenta sólo como ascendencia «suave y continua»

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap02-viento.qmd:79`

> puede ofrecer ascendencias suaves y continuas durante kilómetros, perfectas para el vuelo de distancia

**Problema:** omite la turbulencia de la zona de mezcla, que tras el paso del frente de brisa el aire marino puede acabar con las térmicas del día y que, con aire inestable, el frente puede organizar una línea de tormentas.

**Evidencia:** FAA, *Glider Flying Handbook*, H-8083-13B (2024), cap. 9, «Convergence Lift»: «passage of the front can end thermal soaring for the day»; «pilots should expect turbulence in any thermals associated with a sea breeze front»; puede ser «a focus for a line of thunderstorms».

**Propuesta:** añadir una frase con esas tres condiciones.

**Derivados afectados:** Anki `cap02.yml` (tarjeta de la brisa marina); resumen `cap02:101`; glosario «Brisa marina» y «Línea de convergencia».

#### [COH-01] Las figuras del *Glider Flying Handbook* del cap02 están mal enlazadas o sin explicar

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, pedagogía
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap02-viento.qmd:36-38`, `:44`, `:79` y `:86`

**Problema:**
- `fig-03-cap02-convergencia-topografica` (GFH fig. 9-27, convergencia a sotavento de una cresta) se cita para la convergencia de **brisa marina** (`:79`);
- `fig-03-cap02-vuelo-ladera` (GFH fig. 9-17, ascendencia dinámica de ladera) se cita para los **anabáticos** (`:44`);
- `fig-03-cap02-calles-nubes` (GFH fig. 9-12) se cita para la *curtain cloud* (`:86`);
- ningún párrafo explica las calles de nubes, la convergencia orográfica ni la ascendencia dinámica, y las dos primeras figuras flotan en la sección de fricción (`:36-38`).

**Impacto:** el alumno asocia la térmica de solana con la ascendencia dinámica de ladera, y la brisa marina con la orografía.

**Evidencia:** GFH H-8083-13B, cap. 9 («Cloud Streets»; «Convergence Lift», figs. 9-26 y 9-27; «Ridge/Slope Soaring», fig. 9-17).

**Propuesta:** dos o tres frases por figura basadas en el GFH, o retirarlas; la brisa marina remite a `fig-03-cap02-brisa-marina`; la ascendencia de ladera, al libro 06 (`cap03-tecnicas-de-planeo.qmd`, «Vuelo de ladera»).

#### [PED-01] Figura de isobaras: el viento dibujado de la alta a la baja y rótulos incoherentes

**Categoría:** pedagógica
**Dimensiones afectadas:** pedagogía, técnica
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `03-meteorologia/imagenes/03-cap02-gradiente-isobaras.jpg`, citada en `cap02-viento.qmd:12-14`

**Problema:** sobre un mapa de la Península, las flechas «Dirección del viento» van rectas del anticiclón a la borrasca, cruzando las isobaras, con el rótulo «El viento sopla desde el anticiclón hacia la borrasca»; el capítulo explica dos párrafos después que eso no ocurre. Alrededor de la L los rótulos van 1000, 1004, 1006, 1006, 1000, 1012; hay más de diez isobaras sin rotular entre 1016 y 1012; la flecha del recuadro «Isobaras separadas» apunta a la zona de isobaras juntas.

**Evidencia:** FAA AC 00-6B, §7.4-7.5: el viento se desvía hasta ser paralelo a las isobaras en altura y en superficie las cruza unos 10–45°.

**Propuesta:** flechas casi paralelas a las isobaras con un ligero cruce hacia la baja, o rotularlas «fuerza del gradiente de presión (no es la dirección del viento)»; isobaras cada 4 hPa, monótonas.

#### [TEC-09] La fórmula de la base de los cúmulos perdió los paréntesis en la rc.18 (regresión)

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap03-termodinamica.qmd:29`

> **$T_{ambiente} - T_{rocío}$ × 400 = Altitud de la base en pies.**

**Problema:** antes de la rc.18 decía `(T~ambiente~ - T~rocío~) x 400` (`git log -p`, commit `457008f`). La entrada de la rc.18 dice «Los valores no cambian», pero al quitar los paréntesis la expresión se lee T − 400·T~rocío~. En `index.typ` el subíndice se compone como letras sueltas en cursiva.

**Impacto:** es la fórmula central del capítulo. Los pasos 1 a 3 y el ejemplo (`:32-38`) la escriben bien, así que el daño queda acotado.

**Evidencia:** precedencia aritmética; `git log -p 03-meteorologia/cap03-termodinamica.qmd`; `03-meteorologia/index.typ`.

**Propuesta:** `$(T - T_\text{rocío}) \times 400$ = altura de la base en ft AGL` (ver TEC-10).

**Derivados afectados:** ninguno; Anki, glosario y `en/` sí llevan paréntesis.

#### [TEC-10] La fórmula da la «altitud» de la base, cuando da la altura sobre el aeródromo

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap03-termodinamica.qmd:29`; `glosario.qmd:45`

> × 400 = altitud en pies

**Problema:** el método da la altura sobre la estación. En la terminología aeronáutica española, «altitud» se refiere al nivel del mar. El propio capítulo usa «altura» en `:36` y el glosario dice «altura» en las entradas LCL y NCA (`:111`, `:138`). En un aeródromo a unos 3.300 ft, como Fuentemilanos, leerla como altitud sitúa la base unos 3.300 ft por debajo de la real.

**Impacto:** el alumno puede comparar la base calculada con el altímetro en QNH o con los límites del espacio aéreo.

**Evidencia:** FAA PHAK H-8083-25C, cap. 12: «height of cloud base AGL». `cap10:58` mide las nubes del METAR sobre el aeródromo. La edición inglesa ya dice «cloud base height».

**Propuesta:** «altura de la base sobre el aeródromo (ft AGL); para la altitud, suma la elevación del campo».

**Derivados afectados:** Anki `cap03.yml`, `altura-de-la-base-de-los-cumulos` («altitud de la base, en pies»); figura `03-cap03-base-cumulos-dalr-nca.jpg` (eje y recuadro, ver TEC-01).

#### [TEC-11] La estabilidad absoluta y la condicional están mal definidas

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía, syllabus
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap03-termodinamica.qmd:15-17`

> **Estabilidad Condicional**: Depende de la humedad. Si el aire está seco, es estable; pero si está saturado de humedad, el calor liberado por la condensación (al formar nubes) hace que la burbuja se mantenga caliente y siga subiendo (inestable).

**Problema:** la línea 15 llama «estable» a todo gradiente ambiental menor de 1 °C/100 m; la 17 da la condicional sin su condición (gradiente entre el SALR y el DALR); la estabilidad absoluta (gradiente menor que el SALR, incluidas inversión e isoterma) no existe en el texto.

**Impacto:** el alumno no puede clasificar un sondeo y deduce que todo aire saturado es inestable.

**Evidencia:** FAA AC 00-6B, §12.3.1 y §12.3.4: estabilidad absoluta, «lapse rate of temperature is less than the moist adiabatic lapse rate»; inestabilidad condicional, «less than the dry adiabatic lapse rate, but greater than the moist adiabatic lapse rate».

**Propuesta:** tres viñetas: absolutamente estable (menor que el SALR), condicionalmente inestable (entre SALR y DALR), absolutamente inestable (mayor que el DALR).

**Derivados afectados:** Anki `cap03.yml` (tarjeta de estabilidad); glosario «Estabilidad condicional» (`:75`, correcto en lo esencial).

#### [TEC-12] Las fórmulas del TT y del K se perdieron al importar: «Su fórmula:» no va seguido de nada

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap03-termodinamica.qmd:94-96` y `:122`

> El índice Total Totals (TT) combina el gradiente vertical de temperatura con la humedad en capas bajas. Su fórmula:

**Problema:** tras «Su fórmula:» viene un recuadro de buenas prácticas. En el origen AsciiDoc (`aesa-spl-oficial/libros/03-meteorologia/capitulos/cap03-termodinamica.adoc:142-149` y `:199-201`) las dos fórmulas estaban en bloques `----`, que la conversión a Quarto descartó. El informe de julio las dio por correctas porque leyó el PDF v1.0.2, anterior a la conversión.

**Evidencia:** Air Weather Service, *The Use of the Skew T, Log P Diagram in Analysis and Forecasting*, AWS/TR-79/006 (rev. marzo de 1990), §5.24.12: «TT = VT plus CT = (850-mb temp plus 850-mb dew point) minus 2(500-mb temp)»; §5.24.9 (K). https://www.inscc.utah.edu/~krueger/5300/AF_SkewT_manual.pdf (copia de DTIC ADA221842; consultado el 2026-11-21). NWS Louisville da las mismas fórmulas.

**Propuesta:** restituir `TT = (T₈₅₀ + Td₈₅₀) − 2·T₅₀₀` y `K = (T₈₅₀ − T₅₀₀) + Td₈₅₀ − (T₇₀₀ − Td₇₀₀)` en notación matemática.

**Derivados afectados:** `en/03-meteorology/cap03-thermodynamics.qmd:99` (mismo hueco); glosario «K-Index» (`:108`, ver TEC-42).

#### [TEC-13] La escala del TT que se atribuye a Miller (1972) es la del oeste de EE. UU. (H5a)

**Categoría:** técnica
**Dimensiones afectadas:** técnica, trazabilidad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap03-termodinamica.qmd:102-114`

> Los umbrales clásicos de tormenta del TT proceden del trabajo de Robert C. Miller

**Problema:** los escalones de la tabla (48, 52, 55, 58, 61, 64) reproducen la escala «West of the Rockies» que la AWS/TR-79/006 atribuye a *NWS Western Region Technical Attachment No. 84-14* (1984). La escala de Miller (AWS-TR-200, 1972) es la «East of the Rockies», con tormentas desde TT 44. La fila «> 52: tormentas aisladas» está además mal transcrita: en la escala del oeste, 48 es «isolated or few thunderstorms» y 52, «scattered thunderstorms». El libro llama al TT «el índice del llano» y usa la escala de un oeste montañoso y árido.

**Evidencia:** AWS/TR-79/006, tablas resumen pp. 5-42 y 5-43 y referencias de la p. 5-44; §5.24.12: «threshold convection values for TT vary considerably across the United States».

**Propuesta:** atribuir la tabla a la escala del oeste de EE. UU. (NWS Western Region, 1984, recogida en AWS/TR-79/006) y corregir la fila de 52, o citar a Miller con su escala de 44 a 56. En ambos casos, añadir que los umbrales son regionales y que no hay calibración publicada para la Península.

**Derivados afectados:** `en/03-meteorology/cap03-thermodynamics.qmd:119`; bibliografía (COH-07). La tarjeta Anki de limitaciones del TT no da cifras.

#### [TEC-14] «El K es más representativo en montaña» contradice a la fuente y al propio capítulo

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado en la contradicción con la fuente; la heurística de campo requiere experto
**Ubicación:** `cap03-termodinamica.qmd:90`, `:120-122` y `:137`

> **el TT (Total Totals) es especialmente fiable en el llano, mientras que el K es más representativo en montaña**

**Problema:** la línea 137 reconoce que el K «pierde representatividad» cuando el nivel de 850 hPa queda cerca del suelo, que es justo lo que pasa en montaña, y el TT usa el mismo nivel.

**Evidencia:** AWS/TR-79/006, §5.24.9: «This index cannot be reliably computed for mountain stations»; tabla resumen del K: «K value may not be representative of airmass if 850-mb level is near surface».

**Propuesta:** retirar la regla llano/montaña o presentarla como criterio de instructor con su límite (el nivel de 850 hPa bajo o junto al suelo afecta a los dos índices). Validación de un meteorólogo.

**Derivados afectados:** Anki `cap03.yml` (dos tarjetas: «el K, para la montaña»); glosario «K-Index»; recuadros de `:97` y `:159`; `en/03-meteorology/cap03-thermodynamics.qmd:95`.

#### [COH-02] Las bandas de los índices se contradicen entre las tablas, la tabla resumen y el «día termonuclear» (H6)

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, técnica
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado (comparación interna)
**Ubicación:** `cap03-termodinamica.qmd:105-107`, `:128-131`, `:151`, `:154`, `:158-160`

> Las tablas de umbrales de los apartados anteriores tienen ocho tramos cada una

**Problema:**
- **TT:** la tabla completa da «> 48: desarrollo de Cb probable» y «> 52: tormenta muy probable»; la tabla resumen da como buen día 44–52; el «día termonuclear» pide TT 48–55.
- **K:** la tabla da «20–30: riesgo creciente de chubascos y tormentas»; la tabla resumen da como buen día 15–25, que en la escala de George que el libro cita (`:134`) es un 20–40 % de tormentas.
- **Tramos:** la tabla del K tiene seis, no ocho.
- **H6:** el rótulo «nivel examen» se retiró (corregido), pero la incoherencia de fondo persiste.

**Evidencia:** AWS/TR-79/006, tabla del K, p. 5-38 («15 to 20: 20%», «21 to 25: 20-40%»); escalas del TT, pp. 5-42 y 5-43; NWS Louisville, TT «45 to 50: Thunderstorms possible».

**Propuesta:** una sola banda de buen día por índice, por debajo de los umbrales de tormenta de su propia tabla; corregir «ocho tramos». La banda, validada por un meteorólogo o FI(S) (junto con TEC-02).

**Derivados afectados:** Anki `cap03.yml` (dos tarjetas de bandas); `cap10:123` y `:128`; glosario «K-Index» y «CAPE»; `en/`.

#### [TEC-15] El signo del Lifted Index está invertido

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap03-termodinamica.qmd:148`

> Diferencia entre la temperatura de la parcela y la del ambiente a 500 hPa, tras elevarla adiabáticamente desde el suelo. Valores negativos indican inestabilidad

**Problema:** con «parcela − ambiente», un valor negativo es una parcela más fría, es decir, estabilidad. La frase se contradice a sí misma y contradice al glosario (`glosario.qmd:117`), que lo define bien.

**Evidencia:** AWS/TR-79/006, §5.24.2: «The algebraic difference between the environment temperature and the updraft temperature (observed minus computed) at 500 mb»; NWS Louisville: «LI = T(500 mb envir) − T(500 mb parcel)».

**Propuesta:** «Diferencia entre la temperatura del ambiente y la de la parcela a 500 hPa».

**Derivados afectados:** `en/03-meteorology/cap03-thermodynamics.qmd:153`.

#### [TEC-16] La clasificación de nubes se atribuye a la OMM con cuatro familias y alturas que no coinciden; el Ns cambia de piso

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap04-nubes-y-niebla.qmd:14-30`; figuras `03-cap04-familias-nubes-perfil.png` y `03-cap06-frente-ocluido.png`

> La OMM clasifica la nubosidad en **diez géneros**, repartidos en esas cuatro familias por la altura de su base:

**Problema:**
- la OMM usa **tres pisos**; la familia de desarrollo vertical es una convención de la FAA (Cu y Cb tienen la base en el piso bajo);
- tres pares de alturas: texto, altas > 6.000 m y medias 2.000–6.000 m; figura, > 5.000 m y 2.000–5.000 m, con la raya de 20.000 ft rotulada 16.000 ft y el «0 ft» por encima del panel de desarrollo vertical; OMM, en latitudes templadas, altos 5–13 km y medios 2–7 km, con pisos solapados;
- el texto pone el nimboestrato en las medias, como la OMM; las dos figuras lo ponen en las bajas.

**Evidencia:** OMM, *Atlas Internacional de Nubes* (2017, en línea), §2.2.1.2, tabla 6, y ficha del nimbostratus («almost always found in the middle level»). https://cloudatlas.wmo.int/en/useful-concepts.html (consultado el 2026-11-21). FAA PHAK, cap. 12 (altas por encima de 20.000 ft).

**Propuesta:** «Según la OMM, los diez géneros se reparten en tres pisos (en latitudes medias, aproximadamente: altos 5–13 km, medios 2–7 km, bajos hasta 2 km). Cu y Cb tienen la base en el piso bajo, aunque crecen hasta los otros; aquí se agrupan aparte como desarrollo vertical.» En las figuras, Ns en las medias y alturas coherentes con el texto. Va con PED-08 (tabla anunciada que no existe).

**Derivados afectados:** dos figuras; `en/03-meteorology/cap04-clouds-and-fog.qmd:19`.

#### [COH-03] Neblina o bruma (BR): tres umbrales y dos nombres

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, técnica
**Severidad:** media
**Confianza:** moderada
**Verificación:** confirmado (umbral con material de formación de AEMET; el Anexo 3 no fue accesible)
**Ubicación:** `cap04-nubes-y-niebla.qmd:53`; `glosario.qmd:141`; `cap10-informacion-meteorologica.qmd:25`

> **Neblina y bruma:** Reducen la visibilidad horizontal a valores entre 1.000 m y 3.000 m.

**Problema:** el cap04 da 1.000–3.000 m; el glosario, 1.000–5.000 m («bruma (**mist**)»); el cap10 llama a BR «Neblina». La OMM sólo fija el límite inferior (la neblina no baja la visibilidad de 1 km); el tope de 5.000 m es el de la cifra BR en el METAR.

**Evidencia:**
- OMM, *Atlas Internacional de Nubes*, §3.2.1.1.1, «Fog compared with Mist». https://cloudatlas.wmo.int/en/fog-compared-with-mist.html
- AEMET, curso PIB-M 2022, «03 METAR-SPECI», p. 21: «BR, se comprobará que 1000 m < VVVV [≤] 5000 m». https://etrp.wmo.int/pluginfile.php/56265/mod_resource/content/1/03-METAR-SPECI.pdf (consultado el 2026-11-21).
- Reglamento 2017/373 en español, MET.TR.205 d): «calima, bruma, niebla» como términos; no da umbrales.

**Propuesta:** fijar un término con su equivalencia («neblina o bruma, BR») y el umbral de 1.000–5.000 m en el cap04 y el glosario; distinguirla de la calima (HZ).

**Derivados afectados:** Anki `cap10.yml`, `codigos-fg-br-cavok`; `en/03-meteorology/cap04-clouds-and-fog.qmd:58`. Banco `c04-q05` y `c10-q04`: umbral de 1 km correcto, sin cambio.

#### [TEC-17] Niebla de advección: el texto la sitúa en invierno y otoño; el Atlas Nacional, en verano

**Categoría:** técnica
**Dimensiones afectadas:** técnica
**Severidad:** media
**Confianza:** moderada
**Verificación:** parcial
**Ubicación:** `cap04-nubes-y-niebla.qmd:58`

> Es característica del litoral galaico-cantábrico en invierno y de las costas mediterráneas en otoño con viento de levante.

**Problema:** el IGN da las nieblas de advección costeras como más frecuentes en verano. No se ha encontrado fuente para «invierno» ni para «otoño con levante». El mismo texto del IGN sí respalda las nieblas de radiación de Duero, Ebro y Tajo en invierno (`cap04:56`, `cap07:22`).

**Evidencia:** IGN, *Atlas Nacional de España*, cap. 4 «Clima» (ed. 2020, PDF de 03-11-2023), «Número medio anual de días de niebla». https://www.ign.es/web/resources/docs/IGNCnig/ANE/Capitulos/04_1_Clima_2020_20231103.pdf (consultado el 2026-11-21).

**Propuesta:** «Es típica de los sectores costeros, sobre todo en verano», o que la valide un meteorólogo de AEMET.

#### [TEC-18] «Downburst» y «microrráfaga» como sinónimos, y el microburst ligado sólo a Cb con lluvia intensa

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap05-precipitacion.qmd:48` y `:52`; `cap09-peligros-para-el-vuelo.qmd:77`; `glosario.qmd:62`

> formando una violenta corriente descendente —el **downburst** o **microrráfaga**

**Problema:** la microrráfaga es un *downburst* pequeño (menos de unos 4 km); *downdraft* (`cap05:52`) es cualquier corriente descendente. El cap09 traduce *downburst* como «reventón», con lo que el libro usa dos traducciones, y lo liga sólo a «cumulonimbos desarrollados que descargan lluvia intensa», cuando también se produce bajo cúmulos con virga, como explica el propio cap05.

**Evidencia:** GFH H-8083-13B, glosario: «Microburst. A small-sized downburst of 2.2 nautical mile or less horizontal dimension»; FAA AC 00-6B, §19.6.3: «Smaller, shorter-lived downbursts are called microbursts»; FAA AIM 7-1-24: microbursts en celdas débiles «that have little or no precipitation reaching the ground… light rain in benign appearing virga».

**Propuesta:** «…una violenta corriente descendente, el **reventón** (**downburst**); si afecta a menos de unos 4 km se llama **microrráfaga** (**microburst**)». En `cap09:77`, «…o bajo cúmulos con virga (cap05)».

**Derivados afectados:** glosario «Downburst (microburst / microrráfaga)» (`:62-63`, `:200-201`); `examenes/oficial/03-meteorologia-examen-50.md:901` (cita «downburst» y en otra pregunta «reventón»).

#### [SYL-02] Epígrafe 3.5 parcial: no se explica cómo se forma la precipitación ni qué tipos hay

**Categoría:** syllabus
**Dimensiones afectadas:** syllabus, pedagogía
**Severidad:** media
**Confianza:** moderada
**Verificación:** no aplicable
**Ubicación:** `cap05-precipitacion.qmd`

**Problema:** el capítulo trata la precipitación sólo por su efecto en el planeador (lluvia, granizo, FZRA, virga). Faltan el crecimiento de las gotas (Bergeron, coalescencia), los tipos (llovizna, lluvia, nieve, granizo, gránulos de hielo) y la diferencia entre chubasco (nube convectiva) y precipitación continua (nube estratiforme). «Bergeron», «coalescencia» y «llovizna» sólo aparecen en `cap06:31`.

**Evidencia:** FAA PHAK H-8083-25C, cap. 12, «Precipitation»; FAA AC 00-6B, cap. 14.

**Propuesta:** una sección breve, «Cómo se forma la precipitación y qué tipos hay», que enlace el tipo de nube con el de precipitación y prepare la FZRA (TEC-03).

**Derivados afectados:** Anki y banco (contenido nuevo desde el post-it).

#### [PED-02] Cifras de seguridad sin fuente, presentadas como regla y convertidas en tarjetas

**Categoría:** pedagógica
**Dimensiones afectadas:** pedagogía, técnica
**Severidad:** media
**Confianza:** moderada
**Verificación:** requiere experto
**Ubicación:** `cap04-nubes-y-niebla.qmd:46`; `cap05-precipitacion.qmd:19`; `cap06-masas-de-aire-y-frentes.qmd:70`; `cap07-sistemas-de-presion.qmd:37`; `cap08-climatologia.qmd:39`

**Problema:** ninguna de estas cifras tiene fuente ni dos fuentes independientes, y el post-it y Anki las convierten en datos que memorizar:
- «añade siempre un margen mínimo de 5-10 kt» con lluvia (`cap05:19`); el libro 06 da «5-10 %» de la velocidad de pérdida para agua en las alas (`06/cap06:103`): no se contradicen, pero son heurísticas distintas;
- separación lateral de un Cb «entre 10 y 20 millas náuticas» (`cap04:46`); la FAA aconseja al menos 20 NM de una tormenta severa;
- «Cancela… si… una depresión activa a menos de 500 km» (`cap07:37`);
- «Nunca sobrevueles una ladera de sotavento a menos de 300 ft» (`cap08:39`), que sugiere que 300 ft sobre un sotavento con rotor es aceptable;
- «bases a 5.000-7.000 ft y térmicas de 3-4 m/s» tras un frente frío (`cap06:70`).

**Evidencia:** FAA AC 00-24C, *Thunderstorms* (19-02-2013), §10 a)(14): «avoid by at least 20 miles any thunderstorm identified as severe». https://www.faa.gov/documentLibrary/media/Advisory_Circular/AC%2000-24C.pdf (consultado el 2026-11-21). El resto, sin fuente localizada.

**Propuesta:** marcarlas como orientativas; remitir al AFM para el margen con lluvia; alinear la del Cb con la FAA; retirar las de 500 km y 300 ft o que un FI(S) las valide.

**Derivados afectados:** Anki `separacion-de-un-cb`, `lluvia-y-rendimiento`, `borrasca-a-menos-de-500-km`, `separacion-de-laderas-de-sotavento`.

#### [TEC-19] El frente cálido «estabiliza completamente la masa de aire»

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap06-masas-de-aire-y-frentes.qmd:34` (también `:80` y la figura `03-cap06-frente-calido-nubes.png`, «AIRE TOTALMENTE ESTABLE»)

> A nivel termodinámico, estabiliza completamente la masa de aire suprimiendo físicamente el desarrollo de corrientes convectivas o térmicas aprovechables.

**Problema:** si el aire cálido que asciende es inestable, el frente cálido puede llevar cumulonimbos embebidos en la capa. «Completamente» enseña que no puede haber tormentas en un frente cálido.

**Evidencia:** FAA PHAK, cap. 12: antes de un frente cálido, en verano, es probable que se formen cumulonimbos; FAA AC 00-6B, §10.2: la nubosidad es estratiforme «if the warm rising air is stable».

**Propuesta:** «…normalmente estabiliza las capas bajas y suprime las térmicas; si el aire cálido es inestable, puede esconder cumulonimbos embebidos».

**Derivados afectados:** Anki `cap06.yml`, `frente-calido`; figura del frente cálido.

#### [TEC-20] Frente estacionario definido por masas «de temperatura y densidad similar»

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap06-masas-de-aire-y-frentes.qmd:46`

> Se forma cuando dos masas de aire de temperatura y densidad similar se encuentran y ninguna de las dos tiene fuerza suficiente para avanzar sobre la otra.

**Problema:** si las masas fueran similares, no habría frente. El estacionario separa masas distintas y está quieto porque ninguna desplaza a la otra; la frase contradice la definición de frente con que se abre el capítulo.

**Evidencia:** FAA PHAK, cap. 12: «When the forces of two air masses are relatively equal…»; FAA AC 00-6B, §10.2.

**Propuesta:** «Se forma cuando dos masas de aire **distintas** se encuentran y ninguna tiene fuerza suficiente para desplazar a la otra».

**Derivados afectados:** `en/03-meteorology/cap06-air-masses-and-fronts.qmd:51`.

#### [TEC-21] «La situación más frecuente en primavera-verano» es la masa polar marítima tras un frente frío

**Categoría:** técnica
**Dimensiones afectadas:** técnica
**Severidad:** media
**Confianza:** moderada
**Verificación:** parcial
**Ubicación:** `cap06-masas-de-aire-y-frentes.qmd:70`

> La situación más frecuente en la Península Ibérica durante la temporada de vuelo (primavera-verano) es la llegada de **masa polar marítima (Pm)** tras el paso de un frente frío.

**Problema:** el IGN describe el verano peninsular dominado por los anticiclones subtropicales y la baja térmica estival. La afirmación es defendible para la primavera, no para el verano.

**Evidencia:** IGN, *Atlas Nacional de España*, cap. 4 «Clima» (introducción y «Baja térmica estival»).

**Propuesta:** limitarla a la primavera, o que la valide un meteorólogo.

#### [TEC-22] Baja Térmica Peninsular «permanente» y «en el centro de España»

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** moderada
**Verificación:** parcial
**Ubicación:** `cap08-climatologia.qmd:65` y `:81`

> estableciendo una permanente **baja térmica peninsular** en el centro de España

**Problema:** el IGN la describe como una situación «típicamente estival», con núcleos de origen térmico que no son permanentes. El banco ya dice «casi permanente» (`c08-q07`), mejor que el libro.

**Evidencia:** IGN, *Atlas Nacional de España*, cap. 4, «Baja térmica estival».

**Propuesta:** «…una **baja térmica** casi permanente en verano sobre el interior peninsular, más marcada por la tarde».

**Derivados afectados:** Anki `cap08.yml`, `baja-termica-peninsular`, y su espejo inglés.

#### [COH-04] La figura del ciclo de la tormenta contradice el texto: cuatro fases y precipitación en la de desarrollo

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, técnica
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap09-peligros-para-el-vuelo.qmd:25-31`; figura `03-cap09-ciclo-tormenta.png`

> Todavía no hay precipitación que llegue al suelo

**Problema:** la figura rotula cuatro fases («cúmulo», «desarrollo», «madurez», «disipación») frente a las tres del texto y del pie, y en la «fase de desarrollo» dibuja una corriente descendente hasta el suelo con «posibles precipitaciones moderadas». Es una regresión parcial de H4: el texto se corrigió y la figura lo contradice.

**Evidencia:** FAA AC 00-6B, §19.3: «three distinct stages… The cell transitions to the mature stage when precipitation reaches the surface». La escala de unos 30 min de la figura es correcta.

**Propuesta:** «Fase de cúmulo (desarrollo)» para las tres primeras nubes, sin descendente ni precipitación en superficie; o marcarla `.corregir`. La tarjeta Anki `ciclo-de-la-tormenta` está bien.

#### [TEC-23] Falta el aviso de granizo bajo el yunque y lejos del núcleo; el umbral de 2 cm resta peligro al granizo menor

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap09-peligros-para-el-vuelo.qmd:14` y `:84`

> El impacto de granizo severo (diámetros > 2 cm) destruye el perfil laminar

**Problema:** el capítulo prohíbe volar bajo un Cb, pero no dice que el granizo puede caer bajo el yunque y en aire claro a varias millas del núcleo. El glosario y el banco (`c09-q01`, «granizo expulsado bajo el yunque») sí lo dicen, sin que el capítulo, que es su fuente, lo sostenga.

**Evidencia:** FAA AC 00-24C (19-02-2013), §7: «Hail may be encountered in clear air several miles from the thunderstorm… especially beneath the anvil»; «Hailstones larger than one-half inch in diameter can significantly damage an aircraft»; §10 a)(3): «Don't attempt to fly under the anvil».

**Propuesta:** en «Fenómenos asociados»: «El granizo puede caer bajo el yunque y en aire despejado a varias millas del núcleo: no vueles bajo el yunque. Incluso piedras de algo más de 1 cm dañan la estructura».

#### [COH-05] La figura de la estela se atribuye a un «Estudio de la NASA» que no parece ser

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, trazabilidad
**Severidad:** media
**Confianza:** moderada
**Verificación:** parcial
**Ubicación:** `cap09-peligros-para-el-vuelo.qmd:66`; figura `03-cap09-estela-turbulenta.jpg`

> Estudio de la NASA sobre los vórtices de las puntas de las alas, ilustra cualitativamente la turbulencia de estela.

**Problema:** la imagen muestra un biplano y dos anillos de humo naranja sobre una pista de hierba con manga, con aspecto de recreación. La foto de la NASA (L90-5919, Wallops, 1990) muestra un avión agrícola y un vórtice de humo rojo en el extremo del ala.

**Evidencia:** DVIDS, «Wake Vortex Study at Wallops Island», NASA L90-5919. https://www.dvidshub.net/image/691683/wake-vortex-study-wallops-island (consultado el 2026-11-21). `GUIA_ILUSTRACIONES.md`, material de terceros.

**Propuesta:** aclarar la procedencia: si es recreación, retirar «NASA» del pie y decirlo; si se quiere la de la NASA, usar el original con su crédito.

#### [TEC-24] SPECI: no se emite sólo «porque algo ha empeorado», y en España no se emite por cambios de viento

**Categoría:** técnica
**Dimensiones afectadas:** técnica, normativa
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap10-informacion-meteorologica.qmd:13`; `glosario.qmd:173-174`

> el viento vira o arrecia, la visibilidad o la base de las nubes cruzan un umbral operativo, aparece una tormenta

**Problema:** también hay SPECI de mejoría; el criterio de viento sólo se aplica «si así lo acuerdan» el proveedor y la autoridad, y la lista española no lo incluye (salvo un criterio local); y un SPECI no es necesariamente posterior al último METAR: el informe vigente es el de hora más reciente. En España no se emite SPECI AUTO.

**Impacto:** el piloto espera un SPECI ante un role de viento y no lo recibirá; aprende «SPECI = empeoramiento» en vez de leer el grupo de hora.

**Evidencia:** Reglamento de Ejecución (UE) 2017/373, consolidado a 04-10-2026, MET.TR.200 f): «…si así lo acuerdan el proveedor de servicios meteorológicos y la autoridad competente: 1) cuando el viento cambie…». AIP España GEN 3.5 §3.2.3, nota 3: «Deberá emitirse un SPECI relativo a una mejoría de las condiciones únicamente si dicha mejoría ha persistido 10 minutos»; §3.2.2.1: «SPECI AUTO: No se emiten». Comprobado en la consolidación.

**Propuesta:** «…cuando las condiciones cambian de forma significativa, a mejor o a peor (visibilidad, base o cantidad de nubes, tormenta, precipitación…). Mira siempre la hora: el informe vigente es el más reciente».

**Derivados afectados:** glosario «SPECI»; Anki `cap10.yml`, `speci`.

#### [TEC-25] `SKC` no existe en el METAR europeo: el observador humano escribe NSC o CAVOK

**Categoría:** técnica
**Dimensiones afectadas:** técnica, normativa, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap10-informacion-meteorologica.qmd:24`; `glosario.qmd:150`

> `SKC` lo escribe un **observador humano** que ve el cielo despejado.

**Problema:** la plantilla europea del METAR no contiene SKC; un observador europeo cifra NSC (o CAVOK). SKC es práctica de EE. UU.

**Evidencia:** 2017/373, anexo V, apéndice 1 (modelo de METAR), fila 10: «FEWnnn… VVnnn o VV/// o NSC o NCD (4)», con la nota «(4) Solamente para informes automáticos». AIP GEN 3.5 §3.2.2.1: NCD sólo en mensajes automáticos.

**Propuesta:** «`NCD`: estación automática que no detecta nubes. Con cielo despejado, el observador escribe `NSC` (o `CAVOK` si se cumple todo). `SKC` sólo aparece en informes de EE. UU.»

**Derivados afectados:** `en/03-meteorology/cap10-meteorological-information.qmd:29`; `en/03-meteorology/glossary.qmd:134`; `recursos-completo/glosario.qmd` (copia generada, no canónica).

#### [NOR-01] En España, AIRMET, GAMET y el mapa SWL cubren hasta FL150 en toda la FIR, no FL100

**Categoría:** normativa
**Dimensiones afectadas:** normativa, técnica, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap10-informacion-meteorologica.qmd:97` y `:152`; `glosario.qmd:6` y `:90`

> fenómenos de menor severidad que los del SIGMET, **por debajo del FL100** (FL150 en zonas montañosas)

**Problema:** el libro da la regla genérica de la UE sin su cola («o más, en caso necesario») ni su aplicación española: AEMET emite AIRMET, GAMET y SWL hasta FL150 en toda la FIR. La entrada GAMET del glosario dice «por debajo del FL100», incompleta incluso para la UE.

**Impacto:** un piloto de onda a FL120 sobre la meseta creerá que el AIRMET no le concierne.

**Evidencia:** 2017/373, consolidado a 04-10-2026, MET.OR.255 a): «…por debajo del nivel de vuelo 100, o hasta el nivel de vuelo 150 en zonas montañosas, o más, en caso necesario». AIP España GEN 3.5 §3.6.1 (GAMET: «Pronóstico de área para vuelos por debajo de FL150»), §3.6.2 (SWL: «desde superficie hasta FL150») y §8.2 (AIRMET, «por debajo del FL150»). Comprobado en la consolidación.

**Propuesta:** añadir «(en España, AIRMET, GAMET y el mapa SWL de AEMET cubren hasta FL150 en toda la FIR)»; GAMET en el glosario: «hasta FL150 en España».

**Derivados afectados:** Anki `cap10.yml`, `sigmet-airmet-nivel`, y su espejo inglés; `en/03-meteorology/cap10-meteorological-information.qmd:102` y `:157`; `en/03-meteorology/glossary.qmd:17` y `:89`; `recursos-completo/glosario.qmd` (no canónico).

#### [NOR-02] «Obligatorio» y «legalmente vinculante» usados sin precisión

**Categoría:** normativa
**Dimensiones afectadas:** normativa
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap10-informacion-meteorologica.qmd:100`, `:135` y `:141`

> cruza varias fuentes: es obligatorio y prudente

> es siempre la fuente pública, oficial y legalmente vinculante

**Problema:** la obligación es estudiar los informes y pronósticos disponibles y no iniciar o continuar el vuelo si la información no garantiza una opción de aterrizaje segura; «cruzar varias fuentes» es prudencia, no obligación. La información meteorológica no es «vinculante»: AEMET es la autoridad meteorológica aeronáutica y el proveedor designado.

**Evidencia:** SERA.2010 b) (Easy Access Rules for SERA, 08-2025): «Pre-flight action for flights away from the vicinity of an aerodrome… shall include a careful study of available current weather reports and forecasts». Part-SAO, SAO.OP.120 b) y SAO.OP.135 (Easy Access Rules for Sailplanes, 11-2022). AIP GEN 3.5 §1: AEMET, «autoridad meteorológica aeronáutica y proveedor de servicio».

**Propuesta:** `:135`: «estudiar los informes y pronósticos disponibles es obligatorio (SERA.2010 b); cruzar fuentes es prudente»; `:141`: «fuente oficial: AEMET es el proveedor designado».

**Derivados afectados:** Anki `cap10.yml`, `aemet-ama-fuente-oficial` («oficial y vinculante»). Banco `c10-q06` y `examenes/oficial/03-meteorologia-examen-50.md:1380` atribuyen esta obligación a SAO.GEN.130, que no la contiene; debe citar SAO.OP.120 b), SAO.OP.135 o SERA.2010 b).

#### [SYL-03] El cap10 no trata radar, satélite ni cartas de superficie y altura

**Categoría:** syllabus
**Dimensiones afectadas:** syllabus
**Severidad:** media
**Confianza:** moderada
**Verificación:** parcial
**Ubicación:** `cap10-informacion-meteorologica.qmd`

**Problema:** el epígrafe 3.10 no tiene subepígrafes, pero la doctrina estándar de información meteorológica incluye observaciones de radar y satélite y las cartas de superficie y altura. El libro las menciona de pasada (el mapa sinóptico en cap07, AMA en el apéndice B). El propio CHANGELOG lo reconoce (`CHANGELOG-03.md:166`).

**Propuesta:** un apartado breve: radar (ecos y desplazamiento), satélite visible e infrarrojo, el mapa de superficie y su enlace con cap07. Validación de un FI(S).

#### [TEC-26] CAPE: el glosario la integra «desde la superficie»; se integra desde el LFC

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `glosario.qmd:33`

> Cuantifica la flotabilidad acumulada de una parcela de aire desde la superficie hasta el nivel de equilibrio.

**Problema:** confunde la CIN (la inhibición bajo el LFC) con la CAPE. La banda baja difiere además del capítulo («< 500 J/kg (día débil)» frente a «0 J/kg = estabilidad absoluta» en `cap03:142`), y hereda la banda «excelente» de TEC-02.

**Evidencia:** NWS Louisville, «Stability indices»: el área «from the level of free convection (LFC) to the equilibrium level (EL)».

**Propuesta:** «…desde el nivel de convección libre (LFC) hasta el nivel de equilibrio»; unificar bandas con el cap03 tras resolver TEC-02.

**Derivados afectados:** `en/03-meteorology/glossary.qmd:38`.

#### [COH-06] Dorsal: el glosario dice «ausencia de ascendencias convectivas» y el capítulo planifica distancia bajo una dorsal

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, técnica
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado (comparación interna)
**Ubicación:** `glosario.qmd:60` frente a `cap07-sistemas-de-presion.qmd:25`, `:45` y `:66`

> subsidencia, cielos despejados, buen tiempo y ausencia de ascendencias convectivas

**Problema:** el cap07 dice que bajo una dorsal las térmicas quedan «limitadas en altura» (`:45`), las clasifica como «moderadas» (`:66`) y aconseja planificar vuelo de distancia (`:25`). La entrada contradice también la de «Anticiclón» del propio glosario (`:12`).

**Propuesta:** «…subsidencia, cielos poco nubosos y térmicas limitadas en altura».

#### [TEC-27] SIGMET: la lista de fenómenos omite las tormentas y la onda orográfica severa

**Categoría:** técnica
**Dimensiones afectadas:** técnica, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `glosario.qmd:165`

> engelamiento severo (`SEV ICE`), turbulencia severa (`SEV TURB`), actividad de cenizas volcánicas o ciclones tropicales

**Problema:** faltan las tormentas oscurecidas, embebidas, frecuentes o en línea y la onda orográfica severa (`SEV MTW`), que son precisamente los SIGMET que más importan al planeador. El cap10 (`:96`) sí menciona los Cb embebidos.

**Evidencia:** 2017/373, anexo V, apéndice 5 (fenómenos SIGMET): `OBSC/EMBD/FRQ/SQL TS[GR]`, `TC`, `SEV TURB`, `SEV ICE`, `SEV ICE (FZRA)`, `SEV MTW`, `HVY DS`, `HVY SS`, `VA CLD`, `RDOACT CLD`.

**Propuesta:** «…tormentas oscurecidas, embebidas, frecuentes o en línea (`TS`), engelamiento o turbulencia severos, onda orográfica severa (`SEV MTW`), tempestades de polvo o arena, cenizas volcánicas o ciclones tropicales».

#### [TEC-28] Estela turbulenta: el balanceo peligroso se produce al entrar alineado con el vórtice, no al cruzarlo

**Categoría:** técnica
**Dimensiones afectadas:** técnica, seguridad, coherencia
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `glosario.qmd:192`; idéntica en `06-procedimientos-operativos/glosario.qmd:93`

> Cruzarlos perpendicularmente puede inducir un momento de balanceo que supere los alerones del planeador.

**Problema:** el riesgo de balanceo incontrolable es mayor cuando la aeronave entra alineada con la trayectoria del generador; cruzar produce sacudidas y cargas bruscas.

**Evidencia:** FAA AC 90-23G, *Aircraft Wake Turbulence* (10-02-2014), §9.a: «The probability of induced roll increases when the encountering aircraft's heading is generally aligned or parallel with the flightpath of the generating aircraft». https://www.faa.gov/documentLibrary/media/Advisory_Circular/AC_90-23G.pdf (consultado el 2026-11-21).

**Propuesta:** «Entrar en ellos alineado con la trayectoria del avión que los generó puede inducir un balanceo superior a la autoridad de los alerones; cruzarlos produce sacudidas y cargas bruscas».

**Derivados afectados:** `06-procedimientos-operativos/glosario.qmd:93` (entrada común: se corrige en el 06 y se propaga); `en/03-meteorology/glossary.qmd:197` y el glosario inglés del 06.

#### [COH-07] La bibliografía del libro 03 no contiene ninguna fuente meteorológica

**Categoría:** coherencia
**Dimensiones afectadas:** coherencia, trazabilidad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `bibliografia.qmd`

**Problema:** la bibliografía es idéntica a la de los libros 01, 04, 05 y 09. No recoge el Part-MET, el AIP GEN 3.5, el Atlas de Nubes de la OMM (que `cap04:14` invoca), la AC 00-6B ni Miller (1972) o George, que `cap03:114` y `:134` citan. La introducción común promete que «la bibliografía dice de dónde sale cada cosa». Los libros 02, 06, 07 y 08 ya añaden una sección propia, y el 02 lo hizo por el hallazgo NOR-07 de su auditoría.

**Propuesta:** una sección «Meteorología» con: Reglamento de Ejecución (UE) 2017/373, anexo V (Part-MET), consolidado; AIP España GEN 3.5; OMM-N.º 407 (Atlas Internacional de Nubes) y OMM-N.º 306 (Manual de claves); FAA AC 00-6B (2016); AWS/TR-79/006 (rev. 1990), que recoge las escalas de Miller y George.

#### [PED-03] Reconocimientos y nota de estado: validación técnica sin alcance

**Categoría:** pedagógica
**Dimensiones afectadas:** coherencia, trazabilidad
**Severidad:** media
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `reconocimientos.qmd:6` y las marcas ✓ de la lista; nota de estado del Makefile («Revisión técnica completada por los instructores»)

> revisar técnicamente estas secciones para asegurar su rigor técnico

**Problema:** no se dice qué validaron los revisores marcados con ✓ ni hay leyenda del símbolo, y esta auditoría encuentra cinco errores altos confirmados. El aval de AESA sí está bien acotado (`licencia.qmd`: «en cuanto a su adecuación al syllabus»).

**Propuesta:** leyenda: «✓: ha revisado este libro. La revisión es de criterio instructor y no certifica cada afirmación técnica ni normativa»; moderar «para asegurar su rigor técnico». Es común a los nueve libros (se genera con `tools/actualizar-reconocimientos.py`).

### Baja

| ID | Ubicación | Problema | Propuesta | Confianza / verificación |
| --- | --- | --- | --- | --- |
| PED-04 | `cap01:44`, `:60` | «Menor densidad… significa menos sustentación»: sólo a igual TAS. En vuelo estabilizado la sustentación iguala al peso; cambia la TAS para la misma IAS (PHAK, caps. 5 y 11). El banco `c01-q07` lo enseña bien. | «la misma IAS supone más TAS: más carrera y más velocidad respecto al suelo en despegue y toma». Anki `cap01.yml`; `en/`. | moderada / no aplicable |
| PED-05 | `cap03:176` | El resumen da el SALR como valor fijo («solo la mitad, 1,5 °C»); el cuerpo (`:26`) sí dice «típicamente». AC 00-6B §11.3: de 1,2 a 3 °C/1.000 ft. | «≈1,5 °C/1.000 ft cerca de la superficie en aire templado; aumenta con el frío y la altura». Anki `cap03.yml`; banco `c03-q04`; `leccion-03.md`. | alta / confirmado |
| PED-06 | `cap03:172-179` | El post-it no recoge la fórmula de la base ni el gradiente del punto de rocío (0,5 °C/1.000 ft, que tampoco da el cuerpo); el banco, que sólo sale del post-it, no tiene ninguna pregunta de la destreza más examinable del bloque. | Añadir la viñeta «(T − T~rocío~) × 400 = altura de la base en ft AGL» y el 0,5 °C/1.000 ft en `:29`. | alta / no aplicable |
| PED-07 | figuras `03-cap03-modelo-burbuja.jpg`, `03-cap03-modelo-columna.jpg` | Rótulos espurios respecto al original (GFH figs. 9-6 y 9-7): «Ascensor» (mala traducción de *lift*), «Inversión térmica (Nivel de convergencia)»; curvas y rayas sin explicar en la columna. | Quitar esos rótulos y elementos. | alta / confirmado |
| PED-08 | `cap04:10`, `:16-30` | «La tabla siguiente resume…» y no hay tabla; el bloque de géneros no lleva marca de lista y sale como párrafos sueltos. | Convertirlo en tabla `@tbl-` con piso y géneros (con TEC-16). | alta / no aplicable |
| TEC-29 | `cap05:10` | «…que el flujo de aire se desprenda prematuramente y se vuelva turbulento»: el efecto principal de la lluvia es adelantar la transición laminar-turbulenta; el desprendimiento es otra cosa. | «…adelanta la transición a capa límite turbulenta y, en algunos perfiles, provoca desprendimiento». | moderada / requiere experto |
| TEC-30 | `cap06:42`; figura `03-cap06-frente-ocluido.png` | «El aire cálido ya no toca el suelo, así que las térmicas desaparecen»: causalidad dudosa. Figura: Ns en «Bajos», «ALTOESTRATOS» en la franja de altos, semicírculos sobre el frente frío, cabecera «TABLA INTEGRAL Y DETALLADA» (artefacto). No distingue oclusión fría y cálida (PHAK, cap. 12). | Reformular la causa; rehacer los rótulos de la figura. | moderada / parcial |
| TEC-31 | `cap06:61`, `:65-67` | Continental/marítima por «trayectoria» (es por la región de origen, PHAK cap. 12); tabla de masas sin orígenes europeos; Tc «excelentes térmicas» sin la calima; ártico con «engelamiento severo» en aire muy seco. | Región de origen; orígenes (Atlántico norte, Europa oriental, Azores, Sáhara); calima. Ártico, a un meteorólogo. | moderada / parcial |
| TEC-32 | `cap07:22` | Anticiclón invernal ibérico como térmico; el IGN lo atribuye al continental europeo, al de las Azores o a ambos. «Termal» por «térmico». Profundidad de 3.000–4.000 m sin fuente. | «suele deberse al anticiclón continental europeo, al de las Azores o a ambos»; «térmico». | moderada / parcial |
| COH-08 | `cap07:53`, `:65-66`; `cap08:34`, `:52`; `cap06:61` | Collado con aire «atrapado… por la subsidencia» (propia del anticiclón); columna «Circulación» de la tabla con «inestabilidad local creciente» y «subsidencia estable»; «solanas orientadas al este» frente al glosario (sur); otoño «asociado a mayor estabilidad» frente a las DANA del mismo párrafo y al banco `c08-q06`; «Antes de hablar de temperatura relativa…» aparece después de esa sección. | Corregir cada frase; la columna, «ciclónica / anticiclónica». | alta / confirmado |
| TEC-33 | `cap09:35` | «Las gotículas… se congelan en décimas de segundo»: vale para el hielo opaco; en el claro, sólo una parte se congela al instante y el resto escurre (AC 00-6B §18.3.2). El banco `c09-q06` dice «lentamente» y contradice al capítulo. | «Las gotículas pequeñas se congelan al instante (hielo opaco); las grandes, sólo en parte, y el resto escurre antes de helarse (hielo claro)». | alta / confirmado |
| COH-09 | `cap09:17`, `:70`, `:79`; `cap10:111`, `:116` | Pies que no casan: la foto del Cb muestra un chaparrón, no la cima; la de cizalladura promete una aproximación que no dibuja y dice «Micro ráfaga»; la de flujo sobre crestas no tiene rótulos ni rotor; la de índices rotula «LCL (… por Ascenso)» frente al glosario («por Elevación»), acredita sólo Windy (la captura es de flyXC y SoarCalc) y llama «capa convectiva» a la capa nubosa. | Ajustar pies y créditos; unificar el nombre del LCL. | alta / confirmado |
| COH-10 | `cap09:68`; `glosario.qmd:158-159`; `cap04:73`; `cap08:36` | El rotor es «invisible desde fuera», frente a las nubes de rotor que describen cap04 y el glosario; el glosario las llama «estratos irregulares» y cap04, cap08 y Anki, fractocúmulos. GFH cap. 9: «a roll or rotor cloud». | «…a menudo invisible; con humedad, lo delatan nubes de rotor (fractocúmulos)». | alta / confirmado; género, requiere experto |
| TEC-34 | `cap10:14`, `:78-79`, `:151`; `glosario.qmd:180` | Validez del TAF «9, 24 o 30 h» (correcto para la UE, MET.TR.215 c), pero en España sólo hay de 24 y 30 h, cada 6 h (AIP GEN 3.5 §3.3.3). «Cada 3 h los de 9 h» no se pudo verificar (Anexo 3). | Añadir «(en España, sólo 24 o 30 h, renovados cada 6 h)». Anki `metar-vs-taf`; banco `c10-q02` y examen-50:2146 («en el ámbito del vuelo a vela»). | alta / confirmado |
| TEC-35 | `cap10:64`, `:69`, `:70`, `:73` | `18002KT` «en calma» (calma es < 1 kt, `00000KT`); `WS RWY18` (el modelo vigente es `WS R18`); `NSW` sólo existe en TAF y TREND; `VV///` es visibilidad vertical no determinable; en España hay METAR AUTO supervisado (GEN 3.5 §3.2.2.1). | Una frase por punto: «viento flojo», `WS R18`, «`NSW` (TAF/TREND): fin previsto», «`VVnnn`, y `VV///` si no se puede medir». `en/` copia `WS RWY18`. | alta / confirmado |
| TEC-36 | `cap10:128` (`.mas-alla`) | «A 850 hPa el aire está entre 10 y 15 °C por debajo del suelo» sólo vale cerca del nivel del mar: con 850 hPa ≈ 1.457 m, desde un campo a 1.000 m la diferencia adiabática es de unos 4,5 °C. | «…entre 5 y 15 °C por debajo, según la altitud del campo». | moderada / confirmado (cálculo) |
| TEC-37 | `cap10:121` | Con la temperatura máxima prevista no se obtiene, en rigor, el CCL (definido con la temperatura convectiva; glosario del NWS). | «…obtienes la base prevista de los cúmulos de la tarde (próxima al CCL)». | moderada / parcial |
| PED-09 | `cap10:22`, `:40` | «Un error clásico de examen», «cae en el examen con frecuencia», sin evidencia. | «Es una confusión frecuente». | alta / no aplicable |
| TEC-38 | `apendice-fuentes-meteorologia.qmd:47` | Criterio de viento para la onda «entre 15 y 40 km/h en superficie»; el GFH lo refiere a la altura de las cimas: «at least 15 to 20 knots at mountaintop level», dirección a ±30° de la perpendicular, inversión cerca de las cimas. | Referirlo a las cimas, con la tolerancia direccional. FI(S) de onda. | moderada / requiere experto |
| TEC-39 | `apendice-fuentes-meteorologia.qmd:31-32`, `:40-41` | AMA aparece entre las fuentes «generales», sin GAMET, AIRMET ni SWL, que son sus productos de baja cota (GEN 3.5 §9.1). Wyoming funciona, pero la estación 08221 no devolvió datos el 21-11-2026 (no verificable si se sigue publicando). drjack.info es una página archivada. Las once URL responden. | Categoría propia «oficial» para AMA con sus productos; revisar a mano Wyoming. | alta / parcial |
| COH-11 | `glosario.qmd:41-42`; `cap07:47-49`; Anki `cap07.yml`, `collado` | «Pantano barométrico» como sinónimo de «collado»: el uso español documentado de «pantano» es una zona de presión casi uniforme, no un collado en cruz. `en/` ya lo omite. | Separar los dos conceptos o retirar la sinonimia. | moderada / no verificable (MeteoGlosario inaccesible) |
| PED-10 | `glosario.qmd` | Términos usados sin entrada: TT, TCU, TREND/NOSIG, octas, punto de rocío, CCL, frente estacionario, hielo claro, opaco y mixto, altitud de densidad, nivel de equilibrio. El LCL tiene dos nombres en el mismo glosario («por Elevación», «por Ascenso»). | Añadir las entradas y unificar el nombre. | alta / no aplicable |
| PED-11 | `glosario.qmd:3` | «Organizados según el programa de formación EASA AMC1 SFCL.130», pero el orden es alfabético estricto. Igual en `05/glosario.qmd:3`. | «Ordenados alfabéticamente». | alta / confirmado |
| TEC-40 | `glosario.qmd:152` | «Onda de montaña (wave soaring)»: *wave soaring* es la técnica de vuelo, como usa el libro 06. | «mountain wave / lee wave». | alta / confirmado |
| TEC-41 | `glosario.qmd:18` | «El hielo estructural lo suprime» (bataneo): generalización. | «puede reducirlo o anularlo». FI(S) o ingeniero. | baja / requiere experto |
| TEC-42 | `glosario.qmd:108` | K-Index «humedad en niveles medios»: la fórmula usa la de 850 y 700 hPa; el capítulo dice «medios y bajos». | «humedad en niveles bajos y medios». | alta / confirmado |
| PED-12 | `bibliografia.qmd` | Los anexos OACI «más relevantes» omiten el Anexo 3; faltan ediciones de EAR Sailplanes (rev. 09-2020, PDF 02-11-2022), GFH 13B (2024) y Reichmann (Paraninfo, 1992, ISBN 9788428315678). Texto común. | Añadir el Anexo 3 y las ediciones (con COH-07). | alta / confirmado |
| PED-13 | `reconocimientos.qmd:9` | «A los autores de los manuales internacionales clásicos… y, en especial a:» precede a la lista de revisores, que no son esos autores. | Separar las dos frases. Común a los nueve libros. | alta / no aplicable |
| PED-14 | `epigrafe.qmd` | La cita de Wilbur Wright es auténtica (*Observations on Soaring*, diario, hacia septiembre de 1900, Library of Congress), pero el epígrafe no dice su procedencia; «co-inventor» se escribe «coinventor». | «— Wilbur Wright, notas sobre el vuelo a vela (hacia 1900)…». | alta / confirmado |
| PED-15 | `apendice-syllabus-oficial-easa---meteorologia.qmd:16` | «Para garantizar que cubres todos los puntos necesarios para el examen» promete demasiado, y no dice que es traducción propia de un AMC (ED Decision 2020/004/R). | «…sigue el syllabus oficial (traducción propia del AMC1 SFCL.130)». | alta / no aplicable |
| COH-12 | `07-planificacion-rendimiento/cap03-…:70` | Remisión entrante: «convergencias, onda, efecto Föhn… Libro 3, capítulos 2 y 8»; la onda está sobre todo en el cap04, y el 03 escribe «Foehn». `en/07…/cap03:75` igual. | «capítulos 2, 4 y 8» y «Foehn». | alta / confirmado |
| PED-16 | varios | Erratas y léxico: `cap01:30` «tres equivalencias» y enumera dos; `cap01:52` «Tiempo de Conciencia Útil» (el 02 dice «Tiempo útil de conciencia»); `cap02:30` «unos 30 grados» sin el rango 10–45° (AC 00-6B §7.5); Foehn/FÖHN; `cap03:3` «sin estabilidad inestable»; `cap03:58` falta espacio tras «"térmica".»; `cap03:15-16` «1 °C/100m»; `cap04:79` «algodónosos» (arrastrado al banco `c04-q01`); `cap05:26` «aceleración cinética», «matriz celular sintética»; `cap06:18` «frente frío intercontinental»; `cap06:33` «nieblas cálidas» (niebla frontal); `cap09:76` «aporrizaje»; comas inglesas en las figuras de estabilidad y frente cálido; «ºC» (ordinal) por «°C» en ocho tarjetas Anki del 03. | Corregir. | alta / no aplicable |

---

## Comprobaciones cuantitativas

| Ubicación | Datos y fórmula | Resultado recalculado | Valor publicado | Estado |
| --- | --- | --- | --- | --- |
| `cap01:14-16` | ISA a nivel del mar (AC 00-6B, tabla 1-2) | 15 °C; 1013,25 hPa; 29,92 inHg; 1,225 kg/m³ | ídem, más 760 mmHg | correcto |
| `cap01:26` | gradiente ISA 6,5 °C/km × 0,3048 | 1,98 °C/1.000 ft | 2 °C/1.000 ft | correcto |
| `cap01:27`, `:59` | dz/dp = 1/(ρ·g) = 1/(1,225 × 9,80665) | 8,32 m/hPa = 27,3 ft (unos 31 ft a 5.000 ft) | 30 ft o 9 m | correcto como aproximación de capas bajas |
| `cap01:30` | ISA de 0 a 3.000 ft | 1013,2 → 908,1 hPa: −105 hPa | −100 hPa | correcto (aproximado) |
| `cap01:30` | ISA de 2.000 a 5.000 ft | −99 hPa; 20 − 6 = 14 °C | −100 hPa; 14 °C | correcto |
| `cap01:49` | ISA a 18.000 ft | 506 hPa ≈ 0,50 × p₀ | «la mitad» | correcto |
| figura ISA | 15 − 6,5 × 11 | −56,5 °C a 11.000 m / 36.089 ft | trazo: nivel del mar ≈ 6 °C, tropopausa ≈ −58 °C | **incorrecto** (TEC-06) |
| `cap02:59` | Föhn: ganancia = (DALR − SALR) × ascenso saturado = 1,5 °C/1.000 ft | 1.500 m (4.921 ft) → 7,4 °C; 2.000 m (6.562 ft) → 9,8 °C | «puede superar 10–15 °C»; resumen «hasta 15» | **no reproducible** (TEC-07) |
| figura Föhn | 15 → 25 °C | +10 °C exige unos 2.000 m saturados | +10 °C | límite plausible |
| `cap03:25-26` | DALR, SALR | 3 °C/1.000 ft = 0,98 °C/100 m; 1,5 °C/1.000 ft ≈ 0,5 °C/100 m | ídem | correcto (SALR variable: PED-05) |
| `cap03:29` | 1.000 / (3 − 0,5) | 400 ft/°C (≈ 122 m/°C) | × 400 | correcto; paréntesis (TEC-09) y AGL (TEC-10) |
| `cap03:38` | (26 − 16) × 400 | 4.000 ft AGL | 4.000 ft | correcto |
| figura base de cúmulos | parcela en el NCA: 26 − 3 × 4; Td: 16 − 0,5 × 4 | 14 °C y 14 °C a 4.000 ft | parcela 0 °C; ambiente 13 °C en suelo; tramo saturado 0,75 °C/1.000 ft | **incorrecto** (TEC-01) |
| figura de estabilidad | 20 − 3 × 3 | 11 °C (ambiente 9 °C: inestable; 13 °C: estable) | ídem | correcto |
| `cap03:134` | escala de George (AWS/TR-79/006, p. 5-38) | 15–20: 20 %; 21–25: 20–40 %; 26–30: 40–60 %; 31–35: 60–80 % | 15–20 ≈ 20 %; 21–30 ≈ 20–60 %; 31–35 ≈ 60–80 % | correcto |
| `cap03:131` | K > 30 | > 60 % | > 60 % | correcto |
| `cap04:16-26` | pisos nubosos (OMM, templadas) | altos 5–13 km; medios 2–7 km; bajos 0–2 km | > 6.000 / 2.000–6.000 / < 2.000 m | **incorrecto** como cita de la OMM (TEC-16) |
| figura familias de nubes | ídem | ídem | > 5.000 / 2.000–5.000 m; raya a 20.000 ft rotulada 16.000 ft | **incoherente** (TEC-16) |
| `cap04:54` | niebla | < 1 km (OMM §3.2.1.1.1) | < 1.000 m | correcto |
| `cap04:53` | neblina (BR) | ≥ 1 km; ≤ 5.000 m en METAR | 1.000–3.000 m | **incoherente** (COH-03) |
| `cap05:48` | microburst ≤ 2,2 NM × 1,852 | 4,07 km | no se da | incompleto (TEC-18) |
| `cap06:49` | VMC en clase G | SERA.5001: 5 km; 1.500 m sólo si la autoridad lo prescribe; RD 1180/2018 art. 30: sólo helicópteros y SPO | ídem | correcto |
| `cap08:13-15` | células de Hadley, Ferrel, polar | AC 00-6B §8.2: altas hacia 30°, bajas hacia 50–60° | 0–30°, 30–60°, 60–90° | correcto |
| `cap09:35`, `:40-42` | rangos de engelamiento | AC 00-6B §18: claro hacia 0/−10 °C, opaco por debajo de −15 °C, mixto entre ambos | ídem | correcto |
| figura ciclo de tormenta | duración del ciclo | unos 30 min (AC 00-6B §19.3) | 30 min | correcto |
| `cap09:14` | granizo dañino | > ½ in = 1,27 cm (AC 00-24C §7) | «> 2 cm» | parcial (TEC-23) |
| `cap09:60` | espera tras aeronave pesada | AC 90-23G y AIM 7-4: 2 min (3 para super) | 3 min | correcto como margen prudente |
| `cap09:63` | *downwash* del helicóptero | unos tres diámetros de rotor (AIM 7-4-7) | «al menos tres» | correcto |
| `cap10:12`, `:78` | intervalo del METAR | 30 o 60 min (MET.OR.200) | 30/60 | correcto |
| `cap10:12`, `:79` | validez del TREND | 2 h (AIP GEN 3.5 §3.3.2) | 2 h | correcto |
| `cap10:14`, `:79` | validez del TAF | UE 9/24/30 h; España 24/30 h | 9/24/30 | parcial (TEC-34) |
| `cap10:17` | TEMPO | < 1 h cada vez y < ½ del periodo (MET.TR.220 f) 4)) | ídem | correcto |
| `cap10:18` | PROB | 30 o 40 % (MET.TR.220 g)) | ídem | correcto |
| `cap10:22` | CAVOK | ≥ 10 km; sin nubes por debajo de 5.000 ft o de la MSA más alta; sin Cb ni TCU; sin tiempo significativo (art. 2 def. 37; MET.TR.200 d)) | ídem | correcto |
| `cap10:29-34` | octas | FEW 1–2, SCT 3–4, BKN 5–7, OVC 8 | ídem | correcto |
| `cap10:60` | (16 − 9) × 400 | 2.800 ft | 2.800 | correcto |
| `cap10:64` | 4.000 − 2.800 | 1.200 ft | 1.200 | correcto |
| `cap10:64` | `18002KT` | 2 kt, no calma (< 1 kt) | «en calma» | incorrecto (TEC-35) |
| figura índices | SoarCalc: (18,9 − 4,5) × 125 m + 1.007 m | 2.807 m AMSL | 2.806 m | correcto |
| `cap10:128` | ΔT entre suelo y 850 hPa (≈ 1.457 m ISA) a 9,8 K/km | 14 K desde 0 m; 4,5 K desde 1.000 m | «10–15 °C» | parcial (TEC-36) |
| glosario `:93` | límite del agua superenfriada | ≈ −40 °C | −40 °C | correcto |

---

## Rastreo de derivados

La tabla recoge las proposiciones corregibles agrupadas por destino. Cada hallazgo indica además sus derivados.

| Ruta | Proposición y ámbito | Origen canónico | Estado | Motivo |
| --- | --- | --- | --- | --- |
| `tools/anki/mazos/03-meteorologia/cap01.yml` | tarjeta de densidad | capítulo | afectado (menor) | PED-04 |
| `tools/anki/mazos/03-meteorologia/cap02.yml` | Föhn («hasta 15 ºC»), brisa marina | capítulo | afectado | TEC-07, TEC-08 |
| `tools/anki/mazos/03-meteorologia/cap03.yml` | estabilidad, SALR, `altura-de-la-base-de-los-cumulos`, índices por terreno, CAPE, día termonuclear y bandas | capítulo | afectado | TEC-02, TEC-10, TEC-11, TEC-14, COH-02, PED-05 |
| `tools/anki/mazos/03-meteorologia/cap04.yml` | `separacion-de-un-cb`; `rotor-bajo-la-onda` | capítulo | afectado / comprobado | PED-02; COH-10 (género) |
| `tools/anki/mazos/03-meteorologia/cap05.yml` | `lluvia-y-rendimiento`; `lluvia-engelante` | capítulo | afectado / comprobado sin cambio | PED-02; TEC-03 (la tarjeta es correcta) |
| `tools/anki/mazos/03-meteorologia/cap06.yml` | `frente-calido`; `sera-5001-minimos-vfr` | capítulo | afectado / comprobado sin cambio | TEC-19; rc.17 verificado |
| `tools/anki/mazos/03-meteorologia/cap07.yml` | `borrasca-a-menos-de-500-km`; `collado` | capítulo | afectado | PED-02; COH-11 |
| `tools/anki/mazos/03-meteorologia/cap08.yml` | `baja-termica-peninsular`; `separacion-de-laderas-de-sotavento` | capítulo | afectado | TEC-22; PED-02 |
| `tools/anki/mazos/03-meteorologia/cap09.yml` | todas | capítulo | comprobado sin cambio | — |
| `tools/anki/mazos/03-meteorologia/cap10.yml` | `speci`, `sigmet-airmet-nivel`, `metar-vs-taf`, `aemet-ama-fuente-oficial`, `codigos-fg-br-cavok` | capítulo | afectado | TEC-24, NOR-01, TEC-34, NOR-02, COH-03 |
| `tools/anki/mazos/03-meteorologia/*.yml` | «ºC» en ocho tarjetas | Anki | afectado (tipografía) | PED-16 |
| `tools/anki/mazos/en/03-meteorology/` | mismos `id` | Anki ES | afectado | espejo del español (FL100, «permanente»…) |
| `examenes/json/meteorologia.json` | `c05-q07` (comentario del distractor C) | banco (repositorio aparte; publicado en vuelalibre.net/examenes) | afectado | TEC-03 |
| `examenes/json/meteorologia.json` | `c10-q02` (TAF 9 h «en el ámbito del vuelo a vela»), `c10-q06` (SAO.GEN.130) | banco | afectado | TEC-34, NOR-02 |
| `examenes/json/meteorologia.json` | `c03-q04` (SALR «la mitad»), `c04-q01` («algodónosos»), `c09-q06` (contradice `cap09:35`, el banco tiene razón), `c09-q09` («3 minutos… criterio») | banco | afectado (menor) | PED-05, PED-16, TEC-33, `cap09:60` |
| `examenes/json/meteorologia.json` | resto de las 87 preguntas | banco | comprobado sin cambio | ninguna otra respuesta correcta contradice al libro o a las fuentes |
| `examenes/lecciones/03-meteorologia-leccion-02.md:372`, `-leccion-05.md:307` | Föhn «hasta 15 °C»; salida «hacia abajo» en FZRA | banco | afectado | TEC-07, TEC-03 |
| `examenes/oficial/03-meteorologia-examen-50.md:901`, `:1380`, `:2146` | downburst/reventón; SAO.GEN.130; TAF 9 h | banco | afectado | TEC-18, NOR-02, TEC-34 |
| `en/03-meteorology/` | cap03 (`:95`, `:99`, `:119`, `:150`, `:153`), cap04 (`:19`, `:58`), cap05 (`:39`), cap06 (`:51`), cap10 (`:29`, `:75`, `:102`, `:157`), glosario (`:17`, `:38`, `:86`, `:89`, `:134`, `:197`) | capítulo español | afectado | copia de los errores; `cap03` y `cap07` van además un commit por detrás (`457008f`) |
| `06-procedimientos-operativos/glosario.qmd:93` | turbulencia de estela, «cruzarlos perpendicularmente» | glosario común | afectado | TEC-28 |
| `07-planificacion-rendimiento/cap03-…:70` | remisión al libro 03, «capítulos 2 y 8» | capítulo del 07 | afectado | COH-12 |
| `05-principios-vuelo/glosario.qmd:3` | «organizados según el programa…» | glosario del 05 | afectado | PED-11 |
| `04-comunicaciones/cap04-terminos-de-informacion-meteorologica-relevantes-vfr.qmd:65` | SIGMET «hasta 4 horas (6 h en zonas oceánicas)» | capítulo del 04 | afectado, **fuera de alcance** | MET.OR.250 c) y AIP GEN 3.5 §8.1: 6 h sólo para cenizas volcánicas y ciclones tropicales |
| `04-comunicaciones/cap04-…:27`, `:57`, `:84`; `04-comunicaciones/glosario.qmd:120` | VOLMET difunde «METAR, TAF y SIGMET» | capítulo y glosario del 04 | afectado, **fuera de alcance** | AIP GEN 3.5 §7: el VOLMET español difunde «Informe MET, QNH y TREND» |
| glosarios de los nueve libros | 13 entradas comunes (CAVOK, QNH, METAR, TAF, Hipoxia, IAS, Engelamiento, Térmica, Turbulencia de estela…) | glosario común | comprobado: idénticas byte a byte | sin deriva; la estela obliga a corregir también el 06 |
| preliminares comunes | `licencia`, `dedicatoria`, `colofon`, `reconocimientos` | libro 01 | comprobado sin cambio | `cmp` contra los otros ocho libros: sin diferencias |
| `01-derecho-aereo-atc/cap06…` | 1.500 m en clase G | capítulo del 01 | comprobado sin cambio | ya corregido en la rc.17 |
| `recursos-completo/glosario.qmd` | SKC, FL100 | copia generada | no canónico | se regenera |

---

## Cobertura del syllabus

El syllabus aplicable es el AMC1 SFCL.130 (ED Decision 2020/004/R), recogido en las Easy Access Rules for Sailplanes. La página de EASA (consultada el 2026-11-21) sigue mostrando la versión consolidada de 01-10-2020 y no lista enmiendas posteriores; el PDF publicado es de 02-11-2022. La asignatura *3. Meteorology* tiene diez epígrafes **sin subepígrafes**, que el apéndice A reproduce fielmente (`apendice-…:5-14`). El examen es de 20 preguntas en 40 minutos (AMC1 SFCL.135). La cobertura se juzga contra el epígrafe y la doctrina estándar de nivel SPL, no contra subapartados deducidos.

| Epígrafe oficial | Estado | Evidencia en el libro | Observación |
| --- | --- | --- | --- |
| 3.1 La atmósfera | parcial | `cap01:8-53` | ISA, gradientes, densidad y O~2~ cubiertos. Faltan composición, capas, tropopausa en el texto y altitudes de presión y de densidad (SYL-01). |
| 3.2 Viento | cubierto | `cap02:8-91` | Gradiente, Coriolis, geostrófico, fricción, Buys Ballot, brisas, Föhn, brisa marina, convergencias. El giro alrededor de altas y bajas, en `cap07:12`, `:34`. La ascendencia de ladera, en `06/cap03`. |
| 3.3 Termodinámica | parcial | `cap03:9-77` | Gradientes adiabáticos, NCA, inversiones, burbuja y columna. La clasificación de la estabilidad está incompleta (TEC-11). Los índices de sondeo van correctamente en `.mas-alla`. |
| 3.4 Nubes y niebla | cubierto con lagunas | `cap04` | Diez géneros, Cu → Cb, onda y lenticulares, nieblas de radiación y advección. Clasificación OMM mal atribuida (TEC-16); faltan las nieblas orográfica, frontal y de evaporación. |
| 3.5 Precipitación | parcial | `cap05` | Sólo efectos sobre el planeador; falta formación y tipos (SYL-02). |
| 3.6 Masas de aire y frentes | cubierto con lagunas | `cap06` | Frentes y masas. Sin orígenes europeos de las masas ni oclusión fría frente a cálida (TEC-31, TEC-30). |
| 3.7 Sistemas de presión | cubierto | `cap07` | Anticiclón térmico y dinámico, borrasca como mínimo relativo, vaguada, dorsal, collado, tabla operativa. |
| 3.8 Climatología | cubierto con lagunas | `cap08` | Circulación general, chorro, DANA, Baja Térmica. De los vientos regionales sólo aparece la tramontana (faltan cierzo, levante, poniente…). |
| 3.9 Peligros para el vuelo | cubierto | `cap09` | Tormenta y su ciclo, engelamiento, estela, rotor, cizalladura y microburst. Falta el granizo bajo el yunque (TEC-23). |
| 3.10 Información meteorológica | parcial | `cap10` | METAR, SPECI, TAF, TREND, SIGWX, SIGMET, AIRMET, GAMET y sondeos. Faltan radar, satélite y cartas (SYL-03). VOLMET y ATIS, cubiertos en el libro 04. |

---

## Conciliación con el informe de julio (v1.0.2) y con la rc.17

| ID | Hallazgo de julio | Estado | Comprobación en el texto actual |
| --- | --- | --- | --- |
| H1 | Engelamiento: «tres formas» y enumera cuatro | corregido y verificado | `cap09:37` aparta la escarcha y deja «tres formas» de engelamiento propiamente dicho; el resumen dice «cuatro depósitos». Coincide con AC 00-6B §18.3 (escarcha aparte). |
| H2 | Intervalo «crítico» 0/−15 °C frente a hielo opaco < −15 °C | corregido y verificado | `cap09:35` añade «aunque puede aparecer a temperaturas más bajas»; rangos coherentes con AC 00-6B. |
| H3 | Borrasca definida por < 1.013 hPa | corregido y verificado | `cap07:30`: «mínimo relativo respecto a su entorno… no un umbral absoluto». Ni el libro, ni Anki, ni `en/` conservan el umbral. |
| H4 | Falta el ciclo de vida trifásico de la tormenta | corregido en el texto; regresión parcial en la figura | `cap09:23-29`. La figura rotula cuatro fases y precipitación en la de desarrollo (COH-04). |
| H5a | Fuente de los umbrales TT/K (Miller) | persistente | Se añadió la atribución (`cap03:114`), pero a una escala que no es la de Miller (TEC-13). La escala de George del K está bien citada. |
| H5b | Diez géneros OMM en texto y tabla | corregido en presencia; persiste un problema nuevo | Los diez géneros están en el texto y la figura; la atribución a la OMM, las alturas y el piso del Ns no cuadran (TEC-16). La tabla anunciada no existe (PED-08). |
| H6 | Tabla resumida «nivel examen» de los índices | corregido el rótulo; persiste la incoherencia | `cap03:162`, «bandas de referencia para el vuelo a vela»; las bandas contradicen las tablas completas (COH-02). |
| H7 | Simuladores, marca de agua, índice analítico | corregido y verificado el enlace; implementados los otros dos | https://vuelalibre.net/examenes/03-meteorologia/ responde (10 de 10 capítulos, 87 preguntas, simulacro de 20 en 40 min). Marca de agua e índice, en la maqueta (no verificados en el PDF compilado). |
| — | Fórmulas TT y K (verificadas en julio sobre el PDF v1.0.2) | regresión | Se perdieron al importar a Quarto (TEC-12). |
| — | Fórmula de la base con paréntesis (rc.18) | regresión | `cap03:29` (TEC-09). |

**Correcciones de la rc.17 que venían de las auditorías del 01 y el 02:**

| Corrección | Estado | Comprobación |
| --- | --- | --- |
| cap06, mínimos VFR en clase G (5 km; 1.500 m no vale para planeadores) | corregido y verificado | `cap06:49` coincide con SERA.5001 (tabla S5-1 y nota) y con el RD 1180/2018, art. 30.1; la tarjeta Anki también. Matices menores: SERA dice «a 900 m (3.000 ft) AMSL o por debajo», y el art. 30.2 admite exenciones por resolución. |
| cap06, criterio 3.000 ft AMSL / 1.000 ft | corregido y verificado | Sin otro sitio del libro que lo omita. |
| cap06, IMC sin habilitación sin gravedad fija | corregido y verificado | — |
| Glosario, CAVOK | corregido y verificado | Coincide con 2017/373, art. 2 def. 37 y MET.TR.200 d), y con `cap10:22`. |
| Bibliografía, SERA y RD 1180/2018; lista de normas | corregido y verificado | CELEX 02012R0923-20250501 es la última consolidación de SERA (SPARQL, 2026-11-21); las 25 URL responden. Falta la parte meteorológica (COH-07). |
| Licencia, Part-SFCL | corregido y verificado | — |
| rc.18, cap07 «hemisferio norte» | corregido y verificado | `cap07:12`, `:34`, `:61`, `:73`, `:74`. |

---

## Lo que funciona

- **El METAR de ejemplo** se lee grupo a grupo y termina en una decisión de vuelo (no-go por `OVC040`), y reutiliza la fórmula de la base con un METAR real (`cap10:58-64`): enseña lo que el piloto tiene que hacer con el informe.
- **La definición relativa de borrasca y anticiclón** (`cap07:30`), con su contraejemplo explícito, es exactamente lo que pedía H3.
- **El recuadro normativo de VFR en clase G** (`cap06:49`) cita SERA y el RD 1180/2018 y separa el límite legal de la excepción.
- **La temperatura relativa entre masa de aire y suelo** (`cap06:52-57`) es el modelo mental correcto para el vuelo a vela.
- **Las cifras de la ISA** y los ejemplos de equivalencias del `cap01:30` cuadran con la atmósfera estándar hasta en la caída de 2.000 a 5.000 ft.
- **La fricción y su consecuencia en la toma** (`cap02:30-34`) se explica con exactitud y se transfiere a la operación.
- **Los rangos de engelamiento y la escarcha aparte** (`cap09:35-42`) coinciden con la AC 00-6B.
- **La separación entre fuentes oficiales y comerciales** (`cap10:141`): Windy, SkySight, TopMeteo o RASP nunca se presentan como oficiales.
- **La separación del contenido avanzado**: los índices de sondeo van en un único `.mas-alla`, fuera del post-it; las adaptaciones al vuelo a vela de las tablas del K y del TT se declaran como de la colección.
- **Las figuras de la onda de montaña y del ciclo de la térmica** son adaptaciones fieles del *Glider Flying Handbook* (figs. 9-22 y 9-9).
- **Los preliminares comunes** son idénticos byte a byte a los del 01, y las 13 entradas que el glosario comparte con otros libros, también.

---

## Prioridades

1. **Altas, mensajes de seguridad:**
   - TEC-03 (lluvia engelante): capítulo, glosario, comentario del banco `c05-q07`, lección 05 y `en/`;
   - TEC-02 (CAPE «sin riesgo de tormenta severa»), junto con COH-02 y `cap10:128`; la banda útil, a un meteorólogo o FI(S).
2. **Altas, figuras:** TEC-01 (base de los cúmulos), TEC-04 (frente frío) y TEC-05 (SIGWX). Marcarlas `.corregir` ya, hasta que Ramón las rehaga.
3. **Medias de mayor retorno:**
   - el bloque de índices del cap03: TEC-12 (fórmulas perdidas), TEC-15 (LI), TEC-13 (Miller), TEC-14 (K en montaña), COH-02, y en el glosario TEC-26 y TEC-42;
   - la fórmula de la base: TEC-09 y TEC-10, con PED-06 (post-it) para que el banco la practique;
   - el producto español: NOR-01 (FL150), TEC-24 (SPECI), TEC-25 (SKC), NOR-02 (obligatorio/vinculante, con `c10-q06`), TEC-27 (SIGMET);
   - TEC-11 (estabilidad), TEC-18 (downburst), TEC-19 y TEC-20 (frentes), TEC-23 (granizo bajo el yunque), TEC-28 (estela, con el 06).
4. **Resto de medias:** figuras del cap01, cap02 y cap09 (TEC-06, COH-01, PED-01, COH-04, COH-05); TEC-07 y TEC-08 (Föhn y brisa); TEC-16 y COH-03 (nubes y neblina); climatología (TEC-17, TEC-21, TEC-22); PED-02; COH-06; COH-07 y PED-03 (bibliografía y reconocimientos, comunes a la colección); SYL-01 a SYL-03.
5. **Derivados en otros libros:** `06/glosario` (TEC-28), `07/cap03` (COH-12), `05/glosario` (PED-11) y, fuera del alcance de esta auditoría pero ya verificados, los dos errores del `04/cap04` (validez del SIGMET y contenido del VOLMET).
6. **Bajas:** opcionales y agrupables por capítulo cuando se toque cada uno.

Cada corrección de contenido requiere su línea en `[En curso]` de `CHANGELOG-03.md` (y en los de los libros 04, 05, 06 y 07 cuando se toquen), la propagación a `en/` con su `origen-commit`, a Anki sin cambiar ningún `id`, y la revisión del banco (repositorio aparte) cuando cambie un post-it, con `make web-json`, `make check` y `make lecciones-check`.

---

## Pendiente de verificar

- **Meteorólogo (AEMET):**
  - TEC-02 y COH-02: qué combinación de CAPE, TT, K y LI es buen día de vuelo a vela en la Península sin riesgo de sobredesarrollo. Criterio: la banda queda por debajo de los umbrales de tormenta de sus propias tablas.
  - TEC-13: si existe una calibración regional de los umbrales del TT y del K para la Península.
  - TEC-17, TEC-21, TEC-22, TEC-32: climatología de la niebla de advección, situación típica de primavera y verano, carácter de la Baja Térmica y origen del anticiclón invernal.
  - COH-11: si «pantano barométrico» y «collado» son sinónimos.
  - COH-03: confirmar el tope de 5.000 m de BR en el Anexo 3 o la OMM-306.
  - TEC-31: masa ártica y engelamiento.
  - TEC-37: redacción correcta del CCL.
  - TEC-05: el símbolo rojo del mapa SWL, contra la simbología del Anexo 3 o la guía de AEMET.
  - TEC-07: si existen diferencias de Föhn mayores que las del mecanismo descrito en valles españoles, y el origen del microclima del Tiétar (`cap02:65`).
- **FI(S) de travesía y de onda:**
  - TEC-03: la redacción operativa de la salida de una lluvia engelante en planeador.
  - PED-02: margen de velocidad con lluvia, separación de un Cb, 500 km de una depresión, 300 ft sobre sotavento, bases y térmicas postfrontales.
  - TEC-14: la regla del TT en llano y el K en montaña.
  - TEC-38: criterio de viento para la onda a nivel de las cimas.
  - `cap02:52` (restitución), `cap02:72` (térmicas «explosivas» bajo Föhn), `cap03:74` (burbujas por la mañana, columnas después), `cap03:167` (aterrizaje antes de las 16:00 h), `cap08:23-24` (zonas de onda y convergencia; Pedro Bernardo es sobre todo zona de parapente) y la figura del ciclo anabático (térmica saliendo del centro del valle).
- **FI(S) o aerodinamicista:** TEC-29 (lluvia y capa límite) y TEC-41 (hielo y bataneo).
- **Editor:** PED-03 (leyenda ✓ y alcance de la validación) y la procedencia de las figuras SIGWX y de la estela (TEC-05, COH-05).

---

## Fuentes consultadas

| Fuente | Edición o vigencia | Apartados usados | Naturaleza | Fuerza | Consulta |
| --- | --- | --- | --- | --- | --- |
| Reglamento de Ejecución (UE) 2017/373, CELEX 02017R0373-20261004 (Cellar: https://publications.europa.eu/resource/celex/02017R0373-20261004.SPA.pdfa2a) | consolidación de 04-10-2026 | art. 2 def. 26 y 37; anexo V: MET.OR.200, 250, 255; MET.TR.200 d) y f), 205, 210, 215, 220; apéndices 1 y 5 | primaria | vinculante | 2026-11-21 |
| ENAIRE, AIP España GEN 3.5 «Servicios meteorológicos» (https://aip.enaire.es/AIP/contenido_AIP/GEN/LE_GEN_3_5_es.pdf) | AIRAC AMDT 10/26, WEF 29-OCT-26 | §1, 3.2.2, 3.2.2.1, 3.2.3, 3.3.2, 3.3.3, 3.6.1, 3.6.2, 7, 8.1, 8.2, 9.1 | primaria | vinculante | 2026-11-21 |
| EASA, Easy Access Rules for Sailplanes (https://www.easa.europa.eu/en/downloads/94424/en) | versión consolidada de 01-10-2020; PDF de 02-11-2022 | AMC1 SFCL.130 y 135; SAO.GEN.130; SAO.OP.120 y 135 | primaria (compilación) | IR vinculante; AMC no vinculante | 2026-11-21 |
| EASA, página de normativa de planeadores (https://www.easa.europa.eu/en/regulations/sailplanes-air-operations) | — | ausencia de enmiendas posteriores a 2020 | primaria institucional | no aplicable | 2026-11-21 |
| EASA, Easy Access Rules for SERA (`recursos/fuentes/easa/`) | 08-2025 | SERA.2010 b); SERA.5001 | primaria (compilación) | vinculante | 2026-11-21 |
| Real Decreto 1180/2018, BOE consolidado (`recursos/fuentes/espana/`) | vigente | art. 30 | primaria | vinculante | 2026-11-21 |
| FAA AC 00-6B *Aviation Weather* (https://www.faa.gov/documentLibrary/media/Advisory_Circular/AC_00-6B.pdf) | 23-08-2016 | tabla 1-2; §7.4-7.5; §8.2; §10.2; §11.2-11.3; §12.3; cap. 14 (fig. 14-4); §18.2-18.3; §19.3; §19.6.3 | secundaria técnica de autoridad | no vinculante | 2026-11-21 |
| FAA AC 00-24C *Thunderstorms* (https://www.faa.gov/documentLibrary/media/Advisory_Circular/AC%2000-24C.pdf) | 19-02-2013 | §7 (granizo), §10 | secundaria técnica | no vinculante | 2026-11-21 |
| FAA AC 90-23G *Aircraft Wake Turbulence* (https://www.faa.gov/documentLibrary/media/Advisory_Circular/AC_90-23G.pdf) | 10-02-2014 | §6, §9.a | secundaria técnica | no vinculante | 2026-11-21 |
| FAA *Aeronautical Information Manual*, cap. 7, secciones 1 y 4 (https://www.faa.gov/air_traffic/publications/atpubs/aim_html/chap7_section_1.html) | vigente | 7-1-24; 7-4; 7-4-7 | secundaria técnica | no vinculante | 2026-11-21 |
| FAA PHAK, H-8083-25C (`recursos/fuentes/faa/`) | 2023 | caps. 4, 5, 11 y 12 | secundaria formativa | no vinculante | 2026-11-21 |
| FAA *Glider Flying Handbook*, H-8083-13B (`recursos/fuentes/faa/`) | 2024 | cap. 9 (burbuja, columna, ciclo de la térmica, calles de nubes, convergencias, ladera, onda; figs. 9-6, 9-7, 9-9, 9-12, 9-17, 9-22, 9-26, 9-27); glosario | secundaria formativa | no vinculante | 2026-11-21 |
| Air Weather Service, AWS/TR-79/006 *The Use of the Skew T, Log P Diagram* (https://www.inscc.utah.edu/~krueger/5300/AF_SkewT_manual.pdf; DTIC ADA221842) | dic. 1979, rev. marzo 1990 | §5.24.2 (LI), §5.24.9 (K, escala de George), §5.24.12 (TT); tablas pp. 5-42 y 5-43; referencias p. 5-44 | primaria técnica | no vinculante | 2026-11-21 |
| NWS Louisville, «Stability indices» (https://www.weather.gov/lmk/indices) | en línea | CAPE, LI, K, TT | primaria (servicio oficial) | no vinculante | 2026-11-21 |
| NWS Houston, formación sobre Skew-T (https://www.weather.gov/source/zhu/ZHU_Training_Page/convective_parameters/skewt/skewtinfo.html) | en línea | CAPE | primaria formativa | no vinculante | 2026-11-21 |
| NWS, glosario, «Convective Condensation Level» (https://forecast.weather.gov/glossary.php?word=convective%20condensation%20level) | en línea | CCL | secundaria | no vinculante | 2026-11-21 |
| OMM, *Atlas Internacional de Nubes* (https://cloudatlas.wmo.int/en/useful-concepts.html) | ed. 2017, en línea | §2.2.1.2, tabla 6; §2.3.6.1 (Ns); §3.2.1.1.1 (niebla y neblina) | primaria | no vinculante | 2026-11-21 |
| AEMET, curso PIB-M 2022, «03 METAR-SPECI» (https://etrp.wmo.int/pluginfile.php/56265/mod_resource/content/1/03-METAR-SPECI.pdf) | 2022 | p. 21 (BR) | formación oficial | no vinculante | 2026-11-21 |
| IGN, *Atlas Nacional de España*, cap. 4 «Clima» (https://www.ign.es/web/resources/docs/IGNCnig/ANE/Capitulos/04_1_Clima_2020_20231103.pdf) | ed. 2020, PDF de 03-11-2023 | nieblas; baja térmica estival; anticiclón de invierno; DANA | primaria oficial | no vinculante | 2026-11-21 |
| AEMET Blog, «¿Qué es una dana…?» (https://aemetblog.es/2023/06/03/que-es-una-dana-y-como-se-formapor-que-es-mas-adecuado-usar-este-termino-que-gota-fria/) | 03-06-2023 | DANA | secundaria de organismo | no vinculante | 2026-11-21 |
| DVIDS, NASA L90-5919 «Wake Vortex Study at Wallops Island» (https://www.dvidshub.net/image/691683/wake-vortex-study-wallops-island) | — | foto original | secundaria | no aplicable | 2026-11-21 |
| East Carolina University / Library of Congress, W. Wright, *Observations on Soaring* (https://digital.lib.ecu.edu/exhibits/wright/diaries/w0i1/) | hacia septiembre de 1900 | cita del epígrafe | primaria (archivo) | no aplicable | 2026-11-21 |
| URL del apéndice B (skysight.io, topmeteo.eu, drjack.info, raspuri.mooo.com, soaringmeteo.org, meteo-parapente.com, edl-soaring.com, ama.aemet.es, windy.com, meteoblue.com, weather.uwyo.edu) y vuelalibre.net/examenes/03-meteorologia/ | estado al 2026-11-21 | disponibilidad y función | dinámica | no aplicable | 2026-11-21 |

---

## Alcance y límites

- **Revisado:**
  - los diez capítulos completos, incluidas aperturas, recuadros, tablas, `.mas-alla` y resúmenes;
  - los dos apéndices, el glosario (66 entradas), la bibliografía, la introducción y los preliminares;
  - los diez mazos Anki (sólo `tarjetas`) y su espejo inglés;
  - las 26 figuras, abiertas una a una;
  - el banco de examen, las lecciones y el examen-50, como derivados;
  - las remisiones entrantes al libro 03 desde los otros ocho libros.
- **Forma de trabajo:** la revisión se hizo en cuatro bloques en paralelo (cap01-03; cap04-08; cap09-10 y apéndice B; glosario, bibliografía, apéndice A, introducción y preliminares) y después se consolidó. La consolidación incluyó una verificación propia en fuente primaria de los cinco hallazgos altos: AC 00-6B §14 y §18.3.7 (TEC-03), las figuras abiertas y contrastadas con su recuadro y con la AC 00-6B (TEC-01, TEC-04), la figura SIGWX frente a su leyenda y al AIP GEN 3.5 §3.6.2 (TEC-05) y la página de índices del NWS (TEC-02); además, MET.OR.255, MET.TR.200 f) y GEN 3.5 para NOR-01 y TEC-24. Las citas literales se cotejaron con el `.qmd` mediante `grep -n`.
- **Formato:** los hallazgos de severidad baja se presentan en una tabla compacta, sin el desarrollo completo de evidencia; sus fuentes están en la tabla general.
- **Fuera de alcance:**
  - la calidad de la traducción inglesa, que sólo se rastreó como derivado;
  - la maqueta y el PDF compilado (no se comprobaron la marca de agua, el índice analítico ni el QR del apéndice A);
  - los capítulos de otros libros, salvo para comprobar coherencia y remisiones; los dos errores del `04/cap04` se anotan para la auditoría del libro 04.
- **Fuentes inaccesibles:**
  - el Anexo 3 de la OACI (de pago), suplido con el Part-MET y el AIP GEN 3.5;
  - el MeteoGlosario de AEMET y el DLE (bloqueo automático), el glosario de la AMS (403), el Manual de claves OMM-306 (e-Library en JavaScript), el PDF de Miller (1972) en DTIC y el artículo de Elvidge y Renfrew (2016) sobre el Föhn (403);
  - la ISA de la OACI (Doc 7488, de pago), suplida con la tabla 1-2 de la AC 00-6B.
- **Jurisdicción:** buena parte de la evidencia técnica es de la FAA y del NWS. Las heurísticas de vuelo a vela y la climatología española se apoyan en el IGN y, cuando no hay fuente, quedan como `requiere experto`.
- **Límite de competencia:** esta revisión asistida no sustituye el visto bueno de un meteorólogo, de un FI(S) o FE(S) ni de la autoridad competente en los puntos marcados como pendientes. La adecuación del temario al syllabus que declaran los preliminares no valida cada afirmación del desarrollo.
- **Sin cambios en las fuentes:** no se ha modificado ningún fichero del libro, glosario, Anki, figuras, banco ni CHANGELOG.
