"""Découpe la planche des portails de téléportation.

    tools/.venv/bin/python tools/build_portals.py

Produit une bande de six poses par couleur :

    assets/portals/<couleur>.png      idle · ouverture · ouvert · actif ·
                                      téléportation · fermeture
    assets/portals/frames.json        taille de case, couleurs, ordre des poses

POURQUOI UNE GRILLE ÉCRITE À LA MAIN
Sur les planches de mages, la grille se retrouve toute seule : les poses sont
séparées par des gouttières vides. Ici c'est impossible — chaque portail est une
LUEUR qui déborde largement de sa case, et l'opacité ne redescend jamais à zéro
entre deux colonnes. La détection automatique ne voit qu'un seul bloc de
1536x1024.

Les coordonnées ci-dessous ont donc été relevées à la règle sur l'image, en
lisant les en-têtes de colonnes (Idle, Ouverture, …) et les étiquettes de
couleur. Elles sont vérifiées par une planche de contrôle : voir la sortie de
tools/check_portals.py.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image

SOURCE = Path("assets/portail/portail_teleportation.png")
OUT = Path("assets/portals")

## Les huit couleurs, dans l'ordre des rangées de la planche.
COLORS = ["bleu", "violet", "vert", "orange", "rouge", "cyan", "rose", "jaune"]
## Les six états, dans l'ordre des colonnes.
POSES = ["idle", "ouverture", "ouvert", "actif", "teleportation", "fermeture"]

## Centre de la première case, et pas horizontal — relevés sur les en-têtes.
FIRST_COLUMN = 250.0
COLUMN_PITCH = 147.0
## Centre vertical de chaque rangée. Les valeurs ne sont PAS régulières (la
## planche dérive de quelques pixels vers le bas) : un pas constant rognait la
## rangée jaune.
ROW_CENTERS = [176.0, 276.0, 378.0, 478.0, 583.0, 684.0, 784.0, 877.0]

CELL = (147, 101)
## Hauteur finale d'une case. Le jeu affiche un portail sur ~1,5 case de 32 px.
FRAME_HEIGHT = 96


def build() -> dict:
    sheet = Image.open(SOURCE).convert("RGBA")
    OUT.mkdir(parents=True, exist_ok=True)
    width = int(round(CELL[0] * FRAME_HEIGHT / CELL[1]))

    for row, color in enumerate(COLORS):
        strip = Image.new("RGBA", (CELL[0] * len(POSES), CELL[1]), (0, 0, 0, 0))
        for column in range(len(POSES)):
            cx = FIRST_COLUMN + COLUMN_PITCH * column
            cy = ROW_CENTERS[row]
            box = (int(cx - CELL[0] / 2), int(cy - CELL[1] / 2))
            cell = sheet.crop((box[0], box[1], box[0] + CELL[0], box[1] + CELL[1]))
            strip.alpha_composite(cell, (column * CELL[0], 0))
        strip = strip.resize((width * len(POSES), FRAME_HEIGHT), Image.LANCZOS)
        strip.save(OUT / f"{color}.png")

    meta = {"cell": [width, FRAME_HEIGHT], "colors": COLORS, "poses": POSES}
    (OUT / "frames.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    return meta


def main() -> None:
    if not SOURCE.exists():
        print(f"  ! {SOURCE} introuvable")
        return
    meta = build()
    print("portails : %d couleurs x %d poses, case %dx%d" % [] if False else
          "portails : %d couleurs x %d poses, case %dx%d" % (
              len(meta["colors"]), len(meta["poses"]), meta["cell"][0], meta["cell"][1]))


if __name__ == "__main__":
    main()
