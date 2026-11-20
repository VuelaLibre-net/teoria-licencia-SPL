---
schema: 1
figura: 01-cap09-ejemplo-notam.jpg
tipo: documento
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
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
master_editable: ""
---

# 01-cap09-ejemplo-notam

**Qué enseña.** Cómo leer los cuatro campos de un NOTAM que más se miran: lugar, inicio, fin y texto.
Texto en `cap09-servicios-de-informacion-aeronautica-ais.qmd`, «Noticias urgentes: NOTAM», que usa
este mismo ejemplo (2310250800 = 25 de octubre de 2023 a las 08:00 UTC).

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (PED-11). Se rehace por código.
La edición inglesa es hoy una copia de la española.

## Qué falla en la figura actual

* El campo E dice «RWY 12/30 CLOSED», pero Zaragoza tiene dos pistas, 12L/30R y 12R/30L.
* «CLOSED» no es la abreviatura OACI: en un NOTAM es «CLSD».
* Los iconos (calendario para el fin, reloj para el inicio) no aportan nada.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`.

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
Volver a mirar el AIP en vigor antes de dibujar. La fecha es la del texto; si se cambia, cambiar
las dos.

**Formato.** PNG y `width="100%"`. Al sustituirla, la ruta del `.qmd` pasa de `.jpg` a `.png` en
las dos ediciones y el `.jpg` se borra. La tipografía monoespaciada tiene que estar vendorizada en
`recursos/fonts/`; si no lo está, usar DejaVu Sans Mono de matplotlib y comprobarla en el PDF.

## Edición inglesa

El NOTAM no cambia. Llamadas: «Location: Zaragoza airport», «Start: 25-10-2023, 08:00 UTC», «End:
25-10-2023, 20:00 UTC», «Text: runway 12R/30L closed», «Extract of a NOTAM (example)».
