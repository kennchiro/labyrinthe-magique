class_name MazeView3D
extends Node3D

## Le labyrinthe en volume, construit depuis MazeGrid sans rien y changer.
##
## Le volume des haies se DÉDUIT du dessin : la silhouette de chaque pièce de
## `wall_atlas.png` est relevée sur son canal alpha, puis extrudée. La haie 3D a
## donc exactement les bouts arrondis et les coins de la haie dessinée, et un
## nouvel atlas ne demande aucune retouche ici.
##
## Tout tient en trois maillages (sol, haies, ombres de contact) : trois appels
## de dessin, quelle que soit la taille du labyrinthe.

const TILES_PATH := "res://assets/tiles/"
const FLOOR_SHADER := preload("res://assets/shaders/maze_floor.gdshader")
const WALL_SHADER := preload("res://assets/shaders/maze_wall.gdshader")
const DRIFT_NOISE := preload("res://assets/shaders/fire_noise.png")
const PIECE_COLUMNS := 4
const PIECE_ROWS := 4
## Rangées de haies ajoutées autour de la grille : la caméra voit au-delà du bord.
const OUTSIDE_RING := 7
## Précision du relevé de silhouette, en pixels d'atlas. Plus fin, le nombre de
## triangles monte vite pour un arrondi qui ne se voit plus à cette distance.
const OUTLINE_EPSILON := 2.5
## Sous cette distance, un point du contour est considéré sur le bord de la pièce.
const EDGE_SNAP_PIXELS := 2.0
## Points relevés sur une planche pour mesurer sa luminosité.
const LUMA_SAMPLES := 24
const WALL_TOP_SHADE := 1.0
const WALL_SIDE_TOP_SHADE := 0.60
const WALL_SIDE_FOOT_SHADE := 0.20
const CONTACT_WIDTH := 0.20
const CONTACT_ALPHA := 0.62
## Les quatre angles d'une case : la diagonale qu'ils regardent et les deux bras
## (bits de voisins) qui les encadrent.
const CORNERS: Array[Dictionary] = [
	{"step": Vector2i(1, -1), "arms": 1 | 2},
	{"step": Vector2i(1, 1), "arms": 2 | 4},
	{"step": Vector2i(-1, 1), "arms": 4 | 8},
	{"step": Vector2i(-1, -1), "arms": 8 | 1},
]

var triangle_count := 0

var _grid: MazeGrid = null
var _atlas: Texture2D = null
var _atlas_image: Image = null
var _piece := 64
var _variants := 1
var _outlines := {}
var _mood: StageMood = null
var _wall_gain := 0.0
## Côté de l'encoche d'une croix, en fraction de case, mesuré sur l'atlas.
var _notch := 0.0


func build(grid: MazeGrid, stage: int, mood: StageMood) -> void:
	_grid = grid
	_mood = mood
	_wall_gain = 0.0
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var folder := TILES_PATH + "stage_%d/" % stage
	var atlas: Texture2D = load(folder + "wall_atlas.png")
	var floor_sheet: Texture2D = load(folder + "floor_sheet.png")
	_atlas = atlas
	_atlas_image = atlas.get_image()
	_atlas_image.convert(Image.FORMAT_RGBA8)
	_piece = atlas.get_width() / PIECE_COLUMNS
	_variants = maxi(1, atlas.get_height() / (_piece * PIECE_ROWS))
	_notch = _measure_notch()
	_outlines.clear()
	triangle_count = 0
	_add_floor(floor_sheet)
	_add_walls(atlas)


## Un mur levé ou tombé en pleine partie : le sol, l'atlas et les silhouettes restent
## valables, seules les haies se reconstruisent.
func rebuild_walls() -> void:
	for node_name in ["Walls", "ContactShadows"]:
		var old := get_node_or_null(node_name)
		if old != null:
			remove_child(old)
			old.queue_free()
	triangle_count = 2
	_add_walls(_atlas)


func _add_floor(sheet: Texture2D) -> void:
	# La planche fait six cases de côté : UNE période par largeur de texture.
	var period := float(sheet.get_width()) / 32.0
	var low := Vector2(-OUTSIDE_RING, -OUTSIDE_RING)
	var high := Vector2(_grid.cols + OUTSIDE_RING, _grid.rows + OUTSIDE_RING)
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	tool.set_normal(Vector3.UP)
	for corner in [low, Vector2(high.x, low.y), high, low, high, Vector2(low.x, high.y)]:
		tool.set_uv(corner / period)
		tool.add_vertex(Vector3(corner.x, 0.0, corner.y))
	var material := _drifting(FLOOR_SHADER)
	material.set_shader_parameter("sheet", sheet)
	# Le sol reste sombre pour que les haies ressortent, quelle que soit sa planche.
	var gain := _mood.floor_luma / _luma(sheet.get_image())
	material.set_shader_parameter("tint",
		Vector3(_mood.floor_hue.r * gain, _mood.floor_hue.g * gain, _mood.floor_hue.b * gain))
	material.set_shader_parameter("flow", _mood.flow)
	material.set_shader_parameter("flow_tint", Vector3(_mood.flow_tint.r, _mood.flow_tint.g, _mood.flow_tint.b))
	material.set_shader_parameter("flow_scale", _mood.flow_scale)
	material.set_shader_parameter("flow_speed", _mood.flow_speed)
	_add_mesh(tool, material, "Floor")
	triangle_count += 2


func _add_walls(atlas: Texture2D) -> void:
	var walls := SurfaceTool.new()
	walls.begin(Mesh.PRIMITIVE_TRIANGLES)
	var contact := SurfaceTool.new()
	contact.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(-OUTSIDE_RING, _grid.rows + OUTSIDE_RING):
		for col in range(-OUTSIDE_RING, _grid.cols + OUTSIDE_RING):
			if _is_wall_or_outside(col, row):
				_add_wall_cell(walls, contact, Vector2i(col, row))

	var wall_material := _drifting(WALL_SHADER)
	wall_material.set_shader_parameter("atlas", atlas)
	if _wall_gain <= 0.0:
		_wall_gain = _mood.wall_luma / _luma(_atlas_image)
	wall_material.set_shader_parameter("gain", _wall_gain)
	wall_material.set_shader_parameter("wind", _mood.wind)
	wall_material.set_shader_parameter("sparkle", _mood.sparkle)
	_add_mesh(walls, wall_material, "Walls")

	var contact_material := StandardMaterial3D.new()
	contact_material.vertex_color_use_as_albedo = true
	contact_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	contact_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	contact_material.no_depth_test = false
	var shadow := _add_mesh(contact, contact_material, "ContactShadows")
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _drifting(shader: Shader) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("drift_noise", DRIFT_NOISE)
	material.set_shader_parameter("cloud_depth", _mood.cloud_depth)
	material.set_shader_parameter("flash", _mood.flash)
	return material


## Luminosité moyenne du dessin, transparence exclue. Une grille de points suffit :
## la teinte qu'on en tire ne bouge plus au-delà de quelques centaines.
static func _luma(image: Image) -> float:
	var total := 0.0
	var count := 0
	if image.is_compressed():
		image.decompress()
	for y in LUMA_SAMPLES:
		for x in LUMA_SAMPLES:
			var pixel := image.get_pixel(
				int((x + 0.5) * image.get_width() / LUMA_SAMPLES),
				int((y + 0.5) * image.get_height() / LUMA_SAMPLES))
			if pixel.a >= 0.5:
				total += pixel.get_luminance()
				count += 1
	return maxf(0.01, total / maxf(1.0, float(count)))


func _add_mesh(tool: SurfaceTool, material: Material, node_name: String) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	tool.set_material(material)
	instance.mesh = tool.commit()
	add_child(instance)
	return instance


func _add_wall_cell(walls: SurfaceTool, contact: SurfaceTool, cell: Vector2i) -> void:
	var mask := 0
	if _is_wall_or_outside(cell.x, cell.y - 1):
		mask |= 1
	if _is_wall_or_outside(cell.x + 1, cell.y):
		mask |= 2
	if _is_wall_or_outside(cell.x, cell.y + 1):
		mask |= 4
	if _is_wall_or_outside(cell.x - 1, cell.y):
		mask |= 8
	# La variante se tire de la case : rejouer une graine redonne le même mur.
	var noise := _cell_noise(cell)
	var variant := (noise / 7) % _variants
	var shade := 1.0 + (float(noise % 100) / 100.0 - 0.5) * 0.12
	for outline: PackedVector2Array in outline_of(mask, variant, _closed_corners(cell, mask)):
		_add_top(walls, cell, mask, variant, outline, shade)
		_add_sides(walls, contact, cell, mask, variant, outline, shade)


## Les angles de la case à refermer, un bit par angle de `CORNERS`. Une encoche de
## l'atlas n'a de sens que face à du sol : entre deux bras et une case diagonale déjà
## pleine, elle ferait un puits, et le pointillé sur toute la lisière.
func _closed_corners(cell: Vector2i, mask: int) -> int:
	var closed := 0
	for index in CORNERS.size():
		var corner: Dictionary = CORNERS[index]
		var step: Vector2i = corner["step"]
		var arms: int = corner["arms"]
		if mask & arms == arms and _is_wall_or_outside(cell.x + step.x, cell.y + step.y):
			closed |= 1 << index
	return closed


## Silhouettes d'une pièce, en fractions de case, relevées une fois par pièce.
func outline_of(mask: int, variant: int, closed := 0) -> Array:
	var key := mask + variant * 16 + closed * 256
	if _outlines.has(key):
		return _outlines[key]
	if closed != 0:
		# ⚠️ Une plaque carrée pour toute croix faisait dépasser ses coins des bras
		# voisins, sans flanc dessous : d'où les triangles et les coins noirs des
		# carrefours. On ne referme donc que les angles vraiment entourés.
		var shapes: Array = outline_of(mask, variant)
		for index in CORNERS.size():
			if closed & (1 << index):
				shapes = _with_corner(shapes, index)
		_outlines[key] = shapes
		return shapes
	var region := Rect2i(_piece_origin(mask, variant), Vector2i(_piece, _piece))
	var piece := _atlas_image.get_region(region)
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(piece, 0.5)
	var found: Array = []
	for polygon: PackedVector2Array in bitmap.opaque_to_polygons(
			Rect2i(0, 0, _piece, _piece), OUTLINE_EPSILON):
		var snapped_points := PackedVector2Array()
		for point in polygon:
			snapped_points.append(_snap_to_piece(point))
		# Toujours le même sens vu de dessus : c'est lui qui donne la normale des
		# flancs. Godot dessine la face dont les sommets tournent en sens horaire.
		if _signed_area(snapped_points) < 0.0:
			snapped_points.reverse()
		found.append(snapped_points)
	_outlines[key] = found
	return found


## Le filet de l'atlas referme le fond de l'encoche : son côté se lit donc sur le bord
## de la pièce, là où le bras commence.
func _measure_notch() -> float:
	var origin := _piece_origin(15, 0)
	for x in _piece / 2:
		if _atlas_image.get_pixel(origin.x + x, origin.y).a >= 0.5:
			return float(x) / float(_piece)
	return 0.0


func _with_corner(shapes: Array, index: int) -> Array:
	var step: Vector2i = CORNERS[index]["step"]
	var origin := Vector2(0.0 if step.x < 0 else 1.0 - _notch, 0.0 if step.y < 0 else 1.0 - _notch)
	var patch := PackedVector2Array([origin, origin + Vector2(_notch, 0.0),
		origin + Vector2(_notch, _notch), origin + Vector2(0.0, _notch)])
	var merged: Array = []
	for shape: PackedVector2Array in shapes:
		for polygon: PackedVector2Array in Geometry2D.merge_polygons(shape, patch):
			if _signed_area(polygon) < 0.0:
				polygon.reverse()
			merged.append(polygon)
	return merged


func _snap_to_piece(point: Vector2) -> Vector2:
	var size := float(_piece)
	var out := point
	if out.x <= EDGE_SNAP_PIXELS:
		out.x = 0.0
	elif out.x >= size - EDGE_SNAP_PIXELS:
		out.x = size
	if out.y <= EDGE_SNAP_PIXELS:
		out.y = 0.0
	elif out.y >= size - EDGE_SNAP_PIXELS:
		out.y = size
	return out / size


## Positive quand le contour tourne en sens horaire vu de dessus (Z vers le sud).
static func _signed_area(points: PackedVector2Array) -> float:
	var area := 0.0
	for i in points.size():
		var a := points[i]
		var b := points[(i + 1) % points.size()]
		area += a.x * b.y - b.x * a.y
	return area * 0.5


func _piece_origin(mask: int, variant: int) -> Vector2i:
	return Vector2i(mask % PIECE_COLUMNS, mask / PIECE_COLUMNS + PIECE_ROWS * variant) * _piece


func _add_top(tool: SurfaceTool, cell: Vector2i, mask: int, variant: int,
		outline: PackedVector2Array, shade: float) -> void:
	var triangles := Geometry2D.triangulate_polygon(outline)
	var height := CameraRules.WALL_HEIGHT
	var colour := Color(shade, shade, shade) * WALL_TOP_SHADE
	tool.set_normal(Vector3.UP)
	tool.set_color(colour)
	for first in range(0, triangles.size(), 3):
		var corners := [outline[triangles[first]], outline[triangles[first + 1]],
			outline[triangles[first + 2]]]
		# La triangulation ne promet aucun sens : il est imposé triangle par triangle.
		if _signed_area(PackedVector2Array(corners)) < 0.0:
			corners.reverse()
		for point: Vector2 in corners:
			tool.set_uv(_atlas_uv(mask, variant, point))
			tool.add_vertex(Vector3(cell.x + point.x, height, cell.y + point.y))
	triangle_count += triangles.size() / 3


func _add_sides(walls: SurfaceTool, contact: SurfaceTool, cell: Vector2i, mask: int, variant: int,
		outline: PackedVector2Array, shade: float) -> void:
	var height := CameraRules.WALL_HEIGHT
	var top_colour := Color.WHITE * shade * WALL_SIDE_TOP_SHADE
	var foot_colour := Color.WHITE * shade * WALL_SIDE_FOOT_SHADE
	top_colour.a = 1.0
	foot_colour.a = 1.0
	var outs := _vertex_normals(outline)
	var count := outline.size()
	for i in count:
		var a := outline[i]
		var b := outline[(i + 1) % count]
		if _on_piece_border(a, b):
			continue
		var out_a := outs[i]
		var out_b := outs[(i + 1) % count]
		var top_a := Vector3(cell.x + a.x, height, cell.y + a.y)
		var top_b := Vector3(cell.x + b.x, height, cell.y + b.y)
		var foot_a := Vector3(top_a.x, 0.0, top_a.z)
		var foot_b := Vector3(top_b.x, 0.0, top_b.z)
		# La texture se PLIE sur l'arête : le flanc lit le dessin du dessus, en
		# rentrant vers l'intérieur. Aucune couture entre le dessus et le côté.
		var uv_top_a := _atlas_uv(mask, variant, a)
		var uv_top_b := _atlas_uv(mask, variant, b)
		var uv_foot_a := _atlas_uv(mask, variant, a - out_a * height)
		var uv_foot_b := _atlas_uv(mask, variant, b - out_b * height)
		var normal_a := Vector3(out_a.x, 0.0, out_a.y)
		var normal_b := Vector3(out_b.x, 0.0, out_b.y)
		_side_vertex(walls, top_a, uv_top_a, top_colour, normal_a)
		_side_vertex(walls, foot_a, uv_foot_a, foot_colour, normal_a)
		_side_vertex(walls, foot_b, uv_foot_b, foot_colour, normal_b)
		_side_vertex(walls, top_a, uv_top_a, top_colour, normal_a)
		_side_vertex(walls, foot_b, uv_foot_b, foot_colour, normal_b)
		_side_vertex(walls, top_b, uv_top_b, top_colour, normal_b)
		triangle_count += 2
		_add_contact(contact, foot_a, foot_b, normal_a, normal_b)


## Normale extérieure à chaque SOMMET, moyenne des deux arêtes qui s'y rejoignent :
## l'arrondi est lissé, et les bandes d'ombre de deux arêtes voisines se raccordent.
func _vertex_normals(outline: PackedVector2Array) -> PackedVector2Array:
	var count := outline.size()
	var edges := PackedVector2Array()
	for i in count:
		var along := (outline[(i + 1) % count] - outline[i]).normalized()
		edges.append(Vector2(along.y, -along.x))
	var out := PackedVector2Array()
	for i in count:
		out.append((edges[i] + edges[(i - 1 + count) % count]).normalized())
	return out


func _side_vertex(tool: SurfaceTool, at: Vector3, uv: Vector2, colour: Color, normal: Vector3) -> void:
	tool.set_normal(normal)
	tool.set_color(colour)
	tool.set_uv(uv)
	tool.add_vertex(at)


## L'ombre de contact : une bande qui s'estompe au pied de la haie. C'est elle qui
## pose le volume sur le sol, pour une fraction du prix d'une vraie ombre portée.
func _add_contact(tool: SurfaceTool, a: Vector3, b: Vector3, out_a: Vector3, out_b: Vector3) -> void:
	var lift := Vector3(0.0, 0.01, 0.0)
	var dark := Color(0.0, 0.0, 0.02, CONTACT_ALPHA)
	var clear := Color(0.0, 0.0, 0.02, 0.0)
	var near_a := a + lift
	var near_b := b + lift
	var far_a := near_a + out_a * CONTACT_WIDTH
	var far_b := near_b + out_b * CONTACT_WIDTH
	tool.set_normal(Vector3.UP)
	for pair in [[near_a, dark], [far_a, clear], [far_b, clear],
			[near_a, dark], [far_b, clear], [near_b, dark]]:
		tool.set_color(pair[1])
		tool.add_vertex(pair[0])
	triangle_count += 2


## Une arête posée sur le bord de la pièce raccorde la case voisine : elle est
## À L'INTÉRIEUR de la haie, et personne ne la verra jamais.
func _on_piece_border(a: Vector2, b: Vector2) -> bool:
	return (a.x == b.x and (a.x == 0.0 or a.x == 1.0)) \
		or (a.y == b.y and (a.y == 0.0 or a.y == 1.0))


func _atlas_uv(mask: int, variant: int, point: Vector2) -> Vector2:
	# Un demi-pixel de retrait : le filtrage ne doit pas lire la pièce voisine.
	var margin := 0.5 / float(_piece)
	var inside := point.clamp(Vector2(margin, margin), Vector2(1.0 - margin, 1.0 - margin))
	# Seul un angle refermé atteint le coin de la case. Ce coin est vide dans l'atlas :
	# il reprend le dessin juste au-delà de l'encoche.
	if (point.x == 0.0 or point.x == 1.0) and (point.y == 0.0 or point.y == 1.0):
		inside = inside.clamp(Vector2(_notch, _notch), Vector2(1.0 - _notch, 1.0 - _notch))
	var origin := Vector2(_piece_origin(mask, variant)) / float(_piece)
	var total := Vector2(PIECE_COLUMNS, PIECE_ROWS * _variants)
	return (origin + inside) / total


func _is_wall_or_outside(x: int, y: int) -> bool:
	return x < 0 or y < 0 or x >= _grid.cols or y >= _grid.rows or _grid.is_wall(x, y)


static func _cell_noise(cell: Vector2i) -> int:
	var h: int = cell.x * 73856093 + cell.y * 19349663 + 29 * 83492791
	h = (h ^ (h >> 13)) * 1274126177
	return absi(h ^ (h >> 16))
