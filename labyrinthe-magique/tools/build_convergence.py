#!/usr/bin/env python3
"""Convergence élémentaire — le sort 1 du Sorcier Suprême.

    tools/.venv/bin/python tools/build_convergence.py     # DEPUIS LA RACINE

Produit, dans `assets/characters/supreme/` :
    convergence_orb.png     une bande de 8 cases : 7 de CHARGE + 1 de VOL
    convergence_orb.json    combien de charge, à quelle cadence
    convergence_impact.png  l'éclat au but

LE SORT SE JOUE EN DEUX TEMPS, ET C'EST TOUT LE SUJET

Les neuf dessins livrés ne racontent pas la même chose :

    0 à 6   un noyau qui GROSSIT — les quatre éléments qui s'enroulent.
            C'est un CHARGEMENT : ça se joue sur place, devant le mage.
    7       une comète allongée. C'est le PROJECTILE, et lui seul voyage.
    8       l'éclat au but.

La première version les jouait tous les huit PENDANT le vol : le noyau
grossissait en traversant le couloir, et la comète n'apparaissait qu'au moment
d'arriver. On voyait un sort qui se prépare une fois parti — l'inverse de ce
qu'il raconte. `MagicOrb` tient donc maintenant la charge au point de départ,
puis part avec la seule frame 7.

⚠️ LA FRAME 7 EST DESSINÉE EN DIAGONALE. Mesuré : son axe principal est à 137°,
et sa tête — la partie dense et lumineuse — pointe vers le haut-droite. Le
moteur, lui, oriente le projectile par `sprite.rotation = direction.angle()`,
ce qui suppose un dessin pointant vers la DROITE. Sans redressement, la comète
partait de travers dans les quatre directions.

L'angle n'est PAS écrit en dur ici : il est MESURÉ à chaque passage (axe
principal de la masse lumineuse), puis le résultat est VÉRIFIÉ — si la tête
retombe à gauche, on ajoute un demi-tour. Un dessin 7 redessiné sous un autre
angle se redressera donc tout seul.
"""

from pathlib import Path
import json

import numpy as np
from PIL import Image

FOLDER = Path("assets/characters/supreme")
FRAMES = [FOLDER / f"convergence_{index}.png" for index in range(9)]

## Côté d'une case de la bande.
CELL = 384
## Part de la case occupée par les frames de CHARGE, puis par le PROJECTILE.
##
## La charge reste petite : elle se joue collée au mage, et une boule aussi
## large que la comète cacherait le personnage qui la lance. Le projectile, lui,
## prend toute la case — c'est le coup le plus lourd du Suprême, il doit peser à
## l'écran. Le rapport de un à deux est ce qui fait qu'on VOIT le lancement.
CHARGE_SHARE = 0.50
LAUNCH_SHARE = 1.00
## Cadence de la bande, en images par seconde. Lente : on doit avoir le temps de
## lire les quatre éléments qui s'assemblent.
FPS = 8.0


def principal_axis(image: Image.Image) -> tuple:
    """(angle de l'axe en degrés, tête vers le sens positif ?).

    L'axe est pondéré par l'opacité ET la luminosité : une comète a une traîne
    diffuse et une tête dense, et c'est la tête qui doit décider du sens. Une
    pondération par la seule opacité laisserait la longue traîne l'emporter."""
    data = np.asarray(image.convert("RGBA")).astype(np.float32)
    weight = (data[..., 3] / 255.0) * (data[..., :3].mean(axis=2) / 255.0)
    rows, columns = np.nonzero(weight > 0.06)
    if rows.size < 32:
        return 0.0, True
    mass = weight[rows, columns]
    cx = float((columns * mass).sum() / mass.sum())
    cy = float((rows * mass).sum() / mass.sum())
    dx, dy = columns - cx, rows - cy
    covariance = np.array([
        [(mass * dx * dx).sum(), (mass * dx * dy).sum()],
        [(mass * dx * dy).sum(), (mass * dy * dy).sum()],
    ]) / mass.sum()
    values, vectors = np.linalg.eigh(covariance)
    axis = vectors[:, int(np.argmax(values))]
    angle = float(np.degrees(np.arctan2(axis[1], axis[0])))
    # La tête est du côté le plus LUMINEUX en moyenne, pas le plus large : la
    # traîne est longue et pâle, la tête courte et vive.
    along = dx * axis[0] + dy * axis[1]
    ahead = float(mass[along > 0].mean()) if (along > 0).any() else 0.0
    behind = float(mass[along < 0].mean()) if (along < 0).any() else 0.0
    return angle, ahead >= behind


def pointing_right(image: Image.Image) -> Image.Image:
    """La comète redressée, tête vers la droite.

    On tourne selon la mesure, puis on REVÉRIFIE. La vérification n'est pas de
    la prudence gratuite : la convention de sens de rotation de PIL et celle
    d'un repère dont l'axe Y descend se contredisent une fois sur deux, et se
    tromper de signe met la comète tête en arrière — un défaut qu'on ne voit
    qu'en jouant, et seulement dans deux directions sur quatre."""
    angle, head_is_positive = principal_axis(image)
    heading = angle if head_is_positive else angle + 180.0
    turned = image.rotate(heading, resample=Image.BICUBIC, expand=True)
    check_angle, check_positive = principal_axis(turned)
    heading_after = check_angle if check_positive else check_angle + 180.0
    if abs(((heading_after + 180.0) % 360.0) - 180.0) > 90.0:
        turned = turned.rotate(180.0, resample=Image.BICUBIC, expand=True)
    return turned.crop(turned.getbbox())


def fitted(image: Image.Image, share: float) -> Image.Image:
    """L'image posée au centre d'une case, à la part de case demandée."""
    box = image.crop(image.getbbox()) if image.getbbox() else image
    target = int(CELL * share)
    scaled = box.copy()
    scaled.thumbnail((target, target), Image.LANCZOS)
    cell = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
    cell.alpha_composite(scaled, ((CELL - scaled.width) // 2,
                                  (CELL - scaled.height) // 2))
    return cell


def main() -> None:
    images = [Image.open(path).convert("RGBA") for path in FRAMES]

    cells = [fitted(image, CHARGE_SHARE) for image in images[:7]]
    launch = pointing_right(images[7])
    angle, _ = principal_axis(launch)
    cells.append(fitted(launch, LAUNCH_SHARE))

    strip = Image.new("RGBA", (CELL * len(cells), CELL), (0, 0, 0, 0))
    for index, cell in enumerate(cells):
        strip.alpha_composite(cell, (index * CELL, 0))
    strip.save(FOLDER / "convergence_orb.png")

    (FOLDER / "convergence_orb.json").write_text(json.dumps({
        "frames": len(cells),
        # Les sept premières sont la charge ; la huitième est le projectile.
        # Le moteur lit ces deux nombres plutôt que de les coder : rallonger la
        # charge d'une image ne doit demander qu'un dessin de plus.
        "charge_frames": 7,
        "fps": FPS,
        "cell": [CELL, CELL],
    }, indent=2), encoding="utf-8")

    impact = images[8].crop(images[8].getbbox())
    impact.thumbnail((512, 512), Image.LANCZOS)
    impact.save(FOLDER / "convergence_impact.png")

    print(f"charge 7 images à {FPS:.0f} img/s · projectile redressé "
          f"(axe résiduel {angle:+.1f}°) · bande {CELL * len(cells)}x{CELL}")


if __name__ == "__main__":
    main()
