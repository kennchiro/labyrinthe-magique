# Le Chevalier Écarlate — planches de marche et d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/ecarlate.png`
au générateur, pour qu'il garde le même personnage. Pour la marche, joindre AUSSI
`docs/prompts/mages_animes/guide_complet.png`, qui porte les jambes du Chronomancien,
la marche de référence.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/ecarlate_marche.png
    assets/peso&cover/mages/ecarlate_attaque.png

La gauche n'est PAS demandée : le jeu retourne le profil droit. La planche de marche se
commande entière : [une bande de profil générée à part sort plus fine que la face](marche_chronomancien.md).

---

## Prompt 1 — la marche

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son visage, son armure, son
sabre, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Chevalier Écarlate, un homme ADULTE et HUMAIN, en proportions CHIBI : grosse
tête, corps court. Peau claire, longs cheveux blancs (#f4f1ec) en queue basse, yeux gris pâle,
expression calme, pas de casque. Armure gothique de style samouraï, à fines plaques de laque unie
rouge sang (#b81414) aux bords noirs (#17171a) : épaulières en lamelles, plastron étroit, brassards
et jambières. Tenue noire ajustée et hauts solerets noirs. Sur sa hanche gauche, un long sabre fin
au fourreau noir et à la poignée blanche, RENGAINÉ, incliné vers l'arrière. PAS de cape, de jupe
de plaques, de cornes, de queue, de griffes ni d'ailes.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. C'est le même personnage vu sous
trois angles. Sa tête a EXACTEMENT la même hauteur et la même largeur dans les 24 cases : elle
n'est pas plus petite de profil. De profil, il n'est ni plus fin, ni plus grand, ni plus élancé,
et ses jambes ne sont pas plus longues que de face. Sa hauteur totale est la même dans les 24 cases.

Il MARCHE tranquillement sur place. IL NE COURT PAS : le buste reste DROIT, sans pencher en avant,
et les genoux restent bas. Ses bras restent près du corps et balancent légèrement, en opposition
aux jambes, les mains fermées. Le fourreau bouge à peine et ne coupe jamais les jambes.

⚠️ AUCUNE MAGIE : ni flamme, ni lueur, ni pétale, ni aura, ni particule.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, avec ses
jambières et ses solerets.

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

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES ET LES BRAS BOUGENT. Dans une même rangée, la tête et le
tronc se superposent exactement d'une case à l'autre, et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — LE ROUGE EST FRANC, SANS AUCUN BLEU : aucun bordeaux, rose ou violet sur lui.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune poussière.
```

---

## Prompt 2 — l'attaque

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le personnage : garde EXACTEMENT son visage, son armure, son
sabre, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Chevalier Écarlate, un homme ADULTE et HUMAIN, en proportions CHIBI : grosse
tête, corps court. Peau claire, longs cheveux blancs (#f4f1ec) en queue basse, yeux gris pâle,
expression calme, pas de casque. Armure gothique de style samouraï, à fines plaques de laque unie
rouge sang (#b81414) aux bords noirs (#17171a) : épaulières en lamelles, plastron étroit, brassards
et jambières. Tenue noire ajustée et hauts solerets noirs. À sa hanche gauche, un fourreau noir.
Un long sabre fin, à lame d'acier clair (#d9dee3) et à poignée blanche, COURT par rapport à la
case : il ne la dépasse jamais. PAS de cape, de jupe de plaques, de cornes, de queue, de griffes
ni d'ailes.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le
tronc ont les mêmes dimensions en pixels. Un corps plus petit se verrait comme un
rétrécissement à chaque sort.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il coupe VERS LE BAS DE L'IMAGE, face au joueur. La lame descend DROIT DEVANT lui, le
  long de l'axe du corps, jamais sur le côté
- rangée 2 : il coupe VERS LE HAUT DE L'IMAGE, de dos. La lame part droit devant lui et monte au-dessus
  de sa tête, le long de l'axe du corps, jamais sur le côté
- rangée 3 : il coupe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
1. posture prête, la main droite sur la poignée, le sabre rengainé
2. il tire le sabre à moitié du fourreau, le buste ramassé
3. le sabre sort entier, armé près de l'épaule
4. L'IMPACT : la coupe, bras et lame tendus dans la direction de la rangée
5. la lame reste tendue, immobile
6. il ramène lentement le sabre vers le fourreau
7. la lame rentre à moitié dans le fourreau
8. il retrouve exactement sa pose de marche, le sabre rengainé

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE. Le corps reste CENTRÉ dans sa
case : c'est le CORPS qu'on centre, jamais l'ensemble corps et sabre.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ, AUCUNE TRAÎNÉE DE COUPE, ni arc, ni éclat, ni pétale. Le JEU
dessine lui-même la coupe.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds
restent à plat pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — LE ROUGE EST FRANC, SANS AUCUN BLEU, aucun reflet du fond magenta.

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
| Le corps est plus petit sur l'attaque | Il rétrécit à chaque coup |
| La tête est plus étroite de profil | Il change de taille en tournant |
| La lame part sur le côté en rangée 1 ou 2 | Il semble couper à côté de sa cible |
| La lame sort de la case | Elle serait coupée à la découpe |
| Les pieds gardent le même écart de profil | Il glisse sur le sol |
| Le fourreau coupe les jambes | Le pas ne se lit plus de profil |
| Une traînée ou des pétales sont dessinés | Ils doubleraient ce que le jeu dessine |

**À la livraison :** la largeur de la tête, de profil par rapport à la face, doit rester entre 0,95 et 1,05, et
l'écart des pieds de profil près de celui du Chronomancien (0,17 joints, 0,56 ouverts).
