class_name Compass
extends Node2D

## Petite flèche qui tourne autour du mage et pointe la gemme la plus proche.
##
## Elle donne une DIRECTION, jamais un chemin. La gemme visée est choisie à la
## distance de chemin réelle (une gemme à trois pas derrière une haie n'est pas
## « proche »), mais la flèche, elle, pointe à vol d'oiseau : au joueur de
## trouver par où passer. Une flèche qui indiquerait le prochain virage
## supprimerait le labyrinthe du jeu.

const TEXTURE := preload("res://assets/sprites/compass_arrow.png")
## Distance de la flèche au mage, en cases. Depuis que le mage est dessiné sur
## près de deux cases de haut, 1,05 posait la flèche en plein sur sa poitrine.
const ORBIT_TILES := 1.55

@onready var sprite: Sprite2D = $Sprite2D

var tile_size: int = 32


func setup(p_tile_size: int) -> void:
	tile_size = p_tile_size
	sprite.texture = TEXTURE
	var factor := (tile_size * 0.46) / float(TEXTURE.get_height())
	sprite.scale = Vector2(factor, factor)
	visible = false


func point_to(origin: Vector2, target: Vector2, tint: Color) -> void:
	var offset := target - origin
	if offset.length() < tile_size * 0.9:
		visible = false
		return
	visible = true
	var angle := offset.angle()
	position = origin + Vector2.RIGHT.rotated(angle) * tile_size * ORBIT_TILES
	sprite.rotation = angle
	sprite.modulate = tint


func clear() -> void:
	visible = false
