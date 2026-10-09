---
schema: 1
figura: 02-cap04-hipoxia-tiempo-conciencia.png
tipo: grafico-cuantitativo
estado: borrador
fecha: "2026-10-09"
herramienta:
  nombre: "ChatGPT (chatgpt.com)"
  version: ""
fuentes:
  - referencia: "FAA, *Pilot's Handbook of Aeronautical Knowledge*, FAA-H-8083-25C (2023), cap. 17, tabla del tiempo útil de conciencia"
    licencia: "dominio público (EE. UU.)"
  - referencia: "AMC1 SAO.OP.150, Easy Access Rules for Sailplanes (EASA)"
    licencia: "texto oficial de la UE; cita"
  - referencia: "FAA, AIM 8-1-2 b) (visión nocturna desde 5.000 ft)"
    licencia: "dominio público (EE. UU.)"
  - referencia: "FAA, AC 61-107B CHG 1, fig. 2-3 (variabilidad individual)"
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

# 02-cap04-hipoxia-tiempo-conciencia

**Qué enseña.** Cuánto tiempo útil de conciencia (TUC) queda sin oxígeno según la altitud, y
que un descenso largo puede durar más que ese tiempo. Texto en `cap04-uso-de-oxigeno.qmd`,
«Tiempo útil de conciencia», con los mismos valores de la FAA.

**Estado.** Sustituida el 9 de octubre de 2026 (issue #60) por una versión generada con el encargo
de abajo, no dibujada por código: la revisión técnica tiene que cotejar cada cifra con la tabla de
la FAA. En la edición española se quitan la clase `.corregir` y la nota del pie. Vuelve a
`borrador`: falta la revisión técnica de la figura nueva y su versión inglesa, que sigue siendo la
anterior.

## Procedencia

Generada con ChatGPT (chatgpt.com) el 09-10-2026 con el prompt de esta ficha, sin retoques
posteriores. La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* El rótulo rojo dice «Por encima de 3.000 m (≈ 10.000 ft) el oxígeno suplementario es
  obligatorio». No es una obligación legal: SAO.OP.150 obliga a valorar si la falta de oxígeno
  merma a los ocupantes, y los 10.000 ft son la regla por defecto de su AMC1 cuando el piloto no
  puede valorarlo.
* Da ≈ 5 min a 22.000 ft y ≈ 3 min a 25.000 ft; la FAA da 5 a 10 y 3 a 5 min, y el texto también.
* «≤ 3.000 m: sin síntomas de hipoxia» contradice el recuadro de vuelo nocturno: la visión
  nocturna se degrada desde unos 5.000 ft.
* La franja «3.000–5.500 m: 30 min → varias horas» no sale de ninguna tabla de la FAA.

## Cómo rehacerla

Es un gráfico cuantitativo: según `GUIA_ILUSTRACIONES.md` se construye desde los datos, no con un
generador de imágenes. Lo natural es una función en un `tools/figuras/02_factores_humanos.py`
nuevo, con el estilo de `tools/figuras/estilo.py`, como en los libros 07 y 09.

**Datos (FAA-H-8083-25C, cap. 17).** Altitud en ft; la conversión a metros, redondeada, sólo como
apoyo.

| Altitud | Metros (aprox.) | TUC |
| --- | --- | --- |
| 20.000 ft | 6.100 m | 30 min o más |
| 22.000 ft | 6.700 m | 5 a 10 min |
| 25.000 ft | 7.600 m | 3 a 5 min |
| 28.000 ft | 8.500 m | 2½ a 3 min |
| 30.000 ft | 9.100 m | 1 a 2 min |
| 35.000 ft | 10.700 m | 30 a 60 s |

**Rótulos.**

* «Por encima de 10.000 ft de altitud de presión: regla por defecto del AMC1 SAO.OP.150, si el
  piloto no puede valorar el efecto de la falta de oxígeno».
* «Por debajo de 10.000 ft la visión nocturna ya se degrada (desde unos 5.000 ft)».
* «Valores medios: varían mucho entre personas y se acortan con el esfuerzo. La tabla de la OACI
  da cifras algo menores».
* El recuadro del descenso se conserva: de 7.000 m a 3.000 m a 5 m/s son 800 s, unos 13 minutos.
* Fuente al pie: «FAA-H-8083-25C, cap. 17». Sin el lema «Conocimiento que salva vidas».

## Prompt usado

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: gráfico cuantitativo (escala de altitud con el tiempo útil de conciencia). La ficha recomienda dibujarlo por código; si se usa el generador, revisa cada cifra.
Objetivo didáctico: que el tiempo útil de conciencia (TUC) se acorta deprisa con la altitud y que un descenso largo puede durar más que ese tiempo.
Composición: escala vertical de altitud a la izquierda, en pies con los metros aproximados entre paréntesis, con seis marcas espaciadas proporcionalmente. A la derecha de cada marca, una barra horizontal cuyo largo crece con el TUC y su rótulo. Una línea horizontal discontinua en 10.000 ft separa dos franjas: por encima, ámbar; por debajo, blanca. Recuadro aparte con el cálculo del descenso. Nota y fuente al pie.
Etiquetas visibles exactas: «20.000 ft (6.100 m): 30 min o más», «22.000 ft (6.700 m): 5 a 10 min», «25.000 ft (7.600 m): 3 a 5 min», «28.000 ft (8.500 m): 2½ a 3 min», «30.000 ft (9.100 m): 1 a 2 min», «35.000 ft (10.700 m): 30 a 60 s». Sobre la línea: «Por encima de 10.000 ft de altitud de presión: regla por defecto del AMC1 SAO.OP.150, si el piloto no puede valorar el efecto de la falta de oxígeno». Bajo la línea: «Por debajo de 10.000 ft la visión nocturna ya se degrada (desde unos 5.000 ft)». Recuadro: «Descenso de 7.000 m a 3.000 m a 5 m/s: 800 s, unos 13 minutos». Nota: «Valores medios: varían mucho entre personas y se acortan con el esfuerzo. La tabla de la OACI da cifras algo menores». Fuente: «FAA-H-8083-25C, cap. 17». Título: «Tiempo útil de conciencia según la altitud».
Datos técnicos verificados: tabla de TUC de la FAA (FAA-H-8083-25C, cap. 17), copiada tal cual en las etiquetas; no añadas otras altitudes ni otros valores.

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
