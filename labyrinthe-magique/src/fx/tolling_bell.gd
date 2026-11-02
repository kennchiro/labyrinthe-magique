class_name TollingBell
extends Node2D

## La cloche fantôme du Glas : elle flotte au-dessus du cercle et se balance à chaque coup. Son
## dessin est celui de l'icône du sort : c'est ce que le joueur a appris à reconnaître.

const TEXTURE := preload("res://assets/icons/mort/mort_glas.png")
const HEIGHT_TILES := 1.5
const SIZE_TILES := 1.5
const SWING := 0.32
const TOLL := 1.4
const FADE := 0.4

var _sprite: Sprite2D
var _duration := 1.0
var _time := 0.0


func setup(tile_size: int, duration: float) -> void:
	_duration = maxf(FADE * 2.0, duration)
	_sprite = Sprite2D.new()
	_sprite.texture = TEXTURE
	_sprite.scale = Vector2.ONE * float(tile_size) * SIZE_TILES / float(TEXTURE.get_width())
	_sprite.position = Vector2(0.0, -float(tile_size) * HEIGHT_TILES)
	add_child(_sprite)
	z_index = 11


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration:
		queue_free()
		return
	_sprite.rotation = sin(_time / TOLL * TAU) * SWING
	modulate.a = minf(minf(_time, _duration - _time) / FADE, 1.0) * 0.92
