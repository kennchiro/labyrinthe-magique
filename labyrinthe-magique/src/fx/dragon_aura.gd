class_name DragonAura
extends Node2D

## L'aura du Dragon d'or, tant qu'il garde la forme : deux ailes de lumière à demi repliées dans son dos,
## qui respirent, et des braises d'or qui montent de ses épaules. Ce ne sont pas les cristaux en orbite
## du Prisme : ce sont des ailes et du feu.

const RIM := Color("#3a2408")
const GOLD := Color("#f2c94c")

var tile_size := 32.0
var _time := 0.0


func _ready() -> void:
	z_index = -1


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var t := tile_size
	var breathe := 0.5 + 0.5 * sin(_time * 2.4)
	var root := Vector2(0.0, -t * 1.0)
	for side: float in [-1.0, 1.0]:
		# Une aile : trois baleines et la membrane entre elles, légèrement ouvertes au rythme du souffle.
		var spread := 0.55 + 0.15 * breathe
		var tips: Array[Vector2] = []
		for f in 3:
			var angle := -PI * 0.5 + side * (0.4 + spread * float(f) * 0.6)
			tips.append(root + Vector2.from_angle(angle) * t * (1.5 - 0.25 * float(f)))
		var membrane := PackedVector2Array([root, tips[0], tips[1], tips[2], root + Vector2(side * t * 0.4, t * 0.4)])
		draw_colored_polygon(membrane, Color(GOLD, 0.22 + 0.08 * breathe))
		for tip in tips:
			draw_line(root, tip, Color(1.0, 0.95, 0.75, 0.55 + 0.2 * breathe), 2.0)
	# Les braises qui montent.
	for i in 8:
		var phase := fmod(_time * 0.7 + float(i) * 0.125, 1.0)
		var at := Vector2(sin(float(i) * 2.1) * t * 0.5, -t * 0.6 - phase * t * 1.4)
		draw_circle(at, 1.8 * (1.0 - phase), Color("#ffb347", 0.9 * (1.0 - phase)))
