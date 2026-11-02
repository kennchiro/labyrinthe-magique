extends Node

## Outils de développement, isolés du jeu pour ne pas polluer le GameManager.
##
## Ligne de commande : godot --path . -- [options]
##   --stage N          démarre au stage N
##   --seed N           impose la graine du labyrinthe (rejeu identique)
##   --auto-walk        le mage fait seul la tournée des gemmes puis rentre
##   --zoom F           force le zoom caméra
##   --overview         vue d'ensemble du labyrinthe
##   --heatmap          heatmap des distances à la maison
##   --touch            force le joystick tactile (jouable à la souris)
##   --tap-move         force le déplacement « toucher le chemin » (avec --touch)
##   --tap X Y          simule un tap sur la case (X,Y) après 3 frames
##   --debug            affiche le bandeau d'informations techniques
##   --on-portal        démarre le joueur sur un portail
##   --character ID     mage joué : fire, water, earth, shadow, supreme, chrono, peste, lumiere, mort, etoiles, acier, demon, test
##   --potion           boit une potion : charge l'Extra Power
##   --kills N          simule N ennemis éliminés (test de l'Extra Power)
##   --fx               rejoue en boucle les cinq éclats élémentaires (contrôle visuel)
##   --demo-stage N    en démo, ouvre directement le décor du stage N
##   --use-slot N      lance le sort du slot N dès qu'il part (test des invocations)
##   --goblin / --hunter  colle cet ennemi au joueur (test de sa pose de coup)
##   --crowd          regroupe les ennemis autour du joueur (test des sorts de foule)
##   --stars          plante trois étoiles autour de l'Ange des Étoiles
##   --skill-delay F    attend F secondes avant --skill (le temps que les
##                      ennemis arrivent : un sort qui agit SUR EUX ne se
##                      capture pas à la frame zéro, le labyrinthe est vide)
##   --cast             attaque dès qu'une cible est à portée
##   --win / --lose     déclenche la victoire / la défaite (capture des écrans)
##   --pause            ouvre l'écran de pause (capture du bouton d'options)
##   --settings         ouvre aussi les réglages (avec --pause et --touch)
##   --layout-editor    ouvre aussi l'éditeur de disposition (avec --settings)
##   --cross            force la croix directionnelle (avec --touch)
##   --settings-file F  lit et écrit ces réglages-là, pas ceux du joueur
##   --bench S          mesure S secondes sans limite d'images, écrit BENCH et quitte
##   --2d               l'ancienne vue à plat, au lieu du volume (voir WorldStage)
##   --screenshot PATH  capture un PNG puis quitte
##   --frames N         laisse tourner N frames avant la capture
##
## Touches : TAB vue d'ensemble · F1 heatmap · F3 infos de debug · F5 / F6 / F7 stage

const BENCH_WARMUP_FRAMES := 60

@onready var game: GameManager = get_parent()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func apply_command_line() -> void:
	# UNE SESSION DE DÉVELOPPEMENT N'EST PAS UNE PARTIE.
	#
	# Dès qu'un argument de ligne de commande est passé, la progression cesse
	# d'être écrite sur le disque. Sans ce garde-fou, une simple capture d'écran
	# pouvait ramasser une potion ou franchir la porte et pousser la sauvegarde
	# du joueur — c'est arrivé deux fois, et la seconde après avoir déjà corrigé
	# le même défaut du côté des tests.
	game.progress.persistent = false

	var args := OS.get_cmdline_user_args()

	var character_arg := args.find("--character")
	if character_arg >= 0 and character_arg + 1 < args.size():
		game.character_id = args[character_arg + 1]
		game.start_level(game.level_index)

	var seed_arg := args.find("--seed")
	if seed_arg >= 0 and seed_arg + 1 < args.size():
		game.forced_seed = int(args[seed_arg + 1])
	_auto_walk = "--auto-walk" in args
	if _auto_walk:
		game.level.debug_lock_camera = true
	var zoom_arg := args.find("--zoom")
	if zoom_arg >= 0 and zoom_arg + 1 < args.size():
		game.level.debug_zoom = float(args[zoom_arg + 1])
	# `--stage 3` désigne le CHAPITRE, pas l'index plat : depuis que chaque stage
	# a deux épisodes, l'index plat 3 tomberait sur le stage 2. `--episode`
	# choisit lequel des deux, et c'est le second qui porte les règles de fin
	# de chapitre (destruction des repaires aux stages 3 et 9).
	var stage_arg := args.find("--stage")
	if stage_arg >= 0 and stage_arg + 1 < args.size():
		var ep := 1
		var episode_arg := args.find("--episode")
		if episode_arg >= 0 and episode_arg + 1 < args.size():
			ep = int(args[episode_arg + 1])
		# ⚠️ LA DÉMO N'A PAS LA MÊME LISTE QUE LA PARTIE, et l'option l'ignorait.
		#
		# En partie, les niveaux sont (stage, épisode) : dix stages de deux
		# épisodes, vingt entrées, et `flat_index` fait la conversion. En DÉMO,
		# `GameManager` prépare UN niveau par stage — dix entrées — parce que la
		# démo sert à regarder un décor, pas à jouer un épisode.
		#
		# Passer un index plat dans cette liste-là envoyait `--stage 3` au stage
		# CINQ, et tout ce qui dépassait 5 au dixième. On cherchait un serpent
		# dans les Cavernes de Cristal, où il n'y en a pas.
		var wanted := int(args[stage_arg + 1])
		var demo := game.levels.size() == LevelConfig.STAGE_COUNT
		game.start_level(wanted - 1 if demo else LevelConfig.flat_index(wanted, ep))

	if "--debug" in args:
		game.ui.debug_label.visible = true
	if "--heatmap" in args:
		game.level.maze_renderer.show_distance_field = true
		game.level.maze_renderer.queue_redraw()
	if "--overview" in args:
		game.level.set_overview(true)
	# Pose le joueur sur un portail : pour tester la téléportation à la main
	# sans avoir à traverser la moitié du labyrinthe.
	if "--on-portal" in args and game.level.player != null:
		game.level.player.mover.teleport_to(game.level.grid.portals[0])
		game.level.player.snap_to_mover()
		# Sans quoi la sortie de maison du début reprendrait : le mage quitterait
		# le portail pour retraverser le labyrinthe vers sa porte.
		game.level.player.cancel_path()
	# Ouvre la maison sans tourner dans le labyrinthe : pour capturer son portail.
	if "--open-door" in args:
		game.level.debug_collect_all_gems()
	if "--potion" in args:
		game.kills.drink_potion()
		game.ui.set_kills(game.kills.progress, game.kills.needed, game.kills.available())
	# Lance un sort précis dès que possible : --use-slot 1 (voir GameManager.SLOT_*).
	var slot_arg := args.find("--use-slot")
	if slot_arg >= 0 and slot_arg + 1 < args.size():
		_slot_wanted = int(args[slot_arg + 1])
		_slot_tries = 240
	# Avance de N décors en démo, pour capturer un stage précis :
	#   --demo --demo-stage 6
	var demo_arg := args.find("--demo-stage")
	if demo_arg >= 0 and demo_arg + 1 < args.size():
		game.demo_stage(int(args[demo_arg + 1]) - 1)
	var kills_arg := args.find("--kills")
	if kills_arg >= 0 and kills_arg + 1 < args.size():
		for i in int(args[kills_arg + 1]):
			game.kills.register_kill()
		game.ui.set_kills(game.kills.progress, game.kills.needed, game.kills.available())
	# Colle un ennemi au joueur : la seule façon de voir sa pose de coup sans
	# jouer jusqu'à se faire rattraper, donc de pouvoir la capturer en image.
	_crowd_pending = "--crowd" in args
	if "--goblin" in args:
		_cling_enemy("goblin")
	if "--hunter" in args:
		_cling_enemy("hunter")
	# N'importe quelle créature du bestiaire : `--enemi golem`.
	var species_arg := args.find("--enemi")
	if species_arg >= 0 and species_arg + 1 < args.size():
		_cling_enemy(args[species_arg + 1])
	# Fige la Raie dans une haie : en jouant, elle n'y reste qu'une demi-seconde.
	if "--raie-mur" in args:
		_hold_ray_in_wall()
	# Tue un ennemi sur place : la seule façon de voir la maison s'ouvrir sans
	# attendre d'en abattre un en jouant, donc de pouvoir la capturer.
	# Pose le mage devant la maison du coin : la seule façon de voir la barre de
	# vie d'un repaire descendre sans traverser un stage entier.
	if "--at-lair" in args and not game.level.lairs.is_empty():
		game.level.player.mover.teleport_to(game.level.lairs[0].cell)
		game.level.player.snap_to_mover()
		game.level.player.cancel_path()
	# Abat les deux maisons d'un coup : la seule façon de voir l'annonce de fin
	# de chapitre et l'arrêt des vagues sans jouer le niveau en entier.
	# Déclenche le sort de FUITE : la seule façon de capturer la colonne de
	# téléportation sans jouer jusqu'à en avoir besoin. On RÉESSAIE, parce que
	# la translation est refusée quand le mage regarde un mur — au départ, une
	# fois sur deux.
	if "--warp" in args:
		_warp_tries = 30
	# Lance un SORT précis en boucle : la seule façon de capturer la boule de
	# feu à l'image près, sans jouer jusqu'à ce qu'elle soit prête.
	var delay_arg := args.find("--skill-delay")
	if delay_arg >= 0 and delay_arg + 1 < args.size():
		_skill_delay = float(args[delay_arg + 1])
	var skill_arg := args.find("--skill")
	if skill_arg >= 0 and skill_arg + 1 < args.size():
		_skill_slot = int(args[skill_arg + 1])
		# QUATRE SECONDES DE RELANCES et non deux tiers de seconde. Un sort qui
		# exige une CIBLE — la Faille des ténèbres n'ouvre rien sans proie — est
		# refusé tant que personne n'est sorti de son repaire, et la capture
		# repartait sans l'avoir jamais lancé.
		_skill_tries = 240
	# Plante trois étoiles autour du mage : les rayons d'une Constellation demandent de marcher.
	if "--stars" in args and game.level.character.id == CharacterCatalog.ETOILES:
		var around: Vector2i = game.level.player.mover.nearest_cell()
		for gap: Vector2i in [Vector2i(-3, -1), Vector2i(3, -2), Vector2i(1, 3)]:
			game.level.combat._stars.append({"cell": around + gap, "time_left": 30.0,
				"ability": game.level.character.abilities[0]})
		game.level.combat._report_stars()
	if "--raze" in args:
		for lair in game.level.lairs:
			if lair.is_vulnerable():
				lair.health.take(Damage.new(99999, Element.Kind.SUPREME, "debug"))
	# Le boss sans la tournée : `--stage 4 --episode 2 --boss`. Il surgit par le vrai chemin.
	if "--boss" in args and game.demo:
		# Par le bouton lui-même : c'est aussi son branchement qu'on regarde.
		game.ui.demo_bar.get_node("Boss").pressed.emit()
		if "--boss-down" in args:
			_down_boss_later()
	elif "--boss" in args and game.level.config.has_boss():
		game.level.debug_collect_all_gems()
		for lair in game.level.lairs:
			if lair.is_vulnerable():
				lair.health.take(Damage.new(99999, Element.Kind.SUPREME, "debug"))
		game.level.summon_boss()
		if "--boss-down" in args:
			_down_boss_later()
	if "--lair" in args and not game.level.enemies.is_empty():
		game.level._on_enemy_killed(0)
		# Sans raccourcir l'attente, il faudrait capturer huit secondes plus tard.
		game.level._respawns[0] = 0.4
	_auto_cast = "--cast" in args
	_show_fx = "--fx" in args
	# Simule un tap du mode « toucher le chemin » sur une case. On attend
	# quelques frames : la caméra n'a pas encore appliqué son cadrage à la
	# frame zéro, et l'ordre passe par la VRAIE conversion écran -> case.
	var tap_arg := args.find("--tap")
	if tap_arg >= 0 and tap_arg + 2 < args.size():
		_pending_tap = Vector2i(int(args[tap_arg + 1]), int(args[tap_arg + 2]))
		_tap_countdown = 3

	var bench_arg := args.find("--bench")
	if bench_arg >= 0 and bench_arg + 1 < args.size():
		_run_bench(float(args[bench_arg + 1]))
		return
	if "--screenshot" in args:
		# L'issue est déclenchée APRÈS l'attente de frames, pour que l'écran de
		# fin affiche un temps de partie réaliste et non 0,0 s.
		_capture_and_quit(args)
	else:
		_apply_outcome(args)


## La fluidité en chiffres. La moyenne cache les à-coups, seuls ressentis en jouant :
## c'est le 99e centile qu'il faut lire.
func _run_bench(seconds: float) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	for i in BENCH_WARMUP_FRAMES:
		await get_tree().process_frame
	var times: Array[float] = []
	var total := 0.0
	# Une vraie horloge : `delta` est lissé par le moteur et retombe sur des multiples
	# de 1/120 s, ce qui efface justement les à-coups qu'on vient mesurer.
	var last := Time.get_ticks_usec()
	while total < seconds:
		await get_tree().process_frame
		var now := Time.get_ticks_usec()
		var spent := (now - last) / 1000000.0
		last = now
		times.append(spent)
		total += spent
	times.sort()
	var report := "BENCH [" + " ".join(OS.get_cmdline_user_args()) + "] images=%d %.0f img/s p50=%.2fms p99=%.2fms pire=%.2fms appels=%d" % [
		times.size(), times.size() / total, times[times.size() / 2] * 1000.0,
		times[int(times.size() * 0.99)] * 1000.0, times[-1] * 1000.0,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)]
	print(report)
	# Sur iPhone, `print` ne remonte pas à la console de devicectl : le résultat se
	# récupère dans ce fichier, `Documents/bench.txt` du conteneur de l'application.
	var file := FileAccess.open("user://bench.txt", FileAccess.WRITE)
	if file != null:
		file.store_line(report)
		file.close()
	get_tree().quit()


## Pose un ennemi À QUELQUES CASES du joueur, dans un couloir droit, et non
## collé à lui : c'est l'APPROCHE qu'on veut pouvoir capturer — l'orientation
## qu'il prend en marchant, l'arrêt à une case, puis le geste. Posé au contact,
## il n'a jamais eu de direction et reste tourné vers l'écran.
const CLING_DISTANCE := 3


func _hold_ray_in_wall() -> void:
	var from := game.level.player.mover.nearest_cell()
	for enemy in game.level.enemies:
		if enemy.species != "raie":
			continue
		for reach in range(1, 9):
			# Sur les côtés : plus haut ou plus bas, la haie sort du cadre.
			for direction in [Vector2i.RIGHT, Vector2i.LEFT]:
				var cell: Vector2i = from + direction * int(reach)
				if enemy.mover.can_walk(cell) and not game.level.grid.is_floor_v(cell):
					enemy.revive_at(cell)
					enemy.stagger(3600.0)
					return


func _cling_enemy(species: String) -> void:
	if game.level.player == null:
		return
	var cell := game.level.player.mover.nearest_cell()
	var spot := cell
	for step in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]:
		var probe := cell
		var reached := cell
		for i in CLING_DISTANCE:
			probe += step
			if not game.level.grid.is_floor_v(probe):
				break
			reached = probe
		if reached != cell:
			spot = reached
			break
	for enemy in game.level.enemies:
		if enemy.species != species:
			continue
		# Depuis que les surnuméraires attendent dans leur maison au démarrage,
		# la créature demandée est souvent MORTE à l'image zéro : la coller au
		# mage sans la ranimer ne montrait rien du tout.
		enemy.revive_at(spot)
		enemy.snap_to_mover()
		return


var _slot_wanted := -1
var _slot_tries := 0
var _crowd_pending := false
var _auto_walk := false
var _warp_tries := 0
var _skill_slot := -1
var _skill_tries := 0
## Attente avant de lancer `--skill`, en secondes.
var _skill_delay := 0.0
var _auto_cast := false
var _show_fx := false
var _fx_timer := 0.0
var _pending_tap := Vector2i(-1, -1)
var _tap_countdown := 0


## Cinq ennemis à trois ou quatre pas du joueur : une foule ne se forme pas toute seule au départ.
func _gather_crowd() -> void:
	var level = game.level
	var grid: MazeGrid = level.enemies[0].mover.grid
	var from: Vector2i = level.player.mover.nearest_cell()
	var field := Pathfinder.distance_field(grid, [from] as Array[Vector2i])
	var spots: Array[Vector2i] = []
	for y in grid.rows:
		for x in grid.cols:
			var distance := Pathfinder.value_at(grid, field, Vector2i(x, y))
			if distance >= 3 and distance <= 4:
				spots.append(Vector2i(x, y))
	for i in mini(5, mini(spots.size(), level.enemies.size())):
		level.enemies[i].mover.teleport_to(spots[i])
		level.enemies[i].snap_to_mover()


func _process(delta: float) -> void:
	if _skill_delay > 0.0:
		_skill_delay -= delta
	elif _skill_tries > 0 and _skill_slot >= 0:
		_skill_tries -= 1
		if game.level.player != null and game.level.use_ability(_skill_slot):
			_skill_tries = 0

	if _pending_tap.x >= 0:
		_tap_countdown -= 1
		if _tap_countdown <= 0 and game.level.player != null:
			var screen: Vector2 = game.level.to_screen(
				game.level.maze_renderer.cell_to_world(_pending_tap))
			if not game.level.order_player_walk(screen):
				push_warning("--tap %s : case injouable" % _pending_tap)
			_pending_tap = Vector2i(-1, -1)
	if _crowd_pending and game.level.player != null and not game.level.enemies.is_empty():
		_crowd_pending = false
		_gather_crowd()
	if _warp_tries > 0:
		_warp_tries -= 1
		# `use_slot` rend faux quand le sort est refusé ; on retente à la frame
		# suivante, le mage ayant tourné entre-temps.
		# On s'appuie sur le retour RÉEL de `use_ability` : `can_use` dit oui
		# pour une translation (elle n'a pas de cible), mais le sort est quand
		# même refusé quand le chemin devant le mage est bouché.
		if game.level.player != null and game.level.use_ability(4):
			_warp_tries = 0

	if _slot_tries > 0 and _slot_wanted >= 0:
		_slot_tries -= 1
		if game.level.use_ability(_slot_wanted):
			_slot_tries = 0

	if _auto_walk:
		_drive_player()
	if _show_fx:
		_replay_effects(delta)
	if _auto_cast and game.level.can_use(GameManager.SLOT_ATTACK) \
			and game.level.has_target(GameManager.SLOT_ATTACK):
		game.level.use_ability(GameManager.SLOT_ATTACK)
	if not game.ui.debug_label.visible or game.level.grid == null:
		return
	var chase := 0
	for enemy in game.level.enemies:
		if enemy.ai != null and enemy.ai.state == EnemyAI.State.CHASE:
			chase += 1
	var view: Vector2 = game.level.get_viewport_rect().size
	var zoom: float = game.level.camera.zoom.x
	game.ui.debug_label.text = "grille %dx%d · portails %d · ennemis %d (%d en poursuite) · %.0f fps\nfenêtre %dx%d · viewport %dx%d · zoom %.2f · vue %.1fx%.1f cases\n[TAB] vue  [F1] heatmap  [F5][F6][F7] stage  [R] recommencer" % [
		game.level.grid.cols, game.level.grid.rows,
		game.level.grid.portals.size(), game.level.enemies.size(), chase,
		Engine.get_frames_per_second(),
		DisplayServer.window_get_size().x, DisplayServer.window_get_size().y,
		int(view.x), int(view.y), zoom,
		view.x / zoom / Level.TILE_SIZE, view.y / zoom / Level.TILE_SIZE,
	]


## Pilote le mage : gemme la plus proche, puis la suivante, puis la maison une
## fois la porte ouverte. Sert à capturer une partie entière sans tenir une
## touche — et à vérifier que la boucle d'objectif se termine vraiment.
func _drive_player() -> void:
	var level := game.level
	if level.player == null or level.grid == null:
		return
	var from := level.player.mover.decision_cell()
	var field := level.grid.distance_to_house

	# Tant qu'il reste une gemme, le champ de distances de la maison ne sert à
	# rien : on descend celui de la gemme visée.
	var target := _closest_gem_cell(level, from)
	if target.x >= 0:
		field = Pathfinder.distance_field(level.grid, [target] as Array[Vector2i])

	var step := Pathfinder.step_toward(level.grid, field, from)
	level.player.debug_direction = Vector2(step)


func _closest_gem_cell(level: Level, from: Vector2i) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_distance := 1 << 30
	for gem in level.gems:
		if not is_instance_valid(gem):
			continue
		var distance := absi(gem.cell.x - from.x) + absi(gem.cell.y - from.y)
		if distance < best_distance:
			best_distance = distance
			best = gem.cell
	return best


func _apply_outcome(args: PackedStringArray) -> void:
	# Déclenche les vrais signaux du niveau, pas un raccourci : ce qu'on capture
	# est bien le chemin de code emprunté en jeu.
	if "--pause" in args and game.state == GameManager.State.PLAYING:
		# Le rendu continue pendant la pause de l'arbre : la capture différée
		# de --screenshot montre donc bien l'écran de pause.
		game.toggle_pause()
		if "--settings" in args:
			game.ui.open_settings()
			if "--layout-editor" in args:
				game.ui.settings_panel().open_editor()
	if "--win" in args:
		# La porte est scellée : sans les gemmes, le signal ne produirait qu'un
		# « il manque 5 gemmes ». On les ramasse d'abord, par le vrai chemin.
		game.level.debug_collect_all_gems()
		game.level.player_reached_house.emit()
	if "--lose" in args:
		game.level.player_caught.emit()


## Abat le boss une fois arrivé, le mage sur le seuil : la fin du combat, par le vrai chemin.
func _down_boss_later() -> void:
	await get_tree().create_timer(Level.BOSS_ARRIVAL_TIME + 0.4).timeout
	var level: Level = game.level
	level.player.cancel_path()
	level.player.mover.teleport_to(level.grid.house_center)
	level.debug_kill_boss()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_F5:
			game.start_level(0)
		KEY_F6:
			game.start_level(1)
		KEY_F7:
			game.start_level(2)
		KEY_F1:
			game.level.maze_renderer.toggle_distance_field()
		KEY_F3:
			game.ui.debug_label.visible = not game.ui.debug_label.visible
		KEY_TAB:
			game.level.set_overview(not game.level.overview)


func _capture_and_quit(args: PackedStringArray) -> void:
	for i in Screenshot.frames(args):
		await RenderingServer.frame_post_draw
	# L'issue est déclenchée APRÈS l'attente, pour que l'écran de fin affiche un
	# temps de partie réaliste et non 0,0 s.
	_apply_outcome(args)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	Screenshot.save(self, args)
	get_tree().quit()


## Rejoue les cinq éclats élémentaires côte à côte, en boucle. Comparer les
## effets d'un mage à l'autre demanderait sinon de jouer cinq parties et de
## déclencher le bon sort au bon moment devant la caméra.
func _replay_effects(delta: float) -> void:
	var level := game.level
	if level.player == null:
		return
	_fx_timer -= delta
	if _fx_timer > 0.0:
		return
	_fx_timer = 0.9
	var centre := level.player.mover.nearest_cell()
	var elements := [Element.Kind.FIRE, Element.Kind.WATER, Element.Kind.EARTH,
		Element.Kind.SHADOW, Element.Kind.SUPREME]
	for i in elements.size():
		var cell: Vector2i = centre + Vector2i((i - 2) * 3, 0)
		level._spawn_impact(cell, elements[i], 1.8, 0.85)
