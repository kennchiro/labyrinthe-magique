# L'Éveil du Chérubin — le Gardien du Trône

> Le sixième et dernier ÉVEIL des anges. Le Chérubin garde un LIEU : son trait pose un œil sur ce qu'il frappe, et
> l'ennemi marqué qui arrive à son contact brûle ; son Extra plante son épée et ferme un cercle où nul n'entre.
> Éveillé, il devient **le Gardien du Trône** pendant une minute : le chérubin d'Ézéchiel, qui porte le trône, aux
> roues dans les roues et à l'épée qui tournoie. Son regard porte plus loin, et ce qu'il garde est plus grand.

**Jouable depuis le 2026-11-10** (`CharacterCatalog.cherubin_awakened`). Proposition préparée à la demande du
joueur sans validation séparée, images livrées le jour même. Les cinq images sont découpées dans
`assets/characters/cherubin_eveil` (avec `keep_cast`), `assets/icons/cherubin_eveil` et le portrait de la sélection,
revenu sur magenta et repeint par `tools/build_menu.py` (`NAPPES`). ⚠️ Sur sa planche d'attaque, ses cheveux tirent
plus vers l'orange que sur la marche : à regénérer si ça se voit en jeu. Ses effets sont peints au shader (`eden_*`,
œil et flamme dans `eden.gdshaderinc`) ; `tools/preview_eden.gd` les montre hors partie. Le couloir en feu est une case
en feu ordinaire (10 dégâts/s). Les chiffres sont des points de départ, jamais mesurés. Il reste **sous l'Archimage
Primordial**.

⚠️ **FOND MAGENTA POUR TOUTES SES IMAGES, ET JAMAIS DE ROSE NI DE VIOLET SUR LUI.** Ses planches d'origine sont
passées par le magenta (`demagenta`, jamais `despilled`). Son **SAPHIR ne doit jamais tirer vers le violet** : un
bleu qui a plus de rouge que de vert tomberait au détourage. Les ombres de son lin blanc sont **gris-bleu**, jamais
rosées. Vérifier la première image avant de commander les autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Gardien | ci-dessous, image 1 | `refonte/cherubin_eveil.png` | `refonte/cherubin.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/cherubin_eveil_marche.png` | `refonte/cherubin_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/cherubin_eveil_attaque.png` | `refonte/cherubin_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_cherubin_eveil_skills.png` | aucune |
| 5 | Le portrait de la sélection | [menu/portrait_cherubin_eveil](../menu/portrait_cherubin_eveil.md) | `interface/portraits/portrait_cherubin_eveil.png` | `interface/portraits/portrait_cherubin.png` et `mages/cherubin_eveil_marche.png` |

Le portrait se commande en dernier : il a besoin de la planche de marche. Aucune image pour les effets des sorts.
**Les flammes lancées, les épées qui tournent, les roues, les yeux posés sur les ennemis, l'éclair et le cercle du
Jardin sont faits par le JEU** : ils ne sont jamais dessinés sur ses planches.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## Le Gardien du Trône

### Ce qu'il devient

On reconnaît le Chérubin : un **jeune ange au visage grave et calme**, aux **yeux bleu saphir**, aux **cheveux d'or
foncé courts et bouclés**, en **tunique courte de lin blanc**, **cuirasse et jambières de bronze poli**, **ceinture
saphir**, avec ses **quatre ailes** en deux paires aux yeux d'or et son **épée à lame de flamme saphir**. Mais il est
devenu le chérubin du Trône :

- Ses **quatre ailes** sont un peu plus grandes, toujours repliées, et **couvertes d'yeux d'or** (« pleines d'yeux
  tout autour ») : un œil d'or à iris saphir sur presque chaque grande plume. Leurs pointes sont des **langues de
  flamme saphir** dessinées.
- La petite roue d'or derrière sa tête est devenue **une roue dans une roue** : deux roues d'or croisées, cerclées
  d'yeux, à jante de flamme saphir. C'est un objet solide, qui touche l'arrière de sa tête.
- Son épée est une **grande épée flamboyante** : lame de flamme saphir plus longue, aux langues ondulées, garde de
  bronze en forme d'ailes.
- Sa cuirasse de bronze porte, gravées en or, **quatre petites faces** (homme, lion, bœuf, aigle) en médaillons.
- Sa ceinture saphir laisse tomber deux pans de lin brodés d'yeux d'or.

Il reste chibi, à la même échelle que le Chérubin.

### Son trait éveillé : le Regard du Trône

**Son regard porte plus loin.** Tant que dure l'Éveil :
- l'ennemi marqué d'un œil brûle dès qu'il arrive à **deux cases** de lui, et non plus au contact ;
- cette brûlure fait **35** au lieu de 20, et l'œil se rallume deux fois plus vite.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Flamme du glaive | **Épée flamboyante** | le jet de flamme saphir file plus loin dans le couloir, brûle tout ce qu'il traverse, et laisse le couloir en feu un court instant | 18 dégâts, 7 cases, recharge 0,5 s ; couloir en feu 1,5 s |
| SKILL 1 | Glaive tournoyant | **L'Épée qui tournoie** | deux épées de flamme tournent autour de lui, plus large et plus longtemps (Genèse 3:24) | 16 dégâts, rayon 2, 6 s, un coup toutes les 0,4 s, recharge 9 s |
| SKILL 2 | Roues d'Ézéchiel | **Roues dans les roues** | quatre roues de feu à yeux partent dans les quatre directions des couloirs, et marquent d'un œil ce qu'elles brûlent | 4 roues, 32 dégâts, 8 cases, recharge 8 s |
| SKILL 3 | Ailes voilées | **Ailes du Trône** | il se couvre de ses ailes, intouchable, et repousse ce qui le touche ; quand elles s'ouvrent, tous les yeux de ses plumes s'ouvrent et marquent ce qui l'entoure | 3 s, repousse de 3 cases, marque tout à 3 cases, recharge 14 s |
| FUITE | Comme l'éclair | **Aspect de l'éclair** | il file droit comme l'éclair (Ézéchiel 1:14), traînée de flamme plus longue, et un éclair saphir tombe là où il arrive | 7 cases, traînée 30, éclair 40 rayon 1,5, recharge 9 s |
| EXTRA | Le Jardin gardé | **L'Éden gardé** | il plante son épée : un cercle plus grand, plus long ; ceux qui s'y trouvent sont rejetés et brûlent, et une épée de flamme tourne sur le bord du cercle et frappe ce qui s'en approche ; il regagne 2 PV | rayon 4,5, 10 s, 15 dégâts/s dedans, épée du bord 25, +2 PV |

Les boss entrent dans l'Éden et brûlent, comme dans le Jardin. L'Extra garde sa charge de kills : l'Éveil change le
sort, il ne le rend pas gratuit.

Le cœur de son jeu reste **garder un lieu** : poser des yeux sur ce qui approche et tenir sa place. L'Éveil agrandit
ce qu'il garde.

---

## Image 1 — le modèle du Gardien

Joindre `assets/peso&cover/refonte/cherubin.png` (le Chérubin, qu'il faut garder reconnaissable).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le Chérubin : c'est LE MÊME personnage, que tu dois transformer,
pas remplacer. Ne reprends PAS la mise en page de l'image jointe.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le visage, la double roue derrière la tête et l'épée flamboyante se voient bien
2. vue DE DOS, immobile : les QUATRE AILES couvertes d'yeux et la double roue se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : l'épée tenue droite, les ailes derrière son dos

LE PERSONNAGE — le Chérubin ÉVEILLÉ en GARDIEN DU TRÔNE. On le reconnaît tout de suite : même
jeune ange au corps CHIBI, même visage grave et calme bien VISIBLE, mêmes YEUX BLEU SAPHIR
(#3d6bff), mêmes CHEVEUX D'OR FONCÉ courts et bouclés, même TUNIQUE COURTE de LIN BLANC (#f3efe4)
au-dessus des genoux, même CUIRASSE de BRONZE POLI (#c9822e), mêmes jambières et sandales de
bronze, même CEINTURE BLEU SAPHIR (#2a4fd6), mêmes QUATRE AILES en DEUX PAIRES, blanches. Ce qui
change :
- ses quatre ailes sont un peu plus grandes, toujours repliées, et COUVERTES D'YEUX D'OR : un œil
  d'or en amande à iris saphir sur presque chaque grande plume, dessiné net et calme, jamais
  inquiétant ; leurs pointes sont des LANGUES DE FLAMME SAPHIR dessinées ;
- derrière sa tête, la petite roue d'or est devenue UNE ROUE DANS UNE ROUE : deux roues d'or
  croisées en X, cerclées de petits yeux d'or, à jante de flamme saphir ; c'est un OBJET SOLIDE
  qui TOUCHE l'arrière de sa tête, pas une auréole lumineuse ;
- il tient de la main droite une GRANDE ÉPÉE FLAMBOYANTE : une lame de flamme saphir plus longue,
  aux langues ondulées, en trois tons de bleu en aplats nets et opaques (bleu pâle presque blanc
  au cœur, saphir, bleu profond au bord), sans halo ; la garde de bronze a la forme de deux
  petites ailes ;
- sa cuirasse de bronze porte, gravées en or, QUATRE PETITES FACES en médaillons (un homme, un
  lion, un bœuf, un aigle), petites et nettes ;
- de sa ceinture saphir tombent deux pans de lin brodés de petits yeux d'or.
Toutes ses formes claires sont cernées d'un contour bleu-noir très sombre (#141a2e), net.

⚠️ RÈGLE BLOQUANTE — LE SAPHIR RESTE UN BLEU FRANC, JAMAIS VIOLET. Aucun rose, aucun violet, aucun
magenta sur lui, ni dans les flammes, ni dans les ombres du lin (GRIS-BLEU), ni en reflet : le
fond serait retiré avec.

⚠️ RÈGLE BLOQUANTE — LES QUATRE AILES RESTENT REPLIÉES. Elles ne dépassent pas de plus d'un quart
de la largeur du corps de chaque côté ; la paire du bas s'arrête au-dessus des genoux. Il devra
marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — LA DOUBLE ROUE TOUCHE SA TÊTE, jamais détachée et flottante.

⚠️ RÈGLE BLOQUANTE — UN ANGE, PAS UN MONSTRE : un seul visage, le sien. Les quatre faces ne sont que
de petits médaillons gravés sur la cuirasse. Les yeux des ailes sont un motif calme.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DU CHÉRUBIN : UN CORPS CHIBI DE 2,5 TÊTES, À LA MÊME
TAILLE. Posé à côté de l'image jointe, il fait la même hauteur. L'épée ne dépasse pas sa tête de
plus d'une demi-tête.

⚠️ RÈGLE BLOQUANTE — AUCUNE AURA, AUCUNE ÉTINCELLE, AUCUNE LUEUR FLOUE autour de lui. Les flammes de
l'épée, des ailes et de la roue sont DESSINÉES, nettes et pleines. Le jeu ajoute le reste.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
ailes, même roue, même épée, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le saphir tire sur le violet, ou des ombres roses dans le lin | Le détourage du magenta y ferait des trous |
| Des ailes déployées ou très larges | Il ne tiendrait plus dans un couloir |
| La double roue flotte au-dessus de la tête | Le découpage la jetterait comme une poussière |
| Plusieurs visages, ou des yeux inquiétants | Il deviendrait un monstre ; il reste un ange |
| Un halo ou des flammes floues autour de lui | Le jeu les dessine : ils seraient en double, et sa boîte enflerait |
| Il est plus grand que le Chérubin | Il ne doit pas changer de taille en s'éveillant |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/cherubin_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT ses quatre ailes à yeux, sa double
roue, sa cuirasse, sa tunique, son épée, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Chérubin éveillé en GARDIEN DU TRÔNE, en proportions CHIBI : visage grave aux
yeux saphir, cheveux d'or foncé bouclés, DOUBLE ROUE D'OR à yeux et à jante de flamme saphir qui
touche l'arrière de sa tête, tunique courte de lin blanc, cuirasse de bronze à quatre médaillons,
ceinture saphir, QUATRE AILES blanches couvertes d'yeux d'or à pointes de flamme saphir, REPLIÉES,
GRANDE ÉPÉE FLAMBOYANTE saphir tenue DROITE dans la main DROITE. Contour bleu-noir net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
roue comprise, est la même dans les 24 cases.

Il MARCHE d'un pas grave et mesuré, comme un gardien qui fait sa ronde. IL NE COURT PAS : le buste
reste DROIT et la tête haute, sans bouger d'une image à l'autre. Ses pas sont de la MÊME LONGUEUR
que sur le guide. Le bas de la tunique et la pointe des ailes bougent un peu à chaque image.

L'ÉPÉE reste dans sa main DROITE, tenue droite, pointe en l'air, dans les 24 cases : elle monte et
descend un peu avec le pas, sans jamais basculer ; ce bras balance moins loin. SON BRAS GAUCHE
BALANCE FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand la jambe droite part vers l'avant, le bras
gauche part vers l'avant lui aussi, puis il repart vers l'arrière. Le coude plie, la main suit avec
un léger temps de retard. Il ne reste JAMAIS figé le long du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, AVEC SON
ÉPÉE. Le VERT de la robe du guide ne doit pas passer sur lui.

LA RANGÉE DE PROFIL, de gauche à droite :
1. jambes ouvertes, comme sur le guide : un pied devant, l'autre derrière
2. jambes ouvertes, comme sur le guide
3. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, un seul à peine levé
4. jambes ouvertes de nouveau, les pieds ont ÉCHANGÉ leur place
5. jambes ouvertes : l'INVERSE de l'image 1
6. jambes ouvertes : l'INVERSE de l'image 2
7. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, l'autre à peine levé
8. jambes ouvertes de nouveau : l'image enchaîne sur la première

⚠️ RÈGLE BLOQUANTE — LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. De profil, aux images 3 et 7, la
largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5. Dans les
trois rangées, les images 5 à 8 ne répètent pas les images 1 à 4.

⚠️ RÈGLE BLOQUANTE — LES QUATRE AILES RESTENT REPLIÉES dans les 24 cases, jamais déployées.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LE BAS DE LA TUNIQUE ET LA POINTE DES AILES
BOUGENT. Dans une même rangée, la tête, la roue et le tronc se superposent exactement d'une case
à l'autre, et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE NI VIOLET SUR LUI : le saphir reste bleu franc. Aucune étincelle,
aucune lueur floue.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule détachée.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/cherubin_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT ses quatre ailes à yeux, sa double roue, sa cuirasse, sa tunique, son
épée, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Chérubin éveillé en GARDIEN DU TRÔNE, en proportions CHIBI : cheveux d'or foncé
bouclés, double roue d'or à yeux derrière la tête, tunique de lin blanc, cuirasse de bronze,
quatre ailes couvertes d'yeux d'or, repliées, GRANDE ÉPÉE FLAMBOYANTE saphir dans la main DROITE.
Contour bleu-noir net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il pointe
son épée flamboyante droit devant lui pour lancer sa flamme.
1. posture prête, épée droite
2. il ramène l'épée contre son épaule, la flamme de la lame grandit
3. il commence à pousser l'épée vers l'avant
4. LE COUP : l'épée est tendue DROIT DEVANT lui, dans la direction de la rangée, bras tendu, pointe
   en avant, et un petit ÉCLAT SAPHIR, plus petit que sa tête, brille sur la pointe
5. l'éclat a disparu, l'épée est encore tendue
6. l'épée revient vers lui
7. l'épée revient presque à la verticale
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE COUP PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit éclat saphir de
l'image 4, collé à la pointe. Pas de jet de flamme lancé, pas d'arc : le JEU les dessine.

⚠️ RÈGLE BLOQUANTE — LES QUATRE AILES RESTENT REPLIÉES pendant tout le geste.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE NI VIOLET SUR LUI, ni en reflet du fond.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune aura, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc, la tête et la roue se
superposent exactement dans les 8 images d'une rangée (seuls les bras et l'épée bougent).

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, il regarde VERS LA DROITE
dans les 8 cases.
```

---

## Image 4 — les six icônes éveillées

Aucune image à joindre.

```
Planche de six ICÔNES DE SORTS pour un jeu de rôle mobile, style cartoon coloré,
contours nets, lisibles en tout petit.

PERSONNAGE : le Chérubin éveillé en GARDIEN DU TRÔNE, le chérubin d'Ézéchiel. Ses couleurs sont le
BLEU SAPHIR des flammes (#3d6bff, profond #2a4fd6, cœur bleu pâle presque blanc #dce6ff), l'OR
(#f2c14e), le BRONZE (#c9822e) et le LIN BLANC (#f3efe4, ombres gris-bleu), avec un CONTOUR
BLEU-NOIR TRÈS SOMBRE (#141a2e) net autour de chaque forme. Le motif commun des six icônes est
L'ŒIL D'OR à iris saphir et LA FLAMME SAPHIR : ils doivent se retrouver dans chacune.

FORMAT, à respecter exactement :
- image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 2 rangées, soit 6 cases de 512 x 512
- fond MAGENTA UNI #FF00FF partout, y compris entre les cases, sans dégradé
- NE PAS dessiner les lignes de la grille, ni cadre, ni numéro, ni texte
- une seule icône par case, CENTRÉE, occupant environ 70 % de sa case
- une forme à peu près aussi large que haute, qui tiendrait dans un cercle
- au moins 40 pixels de vide magenta tout autour de chaque icône
- rien ne dépasse sur la case voisine, ni en haut ni en bas

LES SIX ICÔNES, dans cet ordre de lecture :

1. ÉPÉE FLAMBOYANTE — une épée à lame de flamme saphir ondulée, pointe en avant, qui lance un long
   jet de flamme saphir, avec un petit œil d'or sur la garde.

2. L'ÉPÉE QUI TOURNOIE — deux épées de flamme saphir qui tournent l'une derrière l'autre en cercle,
   autour d'un œil d'or au centre.

3. ROUES DANS LES ROUES — deux roues d'or croisées, cerclées d'yeux d'or, à jante de flamme saphir,
   avec quatre traînées de feu qui partent dans quatre directions.

4. AILES DU TRÔNE — deux ailes blanches couvertes d'yeux d'or, refermées en bouclier, dont les yeux
   s'ouvrent en rayonnant.

5. ASPECT DE L'ÉCLAIR — un éclair saphir en zigzag, avec une traînée de flamme et une petite aile
   blanche à son départ.

6. L'ÉDEN GARDÉ — une épée de flamme saphir plantée pointe en bas au centre d'un cercle de feu
   saphir, avec un petit arbre d'or derrière elle et une couronne d'yeux d'or autour du cercle.
   C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune lueur floue, aucune case vide, AUCUN ROSE NI VIOLET dans les
icônes : ils se confondraient avec le fond magenta. Le saphir est un BLEU FRANC, jamais violet. Les
yeux sont calmes, jamais inquiétants. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Ils seront peints au shader, comme ceux des autres Éveils. Mêmes règles : trois temps (départ, coup, trace qui
s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette du Gardien

| rôle | couleur | usage |
|---|---|---|
| Le saphir | `#3d6bff` / `#2a4fd6` | flammes, épées, roues, cercle |
| Le cœur de flamme | `#dce6ff` | cœur des flammes, éclair |
| L'or | `#f2c14e` | yeux, roues, anneaux |
| Le bronze | `#c9822e` | gardes, médaillons |
| Le contour | `#141a2e` | tout ce qui doit tenir sur un sol clair |

Le motif commun est **l'œil d'or qui s'ouvre** et **la flamme saphir**. Jamais de violet, de rose ni de vert.

### L'Éveil lui-même

- **La charge, 0,8 s :** des yeux d'or s'ouvrent un à un en cercle autour de lui, et la roue derrière sa tête tourne
  de plus en plus vite.
- **L'éclosion :** la double roue grandit derrière lui en deux grands cercles de flamme qui se croisent, tous ses
  yeux s'ouvrent en même temps dans un éclair saphir, et un anneau de flamme court au sol ; la caméra tremble.
- **Pendant la minute :** la double roue de lumière tourne lentement derrière lui, et un cercle de flamme saphir à
  deux cases marque jusqu'où porte son regard.
- **La fin :** les yeux se ferment un à un, et la roue de lumière s'éteint.

### Les six sorts

- **Épée flamboyante :** le jet de flamme file plus loin ; le couloir qu'il traverse garde des langues de flamme
  saphir un court instant.
- **L'Épée qui tournoie :** deux épées de flamme tournent en cercle autour de lui, laissant un anneau de feu.
- **Roues dans les roues :** quatre roues de feu à yeux roulent dans quatre directions ; ce qu'elles brûlent garde
  un œil d'or au-dessus de la tête.
- **Ailes du Trône :** ses ailes se referment en dôme ; quand elles s'ouvrent, une couronne d'yeux d'or s'ouvre
  autour de lui et marque ce qui l'entoure.
- **Aspect de l'éclair :** il file en éclair saphir ; à l'arrivée, un éclair tombe du ciel dans un fracas.
- **L'Éden gardé :** l'épée plantée, un grand cercle de flamme saphir s'élève, un arbre de lumière d'or pousse
  derrière l'épée, et une épée de flamme tourne lentement sur le bord du cercle.
