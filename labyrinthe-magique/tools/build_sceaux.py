#!/usr/bin/env python3
"""Les Quatre Sceaux — le sort 2 du Sorcier Suprême.

    tools/.venv/bin/python tools/build_sceaux.py     # DEPUIS LA RACINE

Découpe `assets/peso&cover/sorts/sceaux.png` — une planche 3 x 3 — vers
`assets/characters/supreme/` :

    sceaux_charge.png   les 7 images de charge, en bande à case commune
    sceaux_charge.json  leur nombre et leur cadence
    sceaux_seal.png     le sceau posé au sol
    sceaux_flash.png    l'éclat du mordant

POURQUOI UN SEUL SCEAU POUR QUATRE ZONES

Le sort en pose quatre — feu, eau, terre, air — et la planche n'en dessine
qu'un, en blanc et or. C'est délibéré : quatre sceaux générés séparément
n'auraient jamais eu le même diamètre ni la même gravure, et les quatre sont
posés CÔTE À CÔTE à l'écran, là où le moindre écart se voit. Le moteur les
teinte avec `Element.color()`, comme il teinte déjà le cadre des cartes de
personnages. Un sceau déjà coloré aurait donné quatre teintes fausses.

⚠️ Le sceau garde sa case ENTIÈRE, il n'est pas recadré sur son dessin. Sa
gravure est un cercle centré, et `ZoneEffect` la pose en la mettant à l'échelle
du rayon de la zone : recadrer déplacerait ce centre d'un dessin à l'autre et
les quatre sceaux ne tomberaient plus sur leur case.
"""

from pathlib import Path
import sys
import json

sys.path.insert(0, str(Path(__file__).resolve().parent))

import numpy as np
from PIL import Image
from scipy import ndimage

SHEET = Path("assets/peso&cover/sorts/sceaux.png")
## Les quatre effets élémentaires, une planche chacun : 8 images en boucle,
## rangées en 4 x 2. Quatre planches et non une, parce qu'elles doivent être
## DIFFÉRENTES — une flamme et une tornade n'ont rien à partager. Ce qui doit
## rester commun, le cadrage, est imposé ici et pas au modèle.
EFFECTS = ["feu", "eau", "terre", "air"]
EFFECT_COLUMNS, EFFECT_ROWS = 4, 2
## Cadence de la boucle. Plus lente que la charge : ces effets tiennent une
## minute entière, et un feu qui crépite à 8 images par seconde pendant soixante
## secondes devient un stroboscope.
EFFECT_FPS = 6.0
## Côté d'une image d'effet. `ZoneEffect` la met à l'échelle du rayon de la zone.
EFFECT_CELL = 256
OUT = Path("assets/characters/supreme")

COLUMNS = ROWS = 3
## Écart RGB au fond échantillonné en dessous duquel un pixel est du fond.
##
## Généreux, parce qu'ici on efface le magenta PARTOUT, y compris ENCLAVÉ — et
## c'est indispensable : le sceau est un anneau, la charge est un anneau, et
## tout leur intérieur est du fond que le bord ne peut pas atteindre. Le premier
## essai n'effaçait que le fond relié au bord et rendait des anneaux remplis de
## rose.
##
## Effacer partout est sans risque SUR CETTE PLANCHE, et seulement sur elle : le
## dessin est rouge, bleu, vert, blanc et or, tous à plus de 220 d'écart du
## magenta. Les props de terrain, eux, ont des cristaux plus magenta que le fond
## et demandent la mesure de chromaticité de `build_terrain.py`.
KEY_DISTANCE = 110.0
## Les sept premières cases sont la charge ; la huitième le sceau, la neuvième
## l'éclat. Lus par le moteur dans le descripteur, jamais codés là-bas.
CHARGE_FRAMES = 7
## Cadence de la charge. La même que Convergence : les deux sorts du Suprême
## doivent se préparer au même rythme, sinon l'un paraît plus lourd que l'autre
## alors qu'ils coûtent la même chose.
FPS = 8.0
## Côté d'une case dans la bande de charge.
CELL = 320
## Côté du sceau et de l'éclat. Plus généreux : le sceau est étalé au sol sur
## près de trois cases de jeu, une source trop juste y devient floue.
GROUND = 512


def keyed(cell: Image.Image, ring: bool = False) -> Image.Image:
    """La case détourée, fond magenta retiré où qu'il soit.

    `ring` : la case dessine un ANNEAU CENTRÉ — c'est le cas des sept images de
    charge, et d'elles seules. On peut alors jeter tout ce dont le centre tombe
    loin du milieu, ce qui est le seul moyen sûr d'attraper les derniers éclats
    de la case voisine. L'éclat du mordant, lui, projette légitimement ses
    fragments jusqu'aux coins : la règle ne s'applique pas à lui."""
    pixels = np.asarray(cell.convert("RGB")).astype(np.float32)
    height, width = pixels.shape[:2]
    corner = max(4, min(height, width) // 24)
    corners = np.concatenate([
        pixels[:corner, :corner].reshape(-1, 3),
        pixels[:corner, -corner:].reshape(-1, 3),
        pixels[-corner:, :corner].reshape(-1, 3),
        pixels[-corner:, -corner:].reshape(-1, 3),
    ])
    background = np.median(corners, axis=0)
    hole = np.sqrt(((pixels - background) ** 2).sum(axis=2)) < KEY_DISTANCE

    data = np.array(cell.convert("RGBA"))
    data[..., 3] = np.where(hole, 0, 255)
    # DÉGORGEMENT PAR « MAGENTA-ITÉ », et non par distance au fond.
    #
    # MESURÉ sur la planche de terre : autour du disque, une frange de 12 000
    # pixels roses survivait au seuil de distance — elle est à 110-200 du fond,
    # donc trop loin pour être effacée, et trop près pour ne pas se voir. Une
    # frange rose vif autour d'un tas de cailloux bruns.
    #
    # Monter le seuil de distance aurait mordu le rouge du brasier, qui n'est
    # qu'à 191 du fond. Ce qu'un pixel a de rouge ET de bleu en plus de son vert,
    # lui, tranche net : 0,22 sur la frange, 0,86 sur le fond pur, et ZÉRO sur la
    # terre, la flamme, la glace et le vent. On l'efface donc d'autant qu'il est
    # magenta, sur toute l'image et pas seulement au bord du trou.
    rgb = data[..., :3].astype(np.float32)
    spill = np.clip(
        (np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1]) / (0.35 * 255.0),
        0.0, 1.0)
    data[..., 3] = (data[..., 3].astype(np.float32) * (1.0 - spill)).astype(np.uint8)
    for channel in (0, 2):
        data[..., channel] = np.clip(
            rgb[..., channel] * (1.0 - spill) + rgb[..., 1] * spill, 0, 255
        ).astype(np.uint8)

    # LES MIETTES DE LA CASE VOISINE. Mesuré sur la planche livrée : les trois
    # rangées se débordent l'une sur l'autre — le haut des éclats de la rangée du
    # bas atteint la rangée du milieu, et réciproquement. Découpées telles
    # quelles, les images de charge traînaient des fragments d'éclat sous elles.
    #
    # Une tache qui TOUCHE le bord de sa case et qui est PETITE vient d'à côté.
    # La condition de taille n'est pas une précaution vague : l'anneau de la
    # septième case déborde légitimement sur deux bords, et une règle qui ne
    # regarderait que le contact l'aurait effacé.
    solid = data[..., 3] > 110
    parts, count = ndimage.label(solid)
    if count:
        sizes = ndimage.sum(np.ones_like(parts), parts, range(1, count + 1))
        boxes = ndimage.find_objects(parts)
        height, width = solid.shape
        margin_y, margin_x = int(height * 0.12), int(width * 0.12)
        crumbs = []
        for index in range(1, count + 1):
            if sizes[index - 1] >= solid.size * 0.015:
                continue
            rows_at, columns_at = boxes[index - 1]
            touches = (rows_at.start == 0 or columns_at.start == 0
                       or rows_at.stop >= height or columns_at.stop >= width)
            # Confinée à la marge extérieure : même sans toucher le bord, une
            # petite tache qui ne vit que là vient de la case voisine. Le
            # dégorgement du magenta ronge parfois le pixel qui la reliait au
            # bord, et la règle du contact seule la laissait passer.
            outside = (rows_at.start >= height - margin_y
                       or rows_at.stop <= margin_y
                       or columns_at.start >= width - margin_x
                       or columns_at.stop <= margin_x)
            # LE BAS DE LA CASE. Les trois rangées de la planche se débordent,
            # et c'est toujours par le BAS que ça arrive ici : le haut des
            # éclats de la rangée suivante monte dans celle du dessus.
            #
            # Une petite tache ENTIÈREMENT sous les 80 % de la hauteur est donc
            # une miette. Mesuré : celle qui survivait faisait 0,29 % de la case
            # et son centre tombait à 0,444 du milieu — une règle sur la
            # distance au centre l'aurait laissée passer, ou aurait emporté les
            # étincelles légitimes du bord de l'anneau, qui vivent à 0,45.
            low = ring and rows_at.start > height * 0.80
            if touches or outside or low:
                crumbs.append(index)
        if crumbs:
            data[..., 3][np.isin(parts, crumbs)] = 0
    return Image.fromarray(data, "RGBA")


def cells(sheet: Image.Image) -> list:
    width, height = sheet.size
    cell_w, cell_h = width / COLUMNS, height / ROWS
    out = []
    for number in range(COLUMNS * ROWS):
        column, row = number % COLUMNS, number // COLUMNS
        box = (int(column * cell_w), int(row * cell_h),
               int((column + 1) * cell_w), int((row + 1) * cell_h))
        # Seules les sept premières cases sont des anneaux centrés.
        out.append(keyed(sheet.crop(box), ring=number < CHARGE_FRAMES))
    return out


def centred(image: Image.Image, side: int) -> Image.Image:
    """L'image recalée sur SON centre de masse, dans une case carrée.

    Recaler n'est pas cosmétique. Le modèle n'a pas posé les sept images de
    charge exactement au même endroit de leur case, et une simple mise à
    l'échelle gardait ces écarts : l'anneau sautait d'une image à l'autre au lieu
    de grossir sur place.

    Le centre de masse est le bon repère ici, et pas la boîte englobante : la
    première image est faite de quatre étincelles isolées, dont la boîte est
    étroite et décentrée, alors que leur barycentre tombe pile au centre de
    l'anneau qu'elles vont former."""
    data = np.asarray(image).astype(np.float32)
    weight = data[..., 3]
    total = float(weight.sum())
    out = Image.new("RGBA", image.size, (0, 0, 0, 0))
    if total > 0.0:
        rows, columns = np.mgrid[0:weight.shape[0], 0:weight.shape[1]]
        cy = float((rows * weight).sum() / total)
        cx = float((columns * weight).sum() / total)
        half_x, half_y = image.width * 0.5, image.height * 0.5
        out = image.transform(image.size, Image.AFFINE,
            (1, 0, cx - half_x, 0, 1, cy - half_y), resample=Image.BICUBIC)
    else:
        out = image
    return out.resize((side, side), Image.LANCZOS)


def neutral(image: Image.Image) -> Image.Image:
    """Le dessin ramené au GRIS, sa lumière conservée.

    Le prompt demandait un sceau blanc et or ; la planche livrée l'a peint en
    ROSE. Teinté tel quel, les quatre sceaux auraient tous viré au rose et on ne
    les aurait plus distingués — ce qui est précisément ce qu'on cherche à
    éviter en n'en dessinant qu'un.

    On ne relance donc pas la génération : on retire la couleur et on garde la
    lumière. Le moteur peint ensuite en rouge, bleu, vert ou blanc, et les quatre
    sceaux se lisent enfin. C'est le même partage que pour le cadre des cartes de
    personnages — le dessin donne la forme, le code donne la couleur."""
    data = np.array(image).astype(np.float32)
    luma = data[..., :3] @ np.array([0.299, 0.587, 0.114], np.float32)
    # Un rien plus clair que la luminance brute : une gravure ramenée au gris
    # perd le mordant que lui donnaient ses couleurs saturées.
    grey = np.clip(luma * 1.12, 0, 255)
    data[..., 0] = grey
    data[..., 1] = grey
    data[..., 2] = grey
    return Image.fromarray(data.astype(np.uint8), "RGBA")


def build_effects() -> list:
    """Les quatre boucles élémentaires, en bandes à case commune.

    Les quatre planches n'ont pas la même emprise dessinée — la tornade est
    haute et étroite, le brasier large et bas. On les ramène toutes à la MÊME
    case : sans ça, le sceau de feu couvrirait deux fois la surface de celui de
    l'air alors que les deux zones ont le même rayon dans le jeu."""
    built: list = []
    total = EFFECT_COLUMNS * EFFECT_ROWS
    for name in EFFECTS:
        path = SHEET.parent / f"sceau_{name}.png"
        if not path.exists():
            continue
        with Image.open(path) as image:
            sheet = image.convert("RGB")
        width, height = sheet.size
        cell_w, cell_h = width / EFFECT_COLUMNS, height / EFFECT_ROWS
        strip = Image.new("RGBA", (EFFECT_CELL * total, EFFECT_CELL), (0, 0, 0, 0))
        for number in range(total):
            column, row = number % EFFECT_COLUMNS, number // EFFECT_COLUMNS
            box = (int(column * cell_w), int(row * cell_h),
                   int((column + 1) * cell_w), int((row + 1) * cell_h))
            strip.alpha_composite(
                centred(keyed(sheet.crop(box)), EFFECT_CELL), (number * EFFECT_CELL, 0))
        strip.save(OUT / f"sceaux_fx_{name}.png")
        built.append(name)
    if built:
        (OUT / "sceaux_fx.json").write_text(json.dumps({
            "frames": total, "fps": EFFECT_FPS, "elements": built,
        }, indent=2), encoding="utf-8")
    return built


def main() -> None:
    if not SHEET.exists():
        raise SystemExit(f"{SHEET} introuvable")
    with Image.open(SHEET) as image:
        drawn = cells(image.convert("RGB"))
    if any(cell is None for cell in drawn):
        raise SystemExit("une case est vide — la planche n'a pas 3 x 3 dessins")

    OUT.mkdir(parents=True, exist_ok=True)
    strip = Image.new("RGBA", (CELL * CHARGE_FRAMES, CELL), (0, 0, 0, 0))
    for index in range(CHARGE_FRAMES):
        strip.alpha_composite(centred(drawn[index], CELL), (index * CELL, 0))
    strip.save(OUT / "sceaux_charge.png")
    (OUT / "sceaux_charge.json").write_text(json.dumps({
        "frames": CHARGE_FRAMES, "fps": FPS, "cell": [CELL, CELL],
    }, indent=2), encoding="utf-8")

    neutral(centred(drawn[7], GROUND)).save(OUT / "sceaux_seal.png")
    neutral(centred(drawn[8], GROUND)).save(OUT / "sceaux_flash.png")
    built = build_effects()
    print(f"charge {CHARGE_FRAMES} images à {FPS:.0f} img/s "
          f"({CELL * CHARGE_FRAMES}x{CELL}) · sceau et éclat {GROUND}x{GROUND} "
          f"· effets : {', '.join(built) if built else 'aucun'}")


if __name__ == "__main__":
    main()
