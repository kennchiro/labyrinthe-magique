#!/usr/bin/env python3
"""Vignettes des dix stages, découpées de `assets/stages/stage_N.png`.

Chaque planche de stage est un DOSSIER D'AMBIANCE, pas un atlas de jeu : un
aperçu de labyrinthe, un jeu de tuiles, des décors, des icônes, et — au milieu
du bas — une grande illustration encadrée. C'est cette illustration, et elle
seule, que le jeu utilise : elle est la seule partie de la planche qui dise
d'un coup d'œil « voici l'endroit », ce qu'un écran de sélection doit dire.

La boîte est ÉCRITE À LA MAIN, comme pour les portails et les repaires. La
détection automatique de gouttières ne donne rien ici : les panneaux se
touchent, il n'y a aucune ligne de fond uniforme entre eux. Une boîte commune
cadre huit planches sur neuf ; les deux exceptions sont notées ci-dessous.

    tools/.venv/bin/python tools/build_stage_art.py    # DEPUIS LA RACINE

⚠️ `stage_9.png` n'existe pas sur le disque. Sa vignette est un carton neutre,
à remplacer quand la planche arrivera.
"""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

SOURCE = Path("assets/stages")
OUT = Path("assets/stages/thumbs")

STAGE_COUNT = 10
# Bannière large : c'est le format de l'illustration source (près de 3:1).
# Un carré l'aurait ÉTIRÉE — mieux vaut une carte large qu'un paysage déformé.
THUMB = (512, 166)

# Fractions (x0, y0, x1, y1) de l'illustration dans la planche.
BOX = (0.457, 0.678, 0.843, 0.866)
## La planche 9 est arrivée APRÈS les autres, dans un autre format : un JPEG
## de tuiles sur damier, avec un panneau paysage — la vista aux aurores — en
## bas au centre. C'est elle qui fait la vignette.
OVERRIDES = {
    9: (0.5008, 0.6157, 0.7326, 0.7319),
    2: (0.573, 0.712, 0.838, 0.845),   # panneau décalé à droite et plus haut
    3: (0.457, 0.700, 0.843, 0.888),   # panneau descendu : la boîte commune
}                                       # ramassait la rangée d'icônes

NAMES = [
    "La Forêt", "Le Canyon de la Foudre", "Les Dunes de Feu",
    "Les Rivages Océaniques", "Les Cavernes de Cristal", "Les Montagnes Glacées",
    "Le Bois d'Épine", "Les Ruines Anciennes", "Le Sanctuaire Déchu",
    "Le Château du Ciel",
]


def placeholder(index: int, name: str) -> Image.Image:
    """Carton pour une planche absente.

    HACHURÉ, et pas simplement noir : un rectangle vide se lit comme un bug
    d'affichage, des hachures se lisent comme « rien ici pour l'instant ».
    Emprunter l'illustration d'un voisin donnerait un écran cohérent qui ment.
    """
    image = Image.new("RGB", THUMB, (20, 17, 34))
    draw = ImageDraw.Draw(image)
    for x in range(-THUMB[1], THUMB[0], 22):
        draw.line([(x, THUMB[1]), (x + THUMB[1], 0)], fill=(34, 29, 56), width=7)
    draw.rectangle([4, 4, THUMB[0] - 5, THUMB[1] - 5], outline=(78, 68, 124), width=3)

    font = None
    for candidate in ("/System/Library/Fonts/Supplemental/Futura.ttc",
                      "/System/Library/Fonts/Helvetica.ttc"):
        if Path(candidate).exists():
            font = ImageFont.truetype(candidate, 74)
            break
    label = str(index)
    if font is not None:
        box = draw.textbbox((0, 0), label, font=font)
        draw.text(((THUMB[0] - box[2]) / 2, (THUMB[1] - box[3]) / 2 - 8),
                  label, font=font, fill=(120, 108, 178))
    return image


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for index in range(1, STAGE_COUNT + 1):
        path = SOURCE / f"stage_{index}.png"
        if not path.exists():
            path = SOURCE / f"stage_{index}.jpeg"
        target = OUT / f"stage_{index}.png"
        if not path.exists():
            placeholder(index, NAMES[index - 1]).save(target)
            print(f"stage {index:2d}  carton neutre (planche absente)")
            continue
        with Image.open(path) as sheet:
            sheet = sheet.convert("RGB")
            width, height = sheet.size
            box = OVERRIDES.get(index, BOX)
            crop = sheet.crop((int(width * box[0]), int(height * box[1]),
                               int(width * box[2]), int(height * box[3])))
            crop.resize(THUMB, Image.LANCZOS).save(target)
        print(f"stage {index:2d}  {NAMES[index - 1]:26s} {crop.size} -> {THUMB}")


if __name__ == "__main__":
    main()
