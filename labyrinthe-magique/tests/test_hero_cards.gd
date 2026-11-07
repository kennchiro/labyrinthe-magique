extends SceneTree

## Les cartes des formes d'Aël, de la sélection jusqu'à la démo : chaque carte lance Aël à sa forme,
## et celle du Prisme déclenche la transformation dès l'arrivée. Son Extra ne la défait pas.
##   godot --headless --path . --script res://tests/test_hero_cards.gd

const APP := preload("res://scenes/app.tscn")

var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for form in CharacterCatalog.AEL_FORMS.size():
		var flow: GameFlow = APP.instantiate()
		root.add_child(flow)
		await process_frame
		flow.character_id = CharacterCatalog.AEL_FORMS[form]
		flow.start_game(true)
		await process_frame
		var game := _game(flow)
		if game == null:
			_failures.append("forme %d : pas de partie" % form)
		else:
			if game.character_id != CharacterCatalog.AEL:
				_failures.append("forme %d : la partie n'est pas Aël (%s)" % [form, game.character_id])
			var expected := mini(form, 2)
			if game.character.hero_form != expected:
				_failures.append("forme %d : partie à la forme %d" % [form, game.character.hero_form])
			if form == 3 and (game.hero == null or game.hero.transformation.state == Transformation.State.NORMAL):
				_failures.append("le Prisme ne se transforme pas à l'arrivée")
			if game.hero_progress.persistent:
				_failures.append("forme %d : la démo écrirait la sauvegarde" % form)
			# La carte du Dragon d'or : la charge mène droit au dragon, au niveau 80.
			if form == 4 and game.hero != null:
				await create_timer(Transformation.CHARGE_TIME + 0.3).timeout
				if game.character.hero_form != 4 or game.hero.transformation.state != Transformation.State.DRAGON:
					_failures.append("la carte du Dragon d'or ne l'éveille pas (forme %d)" % game.character.hero_form)
				# Depuis le Prisme, le même bouton mène au Dragon.
				game.hero.finish()
				game.hero.update(Transformation.EXHAUST_TIME + 0.1)
				game.use_slot(GameManager.SLOT_TRANSFORM)
				game.hero.update(Transformation.CHARGE_TIME + 0.05)
				if not game.hero.next_is_dragon():
					_failures.append("en Prisme au niveau 80, le bouton ne propose pas le Dragon")
				game.use_slot(GameManager.SLOT_TRANSFORM)
				game.hero.update(Transformation.CHARGE_TIME + 0.05)
				if game.character.hero_form != 4:
					_failures.append("le bouton ne mène pas du Prisme au Dragon d'or")
			# Le Prisme ultime se lance et la forme continue : le joueur ne comprenait pas que son Extra
			# le détransforme.
			if form == 3 and game.hero != null:
				await create_timer(Transformation.CHARGE_TIME + 0.3).timeout
				if game.hero.transformation.state != Transformation.State.PRISM:
					_failures.append("le Prisme n'est pas atteint après la charge")
				else:
					game.use_slot(GameManager.SLOT_ULTIMATE)
					await process_frame
					var exploded := false
					for node in game.level.entities.get_children():
						exploded = exploded or node is PrismNova
					if not exploded:
						_failures.append("le Prisme ultime n'a pas son explosion de lasers")
					if game.hero.transformation.state != Transformation.State.PRISM:
						_failures.append("le Prisme ultime met encore fin à la transformation")
					# Le bouton dédié : après l'épuisement, un appui relance la transformation.
					game.hero.finish()
					game.hero.update(Transformation.EXHAUST_TIME + 0.1)
					await process_frame
					if not game.ui.transform_button.visible:
						_failures.append("le bouton de la Transformation n'est pas affiché au niveau 30")
					game.ui.transform_button.pressed.emit()
					if game.hero.transformation.state != Transformation.State.CHARGING:
						_failures.append("le bouton de la Transformation ne la déclenche pas")
					if game.character.ultimate.id == "ael_transformation":
						_failures.append("la Transformation est encore sur l'Extra")
		flow.queue_free()
		await process_frame
	if _failures.is_empty():
		print("TOUS LES TESTS PASSENT")
	else:
		for failure in _failures:
			print("ÉCHEC : ", failure)
	quit(0 if _failures.is_empty() else 1)


func _game(node: Node) -> GameManager:
	for child in node.get_children():
		if child is GameManager:
			return child
	return null
