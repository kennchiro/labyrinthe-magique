extends SceneTree

## Preuve automatisée que le joueur ne peut PAS traverser un mur.
##   godot --headless --path . --script res://tests/test_grid_mover.gd
##
## Plutôt que de vérifier les collisions à la main dans le jeu, on simule des
## centaines de milliers de frames de déplacement erratique et on vérifie à
## chaque frame que l'invariant tient. GridMover n'ayant aucune dépendance au
## moteur de scène, tout ça tourne en headless en une seconde.

var _failures: Array[String] = []


func _init() -> void:
	_test_random_walk()
	_test_low_framerate()
	_test_wall_blocks()
	_test_reversal_is_continuous()
	_test_stops_centered()

	print("")
	if _failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT")
	else:
		print("❌  %d ÉCHEC(S) :" % _failures.size())
		for f in _failures:
			print("   - ", f)
	quit(0 if _failures.is_empty() else 1)


func _fail(msg: String) -> void:
	if _failures.size() < 15:
		_failures.append(msg)


## Invariant central : les deux cases interpolées sont praticables et adjacentes.
## S'il est vrai à chaque frame, aucun mur ne peut être franchi, quel que soit
## le chemin parcouru.
func _check(mover: GridMover, tag: String) -> bool:
	if not mover.grid.is_floor_v(mover.cell):
		_fail("%s : `cell` %s est un mur" % [tag, mover.cell])
		return false
	if not mover.grid.is_floor_v(mover.next_cell):
		_fail("%s : `next_cell` %s est un mur" % [tag, mover.next_cell])
		return false
	var step: Vector2i = mover.next_cell - mover.cell
	if step != Vector2i.ZERO and not MazeGrid.NEIGHBORS.has(step):
		_fail("%s : saut de %s entre deux cases non adjacentes" % [tag, step])
		return false
	if mover.progress < 0.0 or mover.progress > 1.0:
		_fail("%s : progress hors bornes (%f)" % [tag, mover.progress])
		return false
	return true


# --- 1. Marche erratique : 300 000 frames à 60 fps ------------------------------

func _test_random_walk() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var frames := 0
	var cells_visited := {}

	for run in 30:
		var grid := MazeGenerator.generate(LevelConfig.for_stage(2), 500 + run)
		var mover := GridMover.new(grid, grid.player_spawn, 5.0)
		for i in 10000:
			# Changement de direction très fréquent : c'est le pire cas,
			# celui qui provoquerait un passage à travers un mur s'il existait.
			if rng.randf() < 0.12:
				mover.desired_direction = MazeGrid.NEIGHBORS[rng.randi_range(0, 3)]
			mover.update(1.0 / 60.0)
			frames += 1
			cells_visited[mover.cell] = true
			if not _check(mover, "marche erratique run=%d frame=%d" % [run, i]):
				return
	print("marche erratique : %d frames simulées, %d cases visitées — aucun mur traversé" % [frames, cells_visited.size()])


# --- 2. Très basse fréquence d'images -----------------------------------------
# À 2 fps et 5 cases/s, on avance de 2,5 cases par frame. Sans la boucle `while`
# dans update(), le personnage sauterait par-dessus les murs.

func _test_low_framerate() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var grid := MazeGenerator.generate(LevelConfig.for_stage(1), 77)
	for dt in [0.5, 0.25, 0.1]:
		var mover := GridMover.new(grid, grid.player_spawn, 5.0)
		for i in 3000:
			if rng.randf() < 0.3:
				mover.desired_direction = MazeGrid.NEIGHBORS[rng.randi_range(0, 3)]
			mover.update(dt)
			if not _check(mover, "dt=%.2fs frame=%d" % [dt, i]):
				return
	print("basse fréquence d'images (2 / 4 / 10 fps) : aucun mur traversé")


# --- 3. Un mur bloque bien ------------------------------------------------------

func _test_wall_blocks() -> void:
	var grid := MazeGenerator.generate(LevelConfig.for_stage(1), 123)
	var start := grid.player_spawn
	var blocked := Vector2i.ZERO
	for d in MazeGrid.NEIGHBORS:
		if grid.is_wall(start.x + d.x, start.y + d.y):
			blocked = d
			break
	if blocked == Vector2i.ZERO:
		print("mur bloquant : cas non rencontré sur cette graine (ignoré)")
		return

	var mover := GridMover.new(grid, start, 5.0)
	mover.desired_direction = blocked
	for i in 120:
		mover.update(1.0 / 60.0)
	if mover.cell != start or mover.is_moving() or mover.progress != 0.0:
		_fail("mur bloquant : le joueur a bougé vers %s alors que c'est un mur" % blocked)
	else:
		print("mur bloquant : 2 s de poussée contre un mur, aucun déplacement")


# --- 4. Le demi-tour ne téléporte pas ------------------------------------------

func _test_reversal_is_continuous() -> void:
	var grid := MazeGenerator.generate(LevelConfig.for_stage(1), 321)
	var mover := GridMover.new(grid, grid.player_spawn, 5.0)

	# On démarre dans la première direction libre.
	for d in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(grid.player_spawn + d):
			mover.desired_direction = d
			break
	mover.update(1.0 / 60.0)
	for i in 5:
		mover.update(1.0 / 60.0)
	if not mover.is_moving():
		print("demi-tour : cas non rencontré sur cette graine (ignoré)")
		return

	var before := mover.grid_position()
	mover.desired_direction = -mover.direction
	mover.update(0.0)
	var after := mover.grid_position()
	if before.distance_to(after) > 0.0001:
		_fail("demi-tour : téléportation de %.4f case (attendu 0)" % before.distance_to(after))
	else:
		print("demi-tour instantané : position continue (écart %.6f case)" % before.distance_to(after))


# --- 5. L'arrêt se fait pile au centre d'une case ------------------------------

func _test_stops_centered() -> void:
	var grid := MazeGenerator.generate(LevelConfig.for_stage(1), 999)
	var mover := GridMover.new(grid, grid.player_spawn, 5.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in 5000:
		if rng.randf() < 0.15:
			mover.desired_direction = MazeGrid.NEIGHBORS[rng.randi_range(0, 3)]
		mover.update(1.0 / 60.0)
		if not mover.is_moving():
			var pos := mover.grid_position()
			if pos != Vector2(mover.cell):
				_fail("arrêt hors centre : %s au lieu de %s" % [pos, mover.cell])
				return
	print("arrêt : toujours exactement au centre d'une case")
