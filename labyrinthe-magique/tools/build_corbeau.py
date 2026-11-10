"""LE CORBEAU DE PESTE (l'Éveil du Mage de la Peste, le Seigneur du Fléau).

Le jeu s'en sert pour les trois corbeaux qui tournent autour du mage pendant l'Éveil (`PlagueCrows`) et pour la
volée de la Nuée de corbeaux. La planche `assets/peso&cover/creatures/peste_corbeau.png` est une grille de 8 x 2 :
rangée 1 vue de DESSUS, tête en haut (le jeu la fait tourner dans le sens du vol), rangée 2 de profil vers la
droite. Huit battements d'ailes par rangée.

Sortie : `assets/allies/peste_corbeau_top.png` et `peste_corbeau_side.png`, deux bandes de huit cases de même
taille, centrées sur le corps, et `peste_corbeau.json` qui donne la case.

    tools/.venv/bin/python tools/build_corbeau.py
"""
from pathlib import Path
import json

import numpy as np
from PIL import Image
from scipy import ndimage

from build_enemies import demagenta, keyed

ROOT = Path(__file__).resolve().parent.parent
SHEET = ROOT / "assets" / "peso&cover" / "creatures" / "peste_corbeau.png"
OUT = ROOT / "assets" / "allies"
COLUMNS = 8
ROWS = 2
MIN_PART = 40       # pixels : une miette plus petite est du bruit de détourage


def cut_cell(sheet: Image.Image, column: int, row: int) -> Image.Image:
    cell_w, cell_h = sheet.width / COLUMNS, sheet.height / ROWS
    box = (round(column * cell_w), round(row * cell_h), round((column + 1) * cell_w), round((row + 1) * cell_h))
    cell = demagenta(keyed(sheet.crop(box)))
    alpha = np.array(cell)[..., 3] > 24
    labels, count = ndimage.label(alpha, structure=np.ones((3, 3)))
    keep = np.zeros_like(alpha)
    for index in range(1, count + 1):
        part = labels == index
        if part.sum() >= MIN_PART:
            keep |= part
    data = np.array(cell)
    data[..., 3] = np.where(keep, data[..., 3], 0)
    ys, xs = np.nonzero(keep)
    return Image.fromarray(data).crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))


def main() -> None:
    sheet = Image.open(SHEET).convert("RGB")
    rows = [[cut_cell(sheet, c, r) for c in range(COLUMNS)] for r in range(ROWS)]
    every = [f for row in rows for f in row]
    side = max(max(f.width for f in every), max(f.height for f in every)) + 4
    for name, frames in zip(("top", "side"), rows):
        strip = Image.new("RGBA", (side * COLUMNS, side), (0, 0, 0, 0))
        for i, frame in enumerate(frames):
            strip.alpha_composite(frame, (i * side + (side - frame.width) // 2, (side - frame.height) // 2))
        strip.save(OUT / f"peste_corbeau_{name}.png")
    (OUT / "peste_corbeau.json").write_text(json.dumps({"cell": side, "frames": COLUMNS}, indent=2), encoding="utf-8")
    print(f"peste_corbeau : 2 bandes de {COLUMNS} cases de {side} px")


if __name__ == "__main__":
    main()
