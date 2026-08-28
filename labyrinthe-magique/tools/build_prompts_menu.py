#!/usr/bin/env python3
"""Les prompts de l'écran « Choisis ton mage » : portraits, cadre, fond.

    tools/.venv/bin/python tools/build_prompts_menu.py     # DEPUIS LA RACINE

Produit :
    docs/prompts/menu/portrait_<id>.md   un par mage — le personnage seul
    docs/prompts/menu/cadre_carte.md     le cadre VIDE, une seule fois
    docs/prompts/menu/fond_selection.md  le fond de la page
    docs/PROMPT_MENU.md                  l'index

⚠️ Fichier SÉPARÉ de `build_prompts.py`, qui fait le terrain. Rien à voir : ces
planches n'ont ni grille, ni raccord, ni contrainte de contraste de jeu, et leur
planche de référence est la maquette d'interface, pas les décors de stage.
C'est l'usage du projet — un outil par sujet.

CE QUI CLOCHE AUJOURD'HUI, ET QUE CES PROMPTS RÉPARENT

L'écran affiche le SPRITE DE JEU de chaque mage : sa première pose de marche de
face, vue de DESSUS, haute de 112 pixels. Dans une vignette de 116 x 142 elle
occupe un tiers de la surface et flotte au milieu d'une boîte vide. Ce n'est pas
un défaut de mise en page : un sprite vu de dessus ne fera JAMAIS un portrait,
parce qu'on n'y voit pas le visage.

Il faut donc un dessin fait pour ça. La maquette existe déjà —
`assets/peso&cover/interface/selection_mage1.jpeg` — et c'est elle qu'on rejoue.

POURQUOI LE CADRE EST DEMANDÉ **UNE SEULE FOIS**

C'est la décision qui structure tout le reste. Demander « le mage du Feu dans son
cadre » huit fois donnerait huit cadres différents : épaisseurs, gemmes, coins et
vignes ne tomberaient jamais deux fois pareil, et une rangée de huit cartes mal
assorties est PIRE qu'une rangée sans cadre. C'est exactement la leçon des pièces
de mur — « la même largeur de tronçon dans les seize cases » — et elle vaut ici
avec encore plus de force, puisque les huit cartes sont côte à côte à l'écran.

Le partage est donc :
    le MODÈLE dessine ce qui change  -> les huit personnages, le fond
    le MOTEUR dessine ce qui se répète -> le cadre, la lueur de sélection,
                                          la plaque de nom
Et le NOM reste du texte, jamais une image : il doit rester lisible à toutes les
tailles, et il changerait de langue avant l'image.
"""

from pathlib import Path

OUT = Path("docs/prompts/menu")

## Format des portraits. 3:4 debout, comme les cartes de la maquette. Le moteur
## dessine ses vignettes dans ce rapport plutôt que l'inverse : recadrer un
## personnage déjà dessiné lui coupe la tête ou les pieds.
PORTRAIT_SIZE = "1024 x 1365 pixels (rapport 3:4, debout)"

# id, nom affiché, élément, couleur, et ce à quoi le mage RESSEMBLE déjà dans le
# jeu. La description physique n'est pas inventée : elle est relevée sur la
# planche du mage et sur la maquette. Un portrait qui ne ressemble pas au sprite
# qu'on jouera ensuite est un mensonge fait au joueur au moment du choix.
MAGES = [
    {
        "id": "fire", "nom": "Mage du Feu", "element": "Feu", "couleur": "#ff6a2a",
        "corps": "une longue robe rouge sang à capuche, dont le capuchon ne "
                 "laisse voir que DEUX YEUX ORANGE lumineux — aucun visage. Un "
                 "bâton de bois noirci surmonté d'une flamme dans la main "
                 "gauche, une boule de feu qui danse au creux de la main droite. "
                 "Broderies d'or et braises qui montent le long de la robe",
        "aura": "orange et rouge, comme un feu de forge",
        "phrase": "Brûle tout ce qui approche.",
    },
    {
        "id": "water", "nom": "Mage de l'Eau", "element": "Eau", "couleur": "#37c6ff",
        "corps": "un grand CHAPEAU POINTU bleu qui retombe, une cape bleu roi, "
                 "et un visage juvénile bien VISIBLE et souriant sous le bord du "
                 "chapeau. Un bâton à cristal bleu clair dans la main droite, "
                 "des gouttes et un ruban d'eau qui tournent autour de lui",
        "aura": "bleu clair et turquoise, comme une eau éclairée par-dessous",
        "phrase": "Ralentit, encaisse et se soigne.",
    },
    {
        "id": "earth", "nom": "Mage de la Terre", "element": "Terre", "couleur": "#7bc043",
        "corps": "un NAIN trapu à LONGUE BARBE GRISE, visage buriné bien "
                 "visible, armure de cuir brun à plastron vert et épaulières de "
                 "pierre. Un lourd bâton noueux à cristal VERT dans la main "
                 "droite, des cailloux qui lévitent autour de ses pieds",
        "aura": "vert mousse et brun terre",
        "phrase": "Le plus résistant, et il peut fermer un couloir.",
    },
    {
        "id": "shadow", "nom": "Sorcier des Ténèbres", "element": "Ténèbres",
        "couleur": "#b06cff",
        "corps": "une robe violet sombre presque noire à large capuche, dont le "
                 "capuchon est un TROU NOIR sans visage ni yeux. Deux ORBES "
                 "VIOLETTES lumineuses flottent au-dessus de ses paumes "
                 "ouvertes, et de la fumée violette s'échappe du bas de la robe",
        "aura": "violet profond, avec un halo magenta",
        "phrase": "Maître des ombres et des portails.",
    },
    {
        "id": "thunder", "nom": "Mage de la Foudre", "element": "Foudre",
        "couleur": "#ffd93a",
        "corps": "des CHEVEUX BLANCS HÉRISSÉS dressés par l'électricité, un "
                 "visage jeune et décidé bien visible, une armure légère DORÉE "
                 "sur une tunique blanche. Un bâton à pointe d'or dans la main "
                 "droite d'où part un éclair, des arcs électriques bleus qui "
                 "courent sur ses bras",
        "aura": "jaune d'or et blanc électrique",
        "phrase": "Le plus rapide du royaume.",
    },
    {
        "id": "air", "nom": "Mage de l'Air", "element": "Air", "couleur": "#cfe9ff",
        "corps": "une robe BLANCHE et bleu très pâle, une longue écharpe qui "
                 "flotte loin derrière lui, une capuche rejetée en arrière sur "
                 "un visage calme et VISIBLE. Un bâton pâle surmonté d'une "
                 "plume, des spirales de vent translucides autour de ses pieds "
                 "— il ne touche pas tout à fait le sol",
        "aura": "blanc bleuté, très clair, comme un ciel d'hiver",
        "phrase": "Il gagne les combats qu'il refuse de livrer.",
    },
    {
        "id": "invocateur", "nom": "Invocateur", "element": "Ténèbres",
        "couleur": "#b06cff",
        "corps": "une robe noire et violette à capuche, un visage en partie "
                 "visible et grave sous le capuchon, un long bâton surmonté "
                 "d'une ORBE VIOLETTE À RUNES. À ses pieds, un CERCLE "
                 "D'INVOCATION gravé qui luit, et DEUX PETITES CRÉATURES "
                 "d'ombre aux yeux violets qui l'accompagnent",
        "aura": "violet et noir, avec la lueur du cercle par en dessous",
        "phrase": "Ne combat pas : il invoque.",
    },
    {
        "id": "supreme", "nom": "Sorcier Suprême", "element": "Suprême",
        "couleur": "#ffd36a",
        "corps": "une robe sombre à liserés d'or et une COURONNE dorée, le "
                 "visage dans l'ombre avec des yeux dorés. QUATRE SPHÈRES "
                 "élémentaires tournent autour de lui — une rouge de feu, une "
                 "bleue d'eau, une verte de terre, une jaune de foudre — et "
                 "leurs quatre couleurs se reflètent sur sa robe",
        "aura": "or, avec les quatre couleurs élémentaires qui s'y mêlent",
        "phrase": "Maître des quatre éléments.",
    },
]

ENTETE = """> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts_menu.py`. Ne pas l'éditer à
> la main : une consigne se corrige dans la table de l'outil, puis on relance —
> sinon elle ne profite qu'à un mage sur huit.
"""

COMMUN = """RÈGLES ABSOLUES :
- le personnage est ENTIER, debout, de face, légèrement de trois quarts, et
  regarde le joueur. On voit ses pieds et le haut de sa tête
- il occupe environ 80 % de la hauteur de l'image et reste CENTRÉ
- aucun CADRE, aucune bordure, aucun liseré, aucune vignette : le cadre est
  ajouté par le jeu, un cadre dessiné ici se superposerait au sien
- aucun TEXTE, aucun nom, aucun chiffre, aucun logo
- aucun sol, aucun décor, aucune ombre portée au sol : le fond est une nappe de
  couleur, pas une scène
- aucun autre personnage"""


def portrait_page(mage: dict) -> str:
    return f"""# portrait_{mage['id']} — {mage['nom']}

{ENTETE}
**Joins `../ref/ref_carte.png` à ChatGPT** — c'est une carte de la maquette
`selection_mage1.jpeg` — et dis « même style de personnage, mais SANS le cadre
ni le texte ».

Résultat attendu : `portrait_{mage['id']}.png` dans
`assets/peso&cover/interface/portraits/`.

```
Illustration de personnage pour un écran de sélection de jeu de rôle mobile,
style cartoon coloré à contours nets, personnage aux proportions héroïques
légèrement stylisées, même facture que l'image de référence jointe.

FORMAT : une seule image de {PORTRAIT_SIZE}.

SUJET — {mage['nom']} : {mage['corps']}.

FOND : une simple nappe de couleur {mage['aura']}, plus lumineuse derrière le
personnage et plus sombre vers les bords, comme un halo. Rien d'autre : ni
paysage, ni objet, ni motif.

{COMMUN}
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Un cadre ou une bordure apparaît | rappeler « aucun cadre, le jeu ajoute le sien » |
| Le personnage est coupé aux genoux | rappeler « ENTIER, on voit ses pieds » |
| Le fond devient un décor | rappeler « une nappe de couleur, pas une scène » |
| Le visage ne ressemble pas au sprite du jeu | rejoindre la planche `mages/mage_*.png` en seconde référence |

⚠️ Le NOM du mage n'est jamais dans l'image : c'est du texte dessiné par le jeu,
qui doit rester lisible à toutes les tailles. Voir
[../../PROMPT_MENU.md](../../PROMPT_MENU.md).
"""


def cadre_page() -> str:
    return f"""# cadre_carte — le cadre des huit cartes

{ENTETE}
**Joins `../ref/ref_carte.png` à ChatGPT** et dis « le CADRE seul de cette
carte, sans le personnage ni le texte ».

⚠️ **Une seule image pour les huit mages.** C'est la décision qui tient tout
l'écran : demander « le mage du Feu dans son cadre » huit fois donnerait huit
cadres différents — épaisseurs, gemmes, coins et vignes ne tomberaient jamais
deux fois pareil — et une rangée de huit cartes mal assorties est PIRE qu'une
rangée sans cadre. Le jeu teinte ce cadre unique à la couleur de chaque élément.

Résultat attendu : `cadre_carte.png` dans
`assets/peso&cover/interface/portraits/`.

```
Élément d'interface pour un jeu de rôle mobile, style cartoon coloré à contours
nets, même facture que l'image de référence jointe.

FORMAT : une seule image de {PORTRAIT_SIZE}.

SUJET : un CADRE DE CARTE VIDE, vu de face. Bordure de pierre grise sculptée
rehaussée d'or, angles renforcés, quelques vignes qui courent sur les côtés. Au
MILIEU DU BORD SUPÉRIEUR, un sertissage rond vide destiné à recevoir une gemme —
dessine le sertissage, PAS la gemme. Le cadre a une légère épaisseur, éclairée
par le haut.

L'INTÉRIEUR DU CADRE EST ENTIÈREMENT MAGENTA PUR UNI (#FF00FF), sans dégradé et
sans ombre : c'est la fenêtre où le jeu posera le portrait, et le magenta se
détoure au pixel près. Le magenta remplit aussi les quatre coins autour du cadre.

RÈGLES ABSOLUES :
- le cadre est GRIS et OR, sans aucune couleur d'élément : le jeu le teinte
  lui-même en rouge, bleu, vert, violet selon le mage. Un cadre déjà coloré
  donnerait huit teintes fausses
- la bordure fait environ un vingtième de la largeur de l'image, RÉGULIÈRE sur
  les quatre côtés
- aucun texte, aucune plaque de nom, aucun chiffre
- aucun personnage, aucun décor, aucun objet dans la fenêtre
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| L'intérieur n'est pas magenta | c'est bloquant : sans lui, pas de fenêtre. Relancer |
| Le cadre est doré-rouge ou coloré | rappeler « GRIS et OR, le jeu le teinte » |
| Une gemme est dessinée dans le sertissage | rappeler « le sertissage, PAS la gemme » |
| La bordure est plus épaisse en bas | rappeler « RÉGULIÈRE sur les quatre côtés » |
"""


def fond_page() -> str:
    return f"""# fond_selection — le fond de la page « Choisis ton mage »

{ENTETE}
**Joins `../ref/ref_fond.png` à ChatGPT** — c'est le fond de la maquette — et
dis « la même ambiance, en plein écran, SANS aucun élément d'interface ».

Résultat attendu : `fond_selection.png` dans
`assets/peso&cover/interface/`.

```
Illustration de fond pour un menu de jeu de rôle mobile, style cartoon coloré à
contours nets, même ambiance et même palette que l'image de référence jointe.

FORMAT : une seule image de 1536 x 864 pixels (rapport 16:9, paysage).

SUJET : des RUINES DE PIERRE ENVAHIES DE VÉGÉTATION, la nuit. Colonnes brisées
et arches couvertes de lierre au premier plan à gauche et à droite, un sol de
dalles au premier plan en bas, des montagnes sombres et un ciel de nuit étoilé au
fond. Quelques cristaux bleus et violets qui luisent doucement entre les pierres,
et de rares lucioles. Palette : bleu nuit profond, vert mousse sombre, gris
pierre, avec les cristaux comme seules notes lumineuses.

RÈGLE LA PLUS IMPORTANTE — LE CENTRE RESTE CALME :
la moitié centrale de l'image doit être SOMBRE, FLOUE et sans détail : c'est là
que le jeu écrit le nom du mage, sa description et la liste de ses sorts, et un
décor chargé rendrait ce texte illisible. Toute la matière intéressante — les
colonnes, le lierre, les cristaux — se tient sur les BORDS et dans les COINS.

AUTRES RÈGLES ABSOLUES :
- aucun élément d'interface : ni cadre, ni bouton, ni carte, ni panneau
- aucun TEXTE, aucun titre, aucun logo
- aucun personnage, aucune créature
- aucune source de lumière forte au centre, aucun rayon qui traverse l'image
- l'image porte jusqu'aux quatre bords, sans vignette dessinée ni cadre noir
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Le centre est chargé et le texte devient illisible | c'est le défaut bloquant : rappeler « la moitié centrale SOMBRE et sans détail » |
| Un titre ou un bouton apparaît | rappeler « aucun élément d'interface, aucun texte » |
| L'image est trop claire | rappeler « la nuit, les cristaux sont les SEULES notes lumineuses » |

⚠️ Le jeu assombrit encore ce fond derrière la fiche du mage. Une image déjà
sombre au centre laisse cette marge ; une image claire ne se rattrape pas.
"""


def index_page() -> str:
    lignes = "\n".join(
        f"| {m['nom']} | {m['element']} | `{m['couleur']}` | "
        f"[portrait_{m['id']}](prompts/menu/portrait_{m['id']}.md) |"
        for m in MAGES)
    return f"""# L'écran « Choisis ton mage » — index des prompts

⚠️ Les fichiers de `docs/prompts/menu/` sont **GÉNÉRÉS** par
`tools/build_prompts_menu.py`. Ne pas les éditer à la main.

## Ce qui cloche aujourd'hui

L'écran affiche le **sprite de jeu** de chaque mage : sa première pose de marche
de face, vue de DESSUS, haute de 112 pixels. Dans une vignette de 116 x 142 elle
occupe un tiers de la surface et flotte au milieu d'une boîte vide.

Ce n'est pas un défaut de mise en page. Un sprite vu de dessus ne fera **jamais**
un portrait : on n'y voit pas le visage, et c'est précisément le visage qu'on
regarde au moment de choisir. Il faut un dessin fait pour ça.

La maquette existe déjà — `assets/peso&cover/interface/selection_mage1.jpeg` —
et c'est elle qu'on rejoue.

## Dix prompts, à lancer un par un

| Mage | Élément | Couleur | Prompt |
|---|---|---|---|
{lignes}

Plus deux prompts communs :

| | Prompt | Pourquoi |
|---|---|---|
| Le cadre | [cadre_carte](prompts/menu/cadre_carte.md) | **une seule fois pour les huit** |
| Le fond | [fond_selection](prompts/menu/fond_selection.md) | la page entière |

Dépose les résultats dans `assets/peso&cover/interface/portraits/` (les huit
portraits et le cadre) et `assets/peso&cover/interface/` (le fond).

---

## Le partage entre le modèle et le moteur

C'est la décision qui structure tout le reste :

    le MODÈLE dessine ce qui CHANGE      -> les huit personnages, le fond
    le MOTEUR dessine ce qui SE RÉPÈTE   -> le cadre, la gemme d'élément,
                                            la lueur de sélection, le nom

Demander « le mage du Feu dans son cadre » huit fois donnerait **huit cadres
différents** : épaisseurs, gemmes, coins et vignes ne tomberaient jamais deux
fois pareil. Or les huit cartes sont côte à côte à l'écran, où le moindre écart
se voit. C'est la même leçon que les pièces de mur du terrain — « la même
largeur de tronçon dans les seize cases » — et elle vaut ici avec plus de force
encore.

Le **nom** reste du texte dessiné par le jeu, jamais une image : il doit rester
lisible à toutes les tailles, et il changerait de langue avant l'image.

---

## Ce que je fais quand les planches arrivent

1. **Le cadre est détouré une fois** (fenêtre magenta) et devient un `NinePatch` :
   ses bords s'étirent, ses coins ne se déforment pas, donc la même image sert à
   la vignette de la rangée et à la grande carte de la fiche ;
2. **`CharacterPortrait` change de dessin** : fond élémentaire, portrait, cadre
   teinté à la couleur de l'élément, gemme, puis la lueur de sélection par-dessus.
   Le sprite de jeu disparaît de cet écran ;
3. **Le fond remplace `MenuBackdrop`** sur cet écran, avec le voile sombre qui
   existe déjà derrière la fiche ;
4. **Repli prévu** : un mage sans portrait garde le rendu actuel. Rien n'oblige
   à fournir les huit d'un coup.
"""


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for mage in MAGES:
        (OUT / f"portrait_{mage['id']}.md").write_text(
            portrait_page(mage), encoding="utf-8")
    (OUT / "cadre_carte.md").write_text(cadre_page(), encoding="utf-8")
    (OUT / "fond_selection.md").write_text(fond_page(), encoding="utf-8")
    Path("docs/PROMPT_MENU.md").write_text(index_page(), encoding="utf-8")
    print(f"{len(MAGES)} portraits + cadre + fond -> {OUT}/")
    print("index -> docs/PROMPT_MENU.md")


if __name__ == "__main__":
    main()
