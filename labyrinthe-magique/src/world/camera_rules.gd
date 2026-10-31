class_name CameraRules
extends RefCounted

## Tout ce qui se DÉDUIT de la caméra, sans un seul nœud : le test de lisibilité
## vérifie ces chiffres en headless, avant qu'aucune image ne soit rendue.
##
## La caméra ne tourne JAMAIS. Le haut de l'écran reste le nord de la grille :
## le manche, le clavier et le joueur n'ont donc rien à réapprendre.

## Inclinaison depuis la verticale. Le dessin des personnages est vu de dessus :
## au-delà d'une quarantaine de degrés, ils ne sont plus cohérents avec le décor.
const TILT_DEGREES := 34.0
## Champ vertical étroit : la perspective se voit sans déformer les bords.
const FOV_DEGREES := 28.0
## Rangées de sol visibles au centre de l'écran.
const VIEW_ROWS := 12.0
## La perspective montre plus de sol en haut de l'écran qu'en bas : le cadre vise
## donc un peu au sud du mage, pour voir venir par le bas autant que dans le jeu 2D.
const AIM_SOUTH := 0.5
## Hauteur des haies, en cases.
const WALL_HEIGHT := 0.5


static func tilt() -> float:
	return deg_to_rad(TILT_DEGREES)


## Distance caméra -> point visé, pour montrer VIEW_ROWS rangées au centre.
static func distance() -> float:
	return VIEW_ROWS * cos(tilt()) / (2.0 * tan(deg_to_rad(FOV_DEGREES) * 0.5))


## Du point visé vers la caméra : elle est au sud de sa cible, et au-dessus.
static func offset() -> Vector3:
	return Vector3(0.0, cos(tilt()), sin(tilt())) * distance()


## Le « haut » du plan des sprites, en coordonnées du monde. Un sprite tourné
## vers la caméra ne monte pas tout droit : il monte vers le nord.
static func up() -> Vector3:
	return Vector3(0.0, sin(tilt()), -cos(tilt()))


## L'angle le plus rasant, depuis la verticale : celui du haut de l'écran.
static func worst_ray_angle() -> float:
	return tilt() + deg_to_rad(FOV_DEGREES) * 0.5


static func _height() -> float:
	return distance() * cos(tilt())


## Rangées de sol visibles AU NORD de la cible : la perspective en montre davantage
## que dans le jeu 2D, c'est donc l'autre côté qui borne ce qu'on voit venir.
static func rows_north() -> float:
	return _height() * tan(worst_ray_angle()) - distance() * sin(tilt()) - AIM_SOUTH


## Rangées de sol visibles au sud de la cible.
static func rows_south() -> float:
	return distance() * sin(tilt()) - _height() * tan(tilt() - deg_to_rad(FOV_DEGREES) * 0.5) + AIM_SOUTH


## Longueur de sol masquée derrière une haie, au pire endroit de l'écran.
static func worst_hidden_floor() -> float:
	return WALL_HEIGHT * tan(worst_ray_angle())


## Ce qu'un dessin DEBOUT doit gagner en hauteur une fois couché sur le sol : la vue
## inclinée l'écrase d'autant. Sans ça, tous les personnages paraissent tassés.
static func stand_scale() -> float:
	return 1.0 / cos(tilt())


## Le rectangle de sol vu par la caméra, autour du point visé, en cases. C'est au
## bord haut que la perspective est la plus large : c'est lui qui donne la largeur.
static func footprint(rows: float, aspect: float) -> Rect2:
	var half_fov := deg_to_rad(FOV_DEGREES) * 0.5
	var range_to_aim := rows * cos(tilt()) / (2.0 * tan(half_fov))
	var height := range_to_aim * cos(tilt())
	var behind := range_to_aim * sin(tilt())
	var north := height * tan(tilt() + half_fov) - behind
	var south := behind - height * tan(tilt() - half_fov)
	var depth_at_top := height / cos(tilt() + half_fov) * cos(half_fov)
	var half_width := depth_at_top * tan(half_fov) * aspect
	return Rect2(-half_width, -north, half_width * 2.0, north + south)
