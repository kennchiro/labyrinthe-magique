class_name LightningArc
extends Node2D

## Un arc de foudre entre deux points : le trait qui rend la chaîne visible.
##
## Sans lui, une chaîne d'éclairs se lit comme cinq dégâts simultanés sur cinq
## ennemis — le joueur voit les chiffres monter sans comprendre qu'ils sont
## LIÉS. C'est le trait, et lui seul, qui raconte le saut.
##
## Le tracé est BRISÉ et retiré au sort, mais à partir d'une graine dérivée des
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
const SEGMENTS := 7
## Écart maximal d'un coude par rapport à la ligne droite, en fraction de la
## distance parcourue. C'est ce qui fait la nervosité du trait.
const JAG := 0.16

var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _tint := Color(1.0, 0.95, 0.55)
var _life := 0.0
var _points := PackedVector2Array()
var _width := 3.0


func setup(from: Vector2, to: Vector2, tint: Color, width: float) -> void:
	_from = from
	_to = to
	_tint = tint
	_width = maxf(1.0, width)
	position = Vector2.ZERO

	var rng := RandomNumberGenerator.new()
	rng.seed = int(absf(from.x + from.y * 7.0 + to.x * 13.0 + to.y * 29.0)) + 1
	var span := to - from
	var across := Vector2(-span.y, span.x).normalized()
	_points.append(from)
	for i in range(1, SEGMENTS):
		var t := float(i) / float(SEGMENTS)
		# Les coudes sont plus francs AU MILIEU qu'aux extrémités : un éclair
		# part d'un point précis et arrive à un point précis, il ne flotte qu'entre
		# les deux.
		var belly := sin(t * PI)
		var offset := across * rng.randf_range(-1.0, 1.0) * span.length() * JAG * belly
		_points.append(from + span * t + offset)
	_points.append(to)

	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	self.material = material


func _process(delta: float) -> void:
	_life += delta
	if _life >= LIFETIME:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	if _points.size() < 2:
		return
	var fade := 1.0 - _life / LIFETIME
	# Quatre passes : deux halos, le trait, puis un cœur blanc. Une seule ligne
	# donne un trait de crayon ; c'est l'empilement qui fait la lumière.
	#
	# ⚠️ Les largeurs ont été TRIPLÉES après capture. Le trait était juste, mais
	# à l'échelle du jeu — une case fait 32 pixels et la caméra dézoome — le
	# cœur mesurait moins de deux pixels : à l'écran, la Chaîne d'éclairs et la
	# frappe du Jugement ne montraient qu'un impact au sol, sans le trait qui
	# les explique. Un effet correct en isolement peut être invisible en jeu :
	# c'est l'image du JEU qui tranche, jamais celle du banc d'essai.
	# La teinte de l'élément sert de HALO, pas de corps. Le corps est doré et
	# saturé, le cœur est blanc : c'est ce contraste-là qui fait lire un éclair
	# sur le vert du labyrinthe. Un trait uniformément teinté s'y délavait.
	draw_polyline(_points, Color(_tint.r * 0.40, _tint.g * 0.45, 1.0, 0.20 * fade),
		_width * 9.0, true)
	draw_polyline(_points, Color(_tint.r * 0.75, _tint.g * 0.70, 1.0, 0.35 * fade),
		_width * 4.5, true)
	draw_polyline(_points, Color(1.0, 0.78, 0.12, 0.95 * fade), _width * 2.0, true)
	draw_polyline(_points, Color(1, 1, 1, fade), _width * 0.7, true)
