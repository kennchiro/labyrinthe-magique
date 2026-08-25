class_name CrystalTurret
extends Node2D

## Le cristal PLANTÉ qui tire tout seul.
##
## Il pose trois choses à l'écran, et les trois sont nécessaires : qu'il est là,
## qu'il TIRE, et combien de temps il lui reste. Sans la troisième, le joueur ne
## sait pas s'il peut encore compter dessus — et ce sort ne se joue que sur ce
## calcul-là.
##
## Le cristal est celui de la planche, socle de pierre compris. Il sort du sol
## comme les Pics : ce qui perce la terre ne doit jamais APPARAÎTRE.

const TARGET_TILES := 1.6
const RISE := 0.22
const SINK := 0.4
## Sous ce reste de temps, la pulsation s'emballe : le cristal s'épuise.
const WARNING := 3.0

@onready var body: Sprite2D = $Body

var tile_size: int = 32

var _left := 0.0
var _total := 1.0
var _time := 0.0
var _flash := 0.0
var _base := 1.0


func setup(p_tile_size: int, duration: float, texture: Texture2D) -> void:
	tile_size = p_tile_size
	_total = maxf(0.5, duration)
	_left = _total
	var node: Sprite2D = get_node_or_null("Body")
	if node == null or texture == null:
		queue_free()
		return
	body = node
	body.texture = texture
	_base = (tile_size * TARGET_TILES) / float(texture.get_height())
	# Ancré sur son socle : le cristal pousse vers le haut, la pierre reste au
	# sol. Centré, il flotterait au-dessus de sa case.
	body.offset = Vector2(0.0, -float(texture.get_height()) * 0.5)
	body.scale = Vector2(_base, 0.0)


## Un éclat part : le cristal blanchit un instant. C'est ce qui relie le tir à
## sa source — sans quoi l'éclat semble venir de nulle part.
func fire() -> void:
	_flash = 1.0


func fade() -> void:
	_left = minf(_left, SINK)


func _process(delta: float) -> void:
	_time += delta
	_left = maxf(0.0, _left - delta)
	_flash = maxf(0.0, _flash - delta * 5.0)
	if _left <= 0.0 or body == null:
		queue_free()
		return

	var out := clampf(_time / RISE, 0.0, 1.0)
	var height := (1.0 + 0.14 * sin(out * PI)) * out
	if _left < SINK:
		height *= clampf(_left / SINK, 0.0, 1.0)
	# La pulsation s'accélère quand il s'épuise : c'est le compte à rebours,
	# lisible sans chiffre.
	var hurry := 1.0 + 2.0 * (1.0 - clampf(_left / WARNING, 0.0, 1.0))
	var pulse := 1.0 + 0.05 * sin(_time * 4.0 * hurry)
	body.scale = Vector2(_base * pulse, _base * height * pulse)
	var glow := 1.0 + 1.3 * _flash
	body.modulate = Color(glow, glow, glow, clampf(out * 2.0, 0.0, 1.0))
