# L'Éveil de l'Avide — Faim Sans Fond

> Le huitième et dernier ÉVEIL des démons. L'Avide est un démon pur sang, voûté, sans yeux, à la gueule fendant le
> ventre : chaque proie le fait grandir. Éveillé, il devient pendant une minute **Faim Sans Fond** : sa gueule s'ouvre
> du ventre jusqu'au cou, d'autres bouches s'ouvrent sur ses bras, et sa faim ne retombe plus.

✅ **Programmé et jouable depuis le 2026-11-09** : `--demo --character avide`, puis le bouton à droite de la
barre du héros ou la touche **T**. Les quatre images sont intégrées. Les chiffres ne sont pas mesurés : les bots
ne s'éveillent pas.

Les quatre images ci-dessous se commandaient dans cet ordre, la première servant de modèle aux trois suivantes.

**Fond MAGENTA**, comme sa forme de base. ⚠️ **AUCUN ROSE, AUCUN VIOLET SUR LUI** : sa peau reste noir d'encre, ses
os ivoire, sa lueur vert bile. ⚠️ **IL N'EST PAS CHIBI** : il garde les proportions massives et voûtées de sa forme
de base, et le jeu le dessine 30 % plus grand. ⚠️ **TOUJOURS PAS D'YEUX** : c'est un démon pur sang, rien d'humain.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle de Faim Sans Fond | ci-dessous, image 1 | `refonte/avide_eveil.png` | `refonte/avide.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/avide_eveil_marche.png` | `refonte/avide_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/avide_eveil_attaque.png` | `refonte/avide_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_avide_eveil_skills.png` | aucune |

Aucun portrait à commander pour le jeu : sans portrait éveillé, la carte de sélection montre son sprite. Les effets
seront peints au shader, dans sa palette (bile `#c8e830`, bile pâle `#eef7a0`, vert profond `#4a6a10`, ivoire
`#e9e2cf`, encre `#111014`, chair sombre `#3a1418`).

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du héros ou la touche **T**, et libre en démo.

---

## Faim Sans Fond

### Ce qu'il devient

On le reconnaît tout de suite : même démon voûté à la peau noir d'encre, même tête sans yeux, mêmes jambes de bouc et
sabots fendus, mêmes très longs bras à griffes, mêmes plaques d'os ivoire. Mais la faim l'a ouvert, et c'est
spectaculaire :

- La **GUEULE DE SON VENTRE** s'est **ouverte du ventre jusqu'au cou**, verticale, bordée de deux rangées de crocs
  ivoire, et une **lueur vert bile** en sort ; une **langue noire à pointe d'os** pend de la gueule.
- Sur chacun de ses **avant-bras**, une **petite bouche** à crocs s'est ouverte entre les plaques d'os.
- Ses **cornes de bélier** se sont **fendues en quatre**, deux grandes et deux petites, et une **couronne de crocs**
  d'os pousse autour de sa tête.
- Sa **colonne** est hérissée d'une **crête de vertèbres** pointues, plus haute.
- Les **fentes vert bile** de sa peau se sont élargies, et des **filets de bile** coulent de ses bouches.
- Il est **plus massif** encore, épaules plus hautes, mais il garde sa taille de base sur la planche : c'est le jeu qui
  le grandit avec ses bouchées.

### Son trait éveillé : la Faim sans fond

**Sa faim ne retombe plus.** Tant que dure l'Éveil :
- il peut garder jusqu'à **8 bouchées** au lieu de 5 ;
- ses bouchées **ne fondent plus** avec le temps ;
- chaque kill lui donne **deux bouchées** au lieu d'une.

C'est son jeu poussé au bout : il grandit sans s'arrêter, puis il recrache tout d'un coup.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillée | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Langue-fouet | **Langues voraces** | trois langues noires claquent à la fois, chacune vers sa propre cible, et transpercent ce qu'elles traversent | 22 dégâts chacune, portée 6, 0,7 s |
| SKILL 1 | Gouffre béant | **Abîme affamé** | une gueule plus grande s'ouvre dans le sol, aspire plus loin et plus longtemps, puis se referme en mordant tout ce qu'elle tient | 55 dégâts, rayon 4, 3 s, recharge 11 s |
| SKILL 2 | Dévorer | **Tout dévorer** | il saisit les DEUX ennemis les plus proches et les avale ; un ennemi blessé meurt d'un coup et le nourrit | 70 dégâts, portée 2, achève sous 45 %, +1 PV par proie, recharge 12 s |
| SKILL 3 | Régurgitation | **Déluge de bile** | il recrache toutes ses bouchées en boules de bile qui explosent, et chaque explosion laisse une flaque de bile acide | 34 par boule, rayon 1,5, flaque 3 s à 12 dégâts/s, recharge 8 s |
| FUITE | Bond bestial | **Bond du prédateur** | un saut plus long ; à l'atterrissage, la gueule de son ventre mord tout ce qui l'entoure et le sonne | 4 cases, 30 dégâts en rayon 1,5, sonnés 1 s, recharge 11 s |
| EXTRA | Le Festin | **Le Grand Festin** | il devient colossal ; la gueule du ventre avale les ennemis plus vite et plus loin, et chaque proie avalée lui rend un PV | 7 s, rayon 7, une proie toutes les 0,5 s |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

**Les boss** ne sont jamais avalés : ils prennent la morsure. Ils prennent la bile et les explosions comme les autres.

### Ce qu'on doit voir à l'écran (peint au shader)

Dans sa palette : la bile vert vif, la bile pâle, le vert profond, l'ivoire des os et des crocs, l'encre et la chair
sombre des gorges. Net, à plages franches ; un effet se réduit au lieu de s'estomper ; ce qui est grand passe sous lui
ou reste creux au centre.

| moment | effet |
|---|---|
| **Le geste d'Éveil** (0,8 s) | la bile monte en veines sur tout son corps, les crocs de son ventre claquent trois fois, puis une gueule de crocs s'ouvre en grand sous ses pieds |
| **L'éclosion** | un hurlement : une onde de bile part au sol, ponctuée de crocs ivoire qui se dressent puis s'enfoncent |
| **Pendant l'Éveil** | une mâchoire ronde de crocs ivoire tourne couchée sous ses pieds, et des gouttes de bile en tombent |
| **La Faim sans fond** | chaque kill fait claquer une petite gueule au-dessus de la proie, et deux gouttes vertes filent vers lui |
| **Langues voraces** | trois langues noires qui claquent en éventail, une étoile de bile au bout de chacune |
| **Abîme affamé** | une gueule de crocs immense s'ouvre dans le sol, des volutes de bile l'aspirent vers son centre, puis elle se referme d'un claquement |
| **Tout dévorer** | deux gueules de crocs se referment sur les deux proies à la fois |
| **Déluge de bile** | les boules de bile retombent en arcs, explosent, et laissent des flaques vertes qui bouillonnent |
| **Bond du prédateur** | à l'atterrissage, une gueule de crocs se referme en cercle autour de lui |
| **Le Grand Festin** | l'écran s'assombrit en vert profond, et une gueule immense s'ouvre derrière lui pendant qu'il avale |

---

## Image 1 — le modèle de Faim Sans Fond

Joindre `assets/peso&cover/refonte/avide.png` (l'Avide, qu'il faut garder reconnaissable, et la mise en page à
reprendre).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre l'Avide, un démon pur sang : c'est LE MÊME personnage, que tu dois
transformer, pas remplacer. Sa faim l'a ouvert. Reprends aussi sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 75 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : la gueule ouverte du ventre jusqu'au cou, la langue qui pend, les
   bouches des avant-bras et la couronne de crocs se voient bien
2. vue DE DOS, immobile : la crête de vertèbres pointues le long de la colonne, les quatre cornes
3. vue DE PROFIL, TOURNÉE VERS LA DROITE, immobile : la gueule ouverte de profil, la langue, la
   crête de vertèbres

LE PERSONNAGE — l'Avide ÉVEILLÉ en FAIM SANS FOND, un DÉMON PUR SANG, massif et voûté. On le
reconnaît tout de suite : mêmes proportions de l'image jointe, PAS chibi, petite tête SANS YEUX,
peau NOIR D'ENCRE (#111014), plaques d'OS IVOIRE (#e9e2cf) sur les épaules, la colonne et les
avant-bras, très longs bras à griffes noires, jambes de bouc pliées vers l'arrière, sabots fendus,
fines fentes VERT BILE (#c8e830) sur la peau. Ce qui change :
- la GUEULE de son ventre s'est OUVERTE du ventre jusqu'au cou, verticale, bordée de deux rangées
  de CROCS ivoire, l'intérieur sombre (#3a1418) éclairé d'une lueur vert bile ; une LANGUE noire à
  POINTE D'OS en pend, courte, jusqu'aux cuisses ;
- sur chaque AVANT-BRAS, une PETITE BOUCHE à crocs s'est ouverte entre les plaques d'os ;
- ses CORNES DE BÉLIER se sont FENDUES EN QUATRE, deux grandes et deux petites, et une COURONNE DE
  CROCS d'os pousse autour de sa tête ;
- sa colonne est hérissée d'une CRÊTE DE VERTÈBRES pointues, plus haute ;
- les fentes vert bile se sont ÉLARGIES, et de minces FILETS DE BILE coulent de ses bouches ;
- il est plus massif encore, épaules plus hautes.
Toutes ses formes sont cernées d'un contour très foncé, net.

⚠️ RÈGLE BLOQUANTE — IL N'EST PAS CHIBI. Il garde EXACTEMENT les proportions massives et voûtées
de l'image jointe, et la même taille. Posé à côté de l'Avide, il fait la même hauteur.

⚠️ RÈGLE BLOQUANTE — TOUJOURS SANS YEUX. Rien d'humain sur lui : ni visage, ni yeux, ni cheveux.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, ni en reflet, ni dans ses gorges : l'intérieur
de ses bouches est un rouge très sombre, presque noir, éclairé de VERT.

⚠️ RÈGLE BLOQUANTE — LA BILE EST UN APLAT NET ET OPAQUE. Aucun halo, aucune lueur diffuse, aucune
goutte détachée qui flotte autour de lui : les filets de bile restent collés à ses bouches.

⚠️ RÈGLE BLOQUANTE — LA LANGUE ET LES CORNES RESTENT DANS SA SILHOUETTE : la langue ne descend pas
plus bas que ses cuisses, et les cornes ne dépassent pas la largeur de ses épaules.

⚠️ RÈGLE BLOQUANTE — IL EST TERRIFIANT : posture voûtée, bras écartés, griffes ouvertes, gueule
béante. Aucun air comique.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même gueule,
mêmes quatre cornes.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Un corps chibi, ou des yeux | Ce n'est plus le démon pur sang voulu |
| Du rose ou du violet dans ses gueules | Le détourage les changerait en gris sale |
| Des gouttes de bile détachées autour de lui | Le détourage les jetterait ou les garderait en miettes |
| Une langue qui pend jusqu'au sol | Elle ferait dériver le calage sur les sabots |
| Plus de plaques d'os ni de jambes de bouc | Ce serait un autre démon, pas un Éveil |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/avide_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT sa gueule ouverte, sa langue, ses
bouches des avant-bras, ses quatre cornes, sa crête de vertèbres, ses couleurs et ses
proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Avide éveillé en FAIM SANS FOND, un DÉMON PUR SANG, massif et voûté, aux
proportions de l'image jointe, PAS chibi : petite tête SANS YEUX à QUATRE CORNES de bélier ivoire
et couronne de crocs, peau noir d'encre (#111014), plaques d'os ivoire (#e9e2cf), crête de
vertèbres pointues, très longs bras à griffes noires avec une petite bouche sur chaque
avant-bras, jambes de bouc pliées vers l'arrière, sabots fendus. Sur le ventre, une GUEULE
verticale OUVERTE jusqu'au cou, bordée de crocs, lueur vert bile (#c8e830), une courte langue
noire à pointe d'os qui pend. Ni yeux, ni ailes, ni queue.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

IL MARCHE COMME UNE PERSONNE QUI SE DÉPLACE, d'un pas lourd de bête affamée, sur place. Le
buste reste voûté vers l'avant, mais ne plonge pas. Les 8 colonnes de chaque rangée sont UNE
BOUCLE de marche, et à CHAQUE image les jambes ET les bras changent de position.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, reprends QUEL PIED est devant, l'ÉCART des pieds et les images
où ils se rejoignent. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses
bottes brunes ne doivent PAS apparaître : ce sont les jambes de bouc du démon qui prennent ces
poses.

LES BRAS BALANCENT EN OPPOSITION AUX JAMBES, COMME CHEZ UN HOMME QUI MARCHE :
quand la jambe DROITE avance, c'est le bras GAUCHE qui part devant et le bras DROIT qui part
derrière ; puis ils échangent. Le coude plie, l'avant-bras pivote, et la main griffue suit
avec un léger retard. Les bras ne restent JAMAIS figés le long du corps.

LE PAS, image par image (de profil, la jambe et le bras PROCHES sont ceux qu'on voit le mieux) :
1. jambe proche DEVANT, jambe éloignée derrière ; bras proche DERRIÈRE, bras éloigné DEVANT
2. jambes encore ouvertes ; les bras reviennent vers le corps, coudes pliés
3. ⚠️ JAMBES JOINTES sous le corps, un sabot à peine levé ; les deux bras le long du corps :
   POINT DE PASSAGE
4. les jambes s'ouvrent de nouveau, les sabots ont ÉCHANGÉ leur place ; le bras proche part
   vers l'avant, le bras éloigné vers l'arrière
5. l'INVERSE de l'image 1 : jambe proche DERRIÈRE, bras proche DEVANT, bras éloigné DERRIÈRE
6. jambes encore ouvertes ; les bras reviennent vers le corps, coudes pliés
7. ⚠️ JAMBES JOINTES, l'autre sabot à peine levé ; les deux bras le long du corps : POINT DE
   PASSAGE
8. les jambes s'ouvrent comme à l'image 1, le bras proche repart vers l'arrière : l'image
   enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui
avance grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté
du corps. La langue se balance un peu d'une image à l'autre.

⚠️ RÈGLE BLOQUANTE — LES BRAS NE SONT JAMAIS FIGÉS. Les images 1 et 5 montrent les bras INVERSÉS.
Deux images voisines identiques pour les bras sont une erreur. Le bras qui avance est TOUJOURS
du côté opposé à la jambe qui avance.

⚠️ RÈGLE BLOQUANTE — LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. De profil, aux images 3 et 7,
la largeur occupée par les deux sabots est MOINS DE LA MOITIÉ de celle des images 1 et 5. Les
images 5 à 8 ne répètent pas les images 1 à 4.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. La tête et les cornes ont EXACTEMENT
la même hauteur et la même largeur dans les 24 cases : il n'est pas plus petit ni plus fin de
profil.

⚠️ RÈGLE BLOQUANTE — LA TÊTE ET LE TORSE NE GLISSENT PAS. Dans une même rangée, ils se
superposent d'une case à l'autre, à un léger balancement près. C'est le JEU qui le fait avancer.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du sabot posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — LA BILE EST UN APLAT NET ET OPAQUE. Aucun halo, aucune goutte détachée.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, sa tête regarde VERS
LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune poussière.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/avide_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT sa gueule ouverte, sa langue, ses bouches des avant-bras, ses
quatre cornes, sa crête de vertèbres, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — l'Avide éveillé en FAIM SANS FOND, un DÉMON PUR SANG, massif et voûté, aux
proportions de l'image jointe, PAS chibi : tête sans yeux à quatre cornes de bélier et couronne
de crocs, peau noir d'encre, plaques d'os ivoire, crête de vertèbres, longs bras griffus à
bouches sur les avant-bras, jambes de bouc, gueule du ventre ouverte jusqu'au cou, lueur vert
bile. Ni yeux, ni ailes, ni queue.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le torse ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur. Son ventre se tend vers nous,
  DANS la largeur du corps
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos. Le buste se tend droit devant lui,
  DANS la largeur du corps, jamais sur le côté
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
1. posture prête, les bras écartés, griffes ouvertes
2. il se ramasse, le buste se creuse, les bras se replient
3. il se cambre en arrière, la gueule du ventre s'ouvre encore plus grand
4. L'IMPACT : le buste est projeté en avant dans la direction de la rangée, la GUEULE GRANDE
   OUVERTE, crocs écartés, la gorge vert bile, et le bout de TROIS langues noires à pointe d'os
   qui en sortent à peine, plus courtes que sa main
5. les langues ont disparu, la gueule reste ouverte
6. la gueule se referme à demi
7. le buste revient, les bras redescendent
8. il retrouve exactement sa pose de marche
Les jambes restent posées, les sabots ne bougent pas pendant le geste.

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en
rangée 1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Les seules langues sont les trois bouts de l'image 4,
plus courts que sa main. Le JEU dessine lui-même les langues qui claquent.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU dans les 24 cases, et la bile garde des aplats
nets et opaques, sans halo.

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

PERSONNAGE : l'Avide éveillé en FAIM SANS FOND, un démon pur sang dont la faim n'a pas de fond.
Ses couleurs sont la BILE vert vif (#c8e830), la bile pâle (#eef7a0), le VERT PROFOND (#4a6a10),
l'IVOIRE des os et des crocs (#e9e2cf), l'ENCRE noire (#111014) et la CHAIR SOMBRE des gorges
(#3a1418), avec un CONTOUR TRÈS FONCÉ net autour de chaque forme. Le motif commun des six icônes
est la GUEULE À CROCS IVOIRE et la GOUTTE DE BILE : elles doivent se retrouver dans chacune.

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

1. LANGUES VORACES — trois langues noires à pointe d'os qui jaillissent en éventail d'une gueule à
   crocs, une étoile de bile au bout de chacune.

2. ABÎME AFFAMÉ — une immense gueule ronde à crocs ivoire, vue de dessus, ouverte dans le sol, avec
   des volutes de bile qui tournent vers son centre.

3. TOUT DÉVORER — deux gueules à crocs qui se referment chacune sur une petite silhouette noire.

4. DÉLUGE DE BILE — une gueule qui recrache trois boules de bile vertes en arc, au-dessus d'une
   flaque qui bouillonne.

5. BOND DU PRÉDATEUR — une silhouette de démon voûté en plein saut, avec une flèche courbe, au-dessus
   d'un cercle de crocs qui se referme.

6. LE GRAND FESTIN — une GUEULE GIGANTESQUE vue de face, à trois rangées de crocs ivoire, la gorge
   vert bile, qui avale de petites silhouettes. C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune lueur floue, aucune case vide, AUCUN ROSE, AUCUN VIOLET dans les
icônes : ils se confondraient avec le fond magenta. Les gorges sont rouge très sombre, jamais
roses. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.
