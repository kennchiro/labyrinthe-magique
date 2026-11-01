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

## Aveuglé : il erre sans chercher le mage, et ne peut pas frapper.
var blind_left := 0.0
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
	if blind_left > 0.0:
		blind_left -= delta
		state = State.PATROL
		_search_field = PackedInt32Array()
		return _patrol(grid, from, current_direction)
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


## Le Rat : il court vers une gemme, puis fuit le mage avec. L'état reste SEARCH : sa teinte
## de poursuite dirait qu'il menace, et il ne frappe jamais.
func decide_thief(grid: MazeGrid, from: Vector2i, current_direction: Vector2i,
		gem_field: PackedInt32Array, player_field: PackedInt32Array, carrying: bool,
		delta: float) -> Vector2i:
	if blind_left > 0.0:
		blind_left -= delta
		state = State.PATROL
		return _patrol(grid, from, current_direction)
	state = State.SEARCH
	var step := _flee(grid, from, player_field) if carrying \
		else Pathfinder.step_toward(grid, gem_field, from)
	if step != Vector2i.ZERO or carrying:
		return step
	state = State.PATROL
	return _patrol(grid, from, current_direction)


## La case voisine la plus loin du mage, ou l'arrêt s'il n'y a pas mieux. Acculé dans un
## cul-de-sac, il attend : c'est là qu'on le rattrape.
func _flee(grid: MazeGrid, from: Vector2i, player_field: PackedInt32Array) -> Vector2i:
	var best := Pathfinder.value_at(grid, player_field, from)
	var best_direction := Vector2i.ZERO
	for d in MazeGrid.NEIGHBORS:
		var value := Pathfinder.value_at(grid, player_field, from + d)
		if value > best:
			best = value
			best_direction = d
	return best_direction


## La Raie : à portée, elle va droit sur le mage à VOL D'OISEAU, murs compris. Hors de
## portée elle patrouille comme les autres, après être sortie du mur où elle se trouve.
func decide_phasing(grid: MazeGrid, from: Vector2i, current_direction: Vector2i,
		player_field: PackedInt32Array, player_cell: Vector2i, reach: float,
		delta: float) -> Vector2i:
	var inside := not grid.is_floor_v(from)
	if blind_left > 0.0 and not inside:
		return decide(grid, from, current_direction, player_field, delta)
	var gap := player_cell - from
	if player_cell.x >= 0 and (inside or Vector2(gap).length() <= reach):
		blind_left = maxf(0.0, blind_left - delta)
		state = State.CHASE
		if absi(gap.x) >= absi(gap.y):
			return Vector2i(signi(gap.x), 0)
		return Vector2i(0, signi(gap.y))
	return decide(grid, from, current_direction, player_field, delta)


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
