#!/usr/bin/env python3
"""LES ORBES — le projectile de chaque mage, en quatre images.

    tools/.venv/bin/python tools/build_orbs.py     # DEPUIS LA RACINE

Chaque planche est commandée en grille STRICTE : quatre images sur une rangée,
de la naissance du tir (image 1) à sa pleine puissance (image 4). Le jeu les
déroule UNE fois en 0,22 s puis tient la dernière — d'où le `"mode": "grow"`
écrit dans `orb.json`.

⚠️ DEUX CONTRAINTES QUE LE DÉCOUPAGE DOIT TENIR, et qui ne se voient qu'en jeu.

1. LA BANDE DE SORTIE A DES CASES ÉGALES. `MagicOrb` pose `sprite.hframes = 4`,
   ce qui découpe la texture en quatre parts EXACTEMENT égales. Une bande dont
   les images n'auraient pas la même largeur montrerait des moitiés d'images.

2. LE CALAGE. Recadrée sur son contenu, l'étincelle de l'image 1 et la comète
   de l'image 4 n'ont ni la même taille ni le même centre : jouées à la suite,
   le tir SAUTE. On calcule donc une boîte COMMUNE aux quatre et on y découpe
   tout le monde — même leçon que l'éruption de la Terre.

La largeur d'une planche n'est pas toujours divisible par quatre (1774 pour les
huit livrées) : on découpe par ARRONDI sur la largeur totale, jamais par une
taille de case fixe.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image

SOURCE = Path("assets/peso&cover")
OUT = Path("assets/characters")

COLUMNS = 4
## Hauteur d'une image dans la bande finale. Le jeu remet l'orbe à l'échelle de
## la case (0,95 case sur sa plus grande dimension), donc ce chiffre ne fixe que
## la finesse : assez pour les écrans Retina, sans peser.
FRAME_HEIGHT = 112

## planche -> dossier du personnage
ORBS = {
    "orb_fire.png": "fire",
    "orb_water.png": "water",
    "orb_earth.png": "earth",
    "orb_thunder.png": "thunder",
    "orb_air.png": "air",
    "orb_shadow.png": "shadow",
    "orb_supreme.png": "supreme",
    "orb_invocateur.png": "invocateur",
}

KEY_HUE = 300.0
HUE_TOLERANCE = 26.0
MIN_SATURATION = 0.22


def hue_and_saturation(pixels: np.ndarray) -> tuple:
    top = pixels.max(axis=2)
    bottom = pixels.min(axis=2)
    span = top - bottom
    red, green, blue = pixels[..., 0], pixels[..., 1], pixels[..., 2]
    hue = np.zeros_like(top)
    safe = span > 1e-6
    with np.errstate(invalid="ignore", divide="ignore"):
        is_red = safe & (top == red)
        is_green = safe & (top == green) & ~is_red
        is_blue = safe & ~is_red & ~is_green
        hue[is_red] = (60.0 * ((green - blue)[is_red] / span[is_red])) % 360.0
        hue[is_green] = 60.0 * ((blue - red)[is_green] / span[is_green]) + 120.0
        hue[is_blue] = 60.0 * ((red - green)[is_blue] / span[is_blue]) + 240.0
    saturation = np.where(top > 1e-6, span / np.maximum(top, 1e-6), 0.0)
    return hue, saturation


def keyed(cell: Image.Image) -> Image.Image:
    """Détourage par TEINTE, puis dégorgement progressif.

    Même formule que les vignettes de sorts : ce qu'un pixel a de rouge ET de
    bleu en plus de son vert est du fond mêlé au dessin. On le rend transparent
    d'autant et on ramène ses canaux vers le vert. C'est ce qui sauve les
    traînées de fumée du Sorcier des Ténèbres, presque de la même teinte que le
    magenta en distance brute.
    """
    pixels = np.asarray(cell.convert("RGB")).astype(float) / 255.0
    hue, saturation = hue_and_saturation(pixels)
    distance = np.abs(((hue - KEY_HUE + 180.0) % 360.0) - 180.0)
    background = (distance < HUE_TOLERANCE) & (saturation > MIN_SATURATION)

    data = np.array(cell.convert("RGBA"))
    data[..., 3] = np.where(background, 0, 255)
    rgb = data[..., :3].astype(float)
    spill = np.clip(
        (np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1]) / 255.0, 0.0, 1.0)
    data[..., 3] = (data[..., 3].astype(float) * (1.0 - spill)).astype(np.uint8)
    for channel in (0, 2):
        data[..., channel] = np.clip(
            rgb[..., channel] * (1.0 - spill) + rgb[..., 1] * spill, 0, 255
        ).astype(np.uint8)
    return Image.fromarray(data, "RGBA")


def main() -> None:
    for sheet_name, cid in ORBS.items():
        path = SOURCE / sheet_name
        if not path.exists():
            print(f"  ! {sheet_name} introuvable")
            continue
        with Image.open(path) as raw:
            sheet = raw.convert("RGBA")
        frames = [keyed(sheet.crop((
            round(sheet.width * column / COLUMNS), 0,
            round(sheet.width * (column + 1) / COLUMNS), sheet.height)))
            for column in range(COLUMNS)]

        union = None
        for frame in frames:
            bounds = frame.getbbox()
            if bounds is None:
                continue
            union = bounds if union is None else (
                min(union[0], bounds[0]), min(union[1], bounds[1]),
                max(union[2], bounds[2]), max(union[3], bounds[3]))
        if union is None:
            print(f"  ! {sheet_name} : rien à découper")
            continue

        factor = FRAME_HEIGHT / float(union[3] - union[1])
        cell = (max(1, int(round((union[2] - union[0]) * factor))), FRAME_HEIGHT)
        strip = Image.new("RGBA", (cell[0] * COLUMNS, FRAME_HEIGHT), (0, 0, 0, 0))
        for index, frame in enumerate(frames):
            strip.alpha_composite(
                frame.crop(union).resize(cell, Image.LANCZOS), (index * cell[0], 0))

        out_dir = OUT / cid
        out_dir.mkdir(parents=True, exist_ok=True)
        strip.save(out_dir / "orb.png")
        (out_dir / "orb.json").write_text(json.dumps({
            "frames": COLUMNS, "cell": list(cell), "mode": "grow",
        }), encoding="utf-8")
        print(f"{cid:11s} {sheet_name:20s} -> bande {strip.size}, case {cell}")


if __name__ == "__main__":
    main()
