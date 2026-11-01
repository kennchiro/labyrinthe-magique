extends SceneTree

## Le portail dans ses trois états, sur un sol sombre, moyen et clair, hors partie, puis
## l'éclat du saut à cinq instants de sa vie et la flèche de la boussole.
##
##   godot --path . --resolution 960x1000 --script res://tools/preview_portal.gd -- /tmp/portail.png

const SCENE := preload("res://scenes/entities/portal.tscn")
## Une case à l'écran, zoom du jeu compris : agrandie pour lire le dessin.
const TILE := 150
const GROUNDS: Array[Color] = [Color(0.16, 0.13, 0.2), Color(0.5, 0.48, 0.28), Color(0.82, 0.75, 0.6)]
const COLUMNS := 3
const BURST_SCENE := preload("res://scenes/entities/teleport_effect.tscn")
const COMPASS_SCENE := preload("res://scenes/ui/compass.tscn")
const BURST_STEPS: Array[float] = [0.05, 0.25, 0.45, 0.65, 0.85]
const GEM_TINTS: Array[Color] = [Color("#8fe6ff"), Color("#4f7fe0"), Color("#a05cff"), Color("#ffd479")]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	# Le nœud du portail n'attrape son Sprite2D qu'une fois l'arbre lancé.
	await process_frame
	await _sheet(args[0] if args.size() > 0 else "/tmp/portail.png")
	quit()


func _sheet(out: String) -> void:
	var root := Node2D.new()
	get_root().add_child(root)
	var cell := Vector2(320, 200)
	var flashes: Array[Portal] = []
	for row in GROUNDS.size():
		var band := ColorRect.new()
		band.size = Vector2(cell.x * COLUMNS, cell.y)
		band.position = Vector2(0, cell.y * row)
		band.color = GROUNDS[row]
		root.add_child(band)
		for column in COLUMNS:
			var portal: Portal = SCENE.instantiate()
			root.add_child(portal)
			portal.position = Vector2(cell.x * (column + 0.5), cell.y * (row + 0.5))
			portal.setup(Vector2i.ZERO, TILE, float(row) * 0.9, row + column)
			portal.highlighted = column == 1
			if column == 2:
				flashes.append(portal)
	var bursts := Vector2(cell.x * COLUMNS / 6.0, cell.y)
	for row in 2:
		var ground := GROUNDS[row * 2]
		var band := ColorRect.new()
		band.size = Vector2(cell.x * COLUMNS, bursts.y)
		band.position = Vector2(0, cell.y * (GROUNDS.size() + row))
		band.color = ground
		root.add_child(band)
		var y := band.position.y + bursts.y * 0.5
		for step in BURST_STEPS.size():
			var effect: TeleportEffect = BURST_SCENE.instantiate()
			root.add_child(effect)
			effect.position = Vector2(bursts.x * (step + 0.5), y)
			effect.setup(64, GEM_TINTS[0], 1.3)
			effect.set_process(false)
			effect.sprite.material.set_shader_parameter("progress", BURST_STEPS[step])
		for tint in GEM_TINTS.size():
			var compass: Compass = COMPASS_SCENE.instantiate()
			root.add_child(compass)
			compass.setup(64)
			var at := Vector2(bursts.x * 5.25 + tint % 2 * 70.0, y - 40.0 + (tint / 2) * 80.0)
			compass.point_to(at - Vector2.RIGHT * 99.2, at + Vector2.RIGHT * 200.0, GEM_TINTS[tint])
	get_root().size = Vector2i(int(cell.x * COLUMNS), int(cell.y * (GROUNDS.size() + 2)))
	for i in 40:
		await process_frame
	for portal in flashes:
		portal.flash_teleport()
	for i in 6:
		await process_frame
	get_root().get_texture().get_image().save_png(out)
	print("preview -> ", out)
