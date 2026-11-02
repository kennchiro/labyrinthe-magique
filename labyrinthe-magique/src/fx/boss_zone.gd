class_name BossZone
extends Node2D

## La zone d'une case menacée par un boss : l'alerte, le coup, la fin.
##
## Enfant du Level et non d'Entities, comme `SporeCloud` : elle reste couchée sur le sol
## en 2,5D, là où les personnages sont redressés. La règle vit dans `BossFight`.

const IMPACT_TIME := 0.5
const FADE_TIME := 0.5
## Un rond : 90 % de sa case dessinée, donc une case de couloir à cette échelle.
const ROUND_TILES := 1.1

var _strips: Dictionary = {}
var _strip: BossStrip = null
var _striking := false
var _hold_left := 0.0
## La case qu'elle menace.
var cell := Vector2i.ZERO


## `strips` porte les textures `warning`, `impact` et `fade` du boss.
func setup(at: Vector2, tile_size: int, strips: Dictionary, alert: float, band: bool,
		vertical: bool) -> void:
	position = at
	z_index = 5
	_strips = strips
	_strip = BossStrip.new()
	var cell := float((strips["warning"] as Texture2D).get_width()) / float(BossStrip.FRAMES)
	# Les bandes se mettent bout à bout : exactement une case, ou il reste des trous.
	_strip.scale = Vector2.ONE * float(tile_size) * (1.0 if band else ROUND_TILES) / cell
	_strip.rotation = PI * 0.5 if vertical else 0.0
	add_child(_strip)
	_strip.play(strips["warning"], alert)


## Le coup tombe, à l'instant exact où `BossFight` le décide. `linger` : le temps qu'il
## reste debout sur sa dernière image, pour le mur de ronces.
func strike(linger: float = 0.0) -> void:
	_striking = true
	_hold_left = linger
	_strip.play(_strips["impact"], IMPACT_TIME)
	_strip.finished.connect(_end_impact, CONNECT_ONE_SHOT)


func is_striking() -> bool:
	return _striking


func _end_impact() -> void:
	if _hold_left <= 0.0:
		_end()


func _process(delta: float) -> void:
	if not _striking or _hold_left <= 0.0 or _strip.frame < BossStrip.FRAMES - 1:
		return
	_hold_left -= delta
	if _hold_left <= 0.0:
		_end()


func _end() -> void:
	_strip.play(_strips["fade"], FADE_TIME)
	_strip.finished.connect(queue_free, CONNECT_ONE_SHOT)
