#!/usr/bin/env python3
"""La barre du mage : cadre, jauges, gemmes et case de sort.

    tools/.venv/bin/python tools/build_barre.py     # DEPUIS LA RACINE

Lit `assets/peso&cover/interface/barre/` (prompts dans
`docs/prompts/interface/barre_mage.md`) et produit dans `assets/ui/barre/` :
    cadre_barre.png   le cadre, ses trois trous détourés
    cadre_case.png    le cadre d'une case de sort, gris et or
    jauge_*.png       vie, portail, bouclier : une colonne, étirée par le jeu
    sertissage.png, gemme.png, icone_portail.png, eclat.png
    barre.json        où sont les trous, en FRACTIONS du cadre

Comme pour `cadre.json` : une planche redessinée déplace ses trous, et des
constantes écrites à la main dans le moteur deviendraient fausses sans rien dire.
"""

import json
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

from build_menu import magenta_mask

SOURCE = Path("assets/peso&cover/interface/barre")
OUT = Path("assets/ui/barre")

## Le cadre fait ~280 points de large à l'écran : trois fois plus laisse la marge
## d'un écran Retina sans peser.
FRAME_WIDTH = 840
## Hauteur de la case de sort une fois réduite : 3 x 50 points.
CASE_HEIGHT = 150
## Part de la hauteur de la case prise par ses angles, à ne pas étirer.
CASE_MARGIN = 0.18
ICON_SIZE = 96
GAUGE_SIZE = (4, 64)
## En dessous, un morceau détouré est une poussière de la planche, pas une pièce.
MIN_PIECE_AREA = 2000
DARK = 70.0


def cut_out(source: Image.Image, hole: np.ndarray) -> Image.Image:
    """Détoure le magenta et lui retire son liseré rose sur les bords."""
    data = np.array(source.convert("RGBA"))
    data[..., 3] = np.where(hole, 0, 255)
    rgb = data[..., :3].astype(np.float32)
    spill = np.clip(
        (np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1]) / 120.0, 0.0, 1.0)
    fringe = ndimage.binary_dilation(hole, iterations=2) & ~hole
    pull = np.where(fringe, spill, 0.0)
    for channel in (0, 2):
        data[..., channel] = np.clip(
            rgb[..., channel] * (1.0 - pull) + rgb[..., 1] * pull, 0, 255
        ).astype(np.uint8)
    return Image.fromarray(data, "RGBA")


def read_mask(path: Path) -> tuple[Image.Image, np.ndarray]:
    with Image.open(path) as image:
        source = image.convert("RGB")
    return source, magenta_mask(np.asarray(source).astype(np.float32))


def bbox_of(mask: np.ndarray) -> tuple[int, int, int, int]:
    rows = np.flatnonzero(mask.any(axis=1))
    columns = np.flatnonzero(mask.any(axis=0))
    return (int(columns[0]), int(rows[0]), int(columns[-1]) + 1, int(rows[-1]) + 1)


def build_frame() -> str:
    """Le cadre et la mesure de ses trois trous.

    On les distingue par leur FORME : le rond est la fenêtre du portrait, les deux
    longs sont les gouttières, celle du haut étant la vie."""
    source, hole = read_mask(SOURCE / "cadre_barre.png")
    left, top, right, bottom = bbox_of(~hole)
    source = source.crop((left, top, right, bottom))
    hole = hole[top:bottom, left:right]
    height, width = hole.shape

    parts, count = ndimage.label(hole)
    window, gutters = None, []
    for index, slices in enumerate(ndimage.find_objects(parts), start=1):
        rows, columns = slices
        touches = (rows.start == 0 or columns.start == 0
                   or rows.stop >= height or columns.stop >= width)
        if touches or (parts[slices] == index).sum() < MIN_PIECE_AREA:
            continue
        ratio = (columns.stop - columns.start) / (rows.stop - rows.start)
        if ratio < 1.5:
            window = slices
        else:
            gutters.append(slices)
    if window is None or len(gutters) != 2:
        raise SystemExit(f"cadre : il faut 1 rond et 2 gouttières, vu {len(gutters)} gouttières")
    gutters.sort(key=lambda s: s[0].start)

    def fractions(slices: tuple) -> list:
        rows, columns = slices
        return [round(columns.start / width, 4), round(rows.start / height, 4),
                round((columns.stop - columns.start) / width, 4),
                round((rows.stop - rows.start) / height, 4)]

    light = np.asarray(source.convert("L")).astype(np.float32)
    # La gorge autour de la fenêtre, là où le jeu dessine l'anneau des kills. Lue
    # sur les diagonales : les quatre plots du médaillon sont sur les axes.
    rows, columns = window
    cy, cx = (rows.start + rows.stop) / 2.0, (columns.start + columns.stop) / 2.0
    radius = (columns.stop - columns.start) / 2.0
    widths = []
    for angle in np.radians(np.arange(25, 360, 10)):
        if min(abs(np.sin(angle)), abs(np.cos(angle))) < 0.3:
            continue
        step = radius + 3.0
        while light[int(cy + np.sin(angle) * step), int(cx + np.cos(angle) * step)] < DARK:
            step += 1.0
        widths.append(step - radius)

    # La plaque d'ardoise, au-dessus et en dessous des gouttières : le jeu y écrit.
    middle = (gutters[0][1].start + gutters[0][1].stop) // 2
    y = gutters[0][0].start - 10
    while light[y, middle] < DARK:
        y -= 1
    plaque_top = y + 1
    y = gutters[1][0].stop + 10
    while light[y, middle] < DARK:
        y += 1
    plaque_bottom = y

    OUT.mkdir(parents=True, exist_ok=True)
    frame = cut_out(source, hole)
    target = (FRAME_WIDTH, int(round(FRAME_WIDTH * height / width)))
    frame.resize(target, Image.LANCZOS).save(OUT / "cadre_barre.png")

    meta = {
        "aspect": round(height / width, 4),
        "window": fractions(window),
        "health": fractions(gutters[0]),
        "portal": fractions(gutters[1]),
        "ring": round(float(np.median(widths)) / width, 4),
        "plaque_top": round(plaque_top / height, 4),
        "plaque_bottom": round(plaque_bottom / height, 4),
        "case_margin": CASE_MARGIN,
    }
    (OUT / "barre.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    return f"cadre {target[0]}x{target[1]} · gorge {float(np.median(widths)):.0f} px"


def build_pieces() -> str:
    """Trois bandes et cinq pièces, reconnues par leur forme puis leur rang."""
    source, hole = read_mask(SOURCE / "pieces_barre.png")
    # Dilaté : les dents du crâne ou les branches de l'éclat restent d'un seul tenant.
    parts, _ = ndimage.label(ndimage.binary_dilation(~hole, iterations=6))
    bands, icons = [], []
    for index, slices in enumerate(ndimage.find_objects(parts), start=1):
        rows, columns = slices
        if (parts[slices] == index).sum() < MIN_PIECE_AREA:
            continue
        ((bands if columns.stop - columns.start > hole.shape[1] / 2 else icons)
            .append(slices))
    if len(bands) != 3 or len(icons) != 5:
        raise SystemExit(f"pièces : attendu 3 bandes et 5 icônes, vu {len(bands)} et {len(icons)}")
    bands.sort(key=lambda s: s[0].start)
    icons.sort(key=lambda s: s[1].start)

    pixels = np.asarray(source).astype(np.float32)
    for name, slices in zip(("vie", "portail", "bouclier"), bands):
        rows, columns = slices
        span = columns.stop - columns.start
        # La médiane des colonnes du milieu : un défaut local de la planche, étiré sur
        # toute la jauge, deviendrait une rayure.
        core = pixels[rows.start + 8:rows.stop - 8,
                      columns.start + span // 5:columns.stop - span // 5]
        column = np.median(core, axis=1, keepdims=True).astype(np.uint8)
        Image.fromarray(column, "RGB").resize(GAUGE_SIZE, Image.LANCZOS).save(
            OUT / f"jauge_{name}.png")

    cut = cut_out(source, hole)
    # Le crâne de la planche n'est pas repris : l'anneau du portrait compte les kills.
    names = ("sertissage", "gemme", "icone_portail", None, "eclat")
    for name, slices in zip(names, icons):
        if name is None:
            continue
        rows, columns = slices
        piece = cut.crop((columns.start, rows.start, columns.stop, rows.stop))
        if name == "gemme":
            # Remontée vers le blanc : le jeu la TEINTE par multiplication, et un gris
            # moyen rendrait toutes les couleurs ternes.
            data = np.array(piece)
            value = data[..., :3].astype(np.float32)
            top_value = np.percentile(value[data[..., 3] > 0], 80)
            data[..., :3] = np.clip(value * 255.0 / top_value, 0, 255).astype(np.uint8)
            piece = Image.fromarray(data, "RGBA")
        side = max(piece.size)
        square = Image.new("RGBA", (side, side), (0, 0, 0, 0))
        square.paste(piece, ((side - piece.width) // 2, (side - piece.height) // 2))
        square.resize((ICON_SIZE, ICON_SIZE), Image.LANCZOS).save(OUT / f"{name}.png")
    return "3 jauges · 5 pièces"


def build_case() -> str:
    source, hole = read_mask(SOURCE / "cadre_case.png")
    left, top, right, bottom = bbox_of(~hole)
    frame = cut_out(source, hole).crop((left, top, right, bottom))
    target = (int(round(frame.width * CASE_HEIGHT / frame.height)), CASE_HEIGHT)
    frame.resize(target, Image.LANCZOS).save(OUT / "cadre_case.png")
    return f"case {target[0]}x{target[1]}"


def main() -> None:
    print(build_frame())
    print(build_pieces())
    print(build_case())


if __name__ == "__main__":
    main()
