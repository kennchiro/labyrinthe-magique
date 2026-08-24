"""Découpe la planche des repaires d'ennemis.

    tools/.venv/bin/python tools/build_lairs.py

Produit une bande de six poses par couleur :

    assets/lairs/<couleur>.png    fermé · lueur · portail · ouvert · plein · éruption
    assets/lairs/frames.json

Le repaire raconte l'arrivée d'un ennemi : la porte est close, une lueur monte,
un portail s'ouvre, l'énergie jaillit du toit, puis la créature sort. Le joueur
voit donc le danger venir AVANT qu'il n'arrive — c'est tout l'intérêt de
remplacer une apparition au hasard par une maison.

Le fond est blanc uni : on le détoure par remplissage depuis les bords, comme
pour les premières planches de mages. Les colonnes se mesurent toutes seules
(les maisons ne se touchent pas) ; les rangées se mesurent DANS une colonne
étroite, parce que les grandes vignettes de gauche débordent d'une rangée sur
l'autre et brouillent le profil global.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image
from scipy import ndimage

SOURCE = Path("assets/portail/portail_enemi.png")
OUT = Path("assets/lairs")

COLORS = ["rouge", "violet", "vert", "cyan"]
POSES = ["ferme", "lueur", "portail", "ouvert", "plein", "eruption"]

## Colonnes d'animation, relevées automatiquement puis figées : la première
## vignette de chaque rangée est un PORTRAIT géant qu'on ne veut pas, et la
## dernière traîne les créatures déjà sorties, qu'on recadre.
COLUMN_STARTS = [347, 521, 701, 880, 1066, 1254]
CELL_WIDTH = 168
## Hauteur des rangées, débordement des faisceaux d'énergie compris.
ROW_TOPS = [60, 282, 514, 762]
CELL_HEIGHT = 212

## Hauteur finale d'une case. Le repaire occupe ~2,5 cases de 32 px.
FRAME_HEIGHT = 132


def cutout(image: Image.Image) -> Image.Image:
    """Détourage du fond blanc, par remplissage depuis les bords.

    Un simple seuil suffirait presque, mais il mangerait les crânes clairs et
    les bougies des façades. En partant des bords, on ne retire que ce qui est
    RELIÉ au fond."""
    rgb = np.array(image.convert("RGB")).astype(int)
    low, high = rgb.min(axis=2), rgb.max(axis=2)
    background = (low > 232) & ((high - low) < 14)
    labels, _ = ndimage.label(background)
    edges = set(labels[0]) | set(labels[-1]) | set(labels[:, 0]) | set(labels[:, -1])
    edges.discard(0)
    alpha = np.where(np.isin(labels, list(edges)), 0, 255).astype(np.uint8)
    return Image.fromarray(np.dstack([rgb, alpha]).astype(np.uint8), "RGBA")


def build() -> dict:
    sheet = cutout(Image.open(SOURCE))
    OUT.mkdir(parents=True, exist_ok=True)
    width = int(round(CELL_WIDTH * FRAME_HEIGHT / CELL_HEIGHT))

    for row, color in enumerate(COLORS):
        strip = Image.new("RGBA", (CELL_WIDTH * len(POSES), CELL_HEIGHT), (0, 0, 0, 0))
        for column, x in enumerate(COLUMN_STARTS):
            y = ROW_TOPS[row]
            cell = sheet.crop((x, y, x + CELL_WIDTH, y + CELL_HEIGHT))
            strip.alpha_composite(cell, (column * CELL_WIDTH, 0))
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
    print("repaires : %d couleurs x %d poses, case %dx%d" % (
        len(meta["colors"]), len(meta["poses"]), meta["cell"][0], meta["cell"][1]))


if __name__ == "__main__":
    main()
