# L'Éveil du Sorcier des Ténèbres — le Seigneur du Néant

> Le sixième ÉVEIL des mages. Le Sorcier des Ténèbres frappe loin, se déplace vite et encaisse mal.
> Éveillé, il devient **le Seigneur du Néant** pendant une minute : son ombre se détache de lui et répète
> chacun de ses coups, il ouvre des gouffres qui aspirent, il fond dans le sol, et il éteint le soleil.
> Le Phénix renaît, le Seigneur des Marées encaisse, le Colosse écrase, l'Avatar foudroie, le Souverain tient
> à distance ; lui frappe deux fois.

**Jouable depuis le 2026-11-07** (`CharacterCatalog.shadow_awakened`). Les quatre images ci-dessous ont été
commandées dans cet ordre, la première servant de modèle aux trois autres ; elles sont découpées dans
`assets/characters/shadow_eveil` et `assets/icons/shadow_eveil`.

⚠️ **FOND VERT, PAS MAGENTA.** Le Sorcier est violet : sur le fond magenta habituel, le détourage ferait des
trous dans sa robe et dans ses yeux. Ses quatre images se commandent sur un **vert pur (#00FF00)**, et il
ne porte **aucun vert**. Vérifier la première avant de commander les autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Seigneur | ci-dessous, image 1 | `refonte/tenebres_eveil.png` | `refonte/tenebres.png` et `refonte/chrono.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/tenebres_eveil_marche.png` | `refonte/tenebres_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/tenebres_eveil_attaque.png` | `refonte/tenebres_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_tenebres_eveil_skills.png` | aucune |

Aucun portrait à commander : la carte de l'écran de sélection reste celle du Sorcier des Ténèbres. Aucune
image pour les effets des sorts : ils seront peints au shader.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## Le Seigneur du Néant

### Ce qu'il devient

On reconnaît le Sorcier des Ténèbres : sa **capuche profonde**, ses **deux yeux violets** lumineux, sa robe
**violet sombre et noire**, son corps compact, et l'orbe qui flotte au creux de sa main gauche. Mais le
néant l'a pris. Sous la capuche, il n'y a plus de visage : un **vide noir** où brillent seulement les deux
yeux, plus grands. Le bas de sa robe se défait en **vrilles d'ombre** qui finissent en petites **mains
griffues**, posées au sol autour de ses pieds. Son orbe est devenu une **éclipse** : un **soleil noir**
cerclé d'un **anneau violet vif**. Deux **chaînes d'argent** pendent à sa ceinture. Des **runes violettes**
luisent sur le bord de sa capuche.

Il reste chibi, à la même échelle que le Sorcier des Ténèbres. Son **ombre**, la silhouette qui répète ses
coups, n'est **pas dessinée** sur les images : c'est le jeu qui la fait, à partir de son propre sprite.

### Son trait éveillé : le Double

**Son ombre répète chacun de ses coups.** Une fraction de seconde après chaque attaque ou chaque sort qui
vise un ennemi, sa silhouette noire surgit derrière lui, refait le geste, et le coup repart vers la même
cible à **la moitié de sa force**. Elle ne répète ni la fuite, ni l'Extra.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Orbe d'ombre | **Orbe du néant** | l'orbe remonte les couloirs, et à l'impact s'ouvre en petit gouffre qui aspire les voisins d'une case | 18 dégâts, 10 cases, 0,45 s, aspire à 2 cases |
| SKILL 1 | Rune | **Sceau du gouffre** | une rune plus large ; des mains d'ombre en sortent et clouent sur place ce qui entre, puis le rongent | rayon 2, 8 s, 14/s, cloue 1,5 s, recharge 8 s |
| SKILL 2 | Passage | **Marche des ombres** | il traverse la haie qu'il regarde et laisse de l'autre côté un leurre d'ombre que les ennemis poursuivent | leurre 5 s, recharge 6 s |
| SKILL 3 | Implosion d'ombre | **Trou noir** | un trou noir s'ouvre sur la cible, aspire tout 2 s, puis s'effondre en explosion et laisse une flaque empoisonnée | 50 dégâts, aspire à 4 cases, rayon 2,6, recharge 9 s |
| FUITE | Pas de l'ombre | **Fusion** | il fond dans le sol 2 s, intouchable, passe sous les haies, puis surgit dans une gerbe de vrilles qui frappent autour | 2 s, 30 dégâts au retour, rayon 1,5, recharge 8 s |
| EXTRA | Faille des ténèbres | **Éclipse** | le soleil s'éteint : la nuit tombe 10 s, les ennemis sont ralentis, et deux fois plus de failles s'ouvrent | la Faille de base ×2, ralentis de 40 % pendant 10 s |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

---

## Image 1 — le modèle du Seigneur

Joindre `assets/peso&cover/refonte/tenebres.png` en PREMIER (le Sorcier des Ténèbres, qu'il faut garder
reconnaissable), puis `assets/peso&cover/refonte/chrono.png` (les proportions et la mise en page).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
La PREMIÈRE image jointe montre le Sorcier des Ténèbres : c'est LE MÊME personnage, que tu dois
transformer, pas remplacer. La DEUXIÈME image jointe sert UNIQUEMENT de référence de
proportions et de mise en page : ne copie ni son personnage, ni ses couleurs, ni ses objets.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- ⚠️ fond VERT PUR UNI (#00FF00) partout : un aplat, sans dégradé ni texture. PAS de magenta.
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le vide sous la capuche et les deux yeux se voient bien
2. vue DE DOS, immobile : la capuche et les vrilles de la robe se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile

LE PERSONNAGE — le Sorcier des Ténèbres ÉVEILLÉ en SEIGNEUR DU NÉANT. On le reconnaît tout de
suite : même petit sorcier au corps compact, même CAPUCHE PROFONDE, mêmes DEUX YEUX VIOLETS
lumineux, même robe VIOLET SOMBRE (#3b1d5c) et NOIRE (#120a1c), même ORBE flottant au creux de sa
main GAUCHE, sans bâton. Ce qui change :
- sous la capuche, il n'y a plus de visage : un VIDE NOIR où brillent seulement les deux yeux,
  plus grands, VIOLET VIF (#c77dff) au cœur blanc ;
- le bas de sa robe se défait en cinq ou six VRILLES D'OMBRE noires bordées de violet, qui
  finissent en petites MAINS GRIFFUES posées au sol autour de ses pieds ;
- son orbe est devenu une ÉCLIPSE : un SOLEIL NOIR parfaitement rond, cerclé d'un ANNEAU VIOLET
  VIF (#c77dff) ;
- deux fines CHAÎNES D'ARGENT (#c9ccd6) pendent à sa ceinture ;
- des RUNES VIOLETTES luisent sur le bord de sa capuche.
Toutes ses formes sont cernées d'un contour noir violacé (#0a0512), net.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, ni dans les reflets, ni dans les ombres, ni en lueur :
le fond vert serait retiré avec. Ses couleurs sont le violet, le noir, l'argent et le blanc.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DU SORCIER DES TÉNÈBRES : UN CORPS CHIBI COMPACT, À
LA MÊME TAILLE. Posé à côté de la première image jointe, il fait la même hauteur.

⚠️ RÈGLE BLOQUANTE — UN SEUL PERSONNAGE PAR CASE : ne dessine PAS son ombre ni un double derrière
lui. Le jeu s'en charge.

⚠️ RÈGLE BLOQUANTE — L'OMBRE EST FAITE DE FORMES NETTES ET OPAQUES, cernées : aucune fumée floue,
aucun halo, aucune brume, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — IL RESTE DANS SA LARGEUR. Les vrilles et les mains ne s'étalent pas à plus
d'une demi-largeur de corps de chaque côté.

⚠️ RÈGLE BLOQUANTE — SES PIEDS SE LISENT EN TRÈS PETIT. Les deux bottes se voient sous la robe,
séparées l'une de l'autre, entre les vrilles.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
vrilles, même éclipse, toujours au creux de la main GAUCHE.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le fond est magenta, ou n'est pas un vert uni | Le détourage trouerait le violet |
| Du vert sur lui (reflets, lueur de l'orbe) | Il partirait avec le fond |
| Une ombre ou un double dessiné derrière lui | Le jeu dessine lui-même son ombre : elle serait en double |
| Il est plus grand que le Sorcier des Ténèbres | Il ne doit pas changer de taille en s'éveillant |
| Les vrilles cachent les pieds | On ne verrait plus ses pas |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/tenebres_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT sa capuche, ses vrilles, son
éclipse, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- ⚠️ fond VERT PUR UNI (#00FF00) partout : un aplat, sans dégradé ni texture. PAS de magenta.
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Sorcier des Ténèbres éveillé en SEIGNEUR DU NÉANT, en proportions CHIBI, corps
compact : capuche profonde sur un VIDE NOIR où brillent DEUX YEUX VIOLETS, robe violet sombre et
noire dont le bas se défait en VRILLES D'OMBRE aux petites mains griffues, deux chaînes d'argent
à la ceinture, et une ÉCLIPSE (soleil noir cerclé de violet) qui flotte au creux de sa main
GAUCHE. Pas de bâton. Contour noir violacé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale
est la même dans les 24 cases.

Il MARCHE d'un pas GLISSÉ et silencieux, comme une ombre. IL NE COURT PAS : le buste reste DROIT.
Ses pas sont de la MÊME LONGUEUR que sur le guide. Ses vrilles ondulent un peu différemment à
chaque image.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps.
- LE BRAS DROIT (main libre, doigts griffus) balance en grand, de l'avant vers l'arrière ;
- LE BRAS GAUCHE (celui de l'éclipse) balance AUSSI, moins loin : la main avance et recule, paume
  vers le haut, et l'éclipse flotte toujours juste au-dessus d'elle, à la même distance.

LE BALANCEMENT DES BRAS, image par image, calé sur les jambes du guide :
1. bras droit tendu vers l'AVANT, main à hauteur de taille ; main de l'éclipse vers l'ARRIÈRE
2. bras droit qui redescend, coude un peu plié ; main de l'éclipse qui revient
3. les deux bras le long du corps, POINT DE PASSAGE (c'est l'image aux jambes jointes)
4. bras droit qui part vers l'arrière ; main de l'éclipse qui part vers l'avant
5. l'INVERSE de l'image 1 : bras droit vers l'ARRIÈRE, main de l'éclipse vers l'AVANT
6. main de l'éclipse qui revient ; bras droit qui revient
7. les deux bras le long du corps, POINT DE PASSAGE (jambes jointes)
8. bras droit qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui avance
grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses. Le VERT de
la robe du guide ne doit pas passer sur lui.

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
Deux images voisines identiques pour les bras sont une erreur. L'éclipse suit sa main.

⚠️ RÈGLE BLOQUANTE — LES VRILLES NE CACHENT JAMAIS LES PIEDS : les deux bottes se voient dans les
24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, L'ÉCLIPSE ET LES VRILLES BOUGENT. Dans une même
rangée, la capuche et le tronc se superposent exactement d'une case à l'autre, et le profil
regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — UN SEUL PERSONNAGE PAR CASE, AUCUN DOUBLE NI OMBRE DERRIÈRE LUI.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI ; l'ombre en formes nettes, sans fumée floue ni halo.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule détachée.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/tenebres_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT sa capuche, ses vrilles, son éclipse, ses couleurs et ses
proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- ⚠️ fond VERT PUR UNI (#00FF00) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Sorcier des Ténèbres éveillé en SEIGNEUR DU NÉANT, en proportions CHIBI, corps
compact : capuche profonde sur un vide noir aux deux yeux violets, robe violet sombre et noire en
vrilles d'ombre aux petites mains griffues, chaînes d'argent, ÉCLIPSE (soleil noir cerclé de
violet) au creux de la main GAUCHE. Pas de bâton. Contour noir violacé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il
LANCE SON ÉCLIPSE d'une poussée de la main gauche, et elle lui revient.
1. posture prête, l'éclipse flottant au-dessus de sa main gauche
2. il ramène la main gauche contre sa poitrine, l'éclipse serrée contre lui, la main droite ouverte
3. le buste se ramasse, l'éclipse gonfle un peu, ses yeux s'allument plus fort
4. LE COUP : il pousse la main gauche paume ouverte DEVANT lui, dans la direction de la rangée, et
   l'éclipse jaillit d'un demi-pas devant sa main, entourée d'un petit anneau violet, plus petite
   que sa tête
5. l'éclipse revient au-dessus de sa paume, l'anneau a disparu
6. il ramène la main
7. la main revient à sa place, l'éclipse au-dessus
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit anneau de l'image 4.
Le JEU dessine lui-même les orbes, les gouffres et son ombre.

⚠️ RÈGLE BLOQUANTE — UN SEUL PERSONNAGE PAR CASE, AUCUN DOUBLE NI OMBRE DERRIÈRE LUI.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, ni en reflet du fond.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune fumée, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc et la capuche se
superposent exactement dans les 8 images d'une rangée (seuls les bras, l'éclipse, les vrilles et
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

PERSONNAGE : le Sorcier des Ténèbres éveillé en SEIGNEUR DU NÉANT. Ses couleurs sont le NOIR
(#120a1c), le VIOLET SOMBRE (#3b1d5c), le VIOLET VIF (#c77dff), le BLANC (#f5ecff) et l'ARGENT
(#c9ccd6), avec un CONTOUR NOIR VIOLACÉ (#0a0512) net autour de chaque forme. Le motif commun des
six icônes est l'ÉCLIPSE (un disque noir cerclé de violet vif) : elle doit se retrouver dans chacune.

FORMAT, à respecter exactement :
- image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 2 rangées, soit 6 cases de 512 x 512
- ⚠️ fond VERT UNI #00FF00 partout, y compris entre les cases, sans dégradé. PAS de magenta.
- NE PAS dessiner les lignes de la grille, ni cadre, ni numéro, ni texte
- une seule icône par case, CENTRÉE, occupant environ 70 % de sa case
- une forme à peu près aussi large que haute, qui tiendrait dans un cercle
- au moins 40 pixels de vide vert tout autour de chaque icône
- rien ne dépasse sur la case voisine, ni en haut ni en bas

LES SIX ICÔNES, dans cet ordre de lecture :

1. ORBE DU NÉANT — une éclipse qui file vers la droite avec une traînée d'ombre, et devant elle
   un petit tourbillon noir qui aspire.

2. SCEAU DU GOUFFRE — un cercle de runes violettes vu en légère plongée, d'où sortent trois mains
   d'ombre griffues qui se referment.

3. MARCHE DES OMBRES — une silhouette encapuchonnée qui passe à travers un mur de briques, et de
   l'autre côté une silhouette noire identique, sans yeux, qui l'attend.

4. TROU NOIR — une grande éclipse au centre d'une spirale noire et violette qui s'enroule vers elle,
   avec des débris aspirés.

5. FUSION — une flaque d'ombre au sol d'où sortent deux yeux violets et des vrilles qui jaillissent
   vers le haut.

6. ÉCLIPSE — un soleil entièrement caché par un disque noir, une couronne de rayons violets autour,
   et deux failles qui s'ouvrent en dessous. C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor en dehors du mur de l'icône 3, pas d'ombre
portée, pas de cadre, pas de texte, pas de flou, aucune fumée floue, aucune lueur floue, aucune
case vide, AUCUN VERT dans les icônes, ni en reflet ni en lueur : il partirait avec le fond. Ce
sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Les shaders `neant_*` (`tools/preview_neant.gd` les montre) et son ombre, `ShadowDouble`. Mêmes règles que les autres :
trois temps (départ, coup, trace qui s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette du Seigneur

| rôle | couleur | usage |
|---|---|---|
| Le néant | `#120a1c` | le cœur des gouffres, l'éclipse, l'ombre du Double |
| Le violet sombre | `#3b1d5c` | les vrilles, les flaques |
| Le violet vif | `#c77dff` | les anneaux, les runes, les yeux |
| Le blanc | `#f5ecff` | le cœur des yeux, l'instant du coup |
| L'argent | `#c9ccd6` | les chaînes, les débris aspirés |
| Le cerne | `#0a0512` | contour |

Le motif commun est **l'éclipse** : un disque noir cerclé de violet vif. L'ombre est en formes nettes,
jamais en fumée floue. En jeu, sur les sols sombres, chaque forme noire garde un **liseré violet** pour se
lire.

### L'Éveil lui-même

- **La charge, 0,8 s :** les ombres du sol rampent vers lui et montent le long de sa robe.
- **L'éclosion :** le jour baisse un instant, une éclipse s'ouvre derrière lui, son ombre se lève et se
  détache de ses pieds, puis une onde noire cerclée de violet part au sol.
- **Pendant la minute :** son ombre le suit, une silhouette noire au liseré violet, un pas derrière lui.
- **Le Double :** l'ombre refait le geste et le coup part d'elle, plus sombre.
- **La fin :** son ombre se dissout en vrilles qui rentrent sous terre, et il redevient le Sorcier.

### Les six sorts

- **Orbe du néant :** l'éclipse file dans les couloirs avec une traînée noire ; à l'impact, un petit
  tourbillon noir s'ouvre et aspire.
- **Sceau du gouffre :** un cercle de runes violettes ; des mains d'ombre sortent du sol sur ce qui entre et
  se referment dessus.
- **Marche des ombres :** il se fond dans la haie ; de l'autre côté, son leurre se dresse, une silhouette
  noire sans yeux, qui se défait quand le temps est écoulé.
- **Trou noir :** une éclipse s'ouvre sur la cible au centre d'une spirale qui s'enroule vers elle ; des
  traits d'argent y plongent ; puis elle s'effondre dans un éclat violet.
- **Fusion :** il s'enfonce dans une flaque d'ombre, deux yeux violets filent au sol, puis les vrilles
  jaillissent en couronne là où il ressort.
- **Éclipse :** l'écran s'assombrit, un grand soleil noir cerclé de violet se dresse au-dessus de lui, et les
  failles s'ouvrent deux par deux.
