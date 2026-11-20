---
schema: 1
figura: 01-cap06-minimos-vmc.jpg
tipo: grafico-cuantitativo
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Reglamento de Ejecución (UE) 923/2012 (SERA), SERA.5001 y su tabla S5-1 (recursos/fuentes/ue/reg-923-2012-sera-consol-2025-05-01.pdf)"
    licencia: "texto normativo"
  - referencia: "Real Decreto 1180/2018, art. 30 (recursos/fuentes/espana/rd-1180-2018-reglamento-del-aire.pdf)"
    licencia: "texto normativo"
restricciones:
  - la franja inferior acaba en el mayor de 3.000 ft AMSL o 1.000 ft AGL
  - sin la visibilidad de 1.500 m, que en España no vale para planeadores (NOR-01)
  - unidades como en el texto: pies en vertical, metros y kilómetros en horizontal
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap06-minimos-vmc

**Qué enseña.** Los mínimos de visibilidad y distancia a nubes en cada franja de altitud y clase de
espacio aéreo. Texto en `cap06-procedimientos-para-navegacion-aerea-operaciones-de-aeronaves.qmd`,
«Mínimos VFR: visibilidad y distancia a nubes».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (TEC-04). Se rehace por código.
La edición inglesa es hoy una copia de la española.

## Qué falla en la figura actual

* La línea de la franja inferior dice «900 m AMSL o 300 m AGL», sin «el mayor de los dos». Sobre la
  meseta, con el suelo a unos 2.600 ft, la franja llega hasta unos 3.600 ft AMSL, no hasta 3.000.
* Las distancias verticales van en metros («300 m») y el texto las da en pies («1.000 ft»).
* La franja superior rotula «Clases B, C, D, E, F y G» por encima de FL 100 sin decir que la
  visibilidad sube a 8 km por la altitud, no por la clase.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`.

**Composición.** Tres franjas horizontales apiladas, separadas por líneas navy rotuladas:

* Línea superior: «FL 100».
* Línea inferior: «3.000 ft AMSL o 1.000 ft AGL, el mayor de los dos».

En cada franja, un planeador esquemático con sus cotas: visibilidad a la izquierda, distancia
horizontal a una nube a la derecha, distancia vertical arriba y abajo.

| Franja | Clases | Visibilidad | Distancia a nubes |
| --- | --- | --- | --- |
| Por encima de FL 100 | B a G | 8 km | 1.500 m horizontal, 1.000 ft vertical |
| De la línea inferior a FL 100 | B a G | 5 km | 1.500 m horizontal, 1.000 ft vertical |
| Por debajo de la línea inferior | B, C, D, E | 5 km | 1.500 m horizontal, 1.000 ft vertical |
| Por debajo de la línea inferior | F, G | 5 km | libre de nubes y con la superficie a la vista |

La franja inferior se parte en dos mitades verticales, controlado y no controlado, como ahora. Bajo
la mitad F-G, una nota: «En España, también 5 km para planeadores (RD 1180/2018, art. 30)».

**Datos verificados.** Los del texto, que siguen SERA.5001 (tabla S5-1) y el RD 1180/2018, art. 30.
La clase A no admite VFR y no aparece.

**Formato.** PNG y `width="100%"`. Al sustituirla, la ruta del `.qmd` pasa de `.jpg` a `.png` en
las dos ediciones y el `.jpg` se borra.

## Edición inglesa

«FL 100», «3,000 ft AMSL or 1,000 ft AGL, whichever is higher», «Visibility 8 km / 5 km», «Classes
B to G», «Classes B, C, D, E», «Classes F, G», «Clear of cloud and in sight of the surface», «In
Spain, 5 km for gliders too (RD 1180/2018, art. 30)». Separador de miles inglés.
