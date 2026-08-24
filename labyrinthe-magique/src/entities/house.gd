class_name House
extends Node2D

## La maison au centre du labyrinthe : l'objectif.
##
## Sa porte est SCELLÉE tant que toutes les gemmes n'ont pas été ramassées.
## L'état se lit sans un mot : maison éteinte et bleutée, sceau flottant au-dessus
## du toit portant une pastille par gemme manquante — dans la couleur exacte de
## la gemme à trouver. Quand la dernière tombe, le sceau se brise, les fenêtres
## s'allument et la maison reprend ses couleurs.

const TEXTURE := preload("res://assets/sprites/house.png")
const PROPS_PATH := "res://assets/stages/props/"
## Encombrement visé, en cases. Un peu plus large que la clairière 3x3 : la
## maison doit déborder sur les haies, sinon elle a l'air posée dans un trou.
##
## DEUX bornes et non une seule, parce que les monuments n'ont pas tous la même
## silhouette : les anciens étaient larges (274x234), les îlots flottants de
## `maison_stage.png` sont HAUTS (280x460). Mis à l'échelle sur la seule
## largeur, un îlot ferait six cases de haut et avalerait le carrefour. On
## retient donc le facteur le plus contraignant des deux.
const TARGET_WIDTH_TILES := 3.8
const TARGET_HEIGHT_TILES := 4.6
## Part de la hauteur remontée au-dessus de l'origine. Les îlots PENDENT sous
## leur plateforme : les centrer poserait le portail hors de la clairière et
## laisserait la roche flotter sur le couloir du bas.
const ANCHOR_LIFT := 0.30

## Teinte de la maison scellée : froide et sombre. Une maison verrouillée qui
## reste chaleureuse invite à s'en approcher — exactement le contresens à éviter.
const TINT_LOCKED := Color(0.58, 0.66, 0.86)
const TINT_OPEN := Color(1.0, 1.0, 1.0)

@onready var sprite: Sprite2D = $Sprite2D

var tile_size: int = 32
var locked := true

## Couleurs des gemmes qui manquent encore, dans l'ordre du niveau.
var _missing: Array[Color] = []
var _time := 0.0
## Hauteur du sceau, mesurée sur le sprite (voir setup).
var _seal_y := -64.0
## Monte de 0 à 1 quand la porte s'ouvre : sert au flash d'ouverture.
var _unseal := 0.0


## Le MONUMENT du stage remplace la maisonnette quand sa planche en fournit un :
## l'autel à gemme de la forêt, le temple de feu des dunes, le château du ciel.
## Une maisonnette de bois posée sur la banquise ne racontait rien.
##
## Le stage 9 n'a pas de planche : il garde la maisonnette, et c'est le bon
## repli — mieux vaut un décor de forêt qu'un trou au centre du labyrinthe.
func setup(p_tile_size: int, stage: int = 0) -> void:
	tile_size = p_tile_size
	var texture := TEXTURE
	var path := PROPS_PATH + "stage_%d/maison/maison_0.png" % stage
	if stage > 0 and ResourceLoader.exists(path):
		var loaded: Texture2D = load(path)
		if loaded != null:
			texture = loaded
	sprite.texture = texture
	var factor := minf((tile_size * TARGET_WIDTH_TILES) / float(texture.get_width()),
		(tile_size * TARGET_HEIGHT_TILES) / float(texture.get_height()))
	sprite.scale = Vector2(factor, factor)
	sprite.offset = Vector2(0.0, -texture.get_height() * ANCHOR_LIFT)
	# Le sceau se pose juste au-dessus du SOMMET RÉEL du sprite, mesuré ici, et
	# non à une hauteur fixe : les monuments plats et les îlots flottants n'ont
	# pas la même silhouette, et une constante qui allait aux premiers plantait
	# le sceau en plein milieu des seconds.
	_seal_y = (sprite.offset.y - texture.get_height() * 0.5) * factor - tile_size * 0.5
	sprite.modulate = TINT_LOCKED if locked else TINT_OPEN
	queue_redraw()


## Appelée à chaque gemme ramassée. `missing` est vide -> la porte s'ouvre.
func set_seal(missing: Array[Color]) -> void:
	_missing = missing
	var now_locked := not missing.is_empty()
	if locked and not now_locked:
		_unseal = 1.0     # déclenche l'éclat d'ouverture
	locked = now_locked
	if sprite != null:
		sprite.modulate = TINT_LOCKED if locked else TINT_OPEN
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	_unseal = maxf(0.0, _unseal - delta * 0.8)
	queue_redraw()


func _draw() -> void:
	var s := float(tile_size)
	if locked:
		_draw_seal(s)
		return

	# Halo chaud des fenêtres, dessiné sous le sprite parce que le _draw du nœud
	# passe avant celui de ses enfants.
	draw_circle(Vector2.ZERO, s * 2.6, Color(1.0, 0.78, 0.35, 0.05))
	draw_circle(Vector2.ZERO, s * 1.7, Color(1.0, 0.78, 0.35, 0.07))
	draw_circle(Vector2.ZERO, s * 1.0, Color(1.0, 0.82, 0.42, 0.07))
	if _unseal > 0.0:
		# Onde d'ouverture : elle part du seuil et s'élargit une seconde durant.
		var wave := 1.0 - _unseal
		draw_arc(Vector2.ZERO, s * (0.6 + 3.4 * wave), 0.0, TAU, 48,
			Color(1.0, 0.86, 0.48, _unseal * 0.85), 3.0 + 5.0 * _unseal)


## Sceau : un anneau au-dessus du toit, une pastille par gemme manquante.
func _draw_seal(s: float) -> void:
	var centre := Vector2(0.0, _seal_y)
	var pulse := 0.5 + 0.5 * sin(_time * 2.4)
	var radius := s * 0.52

	draw_circle(centre, radius * 1.35, Color(0.05, 0.07, 0.14, 0.72))
	draw_arc(centre, radius * 1.35, 0.0, TAU, 40,
		Color(0.55, 0.68, 1.0, 0.35 + 0.25 * pulse), 2.0)

	var count := _missing.size()
	if count == 0:
		return
	for i in count:
		# Une seule gemme manquante : au centre, sinon l'anneau à un point
		# ressemble à un satellite en orbite autour de rien.
		var angle := -PI * 0.5 + TAU * float(i) / float(count)
		var offset := Vector2.ZERO if count == 1 else Vector2(cos(angle), sin(angle)) * radius * 0.72
		var color: Color = _missing[i]
		draw_circle(centre + offset, s * (0.15 + 0.02 * pulse), Color(color.r, color.g, color.b, 0.95))
		draw_circle(centre + offset, s * 0.26, Color(color.r, color.g, color.b, 0.16))
