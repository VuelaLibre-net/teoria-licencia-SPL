---
schema: 1
figura: 01-cap10-circuito-transito.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "ChatGPT (chatgpt.com)"
  version: ""
fuentes:
  - referencia: "Texto del cap10 y Libro 6, capítulo 4 (criterios de instrucción del circuito)"
    licencia: "cita y referencia"
restricciones:
  - un planeador, no un avión
  - sin punto inicial (IP) ni «tramo de entrada»
  - sin cifras de altura, que el texto da como criterio de instrucción
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap10-circuito-transito

**Qué enseña.** El circuito de tránsito estándar con virajes a la izquierda, sus tres tramos y la
incorporación a 45° al de viento en cola. Texto en
`cap10-aerodromos-y-campos-de-despegue-externos.qmd`, «El circuito de tránsito (Traffic Pattern)» y
«Fases clave para el planeador».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión generada con
ChatGPT, en las dos ediciones; se quitan la clase `.corregir` y la nota del pie. Estuvo marcada
desde el 1 de octubre de 2026 (PED-12). Sigue en `borrador`: falta la revisión técnica de la
figura nueva.

## Procedencia

Generada con ChatGPT (chatgpt.com) el 20-11-2026 con el prompt de esta ficha, sin retoques posteriores.
La edición inglesa es la española aceptada, editada en la misma herramienta para sustituir
sólo los rótulos por los de «Edición inglesa». La figura anterior no tenía la procedencia
documentada.

## Qué fallaba en la figura anterior

* Dibuja un bimotor, no un planeador.
* Introduce el punto inicial (IP) y el «tramo de entrada», que el texto no explica.
* Repite el circuito en planta y en perspectiva, con montañas de fondo; basta la planta.

## Prompt

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: vista en planta desde arriba, con el norte arriba.
Objetivo didáctico: los tramos del circuito de tránsito estándar de un planeador, con todos los virajes a la izquierda.
Composición: una pista horizontal en el centro. El aterrizaje es de izquierda a derecha y el viento sopla de derecha a izquierda (flecha hueca azul y una manga junto a la pista que apunta a la izquierda). El circuito es un rectángulo recorrido en sentido antihorario: el tramo de viento en cola va por encima de la pista (al norte), paralelo a ella, de derecha a izquierda; en su extremo izquierdo, viraje a la izquierda al tramo base, que baja; nuevo viraje a la izquierda a la final, que va de izquierda a derecha alineada con la pista hasta la toma. Un trazo de incorporación llega desde arriba a la derecha y se une al principio del tramo de viento en cola formando 45°, con el ángulo marcado. Un planeador (ala larga y fina, sin motor) vuela en el tramo de viento en cola, con el morro en su sentido de avance.
Etiquetas visibles exactas: «Viento en cola: chequeo pre-aterrizaje», «Base: ajuste de altura y velocidad», «Final: frenos fuera», «Incorporación a 45°», «Viento», «Virajes a la izquierda».

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF, sin paisaje.
Líneas limpias y uniformes; pista y líneas guía en azul navy #003366; etiquetas en gris
oscuro #333333, con tipografía sans-serif legible. La trayectoria por el aire es un trazo
continuo con flechas de sentido. El viento usa flecha hueca azul. Sin sombras realistas,
degradados decorativos, texturas, efectos 3D, fondos fotográficos, marcas de agua,
logotipos ni texto ornamental.

Restricciones: todo el texto debe estar en español y ser breve. No inventes cifras,
escalas, símbolos aeronáuticos, procedimientos, logotipos ni detalles técnicos. Ni punto
inicial ni tramo de entrada. No incluyas texto de placeholder, palabras como MOCKUP o
ToDo, ni referencias a archivos. Entrega una composición apaisada, con espacio
suficiente para que las etiquetas se lean a 9 pt al imprimirse.
```

Revisar al recibirla: que el circuito gire en sentido antihorario, que el viento en cola vaya en
sentido contrario al aterrizaje y que la manga apunte a sotavento.

## Edición inglesa

«Downwind: pre-landing checks», «Base: adjust height and speed», «Final: airbrakes out», «Joining at
45°», «Wind», «Left-hand circuit». Términos de `en/terminologia.yml` («Downwind leg»).
