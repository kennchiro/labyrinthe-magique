class_name MagicOrb
extends Node2D

## Le projectile du sort : une bille de lumière bleue qui remonte les couloirs
## jusqu'à sa cible.
##
## Il ne DÉCIDE de rien. Le SpellSystem a déjà fixé la cible et l'instant de
## l'impact ; l'orbe ne fait que rendre visible ce trajet, à la seconde près.
## Séparer les deux permet à la simulation d'équilibrage de jouer des parties
## entières sans jamais instancier un seul de ces nœuds.

const TEXTURE := preload("res://assets/sprites/magic_orb.png")
## Teinte par défaut ; l'élément de la compétence la remplace au lancement.
const TINT := Color("#7fd8ff")
## Longueur de la traînée, en points de trajectoire mémorisés.
const TRAIL_LENGTH := 9

@onready var sprite: Sprite2D = $Sprite2D

var tile_size: int = 32

var _points: PackedVector2Array = PackedVector2Array()
var _duration := 0.4
var _elapsed := 0.0
var _trail: Array[Vector2] = []


var tint: Color = TINT
var _drawn := false
var _frames := 1
## Cadence du flip-book, en images par seconde.
const FLIP_FPS := 12.0


## `p_texture` : le projectile DESSINÉ du mage, découpé de sa planche. Sans lui
## (repli), la bille générique — mais teintée seulement dans ce cas : le trait
## de flamme du Mage du Feu porte déjà ses couleurs, le reteindre le salirait.
## `p_frames` > 1 : la bande est un FLIP-BOOK — les quatre comètes du Feu se
## relaient en vol, et le trait vit au lieu de glisser figé.
func setup(points: PackedVector2Array, duration: float, p_tile_size: int,
		p_tint: Color = TINT, p_texture: Texture2D = null, p_frames: int = 1) -> void:
	tile_size = p_tile_size
	tint = p_tint
	_drawn = p_texture != null
	_frames = maxi(1, p_frames)
	sprite.modulate = Color(1, 1, 1) if _drawn else tint
	_points = points
	_duration = maxf(0.05, duration)
	var texture := p_texture if _drawn else TEXTURE
	sprite.texture = texture
	sprite.hframes = _frames
	var cell_width := float(texture.get_width()) / float(_frames)
	var extent := maxf(cell_width, float(texture.get_height()))
	var factor := (tile_size * 0.95) / extent
	sprite.scale = Vector2(factor, factor)

	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	sprite.material = material
	self.material = material
	if _points.size() > 0:
		position = _points[0]


## La cible bouge pendant le vol : le dernier point du trajet la suit, sinon
## l'orbe irait exploser là où l'ennemi se trouvait à l'instant du tir.
func retarget(world_position: Vector2) -> void:
	if _points.size() >= 2:
		_points[_points.size() - 1] = world_position


func _process(delta: float) -> void:
	_elapsed += delta
	if _points.size() < 2:
		queue_free()
		return

	var t := clampf(_elapsed / _duration, 0.0, 1.0)
	position = _sample(t)

	_trail.push_front(position)
	while _trail.size() > TRAIL_LENGTH:
		_trail.pop_back()

	# Un dessin s'ORIENTE le long du vol — une comète qui tournoie sur
	# elle-même se lit comme un débris, pas comme un tir. La bille générique,
	# ronde, garde sa rotation d'origine : sur elle c'est un scintillement.
	if _drawn and _trail.size() >= 2 and _trail[0] != _trail[1]:
		sprite.rotation = (_trail[0] - _trail[1]).angle()
	elif not _drawn:
		sprite.rotation += delta * 6.0
	if _frames > 1:
		sprite.frame = int(_elapsed * FLIP_FPS) % _frames
	queue_redraw()


## Point à l'avancement `t` le long de la polyligne, à vitesse constante.
func _sample(t: float) -> Vector2:
	var segments := _points.size() - 1
	var scaled := t * float(segments)
	var index := mini(int(scaled), segments - 1)
	return _points[index].lerp(_points[index + 1], scaled - float(index))


## Impact : l'orbe s'efface, l'éclat est joué par le Level (même effet que les
## téléportations, pour que le jeu n'ait qu'un seul vocabulaire visuel).
func burst() -> void:
	queue_free()


func _draw() -> void:
	for i in _trail.size():
		var fade := 1.0 - float(i) / float(TRAIL_LENGTH)
		draw_circle(to_local(_trail[i]), tile_size * 0.16 * fade,
			Color(tint.r, tint.g, tint.b, 0.28 * fade))
