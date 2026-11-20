---
schema: 1
figura: 01-cap13-piramide-sucesos.png
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "matplotlib"
  version: "3.10.9"
fuentes:
  - referencia: "Reglamento (UE) 996/2010, art. 2 (recursos/fuentes/ue/reg-996-2010-investigacion-accidentes-consol-2024-05-19.pdf)"
    licencia: "texto normativo"
  - referencia: "Heinrich, H. W. (1931). Industrial Accident Prevention. McGraw-Hill"
    licencia: "cita y referencia"
restricciones:
  - las categorías del Reglamento 996/2010 no llevan cifras
  - la proporción de Heinrich sólo aparece como nota, con sus categorías propias
  - sin iconos de aviones comerciales
revision:
  persona: ""
  fecha: ""
master_editable: "tools/figuras/01_derecho_aereo.py"
---

# 01-cap13-piramide-sucesos

**Qué enseña.** Las tres categorías de suceso (accidente, incidente grave e incidente) ordenadas por
gravedad, y la idea de que los leves son mucho más frecuentes que los graves. Texto en
`cap13-notificacion-de-accidentes.qmd`, «Definiciones clave».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión dibujada por código,
en las dos ediciones; se quitan la clase `.corregir` y la nota del pie, y la figura pasa de `.jpg` a
`.png`. Estuvo marcada desde el 1 de octubre de 2026 (TEC-15). Sigue en `borrador`: falta la
revisión técnica de la figura nueva.

## Procedencia

Dibujada con matplotlib 3.10.9 por `piramide_sucesos()`, en
`tools/figuras/01_derecho_aereo.py`. Se regenera con:

```bash
python3 tools/figuras/01_derecho_aereo.py [--lang en] 01-cap13-piramide-sucesos
```

La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* Atribuye a Heinrich la proporción «1 accidente / 30 incidentes graves / 300 incidentes menores».
  Heinrich publicó 1 lesión grave, 29 leves y 300 accidentes sin lesión, en accidentes laborales:
  ni sus cifras ni sus categorías son las del Reglamento 996/2010.
* Fondo de planos técnicos y un avión comercial, contra la guía.

## Cómo está hecha

**Composición.** Pirámide de tres pisos, sin cifras:

* Cima: «Accidente».
* Centro: «Incidente grave: casi fue un accidente».
* Base: «Incidente: afecta o puede afectar a la seguridad».

A la izquierda, una flecha vertical «Más grave» hacia arriba; a la derecha, otra «Más frecuente»
hacia abajo. Debajo, una nota pequeña: «Heinrich (1931), en accidentes laborales: por cada lesión
grave, 29 leves y 300 sucesos sin lesión».

Pisos en un solo tono navy que se oscurece hacia la cima, con el nombre escrito.

**Formato.** PNG, insertado con `width="100%"`.

## Al sustituirla

Por decisión de Ramón (20-11-2026), el pie deja de decir «inspirada en Heinrich» y pasa a
«Pirámide de gravedad de sucesos (Reglamento (UE) 996/2010)»; la nota de Heinrich va en el dibujo.

## Edición inglesa

Desde el 20 de noviembre de 2026, la misma figura con `--lang en`: los rótulos en inglés están
junto a los españoles en el script, con `t(es, en)`, y los números llevan el formato inglés.
