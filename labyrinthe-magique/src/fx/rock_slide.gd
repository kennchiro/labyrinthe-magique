class_name RockSlide
extends Node2D

## UN PAN QUI CÈDE : des blocs tombent, la poussière monte, et la roche reste
## fichée dans le sol.
##
## L'éboulement se lit en trois temps, et les trois sont nécessaires. Les blocs
## qui TOMBENT disent d'où vient le coup (du haut, donc du plafond du couloir) ;
## la poussière qui MONTE dit qu'ils ont heurté ; les gerbes qui restent disent
## où l'on ne peut plus passer sans se faire mordre. Sans le premier temps, des
## pierres apparaîtraient au sol sans raison.

const FALL := 0.26
const BLOCKS := 3

var tile_size: int = 32

var _life := 0.0
var _blocks: Array[Sprite2D] = []
var _starts: Array[Vector2] = []
var _lands: Array[Vector2] = []
var _spins: Array[float] = []
var _dust: Sprite2D = null


func setup(p_tile_size: int, pieces: Array, dust: Texture2D, seed_value: int) -> void:
	tile_size = p_tile_size
	var usable: Array = []
	for piece in pieces:
		if piece != null:
			usable.append(piece)
	if usable.is_empty():
		queue_free()
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in BLOCKS:
		var texture: Texture2D = usable[rng.randi_range(0, usable.size() - 1)]
		var block := Sprite2D.new()
		block.texture = texture
		var span := (tile_size * rng.randf_range(0.4, 0.62)) / float(texture.get_height())
		block.scale = Vector2(span, span)
		add_child(block)
		_blocks.append(block)
		# Ils tombent de plus haut que l'écran ne le montre et atterrissent
		# ÉPARPILLÉS : trois blocs qui tombent au même point font une pile, pas
		# un éboulement.
		var landing := Vector2(rng.randf_range(-0.42, 0.42) * tile_size,
			rng.randf_range(-0.12, 0.18) * tile_size)
		_lands.append(landing)
		_starts.append(landing + Vector2(rng.randf_range(-0.3, 0.3) * tile_size,
			-tile_size * rng.randf_range(2.2, 3.4)))
		_spins.append(rng.randf_range(-2.4, 2.4))
	if dust != null:
		_dust = Sprite2D.new()
		_dust.texture = dust
		var wide := (tile_size * 1.5) / float(dust.get_height())
		_dust.scale = Vector2(wide, wide)
		_dust.modulate = Color(1, 1, 1, 0)
		_dust.z_index = -1
		add_child(_dust)


func _process(delta: float) -> void:
	_life += delta
	if _life >= 1.1:
		queue_free()
		return
	for i in _blocks.size():
		var block := _blocks[i]
		# Chaque bloc part avec un léger décalage : un éboulement n'est pas une
		# salve synchronisée.
		var t := clampf((_life - float(i) * 0.045) / FALL, 0.0, 1.0)
		# Chute ACCÉLÉRÉE : la pesanteur, pas un ascenseur.
		var fallen := t * t
		block.position = _starts[i].lerp(_lands[i], fallen)
		block.rotation = _spins[i] * fallen
		if t >= 1.0:
			# Une fois posé, il s'enfonce et s'efface : la case doit se rouvrir.
			var rest := clampf((_life - FALL - 0.35) / 0.4, 0.0, 1.0)
			block.modulate = Color(1, 1, 1, 1.0 - rest)
			block.position += Vector2(0.0, rest * tile_size * 0.12)
	if _dust != null:
		# La poussière ne monte QU'APRÈS le premier impact.
		var puff := clampf((_life - FALL * 0.8) / 0.45, 0.0, 1.0)
		_dust.position = Vector2(0.0, -tile_size * (0.15 + 0.35 * puff))
		_dust.modulate = Color(0.88, 0.82, 0.66, 0.75 * puff * (1.0 - puff))
		var grow := 0.9 + 0.5 * puff
		var base := (tile_size * 1.5) / float(_dust.texture.get_height())
		_dust.scale = Vector2(base * grow, base * grow)
