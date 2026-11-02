class_name Ambience
extends CanvasLayer

## L'AMBIANCE DE LA CARTE : ce qui sépare un lieu d'une planche de tuiles.
##
## Trois couches, et chacune répond à un défaut mesuré en capture :
##
##   · la VIGNETTE — le labyrinthe était éclairé uniformément d'un bord à
##     l'autre, ce qui se lit comme une carte et non comme un endroit où l'on
##     est. Elle prend la teinte du stage, donc chaque biome a son air ;
##   · le HALO DU MAGE — le sol sous ses pieds était exactement celui de vingt
##     cases plus loin. C'est le signal le plus fort qu'on puisse donner : le
##     décor RÉAGIT au personnage ;
##   · la POUSSIÈRE — rien ne bougeait à l'écran sauf les personnages. Quelques
##     motes qui dérivent suffisent à faire respirer l'air.
##
## Tout est en espace ÉCRAN, sur un CanvasLayer : la vignette ne doit pas suivre
## le labyrinthe, elle suit l'œil. Le halo, lui, reçoit la position du mage
## convertie en coordonnées d'écran par le Level.
##
## ⚠️ Aucun accès au tampon d'écran. Le renderer est `gl_compatibility` : y lire
## coûte une copie de l'écran par passe. Deux nappes en alpha ordinaire — l'une
## qui assombrit, l'autre qui éclaire — font le même travail pour rien.

const AMBIENCE_SHADER := preload("res://assets/shaders/ambience.gdshader")
const TORCH_SHADER := preload("res://assets/shaders/torchlight.gdshader")

## Nombre de motes. Assez pour que l'air ne soit pas vide, assez peu pour qu'on
## ne les compte pas — et c'est du CPUParticles2D, comme tout le reste du jeu :
## le rendu doit être identique sur mobile.
const MOTES := 44
## Largeur de `SoftTextures.glow()`, pour parler de tailles en pixels.
const GLOW_SIDE := 128.0
## L'air de chaque stage : tailles en pixels d'écran, vitesses en pixels par seconde.
const AIR := {
	1: {"amount": 26, "life": 8.0, "way": Vector2(1, 0), "spread": 180.0, "speed": Vector2(5, 20),
		"size": Vector2(7, 16), "colour": Color(0.82, 1.0, 0.42, 0.85), "blink": true},
	2: {"amount": 24, "life": 3.5, "way": Vector2(1, 0), "spread": 180.0, "speed": Vector2(8, 36),
		"size": Vector2(4, 9), "colour": Color(0.62, 0.78, 1.0, 0.85), "blink": true},
	3: {"amount": 30, "life": 6.0, "way": Vector2(0.3, -1), "spread": 28.0, "speed": Vector2(14, 34),
		"size": Vector2(4, 9), "colour": Color(1.0, 0.56, 0.20, 0.85)},
	4: {"amount": 24, "life": 8.0, "way": Vector2(0.2, -1), "spread": 35.0, "speed": Vector2(6, 16),
		"size": Vector2(6, 13), "colour": Color(0.70, 0.92, 1.0, 0.50)},
	5: {"amount": 28, "life": 9.0, "way": Vector2(0, -1), "spread": 180.0, "speed": Vector2(3, 12),
		"size": Vector2(5, 12), "colour": Color(0.72, 0.60, 1.0, 0.75), "blink": true},
	6: {"amount": 60, "life": 8.0, "way": Vector2(-0.45, 1), "spread": 14.0, "speed": Vector2(26, 58),
		"size": Vector2(4, 11), "colour": Color(1.0, 1.0, 1.0, 0.80)},
	7: {"amount": 26, "life": 9.0, "way": Vector2(0.3, -1), "spread": 70.0, "speed": Vector2(4, 13),
		"size": Vector2(5, 11), "colour": Color(0.72, 0.95, 0.70, 0.60), "blink": true},
	8: {"amount": 34, "life": 9.0, "way": Vector2(0.5, -0.5), "spread": 50.0, "speed": Vector2(4, 14),
		"size": Vector2(4, 9), "colour": Color(1.0, 0.86, 0.52, 0.65)},
	9: {"amount": 30, "life": 7.0, "way": Vector2(0, -1), "spread": 22.0, "speed": Vector2(10, 24),
		"size": Vector2(4, 10), "colour": Color(0.76, 0.46, 1.0, 0.80)},
	10: {"amount": 26, "life": 9.0, "way": Vector2(0.4, -0.3), "spread": 40.0, "speed": Vector2(6, 18),
		"size": Vector2(5, 12), "colour": Color(1.0, 0.98, 0.84, 0.70), "blink": true},
}

var _veil: ColorRect = null
var _torch: ColorRect = null
var _motes: CPUParticles2D = null
var _veil_material: ShaderMaterial = null
var _torch_material: ShaderMaterial = null


func _ready() -> void:
	# Au-dessus du labyrinthe et des entités, SOUS l'interface : une vignette
	# qui assombrirait les boutons se lirait comme un bug d'affichage.
	layer = 1
	_veil = _sheet(AMBIENCE_SHADER)
	_veil_material = _veil.material
	_torch = _sheet(TORCH_SHADER)
	_torch_material = _torch.material
	# Le halo s'AJOUTE, la vignette se POSE. La composition additive du halo est
	# déclarée dans son shader (`render_mode blend_add`) : sur un ShaderMaterial,
	# un CanvasItemMaterial en `next_pass` ajouterait une passe sans rien changer
	# à la composition de la première.
	_build_motes()
	get_viewport().size_changed.connect(_fit)
	_fit()


func _sheet(shader: Shader) -> ColorRect:
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = shader
	rect.material = material
	add_child(rect)
	return rect


## La teinte de l'air, prise sur le SOL du stage. Un biome de sable et un biome
## de cristal n'ont pas le même air, et la couleur du sol est ce qui le dit le
## plus sûrement — c'est déjà elle qui teinte les tuiles.
func set_stage_tint(floor_tint: Color) -> void:
	if _veil_material == null:
		return
	# Assombrie et refroidie : la vignette est une OMBRE colorée, pas un filtre
	# de couleur. Prise telle quelle, elle repeignait le sable en sable.
	# Assombrie ET refroidie. Une vignette qui reprend la couleur du sol repeint
	# le sable en sable : elle aplatit au lieu de creuser. Le bleu qui reste dit
	# « ombre » quel que soit le biome.
	var air := Color(floor_tint.r * 0.10, floor_tint.g * 0.13, floor_tint.b * 0.26)
	_veil_material.set_shader_parameter("tint", air)


## Position du mage à l'écran, en fraction du viewport. Le Level la calcule : il
## est le seul à connaître la caméra.
func set_focus(screen_uv: Vector2) -> void:
	if _torch_material != null:
		_torch_material.set_shader_parameter("focus", screen_uv)


func _build_motes() -> void:
	_motes = CPUParticles2D.new()
	_motes.amount = MOTES
	_motes.lifetime = 9.0
	_motes.preprocess = 4.0
	_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_motes.direction = Vector2(0.2, -1.0)
	_motes.spread = 40.0
	_motes.gravity = Vector2(0.0, -3.0)
	_motes.initial_velocity_min = 4.0
	_motes.initial_velocity_max = 14.0
	_motes.scale_amount_min = 1.0
	_motes.scale_amount_max = 2.6
	_motes.color = Color(1.0, 0.96, 0.82, 0.55)
	_motes.color_ramp = _fade()
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_motes.material = additive
	add_child(_motes)


## L'air de chaque stage. Assez gros pour se lire comme de la neige ou des lucioles, et
## non comme des pixels morts. Rejoué à chaque niveau : le stage d'avant ne doit rien laisser.
func set_stage(stage: int) -> void:
	if _motes == null:
		return
	var air: Dictionary = AIR.get(stage, AIR[1])
	_motes.amount = air["amount"]
	_motes.lifetime = air["life"]
	_motes.texture = SoftTextures.glow()
	_motes.direction = air["way"]
	_motes.spread = air["spread"]
	_motes.gravity = Vector2.ZERO
	_motes.initial_velocity_min = air["speed"].x
	_motes.initial_velocity_max = air["speed"].y
	_motes.scale_amount_min = air["size"].x / GLOW_SIDE
	_motes.scale_amount_max = air["size"].y / GLOW_SIDE
	_motes.color = air["colour"]
	_motes.color_ramp = _pulse() if air.get("blink", false) else _fade()


## Une mote naît invisible, se montre, et s'éteint : apparaître et disparaître d'un coup
## ferait clignoter des points sur le décor.
func _fade() -> Gradient:
	var fade := Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 0))
	fade.set_color(1, Color(1, 1, 1, 0))
	fade.add_point(0.5, Color(1, 1, 1, 1))
	return fade


func _pulse() -> Gradient:
	var pulse := Gradient.new()
	pulse.offsets = [0.0, 0.2, 0.38, 0.56, 0.78, 1.0]
	pulse.colors = [Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 0.2),
		Color(1, 1, 1, 1), Color(1, 1, 1, 0.3), Color(1, 1, 1, 0)]
	return pulse


func _fit() -> void:
	var span := Vector2(get_viewport().get_visible_rect().size)
	for rect in [_veil, _torch]:
		if rect != null:
			rect.position = Vector2.ZERO
			rect.size = span
	if _motes != null:
		# ⚠️ ELLES NAISSENT PARTOUT, pas au bas de l'écran. Émises depuis le bord
		# inférieur, elles mettaient neuf secondes à monter et l'écran restait
		# vide au-dessus du mage — c'est-à-dire là où l'on regarde. Un pavé
		# d'émission plein écran les répartit d'emblée.
		_motes.position = Vector2(span.x * 0.5, span.y * 0.5)
		_motes.emission_rect_extents = Vector2(span.x * 0.52, span.y * 0.52)
