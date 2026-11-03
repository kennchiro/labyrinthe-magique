# Le Roi de Braise — fiche et modèle du personnage

> Élément **Braise** · teinte du jeu `#ff9a1f` · or noirci et fissures de lave. Onglet **Démon**.
> Un roi humain déchu, à la couronne brisée. Ses deux gantelets et son plastron flottent autour de lui et se battent seuls.

**Il est jouable.** Les six images sont livrées ; pour en regénérer une, garder cet ordre : la première sert de modèle aux autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle | ci-dessous | `refonte/braise.png` | `refonte/chrono.png` |
| 2 | La marche | [mages_animes/braise](../mages_animes/braise.md), prompt 1 | `mages/braise_marche.png` | `refonte/braise.png` et `guide_complet.png` |
| 3 | L'attaque | [mages_animes/braise](../mages_animes/braise.md), prompt 2 | `mages/braise_attaque.png` | `refonte/braise.png` |
| 4 | Les pièces et la cage | [sorts/pieces_braise](../sorts/pieces_braise.md) | `sorts/braise_pieces.png` | `refonte/braise.png` |
| 5 | Les six icônes | [sorts/icones_braise](../sorts/icones_braise.md) | `sorts/mage_braise_skills.png` | aucune |
| 6 | Le portrait du menu | [menu/portrait_braise](../menu/portrait_braise.md) | `interface/portraits/portrait_braise.png` | `ref_carte.png`, `portrait_fire.png` et `refonte/braise.png` |

## Identité visuelle

Le sprite le montre sans ses trois pièces, et le jeu les dessine à part, autour de lui. Une seule planche suffit
donc, quelles que soient les pièces qu'il lui reste.

Sa palette passe `demagenta` sans changer d'une seule valeur (mesuré). ⚠️ Il reste proche du Mage du Feu : c'est l'or
noirci et ses pièces volantes qui l'en distinguent. Sa flamme tire vers l'ambre, et il ne brûle pas ses cibles.

## Ce qui est programmé

Tout est dans `CombatSystem` (section Roi de Braise) : la simulation d'équilibrage voit les mêmes règles.

- **Les pièces** sont les plaques de `Health` : chaque pièce en orbite encaisse un coup entier. `pieces()` dit où elles
  sont, en cases et à vol d'oiseau, et `KingArmor` les montre.
- **Le leurre** remplace le champ du mage (`EnemyAI.lure_field`) : les ennemis le chassent à sa place, boss exceptés.
- **Les cages** réutilisent l'étourdissement. `KingCage` les dessine, et le dernier instant passe au ralenti (`Engine.time_scale`).
- `tools/preview_braise.gd` montre tous ses effets. `--crowd --skill N --skill-then M F` les enchaîne en partie.

## L'idée

Il lance ses pièces dans les couloirs, puis les rappelle à travers le labyrinthe : il gagne par le placement.
Plus il a lancé de pièces, plus il est rapide et moins il est protégé.

L'Archange d'Acier encaisse et reforge ses plaques par les kills. Le Roi de Braise se sépare de son armure, et elle
revient vers lui.

**Le coup à placer :** poser le plastron dans un couloir, lancer les gantelets de l'autre côté, attirer les ennemis
entre les deux, puis tout rappeler.

## Les règles de son armure

- **Trois pièces :** deux gantelets et un plastron, visibles en orbite autour de lui.
- **Un coup reçu** éjecte une pièce au lieu de retirer un PV, et elle blesse les ennemis autour d'elle. Sans pièce
  en orbite, le coup prend un PV.
- **Le retour automatique :** une pièce revient seule après 8 s, sans qu'il faille aller la chercher.
- **La vitesse :** 4,4 avec les trois pièces, 5,6 sans aucune.

## Ses six sorts

Passe rapide seulement (4 parties, un niveau sur 4) : le bot expert gagne partout, sans aucune mort. Il est peut-être un peu fort.

| créneau | sort | ce qu'il fait | chiffres de départ |
|---|---|---|---|
| Base | | 4 PV, vitesse 4,4 à 5,6, extra à 5 kills | |
| ATTAQUE | **Poing de braise** | un gantelet part, frappe et revient. Si les deux sont partis, un poing de flamme part à sa place | 34 dégâts, portée 6, 0,75 s |
| SKILL 1 | **Gantelets chasseurs** | les deux gantelets poursuivent seuls les ennemis | 6 s, 18 par coup, recharge 12 s |
| SKILL 2 | **Fournaise** | posé sur sa case, il s'ouvre sur le premier ennemi qui passe et le retient en le blessant | retient 3 s, 20 dégâts/s, recharge 12 s |
| SKILL 3 | **Rappel** | toutes les pièces reviennent en ligne droite, à travers les haies, et blessent ce qu'elles croisent. Refusé et gratuit si aucune n'est partie | 30 par pièce, recharge 8 s |
| FUITE | **Coquille de cendre** | il saute et laisse une armure de cendre qui attire les ennemis, puis explose | saut de 5 cases, leurre 3 s, 40 dégâts, recharge 10 s |
| EXTRA | **Les Mille Cages** | une cage d'or en fusion se referme sur chaque ennemi à l'écran, le bloque, puis se resserre | 4 s, puis 60 dégâts |

**Les boss** ne sont ni retenus par le plastron, ni bloqués par les cages : ils subissent seulement les dégâts. Le
leurre ne les attire pas.

## Les effets visuels, sort par sort

Les pièces et la cage sont dessinées (image 4), et tout le reste sera peint au shader.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le pâle | `#ffd9a0` | cœur des flammes, éclairs |
| La braise | `#ff9a1f` | matière principale : flamme, traînées, sceaux |
| La lave | `#ff7a18` | fissures, coulures |
| Le profond | `#8a2c08` | creux, dégradé vers le bord |
| L'or noirci | `#2a2118` | cerne, qui tient sur les sols clairs |

Un dessin **net, à plages franches**, un effet qui **se réduit au lieu de s'estomper**, et **ce qui est grand reste
sous lui ou creux au centre**.

### L'orbite

Les pièces tournent lentement à hauteur de taille, reliées à lui par un filet de lave. Quand l'une part, le filet se
tend puis casse. Quand elle revient, elle claque et lance quelques escarbilles.

### Poing de braise (attaque)

- **Vol :** le gantelet file poing fermé, avec une traînée de flamme à plages nettes.
- **Impact :** il s'ouvre d'un coup, dans un éclat à quatre branches et des escarbilles, puis repart.

### Gantelets chasseurs, 6 s

- **Le départ :** les doigts s'ouvrent, leurs fissures s'allument et la flamme s'allonge derrière chacun.
- **La chasse :** ils volent en rase-mottes et se referment sur leur proie à chaque coup.
- **La fin :** ils s'éteignent et rentrent en orbite.

### Fournaise

- **La pose :** il tombe au sol avec une onde, et ses fissures s'allument une à une.
- **La morsure :** il s'ouvre comme une porte de four sur la proie, et des langues de feu claquent à chaque tick.
- **La fin :** il la recrache dans un jet d'escarbilles, puis repart.

### Rappel

- **Le signal :** ses deux mains s'ouvrent, et un trait de lave relie chaque pièce à lui.
- **Le retour :** les pièces partent ensemble, traversent les haies et laissent une trace qui se rétracte derrière elles.
- **L'arrivée :** elles claquent ensemble en orbite, et une onde de braise part de lui.

### Coquille de cendre

- **Le départ :** il se réduit à une flamme qui saute, en laissant une armure debout.
- **Le leurre :** l'armure reste immobile, grise de cendre, avec un sceau de braise à ses pieds qui se remplit en 3 s.
- **La fin :** elle se fend, et des éclats partent dans un anneau de flamme.

### Les Mille Cages (extra), 4 s

- **Le fracas :** une onde part de lui et l'écran tremble une fois.
- **La chute :** une cage ouverte tombe sur chaque ennemi, l'une après l'autre, très vite, et se referme d'un coup.
- **L'attente :** la lave monte le long des barreaux, du bas vers le haut.
- **La fin :** toutes les cages se resserrent à la fois et se brisent dans un éclair.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/chrono.png`, pour le style, la mise en page et surtout les proportions.
À déposer dans `assets/peso&cover/refonte/braise.png`.

⚠️ **Ne jamais joindre une planche du Seigneur Démon** : elle vient d'un pack sous licence, et le dépôt
est public.

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

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — le Roi de Braise, un homme ADULTE, HUMAIN, roi déchu à l'allure fière. Visage
découvert, peau claire, cheveux sombres (#2b1c16) mi-longs et en arrière, yeux ambrés, expression
sévère. Sur sa tête, une couronne d'or noirci BRISÉE, dont il manque un morceau. Armure d'or
noirci (#2a2118) aux arêtes d'or vieilli (#b8862b), parcourue de fines fissures de lave orange
(#ff7a18) : épaulières larges, ceinture, jambières articulées et solerets. Sur le torse et les
bras, une cotte sombre, avec de fines manches et de simples gants noirs. Un court mantelet de
tissu anthracite, posé sur les épaules, s'arrête à la taille. Ses mains sont vides : aucune arme,
aucun objet. Toutes ses formes sombres sont cernées d'un fin liseré d'or vieilli, qui les détache
des sols sombres.

⚠️ RÈGLE BLOQUANTE — PAS DE GRANDS GANTELETS NI DE GROS PLASTRON SUR LE CORPS. Ces pièces
seront dessinées à part : ici, ses mains et sa poitrine restent minces et sombres.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI. Sa hauteur
totale vaut 2,5 TÊTES : la tête (couronne comprise) occupe près de 40 % de la hauteur, et les
jambes à peine un quart. Grosses mains, gros pieds, torse court. Jamais de corps élancé, de
longues jambes ou de petite tête : posé à côté du personnage de l'image jointe, il a la même
morphologie.

⚠️ RÈGLE BLOQUANTE — IL EST HUMAIN. Aucune corne, queue, croc, griffe, aile, auréole, peau colorée
ou transformation démoniaque. La couronne brisée ne ressemble jamais à des cornes.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT. Les deux jambes sont séparées l'une
de l'autre, et aucune cape, aucun pan ni aucune jupe de plaques ne les cache.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond.

⚠️ RÈGLE BLOQUANTE — AUCUNE MAGIE sur cette image : les fissures sont de simples traits orange.
Aucune flamme, aucune lueur autour de lui, aucune particule.

⚠️ RÈGLE BLOQUANTE — MÊME visage, armure, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le corps est élancé, ou la tête petite | Il ne ressemblerait pas aux mages : à regénérer sans attendre |
| Il porte de gros gantelets ou un plastron | Il aurait ses pièces en double une fois en jeu |
| Une cape ou des plaques cachent les jambes | Il glisserait en marchant : le défaut déjà vu sur les anges |
| La couronne ressemble à des cornes | Tout ce qui le dit démon passe par ses sorts |
| Il paraît tout orange | Il se confondrait avec le Mage du Feu : l'or noirci doit dominer |
