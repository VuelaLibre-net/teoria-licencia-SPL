#!/usr/bin/env python3
"""Genera y actualiza reconocimientos.qmd en cada libro y en recursos-completo a partir de recursos/estado-revisores.json"""
from __future__ import annotations

import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
ESTADO_JSON = BASE_DIR / "recursos" / "estado-revisores.json"

DIRECTORIOS_LIBROS = [
    ("01-derecho-aereo-atc", 1),
    ("02-factores-humanos", 2),
    ("03-meteorologia", 3),
    ("04-comunicaciones", 4),
    ("05-principios-vuelo", 5),
    ("06-procedimientos-operativos", 6),
    ("07-planificacion-rendimiento", 7),
    ("08-aeronave-sistemas", 8),
    ("09-navegacion", 9),
    ("recursos-completo", 0),  # 0 indica el volumen completo
]

HEADER = """# Reconocimientos {.unnumbered}

Este manual es el fruto de un esfuerzo colaborativo dentro de la comunidad de vuelo sin motor. Queremos expresar nuestro más sincero agradecimiento a:

* **Agencia Estatal de Seguridad Aérea (AESA)** y **EASA**, por proporcionar el marco normativo y documental que garantiza la seguridad de nuestras operaciones.
* Los **Instructores de Vuelo (FI(S))** y **Examinadores (FE(S))** que han dedicado su tiempo a revisar técnicamente estas secciones para asegurar su rigor técnico.
* A la comunidad de **VuelaLibre.net**, por impulsar iniciativas que modernizan y democratizan el acceso a la formación aeronáutica de calidad.
* A todos los pilotos que, con su feedback constante, ayudan a que este manual sea una herramienta viva y en evolución.
* A los autores de los manuales internacionales clásicos, cuya estructura ha servido de base para organizar el conocimiento de una forma pedagógica y accesible para las nuevas generaciones de pilotos de planeador y, en especial a:

::: {.creditos}
"""

FOOTER = ":::\n"


def generar_contenido_reconocimientos(revisores_data: dict, num_libro: int) -> str:
    lineas = [HEADER]
    revisores = revisores_data.get("revisores", [])

    blocks = []
    for idx, rev in enumerate(revisores):
        nombre = rev["nombre"]
        subtitulo = rev["subtitulo"]
        descripcion = rev["descripcion"]

        if rev.get("honorifico"):
            nombre_con_sufijo = nombre
        else:
            libros_validados = set(rev.get("libros_validados", []))
            libros_pendientes = set(rev.get("libros_pendientes", []))

            if num_libro == 0:  # Completo: incluye a quienes participan en al menos un libro
                if not libros_validados and not libros_pendientes:
                    continue

                if set(range(1, 10)).issubset(libros_validados):
                    nombre_con_sufijo = f"{nombre} ✓"
                else:
                    nombre_con_sufijo = nombre
            else:  # Libro num_libro específico
                if num_libro in libros_validados:
                    nombre_con_sufijo = f"{nombre} ✓"
                elif num_libro in libros_pendientes:
                    nombre_con_sufijo = nombre
                else:
                    # No participa en la revisión ni redacción de este libro
                    continue

        block = f"{nombre_con_sufijo}\n\n:   {subtitulo}\n\n:   {descripcion}"
        blocks.append(block)

    lineas.append("\n\n".join(blocks))
    lineas.append("\n" + FOOTER)

    return "".join(lineas)


def main() -> None:
    if not ESTADO_JSON.exists():
        raise FileNotFoundError(f"No se encontró el archivo de estado: {ESTADO_JSON}")

    with open(ESTADO_JSON, "r", encoding="utf-8") as f:
        revisores_data = json.load(f)

    for subfolder, num_libro in DIRECTORIOS_LIBROS:
        target_file = BASE_DIR / subfolder / "reconocimientos.qmd"
        contenido = generar_contenido_reconocimientos(revisores_data, num_libro)
        target_file.write_text(contenido, encoding="utf-8")
        print(f"✓ Actualizado {subfolder}/reconocimientos.qmd (Libro {num_libro if num_libro != 0 else 'Completo'})")


if __name__ == "__main__":
    main()
