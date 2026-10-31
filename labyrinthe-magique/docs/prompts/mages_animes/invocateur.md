# Invocateur — planches de marche et d'attaque

    aujourd'hui   4 pas · 1 pose d'attaque
    demain        4 orientations · 8 pas · 8 images d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/invocateur.png`
au générateur, pour qu'il garde le même personnage.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/invocateur_marche.png
    assets/peso&cover/mages/invocateur_attaque.png

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

LE PERSONNAGE — l'Invocateur. Robe violette à liserés d'or, capuche rejetée en
arrière, cheveux noirs, colliers d'ossements, regard découvert. Il tient un
BÂTON MAGIQUE de la main droite : une hampe torsadée surmontée d'une ORBE
VIOLETTE enserrée dans des griffes d'or. Corps COMPACT, tête un peu large,
silhouette lisible en très petit. L'aura reste COLLÉE au corps : pas de halo
large, pas de nuage de particules autour.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, il avance vers le bas de l'image
- rangée 2 : vu DE DOS, il s'éloigne vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite de l'image

SES JAMBES : la robe s'ouvre sur ses bottes sombres, qui sortent franchement à
chaque pas.
SES MAINS : le BÂTON EST DANS SA MAIN DROITE DANS LES 24 CASES, sans exception.

LES 8 COLONNES de chaque rangée, de gauche à droite, sont UN CYCLE DE MARCHE vive :
1. APPUI : pied droit loin devant, talon au sol, pied gauche loin derrière
2. le pied arrière quitte le sol et remonte
3. PASSAGE : les deux pieds se croisent au milieu, presque joints
4. le pied gauche part vers l'avant
5. APPUI INVERSE : pied gauche loin devant, talon au sol, pied droit loin derrière
6. le pied arrière quitte le sol et remonte
7. PASSAGE : les deux pieds se croisent au milieu, presque joints
8. le pied droit repart vers l'avant : l'image enchaîne sur la première

⚠️ CHIFFRE À TENIR : aux images d'APPUI, l'écart entre le talon avant et les orteils
arrière vaut au moins LA MOITIÉ DE LA HAUTEUR du personnage. Un pied qui ne fait que
frémir donne un mage qui GLISSE sur le sol au lieu de marcher.

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

LE PERSONNAGE — l'Invocateur. Robe violette à liserés d'or, capuche rejetée en
arrière, cheveux noirs, colliers d'ossements, regard découvert. Il tient un
BÂTON MAGIQUE de la main droite : une hampe torsadée surmontée d'une ORBE
VIOLETTE enserrée dans des griffes d'or. Corps COMPACT, tête un peu large,
silhouette lisible en très petit. L'aura reste COLLÉE au corps : pas de halo
large, pas de nuage de particules autour.

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
1. il saisit le bâton plus haut, l'orbe s'éclaire doucement
2. il lève le bâton, l'autre main s'ouvre paume vers le ciel
3. L'APPEL : le bâton s'abat droit devant lui, l'orbe flamboie
4. le bâton est planté, l'orbe lance de courtes volutes violettes
5. les volutes montent et s'effacent, sa main libre reste ouverte
6. il relâche sa main libre, l'orbe faiblit
7. il retire le bâton du sol
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE SORT PART DANS LA DIRECTION DE LA RANGÉE, et le corps reste
CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais l'ensemble corps et sort.

⚠️ RÈGLE BLOQUANTE — LE SORT RESTE PRÈS DE LA MAIN. Il tient dans la case et ne
dépasse pas la moitié de la hauteur du personnage. Le JEU dessine ensuite le
projectile qui voyage : la planche ne montre que le geste et sa lueur.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds
restent à plat pendant tout le geste, à la même place.

⚠️ AUCUN CERCLE AU SOL et aucune créature : le jeu dessine lui-même le cercle
d'invocation. Le violet reste SOMBRE ET BLEUTÉ, jamais rose vif : il ne doit
pas se confondre avec le fond magenta.

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
