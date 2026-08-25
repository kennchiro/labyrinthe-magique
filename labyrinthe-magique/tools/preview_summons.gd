extends SceneTree

## Contrôle visuel des invocations, hors partie.
##
##   godot --path . --script res://tools/preview_summons.gd -- /tmp/summons.png
##
## Instancie un SummonVisual par créature et par direction, en repos puis en
## coup, et capture la planche. C'est le seul moyen de VOIR les quatre vues du
## dragon d'un coup : en jeu il ne regarde qu'une proie à la fois.

const CELL := Vector2(150, 130)


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "/tmp/summons.png"
	# Le projet étire son rendu pour tenir sur tous les écrans (`content_scale`).
	# Ici on veut des pixels, pas une mise en page : sans cette ligne la planche
	# est dessinée à 55 % dans le coin d'une image aux bonnes dimensions.
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var root := Node2D.new()
	get_root().add_child(root)
	var background := ColorRect.new()
	background.size = Vector2(CELL.x * 8, CELL.y * 4)
	background.color = Color(0.10, 0.12, 0.16)
	root.add_child(background)

	var line := 0
	for kind in ["imp", "gargouille", "dragon", "ombre"]:
		var column := 0
		for facing in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
			for striking in [false, true]:
				var visual := SummonVisual.new()
				root.add_child(visual)
				visual.setup(kind, 32)
				visual.set_facing(facing)
				if striking:
					visual.flash_strike()
				visual.position = Vector2(CELL.x * (column + 0.5),
					CELL.y * (line + 0.5) + 40.0)
				column += 1
		line += 1

	get_root().size = Vector2i(int(CELL.x * 8), int(CELL.y * 4))
	await process_frame
	await process_frame
	var image := get_root().get_texture().get_image()
	image.save_png(out)
	print("preview -> ", out)
	quit()
