#!/usr/bin/env python3
"""Le terrain de chaque stage, teinté d'après sa planche d'ambiance.

    tools/.venv/bin/python tools/build_stage_tiles.py     # DEPUIS LA RACINE

Ce ne sont PAS des tuiles découpées de la planche, et c'est un choix : essayé
d'abord, il donnait de la bouillie. Le plus grand carré qu'on puisse inscrire
dans un mur d'une case de large fait quelques pixels — agrandi à 96, il ne reste
qu'un dégradé flou. Les tuiles du jeu, elles, sont dessinées pour être répétées.

On garde donc leur DESSIN et on leur prend la COULEUR du biome : la luminance
de la tuile de base module la teinte du stage. L'herbe reste de l'herbe, avec
son grain et son ombre, mais elle devient sable aux Dunes et glace aux
Montagnes Glacées.

Les couples de couleurs sont ÉCRITS À LA MAIN, relevés sur l'aperçu de
labyrinthe de chaque planche (le petit labyrinthe dessiné en haut à gauche, qui
montre le sol et les murs du stage). Une classification automatique a été
essayée — « les murs sont fins, le sol est large » — et elle se trompait dès le
stage 2, dont l'aperçu contient DEUX terrains, le sable et la roche électrique.
Neuf couples relevés à l'œil valent mieux qu'une règle qui a l'air générale et
ne l'est pas.

⚠️ Le stage 9 n'a pas de planche : il garde le terrain par défaut.
"""

from pathlib import Path
import numpy as np
from PIL import Image

TILES = Path("assets/tiles")
BASE = ["floor_sheet.png", "hedge_sheet.png", "hedge_top.png", "hedge_shadow.png"]

## (sol, mur) par stage, en RGB. Relevés sur l'aperçu de la planche.
## Le stage 9 est à part : sa planche fournit de VRAIES tuiles dessinées
## (« Sol de Base » et les blocs de muraille) — voir DRAWN_TILES. Sa palette ne
## sert qu'au chapeau et à l'ombre de haie, que la planche ne fournit pas.
PALETTES = {
    9:  ((58, 66, 54),   (74, 92, 62)),      # sanctuaire : mousse sombre, pierre moussue
    1:  ((80, 115, 16),  (25, 70, 24)),      # forêt : terre herbeuse, haie sombre
    2:  ((62, 43, 94),   (76, 96, 218)),     # canyon : roche violette, éclair bleu
    3:  ((165, 91, 38),  (249, 181, 81)),    # dunes : sable brûlé, brique claire
    4:  ((160, 89, 57),  (239, 187, 108)),   # rivages : sable corail, pierre blonde
    5:  ((31, 26, 110),  (183, 123, 239)),   # cavernes : bleu profond, cristal violet
    6:  ((75, 134, 186), (204, 231, 250)),   # montagnes : glace bleue, neige
    7:  ((81, 96, 19),   (26, 44, 11)),      # bois d'épine : olive, ronce noire
    8:  ((107, 112, 49), (208, 194, 133)),   # ruines : mousse, pierre pâle
    10: ((188, 150, 62), (227, 229, 205)),   # château : or, marbre
}

## Part de la teinte du biome dans le résultat. En dessous, les dix stages se
## ressemblent ; au-dessus, on perd le dessin de la tuile au profit d'un aplat.
STRENGTH = 0.82

## Écart de LUMINANCE minimal entre le sol et le mur, sur 255.
##
## C'est la règle du projet — « c'est le contraste de luminosité qui fait lire
## le chemin, pas la couleur » — et deux biomes la violaient : le Bois d'Épine,
## sombre sur sombre, et le Château du Ciel, or sur or. Leur labyrinthe devenait
## illisible alors que chaque couleur, prise seule, était juste.
##
## On écarte les deux luminances symétriquement plutôt que d'en corriger une :
## éclaircir seulement le mur ferait dériver le biome vers le pastel.
MIN_CONTRAST = 52.0


def luminance(colour: tuple) -> float:
    return 0.299 * colour[0] + 0.587 * colour[1] + 0.114 * colour[2]


def spread(floor: tuple, wall: tuple) -> tuple:
    """Écarte les deux couleurs jusqu'à ce que le chemin se lise."""
    gap = luminance(floor) - luminance(wall)
    missing = MIN_CONTRAST - abs(gap)
    if missing <= 0.0:
        return floor, wall
    # Le plus clair des deux monte, l'autre descend, chacun de la moitié du
    # manque. Le sens est celui que le décor a choisi : on ne l'inverse jamais.
    way = 1.0 if gap >= 0.0 else -1.0
    shift = missing * 0.5

    def moved(colour: tuple, direction: float) -> tuple:
        return tuple(int(min(255, max(0, value + direction * shift))) for value in colour)

    return moved(floor, way), moved(wall, -way)


def _rescaled(image: Image.Image, factor: float) -> Image.Image:
    pixels = np.asarray(image).astype(float) * max(0.1, factor)
    return Image.fromarray(np.clip(pixels, 0, 255).astype(np.uint8), "RGB")


def tinted(image: Image.Image, colour: tuple) -> Image.Image:
    """La tuile, repeinte à la couleur du biome, son grain conservé.

    On divise chaque pixel par la luminance MOYENNE de la tuile plutôt que par
    la sienne : c'est ce qui garde les écarts d'ombre et de lumière. Normaliser
    pixel par pixel rendrait un aplat parfaitement uniforme."""
    source = image.convert("RGBA")
    pixels = np.asarray(source).astype(float)
    rgb, alpha = pixels[..., :3], pixels[..., 3:]
    luma = rgb @ np.array([0.299, 0.587, 0.114])
    mean = max(1.0, float(luma[alpha[..., 0] > 0].mean()) if (alpha > 0).any() else luma.mean())
    factor = (luma / mean)[..., None]
    painted = np.clip(np.array(colour, dtype=float)[None, None, :] * factor, 0, 255)
    blended = painted * STRENGTH + rgb * (1.0 - STRENGTH)
    out = np.concatenate([np.clip(blended, 0, 255), alpha], axis=2).astype(np.uint8)
    return Image.fromarray(out, "RGBA")


## Tuiles dessinées du stage 9 : (source, boîte sol, boîte mur).
## Résisées en 96x96 — elles sont dessinées pour se répéter, contrairement aux
## découpes d'aperçu qui donnaient de la bouillie sur les autres stages.
DRAWN_TILES = {
    # Planche remplacée le 2026-08-24 par une vraie planche d'ambiance. Les deux
    # boîtes sont prises à l'INTÉRIEUR des panneaux étiquetés en bas de la
    # planche — « Sol de Stase » pour le sol, « Sel Rocheux » pour le mur — et
    # non sur les blocs de muraille du haut : ceux-là portent leur face 3D et
    # leurs arêtes, qui se répètent en rayures dès qu'on en fait une tuile.
    9: ("assets/stages/stage_9.png", (45, 630, 195, 760), (270, 630, 420, 760)),
}


def main() -> None:
    for index, palette in sorted(PALETTES.items()):
        floor, wall = spread(palette[0], palette[1])
        out_dir = TILES / f"stage_{index}"
        out_dir.mkdir(parents=True, exist_ok=True)
        for name in BASE:
            source = TILES / name
            if not source.exists():
                print(f"  ! {name} introuvable — lancer d'abord tools/build_assets.py")
                return
            # Le haut de haie prend la couleur du mur ÉCLAIRCIE : c'est sa
            # tranche au soleil, elle ne peut pas être aussi sombre que le corps.
            colour = floor if name == "floor_sheet.png" else wall
            if name == "hedge_top.png":
                colour = tuple(min(255, int(v * 1.35 + 30)) for v in wall)
            if name == "hedge_shadow.png":
                colour = tuple(int(v * 0.45) for v in wall)
            with Image.open(source) as image:
                tinted(image, colour).save(out_dir / name)
        note = "" if palette == (floor, wall) else "  (écartés pour le contraste)"
        if index in DRAWN_TILES:
            source, floor_box, wall_box = DRAWN_TILES[index]
            with Image.open(source) as sheet:
                rgb = sheet.convert("RGB")
                floor_tile = rgb.crop(floor_box).resize((96, 96), Image.LANCZOS)
                wall_tile = rgb.crop(wall_box).resize((96, 96), Image.LANCZOS)
            # La règle de lisibilité s'applique AUSSI aux tuiles dessinées :
            # sol et mur de cette planche sont deux pierres moussues presque de
            # même valeur, et le labyrinthe ne se lisait pas. On écarte leurs
            # luminances comme celles des palettes — le sol descend, le mur
            # monte, le dessin reste.
            floor_mean = luminance(tuple(
                np.asarray(floor_tile).reshape(-1, 3).mean(axis=0)))
            wall_mean = luminance(tuple(
                np.asarray(wall_tile).reshape(-1, 3).mean(axis=0)))
            missing = MIN_CONTRAST - abs(wall_mean - floor_mean)
            if missing > 0.0:
                way = 1.0 if wall_mean >= floor_mean else -1.0
                floor_tile = _rescaled(floor_tile,
                    (floor_mean - way * missing * 0.5) / max(1.0, floor_mean))
                wall_tile = _rescaled(wall_tile,
                    (wall_mean + way * missing * 0.5) / max(1.0, wall_mean))
            floor_tile.save(out_dir / "floor_sheet.png")
            wall_tile.save(out_dir / "hedge_sheet.png")
            note = "  (tuiles dessinées de la planche, luminances écartées)"
        print(f"stage {index:2d}  sol {floor}  mur {wall}{note}")


if __name__ == "__main__":
    main()
