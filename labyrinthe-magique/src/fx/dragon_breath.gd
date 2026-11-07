class_name DragonBreath
extends Node2D

## Le Souffle du Dragon : un torrent de flamme d'or et blanche jaillit de sa gueule en cône, s'élargit
## jusqu'au bout de sa portée, puis laisse le sol en fusion — des flaques d'or qui bouillonnent.

const BLOW := 1.0
const POOLS := 3.0
const RIM := Color("#3a2408")

var _dir := Vector2.RIGHT
var _reach := 160.0
var _spread := 0.6
var _life := 0.0
var _pools: Array[Vector2] = []


## `spread` : la demi-ouverture du cône, en radians.
func setup(direction: Vector2, reach: float, spread: float) -> void:
	_dir = direction.normalized() if direction != Vector2.ZERO else Vector2.DOWN
	_reach = reach
	_spread = spread
	z_index = 11
	var rng := RandomNumberGenerator.new()
	rng.seed = 3313
	for i in 7:
		var a := rng.randf_range(-_spread * 0.8, _spread * 0.8)
		_pools.append(_dir.rotated(a) * _reach * rng.randf_range(0.3, 0.9))


func _process(delta: float) -> void:
	_life += delta
	if _life >= BLOW + POOLS:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	# Les flaques d'or en fusion, qui restent après le souffle.
	var pool := clampf(_life / BLOW, 0.0, 1.0) * (1.0 - clampf((_life - BLOW - POOLS + 0.6) / 0.6, 0.0, 1.0))
	for i in _pools.size():
		# Des flaques couchées sur le sol, plates et sombres au bord, qui bouillonnent au centre.
		var r := _reach * 0.07 * (1.0 + 0.12 * sin(_life * 6.0 + float(i)))
		draw_set_transform(_pools[i], 0.0, Vector2(1.0, 0.45))
		draw_circle(Vector2.ZERO, r * 1.4 * pool, Color(RIM, 0.45 * pool))
		draw_circle(Vector2.ZERO, r * pool, Color("#ffb347", 0.7 * pool))
		draw_circle(Vector2(-r * 0.2, 0.0), r * 0.45 * pool, Color(1.0, 0.95, 0.7, 0.8 * pool))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _life >= BLOW:
		return
	# Le torrent : des langues de flamme qui s'allongent en éventail, plus claires au cœur.
	var k := _life / BLOW
	var grow := 1.0 - pow(1.0 - minf(1.0, k * 3.0), 3.0)
	var fade := 1.0 - smoothstep(0.75, 1.0, k)
	draw_circle(Vector2.ZERO, _reach * 0.25 * grow, Color(1.0, 0.95, 0.7, 0.5 * fade))
	for layer: Array in [[1.0, Color("#ffb347", 0.55)], [0.75, Color("#f2c94c", 0.8)], [0.45, Color("#fff4c8", 0.9)]]:
		var share: float = layer[0]
		var colour: Color = layer[1]
		var points := PackedVector2Array([Vector2.ZERO])
		for s in 13:
			var a := lerpf(-_spread, _spread, float(s) / 12.0) * share
			var lick := 1.0 + 0.12 * sin(_life * 40.0 + float(s) * 1.7)
			points.append(_dir.rotated(a) * _reach * grow * lick * (0.75 + 0.25 * share))
		draw_colored_polygon(points, Color(colour, colour.a * fade))
	# Les étincelles qui s'échappent du torrent.
	for i in 12:
		var t := fmod(k * 2.0 + float(i) * 0.083, 1.0)
		var a := sin(float(i) * 2.3) * _spread
		draw_circle(_dir.rotated(a) * _reach * grow * t, 2.0, Color(1.0, 1.0, 0.9, fade * (1.0 - t)))
