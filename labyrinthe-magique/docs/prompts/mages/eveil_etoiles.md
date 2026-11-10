# L'Éveil de l'Ange des Étoiles — la Reine du Firmament

> Le troisième ÉVEIL des anges. L'Ange des Étoiles pose des étoiles dans le labyrinthe, et ce sont les rayons qui les
> relient qui brûlent. Éveillée, elle devient **la Reine du Firmament** pendant une minute : ses constellations sont
> plus grandes, se ferment en figures qui brûlent tout ce qu'elles enferment, et la carte devient son ciel.

**Jouable depuis le 2026-11-10** (`CharacterCatalog.etoiles_awakened`). Les cinq images sont découpées dans
`assets/characters/etoiles_eveil` (avec `keep_cast` : sans lui, le bord des ailes tournait au rouge brun),
`assets/icons/etoiles_eveil` et le portrait de la sélection. ⚠️ Le portrait est revenu sur fond MAGENTA au lieu de la
nappe demandée : `tools/build_menu.py` le détoure et repeint la nappe bleu nuit étoilée (`NAPPES`). Ses effets sont
peints au shader (`firmament_*`, palette et étoile dans `firmament.gdshaderinc` ; le préfixe `reine_` est celui de la
Reine de la Discorde) ; `tools/preview_firmament.gd` les montre hors partie. Les chiffres sont des points de départ,
jamais mesurés. Elle reste **sous l'Archimage Primordial**.

⚠️ **FOND MAGENTA POUR TOUTES SES IMAGES, ET JAMAIS DE ROSE NI DE VIOLET SUR ELLE.** Ses planches d'origine sont
passées par le magenta (`demagenta`) sans perdre son bleu ; un fond vert obligerait à retirer un reflet vert, et le
`despill` fait virer son bleu au beige. Son bleu reste un **bleu nuit franc**, sa nuit est **bleue**, jamais violette,
et son or est un **or pâle**, jamais rosé. Vérifier la première image avant de commander les autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle de la Reine | ci-dessous, image 1 | `refonte/etoiles_eveil.png` | `refonte/etoiles.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/etoiles_eveil_marche.png` | `refonte/etoiles_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/etoiles_eveil_attaque.png` | `refonte/etoiles_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_etoiles_eveil_skills.png` | aucune |
| 5 | Le portrait de la sélection | [menu/portrait_etoiles_eveil](../menu/portrait_etoiles_eveil.md) | `interface/portraits/portrait_etoiles_eveil.png` | `interface/portraits/portrait_etoiles.png` et `mages/etoiles_eveil_marche.png` |

Le portrait se commande en dernier : il a besoin de la planche de marche. Aucune image pour les effets des sorts.
**Le petit astre qui tourne autour d'elle, les étoiles posées, les rayons, les figures, les météores et la galaxie
sont faits par le JEU** : ils ne sont jamais dessinés sur ses planches.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## La Reine du Firmament

### Ce qu'elle devient

On reconnaît l'Ange des Étoiles : une **femme adulte au visage calme**, sa **longue tresse argentée**, sa **longue
robe bleu nuit** à liserés d'argent fendue sur le côté, ses **bottines argentées**, ses deux **ailes bleu nuit semées
de points blancs** à demi repliées, et son **sceptre d'argent** à l'étoile blanche dans la main droite. Mais elle est
devenue la reine de la nuit :

- Sa couronne en croissant de lune est devenue une **COURONNE D'ÉTOILES** : le croissant d'argent est posé sur ses
  cheveux, et **cinq petites étoiles d'or pâle** s'y dressent comme des pointes. Elle touche sa tête, elle ne flotte
  plus.
- Une **longue cape de nuit** bleu nuit très foncé tombe de ses épaules jusqu'aux chevilles, semée d'étoiles blanches
  et de petites **constellations dessinées** (des points reliés par de fins traits d'argent), doublée d'argent.
- Ses **ailes** sont un peu plus grandes, toujours à demi repliées : leurs plumes sont semées de plus d'étoiles, et
  le bord de chaque plume est un liseré d'argent.
- Son sceptre porte une **étoile plus grande** à quatre branches, blanche à cœur d'or pâle, entourée d'un fin anneau
  d'argent.
- Ses yeux brillent d'un **bleu stellaire clair**.

Elle reste chibi, à la même échelle que l'Ange des Étoiles. Elle porte de l'or pâle en touches seulement (couronne,
cœur de l'étoile) : le bleu nuit et l'argent restent ses couleurs.

### Son trait éveillé : le Firmament

**Plus d'étoiles, et des rayons plus brûlants.** Tant que dure l'Éveil :
- elle peut poser jusqu'à **5 étoiles** au lieu de 3 (`STAR_MAX`) ;
- ses rayons brûlent **50 % plus fort**.

Une sixième étoile remplace toujours la plus ancienne. À la fin de l'Éveil, seules ses trois dernières étoiles
restent.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillée | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Éclat stellaire | **Trait de comète** | au troisième coup sur une cible, en plus de l'explosion, une petite étoile éphémère apparaît sur sa case et se relie à la constellation ; deux au plus, elles ne prennent pas la place des étoiles posées | 14 dégâts, 8 cases, recharge 0,45 s, étoile éphémère 4 s |
| SKILL 1 | Constellation | **Grande Constellation** | pose une étoile à ses pieds ; quand les **5** sont posées, la figure se FERME : tout ce qui est à l'intérieur brûle aussi, pas seulement ce qui croise un rayon | rayons 42 /s (28 + 50 %), intérieur 20 /s, étoiles 16 s, recharge 2,5 s |
| SKILL 2 | Pluie d'étoiles | **Pluie de météores** | 14 chutes sur une zone plus large, sur les ennemis d'abord ; la dernière est un gros météore qui tombe sur l'ennemi le plus solide à portée | 14 chutes à 26, rayon 4,5 ; gros météore 90 sur un rayon 2 ; recharge 11 s |
| SKILL 3 | Voile de lune | **Éclipse** | les coups la traversent ; à la fin, un anneau de lune s'élargit autour d'elle, blesse et ralentit ce qu'il touche | immunité 3 s, anneau rayon 4, 20 dégâts, ralentit de 50 % pendant 3 s, recharge 14 s |
| FUITE | Étoile filante | **Comète** | un saut plus long à la traînée plus brûlante ; une étoile se pose gratuitement là où elle arrive | 7 cases, traînée 40, recharge 7 s |
| EXTRA | Nuit éternelle | **Naissance d'une galaxie** | la nuit tombe, une comète frappe chaque ennemi de la carte ; chaque point d'impact devient une étoile pendant 6 s, reliée aux impacts voisins : une constellation géante sur toute la carte | 150 par comète ; étoiles d'impact 6 s, rayons 30 /s, reliées jusqu'à 8 cases |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

Le cœur de son jeu reste **le placement** : poser ses cinq étoiles autour d'un couloir ou d'un carrefour, puis y
attirer les ennemis. La figure fermée transforme un piège en zone, et la Comète lui pose une étoile en fuyant.

---

## Image 1 — le modèle de la Reine

Joindre `assets/peso&cover/refonte/etoiles.png` (l'Ange des Étoiles, qu'il faut garder reconnaissable).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre l'Ange des Étoiles : c'est LE MÊME personnage, que tu dois
transformer, pas remplacer. Ne reprends PAS la mise en page de l'image jointe.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le visage, la couronne d'étoiles et le sceptre se voient bien
2. vue DE DOS, immobile : la cape constellée, la tresse et les deux ailes se voient en entier
3. vue DE PROFIL, TOURNÉE VERS LA DROITE, immobile : le sceptre tenu droit, une aile derrière son dos

LE PERSONNAGE — l'Ange des Étoiles ÉVEILLÉE en REINE DU FIRMAMENT. On la reconnaît tout de suite :
même femme adulte au corps CHIBI et au visage calme bien visible, même longue TRESSE ARGENTÉE,
même longue ROBE BLEU NUIT (#141d4a) à liserés d'argent fendue sur le côté, mêmes BOTTINES
ARGENTÉES, mêmes deux AILES de plumes bleu nuit semées de points blancs, À DEMI REPLIÉES, même
SCEPTRE d'argent dans la main DROITE. Ce qui change :
- sa couronne en croissant est devenue une COURONNE D'ÉTOILES : le croissant d'argent est POSÉ sur
  ses cheveux, et CINQ petites étoiles d'OR PÂLE (#ffe2a0) s'y dressent comme des pointes ;
- une longue CAPE DE NUIT bleu nuit très foncé (#0c1236) tombe de ses épaules jusqu'aux chevilles,
  doublée d'argent, semée d'étoiles blanches et de petites CONSTELLATIONS dessinées : des points
  blancs reliés par de fins traits d'argent ;
- ses ailes sont un peu plus grandes, semées de plus d'étoiles, et chaque plume a un liseré d'argent ;
- son sceptre porte une ÉTOILE PLUS GRANDE à quatre branches, BLANCHE à cœur d'OR PÂLE, entourée
  d'un fin anneau d'argent ;
- ses yeux brillent d'un BLEU STELLAIRE clair (#9db8ff).
Toutes ses formes sont cernées d'un contour très foncé (#070a1c), net, doublé d'un fin liseré
d'argent sur les formes sombres.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA SUR ELLE, ni dans les reflets, ni dans
les ombres, ni dans la nuit de sa cape : le fond serait retiré avec. Sa nuit est BLEUE, ses
ombres sont BLEU NUIT et GRISES, son or est un or PÂLE qui tire sur le jaune, jamais sur le rose.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES, jamais déployées. Elles ne dépassent pas
de plus d'un quart de la largeur du corps de chaque côté, et leurs pointes s'arrêtent au niveau
des genoux. Elle devra marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — LA COURONNE EST POSÉE SUR SA TÊTE, jamais détachée et flottante : on ne voit
aucun espace magenta entre ses cheveux et la couronne, et ses cinq étoiles sont attachées au
croissant.

⚠️ RÈGLE BLOQUANTE — SES PIEDS SE VOIENT. La robe et la cape s'arrêtent au-dessus des chevilles, et
la fente laisse passer une jambe : la marche doit se lire sous le tissu.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'ANGE DES ÉTOILES : UN CORPS CHIBI DE 2,5 TÊTES,
À LA MÊME TAILLE. Posée à côté de l'image jointe, elle fait la même hauteur. Le sceptre ne dépasse
pas sa tête de plus d'une demi-tête. Elle reste une femme adulte, habillée sobrement.

⚠️ RÈGLE BLOQUANTE — AUCUNE ÉTOILE FLOTTANTE, AUCUN ASTRE, AUCUNE PARTICULE, AUCUNE LUEUR FLOUE
autour d'elle. Les étoiles sont DESSINÉES SUR sa cape, ses ailes, sa couronne et son sceptre,
jamais dans le vide autour. Le jeu ajoute le reste.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
ailes, même couronne, même cape, même sceptre, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Du violet ou du rose dans la cape, les ailes ou les ombres | Le détourage du magenta y ferait des trous |
| Le bleu est trop clair | Elle ressemblerait au Mage de l'Eau ou de l'Air |
| La couronne ou ses étoiles flottent au-dessus de sa tête | Le découpage les jetterait comme une poussière |
| Des étoiles ou un astre autour d'elle | Le jeu les dessine : elles seraient en double, et sa boîte enflerait |
| Des ailes déployées | Elle ne tiendrait plus dans un couloir |
| La cape cache les pieds | On ne verrait plus ses pas |
| Elle est plus grande que l'Ange des Étoiles | Elle ne doit pas changer de taille en s'éveillant |
| L'or domine le bleu | Elle ressemblerait à l'Étoile du Matin |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/etoiles_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT sa couronne, sa cape, ses ailes,
sa robe, son sceptre, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Ange des Étoiles éveillée en REINE DU FIRMAMENT, une femme adulte en proportions
CHIBI : visage calme aux yeux bleu stellaire, longue tresse argentée, COURONNE D'ÉTOILES posée sur
ses cheveux (un croissant d'argent et cinq petites étoiles d'or pâle), longue CAPE DE NUIT bleu
nuit semée d'étoiles et de constellations, longue robe bleu nuit fendue sur le côté, bottines
argentées, deux ailes bleu nuit étoilées À DEMI REPLIÉES, SCEPTRE d'argent à grande étoile
blanche tenu DROIT dans la main DROITE. Contour très foncé net, liseré d'argent.

LES RANGÉES :
- rangée 1 : DE FACE, elle avance vers le bas
- rangée 2 : DE DOS, elle s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉE VERS LA DROITE, elle avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
couronne comprise, est la même dans les 24 cases.

Elle MARCHE d'un pas calme et souverain, comme une reine dans son palais. ELLE NE COURT PAS : le
buste reste DROIT et la tête haute, sans bouger d'une image à l'autre. Ses pas sont de la MÊME
LONGUEUR que sur le guide. Le bas de la cape, la tresse et la pointe des ailes flottent un peu
différemment à chaque image.

LE SCEPTRE reste dans sa main DROITE, tenu droit, étoile en haut, dans les 24 cases : il monte et
descend un peu avec le pas, sans jamais basculer. SON BRAS GAUCHE BALANCE FRANCHEMENT, EN
OPPOSITION AUX JAMBES : quand la jambe droite part vers l'avant, le bras gauche part vers l'avant
lui aussi, puis il repart vers l'arrière. Le coude plie, la main suit avec un léger temps de
retard. Il ne reste JAMAIS figé le long du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, AVEC SON
SCEPTRE. Le VERT de la robe du guide ne doit pas passer sur elle.

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

⚠️ RÈGLE BLOQUANTE — LA ROBE ET LA CAPE NE CACHENT PAS LES PIEDS : les deux bottines se voient dans
les 24 cases.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES dans les 24 cases, jamais déployées.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LE BRAS GAUCHE, LE BAS DE LA CAPE, LA TRESSE ET LA POINTE
DES AILES BOUGENT. Dans une même rangée, la tête, la couronne et le tronc se superposent
exactement d'une case à l'autre, et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE NI VIOLET SUR ELLE, aucune étoile flottante, aucune lueur floue.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule détachée.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/etoiles_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT sa couronne, sa cape, ses ailes, sa robe, son sceptre, ses couleurs
et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Ange des Étoiles éveillée en REINE DU FIRMAMENT, une femme adulte en proportions
CHIBI : longue tresse argentée, couronne d'étoiles posée sur ses cheveux, cape de nuit bleu nuit
constellée, robe bleu nuit, deux ailes bleu nuit étoilées à demi repliées, SCEPTRE d'argent à
grande étoile blanche dans la main DROITE. Contour très foncé net, liseré d'argent.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : elle lance VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : elle lance VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : elle lance VERS LA DROITE, de profil, TOURNÉE VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : elle
pointe son sceptre et lance un trait de comète.
1. posture prête, sceptre tenu droit
2. elle lève le sceptre au-dessus de son épaule, l'étoile du sceptre s'allume
3. elle commence à abaisser le sceptre vers l'avant
4. LE TIR : le sceptre est tendu DEVANT elle, bras tendu, dans la direction de la rangée, et un
   petit ÉCLAT BLANC à cœur d'or pâle, plus petit que sa tête, brille sur l'étoile du sceptre
5. l'éclat a disparu, le sceptre est encore tendu
6. le sceptre remonte
7. le sceptre revient presque à la verticale
8. elle retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE TIR PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit éclat de l'image
4, collé à l'étoile du sceptre. Pas de comète lancée, pas de traînée, pas d'étoiles autour : le
JEU les dessine.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES pendant tout le geste.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE NI VIOLET SUR ELLE, ni en reflet du fond.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune aura, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc, la tête et la couronne
se superposent exactement dans les 8 images d'une rangée (seuls les bras, le sceptre, la cape et
les genoux bougent).

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — ELLE NE SE RETOURNE JAMAIS. Sur la rangée de profil, elle regarde VERS LA
DROITE dans les 8 cases.
```

---

## Image 4 — les six icônes éveillées

Aucune image à joindre.

```
Planche de six ICÔNES DE SORTS pour un jeu de rôle mobile, style cartoon coloré,
contours nets, lisibles en tout petit.

PERSONNAGE : l'Ange des Étoiles éveillée en REINE DU FIRMAMENT, la reine de la nuit. Ses couleurs
sont le BLEU NUIT (#141d4a, profond #0c1236), l'ARGENT (#c8d4e8), le BLANC STELLAIRE (#f4f7ff), le
BLEU CLAIR des étoiles (#9db8ff) et l'OR PÂLE (#ffe2a0) en touches, avec un CONTOUR TRÈS FONCÉ
(#070a1c) net autour de chaque forme. Le motif commun des six icônes est l'ÉTOILE BLANCHE À QUATRE
BRANCHES et les FINS RAYONS D'ARGENT qui relient des étoiles : ils doivent se retrouver dans chacune.

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

1. TRAIT DE COMÈTE — une petite comète blanche à queue bleu clair qui file en diagonale, et une
   petite étoile qui s'allume au bout de sa course.

2. GRANDE CONSTELLATION — cinq étoiles blanches reliées par des rayons d'argent en une figure
   FERMÉE, à cinq côtés, dont l'intérieur est rempli d'une lumière bleu clair.

3. PLUIE DE MÉTÉORES — plusieurs petites étoiles qui tombent en biais, et un gros météore blanc à
   cœur d'or pâle qui tombe au milieu d'elles.

4. ÉCLIPSE — un disque bleu nuit qui cache presque un disque blanc, avec un anneau d'argent
   lumineux tout autour, et une onde en cercle qui part de l'anneau.

5. COMÈTE — une étoile filante à longue traînée bleu clair, qui laisse une étoile posée au bout de
   sa trajectoire.

6. NAISSANCE D'UNE GALAXIE — une galaxie en spirale bleu nuit et blanche, au cœur d'or pâle, avec
   des comètes qui en partent et de petites étoiles reliées par des rayons d'argent autour. C'est
   l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune lueur floue, aucune case vide, AUCUN ROSE NI VIOLET dans les
icônes : ils se confondraient avec le fond magenta. La nuit est BLEU NUIT, jamais violette ; la
galaxie est BLEUE et BLANCHE, jamais violette ni rose. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Ils seront peints au shader, comme ceux des autres Éveils. Mêmes règles : trois temps (départ, coup, trace qui
s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette de la Reine

| rôle | couleur | usage |
|---|---|---|
| Le bleu nuit | `#141d4a` / `#0c1236` | ciel de la galaxie, Éclipse, intérieur des figures |
| L'argent | `#c8d4e8` | rayons, anneaux, liserés |
| Le blanc stellaire | `#f4f7ff` | cœur des étoiles, comètes |
| Le bleu des étoiles | `#9db8ff` | lueurs, traînées, ondes |
| L'or pâle | `#ffe2a0` | instant de l'impact, cœur du gros météore et de la galaxie |

Le motif commun est **l'étoile à quatre branches** et **le rayon d'argent qui relie deux étoiles**. Jamais de violet,
de rose ni de vert.

### L'Éveil lui-même

- **La charge, 0,8 s :** des points d'étoile s'allument autour d'elle et se relient un à un par des traits d'argent.
- **L'éclosion :** la figure se ferme en une étoile à cinq branches tracée au sol autour d'elle, qui éclate en
  lumière ; un ciel étoilé s'ouvre un instant sur l'écran, et la caméra tremble.
- **Pendant la minute :** un **petit astre** blanc tourne autour d'elle en laissant une fine traînée, et une
  constellation lente tourne sous ses pieds.
- **La fin :** l'astre s'éteint, et la constellation se défait étoile par étoile.

### Les six sorts

- **Trait de comète :** une petite comète blanche à queue bleue ; au troisième coup, l'explosion d'étoiles, puis
  une étoile éphémère qui s'allume sur la case et qui clignote plus vite avant de s'éteindre.
- **Grande Constellation :** les rayons sont plus épais et plus vifs que d'habitude ; quand la figure se ferme, son
  intérieur se remplit d'un voile bleu nuit traversé de petites étoiles, et ses bords brillent d'argent.
- **Pluie de météores :** les chutes sont annoncées par un petit cercle au sol, et tombent avec une traînée ; le gros
  météore est annoncé par un grand cercle, tombe en dernier et fait trembler la caméra.
- **Éclipse :** un disque bleu nuit passe devant elle, cerclé d'un anneau d'argent ; à la fin, l'anneau s'élargit en
  une onde qui parcourt le sol.
- **Comète :** elle file en comète, laisse une traînée bleue brûlante, et une étoile se pose en tintant à l'arrivée.
- **Naissance d'une galaxie :** le ciel devient bleu nuit, une galaxie en spirale tourne lentement au centre de
  l'écran ; les comètes en partent vers chaque ennemi, et chaque impact s'allume en étoile, reliée à ses voisines :
  une constellation géante s'étend sur toute la carte avant de s'éteindre.
