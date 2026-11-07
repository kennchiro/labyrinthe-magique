class_name DragonRoar
extends Node2D

## Le Rugissement du Roi-Dragon : une immense tête de dragon de lumière surgit derrière Aël, ouvre la
## gueule, et un fleuve de flamme d'or s'en déverse et déferle sur tout l'écran en un anneau qui
## s'étend jusqu'au bout de la portée. L'éclair blanc du début, puis la vague, puis les braises.

const LIFE := 1.9
const RIM := Color("#3a2408")
const GOLD := Color("#f2c94c")
const PALE := Color("#fff4c8")

var _radius := 288.0
var _tile := 32.0
var _life := 0.0


func setup(radius: float, tile_size: int) -> void:
	_radius = radius
	_tile = float(tile_size)
	z_index = 14


func _process(delta: float) -> void:
	_life += delta
	if _life >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := _life / LIFE
	var fade := 1.0 - smoothstep(0.65, 1.0, k)
	# 1. La tête de dragon de lumière, au-dessus de lui : elle monte, ouvre la gueule, puis s'efface.
	var rise := minf(1.0, k * 3.0)
	var jaw := clampf((k - 0.03) / 0.1, 0.0, 1.0)
	var head := Vector2(0.0, -_tile * (1.6 + 0.8 * rise))
	var size := _tile * 2.2 * (0.7 + 0.3 * rise)
	var alpha := fade * rise
	if alpha > 0.02:
		_draw_head(head, size, jaw, alpha)
	# 2. Le fleuve de flamme : un anneau épais qui déferle depuis lui, en plusieurs vagues.
	for w in 3:
		var t := clampf((k - 0.04 - 0.1 * float(w)) / 0.5, 0.0, 1.0)
		if t <= 0.0 or t >= 1.0:
			continue
		var r := _radius * (1.0 - pow(1.0 - t, 2.0))
		var thick := _tile * (1.6 - 0.4 * float(w)) * (1.0 - t * 0.6)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 80, Color(RIM, 0.3 * (1.0 - t)), thick + 6.0, true)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 80, Color(GOLD, 0.8 * (1.0 - t)), thick, true)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 80, Color(PALE, 0.9 * (1.0 - t)), thick * 0.35, true)
		# Les langues de flamme qui dépassent de la vague.
		for i in 24:
			var a := TAU * float(i) / 24.0 + float(w)
			var dir := Vector2.from_angle(a)
			var lick := _tile * (0.6 + 0.4 * sin(_life * 30.0 + float(i)))
			draw_line(dir * r, dir * (r + lick), Color(GOLD, 0.7 * (1.0 - t)), 3.0)
	# 3. Les braises qui retombent partout après le passage.
	if k > 0.45:
		for i in 30:
			var a := TAU * float(i) / 30.0 + float(i) * 0.7
			var at := Vector2.from_angle(a) * _radius * (0.2 + 0.75 * fmod(float(i) * 0.37, 1.0)) \
				+ Vector2(0.0, (k - 0.45) * _tile * 3.0)
			draw_circle(at, 2.2, Color("#ffb347", fade))
	# 4. L'éclair blanc qui ouvre le rugissement.
	if k > 0.12 and k < 0.3:
		var flash := 1.0 - (k - 0.12) / 0.18
		draw_circle(Vector2.ZERO, _radius * 0.2, Color(1.0, 0.97, 0.85, 0.6 * flash))


## Une tête de dragon de face, faite de lumière : cornes, yeux, et la gueule qui s'ouvre.
func _draw_head(at: Vector2, size: float, jaw: float, alpha: float) -> void:
	var skull := PackedVector2Array([at + Vector2(-size, -size * 0.3), at + Vector2(-size * 0.55, -size * 0.85),
		at + Vector2(size * 0.55, -size * 0.85), at + Vector2(size, -size * 0.3), at + Vector2(size * 0.45, size * 0.35),
		at + Vector2(-size * 0.45, size * 0.35)])
	var lower := PackedVector2Array([at + Vector2(-size * 0.45, size * 0.3), at + Vector2(size * 0.45, size * 0.3),
		at + Vector2(size * 0.25, size * (0.7 + 0.5 * jaw)), at + Vector2(-size * 0.25, size * (0.7 + 0.5 * jaw))])
	draw_circle(at, size * 1.6, Color(GOLD, 0.18 * alpha))
	for horn: float in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([at + Vector2(horn * size * 0.5, -size * 0.75),
			at + Vector2(horn * size * 1.3, -size * 1.8), at + Vector2(horn * size * 0.8, -size * 0.6)]), Color(PALE, 0.85 * alpha))
	draw_colored_polygon(skull, Color(GOLD, 0.8 * alpha))
	draw_colored_polygon(lower, Color(GOLD, 0.7 * alpha))
	# La gueule ouverte, d'où sort la lumière.
	if jaw > 0.0:
		draw_colored_polygon(PackedVector2Array([at + Vector2(-size * 0.35, size * 0.3), at + Vector2(size * 0.35, size * 0.3),
			at + Vector2(0.0, size * (0.6 + 0.5 * jaw))]), Color(1.0, 1.0, 1.0, alpha))
	for eye: float in [-1.0, 1.0]:
		draw_colored_polygon(PackedVector2Array([at + Vector2(eye * size * 0.2, -size * 0.25),
			at + Vector2(eye * size * 0.55, -size * 0.4), at + Vector2(eye * size * 0.45, -size * 0.15)]), Color(1.0, 1.0, 1.0, alpha))
