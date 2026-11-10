class_name KingArmor
extends Node2D

## L'armure volante du Roi de Braise : deux gantelets et un plastron, leurs filets de lave, leurs
## traînées et leurs escarbilles.
##
## Elle ne décide de rien : le `CombatSystem` dit où est chaque pièce, en cases. Ici, on la montre.

const PIECES := "res://assets/characters/braise/pieces/"
const METAL := preload("res://assets/shaders/braise_piece.gdshader")
const LAVA := Color("#ff7a18")
const EMBER := Color("#ff9a1f")
const PALE := Color("#ffd9a0")
const DEEP := Color("#8a2c08")
## Où flottent les pièces autour de lui, en cases : à hauteur d'épaules, et le plastron au-dessus.
const SEATS: Array[Vector2] = [Vector2(-0.92, -0.72), Vector2(0.92, -0.72), Vector2(0.0, -1.85)]
## D'où part le filet : ses épaules et le sommet de sa couronne, jamais à travers son visage.
const ANCHORS: Array[Vector2] = [Vector2(-0.3, -0.34), Vector2(0.3, -0.34), Vector2(0.0, -1.32)]
const GAUNTLET_TILES := 0.62
const CHEST_TILES := 0.62
const BITE_TILES := 1.5
const CHASE := 16.0
const TRAIL_POINTS := 16
const TRAIL_WIDTH := 0.22
const MOVING := 3.0

## L'Empereur des Cendres : pendant l'Éveil, ses pièces chauffent à blanc, fissures rallumées.
var molten := false
var _tile := 64.0
var _player: Node2D = null
var _sprites: Array[Sprite2D] = []
var _embers: Array[CPUParticles2D] = []
var _trails: Array[PackedVector2Array] = []
var _states: Array[int] = []
var _flash: Array[float] = []
var _textures := {}
var _time := 0.0
## `WorldStage` étire ce qui entre dans `Entities`. Ici, cela déplacerait les pièces au lieu de
## les redresser : le nœud reste à l'échelle 1, et chaque pièce porte ce redressement elle-même.
var _stand := -1.0


static func metal_material(heat: float, ash: float = 0.0) -> ShaderMaterial:
	var shaded := ShaderMaterial.new()
	shaded.shader = METAL
	shaded.set_shader_parameter("heat", heat)
	shaded.set_shader_parameter("ash", ash)
	return shaded


func _texture(name_on_disk: String) -> Texture2D:
	if not _textures.has(name_on_disk):
		_textures[name_on_disk] = load(PIECES + name_on_disk + ".png")
	return _textures[name_on_disk]


func _build(count: int) -> void:
	for i in count:
		var sprite := Sprite2D.new()
		sprite.material = metal_material(0.0)
		(sprite.material as ShaderMaterial).set_shader_parameter("seed", float(i) * 0.37)
		sprite.flip_h = i == 0
		add_child(sprite)
		_sprites.append(sprite)
		var embers := CPUParticles2D.new()
		embers.amount = 26
		embers.lifetime = 0.55
		embers.local_coords = false
		embers.direction = Vector2.UP
		embers.spread = 60.0
		embers.gravity = Vector2(0.0, -40.0)
		embers.initial_velocity_min = 18.0
		embers.initial_velocity_max = 70.0
		embers.scale_amount_min = 2.0
		embers.scale_amount_max = 4.5
		embers.color = EMBER
		embers.emitting = false
		sprite.add_child(embers)
		_embers.append(embers)
		_trails.append(PackedVector2Array())
		_states.append(CombatSystem.Piece.ORBIT)
		_flash.append(0.0)


## Les cases sont des positions dans le monde : `origin` est le centre de la case (0, 0).
func show_state(pieces: Array[Dictionary], player: Node2D, origin: Vector2, tile_size: int) -> void:
	_tile = float(tile_size)
	_player = player
	if _stand < 0.0:
		_stand = scale.y
		scale = Vector2.ONE
	if _sprites.is_empty():
		_build(pieces.size())
	var delta := get_process_delta_time()
	_time += delta
	for i in pieces.size():
		_show_piece(i, pieces[i], origin, delta)
	queue_redraw()


func _show_piece(i: int, piece: Dictionary, origin: Vector2, delta: float) -> void:
	var sprite := _sprites[i]
	var state: int = piece["state"]
	var target: Vector2
	if state == CombatSystem.Piece.ORBIT:
		var sway := Vector2(sin(_time * 1.3 + float(i) * 2.1) * 0.12, sin(_time * 2.1 + float(i)) * 0.1)
		target = _player.position + (SEATS[i] + sway) * _tile
	else:
		target = origin + (piece["pos"] as Vector2) * _tile
		if state in [CombatSystem.Piece.HUNT, CombatSystem.Piece.RECALL, CombatSystem.Piece.RETURN]:
			target.y -= _tile * 0.7
	if state != _states[i]:
		_flash[i] = 1.0
		_states[i] = state
	_flash[i] = maxf(0.0, _flash[i] - delta * 5.0)
	var before := sprite.position
	sprite.position = before.lerp(target, minf(1.0, delta * CHASE))
	var speed := before.distance_to(sprite.position) / maxf(delta, 0.001) / _tile
	var flying := speed > MOVING
	_embers[i].emitting = flying or state == CombatSystem.Piece.BITE
	_grow_trail(i, sprite.position, flying)
	_dress(sprite, i, state, target - before)


func _dress(sprite: Sprite2D, i: int, state: int, heading: Vector2) -> void:
	var is_chest := i == CombatSystem.CHEST_PIECE
	var look := "plastron" if is_chest else "gant_ouvert"
	var tiles := CHEST_TILES if is_chest else GAUNTLET_TILES
	var heat := 0.0
	var turn := 0.0
	if state == CombatSystem.Piece.BITE:
		look = "plastron_ouvert"
		tiles = BITE_TILES * (1.0 + 0.06 * sin(_time * 16.0))
		heat = 0.5
	elif state == CombatSystem.Piece.POSED:
		tiles = CHEST_TILES * 1.2
		heat = 0.3 + 0.2 * sin(_time * 6.0)
	elif state in [CombatSystem.Piece.HUNT, CombatSystem.Piece.RECALL, CombatSystem.Piece.RETURN] and not is_chest:
		look = "gant_ferme"
		tiles = GAUNTLET_TILES * 1.15
		heat = 0.35
		turn = heading.angle() + PI / 4.0
	elif state == CombatSystem.Piece.RECALL:
		heat = 0.45
	elif state != CombatSystem.Piece.ORBIT:
		heat = 0.2
	sprite.texture = _texture(look)
	sprite.rotation = turn
	sprite.flip_h = i == 0 and turn == 0.0
	var unit := tiles * _tile / float(sprite.texture.get_height())
	sprite.scale = Vector2(unit, unit * _stand)
	if molten:
		heat = maxf(heat, 0.6 + 0.15 * sin(_time * 4.0 + float(i)))
	var shaded := sprite.material as ShaderMaterial
	shaded.set_shader_parameter("heat", heat)
	shaded.set_shader_parameter("flash", _flash[i])


func _grow_trail(i: int, at: Vector2, flying: bool) -> void:
	var trail := _trails[i]
	if flying:
		trail.append(at)
	elif not trail.is_empty():
		trail.remove_at(0)
	while trail.size() > TRAIL_POINTS:
		trail.remove_at(0)
	_trails[i] = trail


func _draw() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	for i in _sprites.size():
		_draw_trail(_trails[i])
		_draw_tether(_sprites[i].position, _states[i], ANCHORS[i])


## La traînée : une langue de feu qui s'élargit vers la pièce, cernée de sombre.
func _draw_trail(trail: PackedVector2Array) -> void:
	for pass_index in 3:
		var color: Color = [DEEP, EMBER, PALE][pass_index]
		var width: float = [1.0, 0.62, 0.26][pass_index] * TRAIL_WIDTH * _tile
		for s in trail.size() - 1:
			var share := float(s + 1) / float(trail.size())
			draw_line(trail[s], trail[s + 1], color, maxf(1.0, width * share))


## Le filet de lave qui le relie à sa pièce. Il frémit en orbite, et se tend quand elle revient.
func _draw_tether(at: Vector2, state: int, anchor: Vector2) -> void:
	var from: Vector2 = _player.position + anchor * _tile
	var pulled := state == CombatSystem.Piece.RECALL
	if not pulled and state != CombatSystem.Piece.ORBIT:
		return
	var line := PackedVector2Array()
	var side := (at - from).orthogonal().normalized()
	var ripple := 0.05 if pulled else 0.14
	for s in 11:
		var share := float(s) / 10.0
		var wave := sin(share * 9.0 - _time * 9.0 + at.x * 0.01) * sin(share * PI) * ripple * _tile
		line.append(from.lerp(at, share) + side * wave)
	var width := _tile * (0.09 if pulled else 0.045)
	draw_polyline(line, DEEP, width * 2.0)
	draw_polyline(line, LAVA, width)
	draw_polyline(line, PALE, width * 0.4)
