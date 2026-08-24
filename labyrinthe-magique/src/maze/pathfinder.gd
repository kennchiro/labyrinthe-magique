class_name Pathfinder
extends RefCounted

## Pathfinding par champ de distances (BFS), pas par A* individuel.
##
## Une seule passe BFS depuis la CIBLE produit un tableau où chaque case connaît
## sa distance au joueur. Chaque poursuivant n'a plus qu'à descendre le gradient :
## il obtient exactement le chemin le plus court, mais le coût est payé UNE fois
## pour tous les ennemis, pas une fois par ennemi.
##
## C'est aussi ce qui rend l'état SEARCH gratuit : il suffit de garder une copie
## du champ au moment où l'ennemi a perdu le joueur de vue, et de continuer à
## le descendre — l'ennemi se dirige alors vers la dernière position connue,
## sans un seul calcul supplémentaire.

static func distance_field(grid: MazeGrid, sources: Array[Vector2i]) -> PackedInt32Array:
	var field := PackedInt32Array()
	field.resize(grid.cols * grid.rows)
	field.fill(-1)

	var queue: Array[Vector2i] = []
	for source in sources:
		if grid.is_floor_v(source):
			field[grid.index(source.x, source.y)] = 0
			queue.append(source)

	var head := 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		var next_distance: int = field[grid.index(current.x, current.y)] + 1
		for neighbour in grid.floor_neighbors(current):
			var i := grid.index(neighbour.x, neighbour.y)
			if field[i] == -1:
				field[i] = next_distance
				queue.append(neighbour)
	return field


static func value_at(grid: MazeGrid, field: PackedInt32Array, cell: Vector2i) -> int:
	if field.is_empty() or not grid.in_bounds(cell.x, cell.y):
		return -1
	return field[grid.index(cell.x, cell.y)]


## Direction du premier pas vers la source du champ.
## ZERO si on y est déjà, ou si la cible est inatteignable.
static func step_toward(grid: MazeGrid, field: PackedInt32Array, from: Vector2i) -> Vector2i:
	var current := value_at(grid, field, from)
	if current <= 0:
		return Vector2i.ZERO
	var best := current
	var best_direction := Vector2i.ZERO
	for d in MazeGrid.NEIGHBORS:
		var value := value_at(grid, field, from + d)
		if value >= 0 and value < best:
			best = value
			best_direction = d
	return best_direction
