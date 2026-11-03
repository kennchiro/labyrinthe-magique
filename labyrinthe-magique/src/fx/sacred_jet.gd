class_name SacredJet
extends Node2D

## La Flamme du glaive : une langue de flamme saphir file dans le couloir, du Chérubin à sa cible,
## en suivant les cases du trajet. Sa tête arrive quand le CombatSystem frappe ; puis la queue la
## rattrape et elle s'éteint en se rétractant, sans fondu.

const PALE := Color("#eef3ff")
const SAPPHIRE := Color("#3d6bff")
const DEEP := Color("#1a2f9e")
const RIM := Color("#141a2e")
## Longueur de la langue, et sa largeur à la tête, en cases.
const LENGTH := 2.4
const WIDTH := 0.6
const RETRACT := 0.16

var _points := PackedVector2Array()
var _lengths := PackedFloat32Array()
var _total := 0.0
var _duration := 0.3
var _time := 0.0
var _tile := 32.0


func setup(points: PackedVector2Array, duration: float, tile_size: int) -> void:
	_points = points
	_duration = maxf(0.05, duration)
	_tile = float(tile_size)
	z_index = 11
	# Elle suit le sol en coordonnées du monde : aucun redressement de la vue 2,5D.
	scale = Vector2.ONE
	_lengths.append(0.0)
	for i in range(1, points.size()):
		_total += points[i].distance_to(points[i - 1])
		_lengths.append(_total)


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration + RETRACT:
		queue_free()
		return
	queue_redraw()


func _at(distance: float) -> Vector2:
	if _points.size() < 2:
		return _points[0] if not _points.is_empty() else Vector2.ZERO
	distance = clampf(distance, 0.0, _total)
	for i in range(1, _points.size()):
		if distance <= _lengths[i]:
			var span := maxf(0.001, _lengths[i] - _lengths[i - 1])
			return _points[i - 1].lerp(_points[i], (distance - _lengths[i - 1]) / span)
	return _points[_points.size() - 1]


func _draw() -> void:
	if _points.size() < 2:
		return
	var head := _total * minf(_time / _duration, 1.0)
	var length := LENGTH * _tile
	var tail := maxf(0.0, head - length)
	if _time > _duration:
		tail = lerpf(tail, head, (_time - _duration) / RETRACT)
	var steps := 14
	for layer in 4:
		var widen: float = [1.25, 1.0, 0.62, 0.3][layer]
		var color: Color = [RIM, DEEP, SAPPHIRE, PALE][layer]
		var left := PackedVector2Array()
		var right := PackedVector2Array()
		for i in steps + 1:
			var k := float(i) / float(steps)
			var at := _at(lerpf(tail, head, k))
			var ahead := _at(lerpf(tail, head, k) + 2.0)
			var normal := (ahead - at).orthogonal().normalized()
			if normal == Vector2.ZERO:
				normal = Vector2.UP
			var flicker := 1.0 + 0.18 * sin(_time * 40.0 + k * 9.0)
			var width := WIDTH * _tile * 0.5 * widen * pow(k, 0.7) * flicker
			var sway := normal * sin(_time * 25.0 + k * 7.0) * _tile * 0.06 * (1.0 - k)
			left.append(at + normal * width + sway)
			right.append(at - normal * width + sway)
		var shape := left.duplicate()
		for i in range(right.size() - 1, -1, -1):
			shape.append(right[i])
		# La tête s'arrondit en pointe.
		var tip := _at(head + _tile * 0.2 * widen)
		shape.insert(left.size(), tip)
		if shape.size() >= 3:
			draw_colored_polygon(shape, color)
