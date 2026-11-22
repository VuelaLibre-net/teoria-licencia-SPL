---
schema: 1
figura: 03-cap03-base-cumulos-dalr-nca.jpg
tipo: grafico-cuantitativo
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "FAA, Aviation Weather, AC 00-6B, 2016 (recursos/fuentes/faa/faa-ac-00-6b-aviation-weather-2016.pdf), §11.2-11.3"
    licencia: "dominio público (obra del Gobierno de EE. UU.)"
restricciones:
  - parcela de 26 °C en superficie a 14 °C a 4.000 ft
  - punto de rocío de 16 °C a 14 °C a 4.000 ft
  - ambiente más frío que la parcela por encima del NCA
  - eje «Altura sobre el aeródromo (ft)»; decimales con coma
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 03-cap03-base-cumulos-dalr-nca

**Qué enseña.** Cómo se calcula la base de los cúmulos con el DALR y el punto de rocío, y por qué sale la regla (T − T~rocío~) × 400. Texto en `cap03-termodinamica.qmd`, «Gradientes adiabáticos y la base de las nubes».

**Estado.** Marcada `.corregir` desde el 22 de noviembre de 2026 (TEC-01, hallazgo alto), con la nota del pie en las dos ediciones. Al sustituirla se quitan la clase y la nota en `03-meteorologia/` y en `en/03-meteorology/`, y se anota en `recursos/auditorias/seguimiento-libro-03.md`.

## Qué falla en la figura actual

* La línea «Temperatura ambiente (T)» sale de 13 °C en el suelo, no de 26 °C como dice el recuadro.
* La burbuja llega al NCA a 0 °C; con el DALR debería estar a 26 − 3 × 4 = 14 °C. Así queda más fría que el ambiente (0 °C frente a 7 °C): una atmósfera estable, sin cúmulo.
* El tramo saturado baja 0,75 °C/1.000 ft, aunque el rótulo dice 1,5.
* El punto de rocío cae de 16 a 6 °C en unos 2.400 ft (unos 4 °C/1.000 ft), cuando son 0,5 °C/1.000 ft.
* «2.5 °C» lleva punto decimal y el eje dice «ALTITUD»: es altura sobre el aeródromo.

## Cómo rehacerla

Es un gráfico con cifras que el texto calcula: se dibuja por código con matplotlib, como las figuras del libro 09 (`tools/figuras/`, con `estilo.py` para la paleta y la tipografía y `guardar()` para el ancho fijo). Un generador de imágenes no garantiza que la curva pase por los valores exactos. La ficha lleva los datos; el bloque de prompt queda como descripción por si se prefiere un generador.

## Prompt

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: gráfico de líneas temperatura-altura.
Objetivo didáctico: la burbuja se enfría 3 °C/1.000 ft y su punto de rocío 0,5 °C/1.000 ft; se juntan a 2,5 °C/1.000 ft y donde coinciden está la base del cúmulo.
Composición: eje horizontal «Temperatura (°C)» de 0 a 30; eje vertical «Altura sobre el aeródromo (ft)» de 0 a 7.000. Recta roja continua de la burbuja: de (26 °C, 0 ft) a (14 °C, 4.000 ft), y por encima, más tendida, hasta (9,5 °C, 7.000 ft). Recta verde discontinua del punto de rocío: de (16 °C, 0 ft) a (14 °C, 4.000 ft). Línea gris de la curva de estado del ambiente: de (24 °C, 0 ft) a (10 °C, 4.000 ft) y (2 °C, 7.000 ft), siempre más fría que la burbuja por encima de 4.000 ft. Línea horizontal discontinua navy a 4.000 ft rotulada «Base del cúmulo (NCA)». Un cúmulo pequeño dibujado encima de esa línea. Recuadro: «T = 26 °C, Td = 16 °C. (26 − 16) × 400 = 4.000 ft».
Etiquetas visibles exactas: «Burbuja: −3 °C por cada 1.000 ft (DALR)», «Burbuja saturada: unos −1,5 °C por cada 1.000 ft (SALR)», «Punto de rocío: −0,5 °C por cada 1.000 ft», «Ambiente», «Base del cúmulo (NCA)», «Se acercan 2,5 °C por cada 1.000 ft», «Temperatura (°C)», «Altura sobre el aeródromo (ft)».
Datos técnicos verificados: DALR 3 °C/1.000 ft; punto de rocío 0,5 °C/1.000 ft; SALR de 1,2 a 3 °C/1.000 ft, unos 1,5 cerca de la superficie en aire templado (FAA AC 00-6B, §11.2-11.3). La curva del ambiente es ilustrativa: sólo tiene que quedar por debajo de la burbuja.

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

«Parcel: −3 °C per 1,000 ft (DALR)», «Saturated parcel: about −1.5 °C per 1,000 ft (SALR)», «Dew point: −0.5 °C per 1,000 ft», «Environment», «Cumulus base (LCL)», «They close by 2.5 °C per 1,000 ft», «Temperature (°C)», «Height above the aerodrome (ft)»; recuadro «T = 26 °C, Td = 16 °C. (26 − 16) × 400 = 4,000 ft».
