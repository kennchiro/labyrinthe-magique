class_name Portal
extends Node2D

## Visuel d'un portail. Aucune logique : les destinations sont décidées par
## PortalNetwork, l'exécution par TeleportSystem.
##
## Six poses dessinées : idle, ouverture, ouvert, actif, téléportation,
## fermeture. Elles racontent l'état du portail sans un mot d'interface :
##
##   au repos          le cercle tourne doucement, refermé
##   le mage arrive    il s'ouvre
##   prêt              il bat entre « ouvert » et « actif »
##   au saut           la colonne de lumière
##   en recharge       il se referme, puis retombe au repos
##
## HUIT COULEURS, une par portail selon son index. Ce n'est pas décoratif : dans
## un labyrinthe où l'on revient sur ses pas, « le portail vert » est un repère
## mémorisable, là où huit portails identiques ne s'ancrent pas.
##
## Le sprite est rendu en BLENDING ADDITIF. C'est ce qui fait qu'une lueur
## ressemble à de la lumière et non à un autocollant : le noir du fond devient
## transparent de lui-même et le halo se cumule avec le décor.

const PORTALS_PATH := "res://assets/portals/"
const FRAMES_PATH := PORTALS_PATH + "frames.json"
const TARGET_HEIGHT_TILES := 1.6

## Poses, dans l'ordre de la planche.
const IDLE := 0
const OPENING := 1
const OPEN := 2
const ACTIVE := 3
const TELEPORTING := 4
const CLOSING := 5

## Durée de la pose de saut, et de la fermeture qui suit.
const TELEPORT_FLASH := 0.30
const CLOSE_DURATION := 0.45

@onready var sprite: Sprite2D = $Sprite2D

var tile_size: int = 32
var cell: Vector2i = Vector2i.ZERO
## Vrai quand le joueur est dessus et peut l'emprunter.
var highlighted := false
var color_name := "bleu"

var _time := 0.0
var _base_scale := 1.0
var _cell := Vector2(140.0, 96.0)
var _flash := 0.0
var _closing := 0.0
var _was_highlighted := false


func setup(p_cell: Vector2i, p_tile_size: int, phase: float, index: int = 0) -> void:
	cell = p_cell
	tile_size = p_tile_size
	# Déphasage par portail : sinon tous pulsent à l'unisson, ce qui fait
	# clignotant d'ambulance plutôt que forêt enchantée.
	_time = phase

	var colors := _colors()
	color_name = colors[index % colors.size()]
	sprite.texture = load(PORTALS_PATH + color_name + ".png")
	sprite.hframes = 6
	sprite.frame = IDLE
	_base_scale = (tile_size * TARGET_HEIGHT_TILES) / _cell.y
	sprite.scale = Vector2(_base_scale, _base_scale)
	sprite.offset = Vector2(0.0, -_cell.y * 0.12)

	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	sprite.material = material


func _colors() -> Array:
	var text := FileAccess.get_file_as_string(FRAMES_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		return ["bleu"]
	var data: Dictionary = parsed
	var cell_size: Array = data["cell"]
	_cell = Vector2(float(cell_size[0]), float(cell_size[1]))
	return data["colors"]


## Appelé par le Level quand un saut part d'ici : la colonne de lumière.
func flash_teleport() -> void:
	_flash = TELEPORT_FLASH


func _process(delta: float) -> void:
	_time += delta
	_flash = maxf(0.0, _flash - delta)
	# Le portail se referme quand le mage s'en va : sans cette pose, il resterait
	# grand ouvert derrière lui et on croirait pouvoir encore l'emprunter.
	if _was_highlighted and not highlighted:
		_closing = CLOSE_DURATION
	_was_highlighted = highlighted
	_closing = maxf(0.0, _closing - delta)

	var pulse := 0.5 + 0.5 * sin(_time * 2.6)
	if _flash > 0.0:
		sprite.frame = TELEPORTING
	elif highlighted:
		# Battement entre ouvert et actif : c'est l'invitation à appuyer.
		sprite.frame = ACTIVE if pulse > 0.5 else OPEN
	elif _closing > 0.0:
		sprite.frame = CLOSING
	else:
		# Au repos, une ouverture de temps en temps : un portail parfaitement
		# immobile se lit comme un décor, pas comme une porte.
		sprite.frame = OPENING if pulse > 0.86 else IDLE

	var factor := _base_scale * (1.0 + 0.06 * pulse + (0.10 if _flash > 0.0 else 0.0))
	sprite.scale = Vector2(factor, factor)
	sprite.modulate = Color(1.25, 1.25, 1.25) if highlighted else Color(1, 1, 1)
	queue_redraw()


func _draw() -> void:
	if not highlighted:
		return
	# Anneau au sol : il dit exactement quelle CASE est le portail, ce que la
	# lueur, large et floue, ne dit pas.
	var pulse := 0.5 + 0.5 * sin(_time * 2.6)
	draw_arc(Vector2(0.0, tile_size * 0.16), tile_size * (0.52 + 0.07 * pulse),
		0.0, TAU, 40, Color(0.85, 0.95, 1.0, 0.75), 2.0)
