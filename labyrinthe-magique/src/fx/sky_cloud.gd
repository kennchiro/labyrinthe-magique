class_name SkyCloud
extends Node2D

## Un nuage du Jugement céleste, posé sur une case du labyrinthe.
##
## Il utilise le nuage DESSINÉ de la planche (`cloud_dark.png`) et non des ronds
## tracés en code. La planche en fournissait deux depuis le début, avec leurs
## éclairs — le jeu affichait des cercles gris à leur place. On ne dessine à la
## main que ce que la planche ne fournit pas.
##
## Il flotte : une oscillation lente et un balancement. Un nuage parfaitement
## immobile se lit comme un décor collé au sol, pas comme un ciel.

const HEIGHT_TILES := 1.3
const TARGET_TILES := 2.0
## Temps de formation et de dissipation, en secondes.
const GATHER := 0.45

@onready var sprite: Sprite2D = $Sprite2D

var tile_size: int = 32

var _left := 0.0
var _total := 1.0
var _time := 0.0
var _flash := 0.0
var _phase := 0.0
## La planche fournit DEUX nuages : un sombre au repos, un bleu allumé. Le sort
## bascule de l'un à l'autre au moment de la décharge, au lieu d'éclaircir la
## couleur d'un seul — c'est le dessinateur qui a choisi à quoi ressemble un
## nuage qui tonne, pas un multiplicateur de teinte.
var _dark: Texture2D = null
var _bright: Texture2D = null


func setup(p_tile_size: int, duration: float, dark: Texture2D, bright: Texture2D,
		phase: float) -> void:
	tile_size = p_tile_size
	_total = maxf(0.1, duration)
	_left = _total
	_phase = phase
	var node: Sprite2D = get_node_or_null("Sprite2D")
	if node == null:
		queue_free()
		return
	sprite = node
	_dark = dark
	_bright = bright if bright != null else dark
	if _dark != null:
		sprite.texture = _dark
		var factor := (tile_size * TARGET_TILES) / float(_dark.get_height())
		sprite.scale = Vector2(factor, factor)
	sprite.position = Vector2(0.0, -tile_size * HEIGHT_TILES)


## Une décharge part : le nuage blanchit un instant. C'est ce qui relie le nuage
## à l'éclair qui en tombe — sans quoi les deux semblent indépendants.
func discharge() -> void:
	_flash = 1.0
	if sprite != null and _bright != null:
		sprite.texture = _bright


func fade() -> void:
	_left = minf(_left, GATHER)


func _process(delta: float) -> void:
	_time += delta
	var lit := _flash > 0.0
	_flash = maxf(0.0, _flash - delta * 4.0)
	if lit and _flash <= 0.0 and sprite != null and _dark != null:
		sprite.texture = _dark
	_left = maxf(0.0, _left - delta)
	if _left <= 0.0:
		queue_free()
		return
	if sprite == null:
		return

	# Il se FORME et se DISSIPE au lieu d'apparaître : un nuage qui surgit d'un
	# coup se lit comme un bug d'affichage.
	var opening := clampf((_total - _left) / GATHER, 0.0, 1.0)
	var closing := clampf(_left / GATHER, 0.0, 1.0)
	var presence := minf(opening, closing)

	var bob := sin(_time * 1.4 + _phase) * tile_size * 0.09
	sprite.position = Vector2(cos(_time * 0.7 + _phase) * tile_size * 0.12,
		-tile_size * HEIGHT_TILES + bob)
	var glow := 1.0 + 0.9 * _flash
	sprite.modulate = Color(glow, glow, glow, presence)
