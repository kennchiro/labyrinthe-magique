class_name BossBar
extends Control

## La barre de vie du boss, en haut de l'écran : son nom et ce qu'il lui reste.
##
## Placée sous le bandeau du mage, centrée, et rétrécie sur un écran étroit : les boutons
## de pause et de carnet tiennent le coin droit.

const WIDTH := 420.0
const HEIGHT := 14.0
const TOP := 34.0
## En démo, la barre des décors tient déjà le haut de l'écran.
const TOP_UNDER_DEMO_BAR := 92.0
const SIDE_MARGIN := 110.0
const NAME_SIZE := 15

var top := TOP
var _name := ""
var _ratio := 1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_viewport().size_changed.connect(queue_redraw)


func set_state(boss_name: String, ratio: float) -> void:
	if boss_name == _name and is_equal_approx(ratio, _ratio):
		return
	_name = boss_name
	_ratio = ratio
	queue_redraw()


func _draw() -> void:
	# Sur la taille de l'écran : un CanvasLayer ne donne pas la sienne à ses enfants.
	var view := get_viewport_rect().size
	var width := minf(WIDTH, view.x - SIDE_MARGIN * 2.0)
	var origin := Vector2((view.x - width) * 0.5, top)
	var font := get_theme_default_font()
	draw_string_outline(font, origin + Vector2(0.0, -5.0), _name, HORIZONTAL_ALIGNMENT_CENTER,
		width, NAME_SIZE, 4, Color(0.02, 0.03, 0.06))
	draw_string(font, origin + Vector2(0.0, -5.0), _name, HORIZONTAL_ALIGNMENT_CENTER,
		width, NAME_SIZE, Color("#ffd9c9"))
	draw_rect(Rect2(origin - Vector2(2.0, 2.0), Vector2(width + 4.0, HEIGHT + 4.0)),
		Color(0.02, 0.03, 0.06, 0.9))
	draw_rect(Rect2(origin, Vector2(width, HEIGHT)), Color(0.28, 0.06, 0.08, 0.95))
	draw_rect(Rect2(origin, Vector2(width * clampf(_ratio, 0.0, 1.0), HEIGHT)), Color("#e0463a"))
	draw_rect(Rect2(origin, Vector2(width, HEIGHT)), Color("#ffd9c9"), false, 1.0)
