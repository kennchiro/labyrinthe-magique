# L'Archange du Ciel — fiche et modèle du personnage

> Élément **Ciel** · teinte du jeu `#34e07a` · blanc, or et émeraude. Onglet **Ange**.
> Il domine le labyrinthe : ses coups tombent du ciel par-dessus les haies, et il s'envole au-dessus des murs.

✅ **Programmé et jouable depuis le 2026-11-03.** Les cinq images sont arrivées et découpées. Ses sorts et leurs
effets peints sont en jeu, et ses chiffres ne sont réglés que sur la passe rapide. Le générateur a dessiné une cloche à
la place de la trompette : le sort est devenu la Cloche céleste.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle | ci-dessous | `refonte/ciel.png` | `refonte/chrono.png` |
| 2 | La marche | [mages_animes/ciel](../mages_animes/ciel.md), prompt 1 | `mages/ciel_marche.png` | `refonte/ciel.png` et `guide_complet.png` |
| 3 | L'attaque | [mages_animes/ciel](../mages_animes/ciel.md), prompt 2 | `mages/ciel_attaque.png` | `refonte/ciel.png` |
| 4 | Les six icônes | [sorts/icones_ciel](../sorts/icones_ciel.md) | `sorts/mage_ciel_skills.png` | aucune |
| 5 | Le portrait du menu | [menu/portrait_ciel](../menu/portrait_ciel.md) | `interface/portraits/portrait_ciel.png` | `ref_carte.png` et `refonte/ciel.png` |

Vérifier chaque image avant de passer à la suivante : un défaut du modèle se retrouve sur
les deux planches. **La largeur des ailes et la longueur de la lance sont les premiers points à
regarder** : il doit tenir dans un couloir et dans sa case.

**Aucune image à demander pour les effets de ses sorts** : ils seront peints au shader,
comme ceux des autres mages. La dernière partie de cette page les décrit en détail.

## Identité visuelle

Un jeune archange au visage visible, en armure légère blanche et or, avec un tabard émeraude et deux
grandes ailes blanches aux pointes émeraude. Il porte une lance d'or et une cloche d'or à la ceinture.
Un diadème d'or à deux petites ailes le reconnaît de loin, même en très petit.

Il se distingue des quatre autres anges :

| ange | couleurs | silhouette |
|---|---|---|
| Porte-Lumière | blanc chaud et or | robe, lance de lumière |
| Ange de la Mort | noir, os et rouge | faux |
| Ange des Étoiles | bleu nuit et argent | robe longue, sceptre |
| Archange d'Acier | gris-bleu | heaume fermé, marteau, ailes de lames |
| **Archange du Ciel** | **blanc, or et émeraude** | **visage visible, tabard court, lance et cloche** |

Toutes ses couleurs passent `demagenta` sans changer : aucune n'a à la fois plus de rouge et plus de bleu
que de vert. Pas de `despilled` sur lui, il repeindrait le blanc de ses ailes.

⚠️ L'émeraude reste loin du turquoise du Chronomancien (`#2fd6b8`) et du vert acide de la Peste (`#b4f02a`) :
c'est le blanc et l'or qui dominent sur lui, l'émeraude ne fait qu'accentuer.

## L'idée

Tous les autres héros se battent dans les couloirs. Lui les voit d'en haut : ses coups passent par-dessus
les haies, et sa fuite l'emmène au-dessus des murs. En échange, il est fragile et frappe court.

**Le coup à placer :** frapper par-dessus une haie un ennemi qui ne peut pas le rejoindre, et s'envoler
au-dessus du mur quand la meute arrive par le couloir.

## Son trait : Vue d'en haut

Ses sorts qui visent un ennemi mesurent leur portée **à vol d'oiseau**, et non en distance de chemin : ils
touchent un ennemi derrière une haie. C'est la règle qu'aucun autre héros n'a en dehors des ultimes, et elle
doit se voir : chaque coup tombe du ciel, jamais en ligne droite le long du couloir.

## Ses six sorts

Ce sont les chiffres du jeu (`CharacterCatalog.ciel()`). Ils ne sont réglés que sur la passe rapide.
L'attaque est passée de 17 à 18 dégâts : à 17, la Mort et la Foudre le dominaient sur le papier.

| créneau | sort | ce qu'il fait | chiffres de départ |
|---|---|---|---|
| Base | | 3 PV, vitesse 5,2, extra à 4 kills (la règle du jeu) | |
| ATTAQUE | **Lance céleste** | une lance de lumière tombe du ciel sur l'ennemi le plus proche, même derrière une haie | 18 dégâts, portée 6 à vol d'oiseau, 0,55 s |
| SKILL 1 | **Plumes-lames** | ses ailes lâchent un éventail de 5 plumes tranchantes devant lui, qui passent au-dessus des haies | 22 par plume, portée 5, recharge 5 s |
| SKILL 2 | **Colonne du ciel** | un pilier de lumière s'abat sur l'ennemi visé et cloue ceux qui l'entourent | 40 dégâts, rayon 1,5, cloue 2 s, portée 7, recharge 9 s |
| SKILL 3 | **Cloche céleste** | sa cloche sonne, et une onde part de lui et étourdit tous les ennemis autour, haies comprises | 10 dégâts, rayon 4, étourdit 1,5 s, recharge 12 s |
| FUITE | **Envol** | il s'élève 3 s, vole par-dessus les haies sans pouvoir être touché, puis retombe avec une onde | 3 s, vitesse x 1,4, onde de 20 dégâts, recharge 12 s |
| EXTRA | **Jugement des Six Ailes** | six ailes de lumière s'ouvrent dans son dos, et des épées tombent sur chaque ennemi à l'écran | 12 épées sur 3 s, 45 chacune, traverse les murs |

**Les règles de l'Envol :** il ne passe jamais l'enceinte du labyrinthe. S'il retombe sur une haie, il glisse
vers la case de sol la plus proche. Il ne ramasse ni gemme ni potion en vol, et ne prend pas les portails.

**Les boss** ne sont ni cloués ni étourdis : ils subissent seulement les dégâts.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/chrono.png`, pour le style, la mise en page et surtout LES PROPORTIONS.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe sert UNIQUEMENT de référence de style, de proportions et de mise en page :
ne copie ni son personnage, ni ses couleurs, ni ses objets.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile : le visage se voit bien, le haut des ailes dépasse derrière les épaules
2. vue DE DOS, immobile : les deux ailes, repliées, se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : une seule aile se voit, derrière son dos

LE PERSONNAGE — l'Archange du Ciel, un jeune archange guerrier au visage calme et décidé,
bien VISIBLE, aux yeux émeraude (#34e07a). Cheveux blancs courts, en mèches qui se soulèvent.
Sur le front, un DIADÈME D'OR (#f2c14e) orné de deux petites ailes dorées sur les tempes.
ARMURE LÉGÈRE blanche (#f4f7f2) à bords dorés : cuirasse courte, petites épaulières dorées
arrondies, brassards et bottes blanches à bords dorés. Par-dessus, un TABARD COURT émeraude
(#1f9e5a) à liseré d'or, qui s'arrête AU-DESSUS DES GENOUX et s'ouvre entre les jambes. Deux
GRANDES AILES de plumes BLANCHES, dont les pointes passent à l'émeraude, REPLIÉES dans son
dos. Il tient de la main droite une LANCE D'OR à pointe blanche, droite, la pointe en l'air,
pas plus haute que lui. Une petite CLOCHE D'OR pend à sa ceinture, sur la hanche gauche.
Toutes ses formes claires sont cernées d'un contour vert très sombre (#10261c), net, qui les
détache des sols clairs.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI. Sa hauteur
totale vaut 2,5 TÊTES : la tête (cheveux et diadème compris) occupe près de 40 % de la hauteur,
et les jambes à peine un quart. Grosses mains, gros pieds, torse court. Jamais de corps élancé,
de longues jambes ou de petite tête : posé à côté du personnage de l'image jointe, il a la même
morphologie.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT REPLIÉES. Jamais déployées. Elles ne dépassent pas de
plus d'un quart de la largeur du corps de chaque côté, leurs pointes du haut ne montent pas
plus haut que le sommet de sa tête, et celles du bas s'arrêtent au niveau des genoux. Le
personnage devra marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — LA LANCE TIENT DANS LA CASE. Elle est tenue droite, contre le corps, et
sa pointe ne dépasse pas le sommet de sa tête de plus d'une demi-tête.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT. Le tabard s'arrête au-dessus des
genoux, aucune cape ni robe longue : les deux jambes et les deux bottes se voient clairement,
séparées l'une de l'autre.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond. Le
blanc des ailes et de l'armure reste blanc, avec des ombres gris-vert, jamais roses ou mauves.

⚠️ RÈGLE BLOQUANTE — AUCUNE MAGIE sur cette image : ni halo, ni auréole lumineuse, ni lueur
autour de la lance, ni particule, ni plume qui vole.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
ailes, même diadème, même lance, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le corps est élancé, ou la tête petite | Il ne ressemblerait pas aux mages : à regénérer sans attendre |
| Les ailes sont ouvertes ou très larges | Il deviendrait bien plus large que les autres, et ses ailes passeraient sur les murs |
| La lance dépasse loin au-dessus de la tête | Elle serait coupée sur toutes les planches suivantes |
| Le tabard ou une cape cache les jambes | Il glisserait en marchant : le défaut déjà vu sur les anges |
| Des ombres roses ou mauves dans le blanc | Le détourage y ferait des trous, et une frange rose resterait |
| Il ressemble au Porte-Lumière | Il doit montrer l'émeraude du tabard et des pointes d'ailes, et le diadème ailé |
| Un halo ou une auréole lumineuse | Le jeu dessine lui-même ses sorts |

---

## Les effets visuels, sort par sort

Ce sont les consignes qu'ont suivies ses shaders (`assets/shaders/ciel_*`). La planche de contrôle
`tools/preview_ciel.gd` les montre à six instants de leur vie.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le pâle | `#f4fff8` | cœur des lances et des colonnes, instant de l'impact |
| L'émeraude | `#34e07a` | matière principale : traînées, ondes, sceaux |
| Le profond | `#0f7a4a` | creux, dégradé vers le bord |
| L'or | `#f2c14e` | pointes, plumes, éclats |
| Le cerne | `#10261c` | contour qui tient sur les sols clairs |

Mêmes règles que les autres anges : un dessin **net, à plages franches**, un effet qui **se réduit au lieu
de s'estomper**, et tout effet posé au sol est **cerné**. Ce qui tombe du ciel se voit **avant** de toucher :
c'est ce qui dit au joueur que le coup a passé la haie.

### Lance céleste (attaque)

- **Le signal, 0,15 s :** il lève sa lance, et un petit sceau émeraude s'ouvre au sol sous la cible.
- **La chute, 0,2 s :** une lance de lumière pâle, bordée d'émeraude, tombe à pic sur le sceau, avec une
  courte traînée verticale.
- **L'impact :** un éclat à quatre branches dorées, et le sceau se referme d'un coup.

### Plumes-lames

- **Le départ :** ses ailes s'entrouvrent une fraction de seconde.
- **Le vol :** cinq plumes d'or en éventail, bord émeraude, qui tournent sur elles-mêmes et passent
  au-dessus des haies, avec une ombre au sol qui les suit.
- **L'impact :** une entaille nette, et la plume se brise en trois éclats d'or.

### Colonne du ciel

- **Le signal, 0,3 s :** un cercle émeraude se dessine au sol et se remplit, pour qu'on lise la zone.
- **La chute :** une colonne de lumière pâle s'abat d'en haut, large comme la zone, cernée d'émeraude.
- **Les cloués :** un petit anneau d'or tourne au sol sous chaque ennemi tant qu'il ne peut pas bouger.
- **La fin, 0,3 s :** la colonne se resserre en un trait fin et remonte.

### Cloche céleste

- **Le tintement, 0,15 s :** la cloche s'illumine d'or à sa ceinture et se balance.
- **L'onde :** trois anneaux émeraude, nets et espacés, partent de lui à vol d'oiseau et passent sur les haies.
- **Les étourdis :** trois petites notes d'or tournent au-dessus de leur tête.

### Envol

- **Le départ, 0,25 s :** ses ailes s'ouvrent, une onde de plumes part au sol, et il s'élève.
- **En vol :** il plane au-dessus du labyrinthe, plus grand, avec son ombre au sol qui le suit et marque
  la case où il retombera. Les ennemis ne peuvent pas le toucher.
- **L'atterrissage, 0,3 s :** il retombe dans un anneau émeraude, et quelques plumes retombent après lui.

### Jugement des Six Ailes (extra)

- **Temps 1, 0,5 s :** le décor s'assombrit, et six ailes de lumière émeraude s'ouvrent dans son dos.
- **Temps 2 :** au-dessus de chaque ennemi à l'écran, un sceau d'or apparaît au sol.
- **La pluie, 3 s :** des épées de lumière pâle tombent une à une sur les sceaux, très vite, chacune
  avec un éclat doré.
- **La fin, 0,6 s :** les ailes se replient en plumes qui retombent et s'effacent.

---

## Pour l'essayer

    godot --path . -- --demo --character ciel
