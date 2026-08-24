class_name WarpTrail
extends Node2D

## La traînée de braises laissée par une translation.
##
## C'est la pièce qui manquait au sort de fuite. Sans elle, le mage disparaît
## d'un point et reparaît à un autre : le joueur voit DEUX événements sans
## rapport, et sur un écran chargé il perd son propre personnage. La traînée
## relie les deux — elle dit par où il est passé, et donc qu'il s'agit bien de
## lui.
##
## Les braises naissent SUR LE TRAJET (une forme d'émission par points, une par
## case traversée) et dérivent dans le sens du déplacement. C'est ce qui donne
## le sens de la fuite : des braises immobiles diraient « quelque chose a brûlé
## ici », des braises qui filent disent « il est parti par là ».

const LIFETIME := 0.55


func setup(points: PackedVector2Array, tile_size: int, tint: Color) -> void:
	if points.size() < 2:
		queue_free()
		return
	position = points[0]
	var travel := (points[points.size() - 1] - points[0])
	var direction := travel.normalized() if travel.length() > 0.001 else Vector2.RIGHT

	# La traînée doit se voir SUR TOUTE SA LONGUEUR, dans un labyrinthe déjà
	# chargé de décor. Une première version, deux fois plus maigre, se perdait
	# dans les feuillages : on ne distinguait plus le chemin du mage des
	# champignons du sol.
	var embers := FxTextures.flame_emitter(
		clampi(points.size() * 18, 40, 200), LIFETIME, float(tile_size) * 0.62,
		Color(minf(1.0, tint.r + 0.35), minf(1.0, tint.g + 0.25),
			minf(1.0, tint.b + 0.12), 1.0),
		Color(tint.r * 0.7, tint.g * 0.32, tint.b * 0.16, 0.0), 46.0, 55.0)
	add_child(embers)
	embers.one_shot = true
	# Pas d'explosivité totale : les braises s'allument le long du trajet plutôt
	# que toutes à la fois, ce qui laisse lire le SENS de la course.
	embers.explosiveness = 0.35
	embers.local_coords = false
	embers.direction = direction
	embers.initial_velocity_min = float(tile_size) * 0.2
	embers.initial_velocity_max = float(tile_size) * 1.1

	# Une position d'émission par case traversée, en coordonnées LOCALES.
	var spots := PackedVector2Array()
	for point in points:
		spots.append(point - points[0])
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINTS
	embers.emission_points = spots
	embers.emitting = true


func _ready() -> void:
	# La traînée se retire d'elle-même : elle n'a rien à surveiller ensuite.
	var timer := get_tree().create_timer(LIFETIME * 2.0)
	timer.timeout.connect(queue_free)
