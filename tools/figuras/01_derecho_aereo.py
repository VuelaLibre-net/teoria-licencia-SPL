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
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import matplotlib.patches as mpatches
import numpy as np

from estilo import (
    ATENCION, CUERPO, ESTRUCTURA, FONDO, MENOR, SEGURA, SUSTENTACION, TEXTO,
    guardar, lienzo, usar_estilo,
)

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


FIGURAS = {
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
