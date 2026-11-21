---
schema: 1
figura: 01-cap02-certificado-aeronavegabilidad.png
tipo: documento
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "matplotlib"
  version: "3.10.9"
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
master_editable: "tools/figuras/01_derecho_aereo.py"
---

# 01-cap02-certificado-aeronavegabilidad

**Qué enseña.** Qué es y qué dice el certificado de aeronavegabilidad (CofA): datos de la aeronave,
base jurídica y la condición de llevar adjunto un ARC en vigor. Texto en
`cap02-aeronavegabilidad.qmd`, «Certificado de aeronavegabilidad (CofA)».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión dibujada por código,
en las dos ediciones; se quitan la clase `.corregir` y la nota del pie, y la figura pasa de `.jpg` a
`.png`. Estuvo marcada desde el 1 de octubre de 2026 (COH-07). Sigue en `borrador`: falta la
revisión técnica de la figura nueva.

## Procedencia

Dibujada con matplotlib 3.10.9 por `certificado_aeronavegabilidad()`, en
`tools/figuras/01_derecho_aereo.py`. Se regenera con:

```bash
python3 tools/figuras/01_derecho_aereo.py [--lang en] 01-cap02-certificado-aeronavegabilidad
```

La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* Cita el Reglamento (CE) 216/2008, sustituido por el Reglamento (UE) 2018/1139.
* Es de un avión: «Avión de categoría normal», «Generic Aircraft Corporation».
* Imita un documento de AESA: escudo, logotipo, sello y firma inventados, dentro de una carpeta de
  piloto con una licencia también imitada.

## Cómo está hecha

El formulario EASA 25 de frente, apaisado, en líneas y casillas navy sobre blanco, con sus casillas
numeradas y en su sitio, como el apéndice VI, y la marca «EJEMPLO» en diagonal. Los textos son los
del reglamento, palabra por palabra:

* Cabecera: «CERTIFICADO DE AERONAVEGABILIDAD», «[Estado miembro de matrícula]», «[AUTORIDAD
  COMPETENTE DEL ESTADO MIEMBRO]» y los dos «(*)». Donde el formulario pone el logotipo, una casilla
  discontinua vacía, rotulada «Logotipo de la autoridad competente».
* Casilla 1: **EC-ABC**, el ejemplo del cap03. Casilla 2: «Ejemplo · planeador biplaza PE-2».
  Casilla 3: «001».
* Casilla 4, «Categorías»: **en blanco**, por decisión de Ramón (20-11-2026), porque no se ha
  cotejado cómo se rellena en un CofA real de planeador.
* Casilla 5: la base jurídica, con el Reglamento (UE) 2018/1139; limitaciones, fecha y firma,
  vacías.
* Casilla 6: validez y ARC adjunto.
* Pie: «Formulario EASA 25, edición 3» y «(*) Para uso del Estado de matrícula». Debajo, en cursiva,
  la línea final del formulario: «El presente certificado de aeronavegabilidad deberá llevarse a
  bordo durante todos los vuelos».

La casilla (7), sólo para aeronaves no tripuladas, no se dibuja. Sin escudo, logotipo, sello ni
firma. PNG, insertado con `width="100%"`.

## Al sustituirla

Por decisión de Ramón (20-11-2026), la línea que pide llevarlo a bordo se conserva y la explica el
pie, porque el cap02 dice que en planeadores puede quedarse en el aeródromo (SAO.GEN.155 c)). Pie
nuevo: «Modelo de certificado de aeronavegabilidad de un planeador (formulario EASA 25, Parte 21,
apéndice VI), sin validez. El formulario pide llevarlo a bordo, pero en planeadores puede quedarse
en el aeródromo o lugar de operación (SAO.GEN.155 c))».

## Edición inglesa

Desde el 20 de noviembre de 2026, la misma figura con `--lang en`, marca «EXAMPLE» y el pie
equivalente en inglés. ⚠️ El texto del formulario sigue la versión inglesa del Reglamento 748/2012,
que no está archivada en `recursos/fuentes/` y no se pudo descargar de EUR-Lex el 20-11-2026:
**cotejarlo** con la versión inglesa del apéndice VI antes de dar la figura por revisada.
