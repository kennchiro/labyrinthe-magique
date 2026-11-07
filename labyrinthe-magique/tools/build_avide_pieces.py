#!/usr/bin/env python3
"""Découpe les pièces de l'Avide : la langue-fouet, le gouffre, la boule de bile et la grande gueule.

Le jeu les dessine à part du corps : la langue qu'il étire jusqu'à la cible, le gouffre qui s'ouvre
au sol, les boules de la Régurgitation, et la gueule de Dévorer et du Festin.

    tools/.venv/bin/python tools/build_avide_pieces.py
"""

from pathlib import Path

from PIL import Image

from build_enemies import demagenta, keyed

SOURCE = Path("assets/peso&cover/sorts/avide_pieces.png")
OUT = Path("assets/characters/avide/pieces")
## Relevé case par case sur la planche, dans l'ordre de lecture.
NAMES = ["langue", "gouffre", "bile", "gueule"]
COLUMNS = 2
ROWS = 2
## Le plus grand côté sur le disque. La langue s'étire et la gueule couvre l'écran : elles gardent leurs pixels.
LONGEST = {"langue": 512, "gueule": 512, "gouffre": 384}
DEFAULT_LONGEST = 256


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
        ratio = LONGEST.get(name, DEFAULT_LONGEST) / max(piece.size)
        piece = piece.resize((round(piece.width * ratio), round(piece.height * ratio)), Image.LANCZOS)
        piece.save(OUT / f"{name}.png")
        print(f"✅  {name:16s} {piece.width} x {piece.height}")


if __name__ == "__main__":
    main()
