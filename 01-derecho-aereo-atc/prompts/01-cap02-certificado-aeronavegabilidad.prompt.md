---
schema: 1
figura: 01-cap02-certificado-aeronavegabilidad.jpg
tipo: documento
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Reglamento (UE) 748/2012, anexo I (Parte 21), apéndice VI: formulario EASA 25, edición 3; pág. 130 del consolidado (recursos/fuentes/ue/reg-748-2012-part-21-consol-2026-08-07.pdf)"
    licencia: "texto normativo"
restricciones:
  - modelo rotulado «EJEMPLO», sin validez
  - sin escudo, logotipo ni sello de AESA o del Estado, y sin firmas
  - planeador, no avión
  - base jurídica del Reglamento (UE) 2018/1139, no del 216/2008
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap02-certificado-aeronavegabilidad

**Qué enseña.** Qué es y qué dice el certificado de aeronavegabilidad (CofA): datos de la aeronave,
base jurídica y la condición de llevar adjunto un ARC en vigor. Texto en
`cap02-aeronavegabilidad.qmd`, «Certificado de aeronavegabilidad (CofA)».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (COH-07). Se rehace por código.
La edición inglesa es hoy una copia de la española.

## Qué falla en la figura actual

* Cita el Reglamento (CE) 216/2008, sustituido por el Reglamento (UE) 2018/1139.
* Es de un avión: «Avión de categoría normal», «Generic Aircraft Corporation».
* Imita un documento de AESA: escudo, logotipo, sello y firma inventados, dentro de una carpeta de
  piloto con una licencia también imitada.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`.

**Composición.** El formulario EASA 25 de frente, apaisado, en líneas y casillas navy sobre blanco,
con sus casillas numeradas y en su sitio, como el apéndice VI. Una marca diagonal gris claro
«EJEMPLO» encima. El texto de las casillas es el del reglamento:

* Cabecera: «CERTIFICADO DE AERONAVEGABILIDAD», «[Estado miembro de matrícula]», «[Autoridad
  competente del Estado miembro]». Donde el formulario pone el logotipo, una casilla vacía.
* 1. Nacionalidad y marcas de matrícula: **EC-ABC** (el ejemplo del cap03).
* 2. Fabricante y designación del fabricante de la aeronave: un fabricante y modelo de planeador
  inventados que se lean como tales, p. ej. «Fabricante de ejemplo — planeador biplaza PE-2».
* 3. Número de serie de la aeronave: «001».
* 4. Categorías: la de un planeador según su certificado de tipo (CS-22: utilitaria o acrobática).
  **Comprobar con un CofA real de planeador** cómo se rellena antes de dibujarlo.
* 5. «El presente certificado de aeronavegabilidad se expide con arreglo al Convenio sobre Aviación
  Civil Internacional de 7 de diciembre de 1944 y el Reglamento (UE) 2018/1139 del Parlamento
  Europeo y del Consejo respecto a la aeronave anteriormente mencionada, que se considera
  aeronavegable cuando se mantiene y se opera con arreglo a lo precedente y a las limitaciones de
  operación pertinentes.» Limitaciones/Observaciones: vacío.
* Fecha de expedición y firma: vacías.
* 6. «El presente certificado de aeronavegabilidad es válido a menos que sea revocado por la
  autoridad competente del Estado miembro de matrícula. Se adjuntará al presente certificado un
  certificado de revisión de la aeronavegabilidad actualizado.»
* Pie: «Formulario EASA 25, edición 3».

La casilla (7), sólo para aeronaves no tripuladas, no se dibuja. Dos llamadas fuera del formulario,
en gris `#333333`: una a la casilla 5, «Base jurídica: Reglamento (UE) 2018/1139», y otra a la 6,
«No caduca, pero exige un ARC en vigor».

**Formato.** PNG y `width="100%"`. Al sustituirla, la ruta del `.qmd` pasa de `.jpg` a `.png` en
las dos ediciones y el `.jpg` se borra.

## Al sustituirla

* El formulario termina con «El presente certificado de aeronavegabilidad deberá llevarse a bordo
  durante todos los vuelos». El texto del cap02 dice que, para planeadores, puede ir a bordo o
  estar disponible en el aeródromo (SAO.GEN.155 c)). O se omite esa línea del dibujo, o se explica
  en el pie. Lo decide Ramón.
* Pie propuesto: «Modelo de certificado de aeronavegabilidad de un planeador (formulario EASA 25,
  Parte 21, apéndice VI). Ejemplo sin validez».

## Edición inglesa

Texto del formulario en la versión inglesa del Reglamento 748/2012 (cotejar en EUR-Lex; no está
archivada): «CERTIFICATE OF AIRWORTHINESS», «[Member State of registry]», «[Competent authority of
the Member State]», casillas 1 a 6, «EASA Form 25, Issue 3». Marca «EXAMPLE».
