---
schema: 1
figura: 01-cap06-regla-semicircular.png
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "matplotlib"
  version: "3.10.9"
fuentes:
  - referencia: "Real Decreto 1180/2018, art. 6 y anexo I (recursos/fuentes/espana/rd-1180-2018-reglamento-del-aire.pdf)"
    licencia: "texto normativo"
  - referencia: "AIP España, ENR 1.7"
    licencia: "cita y referencia"
restricciones:
  - orientación Norte-Sur, no la Este-Oeste del apéndice 3 de SERA
  - derrota magnética
  - sin logotipos ni reproducción de documentos oficiales
revision:
  persona: ""
  fecha: ""
master_editable: "tools/figuras/01_derecho_aereo.py"
---

# 01-cap06-regla-semicircular

**Qué enseña.** Qué altitud o nivel de crucero VFR toca según la derrota magnética. Texto en
`cap06-procedimientos-para-navegacion-aerea-operaciones-de-aeronaves.qmd`, «Regla semicircular de
niveles de crucero», con la regla mnemotécnica «Norte Par / Sur Impar».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión dibujada por código,
en las dos ediciones; se quitan la clase `.corregir` y la nota del pie, y la figura pasa de `.jpg`
a `.png`. Estuvo marcada desde el 1 de octubre de 2026 (COH-01) y es una de las tres prioritarias:
llegó a retirarse. Sigue en `borrador`: falta la revisión técnica de la figura nueva.

## Procedencia

Dibujada con matplotlib 3.10.9 por `regla_semicircular()`, en
`tools/figuras/01_derecho_aereo.py`. Se regenera con:

```bash
python3 tools/figuras/01_derecho_aereo.py [--lang en] 01-cap06-regla-semicircular
```

La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* Reparte los niveles **Este-Oeste** («ESTE 0°-179°» impares, «OESTE 180°-359°» pares), que es el
  apéndice 3 de SERA. En España rige la regla **Norte-Sur**. Para una derrota de 045°, el texto da
  pares + 500 ft (4.500 o 6.500 ft) y la figura, impares + 500 (3.500 o 5.500 ft): quien la
  memorice volará al nivel del tráfico opuesto.
* Magenta y cian saturados, fuera de la paleta de la guía; el color es la única señal de cada
  semicírculo.
* No dice que se mide sobre la derrota magnética ni desde qué altura se aplica.

## Cómo está hecha

Rosa de rumbos con el norte arriba, marcas cada 10° y rótulo cada 30°. La divisoria Este-Oeste
lleva a cada lado el rumbo límite (089° y 090°, 269° y 270°), para que se vea a qué semicírculo
pertenece cada uno:

* **Norte**, de 270° a 089°: relleno azul claro, flecha de derrota hacia el norte, «PARES + 500
  ft» y los ejemplos «4.500 · 6.500 ft… / FL 65 · FL 85…».
* **Sur**, de 090° a 269°: rayado, para que se distinga en escala de grises, flecha hacia el sur,
  «IMPARES + 500 ft» y «3.500 · 5.500 ft… / FL 75 · FL 95…».

Al pie: «Derrota magnética, en vuelo VFR por encima de 3.000 ft AGL (España)». PNG, insertado con
`width="100%"`.

**Datos.** Los del texto, que siguen el RD 1180/2018, art. 6 y anexo I, y el AIP España, ENR 1.7.

## Edición inglesa

Desde el 20 de noviembre de 2026, la misma figura con `--lang en`: «Tracks 270° to 089°», «EVEN +
500 ft», «Tracks 090° to 269°», «ODD + 500 ft», «Magnetic track, VFR flight above 3,000 ft AGL
(Spain)», con separador de miles inglés. El oeste se rotula W.
