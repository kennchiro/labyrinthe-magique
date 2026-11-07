# L'Avide, Démon de la Faim — fiche et modèle du personnage

> Élément **Faim** · teinte du jeu `#c8e830` · peau noir d'encre, plaques d'os, lueur vert bile. Onglet **Démon**.
> Un démon pur sang, sans rien d'humain. Une seconde gueule fend son ventre : plus il dévore, plus il grandit.

**Il est jouable** (`--demo --character avide`). Les six images sont livrées ; pour en regénérer une, garder cet
ordre : la première sert de modèle aux autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle | ci-dessous | `refonte/avide.png` | `refonte/dragon.png` (proportions seulement) |
| 2 | La marche | [mages_animes/avide](../mages_animes/avide.md), prompt 1 | `mages/avide_marche.png` | `refonte/avide.png` et `guide_complet.png` |
| 3 | L'attaque | [mages_animes/avide](../mages_animes/avide.md), prompt 2 | `mages/avide_attaque.png` | `refonte/avide.png` |
| 4 | Les pièces | [sorts/pieces_avide](../sorts/pieces_avide.md) | `sorts/avide_pieces.png` | `refonte/avide.png` |
| 5 | Les six icônes | [sorts/icones_avide](../sorts/icones_avide.md) | `sorts/mage_avide_skills.png` | aucune |
| 6 | Le portrait du menu | [menu/portrait_avide](../menu/portrait_avide.md) | `interface/portraits/portrait_avide.png` | `ref_carte.png`, `portrait_fire.png` et `refonte/avide.png` |

## Identité visuelle

⚠️ **Il n'est PAS chibi**, comme le Dragon des Abysses : une créature grande, massive et voûtée. Le Dragon n'est joint
à l'image 1 que pour ces proportions et le trait ; l'Avide n'en reprend ni les écailles, ni le magma, ni les ailes.

Un démon PUR SANG : grand corps voûté, peau noir d'encre, plaques d'OS blanc ivoire sur les épaules, la colonne et les
avant-bras. Petite tête SANS YEUX, deux grandes cornes de bélier enroulées. De très longs bras qui pendent jusqu'aux
genoux, mains à longues griffes. Jambes de bouc pliées vers l'arrière, sabots fendus. Sa marque : **une seconde gueule
VERTICALE qui fend son ventre**, bordée de crocs, avec une lueur vert bile au fond. Des fentes vert bile courent sur sa peau.

- **Pas d'ailes, pas de queue, pas d'écailles** : c'est ce qui le sépare du Dragon au premier regard.
- **Aucun rapport avec le Seigneur Démon**, le boss du stage 10 : ni sa planche, ni son allure. Son pack est sous licence.
- **Le vert bile et les fentes sont des aplats nets et OPAQUES**, sans halo : un halo se détoure mal sur fond magenta.
- **Aucun rose, aucun violet** : son noir tire vers le vert-gris, jamais vers le violet.
- ⚠️ Le vert bile est voisin du vert de la Peste (`#b4f02a`) : c'est sa silhouette noire et os qui l'en distingue.

## Ce qui est programmé

Tout est dans `CombatSystem` (section L'Avide) : la simulation d'équilibrage voit les mêmes règles.

- **Les bouchées** (`_bites`) : un kill en donne une, jusqu'à `BITES_MAX` ; `_hunger_bonus` ajoute 8 % par bouchée au
  coup d'origine, et une fond toutes les `BITE_DECAY` secondes sans manger (jamais pendant le Festin).
- **Sa taille** : le `Level` écoute `bites_changed` et appelle `Player.set_growth` (+6 % par bouchée, x1,8 au Festin).
- **La langue** est un projectile `pierce_line` ; le `Level` l'étire en `Line2D` le long du couloir (`_lash_tongue`).
- **Le Gouffre** (`Kind.GULF`) s'ouvre sous l'ennemi le plus proche, tire d'une case toutes les `GULF_PULL_GAP` secondes
  par les couloirs (`enemy_hauled`), puis mord dans `GULF_BITE_RADIUS`. Les boss ne bougent pas.
- **Dévorer** (`Kind.DEVOUR`) achève sous `execute_below`, jamais un boss. **La Régurgitation** (`Kind.REGURGITATE`)
  lance une boule par bouchée sur les plus proches, ou droit devant, et remet les bouchées à zéro.
- **Le Bond** (`Kind.LEAP`) file droit jusqu'à une haie et sonne à l'arrivée. **Le Festin** (`Kind.FEAST`) avale un
  ennemi toutes les `FEAST_GAP` secondes ; la gueule géante est dessinée DERRIÈRE lui, pour qu'il reste visible.

## L'idée

Les autres démons ont le sang, la possession, l'armure, l'épée, les chaînes, le feu et le hasard. L'Avide a **la faim** :
chaque ennemi tué est une bouchée qui le fait **grandir** et frapper plus fort. Il choisit entre grossir pour devenir
redoutable, ou **tout recracher** d'un coup dans une salve de bile.

## Ses six sorts

| créneau | sort | ce qu'il fait | chiffres de départ |
|---|---|---|---|
| Base | | 5 PV, vitesse 4,5, extra à 6 kills | |
| TRAIT | **Faim insatiable** | chaque ennemi tué est une bouchée : il grandit et frappe plus fort. Sans manger, elles fondent | 5 bouchées au plus · +6 % de taille et +8 % de dégâts chacune · une fond toutes les 10 s |
| ATTAQUE | **Langue-fouet** | une langue noire claque en ligne droite et transperce tout ce qu'elle traverse | 24 dégâts, portée 5, 0,7 s |
| SKILL 1 | **Gouffre béant** | une gueule s'ouvre dans le sol, aspire les ennemis autour, puis se referme sur eux | rayon 3, aspire 2 s, 45 dégâts, recharge 11 s |
| SKILL 2 | **Dévorer** | il saisit l'ennemi le plus proche et l'avale ; un ennemi blessé meurt d'un coup | portée 2, 60 dégâts, achève sous 35 % de ses PV : +1 PV et +1 bouchée, recharge 12 s |
| SKILL 3 | **Régurgitation** | il recrache toutes ses bouchées en boules de bile qui explosent, et rapetisse | une boule par bouchée, 30 dégâts chacune, rayon 1,5, recharge 8 s |
| FUITE | **Bond bestial** | un grand saut en avant ; l'atterrissage fait trembler le sol et sonne autour de lui | 3 cases, sonnés 1 s, rayon 1,5, recharge 11 s |
| EXTRA | **Le Festin** | il devient gigantesque ; la gueule de son ventre s'ouvre en grand et avale les ennemis proches, un à un | 6 s, rayon 6, un ennemi toutes les 0,6 s, 80 dégâts, +1 PV par ennemi tué (3 au plus) |

**Les boss** ne sont ni aspirés par le Gouffre ni achevés par Dévorer ; ils subissent seulement les dégâts.

## Les effets visuels, sort par sort

Tout sera peint au shader ou dessiné avec les pièces (image 4). Ce sont des effets **voraces** : des gueules qui
s'ouvrent, de la bile qui gicle, des secousses à chaque morsure.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| L'éclat | `#f2ffb0` | cœur des éclats et de la bile |
| La bile | `#c8e830` | matière principale : bile, lueur des gueules |
| Le vert sombre | `#5a7a12` | bord de la bile, creux |
| L'os | `#e9e2cf` | crocs, éclats d'os |
| L'encre | `#111014` | cerne, ombre des gueules, qui tient sur les sols clairs |

### Faim insatiable (le trait)

- **Une bouchée :** une âme vert pâle s'arrache de l'ennemi tué et file dans la gueule de son ventre ; il grossit d'un cran.
- **Une bouchée qui fond :** il rapetisse d'un cran, dans un souffle de vapeur verte.

### Langue-fouet (attaque)

- **Le coup :** une langue noire à pointe d'os jaillit en ligne droite et claque au bout de sa course.
- **L'impact :** une giclée de bile sur chaque ennemi transpercé.

### Gouffre béant

- **L'ouverture :** le sol se fend en cercle, et une gueule ronde bordée de crocs s'ouvre, vue de dessus.
- **L'aspiration :** des traînées vertes tirent les ennemis vers son centre ; l'écran tremble.
- **La fermeture :** les crocs se referment d'un coup, avec une gerbe de bile et d'os.

### Dévorer

- **La prise :** sa gueule du ventre s'ouvre en grand sur l'ennemi.
- **L'avalé :** l'ennemi rétrécit et disparaît dans la gueule, avec un court ralenti. S'il meurt, une âme verte le suit.

### Régurgitation

- **La salve :** il se plie en deux et recrache ses bouchées en boules de bile, en éventail.
- **L'explosion :** chaque boule éclate en flaque verte, et il rapetisse aussitôt.

### Bond bestial

- **Le saut :** il se ramasse, puis saute haut, avec une traînée d'ombre verte.
- **L'atterrissage :** une onde de choc fend le sol en étoile, et la caméra tremble.

### Le Festin (extra)

- **La métamorphose :** l'écran s'assombrit en vert noir, et il grandit d'un coup, deux fois plus haut.
- **La gueule :** une immense gueule verticale s'ouvre sur l'écran (pièce dessinée). Les ennemis proches sont tirés
  vers elle un à un, rétrécissent et disparaissent, chacun dans une gerbe de bile.
- **La fin :** la gueule se referme, un rot de vapeur verte balaie l'écran, et il reprend sa taille.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/dragon.png`, **pour les proportions et le trait seulement**. À déposer dans
`assets/peso&cover/refonte/avide.png`.

⚠️ **Ne jamais joindre une planche du Seigneur Démon** : elle vient d'un pack sous licence, et le dépôt est public.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'IMAGE JOINTE NE SERT QU'AU STYLE, À LA MISE EN PAGE ET AUX PROPORTIONS : un corps grand
et massif, tête petite, épaules larges. Ne reprends NI ses écailles, NI son magma, NI ses
ailes, NI ses couleurs : le personnage à dessiner est tout autre.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — l'Avide, un DÉMON PUR SANG, sans rien d'humain, massif, voûté et effrayant.
Peau noir d'encre (#111014) aux reflets vert-gris. Petite tête SANS YEUX, lisse, avec deux
grandes cornes de bélier enroulées, ivoire. Épaules énormes et voûtées, couvertes de plaques
d'OS blanc ivoire (#e9e2cf) ; une rangée de plaques d'os le long de la colonne ; des plaques
d'os sur les avant-bras. De TRÈS LONGS BRAS qui pendent jusqu'aux genoux, mains à quatre
longues griffes noires. Jambes de bouc pliées vers l'arrière, sabots fendus noirs. Sur le
VENTRE, une seconde gueule VERTICALE, fermée, bordée de crocs ivoire, d'où filtre une lueur
VERT BILE (#c8e830). De fines fentes vert bile courent sur sa poitrine, ses bras et ses
cuisses. Dans le dos, la gueule n'est pas visible : on voit la colonne d'os.

⚠️ RÈGLE BLOQUANTE — UNE MORPHOLOGIE GRANDE ET MASSIVE, PAS UN CORPS CHIBI. Tête petite par
rapport au corps (environ le huitième de la hauteur), épaules très larges, buste voûté vers
l'avant, bras démesurés. Jamais de grosse tête, de corps d'enfant ni d'air mignon : il fait peur.

⚠️ RÈGLE BLOQUANTE — AUCUN YEUX, AUCUNE AILE, AUCUNE QUEUE, AUCUNE ÉCAILLE, AUCUN VÊTEMENT,
AUCUNE ARME. La seule gueule ouverte sur le corps est celle du ventre, ici FERMÉE.

⚠️ RÈGLE BLOQUANTE — LE VERT BILE EST UN APLAT NET ET OPAQUE, à contours francs. Aucun halo,
aucune lueur diffuse, aucune transparence, aucune particule, aucune vapeur.

⚠️ RÈGLE BLOQUANTE — LES SABOTS SUR UNE MÊME LIGNE dans les trois cases : c'est là que le jeu
posera son ombre. Pas d'anneau ni de cercle sous lui.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond. Son
noir tire vers le vert-gris, jamais vers le violet.

⚠️ RÈGLE BLOQUANTE — MÊME corps, mêmes couleurs et mêmes proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Un corps chibi, une grosse tête ou un air mignon | Ce n'est pas l'allure voulue : à regénérer sans attendre |
| Des écailles, du magma ou des ailes du Dragon | Le générateur a copié l'image jointe au lieu de s'en inspirer |
| Des yeux sur la tête | Il perdrait ce qui le rend étrange |
| La gueule du ventre est ouverte | Elle resterait ouverte en marchant ; le jeu l'ouvre lui-même |
| Un halo vert autour des fentes | Le détourage laisserait une frange rose autour |
| Un noir violet | Le détourage le griserait |
