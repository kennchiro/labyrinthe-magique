# Archange d'Acier — planches de marche et d'attaque

    aujourd'hui   rien encore, c'est un nouveau personnage
    demain        4 orientations · 8 pas · 8 images d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/acier.png`
au générateur, pour qu'il garde le même personnage. Pour la marche, joindre AUSSI
`docs/prompts/mages_animes/guide_marche.png`, qui impose la position des pieds.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/acier_marche.png
    assets/peso&cover/mages/acier_attaque.png

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

LE PERSONNAGE — l'Archange d'Acier, un ange guerrier MASSIF et COSTAUD, très
large d'épaules, en ARMURE DE PLATES INTÉGRALE gris-bleu, faite de grandes
plaques épaisses bien visibles : énormes épaulières, plastron bombé, gantelets
et grosses bottes de métal. HEAUME FERMÉ : aucun visage, seulement une fente
horizontale d'où sort une lueur orange. De fines fentes orange, couleur de
métal chauffé, courent entre les plaques du plastron. Deux GRANDES AILES faites
entièrement de LAMES D'ACIER superposées, sans aucune plume, à demi repliées
dans son dos. Il porte de la main droite un grand MARTEAU DE GUERRE, à la tête
d'acier massive et au manche épais. Ses plaques sombres sont cernées d'un fin
liseré GRIS CLAIR, qui les détache des sols sombres. Corps COMPACT, tête un peu
large, silhouette lisible en très petit. L'aura reste COLLÉE au corps : pas de
halo large, pas de nuage de particules autour.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, il avance vers le bas de l'image
- rangée 2 : vu DE DOS, il s'éloigne vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite de l'image

SES JAMBES : ses jambes blindées et ses grosses bottes de métal se lèvent
franchement à chaque pas, d'une démarche lourde.
SES MAINS : le marteau reste dans sa main droite, posé sur l'épaule, et les
ailes de lames restent à demi repliées dans son dos, sans battre.

⚠️ LA DEUXIÈME IMAGE JOINTE EST UN GUIDE DE POSE. Elle a la même grille que la planche
à produire. Dans chaque case, recopie EXACTEMENT la position de ses deux pieds et la
place de son corps. Le pied ROUGE est la jambe la plus proche de nous, le pied BLEU
la plus éloignée. Le mannequin et ses couleurs ne doivent PAS apparaître : c'est le
personnage de la première image, avec ses vraies bottes, qui prend ces poses.

LES 8 COLONNES de chaque rangée sont UN CYCLE DE MARCHE tranquille, à pas MOYENS :
1. le pied proche est devant, le pied éloigné derrière, les deux posés
2. le pied proche recule, le pied éloigné se lève à peine
3. PASSAGE : les pieds se croisent, le pied éloigné levé
4. le pied éloigné passe devant, le pied proche recule
5. l'INVERSE de l'image 1 : le pied éloigné devant, le pied proche derrière
6. le pied éloigné recule, le pied proche se lève à peine
7. PASSAGE : les pieds se croisent, le pied proche levé
8. le pied proche passe devant : l'image enchaîne sur la première

⚠️ RÈGLE BLOQUANTE — NI GRAND ÉCART NI PIEDS COLLÉS. De profil, aux images 1 et 5, l'écart
entre les pieds vaut environ UN TIERS DE LA HAUTEUR du personnage, jamais plus. Les deux
pieds échangent leur place : celui qui est devant à l'image 1 est derrière à l'image 5.
De face et de dos, les pieds restent sous le corps, sans s'écarter vers les côtés : l'un
puis l'autre se lève. Pas de jambes en compas, et pas de saut à pieds joints.

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

LE PERSONNAGE — l'Archange d'Acier, un ange guerrier MASSIF et COSTAUD, très
large d'épaules, en ARMURE DE PLATES INTÉGRALE gris-bleu, faite de grandes
plaques épaisses bien visibles : énormes épaulières, plastron bombé, gantelets
et grosses bottes de métal. HEAUME FERMÉ : aucun visage, seulement une fente
horizontale d'où sort une lueur orange. De fines fentes orange, couleur de
métal chauffé, courent entre les plaques du plastron. Deux GRANDES AILES faites
entièrement de LAMES D'ACIER superposées, sans aucune plume, à demi repliées
dans son dos. Il porte de la main droite un grand MARTEAU DE GUERRE, à la tête
d'acier massive et au manche épais. Ses plaques sombres sont cernées d'un fin
liseré GRIS CLAIR, qui les détache des sols sombres. Corps COMPACT, tête un peu
large, silhouette lisible en très petit. L'aura reste COLLÉE au corps : pas de
halo large, pas de nuage de particules autour.

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
1. il saisit le marteau à deux mains et l'arme haut derrière l'épaule, les fentes de l'armure s'éclairent
2. le marteau monte au-dessus de la tête, le torse se tend, la tête de l'arme rougeoie
3. le marteau commence à s'abattre vers l'avant, un arc gris clair suit sa tête
4. L'IMPACT : bras tendus, le marteau frappe vers l'avant, un petit éclat blanc et orange jaillit de sa tête
5. l'éclat s'efface, deux ou trois petites étincelles orange restent près de la tête du marteau
6. le marteau remonte, la lueur de sa tête faiblit
7. le marteau revient vers l'épaule
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE SORT PART DANS LA DIRECTION DE LA RANGÉE, et le corps reste
CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais l'ensemble corps et sort.

⚠️ RÈGLE BLOQUANTE — LE SORT RESTE PRÈS DE LA MAIN. Il tient dans la case et ne
dépasse pas la moitié de la hauteur du personnage. Le JEU dessine ensuite le
projectile qui voyage : la planche ne montre que le geste et sa lueur.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds
restent à plat pendant tout le geste, à la même place.

⚠️ LES AILES, LE HEAUME ET LE MARTEAU gardent la même taille, la même forme et
la même place dans les 24 cases, et restent entiers DANS la case, y compris la
tête du marteau à l'image de l'impact : les ailes ne dépassent pas de plus d'un
quart de la largeur du corps de chaque côté. AUCUNE ÉTINCELLE ni aucune lueur
HORS de son corps en dehors de l'éclat de l'impact : le jeu dessine lui-même
ses sorts. Le métal reste GRIS-BLEU, à plages nettes, et les seules couleurs
chaudes sont les fentes orange : aucun violet, aucun rose, aucun reflet du fond
magenta sur le métal.

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
