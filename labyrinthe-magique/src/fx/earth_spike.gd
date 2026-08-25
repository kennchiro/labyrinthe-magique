class_name EarthSpike
extends Node2D

## Une gerbe de pierre plantée dans une case du couloir.
##
## Elle utilise les pics DESSINÉS de la planche (`spikes.png`), qui y étaient
## depuis le début pendant que le sort s'affichait en éclat circulaire
## générique. Même histoire que les nuages de la Foudre : on ne trace en code
## que ce que la planche ne fournit pas.
##
## Elle SORT du sol au lieu d'apparaître : sans ce jaillissement, la pierre se
## lit comme un décor posé là, pas comme une éruption. Et la terre soulevée part
## avec — une gerbe qui perce le sol sans remuer un grain de poussière n'a
## aucun poids.

## Hauteur visée, en cases.
const TARGET_TILES := 1.5
## Durée du jaillissement, puis de l'affaissement.
const RISE := 0.16
const SINK := 0.35

@onready var stone: Sprite2D = $Stone
@onready var soil: Sprite2D = $Soil

var _life := 0.0
var _total := 1.0
var _tile := 32
var _base := 1.0


func setup(tile_size: int, duration: float, spikes: Texture2D,
		dust: Texture2D) -> void:
	_tile = tile_size
	_total = maxf(0.2, duration)
	var rock: Sprite2D = get_node_or_null("Stone")
	var earth: Sprite2D = get_node_or_null("Soil")
	if rock == null or earth == null or spikes == null:
		queue_free()
		return
	stone = rock
	soil = earth
	stone.texture = spikes
	_base = (tile_size * TARGET_TILES) / float(spikes.get_height())
	# Ancrée sur sa BASE : les pointes montent, le tas de pierres reste au sol.
	# Centrée, la gerbe flotterait au-dessus de sa case.
	stone.offset = Vector2(0.0, -float(spikes.get_height()) * 0.5)
	stone.scale = Vector2(_base, 0.0)
	if dust != null:
		soil.texture = dust
		var span := (tile_size * 1.3) / float(dust.get_height())
		soil.scale = Vector2(span, span)
		soil.offset = Vector2(0.0, -float(dust.get_height()) * 0.3)
	soil.modulate = Color(1, 1, 1, 0)


func _process(delta: float) -> void:
	_life += delta
	if _life >= _total or stone == null:
		queue_free()
		return

	# 1. Le jaillissement, avec un dépassement : la pierre sort trop haut d'un
	#    dixième, puis se pose. Sans ce dépassement, elle monte comme un
	#    ascenseur.
	var out := clampf(_life / RISE, 0.0, 1.0)
	var height := (1.0 + 0.12 * sin(out * PI)) * out
	# 2. Elle s'affaisse à la fin plutôt que de disparaître : le joueur doit
	#    voir que le couloir se rouvre.
	var left := _total - _life
	if left < SINK:
		height *= clampf(left / SINK, 0.0, 1.0)
	stone.scale = Vector2(_base, _base * height)
	stone.modulate = Color(1, 1, 1, clampf(out * 2.0, 0.0, 1.0))

	# 3. La terre soulevée : elle monte et s'efface en une demi-seconde. C'est
	#    elle qui donne son poids au coup.
	if soil.texture != null:
		var puff := clampf(_life / 0.5, 0.0, 1.0)
		soil.position = Vector2(0.0, -_tile * 0.35 * puff)
		soil.modulate = Color(0.86, 0.78, 0.62, 0.7 * (1.0 - puff))
		soil.scale = soil.scale.lerp(soil.scale * 1.02, 0.4)
