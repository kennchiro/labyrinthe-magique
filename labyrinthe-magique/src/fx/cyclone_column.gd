class_name CycloneColumn
extends Node2D

## LA COLONNE DU CYCLONE : le seul phénomène du jeu qui monte plus haut qu'une haie.
##
## Ce n'est pas un décor, c'est un ARGUMENT. Le sort frappe à travers les murs,
## et la règle du projet veut qu'un ultime n'ait le droit de casser une règle que
## si ça SE VOIT — c'est la hauteur de cette colonne qui le dit, et rien d'autre.
##
## Elle est posée par sa BASE : son pied tombe sur la case, le reste monte
## au-dessus. C'est le découpage qui le garantit (`build_spike_anim.py`, ancre
## « base »), pas un décalage deviné ici.
##
## Elle ne pivote jamais et ne se retourne jamais. Un tourbillon qui change de
## sens en cours de route cesse d'être un tourbillon.

## Images par seconde. Assez vif pour que la rotation emporte, assez lent pour
## qu'on voie les bandes tourner : à vingt images, la colonne grésille.
const SPIN_FPS := 13.0
## Temps de la levée et de la retombée. Une colonne qui apparaît d'un coup a
## l'air d'un décor téléporté ; celle-ci SE LÈVE.
const RISE := 0.5
const FALL := 0.6

var _sprite: Sprite2D = null
var _frames: Array[Texture2D] = []
var _time := 0.0
var _left := 0.0
var _span := 1.0
var _ending := false


func setup(tile_size: int, frames: Array, duration: float, tall: float = 3.4) -> void:
	z_index = 14
	for frame in frames:
		if frame != null:
			_frames.append(frame)
	if _frames.is_empty():
		queue_free()
		return
	_left = duration
	_sprite = Sprite2D.new()
	_sprite.texture = _frames[0]
	# Pied sur l'origine : on décentre d'une demi-largeur et d'une hauteur.
	_sprite.centered = false
	_sprite.offset = Vector2(-_frames[0].get_width() * 0.5, -_frames[0].get_height())
	_span = (tile_size * tall) / float(_frames[0].get_height())
	_sprite.scale = Vector2(_span, _span)
	add_child(_sprite)
	set_process(true)


## Le sort s'éteint : la colonne retombe au lieu de disparaître.
func stop() -> void:
	if not _ending:
		_ending = true
		_left = FALL


func _process(delta: float) -> void:
	_time += delta
	_left -= delta
	if _ending and _left <= 0.0:
		queue_free()
		return
	if not _ending and _left <= FALL:
		_ending = true
		_left = FALL

	_sprite.texture = _frames[int(_time * SPIN_FPS) % _frames.size()]
	# La levée et la retombée se jouent sur la HAUTEUR, pas sur l'opacité : une
	# colonne translucide se lit comme une colonne faible, alors qu'une colonne
	# courte se lit comme une colonne qui monte.
	var grow := 1.0
	if _ending:
		grow = clampf(_left / FALL, 0.0, 1.0)
	elif _time < RISE:
		var t := _time / RISE
		grow = t * t * (3.0 - 2.0 * t)
	_sprite.scale = Vector2(_span * (0.7 + 0.3 * grow), _span * grow)
	_sprite.self_modulate = Color(1.0, 1.0, 1.0, clampf(grow * 1.6, 0.0, 1.0))
