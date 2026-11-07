class_name ClawRake
extends Node2D

## Les Griffes de soleil du Dragon d'or : trois griffures d'or parallèles lacèrent l'air devant lui,
## l'une après l'autre, puis se referment en braises. Ce n'est pas un arc de lame : ce sont des griffes.

const LIFE := 0.5
const RIM := Color("#3a2408")

var _dir := Vector2.RIGHT
var _length := 60.0
var _life := 0.0


func setup(direction: Vector2, length: float) -> void:
	_dir = direction.normalized() if direction != Vector2.ZERO else Vector2.DOWN
	_length = length
	z_index = 12


func _process(delta: float) -> void:
	_life += delta
	if _life >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var side := _dir.orthogonal()
	for i in 3:
		var start := float(i) * 0.04
		var t := clampf((_life - start) / 0.1, 0.0, 1.0)
		var fade := 1.0 - clampf((_life - start - 0.1) / (LIFE - 0.14), 0.0, 1.0)
		if t <= 0.0 or fade <= 0.0:
			continue
		# Chaque griffure part en biais, d'un côté vers l'autre, comme un coup de patte.
		var offset := side * _length * 0.22 * (float(i) - 1.0)
		var from := offset - side * _length * 0.35 + _dir * _length * 0.2
		var to := offset + side * _length * 0.35 + _dir * _length * 0.9
		var tip := from.lerp(to, t)
		var mid := from.lerp(tip, 0.5)
		var width := _length * 0.12 * fade
		var normal := (tip - from).orthogonal().normalized()
		draw_colored_polygon(PackedVector2Array([from, mid + normal * width * 1.6, tip, mid - normal * width * 1.6]), Color(RIM, 0.55 * fade))
		draw_colored_polygon(PackedVector2Array([from, mid + normal * width, tip, mid - normal * width]), Color("#f2c94c", fade))
		draw_line(from.lerp(tip, 0.15), from.lerp(tip, 0.9), Color(1.0, 0.97, 0.85, fade), 1.5)
		# Les braises qui tombent de la griffure.
		for k in 3:
			var at := from.lerp(tip, 0.3 + 0.3 * float(k)) + Vector2(0.0, _life * 60.0 * float(k + 1) * 0.3)
			draw_circle(at, 1.6 * fade, Color("#ffb347", fade))
