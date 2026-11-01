class_name CreatureRules
extends RefCounted

## Les règles des créatures qui ne font pas que poursuivre : le Rat vole, la Gelée se
## scinde, la Vesse crache, la Raie traverse les murs.
##
## En RefCounted, comme `ThrowSystem` : le Level les appelle pour jouer, et
## `tests/test_balance.gd` pour mesurer. Une règle écrite dans le Level n'existerait pas
## pour la simulation, qui rendrait un verdict sur un autre jeu.

## Le Rat ne prend pas une gemme à moins de tant de cases du mage. Sinon il la lui arrache
## sous le nez : la course serait perdue sans que le joueur ait pu faire quoi que ce soit.
const THIEF_SHY_CELLS := 3


## Vers quelles gemmes les rats courent : celles qu'ils ont le droit de prendre.
static func stealable_field(grid: MazeGrid, ground_gems: Array[Vector2i],
		player_field: PackedInt32Array) -> PackedInt32Array:
	var sources: Array[Vector2i] = []
	for gem in ground_gems:
		if may_steal(grid, player_field, gem):
			sources.append(gem)
	return Pathfinder.distance_field(grid, sources)


static func may_steal(grid: MazeGrid, player_field: PackedInt32Array, cell: Vector2i) -> bool:
	var distance := Pathfinder.value_at(grid, player_field, cell)
	return distance < 0 or distance > THIEF_SHY_CELLS


## Où naissent les petites gelées : sur la case de la grande, puis à côté. Jamais sur le
## mage, pour la même raison que le refus du dernier pas : deux sprites superposés, on ne
## voit plus qui frappe.
static func split_cells(grid: MazeGrid, cell: Vector2i, player_cell: Vector2i,
		count: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	if cell != player_cell:
		out.append(cell)
	for direction in MazeGrid.NEIGHBORS:
		var side: Vector2i = cell + direction
		if out.size() < count and side != player_cell and grid.is_floor_v(side):
			out.append(side)
	# Un cul-de-sac bouché par le mage : elles naissent l'une sur l'autre.
	while not out.is_empty() and out.size() < count:
		out.append(out[0])
	return out


static func in_spit_reach(grid: MazeGrid, player_field: PackedInt32Array, cell: Vector2i,
		reach: int) -> bool:
	var distance := Pathfinder.value_at(grid, player_field, cell)
	return distance >= 0 and distance <= reach


## Le nuage tombe une case devant la Vesse, vers le mage, et couvre le carrefour. Il suit
## les couloirs : il n'a aucune raison de ralentir le couloir voisin, de l'autre côté de
## la haie.
static func spit_cells(grid: MazeGrid, cell: Vector2i,
		player_field: PackedInt32Array) -> Array[Vector2i]:
	var centre := cell + Pathfinder.step_toward(grid, player_field, cell)
	var out: Array[Vector2i] = [centre]
	for direction in MazeGrid.NEIGHBORS:
		var side: Vector2i = centre + direction
		if grid.is_floor_v(side):
			out.append(side)
	return out


## La case de sol qui représente une créature prise dans un mur.
##
## Le combat ne connaît que les distances de chemin, et un mur n'en a pas : sans ça, la
## Raie serait intouchable dans la haie alors qu'elle y frappe. On prend la case de sol
## voisine la plus proche du mage. Une haie fait une case d'épaisseur presque partout,
## d'où le second anneau.
static func anchor_cell(grid: MazeGrid, cell: Vector2i, player_cell: Vector2i) -> Vector2i:
	if grid.is_floor_v(cell):
		return cell
	for ring in [1, 2]:
		var best := Vector2i(-1, -1)
		var best_gap := INF
		for direction in MazeGrid.NEIGHBORS:
			var side: Vector2i = cell + direction * int(ring)
			var gap := Vector2(side).distance_to(Vector2(player_cell))
			if grid.is_floor_v(side) and gap < best_gap:
				best = side
				best_gap = gap
		if best.x >= 0:
			return best
	return cell
