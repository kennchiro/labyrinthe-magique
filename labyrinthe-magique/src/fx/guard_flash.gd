class_name GuardFlash
extends Node2D

## Les trois protections d'Aël, chacune avec sa forme : jamais la bulle d'un autre personnage.
## - CROSS, la Parade de l'Apprenti : deux lames d'acier en croix et un anneau de facettes. Pas de
##   magie : c'est sa garde.
## - PLATES, le Prisme gardien de l'Éveillé : six plaques de cristal cyan en hexagone, qui tournent
##   et s'illuminent une à une quand un coup est renvoyé.
## - SPHERE, la Barrière d'aura du Prisme : une sphère de lumière d'or, des méridiens qui tournent
##   et une couronne de rayons qui bat.
## - SCALES, les Écailles de soleil du Dragon d'or : de grandes écailles d'or se dressent autour de lui
##   en corolle, et une couronne de flammes tourne à leur pied.

enum Style { CROSS, PLATES, SPHERE, SCALES }

const FACETS := 8
const OPEN := 0.12
const CLOSE := 0.18
const RIM := Color("#16202b")
const GOLD := Color("#f2c94c")

var _radius := 20.0
var _colour := Color.WHITE
var _duration := 1.0
var _life := 0.0
var _flash := 0.0
var _style := Style.CROSS


func setup(radius: float, colour: Color, duration: float, style: Style = Style.CROSS) -> void:
	_radius = radius
	_colour = colour
	_duration = maxf(OPEN + CLOSE, duration)
	_style = style
	_flash = 1.0
	z_index = 2


## Un coup paré ou renvoyé : la protection se rallume.
func parry() -> void:
	_flash = 1.0


func _process(delta: float) -> void:
	_life += delta
	_flash = maxf(0.0, _flash - delta * 5.0)
	if _life >= _duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var grow := minf(1.0, _life / OPEN)
	var alpha := clampf((_duration - _life) / CLOSE, 0.0, 1.0)
	var radius := _radius * (0.6 + 0.4 * grow)
	match _style:
		Style.PLATES:
			_draw_plates(radius, alpha)
		Style.SPHERE:
			_draw_sphere(radius, alpha)
		Style.SCALES:
			_draw_scales(radius, alpha)
		_:
			_draw_cross(radius, alpha)


func _draw_cross(radius: float, alpha: float) -> void:
	# L'anneau de facettes, qui tourne lentement.
	var ring := PackedVector2Array()
	for i in FACETS + 1:
		ring.append(Vector2.from_angle(TAU * float(i) / FACETS + _life * 0.8) * radius)
	# L'anneau est une lame d'acier qui tourne, pas un tracé : plein, pâle, cerné.
	# Le polygone plein ne reprend pas son premier point : le contour, lui, se referme dessus.
	draw_colored_polygon(ring.slice(0, FACETS), Color(_colour, (0.12 + 0.2 * _flash) * alpha))
	draw_polyline(ring, Color(RIM, 0.45 * alpha), 6.0)
	draw_polyline(ring, Color(_colour, 0.9 * alpha), 3.5)
	for i in FACETS:
		draw_circle(ring[i], 2.2, Color(1.0, 1.0, 1.0, 0.8 * alpha))
	# La croix des deux lames, plus vive à chaque parade.
	var glint := 0.45 + 0.55 * _flash
	for direction in [Vector2(1, -1), Vector2(1, 1)]:
		var d: Vector2 = direction.normalized() * radius * (0.75 + 0.2 * _flash)
		draw_line(-d, d, Color(RIM, 0.5 * alpha * glint), 9.0)
		draw_line(-d, d, Color(_colour, alpha * glint), 6.0)
		draw_line(-d * 0.7, d * 0.7, Color(1.0, 1.0, 1.0, alpha * glint), 2.5)


func _draw_plates(radius: float, alpha: float) -> void:
	# Six plaques taillées, dressées en hexagone autour de lui ; celle qui renvoie un coup brille.
	var lit := int(_life * 12.0) % 6
	for i in 6:
		var angle := TAU * float(i) / 6.0 + _life * 0.6
		var centre := Vector2.from_angle(angle) * radius * 1.05
		var along := Vector2.from_angle(angle + PI * 0.5) * radius * 0.42
		var out := Vector2.from_angle(angle) * radius * 0.12
		var plate := PackedVector2Array([centre - along - out, centre - along * 0.7 + out,
			centre + along * 0.7 + out, centre + along - out])
		var bright := 1.0 if (_flash > 0.0 and i == lit) else 0.0
		draw_colored_polygon(plate, Color(_colour.lerp(Color.WHITE, 0.6 * bright), (0.45 + 0.4 * bright) * alpha))
		draw_polyline(PackedVector2Array([plate[0], plate[1], plate[2], plate[3], plate[0]]),
			Color(1.0, 1.0, 1.0, 0.85 * alpha), 1.5)
		draw_line(centre - along * 0.6, centre + along * 0.2, Color(1.0, 1.0, 1.0, 0.6 * alpha), 1.0)
	draw_arc(Vector2.ZERO, radius * 1.05, 0.0, TAU, 36, Color(_colour, 0.18 * alpha * (1.0 + _flash)), 2.0, true)


func _draw_sphere(radius: float, alpha: float) -> void:
	var r := radius * 1.15
	var beat := 1.0 + 0.06 * sin(_life * 9.0)
	draw_circle(Vector2.ZERO, r * beat, Color(GOLD, (0.12 + 0.2 * _flash) * alpha))
	draw_arc(Vector2.ZERO, r * beat, 0.0, TAU, 48, Color(RIM, 0.35 * alpha), 4.0, true)
	draw_arc(Vector2.ZERO, r * beat, 0.0, TAU, 48, Color(_colour, 0.95 * alpha), 2.5, true)
	# Les méridiens : des ellipses qui tournent, comme un globe de lumière.
	for i in 3:
		var squash := absf(cos(_life * 2.0 + float(i) * PI / 3.0))
		var pts := PackedVector2Array()
		for k in 33:
			var a := TAU * float(k) / 32.0
			pts.append(Vector2(cos(a) * r * squash, sin(a) * r) * beat)
		draw_polyline(pts, Color(1.0, 0.97, 0.85, 0.35 * alpha), 1.2, true)
	# La couronne de rayons qui bat au-dessus de la sphère.
	for i in 12:
		var dir := Vector2.from_angle(TAU * float(i) / 12.0 + _life)
		draw_line(dir * r * 1.05, dir * r * (1.2 + 0.15 * sin(_life * 10.0 + float(i))),
			Color(1.0, 1.0, 1.0, 0.7 * alpha), 1.5)


func _draw_scales(radius: float, alpha: float) -> void:
	# La couronne de flammes, au pied des écailles.
	for i in 16:
		var a := TAU * float(i) / 16.0 + _life * 3.0
		var dir := Vector2.from_angle(a)
		var lick := radius * (0.25 + 0.15 * sin(_life * 20.0 + float(i)))
		draw_line(dir * radius * 1.1, dir * (radius * 1.1 + lick), Color("#ffb347", 0.8 * alpha), 3.0)
	# Les écailles dressées, pointe vers l'extérieur, qui s'illuminent quand un coup les frappe.
	for i in 10:
		var a := TAU * float(i) / 10.0 + _life * 0.4
		var dir := Vector2.from_angle(a)
		var side := dir.orthogonal() * radius * 0.26
		var base := dir * radius * 0.55
		var tip := dir * radius * (1.25 + 0.1 * _flash)
		draw_colored_polygon(PackedVector2Array([base + side, tip, base - side]), Color(RIM, 0.5 * alpha))
		draw_colored_polygon(PackedVector2Array([base + side * 0.8, tip, base - side * 0.8]),
			Color(GOLD.lerp(Color.WHITE, 0.5 * _flash), 0.9 * alpha))
		draw_line(base, tip, Color(1.0, 0.97, 0.85, alpha), 1.2)

