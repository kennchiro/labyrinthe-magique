extends SceneTree

## Les effets de l'Ange des Étoiles à plusieurs instants de leur vie, sur un sol sombre et clair,
## hors partie : les éclats sont trop brefs pour une capture en jeu.
##
##   godot --path . --resolution 1200x900 --script res://tools/preview_etoiles.gd -- /tmp/etoiles.png

const STEPS: Array[float] = [0.1, 0.3, 0.5, 0.7, 0.9]
const KEYS: Array[String] = ["etoiles_impact", "etoiles_ring", "etoiles_veil", "etoiles_comet", "etoiles_night"]
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
	var out: String = args[0] if args.size() > 0 else "/tmp/etoiles.png"
	get_root().get_texture().get_image().save_png(out)
	quit()


## Les effets tracés : la constellation et ses rayons, et la traînée de l'Étoile filante.
func _add_creatures(root: Node2D, row: int) -> void:
	var band := ColorRect.new()
	band.size = Vector2(CELL.x * STEPS.size(), CELL.y * 3.0)
	band.position = Vector2(0, CELL.y * row)
	band.color = GROUNDS[1]
	root.add_child(band)
	var top := CELL.y * row
	var sky := Constellation.new()
	root.add_child(sky)
	sky.setup(48)
	sky.set_points(PackedVector2Array([Vector2(70, top + 50), Vector2(320, top + 90), Vector2(170, top + 220)]))
	var trail := StarTrail.new()
	root.add_child(trail)
	trail.setup(Vector2(460, top + 130), Vector2(760, top + 130), 64)
	trail._time = 0.15
	trail.set_process(false)


func _quad(key: String, step: float, at: Vector2) -> Sprite2D:
	var quad := Sprite2D.new()
	quad.texture = MagicOrb.painted_quad()
	if false:
		quad.material = ZoneEffect.painted_material(key, 2.6, 0.3)
		quad.material.set_shader_parameter("phase", step * 4.0)
		quad.material.set_shader_parameter("life", 1.0 - step)
	else:
		quad.material = PaintedFx.make_material(key, 0.3)
		quad.material.set_shader_parameter("progress", step)
	quad.scale = Vector2(SPAN, SPAN)
	quad.position = at
	return quad
