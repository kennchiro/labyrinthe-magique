class_name CrystalSentinel
extends Node2D

## Le Cristal sentinelle de l'Ascendant : un obélisque de cristal bleu jaillit du sol, cerclé d'un
## anneau d'or qui tourne. Il s'allume à chaque tir, et s'enfonce quand le sort finit. La Terre plante
## une colonne de roche ; ici, une sentinelle taillée et lumineuse.

const RISE := 0.25
const SINK := 0.3
const RIM := Color("#16202b")
const GOLD := Color("#e0b84a")

var _tile := 32.0
var _colour := Color.WHITE
var _life := 0.0
var _flash := 0.0
var _sinking := -1.0
## Son tir : un trait de lumière bleue, net, du sommet de l'obélisque à sa cible.
var _shot := Vector2.ZERO
var _shot_left := 0.0
const SHOT := 0.14


func setup(tile_size: int, colour: Color) -> void:
	_tile = float(tile_size)
	_colour = colour
	z_index = 10


## Il tire sur `target`, en coordonnées de son parent : l'obélisque s'illumine et le trait part.
func fire(target: Vector2) -> void:
	_flash = 1.0
	_shot = target - position
	_shot_left = SHOT


func fade() -> void:
	if _sinking < 0.0:
		_sinking = 0.0


func _process(delta: float) -> void:
	_life += delta
	_flash = maxf(0.0, _flash - delta * 4.0)
	_shot_left = maxf(0.0, _shot_left - delta)
	if _sinking >= 0.0:
		_sinking += delta
		if _sinking >= SINK:
			queue_free()
			return
	queue_redraw()


func _draw() -> void:
	var rise := minf(1.0, _life / RISE)
	var sink := clampf(_sinking / SINK, 0.0, 1.0) if _sinking >= 0.0 else 0.0
	var height := _tile * 1.25 * (1.0 - pow(1.0 - rise, 3.0)) * (1.0 - sink)
	var half := _tile * 0.24
	var bob := sin(_life * 3.0) * 2.0
	var top := Vector2(0.0, -height + bob)
	# L'anneau d'or au sol, qui tourne, et sa lueur.
	draw_circle(Vector2.ZERO, _tile * 0.55, Color(_colour, 0.12 + 0.3 * _flash))
	for i in 3:
		var a := _life * 2.0 + TAU * float(i) / 3.0
		draw_arc(Vector2.ZERO, _tile * 0.5, a, a + 1.4, 10, Color(GOLD, 0.85 * (1.0 - sink)), 2.5, true)
	if height <= 1.0:
		return
	var body := PackedVector2Array([top, Vector2(half, -height * 0.35 + bob), Vector2(half * 0.7, bob),
		Vector2(-half * 0.7, bob), Vector2(-half, -height * 0.35 + bob)])
	var rim := PackedVector2Array()
	for p in body:
		rim.append(p * 1.12 + Vector2(0.0, -1.0))
	draw_colored_polygon(rim, RIM)
	draw_colored_polygon(body, _colour.lerp(Color.WHITE, 0.45 * _flash))
	# La face éclairée et l'arête centrale.
	draw_colored_polygon(PackedVector2Array([top, Vector2(half, -height * 0.35 + bob), Vector2(0.0, bob)]),
		Color(1.0, 1.0, 1.0, 0.35 + 0.4 * _flash))
	draw_line(top, Vector2(0.0, bob), Color(1.0, 1.0, 1.0, 0.8), 1.5)
	# Le cœur d'or, qui bat plus vite quand il tire.
	draw_circle(Vector2(0.0, -height * 0.45 + bob), _tile * (0.09 + 0.05 * _flash), GOLD)
	if _flash > 0.0:
		draw_circle(top, _tile * 0.35 * _flash, Color(1.0, 1.0, 1.0, 0.7 * _flash))
	if _shot_left > 0.0:
		var k := _shot_left / SHOT
		draw_line(top, _shot, Color(_colour, 0.5 * k), _tile * 0.22 * k)
		draw_line(top, _shot, Color(1.0, 1.0, 1.0, k), _tile * 0.07)
		draw_circle(_shot, _tile * 0.3 * k, Color(GOLD, 0.6 * k))
