class_name Actor
extends Node2D

## Base commune au joueur et aux ennemis : un GridMover, une ombre de contact,
## et une animation de marche PROCÉDURALE À TROIS PIÈCES.
##
## Le mage, lui, a depuis une vraie planche d'animation dessinée : Player
## redéfinit `_apply_visual()` et `_animate()` et n'utilise rien de ce qui suit.
## Le procédé à trois pièces reste pour les ENNEMIS, dont les sprites sont
## toujours des poses uniques.
##
## La planche d'assets ne contient aucun cycle de marche : les douze poses du
## mage sont douze dessins légèrement différents (proportions, chapeau, largeur
## du corps), pas les images d'une même animation. Les enchaîner ferait trembler
## le personnage en permanence.
##
## Première tentative : un simple balancement vertical du sprite entier. Le
## résultat donnait l'impression que le mage SAUTAIT au lieu de marcher — c'est
## exactement ce qu'on ne veut pas.
##
## Solution retenue : découper le sprite en trois régions et les animer
## séparément, ce qui reproduit la mécanique réelle d'un pas.
##   corps      — léger tangage à DOUBLE fréquence (deux appuis par foulée) et
##                inclinaison alternée
##   pied gauche / pied droit — se lèvent et avancent en OPPOSITION DE PHASE
## Trois régions d'une seule image suffisent à lire « marche » ; le pas vient du
## décalage entre les pieds, pas de l'amplitude verticale du corps.

## Foulées par seconde à vitesse nominale.
const STRIDE_SPEED := 5.2
## Part basse du sprite considérée comme « les pieds ».
const FOOT_BAND := 0.20
## Amplitude du pas, en pixels de texture.
const FOOT_LIFT := 2.6
const FOOT_SWING := 1.8
## Tangage du corps : volontairement faible. C'est son amplitude excessive qui
## produisait l'effet de saut.
const BODY_BOB := 1.0
const BODY_TILT := 0.035
## Respiration au repos : à peine plus d'un pixel à l'écran.
const BREATH_SPEED := 2.6
const BREATH_DEPTH := 0.016

@onready var sprite: Sprite2D = $Sprite2D
@onready var foot_left: Sprite2D = $FootLeft
@onready var foot_right: Sprite2D = $FootRight

var mover: GridMover = null
var tile_size: int = 32
## À renseigner par la sous-classe AVANT setup().
var texture: Texture2D = null
var target_height := 46.0

## Décalage vertical de l'ombre de contact, en fraction de case. Les ennemis
## sont ancrés au ventre (poses uniques, cf. _apply_visual) et ont besoin d'un
## décalage ; le mage, lui, a les pieds pile sur l'origine.
var shadow_offset := 0.16
var shadow_radius := 0.30

var _scale_factor := 1.0
## Échelle de repos du sprite d'une planche, celle que `_breathe` fait varier.
var _sprite_scale := Vector2.ONE
## Horloge de la respiration. Le départ est propre à chaque acteur : une meute
## qui respire en mesure se voit tout de suite. Pas de `randf()` : ce tirage
## décalerait le générateur global, donc le rejeu d'une graine.
var _life_time := 0.0
var _body_home := Vector2.ZERO
var _foot_home := Vector2.ZERO
var _stride := 0.0


func setup(grid: MazeGrid, start_cell: Vector2i, speed: float, p_tile_size: int) -> void:
	tile_size = p_tile_size
	_life_time = fmod(float(get_instance_id()) * 0.37, TAU)
	mover = GridMover.new(grid, start_cell, speed)
	position = _world_position()
	_apply_visual()
	queue_redraw()


func snap_to_mover() -> void:
	if mover != null:
		position = _world_position()


func current_cell() -> Vector2i:
	return mover.cell if mover != null else Vector2i.ZERO


func set_tint(color: Color) -> void:
	for part in [sprite, foot_left, foot_right]:
		if part != null:
			part.modulate = color


func _apply_visual() -> void:
	if sprite == null or texture == null:
		return
	var width := float(texture.get_width())
	var height := float(texture.get_height())
	var body_height := height * (1.0 - FOOT_BAND)
	_scale_factor = target_height / height

	# Décalage vers le haut : les pieds tombent près du centre de la case, la
	# tête dépasse. Centrer le sprite ferait marcher le personnage sur son ventre.
	var anchor := -height * 0.22

	_setup_part(sprite, Rect2(0.0, 0.0, width, body_height),
		Vector2(0.0, anchor - height * 0.5 + body_height * 0.5))
	_body_home = sprite.position

	var foot_y := anchor - height * 0.5 + body_height + height * FOOT_BAND * 0.5
	_setup_part(foot_left, Rect2(0.0, body_height, width * 0.5, height * FOOT_BAND),
		Vector2(-width * 0.25, foot_y))
	_setup_part(foot_right, Rect2(width * 0.5, body_height, width * 0.5, height * FOOT_BAND),
		Vector2(width * 0.25, foot_y))
	_foot_home = Vector2(width * 0.25, foot_y) * _scale_factor


func _setup_part(part: Sprite2D, region: Rect2, offset: Vector2) -> void:
	part.texture = texture
	part.region_enabled = true
	part.region_rect = region
	part.scale = Vector2(_scale_factor, _scale_factor)
	part.position = offset * _scale_factor


## PILOTÉ DE L'EXTÉRIEUR : l'Arène fait avancer le `GridMover` dans `ArenaMatch`, qui décide pour
## tous les héros à la fois. Le nœud ne fait alors que suivre et dessiner — avancer le même
## mover une seconde fois le ferait courir deux fois plus vite, et lire le clavier le piloterait.
var puppet := false


func _process(delta: float) -> void:
	if mover == null:
		return
	if not puppet:
		_update_desired(delta)
		mover.update(delta)
	position = _world_position()
	_animate(delta)


## À redéfinir : renseigner `mover.desired_direction`.
func _update_desired(_delta: float) -> void:
	pass


func _animate(delta: float) -> void:
	if sprite == null:
		return

	if not mover.is_moving():
		# Retour au repos, sans coupure : un arrêt net sur une pose de pas se voit.
		var ease := minf(1.0, delta * 14.0)
		_stride = 0.0
		sprite.position = sprite.position.lerp(_body_home, ease)
		sprite.rotation = lerpf(sprite.rotation, 0.0, ease)
		foot_left.position = foot_left.position.lerp(Vector2(-_foot_home.x, _foot_home.y), ease)
		foot_right.position = foot_right.position.lerp(_foot_home, ease)
		return

	_stride += delta * STRIDE_SPEED * TAU
	if mover.direction.x != 0:
		var facing_left := mover.direction.x < 0
		sprite.flip_h = facing_left
		foot_left.flip_h = facing_left
		foot_right.flip_h = facing_left

	# Corps : deux appuis par foulée, d'où la double fréquence.
	sprite.position = _body_home + Vector2(0.0, -absf(sin(_stride)) * BODY_BOB) * _scale_factor
	sprite.rotation = sin(_stride * 0.5) * BODY_TILT

	# Pieds en opposition de phase : quand l'un se lève et avance, l'autre est au
	# sol et recule. C'est ce décalage qui fait lire « marche » plutôt que « saut ».
	_place_foot(foot_left, -1.0, _stride)
	_place_foot(foot_right, 1.0, _stride + PI)


func _place_foot(foot: Sprite2D, side: float, phase: float) -> void:
	var lift := maxf(0.0, sin(phase)) * FOOT_LIFT
	var swing := cos(phase) * FOOT_SWING
	foot.position = Vector2(side * _foot_home.x / _scale_factor + swing, _foot_home.y / _scale_factor - lift) * _scale_factor


## Respiration à l'arrêt. L'origine du nœud est aux pieds : le haut du corps
## bouge et les pieds restent posés. Un sprite parfaitement immobile se lit comme
## une image collée sur le décor, pas comme un personnage qui attend.
func _breathe(delta: float) -> void:
	_life_time += delta
	var breath := sin(_life_time * BREATH_SPEED) * BREATH_DEPTH
	sprite.scale = _sprite_scale * Vector2(1.0 - breath * 0.5, 1.0 + breath)


func _world_position() -> Vector2:
	return (mover.grid_position() + Vector2(0.5, 0.5)) * float(tile_size)


func _draw() -> void:
	# Ombre de contact. Sans elle le personnage semble flotter au-dessus du sol :
	# c'est ce qui manque le plus quand on passe des placeholders aux sprites.
	draw_set_transform(Vector2(0.0, tile_size * shadow_offset), 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, tile_size * shadow_radius, Color(0.0, 0.0, 0.0, 0.38))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
