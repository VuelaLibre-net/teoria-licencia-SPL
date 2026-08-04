#!/usr/bin/env python3
"""Figuras técnicas del libro 07 — Planificación y Rendimiento de Vuelo.

⚠️ **Todas las cifras salen del propio capítulo.** No hay ni un dato inventado
ni redondeado a ojo: los cuatro casos de centrado son los que el cap01 calcula,
la regla del 2 % por 300 m es la que enuncia el cap02 y los márgenes de +300 m
y +150 m son los del método de los tres puntos del cap05. Si el texto cambia una
cifra, hay que cambiarla aquí y regenerar; por eso van juntas en un solo fichero
y con la fuente anotada en cada función.

Es también la razón de dibujarlas por código y no con un generador de imágenes:
`GUIA_ILUSTRACIONES.md` reserva la IA para los diagramas conceptuales y la
prohíbe en los gráficos cuantitativos, que «se construyen desde datos
verificables». Estos tres lo son.

Uso:
    python3 tools/figuras/07_planificacion.py [nombre ...]
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import matplotlib.patches as mpatches
import numpy as np

from estilo import (
    ATENCION, ESTRUCTURA, MENOR, RESISTENCIA, SEGURA, SUSTENTACION, TEXTO,
    guardar, lienzo, usar_estilo,
)

DESTINO = Path(__file__).resolve().parent.parent.parent / "07-planificacion-rendimiento" / "imagenes"


# --------------------------------------------------------------------------
# cap01 — La envolvente de centrado
# --------------------------------------------------------------------------
def envolvente_centrado():
    """Masa contra posición del CG, con los cuatro casos que calcula el cap01.

    Fuente de cada dato (cap01-masa-y-centro-de-gravedad.qmd):
      * Rango permitido +0,25 a +0,38 m, «Ejemplo práctico de hoja de centrado».
      * Piloto de 85 kg: 350 kg y CG +0,31 m, misma sección.
      * Piloto de 60 kg: 325 kg y CG +0,37 m, misma sección.
      * Ejercicio 1, sin lastre de cola: 460 kg y CG +0,335 m.
      * Ejercicio 1, con 5 litros en la cola: 465 kg y CG +0,373 m.
    """
    limite_adelante, limite_atras = 0.25, 0.38
    # Cada caso lleva su propio desplazamiento de rótulo: los cuatro puntos
    # caen en dos parejas muy juntas y, colocados todos igual, se pisan.
    casos = [
        (0.31, 350, "piloto 85 kg", SEGURA, (0.004, 0), "left", "center"),
        (0.37, 325, "piloto 60 kg", ATENCION, (-0.004, 0), "right", "center"),
        (0.335, 460, "alas con agua,\nsin lastre de cola", SEGURA, (0, -9), "center", "top"),
        (0.373, 465, "con 5 L en la cola", ATENCION, (0, 9), "center", "bottom"),
    ]

    fig, ax = lienzo(0.62)
    ax.set_axis_on()
    ax.set_aspect("auto")

    y0, y1 = 300, 490
    ax.add_patch(mpatches.Rectangle(
        (limite_adelante, y0), limite_atras - limite_adelante, y1 - y0,
        facecolor=SEGURA, alpha=0.10, edgecolor=SEGURA, lw=1.6, zorder=1))
    for x, etq in ((limite_adelante, "límite\nadelantado"), (limite_atras, "límite\natrasado")):
        ax.axvline(x, color=SEGURA, lw=1.6, zorder=2)
        ax.text(x, y1 + 4, etq, fontsize=MENOR - 1, color=SEGURA, fontweight="bold",
                ha="center", va="bottom")

    for x, y, etq, color, (dx, dy), ha, va in casos:
        ax.plot(x, y, "o", ms=9, color=color, zorder=5)
        ax.text(x + dx, y + dy, etq, fontsize=MENOR, color=color, fontweight="bold",
                ha=ha, va=va, zorder=6)

    # Las dos parejas se unen para que se vea el sentido del movimiento.
    for a, b in ((0, 1), (2, 3)):
        ax.annotate("", xy=(casos[b][0], casos[b][1]), xytext=(casos[a][0], casos[a][1]),
                    arrowprops=dict(arrowstyle="->", color=TEXTO, lw=1.1,
                                    ls=(0, (3, 2))), zorder=4)

    ax.set_xlabel("posición del centro de gravedad tras el datum (m)")
    ax.set_ylabel("masa total (kg)")
    ax.set_xlim(0.225, 0.405)
    ax.set_ylim(y0, y1 + 34)
    ax.set_xticks([0.25, 0.28, 0.31, 0.34, 0.37, 0.40])
    ax.set_xticklabels(["0,25", "0,28", "0,31", "0,34", "0,37", "0,40"])
    for lado in ("top", "right"):
        ax.spines[lado].set_visible(False)

    ax.text(0.225, y0 - 46,
            "Los cuatro casos que calcula este capítulo, sobre el rango permitido. Las dos\n"
            "flechas marcan el sentido del cambio: un piloto más ligero atrasa el CG, y el\n"
            "lastre de cola lo atrasa a propósito hasta rozar el límite.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")
    return guardar(fig, DESTINO / "07-cap01-envolvente-centrado.png")


# --------------------------------------------------------------------------
# cap02 — Lo que separa la IAS de la TAS al subir
# --------------------------------------------------------------------------
def ias_tas_altitud():
    """La regla del 2 % por cada 300 m, dibujada.

    Fuente (cap02…qmd, «IAS y TAS: cuando el anemómetro te mienteal»): «la TAS
    supera a la IAS en un 2 % por cada 300 m de altitud», y el capítulo sitúa los
    aeródromos de la meseta en torno a 1.000 m y el vuelo de térmica o de onda
    entre 2.000 y 4.000 m.
    """
    ias = 100.0                      # km/h indicados, valor de referencia
    alturas = np.linspace(0, 4000, 200)
    tas = ias * (1 + 0.02 * alturas / 300)

    fig, ax = lienzo(0.62)
    ax.set_axis_on()
    ax.set_aspect("auto")

    ax.plot(tas, alturas, lw=2.4, color=SUSTENTACION, zorder=4)
    ax.axvline(ias, lw=1.6, ls=(0, (5, 4)), color=ESTRUCTURA, zorder=3)
    ax.text(ias - 1.6, 2150, "IAS\nlo que marca\nel anemómetro",
            fontsize=MENOR, color=ESTRUCTURA, fontweight="bold", ha="right", va="center")
    ax.text(tas[-1] + 1.2, 2150, "TAS\nlo que vuelas\nde verdad",
            fontsize=MENOR, color=SUSTENTACION, fontweight="bold", ha="left", va="center")

    for h, etq, dy in ((1000, "meseta española:\naeródromos a ~1.000 m", -230),
                       (4000, "techo de onda", -230)):
        t = ias * (1 + 0.02 * h / 300)
        ax.plot([ias, t], [h, h], lw=1.2, color=ATENCION, zorder=5)
        ax.plot(t, h, "o", ms=7, color=ATENCION, zorder=6)
        ax.text(t + 0.9, h + dy, f"+{t - ias:.0f} %  {etq}", fontsize=MENOR - 1,
                color=ATENCION, fontweight="bold", ha="left", va="top")

    ax.set_xlabel("velocidad (km/h) para una IAS de 100 km/h", labelpad=14)
    ax.set_ylabel("altitud (m)")
    ax.set_xlim(88, 136)
    ax.set_xticks([95, 100, 105, 110, 115, 120, 125, 130, 135])
    ax.set_ylim(0, 4300)
    for lado in ("top", "right"):
        ax.spines[lado].set_visible(False)

    ax.text(88, -900,
            "Regla del capítulo: la TAS supera a la IAS un 2 % por cada 300 m. La polar del\n"
            "manual está trazada en IAS, así que el anemómetro sigue sirviendo para volarla;\n"
            "lo que cambia es la velocidad real sobre el terreno y, con ella, el alcance.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")
    return guardar(fig, DESTINO / "07-cap02-ias-tas-altitud.png")


# --------------------------------------------------------------------------
# cap05 — El método de los tres puntos
# --------------------------------------------------------------------------
def metodo_tres_puntos():
    """Margen de llegada frente a distancia recorrida, con las dos trazas.

    Fuente (cap05…qmd, «Monitoreo del planeo final: el método de los 3 puntos»):
    llegada calculada con +300 m; en el punto medio, «si el margen se mantiene en
    torno a +300 m» la masa de aire se comporta como se esperaba, y «si ha bajado
    a +150 m y sigue cayendo» hay que buscar alternativa; tercera comprobación «a
    unos 5 km del destino».
    """
    tramo = 40.0                     # km, tramo de ejemplo para situar los 5 km
    x = np.linspace(0, tramo, 200)
    sana = 300 + 0 * x
    degradada = 300 - 150 * (x / (tramo / 2))          # 300 → 150 en el punto medio
    degradada = np.where(x <= tramo / 2, degradada, 150 - 150 * (x - tramo / 2) / (tramo / 2))

    fig, ax = lienzo(0.58)
    ax.set_axis_on()
    ax.set_aspect("auto")

    ax.axhspan(0, 300, color=ATENCION, alpha=0.08, zorder=0)
    ax.axhline(300, lw=1.4, ls=(0, (5, 4)), color=SEGURA, zorder=2)
    ax.text(0.4, 312, "margen de llegada previsto: +300 m", fontsize=MENOR,
            color=SEGURA, fontweight="bold", ha="left", va="bottom")

    ax.plot(x, sana, lw=2.6, color=SEGURA, zorder=4)
    ax.plot(x, degradada, lw=2.6, color=RESISTENCIA, zorder=4)

    for xp, etq in ((0, "1. al iniciar\nel planeo final"),
                    (tramo / 2, "2. en el punto medio"),
                    (tramo - 5, "3. a 5 km\ndel destino")):
        ax.axvline(xp, lw=1.0, ls=(0, (2, 3)), color=ESTRUCTURA, alpha=0.6, zorder=1)
        ax.text(xp, -95, etq, fontsize=MENOR - 1, color=ESTRUCTURA,
                ha="center", va="top")
    for xp in (0, tramo / 2, tramo - 5):
        ax.plot(xp, 300, "o", ms=7, color=SEGURA, zorder=6)
        ax.plot(xp, float(np.interp(xp, x, degradada)), "o", ms=7, color=RESISTENCIA, zorder=6)

    ax.text(tramo * 0.60, 322, "el margen aguanta:\nsigues adelante", fontsize=MENOR,
            color=SEGURA, fontweight="bold", ha="left", va="bottom")
    ax.text(tramo / 2 + 1.0, 150, "+150 m y cayendo:\nbusca alternativa ya",
            fontsize=MENOR, color=RESISTENCIA, fontweight="bold", ha="left", va="bottom")

    ax.set_xlabel("distancia recorrida del planeo final (km)", labelpad=30)
    ax.set_ylabel("margen de llegada previsto (m)")
    ax.set_xlim(0, tramo)
    ax.set_ylim(-60, 420)
    for lado in ("top", "right"):
        ax.spines[lado].set_visible(False)

    ax.text(0, -235,
            "Una lectura dice dónde estás; dos comparadas dicen hacia dónde vas. Una\n"
            "descendencia continua de 0,5 m/s se pierde en el ruido del variómetro y salta a\n"
            "la vista al comparar el margen del punto inicial con el del punto medio.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")
    return guardar(fig, DESTINO / "07-cap05-metodo-tres-puntos.png")


FIGURAS = {
    "07-cap01-envolvente-centrado": envolvente_centrado,
    "07-cap02-ias-tas-altitud": ias_tas_altitud,
    "07-cap05-metodo-tres-puntos": metodo_tres_puntos,
}


def main(argv):
    usar_estilo()
    for nombre in (argv[1:] or list(FIGURAS)):
        if nombre not in FIGURAS:
            raise SystemExit(f"No conozco «{nombre}». Disponibles: {', '.join(FIGURAS)}")
        ruta = FIGURAS[nombre]()
        print(f"✓ {ruta.name} ({ruta.stat().st_size / 1024:.0f} KB)")


if __name__ == "__main__":
    main(sys.argv)
