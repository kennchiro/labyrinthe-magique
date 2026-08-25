#!/usr/bin/env python3
"""LES ANIMATIONS image par image, détourées de leur fond magenta.

    tools/.venv/bin/python tools/build_spike_anim.py     # DEPUIS LA RACINE

Deux planches à ce jour, commandées en grille STRICTE :
  · l'ÉRUPTION de la Terre — six images par rangée, deux rangées (cristal puis
    pierre), chaque gerbe grandissant depuis le bas au centre de sa case ;
  · la TORNADE de l'Air — huit images sur une rangée, un tour complet, la
    silhouette identique et seules les bandes qui tournent.

⚠️ LE POINT DÉLICAT EST L'ALIGNEMENT. Si l'on recadre chaque image sur son
contenu, la première (une simple fissure large et basse) et la quatrième (une
gerbe haute et étroite) n'ont ni la même taille ni le même centre : jouées à la
suite, les pics SAUTENT d'une image à l'autre. On calcule donc une boîte
COMMUNE à toute la rangée, et on y découpe les six. Le poids en pixels est un
peu plus lourd ; l'animation, elle, tient debout.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image

## planche -> (dossier de sortie, colonnes, rangées, préfixe, hauteur finale)
##
## ⚠️ La largeur d'une planche n'est pas toujours divisible par son nombre de
## colonnes (celle de la tornade fait 1774 pour huit images). On découpe donc
## par ARRONDI sur la largeur totale, jamais par une taille de case fixe : à un
## pixel près par colonne, l'écart s'accumule et la dernière image est décalée.
SHEETS = [
    ("assets/peso&cover/sorts/earth_spikes_anim.png", "earth", 6,
     ["crystal", "stone"], "spikes", 192),
    ("assets/peso&cover/sorts/tornado_spin.png", "air", 8,
     ["spin"], "tornado", 256),
    # Le Grand souffle : le CÔNE part vers la droite, pointe à gauche — c'est
    # cette pointe qu'on posera sur le mage — et l'ONDE reste concentrique.
    ("assets/peso&cover/sorts/wind_blast.png", "air", 6,
     ["cone", "burst"], "blast", 224),
]

## Détourage : même clé de teinte que les vignettes de sorts. Le magenta
## n'appartient à aucune palette du jeu, donc ce qui en a la teinte est du fond.
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

    # Dégorgement : ce qu'un pixel a de rouge ET de bleu en plus de son vert est
    # du fond mélangé au dessin. On le rend transparent d'autant, et on ramène
    # ses canaux vers le vert. Même formule que pour les vignettes.
    rgb = data[..., :3].astype(float)
    spill = np.clip(
        (np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1]) / 255.0, 0.0, 1.0)
    data[..., 3] = (data[..., 3].astype(float) * (1.0 - spill)).astype(np.uint8)
    for channel in (0, 2):
        data[..., channel] = np.clip(
            rgb[..., channel] * (1.0 - spill) + rgb[..., 1] * spill, 0, 255
        ).astype(np.uint8)
    return Image.fromarray(data, "RGBA")


def cut(source: str, folder: str, columns: int, rows: list, prefix: str,
        height: int) -> str:
    path = Path(source)
    if not path.exists():
        return f"  ! {source} introuvable"
    with Image.open(path) as raw:
        sheet = raw.convert("RGBA")
    out = Path("assets/characters") / folder
    out.mkdir(parents=True, exist_ok=True)
    cell_h = sheet.height // len(rows)

    report = []
    for row, matter in enumerate(rows):
        frames = [keyed(sheet.crop((
            round(sheet.width * column / columns), row * cell_h,
            round(sheet.width * (column + 1) / columns), (row + 1) * cell_h)))
                  for column in range(columns)]
        # LA BOÎTE COMMUNE : l'union des contenus de la rangée. Voir l'en-tête.
        union = None
        for frame in frames:
            bounds = frame.getbbox()
            if bounds is None:
                continue
            union = bounds if union is None else (
                min(union[0], bounds[0]), min(union[1], bounds[1]),
                max(union[2], bounds[2]), max(union[3], bounds[3]))
        if union is None:
            report.append(f"! rangée {matter} vide")
            continue
        factor = height / float(union[3] - union[1])
        size = (max(1, int((union[2] - union[0]) * factor)), height)
        for index, frame in enumerate(frames):
            frame.crop(union).resize(size, Image.LANCZOS).save(
                out / f"{prefix}_{matter}_{index}.png")
        report.append(f"{matter} x{columns} {size}")

    (out / f"{prefix}_anim.json").write_text(json.dumps({
        "frames": columns, "matters": rows, "height": height,
    }), encoding="utf-8")
    return f"{folder}/{prefix}  " + " · ".join(report)


def main() -> None:
    for sheet in SHEETS:
        print(cut(*sheet))


if __name__ == "__main__":
    main()
