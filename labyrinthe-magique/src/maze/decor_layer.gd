class_name DecorLayer
extends Node2D

## Semis de décor : champignons, runes, cristaux, lanternes dans les couloirs,
## et une lisière d'arbres tout autour du labyrinthe.
##
## Le placement est DÉTERMINISTE, dérivé de la graine du niveau comme le
## labyrinthe lui-même : rejouer la même graine redonne exactement la même forêt.
## Sans ça, un bug d'affichage serait irreproductible.
##
## Les cristaux de la planche ont été RETIRÉS du semis : depuis que les gemmes
## sont l'objectif du jeu, un cristal violet posé dans un couloir se confond
## avec une améthyste à ramasser. Le décor ne doit jamais imiter un objectif.
##
## Les props lumineux sont déclarés à part : l'étape 9 y accrochera des
## PointLight2D sans avoir à re-parcourir le semis.

const PROPS: Array[Texture2D] = [
	preload("res://assets/sprites/prop_mushroom.png"),
	preload("res://assets/sprites/prop_flower_purple.png"),
	preload("res://assets/sprites/prop_flower_red.png"),
	preload("res://assets/sprites/prop_rock.png"),
	preload("res://assets/sprites/prop_rocks.png"),
	preload("res://assets/sprites/prop_twig.png"),
	preload("res://assets/sprites/prop_plant.png"),
	preload("res://assets/sprites/prop_stone.png"),
	preload("res://assets/sprites/prop_log.png"),
]
const GLOWING: Array[Texture2D] = [
	preload("res://assets/sprites/rune_blue.png"),
	preload("res://assets/sprites/rune_teal.png"),
	preload("res://assets/sprites/rune_deep.png"),
	preload("res://assets/sprites/lantern.png"),
	preload("res://assets/sprites/torch.png"),
	preload("res://assets/sprites/torch_gold.png"),
]
const TREES: Array[Texture2D] = [
	preload("res://assets/sprites/tree_bright.png"),
	preload("res://assets/sprites/tree_pine.png"),
	preload("res://assets/sprites/tree_round.png"),
	preload("res://assets/sprites/tree_small.png"),
	preload("res://assets/sprites/tree_dead.png"),
	preload("res://assets/sprites/tree_twisted.png"),
]

## Une case de couloir sur douze reçoit un prop. Au-delà, le décor devient du
## bruit et le joueur ne distingue plus les portails du mobilier.
const PROP_CHANCE := 12
## Un prop sur cinq est lumineux.
const GLOW_CHANCE := 5
## Épaisseur de la lisière d'arbres autour du labyrinthe, en cases.
const FOREST_RING := 4

var tile_size := 32
## [{texture, position, scale, modulate}] — reconstruit à chaque niveau.
var _items: Array[Dictionary] = []
## Positions monde des props lumineux, pour l'éclairage de l'étape 9.
var glowing_positions: Array[Vector2] = []


## Décor du stage en cours. Les tableaux constants ci-dessus sont celui de la
## forêt, qui sert de repli — le stage 9 n'a pas de planche.
var _stage_props: Array[Texture2D] = []
var _stage_glowing: Array[Texture2D] = []
var _stage_trees: Array[Texture2D] = []


## Charge le décor découpé de la planche du stage. Semer les mêmes champignons
## verts dans les dunes et sur la banquise faisait dix stages qui se
## ressemblaient malgré leurs terrains différents.
func set_stage(index: int) -> void:
	_stage_props = _load_role(index, "semis")
	_stage_glowing = _load_role(index, "lueur")
	_stage_trees = _load_role(index, "lisiere")


func _load_role(index: int, role: String) -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	var folder := "res://assets/stages/props/stage_%d/%s/" % [index, role]
	# Douze rangs et non six : les planches de terrain fournissent dix objets de
	# semis par stage, et s'arrêter à six en jetterait quatre sans rien dire.
	for rank in 12:
		var path := folder + "%s_%d.png" % [role, rank]
		if not ResourceLoader.exists(path):
			continue
		var texture: Texture2D = load(path)
		if texture != null:
			out.append(texture)
	return out


func build(grid: MazeGrid, p_tile_size: int, rng_seed: int) -> void:
	tile_size = p_tile_size
	_items.clear()
	glowing_positions.clear()

	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed if rng_seed != 0 else 1
	_plant_forest(grid, rng)
	_scatter_props(grid, rng)
	queue_redraw()


func _scatter_props(grid: MazeGrid, rng: RandomNumberGenerator) -> void:
	for cell in grid.all_floor_cells():
		# On laisse libres la maison, les portails et les points d'apparition :
		# un champignon posé sur un portail le rendrait illisible.
		if grid.is_house(cell) or grid.portals.has(cell) or cell == grid.player_spawn:
			continue
		if grid.enemy_spawns.has(cell):
			continue
		if rng.randi_range(0, PROP_CHANCE - 1) != 0:
			continue

		var glowing := rng.randi_range(0, GLOW_CHANCE - 1) == 0
		var pool := GLOWING if glowing else PROPS
		if glowing and not _stage_glowing.is_empty():
			pool = _stage_glowing
		elif not glowing and not _stage_props.is_empty():
			pool = _stage_props
		var texture: Texture2D = pool[rng.randi_range(0, pool.size() - 1)]
		var target := float(tile_size) * (0.5 if glowing else 0.42)
		var position := Vector2(cell) * tile_size + Vector2(
			rng.randf_range(0.3, 0.7), rng.randf_range(0.45, 0.75)) * tile_size

		_add(texture, position, target, Color(1, 1, 1))
		if glowing:
			glowing_positions.append(position)


func _plant_forest(grid: MazeGrid, rng: RandomNumberGenerator) -> void:
	var cols := grid.cols
	var rows := grid.rows
	for ring in FOREST_RING:
		var offset := ring + 1
		for i in range(-offset, cols + offset):
			for side in [-offset, rows + offset - 1]:
				if rng.randf() > 0.55:
					continue
				_add_tree(rng, Vector2(i, side))
		for j in range(-offset, rows + offset):
			for side in [-offset, cols + offset - 1]:
				if rng.randf() > 0.55:
					continue
				_add_tree(rng, Vector2(side, j))


func _add_tree(rng: RandomNumberGenerator, cell: Vector2) -> void:
	var pool := _stage_trees if not _stage_trees.is_empty() else TREES
	var texture: Texture2D = pool[rng.randi_range(0, pool.size() - 1)]
	var position := (cell + Vector2(rng.randf_range(0.1, 0.9), rng.randf_range(0.1, 0.9))) * tile_size
	var target := float(tile_size) * rng.randf_range(1.5, 2.6)
	# Assombries : la lisière doit reculer visuellement, pas concurrencer le
	# labyrinthe où se joue la partie.
	var shade := rng.randf_range(0.42, 0.62)
	_add(texture, position, target, Color(shade * 0.9, shade, shade * 0.95))


func _add(texture: Texture2D, position: Vector2, target_height: float, modulate: Color) -> void:
	var scale_factor := target_height / float(texture.get_height())
	_items.append({
		"texture": texture,
		"position": position,
		"size": Vector2(texture.get_width(), texture.get_height()) * scale_factor,
		"modulate": modulate,
	})


func _draw() -> void:
	for item in _items:
		var size: Vector2 = item["size"]
		var position: Vector2 = item["position"] - Vector2(size.x * 0.5, size.y * 0.85)
		draw_texture_rect(item["texture"], Rect2(position, size), false, item["modulate"])
