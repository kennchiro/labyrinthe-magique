extends SceneTree

## Les effets de la Démone de la Discorde à plusieurs instants de leur vie, sur un sol sombre et clair, hors
## partie : les éclats sont trop brefs pour une capture en jeu.
##
##   godot --path . --resolution 1080x1440 --script res://tools/preview_discorde.gd -- /tmp/discorde.png

const STEPS: Array[float] = [0.08, 0.2, 0.32, 0.46, 0.62, 0.82]
const KEYS: Array[String] = ["discorde_noeud", "discorde_oeil", "discorde_echange", "discorde_grande"]
const GROUNDS: Array[Color] = [Color(0.16, 0.13, 0.2), Color(0.42, 0.5, 0.3)]
const CELL := Vector2(180, 180)
const SPAN := 170.0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	await process_frame
	var root := Node2D.new()
	get_root().add_child(root)
	var row := 0
	for key in KEYS:
		for ground in [GROUNDS[row % 2]]:
			var band := ColorRect.new()
			band.size = Vector2(CELL.x * STEPS.size(), CELL.y)
			band.position = Vector2(0, CELL.y * row)
			band.color = ground
			root.add_child(band)
			for step in STEPS.size():
				root.add_child(_quad(key, STEPS[step], Vector2(CELL.x * (step + 0.5), CELL.y * (row + 0.5))))
			row += 1
	# Le projectile, couché dans le sens de son vol, sur les deux sols.
	for ground in GROUNDS.size():
		var band := ColorRect.new()
		band.size = Vector2(CELL.x * STEPS.size(), CELL.y)
		band.position = Vector2(0, CELL.y * row)
		band.color = GROUNDS[ground]
		root.add_child(band)
		var thread := Sprite2D.new()
		thread.texture = MagicOrb.painted_quad()
		thread.material = MagicOrb.painted_material("fil_murmure", 0.3)
		thread.scale = Vector2(MagicOrb.PAINTED["fil_murmure"]["length"], MagicOrb.PAINTED["fil_murmure"]["height"]) * 64.0
		thread.position = Vector2(CELL.x * 0.5, CELL.y * (row + 0.5))
		root.add_child(thread)
		row += 1
	# Le cercle est une zone : il lit `phase` et `life`, et non `progress`.
	var circle_band := ColorRect.new()
	circle_band.size = Vector2(CELL.x * STEPS.size(), CELL.y)
	circle_band.position = Vector2(0, CELL.y * row)
	circle_band.color = GROUNDS[0]
	root.add_child(circle_band)
	for step in STEPS.size():
		var shaded := ZoneEffect.painted_material("toile_peinte", 2.5, 0.3)
		shaded.set_shader_parameter("phase", STEPS[step] * 6.0)
		shaded.set_shader_parameter("life", 1.0 - STEPS[step])
		var zone := Sprite2D.new()
		zone.texture = MagicOrb.painted_quad()
		zone.material = shaded
		zone.scale = Vector2(SPAN, SPAN)
		zone.position = Vector2(CELL.x * (step + 0.5), CELL.y * (row + 0.5))
		root.add_child(zone)
	row += 1
	get_root().size = Vector2i(int(CELL.x * STEPS.size()), int(CELL.y * row))
	for i in 10:
		await process_frame
	var out: String = args[0] if args.size() > 0 else "/tmp/discorde.png"
	get_root().get_texture().get_image().save_png(out)
	quit()


func _quad(key: String, step: float, at: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = MagicOrb.painted_quad()
	var shaded := PaintedFx.make_material(key, 0.3)
	shaded.set_shader_parameter("progress", step)
	shaded.set_shader_parameter("solid", 0.0)
	sprite.material = shaded
	sprite.scale = Vector2(SPAN, SPAN)
	sprite.position = at
	return sprite
