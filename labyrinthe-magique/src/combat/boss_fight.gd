class_name BossFight
extends RefCounted

## L'attaque de loin d'un boss : quand elle part, où elle tombe, et quand elle frappe.
##
## Le coup au contact passe par `MeleeSwing`, comme pour tout ennemi. Ceci ne décide que
## de la zone au sol. Aucun `Node` ici, c'est la règle d'architecture n° 1.
##
## Une forme par boss, pour qu'on ne fuie pas deux boss de la même façon :
##   `trail`    des racines courent sur le chemin du boss au mage, une case après l'autre
##   `line`     la foudre tombe d'un coup sur tout le couloir du mage
##   `burrow`   il s'enfouit et ressort sur une case marquée près du mage
##   `wave`     une vague déferle le long du couloir du mage et le repousse
##   `star`     des pointes en étoile autour du mage
##   `rain`     des blocs tombent autour du mage, chacun à son heure
##   `wall`     un mur reste debout dans le couloir du mage et blesse qui le traverse
##   `cross`    une onde part du boss dans ses quatre directions
##   `pursuit`  trois cercles de suite, chacun là où le mage se trouve alors
##   `combo`    `rain` puis `star`, chacun son tour
##
## Sauf `cross`, le boss regarde le mage au moment de marquer, jamais où il sera : quitter
## la zone pendant l'alerte suffit toujours. Une zone qu'on ne peut pas fuir serait une taxe.

const FIRST_WAIT := 2.0
## À quelle distance du mage tombent les cases marquées en plus de la sienne. Assez près
## pour gêner sa fuite, sans jamais boucher les deux côtés d'un couloir à la case près.
const MARK_NEAR := 2
const MARK_FAR := 5
## L'écart entre deux cases d'une attaque qui court, en secondes.
const TRAIL_STEP := 0.16
const WAVE_STEP := 0.12
const CROSS_STEP := 0.1
const RAIN_SPREAD := 0.9
const STAR_ARM := 2
const WALL_LINGER := 3.5
const PURSUIT_VOLLEYS := 3
const PURSUIT_GAP := 0.8

var pattern: String
var count: int
var alert_time: float
var every: float
## Les cases de l'attaque en cours.
var cells: Array[Vector2i] = []
## Les cases qui viennent de frapper, à cette image.
var struck: Array[Vector2i] = []
## Le temps qu'un coup reste au sol, et le sens où il pousse le mage.
var linger := 0.0
var push := Vector2i.ZERO

var _delays := {}
var _verticals := {}
var _wait := FIRST_WAIT
var _volleys_left := 0
var _combo_turn := 0
## Chaque coup à venir : { "cell", "left" }.
var _pending: Array[Dictionary] = []
var _walls := {}
var _rng := RandomNumberGenerator.new()


func _init(stage: int, rng_seed: int = 0) -> void:
	var boss := BossCatalog.of_stage(stage)
	pattern = str(boss["pattern"])
	count = int(boss["count"])
	alert_time = BossCatalog.alert_time(stage)
	every = BossCatalog.interval(stage)
	linger = WALL_LINGER if pattern == "wall" else 0.0
	_rng.seed = rng_seed


func is_alerting() -> bool:
	return not _pending.is_empty()


## Les bandes se mettent bout à bout, les ronds se posent sur leur case : c'est la planche
## de chaque boss qui le dit, dessinée pour l'une ou pour l'autre.
func uses_bands() -> bool:
	return pattern in ["line", "wave", "wall", "cross"]


func is_vertical(cell: Vector2i) -> bool:
	return bool(_verticals.get(cell, false))


func delay_of(cell: Vector2i) -> float:
	return float(_delays.get(cell, 0.0))


func longest_delay() -> float:
	var longest := 0.0
	for cell in cells:
		longest = maxf(longest, delay_of(cell))
	return longest


## Le mur de ronces est-il debout sur cette case ?
func on_wall(cell: Vector2i) -> bool:
	return _walls.has(cell)


## Avance le temps, et dit si une attaque vient d'être marquée. Les coups qui tombent à
## cette image sont dans `struck`. `can_start` est faux quand le boss est ébranlé, aveuglé
## ou lancé : il finit ce qu'il a commencé, il n'en commence pas d'autre.
func tick(delta: float, grid: MazeGrid, player_cell: Vector2i, boss_cell: Vector2i,
		can_start: bool) -> bool:
	struck.clear()
	_tick_pending(delta)
	for cell in _walls.keys():
		_walls[cell] -= delta
		if _walls[cell] <= 0.0:
			_walls.erase(cell)
	_wait -= delta
	if _wait > 0.0 or not can_start or (is_alerting() and _volleys_left <= 0):
		return false
	mark(grid, player_cell, boss_cell)
	for cell in cells:
		_pending.append({"cell": cell, "left": alert_time + delay_of(cell)})
	if _volleys_left <= 0 and pattern == "pursuit":
		_volleys_left = PURSUIT_VOLLEYS
	_volleys_left = maxi(0, _volleys_left - 1)
	_wait = PURSUIT_GAP if _volleys_left > 0 else every + longest_delay()
	return true


func _tick_pending(delta: float) -> void:
	for index in range(_pending.size() - 1, -1, -1):
		_pending[index]["left"] -= delta
		if _pending[index]["left"] > 0.0:
			continue
		var cell: Vector2i = _pending[index]["cell"]
		struck.append(cell)
		if linger > 0.0:
			_walls[cell] = linger
		_pending.remove_at(index)


## Choisit les cases. Séparé de `tick` pour les tests.
func mark(grid: MazeGrid, player_cell: Vector2i, boss_cell: Vector2i) -> void:
	_delays.clear()
	_verticals.clear()
	push = Vector2i.ZERO
	cells = []
	var shape := pattern
	if pattern == "combo":
		shape = "rain" if _combo_turn % 2 == 0 else "star"
		_combo_turn += 1
	match shape:
		"trail":
			_mark_trail(grid, player_cell, boss_cell)
		"line", "wall":
			_mark_line(grid, player_cell)
		"wave":
			_mark_wave(grid, player_cell, boss_cell)
		"star":
			_mark_star(grid, player_cell, STAR_ARM)
		"rain":
			_mark_around(grid, player_cell, MARK_NEAR, MARK_FAR)
			for cell in cells:
				_delays[cell] = _rng.randf_range(0.0, RAIN_SPREAD)
		"cross":
			_mark_cross(grid, boss_cell)
		_:
			# `burrow` et `pursuit` : une sortie ou un deuxième cercle, tout près.
			_mark_around(grid, player_cell, MARK_NEAR, MARK_NEAR)


## Là où le boss ressort, s'il s'enfouit. Jamais sur le mage : deux personnages sur une
## case, on ne lit plus rien.
func burrow_exit(player_cell: Vector2i) -> Vector2i:
	for cell in cells:
		if cell != player_cell:
			return cell
	return Vector2i(-1, -1)


func _mark_around(grid: MazeGrid, player_cell: Vector2i, nearest: int, farthest: int) -> void:
	cells = [player_cell]
	var field := Pathfinder.distance_field(grid, [player_cell])
	var near: Array[Vector2i] = []
	for y in grid.rows:
		for x in grid.cols:
			var cell := Vector2i(x, y)
			var distance := Pathfinder.value_at(grid, field, cell)
			if distance >= nearest and distance <= farthest and not grid.is_house(cell):
				near.append(cell)
	while cells.size() < count and not near.is_empty():
		cells.append(near.pop_at(_rng.randi_range(0, near.size() - 1)))


## Du boss vers le mage, sur le vrai chemin : les racines arrivent, on les voit venir.
func _mark_trail(grid: MazeGrid, player_cell: Vector2i, boss_cell: Vector2i) -> void:
	var field := Pathfinder.distance_field(grid, [player_cell])
	var path: Array[Vector2i] = []
	var cell := boss_cell
	while cell != player_cell and path.size() < grid.cols * grid.rows:
		var step := Pathfinder.step_toward(grid, field, cell)
		if step == Vector2i.ZERO:
			break
		cell += step
		path.append(cell)
	if path.is_empty() or path[-1] != player_cell:
		path = [player_cell]
	cells.assign(path.slice(maxi(0, path.size() - count)))
	for index in cells.size():
		_delays[cells[index]] = TRAIL_STEP * index


func _mark_line(grid: MazeGrid, player_cell: Vector2i) -> void:
	var across := _run(grid, player_cell, Vector2i.RIGHT)
	var down := _run(grid, player_cell, Vector2i.DOWN)
	var vertical := down.size() > across.size()
	cells = down if vertical else across
	for cell in cells:
		_verticals[cell] = vertical


## La ligne du mage, parcourue depuis le côté du boss : elle l'emporte en s'éloignant de lui.
func _mark_wave(grid: MazeGrid, player_cell: Vector2i, boss_cell: Vector2i) -> void:
	_mark_line(grid, player_cell)
	var vertical := is_vertical(player_cell)
	var side := boss_cell.y - player_cell.y if vertical else boss_cell.x - player_cell.x
	push = (Vector2i.DOWN if vertical else Vector2i.RIGHT) * (-1 if side > 0 else 1)
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return Vector2(a).dot(Vector2(push)) < Vector2(b).dot(Vector2(push)))
	for index in cells.size():
		_delays[cells[index]] = WAVE_STEP * index


## Quelques cases de chaque côté du mage, tant que le couloir continue.
func _mark_star(grid: MazeGrid, player_cell: Vector2i, arm: int) -> void:
	cells = [player_cell]
	for direction in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		var cell: Vector2i = player_cell + direction
		for i in arm:
			if not grid.is_floor_v(cell):
				break
			cells.append(cell)
			cell += direction


## Depuis le boss et non depuis le mage : on s'en protège en quittant ses axes.
func _mark_cross(grid: MazeGrid, boss_cell: Vector2i) -> void:
	for direction in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		var cell: Vector2i = boss_cell + direction
		for distance in count:
			if not grid.is_floor_v(cell):
				break
			cells.append(cell)
			_delays[cell] = CROSS_STEP * distance
			_verticals[cell] = direction.x == 0
			cell += direction


## Les cases praticables en ligne de part et d'autre du mage, jusqu'à `count`, autant que
## possible de chaque côté : il doit pouvoir être pris en tenaille s'il suit la ligne.
func _run(grid: MazeGrid, from: Vector2i, step: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = [from]
	var ahead := from + step
	var behind := from - step
	var open_ahead := true
	var open_behind := true
	while out.size() < count and (open_ahead or open_behind):
		open_ahead = open_ahead and grid.is_floor_v(ahead)
		if open_ahead:
			out.append(ahead)
			ahead += step
		open_behind = open_behind and grid.is_floor_v(behind)
		if open_behind and out.size() < count:
			out.append(behind)
			behind -= step
	return out
