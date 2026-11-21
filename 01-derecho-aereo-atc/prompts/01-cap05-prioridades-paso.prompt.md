---
schema: 1
figura: 01-cap05-prioridades-paso.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "ChatGPT (chatgpt.com)"
  version: ""
fuentes:
  - referencia: "Reglamento de Ejecución (UE) 923/2012 (SERA), SERA.3210 (recursos/fuentes/ue/reg-923-2012-sera-consol-2025-05-01.pdf)"
    licencia: "texto normativo"
restricciones:
  - vista en planta, fondo blanco, sin paisaje
  - cada viñeta rotulada con su situación y su regla
  - el que tiene prioridad mantiene rumbo y velocidad
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap05-prioridades-paso

**Qué enseña.** Quién cede el paso y cómo, en los tres encuentros entre planeadores: de frente,
convergencia y alcance. Texto en `cap05-reglas-del-aire.qmd`, «2. Situaciones de conflicto».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión generada con
ChatGPT, en las dos ediciones; se quitan la clase `.corregir` y la nota del pie. Estuvo marcada
desde el 1 de octubre de 2026 (COH-08). Sigue en `borrador`: falta la revisión técnica de la
figura nueva.

## Procedencia

Generada con ChatGPT (chatgpt.com) el 20-11-2026 con el prompt de esta ficha, sin retoques posteriores.
La edición inglesa es la española aceptada, editada en la misma herramienta para sustituir
sólo los rótulos por los de «Edición inglesa». La figura anterior no tenía la procedencia
documentada.

## Qué fallaba en la figura anterior

* Las tres viñetas no llevan rótulo: no se sabe qué situación es cada una.
* Las flechas no dejan claro el rumbo de cada planeador; en una, el planeador apunta en un sentido y
  la flecha va en otro.
* El fondo de campos y ríos resta legibilidad y va contra la guía.

## Prompt

Si el generador no respeta los rumbos, se dibuja por código como las demás: es una vista en planta
con tres pares de siluetas y flechas.

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: tres viñetas en fila, vista en planta desde arriba.
Objetivo didáctico: en cada encuentro entre dos planeadores, cuál cede el paso y qué maniobra hace.
Composición: en cada viñeta, dos siluetas de planeador vistas desde arriba, con el morro claramente apuntando en su sentido de avance. Cada planeador lleva delante una flecha recta corta de su rumbo, alineada con su eje. El planeador que tiene prioridad va en verde #2E7D32 y sigue recto. El que cede va en ámbar #B26A00 y su maniobra es una flecha curva discontinua ámbar.
Viñeta 1, de frente: los dos se acercan por el mismo eje en sentidos opuestos; los dos son ámbar y los dos se desvían a su derecha.
Viñeta 2, convergencia: uno avanza hacia el norte (arriba) y el otro hacia el oeste (izquierda), entrando por la derecha del primero. El que avanza hacia el norte tiene al otro a su derecha: es ámbar, cede y vira a su derecha para pasar por detrás del otro. El que avanza hacia el oeste es verde y sigue recto.
Viñeta 3, alcance: los dos avanzan hacia el norte, uno detrás del otro. El de delante es verde y sigue recto. El de detrás, más rápido, es ámbar y lo rebasa apartándose por la derecha.
Etiquetas visibles exactas: viñeta 1 «De frente: los dos viran a su derecha»; viñeta 2 «Convergencia: cede quien tiene al otro a su derecha»; viñeta 3 «Alcance: el que alcanza se aparta»; leyenda común «Verde: tiene prioridad, mantiene rumbo y velocidad» y «Ámbar: cede el paso».

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF, sin paisaje
ni terreno. Líneas limpias y uniformes; estructura y líneas guía en azul navy #003366;
etiquetas en gris oscuro #333333, con tipografía sans-serif legible. Sin sombras
realistas, degradados decorativos, texturas, efectos 3D, fondos fotográficos, marcas de
agua, logotipos ni texto ornamental. No dependas solo del color: el que cede lleva
además la flecha discontinua.

Restricciones: todo el texto debe estar en español y ser breve. No inventes cifras,
escalas, símbolos aeronáuticos, procedimientos, logotipos ni detalles técnicos. No
incluyas texto de placeholder, palabras como MOCKUP o ToDo, ni referencias a archivos.
Entrega una composición apaisada de proporción 3:1, con espacio suficiente para que las
etiquetas se lean a 9 pt al imprimirse.
```

## Al sustituirla

La remisión `@fig-01-cap05-prioridades` estaba en la viñeta «Aterrizaje», una regla que la figura
no muestra. Ahora va en la frase que abre «2. Situaciones de conflicto», en las dos ediciones, y la
figura sigue a esa frase, antes de la lista.

## Edición inglesa

«Head-on: both turn right», «Converging: the one that has the other on its right gives way»,
«Overtaking: the overtaking glider keeps clear», «Green: has right of way, maintains heading and
speed», «Amber: gives way».
