#!/usr/bin/env python3
"""Figuras técnicas del libro 01 — Derecho Aéreo y Procedimientos ATC.

Rehacen las figuras que la auditoría del 1 de octubre de 2026 marcó con
`.corregir` (issue #58). Cada función anota de dónde sale cada dato, y la ficha
`01-derecho-aereo-atc/prompts/<figura>.prompt.md` explica qué fallaba en la
versión anterior.

⚠️ **Todos los datos salen del propio capítulo**, que se corrigió y se cotejó con
la norma en la auditoría. Si el texto cambia una cifra o un plazo, hay que
cambiarlo aquí y regenerar. Se dibujan por código, no con un generador de
imágenes, por la razón que da `GUIA_ILUSTRACIONES.md`: un generador no garantiza
que el número o la regla dibujados coincidan con los del texto, y ningún
guardián detecta ese desajuste.

Los rótulos van en los dos idiomas, cada uno con `t(español, inglés)`: la
edición inglesa (en/) comparte los datos y sólo cambia el texto y el formato de
los números. Al tocar un rótulo, tócalo en los dos.

Uso:
    python3 tools/figuras/01_derecho_aereo.py [--lang en] [nombre ...]
"""

import sys
import textwrap
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import matplotlib.patches as mpatches
import numpy as np

from estilo import (
    ATENCION, CUERPO, ESTRUCTURA, FONDO, MENOR, RESISTENCIA, SEGURA,
    SUSTENTACION, TEXTO, guardar, lienzo, usar_estilo,
)

# Tonos de un solo color para escalas de gravedad o de validez: se oscurecen a
# la vez que crece lo que miden, y siempre van con su rótulo escrito.
TONO_CLARO = "#C9D6E6"
TONO_MEDIO = "#5C7FA6"
BANDA = "#E8EEF5"        # fondo de notas y bandas al pie
SUELO = "#E3E6EA"        # el terreno sobre el que se pintan las señales
NUBE = "#DCE3EC"

RAIZ = Path(__file__).resolve().parent.parent.parent
DESTINOS = {
    "es": RAIZ / "01-derecho-aereo-atc" / "imagenes",
    "en": RAIZ / "en" / "01-air-law-atc" / "imagenes",
}
IDIOMA = "es"


def t(es, en):
    """El rótulo en el idioma que se está dibujando."""
    return en if IDIOMA == "en" else es


def destino(nombre):
    return DESTINOS[IDIOMA] / nombre


# --------------------------------------------------------------------------
# Piezas comunes de los diagramas de cajas
# --------------------------------------------------------------------------
def caja(ax, cx, cy, ancho, alto, texto, borde=ESTRUCTURA, relleno=FONDO,
         color_texto=TEXTO, tam=CUERPO, negrita=False, trazo=1.4, estilo="-"):
    """Caja de esquinas redondeadas centrada en (cx, cy), con su texto."""
    ax.add_patch(mpatches.FancyBboxPatch(
        (cx - ancho / 2, cy - alto / 2), ancho, alto,
        boxstyle="round,pad=0,rounding_size=1.6",
        facecolor=relleno, edgecolor=borde, lw=trazo, ls=estilo, zorder=2))
    ax.text(cx, cy, texto, ha="center", va="center", fontsize=tam,
            color=color_texto, fontweight="bold" if negrita else "normal",
            linespacing=1.25, zorder=3)


def flecha(ax, origen, fin, color=ESTRUCTURA, etiqueta=None, lado="left",
           desplazamiento=(1.2, 0)):
    """Flecha recta con punta clara y, si hace falta, su rótulo («Sí», «No»)."""
    ax.annotate("", xy=fin, xytext=origen, zorder=1,
                arrowprops=dict(arrowstyle="-|>,head_length=0.55,head_width=0.3",
                                color=color, lw=1.6, shrinkA=0, shrinkB=0))
    if etiqueta:
        mx, my = (origen[0] + fin[0]) / 2, (origen[1] + fin[1]) / 2
        dx, dy = desplazamiento
        ax.text(mx + dx, my + dy, etiqueta, ha=lado, va="center", fontsize=MENOR,
                color=color, fontweight="bold", zorder=3)


def codo(ax, puntos, color=ESTRUCTURA):
    """Línea quebrada que acaba en flecha: para conectores que doblan."""
    xs, ys = zip(*puntos[:-1])
    ax.plot(xs, ys, color=color, lw=1.6, solid_capstyle="butt", zorder=1)
    flecha(ax, puntos[-2], puntos[-1], color=color)


def cota(ax, p1, p2, texto, dx=0, dy=1.2, ha="center", va="bottom", color=ESTRUCTURA):
    """Cota con flecha en los dos extremos y su valor."""
    ax.annotate("", xy=p2, xytext=p1, zorder=4,
                arrowprops=dict(arrowstyle="<|-|>,head_length=0.45,head_width=0.22",
                                color=color, lw=1.3, shrinkA=0, shrinkB=0))
    mx, my = (p1[0] + p2[0]) / 2, (p1[1] + p2[1]) / 2
    ax.text(mx + dx, my + dy, texto, ha=ha, va=va, fontsize=MENOR, color=TEXTO, zorder=5)


def planeador(ax, x, y, largo, color=ESTRUCTURA):
    """Planeador de perfil, con el morro a la izquierda: fuselaje, cabina,
    ala vista de canto y cola en T."""
    def esc(puntos):
        return [(x + px * largo, y + py * largo) for px, py in puntos]
    fuselaje = [(-0.5, 0), (-0.44, 0.045), (-0.3, 0.07), (-0.12, 0.06), (0.46, 0.025),
                (0.5, 0.03), (0.5, 0.0), (-0.12, -0.04), (-0.3, -0.045), (-0.44, -0.035)]
    deriva = [(0.4, 0.03), (0.45, 0.2), (0.51, 0.2), (0.5, 0.02)]
    ax.add_patch(mpatches.Polygon(esc(fuselaje), closed=True, facecolor=FONDO,
                                  edgecolor=color, lw=1.2, zorder=6))
    ax.add_patch(mpatches.Polygon(esc(deriva), closed=True, facecolor=FONDO,
                                  edgecolor=color, lw=1.2, zorder=6))
    ax.plot([x + 0.4 * largo, x + 0.57 * largo], [y + 0.2 * largo] * 2,
            color=color, lw=1.6, zorder=7)
    ax.add_patch(mpatches.Ellipse((x - 0.3 * largo, y + 0.055 * largo), 0.17 * largo,
                                  0.055 * largo, facecolor=BANDA, edgecolor=color,
                                  lw=1.0, zorder=7))
    ax.plot([x - 0.24 * largo, x + 0.12 * largo], [y + 0.045 * largo] * 2,
            color=color, lw=2.4, solid_capstyle="round", zorder=7)


def nube(ax, x, y, s):
    """Nube plana: tres círculos solapados, sin contorno."""
    for cx, cy, r in ((-0.55, -0.1, 0.42), (0, 0.15, 0.55), (0.55, -0.1, 0.42), (0, -0.2, 0.4)):
        ax.add_patch(mpatches.Circle((x + cx * s, y + cy * s), r * s, facecolor=NUBE,
                                     edgecolor="none", zorder=2))


def lienzo_cajas(alto_relativo):
    """Lienzo de 100 unidades de ancho para diagramas de cajas.

    Las coordenadas van de 0 a 100 en horizontal y de 0 a 100·alto_relativo en
    vertical, así que una unidad mide lo mismo en los dos ejes y las cajas no se
    deforman al cambiar la proporción del lienzo.

    ⚠️ Los ejes ocupan el lienzo entero. Con los márgenes por defecto de
    matplotlib se quedan en el 77 % del ancho: las cajas encogen con ellos, pero
    el texto, que se mide en puntos, no, y se sale de las cajas.
    """
    fig, ax = lienzo(alto_relativo)
    fig.subplots_adjust(left=0, right=1, bottom=0, top=1)
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100 * alto_relativo)
    return fig, ax


# --------------------------------------------------------------------------
# cap06 — La regla semicircular española
# --------------------------------------------------------------------------
def regla_semicircular():
    """Semicírculo norte (pares + 500) y sur (impares + 500), por derrota magnética.

    Fuente (cap06…qmd, «Regla semicircular de niveles de crucero», que sigue el
    RD 1180/2018, art. 6 y anexo I, y el AIP España, ENR 1.7): por encima de
    3.000 ft AGL, derrotas de 270° a 089° → pares + 500 ft (4.500, 6.500 ft…;
    FL 65, FL 85…); de 090° a 269° → impares + 500 ft (3.500, 5.500 ft…; FL 75,
    FL 95…). Es la orientación Norte-Sur, no la Este-Oeste del apéndice 3 de SERA.
    """
    fig, ax = lienzo(0.86)
    r = 1.0
    ax.set_xlim(-1.75, 1.75)
    ax.set_ylim(-1.62, 1.39)

    # Los dos semicírculos se distinguen por el relleno y, además, por el rayado,
    # para que sigan siendo dos en escala de grises.
    ax.add_patch(mpatches.Wedge((0, 0), r, 0, 180, facecolor=SUSTENTACION,
                                alpha=0.13, edgecolor="none", zorder=1))
    ax.add_patch(mpatches.Wedge((0, 0), r, 180, 360, facecolor=FONDO, hatch="////",
                                edgecolor=ESTRUCTURA, lw=0, alpha=0.28, zorder=1))
    ax.add_patch(mpatches.Circle((0, 0), r, fill=False, edgecolor=ESTRUCTURA,
                                 lw=1.8, zorder=3))

    # Marcas de rumbo cada 10°, más largas cada 30°. El rumbo se mide desde el
    # norte en sentido horario; en matplotlib el ángulo va desde el este en
    # sentido antihorario.
    for rumbo in range(0, 360, 10):
        a = np.radians(90 - rumbo)
        largo = 0.09 if rumbo % 30 == 0 else 0.045
        ax.plot([r * np.cos(a), (r - largo) * np.cos(a)],
                [r * np.sin(a), (r - largo) * np.sin(a)],
                color=ESTRUCTURA, lw=1.2 if rumbo % 30 == 0 else 0.8, zorder=4)
        if rumbo % 30 == 0 and rumbo not in (90, 270):
            ax.text(1.1 * r * np.cos(a), 1.1 * r * np.sin(a), f"{rumbo:03d}°",
                    ha="center", va="center", fontsize=MENOR, color=TEXTO, zorder=4)

    # Los cuatro puntos cardinales, por fuera de los grados.
    for rumbo, letra in ((0, "N"), (90, "E"), (180, "S"), (270, t("O", "W"))):
        a = np.radians(90 - rumbo)
        dist = 1.24 if rumbo in (0, 180) else 1.5
        ax.text(dist * r * np.cos(a), dist * r * np.sin(a), letra, ha="center",
                va="center", fontsize=CUERPO + 3, fontweight="bold",
                color=ESTRUCTURA, zorder=4)

    # La divisoria Este-Oeste, con el rumbo de cada lado: así se ve que 090° ya
    # es del sur y 270°, del norte.
    ax.plot([-1.32, 1.32], [0, 0], color=ESTRUCTURA, lw=2.0, zorder=5)
    for x, arriba, abajo in ((1.12, "089°", "090°"), (-1.12, "270°", "269°")):
        ax.text(x, 0.06, arriba, ha="center", va="bottom", fontsize=MENOR,
                color=TEXTO, fontweight="bold", zorder=5)
        ax.text(x, -0.06, abajo, ha="center", va="top", fontsize=MENOR,
                color=TEXTO, fontweight="bold", zorder=5)

    # Una flecha de derrota en cada semicírculo, en el sentido del vuelo.
    for y0, y1 in ((0.12, 0.88), (-0.12, -0.88)):
        ax.annotate("", xy=(-0.66, y1 * 0.82), xytext=(-0.66, y0), zorder=6,
                    arrowprops=dict(arrowstyle="-|>,head_length=0.6,head_width=0.32",
                                    color=ESTRUCTURA, lw=2.2))

    bloques = (
        (0.45, t("Derrotas de 270° a 089°", "Tracks 270° to 089°"),
         t("PARES + 500 ft", "EVEN + 500 ft"),
         t("4.500 · 6.500 ft…\nFL 65 · FL 85…", "4,500 · 6,500 ft…\nFL 65 · FL 85…")),
        (-0.48, t("Derrotas de 090° a 269°", "Tracks 090° to 269°"),
         t("IMPARES + 500 ft", "ODD + 500 ft"),
         t("3.500 · 5.500 ft…\nFL 75 · FL 95…", "3,500 · 5,500 ft…\nFL 75 · FL 95…")),
    )
    for y, cabecera, regla, ejemplos in bloques:
        ax.text(0.02, y + 0.25, cabecera, ha="center", va="center",
                fontsize=CUERPO, color=TEXTO, zorder=6)
        ax.text(0.02, y + 0.07, regla, ha="center", va="center",
                fontsize=CUERPO + 4, fontweight="bold", color=ESTRUCTURA, zorder=6)
        ax.text(0.02, y - 0.2, ejemplos, ha="center", va="center",
                fontsize=MENOR, color=TEXTO, linespacing=1.3, zorder=6)

    ax.text(0, -1.5,
            t("Derrota magnética, en vuelo VFR por encima de 3.000 ft AGL (España)",
              "Magnetic track, VFR flight above 3,000 ft AGL (Spain)"),
            ha="center", va="center", fontsize=CUERPO, color=TEXTO)
    return guardar(fig, destino("01-cap06-regla-semicircular.png"))


# --------------------------------------------------------------------------
# cap13 — A quién se notifica un suceso
# --------------------------------------------------------------------------
def flujo_notificacion():
    """Qué se notifica, a quién y en qué plazo.

    Fuente (cap13…qmd, «El deber de notificar: sistema SNS» y «¿A quién y
    cuándo?»): obligatorios los accidentes, los incidentes graves y los sucesos
    de la lista del Reglamento de Ejecución (UE) 2015/1018, anexo V, sección 2;
    a la autoridad de investigación, el accidente o incidente grave sin demora
    (Reglamento 996/2010, art. 9); a AESA, en 72 horas (Reglamento 376/2014,
    art. 4.7), por el sistema de la organización o directamente al SNS; lo que
    AESA sepa sólo por la notificación no se usa contra un error involuntario
    (art. 16.6).

    ⚠️ No se dibuja la notificación de incidentes no graves a la autoridad de
    investigación: es una pregunta abierta de la auditoría (NOR-05, Ley 2/2024,
    art. 9.1 c)).
    """
    alto = 1.02
    fig, ax = lienzo_cajas(alto)

    col = {"acc": 17, "lista": 50, "vol": 83}
    ancho_col = 31

    caja(ax, 50, 96, 34, 6.5, t("Ocurre un suceso", "An occurrence happens"),
         tam=CUERPO + 1, negrita=True, trazo=1.8)
    flecha(ax, (50, 92.75), (50, 86.6))

    caja(ax, 50, 82, 40, 9, t("¿Es un accidente\no un incidente grave?",
                             "Is it an accident\nor a serious incident?"),
         negrita=True, trazo=2.2)
    # «Sí» a la izquierda, «No» a la derecha; cada rótulo junto al tramo vertical
    # de su flecha, para que no haya duda de a cuál pertenece.
    codo(ax, [(30, 82), (col["acc"], 82), (col["acc"], 72.4)], color=ATENCION)
    ax.text(col["acc"] + 1.2, 77, t("Sí", "Yes"), ha="left", va="center",
            fontsize=MENOR, color=ATENCION, fontweight="bold")
    # La caja de la lista abarca las columnas de la derecha, de 34,5 a 98,5.
    centro_lista = 66.5
    codo(ax, [(70, 82), (centro_lista + 8, 82), (centro_lista + 8, 72.4)])
    ax.text(centro_lista + 9.2, 77, "No", ha="left", va="center", fontsize=MENOR,
            color=ESTRUCTURA, fontweight="bold")

    # Rama de la izquierda: dos destinos a la vez, con plazos distintos.
    caja(ax, col["acc"], 66, ancho_col, 12,
         t("Autoridad de investigación\nde accidentes: sin demora\n(Reglamento 996/2010, art. 9)",
           "Accident investigation\nauthority: without delay\n(Regulation 996/2010, Art. 9)"),
         borde=ATENCION, trazo=2.0)
    flecha(ax, (col["acc"], 60), (col["acc"], 53.6), color=ATENCION)
    ax.text(col["acc"] + 1.2, 56.8, t("y además", "and also"), ha="left", va="center",
            fontsize=MENOR, color=ATENCION, fontweight="bold")

    # Rama de la derecha: la lista del Reglamento 2015/1018.
    caja(ax, centro_lista, 66, 64, 12,
         t("¿Está en la lista del Reglamento 2015/1018\n(anexo V, sección 2)? P. ej., una violación\nde espacio aéreo o una cuasicolisión",
           "Is it on the list in Regulation 2015/1018\n(Annex V, Section 2)? E.g. an airspace\ninfringement or a near collision"),
         trazo=2.2)
    flecha(ax, (col["lista"], 60), (col["lista"], 53.6), color=ATENCION)
    ax.text(col["lista"] + 1.2, 56.8, t("Sí", "Yes"), ha="left", va="center",
            fontsize=MENOR, color=ATENCION, fontweight="bold")
    flecha(ax, (col["vol"], 60), (col["vol"], 53.6), color=SEGURA)
    ax.text(col["vol"] + 1.2, 56.8, "No", ha="left", va="center",
            fontsize=MENOR, color=SEGURA, fontweight="bold")

    # Obligatoria o voluntaria lo dice el texto de la caja, no sólo su color.
    for x in (col["acc"], col["lista"]):
        caja(ax, x, 47, ancho_col, 12,
             t("Obligatoria: AESA,\nen 72 horas (Reglamento\n376/2014, art. 4.7)",
               "Mandatory: AESA,\nwithin 72 hours (Regulation\n376/2014, Art. 4(7))"),
             borde=ATENCION, trazo=2.0)
    caja(ax, col["vol"], 47, ancho_col, 12,
         t("Voluntaria: AESA,\nsi otros pueden\naprender de ello",
           "Voluntary: AESA,\nif others can\nlearn from it"),
         borde=SEGURA, trazo=2.0, estilo=(0, (4, 2)))

    for x in col.values():
        flecha(ax, (x, 41), (x, 33.6))
    caja(ax, 50, 29, 97, 9,
         t("AESA analiza el riesgo y difunde las lecciones aprendidas\n"
           "Se notifica por el sistema de tu organización o, si no tienes, directamente al SNS",
           "AESA analyses the risk and shares the lessons learned\n"
           "Reports go through your organisation’s system or, if you have none, straight to the SNS"),
         trazo=1.8)

    caja(ax, 50, 15, 97, 11,
         t("Cultura justa: lo que AESA sepa sólo por tu notificación no puede usarlo\n"
           "para abrirte un expediente por un error involuntario o un descuido\n"
           "(Reglamento 376/2014, art. 16.6)",
           "Just culture: what AESA learns only from your report cannot be used to\n"
           "bring proceedings against you for an unintentional error or an oversight\n"
           "(Regulation 376/2014, Art. 16(6))"),
         relleno="#E8EEF5", borde="none", trazo=0)
    return guardar(fig, destino("01-cap13-flujo-notificacion.png"))


# --------------------------------------------------------------------------
# cap14 — La gravedad depende de lo que provoca
# --------------------------------------------------------------------------
def escala_infracciones():
    """Leve, grave o muy grave según las consecuencias, con multas y licencia.

    Fuente (cap14…qmd, «Infracciones y sanciones», cotejado con la Ley 21/2003
    archivada en recursos/fuentes/espana/):
      * art. 44.1-3: el incumplimiento de las obligaciones de seguridad es leve
        salvo que cause un incidente grave, lesiones graves o daños de 5.000 a
        15.000 € (grave) o un accidente, una muerte o daños de más de 15.000 €
        (muy grave);
      * art. 50: conductas tipificadas aparte sobre notificación e investigación;
      * art. 55.1: multas para un particular;
      * art. 56.1: suspensión de hasta 5 años (grave) o revocación (muy grave),
        que «podrá imponerse».

    ⚠️ Sin la escala del art. 55.2, para actividades comerciales: si alcanza al
    titular de SPL que vuela con remuneración es una pregunta abierta (NOR-06).
    """
    alto = 0.98
    fig, ax = lienzo_cajas(alto)

    caja(ax, 50, 92, 98, 10,
         t("Incumples una obligación de seguridad: volar con un título válido, con la capacidad\n"
           "física y psíquica intacta, en una aeronave aeronavegable, siguiendo las reglas\n"
           "operacionales, con la documentación requerida y con el seguro obligatorio",
           "You breach a safety obligation: flying with a valid licence, with unimpaired physical\n"
           "and mental capacity, in an airworthy aircraft, following the operating rules, carrying\n"
           "the required documents and holding the compulsory insurance"),
         trazo=1.8)

    xs = (17, 50, 83)
    ancho = 31
    base = 60
    # Escalones que suben con la gravedad; el tono se oscurece a la vez, y el
    # nombre va escrito: el color no es la única señal.
    escalones = (
        (t("LEVE", "MINOR"), 6, "#C9D6E6", ESTRUCTURA),
        (t("GRAVE", "SERIOUS"), 11, "#5C7FA6", FONDO),
        (t("MUY GRAVE", "VERY SERIOUS"), 16, ESTRUCTURA, FONDO),
    )
    for x, (nombre, altura, relleno, color) in zip(xs, escalones):
        flecha(ax, (x, 86.6), (x, base + altura + 0.4))
        ax.add_patch(mpatches.Rectangle((x - ancho / 2, base), ancho, altura,
                                        facecolor=relleno, edgecolor=ESTRUCTURA,
                                        lw=1.4, zorder=2))
        ax.text(x, base + altura / 2, nombre, ha="center", va="center",
                fontsize=CUERPO + 2, fontweight="bold", color=color, zorder=3)

    filas = (
        (55, t("Si provoca… (art. 44)", "If it causes… (Art. 44)"), (
            t("nada más", "nothing else"),
            t("un incidente grave,\nlesiones graves o daños\nde 5.000 a 15.000 €",
              "a serious incident,\nserious injury or damage\nof €5,000 to €15,000"),
            t("un accidente, la muerte\nde una persona o daños\nde más de 15.000 €",
              "an accident, a person’s\ndeath or damage of\nmore than €15,000"),
        )),
        (38, t("Multa a un particular (art. 55.1)", "Fine for a private individual (Art. 55(1))"), (
            t("apercibimiento o\nde 60 a 45.000 €", "a warning or\n€60 to €45,000"),
            t("de 45.001 a 90.000 €", "€45,001 to €90,000"),
            t("de 90.001 a 225.000 €", "€90,001 to €225,000"),
        )),
        (26, t("Además, sobre tu licencia (art. 56)", "On top of that, your licence (Art. 56)"), (
            "—",
            t("puede suspenderse\nhasta 5 años", "may be suspended\nfor up to 5 years"),
            t("puede revocarse", "may be revoked"),
        )),
    )
    for y, cabecera, celdas in filas:
        ax.text(1, y, cabecera, ha="left", va="bottom", fontsize=MENOR,
                color=ESTRUCTURA, fontweight="bold")
        ax.plot([1, 99], [y - 0.6, y - 0.6], color=ESTRUCTURA, lw=0.6, alpha=0.5)
        for x, celda in zip(xs, celdas):
            ax.text(x, y - 1.6, celda, ha="center", va="top", fontsize=CUERPO,
                    color=TEXTO, linespacing=1.25)

    caja(ax, 50, 9, 98, 10,
         t("Tipificadas aparte (art. 50): no notificar un suceso es leve; no comunicar un incidente\n"
           "grave a la autoridad de investigación, grave; no comunicarle un accidente u\n"
           "obstaculizar su investigación, muy grave",
           "Defined separately (Art. 50): failing to report an occurrence is minor; failing to notify\n"
           "a serious incident to the investigation authority, serious; failing to notify it of an\n"
           "accident, or obstructing its investigation, very serious"),
         relleno="#E8EEF5", borde="none", trazo=0)
    return guardar(fig, destino("01-cap14-escala-infracciones.png"))


# --------------------------------------------------------------------------
# cap06 — Mínimos VMC por franjas
# --------------------------------------------------------------------------
def minimos_vmc():
    """Visibilidad y distancia a nubes por franja de altitud y clase de espacio.

    Fuente (cap06…qmd, «Mínimos VFR: visibilidad y distancia a nubes», que sigue
    SERA.5001 y su tabla S5-1, y el RD 1180/2018, art. 30):
      * por encima de FL 100: 8 km, 1.500 m en horizontal, 1.000 ft en vertical;
      * de la franja inferior a FL 100: 5 km, 1.500 m, 1.000 ft, en cualquier clase;
      * franja inferior, hasta el MAYOR de 3.000 ft AMSL o 1.000 ft AGL: en B-E,
        5 km, 1.500 m y 1.000 ft; en F y G, 5 km, libre de nubes y con la
        superficie a la vista.
    ⚠️ Sin la visibilidad de 1.500 m: en España no vale para planeadores
    (RD 1180/2018, art. 30; hallazgo NOR-01).
    """
    alto = 0.92
    fig, ax = lienzo_cajas(alto)
    mil_pies, mil_quinientos = t("1.000 ft", "1,000 ft"), t("1.500 m", "1,500 m")

    def franja_completa(c, titulo, visibilidad):
        ax.text(1, c + 13, titulo, ha="left", va="center", fontsize=CUERPO,
                fontweight="bold", color=ESTRUCTURA)
        planeador(ax, 50, c, 13)
        nube(ax, 50, c + 10.5, 4.2)
        nube(ax, 50, c - 10, 4.2)
        nube(ax, 85, c + 0.5, 4.2)
        cota(ax, (50, c + 3.2), (50, c + 7.6), mil_pies, dx=1.2, dy=0, ha="left", va="center")
        cota(ax, (50, c - 1.6), (50, c - 7.2), mil_pies, dx=1.2, dy=0, ha="left", va="center")
        cota(ax, (58.5, c), (79.5, c), mil_quinientos)
        cota(ax, (8, c), (40.5, c), visibilidad)

    franja_completa(76, t("Por encima de FL 100 · clases B a G", "Above FL 100 · classes B to G"),
                    t("Visibilidad 8 km", "Visibility 8 km"))
    franja_completa(46, t("Hasta FL 100 · clases B a G", "Up to FL 100 · classes B to G"),
                    t("Visibilidad 5 km", "Visibility 5 km"))

    for y, rotulo in ((61.5, "FL 100"),
                      (30.5, t("3.000 ft AMSL o 1.000 ft AGL, el mayor de los dos",
                               "3,000 ft AMSL or 1,000 ft AGL, whichever is higher"))):
        ax.plot([0, 100], [y, y], color=ESTRUCTURA, lw=1.8, zorder=1)
        ax.text(50, y, rotulo, ha="center", va="center", fontsize=CUERPO,
                fontweight="bold", color=ESTRUCTURA, zorder=8,
                bbox=dict(boxstyle="square,pad=0.3", facecolor=FONDO, edgecolor="none"))
    ax.plot([50, 50], [0, 29], color=ESTRUCTURA, lw=1.2, ls=(0, (4, 3)), zorder=1)

    # Franja inferior, espacio controlado.
    ax.text(1, 27, t("Clases B, C, D y E", "Classes B, C, D and E"), ha="left", va="center",
            fontsize=CUERPO, fontweight="bold", color=ESTRUCTURA)
    planeador(ax, 26, 13, 10)
    nube(ax, 26, 22.5, 3.2)
    nube(ax, 26, 4, 3.2)
    nube(ax, 45, 13.5, 3.0)
    cota(ax, (26, 15.6), (26, 19.6), mil_pies, dx=1.2, dy=0, ha="left", va="center")
    cota(ax, (26, 11.6), (26, 7.0), mil_pies, dx=1.2, dy=0, ha="left", va="center")
    cota(ax, (32.5, 13), (41, 13), mil_quinientos)
    cota(ax, (2, 13), (19.5, 13), t("Visibilidad 5 km", "Visibility 5 km"))

    # Franja inferior, espacio no controlado.
    ax.text(52, 27, t("Clases F y G", "Classes F and G"), ha="left", va="center",
            fontsize=CUERPO, fontweight="bold", color=ESTRUCTURA)
    ax.text(52, 22.5, t("En España, 5 km también para planeadores\n(RD 1180/2018, art. 30)",
                        "In Spain, 5 km for gliders too\n(RD 1180/2018, art. 30)"),
            ha="left", va="center", fontsize=MENOR, color=TEXTO, linespacing=1.2)
    planeador(ax, 80, 13, 10)
    cota(ax, (53, 13), (73.5, 13), t("Visibilidad 5 km", "Visibility 5 km"))
    ax.text(80, 5, t("Libre de nubes y con\nla superficie a la vista",
                     "Clear of cloud and in\nsight of the surface"),
            ha="center", va="center", fontsize=MENOR, color=TEXTO, linespacing=1.2)
    return guardar(fig, destino("01-cap06-minimos-vmc.png"))


# --------------------------------------------------------------------------
# cap04 — Validez del certificado médico según la edad
# --------------------------------------------------------------------------
def validez_medical():
    """Validez del LAPL y de la Clase 2 sobre un eje de edad a escala.

    Fuente (cap04…qmd, «El certificado médico», que resume MED.A.045):
      * LAPL: 60 meses hasta los 40; 24 meses desde los 40; expedido antes de
        los 40, deja de valer a los 42.
      * Clase 2: 60 meses hasta los 40 (misma regla de los 42); 24 meses de 40
        a 50 (expedido antes de los 50, deja de valer a los 51); 12 meses desde
        los 50.
      * Ejemplo del texto: expedido a los 39, caduca a los 42, no a los 44.
    """
    alto = 0.52
    fig, ax = lienzo_cajas(alto)
    e0, e1, x0, x1 = 14, 70, 14, 97

    def x(edad):
        return x0 + (edad - e0) * (x1 - x0) / (e1 - e0)

    def barra(y, tramos, titulo):
        ax.text(1, y + 3, titulo, ha="left", va="center", fontsize=CUERPO,
                fontweight="bold", color=ESTRUCTURA)
        for a, b, rotulo, relleno, color in tramos:
            ax.add_patch(mpatches.Rectangle((x(a), y - 3), x(b) - x(a), 6,
                                            facecolor=relleno, edgecolor=ESTRUCTURA,
                                            lw=1.2, zorder=2))
            ax.text((x(a) + x(b)) / 2, y, rotulo, ha="center", va="center",
                    fontsize=CUERPO, fontweight="bold", color=color, zorder=3)

    def regla(y, a, b, texto, arriba=False):
        """Corchete ámbar sobre la barra, de la edad a a la b.

        Con `arriba`, el texto sube un renglón y se alinea a la derecha del
        lienzo, unido al corchete por una guía: a la derecha de los 51 años no
        cabe y ensancharía la figura.
        """
        yc = y + 4.2
        ax.plot([x(a), x(a), x(b), x(b)], [yc - 0.9, yc, yc, yc - 0.9],
                color=ATENCION, lw=1.8, zorder=4)
        if not texto:
            return
        if arriba == "izquierda":
            ax.text(x(a) - 1, yc + 0.6, texto, ha="right", va="center", fontsize=MENOR,
                    color=ATENCION, fontweight="bold", zorder=4)
        elif arriba:
            xm = (x(a) + x(b)) / 2
            ax.plot([xm, xm], [yc, yc + 2.2], color=ATENCION, lw=1.2, zorder=4)
            ax.text(99, yc + 3.2, texto, ha="right", va="center", fontsize=MENOR,
                    color=ATENCION, fontweight="bold", zorder=4)
        else:
            ax.text(x(b) + 1, yc + 0.2, texto, ha="left", va="center", fontsize=MENOR,
                    color=ATENCION, fontweight="bold", zorder=4)

    meses = t("{} meses", "{} months")
    barra(41, ((e0, 40, meses.format(60), TONO_CLARO, ESTRUCTURA),
               (40, e1, meses.format(24), TONO_MEDIO, FONDO)), "LAPL")
    regla(41, 40, 42, t("Expedido antes de los 40: deja de valer a los 42",
                        "Issued before 40: no longer valid after 42"))
    barra(22, ((e0, 40, meses.format(60), TONO_CLARO, ESTRUCTURA),
               (40, 50, meses.format(24), TONO_MEDIO, FONDO),
               (50, e1, meses.format(12), ESTRUCTURA, FONDO)), t("Clase 2", "Class 2"))
    regla(22, 40, 42, t("Igual: deja de valer a los 42", "Same: no longer valid after 42"),
          arriba="izquierda")
    regla(22, 50, 51, t("Expedido antes de los 50: deja de valer a los 51",
                        "Issued before 50: no longer valid after 51"), arriba=True)

    # Eje de edad.
    ax.plot([x0, x1 + 1.5], [11, 11], color=ESTRUCTURA, lw=1.4)
    for edad in (14, 20, 30, 40, 42, 50, 51, 60, 70):
        ax.plot([x(edad)] * 2, [11, 9.8], color=ESTRUCTURA, lw=1.2)
        ha = "right" if edad in (40, 50) else "left" if edad in (42, 51) else "center"
        dx = -0.2 if ha == "right" else 0.2 if ha == "left" else 0
        ax.text(x(edad) + dx, 9.2, str(edad), ha=ha, va="top", fontsize=MENOR, color=TEXTO)
    ax.text((x0 + x1) / 2, 4.6, t("Edad del piloto (años)", "Pilot’s age (years)"),
            ha="center", va="center", fontsize=MENOR, color=TEXTO)
    ax.text(1, 0.8, t("Ejemplo: expedido a los 39, caduca a los 42, no a los 44.",
                      "Example: issued at 39, it expires at 42, not at 44."),
            ha="left", va="center", fontsize=MENOR, color=ATENCION, fontweight="bold")
    return guardar(fig, destino("01-cap04-validez-medical.png"))


# --------------------------------------------------------------------------
# cap02 — El ARC: un año y dos prórrogas
# --------------------------------------------------------------------------
def ciclo_arc():
    """Validez del ARC a escala de años.

    Fuente (cap02…qmd, «La "ITV" anual…», y ML.A.902 a), consolidado a
    07-08-2026): validez de un año, prorrogable por un año, con un máximo de dos
    prórrogas consecutivas, si la misma CAMO o CAO ha gestionado la
    aeronavegabilidad sin interrupción. Al cumplirse el tercer año, nueva
    revisión de la aeronavegabilidad.
    """
    alto = 0.42
    fig, ax = lienzo_cajas(alto)
    ax.set_ylim(3, 3 + 100 * alto)
    xs = (7, 31, 55, 79)
    y0, y1 = 22, 29

    for a, b in zip(xs, xs[1:]):
        ax.add_patch(mpatches.Rectangle((a, y0), b - a, y1 - y0, facecolor=SEGURA,
                                        edgecolor=FONDO, lw=1.5, zorder=2))
        ax.text((a + b) / 2, (y0 + y1) / 2, t("1 año", "1 year"), ha="center", va="center",
                fontsize=CUERPO, fontweight="bold", color=FONDO, zorder=3)
    ax.add_patch(mpatches.Rectangle((xs[-1], y0), 99 - xs[-1], y1 - y0, facecolor=FONDO,
                                    hatch="////", edgecolor="#8A8F96", lw=1.2, zorder=2))
    ax.text((xs[-1] + 99) / 2 + 1.2, (y0 + y1) / 2, t("sin revisión,\ncaducado", "no review:\nexpired"),
            ha="center", va="center", fontsize=MENOR, color=TEXTO, linespacing=1.1, zorder=3,
            bbox=dict(boxstyle="square,pad=0.15", facecolor=FONDO, edgecolor="none"))

    ax.plot([xs[0], xs[0], xs[-1], xs[-1]], [y1 + 6.2, y1 + 7.2, y1 + 7.2, y1 + 6.2],
            color=SEGURA, lw=1.6)
    ax.text((xs[0] + xs[-1]) / 2, y1 + 8, t("ARC válido: hasta 3 años con dos prórrogas",
                                            "ARC valid: up to 3 years with two extensions"),
            ha="center", va="bottom", fontsize=CUERPO, fontweight="bold", color=SEGURA)

    hitos = (
        t("Año 0", "Year 0"), t("Revisión de la\naeronavegabilidad:\nse expide el ARC",
                                "Airworthiness\nreview:\nARC issued"),
        t("Año 1", "Year 1"), t("1.ª prórroga", "1st extension"),
        t("Año 2", "Year 2"), t("2.ª prórroga", "2nd extension"),
        t("Año 3", "Year 3"), t("Nueva revisión de la\naeronavegabilidad",
                                "New airworthiness\nreview"),
    )
    for i, xh in enumerate(xs):
        ax.add_patch(mpatches.Circle((xh, (y0 + y1) / 2), 2.0, facecolor=FONDO,
                                     edgecolor=ESTRUCTURA, lw=1.8, zorder=4))
        ax.text(xh, y1 + 1.4, hitos[2 * i], ha="center", va="bottom", fontsize=MENOR,
                fontweight="bold", color=ESTRUCTURA)
        ax.text(xh, y0 - 1.6, hitos[2 * i + 1], ha="center", va="top", fontsize=MENOR,
                color=TEXTO, linespacing=1.15)

    ax.plot([xs[1], xs[1], xs[2], xs[2]], [11.4, 10.4, 10.4, 11.4], color=ESTRUCTURA, lw=1.2)
    ax.text((xs[1] + xs[2]) / 2, 9.4,
            t("Prórrogas: sólo si la misma CAMO o CAO ha gestionado\n"
              "la aeronavegabilidad sin interrupción (ML.A.902)",
              "Extensions: only if the same CAMO or CAO has managed\n"
              "continuing airworthiness without interruption (ML.A.902)"),
            ha="center", va="top", fontsize=MENOR, color=TEXTO, linespacing=1.2)
    return guardar(fig, destino("01-cap02-ciclo-arc.png"))


# --------------------------------------------------------------------------
# cap10 — La manga de viento
# --------------------------------------------------------------------------
def manga_viento():
    """Cinco mangas, de una a cinco franjas llenas, con su viento aproximado.

    Fuente: la convención de unos 3 kt por franja (de origen FAA, no norma OACI ni
    EASA; hallazgo TEC-14). Conversiones calculadas con 1 kt = 1,852 km/h =
    0,5144 m/s: 3 kt = 5,6 km/h y 1,5 m/s; 6 kt = 11 y 3,1; 9 kt = 17 y 4,6;
    12 kt = 22 y 6,2; 15 kt = 28 y 7,7.
    """
    alto = 0.46
    fig, ax = lienzo_cajas(alto)
    datos = (
        (3, t("5,6 km/h · 1,5 m/s", "5.6 km/h · 1.5 m/s")),
        (6, t("11 km/h · 3,1 m/s", "11 km/h · 3.1 m/s")),
        (9, t("17 km/h · 4,6 m/s", "17 km/h · 4.6 m/s")),
        (12, t("22 km/h · 6,2 m/s", "22 km/h · 6.2 m/s")),
        (15, t("28 km/h · 7,7 m/s", "28 km/h · 7.7 m/s")),
    )
    largo, r0, r1 = 13.0, 2.2, 0.9
    for i, (nudos, conversion) in enumerate(datos):
        xc = 10 + 20 * i
        mastil, cima = xc - 7, 33
        ax.plot([mastil, mastil], [12, cima + 1], color=ESTRUCTURA, lw=2.4,
                solid_capstyle="round", zorder=3)
        # Cuantas más franjas llenas, menos cuelga: de 64° con una a 0° con cinco.
        caida = np.radians(16 * (4 - i))
        d = np.array([np.cos(caida), -np.sin(caida)])
        n = np.array([-d[1], d[0]])
        base = np.array([mastil, cima - 2 * r0]) + n * r0
        for k in range(5):
            a, b = k / 5, (k + 1) / 5
            ra, rb = r0 + (r1 - r0) * a, r0 + (r1 - r0) * b
            pa, pb = base + d * largo * a, base + d * largo * b
            ax.add_patch(mpatches.Polygon([pa + n * ra, pb + n * rb, pb - n * rb, pa - n * ra],
                                          closed=True, lw=1.0, edgecolor=ESTRUCTURA,
                                          facecolor=RESISTENCIA if k % 2 == 0 else FONDO,
                                          zorder=4))
        ax.text(xc, 8.8, f"≈ {nudos} kt" if i < 4 else t(f"≈ {nudos} kt o más", f"≈ {nudos} kt or more"),
                ha="center", va="center", fontsize=CUERPO + 1, fontweight="bold", color=ESTRUCTURA)
        ax.text(xc, 4.6, conversion if i < 4 else conversion + t(" o más", " or more"),
                ha="center", va="center", fontsize=MENOR, color=TEXTO)

    ax.add_patch(mpatches.FancyArrow(4, 41.5, 22, 0, width=1.6, head_width=4.2,
                                     head_length=3.5, length_includes_head=True,
                                     facecolor=FONDO, edgecolor=SUSTENTACION, lw=1.6))
    ax.text(31, 41.5, t("Viento: la manga apunta hacia donde va",
                        "Wind: the sock points the way it is blowing"),
            ha="left", va="center", fontsize=MENOR, color=TEXTO)
    ax.text(99, 0.6, t("Referencia orientativa: unos 3 kt por franja llena, no una norma",
                       "Rough guide: about 3 kt per filled band, not a rule"),
            ha="right", va="center", fontsize=MENOR, color=TEXTO, style="italic")
    return guardar(fig, destino("01-cap10-manga-viento.png"))


# --------------------------------------------------------------------------
# cap13 — Pirámide de gravedad de sucesos
# --------------------------------------------------------------------------
def piramide_sucesos():
    """Las tres categorías de suceso del Reglamento 996/2010, sin cifras.

    Fuente (cap13…qmd, «Definiciones clave»): accidente, incidente grave («casi
    pasa») e incidente («afecta o puede afectar a la seguridad»). La proporción
    de Heinrich (1931) —1 lesión grave, 29 leves, 300 sin lesión— es de accidentes
    laborales y sólo va como nota: no son las categorías del reglamento
    (hallazgo TEC-15).
    """
    alto = 0.6
    fig, ax = lienzo_cajas(alto)
    cima, base, izq, der = (50, 55), 9, 16, 84

    def ancho(y):
        return (der - izq) * (cima[1] - y) / (cima[1] - base)

    pisos = (
        (base, 24, TONO_CLARO, ESTRUCTURA, t("Incidente", "Incident"),
         t("afecta o puede afectar a la seguridad", "affects or could affect safety")),
        (24, 39, TONO_MEDIO, FONDO, t("Incidente grave", "Serious incident"),
         t("casi fue un accidente", "almost an accident")),
        (39, cima[1], ESTRUCTURA, FONDO, t("Accidente", "Accident"), None),
    )
    for y0, y1, relleno, color, nombre, glosa in pisos:
        w0, w1 = ancho(y0) / 2, ancho(y1) / 2
        ax.add_patch(mpatches.Polygon([(50 - w0, y0), (50 + w0, y0), (50 + w1, y1), (50 - w1, y1)],
                                      closed=True, facecolor=relleno, edgecolor=FONDO,
                                      lw=2.0, zorder=2))
        yt = y0 + (y1 - y0) * (0.3 if glosa is None else 0.6)
        ax.text(50, yt, nombre, ha="center", va="center", fontsize=CUERPO + 2,
                fontweight="bold", color=color, zorder=3)
        if glosa:
            ax.text(50, y0 + (y1 - y0) * 0.27, glosa, ha="center", va="center",
                    fontsize=MENOR, color=color, zorder=3)

    for xa, (ya, yb), rotulo in ((8, (12, 52), t("Más grave", "More serious")),
                                 (92, (52, 12), t("Más frecuente", "More frequent"))):
        ax.annotate("", xy=(xa, yb), xytext=(xa, ya),
                    arrowprops=dict(arrowstyle="-|>,head_length=0.6,head_width=0.3",
                                    color=ESTRUCTURA, lw=1.8))
        ax.text(xa + (-2 if xa < 50 else 2), 32, rotulo, ha="center", va="center",
                rotation=90, fontsize=CUERPO, fontweight="bold", color=ESTRUCTURA)

    ax.text(50, 3.2, t("Heinrich (1931), en accidentes laborales: por cada lesión grave, "
                       "29 leves y 300 sucesos sin lesión",
                       "Heinrich (1931), on industrial accidents: for every serious injury, "
                       "29 minor ones and 300 occurrences without injury"),
            ha="center", va="center", fontsize=MENOR, color=TEXTO, style="italic")
    return guardar(fig, destino("01-cap13-piramide-sucesos.png"))


# --------------------------------------------------------------------------
# cap04 — ¿Puedo volar hoy como piloto al mando?
# --------------------------------------------------------------------------
def recencia_requisitos():
    """Los tres filtros: médico, recencia general y recencia del método.

    Fuente (cap04…qmd, «Experiencia reciente: la regla de los 24 meses» y
    «Además, por cada método de lanzamiento»):
      * SFCL.160 a): en los últimos 24 meses, 5 h, 15 lanzamientos y 2 vuelos de
        entrenamiento con instructor; si falta algo, completarlo con instructor
        (doble mando o solo bajo supervisión) o pasar una verificación de
        competencia (SFCL.160 c));
      * SFCL.155: 5 lanzamientos en 24 meses con cada método, 2 con cable
        elástico; si faltan, completarlos en doble mando o solo bajo supervisión.
    Los TMG tienen otra recencia (SFCL.160 b)) y quedan fuera.
    """
    alto = 1.0
    fig, ax = lienzo_cajas(alto)
    xd, wd, xs, ws = 28, 54, 80.5, 37    # columna de preguntas y de salidas «No»

    caja(ax, xd, 95, 52, 6.5, t("¿Puedo volar hoy como piloto al mando?",
                                "Can I fly today as pilot-in-command?"),
         negrita=True, trazo=1.8)
    preguntas = (
        (79, 9, t("¿Certificado médico válido?", "Valid medical certificate?"),
         t("No puedes ejercer las\natribuciones de tu licencia",
           "You cannot exercise the\nprivileges of your licence"), False),
        (56, 13, t("En los últimos 24 meses, ¿5 h, 15 lanzamientos\n"
                   "y 2 vuelos de entrenamiento con instructor?\n(SFCL.160)",
                   "In the last 24 months: 5 h, 15 launches\n"
                   "and 2 training flights with an instructor?\n(SFCL.160)"),
         t("Completa lo que falte con\ninstructor, en doble mando o\nsolo "
           "bajo supervisión, o pasa\nuna verificación de competencia",
           "Complete what is missing with\nan instructor, dual or solo\nunder "
           "supervision, or pass a\nproficiency check"), True),
        (31, 13, t("Con el método de lanzamiento de hoy,\n¿5 lanzamientos en 24 meses\n"
                   "(2 si es cable elástico)? (SFCL.155)",
                   "With today’s launch method:\n5 launches in 24 months\n"
                   "(2 for bungee)? (SFCL.155)"),
         t("Completa los que falten en\ndoble mando o solo bajo\nsupervisión de un instructor",
           "Complete the missing ones\ndual or solo under an\ninstructor’s supervision"), True),
    )
    flecha(ax, (xd, 91.75), (xd, 79 + 9 / 2 + 0.3))
    for i, (y, h, pregunta, salida, vuelve) in enumerate(preguntas):
        caja(ax, xd, y, wd, h, pregunta, trazo=2.0)
        hs = 13 if vuelve else 9
        caja(ax, xs, y, ws, hs, salida, borde=ATENCION, trazo=2.0,
             estilo="-" if not vuelve else (0, (4, 2)))
        if vuelve:
            # La salida se recupera: ida en ámbar, vuelta a la pregunta en navy.
            flecha(ax, (xd + wd / 2, y + 2), (xs - ws / 2, y + 2), color=ATENCION)
            ax.text((xd + wd / 2 + xs - ws / 2) / 2, y + 3.4, "No", ha="center",
                    va="bottom", fontsize=MENOR, color=ATENCION, fontweight="bold")
            flecha(ax, (xs - ws / 2, y - 2.5), (xd + wd / 2, y - 2.5))
            ax.text((xd + wd / 2 + xs - ws / 2) / 2, y - 3.6, t("hecho", "done"),
                    ha="center", va="top", fontsize=MENOR, color=ESTRUCTURA)
        else:
            flecha(ax, (xd + wd / 2, y), (xs - ws / 2, y), color=ATENCION)
            ax.text((xd + wd / 2 + xs - ws / 2) / 2, y + 1.4, "No", ha="center",
                    va="bottom", fontsize=MENOR, color=ATENCION, fontweight="bold")
        siguiente = preguntas[i + 1][0] + preguntas[i + 1][1] / 2 if i < 2 else 13 + 4
        flecha(ax, (xd, y - h / 2), (xd, siguiente + 0.3), color=SEGURA)
        ax.text(xd + 1.2, (y - h / 2 + siguiente) / 2, t("Sí", "Yes"), ha="left",
                va="center", fontsize=MENOR, color=SEGURA, fontweight="bold")

    caja(ax, xd, 13, 40, 8, t("Puedes volar", "You can fly"), borde=SEGURA,
         color_texto=SEGURA, tam=CUERPO + 2, negrita=True, trazo=2.4)
    ax.text(1, 3, t("Planeadores; los TMG tienen su propia recencia (SFCL.160 b)).",
                    "Sailplanes; TMGs have their own recency rules (SFCL.160(b))."),
            ha="left", va="center", fontsize=MENOR, color=TEXTO, style="italic")
    return guardar(fig, destino("01-cap04-recencia-requisitos.png"))


# --------------------------------------------------------------------------
# cap08 — Las tres fases del servicio de alerta
# --------------------------------------------------------------------------
def fases_emergencia():
    """INCERFA, ALERFA y DETRESFA, con lo que dispara cada una.

    Fuente (cap08…qmd, «3. Servicio de alerta (ALRS)», corregido en la auditoría
    según ATS.TR.405 del Reglamento de Ejecución (UE) 2017/373): los criterios de
    cada fase; los medios de búsqueda y salvamento salen en DETRESFA; en DETRESFA
    basta un peligro grave e inminente O necesitar asistencia inmediata; el RCC
    está informado desde la fase de incertidumbre.
    """
    alto = 0.57
    fig, ax = lienzo_cajas(alto)
    ax.set_ylim(7, 7 + 100 * alto)
    xs, ancho = (16, 50, 84), 28
    fases = (
        ("1", "INCERFA", t("Incertidumbre", "Uncertainty"), TONO_CLARO, ESTRUCTURA,
         t("Sin comunicación 30 min\ndespués de lo previsto,\no sin llegar 30 min después\n"
           "de su hora prevista",
           "No communication 30 min\nafter it was due, or not\narrived 30 min after its\n"
           "expected arrival time"),
         t("Se recaba información", "Information is gathered")),
        ("2", "ALERFA", t("Alerta", "Alert"), TONO_MEDIO, FONDO,
         t("Siguen sin noticias; o no\naterriza 5 min después de\nlo previsto tras ser "
           "autorizada;\no su eficiencia operativa\nestá afectada",
           "Still no news; or not landed\n5 min after the expected\ntime once cleared; or its\n"
           "operating efficiency\nis impaired"),
         t("Aumenta la preocupación", "Concern grows")),
        ("3", "DETRESFA", t("Peligro", "Distress"), ESTRUCTURA, FONDO,
         t("Peligro grave e inminente\no necesidad de asistencia\ninmediata (p. ej., "
           "aterrizaje\nforzoso)",
           "Grave and imminent danger\nor need for immediate\nassistance (e.g. a forced\n"
           "landing)"),
         t("Salen los medios de\nbúsqueda y salvamento", "Search and rescue\nunits are dispatched")),
    )
    for x, (num, nombre, glosa, relleno, color, criterio, accion) in zip(xs, fases):
        ax.add_patch(mpatches.FancyBboxPatch((x - ancho / 2, 50), ancho, 13,
                                             boxstyle="round,pad=0,rounding_size=1.6",
                                             facecolor=relleno, edgecolor=ESTRUCTURA,
                                             lw=1.4, zorder=2))
        ax.text(x, 59, f"{num} · {nombre}", ha="center", va="center", fontsize=CUERPO + 2,
                fontweight="bold", color=color, zorder=3)
        ax.text(x, 53.6, glosa, ha="center", va="center", fontsize=CUERPO, color=color, zorder=3)
        caja(ax, x, 35, ancho, 27, "", trazo=1.4)
        ax.text(x, 46.5, criterio, ha="center", va="top", fontsize=MENOR, color=TEXTO,
                linespacing=1.25, zorder=3)
        ax.text(x, 25.5, accion, ha="center", va="center", fontsize=MENOR, color=ESTRUCTURA,
                fontweight="bold", linespacing=1.2, zorder=3)
    for a, b in zip(xs, xs[1:]):
        flecha(ax, (a + ancho / 2 + 0.3, 56.5), (b - ancho / 2 - 0.3, 56.5))

    ax.add_patch(mpatches.FancyArrow(xs[0] - ancho / 2, 13, 99 - (xs[0] - ancho / 2), 0,
                                     width=7, head_width=9.5, head_length=2.5,
                                     length_includes_head=True, facecolor=BANDA,
                                     edgecolor="none", zorder=1))
    ax.text(48, 13, t("Desde INCERFA, el ATS informa al centro coordinador\n"
                     "de salvamento (RCC) (ATS.TR.405)",
                     "From INCERFA, ATS informs the rescue coordination\n"
                     "centre (RCC) (ATS.TR.405)"),
            ha="center", va="center", fontsize=MENOR, color=TEXTO, linespacing=1.2, zorder=2)
    return guardar(fig, destino("01-cap08-fases-emergencia.png"))


# --------------------------------------------------------------------------
# cap01 — Normativa vinculante y estándares no vinculantes
# --------------------------------------------------------------------------
def estructura_normativa_easa():
    """Las capas del sistema normativo de EASA, con las CS aparte.

    Fuente (cap01…qmd, «Estructura normativa…»): Reglamento base (UE) 2018/1139;
    reglamentos de ejecución, p. ej. el 2018/1976 (Part-SFCL y Part-SAO); AMC,
    GM y CS como estándares no vinculantes. Las CS son especificaciones para
    certificar aeronaves y productos (CS-22, planeadores), no medios de
    cumplimiento (hallazgo PED-04).
    """
    alto = 0.6
    fig, ax = lienzo_cajas(alto)
    izq = 12

    ax.annotate("", xy=(7, 4), xytext=(7, 58),
                arrowprops=dict(arrowstyle="-|>,head_length=0.8,head_width=0.45",
                                color=ESTRUCTURA, lw=2.4))
    ax.text(3.2, 31, t("Fuerza legal", "Legal force"), ha="center", va="center",
            rotation=90, fontsize=CUERPO, fontweight="bold", color=ESTRUCTURA)

    ax.add_patch(mpatches.FancyBboxPatch((izq, 32), 99 - izq, 27,
                                         boxstyle="round,pad=0,rounding_size=2",
                                         facecolor=ESTRUCTURA, edgecolor=ESTRUCTURA, zorder=1))
    ax.text(izq + 2, 55.5, t("Normativa vinculante: QUÉ debes cumplir",
                             "Binding rules: WHAT you must comply with"),
            ha="left", va="center", fontsize=CUERPO + 1, fontweight="bold", color=FONDO)
    caja(ax, 33, 42, 38, 12, t("Reglamento base\nReglamento (UE) 2018/1139",
                               "Basic Regulation\nRegulation (EU) 2018/1139"),
         borde=FONDO, trazo=0)
    caja(ax, 77, 42, 38, 12, t("Reglamentos de ejecución (IR)\np. ej., 2018/1976:\n"
                               "Part-SFCL y Part-SAO",
                               "Implementing Rules (IR)\ne.g. 2018/1976:\nPart-SFCL and Part-SAO"),
         borde=FONDO, trazo=0)
    flecha(ax, (52.3, 42), (57.7, 42), color=FONDO)

    ax.add_patch(mpatches.FancyBboxPatch((izq, 1), 99 - izq, 28,
                                         boxstyle="round,pad=0,rounding_size=2",
                                         facecolor=FONDO, edgecolor=ESTRUCTURA, lw=1.8, zorder=1))
    ax.text(izq + 2, 25.5, t("Estándares no vinculantes", "Non-binding standards"),
            ha="left", va="center", fontsize=CUERPO + 1, fontweight="bold", color=ESTRUCTURA)
    caja(ax, 25, 12, 24, 15, t("AMC\nCÓMO cumplir\nde forma reconocida",
                               "AMC\nHOW to comply\nin a recognised way"))
    caja(ax, 51, 12, 24, 15, t("GM\nexplicaciones\ny ejemplos", "GM\nexplanations\nand examples"))
    ax.plot([66, 66], [3, 22], color=ESTRUCTURA, lw=1.0, ls=(0, (3, 3)))
    caja(ax, 82, 12, 28, 15, t("CS\nespecificaciones para\ncertificar aeronaves\n(p. ej., CS-22)",
                               "CS\nspecifications for\ncertifying aircraft\n(e.g. CS-22)"),
         estilo=(0, (4, 2)))
    ax.text(38, 21.5, t("ayudan a cumplir los IR", "help you comply with the IR"),
            ha="center", va="center", fontsize=MENOR, color=TEXTO, style="italic")
    ax.text(82, 21.5, t("otra cosa: certificación", "something else: certification"),
            ha="center", va="center", fontsize=MENOR, color=TEXTO, style="italic")
    return guardar(fig, destino("01-cap01-estructura-normativa-easa.png"))


# --------------------------------------------------------------------------
# cap09 — Los campos de un NOTAM
# --------------------------------------------------------------------------
def ejemplo_notam():
    """Extracto de NOTAM con los campos A, B, C y E que explica el texto.

    Fuente (cap09…qmd, «Noticias urgentes: NOTAM»): el ejemplo de LEZG con
    B) 2310250800 = 25-10-2023 08:00 UTC. Las pistas de Zaragoza son 12L/30R y
    12R/30L (AIP España, AD 2 LEZG, archivado en recursos/fuentes/aip/), y
    «cerrada» se abrevia CLSD (OACI, Doc 8400).

    ⚠️ El NOTAM va en DejaVu Sans Mono, la monoespaciada que trae matplotlib: así
    se lee como un NOTAM impreso. Es la única excepción a Libertinus Sans, y no
    depende de las fuentes del sistema.
    """
    alto = 0.46
    fig, ax = lienzo_cajas(alto)
    ax.text(1, 43, t("Extracto de un NOTAM (ejemplo)", "Extract of a NOTAM (example)"),
            ha="left", va="center", fontsize=CUERPO + 1, fontweight="bold", color=ESTRUCTURA)
    ax.add_patch(mpatches.FancyBboxPatch((2, 4), 47, 33, boxstyle="round,pad=0,rounding_size=1.6",
                                         facecolor=BANDA, edgecolor=ESTRUCTURA, lw=1.4))
    lineas = (
        ("A) LEZG", t("Lugar: aeropuerto de Zaragoza", "Location: Zaragoza airport")),
        ("B) 2310250800", t("Inicio: 25-10-2023, 08:00 UTC", "Start: 25-10-2023, 08:00 UTC")),
        ("C) 2310252000", t("Fin: 25-10-2023, 20:00 UTC", "End: 25-10-2023, 20:00 UTC")),
        ("E) RWY 12R/30L CLSD", t("Texto: pista 12R/30L cerrada", "Text: runway 12R/30L closed")),
    )
    for i, (campo, llamada) in enumerate(lineas):
        y = 31 - 7.5 * i
        ax.text(5, y, campo, ha="left", va="center", fontsize=CUERPO + 1,
                family="DejaVu Sans Mono", color=TEXTO)
        ax.plot([49, 55], [y, y], color=ESTRUCTURA, lw=1.2)
        ax.plot(55, y, "o", ms=4, color=ESTRUCTURA)
        letra, resto = llamada.split(":", 1)
        ax.text(57, y, f"{campo[0]} · {letra}:{resto}", ha="left", va="center",
                fontsize=CUERPO, color=TEXTO)
    return guardar(fig, destino("01-cap09-ejemplo-notam.png"))


# --------------------------------------------------------------------------
# cap02 — El formulario EASA 25
# --------------------------------------------------------------------------
def certificado_aeronavegabilidad():
    """Modelo del certificado de aeronavegabilidad de un planeador, sin validez.

    Fuente: Reglamento (UE) 748/2012, anexo I (Parte 21), apéndice VI,
    «Certificado de aeronavegabilidad. Formulario EASA 25», edición 3 (pág. 130
    del consolidado de 07-08-2026, en recursos/fuentes/ue/). Los textos de las
    casillas 5 y 6 y del pie son los del reglamento, palabra por palabra.

    ⚠️ Decisiones de Ramón (20-11-2026): la casilla 4, «Categorías», va en blanco,
    porque no se ha cotejado con un CofA real de planeador; y la línea final, que
    pide llevarlo a bordo, se conserva y la explica el pie (SAO.GEN.155 c)
    permite tenerlo en el aeródromo). Sin escudo, logotipo, sello ni firma: la
    guía no permite imitar documentos oficiales (hallazgo COH-07).

    La versión inglesa del formulario no está archivada; sus textos son los de la
    versión inglesa del reglamento y están por cotejar en EUR-Lex.
    """
    alto = 0.78
    fig, ax = lienzo_cajas(alto)
    ax.set_ylim(-6, -6 + 100 * alto)
    ancho_linea = 92

    def marco(x0, y0, x1, y1):
        ax.add_patch(mpatches.Rectangle((x0, y0), x1 - x0, y1 - y0, fill=False,
                                        edgecolor=ESTRUCTURA, lw=1.2, zorder=2))

    def etiqueta(x, y, texto, tam=MENOR):
        ax.text(x, y, texto, ha="left", va="top", fontsize=tam, color=TEXTO,
                linespacing=1.2, zorder=3)

    marco(2, 2, 98, 70)
    ax.text(48, 66, t("CERTIFICADO DE AERONAVEGABILIDAD", "CERTIFICATE OF AIRWORTHINESS"),
            ha="center", va="center", fontsize=CUERPO + 3, fontweight="bold", color=ESTRUCTURA)
    ax.text(48, 62, t("[Estado miembro de matrícula]", "[Member State of registry]"),
            ha="center", va="center", fontsize=CUERPO, color=TEXTO)
    ax.text(48, 58.6, t("[AUTORIDAD COMPETENTE DEL ESTADO MIEMBRO]",
                        "[COMPETENT AUTHORITY OF THE MEMBER STATE]"),
            ha="center", va="center", fontsize=CUERPO, color=TEXTO)
    for x in (5, 77):
        ax.text(x, 62, "(*)", ha="center", va="center", fontsize=MENOR, color=TEXTO)
    ax.add_patch(mpatches.Rectangle((80, 56.5), 17, 12, fill=False, edgecolor=ESTRUCTURA,
                                    lw=1.0, ls=(0, (3, 2))))
    ax.text(88.5, 62.5, t("Logotipo de la\nautoridad\ncompetente", "Competent\nauthority\nlogo"),
            ha="center", va="center", fontsize=MENOR, color=TEXTO, linespacing=1.1)

    # Casillas 1 a 3, con los datos del ejemplo; la 4, en blanco.
    marco(2, 43, 28, 55); marco(28, 43, 74, 55); marco(74, 43, 98, 55)
    etiqueta(3, 54.3, t("1. Nacionalidad y marcas\nde matrícula", "1. Nationality and\nregistration marks"))
    etiqueta(29, 54.3, t("2. Fabricante y designación del fabricante\nde la aeronave",
                         "2. Manufacturer and manufacturer’s\ndesignation of aircraft"))
    etiqueta(75, 54.3, t("3. Número de serie de\nla aeronave", "3. Aircraft serial\nnumber"))
    for x, valor in ((15, "EC-ABC"),
                     (51, t("Ejemplo · planeador biplaza PE-2",
                            "Example · PE-2 two-seat glider")),
                     (86, "001")):
        ax.text(x, 46.3, valor, ha="center", va="center", fontsize=CUERPO,
                fontweight="bold", color=ESTRUCTURA)
    marco(2, 37, 98, 43)
    etiqueta(3, 42.3, t("4. Categorías", "4. Categories"))

    # Casilla 5: base jurídica, limitaciones, fecha y firma.
    marco(2, 15, 98, 37)
    texto5 = t("5. El presente certificado de aeronavegabilidad se expide con arreglo al Convenio sobre "
               "Aviación Civil Internacional de 7 de diciembre de 1944 y el Reglamento (UE) 2018/1139 "
               "del Parlamento Europeo y del Consejo respecto a la aeronave anteriormente mencionada, "
               "que se considera aeronavegable cuando se mantiene y se opera con arreglo a lo "
               "precedente y a las limitaciones de operación pertinentes.",
               "5. This Certificate of Airworthiness is issued pursuant to the Convention on "
               "International Civil Aviation dated 7 December 1944 and Regulation (EU) 2018/1139 of "
               "the European Parliament and of the Council in respect of the above-mentioned aircraft "
               "which is considered to be airworthy when maintained and operated in accordance with "
               "the foregoing and the pertinent operating limitations.")
    etiqueta(3, 36.2, textwrap.fill(texto5, ancho_linea))
    etiqueta(3, 24.2, t("Limitaciones/Observaciones:", "Limitations/Remarks:"))
    etiqueta(3, 19.4, t("Fecha de expedición:", "Date of issue:"))
    etiqueta(55, 19.4, t("Firma:", "Signature:"))

    # Casilla 6: validez y ARC.
    marco(2, 5, 98, 15)
    texto6 = t("6. El presente certificado de aeronavegabilidad es válido a menos que sea revocado por la "
               "autoridad competente del Estado miembro de matrícula. Se adjuntará al presente "
               "certificado un certificado de revisión de la aeronavegabilidad actualizado.",
               "6. This Certificate of Airworthiness is valid unless revoked by the competent authority "
               "of the Member State of registry. A current Airworthiness Review Certificate shall be "
               "attached to this Certificate.")
    etiqueta(3, 14.2, textwrap.fill(texto6, ancho_linea))
    ax.text(3, 3.5, t("Formulario EASA 25, edición 3", "EASA Form 25 Issue 3"),
            ha="left", va="center", fontsize=MENOR, color=TEXTO)
    ax.text(97, 3.5, t("(*) Para uso del Estado de matrícula.", "(*) For use by the State of registry."),
            ha="right", va="center", fontsize=MENOR, color=TEXTO)
    ax.text(50, -2.5, t("El presente certificado de aeronavegabilidad deberá llevarse a bordo durante "
                        "todos los vuelos.",
                        "This Certificate of Airworthiness shall be carried on board during all flights."),
            ha="center", va="center", fontsize=MENOR, color=TEXTO, style="italic")

    ax.text(50, 30, t("EJEMPLO", "EXAMPLE"), ha="center", va="center", fontsize=64,
            fontweight="bold", color=ESTRUCTURA, alpha=0.1, rotation=22, zorder=1)
    return guardar(fig, destino("01-cap02-certificado-aeronavegabilidad.png"))


# --------------------------------------------------------------------------
# cap10 — Las señales del área de señales
# --------------------------------------------------------------------------
AMARILLO = "#FFD200"   # el amarillo de los paneles de SERA, sólo en esta figura
PISTA = "#6B7280"


def silueta(ax, formas, relleno=FONDO, borde=ESTRUCTURA):
    """Une varias formas en una silueta con un solo contorno: primero todos los
    bordes, luego todos los rellenos encima, que tapan los bordes interiores."""
    for f in formas:
        f.set(facecolor=borde, edgecolor=borde, lw=2.6, zorder=4)
        ax.add_patch(f)
    for f in formas:
        ax.add_patch(mpatches.PathPatch(f.get_path().transformed(f.get_patch_transform()),
                                        facecolor=relleno, edgecolor="none", zorder=5))


def senales_aerodromo():
    """Nueve señales del área de señales, con su significado.

    Fuente: Reglamento de Ejecución (UE) 923/2012 (SERA), apéndice 1, 3.2, y sus
    figuras A1-1 a A1-11 (págs. 96-97 del consolidado de 01-05-2025, en
    recursos/fuentes/ue/). Las formas copian las de esas figuras: la T con el
    travesaño a un lado y el brazo hacia el otro, la flecha acodada, las cruces
    en aspa y la doble cruz. La manga tiene su propia figura y no se repite.

    Corrige (hallazgo TEC-06): las pesas no exigen pistas pavimentadas, sino
    usar sólo pistas y calles de rodaje; el aspa amarilla prohíbe aterrizar, sin
    que el aeródromo tenga por qué estar cerrado.
    """
    alto = 0.92
    fig, ax = lienzo_cajas(alto)
    R = mpatches.Rectangle

    def panel_rojo(c, diagonales):
        x, y = c
        ax.add_patch(R((x - 5.5, y - 5.5), 11, 11, facecolor=RESISTENCIA, edgecolor=ESTRUCTURA,
                       lw=1.2, zorder=4))
        tramos = [((-4.7, -4.7), (4.7, 4.7)), ((-4.7, 4.7), (4.7, -4.7))][:diagonales]
        for (x0, y0), (x1, y1) in tramos:
            ax.plot([x + x0, x + x1], [y + y0, y + y1], color=AMARILLO, lw=7,
                    solid_capstyle="butt", zorder=5)

    def pesas(c, barras):
        x, y = c
        silueta(ax, [mpatches.Circle((x - 4, y), 2.6), mpatches.Circle((x + 4, y), 2.6),
                     R((x - 4, y - 0.8), 8, 1.6)])
        if barras:
            for xb in (x - 4, x + 4):
                ax.add_patch(R((xb - 0.55, y - 2.6), 1.1, 5.2, facecolor="black",
                               edgecolor="none", zorder=6))

    def cruz_pista(c):
        x, y = c
        ax.add_patch(R((x - 8.5, y - 3.8), 17, 7.6, facecolor=PISTA, edgecolor="none", zorder=4))
        for d in (1, -1):
            ax.plot([x - 2.8, x + 2.8], [y - 2.8 * d, y + 2.8 * d], color=FONDO, lw=5,
                    solid_capstyle="butt", zorder=5)

    def te(c):
        x, y = c
        silueta(ax, [R((x - 5.5, y - 4), 1.6, 8), R((x - 4.2, y - 0.8), 9.5, 1.6)])
        ax.annotate("", xy=(x - 2.5, y - 4.4), xytext=(x + 5.5, y - 4.4), zorder=6,
                    arrowprops=dict(arrowstyle="-|>,head_length=0.5,head_width=0.25",
                                    color=ESTRUCTURA, lw=1.3))

    def flecha_derecha(c):
        x, y = c
        puntos = [(-4, -5), (-2.4, -5), (-2.4, 1.2), (2.5, 1.2), (2.5, -0.6), (5.5, 2.0),
                  (2.5, 4.6), (2.5, 2.8), (-4, 2.8)]
        ax.add_patch(mpatches.Polygon([(x + px, y + py) for px, py in puntos], closed=True,
                                      facecolor=AMARILLO, edgecolor=ESTRUCTURA, lw=1.4, zorder=4))

    def letra_c(c):
        x, y = c
        ax.add_patch(R((x - 4.5, y - 5), 9, 10, facecolor=AMARILLO, edgecolor=ESTRUCTURA,
                       lw=1.2, zorder=4))
        ax.text(x, y, "C", ha="center", va="center", fontsize=22, fontweight="bold",
                color="black", zorder=5)

    def doble_cruz(c):
        x, y = c
        silueta(ax, [R((x - 6, y - 0.8), 12, 1.6), R((x - 3.3, y - 3.5), 1.6, 7),
                     R((x + 1.7, y - 3.5), 1.6, 7)])

    celdas = (
        (lambda c: panel_rojo(c, 2), t("Prohibido aterrizar", "Landing prohibited"),
         t("la prohibición puede\nprolongarse", "the prohibition may\nbe prolonged")),
        (lambda c: panel_rojo(c, 1), t("Precaución", "Special precautions"),
         t("al aproximar y aterrizar", "on approach and landing")),
        (te, t("T de aterrizaje", "Landing T"),
         t("aterriza paralelo al brazo,\nhacia el travesaño", "land parallel to the stem,\ntowards the cross-arm")),
        (lambda c: pesas(c, False), t("Pesas", "Dumb-bell"),
         t("aterrizar, despegar y rodar sólo\nen pistas y calles de rodaje",
           "land, take off and taxi only\non runways and taxiways")),
        (lambda c: pesas(c, True), t("Pesas con barras negras", "Dumb-bell with black bars"),
         t("aterrizar y despegar sólo en\npistas; lo demás, libre",
           "land and take off only on\nrunways; other manoeuvres free")),
        (cruz_pista, t("Cruces en pista o calle", "Crosses on runway or taxiway"),
         t("zona no utilizable (blancas en\npista, amarillas en calle)",
           "area unusable (white on\nrunways, yellow on taxiways)")),
        (flecha_derecha, t("Flecha a la derecha", "Right-hand arrow"),
         t("virajes a la derecha antes de\naterrizar y tras despegar",
           "turn right before landing\nand after take-off")),
        (letra_c, t("Letra C", "Letter C"),
         t("oficina de notificación\nde los servicios ATS", "ATS reporting\noffice")),
        (doble_cruz, t("Doble cruz blanca", "Double white cross"),
         t("planeadores en vuelo", "gliders flying")),
    )
    for i, (dibujo, nombre, significado) in enumerate(celdas):
        fila, columna = divmod(i, 3)
        xc, ytop = 17 + 33 * columna, 90 - 30.5 * fila
        centro = (xc, ytop - 8.5)
        ax.add_patch(mpatches.FancyBboxPatch((xc - 10, ytop - 16.5), 20, 16,
                                             boxstyle="round,pad=0,rounding_size=1.2",
                                             facecolor=SUELO, edgecolor="none", zorder=1))
        dibujo(centro)
        ax.text(xc, ytop - 19, nombre, ha="center", va="center", fontsize=CUERPO,
                fontweight="bold", color=ESTRUCTURA)
        ax.text(xc, ytop - 21, significado, ha="center", va="top", fontsize=MENOR,
                color=TEXTO, linespacing=1.2)
    return guardar(fig, destino("01-cap10-senales-aerodromo.png"))


FIGURAS = {
    "01-cap02-certificado-aeronavegabilidad": certificado_aeronavegabilidad,
    "01-cap10-senales-aerodromo": senales_aerodromo,
    "01-cap01-estructura-normativa-easa": estructura_normativa_easa,
    "01-cap04-recencia-requisitos": recencia_requisitos,
    "01-cap08-fases-emergencia": fases_emergencia,
    "01-cap09-ejemplo-notam": ejemplo_notam,
    "01-cap02-ciclo-arc": ciclo_arc,
    "01-cap04-validez-medical": validez_medical,
    "01-cap06-minimos-vmc": minimos_vmc,
    "01-cap10-manga-viento": manga_viento,
    "01-cap13-piramide-sucesos": piramide_sucesos,
    "01-cap06-regla-semicircular": regla_semicircular,
    "01-cap13-flujo-notificacion": flujo_notificacion,
    "01-cap14-escala-infracciones": escala_infracciones,
}


def main(argv):
    global IDIOMA
    argv = list(argv[1:])
    if argv[:1] == ["--lang"]:
        IDIOMA = argv[1] if len(argv) > 1 else ""
        argv = argv[2:]
    if IDIOMA not in DESTINOS:
        raise SystemExit(f"Idioma desconocido «{IDIOMA}». Disponibles: {', '.join(DESTINOS)}")
    DESTINOS[IDIOMA].mkdir(parents=True, exist_ok=True)
    usar_estilo()
    for nombre in (argv or list(FIGURAS)):
        if nombre not in FIGURAS:
            raise SystemExit(f"No conozco «{nombre}». Disponibles: {', '.join(FIGURAS)}")
        ruta = FIGURAS[nombre]()
        print(f"✓ {ruta.name} ({ruta.stat().st_size / 1024:.0f} KB)")


if __name__ == "__main__":
    main(sys.argv)
