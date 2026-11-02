class_name SlashArc
extends Node2D

## L'arc de lame, à l'impact d'un coup. Il suit le personnage, et il est tracé et non
## dessiné dans la planche : sa durée reste celle du jeu, et sa couleur vient du profil.

const SWEEP := 0.13
const FADE := 0.12
const SEGMENTS := 18
## L'arc balaie dans le sens du geste dessiné sur les planches, en degrés, 0 vers la
## droite et 90 vers le bas.
const ANGLES := {
	Vector2i.RIGHT: Vector2(-75.0, 70.0),
	Vector2i.LEFT: Vector2(255.0, 110.0),
	Vector2i.DOWN: Vector2(200.0, 30.0),
	Vector2i.UP: Vector2(20.0, -160.0),
}
## Le cerne sombre garde l'arc lisible sur les sols clairs.
const RIM := Color("#16202b")

var _from := 0.0
var _to := 0.0
var _radius := 30.0
var _width := 13.0
var _colour := Color.WHITE
var _life := 0.0


func setup(facing: Vector2i, radius: float, colour: Color) -> void:
	var angles: Vector2 = ANGLES.get(facing, ANGLES[Vector2i.DOWN])
	_from = deg_to_rad(angles.x)
	_to = deg_to_rad(angles.y)
	_radius = radius
	_width = radius * 0.34
	_colour = colour
	queue_redraw()


func _process(delta: float) -> void:
	_life += delta
	if _life >= SWEEP + FADE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var head := minf(1.0, _life / SWEEP)
	head = 1.0 - pow(1.0 - head, 3.0)
	var alpha := 1.0 - clampf((_life - SWEEP) / FADE, 0.0, 1.0)
	# La traîne rattrape la tête une fois le geste fini : l'arc se referme sur sa pointe.
	var tail := clampf((_life - SWEEP * 0.35) / (SWEEP + FADE * 0.6), 0.0, 1.0)
	# En fin de course, le croissant trop court ne serait plus qu'un éclat de cerne.
	if head - tail <= 0.1:
		return
	_crescent(head, tail, _width + 3.0, 1.5, Color(RIM, 0.55 * alpha * alpha))
	_crescent(head, tail, _width, 0.0, Color(_colour, 0.85 * alpha))
	_crescent(head, tail, _width * 0.45, -1.0, Color(1.0, 1.0, 1.0, alpha))


## Un croissant effilé aux deux bouts, entre deux fractions du balayage.
func _crescent(head: float, tail: float, width: float, outset: float, colour: Color) -> void:
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in SEGMENTS + 1:
		var along := float(i) / float(SEGMENTS)
		var angle := lerpf(_from, _to, lerpf(tail, head, along))
		var thick := sin(along * PI) * width
		var direction := Vector2.from_angle(angle)
		outer.append(direction * (_radius + outset))
		inner.append(direction * (_radius + outset - thick))
	inner.reverse()
	outer.append_array(inner)
	draw_colored_polygon(outer, colour)
