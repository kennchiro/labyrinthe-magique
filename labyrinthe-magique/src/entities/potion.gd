class_name Potion
extends Node2D

## Fiole de pouvoir. La ramasser remplit le sac de sorts
## (SpellSystem.POTION_CHARGES tirs) ; le cyan de son contenu est exactement
## celui de l'orbe qu'elle permet de lancer — c'est ce qui apprend au joueur ce
## qu'elle fait, sans une ligne de tutoriel.

const TEXTURE := preload("res://assets/sprites/potion.png")
const TINT := Color("#2ec4ff")
const TARGET_HEIGHT_TILES := 0.92

@onready var sprite: Sprite2D = $Sprite2D

var cell: Vector2i = Vector2i.ZERO
var tile_size: int = 32

var _time := 0.0


func setup(p_cell: Vector2i, p_tile_size: int) -> void:
	cell = p_cell
	tile_size = p_tile_size
	sprite.texture = TEXTURE
	var factor := (tile_size * TARGET_HEIGHT_TILES) / float(TEXTURE.get_height())
	sprite.scale = Vector2(factor, factor)

	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	self.material = material


func _process(delta: float) -> void:
	_time += delta
	sprite.position = Vector2(0.0, sin(_time * 1.8) * tile_size * 0.08 - tile_size * 0.14)
	queue_redraw()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_time * 3.0)
	var centre := Vector2(0.0, -tile_size * 0.12)
	draw_circle(centre, tile_size * (0.70 + 0.12 * pulse), Color(TINT.r, TINT.g, TINT.b, 0.09))
	draw_circle(centre, tile_size * (0.40 + 0.07 * pulse), Color(TINT.r, TINT.g, TINT.b, 0.15))
