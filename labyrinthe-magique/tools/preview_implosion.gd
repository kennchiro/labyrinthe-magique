extends SceneTree

## Contrôle visuel de l'implosion d'ombre, hors partie.
##
##   godot --path . --resolution 1440x300 --script res://tools/preview_implosion.gd -- /tmp/implosion.png
##
## L'effet dure deux tiers de seconde : en jeu il est impossible de le juger,
## et le chasser à la frame près avec `--frames` ne marche pas — le mage n'est
## pas au même endroit d'un lancer à l'autre. On instancie donc SIX copies, on
## avance chacune d'un temps différent, et on capture la bande. C'est la seule
## façon de voir si l'anneau se referme VRAIMENT au lieu de s'ouvrir.

const CELL := Vector2(240, 240)
const SHOTS: Array[float] = [0.03, 0.11, 0.19, 0.28, 0.36, 0.46]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var out: String = args[0] if args.size() > 0 else "/tmp/implosion.png"
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var root := Node2D.new()
	get_root().add_child(root)
	# Fond CLAIR comme le sol du jeu : le noyau de l'implosion assombrit, et sur
	# un fond noir on ne verrait pas qu'il assombrit.
	var background := ColorRect.new()
	background.size = Vector2(CELL.x * SHOTS.size(), CELL.y * 2)
	background.color = Color(0.42, 0.46, 0.38)
	root.add_child(background)

	var scene: PackedScene = load("res://scenes/fx/implosion.tscn")
	for i in SHOTS.size():
		var fx: Implosion = scene.instantiate()
		root.add_child(fx)
		fx.setup(32, 3.2, Element.color(Element.Kind.SHADOW), 99)
		fx.position = Vector2(CELL.x * (i + 0.5), CELL.y * 0.5)
		# On avance l'effet à la main plutôt que d'attendre : `_process` ne
		# tourne pas six fois de suite sur une image capturée à la volée.
		fx.set_process(false)
		fx._time = SHOTS[i]
		fx.queue_redraw()

	# La FLAQUE qui reste après le claquement, sur la seconde rangée : elle dure
	# quinze secondes quand l'implosion en dure deux tiers d'une, et c'est le
	# seul moyen de voir les deux au même endroit.
	for i in SHOTS.size():
		var pool: ZoneEffect = load("res://scenes/entities/zone_effect.tscn").instantiate()
		root.add_child(pool)
		pool.setup(32, Element.color(Element.Kind.SHADOW), 2.6, 15.0,
			null, 0.0, "ombre", false)
		pool.position = Vector2(CELL.x * (i + 0.5), CELL.y * 1.5)
		pool.set_process(false)
		pool._time = 0.4 + float(i) * 2.8
		pool.queue_redraw()

	get_root().size = Vector2i(int(CELL.x * SHOTS.size()), int(CELL.y * 2))
	await process_frame
	await process_frame
	var image := get_root().get_texture().get_image()
	image.save_png(out)
	print("preview -> ", out)
	quit()
