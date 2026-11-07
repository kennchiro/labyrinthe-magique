#!/usr/bin/env python3
"""Découpe les pièces du Croupier des Enfers : cartes, dé, pièce, jeton, bille et roulette.

Le jeu les dessine à part du corps : la carte qui vole, les cartes pièges et leurs figures,
les dés qui roulent, la pièce de Pile ou face, les jetons d'un coup de chance, et la roulette
de l'ultime, qui tourne au-dessus de la carte.

    tools/.venv/bin/python tools/build_croupier_pieces.py
"""

from pathlib import Path

from PIL import Image

from build_enemies import demagenta, keyed

SOURCE = Path("assets/peso&cover/sorts/croupier_pieces.png")
ROULETTE = Path("assets/peso&cover/sorts/croupier_roulette.png")
OUT = Path("assets/characters/croupier/pieces")
## Relevé case par case sur la planche, dans l'ordre de lecture.
NAMES = ["dos", "as_feu", "dame_glace", "roi_foudre", "de", "face", "pile", "jeton", "bille"]
COLUMNS = 3
ROWS = 3
## Le plus grand côté sur le disque. La roulette couvre l'écran : elle garde ses pixels.
LONGEST = 256
ROULETTE_LONGEST = 1024


def _cut(board: Image.Image, longest: int) -> Image.Image:
    piece = demagenta(keyed(board))
    piece = piece.crop(piece.getchannel("A").point(lambda a: 255 if a > 10 else 0).getbbox())
    ratio = longest / max(piece.size)
    return piece.resize((round(piece.width * ratio), round(piece.height * ratio)), Image.LANCZOS)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    with Image.open(SOURCE) as sheet:
        board = sheet.convert("RGB")
    width = board.width // COLUMNS
    height = board.height // ROWS
    for index, name in enumerate(NAMES):
        left = (index % COLUMNS) * width
        top = (index // COLUMNS) * height
        piece = _cut(board.crop((left, top, left + width, top + height)), LONGEST)
        piece.save(OUT / f"{name}.png")
        print(f"✅  {name:16s} {piece.width} x {piece.height}")
    with Image.open(ROULETTE) as wheel:
        piece = _cut(wheel.convert("RGB"), ROULETTE_LONGEST)
    piece.save(OUT / "roulette.png")
    print(f"✅  {'roulette':16s} {piece.width} x {piece.height}")


if __name__ == "__main__":
    main()
