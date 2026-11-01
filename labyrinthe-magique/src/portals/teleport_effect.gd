class_name TeleportEffect
extends Node2D

## Éclat joué au départ et à l'arrivée d'une téléportation. Se libère tout seul.
## Peint au shader, comme les portails : une onde de lumière, pas un décalcomanie.

const SHADER := preload("res://assets/shaders/teleport_burst.gdshader")
const DURATION := 0.45

@onready var sprite: Sprite2D = $Sprite2D

var tile_size: int = 32

var _life := 0.0
var _paint: ShaderMaterial


## Le matériau est aussi demandé par le Level, qui compile le shader avec le niveau :
## sinon le premier saut de la partie saccaderait.
static func make_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SHADER
	return material


## `size_tiles` : envergure de l'éclat, en cases. 1,7 pour une téléportation ;
## une explosion passe son propre rayon, sinon un sort de 6 cases de portée
## produirait le même petit flash qu'un saut de portail.
func setup(p_tile_size: int, p_color: Color, size_tiles: float = 1.7) -> void:
	tile_size = p_tile_size
	# Couché sur le sol, comme le portail : la vue 2,5D vient de le redresser.
	scale = Vector2.ONE
	_paint = make_material()
	_paint.set_shader_parameter("tint", p_color)
	_paint.set_shader_parameter("seed", fmod(absf(position.x + position.y), TAU))
	sprite.texture = MagicOrb.painted_quad()
	sprite.material = _paint
	sprite.scale = Vector2.ONE * float(tile_size) * size_tiles * 2.0


func _process(delta: float) -> void:
	_life += delta
	if _life >= DURATION:
		queue_free()
		return
	if _paint != null:
		_paint.set_shader_parameter("progress", _life / DURATION)
