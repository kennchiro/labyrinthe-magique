class_name EchoGhost
extends Node2D

## Le double de l'Écho : le mage lui-même, translucide, qui rejoue sa marche récente.
##
## Il n'a aucune règle : c'est le CombatSystem qui frappe, à la même allure. Ce nœud lit les
## instants que le sort lui donne pour rester sur la case où le coup se décide.

const TINT := Color(0.45, 1.0, 0.92, 0.62)
const WALK_FPS := 11.0
const FADE := 0.2
## Plus loin qu'une case et demie, c'est un portail qu'il a pris : il saute, il ne glisse pas.
const JUMP_TILES := 1.5

var _points := PackedVector2Array()
var _times: Array = []
var _textures := {}
var _walk: Array[int] = []
var _tile := 32.0
var _time := 0.0
var _sprite: Sprite2D


func setup(points: PackedVector2Array, times: Array, textures: Dictionary, walk: Array[int],
		poses: int, sprite_scale: Vector2, sprite_offset: Vector2, tile_size: int) -> void:
	_points = points
	_times = times
	_textures = textures
	_walk = walk
	_tile = float(tile_size)
	z_index = 9
	_sprite = Sprite2D.new()
	_sprite.hframes = maxi(1, poses)
	_sprite.scale = sprite_scale
	_sprite.offset = sprite_offset
	_sprite.modulate = TINT
	add_child(_sprite)
	_place(0.0)


func _process(delta: float) -> void:
	_time += delta
	var end := float(_times[-1])
	if _time >= end:
		queue_free()
		return
	_place(_time)
	modulate.a = minf(1.0, minf(_time, end - _time) / FADE)


func _place(at: float) -> void:
	var index := 0
	while index + 1 < _times.size() and float(_times[index + 1]) <= at:
		index += 1
	var here := _points[index]
	if index + 1 >= _points.size():
		position = here
		return
	var next := _points[index + 1]
	var span := maxf(0.001, float(_times[index + 1]) - float(_times[index]))
	var jumped := here.distance_to(next) > _tile * JUMP_TILES
	position = here if jumped else here.lerp(next, clampf((at - float(_times[index])) / span, 0.0, 1.0))
	if jumped:
		return
	var way := next - here
	var key := "down"
	if absf(way.x) > absf(way.y):
		key = "right" if way.x > 0.0 else "left"
	elif way.y < 0.0:
		key = "up"
	_sprite.texture = _textures.get(key)
	if not _walk.is_empty():
		_sprite.frame = _walk[int(at * WALK_FPS) % _walk.size()]
