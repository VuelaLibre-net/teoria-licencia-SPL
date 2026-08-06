#!/usr/bin/env python3
"""Compila los mazos de un libro a un paquete Anki (.apkg).

    tools/anki/construir.py <libro> <versión> <fecha-iso> <estado> <salida.apkg>

Los cuatro datos se los pasa el **Makefile**, igual que al PDF, al EPUB, al RAG y
al paquete web: versión del `_quarto.yml`, fecha del último commit y estado de
`estado_libro`. No se deducen aquí; sería una quinta copia de esa lógica y
divergiría sin dar error.

Las tarjetas salen de `tools/anki/mazos/<libro>/capNN.yml`, que son fuente
canónica escrita a mano (ver `extraer.py`). Viven fuera del directorio del libro
a propósito: `fecha_libro` es el último commit que tocó `<libro>/`, así que
guardarlas dentro movería la fecha del colofón —y con ella el nombre del PDF, del
EPUB, del RAG y del paquete web— cada vez que se corrigiera una tarjeta.

⚠️ El .apkg es un mazo que el alumno **reimporta** sobre el suyo, no un fichero
nuevo cada vez. Eso obliga a que los identificadores sean estables: ver
`modelo.py`. Si dejan de serlo, la reimportación no actualiza: duplica, y el
alumno pierde el historial de repaso sin que nada dé error.
"""

from __future__ import annotations

import pathlib
import re
import sys
import unicodedata

import genanki
import yaml

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from modelo import MODELOS, guid, id_estable, markdown_a_html  # noqa: E402

RAIZ = pathlib.Path(__file__).resolve().parents[2]
MAZOS = RAIZ / "tools" / "anki" / "mazos"

CATEGORIAS = {"Seguridad", "Normativa", "Regla de oro", "Airmanship"}


def slug(texto: str) -> str:
    """Normaliza una etiqueta para Anki, que separa las etiquetas por espacios."""
    plano = unicodedata.normalize("NFKD", texto).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "-", plano.lower()).strip("-")


def titulo_libro(libro: str) -> str:
    quarto = (RAIZ / libro / "_quarto.yml").read_text(encoding="utf-8")
    m = re.search(r'^\s+title:\s*"([^"]+)"', quarto, re.M)
    if not m:
        raise SystemExit(f"✗ {libro}/_quarto.yml no declara title:")
    return m.group(1)


def campos_de(tarjeta: dict, fuente: str) -> tuple[str, list[str]]:
    tipo = tarjeta.get("tipo", "basica")
    if tipo == "basica":
        return tipo, [
            markdown_a_html(tarjeta["anverso"]),
            markdown_a_html(tarjeta["reverso"]),
            fuente,
        ]
    if tipo == "cloze":
        return tipo, [
            markdown_a_html(tarjeta["texto"]),
            markdown_a_html(tarjeta.get("extra", "")) if tarjeta.get("extra") else "",
            fuente,
        ]
    raise SystemExit(f"✗ Tipo de tarjeta desconocido: {tipo!r} (id {tarjeta.get('id')})")


def construir(libro: str, version: str, fecha: str, estado: str, salida: pathlib.Path) -> int:
    directorio = MAZOS / libro
    if not directorio.is_dir():
        raise SystemExit(f"✗ No hay mazos para {libro}: falta {directorio.relative_to(RAIZ)}")

    numero = int(libro.split("-")[0])
    nombre_libro = titulo_libro(libro)
    # El mazo raíz agrupa las nueve asignaturas bajo un solo árbol plegable en
    # Anki; cada asignatura es un submazo, y cada capítulo un submazo suyo.
    raiz = f"SPL::{numero:02d} {nombre_libro}"

    mazos: dict[str, genanki.Deck] = {}
    vistos: set[str] = set()
    total = 0

    for ruta in sorted(directorio.glob("cap[0-9][0-9].yml")):
        # ⚠️ El error de YAML más frecuente al escribir tarjetas es un `: ` en
        # medio de un escalar sin comillas («Resumen SERA.8001: ¿qué recibe…»),
        # que el analizador toma por un mapa anidado. Sin este mensaje, lo que
        # se ve es una traza de treinta líneas de pyyaml.
        try:
            datos = yaml.safe_load(ruta.read_text(encoding="utf-8")) or {}
        except yaml.YAMLError as e:
            marca = getattr(e, "problem_mark", None)
            donde = f" (línea {marca.line + 1})" if marca else ""
            raise SystemExit(
                f"✗ {ruta.relative_to(RAIZ)}{donde}: YAML inválido.\n"
                "  Si el texto lleva «: » en medio, ponlo entre comillas o usa un bloque |.\n"
                f"  {getattr(e, 'problem', e)}"
            ) from None
        if datos.get("libro") != libro:
            raise SystemExit(f"✗ {ruta.name} dice libro: {datos.get('libro')!r}, se esperaba {libro!r}")
        capitulo = int(datos["capitulo"])
        titulo_cap = datos["titulo"]
        tarjetas = datos.get("tarjetas") or []
        if not tarjetas:
            continue

        nombre_mazo = f"{raiz}::{capitulo:02d} {titulo_cap}"
        mazo = mazos.setdefault(
            nombre_mazo, genanki.Deck(id_estable(nombre_mazo), nombre_mazo)
        )
        fuente = f"{nombre_libro} · cap. {capitulo} — {titulo_cap} · v{version}"

        for tarjeta in tarjetas:
            id_tarjeta = tarjeta["id"]
            if id_tarjeta in vistos:
                raise SystemExit(f"✗ id de tarjeta repetido en {libro}: {id_tarjeta!r}")
            vistos.add(id_tarjeta)

            tipo, campos = campos_de(tarjeta, fuente)
            etiquetas = [f"spl::{libro}", f"spl::{libro}::cap{capitulo:02d}"]
            for extra in tarjeta.get("etiquetas") or []:
                etiquetas.append(f"spl::{slug(extra)}" if extra not in CATEGORIAS
                                 else f"spl::recuadro::{slug(extra)}")
            mazo.add_note(
                genanki.Note(
                    model=MODELOS[tipo],
                    fields=campos,
                    tags=etiquetas,
                    guid=guid(libro, capitulo, id_tarjeta),
                )
            )
            total += 1

    if not total:
        raise SystemExit(f"✗ {libro}: los mazos no tienen ni una tarjeta escrita")

    # ⚠️ El estado editorial viaja en una tarjeta propia y no en el nombre del
    # mazo: el nombre es la identidad del mazo en la colección del alumno y
    # cambiarlo al pasar de «En revisión» a completado le crearía un árbol nuevo
    # y le dejaría el viejo al lado, con las tarjetas duplicadas.
    if estado:
        aviso = mazos.setdefault(raiz, genanki.Deck(id_estable(raiz), raiz))
        aviso.add_note(
            genanki.Note(
                model=MODELOS["basica"],
                fields=[
                    markdown_a_html(f"**Estado de este mazo:** {nombre_libro} v{version}"),
                    markdown_a_html(
                        f"**{estado}.** El libro del que salen estas tarjetas todavía no es "
                        "definitivo; su contenido puede cambiar. Contrasta con el manual "
                        "antes de dar por buena una tarjeta que te choque."
                    ),
                    f"Generado el {fecha}",
                ],
                tags=[f"spl::{libro}", "spl::aviso"],
                guid=guid(libro, 0, "aviso-de-estado"),
            )
        )

    salida.parent.mkdir(parents=True, exist_ok=True)
    genanki.Package(list(mazos.values())).write_to_file(salida)
    return total


def main(argv: list[str]) -> int:
    if len(argv) != 6:
        print(__doc__, file=sys.stderr)
        return 2
    _, libro, version, fecha, estado, salida = argv
    total = construir(libro, version, fecha, estado, pathlib.Path(salida))
    print(f"✓ {total} tarjetas en {salida}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
