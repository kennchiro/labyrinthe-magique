class_name BoltStrike
extends Node2D

## La décharge du Cyclone, jouée SUR SA VICTIME.
##
## Quatre images dessinées — l'amorce, l'éclair, l'impact au sol, la retombée —
## posées par leur BASE sur la case frappée. Elles remplacent le trait tracé en
## code, qui reliait le phénomène à sa cible : ce trait disait d'où venait le
## coup, il ne disait pas ce qu'il faisait en arrivant.
##
## Jouées SANS boucle et sans fondu entre images : un éclair claque, il ne se
## fond pas dans le suivant.

const LIFE := 0.42

var _sprite: Sprite2D = null
var _frames: Array[Texture2D] = []
var _time := 0.0


func setup(tile_size: int, frames: Array, tall: float = 2.2) -> void:
	z_index = 15
	for frame in frames:
		if frame != null:
			_frames.append(frame)
	if _frames.is_empty():
		queue_free()
		return
	_sprite = Sprite2D.new()
	_sprite.texture = _frames[0]
	_sprite.centered = false
	_sprite.offset = Vector2(-_frames[0].get_width() * 0.5, -_frames[0].get_height())
	var span := (tile_size * tall) / float(_frames[0].get_height())
	_sprite.scale = Vector2(span, span)
	# ADDITIF : le dessin est un jaune-blanc très clair. Posé tel quel sur le sol
	# du labyrinthe il se délave — en additif il ÉCLAIRE ce qu'il couvre, ce qui
	# est ce que fait un éclair.
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	self.material = material
	add_child(_sprite)
	set_process(true)


func _process(delta: float) -> void:
	_time += delta
	if _time >= LIFE:
		queue_free()
		return
	var step := int((_time / LIFE) * float(_frames.size()))
	_sprite.texture = _frames[mini(step, _frames.size() - 1)]
