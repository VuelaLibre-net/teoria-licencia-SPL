---
schema: 1
figura: 03-cap03-modelo-columna.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "FAA, Glider Flying Handbook, FAA-H-8083-13B, 2024, cap. 9, fig. 9-7"
    licencia: "dominio público (obra del Gobierno de EE. UU.)"
restricciones:
  - la misma composición que la figura del GFH
  - sin rótulos ni elementos que no estén en el original o en el texto
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 03-cap03-modelo-columna

**Qué enseña.** El modelo de columna (pluma) de la térmica. Texto en `cap03-termodinamica.qmd`, «Convección: el transporte vertical de calor».

**Estado.** Marcada `.corregir` desde el 22 de noviembre de 2026 (PED-07, hallazgo bajo), con la nota del pie en las dos ediciones. Al sustituirla se quitan la clase y la nota en `03-meteorologia/` y en `en/03-meteorology/`, y se anota en `recursos/auditorias/seguimiento-libro-03.md`.

## Qué falla en la figura actual

* Lleva una curva, una línea con punto y una raya discontinua que no están en el original del Glider Flying Handbook (fig. 9-7) ni los explica el texto.

## Cómo rehacerla

Basta con editar la figura actual y quitar la curva, la línea con punto y la raya discontinua que no están en el original; el resto se conserva. Si se rehace, se parte de la fig. 9-7 del Glider Flying Handbook, que es de dominio público, y se rotula en español.

## Prompt

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: edición de la imagen adjunta.
Objetivo didáctico: el mismo de la figura actual.
Composición: conserva la composición, los colores y los rótulos de la imagen adjunta, y quita la curva, la línea con punto y la raya discontinua que no están en el original. No añadas nada.

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

Los mismos rótulos de la figura, traducidos; ninguno nuevo.
