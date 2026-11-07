class_name SlashArc
extends Node2D

## L'arc de lame, à l'impact d'un coup. Il suit le personnage, et il est tracé et non
## dessiné dans la planche : sa durée reste celle du jeu, et sa couleur vient du profil.

const SWEEP := 0.13
## Assez long pour être vu : à 0,12 s, une revue ne le trouvait sur aucune capture.
const FADE := 0.22
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
var _sweep := SWEEP


## `mirrored` fait partir l'arc de l'autre bout : le revers, après le coup droit.
func setup(facing: Vector2i, radius: float, colour: Color, mirrored := false) -> void:
	var angles: Vector2 = ANGLES.get(facing, ANGLES[Vector2i.DOWN])
	_from = deg_to_rad(angles.y if mirrored else angles.x)
	_to = deg_to_rad(angles.x if mirrored else angles.y)
	_radius = radius
	_width = radius * 0.46
	_colour = colour
	queue_redraw()


## Le tour complet, autour du lanceur : le grand coup circulaire d'Aël. Plus lent qu'un arc,
## et plus fin pour sa taille, sinon il couvrirait tout ce qu'il entoure.
func setup_ring(radius: float, colour: Color, seconds: float = 0.26) -> void:
	_from = deg_to_rad(-90.0)
	_to = deg_to_rad(270.0)
	_radius = radius
	_width = radius * 0.16
	_colour = colour
	_sweep = seconds
	queue_redraw()


func _process(delta: float) -> void:
	_life += delta
	if _life >= _sweep + FADE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var head := minf(1.0, _life / _sweep)
	head = 1.0 - pow(1.0 - head, 3.0)
	var alpha := 1.0 - clampf((_life - _sweep) / FADE, 0.0, 1.0)
	# La traîne rattrape la tête une fois le geste fini : l'arc se referme sur sa pointe.
	var tail := clampf((_life - _sweep * 0.35) / (_sweep + FADE * 0.6), 0.0, 1.0)
	# En fin de course, le croissant trop court ne serait plus qu'un éclat de cerne.
	if head - tail <= 0.1:
		return
	_crescent(head, tail, _width + 3.0, 1.5, Color(RIM, 0.55 * alpha * alpha))
	_crescent(head, tail, _width, 0.0, Color(_colour, 0.85 * alpha))
	_crescent(head, tail, _width * 0.45, -1.0, Color(1.0, 1.0, 1.0, alpha))
	# Les étincelles d'acier qui jaillissent de la tête du coup : c'est là qu'il porte.
	var tip := Vector2.from_angle(lerpf(_from, _to, head)) * _radius
	for i in 4:
		var spray := Vector2.from_angle(lerpf(_from, _to, head) + PI * 0.5 * signf(_to - _from) + (float(i) - 1.5) * 0.35)
		draw_line(tip, tip + spray * _radius * (0.25 + 0.12 * float(i % 2)) * alpha, Color(1.0, 1.0, 1.0, alpha), 1.5)


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
