# L'Éveil du Porte-Lumière — l'Étoile du Matin

> Le premier ÉVEIL des anges. Le Porte-Lumière aveugle : sa lumière fait perdre sa trace aux ennemis. Éveillé, il
> devient **l'Étoile du Matin** pendant une minute, un petit soleil qui marche : ce qu'il aveugle, il le frappe plus
> fort, et ce qui reste collé à lui finit ébloui. « Porte-Lumière » et « Étoile du Matin » sont deux vieux noms de la
> même étoile.

**Jouable depuis le 2026-11-09** (`CharacterCatalog.lumiere_awakened`). Les cinq images ont été commandées dans cet
ordre ; elles sont découpées dans `assets/characters/lumiere_eveil`, `assets/icons/lumiere_eveil` et le portrait de la
sélection. Ses effets sont peints au shader (`aurore_*`, étoile et palette dans `aurore.gdshaderinc`) ;
`tools/preview_aurore.gd` les montre hors partie. Les chiffres ci-dessous sont des points de départ, jamais mesurés. Il doit rester **sous l'Archimage Primordial** : le Suprême reste le plus fort, et
le Porte-Lumière est déjà « peut-être un peu fort ».

⚠️ **FOND VERT POUR LE PERSONNAGE, MAGENTA POUR LES ICÔNES.** Le Porte-Lumière de base a été commandé sur magenta, et
ses plumes blanches en gardaient des ombres roses qu'il a fallu retirer (`despill`). Éveillé, il est encore plus
blanc et plus lumineux : ses trois planches de personnage se commandent sur un **vert pur (#00FF00)**, comme
l'Archimage, et il ne porte **aucun vert**. Les icônes restent sur **magenta**, sans aucun rose ni violet. Vérifier
la première image avant de commander les autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle de l'Étoile du Matin | ci-dessous, image 1 | `refonte/lumiere_eveil.png` | `refonte/lumiere.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/lumiere_eveil_marche.png` | `refonte/lumiere_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/lumiere_eveil_attaque.png` | `refonte/lumiere_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_lumiere_eveil_skills.png` | aucune |
| 5 | Le portrait de la sélection | [menu/portrait_lumiere_eveil](../menu/portrait_lumiere_eveil.md) | `interface/portraits/portrait_lumiere_eveil.png` | `interface/portraits/portrait_lumiere.png` et `mages/lumiere_eveil_marche.png` |

Le portrait se commande en dernier : il a besoin de la planche de marche. Aucune image pour les effets des sorts :
ils seront peints au shader. **Le disque solaire, les rayons et le soleil de l'Extra sont faits par le JEU** : ils ne
sont jamais dessinés sur ses planches, sauf le disque d'or collé derrière sa tête.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## L'Étoile du Matin

### Ce qu'il devient

On reconnaît le Porte-Lumière : son visage serein d'enfant, ses **courts cheveux blonds**, son armure légère
**blanc ivoire à liserés d'or** sur une tunique blanche, ses **bottes d'or**, ses deux ailes à demi repliées, et sa
**lance dorée** dans la main droite. Mais il est devenu un petit soleil :

- Son auréole plate s'est changée en un **DISQUE SOLAIRE d'or**, plein, gravé de rayons, dressé DERRIÈRE sa tête et
  collé à elle, comme une couronne de soleil.
- Ses **ailes** ne sont plus en plumes : ce sont des **AILES DE RAYONS**, de longues lames de lumière blanche à
  cœur d'or, nettes et pointues, rangées comme des plumes. Toujours deux, toujours à demi repliées.
- Son armure est passée à l'**or blanc** : plastron et épaulières blanc nacré, liserés d'or vif, et une **étoile à
  huit branches** d'or gravée au milieu du plastron.
- Ses **yeux** brillent d'or clair, et quelques mèches de ses cheveux blonds tournent au **blanc doré**.
- La pointe de cristal de sa lance est devenue une **ÉTOILE À HUIT BRANCHES** de cristal blanc, cerclée d'or.
- Une courte **cape blanche** doublée d'or lui tombe des épaules jusqu'aux genoux, entre les ailes.

Il reste chibi, à la même échelle que le Porte-Lumière. Il garde **deux** ailes : l'Archange du Ciel en a six et
le Chérubin quatre, et l'Étoile du Matin ne doit ressembler à aucun des deux.

### Son trait éveillé : l'Éblouissement

**Ce qu'il aveugle, il le frappe plus fort.** Tant que dure l'Éveil :
- tout coup sur un ennemi **aveuglé** fait **+30 %** de dégâts ;
- un ennemi qui reste **collé à lui plus d'une seconde** est aveuglé, sans passer outre `_blind_locks` : la limite
  qui empêche d'aveugler un ennemi en permanence vaut toujours.

Son jeu reste d'aveugler. Éveillé, l'aveuglement devient aussi une arme.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Trait d'aube | **Trait solaire** | un rayon qui traverse tous les ennemis de la ligne ; un coup sur trois aveugle | 18 dégâts, 9 cases, recharge 0,45 s, aveugle 1,5 s |
| SKILL 1 | Lance solaire | **Lance de l'Aurore** | la Lance suit les couloirs et vire vers les ennemis, puis **reste allumée** : un mur de lumière qui brûle et aveugle ce qui le traverse | 60 dégâts, 14 cases, puis 3 s à 12 dégâts/s, aveugle 2 s, recharge 7 s |
| SKILL 2 | Sanctuaire | **Cathédrale de lumière** | un grand cercle bordé de colonnes de lumière : les ennemis y sont aveuglés et brûlés, et il y regagne des PV | rayon 3, 10 s, 16 dégâts/s, aveugle 2,5 s, +1 PV toutes les 4 s dedans, recharge 18 s |
| SKILL 3 | Ailes gardiennes | **Égide solaire** | ses ailes de rayons se referment sur lui et encaissent des coups ; chaque coup encaissé repart en rayon vers celui qui a frappé | 3 coups, 10 s, rayon renvoyé de 30 qui aveugle 2 s, recharge 20 s |
| FUITE | Envol | **Trait de l'étoile** | il devient un rayon et file droit dans le couloir, en blessant et aveuglant tout ce qu'il traverse | 8 cases, 25 dégâts, aveugle 2 s, recharge 8 s |
| EXTRA | L'Aube | **Le Soleil de midi** | un soleil se lève au-dessus de lui et le suit : chaque seconde, il lance un rayon sur chaque ennemi à l'écran, et tous restent aveuglés ; à la fin, il tombe en une dernière vague de lumière | 8 s, un rayon de 35 par ennemi et par seconde, aveugle tant qu'il brille, puis 80 dégâts dans un rayon de 6 |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit. Comme l'Aube, le Soleil de
midi passe outre `_blind_locks`.

Le cœur de son jeu est **l'aveuglement payé** : on aveugle d'abord, avec la Lance, la Cathédrale ou un coup sur
trois, puis on frappe ce qui ne voit plus.

---

## Image 1 — le modèle de l'Étoile du Matin

Joindre `assets/peso&cover/refonte/lumiere.png` (le Porte-Lumière, qu'il faut garder reconnaissable).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le Porte-Lumière, un ange : c'est LE MÊME personnage, que tu dois
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
1. vue DE FACE, immobile : le visage, l'étoile du plastron et le disque solaire se voient bien
2. vue DE DOS, immobile : le disque solaire derrière la tête, les deux ailes de rayons et la cape
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : la lance tenue droite, une aile de profil

LE PERSONNAGE — le Porte-Lumière ÉVEILLÉ en ÉTOILE DU MATIN. On le reconnaît tout de suite :
même ange au corps CHIBI, même visage serein d'enfant bien visible, mêmes COURTS CHEVEUX
BLONDS, même armure légère sur une tunique blanche, mêmes BOTTES D'OR, même LANCE DORÉE tenue
de la main DROITE. Ce qui change :
- son auréole est devenue un DISQUE SOLAIRE D'OR (#e8b74a, reflets #fff1b8), un disque plein
  gravé de rayons fins, dressé DERRIÈRE sa tête et qui la TOUCHE, comme une couronne de soleil ;
- ses deux ailes sont devenues des AILES DE RAYONS : de longues lames de lumière BLANCHE
  (#fffaf0) à cœur d'OR (#ffd479), nettes, pointues, rangées comme des plumes, À DEMI REPLIÉES ;
- son armure est passée à l'OR BLANC : plastron et épaulières blanc nacré (#f6f0e2), liserés
  d'or vif (#e8b74a), et une ÉTOILE À HUIT BRANCHES d'or gravée au milieu du plastron ;
- ses yeux brillent d'OR CLAIR (#ffe9a8), et quelques mèches blondes tournent au blanc doré ;
- la pointe de sa lance est une ÉTOILE À HUIT BRANCHES de cristal blanc, cerclée d'or ;
- une courte CAPE BLANCHE doublée d'or tombe de ses épaules jusqu'aux genoux, entre les ailes.
Toutes ses formes sont cernées d'un contour BRUN FONCÉ (#3a2410), net, y compris chaque lame
de ses ailes.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, ni dans les reflets, ni dans les ombres, ni en lueur :
le fond vert serait retiré avec. Les ombres de son blanc sont BEIGE et BRUN CLAIR (#c9b48a),
jamais vertes, jamais roses.

⚠️ RÈGLE BLOQUANTE — DEUX AILES SEULEMENT, À DEMI REPLIÉES, jamais déployées. Elles ne
dépassent pas de plus d'un quart de la largeur du corps de chaque côté, et leurs pointes
s'arrêtent au niveau des genoux. Il devra marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — LE DISQUE SOLAIRE EST COLLÉ À LA TÊTE, jamais détaché et flottant : on ne
voit aucun espace vert entre eux. Il ne dépasse pas la tête de plus d'un tiers de sa hauteur.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DU PORTE-LUMIÈRE : UN CORPS CHIBI DE 2,5 TÊTES, À LA
MÊME TAILLE. Posé à côté de l'image jointe, il fait la même hauteur.

⚠️ RÈGLE BLOQUANTE — AUCUNE AURA, AUCUN HALO, AUCUN RAYON AUTOUR DE LUI, AUCUNE PARTICULE, AUCUNE
LUEUR FLOUE. Ses ailes sont des formes NETTES et pleines, pas de la lumière floue. Le jeu ajoute
lui-même la lumière.

⚠️ RÈGLE BLOQUANTE — UN CONTOUR BRUN FONCÉ NET autour de toutes les formes blanches : il doit
rester lisible sur un sol très clair.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
ailes, même disque, même lance, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le fond est magenta ou gris, ou n'est pas un vert uni | Le détourage laisserait des ombres roses sur ses plumes |
| Du vert sur lui (reflets, ombres) | Il partirait avec le fond |
| Plus de deux ailes, ou des ailes déployées | Il ressemblerait à l'Archange du Ciel, et ne tiendrait plus dans un couloir |
| Des ailes en lumière floue | Le détourage en ferait une bouillie transparente |
| Le disque flotte au-dessus de la tête | Le découpage le jetterait comme une poussière |
| Un halo ou des rayons autour de lui | Le jeu les dessine : ils seraient en double, et sa boîte enflerait |
| Il est plus grand que le Porte-Lumière | Il ne doit pas changer de taille en s'éveillant |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/lumiere_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son disque solaire, ses ailes de
rayons, son armure, sa cape, sa lance, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- ⚠️ fond VERT PUR UNI (#00FF00) partout : un aplat, sans dégradé ni texture. PAS de magenta.
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Porte-Lumière éveillé en ÉTOILE DU MATIN, en proportions CHIBI : visage
serein d'enfant, courts cheveux blonds, DISQUE SOLAIRE D'OR collé derrière la tête, deux AILES
DE RAYONS blanches à cœur d'or À DEMI REPLIÉES, armure d'or blanc à l'étoile d'or, courte cape
blanche doublée d'or, bottes d'or, LANCE DORÉE à pointe en étoile tenue DROITE dans la main
DROITE. Contour brun foncé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
disque compris, est la même dans les 24 cases.

Il MARCHE d'un pas léger et assuré. IL NE COURT PAS : le buste reste DROIT et la tête haute,
sans bouger d'une image à l'autre. Ses pas sont de la MÊME LONGUEUR que sur le guide. La cape
et la pointe des ailes flottent un peu différemment à chaque image.

LA LANCE reste dans sa main DROITE, tenue droite, pointe en haut, dans les 24 cases : elle
monte et descend un peu avec le pas, sans jamais basculer. SON BRAS GAUCHE BALANCE FRANCHEMENT,
EN OPPOSITION AUX JAMBES : quand la jambe droite part vers l'avant, le bras gauche part vers
l'avant lui aussi, puis il repart vers l'arrière. Le coude plie, la main suit avec un léger
temps de retard. Il ne reste JAMAIS figé le long du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, AVEC SA
LANCE. Le VERT de la robe du guide ne doit pas passer sur lui.

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

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES dans les 24 cases, jamais déployées, et
leurs pointes s'arrêtent aux genoux.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LE BRAS GAUCHE, LA CAPE ET LA POINTE DES AILES BOUGENT. Dans
une même rangée, la tête, le disque et le tronc se superposent exactement d'une case à l'autre,
et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, aucun halo, aucun rayon autour de lui, aucune lueur floue.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule détachée.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/lumiere_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT son disque solaire, ses ailes de rayons, son armure, sa cape, sa
lance, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- ⚠️ fond VERT PUR UNI (#00FF00) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Porte-Lumière éveillé en ÉTOILE DU MATIN, en proportions CHIBI : visage
serein, courts cheveux blonds, disque solaire d'or collé derrière la tête, deux ailes de rayons
blanches à cœur d'or à demi repliées, armure d'or blanc à l'étoile d'or, courte cape blanche,
bottes d'or, LANCE DORÉE à pointe en étoile dans la main DROITE. Contour brun foncé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il
pointe sa lance et en tire un trait de soleil.
1. posture prête, lance tenue droite
2. il ramène la lance contre l'épaule, l'étoile de la pointe s'éclaire
3. la lance bascule vers l'avant, les deux mains sur la hampe
4. LE TIR : lance pointée DEVANT lui, bras tendus, dans la direction de la rangée, et un petit
   éclat d'OR blanc, plus petit que sa tête, brille sur l'étoile de la pointe
5. l'éclat a disparu, la lance reste pointée
6. la lance remonte
7. la lance revient presque à la verticale
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE TIR PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2 : la pointe de la lance vise le bas de l'image en rangée 1, le haut en rangée 2. Le corps
reste CENTRÉ dans sa case.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit éclat d'or de
l'image 4, collé à la pointe. Pas de rayon, pas de trait, pas de halo : le JEU les dessine.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES pendant tout le geste.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN VERT SUR LUI, ni en reflet du fond.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune aura, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc, la tête et le disque
se superposent exactement dans les 8 images d'une rangée (seuls les bras, la lance, la cape et
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

PERSONNAGE : le Porte-Lumière éveillé en ÉTOILE DU MATIN, un ange devenu petit soleil. Ses
couleurs sont le BLANC CHAUD (#fffaf0), l'OR (#e8b74a), l'OR CLAIR (#fff1b8), le JAUNE SOLAIRE
(#ffd479) et le BLEU CIEL TRÈS PÂLE (#dff3ff) pour les reflets, avec un CONTOUR BRUN FONCÉ
(#3a2410) net autour de chaque forme. Le motif commun des six icônes est l'ÉTOILE D'OR À HUIT
BRANCHES : elle doit se retrouver dans chacune.

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

1. TRAIT SOLAIRE — un rayon blanc et or qui file en diagonale et transperce trois petites
   silhouettes sombres alignées, avec une étoile à huit branches à sa pointe.

2. LANCE DE L'AURORE — une lance dorée à pointe en étoile, d'où part un rayon épais qui tourne à
   angle droit, comme dans un couloir, et reste allumé derrière elle.

3. CATHÉDRALE DE LUMIÈRE — un cercle d'or au sol vu en légère plongée, bordé de colonnes de
   lumière blanche, avec une étoile à huit branches dessinée en vitrail au centre.

4. ÉGIDE SOLAIRE — deux ailes de rayons blanches et or refermées en bouclier rond, et une étoile
   d'or au centre d'où repart un court rayon.

5. TRAIT DE L'ÉTOILE — une petite silhouette d'ange qui file en diagonale, changée en traînée de
   lumière blanche et or, une étoile au départ et une à l'arrivée.

6. LE SOLEIL DE MIDI — un grand soleil d'or rayonnant, avec une étoile à huit branches en son
   cœur, d'où tombent des rayons droits vers le bas. C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune fumée floue, aucune lueur floue, aucune case vide, AUCUN ROSE
NI VIOLET dans les icônes : ils se confondraient avec le fond magenta. Les ombres du blanc sont
BEIGE et BRUN CLAIR. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Ils seront peints au shader, comme ceux des autres Éveils. Mêmes règles : trois temps (départ, coup, trace qui
s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette de l'Étoile du Matin

| rôle | couleur | usage |
|---|---|---|
| Le blanc chaud | `#fffaf0` | cœur des rayons, instant de l'impact |
| L'or | `#e8b74a` | disque, étoiles, colonnes, liserés |
| L'or clair | `#fff1b8` | halos, trace qui s'éteint |
| Le jaune solaire | `#ffd479` | le soleil de l'Extra, la couronne des rayons |
| Le bleu ciel pâle | `#dff3ff` | reflets froids, pour que le blanc ne vire pas au jaune |

Le motif commun est **l'étoile à huit branches** et **le rayon droit** : tout ce qui frappe est une ligne de
lumière nette, jamais une boule. Jamais de rose ni de violet.

### L'Éveil lui-même

- **La charge, 0,8 s :** des rayons convergent vers lui de tout l'écran et se resserrent sur sa poitrine.
- **L'éclosion :** une étoile à huit branches s'allume à ses pieds, une colonne de lumière blanche monte jusqu'au
  haut de l'écran, et un flash bref blanchit tout ; la caméra tremble.
- **Pendant la minute :** un disque solaire tourne lentement derrière lui, et une fine couronne de rayons bat à ses
  pieds. Un ennemi aveuglé porte une petite étoile au-dessus de la tête, qui dit qu'il prend plus cher.
- **La fin :** les rayons rentrent dans le disque, qui pâlit et s'éteint.

### Les six sorts

- **Trait solaire :** un rayon blanc à cœur d'or, une étoile qui éclate sur chaque ennemi traversé ; le coup qui
  aveugle laisse un anneau de lumière plus large.
- **Lance de l'Aurore :** le rayon épais suit les couloirs comme la Lance, puis reste allumé et pulse ; ce qui le
  traverse s'embrase d'un éclat blanc. Il s'éteint en se fendant en poussière d'or.
- **Cathédrale de lumière :** un cercle d'or s'imprime au sol avec une rosace de vitrail, puis des colonnes de
  lumière montent tout autour ; chaque PV regagné fait monter une petite étoile sur le mage.
- **Égide solaire :** les ailes de rayons se referment en bouclier autour de lui ; à chaque coup encaissé, une lame
  du bouclier s'éteint et un rayon part vers celui qui a frappé.
- **Trait de l'étoile :** il s'efface dans une étoile au départ, une traînée de lumière droite parcourt le couloir,
  et une étoile s'ouvre à l'arrivée où il réapparaît.
- **Le Soleil de midi :** l'écran passe en plein jour, un grand soleil se lève au-dessus de lui et le suit ; chaque
  seconde, des rayons droits tombent sur chaque ennemi à l'écran. À la fin, le soleil tombe sur lui et une vague
  de lumière blanche part en cercle jusqu'au bord de l'écran.
