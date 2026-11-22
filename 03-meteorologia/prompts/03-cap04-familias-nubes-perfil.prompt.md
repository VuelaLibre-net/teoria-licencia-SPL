---
schema: 1
figura: 03-cap04-familias-nubes-perfil.png
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "OMM, Atlas Internacional de Nubes (OMM-N.º 407), edición en línea de 2017, §2.2.1.2 y tabla 6 (recursos/fuentes/otras/omm-atlas-nubes-useful-concepts-2026-11-21.html)"
    licencia: "© OMM; se citan datos, no se reproduce la figura"
  - referencia: "FAA, Pilot's Handbook of Aeronautical Knowledge, FAA-H-8083-25C, cap. 12"
    licencia: "dominio público (obra del Gobierno de EE. UU.)"
restricciones:
  - tres pisos de la OMM con las alturas del texto (alto 5–13 km, medio 2–7 km, bajo superficie–2 km)
  - nimboestrato en el piso medio
  - Cu y Cb con la base en el piso bajo, aparte como desarrollo vertical
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 03-cap04-familias-nubes-perfil

**Qué enseña.** Los diez géneros de nubes repartidos por pisos. Texto y tabla en `cap04-nubes-y-niebla.qmd`, «Interpretación de la nubosidad».

**Estado.** Marcada `.corregir` desde el 22 de noviembre de 2026 (TEC-16), con la nota del pie en las dos ediciones. Al sustituirla se quitan la clase y la nota en `03-meteorologia/` y en `en/03-meteorology/`, y se anota en `recursos/auditorias/seguimiento-libro-03.md`.

## Qué falla en la figura actual

* Dibuja el nimboestrato en el piso bajo; la OMM y el texto lo ponen en el medio.
* Las alturas de los pisos no coinciden con la tabla del texto, la raya de 20.000 ft está rotulada 16.000 ft y el «0 ft» está mal colocado.

## Cómo rehacerla

Con un generador, comprobando las alturas al recibirla; si el generador no las coloca bien, por código (es un perfil con tres franjas).

## Prompt

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: perfil vertical en franjas horizontales.
Objetivo didáctico: en qué piso aparece cada género de nube, y que el cúmulo y el cumulonimbo arrancan en el piso bajo aunque crecen hasta los otros.
Composición: eje vertical «Altura (km)» de 0 a 13 a la izquierda. Tres franjas horizontales: piso bajo de 0 a 2 km; piso medio de 2 a 7 km; piso alto de 5 a 13 km. Las franjas media y alta se solapan entre 5 y 7 km, con un sombreado ligero en el solape. En el piso alto: cirros, cirrocúmulos y cirroestratos. En el medio: altocúmulos, altoestratos y nimboestrato (el nimboestrato con la base baja y lluvia, pero rotulado en el piso medio). En el bajo: estratos y estratocúmulos. A la derecha, una columna aparte: un cúmulo con la base a 1 km y un cumulonimbo con la base a 1 km y el yunque cerca de los 12 km.
Etiquetas visibles exactas: «Piso alto (5–13 km)», «Piso medio (2–7 km)», «Piso bajo (superficie–2 km)», «Desarrollo vertical», «Cirros (Ci)», «Cirrocúmulos (Cc)», «Cirroestratos (Cs)», «Altocúmulos (Ac)», «Altoestratos (As)», «Nimboestratos (Ns)», «Estratos (St)», «Estratocúmulos (Sc)», «Cúmulos (Cu)», «Cumulonimbos (Cb)», «Altura (km)», «Latitudes medias».
Datos técnicos verificados: pisos de la OMM en latitudes templadas, alto 5–13 km, medio 2–7 km, bajo superficie–2 km; Ns casi siempre en el piso medio (Atlas Internacional de Nubes, 2017).

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF. Líneas
limpias y uniformes; estructura, ejes y líneas guía en azul navy #003366; etiquetas
en gris oscuro #333333, con tipografía sans-serif legible. Sin sombras realistas,
degradados decorativos, texturas, efectos 3D, fondos fotográficos, marcas de agua,
logotipos ni texto ornamental.

Restricciones: todo el texto debe estar en español y ser breve. Los miles se separan
con punto (10.000 m) y los decimales con coma (−56,5 °C). No inventes cifras,
escalas, símbolos aeronáuticos, procedimientos, logotipos ni detalles técnicos. No
incluyas texto de placeholder, palabras como MOCKUP o ToDo, ni referencias a archivos.
Deja espacio suficiente para que las etiquetas se lean a 9 pt al imprimirse.
```

## Edición inglesa

«High étage (5–13 km)», «Middle étage (2–7 km)», «Low étage (surface–2 km)», «Vertical development», «Cirrus (Ci)», «Cirrocumulus (Cc)», «Cirrostratus (Cs)», «Altocumulus (Ac)», «Altostratus (As)», «Nimbostratus (Ns)», «Stratus (St)», «Stratocumulus (Sc)», «Cumulus (Cu)», «Cumulonimbus (Cb)», «Height (km)», «Middle latitudes».
