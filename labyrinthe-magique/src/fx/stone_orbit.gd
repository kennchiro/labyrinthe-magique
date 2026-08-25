class_name StoneOrbit
extends Node2D

## LES PIERRES QUI TOURNENT AUTOUR DU MAGE, et qu'il lance.
##
## Première version : un cristal flottait à son côté et crachait des éclats. Ça
## marchait, mais ça ne racontait rien — la munition sortait de nulle part.
## Ici, ce qu'on voit tourner est ce qui part : le mage arrache pierres et
## cristaux au sol, les tient en orbite, et les envoie un par un. Le stock est
## VISIBLE, donc le joueur sait ce qu'il lui reste sans lire un chiffre.
##
## Les pierres reviennent d'elles-mêmes quelques instants après avoir été
## lancées — le sort dure dix secondes, pas cinq tirs.

const COUNT := 5
const ORBIT_TILES := 1.0
## Une pierre lancée met ce temps à se reformer dans l'orbite.
const REGROW := 1.1
const RISE := 0.25
const SINK := 0.35
## Sous ce reste de temps, l'orbite s'emballe : le sort s'achève.
const WARNING := 2.5

var tile_size: int = 32

var _left := 0.0
var _total := 1.0
var _time := 0.0
var _stones: Array[Sprite2D] = []
## Instant où chaque pierre a été lancée, -1 si elle est en place.
var _gone: Array[float] = []
## L'anneau de départ : il s'ouvre là où la pierre vient de quitter l'orbite.
var _burst := 0.0
var _burst_at := Vector2.ZERO
var _tint := Color(0.55, 1.0, 0.45)


func setup(p_tile_size: int, duration: float, pieces: Array) -> void:
	tile_size = p_tile_size
	_total = maxf(0.5, duration)
	_left = _total
	z_index = 11
	var usable: Array = []
	for piece in pieces:
		if piece != null:
			usable.append(piece)
	if usable.is_empty():
		queue_free()
		return
	for i in COUNT:
		var texture: Texture2D = usable[i % usable.size()]
		var stone := Sprite2D.new()
		stone.texture = texture
		# PETITS éclats, comme ceux de l'Égide : ce cercle est la réserve du
		# mage, pas le projectile. Ce qui part est bien plus gros — c'est
		# précisément ce contraste qui fait qu'un jet se remarque.
		var span := (tile_size * 0.5) / float(texture.get_height())
		stone.scale = Vector2(span, span)
		stone.modulate = Color(1, 1, 1, 0)
		add_child(stone)
		_stones.append(stone)
		_gone.append(-1.0)


## Lance la pierre la mieux placée vers la cible. Retourne d'où elle part et ce
## qu'elle est — le projectile doit être LA MÊME pierre que celle qui vient de
## quitter l'orbite, sinon l'œil ne fait pas le lien.
func launch(target: Vector2) -> Dictionary:
	var best := -1
	var best_score := 1e9
	for i in _stones.size():
		if _gone[i] >= 0.0:
			continue
		var score: float = _stones[i].global_position.distance_to(target)
		if score < best_score:
			best_score = score
			best = i
	if best < 0:
		return {}
	_gone[best] = _time
	# L'ÉCLAT DE DÉPART. Une pierre qui quitte l'orbite sans rien laisser
	# derrière elle semble simplement disparaître ; l'anneau dit qu'elle a été
	# LANCÉE, et par le mage.
	_burst = 1.0
	_burst_at = _stones[best].position
	queue_redraw()
	return {
		"position": _stones[best].global_position,
		"texture": _stones[best].texture,
	}


func stop() -> void:
	_left = minf(_left, SINK)


func _draw() -> void:
	if _burst <= 0.0:
		return
	# Un anneau qui s'ouvre et pâlit, plus quelques traits qui fusent : le
	# souffle vert de la magie de terre, au point de départ exact du jet.
	var t := 1.0 - _burst
	var radius := tile_size * (0.18 + 0.5 * t)
	draw_arc(_burst_at, radius, 0.0, TAU, 22,
		Color(_tint.r, _tint.g, _tint.b, 0.8 * _burst), 3.0, true)
	draw_arc(_burst_at, radius * 0.62, 0.0, TAU, 18,
		Color(1, 1, 1, 0.5 * _burst), 2.0, true)
	for i in 6:
		var angle := TAU * float(i) / 6.0 + _time
		var away := Vector2(cos(angle), sin(angle) * 0.5)
		draw_line(_burst_at + away * radius * 0.7, _burst_at + away * radius * 1.25,
			Color(_tint.r, _tint.g, _tint.b, 0.55 * _burst), 2.0, true)


func _process(delta: float) -> void:
	_time += delta
	if _burst > 0.0:
		_burst = maxf(0.0, _burst - delta * 3.2)
		queue_redraw()
	_left = maxf(0.0, _left - delta)
	if _left <= 0.0:
		queue_free()
		return

	var born := clampf(_time / RISE, 0.0, 1.0)
	var closing := clampf(_left / SINK, 0.0, 1.0)
	var hurry := 1.0 + 1.6 * (1.0 - clampf(_left / WARNING, 0.0, 1.0))
	var radius := tile_size * ORBIT_TILES * born * closing
	for i in _stones.size():
		var stone := _stones[i]
		var phase := _time * 1.6 * hurry + TAU * float(i) / float(COUNT)
		# Ellipse et non cercle : vue de dessus, une orbite autour d'un
		# personnage est écrasée. Et ce qui passe derrière lui s'assombrit,
		# rétrécit et passe SOUS son sprite — sans ça, les pierres tournent à
		# plat devant le mage.
		var depth := 0.5 + 0.5 * sin(phase)
		stone.position = Vector2(cos(phase) * radius,
			sin(phase) * radius * 0.38 - tile_size * 0.6)
		var shrink := 0.82 + 0.18 * depth
		var span := (tile_size * 0.5) / float(stone.texture.get_height())
		stone.scale = Vector2(span * shrink, span * shrink)
		stone.rotation = phase * 0.8
		stone.z_index = 2 if depth > 0.5 else -2

		# Une pierre lancée manque à l'appel, puis se reforme.
		var presence := born * closing
		if _gone[i] >= 0.0:
			var back := (_time - _gone[i]) / REGROW
			if back >= 1.0:
				_gone[i] = -1.0
			else:
				presence *= back * back
		var tint := 0.75 + 0.25 * depth
		stone.modulate = Color(tint, 1.0, tint * 0.92, presence)
