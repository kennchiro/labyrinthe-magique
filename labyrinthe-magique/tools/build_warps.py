#!/usr/bin/env python3
"""L'effet de téléportation de chaque mage, découpé de sa planche.

    tools/.venv/bin/python tools/build_warps.py      # DEPUIS LA RACINE

Le sort de FUITE déplaçait le mage d'un coup, sans rien montrer : trop brusque,
on ne comprenait pas ce qui venait de se passer. Chaque planche porte pourtant,
dans sa bande du bas, une section « DISPARITION / APPARITION ».

Les sept planches ne la dessinent PAS de la même façon :

    terre, air         une colonne vide, puis la même avec la silhouette dedans
    suprême, foudre    les deux colonnes, mais COLLÉES — un seul bloc détecté
    feu                un anneau de flammes au sol, puis le mage dans un pilier
    eau                un cercle magique, une colonne, un ovale — aucune silhouette
    ténèbres           pas de colonne : un vortex violet, dans les particules

On ne retient donc qu'UNE forme par mage — la colonne ou le portail SANS
personnage — et le jeu anime le reste : le mage s'efface, la colonne monte,
elle redescend ailleurs, le mage revient. Prendre la version « avec silhouette »
aurait affiché deux mages superposés, celui du dessin et celui du joueur.

Les boîtes sont ÉCRITES À LA MAIN. La détection par formes connexes a été
essayée : elle trouve bien les blocs, mais elle ne sait pas dire lequel est la
colonne vide, ni séparer deux colonnes qui se touchent.
"""

from pathlib import Path
from PIL import Image

SOURCE = Path("assets/peso&cover/mages")
OUT = Path("assets/characters")

## id -> (planche, boîte (x0, y0, x1, y1) relevée sur la planche)
WARPS = {
    "fire":    ("mage_fire.png",    (770, 870, 909, 994)),   # anneau de flammes
    "water":   ("mage_circle.png",  (759, 864, 859, 992)),   # colonne de lumière
    "earth":   ("mage_earth.png",   (744, 679, 895, 961)),   # colonne de pierre
    "shadow":  ("mage_dark.png",    (1128, 802, 1240, 868)),  # portail d'ombre
    "supreme": ("mage_element.png", (761, 675, 872, 906)),   # moitié GAUCHE du bloc
    "thunder": ("mage_thunder.png", (767, 711, 927, 985)),   # moitié GAUCHE du bloc
    # ⚠️ Boîte refaite : la précédente (795, 740, 900, 980) coupait le dessin
    # EN DEUX — le cercle magique au sol va jusqu'à x=960, elle s'arrêtait à
    # 900. Le mage de l'Air se téléportait donc dans une demi-colonne tranchée
    # net, signalé par l'utilisateur. La colonne voisine, celle AVEC la
    # silhouette, commence à 965 : on s'arrête juste avant.
    "air":     ("mage_wind.png",    (804, 714, 962, 968)),   # colonne de plumes
}

## Hauteur commune, en pixels. Les colonnes vont du simple au double d'une
## planche à l'autre ; sans cadre commun, le mage de Terre se téléporterait dans
## une colonne deux fois plus haute que celle du mage de l'Eau.
FRAME_HEIGHT = 128


def main() -> None:
    for cid, (sheet, box) in WARPS.items():
        path = SOURCE / sheet
        if not path.exists():
            print(f"  ! {sheet} introuvable")
            continue
        with Image.open(path) as image:
            crop = image.convert("RGBA").crop(box)
        # On recadre sur le contenu réel : les boîtes relevées à l'œil laissent
        # toujours un peu de vide, et ce vide décalerait l'effet sur sa case.
        bounds = crop.getbbox()
        if bounds is not None:
            crop = crop.crop(bounds)
        scale = FRAME_HEIGHT / float(crop.height)
        size = (max(1, int(round(crop.width * scale))), FRAME_HEIGHT)
        out_dir = OUT / cid
        out_dir.mkdir(parents=True, exist_ok=True)
        crop.resize(size, Image.LANCZOS).save(out_dir / "warp.png")
        print(f"{cid:8s} {sheet:18s} {box} -> {size}")


if __name__ == "__main__":
    main()
