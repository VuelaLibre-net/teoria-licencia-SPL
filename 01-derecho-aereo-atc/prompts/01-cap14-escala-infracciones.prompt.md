---
schema: 1
figura: 01-cap14-escala-infracciones.png
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "matplotlib"
  version: "3.10.9"
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
master_editable: "tools/figuras/01_derecho_aereo.py"
---

# 01-cap14-escala-infracciones

**Qué enseña.** Que la Ley de Seguridad Aérea gradúa la misma conducta como leve, grave o muy grave
según lo que provoca, y cuánto puede costar. Texto en `cap14-derecho-nacional.qmd`, «Infracciones y
sanciones».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión dibujada por código,
en las dos ediciones; se quitan la clase `.corregir` y la nota del pie, y la figura pasa de `.jpg`
a `.png`. Estuvo marcada desde el 1 de octubre de 2026 (NOR-06) y es una de las tres prioritarias:
llegó a retirarse. Sigue en `borrador`: falta la revisión técnica de la figura nueva.

## Procedencia

Dibujada con matplotlib 3.10.9 por `escala_infracciones()`, en
`tools/figuras/01_derecho_aereo.py`. Se regenera con:

```bash
python3 tools/figuras/01_derecho_aereo.py [--lang en] 01-cap14-escala-infracciones
```

La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* Clasifica por tipo de conducta, con listas inventadas («uso inadecuado de radiofrecuencias»,
  «operación con peso o balance fuera de límites»…). La LSA las gradúa por sus consecuencias (art.
  44).
* Contradice el texto: pone la licencia o el médico caducados como leve y el vuelo sin licencia o
  sin CofA como muy grave. Sin consecuencias, todo eso es leve.
* Las cuantías sólo dan el máximo («Hasta 45.000 €»); faltan los tramos y las sanciones sobre la
  licencia (art. 56).
* El semáforo y las esposas sugieren un catálogo penal; lo penal es otra cosa (Ley 209/1964).

## Cómo está hecha

Arriba, la conducta de partida: «Incumples una obligación de seguridad», con la lista de
obligaciones del texto. De ella bajan tres flechas a tres escalones que suben con la gravedad:
LEVE, GRAVE y MUY GRAVE, en un solo tono navy que se oscurece, con el nombre escrito. Debajo, tres
filas:

| Fila | Leve | Grave | Muy grave |
| --- | --- | --- | --- |
| Si provoca… (art. 44) | nada más | un incidente grave, lesiones graves o daños de 5.000 a 15.000 € | un accidente, la muerte de una persona o daños de más de 15.000 € |
| Multa a un particular (art. 55.1) | apercibimiento o de 60 a 45.000 € | de 45.001 a 90.000 € | de 90.001 a 225.000 € |
| Además, sobre tu licencia (art. 56) | — | puede suspenderse hasta 5 años | puede revocarse |

Al pie, las conductas tipificadas aparte (art. 50). PNG, insertado con `width="100%"`.

**Datos.** Cotejados el 20 de noviembre de 2026 con la Ley 21/2003 archivada: art. 44.1-3, art.
55.1 y art. 56.1, que dice «podrá imponerse», de ahí el «puede».

## Edición inglesa

Desde el 20 de noviembre de 2026, la misma figura con `--lang en`, con los términos de la
traducción del cap14: «MINOR», «SERIOUS», «VERY SERIOUS», «If it causes… (Art. 44)», «Fine for a
private individual (Art. 55(1))», «On top of that, your licence (Art. 56)», «Defined separately
(Art. 50)…». Importes con el símbolo delante: «€45,001 to €90,000».
