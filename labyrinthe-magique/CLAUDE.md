# Labyrinthe des Éléments — instructions projet

Jeu 2D top-down en **Godot 4.7.2**, renderer `gl_compatibility` (seul backend couvrant
Web + mobile + desktop avec un codebase unique). Cibles : iOS, Android, Web, Desktop.

## Commandes

```bash
# Lancer
godot --path .

# La scène principale est scenes/app.tscn (routeur GameFlow), PAS main.tscn.
# Sans argument -> écran-titre. AVEC un argument -> on entre directement en jeu,
# pour que toutes les captures de développement continuent de fonctionner.
godot --path . -- --menu          # force l'écran-titre
godot --path . -- --select        # force la sélection des personnages
godot --path . -- --stages        # force la sélection de stage
godot --path . -- --demo --character thunder   # le terrain d'essai, tout débloqué

# Outils de dev (voir src/core/dev_tools.gd pour la liste complète)
godot --path . -- --stage 2 --episode 2 --seed 77 --overview --debug --touch
#   --stage N = le CHAPITRE (1 à 10), --episode 1|2 ; l'index plat est interne
godot --path . -- --stage 3 --episode 2 --at-lair --raze   # repaires : sortie, destruction
godot --path . -- --auto-walk --potion --cast --screenshot /tmp/x.png --frames 200
godot --path . -- --character fire --kills 4 --fx   # mage joué, kills simulés, éclats

# Tests (headless, aucun affichage requis)
godot --headless --path . --script res://tests/test_maze.gd
#   … test_portals, test_grid_mover, test_combat, test_victory
godot --headless --path . --script res://tests/test_balance.gd   # LENT (minutes)

# Assets : la planche source ne sert JAMAIS directement, tout passe par le pipeline
tools/.venv/bin/python tools/build_assets.py        # décor, gemmes, tuiles
tools/.venv/bin/python tools/build_characters.py    # les sept mages
tools/.venv/bin/python tools/build_stage_art.py     # vignettes des dix stages
tools/.venv/bin/python tools/build_bestiary.py      # les neuf créatures restantes
tools/.venv/bin/python tools/build_stage_tiles.py   # le terrain des dix stages
tools/.venv/bin/python tools/build_warps.py         # les colonnes de téléportation
tools/.venv/bin/python tools/build_stage_props.py   # décor + monument de chaque stage
tools/.venv/bin/python tools/build_spell_fx.py      # orbe, impact, zone par mage
tools/.venv/bin/python tools/check_characters.py    # vérifie le découpage + le gobelin
godot --headless --path . --import      # OBLIGATOIRE après tout nouveau PNG

# Build iOS (équipe Nano&Co, certificat « Apple Development: Maharo elie »)
godot --headless --path . --export-debug "iOS" build/ios/LabyrintheMagique.xcodeproj
xcrun devicectl device install app --device <id> build/ios/LabyrintheMagique.ipa
```

## Règles d'architecture — à respecter pour tout nouveau code

**1. La logique de jeu ne connaît pas le moteur de scène.**
`MazeGrid`, `MazeGenerator`, `Pathfinder`, `GridMover`, `EnemyAI`, `TeleportSystem`,
`CombatSystem`, `KillSystem`, `Health`, `PortalNetwork` sont des `RefCounted` sans un seul `Node`. C'est ce qui
permet à `tests/test_balance.gd` de simuler des parties entières en headless **en
exécutant le vrai code du jeu**, pas une réimplémentation qui divergerait.
Tout nouveau système de combat doit suivre la même règle.

**2. Trois couches, trois responsabilités.**
- `Level` rapporte des **faits** (« le joueur est entré dans la maison », « un ennemi
  l'a touché »). Il ne décide jamais de rien.
- `GameManager` décide ce que ça **veut dire** (victoire, défaite, déblocage).
- `UIManager` **affiche**. Le GameManager ne touche jamais un `Label`.

**3. Toute la difficulté vit dans `LevelConfig`.** Ajouter un stage = ajouter une
fabrique statique, pas une ligne de gameplay.

**4. Les assets sont générés, pas bricolés à la main.** `tools/build_assets.py` est la
seule source des fichiers de `assets/sprites/`, `assets/tiles/` et `assets/ui/` ;
`tools/build_characters.py` celle de `assets/characters/` et `assets/enemies/`.
Les planches brutes restent dans `assets/raw/` (décor) ou `assets/peso&cover/`
(personnages et ennemis, telles que fournies).

**5bis. Le jeu est en PAYSAGE sur téléphone.** Le **manche analogique** est à
gauche, les cinq boutons de combat à droite, le labyrinthe entre les deux.
L'échelle de l'interface est CALCULÉE (`Platform.apply_ui_scale`) pour qu'une
touche fasse 62 points quelle que soit la forme de l'écran — une constante ne
peut pas marcher, l'étirement varie du simple au triple entre portrait et paysage.

Le manche (`TouchStick`) est à **position fixe**, pas flottant : c'est le flottant
qui avait été abandonné, parce que sans repère à l'écran le pouce devait deviner
où était le centre. Zone morte à 34 % du débattement — un pouce posé sur un manche
n'est jamais centré, et un mage qui part tout seul est un bug pour le joueur. Il
rend un vecteur continu ; c'est `Player` qui le réduit à une direction cardinale,
comme il le fait déjà pour le clavier et la manette. Sa base et son bouton sont
découpés de `assets/peso&cover/pad_mobile.png` vers `assets/ui/` par
`tools/build_assets.py` — les deux textures sont recadrées sur le MÊME centre,
donc le moteur les pose centrées sans connaître de décalage.

Le tactile a un SECOND mode de déplacement, **« toucher le chemin »** (façon
Dota) : un tap sur une case praticable donne un ordre de marche — champ BFS
descendu pas à pas (`Player.walk_to`), marque pulsante sur la case
(`MoveMarker`), toute entrée manuelle ou téléportation annule l'ordre. Le
**manche reste le défaut** ; la bascule vit dans l'écran de PAUSE et persiste
dans `user://settings.cfg` (`Settings`, séparé de `Progress` : une préférence
ne s'écrit que sur un geste du joueur, elle peut donc s'écrire toujours). La
cible ne peut être qu'une case visible (~11 cases) : ce mode ne résout pas le
labyrinthe à la place du joueur. Le pad de combat et le bouton de pause lisent
leurs touches SANS les consommer — le GameManager écarte d'abord tout tap qui
leur appartient (`ui.touch_reserved`), sinon presser un sort ferait AUSSI
marcher le mage. Tests : `--tap-move` force le mode, `--tap X Y` simule un tap
sur la case, `--pause` capture l'écran de pause.

**5. Rien ne se vérifie « à l'œil » sans capture.** Utiliser `--screenshot` plutôt que
demander à l'utilisateur de regarder son écran.

## Les huit mages

`Mage du Feu` · `Mage de l'Eau` · `Mage de la Terre` · `Sorcier des Ténèbres` ·
`Mage de la Foudre` · `Mage de l'Air` · `Invocateur` · `Sorcier Suprême`.

L'**Invocateur** est à part sur toute la ligne :
- sa planche (`mage_invocateur.jpeg`) est un **JPEG sans alpha** sur damier peint,
  aux orientations inégales (4 poses de face, 5 de dos, 4 à gauche, 3 à droite —
  la droite boucle en ping-pong) et sans rangée d'attaque. Elle est découpée par
  **`tools/build_invocateur.py`** (mage + créatures + effets), pas par
  build_characters.py ;
- il ne se bat pas, il **invoque** : voir « Invocations » ci-dessous.

Noms, couleurs et sprites viennent de `assets/peso&cover/` — c'est la **source
de vérité visuelle**, y compris pour l'écran-titre (`couverture.png`).

Les planches sont découpées par `tools/build_characters.py` vers
`assets/characters/<id>/{down,up,left,right}.png` + `frames.json`
(6 poses par bande : IDLE, WALK 1-4, ATTACK). Le script retrouve la grille par
**autocorrélation** ; seuls l'origine de la grille et l'identifiant du mage sont
codés, dans une table de sept lignes.

**Une seule taille de case pour TOUS les personnages**, ennemis compris — le script
mesure toutes les planches avant d'en écrire une seule. La case est **symétrique
autour des pieds**, et ce n'est pas un choix esthétique : le moteur centre le
`Sprite2D` horizontalement, donc les pieds DOIVENT tomber au milieu de la case,
sinon le personnage est dessiné à côté de sa vraie position. Sa demi-largeur vaut
donc le plus grand débordement d'un seul côté, toutes planches confondues — la
boule de feu du mage du Feu et la massue du gobelin en pleine attaque.

⚠️ Les poses voisines **débordent par-dessus les lignes de grille** sur ces
planches. `_without_bleed()` les efface en comparant l'appartenance : une forme
dont le centre tombe dans une autre case, et dont l'essentiel est hors de
celle-ci, est à quelqu'un d'autre. On ne peut PAS simplement jeter tout ce qui
n'est pas la forme principale — le bâton du mage de l'Eau et les feuilles du mage
de la Terre sont détachés du corps et parfaitement légitimes.

## Les ennemis

**Onze créatures**, toutes au format des mages, dans `assets/enemies/<id>/`.
`src/entities/bestiary.gd` dit ce qu'elles valent ; le stage N ajoute UNE espèce
et garde toutes les précédentes. Les statistiques sont des RAPPORTS au spectre,
qui reste l'unité de mesure de tout l'équilibrage.

Neuf d'entre elles viennent de `tools/build_bestiary.py` — fichier séparé de
`build_characters.py`, qui est édité par une autre session. Convention des
planches : **r0 de face, r1 de dos, r2 de profil, r3 l'attaque**. Le profil sert
aux deux côtés, retourné pose par pose. Deux planches (l'ombre, le chevalier)
ont leur **grille imposée à la main** : la détection y mesurait un pas de deux
rangées et rendait un dos coupé en deux moitiés empilées.

Le gobelin et le spectre restent produits par `build_characters.py`, et chacun
a fallu son mode de découpe :

- **gobelin** (`enemi_2.png` → `goblin/`, `mode: "formes"`) — quatre orientations
  dessinées, six poses chacune. Rangées en 4 x 6 mais **pas régulièrement
  espacées** : une grille sectionnerait des massues, ce sont donc les formes
  connexes qui font foi.
- **spectre** (`enemi_1.png` → `hunter/`, `mode: "poses"`) — ni orientations ni
  cycle de marche : dix-sept poses de face d'une créature qui **lévite**, plus un
  grand panneau d'effets. Les six poses retenues sont **désignées à la main**
  (rangée, colonnes) dans `SHEETS`. Sa vue de gauche est la vue de face
  **retournée**, écrite sur le disque (`mirror: {"left": "down"}`) et non
  retournée en jeu : la planche reste la seule source, le moteur lit un dossier
  sans deviner quelle direction miroiter. Le haut et la droite n'ont pas de bande
  et retombent sur `down` — dupliquer un fichier identique n'apprend rien.

⚠️ L'animation procédurale à trois pièces d'`Actor` n'a donc **plus aucun
utilisateur** : tous les personnages ont leur planche.

Les teintes d'état (`TINT_CHASE`, `TINT_STRIKE`) datent des poses uniques, sombres
et désaturées. Sur ces planches vives elles repeignent le dessin — d'où
`TINT_STRENGTH = 0.45` dans `enemy.gd`.

⚠️ La couverture ne montre que **cinq** mages : elle date d'avant la Foudre et
l'Air.

## Décisions de design déjà arbitrées

- **Objectif** : ramasser toutes les gemmes ; la porte de la maison ne s'ouvre qu'au
  compte plein. La maison est une serrure, pas une ligne d'arrivée.
- **Portails** : 20 % de destination avantageuse / 80 % neutre, mesuré sur le champ de
  distances BFS **de l'objectif courant** (gemme, puis maison) — pas de la maison.
- **Chaque stage a son MONUMENT** au centre (l'autel à gemme, le temple de feu,
  le château du ciel), sa lisière et son semis, détourés de sa planche
  (`assets/stages/props/stage_<N>/`). Les boîtes sont relevées à la main et
  volontairement GROSSIÈRES : l'outil recadre sur la plus grosse forme à
  l'intérieur. Trois détections automatiques ont échoué — les props se touchent
  bord à bord sur un fond opaque et texturé.
  ⚠️ Un monument se détoure par CLÉ DE FOND depuis les bords, pas par contraste :
  son masque de contraste revient plein et rend un rectangle opaque.
- **Chaque stage a son terrain**, teinté d'après sa planche d'ambiance
  (`assets/tiles/stage_<N>/`, chargé par `MazeRenderer.set_stage`). Ce ne sont pas
  des tuiles découpées : essayé, ça donne de la bouillie — un mur d'une case de
  large ne contient aucun carré assez grand. On garde le dessin des tuiles et on
  leur prend la couleur. Un écart de luminance minimal entre sol et mur est
  IMPOSÉ : deux biomes rendaient sinon un labyrinthe illisible.
- **Un stage = un CHAPITRE de deux épisodes**, dix chapitres, vingt niveaux. Le
  `GameManager` ne manipule qu'un index PLAT ; `LevelConfig.flat_index()` traduit.
  Le second épisode ne rejoue pas le premier en plus grand — le labyrinthe est déjà
  neuf à chaque partie : il resserre (un poursuivant, une gemme, un retour plus
  rapide). Les noms des dix stages sont ceux **dessinés sur les planches** d'
  `assets/stages/` ; `stage_9.jpeg` (format à part : tuiles sur damier) est intégré.
- **Une session de dev n'écrit JAMAIS la sauvegarde.** `DevTools` met
  `progress.persistent = false` dès qu'un argument est passé : une capture pouvait
  ramasser une potion ou franchir la porte et pousser la progression du joueur.
- **Le clavier a sa propre barre d'action** (`src/ui/action_bar.gd`), affichée
  quand le pad tactile ne l'est pas. Mêmes entrées, fabriquées une seule fois par
  l'UIManager. Les libellés de touche viennent de l'InputMap, pas du code.
  ⚠️ L'action de la frappe s'appelle `teleport` — nom d'origine, d'avant le combat.
- **La progression ne s'écrit QUE depuis une sauvegarde chargée.**
  `Progress.persistent` est faux par défaut ; seule `load_saved()` le met à vrai.
  Le défaut inverse a coûté la sauvegarde d'un joueur : un test appelait
  `reach(5, 2)` et `reach()` écrit sur le disque.
- **Les ennemis sortent de leur maison**, jamais au hasard : deux repaires, aux
  coins haut-gauche et bas-droite. La maison s'ouvre **1,1 s avant** de lâcher sa
  créature — c'est l'avertissement. On choisit toujours le repaire le plus ÉLOIGNÉ
  du mage.
- **Les trois délais de repaire sont dans `LevelConfig`** (ouverture, file
  d'attente, échelonnement du départ), pas dans le `Level` : la simulation
  d'équilibrage doit les appliquer à l'identique. Elle a déjà mesuré un autre jeu
  que le nôtre pour les avoir ignorés — sept ennemis lâchés d'un bloc sur deux
  cases, et une alerte à 92 % de morts qui ne disait rien du niveau.
- **Les repaires ne sont destructibles qu'au dernier épisode des stages 3 et 9.**
  Ils vivent alors dans les MÊMES tableaux du `CombatContext` que les ennemis
  (`structures_from`) : rien n'est dupliqué. Seule règle propre : un ennemi à portée
  passe **toujours** avant une maison (`STRUCTURE_PENALTY`). Les deux abattues, les
  vagues s'arrêtent définitivement.
- **Le mage commence CHEZ LUI** (2026-08-24) : spawn au CENTRE de sa maison, et il
  en SORT en marchant par la porte sud — que le générateur PERCE si la parité la
  fait tomber sur un mur (`_carve_house`). La sortie réutilise le suivi de chemin
  du mode « toucher le chemin » : la première entrée du joueur reprend la main,
  ce n'est jamais une cinématique. Deux conséquences non évidentes :
  `player_reached_house` n'est rapporté qu'en TRANSITION (entrée depuis
  l'extérieur) — sinon « Porte scellée » clignote à la frame zéro ; et les flags
  de dev qui téléportent le mage (`--on-portal`, `--at-lair`) doivent
  `cancel_path()`, sinon il retraverse le labyrinthe vers sa porte.
- **Braiding obligatoire** (~30-38 % des culs-de-sac supprimés) : un labyrinthe parfait
  rend la poursuite injuste (impasse = mort sans recours).
- **Points de vie** = ceux du personnage + le bonus du stage (0/+1/+2) : la tournée dure 1 à 3 minutes,
  un seul PV donnait 90 % de captures en simulation.
- **Boussole** : direction à vol d'oiseau vers la gemme la plus proche **en distance de
  chemin**. Elle donne un cap, jamais un itinéraire — sinon le labyrinthe ne sert plus.
- **Chaque élément MARQUE ses coups d'un trait** (brûlure, trempe, ébranlement,
  ponction, arc, bourrasque, écho — `CombatSystem`, bloc TRAITS) : c'est ce qui
  fait sept mages et non sept teintes. Les zones n'en déclenchent aucun, et les
  traits ne se composent jamais entre eux.
- **Les effets d'un mage sont ses dessins** : `assets/characters/<id>/{orb,impact,zone}.png`
  découpés des planches. La règle de découpe : la boîte relevée à la main ne fait
  que DÉSIGNER, les formes sont prises entières — jamais coupées. Deux règles
  précédentes ont été jetées pour avoir amputé des anneaux de flammes.
- **Attaque** : elle vise et ne rate jamais. Un projectile ratable dans un couloir
  d'une case serait de la chance, pas de l'adresse.
- **Invocations** (l'Invocateur) : les créatures vivent dans le **CombatSystem**,
  pas dans le Level — la simulation d'équilibrage les fait chasser en headless
  avec les règles du jeu (règle d'architecture n° 1). 2 minutes de vie chacune,
  **plafond de 4** (la plus ancienne cède la place), leurs kills nourrissent
  l'ultime. Les marcheurs descendent un champ BFS calculé depuis les ennemis ;
  le **dragon vole** par-dessus les haies, droit sur sa proie — c'est ce qui en
  fait l'ultime. Leurs coups ne déclenchent PAS de trait élémentaire : le trait
  est la signature du mage, pas de ses bêtes.
- **Les poursuivants refusent le dernier pas**, celui qui les ferait monter sur la
  case du mage (`Enemy._update_desired`) : deux sprites superposés, on ne voit plus
  ni qui frappe ni où l'on est. `CATCH_DISTANCE` vaut donc une case pleine, sinon un
  ennemi arrêté juste à côté resterait planté sans jamais toucher.
  ⚠️ Ce refus se décide sur `player_cell`, remise à jour **à chaque frame**, et non
  sur le champ de distances de l'IA (300 ms). Mesuré : avec le champ, l'ennemi reste
  planté un tiers de seconde après le départ du mage, et `test_balance` passe de 25 %
  à 8 % de morts au stage 2 — assez pour lever une alerte. À la frame près, les
  chiffres sont IDENTIQUES à ceux d'avant le changement.
- **`Entities` est en y-sort** : à une case au-dessus, un ennemi passe DERRIÈRE le
  mage. Les sprites font une case et demie de haut, ils se chevauchent forcément —
  ce qui compte est que le personnage joué ne soit jamais masqué. Le z-index reste
  la couche (gemmes 4, acteurs 10, orbes 12), le y-sort ne trie qu'à l'intérieur.

## Pièges connus

- **Tout nouveau PNG doit être importé** (`--import`) avant d'être `preload`é. Sinon
  l'erreur est trompeuse (« has no resource loaders ») et un script qui ne compile pas
  fait apparaître des `Nil` inexpliqués ailleurs dans la scène.
- **Les lambdas GDScript capturent les locales par valeur** : un compteur incrémenté
  dans une lambda connectée à un signal reste à zéro. Utiliser un `Dictionary`.
- **`rendering/textures/vram_compression/import_etc2_astc=true`** est obligatoire pour
  exporter vers iOS/Android. Sans lui l'export échoue **sans message d'erreur**.
- **`application/targeted_device_family`** : 0 = iPhone, 1 = iPad, 2 = les deux.
- **En coordonnées écran, l'axe Y descend** : un arc qui monte a un sinus
  NÉGATIF (angles entre 180° et 360°). Une erreur de signe envoie les boutons
  hors de l'écran.
- **`exclude_filter` compare le chemin COMPLET** (`res://assets/...`) : un motif
  `assets/raw/*` ne mord jamais, il faut `*/assets/raw/*`. Sans ça, les planches
  sources partent dans l'app — 30 Mo pour des fichiers que le jeu n'ouvre jamais.
- **`tools/build_*.py` utilisent des chemins RELATIFS** : lancés hors de la racine
  du projet, ils annoncent « introuvable » pour toutes les planches et ne font rien.
  Toujours `cd` dans le projet — ou `(cd <projet> && ...)`.
- **Une bande de sprites doit vérifier `largeur == cellule × poses`** (`frames.json`).
  Quand une planche BRUTE atterrit à la place d'une bande découpée, rien ne plante :
  `hframes` la taille en morceaux et le personnage s'affiche quatre fois trop grand.
  C'est arrivé — voir `docs/REFONTE.md`, 2026-08-23 au soir.
- **Un nouveau `class_name` n'est visible qu'après `--import`** : le cache des classes
  globales n'est reconstruit qu'à ce moment-là. Sans ça, « Identifier "X" not declared »
  alors que le fichier est juste là.

## État actuel

Voir `docs/REFONTE.md` pour l'avancement de la refonte action/RPG en cours.
