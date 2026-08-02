#!/usr/bin/env python3
"""Comprueba que los glosarios están alfabetizados.

Un glosario desordenado no rompe la compilación ni salta a la vista: son 414
entradas repartidas en nueve ficheros, y una que se cuele dos posiciones más
abajo sólo la descubre quien la busque con el dedo y no la encuentre. Han
aparecido siete así.

El criterio es **el texto visible del rótulo hasta el primer paréntesis**, sin
tildes, sin la marca de subíndice y sin distinguir mayúsculas:

    **V~A~ (Velocidad de maniobra / Maneuvering Speed)**   ->  "va"
    **Centro de Presiones (CP)**                           ->  "centro de presiones"
    **L'Hotellier (Conector)**                             ->  "lhotellier"

Es lo que el lector persigue al recorrer la columna, y no lo que hay dentro del
paréntesis. Por eso `CG` va después de `Centro de Presiones` aunque hablen de lo
mismo, y por eso las velocidades V no quedan agrupadas: `V~NE~` cae detrás de
`Viento relativo`.

Uso:
    python3 .github/comprobar-orden-glosario.py [fichero.qmd ...]

Sin argumentos recorre `*/glosario.qmd`. Sale con 1 si algún glosario está
desordenado, e imprime sólo los pares que no respetan el orden.
"""
import importlib.util
import re
import sys
from pathlib import Path

ROTULO = re.compile(r"^\*\*(.+?)\*\*$")

# La clave se importa de tools/consolidar-completo.py, que es quien ordena el
# glosario unificado. Con una copia aquí, los dos criterios divergirían y este
# guardián acabaría dando por desordenado lo que aquel script acaba de
# escribir. El importlib es por el guion del nombre del fichero, que impide un
# import normal.
_spec = importlib.util.spec_from_file_location(
    "consolidar_completo", Path(__file__).resolve().parent.parent / "tools" / "consolidar-completo.py"
)
_cc = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_cc)
clave = _cc.clave_glosario


def rotulos_de(ruta):
    """Rótulos del glosario, con su número de línea."""
    salida = []
    for n, linea in enumerate(ruta.read_text(encoding="utf-8").splitlines(), 1):
        m = ROTULO.match(linea.strip())
        if m:
            salida.append((n, m.group(1)))
    return salida


def main(argv):
    rutas = [Path(a) for a in argv[1:]] or sorted(Path(".").glob("*/glosario.qmd"))
    if not rutas:
        print("No se ha encontrado ningún glosario que comprobar.", file=sys.stderr)
        return 1

    problemas = 0
    for ruta in rutas:
        rotulos = rotulos_de(ruta)
        if not rotulos:
            print(f"{ruta}: sin entradas; ¿ha cambiado el formato del glosario?", file=sys.stderr)
            problemas += 1
            continue
        for (n1, r1), (n2, r2) in zip(rotulos, rotulos[1:]):
            if clave(r1) > clave(r2):
                print(f"{ruta}:{n2}: «{r2}» debería ir antes que «{r1}» (línea {n1})")
                problemas += 1

    total = sum(len(rotulos_de(r)) for r in rutas)
    if problemas:
        print(f"\n{problemas} entradas fuera de orden en {len(rutas)} glosarios ({total} entradas).")
        return 1
    print(f"Comprobados {len(rutas)} glosarios, {total} entradas: orden alfabético correcto.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
