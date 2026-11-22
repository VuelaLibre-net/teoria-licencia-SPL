---
schema: 1
figura: 03-cap10-sigwx.png
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "AIP España, GEN 3.5 §3.6.2, «Mapas de tiempo significativo de niveles bajos (SWL)», AMDT 10/26 (recursos/fuentes/aip/aip-espana-GEN_3_5_es.pdf)"
    licencia: "texto normativo"
  - referencia: "OACI, Anexo 3, apéndice 1 (simbología de las cartas de tiempo significativo)"
    licencia: "© OACI; se citan los símbolos, no se reproduce"
restricciones:
  - recreación sin logotipos de AEMET ni del Gobierno de España
  - alturas en centenas de pies; de la superficie a FL150
  - V5: 1.000–5.000 m
  - el festón es nubosidad, no un frente
  - OVC: 8 octas
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 03-cap10-sigwx

**Qué enseña.** Cómo se lee un mapa de tiempo significativo de niveles bajos (SWL) de AEMET. Texto en `cap10-informacion-meteorologica.qmd`, «Mapas de tiempo significativo (SIGWX)».

**Estado.** Marcada `.corregir` desde el 22 de noviembre de 2026 (TEC-05, hallazgo alto), con la nota del pie en las dos ediciones. Al sustituirla se quitan la clase y la nota en `03-meteorologia/` y en `en/03-meteorology/`, y se anota en `recursos/auditorias/seguimiento-libro-03.md`.

## Qué falla en la figura actual

* «Altitudes en hectopiescales (hPa). Ej.: 100 = FL100»: la leyenda de la propia carta dice hectopiés, es decir, centenas de pies.
* «V5: visibilidad entre 5 y 8 km»; es de 1.000 a 5.000 m.
* «Válido para información de vuelo en ruta (planos altos)», en una carta que va de la superficie a FL150.
* «Línea azul: frente frío» señala un festón de nubosidad rotulado «BKN/OVC CU AC».
* «OVC: 8 octas o más».
* El símbolo rojo en forma de Ψ que se rotula como tormentas parece de engelamiento; está pendiente de cotejar con un meteorólogo de AEMET.
* Lleva los logotipos de AEMET y del Gobierno de España sin decir que es una recreación.

## Cómo rehacerla

No se pide a un generador de imágenes: la guía excluye los documentos y logotipos oficiales, y la carta lleva símbolos que tienen que ser exactos. Hay dos caminos: un mapa SWL real de AEMET con su permiso y su crédito, o una recreación esquemática dibujada a mano en vector o por código, sin logotipos, con los símbolos del Anexo 3. Antes de dibujar el símbolo de tormenta, resolver la pregunta abierta del seguimiento.

Rótulos de la recreación: «Alturas en centenas de pies (150 = FL150)», «V5: visibilidad de 1.000 a 5.000 m», «Festón: zona de nubosidad», «OVC: 8 octas», «De la superficie a FL150». Pie, ya publicado: «Ejemplo (recreación) de mapa de tiempo significativo de niveles bajos (SWL) de AEMET, de la superficie a FL150».

## Edición inglesa

Rótulos: «Heights in hundreds of feet (150 = FL150)», «V5: visibility 1,000–5,000 m», «Scalloped line: cloud area», «OVC: 8 oktas», «Surface to FL150». Pie inglés ya publicado: «Example (a recreation) of an AEMET low-level significant weather chart (SWL), from the surface to FL150».
