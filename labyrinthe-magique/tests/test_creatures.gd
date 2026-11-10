extends SceneTree

## Le Rat, la Gelée, la Vesse et la Raie, avec le vrai Level.
##   godot --headless --path . --script res://tests/test_creatures.gd
##
## Leurs règles touchent à ce qui fait gagner une partie : la gemme volée doit revenir, une
## gelée ne doit pas donner trois kills. `test_balance` ne verrait ni l'un ni l'autre : il
## mesure des taux de mort, pas ce qu'il advient d'une gemme.

const LEVEL_SCENE := "res://scenes/level.tscn"
const FRAME := 1.0 / 60.0

var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_slots()
	_test_thief_flees()
	_test_clouds()
	_test_phasing()
	_test_strike_styles()
	_test_summons_fought()
	_test_pack()
	_test_sprint()
	await _test_stolen_gem()
	await _test_split()
	await _test_spit()
	await _test_rally_in_level()

	print("")
	if _failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT")
	else:
		print("❌  %d ÉCHEC(S) :" % _failures.size())
		for f in _failures:
			print("   - ", f)
	quit(0 if _failures.is_empty() else 1)


func _fail(msg: String) -> void:
	_failures.append(msg)


func _level_with(stage: int, species: String) -> Level:
	var level: Level = load(LEVEL_SCENE).instantiate()
	root.add_child(level)
	level.load_level(LevelConfig.for_stage(stage), CharacterCatalog.shadow(), 77)
	if _first(level, species) == null:
		_fail("le stage %d ne pose pas %s" % [stage, species])
	return level


func _first(level: Level, species: String) -> Enemy:
	for enemy in level.enemies:
		if enemy.species == species:
			return enemy
	return null


func _cell_far_from_player(level: Level) -> Vector2i:
	var field := Pathfinder.distance_field(level.grid,
		[level.player.mover.nearest_cell()] as Array[Vector2i])
	var best := level.grid.gems[0]
	for gem in level.grid.gems:
		if Pathfinder.value_at(level.grid, field, gem) > Pathfinder.value_at(level.grid, field, best):
			best = gem
	return best


## Les petites gelées sont réservées APRÈS les poursuivants, et le Rat reste seul.
func _test_slots() -> void:
	for episode in [1, 2]:
		var config := LevelConfig.for_stage(4, episode)
		var slots := config.slot_species(config.enemy_count)
		var droplets := slots.slice(config.enemy_count)
		for id in droplets:
			if not Bestiary.is_droplet(id):
				_fail("place réservée à autre chose qu'une petite gelée : %s" % id)
		if droplets.size() != slots.slice(0, config.enemy_count).count("gelee") * 2:
			_fail("deux places par gelée, il y en a %d" % droplets.size())
		var rats := LevelConfig.for_stage(3, episode).slot_species(8).count("rat")
		if rats != 1:
			_fail("%d rats sur un niveau, un seul attendu" % rats)
	print("places : petites gelées réservées, un seul rat : OK")


func _test_thief_flees() -> void:
	var grid := MazeGrid.new(9, 3)
	for c in range(1, 8):
		grid.set_cell(c, 1, MazeGrid.Cell.FLOOR)
	var field := Pathfinder.distance_field(grid, [Vector2i(3, 1)] as Array[Vector2i])
	var ai := EnemyAI.new(8, 1)
	var step := ai.decide_thief(grid, Vector2i(5, 1), Vector2i.ZERO, PackedInt32Array(),
		field, true, FRAME)
	if step != Vector2i.RIGHT:
		_fail("le rat chargé devrait fuir vers la droite, il va vers %s" % step)
	if ai.decide_thief(grid, Vector2i(7, 1), Vector2i.ZERO, PackedInt32Array(), field,
			true, FRAME) != Vector2i.ZERO:
		_fail("acculé, le rat devrait attendre")
	if CreatureRules.may_steal(grid, field, Vector2i(5, 1)):
		_fail("le rat ne doit pas prendre une gemme sous le nez du mage")
	print("rat : il fuit, s'accule et respecte le mage : OK")


func _test_clouds() -> void:
	var clouds := SporeClouds.new()
	var cell := Vector2i(2, 2)
	clouds.spit([cell] as Array[Vector2i], 0.5)
	clouds.advance(0.4)
	if clouds.speed_factor(cell) < 1.0:
		_fail("le nuage ne doit ralentir qu'à l'impact")
	if clouds.advance(0.2).size() != 1 or clouds.speed_factor(cell) >= 1.0:
		_fail("le nuage devrait être tombé")
	clouds.advance(SporeClouds.DURATION + 0.1)
	if clouds.speed_factor(cell) < 1.0:
		_fail("le nuage devrait s'être dissipé")
	print("vesse : le nuage tombe à l'impact et se dissipe : OK")


func _test_phasing() -> void:
	var grid := MazeGrid.new(9, 5)
	for c in range(1, 8):
		grid.set_cell(c, 1, MazeGrid.Cell.FLOOR)
		grid.set_cell(c, 3, MazeGrid.Cell.FLOOR)
	var mover := GridMover.new(grid, Vector2i(4, 1), 5.0)
	if mover.can_walk(Vector2i(4, 2)):
		_fail("un marcheur ordinaire traverse la haie")
	mover.phases = true
	if not mover.can_walk(Vector2i(4, 2)):
		_fail("la raie ne traverse pas la haie")
	if mover.can_walk(Vector2i(4, 0)):
		_fail("la raie sort de l'enceinte")
	var ai := EnemyAI.new(8, 1)
	var field := Pathfinder.distance_field(grid, [Vector2i(4, 3)] as Array[Vector2i])
	if ai.decide_phasing(grid, Vector2i(4, 1), Vector2i.ZERO, field, Vector2i(4, 3), 6.0,
			FRAME) != Vector2i.DOWN:
		_fail("la raie devrait aller droit sur le mage")
	if CreatureRules.anchor_cell(grid, Vector2i(4, 2), Vector2i(4, 3)) != Vector2i(4, 3):
		_fail("dans la haie, la raie doit rester à portée des sorts")
	print("raie : elle traverse, sans sortir, et reste touchable : OK")


## Toute créature qui frappe au contact a son coup peint, et chaque boss aussi.
func _test_strike_styles() -> void:
	for id: String in Bestiary.SPECIES:
		var tuning := Bestiary.of(id)
		var melee := not bool(tuning.get("harmless", false)) \
			and not bool(tuning.get("ranged_only", false))
		if melee and not FoeStrike.has_style(id):
			_fail("%s frappe au contact sans effet de coup" % id)
	for id: String in FoeStrike.STYLES:
		if not FoeStrike.SHADERS.has(str(FoeStrike.STYLES[id]["key"])):
			_fail("le coup de %s demande une forme inconnue" % id)
	print("coups : chaque créature qui frappe a le sien : OK")


## Les ennemis abattent les créatures invoquées, au bon nombre de coups.
func _test_summons_fought() -> void:
	var grid := MazeGrid.new(9, 3)
	for c in range(1, 8):
		grid.set_cell(c, 1, MazeGrid.Cell.FLOOR)
	var cases := [["imp", false, false, 3], ["imp", true, false, 6],
		["gargouille", false, true, 2], ["ombre", false, false, 3]]
	for entry: Array in cases:
		var combat := CombatSystem.new(grid, CharacterCatalog.invocateur(), Health.new(3), 5)
		if bool(entry[1]):
			combat.start_legion(60.0, 1.5, 8)
		var summon := combat._spawn_summon(str(entry[0]), Vector2i(3, 1), 60.0, null)
		var slain := {"done": false}
		combat.summon_slain.connect(func(id: int) -> void:
			slain["done"] = id == int(summon["id"]))
		var foe := {"position": Vector2(2, 1), "free": true, "windup": 0.2, "cycle": 0.6,
			"boss": bool(entry[2])}
		var landed := 0
		for _frame in 60 * 20:
			for event in combat.defend_against_summons(FRAME, [foe], 1.05):
				if str(event["event"]) == "landed":
					landed += 1
					if event["toward"] != Vector2i.RIGHT:
						_fail("l'ennemi frappe la créature du mauvais côté")
			if slain["done"]:
				break
		if not slain["done"] or landed != int(entry[3]):
			_fail("%s%s%s : %d coups pour l'abattre, attendu %d" % [entry[0],
				" de la Légion" if entry[1] else "", " par un boss" if entry[2] else "",
				landed, entry[3]])
		if combat.summon_count() != 0:
			_fail("%s abattue mais toujours en chasse" % entry[0])
	var combat := CombatSystem.new(grid, CharacterCatalog.invocateur(), Health.new(3), 5)
	combat._spawn_summon("dragon", Vector2i(3, 1), 60.0, null)
	combat._spawn_summon("imp", Vector2i(5, 1), 60.0, null)
	if not combat.summon_in_reach(Vector2(2, 1), 1.05).is_empty():
		_fail("le dragon, qui vole, ne doit pas être à portée de coup")
	var busy := {"position": Vector2(4, 1), "free": false, "windup": 0.2, "cycle": 0.6}
	for _frame in 120:
		if not combat.defend_against_summons(FRAME, [busy], 1.05).is_empty():
			_fail("un ennemi occupé à frapper le mage frappe aussi une créature")
			break
	print("invocations : les ennemis les abattent, la Légion tient deux fois plus : OK")


## La meute : sur un anneau, le second poursuivant d'un même côté fait le tour par l'autre.
func _test_pack() -> void:
	var grid := MazeGrid.new(9, 9)
	for i in range(1, 8):
		for cell: Vector2i in [Vector2i(i, 1), Vector2i(i, 7), Vector2i(1, i), Vector2i(7, i)]:
			grid.set_cell(cell.x, cell.y, MazeGrid.Cell.FLOOR)
	var mage := Vector2i(4, 1)
	var field := Pathfinder.distance_field(grid, [mage] as Array[Vector2i])
	var lead := {"index": 0, "cell": Vector2i(1, 3)}
	var follower := {"index": 1, "cell": Vector2i(1, 5)}
	var flanks := PackTactics.assign(grid, mage, field, [lead, follower] as Array[Dictionary])
	if flanks.has(0) or not flanks.has(1):
		_fail("le premier doit poursuivre et le second contourner : %s" % [flanks.keys()])
	else:
		var ai := EnemyAI.new(20, 1)
		ai.flank_field = flanks[1]
		if ai.decide(grid, follower["cell"], Vector2i.UP, field, FRAME) != Vector2i.DOWN:
			_fail("le contourneur devrait partir par le bas de l'anneau")
		# Passé de l'autre côté, il arrive sur le mage par la droite de l'anneau.
		if ai.decide(grid, Vector2i(7, 4), Vector2i.UP, field, FRAME) != Vector2i.UP:
			_fail("de l'autre côté, le contourneur doit remonter vers le mage")
	if not PackTactics.assign(grid, mage, field, [lead] as Array[Dictionary]).is_empty():
		_fail("un poursuivant seul ne contourne pas")
	var both_sides := [lead, {"index": 1, "cell": Vector2i(7, 3)}] as Array[Dictionary]
	if not PackTactics.assign(grid, mage, field, both_sides).is_empty():
		_fail("deux poursuivants venus de deux côtés n'ont rien à contourner")
	# L'appel : un patrouilleur proche répond, un lointain non.
	var long := MazeGrid.new(40, 3)
	for c in range(1, 39):
		long.set_cell(c, 1, MazeGrid.Cell.FLOOR)
	var called := PackTactics.rally(long, [Vector2i(5, 1)] as Array[Vector2i],
		[{"index": 3, "cell": Vector2i(14, 1)}, {"index": 4, "cell": Vector2i(30, 1)}] as Array[Dictionary])
	if called.size() != 1 or called[0] != 3:
		_fail("l'appel devrait toucher le patrouilleur proche seul : %s" % [called])
	var rallied := EnemyAI.new(4, 1)
	var line := Pathfinder.distance_field(long, [Vector2i(5, 1)] as Array[Vector2i])
	if not rallied.rally(line, 6.0) or rallied.decide(long, Vector2i(14, 1), Vector2i.RIGHT, line,
			FRAME) != Vector2i.LEFT:
		_fail("appelé, il doit courir vers le mage même hors de vue")
	print("meute : le suivant arrive par l'autre bout, et l'appel lève les proches : OK")


## Le sprint : il se ramasse, fonce plus vite que le mage, puis souffle. Pas les masses.
func _test_sprint() -> void:
	var grid := MazeGrid.new(20, 3)
	for c in range(1, 19):
		grid.set_cell(c, 1, MazeGrid.Cell.FLOOR)
	var ai := EnemyAI.new(8, 1)
	ai.state = EnemyAI.State.CHASE
	var from := Vector2i(4, 1)
	var mage := Vector2i(9, 1)
	if ai.update_sprint(FRAME, grid, from, mage, true) != EnemyAI.Sprint.WINDUP:
		_fail("le mage dans son couloir, il devrait se ramasser pour sprinter")
	var seen := {}
	var elapsed := 0.0
	while elapsed < EnemyAI.SPRINT_WINDUP + EnemyAI.SPRINT_TIME + 0.2:
		seen[ai.update_sprint(FRAME, grid, from, mage, true)] = true
		elapsed += FRAME
	if not seen.has(EnemyAI.Sprint.RUNNING):
		_fail("après l'arrêt, il devrait foncer")
	if ai.update_sprint(FRAME, grid, from, mage, true) != EnemyAI.Sprint.NONE:
		_fail("après sa course, il doit souffler avant de recommencer")
	var fresh := EnemyAI.new(8, 1)
	fresh.state = EnemyAI.State.CHASE
	if fresh.update_sprint(FRAME, grid, from, Vector2i(14, 1), true) != EnemyAI.Sprint.NONE:
		_fail("trop loin pour le voir, il ne sprinte pas")
	if fresh.update_sprint(FRAME, grid, from, mage, false) != EnemyAI.Sprint.NONE:
		_fail("une espèce qui ne sprinte pas ne sprinte pas")
	if EnemyAI.sprint_speed(EnemyAI.Sprint.RUNNING, 3.8) <= 5.3:
		_fail("en course, il doit dépasser le mage le plus rapide")
	if Bestiary.sprints("golem") or Bestiary.sprints("rat") or not Bestiary.sprints("goblin"):
		_fail("les masses et le Rat ne sprintent pas, le Gobelin oui")
	print("sprint : il se ramasse, fonce, puis souffle : OK")


## LA GEMME NE SORT JAMAIS DU JEU : c'est ce qui rend le vol juste, et ce qui bloquerait la
## partie pour de bon si c'était faux.
func _test_stolen_gem() -> void:
	var level := _level_with(3, "rat")
	var rat := _first(level, "rat")
	var cell := _cell_far_from_player(level)
	rat.revive_at(cell)
	level._refresh_ai()
	var before := level.gems_remaining()
	var signals := {"stolen": 0}
	level.gem_stolen.connect(func() -> void: signals["stolen"] += 1)
	level._update_thieves()
	if rat.stolen == null or signals["stolen"] != 1:
		_fail("le rat posé sur une gemme devrait la prendre")
		return
	var gem := rat.stolen
	if level.gems_remaining() != before or not level.gems.has(gem):
		_fail("une gemme volée reste à ramasser")
	# Le mage passe sur la case d'origine : il n'y a plus rien.
	level.player.mover.teleport_to(cell)
	level._update_pickups(FRAME)
	if not level.gems.has(gem) or level.gems_remaining() != before:
		_fail("le mage a ramassé une gemme que le rat porte")
	level.player.mover.teleport_to(level.grid.player_spawn)
	# Le rat s'éloigne : la gemme suit, et la boussole avec elle.
	var away := _cell_far_from_player(level)
	for candidate in level.grid.house_cells:
		away = candidate
		break
	rat.mover.teleport_to(away)
	level._update_thieves()
	if gem.cell != away:
		_fail("la gemme ne suit pas son voleur")
	level._refresh_ai()
	if level._objective_cell != level._nearest_gem().cell:
		_fail("l'objectif ne suit pas les gemmes")
	level._on_enemy_killed(level.enemies.find(rat))
	if gem.carried or gem.cell != away or rat.stolen != null:
		_fail("abattu, le rat doit rendre la gemme là où il tombe")
	level.player.mover.teleport_to(away)
	level._update_pickups(FRAME)
	if level.gems_remaining() != before - 1:
		_fail("la gemme rendue devrait se ramasser")
	level.queue_free()
	await process_frame
	print("rat : la gemme suit, revient et se ramasse : OK")


## Une gelée vaut deux kills, jamais trois, et ses petites ne reviennent pas.
func _test_split() -> void:
	var level := _level_with(4, "gelee")
	var big := _first(level, "gelee")
	big.revive_at(_cell_far_from_player(level))
	var count := {"kills": 0}
	level.enemy_killed.connect(func() -> void: count["kills"] += 1)
	var slots_before := level.enemies.size()
	level._on_enemy_killed(level.enemies.find(big))
	var alive: Array[Enemy] = []
	for enemy in level.enemies:
		if enemy.species == "gelee_petite" and not enemy.dead:
			alive.append(enemy)
	if alive.size() != 2 or count["kills"] != 0:
		_fail("%d petites et %d kills, attendu 2 et 0" % [alive.size(), count["kills"]])
	if level.enemies.size() != slots_before:
		_fail("une scission a changé le nombre de places")
	for piece in alive:
		if piece.health.current != level.config.enemy_health("gelee_petite") \
				or not level.grid.is_floor_v(piece.mover.nearest_cell()):
			_fail("petite gelée mal née")
		if piece.target_height >= big.target_height:
			_fail("la petite gelée n'est pas plus petite")
	for piece in alive:
		level._on_enemy_killed(level.enemies.find(piece))
		if level._respawns.has(level.enemies.find(piece)):
			_fail("une petite gelée ne doit pas réapparaître")
	if count["kills"] != 2:
		_fail("%d kills pour une gelée, attendu 2" % count["kills"])
	if not level._respawns.has(level.enemies.find(big)):
		_fail("la grande gelée doit revenir par son repaire")
	level.queue_free()
	await process_frame
	print("gelée : deux petites, deux kills, et la grande revient : OK")


func _test_spit() -> void:
	var level := _level_with(5, "vesse")
	var vesse := _first(level, "vesse")
	var cell := level.player.mover.nearest_cell()
	vesse.revive_at(cell)
	level._refresh_ai()
	vesse.player_field = level._player_field
	var normal := level.character.move_speed
	level._update_spores(FRAME, false)
	if vesse.can_spit():
		_fail("la vesse à portée devrait avoir craché")
	if level.player.mover.speed < normal:
		_fail("le mage est ralenti avant l'impact")
	# Le nuage tombe au bout de l'armement, et la vesse ne recrache pas tout de suite.
	level._update_spores(Bestiary.windup("vesse") + 0.05, false)
	if level.player.mover.speed >= normal or level._spore_nodes.is_empty():
		_fail("le mage devrait être ralenti dans le nuage, et le nuage visible")
	level._update_spores(SporeClouds.DURATION + 0.1, false)
	if level.player.mover.speed < normal:
		_fail("le mage devrait retrouver son allure")
	level.queue_free()
	await process_frame
	print("vesse : elle crache, le mage ralentit puis repart : OK")


## L'appel, sur le vrai niveau : le poursuivant lève le patrouilleur proche, qui montre son « ! ».
func _test_rally_in_level() -> void:
	var level := _level_with(2, "goblin")
	var mage := level.player.mover.nearest_cell()
	level._refresh_ai()
	var hunter: Enemy = null
	var patrol: Enemy = null
	for enemy in level.enemies:
		if enemy.flanks() and hunter == null:
			hunter = enemy
		elif enemy.flanks() and patrol == null:
			patrol = enemy
	var field := level._player_field
	var near := mage
	var mid := mage
	for i in field.size():
		var cell := Vector2i(i % level.grid.cols, i / level.grid.cols)
		if field[i] == 2:
			near = cell
		elif field[i] == 10:
			mid = cell
	hunter.revive_at(near)
	patrol.revive_at(mid)
	hunter.ai.state = EnemyAI.State.CHASE
	patrol.ai.state = EnemyAI.State.PATROL
	level._refresh_ai()
	if patrol.ai.state != EnemyAI.State.SEARCH or patrol._rallied_left <= 0.0:
		_fail("le patrouilleur à dix cases d'un poursuivant devrait répondre à l'appel")
	level.queue_free()
	await process_frame
	print("meute : l'appel lève le patrouilleur proche en jeu : OK")
