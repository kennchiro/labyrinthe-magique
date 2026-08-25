#!/usr/bin/env python3
"""Le décor et la maison de chaque stage, détourés de sa planche d'ambiance.

    tools/.venv/bin/python tools/build_stage_props.py     # DEPUIS LA RACINE

Chaque planche porte un vrai jeu de props — temples, obélisques, palmiers,
torches, tentes, charrettes — et le jeu n'en utilisait aucun : il semait partout
les mêmes champignons verts, y compris dans les dunes et sur la banquise.

POURQUOI DES BOÎTES À LA MAIN. Trois détections automatiques ont été essayées et
jetées :

  - alpha : il n'y en a pas, ces planches ont un fond opaque ;
  - contraste local + composantes connexes : marche sur la planche 1, dont les
    props sont espacés ; ailleurs ils se touchent BORD À BORD et tout fusionne
    en un seul bloc couvrant 85 % du panneau ;
  - creux de gradient (la découpe classique d'une planche serrée) : il n'y a
    aucune ligne creuse, ni en lignes ni en colonnes.

Le relevé reste donc manuel, mais GROSSIER : la boîte n'a pas besoin d'être
juste. À l'intérieur, l'outil calcule le masque de contraste et ne garde que la
PLUS GROSSE forme — ce qui élimine les bouts de voisins qui dépassent dans le
cadre. C'est ce qui rend le relevé rapide : viser large, laisser trancher.

Quatre rôles par stage, et pas plus. Il ne s'agit pas de reproduire le
catalogue, mais de rendre chaque stage reconnaissable :

    maison    l'îlot du stage — sa propre planche, voir MAISON_SHEET
    lisiere   ce qui borde le labyrinthe
    lueur     ce qui éclaire
    semis     ce qui traîne dans les couloirs
"""

from pathlib import Path
import json
import numpy as np
from PIL import Image
from scipy import ndimage

SOURCE = Path("assets/stages")
OUT = Path("assets/stages/props")

## stage -> rôle -> boîtes (x0, y0, x1, y1) relevées sur la planche.
##
## Plus de `maison` ici : les monuments viennent désormais de leur propre
## planche (voir MAISON_SHEET), où l'illustrateur les a déjà détourés. Ce qui
## était découpé des planches d'ambiance — un temple noyé dans sa scène peinte,
## qu'aucune clé ne séparait de son herbe — n'avait pas de quoi rivaliser.
BOXES = {
    1:  {"lisiere": [(940, 20, 1030, 178)],
         "lueur":   [(1022, 15, 1110, 135)],
         "semis":   [(691, 470, 790, 560), (860, 470, 950, 560)]},
    2:  {"lisiere": [(1113, 20, 1195, 180)],
         "lueur":   [(1282, 96, 1360, 200)],
         "semis":   [(1029, 470, 1120, 560), (691, 470, 790, 560)]},
    3:  {"lisiere": [(1105, 90, 1195, 265)],
         "lueur":   [(1275, 15, 1360, 105)],
         "semis":   [(691, 320, 790, 420), (691, 470, 790, 560)]},
    4:  {"lisiere": [(1025, 15, 1110, 175)],
         "lueur":   [(1198, 96, 1285, 205)],
         "semis":   [(691, 400, 790, 490), (691, 478, 800, 570)]},
    5:  {"lisiere": [(1113, 20, 1195, 180)],
         "lueur":   [(1282, 172, 1365, 265)],
         "semis":   [(691, 325, 790, 420), (691, 470, 800, 565)]},
    6:  {"lisiere": [(1113, 20, 1195, 180)],
         "lueur":   [(1198, 96, 1285, 205)],
         "semis":   [(691, 401, 790, 495), (691, 478, 795, 570)]},
    7:  {"lisiere": [(1029, 20, 1110, 265)],
         "lueur":   [(1198, 172, 1285, 275)],
         "semis":   [(691, 325, 790, 415), (691, 470, 795, 560)]},
    8:  {"lisiere": [(1113, 96, 1195, 265)],
         "lueur":   [(1367, 172, 1455, 275)],
         "semis":   [(691, 401, 795, 495), (691, 478, 795, 570)]},
    # Planche 9 REMPLACÉE le 2026-08-24 : l'ancienne était un JPEG de tuiles sur
    # damier, la nouvelle est une vraie planche d'ambiance au format des autres.
    # Toutes ses boîtes sont donc remesurées — les anciennes visaient une mise en
    # page qui n'existe plus et rendaient quatre bouts de mur.
    9:  {"lisiere": [(785, 325, 925, 505)],
         "lueur":   [(1190, 364, 1242, 506)],
         "semis":   [(1002, 532, 1082, 598), (1112, 516, 1196, 594)]},
    # Le château flotte sur son îlot, et la planche en aligne d'AUTRES juste à
    # côté : la boîte s'arrête donc avant la tour voisine (x 1030) et sous la
    # roche de l'îlot (y 320), sans le nuage qui passe dessous.
    10: {"maison":  [(738, 8, 1030, 318)],
         "lisiere": [(1113, 20, 1195, 180)],
         "lueur":   [(1282, 172, 1365, 270)],
         "semis":   [(691, 470, 795, 565), (860, 470, 960, 565)]},
}

## Décalage du panneau : les boîtes sont relevées sur la PLANCHE entière.
CONTRAST = 8.0

# --- La maison de chaque stage ----------------------------------------------------
#
# `maison_stage.png` remplace les monuments découpés des planches d'ambiance :
# dix îlots flottants, un par stage, dans l'ordre — cinq par rangée. Chacun porte
# le portail du stage et son décor (l'arbre de la forêt, la foudre du canyon, le
# navire échoué des rivages, les nuages du château du ciel).
#
# Rien à détourer ici, et c'est le point : la planche a un VRAI canal alpha et
# les dix îlots y sont dix formes connexes. Le travail se réduit à trois règles
# mesurées :
#
#   - regrouper par CASE de la grille 5x2, pour que les rochers flottants
#     restent avec leur île — ils en sont détachés mais lui appartiennent
#     (mesuré : tous à moins de 15 px, sauf quatre poussières au-delà de 26) ;
#   - recadrer sur l'alpha VISIBLE et non sur tout pixel non nul. Le halo de
#     lueur descend jusqu'à alpha 4 et gonfle la boîte de 24 px à gauche et 33
#     en haut — invisible à l'écran, mais le jeu dimensionne la maison sur la
#     largeur de sa texture, donc l'île se serait affichée 10 % trop petite ;
#   - jeter ce qui traîne à plus de 26 px de tout îlot.
MAISON_SHEET = SOURCE / "../peso&cover/decor/maison_stage.png"
MAISON_COLUMNS = 5
MAISON_ROWS = 2
## En dessous, un pixel appartient au halo et non au dessin.
MAISON_VISIBLE = 10
## Une forme plus éloignée que ça d'un îlot ne lui appartient pas.
MAISON_ORPHAN = 26.0
## Une forme plus grosse que ça EST un îlot.
MAISON_ISLAND = 8000


def build_maisons() -> dict:
    """Découpe les dix îlots. Rend {stage: Image}."""
    with Image.open(MAISON_SHEET) as raw:
        sheet = raw.convert("RGBA")
    alpha = np.array(sheet)[..., 3]
    labels, count = ndimage.label(alpha > 40, structure=np.ones((3, 3)))
    areas = ndimage.sum(np.ones_like(labels), labels, range(1, count + 1))
    islands = [i + 1 for i, area in enumerate(areas) if area > MAISON_ISLAND]
    if len(islands) != MAISON_COLUMNS * MAISON_ROWS:
        raise SystemExit(f"maison_stage : {len(islands)} îlots trouvés, "
                         f"{MAISON_COLUMNS * MAISON_ROWS} attendus")

    # Les rochers flottants d'une île en sont détachés : on les lui rend en
    # mesurant leur distance, plutôt qu'en supposant qu'ils la touchent.
    distance = ndimage.distance_transform_edt(~np.isin(labels, islands))
    height, width = alpha.shape
    cell = (width / float(MAISON_COLUMNS), height / float(MAISON_ROWS))
    groups: dict = {}
    for index in range(1, count + 1):
        member = labels == index
        if index not in islands and distance[member].min() > MAISON_ORPHAN:
            continue
        ys, xs = np.nonzero(member)
        stage = (int(ys.mean() // cell[1]) * MAISON_COLUMNS
                 + int(xs.mean() // cell[0])) + 1
        groups.setdefault(stage, []).append(member)

    out = {}
    visible = alpha > MAISON_VISIBLE
    for stage, members in sorted(groups.items()):
        keep = np.logical_or.reduce(members)
        ys, xs = np.nonzero(keep & visible)
        box = (int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1)
        piece = np.array(sheet.crop(box))
        # Hors de l'île retenue, rien ne subsiste — pas même le halo de la
        # voisine, qui déborde parfois dans la boîte.
        piece[..., 3] = np.where(keep[box[1]:box[3], box[0]:box[2]], piece[..., 3], 0)
        out[stage] = Image.fromarray(piece, "RGBA")
    return out


ROLES = ("maison", "lisiere", "lueur", "semis")


## Part de la boîte considérée comme son CŒUR : une forme qui n'y touche pas
## n'est pas le monument.
CORE_SHARE = 0.62


def _central_mass(subject: np.ndarray) -> np.ndarray:
    """Ne garde que ce qui touche le CŒUR de la boîte.

    Le monument est visé au centre ; ce qui flotte sur les bords appartient à la
    scène — une branche de l'arbre voisin, un corail, un bout du temple d'à
    côté. Ce sont eux qu'on voyait accrochés à la maison en jeu."""
    height, width = subject.shape
    ys, xs = np.mgrid[0:height, 0:width]
    core = (((xs - width * 0.5) / (width * CORE_SHARE * 0.5)) ** 2
            + ((ys - height * 0.5) / (height * CORE_SHARE * 0.5)) ** 2) <= 1.0
    labels, count = ndimage.label(subject, structure=np.ones((3, 3)))
    if count == 0:
        return subject
    kept = np.unique(labels[core & subject])
    kept = kept[kept > 0]
    return np.isin(labels, kept) if kept.size else subject


def carve_damier(sheet: Image.Image, box: tuple) -> Image.Image | None:
    """Détourage sur fond DAMIER : le fond est un gris neutre et clair.

    Un pixel de damier n'a presque pas d'écart entre ses canaux (gris) et reste
    clair — deux propriétés qu'aucun prop de cette planche ne partage, tout y
    est mousse, pierre teintée ou lueur. Pas de flood-fill nécessaire.
    """
    crop = sheet.crop(box).convert("RGBA")
    pixels = np.asarray(crop).astype(int)[..., :3]
    spread = pixels.max(axis=2) - pixels.min(axis=2)
    luma = pixels @ np.array([0.299, 0.587, 0.114]) / 255.0 * 255
    background = (spread < 16) & (luma > 165)
    data = np.array(crop)
    # Même règle que les monuments : ce qui ne touche pas le cœur de la boîte
    # appartient à la planche, pas au prop. Sans elle, la maison du stage 9
    # traînait un bloc de ruine de la vignette voisine.
    data[..., 3] = np.where(_central_mass(~background), 255, 0)
    out = Image.fromarray(data, "RGBA")
    bounds = out.getbbox()
    return out.crop(bounds) if bounds else None


def carve(sheet: Image.Image, box: tuple) -> Image.Image | None:
    """Découpe une boîte et n'en garde que la forme principale."""
    crop = sheet.crop(box).convert("RGBA")
    pixels = np.asarray(crop).astype(float)[..., :3]
    gray = pixels @ np.array([0.299, 0.587, 0.114])
    mean = ndimage.uniform_filter(gray, 5)
    deviation = np.sqrt(np.maximum(ndimage.uniform_filter(gray * gray, 5) - mean * mean, 0.0))
    mask = ndimage.binary_fill_holes(
        ndimage.binary_closing(deviation > CONTRAST, np.ones((7, 7))))

    labels, count = ndimage.label(mask, structure=np.ones((3, 3)))
    if count == 0:
        return None
    areas = ndimage.sum(np.ones_like(labels), labels, range(1, count + 1))

    # La plus grosse forme n'est pas toujours le prop : sur les planches dont le
    # FOND est texturé (les ruines, le château), c'est le fond lui-même qui
    # gagne. Une forme qui remplit presque toute la boîte est donc écartée —
    # un prop laisse forcément du vide autour de lui.
    total = float(mask.size)
    order = np.argsort(areas)[::-1]
    keep = int(order[0]) + 1
    for candidate in order:
        if areas[candidate] / total <= 0.72:
            keep = int(candidate) + 1
            break
    data = np.array(crop)
    data[..., 3] = np.where(labels == keep, 255, 0)
    out = Image.fromarray(data, "RGBA")
    bounds = out.getbbox()
    return out.crop(bounds) if bounds else None


def main() -> None:
    maisons = build_maisons()
    print(f"maisons : {len(maisons)} îlots depuis {MAISON_SHEET.name}")
    for stage, roles in sorted(BOXES.items()):
        path = SOURCE / f"stage_{stage}.png"
        if not path.exists():
            path = SOURCE / f"stage_{stage}.jpeg"
        if not path.exists():
            print(f"  ! stage_{stage} introuvable")
            continue
        with Image.open(path) as raw:
            sheet = raw.convert("RGB")
            out_dir = OUT / f"stage_{stage}"
            manifest = {}
            for role in ROLES:
                folder = out_dir / role
                folder.mkdir(parents=True, exist_ok=True)
                for old in folder.glob("*.png"):
                    old.unlink()
                names = []
                if role == "maison" and stage in maisons:
                    cut = maisons[stage]
                    cut.save(folder / "maison_0.png")
                    manifest[role] = [{"file": "maison_0.png",
                                       "w": cut.width, "h": cut.height}]
                    continue
                for rank, box in enumerate(roles.get(role, [])):
                    if path.suffix == ".jpeg":
                        cut = carve_damier(sheet, box)
                    else:
                        cut = carve(sheet, box)
                    if cut is None:
                        print(f"  ! stage {stage} {role} {box} : rien de détouré")
                        continue
                    name = f"{role}_{rank}.png"
                    cut.save(folder / name)
                    names.append({"file": name, "w": cut.width, "h": cut.height})
                manifest[role] = names
            (out_dir / "props.json").write_text(
                json.dumps(manifest, indent=2), encoding="utf-8")
        summary = " · ".join(f"{r} {len(manifest[r])}" for r in ROLES)
        print(f"stage {stage:2d}  {summary}")


if __name__ == "__main__":
    main()
