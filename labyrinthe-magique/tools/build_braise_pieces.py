#!/usr/bin/env python3
"""Découpe les pièces du Roi de Braise : gantelets, plastrons et cages.

Le jeu les dessine à part du corps : elles flottent, volent et se referment seules.

    tools/.venv/bin/python tools/build_braise_pieces.py
"""

from pathlib import Path

from PIL import Image

from build_enemies import demagenta, keyed

SOURCE = Path("assets/peso&cover/sorts/braise_pieces.png")
OUT = Path("assets/characters/braise/pieces")
## Relevé case par case sur la planche, dans l'ordre de lecture.
NAMES = ["gant_ouvert", "gant_ferme", "plastron", "plastron_ouvert", "cage_ouverte", "cage_fermee"]
COLUMNS = 3
ROWS = 2
## Le plus grand côté sur le disque : une cage couvre deux cases, soit 256 points au Retina.
LONGEST = 256


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    with Image.open(SOURCE) as sheet:
        board = sheet.convert("RGB")
    width = board.width // COLUMNS
    height = board.height // ROWS
    for index, name in enumerate(NAMES):
        left = (index % COLUMNS) * width
        top = (index // COLUMNS) * height
        piece = demagenta(keyed(board.crop((left, top, left + width, top + height))))
        piece = piece.crop(piece.getchannel("A").point(lambda a: 255 if a > 10 else 0).getbbox())
        ratio = LONGEST / max(piece.size)
        piece = piece.resize((round(piece.width * ratio), round(piece.height * ratio)), Image.LANCZOS)
        piece.save(OUT / f"{name}.png")
        print(f"✅  {name:16s} {piece.width} x {piece.height}")


if __name__ == "__main__":
    main()
