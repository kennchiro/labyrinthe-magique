#!/usr/bin/env python3
"""Le Jugement des quatre — l'ultime du Sorcier Suprême.

    tools/.venv/bin/python tools/build_jugement.py     # DEPUIS LA RACINE

Découpe deux planches d'`assets/peso&cover/sorts/` vers
`assets/characters/supreme/` :

    meteore_supreme.png       (3 x 4)  ->  jugement_meteore.png       12 images
    jugement_mage.png         (4 x 2)  ->  jugement_impact.png          8 images
    jugement_incantation.png  (4 x 4)  ->  jugement_incantation.png    16 images

TROIS BANDES, TROIS RÔLES ET TROIS CADENCES

La MÉTÉORE tourne sur elle-même pendant sa chute. Elle traverse l'écran en moins
d'une seconde, et c'est le seul moment où on la voit : d'où douze images plutôt
que six, et une cadence rapide. Une boule à quatre images tourne comme une roue
de charrue.

L'INCANTATION s'ouvre une fois et se referme. Elle n'a pas à boucler — sa
dernière image est presque vide, exprès, pour que rien ne reste figé au-dessus du
mage pendant que les météores tombent.

⚠️ SA DURÉE EST UNE RÈGLE DE JEU, pas un réglage d'affichage : le ciel ne répond
qu'une fois le geste fini (`rain_delay`, dans le catalogue). Les deux nombres
doivent coïncider, et ce script le VÉRIFIE plutôt que de l'espérer — changer la
cadence ici sans toucher au catalogue laisserait un blanc, ou ferait tomber la
première pierre pendant que le mage lève encore les bras.

Le détourage est celui des sceaux : le magenta s'efface partout, y compris
enclavé — le cœur de la météore et l'œil de la déchirure sont cerclés de matière,
et le fond qu'on aperçoit entre les quartiers n'est atteignable par aucun bord.
"""

from pathlib import Path
import sys
import json

sys.path.insert(0, str(Path(__file__).resolve().parent))

from PIL import Image
from build_sceaux import keyed, centred

SOURCE = Path("assets/peso&cover/sorts")
OUT = Path("assets/characters/supreme")

## (planche, colonnes, rangées, côté de case, cadence, nom de sortie)
##
## La météore est plus finement échantillonnée que l'incantation : elle est
## dessinée petite à l'écran mais elle tombe VITE, et c'est sur elle que l'œil
## se pose. L'incantation, elle, est large et lente.
SHEETS = [
    {"file": "meteore_supreme.png", "columns": 3, "rows": 4,
     "cell": 256, "fps": 18.0, "out": "jugement_meteore"},
    # ⚠️ CETTE PLANCHE A CHANGÉ DE RÔLE. Demandée comme l'incantation du mage,
    # elle a été livrée en EXPLOSION vue de dessus — un cratère de lumière qui
    # s'ouvre et retombe. Superposée au mage, elle ne racontait rien ; posée sur
    # un ennemi au moment où la météore le touche, elle est exactement ce qu'il
    # fallait. On ne l'a donc pas jetée, on l'a déplacée. L'incantation, elle,
    # est redemandée ailleurs (`docs/prompts/sorts/jugement_incantation.md`).
    {"file": "jugement_mage.png", "columns": 4, "rows": 2,
     "cell": 320, "fps": 14.0, "out": "jugement_impact", "split": True},
    # LE GESTE. Seize images pour une montée lente : les quatre éléments
    # orbitent au sol autour du mage, décollent, et quittent le cadre par le
    # haut. C'est ce départ vers le ciel que les météores viennent conclure.
    {"file": "jugement_incantation.png", "columns": 4, "rows": 4,
     "cell": 320, "fps": 11.0, "out": "jugement_incantation",
     "delay_for": "supreme_judgement"},
]

## Le catalogue, lu pour contrôler l'accord entre le geste et le ciel.
CATALOG = Path("src/characters/character_catalog.gd")


def build(entry: dict) -> str:
    path = SOURCE / entry["file"]
    if not path.exists():
        return f"{entry['file']} introuvable"
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
        # `ring=False` : ni la météore ni la déchirure ne sont des anneaux
        # centrés — la première traîne vers le haut-gauche, la seconde déborde
        # vers le bas. La règle du « bas de la case » les amputerait.
        strip.alpha_composite(centred(keyed(sheet.crop(box)), side),
                              (number * side, 0))
    strip.save(OUT / f"{entry['out']}.png")
    # `DrawnBurst` veut des textures SÉPARÉES, pas une bande : il change de
    # `body.texture` d'une image à l'autre. On écrit donc les deux — la bande
    # pour ce qui s'anime en `hframes`, les images pour ce qui s'anime en Godot.
    if entry.get("split", False):
        for number in range(total):
            strip.crop((number * side, 0, (number + 1) * side, side)).save(
                OUT / f"{entry['out']}_{number}.png")
    (OUT / f"{entry['out']}.json").write_text(json.dumps({
        "frames": total, "fps": entry["fps"], "cell": [side, side],
        "source": entry["file"],
    }, indent=2), encoding="utf-8")
    note = f"{entry['out']} {total} images à {entry['fps']:.0f} img/s"
    if "delay_for" in entry:
        note += " · " + check_delay(entry, total / entry["fps"])
    return note


def check_delay(entry: dict, span: float) -> str:
    """L'attente du catalogue tient-elle la durée réelle de la bande ?

    Un écart n'est pas cosmétique : trop court, la première météore tombe
    pendant l'incantation ; trop long, le ciel reste vide après le geste. On le
    dit ici, au découpage, plutôt que de le découvrir à l'œil en jeu.
    """
    if not CATALOG.exists():
        return f"{span:.2f} s (catalogue introuvable)"
    text = CATALOG.read_text(encoding="utf-8")
    head = text.find(f'"id": "{entry["delay_for"]}"')
    mark = text.find('"rain_delay":', head) if head >= 0 else -1
    if mark < 0:
        return f"{span:.2f} s — ⚠️ pas de rain_delay pour {entry['delay_for']}"
    declared = float(text[mark + 13:text.find(",", mark)].strip())
    if abs(declared - span) > 0.05:
        return (f"{span:.2f} s — ⚠️ le catalogue attend {declared:.2f} s, "
                "le ciel et le geste ne sont plus d'accord")
    return f"{span:.2f} s, accordé au catalogue"


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    print(" · ".join(build(entry) for entry in SHEETS))


if __name__ == "__main__":
    main()
