class_name PrismLink
extends Node2D

## L'Onde prismatique de l'Ascendant : la lumière saute d'un ennemi à l'autre en traits DROITS, comme
## réfractée par un prisme, avec un nœud d'or à chaque cible. La Foudre relie en zigzag ; ici, la
## lumière va droit et se brise en angle net à mi-chemin.

const LIFE := 0.32
const RIM := Color("#16202b")
const GOLD := Color("#e0b84a")

var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _colour := Color.WHITE
var _width := 4.0
var _life := 0.0
var _bend := Vector2.ZERO


func setup(from: Vector2, to: Vector2, tile_size: int, colour: Color) -> void:
	_from = from
	_to = to
	_colour = colour
	_width = float(tile_size) * 0.14
	# Le coude de la réfraction : à mi-chemin, un peu de côté, toujours du même côté du trait.
	_bend = from.lerp(to, 0.5) + (to - from).orthogonal().normalized() * float(tile_size) * 0.35
	z_index = 12


func _process(delta: float) -> void:
	_life += delta
	if _life >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := _life / LIFE
	var alpha := 1.0 - k * k
	var reach := minf(1.0, k * 4.0)
	var path := PackedVector2Array([_from, _bend, _to])
	if reach < 1.0:
		path = PackedVector2Array([_from, _from.lerp(_bend, minf(1.0, reach * 2.0))])
		if reach > 0.5:
			path.append(_bend.lerp(_to, (reach - 0.5) * 2.0))
	draw_polyline(path, Color(_colour, 0.25 * alpha), _width * 3.0, true)
	draw_polyline(path, Color(RIM, 0.5 * alpha), _width + 2.0, true)
	draw_polyline(path, Color(_colour, alpha), _width, true)
	draw_polyline(path, Color(1.0, 1.0, 1.0, alpha), _width * 0.35, true)
	# Le prisme au coude, et le nœud d'or sur la cible.
	var p := _width * 2.2
	draw_colored_polygon(PackedVector2Array([_bend + Vector2(0, -p), _bend + Vector2(p * 0.8, p * 0.6),
		_bend + Vector2(-p * 0.8, p * 0.6)]), Color(1.0, 1.0, 1.0, 0.8 * alpha))
	if reach >= 1.0:
		draw_circle(_to, _width * 2.5 * (1.0 + k), Color(GOLD, 0.5 * alpha))
		draw_circle(_to, _width * 1.2, Color(1.0, 1.0, 1.0, alpha))
