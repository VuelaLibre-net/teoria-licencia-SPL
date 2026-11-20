---
schema: 1
figura: 01-cap03-ubicacion-matricula.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Orden FOM/1687/2015, arts. 4-5 y anexo II (recursos/fuentes/espana/orden-fom-1687-2015-marcas-aeronaves.pdf)"
    licencia: "texto normativo"
restricciones:
  - marcas del ala en el intradós del ala izquierda
  - la marca de nacionalidad es EC; la bandera o la franja son aparte
  - sin distintivo de competición
  - sin logotipos ni marcas de fabricantes
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap03-ubicacion-matricula

**Qué enseña.** Dónde van las marcas EC-ABC en un planeador, su altura mínima y dónde van los
colores de España. Texto en `cap03-marcas-de-nacionalidad-y-matricula-de-aeronaves.qmd`, «Ubicación
y dimensiones de las marcas» y «La bandera de España».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (COH-06). Se rehace con un
generador de imágenes. La edición inglesa es hoy una copia de la española.

## Qué falla en la figura actual

* Las marcas del ala van en la cara superior (extradós); van en el intradós, la cara inferior, del
  ala izquierda o abarcando las dos.
* Rotula la bandera como «Nacionalidad». La marca de nacionalidad es EC; la bandera o la franja
  con los colores de España es una obligación aparte.
* Rotula «BC» en la deriva como «código de competencia: letras del club u operador». El distintivo
  de competición no es eso, y el texto no lo trata: se quita.
* No da las alturas mínimas (50 cm en el ala, 30 cm en el fuselaje o la deriva).

## Prompt para rehacerla

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: dos vistas técnicas de un mismo planeador biplaza de ala alta y cola en T.
Objetivo didáctico: dónde van las marcas de nacionalidad y matrícula y los colores de España.
Composición: arriba, vista lateral izquierda del planeador, con «EC-ABC» en el fuselaje, entre el ala y la cola, y encima de la matrícula, paralela a ella, una franja horizontal roja-amarilla-roja con los colores de la bandera de España, de la misma altura que las letras. Abajo, vista en planta desde abajo (el observador mira el intradós), con el morro hacia arriba: «EC-ABC» pintado en el intradós del ala izquierda del planeador, que en esta vista desde abajo aparece a la derecha del observador, con la parte superior de las letras hacia el borde de ataque. El ala derecha, sin marcas.
Etiquetas visibles exactas: «Vista lateral», «Vista desde abajo», «Fuselaje o deriva: altura mínima 30 cm», «Intradós del ala izquierda: altura mínima 50 cm», «EC: marca de nacionalidad», «ABC: marca de matrícula», «Colores de España, a la altura de las marcas».
Datos técnicos verificados: Orden FOM/1687/2015 y anexo II D: alas, 50 cm en el intradós del ala izquierda o abarcando ambas; fuselaje o superficies verticales de cola, 30 cm; franja o bandera de altura no menor que las marcas.

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF. Líneas
limpias y uniformes; estructura, contornos y líneas guía en azul navy #003366; etiquetas
en gris oscuro #333333, con tipografía sans-serif legible. Sin sombras realistas,
degradados decorativos, texturas, efectos 3D, fondos fotográficos, marcas de agua,
logotipos ni texto ornamental. Las llamadas son líneas finas navy con un punto en el
extremo, que no tapan las letras.

Restricciones: todo el texto debe estar en español y ser breve. No inventes cifras,
escalas, símbolos aeronáuticos, logotipos ni detalles técnicos. Ninguna otra letra ni
número en el planeador: sin distintivo de competición ni marcas de fabricante. No
incluyas texto de placeholder, palabras como MOCKUP o ToDo, ni referencias a archivos.
Entrega una composición apaisada, con espacio suficiente para que las etiquetas se lean
a 9 pt al imprimirse.
```

Revisar al recibirla: que las letras del intradós estén en el ala izquierda del planeador (a la
derecha en la vista desde abajo) y se lean desde abajo, no en espejo.

## Edición inglesa

«Side view», «View from below», «Fuselage or fin: minimum height 30 cm», «Underside of the left
wing: minimum height 50 cm», «EC: nationality mark», «ABC: registration mark», «Spanish colours, as
high as the marks». Las marcas EC-ABC no se traducen.
