---
schema: 1
figura: 01-cap02-ciclo-arc.jpg
tipo: grafico-cuantitativo
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Reglamento (UE) 1321/2014, Parte ML, ML.A.902 (recursos/fuentes/ue/reg-1321-2014-aeronavegabilidad-part-ml-consol-2026-08-07.pdf)"
    licencia: "texto normativo"
restricciones:
  - eje de tiempo a escala, en años
  - sin iconos de aviones comerciales
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap02-ciclo-arc

**Qué enseña.** Que el ARC vale un año y admite dos prórrogas, de modo que una revisión de la
aeronavegabilidad cubre hasta tres años, y la condición para prorrogarlo. Texto en
`cap02-aeronavegabilidad.qmd`, «La "ITV" anual: certificado de revisión de aeronavegabilidad
(ARC)».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (COH-04). Se rehace por código.
La edición inglesa es hoy una copia de la española.

## Qué falla en la figura actual

* El tramo válido acaba en la segunda prórroga («2 AÑOS») y el que va de ahí a «3 AÑOS» se rotula
  «CADUCADO». Con la segunda prórroga, el ARC vale hasta cumplirse el tercer año.
* Falta la condición de las prórrogas: que la misma CAMO o CAO haya gestionado la aeronavegabilidad
  sin interrupción.
* «Revisión física» no es el nombre del acto: es una revisión de la aeronavegabilidad, que incluye
  la documentación y el estado físico.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`.

**Composición.** Eje horizontal de 0 a 3 años, a escala, con hitos en 0, 1, 2 y 3:

* 0 — «Revisión de la aeronavegabilidad: se expide el ARC».
* 1 — «1.ª prórroga».
* 2 — «2.ª prórroga».
* 3 — «Nueva revisión de la aeronavegabilidad».

Una barra verde `#2E7D32` continua de 0 a 3, rotulada «ARC válido», partida en tres tramos de «1
año». Pasado el 3, un tramo corto gris rayado: «Sin nueva revisión: ARC caducado, no se vuela».
Debajo de los hitos 1 y 2, una nota: «Sólo si la misma CAMO o CAO ha gestionado la aeronavegabilidad
sin interrupción (ML.A.902)».

**Datos verificados.** ML.A.902 a), consolidado a 07-08-2026: «Un CRA tendrá una validez de un año
y podrá prorrogarse por un año más, con un máximo de dos prórrogas consecutivas».

**Formato.** PNG y `width="100%"`. Al sustituirla, la ruta del `.qmd` pasa de `.jpg` a `.png` en
las dos ediciones y el `.jpg` se borra.

## Edición inglesa

«Airworthiness review: ARC issued», «1st extension», «2nd extension», «New airworthiness review»,
«ARC valid», «1 year», «No new review: ARC expired, no flying», «Only if the same CAMO or CAO has
managed continuing airworthiness without interruption (ML.A.902)».
