# L'Éveil du Démon du Pacte — l'Archidémon du Pacte

> Le premier ÉVEIL des démons. Le Démon du Pacte est un noble humain qui a signé avec sa propre vie.
> Éveillé, **le pacte se paie** : le démon avec qui il a signé sort de lui, et il devient **l'Archidémon du
> Pacte** pendant une minute. Sous sa forme de base, rien de démoniaque ne se voit sur son corps ; éveillé,
> tout éclate d'un coup : cornes, ailes, bras de démon, sceau qui brûle sur sa poitrine.

✅ **Programmé et jouable depuis le 2026-11-08** : `--demo --character demon`, puis le bouton à droite de la
barre du héros ou la touche **T**. Les quatre images sont intégrées. Les chiffres ne sont pas mesurés : les bots
ne s'éveillent pas.

Les quatre images ci-dessous se commandaient dans cet ordre, la première servant de modèle aux trois suivantes.

**Fond MAGENTA**, comme sa forme de base : il est noir, cramoisi et or. ⚠️ Son cramoisi reste un ROUGE SANG
qui tire sur le brun dans l'ombre, jamais rose, jamais framboise ; ses lueurs sont des aplats nets, jamais un
halo flou. C'est ce qui permet au détourage de séparer le rouge du fond.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle de l'Archidémon | ci-dessous, image 1 | `refonte/demon_eveil.png` | `refonte/demon.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/demon_eveil_marche.png` | `refonte/demon_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/demon_eveil_attaque.png` | `refonte/demon_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_demon_eveil_skills.png` | aucune |

Aucun portrait à commander : la carte de l'écran de sélection reste celle du Démon du Pacte. Aucune image
pour les effets des sorts : ils seront peints au shader, dans sa palette (pâle `#ffe9a8`, or `#d8a93a`,
cramoisi `#c8143c`, sang sombre `#6b0a1f`, noir `#140a0e`).

Les règles de l'Éveil sont celles des mages : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du héros ou la touche **T**, et libre en démo.

---

## L'Archidémon du Pacte

### Ce qu'il devient

On reconnaît tout de suite le noble du Pacte : même visage, même long **manteau noir brodé d'or** à doublure
bordeaux, même **gilet cramoisi**, même jabot blanc, mêmes bottes noires à boucles d'or. Mais le démon avec
qui il a signé sort de lui, et c'est spectaculaire :

- **Deux grandes cornes** noires, lisses et luisantes, jaillissent de ses tempes et s'enroulent vers
  l'arrière puis remontent en pointe. Chacune est cerclée de **deux anneaux d'or** gravés de runes du pacte,
  et leur pointe est **rouge sang incandescent**.
- Ses **cheveux** ont poussé, sauvages, rejetés en arrière comme dans un vent brûlant ; leurs pointes
  virent au **cramoisi**, comme si elles brûlaient.
- Ses **yeux** ambrés sont devenus **rouge sang luisant**, à pupilles fendues **d'or**. Un petit **sceau du
  pacte** d'or brûle au milieu de son front.
- Le **rubis de son jabot** est devenu un **cœur de pacte** : un gros cristal rouge qui luit, serré dans des
  griffes d'or. De lui partent des **fissures rouges incandescentes** qui courent sous la peau de son cou,
  jusqu'à la joue gauche, comme des veines de lave.
- Son **bras droit** — celui qui brûlait déjà — est devenu **un bras de démon** : la manche a brûlé jusqu'au
  coude et laisse voir une peau **noire comme l'obsidienne**, craquelée de **veines rouges** qui luisent, et
  une main plus grande, aux **longues griffes noires à pointes d'or**. Son bras gauche garde le gant noir du
  noble. Cette asymétrie est voulue : on voit le pacte le dévorer.
- Deux **ailes de chauve-souris** s'ouvrent à moitié dans son dos : une membrane **noire veinée de rouge
  incandescent**, des os noirs terminés par une **griffe d'or**, et un bord déchiré en pointes.
- Le **bas de son manteau** s'est fendu en **longues pointes** comme une membrane d'aile, toujours bordées
  d'or. Son **col** s'est dressé en **pointes noires à bouts d'or**.
- À ses deux poignets pend une **chaîne d'or brisée** de trois maillons : le pacte qui a cédé.

Il reste chibi, de la même taille que le Démon du Pacte : l'Éveil ne le fait pas grandir d'un coup sur
l'écran. Le spectacle vient de ce qu'il porte, et de ce que le JEU ajoute autour de lui : le sceau du
pacte qui tourne sous ses pieds, et des gouttes de sang qui en jaillissent, montent puis retombent.

### Son trait éveillé : Le Prix du Sang

**Le pacte réclame son dû, et il paie en vies ennemies.**
- Sa vie **coule** : il perd **1 PV toutes les 8 s**. Jamais le dernier : comme le Pacte de sang, le prix
  ne le tue jamais.
- Chaque ennemi qu'il **tue** lui rend **1 PV**.
- Sa **Rage est doublée** : jusqu'à **+100 %** à 1 PV, au lieu de +50 %.

C'est son jeu poussé au bout : éveillé, il vit **au bord du gouffre**, à pleine puissance, et ne remonte
qu'en tuant. Un Archidémon qui ne tue plus fond jusqu'à 1 PV, et y reste.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillé | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Griffe de sang | **Serres de l'Archidémon** | son bras de démon lacère l'air : trois griffures de sang en éventail, chacune sur sa propre cible, qui ne ratent jamais | 18 dégâts chacune, portée 7, 0,5 s |
| SKILL 1 | Pacte de sang | **Pacte écarlate** | il s'ouvre la paume : 1 PV sacrifié (jamais le dernier), une onde de sang part de lui, et tous ses coups sont renforcés | onde 30 dégâts, rayon 2 ; +12 dégâts pendant 8 s ; recharge 12 s |
| SKILL 2 | Sillon de soufre | **Fleuves de soufre** | les flammes de sang partent dans TOUS les couloirs qui partent de lui à la fois, et restent plantées | 46 dégâts, portée 8, restent 4 s, recharge 9 s |
| SKILL 3 | Festin | **Gueule de l'Abîme** | une gueule de sang géante surgit du sol et se referme autour de lui ; il reprend 1 PV par ennemi happé | 34 dégâts, rayon 2,5, jusqu'à 2 PV, recharge 14 s |
| FUITE | Bond de soufre | **Ailes du Pacte** | il ouvre ses ailes et s'envole par-dessus les haies, intouchable, puis s'écrase dans une gerbe de sang | 6 cases, 30 dégâts en rayon 1,5 à l'arrivée, recharge 8 s |
| EXTRA | Dernier Pacte | **Apocalypse de Sang** | un sceau de sang géant s'ouvre sous lui et explose ; il tombe à 1 PV, intouchable, et pendant 8 s une griffe de sang géante s'abat chaque seconde sur l'ennemi le plus proche ; à la fin, il récupère TOUT ce qu'il a donné | onde 90, rayon 5 ; 8 griffes de 40 ; retour 100 % |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

Le cœur de son jeu : descendre à 1 PV avec le Pacte écarlate et le Prix du Sang, frapper à +100 %, et ne
remonter qu'en tuant — par les kills et la Gueule de l'Abîme.

### Ce qu'on doit voir à l'écran (peint au shader)

Il doit être le plus spectaculaire des Éveils. Les effets suivent la palette du Démon du Pacte et ses trois
règles : net, à plages franches ; un effet se réduit au lieu de s'estomper ; ce qui est grand passe sous lui
ou reste creux au centre, pour qu'on le voie toujours, surtout à 1 PV.

| moment | effet |
|---|---|
| **Le geste d'Éveil** (0,8 s) | le sceau du pacte s'allume sous ses pieds, des chaînes d'or s'enroulent autour de lui puis **éclatent** ; une colonne de flammes de sang monte jusqu'au ciel et l'écran tremble |
| **Pendant l'Éveil** | le sceau d'or tourne lentement sous ses pieds, et des gouttes de sang en jaillissent, montent puis retombent, plus nombreuses à mesure qu'il perd des PV. Pas de flammes : le joueur a préféré le cercle et les gouttes seuls (2026-11-08) |
| **Le Prix du Sang** | à chaque PV qui coule, le sceau de son front et son cœur de pacte pulsent ; à chaque kill, une traînée de sang file de l'ennemi jusqu'à son cœur |
| **Serres** | trois griffures rouges à cœur pâle, qui laissent une entaille d'or sur la cible |
| **Pacte écarlate** | un cercle de sang s'ouvre en onde depuis sa paume, avec des runes d'or qui tournent |
| **Fleuves de soufre** | des rivières de flammes de sang qui partent en étoile dans tous les couloirs |
| **Gueule de l'Abîme** | deux mâchoires de sang géantes sortent du sol de chaque côté de lui et se referment, creuses au centre |
| **Ailes du Pacte** | ses ailes laissent une traînée de plumes de sang, l'arrivée fend le sol en étoile |
| **Apocalypse de Sang** | le ciel vire au rouge sombre, un sceau géant couvre l'écran sous lui et explose ; chaque seconde, une serre géante tombe du ciel sur un ennemi |

---

## Image 1 — le modèle de l'Archidémon

Joindre `assets/peso&cover/refonte/demon.png` (le Démon du Pacte, qu'il faut garder reconnaissable, et la
mise en page à reprendre).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le Démon du Pacte, un noble humain : c'est LE MÊME personnage, que
tu dois transformer, pas remplacer. Le démon avec qui il a signé sort de lui. Reprends
aussi sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : les deux cornes, les yeux, le cœur de pacte et le bras de démon se
   voient bien, les ailes dépassent derrière les épaules
2. vue DE DOS, immobile : les deux ailes se voient en entier, et les cornes au-dessus de la tête
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : une corne en entier, une seule aile derrière
   son dos, le bras de démon devant

LE PERSONNAGE — le Démon du Pacte ÉVEILLÉ en ARCHIDÉMON DU PACTE. On le reconnaît tout de suite :
même visage de jeune noble, mêmes cheveux bruns, même LONG MANTEAU NOIR (#140a0e) richement BRODÉ
D'OR VIEILLI (#d8a93a) à doublure bordeaux, même GILET CRAMOISI (#c8143c), même jabot blanc, même
ceinture de cuir, mêmes bottes noires à boucles d'or. Ce qui change :
- DEUX GRANDES CORNES noires, lisses et luisantes, jaillissent de ses tempes, s'enroulent vers
  l'arrière puis remontent en pointe ; chacune est cerclée de DEUX ANNEAUX D'OR gravés de runes,
  et leur pointe est ROUGE SANG incandescent (#ff3a2a, cœur pâle #ffe9a8) ;
- ses cheveux ont poussé, sauvages, rejetés en arrière ; leurs POINTES sont CRAMOISIES ;
- ses YEUX sont ROUGE SANG LUISANT à PUPILLES FENDUES D'OR ; un petit SCEAU D'OR brûle au milieu
  de son front ;
- le rubis de son jabot est devenu un CŒUR DE PACTE : un gros cristal rouge sang qui luit, serré
  dans des griffes d'or ; de lui partent des FISSURES ROUGES INCANDESCENTES sous la peau du cou,
  jusqu'à la joue gauche, comme des veines de lave ;
- son BRAS DROIT est devenu UN BRAS DE DÉMON : la manche a brûlé jusqu'au coude, la peau est NOIRE
  COMME L'OBSIDIENNE, craquelée de VEINES ROUGES qui luisent, et la main est plus grande, aux
  LONGUES GRIFFES NOIRES À POINTES D'OR. Son bras GAUCHE garde le GANT NOIR du noble ;
- deux AILES DE CHAUVE-SOURIS s'ouvrent À MOITIÉ dans son dos : membrane NOIRE veinée de ROUGE
  incandescent, os noirs terminés par une GRIFFE D'OR, bord déchiré en pointes ;
- le bas de son manteau s'est FENDU en LONGUES POINTES comme une membrane d'aile, toujours bordées
  d'or ; son COL s'est dressé en POINTES NOIRES à bouts d'or ;
- à ses deux poignets pend une CHAÎNE D'OR BRISÉE de trois maillons.
Toutes ses formes sont cernées d'un contour très foncé (#140a0e), net.

⚠️ RÈGLE BLOQUANTE — IL FAIT PEUR ET IL EST MAJESTUEUX : posture droite, menton levé, regard dur,
le bras de démon un peu écarté du corps, griffes ouvertes. Aucun air mignon, aucun sourire.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI, À LA MÊME
TAILLE. Posé à côté du Démon du Pacte, il fait la même hauteur SANS LES CORNES : les cornes
dépassent au-dessus de sa tête, de moins d'une demi-tête.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À MOITIÉ OUVERTES ET ÉTROITES. Elles ne dépassent pas de
plus d'un tiers de la largeur du corps de chaque côté ; leur pointe haute ne monte pas plus haut
que le bout des cornes, et leur bas s'arrête à la taille.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA SUR LUI, ni en reflet, ni en lueur.
Le cramoisi reste un ROUGE SANG qui fonce vers le brun dans l'ombre. Les lueurs rouges sont des
APLATS NETS, cernés de sombre, jamais un halo flou.

⚠️ RÈGLE BLOQUANTE — AUCUNE FLAMME, AUCUNE GOUTTE, AUCUNE AURA AUTOUR DE LUI, aucune étincelle
détachée, aucun sceau au sol. Le jeu s'en charge. Ses mains ne brûlent pas sur cette planche :
seules les veines et les pointes rougeoient.

⚠️ RÈGLE BLOQUANTE — LES POINTES DU MANTEAU NE CACHENT PAS LES PIEDS. Les deux bottes se voient,
séparées l'une de l'autre, même en très petit.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
cornes, mêmes ailes, le bras de démon toujours le DROIT.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le rouge tire vers le rose ou le framboise, ou un halo rose l'entoure | Il partirait avec le fond magenta au détourage |
| Des flammes, des gouttes ou une aura autour de lui | Le jeu les dessine lui-même : elles seraient en double, et le détourage les couperait |
| Les cornes font plus d'une demi-tête de haut | Il dépasserait des cases de marche et serait réduit |
| Les ailes sont grandes ouvertes ou larges | Il passerait sur les murs |
| Le bras de démon est le gauche, ou les deux bras sont devenus démoniaques | Toutes ses poses le reprendraient à l'envers, et l'asymétrie du pacte se perdrait |
| Il est plus grand que le Démon du Pacte | Il ne doit pas changer de taille en s'éveillant |
| Il n'est plus reconnaissable (plus de manteau brodé, plus de jabot) | Ce serait un autre personnage, pas un Éveil |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/demon_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT ses cornes, ses ailes, son bras de
démon, son manteau, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, cornes comprises, et occupe environ 90 % de
  la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Démon du Pacte éveillé en ARCHIDÉMON DU PACTE, en proportions CHIBI : long
MANTEAU NOIR BRODÉ D'OR au bas fendu en pointes, gilet cramoisi, jabot blanc au CŒUR DE PACTE
rouge, DEUX GRANDES CORNES noires cerclées d'or à pointe rouge, YEUX ROUGE SANG, fissures rouges
au cou, BRAS DROIT DE DÉMON noir veiné de rouge aux longues griffes, gant noir à la main gauche,
deux AILES DE CHAUVE-SOURIS noires veinées de rouge, à moitié ouvertes, chaînes d'or brisées aux
poignets. Contour très foncé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
cornes comprises, est la même dans les 24 cases.

Il MARCHE d'un pas lent et souverain, comme un seigneur qui avance vers sa proie. IL NE COURT
PAS : le buste reste DROIT, le menton levé, les genoux restent bas. Les ailes restent à moitié
ouvertes, sans battre. Les pointes du manteau flottent un peu différemment à chaque image.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps. Ses deux mains sont libres et balancent toutes les deux en grand : la main de démon,
griffes entrouvertes, et la main gantée. Les chaînes brisées suivent les poignets.

LE BALANCEMENT DES BRAS, image par image, calé sur les jambes du guide :
1. bras droit (de démon) tendu vers l'AVANT, main à hauteur de taille ; bras gauche vers l'ARRIÈRE
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
Deux images voisines identiques pour les bras sont une erreur. Le bras de démon reste le DROIT
dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — LES POINTES DU MANTEAU NE CACHENT JAMAIS LES JAMBES : les deux bottes se
voient dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LES CHAÎNES ET LES POINTES DU MANTEAU BOUGENT.
Dans une même rangée, la tête, les cornes, le tronc et les ailes se superposent exactement d'une
case à l'autre, et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES AILES ET LES CORNES TIENNENT DANS LA CASE : les ailes ne dépassent pas
d'un tiers de la largeur du corps de chaque côté, les cornes ne touchent pas le haut de la case.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui ; le rouge reste un rouge sang, les lueurs
sont des aplats nets, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune flamme, aucune goutte, aucune aura.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/demon_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT ses cornes, ses ailes, son bras de démon, son manteau, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Démon du Pacte éveillé en ARCHIDÉMON DU PACTE, en proportions CHIBI : long
manteau noir brodé d'or au bas fendu en pointes, gilet cramoisi, cœur de pacte rouge au jabot,
deux grandes cornes noires cerclées d'or, yeux rouge sang, BRAS DROIT DE DÉMON noir veiné de rouge
aux longues griffes, gant noir à gauche, deux ailes de chauve-souris à moitié ouvertes. Contour
très foncé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur. Sa main de démon vient DROIT VERS
  NOUS, devant sa poitrine, DANS la largeur du corps
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos. Sa main de démon part droit devant lui,
  DANS la largeur du corps
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il
LACÈRE L'AIR de ses griffes de démon.
1. posture prête, la main de démon un peu écartée, griffes ouvertes
2. il ramène la main de démon haut au-dessus de son épaule droite, les ailes s'ouvrent un peu plus
3. il arme : le buste se tord, les griffes au plus haut, les veines rouges du bras brillent plus
4. LE COUP : il abat la main de démon EN DIAGONALE, devant lui, dans la direction de la rangée, et
   trois petites griffures rouges à cœur pâle, plus courtes que son bras, suivent ses griffes
5. les griffures ont disparu, le bras reste en bas, griffes tendues
6. il ramène le bras
7. le bras revient près du corps, les ailes se referment à moitié
8. il retrouve exactement sa pose de marche

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en
rangée 1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre.

⚠️ RÈGLE BLOQUANTE — C'EST TOUJOURS LE BRAS DROIT, LE BRAS DE DÉMON, QUI FRAPPE. La main gantée
reste près du corps.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul effet de la planche est les trois petites
griffures de l'image 4, plus courtes que son bras. Le JEU dessine lui-même les sorts.

⚠️ RÈGLE BLOQUANTE — LES AILES NE S'OUVRENT JAMAIS EN GRAND, et ne dépassent pas d'un tiers de la
largeur du corps de chaque côté.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, ni en reflet du fond ; les griffures sont
rouge sang à cœur pâle, en aplats nets.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE : le tronc et la tête se
superposent exactement dans les 8 images d'une rangée (seuls les bras, les ailes, le manteau et
les genoux bougent).

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

PERSONNAGE : le Démon du Pacte éveillé en ARCHIDÉMON DU PACTE, un noble dévoré par le démon avec
qui il a signé. Ses couleurs sont le CRAMOISI ROUGE SANG (#c8143c), le SANG SOMBRE (#6b0a1f), le
PÂLE (#ffe9a8), l'OR VIEILLI (#d8a93a) et le NOIR (#140a0e), avec un CONTOUR TRÈS FONCÉ net autour
de chaque forme. Le motif commun des six icônes est le SCEAU DU PACTE en or (un cercle de runes
d'or) et la GRIFFE NOIRE veinée de rouge : ils doivent se retrouver dans chacune.

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

1. SERRES DE L'ARCHIDÉMON — une main de démon noire veinée de rouge, griffes d'or écartées, qui
   laisse trois griffures rouge sang à cœur pâle en diagonale.

2. PACTE ÉCARLATE — une paume ouverte d'où jaillit une goutte de sang, au centre d'un cercle de
   runes d'or qui s'ouvre en onde rouge.

3. FLEUVES DE SOUFRE — un sceau d'or au centre, d'où partent quatre rivières de flammes rouge
   sang en croix, chacune finissant en pointe de flamme.

4. GUEULE DE L'ABÎME — deux immenses mâchoires de sang aux crocs pâles qui se referment, avec une
   goutte de vie rouge qui remonte au-dessus d'elles.

5. AILES DU PACTE — deux ailes de chauve-souris noires veinées de rouge, grandes ouvertes, au-dessus
   d'une onde de choc rouge en étoile.

6. APOCALYPSE DE SANG — une tête cornue d'archidémon vue de face, cornes noires cerclées d'or, yeux
   rouge sang aux pupilles d'or, devant un immense sceau d'or en flammes rouges, et une serre
   géante qui tombe. C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune lueur floue, aucune case vide, AUCUN ROSE NI VIOLET dans les
icônes : ils se confondraient avec le fond magenta. Le rouge reste un rouge sang. Ce sont des
SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.
