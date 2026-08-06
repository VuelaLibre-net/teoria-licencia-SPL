#!/usr/bin/env python3
"""Verifica los paquetes Anki antes de publicarlos.

Un .apkg es un zip con una base sqlite dentro, así que ninguno de los guardianes
que ya tiene el repositorio lo mira: `grep` sobre el fichero no ve nada. Y como
el resto de esta cadena, falla en silencio — genanki escribe un paquete
perfectamente válido con la maqueta sin traducir, con el campo `Fuente` vacío o
con los identificadores cambiados, y sale con 0.

    tools/anki/validar.py            # todos los .apkg de build/anki/
    tools/anki/validar.py <fichero>  # sólo ése

Lo que comprueba, y por qué cada cosa:

* **Maqueta sin traducir** (`:::`, `@fig-`, `**`, `{{<`): el mismo guardián que
  el Markdown para RAG. Si el conversor de markdown deja de reconocer algo, sale
  literal en la tarjeta.
* **`Fuente` no vacío**: una tarjeta que el alumno recuerda mal sólo se puede
  corregir contra el manual, y sin la referencia no hay a qué volver.
* **GUID únicos y con la forma esperada**: dos notas con el mismo GUID se pisan
  al importar; ver la advertencia de `modelo.py`.
* **Las cloze llevan hueco**: `{{c1::…}}`. Una nota cloze sin hueco genera CERO
  cartas — la nota está en el paquete, el alumno no ve nada y no hay error.
* **La taxonomía de recuadros sigue cerrada**: cuatro categorías, las mismas del
  temario.
* **Los nombres de mazo respetan el árbol** `SPL::NN Asignatura::NN Capítulo`: el
  nombre es la identidad del mazo en la colección del alumno.
"""

from __future__ import annotations

import json
import re
import sqlite3
import sys
import tempfile
import zipfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
SALIDA = RAIZ / "build" / "anki"

CATEGORIAS = {"seguridad", "normativa", "regla-de-oro", "airmanship"}

# `**` y `*` no se buscan a secas: un asterisco suelto es legítimo en una tarjeta
# de meteorología. Se busca el par, que es lo que delataría una negrita o una
# cursiva sin convertir.
MAQUETA = (
    (re.compile(r"^:::", re.M), "div de Quarto sin traducir"),
    (re.compile(r"\*\*.+?\*\*", re.S), "negrita markdown sin convertir"),
    (re.compile(r"@(?:fig|tbl)-"), "referencia cruzada sin resolver"),
    (re.compile(r"\{\{<"), "shortcode de Quarto sin resolver"),
    (re.compile(r"\?meta:"), "shortcode de metadatos sin resolver"),
)

RE_MAZO = re.compile(r"^SPL::\d{2} .+?(?:::\d{2} .+)?$")
RE_CLOZE = re.compile(r"\{\{c\d+::")


def abrir(apkg: Path) -> sqlite3.Connection:
    with tempfile.TemporaryDirectory() as tmp:
        with zipfile.ZipFile(apkg) as z:
            nombre = next(n for n in z.namelist() if n.startswith("collection.anki"))
            z.extract(nombre, tmp)
        destino = Path(tmp) / nombre
        # La conexión debe sobrevivir al TemporaryDirectory: se lee todo a memoria.
        memoria = sqlite3.connect(":memory:")
        disco = sqlite3.connect(destino)
        disco.backup(memoria)
        disco.close()
        return memoria


def nombres(col: sqlite3.Connection) -> tuple[list[str], dict[int, str]]:
    """Mazos y modelos, del esquema viejo (JSON en `col`) o del nuevo (tablas)."""
    fila = col.execute("select models, decks from col").fetchone()
    if fila and fila[0]:
        mazos = [d["name"].replace("\x1f", "::") for d in json.loads(fila[1]).values()]
        modelos = {int(k): v["name"] for k, v in json.loads(fila[0]).items()}
    else:
        mazos = [r[0].replace("\x1f", "::") for r in col.execute("select name from decks")]
        modelos = {r[0]: r[1] for r in col.execute("select id, name from notetypes")}
    return mazos, modelos


def validar(apkg: Path) -> list[str]:
    fallos: list[str] = []
    col = abrir(apkg)
    mazos, modelos = nombres(col)

    for mazo in mazos:
        if mazo == "Default":
            continue  # genanki lo incluye siempre; Anki no lo muestra si va vacío
        if not RE_MAZO.match(mazo):
            fallos.append(f"nombre de mazo fuera del árbol SPL: {mazo!r}")

    notas = list(col.execute("select id, guid, mid, flds, tags from notes"))
    if not notas:
        fallos.append("el paquete no tiene ni una nota")

    cartas = {r[0] for r in col.execute("select nid from cards")}
    guids: dict[str, int] = {}

    for nid, guid, mid, flds, tags in notas:
        modelo = modelos.get(mid, "?")
        campos = flds.split("\x1f")
        etiqueta = f"nota {nid} ({modelo})"

        if guid in guids:
            fallos.append(f"{etiqueta}: GUID repetido con la nota {guids[guid]}")
        guids[guid] = nid

        if nid not in cartas:
            fallos.append(f"{etiqueta}: no genera ninguna carta")

        if not campos[-1].strip():
            fallos.append(f"{etiqueta}: campo Fuente vacío")

        for i, campo in enumerate(campos):
            for patron, motivo in MAQUETA:
                if patron.search(campo):
                    fallos.append(f"{etiqueta}, campo {i}: {motivo}")

        if modelo == "SPL Cloze" and not RE_CLOZE.search(campos[0]):
            fallos.append(f"{etiqueta}: nota cloze sin ningún {{{{cN::…}}}}")

        for tag in tags.split():
            if tag.startswith("spl::recuadro::") and tag.split("::")[-1] not in CATEGORIAS:
                fallos.append(f"{etiqueta}: categoría de recuadro fuera del temario: {tag}")

    col.close()
    return fallos


def main(argv: list[str]) -> int:
    paquetes = [Path(a) for a in argv[1:]] or sorted(SALIDA.glob("*.apkg"))
    if not paquetes:
        print(f"✗ No hay ningún .apkg en {SALIDA.relative_to(RAIZ)}", file=sys.stderr)
        return 1

    total = 0
    for apkg in paquetes:
        fallos = validar(apkg)
        total += len(fallos)
        if fallos:
            print(f"✗ {apkg.name}")
            for f in fallos:
                print(f"    {f}")
        else:
            print(f"✓ {apkg.name}")

    if total:
        print(f"\n✗ {total} problema(s) en los paquetes Anki", file=sys.stderr)
        return 1
    print(f"\n✓ {len(paquetes)} paquete(s) Anki correctos")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
