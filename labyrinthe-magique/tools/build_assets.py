"""Sélectionne et prépare les assets finaux à partir de assets/raw/.

    tools/.venv/bin/python tools/build_assets.py

Produit :
  assets/sprites/  entités et props, nommés
  assets/tiles/    tuiles 32x32 pour le sol et les haies

La planche source ne contient NI vue de dos NI vue de profil : les douze poses
du mage sont toutes de face ou en trois-quarts. On retient donc un sprite unique
par personnage, retourné horizontalement selon le sens de marche, et le
mouvement est produit en code (balancement, inclinaison). Enchaîner les poses
comme des frames d'animation ferait trembler le personnage : ce ne sont pas les
images d'un même cycle, mais douze dessins légèrement différents.
"""

from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

RAW = Path("assets/raw")
SPRITES = Path("assets/sprites")
TILES = Path("assets/tiles")

TILE = 32

# --- Entités et props : source -> nom final --------------------------------------
SPRITES_MAP = {
    "mage_00": "player",
    "decor_42": "house",
    "portail_00": "portal",
    "effet_03": "teleport_burst",
    # Décor semé dans les couloirs
    "decor_25": "prop_mushroom",
    "decor_11": "prop_flower_purple",
    "decor_31": "prop_flower_red",
    "decor_14": "prop_rock",
    "decor_43": "prop_rocks",
    "decor_04": "prop_log",
    "decor_30": "prop_stone",
    "decor_39": "prop_twig",
    "decor_18": "prop_plant",
    "decor_22": "rune_blue",
    "decor_33": "rune_teal",
    "decor_34": "rune_deep",
    "decor_21": "lantern",
    "decor_26": "torch",
    "decor_27": "torch_gold",
    # Arbres de la lisière, plantés autour du labyrinthe
    "decor_02": "tree_bright",
    "decor_09": "tree_pine",
    "decor_17": "tree_round",
    "decor_32": "tree_small",
    "decor_15": "tree_dead",
    "decor_10": "tree_twisted",
}

# --- Objectifs : gemmes, potion, orbe ---------------------------------------------
#
# Ces trois-là sont DESSINÉS, pas extraits. La planche ne contient ni gemme
# taillée, ni fiole, ni projectile : ses cristaux sont des rochers violets posés
# sur un socle d'herbe, impossibles à distinguer du décor une fois semés dans
# les couloirs — et un objectif qu'on confond avec un champignon n'est pas un
# objectif. On génère donc des formes nettes, symétriques et très saturées, qui
# ne ressemblent à rien d'autre à l'écran.
#
# Tout est tracé en SURÉCHANTILLONNAGE x4 puis réduit : PIL ne sait pas lisser
# un polygone, la réduction s'en charge à sa place.

SS = 4

# Une couleur par gemme. Le joueur doit pouvoir dire « il me manque la rouge »
# sans compter : sept teintes franches, jamais deux voisines dans le cercle.
# Sept et pas cinq parce que le stage 3 en demande six — avec cinq, deux gemmes
# partageaient une couleur et la rangée du bandeau devenait ambiguë.
GEM_COLORS = {
    "gem_diamond": (150, 236, 255),
    "gem_ruby": (255, 72, 96),
    "gem_emerald": (78, 236, 140),
    "gem_amethyst": (188, 112, 255),
    "gem_topaz": (255, 202, 76),
    "gem_sapphire": (74, 122, 255),
    "gem_rose": (255, 122, 208),
}


def _shade(rgb: tuple, factor: float, alpha: int = 255) -> tuple:
    return tuple(min(255, int(c * factor)) for c in rgb) + (alpha,)


def build_gem(rgb: tuple, size: int = 64) -> Image.Image:
    """Taille brillant vue de dessus : un octogone, une table centrale et huit
    facettes. Vue de dessus et non de profil parce que le jeu est en vue de
    dessus — une gemme de profil poserait la même question que la maison : sur
    quoi repose-t-elle ?

    L'éclat de chaque facette suit l'ANGLE de la facette par rapport à une
    lumière fixe en haut à gauche, avec une légère alternance par-dessus. Une
    alternance seule (clair, sombre, clair…) donne un moulin à vent parfaitement
    plat ; c'est le gradient angulaire qui fait lire une pierre bombée."""
    n = size * SS
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = cy = n / 2.0
    radius = n * 0.42
    turn = np.pi / 8.0
    light = -2.2   # radians : haut-gauche

    def ring(r):
        return [(cx + r * np.cos(turn + i * np.pi / 4.0),
                 cy + r * np.sin(turn + i * np.pi / 4.0)) for i in range(8)]

    outer, inner = ring(radius), ring(radius * 0.48)

    d.polygon(ring(radius * 1.10), fill=(10, 12, 20, 255))           # cerne sombre
    for i in range(8):
        angle = turn + (i + 0.5) * np.pi / 4.0
        facet = 0.86 + 0.46 * np.cos(angle - light) + (0.10 if i % 2 else -0.10)
        d.polygon([outer[i], outer[(i + 1) % 8], inner[(i + 1) % 8], inner[i]],
                  fill=_shade(rgb, max(0.30, facet)))
    d.polygon(inner, fill=_shade(rgb, 1.32))
    # Moitié basse de la table assombrie : la table est plate, mais sans ce
    # dégradé la pierre se lit comme un autocollant posé sur le sol.
    d.polygon([inner[2], inner[3], inner[4], inner[5], inner[6]], fill=_shade(rgb, 1.06))
    for i in range(8):                                               # arêtes
        d.line([inner[i], outer[i]], fill=_shade(rgb, 0.42), width=max(1, n // 80))
    d.line(outer + [outer[0]], fill=(12, 14, 24, 235), width=max(2, n // 46), joint="curve")

    # Éclat : une tache et une étoile à quatre branches, du côté de la lumière.
    d.ellipse([cx - radius * 0.36, cy - radius * 0.44,
               cx - radius * 0.04, cy - radius * 0.16], fill=(255, 255, 255, 240))
    sx, sy, s = cx + radius * 0.30, cy + radius * 0.26, radius * 0.30
    d.polygon([(sx, sy - s), (sx + s * 0.20, sy), (sx, sy + s), (sx - s * 0.20, sy)],
              fill=(255, 255, 255, 225))
    d.polygon([(sx - s, sy), (sx, sy - s * 0.20), (sx + s, sy), (sx, sy + s * 0.20)],
              fill=(255, 255, 255, 225))
    return img.resize((size, size), Image.LANCZOS)


def build_potion(size: int = 64) -> Image.Image:
    """Fiole ronde à col court. Le contenu est cyan comme l'orbe qu'elle
    permet de lancer : la couleur est le seul lien qui apprend au joueur, sans
    un mot de tutoriel, ce que la potion lui donne."""
    n = size * SS
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = n / 2.0
    body_r = n * 0.30
    body_cy = n * 0.62
    glass = (196, 232, 246)
    liquid = (46, 196, 255)

    neck = [cx - n * 0.11, n * 0.16, cx + n * 0.11, n * 0.42]
    d.rounded_rectangle(neck, radius=n * 0.04, fill=_shade(glass, 0.42))
    d.ellipse([cx - body_r * 1.06, body_cy - body_r * 1.06,
               cx + body_r * 1.06, body_cy + body_r * 1.06], fill=(24, 34, 52, 255))
    d.ellipse([cx - body_r, body_cy - body_r, cx + body_r, body_cy + body_r],
              fill=_shade(glass, 0.55))

    # Liquide : les deux tiers bas de la panse, surface plate et plus claire.
    level = body_cy - body_r * 0.34
    d.chord([cx - body_r * 0.9, body_cy - body_r * 0.9,
             cx + body_r * 0.9, body_cy + body_r * 0.9], 0, 180, fill=_shade(liquid, 1.0))
    d.rectangle([cx - body_r * 0.87, level, cx + body_r * 0.87, body_cy],
                fill=_shade(liquid, 1.0))
    d.ellipse([cx - body_r * 0.87, level - body_r * 0.16,
               cx + body_r * 0.87, level + body_r * 0.16], fill=_shade(liquid, 1.35))
    for bx, by, br in ((-0.30, 0.22, 0.11), (0.24, 0.44, 0.08), (0.02, 0.62, 0.06)):
        d.ellipse([cx + body_r * (bx - br), body_cy + body_r * (by - br),
                   cx + body_r * (bx + br), body_cy + body_r * (by + br)],
                  fill=_shade(liquid, 1.6))

    # Reflet du verre, en croissant sur la gauche.
    d.arc([cx - body_r * 0.78, body_cy - body_r * 0.78,
           cx + body_r * 0.78, body_cy + body_r * 0.78],
          140, 215, fill=(255, 255, 255, 220), width=int(n * 0.028))
    d.rounded_rectangle([cx - n * 0.13, n * 0.10, cx + n * 0.13, n * 0.20],
                        radius=n * 0.03, fill=(150, 106, 66, 255))
    d.rounded_rectangle([cx - n * 0.13, n * 0.10, cx + n * 0.13, n * 0.13],
                        radius=n * 0.02, fill=(186, 138, 88, 255))
    return img.resize((size, size), Image.LANCZOS)


def build_compass_arrow(size: int = 48) -> Image.Image:
    """Flèche de la boussole, ÉCLAIRCIE avant d'être teintée. La flèche de la
    planche est bleu nuit : la teinter en jeu la multiplie, et une flèche rouge
    sur fond de haies sombres devient invisible. On la ramène donc au blanc, en
    gardant son ombrage — la couleur, elle, viendra de la gemme visée."""
    source = Image.open(RAW / "effet_04.png").convert("RGBA")
    source.thumbnail((size, size), Image.LANCZOS)
    pixels = np.array(source).astype(float)
    rgb, alpha = pixels[..., :3], pixels[..., 3:]
    luma = rgb.mean(axis=2, keepdims=True)
    peak = max(1.0, float(luma[alpha[..., 0] > 40].max()) if (alpha > 40).any() else 1.0)
    # Remontée douce (racine) : un simple facteur écraserait tout sur du blanc
    # plat et la flèche perdrait son relief.
    lifted = 255.0 * np.sqrt(np.clip(luma / peak, 0.0, 1.0))
    out = np.dstack([np.clip(lifted.repeat(3, axis=2) * 0.55 + 255.0 * 0.45, 0, 255), alpha])
    return Image.fromarray(out.astype(np.uint8), "RGBA")


# --- Planche d'animation du mage --------------------------------------------------
#
# `mage_sheet.png` contient cinq rangées de poses dessinées à la main. Trois
# constats, mesurés et non supposés (position de l'orbe par rapport au centre du
# corps, présence de la barbe claire sur le tiers haut) :
#
#   - TOUTE la planche est dessinée vers la DROITE ou de DOS. Aucune pose vers
#     la gauche, aucune vue de face franche. La marche vers la gauche est donc
#     le miroir de celle vers la droite — ce que le jeu faisait déjà.
#   - la rangée 1 est la seule entièrement de dos (bâton en travers, orbe caché) :
#     c'est la marche vers le HAUT.
#   - la rangée 4 est l'incantation, cerclée de magie violette.
#
# La planche est fournie avec un VRAI canal alpha : on le lit tel quel. Une
# première version arrivait sur damier peint, sans alpha ; le détourage par
# remplissage depuis les bords laissait alors du blanc dans les trous FERMÉS
# (entre le bâton et la cape, entre les jambes), qui ne touchent aucun bord.
# La fonction garde ce repli, mais il ne sert plus tant que la source est
# transparente — et c'est très bien ainsi : aucun détourage ne vaut l'alpha
# d'origine.

MAGE_SHEET = RAW / "mage_sheet.png"
## Rangée source de chaque animation. La gauche est produite par miroir.
MAGE_ANIMATIONS = {
    "mage_walk_right": (0, None),
    "mage_walk_up": (1, None),
    "mage_walk_down": (2, None),
    "mage_cast": (4, None),
}
## Hauteur d'une case de la planche finale, en pixels. Le jeu affiche le mage à
## ~46 px de haut ; 112 laisse de la marge pour les grands écrans sans gonfler
## le fichier.
MAGE_FRAME_HEIGHT = 112


def _mage_alpha(image: Image.Image) -> np.ndarray:
    """Canal alpha de la planche. On préfère TOUJOURS celui de l'image."""
    if image.mode == "RGBA":
        alpha = np.array(image)[..., 3]
        if alpha.min() < 8:      # il y a bien du transparent : c'est le bon
            return alpha
    from scipy import ndimage
    rgb = np.array(image.convert("RGB")).astype(int)
    low, high = rgb.min(axis=2), rgb.max(axis=2)
    background = (low > 232) & ((high - low) < 14)
    labels, _ = ndimage.label(background)
    edges = set(labels[0]) | set(labels[-1]) | set(labels[:, 0]) | set(labels[:, -1])
    edges.discard(0)
    return np.where(np.isin(labels, list(edges)), 0, 255).astype(np.uint8)


def _mage_frames(alpha: np.ndarray):
    """Poses de la planche, rangée par rangée.

    Chaque pose est décrite par ses COMPOSANTES CONNEXES, pas par un rectangle.
    Découper au rectangle recopiait dans la case les éclats de magie de la pose
    voisine — un fragment de lueur qui apparaît et disparaît d'une image à
    l'autre, et qu'on voit clignoter dès que l'animation tourne.

    Les petits morceaux (éclats, étincelles détachées) sont rattachés à la pose
    dont le centre est le plus proche."""
    from scipy import ndimage
    labels, count = ndimage.label(alpha > 40, structure=np.ones((3, 3)))
    slices = ndimage.find_objects(labels)

    bodies, bits = [], []
    for index, box in enumerate(slices):
        if box is None:
            continue
        height = box[0].stop - box[0].start
        width = box[1].stop - box[1].start
        area = int((labels[box] == index + 1).sum())
        entry = (index + 1, box, (box[1].start + box[1].stop) / 2.0)
        if area >= 400 and height >= 30 and width >= 60:
            bodies.append(entry)
        elif area >= 12:
            bits.append(entry)

    rows = {}
    for label, box, centre in bodies:
        rows.setdefault(box[0].start // 140, []).append(
            {"labels": [label], "box": [box[1].start, box[0].start, box[1].stop, box[0].stop],
             "centre": centre})
    for row in rows.values():
        row.sort(key=lambda f: f["centre"])

    for label, box, centre in bits:
        row_key = box[0].start // 140
        if row_key not in rows:
            continue
        target = min(rows[row_key], key=lambda f: abs(f["centre"] - centre))
        target["labels"].append(label)
        target["box"] = [min(target["box"][0], box[1].start), min(target["box"][1], box[0].start),
                         max(target["box"][2], box[1].stop), max(target["box"][3], box[0].stop)]
    return rows, labels


def build_mage_animations() -> dict:
    """Découpe la planche en une bande horizontale par animation.

    Toutes les poses sont recalées sur un MÊME point d'ancrage : le centre des
    pieds. Recaler sur le centre de la boîte englobante ferait tanguer le mage
    d'une pose à l'autre, parce que la cape et le bâton changent de largeur à
    chaque image sans que le corps bouge."""
    source = Image.open(MAGE_SHEET)
    alpha = _mage_alpha(source)
    rgb = np.array(source.convert("RGB"))
    rows, labels = _mage_frames(alpha)

    def cutout(frame):
        """Image de la pose SEULE : tout ce qui n'appartient pas à ses
        composantes devient transparent. Découper au rectangle recopiait dans
        la case les éclats de magie de la pose voisine — un fragment qui
        apparaît et disparaît d'une image à l'autre, et qu'on voit clignoter
        dès que l'animation tourne."""
        x0, y0, x1, y1 = frame["box"]
        keep = np.isin(labels[y0:y1, x0:x1], frame["labels"])
        piece = np.dstack([rgb[y0:y1, x0:x1], np.where(keep, alpha[y0:y1, x0:x1], 0)])
        return Image.fromarray(piece.astype(np.uint8), "RGBA"), keep

    def anchor(frame):
        x0, y0, x1, y1 = frame["box"]
        _, keep = cutout(frame)
        mask = keep & (alpha[y0:y1, x0:x1] > 40)
        feet = mask[int(mask.shape[0] * 0.78):]
        xs = np.nonzero(feet.any(axis=0))[0]
        centre = float(xs.mean()) if len(xs) else mask.shape[1] / 2.0
        return x0 + centre, y1

    # Une seule taille de case pour toutes les animations : le mage ne doit pas
    # changer d'échelle quand il passe de la marche à l'incantation.
    spans = []
    for row_index, _ in MAGE_ANIMATIONS.values():
        for frame in rows[row_index]:
            ax, ay = anchor(frame)
            spans.append((ax - frame["box"][0], frame["box"][2] - ax, ay - frame["box"][1]))
    left = max(s[0] for s in spans)
    right = max(s[1] for s in spans)
    top = max(s[2] for s in spans)
    cell = (int(left + right) + 8, int(top) + 10)

    # Échelle finale calculée UNE fois : chaque bande doit faire exactement
    # `cell_width * nombre de poses`, sinon un arrondi par bande décale la
    # découpe côté moteur et l'animation glisse d'un pixel à chaque tour.
    scale = MAGE_FRAME_HEIGHT / cell[1]
    cell_width = int(round(cell[0] * scale))

    built = {}
    for name, (row_index, keep) in MAGE_ANIMATIONS.items():
        frames = rows[row_index]
        if keep is not None:
            frames = [frames[i] for i in keep]
        strip = Image.new("RGBA", (cell[0] * len(frames), cell[1]), (0, 0, 0, 0))
        for i, frame in enumerate(frames):
            ax, ay = anchor(frame)
            piece, _ = cutout(frame)
            x = int(i * cell[0] + left + 4 - (ax - frame["box"][0]))
            y = int(cell[1] - 5 - (ay - frame["box"][1]))
            strip.alpha_composite(piece, (x, y))
        strip = strip.resize((cell_width * len(frames), MAGE_FRAME_HEIGHT), Image.LANCZOS)
        strip.save(SPRITES / f"{name}.png")
        built[name] = len(frames)

    # Le jeu ne DEVINE pas le nombre de poses : il le lit ici. Sans ce fichier,
    # toute retouche de la planche obligerait à corriger une constante dans le
    # code, et une planche à 10 poses lue comme 11 décale toute l'animation.
    import json
    (SPRITES / "mage_frames.json").write_text(json.dumps(
        {
            "cell": [cell_width, MAGE_FRAME_HEIGHT],
            # Hauteur des pieds dans la case, pour que le moteur pose le
            # personnage sur le sol et non sur son ventre.
            "feet_y": round(MAGE_FRAME_HEIGHT - 5 * scale, 1),
            "animations": built,
        }, indent=2), encoding="utf-8")
    return built


# --- Manette tactile ---------------------------------------------------------------
#
# `pad_mobile.png` est une planche de manettes : une cinquantaine de croix, de
# boutons et de manches, sans grille régulière — il n'y a rien à en déduire, on
# désigne ce qu'on veut. Le jeu n'en prend QU'UNE chose : le manche analogique
# bleu de la rangée du bas, le seul dont la palette s'accorde au reste de
# l'interface (le bandeau, la boussole et les portails sont bleus).
#
# La planche le dessine base et bouton COLLÉS, en une seule forme. Le jeu, lui,
# a besoin des deux séparément : le bouton suit le pouce, la base ne bouge pas.
# On les sépare par l'ALPHA — la base est translucide, le bouton est le seul
# disque franchement opaque — puis on rebouche le trou laissé au centre, sinon
# on verrait le décor à travers la base dès que le bouton se déplace.

PAD_SHEET = Path("assets/peso&cover/interface/pad_mobile.png")
UI = Path("assets/ui")
## Boîte du manche bleu, relevée à la main sur la planche.
PAD_STICK_BOX = (760, 728, 1010, 998)
## Au-dessus de ce seuil d'alpha, on est sur le bouton et pas sur la base.
PAD_KNOB_ALPHA = 238


def _pad_knob_disc(alpha: np.ndarray) -> tuple:
    """(centre, rayon) du bouton dans la vignette du manche."""
    from scipy import ndimage
    labels, count = ndimage.label(alpha > PAD_KNOB_ALPHA)
    if count == 0:
        raise RuntimeError("manette : aucun bouton opaque trouvé")
    sizes = ndimage.sum(np.ones_like(labels), labels, range(1, count + 1))
    ys, xs = np.nonzero(labels == int(np.argmax(sizes)) + 1)
    centre = ((xs.min() + xs.max()) * 0.5, (ys.min() + ys.max()) * 0.5)
    return centre, max(xs.max() - xs.min(), ys.max() - ys.min()) * 0.5


def build_touch_stick() -> tuple:
    """Sépare le manche en deux fichiers : la base fixe et le bouton mobile."""
    from scipy import ndimage
    sheet = Image.open(PAD_SHEET).convert("RGBA")
    crop = sheet.crop(PAD_STICK_BOX)
    pixels = np.array(crop).astype(int)
    (cx, cy), radius = _pad_knob_disc(pixels[..., 3])

    # La boîte mord sur les voisines de la planche — une feuille en haut à
    # gauche, une pointe rouge en haut à droite. On ne garde que la forme
    # connexe qui contient le bouton : c'est le manche, et lui seul.
    labels, _ = ndimage.label(pixels[..., 3] > 40, structure=np.ones((3, 3)))
    pixels[labels != labels[int(cy), int(cx)], 3] = 0

    height, width = pixels.shape[:2]
    y, x = np.mgrid[0:height, 0:width]
    distance = np.hypot(x - cx, y - cy)

    # Couleur du creux : la médiane de l'anneau qui entoure le bouton. La
    # calculer plutôt que la choisir garde la base raccord si la planche change.
    ring = (distance > radius + 4.0) & (distance < radius + 16.0)
    fill = np.median(pixels[ring], axis=0)

    # Fondu sur trois pixels : un disque à bord net se verrait comme une pièce
    # rapportée, alors que la base est un dégradé.
    blend = np.clip((radius + 2.0 - distance) / 3.0, 0.0, 1.0)[..., None]
    base = pixels * (1.0 - blend) + fill[None, None, :] * blend
    Image.fromarray(np.clip(base, 0, 255).astype(np.uint8), "RGBA").save(UI / "stick_base.png")

    # Le bouton est recadré SYMÉTRIQUEMENT autour de son centre : le moteur pose
    # donc sa texture au centre de la base sans avoir à connaître de décalage.
    # Et il est DÉCOUPÉ EN ROND — recadré carré, il emporterait les coins
    # translucides de la base et se promènerait sur l'écran en carré bleu.
    half = int(radius) + 8
    knob = np.array(crop.crop((int(cx) - half, int(cy) - half,
                               int(cx) + half, int(cy) + half))).astype(float)
    ky, kx = np.mgrid[0:knob.shape[0], 0:knob.shape[1]]
    edge = np.clip((radius + 3.0 - np.hypot(kx - half, ky - half)) / 2.0, 0.0, 1.0)
    knob[..., 3] *= edge
    Image.fromarray(np.clip(knob, 0, 255).astype(np.uint8), "RGBA").save(UI / "stick_knob.png")
    return crop.size, (knob.shape[1], knob.shape[0])


def build_app_icon(size: int = 1024) -> Image.Image:
    """Icône de l'application, composée à partir des assets du jeu plutôt que
    dessinée à part : le mage sur la texture de haie, une gemme à ses pieds.

    Carrée et SANS transparence — iOS refuse un canal alpha sur l'icône de
    l'App Store et applique lui-même son masque arrondi. Les bords sont
    assombris en vignette pour que la silhouette reste lisible une fois
    l'icône réduite à 60 px sur l'écran d'accueil."""
    hedge = Image.open(TILES / "hedge_sheet.png").convert("RGB")
    icon = hedge.resize((size, size), Image.LANCZOS).filter(
        __import__("PIL.ImageFilter", fromlist=["ImageFilter"]).GaussianBlur(size / 90))

    # Vignette : sombre aux angles, un peu de lumière au centre.
    y, x = np.mgrid[0:size, 0:size]
    centre = (size - 1) / 2.0
    radius = np.sqrt((x - centre) ** 2 + (y - centre) ** 2) / (size * 0.62)
    shade = np.clip(1.05 - 1.05 * radius ** 1.5, 0.10, 1.0)[..., None]
    pixels = np.array(icon).astype(float) * shade * 0.50
    pixels += np.array([13.0, 25.0, 23.0]) * (1.0 - shade)
    icon = Image.fromarray(np.clip(pixels, 0, 255).astype(np.uint8), "RGB")

    gem = Image.open(SPRITES / "gem_diamond.png").convert("RGBA")
    gem = gem.resize((int(size * 0.22),) * 2, Image.LANCZOS)
    icon.paste(gem, (int(size * 0.62), int(size * 0.66)), gem)

    mage = Image.open(SPRITES / "player.png").convert("RGBA")
    scale = size * 0.66 / mage.height
    mage = mage.resize((int(mage.width * scale), int(mage.height * scale)), Image.LANCZOS)
    icon.paste(mage, (int(size * 0.40) - mage.width // 2, int(size * 0.14)), mage)
    return icon


def build_orb(size: int = 48) -> Image.Image:
    """Projectile du sort : un simple dégradé radial, calculé et non dessiné.
    Il est affiché en blending ADDITIF comme les portails — son noir est donc
    transparent d'office, et seul compte le profil de luminosité."""
    y, x = np.mgrid[0:size, 0:size]
    centre = (size - 1) / 2.0
    r = np.sqrt((x - centre) ** 2 + (y - centre) ** 2) / centre
    core = np.clip(1.0 - r * 1.9, 0.0, 1.0) ** 1.4      # cœur blanc
    halo = np.clip(1.0 - r, 0.0, 1.0) ** 2.6            # halo bleu
    rgb = np.zeros((size, size, 3))
    rgb[..., 0] = 40 * halo + 215 * core
    rgb[..., 1] = 170 * halo + 235 * core
    rgb[..., 2] = 255 * halo + 255 * core
    alpha = np.clip(halo * 1.15 + core, 0.0, 1.0) * 255
    out = np.dstack([np.clip(rgb, 0, 255), alpha]).astype(np.uint8)
    return Image.fromarray(out, "RGBA")


# --- Tuiles ----------------------------------------------------------------------
#
# Les haies sont composées de QUATRE sous-morceaux de 16 px au lieu d'un seul
# morceau de 32. Raison : la carte de référence de la planche dessine les haies
# à ~20 px par case, alors que le jeu affiche des cases de ~66 px à l'écran. Une
# tuile prise telle quelle donne donc quatre énormes feuilles par case — ça fait
# du bruit, pas une masse de feuillage. Descendre les morceaux à 16 px divise par
# deux la taille des feuilles et double leur densité.
HEDGE_PIECES = [
    ("sol_03", (7, 7, 37, 37)),
    ("sol_08", (8, 5, 40, 33)),
    ("sol_09", (4, 4, 26, 26)),
    ("sol_11", (6, 4, 36, 30)),
    ("sol_07", (6, 4, 36, 32)),
    ("sol_01", (46, 60, 76, 86)),
]
# Trois agencements différents des mêmes morceaux : de quoi casser la répétition
# sans multiplier les fichiers.
# Côté de la planche de feuillage, en pixels. 96 = 3x3 cases : chaque case du
# labyrinthe échantillonne une zone CONTIGUË de cette planche selon ses
# coordonnées modulo 3. Deux cases voisines lisent donc deux zones voisines
# d'une même texture continue — la grille par case disparaît complètement,
# alors qu'une tuile indépendante par case laisse forcément voir ses bords.
SHEET = TILE * 3
## Nombre de morceaux de feuillage tamponnés pour composer la planche.
STAMPS = 260


def _feathered(piece: Image.Image) -> tuple:
    """Morceau + masque à bords fondus, pour que les tampons se fondent entre eux
    au lieu de se juxtaposer avec un contour net."""
    size = piece.size[0]
    rgb = np.array(piece.convert("RGB")).astype(float)
    alpha = np.array(piece.convert("RGBA"))[:, :, 3].astype(float) / 255.0
    y, x = np.mgrid[0:size, 0:size]
    centre = (size - 1) / 2.0
    radius = np.sqrt((x - centre) ** 2 + (y - centre) ** 2) / (size * 0.5)
    alpha *= np.clip(1.35 - 1.35 * radius, 0.0, 1.0)
    return rgb, alpha


def build_hedge_sheet(seed: int = 7) -> Image.Image:
    """Synthèse par tamponnage, avec repli cyclique aux bords : la planche se
    répète sans couture dans les deux axes."""
    rng = np.random.default_rng(seed)
    canvas = np.zeros((SHEET, SHEET, 3))
    canvas[:] = [16.0, 30.0, 14.0]  # sous-couche sombre, comble les trous

    sources = []
    for name, box in HEDGE_PIECES:
        sources.append(Image.open(RAW / f"{name}.png").convert("RGBA").crop(box))

    for _ in range(STAMPS):
        source = sources[rng.integers(len(sources))]
        size = int(rng.integers(11, 19))
        piece = source.resize((size, size), Image.LANCZOS)
        piece = piece.rotate(float(rng.integers(0, 360)), Image.BICUBIC)
        rgb, alpha = _feathered(piece)
        # Variation de teinte par tampon : sans elle, la masse est plate.
        rgb *= rng.uniform(0.78, 1.18)
        cx, cy = int(rng.integers(0, SHEET)), int(rng.integers(0, SHEET))
        for j in range(size):
            row = (cy + j) % SHEET
            for i in range(size):
                a = alpha[j, i]
                if a <= 0.01:
                    continue
                col = (cx + i) % SHEET
                canvas[row, col] = canvas[row, col] * (1.0 - a) + rgb[j, i] * a

    return Image.fromarray(np.clip(canvas, 0, 255).astype(np.uint8)).convert("RGBA")


TOP_EDGE = ("sol_11", (3, 0, 48, 15), "hedge_top", (TILE, 13))


def build_hedge(layout: tuple, sub: int = TILE // 2) -> Image.Image:
    tile = Image.new("RGBA", (TILE, TILE))
    for slot, piece_index in enumerate(layout):
        source, box = HEDGE_PIECES[piece_index]
        piece = Image.open(RAW / f"{source}.png").convert("RGBA").crop(box)
        piece = piece.resize((sub, sub), Image.LANCZOS)
        # Rotation par quart de tour selon l'emplacement : sans elle, les quatre
        # quartiers d'une même tuile se ressemblent trop et le motif se voit.
        piece = piece.rotate(90 * slot)
        tile.paste(piece, ((slot % 2) * sub, (slot // 2) * sub))
    return tile


def build_floor_sheet(seed: int) -> Image.Image:
    """Sol généré : la planche ne contient aucune tuile de sol convenable — ses
    textures de terre sont brunes et presque aussi claires que le feuillage, ce
    qui rendait les couloirs indistinguables des murs. Un bruit synthétisé est
    plus sombre, plus sobre, et surtout CYCLIQUE : il se répète sans couture.
    """
    rng = np.random.default_rng(seed)
    y, x = np.mgrid[0:SHEET, 0:SHEET]

    # Somme de sinusoïdes à fréquences ENTIÈRES : le motif boucle exactement sur
    # la planche, donc aucune couture visible une fois répété.
    noise = np.zeros((SHEET, SHEET))
    for frequency in (1, 2, 4, 8, 16):
        for _ in range(2):
            ax, ay = rng.integers(-frequency, frequency + 1, 2)
            phase = rng.random() * 2 * np.pi
            noise += np.sin(2 * np.pi * (ax * x + ay * y) / SHEET + phase) / frequency
    noise = (noise - noise.min()) / max(1e-6, noise.max() - noise.min())

    base = np.array([19.0, 31.0, 25.0])
    warm = np.array([37.0, 47.0, 29.0])
    pixels = base + (warm - base) * noise[..., None]

    # Cailloux clairsemés, posés avec repli cyclique pour rester raccordables.
    for _ in range(rng.integers(26, 40)):
        cx, cy = rng.integers(0, SHEET, 2)
        radius = int(rng.integers(1, 4))
        tone = rng.uniform(48, 74)
        for dy in range(-radius, radius + 1):
            for dx in range(-radius, radius + 1):
                if dx * dx + dy * dy > radius * radius:
                    continue
                px, py = (cx + dx) % SHEET, (cy + dy) % SHEET
                pixels[py, px] = [tone * 0.82, tone, tone * 0.92]

    return Image.fromarray(np.clip(pixels, 0, 255).astype(np.uint8)).convert("RGBA")


def main() -> None:
    SPRITES.mkdir(parents=True, exist_ok=True)
    TILES.mkdir(parents=True, exist_ok=True)
    UI.mkdir(parents=True, exist_ok=True)

    for source, name in SPRITES_MAP.items():
        path = RAW / f"{source}.png"
        if not path.exists():
            print(f"  ! {source} introuvable")
            continue
        Image.open(path).convert("RGBA").save(SPRITES / f"{name}.png")
    print(f"sprites : {len(SPRITES_MAP)} fichiers")

    for name, rgb in GEM_COLORS.items():
        build_gem(rgb).save(SPRITES / f"{name}.png")
    build_potion().save(SPRITES / "potion.png")
    build_compass_arrow().save(SPRITES / "compass_arrow.png")
    build_app_icon().save(Path("assets/icon.png"))
    if MAGE_SHEET.exists():
        frames = build_mage_animations()
        print("mage    : " + ", ".join(f"{k} ({v} poses)" for k, v in frames.items()))
    build_orb().save(SPRITES / "magic_orb.png")
    if PAD_SHEET.exists():
        base, knob = build_touch_stick()
        print(f"manette : base {base[0]}x{base[1]} + bouton {knob[0]}x{knob[1]}")
    print(f"dessinés: {len(GEM_COLORS)} gemmes + potion + orbe + flèche + icône 1024")

    build_hedge_sheet().save(TILES / "hedge_sheet.png")
    build_floor_sheet(1001).save(TILES / "floor_sheet.png")

    source, box, name, size = TOP_EDGE
    Image.open(RAW / f"{source}.png").convert("RGBA").crop(box).resize(size, Image.LANCZOS) \
        .save(TILES / f"{name}.png")

    # Ombre portée sous les haies : un dégradé généré, pas extrait. Le fabriquer
    # garantit un alpha propre — une ombre découpée de la planche traînerait des
    # restes de feuillage sur ses bords.
    shadow = Image.new("RGBA", (TILE, 14), (0, 0, 0, 0))
    for y in range(shadow.height):
        alpha = int(150 * (1.0 - y / shadow.height) ** 1.6)
        for x in range(TILE):
            shadow.putpixel((x, y), (2, 6, 10, alpha))
    shadow.save(TILES / "hedge_shadow.png")
    print(f"tuiles  : planches {SHEET}x{SHEET} + bordure + ombre")


if __name__ == "__main__":
    main()
