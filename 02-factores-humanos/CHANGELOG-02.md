# Registro de cambios — 02. Factores Humanos

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

**Qué releer:** las correcciones de la auditoría del libro 02 del 1 de octubre de 2026 (`recursos/auditorias/`, con su seguimiento): **cap01, Maslow**; **cap02, IMSAFE, visión del color, vigilancia antes de virar y alcohol**; **cap03, DECIDE**; **cap04, tiempo útil de conciencia, hiperventilación y cánula**; y, en una segunda pasada, buena parte de los cuatro capítulos, el glosario y la bibliografía (estadísticas y definición del cap01, cultura justa, MED.A.020, ver y evitar, estrés, fatiga, deshidratación, medicación, dopaje, disbarismos y buceo, sobrecarga y conciencia situacional, Dalton, euforia, regla del oxígeno, botella, diagnóstico diferencial y pulsioxímetro); y, en una tercera, retoques menores (Reason, IMSAFE, agujero negro, PAVE y 3P, memoria, hipoxia histotóxica, equipos de oxígeno, el **apéndice del syllabus** y el **epígrafe**). Además, del libro 01: **cap04, AMC del oxígeno**, la **licencia** de los preliminares y la **Bibliografía**, que añade la lista de normas citadas en la colección.

### Corregido

* **cap01, pirámide de Maslow** — el texto decía que «la seguridad ocupa la base de la pirámide».
  En Maslow la base son las necesidades fisiológicas y la seguridad es el segundo nivel, como ya
  dibujaba la figura. Se enumeran los cinco niveles en orden y la conclusión práctica pasa a ser que
  las necesidades fisiológicas y de seguridad deben estar cubiertas antes de perseguir objetivos de
  orden superior. Hallazgo TEC-01 de la auditoría del libro 02.
* **cap02, alcohol** — el AMC1 SAO.GEN.130(f) y SAO.GEN.135(b) se presentaba como «límite legal» y
  «regla sin excepciones». Es un medio aceptable de cumplimiento; la norma (SAO.GEN.130 f),
  SAO.GEN.135 b) y SERA.2020) no fija una tasa, sino que prohíbe volar con las facultades mermadas,
  y una tasa menor de 0,2 g/l no ampara a quien las tiene. Se añade que en España volar bajo la
  influencia del alcohol es delito (Ley 209/1964, art. 31) y se retira la referencia a un formulario
  de AESA que no se ha podido localizar. Cambian el recuadro de normativa, la letra A de IMSAFE, el
  post-it y la tarjeta `alcohol-botella-al-mando`. Hallazgo NOR-01 de la auditoría del libro 02.
* **cap02, visión del color** — el recuadro decía que la percepción de los colores es obligatoria y
  que, sin ella, la licencia Part-SFCL queda restringida al vuelo diurno. Para la SPL basta el
  certificado médico LAPL, con el que la visión del color sólo se evalúa si se pide la habilitación
  nocturna (MED.A.030); el test de Ishihara y la limitación al vuelo diurno son de los certificados
  de clase 1 y 2 (MED.B.075), y todo ello es Part-MED, no Part-SFCL. Recuadro y tarjeta
  `vision-de-color-ishihara`. Hallazgo NOR-02 de la auditoría del libro 02.
* **cap02, vigilancia antes de virar** — el recuadro mandaba mirar hacia atrás por el lado opuesto
  al viraje. Ahora se despeja primero el sector hacia el que se vira y después el lado opuesto y por
  detrás (FAA, *Glider Flying Handbook*, cap. 7). Recuadro y tarjeta `angulo-muerto-antes-de-virar`.
  Hallazgo TEC-02 de la auditoría del libro 02; la secuencia exacta queda pendiente de un FI(S).
* **cap03, modelo DECIDE** — los pasos 4 y 5 estaban cambiados («Implementar» donde va *Identify* y
  «Determinar resultados» donde va *Do*). Pasan al orden Detect, Estimate, Choose, Identify, Do y
  Evaluate, el mismo que ya tenía el glosario. Hallazgo TEC-03 de la auditoría del libro 02.
* **cap04, tiempo útil de conciencia** — el texto remitía a una «tabla» que es una figura y no daba
  ninguna cifra. Ahora da los valores de la FAA (de 22.000 a 35.000 ft) y avisa de que son medias que
  varían con la persona y el esfuerzo. Tarjeta `tuc`. Hallazgo COH-02 de la auditoría del libro 02.
* **cap04, hiperventilación** — un recuadro de seguridad prohibía dar oxígeno ante una
  hiperventilación «a baja altitud», porque agravaría el desequilibrio de CO~2~. La OACI (Doc 8984)
  y la FAA (AIM 8-1-3) mandan lo contrario: ante la duda, oxígeno primero, comprobar el equipo y
  después controlar la respiración; el oxígeno no empeora la hiperventilación, y las dos pueden
  darse a la vez. Cambian el recuadro, la regla de oro del diagnóstico («en caso de duda, a
  cualquier altitud, trate primero la hipoxia»), el post-it y las tarjetas
  `distinguir-hipoxia-de-hiperventilacion` y `no-dar-oxigeno-en-hiperventilacion`, que conserva su
  `id` aunque diga ya lo contrario. Hallazgo TEC-04 de la auditoría del libro 02; la redacción clínica queda pendiente de un
  médico aeronáutico.
* **cap04, límite de la cánula** — no se decía que la cánula sólo es adecuada hasta unos 18.000 ft
  (FL180) y que por encima hace falta mascarilla, porque al hablar o respirar por la boca deja de
  aportar oxígeno suficiente (FAA, folleto *Oxygen Equipment*). Se añade, con la mascarilla hasta
  unos 25.000 ft y la recomendación de un oxígeno de respaldo en onda. Texto, post-it y tarjeta
  `flujo-continuo-vs-eds`. Hallazgo TEC-05 de la auditoría del libro 02; pendiente de validar por un FI(S) con experiencia de onda.
* **Bibliografía, SERA y Real Decreto 1180/2018** — la entrada de SERA decía que «en España se aplica
  mediante el Real Decreto 552/2014». SERA es un reglamento de la UE y se aplica directamente, sin
  transposición; y el RD 552/2014 está derogado desde el 11 de noviembre de 2018 por el Real Decreto
  1180/2018, que es quien lo desarrolla hoy. Se corrige la entrada y se añade una para el RD
  1180/2018. Hallazgo NOR-02 de la auditoría del libro 01.
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
* **cap04, AMC1 SAO.OP.150** — el umbral de 10.000 ft se presentaba con «deberá», como si fuera el
  reglamento. Es el medio aceptable de cumplimiento («debería»), no vinculante como SAO.OP.150.
  Hallazgo NOR-10 de la auditoría del libro 01.
* **cap01 e introducción, estadísticas** — el 90 % se presentaba como estadística «actual» de la aviación general y el vuelo a vela, y el reparto 40/30/12/6 como «proporciones habituales»; salen de un análisis de unos 250 accidentes de planeador (C. Ceipek, 2019). Ahora se atribuyen, se da el 80 % de la FAA para el conjunto de la aviación y se fechan las cifras de EASA (*Annual Safety Review 2019*). El 26 % se leía como «hasta un 26 % de los accidentes son mortales»: es el porcentaje de accidentes mortales debidos a pérdida y barrena. Tarjeta `fases-criticas-accidentes`. Hallazgo TEC-06 de la auditoría del libro 02.
* **cap01, definición de factores humanos** — la que se atribuía a la OACI es de la HSE británica. Se sustituye por la del Doc 9683 de la OACI. Hallazgo TEC-07 de la auditoría del libro 02.
* **cap01, cultura justa** — no excluye la «negligencia deliberada», sino la negligencia grave, las infracciones intencionadas y los actos destructivos (Reglamento (UE) 376/2014, art. 2.12). Capítulo, glosario y tarjeta `cultura-justa`. Hallazgo NOR-03 de la auditoría del libro 02.
* **cap02, MED.A.020** — el recuadro omitía dos supuestos, se limitaba a volar «al mando» y no citaba los medicamentos ni la consulta al médico de cabecera que firmó el certificado LAPL. Recuadro y tarjeta `cuando-consultar-ame`. Hallazgo NOR-04 de la auditoría del libro 02.
* **cap02, ver y evitar** — «más del 95 %» del tiempo fuera y «al menos 3 segundos» para reaccionar no tenían fuente; la FAA da 4 o 5 segundos de panel por cada 16 de fuera y unos 12,5 segundos entre ver un tráfico y apartarse (AC 90-48E). El viraje a la derecha en un encuentro frontal es obligatorio (SERA), no «preferente». El paso del escaneo se amplía hacia atrás y por encima, como la figura, cuyo pie pasa a «Ciclo de escaneo». Tarjeta `colision-frontal`. Hallazgos TEC-08 y COH-05 de la auditoría del libro 02.
* **cap02, estrés** — el síndrome de Selye se describía a escala de minutos («a los pocos minutos») y el pánico como salida de la fase de alarma; el pánico es la sobreactivación de la curva de Yerkes-Dodson. Tarjeta `evitar-primeras-veces`. Hallazgo TEC-09 de la auditoría del libro 02.
* **cap02 y cap04, hiperventilación** — se quita la apnea, que no recoge la FAA, y se unifica el tratamiento: respirar más despacio alargando la exhalación, hablar y, en los casos graves, una bolsa sobre la nariz y la boca. El post-it hablaba de «ceguera»: son alteraciones visuales. La hiperventilación también puede acompañar a la hipoxia. Tarjetas `hiperventilacion-tratamiento` e `hiperventilacion-causa`. Hallazgo COH-06 de la auditoría del libro 02.
* **cap02, fatiga** — el epígrafe promete fatiga aguda y crónica y el texto no las distinguía; «la fatiga sólo se cura durmiendo» es falso para la crónica, que requiere médico. Texto, recuadro, post-it y tarjeta `fatiga-solo-se-cura-durmiendo`. Hallazgo TEC-10 de la auditoría del libro 02.
* **cap02, deshidratación** — «es habitual perder entre 1 y 3 litros de agua por hora» y los «20 minutos» que tarda en hidratar no tenían fuente; se dan las cifras de reposición de la FAA. Tarjeta `deshidratacion-retraso-sed`. Hallazgo TEC-11 de la auditoría del libro 02; la cifra de pérdida queda pendiente de un médico aeronáutico.
* **cap02, medicación** — las drogas no «invalidan automáticamente» el certificado, no todos los antihistamínicos son incompatibles y la «regla del prospecto» no es la norma. Ahora se cita MED.A.020 y las tres preguntas de la guía de EASA. Tarjeta `automedicacion`. Hallazgo NOR-05 de la auditoría del libro 02.
* **cap02, dopaje** — la WADA fija el Código Mundial Antidopaje, pero los controles los hacen la FAI o la organización nacional (en España, la CELAD); la AUT sólo ampara el uso autorizado; se retira «hay controles al aterrizar», que no tenía fuente. Capítulo, glosario (WADA) y tarjeta `aut-tue-competicion`. Hallazgo NOR-06 de la auditoría del libro 02.
* **cap02 y cap04, disbarismos** — los resúmenes y un recuadro del cap04 atribuían el riesgo a la expansión del gas al ascender; el cuerpo del cap02 ya explicaba que el problema serio llega en el descenso. Tarjetas `disbarismos-congestion` y `ley-de-boyle`. Hallazgo COH-07 de la auditoría del libro 02.
* **cap03, sobrecarga** — se llamaba «sobrecarga cualitativa» a la de demasiadas tareas a la vez; pasa a «sobrecarga de trabajo». Tarjetas `que-erosiona-la-conciencia-situacional` y `procesamiento-de-informacion`. Hallazgo TEC-12 de la auditoría del libro 02.
* **cap03, conciencia situacional** — su pérdida no es «el eslabón inicial de la mayoría de las cadenas de accidentes», afirmación sin fuente; aparece con frecuencia en ellas. Texto, post-it y tarjeta `conciencia-situacional`. Hallazgo COH-08 de la auditoría del libro 02.
* **cap03, *aviate, navigate, communicate*** — comunicar va en tercer lugar, no «sólo si es estrictamente necesario». Tarjeta `carga-de-trabajo-vaso`. Hallazgo TEC-13 de la auditoría del libro 02.
* **cap04, Dalton e hipoxia** — la caída de presión con la altitud no la causa la ley de Dalton, que explica la presión parcial, y los glóbulos rojos no llegan «vacíos»: la saturación baja de forma progresiva (89 % a 10.000 ft). Texto, post-it y tarjetas `ley-de-dalton` y `mecanismo-de-la-hipoxia`. Hallazgo TEC-14 de la auditoría del libro 02.
* **cap04, euforia** — no es «el primer síntoma según el programa AESA»: es uno de los primeros, y el orden varía de una persona a otra. Texto, post-it y tarjeta `primer-sintoma-hipoxia`. Hallazgo TEC-15 de la auditoría del libro 02.
* **cap04, regla del oxígeno** — «oxígeno al 100 %» es el ajuste de los reguladores de mascarilla, no de la cánula ni del EDS. La regla pasa a «oxígeno y desciende», con el máximo aporte de cada equipo. Tarjeta `oxigeno-al-100-y-desciende`, que conserva su `id`. Hallazgo TEC-16 de la auditoría del libro 02; los mandos concretos quedan pendientes de un FI(S) de onda.
* **cap04, presión de la botella** — «entre 150 y 200 bar» no vale como criterio: la presión de llenado depende de la botella y baja con el frío. Se comprueba que basta para el vuelo con reserva. Texto, post-it y tarjeta `presion-de-la-botella`. Hallazgo TEC-17 de la auditoría del libro 02.
* **cap04, diagnóstico diferencial** — la regla de oro asignaba el hormigueo a la hiperventilación por debajo de 10.000 ft, cuando también es síntoma de hipoxia. Pasa a un orden de actuación: primero la hipoxia, después la respiración. Tarjeta `distinguir-hipoxia-de-hiperventilacion`. Hallazgo TEC-18 de la auditoría del libro 02.
* **cap04, pulsioxímetro** — se añaden sus límites: con monóxido de carbono marca valores normales, y el frío y el movimiento lo falsean; ante síntomas se actúa aunque la lectura sea buena. Se quita la invitación a medir a 5.000 m sin decir que es con oxígeno. Texto, post-it, glosario y tarjeta `pulsioximetro-umbral`. Hallazgo TEC-19 de la auditoría del libro 02.
* **cap04, tarjeta `sao-op-150-oxigeno`** — presentaba el AMC como obligación («siempre por encima de 10.000 ft»); ahora distingue el reglamento del AMC. Hallazgo COH-09 de la auditoría del libro 02.
* **cap01, Reason y SHELL** — la definición de error de Reason exige una secuencia *planificada* que falla sin intervención del azar; y Hawkins (1975) dio al modelo SHELL el diagrama que usa la OACI, sin que conste que «añadiera la segunda L». El resumen del cap01 se redacta de nuevo sin «represión ajena» ni «esconder daños fatales». Hallazgos TEC-20 y PED-01 de la auditoría del libro 02.
* **cap02, IMSAFE** — la lista no la «ha estandarizado la aviación»: la difunde la FAA, en cuya versión la E es *Emotion*. Se dice en el capítulo y en el glosario. Hallazgo COH-11 de la auditoría del libro 02.
* **cap02, visión nocturna** — se degrada desde unos 5.000 ft, no 6.000, como ya decía el cap04, que cita ahora el AIM de la FAA. Hallazgo COH-12 de la auditoría del libro 02; el umbral único para la colección queda pendiente de un médico aeronáutico.
* **cap02, aproximación de agujero negro** — la corrección era «mantener la velocidad indicada», pero la ilusión afecta a la senda: se contrasta con referencias objetivas y no se desciende por debajo de la senda prevista. Hallazgo TEC-22 de la auditoría del libro 02.
* **cap02, figura de ilusiones** — mostraba una ilusión vestibular bajo las ópticas y ningún texto la citaba; se mueve tras las ilusiones, se cita y cambia su pie. Hallazgo PED-05 de la auditoría del libro 02.
* **cap02, monóxido de carbono** — «labios de color rojo intenso» es un signo tardío y poco fiable; se sustituye por los síntomas que da la FAA. Tarjeta `monoxido-de-carbono`. Hallazgo TEC-23 de la auditoría del libro 02, pendiente de un médico aeronáutico.
* **cap03, PAVE y 3P** — la E de PAVE es *External pressures*, no «Operación». El modelo de las «3 P» es, en la FAA, un modelo de gestión de riesgos ligado a PAVE: pasa junto a él. Tarjeta `pave`. Hallazgos PED-02 y PED-03 de la auditoría del libro 02.
* **cap03, memoria** — los 200 ms valen para la memoria visual, no para toda la sensorial; el hipocampo interviene en la memoria, pero no la «aloja»; y la memoria a corto plazo admite unos 7 elementos, como dice la figura. Hallazgo TEC-21 de la auditoría del libro 02.
* **cap04, hipoxia histotóxica** — la causan el alcohol, los narcóticos y algunos tóxicos; los sedantes y los antihistamínicos aumentan la vulnerabilidad, pero no la causan. Texto, post-it y tarjeta `cuatro-clases-de-hipoxia`. Hallazgo TEC-24 de la auditoría del libro 02, pendiente de un médico aeronáutico.
* **cap04, sistemas de oxígeno** — el caudal del flujo continuo se regula según la altitud, no «2 a 2,5 L/min»; EDS es la denominación de un fabricante (*Electronic Delivery System*); los equipos actuales no usan pilas de 9 V, y conectarlos a la batería del planeador es una modificación de la aeronave. Hallazgos TEC-25 y TEC-26 de la auditoría del libro 02.
* **cap04, oxígeno de aviación** — el motivo de no usar oxígeno medicinal no es su humedad, que no está respaldado, sino que no cumple las especificaciones del oxígeno de aviación (FAA). Se quita el «98,5 %». Texto, post-it y tarjeta `oxigeno-de-aviacion`. Hallazgo TEC-27 de la auditoría del libro 02.
* **cap04, normativa del equipo** — se añaden SAO.IDE.115 (el planeador lleva equipo de oxígeno cuando SAO.OP.150 lo exige) y CS 22.1441 y 22.1449 (equipo aprobado y medio para comprobar el suministro). Hallazgo NOR-08 de la auditoría del libro 02.
* **Glosario, SAO y SFCL** — el 2018/1976 es un Reglamento de Ejecución, y el programa de estudios no está en la Part-SFCL sino en su AMC1 SFCL.130. Hallazgo NOR-09 de la auditoría del libro 02.
* **Apéndice del syllabus** — no promete ya «cubrir todos los puntos necesarios para el examen»: dice que sigue los epígrafes oficiales y da el formato del examen de la asignatura (10 preguntas en 20 minutos, AMC1 SFCL.135). Hallazgo PED-06 de la auditoría del libro 02.
* **Epígrafe** — la cita de Frank Borman llevaba el año 1968, que no consta en ninguna fuente; se quita. La atribución sigue sin fuente primaria. Hallazgo PED-07 de la auditoría del libro 02.
* **Erratas** — «monomando», «de abordo», «abrevié», «aterriceble», «Paradojicamente» y el trato de tú y de usted mezclado en el escaneo visual. Hallazgo PED-01 de la auditoría del libro 02.

### Añadido

* **cap02 y cap04, gas disuelto** — ningún libro trataba la enfermedad descompresiva. Se añade en el cap02 la regla de EASA de dejar un tiempo razonable tras bucear o donar sangre (24 horas como mínimo, según la guía), y en el cap04 la ley de Henry y el riesgo por encima de unos 25.000 ft. El glosario deja de igualar disbarismo con barotrauma. Hallazgo SYL-01 de la auditoría del libro 02.
* **Bibliografía, factores humanos y medicina aeronáutica** — la bibliografía no recogía ninguna fuente de las cifras y los modelos del libro. Se añade un bloque propio del libro 02 (Part-MED y sus AMC, OACI Doc 8984 y 9683, manuales y circulares de la FAA, *Annual Safety Review* de EASA, Reason, Ceipek y el Código Mundial Antidopaje). El resto de la bibliografía sigue siendo la común de la colección. Hallazgo NOR-07 de la auditoría del libro 02.

### Cambiado

* **Figuras por rehacer: marca «EN REVISIÓN» y nota en el pie** — ocho figuras en las que la
  auditoría encontró errores llevan encima, en diagonal, la marca «EN REVISIÓN», en el PDF,
  el EPUB y la web, y su pie termina con *(CORREGIR: …)*, que dice qué está mal. Primero, la lista IMSAFE
  (cap02), que da 24 h para el alcohol en vez de 8 y cuya regla del «NO» se invierte en dos
  preguntas; el modelo DECIDE (cap03), con los pasos 4 y 5 cambiados; y el tiempo útil de conciencia
  (cap04), que rotula como obligatorio el oxígeno por encima de 3.000 m y da cifras que no coinciden
  con la fuente. En una segunda pasada se marcan otras cuatro: la pirámide de Maslow (cap01), que rotula la seguridad operacional en el nivel de la necesidad de sentirse a salvo; el queso suizo (cap01), con las capas de HFACS y ejemplos mal colocados; la cadena del error (cap01), que llama latente a un error activo; la curva de estrés (cap02), que rotula como «agotamiento» la sobreactivación; y, en una tercera, la visión de túnel (cap03), con la escala del variómetro mal dibujada. Al sustituir cada figura se quitan la marca y la nota.

## [1.0-rc.13] — 7 de agosto de 2026

**Qué releer:** **nada.** El único cambio es el enlace del apéndice del syllabus y su QR; ni el texto ni las figuras cambian.

### Maqueta y producción

* **Apéndice del syllabus, «Ponte a prueba»** — el enlace pasa de `/tests/` a `/examenes/`; el PDF añade un QR hacia la misma página. No cambia lo que se estudia.

## [1.0-rc.12] — 2 de agosto de 2026

**Qué releer:** **Glosario, entradas «Hipoxia», «DECIDE», «SHELL», «AUT / TUE», «SAO» y «Part-MED».** Cinco correcciones de contenido: la hipoxia no es «cerebral» ni hay «presión transferencial», el modelo DECIDE tenía dos pasos cambiados de sitio, SHELL no lo desarrolló la OACI, las exenciones terapéuticas no las concede WADA y Part-SAO no fija ningún umbral de oxígeno —lo fija su AMC, y sólo por defecto—.

### Cambiado

* **Glosario, rótulos de `AME` y `OACI`** — adoptan la forma del libro 01, con el término español delante y el inglés completo detrás. `AME` sólo llevaba el inglés y `OACI` dejaba «ICAO» sin desarrollar.
* **Glosario, ocho rótulos** — `ADM`, `SRM`, `TUC`, `WADA`, `AUT / TUE`, `SAO` y `SFCL` sólo llevaban el inglés, y en cinco de ellos el nombre español estaba repetido como primera frase de la definición: ahora va en el rótulo y no se dice dos veces. `SAO` y `SFCL` adoptan además el desarrollo que ya usaba el libro 01 para `Part-SAO` y `Part-SFCL`. La entrada `MED (Part-MED)` pasa a `Part-MED (Requisitos médicos aeronáuticos)`, se corrige que no es una «subparte» sino el anexo IV del Reglamento (UE) n.º 1178/2011, y se añade que para la SPL basta el certificado médico LAPL.

### Corregido

* **Glosario, entrada «Hipoxia»** — decía «déficit de oxígeno **cerebral**» y hablaba de «falta de presión **transferencial** en altitud». La hipoxia afecta a células y tejidos, no sólo al cerebro, y el término es *presión parcial* de oxígeno; «transferencial» no existe y no aparecía en ningún otro punto de la colección. La definición nueva parte de la redacción correcta y conserva los cuatro tipos, alineados con lo que ya decía cap04. Es la misma definición que llevan ahora los libros 03 y 08.
* **Glosario, entrada «DECIDE»** — el modelo tenía dos pasos cambiados de sitio: ponía «Implementar» donde va *Identify* (identificar las acciones posibles) y «Determinar» donde va *Do* (ejecutarlas), de modo que el alumno memorizaba primero implementar y después determinar. Los seis pasos van ahora con su término original y su glosa.
* **Glosario, entrada «SHELL»** — el modelo no lo desarrolló la OACI: es de Edwards (1972), completado por Hawkins (1975); la OACI lo adoptó y lo difundió.
* **Glosario, entrada «AUT / TUE»** — WADA no concede exenciones terapéuticas. Las conceden las organizaciones nacionales antidopaje y las federaciones internacionales; WADA fija el estándar y revisa las concesiones. Se retira además la mención a las autoridades aeronáuticas, que no intervienen.
* **Glosario, entrada «SAO»** — decía que Part-SAO «fija la obligatoriedad del oxígeno por encima de 10.000 ft», y eso contradecía al propio cap04 del libro. SAO.OP.150 no da ninguna cifra: obliga al piloto a valorar si la falta de oxígeno merma a los ocupantes. Los 10.000 ft son del AMC1 y sólo aplican cuando el piloto no puede hacer esa valoración.
## [1.0-rc.11] — 31 de julio de 2026

### Maqueta y producción

* **cap02, ilusiones ópticas** — la figura era línea negra sobre blanco y todo pesaba lo mismo: el planeador descendiendo, las nubes y el horizonte artificial competían entre sí. Ahora va en color, con el planeador en rojo, el cielo del bocadillo en azul y el instrumento en gris con la barra de actitud azul, de modo que la escena se separa del instrumento a la primera. No cambia lo que ilustra.

## [1.0-rc.10] — 28 de julio de 2026

**Qué releer:** **cap02, apartado de alcohol** (el recuadro de Normativa y su línea del resumen). Se corrige la referencia del AMC y se completa la regla con un tercer límite que faltaba. Las cifras que ya estaban —8 horas y 0,2 g/l— no cambian.

### Corregido

* **cap02, alcohol** — la regla se atribuía al **AMC1 SAO.GEN.130(f)**, que en el Rule Book de EASA es el AMC de *buceo y donación de sangre*. El consumo de alcohol está en el AMC combinado **AMC1 SAO.GEN.130(f) y SAO.GEN.135(b)**, titulado *Alcohol consumption*. Verificado contra las Easy Access Rules for Sailplanes (nov. 2022).

### Añadido

* **cap02, alcohol** — el tercer punto de ese AMC, que faltaba: **nada de alcohol durante el vuelo**. El resumen recoge además el matiz «o el límite nacional, si es más estricto», que el cuerpo ya explicaba.

## [1.0-rc.9] — 27 de julio de 2026

### Maqueta y producción

* **Maquetación Typst** — corrección del solapamiento en páginas de parte, ajuste de la marca de agua «En revisión» y ordenación del índice alfabético sin tildes.

## [1.0-rc.8] — 22 de julio de 2026

**Qué releer:** **Glosario.** Se normalizan las referencias a capítulos en las definiciones. El temario no cambia.

### Cambiado

* **Glosario** — se eliminan las referencias redundantes a capítulos en las definiciones de términos y acrónimos.

### Maqueta y producción

* **Créditos** — se añade un espaciado vertical (`v(1.5em)`) al bloque de créditos en la maquetación Typst para evitar que queden demasiado juntos con el contenido adyacente.
* **Colofón** — se homogeneiza el texto del colofón en todos los libros para que sea idéntico al de Derecho Aéreo, incluyendo la referencia dinámica al repositorio y el uso de Quarto y la extensión `orange-book-es`.
* **Índice alfabético** — generación automática de un índice de términos al final del libro para la versión PDF (Typst), utilizando el paquete `in-dexter` y referenciando los términos del glosario a 3 columnas.
* **Enlaces al glosario** — enlace automático en el PDF (Typst) de la primera aparición de cada término y acrónimo del glosario en el cuerpo de cada capítulo.

## [1.0-rc.7] — 18 de julio de 2026

**Qué releer:** **Preliminares, página de licencia.** El temario no cambia.

### Cambiado

* **Licencia** — la mención institucional pasa de «avalado por AESA» a «temarios validados por
  AESA», siguiendo la formulación indicada por AESA.

## [1.0-rc.6] — 18 de julio de 2026

**Qué releer:** **Glosario** — 8 definiciones (AESA, AME, ATC, EASA, OACI, SPL, TMG, VFR) alineadas con el glosario del libro 1. **Preliminares, página de licencia.** El temario no cambia.

### Cambiado

* **Glosario** — 8 definiciones normalizadas contra el libro 1.
* **Licencia** — el libro pasa a **CC BY-SA 4.0**: mantiene atribución y añade la
  obligación de compartir las adaptaciones bajo la misma licencia o una compatible.

## [1.0-rc.5] — 17 de julio de 2026

**Qué releer:** **Sólo el epígrafe**, que es una página. El temario no cambia ni una línea; lo que
cambia es la cita con la que abre el libro, y si encaja con la asignatura es criterio editorial.

### Cambiado

* **Epígrafe** — el libro abre ahora con una cita propia, de Frank Borman, comandante del Apolo 8,
  elegida para esta asignatura. Los 9 libros compartían la misma cita de Frank Borman,
  que además pertenece a Factores Humanos.

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
* El pie de la gráfica del tiempo de conciencia útil (`cap04`) estaba cortado: decía «Tiempo de
  conciencia útil (» y ahí acababa. Se restaura desde el AsciiDoc de origen, con el término inglés
  en cursiva como lo escribe el cuerpo del capítulo.
* El índice, la lista de ilustraciones y la de tablas bajan de cuerpo. Estaban a 15/13/11/11 pt
  con el texto del libro a 10: hasta la subsección más profunda era mayor que lo que se lee.
* La banda azul de la portadilla crece si el título no cabe en una línea. Tenía altura fija y
  el título del libro 8 la desbordaba, dejando la nota de estado y la versión pisándose fuera
  del recuadro.
* Se normalizan los títulos de capítulos, secciones, portadillas y apéndices a la capitalización
  propia del español.
* Los entregables llevan ahora la versión y la fecha en el nombre
  (`02-factores-humanos-1.0-rc.4-260716.pdf`), para identificarlos sin abrirlos.
* **Cada libro se publica también como un solo Markdown** (`make rag`, a
  `build/rag/02-factores-humanos-1.0-rc.4-260716.md`), para cargarlo como fuente en un asistente de
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

* 4 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **En revisión**, deducido de la versión 1.0-rc.5.
* La marca de agua y el aviso del EPUB desaparecen solos al pasar a `1.0.0`.

## [1.0-rc.4] — 16 de julio de 2026

Versión base del registro. Lo anterior a esta fecha no está detallado entrada por entrada: el libro
se escribió antes de que existiera este fichero.

**Qué releer:** **Todo el temario.** Es la primera revisión técnica completa del libro: no hay una versión revisada anterior con la que comparar.

### Estado en esta versión

* 4 capítulos y 3 apéndices, entre ellos el glosario y la bibliografía.
* Estado editorial: **En revisión**, deducido de la versión 1.0-rc.4.
* La marca de agua y el aviso del EPUB desaparecen solos al pasar a `1.0.0`.
