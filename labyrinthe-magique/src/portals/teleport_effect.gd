class_name TeleportEffect
extends Node2D

## Éclat joué au départ et à l'arrivée d'une téléportation. Se libère tout seul.
## Additif, comme les portails : une onde de lumière, pas un décalcomanie.

const TEXTURE := preload("res://assets/sprites/teleport_burst.png")
const DURATION := 0.45

@onready var sprite: Sprite2D = $Sprite2D

var tile_size: int = 32
var tint: Color = Color("#8fe6ff")

var _life := 0.0
var _base_scale := 1.0
var _size_tiles := 1.7


## `size_tiles` : envergure de l'éclat, en cases. 1,7 pour une téléportation ;
## une explosion passe son propre rayon, sinon un sort de 6 cases de portée
## produirait le même petit flash qu'un saut de portail.
func setup(p_tile_size: int, p_color: Color, size_tiles: float = 1.7) -> void:
	tile_size = p_tile_size
	tint = p_color
	_size_tiles = size_tiles
	sprite.texture = TEXTURE
	_base_scale = (tile_size * size_tiles) / float(TEXTURE.get_height())
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	sprite.material = material


func _process(delta: float) -> void:
	_life += delta
	if _life >= DURATION:
		queue_free()
		return
	var t := _life / DURATION
	var factor := _base_scale * (0.45 + 1.3 * t)
	sprite.scale = Vector2(factor, factor)
	sprite.rotation = t * 1.2
	sprite.modulate = Color(tint.r, tint.g, tint.b, 1.0 - t)
	queue_redraw()


func _draw() -> void:
	var t := _life / DURATION
	var fade := 1.0 - t
	draw_arc(Vector2.ZERO, tile_size * _size_tiles * (0.15 + 0.82 * t), 0.0, TAU, 40,
		Color(tint.r, tint.g, tint.b, fade * 0.9), 1.0 + 4.0 * fade)
