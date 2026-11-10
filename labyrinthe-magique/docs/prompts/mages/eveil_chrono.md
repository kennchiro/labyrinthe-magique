# L'Éveil du Chronomancien — le Seigneur des Heures

> Le huitième ÉVEIL des mages. Le Chronomancien ne fuit pas : il revient en arrière, il ralentit, il répare.
> Éveillé, il devient **le Seigneur des Heures** pendant une minute : son propre temps file plus vite que
> celui du monde, il fige ce qui entre dans son dôme, il rembobine ses blessures, et il arrête le temps pour
> accumuler ses coups jusqu'à un jugement final.

**Jouable depuis le 2026-11-08** (`CharacterCatalog.chrono_awakened`). Les quatre images ci-dessous ont été
commandées dans cet ordre, la première servant de modèle aux trois autres ; elles sont découpées dans
`assets/characters/chrono_eveil` et `assets/icons/chrono_eveil`. Ses effets sont peints au shader (`heures_*`,
palette dans `heures.gdshaderinc`) ; `tools/preview_heures.gd` les montre hors partie. Tous ses sorts ont été vus
en capture. Les chiffres ne sont pas mesurés.

**Fond MAGENTA**, comme d'habitude : il est sarcelle, cuivre et or. ⚠️ Ses cheveux sont BLANCS : sur le fond
magenta, leurs ombres doivent être BLEU-GRIS, jamais mauves, sinon le détourage y fait des trous (le piège
déjà rencontré sur le Souverain des Vents). Aucun rose, aucun violet sur lui.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Seigneur | ci-dessous, image 1 | `refonte/chrono_eveil.png` | `refonte/chrono.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/chrono_eveil_marche.png` | `refonte/chrono_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/chrono_eveil_attaque.png` | `refonte/chrono_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_chrono_eveil_skills.png` | aucune |

Aucun portrait à commander : la carte de l'écran de sélection reste celle du Chronomancien. Aucune image pour
les effets des sorts : ils seront peints au shader.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## Le Seigneur des Heures

### Ce qu'il devient

On reconnaît le Chronomancien : ses **cheveux blancs en épis**, ses **yeux sarcelle**, son long **manteau
sarcelle à liserés de cuivre** au col haut, sa ceinture à boucle d'engrenage, ses bottes de cuir à rivets, le
**sablier de cuivre** porté dans le dos, et son **bâton-horloge** tenu de la main DROITE. Mais il est devenu
le maître des heures. Une **auréole d'horloge** en laiton flotte derrière sa tête : un anneau gravé de chiffres
romains, avec deux aiguilles. Son **sablier dorsal brille**, et le sable sarcelle y **remonte** vers le haut.
Des **engrenages de cuivre** lui font des épaulières. Son bâton est devenu un **sceptre** surmonté d'une grande
horloge à cadran sarcelle, cerclée d'or. Ses **yeux s'allument** de sarcelle vif. Des **chiffres romains d'or**
sont brodés sur le bas de son manteau.

Il reste chibi, à la même échelle que le Chronomancien. L'horloge géante de l'Extra et l'horloge sous ses pieds
ne sont **pas dessinées** : c'est le jeu qui les fait.

### Son trait éveillé : Temps accéléré

**Son temps file plus vite que celui du monde.** Tant que dure l'Éveil, ses recharges reviennent **50 % plus
vite**, il marche **15 % plus vite**, et une horloge sarcelle tourne sous ses pieds, ses aiguilles à toute
allure.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Aiguille | **Trois Aiguilles** | l'aiguille des heures, celle des minutes et la trotteuse partent en éventail sur trois cibles ; chacune ralentit ce qu'elle touche | 14 dégâts chacune, 8 cases, 0,5 s, ralentit 0,5 s |
| SKILL 1 | Bulle de lenteur | **Dôme de stase** | une bulle plus grande ; ce qui y entre est d'abord FIGÉ net, puis se traîne au ralenti | rayon 3, 8 s, 12/s, fige 1,5 s à l'entrée, puis ralenti à 35 %, recharge 12 s |
| SKILL 2 | Écho | **Paradoxe** | deux doubles rejouent ses 5 et ses 10 dernières secondes de marche, et chacun explose en onde d'horloge au bout de son trajet | 60 au passage, onde 30 dégâts rayon 1,5, recharge 9 s |
| SKILL 3 | Sablier | **Rembobinage** | il récupère d'un coup les PV perdus dans les 5 dernières secondes ; les chiffres de dégâts remontent vers lui | 5 s en arrière, recharge 20 s |
| FUITE | Retour | **Saut temporel** | il revient où il était il y a 4 s, et laisse là où il partait une bombe-horloge qui sonne et fige tout autour | bombe 1,5 s, 25 dégâts, fige 1,5 s, rayon 1,8, recharge 7 s |
| EXTRA | Arrêt du temps | **Jugement des Heures** | une horloge géante couvre l'écran et le temps s'arrête ; ses coups s'accumulent au-dessus des ennemis, puis tombent tous ensemble quand les aiguilles atteignent midi | 5 s d'arrêt, coups accumulés rendus à 150 % |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

---

## Image 1 — le modèle du Seigneur

Joindre `assets/peso&cover/refonte/chrono.png` (le Chronomancien, qu'il faut garder reconnaissable, et la mise
en page à reprendre).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le Chronomancien : c'est LE MÊME personnage, que tu dois
transformer, pas remplacer. Reprends aussi sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre arabe, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le visage, l'auréole d'horloge et le sceptre se voient bien
2. vue DE DOS, immobile : le sablier dorsal et son sable qui remonte se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile

LE PERSONNAGE — le Chronomancien ÉVEILLÉ en SEIGNEUR DES HEURES. On le reconnaît tout de suite :
même jeune mage au corps compact, mêmes CHEVEUX BLANCS EN ÉPIS, mêmes YEUX SARCELLE, même long
MANTEAU SARCELLE (#14605e) à LISERÉS DE CUIVRE (#c8742c) et au col haut, même ceinture à boucle
d'engrenage, mêmes bottes de cuir brun à rivets, même SABLIER DE CUIVRE porté dans le dos, et un
bâton tenu de la main DROITE. Ce qui change :
- une AURÉOLE D'HORLOGE en laiton doré (#e0b04a) flotte derrière sa tête, un peu au-dessus : un
  anneau fin gravé de CHIFFRES ROMAINS, avec deux aiguilles, qui ne cache pas son visage ;
- son SABLIER DORSAL BRILLE : le sable SARCELLE VIF (#3fe0d0) y REMONTE vers le haut, contre la gravité ;
- des ENGRENAGES DE CUIVRE lui font deux épaulières ;
- son bâton est devenu un SCEPTRE de cuivre surmonté d'une GRANDE HORLOGE à cadran sarcelle,
  cerclée d'or, ses aiguilles sur midi ;
- ses YEUX brillent de SARCELLE VIF (#3fe0d0) ;
- des CHIFFRES ROMAINS D'OR (#e0b04a) sont brodés le long du bas de son manteau.
Toutes ses formes sont cernées d'un contour brun très foncé (#1a0e08), net.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA SUR LUI, ni en reflet, ni en lueur.
SES CHEVEUX BLANCS S'OMBRENT DE BLEU-GRIS (#9fb0bf), JAMAIS DE MAUVE : le fond magenta serait retiré
avec. Ses couleurs sont le sarcelle, le cuivre, l'or, le brun, le blanc et la peau.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DU CHRONOMANCIEN : UN CORPS CHIBI COMPACT, À LA MÊME
TAILLE. Posé à côté de l'image jointe, il fait la même hauteur, auréole non comprise.

⚠️ RÈGLE BLOQUANTE — AUCUNE GRANDE HORLOGE AU SOL, aucun cercle, aucun double, aucune particule
détachée autour de lui. Le jeu s'en charge.

⚠️ RÈGLE BLOQUANTE — L'AURÉOLE RESTE PETITE ET COLLÉE : pas plus large que sa tête et ses cheveux,
juste derrière eux.

⚠️ RÈGLE BLOQUANTE — SES PIEDS SE LISENT EN TRÈS PETIT. Les deux bottes se voient sous le manteau,
séparées l'une de l'autre.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même
auréole, le sceptre toujours dans la main DROITE, le sablier toujours dans le dos.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune lueur floue.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Des ombres mauves dans le blanc des cheveux | Le détourage y ferait des trous : c'est le piège du blanc sur fond magenta |
| Du rose ou du violet sur lui, en reflet ou en lueur | Il partirait avec le fond |
| Une horloge au sol, un double, des particules | Le jeu les dessine lui-même : ils seraient en double |
| Il est plus grand que le Chronomancien | Il ne doit pas changer de taille en s'éveillant |
| L'auréole est immense | Elle élargirait la case commune de tous les mages |
| Le sceptre a changé de main | Toutes ses poses de marche le reprendraient à l'envers |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/chrono_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT ses cheveux, son auréole, son
manteau, son sablier, son sceptre, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Chronomancien éveillé en SEIGNEUR DES HEURES, en proportions CHIBI, corps
compact : cheveux blancs en épis, petite AURÉOLE D'HORLOGE dorée à chiffres romains derrière la
tête, yeux sarcelle lumineux, long MANTEAU SARCELLE à liserés de cuivre et chiffres romains d'or,
épaulières d'ENGRENAGES de cuivre, SABLIER de cuivre dans le dos où le sable sarcelle remonte, et
SCEPTRE-HORLOGE dans la main DROITE. Contour brun très foncé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale
est la même dans les 24 cases.

Il MARCHE d'un pas VIF et régulier, comme le tic-tac d'une horloge. IL NE COURT PAS : le buste
reste DROIT. Ses pas sont de la MÊME LONGUEUR que sur le guide. Le bas de son manteau ondule un peu
différemment à chaque image. L'auréole reste à la même place derrière sa tête.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps.
- LE BRAS GAUCHE (main libre) balance en grand, de l'avant vers l'arrière ;
- LE BRAS DROIT (celui du sceptre) balance AUSSI, moins loin : la main avance et recule, et le
  sceptre suit en s'inclinant, son pied passant un peu devant puis un peu derrière, sans jamais
  toucher le sol.

LE BALANCEMENT DES BRAS, image par image, calé sur les jambes du guide :
1. bras gauche tendu vers l'AVANT, main à hauteur de taille ; main du sceptre vers l'ARRIÈRE
2. bras gauche qui redescend, coude un peu plié ; main du sceptre qui revient
3. les deux bras le long du corps, POINT DE PASSAGE (c'est l'image aux jambes jointes)
4. bras gauche qui part vers l'arrière ; main du sceptre qui part vers l'avant
5. l'INVERSE de l'image 1 : bras gauche vers l'ARRIÈRE, main du sceptre vers l'AVANT
6. main du sceptre qui revient ; bras gauche qui revient
7. les deux bras le long du corps, POINT DE PASSAGE (jambes jointes)
8. bras gauche qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui avance
grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, avec SON
sceptre et SON sablier à lui.

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
Deux images voisines identiques pour les bras sont une erreur. Le sceptre suit sa main.

⚠️ RÈGLE BLOQUANTE — LE MANTEAU NE CACHE JAMAIS LES PIEDS : les deux bottes se voient dans les
24 cases, et le pied du sceptre ne passe jamais pour un troisième pied : il reste au-dessus du sol.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LE SCEPTRE ET LE BAS DU MANTEAU BOUGENT. Dans une
même rangée, la tête, l'auréole et le tronc se superposent exactement d'une case à l'autre, et le
profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui ; ses cheveux blancs s'ombrent de BLEU-GRIS,
jamais de mauve, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule détachée.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/chrono_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT ses cheveux, son auréole, son manteau, son sablier, son sceptre, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Chronomancien éveillé en SEIGNEUR DES HEURES, en proportions CHIBI, corps
compact : cheveux blancs en épis, petite auréole d'horloge dorée derrière la tête, yeux sarcelle,
manteau sarcelle à liserés de cuivre, épaulières d'engrenages, sablier dans le dos, SCEPTRE-HORLOGE
dans la main DROITE. Contour brun très foncé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il
REMONTE SON HORLOGE puis tranche l'air du sceptre pour lancer ses aiguilles.
1. posture prête, le sceptre droit dans la main droite
2. il ramène le sceptre contre lui, la main gauche posée sur le cadran
3. la main gauche tourne le cadran d'un geste sec, ses yeux s'allument plus fort
4. LE COUP : il balaie le sceptre DEVANT lui, dans la direction de la rangée, et un petit éclat
   sarcelle en forme de cadran, plus petit que sa tête, brille au bout du sceptre
5. l'éclat a disparu, le sceptre reste tendu
6. il ramène le sceptre
7. le sceptre revient à la verticale
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit éclat de l'image
4. Pas d'aiguilles volantes, pas d'horloge au sol : le JEU les dessine.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, ni en reflet du fond ; ses cheveux blancs
s'ombrent de BLEU-GRIS.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune fumée, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc et la tête se
superposent exactement dans les 8 images d'une rangée (seuls les bras, le sceptre, le manteau et
les genoux bougent).

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

PERSONNAGE : le Chronomancien éveillé en SEIGNEUR DES HEURES, maître du temps. Ses couleurs sont le
SARCELLE (#14605e), le SARCELLE VIF (#3fe0d0), le CUIVRE (#c8742c), l'OR (#e0b04a), le BLANC (#f4f1e8)
et le BRUN (#3a2414), avec un CONTOUR BRUN TRÈS FONCÉ (#1a0e08) net autour de chaque forme. Le motif
commun des six icônes est le CADRAN D'HORLOGE (un cercle d'or aux chiffres romains, cadran sarcelle) :
il doit se retrouver dans chacune.

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

1. TROIS AIGUILLES — trois aiguilles d'horloge d'or (une courte, une longue, une fine trotteuse)
   qui partent en éventail d'un petit cadran, avec des traits de vitesse sarcelle.

2. DÔME DE STASE — un dôme de verre sarcelle vu en légère plongée, un cadran gravé au sol dessous,
   et à l'intérieur une petite silhouette de monstre FIGÉE, cernée de glace sarcelle.

3. PARADOXE — deux silhouettes du mage, une claire et une translucide sarcelle, qui marchent en sens
   contraire autour d'un cadran, reliées par une flèche en boucle.

4. REMBOBINAGE — un cœur rouge traversé d'une flèche circulaire qui tourne À REBOURS, sur un cadran
   dont les aiguilles reculent.

5. SAUT TEMPOREL — un réveil de cuivre à deux cloches qui sonne, entouré d'ondes sarcelle, et une
   flèche courbe qui part vers l'arrière.

6. JUGEMENT DES HEURES — une immense horloge d'or aux chiffres romains, ses deux aiguilles sur midi,
   des engrenages tout autour et des éclats de lumière sarcelle. C'est l'icône la plus
   spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre arabe, pas de flou, aucune fumée floue, aucune lueur floue, aucune case vide, AUCUN
ROSE NI VIOLET dans les icônes : ils se confondraient avec le fond magenta. Le blanc s'ombre de
BLEU-GRIS. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Ils seront peints au shader, comme ceux des autres Éveils. Mêmes règles : trois temps (départ, coup, trace
qui s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette du Seigneur

| rôle | couleur | usage |
|---|---|---|
| Le sarcelle | `#14605e` | les cadrans, le fond du dôme |
| Le sarcelle vif | `#3fe0d0` | la lumière du temps, les ondes, les éclats |
| L'or | `#e0b04a` | les chiffres romains, les aiguilles, les engrenages |
| Le cuivre | `#c8742c` | les engrenages, les bombes-horloges |
| Le blanc | `#f4f1e8` | l'instant du coup |
| Le cerne | `#1a0e08` | contour |

Le motif commun est **le cadran** : un cercle d'or aux chiffres romains, sur fond sarcelle, avec ses aiguilles.

### L'Éveil lui-même

- **La charge, 0,8 s :** des engrenages d'or tournent autour de lui de plus en plus vite.
- **L'éclosion :** une horloge géante s'ouvre au sol sous lui, ses aiguilles font un tour complet en un éclair,
  puis une onde sarcelle part au sol avec un « tic » de caméra.
- **Pendant la minute :** une petite horloge tourne sous ses pieds, aiguilles à toute allure.
- **La fin :** l'horloge ralentit, ses aiguilles s'arrêtent, et elle se brise en engrenages.

### Les six sorts

- **Trois Aiguilles :** trois aiguilles d'or filent en éventail ; chaque touché laisse un petit cadran qui tourne
  au ralenti au-dessus de la cible.
- **Dôme de stase :** un dôme de verre sarcelle à cadran au sol ; ce qui y entre se couvre d'un givre de temps
  et s'arrête net.
- **Paradoxe :** deux doubles translucides repartent sur ses traces ; au bout, chacun éclate en onde d'horloge.
- **Rembobinage :** des chiffres de dégâts reviennent vers lui à l'envers, et une horloge tourne à rebours sur lui.
- **Saut temporel :** un réveil de cuivre reste là où il partait, tremble, puis sonne dans une onde qui fige.
- **Jugement des Heures :** l'écran se teinte de sarcelle, une horloge géante s'ouvre, les aiguilles avancent
  vers midi pendant que des cadrans de coups s'empilent au-dessus des ennemis ; à midi, tout explose ensemble
  en éclats d'engrenages.
