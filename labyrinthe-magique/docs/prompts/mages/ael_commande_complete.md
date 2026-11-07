# Aël — la commande complète des images

**Un seul fichier, à faire d'une traite, dans l'ordre.** Chaque image dit ce qu'il faut joindre et où la
déposer. L'ordre compte : la marche, l'attaque et le portrait d'une forme joignent son modèle, qui doit donc
être fait avant.

**Les seize images sont déposées**, le 2026-11-04. Les icônes de l’Apprenti ont été refaites pour
Tranche-vent et Parade ; les trois portraits des évolutions sont également en place.

Tous les chemins partent de la racine du projet `labyrinthe-magique/`.

| # | Image | Joindre, dans cet ordre | Déposer dans `assets/peso&cover/` |
|---|---|---|---|
| 1 | Icônes de l'Apprenti, refaites | rien | `sorts/mage_ael_skills.png`, à la place de l'ancienne |
| 2 | Éveillé : modèle | `refonte/ael_concept.png`, `refonte/ael_apprenti.png` | `refonte/ael_eveille.png` |
| 3 | Éveillé : déplacement | `refonte/ael_eveille.png`, `docs/prompts/template/guide_heros.png` | `mages/ael_eveille_marche.png` |
| 4 | Éveillé : attaque | `refonte/ael_eveille.png`, `docs/prompts/template/guide_attaque.png` | `mages/ael_eveille_attaque.png` |
| 5 | Éveillé : portrait | `docs/prompts/ref/ref_carte.png`, `interface/portraits/portrait_ael.png`, `refonte/ael_eveille.png` | `interface/portraits/portrait_ael_eveille.png` |
| 6 | Éveillé : icônes | rien | `sorts/mage_ael_eveille_skills.png` |
| 7 | Ascendant : modèle | `refonte/ael_concept.png`, `refonte/ael_apprenti.png` | `refonte/ael_ascendant.png` |
| 8 | Ascendant : déplacement | `refonte/ael_ascendant.png`, `docs/prompts/template/guide_heros.png` | `mages/ael_ascendant_marche.png` |
| 9 | Ascendant : attaque | `refonte/ael_ascendant.png`, `docs/prompts/template/guide_attaque.png` | `mages/ael_ascendant_attaque.png` |
| 10 | Ascendant : portrait | `docs/prompts/ref/ref_carte.png`, `interface/portraits/portrait_ael.png`, `refonte/ael_ascendant.png` | `interface/portraits/portrait_ael_ascendant.png` |
| 11 | Ascendant : icônes | rien | `sorts/mage_ael_ascendant_skills.png` |
| 12 | Prisme : modèle | `refonte/ael_concept.png`, `refonte/ael_apprenti.png` | `refonte/ael_prisme.png` |
| 13 | Prisme : déplacement | `refonte/ael_prisme.png`, `docs/prompts/template/guide_heros.png` | `mages/ael_prisme_marche.png` |
| 14 | Prisme : attaque | `refonte/ael_prisme.png`, `docs/prompts/template/guide_attaque.png` | `mages/ael_prisme_attaque.png` |
| 15 | Prisme : portrait | `docs/prompts/ref/ref_carte.png`, `interface/portraits/portrait_ael.png`, `refonte/ael_prisme.png` | `interface/portraits/portrait_ael_prisme.png` |
| 16 | Prisme : icônes | rien | `sorts/mage_ael_prisme_skills.png` |

Les images jointes qui commencent par `refonte/`, `mages/`, `interface/` ou `sorts/` sont dans
`assets/peso&cover/`.

## Avant de déposer chaque image

| Image | À vérifier |
|---|---|
| Modèle | même visage et même taille que l'Apprenti ; chibi ; aucun rose, violet ni lavande ; rien ne flotte autour de lui |
| Déplacement | de profil, pieds joints aux images 3 et 7, buste droit ; tête de même taille sur les 3 rangées ; rien du guide visible |
| Attaque | même taille que le déplacement ; aucun arc ni effet dessiné ; il regarde à droite de profil |
| Portrait | même visage et même cadrage que le portrait de l'Apprenti |
| Icônes | six icônes, une par case, sur magenta uni ; aucun rose ni violet |

---

## Image 1 — les icônes de l'Apprenti

Rien à joindre. Déposer dans `assets/peso&cover/sorts/mage_ael_skills.png`.

```
Planche de six icônes de sorts pour un jeu de rôle mobile, style fantasy manga,
contours nets et formes lisibles en petit. Ces symboles appartiennent à Aël l'Apprenti, un jeune épéiste sans élément ni magie : chaque sort est un geste d'épée.

FORMAT exact : image 1536 x 1024 pixels, grille régulière de 3 colonnes x 2
rangées, six cases de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne
de grille, cadre, numéro ou texte. Une icône centrée par case, environ 70 % de la
case, avec une marge magenta généreuse et sans débordement.

Palette STRICTE : acier (#c9d2dc), blanc bleuté (#dff4ff), brun cuir (#6b4428), rouge sombre (#8e1b17) et, seulement en case 6, cyan (#8fe3ff). AUCUN rose, AUCUN violet, AUCUN magenta, AUCUN arc-en-ciel
dans les dessins. Les éclats sont des aplats nets, sans halo flou. Les icônes sont des
symboles, sans personnage ni visage.

Dans l'ordre de lecture :
1. COUP D'ÉPÉE — une épée courte d'acier à garde de laiton qui tranche en arc, suivie d'un trait courbe blanc net.
2. TRANCHE-VENT — une lame d'air en forme de croissant, blanche bordée d'acier, qui file vers la droite en laissant trois croissants plus pâles derrière elle. Aucune gemme.
3. PARADE — deux épées courtes d'acier croisées en X, avec un éclat blanc en étoile à leur point de contact. Aucun bouclier.
4. RUÉE — une botte de cuir brun qui fonce vers la droite, l'épée pointée devant elle, suivie de trois traits de vitesse blancs.
5. ROULADE — une flèche circulaire blanche qui fait un tour complet autour d'un petit nuage de poussière brune, et un pan d'écharpe rouge sombre qui suit la flèche. Aucun personnage.
6. ÉVEIL DE L'ÉCLAT — une épée d'acier au centre d'un grand cercle de coup blanc, et sur sa garde un petit éclat de gemme qui s'illumine de cyan. C'est l'icône la plus spectaculaire.

Pas de décor, arrière-plan illustré, ombre, flou, cadre, texte ni personnage.
Le magenta du fond ne doit pas se refléter dans les icônes.
```

---

# Aël l'Éveillé (niveau 10)

## Image 2 — le modèle

Joindre `assets/peso&cover/refonte/ael_concept.png` **puis** `assets/peso&cover/refonte/ael_apprenti.png`.
Déposer dans `assets/peso&cover/refonte/ael_eveille.png`.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.

LES IMAGES JOINTES :
- la PREMIÈRE est la planche de concept du personnage, Aël. Dessine UNIQUEMENT sa deuxième
  forme, « 1. Éveillé » (la mèche blanche et la courte cape crème). Garde sa coiffure, sa tenue
  et ses couleurs. Ne recopie NI sa mise en page, NI son fond violet, NI ses textes, NI ses
  cadres, NI ses lueurs.
- la DEUXIÈME est le MÊME garçon dans sa première forme, déjà validée : garde EXACTEMENT son
  visage, sa taille, ses proportions et la mise en page de ses trois cases. Il a seulement évolué.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — Aël l'Éveillé, le même jeune garçon HUMAIN, plus sûr de lui. Cheveux noirs en
épis avec une grande mèche BLANCHE sur le devant, yeux brun sombre. Une courte cape blanc crème
(#efe6d2) couvre ses épaules et s'arrête au milieu du dos. Tunique de cuir brun ceinturée,
pantalon brun foncé, bottes brunes. Un gantelet de CRISTAL cyan (#7fe3ff) couvre son avant-bras
gauche. Il tient de la main droite une épée à LAME DE CRISTAL cyan translucide, pointe vers le
bas. La gemme est maintenant fixée sur sa poitrine, et ELLE BRILLE, blanc-bleu (#dff6ff), par
sa seule couleur. Toutes ses formes sont cernées d'un fin contour brun foncé net.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE ET LE MÊME CORPS QUE SUR LA DEUXIÈME IMAGE. Tête, tronc,
jambes et pieds ont les mêmes dimensions : il change d'allure, pas de corps. Toujours CHIBI,
2,5 TÊTES de haut.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT : la cape s'arrête au dos et ne les cache
jamais.

⚠️ RÈGLE BLOQUANTE — LA LUMIÈRE EST DANS LES COULEURS, PAS AUTOUR. La gemme, le gantelet et la
lame sont clairs et lumineux, mais sans halo, sans aura, sans particule ni étincelle.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond.

⚠️ RÈGLE BLOQUANTE — MÊME visage, tenue, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

## Image 3 — le déplacement

Joindre `assets/peso&cover/refonte/ael_eveille.png` **puis** `docs/prompts/template/guide_heros.png`.
Déposer dans `assets/peso&cover/mages/ael_eveille_marche.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son visage, sa coiffure, sa
tenue, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — Aël l'Éveillé, un jeune garçon HUMAIN, en proportions CHIBI : grosse tête,
corps court. Cheveux noirs en épis avec une grande mèche BLANCHE sur le devant, yeux brun
sombre. Courte cape blanc crème (#efe6d2) sur les épaules, qui s'arrête au milieu du dos.
Tunique de cuir brun ceinturée, pantalon brun foncé, bottes brunes. Gantelet de CRISTAL cyan
(#7fe3ff) sur l'avant-bras gauche. Une épée à LAME DE CRISTAL cyan translucide dans la main
droite. La gemme fixée sur sa poitrine brille blanc-bleu, par sa seule couleur.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, il COURT vers le bas de l'image
- rangée 2 : vu DE DOS, il COURT vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE, il MARCHE d'un pas vif vers la droite

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE POSE. Elle a la même grille que la planche à
produire. Dans chaque case, recopie EXACTEMENT la position de ses pieds et de ses jambes, et
sur les rangées 1 et 2 celle de ses mains et de son épée (rouge : le bras et la jambe qui
tiennent l'épée ; bleu : les autres ; jaune : l'épée). Rien du guide ne doit apparaître : ni
le mannequin, ni ses couleurs, ni le corps gris, le bâton, la robe verte ou les bottes de la
rangée 3. C'est le personnage de la première image qui prend ces poses. ⚠️ Les têtes du guide
n'ont pas la même taille d'une rangée à l'autre : N'EN TIENS PAS COMPTE.

RANGÉES 1 ET 2, UNE COURSE ÉNERGIQUE À PAS MOYENS, en boucle :
1. contact : le pied rouge pose devant, le pied bleu pousse derrière
2. le pied rouge porte le poids, le genou bleu commence à monter
3. PASSAGE : le pied rouge sous le corps, le genou bleu monte
4. le pied bleu part devant, le pied rouge recule
5. l'INVERSE de l'image 1
6. le pied bleu porte le poids, le genou rouge commence à monter
7. PASSAGE : le pied bleu sous le corps, le genou rouge monte
8. le pied rouge part devant : l'image enchaîne sur la première
Les coudes sont pliés et les bras balancent franchement, en opposition aux jambes. L'épée
reste basse et suit le bras. Les pans de sa cape flottent derrière lui, en retard sur le corps. De face et de dos, les pieds restent sous le corps : l'un puis l'autre monte.

RANGÉE 3, DE PROFIL, UNE MARCHE DROITE, sans pencher et sans lever le genou :
1. jambes ouvertes, comme sur le guide : un pied devant, l'autre derrière
2. jambes ouvertes, comme sur le guide
3. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, un seul à peine levé
4. jambes ouvertes de nouveau, les pieds ont ÉCHANGÉ leur place
5. jambes ouvertes : l'INVERSE de l'image 1
6. jambes ouvertes : l'INVERSE de l'image 2
7. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, l'autre à peine levé
8. jambes ouvertes de nouveau : l'image enchaîne sur la première
Le bras gauche balance en opposition aux jambes, l'épée reste basse, la tenue suit le pas.

⚠️ RÈGLE BLOQUANTE — UN PIED TOUJOURS AU SOL. Il ne saute pas : aucune image où les deux pieds
sont en l'air. Ni grand écart, ni jambes en compas.

⚠️ RÈGLE BLOQUANTE — LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. De profil, aux images 3 et 7,
la largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5. Dans les
trois rangées, les images 5 à 8 ne répètent pas les images 1 à 4 : les jambes échangent leurs places.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. De profil, il n'est
ni plus fin, ni plus grand, et ses jambes ne sont pas plus longues que de face.

⚠️ RÈGLE BLOQUANTE — LA TÊTE NE BOUGE PAS D'UNE CASE À L'AUTRE. Dans une même rangée, elle se
superpose exactement, même taille, même place. C'est le JEU qui le fait avancer et rebondir : la
planche montre les membres, sur place, comme sur un tapis roulant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — LA LUMIÈRE EST DANS LES COULEURS, PAS AUTOUR : la gemme, le gantelet et la lame
sont clairs, sans halo, sans aura, sans particule.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS
LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune
poussière, aucun trait de vitesse. Les effets sont ajoutés par le jeu.
```

## Image 4 — l'attaque

Joindre `assets/peso&cover/refonte/ael_eveille.png` **puis** `docs/prompts/template/guide_attaque.png`.
Déposer dans `assets/peso&cover/mages/ael_eveille_attaque.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe montre le personnage : garde EXACTEMENT son visage, sa coiffure, sa tenue, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — Aël l'Éveillé, un jeune garçon HUMAIN, en proportions CHIBI : grosse tête,
corps court. Cheveux noirs en épis avec une grande mèche BLANCHE sur le devant, yeux brun
sombre. Courte cape blanc crème (#efe6d2) sur les épaules, qui s'arrête au milieu du dos.
Tunique de cuir brun ceinturée, pantalon brun foncé, bottes brunes. Gantelet de CRISTAL cyan
(#7fe3ff) sur l'avant-bras gauche. Une épée à LAME DE CRISTAL cyan translucide dans la main
droite. La gemme fixée sur sa poitrine brille blanc-bleu, par sa seule couleur.

⚠️ MÊME TAILLE QUE SUR LA PREMIÈRE IMAGE JOINTE : la tête et le tronc ont les mêmes dimensions
dans les 24 cases. Un corps plus petit se verrait comme un rétrécissement à chaque coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face à nous : le coup vient VERS NOUS
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos : le coup s'éloigne de nous
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

⚠️ LA DEUXIÈME IMAGE JOINTE EST UN GUIDE DE POSE. Elle a la même grille que la planche à
produire. Dans chaque case, recopie EXACTEMENT la position de ses pieds, de sa main, de son
buste et l'angle de son épée. Rouge : le bras et la jambe qui tiennent l'épée. Bleu : les
autres. Jaune : l'épée. Le mannequin et ses couleurs ne doivent PAS apparaître : c'est le
personnage de la première image qui prend ces poses.

LES 8 COLONNES de chaque rangée sont UN SEUL COUP D'ÉPÉE, de gauche à droite, pas une boucle :
1. L'ÉLAN : il abaisse l'épée vers l'arrière, les épaules se tournent
2. ARMÉ : l'épée est levée au plus loin en arrière, le corps enroulé, tendu comme un ressort
3. LE DÉPART : la lame file par-dessus l'épaule, le buste commence à se dérouler
4. L'IMPACT : le bras est tendu, la lame devant lui, le buste jeté en avant
5. LA LAME FINIT SA COURSE : elle passe de l'autre côté, le buste reste penché
6. FIN DU GESTE : le bras est au bout de son mouvement, le corps est tenu
7. LE RETOUR : le bras se replie, le buste se redresse
8. il retrouve sa pose de marche, l'épée basse, la pointe vers le bas

Les images 2, 4 et 6 sont les POSES CLÉS : elles doivent se distinguer au premier regard par
leur seule silhouette, comme dans un jeu d'action.

⚠️ RÈGLE BLOQUANTE — LA TÊTE NE BOUGE PAS D'UNE CASE À L'AUTRE, et le corps reste CENTRÉ dans sa
case, sur la tête et les pieds, jamais sur l'ensemble du corps et de l'épée. C'est le jeu qui fait
la petite poussée vers l'avant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS NE BOUGENT PAS. Ils sont plantés aux mêmes endroits dans les 8 images
d'une rangée, et leur bas touche la même ligne horizontale dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — L'ÉPÉE PART DANS LA DIRECTION DE LA RANGÉE, et reste entière dans sa case. Elle
garde sa longueur : elle ne paraît plus courte que quand elle vient vers nous ou s'éloigne de nous.

⚠️ RÈGLE BLOQUANTE — AUCUN EFFET : aucun arc lumineux, aucune traînée, aucun flou, aucune étincelle,
aucune lueur ajoutée autour de la lame. Le jeu ajoute lui-même l'arc de lame, au bon moment et à la bonne couleur.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS LA
DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

## Image 5 — le portrait

Joindre `docs/prompts/ref/ref_carte.png`, **puis** `assets/peso&cover/interface/portraits/portrait_ael.png`, **puis**
`assets/peso&cover/refonte/ael_eveille.png`. Déposer dans `assets/peso&cover/interface/portraits/portrait_ael_eveille.png`.

```
Portrait vertical pour un écran de sélection de héros, illustration fantasy
manga soignée, détails riches et contours nets. Les images jointes donnent la
mise en page, le style et le visage du héros, puis sa tenue dans cette forme, dans cet ordre.

FORMAT : une image verticale au rapport 3:4, même cadrage et même échelle que le
portrait joint en deuxième.

SUJET — Aël l'Éveillé, le héros principal dans sa deuxième forme : reprendre exactement le jeune garçon
HUMAIN du modèle. Cheveux noirs en épis avec une grande mèche blanche sur le devant, yeux brun
sombre, regard plus assuré. Courte cape blanc crème sur les épaules, tunique de cuir brun
ceinturée, gantelet de cristal cyan à l'avant-bras gauche, épée à lame de cristal cyan dans la
main droite. La gemme de sa poitrine brille blanc-bleu, et quelques reflets cyan dansent sur la
lame.

Il est entier, debout, de face légèrement de trois quarts, et regarde le joueur ; ses bottes
sont visibles. Même visage, même âge et même taille que sur le portrait joint en deuxième.

FOND : nappe bleu nuit au centre, noir profond vers les bords, avec une lueur cyan derrière lui. Aucun décor.

RÈGLES : personnage centré, environ 80 % de la hauteur ; aucun cadre, bordure, texte, nom,
chiffre, logo, sol, ombre portée ni autre personnage. Aucun rose, aucun violet, aucune lavande.
```

## Image 6 — les icônes

Rien à joindre. Déposer dans `assets/peso&cover/sorts/mage_ael_eveille_skills.png`.

```
Planche de six icônes de sorts pour un jeu de rôle mobile, style fantasy manga,
contours nets et formes lisibles en petit. Ces symboles appartiennent à Aël l'Éveillé, un jeune héros à l'épée qui a éveillé la lumière des gemmes.

FORMAT exact : image 1536 x 1024 pixels, grille régulière de 3 colonnes x 2
rangées, six cases de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne
de grille, cadre, numéro ou texte. Une icône centrée par case, environ 70 % de la
case, avec une marge magenta généreuse et sans débordement.

Palette STRICTE : cyan clair (#7fe3ff), blanc bleuté (#dff6ff), blanc crème (#efe6d2) et brun cuir. AUCUN rose, AUCUN violet, AUCUN magenta, AUCUN arc-en-ciel
dans les dessins. Les éclats sont des aplats nets, sans halo flou. Les icônes sont des
symboles, sans personnage ni visage.

Dans l'ordre de lecture :
1. LAME D'ÉCLAT — une lame de cristal cyan qui tranche en diagonale, et une courte onde en croissant qui part de sa pointe.
2. GERBE DE GEMMES — un éventail de cinq petites gemmes cyan taillées, qui partent en arc et dont la trace revient en boucle.
3. PRISME GARDIEN — un bouclier en facettes de cristal cyan, sur lequel rebondit une flèche qui repart en sens inverse.
4. FRAPPE ÉCLAIR — un trait de lumière cyan, droit et net, qui court au sol dans un couloir et laisse des éclats derrière lui.
5. PAS DE LUMIÈRE — une silhouette de botte en lumière blanc-bleu, suivie de trois traces de pas qui s'effacent.
6. RAYON DE GEMME — une gemme taillée d'où jaillit un large rayon blanc-bleu, droit devant. C'est l'icône la plus spectaculaire.

Pas de décor, arrière-plan illustré, ombre, flou, cadre, texte ni personnage.
Le magenta du fond ne doit pas se refléter dans les icônes.
```

---

# Aël l'Ascendant (niveau 20)

## Image 7 — le modèle

Joindre `assets/peso&cover/refonte/ael_concept.png` **puis** `assets/peso&cover/refonte/ael_apprenti.png`.
Déposer dans `assets/peso&cover/refonte/ael_ascendant.png`.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.

LES IMAGES JOINTES :
- la PREMIÈRE est la planche de concept du personnage, Aël. Dessine UNIQUEMENT sa troisième
  forme, « 2. Ascendant » (l'armure de cristal). Garde sa coiffure, son armure et ses couleurs,
  SAUF la teinte lavande de ses cheveux. Ne recopie NI sa mise en page, NI son fond violet, NI
  ses textes, NI ses cadres, NI ses lueurs.
- la DEUXIÈME est le MÊME garçon dans sa première forme, déjà validée : garde EXACTEMENT son
  visage, sa taille, ses proportions et la mise en page de ses trois cases. Il a seulement évolué.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — Aël l'Ascendant, le même jeune garçon HUMAIN, devenu un guerrier sûr de sa
force. Cheveux en épis ARGENTÉS, d'un argent froid teinté de bleu (#d8e4f0), yeux cyan
(#3fd8ff). Épaulières et brassards de CRISTAL bleu pâle (#a9dcff) bordés d'or (#e0b84a), sur
une tenue ajustée bleu nuit (#1e2a4a) à ceinture d'or. Courte cape blanche doublée de bleu, qui
s'arrête au milieu du dos. Bottes bleu nuit à renforts de cristal. Il tient de la main droite
une épée à LAME DE CRISTAL bleue, pointe vers le bas. Une gemme d'or est sertie sur sa
poitrine. Toutes ses formes sombres sont cernées d'un fin liseré clair, qui les détache des
sols sombres.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE ET LE MÊME CORPS QUE SUR LA DEUXIÈME IMAGE. Tête, tronc,
jambes et pieds ont les mêmes dimensions : l'armure s'ajoute sur lui, elle ne le grandit pas.
Toujours CHIBI, 2,5 TÊTES de haut. Les épaulières restent compactes.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT : la cape s'arrête au dos et ne les cache
jamais.

⚠️ RÈGLE BLOQUANTE — LA LUMIÈRE EST DANS LES COULEURS, PAS AUTOUR. Cristal et yeux sont clairs
et lumineux, mais sans halo, sans aura, sans particule ni étincelle.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUNE LAVANDE, AUCUN MAGENTA sur lui, ni reflet du
fond. L'argent de ses cheveux tire vers le bleu.

⚠️ RÈGLE BLOQUANTE — MÊME visage, tenue, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

## Image 8 — le déplacement

Joindre `assets/peso&cover/refonte/ael_ascendant.png` **puis** `docs/prompts/template/guide_heros.png`.
Déposer dans `assets/peso&cover/mages/ael_ascendant_marche.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son visage, sa coiffure, sa
tenue, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — Aël l'Ascendant, un jeune garçon HUMAIN, en proportions CHIBI : grosse tête,
corps court. Cheveux en épis ARGENTÉS, d'un argent froid teinté de bleu (#d8e4f0), yeux cyan
(#3fd8ff). Épaulières et brassards compacts de CRISTAL bleu pâle (#a9dcff) bordés d'or
(#e0b84a), tenue ajustée bleu nuit (#1e2a4a) à ceinture d'or, courte cape blanche doublée de
bleu qui s'arrête au milieu du dos, bottes bleu nuit à renforts de cristal. Une épée à LAME DE
CRISTAL bleue dans la main droite. Une gemme d'or sertie sur sa poitrine.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, il COURT vers le bas de l'image
- rangée 2 : vu DE DOS, il COURT vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE, il MARCHE d'un pas vif vers la droite

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE POSE. Elle a la même grille que la planche à
produire. Dans chaque case, recopie EXACTEMENT la position de ses pieds et de ses jambes, et
sur les rangées 1 et 2 celle de ses mains et de son épée (rouge : le bras et la jambe qui
tiennent l'épée ; bleu : les autres ; jaune : l'épée). Rien du guide ne doit apparaître : ni
le mannequin, ni ses couleurs, ni le corps gris, le bâton, la robe verte ou les bottes de la
rangée 3. C'est le personnage de la première image qui prend ces poses. ⚠️ Les têtes du guide
n'ont pas la même taille d'une rangée à l'autre : N'EN TIENS PAS COMPTE.

RANGÉES 1 ET 2, UNE COURSE ÉNERGIQUE À PAS MOYENS, en boucle :
1. contact : le pied rouge pose devant, le pied bleu pousse derrière
2. le pied rouge porte le poids, le genou bleu commence à monter
3. PASSAGE : le pied rouge sous le corps, le genou bleu monte
4. le pied bleu part devant, le pied rouge recule
5. l'INVERSE de l'image 1
6. le pied bleu porte le poids, le genou rouge commence à monter
7. PASSAGE : le pied bleu sous le corps, le genou rouge monte
8. le pied rouge part devant : l'image enchaîne sur la première
Les coudes sont pliés et les bras balancent franchement, en opposition aux jambes. L'épée
reste basse et suit le bras. Les pans de sa cape flottent derrière lui, en retard sur le corps. De face et de dos, les pieds restent sous le corps : l'un puis l'autre monte.

RANGÉE 3, DE PROFIL, UNE MARCHE DROITE, sans pencher et sans lever le genou :
1. jambes ouvertes, comme sur le guide : un pied devant, l'autre derrière
2. jambes ouvertes, comme sur le guide
3. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, un seul à peine levé
4. jambes ouvertes de nouveau, les pieds ont ÉCHANGÉ leur place
5. jambes ouvertes : l'INVERSE de l'image 1
6. jambes ouvertes : l'INVERSE de l'image 2
7. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, l'autre à peine levé
8. jambes ouvertes de nouveau : l'image enchaîne sur la première
Le bras gauche balance en opposition aux jambes, l'épée reste basse, la tenue suit le pas.

⚠️ RÈGLE BLOQUANTE — UN PIED TOUJOURS AU SOL. Il ne saute pas : aucune image où les deux pieds
sont en l'air. Ni grand écart, ni jambes en compas.

⚠️ RÈGLE BLOQUANTE — LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. De profil, aux images 3 et 7,
la largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5. Dans les
trois rangées, les images 5 à 8 ne répètent pas les images 1 à 4 : les jambes échangent leurs places.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. De profil, il n'est
ni plus fin, ni plus grand, et ses jambes ne sont pas plus longues que de face.

⚠️ RÈGLE BLOQUANTE — LA TÊTE NE BOUGE PAS D'UNE CASE À L'AUTRE. Dans une même rangée, elle se
superpose exactement, même taille, même place. C'est le JEU qui le fait avancer et rebondir : la
planche montre les membres, sur place, comme sur un tapis roulant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — LA LUMIÈRE EST DANS LES COULEURS, PAS AUTOUR : cristal, yeux et gemme sont clairs,
sans halo, sans aura, sans particule. AUCUNE LAVANDE : l'argent de ses cheveux tire vers le bleu.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS
LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune
poussière, aucun trait de vitesse. Les effets sont ajoutés par le jeu.
```

## Image 9 — l'attaque

Joindre `assets/peso&cover/refonte/ael_ascendant.png` **puis** `docs/prompts/template/guide_attaque.png`.
Déposer dans `assets/peso&cover/mages/ael_ascendant_attaque.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe montre le personnage : garde EXACTEMENT son visage, sa coiffure, sa tenue, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — Aël l'Ascendant, un jeune garçon HUMAIN, en proportions CHIBI : grosse tête,
corps court. Cheveux en épis ARGENTÉS, d'un argent froid teinté de bleu (#d8e4f0), yeux cyan
(#3fd8ff). Épaulières et brassards compacts de CRISTAL bleu pâle (#a9dcff) bordés d'or
(#e0b84a), tenue ajustée bleu nuit (#1e2a4a) à ceinture d'or, courte cape blanche doublée de
bleu qui s'arrête au milieu du dos, bottes bleu nuit à renforts de cristal. Une épée à LAME DE
CRISTAL bleue dans la main droite. Une gemme d'or sertie sur sa poitrine.

⚠️ MÊME TAILLE QUE SUR LA PREMIÈRE IMAGE JOINTE : la tête et le tronc ont les mêmes dimensions
dans les 24 cases. Un corps plus petit se verrait comme un rétrécissement à chaque coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face à nous : le coup vient VERS NOUS
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos : le coup s'éloigne de nous
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

⚠️ LA DEUXIÈME IMAGE JOINTE EST UN GUIDE DE POSE. Elle a la même grille que la planche à
produire. Dans chaque case, recopie EXACTEMENT la position de ses pieds, de sa main, de son
buste et l'angle de son épée. Rouge : le bras et la jambe qui tiennent l'épée. Bleu : les
autres. Jaune : l'épée. Le mannequin et ses couleurs ne doivent PAS apparaître : c'est le
personnage de la première image qui prend ces poses.

LES 8 COLONNES de chaque rangée sont UN SEUL COUP D'ÉPÉE, de gauche à droite, pas une boucle :
1. L'ÉLAN : il abaisse l'épée vers l'arrière, les épaules se tournent
2. ARMÉ : l'épée est levée au plus loin en arrière, le corps enroulé, tendu comme un ressort
3. LE DÉPART : la lame file par-dessus l'épaule, le buste commence à se dérouler
4. L'IMPACT : le bras est tendu, la lame devant lui, le buste jeté en avant
5. LA LAME FINIT SA COURSE : elle passe de l'autre côté, le buste reste penché
6. FIN DU GESTE : le bras est au bout de son mouvement, le corps est tenu
7. LE RETOUR : le bras se replie, le buste se redresse
8. il retrouve sa pose de marche, l'épée basse, la pointe vers le bas

Les images 2, 4 et 6 sont les POSES CLÉS : elles doivent se distinguer au premier regard par
leur seule silhouette, comme dans un jeu d'action.

⚠️ RÈGLE BLOQUANTE — LA TÊTE NE BOUGE PAS D'UNE CASE À L'AUTRE, et le corps reste CENTRÉ dans sa
case, sur la tête et les pieds, jamais sur l'ensemble du corps et de l'épée. C'est le jeu qui fait
la petite poussée vers l'avant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS NE BOUGENT PAS. Ils sont plantés aux mêmes endroits dans les 8 images
d'une rangée, et leur bas touche la même ligne horizontale dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — L'ÉPÉE PART DANS LA DIRECTION DE LA RANGÉE, et reste entière dans sa case. Elle
garde sa longueur : elle ne paraît plus courte que quand elle vient vers nous ou s'éloigne de nous.

⚠️ RÈGLE BLOQUANTE — AUCUN EFFET : aucun arc lumineux, aucune traînée, aucun flou, aucune étincelle,
aucune lueur ajoutée autour de la lame. Le jeu ajoute lui-même l'arc de lame, au bon moment et à la bonne couleur.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS LA
DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

## Image 10 — le portrait

Joindre `docs/prompts/ref/ref_carte.png`, **puis** `assets/peso&cover/interface/portraits/portrait_ael.png`, **puis**
`assets/peso&cover/refonte/ael_ascendant.png`. Déposer dans `assets/peso&cover/interface/portraits/portrait_ael_ascendant.png`.

```
Portrait vertical pour un écran de sélection de héros, illustration fantasy
manga soignée, détails riches et contours nets. Les images jointes donnent la
mise en page, le style et le visage du héros, puis sa tenue dans cette forme, dans cet ordre.

FORMAT : une image verticale au rapport 3:4, même cadrage et même échelle que le
portrait joint en deuxième.

SUJET — Aël l'Ascendant, le héros principal dans sa troisième forme : reprendre exactement le jeune
garçon HUMAIN du modèle, devenu un guerrier sûr de sa force. Cheveux argentés teintés de bleu,
yeux cyan lumineux. Épaulières et brassards de cristal bleu pâle bordés d'or, tenue bleu nuit,
courte cape blanche doublée de bleu, épée à lame de cristal bleue dans la main droite, gemme
d'or sur la poitrine. Des reflets bleus courent sur le cristal.

Il est entier, debout, de face légèrement de trois quarts, et regarde le joueur ; ses bottes
sont visibles. Même visage, même âge et même taille que sur le portrait joint en deuxième.

FOND : nappe bleu nuit au centre, noir profond vers les bords, avec une lueur bleue et or derrière lui. Aucun décor.

RÈGLES : personnage centré, environ 80 % de la hauteur ; aucun cadre, bordure, texte, nom,
chiffre, logo, sol, ombre portée ni autre personnage. Aucun rose, aucun violet, aucune lavande.
```

## Image 11 — les icônes

Rien à joindre. Déposer dans `assets/peso&cover/sorts/mage_ael_ascendant_skills.png`.

```
Planche de six icônes de sorts pour un jeu de rôle mobile, style fantasy manga,
contours nets et formes lisibles en petit. Ces symboles appartiennent à Aël l'Ascendant, un jeune héros à l'épée qui a éveillé la lumière des gemmes.

FORMAT exact : image 1536 x 1024 pixels, grille régulière de 3 colonnes x 2
rangées, six cases de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne
de grille, cadre, numéro ou texte. Une icône centrée par case, environ 70 % de la
case, avec une marge magenta généreuse et sans débordement.

Palette STRICTE : bleu cristal (#a9dcff), bleu vif (#3fd8ff), bleu nuit (#1e2a4a), or (#e0b84a) et blanc. AUCUN rose, AUCUN violet, AUCUN magenta, AUCUN arc-en-ciel
dans les dessins. Les éclats sont des aplats nets, sans halo flou. Les icônes sont des
symboles, sans personnage ni visage.

Dans l'ordre de lecture :
1. DOUBLE COUP — deux lames de cristal bleu qui se croisent en X, chacune suivie d'un trait net.
2. PLUIE D'ÉCLATS — une averse d'éclats de cristal bleu qui tombent en diagonale sur un cercle au sol.
3. CRISTAL SENTINELLE — un grand cristal bleu planté au sol, cerclé d'or, d'où part un petit tir droit.
4. ONDE PRISMATIQUE — un trait de lumière bleue qui saute en zigzag entre trois points d'or.
5. AILES DE LUMIÈRE — deux ailes stylisées faites de plumes de cristal bleu et blanc, déployées.
6. TRANSFORMATION — une gemme d'or au centre, entourée de huit éclats de cristal qui jaillissent en étoile, et des cheveux dressés stylisés au-dessus. C'est l'icône la plus spectaculaire.

Pas de décor, arrière-plan illustré, ombre, flou, cadre, texte ni personnage.
Le magenta du fond ne doit pas se refléter dans les icônes.
```

---

# Aël en forme Prisme (niveau 30, transformation en combat)

## Image 12 — le modèle

Joindre `assets/peso&cover/refonte/ael_concept.png` **puis** `assets/peso&cover/refonte/ael_apprenti.png`.
Déposer dans `assets/peso&cover/refonte/ael_prisme.png`.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.

LES IMAGES JOINTES :
- la PREMIÈRE est la planche de concept du personnage, Aël. Dessine UNIQUEMENT sa forme finale,
  « 3. Prisme » (les cheveux dressés blanc et or). Garde sa coiffure, son armure et ses couleurs.
  Ne recopie NI sa mise en page, NI son fond violet, NI ses textes, NI ses cadres, et SURTOUT NI
  son halo, NI les cristaux qui flottent autour de lui, NI ses étincelles.
- la DEUXIÈME est le MÊME garçon dans sa première forme, déjà validée : garde EXACTEMENT son
  visage, sa taille, ses proportions et la mise en page de ses trois cases. Il s'est transformé.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — Aël en forme Prisme, sa transformation finale, le même jeune garçon HUMAIN, au
sommet de sa puissance, regard intense. Cheveux en épis DRESSÉS VERS LE HAUT, blancs aux pointes
dorées (#fff4c8 et #f2c94c), yeux d'or. Armure légère blanche (#f6f3ea) bordée d'or et de
cristal clair, épaulières compactes, tenue blanche, ceinture d'or, bottes blanches et or. Il
tient de la main droite une épée à LAME DE LUMIÈRE dorée, pointe vers le bas. Une gemme d'or
éclatante est sertie sur sa poitrine. Toutes ses formes claires sont cernées d'un contour brun
doré net, qui les détache des sols clairs.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE ET LE MÊME CORPS QUE SUR LA DEUXIÈME IMAGE. Tête, tronc,
jambes et pieds ont les mêmes dimensions ; seuls les cheveux dressés dépassent un peu au-dessus.
Toujours CHIBI, 2,5 TÊTES de haut.

⚠️ RÈGLE BLOQUANTE — RIEN NE FLOTTE AUTOUR DE LUI. Aucun halo, aucune aura, aucun cristal
détaché, aucune particule, aucune étincelle : le jeu ajoutera lui-même son aura, en mouvement.
La lumière est seulement dans les couleurs de ses cheveux, de sa lame et de sa gemme.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT : rien ne les cache.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond.

⚠️ RÈGLE BLOQUANTE — MÊME visage, tenue, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

## Image 13 — le déplacement

Joindre `assets/peso&cover/refonte/ael_prisme.png` **puis** `docs/prompts/template/guide_heros.png`.
Déposer dans `assets/peso&cover/mages/ael_prisme_marche.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son visage, sa coiffure, sa
tenue, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — Aël en forme Prisme, sa transformation finale, un jeune garçon HUMAIN, en
proportions CHIBI : grosse tête, corps court. Cheveux en épis DRESSÉS VERS LE HAUT, blancs aux
pointes dorées (#fff4c8 et #f2c94c), yeux d'or. Armure légère blanche (#f6f3ea) bordée d'or et
de cristal clair, épaulières compactes, ceinture d'or, bottes blanches et or. Une épée à LAME DE
LUMIÈRE dorée dans la main droite. Une gemme d'or éclatante sertie sur sa poitrine.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, il COURT vers le bas de l'image
- rangée 2 : vu DE DOS, il COURT vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE, il MARCHE d'un pas vif vers la droite

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE POSE. Elle a la même grille que la planche à
produire. Dans chaque case, recopie EXACTEMENT la position de ses pieds et de ses jambes, et
sur les rangées 1 et 2 celle de ses mains et de son épée (rouge : le bras et la jambe qui
tiennent l'épée ; bleu : les autres ; jaune : l'épée). Rien du guide ne doit apparaître : ni
le mannequin, ni ses couleurs, ni le corps gris, le bâton, la robe verte ou les bottes de la
rangée 3. C'est le personnage de la première image qui prend ces poses. ⚠️ Les têtes du guide
n'ont pas la même taille d'une rangée à l'autre : N'EN TIENS PAS COMPTE.

RANGÉES 1 ET 2, UNE COURSE ÉNERGIQUE À PAS MOYENS, en boucle :
1. contact : le pied rouge pose devant, le pied bleu pousse derrière
2. le pied rouge porte le poids, le genou bleu commence à monter
3. PASSAGE : le pied rouge sous le corps, le genou bleu monte
4. le pied bleu part devant, le pied rouge recule
5. l'INVERSE de l'image 1
6. le pied bleu porte le poids, le genou rouge commence à monter
7. PASSAGE : le pied bleu sous le corps, le genou rouge monte
8. le pied rouge part devant : l'image enchaîne sur la première
Les coudes sont pliés et les bras balancent franchement, en opposition aux jambes. L'épée
reste basse et suit le bras. Ses cheveux dressés ne bougent presque pas, et rien ne flotte derrière lui. De face et de dos, les pieds restent sous le corps : l'un puis l'autre monte.

RANGÉE 3, DE PROFIL, UNE MARCHE DROITE, sans pencher et sans lever le genou :
1. jambes ouvertes, comme sur le guide : un pied devant, l'autre derrière
2. jambes ouvertes, comme sur le guide
3. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, un seul à peine levé
4. jambes ouvertes de nouveau, les pieds ont ÉCHANGÉ leur place
5. jambes ouvertes : l'INVERSE de l'image 1
6. jambes ouvertes : l'INVERSE de l'image 2
7. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, l'autre à peine levé
8. jambes ouvertes de nouveau : l'image enchaîne sur la première
Le bras gauche balance en opposition aux jambes, l'épée reste basse, la tenue suit le pas.

⚠️ RÈGLE BLOQUANTE — UN PIED TOUJOURS AU SOL. Il ne saute pas : aucune image où les deux pieds
sont en l'air. Ni grand écart, ni jambes en compas.

⚠️ RÈGLE BLOQUANTE — LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. De profil, aux images 3 et 7,
la largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5. Dans les
trois rangées, les images 5 à 8 ne répètent pas les images 1 à 4 : les jambes échangent leurs places.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. De profil, il n'est
ni plus fin, ni plus grand, et ses jambes ne sont pas plus longues que de face.

⚠️ RÈGLE BLOQUANTE — LA TÊTE NE BOUGE PAS D'UNE CASE À L'AUTRE. Dans une même rangée, elle se
superpose exactement, même taille, même place. C'est le JEU qui le fait avancer et rebondir : la
planche montre les membres, sur place, comme sur un tapis roulant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — RIEN NE FLOTTE AUTOUR DE LUI : aucun halo, aucune aura, aucun cristal détaché, aucune
particule, aucune étincelle. Le jeu ajoute lui-même son aura, en mouvement. La lumière est seulement dans
les couleurs de ses cheveux, de sa lame et de sa gemme.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS
LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune
poussière, aucun trait de vitesse. Les effets sont ajoutés par le jeu.
```

## Image 14 — l'attaque

Joindre `assets/peso&cover/refonte/ael_prisme.png` **puis** `docs/prompts/template/guide_attaque.png`.
Déposer dans `assets/peso&cover/mages/ael_prisme_attaque.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe montre le personnage : garde EXACTEMENT son visage, sa coiffure, sa tenue, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — Aël en forme Prisme, sa transformation finale, un jeune garçon HUMAIN, en
proportions CHIBI : grosse tête, corps court. Cheveux en épis DRESSÉS VERS LE HAUT, blancs aux
pointes dorées (#fff4c8 et #f2c94c), yeux d'or. Armure légère blanche (#f6f3ea) bordée d'or et
de cristal clair, épaulières compactes, ceinture d'or, bottes blanches et or. Une épée à LAME DE
LUMIÈRE dorée dans la main droite. Une gemme d'or éclatante sertie sur sa poitrine.

⚠️ MÊME TAILLE QUE SUR LA PREMIÈRE IMAGE JOINTE : la tête et le tronc ont les mêmes dimensions
dans les 24 cases. Un corps plus petit se verrait comme un rétrécissement à chaque coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face à nous : le coup vient VERS NOUS
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos : le coup s'éloigne de nous
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

⚠️ LA DEUXIÈME IMAGE JOINTE EST UN GUIDE DE POSE. Elle a la même grille que la planche à
produire. Dans chaque case, recopie EXACTEMENT la position de ses pieds, de sa main, de son
buste et l'angle de son épée. Rouge : le bras et la jambe qui tiennent l'épée. Bleu : les
autres. Jaune : l'épée. Le mannequin et ses couleurs ne doivent PAS apparaître : c'est le
personnage de la première image qui prend ces poses.

LES 8 COLONNES de chaque rangée sont UN SEUL COUP D'ÉPÉE, de gauche à droite, pas une boucle :
1. L'ÉLAN : il abaisse l'épée vers l'arrière, les épaules se tournent
2. ARMÉ : l'épée est levée au plus loin en arrière, le corps enroulé, tendu comme un ressort
3. LE DÉPART : la lame file par-dessus l'épaule, le buste commence à se dérouler
4. L'IMPACT : le bras est tendu, la lame devant lui, le buste jeté en avant
5. LA LAME FINIT SA COURSE : elle passe de l'autre côté, le buste reste penché
6. FIN DU GESTE : le bras est au bout de son mouvement, le corps est tenu
7. LE RETOUR : le bras se replie, le buste se redresse
8. il retrouve sa pose de marche, l'épée basse, la pointe vers le bas

Les images 2, 4 et 6 sont les POSES CLÉS : elles doivent se distinguer au premier regard par
leur seule silhouette, comme dans un jeu d'action.

⚠️ RÈGLE BLOQUANTE — LA TÊTE NE BOUGE PAS D'UNE CASE À L'AUTRE, et le corps reste CENTRÉ dans sa
case, sur la tête et les pieds, jamais sur l'ensemble du corps et de l'épée. C'est le jeu qui fait
la petite poussée vers l'avant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS NE BOUGENT PAS. Ils sont plantés aux mêmes endroits dans les 8 images
d'une rangée, et leur bas touche la même ligne horizontale dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — L'ÉPÉE PART DANS LA DIRECTION DE LA RANGÉE, et reste entière dans sa case. Elle
garde sa longueur : elle ne paraît plus courte que quand elle vient vers nous ou s'éloigne de nous.

⚠️ RÈGLE BLOQUANTE — AUCUN EFFET : aucun arc lumineux, aucune traînée, aucun flou, aucune étincelle,
aucune lueur ajoutée autour de la lame. Le jeu ajoute lui-même l'arc de lame, au bon moment et à la bonne couleur.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS LA
DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

## Image 15 — le portrait

Joindre `docs/prompts/ref/ref_carte.png`, **puis** `assets/peso&cover/interface/portraits/portrait_ael.png`, **puis**
`assets/peso&cover/refonte/ael_prisme.png`. Déposer dans `assets/peso&cover/interface/portraits/portrait_ael_prisme.png`.

```
Portrait vertical pour un écran de sélection de héros, illustration fantasy
manga soignée, détails riches et contours nets. Les images jointes donnent la
mise en page, le style et le visage du héros, puis sa tenue dans cette forme, dans cet ordre.

FORMAT : une image verticale au rapport 3:4, même cadrage et même échelle que le
portrait joint en deuxième.

SUJET — Aël en forme Prisme, la transformation finale du héros principal : reprendre exactement le
jeune garçon HUMAIN du modèle, au sommet de sa puissance, regard intense. Cheveux en épis dressés
vers le haut, blancs aux pointes dorées, lumineux, yeux d'or. Armure légère blanche et or bordée
de cristal, épée à lame de lumière dorée dans la main droite, gemme d'or éclatante sur la
poitrine. Ici SEULEMENT, une aura blanche et dorée l'entoure, et quelques éclats de cristal
flottent autour de lui.

Il est entier, debout, de face légèrement de trois quarts, et regarde le joueur ; ses bottes
sont visibles. Même visage, même âge et même taille que sur le portrait joint en deuxième.

FOND : nappe bleu nuit au centre, noir profond vers les bords, avec une grande lueur blanche et dorée derrière lui. Aucun décor.

RÈGLES : personnage centré, environ 80 % de la hauteur ; aucun cadre, bordure, texte, nom,
chiffre, logo, sol, ombre portée ni autre personnage. Aucun rose, aucun violet, aucune lavande.
```

## Image 16 — les icônes

Rien à joindre. Déposer dans `assets/peso&cover/sorts/mage_ael_prisme_skills.png`.

```
Planche de six icônes de sorts pour un jeu de rôle mobile, style fantasy manga,
contours nets et formes lisibles en petit. Ces symboles appartiennent à Aël en forme Prisme, un jeune héros à l'épée qui a éveillé la lumière des gemmes.

FORMAT exact : image 1536 x 1024 pixels, grille régulière de 3 colonnes x 2
rangées, six cases de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne
de grille, cadre, numéro ou texte. Une icône centrée par case, environ 70 % de la
case, avec une marge magenta généreuse et sans débordement.

Palette STRICTE : blanc (#f6f3ea), or pâle (#fff4c8), or (#f2c94c) et cyan pâle (#bff3ff). AUCUN rose, AUCUN violet, AUCUN magenta, AUCUN arc-en-ciel
dans les dessins. Les éclats sont des aplats nets, sans halo flou. Les icônes sont des
symboles, sans personnage ni visage.

Dans l'ordre de lecture :
1. RAFALE DE LUMIÈRE — trois traits de lumière dorée, parallèles, qui filent vers le haut à droite.
2. COMÈTE — une comète blanche et or qui fonce en diagonale et éclate en étoile à son point d'impact.
3. BARRIÈRE D'AURA — une sphère de lumière blanche et or, aux bords nets, autour d'une petite gemme.
4. ÉCLATS EN ORBITE — quatre éclats de cristal blanc et or en cercle, reliés par un anneau de rotation.
5. TRANSMISSION — deux silhouettes en pointillés d'or, l'une qui s'efface, l'autre qui apparaît derrière une flèche courbe.
6. PRISME ULTIME — un immense rayon blanc et or qui traverse toute la case, né d'une gemme qui éclate. C'est l'icône la plus spectaculaire.

Pas de décor, arrière-plan illustré, ombre, flou, cadre, texte ni personnage.
Le magenta du fond ne doit pas se refléter dans les icônes.
```
