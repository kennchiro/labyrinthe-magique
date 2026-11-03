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

⚠️ DEUX PLANCHES ÉCHAPPENT À LA CLÉ DE TEINTE, et il faut savoir pourquoi avant
d'y toucher : celles des Ténèbres et de l'Invocateur sont DESSINÉES EN VIOLET,
donc dans la bande de la clé (260-320°, contre 0-40° pour le Feu). Aucun réglage
de teinte ne les sauve — c'est le même violet des deux côtés. Elles passent par
`keyed_on_flat()`, qui fait couler le fond depuis le bord de la case : ce qui a
la couleur du fond mais s'en trouve isolé par un contour reste. Leur seuil est
écrit dans la table, case par case, et vérifié à l'œil sur la planche.
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
    # Relevé case par case : rose des vents à quatre pointes colorées · quatre
    # orbes en spirale vers un noyau · anneau doré à quatre sceaux // goutte au
    # bourgeon · silhouette dorée qui file · météores et onde de choc. Le
    # générateur a suivi l'ordre demandé sur cette planche — ce qui n'était vrai
    # ni pour le Feu ni pour l'Eau : on vérifie quand même, à chaque fois.
    "mage_supreme_skills.png": ("supreme", [
        "supreme_bolt", "supreme_convergence", "supreme_seals",
        "supreme_bloom", "supreme_shift", "supreme_judgement",
    # Sa grille laissait un filet gris à deux bords de chaque icône, comme l'Invocateur.
    ], {"inset": 0.025}),
    "mage_water_skills.png": ("water", [
        "water_jet", "water_wave", "water_geyser",
        "water_shield", "water_circle", "water_current",
    ]),
    # ⚠️ CES DEUX PLANCHES SONT DESSINÉES DANS LA COULEUR DE LA CLÉ, et c'est
    # pour ça qu'elles ont leur propre mode. Relevé sur l'histogramme des
    # teintes : le dessin du Feu vit entre 0 et 40°, à cent lieues du magenta ;
    # les flammes des Ténèbres et de l'Invocateur vivent entre 260 et 320°,
    # c'est-à-dire DANS la bande de la clé. Le détourage par teinte leur mangeait
    # donc le corps et ne laissait que les cernes blancs — six icônes réduites à
    # un trait, plus les lignes de séparation de la planche.
    #
    # Une clé par teinte ne peut PAS s'en sortir : il n'y a pas de seuil qui
    # sépare un violet de fond d'un violet de flamme quand c'est le même violet.
    # C'est la CONNEXITÉ qui travaille, comme pour les planches de personnage —
    # le fond est ce qui coule depuis le bord de la case, et le halo d'une
    # flamme, si proche du fond soit-il, n'y est relié que par des pixels qui
    # s'en écartent franchement.
    "mage_shadow_skills.png": ("shadow", [
        "shadow_orb", "shadow_rune", "shadow_blink",
        "shadow_burst", "shadow_step", "shadow_rift",
    # `lift` : violet sombre sur une case violet sombre, ses icônes étaient des taches.
    ], {"key": "flat", "flood": 80, "lift": True}),
    # L'Invocateur demande un seuil PLUS LARGE que les Ténèbres (110 contre 80)
    # et ce n'est pas un réglage au jugé : son fond est plus sombre
    # (226, 8, 222 contre 249, 4, 250) et ses halos roses s'en approchent
    # davantage. À 80, chaque icône traînait un lambeau de fond en forme de
    # halo ; à 140, la gargouille perdait son casque. Vérifié case par case.
    # Relevé case par case : aiguille · bulle à spirale · silhouette et ses échos //
    # sablier au cœur · flèche qui revient · cadran brisé. L'ordre demandé.
    "mage_chrono_skills.png": ("chrono", [
        "chrono_needle", "chrono_bubble", "chrono_echo",
        "chrono_hourglass", "chrono_rewind", "chrono_stop",
    # Le haut du sablier et du cadran dépasse au-dessus de la moitié de la planche.
    ], {"split_y": 490}),
    # Relevé case par case : dard · botte et flaques · goutte et ses trois filets //
    # cœur où les filets convergent · masque dans le gaz · fiole brisée. L'ordre demandé.
    "mage_peste_skills.png": ("peste", [
        "peste_dart", "peste_trail", "peste_contagion",
        "peste_transfusion", "peste_mist", "peste_pandemic",
    ]),
    # Relevé case par case : étoile et sa traînée · lance et son rayon · cercle d'or //
    # ailes refermées · aile, plumes et flèche · soleil. L'ordre demandé.
    "mage_lumiere_skills.png": ("lumiere", [
        "lumiere_dawn", "lumiere_lance", "lumiere_sanctuary",
        "lumiere_wings", "lumiere_flight", "lumiere_aube",
    # Le fond se reflète en rose sur son blanc, et le centre du cercle tire au violet.
    ], {"despill": True}),
    # Relevé case par case : croissant et plumes · faux et son arc · cloche //
    # trois âmes · plumes et flèche · éclipse. L'ordre demandé.
    "mage_mort_skills.png": ("mort", [
        "mort_crescent", "mort_moisson", "mort_glas",
        "mort_ames", "mort_passage", "mort_heure",
    ], {"despill": True}),
    # Relevé case par case : éclat et points · triangle d'étoiles · pluie //
    # croissant et voile · étoile filante · disque et comète. L'ordre demandé.
    "mage_etoiles_skills.png": ("etoiles", [
        "etoiles_eclat", "etoiles_constellation", "etoiles_pluie",
        "etoiles_voile", "etoiles_filante", "etoiles_nuit",
    # Pas de `despill` : il prend tout ce qui a plus de bleu que de vert, donc son bleu lui-même.
    ]),
    # Relevé case par case : marteau · éventail de lames · enclume //
    # bouclier d'ailes · épaulière · heaume en fusion. L'ordre demandé.
    "mage_acier_skills.png": ("acier", [
        "acier_marteau", "acier_ailes", "acier_enclume",
        "acier_rempart", "acier_charge", "acier_fusion",
    # Des grains isolés restent du fond : ils décentraient le bouclier en élargissant son cadre.
    ], {"undust": 12}),
    # Relevé case par case : griffure · sceau et goutte · flammes //
    # mâchoire · arc · sceau qui éclate. L'ordre demandé.
    "mage_demon_skills.png": ("demon", [
        "demon_griffe", "demon_pacte", "demon_sillon",
        "demon_festin", "demon_bond", "demon_dernier",
    ], {"undust": 12}),
    # Relevé case par case : fil et perle · œil aux fils · anneau et toile //
    # trois nœuds · flèches croisées · grand œil. L'ordre demandé.
    "mage_discorde_skills.png": ("discorde", [
        "discorde_murmure", "discorde_oeil", "discorde_cercle",
        "discorde_lien", "discorde_echange", "discorde_grande",
    ], {"undust": 12}),
    # Relevé case par case : poing et traînée · deux gantelets · plastron-four //
    # trois flèches · armure de cendre · cage couronnée. L'ordre demandé.
    "mage_braise_skills.png": ("braise", [
        "braise_poing", "braise_chasseurs", "braise_plastron",
        "braise_rappel", "braise_coquille", "braise_cages",
    ], {"undust": 12}),
    # Relevé case par case : croissant · lame et traits · sabre dans son cercle //
    # sabre au fourreau · flèche et pétales · coupes croisées. L'ordre demandé.
    "mage_ecarlate_skills.png": ("ecarlate", [
        "ecarlate_entaille", "ecarlate_pas", "ecarlate_garde",
        "ecarlate_rengaine", "ecarlate_volte", "ecarlate_derniere",
    ], {"undust": 12}),
    # Relevé case par case : poing et flammes · crochet et chaîne · cœur et trois fers //
    # anneau de givre · mur traversé · cercle et chaînes. L'ordre demandé.
    "mage_geolier_skills.png": ("geolier", [
        "geolier_poing", "geolier_crochet", "geolier_chaines",
        "geolier_souffle", "geolier_traversee", "geolier_geole",
    ], {"undust": 12}),
    # Relevé case par case : lance qui tombe sur son cercle · éventail de cinq plumes · colonne sur
    # anneau d'or // cloche et ses ondes · deux ailes sur une haie · épée et six ailes. L'ordre demandé.
    "mage_ciel_skills.png": ("ciel", [
        "ciel_lance", "ciel_plumes", "ciel_colonne",
        "ciel_cloche", "ciel_envol", "ciel_jugement",
    ], {"undust": 12}),
    "mage_invocateur_skills.png": ("invocateur", [
        "invoc_bolt", "invoc_imps", "invoc_gargoyle",
        "invoc_circle", "invoc_step", "invoc_dragon",
    ], {"key": "flat", "flood": 110, "inset": 0.025}),
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

    # ⚠️ LA CORRECTION DE COULEUR NE VAUT QU'AU BORD, et c'est la moitié de la
    # règle qui manquait. La « magenta-ité » mesure ce qu'un pixel a de rouge ET
    # de bleu en plus de son vert — mais c'est aussi la signature du VIOLET, du
    # bleu-violet et du pourpre. Appliquée partout, elle ne dégorgeait pas
    # seulement les bords : elle délavait l'intérieur des dessins. Mesuré sur la
    # planche du Suprême, dont les orbes sont violettes : (125, 76, 210) rendu
    # en (78, 122, 177) — la couleur avait changé de camp.
    #
    # L'atténuation d'ALPHA, elle, reste globale : c'est elle qui fait
    # disparaître le fond vu à travers un dôme de verre, et ce fond-là est bien
    # à l'intérieur du dessin.
    rim = ndimage.binary_dilation(background, iterations=3) & ~background
    for channel in (0, 2):
        blended = np.clip(rgb[..., channel] * (1.0 - spill)
                          + rgb[..., 1] * spill, 0, 255)
        data[..., channel] = np.where(rim, blended,
                                      rgb[..., channel]).astype(np.uint8)

    # ÉROSION DU CONTOUR — suppression des franges d'artefacts JPEG.
    #
    # La compression JPEG laisse 1-2 pixels contaminés en bordure : ils sont
    # à moitié magenta, à moitié icône, et forment une frange colorée visible
    # une fois le fond retiré. On érode le masque d'opacité de 2 pixels :
    # les pixels de bord entièrement opaques deviennent semi-transparents à
    # proportion de leur distance au bord, puis les tout-petits sont coupés.
    alpha_float = data[..., 3].astype(float) / 255.0
    # Masque binaire de ce qui est « bien opaque » avant érosion
    opaque = alpha_float > 0.5
    # Distance à la frontière : chaque pixel « vrai » sait combien de voisins
    # opaques le séparent du bord — on érode de 2 pixels.
    dist = ndimage.distance_transform_edt(opaque)
    ERODE_PX = 2
    eroded = np.clip(dist / float(ERODE_PX), 0.0, 1.0)
    data[..., 3] = (alpha_float * eroded * 255.0).astype(np.uint8)

    out = Image.fromarray(data, "RGBA")
    bounds = out.getbbox()
    return out.crop(bounds) if bounds else None


## Détourage sur fond UNI — les deux planches dessinées en violet.
##
## Le seuil ne sert qu'à FAIRE COULER le fond depuis le bord de la case : ce qui
## a la couleur du fond mais s'en trouve isolé par un contour reste. Le fondu
## n'est appliqué qu'au BORD de ce qui part, jamais à l'intérieur du dessin —
## même règle que `keyed_on_flat()` dans `build_characters.py`, et même raison.
FLAT_FADE = 0.5      # début du fondu, en fraction du seuil
FLAT_FADE_OUT = 1.3  # fin du fondu, au-delà du seuil : le pixel est opaque


def keyed_on_flat(cell: Image.Image, flood: int) -> Image.Image | None:
    rgb = np.asarray(cell.convert("RGB")).astype(int)
    border = np.concatenate([rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]])
    background = np.median(border, axis=0)
    distance = np.abs(rgb - background).max(axis=2)

    parts, _ = ndimage.label(distance < flood)
    edges = np.unique(np.concatenate(
        [parts[0], parts[-1], parts[:, 0], parts[:, -1]]))
    outside = np.isin(parts, edges[edges > 0])

    alpha = np.full(distance.shape, 255.0)
    alpha[outside] = 0.0
    rim = ndimage.binary_dilation(outside, iterations=3) & ~outside
    fade_in, fade_out = flood * FLAT_FADE, flood * FLAT_FADE_OUT
    alpha[rim] = np.clip((distance[rim] - fade_in) / (fade_out - fade_in),
                         0.0, 1.0) * 255.0

    # PAS de dégorgement ici, et c'est tout l'écart avec `keyed()`. La
    # « magenta-ité » est la signature du fond sur les six autres planches ;
    # sur celles-ci, c'est la signature du DESSIN. Appliquée, elle rendrait
    # translucide chaque flamme violette — soit l'icône entière.
    out = Image.fromarray(
        np.dstack([rgb.astype(np.uint8), alpha.astype(np.uint8)]), "RGBA")
    bounds = out.getbbox()
    return out.crop(bounds) if bounds else None


def undusted(icon: Image.Image, smallest: int) -> Image.Image:
    """Efface les taches de moins de `smallest` pixels, puis recadre sur ce qui reste."""
    data = np.array(icon)
    labels, count = ndimage.label(data[..., 3] > 30)
    sizes = ndimage.sum(np.ones(labels.shape), labels, range(1, count + 1))
    for label, size in enumerate(sizes, start=1):
        if size < smallest:
            data[labels == label, 3] = 0
    out = Image.fromarray(data, "RGBA")
    return out.crop(out.getbbox())


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


## Éclaircit le dessin et le cerne d'un filet pâle, qui fait un pixel à la taille de la
## barre d'action. La teinte ne change pas : le violet reste la couleur du mage.
LIFT_GAMMA = 0.62
LIFT_RIM_PX = 6
LIFT_RIM_COLOR = (226, 196, 255)


def lifted(icon: Image.Image) -> Image.Image:
    data = np.asarray(icon).astype(float)
    rgb = 255.0 * (data[..., :3] / 255.0) ** LIFT_GAMMA
    solid = data[..., 3] > 96
    rim = ndimage.binary_dilation(solid, iterations=LIFT_RIM_PX) & ~solid
    out = np.dstack([rgb, data[..., 3]])
    out[rim] = (*LIFT_RIM_COLOR, 255)
    return Image.fromarray(out.astype(np.uint8), "RGBA")


def main() -> None:
    for sheet_name, entry in SHEETS.items():
        character, names = entry[0], entry[1]
        options = entry[2] if len(entry) > 2 else {}
        path = SOURCE / sheet_name
        if not path.exists():
            print(f"  ! {sheet_name} introuvable")
            continue
        with Image.open(path) as raw:
            sheet = raw.convert("RGB")
        cell_w = sheet.width // COLUMNS
        cell_h = sheet.height // ROWS

        # MARGE DE DÉCOUPE. La planche de l'Invocateur sépare ses cases par une
        # LIGNE BLANCHE de six pixels, posée à cheval sur la coupe : chaque
        # icône en héritait d'un morceau, et c'est ce qui dessinait les équerres
        # blanches qu'on voyait dans le menu. Une marge de 2,5 % la laisse
        # dehors — les dessins, eux, ne touchent jamais le bord de leur case.
        inset = int(round(min(cell_w, cell_h) * options.get("inset", 0.0)))

        out_dir = OUT / character
        out_dir.mkdir(parents=True, exist_ok=True)
        written = []
        for index, name in enumerate(names):
            column, row = index % COLUMNS, index // COLUMNS
            box = (column * cell_w + inset, row * cell_h + inset,
                   (column + 1) * cell_w - inset, (row + 1) * cell_h - inset)
            if "split_y" in options:
                split = options["split_y"]
                box = (box[0], 0 if row == 0 else split, box[2], split if row == 0 else sheet.height)
            cell = sheet.crop(box)
            cut = (keyed_on_flat(cell, options["flood"])
                   if options.get("key") == "flat" else keyed(cell))
            if cut is None:
                print(f"  ! {name} : rien après détourage")
                continue
            if options.get("undust"):
                cut = undusted(cut, options["undust"])
            icon = fitted(cut)
            if options.get("despill"):
                data = np.array(icon)
                spill = data[..., 2] > data[..., 1]
                data[..., 1] = np.where(spill, data[..., 0] * 0.945, data[..., 1]).astype(np.uint8)
                data[..., 2] = np.where(spill, data[..., 0] * 0.72, data[..., 2]).astype(np.uint8)
                icon = Image.fromarray(data, "RGBA")
            if options.get("lift"):
                icon = lifted(icon)
            icon.save(out_dir / f"{name}.png")
            written.append(name)
            print(f"{character}/{name:12s} {cut.size} -> {ICON_SIZE}x{ICON_SIZE}")
        (out_dir / "icons.json").write_text(
            json.dumps({"icons": written, "size": ICON_SIZE}, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
