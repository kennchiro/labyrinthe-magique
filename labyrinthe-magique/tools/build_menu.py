#!/usr/bin/env python3
"""L'écran « Choisis ton mage » : portraits, cadre, fond.

    tools/.venv/bin/python tools/build_menu.py     # DEPUIS LA RACINE

Produit :
    assets/ui/portraits/portrait_<id>.png   les huit mages
    assets/ui/portraits/cadre_carte.png     le cadre, fenêtre détourée
    assets/ui/portraits/cadre.json          où sont la fenêtre et le sertissage
    assets/ui/fond_selection.png            le fond de la page

Les planches sources sont dans `assets/peso&cover/interface/`, et les prompts
qui les ont produites dans `docs/prompts/menu/`.

TROIS DÉCOUPAGES, ET UN SEUL EST DÉLICAT

Les portraits et le fond ne demandent qu'une réduction : ils sont livrés pleins,
sans transparence, au bon rapport. Le CADRE, lui, arrive avec sa fenêtre peinte
en magenta — il faut la percer, et surtout MESURER où elle est. Le moteur ne
peut pas la deviner : selon l'épaisseur que le modèle a donnée à la bordure, le
portrait doit se poser deux points plus haut ou plus bas, et un portrait mal
posé dépasse du cadre ou laisse un liseré de vide.

`cadre.json` porte donc la fenêtre ET le sertissage de la gemme, en fractions de
l'image. Deux rectangles mesurés une fois ici plutôt que deux constantes écrites
à la main dans le moteur, qui deviendraient fausses au premier cadre redessiné.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image
from scipy import ndimage

SOURCE = Path("assets/peso&cover/interface")
OUT_UI = Path("assets/ui")
OUT_PORTRAITS = OUT_UI / "portraits"

## Ordre du catalogue — c'est celui de la rangée à l'écran.
MAGES = ["fire", "water", "earth", "shadow", "thunder", "air",
         "invocateur", "supreme", "chrono", "peste", "lumiere", "mort", "etoiles", "acier", "demon", "discorde"]

## Taille des portraits sur le disque. La vignette de la rangée fait ~116 points
## de large, doublée sur un écran Retina : 384 laisse de la marge sans peser.
PORTRAIT_WIDTH = 384
## Le fond est affiché plein écran. 1280 x 720 est la base du projet ; au-delà,
## on paie des mégaoctets pour un décor volontairement flou au centre.
BACKDROP_WIDTH = 1280
## Portraits et fond partent en JPEG, le cadre reste en PNG.
##
## Ce n'est pas une micro-optimisation : ces images n'ont AUCUNE transparence —
## le portrait porte sa nappe de couleur jusqu'aux bords, le fond est un décor
## plein — et en PNG elles pesaient 4,2 Mo à elles seules, soit plus que tout le
## terrain des dix stages. En JPEG de qualité 90 elles tombent sous le mégaoctet,
## et la perte ne se voit pas : le portrait est affiché trois fois plus petit
## qu'il n'est stocké. Le CADRE, lui, garde son PNG : sa fenêtre est un TROU, et
## un JPEG n'a pas de canal alpha pour le porter.
JPEG_QUALITY = 90

## Écart RGB au magenta en dessous duquel un pixel est du fond de fenêtre.
KEY_DISTANCE = 90.0


def magenta_mask(pixels: np.ndarray) -> np.ndarray:
    """Ce qui est du magenta de fenêtre.

    Le cadre est gris et or, donc très loin du magenta : un simple seuil de
    distance suffit ici, là où les props de terrain demandaient une mesure de
    chromaticité (leurs cristaux roses étaient plus magenta que le fond)."""
    key = np.array([255.0, 0.0, 255.0], np.float32)
    return np.sqrt(((pixels[..., :3] - key) ** 2).sum(axis=2)) < KEY_DISTANCE


def build_portraits() -> str:
    OUT_PORTRAITS.mkdir(parents=True, exist_ok=True)
    written = 0
    for name in MAGES:
        path = SOURCE / "portraits" / f"portrait_{name}.png"
        if not path.exists():
            print(f"  ! {path.name} introuvable — ce mage garde son sprite")
            continue
        with Image.open(path) as image:
            portrait = image.convert("RGB")
        height = int(round(PORTRAIT_WIDTH * portrait.height / portrait.width))
        portrait.resize((PORTRAIT_WIDTH, height), Image.LANCZOS).save(
            OUT_PORTRAITS / f"portrait_{name}.jpg", quality=JPEG_QUALITY)
        (OUT_PORTRAITS / f"portrait_{name}.png").unlink(missing_ok=True)
        (OUT_PORTRAITS / f"portrait_{name}.png.import").unlink(missing_ok=True)
        written += 1
    return f"{written} portraits"


def build_frame() -> str:
    """Le cadre percé, et la mesure de ses deux trous.

    Après détourage il reste DEUX régions transparentes qui comptent : la grande
    FENÊTRE au centre, où va le portrait, et le petit SERTISSAGE rond en haut,
    où le jeu pose la gemme de l'élément. On les distingue par leur taille, pas
    par leur position : un cadre redessiné peut monter ou descendre son
    sertissage, il restera toujours le plus petit des deux."""
    path = SOURCE / "portraits" / "cadre_carte.png"
    if not path.exists():
        return "cadre introuvable"
    with Image.open(path) as image:
        source = image.convert("RGBA")
    pixels = np.asarray(source).astype(np.float32)
    hole = magenta_mask(pixels)

    parts, count = ndimage.label(hole)
    if count == 0:
        return "cadre : aucune fenêtre magenta trouvée"
    sizes = ndimage.sum(np.ones_like(parts), parts, range(1, count + 1))
    boxes = ndimage.find_objects(parts)
    # Les coins extérieurs sont magenta eux aussi et TOUCHENT le bord : ce ne
    # sont ni la fenêtre ni le sertissage, juste le fond de la planche.
    height, width = hole.shape
    inner = []
    for index in range(1, count + 1):
        rows, columns = boxes[index - 1]
        touches = (rows.start == 0 or columns.start == 0
                   or rows.stop >= height or columns.stop >= width)
        if not touches and sizes[index - 1] > width * height * 0.0005:
            inner.append((float(sizes[index - 1]), (rows, columns)))
    if not inner:
        return "cadre : fenêtre non trouvée (magenta relié au bord seulement)"
    inner.sort(reverse=True)
    window = inner[0][1]
    socket = inner[1][1] if len(inner) > 1 else None

    data = np.array(source)
    data[..., 3] = np.where(hole, 0, 255)
    # Dégorgement : le bord de la fenêtre est mélangé au magenta sur un pixel ou
    # deux, et sans correction il reste un liseré rose autour du portrait.
    rgb = data[..., :3].astype(np.float32)
    spill = np.clip(
        (np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1]) / 120.0, 0.0, 1.0)
    fringe = ndimage.binary_dilation(hole, iterations=2) & ~hole
    pull = np.where(fringe, spill, 0.0)
    for channel in (0, 2):
        data[..., channel] = np.clip(
            rgb[..., channel] * (1.0 - pull) + rgb[..., 1] * pull, 0, 255
        ).astype(np.uint8)

    frame = Image.fromarray(data, "RGBA")
    target_height = int(round(PORTRAIT_WIDTH * frame.height / frame.width))
    frame.resize((PORTRAIT_WIDTH, target_height), Image.LANCZOS).save(
        OUT_PORTRAITS / "cadre_carte.png")

    def fractions(slices: tuple) -> list:
        rows, columns = slices
        return [round(columns.start / width, 4), round(rows.start / height, 4),
                round((columns.stop - columns.start) / width, 4),
                round((rows.stop - rows.start) / height, 4)]

    meta = {"window": fractions(window)}
    if socket is not None:
        meta["socket"] = fractions(socket)
    (OUT_PORTRAITS / "cadre.json").write_text(
        json.dumps(meta, indent=2), encoding="utf-8")
    note = "fenêtre %.0f%%x%.0f%%" % (meta["window"][2] * 100, meta["window"][3] * 100)
    return f"cadre {PORTRAIT_WIDTH}x{target_height} · {note}" + (
        " · sertissage" if socket is not None else " · SANS sertissage")


def build_backdrop() -> str:
    path = SOURCE / "fond_selection.png"
    if not path.exists():
        return "fond introuvable"
    OUT_UI.mkdir(parents=True, exist_ok=True)
    with Image.open(path) as image:
        backdrop = image.convert("RGB")
    height = int(round(BACKDROP_WIDTH * backdrop.height / backdrop.width))
    backdrop.resize((BACKDROP_WIDTH, height), Image.LANCZOS).save(
        OUT_UI / "fond_selection.jpg", quality=JPEG_QUALITY)
    (OUT_UI / "fond_selection.png").unlink(missing_ok=True)
    (OUT_UI / "fond_selection.png.import").unlink(missing_ok=True)
    return f"fond {BACKDROP_WIDTH}x{height}"


def main() -> None:
    print(" · ".join([build_portraits(), build_frame(), build_backdrop()]))


if __name__ == "__main__":
    main()
