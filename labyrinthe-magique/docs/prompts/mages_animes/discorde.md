# Démone de la Discorde — planches de marche et d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/discorde.png`
au générateur, pour qu'il garde le même personnage. Pour la marche, joindre AUSSI
`docs/prompts/mages_animes/guide_marche.png`, qui impose la position des pieds.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/discorde_marche.png
    assets/peso&cover/mages/discorde_attaque.png

La gauche n'est PAS demandée : le jeu retourne le profil droit.

---

## Prompt 1 — la marche

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le personnage : garde EXACTEMENT son visage, ses couleurs,
ses vêtements et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — la Démone de la Discorde, une femme ADULTE, HUMAINE et noble. Peau
claire, cheveux noirs relevés en un chignon haut et serré, retenu par une épingle
d'argent, yeux vert jade. Longue redingote vert sapin très sombre (#12463a), sobre
et couvrante, à col haut, brodée de fils entrelacés en argent, dont les pans
s'ouvrent à partir de la taille et s'arrêtent à mi-cuisse. Pantalon noir ajusté,
bottes noires à boucles d'argent, gants noirs à fines bagues d'argent. Mains vides.
Un fin liseré ARGENTÉ cerne ses formes sombres. MORPHOLOGIE CHIBI, celle des mages :
sa hauteur totale vaut 2,5 TÊTES, la tête (coiffure comprise) occupe près de 40 % de
la hauteur, et les jambes à peine un quart. Grosses mains, gros pieds, torse court,
jamais de corps élancé ni de petite tête. Silhouette lisible en très petit. Aucune
corne, queue ni aile.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vue DE FACE, elle avance vers le bas de l'image
- rangée 2 : vue DE DOS, elle s'éloigne vers le haut de l'image
- rangée 3 : vue DE PROFIL, TOURNÉE VERS LA DROITE, elle avance vers la droite de l'image

SES JAMBES : les pans de la redingote s'ouvrent et ses bottes sortent franchement à
chaque pas. DE PROFIL, les jambes ne gardent jamais la même pose : aux images 3 et 7,
elles sont JOINTES, les deux pieds l'un sur l'autre, sur moins de la moitié de la
largeur des images 1 et 5.
SES MAINS : elles restent vides, et les bras balancent doucement près du corps.

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

⚠️ RÈGLE BLOQUANTE — POSE DES JAMBES. De profil, aux images 1 et 5, les pieds sont séparés
d'environ un tiers de la hauteur du personnage, jamais plus, et échangent leur place entre
les deux poses. Les images 5 à 8 ne répètent PAS les images 1 à 4 : la botte qui se voit en
entier est devant à l'image 1, et derrière à l'image 5. Aux images 3 et 7, les jambes sont
RAPPROCHÉES et les pieds se chevauchent. De face et de dos, les pieds restent sous le corps.
Aucun grand écart ni saut à pieds joints.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE. Une ombre sous le personnage
et un trait entre les cases ne s'effacent pas : ils resteraient collés au sprite.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE. Empile mentalement
les 8 images d'une rangée : le TRONC et la TÊTE se superposent exactement. Elle garde
la même taille, CENTRÉE au même endroit. C'est le JEU qui la fait avancer sur la
carte : la planche montre les membres, sur place, comme sur un tapis roulant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas de ses pieds touche la même
ligne horizontale dans les 24 cases, et rien n'est dessiné plus bas que cette ligne.

⚠️ RÈGLE BLOQUANTE — ELLE NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage
regarde VERS LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur elle, aucun reflet du fond magenta.

AUCUNE magie, aucun fil, aucune lueur sur cette planche : elle marche, c'est tout.
```

---

## Prompt 2 — l'attaque

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le personnage : garde EXACTEMENT son visage, ses couleurs,
ses vêtements et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — la Démone de la Discorde, une femme ADULTE, HUMAINE et noble. Peau
claire, cheveux noirs relevés en un chignon haut et serré, retenu par une épingle
d'argent, yeux vert jade. Longue redingote vert sapin très sombre (#12463a), sobre
et couvrante, à col haut, brodée de fils entrelacés en argent, dont les pans
s'ouvrent à partir de la taille et s'arrêtent à mi-cuisse. Pantalon noir ajusté,
bottes noires à boucles d'argent, gants noirs à fines bagues d'argent. Mains vides.
Un fin liseré ARGENTÉ cerne ses formes sombres. MORPHOLOGIE CHIBI, celle des mages :
sa hauteur totale vaut 2,5 TÊTES, la tête (coiffure comprise) occupe près de 40 % de
la hauteur, et les jambes à peine un quart. Grosses mains, gros pieds, torse court,
jamais de corps élancé ni de petite tête. Aucune corne, queue ni aile.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le
tronc ont les mêmes dimensions en pixels. Un corps plus petit se verrait comme un
rétrécissement à chaque sort.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : elle lance VERS LE BAS DE L'IMAGE, face au joueur : le bras vient VERS
  NOUS, jamais sur le côté
- rangée 2 : elle lance VERS LE HAUT DE L'IMAGE, de dos : le bras s'éloigne de nous,
  jamais sur le côté
- rangée 3 : elle lance VERS LA DROITE, de profil, TOURNÉE VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE de marionnettiste, de gauche à droite,
pas une boucle :
1. posture prête, la main droite près de la poitrine
2. elle lève la main, les doigts réunis et tournés vers le haut
3. elle tire la main en arrière, comme pour tendre un fil
4. L'IMPACT : bras tendu vers l'avant, doigts écartés d'un coup, et un petit éclat
   ARGENTÉ au bout des doigts
5. l'éclat a disparu, les doigts restent écartés
6. elle referme lentement les doigts
7. le bras revient près du corps
8. elle retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, et le corps reste
CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais l'ensemble corps et bras.

⚠️ RÈGLE BLOQUANTE — AUCUN FIL, AUCUN SORT DESSINÉ. Le seul effet de la planche est le
petit éclat argenté de l'image 4, plus petit que sa main. Le JEU dessine lui-même les
fils et les sorts, à la bonne couleur.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds
restent à plat pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur elle, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE. Une ombre sous le personnage
et un trait entre les cases ne s'effacent pas : ils resteraient collés au sprite.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE. Empile mentalement
les 8 images d'une rangée : le TRONC et la TÊTE se superposent exactement. Elle garde
la même taille, CENTRÉE au même endroit.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas de ses pieds touche la même
ligne horizontale dans les 24 cases, et rien n'est dessiné plus bas que cette ligne.

⚠️ RÈGLE BLOQUANTE — ELLE NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage
regarde VERS LA DROITE dans les 8 cases.
```

---

## À vérifier sur la planche reçue

| Défaut | Conséquence en jeu |
|---|---|
| Une ombre ou un trait de grille | Une salissure reste collée au sprite |
| Le corps se déplace dans la case | Elle tressaute en marchant |
| Le corps est plus petit sur l'attaque | Elle rétrécit à chaque sort |
| Le bras part sur le côté en rangée 1 ou 2 | Elle semble tirer à côté de sa cible |
| Les pieds gardent le même écart de profil | Elle glisse sur le sol |
| La même botte reste devant aux images 1 et 5 | Elle marche sur une seule jambe |
| Des fils ou une lueur rose sont dessinés | Le détourage y ferait des trous |

Si seul le profil est mauvais, ne regénère que lui : [profil_anges](profil_anges.md) donne la méthode, à
déposer sous `mages/discorde_profil.png`.
