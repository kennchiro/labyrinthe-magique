class_name SummonVisual
extends Node2D

## Le corps visible d'une invocation. Toute la CHASSE — cible, chemin, coups —
## vit dans le CombatSystem ; ce nœud ne fait qu'afficher ce qu'on lui dit.
##
## Deux familles, deux rendus :
##   marcheurs (imp, gargouille) — une seule pose dessinée. L'animation est
##     procédurale : balancement de vol stationnaire + miroir selon la
##     direction. C'est le procédé qui servait aux ennemis d'avant leurs
##     planches ; il retrouve ici un usage.
##   dragon — deux poses par direction, vol et souffle, lues depuis
##     assets/allies. Le souffle s'affiche pendant le coup.

const ALLIES_PATH := "res://assets/allies/"
## Hauteur à l'écran, en pixels : sous le mage (53) pour les marcheurs, au
## dessus pour le dragon — c'est l'ultime, il doit impressionner.
const HEIGHTS := {"imp": 40.0, "gargouille": 46.0, "dragon": 72.0}
## Vitesse du balancement de vol stationnaire.
const BOB_SPEED := 6.0
const BOB_HEIGHT := 2.4
## Durée d'affichage du souffle après un coup.
const STRIKE_FLASH := 0.45

var kind_id := "imp"
var tile_size := 32

var _sprite: Sprite2D = null
var _textures := {}
var _facing: Vector2i = Vector2i.DOWN
var _strike_left := 0.0
var _bob := 0.0


func setup(p_kind: String, p_tile_size: int) -> void:
	kind_id = p_kind
	tile_size = p_tile_size
	_sprite = Sprite2D.new()
	add_child(_sprite)
	_load_textures()
	_apply_frame()
	# Décalage aléatoire du balancement : deux imps invoqués ensemble ne doivent
	# pas flotter à l'unisson comme des copies.
	_bob = randf() * TAU


func _load_textures() -> void:
	if kind_id == "dragon":
		for direction in ["down", "up", "left", "right"]:
			_textures[direction] = load(ALLIES_PATH + "dragon_%s_0.png" % direction)
			_textures[direction + "_fire"] = load(ALLIES_PATH + "dragon_%s_1.png" % direction)
	else:
		_textures["down"] = load(ALLIES_PATH + kind_id + ".png")


func set_facing(facing: Vector2i) -> void:
	if facing != Vector2i.ZERO:
		_facing = facing
	_apply_frame()


func flash_strike() -> void:
	_strike_left = STRIKE_FLASH
	_apply_frame()


func _process(delta: float) -> void:
	_strike_left = maxf(0.0, _strike_left - delta)
	_bob += delta * BOB_SPEED
	if _sprite == null:
		return
	_sprite.position.y = -sin(_bob) * BOB_HEIGHT
	_apply_frame()


func _direction_key() -> String:
	if _facing == Vector2i.UP:
		return "up"
	if _facing == Vector2i.LEFT:
		return "left"
	if _facing == Vector2i.RIGHT:
		return "right"
	return "down"


func _apply_frame() -> void:
	if _sprite == null:
		return
	var key := _direction_key()
	if kind_id == "dragon":
		var wanted: Texture2D = _textures.get(
			key + "_fire" if _strike_left > 0.0 else key)
		if wanted != null and _sprite.texture != wanted:
			_sprite.texture = wanted
		_sprite.flip_h = false
	else:
		_sprite.texture = _textures.get("down")
		# Une seule pose : le profil est un miroir, et le coup un sursaut de
		# teinte — pas de planche, pas de mensonge, juste des indices lisibles.
		_sprite.flip_h = _facing == Vector2i.LEFT
		_sprite.modulate = Color(1.5, 1.2, 1.2) if _strike_left > 0.0 else Color.WHITE
	if _sprite.texture != null:
		var factor: float = HEIGHTS.get(kind_id, 44.0) / float(_sprite.texture.get_height())
		_sprite.scale = Vector2(factor, factor)
		# Ancré au-dessus de l'origine : l'origine est l'ombre au sol, la
		# créature FLOTTE au-dessus — toutes volent ou lévitent.
		_sprite.offset = Vector2(0.0, -_sprite.texture.get_height() * 0.5 + 2.0)


func _draw() -> void:
	# Ombre de contact, comme les acteurs : sans elle, une créature volante ne
	# se situe plus — on ne sait pas au-dessus de QUELLE case elle est.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, tile_size * (0.34 if kind_id == "dragon" else 0.24),
		Color(0.0, 0.0, 0.0, 0.32))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
