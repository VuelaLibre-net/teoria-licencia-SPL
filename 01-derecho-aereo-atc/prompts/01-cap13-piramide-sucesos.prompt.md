---
schema: 1
figura: 01-cap13-piramide-sucesos.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
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
master_editable: ""
---

# 01-cap13-piramide-sucesos

**Qué enseña.** Las tres categorías de suceso (accidente, incidente grave e incidente) ordenadas por
gravedad, y la idea de que los leves son mucho más frecuentes que los graves. Texto en
`cap13-notificacion-de-accidentes.qmd`, «Definiciones clave».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (TEC-15). Se rehace por código.
La edición inglesa es hoy una copia de la española.

## Qué falla en la figura actual

* Atribuye a Heinrich la proporción «1 accidente / 30 incidentes graves / 300 incidentes menores».
  Heinrich publicó 1 lesión grave, 29 leves y 300 accidentes sin lesión, en accidentes laborales:
  ni sus cifras ni sus categorías son las del Reglamento 996/2010.
* Fondo de planos técnicos y un avión comercial, contra la guía.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`.

**Composición.** Pirámide de tres pisos, sin cifras:

* Cima: «Accidente».
* Centro: «Incidente grave: casi fue un accidente».
* Base: «Incidente: afecta o puede afectar a la seguridad».

A la izquierda, una flecha vertical «Más grave» hacia arriba; a la derecha, otra «Más frecuente»
hacia abajo. Debajo, una nota pequeña: «Heinrich (1931), en accidentes laborales: por cada lesión
grave, 29 leves y 300 sucesos sin lesión».

Pisos en un solo tono navy que se oscurece hacia la cima, con el nombre escrito.

**Formato.** PNG y `width="100%"`. Al sustituirla, la ruta del `.qmd` pasa de `.jpg` a `.png` en
las dos ediciones y el `.jpg` se borra.

## Al sustituirla

El pie dice «inspirada en Heinrich». Con la figura nueva puede quedar en «Pirámide de gravedad de
sucesos (Reglamento (UE) 996/2010)», y la nota de Heinrich ya va en el dibujo. Proponérselo a Ramón.

## Edición inglesa

«Accident», «Serious incident: almost an accident», «Incident: affects or could affect safety»,
«More serious», «More frequent», «Heinrich (1931), on industrial accidents: for every serious
injury, 29 minor ones and 300 occurrences without injury».
