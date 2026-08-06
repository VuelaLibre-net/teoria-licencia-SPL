# Colección de Manuales Teóricos SPL (Licencia de Piloto de Planeador) en Quarto

[![Compilar Manuales SPL](https://github.com/VuelaLibre-net/teoria-licencia-SPL/actions/workflows/ci.yml/badge.svg)](https://github.com/VuelaLibre-net/teoria-licencia-SPL/actions/workflows/ci.yml)
[![Licencia: CC BY-SA 4.0](https://img.shields.io/badge/Licencia-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/deed.es)
[![Validado por AESA](https://img.shields.io/badge/Temarios-validados%20por%20AESA-0057B7.svg)](https://www.seguridadaerea.gob.es/)
[![Syllabus AMC1 SFCL.130](https://img.shields.io/badge/Syllabus-AMC1%20SFCL.130%20(EASA--FCL)-003399.svg)](https://www.easa.europa.eu/)
[![Quarto](https://img.shields.io/badge/Quarto-%E2%89%A5%201.9.17-75AADB.svg)](https://quarto.org/)
[![Typst](https://img.shields.io/badge/Typst-0.15-239DAD.svg)](https://typst.app/)
[![Formatos](https://img.shields.io/badge/Formatos-PDF%20%C2%B7%20EPUB%20%C2%B7%20HTML%20%C2%B7%20MD%20para%20IA-E44D26.svg)](#instrucciones-de-compilación)

`vuelo-a-vela` · `planeador` · `spl` · `easa-fcl` · `aesa` · `licencia-de-piloto` · `manual-de-formación` ·
`temario-teórico` · `quarto` · `typst` · `epub` · `markdown-para-ia` · `rag` · `español`

Este repositorio contiene la versión digitalizada de 9 libros que cubren el temario teórico para la obtención de la **Licencia de Piloto de Planeador (SPL)** bajo la regulación **EASA-FCL (European Union Aviation Safety Agency - Flight Crew Licensing)**, adaptada a los requerimientos de la **Agencia Estatal de Seguridad Aérea (AESA)** española.

El contenido está en **Quarto Markdown (.qmd)** para la generación de entregables de alta calidad en formatos cómodos de editar por los colaboradores: **PDF** (mediante Typst), **EPUB**, **Markdown para RAG**, un paquete **HTML** que se publica integrado en [VuelaLibre.net](https://vuelalibre.net) y un **mazo Anki** por asignatura.

---

## Estructura de la Colección

La biblioteca está organizada por asignaturas según el syllabus oficial de AESA/EASA:

| # | Libro | Asignatura | Versión | Estado |
| --- | --- | --- | --- | --- |
| 1 | **`01-derecho-aereo-atc`** | Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (ATC) | `1.0-rc.13` | 🟡 En revisión |
| 2 | **`02-factores-humanos`** | Factores Humanos | `1.0-rc.12` | 🟡 En revisión |
| 3 | **`03-meteorologia`** | Meteorología | `1.0-rc.14` | 🟡 En revisión |
| 4 | **`04-comunicaciones`** | Comunicaciones | `1.0-rc.14` | 🟡 En revisión |
| 5 | **`05-principios-vuelo`** | Principios de Vuelo | `1.0-rc.7` | 🟡 En revisión |
| 6 | **`06-procedimientos-operativos`** | Procedimientos Operativos | `1.0-rc.1` | 🟡 En revisión |
| 7 | **`07-planificacion-rendimiento`** | Planificación y Rendimiento de Vuelo | `1.0-rc.2` | 🟡 En revisión |
| 8 | **`08-aeronave-sistemas`** | Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia | `0.9.1` | 🟡 En revisión |
| 9 | **`09-navegacion`** | Navegación | `0.9.3` | 🟡 En revisión |

### De qué va cada libro

**1 · Derecho Aéreo y ATC** — El marco legal de cada vuelo, del Convenio de Chicago a las tres normas
que un piloto de planeador debe tener en la cabeza. Sin jerga de opositor, con las consecuencias
operativas de cada regla.

**2 · Factores Humanos** — Cómo funciona de verdad el piloto: qué le lleva a decidir mal bajo presión,
cómo la fatiga y el estrés le degradan el rendimiento sin que lo note, y qué herramientas mentales
marcan la diferencia.

**3 · Meteorología** — Leer la atmósfera como la lee un instructor con miles de horas: no para
aprobar, sino para volver a casa. De la física del aire que te sostiene a los índices de sondeo que
anticipan si el día será épico o peligroso.

**4 · Comunicaciones** — Usar la radio como quien ha escuchado miles de horas de tráfico: con
precisión, con brevedad y con la fraseología que el sistema espera en cada fase del vuelo.

**5 · Principios de Vuelo** — La aerodinámica que sostiene cada planeo, el equilibrio de fuerzas que
mantiene estable al planeador y los fenómenos —pérdida, barrena, picado en espiral— que hay que
entender para reconocerlos, anticiparlos y salir de ellos.

**6 · Procedimientos Operativos** — Cada procedimiento del vuelo sin motor, del primer chequeo
prevuelo al paracaídas de emergencia que nadie quiere usar y todos deben saber desplegar.

**7 · Planificación y Rendimiento** — Leer la polar de tu planeador, ajustar la velocidad de crucero a
la térmica del día, calcular el centrado antes de despegar y rellenar un plan de vuelo OACI sin que
parezca un formulario en otro idioma.

**8 · Aeronave, Sistemas y Equipo de Emergencia** — La máquina con el nivel de detalle que necesita un
piloto, no un ingeniero: lo justo para saber cuándo el planeador está en condiciones de volar y
cuándo no.

**9 · Navegación** — Leer una carta aeronáutica, calcular el rumbo con viento, navegar por estima y
usar el GNSS sin convertirlo en una muleta que falla en el peor momento.

Estas sinopsis resumen el texto de presentación de cada libro, que vive completo —con descripción
larga, contraportada y taglines— en `recursos/media-kit/<libro>.md`.

### Estados editoriales

El estado **no se declara**: se deduce de la versión del libro, que se mantiene a mano en el
`version:` de su `_quarto.yml`. El Makefile aplica esta tabla al compilar y la inyecta en los dos
formatos, de modo que la portadilla del PDF (con marca de agua) y la primera página del EPUB avisan
solos de que un libro aún no está terminado:

| Versión | Estado | Qué significa |
| --- | --- | --- |
| `>= 1.0.0` | ✅ Completado | Edición definitiva. Único estado **sin** marca de agua ni nota. |
| `1.x-rc.n` · `0.9.x` | 🟡 En revisión | Pendiente de revisión técnica por instructores. |
| `0.8.x` | 🎨 Creando ilustraciones | Texto completo; faltan ilustraciones. |
| `<= 0.7.x` | 🚧 En desarrollo | Texto e ilustraciones en elaboración. |

Un candidato de versión (`1.0-rc.5`) es **anterior** a la `1.0.0`, no posterior: por eso los cuatro
primeros libros siguen en revisión.

La tabla de arriba es una copia de un dato que vive en los `_quarto.yml`, así que el CI comprueba en
cada _push_ que no se ha desfasado. Para consultarla —o para saber qué espera el guardián después de
cambiar una versión— basta con:

```bash
make estados      # imprime "libro|versión|estado" de los 9 libros
```

### Qué ha cambiado en cada libro

Cada libro lleva su propio registro de cambios en **`<libro>/CHANGELOG-NN.md`**, pensado para que un
revisor **no tenga que releer el libro entero**: cada entrada abre con una línea **«Qué releer»** que
dice qué capítulos ha tocado esa versión y cuáles puede saltarse.

Si cambias contenido, añade la línea bajo la versión en curso. El CI comprueba que la versión que
declara `_quarto.yml` tenga su entrada, de modo que **subir la versión sin registrar qué cambió
rompe la compilación**.

---

Los archivos `.qmd` de este repositorio son la **fuente canónica** de la colección: se editan
directamente y no se generan a partir de ningún otro formato. Las figuras nuevas y las sustituciones
siguen la [Guía de ilustraciones](GUIA_ILUSTRACIONES.md), que define su estilo técnico,
accesibilidad, formatos, procedencia e inserción en Quarto.

---

## Requisitos Previos

Para poder compilar la colección completa, necesitarás contar con:

- **Quarto CLI 1.9.17 o superior**: [Instrucciones de instalación](https://quarto.org/docs/get-started/).
  La extensión de maquetado (`_extensions/orange-book-es/`) no funciona con versiones anteriores.
- **Typst 0.15** (opcional): Quarto lleva empotrada su propia versión de Typst (0.14.2), suficiente
  para compilar. Los entregables oficiales se generan con Typst 0.15, que produce una paginación
  ligeramente distinta; para reproducirlos con exactitud, apunta Quarto a tu binario:
  ```bash
  export QUARTO_TYPST="$(which typst)"
  ```

---

## Instrucciones de Compilación

El proyecto incluye un _Makefile_ para automatizar la compilación de los libros:

### Compilar la colección completa
Genera los entregables en formatos PDF, EPUB, Markdown para RAG, paquetes HTML y mazos Anki para todos los libros:
```bash
make
```
Los archivos finales se guardarán en:
- `build/pdf/` - PDFs de alta calidad listos para impresión o consulta digital (Typst).
- `build/epub/` - Libros electrónicos adaptados para e-readers (Pandoc). Las imágenes raster se convierten dentro del EPUB a WebP (EPUB 3.3), sin pérdida para PNG y a calidad 82 para JPEG, con un ancho máximo de 1200 px; el PDF sigue usando los originales.
- `build/rag/` - Markdown para cargar el libro en un asistente de estudio (NotebookLM y
  similares), un fichero por asignatura. Ver [Markdown para RAG](#markdown-para-rag).
- `build/web/` - Paquetes `.web.tar.gz` para el lector HTML de VuelaLibre.net. Cada uno contiene el HTML semántico resuelto por Quarto, sus imágenes y un manifiesto de páginas.
- `build/anki/` - Mazos `.apkg` de repaso espaciado, un fichero por asignatura. Ver [Mazos Anki](#mazos-anki).

El CI comprueba XML, recursos WebP, dimensiones y manifiesto de cada EPUB con EPUBCheck 5.3 antes de publicar.

Cada entregable lleva en el nombre **el libro, su versión y su fecha** (`yymmdd`), de modo que un
fichero descargado se identifica sin abrirlo y dos versiones del mismo libro no se pisan:

```
build/pdf/09-navegacion-0.8.1-260716.pdf
build/epub/09-navegacion-0.8.1-260716.epub
build/rag/09-navegacion-0.8.1-260716.md
build/web/09-navegacion-0.8.1-260716.web.tar.gz
build/anki/09-navegacion-0.8.1-260716.apkg
```

La fecha es la del último commit que tocó el libro —la misma que figura en su colofón—, no la de
compilación: así el nombre sólo cambia cuando cambia el libro.

### Compilar un libro individual
Puedes compilar una única asignatura especificando su nombre de directorio. Por ejemplo:
```bash
make 05-principios-vuelo
```

### Markdown para RAG

Cada libro se publica también como un **único fichero Markdown** pensado para cargarlo como fuente
en un asistente de estudio con recuperación (NotebookLM, o cualquier RAG). Los nueve caben de sobra
en un mismo cuaderno:

```bash
make rag          # sólo los 9 Markdown, sin recompilar PDF ni EPUB (segundos)
```

No es el libro en crudo: un RAG no ve la maqueta, sino trozos sueltos de texto, y se prepara para
que cada trozo se explique solo.

- **Los recuadros conservan su etiqueta como texto** (`> **Seguridad**`, `> **Normativa**`…), en vez
  de perderla dentro de una clase CSS.
- **El resumen de cada capítulo es un apartado propio**, para que el buscador lo recupere entero.
- **Las referencias cruzadas se resuelven**: donde el libro escribe `@fig-04-cap05-pistola-luces`, el
  Markdown dice «figura 5.1».
- **Las ilustraciones no viajan** —un RAG no las mira—, pero sí sus pies, que sí dicen algo.
- **Se quedan fuera los preliminares y el colofón**: portadilla, créditos, dedicatoria, epígrafe y
  contracubierta no son materia. Tampoco la guía de lectura, que explica la maqueta y es idéntica en
  los nueve libros: nueve copias del mismo texto sólo estorban al buscar.

Lo que sí entra íntegro es el temario: capítulos, apéndices, glosario y bibliografía.

### Paquetes HTML para VuelaLibre.net

El lector web no interpreta los `.qmd` directamente: Quarto resuelve primero títulos, figuras, referencias cruzadas, tablas, fórmulas, notas y recuadros. Después `tools/web/construir.py` empaqueta esa salida junto con un `manifest.json` que enumera las páginas publicables.

```bash
make web          # sólo los 9 paquetes HTML, sin recompilar PDF, EPUB ni RAG
```

Cada paquete publica la licencia, dedicatoria, reconocimientos, introducción, capítulos, apéndices, glosario y bibliografía. Se excluyen portada, epígrafe, guía de lectura repetida, colofón y contracubierta. Las imágenes raster llevan AVIF y WebP a 480, 768 y 1200 px (sin ampliar el original), con JPEG/PNG como fallback, `srcset`, `sizes` y dimensiones intrínsecas. El CI valida los nueve paquetes y sus **141 páginas** antes de entregarlos al sitio.

En VuelaLibre.net, el lector se sirve bajo rutas estables como:

```text
https://vuelalibre.net/libros/navegacion/leer/
https://vuelalibre.net/libros/navegacion/leer/navegacion-por-estima/
```

### Mazos Anki

Cada asignatura se publica también como un **mazo de repaso espaciado** para
[Anki](https://apps.ankiweb.net/), con **598 tarjetas** en total. El árbol es
`SPL::NN Asignatura::NN Capítulo`: puedes estudiar una asignatura entera, un solo capítulo, o los
nueve libros de una vez.

```bash
make anki         # sólo los 9 mazos .apkg, sin recompilar nada más (segundos)
```

Se importan con doble clic sobre el `.apkg`. **Reimportar una versión nueva actualiza tus tarjetas
sin borrar tu historial de repaso**: los identificadores son estables entre compilaciones, así que
Anki reconoce cada tarjeta y sólo cambia lo que ha cambiado.

Las tarjetas **no se generan automáticamente del texto**: están escritas a mano, una a una, en
`tools/anki/mazos/`. Una tarjeta útil prueba un solo hecho y su anverso es una pregunta con una
respuesta; trocear así el resumen de un capítulo exige criterio, y una tarjeta mal planteada
memorizada es peor que no tenerla.

Salen del **resumen (post-it) de cada capítulo** y de los **recuadros del temario** —Seguridad,
Normativa, Regla de oro y Airmanship—, que viajan como etiqueta (`spl::recuadro::seguridad`) para
poder filtrar por tipo. Cada tarjeta lleva además su asignatura y capítulo, y cita al pie el libro,
el capítulo y la versión de la que sale, para poder contrastarla con el manual.

Hay dos tipos de tarjeta: pregunta-respuesta y hueco (*cloze*), con hoja de estilo propia y modo
oscuro. Mientras un libro no sea definitivo, su mazo incluye una tarjeta de aviso con el estado
editorial.

### Limpiar la compilación
Elimina los entregables generados (`build/`, `_book/`) y las cachés de Quarto. **No toca los `.qmd`,
los `_quarto.yml` ni las `imagenes/`**, que son la fuente canónica:
```bash
make clean
```

---

## Publicar una release

Los entregables se publican en la [página de _releases_](https://github.com/VuelaLibre-net/teoria-licencia-SPL/releases)
del repositorio, de donde cualquiera puede descargarlos sin cuenta de GitHub. El proceso lo automatiza
`.github/workflows/release.yml`: **empujar un tag de versión lo dispara todo**.

```bash
# 1. Sube la versión de los libros que hayan cambiado y cierra sus CHANGELOG
#    (ver «Qué ha cambiado en cada libro», arriba). Fusiona esos cambios a main.

# 2. Ya en main, con todo fusionado, crea un tag anotado:
git switch main && git pull
git tag -a v0.9.2 -m "Descripción breve de la entrega"
git push github v0.9.2
```

El remoto de este repositorio se llama **`github`**, no `origin`: `git push origin …` falla con
`fatal: 'origin' does not appear to be a git repository`.

El tag **no recompila**: busca el run del CI que ya validó **ese mismo commit** —el de la fusión a
`main`— y publica sus entregables, con lo que la release sale en un par de minutos en vez de en
media hora. No hace falta esperar a que ese CI termine antes de etiquetar: si sigue en marcha, la
release lo espera.

Sólo compila cuando no hay nada que reutilizar: si ningún run del CI ha visto ese commit, o si sus
artefactos han caducado (la retención del repositorio son **2 días**, así que etiquetar más tarde
implica recompilar). Y si el CI ya evaluó ese commit **y no salió verde**, la release **aborta**: un
tag no publica un árbol que el CI ha rechazado.

Con los 48 entregables —10 PDF, 10 EPUB, 10 Markdown para RAG, 9 paquetes web y 9 mazos Anki: los
nueve libros más el manual completo, que no tiene ni web ni mazo— crea una **release en borrador**,
todavía no visible al público.

Para terminar, **a mano**:

1. Abre el borrador y rellena la sección **«Qué ha cambiado en esta versión»** —el resto de las notas
   (la tabla de libros, versiones y estados, y el aviso de marca de agua) ya viene generado de
   `make estados`—. La materia prima es la línea «Qué releer» de cada `CHANGELOG-NN.md`.
2. Pulsa **Publish release**.

Es borrador a propósito: compilar y verificar es mecánico y se automatiza, pero decidir que la entrega
sale al público —y redactar qué ha cambiado, que un guión no puede inventar— es cosa de una persona.

Sobre el **número del tag**: sale de la versión del libro menos maduro, porque la colección es tan
madura como su libro más atrasado. Si esa versión ya está etiquetada —hoy los libros 08 y 09 van por
la `0.9.1`, que es la última release—, se sube el último dígito. El prefijo `v` es obligatorio: lo
distingue de la versión literal de los libros, que va sin él y aparece en el nombre de sus ficheros
(`05-principios-vuelo-0.9.1-260802.pdf`).

Si el borrador sale mal, se borra sin dejar rastro —no es público— y se vuelve a empezar:

```bash
gh release delete v0.9.2 --yes
git push github --delete v0.9.2 && git tag -d v0.9.2
```

---

## Estructura Editorial de los Libros

Cada asignatura es un proyecto Quarto independiente, con su propio `_quarto.yml`:

- **Preliminares:** Colofón, Dedicatoria y Prefacio son archivos sin numerar (`{.unnumbered}`) y se
  imprimen **antes** del Índice (*TOC*); el Índice de ilustraciones se sitúa **detrás** de este.
- **Capítulos:** La numeración académica comienza en el primer tema (`cap01-`).
- **Apéndices:** El Glosario, la Bibliografía y el Syllabus Oficial EASA se declaran como apéndices
  en `_quarto.yml` y se numeran aparte (A, B, C…).

Esa ordenación no es de serie en Quarto: la aporta la extensión local
**`_extensions/orange-book-es/`**, un fork del paquete Typst `orange-book` con la maquetación
reordenada y los rótulos en español ("Capítulo", "Índice de ilustraciones"). Cada libro la enlaza
con un symlink `_extensions -> ../_extensions`, porque Quarto sólo busca extensiones dentro del
directorio del proyecto y no sube por el árbol.
