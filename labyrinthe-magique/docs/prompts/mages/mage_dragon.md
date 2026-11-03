# Le Dragon des Abysses — fiche et modèle du personnage

> Élément **Feu infernal** · teinte du jeu `#ff3a14` · écailles noir charbon et rouge sang, veines de magma. Onglet **Démon**.
> Un dragon-démon debout, massif et redoutable. Il met le feu au sol, et il devient plus fort dans le feu.

**Il est jouable** (`--demo --character dragon`). Les six images sont livrées ; pour en regénérer une, garder cet ordre :
la première sert de modèle aux autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle | ci-dessous | `refonte/dragon.png` | `refonte/geolier.png` (proportions seulement) |
| 2 | La marche | [mages_animes/dragon](../mages_animes/dragon.md), prompt 1 | `mages/dragon_marche.png` | `refonte/dragon.png` et `guide_complet.png` |
| 3 | L'attaque | [mages_animes/dragon](../mages_animes/dragon.md), prompt 2 | `mages/dragon_attaque.png` | `refonte/dragon.png` |
| 4 | Les pièces | [sorts/pieces_dragon](../sorts/pieces_dragon.md) | `sorts/dragon_pieces.png` | `refonte/dragon.png` |
| 5 | Les six icônes | [sorts/icones_dragon](../sorts/icones_dragon.md) | `sorts/mage_dragon_skills.png` | aucune |
| 6 | Le portrait du menu | [menu/portrait_dragon](../menu/portrait_dragon.md) | `interface/portraits/portrait_dragon.png` | `ref_carte.png`, `portrait_fire.png` et `refonte/dragon.png` |

## Identité visuelle

⚠️ **Il n'est PAS chibi**, comme le Geôlier : une silhouette grande et massive, tête petite par rapport au corps. Le
Geôlier n'est joint à l'image 1 que pour ces proportions et le trait ; le dragon n'en reprend ni l'armure ni la flamme.

Un dragon-démon BIPÈDE, debout : petite tête de reptile à deux grandes cornes recourbées vers l'arrière, gueule
pleine de crocs, yeux jaunes brûlants. Cou épais, épaules larges, torse puissant, mains griffues. Jambes de bête aux
genoux pliés vers l'arrière, pieds à trois griffes. Écailles noir charbon, plaques du ventre et du dos rouge sang,
**veines de magma** orange et jaune qui fendent les écailles. Ailes de chauve-souris déchirées, **repliées dans le
dos**. Longue queue terminée par une lame d'os.

- **Les ailes restent repliées sur toutes les planches** : déployées, elles ne tiendraient pas dans une case de 256.
  Le jeu les déploie lui-même (Battement d'ailes, l'Ombre du Dragon).
- **La queue s'enroule contre ses jambes**, pointe au niveau des pieds : jamais dressée hors de la case.
- **Le magma et le feu sont des aplats nets et OPAQUES**, sans halo : un halo translucide sur fond magenta se détoure mal.
- **Aucun rose, aucun violet** : ses rouges n'ont pas de bleu (`#8a160c`, `#ff5a10`), ce qui les garde loin du magenta.
- ⚠️ Il reste voisin du Mage du Feu (`#ff6a2a`), du Roi de Braise (orange) et de l'Ange de la Mort (`#e2382a`). Ce sont
  les écailles noires, les cornes et le **sol qui brûle** qui le distinguent.

## Ce qui est programmé

Tout est dans `CombatSystem` (section Dragon des Abysses) : la simulation d'équilibrage voit les mêmes règles.

- **Le sol en feu** (`_fire_cells`) : posé par le trait sur la case de la cible du crachat, par le Souffle et par l'Ombre.
  Il ronge au rythme des zones. Dans le feu, `armor_speed()` lui ajoute 20 % de son allure.
- **Le Souffle** (`Kind.BREATH`) suit le couloir devant lui (`_corridor_ahead`), comme la vague.
- **La Morsure** (`Kind.BITE`) le pose au contact par `blink_performed`. Une proie « en feu » brûle déjà, ou se tient
  sur une case en feu.
- **Les Écailles** (`Kind.MAGMA_SCALES`) sont une coque d'un coup ; elles éclatent au premier coup reçu ou à l'échéance.
- **Le Battement d'ailes** (`Kind.WINGBEAT`) est sa fuite : il repousse, enflamme, puis le fait reculer.
- **L'Ombre** (`Kind.DRAGON_SHADOW`) : la silhouette des pièces passe sur l'écran, noircie, puis les colonnes jaillissent
  dans l'ordre de son passage (`SHADOW_DELAY`, `SHADOW_GAP`).
- Ses planches : `body_scale` 1,3, et `strike_scale` 0,94, car l'attaque est dessinée plus grande que la marche.
- Ses pièces : `tools/build_dragon_pieces.py`. Le sol en feu est le shader `dragon_brasier` ; les autres effets sont ceux
  du Roi de Braise et du Geôlier, recolorés en rouge infernal.

## L'idée

Le Mage du Feu lance des boules de feu, le Roi de Braise se bat avec ses pièces d'armure. Le Dragon **brûle le
terrain** : ses sorts laissent des cases en feu, il s'y bat mieux que ses ennemis, et il dévore les proies qui brûlent.
C'est aussi le seul héros qui **repousse** les ennemis et qui **se soigne en mordant**.

## Ses six sorts

| créneau | sort | ce qu'il fait | chiffres de départ |
|---|---|---|---|
| Base | | 5 PV, vitesse 4,4 : grand et lourd | |
| TRAIT | **Terre brûlée** | ses sorts enflamment les cases. Un ennemi sur une case en feu brûle ; le dragon y va plus vite | cases en feu 4 s, 10 dégâts/s · +20 % de vitesse dans le feu |
| ATTAQUE | **Crachat de magma** | une boule de lave qui éclate à l'impact et laisse une case en feu | 26 dégâts, portée 5, 0,75 s |
| SKILL 1 | **Souffle infernal** | un jet de flammes court dans le couloir devant lui et enflamme chaque case touchée | 5 cases, 40 dégâts, cases en feu 5 s, recharge 10 s |
| SKILL 2 | **Morsure** | il bondit d'une case sur l'ennemi le plus proche et le mord. Si la proie brûlait, il se soigne | 55 dégâts, +1 PV sur une proie en feu, recharge 12 s |
| SKILL 3 | **Écailles de magma** | ses écailles durcissent : elles absorbent le premier coup, et brûlent qui le touche. Puis elles éclatent en éclats de lave | 4 s, 1 coup absorbé, 8 éclats de 20 dégâts, recharge 14 s |
| FUITE | **Battement d'ailes** | il déploie les ailes : les ennemis proches sont repoussés et prennent feu, et lui recule d'un bond | rayon 2, repoussés de 2 cases, 15 dégâts, recul 2 cases, recharge 11 s |
| EXTRA | **L'Ombre du Dragon** | l'ombre géante d'un dragon traverse l'écran : tout ennemi visible brûle, puis explose en colonne de flammes | brûlure 4 s à 12 dégâts/s, puis colonne de 45 dégâts |

**Les boss** ne sont pas repoussés par le Battement d'ailes ; ils subissent seulement les dégâts.

## Les effets visuels, sort par sort

Tout sera peint au shader ; seules la boule de magma, l'écaille, la gueule de flamme et la silhouette du dragon en vol
sont dessinées (image 4). Ce sont les effets les plus **dramatiques** du jeu : secousse, ralenti et assombrissement
sur les gros coups.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le cœur | `#ffe36a` | cœur des flammes, éclairs de l'impact |
| Le magma | `#ff5a10` | matière principale : flammes, lave, sol en feu |
| Le rouge infernal | `#d1200c` | bord des flammes, dégradé |
| Le sang | `#8a160c` | creux, écailles |
| La fumée | `#1c1210` | cerne et fumée noire, qui tiennent sur les sols clairs |

Un dessin **net, à plages franches**, un effet qui **se réduit au lieu de s'estomper**, et de la **fumée noire** qui
monte au-dessus de chaque feu : c'est elle qui le distingue des autres feux du jeu.

### Terre brûlée (le trait)

- **La case en feu :** des flammes basses rouges à cœur jaune lèchent le sol, fissuré de lignes de magma, avec un
  filet de fumée noire. Elle se réduit en braises puis en cendre grise avant de disparaître.
- **Le dragon dans le feu :** ses veines de magma s'allument plus fort, et des braises montent de ses épaules.

### Crachat de magma (attaque)

- **Vol :** une boule de lave qui tourne sur elle-même, suivie d'une traînée de fumée noire et de gouttes de feu.
- **Impact :** une gerbe de lave en éclaboussure, et la case reste en feu.

### Souffle infernal

- **L'inspiration :** sa gorge et son torse s'illuminent, la fumée sort des naseaux, l'écran tremble un peu.
- **Le souffle :** un torrent de flammes rouge et jaune déferle dans le couloir, case après case, comme une vague.
- **La fin :** toutes les cases touchées restent en feu, sous une fumée noire qui monte.

### Morsure

- **Le bond :** il file d'une case, laissant une traînée de braises.
- **La morsure :** une immense gueule de flamme se referme sur la proie (pièce dessinée), avec un claquement et un
  court ralenti. Si la proie brûlait, une flamme remonte d'elle jusqu'au dragon : il se soigne.

### Écailles de magma, 4 s

- **Le durcissement :** des plaques de lave en fusion se referment sur lui, et ses contours rougeoient.
- **Le coup absorbé :** une gerbe d'étincelles, et les écailles se fendent d'un trait de lave.
- **L'éclatement :** huit écailles de magma partent en étoile, chacune avec sa traînée de feu.

### Battement d'ailes

- **Les ailes :** deux grandes ailes de flamme et d'ombre se déploient d'un coup autour de lui.
- **Le souffle :** une onde de cendres brûlantes chasse les ennemis, qui prennent feu en volant.
- **Le recul :** il recule d'un bond dans un nuage de fumée noire.

### L'Ombre du Dragon (extra)

- **La nuit rouge :** l'écran s'assombrit en rouge sang ; seules les flammes restent éclairées. Un rugissement : la
  caméra tremble.
- **Le passage :** l'ombre gigantesque d'un dragon aux ailes déployées traverse la carte d'un bord à l'autre
  (silhouette dessinée, noircie par le jeu). Sous son passage, chaque ennemi prend feu.
- **L'éruption :** une seconde plus tard, une colonne de flammes jaillit sous chaque ennemi touché, une à une, avec
  un ralenti sur la première.
- **La fin :** une grande onde de chaleur balaie l'écran, et la nuit rouge se retire.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/geolier.png`, **pour les proportions et le trait seulement**. À déposer dans
`assets/peso&cover/refonte/dragon.png`.

⚠️ **Ne jamais joindre une planche du Seigneur Démon** : elle vient d'un pack sous licence, et le dépôt est public.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'IMAGE JOINTE NE SERT QU'AU STYLE, À LA MISE EN PAGE ET AUX PROPORTIONS : un corps grand
et massif, tête petite, épaules larges. Ne reprends NI son armure, NI sa flamme cyan, NI
ses couleurs : le personnage à dessiner est tout autre.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — le Dragon des Abysses, un DRAGON-DÉMON BIPÈDE, debout sur deux jambes,
massif et REDOUTABLE. Petite tête de reptile allongée, gueule entrouverte pleine de crocs
blancs, deux yeux jaunes brûlants, deux grandes cornes noires recourbées vers l'arrière,
une crête d'épines le long du cou. Cou épais, épaules très larges, torse puissant, bras
musclés finis par des mains à quatre griffes noires. Jambes de bête aux genoux pliés vers
l'arrière, pieds à trois griffes. Écailles noir charbon (#1c1210) et plaques rouge sang
(#8a160c) sur le ventre, les épaules et les avant-bras. Les écailles sont FENDUES DE
VEINES DE MAGMA orange (#ff5a10) à cœur jaune (#ffe36a) : sur le torse, les bras, les
cuisses et la gorge. Deux ailes de chauve-souris aux membranes rouge sombre déchirées,
REPLIÉES DANS LE DOS, leurs pointes au-dessus des épaules. Une longue queue écaillée finie
par une lame d'os, ENROULÉE contre ses jambes, la pointe au niveau des pieds. Un filet de
fumée noire sort de ses naseaux.

⚠️ RÈGLE BLOQUANTE — UNE MORPHOLOGIE GRANDE ET MASSIVE, PAS UN CORPS CHIBI. Tête petite par
rapport au corps (environ le septième de la hauteur), épaules très larges, torse puissant,
jambes longues. Jamais de grosse tête, de grands yeux ronds, de corps d'enfant ni d'air
mignon : il fait peur.

⚠️ RÈGLE BLOQUANTE — LES AILES SONT REPLIÉES et restent dans la case. La queue reste
enroulée contre les jambes, jamais dressée ni étendue loin du corps.

⚠️ RÈGLE BLOQUANTE — LE MAGMA ET LA FUMÉE SONT DES APLATS NETS ET OPAQUES, à contours
francs. Aucun halo, aucune lueur diffuse, aucune transparence, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — LES PIEDS SUR UNE MÊME LIGNE dans les trois cases : c'est là que le
jeu posera son ombre. Pas d'anneau ni de cercle sous lui.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond.
Ses rouges tirent vers l'orange et le brun, jamais vers le rose. Ses ailes sont rouge
sombre, jamais violettes.

⚠️ RÈGLE BLOQUANTE — AUCUNE ARME, aucun objet tenu, aucune armure, aucun vêtement.

⚠️ RÈGLE BLOQUANTE — MÊME corps, mêmes couleurs et mêmes proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Un corps chibi, une grosse tête ou un air mignon | Ce n'est pas l'allure voulue : à regénérer sans attendre |
| L'armure ou la flamme cyan du Geôlier | Le générateur a copié l'image jointe au lieu de s'en inspirer |
| Les ailes déployées ou la queue dressée | Il ne tiendra pas dans les cases de la marche |
| Le magma a un halo flou | Le détourage laisserait une frange rose autour |
| Des ailes violettes ou des rouges rosés | Le détourage les griserait |
| Un anneau ou un cercle sous lui | Il serait collé au sprite, et le jeu dessine déjà son ombre |
