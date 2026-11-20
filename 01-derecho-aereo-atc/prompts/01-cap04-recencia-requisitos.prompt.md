---
schema: 1
figura: 01-cap04-recencia-requisitos.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Reglamento de Ejecución (UE) 2018/1976, Part-SFCL, SFCL.155 y SFCL.160 (recursos/fuentes/ue/reg-2018-1976-part-sao-sfcl-consol-2021-11-15.pdf)"
    licencia: "texto normativo"
restricciones:
  - recencia de planeador, no de TMG
  - sin caras sonrientes ni iconos decorativos
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap04-recencia-requisitos

**Qué enseña.** Los tres filtros antes de volar como piloto al mando: médico, recencia general
(«5-15-2») y recencia del método de lanzamiento. Texto en `cap04-licencias-de-personal.qmd`,
«Experiencia reciente: la regla de los 24 meses» y «Además, por cada método de lanzamiento».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (SYL-01). Se rehace por código.
La edición inglesa es hoy una copia de la española.

## Qué falla en la figura actual

* Falta la recencia por método de lanzamiento (SFCL.155): 5 lanzamientos en los últimos 24 meses
  con cada método, o 2 con cable elástico. Se puede cumplir el «5-15-2» con remolques y no estar al
  día para despegar en torno.
* La salida «Vuelo prohibido (contactar instructor)» mezcla dos casos: sin médico no puedes ejercer
  las atribuciones; sin recencia, sí puedes volar con instructor para recuperarla.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`.

**Composición.** Diagrama de flujo vertical. Título: «¿Puedo volar hoy como piloto al mando?».

1. «¿Certificado médico válido?» — **No** → «No puedes ejercer las atribuciones de tu licencia».
2. «En los últimos 24 meses: ¿5 h, 15 lanzamientos y 2 vuelos de entrenamiento con instructor?»
   (SFCL.160) — **No** → «Completa lo que falte con instructor, en doble mando o solo bajo
   supervisión, o pasa una verificación de competencia».
3. «Con el método de lanzamiento de hoy: ¿5 lanzamientos en 24 meses (2 si es cable elástico)?»
   (SFCL.155) — **No** → «Completa los que falten en doble mando o solo bajo supervisión de un
   instructor».
4. Todo **Sí** → «Puedes volar».

Las salidas de recuperación vuelven con una flecha a la pregunta correspondiente: cuando se
completa, se puede seguir. Verde `#2E7D32` para «Sí» y ámbar `#B26A00` para «No», con las palabras
escritas.

**Datos verificados.** Los del texto (SFCL.155 y SFCL.160 a) y c)). Los TMG tienen otra recencia y
quedan fuera; una nota al pie lo dice: «Planeadores; los TMG tienen su propia recencia (SFCL.160
b))».

**Formato.** PNG y `width="100%"`. Al sustituirla, la ruta del `.qmd` pasa de `.jpg` a `.png` en
las dos ediciones y el `.jpg` se borra.

## Edición inglesa

«Can I fly today as pilot-in-command?», «Valid medical certificate?», «You cannot exercise the
privileges of your licence», «In the last 24 months: 5 h, 15 launches and 2 training flights with an
instructor?», «Complete what is missing with an instructor, dual or solo under supervision, or pass
a proficiency check», «With today's launch method: 5 launches in 24 months (2 for bungee)?», «You
can fly», «Yes», «No». Términos de la traducción del cap04.
