# L'Éveil de l'Ange de la Mort — le Faucheur des Âmes

> Le deuxième ÉVEIL des anges. L'Ange de la Mort achève ce qui est presque mort et récolte les âmes de ses victimes.
> Éveillé, il devient **le Faucheur des Âmes** pendant une minute : la Mort elle-même. Il moissonne plus large, et ses
> âmes tournent autour de lui et travaillent pour lui.

**Jouable depuis le 2026-11-10** (`CharacterCatalog.mort_awakened`). Les cinq images ont été commandées dans cet
ordre ; elles sont découpées dans `assets/characters/mort_eveil`, `assets/icons/mort_eveil` et le portrait de la
sélection. Ses effets sont peints au shader (`faucheur_*`, lame et âme dans `faucheur.gdshaderinc`) ;
`tools/preview_faucheur.gd` les montre hors partie. Les chiffres sont des points de départ, jamais mesurés. Il est
fragile (3 PV) : sa force vient de l'achèvement et des âmes, pas de sa
résistance. Il reste **sous l'Archimage Primordial**.

⚠️ **FOND VERT POUR LE PERSONNAGE, MAGENTA POUR LES ICÔNES.** Il est noir, gris anthracite et rouge braise : sur le
magenta, son rouge et les ombres violacées de sa robe partiraient au détourage. Ses trois planches de personnage se
commandent sur un **vert pur (#00FF00)**, et il ne porte **aucun vert**. Les icônes restent sur **magenta**, sans aucun
rose ni violet : son rouge y reste un rouge braise franc, tirant sur l'orange. Vérifier la première image avant de
commander les autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Faucheur | ci-dessous, image 1 | `refonte/mort_eveil.png` | `refonte/mort.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/mort_eveil_marche.png` | `refonte/mort_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/mort_eveil_attaque.png` | `refonte/mort_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_mort_eveil_skills.png` | aucune |
| 5 | Le portrait de la sélection | [menu/portrait_mort_eveil](../menu/portrait_mort_eveil.md) | `interface/portraits/portrait_mort_eveil.png` | `interface/portraits/portrait_mort.png` et `mages/mort_eveil_marche.png` |

Le portrait se commande en dernier : il a besoin de la planche de marche. Aucune image pour les effets des sorts :
ils seront peints au shader. **Les âmes qui tournent autour de lui, la cloche, la lune et la faux géante sont faites
par le JEU** : elles ne sont jamais dessinées sur ses planches.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## Le Faucheur des Âmes

### Ce qu'il devient

On reconnaît l'Ange de la Mort : son **visage pâle couleur d'os**, ses **yeux rouge braise**, ses **cheveux noirs
mi-longs**, ses deux **petites cornes noires**, son armure **gris anthracite à liserés couleur d'os** sur une longue
robe noire déchirée, ses bottes noires griffues, ses deux ailes noires à demi repliées, et sa **faux au manche d'os**
dans la main droite. Mais il est devenu la Mort elle-même :

- Son **auréole brisée s'est ressoudée** : un anneau COMPLET de braise rouge, gravé de petites runes, au-dessus de sa
  tête et collé à ses cornes.
- Une **capuche noire déchirée** lui tombe sur la tête ; ses cornes la percent, et on voit toujours son visage pâle.
  Ses yeux rouges sont plus vifs.
- Ses **ailes** sont un peu plus grandes, toujours à demi repliées, et leurs plumes effilochées finissent en
  **flammes de braise** dessinées, à bords nets.
- Sa faux est devenue une **FAUX DOUBLE** : deux lames noires bordées de rouge braise, de part et d'autre du haut du
  manche d'os, comme un croissant de lune ouvert des deux côtés.
- Une **chaîne d'os** lui ceint la taille, d'où pend un petit **sablier noir** au sable rouge.

Il reste chibi, à la même échelle que l'Ange de la Mort.

### Son trait éveillé : la Récolte

**Il achève plus haut, et ses âmes le gardent.** Tant que dure l'Éveil :
- la Sentence achève sous **25 %** des PV au lieu de 15 % (`SENTENCE_BELOW`) ;
- chaque âme récoltée **tourne autour de lui**, jusqu'à **6**, et frappe ce qui arrive à son contact : l'âme part sur
  l'ennemi et s'y consume.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Croissant noir | **Croissant de l'au-delà** | le croissant part, puis revient vers lui, et frappe à l'aller comme au retour | 15 dégâts par passage, 7 cases, recharge 0,5 s |
| SKILL 1 | Moisson | **Grande Moisson** | un coup de faux sur tout le tour de lui ; il achève sous 45 %, et chaque achèvement donne une âme | 50 dégâts, rayon 3, achève sous 45 %, recharge 6 s |
| SKILL 2 | Glas | **Glas funèbre** | une cloche sonne trois fois au-dessus de lui ; à chaque coup, ce qui est proche est marqué (+40 % de dégâts) et ralenti | 3 coups à 1,5 s d'écart, rayon 4, 10 dégâts, marque 4 s, ralentit 2 s, recharge 15 s |
| SKILL 3 | Âmes captives | **Légion des âmes** | il lâche toutes ses âmes, plus trois ; une âme qui tue revient tourner autour de lui | 3 âmes de base + les siennes, 32 dégâts chacune, recharge 10 s |
| FUITE | Passage | **Pas de l'ombre** | il traverse les haies ; tout ennemi sur la ligne du passage est marqué | 6 cases, marque 4 s, recharge 8 s |
| EXTRA | L'Heure dernière | **Minuit** | la nuit tombe, et la faux géante passe deux fois sur l'écran, aller puis retour : chaque passage retire la moitié des PV, et ce qui tombe sous 20 % est achevé | 2 passages, la moitié des PV chacun, achève sous 20 % (à 25 %, deux moitiés tuaient toute la carte) |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

Le cœur de son jeu est **la récolte** : blesser, puis achever. Chaque achèvement lui donne une âme, et ses âmes le
protègent en tournant autour de lui, ce qui compense ses 3 PV.

---

## Image 1 — le modèle du Faucheur

Joindre `assets/peso&cover/refonte/mort.png` (l'Ange de la Mort, qu'il faut garder reconnaissable).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre l'Ange de la Mort : c'est LE MÊME personnage, que tu dois
transformer, pas remplacer. Ne reprends PAS la mise en page de l'image jointe.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- ⚠️ fond VERT PUR UNI (#00FF00) partout : un aplat, sans dégradé ni texture. PAS de magenta,
  PAS de gris.
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le visage pâle sous la capuche, l'auréole et la faux double se voient bien
2. vue DE DOS, immobile : la capuche, l'auréole au-dessus, les deux ailes et leurs pointes de braise
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : la faux tenue droite, une aile de profil

LE PERSONNAGE — l'Ange de la Mort ÉVEILLÉ en FAUCHEUR DES ÂMES. On le reconnaît tout de suite :
même ange déchu au corps CHIBI, même VISAGE PÂLE couleur d'os bien visible, mêmes YEUX ROUGE
BRAISE, mêmes cheveux noirs mi-longs, mêmes deux PETITES CORNES noires, même armure GRIS
ANTHRACITE (#3a3d44) à liserés couleur d'OS (#e8dcc4) sur une longue robe NOIRE déchirée au bas,
mêmes bottes noires griffues, mêmes deux ailes de plumes noires À DEMI REPLIÉES, même faux au
MANCHE D'OS tenue de la main DROITE. Ce qui change :
- son auréole brisée s'est RESSOUDÉE : un anneau COMPLET de braise ROUGE (#e8402a, cœur
  #ffb07a), gravé de petites runes, au-dessus de sa tête, qui TOUCHE ses cornes ;
- une CAPUCHE NOIRE déchirée lui tombe sur la tête, percée par ses deux cornes ; le visage
  reste visible dessous, et ses yeux rouges sont plus vifs ;
- ses ailes sont un peu plus grandes, et leurs plumes effilochées finissent en FLAMMES DE BRAISE
  rouge orangé, dessinées à bords nets ;
- sa faux est une FAUX DOUBLE : deux lames NOIRES bordées de ROUGE BRAISE, de part et d'autre
  du haut du manche d'os, comme un croissant ouvert des deux côtés ;
- une CHAÎNE D'OS lui ceint la taille, d'où pend un petit SABLIER noir au sable rouge.
Toutes ses formes sont cernées d'un contour très foncé (#0c0a0e), net.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, ni dans les reflets, ni dans les ombres, ni en lueur :
le fond vert serait retiré avec. Ses ombres sont GRISES et NOIRES, jamais vertes.

⚠️ RÈGLE BLOQUANTE — UN ANGE D'ABORD, UN DÉMON ENSUITE : les ailes restent des ailes de PLUMES,
le visage reste visible. Pas de crâne, pas de squelette.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES, jamais déployées. Elles ne dépassent pas
de plus d'un quart de la largeur du corps de chaque côté, et leurs pointes s'arrêtent au niveau
des genoux. Il devra marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — L'AURÉOLE TOUCHE LES CORNES, jamais détachée et flottante : on ne voit aucun
espace vert entre elles.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'ANGE DE LA MORT : UN CORPS CHIBI DE 2,5 TÊTES, À
LA MÊME TAILLE. Posé à côté de l'image jointe, il fait la même hauteur. La faux ne dépasse pas sa
tête de plus d'une demi-tête.

⚠️ RÈGLE BLOQUANTE — AUCUNE AURA, AUCUNE FUMÉE, AUCUNE ÂME, AUCUNE PARTICULE, AUCUNE LUEUR FLOUE
autour de lui. Les flammes des ailes sont DESSINÉES, nettes et pleines. Le jeu ajoute le reste.

⚠️ RÈGLE BLOQUANTE — UN CONTOUR NET. Les bords sombres gardent un liseré couleur d'os ou rouge
braise : il doit rester lisible sur un sol sombre.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
ailes, même auréole, même faux, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le fond est magenta ou gris, ou n'est pas un vert uni | Le détourage trouerait son rouge et ses ombres sombres |
| Du vert sur lui (reflets, ombres) | Il partirait avec le fond |
| Un crâne à la place du visage | Il deviendrait un démon ; le joueur veut un ange d'abord |
| Des ailes déployées | Il ne tiendrait plus dans un couloir |
| L'auréole flotte au-dessus des cornes | Le découpage la jetterait comme une poussière |
| Des âmes ou de la fumée autour de lui | Le jeu les dessine : elles seraient en double, et sa boîte enflerait |
| Il est plus grand que l'Ange de la Mort | Il ne doit pas changer de taille en s'éveillant |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/mort_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT sa capuche, son auréole, ses ailes,
son armure, sa faux double, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- ⚠️ fond VERT PUR UNI (#00FF00) partout : un aplat, sans dégradé ni texture. PAS de magenta.
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Ange de la Mort éveillé en FAUCHEUR DES ÂMES, en proportions CHIBI : visage
pâle aux yeux rouge braise sous une CAPUCHE NOIRE percée de deux petites cornes, AURÉOLE de braise
complète qui touche les cornes, deux ailes de plumes noires À DEMI REPLIÉES aux pointes de braise,
armure gris anthracite à liserés couleur d'os sur une robe noire déchirée, chaîne d'os et petit
sablier à la taille, bottes noires griffues, FAUX DOUBLE au manche d'os tenue DROITE dans la main
DROITE. Contour très foncé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
auréole comprise, est la même dans les 24 cases.

Il MARCHE d'un pas lent et sûr, comme qui sait que rien ne lui échappe. IL NE COURT PAS : le buste
reste DROIT et la tête haute, sans bouger d'une image à l'autre. Ses pas sont de la MÊME LONGUEUR
que sur le guide. Le bas de la robe et la pointe des ailes flottent un peu différemment à chaque
image.

LA FAUX reste dans sa main DROITE, tenue droite, lames en haut, dans les 24 cases : elle monte et
descend un peu avec le pas, sans jamais basculer. SON BRAS GAUCHE BALANCE FRANCHEMENT, EN
OPPOSITION AUX JAMBES : quand la jambe droite part vers l'avant, le bras gauche part vers l'avant
lui aussi, puis il repart vers l'arrière. Le coude plie, la main suit avec un léger temps de
retard. Il ne reste JAMAIS figé le long du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, AVEC SA
FAUX. Le VERT de la robe du guide ne doit pas passer sur lui.

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

⚠️ RÈGLE BLOQUANTE — LA ROBE NE CACHE PAS LES PIEDS : les deux bottes se voient dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES dans les 24 cases, jamais déployées.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LE BRAS GAUCHE, LE BAS DE LA ROBE ET LA POINTE DES AILES
BOUGENT. Dans une même rangée, la tête, l'auréole et le tronc se superposent exactement d'une case
à l'autre, et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, aucune âme, aucune fumée, aucune lueur floue.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule détachée.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/mort_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT sa capuche, son auréole, ses ailes, son armure, sa faux double, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- ⚠️ fond VERT PUR UNI (#00FF00) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Ange de la Mort éveillé en FAUCHEUR DES ÂMES, en proportions CHIBI : visage pâle
aux yeux rouges sous une capuche noire percée de deux cornes, auréole de braise complète, deux
ailes noires à demi repliées aux pointes de braise, armure gris anthracite, robe noire déchirée,
FAUX DOUBLE au manche d'os dans la main DROITE. Contour très foncé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il
fauche devant lui et lance un croissant.
1. posture prête, faux tenue droite
2. il ramène la faux en arrière, au-dessus de l'épaule, la lame s'allume de rouge braise
3. la faux part vers l'avant en arc de cercle, les deux mains sur le manche
4. LE COUP : la faux à l'horizontale DEVANT lui, bras tendus, dans la direction de la rangée,
   et un petit éclat ROUGE BRAISE, plus petit que sa tête, brille sur le tranchant
5. l'éclat a disparu, la faux finit son arc
6. la faux remonte
7. la faux revient presque à la verticale
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE COUP PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit éclat rouge de
l'image 4, collé au tranchant. Pas de croissant lancé, pas d'arc de lumière : le JEU les dessine.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES pendant tout le geste.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, ni en reflet du fond.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune aura, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc, la tête et l'auréole
se superposent exactement dans les 8 images d'une rangée (seuls les bras, la faux, la robe et
les genoux bougent).

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, il regarde VERS LA DROITE
dans les 8 cases.
```

---

## Image 4 — les six icônes éveillées

Aucune image à joindre. ⚠️ Celle-ci est sur **MAGENTA**, pas sur vert.

```
Planche de six ICÔNES DE SORTS pour un jeu de rôle mobile, style cartoon coloré,
contours nets, lisibles en tout petit.

PERSONNAGE : l'Ange de la Mort éveillé en FAUCHEUR DES ÂMES, la Mort elle-même. Ses couleurs sont
le NOIR (#141216), le GRIS ANTHRACITE (#3a3d44), la couleur d'OS (#e8dcc4), le ROUGE BRAISE
(#e8402a, cœur #ffb07a) et le BLANC PÂLE des âmes (#eef0f2), avec un CONTOUR TRÈS FONCÉ (#0c0a0e)
net autour de chaque forme. Le motif commun des six icônes est la FAUX DOUBLE noire bordée de
rouge braise : elle doit se retrouver dans chacune, entière ou en partie.

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

1. CROISSANT DE L'AU-DELÀ — un croissant de lame noire bordé de rouge braise, avec une flèche
   courbe qui part et revient, comme un boomerang.

2. GRANDE MOISSON — une faux double vue de dessus, au centre d'un cercle complet de lame noire et
   rouge, et trois petites âmes pâles qui s'en échappent.

3. GLAS FUNÈBRE — une cloche noire à liseré d'os, et trois ondes rouge braise qui partent d'elle en
   cercles.

4. LÉGION DES ÂMES — une nuée de six petites âmes pâles à traînée rouge, en spirale autour d'une
   faux double.

5. PAS DE L'OMBRE — deux plumes noires et une ligne de braise qui traverse un petit mur de haie,
   d'un côté à l'autre.

6. MINUIT — une grande lune rouge dans un ciel noir, traversée par une faux géante, et des âmes
   pâles qui montent vers elle. C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune fumée floue, aucune lueur floue, aucune case vide, AUCUN ROSE
NI VIOLET dans les icônes : ils se confondraient avec le fond magenta. Le rouge est un rouge
braise qui tire sur l'ORANGE, jamais sur le rose. Le ciel noir est NOIR, jamais violet. Ce sont
des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Ils seront peints au shader, comme ceux des autres Éveils. Mêmes règles : trois temps (départ, coup, trace qui
s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette du Faucheur

| rôle | couleur | usage |
|---|---|---|
| Le noir | `#141216` | lames, ciel de Minuit, cloche |
| L'os | `#e8dcc4` | liserés, chaîne, poussière |
| La braise | `#e8402a` | tranchants, auréole, ondes du Glas |
| Le cœur de braise | `#ffb07a` | instant de l'impact |
| Le blanc des âmes | `#eef0f2` | les âmes et leurs traînées |

Le motif commun est **la faux double** et **l'âme pâle à traînée rouge**. Jamais de violet ni de vert.

### L'Éveil lui-même

- **La charge, 0,8 s :** des âmes pâles montent du sol autour de lui et tournent de plus en plus vite.
- **L'éclosion :** l'auréole brisée se ressoude d'un éclat rouge, un cercle de faux tranche le sol autour de lui, et
  une colonne de cendres monte ; la caméra tremble.
- **Pendant la minute :** les âmes récoltées tournent autour de lui (jusqu'à six), et un cercle de braise fendu bat
  sous ses pieds.
- **La fin :** les âmes s'envolent vers le haut et s'éteignent, l'auréole se refend.

### Les six sorts

- **Croissant de l'au-delà :** le croissant noir bordé de braise tourne sur lui-même en filant, laisse une traînée de
  cendres, et revient dans sa main ; chaque coup laisse une entaille rouge.
- **Grande Moisson :** un cercle complet de lame noire et rouge tranche tout autour de lui ; chaque achèvement fait
  jaillir une âme du corps, qui vient le rejoindre.
- **Glas funèbre :** une cloche spectrale apparaît au-dessus de lui ; à chaque coup, une onde noire bordée de braise
  part en cercle, et ce qu'elle marque garde une petite faux rouge au-dessus de la tête.
- **Légion des âmes :** les âmes partent en nuée dans les couloirs, pâles, avec une traînée rouge ; celle qui tue
  revient en spirale autour de lui.
- **Pas de l'ombre :** il se défait en plumes noires, une ligne de braise relie le départ à l'arrivée par-dessus les
  haies, et il se reforme dans un tourbillon de plumes.
- **Minuit :** le ciel devient noir, une lune rouge se lève, la faux géante traverse l'écran de gauche à droite puis
  revient ; les âmes de ceux qu'elle achève montent vers la lune.
