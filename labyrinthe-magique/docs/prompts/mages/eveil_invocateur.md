# L'Éveil de l'Invocateur — le Maître des Légions

> Le septième ÉVEIL des mages. L'Invocateur ne combat pas : il invoque, et ses créatures chassent pendant
> qu'il court aux gemmes. Éveillé, il devient **le Maître des Légions** pendant une minute : ses créatures
> naissent éveillées, plus grandes et plus fortes, il en garde davantage, et pour la première fois il les
> COMMANDE — il marque la proie, et toute la meute s'y jette. Son ultime appelle un dragon couvert de feu.

**Jouable depuis le 2026-11-08** (`CharacterCatalog.invocateur_awakened`). Les cinq images ci-dessous ont été
commandées dans cet ordre, la première servant de modèle aux trois suivantes ; elles sont découpées dans
`assets/characters/invocateur_eveil`, `assets/icons/invocateur_eveil`, et le dragon dans
`assets/allies/dragon_eveil_*.png` (`tools/build_invocateur.py --dragon-eveil`, clé `dragon_eveil` d'allies.json).

⚠️ **FOND VERT, PAS MAGENTA.** L'Invocateur est violet : sur le fond magenta habituel, le détourage ferait des
trous dans sa robe et dans son orbe. Ses images se commandent sur un **vert pur (#00FF00)**, et rien sur lui
n'est vert. Le dragon aussi : ses flammes ont des pointes roses et orangées que le magenta mangerait.
Vérifier la première image avant de commander les autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Maître | ci-dessous, image 1 | `refonte/invocateur_eveil.png` | `refonte/invocateur.png` et `refonte/chrono.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/invocateur_eveil_marche.png` | `refonte/invocateur_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/invocateur_eveil_attaque.png` | `refonte/invocateur_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_invocateur_eveil_skills.png` | aucune |
| 5 | Le dragon embrasé | ci-dessous, image 5 | `creatures/invocateur_dragon_eveil.png` | `mage_invocateur_dragon_no_fire.png` |

Aucun portrait à commander : la carte de l'écran de sélection reste celle de l'Invocateur. Aucune image pour
les diablotins ni la gargouille : le jeu reprend les leurs, les grandit et leur ajoute une aura de runes au
shader. Aucune image pour les effets des sorts : ils seront peints au shader.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## Le Maître des Légions

### Ce qu'il devient

On reconnaît l'Invocateur : ses **cheveux noirs en épis**, son visage découvert, sa **robe violette à liserés
d'or**, son **collier de crânes**, et son **bâton torsadé** tenu de la main DROITE, surmonté d'une **orbe
violette** enserrée dans des griffes d'or. Mais il commande maintenant une armée. Une **couronne de cornes
noires** cerclée d'or sort de ses cheveux. Ses **yeux brillent de violet**. Sa robe s'allonge en un **manteau
de seigneur** au col haut, dont le bas est **brodé de runes violettes lumineuses**. Le collier de crânes est
devenu une **chaîne de petits crânes aux orbites violettes**. Les griffes d'or du bâton se sont ouvertes en
**couronne** autour d'une orbe plus grande, où tourne un **cercle de runes**. À sa hanche gauche, un
**grimoire** fermé par une chaîne porte un **œil violet** sur sa couverture.

Il reste chibi, à la même échelle que l'Invocateur. Les **chaînes de lumière** qui le relient à ses créatures
ne sont **pas dessinées** : c'est le jeu qui les fait.

### Son trait éveillé : la Légion

**Ses créatures naissent éveillées.** Tant que dure l'Éveil, chaque créature invoquée est plus grande, entourée
d'une aura de runes violettes, et frappe **50 % plus fort**. Il en garde **6** au lieu de 4. Une chaîne de lumière
violette le relie à chacune. Quand l'une d'elles tue, une étincelle remonte la chaîne jusqu'à lui.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Trait occulte | **Marque du grimoire** | une aiguille de runes ; l'ennemi touché porte un sceau au-dessus de lui, et TOUTES ses créatures le prennent pour cible | 14 dégâts, 9 cases, 0,5 s, marque 4 s |
| SKILL 1 | Diablotins | **Nuée infernale** | un portail crache quatre diablotins ; chacun explose en flammes violettes quand il s'en va (fin de vie, ou place cédée au plafond) | 4 diablotins, 15 s, explosion 12 dégâts rayon 1, recharge 18 s |
| SKILL 2 | Gargouille | **Gargouille colossale** | la gargouille tombe du ciel près de la proie la plus proche : onde de choc qui étourdit, puis elle chasse, deux fois plus grande | chute 25 dégâts rayon 1,5, étourdit 1 s, 40 s, recharge 22 s |
| SKILL 3 | Cercle d'invocation | **Porte des abysses** | le cercle devient un portail qui ronge, et d'où sort un diablotin toutes les 2 s tant qu'il reste ouvert | rayon 2, 6 s, 10/s, un diablotin / 2 s, recharge 12 s |
| FUITE | Pas du néant | **Échange** | il échange sa place avec sa créature AU SOL la plus éloignée (deux cases au moins) ; sans créature, c'est le Pas du néant | recharge 8 s, repli 4 cases |
| EXTRA | Dragon ancien | **Roi-Dragon** | le ciel s'assombrit, un sceau s'ouvre au-dessus de lui, le dragon embrasé traverse l'écran sur sa rangée et la ligne de feu s'allume derrière lui (par-dessus les haies), puis il chasse | ligne de feu 40 dégâts, 12 cases de chaque côté, 1,5 de large ; dragon 2 min, une fois et demie plus grand |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

---

## Image 1 — le modèle du Maître

Joindre `assets/peso&cover/refonte/invocateur.png` en PREMIER (l'Invocateur, qu'il faut garder reconnaissable),
puis `assets/peso&cover/refonte/chrono.png` (les proportions et la mise en page).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
La PREMIÈRE image jointe montre l'Invocateur : c'est LE MÊME personnage, que tu dois
transformer, pas remplacer. La DEUXIÈME image jointe sert UNIQUEMENT de référence de
proportions et de mise en page : ne copie ni son personnage, ni ses couleurs, ni ses objets.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- ⚠️ fond VERT PUR UNI (#00FF00) partout : un aplat, sans dégradé ni texture. PAS de magenta.
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le visage, la couronne et la chaîne de crânes se voient bien
2. vue DE DOS, immobile : le manteau et ses runes se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile

LE PERSONNAGE — l'Invocateur ÉVEILLÉ en MAÎTRE DES LÉGIONS. On le reconnaît tout de suite : même
jeune sorcier au corps compact, mêmes CHEVEUX NOIRS EN ÉPIS, même visage découvert, même robe
VIOLETTE (#5a2a8c) à LISERÉS D'OR (#d4a640), même BÂTON TORSADÉ tenu de la main DROITE et surmonté
d'une ORBE VIOLETTE enserrée dans des griffes d'or. Ce qui change :
- une COURONNE DE CORNES NOIRES cerclée d'or sort de ses cheveux : quatre petites cornes
  recourbées vers l'arrière, pas plus hautes que sa mèche ;
- ses YEUX brillent de VIOLET VIF (#c77dff) ;
- sa robe s'allonge en MANTEAU DE SEIGNEUR violet sombre (#2e1450) au col haut et raide, doublé de
  noir (#140a20), dont le bas est brodé de RUNES VIOLETTES LUMINEUSES (#c77dff) ;
- son collier est devenu une CHAÎNE DE PETITS CRÂNES blancs (#efe6d6) aux orbites violettes ;
- les griffes d'or de son bâton se sont ouvertes en COURONNE autour d'une orbe plus grande, où
  tourne un CERCLE DE RUNES violet vif ;
- à sa hanche GAUCHE pend un GRIMOIRE fermé par une chaîne d'or, avec un ŒIL VIOLET sur sa
  couverture noire.
Toutes ses formes sont cernées d'un contour noir violacé (#0a0512), net.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, ni dans les reflets, ni dans les ombres, ni en lueur :
le fond vert serait retiré avec. Ses couleurs sont le violet, le noir, l'or, le blanc os et la peau.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'INVOCATEUR : UN CORPS CHIBI COMPACT, À LA MÊME
TAILLE. Posé à côté de la première image jointe, il fait la même hauteur, couronne comprise.

⚠️ RÈGLE BLOQUANTE — UN SEUL PERSONNAGE PAR CASE : aucune créature, aucun diablotin, aucun dragon,
aucune chaîne de lumière autour de lui. Le jeu s'en charge.

⚠️ RÈGLE BLOQUANTE — AUCUN CERCLE AU SOL, aucune fumée, aucun halo, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — IL RESTE DANS SA LARGEUR. Le manteau ne s'étale pas à plus d'une
demi-largeur de corps de chaque côté.

⚠️ RÈGLE BLOQUANTE — SES PIEDS SE LISENT EN TRÈS PETIT. Les deux bottes se voient sous le manteau,
séparées l'une de l'autre.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même
couronne, le bâton toujours dans la main DROITE, le grimoire toujours à la hanche GAUCHE.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le fond est magenta, ou n'est pas un vert uni | Le détourage trouerait le violet |
| Du vert sur lui (reflets, lueur de l'orbe) | Il partirait avec le fond |
| Une créature ou un cercle dessiné avec lui | Le jeu les dessine lui-même : ils seraient en double |
| Il est plus grand que l'Invocateur | Il ne doit pas changer de taille en s'éveillant |
| Le bâton a changé de main | Toutes ses poses de marche le reprendraient à l'envers |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/invocateur_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT sa couronne, son manteau, son
bâton, son grimoire, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- ⚠️ fond VERT PUR UNI (#00FF00) partout : un aplat, sans dégradé ni texture. PAS de magenta.
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Invocateur éveillé en MAÎTRE DES LÉGIONS, en proportions CHIBI, corps compact :
cheveux noirs en épis sous une COURONNE DE CORNES NOIRES cerclée d'or, yeux violets lumineux, long
MANTEAU violet sombre à col haut et liserés d'or, bas du manteau brodé de RUNES VIOLETTES, CHAÎNE DE
PETITS CRÂNES au cou, GRIMOIRE fermé à la hanche GAUCHE, et BÂTON TORSADÉ dans la main DROITE,
surmonté d'une orbe violette dans une couronne de griffes d'or. Contour noir violacé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale
est la même dans les 24 cases.

Il MARCHE d'un pas ASSURÉ de seigneur. IL NE COURT PAS : le buste reste DROIT, le menton haut. Ses
pas sont de la MÊME LONGUEUR que sur le guide. Le bas de son manteau ondule un peu différemment à
chaque image, et le grimoire se balance à sa hanche.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps.
- LE BRAS GAUCHE (main libre) balance en grand, de l'avant vers l'arrière ;
- LE BRAS DROIT (celui du bâton) balance AUSSI, moins loin : la main avance et recule, et le bâton
  suit en s'inclinant, son pied passant un peu devant puis un peu derrière, sans jamais toucher le sol.

LE BALANCEMENT DES BRAS, image par image, calé sur les jambes du guide :
1. bras gauche tendu vers l'AVANT, main à hauteur de taille ; main du bâton vers l'ARRIÈRE
2. bras gauche qui redescend, coude un peu plié ; main du bâton qui revient
3. les deux bras le long du corps, POINT DE PASSAGE (c'est l'image aux jambes jointes)
4. bras gauche qui part vers l'arrière ; main du bâton qui part vers l'avant
5. l'INVERSE de l'image 1 : bras gauche vers l'ARRIÈRE, main du bâton vers l'AVANT
6. main du bâton qui revient ; bras gauche qui revient
7. les deux bras le long du corps, POINT DE PASSAGE (jambes jointes)
8. bras gauche qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui avance
grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, avec SON
bâton à lui. Le VERT de la robe du guide ne doit pas passer sur lui.

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

⚠️ RÈGLE BLOQUANTE — LES BRAS NE SONT JAMAIS FIGÉS. Les images 1 et 5 montrent les bras inversés.
Deux images voisines identiques pour les bras sont une erreur. Le bâton suit sa main.

⚠️ RÈGLE BLOQUANTE — LE MANTEAU NE CACHE JAMAIS LES PIEDS : les deux bottes se voient dans les
24 cases, et le pied du bâton ne passe jamais pour un troisième pied : il reste au-dessus du sol.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LE BÂTON, LE GRIMOIRE ET LE BAS DU MANTEAU
BOUGENT. Dans une même rangée, la tête et le tronc se superposent exactement d'une case à l'autre,
et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — UN SEUL PERSONNAGE PAR CASE, aucune créature, aucun cercle au sol.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune fumée, aucune particule détachée.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/invocateur_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT sa couronne, son manteau, son bâton, son grimoire, ses couleurs et
ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- ⚠️ fond VERT PUR UNI (#00FF00) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Invocateur éveillé en MAÎTRE DES LÉGIONS, en proportions CHIBI, corps compact :
couronne de cornes noires cerclée d'or, yeux violets, long manteau violet sombre à liserés d'or et
runes violettes, chaîne de petits crânes, grimoire à la hanche GAUCHE, BÂTON TORSADÉ dans la main
DROITE surmonté d'une orbe violette dans une couronne de griffes d'or. Contour noir violacé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il
DÉSIGNE SA PROIE du bâton, comme un général qui donne l'ordre d'attaquer.
1. posture prête, le bâton droit dans la main droite
2. il lève le bâton haut au-dessus de sa tête, la main gauche ouverte, paume vers le bas
3. l'orbe s'allume plus fort, ses yeux aussi, le buste se ramasse
4. LE COUP : il abaisse le bâton à l'horizontale, pointé DEVANT lui dans la direction de la
   rangée, et un petit SCEAU de runes violet, plus petit que sa tête, brille juste devant l'orbe
5. le sceau a disparu, le bâton reste pointé
6. il ramène le bâton
7. le bâton revient à la verticale
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit sceau de l'image
4. Pas de cercle au sol, pas de créature : le JEU dessine les aiguilles, les marques et la meute.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, ni en reflet du fond.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune fumée, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc et la tête se
superposent exactement dans les 8 images d'une rangée (seuls les bras, le bâton, le manteau et
les genoux bougent).

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

PERSONNAGE : l'Invocateur éveillé en MAÎTRE DES LÉGIONS, un sorcier qui commande une armée de
créatures. Ses couleurs sont le VIOLET SOMBRE (#2e1450), le VIOLET VIF (#c77dff), l'OR (#d4a640),
le NOIR (#140a20) et le BLANC OS (#efe6d6), avec un CONTOUR NOIR VIOLACÉ (#0a0512) net autour de
chaque forme. L'icône du dragon ajoute le ROUGE (#b3121b), l'ORANGE (#ff7a1a) et le JAUNE (#ffd23f)
de ses flammes. Le motif commun des six icônes est le SCEAU DE RUNES (un cercle violet vif gravé de
runes) : il doit se retrouver dans chacune.

FORMAT, à respecter exactement :
- image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 2 rangées, soit 6 cases de 512 x 512
- ⚠️ fond VERT UNI #00FF00 partout, y compris entre les cases, sans dégradé. PAS de magenta.
- NE PAS dessiner les lignes de la grille, ni cadre, ni numéro, ni texte
- une seule icône par case, CENTRÉE, occupant environ 70 % de sa case
- une forme à peu près aussi large que haute, qui tiendrait dans un cercle
- au moins 40 pixels de vide vert tout autour de chaque icône
- rien ne dépasse sur la case voisine, ni en haut ni en bas

LES SIX ICÔNES, dans cet ordre de lecture :

1. MARQUE DU GRIMOIRE — une aiguille de runes violettes qui file vers la droite, et au bout un
   sceau de runes qui flotte au-dessus d'une petite silhouette de monstre noire.

2. NUÉE INFERNALE — un portail de runes d'où jaillissent quatre petits diablotins rouges aux ailes
   de chauve-souris, l'un d'eux éclatant en flammes violettes.

3. GARGOUILLE COLOSSALE — une gargouille de pierre grise aux ailes ouvertes qui s'écrase au sol
   dans un sceau de runes, avec une onde de choc en anneau.

4. PORTE DES ABYSSES — un grand cercle de runes vu en légère plongée, ouvert sur un gouffre violet
   d'où sortent des griffes et deux yeux.

5. ÉCHANGE — deux silhouettes, un sorcier à bâton et un petit diablotin, reliées par deux flèches
   de runes qui se croisent en échangeant leur place.

6. ROI-DRAGON — une tête de dragon rouge aux cornes claires, COUVERTE DE FLAMMES orangées et
   jaunes, gueule ouverte crachant du feu, devant un grand sceau de runes violet. C'est l'icône la
   plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de flou, aucune fumée floue, aucune lueur floue, aucune case vide, AUCUN VERT dans les icônes,
ni en reflet ni en lueur : il partirait avec le fond. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Image 5 — le dragon embrasé

Le dragon ancien de l'Invocateur, revu pour l'Éveil : **couvert de feu**. Joindre
`assets/peso&cover/mage_invocateur_dragon_no_fire.png` : c'est le dragon actuel, sur la grille que l'outil
sait déjà lire (`dragon_grid_poses` dans `tools/build_invocateur.py`). Le nouveau garde sa silhouette, ses
quatre directions, ses huit images par direction et la même grille.

```
Feuille de sprites d'une créature volante pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image
jointe montre le dragon actuel : c'est LE MÊME dragon, que tu dois embraser, pas remplacer.
Garde EXACTEMENT sa silhouette, ses proportions, ses poses, sa grille et l'ordre de ses images.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 4 rangées, soit 32 cases de 256 x 192
- ⚠️ fond VERT PUR UNI (#00FF00) partout : un aplat, sans dégradé, sans texture, sans le fond
  rouge nuageux de l'image jointe
- dans chaque case, le dragon est CENTRÉ, entier, ailes et flammes comprises
- rien ne dépasse sur la case voisine, et 8 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES QUATRE RANGÉES, de haut en bas, comme sur l'image jointe :
- rangée 1 : vu de DOS, il vole vers le HAUT de l'image (tête en haut)
- rangée 2 : vu de FACE, il vole vers le BAS de l'image (tête en bas, vers le joueur)
- rangée 3 : de PROFIL, TOURNÉ VERS LA GAUCHE, il vole vers la gauche
- rangée 4 : de PROFIL, TOURNÉ VERS LA DROITE, il vole vers la droite

LES 8 COLONNES de chaque rangée :
- colonnes 1 à 4 : le VOL, quatre battements d'ailes (ailes hautes, à mi-course, basses, à
  mi-course), qui bouclent ;
- colonnes 5 à 8 : la MORSURE, la gueule s'ouvre de plus en plus grand, et à la colonne 8 une
  petite langue de feu sort d'entre ses crocs, pas plus longue que sa tête.

LE DRAGON — le même dragon ancien, ÉCAILLES ROUGE SANG (#b3121b) et NOIRES (#1a0608), grandes ailes
de chauve-souris à membrane noire et nervures rouges, cornes claires (#e8d8c0) recourbées vers
l'arrière, griffes claires. Ce qui change, il est COUVERT DE FEU :
- une CRÊTE DE FLAMMES court tout le long de son échine, de la nuque au bout de la queue ;
- le bout de sa queue est une TORCHE de flammes ;
- le bord arrière de ses ailes BRÛLE : une frange de petites flammes le long de la membrane ;
- des FISSURES DE BRAISE orangées (#ff7a1a) luisent entre les écailles de son ventre et de son cou ;
- ses YEUX sont JAUNE BRÛLANT (#ffd23f) ;
- un COLLIER DE RUNES VIOLETTES (#c77dff) gravé autour de son cou dit qu'il est invoqué.
LES FLAMMES sont des FORMES NETTES de dessin animé : des langues pointues en trois couches, rouge
au bord, ORANGE (#ff7a1a) au milieu, JAUNE (#ffd23f) au cœur, cernées d'un contour rouge sombre
(#4a0a06). Elles ondulent un peu différemment à chaque image.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, ni dans les flammes, ni en reflet, ni en lueur : le fond
vert serait retiré avec. Les flammes restent rouges, orangées et jaunes, sans jaune-vert.

⚠️ RÈGLE BLOQUANTE — LES FLAMMES RESTENT COLLÉES AU CORPS : elles ne dépassent pas d'un quart de
tête autour de lui. Aucune flamme détachée, aucune étincelle qui flotte, aucune fumée, aucun halo
flou : le détourage les couperait.

⚠️ RÈGLE BLOQUANTE — AUCUN SOUFFLE DE FEU. Seule la petite langue de feu de la colonne 8 sort de
sa gueule. Le JEU dessine lui-même son souffle et ses colonnes de feu.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE QUE L'IMAGE JOINTE ET D'UNE CASE À L'AUTRE : son corps a les
mêmes dimensions dans les 32 cases. Dans une même rangée, le corps se superpose d'une case à
l'autre ; seuls les ailes, la gueule, la queue et les flammes bougent.

⚠️ RÈGLE BLOQUANTE — CHAQUE RANGÉE GARDE SA DIRECTION : la rangée 3 regarde toujours VERS LA
GAUCHE, la rangée 4 toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE. Le jeu dessine son ombre au sol.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le fond rouge nuageux est resté | Rien ne pourrait le détourer |
| Des flammes détachées ou des étincelles autour | Le détourage les couperait en morceaux |
| Il crache un long souffle | Le jeu dessine déjà le souffle : il serait en double |
| Il est plus petit ou plus grand que l'ancien | C'est le jeu qui le grandit pendant l'Éveil |
| Les flammes tournent au jaune-vert | Elles partiraient avec le fond |

Seul le Roi-Dragon l'appelle : hors Éveil, l'Invocateur garde son dragon d'origine. ⚠️ Plus grand, il couvrait le
mage : sa taille est `summon_scale` 1,15, et la Légion y ajoute ×1,3.

---

## Les effets visuels, sort par sort

Ils seront peints au shader, comme ceux des autres Éveils. Mêmes règles : trois temps (départ, coup, trace
qui s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette du Maître

| rôle | couleur | usage |
|---|---|---|
| Le violet sombre | `#2e1450` | les portails, le fond des cercles |
| Le violet vif | `#c77dff` | les runes, les chaînes de lumière, les sceaux |
| L'or | `#d4a640` | le liseré des cercles, les éclats de commandement |
| Le blanc os | `#efe6d6` | l'instant du coup |
| Le feu | `#ff7a1a` / `#ffd23f` | le dragon et l'explosion des diablotins |
| Le cerne | `#0a0512` | contour |

Le motif commun est **le sceau de runes** : un cercle violet vif, liseré d'or, gravé de runes.

### L'Éveil lui-même

- **La charge, 0,8 s :** des runes montent du sol en spirale autour de lui, et son grimoire s'ouvre.
- **L'éclosion :** un grand sceau de runes s'imprime au sol sous lui, des chaînes de lumière jaillissent vers
  chacune de ses créatures, qui grandissent d'un coup dans un éclat violet ; puis une onde dorée part au sol.
- **Pendant la minute :** une chaîne de lumière le relie à chaque créature, et l'aura de runes tourne sous elles.
- **La fin :** les chaînes se brisent en éclats, les créatures retrouvent leur taille, et il redevient l'Invocateur.

### Les six sorts

- **Marque du grimoire :** une aiguille de runes ; sur la cible, un sceau tourne au-dessus de sa tête, et des
  traits violets partent de chaque créature vers elle.
- **Nuée infernale :** un portail de runes s'ouvre et crache les diablotins ; chacun meurt dans une gerbe de
  flammes violettes.
- **Gargouille colossale :** un sceau marque le sol, la gargouille tombe du ciel, et l'onde de choc soulève des
  éclats de pierre.
- **Porte des abysses :** un cercle de runes s'ouvre sur un gouffre violet ; des griffes s'y agitent, et un
  diablotin en sort toutes les deux secondes.
- **Échange :** deux colonnes de runes, une sous lui et une sous la créature, puis un éclair qui les relie.
- **La boule de feu du dragon embrasé** (2026-11-08, le joueur la trouvait « pas redoutable ») : sa gueule se
  charge de flammes qui convergent (`legion_gueule`), la boule part avec une crinière de sept langues de flamme
  (`brasier_roi`), puis explose en couronne avec une onde de feu (`legion_brasier`) et laisse une brûlure au sol
  (`legion_brulure`). Elle blesse aussi les voisins de sa cible (`CombatSystem.ROYAL_FIREBALL_RADIUS`, 1,3 case).
  `tools/preview_legion.gd` les montre (planche 3).
- **Roi-Dragon :** l'écran s'assombrit, un sceau géant s'ouvre dans le ciel, l'ombre immense du dragon passe en
  crachant une ligne de feu sur tout l'écran, puis il se pose dans une gerbe de flammes.
