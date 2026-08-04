#!/usr/bin/env python3
"""Figuras técnicas del libro 09 — Navegación.

Se dibujan con matplotlib y no con un generador de imágenes por dos razones que
`GUIA_ILUSTRACIONES.md` deja claras: los gráficos cuantitativos se construyen
**desde los datos**, no se generan ni se retocan; y las etiquetas tienen que
decir cifras exactas, que es justo lo que una IA no garantiza.

Cada función devuelve el nombre de archivo que le corresponde. El ID de la
figura en el `.qmd` es `fig-` + ese nombre sin extensión, como manda la guía
para toda figura nueva.

Uso:
    python3 tools/figuras/09_navegacion.py [nombre ...]

Sin argumentos las genera todas en `09-navegacion/imagenes/`.
"""

import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import matplotlib.patches as mpatches
import numpy as np

from estilo import (
    ATENCION, CUERPO, ESTRUCTURA, MENOR, RESISTENCIA, SEGURA, SUSTENTACION,
    TEXTO, VIENTO, guardar, lienzo, usar_estilo,
)

DESTINO = Path(__file__).resolve().parent.parent.parent / "09-navegacion" / "imagenes"


def rumbo(grados, longitud=1.0):
    """Vector cartesiano de un rumbo en grados (0º = norte, sentido horario)."""
    r = math.radians(grados)
    return np.array([math.sin(r), math.cos(r)]) * longitud


def flecha(ax, origen, vector, color, ancho=2.2, estilo="-|>", zorder=3, **kw):
    ax.annotate(
        "", xy=tuple(np.asarray(origen) + np.asarray(vector)), xytext=tuple(origen),
        arrowprops=dict(arrowstyle=estilo, color=color, lw=ancho,
                        shrinkA=0, shrinkB=0, mutation_scale=16),
        zorder=zorder, **kw,
    )


def rotulo(ax, punto, texto, color=TEXTO, tam=MENOR, peso="normal", **kw):
    ax.text(punto[0], punto[1], texto, color=color, fontsize=tam,
            fontweight=peso, zorder=5, **kw)


# --------------------------------------------------------------------------
# cap04 — El triángulo de velocidades, acotado en km/h y en nudos
# --------------------------------------------------------------------------
def triangulo_velocidades():
    """Reemplaza la ilustración provisional `09-cap04-triangulo-viento`.

    El informe de auditoría pedía expresamente un triángulo **acotado en km/h y
    nudos**: la versión anterior no llevaba ni una cifra, y el capítulo enseña a
    calcularlas.
    """
    tc = 90.0          # trayectoria verdadera deseada
    tas = 100.0        # km/h
    viento_de = 40.0   # el viento sopla DESDE este rumbo
    v_viento = 30.0    # km/h

    alfa = math.radians(tc - viento_de)
    cruzado = v_viento * math.sin(alfa)
    frente = v_viento * math.cos(alfa)
    wca = math.degrees(math.asin(cruzado / tas))
    th = tc - wca
    gs = tas * math.cos(math.radians(wca)) - frente

    fig, ax = lienzo(0.60)
    escala = 1 / 100.0
    origen = np.array([0.0, 0.0])
    v_tas = rumbo(th, tas * escala)
    v_wind = rumbo(viento_de + 180, v_viento * escala)
    v_gs = rumbo(tc, gs * escala)

    # Trayectoria deseada, de fondo y discontinua: es la línea sobre el suelo.
    fin = rumbo(tc, 1.02)
    ax.plot([0, fin[0]], [0, fin[1]], ls=(0, (6, 4)), lw=1.2,
            color=ESTRUCTURA, alpha=0.55, zorder=1)
    rotulo(ax, fin + np.array([0.03, 0.0]), "trayectoria deseada",
           color=ESTRUCTURA, ha="left", va="center")

    flecha(ax, origen, v_tas, ESTRUCTURA, 2.6)
    flecha(ax, v_tas, v_wind, VIENTO, 2.6)
    flecha(ax, origen, v_gs, SEGURA, 2.6)

    rotulo(ax, v_tas * 0.50 + np.array([-0.02, 0.06]),
           f"rumbo y TAS\n{tas:.0f} km/h ({tas / 1.852:.0f} kt)",
           color=ESTRUCTURA, peso="bold", ha="center", va="bottom")
    rotulo(ax, v_tas + np.array([0.05, 0.02]),
           f"viento {viento_de:03.0f}º / {v_viento:.0f} km/h "
           f"({v_viento / 1.852:.0f} kt)",
           color=VIENTO, peso="bold", ha="left", va="bottom")
    rotulo(ax, v_gs * 0.50 + np.array([0.0, -0.06]),
           f"ruta y GS\n{gs:.0f} km/h ({gs / 1.852:.0f} kt)",
           color=SEGURA, peso="bold", ha="center", va="top")

    # El ángulo de corrección, marcado como arco entre los dos vectores.
    radio = 0.30
    arco = mpatches.Arc((0, 0), 2 * radio, 2 * radio, angle=0,
                        theta1=90 - tc, theta2=90 - th, lw=1.6,
                        color=ATENCION, zorder=4)
    ax.add_patch(arco)
    rotulo(ax, rumbo((tc + th) / 2, radio) + np.array([0.05, 0.0]),
           f"WCA {wca:.0f}º", color=ATENCION, peso="bold",
           ha="left", va="center")

    ax.text(-0.02, -0.30,
            "El viento entra por la izquierda: el morro se mete al viento "
            f"{wca:.0f}º y la velocidad\nsuelo baja de {tas:.0f} a {gs:.0f} km/h. "
            "Los tres vectores están a la misma escala.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")

    ax.set_xlim(-0.06, 1.55)
    ax.set_ylim(-0.46, 0.40)
    return guardar(fig, DESTINO / "09-cap04-triangulo-velocidades.png")


# --------------------------------------------------------------------------
# cap04 — La regla del 1 en 60 y el ángulo de cierre
# --------------------------------------------------------------------------
def regla_1_en_60():
    """El error cometido y el ángulo de cierre, que es lo que se olvida.

    La regla popular «dobla el error» sólo vale a mitad de tramo, y la figura
    lo enseña con las dos distancias marcadas por separado.
    """
    fig, ax = lienzo(0.52)
    salida = np.array([0.0, 0.0])
    destino = np.array([8.0, 0.0])
    posicion = np.array([4.0, 0.62])   # 4 de 8 recorridas, desviado a la izq.

    ax.plot([salida[0], destino[0]], [salida[1], destino[1]],
            ls=(0, (6, 4)), lw=1.3, color=ESTRUCTURA, alpha=0.6, zorder=1)
    ax.plot([salida[0], posicion[0]], [salida[1], posicion[1]],
            lw=2.2, color=RESISTENCIA, zorder=3)
    ax.plot([posicion[0], destino[0]], [posicion[1], destino[1]],
            lw=2.2, color=SEGURA, zorder=3)
    ax.plot([posicion[0], posicion[0]], [0, posicion[1]],
            lw=1.1, color=ATENCION, ls=(0, (2, 2)), zorder=2)

    for punto, txt, ha in ((salida, "salida", "right"), (destino, "destino", "left")):
        ax.plot(*punto, "o", ms=7, color=ESTRUCTURA, zorder=4)
        rotulo(ax, punto + np.array([0.18 if ha == "left" else -0.18, -0.30]),
               txt, color=ESTRUCTURA, peso="bold", ha=ha, va="center")
    ax.plot(*posicion, "o", ms=7, color=RESISTENCIA, zorder=4)
    rotulo(ax, posicion + np.array([0.0, 0.16]), "posición real",
           color=RESISTENCIA, peso="bold", ha="center", va="bottom")

    rotulo(ax, np.array([4.12, 0.31]), "desvío\n2 NM", color=ATENCION,
           ha="left", va="center")
    rotulo(ax, np.array([2.0, -0.26]), "recorrido 20 NM", color=RESISTENCIA,
           ha="center", va="top")
    rotulo(ax, np.array([6.0, -0.26]), "restante 20 NM", color=SEGURA,
           ha="center", va="top")

    ax.annotate("", xy=(3.9, -0.16), xytext=(0.1, -0.16),
                arrowprops=dict(arrowstyle="<->", color=RESISTENCIA, lw=1.1))
    ax.annotate("", xy=(7.9, -0.16), xytext=(4.1, -0.16),
                arrowprops=dict(arrowstyle="<->", color=SEGURA, lw=1.1))

    # Los ángulos se rotulan por encima de su lado. Nada de arcos: el desvío va
    # exagerado en vertical —2 NM en 20 no se verían— y un arco daría a entender
    # una escala angular que la figura no tiene.
    rotulo(ax, np.array([1.55, 0.30]), "error 6º", color=RESISTENCIA,
           peso="bold", ha="center", va="bottom")
    rotulo(ax, np.array([6.45, 0.30]), "cierre 6º", color=SEGURA,
           peso="bold", ha="center", va="bottom")

    ax.text(0.0, -0.62,
            "Error = desvío × 60 / recorrido.  Cierre = desvío × 60 / restante.\n"
            "La corrección total es la suma: aquí 12º. «Doblar el error» sólo "
            "coincide\nporque se ha recorrido justo la mitad del tramo.\n"
            "El desvío va exagerado en vertical: 2 NM en 20 no se verían.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")

    ax.set_xlim(-0.9, 8.9)
    ax.set_ylim(-1.35, 1.05)
    return guardar(fig, DESTINO / "09-cap04-regla-1-en-60.png")


# --------------------------------------------------------------------------
# cap04 — La cara del viento del computador circular
# --------------------------------------------------------------------------
def computador_cara_viento():
    """Esquema didáctico, sin marcas ni logotipos: no es una foto de producto."""
    fig, ax = lienzo(0.82)
    centro = np.array([0.0, 0.0])
    radio = 1.0

    ax.add_patch(mpatches.Circle(centro, radio, fill=False, lw=2.0,
                                 color=ESTRUCTURA, zorder=3))
    # Los grados van por dentro del aro: por fuera chocarían con el índice.
    for grados in range(0, 360, 30):
        p1 = rumbo(grados, radio)
        p2 = rumbo(grados, radio * 0.95)
        ax.plot([p1[0], p2[0]], [p1[1], p2[1]], lw=1.0, color=ESTRUCTURA)
        rotulo(ax, rumbo(grados, radio * 0.87), f"{grados:03d}",
               ha="center", va="center", tam=MENOR - 1)

    # Arcos de TAS: las circunferencias concéntricas de la regleta. Se rotulan
    # hacia el suroeste, lejos de la marca del viento y de su cota.
    for r, etq in ((0.30, "60"), (0.50, "80"), (0.70, "100")):
        ax.add_patch(mpatches.Circle(centro, r, fill=False, lw=0.9,
                                     color=ESTRUCTURA, alpha=0.35, zorder=2))
        rotulo(ax, rumbo(212, r), etq, tam=MENOR - 1, color=ESTRUCTURA,
               ha="center", va="center",
               bbox=dict(boxstyle="square,pad=0.12", fc="#FFFFFF", ec="none"))
    rotulo(ax, rumbo(212, 0.88) + np.array([-0.30, -0.18]),
           "arcos de TAS (km/h)", tam=MENOR - 1,
           color=ESTRUCTURA, ha="center", va="center",
           bbox=dict(boxstyle="square,pad=0.12", fc="#FFFFFF", ec="none"))

    # Índice superior.
    ax.plot([0, 0], [radio, radio * 1.16], lw=2.4, color=ATENCION, zorder=4)
    rotulo(ax, np.array([0.0, radio * 1.34]), "índice: aquí va la trayectoria",
           color=ATENCION, peso="bold", ha="center", va="bottom")

    # Ojal central, rotulado con línea de guía para no tapar los arcos.
    ax.plot(*centro, "o", ms=8, color=ESTRUCTURA, zorder=6)
    ax.annotate("ojal: se lee la\nvelocidad suelo",
                xy=(0, 0), xytext=(1.32, -0.38), fontsize=MENOR,
                color=ESTRUCTURA, fontweight="bold", ha="left", va="center",
                arrowprops=dict(arrowstyle="-", color=ESTRUCTURA, lw=1.0),
                zorder=6)

    # La marca del viento y su desplazamiento lateral (el WCA).
    marca = np.array([0.26, 0.62])
    ax.plot(*marca, "x", ms=11, mew=2.4, color=VIENTO, zorder=6)
    ax.annotate("marca del viento",
                xy=tuple(marca), xytext=(1.32, 0.92), fontsize=MENOR,
                color=VIENTO, fontweight="bold", ha="left", va="center",
                arrowprops=dict(arrowstyle="-", color=VIENTO, lw=1.0),
                zorder=6)
    ax.plot([0, marca[0]], [marca[1], marca[1]], lw=1.4, ls=(0, (3, 2)),
            color=ATENCION, zorder=5)
    ax.annotate("desplazamiento\nlateral = WCA",
                xy=(marca[0] / 2, marca[1]), xytext=(-1.28, 0.92),
                fontsize=MENOR, color=ATENCION, fontweight="bold",
                ha="right", va="center",
                arrowprops=dict(arrowstyle="-", color=ATENCION, lw=1.0),
                zorder=6)

    ax.text(-1.95, -1.32,
            "Cara del viento (esquema). 1) La dirección del viento en el índice y se "
            "marca\nsu intensidad desde el centro.  2) Se gira la trayectoria al "
            "índice.\n3) Se desliza la regleta hasta que la marca caiga en el arco de "
            "la TAS.\nSe leen la velocidad suelo bajo el ojal y el WCA en el "
            "desplazamiento lateral.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")

    ax.set_xlim(-1.98, 1.98)
    ax.set_ylim(-2.10, 1.60)
    return guardar(fig, DESTINO / "09-cap04-computador-cara-viento.png")


# --------------------------------------------------------------------------
# cap01 — El minuto de latitud es una milla náutica
# --------------------------------------------------------------------------
def minuto_de_latitud():
    """De dónde sale la equivalencia que sostiene medio capítulo.

    La regla «1 minuto de latitud = 1 NM» se enuncia en todos los manuales y
    casi nunca se dibuja. Aquí se ve por qué vale sobre el meridiano y por qué
    NO vale sobre los paralelos.
    """
    fig, ax = lienzo(0.72)
    r = 1.0
    ax.add_patch(mpatches.Circle((0, 0), r, fill=False, lw=1.8,
                                 color=ESTRUCTURA, zorder=3))
    # Ecuador y eje.
    ax.plot([-r, r], [0, 0], lw=1.1, ls=(0, (5, 4)), color=ESTRUCTURA, alpha=0.6)
    rotulo(ax, np.array([r * 1.03, 0.0]), "ecuador", color=ESTRUCTURA,
           ha="left", va="center")
    ax.plot([0, 0], [-r * 1.12, r * 1.12], lw=1.0, ls=(0, (2, 3)),
            color=ESTRUCTURA, alpha=0.5)

    # El arco de latitud, exagerado para que se vea.
    lat0, lat1 = 38.0, 52.0
    arco = np.linspace(math.radians(lat0), math.radians(lat1), 60)
    ax.plot(r * np.cos(arco), r * np.sin(arco), lw=4.0, color=SEGURA, zorder=4,
            solid_capstyle="butt")
    for lat in (lat0, lat1):
        p = np.array([r * math.cos(math.radians(lat)), r * math.sin(math.radians(lat))])
        ax.plot([0, p[0]], [0, p[1]], lw=1.1, color=ATENCION, zorder=2)
        ax.plot(*p, "o", ms=5, color=SEGURA, zorder=5)

    medio = math.radians((lat0 + lat1) / 2)
    p_medio = np.array([r * math.cos(medio), r * math.sin(medio)])
    ax.annotate("1' de latitud = 1 NM",
                xy=tuple(p_medio), xytext=(0.98, 1.02), fontsize=MENOR,
                color=SEGURA, fontweight="bold", ha="left", va="center",
                arrowprops=dict(arrowstyle="-", color=SEGURA, lw=1.0), zorder=6)
    ax.annotate("1' de ángulo\nen el centro",
                xy=(0.36, 0.36), xytext=(0.98, 0.42), fontsize=MENOR - 1,
                color=ATENCION, ha="left", va="center",
                arrowprops=dict(arrowstyle="-", color=ATENCION, lw=0.9),
                zorder=6)

    # Un paralelo, para el contraste.
    lat_p = math.radians(41)
    rp = r * math.cos(lat_p)
    ax.plot([-rp, rp], [r * math.sin(lat_p)] * 2, lw=1.4, color=RESISTENCIA,
            ls=(0, (4, 3)), zorder=3)
    ax.annotate("paralelo 41º N:\n1' de longitud = 0,75 NM",
                xy=(-rp * 0.55, r * math.sin(lat_p)), xytext=(-0.98, 1.02),
                fontsize=MENOR, color=RESISTENCIA, fontweight="bold",
                ha="right", va="center",
                arrowprops=dict(arrowstyle="-", color=RESISTENCIA, lw=1.0),
                zorder=6)

    ax.text(-1.72, -1.30,
            "La milla náutica se definió como el minuto de arco de meridiano, y de ahí "
            "que\nun grado de latitud sean 60 NM. Los meridianos convergen hacia los "
            "polos,\nasí que la equivalencia no se traslada a la longitud: sobre un "
            "paralelo, un\nminuto vale menos, y tanto menos cuanto más al norte.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")

    ax.set_xlim(-1.75, 1.75)
    ax.set_ylim(-2.05, 1.30)
    return guardar(fig, DESTINO / "09-cap01-minuto-de-latitud.png")


# --------------------------------------------------------------------------
# cap02 — Los tres nortes y la cadena de correcciones
# --------------------------------------------------------------------------
def tres_nortes():
    """Norte verdadero, magnético y de brújula, con la cadena de signos.

    El capítulo explica variación y desvío por separado; la figura los pone
    juntos, que es como aparecen en el cálculo.
    """
    fig, ax = lienzo(0.66)
    largo = 1.0
    # ⚠️ Los ángulos van EXAGERADOS a propósito: 6º y 3º reales no se
    # distinguirían en el papel y la figura no enseñaría nada. El pie y el
    # rótulo dicen las cifras verdaderas, que es lo que el lector debe retener.
    v_verdadero, v_magnetico, v_brujula = 0.0, -24.0, -38.0

    for ang, color, etq, ha in (
        (v_verdadero, ESTRUCTURA, "Norte verdadero\n(geográfico)", "left"),
        (v_magnetico, SUSTENTACION, "Norte magnético", "center"),
        (v_brujula, RESISTENCIA, "Norte de la brújula", "right"),
    ):
        v = rumbo(ang, largo)
        flecha(ax, (0, 0), v, color, 2.4)
        rotulo(ax, rumbo(ang, largo * 1.06), etq, color=color, peso="bold",
               ha=ha, va="bottom")

    for a1, a2, radio, color, etq in (
        (v_magnetico, v_verdadero, 0.66, SUSTENTACION, "variación 3º W"),
        (v_brujula, v_magnetico, 0.42, RESISTENCIA, "desvío 2º W"),
    ):
        ax.add_patch(mpatches.Arc((0, 0), 2 * radio, 2 * radio,
                                  theta1=90 - a2, theta2=90 - a1,
                                  lw=1.8, color=color, zorder=4))
        rotulo(ax, rumbo((a1 + a2) / 2, radio) + np.array([-0.16, 0.0]),
               etq, color=color, peso="bold", ha="right", va="center")

    ax.plot(0, 0, "o", ms=7, color=ESTRUCTURA, zorder=5)

    ax.text(-1.55, -0.22,
            "Ángulos muy exagerados para que se vean: en la Península la variación "
            "ronda\n1º-3º y el desvío no suele llegar a 5º. Al Oeste, los nortes caen "
            "a la izquierda\ndel verdadero y los rumbos SUMAN: verdadero 100º → "
            "magnético 103º →\nde brújula 105º. Al Este, al revés. Es la convención "
            "(W −) / (E +) vista de frente.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")

    ax.set_xlim(-1.58, 1.58)
    ax.set_ylim(-1.15, 1.30)
    return guardar(fig, DESTINO / "09-cap02-tres-nortes.png")


# --------------------------------------------------------------------------
# cap05 — El cono de alcance y su deformación por el viento
# --------------------------------------------------------------------------
def cono_de_alcance():
    """Cómo el viento convierte el círculo de alcance en un óvalo descentrado.

    Se dibuja con las cifras del capítulo: fineza 30, 1.000 m de altura,
    TAS 90 km/h y 30 km/h de viento.
    """
    fineza, altura, tas, viento = 30, 1000, 90.0, 30.0
    r_calma = altura * fineza / 1000.0            # 30 km

    fig, ax = lienzo(0.66)
    ax.add_patch(mpatches.Circle((0, 0), r_calma, fill=False, lw=1.6,
                                 ls=(0, (5, 4)), color=ESTRUCTURA, zorder=3))

    # Alcance en cada dirección: el factor GS/TAS con el viento del oeste.
    th = np.linspace(0, 2 * np.pi, 361)
    componente = viento * np.cos(th)              # + a favor hacia el este
    radio = r_calma * (tas + componente) / tas
    ax.fill(radio * np.cos(th), radio * np.sin(th), color=SEGURA, alpha=0.13,
            zorder=1)
    ax.plot(radio * np.cos(th), radio * np.sin(th), lw=2.4, color=SEGURA,
            zorder=4)

    ax.plot(0, 0, "o", ms=9, color=ESTRUCTURA, zorder=6)
    ax.annotate("posición actual,\n1.000 m sobre el campo",
                xy=(0, 0), xytext=(6, -40), fontsize=MENOR, color=ESTRUCTURA,
                fontweight="bold", ha="left", va="center",
                arrowprops=dict(arrowstyle="-", color=ESTRUCTURA, lw=1.0),
                zorder=6)

    flecha(ax, (-56, 48), (18, 0), VIENTO, 2.6)
    rotulo(ax, np.array([-36, 48]), "viento 30 km/h", color=VIENTO,
           peso="bold", ha="left", va="center")

    ax.annotate("", xy=(-20, 0), xytext=(0, 0),
                arrowprops=dict(arrowstyle="<->", color=SEGURA, lw=1.3))
    ax.annotate("", xy=(40, 0), xytext=(0, 0),
                arrowprops=dict(arrowstyle="<->", color=SEGURA, lw=1.3))
    rotulo(ax, np.array([-10, 3.0]), "20 km contra el viento", color=SEGURA,
           peso="bold", ha="center", va="bottom")
    rotulo(ax, np.array([20, -3.0]), "40 km a favor", color=SEGURA,
           peso="bold", ha="center", va="top")
    ax.annotate("30 km en aire en calma",
                xy=(-19.3, 23.0), xytext=(-58, 34), fontsize=MENOR,
                color=ESTRUCTURA, fontweight="bold", ha="left", va="center",
                arrowprops=dict(arrowstyle="-", color=ESTRUCTURA, lw=1.0),
                zorder=6)

    ax.text(-58, -52,
            "Fineza 30 a 90 km/h de TAS. El alcance cambia en la proporción GS/TAS: el\n"
            "círculo de aire en calma se encoge contra el viento y se estira a favor.\n"
            "Todavía sin descontar el margen de llegada ni la fineza degradada.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")

    ax.set_xlim(-58, 58)
    ax.set_ylim(-66, 56)
    return guardar(fig, DESTINO / "09-cap05-cono-de-alcance.png")


# --------------------------------------------------------------------------
# cap05 — El error deliberado
# --------------------------------------------------------------------------
def error_deliberado():
    """Por qué conviene apuntar mal a propósito."""
    fig, ax = lienzo(0.56)
    objetivo = np.array([7.0, 1.1])
    salida = np.array([0.0, 0.0])

    # La referencia lineal que pasa por el objetivo (una carretera, un río).
    ax.plot([4.2, 9.4], [-1.5, 2.6], lw=3.0, color=ATENCION, alpha=0.55,
            zorder=1, solid_capstyle="round")
    rotulo(ax, np.array([9.0, 2.3]), "referencia lineal\n(carretera, río, vía)",
           color=ATENCION, ha="right", va="bottom")

    # Ruta directa: al llegar, no sabes hacia qué lado está.
    ax.plot([salida[0], objetivo[0]], [salida[1], objetivo[1]], lw=2.0,
            ls=(0, (5, 4)), color=RESISTENCIA, zorder=3)
    rotulo(ax, np.array([3.3, 0.72]), "ruta directa: al llegar,\n¿izquierda o derecha?",
           color=RESISTENCIA, peso="bold", ha="center", va="bottom")

    # Ruta con error deliberado.
    corte = np.array([5.55, -0.60])
    ax.plot([salida[0], corte[0]], [salida[1], corte[1]], lw=2.4, color=SEGURA,
            zorder=3)
    flecha(ax, corte, objetivo - corte, SEGURA, 2.4)
    rotulo(ax, np.array([2.9, -0.75]), "error deliberado: apunta a un lado",
           color=SEGURA, peso="bold", ha="center", va="top")
    rotulo(ax, np.array([7.4, -0.35]), "y al cortar la referencia,\ngira sin dudar",
           color=SEGURA, peso="bold", ha="left", va="center")

    ax.plot(*objetivo, "o", ms=8, color=ESTRUCTURA, zorder=5)
    rotulo(ax, objetivo + np.array([0.0, 0.18]), "objetivo pequeño",
           color=ESTRUCTURA, peso="bold", ha="center", va="bottom")
    ax.plot(*salida, "o", ms=8, color=ESTRUCTURA, zorder=5)
    rotulo(ax, salida + np.array([-0.15, 0.0]), "salida", color=ESTRUCTURA,
           peso="bold", ha="right", va="center")

    ax.text(-0.6, -2.2,
            "Diez o quince grados de error intencionado cuestan un rodeo pequeño y\n"
            "eliminan la duda: al alcanzar la referencia sabes con certeza de qué lado\n"
            "estás. Buscar a ciegas cuesta altura, y la altura no se recupera.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")

    ax.set_xlim(-1.0, 10.2)
    ax.set_ylim(-3.6, 3.0)
    return guardar(fig, DESTINO / "09-cap05-error-deliberado.png")


# --------------------------------------------------------------------------
# cap06 — La geometría de los satélites y la DOP
# --------------------------------------------------------------------------
def dilucion_precision():
    """Buena y mala geometría, con el error resultante en cifras."""
    fig, ax = lienzo(0.56)

    def escena(cx, angulos, titulo, color, dop):
        r = 2.6
        # Horizonte y bóveda.
        arco = np.linspace(0, math.pi, 80)
        ax.plot(cx + r * np.cos(arco), r * np.sin(arco), lw=1.2,
                color=ESTRUCTURA, alpha=0.45, zorder=2)
        ax.plot([cx - r, cx + r], [0, 0], lw=1.6, color=ESTRUCTURA, zorder=2)
        ax.plot(cx, 0, "o", ms=8, color=ESTRUCTURA, zorder=5)
        for a in angulos:
            p = np.array([cx + r * math.cos(math.radians(a)),
                          r * math.sin(math.radians(a))])
            ax.plot([cx, p[0]], [0, p[1]], lw=0.9, ls=(0, (2, 3)),
                    color=color, alpha=0.8, zorder=3)
            ax.plot(*p, "o", ms=8, color=color, zorder=4)
        rotulo(ax, np.array([cx, r + 0.35]), titulo, color=color, peso="bold",
               ha="center", va="bottom")
        rotulo(ax, np.array([cx, -0.45]), dop, color=color, peso="bold",
               ha="center", va="top")

    escena(-3.3, [18, 68, 112, 162], "satélites bien repartidos", SEGURA,
           "DOP ≈ 1,5   →   error ≈ 4,5 m")
    escena(3.3, [58, 72, 88, 102], "satélites agrupados", RESISTENCIA,
           "DOP ≈ 6   →   error ≈ 18 m")

    ax.text(-6.4, -1.35,
            "Con el mismo receptor y el mismo error de medida sobre cada satélite (unos "
            "3 m),\nla geometría multiplica el error final. El equipo no da ninguna "
            "alarma: sigue\nfuncionando y sigue mostrando una posición.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")

    ax.set_xlim(-6.5, 6.5)
    ax.set_ylim(-2.9, 3.6)
    return guardar(fig, DESTINO / "09-cap06-dilucion-precision.png")


# --------------------------------------------------------------------------
# cap01 — La red de paralelos y meridianos
# --------------------------------------------------------------------------
def coordenadas():
    """Reemplaza la ilustración provisional `09-cap01-coordenadas`.

    La anterior era un placeholder sin rótulos. Ésta nombra las dos familias de
    líneas, sus orígenes (ecuador y meridiano de Greenwich) y el sentido en que
    crecen, que es lo que el lector necesita para leer unas coordenadas.
    """
    fig, ax = lienzo(0.82)
    r = 1.0
    ax.add_patch(mpatches.Circle((0, 0), r, fill=False, lw=1.8,
                                 color=ESTRUCTURA, zorder=4))

    # Paralelos: elipses cada 20º de latitud.
    for lat in range(-60, 61, 20):
        y = r * math.sin(math.radians(lat))
        ancho = 2 * r * math.cos(math.radians(lat))
        alto = ancho * 0.22
        es_ecuador = lat == 0
        ax.add_patch(mpatches.Ellipse(
            (0, y), ancho, alto, fill=False,
            lw=2.0 if es_ecuador else 0.9,
            color=SEGURA if es_ecuador else ESTRUCTURA,
            alpha=1.0 if es_ecuador else 0.40, zorder=3))

    # Meridianos: elipses verticales cada 30º de longitud. El globo se mira con
    # Greenwich de frente, así que ése es la recta vertical central (anchura 0)
    # y el de 90º coincide con el contorno.
    ax.plot([0, 0], [-r, r], lw=2.0, color=RESISTENCIA, zorder=5)
    for lon in range(30, 180, 30):
        ancho = 2 * r * abs(math.sin(math.radians(lon)))
        ax.add_patch(mpatches.Ellipse(
            (0, 0), ancho, 2 * r, fill=False, lw=0.9,
            color=ESTRUCTURA, alpha=0.40, zorder=3))

    ax.annotate("ecuador: latitud 0º",
                xy=(-r * 0.86, 0.02), xytext=(-1.95, 0.20), fontsize=MENOR,
                color=SEGURA, fontweight="bold", ha="left", va="center",
                arrowprops=dict(arrowstyle="-", color=SEGURA, lw=1.0), zorder=6)
    ax.annotate("meridiano de Greenwich:\nlongitud 0º",
                xy=(0.0, -r * 0.72), xytext=(1.02, -0.92), fontsize=MENOR,
                color=RESISTENCIA, fontweight="bold", ha="left", va="center",
                arrowprops=dict(arrowstyle="-", color=RESISTENCIA, lw=1.0),
                zorder=6)
    ax.annotate("paralelos: miden latitud,\nde 0º a 90º N o S",
                xy=(r * 0.62, r * 0.66), xytext=(1.10, 0.86), fontsize=MENOR,
                color=ESTRUCTURA, fontweight="bold", ha="left", va="center",
                arrowprops=dict(arrowstyle="-", color=ESTRUCTURA, lw=1.0),
                zorder=6)
    ax.annotate("meridianos: miden longitud,\nde 0º a 180º E o W",
                xy=(-r * 0.50, r * 0.60), xytext=(-1.95, 0.92), fontsize=MENOR,
                color=ESTRUCTURA, fontweight="bold", ha="left", va="center",
                arrowprops=dict(arrowstyle="-", color=ESTRUCTURA, lw=1.0),
                zorder=6)

    ax.text(-1.95, -1.30,
            "Toda posición se da con dos ángulos y siempre en el mismo orden: primero\n"
            "la latitud con su letra N o S, después la longitud con la suya E o W.\n"
            "Ejemplo: 41º 06' 30\" N   004º 33' 45\" W.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")

    ax.set_xlim(-1.98, 2.30)
    ax.set_ylim(-1.85, 1.32)
    return guardar(fig, DESTINO / "09-cap01-coordenadas.png")


# --------------------------------------------------------------------------
# cap05 — Triangulación con dos líneas de posición
# --------------------------------------------------------------------------
def triangulacion():
    """Reemplaza la ilustración provisional `09-cap05-triangulacion`.

    Añade lo que la anterior no decía: que el ángulo de corte importa. Dos
    líneas casi paralelas dan un punto pésimo, y eso se ve mejor dibujado que
    explicado.
    """
    fig, ax = lienzo(0.56)

    def escena(cx, ang2, color, titulo, nota, semieje):
        # Dos líneas de posición que se cortan en el mismo punto.
        for ang in (0.0, ang2):
            d = rumbo(90 - ang, 3.2)
            ax.plot([cx - d[0], cx + d[0]], [-d[1], d[1]], lw=2.0,
                    color=ESTRUCTURA, alpha=0.75, zorder=3)
        # Elipse de incertidumbre: se estira cuanto más abierto es el corte.
        ax.add_patch(mpatches.Ellipse((cx, 0), semieje, 0.55, angle=ang2 / 2,
                                      color=color, alpha=0.30, zorder=4))
        ax.plot(cx, 0, "o", ms=8, color=color, zorder=6)
        rotulo(ax, np.array([cx, 2.55]), titulo, color=color, peso="bold",
               ha="center", va="bottom")
        rotulo(ax, np.array([cx, -2.75]), nota, color=color, peso="bold",
               ha="center", va="top")

    escena(-3.6, 80.0, SEGURA, "corte casi perpendicular",
           "posición fiable", 0.75)
    escena(3.6, 22.0, RESISTENCIA, "corte muy abierto",
           "posición imprecisa a lo largo de la línea", 3.10)

    rotulo(ax, np.array([-6.75, 0.16]), "carretera", color=ESTRUCTURA,
           ha="left", va="bottom", tam=MENOR - 1)
    rotulo(ax, np.array([-3.30, 1.95]), "río", color=ESTRUCTURA,
           ha="left", va="center", tam=MENOR - 1)

    ax.text(-7.4, -3.55,
            "Dos líneas de posición fijan un punto, pero la calidad del punto depende "
            "del\nángulo con que se cortan. Busca referencias que se crucen francamente:\n"
            "dos casi paralelas dejan la duda repartida a lo largo de varios kilómetros.",
            fontsize=MENOR, color=TEXTO, ha="left", va="top")

    ax.set_xlim(-7.5, 7.5)
    ax.set_ylim(-6.0, 3.6)
    return guardar(fig, DESTINO / "09-cap05-triangulacion.png")


FIGURAS = {
    "09-cap01-coordenadas": coordenadas,
    "09-cap01-minuto-de-latitud": minuto_de_latitud,
    "09-cap05-triangulacion": triangulacion,
    "09-cap02-tres-nortes": tres_nortes,
    "09-cap04-triangulo-velocidades": triangulo_velocidades,
    "09-cap04-regla-1-en-60": regla_1_en_60,
    "09-cap04-computador-cara-viento": computador_cara_viento,
    "09-cap05-cono-de-alcance": cono_de_alcance,
    "09-cap05-error-deliberado": error_deliberado,
    "09-cap06-dilucion-precision": dilucion_precision,
}


def main(argv):
    usar_estilo()
    nombres = argv[1:] or list(FIGURAS)
    for nombre in nombres:
        if nombre not in FIGURAS:
            raise SystemExit(f"No conozco la figura «{nombre}». "
                             f"Disponibles: {', '.join(FIGURAS)}")
        ruta = FIGURAS[nombre]()
        print(f"✓ {ruta.relative_to(ruta.parent.parent.parent)} "
              f"({ruta.stat().st_size / 1024:.0f} KB)")


if __name__ == "__main__":
    main(sys.argv)
