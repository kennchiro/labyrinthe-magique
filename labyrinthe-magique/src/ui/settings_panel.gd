class_name SettingsPanel
extends Control

## Les réglages du joueur, ouverts depuis la pause ou depuis l'écran-titre. Construit en
## code et posé par-dessus l'écran qui l'ouvre : il n'en sait rien, et il n'écrit que
## dans `Settings`.

signal closed

const MODES := [
	[Settings.MOVE_STICK, "Manche", "Glisse le pouce : le mage suit le manche."],
	[Settings.MOVE_CROSS, "Croix", "Quatre directions nettes : touche un côté, le mage y va."],
	[Settings.MOVE_TAP, "Toucher le chemin", "Touche une case visible : le mage y marche seul."],
]

## Le personnage dont l'éditeur montrera les sorts.
var character_id := CharacterCatalog.default_id()

var _content: Control
var _dim: ColorRect
var _hint: Label
var _mode_buttons := {}
var _editor: TouchLayoutEditor = null


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_dim = ColorRect.new()
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dim.color = Color(0.02, 0.02, 0.07, 0.9)
	add_child(_dim)

	_content = CenterContainer.new()
	_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_content)

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 10)
	_content.add_child(rows)

	var title := Label.new()
	title.text = "RÉGLAGES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#9fb4e8"))
	rows.add_child(title)

	var caption := Label.new()
	caption.text = "Déplacement"
	caption.add_theme_font_size_override("font_size", 14)
	rows.add_child(caption)

	var choices := HBoxContainer.new()
	choices.add_theme_constant_override("separation", 8)
	rows.add_child(choices)
	var group := ButtonGroup.new()
	for mode: Array in MODES:
		var button := Button.new()
		button.text = str(mode[1])
		button.toggle_mode = true
		button.button_group = group
		button.focus_mode = Control.FOCUS_NONE
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 52.0
		MenuStyle.apply(button, Color("#ffd479"), 15)
		button.pressed.connect(_on_mode_chosen.bind(str(mode[0])))
		choices.add_child(button)
		_mode_buttons[mode[0]] = button

	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 13)
	_hint.add_theme_color_override("font_color", Color(0.72, 0.78, 0.92))
	rows.add_child(_hint)

	var layout_button := Button.new()
	layout_button.text = "Disposition des commandes"
	layout_button.focus_mode = Control.FOCUS_NONE
	layout_button.custom_minimum_size.y = 52.0
	MenuStyle.apply(layout_button, Color("#9fe8b4"), 15)
	layout_button.pressed.connect(open_editor)
	rows.add_child(layout_button)

	var close_button := Button.new()
	close_button.text = "Fermer"
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.custom_minimum_size.y = 52.0
	MenuStyle.apply(close_button, MenuStyle.EDGE, 15)
	close_button.pressed.connect(func() -> void: closed.emit())
	rows.add_child(close_button)

	_show_mode(Settings.move_mode())


func open_editor() -> void:
	if _editor != null:
		return
	_editor = TouchLayoutEditor.new()
	_editor.character_id = character_id
	_editor.closed.connect(_close_editor)
	_content.hide()
	_dim.hide()
	add_child(_editor)


func _close_editor() -> void:
	_editor.queue_free()
	_editor = null
	_content.show()
	_dim.show()


func _on_mode_chosen(mode: String) -> void:
	Settings.set_move_mode(mode)
	_show_mode(mode)


func _show_mode(mode: String) -> void:
	_mode_buttons[mode].button_pressed = true
	for entry: Array in MODES:
		if entry[0] == mode:
			_hint.text = str(entry[2])
