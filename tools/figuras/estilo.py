"""Estilo común de las figuras técnicas de la colección.

Recoge en un solo sitio lo que `GUIA_ILUSTRACIONES.md` fija como identidad
gráfica, para que dos figuras hechas con meses de diferencia salgan iguales:
fondo blanco y plano, estructura en azul navy, texto en gris, y la paleta
técnica cerrada (sustentación, resistencia, peso, tracción, zona segura,
atención).

⚠️ La tipografía es **Libertinus Sans y sólo Libertinus Sans**, cargada desde
`recursos/fuentes/`. No se usa la instalada en el sistema: matplotlib, igual que
Typst, cae a otra fuente en silencio si no la encuentra, y así el fallo sería
invisible hasta ver el PDF publicado. `usar_estilo()` aborta si los ficheros no
están donde deben.

⚠️ El tamaño mínimo de texto es 9 pt **al tamaño final impreso**. Como estas
figuras se insertan a ~15 cm de ancho, se dibujan a esa medida en pulgadas y se
exporta a 220 ppp: lo que aquí se declara en puntos es lo que se lee en el papel.
"""

from pathlib import Path

import matplotlib
matplotlib.use("Agg")

from matplotlib import font_manager
import matplotlib.pyplot as plt

RAIZ = Path(__file__).resolve().parent.parent.parent
FUENTES = RAIZ / "recursos" / "fuentes"

# Identidad gráfica (GUIA_ILUSTRACIONES.md, «Identidad gráfica»).
FONDO = "#FFFFFF"
ESTRUCTURA = "#003366"
TEXTO = "#333333"

# Paleta técnica cerrada. Ámbar y naranja no coexisten en una misma figura.
SUSTENTACION = "#0066CC"
RESISTENCIA = "#CC0000"
PESO = "#333333"
TRACCION = "#FF6600"
SEGURA = "#2E7D32"
ATENCION = "#B26A00"

# El viento se dibuja en azul o con flecha hueca; aquí, azul.
VIENTO = SUSTENTACION

# Ancho de caja de la colección: A4 menos 2,5 cm de margen a cada lado = 16 cm.
# Las figuras se insertan con `width="100%"`, así que ése es su ancho impreso.
#
# ⚠️ El dibujo se compone a 15 cm y se publica a 16: el texto crece un 7 %, que
# es el lado bueno del error. Lo que no puede pasar es lo contrario, y pasa
# solo: `bbox_inches="tight"` **agranda** el lienzo cuando una etiqueta se sale
# de los límites de los ejes, y entonces la figura entera se comprime al entrar
# en la caja, encogiendo su texto por debajo del mínimo legible. `guardar()`
# aborta si eso ocurre.
ANCHO_PULGADAS = 15 / 2.54
ANCHO_CAJA_CM = 16.0
ANCHO_MAXIMO_PULGADAS = 6.3   # a partir de aquí, 9 pt caen por debajo de 9 pt

# 330 ppp sobre ~5,5 pulgadas de recorte dan ~1.800 px, holgadamente por encima
# del mínimo que pide la guía para 15 cm (ancho_mm / 25,4 x 220 ≈ 1.300 px).
PPP = 330

# Cuerpo base. 9 pt es el mínimo legible al tamaño final; las etiquetas
# secundarias no bajan de ahí.
CUERPO = 10
MENOR = 9


def usar_estilo():
    """Registra Libertinus Sans y fija los valores por defecto de matplotlib."""
    caras = sorted(FUENTES.glob("LibertinusSans-*.otf"))
    if not caras:
        raise SystemExit(
            f"No hay ninguna Libertinus Sans en {FUENTES}. "
            "Sin ella la figura saldría en otra fuente sin avisar."
        )
    for cara in caras:
        font_manager.fontManager.addfont(str(cara))

    plt.rcParams.update({
        "font.family": "Libertinus Sans",
        "font.size": CUERPO,
        "text.color": TEXTO,
        "axes.labelcolor": TEXTO,
        "axes.edgecolor": ESTRUCTURA,
        "xtick.color": TEXTO,
        "ytick.color": TEXTO,
        "figure.facecolor": FONDO,
        "axes.facecolor": FONDO,
        "savefig.facecolor": FONDO,
        "figure.dpi": PPP,
        "savefig.dpi": PPP,
        # Plano: ni sombras, ni degradados, ni texturas.
        "axes.grid": False,
        "legend.frameon": False,
    })


def lienzo(alto_relativo=0.62):
    """Figura del ancho impreso estándar, sin ejes ni marco.

    La mayoría de estos diagramas son esquemas, no gráficas: no llevan ejes
    cartesianos y se componen en coordenadas de datos libres.
    """
    fig, ax = plt.subplots(
        figsize=(ANCHO_PULGADAS, ANCHO_PULGADAS * alto_relativo)
    )
    ax.set_axis_off()
    ax.set_aspect("equal")
    return fig, ax


def guardar(fig, destino):
    """Escribe el PNG, sin metadatos y sin margen sobrante.

    Comprueba después que el lienzo recortado no se ha ido de ancho. Es la única
    forma de garantizar el mínimo de 9 pt sobre el papel: si una etiqueta se sale
    de los límites de los ejes, `bbox_inches="tight"` ensancha la figura, ésta se
    comprime al ajustarse a la caja de texto y su tipografía encoge en la misma
    proporción. No da ningún aviso, y sólo se ve midiendo el PDF.
    """
    destino = Path(destino)
    destino.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(
        destino,
        format="png",
        bbox_inches="tight",
        pad_inches=0.08,
        metadata={"Software": None},
    )
    plt.close(fig)

    # Y se rellena hasta un ancho de lienzo FIJO, con blanco y centrado.
    #
    # Sin esto, cada figura sale con el ancho que le deje el recorte —de 4,0 a
    # 4,9 pulgadas en esta colección— y, al publicarlas todas a `width="100%"`,
    # cada una se amplía en una proporción distinta: la misma etiqueta de 10 pt
    # acabaría midiendo 13 pt en una figura y 16 en la de al lado. Es el tipo de
    # incoherencia que no se ve figura a figura y salta al hojear el libro.
    from PIL import Image

    objetivo = round(ANCHO_PULGADAS * PPP)
    with Image.open(destino) as im:
        ancho, alto = im.size
        if ancho > ANCHO_MAXIMO_PULGADAS * PPP:
            cuerpo_final = CUERPO * (ANCHO_CAJA_CM / (ancho / PPP * 2.54))
            raise SystemExit(
                f"{destino.name}: el lienzo mide {ancho / PPP:.2f} pulgadas "
                f"({ancho} px) y el máximo son {ANCHO_MAXIMO_PULGADAS}. "
                f"Al entrar en la caja de {ANCHO_CAJA_CM} cm, el cuerpo de "
                f"{CUERPO} pt quedaría en {cuerpo_final:.1f} pt. "
                "Mete las etiquetas dentro de los límites de los ejes o amplía "
                "xlim/ylim para que el recorte no ensanche la figura."
            )
        if ancho < objetivo:
            lienzo_fijo = Image.new("RGB", (objetivo, alto), FONDO)
            lienzo_fijo.paste(im.convert("RGB"), ((objetivo - ancho) // 2, 0))
            lienzo_fijo.save(destino, format="png", optimize=True)
    return destino
