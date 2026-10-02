---
schema: 1
figura: 02-cap02-curva-estres.png
tipo: grafico-cualitativo
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: "Yerkes, R. M. y Dodson, J. D. (1908). «The relation of strength of stimulus to rapidity of habit-formation». *Journal of Comparative Neurology and Psychology*, 18, 459-482"
    licencia: "cita y referencia"
restricciones:
  - sin logotipos, marcas ni reproducción de documentos oficiales
  - texto visible en español, breve
  - sin personas reconocibles
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

# 02-cap02-curva-estres

**Qué enseña.** La curva de U invertida entre el nivel de activación y el rendimiento: poca
activación da un piloto apático, demasiada uno bloqueado, y el máximo está en el punto medio.
Texto en `cap02-fisiologia-aeronautica-basica-y-mantenimiento-de-salud.qmd`, «Estrés fisiológico y
sus efectos», que separa este marco del síndrome general de adaptación de Selye.

**Estado.** Marcada con `.corregir` en la fase 3 de la corrección (hallazgo TEC-09). Hay que
rehacerla.

## Qué falla en la figura actual

* La rama derecha rotula «Agotamiento y Pánico». El agotamiento es la tercera fase del síndrome de
  Selye, un efecto de la duración del estrés, no de su intensidad. La rama derecha es la
  sobreactivación: ansiedad, pánico.
* El eje horizontal se llama «Nivel de Estrés»; el pie y el texto hablan de nivel de activación.
* El degradado arcoíris es decorativo, y el color es la única señal de las zonas.

## Cómo rehacerla

Mejor por código, como las figuras de los libros 07 y 09 (`tools/figuras/`), aunque no lleve
cifras: la curva es cualitativa, sin escala, y lo que importa es que los tres rótulos caigan en su
sitio. Si se usa un generador, este es el encargo:

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: gráfico cualitativo (curva de U invertida, sin escalas numéricas).
Objetivo didáctico: que hay un nivel óptimo de activación y que pasarse de él degrada el rendimiento tanto como quedarse corto.
Composición: ejes con flecha, sin cuadrícula ni números. Curva de U invertida simétrica en azul navy. Tres zonas sombreadas en tonos planos y separadas por líneas verticales discontinuas: izquierda, cima (verde #2E7D32) y derecha (ámbar #B26A00). Cada zona con su rótulo.
Etiquetas visibles exactas: eje X «Nivel de activación», eje Y «Rendimiento», izquierda «Infraactivación (apatía, distracción)», cima «Activación óptima (alerta)», derecha «Sobreactivación (ansiedad, pánico)». Título: «Curva de Yerkes-Dodson».
Datos técnicos verificados: no aplica.

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF. Líneas
limpias y uniformes; estructura, ejes y líneas guía en azul navy #003366; etiquetas
en gris oscuro #333333, con tipografía sans-serif legible. Sin sombras realistas,
degradados decorativos, texturas, efectos 3D, fondos fotográficos, marcas de agua,
logotipos ni texto ornamental. Las zonas seguras usan verde #2E7D32 y un estado de
atención usa ámbar #B26A00. Todo el texto va en gris #333333. No dependas solo del
color: añade etiquetas, tipos de línea o formas distintivas.

Restricciones: todo el texto debe estar en español y ser breve. No inventes cifras,
escalas, símbolos aeronáuticos, procedimientos, logotipos ni detalles técnicos. No
incluyas texto de placeholder, palabras como MOCKUP o ToDo, ni referencias a archivos.
Entrega una composición apaisada, con espacio suficiente para que las etiquetas se
lean a 9 pt al imprimirse.
```

## Edición inglesa

`en/02-human-performance/imagenes/` lleva una copia idéntica de esta imagen. Al rehacerla, se
genera también la versión con las etiquetas en inglés (términos de `en/terminologia.yml`), se
sustituye allí y se quita la marca *(FIX: …)* del pie inglés.
