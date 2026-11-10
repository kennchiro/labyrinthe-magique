class_name PackTactics
extends RefCounted

## LA MEUTE : ceux qui suivent en file prennent l'autre chemin.
##
## Chaque poursuivant descendait le même champ de distances, donc arrivait par le même côté
## que le premier, en file indienne derrière lui. Dans un labyrinthe, ce qui fait peur n'est
## pas la file qui suit : c'est celui qui arrive par l'autre bout du couloir.
##
## La règle reste lisible. On classe les poursuivants par le CÔTÉ d'où ils viennent (le
## premier pas qui, depuis le mage, mène à eux). Dans chaque côté, le plus proche continue
## tout droit. Les suivants prennent un AUTRE chemin vers le mage : celui qui évite la
## dernière approche du premier. Ils arrivent donc par un autre bout, et le piège se referme. Quand ils ont
## changé de côté, ils en sont les plus proches et poursuivent normalement.
##
## ⚠️ Une première version les envoyait couper la fuite à six cases, de l'autre côté du mage.
## Mesurée sur 2 400 cas de vrais labyrinthes, elle ne contournait que dans 8 % des cas : l'autre
## côté ne se rejoint presque jamais sans repasser près du mage, ou au prix d'un détour énorme.
##
## Ce qui la garde juste : ils restent plus lents que le mage, ils s'arrêtent toujours à une
## case de lui, et ils ne sont jamais plus de `MAX_FLANKERS` à contourner.
##
## ⚠️ Mesuré sur 2 400 cas de vrais labyrinthes, ce contournement n'est possible que dans 5 % des
## cas : le suivant est le plus souvent coincé dans un cul-de-sac derrière le premier, ou le seul
## autre chemin fait plus de quarante cases. C'est l'APPEL qui change vraiment la poursuite
## (`rally`) ; le contournement s'ajoute quand la forme du labyrinthe le permet.
##
## Aucun Node : le Level et `test_balance` l'appellent au même rafraîchissement d'IA.

## L'APPEL DE LA MEUTE : un ennemi qui poursuit le mage alerte ceux qui patrouillent à moins de
## tant de cases de couloir de lui. Ils foncent vers l'endroit où le mage a été vu. Sans ça, il
## chassait seul pendant que les autres erraient sans rien savoir.
const RALLY_RADIUS := 12

const MAX_FLANKERS := 2
## La dernière approche du premier, en cases : c'est elle seulement qui est interdite aux
## suivants. Interdire tout son couloir les enfermait derrière lui, puisqu'ils y marchent aussi.
## Mesuré : ils ne contournaient plus que dans 5 % des cas.
const APPROACH := 3
## Au-delà de ce détour, contourner ne vaut pas la peine : il arriverait après la bataille.
const MAX_DETOUR := 14


## `chasers` : les poursuivants qui peuvent contourner, `{"index", "cell"}`. Rend, pour ceux qui
## doivent faire le tour, le champ de distances à descendre, index -> champ.
static func assign(grid: MazeGrid, player_cell: Vector2i, player_field: PackedInt32Array,
		chasers: Array[Dictionary]) -> Dictionary:
	var out := {}
	if chasers.size() < 2 or player_field.is_empty():
		return out
	var sides := _sides(grid, player_cell)
	var by_side := {}
	for chaser in chasers:
		var cell: Vector2i = chaser["cell"]
		if not grid.in_bounds(cell.x, cell.y) or not grid.is_floor_v(cell):
			continue
		var side := sides[grid.index(cell.x, cell.y)]
		if side < 0:
			continue
		if not by_side.has(side):
			by_side[side] = []
		(by_side[side] as Array).append(chaser)
	# Ce qui est déjà pris : le couloir de chaque premier, puis celui de chaque contourneur.
	var taken := {}
	var followers: Array = []
	for side in by_side:
		var group: Array = by_side[side]
		group.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return _distance(grid, player_field, a["cell"]) < _distance(grid, player_field, b["cell"]))
		_take_path(grid, player_field, group[0]["cell"], taken)
		followers.append_array(group.slice(1))
	followers.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return _distance(grid, player_field, a["cell"]) < _distance(grid, player_field, b["cell"]))
	for follower: Dictionary in followers:
		if out.size() >= MAX_FLANKERS:
			break
		var around := _field_avoiding(grid, player_cell, taken)
		var cell: Vector2i = follower["cell"]
		var detour := _distance(grid, around, cell)
		if detour < 0 or detour > _distance(grid, player_field, cell) + MAX_DETOUR:
			continue
		out[int(follower["index"])] = around
		_take_path(grid, around, cell, taken)
	return out


## Les patrouilleurs que la meute appelle : ceux à moins de `RALLY_RADIUS` cases de couloir d'un
## poursuivant. `patrols` : `{"index", "cell"}`. Rend leurs index.
static func rally(grid: MazeGrid, chaser_cells: Array[Vector2i], patrols: Array[Dictionary]) -> Array[int]:
	var called: Array[int] = []
	if chaser_cells.is_empty() or patrols.is_empty():
		return called
	var near := Pathfinder.distance_field(grid, chaser_cells)
	for patrol in patrols:
		var distance := _distance(grid, near, patrol["cell"])
		if distance >= 0 and distance <= RALLY_RADIUS:
			called.append(int(patrol["index"]))
	return called


## Les dernières cases du plus court chemin de `from` au mage, sauf le mage : l'approche d'un
## poursuivant, celle par où il arrivera.
static func _take_path(grid: MazeGrid, field: PackedInt32Array, from: Vector2i,
		taken: Dictionary) -> void:
	var cell := from
	for _step in grid.cols * grid.rows:
		var left := _distance(grid, field, cell)
		if left <= 0:
			return
		if left <= APPROACH:
			taken[cell] = true
		var step := Pathfinder.step_toward(grid, field, cell)
		if step == Vector2i.ZERO:
			return
		cell += step


## Les distances au mage sans emprunter les couloirs déjà pris : descendre ce champ, c'est
## arriver par un autre bout.
static func _field_avoiding(grid: MazeGrid, player_cell: Vector2i,
		taken: Dictionary) -> PackedInt32Array:
	var field := PackedInt32Array()
	field.resize(grid.cols * grid.rows)
	field.fill(-1)
	field[grid.index(player_cell.x, player_cell.y)] = 0
	var queue: Array[Vector2i] = [player_cell]
	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		var next_distance := field[grid.index(current.x, current.y)] + 1
		for next in grid.floor_neighbors(current):
			var i := grid.index(next.x, next.y)
			if field[i] == -1 and not taken.has(next):
				field[i] = next_distance
				queue.append(next)
	return field


## Le côté de chaque case : l'index du premier pas qui y mène depuis le mage, -1 pour le mage
## et ce qui ne lui est pas relié.
static func _sides(grid: MazeGrid, from: Vector2i) -> PackedInt32Array:
	var sides := PackedInt32Array()
	sides.resize(grid.cols * grid.rows)
	sides.fill(-2)
	if not grid.is_floor_v(from):
		sides.fill(-1)
		return sides
	sides[grid.index(from.x, from.y)] = -1
	var queue: Array[Vector2i] = []
	for n in MazeGrid.NEIGHBORS.size():
		var next: Vector2i = from + MazeGrid.NEIGHBORS[n]
		if grid.is_floor_v(next):
			sides[grid.index(next.x, next.y)] = n
			queue.append(next)
	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		var side := sides[grid.index(current.x, current.y)]
		for next in grid.floor_neighbors(current):
			var i := grid.index(next.x, next.y)
			if sides[i] == -2:
				sides[i] = side
				queue.append(next)
	for i in sides.size():
		if sides[i] == -2:
			sides[i] = -1
	return sides


static func _distance(grid: MazeGrid, field: PackedInt32Array, cell: Vector2i) -> int:
	return Pathfinder.value_at(grid, field, cell)
