class_name LightningArc
extends Node2D

## Un arc de foudre entre deux points : le trait qui rend la chaîne visible.
##
## Sans lui, une chaîne d'éclairs se lit comme cinq dégâts simultanés sur cinq
## ennemis — le joueur voit les chiffres monter sans comprendre qu'ils sont
## LIÉS. C'est le trait, et lui seul, qui raconte le saut.
##
## Le tracé est BRISÉ, fourchu, et retiré au sort, mais à partir d'une graine dérivée des
## deux extrémités : deux captures du même sort donnent donc le même éclair, ce
## qui permet de comparer deux images. Un tracé retiré à chaque frame
## grésillerait sans raison.
##
## Il vit très peu de temps — un dixième de seconde — parce qu'un éclair qui
## traîne devient un câble.

## Court, mais pas fugace : à 0,14 s le trait passait inaperçu dès que les deux
## créatures étaient proches. Un éclair qui traîne devient un câble ; un éclair
## qu'on ne voit pas n'explique rien.
const LIFETIME := 0.20
## Trois passes de milieu brisé : huit tronçons, de longueurs inégales, cassés sur
## trois échelles. Sept coudes de même taille donnaient un zigzag d'écolier.
const PASSES := 3
## Écart d'un coude par rapport à sa corde, en fraction de la corde.
const JAG := 0.24
const FORKS := 2
## Longueur d'une fourche, en fraction de ce qu'il reste au trait à parcourir.
const FORK_REACH := 0.3

var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _tint := Color(1.0, 0.95, 0.55)
var _life := 0.0
## Deux formes : il claque une fois en changeant de tracé à mi-vie. Chacune : le trait,
## puis ses fourches.
var _shapes: Array = []
var _width := 3.0
var _lifetime := LIFETIME


## `lifetime` allonge un sort qui doit se voir (la Chaîne, l'Orage) ; le trait de
## l'attaque garde le claquement bref.
func setup(from: Vector2, to: Vector2, tint: Color, width: float,
		lifetime: float = LIFETIME) -> void:
	_from = from
	_to = to
	_tint = tint
	_width = maxf(1.0, width)
	_lifetime = maxf(0.05, lifetime)
	position = Vector2.ZERO

	var rng := RandomNumberGenerator.new()
	rng.seed = int(absf(from.x + from.y * 7.0 + to.x * 13.0 + to.y * 29.0)) + 1
	_shapes = [_trace(rng), _trace(rng)]


func _trace(rng: RandomNumberGenerator) -> Array:
	var main := _broken(_from, _to, rng)
	var out: Array = [main]
	for i in FORKS:
		var at := rng.randi_range(1, main.size() - 3)
		var start := main[at]
		var heading := (main[at + 1] - start).normalized()
		var side := -1.0 if i == 0 else 1.0
		var reach := (_to - start).length() * FORK_REACH
		var end := start + heading.rotated(side * rng.randf_range(0.4, 0.9)) * reach
		out.append(_broken(start, end, rng))
	return out


## Le milieu de chaque tronçon s'écarte de sa corde, et on recommence : les grands coudes
## d'abord, puis les petits. Les bouts ne bougent jamais : un éclair part d'un point
## précis et arrive à un point précis.
func _broken(from: Vector2, to: Vector2, rng: RandomNumberGenerator) -> PackedVector2Array:
	var points := PackedVector2Array([from, to])
	for pass_index in PASSES:
		var next := PackedVector2Array()
		for i in points.size() - 1:
			var a := points[i]
			var b := points[i + 1]
			var chord := b - a
			var across := Vector2(-chord.y, chord.x)
			next.append(a)
			next.append(a + chord * rng.randf_range(0.35, 0.65) + across * rng.randf_range(-JAG, JAG))
		next.append(points[-1])
		points = next
	return points


func _process(delta: float) -> void:
	_life += delta
	if _life >= _lifetime:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	if _shapes.is_empty():
		return
	var shape: Array = _shapes[0 if _life < _lifetime * 0.5 else 1]
	var fade := 1.0 - _life / _lifetime * 0.6
	# Trois passes : le halo, le cerne bleu, le cœur blanc.
	#
	# ⚠️ Composé NORMALEMENT, et le cerne fait le travail : en additif, doré sur blanc, le
	# trait se délavait sur l'herbe et la neige. Il reste épais pour la même raison que le
	# reste : à l'échelle du jeu, un cœur de moins de deux pixels ne se voit pas.
	for layer in [[4.6, Color(0.26, 0.4, 1.0, 0.22)], [1.9, Color(0.2, 0.32, 1.0, 0.95)],
			[0.85, Color(1.0, 1.0, 0.92, 1.0)]]:
		var width: float = _width * float(layer[0])
		var color: Color = layer[1]
		color.a *= fade
		for i in shape.size():
			draw_polyline(shape[i], color, width if i == 0 else width * 0.5, true)
