#!/usr/bin/env python3
"""Les icônes de sorts, détourées du fond magenta de leur planche.

    tools/.venv/bin/python tools/build_skill_icons.py     # DEPUIS LA RACINE

La planche est générée sur commande avec un fond MAGENTA UNI (#FF00FF) plutôt
qu'en transparence : les modèles d'image tiennent mal l'alpha, alors qu'un aplat
magenta se détoure au pixel près — et le magenta n'existe dans aucune des
palettes du jeu, donc rien de légitime ne lui ressemble.

Le détourage se fait en TEINTE et non en distance RGB. Une icône de feu porte
des halos roses sur ses bords, très proches du magenta en distance brute : une
clé par distance les mangeait et grignotait les flammes. La teinte, elle, sépare
nettement le magenta (~300°) de l'orange et du rouge (~0-40°).

La grille est RÉGULIÈRE — trois colonnes, deux rangées, cases de 512 — parce que
c'est ce qui a été commandé. On ne détecte donc rien : on découpe, on détoure, et
on recadre chaque icône sur son contenu.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image
from scipy import ndimage

SOURCE = Path("assets/peso&cover/sorts")
OUT = Path("assets/icons")

## planche -> (personnage, noms des six icônes dans l'ordre de lecture)
## planche -> (personnage, identifiants des six sorts DANS L'ORDRE DE LECTURE)
##
## ⚠️ L'ordre est celui de la PLANCHE, pas celui du prompt. Le générateur ne
## respecte pas la liste qu'on lui donne : sur la planche de l'Eau, il a placé
## le geyser en troisième et le bouclier en quatrième, alors qu'ils étaient
## demandés en sixième et troisième. On relève donc ce que chaque case MONTRE,
## et on l'associe au sort correspondant — jamais l'inverse.
SHEETS = {
    "mage_fire_skills.png": ("fire", [
        "fire_bolt", "fire_ball", "fire_ground",
        "fire_aura", "fire_ember", "fire_nova",
    ]),
    # Relevé case par case : flèche d'eau · orbe tourbillonnante · colonne qui
    # jaillit // dôme protecteur · vortex sur cercle runique · silhouette d'eau.
    # Relevé case par case : éclair qui frappe · arc à trois nœuds · champ
    # circulaire au sol // nuage d'orage · silhouette qui court en foudre ·
    # nuages et pluie d'éclairs. La planche suit ici l'ordre demandé — ce qui
    # n'était vrai ni pour le Feu ni pour l'Eau : on vérifie quand même.
    "mage_thunder_skills.png": ("thunder", [
        "thunder_bolt", "thunder_chain", "thunder_field",
        "thunder_storm", "thunder_flash", "thunder_judgement",
    ]),
    # Relevé case par case : rocher lancé et sa traînée · rangée de pics qui
    # s'éloigne · coque de pierre au cristal // gerbe de cristaux verts ·
    # silhouette qui plonge dans le sol · sol éclaté de crevasses.
    "mage_earth_skills.png": ("earth", [
        "earth_rock", "earth_spikes", "earth_aegis",
        "earth_crystals", "earth_burrow", "earth_quake",
    ]),
    "mage_water_skills.png": ("water", [
        "water_jet", "water_wave", "water_geyser",
        "water_shield", "water_circle", "water_current",
    ]),
}

COLUMNS = 3
ROWS = 2

## Teinte du fond, en degrés, et tolérance autour.
KEY_HUE = 300.0
HUE_TOLERANCE = 26.0
## En dessous de cette saturation, un pixel est trop gris pour être du fond :
## c'est de la fumée ou un éclat blanc, qu'on garde.
MIN_SATURATION = 0.22
## Côté de l'icône finale. Généreux pour les écrans Retina, qui affichent tout
## en double : une source trop juste pique à l'écran sur un Mac.
ICON_SIZE = 256


def hue_and_saturation(pixels: np.ndarray) -> tuple:
    top = pixels.max(axis=2)
    bottom = pixels.min(axis=2)
    span = top - bottom
    red, green, blue = pixels[..., 0], pixels[..., 1], pixels[..., 2]

    hue = np.zeros_like(top)
    safe = span > 1e-6
    with np.errstate(invalid="ignore", divide="ignore"):
        is_red = safe & (top == red)
        is_green = safe & (top == green) & ~is_red
        is_blue = safe & ~is_red & ~is_green
        hue[is_red] = (60.0 * ((green - blue)[is_red] / span[is_red])) % 360.0
        hue[is_green] = 60.0 * ((blue - red)[is_green] / span[is_green]) + 120.0
        hue[is_blue] = 60.0 * ((red - green)[is_blue] / span[is_blue]) + 240.0
    saturation = np.where(top > 1e-6, span / np.maximum(top, 1e-6), 0.0)
    return hue, saturation


def keyed(cell: Image.Image) -> Image.Image | None:
    pixels = np.asarray(cell.convert("RGB")).astype(float) / 255.0
    hue, saturation = hue_and_saturation(pixels)
    distance = np.abs(((hue - KEY_HUE + 180.0) % 360.0) - 180.0)
    background = (distance < HUE_TOLERANCE) & (saturation > MIN_SATURATION)

    # TOUT le magenta part, y compris ENCLAVÉ. La première version ne retirait
    # que le fond relié au bord, par prudence — « un reflet magenta au cœur
    # d'une flamme appartient au dessin ». Mesuré : l'anneau de l'Aura ardente
    # gardait 10 % de pixels à (255, 11, 163), c'est-à-dire du fond pur vu à
    # travers les flammes. Aucune palette de feu ne contient de magenta : ce qui
    # en a la teinte est du fond, où qu'il se trouve.

    data = np.array(cell.convert("RGBA"))
    data[..., 3] = np.where(background, 0, 255)

    # DÉGORGEMENT PROGRESSIF — la partie délicate.
    #
    # Deux versions jetées avant celle-ci :
    #   1. ramener le bleu sous le vert sur TOUS les pixels. Sans effet sur le
    #      feu (une flamme orange a déjà b < g), désastreux sur l'eau dont le
    #      bleu est le canal dominant : les icônes viraient au turquoise ;
    #   2. la même chose, limitée aux pixels de teinte magenta. Mieux, mais le
    #      dôme du bouclier est TRANSLUCIDE : le fond se voit à travers, et ces
    #      pixels-là se faisaient repeindre en rouge sombre au lieu d'être
    #      effacés.
    #
    # La bonne mesure est la « magenta-ité » : ce qu'un pixel a de rouge ET de
    # bleu EN PLUS de son vert. Elle vaut 1 sur le fond pur, 0 sur un bleu d'eau
    # ou un orange de flamme, et prend une valeur intermédiaire sur ce qui est
    # MÉLANGÉ au fond — un bord estompé, une surface translucide.
    #
    # On s'en sert deux fois : pour rendre ces pixels d'autant plus
    # TRANSPARENTS qu'ils sont magenta (le fond vu à travers le verre disparaît
    # au lieu d'être recoloré), et pour retirer la dominante rose de ce qui
    # reste. Rien d'élémentaire n'y survit : c'est la même formule pour les huit
    # personnages.
    rgb = data[..., :3].astype(float)
    spill = np.clip(
        (np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1]) / 255.0, 0.0, 1.0)
    data[..., 3] = (data[..., 3].astype(float) * (1.0 - spill)).astype(np.uint8)
    # Le rouge et le bleu redescendent vers le vert à proportion du dégorgement.
    for channel in (0, 2):
        data[..., channel] = np.clip(
            rgb[..., channel] * (1.0 - spill) + rgb[..., 1] * spill, 0, 255
        ).astype(np.uint8)

    out = Image.fromarray(data, "RGBA")
    bounds = out.getbbox()
    return out.crop(bounds) if bounds else None


def fitted(icon: Image.Image) -> Image.Image:
    """Icône centrée dans un carré, à l'intérieur du CERCLE inscrit.

    Le pad tactile affiche des boutons RONDS : ce qui dépasse du cercle est
    coupé. On met donc l'icône à l'échelle sur sa diagonale et non sur son côté
    — sinon une icône large touche le bord du carré, donc sort du cercle.
    """
    span = max(icon.width, icon.height)
    inner = ICON_SIZE * 0.70          # côté du carré inscrit dans le cercle
    factor = inner / float(span)
    scaled = icon.resize((max(1, int(icon.width * factor)),
                          max(1, int(icon.height * factor))), Image.LANCZOS)
    canvas = Image.new("RGBA", (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))
    canvas.alpha_composite(scaled, ((ICON_SIZE - scaled.width) // 2,
                                    (ICON_SIZE - scaled.height) // 2))
    return canvas


def main() -> None:
    for sheet_name, (character, names) in SHEETS.items():
        path = SOURCE / sheet_name
        if not path.exists():
            print(f"  ! {sheet_name} introuvable")
            continue
        with Image.open(path) as raw:
            sheet = raw.convert("RGB")
        cell_w = sheet.width // COLUMNS
        cell_h = sheet.height // ROWS

        out_dir = OUT / character
        out_dir.mkdir(parents=True, exist_ok=True)
        written = []
        for index, name in enumerate(names):
            column, row = index % COLUMNS, index // COLUMNS
            box = (column * cell_w, row * cell_h, (column + 1) * cell_w, (row + 1) * cell_h)
            cut = keyed(sheet.crop(box))
            if cut is None:
                print(f"  ! {name} : rien après détourage")
                continue
            fitted(cut).save(out_dir / f"{name}.png")
            written.append(name)
            print(f"{character}/{name:12s} {cut.size} -> {ICON_SIZE}x{ICON_SIZE}")
        (out_dir / "icons.json").write_text(
            json.dumps({"icons": written, "size": ICON_SIZE}, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
