class_name Constellation
extends Node2D

## Les étoiles posées par l'Ange des Étoiles et les rayons qui les relient par-dessus les haies. Il
## n'y a qu'un seul dessin pour tout le ciel : c'est le CombatSystem qui tient les étoiles.

const SHINE := Color("#dbe6ff")
const BLUE := Color("#7fa2ff")
const RIM := Color("#0a1030")
const STAR_TILES := 0.42
const RUNNERS := 2
const RUNNER_SPEED := 0.9

var _tile := 32.0
var _points := PackedVector2Array()
var _clock := 0.0


func setup(tile_size: int) -> void:
	_tile = float(tile_size)
	z_index = 9
	# Elle suit le sol en coordonnées du monde : aucun redressement de la vue 2,5D.
	scale = Vector2.ONE


func set_points(points: PackedVector2Array) -> void:
	_points = points
	queue_redraw()


func _process(delta: float) -> void:
	if _points.is_empty():
		return
	_clock += delta
	queue_redraw()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_clock * 5.0)
	for i in _points.size():
		for j in range(i + 1, _points.size()):
			_draw_ray(_points[i], _points[j], pulse)
	for i in _points.size():
		_draw_star(_points[i], float(i))


func _draw_ray(from: Vector2, to: Vector2, pulse: float) -> void:
	draw_line(from, to, RIM, _tile * 0.2, true)
	draw_line(from, to, BLUE, _tile * (0.12 + 0.03 * pulse), true)
	draw_line(from, to, Color.WHITE, _tile * 0.05, true)
	for n in RUNNERS:
		var t := fmod(_clock * RUNNER_SPEED + float(n) / float(RUNNERS), 1.0)
		var at := from.lerp(to, t)
		_star_shape(at, _tile * 0.16, Color.WHITE, _clock * 4.0)


func _draw_star(at: Vector2, phase: float) -> void:
	var size := _tile * STAR_TILES * (1.0 + 0.1 * sin(_clock * 3.0 + phase))
	draw_arc(at, _tile * 0.5, 0.0, TAU, 24, RIM, 3.0, true)
	draw_arc(at, _tile * 0.5, 0.0, TAU, 24, BLUE, 1.5, true)
	_star_shape(at, size, Color.WHITE, _clock * 0.8 + phase)
	for n in 4:
		var angle := -_clock * 1.2 + TAU * float(n) / 4.0 + phase
		var dot := at + Vector2.from_angle(angle) * _tile * 0.5
		draw_circle(dot, _tile * 0.05, SHINE)


func _star_shape(at: Vector2, size: float, color: Color, turn: float) -> void:
	var star := PackedVector2Array()
	for i in 8:
		var reach := size if i % 2 == 0 else size * 0.28
		star.append(at + Vector2.from_angle(turn + TAU * float(i) / 8.0) * reach)
	draw_colored_polygon(star, color)
	star.append(star[0])
	draw_polyline(star, RIM, 1.5, true)
