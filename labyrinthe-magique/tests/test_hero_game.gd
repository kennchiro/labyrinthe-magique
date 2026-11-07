extends SceneTree
var failures: Array[String] = []
func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
func _init() -> void:
	call_deferred("run")
func run() -> void:
	check(GameManager.development_run(), "une suite lancée par --script ne sauvegarde pas la partie réelle")
	var scene := load("res://scenes/main.tscn") as PackedScene
	var game := scene.instantiate() as GameManager
	game.demo = true
	game.character_id = "ael"
	game.hero_progress = HeroProgress.new()
	root.add_child(game)
	await process_frame
	game.demo = false
	for ability in game.character.action_bar():
		check(UiIcons.for_ability("ael", ability.id) != null, "icône Apprenti disponible : " + ability.id)
		check(UiIcons.for_ability("ael", ability.id).resource_path.ends_with(ability.id + ".png"), "icône du sort courant : " + ability.id)
	game.hero.gain(900)
	check_art(game.level.player, "ael_eveille")
	check(game.ui.hud.portrait.resource_path.contains("ael_eveille"), "portrait Éveillé dans le HUD")
	check(game.character.hero_form == 1 and game.level.player.hero_form == 1, "évolution propagée au joueur")
	check(game.level.player_health.maximum == 101, "bonus de vie du terrain conservé")
	game.level.enemy_defeated.emit("hunter", false, game.level.player.position)
	check(game.hero_progress.xp == 910, "un kill rapporte dix XP")
	game._on_gem_collected(1, game.level.gems_total)
	check(game.hero_progress.xp == 915, "une gemme rapporte cinq XP")
	game.hero.gain(99999)
	check_art(game.level.player, "ael_ascendant")
	check(game.level._plate_pips != null, "plaque d’Ascendant visible")
	check(game.character.hero_form == 2, "Ascendant au palier")
	game.hero.update(1.5)
	# La Transformation a son bouton (2026-11-04) : l'Extra de l'Ascendant reste sa Nova.
	check(game.character.ultimate.id == "ael_nova", "l'Extra de l'Ascendant reste la Nova")
	game.use_slot(GameManager.SLOT_TRANSFORM)
	check(game.hero.transformation.state == Transformation.State.NORMAL, "pas de transformation sans sa charge")
	game.hero.charge = HeroRuntime.TRANSFORM_KILLS
	game.use_slot(GameManager.SLOT_TRANSFORM)
	check(game.hero.transformation.state == Transformation.State.CHARGING, "le bouton dédié déclenche la transformation")
	game.hero.update(0.8)
	check_art(game.level.player, "ael_prisme")
	check(game.ui.hud.portrait.resource_path.contains("ael_prisme"), "portrait Prisme dans le HUD")
	check(game.character.hero_form == 3 and game.level.player.hero_form == 3, "Prisme propagé au jeu")
	check(game._action_state()["entries"].size() == 6, "toujours six boutons")
	game.hero.finish()
	check(game.character.hero_form == 2 and not game.kills.available(), "retour avec Extra vidé")
	var xp := game.hero_progress.xp
	game._on_player_died()
	check(game.hero_progress.xp == xp, "une défaite conserve l’XP")
	game.demo = true
	game.restart()
	check(game.hero_progress.xp == xp and game.character.hero_form == 2, "XP conservée après reprise")
	for ability in game.character.action_bar():
		check(UiIcons.for_ability("ael", ability.id) != null, "icône disponible : " + ability.id)
	var saved := game.hero_progress
	game.queue_free()
	await process_frame
	var selection := (load("res://scenes/menu/character_select.tscn") as PackedScene).instantiate() as CharacterSelect
	selection.hero_progress = saved
	root.add_child(selection)
	# Une carte par forme (demande du joueur, 2026-11-04) : chacune montre SA forme, et c'est JOUER qui
	# part avec le niveau acquis. Une forme atteinte se joue, une forme pas encore atteinte s'essaie en démo.
	selection.select("ael_ascendant")
	check(selection._selected_preview._portrait.resource_path.contains("ael_ascendant"), "portrait de la forme sur sa carte")
	check(selection.name_label.text.contains("Ascendant"), "la carte montre sa forme")
	check(not (selection.get_node("Buttons/PlayButton") as Button).disabled, "une forme acquise se joue")
	selection.select("ael_prisme")
	check((selection.get_node("Buttons/PlayButton") as Button).disabled, "le Prisme ne se choisit qu'en démo")
	selection.queue_free()
	await process_frame
	if failures.is_empty():
		print("TOUS LES TESTS PASSENT — Aël en jeu")
	else:
		for message in failures:
			push_error(message)
	quit(0 if failures.is_empty() else 1)

func check_art(player: Player, folder: String) -> void:
	check(player.walk_textures().size() == 4 and player.pose_count() == 17, "quatre directions et 17 poses : " + folder)
	for texture: Texture2D in player.walk_textures().values():
		check(texture != null and texture.resource_path.contains("/" + folder + "/"), "animation propre à la forme : " + folder)
