class_name DeathPassage
extends Node2D

## Le trajet du Passage : une nuée de plumes noires file du départ à l'arrivée, à travers les
## haies, sur un filet de fumée, avec des braises. Des plumes et rien de rond : il n'est plus qu'elles.

const BLACK := Color("#14131c")
const BONE := Color("#e6dfca")
const EMBER := Color("#ff6a2b")
const LIFE := 0.6
const FEATHERS := 18
const EMBERS := 8

var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _tile := 32.0
var _time := 0.0


func setup(from: Vector2, to: Vector2, tile_size: int) -> void:
	_from = from
	_to = to
	_tile = float(tile_size)
	z_index = 11
	# Le trajet suit le sol en coordonnées du monde : aucun redressement de la vue 2,5D.
	scale = Vector2.ONE


func _process(delta: float) -> void:
	_time += delta
	if _time >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var life := _time / LIFE
	var side := (_to - _from).orthogonal().normalized()
	var fade := 1.0 - smoothstep(0.45, 1.0, life)
	var head := clampf(life / 0.35, 0.0, 1.0)
	var smoke := PackedVector2Array([_from, _from.lerp(_to, head)])
	draw_polyline(smoke, Color(BLACK, fade * 0.55), _tile * 0.34, true)
	draw_polyline(smoke, Color(BONE, fade * 0.35), _tile * 0.03, true)
	for i in EMBERS:
		var t := (float(i) + 0.5) / float(EMBERS) * head
		var at := _from.lerp(_to, t) + side * sin(float(i) * 2.4) * _tile * 0.22 + Vector2(0.0, -life * _tile * 0.3)
		draw_circle(at, _tile * 0.035, Color(EMBER, fade))
	for i in FEATHERS:
		var t := (float(i) + 0.5) / float(FEATHERS) * head
		var drift := Vector2(sin(life * 7.0 + float(i)) * _tile * 0.14, -life * _tile * (0.5 + 0.4 * sin(float(i) * 1.3)))
		var at := _from.lerp(_to, t) + side * cos(float(i) * 1.9) * _tile * 0.32 + drift
		var along := Vector2.from_angle(sin(life * 5.0 + float(i) * 2.0) * 1.4 + float(i)) * _tile * 0.2
		var across := along.orthogonal() * 0.28
		var feather := PackedVector2Array([at - along, at + across, at + along, at - across])
		draw_colored_polygon(feather, Color(BLACK, fade))
		feather.append(feather[0])
		draw_polyline(feather, Color(BONE, fade), 1.0, true)
		draw_line(at - along, at + along * 0.7, Color(BONE, fade * 0.8), 1.0, true)
