class_name BladeDash
extends Node2D

## Le trait du Pas de Lame : une ligne blanche d'un bout à l'autre du couloir, bordée de rouge, qui
## s'amincit et se referme du départ vers l'arrivée. Quelques pétales restent derrière lui.

const WHITE := Color("#fff6ee")
const RED := Color("#b81414")
const BLACK := Color("#17171a")
const WIDTH := 0.3
const PETALS := 16

var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _tile := 64.0
var _time := 0.0
var _duration := 0.36
var _core := WHITE
var _rim := RED
var _edge := BLACK


## `from` et `to` sont des positions du monde : le nœud reste à l'échelle 1, à la racine.
func setup(from: Vector2, to: Vector2, tile_size: int, duration: float) -> void:
	scale = Vector2.ONE
	_from = from
	_to = to
	_tile = float(tile_size)
	_duration = duration
	z_index = 11
	var petals := CPUParticles2D.new()
	add_child(petals)
	petals.position = (from + to) * 0.5
	petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	var half := (to - from).abs() * 0.5 + Vector2.ONE
	petals.emission_rect_extents = half
	petals.amount = PETALS
	petals.lifetime = 0.8
	petals.one_shot = true
	petals.explosiveness = 0.9
	petals.gravity = Vector2(0.0, _tile * 1.5)
	petals.initial_velocity_min = _tile * 0.3
	petals.initial_velocity_max = _tile * 1.4
	petals.spread = 180.0
	petals.scale_amount_min = _tile * 0.04
	petals.scale_amount_max = _tile * 0.08
	petals.color = WHITE
	petals.emitting = true


## Les trois tons du trait, du cœur au cerne : le Geôlier le prend en flamme froide.
func tint(core: Color, rim: Color, edge: Color) -> void:
	_core = core
	_rim = rim
	_edge = edge
	for child in get_children():
		if child is CPUParticles2D:
			(child as CPUParticles2D).color = rim


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration + 0.8:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var share := clampf(_time / _duration, 0.0, 1.0)
	if share >= 1.0:
		return
	var tail := _from.lerp(_to, smoothstep(0.2, 1.0, share))
	var width := WIDTH * _tile * (1.0 - share)
	draw_line(tail, _to, _edge, width * 1.3 + 2.0)
	draw_line(tail, _to, _rim, width + 1.0)
	draw_line(tail, _to, _core, width * 0.55)
