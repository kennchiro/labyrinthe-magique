# L'Ange de la Mort — images à générer et effets visuels

> Élément **Mort** · teinte du jeu `#e2382a` · noir bleuté, os et rouge braise.
> Un ange déchu, un peu démoniaque : ce qu'il a blessé, il vient le prendre.

Cinq images, **dans cet ordre** : la première sert de modèle aux autres.

| # | image | prompt | à déposer dans `assets/peso&cover/` | images à joindre |
|---|---|---|---|---|
| 1 | le modèle du personnage | ci-dessous | `refonte/mort.png` | `refonte/lumiere.png` |
| 2 | la marche | [mages_animes/mort](../mages_animes/mort.md), prompt 1 | `mages/mort_marche.png` | `refonte/mort.png` et `guide_marche.png` |
| 3 | l'attaque | [mages_animes/mort](../mages_animes/mort.md), prompt 2 | `mages/mort_attaque.png` | `refonte/mort.png` |
| 4 | les six icônes de sorts | [sorts/icones_mort](../sorts/icones_mort.md) | `sorts/mage_mort_skills.png` | aucune |
| 5 | le portrait du menu | [menu/portrait_mort](../menu/portrait_mort.md) | `interface/portraits/portrait_mort.png` | `ref_carte.png` et `refonte/mort.png` |

Vérifier chaque image avant de passer à la suivante : un défaut du modèle se retrouve sur
les deux planches. **La faux et les ailes sont les premiers points à regarder.**

**Aucune image à demander pour les effets de ses sorts** : ils seront peints au shader,
comme ceux des autres mages. La dernière partie de cette page les décrit en détail.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/lumiere.png`, seulement pour le style et la mise en page.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, effets lumineux, même facture que les sprites d'un jeu
de rôle mobile. L'image jointe sert UNIQUEMENT de référence de style, de proportions et de
mise en page : ne copie ni son personnage, ni ses couleurs, ni ses objets.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vu DE FACE, immobile : le visage se voit bien, le haut des ailes dépasse derrière les épaules
2. vu DE DOS, immobile : les deux ailes à demi repliées se voient en entier
3. vu DE PROFIL, TOURNÉ VERS LA DROITE, immobile : une seule aile se voit, derrière son dos

LE PERSONNAGE — l'Ange de la Mort, un ange déchu à l'allure un peu démoniaque. Deux GRANDES
AILES de plumes noires, déchirées et effilochées au bout, à demi repliées dans son dos. Deux
PETITES CORNES noires courbes sortent de son front, et une AURÉOLE BRISÉE rouge braise, ouverte
comme un anneau fendu, flotte au-dessus de sa tête. Visage pâle couleur d'os, bien visible, aux
yeux rouge braise, et cheveux noirs mi-longs. Armure sombre gris anthracite à liserés couleur
d'os, sur une longue robe noire déchirée au bas, bottes noires griffues. Il tient de la main
droite une grande FAUX au manche d'os, dont la lame noire est bordée de rouge braise. Corps
COMPACT, tête un peu large, silhouette lisible en très petit. L'aura reste COLLÉE au corps : pas
de halo large, pas de fumée, pas de particules autour.

⚠️ RÈGLE BLOQUANTE — UN ANGE D'ABORD, UN DÉMON ENSUITE. Les plumes des ailes et l'auréole brisée
disent l'ange ; les petites cornes et les griffes des bottes sont le seul côté démon. Pas d'ailes
de chauve-souris, pas de peau rouge, pas de queue, pas de crocs, pas de grandes cornes.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES. Jamais déployées. Elles ne dépassent
pas de plus d'un quart de la largeur du corps de chaque côté, et leurs pointes s'arrêtent au
niveau des genoux. Le personnage devra marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — LA FAUX RESTE DANS LA CASE. Tenue droite, lame en haut, et la lame recourbée
ne dépasse pas de plus d'un quart de la hauteur du corps au-dessus de sa tête.

⚠️ RÈGLE BLOQUANTE — UN FIN LISERÉ CLAIR COULEUR D'OS autour de toutes les formes noires, plumes
comprises : il doit rester lisible sur un sol très sombre.

⚠️ RÈGLE BLOQUANTE — LES COULEURS. Le noir reste NEUTRE ou BLEUTÉ, le rouge reste ORANGÉ, couleur
de braise. Aucun violet, aucun rose, aucun reflet du fond magenta sur les plumes ou l'armure.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
ailes, mêmes cornes, même auréole brisée, même faux, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Il ressemble à un démon plutôt qu'à un ange | Tu l'as voulu « un peu » démon, et il va dans l'onglet Ange |
| Les ailes sont déployées ou très larges | Il deviendrait bien plus large que les autres, et ses ailes passeraient sur les murs |
| La lame de la faux est coupée ou très haute | Elle fausserait le calage du corps, comme la lance du Porte-Lumière l'a fait |
| Des reflets violets ou roses sur le noir | Le détourage y ferait des trous, et il se confondrait avec le Sorcier des Ténèbres |
| Pas de liseré clair | Il disparaîtrait sur les stages sombres |
| Le rouge vire à l'écarlate vif | Il se lirait comme le Mage du Feu |

---

## Ses six sorts

Ce sont les règles que je propose ; les chiffres seront réglés à l'équilibrage.

| créneau | sort | ce qu'il fait |
|---|---|---|
| Trait | Sentence | un ennemi qu'un coup fait passer sous 15 % de ses PV meurt sur le coup |
| ATTAQUE | Croissant noir | la faux lance un croissant qui vise et ne rate jamais |
| SKILL 1 | Moisson | un grand coup de faux en arc devant lui ; le seuil de la Sentence y monte à 35 % |
| SKILL 2 | Glas | une cloche sonne à ses pieds : les ennemis du cercle sont marqués et prennent plus de dégâts |
| SKILL 3 | Âmes captives | chaque ennemi tué lui donne une âme ; le sort les lâche, et elles traquent dans les couloirs |
| FUITE | Passage | il se défait en plumes noires et traverse les haies sur quelques cases |
| EXTRA | L'Heure dernière | éclipse, une faux géante traverse l'écran : tous les ennemis perdent la moitié de leurs PV |

Il reste un mage d'attaque : la Sentence récompense le coup de grâce, les âmes récompensent
les kills. Aucune Sentence ne s'applique aux repaires.

---

## Les effets visuels, sort par sort

Ce sont les consignes des shaders que j'écrirai quand il sera branché. Les durées et les tailles
sont des cibles : l'équilibrage et ton essai en jeu peuvent les changer.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| La braise | `#ff6a2b` | cœur des coups, instant de l'impact |
| Le rouge | `#e2382a` | matière principale des lames et des anneaux |
| Le rouge sombre | `#7a1414` | creux et dégradé vers le bord |
| Le noir | `#14131c` | plumes, fumée, lame |
| L'os | `#e6dfca` | âmes, liseré qui tient sur les sols sombres |

Trois règles pour tous : le dessin est **net, à plages franches**, comme les autres effets peints.
Le noir a toujours un **liseré d'os ou de rouge**, sinon il disparaît sur les stages sombres. Et
aucun violet, pour ne pas le confondre avec le Sorcier des Ténèbres et la Peste.

### Croissant noir (attaque)

- **Vol :** un croissant de lame noir, bordé de rouge braise, qui tourne légèrement sur lui-même.
  Deux ou trois plumes noires s'en détachent.
- **Impact, 0,3 s :** une entaille rouge en diagonale qui se referme, et quelques braises.

### La Sentence

C'est l'effet qui fait le personnage : l'achèvement doit claquer et se lire d'un coup d'œil.

- **Temps 1, 0,1 s :** l'ennemi vire au noir d'un coup, avec une silhouette liserée de rouge.
- **Temps 2, 0,15 s :** une grande entaille rouge le traverse en diagonale.
- **Temps 3, 0,4 s :** il se défait en plumes noires et en braises, et une petite âme couleur d'os
  monte de sa case puis file vers le mage.

### Moisson, 0,45 s

- **Armé, 0,1 s :** une lueur rouge court le long de la lame.
- **Fauche, 0,15 s :** un large arc de lame noire et rouge balaie devant lui, épais au tranchant et
  effiloché à l'arrière, avec une traînée de plumes.
- **Fin, 0,2 s :** l'arc se dissout en braises qui retombent au sol.
- **Ennemis touchés :** une entaille sur chacun ; sous le seuil, leur Sentence se joue.

### Glas

- **Ouverture, 0,3 s :** une cloche fantôme couleur d'os apparaît au-dessus de lui et sonne ; un
  anneau rouge s'élargit au sol jusqu'au bord du cercle.
- **Vie :** à chaque coup de cloche, une onde rouge repart du centre, et de fines volutes noires
  montent du sol.
- **Ennemi marqué :** une petite cloche noire liserée de rouge flotte au-dessus de sa tête.
- **Fin :** la cloche se fend et s'efface, et l'anneau se referme.

### Âmes captives

- **Tant qu'il en porte :** de petites flammes couleur d'os tournent lentement autour de lui, une
  par âme, trois au plus.
- **Lâcher, 0,2 s :** elles partent d'un coup en laissant un filet pâle, et poussent un visage
  creux à peine dessiné.
- **Chasse :** elles filent par les couloirs en ondulant, et leur traînée s'efface vite.
- **Impact, 0,3 s :** l'âme s'écrase en anneau pâle sur l'ennemi et lui mord ses PV.

### Passage

- **Départ, 0,2 s :** son corps se défait en une gerbe de plumes noires, de haut en bas.
- **Trajet :** un nuage de plumes et de fumée noire bas sur le sol relie le départ à l'arrivée, à
  travers les haies, avec des braises dedans.
- **Arrivée, 0,25 s :** les plumes convergent et reforment son corps, et une petite onde rouge part
  au sol.

### L'Heure dernière (ultime)

- **Temps 1, 0,5 s :** le décor s'assombrit jusqu'au noir-rouge, comme une éclipse ; il lève la
  faux, ses ailes s'ouvrent, et son auréole brisée s'embrase.
- **Temps 2, 0,7 s :** **une faux géante traverse tout l'écran** d'un bord à l'autre, à contre-jour
  sur un disque rouge, en laissant une longue entaille lumineuse.
- **Temps 3, 0,5 s :** derrière la lame, chaque ennemi touché reçoit son entaille rouge, l'un après
  l'autre. Ceux que le coup fait passer sous le seuil jouent leur Sentence.
- **Temps 4 :** l'éclipse se retire depuis l'entaille, et des plumes noires et des braises retombent
  doucement.

---

## Quand les images sont là

Il suffit de les déposer et de me le dire : je les découpe, je contrôle chaque planche et je
programme le personnage et ses effets.
