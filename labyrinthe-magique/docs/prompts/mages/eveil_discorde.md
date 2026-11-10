# L'Éveil de la Démone de la Discorde — la Reine de la Discorde

> Le deuxième ÉVEIL des démons. La Démone de la Discorde est une noble marionnettiste qui retourne les ennemis
> les uns contre les autres. Éveillée, elle devient **la Reine de la Discorde** pendant une minute : son troisième
> œil s'ouvre, une croix de marionnettiste d'argent se dresse dans son dos, et ses fils tiennent désormais toute
> la salle. **La discorde se propage** : quand un pantin meurt, ses fils sautent sur un voisin.

✅ **Programmé et jouable depuis le 2026-11-09** : `--demo --character discorde`, puis le bouton à droite de la
barre du héros ou la touche **T**. Les quatre images sont intégrées. Les chiffres ne sont pas mesurés : les bots
ne s'éveillent pas. Deux ajouts au jeu prévu : la marionnette du Ballet éclate en fils au bout de ses 3 s
(24 dégâts, rayon 1,5), et le Grand Bal remplace le grand œil de la Grande Discorde par sa croix dans le ciel.

Les quatre images ci-dessous se commandaient dans cet ordre, la première servant de modèle aux trois suivantes.

**Fond MAGENTA**, comme sa forme de base. ⚠️ **AUCUN ROSE, AUCUN VIOLET SUR ELLE**, alors que son élément est
magenta : le détourage retire cette couleur, et le rose deviendrait un rouge terne, la prune un gris sale. Elle
reste vert sapin, noir et argent ; sa nouvelle lueur est un **VERT ÉMERAUDE** vif, à l'opposé du fond. Le magenta
n'existe que dans ses effets, peints au shader par le jeu.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle de la Reine | ci-dessous, image 1 | `refonte/discorde_eveil.png` | `refonte/discorde.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/discorde_eveil_marche.png` | `refonte/discorde_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/discorde_eveil_attaque.png` | `refonte/discorde_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_discorde_eveil_skills.png` | aucune |

Aucun portrait à commander : la carte de l'écran de sélection reste celle de la Démone de la Discorde. Aucune
image pour les effets des sorts : ils seront peints au shader, dans sa palette d'effets (magenta `#e8308f`,
argent `#c9d2d6`, émeraude `#2fe0a0`, noir).

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du héros ou la touche **T**, et libre en démo.

---

## La Reine de la Discorde

### Ce qu'elle devient

On la reconnaît tout de suite : même visage, mêmes yeux verts, même long **manteau vert sapin** à col montant et
broderies d'**argent**, même ceinture noire à boucle d'argent, mêmes gants et bottes noirs. Mais la reine des
pantins se révèle, et c'est spectaculaire :

- Son **chignon s'est défait** : ses longs cheveux noirs flottent derrière elle comme dans un courant, et leurs
  pointes se changent en **fils d'argent** qui ondulent.
- Une **couronne d'argent** à fines pointes, comme des aiguilles, ceint sa tête ; au milieu, un **œil
  d'émeraude** serti.
- Sur son front, un **TROISIÈME ŒIL** s'est ouvert, vertical, d'un **vert émeraude** lumineux : le Mauvais Œil.
  Ses deux yeux à elle brillent du même émeraude.
- Deux **fines cornes noires** effilées, à pointe d'argent, sortent de ses cheveux et remontent vers l'arrière.
- Dans son dos se dresse une **CROIX DE MARIONNETTISTE** d'argent, grande comme son buste : deux barres croisées
  ouvragées, au-dessus de sa tête, d'où pendent des **fils d'argent** qui descendent jusqu'à ses mains.
- Ses **gants** noirs se terminent en **griffes d'argent**, et un **anneau d'argent** à chaque doigt retient un
  fil qui file vers la croix.
- Le bas de son manteau s'est **allongé en traîne fendue** en quatre pans pointus, brodés d'**yeux d'argent**.
  Des **épaulettes d'argent** en forme de mains ouvertes tiennent ses épaules.

Elle reste chibi, de la même taille que la Démone : l'Éveil ne la fait pas grandir d'un coup sur l'écran.
Le jeu ajoute autour d'elle les fils magenta qui relient ses pantins, et un œil qui s'ouvre au-dessus d'eux.

### Son trait éveillé : la Discorde contagieuse

**Ses pantins se transmettent leurs fils.** Tant que dure l'Éveil :
- **chacun de ses coups trouble** sa cible, au lieu d'un sur trois : plus lente, et possédée plus longtemps ;
- quand un ennemi **possédé meurt**, ses fils sautent sur l'ennemi le plus proche de lui (à 3 cases au plus), qui
  est possédé à son tour pour le temps qui restait, et au moins 2 s.

C'est son jeu poussé au bout : une seule possession bien placée peut tourner toute une foule contre elle-même.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillée | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Murmure | **Fil d'argent** | un fil qui vise, puis rebondit vers un deuxième ennemi | 16 dégâts, 1 rebond, portée 7, 0,5 s |
| SKILL 1 | Mauvais Œil | **Œil de la Reine** | le troisième œil s'ouvre au-dessus de l'ennemi visé : lui ET ses deux plus proches voisins sont possédés | portée 8, 6 s, 22 par coup, recharge 11 s |
| SKILL 2 | Cercle de Discorde | **Arène de Discorde** | un cercle plus grand qui ATTIRE les ennemis vers son centre ; plus ils y sont nombreux, plus chacun souffre | 18 dégâts/s, +75 % par ennemi en plus, rayon 3, 7 s, recharge 13 s |
| SKILL 3 | Lien de Souffrance | **Toile de Souffrance** | une toile relie cinq ennemis : une grande part des coups portés à l'un passe aux autres | portée 8, 5 ennemis, 60 %, 10 s, recharge 14 s |
| FUITE | Échange | **Ballet des pantins** | elle échange sa place avec l'ennemi le plus proche et laisse à sa place une marionnette d'elle-même, que les ennemis attaquent | portée 6, leurre 3 s, recharge 9 s |
| EXTRA | Grande Discorde | **Le Grand Bal** | tous les ennemis à l'écran dansent et se battent entre eux ; chaque mort pendant le bal fait éclater des fils qui blessent ses voisins | 8 s, 26 par coup, éclat de 30 en rayon 1,5 |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

**Les boss** ne sont toujours ni possédés ni échangés. L'Arène, la Toile et les éclats du Bal les touchent.

### Ce qu'on doit voir à l'écran (peint au shader)

Dans sa palette d'effets : le magenta de son élément, l'argent de ses fils, l'émeraude de son œil. Net, à plages
franches ; un effet se réduit au lieu de s'estomper ; ce qui est grand passe sous elle ou reste creux au centre.

| moment | effet |
|---|---|
| **Le geste d'Éveil** (0,8 s) | des fils d'argent tombent du ciel et s'accrochent à ses doigts, puis le troisième œil s'ouvre en grand au-dessus d'elle dans un éclair émeraude |
| **Pendant l'Éveil** | la croix de marionnettiste brille ; un léger cercle de fils tourne à ses pieds ; chaque ennemi possédé porte un petit œil émeraude au-dessus de la tête, relié à elle par un fil magenta |
| **La contagion** | quand un pantin meurt, un fil magenta file de lui jusqu'à son voisin, et l'œil saute avec |
| **Fil d'argent** | un fil d'argent à cœur magenta qui file, frappe, puis repart en angle vers le second ennemi |
| **Œil de la Reine** | un grand œil émeraude s'ouvre au-dessus de la cible, et trois fils en tombent sur elle et ses voisins |
| **Arène de Discorde** | une arène ronde de fils tendus, qui tourne et se resserre, avec des traînées qui convergent vers le centre |
| **Toile de Souffrance** | une toile d'argent tendue entre les cinq ennemis, qui vibre à chaque coup |
| **Ballet des pantins** | elle tourne sur elle-même dans un tourbillon de fils ; à sa place reste une marionnette d'argent pendue à ses fils |
| **Le Grand Bal** | l'écran s'assombrit, une immense croix de marionnettiste paraît dans le ciel, et des fils descendent sur chaque ennemi |

---

## Image 1 — le modèle de la Reine

Joindre `assets/peso&cover/refonte/discorde.png` (la Démone de la Discorde, qu'il faut garder reconnaissable, et
la mise en page à reprendre).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre la Démone de la Discorde, une noble marionnettiste : c'est LA MÊME
personne, que tu dois transformer, pas remplacer. Elle devient la reine des pantins.
Reprends aussi sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le troisième œil, la couronne et les deux cornes se voient bien, la
   croix de marionnettiste dépasse au-dessus de sa tête
2. vue DE DOS, immobile : la croix de marionnettiste se voit en entier, les cheveux défaits
   flottent, la traîne fendue en quatre pans
3. vue DE PROFIL, TOURNÉE VERS LA DROITE, immobile : une corne, la croix derrière sa tête, les
   cheveux qui flottent vers l'arrière

LE PERSONNAGE — la Démone de la Discorde ÉVEILLÉE en REINE DE LA DISCORDE. On la reconnaît tout
de suite : même visage de jeune noble au regard dur, même LONG MANTEAU VERT SAPIN (#12463a) à col
montant, brodé d'ARGENT (#c9d2d6), même ceinture noire à boucle d'argent, même pantalon noir,
mêmes gants et bottes noirs à boucles d'argent. Ce qui change :
- son CHIGNON s'est DÉFAIT : ses longs cheveux NOIRS flottent derrière elle comme dans un courant,
  et leurs pointes se changent en FILS D'ARGENT qui ondulent ;
- une COURONNE D'ARGENT à fines pointes, comme des aiguilles, ceint sa tête, avec au milieu un
  ŒIL D'ÉMERAUDE serti ;
- sur son front s'est ouvert un TROISIÈME ŒIL VERTICAL d'un VERT ÉMERAUDE lumineux (#2fe0a0,
  cœur clair #c8ffe8) ; ses deux yeux brillent du même émeraude ;
- deux FINES CORNES NOIRES effilées, à pointe d'argent, sortent de ses cheveux et remontent vers
  l'arrière ;
- dans son DOS se dresse une CROIX DE MARIONNETTISTE D'ARGENT, grande comme son buste : deux
  barres croisées ouvragées, AU-DESSUS de sa tête, d'où pendent de FINS FILS D'ARGENT qui
  descendent jusqu'à ses mains ;
- ses GANTS noirs finissent en GRIFFES D'ARGENT, un ANNEAU D'ARGENT à chaque doigt ;
- le bas de son manteau s'est ALLONGÉ en TRAÎNE FENDUE en quatre pans pointus, brodés d'YEUX
  D'ARGENT ; des ÉPAULETTES D'ARGENT en forme de MAINS OUVERTES tiennent ses épaules.
Toutes ses formes sont cernées d'un contour très foncé (#0a1a16), net.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA, AUCUNE PRUNE SUR ELLE, ni en reflet,
ni en lueur, ni dans les fils. Ses couleurs sont le VERT SAPIN, le NOIR, l'ARGENT et l'ÉMERAUDE.

⚠️ RÈGLE BLOQUANTE — ELLE FAIT PEUR ET ELLE EST MAJESTUEUSE : posture droite, menton levé, regard
froid, une main levée à hauteur d'épaule comme pour tirer un fil. Aucun air mignon, aucun sourire.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI, À LA MÊME
TAILLE. Posée à côté de la Démone, elle fait la même hauteur SANS LA CROIX : la croix dépasse
au-dessus de sa tête de moins d'une demi-tête.

⚠️ RÈGLE BLOQUANTE — LA CROIX ET LES CHEVEUX RESTENT ÉTROITS. Ils ne dépassent pas de plus d'un
tiers de la largeur du corps de chaque côté. Les fils d'argent sont FINS et COURTS : ils relient
la croix à ses mains, ils ne s'étendent jamais hors du personnage.

⚠️ RÈGLE BLOQUANTE — AUCUNE LUEUR FLOUE, aucun halo, aucune étincelle ni particule autour d'elle :
les yeux émeraude sont des aplats nets, cernés de sombre.

⚠️ RÈGLE BLOQUANTE — LA TRAÎNE NE CACHE PAS LES PIEDS. Les deux bottes se voient, séparées l'une
de l'autre, même en très petit.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même
couronne, mêmes cornes, même croix.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Du rose, du violet ou de la prune sur elle ou dans ses fils | Le détourage les changerait en rouge terne ou en gris sale |
| Une lueur floue autour du troisième œil | Une frange resterait au détourage |
| La croix dépasse de plus d'une demi-tête, ou elle est très large | Elle déborderait des cases de marche, et serait réduite |
| Les fils partent loin d'elle | Le détourage les couperait en morceaux flottants |
| Elle est plus grande que la Démone | Elle ne doit pas changer de taille en s'éveillant |
| Plus de manteau vert sapin ni de broderies d'argent | Ce serait une autre personne, pas un Éveil |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/discorde_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT sa couronne, son troisième œil,
ses cornes, sa croix de marionnettiste, ses cheveux, son manteau, ses couleurs et ses
proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, croix comprise, et occupe environ 90 % de
  la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — la Démone de la Discorde éveillée en REINE DE LA DISCORDE, en proportions CHIBI :
long MANTEAU VERT SAPIN brodé d'ARGENT à traîne fendue, ceinture noire, gants noirs à GRIFFES
D'ARGENT, bottes noires, longs CHEVEUX NOIRS DÉFAITS aux pointes en fils d'argent, COURONNE
D'ARGENT, TROISIÈME ŒIL ÉMERAUDE au front, deux FINES CORNES NOIRES, et une CROIX DE
MARIONNETTISTE D'ARGENT dans le dos, au-dessus de sa tête. Contour très foncé net.

LES RANGÉES :
- rangée 1 : DE FACE, elle avance vers le bas
- rangée 2 : DE DOS, elle s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉE VERS LA DROITE, elle avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
croix comprise, est la même dans les 24 cases.

Elle MARCHE d'un pas lent et souverain, comme une reine qui traverse sa salle de bal. ELLE NE
COURT PAS : le buste reste DROIT, le menton levé, les genoux restent bas. La croix reste fixe
dans son dos. Les cheveux et les pans de la traîne flottent un peu différemment à chaque image.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps. Ses deux mains sont libres, doigts griffus un peu écartés, et les fils fins qui relient
ses doigts à la croix suivent ses mains.

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
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, les mains
vides.

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

⚠️ RÈGLE BLOQUANTE — LA TRAÎNE NE CACHE JAMAIS LES JAMBES : les deux bottes se voient dans les
24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LES FILS, LES CHEVEUX ET LA TRAÎNE BOUGENT. Dans
une même rangée, la tête, la couronne, les cornes, le tronc et la croix se superposent exactement
d'une case à l'autre, et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LA CROIX ET LES CHEVEUX TIENNENT DANS LA CASE : pas plus d'un tiers de la
largeur du corps de chaque côté, et la croix ne touche pas le haut de la case.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUNE PRUNE sur elle ; aucun reflet du fond
magenta. Ses lueurs émeraude sont des aplats nets.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune particule, aucun fil qui part loin
d'elle.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/discorde_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT sa couronne, son troisième œil, ses cornes, sa croix de
marionnettiste, ses cheveux, son manteau, ses couleurs et ses proportions, mais PAS sa mise en
page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — la Démone de la Discorde éveillée en REINE DE LA DISCORDE, en proportions CHIBI :
long manteau vert sapin brodé d'argent à traîne fendue, gants noirs à griffes d'argent, cheveux
noirs défaits aux pointes en fils d'argent, couronne d'argent, troisième œil émeraude, deux fines
cornes noires, croix de marionnettiste d'argent dans le dos. Contour très foncé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : elle frappe VERS LE BAS DE L'IMAGE, face au joueur. Sa main vient DROIT VERS NOUS,
  devant sa poitrine, DANS la largeur du corps — JAMAIS sur le côté
- rangée 2 : elle frappe VERS LE HAUT DE L'IMAGE, de dos. Sa main part droit devant elle, DANS
  la largeur du corps — JAMAIS sur le côté
- rangée 3 : elle frappe VERS LA DROITE, de profil, TOURNÉE VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : comme
une marionnettiste, elle LANCE UN FIL d'un claquement de doigts.
1. posture prête, les deux mains à hauteur de taille, doigts écartés
2. elle lève la main droite à hauteur de son visage, doigts repliés comme pour pincer un fil
3. elle arme : le coude en arrière, le troisième œil s'ouvre plus grand
4. LE COUP : elle détend la main droite DEVANT elle, dans la direction de la rangée, doigts
   grands ouverts, et un petit fil d'argent droit, plus court que son bras, part de ses doigts
5. le fil a disparu, la main reste tendue
6. elle ramène la main
7. la main revient à hauteur de taille
8. elle retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en
rangée 1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est le petit fil d'argent de
l'image 4, plus court que son bras. Le JEU dessine lui-même les sorts.

⚠️ RÈGLE BLOQUANTE — LA CROIX NE BOUGE PAS dans son dos, et ne dépasse pas d'un tiers de la largeur
du corps de chaque côté.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUNE PRUNE sur elle, ni en reflet du fond.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc et la tête se
superposent exactement dans les 8 images d'une rangée (seuls les bras, les fils, les cheveux et la
traîne bougent).

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — ELLE NE SE RETOURNE JAMAIS. Sur la rangée de profil, elle regarde VERS LA
DROITE dans les 8 cases.
```

---

## Image 4 — les six icônes éveillées

Aucune image à joindre.

```
Planche de six ICÔNES DE SORTS pour un jeu de rôle mobile, style cartoon coloré,
contours nets, lisibles en tout petit.

PERSONNAGE : la Démone de la Discorde éveillée en REINE DE LA DISCORDE, une reine marionnettiste
qui fait danser ses ennemis. Ses couleurs sont l'ARGENT (#c9d2d6), le VERT ÉMERAUDE lumineux
(#2fe0a0), le VERT SAPIN (#12463a), le NOIR, et un accent CORAIL (#ff6f5a), avec un CONTOUR TRÈS
FONCÉ net autour de chaque forme. Le motif commun des six icônes est le FIL D'ARGENT et l'ŒIL
ÉMERAUDE : ils doivent se retrouver dans chacune.

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

1. FIL D'ARGENT — un fil d'argent tendu qui file en diagonale, frappe une petite cible corail et
   repart en angle vers une seconde, avec une aiguille d'argent au bout.

2. ŒIL DE LA REINE — un grand œil émeraude vertical grand ouvert, d'où tombent trois fils d'argent
   vers trois petites silhouettes noires.

3. ARÈNE DE DISCORDE — un cercle de fils d'argent tendus, vu de dessus, avec des traînées corail
   qui convergent vers son centre, où brille un petit œil émeraude.

4. TOILE DE SOUFFRANCE — une toile d'argent tendue entre cinq points corail, qui vibre, avec un
   œil émeraude au centre.

5. BALLET DES PANTINS — une petite marionnette d'argent pendue à ses fils sous une croix de
   marionnettiste, et une flèche courbe qui tourne autour d'elle.

6. LE GRAND BAL — une immense CROIX DE MARIONNETTISTE d'argent, couronnée, avec un œil émeraude
   au centre, d'où pendent des fils vers une ronde de petites silhouettes qui dansent. C'est l'icône
   la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune lueur floue, aucune case vide, AUCUN ROSE, AUCUN VIOLET,
AUCUNE PRUNE dans les icônes : ils se confondraient avec le fond magenta. L'accent chaud est
CORAIL, jamais rose. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.
