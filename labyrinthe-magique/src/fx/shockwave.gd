class_name Shockwave
extends Node2D

## L'onde de choc d'un sort lourd : un anneau net qui s'écarte, en shader.
##
## Elle ne remplace pas l'ImpactEffect, elle le COMPLÈTE : les particules disent
## la matière (braises, éclats, gouttes), l'onde dit la PUISSANCE. Un sort lourd
## et un sort léger produisaient jusqu'ici le même éclat en plus gros ; l'onde
## est ce qui distingue « ça a explosé » de « ça a touché ».
##
## Réservée aux compétences qui la demandent (`Ability.shockwave`) — si tout en
## produisait une, elle ne signalerait plus rien.

const SHADER := preload("res://assets/shaders/shockwave.gdshader")

@onready var rect: ColorRect = $Rect

var _life := 0.0
var _duration := 0.45
var _material: ShaderMaterial = null


func setup(tile_size: int, radius_tiles: float, core: Color, edge: Color,
		duration: float = 0.45) -> void:
	_duration = maxf(0.1, duration)
	# Le carré couvre le DIAMÈTRE : le shader travaille en UV, c'est la taille
	# du rectangle qui fixe l'envergure réelle de l'onde.
	var span := tile_size * maxf(0.8, radius_tiles) * 2.2
	rect.size = Vector2(span, span)
	rect.position = -rect.size * 0.5

	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter("core_color", core)
	_material.set_shader_parameter("edge_color", edge)
	_material.set_shader_parameter("progress", 0.0)
	rect.material = _material


func _process(delta: float) -> void:
	_life += delta
	if _material != null:
		_material.set_shader_parameter("progress", clampf(_life / _duration, 0.0, 1.0))
	if _life >= _duration:
		queue_free()
