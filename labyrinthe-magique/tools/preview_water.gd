extends SceneTree

## Les effets du Mage de l'Eau, sort par sort, à trois instants, sur sol sombre et clair.
##
##   godot --path . --resolution 1200x1600 --script res://tools/preview_water.gd -- /tmp/eau.png

const TILE := 32.0
const CELL := Vector2(200, 200)
const GROUNDS: Array[Color] = [Color(0.16, 0.13, 0.2), Color(0.82, 0.75, 0.6)]
const INSTANTS: Array[float] = [0.15, 0.45, 0.75]
## Les tailles du jeu, en cases.
const EFFECTS: Array[Dictionary] = [
	{"key": "jet_eau", "size": Vector2(1.9, 0.5)},
	{"key": "wave", "size": Vector2(3.3, 2.2)},
	{"key": "water_bubble", "size": Vector2(2.6, 2.6)},
	{"key": "glace_peinte", "size": Vector2(6.0, 6.0)},
	{"key": "water_swirl", "size": Vector2(2.5, 2.5)},
	{"key": "water_geyser", "size": Vector2(2.2, 4.4)},
	{"key": "goutte", "size": Vector2(1.0, 0.56)},
	{"key": "water_splash", "size": Vector2(3.25, 3.25)},
]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	await _sheet(args[0] if args.size() > 0 else "/tmp/eau.png")
	quit()


func _material(key: String, seed_value: float, instant: float) -> ShaderMaterial:
	var shaded: ShaderMaterial
	if key == "wave":
		shaded = ShaderMaterial.new()
		shaded.shader = WaveFront.SHADER
		shaded.set_shader_parameter("noise", PaintedFx.NOISE)
		shaded.set_shader_parameter("phase", instant * 3.0)
	elif MagicOrb.PAINTED.has(key):
		shaded = MagicOrb.painted_material(key, seed_value)
	elif ZoneEffect.PAINTED_STYLES.has(key):
		shaded = ZoneEffect.painted_material(key, 3.0, seed_value)
	else:
		shaded = PaintedFx.make_material(key, seed_value)
	shaded.set_shader_parameter("progress", instant)
	# Une zone vit dix secondes : le gel qui s'ouvre, la glace prise, les plaques qui cèdent.
	var seconds: float = {0.15: 0.2, 0.45: 3.0, 0.75: 9.4}[instant]
	shaded.set_shader_parameter("phase", seconds)
	shaded.set_shader_parameter("life", 1.0 - seconds / 10.0)
	return shaded


func _sheet(out: String) -> void:
	var root := Node2D.new()
	get_root().add_child(root)
	var columns := GROUNDS.size() * INSTANTS.size()
	for column in columns:
		var band := ColorRect.new()
		band.size = Vector2(CELL.x, CELL.y * EFFECTS.size())
		band.position = Vector2(CELL.x * column, 0)
		band.color = GROUNDS[column / INSTANTS.size()]
		root.add_child(band)
		for row in EFFECTS.size():
			var quad := ColorRect.new()
			quad.size = (EFFECTS[row]["size"] as Vector2) * TILE
			quad.position = CELL * (Vector2(column, row) + Vector2(0.5, 0.5)) - quad.size * 0.5
			quad.material = _material(EFFECTS[row]["key"], 0.137 * float(column + 1),
				INSTANTS[column % INSTANTS.size()])
			root.add_child(quad)
	get_root().size = Vector2i(int(CELL.x * columns), int(CELL.y * EFFECTS.size()))
	for i in 12:
		await process_frame
	get_root().get_texture().get_image().save_png(out)
	print("preview -> ", out)
