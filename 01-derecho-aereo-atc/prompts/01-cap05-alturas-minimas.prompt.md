---
schema: 1
figura: 01-cap05-alturas-minimas.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "ChatGPT (chatgpt.com)"
  version: ""
fuentes:
  - referencia: "Reglamento de Ejecución (UE) 923/2012 (SERA), SERA.5005 f) (recursos/fuentes/ue/reg-923-2012-sera-consol-2025-05-01.pdf)"
    licencia: "texto normativo"
  - referencia: "Real Decreto 1180/2018, art. 33 (recursos/fuentes/espana/rd-1180-2018-reglamento-del-aire.pdf)"
    licencia: "texto normativo"
restricciones:
  - los 300 m se miden desde el obstáculo más alto en un radio de 600 m
  - el planeador de ladera, a barlovento
  - sin rascacielos reconocibles ni logotipos
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap05-alturas-minimas

**Qué enseña.** Las alturas mínimas de SERA.5005 f) sobre aglomeraciones y en campo abierto, y la
excepción española del vuelo de ladera. Texto en `cap05-reglas-del-aire.qmd`, «Alturas mínimas de
vuelo» y «Excepciones para el vuelo a vela».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión generada con
ChatGPT, en las dos ediciones; se quitan la clase `.corregir` y la nota del pie. Estuvo marcada
desde el 1 de octubre de 2026 (TEC-03, NOR-08). Sigue en `borrador`: falta la revisión técnica de la
figura nueva.

## Procedencia

Generada con ChatGPT (chatgpt.com) el 20-11-2026 con el prompt de esta ficha, sin retoques posteriores.
La edición inglesa es la española aceptada, editada en la misma herramienta para sustituir
sólo los rótulos por los de «Edición inglesa». La figura anterior no tenía la procedencia
documentada.

**Diferencias con el encargo.** La figura aceptada no lleva el rótulo «Sotavento: el aire baja» ni
las flechas que bajan tras la cresta, y no dibuja el planeador sobre la población: la cota del
radio de 600 m no parte de él. Las dos correcciones de la auditoría (planeador a barlovento y
300 m desde el obstáculo más alto) sí están. Si en la revisión técnica se echa de menos el
sotavento, se pide en la misma conversación.

## Qué fallaba en la figura anterior

* El planeador de ladera está a sotavento, donde el aire baja. Debe estar a barlovento, donde el
  viento choca con la ladera y sube.
* La cota de los 300 m sobre la ciudad parte de una azotea baja; se mide desde el obstáculo más alto
  en un radio de 600 m.
* En campo abierto falta «o sobre el obstáculo más alto en un radio de 150 m».

## Prompt

Si el generador no coloca las cotas donde se piden, se dibuja por código: es un perfil con tres
cotas.

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: perfil lateral en dos bandas, una encima de otra.
Objetivo didáctico: desde dónde se miden las alturas mínimas, y por qué el planeador de ladera vuela a barlovento.
Composición:
Banda superior, izquierda: una población con edificios de alturas distintas. El más alto está claramente marcado. Una línea horizontal navy por encima de él y una cota vertical con flechas en los dos extremos que va desde lo alto de ese edificio hasta la línea: «300 m (1.000 ft)». Una cota horizontal discontinua bajo la línea, centrada en el avión, rotulada «radio de 600 m».
Banda superior, derecha: campo abierto con un árbol aislado. Otra línea navy más baja y una cota vertical desde el suelo: «150 m (500 ft)».
Banda inferior: una ladera larga. El viento entra por la izquierda con flechas huecas azules que suben por la cara izquierda de la ladera. El planeador vuela pegado a esa cara izquierda, a barlovento, por debajo de la cresta. Al otro lado de la cresta, flechas que bajan.
Etiquetas visibles exactas: «Sobre aglomeraciones: 300 m (1.000 ft) sobre el obstáculo más alto en un radio de 600 m», «En cualquier otra parte: 150 m (500 ft) sobre el suelo o el obstáculo más alto en 150 m», «Viento», «Barlovento: el aire sube», «Sotavento: el aire baja», «Excepción: vuelo de ladera (RD 1180/2018, art. 33)».

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF. Líneas
limpias y uniformes; estructura, cotas y líneas guía en azul navy #003366; etiquetas en
gris oscuro #333333, con tipografía sans-serif legible. El viento usa flecha hueca azul.
Sin sombras realistas, degradados decorativos, texturas, efectos 3D, fondos
fotográficos, marcas de agua, logotipos ni texto ornamental.

Restricciones: todo el texto debe estar en español y ser breve. No inventes cifras,
escalas, símbolos aeronáuticos, procedimientos, logotipos ni detalles técnicos. No
incluyas texto de placeholder, palabras como MOCKUP o ToDo, ni referencias a archivos.
Entrega una composición cuadrada, con espacio suficiente para que las etiquetas se lean
a 9 pt al imprimirse.
```

## Edición inglesa

«Over congested areas: 300 m (1,000 ft) above the highest obstacle within 600 m», «Elsewhere: 150 m
(500 ft) above the ground or the highest obstacle within 150 m», «Wind», «Windward: the air rises»,
«Leeward: the air sinks», «Exception: ridge soaring (RD 1180/2018, art. 33)».
