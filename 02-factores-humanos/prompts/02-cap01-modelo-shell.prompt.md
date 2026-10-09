---
schema: 1
figura: 02-cap01-modelo-shell.png
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-10-09"
herramienta:
  nombre: "ChatGPT (chatgpt.com)"
  version: ""
fuentes:
  - referencia: "OACI, Doc 9683, *Human Factors Training Manual*, cap. 2 (modelo SHELL)"
    licencia: "cita y referencia; no se reproduce el diagrama de la OACI"
restricciones:
  - sin logotipos, marcas ni reproducción de documentos oficiales
  - texto visible en español, breve
  - sin personas reconocibles
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 02-cap01-modelo-shell

**Qué enseña.** Las cinco piezas del modelo SHELL encajadas como un rompecabezas, con el
piloto (Liveware) en el centro. La cita `@fig-02-cap01-modelo-shell` está en
`cap01-factores-humanos-conceptos-basicos.qmd`.

**Estado.** Rehecha el 9 de octubre de 2026 (issue #60) con el encargo de abajo: plana, sin relieve,
y con la glosa española de las cinco piezas. Vuelve a `borrador`: falta la revisión técnica de la
figura nueva y su versión inglesa, que sigue siendo la anterior.

## Procedencia

Generada con ChatGPT (chatgpt.com) el 09-10-2026 con el prompt de esta ficha, sin retoques
posteriores. La figura anterior no tenía la procedencia documentada.

## Observaciones sobre la figura anterior

* Las piezas S, H y E sólo llevan el término inglés; las dos L, en cambio, llevan glosa española
  («Liveware - Piloto»). El glosario del libro da la glosa de las cinco: Software (procedimientos),
  Hardware (la aeronave), Environment (el entorno). Conviene unificar.
* El relieve 3D y las sombras se apartan de la identidad gráfica (`GUIA_ILUSTRACIONES.md`): se
  normaliza cuando se rehaga, no sólo por eso.

## Prompt usado

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: diagrama conceptual (piezas de rompecabezas, planas).
Objetivo didáctico: que el piloto está en el centro y los problemas aparecen en las juntas entre él y cada uno de los otros cuatro elementos.
Composición: cinco piezas de rompecabezas planas encajadas en cruz: en el centro la L del piloto; arriba S, a la izquierda H, a la derecha E y abajo la otra L. Bordes algo irregulares para sugerir que las juntas pueden no encajar del todo. Cada pieza con su letra grande, el término inglés y la glosa española. Sin relieve 3D ni sombras.
Etiquetas visibles exactas: «S Software: procedimientos, listas, normas», «H Hardware: el planeador y sus instrumentos», «E Environment: el entorno», «L Liveware: otras personas», en el centro «L Liveware: el piloto». Título: «El modelo SHELL».
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
