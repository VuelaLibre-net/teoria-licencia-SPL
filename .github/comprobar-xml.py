#!/usr/bin/env python3
"""Comprueba que todos los documentos de un EPUB están bien formados como XML.

Un EPUB es XHTML, no HTML5, y esa diferencia no es cosmética: un parser XML
interpreta las etiquetas dentro de `<style>`, mientras que HTML5 trata ese
contenido como texto. Así que un `<div class="...">` escrito dentro de un
comentario CSS —para documentar el propio CSS— abre un elemento que nunca se
cierra, y el documento deja de estar bien formado.

Pasó de verdad: nueve EPUB se publicaron con ese defecto. Quarto compilaba sin
una queja y los demás guardianes buscaban sobre el texto ya despojado de
etiquetas, donde esto es literalmente invisible.

Va en un fichero aparte y no incrustado en el workflow porque un heredoc de
python dentro de un `run:` de YAML depende de una indentación que nadie ve, y
al primer retoque deja de ejecutarse sin avisar.
"""

import sys
import zipfile
import xml.dom.minidom as md

EXTENSIONES = ('.xhtml', '.opf', '.ncx')


def main(ruta: str) -> int:
    mal = []
    with zipfile.ZipFile(ruta) as z:
        nombres = [n for n in z.namelist() if n.endswith(EXTENSIONES)]
        # Un EPUB sin documentos que mirar no es un EPUB válido: sin esto, el
        # bucle no daría una vuelta y la comprobación pasaría en vacío.
        if not nombres:
            print(f"    {ruta}: no contiene ningún documento XML")
            return 1
        for n in nombres:
            try:
                md.parseString(z.read(n))
            except Exception as e:
                mal.append(f"{n}: {e}")
    for m in mal[:5]:
        print(f"    {m}")
    if len(mal) > 5:
        print(f"    … y {len(mal) - 5} más")
    return 1 if mal else 0


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit("uso: comprobar-xml.py <fichero.epub>")
    sys.exit(main(sys.argv[1]))
