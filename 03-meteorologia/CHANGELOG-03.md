# Registro de cambios — 03. Meteorología

Este registro existe para que **un revisor no tenga que releer el libro entero**. Cada entrada dice
qué cambió, en qué capítulo, y si el cambio toca el contenido técnico o sólo la maqueta.

**Cómo leerlo si vas a revisar:** ve a la entrada de la versión que revisaste por última vez y lee
sólo las líneas "Qué releer" de las entradas posteriores. Si no revisaste ninguna, empieza por la
más antigua.

**Cómo escribirlo si cambias algo:** añade la línea bajo la versión en curso, nombrando el capítulo
(`cap07`, "Glosario", "Preliminares"). Un cambio que no altere lo que el lector aprende va en
*Maqueta y producción*, que el revisor puede saltarse. La versión sale de `version:` en
`_quarto.yml`, y de ella el estado editorial del libro (ver el README de la colección). **El CI
exige que la versión en curso tenga su entrada aquí**: subir la versión sin registrar qué cambió
rompe la compilación.

## [En curso]

### Corregido

* **Glosario, presentación** — decía que las entradas van «organizadas según el programa de
  formación»; van en orden alfabético. Hallazgo PED-11 de la auditoría del libro 03.
* **cap05 y Glosario, lluvia engelante** — decía que forma «hielo opaco o escarcha» y mandaba
  descender «a niveles con temperatura positiva», y el glosario lo daba como «único remedio». La
  lluvia engelante forma sobre todo hielo claro, y en ella el aire más cálido suele estar encima:
  descender puede no sacar de la capa bajo cero (FAA AC 00-6B, §14 y §18.3.7). Ahora se manda salir
  de la zona, girando hacia donde no llueve, o aterrizar. Hallazgo TEC-03 de la auditoría del
  libro 03.
* **cap03 y cap10, CAPE y «día termonuclear», y sus tarjetas Anki** — presentaba un CAPE de
  1.000–2.500 J/kg como excelente «sin el riesgo de tormenta severa». Ese rango es moderadamente
  inestable y no descarta la tormenta si hay humedad y disparo (NWS). Se retira la afirmación y las
  dos «reglas de oro» avisan del sobredesarrollo. Qué banda es buen día en la Península queda como
  pregunta para un meteorólogo. Hallazgo TEC-02 de la auditoría del libro 03.
* **cap02, efecto Foehn, y Glosario y Anki** — decía que la diferencia entre los valles «puede
  superar los 10–15 °C» y el resumen, «hasta 15 °C». Con el mecanismo descrito sale del orden de
  5–10 °C; se da un ejemplo numérico, y el calor latente se libera en la propia masa de aire, no
  «a la atmósfera». Hallazgo TEC-07 de la auditoría del libro 03.
* **cap02, brisa marina** — sólo daba ascendencias «suaves y continuas». Se añaden la turbulencia de
  la zona de mezcla, el fin de las térmicas tras el frente de brisa y la línea de tormentas con aire
  inestable (FAA, *Glider Flying Handbook*). Hallazgo TEC-08 de la auditoría del libro 03.
* **cap02, figuras del *Glider Flying Handbook*** — la convergencia del relieve se citaba para la
  brisa marina, el vuelo de ladera para los anabáticos y las calles de nubes para la cortina de
  brisa. Cada figura tiene ahora su remisión y su párrafo, en un apartado nuevo de calles de nubes y
  convergencias del relieve. Hallazgo COH-01 de la auditoría del libro 03.
* **cap03, fórmula de la base de los cúmulos, y Glosario y Anki** — la rc.18 le quitó los paréntesis
  (se leía T − 400·T~rocío~) y daba la «altitud» de la base, cuando da la altura sobre el
  aeródromo. Hallazgos TEC-09 y TEC-10 de la auditoría del libro 03.
* **cap03, estabilidad** — faltaba la estabilidad absoluta y la condicional no decía su condición
  (gradiente ambiental entre el saturado y el seco). Hallazgo TEC-11 de la auditoría del libro 03.
* **cap03, índices de sondeo** — se restituyen las fórmulas del TT y del K, perdidas al pasar el
  libro a Quarto; la escala del TT que se atribuía a Miller es la del oeste de EE. UU. y se atribuye
  bien, con la fila de 52 corregida; se retira la regla «TT en el llano, K en la montaña», que
  contradecía a la fuente; el LI tenía el signo invertido; y la tabla resumen y el «día
  termonuclear» quedan dentro de las bandas sin tormenta de sus propias tablas. También en Anki.
  Hallazgos TEC-12 a TEC-15 y COH-02 de la auditoría del libro 03.
* **cap04, clasificación de nubes** — la OMM reparte los diez géneros en tres pisos, no en cuatro
  familias, y las alturas no coincidían con las suyas. Los géneros pasan a una tabla, que el texto
  ya anunciaba. Hallazgos TEC-16 y PED-08 de la auditoría del libro 03.
* **cap04, neblina, y Glosario y Anki** — tres umbrales distintos: se unifica en 1.000 m o más, con
  `BR` hasta 5.000 m en el METAR, y se distingue de la calima. Hallazgo COH-03 de la auditoría del
  libro 03.
* **cap04, niebla de advección** — se situaba en invierno y otoño; el Atlas Nacional de España la da
  como más frecuente en verano en los sectores costeros. Hallazgo TEC-17 de la auditoría del libro 03.
* **cap05 y cap09, reventón y microrráfaga, y Glosario** — se igualaban; la microrráfaga es un
  reventón de menos de unos 4 km, y también aparece bajo cúmulos con virga. Hallazgo TEC-18 de la
  auditoría del libro 03.
* **cap04, cap05, cap06, cap07 y cap08, cifras de seguridad, y Anki** — la separación de un Cb, el
  margen con lluvia, los 500 km de una depresión y los 300 ft sobre sotavento se daban como reglas
  sin fuente. Quedan como orientación, con la de la FAA para los Cb y la remisión al AFM para la
  lluvia. Hallazgo PED-02 de la auditoría del libro 03.
* **cap06, frentes** — el frente cálido no estabiliza «completamente»: con aire cálido inestable
  puede esconder Cb embebidos; el frente estacionario separa masas distintas, no similares; y la
  masa polar marítima tras un frente frío es típica de la primavera, no del verano. Hallazgos
  TEC-19, TEC-20 y TEC-21 de la auditoría del libro 03.
* **cap08, Baja Térmica Peninsular, y Anki** — no es «permanente»: es casi permanente en verano,
  más marcada por la tarde. Hallazgo TEC-22 de la auditoría del libro 03.
* **cap09, granizo** — faltaba que puede caer bajo el yunque y en aire despejado lejos del núcleo, y
  que basta algo más de 1 cm para dañar la estructura. Hallazgo TEC-23 de la auditoría del libro 03.
* **cap10, SPECI, y Glosario y Anki** — también se emite cuando las condiciones mejoran, en España
  no por el viento salvo criterios locales, y el informe vigente es el de hora más reciente.
  Hallazgo TEC-24 de la auditoría del libro 03.
* **cap10 y Glosario, SKC** — no existe en el METAR europeo: el observador escribe `NSC` o `CAVOK`.
  Hallazgo TEC-25 de la auditoría del libro 03.
* **cap10, AIRMET, GAMET y SIGWX de niveles bajos, y Glosario y Anki** — en España llegan hasta el
  FL150 en toda la FIR, no hasta el FL100. Hallazgo NOR-01 de la auditoría del libro 03.
* **cap10, obligación del briefing, y Anki** — la norma obliga a estudiar los informes y pronósticos
  disponibles (SERA.2010 b), no a «cruzar varias fuentes», y AEMET es la fuente oficial, no
  «legalmente vinculante». Hallazgo NOR-02 de la auditoría del libro 03.
* **Glosario, CAPE, dorsal, SIGMET y turbulencia de estela** — la CAPE se integra desde el LFC, no
  desde la superficie; bajo una dorsal hay térmicas, limitadas en altura; el SIGMET incluye las
  tormentas y la onda orográfica severa; y el balanceo peligroso de la estela llega al entrar
  alineado con ella, no al cruzarla. Hallazgos TEC-26, COH-06, TEC-27 y TEC-28 de la auditoría del
  libro 03.
* **cap01, densidad y rendimiento, y Anki** — decía que con menos densidad hay «menos
  sustentación»; en vuelo estabilizado la sustentación sigue igualando al peso, y lo que cambia es
  la velocidad verdadera para la misma indicada. Hallazgo PED-04 de la auditoría del libro 03.
* **cap03, gradiente saturado, y Anki** — el resumen lo daba como «la mitad» del seco, un valor
  fijo; ronda 1,5 °C/1.000 ft cerca de la superficie en aire templado y aumenta con el frío y la
  altura. Hallazgo PED-05 de la auditoría del libro 03.
* **cap05, lluvia y perfil laminar** — la lluvia adelanta el paso de la capa límite a turbulenta;
  el desprendimiento sólo llega en algunos perfiles. Hallazgo TEC-29 de la auditoría del libro 03.
* **cap06, oclusión y masas de aire** — las térmicas desaparecen por la nubosidad y la lluvia, no
  porque el aire cálido «ya no toque el suelo»; se distingue la oclusión fría de la cálida; y las
  masas se clasifican por su región de origen, con los orígenes europeos y la calima del aire
  tropical continental. Hallazgos TEC-30 y TEC-31 de la auditoría del libro 03.
* **cap07, anticiclón invernal y tabla** — el anticiclón de invierno de la Península suele ser el
  continental europeo, el de las Azores o ambos, no uno «termal» de 3.000–4.000 m; la tabla da la
  circulación de vaguadas y dorsales. Hallazgos TEC-32 y COH-08 de la auditoría del libro 03.
* **cap08, solanas y otoño** — las laderas orientadas al este son las primeras en activarse por la
  mañana, y el otoño no es una estación «de mayor estabilidad». Hallazgo COH-08 de la auditoría
  del libro 03.
* **cap09, engelamiento, rotor y pies de figura** — sólo las gotas pequeñas se congelan al
  instante (hielo opaco); el rotor se delata a veces por nubes de rotor; y los pies del Cb, la
  cizalladura y el flujo sobre crestas describen lo que muestra cada imagen. Hallazgos TEC-33,
  COH-09 y COH-10 de la auditoría del libro 03.
* **cap10 y Glosario, TAF, y Anki** — en España sólo se emiten TAF de 24 y 30 horas, renovados
  cada 6 horas. La entrada del glosario es común con el libro 04. Hallazgo TEC-34 de la auditoría
  del libro 03.
* **cap10, claves del METAR** — `18002KT` no es calma; `VV///` es visibilidad vertical no
  determinable; `NSW` sólo existe en el TAF y el TREND; la cizalladura se cifra `WS R18`; y en
  España hay estaciones automáticas supervisadas. Hallazgo TEC-35 de la auditoría del libro 03.
* **cap10, sondeos** — la diferencia de temperatura con 850 hPa depende de la altitud del campo
  (5–15 °C), y la construcción con la temperatura máxima da la base prevista de los cúmulos,
  próxima al CCL. Hallazgos TEC-36 y TEC-37 de la auditoría del libro 03.
* **Apéndice de fuentes de meteorología** — AMA pasa a un apartado de fuente oficial, con sus
  productos de baja cota (AIRMET, GAMET, SWL), y el criterio de viento para la onda se refiere a
  la altura de las cimas (FAA, *Glider Flying Handbook*). Hallazgos TEC-38 y TEC-39 de la
  auditoría del libro 03.
* **Glosario, varias entradas** — la onda de montaña es *mountain wave* (*wave soaring* es la
  técnica); el hielo puede reducir o anular el bataneo; las nubes de rotor son fractocúmulos; y el
  LCL tiene un solo nombre. Hallazgos TEC-40, TEC-41, COH-10 y PED-10 de la auditoría del libro 03.

### Añadido

* **Glosario, entradas nuevas** — CCL, frente estacionario, nivel de equilibrio, punto de rocío,
  TCU, Total Totals y TREND, que los capítulos usaban sin definir. Hallazgo PED-10 de la auditoría
  del libro 03.
* **cap03, resumen** — el post-it recoge la fórmula de la base de los cúmulos y el gradiente del
  punto de rocío (0,5 °C/1.000 ft). Hallazgo PED-06 de la auditoría del libro 03.
* **cap01, composición y capas de la atmósfera, y altitudes de presión y de densidad, con su entrada
  en el Glosario** — el capítulo usaba «troposfera» y «altitud de densidad» sin definirlas.
  Hallazgo SYL-01 de la auditoría del libro 03.
* **cap05, formación y tipos de precipitación** — el capítulo sólo trataba los efectos sobre el
  planeador. Hallazgo SYL-02 de la auditoría del libro 03.
* **cap10, radar, satélite y mapas del tiempo** — un apartado breve. Hallazgo SYL-03 de la auditoría
  del libro 03.
* **Bibliografía, meteorología** — la bibliografía no recogía ninguna fuente meteorológica. Se
  añade un bloque propio del libro 03 (Parte MET del Reglamento 2017/373, AIP GEN 3.5, Atlas de
  Nubes de la OMM, circulares de la FAA, manual AWS/TR-79/006 y Atlas Nacional de España). Hallazgo
  COH-07 de la auditoría del libro 03.

### Cambiado

* **Erratas y léxico** — «algodonosos», «tiempo útil de conciencia», «sin aire inestable»,
  «energía del impacto», «material compuesto», «frente frío» sin «intercontinental», «nieblas
  frontales», ángulo de cruce del viento en superficie (10–45°), signo de grado en las tarjetas
  Anki y frases que daban por hecho qué «cae en el examen». Hallazgos PED-09 y PED-16 de la
  auditoría del libro 03.
* **Epígrafe y apéndice del syllabus** — el epígrafe dice de dónde sale la cita de Wilbur Wright,
  y el apéndice, que la lista es una traducción propia del AMC1 SFCL.130 y cómo es el examen.
  Hallazgos PED-14 y PED-15 de la auditoría del libro 03.
* **Reconocimientos (preliminares)** — se explica qué significa la marca ✓: quien la lleva ha
  revisado el libro con criterio de instructor, lo que no certifica cada afirmación técnica ni
  normativa. La frase de los autores de los manuales clásicos se separa de la lista de revisores.
  Común a los nueve libros. Hallazgos PED-03 y PED-13 de la auditoría del libro 03.
* **Bibliografía, ediciones** — el *Glider Flying Handbook* lleva su año (2024), las *Easy Access
  Rules for Sailplanes* su revisión (septiembre de 2020) y el libro de Reichmann su editorial y año
  (Paraninfo, 1992). Común a los nueve libros. Hallazgo PED-12 de la auditoría del libro 03.
* **Bibliografía, anexos de la OACI** — el Anexo 3 (servicio meteorológico para la navegación
  aérea) pasa a la lista de los más relevantes para el piloto de planeador. Común a los nueve
  libros. Hallazgo PED-12 de la auditoría del libro 03.
* **Figuras por rehacer: marca «EN REVISIÓN» y nota en el pie** — tres figuras en las que la
  auditoría encontró errores llevan encima, en diagonal, la marca «EN REVISIÓN», en el PDF, el EPUB
  y la web, y su pie termina con *(CORREGIR: …)*: el cálculo gráfico de la base de los cúmulos
  (cap03), cuyas curvas no cuadran con sus datos; la estructura del frente frío (cap06), con la cuña
  fría en el lado prefrontal; y el mapa SIGWX (cap10), que da las alturas en hPa, un V5 de 5 a 8 km
  y llama frente a una zona de nubes. El pie del SIGWX dice además que es una recreación de un mapa
  de niveles bajos (SWL). En una segunda pasada se marcan otras siete: la atmósfera ISA (cap01), mal
  trazada; las isobaras (cap02), con el viento de la alta a la baja; las familias de nubes (cap04) y
  el frente ocluido (cap06), con el nimboestrato en el piso bajo; el frente cálido (cap06), «aire
  totalmente estable»; el ciclo de la tormenta (cap09), con cuatro fases; y la estela (cap09), que no es la foto de la NASA
  que decía su pie. Al sustituir cada figura se quitan la marca y la nota. Hallazgos TEC-01, TEC-04,
  TEC-05, TEC-06, PED-01, TEC-16, TEC-19, COH-04 y COH-05 de la auditoría del libro 03.

## [1.0-rc.19] — 21 de noviembre de 2026

**Qué releer:** nada. El contenido no cambia respecto a la `1.0-rc.18`: sólo el índice alfabético
del PDF, que es maqueta.

### Maqueta y producción

* **Índice alfabético del PDF** — cada entrada usa el rótulo del glosario, no su equivalente inglés ni la clave de búsqueda más larga. Las siglas aparecen por la sigla y por su desarrollo («CTR» y «Zona de control»). El cambio está en el filtro común `glosario-enlaces.lua` y afecta a los nueve libros (#46). La palabra «visibilidad» deja de enlazar con la entrada CAVOK del glosario.

## [1.0-rc.18] — 18 de noviembre de 2026

**Qué releer:** **cap03, base de los cúmulos**, y **cap07, sistemas de presión**. Cambia la notación, no los datos.

### Cambiado

* **cap03, base de los cúmulos** — la fórmula pasa a notación matemática y el 2.5 a coma decimal. Los valores no cambian.
* **cap07, sistemas de presión** — «H. Norte» se escribe «hemisferio norte» en la tabla y en las dos viñetas.

### Maqueta y producción

* **Reconocimientos** — Luís Ferreira, Encarnación Novillo-Fertrell, Carlos Bravo y Sergi Pujol aparecen ya con su ✓ de validación técnica en este libro.
* **Estado editorial** — los candidatos de versión dejan de salir como «En revisión» y pasan a «Candidato de versión» en la marca de agua, la portadilla y el aviso del EPUB. La nota dice que la revisión técnica por los instructores está completada.

## [1.0-rc.17] — 2 de octubre de 2026

**Qué releer:** **cap06, mínimos VFR en clase G e IMC sin habilitación**, en el **Glosario** la entrada *CAVOK*, la **licencia** de los preliminares y la **Bibliografía**.

### Corregido

* **cap06, mínimos VFR en clase G, y su tarjeta Anki** — decía que la visibilidad «puede reducirse
  hasta 1.500 m para vuelos a 140 kt o menos». SERA sólo lo permite si lo prescribe la autoridad
  competente, y en España sólo se ha hecho para helicópteros y aviones de operaciones aéreas
  especializadas (Real Decreto 1180/2018, art. 30): para un planeador el mínimo sigue siendo 5 km.
  Hallazgo NOR-01 de la auditoría del libro 01.
* **Bibliografía, SERA y Real Decreto 1180/2018** — la entrada de SERA decía que «en España se aplica
  mediante el Real Decreto 552/2014». SERA es un reglamento de la UE y se aplica directamente, sin
  transposición; y el RD 552/2014 está derogado desde el 11 de noviembre de 2018 por el Real Decreto
  1180/2018, que es quien lo desarrolla hoy. Se corrige la entrada y se añade una para el RD
  1180/2018. Hallazgo NOR-02 de la auditoría del libro 01.
* **cap06, mínimos VFR en clase G** — la franja baja es «3.000 ft AMSL o 1.000 ft sobre el
  terreno, el mayor de los dos valores», como dice SERA.5001; faltaba el criterio. Hallazgo TEC-04
  de la auditoría del libro 01.
* **Bibliografía, normas citadas** — la bibliografía no recogía buena parte de las normas que
  citan los capítulos. Se añade una lista de normas consolidadas con su enlace (Reglamentos
  2018/1139, 1178/2011, 1321/2014, 2017/373, 2150/2005, 996/2010, 376/2014, 2015/1018, 300/2008,
  2015/1998 y 785/2004; Leyes 48/1960, 209/1964 y 2/2024; Reales Decretos 184/2008, 1088/2020,
  1189/2011 y 1029/2025; Orden FOM/1687/2015), el enlace consolidado de la Ley 21/2003 y los anexos
  17 y 18 entre los más relevantes. El 2018/1976 se cita como Reglamento de Ejecución. Hallazgo
  NOR-18 de la auditoría del libro 01.
  La lista ya no se presenta como «versiones consolidadas»: los enlaces llevan a la norma original,
  desde la que EUR-Lex y el BOE dan acceso a la consolidada (hallazgo NOR-10 de la auditoría del
  libro 02).
* **Licencia (preliminares)** — el syllabus se atribuía a «EASA-FCL»; el AMC1 SFCL.130 pertenece a
  la Part-SFCL. Hallazgo NOR-19 de la auditoría del libro 01; el rótulo «Validación por AESA» se
  mantiene.
* **cap06 y su tarjeta Anki, IMC sin habilitación** — se calificaba de «infracción grave». La Ley
  de Seguridad Aérea gradúa las infracciones del piloto por sus consecuencias (art. 44), así que no
  tiene una gravedad fija; se dice que incumple las reglas del aire y que es una causa clásica de
  accidente. Hallazgo NOR-06 de la auditoría del libro 01.
* **Glosario, CAVOK** — faltaban la altitud mínima de sector más alta, los torrecúmulos y que no se
  notifique la visibilidad mínima (Reglamento de Ejecución (UE) 2017/373). Se alinea con el libro 01
  y con el cap10 de este libro. Hallazgo TEC-11 de la auditoría del libro 01.

## [1.0-rc.16] — 16 de agosto de 2026

**Qué releer:** **cap10 entero, y las entradas «LCL» y «NSC» del glosario.** Una auditoría externa
encontró cuatro errores técnicos en el apartado de sondeos, y uno de ellos —la temperatura a 850 hPa—
era físicamente imposible. El LCL estaba mal definido, el LFC estaba traducido como «nivel de
condensación» y la regla del LCL alto inducía a error. El apartado de METAR y TAF gana la cadena de
ejemplo completa, SPECI, las cuatro octas y varios indicadores que faltaban.

### Corregido

* **cap10, sondeos (10.3)** — el LCL **no** es donde se juntan la curva de temperatura y la del
  punto de rocío: eso es una capa ya saturada. Se describe la construcción correcta —adiabática
  seca desde la temperatura, línea de relación de mezcla saturante desde el punto de rocío— y se
  enlaza con la Regla de oro de cap03, que es su aproximación aritmética. Se añade que, con la
  temperatura máxima prevista, lo que se obtiene es el CCL, que es el criterio que ya usaba el techo
  térmico.
* **cap10, sondeos (10.3)** — el umbral fijo de «LCL por encima de 3.000 m ⇒ térmica seca» se
  sustituye por lo que de verdad decide si hay cúmulos: la posición del LCL **relativa al techo
  térmico**. Un LCL a 3.000 m con el techo a 4.000 da un día magnífico.
* **cap10, sondeos (10.3)** — el `LFC` pasa a llamarse «nivel de convección libre», como ya lo
  llamaba el glosario; hasta ahora el capítulo daba el mismo nombre castellano a dos siglas
  distintas. La definición del techo térmico deja de ser circular.
* **cap10, recuadro «Regla de oro»** — la temperatura a 850 hPa se compara con **su media
  climatológica para la fecha**, no con la superficie: a 1.500 m el aire está normalmente 10-15 °C
  por debajo del suelo, y lo contrario describiría el día sin una sola térmica. Los umbrales de CAPE
  del capítulo se alinean con los del glosario (vigilancia por encima de 2.500, convección severa
  probable por encima de 3.500).
* **cap10, tabla METAR vs TAF** — la frecuencia de emisión del TAF pasa a los valores de OACI
  Anexo 3: cada 3 h los de 9 h de validez, cada 6 h los de 24 y 30 h. El «1-2 veces al día» anterior
  no correspondía a ningún caso.
* **cap10, SIGWX (10.2)** — SIGMET, AIRMET y GAMET se separan en tres viñetas. El límite de FL100
  o FL150 es del AIRMET; el SIGMET cubre cualquier nivel de la FIR.
* **cap10, recuadro «Airmanship»** — se retiran los NOTAM de la lista de productos de AEMET: los
  publica el servicio AIS (ENAIRE), aunque SNOWTAM y ASHTAM se nutran de datos de AEMET.
* **cap10, CAVOK y NSC** — CAVOK abandona el retroacrónimo «Ceiling And Visibility OK», como ya
  habían hecho los glosarios, y precisa que la ausencia de Cb y TCU es **a cualquier nivel**. `NSC`
  pasa a «No Significant Cloud», en singular, y recoge la condición de la altitud mínima de sector.
* **Glosario, «LCL»** — misma corrección de la construcción gráfica que en cap10.
* **Glosario, «NSC»** — singular, con TCU, la altitud mínima de sector y la aclaración de que sólo
  se usa cuando no procede CAVOK.
* **cap10, ortotipografía** — «No te fíes» con tilde, «9, 24 o 30 horas» y «FL100 o FL150» sin la
  tilde que la RAE retiró en 2010, y «Regla de oro» con la capitalización del recuadro.

### Añadido

* **cap10, ejemplo de decodificación (10.1.1)** — se imprime la **cadena METAR completa** antes de
  descomponerla. Faltaba: el apartado enseñaba a leer los grupos ya segmentados, que es la parte
  fácil, y la última viñeta hablaba de un `=` que no aparecía en ninguna parte.
* **cap10, ejemplo de decodificación (10.1.1)** — el `OVC040` del ejemplo se explota en vez de
  disimularse: es un **no-go** para vuelo a vela, porque sin sol no hay convección. Y lista de los
  grupos frecuentes que el ejemplo no trae (`G`, `VRB`, `V`, `VV///`, `NSW`, `RE`, `WS`, `AUTO`, `M`,
  `A2992`, `COR`, `AMD`).
* **cap10, METAR y TAF (10.1)** — el **SPECI**, que no se mencionaba ni una vez; las cuatro octas
  completas en tabla (`FEW`, `SCT`, `BKN`, `OVC`), de las que sólo estaban las dos del ejemplo;
  `NCD` y `SKC`, que se confunden con `NSC`; `FM` entre los indicadores de cambio del TAF; y la
  precisión de que `PROB30` y `PROB40` son los dos únicos que existen.
* **cap10, recuadro «Normativa» nuevo** — el viento del METAR y el TAF va referido al norte
  verdadero, y el de la Torre al magnético. Punto de examen habitual, hasta ahora sólo tratado en el
  libro de Comunicaciones.
* **Glosario** — entrada «SPECI».
* **Mazo Anki de cap10** — cuatro tarjetas nuevas (SPECI, octas, viento verdadero frente a
  magnético, SIGMET frente a AIRMET). Las tres que repetían errores del capítulo —el CAVOK sin la
  condición de Cb y TCU, el NOTAM atribuido a AEMET y el «mapa de superficie + satélite»— quedan
  corregidas sin cambiar su identificador, para que la reimportación actualice y no duplique.

### Maqueta y producción

* **cap10, figura del sondeo** — el fichero `03-cap03-indices-estabilidad.jpg` pasa a llamarse
  `03-cap10-indices-estabilidad.jpg`. El nombre venía de una reutilización y sólo lo usa el
  capítulo 10.
* **Apéndice «Fuentes de meteorología»** — el enlace de RASP pasa a `http://`. El sitio del Dr. Jack
  no sirve por HTTPS —el puerto 443 ni siquiera responde—, así que el enlace anterior no abría nada.
* **cap10, tablas** — las dos tablas del capítulo reciben su `{#tbl-…}` y se citan desde la prosa.
  Sin identificador, Quarto no las convierte en float y **el pie no llega al PDF**, aunque en la web
  sí salga. Efecto lateral buscado: el PDF del libro pasa a tener índice de tablas, que hasta ahora
  salía vacío y por eso no se imprimía.

### Pendiente

* **cap10, recuadro «Regla de oro»** — queda por revisar con un instructor de travesía el fondo del
  heurístico, no ya su coherencia interna: para vuelo a vela puede ser discutible que un CAPE de
  1.000-2.500 J/kg sea la firma del día excepcional y no la del día con riesgo de sobredesarrollo.
  Los *boomers* clásicos suelen tener CAPE modesto y lo que los define es una capa adiabática seca
  profunda.
* **cap10** — quedan fuera de esta versión los epígrafes del syllabus sobre imágenes de satélite,
  radar meteorológico y mapas de superficie y de altura. El resumen del capítulo ya no los promete.

## [1.0-rc.15] — 7 de agosto de 2026

**Qué releer:** **nada.** El único cambio es el enlace del apéndice del syllabus y su QR; ni el texto ni las figuras cambian.

### Maqueta y producción

* **Apéndice del syllabus, «Ponte a prueba»** — el enlace pasa de `/tests/` a `/examenes/`; el PDF añade un QR hacia la misma página. No cambia lo que se estudia.

## [1.0-rc.14] — 2 de agosto de 2026

**Qué releer:** **Glosario, entradas «Niebla», «Bataneo» y «K-Index»; cap09, recuadro de engelamiento; cap03, tabla del K-Index.** La bruma sí impide el CAVOK, al contrario de lo que decía. Entrada nueva de «Bataneo». Bajo la tabla del K-Index se explica de dónde salen sus bandas; los valores no cambian.

### Añadido

* **Glosario** — entrada «Bataneo (buffet)»: qué es la vibración, que es el aviso previo a la pérdida y por qué el hielo estructural lo suprime. El término lo usaba ya el cap09 sin definirlo aquí.

### Cambiado

* **Glosario, entradas «Hipoxia» e «IAS»** — se unifican con las de los libros que también las definen, para que el manual completo no tenga que elegir entre versiones distintas del mismo término. «Hipoxia» gana los cuatro tipos que sólo estaban en el libro 02; «IAS» gana el encadenado IAS → TAS → GS que sólo estaba en el libro 09. Nada de lo que ya decían cambia.
* **cap03, K-Index** — bajo la tabla de umbrales se dice de dónde salen: las bandas altas son la escala de George de probabilidad de tormenta; las tres primeras filas, una adaptación de esta colección, porque por debajo de 15 la escala meteorológica no distingue. Mismo tratamiento que ya tenía el Total Totals. Los valores de la tabla no cambian.
* **Glosario, rótulos de `CAVOK` y `QNH`** — se alinean con el libro 01. `CAVOK` abandona el retroacrónimo «Ceiling And Visibility OK», que no es la denominación de OACI, y lo recoge dentro de la definición junto con las condiciones concretas. `QNH` recupera su glosa.
* **Glosario, rótulos de `CAPE`, `DALR`, `SALR` y `SIGWX`** — el nombre español estaba como primera frase de la definición y ahora va en el rótulo, sin repetirse. Los nombres de mensaje meteorológico (`METAR`, `TAF`, `SIGMET`, `AIRMET`, `GAMET`, `NSC`) se dejan como están: no se traducen.

### Corregido

* **Glosario, entrada «Niebla»** — decía que la bruma reduce la visibilidad a entre 1.000 y 5.000 m «sin afectar el código CAVOK». Es al revés: CAVOK exige 10 km o más, así que con bruma no puede haberlo.
* **Glosario, entrada «K-Index»** — las bandas no llevaban procedencia y parecían discrepar de la escala meteorológica. Se aclara que las altas concuerdan con la escala de George y que las bajas son la adaptación al vuelo a vela.

### Maqueta y producción

* **cap09, engelamiento** — el recuadro de Seguridad dice «bataneo» y no «buffet», que es el término que usan el capítulo de pérdida del libro 05 y el glosario. Se redacta además «muy por encima de la velocidad habitual» en lugar de «a velocidades muy superiores a las habituales». El aviso no cambia.
* **Glosario** — se restituye el orden alfabético: `Cúmulo` iba detrás de `Cumulonimbus`, `IAS` detrás de `Inversión térmica` y las dos nieblas estaban invertidas. Ninguna definición cambia.
## [1.0-rc.13] — 31 de julio de 2026

**Qué releer:** **cap09, ciclo de vida de la célula tormentosa.** La figura que acompaña al apartado era un boceto provisional —llevaba impreso «MOCKUP — ToDo: crear ilustración final»— y se ha publicado así en varias versiones. Ya es una ilustración de verdad. El texto de las tres fases no cambia; lo que cambia es que ahora la figura lo sostiene.

### Añadido

* **cap09, ciclo de la tormenta** — la ilustración definitiva desarrolla las fases de cúmulo, desarrollo, madurez y disipación, con las corrientes ascendente y descendente, la isoterma de 0 °C, dónde hay gotas, nieve y hielo, el tipo de precipitación de cada fase y la escala de tiempo (0 a 30 min aprox.). Todo ello ya estaba en el cuerpo del apartado.

### Maqueta y producción

* **cap09, cizalladura** — la nube pasa de contorno esquemático a cúmulo con volumen, y las flechas de flujo ascendente interno del ámbar al rojo. Las tres viñetas y la leyenda no cambian.
* **cap02, convergencia topográfica** — se retira la línea horizontal que partía el cuadro entre los paneles A y B: separaba dos vistas del mismo fenómeno como si fueran figuras distintas.

## [1.0-rc.12] — 29 de julio de 2026

### Maqueta y producción

* **Glosario** — las dos velocidades V de la entrada de IAS se escriben ya con subíndice (`V~NE~`, `V~A~`), como las componen CS-22 y 14 CFR §1.2 y como estaban en el resto de la colección. No cambia ningún dato.

## [1.0-rc.11] — 28 de julio de 2026

**Qué releer:** **Apéndice «Fuentes de meteorología para vuelo a vela».** Se añaden herramientas de pronóstico y criterios para revisar condiciones de onda.

### Añadido

* **Apéndice «Fuentes de meteorología para vuelo a vela»** — relación de herramientas específicas y generales, con enlaces y pautas para interpretar pronósticos de onda de montaña.

## [1.0-rc.10] — 27 de julio de 2026

**Qué releer:** **cap03, índices de estabilidad; cap04, clasificación de nubes.** Se retiran atribuciones concluyentes sobre qué contenido aparece en el examen. El contenido técnico no cambia.

### Cambiado

* **cap03** — las bandas de referencia de los índices de estabilidad se presentan como síntesis operativa, sin atribuirlas al examen.
* **cap04** — se elimina la afirmación de que el examen pregunta los diez géneros de nubes.

### Maqueta y producción

* **Maquetación Typst** — corrección del solapamiento en páginas de parte y ajuste de la marca de agua «En revisión».
* **Índice alfabético** — la ordenación española ignora las tildes y la diéresis de las vocales.

## [1.0-rc.9] — 22 de julio de 2026

**Qué releer:** **Glosario.** Se normalizan las referencias a capítulos en las definiciones. El temario no cambia.

### Cambiado

* **Glosario** — se eliminan las referencias redundantes a capítulos en las definiciones de términos y acrónimos.

### Maqueta y producción

* **Créditos** — se añade un espaciado vertical (`v(1.5em)`) al bloque de créditos en la maquetación Typst para evitar que queden demasiado juntos con el contenido adyacente.
* **Colofón** — se homogeneiza el texto del colofón en todos los libros para que sea idéntico al de Derecho Aéreo, incluyendo la referencia dinámica al repositorio y el uso de Quarto y la extensión `orange-book-es`.
* **Índice alfabético** — generación automática de un índice de términos al final del libro para la versión PDF (Typst), utilizando el paquete `in-dexter` y referenciando los términos del glosario a 3 columnas.
* **Enlaces al glosario** — enlace automático en el PDF (Typst) de la primera aparición de cada término y acrónimo del glosario en el cuerpo de cada capítulo.

## [1.0-rc.8] — 19 de julio de 2026

**Qué releer:** **cap02, recuadro de Seguridad sobre gradiente de viento; cap04, desarrollo vertical.** Se restaura texto que el importador perdió al migrar enlaces con cursiva interna.

### Cambiado

* **cap02** — se restituye la mención inglesa *wind shear* que faltaba en el recuadro sobre viento en superficie.
* **cap04** — se restituye *Cúmulo Congestus* en la cadena de desarrollo vertical hacia Cumulonimbus.

## [1.0-rc.7] — 18 de julio de 2026

**Qué releer:** **Preliminares, página de licencia.** El temario no cambia.

### Cambiado

* **Licencia** — la mención institucional pasa de «avalado por AESA» a «temarios validados por
  AESA», siguiendo la formulación indicada por AESA.

## [1.0-rc.6] — 18 de julio de 2026

**Qué releer:** **Glosario:** CAVOK y QNH alineados con el libro 1. **Preliminares, página de licencia.** El temario no cambia.

### Cambiado

* **Glosario** — definiciones de CAVOK y QNH normalizadas con el glosario canónico del libro 1; retiradas las etiquetas `(Mencionado en: ...)`.
* **Licencia** — el libro pasa a **CC BY-SA 4.0**: mantiene atribución y añade la
  obligación de compartir las adaptaciones bajo la misma licencia o una compatible.

## [1.0-rc.5] — 17 de julio de 2026

**Qué releer:** **Los títulos tocados, el epígrafe y el alcance de las secciones marcadas; ni una
línea del temario.** El texto de los capítulos no cambia. Lo que cambia son decisiones editoriales
—la cita de apertura y qué queda señalado como ajeno al examen—, y se confirman en un minuto.

Los títulos de capítulo se comían el paréntesis en inglés que trae el syllabus. El syllabus es la
raíz del proyecto y el título copia su entrada; sólo se le aplica la norma española de mayúsculas y
los términos ingleses van en cursiva. El CI lo comprueba ahora en los 76 capítulos de la colección.

### Cambiado

* **Título de `cap09`** — «Peligros para el vuelo (*flight hazards*)», como en el syllabus.
* **cap03, «Índices de estabilidad: el termómetro del día»** — la sección queda marcada entera como
  «Más allá del examen», sobre fondo gris, incluidas sus tres subsecciones. Antes la marca era sólo
  una entradilla al principio y no se veía dónde acababa el material avanzado.
* **cap10, «Sondeos termodinámicos y curvas de temperatura»** — igual, sin subsecciones. En los dos
  capítulos el resumen queda fuera del gris, como manda la convención: este material no se recoge en
  el post-it.
* **Epígrafe** — el libro abre ahora con una cita propia, de Wilbur Wright, elegida para esta
  asignatura. Los 9 libros compartían la misma cita de Frank Borman, que además pertenece a Factores
  Humanos.

### Maqueta y producción

Nada de esto altera lo que el lector aprende; el revisor puede saltárselo.

* **Los post-it y los créditos se componían en serifa, no en palo seco.** Typst no empotra
  Libertinus Sans —sólo la Serif—, la fuente estaba en la máquina de desarrollo y no en el servidor
  que publica, y Typst no avisa cuando le falta una: compone con otra y sigue. Los PDF publicados
  llevaban meses así. Ahora la fuente viaja en el repositorio y el CI falla si alguna no llega.
  Cambia el aspecto de los resúmenes de capítulo y de los créditos; el texto no.
* **La página de créditos se rediseña.** Salía amontonada y con un tercio del papel en blanco
  debajo. No era la interlínea —135,8 %, dentro de la banda recomendada—: eran el cuerpo a 8,5 pt,
  los párrafos un 27 % más juntos que en el libro y, sobre todo, unos rótulos de sección que eran
  negrita suelta, sin nada que los separase del texto. Ahora los rótulos son encabezados de verdad
  (en el EPUB también se pueden estilar, que antes no), la licencia lleva su distintivo de Creative
  Commons y sus condiciones a dos columnas, la exención de responsabilidad va en un recuadro ámbar y
  el aval en uno gris. Sigue cabiendo en una página, y ahora el CI lo comprueba.
* **Se retira «Fuentes y agradecimientos» de la página de créditos.** No se pierde nada: la
  bibliografía ya acredita el *Glider Flying Handbook* de la FAA —y dice que es la fuente de buena
  parte de las ilustraciones—, y los reconocimientos ya acreditan a Iñaqui con sus
  credenciales. Era una duplicación, y es la que hacía que la página no cerrase.
* Los tres gradientes de `cap03` —DALR, SALR y LI— llevaban el término inglés en negrita dentro de
  una negrita, que Markdown no admite: el `**` interior cerraba el exterior, así que el desarrollo
  salía sin resaltar y el paréntesis de cierre en negrita. Pasan a cursiva, como los otros 15 casos
  de la colección. El CI lo comprueba ahora en los 176 `.qmd`, sobre el árbol de pandoc: eran las
  tres únicas, y aparecieron de casualidad.
* El pie de la figura de la cizalladura (`cap09`) estaba cortado: decía «Reventón (» y ahí acababa.
  Se restaura desde el AsciiDoc de origen, con **downburst** en negrita como lo escribe el cuerpo
  del capítulo.
* El índice, la lista de ilustraciones y la de tablas bajan de cuerpo. Estaban a 15/13/11/11 pt
  con el texto del libro a 10: hasta la subsección más profunda era mayor que lo que se lee.
* La banda azul de la portadilla crece si el título no cabe en una línea. Tenía altura fija y
  el título del libro 8 la desbordaba, dejando la nota de estado y la versión pisándose fuera
  del recuadro.
* Se normalizan los títulos de capítulos, secciones, portadillas y apéndices a la capitalización
  propia del español.
* Los entregables llevan ahora la versión y la fecha en el nombre
  (`03-meteorologia-1.0-rc.4-260716.pdf`), para identificarlos sin abrirlos.
* **Cada libro se publica también como un solo Markdown** (`make rag`, a
  `build/rag/03-meteorologia-1.0-rc.4-260716.md`), para cargarlo como fuente en un asistente de
  estudio con recuperación (NotebookLM y similares). No es el libro en crudo: un RAG no ve la
  maqueta, sino trozos sueltos de texto, y cada trozo tiene que explicarse solo. Los recuadros
  conservan su etiqueta como texto, el resumen de cada capítulo pasa a ser un apartado propio, las
  referencias a figuras se resuelven a «figura 5.1» y las ilustraciones se sustituyen por su pie. El
  temario entra íntegro —capítulos, apéndices, glosario y bibliografía—; quedan fuera los
  preliminares, el colofón y la guía de lectura, que explica la maqueta y es idéntica en los nueve.
* Los EPUB se publicaban como **XHTML mal formado**: unos comentarios del CSS abrían etiquetas que
  nunca cerraban y un lector estricto podía rechazarlos. Corregido, y el CI lo comprueba ahora.
* Cada libro abre con su propia cita, así que el guardián que exigía epígrafes idénticos se ha
  invertido: ahora exige que los 9 sean distintos.

### Estado en esta versión

* 10 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **En revisión**, deducido de la versión 1.0-rc.5.
* La marca de agua y el aviso del EPUB desaparecen solos al pasar a `1.0.0`.

## [1.0-rc.4] — 16 de julio de 2026

Versión base del registro. Lo anterior a esta fecha no está detallado entrada por entrada: el libro
se escribió antes de que existiera este fichero.

**Qué releer:** **Todo el temario.** Es la primera revisión técnica completa del libro: no hay una versión revisada anterior con la que comparar.

### Estado en esta versión

* 10 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **En revisión**, deducido de la versión 1.0-rc.4.
* La marca de agua y el aviso del EPUB desaparecen solos al pasar a `1.0.0`.
