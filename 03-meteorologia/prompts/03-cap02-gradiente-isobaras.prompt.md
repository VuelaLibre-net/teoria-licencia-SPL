---
schema: 1
figura: 03-cap02-gradiente-isobaras.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "FAA, Aviation Weather, AC 00-6B, 2016 (recursos/fuentes/faa/faa-ac-00-6b-aviation-weather-2016.pdf), §7.4-7.5"
    licencia: "dominio público (obra del Gobierno de EE. UU.)"
restricciones:
  - isobaras cada 4 hPa, con rótulos monótonos
  - las flechas de viento casi paralelas a las isobaras, cruzándolas poco hacia la baja
  - sin contornos geográficos reconocibles si no son exactos
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 03-cap02-gradiente-isobaras

**Qué enseña.** La fuerza del gradiente de presión: isobaras juntas, viento fuerte; isobaras separadas, viento flojo. Texto en `cap02-viento.qmd`, «El motor del viento: la fuerza de gradiente» y «El efecto de la fricción en superficie».

**Estado.** Marcada `.corregir` desde el 22 de noviembre de 2026 (PED-01), con la nota del pie en las dos ediciones. Al sustituirla se quitan la clase y la nota en `03-meteorologia/` y en `en/03-meteorology/`, y se anota en `recursos/auditorias/seguimiento-libro-03.md`.

## Qué falla en la figura actual

* Las flechas «Dirección del viento» van rectas del anticiclón a la borrasca, cruzando las isobaras, con el rótulo «El viento sopla desde el anticiclón hacia la borrasca»; el capítulo explica dos párrafos después que no es así.
* Alrededor de la L los rótulos van 1000, 1004, 1006, 1006, 1000, 1012, y hay más de diez isobaras sin rotular entre 1016 y 1012.
* La flecha del recuadro «Isobaras separadas» apunta a la zona de isobaras juntas.

## Cómo rehacerla

Puede hacerse con un generador si respeta los rótulos de las isobaras; si no, por código. Las flechas de la fuerza del gradiente (de la alta a la baja, perpendiculares a las isobaras) y las del viento (casi paralelas) van con estilos distintos para que no se confundan.

## Prompt

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: vista en planta de un mapa de isobaras esquemático, sin costas.
Objetivo didáctico: la fuerza del gradiente apunta de la alta a la baja, pero el viento sopla casi paralelo a las isobaras; donde están juntas, sopla más fuerte.
Composición: un anticiclón «A» a la izquierda y una borrasca «B» a la derecha, con isobaras cerradas cada 4 hPa: 1024 y 1020 alrededor de la A; 1016, 1012, 1008 y 1004 hacia la B, con 1000 en el centro de la B. En un lado del mapa las isobaras están juntas y en el otro separadas. Flechas finas navy discontinuas, perpendiculares a las isobaras, de la A hacia la B: fuerza del gradiente. Flechas azules huecas casi paralelas a las isobaras, girando en sentido antihorario alrededor de la B y horario alrededor de la A, que cruzan las isobaras con un ángulo pequeño hacia la B: viento en superficie. La flecha del viento es más larga donde las isobaras están juntas.
Etiquetas visibles exactas: «A», «B», «1024», «1020», «1016», «1012», «1008», «1004», «1000», «Fuerza del gradiente de presión», «Viento en superficie», «Isobaras juntas: viento fuerte», «Isobaras separadas: viento flojo».
Datos técnicos verificados: en altura el viento es paralelo a las isobaras; en superficie las cruza unos 10° sobre el mar y hasta 45° sobre terreno abrupto (FAA AC 00-6B, §7.4-7.5). Hemisferio norte.

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF. Líneas
limpias y uniformes; estructura, ejes y líneas guía en azul navy #003366; etiquetas
en gris oscuro #333333, con tipografía sans-serif legible. Sin sombras realistas,
degradados decorativos, texturas, efectos 3D, fondos fotográficos, marcas de agua,
logotipos ni texto ornamental.

Restricciones: todo el texto debe estar en español y ser breve. Los miles se separan
con punto (10.000 m) y los decimales con coma (−56,5 °C). No inventes cifras,
escalas, símbolos aeronáuticos, procedimientos, logotipos ni detalles técnicos. No
incluyas texto de placeholder, palabras como MOCKUP o ToDo, ni referencias a archivos.
Deja espacio suficiente para que las etiquetas se lean a 9 pt al imprimirse.
```

## Edición inglesa

«H», «L» (sustituyen a «A» y «B»), los valores de las isobaras sin cambio, «Pressure gradient force», «Surface wind», «Isobars close together: strong wind», «Isobars far apart: light wind».
