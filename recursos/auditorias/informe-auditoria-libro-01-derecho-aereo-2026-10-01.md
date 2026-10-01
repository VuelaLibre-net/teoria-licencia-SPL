# Auditoría del libro 01: *Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (ATC)*

**Libro:** 01. Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (ATC)
**Fuente:** `01-derecho-aereo-atc/`: `cap01…cap14-*.qmd`, `licencia.qmd`, `reconocimientos.qmd`, `introduccion.qmd`, `apendice-syllabus-oficial-easa---derecho-aereo.qmd`, `glosario.qmd`, `bibliografia.qmd`
**Versión:** 1.0-rc.14 (`01-derecho-aereo-atc/_quarto.yml:6`)
**Estado editorial:** En revisión (`make estados`)
**Fecha:** 2026-10-01
**Modalidad:** completa (libro entero, capítulo a capítulo)
**Base de comparación:** `main` en `cf98250`. Los ficheros del libro 01 y sus mazos son idénticos en `main` y en `edicion-inglesa-08`.
**Diff revisado:** no aplica; la modalidad es completa. Informe anterior conciliado: `aesa-spl-oficial/recursos/auditorias/informe-evaluacion-libro-01-derecho-aereo-spl.md`, del 10 de julio de 2026, sobre el PDF v1.0.3.
**Verificación externa:** completa en lo material, con las limitaciones de «Alcance y límites». Los Anexos 7, 11, 12, 14, 17 y 18 de OACI y el Doc 8400 se suplieron con sus transposiciones UE, el AIP España o reproducciones no oficiales, y eso consta en cada caso.

**Derivados revisados:**
- mazos Anki `tools/anki/mazos/01-derecho-aereo-atc/cap01…cap14.yml`;
- las 29 figuras de `01-derecho-aereo-atc/imagenes/`;
- el banco de examen `examenes/json/derecho-aereo-atc.json` y las lecciones `examenes/lecciones/01-derecho-leccion-*.md` (repositorio git propio, excluido del principal);
- la edición inglesa `en/01-air-law-atc/`, rastreada como derivado y no auditada como traducción;
- los capítulos de otros libros que tratan la misma materia.

---

## Resumen ejecutivo

El libro conserva lo que el informe de julio valoró bien. La estructura replica uno a uno los 14 epígrafes del AMC1 SFCL.130. Las cajas tipográficas separan norma, seguridad y *airmanship*. El enfoque es específico del planeador y está contextualizado en España. Muchas cifras normativas son exactas: SERA.3210 en convergencia, mínimos VMC por clase, recencia SFCL.160, pasajeros SFCL.115, la regla 40/42 del médico LAPL, la tabla de niveles de crucero española, los umbrales INCERFA, el código tierra-aire, las cuantías del art. 55.1 de la LSA y el plazo de 72 h del Reglamento 376/2014. Desde julio se han resuelto varios hallazgos: H3, H6, H10 y, en parte, H2, H4, H5 y H9.

Esta auditoría, más profunda que la de julio y apoyada en fuentes vigentes a 1 de octubre de 2026, encuentra problemas de tres tipos.

**Normas derogadas o sustituidas que el libro sigue presentando como vigentes:**
- El RD 552/2014 está derogado desde 2018 por el RD 1180/2018.
- La CIAIAC quedó suprimida el 15-07-2026.
- El RD 384/2015 de matriculación fue sustituido por el RD 1029/2025.

**Errores normativos de fondo que no se detectaron en julio:**
- **Bloqueante:** en España los 1.500 m de visibilidad reducida no se aplican a planeadores (RD 1180/2018, art. 30). El libro lo enseña en el capítulo 6, en Anki, en el libro 03, en el banco de examen y en su lección. En el examen, la respuesta que se puntúa como correcta es la errónea.
- **Alta:**
  - el catálogo de infracciones del capítulo 14, que no es el de la LSA;
  - el alcance de la notificación obligatoria de sucesos;
  - la documentación que debe ir a bordo;
  - el «ATC te separa» sin condicionarlo a la clase de espacio aéreo;
  - la prioridad «siempre» del planeador frente a la aeronave de motor;
  - la regla del transpondedor en España;
  - la ausencia total de SFCL.155, la recencia por método de lanzamiento.

**Figuras que contradicen el texto:**
- La de la regla semicircular dibuja la orientación Este-Oeste de SERA, no la Norte-Sur española.
- Otras: el ARC caducado en el tercer año, el planeador de ladera en sotavento, la escala de infracciones, el flujo de notificación y la ubicación de la matrícula.

**Acción prioritaria:** corregir el bloqueante NOR-01 en todos sus derivados, incluido el banco de examen publicado. Después, las altas con fuente exacta. Casi todas tienen texto sustitutivo verificado y no exigen reescribir capítulos.

| Dimensión | Veredicto | Motivo breve |
| --- | --- | --- |
| Calidad pedagógica | requiere correcciones | TEC-01 y TEC-02 consolidan modelos mentales falsos (prioridad y separación). Varios resúmenes introducen materia ausente del cuerpo. |
| Fiabilidad técnica | bloqueado (además, incompleto) | NOR-01 es bloqueante y está confirmado. Hay diez hallazgos altos. NOR-07 y NOR-17 tienen verificación parcial. |
| Cobertura del syllabus | requiere correcciones | 1.4 parcial por SFCL.155 (SYL-01). 1.8 a 1.14 cubiertos con huecos medios (AFIS, SUP/PIB, señales SERA, balizas, marco de *security*, derecho nacional). |
| Coherencia y derivados | requiere correcciones | Remisiones rotas al libro 04. RD 552/2014 en las 9 bibliografías. Errores repetidos en Anki, banco de examen, lecciones y edición inglesa. |

**Recomendación editorial:** **no apto todavía.** Hay un bloqueante confirmado. Con las correcciones de prioridad 1 y 2 aplicadas, el libro quedaría en «apto con correcciones».

### Veredicto por capítulo

| Cap. | Título | Peor hallazgo | Recomendación |
| --- | --- | --- | --- |
| 01 | Derecho internacional | alta (TEC-01, NOR-02) | apto con correcciones |
| 02 | Aeronavegabilidad | alta (NOR-03) | apto con correcciones |
| 03 | Marcas de nacionalidad y matrícula | media | apto con correcciones |
| 04 | Licencias de personal | alta (SYL-01) | apto con correcciones |
| 05 | Reglas del aire | alta (NOR-02, TEC-01) | apto con correcciones |
| 06 | Procedimientos: operaciones | **bloqueante (NOR-01)** | **no apto todavía** |
| 07 | Estructura del espacio aéreo | alta (NOR-07, parcial; TEC-02) | apto con correcciones |
| 08 | ATS y ATM | alta (TEC-02) | apto con correcciones |
| 09 | AIS | media | apto con correcciones |
| 10 | Aeródromos y campos externos | media (NOR-17, parcial) | apto con correcciones |
| 11 | Búsqueda y salvamento | media | apto con correcciones |
| 12 | Seguridad (*security*) | alta (NOR-03) | apto con correcciones |
| 13 | Notificación de accidentes | alta (NOR-04, NOR-05) | apto con correcciones |
| 14 | Derecho nacional | alta (NOR-06) | apto con correcciones |
| — | Glosario | media (TEC-12, derivado de NOR-04) | apto con correcciones |
| — | Bibliografía | alta, como derivado de NOR-02 | apto con correcciones |
| — | Preliminares (`licencia.qmd`) | requiere experto (H5) | apto con correcciones |

---

## Hallazgos

Los hallazgos van ordenados por severidad y, dentro de cada severidad, por orden de aparición. Cuando varios capítulos comparten una misma causa, se agrupan en un único hallazgo con todas sus ubicaciones. Los de severidad baja se recogen en una tabla compacta al final.

### Bloqueante

#### [NOR-01] En España la visibilidad reducida a 1.500 m no se aplica a planeadores

**Categoría:** normativa
**Dimensiones afectadas:** normativa, técnica, coherencia
**Severidad:** bloqueante
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `01-derecho-aereo-atc/cap06-procedimientos-para-navegacion-aerea-operaciones-de-aeronaves.qmd:25`, `:99`

> Hay una excepción interesante en espacio no controlado: si vuelas a menos de 140 kt (como un planeador), la normativa permite reducir la visibilidad mínima a **1.500 m**, siempre que tu velocidad te deje ver otros tráficos u obstáculos con tiempo de sobra para evitar la colisión

**Problema:** la reducción a 1.500 m no es una regla general de SERA. La nota de la tabla S5-1 empieza «Cuando así lo prescriba la autoridad competente». España la ha prescrito sólo para helicópteros y aviones de operaciones especializadas (RD 1180/2018, art. 30.1). Fuera de ese caso, sólo cabe una exención individual (art. 30.2). Para un planeador en clase F o G por debajo de 3.000 ft AMSL o 1.000 ft AGL, el mínimo sigue siendo **5 km**.

**Impacto:** enseña una actuación ilegal y menos segura: continuar en VFR con una visibilidad de entre 1.500 y 5.000 m. Además, el banco de examen publicado la puntúa como respuesta correcta.

**Evidencia:**
- RD 1180/2018 (BOE-A-2018-15406), texto consolidado, última actualización publicada el 05-06-2024. Art. 30.1: «En los espacios aéreos F y G los helicópteros y aviones destinados a operaciones aéreas especializadas podrán realizar vuelos con reglas de vuelo visual (en adelante VFR) diurnos con una visibilidad inferior a la prevista en la tabla S5-1 de SERA.5001…». https://www.boe.es/buscar/act.php?id=BOE-A-2018-15406 (consultado el 2026-10-01).
- Reglamento de Ejecución (UE) 923/2012, SERA.5001, tabla S5-1, nota (***), consolidado a 01-05-2025.
- AIP España ENR 1.2, que lo resume en el mismo sentido.

**Propuesta:** «SERA permite que la autoridad competente autorice visibilidades de hasta 1.500 m por debajo de 140 kt IAS, pero en España (RD 1180/2018, art. 30) sólo lo ha hecho para helicópteros y aviones de operaciones aéreas especializadas: **para un planeador, el mínimo es 5 km**.» Retirar la frase del resumen (`:99`).

**Derivados afectados:**
- resumen (`cap06:99`);
- Anki `tools/anki/mazos/01-derecho-aereo-atc/cap06.yml:27` (`minimos-vmc-baja-cota`);
- otro capítulo: `03-meteorologia/cap06-masas-de-aire-y-frentes.qmd:49`, y su Anki `03-meteorologia/cap06.yml:60`;
- banco de examen: `derecho-aereo-atc-c06-q03` (respuesta correcta A, «A 1.500 m.»);
- lección `examenes/lecciones/01-derecho-leccion-06.md:114-120`;
- edición inglesa: `en/01-air-law-atc/cap06…:30,104` y los mazos EN 01 y 03 `cap06.yml`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md` y de `CHANGELOG-03.md`.

### Alta

#### [NOR-02] El RD 552/2014 está derogado desde el 11-11-2018; la norma vigente es el RD 1180/2018 (H2)

**Categoría:** normativa
**Dimensiones afectadas:** normativa, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap01-derecho-internacional-convenios-acuerdos-y-organizaciones.qmd:82`; `cap05-reglas-del-aire.qmd:16`, `:66`, `:86`; `bibliografia.qmd:13`

> el Real Decreto 552/2014 lo **complementa y desarrolla** en los aspectos que SERA deja a cada Estado. (`cap01:82`)

> En España las fija el **artículo 15 del Real Decreto 552/2014**, que permite volar por debajo de lo establecido en SERA.5005 f) 2) (`cap05:66`)

> En España se aplica mediante el Real Decreto 552/2014. (`bibliografia.qmd:13`)

**Problema:**
- La corrección de la rc.11 acertó en todo el contenido: la ladera no está en SERA, la excepción es de f) 2) y la lista de distancias es la correcta. Pero cita una norma derogada.
- El texto de las excepciones se conserva palabra por palabra en el **art. 33.1 a) y b) del RD 1180/2018**.
- La bibliografía mantiene además la formulación literal de H2 («se aplica mediante»), y eso en los 9 libros.

**Impacto:** el alumno aprende a citar en el examen una norma que no está vigente. La obligación material no cambia.

**Evidencia:**
- RD 1180/2018, disposición derogatoria única, apartado 1: «Se deroga el Real Decreto 552/2014, de 27 de junio, excepto lo dispuesto en su disposición derogatoria y su disposición final primera». Art. 33.1 b): «Los vuelos de entrenamiento de aterrizajes forzosos, podrán operar hasta una altura mínima de 50 m (150 ft)…». https://www.boe.es/buscar/act.php?id=BOE-A-2018-15406
- Análisis del BOE-A-2014-6856: «SE DEROGA con la excepción indicada, por Real Decreto 1180/2018, de 21 de septiembre». https://www.boe.es/buscar/doc.php?id=BOE-A-2014-6856
- Ambas consultadas el 2026-10-01.

**Propuesta:**
- `cap01:82`: «…el Real Decreto 1180/2018 (que derogó el RD 552/2014) lo complementa y desarrolla…».
- `cap05:66`: «En España las fija el **artículo 33 del Real Decreto 1180/2018**…».
- `cap05:16` y `:86`: cambio equivalente.
- Bibliografía: «Directamente aplicable; en España lo desarrolla el Real Decreto 1180/2018», más una entrada propia para el RD 1180/2018.

**Derivados afectados:**
- Anki `cap05.yml:59`: el fundamento cambia, pero el `id` `excepcion-rd-552-2014` se conserva.
- Banco de examen: `c05-q06`, `c05-q09`, `c05-q10`.
- Lección `01-derecho-leccion-05.md:243,378,415`.
- `bibliografia.qmd:13` (`:15` en los libros 06 y 08) de los 9 libros.
- Edición inglesa: `en/01-air-law-atc/cap01…:87`, `cap05…:21,71,91`, `bibliography.qmd:18`, y el mazo EN `cap05.yml`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md` y de los CHANGELOG de los libros cuya bibliografía cambie. La entrada histórica rc.11 no se toca.

#### [TEC-01] «Un planeador siempre tiene prioridad sobre aeronaves de motor»: la jerarquía sólo rige en convergencia

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap01…:85`; `cap05-reglas-del-aire.qmd:32-39`, `:73-77`

> SERA.3210 establece las prioridades de paso para evitar colisiones. Un planeador siempre tiene prioridad sobre aeronaves de motor (aviones, helicópteros), pero debe ceder el paso a globos. (`cap01:85`, dentro de un recuadro de Seguridad)

> **Globo > Planeador > Motor.** Si tiene motor, te cede el paso. Si es un globo, tú cedes. Si vais de frente, **siempre a la derecha**. (`cap05:74-76`)

**Problema:** en SERA.3210, la jerarquía de categorías es la lista de excepciones a la regla de **convergencia** (c) 2)). En los demás supuestos no se aplica:
- de frente, ambas aeronaves viran a la derecha (c) 1));
- quien alcanza a otra se aparta, sea cual sea su categoría (c) 3));
- las aeronaves en vuelo ceden el paso a la que aterriza o está en fase final (c) 4));
- todas ceden a la aeronave con la maniobrabilidad alterada (b)).

El cuerpo del cap05 (`:46-53`) lo explica bien. Lo contradicen el recuadro del cap01 y la regla de oro del propio cap05.

**Impacto:** un piloto de planeador que alcanza a un remolcador, o que se cruza de frente con un avión o con un tráfico a motor en final, puede no apartarse convencido de que tiene la prioridad.

**Evidencia:** Reglamento 923/2012, SERA.3210 b) y c) 1) a 4), texto ES consolidado a 01-05-2025 (CELEX 02012R0923-20250501, Cellar), consultado el 2026-10-01: «Cuando dos aeronaves converjan a un nivel aproximadamente igual, la que tenga a la otra a su derecha cederá el paso, con las siguientes excepciones: i) los aerodinos propulsados mecánicamente cederán el paso a los dirigibles, planeadores y globos…».

**Propuesta:**
- `cap01:85`: «En convergencia, la aeronave de motor cede el paso al planeador y el planeador al globo; pero de frente ambos viran a la derecha, quien alcanza a otro se aparta sea cual sea su categoría, y todos ceden a quien aterriza o tiene la maniobrabilidad alterada. El detalle, en el capítulo 5.»
- `cap05:74-76`: «En convergencia: globo > planeador > dirigible > motor. De frente: ambos a la derecha (en ladera, la convención). Quien aterriza, primero.»

**Derivados afectados:** Anki `cap05.yml:26-29` (`prioridad-y-frente`); `en/01-air-law-atc/cap01…:90` y `cap05`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md`.

#### [NOR-03] Documentación «a bordo»: se atribuye a Part-SAO una obligación que no impone

**Categoría:** normativa
**Dimensiones afectadas:** normativa, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap02-aeronavegabilidad.qmd:53-58`, `:76`; `cap12-seguridad.qmd:28`

> Antes de despegar, comprueba que la documentación obligatoria está a bordo y en vigor.
> Según la normativa de operaciones de planeadores (Part-SAO), esto incluye:
> * **Documentos de la aeronave**: CofA, ARC, Certificado de Matrícula, Seguro, Licencia de Estación de Radio. (`cap02:53-56`)

> * **Documentación**: lleva siempre tu identificación (DNI, licencia). La Guardia Civil o la autoridad del aeropuerto pueden pedírtela en cualquier momento, en zona de aire o de tierra. (`cap12:28`)

**Problema:**
- **Lo que exige llevar a bordo SAO.GEN.155 a):** sólo el AFM, los datos del plan de vuelo si lo hay, las cartas, la documentación pertinente y las señales de interceptación.
- **Lo que puede quedarse en tierra (SAO.GEN.155 c)):** «When not carried on board», la matrícula, el CofA, el ARC, la licencia de radio y el seguro quedan disponibles «at the aerodrome or operating site».
- **Documentación del piloto:** sale de **SFCL.045**, no de Part-SAO. Incluye también el certificado médico y datos del libro de vuelo, y SFCL.045 d) permite dejarla en el aeródromo en vuelos a la vista de este. Por eso el «siempre» del cap12 es falso.
- **Listas de chequeo:** no figuran en SAO.GEN.155.

**Impacto:** el capítulo enseña una obligación que no existe y una fuente que no la contiene. Contradice a `06-procedimientos-operativos/cap01-requisitos-generales.qmd:33,170` y a `08-aeronave-sistemas/cap08-manuales-y-documentos.qmd:35,47`, que están bien. En el banco de examen, la opción correcta según la norma se puntúa como errónea.

**Evidencia:** EASA, Easy Access Rules for Sailplanes (noviembre de 2022; Reg. 2018/1976 consolidado a 15-11-2021):
- SAO.GEN.155 a) y c), p. 37–38: «(c) When not carried on board, all of the following documents… shall remain available at the aerodrome or operating site…: (1) the certificate of registration; (2) the certificate of airworthiness…; (3) the airworthiness review certificate…»;
- SFCL.045, p. 60.

Fuente: https://www.easa.europa.eu/en/downloads/94424/en (consultado el 2026-10-01).

**Propuesta:**
- `cap02:53-58`: «Comprueba que la documentación está en vigor. A bordo debe ir el AFM (o equivalente), las cartas y la información de interceptación (SAO.GEN.155 a)); los certificados de la aeronave —matrícula, CofA, ARC, licencia de radio si lleva equipo, seguro— y el diario de a bordo pueden quedarse en el aeródromo (SAO.GEN.155 c)). Tu licencia, tu certificado médico y tu documento de identidad los llevas encima salvo en vuelos a la vista del aeródromo (SFCL.045).»
- `cap12:28`: «…preséntalos sin demora si te los pide un representante autorizado de la autoridad competente».

**Derivados afectados:**
- resumen `cap02:76`;
- Anki `cap02.yml:48-54` (`tu-parte-en-la-aeronavegabilidad`);
- banco `c02-q09`: enunciado, opción correcta y fundamento, que cita el art. 29 del Convenio de Chicago, aplicable sólo a la navegación internacional;
- `en/…/cap02:56-63,81`, `en/…/cap12`; mazo EN `cap02.yml:52`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md`.

#### [SYL-01] Faltan las atribuciones y la recencia por método de lanzamiento (SFCL.155) en toda la colección

**Categoría:** syllabus
**Dimensiones afectadas:** syllabus, normativa, seguridad
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap04-licencias-de-personal.qmd:34-48`; figura `imagenes/01-cap04-recencia-requisitos.jpg`

> La regla "5 horas - 15 lanzamientos - 2 vuelos" para mantenerte legal.

**Problema:** cumplir SFCL.160 no basta. SFCL.155 limita las atribuciones a los métodos de lanzamiento en los que el piloto se ha formado, y exige recencia **por método**: cinco lanzamientos en dos años, o dos si es con *bungee*. Una búsqueda de `SFCL.155` en los 9 libros, sin contar `en/` ni `_book/`, no devuelve ningún resultado.

**Impacto:** el libro presenta como suficiente un criterio incompleto. Un piloto con 15 lanzamientos en remolque y menos de 5 en torno no puede despegar en torno, aunque cumpla el «5-15-2».

**Evidencia:** EASA, Easy Access Rules for Sailplanes (noviembre de 2022), SFCL.155 a), c) y d) (Reg. 2020/358), p. 93: «(c) In order to maintain the privileges for each launching method… SPL holders shall complete a minimum of five launches during the last two years, except for bungee launch, in which case they shall complete only two launches». Consultado el 2026-10-01.

**Propuesta:** añadir un apartado breve con SFCL.155 a), c) y d), y en la figura de flujo el nodo «¿5 lanzamientos con este método en 24 meses?». Un FI(S) debe validar la redacción.

**Derivados afectados:** resumen `cap04:70`; Anki (tarjeta nueva); figura; banco (pregunta nueva); `en/…/cap04`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md`.

#### [COH-01] La figura de la regla semicircular dibuja la orientación Este-Oeste de SERA, no la Norte-Sur española

**Categoría:** coherencia
**Dimensiones afectadas:** técnica, normativa, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap06…:48`; `imagenes/01-cap06-regla-semicircular.jpg`

> ![Regla semicircular de niveles de crucero VFR (Norte-Sur)](imagenes/01-cap06-regla-semicircular.jpg){#fig-01-cap06-semicircular}

**Problema:**
- La imagen rotula «ESTE 0°-179°» con impares y «OESTE 180°-359°» con pares, que es el apéndice 3 de SERA.
- En España rige 090°–269° impares y 270°–089° pares. El texto lo explica bien y el pie dice «(Norte-Sur)».

**Impacto:** para una derrota de 045°, el texto da pares + 500 (4.500 o 6.500 ft) y la figura da impares + 500 (3.500 o 5.500 ft). Quien memorice la imagen volará al nivel del tráfico opuesto.

**Evidencia:**
- RD 1180/2018, art. 6 y anexo I.
- AIP España ENR 1.7, AMDT 403/26 (19-02-2026): «De 090º a 269º (IMPARES) / De 270º a 089º (PARES)». https://aip.enaire.es/AIP/contenido_AIP/ENR/LE_ENR_1_7_es.pdf
- Inspección visual de la figura. Todo consultado el 2026-10-01.

**Propuesta:** regenerar la figura con el eje Norte-Sur, o retirarla hasta que esté rehecha. La figura la hace Ramón.

**Derivados afectados:** copia de la figura en `en/01-air-law-atc/imagenes/`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md`.

#### [NOR-07] El transpondedor se liga a la clase de espacio aéreo, cuando en España lo exigen FL145, ciertos TMA y las TMZ

**Categoría:** normativa
**Dimensiones afectadas:** normativa, técnica, syllabus
**Severidad:** alta
**Confianza:** moderada
**Verificación:** parcial
**Ubicación:** `cap07-reglamentacion-de-transito-aereo-estructura-del-espacio-aereo.qmd:10`, `:28-31`

> **Requisitos**: Autorización + Radio + Transponder (generalmente). (`cap07:30`, clase D)

**Problema:**
- SERA.6001 no liga el transpondedor a la clase de espacio aéreo.
- En España el AIP lo exige a todas las aeronaves en tres casos:
  - «a FL145 o superior»;
  - dentro de los TMA de Madrid, Zaragoza, Sevilla, Barcelona, Palma, Valencia y Canarias, a cualquier nivel;
  - en las TMZ.
- Siempre «con las excepciones que la Dirección General de Aviación Civil pueda conceder».
- El capítulo promete explicar cuándo hace falta el transpondedor y no da la regla de FL145.

**Impacto:** un piloto en onda por encima de FL145, en clase E o G, cree que no necesita transpondedor. Y a la inversa, cree que toda clase D lo exige.

**Evidencia:** AIP España ENR 1.6, §2.1, WEF 19-03-2026, AIRAC AMDT 02/26. https://aip.enaire.es/AIP/contenido_AIP/ENR/LE_ENR_1_6_es.pdf (consultado el 2026-10-01). No se ha verificado si existen exenciones de la DGAC para planeadores.

**Propuesta:** quitar el transpondedor de la tabla de clases y añadir: «En España el transpondedor es obligatorio a FL145 o superior, dentro de los TMA de Madrid, Zaragoza, Sevilla, Barcelona, Palma, Valencia y Canarias a cualquier nivel, y en las TMZ (AIP ENR 1.6), salvo exención de la DGAC.» Criterio de aceptación: AESA o la DGAC confirman si hay exenciones para planeadores.

**Derivados afectados:** tabla de clases (`cap07:26-33`); figura `01-cap07-clases-espacio-aereo.jpg`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md`.

#### [TEC-02] «El ATC te separa» sin condicionarlo a la clase de espacio aéreo

**Categoría:** técnica
**Dimensiones afectadas:** técnica, pedagogía, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap07…:20`; `cap08-servicio-de-transito-aereo.qmd:10`, `:22-24`, `:41`, `:98`

> Esta es la gran división. En el **controlado**, alguien (ATC) te separa de otros aviones, o al menos te vigila. (`cap07:20`)

> Lo prestan los controladores aéreos (ATCO), y de ellos recibes **autorizaciones** (instrucciones obligatorias) e información de tráfico. La responsabilidad de que no choques, bajo ciertas reglas, es del controlador. (`cap08:24`)

> * **ATC**: "Vire rumbo 360 por tráfico". (Orden obligatoria, ellos te separan). (`cap08:41`)

**Problema:**
- En las clases en que vuela un planeador, el ATC nunca separa a un VFR de otros VFR. En clase C sólo lo separa del IFR. En clase D no lo separa de nadie, como dice la propia tabla de `cap07:30`.
- Por SERA.3201, evitar la colisión sigue siendo siempre responsabilidad del piloto.
- El libro 09 dice lo contrario (`09-navegacion/cap07-uso-de-ats.qmd:95`: «nadie te separa de nada»), y lo mismo la pregunta de examen `c07-q04`.

**Impacto:** en un CTR de clase D, que es lo habitual en España, el alumno puede relajar el «ver y evitar» creyendo que el controlador lo separa.

**Evidencia:** Reglamento 923/2012, Apéndice 4 (para la clase D, separación del VFR: «Ninguna»; para la clase C: «VFR de IFR») y SERA.3201: «Ninguna de las disposiciones … eximirá al piloto al mando … de evitar una colisión». Texto consolidado a 01-05-2025, https://publications.europa.eu/resource/celex/02012R0923-20250501.SPA.xhtml (consultado el 2026-10-01).

**Propuesta:** `cap08:24`: «El ATC separa según la clase de espacio: al VFR sólo del IFR y sólo en clase C; en clase D recibes autorizaciones e información de tráfico, pero de otros VFR te separas tú. Evitar la colisión es siempre responsabilidad del piloto (SERA.3201).» Ajustar `cap07:20`, `cap08:10,41,98` y escribir «autorizaciones e instrucciones» en lugar de «autorizaciones (instrucciones obligatorias)».

**Derivados afectados:**
- resumen `cap08:98`;
- Anki `cap08.yml`: `atc-fis-alrs`, `informacion-de-trafico-no-es-separacion`;
- `en/01-air-law-atc/cap07…`, `cap08…:15,27,46,103`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md`.

#### [NOR-04] La CIAIAC fue suprimida el 15-07-2026 y el libro la presenta como vigente

**Categoría:** normativa
**Dimensiones afectadas:** normativa, coherencia
**Severidad:** alta (dato institucional obsoleto)
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap13-notificacion-de-accidentes.qmd:10`, `:32`, `:35`, `:47`, `:55`; `glosario.qmd:95-96`

> 1. **CIAIAC** (Comisión de Investigación): investiga las causas técnicas, para que no vuelva a pasar.

**Problema:**
- Al constituirse la Autoridad Administrativa Independiente para la Investigación Técnica de Accidentes e Incidentes ferroviarios, marítimos y de aviación civil (Ley 2/2024; Estatuto aprobado por el RD 141/2026), la CIAIAC quedó extinguida.
- Esa constitución se produjo en la sesión del Consejo del 15-07-2026.
- La rc.14 se publicó el 7 de agosto.

**Impacto:** el libro enseña como vigente un organismo suprimido. En la práctica el canal de notificación sigue funcionando (web, teléfono y correo del Ministerio).

**Evidencia:**
- Ley 2/2024 (BOE-A-2024-15937), disposición adicional primera: «1. La constitución de la Autoridad implicará la extinción de … la Comisión de Investigación de Accidentes e Incidentes de Aviación Civil. 2. … las referencias que la legislación vigente contiene relativas a las Comisiones citadas … se entenderán realizadas a la Autoridad». https://www.boe.es/buscar/act.php?id=BOE-A-2024-15937
- Ministerio de Transportes: «En fecha 15 de julio de 2026 se ha celebrado la sesión constitutiva del Consejo … A partir de dicha fecha quedan suprimidas … la Comisión de Investigación de Accidentes e Incidentes de Aviación Civil (CIAIAC)». https://www.transportes.gob.es/organos-colegiados/ciaiac
- Ambas consultadas el 2026-10-01.

**Propuesta:** «la autoridad de investigación de accidentes: la Autoridad Administrativa Independiente para la Investigación Técnica de Accidentes e Incidentes ferroviarios, marítimos y de aviación civil, que el 15 de julio de 2026 sustituyó a la CIAIAC». La sigla oficial está pendiente de confirmar: la web del Ministerio usa «AITAT».

**Derivados afectados:**
- `glosario.qmd:95-96`, que debe marcarla como suprimida y añadir la nueva entrada;
- Anki `cap13.yml:26-42`;
- banco de examen: `c13-q04` (respuesta correcta «A la CIAIAC, sin demora»), `c01-q03` y `c14-q04/q05/q06` (distractores o fundamentos);
- lecciones `01-derecho-leccion-01.md:103`, `-13.md:147,165,208` y `-14.md:147,218,235`;
- edición inglesa: `en/…/cap13…:15,37,40,52,60`, `en/…/glossary.qmd:100`, mazo EN `cap13.yml:28,38`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md`.

#### [NOR-05] La notificación obligatoria no se limita a accidentes e incidentes graves

**Categoría:** normativa
**Dimensiones afectadas:** normativa, syllabus
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap13…:27-28`; figura `imagenes/01-cap13-flujo-notificacion.jpg` (`:41`)

> * **Notificación obligatoria**: todos los accidentes e incidentes graves deben notificarse.
> * **Notificación voluntaria**: si te pasa algo que no es obligatorio reportar pero crees que otros pueden aprender de ello, repórtalo igualmente.

**Problema:**
- El Reglamento 376/2014 (art. 4.1 y 4.6 a)) obliga al piloto al mando a notificar los sucesos de la lista de clasificación.
- Para planeadores, esa lista es el anexo V, sección 2, del Reglamento 2015/1018. Incluye sucesos que no son incidentes graves: violaciones de espacio aéreo, quedarse sin zona de aterrizaje segura, sueltas de cable que pongan en peligro el planeador y cuasicolisiones con maniobra evasiva.
- La figura dice «¿Grave/accidente? NO → NOTIFICACIÓN VOLUNTARIA».
- El plazo de 72 h para las personas físicas se cuenta «desde el momento en que hayan tenido conocimiento del suceso» (art. 4.7).

**Impacto:** el alumno cree que una violación de espacio aéreo sin consecuencias no se notifica. No notificar es infracción leve (LSA, art. 50).

**Evidencia:**
- Reglamento 376/2014, arts. 4.1, 4.6 y 4.7, consolidado a 11-09-2018.
- Reglamento de Ejecución 2015/1018, anexo V, sección 2, consolidado a 17-08-2026 (modificado por el Reglamento 2026/1821).
- AESA, «¿Quién debe notificar?»: «En caso de no pertenecer a ninguna organización, deberán notificar directamente a AESA también en un plazo de 72 horas». https://www.seguridadaerea.gob.es/es/ambitos/gestion-de-la-seguridad-operacional/sistema-de-notificacion-de-sucesos/quien-debe-notificar
- Todo consultado el 2026-10-01.

**Propuesta:** «**Notificación obligatoria**: los accidentes e incidentes graves y, además, los sucesos de la lista del Reglamento de Ejecución (UE) 2015/1018 (anexo V, sección 2, planeadores): por ejemplo, una violación de espacio aéreo, una suelta del cable que haya puesto en peligro el planeador, una cuasicolisión que exija maniobra evasiva o quedarte sin ningún campo seguro donde aterrizar. Plazo: 72 horas desde que tienes conocimiento del suceso, por el sistema de tu organización o, si no perteneces a ninguna, al SNS de AESA.»

**Derivados afectados:** figura del flujo (rama «NO» y las 72 h aplicadas sólo al accidente); Anki `cap13.yml` (conviene una tarjeta nueva con la lista); `en/…/cap13…:32-33`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md`.

#### [NOR-06] El catálogo de infracciones no corresponde a la LSA, y la figura lo contradice

**Categoría:** normativa
**Dimensiones afectadas:** normativa, coherencia
**Severidad:** alta
**Confianza:** alta
**Verificación:** confirmado
**Ubicación:** `cap14-derecho-nacional.qmd:33-52`; figura `imagenes/01-cap14-escala-infracciones.jpg` (`:54`)

> ### Infracciones graves
>
> * Volar sin licencia válida para el tipo de aeronave.
> […]
> ### Infracciones muy graves
>
> * Volar bajo los efectos del **alcohol o drogas**.
> * **Negligencia grave** que cause un accidente o la muerte de una persona.
> * Operar una aeronave sin **Certificado de Aeronavegabilidad** válido.
> * **Falsificar** títulos, licencias o documentación aeronáutica.

**Problema:**
- **Cómo gradúa la LSA las infracciones del piloto:** no las clasifica conducta a conducta. Incumplir las obligaciones del título IV es infracción **leve**. Esas obligaciones incluyen tener título válido, abstenerse de volar con la capacidad disminuida, operar una aeronave aeronavegable, llevar la documentación y tener el seguro. La infracción pasa a **grave** si causa un incidente grave, lesiones graves o daños de 5.000 a 15.000 €, y a **muy grave** si causa un accidente, una muerte o daños de más de 15.000 € (art. 44).
- **Las tres listas del capítulo no salen de la ley.**
- **Contradicciones de la figura:** pone la licencia o el médico caducados como leve y el vuelo sin licencia o sin CofA como muy grave.
- **Alcohol:** volar bajo sus efectos es además **delito** (Ley 209/1964, art. 31).
- **Cuantías:** las de la figura son correctas para particulares (art. 55.1), pero falta la escala del art. 55.2.

**Impacto:** es el resultado de aprendizaje central del capítulo (`:11`) y es falso. Además rebaja la gravedad del alcohol.

**Evidencia:**
- Ley 21/2003 (BOE-A-2003-13616), consolidada (última actualización publicada el 30-09-2025), art. 44.1: «El incumplimiento de las obligaciones establecidas en el título IV de esta ley … constituirá infracción leve, salvo que … se produzca alguna circunstancia especial … que lo califique como infracción grave o muy grave». Art. 44.2 a)-c) y 44.3. https://www.boe.es/buscar/act.php?id=BOE-A-2003-13616
- Ley 209/1964, art. 31 (BOE-A-1964-21509).
- Ambas consultadas el 2026-10-01.

**Propuesta:** sustituir las tres listas por un párrafo con la estructura del art. 44, las conductas tipificadas aparte (art. 50 sobre notificación e investigación; art. 48.3 sobre el acceso a zonas restringidas de aeropuertos), las cuantías del art. 55.1 y la remisión penal de la Ley 209/1964. El texto completo propuesto por el revisor del bloque 12–14 está disponible y verificado. Rehacer la figura con esa estructura.

**Derivados afectados:**
- figura;
- `en/…/cap14-national-law.qmd:52` y siguientes;
- candidatos con la misma idea en otros libros, que hay que revisar allí: `04-comunicaciones/cap06…:18`, `04-comunicaciones/cap03…:126` con Anki 04 `cap03.yml:85`, y `03-meteorologia/cap06…:49` con Anki 03 `cap06.yml:62`.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md`.

### Media

#### [COH-02] Remisiones rotas al libro 04 tras su renumeración del 16-07-2026

- **Categoría:** coherencia
- **Dimensiones:** coherencia, pedagogía
- **Severidad:** media
- **Confianza:** alta
- **Verificación:** confirmado
- **Ubicación:**
  - `cap06…:94`: «Libro 4 — Comunicaciones (cap. 3)», para el plan de vuelo;
  - `cap07…:63`: «Libro 4 (*Comunicaciones*), capítulo 8», para la interceptación;
  - `cap08…:63` y `cap10…:33`: «Libro 4 — Comunicaciones, capítulo 7», para las señales luminosas.

> Las señales de interceptación y el procedimiento de respuesta (SERA.11015) se estudian en el Libro 4 (*Comunicaciones*), capítulo 8. (`cap07:63`)

**Problema:** el commit `a80eda3` fusionó capítulos del libro 04, y las remisiones quedaron apuntando a la numeración antigua. Dónde está ahora cada contenido:

| Contenido | Capítulo actual | Fichero |
| --- | --- | --- |
| Plan de vuelo (FPL) | cap. 2 | `04-comunicaciones/cap02-comunicaciones-vfr.qmd:146` |
| Señales luminosas | cap. 5 | `04-comunicaciones/cap05-acciones-ante-fallo-de-comunicaciones.qmd:30` |
| Interceptación | cap. 6 | `04-comunicaciones/cap06-procedimientos-de-socorro-y-urgencia.qmd:66` |

El libro 04 sólo tiene 7 capítulos. Las remisiones a los libros 07 (cap04) y 09 (cap07) son correctas.

**Impacto:** el alumno no encuentra el contenido al que se le envía, y en un caso es un procedimiento de seguridad (la interceptación).

**Evidencia:** `04-comunicaciones/_quarto.yml:21-27`; `git show a80eda3`.

**Propuesta:** cambiar a «cap. 2» en `cap06:94`, «capítulo 6» en `cap07:63` y «capítulo 5» en `cap08:63` y `cap10:33`.

**Derivados afectados:**
- `06-procedimientos-operativos/cap01-requisitos-generales.qmd:31` («capítulo 8»);
- `en/…/cap06:99`, `cap07:68`, `cap08:68`, `cap10:38`.
- El comentario en `tools/anki/mazos/01-derecho-aereo-atc/cap07.yml:103` es material de origen y no es canónico.

**Acción editorial al aplicar:** añadir una descripción en `[En curso]` de `CHANGELOG-01.md` y de `CHANGELOG-06.md`.

#### [NOR-08] SERA.5005 f) 2) aparece incompleto: falta el obstáculo más alto en un radio de 150 m

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap05…:62` (y `:86`).

> 2. **150 m** sobre tierra o agua, en campo abierto.

**Problema:** SERA.5005 f) 2) añade «o 150 m (500 ft) sobre el obstáculo más alto situado dentro de un radio de 150 m (500 ft) desde la aeronave». Con el texto actual, volar a 150 m sobre el suelo junto a una antena de 100 m parece legal, y no lo es.

**Evidencia:** SERA.5005 f) 2), consolidado a 01-05-2025.

**Propuesta:** «2. **150 m (500 ft)** sobre tierra o agua, o sobre el obstáculo más alto en un radio de 150 m, fuera de aglomeraciones.»

**Derivados:** resumen; Anki `cap05.yml:44-48`; figura `01-cap05-alturas-minimas.jpg` (los 300 m urbanos se miden desde una azotea baja).

#### [NOR-09] Aterrizajes forzosos: faltan condiciones del art. 33.1 b) y la conversión «150 ft» queda sin nota (H1)

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap05…:69`.

> * **Entrenamiento de aterrizajes forzosos**: se puede bajar hasta **50 m (150 ft)**, manteniendo 150 m respecto de cualquier persona, vehículo o embarcación que se encuentre en la superficie y de todo obstáculo artificial (@fig-01-cap05-alturas-minimas).

**Problema:**
- Faltan dos condiciones de la norma: «siempre que no representen ningún riesgo o molestias para las personas o bienes en la superficie» y «las condiciones que resulten del estudio de seguridad que haya realizado el operador».
- La cifra «50 m (150 ft)» es literal de la norma, pero 50 m son 164 ft.
- La remisión apunta a una figura que no muestra aterrizajes forzosos.

**Evidencia:** RD 1180/2018, art. 33.1 b) (véase NOR-02).

**Propuesta:** «…hasta **50 m** (la norma dice «50 m (150 ft)»; en rigor, 164 ft), sin riesgo ni molestias para personas o bienes, a 150 m de…, y con las condiciones del estudio de seguridad del operador (tu escuela).»

**Derivados:** resumen; Anki `cap05.yml:54-57`; banco `c05-q10`.

#### [TEC-03] La figura de alturas mínimas pone al planeador de ladera en sotavento

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap05…:71`, `imagenes/01-cap05-alturas-minimas.jpg`.

**Problema:** en la viñeta «EXCEPCIÓN: VUELO DE LADERA», el aire asciende por la izquierda y desciende por la derecha, y el planeador está a la derecha, en la descendencia. La figura enseña a volar ladera en la zona de rotor. La otra figura de ladera del mismo capítulo (`01-cap05-preferencias-paso-ladera.jpeg`) sí sitúa bien a los planeadores, a barlovento.

**Evidencia:** FAA, *Glider Flying Handbook*, FAA-H-8083-13B, cap. 9, fig. 9-18: «While the flow deflects upward on the windward side of a ridge, it deflects downward on the lee side». Fuente secundaria técnica.

**Propuesta:** invertir el planeador o el viento, medir los 300 m desde el edificio más alto y añadir la viñeta de aterrizajes forzosos o retirar la remisión.

#### [TEC-04] Banda VMC baja: falta «de ambos valores el mayor»

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap06…:18` (y `:99`).

> ### Por debajo de 3.000 ft AMSL (o 1.000 ft AGL)

**Problema:** SERA dice «A 900 m (3 000 ft) AMSL o por debajo, o a 300 m (1 000 ft) sobre el terreno, de ambos valores el mayor». Sobre la meseta, con el terreno a unos 800 m (2.625 ft), la banda llega a 3.625 ft AMSL.

**Evidencia:** SERA.5001, tabla S5-1.

**Propuesta:** «A 3.000 ft AMSL o por debajo, o a 1.000 ft sobre el terreno si este valor es mayor».

**Derivados:** Anki `cap06.yml:23`; figura `01-cap06-minimos-vmc.jpg`; `03-meteorologia/cap06…:49`.

#### [NOR-10] El AMC1 SAO.OP.150 (oxígeno) se presenta como obligación

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap06…:74`, `:77`.

> **AMC1 SAO.OP.150:** El piloto al mando debe asegurarse de que todos los ocupantes utilicen oxígeno suplementario siempre que la altitud de presión sea superior a los **10.000 ft**

**Problema:** el AMC dice «he or she *should* ensure». Es un medio aceptable de cumplimiento, no una disposición vinculante. El resumen (`:102`) sí lo presenta bien, como «regla por defecto».

**Evidencia:** EAR for Sailplanes, AMC1 SAO.OP.150 (ED Decision 2019/001/R).

**Propuesta:** «…el AMC1 establece como medio aceptable que **debería** garantizar su uso por encima de 10.000 ft de altitud de presión.»

**Derivados:** `02-factores-humanos/cap04-uso-de-oxigeno.qmd:127`; `08-aeronave-sistemas/cap14…:36`.

#### [NOR-11] A SAO.IDE.105 b) le falta su primera condición: vuelo sin referencia visual

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap06…:89`, `:92`, `:104`.

**Problema:**
- La norma exige los instrumentos de b) también cuando el planeador «no se pueda mantener en la trayectoria de vuelo deseada sin referirse a uno o más instrumentos adicionales». El GM1 lo ilustra con VMC sin horizonte: sobre mar, desierto o nieve.
- La norma habla de «planeadores motorizados», no sólo de TMG.

**Evidencia:** Reg. 2018/1976, SAO.IDE.105 b); GM1 SAO.IDE.105(b).

**Propuesta:** añadir la condición y sustituir «TMG» por «planeadores motorizados».

#### [TEC-05] Los ejemplos de zonas R y D contradicen su descripción genérica

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap07…:57-58`, `:60`.

> Normalmente se puede pasar si está inactiva o con permiso especial (parques naturales, zonas de maniobras militares).

**Problema:**
- LER170 (Monfragüe), citada en la figura, es permanente y prohíbe el sobrevuelo salvo excepciones autorizadas.
- LED125 exige coordinación previa con la BA de Talavera.

**Evidencia:** AIP España ENR 5.1, entradas LER170 (WEF 02-10-2025) y LED125 (WEF 07-08-2025), consultadas el 2026-10-01.

**Propuesta:**
- R: «las condiciones están en ENR 5.1; algunas son permanentes y prohíben el sobrevuelo (p. ej., LER170)».
- D: «lee sus observaciones: algunas exigen coordinación previa (LED125)».
- Fechar el recorte de carta de la figura.

#### [NOR-12] Fases de emergencia: un criterio de INCERFA que la norma no contiene y un reparto de avisos inexacto

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap08…:49-54`.

> Se declara reglamentariamente ante cualquiera de estas tres situaciones: […]

**Problema:**
- ATS.TR.405 a) 1) sólo contempla dos supuestos de INCERFA. La «duda sobre la seguridad» es la definición de la fase, no un criterio de declaración.
- El reloj de la comunicación es «la posterior», no «lo que ocurra primero».
- El RCC recibe aviso desde INCERFA, no a partir de ALERFA.
- Faltan los criterios de ALERFA (5 min tras la autorización de aterrizaje) y de DETRESFA (aterrizaje forzoso), que es el caso típico del planeador.
- En `:55`, «y necesitan ayuda» debería ser «o necesitan asistencia».

**Evidencia:** Reg. 2017/373, anexo IV, ATS.TR.405 a) 1)-3) y art. 2 (definiciones), consolidado a 22-02-2026. https://publications.europa.eu/resource/celex/02017R0373-20260222.SPA.xhtml (consultado el 2026-10-01).

**Propuesta:** sustituir el tercer supuesto por la salvedad «no se declara si no existe ninguna duda sobre la seguridad», dar los criterios de ALERFA y DETRESFA, citar ATS.TR.405 y cambiar «y» por «o» en DETRESFA.

**Derivados:**
- figura `01-cap08-fases-emergencia.jpg` (en ALERFA, «Se activan recursos»);
- `cap11:31-33,68`;
- glosario (DETRESFA);
- Anki `fases-de-emergencia-sar`;
- `en/`.

#### [SYL-02] Falta el AFIS entre las dependencias ATS

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap08…:26-30`, `:36`.

> Se organiza en tres dependencias … Torre … Aproximación … Centro de Control de Área

**Problema:**
- El AFIS no aparece en todo el libro. Es la dependencia que presta información y alerta en aeródromos con FIZ, como Burgos, Córdoba o La Seu.
- Tampoco se dice que el FIS en ruta lo presta el ACC, salvo en Canarias, donde lo presta el FIC.

**Evidencia:** AIP España GEN 3.3, AMDT 411/26 (01-10-2026), §3. https://aip.enaire.es/AIP/contenido_AIP/GEN/LE_GEN_3_3_es.pdf

**Propuesta:** añadir «**AFIS**: información y alerta en algunos aeródromos no controlados y su FIZ; no autoriza ni separa» y «el FIS en ruta lo presta el ACC (Canarias: FIC)».

**Derivados:** glosario (sin AFIS ni FIZ).

#### [SYL-03] Faltan los SUP y los PIB: las «tres fuentes» de información son cinco

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap09-servicios-de-informacion-aeronautica-ais.qmd:9`, `:17-43`, `:52-56`.

> Las tres fuentes de información: AIP (permanente), NOTAM (urgente) y AIC (informativo).

**Problema:**
- Los cambios temporales de tres meses o más se publican como SUP, frecuentes en vuelo a vela (campeonatos, zonas temporales).
- Los NOTAM se consultan en la práctica a través del PIB.
- El ciclo AIRAC no lleva su cifra (28 días), y el AIP se organiza en tres «partes», no en tres «volúmenes».

**Evidencia:** Reg. 2017/373, AIS.OR.315 a); AIP GEN 3.1, AMDT 408/26, §3.2, §3.4 y §4. https://aip.enaire.es/AIP/contenido_AIP/GEN/LE_GEN_3_1_es.pdf (consultado el 2026-10-01).

**Propuesta:** un apartado breve sobre los SUP, una frase sobre el PIB y la cifra de 28 días del AIRAC.

**Derivados:** resumen; glosario; Anki.

#### [TEC-06] Mancuerna: «SOLO en pistas y calles pavimentadas … No pises la hierba»

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap10-aerodromos-y-campos-de-despegue-externos.qmd:43`; figura `01-cap10-senales-aerodromo.png`.

> | **Mancuerna (Pesas)** | (Blanca). Aterrizaje, despegue y rodaje **SOLO en pistas y calles pavimentadas**. No pises la hierba. |

**Problema:** SERA no habla de pavimento. En un campo de vuelo a vela con pista de hierba, la señal obliga a usar las pistas y calles designadas, que pueden ser de hierba.

**Evidencia:** SERA, apéndice 1, 3.2.3.1: «…únicamente en las pistas y en las calles de rodaje».

**Propuesta:** «…únicamente en las pistas y calles de rodaje. Con una barra negra en cada círculo: aterrizar y despegar sólo en pista; el resto de maniobras, libre».

**Derivados:** figura; `en/…/cap10:48`.

#### [SYL-04] Faltan señales de tierra de SERA, apéndice 1, apartado 3.2

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap10…:35-44`.

**Problema:** faltan cuatro señales, y ningún otro libro de la colección las trata:
- las cruces sobre pistas o calles cerradas (3.2.4.1), que son relevantes para la seguridad;
- la mancuerna con barras (3.2.3.2);
- el grupo de dos cifras de la dirección de despegue (3.2.5.2);
- la «C» de la oficina de notificación ATS (3.2.7.1).

**Propuesta:** añadir cuatro filas a la tabla y citar «SERA, Apéndice 1, 3.2».

**Derivados:** figura; resumen; Anki `area-de-senales`.

#### [NOR-13] Campos externos y tomas fuera de campo: la sección legal no tiene base normativa (H9)

- **Severidad:** media. **Confianza:** moderada. **Verificación:** parcial.
- **Ubicación:** `cap10…:54-58`.

> además de cumplir las condiciones que fije la normativa nacional para vuelos fuera de aeródromo

**Problema:** la sección añadida desde julio no nombra ninguna norma. Las aplicables son:
- **Part-SAO:** define el lugar de operación (*operating site*). SAO.OP.100 exige que sea adecuado, y el GM1 SAO.OP.100 define la toma fuera de campo (*outlanding*).
- **En España, el aeródromo eventual (RD 1189/2011, arts. 2 b) y 16):** como máximo 40 operaciones al año y 15 al mes, con autorización de la comunidad autónoma.
- **Aviso de llegada (SERA.4020 c)):** obligatorio si se presentó plan de vuelo.
- **Responsabilidad del operador (Ley 48/1960, art. 120)** y seguro obligatorio (Reglamento 785/2004, art. 2.2 g)).

**Evidencia:**
- EAR for Sailplanes (definición 7, SAO.OP.100, GM1);
- BOE, RD 1189/2011 (https://www.boe.es/buscar/act.php?id=BOE-A-2011-14118);
- BOE, Ley 48/1960 (https://www.boe.es/buscar/act.php?id=BOE-A-1960-10905);
- SERA.4020 c).

Todo consultado el 2026-10-01.

**Propuesta:** citar Part-SAO y el RD 1189/2011, añadir el aviso de llegada con remisión al libro 07 (cap04) y precisar «respondes tú o el operador del planeador». Queda pendiente de experto el régimen del despegue ocasional tras una toma fuera de campo y la fuente exacta del «consentimiento del propietario».

**Derivados:** apertura; resumen; Anki; `en/…/cap10:59-63`.

#### [COH-03] «Altura mínima de inicio: 150 m» del tramo base, presentada como límite

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap10…:24` (y `:19`).

> 2. **Tramo base**: viras 90º hacia la pista y haces el último ajuste de altura y velocidad. Altura mínima de inicio: 150 m.

**Problema:** ni SERA ni Part-SAO fijan esa altura. El libro 06 la llama «altura recomendada» (`06-procedimientos-operativos/cap04…:23`). Es un criterio de instrucción.

**Propuesta:** «Referencia habitual al iniciar la base: unos 150 m (criterio de instrucción; ver libro 6, cap04)». Debe validarlo un FI(S).

#### [PED-01] Capítulo 10: la apertura y el resumen no coinciden con el contenido

- **Severidad:** media. **Verificación:** no aplicable.
- **Ubicación:** `cap10…:9-11`, `:60-67`.

**Problema:** la apertura promete «Normas básicas para moverse por el aeródromo», que no se desarrollan. La sección de campos externos, que es la mitad del título del epígrafe, no aparece en la apertura, en el resumen ni en Anki.

**Propuesta:** sustituir la tercera viñeta de la apertura por «La cara legal de los campos externos y las tomas fuera de campo» y añadir una viñeta al resumen.

#### [TEC-07] El ARCC de Palma no cubre sólo «el Mediterráneo y Baleares»

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap11-busqueda-y-salvamento.qmd:21-23`.

> 3. **RCC Palma** (Base Aérea de Son San Juan): cubre el Mediterráneo y Baleares.

**Problema:** la región SAR de Baleares coincide con la FIR Barcelona más Andorra. Incluye tierra peninsular: Cataluña, la Comunidad Valenciana y el este de Aragón. Quien vuela en Cataluña depende de Palma.

**Evidencia:** AIP España GEN 3.6, AMDT 398/25, §2.1–2.3: «Los límites de la SRR Baleares se corresponden con los del FIR BARCELONA, más el territorio del Principado de Andorra». https://aip.enaire.es/AIP/contenido_AIP/GEN/LE_GEN_3_6_es.pdf (consultado el 2026-10-01).

**Propuesta:** «Madrid: la FIR Madrid. Palma: la FIR Barcelona (nordeste peninsular y Levante), Baleares y Andorra. Canarias: la FIR Canarias». El AIP los denomina ARCC.

#### [SYL-05] El texto no trata las balizas ELT/PLB ni Cospas-Sarsat, aunque la figura las muestra

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap11…:33-35`; figura `01-cap11-actuacion-accidente.jpg`.

**Problema:** la figura muestra «baliza ELT → COSPAS-SARSAT → RCC», pero el texto no dice nada de balizas. Faltan tres datos:
- sólo la frecuencia de 406 MHz se detecta por satélite desde 2009;
- la de 121,5 MHz queda para la localización final;
- AMC1 SAO.IDE.125 pide ELT o PLB en zonas donde el SAR sería especialmente difícil.

**Evidencia:**
- Cospas-Sarsat, *121.5 phase-out*: «ceased satellite processing of 121.5/243 MHz beacons on 1 February 2009» (https://www.cospas-sarsat.int/en/21-embedded-articles/165-1215-phase-out);
- AMC1 SAO.IDE.125.

Consultados el 2026-10-01.

**Propuesta:** un párrafo breve sobre las balizas, su registro y la doble frecuencia, con remisión a la figura.

**Derivados:** glosario (ELT); Anki.

#### [COH-04] La figura del ARC marca como «caducado» el tercer año

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap02…:37`, `imagenes/01-cap02-ciclo-arc.jpg`.

**Problema:** el tramo válido termina en la segunda prórroga («2 AÑOS»), y entre «2 AÑOS» y «3 AÑOS» la figura pone «CADUCADO». El texto (`:31`, «1 año + 1 año + 1 año») está bien.

**Evidencia:** Reglamento 1321/2014, ML.A.902 a), consolidado a 07-08-2026: «Un CRA tendrá una validez de un año y podrá prorrogarse por un año más, con un máximo de dos prórrogas consecutivas».

**Propuesta:** extender el tramo válido hasta «3 AÑOS».

#### [TEC-08] Defectos de la aeronave: falta la regla de no volar

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap02…:60-62`.

> Si encuentras algo mal durante la pre-vuelo o durante el vuelo, anótalo en el **Technical Log Book (Diario de a bordo)**. El siguiente piloto te lo agradecerá.

**Problema:** presenta el reporte como una cortesía y omite que un defecto que ponga seriamente en peligro la seguridad debe rectificarse antes del vuelo. Además, confunde el *technical log* con el *journey log*.

**Evidencia:** Reg. 1321/2014, ML.A.403 a), consolidado a 07-08-2026: «Cualquier defecto de la aeronave que ponga en peligro seriamente la seguridad del vuelo debe rectificarse antes del vuelo»; SAO.GEN.130 m).

**Propuesta:** añadir «Si el defecto puede afectar a la seguridad, el planeador no vuela hasta que lo evalúe quien pueda hacerlo (ML.A.403)» y escribir «diario de a bordo (*journey log*) o registro técnico».

**Derivados:** Anki `cap02.yml:48-54`.

#### [NOR-14] El seguro como consecuencia automática: corregido en el cuerpo del cap02 (H4), persiste en Anki y reaparece en el cap04

- **Severidad:** media. **Confianza:** moderada. **Verificación:** no verificable.
- **Ubicación:** `cap02…:34`; `tools/anki/mazos/01-derecho-aereo-atc/cap02.yml:34-35`; `cap04…:60`.

> El incumplimiento implica sanción y pérdida de cobertura del seguro. (`cap04:60`, dentro de un recuadro de Normativa)

**Problema:**
- El cuerpo del cap02 ya está matizado, aunque «la mayoría de las pólizas» no tiene fuente.
- La tarjeta Anki vuelve a ser categórica: «la aseguradora rechazará la cobertura».
- En `cap04:60`, SFCL.115 no dice nada de seguros, y la frase va en un recuadro de Normativa.
- El seguro de responsabilidad frente a terceros (Reglamento 785/2004) responde ante las víctimas. La repetición contra el asegurado depende de cada póliza.

**Propuesta:** «la aseguradora puede negarse a cubrirte o repetir contra ti, según la póliza». Sacar la frase del recuadro de Normativa del cap04.

**Derivados:** mazos EN `cap02.yml:34` y `cap04.yml:42`; `08-aeronave-sistemas/cap08…:74`.

#### [COH-05] «Bajo las alas en algunos casos» contradice el cuerpo y la norma

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap03-marcas-de-nacionalidad-y-matricula-de-aeronaves.qmd:62` (el cuerpo correcto está en `:29-30`).

> * **Marcas pintadas**: en el fuselaje o la cola (y bajo las alas en algunos casos), más la bandera de España.

**Evidencia:** Orden FOM/1687/2015, anexo II, A) 2: «En los aerodinos las marcas se ostentarán, una sola vez, en el intradós del ala… Además, las marcas deberán aparecer a cada lado del fuselaje… o en las mitades superiores de las superficies verticales de cola». https://www.boe.es/buscar/act.php?id=BOE-A-2015-8940 (consolidada a 05-01-2023; consultada el 2026-10-01).

**Propuesta:** «**Marcas pintadas**: una vez en el intradós del ala y además en ambos costados del fuselaje o en la cola, más la bandera de España.»

**Derivados:** Anki `cap03.yml:31-36`; banco `c03-q02`; `en/…/cap03:67`.

#### [COH-06] La figura de ubicación de la matrícula contradice el texto

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap03…:34`, `imagenes/01-cap03-ubicacion-matricula.jpg`.

**Problema:**
- «EC-ABC» aparece en el extradós, no en el intradós.
- La bandera lleva el rótulo «NACIONALIDAD», cuando la marca de nacionalidad es «EC».
- El «CÓDIGO DE COMPETENCIA» se describe como «letras del club u operador».

**Propuesta:** marca bajo el ala, rótulos correctos, y quitar o corregir el distintivo de competición.

#### [NOR-15] La norma española de marcas no se identifica, y no se recoge el RD 1029/2025

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap03…:17`, `:27`, `:50`.

> En España, la marca de nacionalidad es `EC`, seguida de un guion y tres letras

**Problema:**
- No se cita la Orden FOM/1687/2015.
- El RD 1029/2025 (BOE-A-2025-22950), en vigor desde el 03-12-2025, derogó el RD 384/2015. Fija «EC, seguido, tras un guion, por 4 letras» (art. 4.1), aunque se siguen asignando tres letras mientras queden series (disposición adicional segunda).
- La Orden permite una franja con los colores nacionales o la propia bandera, con condiciones distintas para cada una.

**Propuesta:** «EC- seguido, de momento, de tres letras (el RD 1029/2025 prevé cuatro cuando se agoten las series)», citar la Orden y reformular `:50` con la alternativa franja o bandera.

**Derivados:** Anki `matricula-espanola`; banco `c03-q01`; `en/…/cap03:22,55`.

#### [TEC-09] «Motoveleros» como atribución directa de la SPL

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap04…:18`.

> Te da derecho a actuar como piloto al mando (PIC) en planeadores y motoveleros

**Problema:** SFCL.115 a) dice «Subject to compliance with point SFCL.150». Si la prueba de pericia se hizo en planeador, las atribuciones excluyen los TMG hasta completar su formación (SFCL.150 a) y b)). El glosario llama al TMG «Motovelero de turismo», y la edición inglesa lo hace explícito: «sailplanes and touring motor gliders».

**Propuesta:** «…en planeadores, incluidos los planeadores con motor; para los motoveleros de turismo (TMG) necesitas extender las atribuciones (SFCL.150), y su recencia es distinta (SFCL.160 b))».

**Derivados:** `en/…/cap04:23`, con más prioridad que el español.

#### [PED-02] Se promete comparar el médico LAPL con la Clase 2 y sólo se explica el LAPL

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap04…:10`, `:26`.

> Las diferencias entre el certificado médico LAPL y el Clase 2, y cuánto duran.

**Problema:** no se dice cuándo hace falta la Clase 2 (MED.A.030 c) 4)) ni cuál es su validez (MED.A.045 a) 3)).

**Propuesta:** una frase con esos datos, o rebajar la promesa de la apertura.

#### [NOR-16] Mercancías peligrosas: la excepción de SAO.GEN.150 está mal descrita y falta el deber del piloto al mando

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado. Los ejemplos concretos requieren experto.
- **Ubicación:** `cap12…:32`, `:47`.

> Se admiten cantidades razonables de lo necesario para el vuelo o la seguridad (oxígeno medicinal aprobado, baterías de litio de uso personal bajo ciertas condiciones), siempre con precaución extrema.

**Problema:**
- El sujeto de la norma es el piloto al mando: «no permitirá a ninguna persona transportar mercancías peligrosas».
- La única excepción son artículos «que se usen para facilitar la seguridad del vuelo». No hay excepción para objetos «de uso personal».
- Esas cantidades «se considerarán autorizadas», sin aprobación previa. Por eso «excepciones aprobadas», en el resumen, es inexacto.

**Evidencia:** Reg. 2018/1976, anexo II, SAO.GEN.150 a) y b); AMC1 y GM1 SAO.GEN.150.

**Propuesta:** «El piloto al mando no permitirá que nadie lleve mercancías peligrosas a bordo. Sólo se consideran autorizadas cantidades razonables de artículos que se usan para la seguridad del vuelo y conviene tener a mano (SAO.GEN.150).»

**Derivados:** Anki `cap12.yml:24-26`; banco `c12-q04` («salvo las excepciones aprobadas»); `en/…/cap12:52`.

#### [PED-03] Los «artículos prohibidos» (*security*) se confunden con las mercancías peligrosas (*safety*)

- **Severidad:** media. **Confianza:** moderada. **Verificación:** confirmado en las definiciones.
- **Ubicación:** `cap12…:11`, `:30-34`.

**Problema:** el capítulo trata las mercancías peligrosas bajo el rótulo de *security*. Contradice así su propia distinción de las líneas 17-18. Los artículos prohibidos son «armas, explosivos… que pueden utilizarse para cometer actos de interferencia ilícita» (Reglamento 300/2008, art. 3.7).

**Propuesta:** una frase puente que separe las dos categorías y ajustar la promesa de `:11`.

#### [SYL-06] La *security* se enseña sin su marco normativo

- **Severidad:** media. **Confianza:** moderada. **Verificación:** confirmado (vigencia de las normas).
- **Ubicación:** `cap12…:13-38`.

**Problema:** el capítulo no nombra ninguna norma de *security*: ni el Anexo 17, ni el Reglamento 300/2008, ni el Reglamento 2015/1998, ni el Programa Nacional de Seguridad (LSA, art. 3).

**Propuesta:** un párrafo con ese marco y aclarar que las conductas de las líneas 24-28 son recomendaciones. Enlaza con COH-10: zonas restringidas, LSA art. 48.3.

#### [TEC-10] El resumen y Anki amplían la definición de incidente grave

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap13…:54`.

> * **Incidente grave**: las circunstancias indican que hubo alta probabilidad de accidente, o el suceso puso (o pudo poner) en peligro la seguridad de la operación.

**Problema:** la segunda alternativa no está en el Reglamento 996/2010 (art. 2.16). Borra la distinción entre incidente grave e incidente que el capítulo promete. El cuerpo (`:18`) es correcto.

**Evidencia:** Reglamento 996/2010, art. 2.16, consolidado a 19-05-2024.

**Propuesta:** «**Incidente grave**: incidente en el que concurren circunstancias que indican una alta probabilidad de que se hubiera producido un accidente (el Reglamento 996/2010 da ejemplos en su anexo).»

**Derivados:** Anki `cap13.yml:19-24`; `en/`.

#### [NOR-17] «Inhabilitación» por infracción muy grave: término impreciso

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `cap14…:69` (y `:57`).

> * Establece el régimen de infracciones y sanciones: las **muy graves** (muerte o accidente) pueden acarrear la inhabilitación.

**Problema:** según el art. 56 de la LSA:
- la infracción grave puede llevar a suspender o limitar el título hasta cinco años;
- la muy grave, a revocarlo;
- la inhabilitación de tres años se aplica sólo con dos o más infracciones muy graves en un año.

**Propuesta:** «las graves pueden llevar a suspender la licencia hasta cinco años y las muy graves a revocarla; dos muy graves en un año conllevan una inhabilitación de tres años (art. 56)».

**Derivados:** Anki `cap14.yml:20-24,32-33`; banco `c14-q03` (respuesta correcta B, «La inhabilitación del infractor»); `en/`.

#### [SYL-07] El «derecho nacional» se reduce a la LSA

- **Severidad:** media. **Confianza:** moderada. **Verificación:** confirmado (vigencia de las normas).
- **Ubicación:** `cap14…:13-15`.

**Problema:** no aparecen:
- la Ley 48/1960, de Navegación Aérea, que es la ley general;
- la Ley 209/1964, Penal y Procesal de la Navegación Aérea;
- la Ley 2/2024;
- el RD 1180/2018;
- el RD 1088/2020 (SNS).

**Propuesta:** un párrafo de mapa: «la LNA es la ley general; la LSA regula competencias, inspección e infracciones; la Ley 209/1964, los delitos; el RD 1180/2018 desarrolla SERA».

#### [TEC-11] CAVOK en el glosario: condiciones incompletas

- **Severidad:** media. **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `glosario.qmd:90`.

> visibilidad de 10 km o más, sin nubes por debajo de 5.000 ft ni cumulonimbus, y sin tiempo significativo.

**Problema:** faltan tres condiciones:
- la altitud mínima de sector más alta, cuando supera los 5.000 ft;
- los torrecúmulos (TCU) a cualquier altura;
- que no se notifique visibilidad mínima.

Los libros 03 (`cap10:22`) y 04 (`cap04:40`) lo dicen bien.

**Evidencia:** Reg. 2017/373, anexo I, definición 37 y parte MET, consolidado a 22-02-2026.

**Propuesta:** «…visibilidad de 10 km o más (sin visibilidad mínima notificada); ninguna nube por debajo de 5.000 ft o de la altitud mínima de sector más alta, la que sea mayor, ni cumulonimbos ni torrecúmulos a ninguna altura; y ningún fenómeno significativo».

**Derivados:** copias idénticas en `03-meteorologia/glosario.qmd:35-36`, `04-comunicaciones/glosario.qmd:26-27` y `en/01-air-law-atc/glossary.qmd:94`.

#### [TEC-12] El glosario mantiene la CIAIAC como vigente

- Es el derivado de NOR-04, que se registra aquí sólo como recordatorio de ubicación.
- **Ubicación:** `glosario.qmd:95-96`. Severidad heredada: alta.

#### [NOR-18] Bibliografía: faltan normas que los capítulos citan o necesitan, y la LSA no tiene enlace

- **Severidad:** media (trazabilidad). **Confianza:** alta. **Verificación:** confirmado.
- **Ubicación:** `bibliografia.qmd:9-15`.

**Problema:**
- No recoge normas que los capítulos citan: Reglamentos 996/2010, 376/2014, 2018/1139, 1321/2014 y 2150/2005, y RD 184/2008.
- Tampoco las que habría que añadir: RD 1180/2018, Reglamentos 2015/1018 y 300/2008, Ley 2/2024, Ley 48/1960, Ley 209/1964, RD 1088/2020 y Orden FOM/1687/2015.
- La Ley 21/2003 no lleva URL ni fecha de consolidación.
- La nota de `:19` excluye los Anexos 17 y 18 de los «más relevantes», aunque el cap12 se basa en ellos.

**Propuesta:** añadir esas normas con sus enlaces ELI o CELEX consolidados; para la LSA, https://www.boe.es/eli/es/l/2003/07/07/21/con

**Derivados:** las 9 bibliografías son copias de un tronco común.

#### [NOR-19] Preliminares: el rótulo «Validación por AESA» sugiere un aval más amplio que el texto (H5)

- **Severidad:** media. **Confianza:** moderada. **Verificación:** requiere experto.
- **Ubicación:** `licencia.qmd:54-58`.

> Los **temarios de esta colección han sido validados por AESA** (Agencia Estatal de Seguridad Aérea), la autoridad aeronáutica civil de España, en cuanto a su adecuación al syllabus del AMC1 SFCL.130 […] El desarrollo del contenido es responsabilidad exclusiva de los autores.

**Problema:**
- El texto ya acota el alcance a la adecuación al syllabus. El CHANGELOG [1.0-rc.8] dice que la fórmula es la «indicada por AESA».
- No existe un documento público que permita verificarlo.
- El rótulo «Validación por AESA» y el recuadro de aval siguen sugiriendo un respaldo más amplio.
- Este informe muestra que la adecuación del temario al syllabus no valida las afirmaciones del desarrollo.
- En `licencia.qmd:10`, «(EASA-FCL)» debería ser Part-SFCL.

**Propuesta:** rotular «Adecuación del temario al syllabus» y conservar en el archivo editorial la comunicación de AESA.

**Derivados:** según la memoria del proyecto, el texto es idéntico en los 9 preliminares; se edita en el libro 01 y se propaga.

### Baja

| ID | Ubicación | Problema | Propuesta | Confianza / verificación |
| --- | --- | --- | --- | --- |
| TEC-13 | `cap01:53` | «Si sigues los AMC, automáticamente cumples la norma» y el AltMoC «con bastante papeleo». Part-DEF define los AMC como no vinculantes, y en Part-SAO un AltMoC no requiere aprobación (GM1 SAO.GEN.110(b)(2)). | «Seguir los AMC es la vía reconocida para demostrar el cumplimiento; quien use otra debe poder justificar que cumple.» Banco `c01-q04`. | moderada / parcial |
| PED-04 | `cap01:46`, `:70`; figuras `01-cap01-libertades-chicago.jpg` y `01-cap01-estructura-normativa-easa.jpg` | El 2018/1139 no es «la norma de mayor rango» (están los Tratados). TMG, acrobacia y remolque no son todas «habilitaciones» (SFCL.150, 200 y 205). Colores incoherentes en la 5.ª libertad. Las CS rotuladas como «medios de cumplimiento». | Precisar los términos y rotular bien. | alta / confirmado |
| COH-07 | `cap02:25`, figura `01-cap02-certificado-aeronavegabilidad.jpg` | El modelo de CofA cita el Reglamento 216/2008, derogado, y la categoría «Avión Normal». Imita un documento de AESA con firmas inventadas. | Rehacerla como esquema rotulado «EJEMPLO», con la base del Reglamento 2018/1139. | alta / confirmado |
| PED-05 | `cap02:23`, `:31`, `:41` | Faltan las condiciones de 21.A.181 a). Se usa «entorno controlado» (Part-M) en lugar de la gestión continua por CAMO/CAO (ML.A.902 b)). «Anexo Vb» se llama «Anexo V ter» en la versión ES. | Precisar. Revisar también `08/cap09:24,59`. | alta / confirmado |
| PED-06 | `cap03:38-40`, figura `01-cap03-placa-ignifuga.jpg` | Funde la placa de matrícula (Orden FOM/1687/2015, art. 5) con la del fabricante (21.A.801). La foto muestra el campo «Registration letters» en blanco. | Distinguir las dos placas o corregir el pie. Banco `c03-q04/05/06` cita «Anexo 7, capítulo 4», que en la 6.ª ed. es la sección 9. | alta / confirmado |
| SYL-08 | `cap04` | Faltan SFCL.115 a) 1) y a) 3) (operaciones comerciales: 18 años y 75 h o 200 lanzamientos) y la remuneración de instructores. | Una mención. | alta / confirmado |
| PED-07 | `cap04:29`, `:48`; figura `01-cap04-validez-medical.jpg` | «Nuevas gafas» frente a «por vez primera lentes correctoras» (MED.A.020). «15 despegues» frente a «lanzamientos». En la figura, el tramo de la Clase 2 acaba hacia los 34 años y no recoge las reglas de 42 y 51. | Precisar y rehacer la figura. | alta / confirmado |
| COH-08 | `cap05:53-55`, figura `01-cap05-prioridades-paso.jpg` | Tres viñetas sin rótulo, una flecha incoherente, y se cita para una regla de aterrizaje que no muestra. | Rotular y mover la remisión. | moderada / no aplicable |
| NOR-20 | `cap06:35-38` | La regla semicircular no cita fuente, y «desde 2019» es inexacto: es el RD 1180/2018, en vigor desde el 11-11-2018. FL 35, 45 y 55 quedan por debajo de la altitud de transición. | Citar el RD 1180/2018 (art. 6 y anexo I) y el AIP ENR 1.7; usar FL 65, 75… | alta / confirmado |
| PED-08 | `cap06:58-63`; Anki `cap06.yml:39-46` | La mnemotecnia «QFE = *Field Elevation*» invierte la realidad: con QFE el altímetro marca 0 en el campo. El cloze de Anki trata el QNE como reglaje (residuo de H6). | Retirar la mnemotecnia o avisar de que es un truco; ajustar la tarjeta. | moderada / no aplicable |
| PED-09 | `cap06:103`; `cap07:73` | Los resúmenes introducen SAO.GEN.130 y «Autorizaciones ATC» (SERA.8015), que no están en el cuerpo. | Llevarlos al cuerpo o retirarlos del resumen. | alta / no aplicable |
| COH-09 | `cap06:81` | Umbral fisiológico de oxígeno de 8.000–9.000 ft, frente a los 5.000 ft de noche del libro 02 (`02/cap04:133`). | Alinear las cifras tras validarlas un médico aeronáutico. | moderada / requiere experto |
| NOR-21 | `cap07:45`, `:49` | Las RMZ también existen en clase E, que es controlada. La llamada se hace «antes de entrar» y con posición y nivel. | «zona (normalmente E, F o G)…» y un ejemplo de llamada completo. | alta / confirmado |
| NOR-22 | `cap07:36` | «Mayoritariamente clase G» omite que todo el espacio por encima de FL195 es clase C (SERA.6001 b)). | Precisar. Anki `cap07.yml:37-38`. | moderada / confirmado |
| PED-10 | `cap08` figuras `01-cap08-dependencias-atc.jpg`, `01-cap08-fases-emergencia.jpg`; `cap08:16` | El ACC dibujado como torre de aeropuerto. La TWR sin el circuito. SERA.7001 b) limita los obstáculos al área de maniobras. | Ajustar los rótulos al corregir NOR-12. | alta / confirmado |
| PED-11 | `cap09:11`, `:35-37`, figura `01-cap09-ejemplo-notam.jpg` | Promete enseñar a usar Insignia y no lo hace. No explica los campos del NOTAM. El ejemplo «LEZG RWY 12/30» no corresponde a las pistas reales (12L/30R y 12R/30L). | Rebajar la promesa, explicar A/B/C/E y usar un designador real. | alta / confirmado |
| TEC-14 | `cap10:37-41`, figura `01-cap10-manga-viento.png` | La T indica aterrizar «hacia su travesaño». La cruz con diagonales es «aterrizajes prohibidos», no «aeródromo cerrado». En la manga, «≈3 kt por franja» es convención FAA, y la figura redondea mal 9 kt (16,7 km/h y 4,63 m/s) y 15 kt (7,72 m/s). | Ajustar la redacción y las cifras. | moderada / parcial |
| PED-12 | figura `01-cap10-circuito-transito.jpg` | Dibuja un bimotor. Introduce el IP y el «tramo de entrada», que el texto no explica. | Rehacerla con un planeador. | alta / no aplicable |
| NOR-23 | `cap11:15`, `:25` | El nombre vigente es «Ejército del Aire y del Espacio». El AIP GEN 3.6 no publica ningún RSC. | Actualizar el nombre y suprimir la mención de los RSC. Glosario (RSC). | alta / confirmado |
| PED-13 | `cap11:39-48` | Faltan las señales aire-tierra de acuse (alabear las alas, GEN 3.6 §6.3). Los 2,5 m del tamaño de las señales no tienen fuente primaria. | Añadir el acuse y citar el Anexo 12 tras cotejarlo. | moderada / parcial |
| COH-10 | `cap12:47` | El resumen introduce las «zonas restringidas de los aeropuertos», que no están en el cuerpo. | Dos frases en el cuerpo (Reglamento 300/2008, art. 3; LSA, art. 48.3). Banco `c12-q05`. | alta / confirmado |
| PED-14 | `cap12:20`, `:34`; figuras `01-cap12-*` | La *safety* se ilustra como seguridad laboral (casco, grúa, «SALUD OCUPACIONAL»). La figura de etiquetas de mercancías peligrosas no se comenta. | Iconografía aeronáutica y una frase de lectura. | alta / no aplicable |
| PED-15 | `cap13:17`, `:47` | La definición de accidente no tiene ventana temporal ni exclusiones (extremos de ala). La excepción para mover restos es más estrecha que la norma, y falta fotografiar antes de mover (Reglamento 996/2010, arts. 2.1 y 13). | Precisar. | alta / confirmado |
| PED-16 | `cap13:33`; `cap14:21-29` | AESA aparece sólo como vigilante y sancionadora. También gestiona el SNS sin fines sancionadores (Reglamento 376/2014, art. 16.6) y expide las licencias (RD 184/2008, art. 9). | Añadir esas funciones. | alta / confirmado |
| TEC-15 | `cap13:21`, figura `01-cap13-piramide-sucesos.jpg` | Atribuye a Heinrich la proporción 1/30/300 con las categorías del Reglamento 996/2010. Heinrich publicó 1/29/300 de lesiones. | Corregir o sustituir por la clasificación accidente, incidente grave, incidente y suceso. | moderada / parcial |
| NOR-24 | `glosario.qmd:204`, `:207`; `bibliografia.qmd:11` | «Reglamento (UE) 2018/1976» es un **Reglamento de Ejecución**. | Corregir la denominación. | alta / confirmado |

---

## Comprobaciones cuantitativas

| Ubicación | Datos y fórmula | Resultado recalculado | Valor publicado | Estado |
| --- | --- | --- | --- | --- |
| `cap01:20` | Estados miembros de OACI | 193 (icao.int) | 193 | correcto |
| `cap03:29-30` | Altura de las marcas en ala y fuselaje | 50 / 30 cm (Orden FOM/1687/2015, anexo II B); Anexo 7, 5.2 | 50 / 30 cm | correcto |
| `cap04:18` | Edad SPL / vuelo solo | 16 / 14 (SFCL.120, SFCL.125) | 16 / 14 | correcto |
| `cap04:26` | LAPL emitido a los 39 años | 39 + 60 meses = 44, pero cesa a los 42 (MED.A.045 a) 4)) | regla 40/42 | correcto |
| `cap04:36-40` | Recencia | 5 h, 15 lanzamientos, 2 vuelos con FI(S) en 24 meses (SFCL.160 a) 1)) | igual | correcto (incompleto: SFCL.155, SYL-01) |
| `cap04:55-57` | Pasajeros | 10 h o 30 lanzamientos más vuelo con FI(S); 3 lanzamientos en 90 días | igual | correcto |
| `cap05:61-62` | 300 m ÷ 0,3048; 150 m ÷ 0,3048 | 984 ft ≈ 1.000; 492 ft ≈ 500 | 1.000 / 500 ft | correcto (falta el obstáculo, NOR-08) |
| `cap05:69` | 50 m ÷ 0,3048 | 164,0 ft | «50 m (150 ft)» | literal de la norma; −8,6 %, necesita nota (NOR-09) |
| `cap06:18` | Terreno a 800 m = 2.625 ft, + 1.000 ft | 3.625 ft AMSL | 3.000 ft | ilustra TEC-04 |
| `cap06:22-29` | 5 km = 2,70 NM; 8 km = 4,32 NM; FL100 = 3.048 m | — | 5 / 8 km; FL 100 | correcto |
| `cap06:25` | 140 kt × 1,852 | 259 km/h | 140 kt | cifra correcta, pero no aplicable a planeadores (NOR-01) |
| `cap06:37-38` | Rumbo 045°, anexo I del RD 1180/2018 | pares + 500 (4.500 / 6.500 ft) | igual en el texto; la figura da impares | texto correcto, figura incorrecta (COH-01) |
| `cap06:56` | Altitudes de transición (ENR 1.7) | 6.000 ft; Madrid 13.000; Granada 7.000 | igual | correcto (lista no exhaustiva) |
| `cap06:56` | 1013,25 hPa | 29,92 inHg | 1013,25 | correcto |
| `cap07:60` | LEP141, LER170, LER71C, LED125 (ENR 5.1 vigente) | SFC–6.000 ft; SFC–FL090; 2.000 ft AGL–FL240; 5.000 ft–FL245 | igual | correcto |
| `cap08:51-52` | INCERFA | 30 min (ATS.TR.405 a) 1)) | 30 min | correcto (falta «la posterior», NOR-12) |
| `cap09:37` | Validez del NOTAM | umbral de 3 meses (AIS.OR.315) | «generalmente 3 meses» | correcto |
| `cap10:37` | 3 kt × 1,852 | 5,56 km/h | 5,5 km/h | aceptable (truncado) |
| figura `cap10` | 9 kt; 15 kt | 16,7 km/h y 4,63 m/s; 27,8 km/h y 7,72 m/s | 16 / 4,5; 28 / 7,8 | incorrecto (TEC-14) |
| `cap11:19` | Número de RCC | 3 ARCC (GEN 3.6 §2) | 3 | correcto (cobertura de Palma, TEC-07) |
| `cap11:53` | Frecuencia de emergencia | 121,5 MHz | 121,5 MHz | correcto |
| `cap13:35` | Plazo de notificación (376/2014, art. 4.7) | 72 h desde que se tiene conocimiento | 72 h | correcto (matiz en NOR-05) |
| figura `cap13` | Heinrich | 1 : 29 : 300 | 1 / 30 / 300 | incorrecto (TEC-15) |
| figura `cap14` | LSA, art. 55.1 | 60–45.000 / 45.001–90.000 / 90.001–225.000 € | hasta 45.000 / 90.000 / 225.000 € | correcto (falta el art. 55.2) |

---

## Rastreo de derivados

La tabla recoge sólo las proposiciones corregibles. Los hallazgos ya indican sus derivados; aquí se agrupan por destino.

| Ruta | Proposición y ámbito | Origen canónico | Estado | Motivo |
| --- | --- | --- | --- | --- |
| `tools/anki/mazos/01-derecho-aereo-atc/cap02,03,05,06,08,11,12,13,14.yml` | Varias: ver NOR-01 a NOR-06, TEC-01, TEC-02, NOR-12, NOR-14, COH-05, NOR-16, TEC-10, NOR-17 | Anki | afectado | Repiten el error del capítulo |
| `examenes/json/derecho-aereo-atc.json` | `c02-q09`, `c03-q01/q02`, `c05-q06/q09/q10`, `c06-q03`, `c12-q04/q05`, `c13-q04`, `c14-q03`; distractores o fundamentos con CIAIAC en `c01-q03` y `c14-q04/05/06` | banco de examen (repositorio git propio, publicado en vuelalibre.net/examenes) | afectado | En `c06-q03`, `c13-q04` y `c14-q03` la opción puntuada como correcta es errónea |
| `examenes/json/derecho-aereo-atc.json` `c07-q04` | El ATC separa al VFR «solo en las clases más restrictivas» | banco | comprobado sin cambio | Es correcto y sirve de modelo para TEC-02 |
| `examenes/lecciones/01-derecho-leccion-01/05/06/13/14.md` | CIAIAC, RD 552/2014, 1.500 m | lecciones | afectado | NOR-04, NOR-02, NOR-01 |
| `0[1-9]-*/bibliografia.qmd:13` (`:15` en 06 y 08) | SERA «se aplica mediante el RD 552/2014» | bibliografía común | afectado | NOR-02 |
| `03-meteorologia/cap06-masas-de-aire-y-frentes.qmd:49`; Anki 03 `cap06.yml:60` | 1.500 m por debajo de 140 kt en clase G | capítulo | afectado | NOR-01 y TEC-04 |
| `03-meteorologia/glosario.qmd:35-36`; `04-comunicaciones/glosario.qmd:26-27` | CAVOK incompleto | glosario | afectado | TEC-11 |
| `03-meteorologia/cap10…:22`; `04-comunicaciones/cap04…:40` | CAVOK completo | capítulo | comprobado sin cambio | Son el modelo |
| `06-procedimientos-operativos/cap01-requisitos-generales.qmd:31` | «Libro 4, capítulo 8» | capítulo | afectado | COH-02 |
| `06-procedimientos-operativos/cap01…:33,170`; `08-aeronave-sistemas/cap08…:35,47` | SAO.GEN.155 y SFCL.045 | capítulo | comprobado sin cambio | Correctos; contradicen a `01/cap02` |
| `06-procedimientos-operativos/cap04…:23` | Base a 150 m «recomendada» | capítulo | comprobado sin cambio | Modelo para COH-03 |
| `02-factores-humanos/cap04-uso-de-oxigeno.qmd:127`; `08-aeronave-sistemas/cap14…:36` | El AMC1 SAO.OP.150 como «deberá» o «debe» | capítulo | afectado | NOR-10 |
| `08-aeronave-sistemas/cap08…:74` | «Sin ARC en vigor, el seguro no cubre nada» | capítulo | afectado | NOR-14 |
| `08-aeronave-sistemas/cap09…:24,59` | Prórroga del ARC citada como ML.A.901 y «entorno controlado» | capítulo | afectado | PED-05 (el apartado correcto es ML.A.902) |
| `04-comunicaciones/cap06…:18`, `cap03…:126`; Anki 04 `cap03.yml:85`; `03-meteorologia/cap06…:49`; Anki 03 `cap06.yml:62` | Gravedad fija de las infracciones | capítulo | candidato afectado | NOR-06; hay que revisarlo en su libro |
| `04-comunicaciones/cap04…:37,86`; Anki 04 `cap04.yml` | «*Ceiling and Visibility OK*» presentado como desarrollo de la sigla | capítulo | candidato afectado | Choca con la decisión de la rc.13 del glosario 01 |
| `04-comunicaciones/cap06…:66-128` | Interceptación (SERA.11015) | capítulo | comprobado sin cambio | Contenido correcto; sólo falla la remisión |
| `09-navegacion/cap07-uso-de-ats.qmd:77,95,138` | En clase D nadie separa al VFR | capítulo | comprobado sin cambio | Modelo para TEC-02 |
| `07-planificacion-rendimiento/cap04-plan-de-vuelo-icao.qmd` | Plan de vuelo y su cierre | capítulo | comprobado sin cambio | Destino de las remisiones y de NOR-13 |
| `en/01-air-law-atc/` (capítulos, glosario, bibliografía, figuras) y `tools/anki/mazos/en/01-air-law-atc/` | Traducción de todo lo anterior | edición inglesa | afectado | Misma causa; `cap04:23` añade un error propio (TEC-09) |
| `tools/anki/mazos/01-derecho-aereo-atc/cap01.yml`, `cap07.yml:103` (comentarios) | Material de origen | comentario | no canónico | La skill excluye los comentarios |

Las figuras afectadas, que hace Ramón, son 15:
- `01-cap02-ciclo-arc`
- `01-cap02-certificado-aeronavegabilidad`
- `01-cap03-ubicacion-matricula`
- `01-cap04-recencia-requisitos`
- `01-cap04-validez-medical`
- `01-cap05-alturas-minimas`
- `01-cap05-prioridades-paso`
- `01-cap06-regla-semicircular`
- `01-cap06-minimos-vmc`
- `01-cap08-fases-emergencia`
- `01-cap10-senales-aerodromo`
- `01-cap10-manga-viento`
- `01-cap13-flujo-notificacion`
- `01-cap13-piramide-sucesos`
- `01-cap14-escala-infracciones`

No hay fichas `.prompt.md` para ninguna figura del libro 01.

`[En curso]` de `CHANGELOG-01.md` está vacío. Cada corrección que se aplique debe anotarse ahí, y también en los CHANGELOG de los libros 02, 03, 04, 06 y 08 si se propaga a ellos.

---

## Cobertura del syllabus

El syllabus aplicable es el AMC1 SFCL.130, de la ED Decision 2020/004/R, recogido en las EASA Easy Access Rules for Sailplanes (PDF generado en noviembre de 2022; la página de EASA no lista enmiendas posteriores a octubre de 2020). Recoge 14 epígrafes de Derecho Aéreo **sin subepígrafes**, y coinciden uno a uno con `apendice-syllabus-oficial-easa---derecho-aereo.qmd:5-18`. La cobertura se juzga, por tanto, contra el epígrafe y contra la norma vigente, no contra subapartados deducidos.

| Epígrafe oficial | Estado | Evidencia en el libro | Observación |
| --- | --- | --- | --- |
| 1.1 Derecho internacional: convenios, acuerdos y organizaciones | cubierto | `cap01:14-32` | Los Anexos y las SARPS sólo se nombran en la bibliografía. |
| 1.2 Aeronavegabilidad | cubierto | `cap02:13-62`; desarrollo técnico en `08/cap09` | Remisión coherente. |
| 1.3 Marcas de nacionalidad y matrícula | cubierto | `cap03:13-54` | Falta la norma española (NOR-15). |
| 1.4 Licencias de personal | **parcial** | `cap04:14-72` | Faltan SFCL.155 (SYL-01), la extensión TMG (TEC-09) y la Clase 2 (PED-02). |
| 1.5 Reglas del aire | cubierto | `cap05:14-71`; VMC en `cap06:14-31` | El VFR especial (SERA.5010) no aparece en la colección; es una oportunidad, no una carencia exigible. |
| 1.6 Procedimientos: operaciones de aeronaves | cubierto | `cap06:14-92`; plan de vuelo en `04/cap02:146`, `07/cap04`, `09/cap07` | Remisión al libro 04 mal numerada (COH-02). |
| 1.7 Estructura del espacio aéreo | cubierto | `cap07:18-63` | Falta la regla española del transpondedor (NOR-07). |
| 1.8 ATS y ATM | parcial | `cap08:14-91` | Falta el AFIS (SYL-02); separación mal condicionada (TEC-02). |
| 1.9 AIS | parcial | `cap09:13-47` | Faltan SUP y PIB (SYL-03). |
| 1.10 Aeródromos y campos de despegue externos | parcial | `cap10:13-58` | Faltan señales SERA (SYL-04); la sección de campos externos no tiene base normativa (NOR-13). |
| 1.11 Búsqueda y salvamento | parcial | `cap11:13-59` | Faltan balizas (SYL-05) y señales de acuse. |
| 1.12 Seguridad (*security*) | parcial | `cap12:13-38` | Falta el marco normativo (SYL-06). |
| 1.13 Notificación de accidentes | parcial | `cap13:13-57` | Falta la lista de sucesos obligatorios (NOR-05). |
| 1.14 Derecho nacional | parcial | `cap14:13-72` | Régimen de infracciones erróneo (NOR-06) y sólo trata la LSA (SYL-07). |

---

## Conciliación con el informe de julio (v1.0.3)

| ID | Hallazgo de julio | Estado | Comprobación en el texto actual |
| --- | --- | --- | --- |
| H1 | «50 m (150 ft)» en entrenamiento de aterrizajes forzosos | persistente, atenuado | El resumen ya no lo repite. `cap05:69` reproduce literalmente la norma (RD 1180/2018, art. 33.1 b), y AIP ENR 1.2). Basta una nota sobre los 164 ft (NOR-09). |
| H2 | «SERA se aplica en España mediante el RD 552/2014» | corregido en parte, con un error nuevo | `cap01:82` y `cap05:16` ya dicen que SERA es directamente aplicable. Persiste literal en `bibliografia.qmd:13` de los 9 libros. El RD citado como complemento está derogado desde 2018 (NOR-02). |
| H3 | Médico LAPL: regla de los 40/42 años | corregido y verificado | `cap04:26`, frente a MED.A.045 a) 4) (Reglamento 1178/2011, consolidado a 30-04-2026). Queda la figura (PED-07). |
| H4 | «Tu seguro se invalidará automáticamente» | corregido en el cuerpo; persiste en derivados | `cap02:34` está matizado. Siguen categóricos Anki `cap02.yml:34-35`, el mazo EN y `08/cap08:74`, y aparece el mismo patrón en `cap04:60` (NOR-14). |
| H5 | «Validados por AESA» | corregido en el alcance; requiere experto | El texto se limita a la adecuación al syllabus y deja el desarrollo a cargo de los autores. Quedan el rótulo y la falta de soporte público (NOR-19). |
| H6 | QNE al mismo nivel que QNH y QFE | corregido y verificado | `cap06:56` y `glosario.qmd:218-219`. Queda un residuo en el cloze de Anki (PED-08). |
| H7 | Interceptación SERA.11015 sin ubicación | contenido cubierto; remisión en regresión | Desarrollada correctamente en `04/cap06:66-128`. `cap07:63` apunta al «capítulo 8» (COH-02). |
| H8 | Referencias cruzadas a los libros 4, 7 y 9 | añadidas; tres en regresión | Las remisiones existen en `cap06:94`, `cap07:63`, `cap08:63` y `cap10:33`. Las del libro 04 quedaron mal numeradas tras `a80eda3` (COH-02). Las de los libros 07 y 09 son correctas. |
| H9 | Parte legal de los campos externos | persistente, atenuado | Se añadió `cap10:52-58`, pero sin base normativa y sin reflejo en la apertura, el resumen ni Anki (NOR-13, PED-01). |
| H10 | Enlazar los simuladores de examen | corregido y verificado | `apendice…:22-28` («Ponte a prueba»). https://vuelalibre.net/examenes/01-derecho-aereo-atc/ responde. Pero el banco repite errores del libro (ver «Rastreo de derivados»). |
| — | Capítulos 12 a 14, «sin errores» en julio | sin regresión | El texto no cambia desde el 16-07-2026. NOR-04 es sobrevenido (la CIAIAC se suprimió el 15-07-2026). NOR-05, NOR-06, NOR-17 y TEC-10 ya existían y no se detectaron en julio. |

**Por qué el veredicto es más severo que en julio:**
- julio evaluó un PDF y comprobó una muestra de afirmaciones;
- esta auditoría aplica la rúbrica de la skill `revision-capitulo-spl` capítulo a capítulo, contrasta cada cifra con texto primario consolidado a octubre de 2026 y rastrea los derivados;
- tres de los cambios normativos son posteriores a julio o no se detectaron entonces: la supresión de la CIAIAC, el RD 1029/2025 y el RD 1180/2018, que ya regía en julio.

---

## Lo que funciona

- **Arquitectura y cajas.** El patrón apertura, desarrollo, cajas y post-it de resumen, junto con la separación entre ⚖ Normativa, ⚠ Seguridad, ⚓ *Airmanship* y ✦ Regla de oro, sigue siendo la mayor fortaleza pedagógica. Los errores detectados suelen estar precisamente donde una caja mezcla norma y consecuencia (`cap04:60`, `cap01:85`).
- **Exactitud de SERA.3210 en convergencia.** Orden globo > planeador > dirigible > motor, excepción del remolque, alcance entre planeadores por cualquier lado, y la regla de ladera rotulada como convención y no como norma (`cap05:36-49`).
- **La corrección de la rc.11** acertó en todo el contenido. Sólo falla la fuente (NOR-02).
- **Cifras exactas** de recencia, pasajeros, médico LAPL (con ejemplo numérico), la tabla VMC clase a clase, las altitudes de transición, la tabla de niveles de crucero en el texto, los umbrales INCERFA, el código tierra-aire, las cuantías del art. 55.1 y el plazo de 72 h.
- **Ejemplos reales y vigentes** de zonas P, R y D (LEP141, LER170, LER71C, LED125, LEP162), contrastados con el ENR 5.1 a 1 de octubre de 2026.
- **Contraste ATC/FIS** de `cap08:40-43` y regla de oro «La carta te dice dónde está una zona. Nunca si hoy está activa» (`cap08:80`).
- **Deber de informarse** anclado en SERA.2010 b) (`cap09`), e ICARO e Insignia vigentes.
- **Cultura justa:** la distinción de los destinatarios y plazos de notificación con cita de artículo (`cap13:35`) y las excepciones de `cap13:38`, que coinciden con el art. 16.10 del Reglamento 376/2014.
- **Reparto de competencias DGAC/AESA** (`cap14:19-29`) coherente con el RD 253/2024 y la LSA, incluida la reforma de la Ley 8/2025.
- **Glosario:** 57 siglas contrastadas con el AIP GEN 2.2 coinciden. Las entradas de AGL/AMSL, NOTAM y QNE son correctas tras la rc.13.

---

## Prioridades

1. **Bloqueante:** NOR-01 (1.500 m), con todos sus derivados. Corregir primero el banco de examen publicado (`c06-q03` y la lección 06) y el libro 03.
2. **Altas con texto propuesto verificado:**
   - NOR-02: RD 1180/2018 en los capítulos 01 y 05, Anki, banco, lección y las 9 bibliografías.
   - TEC-01: prioridad de paso.
   - NOR-03: documentación a bordo, con el banco `c02-q09`.
   - TEC-02: separación ATC.
   - NOR-04: CIAIAC, con glosario, banco y lecciones.
   - NOR-05: notificación obligatoria y la figura del flujo.
   - NOR-06: infracciones LSA y su figura.
   - SYL-01: SFCL.155.
3. **Alta pendiente de confirmar:** NOR-07 (transpondedor). Corregir ya la regla general y consultar a AESA o la DGAC por las exenciones.
4. **Figura alta:** COH-01 (semicircular). Se puede retirar provisionalmente hasta tenerla rehecha.
5. **Medias de mayor retorno:**
   - COH-02: remisiones al libro 04, cuatro cambios de un número.
   - NOR-08 y NOR-09: alturas mínimas.
   - NOR-12: fases de emergencia.
   - TEC-04: VMC «el mayor».
   - NOR-17: inhabilitación, con el banco `c14-q03`.
   - TEC-11: CAVOK en tres glosarios.
   - TEC-09: TMG, sobre todo en la edición inglesa.
6. **Resto de medias:** cobertura (SYL-02 a SYL-07, NOR-13) y figuras (TEC-03, COH-04, COH-06).
7. **Bajas:** opcionales y agrupables por capítulo cuando se toque cada uno.

---

## Pendiente de verificar

- **AESA o DGAC:** si existen exenciones al transpondedor a FL145 para planeadores (NOR-07).
- **Jurista, AESA o RFAE:**
  - régimen español del despegue ocasional desde un campo tras una toma fuera de campo, y precepto exacto del «consentimiento del propietario» (NOR-13);
  - si la Ley 2/2024, art. 9.1 c), obliga al piloto de planeador a notificar a la Autoridad también los incidentes no graves;
  - si un titular de SPL que vuela con remuneración queda en la escala del art. 55.2 de la LSA;
  - competencia de la Guardia Civil para exigir la licencia aeronáutica;
  - artículo del Código Penal aplicable a la falsificación de licencias.
- **AESA o EASA:** qué artículos concretos (oxígeno, extintor, baterías de variómetro o de uso personal) entran en la excepción de SAO.GEN.150 b) (NOR-16).
- **Corredor de seguros aeronáuticos o jurista:** redacción sobre seguros y ARC (NOR-14).
- **FI(S):**
  - redacción de SFCL.155 (SYL-01);
  - «altura mínima de base» como criterio de instrucción (COH-03);
  - «convención universal» de la ladera (`cap05:49`; falta fuente BGA, FFVP o DAeC);
  - estadística «la mayoría de colisiones ocurren en días claros» (`cap05:25`, sin fuente).
- **Médico aeronáutico:** umbrales fisiológicos de oxígeno en los libros 01 y 02 (COH-09).
- **Editor:**
  - respaldo documental de la fórmula de AESA en los preliminares (NOR-19);
  - sigla oficial de la nueva Autoridad de investigación (NOR-04).
- **Anexos OACI de pago:**
  - Anexo 12, para los 2,5 m de las señales (PED-13);
  - Anexo 14, para la manga y el área de señales;
  - Anexo 7 oficial, consultado sólo en reproducción no oficial.
- **Doc 9626:** las «nueve libertades» (`cap01:22`), no contrastadas.

---

## Fuentes consultadas

Todas se consultaron el 2026-10-01.

| Fuente | Edición o vigencia | Apartados usados | Naturaleza | Fuerza |
| --- | --- | --- | --- | --- |
| EASA, Easy Access Rules for Sailplanes (https://www.easa.europa.eu/en/downloads/94424/en) | PDF de noviembre de 2022; Reg. 2018/1976 consolidado a 15-11-2021; página: «Revision from September 2020» | AMC1 SFCL.130; SAO.GEN.110/130/150/155/160; SAO.OP.100/150; SAO.IDE.105/125; SFCL.045/115/120/125/150/155/160; definiciones; Part-DEF | primaria (compilación) | IR vinculante; AMC y GM no vinculantes |
| EASA, página de normativa de planeadores (https://www.easa.europa.eu/en/regulations/sailplanes-air-operations) | — | Ausencia de enmiendas posteriores a 2020 | primaria institucional | no aplicable |
| EASA, Easy Access Rules for SERA (https://www.easa.europa.eu/en/downloads/68174/en) | agosto de 2025 | AMC1 y GM1 SERA.5005(f) | compilación | AMC y GM no vinculantes |
| Reglamento de Ejecución 923/2012 (SERA), CELEX 02012R0923-20250501 (Cellar y EUR-Lex) | consolidado a 01-05-2025, el último listado | 2010, 3201, 3210, 3225, 4020, 5001 (S5-1), 5005, 6001, 6005, 7001, 8015, 10001, 11015; apéndices 1, 3 y 4 | primaria | vinculante |
| Reglamento de Ejecución 2017/373, CELEX 02017R0373-20260222 | 22-02-2026 | art. 2; anexo I def. 37; ATS.TR.400/405; AIS.OR.315/505; AIS.TR.510; parte MET | primaria | vinculante |
| Reglamento 1178/2011 (Parte MED), CELEX 02011R1178-20260430 | 30-04-2026 | MED.A.020, 030, 045 | primaria | vinculante |
| Reglamento 1321/2014 (Parte ML), CELEX 02014R1321-20260807 | 07-08-2026 | ML.A.403, 803, 901, 902 | primaria | vinculante |
| Reglamento 748/2012 (Parte 21), CELEX 02012R0748-20260807 | 07-08-2026 | 21.A.181, 21.A.801; formulario EASA 25 | primaria | vinculante |
| Reglamento 2018/1139, CELEX 02018R1139-20260802 | 02-08-2026 | art. 76 | primaria | vinculante |
| Reglamento 996/2010 | consolidado a 19-05-2024 | arts. 2, 9, 13 | primaria | vinculante |
| Reglamento 376/2014 | consolidado a 11-09-2018 | arts. 2, 4, 16 | primaria | vinculante |
| Reglamento de Ejecución 2015/1018 | consolidado a 17-08-2026 | anexo V, sección 2 | primaria | vinculante |
| Reglamento 300/2008; Reglamento de Ejecución 2015/1998 | 02-08-2026; 01-10-2026 | arts. 1 y 3; vigencia | primaria | vinculante |
| Reglamento 785/2004 | — | art. 2 | primaria | vinculante |
| RD 1180/2018 (BOE-A-2018-15406) | última actualización publicada el 05-06-2024 | arts. 6, 30, 33; anexo I; disposición derogatoria | primaria | vinculante |
| RD 552/2014 (BOE-A-2014-6856) | derogado por el RD 1180/2018 | análisis; art. 15 | primaria | no vigente |
| Ley 21/2003 (BOE-A-2003-13616) | última actualización publicada el 30-09-2025 | arts. 3, 4 bis, 33-36, 44, 48, 50, 55, 56, 58 | primaria | vinculante |
| Ley 2/2024 (BOE-A-2024-15937) | consolidada | disposición adicional primera; arts. 9, 21 | primaria | vinculante |
| RD 141/2026 (BOE-A-2026-4518) | vigente | Estatuto de la Autoridad | primaria | vinculante |
| Ministerio de Transportes, página de la CIAIAC (https://www.transportes.gob.es/organos-colegiados/ciaiac) | — | sesión constitutiva del 15-07-2026 | primaria institucional | no aplicable |
| Ley 48/1960; Ley 209/1964 | consolidadas | arts. 120, 127; art. 31 | primaria | vinculante |
| RD 1189/2011 | consolidado a 28-11-2015 | arts. 1.2, 2 b), 16 | primaria | vinculante |
| RD 1029/2025 (BOE-A-2025-22950); RD 384/2015 (derogado) | 13-11-2025 | art. 4; disposición adicional segunda; disposición derogatoria | primaria | vinculante |
| Orden FOM/1687/2015 (BOE-A-2015-8940) | consolidada a 05-01-2023 | arts. 4-5; anexo II A, B y D | primaria | vinculante |
| RD 184/2008; RD 253/2024; RD 1088/2020 | modificados por el RD 466/2026; 02-03-2026; 20-12-2025 | arts. 8-9; art. 8; arts. 1-3 | primaria | vinculante |
| AIP España (ENAIRE): GEN 2.2, 3.1, 3.3, 3.6; ENR 1.2, 1.4, 1.6, 1.7, 2.1, 5.1; AD 2-LEZG | AMDT y AIRAC vigentes a 01-10-2026 (detalle en cada hallazgo) | — | primaria operativa | vinculante por remisión |
| AESA, «¿Quién debe notificar?» | modificada el 26-02-2025 | 72 h y canal de notificación | primaria institucional | no aplicable |
| OACI, Doc 7300/9 (Convenio de Chicago) | 2006 | art. 20 | primaria | vinculante |
| OACI, Anexo 7, 6.ª ed. (reproducción no oficial, peter2000.co.uk) | 2012 | 4.3, 5.2, sección 9 | secundaria | sólo orientación |
| Cospas-Sarsat, *121.5 phase-out* | — | — | primaria técnica | no aplicable |
| FAA, *Glider Flying Handbook* FAA-H-8083-13B; FAA AC 150/5345-27F | vigentes | cap. 9, fig. 9-18; §3 | secundaria técnica | no vinculante en España |
| Rebbitt, «Pyramid Power», *Professional Safety* (09/2014) | — | proporción 300-29-1 | secundaria | no aplicable |
| Prensa (hosteltur, elespanol) | julio de 2026 | sólo para orientar la búsqueda de la Autoridad | secundaria | no aplicable |

---

## Alcance y límites

- **Revisado:**
  - los 14 capítulos completos, incluidas aperturas, cajas, tablas y resúmenes;
  - el apéndice de syllabus, el glosario, la bibliografía y los preliminares institucionales (`licencia.qmd`, `reconocimientos.qmd`, `introduccion.qmd`);
  - los 14 mazos Anki (sólo `tarjetas`) y las 29 figuras, inspeccionadas visualmente;
  - el banco de examen y las lecciones, como derivados.
- **Forma de trabajo:** la revisión se hizo en cuatro bloques de capítulos, en paralelo, y después se consolidó. La consolidación incluyó una verificación propia en fuente primaria de todos los hallazgos bloqueantes y altos: RD 1180/2018 (arts. 30 y 33 y derogatoria), Ley 2/2024 y web del Ministerio (CIAIAC), LSA art. 44, SAO.GEN.155, SFCL.155 y la figura semicircular. También se cotejaron con el `.qmd` las citas literales de los hallazgos principales.
- **Formato:** los hallazgos de severidad baja se presentan en una tabla compacta, sin el desarrollo completo de evidencia. Sus fuentes están en la tabla general.
- **Fuera de alcance:**
  - la calidad de la traducción inglesa, que sólo se rastreó como derivado;
  - la maqueta y el PDF compilado;
  - los capítulos de otros libros, salvo para comprobar coherencia y remisiones.
- **Fuentes inaccesibles:**
  - los Anexos 7 (oficial), 11, 12, 14, 17 y 18 de OACI y el Doc 8400, que son de pago o no tienen copia oficial pública. Se suplieron con transposiciones UE y el AIP, y así consta en cada caso;
  - EUR-Lex directo, que bloquea las descargas automáticas. Se usó el repositorio Cellar de la Oficina de Publicaciones (mismo contenido) o el navegador;
  - el Código Penal, que no se consultó.
- **Dato dinámico:** el AIP, la web de AESA y la del Ministerio se consultaron el 2026-10-01. Las afirmaciones que dependen de ellos deben volver a comprobarse en la próxima revisión.
- **Límite de competencia:** esta revisión asistida no sustituye el visto bueno de un FI(S) o FE(S), de un médico aeronáutico, de un jurista ni de AESA o la DGAC en los puntos marcados como pendientes. La adecuación del temario al syllabus que declaran los preliminares no valida cada afirmación del desarrollo.
- **Sin cambios en las fuentes:** no se ha modificado ningún fichero del libro, glosario, Anki, figuras, banco ni CHANGELOG.
