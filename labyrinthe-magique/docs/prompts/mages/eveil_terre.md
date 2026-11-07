# L'Éveil du Mage de la Terre — le Colosse

> Le troisième ÉVEIL des mages. Le Mage de la Terre, le plus lent et le plus solide du jeu, se couvre de
> roche et de cristal et devient **le Colosse** pendant une minute : il grandit, il marche à travers les
> ennemis, et ses six sorts changent. Le Phénix renaît, le Seigneur des Marées encaisse ; lui écrase.

**Jouable depuis le 2026-11-07** (`CharacterCatalog.earth_awakened`). Les quatre images ci-dessous ont été
commandées dans cet ordre, la première servant de modèle aux trois autres ; elles sont découpées dans
`assets/characters/earth_eveil` et `assets/icons/earth_eveil`.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Colosse | ci-dessous, image 1 | `refonte/terre_eveil.png` | `refonte/terre.png` et `refonte/chrono.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/terre_eveil_marche.png` | `refonte/terre_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/terre_eveil_attaque.png` | `refonte/terre_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_terre_eveil_skills.png` | aucune |

Aucun portrait à commander : la carte de l'écran de sélection reste celle du Mage de la Terre. Aucune image
pour les effets des sorts : ils seront peints au shader.

Les règles de l'Éveil sont celles du Phénix et du Seigneur des Marées : **1 min**, **10 s d'épuisement**,
**6 kills** de charge, le bouton à droite de la barre du mage ou la touche **T**, et libre en démo.

---

## Le Colosse

### Ce qu'il devient

On reconnaît le Mage de la Terre : sa barbe grise, son visage sévère, sa robe vert sombre, sa ceinture et son
bâton noueux. Mais la roche le recouvre. Ses **épaulières de pierre** deviennent de gros blocs de roche,
d'où sortent des **cristaux verts**. Des **plaques de roche** lui couvrent les avant-bras, le torse et les
jambes, séparées par de fines **fissures de lave orange** qui luisent. Ses **yeux** brillent d'un vert vif. La
pierre au sommet de son bâton est devenue un **gros cristal vert** taillé. Quelques éclats de cristal sortent
de sa barbe.

Il reste chibi sur l'image, à la même échelle que le Mage de la Terre : c'est le **jeu** qui le fait grandir
d'un tiers à l'Éveil, comme il fait grandir l'Avide. Une image déjà plus grande le ferait grandir deux fois.

### Son trait éveillé : Piétinement

Il **marche à travers les ennemis**. Ce qu'il touche est **repoussé de 2 cases** et prend **15 dégâts**, une
fois par seconde au plus pour un même ennemi. Il grandit d'un tiers et garde son allure. Les boss ne sont pas
repoussés, ils prennent seulement les dégâts.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Rocher | **Météorite** | un rocher géant roule dans le couloir et écrase tout ce qu'il croise | 26 dégâts, 7 cases, 0,7 s |
| SKILL 1 | Pics de terre | **Faille** | le sol se fend en croix, dans les quatre directions, hérissé de pics qui restent plantés | 40 dégâts, 5 cases par branche, pics 3 s à 8/s, recharge 6 s |
| SKILL 2 | Égide de pierre | **Bastion** | intouchable, et des pics de roche jaillissent sur qui le frappe | 3 s, renvoie 30 par coup, recharge 14 s |
| SKILL 3 | Éclats de cristal | **Tour de cristal** | une tour magique de cristal sort du sol, et tire sur trois ennemis à la fois | 14 dégâts par éclat, toutes les secondes, 12 s, recharge 10 s |
| FUITE | Terrier | **Éruption** | il plonge sous terre et ressort plus loin, en projetant tout autour | 6 cases, 35 dégâts, rayon 2, projette de 2 cases, recharge 8 s |
| EXTRA | Séisme | **Cataclysme** | le sol craque sur toute la carte, et des colonnes de lave jaillissent des failles | le Séisme de base, plus 16 colonnes de lave à 50 dégâts |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

---

## Image 1 — le modèle du Colosse

Joindre `assets/peso&cover/refonte/terre.png` en PREMIER (le Mage de la Terre, qu'il faut garder
reconnaissable), puis `assets/peso&cover/refonte/chrono.png` (les proportions et la mise en page).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
La PREMIÈRE image jointe montre le Mage de la Terre : c'est LE MÊME personnage, que tu dois
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
1. vue DE FACE, immobile : son visage et sa barbe se voient bien
2. vue DE DOS, immobile : les blocs de roche des épaules et les cristaux se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile

LE PERSONNAGE — le Mage de la Terre ÉVEILLÉ en COLOSSE. On le reconnaît tout de suite : même
vieux mage trapu, même BARBE GRISE, même visage sévère, même robe VERT SOMBRE (#2f4a1c) à
liserés d'or, même ceinture de cuir, même BÂTON NOUEUX dans la main droite. Ce qui change :
- ses ÉPAULIÈRES de pierre sont devenues de GROS BLOCS DE ROCHE brune (#6b5638), d'où sortent
  deux ou trois CRISTAUX VERTS (#6fe03a) taillés, pointés vers le haut ;
- des PLAQUES DE ROCHE lui couvrent les avant-bras, le torse et le devant des jambes, séparées
  par de fines FISSURES DE LAVE ORANGE (#ff8a1e) qui luisent ;
- ses YEUX brillent d'un VERT VIF (#9dff5c) ;
- la pierre au sommet de son bâton est devenue un GROS CRISTAL VERT taillé, à facettes nettes ;
- quelques petits éclats de cristal vert sortent de sa barbe.
Toutes ses formes sont cernées d'un contour brun-noir très sombre (#1e1408), net, qui les
détache des sols clairs.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DU MAGE DE LA TERRE : UN CORPS CHIBI, LARGE ET
TRAPU, À LA MÊME TAILLE. Posé à côté de la première image jointe, il fait la même hauteur : les
cristaux des épaules ne le grandissent pas de plus d'un quart de tête. C'est le JEU qui le fera
grandir. Grosses mains, gros pieds, torse court, jambes courtes.

⚠️ RÈGLE BLOQUANTE — IL RESTE DANS SA LARGEUR. Les blocs des épaules ne dépassent pas de plus d'un
quart de la largeur du corps de chaque côté. Le personnage devra marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — LA LAVE EST UN TRAIT FIN ET NET dans les fissures, en aplats opaques : aucune
lueur floue, aucun halo, aucune fumée, aucune braise détachée, aucune particule.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT. Les deux jambes et les deux bottes se voient
clairement, séparées l'une de l'autre : la robe ne descend pas plus bas qu'avant.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni dans les ombres, ni en
reflet du fond. La roche s'ombre de brun, le cristal de vert sombre.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
blocs, mêmes cristaux, même bâton, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| On ne reconnaît plus le Mage de la Terre (barbe, robe, bâton) | L'Éveil doit transformer le mage, pas le remplacer |
| Il est déjà plus grand que le Mage de la Terre | Le jeu le grandit lui-même : il grandirait deux fois |
| Les blocs des épaules sont très larges | Il passerait sur les murs |
| La lave luit en halo flou | Une frange resterait au détourage |
| Du violet ou du rose dans les ombres de la roche | Le détourage y ferait des trous |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/terre_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT sa roche, ses cristaux, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage de la Terre éveillé en COLOSSE, en proportions CHIBI, large et trapu :
barbe grise, yeux vert vif, robe vert sombre à liserés d'or, GROS BLOCS DE ROCHE aux épaules
d'où sortent des CRISTAUX VERTS, plaques de roche sur les bras, le torse et les jambes,
séparées de fines FISSURES DE LAVE ORANGE, BÂTON NOUEUX surmonté d'un GROS CRISTAL VERT dans la
main droite, tenu droit. Contour brun-noir net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale
est la même dans les 24 cases.

Il MARCHE d'un pas LOURD et décidé, comme un colosse. IL NE COURT PAS : le buste reste DROIT, et
les genoux restent bas. Ses pas sont posés, mais de la MÊME LONGUEUR que sur le guide.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps.
- LE BRAS LIBRE (le gauche, poing de roche fermé) balance en grand, de l'avant vers l'arrière ;
- LE BRAS DU BÂTON (le droit) balance AUSSI, moins loin : la main avance et recule en emportant
  le bâton, qui reste VERTICAL, cristal en l'air, sans jamais se coucher ni passer devant le visage.

LE BALANCEMENT DES BRAS, image par image, calé sur les jambes du guide :
1. bras libre tendu vers l'AVANT, poing à hauteur de taille ; main du bâton vers l'ARRIÈRE
2. bras libre qui redescend, coude un peu plié ; main du bâton qui revient
3. les deux bras le long du corps, POINT DE PASSAGE (c'est l'image aux jambes jointes)
4. bras libre qui part vers l'arrière ; main du bâton qui part vers l'avant
5. l'INVERSE de l'image 1 : bras libre vers l'ARRIÈRE, main du bâton vers l'AVANT
6. main du bâton qui revient ; bras libre qui revient
7. les deux bras le long du corps, POINT DE PASSAGE (jambes jointes)
8. bras libre qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui avance
grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté du corps.
DE PROFIL, le bâton reste devant le corps, et la main qui le tient avance et recule le long de lui.

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
Deux images voisines identiques pour les bras sont une erreur. Le bâton bouge AVEC sa main,
toujours droit.

⚠️ RÈGLE BLOQUANTE — LA ROBE NE CACHE JAMAIS LES JAMBES : les deux bottes se voient dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS ET LE BÂTON BOUGENT. Dans une même rangée, la tête,
les blocs des épaules et le tronc se superposent exactement d'une case à l'autre, et le profil
regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES BLOCS ET LE BÂTON TIENNENT DANS LA CASE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — LA LAVE RESTE UN TRAIT FIN ET NET, SANS HALO ; AUCUN ROSE, AUCUN VIOLET.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune poussière, aucun reflet du fond magenta.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/terre_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT sa roche, ses cristaux, ses couleurs et ses proportions, mais PAS
sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Mage de la Terre éveillé en COLOSSE, en proportions CHIBI, large et trapu :
barbe grise, yeux vert vif, robe vert sombre, gros blocs de roche aux épaules avec des cristaux
verts, plaques de roche à fissures de lave orange, bâton noueux à gros cristal vert dans la main
droite. Contour brun-noir net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il
FRAPPE LE SOL du pied de son bâton, comme un colosse qui fait trembler la terre.
1. posture prête, le bâton droit dans la main droite
2. il soulève le bâton à deux mains, le cristal vers le ciel
3. le bâton est au plus haut, le corps ramassé, les genoux pliés
4. L'IMPACT : il abat le pied du bâton au sol, DEVANT lui dans la direction de la rangée, et un
   petit éclat de roche et de cristal vert jaillit au point d'impact, plus petit que sa tête
5. l'éclat a disparu, le bâton reste planté au sol
6. il relève le bâton
7. le bâton revient droit contre le corps
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée 1
ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais l'ensemble corps et
bâton.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit éclat de l'image 4.
Le JEU dessine lui-même les rochers et les failles.

⚠️ RÈGLE BLOQUANTE — LE BÂTON RESTE ENTIER DANS LA CASE, même levé à l'image 3.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta ; la lave reste
un trait fin et net.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune poussière.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc et la tête se superposent
exactement dans les 8 images d'une rangée (seuls les bras, le bâton et les genoux bougent).

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

PERSONNAGE : le Mage de la Terre éveillé en COLOSSE. Ses couleurs sont la ROCHE BRUNE (#6b5638),
le CRISTAL VERT (#6fe03a), le VERT VIF (#9dff5c), la LAVE ORANGE (#ff8a1e) et l'OR (#e0b040), avec
un CONTOUR BRUN-NOIR (#1e1408) net autour de chaque forme. Le motif commun des six icônes est la
FISSURE DE LAVE : elle doit se retrouver dans chacune.

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

1. MÉTÉORITE — un gros rocher rond, fendu de lave orange, qui roule vers la droite, avec trois
   traits de vitesse derrière lui et des éclats de roche sous lui.

2. FAILLE — une croix de crevasses vue en légère plongée, fendue de lave orange, avec des pics de
   roche dressés le long des quatre branches.

3. BASTION — un bouclier de roche massif, bombé, fendu de lave, avec des pics de roche qui
   jaillissent tout autour de lui.

4. GÉODE — un gros cristal vert planté dans une roche ouverte, qui lance trois éclats de cristal
   dans trois directions.

5. ÉRUPTION — un jet de roche et de lave qui jaillit du sol fendu, avec des rochers projetés de
   chaque côté.

6. CATACLYSME — la terre qui se fend en étoile, et trois colonnes de lave qui jaillissent des
   failles, entourées de rochers qui volent. C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor en dehors de la roche des icônes, pas d'ombre
portée, pas de cadre, pas de texte, pas de flou, aucune lueur floue autour de la lave, aucune case
vide, AUCUN ROSE et AUCUN VIOLET, ni dans les ombres ni dans les reflets : ils se confondraient avec
le fond magenta. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.

---

## Les effets visuels, sort par sort

Les shaders `colosse_*` (`tools/preview_colosse.gd` les montre). Mêmes règles que les autres :
trois temps (départ, coup, trace qui s'éteint), une taille qui suit le rang, un dessin par sort.

### La palette du Colosse

| rôle | couleur | usage |
|---|---|---|
| La roche | `#6b5638` | matière des rochers, des pics, des failles |
| Le cristal | `#6fe03a` | éclats, tour de cristal, yeux |
| Le vert vif | `#9dff5c` | cœur des cristaux, instant de l'impact |
| La lave | `#ff8a1e` | fissures, colonnes, ce qui brûle |
| Le cerne | `#1e1408` | contour qui tient sur les sols clairs |

Le motif commun est la **fissure de lave** : elle se retrouve dans chaque effet, comme la plume chez le
Phénix et la vague chez le Seigneur des Marées.

### L'Éveil lui-même

- **La charge, 0,8 s :** le sol se fend en étoile sous ses pieds, et des éclats de roche montent vers lui.
- **L'éclosion :** les roches se plaquent sur lui dans un grand choc, il grandit d'un coup, une onde de
  poussière et de fissures part au sol, et la caméra tremble fort.
- **Pendant la minute :** chaque pas fait une petite fissure qui s'efface, et quelques cristaux brillent
  sur ses épaules.
- **La fin :** les roches tombent de lui en éboulis, et il redevient le Mage de la Terre.

### Le Piétinement

Un ennemi touché est projeté dans une gerbe de terre et de cailloux, avec une petite fissure au sol.

### Les six sorts

- **Météorite :** un rocher fendu de lave roule le long du couloir en tournant, et laisse une traînée de
  fissures. Chaque ennemi écrasé lâche une gerbe de cailloux.
- **Faille :** quatre crevasses partent de lui en croix, de case en case, et des pics de roche jaillissent
  le long, puis restent plantés et rougeoient avant de s'effondrer.
- **Bastion :** une carapace de roche se referme autour de lui ; chaque coup reçu fait jaillir un pic de
  roche vers l'attaquant.
- **Tour de cristal** (la Géode jusqu'au 2026-11-07, changée à la demande du joueur) : une tour de blocs de
  cristal cerclée d'or sort du sol sur un socle de roche, une fenêtre luit, et le grand cristal du sommet
  flotte entre trois éclats en orbite. Chaque tir part du sommet, qui s'illumine. Avant :
  une roche s'ouvrait au sol et un grand cristal en sortait, qui tournait lentement et lançait des
  éclats verts, trois à la fois.
- **Éruption :** il s'enfonce dans le sol dans un nuage de terre, puis ressort plus loin dans un jet de
  roche et de lave qui projette tout autour.
- **Cataclysme :** le sol craque sur tout l'écran en un réseau de fissures de lave, puis des colonnes de
  lave jaillissent une à une des failles.
