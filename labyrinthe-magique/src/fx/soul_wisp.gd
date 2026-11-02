class_name SoulWisp
extends Node2D

## Une âme en chasse : une petite flamme couleur d'os aux yeux de braise, qui file par les couloirs
## en ondulant et laisse un filet pâle. Elle sert aussi au retour d'une âme vers le mage.

const BONE := Color("#e6dfca")
const EMBER := Color("#ff6a2b")
const RIM := Color("#14131c")
const TRAIL_POINTS := 10
const TRAIL_REACH := 0.28
const SWAY_TILES := 0.12

var _points := PackedVector2Array()
var _duration := 0.5
var _time := 0.0
var _tile := 32.0
var _length := 1.0


func setup(points: PackedVector2Array, tile_size: int, duration: float) -> void:
	_points = points
	_tile = float(tile_size)
	_duration = maxf(0.1, duration)
	_length = 0.0
	for i in points.size() - 1:
		_length += points[i].distance_to(points[i + 1])
	z_index = 11
	# Le chemin suit le sol en coordonnées du monde : aucun redressement de la vue 2,5D.
	scale = Vector2.ONE


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration:
		queue_free()
		return
	queue_redraw()


func _at(fraction: float) -> Vector2:
	var left := clampf(fraction, 0.0, 1.0) * _length
	for i in _points.size() - 1:
		var span := _points[i].distance_to(_points[i + 1])
		if left <= span:
			var along := (_points[i + 1] - _points[i]) / maxf(0.001, span)
			var sway := sin(fraction * 26.0 + _points[0].x) * SWAY_TILES * _tile
			return _points[i] + along * left + along.orthogonal() * sway
		left -= span
	return _points[_points.size() - 1]


func _draw() -> void:
	var head := _time / _duration
	var trail := PackedVector2Array()
	for i in TRAIL_POINTS + 1:
		trail.append(_at(head - TRAIL_REACH * float(TRAIL_POINTS - i) / float(TRAIL_POINTS)))
	draw_polyline(trail, Color(RIM, 0.75), _tile * 0.1, true)
	draw_polyline(trail, Color(BONE, 0.85), _tile * 0.05, true)
	SoulWisp.draw_flame(self, _at(head), _tile * 0.32, 1.0, _time * 14.0)


## La flamme d'une âme, partagée avec celles qui tournent autour du mage.
static func draw_flame(canvas: CanvasItem, at: Vector2, size: float, alpha: float, clock: float) -> void:
	var lick := sin(clock) * size * 0.16
	var flick := sin(clock * 1.7 + 1.0) * size * 0.12
	var flame := PackedVector2Array([at + Vector2(lick, -size * 1.4), at + Vector2(size * 0.14, -size * 0.72),
		at + Vector2(size * 0.48 + flick, -size * 0.98), at + Vector2(size * 0.42, -size * 0.3),
		at + Vector2(size * 0.72 - flick, -size * 0.46), at + Vector2(size * 0.66, size * 0.2),
		at + Vector2(size * 0.3, size * 0.62), at + Vector2(-size * 0.3, size * 0.62),
		at + Vector2(-size * 0.66, size * 0.2), at + Vector2(-size * 0.72 + flick, -size * 0.5),
		at + Vector2(-size * 0.38, -size * 0.34), at + Vector2(-size * 0.5 - flick, -size * 0.92),
		at + Vector2(-size * 0.12, -size * 0.7)])
	canvas.draw_colored_polygon(flame, Color(BONE, alpha))
	flame.append(flame[0])
	canvas.draw_polyline(flame, Color(RIM, alpha), 1.5, true)
	for side: float in [-1.0, 1.0]:
		var eye := at + Vector2(side * size * 0.24, size * 0.1)
		canvas.draw_colored_polygon(PackedVector2Array([eye + Vector2(-side * size * 0.14, -size * 0.1),
			eye + Vector2(side * size * 0.14, -size * 0.04), eye + Vector2(0.0, size * 0.1)]), Color(EMBER, alpha))
