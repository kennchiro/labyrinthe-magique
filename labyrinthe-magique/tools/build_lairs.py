"""Découpe la planche des repaires d'ennemis.

    tools/.venv/bin/python tools/build_lairs.py

Produit une bande de six poses par couleur :

    assets/lairs/<couleur>.png    fermé · lueur · portail · ouvert · plein · éruption
    assets/lairs/frames.json

Le repaire raconte l'arrivée d'un ennemi : la porte est close, une lueur monte,
un portail s'ouvre, l'énergie jaillit du toit, puis la créature sort. Le joueur
voit donc le danger venir AVANT qu'il n'arrive — c'est tout l'intérêt de
remplacer une apparition au hasard par une maison.

La grille est RÉGULIÈRE, commandée par `docs/prompts/decor/repaire_ennemi.md` : on
ne détecte rien. Le fond magenta part par remplissage depuis les bords de la case,
car la rangée violette vit trop près de lui pour une clé de teinte.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image
from scipy import ndimage

SOURCE = Path("assets/peso&cover/decor/repaire_ennemi.png")
OUT = Path("assets/lairs")

COLORS = ["rouge", "violet", "vert", "cyan"]
POSES = ["ferme", "lueur", "portail", "ouvert", "plein", "eruption"]

SOURCE_CELL = (256, 320)
## Moitié de la case source : assez pour rester net, sur un écran Retina compris.
FRAME = (128, 160)
BACKGROUND = np.array([255.0, 0.0, 255.0])
## Distance au fond, sur le pire canal : sous `FLOOD` le fond coule depuis le bord, et
## entre les deux seuils un pixel de contour est un mélange qu'on sépare du fond.
FLOOD = 70.0
OPAQUE = 150.0
RIM_PX = 3


def cutout(cell: Image.Image) -> np.ndarray:
    """La case détourée, en alpha PRÉMULTIPLIÉ : le magenta ne bavera pas à la réduction."""
    rgb = np.asarray(cell.convert("RGB")).astype(float)
    distance = np.abs(rgb - BACKGROUND).max(axis=2)
    parts, _ = ndimage.label(distance < FLOOD)
    edges = np.unique(np.concatenate([parts[0], parts[-1], parts[:, 0], parts[:, -1]]))
    outside = np.isin(parts, edges[edges > 0])

    alpha = np.ones(distance.shape)
    alpha[outside] = 0.0
    rim = ndimage.binary_dilation(outside, iterations=RIM_PX) & ~outside
    alpha[rim] = np.clip(distance[rim] / OPAQUE, 0.0, 1.0)

    # Un pixel de bord vaut `a * dessin + (1 - a) * fond` : on en retire le fond.
    clean = rgb - (1.0 - alpha[..., None]) * BACKGROUND
    return np.dstack([np.clip(clean, 0.0, 255.0), alpha * 255.0])


def reduced(premultiplied: np.ndarray, size: tuple) -> np.ndarray:
    channels = [Image.fromarray(premultiplied[..., i].astype(np.float32), "F").resize(size, Image.LANCZOS)
                for i in range(4)]
    return np.clip(np.dstack([np.asarray(channel) for channel in channels]), 0.0, 255.0)


def straight(premultiplied: np.ndarray) -> Image.Image:
    alpha = premultiplied[..., 3:4] / 255.0
    rgb = np.where(alpha > 0.0, premultiplied[..., :3] / np.maximum(alpha, 1e-4), 0.0)
    return Image.fromarray(np.dstack([np.clip(rgb, 0.0, 255.0), premultiplied[..., 3]]).astype(np.uint8), "RGBA")


def build() -> dict:
    sheet = Image.open(SOURCE)
    OUT.mkdir(parents=True, exist_ok=True)
    feet = 0
    for row, color in enumerate(COLORS):
        strip = Image.new("RGBA", (FRAME[0] * len(POSES), FRAME[1]), (0, 0, 0, 0))
        for column in range(len(POSES)):
            box = (column * SOURCE_CELL[0], row * SOURCE_CELL[1],
                   (column + 1) * SOURCE_CELL[0], (row + 1) * SOURCE_CELL[1])
            frame = straight(reduced(cutout(sheet.crop(box)), FRAME))
            feet = max(feet, frame.getbbox()[3])
            strip.paste(frame, (column * FRAME[0], 0))
        strip.save(OUT / f"{color}.png")
    meta = {"cell": list(FRAME), "feet_y": feet, "colors": COLORS, "poses": POSES}
    (OUT / "frames.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    return meta


def main() -> None:
    if not SOURCE.exists():
        print(f"  ! {SOURCE} introuvable")
        return
    meta = build()
    print("repaires : %d couleurs x %d poses, case %dx%d, pieds à %d" % (
        len(meta["colors"]), len(meta["poses"]), meta["cell"][0], meta["cell"][1], meta["feet_y"]))


if __name__ == "__main__":
    main()
