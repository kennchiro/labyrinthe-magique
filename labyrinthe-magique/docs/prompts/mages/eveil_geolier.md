# L'Éveil du Geôlier — le Gardien de l'Abîme

> Le cinquième ÉVEIL des démons. Le Geôlier est une armure vide habitée par une flamme froide : il flotte, enchaîne ce
> qu'il touche et traverse les haies. Éveillé, il devient pendant une minute **le Gardien de l'Abîme**, le geôlier de
> la prison la plus profonde : un trousseau de clés spectrales tourne dans son dos, une serrure s'ouvre au cœur de son
> plastron, et ses chaînes pèsent si lourd que tout ce qu'il frappe finit enchaîné.

✅ **Programmé et jouable depuis le 2026-11-09** : `--demo --character geolier`, puis le bouton à droite de la
barre du héros ou la touche **T**. Les quatre images sont intégrées. Les chiffres ne sont pas mesurés : les bots
ne s'éveillent pas. Le générateur a pendu le trousseau de clés à son dos au lieu d'un anneau qui tourne : c'est
gardé. Ses planches sont arrivées en cases carrées, contrairement à celles de sa forme de base.

Les quatre images ci-dessous se commandaient dans cet ordre, la première servant de modèle aux trois suivantes.

**Fond MAGENTA**, comme sa forme de base. ⚠️ **AUCUN ROSE, AUCUN VIOLET SUR LUI** : son noir tire vers le
gris-bleu, ses flammes sont cyan et blanc glacé. ⚠️ **IL N'EST PAS CHIBI** (demande du joueur) : il garde les
proportions grandes et massives de sa forme de base, heaume petit, épaules très larges, énormes gantelets, et **pas
de jambes** : il flotte sur sa flamme.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Gardien | ci-dessous, image 1 | `refonte/geolier_eveil.png` | `refonte/geolier.png` |
| 2 | Le vol | ci-dessous, image 2 | `mages/geolier_eveil_marche.png` | `refonte/geolier_eveil.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/geolier_eveil_attaque.png` | `refonte/geolier_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_geolier_eveil_skills.png` | aucune |

Aucun guide de marche : il flotte. Aucun portrait à commander : la carte de l'écran de sélection reste celle du
Geôlier. Les effets des sorts seront peints au shader ou tracés (les chaînes), dans sa palette (pâle `#e6fdff`, cyan
`#16e0e8`, profond `#0a6f7a`, liseré `#8fb8c0`, obsidienne `#14181f`), avec un noir d'abîme pour son Extra.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du héros ou la touche **T**, et libre en démo.

---

## Le Gardien de l'Abîme

### Ce qu'il devient

On le reconnaît tout de suite : même armure d'obsidienne noire aux reflets gris-bleu, vide, même heaume pointu sans
visage aux deux yeux en fente cyan, mêmes épaulières anguleuses, mêmes gantelets énormes qui flottent au bout de ses
bras, même longue flamme froide à la place des jambes. Mais le geôlier de l'abîme se révèle, et c'est spectaculaire :

- Son **heaume** est couronné de **pointes de glace noire**, et une **haute plume de flamme blanche et cyan** en
  jaillit vers l'arrière.
- Au milieu de son **plastron**, la veine en V s'est ouverte sur une **SERRURE** : un trou de serrure d'où brille un
  cyan presque blanc, cerclé d'un anneau de fer.
- Dans son **dos** tourne un **ANNEAU DE CLÉS SPECTRALES** : un cerceau de fer qui porte cinq grandes clés anciennes,
  cyan et translucides, comme le trousseau du geôlier.
- De lourdes **CHAÎNES** s'enroulent autour de ses avant-bras, et pendent de ses gantelets jusqu'à la taille, finies
  par des **crochets**.
- Ses **gantelets** se hérissent de **pointes de givre**, et des **anneaux de menottes brisées** pendent à ses
  poignets.
- Des **cristaux de givre** poussent sur ses épaulières, et sa **flamme du bas** tourne désormais en spirale,
  traversée de maillons.

Il reste à la même taille que le Geôlier : l'Éveil ne le fait pas grandir d'un coup sur l'écran.

### Son trait éveillé : le Poids des chaînes

**Tout ce qu'il frappe finit enchaîné.** Tant que dure l'Éveil :
- l'ennemi est **entravé au 2e coup** au lieu du 3e ;
- un ennemi **entravé, figé ou cloué** prend **40 % de dégâts en plus** de ses coups.

C'est son jeu poussé au bout : il immobilise d'abord, puis il frappe ce qui ne peut plus fuir.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillée | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Poing spectral | **Poing de l'Abîme** | un gantelet de flamme froide file et éclate en éclats de givre autour de sa cible | 18 dégâts, rayon 1, portée 6, 0,6 s |
| SKILL 1 | Crochet | **Crochets de l'Abîme** | trois chaînes partent à la fois, attrapent les trois ennemis les plus éloignés à portée et les traînent devant lui, sonnés | portée 8, 22 dégâts chacun, sonnés 1,2 s, recharge 10 s |
| SKILL 2 | Chaînes d'âmes | **Chaînes de l'Abîme** | des chaînes le relient à cinq ennemis, ralentis, qui brûlent de froid ; quand elles cèdent, elles se resserrent d'un coup et les figent | 5 ennemis, 7 s, 12 dégâts/s, ralentis de moitié, puis 30 dégâts et figés 1,5 s, recharge 14 s |
| SKILL 3 | Souffle glacé | **Hiver de l'Abîme** | une nova de flamme froide fige tout autour de lui, et laisse au sol une plaque de givre qui ralentit | 34 dégâts, rayon 3, figés 2,5 s, givre 4 s, recharge 12 s |
| FUITE | Traversée spectrale | **Pas de l'Abîme** | il devient flamme et traverse jusqu'à deux haies, et une onde de givre fige ce qui l'attend à l'arrivée | 5 cases, onde 20 dégâts en rayon 1,5, figés 1 s, recharge 12 s |
| EXTRA | La Geôle | **L'Abîme** | le sol s'ouvre en un gouffre noir cerclé de flamme froide : des chaînes y clouent chaque ennemi, les tirent vers le fond, puis le gouffre se referme sur eux | rayon 6, 6 s, 15 dégâts/s, tirés d'une case par seconde, puis 80 dégâts à la fermeture |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

**Les boss** ne sont ni traînés, ni figés, ni cloués : ils subissent seulement les dégâts. Le bonus du Poids des
chaînes ne vaut donc jamais contre eux.

### Ce qu'on doit voir à l'écran (peint au shader ou tracé)

Dans sa palette : le pâle au cœur, le cyan, le profond, le liseré des maillons et l'obsidienne qui cerne. Net, à
plages franches ; un effet se réduit au lieu de s'estomper ; ce qui est grand passe sous lui ou reste creux au centre.

| moment | effet |
|---|---|
| **Le geste d'Éveil** (0,8 s) | des chaînes jaillissent du sol tout autour de lui et s'enroulent en spirale autour de son corps, puis une serrure de flamme tourne et s'ouvre au milieu de son plastron |
| **L'éclosion** | les chaînes éclatent, l'anneau de clés s'allume dans son dos, et une onde de givre part au sol en figeant l'herbe |
| **Pendant l'Éveil** | un cercle de maillons tourne sous lui, givré, et de petits cristaux de glace tombent autour de lui |
| **Le Poids des chaînes** | sur un ennemi entravé, un cadenas cyan se ferme au-dessus de sa tête tant qu'il est pris |
| **Poing de l'Abîme** | le gantelet file dans une traînée de flamme froide et éclate en étoile de givre |
| **Crochets de l'Abîme** | trois chaînes partent en éventail, mordent, puis se rétractent en traînant leurs proies |
| **Chaînes de l'Abîme** | cinq chaînes tendues de lui aux proies, qui grésillent de givre ; à la fin, elles se resserrent dans un claquement et chaque proie est prise dans un bloc de glace |
| **Hiver de l'Abîme** | une onde de flamme froide déferle, des pics de glace jaillissent du sol, puis une plaque de givre reste, qui craque en s'effaçant |
| **Pas de l'Abîme** | il se défait en flamme qui file à travers les haies, et se reforme dans une onde de givre |
| **L'Abîme** | un gouffre noir s'ouvre sous l'écran, cerclé de flammes froides et de maillons, des chaînes en jaillissent sur chaque ennemi, puis le gouffre se referme comme une mâchoire de glace |

---

## Image 1 — le modèle du Gardien

Joindre `assets/peso&cover/refonte/geolier.png` (le Geôlier, qu'il faut garder reconnaissable, et la mise en page à
reprendre).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le Geôlier, une armure vide habitée par une flamme froide : c'est LE MÊME
personnage, que tu dois transformer, pas remplacer. Il devient le gardien de la prison la plus
profonde. Reprends aussi sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 70 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : la serrure au milieu du plastron, le heaume couronné et sa plume de
   flamme, les chaînes aux avant-bras se voient bien
2. vue DE DOS, immobile : l'ANNEAU DE CLÉS SPECTRALES se voit en entier dans son dos
3. vue DE PROFIL, TOURNÉE VERS LA DROITE, immobile : le heaume, la plume de flamme rejetée en
   arrière, l'anneau de clés de profil derrière lui

LE PERSONNAGE — le Geôlier ÉVEILLÉ en GARDIEN DE L'ABÎME. On le reconnaît tout de suite : même
armure d'OBSIDIENNE NOIRE (#14181f) aux reflets gris-bleu, VIDE, habitée par une FLAMME FROIDE
CYAN (#16e0e8, cœur pâle #e6fdff, creux #0a6f7a) ; mêmes proportions GRANDES ET MASSIVES : heaume
petit, épaules très larges, énormes gantelets noirs qui flottent au bout de ses bras ; même heaume
pointu et fermé, sans visage, aux deux yeux en fente cyan ; mêmes épaulières anguleuses ; et PAS
DE JAMBES : sous la taille, son corps se défait en une longue flamme qui s'effile vers le bas. Ce
qui change :
- son HEAUME est couronné de POINTES DE GLACE NOIRE, et une haute PLUME DE FLAMME blanche et cyan
  en jaillit vers l'arrière ;
- au milieu de son PLASTRON, la veine en V s'est ouverte sur une SERRURE : un TROU DE SERRURE d'où
  brille un cyan presque blanc, cerclé d'un anneau de fer ;
- dans son DOS tourne un ANNEAU DE CLÉS SPECTRALES : un cerceau de fer, plus petit que ses
  épaules, qui porte CINQ grandes CLÉS anciennes, cyan et translucides aux bords nets ;
- de lourdes CHAÎNES (#8fb8c0) s'enroulent autour de ses avant-bras et pendent de ses gantelets
  jusqu'à la taille, finies par des CROCHETS ;
- ses GANTELETS se hérissent de POINTES DE GIVRE, et des ANNEAUX DE MENOTTES BRISÉES pendent à ses
  poignets ;
- des CRISTAUX DE GIVRE pâles poussent sur ses épaulières ;
- la flamme du bas tourne en SPIRALE, traversée de quelques maillons.
Toutes ses formes sont cernées d'un contour très foncé, net.

⚠️ RÈGLE BLOQUANTE — IL N'EST PAS CHIBI. Il garde EXACTEMENT les proportions de l'image jointe :
heaume petit, épaules très larges, énormes gantelets. Posé à côté du Geôlier, il fait la même
taille.

⚠️ RÈGLE BLOQUANTE — PAS DE JAMBES, PAS DE PIEDS. Il flotte : le bas de son corps est une flamme.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, ni en reflet, ni dans ses flammes : son noir
tire vers le gris-bleu, ses flammes sont cyan et blanc glacé.

⚠️ RÈGLE BLOQUANTE — LES FLAMMES ET LES CLÉS SONT DES APLATS NETS ET OPAQUES, en trois tons de cyan.
Aucun halo, aucune lueur diffuse, aucune transparence floue, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — L'ANNEAU DE CLÉS ET LA PLUME RESTENT DANS SA SILHOUETTE : ils ne dépassent pas
la largeur de ses épaules, et la plume ne monte pas de plus d'une demi-hauteur de heaume.

⚠️ RÈGLE BLOQUANTE — LES CHAÎNES RESTENT COURTES ET COLLÉES À LUI : elles pendent jusqu'à la taille,
jamais plus bas que le haut de la flamme, et ne partent pas loin de lui.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même
serrure, même anneau de clés.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Un corps chibi, à grosse tête | Ce n'est plus la morphologie voulue par le joueur |
| Des jambes ou des pieds | Il marcherait au lieu de flotter |
| Du rose, du violet ou un halo flou dans les flammes | Une frange rose resterait au détourage |
| L'anneau de clés plus large que ses épaules | Il déborderait des cases de vol, et serait réduit |
| Des chaînes qui pendent jusqu'en bas ou partent loin | Le détourage les couperait en morceaux flottants |
| Il est plus grand que le Geôlier | Il ne doit pas changer de taille en s'éveillant |

---

## Image 2 — le vol

Joindre `assets/peso&cover/refonte/geolier_eveil.png`. Pas de guide de marche : il flotte.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe est le
modèle exact du personnage : garde EXACTEMENT son armure, sa serrure, son anneau de clés, ses
chaînes, ses flammes, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Geôlier éveillé en GARDIEN DE L'ABÎME, une armure d'obsidienne noire (#14181f)
aux reflets gris-bleu, VIDE et habitée par une flamme froide cyan (#16e0e8), aux proportions de
l'image jointe, GRANDES ET MASSIVES, PAS chibi : heaume petit couronné de pointes de glace noire
avec une plume de flamme vers l'arrière, épaules très larges givrées, SERRURE lumineuse au milieu
du plastron, ANNEAU DE CLÉS SPECTRALES dans le dos, CHAÎNES enroulées aux avant-bras, deux énormes
gantelets hérissés de givre qui flottent au bout des bras. PAS DE JAMBES : sous la taille, une
longue flamme qui s'effile vers le bas en spirale.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

IL FLOTTE, IL NE MARCHE PAS, MAIS SES BRAS BOUGENT COMME CEUX D'UN MARCHEUR. Les 8 colonnes
de chaque rangée sont UNE BOUCLE de déplacement :
- LES BRAS BALANCENT FRANCHEMENT, en opposition : quand l'avant-bras et le gantelet droits
  partent vers l'avant, les gauches partent vers l'arrière, puis ils échangent. Le coude
  plie, l'avant-bras pivote, et le gantelet suit avec un temps de retard, comme s'il était
  lourd. Les chaînes suivent les gantelets. Les bras ne restent JAMAIS figés ;
- la flamme du bas ondule et tourne, ses pointes changent d'une image à l'autre ;
- les flammes du heaume et des épaules battent avec le mouvement des bras ;
- DE PROFIL, la flamme du bas et la plume du heaume traînent un peu EN ARRIÈRE, vers la gauche.
  L'image 8 enchaîne sur l'image 1.

LE BALANCEMENT DES BRAS, image par image (le bras PROCHE est celui qu'on voit le mieux) :
1. bras proche tendu vers l'AVANT, gantelet à hauteur de taille ; bras éloigné vers l'ARRIÈRE
2. bras proche qui redescend, coude un peu plié ; bras éloigné qui revient
3. les deux bras le long du corps, gantelets côte à côte, POINT DE PASSAGE
4. bras proche qui part vers l'arrière ; bras éloigné qui part vers l'avant
5. l'INVERSE de l'image 1 : bras proche vers l'ARRIÈRE, bras éloigné tendu vers l'AVANT
6. bras éloigné qui redescend ; bras proche qui revient
7. les deux bras le long du corps, POINT DE PASSAGE
8. bras proche qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : le gantelet qui
avance grossit et descend un peu, celui qui recule rétrécit et monte un peu, de chaque côté
du corps.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Le heaume a EXACTEMENT la même
hauteur et la même largeur dans les 24 cases : il n'est pas plus petit ni plus fin de profil.

⚠️ RÈGLE BLOQUANTE — LE HEAUME, LE TORSE ET L'ANNEAU DE CLÉS NE BOUGENT PAS. Dans une même rangée,
ils se superposent exactement d'une case à l'autre : seuls les bras, les gantelets, les chaînes
et les flammes bougent. C'est le JEU qui le fait avancer sur la carte.

⚠️ RÈGLE BLOQUANTE — LES BRAS NE SONT JAMAIS FIGÉS. Les images 1 et 5 montrent les bras inversés.
Deux images voisines identiques pour les bras sont une erreur.

⚠️ RÈGLE BLOQUANTE — LE BAS DE LA FLAMME S'ARRÊTE SUR LA MÊME LIGNE HORIZONTALE dans les 24
cases, et rien n'est dessiné plus bas. Pas d'anneau ni de cercle sous lui.

⚠️ RÈGLE BLOQUANTE — LES FLAMMES ET LES CLÉS SONT DES APLATS NETS ET OPAQUES, en trois tons de
cyan. Aucun halo, aucune lueur diffuse, aucune transparence, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — L'ANNEAU DE CLÉS, LA PLUME ET LES CHAÎNES TIENNENT DANS LA CASE, sans dépasser
la largeur de ses épaules.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui : son noir tire vers le gris-bleu.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son heaume regarde
VERS LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/geolier_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT son armure, sa serrure, son anneau de clés, ses chaînes, ses
flammes, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Geôlier éveillé en GARDIEN DE L'ABÎME, une armure d'obsidienne noire (#14181f)
VIDE, habitée par une flamme froide cyan (#16e0e8), aux proportions de l'image jointe, GRANDES ET
MASSIVES, PAS chibi : heaume petit couronné de glace noire avec sa plume de flamme, épaules très
larges givrées, serrure lumineuse au plastron, anneau de clés spectrales dans le dos, chaînes aux
avant-bras, deux énormes gantelets hérissés de givre. PAS DE JAMBES : une longue flamme en spirale.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE VOL : le heaume et le torse ont les
mêmes dimensions en pixels. Un corps plus petit se verrait comme un rétrécissement à chaque coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur. Le gantelet vient DROIT VERS
  NOUS, devant son plastron, et cache la serrure. Il reste DANS la largeur du corps, jamais sur
  le côté
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos. Le bras part droit devant lui et le
  gantelet disparaît derrière son heaume, DANS la largeur du corps, jamais sur le côté
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
1. posture prête, les gantelets près du corps
2. il ramène le gantelet droit en arrière, la flamme des épaules se gonfle, la serrure s'allume
3. il arme encore, le corps ramassé
4. L'IMPACT : bras tendu d'un coup dans la direction de la rangée, gantelet ouvert, et un
   petit éclat CYAN net au bout des doigts, plus petit que sa main
5. l'éclat a disparu, le bras reste tendu
6. le gantelet se referme
7. le bras revient près du corps
8. il retrouve exactement sa pose de vol

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée
1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais l'ensemble
corps et bras.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ, AUCUN GANTELET QUI S'ENVOLE, AUCUNE CHAÎNE LANCÉE. Les
chaînes restent enroulées à ses bras. Le seul effet est le petit éclat de l'image 4.

⚠️ RÈGLE BLOQUANTE — L'ANNEAU DE CLÉS NE BOUGE PAS dans son dos.

⚠️ RÈGLE BLOQUANTE — LE BAS DE LA FLAMME S'ARRÊTE SUR LA MÊME LIGNE HORIZONTALE dans les 24
cases, et la flamme garde des aplats nets et opaques, sans halo.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son heaume regarde VERS
LA DROITE dans les 8 cases.
```

---

## Image 4 — les six icônes éveillées

Aucune image à joindre.

```
Planche de six ICÔNES DE SORTS pour un jeu de rôle mobile, style cartoon coloré,
contours nets, lisibles en tout petit.

PERSONNAGE : le Geôlier éveillé en GARDIEN DE L'ABÎME, une armure vide habitée par une flamme
froide, geôlier de la prison la plus profonde. Ses couleurs sont le CYAN (#16e0e8), le PÂLE
glacé (#e6fdff), le cyan PROFOND (#0a6f7a), le gris-bleu des maillons (#8fb8c0) et l'OBSIDIENNE
noire (#14181f), avec un CONTOUR TRÈS FONCÉ net autour de chaque forme. Le motif commun des six
icônes est la CHAÎNE et la CLÉ (ou la serrure) : elles doivent se retrouver dans chacune.

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

1. POING DE L'ABÎME — un énorme gantelet noir hérissé de givre, une chaîne au poignet, qui frappe
   et éclate en étoile de glace cyan.

2. CROCHETS DE L'ABÎME — trois chaînes qui partent en éventail, chacune finie par un crochet
   cyan, avec une grande clé ancienne au centre.

3. CHAÎNES DE L'ABÎME — un cadenas cyan fermé, d'où partent cinq chaînes tendues vers cinq blocs de
   glace.

4. HIVER DE L'ABÎME — une onde ronde de flamme froide d'où jaillissent des pics de glace, avec un
   flocon et un trou de serrure au centre.

5. PAS DE L'ABÎME — une flamme cyan en forme de silhouette qui traverse une haie noire, avec une
   flèche, et une onde de givre à l'arrivée.

6. L'ABÎME — un GOUFFRE NOIR rond, vu de dessus, cerclé de flammes cyan et de maillons, d'où
   jaillissent des chaînes, avec un grand trou de serrure lumineux au fond. C'est l'icône la plus
   spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune lueur floue, aucune case vide, AUCUN ROSE, AUCUN VIOLET dans les
icônes : ils se confondraient avec le fond magenta. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.
