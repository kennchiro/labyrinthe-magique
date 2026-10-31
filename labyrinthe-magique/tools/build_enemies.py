#!/usr/bin/env python3
"""Les ennemis REDESSINÉS : huit pas et huit poses de coup, par direction.

    tools/.venv/bin/python tools/build_enemies.py            # DEPUIS LA RACINE
    tools/.venv/bin/python tools/build_enemies.py spectre    # une seule bête

POURQUOI UN OUTIL DE PLUS

`build_characters.py` et `build_bestiary.py` découpent des planches TROUVÉES :
des illustrations livrées sans grille, dont il faut deviner le pas, rattraper
les débordements et retrouver les pieds. Tout leur code sert à ça.

Ces planches-ci sont COMMANDÉES. Elles ont une grille régulière, un fond magenta
uni et un nombre de cases connu d'avance — les mêmes règles que les planches de
sorts. Il n'y a donc rien à deviner, et il ne faut surtout pas faire semblant :
la détection de grille sur une planche déjà régulière est un risque pur.

CE QUE CHAQUE BÊTE ATTEND

    <id>_marche.png    8 colonnes x 3 rangées   face / dos / profil DROIT
    <id>_attaque.png   8 colonnes x 3 rangées   face / dos / profil DROIT

La gauche est le MIROIR du profil droit, jamais un second dessin : deux dessins
donneraient deux démarches, et c'est exactement le défaut qui a fait marcher
sept créatures à reculons pendant des semaines (voir `build_bestiary.py`).

SORTIE, dans `assets/enemies/<id>/` :

    down.png  up.png  left.png  right.png     une bande de 17 poses chacune
    frames.json                                idle, walk_1..8, attack_1..8

⚠️ DIX-SEPT ET NON SEIZE. La première case de la bande est l'IDLE, et c'est une
COPIE du premier pas. Le moteur a besoin d'une pose d'arrêt distincte ; la
demander au dessinateur aurait été une case de plus à faire coïncider avec le
cycle, pour rien — un monstre à l'arrêt sur son pas de contact est juste.

LA CASE EST COMMUNE À LA BÊTE, ET CALÉE SUR LES PIEDS. Les seize poses d'une
même créature sont mesurées ensemble : si chacune était recadrée sur sa propre
silhouette, le monstre grandirait et rapetisserait d'une image à l'autre, et il
flotterait — c'est le calage sur les pieds qui le pose au sol.
"""

from pathlib import Path
import json
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

import numpy as np
from PIL import Image
from scipy import ndimage

SOURCE = Path("assets/peso&cover/creatures")
OUT = Path("assets/enemies")

## Hauteur d'une case dans les bandes finales, comme pour les mages : le jeu
## affiche l'ennemi autour de 50 px, 112 laisse de la marge sans gonfler.
FRAME_HEIGHT = 112
## Marge autour de la silhouette dans la case commune.
CELL_PADDING = 8

COLUMNS = 8
## Pixels retirés sur chaque bord de case avant tout traitement.
##
## TROIS, et c'est un rabot, pas un réglage fin. Une planche livrée portait des
## TRAITS DE GRILLE blancs sur les bords de ses cases — interdits par le prompt,
## mais dessinés quand même. Larges d'un à deux pixels, ils survivaient au
## détourage (du blanc, aussi loin du magenta que possible) et devenaient la
## matière la plus extérieure de chaque case : la boîte englobante prenait la
## case ENTIÈRE, la créature était mesurée sur un carré, et chaque sprite
## emportait ses quatre traits.
##
## Trois pixels sur 256 sont invisibles — la consigne veut la créature à 80 % de
## la case et rien qui déborde — et coupent le mal à la racine, sur toutes les
## planches, sans avoir à détecter quoi que ce soit.
BORDER_TRIM = 3
## Ordre des rangées dans les deux planches. Le profil est dessiné à DROITE ;
## la gauche en est le miroir.
ROWS = ["down", "up", "right"]

## Les bêtes commandées. Une ligne par créature, et rien d'autre à écrire :
## l'identifiant doit être celui du dossier existant dans `assets/enemies/`,
## sans quoi le jeu chargerait toujours l'ancienne planche.
## ⚠️ La clé est le PRÉFIXE DES PLANCHES, la valeur porte le dossier de jeu. Les
## deux diffèrent souvent — le Spectre se dessine sous « spectre » et se joue
## sous « hunter » — et se tromper de colonne écrirait la nouvelle bête dans le
## dossier d'une autre : le jeu chargerait un Minotaure à la place d'un Gobelin.
HERD = {
    "spectre": {"id": "hunter", "name": "Spectre Violet"},
    "serpent": {"id": "serpent", "name": "Serpent d'Émeraude"},
    "ombre": {"id": "ombre", "name": "Ombre Encapuchonnée"},
    "dragonnet": {"id": "dragonnet", "name": "Dragonnet de Feu"},
    "golem_lave": {"id": "golem", "name": "Golem de Lave"},
    "archer_os": {"id": "archer", "name": "Archer d'Os"},
    "demon_cristal": {"id": "cristal", "name": "Démon de Cristal",
                      "keep_enclosed": True},
    "minotaure": {"id": "minotaure", "name": "Minotaure"},
    "chevalier_noir": {"id": "chevalier", "name": "Chevalier Noir"},
    "golem_givre": {"id": "givre", "name": "Golem de Givre"},
    "gobelin": {"id": "goblin", "name": "Gobelin"},
}


## Les mages ANIMÉS passent par le même découpage : même gabarit, mêmes contrôles.
## Ajouter un mage ici le retire de `build_characters.py` (`MAGES_ANIMES`).
MAGES_SOURCE = Path("assets/peso&cover/mages")
MAGES_OUT = Path("assets/characters")
MAGES = {
    "feu": {"id": "fire", "name": "Mage du Feu", "source": MAGES_SOURCE,
            "out": MAGES_OUT, "walks": True, "align_rows": True},
    "eau": {"id": "water", "name": "Mage de l'Eau", "source": MAGES_SOURCE,
            "out": MAGES_OUT, "walks": True, "align_rows": True},
    "terre": {"id": "earth", "name": "Mage de la Terre", "source": MAGES_SOURCE,
            "out": MAGES_OUT, "walks": True, "align_rows": True},
    "foudre": {"id": "thunder", "name": "Mage de la Foudre", "source": MAGES_SOURCE,
            "out": MAGES_OUT, "walks": True, "align_rows": True},
    "air": {"id": "air", "name": "Mage de l'Air", "source": MAGES_SOURCE,
            "out": MAGES_OUT, "walks": True, "align_rows": True},
    "tenebres": {"id": "shadow", "name": "Sorcier des Ténèbres", "source": MAGES_SOURCE,
            "out": MAGES_OUT, "walks": True, "align_rows": True},
    "invocateur": {"id": "invocateur", "name": "Invocateur", "source": MAGES_SOURCE,
            "out": MAGES_OUT, "walks": True, "align_rows": True},
    # ⚠️ Le Suprême garde son ANCIENNE marche, choisie par le joueur : avec le guide, ses
    # pieds s'écartent trop, dans les trois rangées (de 40 à 134 de dos).
    "supreme": {"id": "supreme", "name": "Sorcier Suprême", "source": MAGES_SOURCE,
                "out": MAGES_OUT, "walks": True, "align_rows": True,
                "walk_sheet": "supreme_marche_ancien.png"},
}


## Distance au fond MESURÉ en deçà de laquelle un pixel est du fond.
##
## 70, et c'est mesuré, pas choisi : sur les planches livrées le fond occupe la
## bande 20-60, et la lueur des yeux du Spectre est à 164 en moyenne. Il y a de
## la place entre les deux — mais pas beaucoup, d'où un seuil et non une règle
## de teinte.
KEY_DISTANCE = 70.0
## Au-delà de cette distance, un pixel magenta est de la MATIÈRE et on n'y
## touche pas. Entre les deux, c'est la frange d'anticrénelage du découpage.
FRINGE_DISTANCE = 140.0
## Une zone enclavée s'écartant en moyenne de plus que ça du fond est de la
## MATIÈRE couleur de fond, pas un trou. Mesuré sur le Démon de Cristal : les vrais
## trous valent 14 à 21, le cœur 30 à 45.
ENCLOSED_MATTER = 25.0
## Marge autour de cette matière, à l'abri du dégorgement de la frange.
ENCLOSED_MARGIN = 4


def keyed(cell: Image.Image, keep_enclosed: bool = False) -> Image.Image:
    """La case détourée, fond magenta retiré où qu'il soit.

    ⚠️ CE DÉTOURAGE A ÉTÉ REFAIT, et la raison mérite d'être écrite.

    La première version jugeait la TEINTE : « rouge et bleu forts, vert faible,
    donc du fond ». Elle a effacé LES YEUX DU SPECTRE, qui sont un magenta clair
    — exactement le piège déjà rencontré sur les cristaux roses des planches de
    terrain, où les cristaux étaient PLUS magenta que le fond. Une créature peut
    légitimement porter la couleur du fond ; sa teinte ne peut donc pas suffire
    à la condamner.

    Ce qui tranche, c'est la DISTANCE au fond réellement mesuré dans les coins.
    Le fond est uni : il forme un pic serré. La matière, même magenta, en est
    loin.

    Le dégorgement, lui, est CONFINÉ à la frange : appliqué partout comme sur
    les planches de sorts, il aurait fait pâlir les mêmes yeux, plus doucement.

    ⚠️ CE QU'IL NE SAIT PAS FAIRE : une ombre portée dessinée sur le fond. Un
    magenta assombri est à 196 du fond — aussi loin que de la matière — et rien
    ne les distingue. C'est pourquoi les prompts l'interdisent : ce défaut-là se
    corrige au dessin, jamais au découpage.

    ⚠️ `keep_enclosed`, pour la bête qui porte le magenta du fond sur elle : le
    cœur du Démon de Cristal partait au détourage et lui laissait un trou dans la
    poitrine. Réservé à ceux qui le déclarent dans `HERD` : le seuil est réglé sur
    ce cœur-là, et ailleurs il reboucherait de vrais trous.
    """
    pixels = np.asarray(cell.convert("RGB")).astype(np.float32)
    height, width = pixels.shape[:2]
    corner = max(4, min(height, width) // 24)
    corners = np.concatenate([
        pixels[:corner, :corner].reshape(-1, 3),
        pixels[:corner, -corner:].reshape(-1, 3),
        pixels[-corner:, :corner].reshape(-1, 3),
        pixels[-corner:, -corner:].reshape(-1, 3),
    ])
    background = np.median(corners, axis=0)
    away = np.sqrt(((pixels - background) ** 2).sum(axis=2))

    data = np.array(cell.convert("RGBA"))
    data[..., 3] = np.where(away < KEY_DISTANCE, 0, 255)

    # LA FRANGE, et elle seule. Le bord d'un dessin posé sur du magenta est un
    # dégradé vers le magenta : trop loin du fond pour être effacé, assez proche
    # pour se voir en liseré rose. On l'efface d'autant qu'il est magenta.
    rgb = data[..., :3].astype(np.float32)
    magentaness = np.clip(
        (np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1]) / (0.35 * 255.0),
        0.0, 1.0)
    fringe = (away >= KEY_DISTANCE) & (away < FRINGE_DISTANCE)
    spill = np.where(fringe, magentaness, 0.0)
    kept = np.zeros_like(fringe)
    if keep_enclosed:
        labels, count = ndimage.label(away < KEY_DISTANCE)
        outside = np.unique(np.concatenate(
            [labels[0], labels[-1], labels[:, 0], labels[:, -1]]))
        for piece in range(1, count + 1):
            mask = labels == piece
            if piece not in outside and away[mask].mean() >= ENCLOSED_MATTER:
                kept |= mask
        spill = np.where(ndimage.binary_dilation(kept, iterations=ENCLOSED_MARGIN),
                         0.0, spill)
    data[..., 3] = (data[..., 3].astype(np.float32)
                    * (1.0 - spill)).astype(np.uint8)
    data[..., 3] = np.where(kept, 255, data[..., 3])
    return Image.fromarray(data, "RGBA")


## Un morceau qui touche le bord HAUT de la case et qui n'est pas le corps de la
## bête est du débordement de la case du dessus. Les planches l'interdisent, et
## il arrive quand même : une massue levée trop haut dépasse dans la rangée
## voisine, et sa pointe reste accrochée en haut de la case d'à côté.
##
## On ne nettoie ici QUE le haut. Le bas porte de la poussière et des éclats
## légitimes, les côtés portent les traînées de coup — y toucher coûterait du
## dessin, sauf preuve de débordement : voir `without_side_bleed`. Le haut, lui,
## doit être vide : la consigne veut la créature centrée sur 80 % de la case.
##
## Sous cette part de bruit, un morceau est de la poussière de détourage.
SPECK_SHARE = 0.0005


def deblorded(cell: Image.Image) -> Image.Image:
    """La case débarrassée de ce qui a débordé de sa voisine du dessus."""
    alpha = np.asarray(cell)[..., 3] > 24
    if not alpha.any():
        return cell
    labels, count = ndimage.label(alpha)
    if count <= 1:
        return cell
    sizes = ndimage.sum(alpha, labels, range(1, count + 1))
    biggest = int(np.argmax(sizes)) + 1
    doomed = np.zeros_like(alpha)
    for piece in range(1, count + 1):
        if piece == biggest:
            continue
        mask = labels == piece
        touches_top = mask[0].any()
        speck = sizes[piece - 1] < alpha.size * SPECK_SHARE
        if touches_top or speck:
            doomed |= mask
    if not doomed.any():
        return cell
    data = np.array(cell)
    data[..., 3] = np.where(doomed, 0, data[..., 3])
    return Image.fromarray(data, "RGBA")


## Écart toléré, en pixels, entre les deux moitiés d'une forme coupée par la
## frontière de deux cases : le rabot de `BORDER_TRIM` en a retiré une tranche.
BLEED_ROW_SLACK = 3


def without_side_bleed(line: list) -> list:
    """La rangée débarrassée de ce qui a débordé des voisines de GAUCHE et de DROITE.

    ⚠️ Un morceau détaché au bord de la case ne suffit pas à le condamner : la
    boule du Golem de Lave en est un, et elle est légitime. Ce qui le condamne,
    c'est que la matière CONTINUE de l'autre côté de la frontière. La flamme du
    Dragonnet laissait ainsi une tranche dans la case suivante, et ses ailes
    ouvertes une pointe de chaque côté.

    ⚠️ Une flèche en plein vol, elle, n'appartient au corps d'aucune des deux
    cases. La condamner des deux côtés la ferait disparaître : on garde alors sa
    plus grande moitié.
    """
    alphas = [np.asarray(cell)[..., 3] > 24 for cell in line]
    parts = []
    for alpha in alphas:
        labels, count = ndimage.label(alpha)
        sizes = ndimage.sum(alpha, labels, range(1, count + 1)) if count else []
        parts.append((labels, count, np.asarray(sizes),
                      int(np.argmax(sizes)) + 1 if count else 0))

    def belongs_across(own_edge, own_size, other) -> bool:
        """Ce bord continue-t-il dans une forme qui a plus de droits que lui ?"""
        if not own_edge[0].any():
            return False
        reach = ndimage.binary_dilation(own_edge[0], iterations=BLEED_ROW_SLACK)
        labels, _, sizes, biggest = other
        for found in np.unique(labels[:, own_edge[1]][reach]):
            if found and (found == biggest or sizes[found - 1] > own_size):
                return True
        return False

    cleaned = []
    for index, cell in enumerate(line):
        alpha = alphas[index]
        labels, count, sizes, biggest = parts[index]
        if count <= 1:
            cleaned.append(cell)
            continue
        doomed = np.zeros_like(alpha)
        for piece in range(1, count + 1):
            if piece == biggest:
                continue
            mask = labels == piece
            size = sizes[piece - 1]
            if ((index > 0
                 and belongs_across((mask[:, 0], -1), size, parts[index - 1]))
                    or (index + 1 < len(line)
                        and belongs_across((mask[:, -1], 0), size, parts[index + 1]))):
                doomed |= mask
        if doomed.any():
            data = np.array(cell)
            data[..., 3] = np.where(doomed, 0, data[..., 3])
            cell = Image.fromarray(data, "RGBA")
        cleaned.append(cell)
    return cleaned


def bounds(cell: Image.Image):
    """Boîte de la matière d'une case, ou None si la case est vide."""
    alpha = np.asarray(cell)[..., 3]
    rows = np.where(alpha.max(axis=1) > 24)[0]
    columns = np.where(alpha.max(axis=0) > 24)[0]
    if rows.size == 0 or columns.size == 0:
        return None
    return int(columns[0]), int(rows[0]), int(columns[-1]) + 1, int(rows[-1]) + 1


def shape_complaint(path: Path, rows: int) -> str:
    """La planche a-t-elle la forme attendue ? Message d'erreur, ou "".

    ⚠️ CE CONTRÔLE VAUT SON POIDS. Le découpage divise bêtement la largeur par 8
    et la hauteur par 3 : sur une planche qui ne fait pas ces proportions, il ne
    PLANTE PAS — il découpe de travers, silencieusement, et rend des créatures
    coupées en deux qu'on ne découvre qu'en jouant.

    Le cas qui arrive vraiment : le générateur d'images rend UNE planche où la
    marche et l'attaque sont empilées, séparées par un trait. Elle a alors six
    rangées au lieu de trois, et chaque case sort à cheval sur deux poses. Vue
    de loin la planche semble juste — c'est exactement pour ça qu'il faut la
    mesurer plutôt que la regarder.
    """
    with Image.open(path) as image:
        width, height = image.size
    wanted = COLUMNS / rows
    actual = width / height
    if abs(actual - wanted) / wanted <= 0.08:
        return ""
    guess = ""
    # Deux fois trop haute : les deux planches ont été rendues en une seule.
    if abs(actual - wanted / 2.0) / wanted <= 0.16:
        guess = (" — on dirait LES DEUX PLANCHES EMPILÉES dans une seule image."
                 " Il en faut deux, une par prompt.")
    return (f"{path.name} fait {width}x{height}, soit {actual:.2f} de rapport ;"
            f" une grille de {COLUMNS}x{rows} en demande {wanted:.2f}{guess}")


## Sous cette part de la matière MÉDIANE de sa rangée, une case est tenue pour
## vide. Un dixième : on ne vise pas les poses discrètes — la plus légère de
## cette planche est encore à 90 % de sa médiane — mais les cases où il ne reste
## qu'une poussière.
EMPTY_SHARE = 0.10


def mend(line: list, label: str) -> list:
    """Remplace les cases VIDES par la précédente qui ne l'est pas.

    ⚠️ CE N'EST PAS UNE COQUETTERIE. Une case vide au milieu d'un coup fait
    DISPARAÎTRE le monstre pendant une image — un clignotement que le joueur lit
    comme un bug d'affichage. Une image tenue deux fois, elle, ne se voit pas :
    c'est le pire des deux qu'on choisit, en connaissance de cause.

    Le cas est arrivé dès la première planche livrée : la septième image du coup
    de profil du Spectre était vide, sa traînée ayant quitté la case. Il se
    reproduira, et l'important est qu'il se VOIE — d'où l'avertissement imprimé.
    """
    ink = []
    for cell in line:
        alpha = np.asarray(cell)[..., 3]
        ink.append(float((alpha > 24).mean()))
    median = sorted(ink)[len(ink) // 2]
    if median <= 0.0:
        return line
    out, last, holes = [], None, []
    for number, cell in enumerate(line):
        if ink[number] >= median * EMPTY_SHARE:
            last = cell
        elif last is not None:
            holes.append(number)
            cell = last
        out.append(cell)
    if holes:
        print("   ⚠️  %s : case(s) %s vide(s) dans la planche, l'image "
              "précédente est tenue à la place"
              % (label, ", ".join(str(h) for h in holes)))
    return out


## Part de la largeur (ou de la hauteur) qu'un trait doit couvrir pour être tenu
## pour un TRAIT DE GRILLE et non pour du dessin. Neuf dixièmes : aucune
## créature ne traverse la planche entière, et ces planches font huit cases de
## large.
GRID_SHARE = 0.90


def without_grid(sheet: Image.Image) -> Image.Image:
    """La planche débarrassée de ses traits de grille, où qu'ils tombent.

    ⚠️ LE RABOT DES BORDS NE SUFFIT PAS, et c'est une leçon payée deux fois.
    `BORDER_TRIM` retire trois pixels sur chaque bord de case, ce qui marche
    tant que le trait est POSÉ sur la limite. Une planche livrée avait les
    siens RENTRÉS de deux pixels — lignes 254-255 et 508-509 pour des cases de
    256. Le rabot emportait 509 et laissait 508 : il restait un trait clair en
    bas de chaque sprite de marche, sur les neuf poses venues de cette planche.

    On les CHERCHE donc, au lieu de deviner où ils tombent. Le critère ne peut
    pas se tromper : un trait de grille traverse la planche entière, et aucune
    créature ne fait huit cases de large.
    """
    pixels = np.asarray(sheet).astype(np.int16)
    # Un trait est CLAIR et peu coloré ; le fond magenta, lui, a du rouge et du
    # bleu forts avec un vert effondré. On repère donc les pixels dont le vert
    # est haut — ce que le fond n'a jamais.
    pale = pixels[..., 1] > 150
    doomed = np.zeros(pixels.shape[:2], bool)
    doomed[pale.mean(axis=1) > GRID_SHARE, :] = True
    doomed[:, pale.mean(axis=0) > GRID_SHARE] = True
    if not doomed.any():
        return sheet
    # On les repeint du fond : le détourage les effacera avec lui.
    corner = pixels[:8, :8].reshape(-1, 3)
    background = np.median(corner, axis=0).astype(np.uint8)
    out = np.array(sheet)
    out[doomed] = background
    return Image.fromarray(out, "RGB")


def cells_of(path: Path, rows: int, keep_enclosed: bool = False) -> dict:
    """Découpe une planche en cases détourées, rangée par rangée."""
    with Image.open(path) as image:
        sheet = without_grid(image.convert("RGB"))
    width, height = sheet.size
    cell_w, cell_h = width / COLUMNS, height / rows
    out = {}
    for row in range(rows):
        line = []
        for column in range(COLUMNS):
            box = (int(column * cell_w) + BORDER_TRIM,
                   int(row * cell_h) + BORDER_TRIM,
                   int((column + 1) * cell_w) - BORDER_TRIM,
                   int((row + 1) * cell_h) - BORDER_TRIM)
            line.append(deblorded(keyed(sheet.crop(box), keep_enclosed)))
        out[ROWS[row]] = mend(without_side_bleed(line),
                              f"{path.stem} rangée {row + 1}")
    return out


def facing_complaint(line: list, label: str) -> str:
    """Toutes les cases du PROFIL regardent-elles du même côté ?

    ⚠️ LE CONTRÔLE QUI MANQUAIT. C'est le défaut le plus cher de ce projet : sept
    créatures ont marché à reculons pendant des semaines parce que personne ne
    mesurait de quel côté regardait la rangée de profil. On l'a corrigé à la
    main une fois ; on le mesure maintenant.

    Et il ne suffit pas que la rangée regarde du bon côté EN MOYENNE : elle doit
    regarder du même côté à CHAQUE case. Une planche livrée alternait droite et
    gauche d'une case sur deux — en jeu, la bête se retourne la tête quatre fois
    par cycle de marche.

    La mesure : la TÊTE est le tiers supérieur de la silhouette. Si son centre
    est à droite du centre du corps, la bête regarde à droite.

    ⚠️ CE N'EST QU'UN INDICE, jamais un verdict — et l'arbitrage a été refait
    trois fois avant d'en arriver là. L'historique, pour qu'on ne recommence pas :

    1. Une planche de serpent a été accusée à tort : ses TRAITS DE GRILLE
       entraient dans la silhouette. Vraie cause, corrigée par `BORDER_TRIM`.

    2. Un minotaure brandissant sa hache à deux mains a été accusé à tort : le
       haut de sa silhouette est du FER, pas un mufle. On a alors gardé la
       mesure ferme sur la MARCHE, où la pose est neutre, et indicative sur
       l'attaque.

    3. Un gobelin a fait tomber ce compromis : il porte sa massue en arrière sur
       l'épaule EN MARCHANT. Le haut de sa silhouette est donc son arme, qui est
       derrière lui, et sa marche a été accusée à son tour — sur une planche
       dont les huit gobelins regardaient bien à droite.

    Conclusion : dès qu'une créature porte quelque chose au-dessus de l'épaule,
    la mesure ment, quelle que soit la planche. Elle reste utile — elle a bien
    attrapé un vrai retournement, sur la marche du serpent — mais c'est l'œil
    qui tranche. Afficher une rangée de huit cases prend dix secondes et ne se
    trompe pas.
    """
    sides = []
    for cell in line:
        alpha = np.asarray(cell)[..., 3] > 24
        ys, xs = np.nonzero(alpha)
        if xs.size == 0:
            sides.append(None)
            continue
        top, low = ys.min(), ys.max()
        head = xs[ys < top + (low - top) * 0.30]
        sides.append(None if head.size == 0
                     else ("right" if head.mean() > xs.mean() else "left"))
    # ON NE JUGE PLUS LE CÔTÉ, ON JUGE L'ACCORD DES CASES ENTRE ELLES.
    #
    # C'est le seul verdict que cette mesure puisse rendre honnêtement, et c'est
    # aussi le seul qui décrive un vrai défaut d'ANIMATION : une planche dont
    # toutes les cases s'accordent est jouable, quel que soit le côté — si elle
    # regarde du mauvais côté, l'œil le voit en dix secondes. Une planche dont
    # les cases se contredisent, elle, fait se retourner la bête en marchant, et
    # ça, l'œil peut le manquer en feuilletant.
    #
    # Le changement vient de quatre fausses accusations sur cinq : dès qu'une
    # créature porte une arme au-dessus de l'épaule, le « haut de la silhouette »
    # est cette arme, qui est DERRIÈRE elle. Le verdict absolu était donc faux
    # aussi souvent qu'il était juste. L'accord, lui, ne dépend pas de ce que la
    # bête porte : il dépend seulement de la régularité du dessin.
    lefts = [i for i, side in enumerate(sides) if side == "left"]
    rights = [i for i, side in enumerate(sides) if side == "right"]
    if not lefts or not rights:
        return ""
    odd = lefts if len(lefts) <= len(rights) else rights
    return (f"{label} : le profil ne s'accorde pas — la case "
            f"{', '.join(str(o) for o in odd)} se lit à l'envers des autres. En"
            " jeu, la bête peut se retourner la tête en marchant. À confirmer à"
            " l'œil : une arme portée en arrière fausse la mesure")


## Part de la masse habituelle de la créature en dessous de laquelle on la tient
## pour ABSENTE d'une case. Un quart : on ne vise pas les poses ramassées — la
## plus basse d'une planche saine reste au-dessus des trois quarts — mais les
## cases où il ne reste que l'effet.
VANISH_SHARE = 0.25


def vanish_complaint(walk_line: list, strike_line: list, label: str) -> str:
    """La créature est-elle DESSINÉE dans chaque case de coup ?

    ⚠️ ELLE NE SAIT PAS DISTINGUER « ABSENT » DE « ACCROUPI », et c'est écrit ici
    parce que la leçon a coûté du bon dessin.

    La mesure est la MOITIÉ HAUTE de la case : une créature debout l'occupe, un
    effet posé au sol non. Elle a bien attrapé un vrai défaut — une planche où
    trois cases ne montraient que la rafale de cristaux, le golem ayant disparu.
    Mais elle a aussi accusé un gobelin qui frappe ACCROUPI, tête sous la ligne
    médiane : 0,002 de matière en haut, exactement comme le golem absent. Les
    deux cas sont indiscernables par cette mesure.

    Cette fonction a d'abord RÉPARÉ ce qu'elle croyait trouver, en tenant
    l'image précédente. Sur le gobelin, elle a donc remplacé trois images de
    coup parfaitement bonnes par une pose figée — un « correctif » qui abîmait
    le dessin livré, sans que rien ne le dise.

    Elle ne répare plus rien. Elle signale, et c'est l'œil qui trancher :
    l'affichage d'une rangée de cases prend dix secondes, et il ne se trompe pas.
    """
    def top_mass(cell) -> float:
        alpha = np.asarray(cell)[..., 3] > 24
        return float(alpha[:alpha.shape[0] // 2, :].mean())

    usual = sorted(top_mass(cell) for cell in walk_line)[len(walk_line) // 2]
    if usual <= 0.0:
        return ""
    gone = [i for i, cell in enumerate(strike_line)
            if top_mass(cell) < usual * VANISH_SHARE]
    if not gone:
        return ""
    return (f"{label} : la créature a DISPARU des case(s) "
            f"{', '.join(str(g) for g in gone)} — il n'y reste que l'effet. En"
            " jeu, le monstre s'efface pendant son propre coup")


## Dérive tolérée du corps dans sa case, en part de la largeur de case.
## Un dixième : en dessous, c'est le balancement normal d'une démarche ; au-delà,
## la bête TRAVERSE sa case.
DRIFT_SHARE = 0.10


def drift_complaint(line: list, label: str) -> str:
    """La créature reste-t-elle EN PLACE d'une case à l'autre ?

    ⚠️ CELLE-CI NE SE TROMPE PAS, contrairement au sens du profil : elle ne
    devine rien, elle mesure une position. Et c'est le défaut le plus visible en
    jeu de tous ceux qu'on attrape ici.

    Le découpage donne à toutes les cases d'une bête la MÊME fenêtre — c'est ce
    qui l'empêche de grandir et rapetisser d'une image à l'autre. Conséquence :
    une créature qui se déplace dans sa case sur la planche se déplace aussi
    dans son sprite, et le jeu la fait donc glisser en arrière et en avant sur
    place pendant qu'elle marche. Mesuré sur une planche livrée : 63 pixels de
    va-et-vient sur une case de 250. On ne voit plus une démarche, on voit un
    patinage.

    Ça ne se rattrape pas au découpage sans recadrer chaque case sur son propre
    corps — ce qui ferait sauter les poses où le déplacement est VOULU, comme la
    fente d'un coup d'épée. C'est donc au dessin de rester en place.
    """
    middles = []
    for cell in line:
        alpha = np.asarray(cell)[..., 3] > 24
        columns = np.nonzero(alpha.any(axis=0))[0]
        if columns.size == 0:
            continue
        middles.append((float(columns.min()) + float(columns.max())) / 2.0)
    if len(middles) < 2:
        return ""
    drift = max(middles) - min(middles)
    width = float(np.asarray(line[0]).shape[1])
    if drift <= width * DRIFT_SHARE:
        return ""
    return (f"{label} : la créature DÉRIVE de {drift:.0f} px dans une case de"
            f" {width:.0f} — elle traverse sa case au lieu de bouger sur place."
            " En jeu, elle patinera d'avant en arrière en marchant")


## Amplitude minimale du pied avant sur un cycle, en part de la largeur de case.
##
## Un dixième, calé sur une planche SAINE plutôt que choisi : le minotaure, dont
## la marche se lit bien en jeu, fait 31 px sur 250, soit 12 %. Le gobelin qui
## patine en fait 9, soit 4 %. On place la barre entre les deux, plus près du
## défaut — mieux vaut laisser passer une démarche courte que réclamer un
## redessin sur une planche correcte.
STRIDE_SHARE = 0.10


def stride_complaint(line: list, label: str) -> str:
    """Les pieds AVANCENT-ils d'une image à l'autre ?

    ⚠️ LE DÉFAUT QU'ON VOIT SANS SAVOIR LE NOMMER. Une planche peut être
    irréprochable partout ailleurs — bonne taille, pas de dérive, pas de trait —
    et donner une créature qui GLISSE : il suffit que ses jambes ne bougent
    presque pas. Le corps oscille, les pieds restent plantés, et l'œil lit un
    patinage sans savoir d'où il vient. Mesuré sur une planche livrée : 6 pixels
    de va-et-vient du pied avant, contre 36 pour une planche saine du même jeu.

    Ça ne se répare pas au découpage — il n'y a rien à recadrer, le dessin ne
    contient pas le mouvement. C'est une reprise du dessin.

    On regarde une BANDE juste au-dessus de la ligne de sol, et le bord AVANT de
    ce qui s'y trouve : c'est le pied qui mène. S'il ne va nulle part, il n'y a
    pas de pas.
    """
    # La ligne de sol est le point le plus bas de la démarche, mesuré ici plutôt
    # que reçu : cette fonction travaille sur les cases SOURCE, dont la hauteur
    # n'a rien à voir avec celle du sprite final.
    feet = 0
    for cell in line:
        rows = np.nonzero((np.asarray(cell)[..., 3] > 24).any(axis=1))[0]
        if rows.size:
            feet = max(feet, int(rows.max()))
    if feet == 0:
        return ""
    height = float(np.asarray(line[0]).shape[0])
    band_height = maxi = max(6, int(height * 0.10))
    # ⚠️ ON REGARDE LES DEUX PIEDS, ET L'ÉCART ENTRE EUX.
    #
    # La première version ne suivait que le bord AVANT, et elle a refusé une
    # planche parfaitement bonne : ce gobelin-là marche en lançant sa jambe
    # ARRIÈRE, son pied avant restant presque en place. 13 px devant, 39 px
    # derrière, et un écartement qui respire de 106 à 143. Une démarche est un
    # mouvement RELATIF entre deux pieds — se fier à un seul, c'est parier sur
    # la façon dont le dessinateur a construit son cycle.
    fronts, backs, spans = [], [], []
    for cell in line:
        alpha = np.asarray(cell)[..., 3] > 24
        band = alpha[max(0, feet - band_height):feet + 1, :]
        columns = np.nonzero(band.any(axis=0))[0]
        if not columns.size:
            continue
        fronts.append(int(columns.max()))
        backs.append(int(columns.min()))
        spans.append(int(columns.max()) - int(columns.min()))
    if len(fronts) < 4:
        return ""
    span = max(max(fronts) - min(fronts), max(backs) - min(backs),
               max(spans) - min(spans))
    width = float(np.asarray(line[0]).shape[1])
    if span >= width * STRIDE_SHARE:
        return ""
    return (f"{label} : les pieds ne parcourent que {span} px sur {width:.0f}"
            " — les jambes ne font pas de pas, la créature glissera. Il faut"
            " redessiner la marche avec une vraie foulée")


## Les espèces à jambes, lues dans le bestiaire du jeu : celles à qui il donne
## une foulée. On ne recopie pas la liste ici — elle divergerait.
def Bestiary_walks(species: str) -> bool:
    source = Path("src/entities/bestiary.gd")
    if not source.exists():
        return True
    text = source.read_text(encoding="utf-8")
    mark = text.find(f'"{species}": {{')
    if mark < 0:
        return False
    return '"stride"' in text[mark:text.find("},", mark)]


def foot_travel(line: list) -> float:
    """Course du pied sur un cycle, en part de la HAUTEUR de la créature.

    ⚠️ C'EST CE NOMBRE QUI EMPÊCHE LA BÊTE DE GLISSER, et il ne peut venir que
    d'ici : lui seul sait de combien le dessinateur a fait avancer le pied.

    Le jeu s'en sert pour régler la cadence de marche. Réglée à la main, elle ne
    pouvait pas tomber juste — mesuré sur une planche livrée : le pied parcourt
    0,52 case pendant que le sol en défile 0,85, donc il glisse d'un tiers de
    case à chaque pas. Le réglage à la main donnait le double de l'écart.

    En part de la HAUTEUR et non de la largeur de case : la hauteur est ce que le
    jeu impose (`Bestiary.height`), donc c'est la seule mesure qui se convertisse
    en cases sans rien connaître du découpage.
    """
    heights, fronts, backs = [], [], []
    for cell in line:
        alpha = np.asarray(cell)[..., 3] > 24
        rows = np.nonzero(alpha.any(axis=1))[0]
        if not rows.size:
            continue
        heights.append(float(rows.max() - rows.min()))
        band = alpha[max(0, int(rows.max()) - int((rows.max() - rows.min()) * 0.16)):
                     int(rows.max()) + 1, :]
        columns = np.nonzero(band.any(axis=0))[0]
        if columns.size:
            fronts.append(int(columns.max()))
            backs.append(int(columns.min()))
    if not heights or len(fronts) < 4:
        return 0.0
    swing = max(max(fronts) - min(fronts), max(backs) - min(backs))
    return float(swing) / max(1.0, sum(heights) / len(heights))


def union(*tables) -> tuple | None:
    """Boîte englobante de toutes les cases des tables données."""
    left = top = 10 ** 6
    right = bottom = 0
    for table in tables:
        for line in table.values():
            for cell in line:
                box = bounds(cell)
                if box is None:
                    continue
                left, top = min(left, box[0]), min(top, box[1])
                right, bottom = max(right, box[2]), max(bottom, box[3])
    return None if right <= left else (left, top, right, bottom)


## Les images de marche jouées par les mages. LE JOUEUR VEUT DES PAS MOYENS : les images
## 1, 4, 5 et 8 sont de grandes enjambées, rejetées en jeu. Mais ne garder que les pieds
## joints (3 et 7) a été rejeté aussi : le mage semble sauter. Le cycle part des pieds
## joints, qui servent de pose d'arrêt, et s'ouvre sur les images 2 et 6.
SMALL_STEP_FRAMES = [3, 2, 2, 3, 7, 6, 6, 7]

## Marge ajoutée autour d'une case avant d'agrandir l'attaque, pour que le sort ne
## soit pas coupé par le bord.
STEADY_MARGIN = 64
## Le corps ne peut pas dériver de plus que ça d'une image à l'autre, en pixels de
## planche. Au-delà, la mesure s'est accrochée au sort.
STEADY_REACH = 48
## Part haute du corps qui sert de repère : la tête et les épaules. Les bras, les
## pieds et le sort bougent, elles non.
STEADY_BAND = 0.45
## Une miette : moins de 5 % du corps, toute entière dans le dernier huitième de case.
CRUMB_SIZE_SHARE = 0.05
CRUMB_EDGE_SHARE = 0.125
## Agrandissement maximal de l'attaque. Au-delà, c'est la planche qui est à refaire.
STEADY_MAX_SCALE = 1.3


def _moved(cell: Image.Image, dx: float, dy: float) -> Image.Image:
    return cell.transform(cell.size, Image.AFFINE, (1, 0, -dx, 0, 1, -dy), Image.BICUBIC)


def _best_dx(reference: np.ndarray, cell: Image.Image, band: tuple) -> int:
    """Le décalage horizontal qui superpose le mieux le haut du corps à la référence."""
    alpha = np.asarray(cell)[band[0]:band[1], :, 3] > 24
    return max(range(-STEADY_REACH, STEADY_REACH + 1),
               key=lambda dx: (int((reference & np.roll(alpha, dx, axis=1)).sum()), -abs(dx)))


def without_edge_crumbs(cell: Image.Image) -> Image.Image:
    """La case sans les miettes collées à son bord gauche ou droit.

    Le bout d'un éclair qui dépasse de la case voisine y laisse une tache isolée, trop
    petite pour que `without_side_bleed` reconnaisse sa forme de l'autre côté. Vue
    une seule image, elle clignote à l'écran. Une étincelle légitime, elle, reste
    près du sort et loin du bord.
    """
    alpha = np.asarray(cell)[..., 3] > 24
    labels, count = ndimage.label(alpha)
    if count <= 1:
        return cell
    sizes = ndimage.sum(alpha, labels, range(1, count + 1))
    biggest = float(np.max(sizes))
    data = np.array(cell)
    margin = int(cell.width * CRUMB_EDGE_SHARE)
    for piece, slices in enumerate(ndimage.find_objects(labels)):
        near_edge = slices[1].stop <= margin or slices[1].start >= cell.width - margin
        if near_edge and sizes[piece] < biggest * CRUMB_SIZE_SHARE:
            data[..., 3][labels == piece + 1] = 0
    return Image.fromarray(data, "RGBA")


def steadied(walk_line: list, strike_line: list) -> tuple:
    """La rangée dont le corps ne bouge plus, de la marche à la fin de l'attaque.

    Le prompt l'exige et le générateur ne le tient pas : mesuré sur les huit mages,
    le corps dérive jusqu'à 32 px en marchant, et l'attaque est dessinée jusqu'à 18 %
    plus petite, ses pieds 12 px plus haut. Le repère de l'attaque est sa DERNIÈRE
    image, qui rejoint la pose de marche : ni geste accroupi ni sort pour la fausser.
    """
    def padded(cell: Image.Image) -> Image.Image:
        out = Image.new("RGBA", (cell.width + 2 * STEADY_MARGIN,
                                 cell.height + 2 * STEADY_MARGIN), (0, 0, 0, 0))
        out.paste(cell, (STEADY_MARGIN, STEADY_MARGIN))
        return out

    walk_line = [padded(cell) for cell in walk_line]
    strike_line = [padded(without_edge_crumbs(cell)) for cell in strike_line]
    first = bounds(walk_line[0])
    band = (first[1], first[1] + int((first[3] - first[1]) * STEADY_BAND))
    reference = np.asarray(walk_line[0])[band[0]:band[1], :, 3] > 24
    walk_line = [_moved(cell, _best_dx(reference, cell, band), 0) for cell in walk_line]

    heights = [bounds(cell)[3] - bounds(cell)[1] for cell in walk_line]
    feet = float(np.median([bounds(cell)[3] for cell in walk_line]))
    neutral = bounds(strike_line[-1])
    scale = float(np.clip(np.median(heights) / max(1, neutral[3] - neutral[1]),
                          1.0, STEADY_MAX_SCALE))
    # L'agrandissement se fait autour des pieds, qui descendent ensuite à leur ligne.
    centre_x, floor = (neutral[0] + neutral[2]) / 2.0, float(neutral[3])
    grown = [cell.transform(cell.size, Image.AFFINE,
                            (1 / scale, 0, centre_x - centre_x / scale,
                             0, 1 / scale, floor - floor / scale - (feet - floor) / scale),
                            Image.BICUBIC) for cell in strike_line]
    strike_line = [_moved(cell, _best_dx(reference, cell, band), 0) for cell in grown]
    return walk_line, strike_line


def build(source_name: str, entry: dict) -> str:
    source_folder = entry.get("source", SOURCE)
    walk_path = source_folder / entry.get("walk_sheet", f"{source_name}_marche.png")
    strike_path = source_folder / f"{source_name}_attaque.png"
    walks = entry.get("walks", Bestiary_walks(entry["id"]))
    missing = [p.name for p in (walk_path, strike_path) if not p.exists()]
    if missing:
        return f"{entry['id']} : {' et '.join(missing)} introuvable(s)"

    # ON MESURE AVANT DE COUPER. Une planche mal formée doit être refusée ici,
    # avec la raison, plutôt que produire des bandes fausses qu'on découvrira
    # en jeu — c'est la leçon des sept créatures qui marchaient à reculons :
    # les fichiers existaient et les tests passaient.
    for path in (walk_path, strike_path):
        complaint = shape_complaint(path, len(ROWS))
        if complaint:
            return f"{entry['id']} REFUSÉ : {complaint}"

    walk = cells_of(walk_path, len(ROWS), entry.get("keep_enclosed", False))
    strike = cells_of(strike_path, len(ROWS), entry.get("keep_enclosed", False))
    # La foulée se juge sur la case d'origine : `steadied` l'élargit.
    original_profile = walk["right"]
    if entry.get("align_rows"):
        for row in ROWS:
            walk[row], strike[row] = steadied(walk[row], strike[row])
            walk[row] = [walk[row][number - 1] for number in SMALL_STEP_FRAMES]

    # On DÉCOUPE QUAND MÊME après cette plainte : elle porte sur le dessin, pas
    # sur le format, donc les bandes produites restent regardables. Mais elle
    # s'imprime en toutes lettres — un profil qui se retourne se voit en jeu, et
    # on ne veut pas le découvrir là.
    # ON SIGNALE, ON NE RÉPARE PLUS. Le raccommodage automatique a été retiré
    # après avoir fait des dégâts : voir `vanish_complaint`.
    for row in ROWS:
        missing = vanish_complaint(walk[row], strike[row],
            f"{strike_path.stem} rangée {ROWS.index(row) + 1}")
        if missing:
            print(f"   ·   à vérifier à l'œil — {missing}")
    # LA DÉRIVE est mesurée sur la MARCHE seule : un coup peut légitimement
    # porter le corps en avant, une démarche non.
    for row in ROWS:
        drift = drift_complaint(walk[row], f"{walk_path.stem} rangée {ROWS.index(row) + 1}")
        if drift:
            print(f"   ⚠️  À FAIRE REDESSINER — {drift}")
    # LA FOULÉE se juge de PROFIL seulement : de face et de dos, un pas qui
    # avance ne se voit pas — et c'est bien pour ça qu'on ne remarque le
    # patinage que lorsque la bête traverse l'écran de gauche à droite.
    # ⚠️ SEULEMENT CE QUI A DES JAMBES. Un serpent rampe, un spectre lévite, une
    # ombre glisse : leur « pied avant » ne veut rien dire, et le contrôle les
    # accusait toutes les trois. La liste est celle du bestiaire, qui déclare
    # déjà une `stride` pour les bêtes qui marchent — une seule source.
    if walks:
        strideless = stride_complaint(original_profile, f"{walk_path.stem} profil")
        if strideless:
            print(f"   ⚠️  À FAIRE REDESSINER — {strideless}")
    for table, source in ((walk, walk_path), (strike, strike_path)):
        hint = facing_complaint(table["right"], source.stem)
        if hint:
            print(f"   ·   à vérifier à l'œil — {hint}")

    # DEUX MESURES, ET C'EST TOUT L'ART DE CETTE FONCTION.
    #
    # La case commune doit contenir la pose la plus ample — sinon le coup le
    # plus large serait rogné — mais elle ne peut pas être MESURÉE dessus. Une
    # traînée de coup ne déborde jamais des deux côtés à la fois : prise dans la
    # boîte, elle décale le corps du monstre par rapport au centre de la case, et
    # le jeu dessine l'ombre de contact sous l'origine du nœud. Le monstre se
    # retrouve à côté de son ombre. C'est ce qu'on a vu sur la première capture.
    #
    # Donc : le CORPS se mesure sur la marche seule, l'ENCOMBREMENT sur tout.
    walk_box = union(walk)
    full_box = union(walk, strike)
    if walk_box is None or full_box is None:
        return f"{entry['id']} : planches vides"

    # ⚠️ LE GÉNÉRATEUR NE POSE PAS SES RANGÉES À LA MÊME HAUTEUR. Mesuré sur le Feu :
    # les pieds tombent à 108 de face, 100 de dos et 93 de profil. Une seule ligne de
    # sol le fait flotter au-dessus de son ombre dès qu'il tourne. Chaque rangée est
    # donc recalée sur sa propre MARCHE, avec son attaque, du même décalage.
    #
    # Verticalement seulement : le centre de boîte d'un profil dépend de ce qui
    # traîne derrière lui, et centrer dessus décalait le corps vers l'avant.
    shifts = {row: 0 for row in ROWS}
    if entry.get("align_rows"):
        for row in ROWS:
            box = union({row: walk[row]})
            shifts[row] = walk_box[3] - box[3]
        boxes = []
        for row in ROWS:
            box = union({row: walk[row]}, {row: strike[row]})
            boxes.append((box[0], box[1] + shifts[row], box[2], box[3] + shifts[row]))
        full_box = (min(b[0] for b in boxes), min(b[1] for b in boxes),
                    max(b[2] for b in boxes), max(b[3] for b in boxes))

    # Horizontalement, la case est SYMÉTRIQUE autour du corps : on prend le
    # débordement le plus grand des deux côtés et on l'applique aux deux. La
    # créature reste donc au centre, et rien n'est coupé.
    middle = (walk_box[0] + walk_box[2]) / 2.0
    half = max(middle - full_box[0], full_box[2] - middle)
    left, right = int(middle - half), int(middle + half)
    top, bottom = full_box[1], full_box[3]

    span_w = right - left + CELL_PADDING * 2
    span_h = bottom - top + CELL_PADDING * 2
    scale = FRAME_HEIGHT / span_h
    cell_w = int(round(span_w * scale))
    folder = entry.get("out", OUT) / entry["id"]
    folder.mkdir(parents=True, exist_ok=True)

    poses = ["idle"] + [f"walk_{i + 1}" for i in range(COLUMNS)] \
        + [f"attack_{i + 1}" for i in range(COLUMNS)]

    for direction in ROWS + ["left"]:
        # LA GAUCHE EST LE MIROIR DU PROFIL DROIT, retourné case par case et
        # non bande entière : retourner la bande inverserait aussi l'ORDRE des
        # poses, et le monstre marcherait à l'envers.
        read = "right" if direction == "left" else direction
        flip = direction == "left"
        line = [walk[read][0]] + walk[read] + strike[read]
        strip = Image.new("RGBA", (cell_w * len(poses), FRAME_HEIGHT),
                          (0, 0, 0, 0))
        for number, cell in enumerate(line):
            shift = shifts[read]
            piece = cell.crop((left - CELL_PADDING, top - CELL_PADDING - shift,
                               right + CELL_PADDING, bottom + CELL_PADDING - shift))
            piece = piece.resize((cell_w, FRAME_HEIGHT), Image.LANCZOS)
            if flip:
                piece = piece.transpose(Image.FLIP_LEFT_RIGHT)
            strip.alpha_composite(piece, (number * cell_w, 0))
        strip.save(folder / f"{direction}.png")

    # LES PIEDS SONT LE BAS DE LA MARCHE, et non le bas de la matière. Même
    # raison que le centrage : une traînée de coup qui plonge sous la robe
    # pousserait la ligne de sol sous le corps, et la créature flotterait
    # au-dessus de son ombre pendant tout le reste du jeu.
    feet_y = (walk_box[3] - (top - CELL_PADDING)) * scale
    # LA FOULÉE, MESURÉE SUR LE DESSIN. Voir `foot_travel`.
    #
    # ⚠️ Zéro pour ce qui n'a pas de jambes : `Enemy` lie la cadence à la distance
    # dès que ce nombre est positif, et un battement d'ailes mesuré comme un pied
    # priverait le Dragonnet de la cadence en secondes qu'il doit garder.
    travel = foot_travel(walk["right"]) if walks else 0.0
    (folder / "frames.json").write_text(json.dumps({
        "cell": [cell_w, FRAME_HEIGHT],
        "feet_y": round(feet_y, 1),
        "foot_travel": round(travel, 4),
        # La hauteur du CORPS dans la case. Le sort agrandit la case et donc réduit
        # le corps : le jeu en a besoin pour garder la taille à l'écran.
        "body_height": round(max(union({row: walk[row]})[3] - union({row: walk[row]})[1]
                                 for row in ROWS) * scale, 1),
        "poses": poses,
        "directions": ["down", "up", "left", "right"],
        "source": f"{source_name}_marche.png + {source_name}_attaque.png",
    }, indent=2), encoding="utf-8")
    return (f"{entry['id']} ({entry['name']}) : 4 directions x {len(poses)} "
            f"poses, case {cell_w}x{FRAME_HEIGHT}")


def main() -> None:
    wanted = sys.argv[1:]
    for name, entry in (HERD | MAGES).items():
        if wanted and name not in wanted:
            continue
        print(build(name, entry))


if __name__ == "__main__":
    main()
