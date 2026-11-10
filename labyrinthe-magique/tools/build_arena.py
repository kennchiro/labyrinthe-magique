"""Le COLISÉE de l'arène : découpe les planches de `docs/prompts/arene/` vers `assets/arena/`.

    tools/.venv/bin/python tools/build_arena.py
    godot --headless --path . --import        # OBLIGATOIRE ensuite

Quatre planches, quatre découpes :

- le SOL (`terrain/arene_sol.png`) devient une plaque raccordable, par le même `seamless` que les
  dix stages, dans `assets/tiles/arena/floor_sheet.png`. Les MURS (`terrain/arene_mur.png`) passent par
  `build_terrain.build_walls`, comme ceux des stages ; sans leur planche, on prend ceux des Ruines
  Anciennes ;
- la GEMME (`decor/arene_gemme.png`, 4 x 2) : la rangée du haut montre la gemme SUR son socle, celle du
  bas le socle SEUL — et non la gemme seule que demandait le prompt. On en tire quand même une gemme
  qui flotte : on la coupe au ras du socle de la rangée du bas, case par case. Les huit images sont
  recadrées sur la MÊME boîte, pour que socle et gemme tombent l'un sur l'autre en jeu ;
- les DÉCORS (`decor/arene_decor.png`, 4 x 3), nommés d'après ce que chaque case MONTRE : le générateur
  n'a pas suivi l'ordre du prompt, et il a dessiné une haie et un muret qu'on ne lui demandait pas ;
- le FOND (`interface/arene_fond.png`), réduit pour l'écran de préparation.

Le détourage du magenta est celui des props de stage (`build_terrain.keyed`) : il n'efface que le fond
qui touche le bord, et laisse les cristaux bleus et les runes.
"""

from pathlib import Path
import json
import shutil
import sys
import tempfile

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
import build_terrain  # noqa: E402
from build_terrain import FLOOR_SIDE, keyed, seamless  # noqa: E402

SOURCE = Path("assets/peso&cover")
OUT = Path("assets/arena")
TILES = Path("assets/tiles/arena")
## Les murs empruntés quand `arene_mur.png` manque, et les haies de repli dans tous les cas.
WALLS_FROM = Path("assets/tiles/stage_8")

## Ce que montre chaque case de la planche de décors, de gauche à droite puis de haut en bas.
DECOR_NAMES = [
	"pilier", "pilier_brise", "brasero_feu", "brasero_bleu",
	"haie", "muret", "statue", "boucliers",
	"etendard_bleu", "etendard_rouge", "tonneaux", "cristal",
]
DECOR_SIDE = 192
## Les quatre états de la gemme, dans l'ordre des colonnes (`ArenaHeart`).
GEM_STATES = ["libre", "bleus", "rouges", "disputee"]
GEM_SIDE = 192
## La gemme est coupée un peu SOUS le haut du socle : sa pointe plonge dans le trou du socle, et la
## couper pile au bord laissait une gemme à fond plat qui flottait au-dessus d'un vide.
GEM_DIP = 0.04
BACKDROP_WIDTH = 1600


def cells(sheet: Image.Image, columns: int, rows: int) -> list:
	width, height = sheet.size
	out = []
	for r in range(rows):
		for c in range(columns):
			box = (round(c * width / columns), round(r * height / rows),
				round((c + 1) * width / columns), round((r + 1) * height / rows))
			out.append(sheet.crop(box))
	return out


def alpha_box(image: Image.Image) -> tuple | None:
	alpha = np.asarray(image)[..., 3] > 24
	if not alpha.any():
		return None
	rows = np.where(alpha.any(axis=1))[0]
	cols = np.where(alpha.any(axis=0))[0]
	return int(cols[0]), int(rows[0]), int(cols[-1]) + 1, int(rows[-1]) + 1


def union(boxes: list) -> tuple:
	boxes = [b for b in boxes if b is not None]
	return (min(b[0] for b in boxes), min(b[1] for b in boxes),
		max(b[2] for b in boxes), max(b[3] for b in boxes))


def fit(image: Image.Image, side: int) -> Image.Image:
	scale = side / max(image.size)
	if scale >= 1.0:
		return image
	return image.resize((max(1, round(image.width * scale)), max(1, round(image.height * scale))), Image.LANCZOS)


def build_floor() -> str:
	with Image.open(SOURCE / "terrain/arene_sol.png") as image:
		sheet = image.convert("RGB")
	TILES.mkdir(parents=True, exist_ok=True)
	seamless(sheet).resize((FLOOR_SIDE, FLOOR_SIDE), Image.LANCZOS).save(TILES / "floor_sheet.png")
	for name in ["hedge_sheet.png", "hedge_top.png", "hedge_shadow.png"]:
		if (WALLS_FROM / name).exists():
			shutil.copyfile(WALLS_FROM / name, TILES / name)
	wall_path = SOURCE / "terrain/arene_mur.png"
	if not wall_path.exists():
		for name in ["wall_atlas.png", "wall.json"]:
			shutil.copyfile(WALLS_FROM / name, TILES / name)
		return f"sol {FLOOR_SIDE}x{FLOOR_SIDE}, murs de {WALLS_FROM.name} (pas de arene_mur.png)"
	# LES MURS DU COLISÉE passent par le MÊME outil que ceux des stages : il ne garde que la croix et les
	# deux barres de la planche, et fabrique les seize pièces d'après elles. Il écrit dans `stage_<N>` :
	# on lui prête un dossier de travail, puis on rapatrie l'atlas — et le contraste sol/mur, qui se règle
	# sur les deux ensemble.
	with Image.open(wall_path) as image:
		wall_sheet = image.convert("RGB")
	with tempfile.TemporaryDirectory() as work:
		build_terrain.TILES = Path(work)
		stage_dir = Path(work) / "stage_0"
		stage_dir.mkdir()
		shutil.copyfile(TILES / "floor_sheet.png", stage_dir / "floor_sheet.png")
		walls = build_terrain.build_walls(0, wall_sheet)
		contrast = build_terrain.enforce_contrast(0)
		for name in ["wall_atlas.png", "wall.json", "floor_sheet.png"]:
			shutil.copyfile(stage_dir / name, TILES / name)
	meta = json.loads((TILES / "wall.json").read_text(encoding="utf-8"))
	meta["source"] = wall_path.name
	(TILES / "wall.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
	return f"sol {FLOOR_SIDE}x{FLOOR_SIDE}, {walls}, {contrast or 'contraste ok'}"


def build_gem() -> str:
	with Image.open(SOURCE / "decor/arene_gemme.png") as image:
		sheet = image.convert("RGB")
	parts = [keyed(cell, crop=False) for cell in cells(sheet, 4, 2)]
	if any(p is None for p in parts):
		raise SystemExit("gemme : une case est vide après détourage")
	# ⚠️ Le socle seul de la rangée du bas n'est PAS à la même hauteur dans sa case que celui de la
	# rangée du haut (mesuré : 80 px plus haut). On le RECALE sur celui du haut — même bas, même centre —
	# et c'est lui qu'on garde : son trou est vide, la gemme peut en sortir. La gemme, elle, est la case
	# du haut AU-DESSUS du rebord du socle recalé ; sa pointe, sous le rebord, passe devant le trou.
	frame = union([alpha_box(p) for p in parts[:4]])
	out = OUT / "gemme"
	out.mkdir(parents=True, exist_ok=True)
	meta = {"states": GEM_STATES}
	scale = GEM_SIDE / max(frame[2] - frame[0], frame[3] - frame[1])
	for i, state in enumerate(GEM_STATES):
		whole = np.asarray(parts[i]).copy()
		above = alpha_box(parts[i])
		lone_part = parts[4 + (0 if i == 3 else i)]
		lone = alpha_box(lone_part)
		dx = (above[0] + above[2]) // 2 - (lone[0] + lone[2]) // 2
		dy = above[3] - lone[3]
		socle = Image.new("RGBA", parts[i].size, (0, 0, 0, 0))
		socle.paste(lone_part, (dx, dy), lone_part)
		rim = lone[1] + dy
		cut = rim + round((lone[3] - lone[1]) * GEM_DIP * 6.0)
		gem = whole.copy()
		gem[cut:, :, 3] = 0
		for name, piece in [("gemme", Image.fromarray(gem, "RGBA")), ("socle", socle)]:
			piece = piece.crop(frame)
			size = (round(piece.width * scale), round(piece.height * scale))
			piece.resize(size, Image.LANCZOS).save(out / f"{name}_{state}.png")
		meta["size"] = [round((frame[2] - frame[0]) * scale), round((frame[3] - frame[1]) * scale)]
		meta["socle_top"] = round((rim - frame[1]) / (frame[3] - frame[1]), 3)
	ring = parts[7].crop(alpha_box(parts[7]))
	fit(ring, 256).save(out / "anneau.png")
	(out / "gemme.json").write_text(json.dumps(meta, indent=2) + "\n")
	return f"gemme {len(GEM_STATES)} états, {meta['size'][0]}x{meta['size'][1]}, socle à {meta['socle_top']}"


def build_decor() -> str:
	with Image.open(SOURCE / "decor/arene_decor.png") as image:
		sheet = image.convert("RGB")
	out = OUT / "decor"
	out.mkdir(parents=True, exist_ok=True)
	written = 0
	for name, cell in zip(DECOR_NAMES, cells(sheet, 4, 3)):
		piece = keyed(cell)
		if piece is None:
			print(f"  décor {name} : case vide")
			continue
		fit(piece, DECOR_SIDE).save(out / f"{name}.png")
		written += 1
	return f"décor {written}/{len(DECOR_NAMES)}"


def build_backdrop() -> str:
	with Image.open(SOURCE / "interface/arene_fond.png") as image:
		backdrop = image.convert("RGB")
	OUT.mkdir(parents=True, exist_ok=True)
	height = round(backdrop.height * BACKDROP_WIDTH / backdrop.width)
	backdrop.resize((BACKDROP_WIDTH, height), Image.LANCZOS).save(OUT / "fond.jpg", quality=88)
	return f"fond {BACKDROP_WIDTH}x{height}"


def main() -> None:
	for step in [build_floor, build_gem, build_decor, build_backdrop]:
		print(f"  {step.__name__:16} {step()}")


if __name__ == "__main__":
	main()
