# L'Éveil du Croupier des Enfers — le Maître du Casino

> Le septième ÉVEIL des démons. Le Croupier des Enfers est un démon joueur en costume : cartes, dés, pièce et
> roulette, chaque sort est un pari. Éveillé, il devient pendant une minute **le Maître du Casino**, celui qui tient
> la banque des Enfers : haut-de-forme, queue-de-pie, monocle-roulette et queue de démon en pique. Et au casino des
> Enfers, **la maison gagne toujours**.

✅ **Programmé et jouable depuis le 2026-11-09** : `--demo --character croupier`, puis le bouton à droite de la
barre du héros ou la touche **T**. Les quatre images sont intégrées. Les chiffres ne sont pas mesurés : les bots
ne s'éveillent pas.

Les quatre images ci-dessous se commandaient dans cet ordre, la première servant de modèle aux trois suivantes.

**Fond MAGENTA**, comme sa forme de base. ⚠️ **AUCUN ROSE, AUCUN VIOLET SUR LUI** : son bordeaux reste un rouge
sombre SANS BLEU (`#7a0f14`), son or est un or chaud. ⚠️ **Il reste CHIBI**, à la même taille que le Croupier.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Maître du Casino | ci-dessous, image 1 | `refonte/croupier_eveil.png` | `refonte/croupier.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/croupier_eveil_marche.png` | `refonte/croupier_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/croupier_eveil_attaque.png` | `refonte/croupier_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_croupier_eveil_skills.png` | aucune |

Aucun portrait à commander pour le jeu : sans portrait éveillé, la carte de sélection montre son sprite. Les effets
seront peints au shader, dans sa palette (or `#e8c25a`, or sombre `#9a7420`, bordeaux `#7a0f14`, rouge vif `#d81e1e`,
noir `#141012`, blanc carte `#f6f0e2`). Sa roulette, ses cartes et ses dés restent ceux de sa forme de base,
dorés par le jeu.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du héros ou la touche **T**, et libre en démo.

---

## Le Maître du Casino

### Ce qu'il devient

On le reconnaît tout de suite : même visage pâle au sourire en coin, mêmes yeux rouges, mêmes cheveux noirs plaqués,
mêmes gants blancs, même chemise blanche à cravate rouge sombre. Mais le banquier des Enfers se révèle, et c'est
spectaculaire :

- Un **HAUT-DE-FORME** noir à bande d'or est posé sur sa tête, une **carte d'as** glissée dans la bande ; ses
  **cornes** ont poussé, **dorées**, et sortent de part et d'autre du chapeau.
- Un **MONOCLE** d'or couvre son œil droit, et son verre est une **petite roulette** rouge et noire.
- Son veston est devenu une **QUEUE-DE-PIE** bordeaux à revers noirs, doublée d'or, dont les deux basques se
  terminent en **pointes de carte** ; les quatre **enseignes** (pique, cœur, carreau, trèfle) sont brodées d'or sur
  les revers.
- Une **QUEUE DE DÉMON** noire sort de sous la queue-de-pie et se termine en **PIQUE** doré.
- Il tient une **CANNE** noire au pommeau d'or en forme de **dé**.
- Une **chaîne de montre** en or barre son gilet, et des **bagues** d'or brillent sur ses gants.

Il reste chibi, de la même taille que le Croupier.

### Son trait éveillé : la Maison gagne toujours

**Tant que dure l'Éveil :**
- son **Coup de chance** tombe **deux fois plus souvent** ;
- chaque Coup de chance **éclate en pluie de jetons** d'or sur les ennemis voisins (15 dégâts dans un rayon de 1,2).

C'est son jeu poussé au bout : la chance n'est plus un hasard, c'est la banque qui encaisse.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillée | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Carte tranchante | **Main gagnante** | trois cartes partent en éventail, chacune vers sa propre cible | 18 dégâts chacune, portée 7, 0,6 s |
| SKILL 1 | Dés pipés | **Dés du Diable** | TROIS dés roulent dans le couloir ; leur total fait les dégâts, un double sonne, un brelan fige et brûle | 3 dés, ×6 par point, portée 7, recharge 9 s |
| SKILL 2 | Carte piège | **Table piégée** | quatre cartes face cachée se posent en croix autour de lui ; certaines sont des **Jokers**, qui font les trois effets à la fois | 4 cartes, 1 Joker sur 4, 12 s, recharge 9 s |
| SKILL 3 | Pile ou face | **Pièce truquée** | la pièce retombe sur la tranche : il est intouchable et soigné, ET ses prochaines cartes frappent double | 2 s, +1 PV, 3 coups doublés, recharge 15 s |
| FUITE | Tour de passe-passe | **Grand tour de magie** | il disparaît dans son haut-de-forme et reparaît plus loin ; sa carte reste, attire les ennemis, puis explose en pluie de jetons | 5 cases, leurre 2,5 s, 30 dégâts en rayon 1,5, recharge 11 s |
| EXTRA | La Roulette infernale | **Le Grand Jeu** | la roulette géante tourne TROIS FOIS de suite ; chaque tour applique son résultat (rouge, noir ou zéro) | 3 tours, mêmes effets que la Roulette |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

**Les boss** ne sont ni figés ni sonnés : ils prennent les dégâts, les jetons et les brûlures.

### Ce qu'on doit voir à l'écran (peint au shader)

Dans sa palette : l'or, le bordeaux, le rouge vif, le noir et le blanc des cartes. Net, à plages franches ; un
effet se réduit au lieu de s'estomper ; ce qui est grand passe sous lui ou reste creux au centre.

| moment | effet |
|---|---|
| **Le geste d'Éveil** (0,8 s) | un jeu de cartes s'envole en spirale autour de lui, les cartes se retournent une à une, puis un haut-de-forme tombe du ciel sur sa tête dans un éclat d'or |
| **L'éclosion** | une pluie de pièces d'or jaillit de lui, et un tapis vert de casino s'étend au sol, bordé d'or |
| **Pendant l'Éveil** | un tapis de roulette rond tourne sous ses pieds, cases rouges et noires bordées d'or, et des jetons tombent autour de lui |
| **La Maison gagne toujours** | chaque Coup de chance fait jaillir une gerbe de jetons d'or qui retombent sur les voisins |
| **Main gagnante** | trois cartes rouges et or partent en éventail, chacune laissant une traînée dorée |
| **Dés du Diable** | trois gros dés rouges roulent dans le couloir ; un double claque en éclair, un brelan s'embrase |
| **Table piégée** | quatre cartes tombent en croix autour de lui ; un Joker retourné éclate en feu, glace et foudre à la fois |
| **Pièce truquée** | une grosse pièce d'or tourne, retombe sur la tranche et reste debout, dans un double éclat |
| **Grand tour de magie** | un haut-de-forme géant l'engloutit, puis le recrache plus loin dans un nuage de cartes |
| **Le Grand Jeu** | la roulette géante tourne trois fois, et à chaque arrêt l'écran claque de la couleur tirée |

---

## Image 1 — le modèle du Maître du Casino

Joindre `assets/peso&cover/refonte/croupier.png` (le Croupier des Enfers, qu'il faut garder reconnaissable, et la
mise en page à reprendre).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le Croupier des Enfers, un démon joueur en costume : c'est LA MÊME
personne, que tu dois transformer, pas remplacer. Il devient le banquier du casino des Enfers.
Reprends aussi sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le haut-de-forme, le monocle-roulette, les enseignes d'or sur les
   revers et la canne se voient bien
2. vue DE DOS, immobile : les deux basques de la queue-de-pie en pointes de carte, et la queue de
   démon terminée en pique doré
3. vue DE PROFIL, TOURNÉE VERS LA DROITE, immobile : le haut-de-forme, une corne dorée, le monocle,
   la queue en pique derrière lui

LE PERSONNAGE — le Croupier des Enfers ÉVEILLÉ en MAÎTRE DU CASINO, un homme ADULTE et HUMAIN, en
proportions CHIBI : grosse tête, corps court, à la même taille que l'image jointe. On le reconnaît
tout de suite : même visage pâle au sourire en coin, mêmes yeux ROUGES, mêmes cheveux noirs
plaqués, mêmes gants BLANCS, même chemise blanche et cravate rouge sombre. Ce qui change :
- un HAUT-DE-FORME noir à bande d'OR (#e8c25a), une carte d'AS blanche glissée dans la bande ;
- ses deux CORNES ont poussé, DORÉES, et sortent de part et d'autre du chapeau ;
- un MONOCLE d'or sur l'œil droit, dont le verre est une petite ROULETTE rouge et noire ;
- son veston est devenu une QUEUE-DE-PIE BORDEAUX (#7a0f14) à revers noirs, doublée d'or, dont
  les deux basques se terminent en POINTES DE CARTE ; les quatre ENSEIGNES (pique, cœur, carreau,
  trèfle) sont brodées d'or sur les revers ;
- une QUEUE DE DÉMON noire sort de sous la queue-de-pie et se termine en PIQUE DORÉ ;
- il tient une CANNE noire, courte, au pommeau d'or en forme de DÉ ;
- une CHAÎNE DE MONTRE en or barre son gilet noir, et des BAGUES d'or brillent sur ses gants.
Toutes ses formes sont cernées d'un contour très foncé, net.

⚠️ RÈGLE BLOQUANTE — LE BORDEAUX EST UN ROUGE SOMBRE SANS BLEU. AUCUN ROSE, AUCUN VIOLET sur lui,
ni en reflet, ni dans ses ombres.

⚠️ RÈGLE BLOQUANTE — IL EST ÉLÉGANT ET INQUIÉTANT : posture droite, une main sur le pommeau de sa
canne, l'autre tenant une carte entre deux doigts, sourire en coin. Pas d'air grotesque.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI, À LA MÊME
TAILLE. Le haut-de-forme dépasse au-dessus de sa tête de moins d'une demi-tête.

⚠️ RÈGLE BLOQUANTE — LA CANNE ET LA QUEUE RESTENT COURTES ET COLLÉES À LUI : la canne ne dépasse pas
sa hanche, la queue ne dépasse pas d'un quart de la largeur du corps sur le côté.

⚠️ RÈGLE BLOQUANTE — AUCUNE LUEUR FLOUE, aucun halo, aucune pièce ni carte volante autour de lui.

⚠️ RÈGLE BLOQUANTE — LA QUEUE-DE-PIE NE CACHE PAS LES JAMBES : les deux chaussures noires se voient,
séparées l'une de l'autre, même en très petit.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même
chapeau, même monocle, même canne.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Un bordeaux qui tire sur le prune ou le rose | Le détourage lui retirerait son rouge |
| Un haut-de-forme très haut | Il déborderait des cases de marche, et serait réduit |
| Une canne longue ou tenue loin du corps | Elle se couperait au détourage, ou ferait dériver la case |
| Des cartes ou des pièces qui volent autour de lui | Le détourage les jetterait ou les garderait en morceaux flottants |
| Plus de gants blancs ni d'yeux rouges | Ce serait une autre personne, pas un Éveil |
| Il est plus grand que le Croupier | Il ne doit pas changer de taille en s'éveillant |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/croupier_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son haut-de-forme, ses cornes
dorées, son monocle, sa queue-de-pie, sa queue en pique, sa canne, ses couleurs et ses
proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, chapeau compris, et occupe environ 90 % de
  la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Croupier des Enfers éveillé en MAÎTRE DU CASINO, un homme adulte et humain, en
proportions CHIBI : HAUT-DE-FORME noir à bande d'or, deux CORNES DORÉES, yeux rouges, MONOCLE-
ROULETTE, cheveux noirs plaqués, QUEUE-DE-PIE BORDEAUX (#7a0f14) doublée d'or aux basques en pointes
de carte, chemise blanche, cravate rouge sombre, gants blancs à bagues d'or, chaussures noires
vernies, QUEUE DE DÉMON en PIQUE doré, et une CANNE noire courte à pommeau de dé d'or tenue dans
la main gauche. Contour très foncé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
chapeau compris, est la même dans les 24 cases.

Il MARCHE d'un pas souple et désinvolte, comme un joueur qui traverse sa salle de jeu. IL NE COURT
PAS : le buste reste DROIT, le menton haut, les genoux restent bas. Le haut-de-forme ne bouge pas.
Les basques et la queue en pique se balancent un peu différemment à chaque image.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps. La main gauche garde sa canne, qui suit le balancement du bras, pointe vers le bas.

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

⚠️ RÈGLE BLOQUANTE — LES BASQUES NE CACHENT JAMAIS LES JAMBES : les deux chaussures se voient dans
les 24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LA CANNE, LES BASQUES ET LA QUEUE BOUGENT. Dans une
même rangée, la tête, le chapeau et le tronc se superposent exactement d'une case à l'autre, et le
profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — LE BORDEAUX EST UN ROUGE SOMBRE SANS BLEU ; aucun rose, aucun violet, aucun
reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune carte ni pièce volante.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/croupier_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT son haut-de-forme, ses cornes dorées, son monocle, sa queue-de-pie,
sa queue en pique, sa canne, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Croupier des Enfers éveillé en MAÎTRE DU CASINO, un homme adulte et humain, en
proportions CHIBI : haut-de-forme noir à bande d'or, cornes dorées, yeux rouges, monocle-roulette,
queue-de-pie bordeaux doublée d'or, gants blancs, queue de démon en pique doré, canne noire courte
à pommeau de dé tenue dans la main GAUCHE. Contour très foncé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il lance VERS LE BAS DE L'IMAGE, face au joueur. Sa main droite part DROIT VERS NOUS,
  devant sa poitrine, et reste DANS la largeur du corps, jamais sur le côté
- rangée 2 : il lance VERS LE HAUT DE L'IMAGE, de dos. Le bras droit part droit devant lui et la
  main disparaît derrière sa tête, DANS la largeur du corps, jamais sur le côté
- rangée 3 : il lance VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle — le
geste d'un croupier qui lance trois cartes en éventail d'un coup de poignet :
1. posture prête, la main droite à hauteur de poitrine, trois cartes en éventail entre les doigts
2. il ramène la main vers son épaule opposée, le poignet plié
3. il arme encore, le buste un peu tourné
4. LE LANCER : le bras se détend d'un coup dans la direction de la rangée, poignet cassé, et trois
   petites cartes rouges NETTES quittent ses doigts, encore serrées
5. les cartes ont disparu, le bras reste tendu, deux doigts pointés
6. le poignet se redresse
7. le bras revient près du corps
8. il retrouve exactement sa pose de marche
La main gauche garde la canne, pointe au sol. Les jambes restent posées, les pieds ne bougent pas.

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée
1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Les seules cartes sont les trois petites de l'image 4,
plus petites que sa main. Le JEU dessine lui-même les cartes qui volent.

⚠️ RÈGLE BLOQUANTE — LE HAUT-DE-FORME NE BOUGE PAS et ne tombe jamais.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — LE BORDEAUX EST UN ROUGE SOMBRE SANS BLEU, aucun reflet du fond magenta.

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

PERSONNAGE : le Croupier des Enfers éveillé en MAÎTRE DU CASINO, le banquier des Enfers, pour qui la
maison gagne toujours. Ses couleurs sont l'OR (#e8c25a), l'or sombre (#9a7420), le BORDEAUX SANS
BLEU (#7a0f14), le ROUGE VIF (#d81e1e), le NOIR (#141012) et le BLANC DES CARTES (#f6f0e2), avec un
CONTOUR TRÈS FONCÉ net autour de chaque forme. Le motif commun des six icônes est le HAUT-DE-FORME
et le JETON D'OR : ils doivent se retrouver dans chacune.

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

1. MAIN GAGNANTE — trois cartes rouges et or qui filent en éventail, chacune suivie d'une traînée
   dorée, devant un petit haut-de-forme.

2. DÉS DU DIABLE — trois gros dés rouges à points d'or qui roulent, avec de petites flammes, et un
   jeton d'or.

3. TABLE PIÉGÉE — quatre cartes face cachée posées en croix, et au centre un JOKER retourné qui
   éclate en feu, glace et foudre.

4. PIÈCE TRUQUÉE — une grosse pièce d'or debout SUR SA TRANCHE, avec un double éclat de chaque côté.

5. GRAND TOUR DE MAGIE — un haut-de-forme renversé d'où jaillissent des cartes, avec une flèche
   courbe qui en sort.

6. LE GRAND JEU — une grande ROULETTE vue de dessus, cases rouges et noires bordées d'or, avec
   trois billes et une pluie de jetons d'or. C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune lueur floue, aucune case vide, AUCUN ROSE, AUCUN VIOLET dans les
icônes : ils se confondraient avec le fond magenta. Le rouge est un rouge franc, jamais rosé. Ce
sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.
