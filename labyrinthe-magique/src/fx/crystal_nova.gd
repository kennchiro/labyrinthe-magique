class_name CrystalNova
extends Node2D

## La Nova prismatique de l'Ascendant, avant qu'il sache se transformer : une couronne de lances de
## cristal bleu jaillit du sol tout autour de lui, en cercle, puis se brise en éclats. Ce n'est pas un
## anneau de lame comme le grand coup de l'Apprenti : c'est le sol qui se hérisse.

const RISE := 0.18
const HOLD := 0.3
const BREAK := 0.35
const SPIKES := 16
const RIM := Color("#16202b")
const GOLD := Color("#e0b84a")

var _radius := 96.0
var _tile := 32.0
var _colour := Color.WHITE
var _life := 0.0


func setup(radius: float, tile_size: int, colour: Color) -> void:
	_radius = radius
	_tile = float(tile_size)
	_colour = colour
	z_index = 11


func _process(delta: float) -> void:
	_life += delta
	if _life >= RISE + HOLD + BREAK:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var rise := minf(1.0, _life / RISE)
	var broke := clampf((_life - RISE - HOLD) / BREAK, 0.0, 1.0)
	var reach := _radius * (1.0 - pow(1.0 - rise, 3.0))
	# Le sol qui s'illumine sous la couronne.
	draw_circle(Vector2.ZERO, reach, Color(_colour, 0.12 * (1.0 - broke)))
	draw_arc(Vector2.ZERO, reach, 0.0, TAU, 56, Color(GOLD, 0.8 * (1.0 - broke)), 2.5, true)
	for i in SPIKES:
		var angle := TAU * float(i) / float(SPIKES)
		var dir := Vector2.from_angle(angle)
		var base := dir * reach * (0.55 + 0.4 * float(i % 2))
		if broke < 1.0:
			# Une lance de cristal, dressée vers le haut de l'écran : elle sort du sol.
			var height := _tile * (0.9 + 0.4 * float(i % 3)) * rise * (1.0 - broke)
			if height > 1.0:
				var side := Vector2(_tile * 0.1, 0.0)
				var tip := base + Vector2(0.0, -height)
				draw_colored_polygon(PackedVector2Array([base - side * 1.4, tip + Vector2(0, -2), base + side * 1.4]), Color(RIM, 0.5))
				draw_colored_polygon(PackedVector2Array([base - side, tip, base + side]), _colour)
				draw_line(base, tip, Color(1.0, 1.0, 1.0, 0.85), 1.2)
		if broke > 0.0 and broke < 0.98:
			# Les éclats de la lance brisée, projetés vers l'extérieur.
			var at := base + dir * _tile * 1.2 * broke + Vector2(0.0, -_tile * 0.5 + _tile * broke * broke)
			var d := Vector2.from_angle(angle + broke * 8.0) * _tile * 0.12
			draw_colored_polygon(PackedVector2Array([at + d, at + d.orthogonal() * 0.5, at - d, at - d.orthogonal() * 0.5]),
				Color(_colour, 1.0 - broke))
