---
schema: 1
figura: 01-cap10-manga-viento.png
tipo: grafico-cuantitativo
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "matplotlib"
  version: "3.10.9"
fuentes:
  - referencia: "Convención de origen FAA de unos 3 kt por franja, no norma OACI ni EASA (informe de auditoría del libro 01, TEC-14)"
    licencia: "cita y referencia"
restricciones:
  - los 3 kt por franja se presentan como referencia orientativa
  - conversiones calculadas con 1 kt = 1,852 km/h = 0,5144 m/s
revision:
  persona: ""
  fecha: ""
master_editable: "tools/figuras/01_derecho_aereo.py"
---

# 01-cap10-manga-viento

**Qué enseña.** Cómo estimar a ojo la intensidad del viento por las franjas de la manga que se
llenan, y hacia dónde sopla. Texto en `cap10-aerodromos-y-campos-de-despegue-externos.qmd`, tabla
«Señales visuales de aeródromo», fila «Manga de Viento».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión dibujada por código,
en las dos ediciones; se quitan la clase `.corregir` y la nota del pie, y la figura conserva su
nombre. Estuvo marcada desde el 1 de octubre de 2026 (TEC-14). Sigue en `borrador`: falta la
revisión técnica de la figura nueva.

## Procedencia

Dibujada con matplotlib 3.10.9 por `manga_viento()`, en
`tools/figuras/01_derecho_aereo.py`. Se regenera con:

```bash
python3 tools/figuras/01_derecho_aereo.py [--lang en] 01-cap10-manga-viento
```

La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* Presenta los 3 nudos por franja como si fueran una regla; es una convención orientativa (FAA).
* Conversiones mal redondeadas: 9 kt son unos 17 km/h y 4,6 m/s (no 16 y 4,5); 15 kt, unos 7,7 m/s
  (no 7,8). También 6 kt son 3,1 m/s y 12 kt, 6,2 m/s.
* No indica de dónde viene el viento.

## Cómo está hecha

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

**Formato.** PNG, insertado con `width="100%"`.

## Al sustituirla

La tabla del cap10 decía «3 nudos, 5,5 km/h»; se corrigió a 5,6 en las dos ediciones (5.6 km/h en
inglés).

## Edición inglesa

Desde el 20 de noviembre de 2026, la misma figura con `--lang en`: los rótulos en inglés están
junto a los españoles en el script, con `t(es, en)`, y los números llevan el formato inglés.
