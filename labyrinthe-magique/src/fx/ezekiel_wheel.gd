class_name EzekielWheel
extends Node2D

## Une Roue d'Ézéchiel : une roue d'or emboîtée dans une autre, la jante couverte d'yeux, dans un
## anneau de flamme saphir. Elle roule le long du couloir en tournant, au rythme de la vague que
## le CombatSystem fait avancer, et sème des flammèches derrière elle.

const SIZE := 1.25
const SPIN := 9.0
## Le temps qu'elle met à s'éteindre au bout de sa course.
const TAIL := 0.25

var _points := PackedVector2Array()
var _duration := 0.5
var _time := 0.0
var _wheel: Sprite2D = null
var _material: ShaderMaterial = null
var _sparks: CPUParticles2D = null


func setup(points: PackedVector2Array, duration: float, tile_size: int, seed_value: float) -> void:
	_points = points
	_duration = maxf(0.05, duration)
	z_index = 11
	_wheel = Sprite2D.new()
	_wheel.texture = MagicOrb.painted_quad()
	_material = PaintedFx.make_material("cherubin_roue", seed_value)
	_wheel.material = _material
	_wheel.scale = Vector2.ONE * SIZE * float(tile_size)
	_wheel.position = Vector2(0.0, -float(tile_size) * 0.45)
	add_child(_wheel)
	_sparks = CPUParticles2D.new()
	_sparks.amount = 18
	_sparks.lifetime = 0.45
	_sparks.local_coords = false
	_sparks.spread = 180.0
	_sparks.gravity = Vector2(0.0, tile_size * 3.0)
	_sparks.initial_velocity_min = tile_size * 0.6
	_sparks.initial_velocity_max = tile_size * 1.6
	_sparks.scale_amount_min = tile_size * 0.05
	_sparks.scale_amount_max = tile_size * 0.1
	_sparks.color = Color("#6f8fff")
	_sparks.position = Vector2(0.0, -float(tile_size) * 0.1)
	add_child(_sparks)
	_place()


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration + TAIL:
		queue_free()
		return
	if _time >= _duration:
		_sparks.emitting = false
	_wheel.rotation += delta * SPIN * (1.0 if _points.size() < 2 or _points[-1].x >= _points[0].x else -1.0)
	_material.set_shader_parameter("progress", _time / (_duration + TAIL))
	_place()


func _place() -> void:
	if _points.is_empty():
		return
	var k := clampf(_time / _duration, 0.0, 1.0) * float(_points.size() - 1)
	var i := mini(int(k), _points.size() - 2)
	position = _points[0] if _points.size() < 2 else _points[i].lerp(_points[i + 1], k - float(i))
