#!/usr/bin/env python3
"""L'Ombre maléfique de la Faille des ténèbres, découpée de sa planche.

    tools/.venv/bin/python tools/build_ombre.py     # DEPUIS LA RACINE

La planche `ombre_malefique.png` suit le prompt de `docs/prompts/sorts/ombre_malefique.md` :
quatre colonnes, cinq rangées, fond magenta uni.

    r1  flottement de FACE          4 poses
    r2  flottement de DOS           4 poses
    r3  flottement de PROFIL GAUCHE 4 poses
    r4  le SOUFFLE de gaz, de face  4 poses
    r5  le GAZ SEUL                 4 poses

⚠️ LA CLÉ DE FOND NE PEUT PAS ÊTRE CELLE DES ICÔNES. `build_skill_icons.keyed()`
retire « ce qu'un pixel a de rouge ET de bleu en plus de son vert » — la
signature du magenta, mais aussi celle du VIOLET. Cette créature est violette
d'un bout à l'autre : la règle des icônes la dissoudrait. On sépare donc sur la
seule chose qui distingue vraiment le fond du sujet ici : le fond a son rouge et
son bleu À ÉGALITÉ (magenta pur, |r-b| ≈ 5), là où le gaz violet a une teinte
mesurée à 277° — c'est-à-dire beaucoup plus de bleu que de rouge.

⚠️ LES DESSINS DÉBORDENT DE LEUR CASE. Le prompt demandait 40 px de marge ; la
planche rendue laisse la fumée de la rangée 1 descendre cinq pixels dans la
case de la rangée 2. Une découpe à la grille couperait donc les traînées et
sèmerait des fragments en haut des cases voisines. On découpe avec un
DÉBORDEMENT, et chaque forme connexe revient à la case où tombe son centre —
même règle que `build_characters._claim_cell`.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image
from scipy import ndimage

SOURCE = Path("assets/peso&cover/creatures/ombre_malefique.png")
## La planche D'APPOINT, facultative : le souffle de dos et le souffle de profil,
## que la première ne dessine pas. Voir l'addendum de `docs/prompts/sorts/ombre_malefique.md`.
##
## Deux rangées demandées à part plutôt qu'une planche complète refaite : un
## modèle d'image ne redessine pas deux fois le même personnage à l'identique, et
## une planche neuve donnerait une AUTRE créature. Tant qu'elle n'est pas là, les
## trois directions concernées reçoivent un ÉLAN plutôt qu'une pose de coup
## (`SummonVisual.LUNGE`) — le jeu n'attend pas après ce fichier.
BREATH = Path("assets/peso&cover/creatures/ombre_souffle.png")
BREATH_ROWS = 2
OUT = Path("assets/allies")
CATALOGUE = OUT / "allies.json"

COLUMNS = 4
ROWS = 5
## Marge prise autour d'une case pour récupérer ce qui en déborde.
OVERHANG = 48

## Le fond : vert bas, rouge ET bleu hauts, et les deux À ÉGALITÉ.
KEY_GREEN = 95
KEY_BRIGHT = 145
KEY_BALANCE = 60
## Au-delà, un pixel est franchement du sujet et garde son alpha plein ; en
## deçà de KEY_BALANCE il est du fond. Entre les deux, le bord anti-crénelé,
## dont l'alpha se dose. Sans ce dosage la silhouette est en escalier.
FADE_BALANCE = 105

## Au-dessus de cette luminosité un pixel est du GAZ, en dessous du manteau.
## Le manteau est presque noir, le jet est un violet vif : rien entre les deux.
CLOAK_DARK = 80
GAS_BRIGHT = 150
## Alpha au-dessus duquel un pixel compte pour SÉPARER les dessins. Voir la note
## sur l'étiquetage dans `cut_row`.
LABEL_ALPHA = 110
## Surface minimale, en pixels, pour qu'une tache sombre soit un manteau.
CLOAK_MIN = 3000

## Largeur de la case, en multiples de la largeur du manteau. Elle borne
## l'envergure du jet — voir la note dans `main`.
CELL_SPREAD = 2.0

## Densité minimale d'une ligne pour compter comme le CORPS et non comme un
## filament de fumée. C'est sur le corps qu'on aligne, jamais sur la traînée.
BODY_ROW = 12


def keyed(sheet: Image.Image) -> np.ndarray:
    """La planche en RGBA, fond retiré."""
    rgb = np.asarray(sheet.convert("RGB")).astype(int)
    red, green, blue = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    balance = np.abs(red - blue)
    magenta = (green < KEY_GREEN) & (np.minimum(red, blue) > KEY_BRIGHT)

    alpha = np.full(green.shape, 255.0)
    alpha[magenta & (balance < KEY_BALANCE)] = 0.0
    # Le bord : d'autant plus opaque qu'il s'écarte de l'équilibre du magenta.
    edge = magenta & (balance >= KEY_BALANCE) & (balance < FADE_BALANCE)
    alpha[edge] = 255.0 * (balance[edge] - KEY_BALANCE) / float(FADE_BALANCE - KEY_BALANCE)

    out = np.dstack([rgb.astype(np.uint8), alpha.astype(np.uint8)])
    return out


def cut_row(data: np.ndarray, width: int, y0: int, y1: int) -> list:
    """Une rangée découpée en cases, chaque forme rendue à SON SOUFFLEUR.

    ⚠️ LA RÈGLE DU CENTRE NE MARCHE PAS ICI, et c'est le piège de cette planche.
    `build_characters` attribue une forme connexe à la case où tombe son centre,
    ce qui suffit quand les dessins ne se chevauchent qu'un peu. Mais le jet de
    gaz est une forme DÉTACHÉE, et il part si loin sur le côté que son centre
    tombe dans la case VOISINE : le souffle de la troisième pose se retrouvait
    dans la deuxième, retourné, à côté d'une créature qui ne soufflait pas.

    On attribue donc par PROPRIÉTAIRE : chaque case a une ancre — le milieu du
    manteau qu'elle contient — et toute forme rejoint l'ancre la plus proche. Une
    nappe de gaz appartient à la créature qui la crache, où qu'elle aille.

    Le test vertical reste, lui, un test de CENTRE : c'est celui qui empêche la
    fumée de la rangée du dessus de descendre dans celle-ci.
    """
    height = data.shape[0]
    wy0, wy1 = max(0, y0 - OVERHANG), min(height, y1 + OVERHANG)
    band = data[wy0:wy1]
    solid = band[..., 3] > 24
    # ⚠️ ON N'ÉTIQUETTE PAS SUR LE VOILE. À alpha > 24, les quatre poses de la
    # rangée de profil ne font qu'UNE SEULE forme connexe : les volutes les plus
    # ténues d'un souffle effleurent la fumée de la créature d'à côté, et tout se
    # tient de bout en bout. Trois cases sur quatre ressortaient vides.
    #
    # On sépare donc sur ce qui est FERME, où les liens ténus n'existent pas,
    # puis on rend le voile au propriétaire le plus proche. Le jet reste attaché
    # à sa créature, le fil qui reliait deux poses ne l'est plus.
    firm = band[..., 3] > LABEL_ALPHA
    labels, count = ndimage.label(firm)

    bounds = [(round(col * width / COLUMNS), round((col + 1) * width / COLUMNS))
              for col in range(COLUMNS)]
    value = band[..., :3].max(axis=2)
    # Le gaz est LUMINEUX, le manteau ne l'est pas. Cette séparation sert deux
    # fois : à trouver le manteau, et à rattacher une bouffée détachée au JET
    # dont elle vient plutôt qu'à la créature d'à côté, un peu moins loin.
    bright = firm & (value >= GAS_BRIGHT)

    ELSEWHERE = -2
    owner = np.full(count + 1, -1, dtype=int)
    if count:
        # ⚠️ UNE RANGÉE A DES CRÉATURES, OU ELLE N'EN A PAS. La rangée du gaz
        # seul n'en a aucune — mais ses nuages ont des cœurs assez foncés pour
        # passer pour des manteaux dès qu'on desserre le seuil, et deux d'entre
        # eux se faisaient alors ancrer pendant que les deux autres étaient
        # aspirés par leurs voisins. On décide donc pour la RANGÉE ENTIÈRE :
        # tant que trois cases sur quatre n'ont pas trouvé leur manteau, on
        # desserre ; si même ainsi il n'y en a pas, la rangée n'a pas de
        # créature et chaque forme revient à la case où tombe son centre.
        found = {}
        for limit in (CLOAK_DARK, 110, 140):
            found = {}
            for col, (x0, x1) in enumerate(bounds):
                piece = firm[:, x0:x1] & (value[:, x0:x1] < limit)
                marked = labels[:, x0:x1][piece]
                marked = marked[marked > 0]
                if marked.size < CLOAK_MIN:
                    continue
                found[col] = int(np.bincount(marked).argmax())
            if len(found) >= COLUMNS - 1:
                break
        if len(found) >= COLUMNS - 1:
            for col, label_id in found.items():
                owner[label_id] = col

        centres = ndimage.center_of_mass(firm, labels, range(1, count + 1))
        for index, (cy, _cx) in enumerate(centres, start=1):
            # Test VERTICAL de centre : c'est lui qui empêche la fumée de la
            # rangée du dessus de descendre dans celle-ci.
            if not (y0 <= cy + wy0 < y1):
                owner[index] = ELSEWHERE

        anchored = bool((owner >= 0).any())
        claimed = np.where(firm, owner[labels], -1) if anchored else None
        nearest = None
        nearest_gas = None
        if anchored:
            _, nearest = ndimage.distance_transform_edt(claimed < 0, return_indices=True)
            owned_gas = (claimed >= 0) & bright
            if owned_gas.any():
                _, nearest_gas = ndimage.distance_transform_edt(
                    ~owned_gas, return_indices=True)
        for index, (cy, cx) in enumerate(centres, start=1):
            if owner[index] != -1:
                continue
            row_at, col_at = int(round(cy)), int(round(cx))
            if nearest is None:
                owner[index] = min(range(COLUMNS),
                    key=lambda col: abs(cx - (bounds[col][0] + bounds[col][1]) * 0.5))
                continue
            # Une bouffée de gaz suit SON jet. Sans cette distinction elle
            # rejoignait le manteau le plus proche, celui de la créature d'à
            # côté quand le souffle porte plus d'une case.
            table = nearest_gas if (nearest_gas is not None
                and bright[labels == index].mean() > 0.5) else nearest
            owner[index] = int(claimed[table[0][row_at, col_at],
                                       table[1][row_at, col_at]])

    # LE VOILE REJOINT LE PLUS PROCHE. Tout ce qui est trop ténu pour avoir été
    # étiqueté — le bord estompé d'une volute, la poussière d'un jet — prend le
    # propriétaire du pixel ferme le plus proche.
    blocked = firm & (owner[labels] == ELSEWHERE) if count else np.zeros_like(firm)
    settled = np.where(firm & (owner[labels] >= 0), owner[labels], -1) if count \
        else np.full(firm.shape, -1)
    if (settled >= 0).any():
        _, veil = ndimage.distance_transform_edt(settled < 0, return_indices=True)
        held = settled[veil[0], veil[1]]
    else:
        held = np.full(firm.shape, -1)

    # UN SOUFFLE NE PART QUE D'UN CÔTÉ, et du même côté pour toute la rangée.
    #
    # Il reste, après attribution, quelques bouffées du jet VOISIN : sa tête
    # part si loin qu'elle se pose derrière la créature d'à côté, et aucune
    # mesure de distance ne peut deviner qu'elle ne lui appartient pas. Le sens
    # du souffle, lui, le dit sans ambiguïté — une créature qui crache à gauche
    # n'a rien à traîner à sa droite.
    #
    # La règle ne mord que si la rangée a VRAIMENT un côté : sur le souffle de
    # face, le gaz descend et se répartit également, la dominance ne se dégage
    # pas et rien n'est retiré.
    side = _breath_side(bright, held, centres_of(bounds, firm, value, labels))
    if side != 0:
        for col, (x0, x1) in enumerate(bounds):
            anchor = _cloak_axis(firm, value, x0, x1)
            if anchor is None:
                continue
            wrong = np.zeros(firm.shape[1], dtype=bool)
            limit = anchor + side * -1 * (x1 - x0) * 0.28
            wrong[int(limit):] = side < 0
            wrong[:int(limit)] = side > 0
            held = np.where(bright & (held == col) & wrong[None, :], -1, held)

    cells = []
    for col, (x0, x1) in enumerate(bounds):
        alpha = np.where(solid & ~blocked & (held == col), band[..., 3], 0)
        piece = np.dstack([band[..., :3], alpha.astype(np.uint8)])
        # La fenêtre fait trois cases de large : le jet de profil porte à plus
        # d'une case et demie de son souffleur, et une fenêtre trop juste le
        # couperait après l'avoir correctement attribué.
        span = x1 - x0
        wx0, wx1 = max(0, x0 - span), min(width, x1 + span)
        cells.append(Image.fromarray(piece[:, wx0:wx1], "RGBA"))
    return cells


def cloak(frame: Image.Image) -> np.ndarray:
    """Le CORPS SOMBRE seul : la capuche et le manteau, sans le gaz ni la fumée.

    C'est le seul repère qui tienne d'une pose à l'autre, et il sert trois fois.
    Le gaz fausse tout le reste : il enfle vers le haut quand la créature souffle
    de dos, il part sur le côté quand elle souffle de profil, et il déborde
    toujours plus loin que la créature. Une boîte englobante calée dessus
    déplacerait le personnage d'une pose à l'autre — ce qui est exactement le
    défaut qu'on veut éviter.
    """
    data = np.asarray(frame)
    return (data[..., 3] > 180) & (data[..., :3].max(axis=2) < CLOAK_DARK)


def cloak_span(frame: Image.Image) -> tuple:
    """Gauche, droite, haut et bas du manteau. (0, 0, 0, 0) s'il est absent."""
    dark = cloak(frame)
    columns = np.nonzero(dark.sum(axis=0) > 8)[0]
    rows = np.nonzero(dark.sum(axis=1) > 8)[0]
    if not columns.size or not rows.size:
        return (0, 0, 0, 0)
    return (int(columns[0]), int(columns[-1]), int(rows[0]), int(rows[-1]))


def rescale(line: list, factor: float) -> list:
    return [frame.resize((max(1, round(frame.width * factor)),
                          max(1, round(frame.height * factor))), Image.LANCZOS)
            for frame in line]


def hood_top(frame: Image.Image) -> int:
    """Le haut de la CAPUCHE — le point sur lequel les seize poses sont calées.

    Mesuré sur le manteau et non sur tout ce qui est opaque : quand la créature
    souffle de dos, son jet de gaz monte bien au-dessus de sa tête, et un
    alignement sur le sommet du dessin l'enfoncerait d'autant dans sa case.
    """
    span = cloak_span(frame)
    if span == (0, 0, 0, 0):
        alpha = np.asarray(frame)[..., 3]
        rows = np.nonzero((alpha > 140).sum(axis=1) > BODY_ROW)[0]
        return int(rows[0]) if rows.size else 0
    return span[2]


def main() -> None:
    if not SOURCE.exists():
        print(f"  ! {SOURCE} introuvable")
        return
    with Image.open(SOURCE) as raw:
        sheet = raw.convert("RGB")
    data = keyed(sheet)
    width, height = sheet.size

    cells = _cut(data, width, height, ROWS)

    # LA PLANCHE D'APPOINT PASSE PAR LE MÊME ALIGNEMENT que la première, et c'est
    # tout l'intérêt de la découper ici plutôt que dans un second outil : les
    # poses de coup doivent tomber sur la même capuche que les poses de repos,
    # sinon la créature sursaute au moment de souffler.
    breath = []
    if BREATH.exists():
        with Image.open(BREATH) as raw:
            extra = raw.convert("RGB")
        breath = _cut(keyed(extra), extra.width, extra.height, BREATH_ROWS)
        print(f"planche d'appoint : {BREATH.name}, {BREATH_ROWS} rangées de souffle")
    else:
        print(f"(pas de {BREATH.name} : le dos et les profils frapperont à l'élan)")

    # LES QUATRE PREMIÈRES RANGÉES SONT LA CRÉATURE, la cinquième est son gaz.
    # On aligne les seize poses sur le HAUT DU CORPS — la capuche — et non sur
    # le bas : la créature FLOTTE, sa fumée traîne à des hauteurs différentes
    # selon la pose (mesuré : 40 px d'écart entre le profil et le dos), et le
    # souffle en projette encore plus bas. Ce que l'œil suit chez une créature
    # qui lévite, c'est sa tête.
    # ⚠️ LA PLANCHE D'APPOINT N'EST PAS À LA MÊME ÉCHELLE. Mesuré : la créature y
    # est dessinée 22 % plus grande que sur la première (manteau de 242 px de
    # large contre 193 de dos, 218 contre 177 de profil). Le modèle a bien rendu
    # le même personnage, dans des cases une fois et demie plus grandes, mais il
    # ne l'a pas dessiné à la même taille dedans.
    #
    # Sans correction, l'ombre ENFLE d'un cinquième au moment de souffler puis
    # revient — le défaut se voit d'autant plus que la pose de coup ne dure
    # qu'une demi-seconde. On remet donc chaque rangée d'appoint à l'échelle de
    # la vue qu'elle prolonge, en comparant la largeur du manteau : le dos avec
    # le dos, le profil avec le profil.
    for index, source in enumerate(cells[1:3]):
        if index >= len(breath):
            break
        reference = float(np.median([_width(frame) for frame in source]))
        measured = float(np.median([_width(frame) for frame in breath[index]]))
        if measured <= 0.0:
            continue
        factor = reference / measured
        breath[index] = rescale(breath[index], factor)
        print(f"souffle rangée {index + 1} : manteau {measured:.0f} px -> "
              f"{reference:.0f} px (x{factor:.3f})")

    poses = [cell for line in cells[:4] for cell in line]
    poses += [cell for line in breath for cell in line]
    tops = [hood_top(pose) for pose in poses]
    target_top = max(tops)

    # ⚠️ LA TOILE DOIT GRANDIR DE CE QU'ON DESCEND. Décaler une pose dans une
    # toile de sa taille d'origine lui coupe le bas de ce qu'on l'a descendue.
    # Tant que les poses venaient d'une seule planche les décalages étaient de
    # quelques pixels et la perte invisible ; la planche d'appoint, dont la
    # capuche est bien plus basse dans sa case, a fait tomber cent pixels de
    # fumée sous la toile — la créature a rétréci d'un tiers sans un mot.
    room = target_top - min(tops)
    aligned = []
    for pose, top in zip(poses, tops):
        shifted = Image.new("RGBA", (pose.width, pose.height + room), (0, 0, 0, 0))
        shifted.alpha_composite(pose, (0, target_top - top))
        aligned.append(shifted)

    # LA CASE EST MESURÉE DEPUIS LE MILIEU DU MANTEAU, pas depuis le milieu du
    # dessin. Le jet de profil part loin d'un seul côté : centrer la boîte
    # englobante repousserait la créature à l'opposé, et elle ferait un pas de
    # côté chaque fois qu'elle souffle.
    boxes = [pose.getbbox() for pose in aligned]
    axes = [_axis(pose, box) for pose, box in zip(aligned, boxes)]
    reach = max(max(axis - box[0], box[2] - axis) for axis, box in zip(axes, boxes))

    # LE JET EST ROGNÉ, ET C'EST VOULU. Le souffle de profil part à 312 px de
    # l'axe : une case qui le contiendrait entièrement ferait 625 px de large
    # pour une créature qui en occupe 180, et le moteur mettant la CASE à
    # l'échelle, l'ombre y paraîtrait minuscule — sans compter quatre textures
    # de 5000 px de large en mémoire sur un téléphone.
    #
    # On garde donc le départ du jet et on laisse filer sa queue. Ce n'est pas
    # une perte : la queue tombe là où se trouve la victime, et c'est justement
    # là que `GasPuff` pose le nuage de la rangée du bas. Le dessin rogné est
    # celui qui faisait doublon.
    spread = max(_width(pose) for pose in aligned) * CELL_SPREAD * 0.5
    half = min(reach, spread)
    if half < reach:
        print(f"jet rogné : {reach:.0f} px d'envergure ramenés à {half:.0f} "
              "(la queue du souffle est reprise par le nuage sur la victime)")
    top = min(box[1] for box in boxes)
    bottom = max(box[3] for box in boxes)
    cell_w, cell_h = int(half * 2), int(bottom - top)

    bands = {
        "down": (aligned[0:4], aligned[12:16]),      # face + souffle
        "up": (aligned[4:8], aligned[16:20] if breath else []),
        "left": (aligned[8:12], aligned[20:24] if breath else []),
    }
    OUT.mkdir(parents=True, exist_ok=True)
    written = {}
    for name, (idle, strike) in bands.items():
        strip = _strip(idle + strike, cell_w, cell_h, top)
        strip.save(OUT / f"ombre_{name}.png")
        written[name] = {"file": f"ombre_{name}.png", "idle": len(idle), "strike": len(strike)}
        print(f"ombre/{name:5s} {len(idle)}+{len(strike)} poses -> {strip.size}")
    # LA DROITE EST ÉCRITE SUR LE DISQUE, pas retournée en jeu. Le moteur lit un
    # dossier sans avoir à deviner quelle direction miroiter — c'est la règle
    # déjà suivie pour le spectre.
    mirrored = [pose.transpose(Image.FLIP_LEFT_RIGHT) for pose in bands["left"][0]]
    mirrored_strike = [pose.transpose(Image.FLIP_LEFT_RIGHT) for pose in bands["left"][1]]
    strip = _strip(mirrored + mirrored_strike, cell_w, cell_h, top)
    strip.save(OUT / "ombre_right.png")
    written["right"] = {"file": "ombre_right.png",
                        "idle": len(mirrored), "strike": len(mirrored_strike)}
    print(f"ombre/right {len(mirrored)}+{len(mirrored_strike)} poses -> {strip.size}"
          " (miroir de la gauche)")

    # LE GAZ SEUL, centré dans sa propre case : ce n'est pas une créature, il
    # n'a ni haut ni bas et ne se cale sur rien.
    gas = cells[4]
    gas_boxes = [frame.getbbox() for frame in gas]
    gas_w = max(box[2] - box[0] for box in gas_boxes)
    gas_h = max(box[3] - box[1] for box in gas_boxes)
    canvas = Image.new("RGBA", (gas_w * len(gas), gas_h), (0, 0, 0, 0))
    for index, (frame, box) in enumerate(zip(gas, gas_boxes)):
        piece = frame.crop(box)
        canvas.alpha_composite(piece, (index * gas_w + (gas_w - piece.width) // 2,
                                       (gas_h - piece.height) // 2))
    canvas.save(OUT / "ombre_gaz.png")
    print(f"ombre/gaz   {len(gas)} poses -> {canvas.size}")

    catalogue = json.loads(CATALOGUE.read_text(encoding="utf-8")) if CATALOGUE.exists() else {}
    catalogue["ombre"] = {
        "anchor": "feet", "cell": [cell_w, cell_h],
        "mirror_left": False, "directions": written,
        "gas": {"file": "ombre_gaz.png", "frames": len(gas),
                "cell": [gas_w, gas_h]},
    }
    CATALOGUE.write_text(json.dumps(catalogue, indent=2), encoding="utf-8")
    print(f"case commune {cell_w}x{cell_h} -> {CATALOGUE}")


def _cut(data: np.ndarray, width: int, height: int, rows: int) -> list:
    """La planche en cases, chacune amputée de ce qui ne lui appartient pas."""
    return [cut_row(data, width, round(row * height / rows),
                    round((row + 1) * height / rows)) for row in range(rows)]


def _cloak_axis(firm: np.ndarray, value: np.ndarray, x0: int, x1: int):
    """Milieu du manteau d'une case, en coordonnées de la bande. None s'il n'y en a pas."""
    for limit in (CLOAK_DARK, 110, 140):
        piece = firm[:, x0:x1] & (value[:, x0:x1] < limit)
        columns = np.nonzero(piece.sum(axis=0) > 8)[0]
        if columns.size and piece.sum() >= CLOAK_MIN:
            return x0 + (columns[0] + columns[-1]) * 0.5
    return None


def centres_of(bounds: list, firm: np.ndarray, value: np.ndarray,
               _labels: np.ndarray) -> list:
    return [_cloak_axis(firm, value, x0, x1) for x0, x1 in bounds]


def _breath_side(bright: np.ndarray, held: np.ndarray, axes: list) -> int:
    """-1 si le souffle part à gauche, +1 à droite, 0 s'il n'a pas de côté.

    Mesuré sur toute la rangée : une pose seule ne tranche pas — la première du
    cycle n'a pas encore de gaz du tout.
    """
    balance = 0.0
    total = 0.0
    columns = np.arange(bright.shape[1])
    for col, axis in enumerate(axes):
        if axis is None:
            continue
        mass = (bright & (held == col)).sum(axis=0).astype(float)
        if not mass.any():
            continue
        offsets = columns - axis
        # LOIN DU CORPS SEULEMENT. Le halo violet qui entoure la créature et la
        # lueur de ses yeux sont brillants eux aussi : comptés, ils noient le
        # signal du jet et une rangée sans souffle se voit attribuer un côté.
        far = np.abs(offsets) > 90.0
        balance += float((np.sign(offsets) * mass * far).sum())
        total += float((mass * far).sum())
    # Il faut assez de gaz pour trancher, et qu'il penche franchement. En deçà,
    # la rangée n'a pas de côté et on n'y touche pas.
    if total < 4000.0 or abs(balance) < total * 0.35:
        return 0
    return -1 if balance < 0 else 1


def _width(frame: Image.Image) -> int:
    span = cloak_span(frame)
    return span[1] - span[0]


def _axis(frame: Image.Image, box: tuple) -> float:
    """L'axe vertical de la créature : le milieu de son manteau."""
    span = cloak_span(frame)
    if span == (0, 0, 0, 0):
        return (box[0] + box[2]) * 0.5
    return (span[0] + span[1]) * 0.5


def _strip(poses: list, cell_w: int, cell_h: int, top: int) -> Image.Image:
    """Les poses posées côte à côte, chacune calée sur l'axe de son manteau.

    Le moteur centre le Sprite2D horizontalement : c'est donc la CRÉATURE qui
    doit tomber au milieu de la case, sinon elle est affichée à côté de sa vraie
    position — et elle se déplacerait d'une pose à l'autre au gré de son jet.
    """
    strip = Image.new("RGBA", (cell_w * len(poses), cell_h), (0, 0, 0, 0))
    for index, pose in enumerate(poses):
        axis = _axis(pose, pose.getbbox())
        # ⚠️ LA PIÈCE EST DÉCOUPÉE À LA CASE, pas seulement posée dedans. La
        # borne d'envergure rétrécit la case sans rétrécir les dessins : une
        # pose plus large que sa case débordait sur la case VOISINE de la bande,
        # et le jet de profil réapparaissait, retourné, à côté de la pose d'à
        # côté. `crop` hors des bords rend du transparent, ce qui est
        # exactement le rognage voulu.
        left = int(round(axis - cell_w * 0.5))
        piece = pose.crop((left, top, left + cell_w, top + cell_h))
        strip.alpha_composite(piece, (index * cell_w, 0))
    return strip


if __name__ == "__main__":
    main()
