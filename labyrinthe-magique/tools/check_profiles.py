#!/usr/bin/env python3
"""Planche de contrôle : TOUT ce qui est écrit en `left.png` regarde-t-il à gauche ?

    tools/.venv/bin/python tools/check_profiles.py [sortie.png]

POURQUOI CE SCRIPT EXISTE

Le 2026-08-24, sept des neuf créatures du bestiaire marchaient à RECULONS. Leur
rangée de profil est dessinée vers la droite sur ces planches, et
`build_bestiary.py` la lisait comme la gauche sur les neuf. Le défaut a vécu des
semaines, et AUCUN contrôle ne pouvait l'attraper :

  - les fichiers existent, leur bande fait bien `cellule x poses` ;
  - `check_characters.py` vérifie le CADRAGE, pas le sens du dessin ;
  - les tests headless ne chargent aucune texture ;
  - en jouant, on ne voit un monstre de profil que quelques secondes, et il faut
    savoir que le défaut existe pour le remarquer.

Il n'y a pas de mesure automatique honnête du « sens » d'un dessin : la gueule
d'un serpent, la cape d'un chevalier et la poussière d'un golem n'ont aucun
invariant commun. Ce script ne juge donc RIEN — il pose côte à côte la pose la
plus en foulée de chaque `left.png`, à taille lisible, et laisse l'œil trancher
en un coup d'œil. C'est le seul artefact qui aurait montré les sept d'un coup.

Les indices qui tranchent, dans l'ordre : l'œil ou la gueule ; la traînée du
coup, qui part DEVANT ; la poussière et la cape, qui restent DERRIÈRE.
"""

from pathlib import Path
import json
import sys

from PIL import Image, ImageDraw

FOLDERS = (Path("assets/enemies"), Path("assets/characters"))
## La pose la plus en foulée : à l'arrêt, beaucoup de créatures sont de face et
## ne disent rien de leur orientation.
POSE = "walk_3"
CELL = (310, 250)
COLUMNS = 5


def strips() -> list:
    found = []
    for folder in FOLDERS:
        if not folder.is_dir():
            continue
        for entry in sorted(folder.iterdir()):
            band = entry / "left.png"
            meta = entry / "frames.json"
            if band.exists() and meta.exists():
                found.append((entry.name, band, json.loads(meta.read_text())))
    return found


def main() -> None:
    out_path = Path(sys.argv[1] if len(sys.argv) > 1 else "/tmp/profils.png")
    found = strips()
    if not found:
        raise SystemExit("aucune bande trouvée — lancer depuis la racine du projet")

    width, height = CELL
    rows = (len(found) + COLUMNS - 1) // COLUMNS
    sheet = Image.new("RGB", (width * COLUMNS, (height + 26) * rows), (18, 18, 24))
    draw = ImageDraw.Draw(sheet)
    for index, (name, band, meta) in enumerate(found):
        cell_width = int(meta["cell"][0])
        pose = meta["poses"].index(POSE) if POSE in meta["poses"] else 0
        image = Image.open(band).convert("RGBA")
        crop = image.crop((cell_width * pose, 0, cell_width * (pose + 1), image.height))
        scale = min(width / crop.width, height / crop.height)
        crop = crop.resize((int(crop.width * scale), int(crop.height * scale)),
                           Image.LANCZOS)
        tile = Image.new("RGBA", CELL, (32, 32, 42, 255))
        tile.alpha_composite(crop, ((width - crop.width) // 2,
                                    (height - crop.height) // 2))
        x = (index % COLUMNS) * width
        y = (index // COLUMNS) * (height + 26)
        sheet.paste(tile.convert("RGB"), (x, y + 26))
        draw.text((x + 8, y + 7), f"{name} — left.png", fill=(255, 220, 90))
        # La flèche rappelle le sens ATTENDU : sans elle, on regarde une galerie
        # de monstres sans savoir ce qu'on est censé y chercher.
        draw.text((x + width - 34, y + 7), "<--", fill=(120, 220, 255))
        draw.rectangle([x, y + 26, x + width - 1, y + 26 + height - 1],
                       outline=(70, 70, 90))
    sheet.save(out_path)
    print(f"{len(found)} bandes -> {out_path}")
    print("Chaque dessin doit regarder vers la GAUCHE. Sinon : `profile` dans "
          "tools/build_bestiary.py, ou la table de tools/build_characters.py.")


if __name__ == "__main__":
    main()
