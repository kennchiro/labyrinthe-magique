extends SceneTree

## Les effets de l'Ange de la Mort à plusieurs instants de leur vie, sur un sol sombre et clair,
## hors partie : les éclats sont trop brefs pour une capture en jeu.
##
##   godot --path . --resolution 1200x900 --script res://tools/preview_mort.gd -- /tmp/mort.png

const STEPS: Array[float] = [0.1, 0.3, 0.5, 0.7, 0.9]
const KEYS: Array[String] = ["mort_cut", "mort_sweep", "mort_feathers", "mort_hour", "glas_peint"]
const GROUNDS: Array[Color] = [Color(0.16, 0.13, 0.2), Color(0.82, 0.75, 0.6)]
const CELL := Vector2(180, 90)
const SPAN := 88.0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	await process_frame
	var root := Node2D.new()
	get_root().add_child(root)
	var row := 0
	for key in KEYS:
		for ground in GROUNDS:
			var band := ColorRect.new()
			band.size = Vector2(CELL.x * STEPS.size(), CELL.y)
			band.position = Vector2(0, CELL.y * row)
			band.color = ground
			root.add_child(band)
			for step in STEPS.size():
				root.add_child(_quad(key, STEPS[step], Vector2(CELL.x * (step + 0.5), CELL.y * (row + 0.5))))
			row += 1
	_add_creatures(root, row)
	row += 3
	get_root().size = Vector2i(int(CELL.x * STEPS.size()), int(CELL.y * row))
	for i in 10:
		await process_frame
	var out: String = args[0] if args.size() > 0 else "/tmp/mort.png"
	get_root().get_texture().get_image().save_png(out)
	quit()


## Les effets tracés : une âme en chasse, les âmes autour du mage, le Passage et la cloche.
func _add_creatures(root: Node2D, row: int) -> void:
	var band := ColorRect.new()
	band.size = Vector2(CELL.x * STEPS.size(), CELL.y * 3.0)
	band.position = Vector2(0, CELL.y * row)
	band.color = GROUNDS[0]
	root.add_child(band)
	var top := CELL.y * row
	var wisp := SoulWisp.new()
	root.add_child(wisp)
	wisp.setup(PackedVector2Array([Vector2(40, top + 60), Vector2(160, top + 60), Vector2(160, top + 200)]), 64, 10.0)
	wisp._time = 3.8
	wisp.set_process(false)
	var orbit := SoulOrbit.new()
	root.add_child(orbit)
	orbit.setup(64)
	orbit.position = Vector2(320, top + 130)
	orbit.set_count(3)
	var passage := DeathPassage.new()
	root.add_child(passage)
	passage.setup(Vector2(460, top + 130), Vector2(640, top + 130), 64)
	passage._time = 0.24
	passage.set_process(false)
	var bell := TollingBell.new()
	root.add_child(bell)
	bell.position = Vector2(800, top + 200)
	bell.setup(64, 10.0)
	bell._time = 1.8


func _quad(key: String, step: float, at: Vector2) -> Sprite2D:
	var quad := Sprite2D.new()
	quad.texture = MagicOrb.painted_quad()
	if key == "glas_peint":
		quad.material = ZoneEffect.painted_material(key, 2.6, 0.3)
		quad.material.set_shader_parameter("phase", step * 4.0)
		quad.material.set_shader_parameter("life", 1.0 - step)
	else:
		quad.material = PaintedFx.make_material(key, 0.3)
		quad.material.set_shader_parameter("progress", step)
	quad.scale = Vector2(SPAN, SPAN)
	quad.position = at
	return quad
