class_name ShardRain
extends Node2D

## La Pluie d'éclats de l'Ascendant : un éclat de cristal tombe du ciel en biais sur sa case,
## annoncé par une ombre qui se resserre au sol, et se brise à l'arrivée en éventail de fragments.
## L'Ange des Étoiles fait tomber des comètes rondes ; ici, des lames de cristal.

const SHATTER := 0.35
const RIM := Color("#16202b")

var _lead := 0.45
var _tile := 32.0
var _colour := Color.WHITE
var _life := 0.0


func setup(lead: float, tile_size: int, colour: Color) -> void:
	_lead = maxf(0.1, lead)
	_tile = float(tile_size)
	_colour = colour
	z_index = 11


func _process(delta: float) -> void:
	_life += delta
	if _life >= _lead + SHATTER:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var fall := minf(1.0, _life / _lead)
	if _life < _lead:
		# L'ombre au sol, qui se resserre à mesure que l'éclat approche.
		var ring := _tile * (0.9 - 0.5 * fall)
		draw_circle(Vector2.ZERO, ring, Color(_colour, 0.12 + 0.18 * fall))
		draw_arc(Vector2.ZERO, ring, 0.0, TAU, 28, Color("#e0b84a", 0.5 + 0.5 * fall), 3.0, true)
		draw_circle(Vector2.ZERO, _tile * 0.18 * fall, Color(RIM, 0.35))
		# L'éclat, qui tombe en biais avec sa traîne.
		var from := Vector2(-_tile * 1.2, -_tile * 3.0)
		var at := from.lerp(Vector2.ZERO, fall * fall)
		var down := (Vector2.ZERO - from).normalized()
		draw_line(at - down * _tile * 1.6, at, Color(_colour, 0.35), _tile * 0.12)
		var side := down.orthogonal() * _tile * 0.24
		var tip := at + down * _tile * 0.5
		var tail := at - down * _tile * 0.8
		draw_circle(at, _tile * 0.45, Color(_colour, 0.3))
		draw_colored_polygon(PackedVector2Array([tip + down * 2.0, at + side * 1.3, tail - down * 2.0, at - side * 1.3]), RIM)
		draw_colored_polygon(PackedVector2Array([tip, at + side, tail, at - side]), _colour)
		draw_line(tail, tip, Color.WHITE, 1.5)
		return
	# Le bris : un éclair, un anneau, et des fragments qui volent en éventail.
	var k := (_life - _lead) / SHATTER
	draw_circle(Vector2.ZERO, _tile * 0.5 * (1.0 - k), Color(1.0, 1.0, 1.0, 0.8 * (1.0 - k)))
	draw_arc(Vector2.ZERO, _tile * (0.4 + 0.9 * k), 0.0, TAU, 32, Color(_colour, 0.8 * (1.0 - k)), 3.0, true)
	for i in 7:
		var angle := -PI * 0.1 - PI * 0.8 * float(i) / 6.0
		var at := Vector2.from_angle(angle) * _tile * (0.2 + 1.1 * k) + Vector2(0.0, _tile * 0.6 * k * k)
		var d := Vector2.from_angle(angle + k * 6.0) * _tile * 0.12
		if k >= 0.97:
			continue
		draw_colored_polygon(PackedVector2Array([at + d, at + d.orthogonal() * 0.5, at - d, at - d.orthogonal() * 0.5]),
			Color(_colour, 1.0 - k))
