# L'Éveil du Mage de l'Air — le Souverain des Vents

> Le cinquième ÉVEIL des mages. Le Mage de l'Air est celui qui gagne les combats qu'il refuse de livrer : il
> repousse, il ralentit, il se protège. Éveillé, il devient **le Souverain des Vents** pendant une minute :
> plus rien ne l'approche, il aspire et projette les ennemis, et il s'envole par-dessus les haies. Le
> Phénix renaît, le Seigneur des Marées encaisse, le Colosse écrase, l'Avatar foudroie ; lui tient tout à
> distance.

**Jouable depuis le 2026-11-07** (`CharacterCatalog.air_awakened`). Les quatre images ci-dessous ont été
commandées dans cet ordre, la première servant de modèle aux trois autres ; elles sont découpées dans
`assets/characters/air_eveil` et `assets/icons/air_eveil`.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Souverain | ci-dessous, image 1 | `refonte/air_eveil.png` | `refonte/air.png` et `refonte/chrono.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/air_eveil_marche.png` | `refonte/air_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/air_eveil_attaque.png` | `refonte/air_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_air_eveil_skills.png` | aucune |

Aucun portrait à commander : la carte de l'écran de sélection reste celle du Mage de l'Air. Aucune image pour
les effets des sorts : ils seront peints au shader.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## Le Souverain des Vents

### Ce qu'il devient

On reconnaît le Mage de l'Air : sa capuche souple, son visage d'enfant aux yeux bleus, sa robe **blanche et
bleu pâle** à liserés d'or, son bâton fin à **anneau ouvert**. Mais le vent l'habite. Ses **écharpes** sont
devenues de longs **rubans de vent** bleu ciel qui ondulent derrière lui, et le bas de sa robe s'effile en
**volutes de vent**. Un **anneau de vent** flotte derrière sa tête, comme une couronne, le même que celui de
son bâton. Ses **yeux** brillent d'un bleu ciel lumineux. Ses **bracelets** et le bord de sa capuche sont en
**argent et or**. L'anneau de son bâton a grandi, et une petite **spirale de vent** tourne au milieu.

Il reste chibi, à la même échelle que le Mage de l'Air.

### Son trait éveillé : Rempart de vent

**Plus rien ne le touche de près.** Un ennemi qui arrive à côté de lui est **repoussé de 2 cases** par une
bourrasque et **ralenti 1 s**, une fois toutes les **2 s** au plus pour un même ennemi. La bourrasque ne
blesse pas : elle éloigne. Les boss ne sont pas repoussés.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Lame de vent | **Croissant d'ouragan** | un grand croissant de vent qui traverse le couloir et repousse d'une case tout ce qu'il touche | 15 dégâts, 12 cases, 0,42 s |
| SKILL 1 | Tornade | **Grand vortex** | une tornade géante remonte le couloir, aspire les ennemis à 3 cases autour d'elle et les emporte | 14/s, 5 s, aspire à 3 cases, recharge 10 s |
| SKILL 2 | Grand souffle | **Souffle du titan** | une onde de vent part en cercle, projette tout de 6 cases et étourdit ce qui heurte un mur | 30 dégâts, rayon 4, projette de 6 cases, 25 au choc et 1 s d'étourdissement, recharge 7 s |
| SKILL 3 | Voile d'air | **Cocon de vent** | une sphère de vent l'enveloppe : intouchable, et ce qui le touche est rejeté | 4 s, rejette de 3 cases, recharge 14 s |
| FUITE | Rafale | **Vol du zéphyr** | il s'envole, file par-dessus les haies, et retombe dans une bourrasque | 3 s de vol, 25 dégâts et repousse en retombant, recharge 10 s |
| EXTRA | Cyclone | **Ouragan** | six colonnes de vent chassent au lieu de trois, et l'œil de l'ouragan reste sur lui : tout ce qui approche est aspiré puis rejeté | le Cyclone de base ×2, et 10 s d'œil de l'ouragan à 12/s |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

---

## Image 1 — le modèle du Souverain

Joindre `assets/peso&cover/refonte/air.png` en PREMIER (le Mage de l'Air, qu'il faut garder reconnaissable),
puis `assets/peso&cover/refonte/chrono.png` (les proportions et la mise en page).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
La PREMIÈRE image jointe montre le Mage de l'Air : c'est LE MÊME personnage, que tu dois
transformer, pas remplacer. La DEUXIÈME image jointe sert UNIQUEMENT de référence de
proportions et de mise en page : ne copie ni son personnage, ni ses couleurs, ni ses objets.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : son visage et ses yeux se voient bien
2. vue DE DOS, immobile : l'anneau de vent derrière sa tête et ses rubans se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile

LE PERSONNAGE — le Mage de l'Air ÉVEILLÉ en SOUVERAIN DES VENTS. On le reconnaît tout de suite :
même petit mage au corps compact, même CAPUCHE SOUPLE, même visage aux yeux bleus, même robe
BLANCHE (#f6f8fb) et BLEU PÂLE (#bfe3f5) à liserés d'or, même BÂTON FIN à ANNEAU OUVERT dans la
main droite. Ce qui change :
- ses écharpes sont devenues deux longs RUBANS DE VENT bleu ciel (#7fd3ff), qui ondulent
  derrière lui en S, sans dépasser de la case ;
- le bas de sa robe s'effile en trois ou quatre VOLUTES DE VENT, enroulées comme des vagues ;
- un ANNEAU DE VENT bleu ciel flotte DERRIÈRE SA TÊTE, comme une couronne posée à plat, ouvert
  comme celui du bâton, avec deux petites boucles de vent ;
- ses YEUX brillent d'un BLEU CIEL lumineux ;
- le bord de sa capuche et ses bracelets sont en ARGENT (#dfe7ee) et OR (#e0b040) ;
- l'anneau de son bâton a GRANDI, et une petite SPIRALE DE VENT bleu ciel tourne au milieu.
Toutes ses formes sont cernées d'un contour bleu-gris très sombre (#1b2a3a), net, qui les
détache des sols clairs.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DU MAGE DE L'AIR : UN CORPS CHIBI COMPACT, À LA MÊME
TAILLE. Posé à côté de la première image jointe, il fait la même hauteur : l'anneau derrière sa
tête ne le grandit pas de plus d'un quart de tête.

⚠️ RÈGLE BLOQUANTE — IL RESTE DANS SA LARGEUR. Les rubans et les volutes ne dépassent pas de plus
d'une demi-largeur de corps de chaque côté.

⚠️ RÈGLE BLOQUANTE — LE VENT EST FAIT DE FORMES NETTES ET OPAQUES, cernées : aucune lueur floue,
aucun halo, aucune brume, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT. Les deux jambes et les deux bottes se voient
clairement sous la robe, séparées l'une de l'autre : les volutes ne descendent pas plus bas que
le bas de la robe d'avant.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni dans le vent, ni dans les
ombres du blanc, ni en reflet du fond. Le blanc s'ombre de BLEU-GRIS, jamais de mauve.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
rubans, même anneau, même bâton, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| On ne reconnaît plus le Mage de l'Air (capuche, robe blanche et bleue, bâton à anneau) | L'Éveil doit transformer le mage, pas le remplacer |
| Il est plus grand que le Mage de l'Air | Il ne doit pas changer de taille en s'éveillant |
| Les rubans partent loin du corps | Ils déborderaient des cases et passeraient sur les murs |
| Des ombres mauves dans le blanc | Le détourage y ferait des trous : c'est le piège du blanc sur fond magenta |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/air_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT sa capuche, ses rubans, son
anneau, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage de l'Air éveillé en SOUVERAIN DES VENTS, en proportions CHIBI, corps
compact : capuche souple, yeux bleu ciel lumineux, robe blanche et bleu pâle à liserés d'or
dont le bas s'effile en volutes de vent, deux RUBANS DE VENT bleu ciel qui ondulent derrière lui,
un ANNEAU DE VENT qui flotte derrière sa tête, BÂTON FIN à grand ANNEAU OUVERT dans la main droite,
tenu droit. Contour bleu-gris sombre net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale
est la même dans les 24 cases.

Il MARCHE d'un pas LÉGER, comme porté par le vent. IL NE COURT PAS : le buste reste DROIT. Ses
pas sont de la MÊME LONGUEUR que sur le guide. Ses rubans ondulent un peu différemment à chaque
image, toujours derrière lui.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps.
- LE BRAS LIBRE (le gauche, main ouverte) balance en grand, de l'avant vers l'arrière ;
- LE BRAS DU BÂTON (le droit) balance AUSSI, moins loin : la main avance et recule en emportant
  le bâton, qui reste VERTICAL, anneau en l'air, sans jamais se coucher ni passer devant le visage.

LE BALANCEMENT DES BRAS, image par image, calé sur les jambes du guide :
1. bras libre tendu vers l'AVANT, main à hauteur de taille ; main du bâton vers l'ARRIÈRE
2. bras libre qui redescend, coude un peu plié ; main du bâton qui revient
3. les deux bras le long du corps, POINT DE PASSAGE (c'est l'image aux jambes jointes)
4. bras libre qui part vers l'arrière ; main du bâton qui part vers l'avant
5. l'INVERSE de l'image 1 : bras libre vers l'ARRIÈRE, main du bâton vers l'AVANT
6. main du bâton qui revient ; bras libre qui revient
7. les deux bras le long du corps, POINT DE PASSAGE (jambes jointes)
8. bras libre qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui avance
grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté du corps.
DE PROFIL, le bâton reste devant le corps, et la main qui le tient avance et recule le long de lui.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses.

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
Deux images voisines identiques pour les bras sont une erreur. Le bâton bouge AVEC sa main,
toujours droit.

⚠️ RÈGLE BLOQUANTE — LA ROBE NE CACHE JAMAIS LES JAMBES : les deux bottes se voient dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LE BÂTON ET LES RUBANS BOUGENT. Dans une même rangée,
la tête, la capuche, l'anneau de vent et le tronc se superposent exactement d'une case à l'autre,
et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES RUBANS, L'ANNEAU ET LE BÂTON TIENNENT DANS LA CASE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — LE VENT RESTE EN FORMES NETTES, SANS HALO NI BRUME ; AUCUN ROSE, AUCUN VIOLET,
AUCUNE OMBRE MAUVE DANS LE BLANC.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule détachée, aucun reflet du
fond magenta.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/air_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT sa capuche, ses rubans, son anneau, ses couleurs et ses
proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage de l'Air éveillé en SOUVERAIN DES VENTS, en proportions CHIBI, corps
compact : capuche souple, yeux bleu ciel lumineux, robe blanche et bleu pâle en volutes de vent,
deux rubans de vent bleu ciel, anneau de vent derrière la tête, bâton fin à grand anneau ouvert
dans la main droite. Contour bleu-gris sombre net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il
FEND L'AIR d'un grand revers de son bâton, comme on lance une faux de vent.
1. posture prête, le bâton droit dans la main droite
2. il ramène le bâton contre son épaule, l'anneau près de sa tête, la main libre tendue devant
3. le bâton est armé au plus loin, le buste tourné, les rubans soulevés
4. LE COUP : il balaie le bâton d'un grand arc DEVANT lui, dans la direction de la rangée, l'anneau
   en tête, et une petite spirale de vent bleu ciel jaillit de l'anneau, plus petite que sa tête
5. la spirale a disparu, le bâton finit son arc devant lui
6. il ramène le bâton
7. le bâton revient droit contre le corps
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais l'ensemble corps et
bâton.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est la petite spirale de
l'image 4. Le JEU dessine lui-même les croissants de vent et les tornades.

⚠️ RÈGLE BLOQUANTE — LE BÂTON ET LES RUBANS RESTENT ENTIERS DANS LA CASE, même armés à l'image 3.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucune ombre mauve dans le blanc, aucun reflet
du fond magenta.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc et la tête se superposent
exactement dans les 8 images d'une rangée (seuls les bras, le bâton, les rubans et les genoux
bougent).

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

PERSONNAGE : le Mage de l'Air éveillé en SOUVERAIN DES VENTS. Ses couleurs sont le BLANC (#f6f8fb),
le BLEU PÂLE (#bfe3f5), le BLEU CIEL (#7fd3ff), l'ARGENT (#dfe7ee) et l'OR (#e0b040), avec un CONTOUR
BLEU-GRIS TRÈS SOMBRE (#1b2a3a) net autour de chaque forme. Le motif commun des six icônes est la
SPIRALE DE VENT : elle doit se retrouver dans chacune.

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

1. CROISSANT D'OURAGAN — un grand croissant de vent tranchant qui file vers la droite, une spirale
   à sa pointe, des traits de vitesse derrière lui.

2. GRAND VORTEX — une tornade géante vue de côté, large en haut et fine en bas, avec trois flèches
   courbes qui s'enroulent vers elle pour montrer qu'elle aspire.

3. SOUFFLE DU TITAN — une onde de vent en cercle autour d'un point central, avec des flèches qui
   partent vers l'extérieur dans six directions.

4. COCON DE VENT — une sphère faite de rubans de vent entrelacés, un anneau d'or à sa taille, et
   deux petites flèches qui rebondissent sur sa surface.

5. VOL DU ZÉPHYR — deux ailes de vent stylisées, ouvertes, au-dessus d'une spirale, avec une
   flèche courbe qui monte et passe par-dessus un petit mur.

6. OURAGAN — un ouragan vu de dessus, une grande spirale à plusieurs bras avec un œil calme au
   centre, et six petites colonnes de vent autour. C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de flou, aucune brume, aucune lueur floue autour du vent, aucune case vide, AUCUN ROSE et
AUCUN VIOLET, ni dans le vent, ni dans les ombres du blanc, ni dans les reflets : ils se
confondraient avec le fond magenta. Le blanc s'ombre de BLEU-GRIS. Ce sont des SYMBOLES, pas des
scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Les shaders `souverain_*` (`tools/preview_souverain.gd` les montre). Mêmes règles que les autres :
trois temps (départ, coup, trace qui s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette du Souverain

| rôle | couleur | usage |
|---|---|---|
| Le blanc | `#f6f8fb` | le cœur des rafales, l'instant du coup |
| Le bleu ciel | `#7fd3ff` | les rubans, les spirales, les tornades |
| Le bleu pâle | `#bfe3f5` | les volutes, le voile du cocon |
| L'argent | `#dfe7ee` | les traits de vitesse |
| L'or | `#e0b040` | anneaux au sol, l'œil de l'ouragan |
| Le cerne | `#1b2a3a` | contour qui tient sur les sols clairs |

Le motif commun est **la spirale de vent**, en formes nettes et cernées : jamais une brume floue. Le vent
n'est **jamais violet**, et le blanc s'ombre de bleu-gris.

### L'Éveil lui-même

- **La charge, 0,8 s :** des rubans de vent montent en spirale autour de lui en se resserrant.
- **L'éclosion :** une colonne de vent l'enveloppe et s'ouvre d'un coup, une onde de vent part au sol en
  rabattant tout, l'anneau apparaît derrière sa tête, et l'écran tremble.
- **Pendant la minute :** deux rubans tournent lentement autour de lui, et ses pas soulèvent de petites
  volutes.
- **Le Rempart de vent :** chaque ennemi repoussé part dans une bourrasque en forme de croissant.
- **La fin :** les rubans se dénouent et s'envolent vers le ciel, et il redevient le Mage de l'Air.

### Les six sorts

- **Croissant d'ouragan :** un grand croissant blanc bordé de bleu ciel qui tourne sur lui-même en filant ;
  chaque ennemi traversé est rejeté d'une case dans un souffle.
- **Grand vortex :** une tornade géante, large en haut, qui remonte le couloir ; des traits de vent
  s'enroulent vers elle, et les ennemis aspirés tournent à son pied.
- **Souffle du titan :** une onde de vent part en cercle en couchant tout, avec des traits de vitesse vers
  l'extérieur ; ce qui heurte un mur s'écrase dans une étoile blanche.
- **Cocon de vent :** une sphère de rubans entrelacés tourne autour de lui ; ce qui la touche rebondit
  dans un éclat.
- **Vol du zéphyr :** deux ailes de vent s'ouvrent dans son dos, il monte et file par-dessus les haies,
  puis retombe dans une onde qui rabat tout.
- **Ouragan :** une immense spirale à plusieurs bras se dessine au sol autour de lui, l'œil calme au
  centre cerclé d'or ; six colonnes de vent en partent pour chasser.
