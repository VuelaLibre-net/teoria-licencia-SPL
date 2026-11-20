---
schema: 1
figura: 01-cap14-escala-infracciones.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Ley 21/2003, de Seguridad Aérea, arts. 44, 50, 55.1 y 56 (recursos/fuentes/espana/ley-21-2003-seguridad-aerea.pdf)"
    licencia: "texto normativo"
restricciones:
  - las infracciones se gradúan por sus consecuencias (art. 44), no por tipo de conducta
  - sin la escala del art. 55.2 (pregunta abierta NOR-06)
  - sin logotipos ni iconos de esposas o policía
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap14-escala-infracciones

**Qué enseña.** Que la Ley de Seguridad Aérea gradúa la misma conducta como leve, grave o muy grave
según lo que provoca, y cuánto puede costar. Texto en `cap14-derecho-nacional.qmd`, «Infracciones y
sanciones».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (NOR-06). Es una de las tres
**prioritarias** del issue #58: estuvo retirada. Se rehace por código. La edición inglesa es hoy
una copia de la española.

## Qué falla en la figura actual

* Clasifica por tipo de conducta, con listas inventadas («uso inadecuado de radiofrecuencias»,
  «operación con peso o balance fuera de límites»…). La LSA las gradúa por sus consecuencias (art.
  44).
* Contradice el texto: pone la licencia o el médico caducados como leve y el vuelo sin licencia o sin
  CofA como muy grave. Sin consecuencias, todo eso es leve.
* Las cuantías sólo dan el máximo («Hasta 45.000 €»); faltan los tramos y las sanciones sobre la
  licencia (art. 56).
* El semáforo y las esposas sugieren un catálogo penal; lo penal es otra cosa (Ley 209/1964).

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`.

**Composición.** Tres escalones de izquierda a derecha, de menor a mayor, con la misma conducta de
partida a la izquierda: «Incumples una obligación de seguridad (título, aptitud física,
aeronavegabilidad, reglas operacionales, documentación, seguro)». Una flecha por escalón dice qué
la hace subir:

| Escalón | Qué provoca (art. 44) | Multa a un particular (art. 55.1) | Además (art. 56) |
| --- | --- | --- | --- |
| Leve | nada más | apercibimiento o 60–45.000 € | — |
| Grave | incidente grave, lesiones graves o daños de 5.000–15.000 € | 45.001–90.000 € | suspensión de la licencia hasta 5 años |
| Muy grave | accidente, muerte o daños de más de 15.000 € | 90.001–225.000 € | revocación de la licencia |

Debajo, una caja aparte: «Tipificadas aparte (art. 50): no notificar un suceso, leve; no comunicar
un incidente grave a la autoridad de investigación, grave; no comunicarle un accidente u
obstaculizar la investigación, muy grave».

Los escalones en un solo tono que se oscurece (navy), con el nombre del nivel escrito: nada de
verde, ámbar y rojo de semáforo.

**Datos verificados.** Los del texto corregido (NOR-06, revisado contra la Ley 21/2003). Cotejar
las cifras con la ley archivada antes de dibujar.

**Formato.** PNG y `width="100%"`. Al sustituirla, la ruta del `.qmd` pasa de `.jpg` a `.png` en
las dos ediciones y el `.jpg` se borra.

## Edición inglesa

«Minor», «Serious», «Very serious» (los de la traducción del cap14), «You breach a safety
obligation (…)», «nothing else», «serious incident, serious injury or damage of €5,000–15,000»,
«accident, death or damage over €15,000», «Fine for a private individual (art. 55.1)», «licence
suspended for up to 5 years», «licence revoked», «Classified separately (art. 50): …». Cotejar con
la terminología del cap14 inglés.
