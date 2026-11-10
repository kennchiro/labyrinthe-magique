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
from scipy import ndimage
from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from build_characters import (MAGES_ANIMES, SOURCE, OUT, OUT_ENEMIES, SHEETS, detect_grid, cell_box,
                              ALPHA_THRESHOLD, POSES, DIRECTIONS, keyed_on_flat)

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


## Part minimale de la case qu'une pose doit occuper.
##
## ⚠️ Ce n'est PAS la promesse des prompts (80 % de la case de la PLANCHE) : la
## case du jeu est commune aux mages ET aux créatures, et c'est le Démon de
## Cristal qui la fixe. Les mages y tiennent 59 à 65 %, ce qui est sain. Ce
## seuil-ci ne cherche donc pas la belle taille : il attrape une pose CASSÉE —
## un lanceur rendu à la case voisine ne laissant que sa boule de feu, mesuré à
## 22 % sur les Ténèbres avant le recalage de la gouttière.
MIN_FILL = 0.45
## Écart maximal ENTRE MAGES. C'est la promesse de la refonte, et la seule
## mesure qui la vérifie : ils allaient de 60 % à 93 % de leur case, sans qu'
## aucune règle du jeu ne le justifie.
MAX_BETWEEN = 1.20
## Écart maximal toléré entre la plus grande et la plus petite pose d'une
## planche. Au-delà, le personnage enfle et rétrécit en marchant.
MAX_SPREAD = 1.35


## Distance maximale, en largeurs de case, entre le personnage et une forme
## détachée. Au-delà, ce n'est plus son bâton ni son orbe : c'est un morceau de
## la pose voisine.
##
## ⚠️ CE CONTRÔLE MANQUAIT, et c'est ce qui l'a rendu nécessaire : la bande de
## face du Mage de l'Air a été livrée avec une écharpe volée à la pose suivante
## et un lanceur amputé, pendant que le contrôleur annonçait huit planches
## irréprochables. Il ne mesurait que des hauteurs — un mage tronqué de son
## écharpe garde la sienne.
MAX_STRAY = 0.20


def _stray_shape(cell: np.ndarray, cell_w: int) -> float:
    """Écart entre le personnage et la forme détachée la plus lointaine."""
    labels, count = ndimage.label(cell)
    if count < 2:
        return 0.0
    areas = ndimage.sum(np.ones_like(labels), labels, range(1, count + 1))
    main = int(np.argmax(areas)) + 1
    body = np.nonzero((labels == main).any(axis=0))[0]
    worst = 0.0
    for index in range(1, count + 1):
        # Une poussière de quelques pixels ne se voit pas ; ce qu'on cherche est
        # un MORCEAU — une manche, une écharpe, un éclat de sort.
        if index == main or areas[index - 1] < 30:
            continue
        here = np.nonzero((labels == index).any(axis=0))[0]
        gap = max(here[0] - body[-1], body[0] - here[-1], 0) / float(cell_w)
        worst = max(worst, gap)
    return worst


def _spread_between_mages() -> tuple:
    """Écart de remplissage entre le plus petit et le plus grand des mages."""
    mesures = {}
    for config in SHEETS.values():
        if "grid" not in config:
            continue
        folder = OUT / config["id"]
        meta = folder / "frames.json"
        if not meta.exists():
            continue
        descriptor = json.loads(meta.read_text(encoding="utf-8"))
        # Un mage animé porte la hauteur de son corps : le jeu en déduit sa taille à
        # l'écran. Son remplissage de case ne dit donc plus rien de cette taille.
        if "body_height" in descriptor:
            continue
        cell_w, cell_h = descriptor["cell"]
        band = np.array(Image.open(folder / "down.png"))[..., 3] > ALPHA_THRESHOLD
        hauteurs = []
        for index in range(band.shape[1] // cell_w):
            cell = band[:, index * cell_w:(index + 1) * cell_w]
            rows_here = np.nonzero(cell.any(axis=1))[0]
            if rows_here.size:
                hauteurs.append(rows_here[-1] - rows_here[0])
        if hauteurs:
            mesures[config["id"]] = float(np.median(hauteurs)) / cell_h
    if len(mesures) < 2:
        return ()
    petit = min(mesures, key=mesures.get)
    grand = max(mesures, key=mesures.get)
    return (mesures[grand] / mesures[petit],
            f"{petit} {mesures[petit] * 100:.0f} %",
            f"{grand} {mesures[grand] * 100:.0f} %")


def check_imposed(name: str, config: dict) -> tuple:
    """Contrôle d'une planche à grille IMPOSÉE — les huit mages de la refonte.

    La grille n'étant plus détectée, il n'y a plus rien à comparer entre une
    détection et la réalité. Le contrôle porte sur les trois défauts que les
    prompts cherchent à éviter, et il les cherche AU BON ENDROIT :

    - sur la PLANCHE, la seule chose qu'elle seule sache dire : une case vide,
      signe que la grille imposée est décalée d'un cran ;
    - sur la BANDE DÉCOUPÉE, tout le reste. Mesurer le remplissage sur la
      planche revient à mesurer le débordement que le découpage RETIRE : la
      pose de profil du Feu y pèse 89 % de sa case à cause de la fumée de la
      rangée du dessus, et 58 % une fois rendue à sa voisine. Le contrôle
      accusait donc huit planches saines.

    ⚠️ Ces planches arrivent SANS canal alpha, sur un fond uni. Les lire telles
    quelles rend une image opaque de bord en bord, et tous les contrôles passent
    avec brio sur vingt-quatre carrés gris — c'est arrivé.
    """
    problems, warnings = [], []
    image = Image.open(SOURCE / name)
    image = keyed_on_flat(image) if image.mode != "RGBA" else image.convert("RGBA")
    alpha = np.array(image)[..., 3] > ALPHA_THRESHOLD
    dx, dy, ox, oy = config["grid"]
    height, width = alpha.shape

    for row in range(4):
        for col in range(6):
            x0, y0 = ox + col * dx, oy + row * dy
            if x0 + dx > width or y0 + dy > height:
                problems.append(f"case ({row + 1}, {col + 1}) : hors de l'image")
                continue
            if not alpha[y0:y0 + dy, x0:x0 + dx].any():
                problems.append(f"case ({row + 1}, {col + 1}) : VIDE — la grille "
                                "imposée est probablement décalée")

    folder = OUT / config["id"]
    meta = folder / "frames.json"
    if not meta.exists():
        problems.append("aucune bande découpée : relancer build_characters.py")
        return problems, warnings
    cell_w, cell_h = json.loads(meta.read_text(encoding="utf-8"))["cell"]
    fills, walking = [], []
    for direction in DIRECTIONS:
        strip = folder / f"{direction}.png"
        if not strip.exists():
            continue
        band = np.array(Image.open(strip))[..., 3] > ALPHA_THRESHOLD
        count = band.shape[1] // cell_w
        for index in range(count):
            cell = band[:, index * cell_w:(index + 1) * cell_w]
            rows_here = np.nonzero(cell.any(axis=1))[0]
            if not rows_here.size:
                problems.append(f"{direction}, pose {index + 1} : VIDE")
                continue
            part = (rows_here[-1] - rows_here[0]) / float(cell_h)
            fills.append(part)
            stray = _stray_shape(cell, cell_w)
            if stray > MAX_STRAY:
                problems.append(f"{direction}, pose {index + 1} : un morceau "
                                f"traîne à {stray:.2f} case du personnage — il "
                                "appartient à la pose voisine")
            # La pose d'ATTAQUE porte le sort en plus du mage : elle est
            # légitimement plus grande et n'entre pas dans l'écart de marche.
            if index < count - 1:
                walking.append(part)

    if fills:
        if min(fills) < MIN_FILL:
            problems.append(f"une pose n'occupe que {min(fills) * 100:.0f} % de sa "
                            f"case (minimum {MIN_FILL * 100:.0f} %) — elle est "
                            "probablement coupée")
        if walking:
            spread = max(walking) / max(min(walking), 1e-6)
            if spread > MAX_SPREAD:
                problems.append(f"la taille varie de x{spread:.2f} d'une pose de "
                                "marche à l'autre : le mage enfle en marchant")
        warnings.append(f"remplissage {min(fills) * 100:.0f} a {max(fills) * 100:.0f} %")
    return problems, warnings


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


## L'Invocateur fait monter son cercle sous ses pieds : son sort n'a pas de sens.
## La Terre frappe le sol juste devant elle : son manteau déborde derrière autant que
## son geste devant, et la mesure ne les sépare pas. Vérifiée à l'œil sur ses planches.
## L'Ange de la Mort arme sa faux en grand DERRIÈRE lui, puis frappe bien devant : vu à l'œil.
## L'Archange d'Acier frappe devant lui, mais ses ailes débordent déjà derrière au repos : vu à l'œil.
## Le Chérubin arme son épée par-dessus l'épaule et ses quatre ailes débordent derrière (26 px au
## repos) ; il frappe bien devant à l'image 4 (+30 px). Mesuré le 2026-11-03, vu à l'œil.
## `earth_eveil` : le bâton levé à la 3e image déborde de 42 px derrière lui, autant que les éclats de
## l'impact devant lui à la 4e (mesuré le 2026-11-07).
## `shadow_eveil` : les mains griffues de ses vrilles débordent de 38 px derrière lui à l'image du coup,
## l'éclipse de 36 px devant ; il frappe bien devant (mesuré et vu le 2026-11-07).
## `peste_eveil` : il arme son encensoir comme une fronde, loin derrière lui aux images 2 et 3, puis le balance
## devant à l'image 4, où l'éclaboussure sort bien devant lui (vu sur la planche le 2026-11-08).
## `supreme_eveil` : il pousse ses deux paumes devant lui, mais son manteau évasé et son auréole débordent
## derrière autant que ses mains devant (vu sur la bande agrandie le 2026-11-08).
ATTACK_SIDE_EXEMPT = {"invocateur", "earth", "mort", "acier", "cherubin", "earth_eveil", "shadow_eveil",
	"peste_eveil", "supreme_eveil"}


## Écarts tolérés sur un mage animé, entre la marche et la dernière image d'attaque.
ANIMATED_MAX_SCALE_GAP = 0.10
ANIMATED_MAX_FEET_GAP = 3


def check_animated(mage: str) -> list:
    """Le corps garde-t-il sa taille et ses pieds, de la marche à l'attaque ?"""
    folder = OUT / mage
    meta = json.loads((folder / "frames.json").read_text(encoding="utf-8"))
    cell_w, _ = meta["cell"]
    walks = [i for i, pose in enumerate(meta["poses"]) if pose.startswith("walk")]
    attacks = [i for i, pose in enumerate(meta["poses"]) if pose.startswith("attack")]
    problems = []
    if len(walks) != 8 or len(attacks) != 8 or "body_height" not in meta:
        return [f"{len(walks)} pas et {len(attacks)} attaques : le format animé en attend 8 et 8"]
    for direction in meta["directions"]:
        with Image.open(folder / f"{direction}.png") as image:
            alpha = np.asarray(image.convert("RGBA"))[..., 3] > ALPHA_THRESHOLD

        def rows_of(index: int) -> tuple:
            rows = np.nonzero(alpha[:, index * cell_w:(index + 1) * cell_w].any(axis=1))[0]
            return (int(rows[0]), int(rows[-1])) if rows.size else (0, 0)

        if any(rows_of(i) == (0, 0) for i in walks + attacks):
            problems.append(f"{direction} : une case est vide")
            continue
        height = float(np.median([rows_of(i)[1] - rows_of(i)[0] for i in walks]))
        feet = float(np.median([rows_of(i)[1] for i in walks]))
        top, bottom = rows_of(attacks[-1])
        if abs((bottom - top) / height - 1.0) > ANIMATED_MAX_SCALE_GAP:
            problems.append(f"{direction} : attaque x{(bottom - top) / height:.2f} par rapport à la marche")
        if abs(bottom - feet) > ANIMATED_MAX_FEET_GAP:
            problems.append(f"{direction} : pieds à {bottom} en attaque, {feet:.0f} en marche")
    return problems


def check_attack_sides() -> list:
    """Sur un profil, le sort part-il du côté que le mage regarde ?

    Chaque fichier existe et a la bonne taille quand il tire dans le dos, comme
    six mages sur huit l'ont fait : seul le côté où déborde la pose le montre.
    """
    troubles = []
    for folder in sorted(OUT.glob("*/")):
        descriptor = folder / "frames.json"
        if not descriptor.exists() or folder.name in ATTACK_SIDE_EXEMPT:
            continue
        meta = json.loads(descriptor.read_text())
        cell_w, _ = meta["cell"]
        attacks = [i for i, pose in enumerate(meta["poses"]) if pose.startswith("attack")]
        for direction, sign in (("left", -1), ("right", 1)):
            with Image.open(folder / f"{direction}.png") as image:
                alpha = np.asarray(image.convert("RGBA"))[..., 3] > 40
            cells = [alpha[:, i * cell_w:(i + 1) * cell_w] for i in attacks]
            columns = np.where(np.any(cells, axis=0).any(0))[0]
            before = cell_w / 2 - columns[0]
            after = columns[-1] - cell_w / 2
            if (after - before) * sign <= 0:
                troubles.append(f"{folder.name}/{direction}.png : le sort part dans le dos")
    return troubles


def main() -> None:
    failures = 0
    checked = 0

    troubles = check_written_strips()
    backwards = check_attack_sides()
    for trouble in backwards:
        print(f"❌  {trouble} -> `attack_mirror` dans build_characters.py")
    if backwards:
        print("")
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
        if "mode" in config:
            continue
        if config["id"] in MAGES_ANIMES:
            checked += 1
            problems = check_animated(config["id"])
            if problems:
                failures += 1
                print(f"❌  {config['id']} (planches animées)")
                for trouble in problems:
                    print(f"      {trouble}")
            else:
                print(f"✅  {config['id']:11s} 8 pas, 8 attaques, corps et pieds constants")
            continue
        if "grid" in config and "row0" not in config:
            path = SOURCE / name
            if not path.exists():
                print(f"  ! {name} introuvable")
                continue
            checked += 1
            problems, warnings = check_imposed(name, config)
            if problems:
                failures += 1
                print(f"❌  {config['id']} ({name})")
                for trouble in problems:
                    print(f"      {trouble}")
            else:
                print(f"✅  {config['id']:11s} {' · '.join(warnings)}")
            continue
        if "row0" not in config:
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
    # Ces mages sont nés animés : ils n'ont jamais eu de planche dans `SHEETS`.
    for mage in ("chrono", "peste", "lumiere", "mort", "etoiles", "acier", "demon", "discorde", "braise", "ecarlate", "geolier", "ciel", "cherubin", "dragon", "croupier", "avide"):
        checked += 1
        problems = check_animated(mage)
        if problems:
            failures += 1
            print(f"❌  {mage} (planches animées)")
            for problem in problems:
                print(f"      {problem}")
        else:
            print(f"✅  {mage} : marche et attaque calées")
    # LE CONTRÔLE QUI PORTE TOUTE LA REFONTE : les huit mages doivent occuper
    # leur case de la même façon. Chacun peut être irréprochable pris à part et
    # l'ensemble rester bancal — c'était exactement l'état d'avant.
    print("")
    entre = _spread_between_mages()
    if entre:
        ecart, plus_petit, plus_grand = entre
        verdict = "✅" if ecart <= MAX_BETWEEN else "❌"
        print(f"{verdict}  écart entre mages x{ecart:.2f} "
              f"(du {plus_petit} au {plus_grand}, maximum toléré x{MAX_BETWEEN:.2f})")
        if ecart > MAX_BETWEEN:
            failures += 1
    print("")
    if failures:
        print(f"❌  {failures} planche(s) sur {checked} mal découpée(s)")
        sys.exit(1)
    if troubles or backwards:
        sys.exit(1)
    print(f"✅  LES {checked} PLANCHES DE MAGES SONT BIEN DÉCOUPÉES")


if __name__ == "__main__":
    main()
