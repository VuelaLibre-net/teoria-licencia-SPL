---
schema: 1
figura: 03-cap06-frente-ocluido.png
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "FAA, Pilot's Handbook of Aeronautical Knowledge, FAA-H-8083-25C, cap. 12"
    licencia: "dominio público (obra del Gobierno de EE. UU.)"
  - referencia: "OMM, Atlas Internacional de Nubes, ficha del nimbostratus (recursos/fuentes/otras/omm-atlas-nubes-nimbostratus-2026-11-21.html)"
    licencia: "© OMM; se citan datos, no se reproduce la figura"
restricciones:
  - oclusión fría: el aire que llega detrás es más frío que el de delante
  - nimboestrato en el piso medio
  - símbolo de oclusión: línea morada con triángulos y semicírculos alternos del mismo lado
  - sin cabeceras ni rótulos ajenos al texto
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 03-cap06-frente-ocluido

**Qué enseña.** La estructura vertical de un frente ocluido (oclusión fría). Texto en `cap06-masas-de-aire-y-frentes.qmd`, «La oclusión y el frente estacionario».

**Estado.** Marcada `.corregir` desde el 22 de noviembre de 2026 (TEC-16 y TEC-30), con la nota del pie en las dos ediciones. Al sustituirla se quitan la clase y la nota en `03-meteorologia/` y en `en/03-meteorology/`, y se anota en `recursos/auditorias/seguimiento-libro-03.md`.

## Qué falla en la figura actual

* Dibuja el nimboestrato en el piso bajo; va en el medio.
* El rótulo «ALTOESTRATOS» cae en la franja de las nubes altas.
* Sobran los semicírculos rojos sobre el frente frío y la cabecera «TABLA INTEGRAL Y DETALLADA», que es un resto del encargo.

## Cómo rehacerla

Con un generador. Basta una sola sección; si se quiere mostrar también la oclusión cálida, en una segunda banda debajo, con el aire de delante más frío que el de detrás.

## Prompt

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: perfil vertical de una oclusión fría que avanza de izquierda a derecha.
Objetivo didáctico: el frente frío alcanza al cálido y levanta del suelo todo el aire cálido; el aire que llega detrás es más frío que el que había delante.
Composición: suelo a lo largo de toda la figura. A la izquierda, aire muy frío azul en cuña. A la derecha, aire fresco azul más claro. La cuña de la izquierda empuja por debajo a la de la derecha. El aire cálido rosado queda separado del suelo, como una lengua elevada entre las dos masas frías. Nubosidad sobre la zona de contacto: nimboestrato con lluvia en el piso medio y algún cumulonimbo embebido; altoestratos y cirroestratos más arriba, delante. En el suelo, donde se tocan las dos masas frías, el símbolo de oclusión: línea morada con triángulos y semicírculos alternos, los dos del mismo lado, apuntando a la derecha. Flecha navy «Avance».
Etiquetas visibles exactas: «Aire frío», «Aire fresco», «Aire cálido elevado», «Frente ocluido (oclusión fría)», «Avance», «Nimboestratos (Ns)», «Altoestratos (As)», «Cirroestratos (Cs)», «Lluvia continua y techos bajos».
Datos técnicos verificados: en la oclusión fría el aire de detrás es más frío que el de delante; en la cálida, al revés (FAA PHAK, cap. 12). El nimboestrato está casi siempre en el piso medio (OMM).

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

«Cold air», «Cool air», «Lifted warm air», «Occluded front (cold occlusion)», «Direction of movement», «Nimbostratus (Ns)», «Altostratus (As)», «Cirrostratus (Cs)», «Continuous rain and low ceilings».
