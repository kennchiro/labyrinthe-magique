class_name CharacterPortrait
extends Control

## Vignette d'un personnage : son sprite, son aura élémentaire, son cadre.
##
## Le sprite vient de SA planche — première pose de la marche de face, celle où
## il regarde le joueur. Chaque mage est donc reconnaissable au premier coup
## d'œil, ce qui est tout l'intérêt d'un écran de sélection.

const CHARACTERS_PATH := "res://assets/characters/"

var stats: CharacterStats = null
var selected := false

var _texture: Texture2D = null
var _cell := Vector2(128.0, 112.0)
var _time := 0.0


func setup(p_stats: CharacterStats) -> void:
	stats = p_stats
	_texture = load(CHARACTERS_PATH + stats.id + "/down.png")
	var text := FileAccess.get_file_as_string(CHARACTERS_PATH + stats.id + "/frames.json")
	var parsed: Variant = JSON.parse_string(text)
	if parsed != null:
		var cell: Array = (parsed as Dictionary)["cell"]
		_cell = Vector2(float(cell[0]), float(cell[1]))
	queue_redraw()


func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if selected:
		queue_redraw()


func _draw() -> void:
	if stats == null or _texture == null:
		return
	var color := stats.color()
	var centre := size * 0.5
	var pulse := 0.5 + 0.5 * sin(_time * 2.4)

	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.07, 0.13, 0.85))
	# L'aura ne s'allume que sur le personnage choisi : c'est le seul retour qui
	# dit « c'est celui-là que tu emmènes ».
	if selected:
		draw_rect(Rect2(Vector2.ZERO, size), Color(color.r, color.g, color.b, 0.14 + 0.06 * pulse))
		draw_circle(centre, size.x * (0.52 + 0.05 * pulse), Color(color.r, color.g, color.b, 0.11))

	# Première pose de la marche de face : le mage regarde le joueur.
	var target := size.y * 0.80
	var factor := target / _cell.y
	var drawn := _cell * factor
	draw_texture_rect_region(_texture,
		Rect2(centre - Vector2(drawn.x * 0.5, drawn.y * 0.56), drawn),
		Rect2(Vector2.ZERO, _cell))

	var edge := color if selected else Color(0.32, 0.38, 0.52)
	draw_rect(Rect2(Vector2.ZERO, size), edge, false, 3.0 if selected else 1.5)
