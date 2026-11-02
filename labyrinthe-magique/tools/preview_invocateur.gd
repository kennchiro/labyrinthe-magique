extends SceneTree

## L'impact et la fuite de l'Invocateur, à six instants, sur un sol sombre et un sol clair.
##
##   godot --path . --resolution 1200x800 --script res://tools/preview_invocateur.gd -- /tmp/invocateur.png

const TILE := 32.0
const CELL := Vector2(200, 200)
const GROUNDS: Array[Color] = [Color(0.16, 0.13, 0.2), Color(0.82, 0.75, 0.6)]
const INSTANTS: Array[float] = [0.08, 0.2, 0.4, 0.6, 0.75, 0.92]
const EFFECTS: Array[String] = ["arcane_sigil", "arcane_void_step"]
## Le quad d'un éclat de rayon 1, et trois fois la taille pour lire le dessin.
const SPAN := 2.5 * TILE * 2.0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	await _sheet(args[0] if args.size() > 0 else "/tmp/invocateur.png")
	quit()


func _sheet(out: String) -> void:
	var root := Node2D.new()
	get_root().add_child(root)
	var rows := GROUNDS.size() * EFFECTS.size()
	for row in rows:
		var band := ColorRect.new()
		band.size = Vector2(CELL.x * INSTANTS.size(), CELL.y)
		band.position = Vector2(0, CELL.y * row)
		band.color = GROUNDS[row / EFFECTS.size()]
		root.add_child(band)
		for column in INSTANTS.size():
			var quad := ColorRect.new()
			quad.size = Vector2(SPAN, SPAN)
			quad.position = CELL * (Vector2(column, row) + Vector2(0.5, 0.5)) - quad.size * 0.5
			var shaded := PaintedFx.make_material(EFFECTS[row % EFFECTS.size()], 0.137)
			shaded.set_shader_parameter("progress", INSTANTS[column])
			quad.material = shaded
			root.add_child(quad)
	get_root().size = Vector2i(int(CELL.x * INSTANTS.size()), int(CELL.y * rows))
	for i in 12:
		await process_frame
	get_root().get_texture().get_image().save_png(out)
	print("preview -> ", out)
