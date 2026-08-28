# sceau_terre — l'effet du sceau de Terre

> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts_sceaux.py`. Ne pas l'éditer à
> la main : une consigne se corrige dans la table de l'outil, puis on relance —
> sinon elle ne profite qu'à un élément sur quatre.

Le sceau de Terre arrête net, une fois par passage. Il tient **60 secondes**, et son
effet doit tenir avec lui : ce n'est pas un impact, c'est une **boucle** jouée
en continu par-dessus la gravure.

**Joins `../../../assets/characters/supreme/sceaux_seal.png` à ChatGPT** — la
gravure sur laquelle l'effet se posera — et dis « l'effet vient AU-DESSUS de ce
sceau, il ne le remplace pas ».

Résultat attendu : `sceau_terre.png` dans `assets/peso&cover/sorts/`.

```
Feuille d'animation pour un sort de jeu 2D vu de DESSUS, style cartoon coloré à
contours nets, effets lumineux, même facture que les sprites de sorts d'un jeu
de rôle mobile.

FORMAT, à respecter exactement :
- UNE image de 2048 x 1024 pixels
- grille RÉGULIÈRE de 4 colonnes x 2 rangées, soit 8 cases de 512 x 512
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

SUJET : des PIERRES ET DES CRISTAUX QUI FRAPPENT. Des éclats de roche brune et des cristaux verts qui jaillissent du sol en pointes, se rétractent, et rejaillissent ailleurs, avec de la poussière et des gravats qui retombent.

Vue de DESSUS en légère plongée : on regarde l'effet d'en haut, comme le reste du
jeu. Il monte donc vers le HAUT de l'image, et sa base est un disque au sol.

LES 8 CASES sont une BOUCLE, lues de gauche à droite puis de haut en bas :
les pointes jaillissent et retombent à tour de rôle — il y en a toujours au moins une levée, la zone ne se vide jamais.

⚠️ LA RÈGLE QUI COMPTE PLUS QUE TOUT : la HUITIÈME case doit enchaîner sur la
PREMIÈRE sans saut. L'effet tourne pendant SOIXANTE SECONDES, soit une centaine
de tours : une boucle qui claque à chaque tour est pire que pas d'animation du
tout. Aucun élément ne doit se trouver à un endroit à la case 8 et ailleurs à la
case 1.

AUTRES RÈGLES :
- la MÊME emprise au sol dans les 8 cases : l'effet vit, il ne grossit pas
- palette dominante #7bc043 — c'est à cette couleur qu'on reconnaît
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
