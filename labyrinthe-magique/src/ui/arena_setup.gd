class_name ArenaSetup
extends Control

## L'écran de préparation de l'ARÈNE : le mode, le format, les deux équipes et la posture de
## chaque héros. Il n'a qu'une sortie, `fight_requested`, qui porte toute la composition : il ne
## sait rien du match qui suit.
##
## Construit en code, comme le carnet de quête : une mise en page qui DÉPEND de la taille de
## l'écran (un téléphone en paysage n'offre qu'environ 690 x 330 unités) se calcule mieux qu'elle
## ne se pose dans une scène.

signal fight_requested(setup: Dictionary)
signal back_requested

const BACKDROP := Color(0.035, 0.045, 0.085)
const GOLD := Color("#ffd479")

## La composition en cours, que l'écran de fin rend telle quelle pour « Rejouer ».
var setup := {
	"mode": ArenaRules.Mode.HEART,
	"format": 3,
	"stage": ArenaRules.COLISEUM,
	"team_a": [],
	"team_b": [],
}

var _title: Label
var _hint: Label
var _mode_buttons: Array[Button] = []
var _format_buttons: Array[Button] = []
var _team_headers: Array[Label] = []
var _random_buttons: Array[Button] = []
## Par équipe, par place : { "card": CharacterPortrait, "name": Label, "posture": Button }.
var _slots: Array = [[], []]
var _stage_label: Label
var _stage_prev: Button
var _stage_next: Button
var _back: Button
var _fight: Button
var _picker: Control = null
var _picking := Vector2i(-1, -1)
var _rng := RandomNumberGenerator.new()
var _backdrop: Texture2D = null


func _ready() -> void:
	_rng.randomize()
	if ResourceLoader.exists("res://assets/arena/fond.jpg"):
		_backdrop = load("res://assets/arena/fond.jpg")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fill_defaults()
	_title = _label("ARÈNE", 30, GOLD)
	_hint = _label("", 14, Color(0.80, 0.85, 0.98))
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for mode in ArenaRules.MODE_NAMES.size():
		var button := _button(str(ArenaRules.MODE_NAMES[mode]), GOLD, 16)
		button.toggle_mode = true
		button.pressed.connect(_set_mode.bind(mode))
		_mode_buttons.append(button)
	for count in ArenaRules.FORMATS:
		var button := _button("%d vs %d" % [count, count], Color("#9fc4ff"), 16)
		button.toggle_mode = true
		button.pressed.connect(_set_format.bind(count))
		_format_buttons.append(button)
	for team in 2:
		var header := _label(["TON ÉQUIPE", "ADVERSAIRES"][team], 17, ArenaRules.TEAM_COLORS[team])
		_team_headers.append(header)
		var shuffle := _button("Hasard", ArenaRules.TEAM_COLORS[team], 13)
		shuffle.pressed.connect(_randomize_team.bind(team))
		_random_buttons.append(shuffle)
		for slot in 3:
			var card := CharacterPortrait.new()
			card.mouse_filter = Control.MOUSE_FILTER_STOP
			card.gui_input.connect(_on_card_input.bind(team, slot))
			add_child(card)
			var caption := _label("", 13, Color.WHITE)
			caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			caption.clip_text = true
			var posture := _button("", ArenaRules.TEAM_COLORS[team], 12)
			posture.pressed.connect(_cycle_posture.bind(team, slot))
			_slots[team].append({"card": card, "name": caption, "posture": posture})
	_stage_prev = _button("◀", Color("#9fe8b4"), 16)
	_stage_next = _button("▶", Color("#9fe8b4"), 16)
	_stage_prev.pressed.connect(_shift_stage.bind(-1))
	_stage_next.pressed.connect(_shift_stage.bind(1))
	_stage_label = _label("", 14, Color("#9fe8b4"))
	_stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_back = _button("RETOUR", MenuStyle.EDGE, 18)
	_back.pressed.connect(func() -> void: back_requested.emit())
	_fight = _button("COMBATTRE", GOLD, 20)
	_fight.pressed.connect(func() -> void: fight_requested.emit(composition()))
	resized.connect(_layout)
	_refresh()
	# Capture : `--arena --arena-pick` ouvre le choix du premier héros.
	if "--arena-pick" in OS.get_cmdline_user_args():
		get_tree().process_frame.connect(_open_picker.bind(0, 0), CONNECT_ONE_SHOT)


## La composition telle que le match la lit : seulement les places du format choisi.
func composition() -> Dictionary:
	var out := setup.duplicate(true)
	var count := int(setup["format"])
	out["team_a"] = (setup["team_a"] as Array).slice(0, count)
	out["team_b"] = (setup["team_b"] as Array).slice(0, count)
	return out


## Une composition déjà faite (revenir de « Équipes » après un match) prime sur le tirage.
func load_setup(previous: Dictionary) -> void:
	if previous.is_empty():
		return
	for key in previous:
		setup[key] = previous[key]
	for team in 2:
		var key := "team_a" if team == 0 else "team_b"
		var picks: Array = setup[key]
		while picks.size() < 3:
			picks.append({"id": _random_id(picks), "posture": ArenaRules.Posture.ASSAULT})
	if is_node_ready():
		_refresh()


func _fill_defaults() -> void:
	var mine := [CharacterCatalog.AEL, CharacterCatalog.FIRE, CharacterCatalog.WATER]
	setup["team_a"] = []
	for i in 3:
		setup["team_a"].append({"id": mine[i], "posture": [ArenaRules.Posture.ASSAULT,
			ArenaRules.Posture.GUARD, ArenaRules.Posture.HUNTER][i]})
	setup["team_b"] = []
	for i in 3:
		setup["team_b"].append({"id": _random_id(setup["team_b"]), "posture": i % 3})


func _random_id(taken: Array) -> String:
	var ids := ArenaRules.roster_ids()
	var used := []
	for pick in taken:
		used.append(pick["id"])
	for attempt in 30:
		var id: String = ids[_rng.randi() % ids.size()]
		if not id in used:
			return id
	return ids[_rng.randi() % ids.size()]


func _set_mode(mode: int) -> void:
	setup["mode"] = mode
	_refresh()


func _set_format(count: int) -> void:
	setup["format"] = count
	_refresh()


func _shift_stage(step: int) -> void:
	setup["stage"] = posmod(int(setup["stage"]) + step, ArenaRules.decor_count())
	_refresh()


func _randomize_team(team: int) -> void:
	var key := "team_a" if team == 0 else "team_b"
	var picks := []
	for i in 3:
		picks.append({"id": _random_id(picks), "posture": [ArenaRules.Posture.ASSAULT,
			ArenaRules.Posture.GUARD, ArenaRules.Posture.HUNTER][_rng.randi() % 3]})
	setup[key] = picks
	_refresh()


func _cycle_posture(team: int, slot: int) -> void:
	var pick: Dictionary = setup["team_a" if team == 0 else "team_b"][slot]
	pick["posture"] = (int(pick["posture"]) + 1) % ArenaRules.POSTURE_NAMES.size()
	_refresh()


func _on_card_input(event: InputEvent, team: int, slot: int) -> void:
	var tapped: bool = (event is InputEventMouseButton and event.pressed
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed)
	if tapped:
		_open_picker(team, slot)


func _refresh() -> void:
	var mode := int(setup["mode"])
	var count := int(setup["format"])
	for i in _mode_buttons.size():
		_mode_buttons[i].button_pressed = i == mode
	for i in _format_buttons.size():
		_format_buttons[i].button_pressed = ArenaRules.FORMATS[i] == count
	_hint.text = "%s — %s.  Touche une carte pour changer de héros, sa posture pour changer ce qu'il fait." % [
		ArenaRules.MODE_NAMES[mode], ArenaRules.MODE_HINTS[mode]]
	for team in 2:
		var picks: Array = setup["team_a" if team == 0 else "team_b"]
		for slot in 3:
			var parts: Dictionary = _slots[team][slot]
			var shown := slot < count
			for part in parts.values():
				(part as Control).visible = shown
			if not shown:
				continue
			var stats := CharacterCatalog.by_id(str(picks[slot]["id"]))
			(parts["card"] as CharacterPortrait).setup(stats)
			(parts["card"] as CharacterPortrait).set_selected(true)
			(parts["name"] as Label).text = stats.display_name
			(parts["posture"] as Button).text = str(ArenaRules.POSTURE_NAMES[int(picks[slot]["posture"])])
			(parts["posture"] as Button).tooltip_text = str(ArenaRules.POSTURE_HINTS[int(picks[slot]["posture"])])
	_stage_label.text = "Décor : %s" % ArenaRules.decor_name(int(setup["stage"]))
	_layout()


func _layout() -> void:
	if _title == null:
		return
	var w := size.x
	var h := size.y
	var m := clampf(w * 0.015, 6.0, 18.0)
	var bar := clampf(h * 0.11, 30.0, 54.0)
	var font := int(clampf(bar * 0.36, 11.0, 18.0))

	# En haut : le titre, les deux modes, les trois formats.
	_title.position = Vector2(m, m)
	_title.size = Vector2(w * 0.16, bar)
	_title.add_theme_font_size_override("font_size", int(clampf(bar * 0.62, 18.0, 34.0)))
	var x := w * 0.17
	var mode_w := w * 0.17
	for button in _mode_buttons:
		_place(button, Vector2(x, m), Vector2(mode_w, bar), font)
		x += mode_w + m * 0.6
	var format_w := w * 0.105
	x = w - m - (format_w * 3.0 + m * 1.2)
	for button in _format_buttons:
		_place(button, Vector2(x, m), Vector2(format_w, bar), font)
		x += format_w + m * 0.6

	var hint_top := m + bar + m * 0.4
	var hint_h := clampf(h * 0.085, 22.0, 40.0)
	_hint.position = Vector2(m, hint_top)
	_hint.size = Vector2(w - m * 2.0, hint_h)
	_hint.add_theme_font_size_override("font_size", int(clampf(hint_h * 0.36, 10.0, 15.0)))

	# En bas : retour, décor, combattre.
	var bottom := h - m - bar
	_place(_back, Vector2(m, bottom), Vector2(w * 0.17, bar), font)
	_place(_fight, Vector2(w - m - w * 0.22, bottom), Vector2(w * 0.22, bar), font + 2)
	var arrow := bar
	var stage_w := w * 0.30
	var stage_x := (w - stage_w) * 0.5
	_place(_stage_prev, Vector2(stage_x - arrow - m * 0.5, bottom), Vector2(arrow, bar), font)
	_place(_stage_next, Vector2(stage_x + stage_w + m * 0.5, bottom), Vector2(arrow, bar), font)
	_stage_label.position = Vector2(stage_x, bottom)
	_stage_label.size = Vector2(stage_w, bar)
	_stage_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_stage_label.add_theme_font_size_override("font_size", font)

	# Au milieu : les deux équipes côte à côte.
	var top := hint_top + hint_h + m * 0.4
	var area_h := bottom - m - top
	var panel_w := (w - m * 3.0) * 0.5
	var header_h := clampf(area_h * 0.13, 18.0, 30.0)
	var posture_h := clampf(area_h * 0.14, 22.0, 34.0)
	var name_h := clampf(area_h * 0.1, 15.0, 24.0)
	var count := int(setup["format"])
	# Les cartes gardent le rapport du cadre (0,82). Quand c'est la LARGEUR qui les borne, le bloc
	# est moins haut que la place : on le centre au lieu de laisser un trou sous les postures.
	var card_h := area_h - header_h - name_h - posture_h - m * 0.8
	var card_w := minf(card_h * 0.82, (panel_w - m * float(count - 1)) / float(count))
	card_h = card_w / 0.82
	top += maxf(0.0, (area_h - (header_h + m * 0.8 + card_h + name_h + posture_h)) * 0.5)
	for team in 2:
		var left := m + float(team) * (panel_w + m)
		_team_headers[team].position = Vector2(left, top)
		_team_headers[team].size = Vector2(panel_w * 0.6, header_h)
		_team_headers[team].add_theme_font_size_override("font_size", int(clampf(header_h * 0.7, 12.0, 20.0)))
		_place(_random_buttons[team], Vector2(left + panel_w - panel_w * 0.28, top), Vector2(panel_w * 0.28, header_h), int(clampf(header_h * 0.55, 10.0, 15.0)))
		var span := card_w * float(count) + m * float(count - 1)
		var cx := left + (panel_w - span) * 0.5
		for slot in 3:
			var parts: Dictionary = _slots[team][slot]
			var card: CharacterPortrait = parts["card"]
			var at := Vector2(cx + float(slot) * (card_w + m), top + header_h + m * 0.4)
			card.position = at
			card.size = Vector2(card_w, card_h)
			card.custom_minimum_size = card.size
			var caption: Label = parts["name"]
			caption.position = at + Vector2(-m * 0.3, card_h)
			caption.size = Vector2(card_w + m * 0.6, name_h)
			caption.add_theme_font_size_override("font_size", int(clampf(name_h * 0.62, 10.0, 15.0)))
			_place(parts["posture"], at + Vector2(0.0, card_h + name_h), Vector2(card_w, posture_h),
				int(clampf(posture_h * 0.42, 9.0, 14.0)))
	if _picker != null:
		_picker.size = size
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKDROP)
	# LE COLISÉE (`assets/arena/fond.jpg`), qui COUVRE l'écran, puis voilé : les cartes, les boutons et
	# le texte se posent dessus, et sur un ciel de crépuscule à pleine lumière ils ne se lisaient plus.
	if _backdrop != null:
		var texture_size := Vector2(_backdrop.get_size())
		var cover := maxf(size.x / texture_size.x, size.y / texture_size.y)
		var drawn := texture_size * cover
		draw_texture_rect(_backdrop, Rect2((size - drawn) * 0.5, drawn), false)
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.03, 0.07, 0.55))
	# Les deux camps se lisent d'abord à leur couleur : un voile de chacune sur sa moitié.
	for team in 2:
		var tint: Color = ArenaRules.TEAM_COLORS[team]
		var half := Rect2(Vector2(size.x * 0.5 * float(team), 0.0), Vector2(size.x * 0.5, size.y))
		for k in 10:
			var a := 0.10 * (1.0 - float(k) / 10.0)
			var strip := half.size.x / 10.0
			var sx := half.position.x + (float(k) * strip if team == 1 else half.size.x - float(k + 1) * strip)
			draw_rect(Rect2(sx, 0.0, strip + 1.0, size.y), Color(tint, a))
	draw_line(Vector2(size.x * 0.5, size.y * 0.25), Vector2(size.x * 0.5, size.y * 0.82), Color(1, 1, 1, 0.12), 2.0)


# --- Le choix d'un héros --------------------------------------------------------------

func _open_picker(team: int, slot: int) -> void:
	_close_picker()
	_picking = Vector2i(team, slot)
	var panel := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.03, 0.06, 0.94)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_picker = panel
	var m := clampf(size.x * 0.015, 6.0, 18.0)
	var bar := clampf(size.y * 0.11, 30.0, 54.0)
	var title := _label("Choisis un héros pour %s" % ["ton équipe", "les adversaires"][team], 18,
		ArenaRules.TEAM_COLORS[team])
	title.reparent(panel)
	title.position = Vector2(m, m)
	title.size = Vector2(size.x * 0.7, bar)
	var close := _button("FERMER", MenuStyle.EDGE, 15)
	close.reparent(panel)
	close.position = Vector2(size.x - m - size.x * 0.16, m)
	close.size = Vector2(size.x * 0.16, bar)
	close.pressed.connect(_close_picker)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	scroll.position = Vector2(m, m * 2.0 + bar)
	scroll.size = Vector2(size.x - m * 2.0, size.y - m * 3.0 - bar)
	var grid := GridContainer.new()
	var columns := clampi(int(scroll.size.x / 92.0), 5, 10)
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", int(m * 0.6))
	grid.add_theme_constant_override("v_separation", int(m * 0.6))
	scroll.add_child(grid)
	var card_w := (scroll.size.x - m * 0.6 * float(columns - 1) - 12.0) / float(columns)
	var current := str(setup["team_a" if team == 0 else "team_b"][slot]["id"])
	for stats in CharacterCatalog.roster():
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 0)
		grid.add_child(cell)
		var card := CharacterPortrait.new()
		card.custom_minimum_size = Vector2(card_w, card_w / 0.82)
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		cell.add_child(card)
		card.setup(stats)
		card.set_selected(stats.id == current)
		card.gui_input.connect(_on_pick_input.bind(stats.id))
		var caption := _label(stats.display_name, 11, Color.WHITE)
		caption.reparent(cell)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.clip_text = true
		caption.custom_minimum_size = Vector2(card_w, 16.0)


func _on_pick_input(event: InputEvent, id: String) -> void:
	var tapped: bool = (event is InputEventMouseButton and event.pressed
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed)
	if not tapped or _picking.x < 0:
		return
	var pick: Dictionary = setup["team_a" if _picking.x == 0 else "team_b"][_picking.y]
	pick["id"] = id
	_close_picker()
	_refresh()


func _close_picker() -> void:
	if _picker != null and is_instance_valid(_picker):
		_picker.queue_free()
	_picker = null
	_picking = Vector2i(-1, -1)


# --- Petits outils ---------------------------------------------------------------------

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.06))
	label.add_theme_constant_override("outline_size", 5)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


func _button(text: String, accent: Color, font_size: int) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.clip_text = true
	MenuStyle.apply(button, accent, font_size)
	add_child(button)
	return button


static func _place(button: Button, at: Vector2, extent: Vector2, font_size: int) -> void:
	button.position = at
	button.size = extent
	button.add_theme_font_size_override("font_size", font_size)
	# La marge intérieure du style (18 px) mange un bouton étroit : on la réduit avec lui.
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := button.get_theme_stylebox(state) as StyleBoxFlat
		if box != null:
			box.content_margin_left = minf(18.0, extent.x * 0.08)
			box.content_margin_right = minf(18.0, extent.x * 0.08)
			box.content_margin_top = minf(10.0, extent.y * 0.12)
			box.content_margin_bottom = minf(10.0, extent.y * 0.12)
