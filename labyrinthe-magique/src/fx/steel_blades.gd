class_name SteelBlades
extends Node2D

## La volée des Ailes-lames. Le CombatSystem frappe d'après les mêmes temps : les lames s'ouvrent en
## ralentissant, se retournent à la pointe, puis reviennent vers le mage en accélérant.

const STEEL := Color("#dfe6ee")
const MID := Color("#8f9cab")
const HOT := Color("#ff8a2a")
const RIM := Color("#161b22")
const LENGTH := 0.62
const WIDTH := 0.17

var _from := Vector2.ZERO
var _directions: Array = []
var _reach := 0.0
var _tile := 32.0
var _time := 0.0
var _player: Node2D = null


func setup(from: Vector2, directions: Array, reach: float, tile_size: int, player: Node2D) -> void:
	_from = from
	_directions = directions
	_reach = reach
	_tile = float(tile_size)
	_player = player
	z_index = 10
	# Elles suivent le sol en coordonnées du monde : aucun redressement de la vue 2,5D.
	scale = Vector2.ONE


func _process(delta: float) -> void:
	_time += delta
	if _time >= CombatSystem.BLADE_OUT + CombatSystem.BLADE_BACK:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var reached := minf(_time / CombatSystem.BLADE_OUT, 1.0)
	var eased := 1.0 - pow(1.0 - reached, 2.0)
	var back := clampf((_time - CombatSystem.BLADE_OUT) / CombatSystem.BLADE_BACK, 0.0, 1.0)
	var home := _player.position if is_instance_valid(_player) else _from
	for direction: Vector2 in _directions:
		var tip := _from + direction * _reach * eased
		var at := tip.lerp(home, back * back)
		_draw_blade(at, direction.angle() + PI * smoothstep(0.0, 0.3, back))


func _draw_blade(at: Vector2, angle: float) -> void:
	var along := Vector2.from_angle(angle) * _tile * LENGTH * 0.5
	var side := along.orthogonal().normalized() * _tile * WIDTH
	var rim := 1.28
	draw_colored_polygon(_kite(at, along * rim, side * rim), RIM)
	draw_colored_polygon(_kite(at, along, side), HOT)
	draw_colored_polygon(_kite(at - along * 0.05, along * 0.82, side * 0.72), STEEL)
	draw_colored_polygon(PackedVector2Array([at - along * 0.7, at + along * 0.7, at + side * 0.5]), MID)


func _kite(at: Vector2, along: Vector2, side: Vector2) -> PackedVector2Array:
	return PackedVector2Array([at + along, at + side - along * 0.2, at - along, at - side - along * 0.2])
