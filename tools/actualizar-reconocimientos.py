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

# Edición inglesa (en/): mismo listado, con su cabecera y las descripciones
# traducidas. Las marcas ✓ son las de la edición española —quien validó el
# libro, validó el texto español—, y la cabecera lo dice.
DIRECTORIOS_EN = [
    ("en/07-flight-performance-planning", 7),
]

HEADER_EN = """# Acknowledgements {.unnumbered}

This manual is the result of a collaborative effort within the gliding community. We wish to express our sincere thanks to:

* The **Spanish Aviation Safety Agency (AESA)** and **EASA**, for providing the regulatory and documentary framework that keeps our operations safe.
* The **Flight Instructors (FI(S))** and **Examiners (FE(S))** who have given their time to review these sections and ensure their technical rigour.
* The **VuelaLibre.net** community, for driving initiatives that modernise and open up access to high-quality aeronautical training.
* All the pilots whose constant feedback helps keep this manual a living, evolving tool.
* The authors of the classic international manuals, whose structure served as the basis for organising the knowledge in a way that is teachable and accessible to new generations of glider pilots and, in particular, to:

A ✓ marks the reviewers who have validated the Spanish edition of this book, from which this translation is made.

::: {.creditos}
"""

# Toda descripción nueva en el JSON necesita aquí su traducción: el script
# aborta antes que publicar una línea en español en la edición inglesa.
DESCRIPCIONES_EN = {
    "Campeón de España de Vuelo a Vela. Instructor y Examinador de Vuelo a Vela":
        "Spanish Gliding Champion. Gliding instructor and examiner",
    "Instructor y Examinador de Vuelo a Vela": "Gliding instructor and examiner",
    "Instructora y Examinadora de Vuelo a Vela": "Gliding instructor and examiner",
    "Piloto de Vuelo a Vela. Edición técnica": "Glider pilot. Technical editing",
}


def generar_contenido_reconocimientos(revisores_data: dict, num_libro: int, idioma: str = "es") -> str:
    lineas = [HEADER_EN if idioma == "en" else HEADER]
    revisores = revisores_data.get("revisores", [])

    blocks = []
    for idx, rev in enumerate(revisores):
        nombre = rev["nombre"]
        subtitulo = rev["subtitulo"]
        descripcion = rev["descripcion"]
        if idioma == "en":
            if descripcion not in DESCRIPCIONES_EN:
                raise SystemExit(f"✗ Falta la traducción inglesa de «{descripcion}» en DESCRIPCIONES_EN")
            descripcion = DESCRIPCIONES_EN[descripcion]

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

    for subfolder, num_libro in DIRECTORIOS_EN:
        target_file = BASE_DIR / subfolder / "acknowledgements.qmd"
        contenido = generar_contenido_reconocimientos(revisores_data, num_libro, "en")
        target_file.write_text(contenido, encoding="utf-8")
        print(f"✓ Actualizado {subfolder}/acknowledgements.qmd (Book {num_libro})")


if __name__ == "__main__":
    main()
