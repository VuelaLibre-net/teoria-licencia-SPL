---
schema: 1
figura: 01-cap13-flujo-notificacion.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
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
master_editable: ""
---

# 01-cap13-flujo-notificacion

**Qué enseña.** Qué sucesos hay que notificar, a quién y en qué plazo, y que la notificación sirve
para aprender. Texto en `cap13-notificacion-de-accidentes.qmd`, «El deber de notificar: sistema
SNS» y «¿A quién y cuándo?».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (NOR-05). Es una de las tres
**prioritarias** del issue #58: estuvo retirada. Se rehace por código. La edición inglesa es hoy
una copia de la española.

## Qué falla en la figura actual

* La decisión «¿Grave / accidente?» manda todo lo demás a la notificación voluntaria. También es
  obligatorio notificar los sucesos de la lista del Reglamento de Ejecución (UE) 2015/1018, anexo
  V, sección 2: una violación de espacio aéreo, una cuasicolisión con maniobra evasiva, una suelta
  del cable que haya puesto en peligro el planeador, una llamada de emergencia…
* No dice a quién se notifica: la autoridad de investigación y AESA tienen plazos distintos.
* «Investigación y análisis» funde la investigación técnica de accidentes con el análisis del SNS.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`.

**Composición.** Diagrama de flujo vertical, cajas navy y flechas con punta clara:

1. Inicio: «Ocurre un suceso».
2. Decisión: «¿Accidente o incidente grave?».
   * **Sí** → dos cajas en paralelo, unidas por «y»:
     «Autoridad de investigación de accidentes: sin demora (Reglamento 996/2010, art. 9)» y
     «AESA: en 72 horas (Reglamento 376/2014, art. 4.7)».
   * **No** → segunda decisión: «¿Está en la lista del Reglamento 2015/1018 (anexo V, sección 2)?»,
     con un ejemplo corto al lado: «violación de espacio aéreo, cuasicolisión…».
     * **Sí** → «AESA: en 72 horas».
     * **No** → «Notificación voluntaria a AESA, si otros pueden aprender de ello».
3. Las ramas de AESA confluyen en «Análisis del riesgo y lecciones aprendidas».
4. Al pie, una banda: «Cultura justa: lo que AESA sepa sólo por tu notificación no se usa para
   sancionar un error involuntario (Reglamento 376/2014, art. 16)».

Una nota pequeña junto a AESA: «por el sistema de tu organización o, si no tienes, directamente al
SNS». Verde `#2E7D32` para la vía voluntaria, ámbar `#B26A00` para las obligatorias, con rótulos
que lo digan: el color no es la única señal.

**Datos verificados.** Los del texto corregido en la fase 1 de la auditoría (PR #50).

**Formato.** PNG y `width="100%"`. Al sustituirla, la ruta del `.qmd` pasa de `.jpg` a `.png` en
las dos ediciones y el `.jpg` se borra. Si la caja doble no cabe a 9 pt, se apila en vertical.

## Edición inglesa

«An occurrence happens», «Accident or serious incident?», «Accident investigation authority:
without delay», «AESA: within 72 hours», «On the list in Regulation 2015/1018 (Annex V, Section
2)?», «airspace infringement, near collision…», «Voluntary report to AESA, if others can learn from
it», «Risk analysis and lessons learned», «Just culture…». Términos de `en/terminologia.yml`
(«Occurrence reporting system»).
