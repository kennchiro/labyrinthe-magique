extends SceneTree

## Les effets du Porte-Lumière à plusieurs instants de leur vie, sur un sol sombre et clair,
## hors partie : les éclats sont trop brefs pour une capture en jeu.
##
##   godot --path . --resolution 1200x900 --script res://tools/preview_lumiere.gd -- /tmp/lumiere.png

const STEPS: Array[float] = [0.1, 0.3, 0.5, 0.7, 0.9]
const KEYS: Array[String] = ["lumiere_star", "lumiere_wings", "lumiere_ring", "lumiere_feathers",
	"lumiere_column", "lumiere_dawn", "sanctuaire_peint"]
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
	get_root().size = Vector2i(int(CELL.x * STEPS.size()), int(CELL.y * row))
	for i in 10:
		await process_frame
	var out: String = args[0] if args.size() > 0 else "/tmp/lumiere.png"
	get_root().get_texture().get_image().save_png(out)
	quit()


func _quad(key: String, step: float, at: Vector2) -> Sprite2D:
	var quad := Sprite2D.new()
	quad.texture = MagicOrb.painted_quad()
	if key == "sanctuaire_peint":
		quad.material = ZoneEffect.painted_material(key, 2.4, 0.3)
		quad.material.set_shader_parameter("phase", step * 4.0)
		quad.material.set_shader_parameter("life", 1.0 - step)
	else:
		quad.material = PaintedFx.make_material(key, 0.3)
		quad.material.set_shader_parameter("progress", step)
	quad.scale = Vector2(SPAN, SPAN)
	quad.position = at
	return quad
