# Guía de ilustraciones

Esta guía es la referencia para crear, sustituir, adaptar e insertar ilustraciones
en los nueve manuales SPL. Se aplica a los entregables PDF, EPUB, web y Markdown
para RAG.

Su objetivo es que las figuras enseñen con precisión y parezcan parte de una misma
colección, sin homogeneizar a la fuerza fotografías, cartas o documentos oficiales.
Se aplica a figuras nuevas y a sustituciones; las ilustraciones existentes se
normalizan gradualmente cuando se revisen.

## Principios

- Una figura debe enseñar una relación, un procedimiento o un fenómeno que el texto
  solo explicaría peor. No se usa como decoración.
- La fidelidad técnica prevalece sobre el estilo. Si una simplificación puede cambiar
  una trayectoria, una escala, una condición de seguridad o un dato, no se admite.
- El texto visible va en español técnico. Las unidades respetan la convención del
  capítulo y las cifras normativas se copian de su fuente, sin reconvertirlas.
- El color nunca es la única señal: las fuerzas, trayectorias, límites y estados se
  distinguen además mediante etiqueta, forma, patrón o tipo de línea.
- Una fotografía o captura se conserva reconocible como tal; no se reestiliza hasta
  poder confundirse con una situación, carta o documento operativo real.

## Identidad gráfica

Los diagramas conceptuales usan fondo blanco `#FFFFFF`, líneas limpias y un acabado
plano. No llevan sombras realistas, degradados decorativos, texturas ni fondos
fotográficos. La estructura, los ejes y las líneas guía usan azul navy `#003366`; el
texto usa gris oscuro `#333333`.

La paleta técnica no depende del color temático de una portada ni de un capítulo:

| Elemento | Color |
| --- | --- |
| Sustentación | Azul `#0066CC` |
| Resistencia | Rojo `#CC0000` |
| Peso | Gris oscuro `#333333` |
| Tracción | Naranja `#FF6600` |
| Zona segura o rango permitido | Verde `#2E7D32` |
| Estado o trayectoria de atención, sin significado físico | Naranja `#E65C00` |

Las convenciones siguientes son fijas:

- La trayectoria por el aire es continua.
- La proyección o trayectoria sobre el suelo es discontinua.
- El viento se representa con flecha hueca o azul y se etiqueta si interviene en la
  explicación.
- Las flechas muestran una punta clara y no se cruzan con el elemento que describen.
- Un diagrama de maniobra incluye una indicación pequeña de palanca y pedales cuando
  la posición de mandos sea relevante para entenderla.

Para rotulación de diagramas se usa Libertinus Sans, que está vendorizada en
`recursos/fuentes/`. El texto debe medir al menos 9 pt al tamaño final en PDF. No se
crea texto convertido a píxeles si puede conservarse como texto vectorial.

## Tipos de figura

### Diagramas conceptuales

Explican geometría, flujos, procedimientos, instrumentos o relaciones cualitativas.
Su máster preferido es SVG editable; se exporta PNG solo si SVG no es viable para el
destino. Usan la identidad gráfica anterior y etiquetas breves.

### Gráficos cuantitativos

Incluyen polares, tangentes, diagramas V-n, masa y centrado, sondeos, tefigramas,
emagramas, escalas, curvas y vectores cuya magnitud relativa importe. Se construyen
desde datos o geometría verificables con una herramienta vectorial, una hoja de
cálculo o código reproducible. No se generan ni se retocan con IA.

Los ejes indican magnitud y unidad, las escalas no se alteran y las curvas conservan
los valores que las originan. Una traducción de rótulos no autoriza a cambiar unidades
ni a redibujar una curva a otra escala.

### Fotografías

Se usan para mostrar un fenómeno real, una aeronave, un elemento o un entorno. Se
guardan como JPEG sRGB, sin reescalarlas hacia arriba. Se permiten correcciones de
recorte, exposición y color que no alteren lo que la imagen demuestra; cualquier
manipulación sustantiva se declara en el crédito.

### Cartas, documentos y capturas

Las cartas aeronáuticas, documentos oficiales y capturas con texto fino se conservan
como PNG. No se recolorean, simplifican ni recortan de modo que se alteren símbolos,
orientación, escala, leyenda o contexto relevante. El pie identifica el organismo,
la edición o fecha cuando sea conocida y aclara si es un ejemplo, una recreación o un
documento operativo real.

Las capturas registran en su ficha de procedencia la aplicación, versión y fecha. Se
eliminan datos personales, credenciales y posiciones sensibles antes de publicarlas.

### Material histórico o de terceros

Una figura FAA, NASA, ENAIRE, DAeC u otra fuente externa puede mantenerse cuando
aporta valor didáctico y su licencia permite reutilizarla. No se presupone que una
fuente pública permita cualquier uso: se comprueban sus condiciones antes de publicar.
La atribución específica va en el pie si es necesaria; la fuente completa queda en la
bibliografía o en la ficha de procedencia.

## Formatos, tamaño y calidad

| Tipo | Formato de entrega preferido | Alternativa |
| --- | --- | --- |
| Diagrama o gráfico vectorial | SVG | PNG de 8 bits |
| Carta, documento o captura con texto | PNG de 8 bits | SVG si es nativo |
| Fotografía | JPEG sRGB | PNG solo si necesita transparencia |

- Los nombres nuevos usan `XX-capYY-descripcion.ext`, en minúsculas ASCII y
  kebab-case; por ejemplo, `05-cap04-guinada-adversa.svg`.
- No se añaden nuevos archivos `.jpeg`; se usa `.jpg`.
- Un SVG debe contener vectores reales, no encapsular un PNG o JPEG salvo que sea un
  caso excepcional justificado.
- Se eliminan EXIF y otros metadatos personales de los raster publicados.
- El perfil de color de todo raster es sRGB.
- Los PNG de diagramas se exportan a 8 bits; no se usan PNG de 16 bits sin una razón
  técnica verificable.

La resolución se decide por el tamaño impreso, no por el DPI escrito en el archivo:

```text
ancho mínimo en píxeles = ancho final en mm / 25,4 x 220
```

Como referencia, a 15 cm de ancho se necesitan aproximadamente 1.300 px. Los
diagramas rasterizados y las cartas con texto fino deben superar ese mínimo; una foto
puede llegar a 150 ppp efectivos si su detalle lo permite. No se interpola una imagen
pequeña para aparentar más resolución.

El peso normal de un SVG no supera 500 KB y el de una imagen raster no supera 2 MB.
Una carta o documento muy detallado puede excederlo si la legibilidad lo requiere.

## Inserción en Quarto

Cada figura de contenido vive en `imagenes/` del libro y se inserta con un pie
informativo, un identificador estable y un texto alternativo independiente:

```markdown
![La guiñada adversa: el aumento de resistencia del ala exterior desvía inicialmente el morro en sentido contrario al viraje](imagenes/05-cap04-guinada-adversa.svg){#fig-05-cap04-guinada-adversa fig-alt="Vista cenital de un planeador. Una flecha roja muestra la resistencia inducida hacia el lado contrario al giro deseado y una trayectoria verde discontinua muestra el giro deseado." width="90%" fig-align="center"}
```

- El pie explica qué aprende la persona lectora. No empieza por «Figura N» porque
  Quarto aporta la numeración.
- `fig-alt` describe la información visual que no debe perder un lector de pantalla.
  No duplica el pie ni contiene créditos, prompts o una receta de generación.
- El ID es `fig-` seguido del nombre del archivo sin extensión. Debe ser único,
  minúsculo, ASCII y en kebab-case.
- Las referencias internas usan exclusivamente `@fig-...`.
- Se usa `width` relativo (`70%`, `90%` o `100%`) y `fig-align="center"`, salvo que
  la composición justifique otra decisión.
- No se renombra un ID ya publicado sin revisar sus referencias internas y externas.

La compatibilidad de `fig-alt` se comprueba al incorporar la primera figura que lo
use en PDF, EPUB y paquete web. Hasta entonces no se reescriben las 143 figuras
actuales solo para añadirlo.

## Prompts, fuentes editables y estados

Los prompts no se ponen en comentarios HTML dentro de los `.qmd`: el EPUB elimina
comentarios, pero el paquete web puede conservarlos. Si una figura generada o
regenerable necesita trazabilidad, se crea junto a ella un archivo no publicado con
el mismo nombre y sufijo `.prompt.md`, por ejemplo:

```text
05-principios-vuelo/imagenes/05-cap04-guinada-adversa.prompt.md
```

La ficha incluye tipo de figura, estado (`borrador`, `revision-tecnica` o `final`),
fecha, herramienta y versión, prompt, fuentes técnicas, licencia de las fuentes,
restricciones y persona que hizo la revisión técnica. El máster editable se conserva
junto a la ficha o en una ruta indicada por ella.

El prompt de un diagrama generado pide siempre fondo blanco, estilo vectorial plano,
etiquetas en español y la paleta de esta guía. No se pide a IA texto largo, cálculos,
escalas ni documentos o logotipos oficiales.

### Prompt genérico para OpenAI

Esta plantilla sirve tanto para crear un diagrama nuevo como para sustituir un mockup
existente con un generador de imágenes de OpenAI, incluidos los modelos Terra o Sol
cuando estén disponibles. Se completa el bloque entre corchetes antes de enviarlo y
se guarda la versión final en la ficha `.prompt.md` de la figura.

```text
Genera una ilustración didáctica para un manual teórico de piloto de planeador SPL.

Tipo de figura: [diagrama conceptual / maniobra / vista en planta / perfil /
diagrama de flujo / otro].
Objetivo didáctico: [qué debe comprender la persona lectora].
Composición: [elementos, posiciones, orden de lectura y relaciones espaciales].
Etiquetas visibles exactas: [lista breve de textos en español].
Datos técnicos verificados: [valores, fuentes y unidades; omitir si no aplica].

Estilo: ilustración técnica vectorial plana sobre fondo blanco puro #FFFFFF. Líneas
limpias y uniformes; estructura, ejes y líneas guía en azul navy #003366; etiquetas
en gris oscuro #333333, con tipografía sans-serif legible. Sin sombras realistas,
degradados decorativos, texturas, efectos 3D, fondos fotográficos, marcas de agua,
logotipos ni texto ornamental.

Código de color obligatorio para fuerzas: sustentación azul #0066CC, resistencia roja
#CC0000, peso gris oscuro #333333 y tracción naranja #FF6600. Las zonas seguras usan
verde #2E7D32. No dependas solo del color: añade etiquetas, tipos de línea o formas
distintivas. La trayectoria por el aire es continua; la proyección sobre el suelo,
discontinua; el viento usa flecha hueca o azul.

Restricciones: todo el texto debe estar en español y ser breve. No inventes cifras,
escalas, símbolos aeronáuticos, procedimientos, logotipos ni detalles técnicos. No
incluyas texto de placeholder, palabras como MOCKUP o ToDo, ni referencias a archivos.
Entrega una composición apaisada [o proporción requerida], con espacio suficiente para
que las etiquetas se lean a 9 pt al imprimirse.
```

Cuando se modifique una imagen existente, se adjunta la imagen y se antepone este
bloque al prompt anterior:

```text
Conserva exactamente la composición, encuadre, geometría, sentido de las flechas,
relaciones espaciales, etiquetas, cifras y unidades de la imagen de referencia. No
añadas, elimines, traduzcas ni reinterpretes contenido. Cambia únicamente el acabado
visual para cumplir el estilo indicado. Si algún texto, dato o detalle técnico no se
lee con certeza, déjalo señalado para revisión humana en vez de inventarlo.
```

Esta variante no se usa para gráficos cuantitativos: polares, V-n, masa y centrado,
sondeos, ejes a escala y curvas verificables se reconstruyen en vector desde sus datos.

Una figura provisional debe llevar un estado visible fuera del entregable final. No
se publica un archivo que contenga `MOCKUP`, `FIGURA PENDIENTE`, `ToDo` ni referencias
al antiguo formato `.adoc`. Sustituirlo es una tarea editorial independiente; esta
guía no convierte automáticamente una figura existente en provisional.

## Procedencia, licencia y atribución

Antes de incorporar una figura se registra su origen y licencia. Para material propio
se identifica autoría y fecha; para una adaptación se identifica también la obra base
convierte automáticamente una fuente externa en reutilizable bajo esa licencia.

No se usan logotipos de AESA, EASA, ENAIRE ni de otros organismos como decoración o
para insinuar una aprobación. Una carta o documento oficial se reproduce solo cuando
su licencia o condiciones de uso lo permitan y su atribución sea completa.

## Revisión antes de publicar

Para cada figura nueva o sustituida, comprobar:

- [ ] La figura aporta una explicación que el texto necesita y ha pasado revisión
  técnica cuando contiene procedimientos, geometría, datos o escalas.
- [ ] El formato, perfil sRGB, resolución y peso son adecuados.
- [ ] Las etiquetas son legibles, están en español y el significado no depende solo
  del color.
- [ ] El pie, `fig-alt`, nombre e ID cumplen la sección de Quarto.
- [ ] La fuente, licencia, atribución y cualquier modificación están registradas.
- [ ] PDF: texto, líneas finas, numeración e índice de ilustraciones son legibles al
  100 % y en escala de grises.
- [ ] EPUB y web: la figura no desborda en pantalla estrecha, se ve sobre fondos claro
  y oscuro y conserva un `alt` útil.
- [ ] RAG: el pie aislado sigue explicando qué contenía la figura.
- [ ] El entregable publicable no conserva placeholders ni trazas de prompts.

La automatización de este control se incorporará en un cambio independiente. Mientras
no exista, quien cambie una ilustración compila y revisa al menos el libro afectado.
