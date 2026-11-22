---
schema: 1
figura: 03-cap01-atmosfera-isa.jpg
tipo: grafico-cuantitativo
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "FAA, Aviation Weather, AC 00-6B, 2016 (recursos/fuentes/faa/faa-ac-00-6b-aviation-weather-2016.pdf), tabla 1-2"
    licencia: "dominio público (obra del Gobierno de EE. UU.)"
restricciones:
  - 15 °C a 0 m; 6,5 °C/km; −56,5 °C a 11.000 m; vertical por encima
  - eje vertical «Altitud (m)», no «Altura»
  - sin otras capas ni cifras que no estén en el texto
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 03-cap01-atmosfera-isa

**Qué enseña.** El perfil de temperatura de la atmósfera estándar ISA hasta la tropopausa. Texto en `cap01-la-atmosfera.qmd`, «La atmósfera estándar internacional (ISA)» y «Composición y capas de la atmósfera».

**Estado.** Marcada `.corregir` desde el 22 de noviembre de 2026 (TEC-06), con la nota del pie en las dos ediciones. Al sustituirla se quitan la clase y la nota en `03-meteorologia/` y en `en/03-meteorology/`, y se anota en `recursos/auditorias/seguimiento-libro-03.md`.

## Qué falla en la figura actual

* El punto «Nivel del mar: 15,0 °C» está sobre la marca de 10 °C y la recta corta el eje hacia 6–7 °C.
* El codo de la tropopausa queda hacia −58 °C en lugar de −56,5 °C: la pendiente sale de unos 5,8 °C/km, no 6,5.
* El eje dice «Altura (m)»; la ISA se da en altitud.

## Cómo rehacerla

Es un gráfico con cifras que el texto calcula: se dibuja por código con matplotlib, como las figuras del libro 09 (`tools/figuras/`, con `estilo.py` para la paleta y la tipografía y `guardar()` para el ancho fijo). Un generador de imágenes no garantiza que la curva pase por los valores exactos. La ficha lleva los datos; el bloque de prompt queda como descripción por si se prefiere un generador.

## Prompt

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: gráfico de líneas.
Objetivo didáctico: cómo baja la temperatura con la altitud en la ISA y dónde está la tropopausa.
Composición: eje horizontal «Temperatura (°C)» de −70 a 20; eje vertical «Altitud (m)» de 0 a 20.000. Una recta azul navy de (15 °C, 0 m) a (−56,5 °C, 11.000 m) y, desde ahí, vertical hasta 20.000 m. Puntos marcados en los dos extremos de la recta. Una línea horizontal discontinua a 11.000 m rotulada «Tropopausa».
Etiquetas visibles exactas: «Nivel del mar: 15 °C, 1013,25 hPa», «Tropopausa: 11.000 m (36.090 ft), −56,5 °C», «Troposfera: −6,5 °C por cada 1.000 m», «Estratosfera», «Temperatura (°C)», «Altitud (m)».
Datos técnicos verificados: 15 °C a nivel del mar; 6,5 °C/1.000 m; tropopausa a 11.000 m / 36.089 ft y −56,5 °C (FAA AC 00-6B, tabla 1-2).

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

«Sea level: 15 °C, 1013.25 hPa», «Tropopause: 11,000 m (36,090 ft), −56.5 °C», «Troposphere: −6.5 °C per 1,000 m», «Stratosphere», «Temperature (°C)», «Altitude (m)».
