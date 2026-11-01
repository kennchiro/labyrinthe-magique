class_name LightBeam
extends Node2D

## Le rayon de la Lance solaire. Il part du mage, file le long des couloirs en arrondissant
## ses virages, puis se résorbe du mage vers le bout. Il éclate à chaque virage et sur chaque
## ennemi au moment où sa tête y passe, et sème des étincelles sur tout le trajet.

const SHADER := preload("res://assets/shaders/lumiere_beam.gdshader")
const GOLD := Color("#ffcf5a")
const SHINE := Color("#fff1b8")
const RIM := Color("#4a2f12")
const LIFE := 0.95
## La part de vie où la tête parcourt le trajet.
const RUN := 0.24
## La part de vie où la queue commence à remonter vers le bout.
const FADE := 0.58
const WIDTH_TILES := 1.5
const CORNER_TILES := 0.42
const CORNER_STEPS := 6
const SPARKS_PER_TILE := 2.5
const SPARKS_MAX := 40
const FLARE_TIME := 0.34
const HIT_TIME := 0.46

var _time := 0.0
var _tile := 32.0
var _length := 1.0
var _paint: ShaderMaterial
var _line: Line2D
var _start := Vector2.ZERO
var _end := Vector2.ZERO
var _corners: Array[Dictionary] = []
var _hits: Array[Dictionary] = []
var _sparks: Array[Dictionary] = []


## `points` part du mage et passe par le centre de chaque case ; `hits` donne, dans `points`,
## les rangs des cases où se tient un ennemi touché.
func setup(points: PackedVector2Array, hits: Array[int], tile_size: int) -> void:
	_tile = float(tile_size)
	_start = points[0]
	_end = points[points.size() - 1]
	var rounded := _rounded(points)
	var walked := _walked_lengths(points)
	_length = maxf(1.0, walked[walked.size() - 1])
	for rank in range(1, points.size() - 1):
		if (points[rank] - points[rank - 1]).dot(points[rank + 1] - points[rank]) < 0.5:
			_corners.append({"at": points[rank], "when": walked[rank] / _length})
	for rank in hits:
		_hits.append({"at": points[rank], "when": walked[rank] / _length})
	_seed_sparks(points, walked)
	_paint = ShaderMaterial.new()
	_paint.shader = SHADER
	_paint.set_shader_parameter("seed", _start.x * 0.013 + _start.y * 0.007)
	_paint.set_shader_parameter("length_tiles", _length / _tile)
	_line = Line2D.new()
	_line.points = rounded
	_line.width = _tile * WIDTH_TILES
	_line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	_line.joint_mode = Line2D.LINE_JOINT_ROUND
	_line.material = _paint
	# Les éclats se dessinent par-dessus le ruban : c'est lui qui passe derrière son parent.
	_line.show_behind_parent = true
	add_child(_line)
	z_index = 11
	# Le trajet suit le sol en coordonnées du monde : aucun redressement de la vue 2,5D.
	scale = Vector2.ONE
	show_at(0.0)


func _process(delta: float) -> void:
	_time += delta
	if _time >= LIFE:
		queue_free()
		return
	show_at(_time)


func show_at(time: float) -> void:
	_time = time
	var life := _time / LIFE
	var fade := smoothstep(FADE, 1.0, life)
	_paint.set_shader_parameter("run", 1.0 if life >= RUN else life / RUN * 1.04)
	_paint.set_shader_parameter("gone", fade * 1.05)
	_paint.set_shader_parameter("body", lerpf(0.3, 1.0, smoothstep(0.0, RUN, life)) * (1.0 - fade * 0.65))
	queue_redraw()


## Les virages deviennent de petites courbes : le rayon coule dans le couloir au lieu d'y casser.
func _rounded(points: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array([points[0]])
	var reach := _tile * CORNER_TILES
	for rank in range(1, points.size() - 1):
		var here := points[rank]
		var into := (here - points[rank - 1]).normalized()
		var away := (points[rank + 1] - here).normalized()
		if into.dot(away) > 0.5:
			out.append(here)
			continue
		var enter := here - into * reach
		var leave := here + away * reach
		for step in CORNER_STEPS + 1:
			var t := float(step) / float(CORNER_STEPS)
			out.append(enter.lerp(here, t).lerp(here.lerp(leave, t), t))
	out.append(points[points.size() - 1])
	return out


func _walked_lengths(points: PackedVector2Array) -> PackedFloat32Array:
	var walked := PackedFloat32Array([0.0])
	for rank in range(1, points.size()):
		walked.append(walked[rank - 1] + points[rank - 1].distance_to(points[rank]))
	return walked


func _seed_sparks(points: PackedVector2Array, walked: PackedFloat32Array) -> void:
	var noise := RandomNumberGenerator.new()
	noise.seed = hash(_start)
	var count := mini(SPARKS_MAX, int(_length / _tile * SPARKS_PER_TILE))
	for i in count:
		var distance := noise.randf() * _length
		var rank := 1
		while rank < points.size() - 1 and walked[rank] < distance:
			rank += 1
		var span := maxf(0.001, walked[rank] - walked[rank - 1])
		var along := points[rank] - points[rank - 1]
		_sparks.append({
			"at": points[rank - 1].lerp(points[rank], (distance - walked[rank - 1]) / span),
			"when": distance / _length,
			"drift": along.orthogonal().normalized() * noise.randf_range(-1.0, 1.0) * _tile * 0.75,
			"life": noise.randf_range(0.22, 0.5),
			"size": noise.randf_range(0.04, 0.085) * _tile,
		})


## L'instant où la tête passe à cette fraction du trajet.
func _passed(when: float) -> float:
	return when * RUN * LIFE


func _draw() -> void:
	var life := _time / LIFE
	_draw_muzzle()
	for spark in _sparks:
		_draw_spark(spark)
	for corner in _corners:
		_draw_flare(corner, FLARE_TIME, 0.62, 4)
	for hit in _hits:
		_draw_flare(hit, HIT_TIME, 1.15, 8)
	_draw_flare({"at": _end, "when": 1.0}, HIT_TIME, 1.0, 6)
	if life < RUN:
		var head := _at_fraction(life / RUN)
		_draw_star(head, _tile * 0.5, SHINE, life * 22.0)
		draw_circle(head, _tile * 0.14, Color.WHITE)


## L'éclair au départ : c'est lui qui dit de quel mage part le rayon.
func _draw_muzzle() -> void:
	var age := _time / 0.3
	if age >= 1.0:
		return
	_draw_star(_start, _tile * lerpf(0.55, 1.05, age), Color(SHINE, 1.0 - age), age * 1.6)
	draw_circle(_start, _tile * 0.2 * (1.0 - age), Color.WHITE)


func _draw_spark(spark: Dictionary) -> void:
	var age := (_time - _passed(float(spark["when"]))) / float(spark["life"])
	if age < 0.0 or age >= 1.0:
		return
	var drift: Vector2 = spark["drift"]
	var at: Vector2 = spark["at"] + drift * sqrt(age) + Vector2(0.0, age * age * _tile * 0.35)
	var size: float = float(spark["size"]) * (1.0 - age * 0.6)
	var alpha := 1.0 - age * age
	_draw_diamond(at, size + 1.0, Color(RIM, alpha))
	_draw_diamond(at, size, Color(SHINE if int(spark["size"] * 100.0) % 2 == 0 else GOLD, alpha))


## Un éclat au passage de la tête : une étoile, un anneau, et des rayons qui jaillissent.
func _draw_flare(flare: Dictionary, time: float, radius: float, rays: int) -> void:
	var age := (_time - _passed(float(flare["when"]))) / time
	if age < 0.0 or age >= 1.0:
		return
	var at: Vector2 = flare["at"]
	var alpha := 1.0 - age * age
	var out := 1.0 - (1.0 - age) * (1.0 - age)
	draw_arc(at, _tile * radius * out, 0.0, TAU, 28, Color(GOLD, alpha), _tile * 0.07 * (1.0 - age) + 1.0, true)
	for ray in rays:
		var way := Vector2.from_angle(TAU * float(ray) / float(rays) + at.x * 0.1)
		var inner := at + way * _tile * radius * out * 0.55
		var outer := at + way * _tile * radius * (out * 1.05 + 0.08)
		draw_line(inner, outer, Color(RIM, alpha), _tile * 0.075, true)
		draw_line(inner, outer, Color(SHINE, alpha), _tile * 0.04, true)
	_draw_star(at, _tile * radius * 0.62 * (1.0 - age * 0.6), Color(Color.WHITE, alpha), age * 1.2)


func _draw_star(at: Vector2, radius: float, color: Color, turn: float) -> void:
	var star := PackedVector2Array()
	for i in 8:
		var reach := radius if i % 2 == 0 else radius * 0.2
		star.append(at + Vector2.from_angle(turn + TAU * float(i) / 8.0) * reach)
	draw_colored_polygon(star, color)
	star.append(star[0])
	draw_polyline(star, Color(RIM, color.a), 1.0, true)


func _draw_diamond(at: Vector2, size: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([at + Vector2(0.0, -size * 1.5), at + Vector2(size, 0.0),
		at + Vector2(0.0, size * 1.5), at + Vector2(-size, 0.0)]), color)


func _at_fraction(fraction: float) -> Vector2:
	var points := _line.points
	var left := fraction * _length
	for rank in points.size() - 1:
		var span := points[rank].distance_to(points[rank + 1])
		if left <= span:
			return points[rank].lerp(points[rank + 1], left / maxf(0.001, span))
		left -= span
	return _end
