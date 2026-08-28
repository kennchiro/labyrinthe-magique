#!/usr/bin/env python3
"""LES EFFETS ANIMÉS DESSINÉS — frappes, geysers, éclaboussures.

    tools/.venv/bin/python tools/build_impacts.py     # DEPUIS LA RACINE

Le dessin d'impact découpé d'une planche de personnage est FIXE : le jeu ne
peut que l'agrandir et le faire pâlir. Une frappe demande à se dérouler — le
trait tombe, le sol encaisse, la lumière se retire.

⚠️ LE POINT D'IMPACT N'EST PAS LE CENTRE DE L'IMAGE. L'éclair tombe du haut de
la case et l'éclat se produit EN BAS : centrer le dessin poserait la frappe une
demi-case trop haut, et le sol s'illuminerait à côté de la créature touchée.

On relève donc l'ANCRE sur la DERNIÈRE image — celle où il ne reste que
l'anneau au sol, dont le centre EST le point d'impact — et on l'écrit dans le
descripteur. Le rendu s'en sert pour poser le dessin sur la case.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image

SOURCE = Path("assets/peso&cover")
OUT = Path("assets/characters")

COLUMNS = 6
## Hauteur finale d'une image. Le jeu remet à l'échelle de la case ; ce chiffre
## ne fixe que la finesse.
FRAME_HEIGHT = 224

## planche -> (dossier du personnage, noms des rangées, colonnes)
##
## Une rangée = une animation, nommée par ce qu'elle montre. Le jeu charge
## `<nom>_0..n.png` et `<nom>_anim.json` dans le dossier du personnage.
SHEETS = [
    ("impact_thunder.png", "thunder", ["impact"], 6),
    ("geyser_water.png", "water", ["geyser", "splash"], 6),
]

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



## Où couper entre deux images, quand le dessin DÉBORDE de sa case.
##
## La planche est commandée en grille régulière et les images sont censées
## garder leurs marges. Celle de la Foudre ne les a pas gardées : ses
## étincelles touchent les bords, si bien qu'un découpage aux lignes théoriques
## emportait dans chaque image un morceau de sa voisine — visible à l'œil, et
## signalé.
##
## On cherche donc, autour de chaque ligne théorique, la colonne la plus VIDE
## dans une fenêtre de 12 % : c'est le creux entre deux dessins. À défaut de
## creux franc, on retombe sur la ligne théorique, qui reste la meilleure
## approximation.
def column_cuts(keyed_sheet: Image.Image, columns: int) -> list:
    alpha = np.asarray(keyed_sheet)[..., 3].astype(float).sum(axis=0)
    width = keyed_sheet.width
    window = max(4, int(width / columns * 0.12))
    cuts = [0]
    for column in range(1, columns):
        middle = round(width * column / columns)
        low = max(cuts[-1] + 1, middle - window)
        high = min(width - 1, middle + window)
        slice_ = alpha[low:high]
        cuts.append(low + int(np.argmin(slice_)) if slice_.size else middle)
    cuts.append(width)
    return cuts


def cut_sheet(sheet_name: str, cid: str, rows: list, columns: int) -> str:
    path = SOURCE / sheet_name
    if not path.exists():
        return f"  ! {sheet_name} introuvable"
    with Image.open(path) as raw:
        sheet = raw.convert("RGBA")
    out_dir = OUT / cid
    out_dir.mkdir(parents=True, exist_ok=True)
    row_height = sheet.height // len(rows)
    report = []

    for index, name in enumerate(rows):
        band = sheet.crop((0, index * row_height, sheet.width,
                           (index + 1) * row_height))
        cuts = column_cuts(keyed(band), columns)
        frames = [keyed(band.crop((cuts[c], 0, cuts[c + 1], band.height)))
                  for c in range(columns)]

        # Boîte COMMUNE : sans elle, l'effet saute d'une image à l'autre.
        union = None
        for frame in frames:
            bounds = frame.getbbox()
            if bounds is None:
                continue
            union = bounds if union is None else (
                min(union[0], bounds[0]), min(union[1], bounds[1]),
                max(union[2], bounds[2]), max(union[3], bounds[3]))
        if union is None:
            report.append(f"! rangée {name} vide")
            continue

        # L'ANCRE, relevée sur la DERNIÈRE image : voir l'en-tête.
        last = frames[-1].getbbox() or union
        anchor_px = ((last[0] + last[2]) * 0.5 - union[0],
                     (last[1] + last[3]) * 0.5 - union[1])

        factor = FRAME_HEIGHT / float(union[3] - union[1])
        size = (max(1, int(round((union[2] - union[0]) * factor))), FRAME_HEIGHT)
        for frame_index, frame in enumerate(frames):
            frame.crop(union).resize(size, Image.LANCZOS).save(
                out_dir / f"{name}_{frame_index}.png")
        anchor = [round(anchor_px[0] * factor, 1), round(anchor_px[1] * factor, 1)]
        (out_dir / f"{name}_anim.json").write_text(json.dumps({
            "frames": columns, "cell": list(size), "anchor": anchor,
        }), encoding="utf-8")
        report.append(f"{name} x{columns} {size} ancre {anchor}")
    return f"{cid:9s} " + " · ".join(report)


def main() -> None:
    for sheet in SHEETS:
        print(cut_sheet(*sheet))


if __name__ == "__main__":
    main()
