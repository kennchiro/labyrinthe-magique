class_name House
extends Node2D

## La maison au centre du labyrinthe : l'objectif.
##
## Sa porte est SCELLÉE tant que toutes les gemmes n'ont pas été ramassées.
## L'état se lit sans un mot : maison éteinte et bleutée tant qu'il en manque,
## puis les fenêtres s'allument et elle reprend ses couleurs.
##
## ⚠️ IL Y AVAIT UN SCEAU au-dessus du toit — un anneau portant une pastille par
## gemme manquante, dans la couleur exacte de la gemme à trouver. Retiré : le
## bandeau d'information affiche DÉJÀ cette collection, une pastille par gemme du
## niveau, éteinte quand elle est ramassée. Deux compteurs de la même chose, dont
## l'un flottait au milieu du décor.
##
## Ce qui reste dit la même chose sans le répéter : la TEINTE froide de la maison
## scellée, et l'onde chaude qui s'ouvre quand la dernière gemme tombe.

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

var _time := 0.0
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
	sprite.modulate = TINT_LOCKED if locked else TINT_OPEN
	queue_redraw()


## Appelée à chaque gemme ramassée. Zéro manquante -> la porte s'ouvre.
##
## Elle ne reçoit plus la LISTE des gemmes mais leur nombre : depuis que le sceau
## a disparu, leurs couleurs ne servaient plus à rien ici — le bandeau les
## affiche, la maison ne fait que s'ouvrir ou non.
func set_locked(missing: int) -> void:
	var now_locked := missing > 0
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
