class_name ShadowDouble
extends Node2D

## L'OMBRE DU SEIGNEUR DU NÉANT (l'Éveil du Sorcier des Ténèbres) : sa propre silhouette, noire au liseré
## violet, qui le suit un pas derrière lui et refait ses gestes. Elle recopie à chaque image le sprite du
## mage (`neant_silhouette.gdshader`) : aucune planche à dessiner, et elle porte toujours sa pose du moment.
##
## Figée (`frozen`), elle sert de leurre à la Marche des ombres : elle garde la pose du départ.

const SHADER := preload("res://assets/shaders/neant_silhouette.gdshader")
## Combien de cases derrière lui elle marche, et un peu plus grande que lui.
const BEHIND := 0.6
const SCALE := 1.12
## Le temps d'un coup : elle s'élance vers la cible et s'embrase, puis revient.
const STRIKE_TIME := 0.35
const LUNGE := 0.45
const FADE_TIME := 0.4

var _player: Player = null
var _sprite: Sprite2D = null
var _material: ShaderMaterial = null
var _tile := 32
var _frozen := false
var _seconds := -1.0
var _life := 0.0
var _strike := 0.0
var _target := Vector2.ZERO
var _heading := Vector2.DOWN
var _last := Vector2.ZERO
var _leaving := false
var _fade := 0.0


func setup(player: Player, tile: int, frozen: bool = false, seconds: float = -1.0) -> void:
	_player = player
	_tile = tile
	_frozen = frozen
	_seconds = seconds
	z_index = 9
	_sprite = player.sprite.duplicate() as Sprite2D
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter("fade", 0.0)
	_sprite.material = _material
	_sprite.modulate = Color.WHITE
	add_child(_sprite)
	_copy()
	_last = player.position
	position = player.position


func _copy() -> void:
	var source := _player.sprite
	_sprite.texture = source.texture
	_sprite.hframes = source.hframes
	_sprite.vframes = source.vframes
	_sprite.frame = source.frame
	_sprite.flip_h = source.flip_h
	_sprite.scale = source.scale * SCALE
	_sprite.offset = source.offset
	_sprite.position = source.position


## L'ombre refait le coup : elle s'élance vers `target` (position dans le monde) et s'embrase.
func strike(target: Vector2) -> void:
	_strike = STRIKE_TIME
	_target = target


## Où elle se tient, dans le monde : d'où part le coup qu'elle répète.
func hand() -> Vector2:
	return position + Vector2(0.0, -_tile * 0.5)


## Elle se dissout, puis disparaît.
func dissolve() -> void:
	_leaving = true


func _process(delta: float) -> void:
	_life += delta
	if _player == null or not is_instance_valid(_player):
		queue_free()
		return
	if _seconds > 0.0 and _life >= _seconds:
		_leaving = true
	_fade = maxf(0.0, _fade - delta / FADE_TIME) if _leaving else minf(1.0, _fade + delta / FADE_TIME)
	if _leaving and _fade <= 0.0:
		queue_free()
		return
	_strike = maxf(0.0, _strike - delta)
	var glow := _strike / STRIKE_TIME
	_material.set_shader_parameter("fade", _fade)
	_material.set_shader_parameter("glow", glow)
	if _frozen:
		return
	_copy()
	var moved := _player.position - _last
	_last = _player.position
	if moved.length() > 0.5:
		_heading = moved.normalized()
	var spot := _player.position - _heading * BEHIND * _tile
	if _strike > 0.0:
		var push := sin(glow * PI) * LUNGE * _tile
		spot += (_target - spot).normalized() * push
	position = position.lerp(spot, clampf(delta * 10.0, 0.0, 1.0))
