# Les icônes de sorts du Sorcier Suprême — prompt

## Ce qui existe déjà

Sept mages sur huit ont leurs six icônes ; **le Suprême est le dernier sans**.
Tout le reste est en place : `UiIcons` cherche
`assets/icons/<mage>/<id_du_sort>.png` et retombe sur les pastilles colorées
quand il ne trouve rien — c'est ce qui a permis d'habiller les mages un par un.
Il n'y a donc **rien à coder** : dès que la planche est découpée, les six
boutons changent, au clavier comme au pouce.

## Ses six sorts, et ce que chaque icône doit dire

| créneau | sort | ce qu'il fait |
|---|---|---|
| ATTAQUE | Trait élémentaire | 20 dégâts, portée 8 — **change d'élément à chaque tir** |
| SKILL 1 | Convergence élémentaire | 56 dégâts — les quatre éléments fondus en un noyau |
| SKILL 2 | Les Quatre Sceaux | zone de 60 s — quatre sceaux gravés au sol |
| SKILL 3 | Renaissance | rend 2 PV — eau et terre, la nature referme |
| FUITE | Glissement | saut de 6 cases |
| EXTRA | Jugement des quatre | 110 dégâts + 12 météores + la terre tremble |

Sa couleur est l'**or** (`#ffd36a`), et ses quatre éléments sont le rouge du feu,
le bleu de l'eau, le vert de la terre et le blanc bleuté de l'air.

---

## Le prompt

> Copier-coller tel quel. Le fond MAGENTA n'est pas un caprice : les modèles
> tiennent mal la transparence, et aucune palette du jeu ne contient de magenta,
> donc rien de légitime ne lui ressemble. C'est la convention des sept planches
> d'icônes déjà découpées.

```
Planche de six ICÔNES DE SORTS pour un jeu de rôle mobile, style cartoon coloré,
contours nets, lisibles en tout petit.

PERSONNAGE : le Sorcier Suprême, maître des quatre éléments. Sa couleur est l'OR
(#ffd36a) ; ses quatre éléments sont le ROUGE du feu, le BLEU de l'eau, le VERT
de la terre et le BLANC BLEUTÉ de l'air. Chaque icône doit mêler l'or à un ou
plusieurs de ces quatre.

FORMAT, à respecter exactement :
- image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 2 rangées, soit 6 cases de 512 x 512
- fond MAGENTA UNI #FF00FF partout, y compris entre les cases, sans dégradé
- NE PAS dessiner les lignes de la grille, ni cadre, ni numéro, ni texte
- une seule icône par case, CENTRÉE, occupant environ 70 % de sa case
- au moins 40 pixels de vide magenta tout autour de chaque icône
- rien ne dépasse sur la case voisine

LES SIX ICÔNES, dans cet ordre de lecture :

1. TRAIT ÉLÉMENTAIRE — une flèche d'énergie effilée qui file vers la droite,
   FENDUE EN QUATRE dans sa longueur : rouge, bleu, vert et blanc, cerclée d'or.
   Une courte traînée derrière elle.

2. CONVERGENCE ÉLÉMENTAIRE — quatre orbes (rouge, bleu, vert, blanche) qui
   tombent en spirale vers un NOYAU DORÉ au centre, prêt à éclater. On doit voir
   qu'elles convergent : les traînées pointent vers le centre.

3. LES QUATRE SCEAUX — vue de DESSUS : quatre sceaux runiques posés en carré sur
   le sol, un rouge, un bleu, un vert, un blanc, reliés par un anneau doré gravé.

4. RENAISSANCE — un bourgeon vert qui s'ouvre dans une goutte d'eau bleue, une
   lueur dorée en son cœur, deux feuilles neuves. Une icône PAISIBLE, sans
   éclat ni pointe : c'est la seule du lot qui soigne.

5. GLISSEMENT — une silhouette d'énergie dorée qui se dédouble en filant vers la
   droite, laissant derrière elle trois traînées : rouge, bleue et blanche.
   Le mouvement doit être immédiatement lisible.

6. JUGEMENT DES QUATRE — un ciel doré déchiré d'où tombent quatre météores, un
   par élément (rouge, bleu, vert, blanc), avec une onde de choc dorée au sol
   sous eux.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas de sol dessiné, pas
d'ombre portée, pas de cadre, pas de texte, pas de flou, aucune case vide, aucun
personnage entier — ce sont des SYMBOLES, pas des scènes.
```

---

## Ce que je fais quand la planche arrive

Déposer dans **`assets/peso&cover/sorts/mage_supreme_skills.png`**, puis me le
dire. J'ajoute une ligne à `tools/build_skill_icons.py` et je découpe.

⚠️ **Je relèverai d'abord ce que chaque case MONTRE.** Le générateur ne respecte
pas l'ordre du prompt — mesuré sur la planche de l'Eau, où il avait placé le
geyser en troisième et le bouclier en quatrième alors qu'ils étaient demandés en
sixième et troisième. La table de l'outil associe donc chaque case au sort
qu'elle DESSINE, jamais à celui qui a été demandé.

⚠️ Et le détourage a sa propre règle, née d'un échec : la clé retire tout ce qui
a la teinte du magenta, **y compris enclavé** — un reflet magenta au cœur d'une
flamme est du fond vu à travers. L'échelle se fait sur la DIAGONALE et non sur
le côté, parce que les boutons tactiles sont RONDS : une icône large calée sur
sa largeur déborderait du cercle.
