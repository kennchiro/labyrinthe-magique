class_name SoulOrbit
extends Node2D

## Les âmes récoltées qui tournent lentement autour de l'Ange de la Mort, une par âme.

const TURN_SPEED := 1.4

var _tile := 32.0
var _count := 0
var _clock := 0.0


func setup(tile_size: int) -> void:
	_tile = float(tile_size)
	z_index = 2
	position = Vector2(0.0, -_tile * 0.5)


func set_count(count: int) -> void:
	_count = count
	queue_redraw()


func _process(delta: float) -> void:
	if _count > 0:
		_clock += delta
		queue_redraw()


func _draw() -> void:
	for i in _count:
		var angle := _clock * TURN_SPEED + TAU * float(i) / float(_count)
		var at := Vector2(cos(angle) * _tile * 0.72, sin(angle) * _tile * 0.3)
		SoulWisp.draw_flame(self, at, _tile * 0.2, 1.0, _clock * 9.0 + float(i))
