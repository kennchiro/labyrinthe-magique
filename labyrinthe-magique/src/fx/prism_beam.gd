class_name PrismBeam
extends Node2D

## Les deux rayons d'Aël, qui ne se ressemblent pas :
## - le Rayon de gemme de l'Éveillé : du cristal cyan, des facettes qui scintillent sur sa longueur.
##   C'est une gemme qui tire, pas une lance de lumière comme celle du Porte-Lumière.
## - le Prisme ultime (`ultimate`) : une colonne d'or bien plus large, tenue deux fois plus longtemps,
##   avec des anneaux qui filent en spirale le long du rayon et des ondes qui partent de sa bouche.

const GROW := 0.07
const HOLD := 0.22
const FADE := 0.4
const RIM := Color("#16202b")

var _points := PackedVector2Array()
var _width := 12.0
var _colour := Color.WHITE
var _life := 0.0
var _ultimate := false
var _hold := HOLD


func setup(points: PackedVector2Array, tile_size: int, colour: Color, width_tiles: float,
		ultimate := false) -> void:
	_ultimate = ultimate
	_hold = HOLD * (2.4 if ultimate else 1.0)
	_points = points
	_width = float(tile_size) * width_tiles
	_colour = colour
	z_index = 12


func _process(delta: float) -> void:
	_life += delta
	if _life >= GROW + _hold + FADE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	if _points.size() < 2:
		return
	var grow := minf(1.0, _life / GROW)
	var fade := clampf((_life - GROW - _hold) / FADE, 0.0, 1.0)
	var width := _width * (0.4 + 0.6 * grow) * (1.0 - fade * 0.85)
	var alpha := 1.0 - fade
	# Le halo, le cerne, le corps, puis le cœur blanc qui vibre.
	var shimmer := 1.0 + 0.12 * sin(_life * 70.0)
	draw_polyline(_points, Color(_colour, 0.22 * alpha), width * 2.4, true)
	draw_polyline(_points, Color(RIM, 0.5 * alpha), width + 3.0, true)
	draw_polyline(_points, Color(_colour, 0.9 * alpha), width, true)
	draw_polyline(_points, Color(1.0, 1.0, 1.0, alpha), width * 0.38 * shimmer, true)
	var total := _points.size()
	if _ultimate:
		_draw_spiral(width, alpha)
	# Les facettes : des losanges qui scintillent l'un après l'autre le long du rayon.
	for i in (0 if _ultimate else total):
		var at := _points[i]
		var spark := 0.5 + 0.5 * sin(_life * 30.0 - float(i) * 1.7)
		var size := width * (0.25 + 0.2 * spark)
		var tilt := _life * 4.0 + float(i)
		var a := Vector2.from_angle(tilt) * size
		var b := Vector2.from_angle(tilt + PI * 0.5) * size * 0.45
		draw_colored_polygon(PackedVector2Array([at + a, at + b, at - a, at - b]),
			Color(1.0, 1.0, 1.0, 0.75 * alpha * spark))
	# L'éclat à la bouche du rayon et celui qui frappe au bout.
	for end in [_points[0], _points[total - 1]]:
		draw_circle(end, width * 1.1 * (1.0 + 0.3 * (1.0 - grow)), Color(_colour, 0.35 * alpha))
		draw_circle(end, width * 0.55, Color(1.0, 1.0, 1.0, alpha))
		for k in 6:
			var ray := Vector2.from_angle(TAU * float(k) / 6.0 + _life * 3.0)
			draw_line(end + ray * width * 0.6, end + ray * width * (1.6 + 0.6 * grow),
				Color(1.0, 1.0, 1.0, 0.7 * alpha), 2.0)


## Le Prisme ultime : des anneaux filent le long du rayon, et des ondes partent de sa bouche.
func _draw_spiral(width: float, alpha: float) -> void:
	var length := 0.0
	for i in _points.size() - 1:
		length += _points[i].distance_to(_points[i + 1])
	for r in 7:
		var goal := fmod(_life * 900.0 + float(r) * length / 7.0, maxf(length, 1.0))
		var at := _points[0]
		var dir := Vector2.RIGHT
		for i in _points.size() - 1:
			var piece := _points[i].distance_to(_points[i + 1])
			if goal <= piece:
				dir = (_points[i + 1] - _points[i]).normalized()
				at = _points[i] + dir * goal
				break
			goal -= piece
		# Un anneau vu de biais : une ellipse couchée en travers du rayon.
		var ring := PackedVector2Array()
		for k in 21:
			var a := TAU * float(k) / 20.0
			ring.append(at + dir * cos(a) * width * 0.35 + dir.orthogonal() * sin(a) * width * 1.3)
		draw_polyline(ring, Color(1.0, 0.97, 0.85, 0.8 * alpha), 2.0, true)
	for w in 3:
		var t := fmod(_life * 2.5 + float(w) / 3.0, 1.0)
		draw_arc(_points[0], width * (1.0 + 3.0 * t), 0.0, TAU, 40, Color(_colour, 0.6 * (1.0 - t) * alpha), 3.0, true)
