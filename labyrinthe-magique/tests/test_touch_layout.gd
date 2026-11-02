extends SceneTree

## Les commandes tactiles sur mesure : LE JOUEUR PEUT TOUT DÉPLACER, ET RIEN NE SE RECOUVRE.
##
##   godot --headless --path . --script res://tests/test_touch_layout.gd
##
## L'éditeur est éprouvé par ses gestes, sur ses vrais nœuds. `tests/test_pad.gd` garde la
## place déduite ; ici, c'est ce que le joueur en fait.

const TEST_SETTINGS := "user://test_touch_layout.cfg"
## Des tailles d'INTERFACE : voir `tests/test_pad.gd`.
const VIEWS := [Vector2(1280.0, 720.0), Vector2(960.0, 460.0), Vector2(690.0, 330.0)]

var failures: Array[String] = []


func _init() -> void:
	Settings.path_override = TEST_SETTINGS
	_clean_settings()
	_test_reserved_matches_scene()
	_test_empty_layout_is_the_old_game()
	_test_data_survives_bad_files()
	_test_settle()
	_test_settings_file()
	_test_cross()
	for view: Vector2 in VIEWS:
		await _test_editor(view)
	await _test_in_a_real_game()
	_clean_settings()

	print("")
	if failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT")
	else:
		print("❌  %d ÉCHEC(S) :" % failures.size())
		for line in failures:
			print("   - ", line)
	quit(0 if failures.is_empty() else 1)


func _clean_settings() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SETTINGS))
	Settings.forget()


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


## Les zones réservées recopient la scène : elles ne doivent pas s'en éloigner en silence.
func _test_reserved_matches_scene() -> void:
	var game: Node = load("res://scenes/main.tscn").instantiate()
	var pause: Control = game.get_node("UI/PauseButton")
	var quest: Control = game.get_node("UI/QuestButton")
	_check(is_equal_approx(-pause.offset_left, TouchLayout.TOP_RIGHT.x)
		and is_equal_approx(quest.offset_bottom, TouchLayout.TOP_RIGHT.y),
		"le coin réservé ne recouvre plus la pause et le carnet")
	game.free()


## Une disposition vide ne change RIEN : ni place, ni taille.
func _test_empty_layout_is_the_old_game() -> void:
	var bare := CombatPad.new()
	var custom := CombatPad.new()
	custom.layout = TouchLayout.new()
	for pad in [bare, custom]:
		pad.size = Vector2(690.0, 330.0)
	for i in 6:
		_check(bare._centre(i) == custom._centre(i) and bare._radius(i) == custom._radius(i),
			"une disposition vide déplace le bouton %d" % i)
	bare.free()
	custom.free()


## Un fichier abîmé ne doit jamais rendre un bouton invisible ou introuvable.
func _test_data_survives_bad_files() -> void:
	var layout := TouchLayout.from_data({
		"b1": {"at": Vector2(9.0, -3.0), "scale": 40.0, "alpha": 0.0},
		"b2": "n'importe quoi",
		"b3": {"at": "ici", "scale": NAN},
	})
	_check(layout.custom["b1"]["at"] == Vector2(1.0, 0.0), "position hors écran gardée")
	_check(layout.scale_of("b1") == TouchLayout.MAX_SCALE, "taille démesurée gardée")
	_check(layout.alpha_of("b1") == TouchLayout.MIN_ALPHA, "bouton rendu invisible")
	_check(not layout.custom.has("b2") and not layout.custom.has("b3"), "valeur abîmée gardée")
	_check(TouchLayout.from_data("rien").is_default(), "un fichier illisible n'est pas le défaut")
	var view := Vector2(690.0, 330.0)
	_check(layout.centre_of("b1", view, Vector2.ZERO, 30.0).x <= view.x - 30.0,
		"le bouton sort de l'écran")


func _test_settle() -> void:
	var view := Vector2(1280.0, 720.0)
	var moved: Array[String] = ["a"]
	# Posé exactement sur son voisin : il s'en écarte, et le voisin ne bouge pas.
	var items: Array[Dictionary] = [
		{"id": "a", "at": Vector2(600.0, 400.0), "radius": 40.0, "extent": 40.0},
		{"id": "b", "at": Vector2(600.0, 400.0), "radius": 40.0, "extent": 40.0},
	]
	_check(TouchLayout.settle(items, view, moved), "un bouton sur un autre n'a pas trouvé de place")
	_check(items[1]["at"] == Vector2(600.0, 400.0), "le voisin a été dérangé")
	_check(Vector2(items[0]["at"]).distance_to(items[1]["at"]) >= 88.0 - 0.01,
		"pas assez d'écart après la séparation")
	# Un bouton posé sur la pause, ou sur la barre de vie, en sort.
	for point: Vector2 in [Vector2(1250.0, 30.0), Vector2(120.0, 40.0)]:
		var alone: Array[Dictionary] = [
			{"id": "a", "at": point, "radius": 40.0, "extent": 40.0}]
		_check(TouchLayout.settle(alone, view, moved), "pas de sortie depuis %s" % point)
		for zone in TouchLayout.reserved(view):
			var at: Vector2 = alone[0]["at"]
			_check(at.distance_to(at.clamp(zone.position, zone.end)) >= 40.0,
				"un bouton reste sur une zone réservée (%s)" % point)
	# Trop gros pour l'écran : c'est un refus, pas un bouton à moitié dehors.
	var giant: Array[Dictionary] = [
		{"id": "a", "at": Vector2(300.0, 300.0), "radius": 500.0, "extent": 500.0}]
	_check(not TouchLayout.settle(giant, view, moved), "un bouton plus grand que l'écran est accepté")


func _test_settings_file() -> void:
	_clean_settings()
	_check(Settings.move_mode() == Settings.MOVE_STICK, "le manche n'est plus le défaut")
	_check(Settings.touch_layout().is_default(), "la disposition par défaut n'est pas vide")

	# Un joueur qui avait choisi le tap, avant que la croix existe, le garde.
	var old := ConfigFile.new()
	old.set_value("controls", "tap_to_move", true)
	old.save(TEST_SETTINGS)
	Settings.forget()
	_check(Settings.move_mode() == Settings.MOVE_TAP, "l'ancien réglage du tap est perdu")

	Settings.set_move_mode(Settings.MOVE_CROSS)
	var layout := TouchLayout.new()
	layout.set_scale("b2", 1.25)
	layout.set_alpha(TouchLayout.MOVE, 0.5)
	layout.set_centre("b2", Vector2(100.0, 200.0), Vector2(1000.0, 1000.0))
	# L'objet que tiennent le manche et le pad est le même après l'enregistrement.
	var held := Settings.touch_layout()
	Settings.save_touch_layout(layout)
	_check(held.scale_of("b2") == 1.25, "la partie en cours ne suit pas l'enregistrement")
	Settings.forget()
	_check(Settings.move_mode() == Settings.MOVE_CROSS, "le mode ne survit pas au redémarrage")
	var back := Settings.touch_layout()
	_check(back.scale_of("b2") == 1.25 and back.alpha_of(TouchLayout.MOVE) == 0.5,
		"la disposition ne survit pas au redémarrage")
	_check(back.custom["b2"]["at"].is_equal_approx(Vector2(0.1, 0.2)), "la position est perdue")
	_clean_settings()


func _touch(index: int, point: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = pressed
	return event


func _slide(index: int, point: Vector2) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = point
	return event


func _test_cross() -> void:
	var stick := TouchStick.new()
	stick.size = Vector2(1280.0, 720.0)
	stick.set_style(TouchStick.Style.CROSS)
	var centre := stick._origin()
	var reach := stick.radius * 0.7

	# Il suffit de poser le pouce du bon côté, sans glisser.
	var sides := {Vector2.RIGHT: Vector2.RIGHT, Vector2.LEFT: Vector2.LEFT,
		Vector2.UP: Vector2.UP, Vector2.DOWN: Vector2.DOWN}
	for side: Vector2 in sides:
		stick._input(_touch(0, centre + side * reach, true))
		_check(stick.direction == sides[side], "croix : mauvaise direction vers %s" % side)
		stick._input(_touch(0, centre + side * reach, false))
		_check(stick.direction == Vector2.ZERO, "croix : le mage continue doigt levé")

	# Toujours une direction franche, jamais une diagonale.
	stick._input(_touch(0, centre + Vector2(reach, reach * 0.6), true))
	_check(stick.direction == Vector2.RIGHT, "croix : une diagonale n'est pas réduite à un axe")
	# Sur la frontière, le pouce garde son bras au lieu de le faire vibrer.
	stick._input(_slide(0, centre + Vector2(reach, reach * 1.05)))
	_check(stick.direction == Vector2.RIGHT, "croix : le mage vibre sur la diagonale")
	# Bien au-delà, on change de bras sans relever le pouce.
	stick._input(_slide(0, centre + Vector2(reach * 0.2, reach)))
	_check(stick.direction == Vector2.DOWN, "croix : glisser ne change pas de direction")
	# Le pouce au repos sur le centre n'avance plus.
	stick._input(_slide(0, centre + Vector2(2.0, 2.0)))
	_check(stick.direction == Vector2.ZERO, "croix : le centre fait marcher le mage")
	stick._input(_touch(0, centre, false))

	# Le manche, lui, reste analogique : une zone morte, puis un vecteur continu.
	stick.set_style(TouchStick.Style.ANALOG)
	stick._input(_touch(0, centre + Vector2(2.0, 0.0), true))
	_check(stick.direction == Vector2.ZERO, "manche : la zone morte a disparu")
	stick._input(_slide(0, centre + Vector2(stick.radius, stick.radius * 0.5)))
	_check(stick.direction.y > 0.0 and stick.direction.x > 0.0, "manche : il n'est plus analogique")
	stick.free()


func _no_overlap(editor: TouchLayoutEditor, view: Vector2, moment: String) -> void:
	var items := editor._items()
	var everything: Array[String] = []
	for item in items:
		everything.append(item["id"])
	var bad := TouchLayout.conflicts(items, view, everything)
	# Seul ce que le joueur a déplacé répond de sa place.
	for id in bad:
		if editor._draft.has_position(id):
			_check(false, "%s, %s : %s gêne une autre commande" % [view, moment, id])


## Tout passe par les gestes de l'éditeur, sur chaque taille d'écran.
func _test_editor(view: Vector2) -> void:
	_clean_settings()
	var holder := Control.new()
	holder.size = view
	root.add_child(holder)
	var editor := TouchLayoutEditor.new()
	holder.add_child(editor)
	await process_frame
	await process_frame
	# ⚠️ AUCUNE TAILLE N'EST POSÉE ICI. Ce test les posait d'abord à la main, et passait
	# pendant que le vrai éditeur s'ouvrait tassé dans le coin de l'écran, sans taille.
	for part: Control in [editor, editor._stick, editor._pad, editor._marks]:
		_check(part.size == view, "%s : %s ne remplit pas l'écran (%s)" % [view, part.get_class(), part.size])
	_check(editor._toolbar.get_global_rect().end.x <= view.x
		and editor._toolbar.get_global_rect().end.y <= view.y,
		"%s : la barre d'outils sort de l'écran" % view)

	# Un simple appui sélectionne, et ne déplace rien.
	var target: Vector2 = editor._pad._centre(2)
	editor._input(_touch(0, target, true))
	editor._input(_touch(0, target, false))
	_check(editor._selected == "b2", "%s : l'appui ne sélectionne pas" % view)
	_check(not editor._draft.has_position("b2"), "%s : un appui a déplacé le bouton" % view)

	# Un vrai glissé pose le bouton là où on l'a lâché.
	var free_spot := view * Vector2(0.5, 0.75)
	editor._input(_touch(0, target, true))
	editor._input(_slide(0, free_spot))
	editor._input(_touch(0, free_spot, false))
	_check(editor._pad._centre(2).distance_to(free_spot) < 60.0,
		"%s : le bouton n'a pas suivi le doigt" % view)
	_no_overlap(editor, view, "après un glissé")

	# Lâché sur un voisin : il ne reste pas dessus.
	var neighbour: Vector2 = editor._pad._centre(0)
	editor._input(_touch(0, editor._pad._centre(2), true))
	editor._input(_slide(0, neighbour))
	editor._input(_touch(0, neighbour, false))
	_no_overlap(editor, view, "lâché sur la frappe")
	var gap: float = editor._pad._centre(2).distance_to(editor._pad._centre(0)) \
		- editor._pad._radius(2) - editor._pad._radius(0)
	_check(gap >= TouchLayout.GAP - 0.5, "%s : deux boutons l'un sur l'autre (%.1f)" % [view, gap])

	# Plus grand et plus petit, un bouton seul : le curseur n'accepte que le possible.
	editor._select("b0")
	editor._on_size_changed(TouchLayout.MAX_SCALE)
	_no_overlap(editor, view, "frappe au maximum")
	editor._on_size_changed(TouchLayout.MIN_SCALE)
	_check(is_equal_approx(editor._draft.scale_of("b0"), TouchLayout.MIN_SCALE),
		"%s : la frappe ne rétrécit pas" % view)

	# L'opacité ne touche que le bouton choisi.
	editor._on_alpha_changed(0.4)
	_check(is_equal_approx(editor._draft.alpha_of("b0"), 0.4)
		and is_equal_approx(editor._draft.alpha_of("b1"), 1.0),
		"%s : l'opacité déborde sur les autres" % view)

	# Un appui hors de tout revient à « toutes les commandes ».
	editor._input(_touch(0, view * Vector2(0.5, 0.5), true))
	if editor.control_at(view * Vector2(0.5, 0.5)).is_empty():
		_check(editor._selected == TouchLayoutEditor.ALL, "%s : retour à « toutes »" % view)
	editor._input(_touch(0, view * Vector2(0.5, 0.5), false))

	# Tout agrandir d'un coup : le curseur s'arrête au possible, sans chevauchement.
	editor.reset()
	editor._on_size_changed(1.25)
	_no_overlap(editor, view, "tout à 125 %")

	# Annuler n'a rien écrit.
	_check(Settings.touch_layout().is_default(), "%s : le brouillon a fui avant « Enregistrer »" % view)

	# Le jeu pour gaucher, depuis la disposition d'origine : c'est lui qui compte.
	editor.reset()
	var was_on_right: bool = editor._pad._centre(0).x > view.x * 0.5
	_check(editor.mirror(), "%s : pas de place pour le jeu gaucher" % view)
	_check(was_on_right and editor._pad._centre(0).x < view.x * 0.5,
		"%s : la frappe n'est pas passée à gauche" % view)
	_check(editor._stick._origin().x > view.x * 0.5, "%s : le manche n'est pas passé à droite" % view)
	_no_overlap(editor, view, "en gaucher")

	# Enregistré, le vrai pad d'une partie le voit, et ses touches suivent le bouton.
	var seen := {"slot": -99}
	var moved_to: Vector2 = editor._pad._centre(0)
	editor.save()
	var pad := CombatPad.new()
	pad.layout = Settings.touch_layout()
	pad.size = view
	pad.entries = editor._pad.entries
	pad.visible = true
	pad.action_requested.connect(func(slot: int) -> void: seen["slot"] = slot)
	_check(pad._centre(0).is_equal_approx(moved_to), "%s : le pad ne suit pas" % view)
	pad._input(_touch(0, moved_to, true))
	_check(seen["slot"] == 0, "%s : la frappe déplacée ne répond plus" % view)
	pad.free()
	holder.free()
	_clean_settings()


## Le trajet du joueur dans une vraie partie : la pause, les réglages, et au retour les
## commandes de la partie ont changé sans recharger le niveau.
func _test_in_a_real_game() -> void:
	_clean_settings()
	var game: GameManager = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	var ui := game.ui
	ui.touch_mode = true
	ui.result_screen.settings_available = true
	ui.combat_pad.visible = true
	ui._apply_control_scheme()

	# Une partie sans argument ouvre son carnet : le bouton de pause le refermerait.
	if ui.quest_visible():
		game.resume()
	game.toggle_pause()
	_check(ui.result_screen.settings_button.visible, "pas de bouton Réglages à la pause")
	ui.result_screen.settings_button.pressed.emit()
	await process_frame
	var panel := ui.settings_panel()
	_check(panel != null, "le bouton n'ouvre pas les réglages")
	_check(panel.size == ui.get_viewport().get_visible_rect().size, "le panneau ne couvre pas l'écran")
	# Derrière le panneau, aucune commande ne doit répondre.
	_check(not ui.combat_pad.visible and not ui.stick.visible, "les commandes restent actives dessous")
	_check(ui.touch_reserved(Vector2(5.0, 5.0)), "un tap sur le panneau ferait marcher le mage")

	panel._mode_buttons[Settings.MOVE_CROSS].pressed.emit()
	_check(Settings.move_mode() == Settings.MOVE_CROSS, "le choix de la croix n'est pas retenu")

	panel.open_editor()
	await process_frame
	await process_frame
	var editor := panel._editor
	_check(editor._stick.style == TouchStick.Style.CROSS, "l'éditeur ne montre pas la croix")
	var view := editor.size
	var spot := view * Vector2(0.5, 0.75)
	editor._input(_touch(0, editor._pad._centre(1), true))
	editor._input(_slide(0, spot))
	editor._input(_touch(0, spot, false))
	var placed: Vector2 = editor._pad._centre(1)
	editor.save()
	await process_frame
	_check(panel._editor == null, "l'éditeur reste ouvert après l'enregistrement")
	panel.closed.emit()
	await process_frame
	_check(ui.settings_panel() == null, "le panneau ne se ferme pas")
	_check(ui.stick.style == TouchStick.Style.CROSS and ui.stick.visible, "la partie n'a pas la croix")
	_check(ui.combat_pad.visible, "le pad ne revient pas")
	_check(ui.combat_pad._centre(1).is_equal_approx(placed), "la partie ne suit pas la disposition")

	# Reprendre la main au clavier, réglages ouverts, ne laisse rien derrière.
	ui.open_settings()
	game.resume()
	_check(ui.settings_panel() == null, "reprendre laisse le panneau ouvert")
	game.free()
	get_root().get_tree().paused = false
	_clean_settings()
