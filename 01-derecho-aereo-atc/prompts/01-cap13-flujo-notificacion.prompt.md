---
schema: 1
figura: 01-cap13-flujo-notificacion.png
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "matplotlib"
  version: "3.10.9"
fuentes:
  - referencia: "Reglamento (UE) 996/2010, art. 9 (recursos/fuentes/ue/reg-996-2010-investigacion-accidentes-consol-2024-05-19.pdf)"
    licencia: "texto normativo"
  - referencia: "Reglamento (UE) 376/2014, arts. 4.7 y 16 (recursos/fuentes/ue/reg-376-2014-notificacion-sucesos-consol-2018-09-11.pdf)"
    licencia: "texto normativo"
  - referencia: "Reglamento de Ejecución (UE) 2015/1018, anexo V, sección 2 (recursos/fuentes/ue/reg-2015-1018-lista-sucesos-consol-2026-08-17.pdf)"
    licencia: "texto normativo"
  - referencia: "Ley 2/2024, disposición adicional primera (recursos/fuentes/espana/ley-2-2024-autoridad-investigacion-accidentes.pdf)"
    licencia: "texto normativo"
restricciones:
  - no dibujar la notificación de incidentes no graves a la autoridad de investigación (pregunta abierta NOR-05, Ley 2/2024, art. 9.1 c))
  - no nombrar la CIAIAC, suprimida el 15-07-2026
  - sin logotipos de AESA ni de la autoridad de investigación
revision:
  persona: ""
  fecha: ""
master_editable: "tools/figuras/01_derecho_aereo.py"
---

# 01-cap13-flujo-notificacion

**Qué enseña.** Qué sucesos hay que notificar, a quién y en qué plazo, y que la notificación sirve
para aprender. Texto en `cap13-notificacion-de-accidentes.qmd`, «El deber de notificar: sistema
SNS» y «¿A quién y cuándo?».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión dibujada por código,
en las dos ediciones; se quitan la clase `.corregir` y la nota del pie, y la figura pasa de `.jpg`
a `.png`. Estuvo marcada desde el 1 de octubre de 2026 (NOR-05) y es una de las tres prioritarias:
llegó a retirarse. Sigue en `borrador`: falta la revisión técnica de la figura nueva.

## Procedencia

Dibujada con matplotlib 3.10.9 por `flujo_notificacion()`, en
`tools/figuras/01_derecho_aereo.py`. Se regenera con:

```bash
python3 tools/figuras/01_derecho_aereo.py [--lang en] 01-cap13-flujo-notificacion
```

La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* La decisión «¿Grave / accidente?» manda todo lo demás a la notificación voluntaria. También es
  obligatorio notificar los sucesos de la lista del Reglamento de Ejecución (UE) 2015/1018, anexo
  V, sección 2: una violación de espacio aéreo, una cuasicolisión con maniobra evasiva, una suelta
  del cable que haya puesto en peligro el planeador, una llamada de emergencia…
* No dice a quién se notifica: la autoridad de investigación y AESA tienen plazos distintos.
* «Investigación y análisis» funde la investigación técnica de accidentes con el análisis del SNS.

## Cómo está hecha

Diagrama de flujo vertical:

1. «Ocurre un suceso».
2. «¿Es un accidente o un incidente grave?».
   * **Sí** → «Autoridad de investigación de accidentes: sin demora (Reglamento 996/2010, art.
     9)» y, «y además», «Obligatoria: AESA, en 72 horas (Reglamento 376/2014, art. 4.7)».
   * **No** → «¿Está en la lista del Reglamento 2015/1018 (anexo V, sección 2)? P. ej., una
     violación de espacio aéreo o una cuasicolisión».
     * **Sí** → «Obligatoria: AESA, en 72 horas».
     * **No** → «Voluntaria: AESA, si otros pueden aprender de ello».
3. Las tres cajas de AESA confluyen en «AESA analiza el riesgo y difunde las lecciones aprendidas»,
   con la vía de notificación: por el sistema de la organización o directamente al SNS.
4. Al pie, la cultura justa (Reglamento 376/2014, art. 16.6).

Ámbar `#B26A00` y trazo continuo para lo obligatorio; verde `#2E7D32` y trazo discontinuo para lo
voluntario. Las cajas dicen además «Obligatoria» o «Voluntaria»: el color no es la única señal. PNG,
insertado con `width="100%"`.

**Datos.** Los del texto corregido en la auditoría (PR #50). La CIAIAC no aparece: el texto ya
habla de la autoridad de investigación que la sustituyó.

## Edición inglesa

Desde el 20 de noviembre de 2026, la misma figura con `--lang en`, con los rótulos de la
traducción del cap13: «An occurrence happens», «Is it an accident or a serious incident?»,
«Accident investigation authority: without delay», «Mandatory: AESA, within 72 hours»,
«Voluntary: AESA, if others can learn from it», «Just culture…». Los artículos se citan a la
inglesa: «Art. 4(7)», «Art. 16(6)».
