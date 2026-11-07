extends SceneTree

## Les 24 boutons passent par GameManager → Level → CombatSystem et leurs vrais effets.
var failures: Array[String] = []
func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var game := (load("res://scenes/main.tscn") as PackedScene).instantiate() as GameManager
	game.demo = true
	game.character_id = "ael"
	game.forced_seed = 4242
	game.hero_progress = HeroProgress.new()
	root.add_child(game)
	game.set_process(false)
	var casts := {"count": 0}
	game.level.ability_used.connect(func(_ability: Ability) -> void: casts["count"] += 1)
	for form in 4:
		for slot in 6:
			game.demo_form(form)
			if form == 3:
				game.hero.update(0.8)
			check(HeroTestArena.prepare(game), "une cible à portée dans le terrain de test")
			var ability := game.level.ability_at(slot)
			var before := int(casts["count"])
			game.use_slot(slot)
			check(int(casts["count"]) == before + 1, "forme %d, %s : le sort part" % [form, ability.display_name])
			check(game.level.combat.cooldown_left(ability) == 0.0, "aucune recharge en démo : " + ability.id)
			check(UiIcons.for_ability("ael", ability.id) != null, "icône du sort : " + ability.id)
			check(not game.hero_progress.persistent, "aucune sauvegarde pendant l’essai des sorts")
			# Le temps et les impacts passent par les mêmes règles que dans la partie.
			game.level._refresh_context()
			game.level.combat.update(0.5, game.level.combat_context)
			await process_frame
	check(int(casts["count"]) == 24, "24 compétences utilisables")
	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("TOUS LES TESTS PASSENT — 24 compétences d’Aël en jeu")
	else:
		for failure in failures:
			push_error(failure)
	quit(0 if failures.is_empty() else 1)
