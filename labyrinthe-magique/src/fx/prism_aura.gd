class_name PrismAura
extends Node2D

## Cristaux en orbite : dessinés à chaque frame, jamais collés à la planche.
var tile_size := 32.0
var _time := 0.0
func _process(delta: float) -> void:
	_time += delta
	queue_redraw()
func _draw() -> void:
	var center := Vector2(0, -tile_size * 0.85)
	for i in 5:
		var angle := _time * 1.5 + TAU * float(i) / 5.0
		var at := center + Vector2(cos(angle) * tile_size * 0.8, sin(angle) * tile_size * 0.45)
		var points := PackedVector2Array([at + Vector2(0,-7), at + Vector2(4,0), at + Vector2(0,7), at + Vector2(-4,0)])
		draw_colored_polygon(points, Color("#c9f5ff"))
		draw_polyline(PackedVector2Array([points[0],points[1],points[2],points[3],points[0]]), Color("#e3be60"), 1.0, true)
	draw_arc(center, tile_size * (0.8 + sin(_time * 4.0) * 0.04), 0.0, TAU, 40, Color(0.8,0.95,1.0,0.25), 1.2, true)
