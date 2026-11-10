# L'Éveil du Dragon des Abysses — le Dragon Primordial

> Le sixième ÉVEIL des démons. Le Dragon des Abysses est un dragon-démon bipède qui met le feu au sol. Éveillé, il
> redevient pendant une minute **le Dragon Primordial**, le premier feu du monde : quatre cornes de lave, un cœur de
> magma blanc qui bat à travers ses côtes, et un feu qui ne s'éteint plus. Ce qui meurt dans ses flammes explose et
> les répand.

✅ **Programmé et jouable depuis le 2026-11-09** : `--demo --character dragon`, puis le bouton à droite de la
barre du héros ou la touche **T**. Les quatre images sont intégrées. Les chiffres ne sont pas mesurés : les bots
ne s'éveillent pas. L'ombre du Ciel en feu reste la silhouette dessinée de sa forme de base.

Les quatre images ci-dessous se commandaient dans cet ordre, la première servant de modèle aux trois suivantes.

**Fond MAGENTA**, comme sa forme de base. ⚠️ **AUCUN ROSE, AUCUN VIOLET SUR LUI** : ses ailes restent rouge sombre,
ses ombres brunes et noires. ⚠️ **IL N'EST PAS CHIBI** : il garde les proportions massives de sa forme de base,
bipède, tête de reptile petite, épaules très larges, et le jeu le dessine 30 % plus grand. ⚠️ Il ne doit pas
ressembler au **Dragon d'or** d'Aël : pas d'or ni de blanc lumineux sur ses écailles, son feu reste magma et
obsidienne.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Dragon Primordial | ci-dessous, image 1 | `refonte/dragon_eveil.png` | `refonte/dragon.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/dragon_eveil_marche.png` | `refonte/dragon_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/dragon_eveil_attaque.png` | `refonte/dragon_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_dragon_eveil_skills.png` | aucune |

Aucun portrait à commander pour le jeu : sans portrait éveillé, la carte de sélection montre son sprite. Les effets
des sorts seront peints au shader, dans sa palette (cœur `#fff1c0`, magma jaune `#ffe36a`, magma `#ff5a10`, rouge
sang `#8a160c`, obsidienne `#1c1210`, fumée `#3a2e2a`).

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du héros ou la touche **T**, et libre en démo.

---

## Le Dragon Primordial

### Ce qu'il devient

On le reconnaît tout de suite : même dragon-démon bipède et massif, même petite tête de reptile aux crocs, mêmes
écailles noir charbon et plaques rouge sang fendues de magma, mêmes ailes rouge sombre, même longue queue à lame
d'os. Mais le premier feu du monde se réveille en lui, et c'est spectaculaire :

- Ses **deux cornes** se sont doublées en **quatre cornes** d'obsidienne, recourbées vers l'arrière, d'où coulent
  des **filets de lave** jusqu'à leurs pointes.
- Ses **yeux** brûlent d'un **blanc de magma**, et sa **gorge** rougeoie : on voit le brasier entre ses crocs.
- Au milieu de son torse, les plaques se sont écartées sur un **CŒUR DE MAGMA** jaune et blanc, qui bat entre des
  **côtes d'obsidienne**.
- Des **pointes d'obsidienne** ont poussé le long de son échine, de ses épaules et de ses avant-bras, et la lave
  **coule le long de ses bras** jusqu'à ses griffes.
- Ses **ailes** sont plus grandes, toujours repliées, et leurs membranes déchirées sont **bordées de flammes**
  dessinées, à bords nets.
- La **lame de sa queue** est devenue une lame d'**obsidienne** fendue de magma.

Il garde sa taille de base : c'est le jeu qui le dessine 30 % plus grand que les mages, comme le Dragon des Abysses.

### Son trait éveillé : le Feu primordial

**Son feu ne s'éteint plus, et il se répand.** Tant que dure l'Éveil :
- les cases qu'il enflamme **brûlent deux fois plus longtemps** (8 s) et **rongent plus fort** (15 par seconde au
  lieu de 10) ;
- un ennemi qui **meurt dans le feu** (sur une case en feu ou en brûlant) **explose** en gerbe de flammes : 20
  dégâts autour de lui, et les cases voisines prennent feu.

C'est son jeu poussé au bout : la première case en feu finit par embraser tout le couloir.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillée | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Crachat de magma | **Bombe de magma** | une grosse boule de lave qui explose à l'impact et met le feu à toutes les cases autour | 30 dégâts, rayon 1,5, portée 5, 0,75 s |
| SKILL 1 | Souffle infernal | **Souffle primordial** | un torrent de flammes blanches et jaunes qui court plus loin dans le couloir, et embrase aussi les cases qui le bordent | 46 dégâts, 8 cases, feu 8 s, recharge 10 s |
| SKILL 2 | Morsure | **Dévoreur** | il bondit sur l'ennemi le plus proche ; si la proie brûlait et qu'elle est blessée, il l'avale entière, se soigne et crache une gerbe de flammes | 60 dégâts, portée 4, avale sous 40 % de vie, +2 PV, recharge 12 s |
| SKILL 3 | Écailles de magma | **Carapace primordiale** | ses écailles encaissent deux coups au lieu d'un, brûlent qui le touche, puis éclatent en douze éclats de lave | 2 coups, 5 s, 12 éclats de 22, recharge 15 s |
| FUITE | Battement d'ailes | **Envol du dragon** | il s'envole par-dessus les haies, intouchable, et retombe en écrasant le sol dans un anneau de feu | 2 s de vol, onde 35 en rayon 2,5, le sol s'embrase, recharge 11 s |
| EXTRA | L'Ombre du Dragon | **Le Ciel en feu** | le ciel s'embrase, l'ombre d'un dragon gigantesque passe sur l'écran, et un météore de lave tombe sur chaque ennemi ; chaque point d'impact reste en feu | 4 s, 60 par météore en rayon 1,5, feu 8 s |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

**Les boss** ne sont jamais avalés par le Dévoreur : ils prennent la morsure. Ils brûlent, prennent les météores et
les explosions comme les autres.

### Ce qu'on doit voir à l'écran (peint au shader)

Dans sa palette : le cœur blanc, le magma jaune et orange, le rouge sang, l'obsidienne et la fumée. Net, à plages
franches ; un effet se réduit au lieu de s'estomper ; ce qui est grand passe sous lui ou reste creux au centre.

| moment | effet |
|---|---|
| **Le geste d'Éveil** (0,8 s) | la lave monte en veines sur tout son corps, le cœur de magma s'allume à travers ses côtes, et un cercle de fissures s'ouvre au sol sous ses pieds |
| **L'éclosion** | il rugit vers le ciel : une colonne de flammes jaillit de sa gueule, et une onde de feu part au sol en embrasant tout autour |
| **Pendant l'Éveil** | un cercle de lave craquelée tourne sous ses pieds, des braises montent de ses épaules |
| **Le Feu primordial** | un ennemi qui meurt dans le feu éclate en gerbe de flammes qui lèche les cases voisines |
| **Bombe de magma** | une grosse boule de lave qui file en tournant, puis explose en couronne de flammes |
| **Souffle primordial** | un torrent de flammes blanches au cœur, qui court dans le couloir et déborde sur les côtés |
| **Dévoreur** | une gueule de feu géante se referme sur la proie, puis une gerbe de flammes jaillit |
| **Carapace primordiale** | une coque d'écailles de magma l'entoure ; chaque coup y fait une fissure, puis elle éclate en éclats de lave |
| **Envol du dragon** | ses ailes s'ouvrent dans une bourrasque de braises, il s'élève, puis retombe dans un anneau de feu qui s'étend |
| **Le Ciel en feu** | l'écran vire au rouge sombre, l'ombre d'un dragon immense passe d'un bord à l'autre, puis des météores de lave tombent un à un, chacun dans une colonne de feu |

---

## Image 1 — le modèle du Dragon Primordial

Joindre `assets/peso&cover/refonte/dragon.png` (le Dragon des Abysses, qu'il faut garder reconnaissable, et la mise
en page à reprendre).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le Dragon des Abysses, un dragon-démon bipède : c'est LE MÊME personnage,
que tu dois transformer, pas remplacer. Le premier feu du monde se réveille en lui. Reprends
aussi sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 75 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : les quatre cornes, le cœur de magma entre ses côtes, les yeux blancs
   se voient bien
2. vue DE DOS, immobile : les pointes d'obsidienne de l'échine, les ailes repliées bordées de
   flammes, la queue à lame d'obsidienne
3. vue DE PROFIL, TOURNÉE VERS LA DROITE, immobile : la tête, les cornes, la gueule où rougeoie
   le brasier

LE PERSONNAGE — le Dragon des Abysses ÉVEILLÉ en DRAGON PRIMORDIAL, un dragon-démon BIPÈDE, debout,
massif et redoutable. On le reconnaît tout de suite : mêmes proportions de l'image jointe, PAS
chibi, tête de reptile petite, épaules très larges, torse puissant, bras musclés à mains griffues,
jambes de bête aux genoux pliés vers l'arrière ; mêmes écailles NOIR CHARBON (#1c1210) et plaques
ROUGE SANG (#8a160c) fendues de veines de MAGMA orange (#ff5a10) à cœur jaune (#ffe36a) ; mêmes
ailes rouge sombre ; même longue queue. Ce qui change :
- ses deux cornes se sont doublées en QUATRE CORNES d'obsidienne noire, recourbées vers l'arrière,
  le long desquelles coulent de fins FILETS DE LAVE jusqu'aux pointes ;
- ses YEUX brûlent d'un BLANC DE MAGMA (#fff1c0), et sa GORGE rougeoie : on voit un brasier jaune
  entre ses crocs ;
- au milieu de son torse, les plaques s'écartent sur un CŒUR DE MAGMA jaune et blanc, rond, qui
  bat entre des CÔTES D'OBSIDIENNE ;
- des POINTES D'OBSIDIENNE ont poussé le long de son échine, de ses épaules et de ses avant-bras,
  et la LAVE COULE le long de ses bras jusqu'à ses griffes ;
- ses AILES sont un peu plus grandes, toujours REPLIÉES dans le dos, et leurs membranes déchirées
  sont BORDÉES DE FLAMMES orange dessinées, à bords nets ;
- la lame de sa queue est devenue une LAME D'OBSIDIENNE fendue de magma.
Toutes ses formes sont cernées d'un contour très foncé, net.

⚠️ RÈGLE BLOQUANTE — IL N'EST PAS CHIBI. Il garde EXACTEMENT les proportions massives de l'image
jointe, et la même taille. Posé à côté du Dragon des Abysses, il fait la même hauteur.

⚠️ RÈGLE BLOQUANTE — CE N'EST PAS UN DRAGON D'OR. Aucune écaille dorée ni blanche : ses écailles
restent noir charbon et rouge sang, seul son magma brille.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, ni en reflet, ni dans ses ailes, ni dans
ses ombres : ses ailes sont ROUGE SOMBRE, ses ombres brunes et noires.

⚠️ RÈGLE BLOQUANTE — LE MAGMA ET LES FLAMMES SONT DES APLATS NETS ET OPAQUES. Aucun halo, aucune
lueur diffuse, aucune braise ni particule détachée autour de lui.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT REPLIÉES et dans sa silhouette : elles ne dépassent pas la
largeur de ses épaules de plus d'un quart de chaque côté.

⚠️ RÈGLE BLOQUANTE — IL EST MENAÇANT : posture droite, épaules en avant, griffes à demi levées,
gueule entrouverte. Aucun air mignon.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
quatre cornes, même cœur de magma.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune fumée détachée.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Un corps chibi, à grosse tête | Ce n'est plus la morphologie voulue |
| Des écailles dorées ou blanches | On le confondrait avec le Dragon d'or d'Aël |
| Du rose ou du violet dans ses ailes | Le détourage les changerait en gris sale |
| Les ailes ouvertes, très larges | Elles déborderaient des cases de marche, et il serait réduit |
| Une fumée ou des braises détachées | Le détourage les couperait en morceaux flottants |
| Plus de plaques rouge sang ni de queue à lame | Ce serait un autre dragon, pas un Éveil |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/dragon_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT ses quatre cornes, son cœur de
magma, ses écailles, ses ailes bordées de flammes, ses couleurs et ses proportions, mais PAS
sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Dragon des Abysses éveillé en DRAGON PRIMORDIAL, un dragon-démon BIPÈDE,
debout, massif et redoutable, aux proportions de l'image jointe, PAS chibi : tête de reptile
petite à QUATRE CORNES d'obsidienne coulant de lave, yeux blancs de magma, gorge qui rougeoie.
Épaules très larges hérissées de pointes d'obsidienne, CŒUR DE MAGMA jaune et blanc entre des
côtes d'obsidienne, bras musclés où coule la lave, mains griffues, jambes de bête aux genoux
pliés vers l'arrière. Écailles noir charbon (#1c1210) et plaques rouge sang (#8a160c), veines de
magma orange (#ff5a10) à cœur jaune (#ffe36a). Ailes rouge sombre REPLIÉES dans le dos, bordées de
flammes nettes. Longue queue à lame d'obsidienne, basse, derrière ses jambes.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

IL MARCHE COMME UNE PERSONNE QUI SE DÉPLACE, d'un pas lourd et menaçant, sur place. Le buste
reste droit. Les 8 colonnes de chaque rangée sont UNE BOUCLE de marche, et à CHAQUE image
les jambes ET les bras changent de position.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, reprends QUEL PIED est devant, l'ÉCART des pieds et les images
où ils se rejoignent. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses
bottes brunes ne doivent PAS apparaître, et ses jambes courtes non plus : ce sont les jambes
de bête du dragon qui prennent ces poses.

LES BRAS BALANCENT EN OPPOSITION AUX JAMBES, COMME CHEZ UN HOMME QUI MARCHE :
quand la jambe DROITE avance, c'est le bras GAUCHE qui part devant et le bras DROIT qui part
derrière ; puis ils échangent. Le coude plie, l'avant-bras pivote, et la main griffue suit
avec un léger retard, doigts à demi refermés. Les bras ne restent JAMAIS figés le long du
corps, ni collés au torse, ni croisés.

LE PAS, image par image (de profil, la jambe et le bras PROCHES sont ceux qu'on voit le mieux) :
1. jambe proche DEVANT, jambe éloignée derrière ; bras proche DERRIÈRE, bras éloigné DEVANT
2. jambes encore ouvertes ; les bras reviennent vers le corps, coudes pliés
3. ⚠️ JAMBES JOINTES sous le corps, un pied à peine levé ; les deux bras le long du corps,
   mains côte à côte : POINT DE PASSAGE
4. les jambes s'ouvrent de nouveau, les pieds ont ÉCHANGÉ leur place ; le bras proche part
   vers l'avant, le bras éloigné vers l'arrière
5. l'INVERSE de l'image 1 : jambe proche DERRIÈRE, bras proche DEVANT, bras éloigné DERRIÈRE
6. jambes encore ouvertes ; les bras reviennent vers le corps, coudes pliés
7. ⚠️ JAMBES JOINTES, l'autre pied à peine levé ; les deux bras le long du corps : POINT DE
   PASSAGE
8. les jambes s'ouvrent comme à l'image 1, le bras proche repart vers l'arrière : l'image
   enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui
avance grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté
du corps ; le genou qui avance monte un peu.

LA QUEUE ET LES AILES :
- la queue ondule en CONTRE-TEMPS : sa pointe part du côté opposé à la jambe qui avance ;
- de profil, la queue traîne DERRIÈRE lui, vers la gauche, basse, sans sortir de la case ;
- les ailes restent REPLIÉES et frémissent à peine, leurs flammes de bord changent un peu d'une
  image à l'autre.

⚠️ RÈGLE BLOQUANTE — LES BRAS NE SONT JAMAIS FIGÉS. Les images 1 et 5 montrent les bras INVERSÉS.
Deux images voisines identiques pour les bras sont une erreur. Le bras qui avance est TOUJOURS
du côté opposé à la jambe qui avance.

⚠️ RÈGLE BLOQUANTE — LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. De profil, aux images 3 et 7,
la largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5. Les
images 5 à 8 ne répètent pas les images 1 à 4 : les deux jambes échangent leurs places.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. La tête et les cornes ont EXACTEMENT
la même hauteur et la même largeur dans les 24 cases : il n'est pas plus petit ni plus fin de
profil.

⚠️ RÈGLE BLOQUANTE — LA TÊTE ET LE TORSE NE GLISSENT PAS. Dans une même rangée, ils se
superposent d'une case à l'autre, à un léger balancement près. C'est le JEU qui le fait avancer.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas. Pas d'anneau ni de cercle sous lui.

⚠️ RÈGLE BLOQUANTE — LE MAGMA ET LES FLAMMES DES AILES SONT DES APLATS NETS ET OPAQUES. Aucun halo,
aucune lueur diffuse, aucune braise ni particule détachée : le JEU ajoute le feu.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui : ses ailes sont rouge sombre.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, sa tête regarde VERS
LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune poussière.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/dragon_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT ses quatre cornes, son cœur de magma, ses écailles, ses ailes
bordées de flammes, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Dragon des Abysses éveillé en DRAGON PRIMORDIAL, un dragon-démon BIPÈDE,
debout, massif et redoutable, aux proportions de l'image jointe, PAS chibi : quatre cornes
d'obsidienne coulant de lave, yeux blancs de magma, cœur de magma entre ses côtes, pointes
d'obsidienne aux épaules et à l'échine, écailles noir charbon et plaques rouge sang veinées de
magma, ailes rouge sombre REPLIÉES bordées de flammes, queue basse à lame d'obsidienne.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le torse ont les
mêmes dimensions en pixels. Un corps plus grand se verrait comme un gonflement à chaque coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il crache VERS LE BAS DE L'IMAGE, face au joueur. La tête plonge vers nous,
  gueule ouverte, DANS la largeur du corps
- rangée 2 : il crache VERS LE HAUT DE L'IMAGE, de dos. La tête se tend droit devant lui et
  disparaît en partie, DANS la largeur du corps, jamais sur le côté
- rangée 3 : il crache VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
1. posture prête, les griffes à demi levées
2. il se redresse, la tête part en arrière, la gorge et le cœur de magma s'illuminent
3. il gonfle le torse, les épaules remontent, les griffes s'écartent
4. L'IMPACT : la tête est projetée en avant, GUEULE GRANDE OUVERTE dans la direction de la
   rangée, avec une petite boule de magma NETTE devant les crocs
5. la boule a disparu, la gueule reste ouverte
6. la gueule se referme, un filet de fumée noire sort des naseaux, collé à la tête
7. la tête revient au-dessus des épaules
8. il retrouve exactement sa pose de marche
Les jambes restent posées, les pieds ne bougent pas pendant le geste.

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en
rangée 1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ, AUCUN JET DE FLAMMES. Le seul effet est la petite
boule de l'image 4, plus petite que sa tête. Le JEU dessine les flammes.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU dans les 24 cases, et le magma garde des aplats
nets et opaques, sans halo.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT REPLIÉES, la queue reste basse, dans la case.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, sa tête regarde VERS
LA DROITE dans les 8 cases.
```

---

## Image 4 — les six icônes éveillées

Aucune image à joindre.

```
Planche de six ICÔNES DE SORTS pour un jeu de rôle mobile, style cartoon coloré,
contours nets, lisibles en tout petit.

PERSONNAGE : le Dragon des Abysses éveillé en DRAGON PRIMORDIAL, le premier feu du monde. Ses
couleurs sont le MAGMA orange (#ff5a10), le magma JAUNE (#ffe36a), le CŒUR blanc chaud (#fff1c0),
le ROUGE SANG (#8a160c), l'OBSIDIENNE noire (#1c1210) et la FUMÉE grise (#3a2e2a), avec un CONTOUR
TRÈS FONCÉ net autour de chaque forme. Le motif commun des six icônes est la FLAMME DE MAGMA et la
CORNE D'OBSIDIENNE : elles doivent se retrouver dans chacune.

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

1. BOMBE DE MAGMA — une grosse boule de lave craquelée, cernée d'obsidienne, qui éclate en
   couronne de flammes.

2. SOUFFLE PRIMORDIAL — une gueule de dragon à cornes d'obsidienne, de profil, qui crache un
   torrent de flammes blanches et jaunes en éventail.

3. DÉVOREUR — une gueule de dragon géante, vue de face, qui se referme, crocs blancs et gorge de
   magma, avec des flammes qui débordent.

4. CARAPACE PRIMORDIALE — un bouclier rond d'écailles de magma fissurées, qui éclate en éclats de
   lave tout autour.

5. ENVOL DU DRAGON — deux grandes ailes rouge sombre bordées de flammes, ouvertes au-dessus d'un
   anneau de feu au sol, avec une flèche vers le haut.

6. LE CIEL EN FEU — une silhouette noire de dragon immense, ailes ouvertes, devant un ciel rouge,
   d'où tombent des météores de lave en traînées de feu. C'est l'icône la plus spectaculaire du
   lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune lueur floue, aucune case vide, AUCUN ROSE, AUCUN VIOLET dans les
icônes : ils se confondraient avec le fond magenta. Les flammes sont ORANGE, JAUNES et BLANCHES,
jamais roses. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.
