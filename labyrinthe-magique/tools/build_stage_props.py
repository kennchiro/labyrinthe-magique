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

    maison    le monument du stage — remplace la maisonnette de la forêt
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
BOXES = {
    1:  {"maison":  [(685, 115, 960, 350)],
         "lisiere": [(940, 20, 1030, 178)],
         "lueur":   [(1022, 15, 1110, 135)],
         "semis":   [(691, 470, 790, 560), (860, 470, 950, 560)]},
    2:  {"maison":  [(855, 30, 1115, 340)],
         "lisiere": [(1113, 20, 1195, 180)],
         "lueur":   [(1282, 96, 1360, 200)],
         "semis":   [(1029, 470, 1120, 560), (691, 470, 790, 560)]},
    3:  {"maison":  [(758, 15, 1060, 330)],
         "lisiere": [(1105, 90, 1195, 265)],
         "lueur":   [(1275, 15, 1360, 105)],
         "semis":   [(691, 320, 790, 420), (691, 470, 790, 560)]},
    4:  {"maison":  [(765, 12, 985, 310)],
         "lisiere": [(1025, 15, 1110, 175)],
         "lueur":   [(1198, 96, 1285, 205)],
         "semis":   [(691, 400, 790, 490), (691, 478, 800, 570)]},
    5:  {"maison":  [(770, 15, 1070, 325)],
         "lisiere": [(1113, 20, 1195, 180)],
         "lueur":   [(1282, 172, 1365, 265)],
         "semis":   [(691, 325, 790, 420), (691, 470, 800, 565)]},
    6:  {"maison":  [(745, 25, 1090, 340)],
         "lisiere": [(1113, 20, 1195, 180)],
         "lueur":   [(1198, 96, 1285, 205)],
         "semis":   [(691, 401, 790, 495), (691, 478, 795, 570)]},
    7:  {"maison":  [(765, 15, 1045, 340)],
         "lisiere": [(1029, 20, 1110, 265)],
         "lueur":   [(1198, 172, 1285, 275)],
         "semis":   [(691, 325, 790, 415), (691, 470, 795, 560)]},
    8:  {"maison":  [(770, 15, 1115, 350)],
         "lisiere": [(1113, 96, 1195, 265)],
         "lueur":   [(1367, 172, 1455, 275)],
         "semis":   [(691, 401, 795, 495), (691, 478, 795, 570)]},
    # La planche 9 est un JPEG sur DAMIER : le fond n'est ni uniforme ni
    # texturé, c'est un échiquier de gris neutres aplati dans les pixels.
    # Elle a son propre détourage — voir `carve_damier`.
    9:  {"maison":  [(720, 13, 971, 288)],
         "lisiere": [(633, 260, 738, 422)],
         "lueur":   [(1071, 6, 1123, 121)],
         "semis":   [(745, 290, 851, 362), (697, 418, 772, 478)]},
    10: {"maison":  [(770, 12, 1108, 350)],
         "lisiere": [(1113, 20, 1195, 180)],
         "lueur":   [(1282, 172, 1365, 270)],
         "semis":   [(691, 470, 795, 565), (860, 470, 960, 565)]},
}

## Décalage du panneau : les boîtes sont relevées sur la PLANCHE entière.
CONTRAST = 8.0
ROLES = ("maison", "lisiere", "lueur", "semis")


## Tolérance de la clé de fond, en distance RGB.
KEY_TOLERANCE = 58.0
## Largeur du fondu de bordure d'un monument, en pixels.
FEATHER = 14


def keyed(crop: Image.Image) -> Image.Image | None:
    """Détoure un MONUMENT : clé de fond depuis les bords, puis fondu.

    Le masque de contraste ne sert à rien ici : un temple occupe presque toute
    sa boîte, et le fond qui l'entoure est lui-même texturé. On part donc des
    BORDS, dont on sait qu'ils sont du fond, et on efface tout ce qui leur
    ressemble et qui leur est connecté. QUATRE références (une par côté) plutôt
    qu'une médiane globale : un ciel en dégradé n'a pas la même couleur en haut
    qu'en bas, et la médiane unique laissait des coins de décor.

    Puis un FONDU DE BORDURE, dans tous les cas. C'est le filet des planches
    dont le fond est une SCÈNE peinte (la clairière du stage 1, la jungle du 7) :
    aucune clé ne détoure une forêt, et la découpe rendait un rectangle à bords
    droits posé au milieu du labyrinthe. Avec le fondu, ce qui n'a pas pu être
    détouré s'éteint en vignette — le monument semble poser sur son propre
    terrain au lieu d'être un autocollant carré.
    """
    pixels = np.asarray(crop).astype(float)[..., :3]
    references = [np.median(pixels[0], axis=0), np.median(pixels[-1], axis=0),
                  np.median(pixels[:, 0], axis=0), np.median(pixels[:, -1], axis=0)]
    close = np.zeros(pixels.shape[:2], dtype=bool)
    for reference in references:
        close |= np.sqrt(((pixels - reference) ** 2).sum(axis=2)) < KEY_TOLERANCE

    data = np.array(crop)
    alpha = data[..., 3].astype(float)
    labels, count = ndimage.label(close, structure=np.ones((3, 3)))
    if count > 0:
        edge = set(labels[0]) | set(labels[-1]) | set(labels[:, 0]) | set(labels[:, -1])
        edge.discard(0)
        background = np.isin(labels, list(edge))
        if background.mean() <= 0.9:
            alpha = np.where(background, 0.0, alpha)

    # Fondu : la distance au bord de la boîte, bornée à FEATHER pixels.
    height, width = alpha.shape
    ys = np.minimum(np.arange(height), np.arange(height)[::-1])[:, None]
    xs = np.minimum(np.arange(width), np.arange(width)[::-1])[None, :]
    ramp = np.clip(np.minimum(ys, xs) / float(FEATHER), 0.0, 1.0)
    data[..., 3] = (alpha * ramp).astype(np.uint8)

    out = Image.fromarray(data, "RGBA")
    bounds = out.getbbox()
    return out.crop(bounds) if bounds else None


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
    data[..., 3] = np.where(background, 0, 255)
    out = Image.fromarray(data, "RGBA")
    bounds = out.getbbox()
    return out.crop(bounds) if bounds else None


def carve(sheet: Image.Image, box: tuple, may_fill: bool = False) -> Image.Image | None:
    """Découpe une boîte et n'en garde que la forme principale.

    `may_fill` pour les MONUMENTS : un temple occupe légitimement toute sa
    boîte, alors qu'un petit prop laisse forcément du vide autour de lui. Sans
    cette distinction, la règle anti-fond rejetait la ziggourat du stage 8 et
    ne gardait qu'un éclat de trois pixels."""
    crop = sheet.crop(box).convert("RGBA")
    if may_fill:
        return keyed(crop)
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
    if not may_fill:
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
                for rank, box in enumerate(roles.get(role, [])):
                    if path.suffix == ".jpeg":
                        cut = carve_damier(sheet, box)
                    else:
                        cut = carve(sheet, box, may_fill=(role == "maison"))
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
