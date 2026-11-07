# L'Éveil du Mage du Feu — le Phénix

> Le premier ÉVEIL des mages. Le Mage du Feu s'embrase et devient **le Phénix** pendant une minute :
> ses six sorts changent, et il renaît une fois de ses cendres. Les autres mages suivront le même modèle.

✅ **Programmé et jouable depuis le 2026-11-07** : `--demo --character fire`, puis le bouton à droite de la
barre du mage ou la touche **T**. Les chiffres ne sont pas mesurés : les bots ne s'éveillent pas.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Phénix | ci-dessous, image 1 | `refonte/feu_eveil.png` | `refonte/feu.png` et `refonte/chrono.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/feu_eveil_marche.png` | `refonte/feu_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/feu_eveil_attaque.png` | `refonte/feu_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_feu_eveil_skills.png` | aucune |

Aucun portrait à commander : la carte de l'écran de sélection reste celle du Mage du Feu. Aucune
image non plus pour les effets des sorts : ils seront peints au shader, comme ceux des autres mages.

---

## Les règles de l'Éveil (communes à tous les mages)

| règle | valeur | pourquoi |
|---|---|---|
| Durée | **1 minute** | la demande du joueur |
| Épuisement après | **10 s** : forme de base, Éveil impossible | la demande du joueur, comme la fin de transformation d'Aël |
| Charge | **6 kills** depuis le dernier Éveil | sans elle, le mage serait éveillé 6 secondes sur 7 et l'Éveil deviendrait sa forme normale |
| Bouton | le bouton de transformation d'Aël (`TransformButton`), à droite de la barre du mage, touche **T** | l'éventail est réglé pour six boutons |
| Démo | toujours disponible, sans charge | pour l'essayer à volonté |
| Fin anticipée | le joueur peut le quitter en rappuyant ; la Renaissance y met fin aussi | |

Le geste d'Éveil dure **0,8 s**. Le mage n'est pas intouchable pendant ce temps : on s'éveille
quand on a de la place, pas au contact.

---

## Le Phénix

### Ce qu'il devient

La capuche du Mage du Feu brûle et s'ouvre en une **crête de flammes en plumes**, comme la tête
d'un phénix. Ses yeux de braise deviennent **or blanc**. Sa robe écarlate se couvre de **plumes d'or**
aux épaules, et son ourlet se découpe en **pointes de plumes** qui flambent, sans descendre plus bas.
Deux **ailes de feu** s'ouvrent à moitié dans son dos : des plumes de flamme orange et or, à cœur
blanc, cernées de rouge sombre. Ses mains restent nues, cerclées de flammes plus hautes.

Il reste chibi, de la même taille que le Mage du Feu : l'Éveil ne doit jamais le faire grandir
d'un coup sur l'écran.

### Son trait éveillé : Renaissance

Une fois par Éveil, un coup qui devrait le tuer le relève à **2 PV**, dans une explosion de flammes
(40 dégâts, rayon 2,5). Il est intouchable **1,5 s**, et l'Éveil se termine. C'est le phénix qui renaît
de ses cendres, et c'est ce qui rend l'Éveil précieux pour un mage à 3 PV.

En plus, éveillé, il va **15 % plus vite** et laisse une **traînée de braises** sur les cases qu'il
quitte (6 dégâts par seconde, 1,5 s).

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Trait de flamme | **Plumes du phénix** | trois traits de flamme en éventail, chacun sur sa cible | 16 dégâts chacun, portée 8, 0,5 s |
| SKILL 1 | Boule de feu | **Soleil captif** | une boule plus grosse, qui explose deux fois et laisse du magma | 48 dégâts, rayon 3, seconde explosion 30 après 0,6 s, magma 4 s à 8/s, recharge 5 s |
| SKILL 2 | Sol embrasé | **Colonnes de feu** | six piliers de feu jaillissent en cercle autour de lui | 30 dégâts chacun, cercle de rayon 2,5, recharge 3 s |
| SKILL 3 | Aura ardente | **Couronne de brasiers** | trois brasiers tournent autour de lui et le suivent | 12 dégâts par seconde au contact, 10 s, recharge 7 s |
| FUITE | Braise fuyante | **Plongée du phénix** | il plonge 8 cases devant lui, intouchable, et une explosion part de chaque bout | 35 dégâts, rayon 1,8, recharge 7 s |
| EXTRA | Embrasement | **Supernova** | le phénix monte au ciel et retombe : l'onde traverse les murs, puis deux fois plus de météores | onde de 160, rayon 8, deux fois les météores de l'Embrasement |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

---

## Image 1 — le modèle du Phénix

Joindre `assets/peso&cover/refonte/feu.png` en PREMIER (le Mage du Feu, qu'il faut garder
reconnaissable), puis `assets/peso&cover/refonte/chrono.png` (les proportions et la mise en page).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
La PREMIÈRE image jointe montre le Mage du Feu : c'est LE MÊME personnage, que tu dois
transformer, pas remplacer. La DEUXIÈME image jointe sert UNIQUEMENT de référence de
proportions et de mise en page : ne copie ni son personnage, ni ses couleurs, ni ses objets.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : les yeux se voient bien, les ailes dépassent derrière les épaules
2. vue DE DOS, immobile : les deux ailes se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : une seule aile se voit, derrière son dos

LE PERSONNAGE — le Mage du Feu ÉVEILLÉ en PHÉNIX. On le reconnaît tout de suite : même robe
écarlate (#b3200f) à liserés d'or, même ceinture de cuir sombre, mêmes MAINS NUES cerclées de
flammes, même visage dans l'ombre avec deux yeux qui brûlent. Ce qui change :
- sa CAPUCHE s'est ouverte en une CRÊTE DE FLAMMES EN FORME DE PLUMES, dressée vers l'arrière
  comme la crête d'un phénix ; son visage reste dans l'ombre sous elle ;
- ses deux YEUX brûlent OR BLANC (#fff4d6) au lieu d'orange ;
- ses ÉPAULES portent des PLUMES D'OR (#ffc23a) qui se recouvrent comme des écailles ;
- l'OURLET de sa robe se découpe en POINTES DE PLUMES dont le bout flambe, À LA MÊME HAUTEUR
  qu'avant : ses deux bottes se voient toujours ;
- les flammes de ses MAINS sont plus hautes ;
- deux AILES DE FEU s'ouvrent À MOITIÉ dans son dos : des plumes de flamme en aplats nets,
  ORANGE (#ff6a2a) et OR (#ffc23a), au cœur BLANC CHAUD (#fff4d6), cernées de ROUGE SOMBRE
  (#6a1208).
Toutes ses formes sont cernées d'un contour brun-noir très sombre (#2a0a05), net, qui les
détache des sols clairs.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DES IMAGES JOINTES : UN CORPS CHIBI, DE LA MÊME
TAILLE QUE LE MAGE DU FEU. Sa hauteur totale vaut 2,5 TÊTES, crête comprise. Grosses mains, gros
pieds, torse court. Posé à côté de la première image jointe, il fait la même taille : la crête ne
le grandit pas de plus d'une demi-tête.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À MOITIÉ OUVERTES ET ÉTROITES. Elles ne dépassent pas de
plus d'un tiers de la largeur du corps de chaque côté, leurs pointes du haut ne montent pas plus
haut que le sommet de la crête, et celles du bas s'arrêtent à la taille. Le personnage devra
marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — LES FLAMMES SONT DES APLATS NETS ET OPAQUES, en trois ou quatre tons (blanc
chaud au cœur, or, orange, rouge sombre au bord), avec des langues bien découpées. Aucune lueur
floue, aucun halo, aucune transparence, aucune étincelle détachée.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA, ni dans les flammes, ni dans les
ombres, ni en reflet du fond. Le feu va du blanc à l'or, à l'orange et au rouge sombre, jamais
au rose.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT. L'ourlet en plumes reste à la hauteur de
l'ancienne robe : les deux bottes se voient clairement, séparées l'une de l'autre.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même
crête, mêmes ailes.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| On ne reconnaît plus le Mage du Feu | L'Éveil doit transformer le mage, pas le remplacer |
| Il est plus grand que le Mage du Feu | Il grandirait d'un coup à chaque Éveil |
| Les ailes sont grandes ouvertes ou larges | Il passerait sur les murs |
| Des flammes floues, ou roses | Le détourage y ferait des trous et laisserait une frange rose |
| L'ourlet en plumes cache les bottes | Il glisserait en marchant |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/feu_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT sa crête, ses ailes, ses couleurs
et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage du Feu éveillé en PHÉNIX, en proportions CHIBI : robe écarlate à
liserés d'or, capuche ouverte en CRÊTE DE FLAMMES EN PLUMES, yeux OR BLANC dans l'ombre,
plumes d'or aux épaules, ourlet en pointes de plumes qui flambent, MAINS NUES cerclées de
flammes, deux AILES DE FEU orange et or à cœur blanc, à moitié ouvertes dans son dos.
Flammes en aplats nets et opaques. Un contour brun-noir cerne ses formes.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale
est la même dans les 24 cases.

Il MARCHE d'un pas léger et décidé. IL NE COURT PAS : le buste reste DROIT, et les genoux
restent bas. Les ailes restent à moitié ouvertes, sans battre ; seules leurs flammes ondulent.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps. Ses deux mains sont libres et enflammées : elles balancent toutes les deux en grand, et
leurs flammes traînent un peu derrière le geste.

LE BALANCEMENT DES BRAS, image par image, calé sur les jambes du guide :
1. bras droit tendu vers l'AVANT, main à hauteur de taille ; bras gauche vers l'ARRIÈRE
2. bras droit qui redescend, coude un peu plié ; bras gauche qui revient
3. les deux bras le long du corps, POINT DE PASSAGE (c'est l'image aux jambes jointes)
4. bras droit qui part vers l'arrière ; bras gauche qui part vers l'avant
5. l'INVERSE de l'image 1 : bras droit vers l'ARRIÈRE, bras gauche tendu vers l'AVANT
6. bras gauche qui redescend ; bras droit qui revient
7. les deux bras le long du corps, POINT DE PASSAGE (jambes jointes)
8. bras droit qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui avance
grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses.

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

⚠️ RÈGLE BLOQUANTE — L'OURLET EN PLUMES NE CACHE JAMAIS LES JAMBES : les deux bottes se voient
dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS ET LES FLAMMES BOUGENT. Dans une même rangée, la
tête, la crête, le tronc et les ailes se superposent exactement d'une case à l'autre, et le profil
regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES AILES TIENNENT DANS LA CASE : pas plus d'un tiers de la largeur du corps
de chaque côté.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — LES FLAMMES SONT NETTES ET OPAQUES, SANS ROSE NI VIOLET, sans halo ni
étincelle détachée.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/feu_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT sa crête, ses ailes, ses couleurs et ses proportions, mais PAS
sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage du Feu éveillé en PHÉNIX, en proportions CHIBI : robe écarlate à
liserés d'or, capuche ouverte en CRÊTE DE FLAMMES EN PLUMES, yeux OR BLANC, plumes d'or aux
épaules, ourlet en pointes de plumes, MAINS NUES enflammées, deux AILES DE FEU à moitié
ouvertes. Flammes en aplats nets. Contour brun-noir.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il lance VERS LE BAS DE L'IMAGE, face au joueur. Ses mains viennent DROIT VERS
  NOUS, devant sa poitrine, DANS la largeur du corps
- rangée 2 : il lance VERS LE HAUT DE L'IMAGE, de dos. Ses mains partent droit devant lui,
  DANS la largeur du corps
- rangée 3 : il lance VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
1. posture prête, les mains enflammées près du corps
2. il ramène les deux mains contre sa poitrine, les ailes s'ouvrent un peu plus
3. il arme, le corps ramassé, les flammes de ses mains grandissent
4. L'IMPACT : il pousse les deux mains devant lui dans la direction de la rangée, et trois
   petites plumes de flamme en éventail en partent, plus courtes que son bras
5. les plumes ont disparu, les mains restent tendues
6. les mains commencent à revenir
7. les mains reviennent près du corps, les ailes se referment à moitié
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en
rangée 1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est les trois petites plumes
de l'image 4, plus courtes que son bras. Le JEU dessine lui-même les sorts.

⚠️ RÈGLE BLOQUANTE — LES AILES NE S'OUVRENT JAMAIS EN GRAND, et ne dépassent pas d'un tiers de la
largeur du corps de chaque côté.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — LES FLAMMES SONT NETTES ET OPAQUES, SANS ROSE NI VIOLET.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc et la tête se
superposent exactement dans les 8 images d'une rangée.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, il regarde VERS LA
DROITE dans les 8 cases.
```

---

## Image 4 — les six icônes éveillées

Aucune image à joindre.

```
Planche de six ICÔNES DE SORTS pour un jeu de rôle mobile, style cartoon coloré,
contours nets, lisibles en tout petit.

PERSONNAGE : le Mage du Feu éveillé en PHÉNIX. Ses couleurs sont le BLANC CHAUD (#fff4d6),
l'OR (#ffc23a), l'ORANGE (#ff6a2a) et le ROUGE SOMBRE (#b3200f), avec un CONTOUR BRUN-NOIR
(#2a0a05) net autour de chaque forme. Les flammes sont dessinées en aplats nets, avec des
langues bien découpées : jamais une lueur floue. Le motif commun des six icônes est la PLUME
DE FEU : elle doit se retrouver dans chacune.

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

1. PLUMES DU PHÉNIX — trois plumes de feu en éventail, pointes vers le haut, qui filent comme
   des traits, avec une courte traînée sous chacune.

2. SOLEIL CAPTIF — une grosse boule de feu à cœur blanc, entourée d'un anneau de plumes de feu,
   avec une seconde petite explosion qui éclate sur son flanc.

3. COLONNES DE FEU — six petits piliers de flamme dressés en cercle, vus en légère plongée,
   autour d'une plume d'or posée au centre.

4. COURONNE DE BRASIERS — trois boules de braise qui tournent en cercle, reliées par une traînée
   de flamme courbe, comme une couronne.

5. PLONGÉE DU PHÉNIX — un oiseau de feu, ailes repliées, qui plonge en diagonale vers le bas,
   avec une gerbe de flammes à son point d'arrivée.

6. SUPERNOVA — un PHÉNIX DE FEU, ailes GRANDES OUVERTES, au centre d'une étoile de flamme
   éclatée à huit branches. C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de
texte, pas de flou, aucune case vide, AUCUN ROSE et AUCUN VIOLET, ni dans les flammes ni dans
les ombres : ils se confondraient avec le fond magenta. Le feu va du blanc à l'or, à l'orange
et au rouge sombre. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Ce sont les consignes des shaders que j'écrirai quand il sera branché. Mêmes règles que les autres :
trois temps (départ, coup, trace qui s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette du Phénix

| rôle | couleur | usage |
|---|---|---|
| Le blanc chaud | `#fff4d6` | cœur des flammes, instant de l'impact |
| L'or | `#ffc23a` | plumes, couronnes, éclats |
| L'orange | `#ff6a2a` | matière principale des flammes |
| Le rouge sombre | `#b3200f` | bord des flammes, cendres |
| Le cerne | `#2a0a05` | contour qui tient sur les sols clairs |

Elle se distingue de l'Embrasement de base par l'**or** et le **blanc chaud** qui dominent, et par la
**plume** qu'on retrouve dans chaque effet.

### L'Éveil lui-même

- **La charge, 0,8 s :** il se recroqueville, et une spirale de plumes de feu monte autour de lui.
- **L'éclosion :** une colonne de flammes jaillit, ses ailes s'ouvrent en grand une demi-seconde
  (plus grandes que la case, puisque c'est un effet et non le sprite), puis se replient à moitié.
  La caméra tremble, et un anneau d'or court au sol.
- **Pendant la minute :** une lueur de braises sous ses pieds, des plumes de feu qui tombent de ses
  ailes, et la traînée de braises qu'il laisse.
- **La fin :** ses ailes se défont en cendres qui retombent, et il redevient le Mage du Feu.

### Renaissance

- **La mort évitée :** l'écran se fige un instant au ralenti et passe au blanc chaud.
- **Les cendres :** il se défait en un tas de cendres rougeoyantes.
- **La renaissance :** un phénix de feu jaillit des cendres, ailes grandes ouvertes, et l'explosion
  part en anneau. Il reprend forme au centre.

### Les six sorts

- **Plumes du phénix :** trois plumes de feu filent, chacune vers sa cible, en tournant un peu. Elles
  se plantent dans l'ennemi et s'y consument en une petite gerbe d'or.
- **Soleil captif :** une boule plus grosse, cerclée de plumes. Première explosion en fleur de
  flammes ; la seconde, 0,6 s plus tard, plus blanche ; puis une nappe de magma craquelée au sol.
- **Colonnes de feu :** six cercles d'or au sol se dessinent en un battement, puis six piliers de
  flamme jaillissent ensemble, hauts de deux cases, et retombent en cendres.
- **Couronne de brasiers :** trois braises tournent autour de lui, reliées par un arc de flamme qui
  tourne avec elles. Chaque ennemi touché s'embrase brièvement.
- **Plongée du phénix :** il se change en oiseau de feu, file en ligne droite, et une explosion
  en éventail de plumes part de chaque bout. Une ligne de braises reste au sol entre les deux.
- **Supernova :** il monte, et une ombre d'oiseau traverse l'écran. Puis il retombe : l'onde blanche
  traverse les murs, et la pluie de météores tombe, chacune avec une traînée de plumes.
