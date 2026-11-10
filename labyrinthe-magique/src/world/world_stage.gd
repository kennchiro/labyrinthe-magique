class_name WorldStage
extends Node3D

## La vue en volume du jeu : le sol et les haies sont en 3D, tout le reste est le
## `Level` 2D, inchangé, dessiné dans une texture et couché sur le sol.
##
## C'est ce partage qui évite de réécrire le jeu. Personnages, sorts, gemmes,
## portails et barres de vie gardent leur code et leur ordre d'affichage : seule
## leur destination change. Un effet 2D ajouté demain marche donc sans rien ici.
##
##   ⚠️ La caméra 2D ne suit PAS le joueur au sens habituel : elle cadre le morceau
##   de sol vu par la caméra 3D. Le lissage et la secousse sont ceux de la 3D.
##
## C'est la vue du jeu. `--2d` rend l'ancienne, à plat, pour comparer.

const FLAT_FLAG := "--2d"
const CELL_PIXELS := 32.0
const FOLLOW_SPEED := 8.0
const PADDING_RATIO := 0.12
## Marge autour du sol visible, en cases, pour que la secousse ne montre pas le bord.
const CANVAS_MARGIN := 1.0
## Pixels de texture par case. Au-delà, on paie la netteté sans la voir à l'écran.
const MAX_DENSITY := 64.0
const SHARPNESS := 1.15
const MAX_CANVAS_SIDE := 2048.0
## Au-dessus du sol et des ombres de contact.
const GROUND_PRIORITY := 10

const GROUND_SHADER := """
shader_type spatial;
render_mode unshaded, blend_premul_alpha, depth_test_disabled, depth_draw_never, cull_disabled, shadows_disabled;
uniform sampler2D canvas : source_color, filter_linear, repeat_disable;
void fragment() {
	vec4 painted = texture(canvas, UV);
	ALBEDO = painted.rgb;
	ALPHA = painted.a;
}
"""

const AMBIENT_ENERGY := 1.05
const MOON_ENERGY := 0.85
const MAGE_LIGHT := Color(1.0, 0.72, 0.42)
const MAGE_LIGHT_HEIGHT := 1.4
const PORTAL_GLOW := Color(0.25, 0.55, 1.0, 0.55)
const PORTAL_GLOW_RADIUS := 1.9
const HOUSE_GLOW := Color(1.0, 0.68, 0.26, 0.55)
const HOUSE_GLOW_RADIUS := 4.2
## L'ombre de l'îlot : au sud de son centre, sinon l'îlot la cache à la caméra.
const MONUMENT_SHADOW := Color(0.0, 0.0, 0.0, 0.62)
const MONUMENT_SHADOW_SIZE := Vector2(3.2, 2.0)
const MONUMENT_SHADOW_SOUTH := 0.9
## Sous la texture du sol : personnages et gemmes restent dessinés devant l'îlot.
const MONUMENT_PRIORITY := 2
const MONUMENT_SHADOW_PRIORITY := 1

var maze: MazeView3D = null
var camera: Camera3D = null

var _level: Level = null
## La scène 2D adoptée et sa caméra : le `Level` en campagne, l'`ArenaView` en arène.
var _view: Node2D = null
var _camera2d: Camera2D = null
var _canvas: SubViewport = null
var _ground: MeshInstance3D = null
var _ground_material: ShaderMaterial = null
var _glows: Node3D = null
var _mage_light: OmniLight3D = null
var _environment: Environment = null
var _moon: DirectionalLight3D = null
var _mood: StageMood = null
var _rows := CameraRules.VIEW_ROWS
var _footprint := Rect2()
var _density := MAX_DENSITY
var _centre := Vector2.ZERO
var _fitted_for := Vector3.ZERO


static func requested() -> bool:
	return FLAT_FLAG not in OS.get_cmdline_user_args()


## Prend le `Level` en charge. À appeler une fois dans l'arbre, avant le premier niveau.
func adopt(level: Level) -> void:
	_level = level
	# Le Level est adopté VIDE, avant le premier niveau : ce qui entrera dans `entities` sera redressé
	# à son arrivée, et rien de ce qu'il porte déjà dans sa scène ne doit l'être (comme avant l'arène).
	adopt_view(level, level.camera, level.maze_renderer, [level.entities], false)


## Prend en charge n'importe quelle scène 2D posée sur une grille : sa caméra cadrera ce que voit la
## caméra 3D, son rendu à plat est caché, et ce qui entre dans ses `entities` est redressé — y compris
## ce qui s'y trouve déjà (l'arène pose ses héros et ses décors avant d'être adoptée).
func adopt_view(view: Node2D, camera2d: Camera2D, renderer: MazeRenderer, entities: Array,
		stand_present: bool = true) -> void:
	_view = view
	_camera2d = camera2d
	_build_scene()
	_canvas = SubViewport.new()
	_canvas.transparent_bg = true
	_canvas.disable_3d = true
	_canvas.gui_disable_input = true
	_canvas.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_canvas)
	_ground_material.set_shader_parameter("canvas", _canvas.get_texture())
	view.reparent(_canvas, false)
	camera2d.position_smoothing_enabled = false
	camera2d.offset = Vector2.ZERO
	camera2d.make_current()
	renderer.visible = false
	for group in entities:
		add_entities(group, stand_present)


## Un calque d'entités de plus à redresser (les `Level` hôtes de l'arène).
func add_entities(group: Node2D, stand_present: bool = true) -> void:
	if stand_present:
		for child in group.get_children():
			_stand_up(child)
	group.child_entered_tree.connect(_stand_up)


func _build_scene() -> void:
	var world := WorldEnvironment.new()
	_environment = Environment.new()
	_environment.background_mode = Environment.BG_COLOR
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_energy = AMBIENT_ENERGY
	_environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	world.environment = _environment
	add_child(world)

	_moon = DirectionalLight3D.new()
	_moon.light_energy = MOON_ENERGY
	# La lumière vient du sud-ouest : les flancs vus par la caméra restent lisibles.
	_moon.rotation_degrees = Vector3(-58.0, -28.0, 0.0)
	add_child(_moon)

	camera = Camera3D.new()
	camera.fov = CameraRules.FOV_DEGREES
	camera.far = 200.0
	add_child(camera)
	camera.make_current()

	maze = MazeView3D.new()
	add_child(maze)
	_glows = Node3D.new()
	add_child(_glows)

	var shader := Shader.new()
	shader.code = GROUND_SHADER
	_ground_material = ShaderMaterial.new()
	_ground_material.shader = shader
	_ground_material.render_priority = GROUND_PRIORITY
	_ground = MeshInstance3D.new()
	_ground.mesh = PlaneMesh.new()
	_ground.material_override = _ground_material
	_ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ground.extra_cull_margin = 8.0
	add_child(_ground)

	_mage_light = OmniLight3D.new()
	_mage_light.light_color = MAGE_LIGHT
	_mage_light.light_energy = 1.1
	_mage_light.omni_range = 4.6
	add_child(_mage_light)


## `folder` : un dossier de tuiles à la place de celui du stage ; sans maison, aucune lueur de maison
## (l'arène n'en a pas).
func build(grid: MazeGrid, stage: int, folder: String = "", with_house: bool = true) -> void:
	_mood = StageMood.of(stage)
	_environment.background_color = _mood.sky
	_environment.ambient_light_color = _mood.ambient
	_moon.light_color = _mood.moon
	maze.build(grid, stage, _mood, folder)
	for glow in _glows.get_children():
		_glows.remove_child(glow)
		glow.queue_free()
	for cell in grid.portals:
		_add_glow(cell, PORTAL_GLOW_RADIUS, PORTAL_GLOW)
	if with_house:
		_add_glow(grid.house_center, HOUSE_GLOW_RADIUS, HOUSE_GLOW)


## Une lueur posée sur une case, hors campagne (la gemme de l'arène).
func add_glow(cell: Vector2i, radius: float, tint: Color) -> void:
	_add_glow(cell, radius, tint)


## Un mur levé ou tombé : seul le maillage change, la texture du sol suit d'elle-même.
func rebuild_walls() -> void:
	maze.rebuild_walls()


## Un halo PEINT : une OmniLight redessinerait tout le décor qu'elle touche.
func _add_glow(cell: Vector2i, radius: float, tint: Color) -> void:
	var glow := Sprite3D.new()
	glow.texture = SoftTextures.glow()
	glow.axis = Vector3.AXIS_Y
	glow.shaded = false
	glow.no_depth_test = true
	glow.material_override = SoftTextures.additive(glow.texture)
	glow.modulate = tint
	glow.pixel_size = radius * 2.0 / float(glow.texture.get_width())
	glow.position = Vector3(cell.x + 0.5, 0.04, cell.y + 0.5)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_glows.add_child(glow)


## Dresse l'îlot face à la caméra, qui ne tourne jamais. Perpendiculaire à la vue, il garde
## à l'écran la taille de son dessin, et rien ne l'y écrase : il n'a pas à être redressé.
## Les enfants de `_glows` sont retirés à chaque niveau : l'îlot d'avant part avec eux.
func raise_monument(house: House, cell: Vector2i) -> void:
	var panel := Sprite3D.new()
	panel.shaded = false
	panel.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	panel.render_priority = MONUMENT_PRIORITY
	panel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	panel.rotation.x = CameraRules.tilt() - PI * 0.5
	panel.position = Vector3(cell.x + 0.5, House.PANEL_LIFT, cell.y + 0.5 + House.PANEL_SOUTH)
	_glows.add_child(panel)
	house.stand_on(panel)

	var shadow := Sprite3D.new()
	shadow.texture = SoftTextures.blot()
	shadow.axis = Vector3.AXIS_Y
	shadow.shaded = false
	shadow.material_override = SoftTextures.shade(shadow.texture)
	shadow.material_override.render_priority = MONUMENT_SHADOW_PRIORITY
	shadow.modulate = MONUMENT_SHADOW
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	shadow.pixel_size = 1.0 / float(shadow.texture.get_width())
	shadow.scale = Vector3(MONUMENT_SHADOW_SIZE.x, 1.0, MONUMENT_SHADOW_SIZE.y)
	shadow.position = Vector3(cell.x + 0.5, 0.03, cell.y + 0.5 + MONUMENT_SHADOW_SOUTH)
	_glows.add_child(shadow)


## Le dessin d'une entité est debout, mais couché ici sur le sol : on lui rend la
## hauteur que la vue inclinée lui retire. Son origine reste à ses pieds.
func _stand_up(child: Node) -> void:
	if child is Node2D:
		(child as Node2D).scale.y *= CameraRules.stand_scale()


## Cadre la scène. Remplace le suivi de caméra du `Level`, positions en pixels du monde.
func aim(mage: Vector2, maze_pixels: Vector2, overview: bool, snap: bool, shake: Vector2) -> void:
	var cells := maze_pixels / CELL_PIXELS
	var view := Vector2(get_viewport().get_visible_rect().size)
	var aspect := view.x / maxf(1.0, view.y)
	_rows = maxf(cells.y, cells.x / aspect) + 2.0 if overview else CameraRules.VIEW_ROWS
	_aim_at(mage, mage, cells, aspect, overview, snap, shake)


## Cadre `rows` rangées autour de `centre` (pixels du monde) : l'arène suit la mêlée et non un mage.
## Les rangées doivent être ENTIÈRES — la texture du sol est retaillée à chaque changement.
func aim_rows(centre: Vector2, rows: float, maze_pixels: Vector2, snap: bool, shake: Vector2) -> void:
	var view := Vector2(get_viewport().get_visible_rect().size)
	_rows = rows
	_aim_at(centre, centre, maze_pixels / CELL_PIXELS, view.x / maxf(1.0, view.y), false, snap, shake)


func _aim_at(mage: Vector2, focus: Vector2, cells: Vector2, aspect: float, overview: bool, snap: bool,
		shake: Vector2) -> void:
	_fit_canvas(aspect)
	var wanted := cells * 0.5
	if not overview:
		var at := focus / CELL_PIXELS
		wanted = Vector2(_clamp_axis(at.x, _rows * aspect, cells.x),
			_clamp_axis(at.y + CameraRules.AIM_SOUTH, _rows, cells.y))
	if snap or overview:
		_centre = wanted
	else:
		_centre = _centre.lerp(wanted, minf(1.0, get_process_delta_time() * FOLLOW_SPEED))
	_place(mage, shake)


func _place(mage: Vector2, shake: Vector2) -> void:
	var tilt := CameraRules.tilt()
	var range_to_aim := _rows * cos(tilt) / (2.0 * tan(deg_to_rad(CameraRules.FOV_DEGREES) * 0.5))
	var aim_at := Vector3(_centre.x, 0.0, _centre.y)
	camera.look_at_from_position(aim_at + Vector3(0.0, cos(tilt), sin(tilt)) * range_to_aim,
		aim_at, Vector3.FORWARD)
	camera.h_offset = shake.x / CELL_PIXELS
	camera.v_offset = -shake.y / CELL_PIXELS
	# Calé sur un pixel entier de la texture : sinon, les sprites scintillent à
	# chaque image pendant que le sol glisse sous eux.
	var middle := _centre + _footprint.get_center()
	middle = (middle * _density).round() / _density
	_camera2d.position = middle * CELL_PIXELS
	_ground.position = Vector3(middle.x, 0.02, middle.y)
	_mage_light.position = Vector3(mage.x / CELL_PIXELS, MAGE_LIGHT_HEIGHT, mage.y / CELL_PIXELS)


## La texture couvre juste ce que la caméra voit : c'est elle qui coûte, pas le labyrinthe.
func _fit_canvas(aspect: float) -> void:
	var window_height := float(get_window().size.y)
	var wanted := Vector3(_rows, aspect, window_height)
	if wanted == _fitted_for:
		return
	_fitted_for = wanted
	_footprint = CameraRules.footprint(_rows, aspect).grow(CANVAS_MARGIN)
	var longest := maxf(_footprint.size.x, _footprint.size.y)
	_density = minf(minf(MAX_DENSITY, window_height / _rows * SHARPNESS), MAX_CANVAS_SIDE / longest)
	_canvas.size = Vector2i((_footprint.size * _density).ceil())
	(_ground.mesh as PlaneMesh).size = Vector2(_canvas.size) / _density
	_camera2d.zoom = Vector2.ONE * _density / CELL_PIXELS


static func _clamp_axis(value: float, visible: float, world: float) -> float:
	var padding := visible * PADDING_RATIO
	var low := visible * 0.5 - padding
	var high := world - visible * 0.5 + padding
	if low >= high:
		return world * 0.5
	return clampf(value, low, high)


## Pixels du monde 2D -> coordonnées de l'interface. La caméra 3D compte en pixels de
## fenêtre, l'interface en unités de mise en page : le rapport varie selon l'écran.
func world_to_screen(world: Vector2) -> Vector2:
	var at := Vector3(world.x / CELL_PIXELS, 0.0, world.y / CELL_PIXELS)
	return camera.unproject_position(at) / _window_per_unit()


## L'inverse, sur le plan du sol : c'est ce qui rend le tap d'un joueur juste.
func screen_to_world(screen: Vector2) -> Vector2:
	var pixel := screen * _window_per_unit()
	var from := camera.project_ray_origin(pixel)
	var along := camera.project_ray_normal(pixel)
	var hit := from + along * (-from.y / along.y)
	return Vector2(hit.x, hit.z) * CELL_PIXELS


func _window_per_unit() -> Vector2:
	return Vector2(get_window().size) / Vector2(get_viewport().get_visible_rect().size)
