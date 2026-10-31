# Mage de l'Eau — planches de marche et d'attaque

    aujourd'hui   4 pas · 1 pose d'attaque
    demain        4 orientations · 8 pas · 8 images d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/eau.png`
au générateur, pour qu'il garde le même personnage. Pour la marche, joindre AUSSI
`docs/prompts/mages_animes/guide_marche.png`, qui impose la position des pieds.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/eau_marche.png
    assets/peso&cover/mages/eau_attaque.png

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

LE PERSONNAGE — le Mage de l'Eau. Robe bleu profond à liserés turquoise,
capuche, écharpe claire. Il tient un BÂTON MAGIQUE de la main droite : une
hampe pâle surmontée d'une GOUTTE DE CRISTAL BLEU d'où perle une eau qui ne
tombe jamais. Corps COMPACT, tête un peu large, silhouette lisible en très
petit. L'aura reste COLLÉE au corps : pas de halo large, pas de nuage de
particules autour.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, il avance vers le bas de l'image
- rangée 2 : vu DE DOS, il s'éloigne vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite de l'image

SES JAMBES : le bas de la robe s'ouvre et ses bottes sortent franchement à
chaque pas.
SES MAINS : le bâton reste dans sa main droite, tenu droit, et l'écharpe flotte
derrière lui.

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

LE PERSONNAGE — le Mage de l'Eau. Robe bleu profond à liserés turquoise,
capuche, écharpe claire. Il tient un BÂTON MAGIQUE de la main droite : une
hampe pâle surmontée d'une GOUTTE DE CRISTAL BLEU d'où perle une eau qui ne
tombe jamais. Corps COMPACT, tête un peu large, silhouette lisible en très
petit. L'aura reste COLLÉE au corps : pas de halo large, pas de nuage de
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
1. il ramène le bâton contre l'épaule, la goutte de cristal s'éclaire
2. le bâton bascule vers l'avant, de l'eau s'enroule autour de la goutte
3. LE TIR : bâton pointé vers l'avant, un jet d'eau court et dense jaillit de la goutte
4. le jet s'étire d'un dernier coup, des gouttes s'en échappent
5. le jet retombe en éclaboussures près de la goutte
6. le bâton remonte, les dernières gouttes tombent
7. le bâton revient presque à la verticale
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
