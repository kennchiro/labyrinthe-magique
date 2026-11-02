extends SceneTree

## Contrôle visuel du gabarit d'animation : la course et le coup, image par image, sur une
## planche. Une capture en jeu ne tombe jamais sur le bon instant d'un geste de 0,3 s.
##   godot --path . --resolution 1320x700 --script res://tools/preview_motion.gd -- /tmp/motion.png [personnage]

const PLAYER_SCENE := preload("res://scenes/entities/player.tscn")
const TILE := 32
const FRAME := 1.0 / 60.0
const COLUMNS := 11
const BOX := Vector2i(120, 100)
const ZOOM := 1.6
## Une rangée par situation : (direction de course, direction du coup).
const ROWS: Array[Array] = [
	[Vector2.RIGHT, Vector2i.ZERO],
	[Vector2.ZERO, Vector2i.RIGHT],
	[Vector2.ZERO, Vector2i.DOWN],
	[Vector2.ZERO, Vector2i.UP],
	[Vector2.ZERO, Vector2i.LEFT],
]
## Écart entre deux vignettes, en images à 60 par seconde.
const STEP_RUN := 2
const STEP_STRIKE := 2


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var path := "/tmp/motion.png"
	if not OS.get_cmdline_user_args().is_empty():
		path = OS.get_cmdline_user_args()[0]
	var sheet := Image.create(COLUMNS * BOX.x, ROWS.size() * BOX.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#3a4a3f"))
	RenderingServer.set_default_clear_color(Color("#3a4a3f"))
	for row in ROWS.size():
		await _capture_row(sheet, row, ROWS[row][0], ROWS[row][1])
	sheet.save_png(path)
	print("  ", path)
	quit(0)


func _capture_row(sheet: Image, row: int, run: Vector2, strike: Vector2i) -> void:
	var grid := MazeGrid.new(60, 9)
	for y in range(1, 8):
		for x in range(1, 59):
			grid.set_cell(x, y, MazeGrid.Cell.FLOOR)
	var player: Player = PLAYER_SCENE.instantiate()
	var args := OS.get_cmdline_user_args()
	player.set_character(CharacterCatalog.by_id(args[1] if args.size() > 1 else CharacterCatalog.TEST))
	var holder := Node2D.new()
	root.add_child(holder)
	holder.add_child(player)
	player.setup(grid, Vector2i(2, 4), 5.1, TILE)
	# Le moteur le fait avancer tout seul : c'est la vignette qui le suit.
	player.set_process(false)
	player.debug_direction = run
	for i in 20:
		player._process(FRAME)
	if strike != Vector2i.ZERO:
		var aim := player.position + Vector2(strike) * float(TILE) * 3.0
		player.play_cast(aim)
	var view := root.get_visible_rect().size
	for column in COLUMNS:
		holder.scale = Vector2(ZOOM, ZOOM)
		holder.position = view * 0.5 - player.position * ZOOM + Vector2(0.0, 28.0)
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		image.convert(Image.FORMAT_RGBA8)
		var corner := Vector2i(view * 0.5) - BOX / 2
		sheet.blit_rect(image, Rect2i(corner, BOX), Vector2i(column * BOX.x, row * BOX.y))
		for i in STEP_RUN if run != Vector2.ZERO else STEP_STRIKE:
			player._process(FRAME)
		# L'arc avance tout seul d'une image par vignette : on lui donne le reste.
		for child in player.get_children():
			if child is SlashArc:
				child._process(FRAME * float(STEP_STRIKE - 1))
	holder.queue_free()
	await process_frame
