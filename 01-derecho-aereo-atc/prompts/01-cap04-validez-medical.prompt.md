---
schema: 1
figura: 01-cap04-validez-medical.png
tipo: grafico-cuantitativo
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "matplotlib"
  version: "3.10.9"
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
master_editable: "tools/figuras/01_derecho_aereo.py"
---

# 01-cap04-validez-medical

**Qué enseña.** Cuánto vale un certificado médico LAPL o de Clase 2 según la edad del piloto, y la
trampa de los 42 y los 51 años. Texto en `cap04-licencias-de-personal.qmd`, «El certificado
médico».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión dibujada por código,
en las dos ediciones; se quitan la clase `.corregir` y la nota del pie, y la figura pasa de `.jpg` a
`.png`. Estuvo marcada desde el 1 de octubre de 2026 (PED-07). Sigue en `borrador`: falta la
revisión técnica de la figura nueva.

## Procedencia

Dibujada con matplotlib 3.10.9 por `validez_medical()`, en
`tools/figuras/01_derecho_aereo.py`. Se regenera con:

```bash
python3 tools/figuras/01_derecho_aereo.py [--lang en] 01-cap04-validez-medical
```

La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* En la Clase 2, el tramo de 60 meses acaba hacia los 34 años en el eje; debe llegar a los 40.
* Faltan las dos reglas que el texto explica: un certificado expedido antes de los 40 deja de valer
  a los 42; uno de Clase 2 expedido antes de los 50, a los 51.
* «> 40 años» y «> 50 años» no dicen qué pasa justo a los 40 o a los 50.

## Cómo está hecha

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

**Formato.** PNG, insertado con `width="100%"`.

## Edición inglesa

Desde el 20 de noviembre de 2026, la misma figura con `--lang en`: los rótulos en inglés están
junto a los españoles en el script, con `t(es, en)`, y los números llevan el formato inglés.
