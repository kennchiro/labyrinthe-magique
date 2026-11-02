class_name StarTrail
extends Node2D

## La traînée de l'Étoile filante : effilée vers l'arrière, elle reste un instant au sol, là où elle
## vient de brûler ce qui passait, et des points s'en détachent. La Charge de l'Archange d'Acier la
## reprend dans ses couleurs.

const SHINE := Color("#dbe6ff")
const BLUE := Color("#7fa2ff")
const RIM := Color("#0a1030")
const STEEL_COLORS := {"shine": Color("#dfe6ee"), "body": Color("#ff8a2a"), "rim": Color("#161b22"),
	"dot": Color("#ffb066")}
const LIFE := 0.55
const STEPS := 12
const DOTS := 8

var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _tile := 32.0
var _time := 0.0
var _colors := {"shine": SHINE, "body": BLUE, "rim": RIM, "dot": Color.WHITE}


func setup(from: Vector2, to: Vector2, tile_size: int, colors: Dictionary = {}) -> void:
	if not colors.is_empty():
		_colors = colors
	_from = from
	_to = to
	_tile = float(tile_size)
	z_index = 9
	# Elle suit le sol en coordonnées du monde : aucun redressement de la vue 2,5D.
	scale = Vector2.ONE


func _process(delta: float) -> void:
	_time += delta
	if _time >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var life := _time / LIFE
	var fade := 1.0 - smoothstep(0.4, 1.0, life)
	var side := (_to - _from).orthogonal().normalized()
	var layers: Array[Array] = [[0.3, _colors["rim"]], [0.22, _colors["body"]], [0.1, _colors["shine"]]]
	for layer in layers:
		var shape := PackedVector2Array()
		for i in STEPS + 1:
			var t := float(i) / float(STEPS)
			shape.append(_from.lerp(_to, t) + side * t * _tile * float(layer[0]))
		for i in range(STEPS, -1, -1):
			var t := float(i) / float(STEPS)
			shape.append(_from.lerp(_to, t) - side * t * _tile * float(layer[0]))
		draw_colored_polygon(shape, Color(layer[1], fade))
	for i in DOTS:
		var t := (float(i) + 0.5) / float(DOTS)
		var at := _from.lerp(_to, t) + side * sin(float(i) * 2.3) * _tile * (0.3 + life * 0.3)
		draw_circle(at, _tile * 0.05 * (1.0 - life * 0.6), Color(_colors["dot"], fade))
