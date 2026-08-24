#!/usr/bin/env python3
"""L'Invocateur : le huitième mage, et ses créatures.

    tools/.venv/bin/python tools/build_invocateur.py     # DEPUIS LA RACINE

Produit :
    assets/characters/invocateur/{down,up,left,right}.png + frames.json
    assets/allies/{imp,gargouille}.png + dragon_{down,up,left,right}.png + allies.json

Fichier SÉPARÉ de build_characters.py, comme build_bestiary.py et pour la même
raison : ce dernier est édité en parallèle. On réutilise son vocabulaire
(POSES, ancrage aux pieds, case symétrique) sans toucher à sa table.

Sa planche ne ressemble à AUCUNE autre :

  - c'est un JPEG. Pas de canal alpha, un damier PEINT, et du bruit de
    compression par-dessus. Le damier n'a pas deux couleurs mais une nappe de
    gris — le détourage par couleurs de référence laissait des carreaux
    fantômes. Le critère retenu : un pixel NEUTRE (canaux quasi égaux, ni noir
    ni blanc pur) CONNECTÉ AU BORD de la planche est du fond. Les étiquettes
    de texte, neutres et posées sur le fond, partent avec lui ; les contours
    noirs et les reflets gris des sprites, enclavés, restent.

  - les orientations sont INÉGALES : 4 poses de face, 5 de dos, 4 vers la
    gauche, 3 vers la droite. La marche a besoin de 4 temps : la droite boucle
    en ping-pong (1-2-3-2), la gauche est dessinée, rien n'est retourné.

  - il n'y a pas de rangée d'attaque : le geste est pris ailleurs — bras levé
    d'invocation pour la face, fente de tir pour les profils (dessinée vers la
    droite, retournée pour la gauche), pose de dos pour le dos.
"""

from pathlib import Path
from collections import deque
import json
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

import numpy as np
from PIL import Image, ImageFilter
from build_characters import (CELL_PADDING, FRAME_HEIGHT, POSES, SOURCE, anchor)

SHEET = SOURCE / "mage_invocateur.jpeg"
OUT_MAGE = Path("assets/characters/invocateur")
OUT_ALLIES = Path("assets/allies")

## Un pixel est « neutre » si ses canaux se tiennent dans cet écart.
NEUTRAL_SPREAD = 22
## Bornes de luminance du damier : en dessous c'est un contour, au-dessus un éclat.
NEUTRAL_LUM = (52, 232)

# --- Boîtes relevées à la main sur la planche (pixels source) ---------------------
#
# La planche mélange sprites, étiquettes de texte et vignettes de tailles
# libres : rien à déduire, tout est désigné. Les 16 poses de marche, elles,
# sont détectées par profil de colonnes dans leur bande — elles au moins sont
# alignées.

WALK_BAND = (0, 158)
## Répartition des 16 poses de marche : combien pour chaque direction, dans
## l'ordre où la planche les dessine.
WALK_GROUPS = [("down", 4), ("up", 5), ("left", 4), ("right", 3)]

## Poses isolées. `mirror` = retourner horizontalement à la découpe.
MAGE_EXTRAS = {
    ("down", "attack"): {"box": (770, 150, 875, 300)},  # bras levé, geste d'invocation
    ("right", "attack"): {"box": (315, 300, 470, 475)}, # fente de tir, dessinée à droite
    ("left", "attack"): {"box": (315, 300, 470, 475), "mirror": True},
}

## Les créatures invoquées. L'ancre du dragon est son CENTRE : il vole, le poser
## sur des pieds n'aurait pas de sens — le jeu dessine son ombre séparément.
ALLIES = {
    # `erase` : zones effacées APRÈS découpe, en pixels locaux de la boîte. La
    # volute de fumée de l'apparition colle à l'imp — jolie sur la planche,
    # absurde accrochée à une créature qui marche.
    "imp": {"box": (168, 148, 305, 272), "anchor": "feet", "erase": [(0, 70, 52, 124)]},
    # Coupée au-dessus de son socle : le cercle d'invocation sous ses pieds est
    # joli sur la planche, absurde sous une créature qui marche.
    "gargouille": {"box": (920, 155, 1050, 269), "anchor": "feet"},
    "dragon_down": {"boxes": [(505, 625, 655, 768), (985, 665, 1165, 768)], "anchor": "centre"},
    "dragon_up": {"boxes": [(492, 470, 640, 655), (915, 440, 1225, 655)], "anchor": "centre"},
    # Les boîtes des poses de souffle sont LARGES : la flamme doit tenir dedans
    # tout entière, car une forme qui touche le bord de sa boîte est traitée
    # comme un débordement de voisine et effacée.
    # La rangée « LEFT FLIGHT FIRE » de la planche ment : son premier dragon n'a
    # pas de flamme et le second souffle vers la DROITE. Le souffle gauche est
    # donc le miroir du souffle droit, qui est net.
    "dragon_left": {"boxes": [(160, 485, 340, 640),
                              {"box": (918, 316, 1180, 470), "mirror": True}],
                    "anchor": "centre"},
    "dragon_right": {"boxes": [(1185, 280, 1408, 475), (918, 316, 1180, 470)], "anchor": "centre"},
}


def load_sheet() -> Image.Image:
    """La planche avec un vrai canal alpha : le damier est effacé.

    Neutre + connecté au bord = fond. Le remplissage part des quatre bords et ne
    traverse jamais un pixel coloré : les gris INTERNES d'un sprite — boucles de
    ceinture, reflets de capuche — ne sont pas atteignables, ils restent.
    """
    rgb = np.array(Image.open(SHEET).convert("RGB")).astype(int)
    height, width = rgb.shape[:2]
    spread = rgb.max(axis=2) - rgb.min(axis=2)
    lum = rgb.mean(axis=2)
    neutral = (spread < NEUTRAL_SPREAD) & (lum > NEUTRAL_LUM[0]) & (lum < NEUTRAL_LUM[1])

    background = np.zeros((height, width), bool)
    queue = deque()
    for x in range(width):
        for y in (0, height - 1):
            if neutral[y, x] and not background[y, x]:
                background[y, x] = True
                queue.append((y, x))
    for y in range(height):
        for x in (0, width - 1):
            if neutral[y, x] and not background[y, x]:
                background[y, x] = True
                queue.append((y, x))
    while queue:
        y, x = queue.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < height and 0 <= nx < width and neutral[ny, nx] \
                    and not background[ny, nx]:
                background[ny, nx] = True
                queue.append((ny, nx))

    alpha = np.where(background, 0, 255).astype(np.uint8)
    image = Image.fromarray(np.dstack([rgb.astype(np.uint8), alpha]), "RGBA")
    # Bord adouci d'un demi-pixel : le JPEG a déjà mangé la netteté du trait,
    # un détourage dur par-dessus ferait un liseré crénelé.
    image.putalpha(image.split()[3].filter(ImageFilter.GaussianBlur(0.5)))
    return image


def crop_clean(image: Image.Image, box: tuple, mirror: bool = False) -> Image.Image:
    """Vignette détourée, sans les miettes des voisines.

    Dans la boîte, seule la matière CONNECTÉE à la plus grosse forme survit —
    plus les formes détachées franchement à l'intérieur (l'orbe au bout du
    bâton). Une forme qui touche le bord de la boîte sans être la principale
    est un morceau du voisin."""
    from scipy import ndimage
    crop = image.crop(box)
    pixels = np.array(crop)
    mask = pixels[..., 3] > 40
    labels, count = ndimage.label(mask, structure=np.ones((3, 3)))
    h, w = mask.shape
    rgb = pixels[..., :3].astype(int)
    spread = rgb.max(axis=2) - rgb.min(axis=2)
    sizes = ndimage.sum(np.ones_like(labels), labels, range(1, count + 1))         if count else np.zeros(0)
    # La plus grosse forme COLORÉE est le sprite. Pas la plus grosse tout court :
    # les étiquettes de la planche (« DOWN FLIGHT »…) sont du blanc cerclé de
    # noir — leur contour bloque le remplissage du damier, elles survivent au
    # détourage et pèsent parfois plus lourd que la vignette qu'elles annoncent.
    # 30 et pas moins : le bruit de compression JPEG teinte légèrement le texte
    # blanc des étiquettes (mesuré entre 18 et 28 de dispersion moyenne), alors
    # que la plus terne des créatures — l'or passé du dragon — dépasse 45.
    def colour_of(index: int) -> float:
        member = labels == index
        return float(spread[member].mean()) if member.any() else 0.0
    main = 0
    best = -1.0
    for i in range(1, count + 1):
        if colour_of(i) < 30.0:
            continue
        if sizes[i - 1] > best:
            best = float(sizes[i - 1])
            main = i
    for i in range(1, count + 1):
        if i == main:
            continue
        member = labels == i
        ys, xs = np.nonzero(member)
        # Toucher un bord de boîte trahit un débordement de voisine — SAUF si ce
        # bord est aussi celui de la planche : la boule de feu du dragon gauche
        # est dessinée contre le bas de l'image, elle n'a de voisin nulle part.
        sheet_w, sheet_h = image.size
        touches = (xs.min() == 0 and box[0] > 0)             or (ys.min() == 0 and box[1] > 0)             or (xs.max() == w - 1 and box[2] < sheet_w)             or (ys.max() == h - 1 and box[3] < sheet_h)
        # Meurent : les formes grises (texte, volutes de fumée, poussière JPEG),
        # les miettes, et ce qui entre par le bord — c'est le voisin.
        if touches or sizes[i - 1] < 40 or colour_of(i) < 30.0:
            pixels[..., 3][member] = 0

    # Effacer un noyau ne suffit pas : le flou du détourage lui a fabriqué un
    # halo à alpha faible, qui n'appartient à aucune forme et resterait en
    # fantôme grisâtre. Un pixel translucide ne survit que rattaché à de la
    # matière encore opaque.
    soft = pixels[..., 3] > 0
    parts, _ = ndimage.label(soft, structure=np.ones((3, 3)))
    anchored = np.unique(parts[pixels[..., 3] > 40])
    pixels[..., 3][~np.isin(parts, anchored[anchored > 0])] = 0
    out = Image.fromarray(pixels, "RGBA")
    return out.transpose(Image.FLIP_LEFT_RIGHT) if mirror else out


def walk_boxes(image: Image.Image) -> list:
    """Les 16 poses de marche, par profil de colonnes dans leur bande."""
    y0, y1 = WALK_BAND
    alpha = np.array(image)[y0:y1, :, 3] > 40
    profile = alpha.sum(axis=0)
    out, start, last = [], None, None
    for x, value in enumerate(profile):
        if value > 2:
            start = x if start is None else start
            last = x
        elif start is not None and x - last > 4:
            if last - start > 20:
                out.append((start, y0, last + 1, y1))
            start = None
    if start is not None and last - start > 20:
        out.append((start, y0, last + 1, y1))

    # Deux poses peuvent se toucher par le bâton et fusionner leur boîte. Une
    # boîte large comme deux poses est refendue à sa colonne la plus creuse,
    # cherchée au milieu — jamais sur un bord, où le creux est trivial.
    split = []
    for x0, by0, x1, by1 in out:
        if x1 - x0 < 110:
            split.append((x0, by0, x1, by1))
            continue
        window = profile[x0:x1]
        third = (x1 - x0) // 3
        pivot = x0 + third + int(np.argmin(window[third:2 * third]))
        split.append((x0, by0, pivot, by1))
        split.append((pivot, by0, x1, by1))
    return split


def build_mage(image: Image.Image) -> None:
    boxes = walk_boxes(image)
    expected = sum(n for _, n in WALK_GROUPS)
    if len(boxes) != expected:
        raise SystemExit(f"marche : {len(boxes)} poses trouvées, {expected} attendues")

    cells = {}
    cursor = 0
    for direction, count in WALK_GROUPS:
        group = boxes[cursor:cursor + count]
        cursor += count
        # 4 temps de marche quels que soient les dessins disponibles :
        # 5 poses -> la première est l'idle ; 4 -> la première sert deux fois ;
        # 3 -> ping-pong 1-2-3-2. Aucun trou, aucun miroir.
        if count == 5:
            order = [0, 1, 2, 3, 4]
        elif count == 4:
            order = [0, 0, 1, 2, 3]
        else:
            order = [0, 0, 1, 2, 1]
        for pose_index, pose in enumerate(["idle", "walk_1", "walk_2", "walk_3", "walk_4"]):
            if (direction, pose) in cells:
                continue
            cells[(direction, pose)] = crop_clean(image, group[order[pose_index]])

    for key, entry in MAGE_EXTRAS.items():
        cells[key] = crop_clean(image, entry["box"], entry.get("mirror", False))
    # Le dos n'a pas de geste dessiné : sa première pose fait l'affaire, le coup
    # se lit alors au projectile qui part.
    cells[("up", "attack")] = cells[("up", "idle")]

    anchored = {}
    extents = []
    for key, crop in cells.items():
        point = anchor(np.array(crop)[..., 3] > 40)
        if point is None:
            raise SystemExit(f"pose vide : {key}")
        anchored[key] = (crop, point)
        extents.append((point[0], crop.width - point[0], point[1]))

    half = max(max(e[0] for e in extents), max(e[1] for e in extents))
    height = int(max(e[2] for e in extents)) + 10
    scale = FRAME_HEIGHT / float(height)
    cell_width = 2 * int(np.ceil(half * scale)) + CELL_PADDING
    source_width = int(round(cell_width / scale))

    OUT_MAGE.mkdir(parents=True, exist_ok=True)
    for direction in ("down", "up", "left", "right"):
        strip = Image.new("RGBA", (source_width * len(POSES), height), (0, 0, 0, 0))
        for pose_index, pose in enumerate(POSES):
            crop, (ax, ay) = anchored[(direction, pose)]
            x = int(pose_index * source_width + source_width * 0.5 - ax)
            y = int(height - 5 - ay)
            strip.alpha_composite(crop, (x, y))
        strip = strip.resize((cell_width * len(POSES), FRAME_HEIGHT), Image.LANCZOS)
        strip.save(OUT_MAGE / f"{direction}.png")

    (OUT_MAGE / "frames.json").write_text(json.dumps({
        "cell": [cell_width, FRAME_HEIGHT],
        "feet_y": round(FRAME_HEIGHT - 5 * scale, 1),
        "poses": POSES,
        "directions": ["down", "up", "left", "right"],
        "source": SHEET.name,
    }, indent=2), encoding="utf-8")
    print(f"invocateur : bande {cell_width * len(POSES)}x{FRAME_HEIGHT}")


def build_allies(image: Image.Image) -> None:
    """Les créatures : une image par pose, un descripteur commun.

    Pas de bande ici : l'imp et la gargouille n'ont qu'une pose (le jeu les
    anime en procédural), le dragon a deux poses par direction — vol et
    souffle — que le jeu échange au moment de l'attaque."""
    OUT_ALLIES.mkdir(parents=True, exist_ok=True)
    catalogue = {}
    for name, entry in ALLIES.items():
        boxes = entry.get("boxes", [entry.get("box")])
        frames = []
        for index, box in enumerate(boxes):
            flip = isinstance(box, dict)
            if flip:
                box = box["box"]
            crop = crop_clean(image, box, mirror=flip)
            for zone in entry.get("erase", []):
                cleared = np.array(crop)
                cleared[zone[1]:zone[3], zone[0]:zone[2], 3] = 0
                crop = Image.fromarray(cleared, "RGBA")
            bbox = crop.getbbox()
            crop = crop.crop(bbox)
            suffix = "" if len(boxes) == 1 else f"_{index}"
            crop.save(OUT_ALLIES / f"{name}{suffix}.png")
            frames.append({"file": f"{name}{suffix}.png",
                           "size": [crop.width, crop.height]})
        catalogue[name] = {"frames": frames, "anchor": entry["anchor"]}
    (OUT_ALLIES / "allies.json").write_text(
        json.dumps(catalogue, indent=2), encoding="utf-8")
    print(f"alliés : {len(ALLIES)} entrées dans {OUT_ALLIES}")


## Les effets de pouvoir, découpés de la même planche — mêmes fichiers de
## sortie que build_spell_fx.py pour les sept autres mages. `impact.png` n'est
## pas produit : la planche n'a pas de dessin d'impact, le jeu retombe alors
## sur son éclat procédural, prévu pour ça.
SPELL_FX = {
    "orb.png": (452, 350, 512, 402),     # l'orbe spirale, sans direction
    "zone.png": (874, 242, 1068, 318),   # le pentacle d'invocation
    "warp.png": (820, 330, 912, 432),    # l'anneau doré
}


def build_fx(image: Image.Image) -> None:
    for name, box in SPELL_FX.items():
        crop = crop_clean(image, box)
        bbox = crop.getbbox()
        if bbox is None:
            raise SystemExit(f"effet vide : {name}")
        crop.crop(bbox).save(OUT_MAGE / name)
    (OUT_MAGE / "orb.json").write_text(json.dumps({"frames": 1}), encoding="utf-8")
    print(f"effets : {len(SPELL_FX)} fichiers + orb.json")


def main() -> None:
    image = load_sheet()
    build_mage(image)
    build_allies(image)
    build_fx(image)


if __name__ == "__main__":
    main()
