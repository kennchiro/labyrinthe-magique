#!/usr/bin/env python3
"""Les prompts des quatre effets élémentaires des Quatre Sceaux.

    tools/.venv/bin/python tools/build_prompts_sceaux.py     # DEPUIS LA RACINE

Produit `docs/prompts/sorts/sceau_<element>.md`, un par élément.

POURQUOI QUATRE PLANCHES ET NON UNE

C'est l'inverse de la décision prise pour le sceau lui-même. Là-bas on n'a
demandé qu'UN dessin pour quatre zones, parce que les quatre devaient être
IDENTIQUES à la couleur près — quatre gravures générées séparément n'auraient
jamais eu le même diamètre.

Ici c'est le contraire : les quatre effets doivent être DIFFÉRENTS, et
reconnaissables au premier coup d'œil. Une flamme, de la glace, des pierres et
une tornade n'ont aucune raison de partager quoi que ce soit. Chacune a donc sa
propre planche, qu'on peut relancer seule si elle rate.

Ce qui doit rester commun — le cadrage et la taille — n'est pas confié au
modèle : l'outil de découpe ramène les quatre à la même case.

CE QUE CES EFFETS SONT, ET NE SONT PAS

Ce ne sont pas des impacts. Le sceau tient SOIXANTE SECONDES, et son effet doit
tenir avec lui : c'est une boucle, jouée en continu par-dessus la gravure. D'où
la contrainte qui gouverne les quatre prompts — **la huitième image doit
enchaîner sur la première sans saut**. Une animation qui claque toutes les
huit images pendant une minute est pire que pas d'animation du tout.
"""

from pathlib import Path

OUT = Path("docs/prompts/sorts")

## Grille demandée : 8 images, lues de gauche à droite puis de haut en bas.
GRID = "4 colonnes x 2 rangées, soit 8 cases de 512 x 512"
SIZE = "2048 x 1024 pixels"

ELEMENTS = [
    {
        "id": "feu", "nom": "Feu", "couleur": "#ff6a2a",
        "sujet": "un FEU QUI MONTE. Des flammes qui s'élèvent depuis le sol, "
                 "orange et jaune au cœur, rouge sombre sur les bords, avec des "
                 "braises qui montent en tournoyant et s'éteignent en haut",
        "boucle": "les flammes ondulent et les braises montent en continu — "
                  "aucune extinction, aucun départ de feu : on prend le brasier "
                  "en cours et on le rend en boucle",
        "trait": "brûle — c'est le sceau qui fait le plus de dégâts",
    },
    {
        "id": "eau", "nom": "Eau", "couleur": "#37c6ff",
        "sujet": "une GELÉE QUI PREND. Des cristaux de glace qui poussent depuis "
                 "le sol en aiguilles bleu clair, un givre qui s'étale à leur "
                 "pied, et un souffle de froid blanc qui monte doucement",
        "boucle": "la glace pousse, craquelle, refond légèrement puis repousse — "
                  "un cycle fermé, jamais une fonte complète",
        "trait": "ralentit tant qu'on reste dessus",
    },
    {
        "id": "terre", "nom": "Terre", "couleur": "#7bc043",
        "sujet": "des PIERRES ET DES CRISTAUX QUI FRAPPENT. Des éclats de roche "
                 "brune et des cristaux verts qui jaillissent du sol en pointes, "
                 "se rétractent, et rejaillissent ailleurs, avec de la poussière "
                 "et des gravats qui retombent",
        "boucle": "les pointes jaillissent et retombent à tour de rôle — il y en "
                  "a toujours au moins une levée, la zone ne se vide jamais",
        "trait": "arrête net, une fois par passage",
    },
    {
        "id": "air", "nom": "Air", "couleur": "#cfe9ff",
        "sujet": "une TORNADE. Une colonne de vent translucide qui tourne sur "
                 "elle-même, blanc bleuté, avec des feuilles et de la poussière "
                 "prises dedans qui montent en spirale",
        "boucle": "la colonne tourne à vitesse constante — c'est la ROTATION qui "
                  "boucle, la tornade ne se forme ni ne se dissipe",
        "trait": "le plus large des quatre, mais le moins mordant",
    },
]

ENTETE = """> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts_sceaux.py`. Ne pas l'éditer à
> la main : une consigne se corrige dans la table de l'outil, puis on relance —
> sinon elle ne profite qu'à un élément sur quatre.
"""


def page(entry: dict) -> str:
    return f"""# sceau_{entry['id']} — l'effet du sceau de {entry['nom']}

{ENTETE}
Le sceau de {entry['nom']} {entry['trait']}. Il tient **60 secondes**, et son
effet doit tenir avec lui : ce n'est pas un impact, c'est une **boucle** jouée
en continu par-dessus la gravure.

**Joins `../../../assets/characters/supreme/sceaux_seal.png` à ChatGPT** — la
gravure sur laquelle l'effet se posera — et dis « l'effet vient AU-DESSUS de ce
sceau, il ne le remplace pas ».

Résultat attendu : `sceau_{entry['id']}.png` dans `assets/peso&cover/sorts/`.

```
Feuille d'animation pour un sort de jeu 2D vu de DESSUS, style cartoon coloré à
contours nets, effets lumineux, même facture que les sprites de sorts d'un jeu
de rôle mobile.

FORMAT, à respecter exactement :
- UNE image de {SIZE}
- grille RÉGULIÈRE de {GRID}
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé ni ombre
- dans chaque case, l'effet est CENTRÉ et occupe environ 80 % de la case
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun personnage

⚠️ RÈGLE BLOQUANTE — AUCUN CERCLE, AUCUN ANNEAU, AUCUNE GRAVURE, AUCUN DISQUE DE
SOL. Le jeu dessine DÉJÀ un sceau gravé sous cet effet, et il est le même pour
les quatre éléments : c'est lui qui les rend identiques. Un anneau dessiné ici
viendrait s'ajouter au sien — deux cercles superposés — et l'effet ne
ressemblerait plus aux trois autres.
Ne dessine QUE la matière : les flammes, la glace, les pierres, le vent. Entre
elles, le fond magenta doit se voir : c'est par là qu'on apercevra la gravure.

SUJET : {entry['sujet']}.

Vue de DESSUS en légère plongée : on regarde l'effet d'en haut, comme le reste du
jeu. Il monte donc vers le HAUT de l'image, et sa base est un disque au sol.

LES 8 CASES sont une BOUCLE, lues de gauche à droite puis de haut en bas :
{entry['boucle']}.

⚠️ LA RÈGLE QUI COMPTE PLUS QUE TOUT : la HUITIÈME case doit enchaîner sur la
PREMIÈRE sans saut. L'effet tourne pendant SOIXANTE SECONDES, soit une centaine
de tours : une boucle qui claque à chaque tour est pire que pas d'animation du
tout. Aucun élément ne doit se trouver à un endroit à la case 8 et ailleurs à la
case 1.

AUTRES RÈGLES :
- la MÊME emprise au sol dans les 8 cases : l'effet vit, il ne grossit pas
- palette dominante {entry['couleur']} — c'est à cette couleur qu'on reconnaît
  quel élément garde quel passage
- l'effet est AJOURÉ : entre les flammes, les cristaux ou les pierres, on voit le
  fond magenta. C'est par ces trous qu'apparaîtra la gravure du jeu
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| La boucle claque entre la case 8 et la case 1 | c'est **le** défaut bloquant — sur soixante secondes il revient cent fois. Redemander la planche entière |
| L'effet grossit d'une case à l'autre | rappeler « la MÊME emprise au sol dans les 8 cases » |
| Un cercle, un anneau ou un disque de sol est dessiné | **défaut bloquant** : il s'ajouterait à la gravure du jeu, et l'élément ne ressemblerait plus aux trois autres. Redemander la planche |
| L'effet est un disque plein, sans trous | rappeler « AJOURÉ : entre les pierres, on voit le fond » — sinon il cache la gravure |
| L'effet est vu de côté | rappeler « vue de DESSUS en légère plongée, sa base est un disque au sol » |
| Frange rose autour de l'effet | rien à faire côté prompt, je dégorge au découpage |

⚠️ Les quatre planches sont demandées SÉPARÉMENT, et c'est l'inverse de la
décision prise pour la gravure. Là-bas on n'en a dessiné qu'une pour quatre
zones, parce que les quatre devaient être identiques à la couleur près. Ici les
quatre doivent être DIFFÉRENTES et reconnaissables : une flamme et une tornade
n'ont aucune raison de partager quoi que ce soit. Le cadrage commun, lui, est
imposé au découpage — pas au modèle.
"""


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for entry in ELEMENTS:
        (OUT / f"sceau_{entry['id']}.md").write_text(page(entry), encoding="utf-8")
    print(f"{len(ELEMENTS)} prompts -> {OUT}/sceau_<element>.md")


if __name__ == "__main__":
    main()
