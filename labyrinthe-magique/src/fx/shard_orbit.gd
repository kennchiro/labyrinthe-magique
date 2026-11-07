class_name ShardOrbit
extends Node2D

## Les Éclats en orbite du Prisme : six petites épées de lumière d'or tournent autour de lui, pointe
## vers l'extérieur, et l'une d'elles part frapper quand le sort touche un ennemi, puis se reforme.
## À la place du nuage d'orage de la Foudre. Et ce ne sont pas des cristaux : ceux-là sont son aura.

const COUNT := 6
const RIM := Color("#16202b")

var _tile := 32.0
var _colour := Color.WHITE
var _life := 0.0
var _duration := 6.0
var _stopping := -1.0
var _gone: Array[float] = []


func setup(tile_size: int, colour: Color, duration: float) -> void:
	_tile = float(tile_size)
	_colour = colour
	_duration = duration
	_gone.resize(COUNT)
	_gone.fill(0.0)
	z_index = 3


## Un éclat part vers sa cible : il manque dans le cercle le temps de se reformer. Rend sa place,
## relative au mage.
func strike() -> Vector2:
	var best := 0
	for i in COUNT:
		if _gone[i] <= 0.0:
			best = i
			break
	_gone[best] = 0.6
	return _slot(best)


func stop() -> void:
	if _stopping < 0.0:
		_stopping = 0.0


func refresh(duration: float) -> void:
	_duration = _life + duration
	_stopping = -1.0


func _process(delta: float) -> void:
	_life += delta
	for i in COUNT:
		_gone[i] = maxf(0.0, _gone[i] - delta)
	if _stopping < 0.0 and _life >= _duration:
		_stopping = 0.0
	if _stopping >= 0.0:
		_stopping += delta
		if _stopping >= 0.35:
			queue_free()
			return
	queue_redraw()


func _slot(i: int) -> Vector2:
	var angle := _life * 2.6 + TAU * float(i) / float(COUNT)
	var shrink := 1.0 - clampf(_stopping / 0.35, 0.0, 1.0) if _stopping >= 0.0 else 1.0
	return Vector2(cos(angle), sin(angle) * 0.5) * _tile * 0.95 * shrink + Vector2(0.0, -_tile * 0.6)


func _draw() -> void:
	var alpha := 1.0 - clampf(_stopping / 0.35, 0.0, 1.0) if _stopping >= 0.0 else minf(1.0, _life * 5.0)
	draw_arc(Vector2(0.0, -_tile * 0.6), _tile * 0.95, 0.0, TAU, 40, Color(_colour, 0.18 * alpha), 2.0, true)
	for i in COUNT:
		if _gone[i] > 0.3:
			continue
		var regrow := 1.0 - _gone[i] / 0.3 if _gone[i] > 0.0 else 1.0
		var at := _slot(i)
		var size := _tile * 0.17 * regrow
		if size < 1.0:
			continue
		# L'épée pointe vers l'extérieur du cercle : la lame, la garde, la poignée.
		var out := (at - Vector2(0.0, -_tile * 0.6)).normalized()
		var side := out.orthogonal()
		var tip := at + out * size * 1.6
		var guard := at - out * size * 0.5
		draw_circle(at, size * 1.2, Color(_colour, 0.2 * alpha))
		draw_colored_polygon(PackedVector2Array([guard + side * size * 0.3, tip, guard - side * size * 0.3]), Color(RIM, 0.6 * alpha))
		draw_colored_polygon(PackedVector2Array([guard + side * size * 0.22, tip, guard - side * size * 0.22]), Color(1.0, 0.98, 0.88, alpha))
		draw_line(guard + side * size * 0.6, guard - side * size * 0.6, Color(_colour, alpha), 2.5)
		draw_line(guard, guard - out * size * 0.5, Color(_colour, alpha), 2.0)
