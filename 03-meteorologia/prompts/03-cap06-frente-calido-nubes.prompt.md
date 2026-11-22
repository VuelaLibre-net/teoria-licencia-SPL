---
schema: 1
figura: 03-cap06-frente-calido-nubes.png
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "FAA, Aviation Weather, AC 00-6B, 2016 (recursos/fuentes/faa/faa-ac-00-6b-aviation-weather-2016.pdf), §10.2"
    licencia: "dominio público (obra del Gobierno de EE. UU.)"
  - referencia: "FAA, Pilot's Handbook of Aeronautical Knowledge, FAA-H-8083-25C, cap. 12"
    licencia: "dominio público (obra del Gobierno de EE. UU.)"
restricciones:
  - el aire frío delante del frente, bajo la nubosidad, del lado del observador
  - «normalmente estable»: con aire cálido inestable puede haber Cb embebidos
  - miles con punto (10.000 m)
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 03-cap06-frente-calido-nubes

**Qué enseña.** La secuencia de nubes que anuncia un frente cálido y cómo degrada el VFR. Texto en `cap06-masas-de-aire-y-frentes.qmd`, «Frentes cálidos y subsidencia pre-frontal».

**Estado.** Marcada `.corregir` desde el 22 de noviembre de 2026 (TEC-19), con la nota del pie en las dos ediciones. Al sustituirla se quitan la clase y la nota en `03-meteorologia/` y en `en/03-meteorology/`, y se anota en `recursos/auditorias/seguimiento-libro-03.md`.

## Qué falla en la figura actual

* El rótulo «AIRE TOTALMENTE ESTABLE»: si el aire cálido que asciende es inestable, el frente cálido puede llevar cumulonimbos embebidos.
* Los miles van con coma («10,000 m», «6,000 m», «3,000 m», «<1,000 m»).
* Se vio al preparar esta ficha, fuera del informe, y hay que revisarlo al rehacerla: la cuña de «Aire frío estacionario» está a la izquierda, detrás, cuando el aire frío está delante del frente, bajo las nubes que ve el observador; el rótulo «Potenciales térmicas antes del frente (zona de aire inestable)» no lo respalda el texto; y «nieblas cálidas» es, en el texto, «nieblas frontales».

## Cómo rehacerla

Con un generador. Al recibirla, comprobar que el aire frío está a la derecha, bajo toda la nubosidad, y que el aire cálido sube por encima de él desde la izquierda.

## Prompt

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: perfil vertical de un frente cálido que avanza de izquierda a derecha hacia un observador situado a la derecha.
Objetivo didáctico: el aire cálido sube despacio por encima del frío; el observador ve primero cirros muy altos y luego nubes cada vez más bajas y gruesas, hasta la lluvia continua.
Composición: suelo a lo largo de toda la figura. Una superficie frontal muy tendida que sube suavemente desde el frente, en el suelo a la izquierda, hasta el borde derecho. Debajo, una cuña de aire frío azul claro, más gruesa hacia la derecha. Encima, aire cálido rosado, con una flecha ancha que sube por la superficie frontal hacia la derecha. Sobre ella, de derecha a izquierda: cirros a unos 10.000 m, cirroestratos a unos 6.000 m, altoestratos a unos 3.000 m y nimboestratos con lluvia continua cerca del frente, con estratos bajos y niebla debajo. En el suelo, a la izquierda, el símbolo del frente cálido: línea roja con semicírculos que apuntan a la derecha. Un observador de pie a la derecha mirando hacia la izquierda. Una flecha navy «Avance del frente» hacia la derecha.
Etiquetas visibles exactas: «Aire cálido», «Aire frío», «Frente cálido», «Avance del frente», «Cirros (Ci), unos 10.000 m: horas o días antes», «Cirroestratos (Cs), unos 6.000 m», «Altoestratos (As), unos 3.000 m», «Nimboestratos (Ns): lluvia continua», «Estratos y nieblas frontales», «Aire normalmente estable; si es inestable, Cb embebidos».
Datos técnicos verificados: la superficie del frente cálido tiene poca pendiente y la nubosidad es estratiforme si el aire cálido que sube es estable (FAA AC 00-6B, §10.2); con aire cálido inestable puede haber cumulonimbos (FAA PHAK, cap. 12). Las alturas son orientativas.

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF. Líneas
limpias y uniformes; estructura, ejes y líneas guía en azul navy #003366; etiquetas
en gris oscuro #333333, con tipografía sans-serif legible. Sin sombras realistas,
degradados decorativos, texturas, efectos 3D, fondos fotográficos, marcas de agua,
logotipos ni texto ornamental.

Restricciones: todo el texto debe estar en español y ser breve. Los miles se separan
con punto (10.000 m) y los decimales con coma (−56,5 °C). No inventes cifras,
escalas, símbolos aeronáuticos, procedimientos, logotipos ni detalles técnicos. No
incluyas texto de placeholder, palabras como MOCKUP o ToDo, ni referencias a archivos.
Deja espacio suficiente para que las etiquetas se lean a 9 pt al imprimirse.
```

## Edición inglesa

«Warm air», «Cold air», «Warm front», «Direction of movement», «Cirrus (Ci), about 10,000 m: hours or days ahead», «Cirrostratus (Cs), about 6,000 m», «Altostratus (As), about 3,000 m», «Nimbostratus (Ns): continuous rain», «Stratus and frontal fog», «Air usually stable; if unstable, embedded Cb».
