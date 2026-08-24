class_name MenuStyle
extends RefCounted

## Habillage des boutons de menu, en un seul endroit.
##
## Les boutons Godot par défaut sont gris et plats : posés sur une forêt de nuit,
## ils ressemblent à une boîte de dialogue système, pas à l'entrée d'un jeu.
## On les redessine en code plutôt qu'en ressource `.tres` — trois StyleBox par
## bouton et par état feraient une douzaine de fichiers à maintenir pour ce qui
## tient en vingt lignes.

const EDGE := Color(0.42, 0.50, 0.75)


static func _box(fill: Color, border: Color, width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(6)
	box.content_margin_left = 18.0
	box.content_margin_right = 18.0
	box.content_margin_top = 10.0
	box.content_margin_bottom = 10.0
	return box


## `accent` colore la bordure et le survol : un bouton d'action principal se
## distingue ainsi d'un simple retour, sans changer sa forme.
static func apply(button: Button, accent: Color = EDGE, font_size: int = 20) -> void:
	button.add_theme_stylebox_override("normal",
		_box(Color(0.06, 0.08, 0.15, 0.92), Color(accent.r, accent.g, accent.b, 0.55), 2))
	button.add_theme_stylebox_override("hover",
		_box(Color(0.11, 0.15, 0.26, 0.96), accent, 2))
	button.add_theme_stylebox_override("pressed",
		_box(Color(accent.r * 0.35, accent.g * 0.35, accent.b * 0.35, 0.98), accent, 3))
	button.add_theme_stylebox_override("focus",
		_box(Color(0.09, 0.12, 0.22, 0.94), accent, 3))
	button.add_theme_stylebox_override("disabled",
		_box(Color(0.05, 0.06, 0.10, 0.7), Color(0.3, 0.34, 0.44, 0.4), 1))
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color(0.90, 0.94, 1.0))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.07))
	button.add_theme_constant_override("outline_size", 5)
