extends SceneTree

## Les effets du Chronomancien à plusieurs instants de leur vie, sur un sol sombre, moyen et
## clair, hors partie : ce sont des éclats trop brefs pour une capture en jeu.
##
##   godot --path . --resolution 1200x900 --script res://tools/preview_chrono.gd -- /tmp/chrono.png

const STEPS: Array[float] = [0.12, 0.3, 0.5, 0.7, 0.9]
const KEYS: Array[String] = ["chrono_tick", "chrono_rewind", "chrono_sand"]
const GROUNDS: Array[Color] = [Color(0.16, 0.13, 0.2), Color(0.5, 0.48, 0.28), Color(0.82, 0.75, 0.6)]
const CELL := Vector2(240, 100)
const SPAN := 96.0


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
				var quad := Sprite2D.new()
				quad.texture = MagicOrb.painted_quad()
				quad.material = PaintedFx.make_material(key, 0.3)
				quad.material.set_shader_parameter("progress", STEPS[step])
				quad.scale = Vector2(SPAN, SPAN)
				quad.position = Vector2(CELL.x * (step + 0.5), CELL.y * (row + 0.5))
				root.add_child(quad)
			row += 1
	get_root().size = Vector2i(int(CELL.x * STEPS.size()), int(CELL.y * row))
	for i in 10:
		await process_frame
	var out: String = args[0] if args.size() > 0 else "/tmp/chrono.png"
	get_root().get_texture().get_image().save_png(out)
	quit()
