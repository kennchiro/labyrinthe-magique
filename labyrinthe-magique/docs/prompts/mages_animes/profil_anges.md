# Les anges — rattraper une marche de profil

⚠️ **À n'utiliser qu'en secours, et après la refonte du sprite** : la nouvelle planche de marche (fiche
de chaque ange) demande déjà la bonne foulée. Cette page ne sert que si son profil glisse encore : ses
pieds gardent le même écart sur les 8 images, alors que ceux des mages se rejoignent aux images 3
et 7. `tools/build_enemies.py` prend le fichier `<id>_profil.png` à la place de la rangée de profil de
`<id>_marche.png`, sans toucher à cette planche.

Le guide `guide_profil.png` vient de la marche du Chronomancien : ses jambes sont gardées, le haut de
son corps est peint en gris. **À regarder sur l'image reçue : les images 3 et 7 doivent montrer des
jambes jointes.** Si elles restent écartées, regénérer avant de déposer.

---

## Porte-Lumière

Joindre `assets/peso&cover/refonte/lumiere.png` et `docs/prompts/mages_animes/guide_profil.png`.
Déposer le résultat dans `assets/peso&cover/mages/lumiere_profil.png`.

```
Bande de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à contours
nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image jointe montre le
personnage : garde EXACTEMENT ses couleurs, ses vêtements et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 256 pixels
- UNE SEULE rangée de 8 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Porte-Lumière, un ange. Deux GRANDES AILES de plumes blanches, à demi repliées dans son
dos. Une AURÉOLE d'or plate flotte au-dessus de sa tête. Courts cheveux blonds, visage
serein bien visible, armure légère blanc ivoire à liserés d'or sur une tunique blanche,
bottes d'or. Il tient de la main droite une LANCE dorée, surmontée d'une pointe de cristal
blanc lumineux. Toutes ses formes blanches sont cernées d'un contour BRUN FONCÉ net.
MORPHOLOGIE CHIBI, celle des mages : sa hauteur totale vaut 2,5 TÊTES, la tête (coiffure ou
casque compris) occupe près de 40 % de la hauteur, et les jambes à peine un quart. Grosses
mains, gros pieds, torse court, jamais de corps élancé ni de petite tête. Silhouette lisible
en très petit. L'aura reste COLLÉE au corps : pas de halo large, pas de nuage de particules
autour.

Il est vu DE PROFIL, TOURNÉ VERS LA DROITE, dans les 8 cases, et il marche sur place.
SES JAMBES : la tunique courte s'ouvre et ses bottes d'or sortent franchement à chaque pas. DE PROFIL, les jambes ne gardent jamais la même pose : aux images 3 et 7, elles sont JOINTES, les deux pieds l'un sur l'autre, sur moins de la moitié de la largeur des images 1 et 5.
SES MAINS : la lance reste dans sa main droite, tenue droite, et les ailes restent à demi repliées dans son dos, sans battre.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à produire.
Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS. Le corps gris du
guide et ses bottes ne doivent PAS apparaître : c'est le personnage de la première image qui prend
ces poses, avec ses propres jambes.

LES 8 IMAGES, de gauche à droite :
1. jambes GRANDES OUVERTES : un pied loin devant, l'autre loin derrière
2. jambes encore ouvertes, les pieds se rapprochent
3. ⚠️ JAMBES JOINTES : les deux pieds L'UN SUR L'AUTRE, sous le corps, un seul pied levé
4. jambes ouvertes de nouveau, les pieds ont ÉCHANGÉ leur place
5. jambes GRANDES OUVERTES, l'INVERSE de l'image 1
6. jambes encore ouvertes, les pieds se rapprochent
7. ⚠️ JAMBES JOINTES : les deux pieds L'UN SUR L'AUTRE, sous le corps, l'autre pied levé
8. jambes ouvertes de nouveau : l'image enchaîne sur la première

⚠️ RÈGLE BLOQUANTE — C'EST LE DÉFAUT À CORRIGER : LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. Aux
images 3 et 7, la largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5.
Un personnage aux jambes écartées sur les 8 images est faux, même si ses pieds bougent un peu.

⚠️ RÈGLE BLOQUANTE — SEULES LES JAMBES BOUGENT. Le tronc, la tête, les ailes et ce qu'il tient se
superposent exactement d'une case à l'autre, à la même taille, et il regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne horizontale
dans les 8 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun effet ni aucune particule, aucun reflet
du fond magenta.
```

---

## Ange de la Mort

Joindre `assets/peso&cover/refonte/mort.png` et `docs/prompts/mages_animes/guide_profil.png`.
Déposer le résultat dans `assets/peso&cover/mages/mort_profil.png`.

```
Bande de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à contours
nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image jointe montre le
personnage : garde EXACTEMENT ses couleurs, ses vêtements et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 256 pixels
- UNE SEULE rangée de 8 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Ange de la Mort, un ange déchu à l'allure un peu démoniaque. Deux GRANDES AILES de plumes
noires, déchirées et effilochées au bout, à demi repliées dans son dos. Deux PETITES CORNES
noires courbes sortent de son front, et une AURÉOLE BRISÉE rouge braise, ouverte comme un
anneau fendu, flotte au-dessus de sa tête. Visage pâle couleur d'os, bien visible, aux yeux
rouge braise, et cheveux noirs mi-longs. Armure sombre gris anthracite à liserés couleur
d'os, sur une longue robe noire déchirée au bas, bottes noires griffues. Il tient de la main
droite une grande FAUX au manche d'os, dont la lame noire est bordée de rouge braise. Toutes
ses formes noires sont cernées d'un fin liseré CLAIR couleur d'os, qui les détache des sols
sombres. MORPHOLOGIE CHIBI, celle des mages : sa hauteur totale vaut 2,5 TÊTES, la tête
(coiffure ou casque compris) occupe près de 40 % de la hauteur, et les jambes à peine un
quart. Grosses mains, gros pieds, torse court, jamais de corps élancé ni de petite tête.
Silhouette lisible en très petit. L'aura reste COLLÉE au corps : pas de halo large, pas de
nuage de particules autour.

Il est vu DE PROFIL, TOURNÉ VERS LA DROITE, dans les 8 cases, et il marche sur place.
SES JAMBES : la robe déchirée s'ouvre devant et ses bottes griffues sortent franchement à chaque pas. DE PROFIL, les jambes ne gardent jamais la même pose : aux images 3 et 7, elles sont JOINTES, les deux pieds l'un sur l'autre, sur moins de la moitié de la largeur des images 1 et 5.
SES MAINS : la faux reste dans sa main droite, tenue droite, lame en haut, et les ailes restent à demi repliées dans son dos, sans battre.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à produire.
Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS. Le corps gris du
guide et ses bottes ne doivent PAS apparaître : c'est le personnage de la première image qui prend
ces poses, avec ses propres jambes.

LES 8 IMAGES, de gauche à droite :
1. jambes GRANDES OUVERTES : un pied loin devant, l'autre loin derrière
2. jambes encore ouvertes, les pieds se rapprochent
3. ⚠️ JAMBES JOINTES : les deux pieds L'UN SUR L'AUTRE, sous le corps, un seul pied levé
4. jambes ouvertes de nouveau, les pieds ont ÉCHANGÉ leur place
5. jambes GRANDES OUVERTES, l'INVERSE de l'image 1
6. jambes encore ouvertes, les pieds se rapprochent
7. ⚠️ JAMBES JOINTES : les deux pieds L'UN SUR L'AUTRE, sous le corps, l'autre pied levé
8. jambes ouvertes de nouveau : l'image enchaîne sur la première

⚠️ RÈGLE BLOQUANTE — C'EST LE DÉFAUT À CORRIGER : LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. Aux
images 3 et 7, la largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5.
Un personnage aux jambes écartées sur les 8 images est faux, même si ses pieds bougent un peu.

⚠️ RÈGLE BLOQUANTE — SEULES LES JAMBES BOUGENT. Le tronc, la tête, les ailes et ce qu'il tient se
superposent exactement d'une case à l'autre, à la même taille, et il regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne horizontale
dans les 8 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun effet ni aucune particule, aucun reflet
du fond magenta.
```

---

## Ange des Étoiles

Joindre `assets/peso&cover/refonte/etoiles.png` et `docs/prompts/mages_animes/guide_profil.png`.
Déposer le résultat dans `assets/peso&cover/mages/etoiles_profil.png`.

```
Bande de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à contours
nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image jointe montre le
personnage : garde EXACTEMENT ses couleurs, ses vêtements et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 256 pixels
- UNE SEULE rangée de 8 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Ange des Étoiles, une femme adulte, un ange au visage calme et bien visible. Deux GRANDES
AILES de plumes bleu nuit, semées de petits points blancs comme un ciel étoilé, à demi
repliées dans son dos. Une COURONNE EN CROISSANT DE LUNE argentée flotte au-dessus de sa
tête. Longs cheveux argentés attachés en une tresse qui tombe dans son dos. Longue robe bleu
nuit à manches longues, sobre et couvrante, à liserés d'argent, fendue sur le côté, sur des
bottines argentées. Elle tient de la main droite un fin SCEPTRE d'argent, surmonté d'une
étoile blanche à quatre branches. Toutes ses formes sombres sont cernées d'un fin liseré
ARGENTÉ, qui les détache des sols sombres. MORPHOLOGIE CHIBI, celle des mages : sa hauteur
totale vaut 2,5 TÊTES, la tête (coiffure ou casque compris) occupe près de 40 % de la
hauteur, et les jambes à peine un quart. Grosses mains, gros pieds, torse court, jamais de
corps élancé ni de petite tête. Silhouette lisible en très petit. L'aura reste COLLÉE au
corps : pas de halo large, pas de nuage de particules autour.

Il est vu DE PROFIL, TOURNÉ VERS LA DROITE, dans les 8 cases, et il marche sur place.
SES JAMBES : la robe s'ouvre par sa fente et ses bottines argentées sortent franchement à chaque pas. DE PROFIL, les jambes ne gardent jamais la même pose : aux images 3 et 7, elles sont JOINTES, les deux pieds l'un sur l'autre, sur moins de la moitié de la largeur des images 1 et 5.
SES MAINS : le sceptre reste dans sa main droite, tenu droit, et les ailes restent à demi repliées dans son dos, sans battre.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à produire.
Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS. Le corps gris du
guide et ses bottes ne doivent PAS apparaître : c'est le personnage de la première image qui prend
ces poses, avec ses propres jambes.

LES 8 IMAGES, de gauche à droite :
1. jambes GRANDES OUVERTES : un pied loin devant, l'autre loin derrière
2. jambes encore ouvertes, les pieds se rapprochent
3. ⚠️ JAMBES JOINTES : les deux pieds L'UN SUR L'AUTRE, sous le corps, un seul pied levé
4. jambes ouvertes de nouveau, les pieds ont ÉCHANGÉ leur place
5. jambes GRANDES OUVERTES, l'INVERSE de l'image 1
6. jambes encore ouvertes, les pieds se rapprochent
7. ⚠️ JAMBES JOINTES : les deux pieds L'UN SUR L'AUTRE, sous le corps, l'autre pied levé
8. jambes ouvertes de nouveau : l'image enchaîne sur la première

⚠️ RÈGLE BLOQUANTE — C'EST LE DÉFAUT À CORRIGER : LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. Aux
images 3 et 7, la largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5.
Un personnage aux jambes écartées sur les 8 images est faux, même si ses pieds bougent un peu.

⚠️ RÈGLE BLOQUANTE — SEULES LES JAMBES BOUGENT. Le tronc, la tête, les ailes et ce qu'il tient se
superposent exactement d'une case à l'autre, à la même taille, et il regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne horizontale
dans les 8 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun effet ni aucune particule, aucun reflet
du fond magenta.
```

---

## Archange d'Acier

Joindre `assets/peso&cover/refonte/acier.png` et `docs/prompts/mages_animes/guide_profil.png`.
Déposer le résultat dans `assets/peso&cover/mages/acier_profil.png`.

```
Bande de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à contours
nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image jointe montre le
personnage : garde EXACTEMENT ses couleurs, ses vêtements et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 256 pixels
- UNE SEULE rangée de 8 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Archange d'Acier, un ange guerrier MASSIF et COSTAUD, très large d'épaules, en ARMURE DE
PLATES INTÉGRALE gris-bleu, faite de grandes plaques épaisses bien visibles : énormes
épaulières, plastron bombé, gantelets et grosses bottes de métal. HEAUME FERMÉ : aucun
visage, seulement une fente horizontale d'où sort une lueur orange. De fines fentes orange,
couleur de métal chauffé, courent entre les plaques du plastron. Deux GRANDES AILES faites
entièrement de LAMES D'ACIER superposées, sans aucune plume, à demi repliées dans son dos.
Il porte de la main droite un grand MARTEAU DE GUERRE, à la tête d'acier massive et au
manche épais. Ses plaques sombres sont cernées d'un fin liseré GRIS CLAIR, qui les détache
des sols sombres. MORPHOLOGIE CHIBI, celle des mages : sa hauteur totale vaut 2,5 TÊTES, la
tête (coiffure ou casque compris) occupe près de 40 % de la hauteur, et les jambes à peine
un quart. Grosses mains, gros pieds, torse court, jamais de corps élancé ni de petite tête.
Silhouette lisible en très petit. L'aura reste COLLÉE au corps : pas de halo large, pas de
nuage de particules autour.

Il est vu DE PROFIL, TOURNÉ VERS LA DROITE, dans les 8 cases, et il marche sur place.
SES JAMBES : ses jambes blindées et ses grosses bottes de métal se lèvent franchement à chaque pas, d'une démarche lourde. DE PROFIL, les jambes ne gardent jamais la même pose : aux images 3 et 7, elles sont JOINTES, les deux pieds l'un sur l'autre, sur moins de la moitié de la largeur des images 1 et 5.
SES MAINS : le marteau reste dans sa main droite, posé sur l'épaule, et les ailes de lames restent à demi repliées dans son dos, sans battre.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à produire.
Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS. Le corps gris du
guide et ses bottes ne doivent PAS apparaître : c'est le personnage de la première image qui prend
ces poses, avec ses propres jambes.

LES 8 IMAGES, de gauche à droite :
1. jambes GRANDES OUVERTES : un pied loin devant, l'autre loin derrière
2. jambes encore ouvertes, les pieds se rapprochent
3. ⚠️ JAMBES JOINTES : les deux pieds L'UN SUR L'AUTRE, sous le corps, un seul pied levé
4. jambes ouvertes de nouveau, les pieds ont ÉCHANGÉ leur place
5. jambes GRANDES OUVERTES, l'INVERSE de l'image 1
6. jambes encore ouvertes, les pieds se rapprochent
7. ⚠️ JAMBES JOINTES : les deux pieds L'UN SUR L'AUTRE, sous le corps, l'autre pied levé
8. jambes ouvertes de nouveau : l'image enchaîne sur la première

⚠️ RÈGLE BLOQUANTE — C'EST LE DÉFAUT À CORRIGER : LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. Aux
images 3 et 7, la largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5.
Un personnage aux jambes écartées sur les 8 images est faux, même si ses pieds bougent un peu.

⚠️ RÈGLE BLOQUANTE — SEULES LES JAMBES BOUGENT. Le tronc, la tête, les ailes et ce qu'il tient se
superposent exactement d'une case à l'autre, à la même taille, et il regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne horizontale
dans les 8 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun effet ni aucune particule, aucun reflet
du fond magenta.
```
