class_name HeroDemoPicker
extends HBoxContainer

## Choisir ou rejouer une évolution dans l’arène, sans écrire la progression.
signal form_requested(form: int)
const LABELS := ["Apprenti", "I · Éveillé", "II · Ascendant", "III · Prisme", "IV · Dragon d’or"]
var choice := OptionButton.new()
var advance := Button.new()
var _form := 0

func _ready() -> void:
	name = "HeroDemoPicker"
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_theme_constant_override("separation", 6)
	choice.name = "Form"
	choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choice.focus_mode = Control.FOCUS_NONE
	for form in LABELS.size():
		choice.add_item("%s · niv. %d" % [LABELS[form], CharacterCatalog.AEL_FORM_LEVELS[form]], form)
	choice.item_selected.connect(func(index: int) -> void: form_requested.emit(index))
	add_child(choice)
	advance.name = "Evolve"
	advance.focus_mode = Control.FOCUS_NONE
	advance.text = "Évoluer"
	advance.custom_minimum_size = Vector2(78, 36)
	advance.pressed.connect(func() -> void: form_requested.emit(2 if _form == LABELS.size() - 1 else _form + 1))
	add_child(advance)
	MenuStyle.apply(choice, Color("#8fe3ff"), 12)
	MenuStyle.apply(advance, Color("#ffd479"), 12)
	# Les marges de menu ordinaires ne tiendraient pas dans le bandeau mobile.
	for button in [choice, advance]:
		for state in ["normal", "hover", "pressed", "focus", "disabled"]:
			var style := button.get_theme_stylebox(state) as StyleBoxFlat
			style.content_margin_left = 7.0
			style.content_margin_right = 7.0
			style.content_margin_top = 4.0
			style.content_margin_bottom = 4.0

func set_form(form: int, rank: int) -> void:
	_form = clampi(form, 0, LABELS.size() - 1)
	for index in LABELS.size():
		choice.set_item_text(index, "%s · niv. %d" % [LABELS[index], rank if index == _form else int(CharacterCatalog.AEL_FORM_LEVELS[index])])
	if choice.selected != _form:
		choice.select(_form)
	advance.text = "Revenir" if _form == LABELS.size() - 1 else "Évoluer"
