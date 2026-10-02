---
schema: 1
figura: 02-cap04-hipoxia-tiempo-conciencia.png
tipo: grafico-cuantitativo
estado: borrador
fecha: ""
herramienta:
  nombre: ""
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

**Estado.** Marcada con `.corregir` en la fase 2 de la corrección (hallazgo COH-02). Hay que
rehacerla.

## Qué falla en la figura actual

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

## Edición inglesa

`en/02-human-performance/imagenes/` lleva una copia idéntica de esta imagen. Al rehacerla, se
genera también la versión con las etiquetas en inglés (términos de `en/terminologia.yml`), se
sustituye allí y se quita la marca *(FIX: …)* del pie inglés.
