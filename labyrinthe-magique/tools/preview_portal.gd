extends SceneTree

## Le portail dans ses trois états, sur un sol sombre, moyen et clair, hors partie.
##
##   godot --path . --resolution 960x600 --script res://tools/preview_portal.gd -- /tmp/portail.png

const SCENE := preload("res://scenes/entities/portal.tscn")
## Une case à l'écran, zoom du jeu compris : agrandie pour lire le dessin.
const TILE := 150
const GROUNDS: Array[Color] = [Color(0.16, 0.13, 0.2), Color(0.5, 0.48, 0.28), Color(0.82, 0.75, 0.6)]
const COLUMNS := 3


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
	get_root().size = Vector2i(int(cell.x * COLUMNS), int(cell.y * GROUNDS.size()))
	for i in 40:
		await process_frame
	for portal in flashes:
		portal.flash_teleport()
	for i in 6:
		await process_frame
	get_root().get_texture().get_image().save_png(out)
	print("preview -> ", out)
