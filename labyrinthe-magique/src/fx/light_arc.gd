class_name LightArc
extends Node2D

## Le trajet de l'Envol : un arc de lumière par-dessus les haies, d'où retombent des plumes.

const GOLD := Color("#ffcf5a")
const LIGHT := Color("#fff1b8")
const RIM := Color("#4a2f12")
const POINTS := 18
const FEATHERS := 7
const LIFE := 0.55
const HEIGHT_TILES := 1.6

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


## Il se bombe de côté : sur un trajet vertical, monter en l'air n'écarterait rien du tout.
func _at(t: float) -> Vector2:
	var side := (_to - _from).orthogonal().normalized()
	if side.y > 0.0:
		side = -side
	return _from.lerp(_to, t) + side * sin(t * PI) * HEIGHT_TILES * _tile


func _draw() -> void:
	var life := _time / LIFE
	var fade := 1.0 - smoothstep(0.55, 1.0, life)
	var head := clampf(life / 0.4, 0.0, 1.0)
	var line := PackedVector2Array()
	for i in POINTS + 1:
		line.append(_at(float(i) / float(POINTS) * head))
	draw_polyline(line, Color(RIM, fade), _tile * 0.1, true)
	draw_polyline(line, Color(GOLD, fade), _tile * 0.075, true)
	draw_polyline(line, Color(LIGHT, fade), _tile * 0.035, true)
	for i in FEATHERS:
		var t := (float(i) + 0.5) / float(FEATHERS) * head
		var drop := life * _tile * 0.8
		var at := _at(t) + Vector2(sin(life * 8.0 + float(i)) * _tile * 0.1, drop)
		var angle := sin(life * 5.0 + float(i) * 2.0) * 0.8
		var along := Vector2.from_angle(angle + PI * 0.5) * _tile * 0.1
		var side := along.orthogonal() * 0.32
		var feather := PackedVector2Array([at - along, at + side, at + along, at - side])
		draw_colored_polygon(feather, Color(LIGHT, fade))
		feather.append(feather[0])
		draw_polyline(feather, Color(RIM, fade), 1.0)
