extends SceneTree

## La barre du mage : TOUT TIENT, sur tous les stages, et rien ne se recouvre.
##
##   godot --headless --path . --script res://tests/test_hud.gd
##
## La barre lit sa géométrie dans `barre.json`, mesuré sur l'image : un cadre
## redessiné peut donc la casser sans qu'aucune ligne de code ne change.


func _init() -> void:
	var failures: Array[String] = []
	var hud: HUD = load("res://scenes/ui/hud.tscn").instantiate()
	root.add_child(hud)
	await process_frame

	var font: Font = hud.level_label.get_theme_font("font")
	# Le titre, sur les dix stages et leurs deux épisodes.
	for config: LevelConfig in LevelConfig.all_levels():
		hud.set_level(config, 1)
		var width := font.get_string_size(hud.level_label.text, HORIZONTAL_ALIGNMENT_LEFT,
			-1.0, hud.level_label.get_theme_font_size("font_size")).x
		if width > hud._title_row.size.x:
			failures.append("titre coupé : %s" % hud.level_label.text)

	# Dix gemmes, le maximum (stage 10, épisode 2), sans passer sous les compteurs.
	var room: float = hud.gem_room()
	var last := HUD.gem_step(room, 10) * 9.0 + HUD.GEM_SIZE
	if last > room + 0.01:
		failures.append("10 gemmes : %.1f pour %.1f" % [last, room])
	if HUD.gem_step(room, 10) < HUD.GEM_SIZE * 0.75:
		failures.append("10 gemmes trop serrées : pas de %.1f" % HUD.gem_step(room, 10))

	# Le compteur de portails tient dans sa case.
	if font.get_string_size("99", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11).x > HUD.counter_width():
		failures.append("compteur de portails coupé")

	# Douze PV gardent leurs crans ; les cent de la démo n'en ont pas.
	if not HUD.segments_fit(hud._health_rect.size.x, 12):
		failures.append("12 PV : plus de crans")
	if HUD.segments_fit(hud._health_rect.size.x, 100):
		failures.append("100 PV : la jauge serait rayée")

	# Le bouclier touche la vie restante et ne sort jamais de la gouttière.
	var rect := Rect2(10.0, 0.0, 100.0, 10.0)
	if not is_equal_approx(HUD.shield_band(rect, 0.25, 1.0).position.x, 35.0):
		failures.append("bouclier décollé de la vie à 25 %")
	if HUD.shield_band(rect, 1.0, 1.0).end.x > rect.end.x + 0.01:
		failures.append("bouclier hors de la gouttière à pleine vie")

	# Chaque mage a son portrait peint.
	for character in CharacterCatalog.all():
		hud.set_character(character)
		if hud.portrait_region.size.x <= 0.0 or hud.portrait == null:
			failures.append("portrait manquant : %s" % character.id)
		if not ResourceLoader.exists("res://assets/ui/portraits/portrait_%s.jpg" % character.id):
			failures.append("portrait peint absent : %s" % character.id)

	print("")
	if failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT")
	else:
		print("❌  %d ÉCHEC(S) :" % failures.size())
		for line in failures:
			print("   - ", line)
	quit(0 if failures.is_empty() else 1)
