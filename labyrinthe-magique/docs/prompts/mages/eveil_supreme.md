# L'Éveil du Sorcier Suprême — l'Archimage Primordial

> Le dixième ÉVEIL des mages. Le Sorcier Suprême est le maître des quatre éléments, et ses coups se répètent en
> écho. Éveillé, il devient **l'Archimage Primordial** pendant une minute : les quatre éléments tournent
> autour de lui en orbes, et chacun de ses coups prend le suivant. Les autres Éveils poussent un élément au bout ;
> lui les fait tous tourner.

**Jouable depuis le 2026-11-08** (`CharacterCatalog.supreme_awakened`). Les quatre images ci-dessous ont été
commandées dans cet ordre ; elles sont découpées dans `assets/characters/supreme_eveil` et
`assets/icons/supreme_eveil`. Ses effets sont peints au shader (`primordial_*`, anneau et palette dans
`primordial.gdshaderinc`, matière des éléments dans `elements.gdshaderinc`) ; les orbes sont `ElementOrbs`, et
`tools/preview_primordial.gd` montre les effets hors partie. Tous ses sorts ont été vus en capture. Les chiffres ne
sont pas mesurés.

⚠️ **FOND VERT POUR LE PERSONNAGE, MAGENTA POUR LES ICÔNES.** Le Sorcier a des yeux et des gemmes violets, et sa
robe tire sur le violet noir : sur le fond magenta, le détourage les trouerait. Ses trois planches de
personnage se commandent sur un **vert pur (#00FF00)**, comme le Seigneur du Néant, et il ne porte **aucun
vert**. Les icônes, elles, montrent la terre, qui peut être verte : elles restent sur **magenta**, sans aucun
violet. Vérifier la première image avant de commander les autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle de l'Archimage | ci-dessous, image 1 | `refonte/supreme_eveil.png` | `refonte/supreme.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/supreme_eveil_marche.png` | `refonte/supreme_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/supreme_eveil_attaque.png` | `refonte/supreme_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_supreme_eveil_skills.png` | aucune |

Aucun portrait à commander : la carte de l'écran de sélection reste celle du Sorcier Suprême. Aucune image pour
les effets des sorts : ils seront peints au shader. **Les quatre orbes qui tournent autour de lui sont faites
par le JEU** : elles ne sont jamais dessinées sur ses planches. Les planches du Sorcier les portaient, et elles
gonflaient sa boîte au point qu'on voyait la lueur et pas le mage.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## L'Archimage Primordial

### Ce qu'il devient

On reconnaît le Sorcier Suprême : sa **capuche profonde** sur un visage d'ombre où brillent **deux yeux
violets**, sa **robe noire violacée à liserés et motifs d'or**, ses épaulières d'or et ses gemmes violettes,
ses petites bottes, ses mains nues. Mais il est devenu l'origine des éléments. Une **auréole d'or** gravée de
quatre runes se dresse derrière sa capuche, collée à elle. Sa robe est devenue un **manteau de nuit étoilée**,
noir bleuté semé de petites étoiles d'or. Une **étole d'or** lui descend sur la poitrine, sertie de **quatre
gemmes** : rouge feu, bleu eau, ambre terre et blanc nacré pour l'air. Ses épaulières sont plus grandes, et un
haut **col d'or** lui encadre la capuche. Ses mains nues sont cerclées de **bracelets d'or**.

Il reste chibi, à la même échelle que le Sorcier Suprême. Les orbes, les sceaux et les auras ne sont **pas
dessinés** sur lui : c'est le jeu qui les fait.

### Son trait éveillé : la Roue des éléments

**Chaque coup prend l'élément suivant.** Tant que dure l'Éveil, quatre orbes tournent autour de lui : feu, eau,
terre et air. L'orbe en tête désigne l'élément de son prochain coup visé. Ce coup porte le **trait de cet
élément** (brûlure, trempe, ébranlement ou bourrasque), en plus de son propre Écho, puis la roue tourne d'un
cran. Quatre coups font le tour des quatre éléments.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Trait élémentaire | **Trait primordial** | le trait prend l'élément de l'orbe en tête, sa couleur et son trait | 22 dégâts, 8 cases |
| SKILL 1 | Convergence élémentaire | **Grande Convergence** | le noyau des quatre explose, puis se brise en quatre éclats, un par élément, qui filent chacun sur un ennemi proche | 60 dégâts rayon 3, puis 4 éclats de 20 avec leur trait, recharge 10 s |
| SKILL 2 | Les Quatre Sceaux | **Couronne des sceaux** | les quatre sceaux s'accrochent à lui, un à chaque point cardinal, et le suivent : le feu brûle, l'eau ralentit, la terre arrête, l'air balaie | 15 s, 2 cases de lui, 14 dégâts/s, recharge 18 s |
| SKILL 3 | Renaissance | **Apothéose** | il s'élève : ses coups pèsent plus lourd, il absorbe des coups, et son Écho frappe deux fois | +12 par coup, 3 coups absorbés, 20 s, soin 3, recharge 30 s |
| FUITE | Glissement | **Pas des éléments** | il se dissout et se reforme plus loin ; à l'arrivée, un rayon de chaque élément part dans chaque couloir | 7 cases, 4 rayons de 18 avec leur trait, recharge 7 s |
| EXTRA | Jugement des quatre | **La Genèse** | le ciel s'ouvre en roue : seize météores, chacune d'un élément à tour de rôle, tombent sur les ennemis ; puis les quatre orbes se fondent au-dessus de lui et la lumière de l'origine balaie tout l'écran | 16 météores de 75 avec leur trait, puis une nova de 120 rayon 7 à travers les haies |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

Le cœur de son jeu est **la roue** : on ne choisit pas son élément, on le voit venir. On attend l'eau pour
ralentir un poursuivant, la terre pour en arrêter un autre.

---

## Image 1 — le modèle de l'Archimage

Joindre `assets/peso&cover/refonte/supreme.png` (le Sorcier Suprême, qu'il faut garder reconnaissable).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le Sorcier Suprême : c'est LE MÊME personnage, que tu dois
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
1. vue DE FACE, immobile : les deux yeux violets, l'étole aux quatre gemmes et l'auréole se voient bien
2. vue DE DOS, immobile : la capuche, l'auréole d'or derrière elle et le manteau étoilé
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : la capuche et l'auréole de profil

LE PERSONNAGE — le Sorcier Suprême ÉVEILLÉ en ARCHIMAGE PRIMORDIAL. On le reconnaît tout de suite :
même sorcier au corps compact et trapu, à la tête large, même CAPUCHE PROFONDE sur un visage
d'OMBRE NOIRE où brillent DEUX YEUX VIOLETS en amande (#b07cff, cœur blanc #f4ecff), mêmes
motifs et liserés d'OR (#e8b74a), mêmes épaulières d'or, mêmes petites bottes sombres, mêmes
MAINS NUES sans bâton. Ce qui change :
- une AURÉOLE D'OR (#e8b74a, reflets #fff1b8), un anneau plein et épais, se dresse DERRIÈRE sa
  capuche et la TOUCHE. Elle porte quatre petites runes gravées, à égale distance ;
- sa robe est devenue un long MANTEAU DE NUIT ÉTOILÉE, NOIR BLEUTÉ (#141a2e), semé de petites
  étoiles d'or à quatre branches, bordé d'un large liseré d'or ;
- une ÉTOLE D'OR lui descend sur la poitrine jusqu'aux genoux, sertie de QUATRE GEMMES rondes
  l'une sous l'autre : ROUGE FEU (#ff5a2a), BLEU EAU (#3aa8ff), AMBRE TERRE (#c88a2e) et BLANC
  NACRÉ (#eef6ff) ;
- ses ÉPAULIÈRES d'or sont plus grandes, en pointes, et un haut COL D'OR évasé encadre la capuche ;
- ses poignets portent de larges BRACELETS D'OR.
Toutes ses formes sont cernées d'un contour très foncé (#0a0812), net.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, ni dans les reflets, ni dans les ombres, ni en lueur :
le fond vert serait retiré avec. La gemme de la terre est AMBRE, jamais verte. Ses couleurs sont
le noir bleuté, l'or, le violet des yeux et les quatre gemmes.

⚠️ RÈGLE BLOQUANTE — AUCUNE ORBE autour de lui. Le Sorcier Suprême de l'image jointe est entouré de
quatre orbes de couleur : elles NE DOIVENT PAS apparaître. Le jeu les dessine lui-même.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DU SORCIER SUPRÊME : UN CORPS CHIBI COMPACT, À LA
MÊME TAILLE. Posé à côté de l'image jointe, il fait la même hauteur. L'auréole ne dépasse pas sa
capuche de plus d'un tiers de la hauteur de la tête.

⚠️ RÈGLE BLOQUANTE — L'AURÉOLE EST COLLÉE À LA CAPUCHE, jamais détachée et flottante au-dessus :
on ne voit aucun espace vert entre elles.

⚠️ RÈGLE BLOQUANTE — AUCUNE AURA, AUCUNE PARTICULE, AUCUNE FLAMME, AUCUNE LUEUR FLOUE autour de lui.
Les étoiles du manteau sont DESSINÉES SUR le tissu, pas autour.

⚠️ RÈGLE BLOQUANTE — LE MANTEAU NE CACHE PAS LES PIEDS. Les deux bottes se voient dessous,
séparées l'une de l'autre, même en très petit.

⚠️ RÈGLE BLOQUANTE — UN CONTOUR CLAIR. Le manteau sombre garde son liseré d'or net sur tous ses
bords : il doit rester lisible sur un sol sombre.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même
auréole, mains nues.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le fond est magenta ou gris, ou n'est pas un vert uni | Le détourage trouerait ses yeux et sa robe |
| Du vert sur lui (reflets, gemme de la terre verte) | Il partirait avec le fond |
| Des orbes autour de lui, comme sur l'image jointe | Le jeu les dessine : elles seraient en double, et sa boîte enflerait |
| L'auréole flotte au-dessus de la capuche | Le découpage la jetterait comme une poussière |
| Il est plus grand que le Sorcier Suprême | Il ne doit pas changer de taille en s'éveillant |
| Le manteau cache les bottes | On ne verrait plus ses pas |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/supreme_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT sa capuche, son auréole, son
manteau, son étole, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- ⚠️ fond VERT PUR UNI (#00FF00) partout : un aplat, sans dégradé ni texture. PAS de magenta.
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Sorcier Suprême éveillé en ARCHIMAGE PRIMORDIAL, en proportions CHIBI, corps
compact : capuche profonde sur un visage d'OMBRE où brillent DEUX YEUX VIOLETS, AURÉOLE D'OR
collée derrière la capuche, haut col d'or, grandes épaulières d'or, MANTEAU DE NUIT ÉTOILÉE noir
bleuté bordé d'or, ÉTOLE D'OR aux quatre gemmes (rouge, bleu, ambre, blanc), bracelets d'or,
MAINS NUES, sans bâton. Contour très foncé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
auréole comprise, est la même dans les 24 cases.

Il MARCHE d'un pas ample et posé, comme un souverain. IL NE COURT PAS : le buste reste DROIT et
la tête haute, sans bouger d'une image à l'autre. Ses pas sont de la MÊME LONGUEUR que sur le
guide. Le bas du manteau et l'étole flottent un peu différemment à chaque image.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps. Les deux mains sont nues et ouvertes, doigts détendus.

LE BALANCEMENT DES BRAS, image par image, calé sur les jambes du guide :
1. bras droit tendu vers l'AVANT, main à hauteur de taille ; bras gauche vers l'ARRIÈRE
2. bras droit qui redescend, coude un peu plié ; bras gauche qui revient
3. les deux bras le long du corps, POINT DE PASSAGE (c'est l'image aux jambes jointes)
4. bras droit qui part vers l'arrière ; bras gauche qui part vers l'avant
5. l'INVERSE de l'image 1 : bras droit vers l'ARRIÈRE, bras gauche vers l'AVANT
6. bras gauche qui revient ; bras droit qui revient
7. les deux bras le long du corps, POINT DE PASSAGE (jambes jointes)
8. bras droit qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui avance
grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, MAINS NUES.
Le VERT de la robe du guide ne doit pas passer sur lui.

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
Deux images voisines identiques pour les bras sont une erreur.

⚠️ RÈGLE BLOQUANTE — LE MANTEAU NE CACHE JAMAIS LES PIEDS : les deux bottes se voient dans les
24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LE BAS DU MANTEAU ET L'ÉTOLE BOUGENT. Dans une
même rangée, la capuche, l'auréole et le tronc se superposent exactement d'une case à l'autre, et
le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUNE ORBE autour de lui, AUCUN VERT SUR LUI, aucune aura ni lueur floue.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule détachée.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/supreme_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT sa capuche, son auréole, son manteau, son étole, ses couleurs et
ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- ⚠️ fond VERT PUR UNI (#00FF00) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Sorcier Suprême éveillé en ARCHIMAGE PRIMORDIAL, en proportions CHIBI, corps
compact : capuche profonde aux deux yeux violets, auréole d'or collée derrière la capuche, haut
col et grandes épaulières d'or, manteau de nuit étoilée noir bleuté bordé d'or, étole d'or aux
quatre gemmes, bracelets d'or, MAINS NUES. Contour très foncé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il
rassemble la magie entre ses mains et la pousse DEVANT lui, des deux paumes.
1. posture prête, les deux mains le long du corps
2. il écarte les deux bras sur les côtés, paumes ouvertes vers le haut
3. il ramène les deux mains l'une vers l'autre devant sa poitrine, paumes face à face, sans
   qu'elles se touchent
4. LE COUP : il pousse les DEUX PAUMES ouvertes DEVANT lui, bras tendus, dans la direction de la
   rangée, et un petit éclat d'OR blanc, plus petit que sa tête, brille entre ses paumes
5. l'éclat a disparu, les bras restent tendus
6. il ramène les bras
7. les mains redescendent le long du corps
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit éclat d'or de
l'image 4, collé à ses paumes. Pas de trait, pas de flamme, pas d'orbe : le JEU les dessine.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, ni en reflet du fond. AUCUNE ORBE autour de lui.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune aura, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc, la capuche et
l'auréole se superposent exactement dans les 8 images d'une rangée (seuls les bras, le manteau,
l'étole et les genoux bougent).

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, il regarde VERS LA DROITE
dans les 8 cases.
```

---

## Image 4 — les six icônes éveillées

Aucune image à joindre. ⚠️ Celle-ci est sur **MAGENTA**, pas sur vert : la terre peut y être verte.

```
Planche de six ICÔNES DE SORTS pour un jeu de rôle mobile, style cartoon coloré,
contours nets, lisibles en tout petit.

PERSONNAGE : le Sorcier Suprême éveillé en ARCHIMAGE PRIMORDIAL, le maître qui fait tourner les
quatre éléments. Ses couleurs sont l'OR (#e8b74a), l'OR CLAIR (#fff1b8), le NOIR BLEUTÉ ÉTOILÉ
(#141a2e), et les quatre éléments : le FEU ROUGE ORANGÉ (#ff5a2a), l'EAU BLEUE (#3aa8ff), la TERRE
AMBRE ET VERTE (#c88a2e, #5aa83a) et l'AIR BLANC NACRÉ (#eef6ff), avec un CONTOUR TRÈS FONCÉ
(#0a0812) net autour de chaque forme. Le motif commun des six icônes est l'ANNEAU D'OR gravé de
quatre runes : il doit se retrouver dans chacune.

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

1. TRAIT PRIMORDIAL — un trait de lumière d'or qui file en diagonale, dont la pointe est faite de
   quatre couleurs tressées : rouge, bleu, ambre et blanc.

2. GRANDE CONVERGENCE — une sphère d'or brillante qui éclate en quatre éclats, un rouge feu, un
   bleu eau, un ambre terre et un blanc d'air, qui partent vers les quatre coins.

3. COURONNE DES SCEAUX — quatre petits cercles runiques, un de chaque élément, posés en croix
   autour d'un anneau d'or, reliés à lui par un fin trait d'or.

4. APOTHÉOSE — une silhouette encapuchonnée, noire bleutée, qui s'élève les bras ouverts devant
   une grande auréole d'or rayonnante.

5. PAS DES ÉLÉMENTS — une silhouette encapuchonnée qui se dissout en quatre volutes de couleur
   (rouge, bleu, ambre, blanc), et quatre rayons qui partent en croix à côté d'elle.

6. LA GENÈSE — un grand anneau d'or gravé de quatre runes dans un ciel noir étoilé, d'où tombent
   quatre météores, une de chaque élément, et au centre de l'anneau une lumière blanche éclatante.
   C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune fumée floue, aucune lueur floue, aucune case vide, AUCUN ROSE
NI VIOLET dans les icônes : ils se confondraient avec le fond magenta. Le ciel étoilé est NOIR
BLEUTÉ, jamais violet. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Ils seront peints au shader, comme ceux des autres Éveils. Mêmes règles : trois temps (départ, coup, trace qui
s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette de l'Archimage

| rôle | couleur | usage |
|---|---|---|
| L'or | `#e8b74a` | anneaux, runes, auréole, matière commune |
| L'or clair | `#fff1b8` | cœur des coups, instant de l'impact |
| La nuit | `#141a2e` | fond du ciel de la Genèse, creux des sceaux |
| Le feu | `#ff5a2a` | orbe et éclats de feu |
| L'eau | `#3aa8ff` | orbe et éclats d'eau |
| La terre | `#c88a2e` / `#5aa83a` | orbe et éclats de terre |
| L'air | `#eef6ff` | orbe et éclats d'air |

Le motif commun est **l'anneau d'or gravé de quatre runes**, et **la roue** : tout ce qui vient en quatre tourne.
Jamais de violet en grand : seuls ses yeux le sont.

### L'Éveil lui-même

- **La charge, 0,8 s :** quatre filets de couleur montent en spirale autour de lui et se nouent au-dessus de sa
  tête.
- **L'éclosion :** un grand anneau d'or s'ouvre sous ses pieds, ses quatre runes s'allument une à une, une
  colonne de lumière blanche le traverse, et les quatre orbes en sortent pour prendre leur ronde ; la caméra
  tremble.
- **Pendant la minute :** les quatre orbes tournent autour de lui, l'orbe en tête plus grosse et plus vive ; un
  fin anneau d'or tourne à ses pieds.
- **La fin :** les orbes ralentissent, pâlissent et rentrent dans l'anneau, qui se referme.

### Les six sorts

- **Trait primordial :** le trait prend la couleur de l'orbe en tête et laisse sa trace (braises, gouttes,
  éclats de roche, souffle) ; l'orbe tourne à l'arrière.
- **Grande Convergence :** les quatre orbes se jettent dans un noyau qui grossit devant lui, file, explose en
  anneau d'or, puis quatre éclats de couleur partent chacun vers leur cible.
- **Couronne des sceaux :** quatre cercles runiques, chacun de son élément, glissent avec lui en croix, reliés à
  lui par un fil d'or.
- **Apothéose :** une colonne de lumière, l'auréole s'agrandit derrière lui le temps du sort ; chaque Écho double
  laisse deux anneaux.
- **Pas des éléments :** il se dissout en quatre volutes au départ ; à l'arrivée, l'anneau d'or s'imprime au sol
  et quatre rayons de couleur partent dans les couloirs.
- **La Genèse :** le ciel s'assombrit en nuit étoilée, un immense anneau d'or tourne au-dessus de lui, les
  météores tombent chacune de sa couleur, puis les quatre orbes se fondent en un point blanc et la lumière de
  l'origine balaie l'écran.
