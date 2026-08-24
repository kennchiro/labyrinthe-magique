#!/usr/bin/env python3
"""L'Invocateur : le huitième mage, ses créatures et ses effets.

    tools/.venv/bin/python tools/build_invocateur.py     # DEPUIS LA RACINE

Produit :
    assets/characters/invocateur/{down,up,left,right}.png + frames.json
    assets/characters/invocateur/{orb,impact,zone,warp}.png + orb.json
    assets/allies/{imp,gargouille,dragon_down,dragon_up,dragon_left,dragon_right}.png
    assets/allies/allies.json

PLANCHE REMPLACÉE LE 2026-08-24 : `mage_invocateur.png` succède au JPEG.

La différence n'est pas cosmétique, elle vide la moitié de l'ancien outil :

  - la nouvelle planche a un VRAI CANAL ALPHA. Tout le détourage « pixel neutre
    connecté au bord », les seuils de désaturation qui tuaient les étiquettes de
    texte, le flou d'un demi-pixel contre le crénelage du JPEG : plus rien de
    tout cela n'a lieu d'être. Il ne reste qu'une règle, celle des voisines —
    dans une boîte, la matière qui entre par un bord appartient au dessin d'à
    côté.

  - elle dessine BEAUCOUP plus : 14 poses de marche (4 de face, 4 de dos, 6 de
    profil gauche), six poses de sort, quatre créatures en plusieurs poses
    chacune, une douzaine d'effets. Les orientations restent inégales — rien
    n'est dessiné vers la DROITE, ni pour le mage ni pour le dragon : la droite
    est le miroir de la gauche, comme sur la planche du spectre.

  - ses vues de dragon vues de dessus montrent toutes le DOS, tête en haut :
    ce sont des poses « up ». Les seules poses tête en bas sont les deux
    silhouettes à ailes rabattues du bas de planche — d'où un dragon « down »
    plus plat que son « up », ce qui est juste : il pique vers le joueur.

Les boîtes ci-dessous sont les boîtes englobantes des formes connexes de la
planche, relevées par étiquetage puis attribuées à la main. Elles sont donc
EXACTES au pixel, contrairement aux boîtes de l'ancienne planche mesurées à
l'œil.
"""

from pathlib import Path
import json
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

import numpy as np
from PIL import Image
from scipy import ndimage
from build_characters import (CELL_PADDING, FRAME_HEIGHT, POSES, SOURCE, anchor)

SHEET = SOURCE / "mage_invocateur.png"
OUT_MAGE = Path("assets/characters/invocateur")
OUT_ALLIES = Path("assets/allies")

## En dessous, un pixel est du halo ; au-dessus, il est de la matière.
SOLID_ALPHA = 40
## Une forme plus petite que ça dans une boîte est une miette, pas un dessin.
CRUMB = 40


# --- Le mage ---------------------------------------------------------------------
#
# Les quatre poses de face et de dos suffisent au cycle de marche ; le profil en
# offre six, dont deux au repos (pieds joints, bâton vertical). L'IDLE n'est
# donc pas la première pose de la rangée mais celle où le mage se tient droit —
# la première est déjà en pleine foulée, et un mage à l'arrêt jambes écartées se
# voit tout de suite.

WALK = {
    "down": {"cycle": [(9, 7, 87, 123), (118, 6, 193, 124),
                       (217, 5, 302, 123), (330, 5, 419, 122)],
             "idle": (330, 5, 419, 122)},
    "up": {"cycle": [(447, 8, 522, 123), (550, 8, 631, 124),
                     (670, 5, 746, 123), (784, 6, 859, 123)],
           "idle": (670, 5, 746, 123)},
    # Les six poses de profil sont dessinées vers la GAUCHE. Les quatre premières
    # marchent, les deux dernières se tiennent debout : la cinquième fait l'idle,
    # la sixième ne sert pas — deux poses de repos ne s'animent pas.
    "left": {"cycle": [(901, 11, 982, 122), (1009, 6, 1097, 122),
                       (1122, 10, 1202, 122), (1222, 9, 1296, 122)],
             "idle": (1323, 6, 1404, 122)},
}

## La pose d'ATTAQUE, par direction. `mirror` retourne à la découpe.
## Le dos n'a pas de geste dessiné : il retombe sur son idle, et le coup se lit
## alors au projectile qui part — c'était déjà le choix de l'ancienne planche.
ATTACK = {
    "down": {"box": (480, 137, 565, 255)},                  # bâton levé, de face
    "right": {"box": (104, 139, 221, 255)},                 # fente, bâton tendu
    "left": {"box": (104, 139, 221, 255), "mirror": True},
}


# --- Les effets ------------------------------------------------------------------
#
# Mêmes noms de fichiers que `build_spell_fx.py` pour les sept autres mages, à
# une addition près : la planche dessine enfin un IMPACT, que le JPEG n'avait
# pas. Le moteur le prend s'il existe et retombe sur son éclat procédural sinon.
#
# Le choix des formes suit ce que le moteur en FAIT :
#   orb    tourne sur lui-même quand le sort n'a pas de traînée (MagicOrb) —
#          donc une sphère, jamais une comète, qui pointerait n'importe où.
#   impact tourne AUSSI (draw_set_transform, t * 1.6) — un vortex, pas une
#          gerbe de cristaux qui aurait un haut et un bas.
#   zone   est écrasée à l'horizontale (1.12 x 0.74) pour se poser au sol —
#          le pentacle y devient l'ellipse gravée que promet le sort.
ORB_FRAMES = [(504, 269, 557, 319), (586, 263, 652, 325)]
SPELL_FX = {
    "impact.png": (802, 266, 897, 361),   # le vortex
    "zone.png": (682, 266, 763, 353),     # le pentacle d'invocation
    "warp.png": (1298, 257, 1399, 348),   # le dôme de translation, sur son socle
}


# --- Les créatures ---------------------------------------------------------------
#
# Une BANDE par créature et par direction, comme les mages : les poses d'inaction
# d'abord, la pose de coup ensuite, toutes dans une case commune à la créature.
# La case commune n'est pas un détail — le moteur dimensionne sur la HAUTEUR de
# la texture ; des images de tailles libres feraient enfler et rétrécir la bête
# à chaque image.
#
# `feet` cale sur le milieu des pieds (les marcheurs), `centre` sur le centre de
# la boîte (le dragon vole, le jeu dessine son ombre à part).
#
# Le dragon est le seul à avoir quatre directions. Les marcheurs n'ont qu'une
# vue de face ; leur profil gauche est un miroir, comme avant.
ALLIES = {
    "imp": {
        "anchor": "feet", "mirror_left": True,
        # Ses trois poses d'inaction sont un BATTEMENT D'AILES : 102, 134 puis
        # 148 px d'envergure pour 9 % de hauteur en plus seulement. Jouées en
        # boucle simple, l'aile grande ouverte claquerait d'un coup sur l'aile
        # repliée ; la bande revient donc par la pose du milieu.
        "directions": {"down": {
            "idle": [(413, 345, 515, 436), (264, 349, 398, 443),
                     (691, 366, 839, 465), (264, 349, 398, 443)],
            "strike": [(537, 348, 672, 448)],   # gueule ouverte, en avant
        }},
    },
    # La grosse bête rouge de la planche. Elle est deux fois plus lourde que les
    # diablotins et crache le feu : c'est elle qui tient le rôle de la gargouille
    # — « lente mais qui frappe deux fois plus fort ».
    "gargouille": {
        "anchor": "feet", "mirror_left": True,
        "directions": {"down": {
            "idle": [(899, 365, 1141, 500), (736, 452, 946, 581)],
            "strike": [(1153, 349, 1433, 498)],  # souffle, dessiné vers la droite
        }},
    },
    "dragon": {
        "anchor": "centre", "mirror_left": False,
        "directions": {
            # Vues de dessus, dos visible, tête EN HAUT : ce sont les poses de
            # montée. Deux battements d'ailes, le plus ouvert pour le coup.
            "up": {"idle": [(1131, 661, 1317, 792)],
                   "strike": [(701, 610, 939, 775)]},
            # Les deux seules silhouettes tête en bas de la planche, ailes
            # rabattues : le dragon qui pique vers le bas de l'écran.
            "down": {"idle": [(1047, 930, 1310, 1018)],
                     "strike": [(827, 941, 1054, 1018)]},
            # Le profil est dessiné vers la DROITE, souffle compris.
            "right": {"idle": [(1262, 780, 1527, 960)],
                      "strike": [(6, 602, 342, 774)]},
            "left": {"idle": [{"box": (1262, 780, 1527, 960), "mirror": True}],
                     "strike": [{"box": (6, 602, 342, 774), "mirror": True}]},
        },
    },
}

## Fichiers de l'ancienne planche que ce format remplace : une pose par fichier,
## sans case commune. Laissés sur le disque, ils se chargeraient encore.
STALE_ALLIES = [f"dragon_{d}_{i}.png" for d in ("down", "up", "left", "right")
                for i in (0, 1)]


def load_sheet() -> Image.Image:
    """La planche telle quelle : son alpha est déjà le bon."""
    return Image.open(SHEET).convert("RGBA")


def crop_clean(image: Image.Image, box, mirror: bool = False) -> Image.Image:
    """Vignette recadrée, sans les miettes des voisines.

    L'alpha de la planche étant vrai, il ne reste qu'une question : à qui
    appartient chaque forme de la boîte ? La plus grosse est le sujet. Une autre
    ne survit que si elle est ENCLAVÉE — l'orbe détaché au bout du bâton, un
    éclat qui gravite. Celle qui touche un bord de la boîte entre par là : c'est
    la voisine, elle part. Sauf si ce bord est aussi celui de la planche, où il
    n'y a pas de voisine possible."""
    if isinstance(box, dict):
        mirror = box.get("mirror", mirror)
        box = box["box"]
    crop = image.crop(box)
    pixels = np.array(crop)
    mask = pixels[..., 3] > SOLID_ALPHA
    labels, count = ndimage.label(mask, structure=np.ones((3, 3)))
    if count == 0:
        raise SystemExit(f"boîte vide : {box}")
    sizes = ndimage.sum(np.ones_like(labels), labels, range(1, count + 1))
    main = int(np.argmax(sizes)) + 1
    height, width = mask.shape
    sheet_w, sheet_h = image.size
    for index in range(1, count + 1):
        if index == main:
            continue
        member = labels == index
        ys, xs = np.nonzero(member)
        touches = (xs.min() == 0 and box[0] > 0) \
            or (ys.min() == 0 and box[1] > 0) \
            or (xs.max() == width - 1 and box[2] < sheet_w) \
            or (ys.max() == height - 1 and box[3] < sheet_h)
        if touches or sizes[index - 1] < CRUMB:
            pixels[..., 3][member] = 0

    # Un halo à alpha faible reste accroché à une forme effacée : il n'appartient
    # plus à rien et se verrait en fantôme. Un pixel translucide ne survit que
    # rattaché à de la matière restée opaque.
    soft = pixels[..., 3] > 0
    parts, _ = ndimage.label(soft, structure=np.ones((3, 3)))
    anchored = np.unique(parts[pixels[..., 3] > SOLID_ALPHA])
    pixels[..., 3][~np.isin(parts, anchored[anchored > 0])] = 0

    out = Image.fromarray(pixels, "RGBA")
    bbox = out.getbbox()
    if bbox is None:
        raise SystemExit(f"boîte vidée par le nettoyage : {box}")
    out = out.crop(bbox)
    return out.transpose(Image.FLIP_LEFT_RIGHT) if mirror else out


def build_mage(image: Image.Image) -> None:
    """Les quatre bandes du mage, six poses chacune, calées sur les pieds."""
    cells = {}
    for direction, entry in WALK.items():
        cycle = [crop_clean(image, box) for box in entry["cycle"]]
        cells[(direction, "idle")] = crop_clean(image, entry["idle"])
        for index, pose in enumerate(POSES[1:5]):
            cells[(direction, pose)] = cycle[index]
    # La droite n'est pas dessinée : c'est la gauche retournée, pose par pose.
    for pose in POSES[:5]:
        cells[("right", pose)] = cells[("left", pose)].transpose(Image.FLIP_LEFT_RIGHT)
    for direction, entry in ATTACK.items():
        cells[(direction, "attack")] = crop_clean(image, entry["box"],
                                                  entry.get("mirror", False))
    cells[("up", "attack")] = cells[("up", "idle")]

    anchored = {}
    extents = []
    for key, crop in cells.items():
        point = anchor(np.array(crop)[..., 3] > SOLID_ALPHA)
        if point is None:
            raise SystemExit(f"pose vide : {key}")
        anchored[key] = (crop, point)
        extents.append((point[0], crop.width - point[0], point[1]))

    # La case est SYMÉTRIQUE autour des pieds : le moteur centre le Sprite2D
    # horizontalement, un mage calé de travers serait dessiné à côté de sa case.
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
    print(f"invocateur : bande {cell_width * len(POSES)}x{FRAME_HEIGHT} "
          f"(case {cell_width}x{FRAME_HEIGHT})")


def _place(frames: list, cell: tuple, mode: str) -> Image.Image:
    """Les images d'une créature dans une bande à case commune.

    `feet` pose chaque image sur le SOL de la case, milieu des pieds au milieu
    de la case : une bête qui marche ne doit pas flotter d'une image à l'autre.
    `centre` centre la boîte — le dragon vole, il n'a pas de sol."""
    cell_w, cell_h = cell
    band = Image.new("RGBA", (cell_w * len(frames), cell_h), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        x0 = index * cell_w
        if mode == "feet":
            point = anchor(np.array(frame)[..., 3] > SOLID_ALPHA)
            band.alpha_composite(frame, (int(x0 + cell_w * 0.5 - point[0]),
                                         int(cell_h - 2 - point[1])))
        else:
            band.alpha_composite(frame, (int(x0 + (cell_w - frame.width) * 0.5),
                                         int((cell_h - frame.height) * 0.5)))
    return band


def build_allies(image: Image.Image) -> None:
    """Une bande par créature et par direction, plus le descripteur commun."""
    OUT_ALLIES.mkdir(parents=True, exist_ok=True)
    for name in STALE_ALLIES:
        for path in (OUT_ALLIES / name, OUT_ALLIES / (name + ".import")):
            if path.exists():
                path.unlink()

    catalogue = {}
    for name, entry in ALLIES.items():
        cut = {}
        for direction, poses in entry["directions"].items():
            cut[direction] = {key: [crop_clean(image, box) for box in poses[key]]
                              for key in ("idle", "strike")}
        # La case est commune à TOUTES les directions d'une créature : le dragon
        # qui pique est plus plat que celui qui monte, et c'est ce rapport-là
        # qu'il faut garder — une case par direction le gommerait.
        every = [f for d in cut.values() for k in d.values() for f in k]
        cell = (max(f.width for f in every) + 4, max(f.height for f in every) + 4)
        directions = {}
        for direction, poses in cut.items():
            frames = poses["idle"] + poses["strike"]
            band = _place(frames, cell, entry["anchor"])
            file = f"{name}.png" if len(cut) == 1 else f"{name}_{direction}.png"
            band.save(OUT_ALLIES / file)
            directions[direction] = {"file": file, "idle": len(poses["idle"]),
                                     "strike": len(poses["strike"])}
        catalogue[name] = {"anchor": entry["anchor"], "cell": list(cell),
                           "mirror_left": entry["mirror_left"],
                           "directions": directions}
        print(f"{name:11s} case {cell[0]}x{cell[1]} · "
              + " · ".join(f"{d} x{v['idle']}+{v['strike']}"
                           for d, v in directions.items()))
    (OUT_ALLIES / "allies.json").write_text(
        json.dumps(catalogue, indent=2), encoding="utf-8")


def build_fx(image: Image.Image) -> None:
    frames = [crop_clean(image, box) for box in ORB_FRAMES]
    cell = (max(f.width for f in frames), max(f.height for f in frames))
    _place(frames, cell, "centre").save(OUT_MAGE / "orb.png")
    (OUT_MAGE / "orb.json").write_text(
        json.dumps({"frames": len(frames), "cell": list(cell)}), encoding="utf-8")
    for name, box in SPELL_FX.items():
        crop_clean(image, box).save(OUT_MAGE / name)
    print(f"effets : orbe x{len(frames)} {cell} · "
          + " · ".join(sorted(SPELL_FX)))


def main() -> None:
    image = load_sheet()
    build_mage(image)
    build_allies(image)
    build_fx(image)


if __name__ == "__main__":
    main()
