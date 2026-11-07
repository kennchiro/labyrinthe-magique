extends SceneTree

## Contrôle visuel des coups ennemis, hors partie.
##
##   godot --path . --resolution 1380x1300 --script res://tools/preview_foe_strikes.gd -- /tmp/coups.png
##
## Une ligne par créature : l'armement, puis le coup à trois instants. En jeu, le coup d'un
## boss dure trois quarts de seconde et n'arrive que s'il est collé au mage : aucune capture
## n'y tombe à coup sûr.

const CELL := Vector2(170, 170)
const TILE := 32
const MOMENTS := [0.12, 0.3, 0.55]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "/tmp/coups.png"
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var root := Node2D.new()
	get_root().add_child(root)
	var species: Array = FoeStrike.STYLES.keys()
	var frozen: Array = []
	var columns := 8
	var rows := ceili(float(species.size()) / 2.0)
	var background := ColorRect.new()
	background.size = Vector2(CELL.x * columns, CELL.y * rows)
	# Un sol clair : c'est là qu'un aplat pâle se perd.
	background.color = Color(0.55, 0.5, 0.42)
	root.add_child(background)
	for index in species.size():
		var id: String = species[index]
		var left := 4 * (index % 2)
		var top := index / 2
		var holder := Node2D.new()
		root.add_child(holder)
		var stand := Node2D.new()
		holder.add_child(stand)
		stand.position = _at(left, top)
		frozen.append([FoeStrike.charge(stand, id, 1.0, TILE), 0.6])
		for moment in MOMENTS.size():
			var fx := FoeStrike.strike(holder, id, _at(left + 1 + moment, top) + Vector2(0, -TILE),
				Vector2i.DOWN, TILE)
			frozen.append([fx, MOMENTS[moment]])
		var label := Label.new()
		label.text = id
		label.position = _at(left, top) + Vector2(-CELL.x * 0.45, CELL.y * 0.32)
		root.add_child(label)
	get_root().size = Vector2i(int(CELL.x * columns), int(CELL.y * rows))
	# Une image d'abord : le traitement des nœuds s'allume à leur entrée, et le figer avant
	# ne sert à rien. Mesuré, les trois instants sortaient identiques.
	await process_frame
	for pair: Array in frozen:
		_freeze(pair[0], pair[1])
	await process_frame
	await process_frame
	get_root().get_texture().get_image().save_png(out)
	print("preview -> ", out)
	quit()


func _at(column: int, row: int) -> Vector2:
	return Vector2(CELL.x * (column + 0.5), CELL.y * (row + 0.5))


func _freeze(fx: FoeStrike, progress: float) -> void:
	fx.set_process(false)
	(fx.get_child(0) as Sprite2D).material.set_shader_parameter("progress", progress)
