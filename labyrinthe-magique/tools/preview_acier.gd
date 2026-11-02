extends SceneTree

## Les effets de l'Archange d'Acier à plusieurs instants de leur vie, sur un sol sombre et clair,
## hors partie : les éclats sont trop brefs pour une capture en jeu.
##
##   godot --path . --resolution 1200x900 --script res://tools/preview_acier.gd -- /tmp/acier.png

const STEPS: Array[float] = [0.1, 0.3, 0.5, 0.7, 0.9]
const KEYS: Array[String] = ["acier_impact", "acier_dash", "acier_ring", "acier_anvil", "acier_rampart", "acier_molten"]
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
	_add_drawn(root, row)
	row += 3
	get_root().size = Vector2i(int(CELL.x * STEPS.size()), int(CELL.y * row))
	for i in 10:
		await process_frame
	var out: String = args[0] if args.size() > 0 else "/tmp/acier.png"
	get_root().get_texture().get_image().save_png(out)
	quit()


## Les effets tracés : les plaques, la volée de lames, les fissures et la traînée de la Charge.
func _add_drawn(root: Node2D, row: int) -> void:
	var band := ColorRect.new()
	band.size = Vector2(CELL.x * STEPS.size(), CELL.y * 3.0)
	band.position = Vector2(0, CELL.y * row)
	band.color = GROUNDS[1]
	root.add_child(band)
	var top := CELL.y * row
	var pips := PlatePips.new()
	root.add_child(pips)
	pips.setup(64, 3)
	pips.set_count(2)
	pips.position = Vector2(70, top + 40)
	var directions := []
	for turn in [-60.0, -30.0, 0.0, 30.0, 60.0]:
		directions.append(Vector2.RIGHT.rotated(deg_to_rad(turn)))
	var volley := SteelBlades.new()
	root.add_child(volley)
	volley.setup(Vector2(180, top + 135), directions, 170.0, 64, null)
	volley._time = 0.2
	volley.set_process(false)
	var links := []
	var at := Vector2(420, top + 135)
	for i in 8:
		links.append({"from": at + Vector2(float(i) * 44.0, 0.0), "to": at + Vector2(float(i + 1) * 44.0, 0.0), "steps": 1})
		links.append({"from": at + Vector2(88.0, float(i) * 22.0 - 80.0), "to": at + Vector2(88.0, float(i + 1) * 22.0 - 80.0), "steps": 1})
	var cracks := SteelCracks.new()
	root.add_child(cracks)
	cracks.setup(links, 64)
	cracks._time = 0.2
	cracks.set_process(false)
	var wave := Sprite2D.new()
	wave.texture = MagicOrb.painted_quad()
	wave.material = MagicOrb.painted_material("onde_marteau", 0.3)
	wave.scale = Vector2(1.7, 1.05) * 64.0
	wave.position = Vector2(780, top + 60)
	root.add_child(wave)
	var trail := StarTrail.new()
	root.add_child(trail)
	trail.setup(Vector2(60, top + 240), Vector2(800, top + 240), 64, StarTrail.STEEL_COLORS)
	trail._time = 0.15
	trail.set_process(false)


func _quad(key: String, step: float, at: Vector2) -> Sprite2D:
	var quad := Sprite2D.new()
	quad.texture = MagicOrb.painted_quad()
	quad.material = PaintedFx.make_material(key, 0.3)
	quad.material.set_shader_parameter("progress", step)
	quad.scale = Vector2(SPAN, SPAN)
	quad.position = at
	return quad
