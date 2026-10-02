---
schema: 1
figura: 02-cap03-vision-tunel.jpg
tipo: diagrama-conceptual
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

# 02-cap03-vision-tunel

**Qué enseña.** Que bajo estrés extremo la atención se concentra en un solo detalle —aquí, el
variómetro— y se pierde todo lo demás. Texto en `cap03-psicologia-aeronautica-basica.qmd`: el
cerebro «focaliza absolutamente toda su atención residual en un solo detalle del vuelo».

**Estado.** Marcada con `.corregir` en la fase 5 de la corrección (hallazgo PED-04). Hay que
rehacerla. Queda abierta para un especialista en factores humanos la pregunta de si el fenómeno es
sólo atencional o también un estrechamiento del campo visual periférico; el rótulo propuesto se
ciñe a lo que dice el texto.

## Qué falla en la figura actual

* El rótulo dice «El estrés extremo reduce drásticamente el campo visual periférico». El texto
  describe una fijación de la atención, y el examen da por incorrecto el distractor de la visión
  periférica.
* La escala del variómetro es incoherente: el «−4» aparece dos veces.

## Prompt para rehacerla

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: diagrama conceptual.
Objetivo didáctico: que el pánico concentra la atención en un solo instrumento y deja fuera el resto de la cabina y el exterior.
Composición: vista de cabina desde el asiento: el variómetro nítido en el centro; el resto del panel, la palanca y el exterior, desvaídos hacia los bordes en anillos concéntricos grises.
Etiquetas visibles exactas: título «Visión de túnel: el estrés extremo estrecha la atención». En la esfera, sólo «m/s» y los números de la escala.
Datos técnicos verificados: escala del variómetro de −5 a +5 m/s, con el 0 a las 9 en punto, los positivos hacia arriba y los negativos hacia abajo; cada número aparece una sola vez. Aguja en −4.

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
