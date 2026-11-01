# Labyrinthe des Éléments — instructions projet

Jeu top-down en 2,5D (voir « La vue en volume ») en **Godot 4.7.2**, renderer `gl_compatibility` (seul backend couvrant
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
godot --path . -- --stage 9 --episode 2 --quest     # ouvre le CARNET DE QUÊTE, pour le capturer

# TOUT VÉRIFIER EN UNE COMMANDE — suites, contrôles de planches, verdict unique.
# Elle filtre aussi les SCRIPT ERROR, que les suites ne font pas échouer.
tools/verifier.sh
tools/verifier.sh --balance     # + la passe rapide d'équilibrage

# Tests (headless, aucun affichage requis)
godot --headless --path . --script res://tests/test_maze.gd
#   … test_portals, test_grid_mover, test_combat, test_victory, test_quest, test_pad
#
# ⚠️ UN TEST QUI PLANTE EST COMPTÉ COMME UN TEST QUI PASSE. Une erreur GDScript
# à l'exécution interrompt la fonction fautive et REND LA MAIN à l'appelant : la
# suite continue et conclut « TOUS LES TESTS PASSENT » sur un test qui n'a rien
# vérifié. Arrivé le 2026-08-28 sur un appel à une méthode inexistante.
# Toujours relire la sortie, ou la filtrer :
#   godot --headless --path . --script res://tests/test_combat.gd 2>&1 \
#     | grep -q "SCRIPT ERROR" && echo "UN TEST A PLANTÉ"
godot --headless --path . --script res://tests/test_balance.gd   # LENT (~30 min)
godot --headless --path . --script res://tests/test_balance.gd -- --quick   # ~3 min
#   ⚠️ La passe rapide (un niveau sur quatre, 4 parties) attrape la GROSSE
#   dérive — un mage injouable, un stage impossible — pas les écarts de
#   quelques points. Elle existe parce qu'un test d'une demi-heure ne se lance
#   jamais : il n'a pas tourné une seule fois pendant que cinq sorts majeurs
#   étaient réécrits.

# Fiches de référence des personnages et du bestiaire — RÉGÉNÉRER après tout
# changement d'équilibrage, elles sont générées et ne doivent jamais diverger.
godot --headless --path . --script res://tools/dump_reference.gd

# Assets : la planche source ne sert JAMAIS directement, tout passe par le pipeline
tools/.venv/bin/python tools/build_assets.py        # décor, gemmes, tuiles
tools/.venv/bin/python tools/build_characters.py    # les sept mages
tools/.venv/bin/python tools/build_stage_art.py     # vignettes des dix stages
tools/.venv/bin/python tools/build_bestiary.py      # les neuf créatures restantes
tools/.venv/bin/python tools/build_stage_tiles.py   # terrain TEINTÉ (repli des stages sans planche)
tools/.venv/bin/python tools/build_terrain.py       # terrain DESSINÉ — À LANCER APRÈS le précédent
tools/.venv/bin/python tools/build_menu.py          # portraits, cadre et fond de l'écran de sélection
tools/.venv/bin/python tools/build_warps.py         # les colonnes de téléportation
tools/.venv/bin/python tools/build_stage_props.py   # décor + monument de chaque stage
tools/.venv/bin/python tools/build_spell_fx.py      # orbe, impact, zone par mage
tools/.venv/bin/python tools/build_skill_icons.py   # icônes des sorts (fond magenta)
tools/.venv/bin/python tools/build_invocateur.py    # l'Invocateur, ses créatures, ses effets
tools/.venv/bin/python tools/build_ombre.py        # l'Ombre maléfique de la Faille + son gaz
tools/.venv/bin/python tools/build_prompts.py      # les 30 prompts de terrain + leurs références
tools/.venv/bin/python tools/build_prompts_menu.py # les prompts de l'écran « Choisis ton mage »
tools/.venv/bin/python tools/check_characters.py    # vérifie le découpage + le gobelin
tools/.venv/bin/python tools/check_profiles.py      # tous les left.png regardent-ils à GAUCHE ?
godot --headless --path . --import      # OBLIGATOIRE après tout nouveau PNG

# Contrôle visuel de l'implosion d'ombre : six instants sur une bande. Un effet
# de deux tiers de seconde ne se juge pas en jeu, et le chasser à la frame près
# avec --frames ne marche pas — le mage n'est jamais au même endroit.
godot --path . --resolution 1440x240 --script res://tools/preview_implosion.gd -- /tmp/implosion.png

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

**4bis. Les planches sources sont RANGÉES PAR NATURE.** `assets/peso&cover/`
n'est plus un tas : `mages/` (les huit planches de personnage), `sorts/` (icônes
et animations de sorts), `creatures/` (ennemis et invocations), `decor/`,
`interface/`, `terrain/`. Les tables de `build_characters.py` et
`build_bestiary.py` portent le sous-dossier dans leur CLÉ, ce qui leur permet de
lire deux dossiers avec un seul `SOURCE`.
⚠️ `export_presets.cfg` exclut désormais des DOSSIERS entiers. La seule planche
brute qui parte dans l'app est `interface/couverture.png`, que l'écran-titre
`preload`. Vérifier après tout changement : le filtre compare le chemin COMPLET
(`res://…`), un motif sans `*/` devant ne mord jamais — 30 Mo sont déjà partis
comme ça une fois.

**4. Les assets sont générés, pas bricolés à la main.** `tools/build_assets.py` est la
seule source des fichiers de `assets/sprites/`, `assets/tiles/` et `assets/ui/` ;
`tools/build_characters.py` celle de `assets/characters/` et `assets/enemies/`.
Les planches brutes restent dans `assets/raw/` (décor) ou `assets/peso&cover/`
(personnages, ennemis et sorts, telles que fournies — voir 4bis pour le rangement).

**5bis. Le jeu est en PAYSAGE sur téléphone.** Le **manche analogique** est à
gauche, les cinq boutons de combat à droite, le labyrinthe entre les deux.
L'échelle de l'interface est CALCULÉE (`Platform.apply_ui_scale`) pour qu'une
touche fasse 62 points quelle que soit la forme de l'écran — une constante ne
peut pas marcher, l'étirement varie du simple au triple entre portrait et paysage.

⚠️ **La géométrie de la barre de combat se DÉDUIT, elle ne se pose pas.** Les
six boutons sont en éventail régulier autour du pouce, et `CombatPad._fan()`
enchaîne trois conséquences : la corde entre deux voisins impose un rayon
d'éventail minimal, l'écran en impose un maximal, et quand le second est plus
petit que le premier ce sont les BOUTONS qui rétrécissent — jamais l'écart.
Deux défauts sont nés d'un placement écrit à la main : la fuite et le troisième
sort posés au MÊME angle (62 px de recouvrement, on visait l'un et on
déclenchait l'autre), puis un rayon constant qui sortait par le haut sur
téléphone. `tests/test_pad.gd` vérifie l'absence de chevauchement et la
présence à l'écran sur cinq tailles d'interface.
⚠️ Ces tailles sont des unités de MISE EN PAGE et non des pixels : un téléphone
en paysage n'offre qu'environ 690 x 330 unités là où son écran en fait 960 x 460.
Éprouvé sur les pixels bruts, le test passait pendant que trois boutons sortaient
de l'écran.

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

## La vue en volume (par défaut, `--2d` pour l'ancienne)

Le sol et les haies sont en 3D (`src/world/`), tout le reste est le `Level` 2D, dessiné
dans une SubViewport puis couché sur le sol (`WorldStage`). Personnages, sorts et ordre
d'affichage gardent donc leur code : un nouvel effet 2D marche sans rien ajouter ici.
⚠️ Activée par défaut le 2026-11-01 à la demande du joueur, mais sa fluidité n'a encore
JAMAIS été mesurée sur iPhone : à faire avec `--bench`, sur un téléphone.

```bash
godot --path .                                         # jouer, depuis l'écran-titre
godot --path . -- --stage 3 --screenshot /tmp/x.png --frames 40
godot --path . -- --2d --stage 3                       # l'ancienne vue, pour comparer
godot --path . --resolution 2532x1170 -- --auto-walk --cast --bench 10
```

- **La caméra ne tourne jamais** : le haut de l'écran reste le nord, les commandes ne
  changent pas. `CameraRules` déduit tout, `tests/test_world.gd` vérifie qu'on voit au
  moins autant qu'en 2D, que la texture tombe sur sa case et qu'un tap retrouve la sienne.
- **Les entités sont redressées** par `CameraRules.stand_scale()` : couchées sur le sol,
  la vue inclinée les écraserait de 17 %. Seuls les enfants d'`Entities` le sont.
- **L'éclairage se déduit de la planche** : `StageMood` écrit la luminosité voulue,
  `MazeView3D` mesure le dessin et en tire sa teinte. Les planches vont de 0,16 à 0,95.
- ⚠️ Ce qui doit rester en espace écran (`Ambience`) ne peut PAS être un enfant du
  `Level` : un CanvasLayer dessinerait dans la texture du sol.
- ⚠️ Passer par `Level.to_screen()` et non `get_canvas_transform()` : ce dernier répond
  dans la texture, plus à l'écran.
- ⚠️ La texture est à alpha PRÉMULTIPLIÉ (`blend_premul_alpha`) : c'est ce qui garde
  visibles les effets additifs sur un fond transparent.
- ⚠️ Pour mesurer, ne pas lire `delta` : le moteur le lisse sur des multiples de 1/120 s.
  `--bench` prend une vraie horloge, et c'est le p99 qui compte.

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

## Les prompts d'images

Les prompts de commande vivent dans **`docs/prompts/`**, rangés par nature :
`mages/` (les huit planches de personnage), `sorts/` (sorts et créatures), les
`terrain_*` avec leurs références dans `ref/`. `docs/PROMPTS.md` est la porte
d'entrée — elle les indexe et retient ce que dix planches ont appris. Le prompt et l'outil de découpage vont ENSEMBLE : le prompt impose ce que
l'outil sait vérifier, et l'outil échoue en silence sur tout ce que le prompt n'a
pas exigé.

✅ Refonte des mages FAITE le 2026-08-25 : les huit planches de personnage
viennent de `assets/peso&cover/refonte/`, toutes sur le même gabarit (6 x 4
cases de 256, grille IMPOSÉE). Ils occupaient leur case commune de 60 % à 93 %,
ils l'occupent maintenant de 62 % à 66 % — **écart entre mages x1,07**, vérifié
par `check_characters.py` à chaque passage.
⚠️ Les ANCIENNES planches restent en place et ne doivent pas être supprimées :
elles sont encore la source de l'orbe, de l'impact, de la zone et de la colonne
de téléportation de chaque mage (`build_spell_fx.py`, `build_warps.py`), à des
coordonnées relevées à la main dedans. Les planches d'effets de la refonte
(`refonte/*_fx.png`) ne sont pas encore arrivées.
⚠️ Ces planches n'ont PAS de canal alpha : fond gris uni, détouré par
`keyed_on_flat()`. Le seuil y est SERRÉ et c'est la connexité qui travaille — le
dos du Sorcier des Ténèbres est une robe noire sur gris très foncé, dont un
quart des pixels est à distance 2 du fond, dans le bruit de la planche. Un seuil
confortable lui mange les trois quarts du corps ; le fondu du bord, appliqué
ailleurs qu'au bord, rend translucide l'intérieur des robes sombres.
⚠️ La grille ANNONCÉE n'est pas celle qui est DESSINÉE : chaque pose flotte, et
la pose d'attaque déborde de 40 à 125 px dans sa voisine (le générateur la centre
sur le SORT, pas sur le mage). `_row_cuts()` découpe sur les vraies gouttières,
choisies par RÉGULARITÉ — ni la plus large ni la plus proche ne marchent, deux
rangées demandaient l'inverse l'une de l'autre.
⚠️ `check_characters.py` mesure aussi les MORCEAUX DÉTACHÉS : un contrôle qui ne
regarde que des hauteurs laisse passer un mage amputé de son écharpe.

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

⚠️ Le sol de la clairière n'a **aucun traitement particulier**. Il était réchauffé
(×1,45 en rouge) pour signaler l'objectif du temps de la maisonnette de bois ;
avec l'îlot il dessinait un damier de carrés clairs à cheval sur les couloirs,
qu'on prenait pour un autre terrain. Ce qui désigne l'objectif, c'est ce qui est
POSÉ dessus — l'îlot, son portail allumé, son sceau de gemmes.

⚠️ **Pas de sceau au-dessus du monument.** Il y en a eu un — un anneau portant
une pastille par gemme manquante — retiré le 2026-08-28 : le bandeau
d'information affiche DÉJÀ cette collection. Ce qui dit l'état de la porte, ce
sont la teinte froide de la maison scellée et l'onde chaude de son ouverture.

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
- **L'écran « Choisis ton mage » montre des PORTRAITS, pas les sprites de jeu**
  (2026-08-26). La vignette affichait la première pose de marche de face : un
  dessin vu de DESSUS, où l'on ne voit pas le visage, haut de 112 px dans une
  case de 142. Aucun réglage d'échelle n'y pouvait rien — c'est le point de vue
  qui était faux. Découpage par `tools/build_menu.py`, prompts dans
  `docs/prompts/menu/` (`tools/build_prompts_menu.py`).
  Le partage est la clé : le **modèle** dessine ce qui CHANGE (huit portraits, le
  fond), le **moteur** dessine ce qui SE RÉPÈTE (le cadre, la gemme, la lueur de
  sélection). Un seul cadre pour les huit — huit cadres générés séparément
  n'auraient jamais la même épaisseur ni la même gemme, et les cartes sont côte
  à côte à l'écran. Même leçon que les seize pièces de mur.
  Le **nom reste du texte**, jamais une image : lisible à toute taille, et il
  changerait de langue avant l'image.
  ⚠️ `cadre.json` porte la fenêtre et le sertissage en FRACTIONS, mesurés sur la
  planche : deux constantes écrites dans le moteur deviendraient fausses au
  premier cadre redessiné.
  ⚠️ Trois indices cumulés désignent la carte choisie (halo débordant tracé avec
  le cadre agrandi, cartes voisines assombries, teinte de l'élément par-dessus) :
  un seul ne suffisait pas, huit cartes également lumineuses ne se distinguaient
  pas. Repli prévu : un mage sans portrait garde l'ancien rendu.
- **Chaque épisode a son CARNET DE QUÊTE** (2026-08-28), ouvert par le livre en
  haut à droite, sous le bouton de pause — la seule zone libre de ce côté dans
  les deux schémas de contrôle. Il ne change AUCUNE règle : la mission existait
  déjà dans `LevelConfig`, il la met en phrases et la suit en direct. Ce qui
  manquait n'était pas « qu'ai-je d'autre à faire » mais « que suis-je censé
  faire ici, et où j'en suis » — l'écran affiche des compteurs, jamais une
  phrase.
  ⚠️ **Tout est DÉDUIT de la config, rien n'est recopié** (`QuestBook`). C'est la
  règle des fiches générées appliquée à l'interface : une quête qui annoncerait
  « 4 gemmes » sur un niveau qui en pose 6 serait un mensonge qu'aucun test
  n'attrape et qu'aucun joueur ne pardonne. Seule l'AMBIANCE est écrite à la
  main — dix phrases de chapitre, aucune ne porte de chiffre.
  `tests/test_quest.gd` relit les vingt épisodes et compare chaque ligne à la
  config. Il a déjà attrapé une attente fausse de sa propre écriture.
  ⚠️ Le carnet MET EN PAUSE et réutilise l'état `PAUSED` : lire sa mission
  pendant qu'un spectre vous court après n'est pas un choix, c'est une punition.
  Il se ferme au départ d'un niveau — sans ça il restait ouvert sur la mission du
  précédent quand DevTools relance la partie.
  ⚠️ Le « déjà vu » vit dans `Settings`, pas dans `Progress` : c'est une
  commodité d'affichage, pas un acquis, et `Progress` refuse d'écrire hors d'une
  sauvegarde chargée. Une session de dev ne l'ouvre jamais toute seule ; `--quest`
  le force pour la capture.
  ⚠️ La page S'ÉLARGIT avant de rapetisser son texte : sur téléphone en paysage
  il ne reste que 240 unités sous le bouton, et c'est la HAUTEUR qui manque, pas
  la largeur. Ordre des sacrifices ensuite : le corps du texte, les provisions,
  puis l'ambiance. Les objectifs et le bouton de fermeture ne partent jamais.
- **Les six sorts de la fiche sont une GRILLE 3 x 2, pas une liste** (2026-08-28,
  maquette `docs/prompts/menu/disposition_sorts.md`, variante 2). La liste posait
  le nom à gauche et ses chiffres contre le bord droit, à presque mille pixels de
  là : six allers-retours du regard par mage, sur un écran qui sert à en COMPARER
  huit. Chaque sort est maintenant une carte, et `AbilityRow` a disparu au profit
  d'`AbilityCard`.
  La carte est HORIZONTALE : l'icône à gauche sur toute la hauteur, le texte à
  droite en lignes ferrées à gauche. L'icône a d'abord été posée AU-DESSUS d'un
  texte centré ; elle n'y faisait qu'un tiers de la hauteur et se lisait comme
  une vignette de liste. Elle n'a plus ni disque ni bordure — la pastille ronde
  rappelait le bouton du pad, mais sur une icône pleine hauteur elle ne cerclait
  plus rien et lui volait le quart de sa surface.
  ⚠️ Le débordement de l'icône (`ICON_BLEED`) est BORNÉ et la carte ROGNE. Les
  icônes sont inscrites dans 70 % de leur image pour les boutons ronds du pad :
  sans débordement elles paraissent petites, avec trop elles s'impriment sur la
  carte voisine. Mesuré : à 0,19 le dessin arrivait à un pixel du bord.
  ⚠️ Ce qui dimensionne la carte n'est PAS le nom mais la LIGNE DE CHIFFRES :
  jusqu'à 90 caractères sur la Rune des Ténèbres, contre 23 pour le plus long des
  noms. Toute mise en page qui la suppose courte déborde sur ce mage-là seul.
  ⚠️ `AbilityCard.fit()` CHERCHE son réglage au lieu de poser puis rogner. Une
  passe unique qui retirait ce qui dépasse effaçait les chiffres de la Rune et de
  l'Implosion — les deux sorts qui en ont le plus à dire. L'ordre des sacrifices
  est écrit dans le code : la description, puis le disque de l'icône, puis le
  corps du texte ; le nom et les chiffres ne partent jamais.
  L'élément est monté sur la ligne du NOM du mage : sa ligne à lui seul coûtait
  vingt-deux unités prises sur la grille, soit une ligne de description dans
  chacune des six cartes.
- **Le terrain DESSINÉ prime sur le terrain teinté** (2026-08-25). Les dix stages
  ont désormais leurs planches dans `assets/peso&cover/terrain/` — sol, mur,
  décor — découpées par `tools/build_terrain.py`, qui s'exécute APRÈS
  `build_stage_tiles.py` et écrase son résultat. Trois découpages sans rapport :
  - le **sol** est une plaque pleine rendue raccordable par l'outil (décalage
    torique + fondu). On ne demande JAMAIS « seamless » à un modèle : il dessine
    un cadre pour faire semblant. Période portée de 3 à 6 cases, lue dans la
    LARGEUR de la texture et non plus codée en dur ;
  - le **mur** est un **autotile de 16 pièces**, une par configuration de voisins
    (haut 1, droite 2, bas 4, gauche 8). ⚠️ Les planches livrées dessinent des
    pièces qui **FLOTTENT** — magenta tout autour, y compris du côté à raccorder —
    et aucune ne respecte l'ordre demandé. L'outil n'en garde donc que TROIS (la
    croix et les deux barres), mesure leur topologie, et FABRIQUE les seize :
    prolonger un bras jusqu'au bord, ou y recopier le rebord de la barre
    perpendiculaire. Tout vient du dessin livré, rien n'est inventé ;
  - le **décor** remplace les props générés dans `stages/props/stage_N/{semis,lueur}`.
  ⚠️ Le détourage du magenta n'est PAS celui des icônes de sorts : ici les
  cristaux roses des Cavernes sont **plus magenta que le fond** (0,96 contre
  0,86). On sépare par CHROMATICITÉ — l'ombre portée garde la direction de
  couleur du fond, un cristal non — et on n'efface que ce qui touche le bord.
  ⚠️ `HEDGE_SHADE` ne s'applique QU'À la tuile de repli : appliquée à un mur
  dessiné elle repeint le dessin et défait l'écart de luminance imposé.
  ⚠️ Le SOL se dessine sur TOUTES les cases, murs compris, et la pièce de mur se
  pose dessus. Une pièce d'autotile ne remplit pas sa case ; sans sol dessous,
  ses angles arrondis montrent le fond de scène et tout le labyrinthe paraît
  cerné d'un trait NOIR. Même raison côté outil : la couleur est prolongée hors
  de la silhouette avant réduction, sinon le rééchantillonnage ramène du noir.
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
- **Le dégorgement ne corrige la COULEUR qu'au bord**, jamais à l'intérieur : la
  « magenta-ité » est aussi la signature du violet, et c'est elle qui avait
  obligé à écrire un détoureur séparé pour la Rune. L'atténuation d'ALPHA, elle,
  reste globale — c'est elle qui efface le fond vu à travers un dôme de verre.
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
- **Un ultime peut CHASSER au lieu de frapper.** Le Cyclone de l'Air lève trois
  colonnes autonomes sur la machinerie des invocations (`SUMMON_KINDS`), la
  Faille des ténèbres six ombres : ça chasse pendant que le mage fait autre
  chose, et ça vit dans le CombatSystem, donc `test_balance` peut le simuler.
  ⚠️ Un phénomène qui SUIT le mage a été essayé pour le Cyclone et jeté : si
  lentement qu'il suive, ça reste l'Orage du mage de la Foudre sous un autre
  dessin. C'est l'AUTONOMIE qui distingue, pas la vitesse de suivi.
  ⚠️ Ce qui chasse n'est pas forcément une créature : le cyclone n'a ni faces ni
  pose de coup, donc pas d'entrée dans `allies.json` et pas de `SummonVisual` —
  il a son propre nœud, et on ne lui donne pas de direction.
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
- **`Ability.pull_radius` / `pull_cells`** : le sort ASPIRE au lieu d'écarter.
  Miroir exact du souffle de l'Air (`_push_away` / `_haul_in`) — deux éléments
  qui déplaceraient dans le même sens ne se distingueraient plus. Le souffle
  porte volontairement PLUS LOIN que les dégâts : un sort qui n'aspirerait que
  ce qu'il frappe déjà ne servirait à rien, c'est le fait de ramener de loin ce
  qu'on va frapper qui fait le sort. Il ne dépose jamais une créature SUR le
  mage, et `pull_min` l'arrête AVANT le contact — mesuré : déposé au contact, le
  poursuivant frappe dans la seconde, et le sort offre le coup qu'il devait
  éviter. La butée doit rester DANS le rayon des dégâts, sinon le sort range la
  meute hors de portée de sa propre explosion. Elle ne repousse personne : une
  créature déjà collée y reste — le sort corrige ce qu'il provoque, pas ce
  qu'il trouve.
  ⚠️ L'aspiration recalcule son champ depuis `player_cell` au lieu de prendre
  `context.player_field`, qui est celui de l'IA et date de 300 ms : c'est le
  même piège que l'arrêt au corps à corps, et il ramènerait vers l'endroit où
  le mage ÉTAIT.
- **`Ability.summon_portals`** : le sort ouvre des passages AU LOIN au lieu
  d'appeler ses créatures autour du lanceur. C'est toute la différence entre
  invoquer et DÉCHIRER — l'Invocateur fait naître ses bêtes à ses pieds et le
  trajet est leur contrepartie ; une faille s'ouvre là où sont les proies. Les
  portes sont plafonnées (une par ennemi viderait un stage tardif d'un seul
  geste) et ne s'ouvrent jamais SUR la case d'une proie, même règle que le refus
  du dernier pas. Sans proie, le sort est REFUSÉ et ne coûte rien : un ultime
  gagné en quatre kills ne se dépense pas dans un couloir vide.
  `summon_cap` relève le plafond commun pour ce sort seul — celui-ci existe pour
  empêcher l'Invocateur d'accumuler lancer après lancer, ce qu'un ultime à usage
  unique ne peut pas faire.
- **`Ability.residue_duration`** : une explosion qui laisse une trace n'est plus
  un instant, c'est un LIEU. La zone dérivée est fabriquée comme les pics de la
  ligne de terre (`_residue_of`) et ne reprend PAS les dégâts de l'explosion —
  une flaque qui referait le coup entier serait le vrai sort, et l'explosion son
  décor. Elle naît après `_apply_area` : sinon la créature qu'on vient de
  ramener serait empoisonnée avant d'avoir encaissé.
- **`Ability.poison_duration` / `poison_damage`** : long, faible et FIXE, là où
  la brûlure est courte, violente et proportionnelle au coup. Il ne récompense
  pas la puissance du sort mais le fait d'avoir tenu quelqu'un dans l'ombre, et
  il SUIT sa victime hors de la zone. Il tique à la SECONDE et non au demi-tick
  des zones : sur de petits dégâts entiers, l'arrondi de `damage * ZONE_TICK`
  doublerait en silence le chiffre annoncé au joueur.
- **`Ability.slow_sustained`** : l'englu tient tant que la créature est dans la
  zone. Le drapeau ne change pas `slow_duration`, il en change le SENS — ce
  n'est plus la durée de l'effet mais sa TRAÎNÉE une fois dehors. Sans lui, un
  ralentissement décompté rend l'allure à qui reste PLANTÉ dans le sort, soit
  l'inverse de ce qu'un piège doit faire. Il se réarme par FRAME et non au tick
  de zone : la traînée est plus courte que l'intervalle des ticks, donc au tick
  l'ennemi retrouverait son allure deux fois par seconde. Le champ de distances
  passe alors par `_field_from`, sans quoi c'est un BFS par zone et par frame.
  ⚠️ Retenir et RONGER vont ensemble : un englu soutenu sur une zone qui ne
  prélève qu'une fois punit le passage, pas la présence — l'ennemi retenu ne
  paie alors plus rien pour le temps qu'il y perd, ce qui est exactement à
  l'envers. Les dégâts restent sur le tick, c'est une usure et non une rafale.
- **UN SEUL PORTAIL, une seule couleur, peint au shader** (`portal.gdshader`,
  banc : `tools/preview_portal.gd`). Ses états ne sont pas dessinés : `Portal`
  les joue par la vitesse de rotation et l'éclat. Il tient dans 0,95 case — un
  couloir en fait une — et se compose NORMALEMENT : en additif il se délavait
  sur les stages clairs, l'additif ne sachant qu'éclaircir. Contrairement aux
  personnages, il reste COUCHÉ sur le sol en 2,5D : `setup` annule le redressement
  de `WorldStage._stand_up`. Portails, gemmes et potions passent devant le monument :
  mesuré sur 400 parties, il a recouvert une gemme et quatre portails.
  ⚠️ Le repère de couleur est perdu volontairement (« le portail vert » était
  mémorisable) ; ce qui les distingue est leur déphasage.
- **L'AMBIANCE DE LA CARTE vit sur un CanvasLayer** (`Ambience`) : vignette
  teintée par le biome, halo qui suit le mage, poussière en `CPUParticles2D`.
  Aucune lecture du tampon d'écran — deux nappes en composition ordinaire
  suffisent, et y lire coûterait une copie de l'écran par passe en
  `gl_compatibility`.
  ⚠️ Le mode de composition d'un ShaderMaterial se déclare DANS le shader
  (`render_mode blend_add`) : un `CanvasItemMaterial` en `next_pass` ajoute une
  passe sans rien changer à la première.
  ⚠️ Le contraste centre/bord se MESURE (anneaux de luminosité autour du mage) :
  il vaut **1,5** et ne doit pas monter. À 2,3 — le premier réglage — les coins
  perdent la moitié de leur lumière, et avec eux les couloirs et les poursuivants
  qui y arrivent. Joli en capture, illisible en jeu.
  ⚠️ L'UI est au calque **2**, l'ambiance au **1**. Sans ce numéro explicite
  l'interface se faisait assombrir avec le décor — mesuré, 44 % de luminosité
  perdue sur le bandeau, et ça se regarde sans se voir.
- **Pas d'addon VFX** : le renderer est `gl_compatibility` (iOS + Web + desktop
  d'un seul code) et la plupart supposent Forward+. Shader + CPUParticles2D
  suffisent — CPU et non GPU, pour un rendu identique sur mobile.
- **Chaque élément MARQUE ses coups d'un trait** (brûlure, trempe, ébranlement,
  ponction, arc, bourrasque, écho — `CombatSystem`, bloc TRAITS) : c'est ce qui
  fait sept mages et non sept teintes. Les zones n'en déclenchent aucun, et les
  traits ne se composent jamais entre eux.
- **Une animation image par image se cale sur une ANCRE, pas sur sa case.**
  `build_spike_anim.py` : l'onde du Grand souffle sur le centre de son anneau,
  le cône sur sa pointe — parce que c'est ainsi que le moteur les pose (sprite
  centré sur le mage / décentré pour que son bord gauche tombe sur lui). La
  boîte est bâtie AUTOUR de l'ancre et doit être SYMÉTRIQUE, sinon l'ancre n'est
  pas au milieu de l'image et le sprite centré ne l'est pas sur le mage.
  ⚠️ Une planche d'animation n'est pas forcément sur sa grille : celle du Grand
  souffle grandit d'image en image et le générateur les a resserrées vers la
  gauche (35 à 72 px). On découpe sur les gouttières — mais ici c'est leur
  LARGEUR qui tranche et non la régularité, les images n'étant pas également
  espacées.
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
  ⚠️ Une planche d'APPOINT (des poses ajoutées après coup) n'est jamais à la même
  échelle que la première : mesuré 22 % d'écart sur l'Ombre. On la remet à
  l'échelle sur la LARGEUR DU MANTEAU — la hauteur enfle avec le jet — et on la
  fait passer par le MÊME outil, donc le même alignement, sinon la créature
  sursaute au moment de frapper. Voir `tools/build_ombre.py`, qui consigne six
  pièges de découpage dont deux silencieux (une toile d'alignement trop courte
  ampute le bas des poses ; un étiquetage sur le voile fond quatre poses en une).
  ⚠️ `SummonVisual.HEIGHTS` donne des hauteurs de CASE, jamais de créature, et
  les cases ne sont pas remplies pareil : la gargouille occupe 88 % de la
  sienne, l'Ombre 67 % — sa case doit tenir le jet de gaz, qui descend 50 px
  plus bas que sa fumée au repos. À hauteur de case égale, elle paraissait donc
  plus PETITE alors qu'elle était réglée plus haut.
  ⚠️ Une créature dont la planche n'existe pas encore EMPRUNTE celle d'une
  autre, teintée (`SummonVisual.STAND_INS`), au lieu de lever une erreur : la
  mécanique se règle avant que le dessin n'existe, et une invocation invisible
  se lit comme un sort cassé. La teinte est assez sombre pour qu'aucune capture
  ne soit prise pour l'apparence définitive.
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
- **Un `Label` en repli automatique MENT sur sa taille tant qu'il n'a pas eu sa
  largeur.** Il calcule son minimum d'après la largeur qu'il a DÉJÀ — zéro pour
  un libellé qu'on vient de créer — et le garde en cache jusqu'à l'image
  suivante ; `Control` refuse ensuite toute taille inférieure. Mesuré sur le
  carnet : une ligne d'objectif se voyait imposer 722 px de haut. Elle
  S'AFFICHAIT bien (le texte se dessine en haut de sa boîte), mais la mise en
  page avançait de 722 et la moitié de la page partait sous l'écran. Ne jamais
  relire `label.size.y` après l'avoir posé : mesurer avec la POLICE
  (`get_multiline_string_size`), qui, elle, ne se trompe jamais.
- **En coordonnées écran, l'axe Y descend** : un arc qui monte a un sinus
  NÉGATIF (angles entre 180° et 360°). Une erreur de signe envoie les boutons
  hors de l'écran.
- ⚠️ **Une planche déposée à la RACINE de `peso&cover/` part dans l'app.** Le
  filtre exclut des dossiers (`mages/`, `sorts/`, `creatures/`…) : ce qui n'est
  rangé nulle part n'est couvert par rien. Mesuré le 2026-08-28 : 22,9 Mo de
  planches que le jeu n'ouvre jamais. Ranger, ou ajouter un motif.
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
- ⚠️ **`build_characters.py` n'écrit plus le gobelin ni le spectre** : leurs bandes
  de 17 poses viennent de `build_enemies.py`. Il les MESURE encore, car ils fixent
  la largeur de case commune. Les réécrire les ramènerait à six poses sans erreur.
- ⚠️ **Le profil dessiné ne dit pas dans quel sens part le sort.** Six mages sur huit
  tiraient dans leur dos sur un profil : le générateur lance presque toujours vers
  la droite. `attack_mirror` reprend la pose du bon profil, `attack_recentre` ramène
  le corps quand un sort posé au sol fausse le calage sur les pieds (Terre, Air).
  `check_characters.py` échoue si un sort part du mauvais côté.
- **Les retours visuels d'un coup se testent dans `tests/test_animation.gd`** : les
  vrais nœuds, frame par frame. Une capture ne tombe jamais sur le bon instant.

- ⚠️ **Le coup au contact touche à l'IMPACT, pas au départ** (`MeleeSwing`, partagé par
  le `Level` et `test_balance`). `Bestiary.windup` donne l'armement, `impact_pose`
  l'image où l'arme arrive, et `Enemy` cale sa bande dessus. Le mage sorti de portée
  pendant l'armement a esquivé. Mesuré avec le contact du jeu : 7 % de coups portés
  en moins, mêmes taux de mort en passe rapide. Un contact différent dans la simulation fausse
  cette mesure : `test_balance` doit garder `CATCH_DISTANCE` et le refus du dernier pas du jeu.

- ⚠️ **Le générateur ne pose pas ses rangées à la même hauteur** : pieds à 108 de face et
  93 de profil sur le Feu, et le mage flotte au-dessus de son ombre. `align_rows` de
  `build_enemies.py` recale chaque rangée sur sa marche, pour les mages et les ennemis.
  La case change alors de remplissage : `frames.json` porte `body_height`, et `Player`
  et `Enemy` (`Bestiary.body`) en déduisent une taille à l'écran qui ne bouge pas.
- ⚠️ **Le générateur ne tient pas la consigne « même corps » entre deux planches** :
  mesuré sur les mages, le corps dérive jusqu'à 32 px en marche, et l'attaque est 18 %
  plus petite (30 % sur l'Ombre). `steadied` les recale (dernière image d'attaque
  contre la marche), et `check_animated` le vérifie sur les mages. Les huit mages passent par `build_enemies.py`, plus par
  `build_characters.py`, qui ne reste que la mesure de largeur et les anciennes planches.
- ⚠️ **LE JOUEUR VEUT DES PAS MOYENS, dans toutes les directions.** Des enjambées d'une
  demi-hauteur ont été rejetées en jeu (« catastrophe »), et les deux pieds collés aussi
  (« on dirait qu'il saute »). Ne pas réviser ce choix pour réduire le glissement.
  `SMALL_STEP_FRAMES` ne joue que les images moyennes des planches actuelles, et
  `guide_marche.png` impose un écart d'un tiers de hauteur. Le texte seul ne suffit pas au
  générateur : joindre le guide. Juger image par image, agrandi : le bâton touche le
  sol et compte comme un pied dans les mesures (l'Air semblait rater un pas, à tort).

## État actuel

Voir `docs/REFONTE.md` pour l'avancement de la refonte action/RPG en cours.
