---
schema: 1
figura: 02-cap02-imsafe.jpg
tipo: infografia
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "AMC1 SAO.GEN.130(f) & SAO.GEN.135(b), ED Decision 2019/001/R (8 h sin alcohol)"
    licencia: "texto oficial de la UE; cita"
  - referencia: "FAA, *Pilot's Handbook of Aeronautical Knowledge*, FAA-H-8083-25C (2023), cap. 2 (IMSAFE)"
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

# 02-cap02-imsafe

**Qué enseña.** La lista personal IMSAFE antes de cada vuelo. Texto en
`cap02-fisiologia-aeronautica-basica-y-mantenimiento-de-salud.qmd`: el libro usa la E de
*Eating* (alimentación) y avisa de que la FAA usa *Emotion*.

**Estado.** Marcada con `.corregir` en la fase 2 de la corrección (hallazgo COH-01). Hay que
rehacerla.

## Qué falla en la figura actual

* El alcohol rotula «24 h mín. antes del vuelo». El AMC de EASA, el texto, Anki y el banco dicen
  8 h; las 12-24 h de la FAA son una recomendación de otra jurisdicción.
* El recuadro «Si alguna respuesta es "NO", no vuele» se invierte en dos preguntas formuladas en
  positivo: la S («¿Tengo preocupaciones…?») y la A («¿He consumido alcohol?»). Con ellas, responder
  «no» es justo lo que permite volar.

## Prompt para rehacerla

Las seis preguntas van con la misma polaridad: «sí» es favorable, y la regla final funciona en
todas.

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: infografía (lista de comprobación).
Objetivo didáctico: repasar las seis comprobaciones personales antes de cada vuelo y cancelar si alguna sale desfavorable.
Composición: columna izquierda con las seis letras I-M-S-A-F-E en grande, cada una con su palabra, su pregunta y un icono simple; a la derecha, un piloto genérico (sin rasgos reconocibles) junto a un planeador, repasando la lista; abajo a la derecha, recuadro con la regla.
Etiquetas visibles exactas: «I Enfermedad: ¿Estoy libre de enfermedad y de síntomas?», «M Medicación: ¿Estoy libre de efectos de medicamentos?», «S Estrés: ¿Estoy libre de preocupaciones que me distraigan?», «A Alcohol: ¿Llevo al menos 8 h sin beber?», «F Fatiga: ¿Estoy descansado y alerta?», «E Alimentación: ¿He comido y bebido lo suficiente?». Recuadro: «Si alguna respuesta es NO, no vuele». Título: «Lista IMSAFE».
Datos técnicos verificados: 8 h entre la última copa y el vuelo (AMC1 SAO.GEN.130(f)).

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
