extends SceneTree

## La Lance solaire à plusieurs instants, sur un trajet à virages, sur sol sombre et sol clair :
## l'effet dure moins d'une seconde, une capture en jeu tombe rarement au bon moment.
##
##   godot --path . --resolution 1500x640 --script res://tools/preview_lance.gd -- /tmp/lance.png

const TIMES: Array[float] = [0.08, 0.2, 0.34, 0.55, 0.8]
const GROUNDS: Array[Color] = [Color(0.16, 0.13, 0.2), Color(0.82, 0.75, 0.6)]
const CELL := Vector2(300, 320)
const TILE := 32
const ROUTE: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
	Vector2i(3, 1), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2), Vector2i(6, 3),
	Vector2i(6, 4), Vector2i(5, 4), Vector2i(4, 4), Vector2i(3, 4)]
const HITS: Array[int] = [5, 11]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	await process_frame
	var root := Node2D.new()
	get_root().add_child(root)
	var beams: Array[LightBeam] = []
	for row in GROUNDS.size():
		var band := ColorRect.new()
		band.size = Vector2(CELL.x * TIMES.size(), CELL.y)
		band.position = Vector2(0, CELL.y * row)
		band.color = GROUNDS[row]
		root.add_child(band)
		for column in TIMES.size():
			var origin := Vector2(CELL.x * column + 40.0, CELL.y * row + 70.0)
			var points := PackedVector2Array()
			for cell in ROUTE:
				points.append(origin + Vector2(cell) * float(TILE))
			var beam := LightBeam.new()
			root.add_child(beam)
			beam.setup(points, HITS, TILE)
			beam.set_process(false)
			beam.show_at(TIMES[column])
			beams.append(beam)
	get_root().size = Vector2i(int(CELL.x * TIMES.size()), int(CELL.y * GROUNDS.size()))
	for i in 10:
		await process_frame
	var out: String = args[0] if args.size() > 0 else "/tmp/lance.png"
	get_root().get_texture().get_image().save_png(out)
	quit()
