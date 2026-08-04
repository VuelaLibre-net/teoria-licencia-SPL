---
schema: 1
figura: 09-cap05-error-deliberado.png
tipo: diagrama conceptual
estado: revision-tecnica
fecha:
herramienta:
  nombre: matplotlib
  version: "3.10.9"
fuentes:
  - referencia: elaboración propia a partir del texto del capítulo
    licencia: misma que la obra
restricciones: sin logotipos, marcas ni reproducción de documentos oficiales
revision:
  persona:
  fecha:
master_editable: tools/figuras/09_navegacion.py
---

# 09-cap05-error-deliberado

**Qué enseña.** Ruta directa frente a ruta con error deliberado hacia una referencia lineal que pasa por el objetivo.

**Por qué existe.** Figura nueva, para la técnica que se incorpora en esta versión.

## Cómo se genera

No se ha usado ningún generador de imágenes. La figura se construye por código con
matplotlib, desde `tools/figuras/09_navegacion.py`, función correspondiente a este
nombre. La regeneración es reproducible:

```bash
python3 tools/figuras/09_navegacion.py 09-cap05-error-deliberado
```

`GUIA_ILUSTRACIONES.md` reserva la generación por IA para los diagramas conceptuales y
la prohíbe en los gráficos cuantitativos, que «se construyen desde datos verificables».
Aquí se ha elegido el código para **todas**, por dos razones:

* Las cotas son cifras exactas que el propio capítulo calcula. Un generador no garantiza
  que el número dibujado coincida con el del texto, y ese desajuste no lo detecta ningún
  guardián del CI.
* La geometría es el contenido. En el triángulo de velocidades, en el cono de alcance o
  en la regla del 1 en 60, la figura sólo enseña algo si los ángulos y las longitudes
  salen del mismo cálculo que el texto.

El estilo —paleta, tipografía Libertinus Sans y tamaño mínimo de 9 pt al tamaño final—
está centralizado en `tools/figuras/estilo.py`, que aborta si la fuente no está en
`recursos/fuentes/`.
