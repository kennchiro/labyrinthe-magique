class_name GatherLight
extends Node2D

## La charge de la Transformation, avant que le Prisme n'éclate : la lumière converge vers lui de
## tous côtés, des traits qui se resserrent et un anneau qui se referme, de plus en plus vite. C'est
## la seconde où le joueur sait ce qui arrive. L'éclatement lui-même est `AscensionBurst`.

const RIM := Color("#16202b")

var _tile := 32.0
var _colour := Color.WHITE
var _duration := 0.8
var _life := 0.0


func setup(tile_size: int, colour: Color, duration: float) -> void:
	_tile = float(tile_size)
	_colour = colour
	_duration = maxf(0.2, duration)
	z_index = 13


func _process(delta: float) -> void:
	_life += delta
	if _life >= _duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := _life / _duration
	var centre := Vector2(0.0, -_tile * 0.5)
	# L'anneau qui se referme sur lui.
	var r := _tile * 3.2 * (1.0 - k * k)
	draw_arc(centre, r, 0.0, TAU, 56, Color(RIM, 0.35), 5.0, true)
	draw_arc(centre, r, 0.0, TAU, 56, Color(_colour, 0.4 + 0.6 * k), 2.5, true)
	# Les traits de lumière qui convergent, de plus en plus vite.
	for i in 18:
		var angle := TAU * float(i) / 18.0 + float(i) * 0.37
		var phase := fmod(k * (2.0 + 2.0 * k) + float(i) * 0.11, 1.0)
		var dir := Vector2.from_angle(angle)
		var far := _tile * 3.5 * (1.0 - phase)
		var near := maxf(0.0, far - _tile * 0.9)
		if far - near < 2.0:
			continue
		draw_line(centre + dir * far, centre + dir * near, Color(_colour.lerp(Color.WHITE, 0.4), 0.8 * phase), 2.0)
	# Le cœur qui grossit et pâlit jusqu'à l'éclatement.
	draw_circle(centre, _tile * (0.2 + 0.5 * k), Color(_colour, 0.35 + 0.4 * k))
	draw_circle(centre, _tile * (0.1 + 0.3 * k), Color(1.0, 1.0, 1.0, 0.6 + 0.4 * k))
