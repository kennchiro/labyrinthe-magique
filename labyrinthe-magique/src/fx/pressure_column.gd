class_name PressureColumn
extends Node2D

## La colonne de pression d'un geyser : l'eau jaillit du sol et retombe.
##
## Elle joue le rôle que le panache joue pour la boule de feu — dire de quel
## ÉLÉMENT vient le coup avant même d'en voir les dégâts. Mais elle raconte
## l'inverse : le feu se propage à l'horizontale, l'eau sous pression monte à la
## verticale puis retombe en pluie. C'est ce contraste qui distingue les deux
## ultimes autrement que par la couleur.
##
## Trois temps, parce qu'un jet d'eau réel en a trois : la POUSSÉE (une gerbe
## étroite et violente), la RETOMBÉE (des gouttes qui redescendent en s'écartant)
## et la NAPPE au sol.

const DURATION := 1.6


func setup(tile_size: int, radius_tiles: float, tint: Color) -> void:
	var reach := float(tile_size) * maxf(1.0, radius_tiles)

	# 1. LA POUSSÉE : étroite, très rapide, vers le haut. La gravité positive
	#    la fait retomber d'elle-même — on ne simule rien, on laisse tomber.
	var jet := FxTextures.flame_emitter(70, 1.1, float(tile_size) * 0.9,
		Color(minf(1.0, tint.r + 0.45), minf(1.0, tint.g + 0.3), 1.0, 0.85),
		Color(tint.r * 0.6, tint.g * 0.8, 1.0, 0.0), 220.0, 16.0)
	add_child(jet)
	jet.one_shot = true
	jet.explosiveness = 0.5
	jet.local_coords = false
	jet.direction = Vector2(0.0, -1.0)
	jet.initial_velocity_min = reach * 2.2
	jet.initial_velocity_max = reach * 4.0
	jet.emitting = true

	# 2. LA RETOMBÉE : plus large, plus lente, elle s'écarte en redescendant.
	var spray := FxTextures.flame_emitter(44, 1.4, float(tile_size) * 0.6,
		Color(1.0, 1.0, 1.0, 0.7), Color(tint.r, tint.g, tint.b, 0.0), 300.0, 46.0)
	add_child(spray)
	spray.one_shot = true
	spray.explosiveness = 0.35
	spray.local_coords = false
	spray.direction = Vector2(0.0, -1.0)
	spray.initial_velocity_min = reach * 0.9
	spray.initial_velocity_max = reach * 2.4
	spray.emitting = true

	# 3. LA NAPPE : l'eau qui s'étale au sol après le jet.
	var pool := FxTextures.flame_emitter(30, 0.8, float(tile_size) * 0.8,
		Color(minf(1.0, tint.r + 0.3), minf(1.0, tint.g + 0.2), 1.0, 0.6),
		Color(tint.r, tint.g, tint.b, 0.0), 8.0, 180.0)
	add_child(pool)
	pool.one_shot = true
	pool.explosiveness = 0.8
	pool.local_coords = false
	pool.initial_velocity_min = reach * 0.4
	pool.initial_velocity_max = reach * 1.5
	pool.emitting = true


func _ready() -> void:
	var timer := get_tree().create_timer(DURATION)
	timer.timeout.connect(queue_free)
