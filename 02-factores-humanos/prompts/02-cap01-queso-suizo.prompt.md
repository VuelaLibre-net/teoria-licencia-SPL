---
schema: 1
figura: 02-cap01-queso-suizo.png
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Reason, J. (1990). *Human Error*. Cambridge University Press"
    licencia: "cita y referencia"
  - referencia: "OACI, Doc 9683, § 2.4 (fallos activos y latentes)"
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

# 02-cap01-queso-suizo

**Qué enseña.** Las capas defensivas del sistema como lonchas de queso con agujeros: el
accidente ocurre cuando los agujeros de todas se alinean. El texto
(`cap01-factores-humanos-conceptos-basicos.qmd`, sección del error humano) nombra cuatro capas:
instrucción, procedimientos, listas de verificación y supervisión.

**Estado.** Marcada con `.corregir` en la fase 3 de la corrección (hallazgo COH-03 de la auditoría
del 1 de octubre de 2026). Hay que rehacerla.

## Qué falla en la figura actual

* Las capas dibujadas («Influencias organizacionales», «Supervisión insegura», «Precondiciones para
  actos inseguros», «Actos inseguros») son los cuatro niveles de HFACS (Shappell y Wiegmann, FAA,
  2000), no las capas que enumera el texto.
* Los ejemplos están en la capa equivocada: la planificación de ruta y el chequeo meteorológico son
  actos del piloto, no influencias organizacionales ni supervisión.
* «Aterrizaje fuera de aeródromo» aparece como acto inseguro, y es una maniobra normal del vuelo a
  vela.
* «Supervisión insegura» aparece dos veces.

## Prompt para rehacerla

Los ejemplos de cada capa son una propuesta; el revisor técnico los confirma o los cambia.

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: diagrama conceptual.
Objetivo didáctico: que el accidente necesita que fallen a la vez varias barreras, y que basta con que una funcione para detenerlo.
Composición: cuatro lonchas de queso en fila, de izquierda a derecha, cada una con su rótulo encima y un ejemplo breve debajo. Una flecha roja entra por la izquierda («Peligro»), atraviesa un agujero alineado en cada loncha y sale por la derecha («Accidente o incidente»). Una segunda flecha, más corta, choca contra la tercera loncha y se detiene («Barrera que funciona»). Sin planeador dibujado ni banderas.
Etiquetas visibles exactas: «Peligro», «Instrucción», «Procedimientos», «Listas de verificación», «Supervisión», «Accidente o incidente», «Barrera que funciona». Ejemplos bajo cada loncha: «Formación incompleta en tomas fuera de campo», «Montaje sin comprobación cruzada», «Lista de prevuelo omitida por prisa», «Briefing del día sin meteorología». Título: «Modelo del queso suizo (James Reason)».
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
