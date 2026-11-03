# Le Roi de Braise — planches de marche et d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/braise.png`
au générateur, pour qu'il garde le même personnage. Pour la marche, joindre AUSSI
`docs/prompts/mages_animes/guide_complet.png`, qui porte les jambes du Chronomancien,
la marche de référence.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/braise_marche.png
    assets/peso&cover/mages/braise_attaque.png

La gauche n'est PAS demandée : le jeu retourne le profil droit. La planche de marche se
commande entière : [une bande de profil générée à part sort plus fine que la face](marche_chronomancien.md).

---

## Prompt 1 — la marche

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son visage, son armure, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Roi de Braise, un homme ADULTE et HUMAIN, en proportions CHIBI : grosse tête,
corps court. Peau claire, cheveux sombres mi-longs en arrière, yeux ambrés, expression sévère,
couronne d'or noirci BRISÉE. Armure d'or noirci (#2a2118) aux arêtes d'or vieilli (#b8862b),
parcourue de fines fissures de lave orange (#ff7a18) : épaulières larges, ceinture, jambières et
solerets. Cotte sombre, fines manches et simples gants noirs. Court mantelet anthracite qui
s'arrête à la taille. PAS de grands gantelets, de plastron, de longue cape, de cornes, de queue,
de griffes ni d'ailes. Aucune arme.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. C'est le même personnage vu sous
trois angles. Sa tête a EXACTEMENT la même hauteur et la même largeur dans les 24 cases : elle
n'est pas plus petite de profil. De profil, il n'est ni plus fin, ni plus grand, ni plus élancé,
et ses jambes ne sont pas plus longues que de face. Sa hauteur totale est la même dans les 24 cases.

Il MARCHE tranquillement sur place, d'un pas royal. IL NE COURT PAS : le buste reste DROIT, sans
pencher en avant, et les genoux restent bas. Ses bras restent près du corps et balancent
légèrement, en opposition aux jambes, les mains fermées.

⚠️ AUCUNE MAGIE : les fissures sont de simples traits orange. Ni flamme, ni lueur, ni aura, ni particule.

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

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune poussière.
```

---

## Prompt 2 — l'attaque

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le personnage : garde EXACTEMENT son visage, son armure, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Roi de Braise, un homme ADULTE et HUMAIN, en proportions CHIBI : grosse tête,
corps court. Peau claire, cheveux sombres mi-longs en arrière, yeux ambrés, expression sévère,
couronne d'or noirci BRISÉE. Armure d'or noirci (#2a2118) aux arêtes d'or vieilli (#b8862b),
parcourue de fines fissures de lave orange (#ff7a18) : épaulières larges, ceinture, jambières et
solerets. Cotte sombre, fines manches et simples gants noirs. Court mantelet anthracite qui
s'arrête à la taille. PAS de grands gantelets, de plastron, de longue cape, de cornes, de queue,
de griffes ni d'ailes. Aucune arme.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le
tronc ont les mêmes dimensions en pixels. Un corps plus petit se verrait comme un
rétrécissement à chaque sort.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur. Son poing vient DROIT VERS NOUS,
  devant sa poitrine, et cache le milieu de son torse. Il reste DANS la largeur du corps
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos. Son bras part droit devant lui et
  disparaît derrière sa tête. Il reste DANS la largeur du corps
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
1. posture prête, le poing droit près de la poitrine
2. il ramène le poing en arrière, les épaules tournées
3. il arme encore le bras, le corps ramassé
4. L'IMPACT : bras tendu d'un coup dans la direction de la rangée, main grande ouverte, et un
   petit éclat ORANGE au bout des doigts
5. l'éclat a disparu, le bras reste tendu et la main ouverte
6. la main se referme lentement
7. le bras revient près du corps
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en
rangée 1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais
l'ensemble corps et bras.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ, AUCUN GANTELET VOLANT. Le seul effet de la planche est
le petit éclat orange de l'image 4, plus petit que sa main. Le JEU dessine lui-même les pièces et
les sorts.

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
| Le bras part sur le côté en rangée 1 ou 2 | Il semble frapper à côté de sa cible |
| Les pieds gardent le même écart de profil | Il glisse sur le sol |
| Le même soleret reste devant aux images 1 et 5 | Il marche sur une seule jambe |
| Des gantelets, une flamme ou une lueur sont dessinés | Ils doubleraient ce que le jeu dessine |

**À la livraison :** la largeur de la tête, de profil par rapport à la face, doit rester entre 0,95 et 1,05, et
l'écart des pieds de profil près de celui du Chronomancien (0,17 joints, 0,56 ouverts).
