---
schema: 1
figura: 01-cap01-estructura-normativa-easa.png
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "matplotlib"
  version: "3.10.9"
fuentes:
  - referencia: "Reglamento (UE) 2018/1139, art. 76 (recursos/fuentes/ue/reg-2018-1139-basico-easa-consol-2026-08-02.pdf)"
    licencia: "texto normativo"
restricciones:
  - las CS son especificaciones de certificación, no medios de cumplimiento
  - sin logotipos de EASA ni de la UE
revision:
  persona: ""
  fecha: ""
master_editable: "tools/figuras/01_derecho_aereo.py"
---

# 01-cap01-estructura-normativa-easa

**Qué enseña.** Las capas del sistema normativo de EASA y su fuerza legal: lo que obliga y lo que
ayuda a cumplir. Texto en `cap01-derecho-internacional-convenios-acuerdos-y-organizaciones.qmd`,
«Estructura normativa: normativa vinculante y estándares no vinculantes», y su «Regla de oro».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión dibujada por código,
en las dos ediciones; se quitan la clase `.corregir` y la nota del pie, y la figura pasa de `.jpg` a
`.png`. Estuvo marcada desde el 1 de octubre de 2026 (PED-04). Sigue en `borrador`: falta la
revisión técnica de la figura nueva.

## Procedencia

Dibujada con matplotlib 3.10.9 por `estructura_normativa_easa()`, en
`tools/figuras/01_derecho_aereo.py`. Se regenera con:

```bash
python3 tools/figuras/01_derecho_aereo.py [--lang en] 01-cap01-estructura-normativa-easa
```

La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* Rotula la base «AMC + GM + CS: estándares no vinculantes / medios de cumplimiento». Las CS son
  especificaciones de certificación de aeronaves y productos (CS-22, planeadores), no medios de
  cumplimiento.
* No da ningún ejemplo de cada capa.

## Cómo está hecha

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

**Formato.** PNG, insertado con `width="100%"`.

## Edición inglesa

Desde el 20 de noviembre de 2026, la misma figura con `--lang en`: los rótulos en inglés están
junto a los españoles en el script, con `t(es, en)`, y los números llevan el formato inglés.
