class_name KingDecoy
extends Node2D

## La Coquille de cendre : il laisse une armure grise à sa pose, qui se fissure et rougit jusqu'à
## l'explosion. Elle reprend l'image même du mage, à la même taille.

var _sprite: Sprite2D = null
var _material: ShaderMaterial = null
var _seconds := 3.0
var _life := 0.0


func setup(player: Player, seconds: float) -> void:
	_seconds = seconds
	z_index = 10
	_sprite = player.sprite.duplicate() as Sprite2D
	_material = KingArmor.metal_material(0.0, 1.0)
	_sprite.material = _material
	_sprite.modulate = Color.WHITE
	_sprite.position = player.sprite.position
	add_child(_sprite)


func _process(delta: float) -> void:
	_life += delta
	var share := clampf(_life / _seconds, 0.0, 1.0)
	_material.set_shader_parameter("heat", share * share)
	_material.set_shader_parameter("flash", maxf(0.0, 1.0 - _life * 6.0))
	# Il tremble de plus en plus : on doit sentir venir le moment de s'en éloigner.
	_sprite.rotation = sin(_life * (10.0 + share * 40.0)) * 0.05 * share
