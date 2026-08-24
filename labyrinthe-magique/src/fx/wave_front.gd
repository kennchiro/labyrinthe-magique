class_name WaveFront
extends Node2D

## La crête d'une vague qui déferle le long d'un couloir.
##
## Elle avance exactement au rythme que le CombatSystem a fixé : le nœud ne
## décide de rien, il rend visible un front qui existe déjà dans les règles.
## C'est ce qui permet à la simulation d'équilibrage de jouer la même vague sans
## instancier une seule particule.
##
## Le front est un QUAD en shader (`assets/shaders/wave.gdshader`) plutôt que
## des traits dessinés. Trois traits empilés donnaient une masse, pas une lame :
## il manquait le PROFIL — le ventre plus profond au centre, la crête d'écume au
## bord d'attaque, le dos qui s'étale derrière. Ça, seul un shader le fait par
## pixel.
##
## Le quad est orienté pour que son axe local +Y suive la course : le shader
## travaille alors en repère de vague (UV.x traverse la lame, UV.y suit sa
## direction) sans jamais avoir à connaître l'orientation réelle.

const SHADER := preload("res://assets/shaders/wave.gdshader")
## Profondeur de la lame, en cases. Elle traîne derrière son bord d'attaque.
const DEPTH_TILES := 2.2
## Temps que met l'écume à retomber une fois le front arrivé.
const SETTLE := 0.35

## Récupéré dans `setup()` et non par `@onready` : le Level appelle `setup()`
## dans la foulée de `add_child()`, et selon le contexte le `_ready` du nœud
## n'a pas encore tourné — la référence était alors nulle et la lame ne se
## dessinait pas du tout, sans qu'aucune erreur ne remonte.
var blade: ColorRect = null

var tile_size: int = 32

var _points: PackedVector2Array = PackedVector2Array()
var _duration := 0.5
var _time := 0.0
var _material: ShaderMaterial = null
var _behind: Array[Vector2] = []


func setup(points: PackedVector2Array, duration: float, p_tile_size: int,
		tint: Color, width_tiles: float) -> void:
	blade = get_node_or_null("Blade")
	if blade == null:
		queue_free()
		return
	_points = points
	_duration = maxf(0.05, duration)
	tile_size = p_tile_size
	if _points.size() > 0:
		position = _points[0]

	var span := tile_size * maxf(0.8, width_tiles) * 2.2
	var depth := tile_size * DEPTH_TILES
	blade.size = Vector2(span, depth)
	# Le quad est centré en largeur, et son bord d'attaque tombe sur l'origine :
	# la case frappée est celle où l'on VOIT l'écume, pas le milieu de la lame.
	blade.position = Vector2(-span * 0.5, -depth)

	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter("deep_color",
		Color(tint.r * 0.25, tint.g * 0.45, tint.b * 0.8, 1.0))
	_material.set_shader_parameter("light_color", tint)
	_material.set_shader_parameter("phase", 0.0)
	_material.set_shader_parameter("fade", 1.0)
	blade.material = _material

	# L'écume vive : elle naît sur la crête et RESTE en arrière, ce qui donne le
	# sillage sans avoir à le simuler.
	var foam := FxTextures.flame_emitter(50, 0.45, float(tile_size) * 0.5,
		Color(1.0, 1.0, 1.0, 0.75), Color(tint.r, tint.g, tint.b, 0.0), 30.0, 180.0)
	add_child(foam)
	foam.local_coords = false
	foam.initial_velocity_min = float(tile_size) * 0.2
	foam.initial_velocity_max = float(tile_size) * 1.2
	foam.emitting = true


func _process(delta: float) -> void:
	_time += delta
	if _points.size() < 2 or _material == null:
		queue_free()
		return
	var progress := clampf(_time / _duration, 0.0, 1.0)
	position = _sample(progress)

	_behind.push_front(position)
	while _behind.size() > 3:
		_behind.pop_back()
	# L'orientation vient du DÉPLACEMENT réel et non de la direction visée :
	# la lame suit ainsi les virages du couloir toute seule.
	if _behind.size() >= 2 and _behind[0] != _behind[1]:
		rotation = (_behind[0] - _behind[1]).angle() - PI * 0.5

	_material.set_shader_parameter("phase", _time * 3.0)
	_material.set_shader_parameter("fade",
		1.0 - clampf((_time - _duration) / SETTLE, 0.0, 1.0))
	if _time > _duration + SETTLE:
		queue_free()


func _sample(t: float) -> Vector2:
	var segments := _points.size() - 1
	var scaled := t * float(segments)
	var index := mini(int(scaled), segments - 1)
	return _points[index].lerp(_points[index + 1], scaled - float(index))
