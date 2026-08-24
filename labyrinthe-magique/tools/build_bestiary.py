#!/usr/bin/env python3
"""Le bestiaire : neuf créatures de plus, découpées de `assets/peso&cover/`.

    tools/.venv/bin/python tools/build_bestiary.py     # DEPUIS LA RACINE

Fichier SÉPARÉ de `build_characters.py`, et c'est délibéré : ce dernier est
édité en parallèle par une autre session de travail, et sa table `SHEETS`
contient déjà le gobelin (`enemi_2`) et le spectre (`enemi_1`). On réutilise
tout son pipeline — détection de grille, nettoyage des débordements, calage sur
les pieds, case commune — sans toucher à sa table.

Les onze planches suivent une convention régulière, vérifiée sur les neuf :

    rangée 0   de face      rangée 2   de profil (sert aux deux côtés)
    rangée 1   de dos       rangée 3   poses d'attaque
    rangée 4+  effets, particules, portrait

C'est la SEULE convention qu'on leur suppose. Les rangées sont écrites à la
main dans la table ci-dessous : se tromper de rangée donnerait un monstre qui
marche de dos en avançant vers le joueur, un défaut qu'on ne voit qu'en jouant.

La case finale est commune AU BESTIAIRE, pas commune avec les mages : ces
créatures n'ont pas la même stature (un serpent, un minotaure), et les forcer
dans la case d'un mage les aurait toutes rétrécies au gabarit du plus large.
"""

from pathlib import Path
import json
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

import numpy as np
from build_characters import (CELL_PADDING, FRAME_HEIGHT, OUT_ENEMIES, POSES,
                              SOURCE, measure, write)

# Orientations dessinées ; la droite est le profil retourné.
ROWS = {"down": 0, "up": 1, "left": 2}
SIDES = {"right": "left"}

# id, nom affiché, et ce qu'on suppose de sa façon de se battre. La colonne
# d'attaque est prise dans la rangée 3, à la pose la plus lisible.
BESTIARY = {
    "enemi_0.png": {"id": "serpent", "name": "Serpent d'Émeraude",
                    "attack": {"row": 2, "col": 4}},
    # Grilles imposées : la détection mesurait ici un pas de DEUX rangées et
    # rendait un dos coupé en deux moitiés empilées.
    "enemi_3.png": {"id": "ombre", "name": "Ombre Encapuchonnée",
                    "attack": {"row": 3, "col": 0}, "grid": (175, 171, 61, 12)},
    # Grille imposée aussi : l'auto-détection cale ici la phase sur la GRANDE
    # illustration de droite (un dragon crachant du feu sur deux cases) et place
    # la première cellule à cheval sur deux poses — la marche sautait la
    # première image et la cinquième sortait vide. Mesuré sur les centres des
    # poses : x = 121, 319, 519, 725, 911, soit un pas de 200 depuis 20.
    "enemi_4.png": {"id": "dragonnet", "name": "Dragonnet de Feu",
                    "attack": {"row": 3, "col": 0}, "grid": (200, 167, 20, 22)},
    "enemi_5.png": {"id": "golem", "name": "Golem de Lave",
                    "attack": {"row": 3, "col": 0}},
    "enemi_6.png": {"id": "archer", "name": "Archer d'Os",
                    "attack": {"row": 3, "col": 0}},
    "enemi_7.png": {"id": "cristal", "name": "Démon de Cristal",
                    "attack": {"row": 3, "col": 0}},
    # Grille imposée : même piège que le dragonnet — la phase auto se cale sur
    # la grande illustration de droite, saute la PREMIÈRE pose de chaque rangée
    # et tranche la pose de charge en case d'attaque. Centres mesurés :
    # x = 89, 253, 420, 578, 744 en face, pas de 166 depuis 6.
    "enemi_8.png": {"id": "minotaure", "name": "Minotaure",
                    "attack": {"row": 3, "col": 0}, "grid": (166, 170, 6, 0)},
    "enemi_9.png": {"id": "chevalier", "name": "Chevalier Noir",
                    "attack": {"row": 3, "col": 0}, "grid": (148, 156, 30, 12)},
    "enemi_10.png": {"id": "givre", "name": "Golem de Givre",
                     "attack": {"row": 3, "col": 0}},
}


def config_for(name: str) -> dict:
    entry = dict(BESTIARY[name])
    entry.update({
        "mode": "rangees",
        "out": OUT_ENEMIES,
        "rows": ROWS,
        "directions": list(ROWS),
        "mirror": SIDES,
    })
    return entry


def main() -> None:
    OUT_ENEMIES.mkdir(parents=True, exist_ok=True)

    measured, configs = {}, {}
    for name in BESTIARY:
        if not (SOURCE / name).exists():
            print(f"  ! {name} introuvable")
            continue
        configs[name] = config_for(name)
        try:
            measured[name] = measure(Path(name), configs[name])
        except Exception as error:                      # noqa: BLE001
            print(f"  ! {name} : {type(error).__name__} — {error}")

    if not measured:
        print("aucune planche mesurée — lancer l'outil DEPUIS LA RACINE du projet")
        return

    half = max(m["half"] * m["scale"] for m in measured.values())
    cell_width = 2 * int(np.ceil(half)) + CELL_PADDING

    catalogue = {}
    for name, entry in measured.items():
        config = configs[name]
        meta = write(config, entry, cell_width)
        catalogue[config["id"]] = {"name": config["name"], "source": name}
        grid = meta["grid"]
        print(f"{config['id']:10s} {config['name']:22s} bande "
              f"{meta['cell'][0] * len(POSES)}x{FRAME_HEIGHT}  "
              f"dx={grid['dx']} dy={grid['dy']} ox={grid['ox']} oy={grid['oy']}")

    (OUT_ENEMIES / "bestiary.json").write_text(
        json.dumps(catalogue, indent=2, ensure_ascii=False), encoding="utf-8")


if __name__ == "__main__":
    main()
