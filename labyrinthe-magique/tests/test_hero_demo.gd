extends SceneTree

## Les mêmes gestes que le joueur : cartes, choix dans l’arène et reprises de l’Extra.
const APP := preload("res://scenes/app.tscn")
var failures: Array[String] = []
func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var flow: GameFlow = APP.instantiate()
	root.add_child(flow)
	await process_frame
	for form in 4:
		flow.character_id = CharacterCatalog.AEL_FORMS[form]
		flow.start_game(true)
		await process_frame
		var game := flow._current as GameManager
		check(game != null and game.hero != null, "forme %d : vraie partie Aël" % form)
		check(game.hero_progress.level() == int(CharacterCatalog.AEL_FORM_LEVELS[form]), "forme %d : niveau exact de sa carte" % form)
		check(game.kills.kills == 0 and game.kills.available(), "la démo charge l’Extra sans inventer de kills")
		check(not game.hero_progress.persistent and not game.progress.persistent, "aucune sauvegarde en démo")
		check(game.ui.hero_demo_picker != null, "choix des évolutions dans l’arène")
		if form == 3:
			game.hero.update(0.8)
			check(game.character.hero_form == 3, "la carte Prisme s’éveille")
			game.hero.finish()
			check(game.kills.available(), "l’Extra reste chargé après le retour en démo")
			check(not game.hero.can_transform(true), "la transformation attend la fin de l’épuisement")
			game.hero.update(3.0)
			check(game.hero.can_transform(true), "la transformation se rejoue sans tuer d’ennemi")
			game.use_slot(GameManager.SLOT_TRANSFORM)
			check(not game._action_state()["entries"][0]["ready"], "les boutons attendent la fin de la charge")
			game.hero.update(0.8)
			check(game.character.hero_form == 3, "deuxième transformation possible")
		game.ui.hero_demo_picker.form_requested.emit(1)
		check(game.character.hero_form == 1 and game.hero_progress.level() == 10, "le sélecteur change la forme")
		game.ui.hero_demo_picker.advance.pressed.emit()
		check(game.character.hero_form == 2 and game.hero_progress.level() == 20, "le bouton Évoluer passe au palier suivant")
		game.demo_form(3)
		game.demo_stage(1)
		check(game.hero.transformation.state == Transformation.State.CHARGING, "le décor suivant conserve le choix Prisme")
		game.hero.update(0.8)
		game.hero.finish()
		game.level.player_health.plates = 0
		game.level.player_health.shield = 0
		game.level.player_health.immune = false
		game.level.player_health.take(Damage.new(10000, Element.Kind.SHADOW, "test"))
		check(game.level.player_health.is_alive(), "la démo ne finit pas par tuer Aël")
		var before := game.hero_progress.xp
		game._on_enemy_defeated("hunter", false, Vector2.ZERO)
		game._on_gem_collected(1, game.level.gems_total)
		check(game.hero_progress.xp == before, "essayer un sort ne fait pas progresser la vraie partie")
		# Les mêmes commandes sont refusées en campagne.
		game.demo = false
		game.demo_form(0)
		check(game.hero_progress.xp == before, "pas de changement de niveau par le sélecteur en campagne")
	flow.queue_free()
	await process_frame
	if failures.is_empty():
		print("TOUS LES TESTS PASSENT — démo des quatre formes d’Aël")
	else:
		for failure in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)
