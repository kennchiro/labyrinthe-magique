class_name BladeStreak
extends Node2D

## Les sauts d'Aël, chacun avec sa trace : jamais la téléportation commune aux mages.
## - GHOSTS, la Ruée de l'Apprenti : des silhouettes de lui-même et un trait d'acier. Les silhouettes
##   sont des copies du dessin du joueur à cet instant : le geste reste le sien.
## - MOTES, le Pas de lumière de l'Éveillé : il se défait en grains de lumière cyan, qui filent le
##   long du trajet, et laisse des empreintes lumineuses.
## - WINGS, les Ailes de lumière de l'Ascendant : deux ailes de cristal s'ouvrent au départ et à
##   l'arrivée, et des plumes de cristal retombent sur le trajet.
## - COMET, la Comète du Prisme : une tête blanche et une longue queue d'or, épaisse et brûlante.
## - TRANSMIT, la Transmission du Prisme : aucun trajet. Une colonne d'étincelles d'or l'efface, une
##   autre le fait reparaître.
## - DIVE, la Chute du Dragon d'or : une ombre se resserre sur le point d'arrivée, une colonne de lumière
##   s'écrase dessus, et le sol se fend en étoile.
## - SOAR, les Ailes d'or du Dragon : deux immenses ailes de dragon s'ouvrent au départ, un sillage de
##   flamme d'or court jusqu'à l'arrivée, où les ailes se replient.

enum Style { GHOSTS, MOTES, WINGS, COMET, TRANSMIT, DIVE, SOAR }

const LIFE := 0.34
const GHOSTS := 4
const RIM := Color("#16202b")

var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _width := 8.0
var _tile := 32.0
var _colour := Color.WHITE
var _life := 0.0
var _ghosts: Array[Sprite2D] = []
var _style := Style.GHOSTS
var _span := LIFE


## `model` est le Sprite2D du joueur ; `model_scale` l'échelle de son nœud (le redressement 2,5D).
func setup(from: Vector2, to: Vector2, tile_size: int, colour: Color, model: Sprite2D,
		model_scale: Vector2, style: Style = Style.GHOSTS) -> void:
	_from = from
	_to = to
	_tile = float(tile_size)
	_width = _tile * 0.55
	_colour = colour
	_style = style
	_span = {Style.GHOSTS: 0.5, Style.MOTES: 0.55, Style.WINGS: 0.6, Style.COMET: 0.45,
		Style.TRANSMIT: 0.55, Style.DIVE: 0.7, Style.SOAR: 0.7}[style]
	z_index = 9
	if model == null or style != Style.GHOSTS:
		return
	for i in GHOSTS:
		var ghost := Sprite2D.new()
		ghost.texture = model.texture
		ghost.hframes = model.hframes
		ghost.vframes = model.vframes
		ghost.frame = model.frame
		ghost.flip_h = model.flip_h
		ghost.centered = model.centered
		ghost.offset = model.offset
		ghost.scale = model.scale * model_scale
		# La plus proche du départ est la plus pâle : elles s'effacent dans l'ordre du trajet.
		var t := (float(i) + 0.5) / float(GHOSTS)
		ghost.position = from.lerp(to, t) - position
		ghost.modulate = Color(0.8, 0.95, 1.0, 0.3 + 0.4 * t)
		add_child(ghost)
		_ghosts.append(ghost)


func _process(delta: float) -> void:
	_life += delta
	if _life >= _span:
		queue_free()
		return
	var k := _life / _span
	for i in _ghosts.size():
		var t := (float(i) + 0.5) / float(_ghosts.size())
		_ghosts[i].modulate.a = (0.3 + 0.4 * t) * (1.0 - k)
	queue_redraw()


func _draw() -> void:
	var k := _life / _span
	var from := _from - position
	var to := _to - position
	match _style:
		Style.MOTES:
			_draw_motes(from, to, k)
		Style.WINGS:
			_draw_wings(from, to, k)
		Style.COMET:
			_draw_comet(from, to, k)
		Style.TRANSMIT:
			_draw_transmit(from, to, k)
		Style.DIVE:
			_draw_dive(to, k)
		Style.SOAR:
			_draw_soar(from, to, k)
		_:
			_draw_ghost_trail(from, to, k)


func _draw_ghost_trail(from: Vector2, to: Vector2, k: float) -> void:
	# Le trait se retire depuis le départ : il suit le héros, il ne reste pas planté.
	var tail := from.lerp(to, minf(1.0, k * 1.4))
	var side := (to - from).orthogonal().normalized()
	var width := _width * (1.0 - k)
	if tail.distance_to(to) < 1.0 or width < 0.5:
		return
	for layer in [[width + 3.0, Color(RIM, 0.45 * (1.0 - k))], [width, Color(_colour, 0.85 * (1.0 - k))],
			[width * 0.4, Color(1.0, 1.0, 1.0, 1.0 - k)]]:
		var w: float = layer[0]
		# Effilé à la traîne, plein à la tête.
		draw_colored_polygon(PackedVector2Array([tail, to + side * w * 0.5, to - side * w * 0.5]),
			layer[1])
	# Trois traits de vitesse, de part et d'autre.
	for i in 3:
		var shift := side * _width * (float(i) - 1.0) * 1.3
		draw_line(tail.lerp(to, 0.35) + shift, to.lerp(tail, 0.15) + shift,
			Color(1.0, 1.0, 1.0, 0.5 * (1.0 - k)), 1.5)


func _draw_motes(from: Vector2, to: Vector2, k: float) -> void:
	var side := (to - from).orthogonal().normalized()
	var alpha := 1.0 - k
	# Les empreintes, posées sur le trajet, qui s'éteignent de la première à la dernière.
	var steps := maxi(2, int(from.distance_to(to) / (_tile * 0.6)))
	for i in steps:
		var t := float(i) / float(steps - 1)
		var at := from.lerp(to, t) + side * _tile * 0.12 * (1.0 if i % 2 == 0 else -1.0)
		var fade := clampf(1.0 - k * 1.6 + t * 0.5, 0.0, 1.0)
		draw_circle(at, _tile * 0.1, Color(_colour, 0.55 * fade))
		draw_circle(at, _tile * 0.05, Color(1.0, 1.0, 1.0, 0.8 * fade))
	# Les grains de lumière qui filent vers l'arrivée en ondulant.
	for i in 14:
		var t := fmod(k * 1.8 + float(i) * 0.071, 1.0)
		var at := from.lerp(to, t) + side * sin(t * 9.0 + float(i)) * _tile * 0.35
		draw_circle(at, _tile * 0.16 * (1.0 - t * 0.5), Color(_colour, 0.35 * alpha))
		draw_circle(at, _tile * 0.08 * (1.0 - t * 0.5), Color(1.0, 1.0, 1.0, alpha))
	draw_circle(to, _tile * 0.45 * (1.0 - k), Color(_colour, 0.3 * alpha))


func _draw_wings(from: Vector2, to: Vector2, k: float) -> void:
	var alpha := 1.0 - k
	var open := sin(minf(1.0, k * 2.2) * PI * 0.5)
	for at: Vector2 in [from, to]:
		for sgn: float in [-1.0, 1.0]:
			# Une aile : cinq plumes de cristal en éventail, qui s'ouvrent puis s'effacent.
			for f in 5:
				var angle := -PI * 0.5 + sgn * (0.35 + 0.28 * float(f)) * open
				var length := _tile * (1.5 - 0.15 * float(f))
				var dir := Vector2.from_angle(angle)
				var base: Vector2 = at + Vector2(0.0, -_tile * 0.6)
				var tip: Vector2 = base + dir * length
				var side := dir.orthogonal() * _tile * 0.13
				draw_colored_polygon(PackedVector2Array([base + side, tip, base - side]),
					Color(_colour.lerp(Color.WHITE, 0.25 * float(f % 2)), 0.8 * alpha))
				draw_line(base, tip, Color(1.0, 1.0, 1.0, 0.7 * alpha), 1.0)
	# Les plumes qui retombent sur le trajet.
	for i in 8:
		var t := (float(i) + 0.5) / 8.0
		var at := from.lerp(to, t) + Vector2(sin(float(i) * 3.1) * _tile * 0.3, -_tile * 0.6 + k * _tile * 0.9)
		var dir := Vector2.from_angle(k * 5.0 + float(i))
		draw_line(at - dir * _tile * 0.14, at + dir * _tile * 0.14, Color(_colour, 0.8 * alpha), 2.5)


func _draw_comet(from: Vector2, to: Vector2, k: float) -> void:
	var alpha := 1.0 - k
	var dir := (to - from).normalized()
	var side := dir.orthogonal()
	var head := to
	var tail := from.lerp(to, minf(1.0, k * 0.9))
	var width := _tile * 0.55 * (1.0 - k * 0.7)
	if tail.distance_to(head) > 1.0:
		draw_colored_polygon(PackedVector2Array([tail, head + side * width, head - side * width]), Color(_colour, 0.35 * alpha))
		draw_colored_polygon(PackedVector2Array([tail, head + side * width * 0.55, head - side * width * 0.55]), Color(_colour, 0.85 * alpha))
		draw_colored_polygon(PackedVector2Array([tail.lerp(head, 0.4), head + side * width * 0.2, head - side * width * 0.2]), Color(1, 1, 1, alpha))
	draw_circle(head, width * 0.9, Color(1.0, 1.0, 1.0, alpha))
	# Les étincelles qui s'arrachent de la queue.
	for i in 10:
		var t := fmod(float(i) * 0.13 + k * 1.3, 1.0)
		var at := tail.lerp(head, t) + side * sin(float(i) * 4.0) * width * (0.6 + k)
		draw_circle(at, _tile * 0.05, Color(1.0, 0.95, 0.7, alpha))


func _draw_transmit(from: Vector2, to: Vector2, k: float) -> void:
	# Au départ il s'efface (la colonne se resserre), à l'arrivée il se reforme (elle s'ouvre).
	for end: Array in [[from, 1.0 - k], [to, minf(1.0, k * 2.0) * (1.0 - k)]]:
		var at: Vector2 = end[0]
		var strength: float = end[1]
		if strength <= 0.02:
			continue
		var width := _tile * 0.9 * strength
		draw_rect(Rect2(at.x - width * 0.5, at.y - _tile * 2.6, width, _tile * 2.7), Color(_colour, 0.5 * strength))
		draw_rect(Rect2(at.x - width * 0.15, at.y - _tile * 2.6, width * 0.3, _tile * 2.7), Color(1, 1, 1, 0.95 * strength))
		draw_circle(at, _tile * 0.7 * strength, Color(_colour, 0.4 * strength))
		for i in 12:
			var phase := fmod(float(i) * 0.083 + k * 2.0, 1.0)
			var spark: Vector2 = at + Vector2(sin(float(i) * 2.7) * _tile * 0.5, -phase * _tile * 2.2)
			draw_circle(spark, _tile * 0.08, Color(1.0, 0.95, 0.75, strength))


func _draw_dive(to: Vector2, k: float) -> void:
	var alpha := 1.0 - smoothstep(0.6, 1.0, k)
	# L'ombre qui se resserre avant l'impact.
	var fall := minf(1.0, k / 0.3)
	if k < 0.3:
		draw_arc(to, _tile * (1.6 - 1.2 * fall), 0.0, TAU, 32, Color(RIM, 0.5), 3.0, true)
		draw_circle(to, _tile * 0.5 * fall, Color(RIM, 0.3))
		return
	var hit := (k - 0.3) / 0.7
	# La colonne de lumière qui s'écrase, puis le sol qui se fend en étoile.
	var width := _tile * 0.9 * (1.0 - hit)
	if width > 0.5:
		draw_rect(Rect2(to.x - width * 0.5, to.y - _tile * 5.0, width, _tile * 5.0), Color(_colour, 0.55 * alpha))
		draw_rect(Rect2(to.x - width * 0.15, to.y - _tile * 5.0, width * 0.3, _tile * 5.0), Color(1, 1, 1, 0.9 * alpha))
	for i in 8:
		var dir := Vector2.from_angle(TAU * float(i) / 8.0 + 0.3)
		var length := _tile * (1.4 + 0.8 * float(i % 2)) * minf(1.0, hit * 3.0)
		var kink := dir.rotated(0.35 * (1.0 if i % 2 == 0 else -1.0))
		draw_polyline(PackedVector2Array([to, to + dir * length * 0.5, to + dir * length * 0.5 + kink * length * 0.5]),
			Color(_colour.lerp(Color.WHITE, 0.3), alpha), 3.0, true)
	draw_arc(to, _tile * 2.5 * hit, 0.0, TAU, 40, Color(_colour, 0.8 * alpha), 4.0, true)


func _draw_soar(from: Vector2, to: Vector2, k: float) -> void:
	var alpha := 1.0 - k
	var open := sin(minf(1.0, k * 2.5) * PI * 0.5)
	# Le sillage de flamme d'or entre le départ et l'arrivée.
	var dir := (to - from).normalized()
	var side := dir.orthogonal()
	var tail := from.lerp(to, minf(1.0, k * 1.3))
	if tail.distance_to(to) > 1.0:
		draw_colored_polygon(PackedVector2Array([tail, to + side * _tile * 0.35, to - side * _tile * 0.35]), Color("#ffb347", 0.5 * alpha))
		draw_colored_polygon(PackedVector2Array([tail, to + side * _tile * 0.15, to - side * _tile * 0.15]), Color(1, 0.97, 0.85, 0.8 * alpha))
	# Les deux immenses ailes : ouvertes au départ, repliées à l'arrivée.
	for end: Array in [[from, open * (1.0 - k)], [to, (1.0 - open) * 0.6 + 0.4 * open]]:
		var at: Vector2 = end[0]
		var strength: float = end[1]
		if strength < 0.05:
			continue
		for sgn: float in [-1.0, 1.0]:
			var root: Vector2 = at + Vector2(0.0, -_tile * 0.9)
			var tips := PackedVector2Array([root])
			for f in 4:
				var angle := -PI * 0.5 + sgn * (0.3 + 0.38 * float(f)) * (0.4 + 0.6 * strength)
				tips.append(root + Vector2.from_angle(angle) * _tile * (2.4 - 0.35 * float(f)))
			tips.append(root + Vector2(sgn * _tile * 0.6, _tile * 0.6))
			draw_colored_polygon(tips, Color(_colour, 0.4 * alpha * strength))
			for f in range(1, 5):
				draw_line(root, tips[f], Color(1.0, 0.95, 0.75, 0.8 * alpha * strength), 2.0)

