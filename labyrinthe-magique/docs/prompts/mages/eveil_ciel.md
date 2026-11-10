# L'Éveil de l'Archange du Ciel — le Séraphin

> Le cinquième ÉVEIL des anges. L'Archange du Ciel frappe d'en haut : sa lance et sa Colonne tombent du ciel
> par-dessus les haies, et il s'envole au-dessus des murs. Fragile (3 PV), il frappe court. Éveillé, il devient
> **le Séraphin** pendant une minute : l'ange aux six ailes, pour qui le ciel entier frappe.

**Jouable depuis le 2026-11-10** (`CharacterCatalog.ciel_awakened`). Les cinq images sont découpées dans
`assets/characters/ciel_eveil` (cases carrées, `keep_cast`), `assets/icons/ciel_eveil` et le portrait de la sélection.
Ses effets sont peints au shader (`seraphin_*`, aile de lumière et épée dans `seraphin.gdshaderinc`) ;
`tools/preview_seraphin.gd` les montre hors partie. Le Carillon réutilise le Glas du Faucheur. Les chiffres sont des
points de départ, jamais mesurés. Il reste **sous l'Archimage Primordial**.

⚠️ **FOND MAGENTA POUR TOUTES SES IMAGES, ET JAMAIS DE ROSE NI DE VIOLET SUR LUI.** Le vert est exclu : il porte de
l'émeraude, qui partirait avec le fond. Le magenta, lui, laissait des ombres roses dans les plumes blanches du
Porte-Lumière : les ombres de son blanc doivent donc être **GRIS-VERT** (#c9d6cc), jamais rosées ni violacées.
Vérifier la première image avant de commander les autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Séraphin | ci-dessous, image 1 | `refonte/ciel_eveil.png` | `refonte/ciel.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/ciel_eveil_marche.png` | `refonte/ciel_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/ciel_eveil_attaque.png` | `refonte/ciel_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_ciel_eveil_skills.png` | aucune |
| 5 | Le portrait de la sélection | [menu/portrait_ciel_eveil](../menu/portrait_ciel_eveil.md) | `interface/portraits/portrait_ciel_eveil.png` | `interface/portraits/portrait_ciel.png` et `mages/ciel_eveil_marche.png` |

Le portrait se commande en dernier : il a besoin de la planche de marche. Aucune image pour les
effets des sorts. **Les lances, les plumes qui tombent, la colonne, les ondes de la cloche, les épées et l'épée
géante sont faites par le JEU** : elles ne sont jamais dessinées sur ses planches.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## Le Séraphin

### Ce qu'il devient

On reconnaît l'Archange du Ciel : un **jeune archange guerrier** au visage calme et décidé, aux **yeux émeraude**,
aux **cheveux blancs courts** en mèches, au **diadème d'or** à petites ailes, en **armure légère blanche** à bords
dorés sous un **tabard court émeraude**, avec sa **lance d'or** dans la main droite et sa **cloche** à la ceinture.
Mais il est devenu un séraphin :

- Il porte **SIX AILES** blanches à pointes d'or, en **trois paires empilées** dans son dos : une paire haute
  au-dessus des épaules, une au milieu, une basse vers les hanches. Toutes sont **petites et à demi repliées**,
  serrées les unes contre les autres : ensemble, elles ne sont pas plus larges que les deux grandes ailes d'avant.
- Une **auréole d'or** flotte juste au-dessus de son diadème, cerclée de petites **flammes émeraude** dessinées.
  Elle touche ses cheveux.
- Sa lance d'or a maintenant une **pointe de flamme émeraude**, nette et dessinée.
- Sa cloche est devenue une **cloche d'or gravée**, un peu plus grande, toujours sur la hanche gauche.
- Son tabard émeraude porte une **broderie d'or** de six petites ailes.

Il reste chibi, à la même échelle que l'Archange du Ciel.

### Son trait éveillé : les Yeux du ciel

**Le ciel entier frappe pour lui.** Tant que dure l'Éveil :
- chaque Lance céleste en appelle **une seconde** sur un autre ennemi proche, elle aussi par-dessus les haies ;
- ce que le ciel frappe (les lances, la Colonne, les plumes, les épées) est **marqué** : il prend **+20 %** de
  dégâts pendant 3 s.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Lance céleste | **Lance du Séraphin** | deux lances tombent du ciel à chaque coup, sur deux ennemis différents, par-dessus les haies | 18 dégâts chacune, 7 cases, recharge 0,55 s |
| SKILL 1 | Plumes-lames | **Pluie de plumes** | une plume tranchante tombe du ciel sur chaque ennemi à portée, six au plus | 6 plumes, 26 dégâts, 6 cases, recharge 5 s |
| SKILL 2 | Colonne du ciel | **Colonne du jugement** | le pilier s'abat sur l'ennemi visé, cloue ce qui l'entoure, puis reste allumé et brûle ce qui y entre | 50 dégâts, rayon 2, cloue 2,5 s ; reste 3 s à 15 dégâts/s ; recharge 9 s |
| SKILL 3 | Cloche céleste | **Carillon céleste** | la cloche sonne trois fois ; chaque coup part de lui, passe les haies, blesse et étourdit | 3 coups à 1 s d'écart, rayon 4,5, 12 dégâts, étourdit 1 s ; recharge 12 s |
| FUITE | Envol | **Ascension** | il s'élève plus longtemps, intouchable ; pendant le vol, une lance tombe toutes les 0,6 s sur l'ennemi le plus proche ; il retombe avec une grande onde | 5 s, lances de 18, onde 35 rayon 2,5 ; recharge 12 s |
| EXTRA | Jugement des Six Ailes | **Jugement dernier** | 24 épées tombent une à une sur les ennemis de la carte, puis une épée géante s'abat au centre et frappe une grande zone | 24 épées de 45 ; épée géante 120, rayon 4 |

Les boss ne sont jamais cloués ni étourdis, comme pour l'Archange du Ciel. L'Extra garde sa charge de kills :
l'Éveil change le sort, il ne le rend pas gratuit.

Le cœur de son jeu reste **frapper de loin et par-dessus les murs** : il ne doit pas se laisser toucher. L'Éveil
lui donne plus de coups venus du ciel, pas plus de vie.

---

## Image 1 — le modèle du Séraphin

Joindre `assets/peso&cover/refonte/ciel.png` (l'Archange du Ciel, qu'il faut garder reconnaissable).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre l'Archange du Ciel : c'est LE MÊME personnage, que tu dois
transformer, pas remplacer. Ne reprends PAS la mise en page de l'image jointe.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le visage, l'auréole, la lance et le haut des six ailes se voient bien
2. vue DE DOS, immobile : les SIX AILES en trois paires empilées se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : la lance tenue droite, les ailes derrière son dos

LE PERSONNAGE — l'Archange du Ciel ÉVEILLÉ en SÉRAPHIN. On le reconnaît tout de suite : même
jeune archange guerrier au corps CHIBI, même visage calme et décidé bien VISIBLE, mêmes YEUX
ÉMERAUDE (#34e07a), mêmes CHEVEUX BLANCS COURTS en mèches, même DIADÈME D'OR (#f2c14e) à petites
ailes sur les tempes, même ARMURE LÉGÈRE BLANCHE (#f4f7f2) à bords dorés, même TABARD COURT
ÉMERAUDE (#1f9e5a) à liseré d'or qui s'arrête au-dessus des genoux, mêmes bottes blanches, même
LANCE D'OR dans la main DROITE, pointe en l'air. Ce qui change :
- il porte SIX AILES de plumes BLANCHES à pointes d'OR, en TROIS PAIRES EMPILÉES dans son dos :
  une paire haute au-dessus des épaules, une paire au milieu du dos, une paire basse vers les
  hanches. Toutes sont PETITES et À DEMI REPLIÉES, serrées les unes contre les autres ;
- une AURÉOLE D'OR flotte juste au-dessus du diadème, cerclée de petites FLAMMES ÉMERAUDE
  dessinées, et TOUCHE ses cheveux ;
- la pointe de sa lance est une FLAMME ÉMERAUDE nette, dessinée, à cœur blanc ;
- sa cloche est une CLOCHE D'OR GRAVÉE, un peu plus grande, sur la hanche gauche ;
- son tabard porte une broderie d'or de six petites ailes.
Toutes ses formes claires sont cernées d'un contour vert très sombre (#10261c), net.

⚠️ RÈGLE BLOQUANTE — LES OMBRES DU BLANC SONT GRIS-VERT (#c9d6cc), JAMAIS ROSES NI VIOLETTES. Aucun
rose, aucun violet, aucun magenta sur lui, ni dans les plumes, ni dans les reflets : le fond
serait retiré avec.

⚠️ RÈGLE BLOQUANTE — LES SIX AILES TIENNENT DANS LA LARGEUR DE DEUX. Ensemble, elles ne dépassent
pas de plus d'un quart de la largeur du corps de chaque côté, et leurs pointes s'arrêtent au
niveau des genoux. Il devra marcher dans un couloir étroit. On compte bien SIX ailes de dos.

⚠️ RÈGLE BLOQUANTE — L'AURÉOLE TOUCHE SES CHEVEUX, jamais détachée et flottante.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'ARCHANGE DU CIEL : UN CORPS CHIBI DE 2,5 TÊTES,
À LA MÊME TAILLE. Posé à côté de l'image jointe, il fait la même hauteur. La lance ne dépasse pas
sa tête de plus d'une demi-tête.

⚠️ RÈGLE BLOQUANTE — AUCUNE AURA, AUCUN RAYON, AUCUNE PLUME QUI VOLE, AUCUNE LUEUR FLOUE autour de
lui. Les flammes de l'auréole et de la lance sont DESSINÉES, nettes et pleines. Le jeu ajoute le
reste.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
six ailes, même auréole, même lance, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Des ombres roses ou violettes dans le blanc | Le détourage du magenta y ferait des trous |
| Les six ailes sont déployées ou très larges | Il ne tiendrait plus dans un couloir |
| On ne compte pas six ailes de dos | Ce n'est plus un séraphin |
| L'auréole flotte au-dessus de la tête | Le découpage la jetterait comme une poussière |
| Des plumes qui volent ou des rayons autour de lui | Le jeu les dessine : ils seraient en double |
| Il est plus grand que l'Archange du Ciel | Il ne doit pas changer de taille en s'éveillant |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/ciel_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT ses six ailes, son auréole, son
armure, son tabard, sa lance, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Archange du Ciel éveillé en SÉRAPHIN, en proportions CHIBI : visage calme aux yeux
émeraude, cheveux blancs courts, diadème d'or, AURÉOLE D'OR à flammes émeraude qui touche ses
cheveux, armure légère blanche à bords dorés, tabard court émeraude brodé d'or, SIX AILES blanches
à pointes d'or en trois paires empilées, petites et À DEMI REPLIÉES, LANCE D'OR à pointe de flamme
émeraude tenue DROITE dans la main DROITE, cloche d'or à la hanche gauche. Contour vert très sombre
net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
auréole comprise, est la même dans les 24 cases.

Il MARCHE d'un pas léger et assuré, comme s'il touchait à peine le sol. IL NE COURT PAS : le buste
reste DROIT et la tête haute, sans bouger d'une image à l'autre. Ses pas sont de la MÊME LONGUEUR
que sur le guide. La pointe des ailes frémit un peu différemment à chaque image.

LA LANCE reste dans sa main DROITE, tenue droite, pointe en l'air, dans les 24 cases : elle monte et
descend un peu avec le pas, sans jamais basculer ; ce bras balance moins loin. SON BRAS GAUCHE
BALANCE FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand la jambe droite part vers l'avant, le bras
gauche part vers l'avant lui aussi, puis il repart vers l'arrière. Le coude plie, la main suit avec
un léger temps de retard. Il ne reste JAMAIS figé le long du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, AVEC SA
LANCE.

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

⚠️ RÈGLE BLOQUANTE — LES SIX AILES RESTENT À DEMI REPLIÉES dans les 24 cases, jamais déployées.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LE BAS DU TABARD ET LA POINTE DES AILES BOUGENT.
Dans une même rangée, la tête, l'auréole et le tronc se superposent exactement d'une case à
l'autre, et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE NI VIOLET SUR LUI : les ombres du blanc sont gris-vert. Aucune
plume qui vole, aucune lueur floue.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule détachée.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/ciel_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT ses six ailes, son auréole, son armure, son tabard, sa lance, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Archange du Ciel éveillé en SÉRAPHIN, en proportions CHIBI : cheveux blancs,
auréole d'or à flammes émeraude, armure blanche à bords dorés, tabard émeraude, six ailes blanches
à pointes d'or à demi repliées, LANCE D'OR à pointe de flamme émeraude dans la main DROITE. Contour
vert très sombre net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il lève
sa lance vers le ciel pour appeler la foudre du ciel, puis la pointe vers sa cible.
1. posture prête, lance droite
2. il lève la lance bien haut au-dessus de sa tête, pointe vers le ciel
3. la flamme de la pointe s'allume plus fort, la lance tout en haut
4. LE COUP : il abaisse la lance et la pointe DEVANT lui, dans la direction de la rangée, bras
   tendu, et un petit ÉCLAT ÉMERAUDE, plus petit que sa tête, brille sur la pointe
5. l'éclat a disparu, la lance est encore tendue
6. la lance remonte
7. la lance revient presque à la verticale
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE COUP PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit éclat émeraude
de l'image 4, collé à la pointe. Pas de lance qui tombe du ciel, pas de rayon : le JEU les
dessine.

⚠️ RÈGLE BLOQUANTE — LES SIX AILES RESTENT À DEMI REPLIÉES pendant tout le geste.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE NI VIOLET SUR LUI, ni en reflet du fond.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune aura, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc, la tête et l'auréole
se superposent exactement dans les 8 images d'une rangée (seuls les bras et la lance bougent).

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

PERSONNAGE : l'Archange du Ciel éveillé en SÉRAPHIN, l'ange aux six ailes. Ses couleurs sont le
BLANC (#f4f7f2, ombres gris-vert #c9d6cc), l'OR (#f2c14e), l'ÉMERAUDE (#34e07a, foncé #1f9e5a) et
la lumière blanche à cœur d'or, avec un CONTOUR VERT TRÈS SOMBRE (#10261c) net autour de chaque
forme. Le motif commun des six icônes est CE QUI TOMBE DU CIEL : une lance, une plume ou une épée
qui descend d'en haut, avec une traînée de lumière. Il doit se retrouver dans chacune.

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

1. LANCE DU SÉRAPHIN — DEUX lances d'or à pointe de flamme émeraude qui tombent du ciel côte à côte,
   en biais, avec des traînées de lumière.

2. PLUIE DE PLUMES — six plumes blanches à pointe d'or, tranchantes, qui tombent du ciel en pluie,
   pointe en bas.

3. COLONNE DU JUGEMENT — un pilier de lumière blanche et or qui s'abat sur un cercle de sol fendu,
   avec des flammes émeraude à sa base.

4. CARILLON CÉLESTE — une cloche d'or gravée, et TROIS ondes émeraude qui en partent en cercles.

5. ASCENSION — un petit ange vu de dos qui s'élève, six ailes ouvertes, au-dessus d'un mur de
   haie, et des lances qui tombent sous lui.

6. JUGEMENT DERNIER — une épée géante d'or et de lumière qui s'abat pointe en bas, entourée de
   six ailes de lumière ouvertes en éventail et d'une couronne de petites épées. C'est l'icône la
   plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune lueur floue, aucune case vide, AUCUN ROSE NI VIOLET dans les
icônes : ils se confondraient avec le fond magenta. Les ombres du blanc sont GRIS-VERT, jamais
rosées. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Ils seront peints au shader, comme ceux des autres Éveils. Mêmes règles : trois temps (départ, coup, trace qui
s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette du Séraphin

| rôle | couleur | usage |
|---|---|---|
| Le blanc | `#f4f7f2` | lumière des colonnes, plumes |
| L'or | `#f2c14e` | lances, épées, auréole, anneaux |
| L'émeraude | `#34e07a` / `#1f9e5a` | flammes, ondes, marques |
| Le cœur | `#fff6d8` | instant de l'impact |
| Le contour | `#10261c` | tout ce qui doit tenir sur un sol clair |

Le motif commun est **ce qui tombe du ciel avec une traînée de lumière**, et **l'aile de lumière**. Jamais de rose,
de violet ni de vert pomme.

### L'Éveil lui-même

- **La charge, 0,8 s :** des plumes de lumière montent en spirale autour de lui, et l'auréole s'allume.
- **L'éclosion :** six ailes de lumière s'ouvrent derrière lui en grand éventail, une colonne de lumière tombe sur
  lui, et un anneau émeraude court au sol ; la caméra tremble.
- **Pendant la minute :** six petites ailes de lumière battent lentement derrière lui, et un œil d'or veille
  au-dessus de chaque ennemi marqué.
- **La fin :** les ailes de lumière se replient et se dissolvent en plumes.

### Les six sorts

- **Lance du Séraphin :** les deux lances tombent en même temps, avec leur traînée ; chaque impact laisse une petite
  flamme émeraude.
- **Pluie de plumes :** chaque plume s'annonce par une ombre au sol, puis tombe en tournant et se plante.
- **Colonne du jugement :** le pilier tombe, le sol se fend, puis la colonne reste debout, plus fine, crépitant de
  flammes émeraude jusqu'à s'éteindre.
- **Carillon céleste :** une cloche de lumière au-dessus de lui ; à chaque coup, une onde émeraude part et passe
  les haies.
- **Ascension :** il monte dans une colonne de plumes ; ses lances tombent sous lui ; il retombe dans un anneau de
  lumière qui court au sol.
- **Jugement dernier :** les épées tombent comme avant, puis le ciel s'ouvre, six ailes immenses se déploient sur
  l'écran, et l'épée géante s'abat au centre dans un éclair blanc et une onde d'or.
