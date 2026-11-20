---
schema: 1
figura: 01-cap06-regla-semicircular.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
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
master_editable: ""
---

# 01-cap06-regla-semicircular

**Qué enseña.** Qué altitud o nivel de crucero VFR toca según la derrota magnética. Texto en
`cap06-procedimientos-para-navegacion-aerea-operaciones-de-aeronaves.qmd`, «Regla semicircular de
niveles de crucero», con la regla mnemotécnica «Norte Par / Sur Impar».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (COH-01). Es una de las tres
**prioritarias** del issue #58: estuvo retirada. Se rehace por código. La edición inglesa es hoy
una copia de la española.

## Qué falla en la figura actual

* Reparte los niveles **Este-Oeste** («ESTE 0°-179°» impares, «OESTE 180°-359°» pares), que es el
  apéndice 3 de SERA. En España rige la regla **Norte-Sur**. Para una derrota de 045°, el texto da
  pares + 500 ft (4.500 o 6.500 ft) y la figura, impares + 500 (3.500 o 5.500 ft): quien la
  memorice volará al nivel del tráfico opuesto.
* Magenta y cian saturados, fuera de la paleta de la guía; el color es la única señal de cada
  semicírculo.
* No dice que se mide sobre la derrota magnética ni desde qué altura se aplica.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, como las del 07 y el 09, con los rótulos en `t(es, en)`.

**Composición.** Rosa de rumbos vista desde arriba, con el norte arriba y marcas cada 30°. Una línea
navy de 270° a 090° la parte en dos semicírculos:

* **Norte** (de 270° a 089°, pasando por 360°): relleno azul claro y una flecha de derrota hacia el
  norte. Rótulo: «Derrotas de 270° a 089°: pares + 500 ft».
* **Sur** (de 090° a 269°): otro tono, con rayado para que se distinga en escala de grises, y una
  flecha de derrota hacia el sur. Rótulo: «Derrotas de 090° a 269°: impares + 500 ft».

Junto a cada semicírculo, los ejemplos: «4.500 · 6.500 ft… / FL 65 · FL 85…» y «3.500 · 5.500 ft…
/ FL 75 · FL 95…». Debajo, una línea: «Derrota magnética, por encima de 3.000 ft AGL».

**Datos verificados.** Los del texto, que siguen el RD 1180/2018, art. 6 y anexo I, y el AIP España,
ENR 1.7. Los límites son 270° a 089° (norte) y 090° a 269° (sur), ambos incluidos.

**Formato.** PNG y `width="100%"`. Al sustituirla, la ruta del `.qmd` pasa de `.jpg` a `.png` en
las dos ediciones y el `.jpg` se borra.

## Edición inglesa

Mismos datos, con `--lang en`: «Tracks 270° to 089°: even + 500 ft», «Tracks 090° to 269°: odd + 500
ft», «4,500 · 6,500 ft… / FL 65 · FL 85…», «3,500 · 5,500 ft… / FL 75 · FL 95…», «Magnetic track,
above 3,000 ft AGL». Separador de miles inglés (coma).
