# Manuales teóricos SPL en Quarto

[![Compilar Manuales SPL](https://github.com/VuelaLibre-net/teoria-licencia-SPL/actions/workflows/ci.yml/badge.svg)](https://github.com/VuelaLibre-net/teoria-licencia-SPL/actions/workflows/ci.yml)
[![Licencia: CC BY-SA 4.0](https://img.shields.io/badge/Licencia-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/deed.es)
[![Validado por AESA](https://img.shields.io/badge/Temarios-validados%20por%20AESA-0057B7.svg)](https://www.seguridadaerea.gob.es/)
[![Syllabus AMC1 SFCL.130](https://img.shields.io/badge/Syllabus-AMC1%20SFCL.130%20(EASA--FCL)-003399.svg)](https://www.easa.europa.eu/)
[![Quarto](https://img.shields.io/badge/Quarto-%E2%89%A5%201.9.17-75AADB.svg)](https://quarto.org/)
[![Typst](https://img.shields.io/badge/Typst-0.15-239DAD.svg)](https://typst.app/)
[![Formatos](https://img.shields.io/badge/Formatos-PDF%20%C2%B7%20EPUB%20%C2%B7%20HTML%20%C2%B7%20MD%20para%20IA-E44D26.svg)](#compilación)

`vuelo-a-vela` · `planeador` · `spl` · `easa-fcl` · `aesa` · `licencia-de-piloto` · `manual-de-formación` ·
`temario-teórico` · `quarto` · `typst` · `epub` · `markdown-para-ia` · `rag` · `español`

![Tablet con la biblioteca SPL de VuelaLibre.net en un hangar de aeródromo](recursos/media-kit/tablet.png)

9 libros con el temario teórico de la **Licencia de Piloto de Planeador (SPL)** según la regulación EASA-FCL, adaptado a lo que pide AESA en España.

Están escritos en **Quarto Markdown (.qmd)** y se compilan a **PDF** (Typst), **EPUB**, **Markdown para RAG**, **HTML** (publicado en [VuelaLibre.net](https://vuelalibre.net)) y **mazos Anki**.

---

## La colección

| # | Libro | Asignatura | Versión | Estado |
| --- | --- | --- | --- | --- |
| 1 | **`01-derecho-aereo-atc`** | Derecho Aéreo y ATC | `1.0-rc.14` | 🟡 En revisión |
| 2 | **`02-factores-humanos`** | Factores Humanos | `1.0-rc.13` | 🟡 En revisión |
| 3 | **`03-meteorologia`** | Meteorología | `1.0-rc.16` | 🟡 En revisión |
| 4 | **`04-comunicaciones`** | Comunicaciones | `1.0-rc.15` | 🟡 En revisión |
| 5 | **`05-principios-vuelo`** | Principios de Vuelo | `1.0-rc.8` | 🟡 En revisión |
| 6 | **`06-procedimientos-operativos`** | Procedimientos Operativos | `1.0-rc.2` | 🟡 En revisión |
| 7 | **`07-planificacion-rendimiento`** | Planificación y Rendimiento de Vuelo | `1.0-rc.3` | 🟡 En revisión |
| 8 | **`08-aeronave-sistemas`** | Aeronave, Sistemas y Equipo de Emergencia | `0.9.5` | 🟡 En revisión |
| 9 | **`09-navegacion`** | Navegación | `0.9.5` | 🟡 En revisión |

### Qué hay en cada libro

**1 · Derecho Aéreo y ATC** — Del Convenio de Chicago a las tres normas que un piloto de planeador necesita tener en la cabeza. Sin jerga de opositor, con las consecuencias operativas de cada regla.

**2 · Factores Humanos** — Qué le lleva a un piloto a decidir mal bajo presión, cómo la fatiga y el estrés le degradan el rendimiento sin que lo note, y qué herramientas mentales marcan la diferencia.

**3 · Meteorología** — Leer la atmósfera como un instructor con miles de horas. De la física del aire que te sostiene a los índices de sondeo que anticipan si el día será épico o peligroso.

**4 · Comunicaciones** — Radio con precisión y brevedad: la fraseología que el sistema espera en cada fase del vuelo.

**5 · Principios de Vuelo** — La aerodinámica que sostiene cada planeo, el equilibrio de fuerzas que mantiene estable al planeador y los fenómenos (pérdida, barrena, picado en espiral) que hay que reconocer y anticipar.

**6 · Procedimientos Operativos** — Del primer chequeo prevuelo al paracaídas de emergencia que nadie quiere usar y todos deben saber desplegar.

**7 · Planificación y Rendimiento** — Leer la polar de tu planeador, ajustar la velocidad de crucero a la térmica del día, calcular el centrado y rellenar un plan de vuelo OACI.

**8 · Aeronave, Sistemas y Equipo de Emergencia** — La máquina con el detalle que necesita un piloto, no un ingeniero: lo justo para saber cuándo el planeador puede volar y cuándo no.

**9 · Navegación** — Leer una carta aeronáutica, calcular el rumbo con viento, navegar por estima y usar el GNSS sin convertirlo en una muleta.

Las sinopsis completas, con contraportada y taglines, están en `recursos/media-kit/<libro>.md`.

### Estados editoriales

El estado se deduce de la versión del libro (campo `version:` en su `_quarto.yml`). El Makefile aplica esta tabla al compilar y la inyecta en la portadilla del PDF (marca de agua) y en la primera página del EPUB:

| Versión | Estado | Significado |
| --- | --- | --- |
| `>= 1.0.0` | ✅ Completado | Edición definitiva. Sin marca de agua ni aviso. |
| `1.x-rc.n` · `0.9.x` | 🟡 En revisión | Pendiente de revisión técnica por instructores. |
| `0.8.x` | 🎨 Creando ilustraciones | Texto completo; faltan ilustraciones. |
| `<= 0.7.x` | 🚧 En desarrollo | Texto e ilustraciones en elaboración. |

Un `1.0-rc.5` es anterior a `1.0.0`, no posterior. El CI comprueba en cada push que la tabla no se haya desfasado. Para verla:

```bash
make estados      # imprime "libro|versión|estado" de los 9 libros
```

### Registro de cambios

Cada libro tiene su `<libro>/CHANGELOG-NN.md`. Cada entrada empieza con una línea «Qué releer» para que un revisor no tenga que releer el libro entero.

Si cambias contenido, añade la línea bajo la versión en curso. El CI comprueba que la versión de `_quarto.yml` tenga su entrada: subir la versión sin registrar el cambio rompe la compilación.

---

Los `.qmd` son la fuente canónica: se editan directamente, no se generan. Las figuras siguen la [Guía de ilustraciones](GUIA_ILUSTRACIONES.md).

---

## Requisitos

- **Quarto CLI 1.9.17+**: [Instalación](https://quarto.org/docs/get-started/). La extensión `_extensions/orange-book-es/` necesita esta versión como mínimo.
- **Typst 0.15** (opcional): Quarto trae Typst 0.14.2, suficiente para compilar. Los entregables oficiales usan Typst 0.15 (paginación ligeramente distinta). Para reproducirlos:
  ```bash
  export QUARTO_TYPST="$(which typst)"
  ```

---

## Compilación

El Makefile automatiza todo.

### Colección completa

```bash
make
```

Los entregables van a:
- `build/pdf/` — PDF (Typst).
- `build/epub/` — EPUB 3.3 (imágenes raster convertidas a WebP, ancho máx. 1200 px). Validado con EPUBCheck 5.3.
- `build/rag/` — Un Markdown por asignatura, pensado para RAG. Ver [Markdown para RAG](#markdown-para-rag).
- `build/web/` — Paquetes `.web.tar.gz` para el lector de VuelaLibre.net.
- `build/anki/` — Mazos `.apkg`, uno por asignatura. Ver [Mazos Anki](#mazos-anki).

Cada fichero lleva el libro, su versión y la fecha del último commit que lo tocó:

```
build/pdf/09-navegacion-0.8.1-260716.pdf
build/epub/09-navegacion-0.8.1-260716.epub
```

### Un solo libro

```bash
make 05-principios-vuelo
```

### Markdown para RAG

Un fichero Markdown por libro, preparado para que cada fragmento se explique solo en un sistema RAG (NotebookLM, etc.). Los nueve caben en un solo cuaderno.

```bash
make rag          # segundos, no recompila PDF ni EPUB
```

Qué se ajusta respecto al libro:
- Los recuadros conservan su etiqueta como texto (`> **Seguridad**`, `> **Normativa**`…).
- El resumen de cada capítulo es un apartado propio.
- Las referencias cruzadas se resuelven (`@fig-04-cap05-…` pasa a «figura 5.1»).
- Las ilustraciones no viajan, pero sí sus pies de foto.
- Se excluyen preliminares, colofón y la guía de lectura (idéntica en los nueve libros).

Entra íntegro: capítulos, apéndices, glosario y bibliografía.

### Paquetes HTML

Quarto resuelve los `.qmd` y `tools/web/construir.py` los empaqueta con un `manifest.json`.

```bash
make web          # solo HTML
```

Cada paquete incluye: licencia, dedicatoria, reconocimientos, introducción, capítulos, apéndices, glosario y bibliografía. Las imágenes raster llevan AVIF y WebP a 480, 768 y 1200 px, con JPEG/PNG como fallback, `srcset`, `sizes` y dimensiones intrínsecas. El CI valida los 9 paquetes y sus 141 páginas.

En VuelaLibre.net se sirven así:

```
https://vuelalibre.net/libros/navegacion/leer/
https://vuelalibre.net/libros/navegacion/leer/navegacion-por-estima/
```

### Mazos Anki

Un mazo de repaso espaciado por asignatura, **598 tarjetas** en total. Estructura: `SPL::NN Asignatura::NN Capítulo`.

```bash
make anki         # segundos
```

Se importan con doble clic sobre el `.apkg`. Reimportar una versión nueva actualiza las tarjetas sin borrar el historial de repaso (los identificadores son estables).

Las tarjetas están escritas a mano en `tools/anki/mazos/`. Salen de los resúmenes de cada capítulo y de los recuadros del temario (Seguridad, Normativa, Regla de oro, Airmanship), que viajan como etiqueta (`spl::recuadro::seguridad`). Cada tarjeta cita el libro, capítulo y versión de origen.

Hay dos tipos: pregunta-respuesta y hueco (cloze), con hoja de estilo propia y modo oscuro. Si el libro no es definitivo, el mazo incluye un aviso con el estado editorial.

### Limpiar

Elimina `build/`, `_book/` y cachés de Quarto. No toca los `.qmd`, `_quarto.yml` ni las `imagenes/`:

```bash
make clean
```

---

## Publicar una release

Los entregables se publican en la [página de releases](https://github.com/VuelaLibre-net/teoria-licencia-SPL/releases), accesible sin cuenta de GitHub. El proceso lo automatiza `.github/workflows/release.yml`: empujar un tag lo dispara.

```bash
# 1. Sube la versión de los libros que hayan cambiado, cierra sus CHANGELOG
#    y fusiona a main.

# 2. Crea un tag anotado:
git switch main && git pull
git tag -a v0.9.2 -m "Descripción breve de la entrega"
git push github v0.9.2
```

El remoto se llama **`github`**, no `origin`. `git push origin …` falla.

El tag no recompila: busca el run del CI que ya validó ese commit y publica sus entregables. Si el CI sigue en marcha, la release lo espera. Solo compila si no hay nada que reutilizar (ningún run para ese commit o artefactos caducados; la retención son 2 días). Si el CI falló, la release aborta.

Con los 45 entregables (9 PDF, 9 EPUB, 9 RAG, 9 web, 9 Anki) crea una **release en borrador**. El manual completo no entra (se compila en local con `make completo`).

Para terminar, a mano:

1. Abre el borrador y rellena «Qué ha cambiado en esta versión» (la tabla de estados ya viene generada de `make estados`). Usa la línea «Qué releer» de cada `CHANGELOG-NN.md`.
2. Pulsa **Publish release**.

Es borrador a propósito: compilar y verificar se automatiza, pero decidir que la entrega sale al público y redactar qué cambió es cosa de una persona.

El **número del tag** sale de la versión del libro menos maduro. Si ya está etiquetada, se sube el último dígito. El prefijo `v` es obligatorio: distingue el tag de la versión literal de los libros (`05-principios-vuelo-0.9.1-260802.pdf`).

Si el borrador sale mal, se borra y se vuelve a empezar:

```bash
gh release delete v0.9.2 --yes
git push github --delete v0.9.2 && git tag -d v0.9.2
```

---

## Estructura editorial

Cada asignatura es un proyecto Quarto independiente con su `_quarto.yml`:

- **Preliminares:** Licencia, Dedicatoria, Epígrafe, Reconocimientos e Introducción, sin numerar (`{.unnumbered}`). Después de los Reconocimientos y antes de la Introducción, la extensión inserta el índice general (TOC) y, si hay figuras o tablas, sus índices.
- **Capítulos:** La numeración empieza en el primer tema (`cap01-`).
- **Apéndices:** Syllabus Oficial EASA, Glosario, Bibliografía, Colofón y Contracubierta, numerados aparte (A, B, C…).

Esa ordenación la aporta la extensión local `_extensions/orange-book-es/`, un fork de `orange-book` con la maquetación reordenada y los rótulos en español. Cada libro la enlaza con un symlink (`_extensions -> ../_extensions`) porque Quarto solo busca extensiones dentro del directorio del proyecto.
