---
schema: 1
figura: 02-cap03-decide.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "FAA, *Pilot's Handbook of Aeronautical Knowledge*, FAA-H-8083-25C (2023), cap. 2, «The DECIDE Model»"
    licencia: "dominio público (EE. UU.)"
restricciones:
  - sin logotipos, marcas ni reproducción de documentos oficiales
  - texto visible en español, breve
  - sin personas reconocibles
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 02-cap03-decide

**Qué enseña.** El modelo DECIDE de toma de decisiones como ciclo de seis pasos. Texto en
`cap03-psicologia-aeronautica-basica.qmd` (seis viñetas) y en el glosario.

**Estado.** Marcada con `.corregir` en la fase 2 de la corrección (hallazgo TEC-03). Hay que
rehacerla.

## Qué falla en la figura actual

* Los pasos no siguen el modelo: pone «Estudiar», «Considerar», «Implementar» y «Determinar
  resultados». El orden es Detectar, Estimar, Elegir, Identificar, Hacer y Evaluar.
* Lleva la palabra «TURBULENCE», en inglés.

## Prompt para rehacerla

Las iniciales españolas no forman «DECIDE», así que cada paso lleva la letra y la palabra inglesa
del modelo y debajo la española, como las viñetas del capítulo.

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: diagrama de flujo circular.
Objetivo didáctico: los seis pasos del modelo DECIDE en su orden, como un ciclo que se repite.
Composición: seis círculos dispuestos en anillo, unidos por flechas en el sentido de las agujas del reloj, empezando arriba a la izquierda. En el centro, un planeador en vuelo. Cada círculo: letra grande, palabra inglesa, palabra española y una frase corta.
Etiquetas visibles exactas: «D Detect — Detectar: algo ha cambiado», «E Estimate — Estimar: ¿hace falta reaccionar?», «C Choose — Elegir: el resultado que se busca», «I Identify — Identificar: las acciones que lo consiguen», «D Do — Hacer: ejecutar la acción», «E Evaluate — Evaluar: comprobar el resultado». Título: «El modelo DECIDE».
Datos técnicos verificados: orden del modelo según la FAA (PHAK, cap. 2).

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
