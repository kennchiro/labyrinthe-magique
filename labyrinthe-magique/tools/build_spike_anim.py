#!/usr/bin/env python3
"""LES ANIMATIONS image par image, détourées de leur fond magenta.

    tools/.venv/bin/python tools/build_spike_anim.py     # DEPUIS LA RACINE

Deux planches à ce jour, commandées en grille STRICTE :
  · l'ÉRUPTION de la Terre — six images par rangée, deux rangées (cristal puis
    pierre), chaque gerbe grandissant depuis le bas au centre de sa case ;
  · la TORNADE de l'Air — huit images sur une rangée, un tour complet, la
    silhouette identique et seules les bandes qui tournent.

⚠️ LE POINT DÉLICAT EST L'ALIGNEMENT. Si l'on recadre chaque image sur son
contenu, la première (une simple fissure large et basse) et la quatrième (une
gerbe haute et étroite) n'ont ni la même taille ni le même centre : jouées à la
suite, les pics SAUTENT d'une image à l'autre. On calcule donc une boîte
COMMUNE à toute la rangée, et on y découpe les six. Le poids en pixels est un
peu plus lourd ; l'animation, elle, tient debout.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image

## planche -> (dossier de sortie, colonnes, rangées, préfixe, hauteur finale)
##
## ⚠️ La largeur d'une planche n'est pas toujours divisible par son nombre de
## colonnes (celle de la tornade fait 1774 pour huit images). On découpe donc
## par ARRONDI sur la largeur totale, jamais par une taille de case fixe : à un
## pixel près par colonne, l'écart s'accumule et la dernière image est décalée.
SHEETS = [
    ("assets/peso&cover/sorts/earth_spikes_anim.png", "earth", 6,
     ["crystal", "stone"], "spikes", 192),
    ("assets/peso&cover/sorts/tornado_spin.png", "air", 8,
     ["spin"], "tornado", 256),
    # Le Grand souffle : le CÔNE part vers la droite, pointe à gauche — c'est
    # cette pointe qu'on posera sur le mage — et l'ONDE reste concentrique.
    ("assets/peso&cover/sorts/wind_blast.png", "air", 6,
     ["cone", "burst"], "blast", 224,
     # ⚠️ CETTE PLANCHE N'EST PAS SUR SA GRILLE. Ses images GRANDISSENT — un
     # cône qui s'ouvre, une onde qui s'élargit — et le générateur les a
     # resserrées vers la gauche : les vraies séparations tombent 35 à 72 px
     # avant les lignes régulières. Découpées à la colonne, les images 2 à 5 du
     # cône étaient tranchées net à la verticale.
     #
     # Et chaque famille a son ANCRE, imposée par la façon dont le moteur la
     # pose (`src/fx/wind_blast.gd`) : l'onde est un Sprite2D CENTRÉ sur le
     # mage, le cône est décentré pour que son bord gauche tombe sur lui. Une
     # boîte commune calée sur la case ne suffit donc pas — le dessin doit être
     # calé sur SON centre, ou sur SA pointe.
     {"gutters": True, "anchor": {"burst": "centre", "cone": "pointe"}}),
    # LE CYCLONE : huit images d'un tour complet, étalées sur DEUX rangées. Ce
    # n'est donc pas « deux matières de quatre images » comme l'éruption de la
    # Terre — c'est une seule animation qui se lit ligne par ligne, d'où
    # `rangees_par_matiere`.
    #
    # Ancré sur sa BASE : c'est le pied de la colonne qui se pose sur la case du
    # labyrinthe, comme la pointe du cône du Grand souffle se pose sur le mage.
    # Un cyclone calé sur son centre s'enfoncerait dans le sol de la moitié de
    # sa hauteur.
    ("assets/peso&cover/sorts/cyclone_spin.png", "air", 4,
     ["spin"], "cyclone", 320,
     {"rangees_par_matiere": 2, "anchor": {"spin": "base"}}),
    # Sa décharge : amorce, éclair, impact au sol, retombée. Même ancre — tout
    # se joue au sol, et l'éclair TOMBE dessus.
    ("assets/peso&cover/sorts/cyclone_bolt.png", "air", 4,
     ["bolt"], "cyclonebolt", 256,
     {"gutters": True, "anchor": {"bolt": "base"}}),
    # LE PORTAIL DU LABYRINTHE : huit images d'un tour, une seule couleur.
    #
    # Il remplace huit planches de six ÉTATS dessinés — repos, ouverture,
    # ouvert, actif, saut, fermeture — soit quarante-huit images pour huit. Les
    # états sont maintenant des réglages de cette boucle unique (vitesse,
    # taille, éclat) : c'est ce qui les rend enfin cohérents entre eux.
    #
    # Ancré sur son CENTRE : le moteur pose ce sprite centré sur la case du
    # labyrinthe, donc ce qui n'est pas au milieu de l'image n'est pas au milieu
    # de la case.
    ("assets/peso&cover/sorts/portail_unique.png", "", 4,
     ["tour"], "portail", 192,
     {"racine": "assets/portals", "rangees_par_matiere": 2,
      "anchor": {"tour": "centre"}}),
]

## Détourage : même clé de teinte que les vignettes de sorts. Le magenta
## n'appartient à aucune palette du jeu, donc ce qui en a la teinte est du fond.
KEY_HUE = 300.0
HUE_TOLERANCE = 26.0
MIN_SATURATION = 0.22
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


def keyed(cell: Image.Image) -> Image.Image:
    pixels = np.asarray(cell.convert("RGB")).astype(float) / 255.0
    hue, saturation = hue_and_saturation(pixels)
    distance = np.abs(((hue - KEY_HUE + 180.0) % 360.0) - 180.0)
    background = (distance < HUE_TOLERANCE) & (saturation > MIN_SATURATION)

    data = np.array(cell.convert("RGBA"))
    data[..., 3] = np.where(background, 0, 255)

    # Dégorgement : ce qu'un pixel a de rouge ET de bleu en plus de son vert est
    # du fond mélangé au dessin. On le rend transparent d'autant, et on ramène
    # ses canaux vers le vert. Même formule que pour les vignettes.
    rgb = data[..., :3].astype(float)
    spill = np.clip(
        (np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1]) / 255.0, 0.0, 1.0)
    data[..., 3] = (data[..., 3].astype(float) * (1.0 - spill)).astype(np.uint8)
    for channel in (0, 2):
        data[..., channel] = np.clip(
            rgb[..., channel] * (1.0 - spill) + rgb[..., 1] * spill, 0, 255
        ).astype(np.uint8)
    return Image.fromarray(data, "RGBA")


def row_cuts(band: np.ndarray, columns: int) -> list:
    """Les vraies séparations d'une rangée : ses gouttières les plus larges.

    On en cherche exactement `columns - 1`. Contrairement aux planches de mages,
    les images ne sont PAS également espacées ici — elles grandissent — donc la
    régularité ne peut pas servir de juge : c'est la largeur du vide qui tranche,
    et les gouttières parasites (à l'intérieur d'une onde qui s'ouvre) sont
    toutes bien plus fines que celles qui séparent deux images.
    """
    ink = (band > 20).any(axis=0)
    marks = np.nonzero(ink)[0]
    if marks.size < 2:
        return []
    gutters, x = [], int(marks[0])
    while x < marks[-1]:
        if ink[x]:
            x += 1
            continue
        start = x
        while x < marks[-1] and not ink[x]:
            x += 1
        gutters.append((start + (x - start) // 2, x - start))
    if len(gutters) < columns - 1:
        return []
    widest = sorted(gutters, key=lambda g: -g[1])[:columns - 1]
    return sorted(g[0] for g in widest)


def anchor_of(frame: Image.Image, mode: str) -> tuple:
    """Le point du dessin qui doit tomber au même endroit dans toutes les images."""
    alpha = np.asarray(frame)[..., 3]
    solid = alpha > 20
    if not solid.any():
        return (0, 0)
    columns = np.nonzero(solid.any(axis=0))[0]
    weights = alpha.astype(float)
    total = weights.sum()
    cy = int(round((weights.sum(axis=1) * np.arange(alpha.shape[0])).sum() / total))
    if mode == "pointe":
        # La POINTE du cône : sa colonne la plus à gauche. C'est elle qu'on pose
        # sur le mage, et c'est donc elle qui doit être immobile.
        return (int(columns[0]), cy)
    cx = int(round((weights.sum(axis=0) * np.arange(alpha.shape[1])).sum() / total))
    if mode == "base":
        # LE PIED de la colonne : sa ligne la plus basse, sur son axe des masses.
        # Pris sur le milieu de la BOÎTE, l'axe partirait de travers — le sommet
        # du cyclone s'évase d'un côté et tirerait le pied avec lui.
        lines = np.nonzero(solid.any(axis=1))[0]
        return (cx, int(lines[-1]))
    return (cx, cy)


def cut(source: str, folder: str, columns: int, rows: list, prefix: str,
        height: int, options: dict = None) -> str:
    path = Path(source)
    if not path.exists():
        return f"  ! {source} introuvable"
    with Image.open(path) as raw:
        sheet = raw.convert("RGBA")
    # La racine par défaut est `assets/characters/` — ces animations
    # appartiennent à un mage. Le portail du labyrinthe, lui, n'appartient à
    # personne : il vit dans `assets/portals/`.
    out = Path((options or {}).get("racine", "assets/characters")) / folder
    out.mkdir(parents=True, exist_ok=True)
    cell_h = sheet.height // len(rows)

    options = options or {}
    anchors = options.get("anchor", {})
    # Une matière peut s'étaler sur PLUSIEURS rangées : le tour du cyclone tient
    # sur deux lignes de quatre images, et c'est une seule animation.
    stack = max(1, int(options.get("rangees_par_matiere", 1)))
    cell_h = sheet.height // (len(rows) * stack)
    report = []
    for row, matter in enumerate(rows):
        frames = []
        for line in range(stack):
            top = (row * stack + line) * cell_h
            edges = [round(sheet.width * c / columns) for c in range(columns + 1)]
            if options.get("gutters"):
                band = np.asarray(keyed(sheet.crop(
                    (0, top, sheet.width, top + cell_h))))[..., 3]
                found = row_cuts(band, columns)
                if found:
                    edges = [0] + found + [sheet.width]
            frames += [keyed(sheet.crop((edges[c], top, edges[c + 1], top + cell_h)))
                       for c in range(columns)]

        mode = anchors.get(matter)
        if mode:
            report.append(_anchored(frames, mode, height, out, prefix, matter))
            continue
        # LA BOÎTE COMMUNE : l'union des contenus de la rangée. Voir l'en-tête.
        union = None
        for frame in frames:
            bounds = frame.getbbox()
            if bounds is None:
                continue
            union = bounds if union is None else (
                min(union[0], bounds[0]), min(union[1], bounds[1]),
                max(union[2], bounds[2]), max(union[3], bounds[3]))
        if union is None:
            report.append(f"! rangée {matter} vide")
            continue
        factor = height / float(union[3] - union[1])
        size = (max(1, int((union[2] - union[0]) * factor)), height)
        for index, frame in enumerate(frames):
            frame.crop(union).resize(size, Image.LANCZOS).save(
                out / f"{prefix}_{matter}_{index}.png")
        report.append(f"{matter} x{columns} {size}")

    # ⚠️ LE NOMBRE D'IMAGES, PAS LE NOMBRE DE COLONNES. Une matière peut
    # s'étaler sur plusieurs rangées : le portail en a huit sur deux lignes de
    # quatre, et le descripteur annonçait fièrement « 4 ».
    (out / f"{prefix}_anim.json").write_text(json.dumps({
        "frames": columns * stack, "matters": rows, "height": height,
    }), encoding="utf-8")
    return f"{folder}/{prefix}  " + " · ".join(report)


def _anchored(frames: list, mode: str, height: int, out: Path,
              prefix: str, matter: str) -> str:
    """Écrit une famille d'images calées sur leur ancre commune.

    La boîte est bâtie AUTOUR de l'ancre et non autour du contenu : c'est ce qui
    rend l'ancre immobile d'une image à l'autre. Sans cela l'onde du Grand
    souffle sautait à chaque image — le mage n'était au centre d'aucune — et la
    pointe du cône glissait le long de son bras.
    """
    points = [anchor_of(frame, mode) for frame in frames]
    boxes = [frame.getbbox() for frame in frames]
    left = max(a[0] - b[0] for a, b in zip(points, boxes) if b)
    right = max(b[2] - a[0] for a, b in zip(points, boxes) if b)
    up = max(a[1] - b[1] for a, b in zip(points, boxes) if b)
    down = max(b[3] - a[1] for a, b in zip(points, boxes) if b)
    if mode == "base":
        # LE PIED SE POSE SUR LA CASE : rien en dessous, et la colonne est
        # centrée en largeur sur lui.
        down = 0
        left = right = max(left, right)
    elif mode == "pointe":
        # La pointe se pose SUR le mage : rien à sa gauche, et le cône est
        # centré en hauteur sur elle — le moteur décale le sprite d'une
        # demi-hauteur, il ne peut pas deviner autre chose.
        left, half = 0, max(up, down)
        up = down = half
    else:
        # ⚠️ LA BOÎTE DOIT ÊTRE SYMÉTRIQUE, pas seulement commune. Bâtie sur les
        # débordements réellement mesurés, elle ne l'est pas — l'onde du Grand
        # souffle s'étale plus vers le bas que vers le haut — et l'ancre se
        # retrouvait 28 px sous le milieu de l'image. Le moteur pose ce sprite
        # CENTRÉ sur le mage : ce qui n'est pas au milieu de l'image n'est pas
        # sur le mage.
        left = right = max(left, right)
        up = down = max(up, down)
    span = (left + right, up + down)
    factor = height / float(span[1])
    size = (max(1, int(span[0] * factor)), height)
    for index, (frame, point) in enumerate(zip(frames, points)):
        box = (point[0] - left, point[1] - up, point[0] + right, point[1] + down)
        frame.crop(box).resize(size, Image.LANCZOS).save(
            out / f"{prefix}_{matter}_{index}.png")
    return f"{matter} x{len(frames)} {size} ancré sur {mode}"


def main() -> None:
    for sheet in SHEETS:
        print(cut(*sheet))


if __name__ == "__main__":
    main()
