---
schema: 1
figura: 01-cap10-manga-viento.png
tipo: grafico-cuantitativo
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Convención de origen FAA de unos 3 kt por franja, no norma OACI ni EASA (informe de auditoría del libro 01, TEC-14)"
    licencia: "cita y referencia"
restricciones:
  - los 3 kt por franja se presentan como referencia orientativa
  - conversiones calculadas con 1 kt = 1,852 km/h = 0,5144 m/s
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap10-manga-viento

**Qué enseña.** Cómo estimar a ojo la intensidad del viento por las franjas de la manga que se
llenan, y hacia dónde sopla. Texto en `cap10-aerodromos-y-campos-de-despegue-externos.qmd`, tabla
«Señales visuales de aeródromo», fila «Manga de Viento».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (TEC-14). Se rehace por código.
La edición inglesa es hoy una copia de la española.

## Qué falla en la figura actual

* Presenta los 3 nudos por franja como si fueran una regla; es una convención orientativa (FAA).
* Conversiones mal redondeadas: 9 kt son unos 17 km/h y 4,6 m/s (no 16 y 4,5); 15 kt, unos 7,7 m/s
  (no 7,8). También 6 kt son 3,1 m/s y 12 kt, 6,2 m/s.
* No indica de dónde viene el viento.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`.

**Composición.** Cinco mangas en fila, cada una con una franja más llena que la anterior: el cono
pasa de colgar casi vertical a quedar horizontal. Cinco franjas alternas rojo `#CC0000` y blanco con
contorno navy. Debajo de cada una:

| Franjas llenas | kt | km/h | m/s |
| --- | --- | --- | --- |
| 1 | ≈ 3 | 5,6 | 1,5 |
| 2 | ≈ 6 | 11 | 3,1 |
| 3 | ≈ 9 | 17 | 4,6 |
| 4 | ≈ 12 | 22 | 6,2 |
| 5 | ≈ 15 o más | 28 o más | 7,7 o más |

Una flecha hueca azul sobre la fila: «Viento: la manga apunta hacia donde va». Al pie: «Referencia
orientativa: unos 3 kt por franja».

**Datos verificados.** Calculados aquí: 3 kt = 5,556 km/h = 1,543 m/s; 6 kt = 11,11 / 3,087; 9 kt =
16,67 / 4,630; 12 kt = 22,22 / 6,173; 15 kt = 27,78 / 7,716.

**Formato.** Sigue en PNG, sin cambio de nombre. `width="100%"`.

## Al sustituirla

La tabla del cap10 dice «3 nudos, 5,5 km/h»: son 5,6. Corregirlo a la vez, en las dos ediciones.

## Edición inglesa

«≈ 3 kt», «5.6 km/h», «1.5 m/s»… con punto decimal; «Wind: the sock points where it is going»,
«Rough guide: about 3 kt per band».
