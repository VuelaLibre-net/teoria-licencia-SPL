---
schema: 1
figura: 03-cap06-frente-frio-estructura.png
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "FAA, Aviation Weather, AC 00-6B, 2016 (recursos/fuentes/faa/faa-ac-00-6b-aviation-weather-2016.pdf), §10.2"
    licencia: "dominio público (obra del Gobierno de EE. UU.)"
  - referencia: "FAA, Pilot's Handbook of Aeronautical Knowledge, FAA-H-8083-25C, cap. 12"
    licencia: "dominio público (obra del Gobierno de EE. UU.)"
restricciones:
  - cuña fría detrás del frente, apoyada en el suelo del lado postfrontal
  - triángulos hacia el aire cálido
  - terreno más cálido que el aire postfrontal
  - viento del S-SW delante y del W-NW detrás
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 03-cap06-frente-frio-estructura

**Qué enseña.** La estructura vertical del frente frío y por qué tras su paso hay térmicas. Texto en `cap06-masas-de-aire-y-frentes.qmd`, «Frentes fríos e inestabilidad».

**Estado.** Marcada `.corregir` desde el 22 de noviembre de 2026 (TEC-04, hallazgo alto), con la nota del pie en las dos ediciones. Al sustituirla se quitan la clase y la nota en `03-meteorologia/` y en `en/03-meteorology/`, y se anota en `recursos/auditorias/seguimiento-libro-03.md`.

## Qué falla en la figura actual

* La masa de aire frío está a la derecha del frente, bajo la masa cálida: en el lado prefrontal. La zona postfrontal queda sin aire frío.
* Los triángulos azules apuntan hacia la zona postfrontal, no hacia el aire cálido al que avanza el frente.
* «Terreno (más frío que el aire post-frontal inicialmente)» contradice el texto: la masa postfrontal es más fría que el terreno, y por eso es inestable.
* «Viento SE» en el sector prefrontal; el sector cálido trae viento del S-SW.

## Cómo rehacerla

Con un generador. Al recibirla, comprobar la geometría antes que nada: el aire frío, detrás y abajo; el cálido, delante y empujado hacia arriba.

## Prompt

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: perfil vertical (corte) de un frente frío que avanza de izquierda a derecha.
Objetivo didáctico: el aire frío, más denso, entra en cuña por debajo del cálido y lo levanta; detrás queda aire frío sobre un suelo más cálido, que da térmicas.
Composición: suelo a lo largo de toda la figura. A la izquierda, una cuña de aire frío azul claro apoyada en el suelo, con el borde delantero empinado y redondeado que avanza hacia la derecha. A la derecha, aire cálido rosado que la cuña obliga a subir por encima de ella; una flecha ancha muestra ese ascenso. Sobre el borde de la cuña, un cumulonimbo con chubascos. Sobre la línea del frente en el suelo, el símbolo de frente frío: línea azul con triángulos que apuntan a la derecha, hacia el aire cálido. Una flecha horizontal navy sobre la cuña: «Avance del frente». Detrás del frente, a la izquierda, cúmulos pequeños de contornos nítidos sobre el suelo, con flechas onduladas que suben desde él.
Etiquetas visibles exactas: «Aire frío (más denso)», «Aire cálido (forzado a subir)», «Frente frío», «Avance del frente», «Zona postfrontal: aire frío sobre suelo más cálido, térmicas y buena visibilidad», «Zona prefrontal», «Chubascos y Cb», «Viento S-SW», «Viento W-NW».
Datos técnicos verificados: la superficie frontal se inclina sobre el aire más frío y denso (FAA AC 00-6B, §10.2); tras el frente frío el viento rola a W-NW y el aire frío que pasa sobre suelo más cálido se calienta desde abajo y se hace inestable (FAA PHAK, cap. 12).

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

«Cold air (denser)», «Warm air (forced to rise)», «Cold front», «Direction of movement», «Post-frontal zone: cold air over warmer ground, thermals and good visibility», «Pre-frontal zone», «Showers and Cb», «Wind S–SW», «Wind W–NW».
