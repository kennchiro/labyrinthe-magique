class_name Tornado
extends Node2D

## LA TORNADE : elle tourne, elle avance, elle aspire ce qui l'entoure.
##
## Le dessin vient de la planche du mage — il y en avait deux, inemployées : la
## Tornade s'affichait avec l'anneau de vent générique des zones, le même que
## celui du brasier et du cercle glacé.
##
## Elle TOURNE pour de vrai : huit images d'un tour complet, en boucle.
##
## ⚠️ La rotation a d'abord été tentée par SHADER, en faisant défiler la texture
## horizontalement — ce qui tourne à l'œil sur une tornade, ce sont ses bandes.
## Raté : un dessin de tornade n'est pas RÉPÉTABLE horizontalement, donc le bord
## gauche réapparaissait à droite et le tout s'étalait en bouillie bleue. La
## planche a été commandée pour ça, silhouette identique d'une image à l'autre
## et seules les bandes qui bougent.
##
## Le reste du mouvement l'accompagne : le corps respire en largeur, les débris
## happés tournent autour de la base, et la colonne GLISSE d'une case à l'autre
## au lieu d'y sauter — sans quoi l'œil perd ce qu'elle emporte.

## Hauteur visée, en cases.
## Hauteur visée, en cases. À 2,6 elle effaçait complètement le mage à
## l'instant du lancement — elle part aussitôt, mais cette première demi-seconde
## comptait.
const TARGET_TILES := 2.1
const RISE := 0.3
const FALL := 0.35
## Débris happés qui tournent autour de la base.
const MOTES := 7

@onready var body: Sprite2D = $Body

## Tours complets par seconde. Trois : assez vite pour gronder, assez lent pour
## qu'on distingue le sens de rotation. Au-delà, les bandes se brouillent.
const TURNS := 3.0

var tile_size: int = 32
var _frames: Array[Texture2D] = []

var _left := 0.0
var _total := 1.0
var _time := 0.0
var _motes: Array[Vector2] = []
var _tint := Color(0.81, 0.91, 1.0)


func setup(p_tile_size: int, duration: float, frames: Array,
		tint: Color) -> void:
	tile_size = p_tile_size
	_total = maxf(0.3, duration)
	_left = _total
	_tint = tint
	for frame in frames:
		if frame != null:
			_frames.append(frame)
	var node: Sprite2D = get_node_or_null("Body")
	if node == null or _frames.is_empty():
		queue_free()
		return
	body = node
	body.texture = _frames[0]
	var factor := (tile_size * TARGET_TILES) / float(_frames[0].get_height())
	body.scale = Vector2(factor, factor)
	# Ancrée sur sa POINTE : elle touche le sol de sa case, le reste monte.
	body.offset = Vector2(0.0, -float(_frames[0].get_height()) * 0.5)
	for i in MOTES:
		_motes.append(Vector2(randf_range(0.0, TAU), randf_range(0.5, 1.1)))


## Elle CHANGE DE CASE : le rendu suit, en glissant. Sans glissement, elle
## saute de case en case et l'œil perd ce qu'elle emporte.
var _target := Vector2.ZERO
var _sliding := false


func walk_to(destination: Vector2) -> void:
	_target = destination
	_sliding = true


func fade() -> void:
	_left = minf(_left, FALL)


func _process(delta: float) -> void:
	_time += delta
	_left = maxf(0.0, _left - delta)
	if _left <= 0.0 or body == null:
		queue_free()
		return
	if _sliding:
		# Rattrapage souple : elle vise sa case sans jamais y sauter.
		position = position.lerp(_target, clampf(delta * 9.0, 0.0, 1.0))
		if position.distance_to(_target) < 1.0:
			_sliding = false

	# LE TOUR. Les huit images bouclent : la dernière enchaîne sur la première
	# sans saut, c'est ce que la planche garantit.
	var turn := int(_time * TURNS * float(_frames.size())) % _frames.size()
	body.texture = _frames[turn]

	var opening := clampf((_total - _left) / RISE, 0.0, 1.0)
	var closing := clampf(_left / FALL, 0.0, 1.0)
	var presence := minf(opening, closing)
	var factor := (tile_size * TARGET_TILES) / float(body.texture.get_height())
	# Elle grandit en s'installant et se rétracte en mourant, mais garde sa
	# LARGEUR : une tornade qui rétrécit en hauteur seulement s'écrase.
	# Elle RESPIRE en largeur : un entonnoir qui tourne se resserre et s'élargit
	# sans cesse. C'est le seul mouvement qu'un dessin unique peut donner.
	var breath := 1.0 + 0.09 * sin(_time * 7.5)
	body.scale = Vector2(factor * (0.55 + 0.45 * presence) * breath,
		factor * (0.4 + 0.6 * presence))
	body.modulate = Color(_tint.r, _tint.g, _tint.b, 0.88 * presence)
	queue_redraw()


func _draw() -> void:
	# Les débris aspirés : ils tournent vite et bas, dans le sens du shader.
	var presence := clampf(_left / FALL, 0.0, 1.0)
	for i in _motes.size():
		var seed_angle: Vector2 = _motes[i]
		var angle := seed_angle.x + _time * 5.0 * seed_angle.y
		var radius := tile_size * (0.35 + 0.32 * sin(_time * 2.0 + seed_angle.x))
		var height := -tile_size * (0.15 + 0.75 * fposmod(_time * seed_angle.y
			+ seed_angle.x * 0.4, 1.0))
		var at := Vector2(cos(angle) * radius, sin(angle) * radius * 0.35 + height)
		draw_circle(at, tile_size * 0.055,
			Color(_tint.r, _tint.g, _tint.b, 0.55 * presence))
