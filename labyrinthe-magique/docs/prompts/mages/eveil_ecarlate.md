# L'Éveil du Chevalier Écarlate — le Seigneur Écarlate

> Le quatrième ÉVEIL des démons. Le Chevalier Écarlate est un bretteur humain aux longs cheveux blancs : ses coups
> laissent des entailles qui ne s'ouvrent que lorsqu'il rengaine. Éveillé, le démon de sa lame se montre pendant une
> minute : **le Seigneur Écarlate**. Un masque de démon lui couvre le bas du visage, une lame fantôme flotte dans son
> dos, et ses entailles n'attendent plus : arrivées au bout, elles s'ouvrent toutes seules.

✅ **Programmé et jouable depuis le 2026-11-09** : `--demo --character ecarlate`, puis le bouton à droite de la
barre du héros ou la touche **T**. Les quatre images sont intégrées. Les chiffres ne sont pas mesurés : les bots
ne s'éveillent pas. Le générateur a dessiné le cimier en un seul croissant noir et rouge sur le front, et non en V :
c'est gardé.

Les quatre images ci-dessous se commandaient dans cet ordre, la première servant de modèle aux trois suivantes.

**Fond MAGENTA**, comme sa forme de base. ⚠️ **SON ROUGE EST FRANC, SANS AUCUN BLEU** (`#b81414`) : avec un peu
de bleu, le détourage lui retire son rouge (mesuré sur sa forme de base). Aucun rose, aucun violet, aucun bordeaux
tirant sur le prune. Ses blancs restent des blancs chauds.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle du Seigneur | ci-dessous, image 1 | `refonte/ecarlate_eveil.png` | `refonte/ecarlate.png` |
| 2 | La marche | ci-dessous, image 2 | `mages/ecarlate_eveil_marche.png` | `refonte/ecarlate_eveil.png` et `docs/prompts/mages_animes/guide_complet.png` |
| 3 | L'attaque | ci-dessous, image 3 | `mages/ecarlate_eveil_attaque.png` | `refonte/ecarlate_eveil.png` |
| 4 | Les six icônes éveillées | ci-dessous, image 4 | `sorts/mage_ecarlate_eveil_skills.png` | aucune |

Aucun portrait à commander : la carte de l'écran de sélection reste celle du Chevalier Écarlate. Aucune image pour
les effets des sorts : ils seront peints au shader, dans sa palette (blanc `#fff6ee`, acier `#d9dee3`, écarlate
`#b81414`, sombre `#5e0a0a`, noir `#17171a`), avec une lune rouge pour son Extra.

Les règles de l'Éveil sont celles des autres : **1 min**, **10 s d'épuisement**, **6 kills** de charge, le
bouton à droite de la barre du héros ou la touche **T**, et libre en démo.

---

## Le Seigneur Écarlate

### Ce qu'il devient

On le reconnaît tout de suite : même visage calme d'homme adulte, mêmes longs cheveux blancs en queue basse, même
armure de style samouraï à fines plaques de laque rouge sang bordées de noir, même tenue noire ajustée, même long
sabre fin. Mais le démon de sa lame se montre, et c'est spectaculaire :

- Un **masque de démon** (un menpō) de laque rouge et noire lui couvre le **bas du visage**, avec des crocs
  blancs dessinés : on ne voit plus que ses yeux.
- Ses **yeux** sont devenus **rouge écarlate**, à pupille blanche fendue, et une **fine traînée rouge** en part
  vers l'arrière, comme un sillage.
- Sur son front se dresse un **cimier en croissant** (un kuwagata) noir à bord rouge, deux fines cornes de laque
  qui s'écartent : sa seule silhouette de démon.
- Ses **cheveux blancs** flottent plus longs, et leurs **pointes rougissent**, comme trempées dans le sang.
- Dans son **dos flotte une LAME FANTÔME** : un second sabre, blanc et translucide aux bords nets, cerné de rouge,
  pointe en bas, en travers de son dos, qui le suit sans le toucher.
- Son **sabre** a désormais un **fil écarlate** le long du tranchant, et sa **poignée** est tressée de rouge.
- Un **haori court** noir, doublé de rouge, lui tombe des épaules jusqu'à la taille, ses pans fendus en
  **pétales**.

Il reste chibi, de la même taille que le Chevalier : l'Éveil ne le fait pas grandir d'un coup sur l'écran.

### Son trait éveillé : la Lame affûtée

**Ses entailles n'attendent plus.** Tant que dure l'Éveil :
- chaque coup laisse **une entaille de plus** qu'en temps normal ;
- un ennemi porte jusqu'à **8 entailles**, au lieu de 5 ;
- quand un ennemi arrive à **8**, ses entailles **s'ouvrent d'elles-mêmes**, sans attendre la Rengaine, à 18 par
  entaille.

C'est son jeu poussé au bout : il n'a plus besoin de rengainer pour tuer celui qu'il a déjà taillé, et il garde la
Rengaine pour la foule.

### Ses six sorts éveillés

Les chiffres sont des points de départ, jamais mesurés.

| créneau | forme de base | éveillée | ce qu'il fait | chiffres de départ |
|---|---|---|---|---|
| ATTAQUE | Entaille | **Croissant écarlate** | un croissant blanc bordé de rouge part de sa lame et traverse tout le couloir : chaque ennemi touché prend ses entailles | 17 dégâts, portée 6, 0,5 s, 1 entaille (2 avec le trait) |
| SKILL 1 | Pas de Lame | **Pas des Mille Lames** | il file dans le couloir en coupant tout, et sa lame fantôme repasse derrière lui une demi-seconde plus tard | 6 cases, 22 dégâts et 2 entailles, puis l'écho : 12 dégâts et 1 entaille, recharge 8 s |
| SKILL 2 | Garde | **Garde du Seigneur** | pendant 2 s, il pare TOUS les coups, et chaque parade riposte autour de lui | 2 s, riposte 30 en rayon 2, 2 entailles, recharge 11 s |
| SKILL 3 | Rengaine | **Rengaine écarlate** | il rengaine : toutes les entailles de l'écran éclatent, et chaque éclat projette des pétales-lames sur les voisins | portée 12, 22 par entaille, éclat 1 entaille aux voisins à 1,5 case, recharge 9 s |
| FUITE | Volte-face | **Danse des pétales** | il saute en arrière, et à sa place reste un tourbillon de pétales-lames qui attire les ennemis puis les entaille tous | 5 cases, tourbillon 0,8 s, 24 dégâts en rayon 1,5, 2 entailles, recharge 9 s |
| EXTRA | Dernière Rengaine | **Nuit Écarlate** | le monde passe en noir et rouge, une immense lune rouge se lève, de grandes coupes traversent l'écran, chaque ennemi reçoit 8 entailles, il rengaine, et tout s'ouvre | 1,2 s, puis 22 par entaille |

L'Extra garde sa charge de kills : l'Éveil change le sort, il ne le rend pas gratuit.

**Les boss** reçoivent les entailles et les dégâts comme les autres, et la Danse des pétales ne les attire pas.

### Ce qu'on doit voir à l'écran (peint au shader)

Dans sa palette : le blanc de ses coupes, l'acier, l'écarlate qui borde chaque trait, le sombre et le noir qui cerne.
Net, à plages franches ; un effet se réduit au lieu de s'estomper ; ce qui est grand passe sous lui ou reste creux
au centre.

| moment | effet |
|---|---|
| **Le geste d'Éveil** (0,8 s) | des pétales blancs tourbillonnent autour de lui et rougissent un à un, puis une coupe verticale fend l'air au-dessus de lui : la lame fantôme en sort |
| **L'éclosion** | une gerbe de pétales part de lui, une croix de coupes rouges s'ouvre au sol, et l'écran claque |
| **Pendant l'Éveil** | un cercle de coupes tourne à ses pieds, des pétales tombent lentement autour de lui |
| **La Lame affûtée** | quand un ennemi arrive à 8 entailles, elles s'illuminent toutes, et s'ouvrent en étoile rouge |
| **Croissant écarlate** | un croissant blanc à bord rouge qui file dans le couloir, et une ligne nette sur chaque ennemi traversé |
| **Pas des Mille Lames** | un trait blanc suit le couloir, puis un second trait rouge repasse dessus, plus fin |
| **Garde du Seigneur** | un cercle de lames tourne autour de lui ; chaque parade claque en étoile à quatre branches et lance un cercle de coupe |
| **Rengaine écarlate** | les entailles s'allument dans tout l'écran, un silence, puis elles éclatent ensemble en étoiles rouges, et des pétales-lames filent vers les voisins |
| **Danse des pétales** | un tourbillon de pétales-lames blancs reste à sa place, se resserre, puis éclate en coupes |
| **Nuit Écarlate** | l'écran passe en noir et rouge, une immense lune rouge se lève derrière lui, de grandes coupes blanches traversent l'écran, puis les couleurs reviennent dans l'éclat |

---

## Image 1 — le modèle du Seigneur

Joindre `assets/peso&cover/refonte/ecarlate.png` (le Chevalier Écarlate, qu'il faut garder reconnaissable, et la
mise en page à reprendre).

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe montre le Chevalier Écarlate, un bretteur humain : c'est LA MÊME personne, que tu
dois transformer, pas remplacer. Le démon de sa lame se montre. Reprends aussi sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le masque de démon, les yeux rouges et le cimier en croissant se voient
   bien, la poignée de la lame fantôme dépasse derrière son épaule
2. vue DE DOS, immobile : la LAME FANTÔME se voit en entier, en travers de son dos, au-dessus du
   haori ; la queue de cheveux blancs aux pointes rouges
3. vue DE PROFIL, TOURNÉE VERS LA DROITE, immobile : le masque, une corne du cimier, la lame
   fantôme derrière lui

LE PERSONNAGE — le Chevalier Écarlate ÉVEILLÉ en SEIGNEUR ÉCARLATE, un homme ADULTE et HUMAIN. On
le reconnaît tout de suite : même peau claire, mêmes longs CHEVEUX BLANCS (#f4f1ec) en queue basse,
même armure de style samouraï à fines plaques de LAQUE UNIE ROUGE SANG (#b81414) aux bords NOIRS
(#17171a), mêmes épaulières en lamelles, même tenue noire ajustée et hauts solerets noirs, même
fourreau noir à la hanche gauche, même long sabre fin à lame d'acier clair (#d9dee3). Ce qui
change :
- un MASQUE DE DÉMON (menpō) de laque rouge et noire lui couvre le BAS DU VISAGE, avec des crocs
  blancs dessinés : on ne voit plus que ses yeux ;
- ses YEUX sont ROUGE ÉCARLATE (#e01a1a), à pupille blanche fendue ;
- sur son front se dresse un CIMIER EN CROISSANT (kuwagata) : deux fines cornes de laque noire à
  bord rouge, qui s'écartent en V, COURTES ;
- les POINTES de ses cheveux blancs ROUGISSENT, comme trempées dans le sang ;
- dans son DOS flotte une LAME FANTÔME : un second sabre BLANC (#fff6ee), à bords nets, cerné d'un
  filet ROUGE, en travers de son dos, pointe vers le bas, qui ne le touche pas ;
- son sabre a un FIL ÉCARLATE le long du tranchant, et sa poignée est tressée de rouge ;
- un HAORI COURT noir doublé de rouge lui tombe des épaules jusqu'à la TAILLE, ses pans fendus en
  forme de PÉTALES.
Toutes ses formes sont cernées d'un contour très foncé (#17171a), net.

⚠️ RÈGLE BLOQUANTE — LE ROUGE EST FRANC, SANS AUCUN BLEU, ni rose, ni violet, ni bordeaux prune,
aucun reflet du fond magenta. Ses blancs sont des blancs chauds.

⚠️ RÈGLE BLOQUANTE — IL EST CALME ET MENAÇANT : posture droite, la main droite posée sur la
poignée de son sabre rengainé, regard froid au-dessus du masque. Aucun air mignon.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI, À LA MÊME
TAILLE. Posé à côté du Chevalier, il fait la même hauteur : le cimier dépasse au-dessus de sa tête
de moins d'un tiers de tête.

⚠️ RÈGLE BLOQUANTE — LA LAME FANTÔME RESTE DANS SA SILHOUETTE. En travers de son dos, elle ne
dépasse pas de plus d'un tiers de la largeur du corps de chaque côté, et pas plus haut que sa tête.

⚠️ RÈGLE BLOQUANTE — AUCUNE LUEUR FLOUE, aucun halo, aucune étincelle, aucun pétale volant autour de
lui : la lame fantôme est un aplat blanc net, cerné de rouge et de noir.

⚠️ RÈGLE BLOQUANTE — LE HAORI S'ARRÊTE À LA TAILLE : les deux jambes et les deux solerets se voient,
séparés l'un de l'autre, même en très petit.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même
masque, même cimier, même lame fantôme.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Un rouge qui tire sur le rose ou le prune | Le détourage lui retirerait son rouge |
| Une lueur floue autour de la lame fantôme | Une frange resterait au détourage |
| La lame fantôme dépasse largement de sa silhouette | Elle déborderait des cases de marche, et il serait réduit |
| Des pétales qui volent autour de lui | Le détourage les jetterait ou les garderait en morceaux flottants |
| Plus de cheveux blancs ni d'armure laquée | Ce serait une autre personne, pas un Éveil |
| Il est plus grand que le Chevalier | Il ne doit pas changer de taille en s'éveillant |

---

## Image 2 — la marche

Joindre `assets/peso&cover/refonte/ecarlate_eveil.png` en PREMIER, puis
`docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son masque, son cimier, ses cheveux,
sa lame fantôme, son armure, son haori, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, lame fantôme comprise, et occupe environ
  90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Chevalier Écarlate éveillé en SEIGNEUR ÉCARLATE, un homme adulte et humain, en
proportions CHIBI : longs CHEVEUX BLANCS en queue basse aux pointes rouges, MASQUE DE DÉMON rouge
et noir sur le bas du visage, YEUX ROUGES, CIMIER EN CROISSANT noir à bord rouge, armure samouraï à
plaques de LAQUE ROUGE SANG bordées de noir, tenue noire, HAORI COURT noir doublé de rouge jusqu'à
la taille, sabre rengainé au fourreau noir à sa hanche gauche, et une LAME FANTÔME blanche cernée
de rouge qui flotte en travers de son dos. Contour très foncé net.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. Sa hauteur totale,
cimier compris, est la même dans les 24 cases.

Il MARCHE d'un pas souple et silencieux, comme un bretteur qui s'approche de son adversaire. IL NE
COURT PAS : le buste reste DROIT, le menton haut, les genoux restent bas. La lame fantôme reste en
travers de son dos. Les cheveux et les pans du haori bougent un peu différemment à chaque image.

SES BRAS BALANCENT FRANCHEMENT, EN OPPOSITION AUX JAMBES : quand une jambe part vers l'avant,
le bras du côté opposé part vers l'avant lui aussi, puis ils échangent. Le coude plie, l'avant-bras
pivote, et la main suit avec un léger temps de retard. Les bras ne restent JAMAIS figés le long
du corps. Ses mains sont libres : le sabre reste dans son fourreau.

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

⚠️ RÈGLE BLOQUANTE — LE HAORI NE CACHE JAMAIS LES JAMBES : les deux solerets se voient dans les
24 cases.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES, LES BRAS, LES CHEVEUX ET LES PANS DU HAORI BOUGENT. Dans
une même rangée, la tête, le masque, le cimier, le tronc et la lame fantôme se superposent
exactement d'une case à l'autre, et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LA LAME FANTÔME TIENT DANS LA CASE : pas plus d'un tiers de la largeur du corps
de chaque côté, et pas plus haut que sa tête.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — LE ROUGE EST FRANC, SANS AUCUN BLEU ; aucun rose, aucun violet, aucun reflet
du fond magenta.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun pétale, aucune particule.
```

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/ecarlate_eveil.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT son masque, son cimier, ses cheveux, sa lame fantôme, son armure,
son haori, son sabre, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Chevalier Écarlate éveillé en SEIGNEUR ÉCARLATE, un homme adulte et humain, en
proportions CHIBI : cheveux blancs en queue basse aux pointes rouges, masque de démon rouge et noir,
yeux rouges, cimier en croissant, armure samouraï de laque rouge sang bordée de noir, haori court
noir doublé de rouge, fourreau noir à la hanche gauche, lame fantôme blanche cernée de rouge en
travers du dos. Un long sabre fin à lame d'acier clair (#d9dee3) au fil écarlate, COURT par rapport
à la case : il ne la dépasse jamais. Contour très foncé net.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il coupe VERS LE BAS DE L'IMAGE, face au joueur. La lame descend DROIT DEVANT lui, le
  long de l'axe du corps, jamais sur le côté
- rangée 2 : il coupe VERS LE HAUT DE L'IMAGE, de dos. La lame part droit devant lui et monte
  au-dessus de sa tête, le long de l'axe du corps, jamais sur le côté
- rangée 3 : il coupe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle : il dégaine
et coupe d'un seul trait, comme un maître du iaido.
1. posture prête, la main droite sur la poignée, le sabre rengainé
2. il tire le sabre à moitié du fourreau, le buste ramassé
3. le sabre sort entier, armé près de l'épaule
4. L'IMPACT : la coupe, bras et lame tendus dans la direction de la rangée
5. la lame reste tendue, immobile
6. il ramène lentement le sabre vers le fourreau
7. la lame rentre à moitié dans le fourreau
8. il retrouve exactement sa pose de marche, le sabre rengainé

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE. Le corps reste CENTRÉ dans sa
case : c'est le CORPS qu'on centre, jamais l'ensemble corps et sabre.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ, AUCUNE TRAÎNÉE DE COUPE, ni arc, ni éclat, ni pétale. Le JEU
dessine lui-même la coupe.

⚠️ RÈGLE BLOQUANTE — LA LAME FANTÔME NE BOUGE PAS dans son dos, et ne dépasse pas d'un tiers de la
largeur du corps de chaque côté.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds restent à plat
pendant tout le geste, à la même place.

⚠️ RÈGLE BLOQUANTE — LE ROUGE EST FRANC, SANS AUCUN BLEU, aucun reflet du fond magenta.

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

PERSONNAGE : le Chevalier Écarlate éveillé en SEIGNEUR ÉCARLATE, un bretteur démon dont les coupes
s'ouvrent quand il rengaine. Ses couleurs sont le BLANC CHAUD (#fff6ee), l'ACIER (#d9dee3), le
ROUGE ÉCARLATE FRANC SANS BLEU (#b81414), le rouge sombre (#5e0a0a) et le NOIR, avec un CONTOUR
TRÈS FONCÉ net autour de chaque forme. Le motif commun des six icônes est la COUPE BLANCHE BORDÉE
DE ROUGE et le PÉTALE : ils doivent se retrouver dans chacune.

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

1. CROISSANT ÉCARLATE — un grand croissant de coupe blanc bordé de rouge qui file en diagonale et
   traverse trois petites silhouettes noires, chacune barrée d'un trait.

2. PAS DES MILLE LAMES — un trait de coupe blanc qui file droit, doublé juste derrière par un
   second trait rouge plus fin, avec un sabre fantôme blanc au bout.

3. GARDE DU SEIGNEUR — un sabre tenu à l'horizontale devant un cercle de lames qui tourne, et une
   étoile à quatre branches qui claque sur le tranchant.

4. RENGAINE ÉCARLATE — un sabre qui rentre dans son fourreau noir, et autour de lui des entailles
   rouges qui éclatent en étoiles, avec des pétales.

5. DANSE DES PÉTALES — un tourbillon de pétales blancs tranchants bordés de rouge, avec une flèche
   courbe qui saute en arrière.

6. NUIT ÉCARLATE — une immense LUNE ROUGE pleine, barrée de deux grandes coupes blanches en croix,
   avec des pétales qui tombent devant. C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas d'ombre portée, pas de cadre, pas de texte,
pas de chiffre, pas de flou, aucune lueur floue, aucune case vide, AUCUN ROSE, AUCUN VIOLET, AUCUN
ROUGE QUI TIRE SUR LE BLEU dans les icônes : ils se confondraient avec le fond magenta. Le rouge est
FRANC, comme du sang. Ce sont des SYMBOLES, pas des scènes.
```

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la découper.
