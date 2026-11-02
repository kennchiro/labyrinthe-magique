class_name SteelCracks
extends Node2D

## L'onde d'enclume dans les couloirs : les fissures gagnent de proche en proche, à la vitesse des
## dégâts, puis refroidissent de l'orange au gris. Tracées et non peintes : une par case serait
## bien trop de quads pour un iPhone.

const HOT := Color("#ff8a2a")
const COLD := Color("#3a4450")
const RIM := Color("#161b22")
const COOL_START := 0.35
const LIFE := 1.1

var _links: Array = []
var _time := 0.0
var _tile := 32.0
var _speed := CombatSystem.ANVIL_SPEED


## `links` : {"from": monde, "to": monde, "steps": cases depuis le coup}. `speed` en cases par seconde.
func setup(links: Array, tile_size: int, speed: float = CombatSystem.ANVIL_SPEED) -> void:
	_links = links
	_speed = speed
	_tile = float(tile_size)
	z_index = 4
	# Elles suivent le sol en coordonnées du monde : aucun redressement de la vue 2,5D.
	scale = Vector2.ONE


func _process(delta: float) -> void:
	_time += delta
	if _time >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var front := _time * _speed
	var points := PackedVector2Array()
	for link: Dictionary in _links:
		if float(link["steps"]) > front:
			continue
		var from: Vector2 = link["from"]
		var to: Vector2 = link["to"]
		var bend := (to - from).orthogonal().normalized() * _tile * 0.16 \
			* sin(float(link["steps"]) * 2.7 + from.x * 0.13)
		var middle := from.lerp(to, 0.5) + bend
		points.append_array(PackedVector2Array([from, middle, middle, to]))
	if points.is_empty():
		return
	var fade := 1.0 - smoothstep(0.7, 1.0, _time / LIFE)
	var heat := HOT.lerp(COLD, smoothstep(COOL_START, LIFE * 0.8, _time))
	draw_multiline(points, Color(RIM, fade), _tile * 0.16)
	draw_multiline(points, Color(heat, fade), _tile * 0.08)
