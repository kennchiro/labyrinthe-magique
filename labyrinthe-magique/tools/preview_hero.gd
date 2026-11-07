extends SceneTree

## Capture les quatre formes sans toucher à la progression du joueur.
func _init() -> void:
	call_deferred("capture")

func capture() -> void:
	var game := (load("res://scenes/main.tscn") as PackedScene).instantiate() as GameManager
	game.demo = true
	game.character_id = "ael"
	game.hero_progress = HeroProgress.new()
	root.add_child(game)
	for rank in [1, 10, 20, 30]:
		game.hero_progress.xp = HeroProgress.threshold(rank)
		game.start_level(0)
		if rank == 30:
			game.hero.transformation.begin(30)
			game.hero.update(0.8)
		await create_timer(1.0).timeout
		await RenderingServer.frame_post_draw
		var path := "/tmp/ael-forme-%d.png" % rank
		root.get_texture().get_image().save_png(path)
		print("capture -> " + path)
	game.queue_free()
	await process_frame
	quit()
