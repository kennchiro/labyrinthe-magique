#!/usr/bin/env python3
"""Découpe les pièces du Dragon des Abysses : boule de magma, écaille, gueule et silhouette.

Le jeu les dessine à part du corps : la boule du Crachat en vol, les éclats des Écailles,
la gueule de la Morsure, et le dragon vu de dessus que l'Ombre du Dragon noircit et agrandit.

    tools/.venv/bin/python tools/build_dragon_pieces.py
"""

from pathlib import Path

from PIL import Image

from build_enemies import demagenta, keyed

SOURCE = Path("assets/peso&cover/sorts/dragon_pieces.png")
OUT = Path("assets/characters/dragon/pieces")
## Relevé case par case sur la planche, dans l'ordre de lecture.
NAMES = ["magma", "ecaille", "gueule", "silhouette"]
COLUMNS = 2
ROWS = 2
## Le plus grand côté sur le disque. La silhouette couvre l'écran : elle garde plus de pixels.
LONGEST = {"silhouette": 512}
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
