extends SceneTree

## Les effets de la Foudre, à plusieurs instants, sur un sol sombre et un sol clair.
##
##   godot --path . --resolution 1440x1250 --script res://tools/preview_thunder.gd -- /tmp/foudre.png
##   godot --path . --resolution 1280x720 --script res://tools/preview_thunder.gd -- --bench
##
## ⚠️ Le nuage ne s'éclaire qu'un dixième du temps : une seule capture ne montre presque
## jamais ses veines. Sa rangée garde donc, case par case, l'image la plus zébrée.

const TILE := 32.0
const CELL := Vector2(240, 250)
const GROUNDS: Array[Color] = [Color(0.16, 0.13, 0.2), Color(0.82, 0.75, 0.6)]
const INSTANTS: Array[float] = [0.12, 0.35, 0.6]
## Les tailles que le jeu leur donne, en cases.
const EFFECTS: Array[Dictionary] = [
	{"key": "thunder_strike", "size": Vector2(2.5, 2.5)},
	{"key": "thunder_crest", "size": Vector2(7.5, 7.5)},
	{"key": "field", "size": Vector2(4.8, 4.8)},
	{"key": "thunder_storm", "size": Vector2(2.6, 1.7)},
	{"key": "thunder_cloud", "size": Vector2(3.0, 1.9)},
]
## Assez de quads pour que le coût dépasse le bruit de la mesure.
const BENCH_COUNT := 200


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	if "--bench" in args:
		await _bench()
	else:
		await _sheet(args[0] if args.size() > 0 else "/tmp/foudre.png")
	quit()


func _material(key: String, seed_value: float) -> ShaderMaterial:
	if key == "field":
		var field := ShaderMaterial.new()
		field.shader = load("res://assets/shaders/field.gdshader")
		field.set_shader_parameter("noise", PaintedFx.THUNDER_NOISE)
		return field
	if MagicOrb.PAINTED.has(key):
		return MagicOrb.painted_material(key, seed_value)
	return PaintedFx.make_material(key, seed_value)


func _quad(effect: Dictionary, at: Vector2, seed_value: float, progress: float) -> ColorRect:
	var quad := ColorRect.new()
	var look: Dictionary = MagicOrb.PAINTED.get(effect["key"], {})
	var tiles: Vector2 = Vector2(look["length"], look["height"]) if look else effect["size"]
	quad.size = tiles * TILE
	quad.position = at - quad.size * 0.5
	var shaded := _material(effect["key"], seed_value)
	shaded.set_shader_parameter("progress", progress)
	shaded.set_shader_parameter("phase", 0.3 + progress * 12.0)
	shaded.set_shader_parameter("life", 1.0 - progress)
	shaded.set_shader_parameter("flash", 1.0 if progress > 0.5 else 0.0)
	quad.material = shaded
	return quad


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
			var at := CELL * (Vector2(column, row) + Vector2(0.5, 0.5))
			var progress := INSTANTS[column % INSTANTS.size()]
			root.add_child(_quad(EFFECTS[row], at, 0.137 * float(column + 1), progress))
	get_root().size = Vector2i(int(CELL.x * columns), int(CELL.y * EFFECTS.size()))
	for i in 12:
		await process_frame
	var sheet := get_root().get_texture().get_image()
	# Le nuage : soixante images à la cadence de ses éclairs, la plus zébrée par case.
	var cloud_row := EFFECTS.size() - 1
	var best: Array[int] = []
	best.resize(columns)
	for i in 60:
		await create_timer(1.0 / 7.0).timeout
		await process_frame
		var shot := get_root().get_texture().get_image()
		for column in columns:
			var box := Rect2i(Vector2i(CELL * Vector2(column, cloud_row)), Vector2i(CELL))
			var lit := _lit_pixels(shot, box)
			if lit > best[column]:
				best[column] = lit
				sheet.blit_rect(shot, box, box.position)
	sheet.save_png(out)
	print("preview -> ", out, " | veines par case : ", best)


func _lit_pixels(image: Image, box: Rect2i) -> int:
	var lit := 0
	# Le fond clair ressort aussi : seul le pixel presque blanc et bleuté compte.
	for y in range(box.position.y, box.end.y, 2):
		for x in range(box.position.x, box.end.x, 2):
			var pixel := image.get_pixel(x, y)
			if pixel.r > 0.8 and pixel.b > 0.9:
				lit += 1
	return lit


func _measure() -> float:
	for i in 20:
		await process_frame
	var start := Time.get_ticks_usec()
	var frames := 180
	for i in frames:
		await process_frame
	return float(Time.get_ticks_usec() - start) / 1000.0 / float(frames)


func _bench() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var view := Vector2(get_root().size)
	var empty := await _measure()
	print("à vide : %.2f ms" % empty)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for effect in EFFECTS:
		var root := Node2D.new()
		get_root().add_child(root)
		for i in BENCH_COUNT:
			var at := Vector2(rng.randf() * view.x, rng.randf() * view.y)
			root.add_child(_quad(effect, at, rng.randf(), 0.3))
		print("%s x%d : %.2f ms" % [effect["key"], BENCH_COUNT, await _measure() - empty])
		root.queue_free()
		await process_frame
