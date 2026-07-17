#!/usr/bin/env python3
"""Caza la negrita anidada dentro de negrita, que Markdown no admite.

`**Gradiente (DALR - **Dry Adiabatic Lapse Rate**)**` parece correcto y no lo
es: el `**` interior cierra el exterior en vez de abrir uno nuevo. El resultado
publicado es el contrario del que se pretendía —el término inglés SIN resaltar
y el paréntesis de cierre en negrita—:

    <strong>Gradiente (DALR - </strong>Dry Adiabatic Lapse Rate<strong>)</strong>

No da ningún error. Quarto compila, el .qmd se lee bien y el fallo sólo se ve
en el entregable, mirando muy de cerca. Tres capítulos se publicaron así.

QUÉ SE COMPRUEBA: que ninguna negrita ni cursiva empiece o acabe en espacio.
No es una heurística: Markdown no puede producirlas —`** hola **` no es negrita,
precisamente porque los delimitadores no pueden tocar un espacio por dentro—.
Si aparece una, es que el emparejado se resolvió por un sitio que nadie quería,
y la anidación rota es la causa habitual.

Buscar el patrón en el texto no vale: `**a **b** c**` puede ser correcto o no
según qué lo rodee, y sólo el parser lo sabe. Por eso se consulta el árbol.

SOLUCIÓN cuando salta: pasar el término interior a cursiva, que sí anida
(`**Gradiente (DALR - *Dry Adiabatic Lapse Rate*)**`). Es lo que hace el resto
de la colección.

Se usa `quarto pandoc`, no `pandoc`: el runner no trae pandoc suelto, y si lo
trajera no tendría por qué ser el mismo que compone los libros.
"""
import glob
import json
import subprocess
import sys

# Los contenedores donde un espacio en el borde es imposible por construcción.
MARCAS = ("Strong", "Emph")
ESPACIOS = ("Space", "SoftBreak", "LineBreak")


def texto(nodo):
    """Aplana un nodo del árbol a texto plano, para poder enseñarlo."""
    if isinstance(nodo, list):
        return "".join(texto(n) for n in nodo)
    if isinstance(nodo, dict):
        t = nodo.get("t")
        if t == "Str":
            return nodo.get("c", "")
        if t in ESPACIOS:
            return " "
        c = nodo.get("c")
        return texto(c) if isinstance(c, (list, dict)) else ""
    return ""


def busca(nodo, hallazgos):
    if isinstance(nodo, list):
        for n in nodo:
            busca(n, hallazgos)
        return
    if not isinstance(nodo, dict):
        return
    if nodo.get("t") in MARCAS:
        hijos = nodo.get("c") or []
        if isinstance(hijos, list) and hijos:
            borde = hijos[0].get("t") in ESPACIOS or hijos[-1].get("t") in ESPACIOS
            if borde:
                hallazgos.append((nodo["t"], texto(hijos)))
    for v in nodo.values():
        if isinstance(v, (list, dict)):
            busca(v, hallazgos)


def linea_de(ruta, fragmento):
    """La línea del fichero donde está el fragmento.

    Se comparan las dos partes sin asteriscos: el fragmento sale del árbol y ya
    no los lleva, mientras que en el fichero siguen puestos y justo en medio.
    Buscar sólo la primera palabra no vale —«Gradiente» está en varias líneas
    seguidas y todas las anidaciones se apuntaban a la primera.
    """
    aguja = fragmento.strip()
    if not aguja:
        return 1
    with open(ruta, encoding="utf-8") as f:
        for n, linea in enumerate(f, 1):
            if aguja in linea.replace("*", ""):
                return n
    return 1


def main():
    ficheros = sorted(glob.glob("0*/*.qmd"))
    if not ficheros:
        print("::error::No se encontró ningún .qmd; el guardián no comprobaría nada")
        return 1

    errores = 0
    for ruta in ficheros:
        r = subprocess.run(
            ["quarto", "pandoc", ruta, "--from=markdown", "--to=json"],
            capture_output=True, text=True,
        )
        if r.returncode != 0:
            print(f"::error file={ruta}::No se pudo analizar: {r.stderr.strip()[:200]}")
            errores += 1
            continue

        hallazgos = []
        busca(json.loads(r.stdout).get("blocks", []), hallazgos)
        for marca, t in hallazgos:
            n = linea_de(ruta, t)
            corto = t.strip()[:60]
            print(
                f"::error file={ruta},line={n}::{marca} que empieza o acaba en "
                f"espacio: «{corto}». Suele ser negrita dentro de negrita; el "
                f"término interior va en cursiva."
            )
            errores += 1

    print(f"Analizados {len(ficheros)} .qmd; {errores} problemas.")
    return 1 if errores else 0


if __name__ == "__main__":
    sys.exit(main())
