---
schema: 1
figura: 01-cap04-recencia-requisitos.png
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: "matplotlib"
  version: "3.10.9"
fuentes:
  - referencia: "Reglamento de Ejecución (UE) 2018/1976, Part-SFCL, SFCL.155 y SFCL.160 (recursos/fuentes/ue/reg-2018-1976-part-sao-sfcl-consol-2021-11-15.pdf)"
    licencia: "texto normativo"
restricciones:
  - recencia de planeador, no de TMG
  - sin caras sonrientes ni iconos decorativos
revision:
  persona: ""
  fecha: ""
master_editable: "tools/figuras/01_derecho_aereo.py"
---

# 01-cap04-recencia-requisitos

**Qué enseña.** Los tres filtros antes de volar como piloto al mando: médico, recencia general
(«5-15-2») y recencia del método de lanzamiento. Texto en `cap04-licencias-de-personal.qmd`,
«Experiencia reciente: la regla de los 24 meses» y «Además, por cada método de lanzamiento».

**Estado.** Sustituida el 20 de noviembre de 2026 (issue #58) por una versión dibujada por código,
en las dos ediciones; se quitan la clase `.corregir` y la nota del pie, y la figura pasa de `.jpg` a
`.png`. Estuvo marcada desde el 1 de octubre de 2026 (SYL-01). Sigue en `borrador`: falta la
revisión técnica de la figura nueva.

## Procedencia

Dibujada con matplotlib 3.10.9 por `recencia_requisitos()`, en
`tools/figuras/01_derecho_aereo.py`. Se regenera con:

```bash
python3 tools/figuras/01_derecho_aereo.py [--lang en] 01-cap04-recencia-requisitos
```

La figura anterior no tenía la procedencia documentada.

## Qué fallaba en la figura anterior

* Falta la recencia por método de lanzamiento (SFCL.155): 5 lanzamientos en los últimos 24 meses
  con cada método, o 2 con cable elástico. Se puede cumplir el «5-15-2» con remolques y no estar al
  día para despegar en torno.
* La salida «Vuelo prohibido (contactar instructor)» mezcla dos casos: sin médico no puedes ejercer
  las atribuciones; sin recencia, sí puedes volar con instructor para recuperarla.

## Cómo está hecha

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

**Formato.** PNG, insertado con `width="100%"`.

## Edición inglesa

Desde el 20 de noviembre de 2026, la misma figura con `--lang en`: los rótulos en inglés están
junto a los españoles en el script, con `t(es, en)`, y los números llevan el formato inglés.
