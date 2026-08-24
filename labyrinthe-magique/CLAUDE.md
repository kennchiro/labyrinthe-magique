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
godot --path . -- --demo --demo-stage 6   # essai : décor du stage 6, sans mourir
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

# Fiches de référence des personnages et du bestiaire — RÉGÉNÉRER après tout
# changement d'équilibrage, elles sont générées et ne doivent jamais diverger.
godot --headless --path . --script res://tools/dump_reference.gd

# Assets : la planche source ne sert JAMAIS directement, tout passe par le pipeline
tools/.venv/bin/python tools/build_assets.py        # décor, gemmes, tuiles
tools/.venv/bin/python tools/build_characters.py    # les sept mages
tools/.venv/bin/python tools/build_stage_art.py     # vignettes des dix stages
tools/.venv/bin/python tools/build_bestiary.py      # les neuf créatures restantes
tools/.venv/bin/python tools/build_stage_tiles.py   # le terrain des dix stages
tools/.venv/bin/python tools/build_warps.py         # les colonnes de téléportation
tools/.venv/bin/python tools/build_stage_props.py   # décor + monument de chaque stage
tools/.venv/bin/python tools/build_spell_fx.py      # orbe, impact, zone par mage
tools/.venv/bin/python tools/build_skill_icons.py   # icônes des sorts (fond magenta)
tools/.venv/bin/python tools/build_invocateur.py    # l'Invocateur, ses créatures, ses effets
tools/.venv/bin/python tools/check_characters.py    # vérifie le découpage + le gobelin
tools/.venv/bin/python tools/check_profiles.py      # tous les left.png regardent-ils à GAUCHE ?
godot --headless --path . --import      # OBLIGATOIRE après tout nouveau PNG

# Contrôle visuel des invocations, hors partie : les 3 créatures x 4 directions
# x (repos, coup) sur une seule planche — impossible à voir en jouant.
godot --path . --resolution 1200x390 --script res://tools/preview_summons.gd -- /tmp/summons.png

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
- sa planche est `mage_invocateur.png` (**remplace le JPEG le 2026-08-24** —
  vrai canal alpha, dessin bien plus fin, quatre fois plus de poses). Elle est
  découpée par **`tools/build_invocateur.py`** (mage + créatures + effets), pas
  par build_characters.py, parce qu'elle n'a **aucune grille** : ses 14 poses de
  marche, ses 6 poses de sort, ses 4 créatures et sa douzaine d'effets sont
  posés librement. Les boîtes de l'outil sont les **boîtes englobantes des
  formes connexes**, relevées par étiquetage — exactes au pixel ;
- ses orientations restent **inégales** : 4 poses de face, 4 de dos, 6 de profil
  GAUCHE, et rien vers la droite — ni pour lui ni pour son dragon. La droite est
  le miroir de la gauche, comme sur la planche du spectre ;
- ⚠️ la planche ne dessine **pas le bâton dans toutes les poses de marche** (il
  manque dans 3 des 6 poses de profil, dans 2 des 4 poses de dos). Le cycle suit
  malgré tout l'ordre de la planche : l'orbe du bâton apparaît et disparaît
  pendant la marche. C'est le DESSIN, pas le découpage ;
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

## Le mode démo

Lancé par le bouton **ESSAI** de la sélection des mages (ou `--demo`). Il sert à
deux choses, et la seconde est venue après : essayer les sorts d'un personnage —
tout est débloqué, rien ne se recharge, on ne meurt pas — et **visiter les
décors**. Les dix stages y sont préparés en terrain d'essai : même labyrinthe
clément, seule la PEAU change (tuiles, props, monument, roster), parce que c'est
`config.stage` que lisent le rendu, le semis de décor et la maison.

On en change par les flèches en haut de l'écran, au clavier par `Page↑` / `Page↓`
(ou `[` / `]`), et en capture par `--demo-stage N`. Le tour est cyclique.

⚠️ Rien de tout cela n'existe hors démo : deux flèches qui changent de stage en
pleine partie seraient une triche, pas un outil. `GameManager.demo_stage()` le
garantit à la source.

## Fiches de référence

`docs/PERSONNAGES.md` et `docs/BESTIAIRE.md` listent chaque mage avec ses six
créneaux, chaque créature avec ses rapports, et les PV réels stage par stage.

⚠️ Les deux sont **GÉNÉRÉS** par `tools/dump_reference.gd`, qui lit
`CharacterCatalog`, `Bestiary`, `LevelConfig` et `CombatSystem`. Ne jamais les
éditer à la main : une fiche recopiée ment dès le premier réglage, et une fiche
qui ment est pire que pas de fiche — on finit par corriger le jeu pour qu'il
colle au document. Corriger un chiffre se fait dans le code, puis on régénère.

## Les monuments de stage

La « maison » de chaque stage est un **îlot flottant** découpé de
`assets/peso&cover/maison_stage.png` par `tools/build_stage_props.py` — dix îlots
dans l'ordre des stages, cinq par rangée, chacun portant le portail et le décor
de son thème.

Cette planche a un **vrai canal alpha** : rien à détourer. Le travail se réduit à
trois règles mesurées — regrouper par case de la grille 5×2 pour que les rochers
flottants restent avec leur île (tous à moins de 15 px, sauf quatre poussières
au-delà de 26) ; recadrer sur l'alpha **visible** (> 10) et non sur tout pixel non
nul, le halo de lueur descendant à alpha 4 gonflait la boîte de 24 px et
l'affichage s'en trouvait 10 % trop petit ; jeter ce qui traîne loin de tout îlot.

⚠️ `House` cadre le monument dans une **boîte à deux bornes** (3,8 × 4,6 cases) et
non sur sa seule largeur : les anciens monuments étaient larges, ces îlots sont
hauts (280×460), et une mise à l'échelle sur la largeur en aurait fait six cases
de haut. Le sceau des gemmes suit le **sommet réel** du sprite, mesuré au moment
du `setup()` — à hauteur fixe, il tombait au milieu de l'île.

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

⚠️ **La convention ne dit PAS de quel côté regarde la rangée de profil**, et la
supposer coûte cher : lue comme la gauche sur les neuf planches, elle regarde en
réalité vers la **DROITE sur sept d'entre elles**. Sept créatures ont donc
marché à reculons pendant des semaines. C'est ce que déclare `profile` dans
`build_bestiary.py` (défaut `"right"`, exceptions écrites : l'ombre et le démon
de cristal). Rien ne l'attrape tout seul — les fichiers existent, les bandes
font la bonne taille, `check_characters.py` ne juge que le CADRAGE et les tests
headless ne chargent aucune texture. D'où **`tools/check_profiles.py`**, qui
pose côte à côte la pose de foulée de chaque `left.png` : elles doivent TOUTES
regarder à gauche. Les indices qui tranchent, dans l'ordre — l'œil ou la
gueule ; la traînée du coup, qui part DEVANT ; la poussière et la cape, qui
restent DERRIÈRE.

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
- **Le roster est cumulatif ET la nouveauté passe devant.** Le stage N contient
  les espèces des stages 1 à N — mais l'effectif plafonne (huit poursuivants au
  stage 10 pour onze espèces), donc l'ordre de placement compte. `LevelConfig`
  range la **nouveauté du chapitre en premier** (`_build_lineup`), sinon c'est
  elle qui tombe : mesuré, le Chevalier Noir et le Golem de Givre n'entraient
  jamais en jeu. Les anciennes suivent, décalées d'un cran à l'épisode 2.
  Invariant vérifié par `test_combat` (`_test_rosters`).
- **Braiding obligatoire** (~30-38 % des culs-de-sac supprimés) : un labyrinthe parfait
  rend la poursuite injuste (impasse = mort sans recours).
- **Points de vie** = ceux du personnage + le bonus du stage (0/+1/+2) : la tournée dure 1 à 3 minutes,
  un seul PV donnait 90 % de captures en simulation.
- **Boussole** : direction à vol d'oiseau vers la gemme la plus proche **en distance de
  chemin**. Elle donne un cap, jamais un itinéraire — sinon le labyrinthe ne sert plus.
- **La signature visuelle d'un sort est une DONNÉE de la compétence**
  (`Ability.projectile_scale`, `projectile_speed`, `trail_density`, `shockwave`,
  `flames`), pas du personnage. Deux sorts de même forme se ressemblaient trait
  pour trait — le jeu donnait la même orbe à tous les projectiles d'un mage.
- **Le seuil d'ultime suit la constitution** : `kills = base_health + 1`, sauf le
  Suprême (8, ultime le plus puissant) et l'Invocateur (6, ses kills viennent de
  ses invocations). Un mage fragile atteint son ultime plus tôt.
- **Un ULTIME a le droit de casser une règle** — `Ability.pierces_walls` mesure le
  rayon à vol d'oiseau là où tout le reste du jeu utilise la distance de chemin.
  Condition non négociable : que ça se voie (l'onde de choc géante).
- **Le générateur d'images NE RESPECTE PAS l'ordre du prompt.** La table de
  `build_skill_icons.py` relève ce que chaque case MONTRE, jamais ce qui a été
  demandé — vérifier la planche avant de découper.
- **Le dégorgement se mesure en « magenta-ité »** (ce qu'un pixel a de rouge ET
  de bleu en plus de son vert), jamais par un réglage propre à un élément : une
  règle taillée pour le feu virait l'eau au turquoise. Elle sert aussi à rendre
  TRANSPARENT ce qui est translucide — le fond vu à travers un dôme de verre.
- **Les icônes de sorts sont commandées sur FOND MAGENTA UNI**, jamais en
  transparence : les modèles d'image tiennent mal l'alpha. Détourage par TEINTE
  (300°), pas par distance RGB — les halos roses d'une flamme sont trop proches
  du magenta en distance brute. Tout le magenta part, y compris ENCLAVÉ.
  L'échelle se fait sur la DIAGONALE : les boutons tactiles sont ronds.
- **`Ability.Kind.STORM`** : un nuage qui SUIT le mage et frappe tout seul. La
  seule chose du jeu qui accompagne le joueur au lieu de l'attendre quelque part.
  Relancer le remet à neuf — deux nuages doubleraient la cadence en silence.
- **`Ability.Kind.CHAIN`** : un arc qui rebondit d'ennemi en ennemi en
  s'épuisant. Le parcours est calculé au lancement puis joué relais par relais —
  le recalculer à chaque saut laisserait la chaîne changer d'avis en vol.
- **`_apply_damage` a DEUX freins distincts**, `with_trait` et `empowered`. Un
  sort qui chaîne déjà ne doit pas déclencher le trait de son élément, mais doit
  quand même profiter de l'exaltation. Les dégâts dérivés (brûlure, arc, écho)
  passent `false, false`.
- **`Ability.empower_bonus`** renforce tous les coups du mage pendant un temps.
  Il ne s'applique QU'AU COUP D'ORIGINE : appliqué aux dégâts dérivés (brûlure,
  arc, écho, météore), il se multiplierait au lieu de s'ajouter — sans rien
  casser, juste en faussant tous les chiffres.
- **`Ability.Kind.WAVE`** : un front qui DÉFERLE devant le lanceur et frappe ce
  qu'il traverse. La boule de feu cherche une cible, la vague prend le couloir.
  Chaque ennemi n'encaisse qu'une fois — sans mémoire des touchés, il prend un
  coup par case traversée.
- **`Ability.arc`** limite un souffle à un cône devant le lanceur, mesuré à vol
  d'oiseau : le joueur juge « devant » à ce qu'il voit, pas à la topologie.
- **Sorts à CHARGES** (`Ability.charges`) : N lancers d'affilée, puis une
  recharge qui les rend TOUTES. Tant qu'il reste une charge, le sort est prêt.
  Les charges s'affichent en chiffres au clavier, en pastilles au pouce.
- **Zones-pièges** (`Ability.snare` / `snare_burn`) : appliquées UNE FOIS par
  créature et par passage, avec verrou. Une zone tique deux fois par seconde —
  sans verrou, elle reprend sa victime à chaque tick et l'ennemi ne repart jamais.
- **Pas d'addon VFX** : le renderer est `gl_compatibility` (iOS + Web + desktop
  d'un seul code) et la plupart supposent Forward+. Shader + CPUParticles2D
  suffisent — CPU et non GPU, pour un rendu identique sur mobile.
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
  Côté image, `SummonVisual` lit **`assets/allies/allies.json`** exactement comme
  `Player` lit son `frames.json` : une BANDE par créature et par direction
  (`hframes`), poses d'inaction d'abord, poses de coup ensuite, aucun nom de
  fichier ni nombre de poses codé en dur. La **case est commune à toutes les
  directions d'une créature** — c'est elle qu'on met à l'échelle, pas le dessin :
  le dragon qui pique a les ailes rabattues, celui qui monte les a déployées, et
  ce rapport-là doit tenir. La teinte de coup a disparu avec sa raison d'être :
  les créatures ont maintenant une vraie pose de morsure et de souffle.
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
