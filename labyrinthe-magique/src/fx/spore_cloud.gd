class_name SporeCloud
extends ColorRect

## Le nuage sur une case. La règle vit dans `SporeClouds`, ceci ne fait que la montrer.
##
## Enfant du Level et non d'Entities, comme `MoveMarker` : il reste couché sur le sol en
## 2,5D, là où les personnages sont redressés.

const SHADER: Shader = preload("res://assets/shaders/spore_cloud.gdshader")
const FADE_TIME := 0.5
## Plus large que la case : les nuages voisins se fondent en une seule nappe.
const SPREAD := 1.7

var _left := 0.0
var _paint: ShaderMaterial = null


func setup(at: Vector2, tile_size: int, duration: float, seed_value: float) -> void:
	_left = duration
	size = Vector2.ONE * float(tile_size) * SPREAD
	position = at - size * 0.5
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_paint = ShaderMaterial.new()
	_paint.shader = SHADER
	_paint.set_shader_parameter("seed", seed_value)
	_paint.set_shader_parameter("fade", 0.0)
	material = _paint


func _process(delta: float) -> void:
	_left -= delta
	if _left <= 0.0:
		queue_free()
		return
	_paint.set_shader_parameter("fade", minf(1.0, _left / FADE_TIME))
