# L'Archange du Ciel — planches de marche et d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/ciel.png`
au générateur, pour qu'il garde le même personnage. Pour la marche, joindre AUSSI
`docs/prompts/mages_animes/guide_complet.png`, qui porte les jambes du Chronomancien,
la marche de référence.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/ciel_marche.png
    assets/peso&cover/mages/ciel_attaque.png

La gauche n'est PAS demandée : le jeu retourne le profil droit. La planche de marche se
commande entière : [une bande de profil générée à part sort plus fine que la face](marche_chronomancien.md).

---

## Prompt 1 — la marche

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son visage, ses couleurs, son
armure et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Archange du Ciel, un jeune archange au visage bien visible, aux yeux
émeraude, en proportions CHIBI : grosse tête, corps court. Cheveux blancs courts, DIADÈME
D'OR à deux petites ailes dorées. Armure légère blanche à bords dorés, petites épaulières
dorées, TABARD COURT émeraude à liseré d'or qui s'arrête au-dessus des genoux. Deux grandes
ailes de plumes BLANCHES aux pointes émeraude, REPLIÉES dans son dos. Une LANCE D'OR à pointe
blanche dans la main droite, tenue droite, pointe en l'air. Une petite cloche d'or à la
ceinture. Un contour vert très sombre cerne ses formes claires. Pas de cape, pas d'auréole.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. C'est le même personnage vu sous
trois angles. Sa tête a EXACTEMENT la même hauteur et la même largeur dans les 24 cases : elle
n'est pas plus petite de profil. De profil, il n'est ni plus fin, ni plus grand, ni plus élancé,
et ses jambes ne sont pas plus longues que de face. Sa hauteur totale est la même dans les 24 cases.

Il MARCHE tranquillement sur place, d'un pas léger. IL NE COURT PAS : le buste reste DROIT, sans
pencher en avant, et les genoux restent bas. Les ailes restent repliées, sans battre.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps.
- LE BRAS LIBRE (le gauche, poing fermé) balance en grand, de l'avant vers l'arrière ;
- LE BRAS DE LA LANCE (le droit) balance AUSSI, moins loin : la main avance et recule en
  emportant la lance, qui reste VERTICALE, pointe en l'air, et ne fait que glisser vers l'avant
  ou l'arrière avec la main, sans jamais se coucher ni passer devant le visage ;
- la cloche de la ceinture se balance un peu, en retard sur les hanches.

LE BALANCEMENT DES BRAS, image par image, calé sur les jambes du guide :
1. bras libre tendu vers l'AVANT, poing à hauteur de taille ; main de la lance vers l'ARRIÈRE
2. bras libre qui redescend, coude un peu plié ; main de la lance qui revient
3. les deux bras le long du corps, POINT DE PASSAGE (c'est l'image aux jambes jointes)
4. bras libre qui part vers l'arrière ; main de la lance qui part vers l'avant
5. l'INVERSE de l'image 1 : bras libre vers l'ARRIÈRE, main de la lance vers l'AVANT
6. main de la lance qui revient ; bras libre qui revient
7. les deux bras le long du corps, POINT DE PASSAGE (jambes jointes)
8. bras libre qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui avance
grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté du corps.
DE PROFIL, la lance reste devant le corps, et la main qui la tient avance et recule le long de
lui.

⚠️ AUCUNE MAGIE : ni lueur, ni aura, ni plume qui vole, ni particule.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, avec ses
bottes blanches et dorées.

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
trois rangées, les images 5 à 8 ne répètent pas les images 1 à 4 : les deux jambes échangent
leurs places.

⚠️ RÈGLE BLOQUANTE — LES BRAS NE SONT JAMAIS FIGÉS. D'une image à la suivante, l'avant-bras et
la main changent de position, et les images 1 et 5 montrent les bras inversés. Deux images
voisines identiques pour les bras sont une erreur. La lance bouge AVEC sa main, toujours droite.

⚠️ RÈGLE BLOQUANTE — LE TABARD NE CACHE JAMAIS LES JAMBES. Il s'arrête au-dessus des genoux et
s'ouvre entre elles : les deux bottes se voient dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LA LANCE ET LA CLOCHE BOUGENT. Dans une même
rangée, la tête, le tronc et les ailes se superposent exactement d'une case à l'autre, et le
profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES AILES ET LA LANCE TIENNENT DANS LA CASE. Les ailes ne dépassent pas de plus
d'un quart de la largeur du corps de chaque côté, et la pointe de la lance ne sort jamais de la case.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui : le blanc reste blanc, ombré de gris-vert.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune poussière.
```

---

## Prompt 2 — l'attaque

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le personnage : garde EXACTEMENT son visage, ses couleurs,
son armure et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Archange du Ciel, un jeune archange au visage bien visible, aux yeux
émeraude, en proportions CHIBI : grosse tête, corps court. Cheveux blancs courts, DIADÈME
D'OR à deux petites ailes dorées. Armure légère blanche à bords dorés, petites épaulières
dorées, TABARD COURT émeraude à liseré d'or qui s'arrête au-dessus des genoux. Deux grandes
ailes de plumes BLANCHES aux pointes émeraude, REPLIÉES dans son dos. Une LANCE D'OR à pointe
blanche dans la main droite. Une petite cloche d'or à la ceinture. Un contour vert très
sombre cerne ses formes claires. Pas de cape, pas d'auréole.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le
tronc ont les mêmes dimensions en pixels. Un corps plus petit se verrait comme un
rétrécissement à chaque sort.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur. La pointe de la lance vient
  DROIT VERS NOUS, devant sa poitrine. Elle reste DANS la largeur du corps
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos. La lance part droit devant lui et
  disparaît derrière sa tête. Elle reste DANS la largeur du corps
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
1. posture prête, la lance droite dans la main droite
2. il lève la lance vers le ciel, les ailes s'entrouvrent à peine
3. la lance est au plus haut, pointe vers le ciel, le corps tendu
4. L'IMPACT : il abaisse la lance d'un coup et la pointe dans la direction de la rangée, avec
   un petit éclat BLANC et ÉMERAUDE à sa pointe
5. l'éclat a disparu, la lance reste pointée
6. la lance commence à se redresser
7. la lance revient droite contre le corps
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en
rangée 1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais
l'ensemble corps et lance.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit éclat de
l'image 4, plus petit que sa tête. Le JEU dessine lui-même la lance de lumière qui tombe du ciel.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT REPLIÉES et ne dépassent pas de plus d'un quart de la
largeur du corps de chaque côté. La lance reste entière DANS la case, même à l'image 3.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds
restent à plat pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE. Une ombre sous le personnage
et un trait entre les cases ne s'effacent pas : ils resteraient collés au sprite.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE. Empile mentalement
les 8 images d'une rangée : le TRONC et la TÊTE se superposent exactement. Il garde
la même taille, CENTRÉ au même endroit.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas de ses pieds touche la même
ligne horizontale dans les 24 cases, et rien n'est dessiné plus bas que cette ligne.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage
regarde VERS LA DROITE dans les 8 cases.
```

---

## À vérifier sur la planche reçue

| Défaut | Conséquence en jeu |
|---|---|
| Une ombre ou un trait de grille | Une salissure reste collée au sprite |
| Le corps se déplace dans la case | Il tressaute en marchant |
| Le corps est plus petit sur l'attaque | Il rétrécit à chaque sort |
| La tête est plus étroite de profil | Il change de taille en tournant |
| La lance part sur le côté en rangée 1 ou 2 | Il semble frapper à côté de sa cible |
| Les pieds gardent le même écart de profil | Il glisse sur le sol |
| Le même pied reste devant aux images 1 et 5 | Il marche sur une seule jambe |
| La pointe de la lance sort de la case | Elle serait coupée à la découpe |
| Les ailes battent ou s'ouvrent pendant la marche | Il change de largeur à chaque pas |
| Les bras restent figés le long du corps | Il glisse comme une statue au lieu de marcher |
| Les mêmes bras devant aux images 1 et 5 | Il balance un seul bras |
| La lance penche ou se couche en marchant | Elle sortirait de la case et passerait devant le visage |

**À la livraison :** la largeur de la tête, de profil par rapport à la face, doit rester entre 0,95 et 1,05, et
l'écart des pieds de profil près de celui du Chronomancien (0,17 joints, 0,56 ouverts).
