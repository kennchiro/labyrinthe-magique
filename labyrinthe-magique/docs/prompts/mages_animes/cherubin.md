# Le Chérubin — planches de marche et d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/cherubin.png`
au générateur, pour qu'il garde le même personnage. Pour la marche, joindre AUSSI
`docs/prompts/mages_animes/guide_complet.png`, qui porte les jambes du Chronomancien,
la marche de référence.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/cherubin_marche.png
    assets/peso&cover/mages/cherubin_attaque.png

La gauche n'est PAS demandée : le jeu retourne le profil droit. La planche de marche se
commande entière : [une bande de profil générée à part sort plus fine que la face](marche_chronomancien.md).

---

## Prompt 1 — la marche

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son visage, ses couleurs, ses
quatre ailes et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Chérubin, le gardien d'Éden, un jeune ange au visage grave bien visible,
aux yeux bleu saphir, en proportions CHIBI : grosse tête, corps court. Cheveux d'or foncé
courts et bouclés, une petite ROUE D'OR à huit rayons fixée derrière la tête. TUNIQUE COURTE
de lin blanc qui s'arrête au-dessus des genoux, CUIRASSE de BRONZE POLI, jambières et sandales
de bronze, CEINTURE BLEU SAPHIR. QUATRE AILES en deux paires, blanches aux pointes saphir, avec
quelques yeux d'or stylisés sur les plumes, REPLIÉES dans son dos. Une ÉPÉE de bronze dont la
lame est une FLAMME BLEU SAPHIR en trois tons nets, dans la main droite, tenue droite, pointe
en l'air. Un contour bleu-noir très sombre cerne ses formes claires. Pas de cape, pas d'auréole.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. C'est le même personnage vu sous
trois angles. Sa tête a EXACTEMENT la même hauteur et la même largeur dans les 24 cases : elle
n'est pas plus petite de profil. De profil, il n'est ni plus fin, ni plus grand, ni plus élancé,
et ses jambes ne sont pas plus longues que de face. Sa hauteur totale est la même dans les 24 cases.

Il MARCHE tranquillement sur place, d'un pas léger. IL NE COURT PAS : le buste reste DROIT, sans
pencher en avant, et les genoux restent bas. Les quatre ailes restent repliées, sans battre.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps.
- LE BRAS LIBRE (le gauche, poing fermé) balance en grand, de l'avant vers l'arrière ;
- LE BRAS DE L'ÉPÉE (le droit) balance AUSSI, moins loin : la main avance et recule en
  emportant l'épée, qui reste VERTICALE, flamme en l'air, et ne fait que glisser vers l'avant
  ou l'arrière avec la main, sans jamais se coucher ni passer devant le visage ;
- la flamme de la lame ondule un peu : ses langues changent d'une image à l'autre, sans grandir.

LE BALANCEMENT DES BRAS, image par image, calé sur les jambes du guide :
1. bras libre tendu vers l'AVANT, poing à hauteur de taille ; main de l'épée vers l'ARRIÈRE
2. bras libre qui redescend, coude un peu plié ; main de l'épée qui revient
3. les deux bras le long du corps, POINT DE PASSAGE (c'est l'image aux jambes jointes)
4. bras libre qui part vers l'arrière ; main de l'épée qui part vers l'avant
5. l'INVERSE de l'image 1 : bras libre vers l'ARRIÈRE, main de l'épée vers l'AVANT
6. main de l'épée qui revient ; bras libre qui revient
7. les deux bras le long du corps, POINT DE PASSAGE (jambes jointes)
8. bras libre qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui avance
grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté du corps.
DE PROFIL, l'épée reste devant le corps, et la main qui la tient avance et recule le long de lui.

⚠️ AUCUNE MAGIE : ni lueur, ni aura, ni plume qui vole, ni particule. La flamme de l'épée est un
dessin net, en aplats opaques, et rien ne brille autour.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, avec ses
sandales et ses jambières de bronze.

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
voisines identiques pour les bras sont une erreur. L'épée bouge AVEC sa main, toujours droite.

⚠️ RÈGLE BLOQUANTE — NI LA TUNIQUE NI LES AILES NE CACHENT LES JAMBES. La tunique s'arrête
au-dessus des genoux, la paire d'ailes du bas aussi : les deux sandales se voient dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS ET L'ÉPÉE BOUGENT. Dans une même rangée, la tête,
la roue, le tronc et les quatre ailes se superposent exactement d'une case à l'autre, et le profil
regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES AILES ET L'ÉPÉE TIENNENT DANS LA CASE. Les quatre ailes ne dépassent pas
de plus d'un quart de la largeur du corps de chaque côté, et la pointe de la flamme ne sort jamais
de la case.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — LE BLEU EST UN SAPHIR FRANC, JAMAIS VIOLET. AUCUN ROSE, AUCUN VIOLET sur lui :
le lin reste blanc, ombré de gris-beige.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune poussière.
```

---

## Prompt 2 — l'attaque

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le personnage : garde EXACTEMENT son visage, ses couleurs,
ses quatre ailes et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Chérubin, le gardien d'Éden, un jeune ange au visage grave bien visible,
aux yeux bleu saphir, en proportions CHIBI : grosse tête, corps court. Cheveux d'or foncé
courts et bouclés, une petite ROUE D'OR à huit rayons fixée derrière la tête. TUNIQUE COURTE
de lin blanc, CUIRASSE de BRONZE POLI, jambières et sandales de bronze, CEINTURE BLEU SAPHIR.
QUATRE AILES en deux paires, blanches aux pointes saphir, avec quelques yeux d'or stylisés,
REPLIÉES dans son dos. Une ÉPÉE de bronze à lame de FLAMME BLEU SAPHIR dans la main droite.
Un contour bleu-noir très sombre cerne ses formes claires. Pas de cape, pas d'auréole.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le
tronc ont les mêmes dimensions en pixels. Un corps plus petit se verrait comme un
rétrécissement à chaque sort.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur. La pointe de l'épée vient
  DROIT VERS NOUS, devant sa poitrine. Elle reste DANS la largeur du corps
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos. L'épée part droit devant lui et
  disparaît derrière sa tête. Elle reste DANS la largeur du corps
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
1. posture prête, l'épée droite dans la main droite
2. il ramène l'épée contre son épaule, la flamme se couche un peu en arrière
3. il arme, le corps ramassé, les ailes du haut s'entrouvrent à peine
4. L'IMPACT : il tend l'épée d'un coup dans la direction de la rangée, la flamme s'allonge
   devant la pointe en une petite langue saphir nette, plus courte que son bras
5. la langue de flamme a disparu, l'épée reste tendue
6. l'épée commence à revenir
7. l'épée revient droite contre le corps
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en
rangée 1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais
l'ensemble corps et épée.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est la petite langue de
flamme de l'image 4, plus courte que son bras. Le JEU dessine lui-même le jet de flamme.

⚠️ RÈGLE BLOQUANTE — LES QUATRE AILES RESTENT REPLIÉES et ne dépassent pas de plus d'un quart
de la largeur du corps de chaque côté. L'épée reste entière DANS la case.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds
restent à plat pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — LE BLEU EST UN SAPHIR FRANC, JAMAIS VIOLET. AUCUN ROSE, AUCUN VIOLET sur
lui, aucun reflet du fond magenta.

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
| L'épée part sur le côté en rangée 1 ou 2 | Il semble frapper à côté de sa cible |
| Les pieds gardent le même écart de profil | Il glisse sur le sol |
| Le même pied reste devant aux images 1 et 5 | Il marche sur une seule jambe |
| Les bras restent figés le long du corps | Il glisse comme une statue au lieu de marcher |
| Les mêmes bras devant aux images 1 et 5 | Il balance un seul bras |
| L'épée penche ou se couche en marchant | Elle sortirait de la case et passerait devant le visage |
| Les ailes battent, s'ouvrent, ou ne sont plus que deux | Il change de largeur à chaque pas, ou perd ce qui le distingue |
| La paire d'ailes du bas cache les jambes | Il glisse sur le sol |

**À la livraison :** la largeur de la tête, de profil par rapport à la face, doit rester entre 0,95 et 1,05, et
l'écart des pieds de profil près de celui du Chronomancien (0,17 joints, 0,56 ouverts).
