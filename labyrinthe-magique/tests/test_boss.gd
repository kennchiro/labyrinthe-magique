extends SceneTree

## Le boss de fin de chapitre, avec le vrai Level et le vrai BossFight.
##   godot --headless --path . --script res://tests/test_boss.gd
##
## Ses règles décident si on peut finir un chapitre : la porte doit rester fermée tant
## qu'il vit, s'ouvrir à sa mort, et une zone doit toujours pouvoir se fuir.

const LEVEL_SCENE := "res://scenes/level.tscn"
const MAGE_CELLS_PER_SECOND := 5.0
const MAX_BOSS_WALK := 2.6

var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_catalog()
	_test_only_finales()
	_test_patterns()
	_test_variety()
	_test_can_flee()
	await _test_fight()
	await _test_stray_zone()
	await _test_demo()

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


func _test_catalog() -> void:
	if BossCatalog.BY_STAGE.size() != LevelConfig.STAGE_COUNT:
		_fail("il faut un boss par chapitre")
	for stage in range(1, LevelConfig.STAGE_COUNT + 1):
		var id := BossCatalog.id_of(stage)
		if not Bestiary.has(id) or not bool(Bestiary.of(id).get("boss", false)):
			_fail("%s n'est pas un boss du bestiaire" % id)
		for strip in ["down", "arrival", "ranged_attack", "death", "warning", "impact", "fade"]:
			if not ResourceLoader.exists("res://assets/enemies/%s/%s.png" % [id, strip]):
				_fail("%s : %s.png manque" % [id, strip])
		for group in Bestiary.NEWCOMERS:
			if id in group:
				_fail("%s ne doit pas sortir d'un repaire" % id)
		# Le mage court à 5 cases/s : à 4 s il faut un temps de sortir d'une bande de 7.
		if BossCatalog.alert_time(stage) < 0.8:
			_fail("stage %d : alerte trop courte pour fuir" % stage)
	if not is_equal_approx(BossCatalog.alert_time(1), 1.6) \
			or not is_equal_approx(BossCatalog.alert_time(10), 0.9):
		_fail("les durées d'alerte ne sont plus celles des fiches")


func _test_only_finales() -> void:
	for level in LevelConfig.all_levels():
		if level.has_boss() != (level.episode == LevelConfig.EPISODES_PER_STAGE):
			_fail("stage %d épisode %d : boss mal placé" % [level.stage, level.episode])
	if not LevelConfig.demo(4).has_boss():
		_fail("le terrain d'essai a aussi son boss")


## Sa forme est bien tenue : praticable, sans doublon, et le mage toujours en cause.
func _test_patterns() -> void:
	for stage in range(1, LevelConfig.STAGE_COUNT + 1):
		var config := LevelConfig.for_stage(stage, 2)
		var grid := MazeGenerator.generate(config, 77)
		var fight := BossFight.new(stage, 5)
		var from: Vector2i = grid.gems[0]
		var boss_cell: Vector2i = grid.gems[-1]
		# Deux tours : la Chimère en change.
		for turn in 2:
			fight.mark(grid, from, boss_cell)
			if fight.cells.is_empty():
				_fail("stage %d : aucune case marquée" % stage)
			if fight.pattern != "cross" and not from in fight.cells:
				_fail("stage %d : la zone ne vise pas le mage" % stage)
			var seen := {}
			for cell in fight.cells:
				if not grid.is_floor_v(cell):
					_fail("stage %d : zone sur un mur en %s" % [stage, cell])
				if seen.has(cell):
					_fail("stage %d : case marquée deux fois" % stage)
				seen[cell] = true
				if fight.pattern in ["line", "wall", "wave"] and (
						(fight.is_vertical(from) and cell.x != from.x)
						or (not fight.is_vertical(from) and cell.y != from.y)):
					_fail("stage %d : la bande n'est pas droite" % stage)


## Dix façons différentes de combattre, et aucune ne rattrape le mage en marchant.
func _test_variety() -> void:
	var patterns := {}
	for stage in range(1, LevelConfig.STAGE_COUNT + 1):
		var boss := BossCatalog.of_stage(stage)
		if patterns.has(boss["pattern"]):
			_fail("%s attaque comme un autre boss" % boss["id"])
		patterns[boss["pattern"]] = true
		if float(boss["speed"]) > MAX_BOSS_WALK:
			_fail("%s marche trop vite" % boss["id"])
		if float(boss.get("charge_speed", 0.0)) >= MAGE_CELLS_PER_SECOND:
			_fail("%s charge plus vite que le mage" % boss["id"])
	# Le poids se lit dans le pas : un colosse se pose, le Yéti se ramasse avant de charger.
	var steps := BossGait.new(8)
	var moves := 0
	var rests := 0
	for i in 200:
		steps.tick(0.02, false)
		if steps.holding:
			rests += 1
		else:
			moves += 1
	if moves == 0 or rests == 0:
		_fail("l'Idole ne s'arrête jamais entre ses pas")
	var charge := BossGait.new(6)
	charge.start_charge(Vector2i.RIGHT)
	if not charge.holding or charge.charge_direction() != Vector2i.ZERO:
		_fail("le Yéti part sans prévenir")
	charge.tick(BossGait.CHARGE_WINDUP + 0.01, false)
	if charge.holding or charge.charge_direction() != Vector2i.RIGHT:
		_fail("le Yéti ne part pas")


## La règle de `BossFight` : une zone se fuit toujours, même du fond d'un cul-de-sac.
func _test_can_flee() -> void:
	for stage in range(1, LevelConfig.STAGE_COUNT + 1):
		var fight := BossFight.new(stage, stage)
		var reach := fight.alert_time * MAGE_CELLS_PER_SECOND
		for maze_seed in [11, 77]:
			var grid := MazeGenerator.generate(LevelConfig.for_stage(stage, 2), maze_seed)
			var boss_cell: Vector2i = grid.gems[-1]
			for y in grid.rows:
				for x in grid.cols:
					var from := Vector2i(x, y)
					if not grid.is_floor_v(from):
						continue
					fight.mark(grid, from, boss_cell)
					if not from in fight.cells:
						continue
					var way := _steps_out(grid, from, fight.cells)
					if float(way) > reach:
						_fail("stage %d : %d pas pour sortir de la zone en %s, %.1f possibles"
							% [stage, way, from, reach])
						return


func _steps_out(grid: MazeGrid, from: Vector2i, cells: Array[Vector2i]) -> int:
	var field := Pathfinder.distance_field(grid, [from])
	var best := 1 << 30
	for y in grid.rows:
		for x in grid.cols:
			var cell := Vector2i(x, y)
			var distance := Pathfinder.value_at(grid, field, cell)
			if distance > 0 and distance < best and not cell in cells:
				best = distance
	return best


func _level_ready(stage: int) -> Level:
	var level: Level = load(LEVEL_SCENE).instantiate()
	root.add_child(level)
	level.load_level(LevelConfig.for_stage(stage, 2), CharacterCatalog.shadow(), 77)
	level.debug_collect_all_gems()
	for lair in level.lairs:
		if lair.is_vulnerable():
			lair.health.take(Damage.new(99999, Element.Kind.SUPREME, "test"))
	return level


## En vraies secondes : sans affichage, une image ne dure pas 1/60 s.
func _wait(seconds: float) -> void:
	await create_timer(seconds).timeout


## De l'arrivée à la mort : la porte, la vague, le kill.
func _test_fight() -> void:
	var level := _level_ready(1)
	var killed := {"count": 0, "defeated": 0}
	level.enemy_killed.connect(func() -> void: killed["count"] += 1)
	level.boss_defeated.connect(func() -> void: killed["defeated"] += 1)
	if level.house_is_open():
		_fail("la porte s'ouvre sans avoir vu le boss")
	if not level.boss_is_due():
		_fail("le boss devrait être attendu, tout le reste est fait")
	var boss_index := level.enemies.size() - 1
	var boss: Enemy = level.enemies[boss_index]
	if not boss.dead:
		_fail("le boss ne doit pas chasser avant d'être appelé")
	level.summon_boss()
	if boss.health.is_alive():
		_fail("il est intouchable pendant son arrivée")
	await _wait(Level.BOSS_ARRIVAL_TIME + 0.2)
	if boss.dead or not boss.health.is_alive():
		_fail("le boss n'est pas arrivé")
	if not level.boss_is_fighting():
		_fail("le combat n'a pas commencé")
	if level.house_is_open():
		_fail("la porte s'ouvre avec le boss vivant")
	var left := boss.health.current
	boss.health.take(Damage.new(left, Element.Kind.SHADOW, "test"))
	level._on_enemy_killed(boss_index)
	if not level.house_is_open():
		_fail("la porte reste fermée après sa mort")
	if int(killed["count"]) != 1 or int(killed["defeated"]) != 1:
		_fail("sa mort doit compter une fois : %s" % killed)
	if not level._respawns.is_empty() and level.boss_guards_door():
		_fail("il revient après sa mort")
	await _wait(Level.BOSS_DEATH_TIME + Level.BOSS_DEATH_FADE + 0.2)
	if not boss.dead:
		_fail("le boss revient après sa mort")
	level.queue_free()
	await process_frame


## La zone blesse celui qui y reste, jamais celui qui en est sorti.
func _test_stray_zone() -> void:
	var level := _level_ready(2)
	var caught := {"count": 0}
	level.player_caught.connect(func() -> void: caught["count"] += 1)
	level.summon_boss()
	await _wait(Level.BOSS_ARRIVAL_TIME + 0.2)
	var boss: Enemy = level.enemies[level.enemies.size() - 1]
	var fight := level._boss_fight
	# Le boss loin, pour ne mesurer que la zone.
	boss.mover.speed = 0.0
	fight.mark(level.grid, level.player.mover.nearest_cell(), boss.mover.nearest_cell())
	level._on_boss_alert(boss)
	var away := _cell_outside(level, fight.cells)
	level.player.mover.teleport_to(away)
	fight.struck = fight.cells
	level._on_boss_strike(boss)
	if int(caught["count"]) != 0:
		_fail("la zone blesse un mage qui en est sorti")
	level.player.mover.teleport_to(fight.cells[0])
	level._on_boss_strike(boss)
	if int(caught["count"]) != 1:
		_fail("la zone ne blesse pas le mage qui y reste")
	level.queue_free()
	await process_frame


## En démo, le vrai boss, sur appel, sans gemme, autant de fois qu'on veut.
func _test_demo() -> void:
	var level: Level = load(LEVEL_SCENE).instantiate()
	root.add_child(level)
	level.load_level(LevelConfig.demo(4), CharacterCatalog.shadow(), 77)
	var boss: Enemy = level.enemies[level.enemies.size() - 1]
	var real := LevelConfig.for_stage(4, LevelConfig.EPISODES_PER_STAGE)
	if boss.health.maximum != real.enemy_health(boss.species):
		_fail("démo : ce n'est pas le vrai boss, %d PV" % boss.health.maximum)
	if level.boss_guards_door() or level.boss_is_due():
		_fail("démo : le boss ne doit rien garder avant d'être appelé")
	level.debug_collect_all_gems()
	if not level.house_is_open():
		_fail("démo : la gemme ne rouvre pas la porte")
	for round_number in 2:
		if not level.boss_can_be_called():
			_fail("démo : on ne peut pas l'appeler, tour %d" % round_number)
		level.call_boss()
		if level.boss_can_be_called() or level.house_is_open():
			_fail("démo : la porte reste ouverte ou il arrive deux fois, tour %d" % round_number)
		await _wait(Level.BOSS_ARRIVAL_TIME + 0.2)
		if not level.boss_is_fighting() or boss.dead:
			_fail("démo : le boss n'est pas arrivé, tour %d" % round_number)
		level.debug_kill_boss()
		if level.boss_can_be_called():
			_fail("démo : on le rappelle pendant sa chute, tour %d" % round_number)
		await _wait(Level.BOSS_DEATH_TIME + Level.BOSS_DEATH_FADE + 0.2)
		if not level.house_is_open():
			_fail("démo : la porte reste fermée après sa mort, tour %d" % round_number)
	level.queue_free()
	await process_frame


func _cell_outside(level: Level, cells: Array[Vector2i]) -> Vector2i:
	for y in level.grid.rows:
		for x in level.grid.cols:
			var cell := Vector2i(x, y)
			if level.grid.is_floor_v(cell) and not cell in cells:
				return cell
	return Vector2i.ZERO
