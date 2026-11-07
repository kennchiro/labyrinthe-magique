class_name GemGlint
extends Node2D

## L'Éveil de l'éclat de l'Apprenti : la gemme pendue à son cou s'allume un instant, une étoile cyan à
## quatre branches qui s'étire puis s'éteint. C'est le premier signe de ce qu'il deviendra.

const LIFE := 0.6

var _size := 24.0
var _colour := Color.WHITE
var _life := 0.0


func setup(size: float, colour: Color) -> void:
	_size = size
	_colour = colour
	z_index = 14


func _process(delta: float) -> void:
	_life += delta
	if _life >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := _life / LIFE
	var grow := sin(minf(1.0, k * 2.5) * PI * 0.5)
	var alpha := 1.0 - smoothstep(0.4, 1.0, k)
	draw_circle(Vector2.ZERO, _size * 0.6 * grow, Color(_colour, 0.35 * alpha))
	for i in 4:
		var dir := Vector2.from_angle(PI * 0.25 + PI * 0.5 * float(i) + k * 0.6)
		var long := _size * (1.6 if i % 2 == 0 else 1.1) * grow
		var side := dir.orthogonal() * _size * 0.12
		if long < 2.0:
			continue
		draw_colored_polygon(PackedVector2Array([side, dir * long, -side]), Color(_colour, alpha))
		draw_colored_polygon(PackedVector2Array([side * 0.5, dir * long * 0.8, -side * 0.5]), Color(1, 1, 1, alpha))
	draw_circle(Vector2.ZERO, _size * 0.18 * grow, Color(1.0, 1.0, 1.0, alpha))
