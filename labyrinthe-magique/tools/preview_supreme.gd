extends SceneTree

## Les effets du Sorcier Suprême, par matière, sur sol sombre et sur sol clair.
##
##   godot --path . --resolution 1200x1000 --script res://tools/preview_supreme.gd -- /tmp/supreme.png
##
## Trois rangées par élément (feu, eau, terre, air, puis terre et air sur sol clair), et
## une dernière pour les sorts qui mêlent les quatre.

const TILE := 40.0
const CELL := Vector2(200, 200)
const DARK := Color(0.16, 0.13, 0.2)
const LIGHT := Color(0.82, 0.75, 0.6)
const COLUMNS: Array[Dictionary] = [
	{"kind": 0, "ground": DARK}, {"kind": 1, "ground": DARK}, {"kind": 2, "ground": DARK},
	{"kind": 3, "ground": DARK}, {"kind": 2, "ground": LIGHT}, {"kind": 3, "ground": LIGHT},
]
const BY_KIND: Array[Dictionary] = [
	{"key": "trait_prisme", "progress": 0.5},
	{"key": "prism_star", "size": Vector2(3.2, 3.2), "progress": 0.42},
	{"key": "meteore_jugement", "progress": 0.5},
]
const MIXED: Array[Dictionary] = [
	{"key": "convergence_peinte", "progress": 0.5},
	{"key": "convergence_burst", "size": Vector2(3.2, 3.2), "progress": 0.3},
	{"key": "prism_shift", "size": Vector2(2.5, 2.5), "progress": 0.3},
	{"key": "judgement_burst", "size": Vector2(4.5, 4.5), "progress": 0.35},
	{"key": "rebirth_aura", "size": Vector2(3.0, 3.6), "progress": 0.5},
]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var root := Node2D.new()
	get_root().add_child(root)
	var rows := BY_KIND.size() + 1
	for column in COLUMNS.size():
		var band := ColorRect.new()
		band.size = Vector2(CELL.x, CELL.y * rows)
		band.position = Vector2(CELL.x * column, 0)
		band.color = COLUMNS[column]["ground"]
		root.add_child(band)
		for row in BY_KIND.size():
			root.add_child(_quad(BY_KIND[row], column, row, COLUMNS[column]["kind"]))
	for column in MIXED.size():
		root.add_child(_quad(MIXED[column], column, BY_KIND.size(), 0))
	get_root().size = Vector2i(int(CELL.x * COLUMNS.size()), int(CELL.y * rows))
	for i in 12:
		await process_frame
	var out: String = args[0] if args.size() > 0 else "/tmp/supreme.png"
	get_root().get_texture().get_image().save_png(out)
	print("preview -> ", out)
	quit()


func _quad(effect: Dictionary, column: int, row: int, kind: int) -> ColorRect:
	var key: String = effect["key"]
	var shaded: ShaderMaterial
	var tiles: Vector2 = effect.get("size", Vector2.ONE)
	if MagicOrb.PAINTED.has(key):
		shaded = MagicOrb.painted_material(key, 0.31)
		var look: Dictionary = MagicOrb.PAINTED[key]
		tiles = Vector2(look["length"], look["height"])
	else:
		shaded = PaintedFx.make_material(key, 0.31)
	shaded.set_shader_parameter("kind", kind)
	shaded.set_shader_parameter("progress", effect["progress"])
	var quad := ColorRect.new()
	quad.size = tiles * TILE
	quad.position = CELL * (Vector2(column, row) + Vector2(0.5, 0.5)) - quad.size * 0.5
	quad.material = shaded
	return quad
