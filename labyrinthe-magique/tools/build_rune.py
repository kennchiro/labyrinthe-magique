#!/usr/bin/env python3
"""La bande d'animation du portail des Ténèbres.

    tools/.venv/bin/python tools/build_rune.py     # DEPUIS LA RACINE

Produit `assets/characters/shadow/rune.png` — six images côte à côte — et son
descripteur `rune.json`, au même format que l'orbe animée du Mage du Feu.

Fichier SÉPARÉ de `build_skill_icons.py`, dont il n'emprunte que le détourage :
celui-ci produit des ICÔNES, carrées et calées sur le cercle inscrit d'un bouton
tactile. Une bande d'animation ne veut rien de tout cela — elle veut des images
de MÊME cadre, alignées au pixel près.

⚠️ C'EST L'ALIGNEMENT QUI COMPTE, pas le recadrage. Recadrer chaque image sur son
propre contenu ferait sauter le portail d'une image à l'autre : les éclats qui
s'en échappent changent de hauteur à chaque pose, donc la boîte aussi. On calcule
donc UNE boîte commune — l'union des six — et toutes les images y sont posées à
leur place d'origine dans leur case.
"""

from pathlib import Path
import json
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

import numpy as np
from PIL import Image
from build_skill_icons import SOURCE, COLUMNS, ROWS

OUT = Path("assets/characters/shadow")
SHEET = SOURCE / "skill_rune.png"
NAME = "rune"
## Hauteur d'une image dans la bande finale. Le portail est affiché à ~3 cases
## de large ; 192 laisse de la marge sur les écrans à double densité.
FRAME_HEIGHT = 192

## --- POURQUOI UN DÉTOURAGE À PART -------------------------------------------
##
## `build_skill_icons.keyed` détoure par TEINTE et corrige la frange en retirant
## à chaque pixel « ce qu'il a de rouge ET de bleu en plus de son vert ». Cette
## formule marche pour le feu, l'eau et la foudre — et détruit le VIOLET, dont
## c'est exactement la signature. Essayé : le portail sortait bleu-gris et son
## cœur devenait translucide.
##
## Ici le fond ne se distingue pas par sa teinte (le portail est magenta lui
## aussi, à 78 % de la planche) mais par sa CLARTÉ : le fond est un magenta vif,
## le portail un violet sombre. Mesuré sur la planche — fond r,b ≥ 200 avec
## g ≤ 60, soit 67 % des pixels pour un fond qui en occupe 69 %.
KEY_BRIGHT = 200
KEY_GREEN = 60
## Bande où l'alpha descend progressivement : les bords fondus dans le fond.
FADE_GREEN = 110


def key_magenta(cell: Image.Image) -> Image.Image:
    """Retire le fond magenta CLAIR, garde le violet sombre du portail."""
    pixels = np.asarray(cell.convert("RGB")).astype(float)
    red, green, blue = pixels[..., 0], pixels[..., 1], pixels[..., 2]
    bright = np.minimum(red, blue)
    # « Magenta-ité » : rouge et bleu hauts, vert bas. Elle vaut 1 sur le fond
    # et retombe à 0 dès que le vert remonte — donc sur les runes claires, qui
    # sont un lilas presque blanc, comme sur le violet sombre du puits.
    keyness = np.clip((bright - KEY_BRIGHT) / 40.0, 0.0, 1.0) \
        * np.clip((FADE_GREEN - green) / float(FADE_GREEN - KEY_GREEN), 0.0, 1.0)
    data = np.dstack([pixels, (1.0 - keyness) * 255.0])
    # Dégorgement CIBLÉ : seuls les pixels partiellement magenta voient leur
    # rouge et leur bleu redescendre. Le violet, dont la magenta-ité est nulle,
    # n'est pas touché — c'est toute la différence avec la formule partagée.
    mix = keyness[..., None]
    for channel in (0, 2):
        data[..., channel] = data[..., channel] * (1.0 - mix[..., 0]) \
            + green * mix[..., 0]
    return Image.fromarray(np.clip(data, 0, 255).astype(np.uint8), "RGBA")


def main() -> None:
    if not SHEET.exists():
        print(f"  ! {SHEET} introuvable")
        return
    with Image.open(SHEET) as raw:
        sheet = raw.convert("RGB")
    cell_w = sheet.width // COLUMNS
    cell_h = sheet.height // ROWS

    # Détourage case par case, SANS recadrer : on garde la position dans la case.
    frames = []
    for row in range(ROWS):
        for column in range(COLUMNS):
            box = (column * cell_w, row * cell_h, (column + 1) * cell_w, (row + 1) * cell_h)
            full = key_magenta(sheet.crop(box))
            if full.getbbox() is None:
                print(f"  ! case {row},{column} vide après détourage")
                return
            frames.append(full)

    # ALIGNEMENT SUR LE BORD AVANT DE L'ELLIPSE.
    #
    # La position dans la case ne peut PAS servir de référence : mesuré sur la
    # planche, la seconde rangée est dessinée 91 px plus haut que la première
    # (bord avant à y 371 contre 462). Gardées telles quelles, les images 4 à 6
    # font sauter le portail d'un tiers de case, puis il redescend en bouclant.
    #
    # On aligne donc sur le BORD AVANT du corps opaque — le point où l'ellipse
    # touche le sol. C'est le seul repère stable : il est identique aux trois
    # images d'une même rangée, alors que le haut varie avec les éclats qui
    # s'échappent, et le centre avec eux. C'est exactement le rôle que jouent
    # les pieds pour les personnages.
    rims = [_rim(frame) for frame in frames]
    target = max(rims)
    aligned = []
    for frame, rim in zip(frames, rims):
        shifted = Image.new("RGBA", frame.size, (0, 0, 0, 0))
        shifted.alpha_composite(frame, (0, target - rim))
        aligned.append(shifted)
    frames = aligned

    # Boîte COMMUNE : l'union des six contenus.
    left, top, right, bottom = cell_w, cell_h, 0, 0
    for frame in frames:
        bounds = frame.getbbox()
        left, top = min(left, bounds[0]), min(top, bounds[1])
        right, bottom = max(right, bounds[2]), max(bottom, bounds[3])
    span = (right - left, bottom - top)

    scale = FRAME_HEIGHT / float(span[1])
    frame_width = int(round(span[0] * scale))
    strip = Image.new("RGBA", (span[0] * len(frames), span[1]), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        strip.alpha_composite(frame.crop((left, top, right, bottom)), (index * span[0], 0))
    strip = strip.resize((frame_width * len(frames), FRAME_HEIGHT), Image.LANCZOS)

    OUT.mkdir(parents=True, exist_ok=True)
    strip.save(OUT / f"{NAME}.png")
    (OUT / f"{NAME}.json").write_text(
        json.dumps({"frames": len(frames), "cell": [frame_width, FRAME_HEIGHT]}, indent=2),
        encoding="utf-8")
    print(f"{NAME} : {len(frames)} images de {frame_width}x{FRAME_HEIGHT} "
          f"(boîte commune {span[0]}x{span[1]} dans une case de {cell_w}x{cell_h})")


## Bord avant de l'ellipse : la dernière ligne franchement opaque.
##
## Le seuil est HAUT (200) volontairement : les éclats et le halo qui entourent
## le portail sont translucides, et les inclure ferait dépendre le repère de ce
## qui vole autour plutôt que de l'anneau lui-même.
def _rim(frame: Image.Image) -> int:
    alpha = np.asarray(frame)[..., 3]
    rows = np.nonzero((alpha > 200).any(axis=1))[0]
    return int(rows[-1]) if rows.size else frame.height - 1


if __name__ == "__main__":
    main()
