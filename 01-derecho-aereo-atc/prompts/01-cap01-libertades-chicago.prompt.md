---
schema: 1
figura: 01-cap01-libertades-chicago.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "OACI, Doc 7300/9, Convenio sobre Aviación Civil Internacional, y acuerdos anejos de tránsito y de transporte (recursos/fuentes/oaci/oaci-doc-7300-9-convenio-chicago.pdf)"
    licencia: "cita y referencia"
restricciones:
  - el azul es siempre el país de la aeronave; el gris, siempre un país extranjero
  - sin logotipos ni libreas de aerolíneas reales
  - texto visible en español, breve
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap01-libertades-chicago

**Qué enseña.** Las cinco primeras libertades del aire, de los acuerdos anejos al Convenio de
Chicago. Texto en `cap01-derecho-internacional-convenios-acuerdos-y-organizaciones.qmd`, «El origen
de las normas: Convenio de Chicago y OACI».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (PED-04). Se rehace con un
generador de imágenes, a partir de la figura actual. La edición inglesa es hoy una copia de la
española.

## Qué falla en la figura actual

* En la quinta libertad, el país azul (el de la aeronave, como en las otras cuatro) se rotula «país
  extranjero A». Debe ser «país de origen».
* La quinta libertad no destaca el tramo que la define: el tráfico entre los dos países extranjeros,
  en un vuelo que sale del país de origen o acaba en él.
* El título dice «5 libertades… Convenio de Chicago»; el texto explica que hoy se reconocen nueve y
  que Chicago definió las cinco primeras.

## Prompt para rehacerla

Se adjunta la figura actual y se pide conservar la composición: cinco bandas numeradas, una por
libertad.

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL, a partir de la imagen adjunta.

Tipo de figura: diagrama conceptual en cinco bandas horizontales numeradas del 1 al 5.
Objetivo didáctico: distinguir las cinco primeras libertades del aire. Regla de color fija en las cinco bandas: el país de la aeronave es siempre azul y lleva el rótulo «País de origen»; los demás países son siempre grises y llevan «País extranjero».
Composición: conserva la de la imagen adjunta en las bandas 1 a 4. En la banda 5, tres países en fila: a la izquierda el azul «País de origen (A)», en el centro el gris «País extranjero (B)» y a la derecha el gris «País extranjero (C)». Un avión vuela de A a B y luego de B a C. El tramo de B a C, que es el que concede la quinta libertad, va en trazo más grueso y con un corchete debajo: «Pasajeros y carga entre B y C».
Etiquetas visibles exactas: título «Las cinco primeras libertades del aire». Banda 1 «Sobrevolar sin aterrizar»; banda 2 «Escala técnica, sin fines comerciales»; banda 3 «Transporte del país de origen a un país extranjero»; banda 4 «Transporte de un país extranjero al país de origen»; banda 5 «Transporte entre dos países extranjeros, en un vuelo que empieza o acaba en el país de origen». Países: «País de origen (A)», «País extranjero (B)», «País extranjero (C)».

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF. Líneas
limpias y uniformes; estructura, ejes y líneas guía en azul navy #003366; etiquetas
en gris oscuro #333333, con tipografía sans-serif legible. Sin sombras realistas,
degradados decorativos, texturas, efectos 3D, fondos fotográficos, marcas de agua,
logotipos ni texto ornamental. No dependas solo del color: el azul y el gris llevan
además su rótulo.

Restricciones: todo el texto debe estar en español y ser breve. No inventes cifras,
escalas, símbolos aeronáuticos, procedimientos, logotipos ni detalles técnicos. Aviones
genéricos, sin librea de ninguna aerolínea. No incluyas texto de placeholder, palabras
como MOCKUP o ToDo, ni referencias a archivos. Entrega una composición vertical, con
espacio suficiente para que las etiquetas se lean a 9 pt al imprimirse.
```

## Edición inglesa

Se edita la figura española nueva cambiando sólo los rótulos: «The first five freedoms of the air»,
«Overfly without landing», «Technical stop, for non-traffic purposes», «Carriage from the home
country to a foreign country», «Carriage from a foreign country to the home country», «Carriage
between two foreign countries, on a flight that starts or ends in the home country», «Home country
(A)», «Foreign country (B)», «Foreign country (C)», «Passengers and cargo between B and C».
