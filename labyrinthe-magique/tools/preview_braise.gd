extends SceneTree

## Les effets du Roi de Braise à plusieurs instants de leur vie, sur un sol sombre et clair, hors
## partie : les éclats sont trop brefs pour une capture en jeu.
##
##   godot --path . --resolution 1080x1980 --script res://tools/preview_braise.gd -- /tmp/braise.png

const STEPS: Array[float] = [0.06, 0.18, 0.32, 0.48, 0.68, 0.9]
const KEYS: Array[String] = ["braise_choc", "braise_saut", "braise_fissure", "braise_gueule", "braise_rappel",
	"braise_explosion", "braise_sceau", "braise_colonne", "braise_voile", "braise_onde"]
const GROUNDS: Array[Color] = [Color(0.16, 0.13, 0.2), Color(0.42, 0.5, 0.3)]
const CELL := Vector2(180, 180)
const SPAN := 170.0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	await process_frame
	var root := Node2D.new()
	get_root().add_child(root)
	for row in KEYS.size():
		var band := ColorRect.new()
		band.size = Vector2(CELL.x * STEPS.size(), CELL.y)
		band.position = Vector2(0, CELL.y * row)
		band.color = GROUNDS[row % 2]
		root.add_child(band)
		for step in STEPS.size():
			var quad := Sprite2D.new()
			quad.texture = MagicOrb.painted_quad()
			var shaded := PaintedBurst.make_material(KEYS[row], 0.4 + float(step) * 0.1, 2.0)
			shaded.set_shader_parameter("progress", STEPS[step])
			quad.material = shaded
			quad.scale = Vector2(SPAN, SPAN)
			quad.position = Vector2(CELL.x * (step + 0.5), CELL.y * (row + 0.5))
			root.add_child(quad)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png(args[0] if not args.is_empty() else "/tmp/braise.png")
	quit()
