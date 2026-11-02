#!/usr/bin/env python3
"""Découpe les quatre planches commandées de chacun des dix boss.

    tools/.venv/bin/python tools/build_bosses.py            # depuis la racine
    tools/.venv/bin/python tools/build_bosses.py boss_yeti  # un seul boss

La marche et l'attaque passent par le pipeline éprouvé de `build_enemies.py`.
Les planches de scène et de portée ont une grille explicite de 8 x 3 : elles
deviennent chacune trois bandes de huit cases transparentes, conservées à 256 px.
"""

from pathlib import Path
import json
import sys

from PIL import Image
import numpy as np
from scipy import ndimage

import build_enemies as animated

SOURCE = Path("assets/peso&cover/creatures")
OUT = Path("assets/enemies")
CELL = 256
COLUMNS = 8
ROWS = ("down", "up", "right")
## Un morceau au bord de la case, sous cette part du dessin, vient de la rangée voisine.
STRAY_SHARE = 0.03

BOSSES = {
    "boss_sylvain": "Le Sylvain Ancien",
    "boss_oiseau_tonnerre": "L'Oiseau-Tonnerre",
    "boss_scorpion": "Le Scorpion des Braises",
    "boss_behemoth": "Le Béhémoth des Abysses",
    "boss_araignee": "La Reine de Cristal",
    "boss_yeti": "Le Roi Yéti",
    "boss_mere_ronce": "La Mère-Ronce",
    "boss_idole": "L'Idole Éveillée",
    "boss_roi_dechu": "Le Roi Déchu",
    "boss_chimere": "La Chimère d'Or",
}

SPECIAL_SHEETS = {
    "scene": ("arrival", "ranged_attack", "death"),
    "portee": ("warning", "impact", "fade"),
}


def complaint(path: Path) -> str:
    if not path.exists():
        return f"{path.name} introuvable"
    with Image.open(path) as image:
        wanted = (CELL * COLUMNS, CELL * len(ROWS))
        if image.size != wanted and (abs(image.width - wanted[0]) > 4
                                     or abs(image.height - wanted[1]) > 4):
            return f"{path.name} fait {image.width}x{image.height}, attendu 2048x768"
    return ""


def without_strays(frame: Image.Image) -> Image.Image:
    """Efface ce qui vient d'une rangée voisine : un petit morceau collé au haut ou au bas
    de la case. Une corne ou un pied coupés restent, ils sont gros."""
    alpha = np.array(frame.getchannel("A")) > 40
    labels, count = ndimage.label(alpha, structure=np.ones((3, 3)))
    if count == 0:
        return frame
    sizes = ndimage.sum(alpha, labels, range(1, count + 1))
    edge = set(labels[0]) | set(labels[-1])
    out = np.array(frame)
    for index in range(1, count + 1):
        if index in edge and sizes[index - 1] < STRAY_SHARE * alpha.sum():
            out[labels == index, 3] = 0
    return Image.fromarray(out, "RGBA")


def body_of(strip_path: Path) -> tuple[float, float]:
    """(hauteur du corps, ligne des pieds) sur la dernière image de l'arrivée, qui rejoint
    la pose de marche : le jeu y cale toutes les poses de scène."""
    with Image.open(strip_path) as strip:
        last = strip.crop((CELL * (COLUMNS - 1), 0, CELL * COLUMNS, CELL))
    rows = np.where((np.array(last.getchannel("A")) > 40).any(axis=1))[0]
    return float(rows[-1] - rows[0] + 1), float(rows[-1] + 1)


def split_special(path: Path, folder: Path, labels: tuple[str, ...]) -> None:
    with Image.open(path) as source:
        sheet = source.convert("RGB")
        if sheet.size != (CELL * COLUMNS, CELL * len(ROWS)):
            sheet = sheet.resize((CELL * COLUMNS, CELL * len(ROWS)), Image.Resampling.LANCZOS)
        for row, label in enumerate(labels):
            strip = Image.new("RGBA", (CELL * COLUMNS, CELL), (0, 0, 0, 0))
            for column in range(COLUMNS):
                box = (column * CELL, row * CELL,
                       (column + 1) * CELL, (row + 1) * CELL)
                frame = without_strays(animated.keyed(sheet.crop(box)))
                strip.alpha_composite(frame, (column * CELL, 0))
            strip.save(folder / f"{label}.png")


def build(name: str) -> list[str]:
    folder = OUT / name
    entry = {
        "id": name,
        "name": BOSSES[name],
        "walks": True,
        "align_rows": True,
    }
    status = [animated.build(name, entry)]
    special_paths = {kind: SOURCE / f"{name}_{kind}.png"
                     for kind in SPECIAL_SHEETS}
    faults = [message for path in special_paths.values()
              if (message := complaint(path))]
    if faults:
        return status + faults

    folder.mkdir(parents=True, exist_ok=True)
    for kind, labels in SPECIAL_SHEETS.items():
        split_special(special_paths[kind], folder, labels)

    scene_body, scene_feet = body_of(folder / "arrival.png")
    (folder / "special_frames.json").write_text(json.dumps({
        "cell": [CELL, CELL],
        "columns": COLUMNS,
        "scene_body": scene_body,
        "scene_feet_y": scene_feet,
        "scene": list(SPECIAL_SHEETS["scene"]),
        "portee": list(SPECIAL_SHEETS["portee"]),
        "source": {kind: path.name for kind, path in special_paths.items()},
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    status.append(f"{name} : scène et portée découpées en bandes de 8 poses")
    return status


def main() -> None:
    wanted = sys.argv[1:]
    unknown = sorted(set(wanted) - BOSSES.keys())
    if unknown:
        raise SystemExit(f"boss inconnu(s) : {', '.join(unknown)}")
    names = wanted or list(BOSSES)
    for name in names:
        for line in build(name):
            print(line)


if __name__ == "__main__":
    main()
