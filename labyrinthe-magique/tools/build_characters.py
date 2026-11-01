"""Découpe les planches de personnages en bandes d'animation utilisables.

    tools/.venv/bin/python tools/build_characters.py

Produit, pour chaque personnage :
    assets/characters/<id>/down.png  up.png  left.png  right.png
    assets/characters/<id>/frames.json
et, pour les ennemis, la même chose sous assets/enemies/<id>/.

Chaque bande contient les six poses d'une direction, dans l'ordre
IDLE, WALK 1, WALK 2, WALK 3, WALK 4, ATTACK — le même ordre sur toutes les
planches, c'est la grille fournie par l'illustrateur.

DEUX MODES DE DÉCOUPE, PARCE QU'AUCUN NE MARCHE PARTOUT

« grille » — les sept planches de mages. Elles n'ont pas la même mise en page :
panneaux d'effets à droite ou en bas, étiquettes de colonnes présentes ou non,
lueurs qui débordent d'une case sur l'autre. Les composantes connexes y échouent
(deux sprites voisins fusionnent par leur halo), et coder sept grilles à la main
serait faux dès la première planche corrigée. La grille, elle, est RÉGULIÈRE : on
retrouve son pas par autocorrélation du profil d'opacité, puis sa phase en
cherchant le décalage qui met les lignes de grille dans les GOUTTIÈRES.

« formes » — la planche du gobelin. Ses sprites sont bien rangés en 4 x 6, mais
PAS sur un pas régulier : les six poses d'une rangée sont espacées de 221 à 227
px, l'attaque de 314. Une grille, quel que soit son pas, sectionne des massues.
En revanche chaque gobelin, massue comprise, est une seule forme connexe bien
détachée de ses voisines — c'est donc elle qui fait foi.

« poses » — la planche du spectre. Elle n'a NI quatre orientations NI cycle de
marche : dix-sept poses de face d'une créature qui LÉVITE, plus un grand panneau
d'effets (projectiles, portails, explosions) qui occupe la moitié basse. Rien à
déduire automatiquement, donc : on désigne à la main la rangée et les colonnes
qui remplissent les six créneaux de POSES, et la planche ne déclare qu'une seule
direction — le moteur la réutilise pour les quatre.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image

SOURCE = Path("assets/peso&cover")
OUT = Path("assets/characters")
## Les ennemis suivent le même format, mais ne sont pas des personnages jouables :
## CharacterCatalog ne doit jamais tomber dessus.
OUT_ENEMIES = Path("assets/enemies")

## Hauteur d'une case dans les bandes finales. Le jeu affiche le mage à ~58 px ;
## 112 laisse de la marge sur grand écran sans gonfler les fichiers.
FRAME_HEIGHT = 112

## Ordre des poses dans la grille, identique sur les sept planches.
POSES = ["idle", "walk_1", "walk_2", "walk_3", "walk_4", "attack"]
DIRECTIONS = ["down", "up", "left", "right"]

## Par planche : identifiant du personnage, et l'ancrage de la grille en INDICES
## de cellules détectées (colonne de départ, rangée de départ).
##
## Tous à zéro, et ce n'est pas un hasard : la PHASE détectée tombe déjà sur la
## première case de personnage, parce que les étiquettes (« DOWN », « WALK 1 »…)
## sont des pastilles étroites qui ne pèsent presque rien dans le profil
## d'opacité. Une version précédente mettait `col0 = 1, row0 = 1` sur l'Eau et
## les Ténèbres en croyant sauter une colonne d'étiquettes : elle sautait en
## réalité la pose IDLE **et** la direction DOWN. Résultat en jeu — le mage
## n'avait pas de pose de repos, et sa quatrième direction tombait dans le
## portrait du bas de la planche.
##
## La vérification est faite par `tools/check_characters.py`, qui compare cet
## ancrage aux rangées et colonnes réellement mesurées.
## `mode` vaut "grille" par défaut ; `out` vaut assets/characters/ par défaut.
SHEETS = {
    # LES HUIT MAGES, PLANCHES REFAITES LE 2026-08-25.
    #
    # Les anciennes avaient été dessinées séparément et occupaient leur case
    # commune de 60 % (Feu) à 93 % (Invocateur) : un mage paraissait plus petit
    # qu'un autre sans qu'aucune règle du jeu ne le dise. Les huit nouvelles sont
    # commandées sur le même gabarit — 6 colonnes x 4 rangées de 256 px, le
    # personnage à 80 % de la hauteur de sa case, pieds près du bas.
    #
    # GRILLE IMPOSÉE et non détectée : un pas de 256 px sort de la fenêtre
    # d'autocorrélation (calibrée sur 70-220). C'est justement pour ça que le
    # prompt exige une grille régulière — ce qui est promis peut être imposé.
    #
    # ⚠️ Elles ne remplacent PAS les anciennes sur le disque. `build_spell_fx.py`
    # et `build_warps.py` découpent l'orbe, l'impact, la zone et la colonne de
    # téléportation de chaque mage à des coordonnées relevées à la main DANS les
    # anciennes planches, qui restent donc en place tant que les planches
    # d'effets de la refonte ne sont pas arrivées.
    "refonte/feu.png": {"id": "fire", "grid": (256, 256, 0, 0), "gutter": True,
                         "attack_mirror": {"left": "right"}},
    "refonte/eau.png": {"id": "water", "grid": (256, 256, 0, 0), "gutter": True,
                         "attack_mirror": {"left": "right"}},
    "refonte/terre.png": {"id": "earth", "grid": (256, 256, 0, 0), "gutter": True,
                         "attack_mirror": {"left": "right"}, "attack_recentre": True},
    "refonte/tenebres.png": {"id": "shadow", "grid": (256, 256, 0, 0), "gutter": True,
                         "attack_mirror": {"left": "right"}},
    "refonte/foudre.png": {"id": "thunder", "grid": (256, 256, 0, 0), "gutter": True,
                            "attack_mirror": {"right": "left"}},
    "refonte/air.png": {"id": "air", "grid": (256, 256, 0, 0), "gutter": True,
                        "attack_recentre": True},
    "refonte/supreme.png": {"id": "supreme", "grid": (256, 256, 0, 0), "gutter": True,
                         "attack_mirror": {"left": "right"}},
    # ⚠️ `attack_mirror` : LE PROFIL DESSINÉ NE DIT PAS DANS QUEL SENS PART LE SORT.
    # Le générateur centre la pose d'attaque sur le sort et le lance presque
    # toujours vers la droite : six mages sur huit tiraient dans leur dos sur l'un
    # de leurs profils. La pose est reprise du profil juste, retournée. Mesurable :
    # le sort doit déborder du côté regardé (`check_characters.py`).
    #
    # ⚠️ `attack_recentre` : le rocher de la Terre et le croissant de l'Air sont
    # posés AU SOL à côté du mage, et le calage sur les pieds prend l'ensemble pour
    # le personnage. Le mage sautait d'un quart de case sur le côté à chaque sort.
    #
    # L'Invocateur rejoint la table commune. Son ancienne planche n'avait aucune
    # grille — ses poses étaient posées librement, d'où `build_invocateur.py` et
    # sa découpe par formes connexes. Celle-ci en a une : le mage revient donc
    # ici, et l'outil dédié ne garde que ce que lui seul sait faire — les
    # créatures invoquées et leurs effets.
    "refonte/invocateur.png": {"id": "invocateur", "grid": (256, 256, 0, 0), "gutter": True},
    "creatures/enemi_2.png": {"id": "goblin", "mode": "formes", "out": OUT_ENEMIES},
    # Spectre : tout vient de la RANGÉE 1. La rangée 0 est la même créature avec
    # une couronne de lumière que les poses d'attaque n'ont pas — alterner les
    # deux ferait clignoter la couronne. Colonnes retenues, dans l'ordre des
    # créneaux IDLE / WALK 1-4 / ATTACK : quatre lévitations et une cinquième
    # (col. 7) pour le cycle, puis l'orbe chargée à bout de bras (col. 4). Les
    # colonnes 5 et 6 — projectile déjà parti, portail qui s'ouvre — racontent un
    # tir à distance, que cet ennemi ne fait pas : il frappe au contact.
    "creatures/enemi_1.png": {
        "id": "hunter", "mode": "poses", "out": OUT_ENEMIES,
        "directions": ["down"], "band": 200, "row": 1, "row_shapes": 8,
        "columns": [0, 1, 2, 3, 7, 4],
        # Le spectre n'a pas de profil dessiné : sa vue de gauche est celle de
        # face RETOURNÉE. C'est une bande de plus sur le disque plutôt qu'un
        # `flip_h` en jeu, pour que la planche reste la seule source de vérité —
        # le moteur lit un dossier, il ne devine pas quelle direction retourner.
        # La droite, elle, n'a pas de bande : c'est la face telle quelle, et le
        # repli du moteur s'en charge sans dupliquer un fichier identique.
        "mirror": {"left": "down"},
    },
}

## Les mages passés aux planches de 8 pas et 8 attaques : `build_enemies.py` écrit
## leurs bandes. Comme le gobelin, ils restent mesurés pour la largeur commune.
MAGES_ANIMES = {"fire", "water", "earth", "thunder", "air", "shadow", "invocateur", "supreme",
                "chrono"}

## Une forme connexe plus petite que ça est une poussière du rendu, pas un sprite.
MIN_SHAPE_PIXELS = 300

ALPHA_THRESHOLD = 40


def _pitch(profile: np.ndarray, low: int, high: int) -> int:
    """Pas de la grille : le décalage qui ressemble le plus au profil lui-même."""
    centred = profile.astype(float) - profile.mean()
    correlation = np.correlate(centred, centred, mode="full")[len(centred) - 1:]
    return low + int(np.argmax(correlation[low:high]))


def _phase(profile: np.ndarray, step: int) -> int:
    """Décalage qui pose les lignes de grille là où il n'y a rien."""
    best, best_cost = 0, None
    for offset in range(step):
        cost = profile[np.arange(offset, len(profile), step)].sum()
        if best_cost is None or cost < best_cost:
            best_cost, best = cost, offset
    return best


def _bands(profile: np.ndarray, gap: int, minimum: int) -> list:
    """Plages non vides d'un profil d'opacité, séparées par au moins `gap` vides."""
    out, start, blank = [], None, 0
    for index, value in enumerate(profile):
        if value > 0:
            if start is None:
                start = index
            blank = 0
        elif start is not None:
            blank += 1
            if blank >= gap:
                if index - blank - start >= minimum:
                    out.append((start, index - blank))
                start = None
    if start is not None and len(profile) - start >= minimum:
        out.append((start, len(profile)))
    return out


def detect_grid(alpha: np.ndarray) -> tuple:
    """Pas et origine de la grille de personnages.

    Les RANGÉES sont mesurées directement quand on peut les isoler : on lit où
    commence chacune et de combien elles s'espacent. C'est exact, et c'est
    nécessaire — la phase par gouttière se trompait de ~24 px sur le Feu (les
    cases rognaient les pieds) et d'une rangée entière sur les Ténèbres et l'Eau.

    Les COLONNES et le repli, quand les rangées ne s'isolent pas (Terre,
    Suprême, Foudre : les lueurs se touchent), viennent de l'autocorrélation.
    """
    height, width = alpha.shape
    # On cherche le pas sur la zone des personnages : les panneaux d'effets, à
    # droite et en bas, n'ont aucune régularité et fausseraient l'autocorrélation.
    region = alpha[:int(height * 0.78), :int(width * 0.70)]
    dx = _pitch(region.sum(axis=0), 70, 220)
    dy = _pitch(region.sum(axis=1), 100, 280)
    ox = _phase(alpha[:int(height * 0.78)].sum(axis=0), dx)
    oy = _phase(alpha[:, :int(width * 0.70)].sum(axis=1), dy)

    rows = [r for r in _bands(alpha[:, :int(width * 0.62)].sum(axis=1), 8, 40)
            if r[0] < height * 0.74 and r[1] - r[0] > 60]
    if len(rows) >= 4:
        starts = [r[0] for r in rows[:4]]
        spacings = [starts[i + 1] - starts[i] for i in range(3)]
        dy = int(round(sum(spacings) / 3.0))
        # Une marge : la rangée mesurée commence au premier pixel opaque, la case
        # doit démarrer un peu au-dessus pour ne pas raboter le chapeau.
        oy = max(0, starts[0] - int((dy - (rows[0][1] - rows[0][0])) * 0.5))

        # Les COLONNES, elles, restent sur l'autocorrélation. Un calage par
        # mesure a été essayé et rejeté : la colonne d'étiquettes (« DOWN »,
        # « UP »…) est séparée de la première pose par un écart proche du pas
        # normal, et le calage démarrait donc une case trop à gauche — chaque
        # case contenait alors deux moitiés de mage. La phase par gouttière,
        # elle, tombe juste sur les sept planches (vérifié colonne par colonne).
    return dx, dy, ox, oy


def cell_box(dx: int, dy: int, ox: int, oy: int, col: int, row: int) -> tuple:
    return (ox + col * dx, oy + row * dy, ox + (col + 1) * dx, oy + (row + 1) * dy)


def anchor(mask: np.ndarray) -> tuple:
    """(x du milieu des pieds, y du sol) dans la cellule.

    Toutes les poses sont recalées sur ce point. Les centrer sur leur propre
    boîte englobante ferait sautiller le mage : la cape et le bâton changent de
    largeur à chaque image sans que le corps bouge."""
    rows = np.nonzero(mask.any(axis=1))[0]
    if rows.size == 0:
        return None
    bottom = int(rows[-1])
    feet = mask[max(0, bottom - max(4, mask.shape[0] // 8)):bottom + 1]
    columns = np.nonzero(feet.any(axis=0))[0]
    if columns.size == 0:
        columns = np.nonzero(mask.any(axis=0))[0]
    return float(columns.mean()), float(bottom)


def _cells_by_grid(image: Image.Image, alpha: np.ndarray, config: dict) -> tuple:
    """Boîtes des poses, posées sur la grille régulière de la planche.

    Deux réglages facultatifs, tous deux nés d'une planche réelle :

    `grid` — la grille IMPOSÉE, quand l'autodétection se trompe. Elle cale sa
    phase sur ce qu'elle trouve de plus régulier, et une grande illustration ou
    un pas de plus de 220 px la font mentir sans rien signaler.

    `rows` — quelle RANGÉE porte quelle direction, quand la planche ne les
    dessine pas dans l'ordre attendu, ou qu'il en manque une. La planche du
    Suprême dessine deux profils DROITE et aucun gauche : on lui prend sa
    rangée droite et `mirror` fabrique la gauche.
    """
    imposed = config.get("grid")
    dx, dy, ox, oy = tuple(imposed) if imposed else detect_grid(alpha)
    rows = config.get("rows")
    placement = list(rows.items()) if rows else list(enumerate(DIRECTIONS))
    if not rows:
        placement = [(direction, index) for index, direction in placement]
    boxes = {}
    for direction, row_index in placement:
        for pose_index, pose in enumerate(POSES):
            boxes[(direction, pose)] = cell_box(
                dx, dy, ox, oy, config.get("col0", 0) + pose_index,
                config.get("row0", 0) + row_index)
        if config.get("gutter"):
            # Les cinq séparations sont RELEVÉES sur la rangée, pas déduites de
            # la grille — et elles servent aux deux cases qu'elles séparent.
            col0, row0 = config.get("col0", 0), config.get("row0", 0)
            top = oy + (row0 + row_index) * dy
            lines = [ox + (col0 + i) * dx for i in range(1, len(POSES))]
            cuts = _row_cuts(alpha, top, dy, lines)
            edges = [ox + col0 * dx] + cuts + [alpha.shape[1]]
            for pose_index, pose in enumerate(POSES):
                boxes[(direction, pose)] = (
                    edges[pose_index], top, edges[pose_index + 1], top + dy)
    return boxes, {"dx": dx, "dy": dy, "ox": ox, "oy": oy,
                   "col0": config.get("col0", 0), "row0": config.get("row0", 0)}


## Nombre de gouttières mises en concurrence, les plus larges d'abord. Assez
## pour que les vraies séparations y soient toutes, assez peu pour que l'essai
## de toutes les combinaisons reste instantané.
GUTTER_CANDIDATES = 10


def _row_cuts(alpha: np.ndarray, top: int, dy: int, lines: list) -> list:
    """Les cinq séparations RÉELLES d'une rangée de six poses.

    ⚠️ LA GRILLE ANNONCÉE N'EST PAS CELLE QUI EST DESSINÉE. Les planches de la
    refonte respectent leurs 6 x 4 cases de 256 dans l'ensemble, mais chaque pose
    y flotte : la pose d'attaque déborde de 40 à 125 px dans la case de gauche
    (le générateur la centre sur son SORT et non sur son mage), et une écharpe,
    un éclair ou un pan de cape franchissent régulièrement une ligne.

    Découpées sur les lignes théoriques, ces poses se volent des morceaux : le
    lanceur de sort était rendu à la case voisine et il ne restait dans la case
    d'attaque que la boule de feu (22 % de remplissage sur les Ténèbres) ; un
    éclat d'éclair flottait à côté du Mage de la Foudre, arraché à la pose
    suivante.

    On cherche donc, autour de chaque ligne, la vraie GOUTTIÈRE : une bande vide
    ayant de l'encre des deux côtés. La condition « des deux côtés » distingue
    une séparation d'une marge ; la fenêtre de recherche empêche de confondre la
    gouttière avec le vide qui sépare un mage de son orbe flottante. Sans
    candidat, on garde la ligne — elle est fausse de quelques pixels, jamais de
    cent.
    """
    band = alpha[top:top + dy]
    ink = band.any(axis=0)
    marks = np.nonzero(ink)[0]
    if marks.size < 2:
        return lines

    gutters = []
    x = int(marks[0])
    while x < marks[-1]:
        if ink[x]:
            x += 1
            continue
        start = x
        while x < marks[-1] and not ink[x]:
            x += 1
        gutters.append((start + (x - start) // 2, x - start))

    # ⚠️ NI LA LARGEUR NI LA PROXIMITÉ NE TRANCHENT, et les deux ont été
    # essayées. Sur la rangée de profil des Ténèbres, dont les poses dérivent
    # vers la droite, « la plus large » allait chercher la gouttière de la pose
    # SUIVANTE ; sur sa rangée de dos, « la plus proche » préférait le vide qui
    # sépare le mage de son orbe. Une rangée demandait l'inverse de l'autre.
    #
    # Ce qui tranche est ce qu'on sait de la planche : SIX POSES ÉGALEMENT
    # ESPACÉES. On essaie donc les combinaisons de cinq gouttières et on garde
    # celle qui donne les cases de marche les plus régulières, à largeur de
    # gouttière égale. La case d'attaque est exclue de la mesure de régularité :
    # elle porte le sort en plus du mage et elle est légitimement plus large.
    if len(gutters) < len(lines):
        return lines
    from itertools import combinations
    left = lines[0] - (lines[1] - lines[0] if len(lines) > 1 else 0)
    best, best_score = None, None
    for pick in combinations(sorted(gutters, key=lambda g: -g[1])[:GUTTER_CANDIDATES],
                             len(lines)):
        cuts = sorted(g[0] for g in pick)
        walking = [b - a for a, b in zip([left] + cuts[:-1], cuts)]
        if min(walking) <= 0:
            continue
        score = sum(g[1] for g in pick) - 1.5 * (max(walking) - min(walking))
        if best_score is None or score > best_score:
            best, best_score = cuts, score
    return best if best else lines

def _cells_by_rows(image: Image.Image, alpha: np.ndarray, config: dict) -> tuple:
    """Boîtes quand chaque RANGÉE est une orientation, désignée à la main.

    Les planches du bestiaire suivent une convention régulière — r0 de face,
    r1 de dos, r2 de profil, r3 les poses d'attaque — mais pas celle des mages :
    la quatrième rangée n'est pas la quatrième orientation, c'est le coup. Le
    profil sert donc aux deux côtés, retourné.

    On ne devine pas ces rangées : elles sont ÉCRITES dans la table. Une
    détection qui se tromperait de rangée donnerait un monstre qui marche de dos
    en avançant vers le joueur — un défaut qu'on ne voit qu'en jouant.
    """
    # Grille IMPOSÉE quand la détection se trompe. Elle se trompe rarement, mais
    # quand elle se trompe c'est d'un facteur : elle mesure un pas de deux
    # rangées et découpe alors une créature en deux moitiés empilées — un demi
    # monstre en haut de la case, l'autre en bas. Aucun réglage automatique ne
    # rattrape ça ; on écrit les quatre nombres.
    imposed = config.get("grid")
    dx, dy, ox, oy = tuple(imposed) if imposed else detect_grid(alpha)
    col0 = config.get("col0", 0)
    attack = config["attack"]
    boxes = {}
    for direction, row in config["rows"].items():
        for pose_index, pose in enumerate(POSES):
            if pose == POSES[-1]:
                boxes[(direction, pose)] = cell_box(
                    dx, dy, ox, oy, attack["col"], attack["row"])
                continue
            boxes[(direction, pose)] = cell_box(
                dx, dy, ox, oy, col0 + pose_index, row)
    return boxes, {"dx": dx, "dy": dy, "ox": ox, "oy": oy, "rows": config["rows"]}


def _shape_rows(alpha: np.ndarray, band: float) -> dict:
    """Formes connexes de la planche, groupées par rangée et triées de gauche à droite.

    La rangée se lit au CENTRE de la boîte et non à son sommet : les poses
    d'attaque, plus hautes que les autres, mordent sur la bande voisine."""
    from scipy import ndimage
    labels, _ = ndimage.label(alpha, structure=np.ones((3, 3)))
    found = []
    for index, slices in enumerate(ndimage.find_objects(labels)):
        if int((labels[slices] == index + 1).sum()) < MIN_SHAPE_PIXELS:
            continue
        found.append((slices[1].start, slices[0].start, slices[1].stop, slices[0].stop))

    # Une forme ENTIÈREMENT CONTENUE dans la boîte d'une autre est un morceau de
    # celle-ci — un poing que l'anti-aliasing a détaché du bras — et non une pose.
    # On la laisse tomber : la découpe se fait sur la boîte, elle y est déjà.
    found.sort(key=lambda b: (b[2] - b[0]) * (b[3] - b[1]), reverse=True)
    kept = []
    for box in found:
        if not any(box[0] >= k[0] and box[1] >= k[1] and box[2] <= k[2] and box[3] <= k[3]
                   for k in kept):
            kept.append(box)

    rows = {}
    for box in kept:
        rows.setdefault(int((box[1] + box[3]) * 0.5 / band), []).append(box)
    for row in rows.values():
        row.sort(key=lambda b: b[0])
    return rows


def _cells_by_shapes(image: Image.Image, alpha: np.ndarray, config: dict) -> tuple:
    """Boîtes des 4 x 6 poses, une par forme connexe.

    Pour les planches dont les poses sont rangées mais pas régulièrement espacées."""
    rows = _shape_rows(alpha, alpha.shape[0] / float(len(DIRECTIONS)))

    # Vérification et non supposition : une planche mal comptée produit une
    # animation décalée d'une pose, ce qui ne se voit qu'en jeu et de loin.
    counts = [len(rows.get(index, [])) for index in range(len(DIRECTIONS))]
    if counts != [len(POSES)] * len(DIRECTIONS):
        raise RuntimeError(f"{config['id']} : {counts} formes par rangée, "
                           f"attendu {len(POSES)} sur {len(DIRECTIONS)} rangées")

    boxes = {}
    for row_index, direction in enumerate(DIRECTIONS):
        for pose_index, box in enumerate(rows[row_index]):
            boxes[(direction, POSES[pose_index])] = box
    return boxes, None


def _cells_by_poses(image: Image.Image, alpha: np.ndarray, config: dict) -> tuple:
    """Boîtes désignées une à une, pour une planche à orientation unique.

    Aucune régularité à exploiter ici : la planche mélange des poses de la
    créature et un panneau d'effets. La table SHEETS dit quelle rangée lire et
    quelle colonne remplit quel créneau ; on vérifie seulement que la rangée
    contient bien le nombre de formes annoncé, sinon les colonnes désignent
    autre chose que ce qu'on croit."""
    rows = _shape_rows(alpha, float(config["band"]))
    row = rows.get(config["row"], [])
    if len(row) != config["row_shapes"]:
        raise RuntimeError(f"{config['id']} : rangée {config['row']} a {len(row)} formes, "
                           f"attendu {config['row_shapes']}")
    columns = config["columns"]
    if len(columns) != len(POSES):
        raise RuntimeError(f"{config['id']} : {len(columns)} colonnes pour {len(POSES)} poses")
    direction = config["directions"][0]
    return {(direction, POSES[i]): row[c] for i, c in enumerate(columns)}, None


## Part d'une forme qui doit se trouver DANS la case pour qu'on la garde même
## quand son centre est ailleurs. En dessous, c'est la pose voisine qui déborde.
BLEED_SHARE = 0.5
## Marge laissée autour du contenu dans la case finale, en pixels de sortie.
CELL_PADDING = 8
## Débordement récupéré au-delà de la boîte de grille, en pixels de planche.
## Les lignes de grille de ces planches TRANCHENT les dessins : la boule de feu
## du mage du Feu, les capes de la Foudre, le halo de l'Air continuent sur la
## case voisine. Couper à la boîte laissait des bords droits en pleine chair.
## 64 et pas moins : mesuré, les poses d'attaque de la Terre et de la Foudre
## poussent leur bâton jusqu'à 61 px au-delà de leur case.
CLAIM_OVERHANG = 64
## En dessous, un pixel est du bruit de fond ; au-delà, il doit se justifier.
FAINT_ALPHA = 12


def _claim_cell(image: Image.Image, labels: np.ndarray, sizes: np.ndarray,
                centres: list, box: tuple) -> Image.Image:
    """Découpe une case ÉLARGIE et n'y garde que ce qui appartient à la pose.

    Trois sorts possibles pour chaque forme connexe de la fenêtre élargie :
      possédée  — son centre tombe dans la boîte de grille : gardée EN ENTIER,
                  y compris ce qui dépasse la ligne. C'est la récupération des
                  membres tranchés.
      partagée  — centre ailleurs mais au moins la moitié de ses pixels ici
                  (une plaque à cheval sur deux poses d'attaque) : gardée mais
                  CLIPPÉE à la boîte de grille, comme avant. Ni régression, ni
                  morceau du voisin rapatrié.
      étrangère — tout le reste : effacée. C'est le débordement du voisin.

    On ne peut pas jeter tout ce qui n'est pas la forme principale : le bâton du
    mage de l'Eau et les feuilles du mage de la Terre sont détachés du corps et
    parfaitement légitimes — leur centre est dans la case, ils sont possédés.
    """
    x0, y0, x1, y1 = box
    ex0, ey0 = max(0, x0 - CLAIM_OVERHANG), max(0, y0 - CLAIM_OVERHANG)
    ex1 = min(labels.shape[1], x1 + CLAIM_OVERHANG)
    ey1 = min(labels.shape[0], y1 + CLAIM_OVERHANG)
    window = labels[ey0:ey1, ex0:ex1]
    pixels = np.array(image.crop((ex0, ey0, ex1, ey1)))

    core = np.zeros(window.shape, bool)
    core[y0 - ey0:y1 - ey0, x0 - ex0:x1 - ex0] = True
    core_content = int((window[core] > 0).sum())

    for label in np.unique(window):
        if label == 0:
            continue
        centre_y, centre_x = centres[label - 1]
        owned = x0 <= centre_x < x1 and y0 <= centre_y < y1
        member = window == label
        if owned:
            # Possédée, mais fusionnée avec la pose d'à côté ? Si plus du tiers
            # de ses pixels VISIBLES ici sont hors case, c'est qu'elle traîne un
            # morceau de voisine (cas des plaques soudées) : on clippe à la
            # grille. Un simple débordement de membre — bâton, flamme — reste
            # bien en dessous de ce seuil et est gardé entier.
            outside = int((member & ~core).sum())
            if outside > (inside_owned := int((member & core).sum())) * 0.5:
                pixels[..., 3][member & ~core] = 0
            continue
        inside = int((member & core).sum())
        # Deux façons d'être « partagée » : porter ici au moins la moitié de ses
        # propres pixels, OU constituer l'essentiel du contenu de la case. La
        # seconde règle sauve la pose dont le corps fusionne avec la voisine
        # (les plaques d'attaque du Suprême se touchent verticalement : une
        # seule forme pour deux poses, et son centre ne peut être que dans une
        # des deux cases — sans cette règle, l'autre case sortait VIDE).
        if inside >= sizes[label - 1] * BLEED_SHARE or inside >= core_content * 0.5:
            pixels[..., 3][member & ~core] = 0
        else:
            pixels[..., 3][member] = 0

    # Reste le PRESQUE-INVISIBLE : les gouttières de certaines planches (Foudre,
    # Air) sont parsemées de volutes décoratives sous le seuil d'étiquetage —
    # trop transparentes pour être des formes, assez pour se voir en jeu. Règle :
    # un pixel translucide ne survit que rattaché à un noyau opaque conservé.
    # Le halo d'un sprite y est rattaché ; une volute qui flotte ne l'est pas.
    from scipy import ndimage
    soft = pixels[..., 3] > FAINT_ALPHA
    parts, _ = ndimage.label(soft, structure=np.ones((3, 3)))
    anchored = np.unique(parts[pixels[..., 3] > ALPHA_THRESHOLD])
    pixels[..., 3][~np.isin(parts, anchored[anchored > 0])] = 0
    return Image.fromarray(pixels, "RGBA")


## Écart au fond en deçà duquel un pixel EST le fond, et au-delà duquel il est
## franchement le dessin. Entre les deux, le bord anti-crénelé, dont l'alpha se
## dose — sans quoi la silhouette sort en escalier.
KEY_IN = 4
KEY_OUT = 26
## Écart au fond en deçà duquel le fond COULE, de proche en proche, depuis les
## bords de la planche. Serré exprès — voir la note dans `keyed_on_flat`.
KEY_FLOOD = 8
## Surface minimale d'une forme, en pixels de la PLANCHE. En dessous, c'est de
## la poussière de détourage et non un morceau du dessin.
KEY_MIN_SHAPE = 600


def keyed_on_flat(image: Image.Image) -> Image.Image:
    """Détoure une planche livrée SANS transparence, sur son fond uni.

    ⚠️ Les planches de la refonte arrivent en RGB sur un gris très foncé — c'est
    ce que le prompt demande, un fond uni se relisant mieux qu'un alpha que les
    modèles d'image tiennent mal. Converties en RGBA, elles sont donc opaques
    d'un bord à l'autre : le découpage rendait huit carrés gris parfaitement
    identiques, et la mesure de « remplissage » annonçait fièrement 78 % pour
    tout le monde. Un défaut qui se félicite lui-même est le pire de tous.

    Le fond n'est retiré que là où il TOUCHE LE BORD de la planche, de proche en
    proche. Une pénombre au creux d'une capuche a beau avoir la couleur du fond,
    elle n'y est pas reliée : elle reste.
    """
    from scipy import ndimage
    rgb = np.asarray(image.convert("RGB")).astype(int)
    border = np.concatenate([rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]])
    background = np.median(border, axis=0)

    distance = np.abs(rgb - background).max(axis=2)

    # ⚠️ LE SEUIL EST SERRÉ, ET C'EST LA CONNEXITÉ QUI TRAVAILLE. Le Sorcier des
    # Ténèbres, vu de dos, est une robe NOIRE sur un gris très foncé : un quart
    # de ses pixels sont à une distance de 2 ou 3 du fond, c'est-à-dire dans le
    # bruit de la planche (p99 = 2). Aucune clé par couleur ne peut les
    # distinguer, et un seuil confortable de 30 lui mangeait les trois quarts du
    # corps — il ne restait qu'une capuche violette et une orbe flottante.
    #
    # Le seuil ne sert donc qu'à FAIRE COULER le fond depuis les bords. Ce qui
    # est de la couleur du fond mais enfermé dans une silhouette n'est pas
    # atteint : le contour du personnage, lui, s'écarte franchement du gris, et
    # il suffit à faire barrage.
    flat = distance < KEY_FLOOD
    parts, _ = ndimage.label(flat)
    edges = np.unique(np.concatenate([parts[0], parts[-1], parts[:, 0], parts[:, -1]]))
    outside = np.isin(parts, edges[edges > 0])

    # Le fondu du bord ne s'applique qu'AU BORD. Appliqué partout, il rendait
    # translucide l'intérieur d'une robe sombre — le même défaut, en plus discret.
    alpha = np.full(distance.shape, 255.0)
    alpha[outside] = 0.0
    rim = ndimage.binary_dilation(outside, iterations=2) & ~outside
    alpha[rim] = np.clip((distance[rim] - KEY_IN) / float(KEY_OUT - KEY_IN),
                         0.0, 1.0) * 255.0

    # LA POUSSIÈRE PART. Ce que la clé laisse d'une ombre portée, d'une étincelle
    # ou d'un grain de compression, ce sont des taches de quelques pixels qui
    # deviennent des points sales à côté du mage — mesuré : jusqu'à quarante par
    # pose sur la planche du Suprême. Les orbes qui gravitent autour de lui, elles,
    # pèsent plus de mille pixels et ne risquent rien.
    kept, _ = ndimage.label(alpha > ALPHA_THRESHOLD)
    if kept.max():
        areas = ndimage.sum(np.ones_like(kept), kept, range(1, kept.max() + 1))
        dust = np.zeros(kept.max() + 1, dtype=bool)
        dust[1:] = areas < KEY_MIN_SHAPE
        alpha[dust[kept]] = 0.0

    data = np.dstack([rgb.astype(np.uint8), alpha.astype(np.uint8)])
    return Image.fromarray(data, "RGBA")


def measure(path: Path, config: dict) -> dict:
    """Découpe et nettoie une planche, sans encore décider de la taille de case.

    La case, elle, est COMMUNE à tous les personnages et ne peut donc être
    arrêtée qu'une fois toutes les planches mesurées (voir main)."""
    from scipy import ndimage
    image = Image.open(SOURCE / path)
    # Une planche sans canal alpha est une planche à détourer : voir plus haut.
    image = keyed_on_flat(image) if image.mode != "RGBA" else image.convert("RGBA")
    mask = np.array(image)[..., 3] > ALPHA_THRESHOLD
    finder = {"formes": _cells_by_shapes, "poses": _cells_by_poses,
              "rangees": _cells_by_rows}.get(
        config.get("mode"), _cells_by_grid)
    boxes, grid = finder(image, mask, config)

    labels, count = ndimage.label(mask, structure=np.ones((3, 3)))
    ones = np.ones_like(labels)
    sizes = ndimage.sum(ones, labels, range(1, count + 1))
    centres = ndimage.center_of_mass(ones, labels, range(1, count + 1))

    cells, extents = {}, []
    for key, box in boxes.items():
        crop = _claim_cell(image, labels, sizes, centres, box)
        point = anchor(np.array(crop)[..., 3] > ALPHA_THRESHOLD)
        if point is None:
            continue
        cells[key] = (crop, point)
        extents.append((point[0], crop.width - point[0], point[1]))

    if not extents:
        raise RuntimeError(f"{path} : aucune pose détectée")

    # Demi-largeur : le personnage est CENTRÉ sur son ancre, donc la case doit
    # tenir le plus grand débordement, à gauche comme à droite. Une case
    # symétrique se retourne aussi sans rien couper — c'est ce qui manquait au
    # miroir du spectre, dont la pose de gauche sortait de la case.
    half = max(max(e[0] for e in extents), max(e[1] for e in extents))
    height = int(max(e[2] for e in extents)) + 10
    return {
        "cells": cells,
        "grid": grid,
        "half": half,
        "height": height,
        # Chaque personnage garde SA réduction verticale : elle fixe sa taille
        # apparente en jeu, et l'uniformisation ne porte que sur le cadre.
        "scale": FRAME_HEIGHT / float(height),
        "directions": config.get("directions", DIRECTIONS),
        "mirrors": config.get("mirror", {}),
        "source": path.name,
    }


def _attack_recentred(strip: Image.Image, cell_width: int) -> Image.Image:
    """La pose d'attaque ramenée sur le corps de la pose de repos.

    Le décalage est celui qui superpose le mieux les deux silhouettes. Le haut du
    corps seul : le bas de l'attaque porte le sort, posé au sol.
    """
    alpha = np.asarray(strip)[..., 3] > 120
    height = int(FRAME_HEIGHT * 0.72)
    attack_index = POSES.index("attack")
    idle = alpha[:height, :cell_width]
    attack = alpha[:height, attack_index * cell_width:(attack_index + 1) * cell_width]
    limit = cell_width // 4
    shift = max(range(-limit, limit + 1),
                key=lambda dx: int((idle & np.roll(attack, dx, axis=1)).sum()))
    box = (attack_index * cell_width, 0, (attack_index + 1) * cell_width, FRAME_HEIGHT)
    cell = strip.crop(box)
    out = strip.copy()
    out.paste((0, 0, 0, 0), box)
    out.paste(cell, (box[0] + shift, 0))
    return out


def write(config: dict, measured: dict, cell_width: int) -> dict:
    """Écrit les bandes d'un personnage dans la case commune."""
    scale = measured["scale"]
    # Largeur de travail : celle qui donnera EXACTEMENT `cell_width` après
    # réduction. La calculer à l'envers est ce qui évite de déformer — réduire
    # une case trop large vers une case étroite écraserait le personnage.
    source_width = int(round(cell_width / scale))
    source = (source_width, measured["height"])
    centre_x = source_width * 0.5

    out_dir = config.get("out", OUT) / config["id"]
    out_dir.mkdir(parents=True, exist_ok=True)
    # Les miroirs viennent APRÈS les directions dessinées, et dans l'ordre : le
    # descripteur les liste comme les autres, le moteur ne fait pas la différence.
    mirrors: dict = measured["mirrors"]
    for direction in measured["directions"] + list(mirrors):
        source_direction = mirrors.get(direction, direction)
        strip = Image.new("RGBA", (source[0] * len(POSES), source[1]), (0, 0, 0, 0))
        for pose_index, pose in enumerate(POSES):
            flipped = direction in mirrors
            if pose == "attack" and direction in config.get("attack_mirror", {}):
                source_direction = config["attack_mirror"][direction]
                flipped = True
            entry = measured["cells"].get((source_direction, pose))
            if entry is None:
                continue
            crop, (ax, ay) = entry
            if flipped:
                # Chaque pose est retournée SÉPARÉMENT, et son ancre avec elle.
                # Retourner la bande entière inverserait l'ordre des poses, et
                # oublier l'ancre décalerait le personnage d'un demi-corps.
                crop = crop.transpose(Image.FLIP_LEFT_RIGHT)
                ax = crop.width - ax
            x = int(pose_index * source[0] + centre_x - ax)
            y = int(source[1] - 5 - ay)
            strip.alpha_composite(crop, (x, y))
        strip = strip.resize((cell_width * len(POSES), FRAME_HEIGHT), Image.LANCZOS)
        if config.get("attack_recentre"):
            strip = _attack_recentred(strip, cell_width)
        strip.save(out_dir / f"{direction}.png")

    meta = {
        "cell": [cell_width, FRAME_HEIGHT],
        "feet_y": round(FRAME_HEIGHT - 5 * scale, 1),
        "poses": POSES,
        "directions": measured["directions"] + list(mirrors),
        "source": measured["source"],
    }
    if measured["grid"] is not None:
        meta["grid"] = measured["grid"]
    (out_dir / "frames.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")
    return meta


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    # DEUX PASSES, et c'est le point important : la case est COMMUNE à tous les
    # personnages. Une case par planche donnait des bandes de 702 à 948 px de
    # large — le moteur s'en accommode, mais rien ne se compare plus à l'œil, et
    # la moindre vérification demande de rouvrir un descripteur.
    measured = {}
    for name, config in SHEETS.items():
        if not (SOURCE / name).exists():
            print(f"  ! {name} introuvable")
            continue
        measured[name] = measure(Path(name), config)

    if not measured:
        return

    # La case doit tenir le plus large de tous, APRÈS réduction — c'est en
    # pixels de sortie que la largeur est commune, pas en pixels de planche.
    half = max(m["half"] * m["scale"] for m in measured.values())
    cell_width = 2 * int(np.ceil(half)) + CELL_PADDING

    for name, entry in measured.items():
        config = SHEETS[name]
        # ⚠️ Le gobelin et le spectre restent MESURÉS, car ils fixent la largeur de
        # case commune, mais leurs bandes viennent désormais de `build_enemies.py`.
        # Les réécrire ici les ramènerait à six poses sans aucune erreur.
        if config.get("out") is OUT_ENEMIES or config["id"] in MAGES_ANIMES:
            continue
        meta = write(config, entry, cell_width)
        grid = meta.get("grid")
        detail = f"grille dx={grid['dx']} dy={grid['dy']} ox={grid['ox']} oy={grid['oy']}" \
            if grid is not None else \
            ("poses désignées à la main" if config.get("mode") == "poses"
             else "découpe par formes connexes")
        print(f"{config['id']:8s} bande {meta['cell'][0] * len(POSES)}x{FRAME_HEIGHT}  {detail}")
    print(f"case commune {cell_width}x{FRAME_HEIGHT}")


if __name__ == "__main__":
    main()
