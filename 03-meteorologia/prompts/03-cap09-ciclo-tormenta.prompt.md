---
schema: 1
figura: 03-cap09-ciclo-tormenta.png
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "FAA, Aviation Weather, AC 00-6B, 2016 (recursos/fuentes/faa/faa-ac-00-6b-aviation-weather-2016.pdf), §19.3"
    licencia: "dominio público (obra del Gobierno de EE. UU.)"
restricciones:
  - tres fases, no cuatro
  - en la fase de cúmulo, sólo ascendencias y sin precipitación en el suelo
  - la madurez empieza cuando la precipitación llega al suelo
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 03-cap09-ciclo-tormenta

**Qué enseña.** Las tres fases de la vida de una célula de tormenta. Texto en `cap09-peligros-para-el-vuelo.qmd`, «El ciclo de vida de la célula tormentosa».

**Estado.** Marcada `.corregir` desde el 22 de noviembre de 2026 (COH-04), con la nota del pie en las dos ediciones. Al sustituirla se quitan la clase y la nota en `03-meteorologia/` y en `en/03-meteorology/`, y se anota en `recursos/auditorias/seguimiento-libro-03.md`.

## Qué falla en la figura actual

* Rotula cuatro fases («cúmulo», «desarrollo», «madurez», «disipación») frente a las tres del texto y del pie.
* En la «fase de desarrollo» dibuja una corriente descendente hasta el suelo con «posibles precipitaciones moderadas»: en esa fase todavía no hay precipitación en el suelo.

## Cómo rehacerla

Con un generador; la escala de tiempo de la figura actual (unos 30 minutos) es correcta y se conserva.

## Prompt

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: secuencia de tres viñetas, de izquierda a derecha, sobre una línea de tiempo.
Objetivo didáctico: cómo evolucionan las corrientes y la precipitación en una célula de tormenta, y cuál es la fase más peligrosa.
Composición: tres nubes sobre el mismo suelo. 1) Un cúmulo que crece, sólo con flechas rojas de ascendencia en su interior; nada de lluvia bajo la base. 2) Un cumulonimbo maduro con yunque, flechas rojas de ascendencia y azules de descendencia lado a lado, lluvia intensa y granizo hasta el suelo y, en la superficie, el aire frío que se expande hacia los lados: el frente de racha. 3) Una nube que se deshace, con un yunque residual, sólo flechas azules de descendencia débiles y lluvia ligera. Debajo, una flecha de tiempo de unos 30 minutos.
Etiquetas visibles exactas: «1. Fase de cúmulo (desarrollo)», «Sólo ascendencias; sin precipitación en el suelo», «2. Fase de madurez», «Ascendencias y descendencias; lluvia, granizo, frente de racha», «3. Fase de disipación», «Dominan las descendencias; lluvia débil», «Ascendencia», «Descendencia», «Unos 30 minutos».
Datos técnicos verificados: tres fases; la célula pasa a madurez cuando la precipitación llega a la superficie (FAA AC 00-6B, §19.3).

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

«1. Cumulus (developing) stage», «Updraughts only; no precipitation at the ground», «2. Mature stage», «Updraughts and downdraughts; rain, hail, gust front», «3. Dissipating stage», «Downdraughts dominate; light rain», «Updraught», «Downdraught», «About 30 minutes».
