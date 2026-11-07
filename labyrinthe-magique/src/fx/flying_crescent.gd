class_name FlyingCrescent
extends Node2D

## Le Tranche-vent d'Aël : une lame d'air en croissant qui file dans le couloir. Elle suit le
## chemin du projectile, couchée dans le sens de sa course, et laisse une traîne qui s'efface.
## Pas d'orbe ni d'élément : c'est un coup d'épée qui part tout seul, acier et blanc.
## Trois styles, trois sorts : CRESCENT, le Tranche-vent de l'Apprenti ; LANCE, un dard de lumière
## effilé, la Rafale du Prisme ; SHARD, un éclat de cristal taillé qui tournoie au ras du sol, le
## sillage de la Lame d'éclat de l'Éveillé.

enum Style { CRESCENT, LANCE, SHARD }

const SEGMENTS := 14
## Le croissant ouvre devant lui, en degrés de part et d'autre de sa course.
const OPEN := 62.0
const BURST := 0.16
const RIM := Color("#16202b")

var _points := PackedVector2Array()
var _duration := 0.3
var _life := 0.0
var _radius := 14.0
var _colour := Color.WHITE
var _heading := Vector2.RIGHT
var _trail: Array[Vector2] = []
var _burst_left := -1.0
var _style := Style.CRESCENT


func setup(points: PackedVector2Array, duration: float, tile_size: int, colour: Color,
		style: Style = Style.CRESCENT) -> void:
	_style = style
	_points = points
	_duration = maxf(0.05, duration)
	_radius = float(tile_size) * 0.85
	_colour = colour
	if not points.is_empty():
		position = points[0]
	z_index = 12


## Il touche : la lame se brise en un éclat bref, au lieu de disparaître d'un coup.
func burst() -> void:
	_burst_left = BURST


func _process(delta: float) -> void:
	if _burst_left >= 0.0:
		_burst_left -= delta
		if _burst_left <= 0.0:
			queue_free()
		queue_redraw()
		return
	_life += delta
	var t := clampf(_life / _duration, 0.0, 1.0)
	var at := _along(t)
	if at.distance_to(position) > 0.5:
		_heading = (at - position).normalized()
	_trail.push_front(position)
	if _trail.size() > 7:
		_trail.pop_back()
	position = at
	if _life >= _duration + 0.05:
		_burst_left = BURST
	queue_redraw()


func _along(t: float) -> Vector2:
	if _points.size() < 2:
		return position
	var total := 0.0
	for i in _points.size() - 1:
		total += _points[i].distance_to(_points[i + 1])
	var goal := total * t
	for i in _points.size() - 1:
		var piece := _points[i].distance_to(_points[i + 1])
		if goal <= piece or i == _points.size() - 2:
			return _points[i].lerp(_points[i + 1], clampf(goal / maxf(piece, 0.001), 0.0, 1.0))
		goal -= piece
	return _points[_points.size() - 1]


func _draw() -> void:
	var angle := _heading.angle()
	if _burst_left >= 0.0:
		# L'éclat : quatre traits blancs qui s'écartent, et le croissant qui s'ouvre en s'effaçant.
		var k := 1.0 - _burst_left / BURST
		for i in 4:
			var ray := Vector2.from_angle(angle + TAU * (float(i) + 0.5) / 4.0)
			draw_line(ray * _radius * 0.3 * (1.0 + k), ray * _radius * (0.7 + k), Color(1, 1, 1, 1.0 - k), 2.0)
		_crescent(angle, _radius * (1.0 + k * 0.6), Color(_colour, 0.8 * (1.0 - k)))
		return
	# La traîne : les places précédentes, de plus en plus pâles, comme un sillage d'air.
	for i in _trail.size():
		var fade := 1.0 - float(i + 1) / float(_trail.size() + 1)
		draw_set_transform(_trail[i] - position, 0.0, Vector2.ONE)
		if _style == Style.LANCE:
			_dart(angle, _radius * 1.2, 2.0, Color(_colour, 0.25 * fade))
		elif _style == Style.SHARD:
			draw_circle(Vector2.ZERO, _radius * 0.18 * fade, Color(_colour, 0.4 * fade))
		else:
			_crescent(angle, _radius * (0.9 - 0.06 * float(i)), Color(_colour, 0.22 * fade))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _style == Style.SHARD:
		draw_circle(Vector2.ZERO, _radius * 0.7, Color(_colour, 0.25))
		_gem(_life * 18.0, _radius * 0.8)
		return
	if _style == Style.LANCE:
		_dart(angle, _radius * 1.5 + 2.0, 5.0, Color(RIM, 0.5))
		_dart(angle, _radius * 1.5, 3.6, Color(_colour, 0.95))
		_dart(angle, _radius * 1.1, 1.6, Color(1.0, 1.0, 1.0, 1.0))
		return
	_crescent(angle, _radius + 2.0, Color(RIM, 0.5))
	_crescent(angle, _radius, Color(_colour, 0.95))
	_crescent(angle, _radius * 0.82, Color(1.0, 1.0, 1.0, 1.0))


## Un croissant ouvert vers l'avant, effilé aux deux pointes.
func _crescent(angle: float, radius: float, colour: Color) -> void:
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in SEGMENTS + 1:
		var along := float(i) / float(SEGMENTS)
		var a := angle + deg_to_rad(lerpf(-OPEN, OPEN, along))
		var thick := sin(along * PI) * radius * 0.36
		var direction := Vector2.from_angle(a)
		outer.append(direction * radius)
		inner.append(direction * (radius - thick))
	inner.reverse()
	outer.append_array(inner)
	draw_colored_polygon(outer, colour)


## Un dard effilé, sa pointe devant : `length` de long, `width` en son milieu.
func _dart(angle: float, length: float, width: float, colour: Color) -> void:
	var ahead := Vector2.from_angle(angle)
	var side := ahead.orthogonal()
	draw_colored_polygon(PackedVector2Array([ahead * length * 0.45, side * width,
		-ahead * length * 0.55, -side * width]), colour)


## Un éclat de cristal taillé, qui tourne sur lui-même.
func _gem(spin: float, size: float) -> void:
	var a := Vector2.from_angle(spin) * size
	var b := Vector2.from_angle(spin + PI * 0.5) * size * 0.55
	draw_colored_polygon(PackedVector2Array([a * 1.2, b * 1.2, -a * 1.2, -b * 1.2]), Color(RIM, 0.6))
	draw_colored_polygon(PackedVector2Array([a, b, -a, -b]), _colour)
	draw_colored_polygon(PackedVector2Array([a * 0.4, b * 0.4, -a * 0.4, -b * 0.4]), Color(1, 1, 1, 0.9))
