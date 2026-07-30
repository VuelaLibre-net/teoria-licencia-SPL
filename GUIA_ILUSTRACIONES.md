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
| Estado o trayectoria de atención, sin significado físico | Ámbar `#B26A00` |

El ámbar de atención y el naranja de tracción **no aparecen en la misma figura**: son
tonos vecinos y en escala de grises convergen. Si una figura necesita las dos ideas, la
de atención se distingue además por trazo discontinuo y etiqueta.

El naranja `#FF6600` tiene un contraste de aproximadamente 2,9:1 sobre blanco: sirve
para una línea o una flecha gruesa, **no para texto de etiqueta**, que va en gris
`#333333`.

Las convenciones siguientes son fijas:

- La trayectoria por el aire es continua.
- La proyección o trayectoria sobre el suelo es discontinua.
- El viento se representa con flecha hueca o azul y se etiqueta si interviene en la
  explicación.
- Las flechas muestran una punta clara y no se cruzan con el elemento que describen.
- Un diagrama de maniobra incluye una indicación pequeña de palanca y pedales cuando
  la posición de mandos sea relevante para entenderla.

Para rotulación de diagramas se usa Libertinus Sans, que está vendorizada en
`recursos/fuentes/`. El texto debe medir al menos 9 pt **al tamaño final en PDF, es
decir, después de aplicar el `width` de inserción**: un diagrama insertado al 90 %
encoge su tipografía en la misma proporción, así que 9 pt en el máster no son 9 pt en
la página. No se crea texto convertido a píxeles si puede conservarse como texto
vectorial.

⚠️ Ninguna otra fuente está garantizada. Typst no falla ante una fuente ausente: cae a
otra en silencio (ver `CLAUDE.md`). Una fuente nueva se vendoriza en `recursos/fuentes/`
o no se usa.

## Tipos de figura

### Diagramas conceptuales

Explican geometría, flujos, procedimientos, instrumentos o relaciones cualitativas.
Su máster preferido es SVG editable; se exporta PNG solo si SVG no es viable para el
destino. Usan la identidad gráfica anterior y etiquetas breves.

⚠️ **El SVG aún no se ha usado en la colección: las 143 figuras actuales son PNG o
JPEG.** La primera figura SVG es un piloto y se revisa en los cuatro entregables antes
de generalizar el formato, porque hay dos incógnitas conocidas:

- Typst rasteriza el SVG con **resvg**, que no admite `@font-face`, tiene soporte
  limitado de `<style>` y CSS y no aplica filtros. El texto se compone con las fuentes
  del sistema; si la familia no está, cae a otra sin avisar. Libertinus Sans sí está
  (la instala el CI), cualquier otra no.
- `tools/epub/optimizar_imagenes.py` y `tools/web/imagenes.py` filtran por
  `{".jpg", ".jpeg", ".png"}`: un SVG pasa sin `srcset`, sin AVIF/WebP y sin el `alt`
  que sintetiza el pipeline web. Hay que comprobar que se ve bien igualmente.

Si el piloto falla en algún entregable, el diagrama se entrega como PNG y el SVG se
conserva como máster editable junto a la ficha.

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
- No se añaden nuevos archivos `.jpeg`; se usa `.jpg`. Queda uno heredado,
  `01-derecho-aereo-atc/imagenes/01-cap05-preferencias-paso-ladera.jpeg`, que se
  renombra cuando se toque esa figura.
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

⚠️ **Ese mínimo sirve al PDF, no a los otros entregables.** El pipeline recorta el
ancho: `tools/epub/optimizar_imagenes.py` reescala a `MAX_WIDTH = 1200` y convierte a
WebP con `quality=82`, y `tools/web/imagenes.py` genera variantes de 480, 768 y
1200 px en AVIF y WebP. Todo lo que exceda 1200 px es resolución para imprimir. El
máster se guarda a resolución de impresión y no se reduce para «aligerar la web»: de
eso se ocupan los dos scripts.

El peso normal de un SVG no supera 500 KB y el de una imagen raster no supera 2 MB.
Una carta o documento muy detallado puede excederlo si la legibilidad lo requiere.
Hoy lo superan cinco figuras heredadas —`01-cap07-zonas-prd.png`,
`07-cap05-cono-alcance.png`, `09-cap03-carta-enaire-ama.png`,
`05-cap07-espiral-vs-barrena.png` y `03-cap04-familias-nubes-perfil.png`, entre 2,4 y
3,5 MB—, que se normalizan cuando se revisen.

## Inserción en Quarto

Cada figura de contenido vive en `imagenes/` del libro y se inserta con un pie
informativo, un identificador estable y un texto alternativo independiente:

```markdown
![La guiñada adversa: el aumento de resistencia del ala exterior desvía inicialmente el morro en sentido contrario al viraje](imagenes/05-cap04-guinada-adversa.svg){#fig-05-cap04-guinada-adversa fig-alt="Vista cenital de un planeador. Una flecha roja muestra la resistencia inducida hacia el lado contrario al giro deseado y una trayectoria discontinua muestra el giro deseado."}
```

- El pie explica qué aprende la persona lectora. No empieza por «Figura N» porque
  Quarto aporta la numeración.
- `fig-alt` describe la información visual que no debe perder un lector de pantalla.
  No duplica el pie ni contiene créditos, prompts o una receta de generación.
- **En una figura nueva**, el ID es `fig-` seguido del nombre del archivo sin
  extensión. Debe ser único, minúsculo, ASCII y en kebab-case. Manda el ID: si hay que
  elegir, se renombra el archivo para que coincida, nunca al revés.
- Las referencias internas usan exclusivamente `@fig-...`.
- No se renombra un ID ya publicado sin revisar sus referencias internas y externas.

⚠️ La regla anterior **no es retroactiva**: 33 de las 143 figuras actuales tienen un ID
que no coincide con su archivo (`01-cap02-certificado-aeronavegabilidad.jpg` va con
`#fig-01-cap02-cofa-example`), y unos quince conservan el ID en inglés de la migración
desde AsciiDoc. Se corrigen al sustituir esas figuras, no antes: un ID publicado se
renombra con sus referencias, no por higiene. El caso raro es
`03-cap03-indices-estabilidad.jpg`, cuyo ID dice `cap10`; ése sí conviene revisarlo
porque induce a error al buscar la figura.

Las 143 figuras actuales se insertan **sin `width` ni `fig-align`** y se maquetan bien
con el valor por omisión. Una figura nueva no los añade salvo que su composición lo
pida; si los lleva, se usa `width` relativo (`70%`, `90%` o `100%`) y
`fig-align="center"`. Fijar uno solo por costumbre deja la colección con dos criterios
de maqueta.

La compatibilidad de `fig-alt` se comprueba al incorporar la primera figura que lo
use en PDF, EPUB y paquete web —ninguna de las 143 lo lleva todavía—. Hasta entonces
no se reescriben solo para añadirlo. Al comprobarlo, verificar que no choca con el
`alt` que `tools/web/imagenes.py` sintetiza por su cuenta.

## Prompts, fuentes editables y estados

Los prompts no se ponen en comentarios HTML dentro de los `.qmd`: el EPUB elimina
comentarios, pero el paquete web puede conservarlos. Si una figura generada o
regenerable necesita trazabilidad, se crea un archivo no publicado con el mismo nombre
que la figura y sufijo `.prompt.md`, en `prompts/` **fuera de `imagenes/`**:

```text
05-principios-vuelo/prompts/05-cap04-guinada-adversa.prompt.md
```

⚠️ La ficha va fuera de `imagenes/` porque **Quarto copia ese directorio entero al
paquete web** —se ve como `quarto/imagenes/` dentro del `.tar.gz`—, y una ficha allí se
publicaría junto a la figura. «No publicado» aquí no es una convención: es una ruta.
Al crear la primera ficha, comprobarlo sobre el entregable:

```bash
tar tzf build/web/05-principios-vuelo-*.web.tar.gz | grep -c '\.prompt\.md'   # 0
```

La ficha incluye tipo de figura, estado (`borrador`, `revision-tecnica` o `final`),
fecha, herramienta y versión, prompt, fuentes técnicas, licencia de las fuentes,
restricciones y persona que hizo la revisión técnica. El máster editable se conserva
junto a la ficha o en una ruta indicada por ella.

La ficha usa front matter YAML con `schema: 1` y el prompt como cuerpo Markdown:

```markdown
---
schema: 1
figura: 05-cap04-guinada-adversa.svg
tipo: diagrama-conceptual
estado: borrador
fecha: ""
herramienta:
  nombre: ""
  version: ""
fuentes:
  - referencia: ""
    licencia: ""
restricciones: []
revision:
  persona: ""
  fecha: ""
master_editable: ""
---

Prompt completo de la figura.
```

`figura` ata la ficha a su imagen aunque una de las dos se mueva o se renombre; el
nombre del archivo por sí solo no basta. `fecha` va vacía en la plantilla a propósito:
una fecha de ejemplo se copia tal cual y envejece sin que nadie lo note.

Los tres estados son `borrador`, `revision-tecnica` y `final`. Una figura ya publicada
que se regenera **vuelve a `borrador`** y necesita revisión técnica otra vez: el
estado describe la versión actual del archivo, no el historial de la figura.

`ilustra` puede crear y editar esta ficha. No sustituye una ficha YAML inválida:
se corrige primero en el repositorio para no perder trazabilidad. Nada valida hoy el
`schema: 1`; si se automatiza la comprobación, va con el resto de guardianes del CI.

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
verde #2E7D32 y un estado o trayectoria de atención sin significado físico usa ámbar
#B26A00, que no aparece en la misma figura que el naranja de tracción. Todo el texto
va en gris #333333: el naranja no tiene contraste suficiente para una etiqueta. No
dependas solo del color: añade etiquetas, tipos de línea o formas distintivas. La
trayectoria por el aire es continua; la proyección sobre el suelo, discontinua; el
viento usa flecha hueca o azul.

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
y su licencia, y qué se ha modificado. Que una fuente sea pública, gratuita o de un
organismo oficial no la convierte en reutilizable: la licencia de esta colección no se
propaga hacia atrás ni autoriza por sí sola a republicar material ajeno.

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
- [ ] La fuente, licencia, atribución y cualquier modificación están registradas, y la
  ficha `.prompt.md` está en `prompts/`, no en `imagenes/`.
- [ ] PDF: texto, líneas finas, numeración e índice de ilustraciones son legibles al
  100 % y en escala de grises.
- [ ] EPUB y web: la figura no desborda en pantalla estrecha, se ve sobre fondos claro
  y oscuro y conserva un `alt` útil.
- [ ] RAG: el pie aislado sigue explicando qué contenía la figura.
- [ ] El entregable publicable no conserva placeholders ni trazas de prompts.

La automatización de este control se incorporará en un cambio independiente. Mientras
no exista, quien cambie una ilustración compila y revisa al menos el libro afectado:
`make <libro>` produce sus cuatro entregables. No basta con que salga con 0 — toda esta
cadena falla en silencio (ver `CLAUDE.md`), así que hay que mirar los archivos.
