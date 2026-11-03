# Le Chérubin — fiche et modèle du personnage

> Élément **Feu sacré** · teinte du jeu `#3d6bff` · lin blanc, bronze poli et bleu saphir. Onglet **Ange**.
> Le gardien d'Éden : quatre ailes, une épée de flamme qui tournoie, des roues couvertes d'yeux. On ne s'approche
> pas de lui impunément.

✅ **Programmé et jouable depuis le 2026-11-03** (`--demo --character cherubin`). Les cinq images sont arrivées et découpées. Les chiffres ne sont réglés que sur la passe rapide.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle | ci-dessous | `refonte/cherubin.png` | `refonte/chrono.png` |
| 2 | La marche | [mages_animes/cherubin](../mages_animes/cherubin.md), prompt 1 | `mages/cherubin_marche.png` | `refonte/cherubin.png` et `guide_complet.png` |
| 3 | L'attaque | [mages_animes/cherubin](../mages_animes/cherubin.md), prompt 2 | `mages/cherubin_attaque.png` | `refonte/cherubin.png` |
| 4 | Les six icônes | [sorts/icones_cherubin](../sorts/icones_cherubin.md) | `sorts/mage_cherubin_skills.png` | aucune |
| 5 | Le portrait du menu | [menu/portrait_cherubin](../menu/portrait_cherubin.md) | `interface/portraits/portrait_cherubin.png` | `ref_carte.png` et `refonte/cherubin.png` |

Vérifier chaque image avant de passer à la suivante : un défaut du modèle se retrouve sur
les deux planches. **Les quatre ailes sont le premier point à regarder** : repliées et étroites,
elles doivent laisser voir les jambes et tenir dans un couloir.

**Aucune image à demander pour les effets de ses sorts** : ils seront peints au shader,
comme ceux des autres anges. La dernière partie de cette page les décrit en détail.

## D'où il vient

Le chérubin de la Bible, et non l'angelot des tableaux :

- **Genèse 3:24** : Dieu place des chérubins à l'est d'Éden, avec « la flamme de l'épée qui tournoie », pour
  garder le chemin de l'arbre de vie. C'est son rôle : un gardien.
- **Ézéchiel 1 et 10** : chacun a **quatre ailes**, des pieds qui « étincelaient comme du bronze poli », et à côté
  d'eux des **roues dans des roues, couvertes d'yeux**, qui vont droit devant sans se tourner. Au-dessus, la couleur
  du **saphir**.

## Identité visuelle

Un jeune gardien au visage grave et bien visible, en tunique courte de lin blanc, cuirasse et jambières de bronze
poli, ceinture bleu saphir. **Quatre ailes**, en deux paires, blanches aux pointes saphir, avec des **yeux d'or**
stylisés dessinés sur les plumes. Il tient une **épée à flamme bleu saphir**, et une petite **roue d'or** à yeux
est fixée derrière sa tête comme un objet solide.

Il se distingue des cinq autres anges :

| ange | couleurs | silhouette |
|---|---|---|
| Porte-Lumière | blanc chaud et or | robe, lance de lumière |
| Ange de la Mort | noir, os et rouge | faux |
| Ange des Étoiles | bleu nuit et argent | robe longue, sceptre |
| Archange d'Acier | gris-bleu | heaume fermé, marteau, ailes de lames |
| Archange du Ciel | blanc, or et émeraude | tabard, lance et cloche |
| **Chérubin** | **lin blanc, bronze et saphir** | **quatre ailes à yeux, épée de flamme, roue d'or** |

La flamme est **bleu saphir** et non orange : elle ne doit ressembler ni au Feu ni à la Braise. Elle reste plus
profonde que le cyan du Geôlier (`#16e0e8`).

⚠️ **Le bleu ne doit JAMAIS tirer vers le violet.** Un bleu qui a plus de rouge que de vert passe pour le fond
magenta au détourage. Le saphir voulu (`#3d6bff`) a plus de vert que de rouge : `demagenta` ne le touche pas.
Pas de `despilled` sur lui, il repeindrait le lin blanc et le saphir.

## L'idée

Les autres anges aveuglent, achèvent, se placent, encaissent ou frappent de loin. Lui **garde un lieu** : il
punit ce qui l'approche, et son extra ferme un cercle où aucun ennemi n'entre.

**Le coup à placer :** marquer la meute de loin, la laisser venir, et la faire brûler au contact ; puis, quand
elle est trop nombreuse, planter l'épée et tenir le jardin.

## Son trait : Nul n'approche

Chaque coup pose un **œil** sur l'ennemi. Quand un ennemi marqué arrive au contact du Chérubin, l'œil s'embrase
et le brûle, une fois. C'est la seule défense du jeu qui frappe **celui qui approche**, et non celui qu'on vise.

## Ses six sorts

Ce sont les chiffres du jeu (`CharacterCatalog.cherubin()`). Changement par rapport à la proposition : **5 PV, vitesse 4,7, extra à 6 kills** au lieu de 4, 4,9 et 5 — à ces chiffres, le Mage de l'Eau le dominait sur le papier. Sa flamme continue **après sa cible**, jusqu'au bout de sa portée.

| créneau | sort | ce qu'il fait | chiffres de départ |
|---|---|---|---|
| Base | | 5 PV, vitesse 4,7, extra à 6 kills (la règle du jeu) | |
| Trait | **Nul n'approche** | un œil par coup ; l'ennemi marqué qui arrive au contact brûle | 20 dégâts, puis 3 s avant un nouvel œil |
| ATTAQUE | **Flamme du glaive** | un jet de flamme saphir file dans le couloir et brûle tout ce qu'il traverse | 15 dégâts, 5 cases, 0,5 s |
| SKILL 1 | **Glaive tournoyant** | l'épée tourne autour de lui et frappe tout ce qui est à sa portée | 14 par passage, 2 par seconde, rayon 1,5, 4 s, recharge 9 s |
| SKILL 2 | **Roues d'Ézéchiel** | deux roues de feu couvertes d'yeux roulent dans les couloirs, dans deux directions opposées | 30 dégâts, 7 cases chacune, recharge 8 s |
| SKILL 3 | **Ailes voilées** | il se couvre de sa seconde paire d'ailes : intouchable, et ce qui le touche est repoussé | 2 s, repousse de 2 cases, recharge 14 s |
| FUITE | **Comme l'éclair** | il file droit devant, sans tourner, en laissant une traînée de flamme | 5 cases, traînée de 20 dégâts, recharge 9 s |
| EXTRA | **Le Jardin gardé** | il plante l'épée au sol : aucun ennemi n'entre dans le cercle, ceux qui s'y trouvent sont rejetés et brûlent, et il regagne 1 PV | rayon 3, 8 s, 15 dégâts par seconde |

**Les règles du Jardin :** le cercle reste là où l'épée est plantée, il ne suit pas le Chérubin. Un ennemi
rejeté repart du bord. **Les boss** ne sont pas rejetés : ils entrent, et brûlent.

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
2. vue DE DOS, immobile : les QUATRE ailes, repliées, se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : on voit les deux ailes de son côté

LE PERSONNAGE — le Chérubin, le gardien d'Éden de la Bible, un jeune ange au visage grave et
calme, bien VISIBLE, aux yeux bleu saphir (#3d6bff). Cheveux d'or foncé, courts et bouclés. Il
porte une TUNIQUE COURTE de LIN BLANC (#f3efe4) qui s'arrête AU-DESSUS DES GENOUX, une CUIRASSE de
BRONZE POLI (#c9822e) aux reflets clairs, des jambières et des sandales de bronze, et une
CEINTURE BLEU SAPHIR (#2a4fd6) nouée à la taille.
QUATRE AILES, en DEUX PAIRES, blanches aux pointes bleu saphir : la paire du HAUT est repliée
derrière ses épaules, la paire du BAS est repliée plus bas dans son dos et s'arrête AU-DESSUS DES
GENOUX. Sur les plumes, quelques YEUX D'OR stylisés, en amande, à iris saphir, dessinés comme un
motif net et calme, jamais inquiétant.
Il tient de la main droite une ÉPÉE de bronze dont la lame est une FLAMME BLEU SAPHIR : trois tons
de bleu en aplats nets et opaques (bleu pâle presque blanc au cœur, saphir, bleu profond au bord),
aux langues bien dessinées, sans halo ni lueur. La lame est tenue droite, pointe en l'air, pas
plus haute que sa tête.
Derrière sa tête, une petite ROUE D'OR à huit rayons, avec un œil d'or sur sa jante : c'est un
OBJET SOLIDE, posé derrière la tête, pas une auréole lumineuse.
Toutes ses formes claires sont cernées d'un contour bleu-noir très sombre (#141a2e), net, qui les
détache des sols clairs.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI. Sa hauteur
totale vaut 2,5 TÊTES : la tête (cheveux compris, roue non comprise) occupe près de 40 % de la
hauteur, et les jambes à peine un quart. Grosses mains, gros pieds, torse court. Jamais de corps
élancé, de longues jambes ou de petite tête : posé à côté du personnage de l'image jointe, il a la
même morphologie.

⚠️ RÈGLE BLOQUANTE — LES QUATRE AILES RESTENT REPLIÉES. Jamais déployées. Ensemble, elles ne
dépassent pas de plus d'un quart de la largeur du corps de chaque côté. Les pointes du haut ne
montent pas plus haut que le sommet de sa tête, et celles du bas s'arrêtent au-dessus des genoux.
Le personnage devra marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — L'ÉPÉE ET LA ROUE TIENNENT DANS LA CASE. La pointe de la flamme ne dépasse pas
le sommet de sa tête de plus d'une demi-tête, et la roue reste derrière la tête, pas plus large
qu'elle.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT. La tunique s'arrête au-dessus des
genoux, aucune robe longue : les deux jambes et les deux sandales de bronze se voient clairement,
séparées l'une de l'autre.

⚠️ RÈGLE BLOQUANTE — LE BLEU EST UN SAPHIR FRANC, JAMAIS VIOLET NI LAVANDE. AUCUN ROSE, AUCUN
VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond. Le lin blanc s'ombre de gris-beige, jamais de rose
ou de mauve.

⚠️ RÈGLE BLOQUANTE — AUCUNE MAGIE AUTOUR DE LUI : ni halo, ni lueur autour de l'épée, ni particule,
ni plume qui vole. La flamme de l'épée est un dessin net, et rien ne brille autour.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
quatre ailes, même roue, même épée, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le corps est élancé, ou la tête petite | Il ne ressemblerait pas aux mages : à regénérer sans attendre |
| Deux ailes seulement, ou six | Il perd ce qui le distingue des autres anges |
| Les ailes sont ouvertes ou très larges | Il deviendrait bien plus large que les autres, et ses ailes passeraient sur les murs |
| La paire du bas cache les jambes | Il glisserait en marchant : le défaut déjà vu sur les anges |
| Le bleu tire vers le violet ou le lavande | Le détourage y ferait des trous, et une frange rose resterait |
| Une auréole lumineuse ou un halo autour de l'épée | Le jeu dessine lui-même ses sorts |
| Les yeux des ailes sont inquiétants ou trop nombreux | Il doit rester un gardien, pas un monstre |
| La flamme est orange | Il ressemblerait au Feu et à la Braise |

---

## Les effets visuels, sort par sort

Ce sont les consignes qu'ont suivies ses shaders (`assets/shaders/cherubin_*`), `SacredJet` et `EzekielWheel`.
`tools/preview_cherubin.gd` les montre à six instants de leur vie.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le pâle | `#eef3ff` | cœur des flammes, instant de l'impact |
| Le saphir | `#3d6bff` | matière principale : flammes, roues, cercles |
| Le profond | `#1a2f9e` | bord des flammes, creux |
| Le bronze | `#e0a04a` | yeux, rayons des roues, éclats |
| Le cerne | `#141a2e` | contour qui tient sur les sols clairs |

Mêmes règles que les autres anges : un dessin **net, à plages franches**, un effet qui **se réduit au lieu de
s'estomper**, et tout effet posé au sol est **cerné**. La flamme a des **langues dessinées** en trois tons, jamais
une lueur floue.

### Nul n'approche (le trait)

- **L'œil posé :** un petit œil d'or s'ouvre au-dessus de la tête de l'ennemi touché, et reste ouvert.
- **L'œil qui s'embrase :** au contact, l'œil s'écarquille, puis éclate en une gerbe de flamme saphir qui
  enveloppe l'ennemi une demi-seconde.

### Flamme du glaive (attaque)

- **Le geste :** il tend l'épée, et la flamme jaillit de la lame.
- **Le jet :** une langue de flamme saphir à cœur pâle file dans le couloir, en ondulant, et laisse derrière elle
  des flammèches qui retombent.
- **Le bout :** elle s'enroule sur elle-même et s'éteint en se rétractant.

### Glaive tournoyant

- **Le départ :** l'épée quitte sa main et se met à tourner autour de lui.
- **La ronde :** une épée de flamme qui tourne vite, traînant un cercle de feu saphir à moitié ouvert, comme une
  roue. Chaque ennemi touché prend une entaille de flamme.
- **La fin :** l'épée ralentit et revient dans sa main.

### Roues d'Ézéchiel

- **Le départ :** deux roues d'or naissent à ses pieds, une de chaque côté.
- **La course :** chacune roule dans le couloir, une roue dans une roue, la jante couverte d'yeux, entourée
  d'un anneau de flamme saphir. Elles vont droit, sans tourner, comme dans Ézéchiel.
- **L'impact :** l'ennemi touché est traversé d'un éclat d'or, et la roue continue.

### Ailes voilées

- **Le geste :** la seconde paire d'ailes se referme devant lui comme un voile.
- **Le voile :** ses ailes forment une coque blanche aux yeux d'or ouverts, cernée de flamme saphir.
- **Le rejet :** ce qui le touche est repoussé dans une petite onde saphir.

### Comme l'éclair

- **Le départ :** un éclair saphir part de lui, en ligne droite.
- **La traînée :** une ligne de flammes saphir reste au sol sur toute la course, et brûle ce qui s'y trouve.
- **L'arrivée :** ses quatre ailes s'ouvrent une fraction de seconde, puis se replient.

### Le Jardin gardé (extra)

- **Temps 1, 0,5 s :** il lève l'épée, et le décor s'assombrit légèrement.
- **Temps 2 :** il la plante au sol. Un grand cercle de flamme saphir jaillit autour, haut comme une haie, et
  les ennemis qui sont dedans sont projetés au-dehors.
- **Pendant 8 s :** l'épée reste plantée au centre et brûle. Sur le cercle, des yeux d'or s'ouvrent et
  regardent vers l'extérieur ; un ennemi qui s'en approche est repoussé dans une gerbe de flamme.
- **La fin, 0,6 s :** le cercle se resserre jusqu'à l'épée, qui revient dans sa main.

---

## Pour l'essayer

    godot --path . -- --demo --character cherubin
