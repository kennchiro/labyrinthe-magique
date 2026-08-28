#!/usr/bin/env python3
"""Le terrain DESSINÉ des dix stages, découpé des planches d'`peso&cover/terrain/`.

    tools/.venv/bin/python tools/build_terrain.py     # DEPUIS LA RACINE

Produit, pour chaque stage dont la planche existe :
    assets/tiles/stage_<N>/floor_sheet.png    192x192 = 6x6 cases, SANS COUTURE
    assets/tiles/stage_<N>/wall_atlas.png     4x4 pièces raccordables + wall.json
    assets/decor/stage_<N>/prop_<i>.png       les 12 props + decor.json

⚠️ À LANCER APRÈS `build_stage_tiles.py`, jamais avant : celui-là teinte les
tuiles génériques pour les dix stages, celui-ci ÉCRASE le résultat des stages qui
ont une vraie planche. L'inverse rendrait le terrain teinté par-dessus le dessiné.

TROIS PLANCHES, TROIS PROBLÈMES SANS RAPPORT

`_sol`   une grande plaque de matière, pleine image. Le seul travail est de la
         rendre RACCORDABLE — ce n'est pas au modèle de le faire, on le lui a
         explicitement interdit (il aurait dessiné un cadre pour faire semblant).

`_decor` douze objets centrés sur magenta. Découpage trivial, détourage par
         teinte comme les icônes de sorts.

`_mur`   seize pièces sur magenta — et c'est là que tout se joue. Les modèles ont
         dessiné de beaux tronçons, mais **qui FLOTTENT** : chaque pièce est
         posée au milieu de sa case avec du magenta tout autour, y compris du
         côté où elle devrait se raccorder à sa voisine. Telles quelles, elles
         laisseraient un trou à chaque jonction du labyrinthe.

         On ne relance donc PAS la génération : on répare. Une pièce est un
         carrefour plus des BRAS ; chaque bras qui doit se raccorder est
         PROLONGÉ jusqu'au bord de la case en répétant sa propre section — le
         profil d'un bras est constant sur sa longueur, c'est ce qui rend
         l'opération invisible. Les bras qui ne se raccordent pas gardent leur
         bout arrondi, qui est justement ce que le modèle dessine bien.

         Et on ne fait AUCUNE confiance à l'ordre des cases : les dix planches
         ne l'ont pas respecté de la même façon. La topologie de chaque pièce
         (quels bras elle porte) est MESURÉE, puis chaque configuration de
         voisins va chercher la pièce qui lui correspond.
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image
from scipy import ndimage
from build_stage_tiles import MIN_CONTRAST

SOURCE = Path("assets/peso&cover/terrain")
TILES = Path("assets/tiles")
DECOR = Path("assets/decor")

## Côté de la planche de sol finale, en pixels. 192 = 6 x 6 cases de 32.
##
## Six et non trois : à trois cases, le motif recommence tous les trois pas et
## l'œil voit la grille sur un labyrinthe entier. Six coûte quatre fois le poids
## d'une planche minuscule — 40 Ko contre 10 — et fait disparaître la répétition.
FLOOR_TILES = 6
TILE_SIZE = 32
FLOOR_SIDE = FLOOR_TILES * TILE_SIZE

## Largeur de la bande de fondu qui rend la plaque raccordable, en fraction du
## côté. En dessous, la couture reste visible ; au-dessus, le fantôme du fondu
## commence à se voir sur les matières à gros motifs.
SEAM_BAND = 0.16


def load(name: str) -> Image.Image | None:
    path = SOURCE / name
    return Image.open(path).convert("RGB") if path.exists() else None


# --- Le sol : rendre raccordable une plaque qui ne l'est pas ---------------------

def seamless(image: Image.Image) -> Image.Image:
    """La plaque, raccordable avec elle-même.

    Le principe tient en une phrase : une image et la MÊME image décalée d'une
    demi-période ont leurs discontinuités à des endroits DIFFÉRENTS — l'une aux
    bords, l'autre au milieu. On garde donc l'originale au milieu, la décalée
    aux bords, et on passe de l'une à l'autre par un fondu.

    Le fondu mélange deux contenus différents, donc il FANTÔME. C'est le prix, et
    c'est pour ça que les prompts exigeaient une matière à petit grain et à
    éclairage plat : sur de l'herbe ou du sable, le fantôme est indétectable ;
    sur un gros motif, il se verrait."""
    pixels = np.asarray(image).astype(np.float32)
    height, width = pixels.shape[:2]
    rolled = np.roll(pixels, (height // 2, width // 2), axis=(0, 1))

    def ramp(size: int) -> np.ndarray:
        band = max(2, int(size * SEAM_BAND))
        distance = np.minimum(np.arange(size), size - 1 - np.arange(size))
        t = np.clip(1.0 - distance / float(band), 0.0, 1.0)
        # Lissage aux deux bouts : une rampe linéaire laisse une arête de dérivée
        # que l'œil attrape comme une bande.
        return t * t * (3.0 - 2.0 * t)

    weight = np.maximum(ramp(height)[:, None], ramp(width)[None, :])[..., None]
    blended = pixels * (1.0 - weight) + rolled * weight
    return Image.fromarray(np.clip(blended, 0, 255).astype(np.uint8), "RGB")


def build_floor(index: int, sheet: Image.Image) -> str:
    tile = seamless(sheet).resize((FLOOR_SIDE, FLOOR_SIDE), Image.LANCZOS)
    out_dir = TILES / f"stage_{index}"
    out_dir.mkdir(parents=True, exist_ok=True)
    tile.save(out_dir / "floor_sheet.png")
    return f"sol {FLOOR_SIDE}x{FLOOR_SIDE}"


# --- Le contraste : la seule règle qui prime sur le dessin ------------------------

def luminance(pixels: np.ndarray) -> float:
    return float((pixels[..., :3].astype(np.float32)
                  @ np.array([0.299, 0.587, 0.114], np.float32)).mean())


def rescaled(image: Image.Image, factor: float) -> Image.Image:
    data = np.asarray(image).astype(np.float32)
    data[..., :3] = np.clip(data[..., :3] * max(0.15, factor), 0, 255)
    return Image.fromarray(data.astype(np.uint8), image.mode)


def enforce_contrast(index: int) -> str:
    """Écarte sol et mur jusqu'à ce que le chemin se lise.

    Les prompts n'imposaient PAS lequel des deux devait être le plus clair —
    deux mesures automatiques se contredisaient sur les planches de référence, et
    inscrire une direction qu'on ne sait pas mesurer aurait été pire que rien.
    Le sens se mesure donc ICI, sur le dessin livré, et on ne l'inverse jamais :
    on écarte les deux valeurs symétriquement autour de leur écart existant.

    Sans ça, les Dunes rendaient un grès blond sur du sable doré et les Montagnes
    de la glace sur de la neige : deux labyrinthes illisibles dont chaque couleur,
    prise seule, était juste."""
    out_dir = TILES / f"stage_{index}"
    floor_path, atlas_path = out_dir / "floor_sheet.png", out_dir / "wall_atlas.png"
    if not (floor_path.exists() and atlas_path.exists()):
        return ""
    with Image.open(floor_path) as image:
        floor = image.convert("RGB").copy()
    with Image.open(atlas_path) as image:
        atlas = image.convert("RGBA").copy()

    solid = np.asarray(atlas)[..., 3] > 200
    if not solid.any():
        return ""
    floor_lum = luminance(np.asarray(floor))
    wall_lum = luminance(np.asarray(atlas)[solid])
    gap = wall_lum - floor_lum
    missing = MIN_CONTRAST - abs(gap)
    if missing <= 0.0:
        return f"contraste {abs(gap):.0f} ok"

    way = 1.0 if gap >= 0.0 else -1.0
    rescaled(floor, (floor_lum - way * missing * 0.5) / max(floor_lum, 1.0)).save(floor_path)
    rescaled(atlas, (wall_lum + way * missing * 0.5) / max(wall_lum, 1.0)).save(atlas_path)
    return f"contraste {abs(gap):.0f} -> {MIN_CONTRAST:.0f}"


# --- Le décor : douze objets, dix semés et deux allumés ---------------------------

## Grille de la planche de props.
DECOR_COLUMNS, DECOR_ROWS = 4, 3
## Les DEUX DERNIERS objets de la planche sont les lumineux — c'est écrit dans
## tous les prompts, à tous les stages. Ils vont dans `lueur/`, que DecorLayer
## tire cinq fois moins souvent et à quoi l'étape d'éclairage accroche une lampe.
GLOWING_COUNT = 2
## Côté maximal d'un prop écrit sur le disque. `DecorLayer` le remet à l'échelle
## de la case au rendu (0,42 case, 0,5 pour un lumineux) : cette taille ne fixe
## donc que la finesse, pas l'encombrement en jeu.
PROP_SIDE = 128


## Écart RGB au fond échantillonné en dessous duquel un pixel est du fond.
## 78 et pas plus : le lierre du Bois d'Épine et les coraux des Rivages ont des
## bords estompés qui s'en approchent, et au-delà on leur mange le contour.
KEY_DISTANCE = 78.0
## Écart de CHROMATICITÉ au fond en dessous duquel un pixel plus sombre que le
## fond est son ombre portée. 0,085 : mesuré, l'ombre reste sous 0,03 et le
## cristal rose le plus proche du fond est à 0,115.
CHROMA_TOLERANCE = 0.085


def keyed(cell: Image.Image, crop: bool = True) -> Image.Image | None:
    """L'objet seul, le fond magenta retiré.

    ⚠️ Ce n'est PAS le détourage de `build_skill_icons.py`, et la différence est
    la raison d'être de cette fonction. Là-bas, tout pixel de TEINTE magenta
    part, y compris enclavé — légitime pour une icône de flamme, désastreux ici :
    les cristaux du Canyon, des Cavernes et du Sanctuaire sont violets, donc à
    quelques degrés du magenta, et ils se faisaient effacer avec le fond. Mesuré
    sur trois stages : les props revenaient en fantômes troués.

    Ici le fond est un aplat UNI et on le connaît — il suffit de l'échantillonner
    aux quatre coins. On retire alors ce qui lui ressemble ET QUI TOUCHE LE BORD.
    La condition de bord est ce qui sauve les violets : un cristal au milieu de
    la case n'est jamais atteignable depuis l'extérieur, quelle que soit sa
    teinte."""
    pixels = np.asarray(cell.convert("RGB")).astype(np.float32)
    height, width = pixels.shape[:2]
    corner = max(4, min(height, width) // 20)
    corners = np.concatenate([
        pixels[:corner, :corner].reshape(-1, 3),
        pixels[:corner, -corner:].reshape(-1, 3),
        pixels[-corner:, :corner].reshape(-1, 3),
        pixels[-corner:, -corner:].reshape(-1, 3),
    ])
    background = np.median(corners, axis=0)

    # RESSEMBLER AU FOND, ou être SON OMBRE. Deux critères, et il faut les deux.
    #
    # La distance RGB attrape le magenta pur, mais pas l'OMBRE PORTÉE que le
    # modèle peint dessus : du magenta assombri se retrouve à 120 d'écart et
    # survivait, d'où le halo rose sous chaque cristal du premier essai.
    #
    # La « magenta-ité » a été essayée pour l'attraper, et jetée : MESURÉ sur la
    # planche des Cavernes, les cristaux roses montent à 0,96 quand le fond
    # plafonne à 0,86. Ils sont PLUS magenta que le magenta ; aucun seuil ne les
    # sépare.
    #
    # Ce que l'ombre conserve et que le cristal n'a pas, c'est la CHROMATICITÉ :
    # assombrir divise les trois canaux par le même facteur, donc la direction
    # de la couleur ne bouge pas. On compare donc des couleurs NORMALISÉES, et
    # on n'accepte que ce qui est plus sombre que le fond — un objet plus clair
    # que le fond n'est jamais son ombre.
    norm = np.maximum(np.linalg.norm(pixels, axis=2, keepdims=True), 1e-6)
    direction = pixels / norm
    key_direction = background / max(float(np.linalg.norm(background)), 1e-6)
    chroma = np.linalg.norm(direction - key_direction, axis=2)
    darker = norm[..., 0] <= float(np.linalg.norm(background)) * 1.02
    close = (np.sqrt(((pixels - background) ** 2).sum(axis=2)) < KEY_DISTANCE) \
        | ((chroma < CHROMA_TOLERANCE) & darker)
    parts, count = ndimage.label(close)
    edges = np.concatenate([parts[0], parts[-1], parts[:, 0], parts[:, -1]])
    outside = np.isin(parts, np.unique(edges[edges > 0]))
    if count == 0 or not outside.any():
        return None

    # Un trou de fond vu ENTRE DEUX BRANCHES n'est atteignable par aucun bord et
    # resterait en pastille rose. On le prend par la même chromaticité, mais avec
    # une tolérance deux fois plus serrée : enclavé, on n'a plus le bord pour
    # garde-fou, et se tromper là coûte un trou dans l'objet.
    outside = outside | ((chroma < CHROMA_TOLERANCE * 0.5) & darker)

    data = np.array(cell.convert("RGBA"))
    data[..., 3] = np.where(outside, 0, 255)

    # DÉGORGEMENT. Le bord de l'objet est mélangé au fond sur un ou deux pixels ;
    # sans correction il reste un liseré rose autour de chaque champignon. On
    # mesure combien chaque pixel TIRE vers le fond et on l'en éloigne d'autant.
    rgb = data[..., :3].astype(np.float32)
    towards = np.clip(
        1.0 - np.sqrt(((rgb - background) ** 2).sum(axis=2)) / (KEY_DISTANCE * 2.2),
        0.0, 1.0)
    fringe = ndimage.binary_dilation(outside, iterations=2) & ~outside
    pull = np.where(fringe, towards, 0.0)[..., None]
    # On repousse vers la couleur MOYENNE de l'objet, la seule référence
    # disponible : reculer vers le gris décolorerait les bords.
    body = rgb[~outside].mean(axis=0) if (~outside).any() else np.zeros(3)
    data[..., :3] = np.clip(rgb * (1.0 - pull) + body * pull, 0, 255).astype(np.uint8)
    data[..., 3] = np.where(fringe, (data[..., 3] * (1.0 - pull[..., 0])).astype(
        np.uint8), data[..., 3])

    out = Image.fromarray(data, "RGBA")
    if not crop:
        # Les pièces de mur gardent leur case entière : leur géométrie se mesure
        # en coordonnées de CASE, un recadrage la perdrait.
        return out
    bounds = out.getbbox()
    return out.crop(bounds) if bounds else None


def build_decor(index: int, sheet: Image.Image) -> str:
    width, height = sheet.size
    cell_w, cell_h = width / DECOR_COLUMNS, height / DECOR_ROWS
    out_dir = Path(f"assets/stages/props/stage_{index}")
    semis, lueur = out_dir / "semis", out_dir / "lueur"
    semis.mkdir(parents=True, exist_ok=True)
    lueur.mkdir(parents=True, exist_ok=True)
    # Les props générés par `build_stage_props.py` occupent les mêmes noms. On
    # les efface : en laisser un traîner au rang 4 mêlerait un caillou terne au
    # milieu de dix objets dessinés, et on chercherait longtemps d'où il sort.
    for folder in (semis, lueur):
        for stale in folder.glob("*.png"):
            stale.unlink()
            stale.with_suffix(".png.import").unlink(missing_ok=True)

    total = DECOR_COLUMNS * DECOR_ROWS
    written = [0, 0]
    for number in range(total):
        column, row = number % DECOR_COLUMNS, number // DECOR_COLUMNS
        box = (int(column * cell_w), int(row * cell_h),
               int((column + 1) * cell_w), int((row + 1) * cell_h))
        prop = keyed(sheet.crop(box))
        if prop is None:
            continue
        prop.thumbnail((PROP_SIDE, PROP_SIDE), Image.LANCZOS)
        glowing = number >= total - GLOWING_COUNT
        role = "lueur" if glowing else "semis"
        rank = written[1 if glowing else 0]
        prop.save(out_dir / role / f"{role}_{rank}.png")
        written[1 if glowing else 0] += 1
    return f"décor {written[0]} semis + {written[1]} lueurs"


# --- Les murs : seize pièces raccordables, assemblées à partir de trois ----------
#
# LE PROBLÈME. Les planches livrées dessinent de beaux tronçons, mais qui
# FLOTTENT : chaque pièce est posée au milieu de sa case avec du magenta tout
# autour, y compris du côté où elle devrait rejoindre sa voisine. Et l'ordre des
# cases demandé n'a été respecté par aucune des dix planches : mesurée, la
# topologie réelle donne des doublons (cinq croix au stage 1) et des trous (il
# manque un coin ou un T à chaque stage).
#
# CE QU'ON NE FAIT PAS. Choisir parmi les seize la pièce qui correspond à chaque
# configuration de voisins : il en manque toujours, et relancer la génération
# pour dix planches jusqu'à ce que les seize tombent juste est un pari.
#
# CE QU'ON FAIT. On n'en garde que TROIS, celles que les dix planches ont toutes
# réussies : la CROIX, la BARRE VERTICALE et la BARRE HORIZONTALE. La croix
# porte le carrefour et les quatre bras ; les barres portent les quatre BORDS de
# la haie — le rebord du haut, celui du bas, ceux des côtés. Avec ça on fabrique
# les seize :
#
#     fermer un côté  -> on y recopie le bord de la barre perpendiculaire
#     ouvrir un côté  -> on prolonge le bras jusqu'au bord de la case
#
# Tout est donc du dessin livré, jamais du dessin inventé : on ne fait que
# déplacer des morceaux de haie. Et comme les trois sources viennent de la même
# case, la largeur, l'éclairage et la densité de feuillage sont cohérents par
# construction — c'était la contrainte la plus dure à obtenir d'un modèle.
#
# ⚠️ Aucune rotation, jamais. La haie est éclairée par le haut et porte une
# tranche sombre sur son bord bas ; tourner une pièce d'un quart de tour mettrait
# cette tranche sur le côté. Le miroir horizontal, lui, serait licite — il n'est
# pas nécessaire ici.

WALL_COLUMNS = WALL_ROWS = 4
## Nombre de VARIANTES de chaque pièce dans l'atlas final.
##
## Une seule ne suffit pas : la matière est cuite dans la pièce, donc deux cases
## voisines de même configuration — c'est-à-dire tout long mur droit — affichent
## le même dessin au pixel près, et le mur se met à battre. Deux variantes
## décalées, tirées par case, plus le miroir du moteur, font quatre apparences
## pour un atlas deux fois plus lourd (32 Ko).
WALL_VARIANTS = 2
## Côté d'une pièce dans l'atlas final. 64 pour une case de jeu de 32 : le
## moteur réduit, donc le trait reste net sur un écran Retina sans peser.
WALL_PIECE = 64
## Bits de la configuration de voisins. L'ordre est celui que lira le moteur.
UP, RIGHT, DOWN, LEFT = 1, 2, 4, 8
STEPS = {UP: (0, -1), RIGHT: (1, 0), DOWN: (0, 1), LEFT: (-1, 0)}
## Allonge minimale d'un bras, en multiples du rayon du carrefour.
ARM_REACH = 1.45
## En dessous de cette couverture, la tranche prélevée pour prolonger un bras est
## trop vide pour servir : c'est qu'il n'y a pas de bras de ce côté.
SLAB_COVERAGE = 0.30
## Demi-largeur du tronçon, en fraction de la case finale. C'est ELLE qui fixe
## l'échelle de tout l'atlas : les pièces livrées flottent au milieu de leur case
## à des tailles libres, et les recadrer sans caler cette fraction donnait des
## haies deux fois trop fines pour la case du jeu — un labyrinthe de fils.
## 0,325 : le tronçon occupe 65 % de la case. Les deux bornes ont été VUES —
## à 0,42 le carrefour renflé de la croix remplit la case entière, les seize
## pièces sortent identiques et le labyrinthe redevient un aplat ; en dessous de
## 0,30 les haies deviennent des fils avec du sol partout entre elles.
BAR_FRACTION = 0.325


def wall_cells(sheet: Image.Image) -> list:
    """Les seize cases de la planche, détourées, en pleine case."""
    width, height = sheet.size
    cell_w, cell_h = width / WALL_COLUMNS, height / WALL_ROWS
    out = []
    for number in range(WALL_COLUMNS * WALL_ROWS):
        column, row = number % WALL_COLUMNS, number // WALL_COLUMNS
        box = (int(column * cell_w), int(row * cell_h),
               int((column + 1) * cell_w), int((row + 1) * cell_h))
        out.append(keyed(sheet.crop(box), crop=False))
    return out


def measure(piece: Image.Image | None) -> dict | None:
    """Ce qu'une pièce EST, mesuré : son carrefour, son rayon, ses bras.

    Le rayon vient de la transformée de distance : le point le plus éloigné du
    vide est forcément au milieu du tronçon le plus épais, c'est-à-dire au
    carrefour. C'est plus sûr que le centre de la boîte englobante, qui pour un
    coin tombe dans le vide de l'angle."""
    if piece is None:
        return None
    mask = np.asarray(piece)[..., 3] > 110
    if mask.sum() < 200:
        return None
    distance = ndimage.distance_transform_edt(mask)
    radius = float(distance.max())
    cy, cx = np.unravel_index(int(distance.argmax()), distance.shape)
    height, width = mask.shape
    reach = {}
    for bit, (dx, dy) in STEPS.items():
        far = 0
        for step in range(1, max(width, height)):
            y, x = int(cy + dy * step), int(cx + dx * step)
            if not (0 <= y < height and 0 <= x < width) or not mask[y, x]:
                break
            far = step
        reach[bit] = far
    # 1,45 fois le rayon, et pas 1,6 : MESURÉ sur les dix planches, quatre
    # d'entre elles n'avaient alors AUCUNE croix — le lierre du Bois d'Épine et
    # la pierre des Ruines sont si épais que leurs bras dépassent à peine leur
    # propre rayon. À 1,45, neuf planches sur dix en ont une.
    arms = sum(bit for bit, far in reach.items() if far > radius * ARM_REACH)
    return {"image": piece, "mask": mask, "radius": radius,
            "centre": (int(cx), int(cy)), "arms": arms, "reach": reach}


def material(entry: dict, side: int) -> Image.Image:
    """Un carré de MATIÈRE pris au cœur du tronçon, rendu raccordable.

    C'est tout ce qu'on retient du dessin de mur : ses feuilles, sa pierre, sa
    glace. Le carré est pris autour du carrefour, là où la pièce est la plus
    épaisse, donc garanti sans bord ni transparence."""
    cx, cy = entry["centre"]
    reach = int(entry["radius"] * 0.72)
    patch = entry["image"].convert("RGB").crop(
        (cx - reach, cy - reach, cx + reach, cy + reach))
    # Le carré est répété DEUX FOIS dans chaque sens plutôt qu'agrandi à la
    # taille de la case. Agrandi, ses fleurs et ses pierres faisaient une pièce
    # entière : le motif revenait à l'identique d'une case à l'autre et le mur
    # se mettait à battre. En le répétant, le grain redevient du grain.
    half = max(8, side // 2)
    small = seamless(patch).resize((half, half), Image.LANCZOS)
    out = Image.new("RGB", (side, side))
    for row in range(0, side, half):
        for column in range(0, side, half):
            out.paste(small, (column, row))
    return out


def shape_mask(mask: int, side: int) -> np.ndarray:
    """La SILHOUETTE de la pièce, calculée — jamais découpée.

    C'est le renversement qui fait marcher tout le reste. Assembler les seize
    pièces en déplaçant des morceaux des planches livrées a été essayé et jeté :
    leurs tronçons flottent au milieu de leur case, à des largeurs et des
    carrefours qui ne coïncident pas, et le résultat sortait décalé d'un tiers de
    case avec des bavures. Une forme CALCULÉE, elle, se raccorde au pixel près
    par construction, et le dessin garde le rôle où il est irremplaçable : la
    matière.

    Un tronçon par voisin, plus un disque au carrefour. Les bras absents n'ont
    rien à dessiner : c'est l'arc du disque qui leur fait un bout arrondi, et
    c'est exactement la forme que le modèle dessinait bien."""
    half = side // 2
    bar = side * BAR_FRACTION
    yy, xx = np.mgrid[0:side, 0:side]
    shape = ((xx - half) ** 2 + (yy - half) ** 2) <= (bar * (1.18 if mask == 0 else 1.0)) ** 2
    inside = np.abs(xx - half) <= bar
    level = np.abs(yy - half) <= bar
    if mask & UP:
        shape |= inside & (yy <= half)
    if mask & DOWN:
        shape |= inside & (yy >= half)
    if mask & LEFT:
        shape |= level & (xx <= half)
    if mask & RIGHT:
        shape |= level & (xx >= half)
    # FILETAGE des angles rentrants. L'union de quatre rectangles fait un plus à
    # angles vifs ; une haie taillée n'en a pas. Une fermeture morphologique les
    # arrondit sans toucher aux bords droits ni aux bouts déjà ronds.
    fillet = max(2, int(bar * 0.30))
    disc = np.hypot(*np.mgrid[-fillet:fillet + 1, -fillet:fillet + 1]) <= fillet
    return ndimage.binary_erosion(
        ndimage.binary_dilation(shape, disc), disc, border_value=1)


def sculpted(shape: np.ndarray, skin: Image.Image) -> Image.Image:
    """La matière posée dans la silhouette, avec juste ce qu'il faut de relief.

    ⚠️ AUCUN NOIR. Une première version cernait chaque mur d'une bordure noire
    bien visible en jeu, et elle avait TROIS causes cumulées, toutes évitables :

      1. une OMBRE PORTÉE peinte en noir pur sous la pièce. Supprimée : le
         contraste de luminance imposé entre sol et mur (52) sépare déjà les
         deux, une ombre n'ajoutait que de la crasse ;
      2. un BISEAU qui tombait à 34 % de la luminance au ras du bord, soit un
         liseré presque noir tout autour. Il ne descend plus qu'à 84 % : on
         devine l'épaisseur, on ne voit plus de trait ;
      3. la plus sournoise — hors de la forme, le RGB restait à ZÉRO. Invisible
         en pleine résolution, puisque l'alpha y est nul ; mais la réduction à la
         taille de l'atlas MÉLANGE les couleurs voisines sans tenir compte de
         l'alpha, et ramène donc du noir sur tout le pourtour. D'où le
         DÉBORDEMENT ci-dessous : la couleur est prolongée vers l'extérieur avant
         toute réduction, pour qu'il n'y ait jamais de noir à ramener."""
    side = shape.shape[0]
    rgb = np.asarray(skin.convert("RGB")).astype(np.float32)
    depth = ndimage.distance_transform_edt(shape)
    bevel = max(2.0, side * 0.10)
    lit = np.clip(depth / bevel, 0.0, 1.0)

    shade = 0.84 + 0.16 * lit
    # L'arête du haut prend la lumière : le soleil est au zénith sur toutes les
    # planches. C'est ce qui reste pour dire l'épaisseur, maintenant que le bord
    # ne s'assombrit presque plus.
    above = np.roll(shape, int(bevel * 0.9), axis=0) & shape
    shade = shade + np.clip((1.0 - lit) * above, 0.0, 1.0) * 0.22

    painted = np.clip(rgb * shade[..., None], 0, 255)
    # DÉBORDEMENT : chaque pixel du vide reprend la couleur de la matière la plus
    # proche. L'alpha reste nul, donc rien ne se voit — mais la réduction ne
    # trouve plus de noir à mélanger au bord.
    _, (row, column) = ndimage.distance_transform_edt(~shape, return_indices=True)
    out = np.zeros((side, side, 4), np.float32)
    out[..., :3] = painted[row, column]
    out[..., 3] = np.where(shape, 255.0, 0.0)
    return Image.fromarray(out.astype(np.uint8), "RGBA")


def build_walls(index: int, sheet: Image.Image) -> str:
    entries = [e for e in (measure(c) for c in wall_cells(sheet)) if e is not None]
    if not entries:
        return "murs : planche vide"
    # La pièce la plus ÉPAISSE donne la meilleure matière : c'est celle dont le
    # cœur est le plus loin de tout bord, donc la plus sûre à échantillonner.
    thickest = max(entries, key=lambda e: e["radius"])
    side = WALL_PIECE * 4
    skin = material(thickest, side)

    atlas = Image.new("RGBA",
        (WALL_PIECE * 4, WALL_PIECE * 4 * WALL_VARIANTS), (0, 0, 0, 0))
    shapes = [shape_mask(mask, side) for mask in range(16)]
    for variant in range(WALL_VARIANTS):
        # La variante décale la matière d'un tiers et d'une demie : deux nombres
        # premiers entre eux avec la période, sinon le décalage retombe sur le
        # motif d'origine et les deux variantes sont identiques.
        moved = Image.fromarray(np.roll(np.asarray(skin),
            (side // 3 * variant, side // 2 * variant), axis=(0, 1)))
        for mask in range(16):
            piece = sculpted(shapes[mask], moved)
            atlas.alpha_composite(
                piece.resize((WALL_PIECE, WALL_PIECE), Image.LANCZOS),
                ((mask % 4) * WALL_PIECE,
                 (mask // 4 + 4 * variant) * WALL_PIECE))

    out_dir = TILES / f"stage_{index}"
    out_dir.mkdir(parents=True, exist_ok=True)
    atlas.save(out_dir / "wall_atlas.png")
    (out_dir / "wall.json").write_text(json.dumps({
        "piece": WALL_PIECE, "columns": 4, "rows": 4,
        "variants": WALL_VARIANTS,
        "bits": {"up": UP, "right": RIGHT, "down": DOWN, "left": LEFT},
        "source": f"terrain_{index}_mur.png",
    }, indent=2), encoding="utf-8")
    return f"murs atlas {WALL_PIECE * 4}x{WALL_PIECE * 4 * WALL_VARIANTS}"


def main() -> None:
    for index in range(1, 11):
        rapport = []
        sol = load(f"terrain_{index}_sol.png")
        if sol is not None:
            rapport.append(build_floor(index, sol))
        mur = load(f"terrain_{index}_mur.png")
        if mur is not None:
            rapport.append(build_walls(index, mur))
        decor = load(f"terrain_{index}_decor.png")
        if decor is not None:
            rapport.append(build_decor(index, decor))
        note = enforce_contrast(index)
        if note:
            rapport.append(note)
        if rapport:
            print(f"stage {index:2d}  " + " · ".join(rapport))
        else:
            print(f"stage {index:2d}  aucune planche")


if __name__ == "__main__":
    main()
