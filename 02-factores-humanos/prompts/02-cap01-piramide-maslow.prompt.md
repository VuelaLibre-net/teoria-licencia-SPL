---
schema: 1
figura: 02-cap01-piramide-maslow.png
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Maslow, A. H. (1943). «A Theory of Human Motivation». *Psychological Review*, 50(4), 370-396"
    licencia: "cita y referencia"
  - referencia: "FAA, *Aviation Instructor's Handbook*, FAA-H-8083-9B (2020), cap. 2"
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

# 02-cap01-piramide-maslow

**Qué enseña.** Los cinco niveles de la jerarquía de Maslow aplicados al piloto de planeador:
las necesidades de abajo tienen que estar cubiertas antes de perseguir las de arriba. Texto en
`cap01-factores-humanos-conceptos-basicos.qmd`, «Motivación y desempeño».

**Estado.** Marcada con `.corregir` en la fase 3 de la corrección (hallazgo TEC-01). El orden de
los niveles es correcto; sólo hay que cambiar el segundo.

## Qué falla en la figura actual

* El nivel 2 («Seguridad») pone «Seguridad operacional (SMS), Previsión meteorológica, Equipamiento
  (arnés, paracaídas), Control del planeador». La necesidad de seguridad de Maslow es sentirse a
  salvo —integridad física, estabilidad, ausencia de amenaza—, no la seguridad operacional del vuelo
  ni el SMS.
* «cross-country», en inglés, en el nivel 5; en español, «travesía».

## Prompt para rehacerla

Se puede partir de la imagen actual como referencia de composición: los niveles 1, 3, 4 y 5 se
conservan con sus textos (salvo «travesía»).

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: diagrama conceptual (pirámide de cinco niveles).
Objetivo didáctico: que las necesidades fisiológicas y las de seguridad personal son la base, y que ningún objetivo de orden superior justifica sacrificarlas.
Composición: pirámide de cinco franjas numeradas de abajo arriba, con el rótulo del nivel a la izquierda, un icono sencillo en la franja y dos o tres ejemplos breves a la derecha.
Etiquetas visibles exactas: 1 «Fisiológicas: hidratación, alimentación, descanso, salud, temperatura»; 2 «Seguridad: sentirse a salvo, integridad física, estabilidad»; 3 «Pertenencia: el club, el trabajo en equipo, la comunidad de pilotos»; 4 «Estima: habilidad de pilotaje, logros, respeto de los compañeros»; 5 «Autorrealización: dominio del vuelo, vuelos de onda y travesía». Título: «Pirámide de Maslow aplicada al piloto de planeador».
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
