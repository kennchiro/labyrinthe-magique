class_name EnemyAI
extends RefCounted

## IA de poursuite à trois états. Volontairement simple : la tension du jeu doit
## venir du labyrinthe et des portails, pas d'une IA impossible à lire.
##
##   PATROL — marche au hasard, sans jamais faire demi-tour (un ennemi qui
##            hésite n'est pas menaçant). Ne redécide qu'en entrant dans une
##            case, sinon il vibrerait sur place.
##   CHASE  — descend le champ de distances du joueur : chemin optimal. C'est
##            Enemy qui refuse le DERNIER pas, celui qui monterait sur le mage.
##   SEARCH — continue vers la DERNIÈRE position connue, en descendant une copie
##            figée du champ. C'est ce qui donne l'impression que l'ennemi
##            "cherche" alors qu'il ne fait que finir son ancien trajet.
##
## Aucune dépendance au moteur de scène : testable en headless.

enum State { PATROL, CHASE, SEARCH }

var state: State = State.PATROL
## Rayon de détection en distance de CHEMIN, pas à vol d'oiseau : un ennemi
## séparé par un mur ne doit pas repérer le joueur collé de l'autre côté.
var detection_radius: int = 8
var search_duration: float = 3.0

var _search_field := PackedInt32Array()
var _search_timer := 0.0
var _patrol_direction := Vector2i.ZERO
var _patrol_decided_at := Vector2i(-1, -1)
var _rng := RandomNumberGenerator.new()


func _init(p_detection_radius: int, rng_seed: int = 0) -> void:
	detection_radius = p_detection_radius
	if rng_seed == 0:
		_rng.randomize()
	else:
		_rng.seed = rng_seed


func decide(grid: MazeGrid, from: Vector2i, current_direction: Vector2i,
		player_field: PackedInt32Array, delta: float) -> Vector2i:
	var distance_to_player := Pathfinder.value_at(grid, player_field, from)
	var detected := distance_to_player >= 0 and distance_to_player <= detection_radius

	if detected:
		state = State.CHASE
		_search_field = player_field
		_search_timer = search_duration
	elif state == State.CHASE:
		state = State.SEARCH

	if state == State.SEARCH:
		_search_timer -= delta
		var remaining := Pathfinder.value_at(grid, _search_field, from)
		if _search_timer <= 0.0 or remaining <= 0:
			state = State.PATROL
			_search_field = PackedInt32Array()

	match state:
		State.CHASE:
			var chase_step := Pathfinder.step_toward(grid, player_field, from)
			if chase_step != Vector2i.ZERO:
				return chase_step
		State.SEARCH:
			var search_step := Pathfinder.step_toward(grid, _search_field, from)
			if search_step != Vector2i.ZERO:
				return search_step
			state = State.PATROL

	return _patrol(grid, from, current_direction)


func _patrol(grid: MazeGrid, from: Vector2i, current_direction: Vector2i) -> Vector2i:
	var needs_new_direction := (
		from != _patrol_decided_at
		or _patrol_direction == Vector2i.ZERO
		or not grid.is_floor_v(from + _patrol_direction)
	)
	if not needs_new_direction:
		return _patrol_direction

	_patrol_decided_at = from
	var options: Array[Vector2i] = []
	for d in MazeGrid.NEIGHBORS:
		if d == -current_direction:
			continue
		if grid.is_floor_v(from + d):
			options.append(d)

	if options.is_empty():
		# Cul-de-sac : le demi-tour est le seul choix possible.
		_patrol_direction = -current_direction
	else:
		_patrol_direction = options[_rng.randi_range(0, options.size() - 1)]
	return _patrol_direction
