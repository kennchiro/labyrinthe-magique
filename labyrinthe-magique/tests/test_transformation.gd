extends SceneTree

var failures: Array[String] = []
func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)

func _init() -> void:
	var state := Transformation.new()
	check(not state.begin(29), "pas de transformation avant 30")
	check(state.begin(30) and not state.begin(30), "une seule charge")
	state.update(0.8)
	check(state.state == Transformation.State.PRISM and is_equal_approx(state.left, 20.0), "20 secondes après la charge")
	for i in 20:
		state.kill()
	check(state.left == 30.0, "kills plafonnés à 30 secondes")
	state.hit(3)
	check(state.left == 27.0, "un coup retire trois secondes")
	state.hit(1)
	check(state.state == Transformation.State.EXHAUSTED, "bris à 1 PV")
	state.update(3.0)
	check(state.state == Transformation.State.NORMAL, "fin de l’épuisement")
	state.begin(30)
	state.update(21.0)
	check(state.state == Transformation.State.EXHAUSTED, "durée écoulée, même en grand pas de temps")
	var saved := HeroProgress.new()
	saved.xp = HeroProgress.threshold(30)
	var grid := MazeGenerator.generate(LevelConfig.for_stage(1), 4242)
	var stats := HeroCatalog.at_level(30)
	var health := Health.new(4)
	var combat := CombatSystem.new(grid, stats, health)
	var runtime := HeroRuntime.new(saved, combat)
	var ctx := CombatContext.new(grid)
	ctx.player_cell = grid.player_spawn
	ctx.player_field = Pathfinder.distance_field(grid, [ctx.player_cell] as Array[Vector2i])
	var attack := combat.stats.escape
	combat.use(attack, ctx)
	var cooldown := combat.cooldown_left(attack)
	runtime.charge = HeroRuntime.TRANSFORM_KILLS
	check(runtime.transform(), "le bouton dédié lance la transformation")
	runtime.update(0.8)
	combat.update(0.8, ctx)
	check(combat.stats.hero_form == 3 and health.current == 4, "PV conservés en Prisme")
	check(combat.health == health, "la santé n’est jamais remplacée")
	check(health.plates == 2, "plaque de base et plaque d’aura")
	health.plates = 0
	health.take(Damage.new(99, Element.Kind.SHADOW, "test"))
	check(health.current == 1 and health.is_alive(), "le coup fatal brise la forme")
	check(runtime.transformation.state == Transformation.State.EXHAUSTED and health.minimum_current == 0, "retour normal sans protection résiduelle")
	check(combat.stats.hero_form == 2 and combat.stats.move_speed < 5.4, "retour Ascendant ralenti")
	check(combat.cooldown_left(attack) <= cooldown, "les recharges ne repartent pas à zéro")
	runtime.update(3.0)
	check(is_equal_approx(combat.stats.move_speed, 5.4), "vitesse restaurée")
	var beginner := HeroProgress.new()
	var hp := Health.new(3)
	var system := CombatSystem.new(grid, HeroCatalog.at_level(1), hp)
	var run := HeroRuntime.new(beginner, system)
	run.gain(900)
	check(hp.maximum == 4 and hp.current == 4 and system.stats.hero_form == 1, "évolution et soin en combat")
	var arena := MazeGrid.new(9, 7)
	for y in arena.rows:
		for x in arena.cols:
			arena.set_cell(x, y, MazeGrid.Cell.FLOOR)
	arena.set_cell(4, 3, MazeGrid.Cell.WALL)
	var fighter := HeroCatalog.at_level(30, true)
	var system2 := CombatSystem.new(arena, fighter, Health.new(4))
	var snapshot := CombatContext.new(arena)
	snapshot.player_cell = Vector2i(2, 3)
	snapshot.player_facing = Vector2i.RIGHT
	snapshot.player_field = Pathfinder.distance_field(arena, [snapshot.player_cell] as Array[Vector2i])
	snapshot.enemy_cells = [Vector2i(6, 3)]
	snapshot.enemy_facings = [Vector2i.RIGHT]
	snapshot.enemy_health = [Health.new(500)]
	check(system2.use(fighter.ultimate, snapshot), "Prisme ultime lancé")
	check(snapshot.enemy_health[0].current == 300, "Prisme ultime à travers la haie")
	check(system2.use(fighter.escape, snapshot) and snapshot.player_cell == Vector2i(5, 3), "Transmission derrière la cible")
	var remaining := snapshot.enemy_health[0].current
	check(system2.use(fighter.abilities[0], snapshot), "Comète avec une cible")
	check(snapshot.player_cell == Vector2i(6, 3) and snapshot.enemy_health[0].current < remaining, "Comète : déplacement et explosion à l’arrivée")
	var novice := HeroCatalog.at_level(1)
	var melee := CombatSystem.new(arena, novice, Health.new(3))
	snapshot.player_cell = Vector2i(5, 3)
	snapshot.player_facing = Vector2i.LEFT
	snapshot.player_field = Pathfinder.distance_field(arena, [snapshot.player_cell] as Array[Vector2i])
	remaining = snapshot.enemy_health[0].current
	check(melee.find_target(novice.attack, snapshot) == 0 and melee.use(novice.attack, snapshot), "attaque au contact ciblée")
	check(snapshot.enemy_health[0].current == remaining - novice.attack.damage, "l’épée se tourne vers sa cible à portée")
	# Le sort 2 DÉPLACE Aël dans toutes ses formes, et frappe ce qu'il traverse (demande du joueur, 2026-11-06).
	var open_field := MazeGrid.new(13, 5)
	for y in open_field.rows:
		for x in open_field.cols:
			open_field.set_cell(x, y, MazeGrid.Cell.FLOOR)
	for form_level in [1, 10, 20, 30]:
		var kit := HeroCatalog.at_level(form_level, form_level >= 30)
		var dasher := CombatSystem.new(open_field, kit, Health.new(4))
		var lane := CombatContext.new(open_field)
		lane.player_cell = Vector2i(2, 2)
		lane.player_facing = Vector2i.RIGHT
		lane.player_field = Pathfinder.distance_field(open_field, [lane.player_cell] as Array[Vector2i])
		lane.enemy_cells = [Vector2i(4, 2)]
		lane.enemy_facings = [Vector2i.LEFT]
		lane.enemy_health = [Health.new(500)]
		var landed := {"cell": lane.player_cell}
		dasher.blink_performed.connect(func(_from: Vector2i, to: Vector2i) -> void: landed["cell"] = to)
		check(dasher.use(kit.abilities[1], lane), "le sort 2 part, forme %d" % kit.hero_form)
		check(landed["cell"] != Vector2i(2, 2), "le sort 2 déplace Aël, forme %d" % kit.hero_form)
		check(lane.enemy_health[0].current < 500, "le sort 2 frappe en chemin, forme %d" % kit.hero_form)
	if failures.is_empty():
		runtime.dispose()
		run.dispose()
		print("TOUS LES TESTS PASSENT — transformation d’Aël")
	else:
		for message in failures:
			push_error(message)
	quit(0 if failures.is_empty() else 1)
