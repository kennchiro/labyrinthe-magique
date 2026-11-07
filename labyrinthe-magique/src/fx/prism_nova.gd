class_name PrismNova
extends Node2D

## Le Prisme ultime : une explosion de lumière, comme une bombe, mais faite de LASERS. Un éclair blanc
## aveuglant, puis des dizaines de rubans de lumière jaillissent de lui en éventail et s'étirent jusqu'au
## bout de la portée, comme les rubans de l'ouverture de Netflix. Certains filent droit sur chaque
## ennemi touché. Derrière eux, une onde de choc s'étend, et une colonne monte au centre.
##
## Il n'y a rien à viser : la déflagration part dans tous les sens et traverse les haies. Le rayon droit
## d'avant ne touchait que ce qui était dans l'axe de son regard.

const LIFE := 1.6
const RIBBONS := 34
const RIM := Color("#16202b")
## Les couleurs des rubans : de l'or, du blanc, et des bleus pâles. Jamais de rose ni de violet.
const PALETTE := [Color("#fff4c8"), Color("#f2c94c"), Color("#ffffff"), Color("#bff3ff"), Color("#ffb347"),
	Color("#8fe3ff"), Color("#ffe08a")]

var _radius := 256.0
var _tile := 32.0
var _life := 0.0
var _targets: Array[Vector2] = []
var _rays: Array[Dictionary] = []


## `targets` : les ennemis touchés, en coordonnées du parent. Un ruban part droit sur chacun.
func setup(radius: float, tile_size: int, targets: Array[Vector2]) -> void:
	_radius = radius
	_tile = float(tile_size)
	z_index = 14
	var rng := RandomNumberGenerator.new()
	rng.seed = 7741
	for target in targets:
		var local := target - position
		if local.length() > 1.0:
			_rays.append({"angle": local.angle(), "length": local.length() + _tile * 0.6,
				"delay": 0.08, "width": _tile * 0.32, "colour": Color.WHITE, "aimed": true})
	for i in RIBBONS:
		_rays.append({"angle": TAU * float(i) / float(RIBBONS) + rng.randf_range(-0.08, 0.08),
			"length": _radius * rng.randf_range(0.7, 1.1), "delay": rng.randf_range(0.05, 0.35),
			"width": _tile * rng.randf_range(0.22, 0.5), "colour": PALETTE[i % PALETTE.size()],
			"bend": rng.randf_range(-0.25, 0.25), "aimed": false})


func _process(delta: float) -> void:
	_life += delta
	if _life >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := _life / LIFE
	var fade := 1.0 - smoothstep(0.6, 1.0, k)
	# 1. L'onde de choc : un disque qui assombrit puis un anneau qui file jusqu'au bout.
	var wave := 1.0 - pow(1.0 - minf(1.0, k * 1.6), 3.0)
	draw_circle(Vector2.ZERO, _radius * 1.15 * wave, Color(RIM, 0.22 * fade))
	draw_arc(Vector2.ZERO, _radius * 1.15 * wave, 0.0, TAU, 72, Color("#fff4c8", 0.85 * fade), 6.0, true)
	draw_arc(Vector2.ZERO, _radius * 0.9 * wave, 0.0, TAU, 72, Color("#f2c94c", 0.5 * fade), 3.0, true)
	# Le soleil au centre, qui tient toute la durée : la forme finale doit avoir son cœur.
	var core := _tile * (2.2 + 0.4 * sin(_life * 18.0)) * fade
	draw_circle(Vector2.ZERO, core * 1.8, Color("#f2c94c", 0.25 * fade))
	draw_circle(Vector2.ZERO, core, Color("#fff4c8", 0.8 * fade))
	draw_circle(Vector2.ZERO, core * 0.5, Color(1.0, 1.0, 1.0, fade))
	# 2. Les rubans de lumière, qui jaillissent l'un après l'autre et s'étirent.
	for ray in _rays:
		var t := clampf((_life - float(ray["delay"])) / 0.35, 0.0, 1.0)
		if t <= 0.0:
			continue
		var reach := float(ray["length"]) * (1.0 - pow(1.0 - t, 3.0))
		var width := float(ray["width"]) * (0.4 + 0.6 * t) * fade
		if reach < 4.0 or width < 0.4:
			continue
		var angle := float(ray["angle"])
		var colour: Color = ray["colour"]
		var bend := float(ray.get("bend", 0.0))
		# Un ruban : effilé au départ, large au bout, légèrement courbé comme une bande de lumière.
		var dir := Vector2.from_angle(angle)
		var tip := dir * reach
		var mid := dir * reach * 0.55 + dir.orthogonal() * reach * bend * 0.3
		var side := dir.orthogonal()
		var band := PackedVector2Array([Vector2.ZERO + side * width * 0.15, mid + side * width * 0.6,
			tip + side * width, tip - side * width, mid - side * width * 0.6, Vector2.ZERO - side * width * 0.15])
		draw_colored_polygon(band, Color(colour, 0.9 * fade))
		draw_polyline(PackedVector2Array([Vector2.ZERO, mid, tip]), Color(1.0, 1.0, 1.0, 0.9 * fade), maxf(1.0, width * 0.3), true)
		if ray["aimed"] and t >= 1.0:
			draw_circle(tip - dir * _tile * 0.6, _tile * 0.5 * fade, Color(1.0, 1.0, 1.0, 0.7 * fade))
	# 3. La colonne qui monte au centre, comme le champignon d'une bombe.
	var rise := minf(1.0, k * 2.0)
	var column := _tile * 7.0 * rise
	var w := _tile * (0.8 + 0.6 * sin(minf(1.0, k * 2.2) * PI)) * fade
	if w > 0.5:
		draw_rect(Rect2(-w, -column, w * 2.0, column), Color("#fff4c8", 0.35 * fade))
		draw_rect(Rect2(-w * 0.35, -column, w * 0.7, column), Color(1.0, 1.0, 1.0, 0.85 * fade))
		draw_circle(Vector2(0.0, -column), w * 2.2 * rise, Color("#f2c94c", 0.3 * fade))
	# 4. L'éclair blanc, aveuglant, du tout premier instant.
	if k < 0.15:
		var flash := 1.0 - k / 0.15
		draw_circle(Vector2.ZERO, _radius * 0.6 * (1.0 - flash * 0.5), Color(1.0, 1.0, 1.0, 0.95 * flash))
