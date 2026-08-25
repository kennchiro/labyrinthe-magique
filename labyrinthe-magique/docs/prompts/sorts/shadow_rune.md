# La Rune du Sorcier des Ténèbres — prompt pour la planche animée

## Ce qui existe déjà

Le sort est **fini côté jeu** : trois charges, 8 s de recharge, 8 s de tenue, et
un **péage** — qui marche dessus y laisse 10 PV et un cinquième de sa vitesse
pendant 3 s, une fois par passage. Vérifié en headless.

Ce qui manque est le DESSIN. Le portail est actuellement le sprite de la
translation du mage (`warp.png`), posé à plat et animé par du code : deux
anneaux qui tournent en sens inverse, une ouverture progressive. Ça tient, mais
c'est un décal détourné de son usage.

Une planche d'images dessinées ferait mieux — et les effets qui l'entourent
(braises, ouverture, prise du péage) restent à ma charge, comme convenu.

---

## Le prompt

> Copier-coller tel quel. Le fond MAGENTA n'est pas un caprice : les modèles
> d'image tiennent mal la transparence, alors qu'un aplat magenta se détoure au
> pixel près — et aucune palette du jeu ne contient de magenta, donc rien de
> légitime ne lui ressemble. C'est la convention déjà utilisée pour les icônes
> de sorts, et elle a marché du premier coup sur trois planches.

```
Feuille d'animation pour un jeu 2D vu de DESSUS, style cartoon coloré, même
facture qu'un jeu de rôle mobile.

SUJET : un portail magique POSÉ AU SOL, vu de dessus — donc une ELLIPSE ÉCRASÉE
et non un cercle parfait, comme un trou vu en oblique. Anneau de runes gravées
qui tourne, cœur sombre et profond au centre (un puits, pas une lampe), éclats
violets qui s'en échappent. Palette : violet vif, magenta profond, noir. Aucun
autre coloris.

FORMAT, à respecter exactement :
- image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 2 rangées, soit 6 cases de 512 x 512
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé, sans
  ombre portée, sans cadre
- aucun texte, aucun numéro, aucune bordure dessinée

LES 6 IMAGES, lues de gauche à droite puis de haut en bas — c'est une
ANIMATION EN BOUCLE du portail déjà ouvert, pas une ouverture :
1. l'anneau de runes à sa position de départ, cœur sombre
2. l'anneau a tourné d'un sixième de tour, un éclat monte à gauche
3. l'anneau a tourné d'un tiers, le cœur se creuse
4. l'anneau à mi-tour, deux éclats montent
5. l'anneau aux deux tiers, le cœur se referme un peu
6. l'anneau aux cinq sixièmes — la suivante doit revenir sur la 1

RÈGLES IMPORTANTES :
- le portail occupe environ 80 % de la largeur de sa case et reste CENTRÉ
- exactement la MÊME taille, la MÊME position et le MÊME style dans les 6 cases :
  seule la rotation et les éclats changent. Un portail qui grandit d'une image à
  l'autre donnerait une animation qui palpite
- rien ne dépasse sur la case voisine
- pas de personnage, pas de décor, pas de sol : le portail seul sur le magenta
```

<details>
<summary>Version anglaise</summary>

```
Top-down 2D game animation sheet, colorful cartoon style, mobile RPG look.

SUBJECT: a magic portal LYING ON THE GROUND, seen from above — so a FLATTENED
ELLIPSE, not a perfect circle, like a pit seen at an angle. A rotating ring of
carved runes, a dark deep core at the centre (a well, not a lamp), violet shards
escaping upward. Palette: vivid violet, deep magenta, black. No other colors.

FORMAT, follow exactly:
- 1536 x 1024 pixel image
- REGULAR grid of 3 columns x 2 rows, i.e. 6 cells of 512 x 512
- PURE FLAT MAGENTA background (#FF00FF) in EVERY cell, no gradient, no drop
  shadow, no frame
- no text, no numbers, no drawn borders

THE 6 FRAMES, read left to right then top to bottom — a LOOPING animation of the
already-open portal, not an opening:
1. rune ring at its starting position, dark core
2. ring turned one sixth, one shard rising on the left
3. ring turned one third, core deepening
4. ring at half turn, two shards rising
5. ring at two thirds, core closing slightly
6. ring at five sixths — the next frame must land back on frame 1

IMPORTANT RULES:
- the portal fills about 80% of its cell width and stays CENTERED
- exactly the SAME size, position and style in all 6 cells: only the rotation
  and the shards change. A portal that grows between frames would pulse
- nothing crosses into the neighbouring cell
- no character, no scenery, no ground: the portal alone on the magenta
```
</details>

---

## Ce que je fais quand la planche arrive

Dépose-la dans `assets/peso&cover/` (dis-moi son nom) :

1. **découpe** — la grille 3 × 2 de 512 est EXACTEMENT celle des icônes de sorts,
   donc `tools/build_skill_icons.py` sait déjà la lire : détourage par TEINTE
   (300°) et non par distance RGB, tout le magenta part y compris enclavé, et le
   dégorgement anti-frange évite les bords violacés. Sortie en bande horizontale
   de 6 images + un descripteur, comme `orb.png` / `orb.json` ;
2. **branchement** — `ZoneEffect` lira la bande en `hframes` et fera tourner la
   boucle, à la place des deux anneaux que je dessine aujourd'hui ;
3. **les effets restent à moi** : l'ouverture progressive (0,42 s, lissée aux
   deux bouts), les braises, et surtout le **retour visuel du péage** — il faut
   qu'on VOIE la prise au moment où un ennemi traverse, sinon le joueur perd
   10 PV d'ennemi sans savoir que c'est son portail qui les a pris ;
4. **contrôle à l'image** : les 6 cases sur fond vert (pour repérer tout magenta
   survivant), puis une capture en jeu avec un gobelin qui traverse.

**Si le résultat n'est pas bon**, ce qui m'aide le plus est de me dire lequel des
trois défauts revient : portail qui change de taille d'une case à l'autre,
frange violacée sur les bords, ou boucle qui saute entre la 6 et la 1.
