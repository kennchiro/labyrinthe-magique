# L'Éveil du Mage de la Peste — le Seigneur du Fléau

> Le neuvième ÉVEIL des mages. Le Mage de la Peste ne frappe pas fort : il charge le monde de poison.
> Éveillé, il devient **le Seigneur du Fléau** pendant une minute. Le poursuivre, c'est s'empoisonner : il
> charge chaque ennemi de doses, puis fait tout éclater d'un coup.

**Jouable depuis le 2026-11-08** (`CharacterCatalog.peste_awakened`). Les cinq images ci-dessous ont été
commandées dans cet ordre ; elles sont découpées dans `assets/characters/peste_eveil`, `assets/icons/peste_eveil`, et
le corbeau dans `assets/allies/peste_corbeau_top.png` et `_side.png` par `tools/build_corbeau.py` (sa planche est
venue en 2172 x 724 au lieu de 2048 x 512 : l'outil la lit en grille, quelle que soit sa taille). Ses effets sont
peints au shader (`fleau_*`, palette dans `fleau.gdshaderinc`) ; `tools/preview_fleau.gd` les montre hors partie.
Tous ses sorts ont été vus en capture. Les chiffres ne sont pas mesurés.

**Fond MAGENTA**, comme d'habitude : il est noir, vert acide et bronze. ⚠️ Son manteau reste presque noir et
BLEUTÉ, jamais violet ; son vert reste un vert ACIDE qui tire sur le jaune. Aucun rose, aucun violet sur lui,
ni dans ses fumées.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Seigneur | ci-dessous, image 1 | `refonte/peste_eveil.png` | `refonte/peste.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/peste_eveil_marche.png` | `refonte/peste_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/peste_eveil_attaque.png` | `refonte/peste_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_peste_eveil_skills.png` | aucune |
| 5 | Le corbeau de peste | ci-dessous, image 5 | `creatures/peste_corbeau.png` | `refonte/peste_eveil.png` |

Aucun portrait à commander : la carte de l'écran de sélection reste celle du Mage de la Peste. Aucune image
pour les effets des sorts : ils seront peints au shader. Les corbeaux qui tournent autour de lui et la volée
de la fuite sont faits par le JEU à partir de la planche 5 : ils ne sont jamais dessinés sur ses planches à lui.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## Le Seigneur du Fléau

### Ce qu'il devient

On reconnaît le Mage de la Peste : sa **capuche** et son long **manteau presque noir à liserés vert acide**,
son **masque de médecin de peste** à long bec courbe, ses sangles de cuir, ses **fioles vertes** à la ceinture,
ses bottes de cuir, et son bâton tenu de la main DROITE. Mais il est devenu le fléau lui-même. Son masque est
devenu un **crâne-bec de bronze**, et ses deux verres ronds **brûlent** de vert acide. Le bas de son manteau
est **en lambeaux**, effrangé en pointes. Des **plaques de bronze** gravées de runes lui couvrent les épaules.
Son bâton tordu porte désormais un **encensoir** de bronze ajouré, plein d'un liquide vert qui luit. Les fioles
de sa ceinture sont plus nombreuses et bouillonnent.

Il reste chibi, à la même échelle que le Mage de la Peste. Les fumées, le miasme et les corbeaux ne sont **pas
dessinés** sur lui : c'est le jeu qui les fait.

### Son trait éveillé : Miasme

**Le poursuivre, c'est s'empoisonner.** Tant que dure l'Éveil, un miasme vert l'entoure : chaque ennemi collé à
lui (à une case) reçoit **une dose par seconde**. Le poison monte jusqu'à **5 doses** au lieu de 3. Trois
corbeaux de peste tournent autour de lui.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Dard venimeux | **Crachat du fléau** | le trait éclate à l'impact en une gerbe : une dose à tout ce qui est autour | 10 dégâts, gerbe rayon 1,2, 1 dose chacun, 8 cases |
| SKILL 1 | Traînée toxique | **Sillage pestilent** | une traînée plus longue ; ses flaques bouillonnent, collent et ralentissent | 8 s, flaques 6 s, 2 doses, ralentit à 60 %, recharge 13 s |
| SKILL 2 | Contagion | **Épidémie** | le poison saute d'ennemi en ennemi, et chaque saut blesse et ajoute des doses | 6 sauts de 4 cases au plus, 15 dégâts et 2 doses par saut, recharge 8 s |
| SKILL 3 | Transfusion | **Saignée** | toutes les doses autour de lui éclatent d'un coup ; il reprend de la vie sur ce qui a éclaté | 10 dégâts par dose, rayon 10, 1 PV pour 3 doses, recharge 18 s |
| FUITE | Brume | **Nuée de corbeaux** | il éclate en une volée de corbeaux qui passe par-dessus les haies et pique ce qu'elle survole, puis il se reforme dans un nuage | 6 cases, 10 dégâts et 2 doses au passage, nuage rayon 1,4 4 s, recharge 7 s |
| EXTRA | Pandémie | **La Grande Peste** | le ciel vire au vert, une pluie pestilente tombe sur toute la carte ; tout ennemi est chargé au maximum et ralenti, et ceux qui meurent éclatent en nuages qui contaminent leurs voisins | 10 s, ralentit à 70 %, nuage rayon 1,5 qui met 2 doses |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

Le cœur de son jeu est la **Saignée** : il charge tout le monde de doses (Miasme, Sillage, Épidémie), puis il fait
tout éclater d'un coup.

---

## Image 1 — le modèle du Seigneur

Joindre `assets/peso&cover/refonte/peste.png` (le Mage de la Peste, qu'il faut garder reconnaissable, et la mise
en page à reprendre).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le Mage de la Peste : c'est LE MÊME personnage, que tu dois
transformer, pas remplacer. Reprends aussi sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : les deux verres ronds du masque et l'encensoir se voient bien
2. vue DE DOS, immobile : la capuche, les plaques des épaules et le bas du manteau en lambeaux
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : le long bec du masque se voit en entier

LE PERSONNAGE — le Mage de la Peste ÉVEILLÉ en SEIGNEUR DU FLÉAU. On le reconnaît tout de suite :
même alchimiste au corps compact et à la tête un peu large, même CAPUCHE et même long MANTEAU
PRESQUE NOIR ET BLEUTÉ (#14161c) à LISERÉS VERT ACIDE (#b4f02a), mêmes sangles de cuir brun à
boucles de bronze, mêmes FIOLES vertes à la ceinture, mêmes bottes de cuir, et un bâton tenu de
la main DROITE. Ce qui change :
- son MASQUE est devenu un CRÂNE-BEC DE BRONZE (#a8743a), au long bec courbe, gravé de fines
  runes ; ses deux verres ronds BRÛLENT de VERT ACIDE vif (#d8ff5a), avec un cœur clair (#f2ff9e) ;
- le bas de son manteau est EN LAMBEAUX, effrangé en longues pointes déchirées, toujours bordées
  du liseré vert acide ;
- deux PLAQUES DE BRONZE (#a8743a) gravées de runes vert acide lui couvrent les épaules, par-dessus
  la capuche ;
- son bâton tordu en bois noir porte, à la place de la grosse fiole, un ENCENSOIR de bronze ajouré
  et rond, accroché court sous la tête du bâton, plein d'un liquide VERT ACIDE qui luit à travers
  les jours ;
- sa ceinture porte CINQ fioles vert acide au lieu de trois, et on voit des bulles dedans.
Toutes ses formes sont cernées d'un contour très foncé (#0c140a), net.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA SUR LUI, ni en reflet, ni en lueur. Le
manteau reste PRESQUE NOIR ET BLEUTÉ, jamais aubergine vif, jamais violet. Le vert reste un vert
ACIDE qui tire sur le jaune, jamais un vert de mousse. Ses couleurs sont le noir bleuté, le vert
acide, le bronze, le cuir brun et le contour sombre.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DU MAGE DE LA PESTE : UN CORPS CHIBI COMPACT, À LA
MÊME TAILLE. Posé à côté de l'image jointe, il fait la même hauteur.

⚠️ RÈGLE BLOQUANTE — AUCUNE FUMÉE, AUCUN NUAGE, AUCUNE GOUTTE DÉTACHÉE, AUCUN CORBEAU autour de lui,
aucune flaque au sol. Le jeu s'en charge. L'encensoir ne fume pas sur cette planche.

⚠️ RÈGLE BLOQUANTE — L'ENCENSOIR RESTE ACCROCHÉ COURT sous la tête du bâton, collé à lui : il ne
pend pas au bout d'une longue chaîne.

⚠️ RÈGLE BLOQUANTE — LES LAMBEAUX NE CACHENT PAS LES PIEDS. Les deux bottes se voient sous le
manteau, séparées l'une de l'autre, même en très petit.

⚠️ RÈGLE BLOQUANTE — UN CONTOUR CLAIR. Le manteau sombre garde son liseré vert net sur tous ses
bords, lambeaux compris : il doit rester lisible sur un sol sombre.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même
masque, le bâton à l'encensoir toujours dans la main DROITE.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune lueur floue.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le manteau tire vers le violet ou l'aubergine vif | Il partirait avec le fond magenta, et ressemblerait au Seigneur du Néant |
| Le vert tire vers la mousse | Il ressemblerait au Colosse de la Terre |
| Une fumée, une flaque ou des corbeaux autour de lui | Le jeu les dessine lui-même : ils seraient en double, et le détourage les couperait |
| L'encensoir pend au bout d'une longue chaîne | Il déborderait de la case, et se balancerait différemment d'une planche à l'autre |
| Les lambeaux cachent les bottes | La marche ne se lirait plus |
| Il est plus grand que le Mage de la Peste | Il ne doit pas changer de taille en s'éveillant |
| Le bâton a changé de main | Toutes ses poses de marche le reprendraient à l'envers |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/peste_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son masque, sa capuche, son
manteau, ses plaques, ses fioles, son bâton, ses couleurs et ses proportions, mais PAS sa
mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage de la Peste éveillé en SEIGNEUR DU FLÉAU, en proportions CHIBI, corps
compact : capuche et long MANTEAU PRESQUE NOIR ET BLEUTÉ à liserés VERT ACIDE, bas du manteau EN
LAMBEAUX, MASQUE CRÂNE-BEC DE BRONZE aux deux verres VERT ACIDE brûlants, PLAQUES DE BRONZE aux
épaules, cinq FIOLES vertes à la ceinture, et BÂTON tordu à ENCENSOIR de bronze dans la main
DROITE. Contour très foncé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale
est la même dans les 24 cases.

Il MARCHE d'un pas souple et un peu voûté, comme un médecin qui fait sa tournée. IL NE COURT PAS :
le buste reste penché très légèrement en avant, sans bouger d'une image à l'autre. Ses pas sont
de la MÊME LONGUEUR que sur le guide. Les lambeaux du manteau flottent un peu différemment à chaque
image. L'encensoir oscille un peu au bout du bâton.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps.
- LE BRAS GAUCHE (main libre, gantée) balance en grand, de l'avant vers l'arrière ;
- LE BRAS DROIT (celui du bâton) balance AUSSI, moins loin : la main avance et recule, et le
  bâton suit en s'inclinant, son pied passant un peu devant puis un peu derrière, sans jamais
  toucher le sol.

LE BALANCEMENT DES BRAS, image par image, calé sur les jambes du guide :
1. bras gauche tendu vers l'AVANT, main à hauteur de taille ; main du bâton vers l'ARRIÈRE
2. bras gauche qui redescend, coude un peu plié ; main du bâton qui revient
3. les deux bras le long du corps, POINT DE PASSAGE (c'est l'image aux jambes jointes)
4. bras gauche qui part vers l'arrière ; main du bâton qui part vers l'avant
5. l'INVERSE de l'image 1 : bras gauche vers l'ARRIÈRE, main du bâton vers l'AVANT
6. main du bâton qui revient ; bras gauche qui revient
7. les deux bras le long du corps, POINT DE PASSAGE (jambes jointes)
8. bras gauche qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui avance
grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, avec SON
bâton à encensoir à lui.

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
trois rangées, les images 5 à 8 ne répètent pas les images 1 à 4.

⚠️ RÈGLE BLOQUANTE — LES BRAS NE SONT JAMAIS FIGÉS. Les images 1 et 5 montrent les bras inversés.
Deux images voisines identiques pour les bras sont une erreur. Le bâton suit sa main.

⚠️ RÈGLE BLOQUANTE — LES LAMBEAUX NE CACHENT JAMAIS LES PIEDS : les deux bottes se voient dans les
24 cases, et le pied du bâton ne passe jamais pour un troisième pied : il reste au-dessus du sol.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LE BÂTON ET LES LAMBEAUX BOUGENT. Dans une même
rangée, la tête, la capuche et le tronc se superposent exactement d'une case à l'autre, et le
profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui ; le manteau reste presque noir et bleuté,
aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune fumée, aucune goutte, aucun corbeau.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/peste_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT son masque, sa capuche, son manteau, ses plaques, ses fioles, son
bâton, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage de la Peste éveillé en SEIGNEUR DU FLÉAU, en proportions CHIBI, corps
compact : capuche et manteau presque noirs et bleutés à liserés vert acide, bas en lambeaux,
masque crâne-bec de bronze aux verres vert acide brûlants, plaques de bronze aux épaules, fioles à
la ceinture, BÂTON À ENCENSOIR dans la main DROITE. Contour très foncé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il
BALANCE SON ENCENSOIR comme une fronde et en crache le venin.
1. posture prête, le bâton droit dans la main droite
2. il ramène le bâton en arrière, à deux mains, l'encensoir derrière lui
3. il arme : le buste se tord, l'encensoir au plus loin derrière
4. LE COUP : il balance le bâton DEVANT lui, dans la direction de la rangée, et une petite
   éclaboussure VERT ACIDE, plus petite que sa tête, jaillit de l'encensoir
5. l'éclaboussure a disparu, le bâton reste tendu
6. il ramène le bâton
7. le bâton revient à la verticale, dans la main droite
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est la petite éclaboussure de
l'image 4, collée à l'encensoir. Pas de jet, pas de nuage, pas de flaque : le JEU les dessine.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, ni en reflet du fond.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune fumée, aucune goutte détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc et la tête se
superposent exactement dans les 8 images d'une rangée (seuls les bras, le bâton, le manteau et les
genoux bougent).

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, il regarde VERS LA DROITE
dans les 8 cases.
```

---

## Image 4 — les six icônes éveillées

Aucune image à joindre.

```
Planche de six ICÔNES DE SORTS pour un jeu de rôle mobile, style cartoon coloré,
contours nets, lisibles en tout petit.

PERSONNAGE : le Mage de la Peste éveillé en SEIGNEUR DU FLÉAU, un médecin de peste devenu le fléau
lui-même. Ses couleurs sont le VERT ACIDE (#b4f02a), le VERT CLAIR (#f2ff9e), le VERT SOMBRE
(#4e8a12), le NOIR BLEUTÉ (#14161c), le BRONZE (#a8743a) et le CUIR BRUN (#5a3a1e), avec un CONTOUR
TRÈS FONCÉ (#0c140a) net autour de chaque forme. Le motif commun des six icônes est la GOUTTE DE
VENIN vert acide et le BRONZE gravé : ils doivent se retrouver dans chacune.

FORMAT, à respecter exactement :
- image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 2 rangées, soit 6 cases de 512 x 512
- fond MAGENTA UNI #FF00FF partout, y compris entre les cases, sans dégradé
- NE PAS dessiner les lignes de la grille, ni cadre, ni numéro, ni texte
- une seule icône par case, CENTRÉE, occupant environ 70 % de sa case
- une forme à peu près aussi large que haute, qui tiendrait dans un cercle
- au moins 40 pixels de vide magenta tout autour de chaque icône
- rien ne dépasse sur la case voisine, ni en haut ni en bas

LES SIX ICÔNES, dans cet ordre de lecture :

1. CRACHAT DU FLÉAU — une grosse goutte de venin vert acide qui éclate en couronne de gouttelettes,
   jaillie d'un petit encensoir de bronze.

2. SILLAGE PESTILENT — une traînée d'empreintes de bottes dans des flaques vert acide qui
   bouillonnent, avec de grosses bulles qui éclatent.

3. ÉPIDÉMIE — cinq petits crânes vert acide reliés en chaîne par un trait de venin qui saute de
   l'un à l'autre.

4. SAIGNÉE — un crâne vert acide qui éclate en étoile de gouttes, et une goutte de vie rouge qui
   remonte vers un masque à bec de bronze.

5. NUÉE DE CORBEAUX — trois corbeaux noirs aux yeux vert acide qui s'envolent en spirale d'un
   petit nuage vert.

6. LA GRANDE PESTE — un grand masque crâne-bec de bronze aux yeux vert acide brûlants, sous une
   pluie de gouttes vertes, des volutes de miasme vert tout autour. C'est l'icône la plus
   spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune fumée floue, aucune lueur floue, aucune case vide, AUCUN ROSE
NI VIOLET dans les icônes : ils se confondraient avec le fond magenta. Le miasme est VERT, jamais
violet. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Image 5 — le corbeau de peste

Joindre `assets/peso&cover/refonte/peste_eveil.png` (pour le style et les couleurs). Le jeu s'en sert pour
les trois corbeaux qui tournent autour de lui pendant l'Éveil, et pour la volée de la Nuée de corbeaux : il
les fait tourner dans le sens de leur vol. Il lui faut donc un corbeau vu de DESSUS, et un de profil.

```
Feuille de sprites d'un oiseau pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe
montre son maître, le Seigneur du Fléau : reprends son style et ses couleurs, pas le personnage.

FORMAT, à respecter exactement :
- UNE image de 2048 x 512 pixels
- grille RÉGULIÈRE de 8 colonnes x 2 rangées, soit 16 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, l'oiseau est CENTRÉ, entier, ailes comprises, et occupe environ 70 % de la
  case dans sa plus grande dimension
- rien ne dépasse sur la case voisine, et 12 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

L'OISEAU — un CORBEAU DE PESTE, petit et vif : plumes NOIR BLEUTÉ (#14161c) aux reflets bleu
nuit, bec de BRONZE (#a8743a) un peu courbe comme le masque de son maître, YEUX VERT ACIDE
brûlants (#d8ff5a), et un fin liseré VERT ACIDE (#b4f02a) au bout des grandes plumes des ailes et
de la queue, pour qu'il se lise sur un sol sombre. Contour très foncé (#0c140a) net.

LES DEUX RANGÉES :
- rangée 1 : VU DE DESSUS, exactement d'en haut, il vole vers le HAUT de l'image (tête en haut,
  queue en bas), ailes ouvertes de chaque côté
- rangée 2 : DE PROFIL, TOURNÉ VERS LA DROITE, il vole vers la droite

LES 8 COLONNES de chaque rangée sont UN BATTEMENT D'AILES qui boucle : ailes tout en haut, qui
descendent, à plat, tout en bas, qui remontent, à plat, presque en haut, puis l'image enchaîne sur
la première. Vu de dessus, le battement se lit par l'envergure : ailes grandes ouvertes à plat,
puis repliées vers le corps.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : dans une même rangée, le corps et
la tête se superposent exactement ; seules les ailes et la queue bougent.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE dans les 16 cases.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, ni en reflet, ni en lueur ; les reflets des plumes
sont BLEU NUIT, jamais violets.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune plume détachée, aucune fumée, aucune
traînée.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Des reflets violets dans le noir des plumes | Le détourage y ferait des trous |
| La rangée du dessus est vue de trois quarts | Le jeu le fait tourner dans le sens du vol : de trois quarts, il volerait de travers |
| Des plumes détachées autour | Elles tourneraient avec lui, en morceaux |

---

## Les effets visuels, sort par sort

Ils seront peints au shader, comme ceux des autres Éveils. Mêmes règles : trois temps (départ, coup, trace
qui s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette du Fléau

| rôle | couleur | usage |
|---|---|---|
| Le cœur | `#f2ff9e` | bulles qui éclatent, instant du coup |
| Le venin | `#b4f02a` | matière principale, gouttes, flaques |
| Le venin vif | `#d8ff5a` | yeux, lueurs, éclats de la Saignée |
| L'ombre du venin | `#4e8a12` | creux des flaques, volutes du miasme |
| Le noir bleuté | `#14161c` | les corbeaux, le ciel de la Grande Peste |
| Le bronze | `#a8743a` | l'encensoir, les sceaux gravés |
| Le cerne | `#0c140a` | contour |

Le motif commun est **la goutte de venin qui éclate en couronne**, et le **crâne-bec** pour les grands coups.
Jamais de violet : la nuit du poison est noire et bleutée.

### L'Éveil lui-même

- **La charge, 0,8 s :** des volutes vertes montent en spirale autour de lui, des bulles éclatent à ses pieds.
- **L'éclosion :** une flaque de venin s'ouvre sous lui et bouillonne, un geyser vert jaillit, trois corbeaux en
  sortent et prennent leur ronde ; la caméra tremble.
- **Pendant la minute :** le miasme, un anneau de fumée verte basse, tourne à ses pieds ; les trois corbeaux
  tournent au-dessus.
- **La fin :** les corbeaux s'envolent au loin, le miasme retombe en flaque et sèche.

### Les six sorts

- **Crachat du fléau :** une goutte lourde qui file, puis éclate en couronne de gouttelettes au sol.
- **Sillage pestilent :** des flaques plus larges, qui bouillonnent ; ce qui y marche a les pieds pris de vert.
- **Épidémie :** un trait de venin saute de crâne en crâne, et chaque victime s'allume d'un petit crâne vert.
- **Saignée :** chaque ennemi chargé gonfle une seconde, puis éclate en gerbe verte proportionnée à ses doses ; des
  gouttes de vie remontent vers le mage.
- **Nuée de corbeaux :** il éclate en plumes, une volée de corbeaux file par-dessus les haies, puis se rassemble
  en tourbillon et le recrache dans un nuage.
- **La Grande Peste :** le ciel vire au vert sombre, une pluie de gouttes tombe sur tout l'écran, un grand masque
  crâne-bec se dessine dans le ciel le temps de l'ouverture, et chaque mort éclate en nuage.
