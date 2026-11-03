class_name SkyFeathers
extends Node2D

## Les Plumes-lames de l'Archange du Ciel. Cinq plumes d'or partent en éventail et tournent sur
## elles-mêmes en filant par-dessus les haies, chacune suivie de son ombre au sol. Elles ne
## reviennent pas. Le CombatSystem frappe d'après les mêmes temps (`BLADE_OUT`).

const LENGTH := 1.15
const WIDTH := 0.5
## La plume vole au-dessus du sol : son ombre reste dessous, et c'est elle qui dit où elle passe.
const HEIGHT := 0.55
const SPIN := 14.0

var _from := Vector2.ZERO
var _directions: Array = []
var _reach := 0.0
var _tile := 32.0
var _time := 0.0
var _feathers: Array[Sprite2D] = []


func setup(from: Vector2, directions: Array, reach: float, tile_size: int) -> void:
	_from = from
	_directions = directions
	_reach = reach
	_tile = float(tile_size)
	z_index = 11
	# Elles suivent le sol en coordonnées du monde : aucun redressement de la vue 2,5D.
	scale = Vector2.ONE
	for i in directions.size():
		var feather := Sprite2D.new()
		feather.texture = MagicOrb.painted_quad()
		feather.material = PaintedFx.make_material("ciel_plume", float(i) * 0.17)
		feather.scale = Vector2(LENGTH, WIDTH) * _tile
		add_child(feather)
		_feathers.append(feather)
	_place()


func _process(delta: float) -> void:
	_time += delta
	if _time >= CombatSystem.BLADE_OUT + 0.08:
		queue_free()
		return
	_place()
	queue_redraw()


## Même course que la volée du CombatSystem : vite au départ, en ralentissant vers la pointe.
func _reached() -> float:
	var k := minf(_time / CombatSystem.BLADE_OUT, 1.0)
	return 1.0 - pow(1.0 - k, 2.0)


func _place() -> void:
	var eased := _reached()
	# Elles montent en partant et redescendent en arrivant, comme une volée lancée.
	var lift := sin(minf(_time / CombatSystem.BLADE_OUT, 1.0) * PI) * HEIGHT * _tile
	for i in _feathers.size():
		var direction: Vector2 = _directions[i]
		var feather := _feathers[i]
		feather.position = direction * _reach * eased - Vector2(0.0, lift)
		feather.rotation = direction.angle() + sin(_time * SPIN + float(i)) * 0.5
		var end := 1.0 - smoothstep(0.85, 1.0, _time / (CombatSystem.BLADE_OUT + 0.08))
		feather.scale = Vector2(LENGTH, WIDTH) * _tile * (0.6 + 0.4 * minf(_time * 10.0, 1.0)) * end
	position = _from


## L'ombre de chaque plume au sol : c'est elle qui dit qu'elles passent par-dessus les haies.
func _draw() -> void:
	var eased := _reached()
	for direction: Vector2 in _directions:
		var at: Vector2 = direction * _reach * eased
		draw_set_transform(at, 0.0, Vector2(1.0, 0.45))
		draw_circle(Vector2.ZERO, _tile * 0.2, Color(0.02, 0.08, 0.05, 0.4))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
