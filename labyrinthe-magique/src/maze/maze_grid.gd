class_name MazeGrid
extends RefCounted

## Données pures du labyrinthe.
##
## Cette classe ne connaît QUE des coordonnées de grille (col, row) : jamais de
## pixels, jamais de Node. C'est la règle d'or du projet — elle rend la
## génération, le pathfinding et les portails testables sans lancer le jeu,
## et permet de remplacer complètement le rendu (placeholders -> tileset)
## sans toucher à une ligne de logique.

enum Cell { WALL, FLOOR }

const NEIGHBORS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

var cols: int
var rows: int

var _cells: PackedByteArray

## Distance BFS de chaque case jusqu'à la maison. -1 = mur ou inatteignable.
## Calculée une fois à la génération, elle sert ensuite à TOUT :
## la règle des 20 % des portails, le placement du spawn joueur, l'équilibrage.
var distance_to_house: PackedInt32Array

var house_center: Vector2i = Vector2i.ZERO
var house_cells: Array[Vector2i] = []
var portals: Array[Vector2i] = []
## Gemmes à ramasser. Leur nombre EST la condition de victoire du niveau.
var gems: Array[Vector2i] = []
## Repaires d'ennemis : deux, aux coins opposés. Les ennemis en SORTENT — ils
## n'apparaissent plus au hasard, et le joueur apprend d'où vient le danger.
var lairs: Array[Vector2i] = []
## Potions posées à la génération. D'autres peuvent apparaître en cours de
## partie (voir Level) — cette liste ne décrit que l'état initial.
var potions: Array[Vector2i] = []
var player_spawn: Vector2i = Vector2i.ZERO
var enemy_spawns: Array[Vector2i] = []


func _init(p_cols: int, p_rows: int) -> void:
	cols = p_cols
	rows = p_rows
	_cells = PackedByteArray()
	_cells.resize(cols * rows)
	_cells.fill(Cell.WALL)
	distance_to_house = PackedInt32Array()
	distance_to_house.resize(cols * rows)
	distance_to_house.fill(-1)


func index(c: int, r: int) -> int:
	return r * cols + c


func in_bounds(c: int, r: int) -> bool:
	return c >= 0 and c < cols and r >= 0 and r < rows


func get_cell(c: int, r: int) -> int:
	if not in_bounds(c, r):
		return Cell.WALL
	return _cells[index(c, r)]


func set_cell(c: int, r: int, value: int) -> void:
	if in_bounds(c, r):
		_cells[index(c, r)] = value


func is_wall(c: int, r: int) -> bool:
	return get_cell(c, r) == Cell.WALL


func is_floor(c: int, r: int) -> bool:
	return get_cell(c, r) == Cell.FLOOR


func is_floor_v(p: Vector2i) -> bool:
	return is_floor(p.x, p.y)


func is_house(p: Vector2i) -> bool:
	return house_cells.has(p)


## Voisins orthogonaux praticables — la base du pathfinding et de l'IA.
func floor_neighbors(p: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in NEIGHBORS:
		var n: Vector2i = p + d
		if is_floor_v(n):
			out.append(n)
	return out


func distance_at(p: Vector2i) -> int:
	if not in_bounds(p.x, p.y):
		return -1
	return distance_to_house[index(p.x, p.y)]


func set_distance(p: Vector2i, d: int) -> void:
	if in_bounds(p.x, p.y):
		distance_to_house[index(p.x, p.y)] = d


func all_floor_cells() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for r in rows:
		for c in cols:
			if _cells[index(c, r)] == Cell.FLOOR:
				out.append(Vector2i(c, r))
	return out


## Une case est-elle déjà occupée par un élément de jeu ? Sert au placement :
## une gemme sous un portail serait invisible, une potion sur un spawn serait
## ramassée avant d'avoir été vue.
func is_occupied(p: Vector2i) -> bool:
	return (portals.has(p) or gems.has(p) or potions.has(p) or lairs.has(p)
		or is_house(p) or p == player_spawn or enemy_spawns.has(p))


## Distance maximale à la maison sur tout le labyrinthe (= le point le plus reculé).
func max_distance() -> int:
	var best := 0
	for d in distance_to_house:
		if d > best:
			best = d
	return best
