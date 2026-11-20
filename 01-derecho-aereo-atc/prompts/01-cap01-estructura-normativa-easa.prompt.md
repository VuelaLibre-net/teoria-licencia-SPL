---
schema: 1
figura: 01-cap01-estructura-normativa-easa.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Reglamento (UE) 2018/1139, art. 76 (recursos/fuentes/ue/reg-2018-1139-basico-easa-consol-2026-08-02.pdf)"
    licencia: "texto normativo"
restricciones:
  - las CS son especificaciones de certificación, no medios de cumplimiento
  - sin logotipos de EASA ni de la UE
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap01-estructura-normativa-easa

**Qué enseña.** Las capas del sistema normativo de EASA y su fuerza legal: lo que obliga y lo que
ayuda a cumplir. Texto en `cap01-derecho-internacional-convenios-acuerdos-y-organizaciones.qmd`,
«Estructura normativa: normativa vinculante y estándares no vinculantes», y su «Regla de oro».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (PED-04). Se rehace por código.
La edición inglesa es hoy una copia de la española.

## Qué falla en la figura actual

* Rotula la base «AMC + GM + CS: estándares no vinculantes / medios de cumplimiento». Las CS son
  especificaciones de certificación de aeronaves y productos (CS-22, planeadores), no medios de
  cumplimiento.
* No da ningún ejemplo de cada capa.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`.

**Composición.** Dos bloques apilados con una flecha lateral «Fuerza legal» hacia abajo:

* **Normativa vinculante: QUÉ debes cumplir.**
  * «Reglamento base: Reglamento (UE) 2018/1139».
  * «Reglamentos de ejecución (IR): p. ej., 2018/1976 (Part-SFCL y Part-SAO)».
* **Estándares no vinculantes.** Tres cajas en fila:
  * «AMC: CÓMO cumplir de forma reconocida».
  * «GM: explicaciones y ejemplos».
  * «CS: especificaciones para certificar aeronaves; p. ej., CS-22».

Las CS en una caja con otro trazo, para que no se lean como un tercer medio de cumplimiento. Bloque
vinculante en navy lleno con texto blanco; el no vinculante, con contorno navy.

**Datos verificados.** Los del texto: no añadir reglamentos delegados ni otras capas que el
capítulo no explica.

**Formato.** PNG y `width="100%"`. Al sustituirla, la ruta del `.qmd` pasa de `.jpg` a `.png` en
las dos ediciones y el `.jpg` se borra.

## Edición inglesa

«Legal force», «Binding rules: WHAT you must comply with», «Basic Regulation: Regulation (EU)
2018/1139», «Implementing Rules (IR): e.g. 2018/1976 (Part-SFCL and Part-SAO)», «Non-binding
standards», «AMC: HOW to comply in a recognised way», «GM: explanations and examples», «CS:
specifications for certifying aircraft; e.g. CS-22».
