# Le Jugement des quatre — l'ultime du Sorcier Suprême

## Ce qui existe déjà côté jeu

L'ultime est **fini et jouable**. Il ne manque que le dessin.

| | |
|---|---|
| **souffle** | 110 dégâts sur 6 cases, onde de choc, traverse les murs |
| **12 météores** | qui VISENT les poursuivants vivants, 58 dégâts chacune |
| **séisme** | 3,4 s de tremblement pendant que ça tombe |

⚠️ **Le total est fixe et les cibles sont prises à tour de rôle** : six ennemis
en reçoivent deux chacun, les deux derniers en reçoivent six chacun. Plus il en
reste peu, plus ça tombe dru — c'est ce qui en fait un jugement et pas un feu
d'artifice.

Il remplace le **Prisme des quatre**, un souffle de 180 sur 7 cases : un gros
chiffre, et rien à regarder.

En attendant les planches, les météores empruntent le rocher de l'éruption du
Mage du Feu. C'est jouable, mais ce sont des cailloux — pas les quatre éléments.

---

## Deux planches, deux rôles

    meteore_supreme.png   la BOULE qui tombe — 12 images, une rotation complète
    jugement_mage.png     l'INCANTATION du mage — 8 images

La météore est demandée avec **beaucoup d'images**, et pour une raison précise :
elle traverse l'écran en moins d'une seconde, en diagonale, et c'est le seul
moment où on la voit. Une boule à quatre images tourne comme une roue de charrue.

⚠️ **Elle tombe EN DIAGONALE À 45°**, du haut-gauche vers le bas-droite — le
moteur la lance de vingt-deux cases en haut et vingt-deux à gauche de son point
de chute, c'est-à-dire **hors de l'écran** : elle entre toujours par le coin
haut-gauche, quel que soit l'endroit du labyrinthe qu'elle vise. Sa traîne doit
donc partir vers le HAUT-GAUCHE, dans son dos, et à cet angle-là.

---

## Prompt 1 — la météore

> Une planche, `meteore_supreme.png`, dans `assets/peso&cover/sorts/`.

```
Feuille d'animation pour un sort de jeu 2D vu de DESSUS, style cartoon coloré à
contours nets, effets lumineux, même facture que les sprites de sorts d'un jeu
de rôle mobile.

FORMAT, à respecter exactement :
- UNE image de 1536 x 2048 pixels
- grille RÉGULIÈRE de 3 colonnes x 4 rangées, soit 12 cases de 512 x 512
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé ni ombre
- dans chaque case, la météore est CENTRÉE et occupe environ 75 % de la case
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun personnage

SUJET — une MÉTÉORE DES QUATRE ÉLÉMENTS : une grosse boule dont la surface est
partagée en quatre quartiers qui tournent ensemble — un quartier de ROCHE EN
FUSION orange et rouge, un de GLACE bleue, un de PIERRE brune et verte, un de
VENT blanc tourbillonnant. Les quatre se rejoignent en un cœur doré incandescent
qu'on aperçoit entre eux. Une couronne de débris et d'étincelles tourne autour.

LA TRAÎNÉE : elle part vers le HAUT-GAUCHE, en diagonale, comme si la boule
tombait vers le bas-droite. Feu, givre, poussière et vent y sont mêlés. Elle
occupe le coin haut-gauche de la case et s'estompe avant le bord.

LES 12 CASES sont une ROTATION COMPLÈTE de la boule sur elle-même, lues de gauche
à droite puis de haut en bas : à chaque case les quatre quartiers ont tourné d'un
douzième de tour, et la douzième case doit ramener exactement à la première.

⚠️ RÈGLE BLOQUANTE — LA BOULE NE BOUGE PAS DANS SA CASE. Elle tourne sur
elle-même, elle ne se déplace pas et ne change pas de taille : c'est le jeu qui
la fait tomber. Une boule qui dérive d'une case à l'autre sauterait à l'écran à
chaque image.

AUTRES RÈGLES :
- la traîne part TOUJOURS du même côté, haut-gauche, dans les 12 cases
- les quatre quartiers gardent leur ordre en tournant : feu, glace, pierre, vent
- aucun cratère, aucun impact, aucune explosion : c'est la boule EN VOL
```

---

## Prompt 2 — l'incantation du mage

> Une planche, `jugement_mage.png`, dans `assets/peso&cover/sorts/`.

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
- aucun texte, aucun chiffre, aucun trait de grille, aucun personnage, aucun sol

SUJET — LE CIEL QUI S'OUVRE. Une déchirure de lumière dorée s'ouvre en hauteur
au-dessus du lanceur, bordée de nuages d'orage sombres, et quatre courants de
couleur y sont aspirés — rouge, bleu, vert, blanc — avant que la lumière ne
s'engouffre vers le bas. Vue de DESSUS en légère plongée, comme le reste du jeu.

LES 8 CASES s'enchaînent, lues de gauche à droite puis de haut en bas — c'est une
OUVERTURE, pas une boucle :
1. le ciel est intact : seules quatre étincelles de couleur montent
2. une fêlure dorée apparaît, fine
3. la fêlure s'ouvre, les nuages se creusent autour
4. la déchirure est béante, les quatre courants y entrent en spirale
5. la lumière s'accumule dans la déchirure, blanche au cœur
6. elle déborde et commence à couler vers le bas
7. le trop-plein descend en colonne, la déchirure se referme derrière
8. il ne reste qu'une lueur qui s'éteint et quelques braises

⚠️ La huitième case est PRESQUE VIDE : le sort se termine, les météores prennent
le relais. Une dernière image encore pleine laisserait un halo figé au-dessus du
mage pendant tout le reste du sort.

AUTRES RÈGLES :
- la MÊME position de la déchirure dans les 8 cases : elle grandit sur place
- les quatre couleurs restent identifiables jusqu'à la case 5
- aucun cratère, aucune météore : c'est ce qui les ANNONCE
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| La boule dérive dans sa case | **défaut bloquant** : elle sauterait à l'écran à chaque image. Redemander la planche |
| La traîne change de côté d'une case à l'autre | rappeler « TOUJOURS haut-gauche, dans les 12 cases » |
| La rotation ne boucle pas entre la case 12 et la case 1 | moins grave que pour les sceaux — la météore ne fait qu'une seconde de vol, elle ne boucle presque pas |
| La météore est dessinée avec son cratère | rappeler « c'est la boule EN VOL » — l'impact est déjà dessiné par le jeu |
| L'incantation finit sur une image pleine | rappeler « la huitième case est PRESQUE VIDE » |

---

## Ce que je fais quand les planches arrivent

1. **découpe** — la météore en bande de 12 images, l'incantation en bande de 8,
   toutes deux ramenées à une case commune, comme les effets des sceaux ;
2. **branchement** — `Meteor` prend la bande au lieu du rocher de l'éruption et
   la joue pendant sa chute. La pente est en place : 22 cases pour 22, la boule
   naît hors champ et traverse l'écran en biais ;
3. **l'incantation** passe par `SpellCharge`, le nœud écrit pour les Quatre
   Sceaux — il joue une bande une seule fois au-dessus du mage, puis disparaît ;
4. **contrôle à l'image** : une capture en démo avec deux ennemis, pour vérifier
   qu'on voit bien six météores tomber sur chacun plutôt que douze éparpillées.
