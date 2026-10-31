# Mage de la Foudre — planches de marche et d'attaque

    aujourd'hui   4 pas · 1 pose d'attaque
    demain        4 orientations · 8 pas · 8 images d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/foudre.png`
au générateur, pour qu'il garde le même personnage. Pour la marche, joindre AUSSI
`docs/prompts/mages_animes/guide_marche.png`, qui impose la position des pieds.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/foudre_marche.png
    assets/peso&cover/mages/foudre_attaque.png

La gauche n'est PAS demandée : le jeu retourne le profil droit.

---

## Prompt 1 — la marche

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, effets lumineux, même facture que les sprites d'un jeu
de rôle mobile. L'image jointe montre le personnage : garde EXACTEMENT son visage,
ses couleurs, ses vêtements et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage de la Foudre. Tunique courte jaune et bleu nuit, fendue
pour la course, bottes légères, cheveux blancs dressés par la charge. Il tient
un BÂTON MAGIQUE court de la main droite : une hampe sombre surmontée d'un
ÉCLAT JAUNE CRÉPITANT. Corps COMPACT, tête un peu large, silhouette lisible en
très petit. L'aura reste COLLÉE au corps : pas de halo large, pas de nuage de
particules autour.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, il avance vers le bas de l'image
- rangée 2 : vu DE DOS, il s'éloigne vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite de l'image

SES JAMBES : c'est le plus rapide des huit : tunique courte, jambes bien
visibles, une vraie foulée de coureur.
SES MAINS : le bâton court est tenu en avant comme un coureur, le bras libre
balance.

⚠️ LA DEUXIÈME IMAGE JOINTE EST UN GUIDE DE POSE. Elle a la même grille que la planche
à produire. Dans chaque case, recopie EXACTEMENT la position de ses deux pieds et la
place de son corps. Le pied ROUGE est la jambe la plus proche de nous, le pied BLEU
la plus éloignée. Le mannequin et ses couleurs ne doivent PAS apparaître : c'est le
personnage de la première image, avec ses vraies bottes, qui prend ces poses.

LES 8 COLONNES de chaque rangée sont UN CYCLE DE MARCHE, et les 8 images sont TOUTES
différentes. Sur la rangée de profil :
1. le pied proche est loin DEVANT, posé. Le pied éloigné est loin DERRIÈRE
2. le pied proche recule, à plat. Le pied éloigné quitte le sol
3. PASSAGE : les deux pieds sont l'un sur l'autre, JOINTS, le pied éloigné levé
4. le pied proche continue vers l'arrière. Le pied éloigné passe DEVANT, levé
5. l'INVERSE de l'image 1 : le pied éloigné est loin DEVANT, le pied proche loin DERRIÈRE
6. le pied éloigné recule, à plat. Le pied proche quitte le sol
7. PASSAGE : les deux pieds sont JOINTS, le pied proche levé
8. le pied proche passe DEVANT, levé. L'image enchaîne sur la première

⚠️ DÉFAUT À NE PAS REPRODUIRE, livré sur toutes les planches précédentes : les jambes
restent écartées presque tout le cycle, et c'est toujours le même pied qui est devant.
Les deux pieds doivent ÉCHANGER leur place : celui qui est devant à l'image 1 est
derrière à l'image 5. Aux images 3 et 7, on ne voit plus d'écart entre les pieds.
Aux images 1 et 5, l'écart vaut au moins la MOITIÉ DE LA HAUTEUR du personnage. La
robe s'ouvre autant qu'il le faut pour que les bottes restent visibles.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE. Une ombre sous le personnage
et un trait entre les cases ne s'effacent pas : ils resteraient collés au sprite.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE. Empile mentalement
les 8 images d'une rangée : le TRONC et la TÊTE se superposent exactement. Il garde
la même taille, CENTRÉ au même endroit. C'est le JEU qui le fait avancer sur la
carte : la planche montre les membres, sur place, comme sur un tapis roulant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas de ses pieds touche la même
ligne horizontale dans les 24 cases, et rien n'est dessiné plus bas que cette ligne.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage
regarde VERS LA DROITE dans les 8 cases.

AUCUNE attaque, aucun projectile sur cette planche : il marche, c'est tout.
```

---

## Prompt 2 — l'attaque

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, effets lumineux, même facture que les sprites d'un jeu
de rôle mobile. L'image jointe montre le personnage : garde EXACTEMENT son visage,
ses couleurs, ses vêtements et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage de la Foudre. Tunique courte jaune et bleu nuit, fendue
pour la course, bottes légères, cheveux blancs dressés par la charge. Il tient
un BÂTON MAGIQUE court de la main droite : une hampe sombre surmontée d'un
ÉCLAT JAUNE CRÉPITANT. Corps COMPACT, tête un peu large, silhouette lisible en
très petit. L'aura reste COLLÉE au corps : pas de halo large, pas de nuage de
particules autour.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le
tronc ont les mêmes dimensions en pixels. Un corps plus petit se verrait comme un
rétrécissement à chaque sort.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il lance VERS LE BAS DE L'IMAGE, face au joueur : le bras et le sort
  viennent VERS NOUS, jamais sur le côté
- rangée 2 : il lance VERS LE HAUT DE L'IMAGE, de dos : le bras et le sort
  s'éloignent de nous, jamais sur le côté
- rangée 3 : il lance VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
1. il ramène le bâton près de l'épaule, de petites étincelles courent dessus
2. le bâton se lève, l'éclat jaune s'allume, ses cheveux se hérissent
3. LE TIR : bâton pointé vers l'avant, un éclair court et brisé part de l'éclat
4. l'éclair crépite encore, deux ou trois branches courtes
5. l'éclair s'éteint, il reste quelques étincelles sur la hampe
6. le bâton redescend, les étincelles s'éteignent
7. le bâton revient près du corps
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE SORT PART DANS LA DIRECTION DE LA RANGÉE, et le corps reste
CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais l'ensemble corps et sort.

⚠️ RÈGLE BLOQUANTE — LE SORT RESTE PRÈS DE LA MAIN. Il tient dans la case et ne
dépasse pas la moitié de la hauteur du personnage. Le JEU dessine ensuite le
projectile qui voyage : la planche ne montre que le geste et sa lueur.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds
restent à plat pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE. Une ombre sous le personnage
et un trait entre les cases ne s'effacent pas : ils resteraient collés au sprite.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE. Empile mentalement
les 8 images d'une rangée : le TRONC et la TÊTE se superposent exactement. Il garde
la même taille, CENTRÉ au même endroit. C'est le JEU qui le fait avancer sur la
carte : la planche montre les membres, sur place, comme sur un tapis roulant.

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
| Le corps se déplace dans la case | Le mage tressaute en marchant |
| Le corps est plus petit sur l'attaque | Il rétrécit à chaque sort |
| Le sort part sur le côté en rangée 1 ou 2 | Il semble tirer à côté de sa cible |
| Les pieds bougent à peine | Il glisse sur le sol |
| Le bâton ou l'orbe disparaît sur une case | L'objet clignote pendant la marche |
