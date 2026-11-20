---
schema: 1
figura: 01-cap04-validez-medical.jpg
tipo: grafico-cuantitativo
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Reglamento (UE) 1178/2011, Parte MED, MED.A.045 (recursos/fuentes/ue/reg-1178-2011-aircrew-part-med-consol-2026-04-30.pdf)"
    licencia: "texto normativo"
restricciones:
  - eje de edad a escala
  - reglas de los 42 y los 51 años visibles
  - sin cruces médicas ni logotipos
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap04-validez-medical

**Qué enseña.** Cuánto vale un certificado médico LAPL o de Clase 2 según la edad del piloto, y la
trampa de los 42 y los 51 años. Texto en `cap04-licencias-de-personal.qmd`, «El certificado
médico».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (PED-07). Se rehace por código.
La edición inglesa es hoy una copia de la española.

## Qué falla en la figura actual

* En la Clase 2, el tramo de 60 meses acaba hacia los 34 años en el eje; debe llegar a los 40.
* Faltan las dos reglas que el texto explica: un certificado expedido antes de los 40 deja de valer
  a los 42; uno de Clase 2 expedido antes de los 50, a los 51.
* «> 40 años» y «> 50 años» no dicen qué pasa justo a los 40 o a los 50.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`.

**Composición.** Dos barras horizontales sobre un eje de edad común, a escala, de 14 a 70 años con
marcas en 40, 42, 50 y 51:

* **LAPL**: «60 meses» hasta los 40; «24 meses» desde los 40.
* **Clase 2**: «60 meses» hasta los 40; «24 meses» de los 40 a los 50; «12 meses» desde los 50.

Sobre la barra, un corchete ámbar `#B26A00` de 40 a 42 con la nota «Expedido antes de los 40: deja
de valer a los 42». En la Clase 2, otro de 50 a 51: «Expedido antes de los 50: deja de valer a los
51». Debajo, el ejemplo del texto en una línea: «Expedido a los 39: caduca a los 42, no a los 44».

Tonos de un solo color que se oscurecen al acortarse la validez, con la cifra escrita en cada
tramo.

**Datos verificados.** MED.A.045, tal como lo resume el texto, corregido y cotejado en la auditoría
(H3, PED-07).

**Formato.** PNG y `width="100%"`. Al sustituirla, la ruta del `.qmd` pasa de `.jpg` a `.png` en
las dos ediciones y el `.jpg` se borra.

## Edición inglesa

«LAPL medical», «Class 2 medical», «60 months», «24 months», «12 months», «Pilot's age», «Issued
before 40: no longer valid after 42», «Issued before 50: no longer valid after 51», «Issued at 39:
expires at 42, not 44».
