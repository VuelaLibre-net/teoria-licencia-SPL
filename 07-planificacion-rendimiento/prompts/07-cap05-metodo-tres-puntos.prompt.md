---
schema: 1
figura: 07-cap05-metodo-tres-puntos.png
tipo: gráfico cuantitativo
estado: revision-tecnica
fecha:
herramienta:
  nombre: matplotlib
  version: "3.10.9"
fuentes:
  - referencia: cifras del propio capítulo del libro 07
    licencia: misma que la obra
restricciones: sin logotipos ni marcas; ningún dato ajeno al capítulo
revision:
  persona:
  fecha:
master_editable: tools/figuras/07_planificacion.py
---

# 07-cap05-metodo-tres-puntos

**Qué enseña.** Margen de llegada frente a distancia recorrida en el planeo final, con la traza que aguanta y la que se degrada, y los tres puntos de comprobación.

**Por qué existe.** El método de los tres puntos es literalmente una comparación de tendencias y se explicaba sin ninguna.

## Cómo se genera

No se ha usado ningún generador de imágenes. La figura la dibuja
`tools/figuras/07_planificacion.py` con matplotlib, y se regenera con:

```bash
python3 tools/figuras/07_planificacion.py 07-cap05-metodo-tres-puntos
```

⚠️ **Todas las cifras salen del propio capítulo**, no de una fuente externa ni de
una estimación. Están anotadas una a una en el docstring de su función. Si el
texto cambia un número, hay que cambiarlo aquí y regenerar: no hay guardián que
detecte la divergencia.

`GUIA_ILUSTRACIONES.md` prohíbe generar con IA los gráficos cuantitativos, que
«se construyen desde datos verificables». Éste lo es.

El estilo —paleta, Libertinus Sans y mínimo de 9 pt al tamaño final— vive en
`tools/figuras/estilo.py`.
