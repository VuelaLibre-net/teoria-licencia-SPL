#!/usr/bin/env python3
"""Comprueba que VoiceStudio está en marcha y tiene las voces del reparto.

    voces.py            lista las voces del reparto y si existen
    voces.py --crear    diseña las que falten con el `diseno` de reparto.yml

Las voces del reparto son clones elegidos con casting.py; `--crear` sólo
puede rehacer las diseñadas (las que llevan `diseno` en reparto.yml).
"""

import argparse

import cliente as C
import guion as G


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--crear", action="store_true")
    a = ap.parse_args()

    sal = C.salud()
    print(f"VoiceStudio {sal.get('version')} en {C.BASE}: {sal.get('status')}, {sal.get('device')}")
    reparto = G.reparto()
    ids = C.perfiles()
    usadas = {r["voz"] for r in reparto["roles"].values() if "voz" in r}
    faltan = []
    for nombre in sorted(usadas):
        if nombre in ids:
            print(f"  ✓ {nombre} ({ids[nombre]})")
        else:
            faltan.append(nombre)
            print(f"  ✗ {nombre}: no existe")
    # La instrucción de estilo vive en el perfil de VoiceStudio (el render por
    # capítulos no la admite por fragmento): se sincroniza desde reparto.yml.
    perfiles = {p["name"]: p for p in C.get_json("/profiles")}
    for nombre, voz in reparto["voces"].items():
        p = perfiles.get(nombre)
        if not p:
            continue
        quiere = voz.get("instruccion") or ""
        if (p.get("instruct") or "") != quiere and (voz.get("candidata") or quiere):
            C.put_json(f"/profiles/{p['id']}", {"instruct": quiere})
            print(f"  ~ {nombre}: instrucción {'«' + quiere + '»' if quiere else 'quitada'}")
    if faltan and a.crear:
        for nombre in faltan:
            voz = reparto["voces"].get(nombre, {})
            if "diseno" in voz:
                p = C.disenar_voz(nombre, voz["diseno"])
                print(f"  + {nombre} diseñada ({voz['diseno']}) → {p.get('id')}")
            else:
                # Una voz clonada no se puede rehacer sin su grabación: la
                # rehace el casting a partir de la candidata anotada.
                print(f"  ! {nombre} es un clon de «{voz.get('candidata')}»: recréalo con "
                      f"`casting.py referencias {voz.get('candidata')}` y `clonar`, y renombra "
                      f"«CAST {voz.get('candidata')}» a «{nombre}».")
    elif faltan:
        raise SystemExit("Faltan voces. Créalas con `make audio-voces CREAR=1`.")


if __name__ == "__main__":
    main()
