---
schema: 1
figura: 01-cap10-senales-aerodromo.png
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Reglamento de Ejecución (UE) 923/2012 (SERA), apéndice 1, 3.2 y figuras A1-1 a A1-11; págs. 96-97 del consolidado (recursos/fuentes/ue/reg-923-2012-sera-consol-2025-05-01.pdf)"
    licencia: "texto normativo"
restricciones:
  - formas y colores de las figuras A1 de SERA, sin reinterpretarlas
  - significados como en SERA, apéndice 1, 3.2
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap10-senales-aerodromo

**Qué enseña.** A reconocer las señales del área de señales y saber qué ordena cada una. Texto en
`cap10-aerodromos-y-campos-de-despegue-externos.qmd`, tabla «Señales visuales de aeródromo
(SERA, apéndice 1, 3.2)».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (TEC-06). Se rehace por código.
La edición inglesa es hoy una copia de la española.

## Qué falla en la figura actual

* La mancuerna dice «SOLO en pistas y calles pavimentadas. No pises la hierba». SERA 3.2.3.1 dice
  sólo pistas y calles de rodaje, que pueden ser de hierba.
* La cruz roja (aspa amarilla) dice «El aeródromo está cerrado o la pista inutilizable». Prohíbe
  aterrizar, y la prohibición puede prolongarse; el aeródromo no tiene por qué estar cerrado.
* Faltan señales que el texto explica: la mancuerna con barras negras, las cruces sobre pista o
  calle de rodaje y la letra C.
* Las formas son aproximadas; la flecha a rayas no sigue la figura A1-9.

## Cómo rehacerla: por código

En `tools/figuras/01_derecho_aereo.py`, con los rótulos en `t(es, en)`. Las formas se dibujan en
vector copiando las proporciones de las figuras A1 de SERA (págs. 96-97 del PDF archivado), no de
memoria.

**Composición.** Rejilla de 3 × 3, cada señal sobre un cuadro gris claro que haga de suelo, con su
nombre y una línea de significado debajo:

| Señal (SERA, ap. 1) | Rótulo | Significado |
| --- | --- | --- |
| Cuadrado rojo con aspa amarilla (3.2.1) | Prohibido aterrizar | Puede prolongarse |
| Cuadrado rojo con una diagonal amarilla (3.2.2) | Precaución | Al aproximar y aterrizar |
| Pesas blancas (3.2.3.1) | Sólo pistas y calles de rodaje | Para aterrizar, despegar y rodar |
| Pesas con barra negra en cada círculo (3.2.3.2) | Sólo pistas para aterrizar y despegar | Lo demás, libre |
| Cruz sobre pista o calle (3.2.4) | Zona no utilizable | Blanca en pista, amarilla en calle |
| T de aterrizaje, blanca o naranja (3.2.5.1) | Dirección de aterrizaje y despegue | Paralelo al brazo, hacia el travesaño |
| Flecha a la derecha de color llamativo (3.2.6) | Virajes a la derecha | Antes de aterrizar y tras despegar |
| Letra C negra sobre amarillo (3.2.7) | Oficina ATS | Notificación |
| Doble cruz blanca (3.2.8) | Planeadores en vuelo | Hay actividad de vuelo a vela |

Ni la manga (tiene su figura) ni las dos cifras de la torre. Una flecha en la T con la dirección de
aterrizaje ayuda a leerla.

**Datos verificados.** Los de SERA, apéndice 1, 3.2, en el PDF archivado; coinciden con la tabla
del cap10.

**Formato.** Sigue en PNG, sin cambio de nombre. `width="100%"`; con nueve casillas, comprobar que
el significado no baja de 9 pt.

## Edición inglesa

«Landing prohibited», «Special precautions», «Runways and taxiways only», «Runways only for take-off
and landing», «Area unusable», «Landing T», «Right-hand traffic», «ATS reporting office», «Gliders
flying», con los significados en inglés de SERA, Appendix 1, 3.2 (cotejar con la tabla del cap10
inglés).
