class_name PlatePips
extends Node2D

## Les plaques de l'Archange d'Acier au-dessus de sa tête : pleines, ou creuses une fois arrachées.

const STEEL := Color("#dfe6ee")
const HOT := Color("#ff8a2a")
const EMPTY := Color("#3a4450")
const RIM := Color("#161b22")
const SIDE := 0.13
const GAP := 0.32

var _tile := 32.0
var _maximum := 3
var _count := 0


func setup(tile_size: int, maximum: int) -> void:
	_tile = float(tile_size)
	_maximum = maximum
	z_index = 3
	position = Vector2(0.0, -_tile * 1.25)


func set_count(count: int) -> void:
	_count = count
	queue_redraw()


func _draw() -> void:
	var side := _tile * SIDE
	for i in _maximum:
		var at := Vector2((float(i) - float(_maximum - 1) * 0.5) * _tile * GAP, 0.0)
		draw_colored_polygon(_plate(at, side * 1.3), RIM)
		if i < _count:
			draw_colored_polygon(_plate(at, side), HOT)
			draw_colored_polygon(_plate(at, side * 0.72), STEEL)
		else:
			draw_colored_polygon(_plate(at, side), EMPTY)


func _plate(at: Vector2, side: float) -> PackedVector2Array:
	return PackedVector2Array([at + Vector2(-side, -side), at + Vector2(side, -side),
		at + Vector2(side, side * 0.35), at + Vector2(0.0, side * 1.25), at + Vector2(-side, side * 0.35)])
