extends SceneTree

## Les effets du Seigneur du Fléau (Éveil du Mage de la Peste) à six instants de leur vie, sur un sol sombre et
## clair, hors partie. Trois planches :
##
##   godot --path . --resolution 1080x1080 --script res://tools/preview_fleau.gd -- /tmp/fleau_1.png 1
##
## Le miasme et la flaque bougent avec TIME, figés ici. Les corbeaux (`PlagueCrows`) se voient en jeu.

const STEPS: Array[float] = [0.06, 0.18, 0.32, 0.5, 0.7, 0.9]
const SHEETS := {
	"1": ["fleau_charge", "fleau_eveil", "fleau_miasme", "fleau_fin", "crachat_fleau", "fleau_gerbe"],
	"2": ["fleau_flaque", "fleau_saut", "fleau_crane", "fleau_saignee", "fleau_soin", "fleau_plumes"],
	"3": ["fleau_tourbillon", "fleau_ciel"],
}
## Ce qui s'étire se dessine dans un quad plat ou haut : (largeur, hauteur) en part de la case.
const TALL := {"crachat_fleau": Vector2(1.0, 0.43), "fleau_saut": Vector2(1.0, 0.3)}
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
			var key: String = keys[row]
			var shaded: ShaderMaterial
			if MagicOrb.PAINTED.has(key):
				shaded = MagicOrb.painted_material(key, 0.4 + float(step) * 0.1)
			elif ZoneEffect.PAINTED_STYLES.has(key):
				shaded = ZoneEffect.painted_material(key, 0.5, 0.4 + float(step) * 0.1)
				shaded.set_shader_parameter("phase", STEPS[step] * 3.0)
				shaded.set_shader_parameter("life", 1.0 - STEPS[step])
			else:
				shaded = PaintedBurst.make_material(key, 0.4 + float(step) * 0.1, 2.0)
			shaded.set_shader_parameter("progress", STEPS[step])
			shaded.set_shader_parameter("fill", STEPS[step] * 1.25)
			quad.material = shaded
			quad.scale = TALL.get(key, Vector2.ONE) * SPAN
			quad.position = Vector2(CELL.x * (step + 0.5), CELL.y * (row + 0.5))
			root.add_child(quad)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png(args[0] if not args.is_empty() else "/tmp/fleau.png")
	quit()
