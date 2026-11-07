# Aël, Dragon d'or — la forme du niveau 80

> La forme ultime d'Aël, demandée le 2026-11-04 : un dragon humanoïde épique, aux couleurs du Prisme (blanc, or,
> lumière). Plan de jeu : [HEROS_PRINCIPAL](../../HEROS_PRINCIPAL.md), section 9.

⚠️ **Ne jamais joindre `GGXrd_Dragon_Install_Sol_2.webp` au générateur, ni le déposer dans le dépôt.** C'est un
personnage protégé (Sol Badguy, *Guilty Gear Xrd*, Arc System Works), et le dépôt est public : même règle que les
planches du Seigneur Démon. Les prompts décrivent un dragon ORIGINAL qui en garde l'esprit — cornes, corps de dragon
debout, fissures de lumière sur la peau, griffes, grande lame — sans jamais en reprendre le dessin, la veste, les
ceintures, les chaînes ou l'arme.

## Ce qu'il est

Au niveau 80, la Transformation va plus loin : en Prisme, le bouton de la Transformation se recharge, et un second
appui l'éveille en **Dragon d'or** pour 15 secondes. Son corps devient celui d'un dragon debout, la gemme de sa
poitrine s'embrase, et il revient à sa forme Ascendant quand la lumière s'épuise. C'est le palier au-dessus du Prisme,
comme une deuxième transformation dans DBZ.

| | |
|---|---|
| **Débloqué** | niveau 80 (le niveau maximal passe de 30 à 80) |
| **Comment** | en Prisme, le bouton de la Transformation rechargé (8 kills) : un second appui |
| **Durée** | 15 s, chaque kill rend 1 s, chaque coup reçu en retire 3 ; retour à l'Ascendant |
| **PV** | il garde les siens, + 2 plaques d'écailles |
| **Vitesse** | 6,4 |
| **Dégâts** | + 160 % |
| **Trait** | **Flamme d'or** : chaque coup laisse une brûlure de lumière dorée, qui saute à l'ennemi voisin à la mort de sa cible |

## Sa silhouette et sa démarche

**Ce n'est plus un garçon** : c'est un dragon humanoïde grand et sec, environ 4 têtes de haut, voûté comme un
prédateur. Il marche sur deux pattes, mais **il rôde** : penché en avant, la tête basse, les genoux fléchis, sur
les orteils, les épaules qui roulent, les longs bras qui pendent griffes ouvertes, la queue qui fait contrepoids,
la lame qui traîne. Son attaque est une ruée de bête : un bond, une griffe, puis un revers de lame brutal.

Pour le jeu : sa démarche passe par le gabarit d'animation comme celle d'Aël, mais plus lourde (rebond plus
profond, à-coup plus fort), et il pourra être affiché un peu plus grand que les autres formes.

## Ses six sorts

Chacun a son effet propre, comme pour ses autres formes : rien d'un autre personnage, rien d'une autre de ses formes.

| Bouton | Sort | Ce qu'il fait | Ce qu'on voit |
|---|---|---|---|
| **Attaque** | **Griffes de soleil** | trois entailles en éventail devant lui, très rapides | trois griffures d'or parallèles qui lacèrent l'air, puis se referment en braises |
| **Sort 1** | **Souffle du Dragon** | un cône de flamme d'or de 5 cases devant lui, qui laisse le sol en fusion 3 s | un torrent de flamme dorée et blanche qui s'élargit, et des flaques d'or qui bouillonnent |
| **Sort 2** | **Écailles de soleil** | 2 s intouchable ; tout ennemi au contact brûle | ses écailles se dressent et s'embrasent, une couronne de flammes d'or tourne autour de lui |
| **Sort 3** | **Chute du Dragon** | il bondit hors de l'écran et retombe sur l'ennemi le plus proche à 6 cases, onde de choc de 2,5 cases | une ombre au sol qui se resserre, puis il s'écrase dans une colonne de lumière et le sol se fend en étoile |
| **Fuite** | **Ailes d'or** | il s'envole par-dessus les haies sur 7 cases | deux grandes ailes de lumière s'ouvrent, et des plumes d'or retombent derrière lui |
| **Extra** | **Rugissement du Roi-Dragon** | une tête de dragon de lumière surgit derrière lui et rugit : un souffle colossal traverse tout l'écran devant lui, à travers les haies, et brûle tout | la tête de dragon apparaît, gueule ouverte, l'écran blanchit, puis un fleuve de lumière d'or balaie l'écran |

⚠️ Ses grandes ailes, la tête de dragon de l'Extra, les flammes et les fissures qui brillent sont **dessinées par le
jeu**, au shader : jamais sur les planches, où elles resteraient figées.

---

## L'ordre des images

| # | Image | Joindre, dans cet ordre | Déposer dans `assets/peso&cover/` |
|---|---|---|---|
| 1 | Le modèle | `refonte/ael_prisme.png`, `refonte/ael_apprenti.png` | `refonte/ael_dragon.png` |
| 2 | Le déplacement | `refonte/ael_dragon.png`, `docs/prompts/template/guide_dragon.png` | `mages/ael_dragon_marche.png` |
| 3 | L'attaque | `refonte/ael_dragon.png` | `mages/ael_dragon_attaque.png` |
| 4 | Le portrait | `docs/prompts/ref/ref_carte.png`, `interface/portraits/portrait_ael_prisme.png`, `refonte/ael_dragon.png` | `interface/portraits/portrait_ael_dragon.png` |
| 5 | Les six icônes | rien | `sorts/mage_ael_dragon_skills.png` |

**À vérifier sur chaque image :** une créature voûtée et non un garçon droit, une démarche de rôdeur et non de
promeneur, le visage d'Aël reconnaissable, aucun rose ni violet ni rouge sang, rien qui
flotte autour de lui (sauf sur le portrait), pas d'ailes sur les planches de jeu, et rien qui rappelle un personnage
existant (veste à pointes, ceinture, chaînes, épée en forme de clé).

---

## Image 1 — le modèle

Joindre `assets/peso&cover/refonte/ael_prisme.png` **puis** `assets/peso&cover/refonte/ael_apprenti.png`.
Déposer dans `assets/peso&cover/refonte/ael_dragon.png`.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.

LES IMAGES JOINTES :
- la PREMIÈRE est le même héros dans sa forme Prisme : garde EXACTEMENT ses couleurs (blanc, or
  pâle, or, touches de cyan pâle) et la mise en page en trois cases. PAS sa silhouette.
- la DEUXIÈME est le même garçon dans sa première forme : garde seulement son VISAGE reconnaissable.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 75 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — Aël, DRAGON D'OR, sa forme ultime. Ce n'est PLUS un garçon : c'est un DRAGON
HUMANOÏDE, grand, sec et musclé, qui se tient debout sur deux pattes mais VOÛTÉ comme un
prédateur, les épaules en avant, la tête basse et projetée, les genoux fléchis. Silhouette
élancée et anguleuse : longs bras qui pendent jusqu'aux genoux, mains en GRIFFES d'or à quatre
doigts, jambes de DRAGON qui marchent sur les orteils (le talon haut, le jarret replié en arrière),
pieds griffus. Une longue QUEUE écaillée part de ses reins et touche presque le sol.
Son visage reste celui d'Aël, durci, avec des yeux d'or fendus et des crocs. De ses cheveux blancs
et or, dressés en mèches de flamme, sortent DEUX GRANDES CORNES d'or courbées vers l'arrière.
Peau d'ÉCAILLES blanc nacré (#f6f3ea) et or (#f2c94c), plus épaisses sur les avant-bras, les
épaules et les tibias ; sur son torse, ses bras et ses jambes courent de fines FISSURES DE LUMIÈRE
blanc doré, comme une flamme sous la peau. Une plaque d'armure d'or sur les épaules et la
poitrine, la gemme d'or sertie au centre. Il tient de la main droite une GRANDE LAME d'or et de
cristal, large et droite, qui traîne nonchalamment vers le sol. Toutes ses formes claires sont
cernées d'un contour brun doré net.

⚠️ RÈGLE BLOQUANTE — UN DESSIN ORIGINAL. Aucune veste, aucune ceinture, aucune chaîne, aucune sangle
à boucles, aucune pointe de métal sur les épaules, aucune épée en forme de clé : il ne doit
ressembler à aucun personnage de jeu existant.

⚠️ RÈGLE BLOQUANTE — UNE AUTRE SILHOUETTE QUE L'APPRENTI : grand et élancé, environ 4 TÊTES de
haut (cornes non comprises), voûté, jamais droit comme un humain. Posé à côté de la première
image, on doit voir une créature, pas un garçon déguisé.

⚠️ RÈGLE BLOQUANTE — PAS D'AILES sur cette image, et RIEN NE FLOTTE AUTOUR DE LUI : aucune flamme,
aucun halo, aucune aura, aucune particule. Le jeu ajoutera ses ailes et ses flammes, en mouvement.
La lumière est seulement dans les couleurs de ses fissures, de ses yeux et de sa gemme.

⚠️ RÈGLE BLOQUANTE — SES DEUX JAMBES SE LISENT EN TRÈS PETIT, séparées, et la queue ne les cache
jamais.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN ROUGE, AUCUN MAGENTA sur lui, ni reflet du fond.
Ses ombres tirent vers l'ambre et le brun doré.

⚠️ RÈGLE BLOQUANTE — MÊME visage, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

---

## Image 2 — le déplacement

Joindre `assets/peso&cover/refonte/ael_dragon.png` **puis** `docs/prompts/template/guide_dragon.png`, la démarche
de rôdeur dessinée pour lui (`tools/build_template_guides.py`).

⚠️ **Refaite le 2026-11-06** : la première planche avait des pas trop serrés de profil (le joueur : « trop serré »).
Le guide a été élargi à une demi-hauteur. L'ancienne est gardée dans `mages/ael_dragon_marche_serree.png`.
Déposer dans `assets/peso&cover/mages/ael_dragon_marche.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son visage, ses cornes, ses
écailles, ses couleurs, sa silhouette voûtée et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — Aël, Dragon d'or : un DRAGON HUMANOÏDE grand et sec, voûté comme un prédateur,
la tête basse et projetée, deux grandes cornes d'or, écailles blanc nacré et or, fissures de
lumière blanc doré, armure d'or aux épaules et à la poitrine avec la gemme d'or, longs bras
griffus, jambes de dragon sur les orteils, longue queue. Une GRANDE LAME d'or et de cristal dans
la main droite, qui traîne vers le sol.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, il avance vers le bas de l'image
- rangée 2 : vu DE DOS, il s'éloigne vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

IL NE MARCHE PAS COMME UN HUMAIN : IL RÔDE COMME UN DRAGON. Sur deux pattes, mais voûté et
penché en avant pendant toute la boucle, la tête basse qui reste en avant, les genoux toujours
fléchis. Il pose le pied sur les ORTEILS, griffes d'abord, le talon jamais au sol. Ses épaules
ROULENT à chaque pas, à l'opposé du pied qui avance, et ses longs bras se balancent bas, presque
jusqu'aux genoux, griffes ouvertes. Sa queue ondule et fait contrepoids, en retard sur le corps.
La lame traîne derrière lui, pointe vers le sol. C'est une démarche lente, lourde et menaçante.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE POSE. Elle a la même grille que la planche à produire.
Dans chaque case, recopie EXACTEMENT la posture voûtée, la position de ses pattes, de ses bras et
de sa queue. Rouge : la patte et le bras proches ; bleu : les autres ; jaune : les griffes. Le
mannequin et ses couleurs ne doivent PAS apparaître : c'est le personnage de la première image
qui prend ces poses.

LES 8 IMAGES de chaque rangée sont UNE BOUCLE, à GRANDES FOULÉES :
1. la patte rouge pose devant, sur les orteils ; la patte bleue pousse derrière
2. la patte rouge porte le poids, le corps plonge un peu
3. PASSAGE : la patte bleue passe sous le corps, repliée
4. la patte bleue part devant, les épaules roulent de l'autre côté
5. l'INVERSE de l'image 1
6. la patte bleue porte le poids, le corps plonge un peu
7. PASSAGE : la patte rouge passe sous le corps, repliée
8. la patte rouge part devant : l'image enchaîne sur la première

⚠️ RÈGLE BLOQUANTE — VOÛTÉ ET PENCHÉ EN AVANT DANS LES 24 CASES : jamais droit comme un humain.

⚠️ RÈGLE BLOQUANTE — DE PROFIL, DE GRANDES FOULÉES ARTICULÉES, PAS DES PETITS PAS SERRÉS. Aux images 1
et 5, ses deux pieds sont écartés d'environ LA MOITIÉ DE SA HAUTEUR : un pied loin devant, l'autre loin
derrière, comme sur le guide. À chaque pas la cuisse avance, le genou plie franchement et le jarret
repart en arrière ; au passage (images 3 et 7), le genou de la patte qui revient MONTE haut, à mi-cuisse.
La lame et la queue ne cachent jamais ses pattes : la lame traîne DERRIÈRE la patte arrière.

⚠️ RÈGLE BLOQUANTE — UN PIED TOUJOURS AU SOL, et les images 5 à 8 ne répètent pas les images 1 à 4 :
les deux pattes échangent leurs places.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES : sa tête et ses cornes ont la même
hauteur et la même largeur dans les 24 cases ; il n'est pas plus fin de profil.

⚠️ RÈGLE BLOQUANTE — LA TÊTE NE GLISSE PAS D'UNE CASE À L'AUTRE, et les pieds touchent la même ligne
dans les 24 cases. C'est le JEU qui le fait avancer.

⚠️ RÈGLE BLOQUANTE — PAS D'AILES, AUCUNE FLAMME, AUCUN HALO, AUCUNE PARTICULE : le jeu les ajoute.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN ROUGE sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS : de profil, son visage regarde VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans ombre portée ni cadre.
```

---

## Image 3 — l'attaque

Joindre seulement `assets/peso&cover/refonte/ael_dragon.png` : le guide du coup d'épée est celui d'un humain.
Déposer dans `assets/peso&cover/mages/ael_dragon_attaque.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe montre le personnage : garde EXACTEMENT son visage, ses cornes, ses écailles, ses
couleurs, sa silhouette voûtée et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — Aël, Dragon d'or : un DRAGON HUMANOÏDE grand et sec, voûté comme un prédateur,
deux grandes cornes d'or, écailles blanc nacré et or, fissures de lumière blanc doré, armure d'or
aux épaules et à la poitrine avec la gemme d'or, longs bras griffus, jambes de dragon sur les
orteils, longue queue. Une GRANDE LAME d'or et de cristal dans la main droite.

⚠️ MÊME TAILLE QUE SUR LA PREMIÈRE IMAGE JOINTE : la tête et le tronc ont les mêmes dimensions
dans les 24 cases.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face à nous : le coup vient VERS NOUS
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL ASSAUT DE BÊTE, de gauche à droite, pas une boucle.
Ce n'est pas le coup d'épée appliqué d'un humain : c'est une ruée sauvage.
1. LA MENACE : il se ramasse, encore plus bas, la tête rentrée, la queue dressée
2. LA DÉTENTE : il bondit en avant, le buste à l'horizontale, la main griffue libre lancée devant
3. LA GRIFFE : la main gauche lacère l'air devant lui, quatre griffes écartées
4. L'IMPACT : la grande lame part dans un revers brutal, à bout de bras, le corps tordu
5. LA LAME FINIT SA COURSE, emportée par son poids ; la queue fouette de l'autre côté
6. il retombe sur ses pattes, accroupi, la lame plantée vers le sol
7. il se redresse à moitié, voûté, gueule ouverte
8. il retrouve sa pose de rôdeur, la lame traînant vers le sol

Les images 2, 4 et 6 sont les POSES CLÉS : elles se distinguent au premier regard par leur seule
silhouette.

⚠️ RÈGLE BLOQUANTE — LE CORPS RESTE CENTRÉ dans sa case, sur la tête et les pieds, jamais sur
l'ensemble du corps et de la lame. C'est le jeu qui le fait bondir en avant.

⚠️ RÈGLE BLOQUANTE — AUCUN EFFET : aucune flamme, aucun arc lumineux, aucune griffure dessinée dans
l'air, aucune étincelle. Le jeu les ajoute lui-même.

⚠️ RÈGLE BLOQUANTE — PAS D'AILES. AUCUN ROSE, AUCUN VIOLET, AUCUN ROUGE sur lui.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS : de profil, son visage regarde VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans ombre portée ni cadre.
```

---

## Image 4 — le portrait

Joindre `docs/prompts/ref/ref_carte.png`, **puis** `assets/peso&cover/interface/portraits/portrait_ael_prisme.png`,
**puis** `assets/peso&cover/refonte/ael_dragon.png`. Déposer dans
`assets/peso&cover/interface/portraits/portrait_ael_dragon.png`.

```
Portrait vertical pour un écran de sélection de héros, illustration fantasy manga épique,
détails riches et contours nets. Les images jointes donnent la mise en page, le style et le
visage du héros, puis son apparence dans cette forme, dans cet ordre.

FORMAT : une image verticale au rapport 3:4, même cadrage et même échelle que le portrait
joint en deuxième.

SUJET — Aël, DRAGON D'OR, la forme ultime du héros principal : reprendre exactement le dragon
humanoïde du modèle, grand, sec et voûté comme un prédateur, la tête basse et projetée, avec le visage d'Aël reconnaissable, ses yeux d'or fendus, ses cheveux blancs
et or dressés et ses deux grandes cornes d'or. Écailles blanc nacré et or, fissures de lumière
blanc doré qui brillent sous la peau, armure d'or aux épaules et à la poitrine où la gemme d'or
flamboie, mains griffues, courte queue. Il tient sa grande lame d'or et de cristal, qui traîne vers
le sol, et fixe le joueur par en dessous, menaçant.

Ici SEULEMENT : derrière lui s'ouvrent deux immenses ailes de dragon faites de LUMIÈRE d'or, et
des flammes dorées montent de ses épaules. Un souffle de lumière fait voler ses cheveux.

Il est entier, debout, de face légèrement de trois quarts ; ses pieds griffus sont visibles. Même
visage et même âge que sur le portrait joint en deuxième.

FOND : nappe bleu nuit au centre, noir profond vers les bords, avec une immense lueur dorée
derrière lui. Aucun décor.

RÈGLES : personnage centré, environ 80 % de la hauteur ; aucun cadre, bordure, texte, nom,
chiffre, logo, sol, ombre portée ni autre personnage. Aucun rose, aucun violet, aucun rouge.
Un dessin original : ni veste, ni ceinture, ni chaînes, ni épée en forme de clé.
```

---

## Image 5 — les six icônes

Rien à joindre. Déposer dans `assets/peso&cover/sorts/mage_ael_dragon_skills.png`.

```
Planche de six icônes de sorts pour un jeu de rôle mobile, style fantasy manga, contours nets
et formes lisibles en petit. Ces symboles appartiennent à un héros devenu DRAGON D'OR, un
dragon debout fait de lumière et d'écailles blanches et dorées.

FORMAT exact : image 1536 x 1024 pixels, grille régulière de 3 colonnes x 2 rangées, six cases
de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne de grille, cadre, numéro ou texte.
Une icône centrée par case, environ 70 % de la case, avec une marge magenta généreuse.

Palette STRICTE : blanc (#f6f3ea), or pâle (#fff4c8), or (#f2c94c), ambre (#ffb347) et brun
doré pour les contours. AUCUN rose, AUCUN violet, AUCUN rouge, AUCUN magenta dans les dessins.
Les éclats sont des aplats nets, sans halo flou. Des symboles, sans personnage ni visage.

Dans l'ordre de lecture :
1. GRIFFES DE SOLEIL — trois griffures d'or parallèles en diagonale, nettes, avec des braises
   au bout de chaque trait.
2. SOUFFLE DU DRAGON — un torrent de flamme d'or et blanche qui s'élargit en cône vers la droite.
3. ÉCAILLES DE SOLEIL — un bouclier fait de grandes écailles d'or dressées en éventail, bordées
   de flammes blanches.
4. CHUTE DU DRAGON — une silhouette de griffe d'or qui plonge vers le bas sur une étoile de
   fissures qui éclate au sol.
5. AILES D'OR — deux grandes ailes de dragon faites de lumière d'or, déployées.
6. RUGISSEMENT DU ROI-DRAGON — une tête de dragon de lumière d'or, de face, gueule grande
   ouverte, d'où jaillit un flot de lumière blanche. C'est l'icône la plus spectaculaire.

Pas de décor, arrière-plan illustré, ombre, flou, cadre, texte ni personnage.
Le magenta du fond ne doit pas se refléter dans les icônes.
```
