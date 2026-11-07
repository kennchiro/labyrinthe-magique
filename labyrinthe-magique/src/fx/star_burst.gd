class_name StarBurst
extends Node2D

## Un éclatement en étoile : l'impact de la Comète du Prisme, l'arrivée de sa Transmission, et les coups
## d'Aël qui n'ont pas d'effet à eux. Des rayons qui jaillissent, un anneau, un éclair blanc, et des
## éclats qui retombent. Sa taille et sa couleur disent la force du coup.

const LIFE := 0.5
const RAYS := 10
const RIM := Color("#16202b")

var _radius := 32.0
var _colour := Color.WHITE
var _life := 0.0


func setup(radius: float, colour: Color) -> void:
	_radius = radius
	_colour = colour
	z_index = 12


func _process(delta: float) -> void:
	_life += delta
	if _life >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := _life / LIFE
	var burst := 1.0 - pow(1.0 - minf(1.0, k * 2.5), 3.0)
	var alpha := 1.0 - k
	draw_circle(Vector2.ZERO, _radius * 0.38 * (1.0 - k), Color(1.0, 1.0, 1.0, 0.9 * alpha))
	draw_circle(Vector2.ZERO, _radius * 0.9 * burst, Color(_colour, 0.18 * alpha))
	draw_arc(Vector2.ZERO, _radius * burst, 0.0, TAU, 40, Color(RIM, 0.4 * alpha), 5.0, true)
	draw_arc(Vector2.ZERO, _radius * burst, 0.0, TAU, 40, Color(_colour, alpha), 3.0, true)
	# Les rayons : longs et courts en alternance, effilés.
	for i in RAYS:
		var angle := TAU * float(i) / float(RAYS) + 0.2
		var length := _radius * (1.25 if i % 2 == 0 else 0.8) * burst
		# Au tout premier instant le rayon n'a pas de longueur : un triangle plat ne se dessine pas.
		if length <= _radius * 0.3 or k >= 0.98:
			continue
		var dir := Vector2.from_angle(angle)
		var side := dir.orthogonal() * _radius * 0.06 * (1.0 - k)
		draw_colored_polygon(PackedVector2Array([dir * _radius * 0.2 + side, dir * length, dir * _radius * 0.2 - side]),
			Color(_colour.lerp(Color.WHITE, 0.4), alpha))
	# Les éclats qui retombent.
	for i in 6:
		var angle := TAU * float(i) / 6.0 + 0.5
		var at := Vector2.from_angle(angle) * _radius * (0.4 + 0.8 * k) + Vector2(0.0, _radius * 0.5 * k * k)
		draw_circle(at, _radius * 0.06 * (1.0 - k), Color(1.0, 1.0, 1.0, alpha))
