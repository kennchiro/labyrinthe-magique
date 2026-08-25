#!/usr/bin/env python3
"""Les prompts de terrain des dix stages, et leurs images de référence.

    tools/.venv/bin/python tools/build_prompts.py     # DEPUIS LA RACINE

Produit, pour chaque stage :
    docs/prompts/terrain_<N>_sol.md      la matière du sol
    docs/prompts/terrain_<N>_mur.md      le jeu de 16 pièces du mur
    docs/prompts/terrain_<N>_decor.md    les 12 props des couloirs
    docs/prompts/ref/ref_<N>_{sol,mur,decor}.png   les découpes à joindre

POURQUOI UN GÉNÉRATEUR, ET PAS TRENTE FICHIERS ÉCRITS À LA MAIN

Parce que 90 % de chaque prompt est IDENTIQUE d'un stage à l'autre : le format
de la planche, la convention du fond magenta, la liste des 16 cases (c'est de la
géométrie, pas du décor), les règles d'échelle et d'éclairage. Seuls changent le
SUJET, les COULEURS et la liste des props. Écrire trente fichiers, c'est trente
occasions de laisser passer une consigne dans un seul d'entre eux — et c'est
exactement le genre de divergence silencieuse qui a déjà coûté cher ici.

⚠️ Les fichiers produits sont GÉNÉRÉS. Ne pas les éditer à la main : corriger
une consigne se fait ici, puis on relance.

Les dix planches d'`assets/stages/` partagent la même mise en page — panneau
d'autotile en haut à gauche, panneaux de sol étiquetés en bas à gauche, props à
droite — mais PAS aux mêmes coordonnées. Les boîtes sont donc relevées à la main
stage par stage, comme partout ailleurs dans ce projet.

Une seule version, en FRANÇAIS. Maintenir trente prompts en deux langues, c'est
soixante blocs à garder synchronisés pour un gain non démontré ; si un modèle
rend mieux en anglais, lui demander de traduire le prompt avant de générer coûte
une ligne et ne peut pas diverger.
"""

from pathlib import Path
import numpy as np
from PIL import Image

SHEETS = Path("assets/stages")
OUT = Path("docs/prompts")
REF = OUT / "ref"

## Nom officiel du stage — le même que `LevelConfig.STAGE_NAMES`.
NAMES = [
    "La Forêt", "Le Canyon de la Foudre", "Les Dunes de Feu",
    "Les Rivages Océaniques", "Les Cavernes de Cristal",
    "Les Montagnes Glacées", "Le Bois d'Épine", "Les Ruines Anciennes",
    "Le Sanctuaire Déchu", "Le Château du Ciel",
]

# --- Boîtes relevées à la main sur chaque planche (pixels source, 1536 x 1024) ---
#
# `mur`   le panneau d'autotile, en haut à gauche
# `sol`   les panneaux de sol étiquetés, en bas à gauche
# `decor` le semis de props, à droite
#
# ⚠️ Il n'y a PAS de mesure du contraste ici, et c'est un choix. Deux estimateurs
# ont été essayés sur ces planches : deux groupes de couleurs (k-moyennes) suit
# les REFLETS — les veines d'éclair du Canyon, les fleurs des haies — et rend le
# mur systématiquement plus clair ; « le plus loin de la couleur du sol » suit
# les CONTOURS NOIRS et rend le mur systématiquement plus sombre. Les deux se
# contredisent sur les dix planches. Écrire dans vingt fichiers une direction
# qu'on ne sait pas mesurer serait pire que de ne rien écrire : les prompts
# demandent donc un ÉCART franc sans en imposer le sens, l'image de référence
# jointe portant déjà le rapport réel bien mieux qu'une phrase. Le sens est
# ensuite mesuré sur la planche LIVRÉE, et `MIN_CONTRAST` écarte les deux
# valeurs dans le sens que le dessin a choisi.
BOXES = {
    1:  {"mur": (9, 143, 702, 636),   "sol": (9, 658, 592, 976),
         "decor": (680, 22, 1525, 636)},
    2:  {"mur": (11, 104, 855, 668),  "sol": (11, 674, 855, 962),
         "decor": (868, 27, 1529, 695)},
    3:  {"mur": (11, 118, 761, 628),  "sol": (11, 641, 761, 982),
         "decor": (775, 27, 1529, 628)},
    4:  {"mur": (11, 107, 721, 654),  "sol": (11, 668, 721, 995),
         "decor": (734, 27, 1529, 654)},
    5:  {"mur": (11, 107, 721, 641),  "sol": (11, 681, 721, 1015),
         "decor": (734, 27, 1529, 641)},
    6:  {"mur": (11, 120, 721, 641),  "sol": (11, 681, 721, 1014),
         "decor": (734, 27, 1529, 668)},
    7:  {"mur": (11, 127, 721, 641),  "sol": (11, 654, 721, 988),
         "decor": (728, 27, 1529, 628)},
    8:  {"mur": (11, 134, 721, 641),  "sol": (11, 661, 721, 988),
         "decor": (734, 27, 1529, 628)},
    9:  {"mur": (11, 93, 801, 614),   "sol": (11, 614, 908, 855),
         "decor": (828, 27, 1529, 641)},
    10: {"mur": (11, 127, 721, 641),  "sol": (11, 668, 721, 988),
         "decor": (734, 27, 1529, 641)},
}

# --- Ce qui change vraiment d'un stage à l'autre ---------------------------------
#
# `mur`    ce qu'est le mur du labyrinthe. Ce n'est une haie qu'au stage 1.
# `sol`    ce qu'est le sol des couloirs.
# `teinte_mur` / `teinte_sol` : la consigne de couleur, en clair.
# `props`  les douze objets du semis, dans l'ordre où ils seront dessinés.
#          Les DEUX DERNIERS sont toujours LUMINEUX : ils partent dans la liste
#          `GLOWING` de DecorLayer, qui leur accroche une lumière en jeu.
STAGES = {
    1: {
        "mur": "une haie de buis taillée, feuillage vert vif et lumineux, semée "
               "de petites fleurs blanches, jaunes et rouges",
        "sol": "de l'herbe rase vert moyen, traversée de plaques de TERRE "
               "SABLEUSE claire aux bords irréguliers, quelques petits cailloux "
               "gris arrondis, de rares petites fleurs blanches et bleues",
        "teinte_mur": "vert vif lumineux, presque jaune-vert au soleil, avec des "
                      "creux d'ombre bleutés entre les feuilles",
        "teinte_sol": "vert herbe MOYEN à légèrement SOURD, et beige sable chaud "
                      "pour les plaques de terre",
        "props": [
            "un bouquet de trois champignons à chapeau rouge à pois blancs",
            "une touffe de petites fleurs bleues",
            "une touffe de petites fleurs blanches et jaunes",
            "une souche d'arbre coupée, anneaux visibles sur le dessus, mousse au pied",
            "un rocher gris arrondi, mousse sur le dessus",
            "un groupe de trois cailloux gris de tailles différentes",
            "un tronc couché, écorce brune, mousse et champignons dessus",
            "une fougère verte en éventail",
            "un buisson rond vert foncé à petites baies rouges",
            "deux planches de bois clouées posées au sol",
            "une pierre runique dressée, gravure verte LUMINEUSE",
            "une lanterne de fer posée au sol, verre ambré ALLUMÉ",
        ],
    },
    2: {
        "mur": "un muret de roche violette empilée, parcouru de VEINES D'ÉCLAIR "
               "bleu électrique lumineuses qui courent sur son dessus",
        "sol": "de la terre sableuse ocre CRAQUELÉE, semée de petits cailloux "
               "violets et de fines fissures sombres",
        "teinte_mur": "violet sombre pour la pierre, bleu électrique très "
                      "LUMINEUX pour les veines — le mur est la source de lumière "
                      "de ce biome",
        "teinte_sol": "ocre sable chaud, calme, sans aucune lueur : c'est le fond "
                      "sur lequel les éclairs du mur doivent ressortir",
        "props": [
            "un amas de cristaux bleus dressés",
            "un amas de cristaux violets dressés",
            "un arbre mort foudroyé, branches nues et tordues",
            "un rocher violet arrondi",
            "un groupe de trois cailloux violets de tailles différentes",
            "une souche de roche fendue",
            "un crâne blanchi posé au sol",
            "un tonneau de bois cerclé de fer",
            "un chariot de mine en bois, roues de fer",
            "une portion de clôture de bois brisée",
            "une borne runique bleue à gravure LUMINEUSE",
            "une torche sur pied à flamme bleue ALLUMÉE",
        ],
    },
    3: {
        "mur": "un muret de BLOCS DE GRÈS taillés et empilés, joints sombres "
               "marqués, arêtes usées par le sable",
        "sol": "du sable clair ondulé par le vent, quelques petits cailloux, de "
               "rares os blanchis à moitié enfouis",
        "teinte_mur": "grès blond CLAIR, presque crème au soleil, avec des joints "
                      "brun sombre bien lisibles",
        "teinte_sol": "sable doré chaud, plus SOMBRE et plus orangé que la pierre "
                      "des murs",
        "props": [
            "un palmier court à quelques palmes",
            "un cactus vert à fleurs roses",
            "un crâne d'animal à cornes posé au sol",
            "un tas d'os blanchis",
            "un rocher de grès arrondi",
            "un groupe de trois cailloux ocre",
            "un arbre mort desséché, branches nues",
            "un tonneau de bois cerclé de fer",
            "un chariot de bois à deux roues",
            "une jarre de terre cuite couchée",
            "un obélisque de grès à gravure dorée LUMINEUSE",
            "un brasero sur pied à flamme orange ALLUMÉE",
        ],
    },
    4: {
        "mur": "un muret de GALETS RONDS beiges et roses assemblés, sur lequel "
               "poussent des coraux rouges et blancs",
        "sol": "du sable clair humide, semé de coquillages, de petites étoiles de "
               "mer et de galets lisses",
        "teinte_mur": "beige rosé pour les galets, ROUGE CORAIL vif et blanc pour "
                      "les coraux — le mur est la note colorée du biome",
        "teinte_sol": "sable clair chaud, très lumineux, plus PÂLE que le mur",
        "props": [
            "un bouquet de corail rouge",
            "un bouquet de corail bleu",
            "une étoile de mer orange et deux coquillages",
            "un palmier court penché",
            "un rocher couvert d'algues vertes",
            "un groupe de trois galets gris lisses",
            "une ancre de fer posée au sol",
            "un vieux canon de bois échoué",
            "un tonneau de bois cerclé de fer",
            "un filet de pêche et deux planches",
            "une borne de corail bleu LUMINEUSE",
            "une lanterne de port en fer, verre ambré ALLUMÉ",
        ],
    },
    5: {
        "mur": "un muret de roche violette sur lequel sont plantés de GROS "
               "CRISTAUX bleus et roses lumineux",
        "sol": "de la roche violette sombre, semée d'éclats de cristal bleus "
               "minuscules et de fines craquelures",
        "teinte_mur": "roche violette moyenne, et cristaux bleus et roses TRÈS "
                      "LUMINEUX — le mur éclaire la caverne",
        "teinte_sol": "violet SOMBRE et calme, presque noir dans les creux : c'est "
                      "le fond sur lequel les cristaux doivent briller",
        "props": [
            "un amas de cristaux roses dressés",
            "un amas de cristaux bleus dressés",
            "un arbre pétrifié violet, branches nues",
            "un rocher violet arrondi",
            "un groupe de trois cailloux violets",
            "un crâne posé au sol",
            "une caisse de bois cloutée",
            "un chariot de mine en bois, roues de fer",
            "deux poutres de bois croisées",
            "un gros champignon bleu LUMINEUX",
            "une borne runique violette à gravure LUMINEUSE",
            "une lanterne de mineur, verre bleu ALLUMÉ",
        ],
    },
    6: {
        "mur": "un muret de BLOCS DE GLACE et de neige tassée, avec de courtes "
               "stalactites bleues sous son bord",
        "sol": "de la neige tassée, quelques petits cailloux gris qui affleurent, "
               "de rares éclats de glace",
        "teinte_mur": "glace BLEUE translucide et neige blanche — le mur est le "
                      "plus clair et le plus froid du biome",
        "teinte_sol": "blanc légèrement bleuté, mais plus GRIS et plus SOURD que "
                      "la glace des murs, sinon le labyrinthe devient illisible",
        "props": [
            "un petit sapin enneigé",
            "un arbre mort givré, branches nues et blanches",
            "un amas de glaçons bleus dressés",
            "un rocher gris coiffé de neige",
            "un groupe de trois cailloux gris",
            "une congère arrondie",
            "un crâne pris dans la glace",
            "une caisse de bois givrée",
            "un chariot de bois à roues de fer",
            "deux planches de bois gelées",
            "une borne de glace bleue LUMINEUSE",
            "une lanterne de fer à flamme bleue ALLUMÉE",
        ],
    },
    7: {
        "mur": "un muret de pierre entièrement mangé par un LIERRE ÉPINEUX vert "
               "olive, portant de petites baies rouges et violettes",
        "sol": "de la terre olive et des pierres plates couvertes de mousse, "
               "quelques petites fleurs violettes",
        "teinte_mur": "vert olive SOMBRE, presque noir dans les creux du lierre, "
                      "avec les baies comme seules touches vives",
        "teinte_sol": "olive CLAIR et terreux, nettement plus lumineux que le "
                      "lierre des murs — c'est le seul contraste de ce biome",
        "props": [
            "un buisson d'épines à baies rouges",
            "un bouquet de champignons bleus LUMINEUX",
            "un arbre tordu aux branches nues",
            "une souche couverte de mousse",
            "un rocher gris couvert de mousse",
            "un groupe de trois cailloux moussus",
            "un tronc couché envahi de lierre",
            "une fougère vert sombre en éventail",
            "un crâne à moitié pris dans les ronces",
            "un tonneau de bois moussu",
            "une borne runique à gravure verte LUMINEUSE",
            "une lanterne de fer, verre ambré ALLUMÉ",
        ],
    },
    8: {
        "mur": "un muret de BLOCS DE PIERRE CLAIRE fissurés, avec du lierre vert "
               "et de la mousse dans les joints",
        "sol": "des dalles de pierre pâle disjointes, de la mousse dans les "
               "joints et de l'herbe rase qui perce entre elles",
        "teinte_mur": "pierre CLAIRE presque blanche, patinée, avec le vert du "
                      "lierre en accent",
        "teinte_sol": "pierre grisée plus SOMBRE et plus terne que celle des murs, "
                      "avec du vert mousse dans les joints",
        "props": [
            "une colonne de pierre brisée, posée debout",
            "un bloc de pierre gravé, couché",
            "un petit tas de dalles éboulées",
            "un arbre mort aux branches nues",
            "un buisson à petites fleurs violettes",
            "un rocher gris couvert de mousse",
            "un groupe de trois cailloux clairs",
            "un crâne posé au sol",
            "un chariot de bois à roues de fer",
            "deux planches de bois clouées",
            "un obélisque de pierre à gemme verte LUMINEUSE",
            "une lanterne de fer, verre vert ALLUMÉ",
        ],
    },
    9: {
        "mur": "un muret de BLOCS DE PIERRE VERT-DE-GRIS fissurée, couverts d'une "
               "mousse sombre, sans aucune lueur",
        "sol": "de la pierre sombre vert-de-gris craquelée, de la mousse noire "
               "dans les fissures, aucune fleur",
        "teinte_mur": "vert-de-gris MOYEN, pierre humide et froide — c'est le plus "
                      "clair des deux, mais tout reste sombre dans ce biome",
        "teinte_sol": "vert-de-gris TRÈS SOMBRE, presque noir : le sanctuaire est "
                      "éteint, seule la lueur violette des props l'éclaire",
        "props": [
            "un arbre pétrifié violet, branches nues et tordues",
            "un amas de cristaux violets dressés",
            "un tas d'ossements",
            "un crâne posé au sol",
            "une colonne vert-de-gris brisée, debout",
            "un bloc de pierre fissuré, couché",
            "une souche de pierre",
            "un rocher sombre couvert de mousse noire",
            "un tonneau de bois pourri",
            "deux planches de bois vermoulues",
            "une borne runique à gravure violette LUMINEUSE",
            "un brasero de pierre à flamme verte ALLUMÉE",
        ],
    },
    10: {
        "mur": "un muret de MARBRE BLANC à bordure dorée, serti de petites gemmes "
               "bleues à intervalles réguliers",
        "sol": "des dalles de marbre pâle veiné d'or, et de très légères traînées "
               "de nuages blancs qui passent dessus",
        "teinte_mur": "marbre BLANC lumineux et or brillant, avec le bleu des "
                      "gemmes en accent",
        "teinte_sol": "marbre crème plus SOMBRE et plus doré que celui des murs, "
                      "sinon sol et murs se confondent en un seul aplat clair",
        "props": [
            "un buisson fleuri dans un pot doré",
            "un petit arbre à feuillage doré",
            "une fontaine basse en marbre, eau bleue",
            "un rocher clair arrondi",
            "un groupe de trois cailloux clairs",
            "une colonne de marbre brisée, debout",
            "un banc de marbre",
            "une caisse de bois à ferrures dorées",
            "un chariot doré à deux roues",
            "un amas de cristaux bleus",
            "une borne de marbre à gemme bleue LUMINEUSE",
            "une lanterne dorée sur pied, verre ambré ALLUMÉ",
        ],
    },
}

## Les 16 cases du mur : c'est de la GÉOMÉTRIE, elle ne change pas d'un stage à
## l'autre. Une seule écriture, donc une seule chose à corriger si elle est fausse.
CASES = """Rangée 1
1. bloc ISOLÉ : une masse ronde au centre, qui ne touche AUCUN bord
2. cul-de-sac ouvert vers le HAUT (arrondi en bas)
3. cul-de-sac ouvert vers la DROITE (arrondi à gauche)
4. cul-de-sac ouvert vers le BAS (arrondi en haut)

Rangée 2
5. cul-de-sac ouvert vers la GAUCHE (arrondi à droite)
6. tronçon DROIT vertical : ouvert vers le haut ET vers le bas
7. tronçon DROIT horizontal : ouvert vers la gauche ET vers la droite
8. COIN ouvert vers le HAUT et vers la DROITE

Rangée 3
9.  COIN ouvert vers la DROITE et vers le BAS
10. COIN ouvert vers le BAS et vers la GAUCHE
11. COIN ouvert vers la GAUCHE et vers le HAUT
12. T ouvert vers le HAUT, la DROITE et le BAS (fermé à gauche)

Rangée 4
13. T ouvert vers la DROITE, le BAS et la GAUCHE (fermé en haut)
14. T ouvert vers le BAS, la GAUCHE et le HAUT (fermé à droite)
15. T ouvert vers la GAUCHE, le HAUT et la DROITE (fermé en bas)
16. CROIX : ouvert vers les QUATRE bords"""

ENTETE = """> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts.py`. Ne pas l'éditer à la
> main : corriger une consigne se fait dans la table de l'outil, puis on relance.
> Sinon la correction ne profite qu'à un stage sur dix.

Si le modèle rend mieux en anglais, demande-lui de **traduire ce prompt** avant
de générer : ça évite de maintenir soixante blocs en deux langues.
"""

RATES_COMMUN = """| Une couture visible quand on répète | **ne rien changer** — le raccord est mon travail |"""


def luminance(patch: Image.Image) -> float:
    """Luminance moyenne d'une découpe, sur 255."""
    pixels = np.asarray(patch.convert("RGB")).reshape(-1, 3).astype(float)
    return float((pixels @ np.array([0.299, 0.587, 0.114])).mean())


def sol_page(index: int, data: dict) -> str:
    return f"""# terrain_{index}_sol — le SOL du stage {index} ({NAMES[index - 1]})

{ENTETE}
**Joins `ref/ref_{index}_sol.png` à ChatGPT** — ce sont les panneaux de sol
étiquetés de `assets/stages/stage_{index}.png` — et dis « même style, même palette ».

Une seule image, la matière occupe tout. **Pas de magenta** : il n'y a rien à
détourer. Résultat attendu : `terrain_{index}_sol.png` dans `assets/peso&cover/terrain/`.

```
Texture de sol pour un jeu 2D vu de DESSUS, style cartoon coloré, contour marqué,
même facture et même palette que l'image de référence jointe.

FORMAT : une seule image carrée de 1024 x 1024 pixels.

SUJET : le sol des couloirs d'un labyrinthe — {data['sol']}. Vue strictement
VERTICALE, à la perpendiculaire du sol : aucun horizon, aucun ciel, aucune
perspective, aucun objet debout.

ÉCHELLE, le point le plus important : l'image entière représente environ 3 x 3
mètres de sol. Un caillou, une fleur, un éclat font donc moins d'un CENTIÈME de
la largeur de l'image. Il y en a des centaines, petits et serrés. Aucun élément
ne doit dominer l'image.

ÉCLAIRAGE : parfaitement PLAT et UNIFORME. Pas de vignettage, pas de coin sombre,
pas de tache de lumière, pas d'ombre d'un objet hors champ. La luminosité doit
être la même au centre et dans les quatre coins.

COULEURS : {data['teinte_sol']}. C'est le FOND sur lequel courent les
personnages : garde-le CALME — moins contrasté, moins saturé et moins détaillé
que le mur. Entre deux valeurs, prends la plus sourde.

RÈGLES ABSOLUES :
- la matière touche les QUATRE BORDS de l'image, elle est coupée net par le cadre
- aucun cadre, aucune bordure, aucune vignette, aucun fond visible
- aucun chemin continu, aucune ligne traversant l'image de part en part : des
  PLAQUES et des semis, pas un sentier
- aucun texte, aucun chiffre, aucun filigrane
- aucun personnage, aucun objet debout, aucun mur
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Un coin plus sombre que le centre | insister sur « éclairage PLAT », relancer |
| Un gros élément au milieu | rappeler « moins d'un centième de la largeur » |
| Un sentier traverse l'image | rappeler « des PLAQUES, pas un sentier » |
{RATES_COMMUN}

⚠️ Ne demande jamais « seamless » / « tileable » : le modèle dessinera un cadre
pour faire semblant. Voir [../PROMPT_TERRAIN.md](../PROMPT_TERRAIN.md).
"""


def mur_page(index: int, data: dict) -> str:
    return f"""# terrain_{index}_mur — les MURS du stage {index} ({NAMES[index - 1]})

{ENTETE}
**Joins `ref/ref_{index}_mur.png` à ChatGPT** — c'est le panneau de labyrinthe de
`assets/stages/stage_{index}.png` — et dis : « refais-moi ce jeu de pièces au
complet, même style, même palette ».

Ce n'est **pas une matière**, c'est un **jeu de 16 pièces** — un autotile. La
planche du stage en contient déjà l'essentiel : droits, coins, T, croix,
culs-de-sac. C'est ce qui donne au mur une SILHOUETTE, et c'est de loin ce qui
manque le plus au jeu aujourd'hui (le moteur pose un carré plein par case, sans
bord ni coin).

Résultat attendu : `terrain_{index}_mur.png` dans `assets/peso&cover/terrain/`.

```
Planche de tuiles pour un jeu 2D vu de DESSUS, style cartoon coloré, contour
marqué, même facture et même palette que l'image de référence jointe.

SUJET : {data['mur']}, vu de dessus. Le mur a une ÉPAISSEUR : on voit une fine
tranche plus sombre le long de son bord BAS, et une ombre douce portée sur le sol
sous ce bord.

FORMAT, à respecter exactement :
- image de 1024 x 1024 pixels
- grille RÉGULIÈRE de 4 colonnes x 4 rangées, soit 16 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé, sans ombre
- aucun texte, aucun chiffre, aucune bordure dessinée, aucun trait de grille

LA RÈGLE QUI COMPTE PLUS QUE TOUT — LE RACCORD :
chaque pièce est un tronçon de mur de MÊME LARGEUR, toujours CENTRÉ dans sa case.
Quand un tronçon rejoint un bord de case, il doit TOUCHER ce bord et le remplir
sur toute sa largeur, sans arrondi et sans magenta résiduel : deux cases posées
côte à côte dans le jeu doivent former un mur continu, sans décrochement ni
bosse. Là où un tronçon NE rejoint PAS un bord, il se termine par un bout
ARRONDI, et le magenta reste visible jusqu'au bord.

LES 16 CASES, de gauche à droite puis de haut en bas. « ouvert vers X » = le
tronçon touche ce bord de la case.

{CASES}

COULEURS : {data['teinte_mur']}. Le mur doit se DÉTACHER franchement du sol de
la référence : c'est lui qu'on suit des yeux quand on cherche son chemin. Donne-
lui une LUMINOSITÉ nettement différente de celle du sol — plus claire ou plus
sombre, peu importe, mais jamais la même valeur.

AUTRES RÈGLES :
- exactement la MÊME largeur de tronçon, la MÊME matière et le MÊME niveau de
  détail dans les 16 cases. Une pièce plus épaisse que sa voisine se verrait à
  chaque jonction du labyrinthe
- la lumière vient toujours du HAUT, jamais de côté : le dessus est clair, la
  tranche du bas est plus sombre. Ne fais pas tourner cet éclairage d'une pièce
  à l'autre
- les détails (fleurs, cristaux, fissures, gemmes) sont ÉPARS et jamais aux mêmes
  endroits d'une case à l'autre
- rien ne dépasse sur la case voisine
- aucun personnage, aucun sol, aucun décor, aucun objet posé
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Les tronçons n'ont pas tous la même largeur | c'est **le** défaut bloquant : relancer en insistant sur « MÊME largeur, toujours CENTRÉ » |
| Du magenta au bord d'une case ouverte | rappeler « toucher le bord et le remplir sur toute sa largeur » |
| L'éclairage tourne d'une pièce à l'autre | rappeler « la lumière vient toujours du HAUT » |
| Des pièces manquent ou sont dans le désordre | redemander la case fautive seule, en 256 x 256 sur magenta |
| Frange colorée autour du magenta | rien à faire côté prompt, je dégorge au découpage |

**Si le modèle ne tient pas les 16 d'un coup** : demande-lui les deux premières
rangées (8 cases, 1024 x 512), puis les deux dernières dans la MÊME conversation
en disant « même style, même largeur de mur que la planche précédente ».

⚠️ Ce jeu de pièces demande une modification du moteur (`MazeRenderer` choisit
aujourd'hui une seule tuile pleine). C'est prévu, c'est de mon côté. Voir
[../PROMPT_TERRAIN.md](../PROMPT_TERRAIN.md).
"""


def decor_page(index: int, data: dict) -> str:
    lignes = []
    for rang in range(3):
        lignes.append(f"Rangée {rang + 1}")
        for colonne in range(4):
            numero = rang * 4 + colonne + 1
            espace = " " if numero < 10 else ""
            lignes.append(f"{numero}.{espace} {data['props'][numero - 1]}")
        lignes.append("")
    liste = "\n".join(lignes).rstrip()

    return f"""# terrain_{index}_decor — le SEMIS des couloirs du stage {index} ({NAMES[index - 1]})

{ENTETE}
**Joins `ref/ref_{index}_decor.png` à ChatGPT** — ce sont les props de
`assets/stages/stage_{index}.png` — et dis « même style, même palette, mêmes contours ».

À quoi ça sert : `DecorLayer` sème un objet sur une case de couloir sur douze.
Les neuf objets actuels sont **générés en code** par `build_assets.py`, et sont
les mêmes aux dix stages. Ceux de la planche sont sans commune mesure.

Résultat attendu : `terrain_{index}_decor.png` dans `assets/peso&cover/terrain/`.

```
Planche d'objets de décor pour un jeu 2D vu de DESSUS, style cartoon coloré,
contour marqué, même facture et même palette que l'image de référence jointe.

FORMAT, à respecter exactement :
- image de 1024 x 768 pixels
- grille RÉGULIÈRE de 4 colonnes x 3 rangées, soit 12 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé, sans ombre
  portée sur le magenta
- aucun texte, aucun chiffre, aucune bordure dessinée

LES 12 OBJETS, de gauche à droite puis de haut en bas — un seul objet par case,
CENTRÉ, posé au sol, vu de dessus en légère plongée (on voit le dessus et un peu
la face avant, comme dans la référence) :

{liste}

RÈGLES ABSOLUES :
- chaque objet occupe environ 70 % de sa case et reste CENTRÉ, avec du magenta
  visible tout autour : rien ne touche le bord de sa case
- la MÊME échelle apparente d'une case à l'autre : ces objets seront posés côte
  à côte dans le même couloir. Un caillou aussi haut qu'un arbre serait faux
- la lumière vient du HAUT dans les douze cases
- l'ombre au sol est TRÈS légère et collée sous l'objet — pas de grande ombre
  portée qui déborderait sur le magenta
- les deux DERNIERS objets sont les seuls à ÉMETTRE de la lumière ; les dix
  autres ne brillent pas
- aucun personnage, aucun sol, aucun fond, aucun mur
- aucun cristal taillé en gemme à ramasser, aucune pierre précieuse isolée :
  ce sont les objectifs du jeu, le décor ne doit jamais les imiter
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Les objets n'ont pas la même échelle entre eux | relancer en insistant sur « MÊME échelle apparente » |
| Un objet touche le bord de sa case | rappeler « 70 % de la case, centré, magenta tout autour » |
| Une grande ombre portée sur le magenta | rappeler « ombre très légère, collée sous l'objet » |
| Tout brille | rappeler « seuls les deux DERNIERS émettent de la lumière » |

⚠️ Les cases 11 et 12 partent dans la liste **GLOWING** de `DecorLayer` — elles
reçoivent une lumière en jeu, contrairement aux dix autres. C'est pour ça
qu'elles sont toujours en dernier, à tous les stages. Voir
[../PROMPT_TERRAIN.md](../PROMPT_TERRAIN.md).
"""


def index_page(faits: list) -> str:
    lignes = []
    for index in faits:
        data = STAGES[index]
        mur = data["mur"].split(",")[0].replace("un muret de ", "").replace("une ", "")
        lignes.append(
            f"| {index} | {NAMES[index - 1]} | {mur} | "
            f"[sol]({{0}}terrain_{index}_sol.md) · "
            f"[mur]({{0}}terrain_{index}_mur.md) · "
            f"[decor]({{0}}terrain_{index}_decor.md) |"
        )
    table = "\n".join(lignes).format("prompts/")

    return f"""# Le terrain des dix stages — index des prompts

⚠️ Les trente fichiers de `docs/prompts/` sont **GÉNÉRÉS** par
`tools/build_prompts.py`. Ne pas les éditer à la main.

Trois planches par stage, à demander une par une, chacune avec son image de
référence en pièce jointe. Dépose les résultats dans
**`assets/peso&cover/terrain/`** sous les noms indiqués dans chaque fichier.

| # | Stage | Le mur, c'est | Prompts |
|---|---|---|---|
{table}

## Pourquoi les prompts n'imposent PAS lequel est le plus clair

Le jeu impose 52 de luminance d'écart entre sol et mur (`MIN_CONTRAST`) : c'est
ce qui fait qu'on LIT le chemin. Mais le SENS de cet écart n'est écrit nulle
part dans les prompts, et c'est délibéré.

Deux façons de le mesurer sur ces planches ont été essayées, et elles se
contredisent sur les dix : les regrouper en deux familles de couleurs suit les
REFLETS — veines d'éclair du Canyon, fleurs des haies — et rend le mur
systématiquement plus clair ; prendre « ce qui est le plus loin de la couleur du
sol » suit les CONTOURS NOIRS et rend le mur systématiquement plus sombre.
Inscrire dans vingt fichiers une direction qu'on ne sait pas mesurer serait pire
que de ne rien écrire.

Les prompts demandent donc un **écart franc sans en imposer le sens** —
l'image de référence jointe porte déjà le rapport réel bien mieux qu'une phrase.
Je mesure ensuite sur la planche LIVRÉE, et `MIN_CONTRAST` écarte les deux
valeurs dans le sens que le dessin a choisi, sans jamais l'inverser.

---

## Ce qu'on demande, et pourquoi ce n'est pas la même chose selon la planche

**Le SOL est une MATIÈRE.** On ne demande jamais un tileset : les modèles
d'image ne savent pas faire une tuile raccordable — ils rendent une jolie image
carrée dont les bords ne se rejoignent pas, et répétée elle affiche une grille de
coutures. On a d'ailleurs déjà échoué à découper des tuiles dans ces planches, et
le constat est dans `build_stage_tiles.py` : le plus grand carré inscriptible
dans un mur d'une case fait quelques pixels. Donc on demande une grande plaque
uniforme, et **le raccord, c'est moi qui le fabrique** — décalage torique et
fondu sur la couture. Ne demande jamais « seamless » : le modèle dessinera un
cadre pour faire semblant.

**Le MUR est un JEU DE 16 PIÈCES.** Parce que les planches en contiennent déjà
l'essentiel, et que c'est ça qui fait « un vrai labyrinthe » : une matière ne
peut produire ni un bout arrondi ni un angle. La contrainte de raccord y est
faible et vérifiable à l'œil — même largeur de tronçon, toujours centré, et qui
remplit le bord de case qu'il touche.

**Le DÉCOR est un semis d'objets isolés**, sur magenta comme les icônes de sorts.
Les deux derniers de chaque planche sont toujours les objets LUMINEUX : ils
partent dans la liste `GLOWING` de `DecorLayer`, qui leur accroche une lumière.

---

## Ce que je fais quand les planches arrivent

1. **Raccord fabriqué, pas demandé** — décalage torique d'une demi-image, fondu
   sur la couture, réduction. Une plaque uniforme y survit sans qu'on voie rien :
   c'est pour ça que les prompts insistent sur « éclairage plat » et « aucun
   élément dominant ».
2. **Période portée de 3 à 6 cases** — planches de 192 x 192 au lieu de 96, et
   `MazeRenderer` lira la période dans la LARGEUR de la texture au lieu de la
   coder en dur.
3. **L'autotile dans le moteur** — `_draw_hedge` calculera le masque des 4
   voisins et prendra la pièce correspondante dans la planche 4 x 4. Les blocs
   2 x 2 se résolvent en quatre coins, dont l'union donne un carré arrondi.
4. **Le contraste est vérifié et forcé** — `MIN_CONTRAST` impose 52 de luminance
   d'écart, dans le sens que le décor a choisi ; l'outil ne l'inverse jamais.
5. **Contrôle à l'image** : `--stage N --overview` avant / après, et un aplat de
   8 x 4 cases pour traquer les coutures.

Un stage peut avancer seul : rien n'oblige à fournir les trente planches d'un
coup, et les stages sans planche gardent leur terrain teinté actuel.
"""


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    REF.mkdir(parents=True, exist_ok=True)

    faits = []
    for index, data in sorted(STAGES.items()):
        source = SHEETS / f"stage_{index}.png"
        if not source.exists():
            print(f"  ! {source} introuvable")
            continue
        with Image.open(source) as sheet:
            image = sheet.convert("RGB")
            tailles = {}
            for kind in ("sol", "mur", "decor"):
                crop = image.crop(BOXES[index][kind])
                crop.save(REF / f"ref_{index}_{kind}.png")
                tailles[kind] = crop.size

        (OUT / f"terrain_{index}_sol.md").write_text(
            sol_page(index, data), encoding="utf-8")
        (OUT / f"terrain_{index}_mur.md").write_text(
            mur_page(index, data), encoding="utf-8")
        (OUT / f"terrain_{index}_decor.md").write_text(
            decor_page(index, data), encoding="utf-8")
        faits.append(index)
        print(f"stage {index:2d}  {NAMES[index - 1]:24s} "
              + "  ".join(f"{k} {w}x{h}" for k, (w, h) in tailles.items()))

    Path("docs/PROMPT_TERRAIN.md").write_text(index_page(faits), encoding="utf-8")
    print(f"\n{len(faits) * 3} prompts + {len(faits) * 3} références "
          f"+ docs/PROMPT_TERRAIN.md")


if __name__ == "__main__":
    main()
