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
	# Aël, le héros principal, est le premier qu'on voit : premier onglet, choisi d'office.
	if CharacterCatalog.CATEGORIES.keys()[0] != CharacterCatalog.CATEGORY_HEROS:
		failures.append("l'onglet Héros n'est pas le premier")
	if screen.character_id != CharacterCatalog.AEL or CharacterCatalog.roster()[0].id != CharacterCatalog.AEL:
		failures.append("Aël n'est pas le premier personnage affiché : %s" % screen.character_id)
	if (screen.get_node("Buttons/PlayButton") as Button).disabled:
		failures.append("Aël ne peut pas lancer une vraie partie")
	# Ses quatre formes ont chacune leur carte, et s'essaient en DÉMO.
	var forms := 0
	for portrait: CharacterPortrait in screen._portraits:
		if portrait.stats.id in CharacterCatalog.AEL_FORMS:
			forms += 1
	if forms != CharacterCatalog.AEL_FORMS.size():
		failures.append("onglet Héros : %d formes d'Aël sur 4" % forms)
	screen.select("ael_prisme")
	if not (screen.get_node("Buttons/PlayButton") as Button).disabled \
			or (screen.get_node("Buttons/DemoButton") as Button).disabled:
		failures.append("le Prisme se choisit en DÉMO seulement")
	if CharacterCatalog.by_id("ael_ascendant").hero_form != 2:
		failures.append("la carte Ascendant ne donne pas sa forme")
	screen.select(CharacterCatalog.AEL)

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

	# LE BOUTON ÉVEIL bascule la fiche sur la forme éveillée, reste enclenché d'un mage à l'autre, disparaît sur qui
	# n'en a pas, et JOUER part toujours avec le mage.
	var awaken: Button = screen._awaken_button
	if not awaken.visible:
		failures.append("le Mage du Feu n'a pas de bouton Éveil")
	# Le bouton déborde de la fenêtre du test, plus petite que l'écran : on l'enclenche comme le ferait un clic.
	awaken.button_pressed = true
	if screen.name_label.text != "Phénix" or not screen._selected_preview.stats.awakened:
		failures.append("le bouton Éveil montre « %s »" % screen.name_label.text)
	if screen._ability_cards[0]._icon.texture == null:
		failures.append("les sorts de l'Éveil n'ont pas leurs icônes")
	screen.select(CharacterCatalog.SUPREME)
	if screen.name_label.text != "Archimage Primordial":
		failures.append("l'Éveil ne reste pas enclenché d'un mage à l'autre : %s" % screen.name_label.text)
	if screen.character_id != CharacterCatalog.SUPREME:
		failures.append("JOUER ne part plus avec le mage : %s" % screen.character_id)
	# Un personnage sans Éveil, cherché dans le roster : la liste des Éveils grandit d'un jour à l'autre.
	var plain := ""
	for entry in CharacterCatalog.roster():
		if CharacterCatalog.awakening_of(entry.id) == null and not entry.id in CharacterCatalog.AEL_FORMS \
				and entry.id != CharacterCatalog.AEL:
			plain = entry.id
			break
	if plain != "":
		screen.select(plain)
		if awaken.visible or screen.name_label.text != CharacterCatalog.by_id(plain).display_name:
			failures.append("%s, sans Éveil, montre « %s »" % [plain, screen.name_label.text])
	screen.select(CharacterCatalog.FIRE)
	awaken.button_pressed = false
	if screen.name_label.text != CharacterCatalog.by_id(CharacterCatalog.FIRE).display_name:
		failures.append("second appui : la fiche ne revient pas au mage")

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
