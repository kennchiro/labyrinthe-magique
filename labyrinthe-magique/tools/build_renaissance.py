#!/usr/bin/env python3
"""Renaissance — l'éclat d'exaltation du Sorcier Suprême.

    tools/.venv/bin/python tools/build_renaissance.py     # DEPUIS LA RACINE

Découpe une planche d'`assets/peso&cover/sorts/` vers
`assets/characters/supreme/` :

    supreme_renaissance.png (4 x 2)  ->  renaissance_aura.png + .json  8 images

UNE PLANCHE, DEUX TEMPS — ET C'EST LÀ QUE TOUT SE JOUE

La planche a été dessinée comme un JAILLISSEMENT en un seul temps : le cercle de
runes s'allume, les quatre rubans montent en colonne, puis tout retombe. Sa
dernière case est presque vide, exprès.

On lui demande maintenant de tenir TRENTE SECONDES, comme une charge de ki. Une
telle bande ne peut pas boucler telle quelle : à chaque tour on repasserait par
sa case vide, et l'aura s'éteindrait une fois par seconde.

D'où le champ `loop`, et c'est le cœur de cet outil :

    cases 0 à 7   jouées UNE fois       -> l'activation, le jaillissement
    cases 3 à 5   bouclées ensuite      -> l'aura, tant que dure le bonus

Les cases 3 à 5 sont les trois où la colonne est à pleine puissance. Enchaînées
en rond, elles scintillent sans jamais retomber — ce qui est précisément
l'aspect d'une aura de charge. Les cases 0-2 (l'allumage) et 6-7 (la retombée)
n'appartiennent qu'à l'activation.

⚠️ Ces bornes sont écrites DANS LE DESCRIPTEUR, jamais dans le moteur. Redessiner
la planche avec dix images ne demandera que de corriger ce couple de nombres.

Le détourage est celui des sceaux : le magenta s'efface partout, y compris
enclavé — le centre de la planche est un trou par lequel on doit voir le mage.
"""

from pathlib import Path
import sys
import json

sys.path.insert(0, str(Path(__file__).resolve().parent))

from PIL import Image
from build_sceaux import keyed, centred

SOURCE = Path("assets/peso&cover/sorts")
OUT = Path("assets/characters/supreme")

## Neuf images par seconde pour huit images : l'éclat dure 0,89 s.
##
## Ni plus lent ni plus rapide, et pour une raison de jeu : c'est le temps qu'il
## faut pour comprendre qu'on vient de changer d'état, avant que l'aura ne prenne
## le relais. Plus long, on attend ; plus court, on ne l'a pas vu.
SHEET = {"file": "supreme_renaissance.png", "columns": 4, "rows": 2,
         "cell": 320, "fps": 9.0, "out": "renaissance_aura", "loop": [3, 5]}


def build(entry: dict) -> str:
    path = SOURCE / entry["file"]
    if not path.exists():
        return f"{entry['file']} introuvable — rien à découper"
    with Image.open(path) as image:
        sheet = image.convert("RGB")
    width, height = sheet.size
    cell_w, cell_h = width / entry["columns"], height / entry["rows"]
    total = entry["columns"] * entry["rows"]
    side = entry["cell"]

    strip = Image.new("RGBA", (side * total, side), (0, 0, 0, 0))
    for number in range(total):
        column, row = number % entry["columns"], number // entry["columns"]
        box = (int(column * cell_w), int(row * cell_h),
               int((column + 1) * cell_w), int((row + 1) * cell_h))
        # `ring=False` : l'éclat monte le long du corps, il n'est pas posé au
        # sol. La règle du « bas de la case » l'amputerait par le haut.
        strip.alpha_composite(centred(keyed(sheet.crop(box)), side),
                              (number * side, 0))
    strip.save(OUT / f"{entry['out']}.png")
    first, last = entry["loop"]
    (OUT / f"{entry['out']}.json").write_text(json.dumps({
        "frames": total, "fps": entry["fps"], "cell": [side, side],
        "loop": [first, last], "source": entry["file"],
    }, indent=2), encoding="utf-8")
    return (f"{entry['out']} {total} images à {entry['fps']:.0f} img/s "
            f"({total / entry['fps']:.2f} s d'activation, "
            f"puis boucle sur {first}-{last})")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    print(build(SHEET))


if __name__ == "__main__":
    main()
