class_name BladeThrow
extends Node2D

## Une épée de lumière quitte l'orbite du Prisme, file en tournoyant vers sa cible et y laisse une
## entaille en croix. C'est la seule chose du jeu qui part de ses Éclats en orbite.

const FLY := 0.13
const CUT := 0.22
const RIM := Color("#16202b")

var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _tile := 32.0
var _colour := Color.WHITE
var _life := 0.0


func setup(from: Vector2, to: Vector2, tile_size: int, colour: Color) -> void:
	_from = from
	_to = to
	_tile = float(tile_size)
	_colour = colour
	z_index = 12


func _process(delta: float) -> void:
	_life += delta
	if _life >= FLY + CUT:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	if _life < FLY:
		var t := _life / FLY
		var at := _from.lerp(_to, t * t)
		var dir := Vector2.from_angle(_life * 40.0)
		var size := _tile * 0.3
		draw_line(_from.lerp(_to, maxf(0.0, t * t - 0.25)), at, Color(_colour, 0.4), _tile * 0.08)
		draw_line(at - dir * size, at + dir * size, Color(RIM, 0.6), 5.0)
		draw_line(at - dir * size, at + dir * size, Color(1.0, 0.98, 0.88), 3.0)
		draw_line(at - dir.orthogonal() * size * 0.4, at + dir.orthogonal() * size * 0.4, _colour, 2.0)
		return
	# L'entaille : deux traits en croix qui s'ouvrent puis s'effacent.
	var k := (_life - FLY) / CUT
	var size := _tile * (0.35 + 0.25 * k)
	for d in [Vector2(1, -1), Vector2(1, 1)]:
		var v: Vector2 = d.normalized() * size
		draw_line(_to - v, _to + v, Color(_colour, 1.0 - k), 4.0 * (1.0 - k) + 1.0)
		draw_line(_to - v * 0.7, _to + v * 0.7, Color(1.0, 1.0, 1.0, 1.0 - k), 1.5)
