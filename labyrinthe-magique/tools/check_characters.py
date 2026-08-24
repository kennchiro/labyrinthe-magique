"""Vérifie que le découpage des planches de mages tombe sur les bonnes cases.

    tools/.venv/bin/python tools/check_characters.py

POURQUOI CE SCRIPT EXISTE
Le découpage repose sur une grille détectée automatiquement (pas + phase) et sur
un ancrage déclaré à la main (`col0`, `row0`). Une erreur d'ancrage ne casse RIEN
de visible côté outil : les bandes se génèrent, les fichiers existent, les tests
du jeu passent. Le défaut n'apparaît qu'en jeu, et seulement si on regarde le bon
personnage marcher dans la bonne direction.

C'est exactement ce qui est arrivé : `col0 = 1, row0 = 1` sur l'Eau et les
Ténèbres sautait la pose IDLE **et** la direction DOWN, et la quatrième direction
tombait dans le portrait du bas de la planche. Le défaut a vécu des heures.

CE QUE LE SCRIPT MESURE

Le contrôle qui compte : **comparer la grille calculée aux rangées de
personnages réellement mesurées sur l'image**. C'est le seul qui attrape une
erreur d'ancrage, et il est vérifié par l'épreuve du feu — on remet le mauvais
`row0` et le script doit crier.

Une première version se contentait de regarder le CONTENU des cases (vides ?
hauteurs cohérentes ?). Elle ne servait à rien : avec l'ancrage fautif, la
quatrième rangée tombait sur le portrait du bas de planche, dont le dessin fait
la même hauteur qu'un personnage. Le script disait « tout va bien ». Un garde-fou
qui ne se déclenche pas sur le bug qu'il est censé attraper est pire que rien —
il rassure à tort.

Reste que sur trois planches (Terre, Suprême, Foudre) les lueurs se touchent et
il n'y a plus de gouttière à mesurer. Le script le DIT au lieu de faire semblant
de les avoir vérifiées.

Les contrôles de contenu sont conservés en second rideau : case vide, hauteur
aberrante, dessin au contact du bord (celui-là en simple avertissement — sur les
poses d'attaque, l'orbe déborde légitimement).
"""

from pathlib import Path
import json
import sys
import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from build_characters import SOURCE, OUT, OUT_ENEMIES, SHEETS, detect_grid, cell_box, ALPHA_THRESHOLD, POSES, DIRECTIONS

## Écart admis entre une case calculée et la rangée réellement mesurée. Au-delà,
## la case mord sur sa voisine. 26 px pour un pas d'environ 150 : un sixième de case.
ROW_TOLERANCE = 26
## Une case dont la hauteur de contenu s'écarte de plus de 45 % de la médiane
## est presque sûrement hors grille.
HEIGHT_TOLERANCE = 0.45
## Contenu minimal d'une case, en fraction de sa surface.
MIN_FILL = 0.012
## Un sprite est « coupé » si le bord de la case porte plus que cette fraction
## de la hauteur du contenu. En dessous, c'est une lueur qui déborde — normal.
EDGE_TOLERANCE = 0.34


def cell_report(mask: np.ndarray) -> dict:
    rows = np.nonzero(mask.any(axis=1))[0]
    columns = np.nonzero(mask.any(axis=0))[0]
    if rows.size == 0 or columns.size == 0:
        return {"empty": True}
    height = int(rows[-1] - rows[0] + 1)
    left = int(mask[:, :2].sum())
    right = int(mask[:, -2:].sum())
    return {
        "empty": False,
        "fill": float(mask.mean()),
        "height": height,
        "cut_left": left > height * EDGE_TOLERANCE,
        "cut_right": right > height * EDGE_TOLERANCE,
    }


def bands(profile: np.ndarray, gap: int, minimum: int) -> list:
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


def check(name: str, config: dict) -> tuple:
    problems, warnings = [], []
    alpha = np.array(Image.open(SOURCE / name).convert("RGBA"))[..., 3] > ALPHA_THRESHOLD
    height, width = alpha.shape
    dx, dy, ox, oy = detect_grid(alpha)

    # --- Contrôle principal : la grille tombe-t-elle sur les vraies rangées ? ---
    rows = [r for r in bands(alpha[:, :int(width * 0.62)].sum(axis=1), 8, 40)
            if r[0] < height * 0.74 and r[1] - r[0] > 60]
    verified = len(rows) >= len(DIRECTIONS)
    if verified:
        for index, direction in enumerate(DIRECTIONS):
            expected = oy + (config["row0"] + index) * dy
            gap = abs(expected - rows[index][0])
            if gap > ROW_TOLERANCE:
                problems.append(f"rangée {direction} : case calculée en y={expected}, "
                                f"rangée réelle en y={rows[index][0]} (écart {gap} px)")
        top = rows[0][0]
        columns = [c[0] for c in bands(alpha[top:top + dy, :int(width * 0.72)].sum(axis=0), 7, 20)]
        if columns:
            expected = ox + config["col0"] * dx
            nearest = min(columns, key=lambda c: abs(c - expected))
            if abs(nearest - expected) > ROW_TOLERANCE:
                problems.append(f"colonne IDLE : case calculée en x={expected}, "
                                f"colonne réelle la plus proche en x={nearest}")
    else:
        warnings.append(f"rangées non mesurables ({len(rows)} détectée(s) sur "
                        f"{len(DIRECTIONS)}) — les lueurs se touchent, "
                        f"l'alignement n'a PAS pu être vérifié")

    # --- Second rideau : le contenu de chacune des 24 cases -------------------
    reports = {}
    for row_index, direction in enumerate(DIRECTIONS):
        for pose_index, pose in enumerate(POSES):
            x0, y0, x1, y1 = cell_box(dx, dy, ox, oy,
                config["col0"] + pose_index, config["row0"] + row_index)
            if y1 > height or x1 > width:
                problems.append(f"{direction}/{pose} : la case sort de l'image")
                continue
            reports[(direction, pose)] = cell_report(alpha[y0:y1, x0:x1])

    sizes = [r["height"] for r in reports.values() if not r["empty"]]
    if not sizes:
        return problems + ["aucune case ne contient quoi que ce soit"], warnings
    median = float(np.median(sizes))
    for (direction, pose), report in reports.items():
        if report["empty"]:
            problems.append(f"{direction}/{pose} : case VIDE")
            continue
        if report["fill"] < MIN_FILL:
            problems.append(f"{direction}/{pose} : case quasi vide ({report['fill']*100:.1f} %)")
        if abs(report["height"] - median) / median > HEIGHT_TOLERANCE:
            problems.append(f"{direction}/{pose} : contenu de {report['height']} px de haut "
                            f"contre {median:.0f} attendus")
        if report["cut_left"] or report["cut_right"]:
            side = "gauche" if report["cut_left"] else "droite"
            warnings.append(f"{direction}/{pose} : dessin au contact du bord {side}")
    return problems, warnings


def check_written_strips() -> list:
    """Les bandes ÉCRITES sur le disque correspondent-elles à leur descripteur ?

    C'est la vérification la plus bête du fichier, et c'est celle qui a manqué :
    quand une planche BRUTE (2172x724) atterrit à la place d'une bande découpée
    (918x112), rien ne plante. `hframes` taille la source en six morceaux et le
    personnage s'affiche quatre fois trop grand en jeu — un défaut qu'on ne
    trouve qu'à l'œil, sur une capture, si on pense à regarder.

    Elle porte sur `assets/`, pas sur les sources : elle attrape donc aussi bien
    un bug du découpeur qu'un fichier écrasé par ailleurs.
    """
    troubles = []
    for folder in sorted(list(OUT.glob("*/")) + list(OUT_ENEMIES.glob("*/"))):
        descriptor = folder / "frames.json"
        if not descriptor.exists():
            continue
        meta = json.loads(descriptor.read_text())
        cell_w, cell_h = meta["cell"]
        expected = (cell_w * len(meta["poses"]), cell_h)
        for direction in meta["directions"]:
            strip = folder / f"{direction}.png"
            if not strip.exists():
                troubles.append(f"{folder.name}/{direction}.png manquante")
                continue
            with Image.open(strip) as image:
                if image.size != expected:
                    troubles.append(
                        f"{folder.name}/{direction}.png fait {image.size},"
                        f" attendu {expected} — planche brute à la place de la bande ?")
    return troubles


def main() -> None:
    failures = 0
    checked = 0

    troubles = check_written_strips()
    if troubles:
        print("❌  BANDES ÉCRITES INCOHÉRENTES AVEC LEUR DESCRIPTEUR :")
        for trouble in troubles:
            print(f"      {trouble}")
        print("      -> relancer tools/build_characters.py DEPUIS LA RACINE du projet")
        print("")
    for name, config in SHEETS.items():
        # Les entrées d'ENNEMIS ajoutées par le pipeline voisin ont une autre
        # géométrie (clé « mode ») : elles ne se vérifient pas comme une grille
        # de mage.
        if "mode" in config or "row0" not in config:
            continue
        path = SOURCE / name
        if not path.exists():
            print(f"  ! {name} introuvable")
            continue
        checked += 1
        problems, warnings = check(name, config)
        if problems:
            failures += 1
            print(f"❌  {config['id']} ({name})")
            for problem in problems[:6]:
                print(f"      {problem}")
            if len(problems) > 6:
                print(f"      … et {len(problems) - 6} autre(s)")
        else:
            note = ""
            if any("non mesurables" in w for w in warnings):
                note = "  ⚠️ alignement NON vérifié (lueurs jointives)"
            elif warnings:
                note = f"  ({len(warnings)} débordement(s) de lueur)"
            print(f"✅  {config['id']:8s} {len(DIRECTIONS)} directions x {len(POSES)} poses,"
                  f" toutes cadrées{note}")
    print("")
    if failures:
        print(f"❌  {failures} planche(s) sur {checked} mal découpée(s)")
        sys.exit(1)
    if troubles:
        sys.exit(1)
    print(f"✅  LES {checked} PLANCHES DE MAGES SONT BIEN DÉCOUPÉES")


if __name__ == "__main__":
    main()
