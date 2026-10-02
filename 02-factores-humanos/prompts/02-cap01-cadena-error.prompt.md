---
schema: 1
figura: 02-cap01-cadena-error.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "OACI, Doc 9683, § 2.4.3 (fallos activos y latentes)"
    licencia: "cita y referencia"
restricciones:
  - sin logotipos, marcas ni reproducción de documentos oficiales
  - texto visible en español, breve
  - sin personas reconocibles
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 02-cap01-cadena-error

**Qué enseña.** La cadena del error durante el montaje del planeador, y que basta con romper
un eslabón —la lista de chequeo descubre el fallo y el piloto rechaza el vuelo— para evitar el
accidente. Texto en `cap01-factores-humanos-conceptos-basicos.qmd`, sección «Prevención y
mitigación del error».

**Estado.** Marcada con `.corregir` en la fase 3 de la corrección (hallazgo COH-04). Hay que
rehacerla.

## Qué falla en la figura actual

* Rotula «ERROR LATENTE (Falta de atención en el montaje)». Según el texto y la OACI, un despiste
  del propio piloto es un error activo; latente es una condición previa del sistema, como una
  instrucción de montaje deficiente o una lista de chequeo inadecuada.
* La lista de chequeo dibujada tiene texto sin sentido («Vortigenerizador», «Pernos de ale.»
  repetido, «Consígnas»).
* Los eslabones «Siguiente paso» y «Fallo inminente» no dicen nada que el alumno pueda reconocer.

## Prompt para rehacerla

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: diagrama conceptual.
Objetivo didáctico: que el accidente es la suma de eslabones —una condición latente, unas condiciones previas, una decisión errónea y un error activo— y que romper uno solo salva el vuelo.
Composición: una cadena horizontal de cinco eslabones, de izquierda a derecha, cada uno con su rótulo y un ejemplo breve. Unas tenazas cortan el cuarto eslabón; tras el corte, el último eslabón («Accidente») aparece separado y atenuado. Debajo del corte, una lista de chequeo con casillas y líneas sin texto legible, salvo un único renglón marcado: «Pernos de las alas asegurados». Un recuadro final con la regla de oro.
Etiquetas visibles exactas: «Error latente: instrucciones de montaje incompletas», «Condiciones previas: fatiga, prisa, ansiedad», «Decisión errónea: montar deprisa», «Error activo: perno principal sin asegurar», «Accidente», «La lista de chequeo lo detecta», «Vuelo rechazado». Regla de oro: «Romper un solo eslabón salva el vuelo». Título: «La cadena del error».
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
