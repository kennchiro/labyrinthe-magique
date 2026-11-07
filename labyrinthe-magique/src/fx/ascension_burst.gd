class_name AscensionBurst
extends Node2D

## L'évolution d'Aël et sa transformation en Prisme : le moment le plus dramatique du jeu. Une colonne
## de lumière tombe sur lui, trois anneaux s'en échappent, des rayons tournent, et des éclats de cristal
## montent tout autour. À l'envers, quand le Prisme se dissipe, la lumière se défait en éclats qui
## retombent : `fall`.

## Moins d'une seconde : plus longue, elle cachait les premiers sorts de la forme (revue du 2026-11-05).
const LIFE := 0.9
const RIM := Color("#16202b")

var _tile := 32.0
var _colour := Color.WHITE
var _life := 0.0
var _fall := false


func setup(tile_size: int, colour: Color, fall := false) -> void:
	_tile = float(tile_size)
	_colour = colour
	_fall = fall
	z_index = 13


func _process(delta: float) -> void:
	_life += delta
	if _life >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := _life / LIFE
	if _fall:
		_draw_fall(k)
		return
	var alpha := 1.0 - smoothstep(0.55, 1.0, k)
	# La colonne de lumière : elle tombe, s'élargit, puis s'amincit.
	var drop := minf(1.0, k * 6.0)
	var width := _tile * (0.5 + 0.9 * sin(minf(1.0, k * 1.6) * PI)) * alpha
	var top := -_tile * 9.0
	var bottom := lerpf(top, _tile * 0.2, drop)
	draw_rect(Rect2(-width * 1.3, top, width * 2.6, bottom - top), Color(_colour, 0.1 * alpha))
	draw_rect(Rect2(-width * 0.5, top, width, bottom - top), Color(_colour, 0.45 * alpha))
	draw_rect(Rect2(-width * 0.18, top, width * 0.36, bottom - top), Color(1.0, 1.0, 1.0, 0.95 * alpha))
	# Trois anneaux d'onde de choc, l'un après l'autre.
	for i in 3:
		var t := clampf((k - 0.12 - 0.12 * float(i)) / 0.5, 0.0, 1.0)
		if t <= 0.0 or t >= 1.0:
			continue
		var r := _tile * (0.6 + 3.2 * t)
		draw_arc(Vector2(0, -_tile * 0.3), r, 0.0, TAU, 56, Color(RIM, 0.35 * (1.0 - t)), 6.0, true)
		draw_arc(Vector2(0, -_tile * 0.3), r, 0.0, TAU, 56, Color(_colour, 1.0 - t), 3.5, true)
	# Les rayons qui tournent autour de lui.
	var spin := _life * 1.8
	for i in 12:
		var angle := spin + TAU * float(i) / 12.0
		var dir := Vector2.from_angle(angle)
		var length := _tile * (1.4 + 1.6 * sin(minf(1.0, k * 2.0) * PI)) * alpha
		# Un rayon éteint n'a plus de longueur : un triangle plat ne se dessine pas.
		if length < 6.0:
			continue
		draw_colored_polygon(PackedVector2Array([Vector2(0, -_tile * 0.4) + dir.orthogonal() * 3.0,
			Vector2(0, -_tile * 0.4) + dir * length, Vector2(0, -_tile * 0.4) - dir.orthogonal() * 3.0]),
			Color(_colour.lerp(Color.WHITE, 0.5), 0.55 * alpha))
	# Les éclats qui montent tout autour.
	for i in 10:
		var phase := fmod(k * 1.5 + float(i) * 0.137, 1.0)
		var x := sin(float(i) * 2.4) * _tile * 1.4
		var at := Vector2(x, _tile * 0.2 - phase * _tile * 3.5)
		var s := _tile * 0.1 * (1.0 - phase)
		if s < 0.6:
			continue
		draw_colored_polygon(PackedVector2Array([at + Vector2(0, -s * 1.6), at + Vector2(s, 0), at + Vector2(0, s * 1.6), at + Vector2(-s, 0)]),
			Color(_colour.lerp(Color.WHITE, 0.3), alpha * (1.0 - phase)))
	# L'éclair blanc du tout début.
	if k < 0.12:
		draw_circle(Vector2(0, -_tile * 0.4), _tile * 2.2 * (k / 0.12), Color(1.0, 1.0, 1.0, 0.8 * (1.0 - k / 0.12)))


func _draw_fall(k: float) -> void:
	var alpha := 1.0 - k
	draw_circle(Vector2(0, -_tile * 0.4), _tile * 1.2 * (1.0 - k), Color(_colour, 0.25 * alpha))
	for i in 14:
		var angle := TAU * float(i) / 14.0
		var at := Vector2(0, -_tile * 0.6) + Vector2.from_angle(angle) * _tile * (0.4 + 1.2 * k) \
			+ Vector2(0.0, _tile * 1.6 * k * k)
		var s := _tile * 0.09 * alpha
		if s < 0.6:
			continue
		draw_colored_polygon(PackedVector2Array([at + Vector2(0, -s * 1.5), at + Vector2(s, 0), at + Vector2(0, s * 1.5), at + Vector2(-s, 0)]),
			Color(_colour, alpha))
