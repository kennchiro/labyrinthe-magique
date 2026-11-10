# L'Éveil du Roi de Braise — l'Empereur des Cendres

> Le troisième ÉVEIL des démons. Le Roi de Braise est un roi déchu, à la couronne brisée, qui se bat avec son
> armure : ses deux gantelets et son plastron volent seuls. Éveillé, il redevient empereur pendant une minute :
> **l'Empereur des Cendres**. Sa couronne se reforge dans la lave, ses cheveux s'embrasent, et chaque pièce qu'il
> lance laisse derrière elle un sillage de cendres ardentes.

✅ **Programmé et jouable depuis le 2026-11-09** : `--demo --character braise`, puis le bouton à droite de la
barre du héros ou la touche **T**. Les quatre images sont intégrées. Les chiffres ne sont pas mesurés : les bots
ne s'éveillent pas. Un écart avec le jeu prévu : la Forge impériale ne retient que le premier ennemi, comme le
plastron de base, mais aspire tous les autres vers lui, et son explosion les prend.

Les quatre images ci-dessous se commandaient dans cet ordre, la première servant de modèle aux trois suivantes.

**Fond MAGENTA**, comme sa forme de base. ⚠️ **AUCUN ROSE, AUCUN VIOLET SUR LUI**, ni en reflet ni dans ses
lueurs : le détourage retire cette couleur. Sa flamme est orange et ambre, jamais rose ; ses ombres sont brunes et
noires, jamais prune.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle de l'Empereur | ci-dessous, image 1 | `refonte/braise_eveil.png` | `refonte/braise.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/braise_eveil_marche.png` | `refonte/braise_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/braise_eveil_attaque.png` | `refonte/braise_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_braise_eveil_skills.png` | aucune |

Aucun portrait à commander : la carte de l'écran de sélection reste celle du Roi de Braise. **Aucune nouvelle
planche de pièces** non plus : le jeu reprend ses gantelets et son plastron (`sorts/braise_pieces.png`) et les
chauffe à blanc au shader, fissures de lave rallumées. Les effets des sorts seront peints au shader, dans sa
palette (pâle `#ffd9a0`, braise `#ff9a1f`, lave `#ff5a10`, or vieilli `#b8862b`, cendre `#4a4038`, noir).

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du héros ou la touche **T**, et libre en démo.

---

## L'Empereur des Cendres

### Ce qu'il devient

On le reconnaît tout de suite : même visage d'homme adulte au regard sévère, même cicatrice sur la joue, même
armure d'or noirci aux arêtes d'or vieilli, mêmes épaulières larges, même ceinture. Mais le roi déchu se
couronne de nouveau, et c'est spectaculaire :

- Sa **couronne brisée s'est reforgée** : ses morceaux sont soudés par des coulées de **lave** orange, et elle a
  gagné de hautes pointes d'or. Au-dessus d'elle flotte un **anneau de pointes de braise**, comme une seconde
  couronne de feu.
- Ses **cheveux s'embrasent** : bruns à la racine, ils deviennent des **flammes orange et ambre** vers les
  pointes, rejetées en arrière, à bords nets.
- Ses **yeux** brûlent d'un **ambre presque blanc**, et sa **cicatrice** laisse couler un filet de lave.
- Les **fissures de lave** de son armure se sont **élargies** et brillent à travers l'or noirci, et une **plaque
  de magma** bat au milieu de son torse, comme un cœur de forge.
- De ses épaulières montent **deux volutes de flamme** dessinées, courtes, à bords francs.
- Son mantelet est devenu un **manteau impérial de cendre**, gris anthracite, qui descend à mi-cuisse, fendu en
  pans. Son **bord s'effrite en cendres** ourlées d'orange, dessinées, sans particules.

Il garde ses mains nues gantées de noir : ses **grands gantelets et son plastron volent toujours à part**, et
c'est le jeu qui les dessine. Il reste chibi, de la même taille que le Roi de Braise.

### Son trait éveillé : le Sillage de cendres

**Son armure brûle tout ce qu'elle traverse.** Tant que dure l'Éveil :
- chaque pièce **qui vole** (lancée par le Poing, en chasse, rappelée) laisse derrière elle des **cendres
  ardentes** sur les cases qu'elle traverse : 2 s, 10 dégâts par seconde à qui s'y tient ;
- une pièce éjectée par un coup reçu **revient en 4 s** au lieu de 8.

C'est son jeu poussé au bout : le labyrinthe se couvre de traînées brûlantes là où ses pièces sont passées, et
le Rappel les fait toutes repasser au même endroit.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés. ⚠️ Le Roi de base est déjà peut-être un peu fort
(0 % de morts en passe rapide) : l'Éveil doit surtout se voir, pas écraser le jeu.

| créneau | forme de base | éveillée | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Poing de braise | **Poing impérial** | un gantelet part, frappe en **explosant** autour de sa cible, puis revient | 36 dégâts, rayon 1, portée 6, 0,75 s |
| SKILL 1 | Gantelets chasseurs | **Gantelets de l'Empereur** | les deux gantelets chassent seuls, et chaque coup crache une **gerbe de lave** autour de la proie | 8 s, 22 par coup, gerbe rayon 1, recharge 12 s |
| SKILL 2 | Fournaise | **Forge impériale** | le plastron posé s'ouvre comme une forge, **aspire** les ennemis proches, retient le premier, puis **explose** sur tous | aspire à 3 cases, retient 3 s, 24 dégâts/s, explosion 40 en rayon 2, recharge 12 s |
| SKILL 3 | Rappel | **Retour de l'Empire** | toutes les pièces reviennent à travers les haies en laissant un **mur de flammes** sur leur ligne ; si les trois reviennent ensemble, une **onde de cendres** part de lui | 34 par pièce, mur 2 s, onde 40 en rayon 2, recharge 8 s |
| FUITE | Coquille de cendre | **Statue de cendres** | il saute et laisse une **statue impériale de cendre** qui attire les ennemis, puis s'effondre en **colonne de lave** | saut de 5 cases, leurre 3 s, 50 dégâts en rayon 2,5, recharge 10 s |
| EXTRA | Les Mille Cages | **L'Empire des Cendres** | le ciel se couvre de cendres, une **couronne géante de lave** s'abat sur l'écran, une cage d'or en fusion se referme sur chaque ennemi, puis chaque cage **éclate en colonne de lave** | 4 s, 70 dégâts, puis éclat 30 en rayon 1,5 |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

**Les boss** ne sont toujours ni retenus, ni aspirés, ni mis en cage, ni attirés par la statue : ils subissent
seulement les dégâts, les cendres et les éclats.

### Ce qu'on doit voir à l'écran (peint au shader)

Dans sa palette : la braise, la lave, l'or vieilli, la cendre et le noir. Net, à plages franches ; un effet se
réduit au lieu de s'estomper ; ce qui est grand passe sous lui ou reste creux au centre.

| moment | effet |
|---|---|
| **Le geste d'Éveil** (0,8 s) | les morceaux de sa couronne brisée se soulèvent autour de sa tête, la lave coule entre eux et les ressoude, et ses trois pièces se serrent contre lui en chauffant à blanc |
| **L'éclosion** | une colonne de flammes jaillit sous lui, l'anneau de braise s'allume au-dessus de sa couronne, et une onde de cendres part au sol |
| **Pendant l'Éveil** | un sceau impérial de lave tourne sous ses pieds ; ses pièces en orbite brillent, fissures rallumées ; des cendres tombent doucement autour de lui |
| **Le Sillage de cendres** | derrière chaque pièce qui vole, des braises restent posées sur les cases, rougeoient, puis s'éteignent en fumée |
| **Poing impérial** | le gantelet file dans une traînée de feu et explose en gerbe de lave sur sa cible |
| **Gantelets de l'Empereur** | deux traînées de feu qui zigzaguent, et à chaque coup une petite gerbe de lave |
| **Forge impériale** | le plastron s'ouvre en gueule de forge rougeoyante, des tourbillons de flamme aspirent les ennemis, puis il explose en champignon de feu |
| **Retour de l'Empire** | les pièces reviennent en laissant de vrais murs de flammes, puis l'onde de cendres part de lui si les trois arrivent ensemble |
| **Statue de cendres** | une statue de cendre à son image, aux fissures orange, qui craque puis s'effondre dans une colonne de lave |
| **L'Empire des Cendres** | l'écran se couvre de cendres qui tombent, une immense couronne de lave paraît dans le ciel et s'abat, les cages d'or se ferment, puis éclatent l'une après l'autre en colonnes de lave |

---

## Image 1 — le modèle de l'Empereur

Joindre `assets/peso&cover/refonte/braise.png` (le Roi de Braise, qu'il faut garder reconnaissable, et la mise
en page à reprendre).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le Roi de Braise, un roi humain déchu : c'est LA MÊME personne, que tu
dois transformer, pas remplacer. Il redevient empereur. Reprends aussi sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : la couronne reforgée, l'anneau de braise au-dessus, le cœur de magma
   au milieu du torse se voient bien
2. vue DE DOS, immobile : le manteau impérial de cendre en entier, son bord qui s'effrite, les
   cheveux en flammes rejetés en arrière
3. vue DE PROFIL, TOURNÉE VERS LA DROITE, immobile : la couronne, les cheveux en flammes vers
   l'arrière, une volute de flamme sur l'épaulière

LE PERSONNAGE — le Roi de Braise ÉVEILLÉ en EMPEREUR DES CENDRES, un homme ADULTE et HUMAIN. On
le reconnaît tout de suite : même visage sévère, même cicatrice sur la joue, même peau claire,
même armure d'OR NOIRCI (#2a2118) aux arêtes d'OR VIEILLI (#b8862b), mêmes épaulières larges,
même ceinture, mêmes jambières et solerets, mêmes simples gants noirs. Ce qui change :
- sa COURONNE BRISÉE s'est REFORGÉE : ses morceaux sont soudés par des coulées de LAVE ORANGE
  (#ff7a18), et elle a gagné de hautes pointes d'or ; AU-DESSUS d'elle flotte un ANNEAU de
  petites POINTES DE BRAISE orange, comme une seconde couronne de feu ;
- ses CHEVEUX S'EMBRASENT : bruns à la racine, ils deviennent des FLAMMES ORANGE et AMBRE
  (#ff9a1f, cœur pâle #ffd9a0) vers les pointes, rejetées en arrière, à bords NETS ;
- ses YEUX brûlent d'un AMBRE presque BLANC, et sa CICATRICE laisse couler un mince filet de lave ;
- les FISSURES DE LAVE de son armure se sont ÉLARGIES et brillent d'orange à travers l'or noirci ;
  une PLAQUE DE MAGMA ronde bat au milieu de son torse, comme un cœur de forge ;
- de ses épaulières montent DEUX VOLUTES DE FLAMME dessinées, courtes, à bords francs ;
- son mantelet est devenu un MANTEAU IMPÉRIAL DE CENDRE, gris anthracite (#4a4038), qui descend
  à MI-CUISSE, fendu en pans ; son bord S'EFFRITE en cendres ourlées d'orange, DESSINÉES.
Toutes ses formes sont cernées d'un contour très foncé (#1a120c), net.

⚠️ RÈGLE BLOQUANTE — PAS DE GRANDS GANTELETS, PAS DE PLASTRON, AUCUNE ARME. Ses mains restent
dans de simples gants noirs : ses gantelets et son plastron volent à part, et c'est le JEU qui
les dessine. Pas de cornes, de queue, de griffes ni d'ailes.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUNE PRUNE SUR LUI, ni en reflet, ni dans ses
flammes, ni dans ses ombres. Ses flammes sont ORANGE et AMBRE, ses ombres BRUNES et NOIRES.

⚠️ RÈGLE BLOQUANTE — IL EST MAJESTUEUX ET MENAÇANT : posture droite, menton levé, regard dur, une
main ouverte devant lui comme pour commander. Aucun air mignon, aucun sourire.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI, À LA MÊME
TAILLE. Posé à côté du Roi de Braise, il fait la même hauteur SANS L'ANNEAU DE BRAISE : la
couronne et l'anneau dépassent au-dessus de sa tête de moins d'une demi-tête.

⚠️ RÈGLE BLOQUANTE — LES FLAMMES RESTENT PETITES ET COLLÉES À LUI. Cheveux, volutes et anneau ne
dépassent pas de plus d'un quart de la largeur du corps de chaque côté. Ce sont des formes
dessinées à bord net, pas des flammes floues.

⚠️ RÈGLE BLOQUANTE — AUCUNE LUEUR FLOUE, aucun halo, aucune étincelle ni particule autour de lui :
la lave et les flammes sont des aplats nets, cernés de sombre.

⚠️ RÈGLE BLOQUANTE — LE MANTEAU NE CACHE PAS LES JAMBES. Il s'arrête à mi-cuisse : les deux
jambes et les deux solerets se voient, séparés l'un de l'autre, même en très petit.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même
couronne, même anneau, mêmes cheveux en flammes.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Du rose, du violet ou de la prune dans ses flammes ou ses ombres | Le détourage les changerait en rouge terne ou en gris sale |
| De grands gantelets ou un plastron sur lui | Le jeu les dessine déjà en vol : il en aurait deux de chaque |
| Une lueur floue autour des flammes | Une frange resterait au détourage |
| Les cheveux ou l'anneau débordent largement | Ils déborderaient des cases de marche, et il serait réduit |
| Le manteau descend aux chevilles | On ne verrait plus marcher ses jambes |
| Il est plus grand que le Roi de Braise | Il ne doit pas changer de taille en s'éveillant |
| Plus d'armure d'or noirci ni de cicatrice | Ce serait une autre personne, pas un Éveil |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/braise_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT sa couronne reforgée, son anneau de
braise, ses cheveux en flammes, son armure, son manteau, ses couleurs et ses proportions, mais
PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, anneau compris, et occupe environ 90 % de
  la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Roi de Braise éveillé en EMPEREUR DES CENDRES, un homme adulte et humain, en
proportions CHIBI : armure d'OR NOIRCI aux arêtes d'or vieilli, fissures de LAVE orange élargies,
cœur de magma au torse, deux volutes de flamme sur les épaulières, MANTEAU IMPÉRIAL DE CENDRE à
mi-cuisse au bord effrité, COURONNE REFORGÉE à la lave, ANNEAU DE BRAISE flottant au-dessus,
CHEVEUX EN FLAMMES orange vers les pointes, simples gants noirs. PAS de grands gantelets, de
plastron ni d'arme. Contour très foncé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
anneau compris, est la même dans les 24 cases.

Il MARCHE d'un pas lourd et impérial, comme un empereur qui traverse sa salle du trône. IL NE
COURT PAS : le buste reste DROIT, le menton levé, les genoux restent bas. L'anneau de braise reste
au-dessus de sa couronne. Les flammes de ses cheveux et les pans du manteau bougent un peu
différemment à chaque image.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps. Ses deux mains sont nues, gantées de noir, poings à demi fermés.

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

⚠️ RÈGLE BLOQUANTE — LE MANTEAU NE CACHE JAMAIS LES JAMBES : les deux solerets se voient dans les
24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LES FLAMMES DES CHEVEUX ET LES PANS DU MANTEAU
BOUGENT. Dans une même rangée, la tête, la couronne, l'anneau et le tronc se superposent exactement
d'une case à l'autre, et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES FLAMMES ET L'ANNEAU TIENNENT DANS LA CASE : pas plus d'un quart de la
largeur du corps de chaque côté, et l'anneau ne touche pas le haut de la case.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUNE PRUNE sur lui ; aucun reflet du fond
magenta. Ses flammes et sa lave sont des aplats orange nets.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune étincelle, aucune particule, aucun
gantelet ni plastron volant.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/braise_eveil.png`.

⚠️ Sur la planche d'attaque de base, son bras partait SUR LE CÔTÉ de face et de dos : le prompt insiste deux fois.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT sa couronne reforgée, son anneau de braise, ses cheveux en flammes,
son armure, son manteau, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Roi de Braise éveillé en EMPEREUR DES CENDRES, un homme adulte et humain, en
proportions CHIBI : armure d'or noirci aux fissures de lave élargies, cœur de magma au torse,
volutes de flamme sur les épaulières, manteau impérial de cendre à mi-cuisse, couronne reforgée,
anneau de braise flottant au-dessus, cheveux en flammes, simples gants noirs. PAS de grands
gantelets, de plastron ni d'arme. Contour très foncé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels. Un corps plus grand se verrait comme un gonflement à chaque coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur. Son poing vient DROIT VERS NOUS, en
  raccourci, plus gros, AU MILIEU DE SON TORSE, et cache le cœur de magma. Il reste DANS la
  largeur du corps — JAMAIS sur le côté
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos. Son bras part droit devant lui et
  DISPARAÎT DERRIÈRE SA TÊTE : on n'en voit presque rien. Il reste DANS la largeur du corps —
  JAMAIS sur le côté
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : en
empereur, il ORDONNE à son gantelet de partir, d'un coup de poing lancé.
1. posture prête, le poing droit près de la poitrine
2. il ramène le poing en arrière, les épaules tournées, les flammes des cheveux couchées
3. il arme encore le bras, le corps ramassé, le cœur de magma s'allume plus fort
4. L'IMPACT : bras tendu d'un coup dans la direction de la rangée, main grande ouverte, et un
   petit éclat ORANGE au bout des doigts, plus petit que sa main
5. l'éclat a disparu, le bras reste tendu et la main ouverte
6. la main se referme lentement
7. le bras revient près du corps
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en
rangée 1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais
l'ensemble corps et bras.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ, AUCUN GANTELET VOLANT. Le seul effet de la planche est le
petit éclat orange de l'image 4. Le JEU dessine lui-même les pièces et les sorts.

⚠️ RÈGLE BLOQUANTE — L'ANNEAU DE BRAISE NE BOUGE PAS au-dessus de sa couronne, et les flammes ne
dépassent pas d'un quart de la largeur du corps de chaque côté.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUNE PRUNE sur lui, ni en reflet du fond.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc et la tête se
superposent exactement dans les 8 images d'une rangée (seuls les bras, les flammes des cheveux et
les pans du manteau bougent).

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

PERSONNAGE : le Roi de Braise éveillé en EMPEREUR DES CENDRES, un empereur dont l'armure vole et
brûle tout ce qu'elle traverse. Ses couleurs sont l'OR VIEILLI (#b8862b), l'OR NOIRCI (#2a2118),
la BRAISE ORANGE (#ff9a1f), la LAVE (#ff5a10), le PÂLE (#ffd9a0), la CENDRE grise (#4a4038) et le
NOIR, avec un CONTOUR TRÈS FONCÉ net autour de chaque forme. Le motif commun des six icônes est
la COURONNE REFORGÉE À LA LAVE et la TRAÎNÉE DE CENDRES ARDENTES : elles doivent se retrouver dans
chacune.

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

1. POING IMPÉRIAL — un gros gantelet d'or noirci fissuré de lave, poing fermé, qui file en
   diagonale dans une traînée de feu et éclate en gerbe de lave au bout.

2. GANTELETS DE L'EMPEREUR — deux gantelets d'or noirci qui volent l'un vers l'autre en
   zigzaguant, chacun suivi d'une traînée de braises, avec une petite couronne de lave entre eux.

3. FORGE IMPÉRIALE — un plastron d'or noirci ouvert comme une gueule de forge, rouge orangé à
   l'intérieur, avec des tourbillons de flamme qui y sont aspirés.

4. RETOUR DE L'EMPIRE — trois pièces d'armure (deux gantelets et un plastron) qui convergent vers
   le centre en laissant trois murs de flammes, et une onde de cendres qui part du centre.

5. STATUE DE CENDRES — une statue grise de cendre d'un roi couronné, fissurée d'orange, qui
   s'effondre dans une colonne de lave, avec une flèche courbe qui saute au-dessus d'elle.

6. L'EMPIRE DES CENDRES — une IMMENSE COURONNE de lave et d'or qui s'abat, entourée de cages d'or
   en fusion et de colonnes de lave qui jaillissent, sous une pluie de cendres. C'est l'icône la
   plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune lueur floue, aucune case vide, AUCUN ROSE, AUCUN VIOLET,
AUCUNE PRUNE dans les icônes : ils se confondraient avec le fond magenta. Les flammes sont ORANGE
et AMBRE, jamais roses. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.
