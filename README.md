# Colección de Manuales Teóricos SPL (Licencia de Piloto de Planeador) en Quarto

[![Compilar Manuales SPL](https://github.com/VuelaLibre-net/teoria-licencia-SPL/actions/workflows/ci.yml/badge.svg)](https://github.com/VuelaLibre-net/teoria-licencia-SPL/actions/workflows/ci.yml)
[![Licencia: CC BY 4.0](https://img.shields.io/badge/Licencia-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/deed.es)
[![Avalado por AESA](https://img.shields.io/badge/Programa-avalado%20por%20AESA-0057B7.svg)](https://www.seguridadaerea.gob.es/)
[![Syllabus AMC1 SFCL.130](https://img.shields.io/badge/Syllabus-AMC1%20SFCL.130%20(EASA--FCL)-003399.svg)](https://www.easa.europa.eu/)
[![Quarto](https://img.shields.io/badge/Quarto-%E2%89%A5%201.9.17-75AADB.svg)](https://quarto.org/)
[![Typst](https://img.shields.io/badge/Typst-0.15-239DAD.svg)](https://typst.app/)
[![Formatos](https://img.shields.io/badge/Formatos-PDF%20%C2%B7%20EPUB-E44D26.svg)](#instrucciones-de-compilación)

`vuelo-a-vela` · `planeador` · `spl` · `easa-fcl` · `aesa` · `licencia-de-piloto` · `manual-de-formación` ·
`temario-teórico` · `quarto` · `typst` · `epub` · `español`

Este repositorio contiene la versión digitalizada de 9 libros que cubren el temario teórico para la obtención de la **Licencia de Piloto de Planeador (SPL)** bajo la regulación **EASA-FCL (European Union Aviation Safety Agency - Flight Crew Licensing)**, adaptada a los requerimientos de la **Agencia Estatal de Seguridad Aérea (AESA)** española.

El contenido está en **Quarto Markdown (.qmd)** para la generación de entregables de alta calidad en formatos cómodos de editar por los colaboradores, **PDF (mediante el motor Typst)** y **EPUB (mediante Pandoc)**.

---

## Estructura de la Colección

La biblioteca está organizada por asignaturas según el syllabus oficial de AESA/EASA:

| # | Libro | Asignatura | Versión | Estado |
| --- | --- | --- | --- | --- |
| 1 | **`01-derecho-aereo-atc`** | Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo (ATC) | `1.0-rc.5` | 🟡 En revisión |
| 2 | **`02-factores-humanos`** | Factores Humanos | `1.0-rc.4` | 🟡 En revisión |
| 3 | **`03-meteorologia`** | Meteorología | `1.0-rc.4` | 🟡 En revisión |
| 4 | **`04-comunicaciones`** | Comunicaciones | `1.0-rc.4` | 🟡 En revisión |
| 5 | **`05-principios-vuelo`** | Principios de Vuelo | `0.8.1` | 🎨 Creando ilustraciones |
| 6 | **`06-procedimientos-operativos`** | Procedimientos Operativos | `0.8.1` | 🎨 Creando ilustraciones |
| 7 | **`07-planificacion-rendimiento`** | Planificación y Rendimiento de Vuelo | `0.8.1` | 🎨 Creando ilustraciones |
| 8 | **`08-aeronave-sistemas`** | Conocimientos Generales de la Aeronave, Estructura, Sistemas y Equipo de Emergencia | `0.8.1` | 🎨 Creando ilustraciones |
| 9 | **`09-navegacion`** | Navegación | `0.8.1` | 🎨 Creando ilustraciones |

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
directamente y no se generan a partir de ningún otro formato.

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
Genera los entregables en formatos PDF y EPUB para todos los libros:
```bash
make
```
Los archivos finales se guardarán en:
- `build/pdf/` - PDFs de alta calidad listos para impresión o consulta digital (Typst).
- `build/epub/` - Libros electrónicos adaptados para e-readers (Pandoc).

Cada entregable lleva en el nombre **el libro, su versión y su fecha** (`yy-mm-dd`), de modo que un
fichero descargado se identifica sin abrirlo y dos versiones del mismo libro no se pisan:

```
build/pdf/09-navegacion-0.8.1-26-07-16.pdf
build/epub/09-navegacion-0.8.1-26-07-16.epub
```

La fecha es la del último commit que tocó el libro —la misma que figura en su colofón—, no la de
compilación: así el nombre sólo cambia cuando cambia el libro.

### Compilar un libro individual
Puedes compilar una única asignatura especificando su nombre de directorio. Por ejemplo:
```bash
make 05-principios-vuelo
```

### Limpiar la compilación
Elimina los entregables generados (`build/`, `_book/`) y las cachés de Quarto. **No toca los `.qmd`,
los `_quarto.yml` ni las `imagenes/`**, que son la fuente canónica:
```bash
make clean
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
