class_name TouchLayoutEditor
extends Control

## L'éditeur de disposition : on glisse les vraies commandes, on règle leur taille et
## leur opacité, on enregistre. Touche un bouton pour le régler seul, touche ailleurs
## pour les régler tous.
##
## Il dessine SES PROPRES TouchStick et CombatPad, en aperçu, et non ceux de la partie :
## il s'ouvre aussi depuis l'écran-titre, où il n'y en a pas. Ce sont les mêmes classes,
## donc ce qu'on place ici est ce qu'on aura en jouant.
##
## Tout se fait sur un BROUILLON, que seul « Enregistrer » écrit. Annuler n'a donc rien
## à défaire.

signal closed

## La sélection « tous les boutons ».
const ALL := ""
## En deçà, un appui reste un appui : il sélectionne sans déplacer.
const DRAG_THRESHOLD := 6.0
## Un bouton répond à 12 unités au-delà de son dessin (`CombatPad._slot_at`), et `GAP` en
## sépare déjà 8 du manche : ces 4 unités évitent qu'un même pouce saisisse les deux.
const STICK_CLEARANCE := 4.0
const SPOT_TOLERANCE := 10.0
const NAMES := ["Frappe", "Sort 1", "Sort 2", "Sort 3", "Fuite", "Extra Hit"]

## Le personnage dont on montre les sorts.
var character_id := CharacterCatalog.default_id()

var _draft: TouchLayout
var _stick: TouchStick
var _pad: CombatPad
var _marks: Control
var _toolbar: PanelContainer
var _title: Label
var _size_label: Label
var _alpha_label: Label
var _size_slider: HSlider
var _alpha_slider: HSlider
var _selected := ALL
var _finger := -1
var _dragged := ""
var _grab_offset := Vector2.ZERO
var _press_point := Vector2.ZERO
var _moved := false
var _before_drag := {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_draft = TouchLayout.from_data(Settings.touch_layout().to_data())

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.03, 0.08, 0.88)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	_stick = TouchStick.new()
	_stick.layout = _draft
	_stick.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_stick)
	_stick.set_style(TouchStick.Style.CROSS if Settings.move_mode() == Settings.MOVE_CROSS
		else TouchStick.Style.ANALOG)
	_stick.set_preview()

	_pad = CombatPad.new()
	_pad.layout = _draft
	_pad.preview = true
	_pad.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_pad)
	_pad.visible = true
	_pad.set_entries(_preview_entries())

	_marks = Control.new()
	_marks.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_marks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_marks.draw.connect(_draw_marks)
	add_child(_marks)

	_build_toolbar()
	_select(ALL)
	resized.connect(_refresh)
	_refresh.call_deferred()


## Les sorts du personnage, tous prêts : ni recharge ni cadenas, pour voir le bouton
## tel qu'il est, sans rien de ce qui change en jouant.
func _preview_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var bar := CharacterCatalog.by_id(character_id).action_bar()
	for slot in bar.size():
		var ability: Ability = bar[slot]
		entries.append({
			"slot": slot, "color": Element.color(ability.element), "ready": true, "ratio": 1.0,
			"icon": UiIcons.for_ability(character_id, ability.id),
			"charges": -1, "charges_max": 1, "locked": false, "highlight": false,
		})
	return entries


func _build_toolbar() -> void:
	_toolbar = PanelContainer.new()
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.05, 0.07, 0.13, 0.95)
	box.border_color = Color(MenuStyle.EDGE, 0.6)
	box.set_border_width_all(1)
	box.set_corner_radius_all(6)
	box.set_content_margin_all(6.0)
	_toolbar.add_theme_stylebox_override("panel", box)
	add_child(_toolbar)

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 4)
	_toolbar.add_child(rows)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 11)
	_title.add_theme_color_override("font_color", Color("#ffd479"))
	rows.add_child(_title)

	var sliders := HBoxContainer.new()
	sliders.add_theme_constant_override("separation", 6)
	rows.add_child(sliders)
	_size_label = _slider_label(sliders)
	_size_slider = _slider(sliders, TouchLayout.MIN_SCALE, TouchLayout.MAX_SCALE, _on_size_changed)
	_alpha_label = _slider_label(sliders)
	_alpha_slider = _slider(sliders, TouchLayout.MIN_ALPHA, 1.0, _on_alpha_changed)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 4)
	rows.add_child(buttons)
	_button(buttons, "Gaucher", MenuStyle.EDGE, mirror)
	_button(buttons, "Défaut", MenuStyle.EDGE, reset)
	_button(buttons, "Annuler", MenuStyle.EDGE, func() -> void: closed.emit())
	_button(buttons, "Enregistrer", Color("#ffd479"), save)


func _slider_label(parent: Control) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", 11)
	label.custom_minimum_size.x = 74.0
	parent.add_child(label)
	return label


func _slider(parent: Control, low: float, high: float, on_change: Callable) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = low
	slider.max_value = high
	slider.step = 0.05
	slider.focus_mode = Control.FOCUS_NONE
	slider.custom_minimum_size = Vector2(92.0, 26.0)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(on_change)
	parent.add_child(slider)
	return slider


func _button(parent: Control, text: String, accent: Color, on_press: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	MenuStyle.apply(button, accent, 12)
	for state in ["normal", "hover", "pressed", "focus"]:
		var box: StyleBoxFlat = button.get_theme_stylebox(state)
		box.content_margin_left = 12.0
		box.content_margin_right = 12.0
		box.content_margin_top = 7.0
		box.content_margin_bottom = 7.0
	button.pressed.connect(on_press)
	parent.add_child(button)


# --- Les gestes -------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _finger < 0:
			_press(event.index, event.position)
		elif not event.pressed and event.index == _finger:
			_release()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == _finger:
		_drag_to(event.position)
		get_viewport().set_input_as_handled()


## Une commande passe avant la barre d'outils qu'elle recouvre : sinon elle deviendrait
## impossible à récupérer une fois glissée dessous.
func _press(finger: int, point: Vector2) -> void:
	var id := control_at(point)
	if id.is_empty():
		if not _toolbar.get_global_rect().has_point(point):
			_select(ALL)
		return
	_select(id)
	_finger = finger
	_dragged = id
	_moved = false
	_press_point = point
	_grab_offset = _item(id)["at"] - point
	_before_drag = _draft.to_data()
	_toolbar.hide()
	get_viewport().set_input_as_handled()


func _drag_to(point: Vector2) -> void:
	if not _moved and point.distance_to(_press_point) < DRAG_THRESHOLD:
		return
	_moved = true
	_draft.set_centre(_dragged, TouchLayout.kept_on_screen(point + _grab_offset, size,
		_item(_dragged)["extent"]), size)
	_refresh()


## Le bouton lâché se pose à la place libre la plus proche. S'il n'y en a pas, il revient
## d'où il venait : mieux vaut un geste refusé qu'un bouton sur un autre.
func _release() -> void:
	var id := _dragged
	_finger = -1
	_dragged = ""
	_toolbar.show()
	if _moved and not _commit([id]):
		_draft.custom = _before_drag
		_title.text = "Pas de place ici"
	_refresh()


func control_at(point: Vector2) -> String:
	var best := ""
	var nearest := INF
	for item in _items():
		var distance: float = point.distance_to(item["at"])
		if distance <= float(item["extent"]) + SPOT_TOLERANCE and distance < nearest:
			nearest = distance
			best = item["id"]
	return best


func _select(id: String) -> void:
	_selected = id
	_title.text = _name_of(id)
	_sync_sliders()
	_marks.queue_redraw()


func _name_of(id: String) -> String:
	if id == ALL:
		return "Toutes les commandes  ·  touches-en une pour la régler seule"
	if id == TouchLayout.MOVE:
		return "La croix" if _stick.style == TouchStick.Style.CROSS else "Le manche"
	return NAMES[int(id.substr(1))]


func _targets() -> Array[String]:
	var ids: Array[String] = []
	if _selected != ALL:
		ids.append(_selected)
		return ids
	for item in _items():
		ids.append(item["id"])
	return ids


func _on_size_changed(value: float) -> void:
	var before := _draft.to_data()
	var ids := _targets()
	for id in ids:
		_draft.set_scale(id, value)
	if not _commit(ids):
		# L'écran n'en tient pas plus : le curseur revient à la dernière taille possible.
		_draft.custom = before
		_title.text = "Plus de place pour grandir"
	_sync_sliders()
	_refresh()


func _on_alpha_changed(value: float) -> void:
	for id in _targets():
		_draft.set_alpha(id, value)
	_sync_sliders()
	_refresh()


## Passe le jeu d'une main à l'autre, en miroir. Dit si la place suffisait.
func mirror() -> bool:
	var before := _draft.to_data()
	var ids: Array[String] = []
	for item in _items():
		ids.append(item["id"])
		_draft.set_centre(item["id"], Vector2(size.x - item["at"].x, item["at"].y), size)
	var done := _commit(ids)
	if not done:
		_draft.custom = before
		_title.text = "Cet écran est trop petit pour ça"
	_refresh()
	return done


func reset() -> void:
	_draft.custom = {}
	_select(ALL)
	_refresh()


func save() -> void:
	Settings.save_touch_layout(_draft)
	closed.emit()


# --- La géométrie -----------------------------------------------------------------

func _items() -> Array[Dictionary]:
	var items: Array[Dictionary] = [{
		"id": TouchLayout.MOVE, "at": _stick._origin(),
		"radius": _stick.grab_radius() + STICK_CLEARANCE, "extent": _stick.visual_radius(),
	}]
	for i in _pad.entries.size():
		items.append({
			"id": TouchLayout.button_id(i), "at": _pad._centre(i),
			"radius": _pad._radius(i), "extent": _pad._radius(i),
		})
	return items


func _item(id: String) -> Dictionary:
	for item in _items():
		if item["id"] == id:
			return item
	return {}


## Écarte ce qui gêne, et n'écrit que ce qui a bougé : un bouton resté à sa place déduite
## continue de la suivre.
func _commit(movable: Array[String]) -> bool:
	var items := _items()
	var was := {}
	for item in items:
		was[item["id"]] = item["at"]
	if not TouchLayout.settle(items, size, movable):
		return false
	for item in items:
		if Vector2(item["at"]).distance_to(was[item["id"]]) > 0.01:
			_draft.set_centre(item["id"], item["at"], size)
	return true


func _sync_sliders() -> void:
	var id: String = _selected if _selected != ALL else TouchLayout.MOVE
	var scale_value := _draft.scale_of(id)
	var alpha_value := _draft.alpha_of(id)
	_size_slider.set_value_no_signal(scale_value)
	_alpha_slider.set_value_no_signal(alpha_value)
	_size_label.text = "Taille %d %%" % roundi(scale_value * 100.0)
	_alpha_label.text = "Opacité %d %%" % roundi(alpha_value * 100.0)


func _refresh() -> void:
	_pad.queue_redraw()
	_stick.queue_redraw()
	_marks.queue_redraw()
	_place_toolbar()


## La barre d'outils prend le coin qui recouvre le moins de commandes. Elle ne peut pas
## avoir de place fixe : elles peuvent toutes aller n'importe où.
func _place_toolbar() -> void:
	var extent := _toolbar.get_combined_minimum_size()
	_toolbar.size = extent
	var spots := [Vector2(4.0, 4.0), Vector2(size.x - extent.x - 4.0, 4.0),
		Vector2((size.x - extent.x) * 0.5, size.y - extent.y - 4.0)]
	var best: Vector2 = spots[0]
	var least := 99
	for spot: Vector2 in spots:
		var box := Rect2(spot, extent)
		var hidden_count := 0
		for item in _items():
			var at: Vector2 = item["at"]
			if at.distance_to(at.clamp(box.position, box.end)) < float(item["extent"]):
				hidden_count += 1
		if hidden_count < least:
			least = hidden_count
			best = spot
	_toolbar.position = best


func _draw_marks() -> void:
	var moving := not _dragged.is_empty() and _moved
	if moving:
		for zone in TouchLayout.reserved(size):
			_marks.draw_rect(zone, Color(1.0, 0.35, 0.3, 0.16))
	var items := _items()
	var blocked: Array[String] = []
	if moving:
		var only: Array[String] = [_dragged]
		blocked = TouchLayout.conflicts(items, size, only)
	for item in items:
		var picked: bool = _selected == ALL or item["id"] == _selected
		var color := Color(1.0, 0.82, 0.48, 0.85) if picked else Color(0.75, 0.8, 0.95, 0.3)
		if item["id"] in blocked:
			color = Color(1.0, 0.3, 0.25)
		_marks.draw_arc(item["at"], float(item["extent"]) + 3.0, 0.0, TAU, 48, color, 2.0)
