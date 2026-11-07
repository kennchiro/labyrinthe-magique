class_name CrystalLine
extends Node2D

## La Frappe éclair de l'Éveillé : un trait de lumière file au sol dans le couloir, et des aiguilles
## de cristal en jaillissent derrière lui, case après case, puis restent plantées le temps du sort.
## Les Pics de la Terre sont de la roche brune qui s'arrache ; ici, du cristal net et lumineux.

const RISE := 0.12
const SINK := 0.35
const RIM := Color("#16202b")

var _points := PackedVector2Array()
var _step := 0.05
var _stay := 1.0
var _tile := 32.0
var _colour := Color.WHITE
var _life := 0.0


func setup(points: PackedVector2Array, duration: float, stay: float, tile_size: int, colour: Color) -> void:
	_points = points
	_step = duration / maxf(1.0, float(points.size()))
	_stay = maxf(0.4, stay)
	_tile = float(tile_size)
	_colour = colour
	z_index = 9


func _process(delta: float) -> void:
	_life += delta
	if _life >= _step * float(_points.size()) + _stay + SINK:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	# Le trait de tête, qui court devant les aiguilles.
	var head := clampf(_life / maxf(_step * float(_points.size()), 0.001), 0.0, 1.0)
	var lead := int(head * float(_points.size() - 1))
	if head < 1.0 and _points.size() > 1:
		var at := _points[lead].lerp(_points[mini(lead + 1, _points.size() - 1)],
			head * float(_points.size() - 1) - float(lead))
		draw_line(_points[0], at, Color(1.0, 1.0, 1.0, 0.8), 3.0)
		draw_circle(at, _tile * 0.22, Color(_colour, 0.6))
		draw_circle(at, _tile * 0.1, Color.WHITE)
	# Le sillage lumineux qui reste au sol tant que les aiguilles tiennent.
	var reached := mini(_points.size(), int(_life / maxf(_step, 0.001)) + 1)
	if reached >= 2:
		var trail := _points.slice(0, reached)
		var stay := 1.0 - clampf((_life - _step * float(_points.size()) - _stay) / SINK, 0.0, 1.0)
		draw_polyline(trail, Color(_colour, 0.35 * stay), _tile * 0.5, true)
		draw_polyline(trail, Color(1.0, 1.0, 1.0, 0.8 * stay), _tile * 0.12, true)
	for i in _points.size():
		var born := _step * float(i)
		var age := _life - born
		if age < 0.0:
			continue
		var rise := minf(1.0, age / RISE)
		var sink := clampf((age - _stay) / SINK, 0.0, 1.0)
		var height := _tile * 1.0 * rise * (1.0 - sink)
		if height <= 0.5:
			continue
		# Trois aiguilles par case, de tailles et d'inclinaisons différentes.
		for k in 3:
			var lean := (float(k) - 1.0) * 0.38 + sin(float(i) * 2.3) * 0.12
			var base := _points[i] + Vector2((float(k) - 1.0) * _tile * 0.2, _tile * 0.12)
			var tip := base + Vector2(sin(lean), -cos(lean)) * height * (0.75 + 0.25 * float(k % 2))
			var side := Vector2(_tile * 0.07, 0.0)
			draw_colored_polygon(PackedVector2Array([base - side * 1.4, tip + Vector2(0, -2), base + side * 1.4]),
				Color(RIM, 0.55 * (1.0 - sink)))
			draw_colored_polygon(PackedVector2Array([base - side, tip, base + side]),
				Color(_colour, 0.92 * (1.0 - sink)))
			draw_line(base, tip, Color(1.0, 1.0, 1.0, 0.85 * (1.0 - sink)), 1.2)
		# L'éclat de naissance de chaque case.
		if age < RISE * 1.5:
			draw_circle(_points[i], _tile * 0.4 * (1.0 - age / (RISE * 1.5)), Color(1.0, 1.0, 1.0, 0.6))
