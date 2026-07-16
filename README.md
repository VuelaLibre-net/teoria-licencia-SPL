# Colección de Manuales Teóricos SPL (Licencia de Piloto de Planeador) en Quarto

Este repositorio contiene la versión digitalizada de 9 libros que cubren el temario teórico para la obtención de la **Licencia de Piloto de Planeador (SPL)** bajo la regulación **EASA-FCL (European Union Aviation Safety Agency - Flight Crew Licensing)**, adaptada a los requerimientos de la **Agencia Estatal de Seguridad Aérea (AESA)** española.

El contenido está en **Quarto Markdown (.qmd)** para la generación de entregables de alta calidad en formatos cómodos de editar por los colaboradores, **PDF (mediante el motor Typst)** y **EPUB (mediante Pandoc)**.

---

## Estructura de la Colección

La biblioteca está organizada por asignaturas según el syllabus oficial de AESA/EASA:

1. **`01-derecho-aereo-atc`** - Derecho Aéreo y Procedimientos de Control de Tránsito Aéreo
2. **`02-factores-humanos`** - Factores Humanos (Medicina y Psicología Aeronáutica)
3. **`03-meteorologia`** - Meteorología General y Aeronáutica
4. **`04-comunicaciones`** - Comunicaciones (Procedimientos de Radio y Fraseología VFR)
5. **`05-principios-vuelo`** - Principios de Vuelo (Aerodinámica y Estabilidad del Planeador)
6. **`06-procedimientos-operativos`** - Procedimientos Operativos y Emergencias
7. **`07-planificacion-rendimiento`** - Rendimiento y Planificación de Vuelo
8. **`08-aeronave-sistemas`** - Conocimientos Generales de la Aeronave, Estructura y Sistemas
9. **`09-navegacion`** - Navegación Visual, Estima e Instrumentos (GNSS)

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
