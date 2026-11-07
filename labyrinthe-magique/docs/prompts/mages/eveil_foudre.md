# L'Éveil du Mage de la Foudre — l'Avatar de la Tempête

> Le quatrième ÉVEIL des mages. Le Mage de la Foudre, le plus rapide du jeu, se change à moitié en foudre
> et devient **l'Avatar de la Tempête** pendant une minute : il court encore plus vite, chaque coup le charge,
> et ses six sorts changent. Le Phénix renaît, le Seigneur des Marées encaisse, le Colosse écrase ; lui
> foudroie.

**Jouable depuis le 2026-11-07** (`CharacterCatalog.thunder_awakened`). Les quatre images ci-dessous ont été
commandées dans cet ordre, la première servant de modèle aux trois autres ; elles sont découpées dans
`assets/characters/thunder_eveil` et `assets/icons/thunder_eveil`.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle de l'Avatar | ci-dessous, image 1 | `refonte/foudre_eveil.png` | `refonte/foudre.png` et `refonte/chrono.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/foudre_eveil_marche.png` | `refonte/foudre_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/foudre_eveil_attaque.png` | `refonte/foudre_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_foudre_eveil_skills.png` | aucune |

Aucun portrait à commander : la carte de l'écran de sélection reste celle du Mage de la Foudre. Aucune image
pour les effets des sorts : ils seront peints au shader.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## L'Avatar de la Tempête

### Ce qu'il devient

On reconnaît le Mage de la Foudre : son visage de jeune homme, ses cheveux blancs en pointes, sa tunique
**jaune et bleu nuit**, sa ceinture, ses bottes légères et son bâton court. Mais la foudre le traverse. Ses
**cheveux** se dressent encore plus haut et leurs pointes deviennent des **éclairs blancs et bleus**. Ses
**yeux** sont blancs et lumineux, sans pupille. Le bas de sa tunique se **déchire en zigzags d'éclair**. Des
**arcs électriques** bleu-blanc courent sur ses avant-bras, comme des veines. Deux **bracelets d'or** à ses
poignets retiennent la foudre. L'éclat au sommet de son bâton est devenu une **pointe de foudre** taillée, jaune
au cœur et bleue au bord.

Il reste chibi, à la même échelle que le Mage de la Foudre.

### Son trait éveillé : Surtension

Il court **20 % plus vite**. Chaque coup qui touche un ennemi lui donne **une charge**, jusqu'à **5**. À 5
charges, sa prochaine attaque appelle **la foudre du ciel** sur sa cible : **40 dégâts** sur elle et ses
voisins, à **1,5 case** autour. Les charges retombent à zéro.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Éclair | **Lance de foudre** | un trait qui traverse le couloir et touche tout ce qu'il croise | 14 dégâts, 8 cases, 0,35 s |
| SKILL 1 | Chaîne d'éclairs | **Tempête en chaîne** | l'arc saute sur six ennemis sans faiblir, et paralyse chacun un instant | 30 dégâts, 6 sauts, paralysie 0,6 s, recharge 2 s |
| SKILL 2 | Champ de foudre | **Cage électrique** | un dôme de foudre autour de lui, qui le suit, paralyse et brûle ce qui entre | rayon 2, 8 s, 12/s, paralysie 1 s, recharge 11 s |
| SKILL 3 | Orage | **Œil du cyclone** | trois nuages tournent autour de lui et foudroient tout seuls | 18 dégâts par éclair, un par nuage et par seconde, 20 s, recharge 25 s |
| FUITE | Éclair fuyant | **Saut d'éclair** | il se change en foudre, rebondit sur trois ennemis proches en les frappant, puis réapparaît | 30 dégâts par ennemi, 5 cases, recharge 6 s |
| EXTRA | Jugement céleste | **Colère du ciel** | le ciel devient noir, puis un éclair géant tombe sur chaque ennemi de l'écran, un par un | le Jugement de base, plus 80 dégâts par ennemi |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

---

## Image 1 — le modèle de l'Avatar

Joindre `assets/peso&cover/refonte/foudre.png` en PREMIER (le Mage de la Foudre, qu'il faut garder
reconnaissable), puis `assets/peso&cover/refonte/chrono.png` (les proportions et la mise en page).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
La PREMIÈRE image jointe montre le Mage de la Foudre : c'est LE MÊME personnage, que tu dois
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
2. vue DE DOS, immobile : ses cheveux et le bas déchiré de sa tunique se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile

LE PERSONNAGE — le Mage de la Foudre ÉVEILLÉ en AVATAR DE LA TEMPÊTE. On le reconnaît tout de
suite : même jeune mage au corps compact, même visage, mêmes CHEVEUX BLANCS EN POINTES, même
tunique JAUNE (#f2c230) et BLEU NUIT (#1b2440), même ceinture, mêmes bottes légères, même BÂTON
COURT dans la main droite. Ce qui change :
- ses cheveux se dressent plus haut, et le bout de chaque pointe devient un petit ÉCLAIR
  BLANC (#f4fbff) bordé de BLEU ÉLECTRIQUE (#3fa9ff) ;
- ses YEUX sont BLANCS et lumineux, sans pupille ;
- le bas de sa tunique se DÉCHIRE en ZIGZAGS D'ÉCLAIR, jaunes bordés de bleu nuit ;
- des ARCS ÉLECTRIQUES bleu-blanc courent sur ses avant-bras, comme des veines, en traits fins ;
- deux BRACELETS D'OR (#e0b040) à ses poignets ;
- l'éclat au sommet de son bâton est devenu une POINTE DE FOUDRE taillée, jaune au cœur et
  bleu électrique au bord.
Toutes ses formes sont cernées d'un contour bleu nuit très sombre (#0b1022), net, qui les
détache des sols clairs.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DU MAGE DE LA FOUDRE : UN CORPS CHIBI COMPACT, À LA
MÊME TAILLE. Posé à côté de la première image jointe, il fait la même hauteur : les cheveux
dressés ne le grandissent pas de plus d'un quart de tête.

⚠️ RÈGLE BLOQUANTE — LA FOUDRE EST FAITE DE TRAITS NETS ET OPAQUES, collés au corps : aucune lueur
floue, aucun halo, aucun nuage d'étincelles, aucun éclair qui part loin du corps.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT. Les deux jambes et les deux bottes se voient
clairement, séparées l'une de l'autre : la tunique déchirée ne descend pas plus bas qu'avant.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni dans la foudre, ni dans les
ombres, ni en reflet du fond. La foudre est BLANCHE, BLEUE et JAUNE, jamais violette.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
cheveux, même bâton, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| On ne reconnaît plus le Mage de la Foudre (cheveux, tunique jaune et bleue, bâton) | L'Éveil doit transformer le mage, pas le remplacer |
| Il est plus grand que le Mage de la Foudre | Il ne doit pas changer de taille en s'éveillant |
| La foudre luit en halo flou ou part loin du corps | Une frange resterait au détourage, et les éclairs déborderaient des cases |
| Du violet dans la foudre | Le détourage y ferait des trous |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/foudre_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT ses cheveux, sa foudre, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage de la Foudre éveillé en AVATAR DE LA TEMPÊTE, en proportions CHIBI, corps
compact : cheveux blancs dressés aux pointes d'éclair blanc et bleu, yeux blancs lumineux,
tunique jaune et bleu nuit déchirée en zigzags d'éclair, arcs électriques bleu-blanc sur les
avant-bras, bracelets d'or, BÂTON COURT surmonté d'une POINTE DE FOUDRE dans la main droite,
tenu droit. Contour bleu nuit net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale
est la même dans les 24 cases.

Il MARCHE d'un pas VIF et léger, prêt à bondir. IL NE COURT PAS : le buste reste DROIT, à peine
penché en avant. Ses pas sont de la MÊME LONGUEUR que sur le guide.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps.
- LE BRAS LIBRE (le gauche, main ouverte crépitante) balance en grand, de l'avant vers l'arrière ;
- LE BRAS DU BÂTON (le droit) balance AUSSI, moins loin : la main avance et recule en emportant
  le bâton, qui reste VERTICAL, pointe de foudre en l'air, sans jamais se coucher ni passer
  devant le visage.

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

⚠️ RÈGLE BLOQUANTE — LA TUNIQUE NE CACHE JAMAIS LES JAMBES : les deux bottes se voient dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS ET LE BÂTON BOUGENT. Dans une même rangée, la tête,
les cheveux et le tronc se superposent exactement d'une case à l'autre, et le profil regarde
toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES CHEVEUX ET LE BÂTON TIENNENT DANS LA CASE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — LA FOUDRE RESTE EN TRAITS FINS ET NETS COLLÉS AU CORPS, SANS HALO ; AUCUN ROSE,
AUCUN VIOLET.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune étincelle détachée, aucun reflet du
fond magenta.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/foudre_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT ses cheveux, sa foudre, ses couleurs et ses proportions, mais PAS
sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage de la Foudre éveillé en AVATAR DE LA TEMPÊTE, en proportions CHIBI, corps
compact : cheveux blancs dressés aux pointes d'éclair, yeux blancs lumineux, tunique jaune et bleu
nuit déchirée en zigzags, arcs électriques sur les avant-bras, bracelets d'or, bâton court à
pointe de foudre dans la main droite. Contour bleu nuit net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il
PROJETTE LA FOUDRE d'un coup de bâton, comme on lance une lance.
1. posture prête, le bâton droit dans la main droite
2. il ramène le bâton en arrière à l'horizontale, la main libre tendue vers l'avant pour viser
3. le bâton est au plus loin derrière lui, le corps tendu comme un arc
4. LE COUP : il pousse le bâton droit DEVANT lui dans la direction de la rangée, bras tendu, et
   un petit éclat de foudre blanc et bleu jaillit de la pointe, plus petit que sa tête
5. l'éclat a disparu, le bâton reste tendu
6. il ramène le bâton
7. le bâton revient droit contre le corps
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais l'ensemble corps et
bâton.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit éclat de l'image 4.
Le JEU dessine lui-même les éclairs et la foudre qui tombe du ciel.

⚠️ RÈGLE BLOQUANTE — LE BÂTON RESTE ENTIER DANS LA CASE, même ramené en arrière à l'image 3.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta ; la foudre reste
en traits fins et nets.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune étincelle détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc et la tête se superposent
exactement dans les 8 images d'une rangée (seuls les bras, le bâton et les genoux bougent).

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

PERSONNAGE : le Mage de la Foudre éveillé en AVATAR DE LA TEMPÊTE. Ses couleurs sont le BLANC
ÉLECTRIQUE (#f4fbff), le BLEU ÉLECTRIQUE (#3fa9ff), le JAUNE (#f2c230), l'OR (#e0b040) et le BLEU NUIT
(#1b2440), avec un CONTOUR BLEU NUIT TRÈS SOMBRE (#0b1022) net autour de chaque forme. Le motif commun
des six icônes est l'ÉCLAIR EN ZIGZAG : il doit se retrouver dans chacune.

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

1. LANCE DE FOUDRE — une lance faite d'un seul éclair droit, pointe en avant vers la droite,
   traversant trois petits cercles alignés, avec des traits de vitesse derrière elle.

2. TEMPÊTE EN CHAÎNE — un éclair en zigzag qui relie six points lumineux disposés en arc de
   cercle, chacun entouré d'une petite étoile de paralysie.

3. CAGE ÉLECTRIQUE — un dôme fait de barreaux d'éclairs entrecroisés, posé sur un anneau jaune au
   sol, avec un éclair plus vif au sommet.

4. ŒIL DU CYCLONE — trois petits nuages bleu nuit en rond autour d'un cercle jaune, chacun lâchant
   un éclair vers l'extérieur.

5. SAUT D'ÉCLAIR — un éclair qui rebondit trois fois en zigzag entre trois petites étoiles d'impact,
   et se termine par une flèche.

6. COLÈRE DU CIEL — un nuage noir massif d'où tombent trois éclairs géants, avec un grand éclat
   blanc en étoile là où le plus gros touche le sol. C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de flou, aucune lueur floue autour des éclairs, aucune case vide, AUCUN ROSE et AUCUN VIOLET,
ni dans les éclairs, ni dans les ombres, ni dans les reflets : ils se confondraient avec le fond
magenta. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Les shaders `tempete_*` (`tools/preview_tempete.gd` les montre). Mêmes règles que les autres :
trois temps (départ, coup, trace qui s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette de l'Avatar

| rôle | couleur | usage |
|---|---|---|
| Le cœur de la foudre | `#f4fbff` | le trait de chaque éclair, l'instant de l'impact |
| Le bleu électrique | `#3fa9ff` | le bord des éclairs, les arcs, la cage |
| Le jaune | `#f2c230` | ses éclairs à lui, la Surtension, les charges |
| L'or | `#e0b040` | bracelets, anneaux au sol |
| Le bleu nuit | `#1b2440` | les nuages, le ciel noir de la Colère |
| Le cerne | `#0b1022` | contour qui tient sur les sols clairs |

Le motif commun est **l'éclair en zigzag**, net et opaque : jamais un halo flou. La foudre n'est **jamais
violette**.

### L'Éveil lui-même

- **La charge, 0,8 s :** des éclairs montent du sol et s'enroulent autour de lui, de plus en plus serrés.
- **L'éclosion :** la foudre tombe du ciel sur lui dans un grand flash blanc, une onde électrique part au sol,
  et l'écran tremble.
- **Pendant la minute :** des arcs courent sur lui, et il laisse derrière lui une trace d'étincelles.
- **Les charges de Surtension :** de petites étoiles jaunes tournent au-dessus de sa tête, une par charge.
- **La fin :** la foudre le quitte en un dernier éclair vers le ciel, et il redevient le Mage de la Foudre.

### Les six sorts

- **Lance de foudre :** un trait droit, blanc au cœur et bleu au bord, qui file le long du couloir ; chaque
  ennemi traversé s'allume d'un éclat.
- **Surtension (la 5e charge) :** un éclair épais tombe du ciel sur la cible, avec un cercle d'or au sol.
- **Tempête en chaîne :** des arcs en zigzag sautent d'ennemi en ennemi, et chacun garde une petite étoile de
  paralysie au-dessus de la tête.
- **Cage électrique :** un dôme de barreaux d'éclairs qui crépite autour de lui et le suit ; ce qui entre est
  traversé d'un arc.
- **Œil du cyclone :** trois nuages bleu nuit tournent autour de lui et lâchent chacun leur éclair.
- **Saut d'éclair :** il devient un trait de foudre qui rebondit de cible en cible, puis réapparaît dans un
  éclat blanc.
- **Colère du ciel :** l'écran s'assombrit d'un coup, puis des éclairs géants tombent un par un sur chaque
  ennemi, chacun avec son flash et sa secousse.
