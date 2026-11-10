# L'Éveil de l'Archange d'Acier — le Forgeron Céleste

> Le quatrième ÉVEIL des anges. L'Archange d'Acier est l'ange qui encaisse : 6 PV, trois plaques d'armure qui prennent
> chacune un coup avant les PV, et ses kills les reforgent. Éveillé, il devient **le Forgeron Céleste** pendant une
> minute : la forge du ciel elle-même. Il encaisse encore plus, et chaque coup qu'il prend se retourne contre qui le
> frappe.

**Jouable depuis le 2026-11-10** (`CharacterCatalog.acier_awakened`). Les cinq images sont découpées dans
`assets/characters/acier_eveil` (avec `keep_cast`), `assets/icons/acier_eveil` et le portrait de la sélection. Ses
effets sont peints au shader (`forgeron_*`, palette, fissures et gerbe dans `forgeron.gdshaderinc`) ;
`tools/preview_forgeron.gd` les montre hors partie. Le métal en fusion au sol est une case en feu ordinaire
(10 dégâts/s). Les chiffres sont des points de départ, jamais mesurés. Il reste **sous l'Archimage Primordial**.

⚠️ **FOND MAGENTA POUR TOUTES SES IMAGES, ET JAMAIS DE ROSE NI DE VIOLET SUR LUI.** Ses planches d'origine sont
passées par le magenta (`demagenta`) : son gris-bleu, son or et son orange y sont loin du fond. Son métal chauffé est
un **orange franc**, jamais rouge rosé ; ses ombres sont **gris-bleu**, jamais violettes. Vérifier la première image
avant de commander les autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Forgeron | ci-dessous, image 1 | `refonte/acier_eveil.png` | `refonte/acier.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/acier_eveil_marche.png` | `refonte/acier_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/acier_eveil_attaque.png` | `refonte/acier_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_acier_eveil_skills.png` | aucune |
| 5 | Le portrait de la sélection | [menu/portrait_acier_eveil](../menu/portrait_acier_eveil.md) | `interface/portraits/portrait_acier_eveil.png` | `interface/portraits/portrait_acier.png` et `mages/acier_eveil_marche.png` |

Le portrait se commande en dernier : il a besoin de la planche de marche. Aucune image pour les effets des sorts.
**L'enclume géante, les éclats de plaque, les lames en fusion, le métal en fusion au sol et les ondes sont faits par
le JEU** : ils ne sont jamais dessinés sur ses planches.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## Le Forgeron Céleste

### Ce qu'il devient

On reconnaît l'Archange d'Acier : un ange guerrier **massif et costaud**, très large d'épaules, en **armure de
plates intégrale gris-bleu** aux grandes plaques épaisses, au **heaume fermé** dont la fente laisse sortir une lueur
orange, aux deux **ailes de lames d'acier** à demi repliées, et au grand **marteau de guerre** dans la main droite.
Mais il est devenu la forge du ciel :

- Les fines fentes orange entre ses plaques **flamboient** : un orange vif de métal en fusion, à cœur jaune, net et
  dessiné, sur le plastron, les épaulières et les gantelets.
- Une **couronne d'enclume** dorée est posée sur son heaume : un bandeau d'or massif, surmonté d'une petite enclume
  d'or au front et de pointes courtes comme des clous de forge.
- Le **tranchant** de chaque lame de ses ailes rougeoie d'orange, comme sorti du feu.
- Son marteau est devenu un énorme **marteau-forge** : une tête d'acier plus massive, cerclée de deux bandes d'or, au
  **cœur incandescent** orange visible par une fente de chaque côté.
- La lueur de la fente de son heaume est plus vive.

Il reste chibi, à la même échelle que l'Archange d'Acier.

### Son trait éveillé : la Forge vivante

**Il encaisse plus, et ce qu'il encaisse se retourne contre qui le frappe.** Tant que dure l'Éveil :
- il porte **5 plaques** au lieu de 3, et ses plaques sont pleines à l'éveil ;
- **chaque kill** reforge une plaque, au lieu d'un kill sur deux ;
- une plaque qui casse **explose en éclats** autour de lui : ce qui est à côté de lui est blessé.

À la fin de l'Éveil, il garde au plus ses 3 plaques ordinaires.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Coup de marteau | **Marteau du ciel** | l'onde de choc court jusqu'à la cible et touche plus large ; un coup sur trois étourdit ce qu'il touche | 26 dégâts, rayon 2, 6 cases, recharge 0,65 s ; étourdit 0,8 s un coup sur 3 |
| SKILL 1 | Ailes-lames | **Tempête de lames** | 8 lames partent sur TOUT le tour de lui, par-dessus les haies, puis reviennent et retouchent au retour | 8 lames, 32 dégâts, 5 cases, recharge 7 s |
| SKILL 2 | Onde d'enclume | **Enclume céleste** | une enclume géante tombe du ciel sur l'ennemi le plus proche : gros dégâts et long étourdissement sur la zone, puis l'onde d'enclume part dans les couloirs depuis l'impact | impact 80 dégâts, rayon 2,5, étourdit 2 s ; onde 34 dégâts sur 7 cases, étourdit 1,5 s ; recharge 10 s |
| SKILL 3 | Rempart | **Bastion de la forge** | il se referme dans ses ailes, immobile et intouchable, et renvoie les coups ; à la fin, ses ailes s'ouvrent dans une gerbe de lames en fusion et il récupère une plaque | 4 s, renvoie 40, gerbe 45 dégâts rayon 3, +1 plaque, recharge 18 s |
| FUITE | Charge | **Charge du bélier** | il fonce plus loin ; ce qu'il renverse est aussi étourdi, et il laisse une traînée de métal en fusion qui brûle | 6 cases, 40 dégâts, renverse 2 cases, étourdit 1 s ; traînée 3 s à 10 dégâts/s (une case en feu) ; recharge 8 s |
| EXTRA | Acier en fusion | **Cœur de la forge** | la forge explose autour de lui ; il redevient géant en fusion, plaques toutes pleines, et ses pas laissent du métal en fusion au sol | 120 dégâts, rayon 5 ; fusion 12 s ; chaque pas brûle 2 s à 10 dégâts/s |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

Le cœur de son jeu reste **le contact** : aller au milieu des ennemis, encaisser sur ses plaques, et les reforger en
tuant. L'Éveil le rend plus dur à percer et punit ceux qui s'acharnent sur lui.

---

## Image 1 — le modèle du Forgeron

Joindre `assets/peso&cover/refonte/acier.png` (l'Archange d'Acier, qu'il faut garder reconnaissable).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre l'Archange d'Acier : c'est LE MÊME personnage, que tu dois
transformer, pas remplacer. Ne reprends PAS la mise en page de l'image jointe.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le heaume, la couronne d'enclume, le plastron flamboyant et le marteau se voient bien
2. vue DE DOS, immobile : les deux ailes de lames aux tranchants orange se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : le marteau posé sur l'épaule, une aile derrière son dos

LE PERSONNAGE — l'Archange d'Acier ÉVEILLÉ en FORGERON CÉLESTE. On le reconnaît tout de suite :
même ange guerrier au corps CHIBI, MASSIF et COSTAUD, très large d'épaules, même ARMURE DE PLATES
INTÉGRALE GRIS-BLEU (#a9b6c6, ombres #5d6b7d) aux grandes plaques épaisses, mêmes énormes
épaulières, même plastron bombé, mêmes gantelets et grosses bottes de métal, même HEAUME FERMÉ
sans visage, mêmes deux AILES faites de LAMES D'ACIER superposées, sans aucune plume, À DEMI
REPLIÉES, même grand marteau de guerre dans la main DROITE. Ce qui change :
- les fentes entre ses plaques FLAMBOIENT : un ORANGE VIF de métal en fusion (#ff8a2a, cœur
  #ffd36a), net et dessiné, sur le plastron, les épaulières et les gantelets ;
- une COURONNE D'ENCLUME en OR (#e8b84a) est POSÉE sur son heaume : un bandeau d'or massif, une
  petite enclume d'or au front, et des pointes courtes comme des clous de forge ;
- le TRANCHANT de chaque lame de ses ailes rougeoie d'ORANGE, comme sorti du feu ; le reste de la
  lame reste gris-bleu ;
- son marteau est un énorme MARTEAU-FORGE : tête d'acier plus massive, cerclée de deux bandes d'OR,
  avec un CŒUR INCANDESCENT orange visible par une fente de chaque côté ;
- la lueur orange de la fente de son heaume est plus vive.
Toutes ses formes sont cernées d'un contour très foncé (#14181f), net.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA SUR LUI, ni dans les reflets, ni dans
les ombres, ni dans le métal chauffé : le fond serait retiré avec. Ses ombres sont GRIS-BLEU, son
métal chauffé est ORANGE FRANC et JAUNE, jamais rouge rosé.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES, jamais déployées. Elles ne dépassent pas
de plus d'un quart de la largeur du corps de chaque côté, et leurs pointes s'arrêtent au niveau
des genoux. Il devra marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — LA COURONNE EST POSÉE SUR LE HEAUME, jamais détachée et flottante.

⚠️ RÈGLE BLOQUANTE — LE HEAUME RESTE FERMÉ : aucun visage, seulement la fente lumineuse.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'ARCHANGE D'ACIER : UN CORPS CHIBI DE 2,5 TÊTES,
À LA MÊME TAILLE. Posé à côté de l'image jointe, il fait la même hauteur et la même largeur. Le
marteau ne dépasse pas sa tête de plus d'une demi-tête.

⚠️ RÈGLE BLOQUANTE — AUCUNE FLAMME, AUCUNE ÉTINCELLE, AUCUNE FUMÉE, AUCUNE LUEUR FLOUE autour de
lui. Le métal en fusion est DESSINÉ dans les fentes de l'armure, net et plein. Le jeu ajoute le
reste.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
ailes, même couronne, même marteau, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Du rose ou du violet dans les ombres ou le métal chauffé | Le détourage du magenta y ferait des trous |
| Des flammes ou des étincelles autour de lui | Le jeu les dessine : elles seraient en double, et sa boîte enflerait |
| La couronne flotte au-dessus du heaume | Le découpage la jetterait comme une poussière |
| Un visage dans le heaume | Ce n'est plus l'Archange d'Acier |
| Des ailes déployées | Il ne tiendrait plus dans un couloir |
| L'or ou l'orange dominent le gris-bleu | Il ressemblerait au Roi de Braise |
| Il est plus grand que l'Archange d'Acier | Il ne doit pas changer de taille en s'éveillant |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/acier_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son heaume, sa couronne, son armure,
ses ailes, son marteau, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Archange d'Acier éveillé en FORGERON CÉLESTE, en proportions CHIBI, massif et
large d'épaules : armure de plates intégrale gris-bleu dont les fentes FLAMBOIENT d'orange vif,
heaume fermé à la fente lumineuse, COURONNE D'ENCLUME d'or posée sur le heaume, deux ailes de lames
d'acier À DEMI REPLIÉES aux tranchants orange, MARTEAU-FORGE cerclé d'or au cœur incandescent dans
la main DROITE. Contour très foncé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
couronne comprise, est la même dans les 24 cases.

Il MARCHE d'un pas lourd et puissant, comme une forteresse qui avance. IL NE COURT PAS : le buste
reste DROIT, la tête haute, sans bouger d'une image à l'autre. Ses pas sont de la MÊME LONGUEUR que
sur le guide. Seule la pointe des ailes bouge un peu.

LE MARTEAU reste dans sa main DROITE, posé sur l'épaule ou tenu droit, dans les 24 cases : il
monte et descend un peu avec le pas, sans jamais basculer. SON BRAS GAUCHE BALANCE FRANCHEMENT, EN
OPPOSITION AUX JAMBES : quand la jambe droite part vers l'avant, le bras gauche part vers l'avant
lui aussi, puis il repart vers l'arrière. Le coude plie, le gantelet suit avec un léger temps de
retard. Il ne reste JAMAIS figé le long du corps.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, AVEC SON
MARTEAU. Le VERT de la robe du guide ne doit pas passer sur lui.

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

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES dans les 24 cases, jamais déployées.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LE BRAS GAUCHE ET LA POINTE DES AILES BOUGENT. Dans une même
rangée, la tête, la couronne et le tronc se superposent exactement d'une case à l'autre, et le
profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE NI VIOLET SUR LUI, aucune flamme, aucune étincelle, aucune lueur floue.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule détachée.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/acier_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT son heaume, sa couronne, son armure, ses ailes, son marteau, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Archange d'Acier éveillé en FORGERON CÉLESTE, en proportions CHIBI, massif :
armure gris-bleu aux fentes orange flamboyantes, heaume fermé, couronne d'enclume d'or, ailes de
lames à demi repliées aux tranchants orange, MARTEAU-FORGE cerclé d'or dans la main DROITE.
Contour très foncé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il abat
son marteau sur le sol devant lui.
1. posture prête, marteau sur l'épaule
2. il lève le marteau à deux mains au-dessus de sa tête, le cœur du marteau s'allume
3. le marteau commence à descendre devant lui
4. LE COUP : la tête du marteau touche le sol DEVANT lui, dans la direction de la rangée, bras
   tendus, et un petit ÉCLAT ORANGE, plus petit que sa tête, brille au point d'impact
5. l'éclat a disparu, le marteau est encore au sol
6. il relève le marteau
7. le marteau remonte vers l'épaule
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE COUP PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit éclat orange de
l'image 4, collé à la tête du marteau. Pas d'onde de choc, pas de fissure, pas d'étincelles : le
JEU les dessine.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES pendant tout le geste.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE NI VIOLET SUR LUI, ni en reflet du fond.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune aura, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc, la tête et la couronne
se superposent exactement dans les 8 images d'une rangée (seuls les bras, le marteau et les
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

PERSONNAGE : l'Archange d'Acier éveillé en FORGERON CÉLESTE, la forge du ciel. Ses couleurs sont
l'ACIER GRIS-BLEU (#a9b6c6, ombre #5d6b7d), l'OR (#e8b84a), l'ORANGE du métal en fusion (#ff8a2a,
cœur #ffd36a) et le blanc chaud des étincelles (#fff4dc), avec un CONTOUR TRÈS FONCÉ (#14181f) net
autour de chaque forme. Le motif commun des six icônes est le MÉTAL EN FUSION : une fente ou un
cœur orange vif dans de l'acier gris-bleu. Il doit se retrouver dans chacune.

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

1. MARTEAU DU CIEL — un marteau-forge cerclé d'or qui frappe le sol, et une onde de choc orange en
   anneau sous lui, avec une petite étoile d'étourdissement.

2. TEMPÊTE DE LAMES — huit lames d'acier aux tranchants orange disposées en cercle complet, comme
   une roue, qui tournent autour d'un centre vide.

3. ENCLUME CÉLESTE — une énorme enclume d'acier cerclée d'or qui tombe du ciel, avec des traînées
   de chute, au-dessus d'un sol qui se fend d'orange.

4. BASTION DE LA FORGE — deux ailes de lames refermées en bouclier, aux tranchants orange, et une
   gerbe de lames en fusion qui jaillit de leur sommet.

5. CHARGE DU BÉLIER — une épaulière d'acier massive qui fonce de côté, avec des lignes de vitesse et
   une traînée de métal en fusion orange derrière elle.

6. CŒUR DE LA FORGE — un cœur de métal en fusion orange et jaune, enfermé dans une cage d'acier
   gris-bleu cerclée d'or, qui éclate en rayons et en étincelles. C'est l'icône la plus
   spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune fumée floue, aucune lueur floue, aucune case vide, AUCUN ROSE
NI VIOLET dans les icônes : ils se confondraient avec le fond magenta. Le métal chauffé est ORANGE
et JAUNE, jamais rouge rosé ; les ombres de l'acier sont GRIS-BLEU, jamais violettes. Ce sont des
SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Ils seront peints au shader, comme ceux des autres Éveils. Mêmes règles : trois temps (départ, coup, trace qui
s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette du Forgeron

| rôle | couleur | usage |
|---|---|---|
| L'acier | `#a9b6c6` / `#5d6b7d` | lames, enclume, éclats de plaque |
| L'or | `#e8b84a` | couronne, cercles de l'enclume, anneaux |
| Le métal en fusion | `#ff8a2a` | fentes, traînées, ondes |
| Le cœur de forge | `#ffd36a` | instant de l'impact |
| L'étincelle | `#fff4dc` | gerbes, éclats |

Le motif commun est **la fente de métal en fusion dans l'acier** et **la gerbe d'étincelles**. Jamais de rose, de
violet ni de vert.

### L'Éveil lui-même

- **La charge, 0,8 s :** des étincelles montent du sol autour de lui, et les fentes de son armure s'allument une à une.
- **L'éclosion :** un coup de marteau sur une enclume invisible, une colonne d'étincelles, et un anneau de métal en
  fusion qui court au sol ; la caméra tremble fort.
- **Pendant la minute :** une lueur de forge bat sous ses pieds, et quelques étincelles s'échappent de son armure.
- **La fin :** les fentes s'éteignent l'une après l'autre dans un nuage de vapeur grise.

### Les six sorts

- **Marteau du ciel :** l'onde de choc court au sol en anneau orange ; le coup qui étourdit fait jaillir une gerbe.
- **Tempête de lames :** huit lames tournent en roue autour de lui en filant, tranchant orange, puis reviennent.
- **Enclume céleste :** un cercle doré s'annonce au sol, l'enclume tombe du ciel avec une traînée, frappe, le sol se
  fend d'orange, les étincelles jaillissent, puis l'onde part dans les couloirs.
- **Bastion de la forge :** ses ailes se referment en dôme de lames ; à la fin, elles s'ouvrent dans une gerbe de
  lames en fusion qui part en couronne.
- **Charge du bélier :** il fonce dans un sillage de métal en fusion qui reste au sol et bouillonne ; ce qu'il
  renverse voit des étoiles.
- **Éclats de plaque (le trait) :** une plaque qui casse éclate en morceaux d'acier aux bords orange qui partent tout
  autour de lui.
- **Cœur de la forge :** la forge explose autour de lui en un grand anneau de métal en fusion et une colonne
  d'étincelles ; pendant la fusion, chaque pas laisse une flaque orange qui refroidit en gris.
