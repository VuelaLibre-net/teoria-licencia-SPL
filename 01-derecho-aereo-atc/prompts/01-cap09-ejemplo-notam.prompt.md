---
schema: 1
figura: 01-cap09-ejemplo-notam.png
tipo: documento
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "matplotlib"
  version: "3.10.9"
fuentes:
  - referencia: "AIP España, AD 2 LEZG, designadores de pista 12L/30R y 12R/30L (recursos/fuentes/aip/aip-espana-AD_2_LEZG_es.pdf)"
    licencia: "cita y referencia"
  - referencia: "OACI, Doc 8126 y PANS-ABC (Doc 8400): formato NOTAM y abreviatura CLSD"
    licencia: "cita y referencia"
restricciones:
  - NOTAM de ejemplo, no operativo
  - designador de pista real de Zaragoza
  - sólo los campos A, B, C y E que explica el texto
revision:
  persona: ""
  fecha: ""
master_editable: "tools/figuras/01_derecho_aereo.py"
---

# 01-cap09-ejemplo-notam

**Qué enseña.** Cómo leer los cuatro campos de un NOTAM que más se miran: lugar, inicio, fin y
texto. Texto en `cap09-servicios-de-informacion-aeronautica-ais.qmd`, «Noticias urgentes: NOTAM»,
que usa este mismo ejemplo (2310250800 = 25 de octubre de 2023 a las 08:00 UTC).

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión dibujada por código,
en las dos ediciones; se quitan la clase `.corregir` y la nota del pie, y la figura pasa de `.jpg` a
`.png`. Estuvo marcada desde el 1 de octubre de 2026 (PED-11). Sigue en `borrador`: falta la
revisión técnica de la figura nueva.

## Procedencia

Dibujada con matplotlib 3.10.9 por `ejemplo_notam()`, en
`tools/figuras/01_derecho_aereo.py`. Se regenera con:

```bash
python3 tools/figuras/01_derecho_aereo.py [--lang en] 01-cap09-ejemplo-notam
```

La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* El campo E dice «RWY 12/30 CLOSED», pero Zaragoza tiene dos pistas, 12L/30R y 12R/30L.
* «CLOSED» no es la abreviatura OACI: en un NOTAM es «CLSD».
* Los iconos (calendario para el fin, reloj para el inicio) no aportan nada.

## Cómo está hecha

**Composición.** En el centro, el extracto del NOTAM en tipografía monoespaciada, como se imprime:

```text
A) LEZG
B) 2310250800
C) 2310252000
E) RWY 12R/30L CLSD
```

Cada línea con su llamada a un lado, unida por una línea navy:

* A — «Lugar: aeropuerto de Zaragoza».
* B — «Inicio: 25-10-2023, 08:00 UTC».
* C — «Fin: 25-10-2023, 20:00 UTC».
* E — «Texto: pista 12R/30L cerrada».

Título: «Extracto de un NOTAM (ejemplo)».

**Datos verificados.** Pistas de LEZG en el AIP archivado: 12L/30R (3.032 m) y 12R/30L (3.718 m).
Si el AIP en vigor cambia las pistas, hay que cambiar la figura. La fecha es la del texto; si se
cambia, cambiar las dos.

**Formato.** PNG, insertado con `width="100%"`.

## Edición inglesa

Desde el 20 de noviembre de 2026, la misma figura con `--lang en`: los rótulos en inglés están
junto a los españoles en el script, con `t(es, en)`, y los números llevan el formato inglés.
