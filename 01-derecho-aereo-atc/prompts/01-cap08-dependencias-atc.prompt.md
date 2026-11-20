---
schema: 1
figura: 01-cap08-dependencias-atc.jpg
tipo: diagrama-conceptual
estado: borrador
fecha: "2026-11-20"
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "AIP España, GEN 3.3 (recursos/fuentes/aip/aip-espana-GEN_3_3_es.pdf)"
    licencia: "cita y referencia"
restricciones:
  - el ACC es un centro de control, no un aeropuerto
  - la torre controla el aeródromo y el circuito
  - sin logotipos ni libreas de aerolíneas reales
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 01-cap08-dependencias-atc

**Qué enseña.** Las tres dependencias del servicio de control y la fase de vuelo de cada una. Texto
en `cap08-servicio-de-transito-aereo.qmd`, «1. Servicio de control (ATC)».

**Estado.** Marcada con `.corregir` desde el 1 de octubre de 2026 (PED-10). Se rehace con un
generador de imágenes, a partir de la figura actual. La edición inglesa es hoy una copia de la
española.

## Qué falla en la figura actual

* Dibuja el ACC como una terminal de aeropuerto con torre. Es un centro de control, en un edificio
  propio, lejos de los aeropuertos.
* Rotula la torre «TWR - Suelo» y «gestión de pista y rodaje». La torre controla el aeródromo y el
  circuito: despegues, aterrizajes, rodaje y el tránsito del circuito.

## Prompt para rehacerla

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL, a partir de la imagen adjunta.

Tipo de figura: diagrama conceptual en tres bandas horizontales apiladas.
Objetivo didáctico: qué dependencia de control atiende cada fase del vuelo.
Composición: conserva las tres bandas de la imagen adjunta, con estos cambios.
Banda superior, ACC: a la izquierda, un edificio de oficinas bajo y sin torre, con una antena de radar al lado y una sala de pantallas sugerida por la ventana; ningún avión ni pista junto a él. A la derecha, dos aviones en crucero a gran altura unidos al edificio por líneas finas discontinuas de comunicación.
Banda central, APP: un avión que asciende y otro que desciende alrededor de un aeropuerto lejano.
Banda inferior, TWR: la torre junto a la pista. Alrededor de la pista, el rectángulo del circuito de tránsito dibujado con trazo continuo y flechas en sentido antihorario, con un avión en él; otro despegando y otro rodando. La torre se une con líneas finas a los tres.
Etiquetas visibles exactas: «Centro de control de área (ACC): vuelos en ruta», «Control de aproximación (APP): entradas y salidas de la zona del aeropuerto», «Torre (TWR): aeródromo y circuito: despegues, aterrizajes y rodaje», «Circuito de tránsito».

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF. Líneas
limpias y uniformes; estructura y líneas guía en azul navy #003366; etiquetas en gris
oscuro #333333, con tipografía sans-serif legible. Sin sombras realistas, degradados
decorativos, texturas, efectos 3D, fondos fotográficos, marcas de agua, logotipos ni
texto ornamental. La trayectoria por el aire es continua.

Restricciones: todo el texto debe estar en español y ser breve. No inventes cifras,
escalas, símbolos aeronáuticos, procedimientos, logotipos ni detalles técnicos. Aviones
genéricos, sin librea de ninguna aerolínea. No incluyas texto de placeholder, palabras
como MOCKUP o ToDo, ni referencias a archivos. Entrega una composición vertical, con
espacio suficiente para que las etiquetas se lean a 9 pt al imprimirse.
```

## Edición inglesa

«Area control centre (ACC): en-route flights», «Approach control (APP): arrivals and departures
around the airport», «Aerodrome control tower (TWR): aerodrome and circuit: take-offs, landings and
taxiing», «Traffic circuit». Términos de `en/terminologia.yml`.
