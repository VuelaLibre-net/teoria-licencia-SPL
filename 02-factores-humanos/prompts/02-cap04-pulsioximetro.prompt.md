---
schema: 1
figura: 02-cap04-pulsioximetro.jpg
tipo: ilustracion-realista
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Elaboración propia a partir del texto del capítulo"
    licencia: "misma que la obra"
restricciones:
  - sin logotipos, marcas ni reproducción de documentos oficiales
  - texto visible en español, breve
  - sin personas reconocibles
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 02-cap04-pulsioximetro

**Qué enseña.** Un pulsioxímetro de dedo con la lectura de saturación (SpO₂) y de frecuencia
del pulso. Texto en `cap04-uso-de-oxigeno.qmd`, «Pulsioxímetro».

**Estado.** Marcada con `.corregir` en la fase 7 de la corrección (hallazgo COH-13). Hay que
sustituirla.

## Qué falla en la figura actual

* Muestra la marca comercial de un fabricante en la pantalla. La guía excluye logotipos y marcas.
* El rótulo «SpO2%» de la pantalla está mal compuesto: el 2 queda pegado al signo de porcentaje.

## Prompt para rehacerla

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: ilustración de un objeto (estilo plano, no fotográfico).
Objetivo didáctico: reconocer un pulsioxímetro de dedo y sus dos lecturas.
Composición: un pulsioxímetro de pinza genérico colocado en un dedo índice, visto de tres cuartos, con la pantalla legible. Ningún nombre, marca ni logotipo en la carcasa ni en la pantalla.
Etiquetas visibles exactas: en la pantalla, «SpO₂ %» con «97» y «PR lpm» con «72».
Datos técnicos verificados: no aplica.

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF. Líneas
limpias y uniformes; estructura, ejes y líneas guía en azul navy #003366; etiquetas
en gris oscuro #333333, con tipografía sans-serif legible. Sin sombras realistas,
degradados decorativos, texturas, efectos 3D, fondos fotográficos, marcas de agua,
logotipos ni texto ornamental. Las zonas seguras usan verde #2E7D32 y un estado de
atención usa ámbar #B26A00. Todo el texto va en gris #333333. No dependas solo del
color: añade etiquetas, tipos de línea o formas distintivas.

Restricciones: todo el texto debe estar en español y ser breve. No inventes cifras,
escalas, símbolos aeronáuticos, procedimientos, logotipos ni detalles técnicos. No
incluyas texto de placeholder, palabras como MOCKUP o ToDo, ni referencias a archivos.
Entrega una composición apaisada, con espacio suficiente para que las etiquetas se
lean a 9 pt al imprimirse.
```

## Edición inglesa

`en/02-human-performance/imagenes/` lleva una copia idéntica de esta imagen. Al rehacerla, se
genera también la versión con las etiquetas en inglés (términos de `en/terminologia.yml`), se
sustituye allí y se quita la marca *(FIX: …)* del pie inglés.
