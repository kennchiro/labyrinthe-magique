extends SceneTree

## Le feu peint au shader, face à ce que le jeu affiche aujourd'hui, hors partie.
##
##   godot --path . --resolution 1280x560 --script res://tools/preview_fire.gd -- /tmp/feu.png
##   godot --path . --resolution 1280x720 --script res://tools/preview_fire.gd -- --bench
##
## `--bench` compare le temps d'une image à nombre de projectiles égal, en montant
## jusqu'à bien plus de projectiles qu'une partie n'en voit. Il répond sur CETTE
## machine : un téléphone se mesure sur le téléphone.

const BOLT := preload("res://assets/shaders/fire_bolt.gdshader")
const BALL := preload("res://assets/shaders/fire_ball.gdshader")
const NOISE := preload("res://assets/shaders/fire_noise.png")
const ORB := preload("res://assets/characters/fire/orb.png")
## Une case à l'écran, zoom du jeu compris.
const TILE := 64.0
const BOLT_SIZE := Vector2(TILE * 2.2, TILE * 0.62)
const BALL_SIZE := Vector2(TILE * 3.2, TILE * 2.0)
const GROUNDS: Array[Color] = [Color(0.16, 0.13, 0.2), Color(0.5, 0.48, 0.28), Color(0.82, 0.75, 0.6)]
const COUNTS: Array[int] = [1, 10, 30, 100, 300]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	get_root().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	if "--bench" in args:
		await _bench()
	else:
		await _sheet(args[0] if args.size() > 0 else "/tmp/feu.png")
	quit()


func _material(shader: Shader, seed: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("noise", NOISE)
	material.set_shader_parameter("seed", seed)
	return material


## Un quad blanc porte le shader : il ne lit aucune image de sort.
func _quad(shader: Shader, size: Vector2, at: Vector2, seed: float) -> ColorRect:
	var quad := ColorRect.new()
	quad.size = size
	quad.position = at - size * 0.5
	quad.material = _material(shader, seed)
	return quad


## La dernière image de la bande actuelle : le tir à pleine puissance.
func _old_orb(at: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = ORB
	sprite.hframes = 4
	sprite.frame = 3
	sprite.position = at
	sprite.scale = Vector2.ONE * (TILE * 1.4 / 112.0)
	return sprite


func _sheet(out: String) -> void:
	var root := Node2D.new()
	get_root().add_child(root)
	var cell := Vector2(320, 140)
	for row in GROUNDS.size():
		var band := ColorRect.new()
		band.size = Vector2(cell.x * 4, cell.y)
		band.position = Vector2(0, cell.y * row)
		band.color = GROUNDS[row]
		root.add_child(band)
		var y := cell.y * (row + 0.5)
		root.add_child(_old_orb(Vector2(cell.x * 0.5, y)))
		root.add_child(_quad(BOLT, BOLT_SIZE, Vector2(cell.x * 1.5, y), float(row) * 0.31))
		root.add_child(_quad(BOLT, BOLT_SIZE, Vector2(cell.x * 2.5, y), float(row) * 0.31 + 0.5))
		root.add_child(_quad(BALL, BALL_SIZE, Vector2(cell.x * 3.5, y), float(row) * 0.23))
	get_root().size = Vector2i(int(cell.x * 4), int(cell.y * GROUNDS.size()))
	for i in 12:
		await process_frame
	get_root().get_texture().get_image().save_png(out)
	print("preview -> ", out)


## Le temps moyen d'une image, sur une durée fixe, une fois le cache des shaders
## rempli.
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
	print("projectiles | image %.2f | shader trait | shader boule (ms par image, à vide déduit)" % 0.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for count in COUNTS:
		var results: Array[float] = []
		for kind in 3:
			var root := Node2D.new()
			get_root().add_child(root)
			for i in count:
				var at := Vector2(rng.randf() * view.x, rng.randf() * view.y)
				match kind:
					0: root.add_child(_old_orb(at))
					1: root.add_child(_quad(BOLT, BOLT_SIZE, at, rng.randf()))
					2: root.add_child(_quad(BALL, BALL_SIZE, at, rng.randf()))
			results.append(await _measure() - empty)
			root.queue_free()
			await process_frame
		print("%4d | %6.2f | %6.2f | %6.2f" % [count, results[0], results[1], results[2]])
