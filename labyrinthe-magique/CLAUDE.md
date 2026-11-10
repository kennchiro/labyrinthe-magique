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

Les **Réglages** (`SettingsPanel`, ouverts depuis la pause et l'écran-titre, sur écran
tactile seulement) offrent trois déplacements et l'éditeur de disposition. Tout persiste
dans `user://settings.cfg` (`Settings`, séparé de `Progress` : une préférence ne s'écrit
que sur un geste du joueur, elle peut donc s'écrire toujours).

La **croix** est un style de `TouchStick` (`--cross`). ⚠️ Ce ne sont pas quatre carrés à
viser, le défaut qui avait fait retirer `TouchDPad` : la zone du manche est partagée en
quatre secteurs, et il suffit de poser le pouce du bon côté.

L'**éditeur** (`TouchLayoutEditor`) déplace, agrandit et estompe chaque commande, ou
toutes ensemble, et passe le jeu en gaucher. `TouchLayout` ne garde que ce que le joueur
a changé, en fractions d'écran : le reste suit toujours la géométrie déduite ci-dessus.
⚠️ `TouchLayout.settle` refuse tout chevauchement et les zones réservées (la barre du mage,
la pause, le carnet), sinon le placement libre recréerait le défaut de l'éventail.
`--pause --settings --layout-editor` le capture, `--settings-file F` protège les réglages
du joueur. `tests/test_touch_layout.gd` passe par ses gestes et par une vraie partie.
⚠️ **La pause et le carnet ne sont PAS dans le coin en tactile.** Ils y couvraient l'ultime,
le haut de l'éventail par défaut, qui ne passe pas par `settle`. `TouchLayout.fit_corner`
les range à gauche de ce que l'éventail occupe en haut (`CombatPad.reach_from_right`), ce qui
dépend de l'écran. Au clavier, ils restent dans le coin de `scenes/main.tscn`.
- Les commandes se rangent derrière la pause, la victoire et les réglages
  (`UIManager._refresh_controls`) : elles lisent leurs touches sans les nœuds, un sort posé
  sur « Menu » partait avec lui.
- Une gemme, une potion ou un ennemi sous un bouton de l'éventail rend ce bouton transparent
  et reçoit un repère (`CombatPad.show_beneath`, nourri par `GameManager._watched_things`).
  Le manche n'en fait rien : il est déjà translucide.
- L'objectif s'affiche en bandeau au début de chaque niveau, sous la barre du mage, dans la
  largeur laissée par l'éventail (`UIManager._show_objective`). Le niveau gagné à la victoire
  s'annonce sur l'écran de victoire, et non plus dessous.
⚠️ Dans un Control construit en code, `set_anchors_and_offsets_preset` et jamais
`set_anchors_preset` : il garde sa taille nulle, et un test qui pose les tailles à la main
ne le voit pas.

Le tactile a aussi le mode **« toucher le chemin »** (façon
Dota) : un tap sur une case praticable donne un ordre de marche — champ BFS
descendu pas à pas (`Player.walk_to`), marque pulsante sur la case
(`MoveMarker`), toute entrée manuelle ou téléportation annule l'ordre. Le
**manche reste le défaut**. La
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
- **La carte vit, un mouvement dominant par stage** : `StageMood.MOTION` (vent, nappes,
  éclats, éclairs, ce qui court au sol ; `maze_wall`, `maze_floor`, `drift.gdshaderinc`),
  `DecorLayer.PLANTS` (`decor_sway`) et les lueurs (`decor_flicker`), `Ambience.AIR` (lucioles,
  neige, braises...). Le vent ne déplace aucun sommet : une haie qui bouge ne dirait plus
  où est le mur. ⚠️ Non mesuré sur iPhone : à faire avec `--bench` avant de conclure.
- ⚠️ Un carrefour n'est PAS une plaque carrée : ses coins dépassaient des bras voisins,
  sans flanc dessous. `_closed_corners` ne referme que les angles entourés de haies.
- Objets de décor seuls : `tools/build_terrain.py --decor`. `magenta_residue` retire
  l'ombre magenta peinte sur les planches, en s'arrêtant aux contours sombres. Au-delà de
  20 % de l'objet, il n'y touche pas : ce violet EST l'objet (stages 2 et 5).

## Les vingt-quatre personnages

`Mage du Feu` · `Mage de l'Eau` · `Mage de la Terre` · `Sorcier des Ténèbres` ·
`Mage de la Foudre` · `Mage de l'Air` · `Invocateur` · `Sorcier Suprême` ·
`Chronomancien` · `Mage de la Peste` · `Porte-Lumière` · `Ange de la Mort` · `Ange des Étoiles` · `Archange d'Acier` · `Démon du Pacte` · `Démone de la Discorde` · `Roi de Braise` · `Chevalier Écarlate` · `Geôlier` · `Archange du Ciel` · `Chérubin` · `Dragon des Abysses` · `Croupier des Enfers` · `L'Avide`.

⚠️ **Pour tout nouveau personnage, n'oublie pas l'effet magique DRAMATIQUE de chaque sort**
(demande du joueur, 2026-11-03). Les six créneaux (attaque, trois sorts, fuite, extra) ont chacun
un effet qui se voit EN JEU, à l'échelle réelle, et qui dit ce que fait le sort. Le geste du
personnage ou le chiffre de dégâts ne comptent pas comme un effet.
- **Trois temps** : le départ (éclat ou charge sur le lanceur), le coup (une forme propre au
  sort, lumineuse et plus grande que la case), puis une trace qui s'éteint (braises, fumée,
  runes, sillage). Un éclat de 0,2 s ne se voit pas en jouant.
- **La taille suit le rang** : l'attaque tient environ une case, un sort deux ou trois, et
  l'extra prend une grande part de l'écran. Les gros coups et l'extra secouent la caméra (`_shake`).
- **La fuite se voit aux deux bouts**, là où il part et là où il arrive (`ESCAPE_RADIUS`,
  `ESCAPE_TIME`).
- Un dessin par sort (`PaintedFx`, `test_animation`) : une recoloration ne compte pas.
- **Contrôle** : une capture par créneau, avec un ennemi collé, à plusieurs instants :
  `--demo --character X --kills 9 --hunter --skill N --skill-delay 0.2 --frames F --screenshot P`,
  F de 13 à 50. Un créneau vide sur toutes les captures est un défaut. ⚠️ Certains sorts
  demandent un contexte (Contagion et Transfusion, Rengaine, Lien de Souffrance) : la capture les
  montre refusés, il faut alors les voir en jouant.

Le **Chronomancien** (élément Temps) est né animé et peint au shader : il n'a ni planche
`SHEETS` ni `impact.png`, `orb.png` ou `warp.png` (`_load_character_fx` met le quad peint à
leur place). Ses sorts lisent la TRACE du mage que tient `CombatSystem` : le Retour y
revient, le double de l'Écho la rejoue. L'Arrêt du temps passe par l'ébranlement ; les jets
ennemis lisent `time_factor_at`, et le `Level` fige les repaires et les retours d'ennemis.
⚠️ Les bots d'équilibrage n'utilisent aucune fuite, le Retour compris.

Le **Mage de la Peste** (élément Poison) est fait pareil. Ses dégâts sont des DOSES de venin
(`CombatSystem._venom`, trois au plus) qui prélèvent ensemble ; elles sont distinctes de
`_poisoned`, le poison fixe des Ténèbres. Aucun poison ne touche les repaires, ce qui rend
les niveaux où il faut les abattre plus durs pour lui.

Le **Porte-Lumière** (élément Lumière) est fait pareil. Sa lumière AVEUGLE : `EnemyAI.blind_left`
fait errer l'ennemi, qui ne frappe plus. `CombatSystem._blind_locks` empêche qu'il le reste en
permanence, et seule l'Aube passe outre. La Lance (`Kind.BEAM`) suit les couloirs : elle part du côté où regarde le mage, puis vers
la proie la plus proche, sans repasser sur ses pas (`_beam_path`). ⚠️ `build_enemies.py` fixe l'échelle de son attaque (`strike_scale`) :
égaliser les hauteurs la faussait à cause de sa lance, et les ailes l'élargissent.

L'**Ange de la Mort** (élément Mort) est fait pareil. Son trait, la Sentence, achève un ennemi
passé sous un seuil de PV (`SENTENCE_BELOW`, ou `Ability.execute_below`). Les coups mortels de son
élément donnent des âmes (`_souls`, trois au plus) que `Kind.SOULS` lâche, avec une âme de base :
le sort n'est donc jamais mort en début de niveau. Le Glas marque (`_marked`) et l'Heure dernière
passe après un temps, de gauche à droite, comme sa faux à l'écran (`Kind.LAST_HOUR`).

L'**Ange des Étoiles** (élément Étoiles) est fait pareil. Elle pose des étoiles (`_stars`, trois au
plus) et `_on_star_ray` brûle ce qui passe sur les rayons qui les relient, À VOL D'OISEAU, par-dessus
les haies. Son trait, Astre, compte les coups (`_star_marks`), et sa Nuit réutilise `Kind.DAWN`.

L'**Archange d'Acier** (élément Acier) est fait pareil. Son attaque est un projectile à rayon, dont le
visuel `onde_marteau` fend le sol derrière lui (`_spawn_hammer_strike`). Ses plaques (`Health.plates`) encaissent
chacune un coup entier avant les PV, et `PLATE_KILLS` kills en reforgent une. Le Rempart (un
`Kind.SHIELD` avec `reflect_damage`) le cloue sur place : le jeu et la simulation lisent
`player_rooted()`. L'Acier en fusion (`molten_seconds`) renforce et fait projeter ses coups.

Le **Démon du Pacte** (élément Sang, onglet Démon) est fait pareil. Sa Rage (`rage_bonus`) gagne jusqu'à
`RAGE_MAX` selon les PV perdus, au maximum à 1 PV quel que soit le stage, et seulement sur le coup d'origine.
`Ability.self_cost` paie en PV par `Health.sacrifice`, qui ne prend jamais le dernier et passe outre le
bouclier. Le Dernier Pacte réutilise `_immune_left`, et `_pact_owed` rend les PV à la fin. ⚠️ C'est un humain
noble à l'image : tout ce qui le dit démon est dans ses sorts, jamais dans son corps. ⚠️ Les bots ne cherchent
jamais à rester à 1 PV : `test_balance` mesure la Rage, pas ce jeu-là. `tools/preview_demon.gd` montre ses effets.

La **Démone de la Discorde** (élément Envoûtement, onglet Démon) ne frappe presque pas : `Kind.POSSESS` retourne les
ennemis les uns contre les autres. Un possédé est aveuglé (`blind_left`) et suit le champ d'un foyer commun
(`possession_field`, `EnemyAI.possess_field`). `Kind.BOND` partage les dégâts, `Kind.SWAP` est sa fuite, et les boss
(`CombatContext.bosses`) ne se possèdent ni ne s'échangent. ⚠️ Sa couleur est celle du fond des planches : aucun rose
ni violet sur son sprite ou ses icônes, le magenta n'existe que dans ses shaders et `DiscordThreads`.

Le **Roi de Braise** (élément Braise, onglet Démon) se bat avec son armure : deux gantelets et un plastron volent à vol
d'oiseau (`CombatSystem.pieces()`). Ceux en orbite sont les plaques de `Health`, et chaque pièce lancée ajoute à son allure
(`armor_speed()`, lue par le jeu et la simulation). `Kind.HUNTERS`, `CHEST`, `RECALL`, `CAGES` ; le leurre passe par
`EnemyAI.lure_field`. Les pièces viennent de `tools/build_braise_pieces.py`, et `KingArmor`, `KingCage`, `KingDecoy` les
montrent. ⚠️ Un nœud qui dessine en positions du monde dans `Entities` doit annuler le redressement de `WorldStage`, sinon
tout glisse vers le sud (`KingArmor._stand`).

Le **Chevalier Écarlate** (élément Lame, onglet Démon) pose des entailles (`_cuts`, `Ability.cuts`) qui ne font rien jusqu'à
`Kind.SHEATHE`, après un silence (`SHEATHE_SILENCE`). `Kind.DASH` et `Kind.GUARD` en posent aussi. L'ultime lit l'écran
(`ecarlate_nuit`) une seconde, sur un `CanvasLayer` à la racine de la fenêtre, jamais enfant du `Level`.

Le **Geôlier** (élément Flamme froide, onglet Démon) flotte, et n'est PAS chibi à la demande du joueur. Il enchaîne :
`Kind.HOOK` ramène, `Kind.SOUL_CHAINS` et `Kind.GAOL` rongent, et `GaolerChains` dessine les chaînes. Sa fuite traverse une
haie (`pierces_walls`). ⚠️ Ses planches sont en cases hautes : `tall_cells` dans `build_enemies.py` les remet au carré.

Le **Dragon des Abysses** (élément Feu infernal, onglet Démon) n'est PAS chibi non plus, et il est dessiné 30 % plus
grand (`body_scale` 1,3). Il brûle le SOL : son trait, Terre brûlée, enflamme la case de chaque cible de son crachat
(`_fire_cells`), le Souffle (`Kind.BREATH`) enflamme le couloir devant lui, et une case en feu ronge ce qui s'y tient.
Dans le feu, il va plus vite : c'est `armor_speed()`, que lisent le `Level` et la simulation. La Morsure (`Kind.BITE`)
le fait bondir par `blink_performed` et le soigne si la proie brûlait. Les Écailles (`Kind.MAGMA_SCALES`) sont une
coque d'un coup, qui éclate en éclats (`shard_count`). Sa fuite (`Kind.WINGBEAT`) repousse, enflamme et le fait
reculer ; l'ultime (`Kind.DRAGON_SHADOW`) fait passer la silhouette des pièces sur l'écran, puis des colonnes. Ses
pièces sortent de `tools/build_dragon_pieces.py`. ⚠️ Sa planche d'attaque le dessine plus grand que sa marche :
`strike_scale` 0,94.

Le **Croupier des Enfers** (élément Hasard, onglet Démon) est un humain chibi qui joue : tout tirage passe par `_rng`
de `CombatSystem`, donc par la graine. Son trait, Coup de chance, est dans `_gamble` (`LUCK_CHANCE`, `LUCK_MULT`), appelé
par `_apply_damage` ; Pile y double aussi ses prochaines cartes (`_doubled_left`). `Kind.DICE` roule dans le couloir
comme le Souffle, `Kind.TRAP_CARD` pose des cartes (`_traps`) qui se retournent sous un ennemi (`Suit`), `Kind.COIN`
le rend intouchable ou double ses coups, et `Kind.ROULETTE` tire `Slot` puis frappe après `ROULETTE_SPIN`. Sa fuite est
le leurre du Roi de Braise, dessiné en carte. La roue de l'image est posée zéro en haut : le `Level` l'arrête d'une
case à droite (rouge 32) ou à gauche (noir 26). Pièces : `tools/build_croupier_pieces.py`.

L'**Avide** (élément Faim, onglet Démon) est un démon pur sang, PAS chibi (`body_scale` 1,3). Chaque kill est une
bouchée (`_bites`, `BITES_MAX`) : +8 % de dégâts chacune dans `_apply_damage`, et une fond toutes les `BITE_DECAY`
secondes. Le `Level` le fait GRANDIR avec elles, et au Festin (`FEAST_SIZE`), par `Player.set_growth`, qui ne change
que le dessin. Sa langue est un projectile `pierce_line` que le `Level` dessine en `Line2D` étirée (`_lash_tongue`).
`Kind.GULF` aspire par les couloirs (`enemy_hauled`, que `test_balance` applique pour lui seul), `Kind.DEVOUR`
achève sous `execute_below`, `Kind.REGURGITATE` dépense toutes les bouchées, `Kind.LEAP` est sa fuite, et
`Kind.FEAST` avale un ennemi par `FEAST_GAP`. Pièces : `tools/build_avide_pieces.py`.

L'**Archange du Ciel** (élément Ciel, onglet Ange) frappe par-dessus les haies : son trait, Vue d'en haut,
c'est `Ability.from_sky`. La cible se choisit à vol d'oiseau, le coup tombe après `sky_fall`, et le `Level` dessine
la chute (`_sky_falls`) au lieu d'un projectile. La Colonne est un tel projectile, avec rayon et `stun_seconds`.
Les Plumes-lames sont une volée `BLADES` qui ne revient pas (`blades_return`). La Cloche est un `BLAST` avec
`pierces_walls`, une exception écrite dans `test_combat`. Le Jugement est la pluie qui vise du Feu, avec des épées.
Son Envol (`Kind.FLIGHT`) le rend intouchable 3 s. Le `Level` passe `GridMover.phases` et compte le mage sur la case
de sol la plus proche (`_grounded`), puis le repose avant que l'onde d'atterrissage ne frappe (`flight_ended`, puis
`_land`). En vol, il ne ramasse rien et ne prend aucun portail. `enemies_dazed` distingue ses deux contrôles.
`tools/preview_ciel.gd` montre ses effets. ⚠️ Son attaque est arrivée en cases hautes : `tall_cells`, comme le Geôlier.

Le **Chérubin** (élément Feu sacré, onglet Ange) garde un lieu. Son trait, Nul n'approche, ouvre un œil par coup
(`_eyes`) ; l'œil s'embrase quand l'ennemi arrive au contact, puis `EYE_LOCK` passe avant le suivant. Sa flamme
(`pierce_line`) continue après sa cible jusqu'au bout de sa portée, sinon elle ne brûlerait jamais personne d'autre :
la cible est toujours la plus proche. `Kind.WHIRL` frappe autour de lui par passages, et `Kind.WHEELS` lance deux
vagues dans deux sens (`_rolling_path`). Les Ailes voilées sont un `SHIELD` intouchable avec `repel_cells`.
`Kind.GARDEN` rejette à chaque image tout ennemi du cercle par les couloirs (`_garden_exit`), et ne le brûle qu'une
fois par `GARDEN_LOCK`. Les boss y entrent, et brûlent. Le rejet passe par `enemy_pushed`, que la simulation applique
déjà. `SacredJet` et `EzekielWheel` dessinent la flamme et les roues, et `tools/preview_cherubin.gd` montre ses effets.

**L'Éveil des mages** (2026-11-07) : une minute sous une forme transformée, puis `EXHAUST_TIME` d'épuisement, et
`KILLS` kills avant le suivant (`Awakening`, RefCounted). Le joueur avait demandé « 1 min, recharge 10 s » : sans la
charge, le mage serait éveillé six secondes sur sept. Le bouton est celui de la transformation d'Aël (`TransformButton`,
`SLOT_TRANSFORM`, touche T), que le GameManager prête aux mages : rappuyer quitte l'Éveil. En démo, il est libre.
- La forme vient de `CharacterCatalog.awakening_of(id)`. Elle garde l'IDENTIFIANT du mage, donc ses effets de base, et
  porte `CharacterStats.awakened` : `Player` lit alors `<id>_eveil` et `UiIcons` le dossier d'icônes `<id>_eveil`.
- Le **Mage du Feu** a le sien, le **Phénix** (`fire_awakened`, fiche `docs/prompts/mages/eveil_feu.md`). Sa
  Renaissance vit dans `Awakening` : `minimum_current` le garde à 1 PV, puis `_on_damaged` le relève à 2 PV,
  intouchable, `CombatSystem.erupt` frappe, et l'Éveil s'achève. Ses braises : `start_embers`.
- Ses sorts : `Ability.volley` (un tir par cible), `echo_delay` et `magma_duration` (le Soleil captif),
  `Kind.PILLARS`, `end_blast_damage` (la Plongée). La Couronne est un `WHIRL`. `tools/preview_phenix.gd` montre
  ses effets, `--awaken` l'éveille dans une capture.
- Le **Mage de l'Eau** a le **Seigneur des Marées** (`water_awakened`, `docs/prompts/mages/eveil_eau.md`), choisi
  par le joueur à la place de l'Esprit des Marées, dont il garde les images. Son trait, Marée haute, est une
  coque d'eau d'un coup qui se reforme `SHELL_REGROW` s après avoir cédé, lue à chaque image dans `Awakening`.
  Ses sorts : `Ability.bounces` (le Trident), la vague à `blow_cells` et `slam_damage`, `heal_if_held` (la Bulle),
  `follows_corridor` et `wake_seconds` (le Torrent), et `Kind.LEVIATHAN`. `tools/preview_maree.gd`.
- Le **Mage de la Terre** a le **Colosse** (`earth_awakened`, `docs/prompts/mages/eveil_terre.md`). L'image reste à
  l'échelle du mage : c'est le `Level` qui le grandit de `Awakening.GROWTH` (`Player.set_growth`, comme l'Avide).
  Son trait, Piétinement, est `CombatSystem.start_trample` : sa case et ses voisines sont repoussées et blessées, une
  fois par seconde par ennemi ; boss et repaires encaissent sans bouger. Les ennemis ne bloquent pas le mage : il
  les traverse déjà. Ses sorts : `pierce_line` (la Météorite), `line_cross` (la Faille, une branche par couloir,
  zone `faille_peinte`), `reflect_damage` (le Bastion, comme l'Acier), `turret_volley` (la Tour de cristal, ex-Géode : id `earth_eveil_geode`),
  `end_blast_push` et `end_blast_arrival_only` (l'Éruption), `lava_columns` (le Cataclysme, sur le Séisme de base).
  Effets : `colosse_*`, palette commune dans `colosse.gdshaderinc`. `tools/preview_colosse.gd`.
- Le **Mage de la Foudre** a l'**Avatar de la Tempête** (`thunder_awakened`, `docs/prompts/mages/eveil_foudre.md`),
  20 % plus rapide. Son trait, Surtension, est `CombatSystem.start_surge` : chaque coup d'origine (`with_trait`)
  donne une charge, et la cinquième fait tomber la foudre sur la cible de l'attaque suivante. Ses sorts :
  `pierce_line` (la Lance), `chain_stun` (la Tempête en chaîne), `zone_follows` (la Cage électrique, zone
  `cage_peinte`), `storm_clouds` (l'Œil du cyclone), `hop_count` (le Saut d'éclair, qui finit sur le dernier
  ennemi), `wrath_damage` (la Colère du ciel, sur le Jugement de base). Effets : `tempete_*`, palette dans
  `tempete.gdshaderinc` — jamais de violet. `tools/preview_tempete.gd`.
- Le **Mage de l'Air** a le **Souverain des Vents** (`air_awakened`, `docs/prompts/mages/eveil_air.md`). Son trait,
  Rempart de vent, est le pas du Colosse sans dégâts (`start_trample` avec `lock` et `slow`). Ses sorts :
  `pierce_push` (le Croissant), `zone_pull` (le Grand vortex, une tornade de base qui aspire), `slam_stun` (le
  Souffle du titan), un bouclier `immune` + `repel_cells` (le Cocon, comme le Chérubin), `Kind.FLIGHT` +
  `end_blast_push` (le Vol du zéphyr, comme l'Envol du Ciel), `eye_seconds` (l'Ouragan : une zone `zone_follows`
  fabriquée par `_open_eye`). Effets : `souverain_*`, palette dans `souverain.gdshaderinc`. `tools/preview_souverain.gd`.
- Le **Sorcier des Ténèbres** a le **Seigneur du Néant** (`shadow_awakened`, `docs/prompts/mages/eveil_tenebres.md`).
  Son trait, le Double, est `CombatSystem.start_double` : chaque coup visé est répété par son ombre à moitié de
  sa force (ni la fuite, ni l'Extra). L'ombre est `ShadowDouble` : elle recopie à chaque image le sprite du mage
  (`neant_silhouette.gdshader`), et sert aussi de leurre figé à la Marche des ombres. Ses sorts : `impact_pull`
  (l'Orbe), zone `sceau_gouffre`, `decoy_seconds` (la Marche), `hole_seconds` (le Trou noir), `Kind.FLIGHT` peint
  en Fusion (son sprite s'efface par `self_modulate`, la flaque reste), `eclipse_seconds` (l'Éclipse). Effets :
  `neant_*`, palette dans `neant.gdshaderinc`. `tools/preview_neant.gd`.
- ⚠️ Ses planches sont sur FOND VERT (il est violet) : l'entrée `tenebres_eveil` de `build_enemies.py` prend
  `degreen` au lieu de `demagenta`, et `keep_cast` pour sauter `without_magenta_cast`, qui ramenait son violet au
  rouge ; ses icônes prennent `key: flat` et `degreen`.
- L'**Invocateur** a le **Maître des Légions** (`invocateur_awakened`, `docs/prompts/mages/eveil_invocateur.md`). Son
  trait, la Légion, est `CombatSystem.start_legion` : les créatures nées pendant l'Éveil ont `legion` (dégâts ×
  `LEGION_RATIO`, plafond `LEGION_CAP`), le `Level` les grandit (`SummonVisual.set_legion`) et les relie au mage
  (`LegionChains`). Le `Level` lit leur apparence et leur taille par `combat.summon_info(id)`. Ses sorts :
  `prey_mark_seconds` (la Marque : `_nearest_prey` la préfère ; distincte de `mark_seconds`, celle de l'Ange de la
  Mort), `summon_burst_damage` (la Nuée, explosion quand la créature s'en va), `summon_drop_damage` (la Gargouille
  colossale tombe près de la proie), zone `porte_abysses` avec `zone_spawn_every`, `swap_with_summon` (l'Échange),
  `flyover_damage` + `summon_look` `dragon_eveil` (le Roi-Dragon, dont la boule de feu `brasier_roi` explose sur
  `ROYAL_FIREBALL_RADIUS`). Effets : `legion_*`, palette dans `legion.gdshaderinc`. `tools/preview_legion.gd`.
- ⚠️ Ses planches sont sur FOND VERT, comme le Seigneur du Néant (`degreen`, `keep_cast`). Son dragon embrasé vient
  de `creatures/invocateur_dragon_eveil.png`, détouré par `green_keyed` dans `tools/build_invocateur.py --dragon-eveil`.
- Le **Chronomancien** a le **Seigneur des Heures** (`chrono_awakened`, `docs/prompts/mages/eveil_chrono.md`). Son
  trait, Temps accéléré, est `CombatSystem.start_haste` : les recharges courent à `Awakening.HASTE_FACTOR`, et le
  `Level` pose l'horloge `heures_horloge` sous ses pieds. Ses sorts : `volley` 3 (les Trois Aiguilles),
  `entry_freeze` (le Dôme de stase fige une seule fois chaque créature qui entre, zone `dome_stase`),
  `echo_second_seconds` + `echo_end_damage` (le Paradoxe : deux doubles, une onde au bout ; `TRAIL_KEEP` monté à
  11 s pour le second), `rewind_heal_seconds` (le Rembobinage lit `health_at_past`), `clock_bomb_*` (le Saut
  temporel pose une bombe-horloge), `judgement_ratio` (le Jugement des Heures : pendant l'arrêt, `_apply_damage`
  accumule au lieu de blesser, puis `_release_judgement` rend le tout multiplié). Effets : `heures_*`, palette dans
  `heures.gdshaderinc`. `tools/preview_heures.gd`. Fond magenta, `demagenta`.
- Le **Mage de la Peste** a le **Seigneur du Fléau** (`peste_awakened`, `docs/prompts/mages/eveil_peste.md`). Son
  trait, le Miasme, est `CombatSystem.start_miasma` : une dose par seconde aux créatures collées, et `venom_cap()`
  monte à `Awakening.MIASMA_CAP` (5) tant qu'il dure — la teinte d'`Enemy` est plafonnée à trois doses. Le `Level` pose
  l'anneau `fleau_miasme` et la ronde de `PlagueCrows` (trois corbeaux de `assets/allies/peste_corbeau_top.png`,
  vus de dessus et tournés dans le sens du vol, `tools/build_corbeau.py`). Ses sorts : `radius` sur le Crachat (la
  gerbe passe par `_apply_area`, une dose par le trait), `trail_doses`/`trail_slow` (le Sillage), `epidemic_jumps`
  (l'Épidémie), `bleed_per_dose` (la Saignée fait éclater toutes les doses du rayon), `flock_damage` +
  `cloud_at_arrival` (la Nuée de corbeaux), `plague_slow` + `cloud_venom_doses` (la Grande Peste, ciel `fleau_ciel`
  accroché au mage). Effets : `fleau_*`, palette dans `fleau.gdshaderinc`. `tools/preview_fleau.gd`.
- Le **Sorcier Suprême** a l'**Archimage Primordial** (`supreme_awakened`, `docs/prompts/mages/eveil_supreme.md`).
  Son trait, la Roue des éléments, est `CombatSystem.start_wheel` : chaque coup porte le trait de l'orbe en tête
  (feu, eau, terre, air, l'ordre de `SEAL_ORDER`) en plus de l'Écho, et l'attaque fait tourner la roue. Le tir
  emporte son rang (`_in_flight[...]["wheel"]`, relu par `_wheel_hit`) : la roue tourne au lancer, pas à l'impact.
  Le `Level` pose l'anneau `primordial_anneau` et les quatre orbes d'`ElementOrbs`. Ses sorts : `element_shards`
  (la Grande Convergence se brise en éclats), `seals_follow` (la Couronne : chaque sceau garde son point cardinal
  par `_seal_cell`), `double_echo` (l'Apothéose), `element_ray_damage` (le Pas des éléments : un rayon par
  couloir à l'arrivée), `rain_elements` + `nova_damage` (la Genèse : les météores suivent la roue, puis
  `primal_nova`). Effets : `primordial_*`, anneau et palette dans `primordial.gdshaderinc`.
  `tools/preview_primordial.gd`. ⚠️ Planches sur FOND VERT (`degreen`, `keep_cast`), icônes sur magenta.
- `--awaken` remplit aussi la charge de kills hors démo : le Paradoxe et le Saut temporel demandent de marcher, et
  la démo se gagne en six secondes. Pour les capturer : `--stage 6 --character chrono --awaken --auto-walk`.
- ⚠️ Une zone `zone_follows` est déplacée par `Level._on_zone_moved` : avant le 2026-11-07, seules les tornades
  bougeaient à l'écran, et la Cage de l'Avatar blessait autour du mage en restant dessinée où elle était posée.
- Le **Démon du Pacte** a l'**Archidémon du Pacte** (`demon_awakened`, `docs/prompts/mages/eveil_demon.md`), le
  premier Éveil d'un DÉMON. Son trait, le Prix du Sang, est `CombatSystem.start_blood_price` : 1 PV coule toutes les
  `Awakening.BLOOD_EVERY` s (`Health.sacrifice`, jamais le dernier, rien pendant qu'il est intouchable), chaque kill
  en rend 1 (`_feed_blood`), et `rage_bonus` est multipliée par `BLOOD_RAGE`. Ses sorts : `volley` 3 (les Serres),
  un `PACT` qui porte `damage` et `radius` (l'onde du Pacte écarlate), `line_cross` sur le Sillon (les Fleuves),
  `heal_per_hit` (la Gueule rend 1 PV par ennemi happé, `heal_self` au plus), `Kind.FLIGHT` (les Ailes), et
  `pact_claw_damage`/`pact_claw_gap` sur le Dernier Pacte (l'Apocalypse : une serre par seconde sur l'ennemi le
  plus proche tant qu'il est intouchable, `pact_claw_struck`). Effets : `archi_*`, palette dans `archi.gdshaderinc`
  (les fonctions du Fléau, recolorées en sang et or) ; l'aura lit la Rage par `PaintedBurst.set_shader_value`.
  Fond magenta, `demagenta` ; ses icônes se découpent seules (`build_skill_icons` filtré sur sa planche).
- La **Démone de la Discorde** a la **Reine de la Discorde** (`discorde_awakened`, `docs/prompts/mages/eveil_discorde.md`).
  Son trait, la Discorde contagieuse, est `CombatSystem.start_contagion` : chaque coup trouble (`_add_whisper` sans
  attendre `WHISPER_MARKS`), et la possession d'un pantin mort saute sur le plus proche à `CONTAGION_REACH`, pour le
  temps qui restait et au moins `CONTAGION_MIN` (`possession_jumped`). Ses sorts : `bounces` (le Fil d'argent, dessiné
  par `_on_water_bounced`), `possess_neighbors` (l'Œil de la Reine, `queen_eye_opened`), une zone `discord_bonus` +
  `zone_pull` (l'Arène, `arene_peinte`), un `BOND` à cinq (la Toile, `web_spun`), un `SWAP` avec `decoy_seconds` (le
  Ballet : `PuppetDecoy` recopie son sprite en argent), et `ball_burst_damage` sur la Grande Discorde (le Grand Bal :
  chaque mort éclate à l'image suivante, en cascade, `ball_burst`). Effets : `reine_*`, palette et œil peint dans
  `reine.gdshaderinc`. ⚠️ Ses planches prennent `keep_cast` : `without_magenta_cast` bordait ses cheveux et sa croix
  d'une frange rouge. Le leurre se met à jour dans `_update_discord` : `_update_king` ne tourne qu'avec des pièces.
- Le **Roi de Braise** a l'**Empereur des Cendres** (`braise_awakened`, `docs/prompts/mages/eveil_braise.md`). Son
  trait, le Sillage de cendres, est `CombatSystem.start_ashes` : chaque pièce qui vole met le feu aux cases qu'elle
  franchit (`_leave_ashes`, les cases en feu du Dragon pendant `ASH_SECONDS`), et une pièce arrachée revient en
  `ASH_RETURN`. ⚠️ `armor_speed` ne donne l'allure du feu qu'au Dragon (`INFERNO`) : sans cette garde, le Roi courait
  dans ses propres cendres. Ses sorts : un projectile à `radius` (le Poing impérial), `HUNTERS` à `radius` (la gerbe
  des Gantelets, `gauntlet_splashed`), `forge_pull` + `forge_blast_*` sur le plastron (la Forge impériale),
  `recall_fire_seconds` + `recall_wave_*` (le Retour de l'Empire : l'onde ne part que si les trois pièces rentrent
  ensemble, `_empire_wave`), le leurre de base (la Statue, colonne de lave), `cage_burst_*` sur les cages (l'Empire des
  Cendres, ciel `empereur_ciel`). `KingArmor.molten` chauffe les pièces. Effets : `empereur_*`, palette dans
  `empereur.gdshaderinc`. ⚠️ Son anneau de pointes flotte, détaché : `speck_share` abaissé dans `build_enemies.py`, sinon
  `deblorded` les prenait pour de la poussière. `despill` et `keep_cast` sur ses planches.
- Le **Chevalier Écarlate** a le **Seigneur Écarlate** (`ecarlate_awakened`, `docs/prompts/mages/eveil_ecarlate.md`).
  Son trait, la Lame affûtée, est `CombatSystem.start_keen` : `_add_cuts` pose une entaille de plus et plafonne à
  `KEEN_CUTS_MAX`, et un ennemi arrivé au bout ouvre ses entailles à l'image suivante (`_keen_pending`, `keen_burst`).
  ⚠️ La Nuit Écarlate pose ses huit entailles avec `may_open` faux : sinon elles s'ouvraient avant la rengaine. Ses
  sorts : `pierce_line` (le Croissant), `dash_echo_*` (la lame fantôme repasse, `dash_echoed`), `guard_all` (la Garde
  pare tout et riposte une fois par `PARRY_LOCK`), `petal_cuts`/`petal_radius` (la Rengaine écarlate, `petals_flung`),
  un `BLINK` arrière avec `decoy_seconds` et `cuts` (la Danse : le leurre éclate en entailles ; il se met à jour dans
  `_update_blade`), et `crimson` dans `ecarlate_nuit` (noir et rouge, lune de sang). Effets : `seigneur_*`, palette
  et pétale peint dans `seigneur.gdshaderinc`. Planches `demagenta` + `keep_cast`.
- Le **Geôlier** a le **Gardien de l'Abîme** (`geolier_awakened`, `docs/prompts/mages/eveil_geolier.md`), grand et
  massif comme lui (`body_scale` 1,4, mais PAS de `tall_cells` : ses planches sont carrées). Son trait, le Poids des
  chaînes, est `CombatSystem.start_abyss` : entravé à `ABYSS_SHACKLE_HITS`, et ce qui est sonné prend
  `ABYSS_HELD_BONUS` de plus. Le registre `_held` se remplit par `_note_held`, branché dans `_init` sur
  `enemy_staggered` : tout étourdissement passe par ce signal. Ses sorts : un projectile à `radius` (le Poing),
  `hook_count` (trois crochets, chacun sur sa case), `snap_damage`/`snap_stun` sur les Chaînes (`chains_snapped`),
  `frost_seconds` sur le Souffle (une zone `givre_abime` qui ralentit), `end_blast_stun` sur la Traversée (`frost_wave`),
  `gaol_pull_gap` + `gaol_end_damage` sur la Geôle (l'Abîme : il tire ses prisonniers par `enemy_pushed`, puis
  `abyss_closed`). Effets : `abime_*`, maillon et serrure peints dans `abime.gdshaderinc`.
- Le **Dragon des Abysses** a le **Dragon Primordial** (`dragon_awakened`, `docs/prompts/mages/eveil_dragon.md`), PAS
  chibi et dessiné 30 % plus grand comme lui. Son trait, le Feu primordial, est `CombatSystem.start_primal` :
  `_ignite_cells` multiplie la durée par `PRIMAL_FIRE_LONGER` (les `ground_fire` de son kit sont donc la MOITIÉ de ce
  qu'annonce la fiche), les cases rongent `PRIMAL_FIRE_DAMAGE`, et ce qui meurt en feu (`_is_aflame`) explose à
  l'image suivante (`_burst_primal`, `primal_burst`). Ses sorts : un projectile à `radius` + `ground_fire` (la Bombe
  enflamme son rayon, `_floor_within`), `breath_spill` (le Souffle déborde sur les bords), `execute_below` sur la
  `BITE` (le Dévoreur avale une proie en feu blessée, jamais un boss), des Écailles à deux coups, `Kind.FLIGHT` +
  `ground_fire` (l'Envol retombe dans le feu, dans `_land`), `meteor_radius` sur l'Ombre (le Ciel en feu). Effets :
  `premier_*`, palette dans `premier.gdshaderinc` (jamais doré : ce serait le Dragon d'or d'Aël).
- Le **Croupier des Enfers** a le **Maître du Casino** (`croupier_awakened`, `docs/prompts/mages/eveil_croupier.md`).
  Son trait, la Maison gagne toujours, est `CombatSystem.start_house` : `_gamble` multiplie `LUCK_CHANCE` par
  `HOUSE_LUCK`, et chaque Coup de chance paie une gerbe de jetons à l'image suivante (`_payouts`, `house_payout`).
  Ses sorts : `volley` 3 (la Main gagnante), `dice_count` 3 (les Dés du Diable : un brelan fige et brûle,
  `devil_die`), `trap_cross` + `joker_chance` (la Table piégée ; `Suit.JOKER` joue les trois figures),
  `coin_both` (la Pièce truquée), le leurre de base avec dégâts (le Grand tour, `casino_chapeau`), et
  `roulette_spins` (le Grand Jeu relance `roulette_spun` entre deux tours). Effets : `casino_*`, jeton et carte
  peints dans `casino.gdshaderinc`. ⚠️ Son leurre n'était JAMAIS mis à jour (il vit dans `_update_king`, qui ne tourne
  qu'avec les pièces du Roi) : `_update_croupier` l'appelle maintenant, comme la Discorde et l'Écarlate.
- Le **Porte-Lumière** a l'**Étoile du Matin** (`lumiere_awakened`, `docs/prompts/mages/eveil_lumiere.md`), le premier
  Éveil d'un ANGE. Son trait, l'Éblouissement, est `CombatSystem.start_dazzle` : `_apply_damage` ajoute `DAZZLE_BONUS`
  sur une créature aveuglée (`is_blinded`, le verrou dépasse `BLIND_LOCK`), et ce qui reste collé `DAZZLE_CONTACT` s
  est aveuglé, sans passer outre `_blind_locks`. Ses sorts : `pierce_line` + `blind_every` (le Trait solaire),
  `beam_linger`/`linger_damage` sur la Lance (`_light_walls`, `light_wall_raised`), `zone_heal_every` (la Cathédrale,
  zone `cathedrale_peinte`), `aegis_ray_damage` sur le bouclier (l'Égide renvoie chaque point de bouclier perdu,
  `aegis_ray`), un `DASH` qui aveugle (le Trait de l'étoile), et `sun_seconds` sur la forme DAWN (le Soleil de midi :
  `SUN_EVERY`, champ `SUN_VIEW`, puis `sun_set`). Effets : `aurore_*`, étoile à huit branches et palette dans
  `aurore.gdshaderinc`. `tools/preview_aurore.gd`. Planches sur FOND VERT (`degreen`, `keep_cast`), icônes sur magenta.
  ⚠️ `without_grid` de `build_enemies.py` prenait des rangées de fond vert et de dessin blanc pour des traits de grille
  et les effaçait : il ne compte plus que les pixels éloignés du fond. Les autres planches vertes n'ont pas été
  redécoupées depuis.
- L'**Avide** a **Faim Sans Fond** (`avide_awakened`, `docs/prompts/mages/eveil_avide.md`), PAS chibi, sans yeux. Son
  trait, la Faim sans fond, est `CombatSystem.start_endless` : `ENDLESS_BITES` bouchées, `ENDLESS_GAIN` par kill, et
  aucune ne fond ; `stop_endless` le ramène à `BITES_MAX`. Ses sorts : `volley` 3 + `pierce_line` (les Langues voraces ;
  `_launch_at` sait maintenant percer), un Gouffre plus grand (l'Abîme affamé), `devour_count` (Tout dévorer,
  `_devour_one`), `bile_seconds`/`bile_damage` (le Déluge laisse des zones `bile_peinte`), un `LEAP` à `damage` (le Bond
  mord), `feast_gap` + `feast_heal_cap` (le Grand Festin). Effets : `faim_*`, gueule de crocs peinte dans
  `faim.gdshaderinc` ; il garde aussi les effets `avide_*` de sa forme de base.
- L'**Ange de la Mort** a le **Faucheur des Âmes** (`mort_awakened`, `docs/prompts/mages/eveil_mort.md`). Son trait, la
  Récolte, est `CombatSystem.start_harvest` : `_sentence` achève sous `HARVEST_BELOW`, `soul_cap()` monte à
  `HARVEST_SOULS`, et une âme en orbite frappe ce qui arrive à son contact (`_update_harvest`, `soul_guarded`, une fois
  par `HARVEST_GUARD_LOCK`). `SoulOrbit` dessine déjà les âmes. Ses sorts : `returns` (le Croissant revient, `_returns`,
  `crescent_returned`), une Moisson `BLAST` sans arc à `execute_below` 0,45, `toll_count` sur un `BLAST` (le Glas
  funèbre : `_tolls`, `toll_rang`), `souls_base` (la Légion), `blink_mark_seconds` (le Pas de l'ombre),
  `hour_passes` 2 (Minuit : le retour part après `HOUR_RETURN_GAP`). ⚠️ Minuit achève sous 20 % et non 25 : deux
  moitiés laissent un ennemi indemne à 25 % pile, et toute la carte mourait. Effets : `faucheur_*`, lame et âme dans
  `faucheur.gdshaderinc`. `tools/preview_faucheur.gd`. Planches sur FOND VERT, icônes sur magenta.
- L'**Ange des Étoiles** a la **Reine du Firmament** (`etoiles_awakened`, `docs/prompts/mages/eveil_etoiles.md`). Son
  trait, le Firmament, est `CombatSystem.start_firmament` : `star_cap()` monte à `FIRMAMENT_STARS` et les rayons
  frappent à `FIRMAMENT_RAY`. Avec cinq étoiles, `_figure_hull` ferme la figure (enveloppe convexe) : ce qui est dedans
  sans toucher un rayon prend `figure_damage` (`figure_changed`, remplie par `Constellation.set_figure`). Ses sorts :
  `spark_seconds` (l'étoile éphémère du Trait de comète, `_sparks`, deux au plus), `big_meteor_damage` (la Pluie de
  météores vise le plus solide en s'annonçant, `big_meteor_falling`/`_struck`), `moon_ring_*` (l'anneau de fin de
  l'Éclipse ; `eclipse_slow` était déjà pris), `blink_star` (la Comète pose une étoile), `galaxy_seconds` (chaque
  impact devient une étoile reliée à ses deux voisines, `galaxy_changed`, un second `Constellation` en `set_links`).
  Effets : `firmament_*` (⚠️ le préfixe `reine_` est celui de la Reine de la Discorde), palette et étoile dans
  `firmament.gdshaderinc`, `tools/preview_firmament.gd`. Planches sur magenta avec `keep_cast` (sans lui, le bord de
  ses ailes tournait au rouge brun). Son portrait est revenu sur magenta : `build_menu.py` le repeint (`NAPPES`).
  `--stars --awaken` plante cinq étoiles en pentagone.
- L'**Archange d'Acier** a le **Forgeron Céleste** (`acier_awakened`, `docs/prompts/mages/eveil_acier.md`). Son trait,
  la Forge vivante, est `CombatSystem.start_forge` : `plate_cap()` monte à `FORGE_PLATES`, `_forge_plate` reforge à
  chaque kill, et une plaque qui casse (`_on_plate_torn`) fait `FORGE_SHARD_DAMAGE` autour de lui (`plate_shattered`).
  `PlatePips` suit `plate_cap()`. Ses sorts : `stun_every` (le Marteau étourdit un coup sur trois, `hammer_stunned` ;
  sans lui `stun_seconds` d'un projectile passe par `_freeze_around`, qui dessine le givre du Geôlier), `blades_circle`
  (la roue de huit lames), `anvil_drop_*` (l'enclume tombe sur l'ennemi le plus proche après `ANVIL_DROP_LEAD`, puis
  `_anvil_wave` part de l'impact), `bastion_*` (gerbe et plaque à la fin de l'intouchabilité), `trail_stun` et
  `molten_trail_seconds` (la Charge laisse des cases en feu, dessinées `forgeron_fusion`), `molten_steps_seconds` (les
  pas du Cœur de la forge). Effets : `forgeron_*`, palette, fissures et gerbe dans `forgeron.gdshaderinc`,
  `tools/preview_forgeron.gd`. Planches sur magenta avec `keep_cast`.
- Le **Chérubin** a le **Gardien du Trône** (`cherubin_awakened`, `docs/prompts/mages/eveil_cherubin.md`). Son trait,
  le Regard du Trône, est `CombatSystem.start_throne` : l'œil brûle à `THRONE_REACH` au lieu de `EYE_REACH`, pour
  `THRONE_EYE_DAMAGE`, et se rallume en `THRONE_EYE_LOCK`. Ses sorts : `line_fire` (la flamme laisse le couloir en
  feu, des cases en feu dessinées `eden_flamme`), un `WHIRL` dont le `Level` double l'épée (rotation PI),
  `wheel_count` 4 (`_cast_four_wheels`, une roue par direction ouverte), `veil_eyes_radius` (à la fin de
  l'intouchabilité, `_open_throne_eyes` pose un œil sur ce qui est proche, `throne_eyes_opened`), le `BLINK` avec
  `end_blast_*` (l'éclair, `eden_eclair` debout à l'arrivée), `garden_sword_damage` (une épée tourne sur le bord de
  l'Éden en `GARDEN_SWORD_PERIOD`, `_swing_garden_sword`, `garden_sword_struck` ; `eden_bord` lit `seconds` pour
  tourner au même angle). L'arbre de vie (`eden_arbre`) pousse derrière l'épée plantée. Effets : `eden_*`, œil et
  flamme dans `eden.gdshaderinc`, `tools/preview_eden.gd`. Planches sur magenta avec `keep_cast` ; portrait revenu sur
  magenta, repeint par `NAPPES`. ⚠️ Sa planche d'attaque a les cheveux plus orangés que sa marche.
- L'**Archange du Ciel** a le **Séraphin** (`ciel_awakened`, `docs/prompts/mages/eveil_ciel.md`), dernier des six Éveils
  d'anges. Son trait, les Yeux du ciel, est `CombatSystem.start_skies` : tout coup de son élément marque
  (`_sky_marks`, `SKY_MARK_SECONDS`), et une cible marquée prend `SKY_MARK_BONUS`. Ses sorts : `sky_twin` (une seconde
  lance sur l'ennemi le plus proche, `_sky_neighbour` ; le tir du ciel passe par `_sky_drop`), `feather_rain` sur un
  `BLADES` (`_rain_feathers` : des projectiles `from_sky` au visuel `plume_seraphin`, que `_sky_falls` dessine en
  `seraphin_plume`), `column_linger`/`column_burn` (`_columns`, `column_lingered`), le Glas du Faucheur réutilisé pour le
  Carillon (`toll_count` + `pierces_walls` mesure à vol d'oiseau, `stun_seconds` étourdit, la marque n'est posée que si
  `mark_seconds`), `flight_lance_gap` (des lances pendant l'Envol, `FLIGHT_LANCE_REACH`), `great_sword_*` (l'épée
  géante tombe sur lui après la pluie, `GREAT_SWORD_PAUSE`, `great_sword_falling`/`_struck`). Effets : `seraphin_*`, aile
  de lumière et épée dans `seraphin.gdshaderinc`, `tools/preview_seraphin.gd`. Planches carrées sur magenta (pas de
  `tall_cells`, contrairement à sa forme de base), `keep_cast`.
- ⚠️ Les bots de `test_balance` ne s'éveillent jamais : rien n'y mesure l'Éveil.
- **Le bouton ÉVEIL de la sélection** (2026-11-09) bascule la fiche sur la forme éveillée : portrait, nom, trait
  (`CharacterCatalog.AWAKENING_TRAITS`) et six sorts, avec les icônes `<id>_eveil`. Il reste enclenché d'un mage
  à l'autre et JOUER part toujours avec le mage. Le portrait est `portrait_<id>_eveil.jpg` (`build_menu.py`, prompts
  `docs/prompts/menu/portrait_*_eveil.md`) ; sans lui, `CharacterPortrait` montre le sprite de l'Éveil. `--select
  --character X --eveil` le capture. Un nouvel Éveil demande une ligne dans `AWAKENING_TRAITS` et dans `EVEILS` de
  `build_prompts_menu.py`.

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

## Les boss

Un boss garde la porte du dernier épisode de chaque chapitre (`LevelConfig.has_boss`). Il surgit
quand le mage revient à sa maison avec tout le reste fait, et la porte ne s'ouvre qu'à sa mort.
`godot --path . -- --stage 4 --episode 2 --boss` l'appelle sans faire la tournée.

En démo, chaque décor a son boss, avec ses vrais PV et sa vraie vitesse : le bouton « Appeler le
boss » le fait surgir sans gemme (`Level.call_boss`), et on peut le rappeler après sa mort. Il ne
ferme la porte que pendant le combat. `--demo --demo-stage 4 --boss` passe par ce bouton.

- `BossCatalog` dit qui garde quel chapitre et la forme de son attaque, `Bestiary` ce qu'il vaut,
  `BossFight` quand et où tombe sa zone, en RefCounted. `tests/test_boss.gd` vérifie le tout.
- Il frappe au contact comme tout ennemi. De loin, il marque le sol (`BossZone`) : la zone se voit
  se remplir, et qui en sort à temps n'a rien. `test_boss` vérifie qu'on peut toujours en sortir.
- Chaque boss a SA forme d'attaque (`BossFight`), et test_boss refuse deux formes identiques. Sa
  démarche (`BossGait`) et sa vitesse viennent de `BossCatalog`, en cases par seconde : elles suivent
  sa taille (`body` dans `Bestiary`), pas le stage. Les fiches de `docs/prompts/boss/` décrivent les
  images ; pour les portées et les attaques, c'est `BossCatalog` et `BossFight` qui font foi.
- ⚠️ Sa place dans `enemies` est RÉSERVÉE au chargement, comme celle des petites gelées : un ennemi
  ajouté en pleine partie décalerait les index sous les projectiles en vol. Il est hors de
  `slot_species`, et donc hors de `test_balance`, qui NE MESURE PAS les combats de boss.
- Face à lui, la vague s'arrête : ce qui tombe ne revient plus (`_update_respawns`).
- Les planches passent par `tools/build_bosses.py` : marche et attaque comme tout ennemi, scène et
  portée en bandes de huit cases de 256. `special_frames.json` porte le corps mesuré, qui garde la
  même taille à l'écran. L'identifiant `boss_araignee` reste celui de la Reine de Cristal, qui
  n'est plus une araignée.
- ⚠️ Sans affichage, une image ne dure pas 1/60 s : pour attendre un de ses gestes dans un test,
  `create_timer`, jamais un compte d'images.

## Le gabarit d'animation

Le **Héros d'essai** (`test`) sert à régler le mouvement. Il est caché de l'écran de sélection depuis
le 2026-11-03, à la demande du joueur : on n'y va plus que par `--demo --character test`. Pour le remontrer,
l'ajouter à `CharacterCatalog.roster()` et rendre son onglet à `CATEGORIES`. Il est hors de `all()`, donc hors
de `test_balance` et des fiches. Il ne part jamais en vraie partie.

- La clé `motion` de `frames.json` active `MotionProfile` dans `Player`. Sans elle, le code d'avant
  joue tel quel. `build_enemies.py` l'écrit depuis la clé `motion` de son entrée, `every_step` y garde
  les huit images de course au lieu de `SMALL_STEP_FRAMES`.
- Les planches portent les membres, la penchée et les poses clés. Le code ajoute le rebond,
  l'écrasement, les durées inégales de l'attaque, la poussée et `SlashArc`, sans toucher à la grille.
- Prompts et guides : `docs/prompts/template/heros_test.md`, `tools/build_template_guides.py`. Planche
  de contrôle : `tools/preview_motion.gd`. `tests/test_motion.gd` vérifie aussi que personne d'autre
  n'a de gabarit hors de sa liste `WITH_MOTION` : le Démon du Pacte, premier mage à l'essayer, sans arc de lame
  (`slash_color` transparent) et avec `impact_pose` sur l'image où jaillit son sort.
- ⚠️ Sur un mage, le joueur a trouvé bizarre la marche du gabarit : le Démon garde le rebond des mages
  (`bob` à 1, soit `WALK_BOB`), sans écrasement, à-coup ni poussière. Seule son attaque garde le gabarit.
- **Aël**, le héros principal (`docs/HEROS_PRINCIPAL.md`), reprend tout le gabarit : planche `ael_marche.png`
  ENTIÈRE sur `template/guide_heros.png` (course de face et de dos, marche des mages de profil). Premier onglet
  (« Héros ») et personnage par défaut (`default_id()`, et `by_id` d'un identifiant inconnu), jouable, mais hors
  de `all()` (roster des mages). `HeroProgress` conserve ses niveaux ; `HeroCatalog` fournit ses quatre
  formes et 24 compétences. La simulation le mesure avec `--mage ael --hero-campaign`.
  Son élément, le Prisme, n'a pas de trait.
  ⚠️ L'Apprenti est un épéiste SANS MAGIE : chaque sort est un geste d'épée, avec son propre effet tracé
  (`FlyingCrescent`, `BladeStreak`, `GuardFlash`, `SlashArc.setup_ring`), jamais le visuel d'un autre personnage.
  `tools/preview_ael.gd` les montre image par image.
  Ses formes (mécanique de Codex : `HeroCatalog`, `HeroProgress`, `Transformation`, `HeroRuntime`) ont chacune leur
  matière et leurs effets : ⚠️ AUCUN effet partagé, ni avec un autre personnage, ni entre deux de ses 24 sorts
  (tableau dans `docs/HEROS_PRINCIPAL.md`). Le Prisme ultime ne met plus fin à la transformation.
  La Transformation a son bouton dédié (`TransformButton`, `GameManager.SLOT_TRANSFORM`, touche T), hors de
  l'éventail de six : sa charge est à part (`HeroRuntime.TRANSFORM_KILLS`), l'Extra de l'Ascendant reste la Nova.
  Au niveau 80 (`HeroProgress.MAX_LEVEL`), le même bouton mène du Prisme au DRAGON D'OR (`Transformation.ascend`,
  `DRAGON_KILLS`), sa cinquième forme : un dragon humanoïde qui rôde, ses effets à lui, une cinquième carte. Une carte par forme dans l'onglet Héros
  (`AEL_FORMS`), qui ne sert qu'au menu : en jeu, c'est toujours `ael`, et `--hero-form N` y mène.
  En démo, le sélecteur dans l’arène permet de choisir Apprenti ou les évolutions I, II, III ; l’Extra
  reste disponible après le retour du Prisme. La démo ne sauvegarde ni niveaux ni progression.
- ⚠️ Les planches `test_repos` et `test_gestes` ne sont encore lues par aucun outil.
- ⚠️ Le générateur peut répéter son demi-cycle : même foulée mesurée, mais il court sur une seule jambe.
  `repeat_complaint` le signale (planches `every_step` seulement). `test_profil.png` remplace la rangée.
  ⚠️ De profil, le joueur veut la marche des mages, pas une course : `test_profil.png` est dessinée
  sur `mages_animes/guide_profil.png`, et `small_steps_right` choisit ses images. Il garde le rebond du
  haut et du bas (`side_bob`, `side_squash`). `side_phase` cale ce rebond : au plus bas, pieds écartés.
  À recaler si l'ordre des images change. ⚠️ Les images d'écart maximal changent d'une planche à l'autre :
  mesurer l'écart à l'écran contre un mage avant de choisir (0,2 de la hauteur joints, 0,55 ouverts).
  Resserrer les jambes à la découpe a été essayé et rejeté : c'est le pas qu'il faut redessiner.
- De profil, l'arrêt vient de la fiche de modèle (`standing_right`) : la première image de course a les
  pieds écartés. Son échelle se prend sur la tête, sinon il rétrécit à chaque arrêt.

## L'Arène (2026-11-09)

Les héros se battent SEULS, en équipes : le joueur choisit le mode (**Gemme-Cœur** ou **Duel à
mort**), le format (1, 2 ou 3 contre autant), ses héros et leur posture (Assaillant, Gardien,
Chasseur), puis il regarde. Quatrième bouton de l'écran-titre, `GameFlow.show_arena`.

```bash
godot --path . -- --arena                     # la préparation ; --arena-pick ouvre le choix d'un héros
godot --path . -- --arena-fight --arena-mode duel --arena-format 2 --arena-a fire,acier --arena-b peste,mort
#   --arena-stage N (décor)  --arena-skip S (joue S s d'un coup)  --arena-speed 2  --arena-result
godot --headless --path . --script res://tests/test_arena.gd               # dans tools/verifier.sh
godot --headless --path . --script res://tests/test_arena.gd -- --durees   # durée des duels, règle HP_PER_PV
godot --headless --path . --script res://tests/test_arena.gd -- --matrice  # qui bat qui en 1 contre 1
tools/arena_matrix.sh                         # la même, sur 6 processus
python3 tools/arena_tune.py 0.8              # matrice, puis corrige ArenaRules.VIGOR
tools/.venv/bin/python tools/build_arena.py   # le Colisée : sol, gemme, décors, fond
```

- **Chaque héros a son `CombatSystem`**, et dans son `CombatContext` les héros d'en face tiennent
  la place des ennemis (`ArenaFighter`). Sorts, traits, zones et invocations marchent donc entre
  héros sans une ligne réécrite. L'ordre des adversaires ne bouge jamais, même mort : même règle que
  les repaires et les gelées.
- **Tout ce qui décide est en RefCounted** (`src/arena/` : `ArenaRules`, `ArenaFighter`,
  `ArenaBrain`, `ArenaMatch`), et `test_arena` joue de vrais matchs sans affichage. `ArenaView`
  montre, `ArenaHud` affiche, `ArenaScreen` enchaîne préparation, match et verdict.
- ⚠️ **Un PV de héros vaut `ArenaRules.HP_PER_PV` points** (400). En campagne, un ennemi retire un
  PV par coup ; un sort de héros en retire 20 à 200. Sans cette échelle, un coup tuait. Les soins
  écrits en PV valent `HEAL_PER_PV` (`ArenaFighter._scale_heal`, `SMALL_HEAL`) ;
  le prix d'un pacte (`self_cost`) ne l'est pas et ne coûte presque rien en arène.
  Mesuré le 2026-11-09 : duel 1 contre 1 en 28 s en moyenne contre le Mage du Feu, Gemme-Cœur
  gagnée en 1 à 2 minutes, Duel à mort 3 contre 3 en 30 à 45 s.
- Les effets de contrôle du combat (`enemy_staggered`, `enemies_frozen`, `enemy_pushed`…) sont
  appliqués au héros visé par `ArenaMatch._wire`. Possédé ou aveuglé, un héros erre au lieu de se
  retourner contre les siens : son combat ne connaît que ses adversaires.
- **L'équilibrage de l'arène ne touche à aucune fiche de campagne** (2026-11-10). Trois règles d'arène :
  les boucliers du jeu comptent des COUPS (45 pour la Bulle) et valent `SHIELD_PER_HIT` points, au plus
  `SHIELD_CAP` et `SHIELD_SHARE` de la vie ; une immunité dure au plus `IMMUNE_CAP` (l'Égide de la Terre
  durait trente secondes) ; un étourdissement au plus `STUN_CAP` (les Chaînes du Geôlier en duraient six).
  Puis `ArenaRules.VIGOR`, un multiplicateur de vie par personnage, réglé par passes sur la matrice :
  `tools/arena_matrix.sh` (6 processus, environ 6 minutes). Mesuré après le réglage du 2026-11-10 (esquive,
  mobilité, cadence et tactique comprises) : 28 personnages sur 29 gagnent de 43 à 61 % de leurs duels, l'Eau 64 %.
  Aël · Prisme est à 61 % au plancher de vigueur (0,4) grâce à `ATTACK_EXTRA`. ⚠️ Aël de base (l'Apprenti, portée 2)
  demande près de quatre fois sa vie (3,9) : sans portée, les tireurs le tiennent à distance. Le réglage passe
  par `python3 tools/arena_tune.py GAIN`, 1,4 puis 0,8 : à gain fort, il oscille (la Peste de 84 à 18 %).
  ⚠️ Toute modification d'un sort ou du cerveau (`ArenaBrain`) déplace ces chiffres : relancer la matrice.
- L'Extra se charge aussi avec le temps (`ULTIMATE_TICK`) : un héros ne tue que deux ou trois fois
  par match. Un kill le remplit d'un coup.
- **Les effets sont ceux du `Level`, sort par sort** : chaque héros reçoit un `Level` HÔTE
  (`Level.host_arena`), avec son `combat`, son nœud en guise de `player` et des fantômes d'`Enemy`
  sur ses adversaires en guise d'`enemies` (même `GridMover`, même `Health`, dessin caché,
  `Enemy.hide_health_bar`). Le Level dessine donc comme en campagne, marques d'état comprises, et
  `host_tick` ne fait que ce qui dessine. ⚠️ Pour cela, `load_level` est coupé en `_wire_combat`
  (tous les `combat.*.connect`) et `_populate` : un nouveau signal de sort se branche DANS
  `_wire_combat`, sinon l'arène ne le verra pas. `_on_enemy_killed` est débranché chez l'hôte :
  la chute appartient à l'arène. L'Éveil passe par `show_awakening_charge`, `set_character`,
  `show_awakening` et `end_awakening` de l'hôte, comme le fait le `GameManager`.
- ⚠️ Six lanceurs ont révélé un défaut latent du `Level` : un nœud déjà libéré rangé dans une
  variable TYPÉE (`var orb: MagicOrb = _orbs[i]`) fait une SCRIPT ERROR, même suivi de
  `is_instance_valid`. Ces lectures sont en `Variant` (orbes, zones, nuages, tourelles, marques,
  invocations). Tout nouveau dictionnaire de nœuds doit suivre la même règle.
- `--arena-generic` rejoue la première version : effets génériques par héros (`ArenaView._burst`,
  bornés par `MAX_BURSTS`), qui sert de repli et de comparaison.
- **L'Éveil en arène** : `Awakening` par héros (`ArenaFighter.attach_awakening`), chargé surtout
  par le temps (`AWAKEN_TICK`, `AWAKEN_KILL_STEPS`), défait par la chute. Les bleus s'éveillent au
  bouton (`ArenaHud`, `ArenaMatch.manual_team`), les rouges seuls ; `--arena-auto` les rend tous
  automatiques. La coque des Marées vaut un PV d'arène. Aël n'a pas d'Éveil ici.
- ⚠️ Un héros s'arrête à portée de SES SORTS (`CAST_REACH`), pas au bout de son attaque : deux
  tireurs s'échangeaient des tirs de base à sept cases sans jamais lancer un sort ni s'éveiller.
- **Le combat bouge** (2026-11-10, demande du joueur : « plus de mobilité, esquiver, pas rester à un
  endroit ») :
  - **L'esquive.** En arène, un tir ne suit plus sa cible. Il vole jusqu'à la case où elle était au
    départ (`lane`), et `ArenaMatch._misses` décide à l'arrivée : la cible est touchée si elle est
    restée sur la ligne, si elle a reculé tout droit ou si elle est dans le rayon de l'explosion ;
    sortie de côté, elle a esquivé.
    - Le crochet est générique : `CombatContext.dodge_rule`, vide en campagne, où l'attaque ne rate
      jamais, et `CombatSystem.projectile_dodged`.
    - Le pas de côté est décidé par `ArenaBrain.incoming`, au départ du tir : perpendiculaire à
      l'arrivée, `DODGE_BOOST` d'allure, `DODGE_COOLDOWN` d'attente.
    - Un sort se voit venir (`DODGE_SPELL`), une attaque de base beaucoup moins (`DODGE_ATTACK`).
    - Sans case libre, contre un sort, le héros PARE avec son bouclier s'il en a un de prêt.
    - Mesuré : 40 % des sorts-projectiles esquivés, 23 % des tirs en tout.
    - ⚠️ Une `MagicOrb` n'éclate que sur `projectile_hit`. Esquivée, elle restait figée au bout de sa
      course (vu sur iPhone).
      - Le `Level` l'éteint maintenant sur `projectile_dodged`. En arène (`hosting`), il ne la fait
        plus suivre sa cible, ce qui laisse voir l'esquive.
      - `MagicOrb.LINGER` efface toute orbe arrivée sans impact.
      - Les autres dessins de tir (croissant, flamme, langue, chute du ciel) finissaient déjà seuls.
- ⚠️ **La Nuit écarlate** (l'Extra du Chevalier) ne se levait que sur `sheathe_ended`. Un Éveil, une autre
  Rengaine ou une chute en pleine nuit défont la rengaine sans ce signal, et l'écran restait BLANC (vu sur
  iPhone, 2026-11-10). Mesuré sur 30 duels : c'était l'Éveil, la plupart du temps.
  - Le voile se lève maintenant seul au bout de sa course (`Level.NIGHT_GRACE`). Le défaut existait aussi
    en campagne.
  - `ArenaBrain` ne s'éveille plus pendant une rengaine.
  - **Il change de case** (`_battle_cell`) toutes les `STRAFE_MIN` à `STRAFE_MAX` s, dans sa bande de
    portée, de préférence hors de la ligne de l'adversaire. Un tireur ne se laisse pas approcher à
    moins de deux cases.
    ⚠️ Trois cases face à un héros de contact a été essayé : Aël tombait à 13 % de victoires.
  - **Il sort des sorts adverses** : zones posées et météores annoncés (`is_dangerous`,
    `ArenaMatch.dangers`).
  - **L'attaque de base attend `ATTACK_EXTRA` (0,3 s) de plus qu'en campagne**, ce qui a ramené
    Aël · Prisme de 82 % à environ 60 %.
  - « ESQUIVE » s'affiche au-dessus du héros, et l'écran de fin compte les esquives.
- **La tactique** (2026-11-10, deuxième demande du joueur) :
  - **La cible commune** (`ArenaBrain._choose_focus`, 3 fois par seconde). Le héros préfère le plus
    blessé à portée, puis le plus proche, et d'abord ce qu'un allié vise ou ce qui est tenu. La cible
    reste un peu collante. `CombatContext.focus` la fait passer avant le plus proche dans
    `find_target` ; il est vide en campagne.
  - **Les combos.** Sur une cible libre, le héros lance d'abord un sort de contrôle
    (`ArenaBrain.controls`, lu dans les champs du sort). Sur une cible tenue (étourdie, ralentie,
    perdue), il lance d'abord son plus gros sort. Ce gros sort attend un contrôle prêt sous
    `COMBO_WAIT`, au plus `COMBO_HOLD_MAX`.
  - **L'Extra au bon moment** (`_ultimate_moment`). Il part quand il prend deux adversaires ou plus,
    quand il peut achever, en duel sur une cible entamée, ou en dernier recours. Il ne reste jamais
    gardé plus de `ULTIMATE_PATIENCE`.
  - Mesuré sur 12 matchs de 3 contre 3 :
    - 91 % du temps, un héros vise la même cible qu'un allié ;
    - 53 % des gros sorts tombent sur une cible tenue ;
    - 23 Extras sur 37 prennent au moins deux adversaires ;
    - un match dure 31 s.
- Le ralenti de certains sorts rend `Engine.time_scale` à 1 : `ArenaScreen._process` remet le ×2.
- La caméra cadre les héros debout et la gemme (`ArenaView._aim`), sans sortir du terrain.
- Les héros sont des `Player` en `puppet` (`Actor.puppet`) : le nœud suit le `GridMover` que fait
  avancer `ArenaMatch`, sans lire le clavier ni avancer une seconde fois.
- Le terrain est `ArenaRules.LAYOUT`, symétrique (`test_arena` le vérifie), sur le décor d'un des
  dix stages au choix.
- **En volume, comme les stages** (2026-11-10, demande du joueur : « joli comme le stage ») :
  - `WorldStage.adopt_view` prend n'importe quelle scène 2D (sa caméra, son rendu à plat, ses calques
    d'entités). `adopt(level)` n'en est plus qu'un cas.
  - `ArenaScreen` crée le `WorldStage` et `ArenaView.enter_world` y entre avec ses `Level` hôtes, dont
    les effets sont redressés comme en campagne.
  - La caméra suit la mêlée (`WorldStage.aim_rows`), de `WORLD_ROWS_MIN` à `WORLD_ROWS_MAX` rangées
    ENTIÈRES : la texture du sol se retaille à chaque changement.
  - Le Colisée a son ambiance : `StageMood` 0 (plein soleil, sol plus clair que les stages), poussière
    dorée `Ambience.AIR[0]`, et une lueur sur la gemme. La gemme se redresse (`ArenaHeart.stand`), son
    cercle reste couché.
  - `--2d` rend l'ancienne vue à plat.
  - ⚠️ Six `Level` hôtes en 3D n'ont jamais été mesurés sur iPhone : à faire avec `--bench` si ça rame.
- **Le Colisée** est le décor par défaut (`ArenaRules.COLISEUM`, les dix stages restent au choix) :
  `tools/.venv/bin/python tools/build_arena.py` découpe sol, gemme, décors et fond de
  `docs/prompts/arene/` vers `assets/arena/` et `assets/tiles/arena/` (`MazeRenderer.set_tiles`).
  Les murs (`arene_mur.png`, livré le 2026-11-10) passent par `build_terrain.build_walls` et
  `enforce_contrast`, comme ceux des stages : l'outil leur prête un dossier `stage_0` de travail.
  ⚠️ La planche de gemme montre le socle SEUL en bas, pas la gemme seule, et plus haut dans sa case :
  l'outil le recale sur celui du haut et coupe la gemme au-dessus de son rebord, pour qu'elle flotte.
  ⚠️ La planche de décors ne suit pas l'ordre du prompt : `DECOR_NAMES` dit ce que chaque case MONTRE.
  `ArenaDecor` ne pose rien sur une case de sol, seulement sur l'enceinte, les piliers et les bornes.
- ⚠️ Aël ne se transforme pas en arène.

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

**L'îlot debout.** Couché sur la
texture du sol, il glissait avec elle et paraissait plat à côté des haies. `WorldStage.raise_monument`
le dresse face à la caméra, avec une ombre fixe au sol, et `House` le fait balancer. La logique
et la vue `--2d` gardent le `House` 2D, qui ne fait plus que le halo et l'onde d'ouverture.

- La texture du sol reste dessinée APRÈS l'îlot : mage, ennemis et gemmes restent devant,
  comme avant (z 10 et 6 contre 5). Le décor aussi, d'où `House.hides` qui le retire de ce
  que l'îlot couvre, sans changer les tirages du reste du semis.
- ⚠️ Ce qui s'élève glisse vers le nord, d'autant plus qu'on s'éloigne du centre de l'écran :
  sans `PANEL_SOUTH`, le portail flottait deux cases au-dessus de sa clairière.
- ⚠️ L'ombre passe par `SoftTextures.blot()` : avec `glow()`, seul le centre se voit, et il
  est caché par l'îlot. Elle semblait absente quelle que soit sa force.
- **Le portail** reprend la spirale PEINTE de l'îlot et la tourne (`monument_portal`), dans
  une ellipse relevée à la main : `House.PORTALS`. Éteint et immobile tant que la porte est
  scellée, il s'allume et tourne à l'ouverture. `--open-door` l'ouvre pour une capture.
  Un nouvel îlot demande de relever son ellipse, puis de la revoir porte ouverte.

## Les ennemis

**Seize créatures**, toutes au format des mages, dans `assets/enemies/<id>/`.
`src/entities/bestiary.gd` dit ce qu'elles valent ; le stage N ajoute ses nouveautés
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

Le **Seigneur Démon** est dessiné d'après le pack « Demon Overlord 2D Pixel Art »
(Le3cH_z), qui n'a qu'un profil : ses quatre directions ont été générées à partir de
cette référence, puis découpées par `build_enemies.py`.
⚠️ Le dépôt est public et la licence interdit de redistribuer le pack, même modifié :
ses planches (`creatures/seigneur_demon*`) sont ignorées par git, seules les bandes
réduites du jeu sont suivies. Un clone neuf garde le jeu complet, mais ne peut pas
les redécouper.

**La meute** (2026-11-09, `PackTactics`, appelé au rafraîchissement d'IA par le `Level` et par
`test_balance`, `--sans-meute` pour comparer). Deux règles :
- **L'appel** : un poursuivant lève les patrouilleurs à 12 cases de couloir ou moins (`RALLY_RADIUS`).
  Ils courent vers l'endroit où le mage a été vu (`EnemyAI.rally`, état SEARCH), avec un « ! » jaune
  au-dessus d'eux. `--meute` met la scène en place pour la voir.
- **Le contournement** : parmi les poursuivants venus du même côté, le plus proche va tout droit, les
  suivants prennent un autre chemin qui évite sa dernière approche (deux au plus, 14 cases de détour).
  ⚠️ Mesuré sur 2 400 cas de vrais labyrinthes, il n'est possible que dans 5 % des cas : le suivant
  est le plus souvent coincé dans un cul-de-sac derrière le premier, ou l'autre chemin dépasse 40 cases.
  Viser une coupure à six cases devant le mage marchait encore moins bien.
- Ne contournent ni n'appellent : le Rat, la Raie, les tireurs, les inoffensifs et les boss.
- **Le sprint** (`EnemyAI.update_sprint`, `--sans-sprint` pour comparer) : en poursuite, le mage dans
  son couloir à 6 cases ou moins, il se ramasse 0,35 s (teinte orange et cercle à ses pieds), puis
  court 1,2 s à 5,75 cases/s, en valeur absolue, juste au-dessus du mage le plus rapide (5,3). Il attend
  ensuite 5 s. Ne sprintent pas : `no_sprint` (Spectre, les deux Golems, le Démon de Cristal, les
  Gelées) ni ce qui ne contourne pas. Mesuré en passe rapide : le bot prend plus souvent les portails
  pour s'échapper (Sanctuaire, 1,0 à 2,5), mais personne ne meurt davantage.
- Mesuré en passe rapide : la meute amène plus d'ennemis au mage (kills de l'explorateur au Sanctuaire,
  14 à 22), mais personne ne meurt davantage, 0 % avant comme après.

**Les ennemis se battent contre les créatures invoquées** (2026-11-08, demande du joueur) :
celles de l'Invocateur, les ombres de la Faille des ténèbres, et leurs versions de l'Éveil (Légion,
Gargouille colossale). Elles ont des points de vie comptés en COUPS (`CombatSystem.SUMMON_HITS` :
diablotin 3, gargouille 6, ombre 3), doublés pour la Légion et multipliés par la taille. Un coup
d'ennemi en retire 1, un coup de boss 3, et une barre VERTE s'affiche dès le premier coup reçu.
- Le mage passe d'abord : un ennemi à son contact le frappe, lui. Sinon il s'arrête (`Enemy.engaged`)
  et frappe la créature à son contact, avec le même `MeleeSwing` et le même effet de coup.
- Le dragon et le cyclone sont hors d'atteinte : ils volent, et le dragon tire de loin.
- La règle est `CombatSystem.defend_against_summons`, appelée par le `Level` et par `test_balance`
  (`--sans-defense` rejoue l'ancien jeu pour comparer). Mesuré en passe rapide : les kills des
  créatures baissent nettement (Ténèbres, explorateur au Sanctuaire : 30 à 14), mais personne ne
  meurt davantage.
- Les tireurs (Golem de Lave, Archer d'Os, Golem de Givre) ne visent que le mage.

**Chaque coup ennemi se voit en trois temps** (2026-11-04, demande du joueur) : l'armement sur la
créature (`foe_charge`), puis le coup devant son arme, puis ce qui en reste. `FoeStrike` porte une
forme par façon de frapper (lame, choc au sol, morsure, souffle, éclaboussure, dard) et les couleurs
de chaque espèce et de chaque boss, joués par `Level._foe_charge` et `_foe_strike`. Le coup se voit
même s'il est esquivé ; la caméra tremble s'il touche, et à chaque coup d'un boss, qui ajoute une
onde de choc. Les zones de boss restent les images de leur planche, elles ne gagnent qu'une secousse.
- ⚠️ Les positions d'entités sont celles des PIEDS : un coup posé là semblait tomber sous le mage en
  2,5D. `BODY_LIFT` le remonte à hauteur du corps, et `ANCHORS` pose le point d'impact de chaque
  dessin sur le mage, à une case.
- Toute créature qui frappe au contact doit avoir son style : `test_creatures` le vérifie. Banc :
  `tools/preview_foe_strikes.gd` (armement, puis le coup à trois instants, sur un sol clair).

**Quatre créatures ne se contentent pas de poursuivre** (2026-11-01), et leurs règles
vivent dans `CreatureRules` et `SporeClouds`, en RefCounted, pour que `test_balance` les
simule. `tests/test_creatures.gd` les vérifie sur le vrai `Level`.
- **Rat Chapardeur** : il ne frappe jamais, il vole une gemme et fuit. La gemme reste dans
  `Level.gems` et sa `cell` suit le voleur : boussole, sceau et portails la visent sans une
  ligne de plus. Abattu, il la rend là où il tombe. Il ne prend ni les portails, ni une
  gemme à moins de trois cases du mage, et il n'y en a qu'un par niveau.
- **Gelée des Marées** : abattue, elle lâche deux petites gelées, qui ont la même planche
  (`"sheet"`), et sa mort à elle n'est pas un kill. ⚠️ Les petites ont leurs places RÉSERVÉES
  (`LevelConfig.slot_species`) : les repaires suivent les ennemis dans les tableaux du
  combat, et un ennemi ajouté en pleine partie décalerait leurs index sous les projectiles
  en vol. Utiliser `slot_species` et non `species_at` pour poser un niveau.
- **Vesse-de-Loup** : elle ne touche pas le mage. Elle crache un nuage qui le ralentit (facteur
  0,65, 5 s), peint au shader et couché sur le sol. Le ralentissement passe par
  `player.mover.speed`, recalculé à chaque frame par `Level._update_spores`.
- **Raie des Ruines** : `GridMover.phases` la laisse traverser les murs, jamais l'enceinte,
  et une seule à la fois. ⚠️ Le combat ne connaît que les distances de chemin : dans une haie
  elle serait intouchable, d'où `CreatureRules.anchor_cell`, la case de sol qui la représente.
  Elle reste visible sur les haies en 2,5D (`--raie-mur` la fige dans l'une d'elles).
- ⚠️ Leurs planches sortent de la grille, et `whole_shapes` dans `build_enemies.py` range donc
  chaque forme entière dans la case qui en tient le plus. Un dessin qui touche sa voisine se
  règle à la main avec `strike_erase` et `strike_give`, coordonnées relevées sur la planche.

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
- **L'écran de sélection a un onglet par famille** (`CharacterCatalog.CATEGORIES`,
  champ `category` de chaque personnage). Ce
  classement ne touche que le menu, aucune règle de jeu ne le lit. `tests/test_select.gd`
  vérifie que chaque personnage est bien dans un onglet.
- **La barre du mage est un cadre peint, percé** (`src/ui/hud.gd`). Le jeu remplit
  les jauges et le portrait par-dessous ; `tools/build_barre.py` découpe les planches
  de `peso&cover/interface/barre/` et mesure les trous dans `assets/ui/barre/barre.json`.
  Un cadre redessiné ne demande donc aucune constante. `tests/test_hud.gd` vérifie que
  tout tient. ⚠️ `export_presets.cfg` n'est pas suivi par git : l'exclusion de
  `interface/barre/` est à reporter sur une autre machine.
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
- **Points de vie** = ceux du personnage + le bonus du stage (0, +1, +1, puis +1 à +3 du stage 4 au 10,
  baissé le 2026-11-10 : le mage ne finissait jamais une partie sous 2 PV) : la tournée dure 1 à 3 minutes,
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
- **Attaque** : elle vise et ne rate jamais un ennemi à portée. Un projectile ratable dans
  un couloir d'une case serait de la chance, pas de l'adresse. Sans ennemi à viser, le mage
  tire quand même : droit devant, jusqu'à la première haie ou au bout de sa portée, et le
  tir frappe ce qu'il croise (`_cast_free_shot`). Ceci ne vaut que pour l'attaque de base ;
  un sort qui vise reste refusé sans cible. Les bots ne tirent jamais dans le vide.
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

- **Les trois sorts sont disponibles dès le début** (2026-11-01). Seul l'Extra Power se
  mérite, de deux façons : les kills, ou les potions, dont chacune charge la moitié de la
  jauge (`KillSystem.POTION_SHARE`). Une potion ne compte pas au score. Il y en a dès le
  stage 1.

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
