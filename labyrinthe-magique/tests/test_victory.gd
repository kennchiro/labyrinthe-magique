extends SceneTree

## Prouve que TOUT niveau généré est gagnable, et mesure combien de temps met
## un joueur parfait pour le finir.
##   godot --headless --path . --script res://tests/test_victory.gd
##
## Depuis que l'objectif est la collecte, « gagnable » ne veut plus dire
## « la maison est atteignable » : il faut RAMASSER TOUTES LES GEMMES, puis
## rentrer. Le test simule donc une tournée complète — gemme la plus proche,
## puis la suivante, puis la maison — avec le vrai GridMover du jeu.
##
## La tournée est gloutonne, pas optimale : trouver le meilleur ordre serait un
## problème de voyageur de commerce, et ce n'est pas ce qu'on mesure. Un joueur
## humain joue glouton lui aussi. Le temps obtenu reste un PLANCHER : il ne se
## trompe jamais de chemin et ne croise aucun ennemi.

const ITERATIONS := 100
const DT := 1.0 / 60.0
const MAX_FRAMES := 60000
## Même rayon de ramassage que le jeu (Level.PICKUP_DISTANCE).
const PICKUP_DISTANCE := 0.7

var _failures: Array[String] = []


func _init() -> void:
	for config in LevelConfig.all_levels():
		_test_level(config)

	print("")
	if _failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT")
	else:
		print("❌  %d ÉCHEC(S) :" % _failures.size())
		for f in _failures:
			print("   - ", f)
	quit(0 if _failures.is_empty() else 1)


func _test_level(config: LevelConfig) -> void:
	var fastest := MAX_FRAMES
	var slowest := 0
	var total := 0
	var solved := 0

	for i in ITERATIONS:
		var rng_seed := 2000 + i
		var grid := MazeGenerator.generate(config, rng_seed)
		var frames := _run(grid)

		if frames < 0:
			_failures.append("%s seed=%d : tournée JAMAIS terminée (niveau ingagnable)" % [
				config.level_name, rng_seed])
			continue

		solved += 1
		total += frames
		fastest = mini(fastest, frames)
		slowest = maxi(slowest, frames)

	if solved == 0:
		return
	print("%s : %d/%d gagnables · %d gemmes · run parfait %.1f s en moyenne (de %.1f s à %.1f s)" % [
		config.level_name, solved, ITERATIONS, config.gem_count,
		float(total) / float(solved) * DT, fastest * DT, slowest * DT,
	])


## Nombre de frames pour tout ramasser et rentrer, ou -1 si la tournée bloque.
##
## Un champ de distances par gemme, calculé UNE FOIS pour le niveau. Le choix de
## la prochaine étape se relit ensuite dans ces tableaux, et n'est refait qu'au
## moment où une gemme tombe — pas à chaque frame. Recalculer les BFS à chaque
## frame rendait ce test 400 fois plus lent que le reste de la suite.
func _run(grid: MazeGrid) -> int:
	var mover := GridMover.new(grid, grid.player_spawn, 5.0)
	var remaining := grid.gems.duplicate()
	var fields := {}
	for gem in grid.gems:
		fields[gem] = Pathfinder.distance_field(grid, [gem] as Array[Vector2i])
	var house_field := Pathfinder.distance_field(grid, [grid.house_center] as Array[Vector2i])

	var field: PackedInt32Array = _pick_field(grid, fields, house_field, remaining, mover.cell)

	for frame in MAX_FRAMES:
		var step := Pathfinder.step_toward(grid, field, mover.decision_cell())
		mover.desired_direction = step
		if step == Vector2i.ZERO and not mover.is_moving():
			# Immobile et sans direction : soit on est arrivé, soit le gradient
			# est cassé — et un gradient cassé sur un BFS complet est un bug.
			if remaining.is_empty():
				return frame if grid.is_house(mover.cell) else -1
			if not _collect(remaining, mover):
				return -1
			field = _pick_field(grid, fields, house_field, remaining, mover.cell)
			continue

		mover.update(DT)
		if _collect(remaining, mover):
			field = _pick_field(grid, fields, house_field, remaining, mover.cell)

		if remaining.is_empty() and grid.is_house(mover.cell):
			return frame
	return -1


## Champ vers la gemme la plus proche, ou vers la maison si le sac est plein.
## C'est exactement le choix que propose la boussole du jeu.
func _pick_field(grid: MazeGrid, fields: Dictionary, house_field: PackedInt32Array,
		remaining: Array[Vector2i], from: Vector2i) -> PackedInt32Array:
	if remaining.is_empty():
		return house_field
	var best: PackedInt32Array = fields[remaining[0]]
	var best_distance := 1 << 30
	for gem in remaining:
		var field: PackedInt32Array = fields[gem]
		var distance := Pathfinder.value_at(grid, field, from)
		if distance >= 0 and distance < best_distance:
			best_distance = distance
			best = field
	return best


func _collect(remaining: Array[Vector2i], mover: GridMover) -> bool:
	var position := mover.grid_position()
	for i in range(remaining.size() - 1, -1, -1):
		if Vector2(remaining[i]).distance_to(position) < PICKUP_DISTANCE:
			remaining.remove_at(i)
			return true
	return false
