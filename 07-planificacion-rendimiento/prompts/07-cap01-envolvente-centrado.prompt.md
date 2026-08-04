---
schema: 1
figura: 07-cap01-envolvente-centrado.png
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

# 07-cap01-envolvente-centrado

**Qué enseña.** Masa contra posición del CG, con el rango permitido y los cuatro casos de centrado que el propio capítulo calcula.

**Por qué existe.** El cap01 daba cuatro resultados numéricos sueltos y ninguna forma de ver el margen que queda ni hacia dónde se mueve el CG en cada caso.

## Cómo se genera

No se ha usado ningún generador de imágenes. La figura la dibuja
`tools/figuras/07_planificacion.py` con matplotlib, y se regenera con:

```bash
python3 tools/figuras/07_planificacion.py 07-cap01-envolvente-centrado
```

⚠️ **Todas las cifras salen del propio capítulo**, no de una fuente externa ni de
una estimación. Están anotadas una a una en el docstring de su función. Si el
texto cambia un número, hay que cambiarlo aquí y regenerar: no hay guardián que
detecte la divergencia.

`GUIA_ILUSTRACIONES.md` prohíbe generar con IA los gráficos cuantitativos, que
«se construyen desde datos verificables». Éste lo es.

El estilo —paleta, Libertinus Sans y mínimo de 9 pt al tamaño final— vive en
`tools/figuras/estilo.py`.
