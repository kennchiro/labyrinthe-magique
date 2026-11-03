extends SceneTree

## Les effets du Chérubin à six instants de leur vie, sur un sol sombre et clair, hors
## partie : les éclats sont trop brefs pour une capture en jeu. Deux planches, pour qu'elles
## restent lisibles :
##
##   godot --path . --resolution 1080x1620 --script res://tools/preview_cherubin.gd -- /tmp/cherubin_1.png 1
##   godot --path . --resolution 1080x1620 --script res://tools/preview_cherubin.gd -- /tmp/cherubin_2.png 2

const STEPS: Array[float] = [0.06, 0.18, 0.32, 0.5, 0.7, 0.9]
const SHEETS := {
	"1": ["cherubin_choc", "cherubin_eclair", "cherubin_trainee", "cherubin_oeil", "cherubin_embrasement",
		"cherubin_tournoyant", "cherubin_coupe"],
	"2": ["cherubin_roue", "cherubin_voile", "cherubin_rejet", "cherubin_jardin", "cherubin_epee",
		"cherubin_nuit"],
}
## Ce qui se dresse se dessine dans un quad haut ou plat : (largeur, hauteur) en part de la case.
const TALL := {"cherubin_epee": Vector2(0.45, 1.0), "cherubin_oeil": Vector2(0.62, 0.42),
	"cherubin_embrasement": Vector2(0.7, 1.0)}
const GROUNDS: Array[Color] = [Color(0.14, 0.17, 0.15), Color(0.62, 0.66, 0.5)]
const CELL := Vector2(180, 180)
const SPAN := 170.0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var keys: Array = SHEETS.get(args[1] if args.size() > 1 else "1", SHEETS["1"])
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	await process_frame
	var root := Node2D.new()
	get_root().add_child(root)
	for row in keys.size():
		var band := ColorRect.new()
		band.size = Vector2(CELL.x * STEPS.size(), CELL.y)
		band.position = Vector2(0, CELL.y * row)
		band.color = GROUNDS[row % 2]
		root.add_child(band)
		for step in STEPS.size():
			var quad := Sprite2D.new()
			quad.texture = MagicOrb.painted_quad()
			var shaded := PaintedBurst.make_material(keys[row], 0.4 + float(step) * 0.1, 2.0)
			shaded.set_shader_parameter("progress", STEPS[step])
			quad.material = shaded
			quad.scale = TALL.get(keys[row], Vector2.ONE) * SPAN
			quad.position = Vector2(CELL.x * (step + 0.5), CELL.y * (row + 0.5))
			root.add_child(quad)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png(args[0] if not args.is_empty() else "/tmp/cherubin.png")
	quit()
