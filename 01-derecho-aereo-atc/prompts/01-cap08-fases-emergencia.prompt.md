---
schema: 1
figura: 01-cap08-fases-emergencia.png
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "matplotlib"
  version: "3.10.9"
fuentes:
  - referencia: "Reglamento de Ejecución (UE) 2017/373, ATS.TR.400 y ATS.TR.405 (recursos/fuentes/ue/reg-2017-373-ats-ais-met-consol-2026-02-22.pdf)"
    licencia: "texto normativo"
restricciones:
  - los medios SAR salen en DETRESFA, no en ALERFA
  - el RCC está informado desde INCERFA
  - en DETRESFA basta una de las dos condiciones
  - sin balizas giratorias ni paneles con remaches
revision:
  persona: ""
  fecha: ""
master_editable: "tools/figuras/01_derecho_aereo.py"
---

# 01-cap08-fases-emergencia

**Qué enseña.** Las tres fases del servicio de alerta, qué dispara cada una y en cuál salen los
medios de búsqueda y salvamento. Texto en `cap08-servicio-de-transito-aereo.qmd`, «3. Servicio de
alerta (ALRS)».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión dibujada por código,
en las dos ediciones; se quitan la clase `.corregir` y la nota del pie, y la figura pasa de `.jpg` a
`.png`. Estuvo marcada desde el 1 de octubre de 2026 (NOR-12, PED-10). Sigue en `borrador`: falta la
revisión técnica de la figura nueva.

## Procedencia

Dibujada con matplotlib 3.10.9 por `fases_emergencia()`, en
`tools/figuras/01_derecho_aereo.py`. Se regenera con:

```bash
python3 tools/figuras/01_derecho_aereo.py [--lang en] 01-cap08-fases-emergencia
```

La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* En ALERFA dice «Se activan recursos de búsqueda y rescate»: salen en DETRESFA.
* No dice que la dependencia ATS informa al centro coordinador de salvamento (RCC) desde la fase de
  incertidumbre.
* En DETRESFA exige «peligro inminente **y** asistencia inmediata»: basta una de las dos.
* Los criterios de cada fase son vagos («falta de información o contacto»); el texto da los de
  ATS.TR.405.

## Cómo está hecha

**Composición.** Tres columnas de izquierda a derecha, unidas por flechas de escalada, con un número
de fase (1, 2, 3) además del color:

* **INCERFA — Incertidumbre.** «Sin noticias 30 min después de lo previsto, o no llega 30 min
  después de su hora prevista». «Se recaba información».
* **ALERFA — Alerta.** «Siguen sin noticias; o no aterriza 5 min después de lo previsto con
  autorización; o su eficiencia operativa está afectada». «Aumenta la preocupación».
* **DETRESFA — Peligro.** «Peligro grave e inminente **o** necesidad de asistencia inmediata (p.
  ej., aterrizaje forzoso)». «Salen los medios de búsqueda y salvamento».

Bajo las tres columnas, una banda continua desde la primera: «Desde INCERFA, el ATS informa al
centro coordinador de salvamento (RCC)». Tonos de un solo color que se oscurecen hacia la derecha,
con el número de fase escrito.

**Datos verificados.** Los del texto corregido (NOR-12), que sigue ATS.TR.405.

**Formato.** PNG, insertado con `width="100%"`.

## Edición inglesa

Desde el 20 de noviembre de 2026, la misma figura con `--lang en`: los rótulos en inglés están
junto a los españoles en el script, con `t(es, en)`, y los números llevan el formato inglés.
