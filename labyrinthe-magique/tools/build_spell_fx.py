#!/usr/bin/env python3
"""Les effets de pouvoir dessinés de chaque mage, découpés de sa planche.

    tools/.venv/bin/python tools/build_spell_fx.py     # DEPUIS LA RACINE

Trois familles par mage, vers `assets/characters/<id>/` :

    orb.png     le projectile — ANIMÉ quand la planche en dessine les phases
                (le Feu a quatre comètes) ; orb.json donne le nombre d'images
    impact.png  l'éclat du coup au but — le vortex de flammes, la frappe de
                foudre au sol, la tornade
    zone.png    le cercle au sol du sort de zone — l'anneau de feu, le cercle
                de pierres, l'anneau d'or de la foudre

L'orbe du jeu était UNE bille générique teintée par élément : le trait de
flamme du Mage du Feu et le jet d'eau du Mage de l'Eau étaient la même bille en
deux couleurs. Les impacts et les zones, eux, étaient entièrement procéduraux —
bons pour les particules, muets sur l'identité. Le dessin devient la pièce
maîtresse, le procédural reste l'habillage.

Les boîtes sont relevées à la main, GROSSIÈRES, et l'outil recadre sur la plus
grosse forme d'alpha à l'intérieur — même recette que les colonnes de
téléportation : sur ces planches l'alpha existe, seule la sélection est un
jugement.
"""

from pathlib import Path
import json
from PIL import Image
import numpy as np
from scipy import ndimage

SOURCE = Path("assets/peso&cover/mages")
OUT = Path("assets/characters")

SHEETS = {
    "fire": "mage_fire.png", "water": "mage_circle.png", "earth": "mage_earth.png",
    "shadow": "mage_dark.png", "supreme": "mage_element.png",
    "thunder": "mage_thunder.png", "air": "mage_wind.png",
}

## id -> (liste de boîtes — plusieurs = animation, pointe_vers, mode)
## `pointe_vers` : direction du dessin. Le jeu oriente l'orbe le long du vol,
## il faut donc savoir où regarde la comète — une comète qui vole cul en avant
## se remarque immédiatement.
## `mode` : "formes" (le dessin entier, par formes connexes) ou "fenetre"
## (découpe stricte à la boîte, pour les dessins aux lueurs jointives).
ORBS = {
    "fire":    ([(1103, 446, 1192, 524), (1192, 446, 1276, 524),
                 (1276, 446, 1363, 524), (1363, 446, 1449, 524)], "none", "formes"),
    # ⚠️ PAS de retournement : la comète de la planche pointe DÉJÀ vers la
    # droite, c'est-à-dire vers le zéro de rotation de Godot. La retourner la
    # faisait voler à reculons — tête en arrière, queue devant — et le défaut
    # ne se voit qu'en tirant vers la droite, jamais sur une capture fixe.
    "water":   ([(1175, 632, 1278, 706)], "none", "formes"),
    # Les pierres volantes de la rangée d'effets — le seul dessin de la planche
    # qui se lise comme un jet ; les cristaux, eux, sont tous scellés à un socle.
    "earth":   ([(924, 596, 1018, 694)], "none", "formes"),
    "shadow":  ([(1443, 296, 1536, 392)], "none", "formes"),
    # L'ORBITE GÉANTE multicolore — l'anneau irisé de la rangée du bas, la
    # signature du Suprême : toutes les couleurs des six éléments à la fois.
    "supreme": ([(1112, 596, 1252, 734)], "none", "formes"),
    "thunder": ([(1035, 378, 1140, 468)], "none", "formes"),
    "air":     ([(1040, 378, 1140, 472)], "none", "formes"),
}

IMPACTS = {
    "fire":    (1288, 585, 1398, 700),   # le vortex de flammes
    "water":   (1328, 636, 1422, 706),   # l'étoile d'éclaboussure
    "earth":   (1292, 590, 1376, 692),   # le tourbillon d'énergie verte
    "shadow":  (1436, 438, 1536, 600),   # la colonne de fumée violette
    "supreme": (952, 601, 1111, 738),    # la galaxie irisée
    # LA FRAPPE BLEUE, avec son anneau au sol. Deux boîtes jetées avant
    # celle-ci : la première décapitait les éclairs (ils commencent à y=362, pas
    # 422), la seconde rendait un fragment bleu illisible de 96 x 84 — une
    # bouillie signalée par l'utilisateur. Celle-ci prend la décharge ENTIÈRE,
    # du haut des éclairs au bas de l'anneau, en écartant le trait d'or voisin.
    # ⚠️ TROISIÈME boîte. La deuxième (1262, 362, 1352, 516) tranchait le dessin
    # des DEUX côtés : la pointe des éclairs commence à y=352 et la branche de
    # droite va jusqu'à x=1372. Le résultat, signalé par l'utilisateur comme
    # « cassé », était un buisson bleu étêté. Mesurée au quadrillage : le dessin
    # entier tient dans (1256, 348) - (1376, 508), anneau au sol compris.
    "thunder": ("window", 1256, 348, 1376, 508),
    "air":     (1270, 436, 1370, 546),   # la tornade
}

## Éléments SUPPLÉMENTAIRES d'une planche, découpés à part de la triade
## orbe/impact/zone : ils servent à des sorts particuliers.
##
## Les nuages de la planche de la Foudre en sont l'exemple : ils étaient là
## depuis le début, dessinés avec leurs éclairs, et le jeu affichait à leur
## place des ronds gris tracés en code. On ne dessine à la main que ce que la
## planche ne fournit pas.
EXTRAS = {
    "thunder": {
        "cloud": (1137, 542, 1243, 672),      # nuage bleu et son éclair
        "cloud_dark": (1230, 542, 1336, 672), # nuage d'orage, plus sombre
        "bolt": (1343, 545, 1409, 649),       # l'éclair seul
        # Le blason au foudre. Il paraît AU LANCEMENT DE L'EXTRA, droit et
        # transparent au-dessus du mage — jamais en rotation : une emblème qui
        # tourne se lit comme un objet ramassable qui vole.
        "crest": (1396, 352, 1514, 510),
    },
    # L'Air : ses TORNADES dessinées, dont le jeu n'employait aucune — la
    # Tornade s'affichait avec l'anneau de vent générique des zones.
    "air": {
        "tornado": (1262, 22, 1390, 175),        # la grande, en détail
        "tornado_small": (1186, 180, 1294, 328), # l'entonnoir étroit
        "curl": (1316, 193, 1360, 278),          # la volute, une lame d'air
    },
    # La Terre : ses PICS étaient dessinés depuis le début, en trois tailles,
    # pendant que « Pics de terre » s'affichait comme un éclat circulaire
    # générique. Même histoire que les nuages de la Foudre.
    "earth": {
        "spikes": (1284, 16, 1388, 176),       # la gerbe de pierre, taille d'une case
        "spikes_big": (1396, 20, 1526, 180),   # la même, avec ses cristaux
        "dust": (1400, 550, 1526, 650),        # la motte de terre soulevée
        # L'ÉGIDE et ce en quoi elle se disperse : la coque de pierre à son
        # cristal, puis les cailloux et les étoiles vertes qui tournent autour
        # du mage tant qu'il est intouchable.
        # Mesurée au quadrillage après une première coupe qui tranchait la
        # pierre à GAUCHE (1388 alors qu'elle commence à 1375), à droite, et
        # la poussière du bas. La coque entière tient dans cette boîte.
        "aegis": (1372, 356, 1524, 516),
        # Le cristal PLANTÉ, avec son socle de pierre : le sort qui se bat
        # tout seul. Il était dessiné, lui aussi.
        "crystal": (1086, 192, 1194, 352),
        # CE QUE LE MAGE MET EN ORBITE ET LANCE : le gros rocher rond fendu et
        # le grand cristal vert. Les premiers essais employaient un caillou et
        # un éclat minuscules — signalés comme invisibles en jeu, et ils
        # l'étaient : vingt pixels de haut.
        "boulder": (1074, 66, 1156, 154),
        "gem": (1106, 371, 1159, 458),
        # L'ÉCLAT qui part du cristal : le petit cristal dessiné à côté du
        # pilier, sur la planche. Le tir alterne avec `rock` — du cristal ET de
        # la pierre, puisque c'est ce que le sort arrache au sol.
        "shard": (1160, 266, 1182, 292),
        "rock": (982, 556, 1016, 596),
        "spark": (1136, 548, 1176, 598),
    },
}

ZONES = {
    "fire":    (1092, 583, 1240, 696),   # l'anneau de feu
    "water":   (1374, 298, 1462, 386),   # l'anneau d'eau
    "earth":   (1011, 448, 1106, 526),   # le cercle de pierres
    "shadow":  (1204, 294, 1300, 386),   # le vortex d'ombre
    "supreme": (1090, 522, 1196, 602),   # l'anneau violet
    "thunder": (1012, 446, 1110, 526),   # l'anneau d'or
    "air":     (1008, 440, 1112, 538),   # l'anneau de vent
}


class SheetShapes:
    """Les formes connexes d'une planche, étiquetées UNE fois.

    La boîte relevée à la main ne fait que DÉSIGNER : on retient les formes
    dont le centre tombe dedans, puis on prend leur étendue RÉELLE sur la
    planche — même quand elle déborde de la boîte. Les deux règles précédentes
    amputaient les dessins : « la plus grosse forme » ne gardait qu'une langue
    d'un anneau de flammes, et « jeter ce qui touche le bord » déchirait tout
    dessin dont la lueur dépassait la boîte. Ici, rien n'est jamais coupé :
    un dessin est pris en entier ou pas du tout.
    """

    def __init__(self, sheet: Image.Image):
        self.sheet = sheet
        alpha = np.asarray(sheet)[..., 3] > 40
        self.labels, count = ndimage.label(alpha, structure=np.ones((3, 3)))
        ones = np.ones_like(self.labels)
        self.centres = ndimage.center_of_mass(ones, self.labels, range(1, count + 1))
        self.slices = ndimage.find_objects(self.labels)
        self.areas = ndimage.sum(ones, self.labels, range(1, count + 1))

    def inside(self, box: tuple) -> list:
        x0, y0, x1, y1 = box
        found = []
        for index, (cy, cx) in enumerate(self.centres):
            if x0 <= cx < x1 and y0 <= cy < y1 and self.areas[index] >= 30:
                found.append(index + 1)
        return found

    def window(self, box: tuple) -> Image.Image | None:
        """Découpe STRICTE à la boîte, pour les dessins aux lueurs jointives.

        Quand deux dessins se touchent par leur halo, ils ne font qu'UNE forme
        connexe : la sélection par centre rend alors le bloc entier (les trois
        orbes du Suprême, la frappe de foudre soudée à son bouclier). Ici on
        tranche au bord de la boîte — couper un halo diffus se voit à peine,
        embarquer un bouclier entier se voit beaucoup.
        """
        out = self.sheet.crop(box)
        bounds = out.getbbox()
        return out.crop(bounds) if bounds else None

    def cut(self, box: tuple, points: str = "none", solo: bool = False) -> Image.Image | None:
        chosen = self.inside(box)
        if not chosen:
            return None
        if solo:
            # Un PROJECTILE est une forme unique : s'il y en a plusieurs dans la
            # boîte, la plus grosse est le sujet, les autres sont des voisines.
            chosen = [max(chosen, key=lambda i: self.areas[i - 1])]
        rows = [self.slices[i - 1][0] for i in chosen]
        cols = [self.slices[i - 1][1] for i in chosen]
        top, bottom = min(r.start for r in rows), max(r.stop for r in rows)
        left, right = min(c.start for c in cols), max(c.stop for c in cols)
        window = self.labels[top:bottom, left:right]
        data = np.array(self.sheet.crop((left, top, right, bottom)))
        data[..., 3] = np.where(np.isin(window, chosen), data[..., 3], 0)
        out = Image.fromarray(data, "RGBA")
        if points == "left":
            # Réorienté vers la DROITE : le zéro de rotation de Godot.
            out = out.transpose(Image.FLIP_LEFT_RIGHT)
        return out


def strip(frames: list) -> tuple:
    """Bande d'animation : chaque image centrée dans une case commune."""
    cell_w = max(f.width for f in frames)
    cell_h = max(f.height for f in frames)
    band = Image.new("RGBA", (cell_w * len(frames), cell_h), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        band.alpha_composite(frame, (i * cell_w + (cell_w - frame.width) // 2,
                                     (cell_h - frame.height) // 2))
    return band, (cell_w, cell_h)


def main() -> None:
    for cid, sheet_name in SHEETS.items():
        path = SOURCE / sheet_name
        if not path.exists():
            print(f"  ! {sheet_name} introuvable")
            continue
        with Image.open(path) as image:
            shapes = SheetShapes(image.convert("RGBA"))
        out_dir = OUT / cid
        out_dir.mkdir(parents=True, exist_ok=True)

        boxes, points, mode = ORBS[cid]
        if mode == "fenetre":
            frames = []
            for box in boxes:
                frame = shapes.window(box)
                if frame is not None:
                    if points == "left":
                        frame = frame.transpose(Image.FLIP_LEFT_RIGHT)
                    frames.append(frame)
        else:
            frames = [f for f in (shapes.cut(box, points, True) for box in boxes) if f is not None]
        report = []
        if frames:
            band, cell = strip(frames)
            band.save(out_dir / "orb.png")
            (out_dir / "orb.json").write_text(json.dumps(
                {"frames": len(frames), "cell": list(cell)}), encoding="utf-8")
            report.append(f"orbe x{len(frames)} {cell}")

        for name, box in EXTRAS.get(cid, {}).items():
            drawn = shapes.window(box)
            if drawn is None:
                print(f"  ! {cid} : rien dans la boîte {name}")
                continue
            drawn.save(out_dir / f"{name}.png")
            report.append(f"{name} {drawn.size}")

        for name, table in (("impact", IMPACTS), ("zone", ZONES)):
            entry = table[cid]
            if entry[0] == "window":
                drawn = shapes.window(entry[1:])
            else:
                drawn = shapes.cut(entry)
            if drawn is None:
                print(f"  ! {cid} : rien dans la boîte {name}")
                continue
            drawn.save(out_dir / f"{name}.png")
            report.append(f"{name} {drawn.size}")
        print(f"{cid:8s} " + " · ".join(report))


if __name__ == "__main__":
    main()
