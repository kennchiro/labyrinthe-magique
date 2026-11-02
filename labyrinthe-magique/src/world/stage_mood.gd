class_name StageMood
extends RefCounted

## L'éclairage de chaque stage en volume.
##
## Les planches vont du presque noir (Sanctuaire : sol à 0,16) au presque blanc
## (Montagnes : sol à 0,95). Une même lumière brûlait les unes et noyait les autres.
## On écrit donc ici la luminosité VOULUE : `MazeView3D` mesure la planche et en déduit
## sa teinte. Une planche redessinée garde sa place dans l'image sans retouche.
##
## Les couleurs restent légères : la lumière pose une heure et un lieu, elle ne doit pas
## repeindre le dessin. Le stage 1 est la référence, réglée sur l'image cible.

var sky: Color
var ambient: Color
var moon: Color
## Reflet teinté du sol, indépendant de sa luminosité.
var floor_hue: Color
var floor_luma: float
var wall_luma: float
## Force du vent dans les haies. 0 : rien ne bouge.
var wind := 0.0
## Part de lumière retirée au cœur des nappes qui passent. 0 : pas de nappes.
var cloud_depth := 0.0
## Éclats qui scintillent sur les murs de cristal, de glace ou d'or.
var sparkle := 0.0
## Lueur des éclairs lointains, rares et douces : un flash franc gênerait la lecture.
var flash := 0.0
## Ce qui court sur le sol : sable, neige soufflée, reflets de l'eau.
var flow := 0.0
var flow_tint := Color.WHITE
## Étiré sur un axe, le dessin fait des traînées ; égal sur les deux, il fait des reflets.
var flow_scale := Vector2.ONE
var flow_speed := Vector2.ZERO

## Ce qui bouge sur chaque stage : un seul mouvement dominant, pour que chacun se reconnaisse.
const MOTION := {
	1: {"cloud": 0.24, "wind": 1.0},
	2: {"cloud": 0.34, "flash": 0.22},
	3: {"cloud": 0.12, "flow": 0.16, "flow_tint": Color(1.0, 0.72, 0.38),
		"flow_scale": Vector2(0.10, 0.42), "flow_speed": Vector2(0.050, 0.008)},
	4: {"cloud": 0.14, "flow": 0.14, "flow_tint": Color(0.55, 0.85, 1.0),
		"flow_scale": Vector2(0.21, 0.21), "flow_speed": Vector2(0.018, 0.012)},
	5: {"cloud": 0.16, "sparkle": 0.9},
	6: {"cloud": 0.12, "sparkle": 0.45, "flow": 0.16, "flow_tint": Color(0.86, 0.94, 1.0),
		"flow_scale": Vector2(0.08, 0.36), "flow_speed": Vector2(-0.060, 0.012)},
	7: {"cloud": 0.32, "wind": 0.8},
	8: {"cloud": 0.20},
	9: {"cloud": 0.28, "sparkle": 0.35},
	10: {"cloud": 0.20, "sparkle": 0.30},
}


func _init(p_sky: Color, p_ambient: Color, p_moon: Color, p_floor_hue: Color,
		p_floor_luma: float, p_wall_luma: float) -> void:
	sky = p_sky
	ambient = p_ambient
	moon = p_moon
	floor_hue = p_floor_hue
	floor_luma = p_floor_luma
	wall_luma = p_wall_luma


static func of(stage: int) -> StageMood:
	var mood := _lit(stage)
	var moving: Dictionary = MOTION.get(stage, MOTION[1])
	mood.cloud_depth = moving["cloud"]
	mood.wind = moving.get("wind", 0.0)
	mood.sparkle = moving.get("sparkle", 0.0)
	mood.flash = moving.get("flash", 0.0)
	mood.flow = moving.get("flow", 0.0)
	mood.flow_tint = moving.get("flow_tint", Color.WHITE)
	mood.flow_scale = moving.get("flow_scale", Vector2.ONE)
	mood.flow_speed = moving.get("flow_speed", Vector2.ZERO)
	return mood


static func _lit(stage: int) -> StageMood:
	match stage:
		2:   # Canyon de la Foudre : ciel d'orage
			return StageMood.new(Color(0.03, 0.03, 0.07), Color(0.55, 0.60, 0.80), Color(0.80, 0.85, 1.00),
				Color(0.97, 0.98, 1.08), 0.20, 0.42)
		3:   # Dunes de Feu : fin de journée
			return StageMood.new(Color(0.08, 0.04, 0.02), Color(0.72, 0.62, 0.55), Color(1.00, 0.85, 0.65),
				Color(1.05, 0.98, 0.92), 0.26, 0.55)
		4:   # Rivages Océaniques : crépuscule clair
			return StageMood.new(Color(0.03, 0.05, 0.08), Color(0.60, 0.70, 0.78), Color(0.95, 0.95, 0.90),
				Color(0.96, 1.00, 1.06), 0.30, 0.50)
		5:   # Cavernes de Cristal : sous terre
			return StageMood.new(Color(0.02, 0.01, 0.05), Color(0.55, 0.50, 0.72), Color(0.75, 0.65, 1.00),
				Color(1.00, 0.97, 1.10), 0.15, 0.40)
		6:   # Montagnes Glacées : froid et clair
			return StageMood.new(Color(0.04, 0.06, 0.10), Color(0.60, 0.70, 0.85), Color(0.85, 0.93, 1.00),
				Color(0.94, 1.00, 1.10), 0.30, 0.55)
		7:   # Bois d'Épine : plus sombre que la Forêt
			return StageMood.new(Color(0.02, 0.03, 0.03), Color(0.50, 0.62, 0.60), Color(0.75, 0.92, 0.80),
				Color(0.97, 1.00, 1.05), 0.15, 0.33)
		8:   # Ruines Anciennes : lumière dorée
			return StageMood.new(Color(0.05, 0.04, 0.03), Color(0.68, 0.64, 0.58), Color(1.00, 0.90, 0.72),
				Color(1.03, 1.00, 0.95), 0.20, 0.45)
		9:   # Sanctuaire Déchu : violet éteint
			return StageMood.new(Color(0.02, 0.01, 0.04), Color(0.55, 0.50, 0.70), Color(0.80, 0.72, 0.95),
				Color(1.00, 0.97, 1.08), 0.13, 0.40)
		10:  # Château du Ciel : le seul stage en plein jour
			return StageMood.new(Color(0.10, 0.13, 0.20), Color(0.72, 0.76, 0.85), Color(1.00, 0.98, 0.90),
				Color(1.00, 1.00, 1.02), 0.38, 0.62)
	# Stage 1, la Forêt : nuit froide, et tout stage inconnu par défaut.
	return StageMood.new(Color(0.02, 0.03, 0.05), Color(0.52, 0.66, 0.72), Color(0.78, 0.96, 0.86),
		Color(0.97, 1.00, 1.13), 0.183, 0.393)
