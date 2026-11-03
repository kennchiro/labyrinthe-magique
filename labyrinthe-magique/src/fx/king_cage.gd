class_name KingCage
extends Node2D

## Une des Mille Cages : elle tombe du ciel, se referme sur sa proie dans un fracas, chauffe jusqu'au
## blanc pendant que le feu monte en elle, puis se resserre et vole en éclats.

signal landed(at: Vector2)

const OPEN := preload("res://assets/characters/braise/pieces/cage_ouverte.png")
const CLOSED := preload("res://assets/characters/braise/pieces/cage_fermee.png")
const CAGE_TILES := 2.05
const COLUMN_TILES := 2.1
## La cage se pose l'une après l'autre, du plus proche au plus loin : un seul bruit n'en serait pas mille.
const FIRST_FALL := 0.1
const FALL_STEP := 0.09
const FALL_TIME := 0.24
const FALL_HEIGHT := 7.0
const LAND_SQUASH := 0.28
const CRUSH_TIME := 0.14
const SHARD_COLOR := Color("#b8862b")

var _enemy: Enemy = null
var _tile := 64.0
var _seconds := 4.0
var _delay := 0.0
var _life := 0.0
var _down := false
var _crushing := 0.0
var _sprite: Sprite2D = null
var _material: ShaderMaterial = null
var _column: Sprite2D = null
var _column_material: ShaderMaterial = null
var _shadow: Sprite2D = null
var _rest := Vector2.ONE


func setup(enemy: Enemy, tile_size: int, seconds: float, delay: float) -> void:
	_enemy = enemy
	_tile = float(tile_size)
	_seconds = seconds
	_delay = delay
	position = enemy.position
	z_index = 11
	_shadow = Sprite2D.new()
	_shadow.texture = SoftTextures.blot()
	_shadow.modulate = Color(0.0, 0.0, 0.0, 0.0)
	_shadow.scale = Vector2.ONE * _tile * 1.4 / float(_shadow.texture.get_width()) * Vector2(1.0, 0.5)
	add_child(_shadow)
	_column_material = PaintedFx.make_material("braise_colonne", float(enemy.get_instance_id() % 97) * 0.01)
	_column = Sprite2D.new()
	_column.texture = MagicOrb.painted_quad()
	_column.material = _column_material
	_column.scale = Vector2.ONE * COLUMN_TILES * _tile
	_column.position = Vector2(0.0, -_tile * 0.72)
	_column.visible = false
	add_child(_column)
	_material = KingArmor.metal_material(0.0)
	_sprite = Sprite2D.new()
	_sprite.texture = OPEN
	_sprite.material = _material
	_sprite.visible = false
	var unit := CAGE_TILES * _tile / float(CLOSED.get_height())
	_rest = Vector2(unit, unit)
	_sprite.scale = _rest
	add_child(_sprite)


func _process(delta: float) -> void:
	_life += delta
	if _crushing > 0.0:
		_play_crush(delta)
		return
	if not _down:
		_play_fall()
		return
	if _enemy == null or not is_instance_valid(_enemy) or _enemy.dead:
		_shatter()
		return
	var since := _life - _delay - FALL_TIME
	_sprite.position = _at_rest() + Vector2(sin(_life * 41.0), 0.0) * _heat() * _tile * 0.03
	var settle := clampf(since / 0.16, 0.0, 1.0)
	_sprite.scale = _rest * Vector2(1.0 + LAND_SQUASH * (1.0 - settle), 1.0 - LAND_SQUASH * (1.0 - settle))
	_material.set_shader_parameter("heat", _heat())
	_material.set_shader_parameter("flash", maxf(0.0, 1.0 - since * 7.0))
	_column_material.set_shader_parameter("progress", _heat())


func _at_rest() -> Vector2:
	return Vector2(0.0, -CAGE_TILES * _tile * 0.42)


func _heat() -> float:
	return clampf((_life - _delay - FALL_TIME) / maxf(0.1, _seconds - _delay - FALL_TIME), 0.0, 1.0)


func _play_fall() -> void:
	if _life < _delay:
		return
	var share := clampf((_life - _delay) / FALL_TIME, 0.0, 1.0)
	_sprite.visible = true
	_sprite.position = _at_rest() + Vector2(0.0, -FALL_HEIGHT * _tile * (1.0 - share * share))
	_shadow.modulate.a = 0.55 * share
	_material.set_shader_parameter("heat", 0.3)
	if share >= 1.0:
		_down = true
		_sprite.texture = CLOSED
		_column.visible = true
		landed.emit(position)


## Le coup final, porté par le `CombatSystem`. Une cage encore en l'air se pose dans le même éclat.
func crush() -> void:
	_crushing = CRUSH_TIME
	_sprite.visible = true
	_sprite.texture = CLOSED
	_sprite.position = _at_rest()


func _play_crush(delta: float) -> void:
	_crushing -= delta
	var share := clampf(1.0 - _crushing / CRUSH_TIME, 0.0, 1.0)
	_sprite.scale = _rest * Vector2(1.0 - 0.42 * share, 1.0 - 0.2 * share)
	_material.set_shader_parameter("heat", 1.0)
	_material.set_shader_parameter("flash", share)
	if _crushing <= 0.0:
		_shatter()


func _shatter() -> void:
	KingCage.scatter(get_parent(), position + _at_rest(), int(_tile))
	queue_free()


## Des éclats de métal chaud qui partent et retombent, pour la cage et pour la fausse armure.
static func scatter(parent: Node, at: Vector2, tile_size: int) -> void:
	var shards := CPUParticles2D.new()
	parent.add_child(shards)
	shards.position = at
	shards.z_index = 11
	shards.amount = 26
	shards.lifetime = 0.8
	shards.one_shot = true
	shards.explosiveness = 1.0
	shards.direction = Vector2.UP
	shards.spread = 180.0
	shards.gravity = Vector2(0.0, float(tile_size) * 9.0)
	shards.initial_velocity_min = float(tile_size) * 2.5
	shards.initial_velocity_max = float(tile_size) * 7.0
	shards.angular_velocity_min = -500.0
	shards.angular_velocity_max = 500.0
	shards.scale_amount_min = float(tile_size) * 0.05
	shards.scale_amount_max = float(tile_size) * 0.13
	shards.color = SHARD_COLOR
	shards.finished.connect(shards.queue_free)
	shards.emitting = true
