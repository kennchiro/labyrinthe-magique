class_name VenomThread
extends Node2D

## Le filet de venin de la Contagion et de la Transfusion : il COULE le long du couloir, et
## des gouttes le remontent. Ni trait brisé ni éclat : c'est ce qui le sépare d'un éclair.

const VENOM := Color("#b4f02a")
const SHADE := Color("#4e8a12")
const RIM := Color("#1e3a0c")
const SHINE := Color("#f2ff9e")
const WOBBLE_TILES := 0.13
const DROPS := 5
## La part de vie où le filet se déroule ; il s'efface ensuite.
const RUN := 0.62

var _points := PackedVector2Array()
var _duration := 0.5
var _time := 0.0
var _tile := 32.0
var _length := 1.0
var _phase := 0.0


func setup(points: PackedVector2Array, tile_size: int, duration: float) -> void:
	_tile = float(tile_size)
	_duration = maxf(0.1, duration)
	_phase = points[0].x * 0.13
	z_index = 9
	# Le chemin suit le sol en coordonnées du monde : aucun redressement de la vue 2,5D.
	scale = Vector2.ONE
	_points = _sinuous(points)
	_length = 0.0
	for i in _points.size() - 1:
		_length += _points[i].distance_to(_points[i + 1])


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration:
		queue_free()
		return
	queue_redraw()


## Le chemin subdivisé, chaque point écarté de part et d'autre : il serpente.
func _sinuous(path: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in path.size() - 1:
		var along := path[i + 1] - path[i]
		var side := along.orthogonal().normalized()
		var steps := maxi(2, int(along.length() / (_tile * 0.2)))
		for step in steps:
			var at := float(step) / float(steps)
			var sway := sin(float(i) * 1.7 + at * 6.3 + _phase) * sin(at * PI) * WOBBLE_TILES * _tile
			out.append(path[i] + along * at + side * sway)
	out.append(path[path.size() - 1])
	return out


func _at_distance(distance: float) -> Vector2:
	var left := distance
	for i in _points.size() - 1:
		var span := _points[i].distance_to(_points[i + 1])
		if left <= span:
			return _points[i].lerp(_points[i + 1], left / maxf(0.001, span))
		left -= span
	return _points[_points.size() - 1]


func _draw() -> void:
	var life := _time / _duration
	var head := clampf(life / RUN, 0.0, 1.0) * _length
	var fade := 1.0 - smoothstep(RUN, 1.0, life)
	var walked := PackedVector2Array()
	var total := 0.0
	walked.append(_points[0])
	for i in _points.size() - 1:
		var span := _points[i].distance_to(_points[i + 1])
		if total + span >= head:
			walked.append(_at_distance(head))
			break
		total += span
		walked.append(_points[i + 1])
	if walked.size() < 2:
		return
	var width := _tile * 0.09
	draw_polyline(walked, Color(RIM, fade), width + 2.0, true)
	draw_polyline(walked, Color(SHADE, fade), width, true)
	draw_polyline(walked, Color(VENOM, fade), width * 0.5, true)
	for i in DROPS:
		var at := fmod(life * 1.6 + float(i) / float(DROPS), 1.0) * head
		var drop := _at_distance(at)
		draw_circle(drop, _tile * 0.075 + 1.0, Color(RIM, fade))
		draw_circle(drop, _tile * 0.075, Color(VENOM, fade))
		draw_circle(drop, _tile * 0.03, Color(SHINE, fade))
	draw_circle(walked[walked.size() - 1], _tile * 0.12, Color(VENOM, fade))
