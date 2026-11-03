extends SceneTree

## L'écran de sélection et ses onglets : chaque personnage est dans UN onglet, et le
## choix affiché appartient toujours à l'onglet ouvert.
##
##   godot --headless --path . --script res://tests/test_select.gd


func _init() -> void:
	var failures: Array[String] = []

	var counted := 0
	for category: String in CharacterCatalog.CATEGORIES:
		var members := CharacterCatalog.in_category(category)
		counted += members.size()
		if members.is_empty():
			failures.append("onglet vide : %s" % category)
	# Une catégorie mal écrite ferait disparaître le personnage de l'écran, sans erreur.
	if counted != CharacterCatalog.roster().size():
		failures.append("%d personnages rangés sur %d" % [counted, CharacterCatalog.roster().size()])
	if CharacterCatalog.by_id(CharacterCatalog.LUMIERE).category != CharacterCatalog.CATEGORY_ANGE:
		failures.append("le Porte-Lumière n'est pas un ange")

	var screen: CharacterSelect = load("res://scenes/menu/character_select.tscn").instantiate()
	screen.size = Vector2(690.0, 330.0)
	root.add_child(screen)
	await process_frame

	var default_stats := CharacterCatalog.by_id(CharacterCatalog.default_id())
	if screen._category != default_stats.category:
		failures.append("ouvre sur le mauvais onglet : %s" % screen._category)

	# Changer d'onglet choisit un personnage de cet onglet, et n'affiche que lui.
	screen.select(CharacterCatalog.FIRE)
	# Un VRAI clic, pas un appel : un onglet recouvert par un autre nœud ne répondrait pas.
	await _click(screen._tabs[CharacterCatalog.CATEGORY_ANGE])
	if CharacterCatalog.by_id(screen.character_id).category != CharacterCatalog.CATEGORY_ANGE:
		failures.append("l'onglet Ange garde un personnage d'un autre onglet")
	for portrait: CharacterPortrait in screen._portraits:
		if portrait.visible != (portrait.stats.category == CharacterCatalog.CATEGORY_ANGE):
			failures.append("carte mal rangée : %s" % portrait.stats.id)
	if screen._listed.size() != CharacterCatalog.in_category(CharacterCatalog.CATEGORY_ANGE).size():
		failures.append("la rangée ne compte pas les seuls anges")

	# Revenir sur un onglet retrouve le choix qu'on y avait fait.
	screen._on_tab(CharacterCatalog.CATEGORY_MAGE)
	if screen.character_id != CharacterCatalog.FIRE:
		failures.append("retour sur Mage : %s au lieu de fire" % screen.character_id)

	# Sélectionner un personnage ouvre son onglet, d'où que vienne la sélection.
	screen.select(CharacterCatalog.LUMIERE)
	if screen._category != CharacterCatalog.CATEGORY_ANGE:
		failures.append("select() n'a pas ouvert l'onglet du personnage")
	if not (screen._tabs[CharacterCatalog.CATEGORY_ANGE] as Button).button_pressed:
		failures.append("l'onglet Ange n'est pas marqué")

	# Le Héros d'essai est caché du joueur, mais reste jouable par `--character test`.
	if screen._tabs.has(CharacterCatalog.CATEGORY_TEST):
		failures.append("l'onglet Essai est encore affiché")
	for portrait in screen._portraits:
		if portrait.stats.id == CharacterCatalog.TEST:
			failures.append("le Héros d'essai a encore son portrait")
	screen.select(CharacterCatalog.FIRE)
	if (screen.get_node("Buttons/PlayButton") as Button).disabled:
		failures.append("JOUER reste grisé pour les autres")

	# Le titre ne passe pas sous les onglets, sur les tailles d'un téléphone.
	for width in [960.0, 690.0, 480.0]:
		screen.size = Vector2(width, 330.0)
		screen._layout()
		var last: Button = screen._tabs[CharacterCatalog.CATEGORY_DEMON]
		if screen.get_node("Heading").position.x < last.position.x + last.size.x:
			failures.append("titre sous les onglets à %d" % int(width))

	print("")
	if failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT")
	else:
		print("❌  %d ÉCHEC(S) :" % failures.size())
		for line in failures:
			print("   - ", line)
	quit(0 if failures.is_empty() else 1)


func _click(button: Button) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = button.get_global_rect().get_center()
		event.global_position = event.position
		# En coordonnées locales : la fenêtre étire l'interface, et la position d'un
		# bouton n'est pas en pixels de fenêtre.
		root.push_input(event, true)
		await process_frame
