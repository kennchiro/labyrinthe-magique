"""Découpe une planche d'assets en PNG individuels détourés.

    tools/.venv/bin/python tools/slice_sheet.py <planche.png> <dossier_sortie>

Le fond de la planche est une couleur sombre uniforme, mais SANS transparence.
Le détourage se fait par REMPLISSAGE DEPUIS LES BORDS et non par seuil de
luminosité : un seuil trouerait les zones sombres à l'intérieur des sprites
(ombres des robes, contours noirs), alors que le remplissage ne retire que le
fond réellement connecté au bord de la vignette.
"""

import sys
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

# Panneaux à découper : nom -> (x0, y0, x1, y1, mode)
#
# Deux modes de détection, parce qu'aucun ne marche partout :
#   "grille"    — projections lignes/colonnes. Rapide et net quand les sprites
#                 sont alignés et séparés par du fond (personnages, portails).
#   "composantes" — étiquetage des zones connexes. Indispensable pour le panneau
#                 de décor, où les props se touchent : les projections y
#                 fusionnent tout en un seul bloc.
PANELS = {
    # y0 = 28 : à 100 on sautait la première rangée entière (les vues de face).
    "mage":     (0, 28, 348, 245, "grille"),
    "mechant":  (0, 265, 348, 460, "grille"),
    "gobelin":  (0, 483, 348, 610, "grille"),
    # y0 volontairement sous le titre du panneau : sinon le texte "MAISON
    # (Objectif)" est détecté comme un sprite et fusionne avec la première image.
    "maison":   (0, 645, 348, 702, "grille"),
    "portail":  (0, 792, 348, 866, "grille"),
    "decor":    (352, 170, 742, 700, "composantes"),
    "sol":      (352, 30, 742, 168, "composantes"),
    "effet":    (352, 940, 742, 1005, "grille"),
}

BG_TOLERANCE = 40      # écart de couleur toléré pour considérer un pixel comme fond
MIN_SIZE = 10          # ignore les fragments plus petits


def bands(profile, threshold, min_len, gap_tolerance=2):
    """Segments continus au-dessus du seuil, en tolérant de courtes interruptions."""
    out, start, last_on = [], None, None
    for i, value in enumerate(profile):
        if value > threshold:
            if start is None:
                start = i
            last_on = i
        elif start is not None and i - last_on > gap_tolerance:
            if last_on - start + 1 >= min_len:
                out.append((start, last_on + 1))
            start = None
    if start is not None and last_on - start + 1 >= min_len:
        out.append((start, last_on + 1))
    return out


def detect_boxes(luminance, panel):
    x0, y0, x1, y1, mode = panel
    mask = luminance[y0:y1, x0:x1] > 38
    if mode == "composantes":
        return _boxes_by_components(mask, x0, y0)
    boxes = []
    for row_start, row_end in bands(mask.mean(axis=1), 0.015, MIN_SIZE):
        for col_start, col_end in bands(mask[row_start:row_end].mean(axis=0), 0.015, MIN_SIZE):
            boxes.append((x0 + col_start, y0 + row_start, x0 + col_end, y0 + row_end))
    return boxes


def _boxes_by_components(mask, x0, y0):
    from scipy import ndimage
    # Fermeture morphologique : recolle les halos et les pixels isolés d'un même
    # objet, qui seraient sinon comptés comme autant de sprites minuscules.
    closed = ndimage.binary_closing(mask, structure=np.ones((3, 3)), iterations=2)
    labels, count = ndimage.label(closed)
    boxes = []
    for y_slice, x_slice in ndimage.find_objects(labels):
        width = x_slice.stop - x_slice.start
        height = y_slice.stop - y_slice.start
        if width < MIN_SIZE or height < MIN_SIZE or width * height < 260:
            continue
        boxes.append((x0 + x_slice.start, y0 + y_slice.start,
                      x0 + x_slice.stop, y0 + y_slice.stop))
    return boxes


def cut(image, box, margin=3):
    """Détoure une vignette : fond -> transparent, contour légèrement adouci."""
    x0, y0, x1, y1 = box
    crop = image.crop((max(0, x0 - margin), max(0, y0 - margin),
                       min(image.width, x1 + margin), min(image.height, y1 + margin)))
    pixels = np.array(crop.convert("RGB")).astype(int)
    height, width = pixels.shape[:2]

    border = np.concatenate([pixels[0], pixels[-1], pixels[:, 0], pixels[:, -1]])
    background = np.median(border, axis=0)
    is_background = np.abs(pixels - background).sum(axis=2) < BG_TOLERANCE

    visited = np.zeros((height, width), bool)
    queue = deque()
    for x in range(width):
        for y in (0, height - 1):
            if is_background[y, x] and not visited[y, x]:
                visited[y, x] = True
                queue.append((y, x))
    for y in range(height):
        for x in (0, width - 1):
            if is_background[y, x] and not visited[y, x]:
                visited[y, x] = True
                queue.append((y, x))
    while queue:
        y, x = queue.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < height and 0 <= nx < width and is_background[ny, nx] and not visited[ny, nx]:
                visited[ny, nx] = True
                queue.append((ny, nx))

    alpha = Image.fromarray(((~visited) * 255).astype(np.uint8))
    alpha = alpha.filter(ImageFilter.GaussianBlur(0.6))
    out = crop.convert("RGBA")
    out.putalpha(alpha)
    bbox = out.getbbox()
    return out.crop(bbox) if bbox else out


def main():
    sheet_path, out_dir = Path(sys.argv[1]), Path(sys.argv[2])
    out_dir.mkdir(parents=True, exist_ok=True)
    image = Image.open(sheet_path).convert("RGB")
    luminance = np.array(image).astype(int).mean(axis=2)

    total = 0
    for name, panel in PANELS.items():
        boxes = detect_boxes(luminance, panel)
        for index, box in enumerate(boxes):
            sprite = cut(image, box)
            sprite.save(out_dir / f"{name}_{index:02d}.png")
            total += 1
        print(f"{name:10s} : {len(boxes)} sprites")
    print(f"total : {total} fichiers dans {out_dir}")


if __name__ == "__main__":
    main()
