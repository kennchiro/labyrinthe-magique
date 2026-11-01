class_name EnemyLair
extends Node2D

## Le repaire d'où sortent les ennemis.
##
## Il remplace l'apparition au hasard, et c'est un changement de fond : une
## menace qui surgit n'importe où ne s'apprend pas, elle se subit. Une menace
## qui sort d'une maison connue, aux coins de la carte, se lit — le joueur peut
## éviter les angles, anticiper le retour d'un ennemi qu'il vient d'abattre, ou
## décider d'aller le cueillir à la sortie.
##
## Six poses : porte close, lueur, portail, portail ouvert, éruption, sortie.
## Elles servent d'AVERTISSEMENT : le repaire s'anime une seconde avant de
## lâcher la créature, ce qui laisse au joueur le temps de s'écarter.

signal released
signal destroyed

const LAIRS_PATH := "res://assets/lairs/"
const FRAMES_PATH := LAIRS_PATH + "frames.json"
## Hauteur de la CASE, en cases du labyrinthe : la marge de la planche y compte, et le
## bâtiment lui-même en fait 2.
const TARGET_HEIGHT_TILES := 2.85
## Le socle tombe un peu sous le centre de sa case, et la toiture déborde derrière.
const FEET_BELOW_CENTER_TILES := 0.4
## La couleur du halo au sol, celle de la magie de chaque repaire.
const GLOWS := {
	"rouge": Color(1.0, 0.35, 0.3), "violet": Color(0.6, 0.42, 1.0),
	"vert": Color(0.45, 1.0, 0.3), "cyan": Color(0.3, 0.88, 0.95),
}
## Durée de l'avertissement, du premier frémissement à la sortie. Fixée par le
## `LevelConfig` : c'est un réglage de difficulté, et la simulation
## d'équilibrage doit appliquer exactement la même.
var opening_duration := 1.1
## Temps pendant lequel la pose de sortie reste à l'écran APRÈS le lâcher.
## Sans cette tenue, la dernière pose — le point culminant de l'animation —
## ne durerait qu'une seule image et ne se verrait jamais.
const SPAWN_HOLD := 0.35
const HIT_FLASH := 0.14

const CLOSED := 0
const ERUPTION := 4
const SPAWNING := 5

@onready var sprite: Sprite2D = $Sprite2D

var cell: Vector2i = Vector2i.ZERO
var tile_size: int = 32

var _cell_size := Vector2(128.0, 160.0)
var _feet_y := 142.0
var _glow: Color = GLOWS["rouge"]
var _opening := 0.0
var _holding := 0.0
var _flash := 0.0
var _rubble := 0.0

## Points de vie — nul tant que la maison est indestructible. Sur les niveaux
## de fin de chapitre (stages 3 et 9), c'est elle qu'il faut abattre pour que la
## porte du mage s'ouvre.
var health: Health = null
var _time := 0.0
var _poses := 6


## `p_health` à zéro : la maison est un décor invulnérable, comme dans tous les
## niveaux ordinaires.
func setup(p_cell: Vector2i, p_tile_size: int, index: int, p_health: int = 0,
		p_opening: float = 1.1) -> void:
	cell = p_cell
	opening_duration = maxf(0.1, p_opening)
	if p_health > 0:
		health = Health.new(p_health)
		health.died.connect(_on_died)
	tile_size = p_tile_size
	var colors := _load_meta()
	var color := str(colors[index % colors.size()])
	_glow = GLOWS.get(color, _glow)
	sprite.texture = load(LAIRS_PATH + color + ".png")
	sprite.hframes = _poses
	sprite.frame = CLOSED
	var factor := (tile_size * TARGET_HEIGHT_TILES) / _cell_size.y
	sprite.scale = Vector2(factor, factor)
	# La maison est posée SUR sa case : son socle tombe au centre, sa toiture
	# déborde sur les haies derrière — comme la maison du mage.
	sprite.offset = Vector2(0.0, _cell_size.y * 0.5 - _feet_y
		+ FEET_BELOW_CENTER_TILES * tile_size / factor)


func _load_meta() -> Array:
	var text := FileAccess.get_file_as_string(FRAMES_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		return ["rouge"]
	var data: Dictionary = parsed
	var size: Array = data["cell"]
	_cell_size = Vector2(float(size[0]), float(size[1]))
	_feet_y = float(data["feet_y"])
	_poses = (data["poses"] as Array).size()
	return data["colors"]


## Ouvre la porte. `released` part à la fin de l'animation — c'est le Level qui
## fait alors réapparaître l'ennemi, pas le repaire : lui ne fait que montrer.
func open() -> void:
	if _opening <= 0.0 and _holding <= 0.0:
		_opening = opening_duration


func is_vulnerable() -> bool:
	return health != null


func is_destroyed() -> bool:
	return health != null and not health.is_alive()


func flash_hit() -> void:
	_flash = HIT_FLASH


func _on_died() -> void:
	# La maison qui tombe cesse d'exister comme menace : plus d'ouverture, plus
	# de sortie. C'est toute la récompense de l'avoir abattue.
	_opening = 0.0
	_holding = 0.0
	_rubble = 1.0
	destroyed.emit()


func is_opening() -> bool:
	return _opening > 0.0 or _holding > 0.0


func _process(delta: float) -> void:
	_time += delta
	_flash = maxf(0.0, _flash - delta)
	if is_destroyed():
		# Carcasse éteinte : la porte close, sans lueur, noircie. Aucune pose de
		# ruine n'existe sur la planche — le noircissement est ce qui distingue
		# le plus lisiblement une maison morte d'une maison au repos.
		sprite.frame = CLOSED
		sprite.modulate = Color(0.32, 0.26, 0.30)
		queue_redraw()
		return
	sprite.modulate = Color(2.2, 1.4, 1.4) if _flash > 0.0 else Color(1, 1, 1)
	if _opening > 0.0:
		var before := _opening
		_opening = maxf(0.0, _opening - delta)
		# Les cinq premières poses défilent pendant l'ouverture, la sixième au
		# moment exact où la créature sort.
		var progress := 1.0 - _opening / opening_duration
		sprite.frame = clampi(int(progress * float(_poses - 1)), 0, _poses - 1)
		if before > 0.0 and _opening <= 0.0:
			sprite.frame = SPAWNING
			_holding = SPAWN_HOLD
			released.emit()
	elif _holding > 0.0:
		_holding = maxf(0.0, _holding - delta)
		sprite.frame = SPAWNING
	else:
		# Au repos, la porte reste close mais la lueur respire : une maison
		# parfaitement éteinte se confond avec le décor de la forêt.
		var pulse := 0.5 + 0.5 * sin(_time * 1.7)
		sprite.frame = CLOSED if pulse < 0.72 else 1
	queue_redraw()


func _draw() -> void:
	if is_destroyed():
		return
	if health != null:
		_draw_health()
	# Halo au sol, plus vif pendant l'ouverture : c'est le signal d'alerte.
	var pulse := 0.5 + 0.5 * sin(_time * (6.0 if is_opening() else 1.7))
	var strength := 0.16 + (0.34 if is_opening() else 0.0)
	draw_circle(Vector2(0.0, tile_size * 0.12), tile_size * (0.85 + 0.15 * pulse),
		Color(_glow.r, _glow.g, _glow.b, strength * (0.5 + 0.5 * pulse)))


## Barre de vie, dessinée comme celle des ennemis : le joueur doit voir que ses
## tirs portent, sinon rien ne distingue une façade qu'on entame d'un décor.
func _draw_health() -> void:
	var width := float(tile_size) * 1.9
	var top := -float(tile_size) * 1.55
	var ratio := clampf(float(health.current) / float(maxi(1, health.maximum)), 0.0, 1.0)
	var back := Rect2(Vector2(-width * 0.5, top), Vector2(width, 5.0))
	draw_rect(back, Color(0.05, 0.03, 0.06, 0.8))
	draw_rect(Rect2(back.position, Vector2(width * ratio, 5.0)), Color(0.95, 0.35, 0.25))
	draw_rect(back, Color(0.9, 0.8, 0.9, 0.5), false, 1.0)
