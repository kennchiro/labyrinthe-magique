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
## Altitude de l'îlot, en cases. En dessous de 0,5, sa roche passerait sous le sol.
const PANEL_LIFT := 0.8
## La perspective fait glisser vers le nord ce qui s'élève, loin du centre de l'écran.
## Ce recul garde le portail au-dessus de sa clairière, là où le mage entre.
const PANEL_SOUTH := 0.7
const BOB_HEIGHT := 0.06
const BOB_SPEED := 1.6
const PORTAL_SHADER := preload("res://assets/shaders/monument_portal.gdshader")
## Portail de chaque îlot, en pixels de son image : centre de la spirale, puis rayons
## de l'ellipse. Relevés à la main sur `assets/stages/props/stage_N/maison/maison_0.png`.
const PORTALS := {
	1: Vector4(126, 200, 26, 36),
	2: Vector4(130, 188, 28, 40),
	3: Vector4(145, 135, 26, 40),
	4: Vector4(129, 158, 28, 38),
	5: Vector4(143, 188, 30, 40),
	6: Vector4(163, 188, 28, 44),
	7: Vector4(144, 175, 26, 38),
	8: Vector4(152, 170, 28, 42),
	9: Vector4(152, 170, 34, 46),
	10: Vector4(166, 195, 24, 34),
}
## Tours par seconde, en radians. Assez lent pour rester du décor.
const PORTAL_SPIN := 0.9
const PORTAL_OPENING_SPEED := 0.8
const PORTAL_SEALED := Color(0.26, 0.30, 0.42)
const PORTAL_PRIORITY := 3

@onready var sprite: Sprite2D = $Sprite2D

var tile_size: int = 32
var locked := true

var _time := 0.0
## Monte de 0 à 1 quand la porte s'ouvre : sert au flash d'ouverture.
var _unseal := 0.0
## L'îlot debout, quand la vue en volume en a dressé un : il remplace le sprite couché.
var _panel: Sprite3D = null
var _stage := 0
var _portal_material: ShaderMaterial = null
var _portal_phase := 0.0
var _portal_open := 0.0


## Les cases dont le décor passerait devant l'îlot : tout ce qui est peint au sol est
## dessiné après lui, et il couvre le sol jusqu'à cinq cases au nord de son centre.
static func hides(cell: Vector2i, centre: Vector2i) -> bool:
	var offset := cell - centre
	return absi(offset.x) <= 2 and offset.y >= -6 and offset.y <= -2


## Passe le dessin à la scène 3D. Le sprite reste pour ses mesures, mais ne se montre plus.
func stand_on(panel: Sprite3D) -> void:
	_panel = panel
	panel.texture = sprite.texture
	panel.pixel_size = sprite.scale.x / float(tile_size)
	# Un Sprite3D compte ses pixels vers le haut, un Sprite2D vers le bas.
	panel.offset = -sprite.offset
	panel.modulate = sprite.modulate
	sprite.visible = false
	if PORTALS.has(_stage) and sprite.texture != TEXTURE:
		_add_portal(panel, PORTALS[_stage])


## Un quad posé sur l'ouverture, enfant de l'îlot : il flotte avec lui.
func _add_portal(panel: Sprite3D, portal: Vector4) -> void:
	var size := panel.texture.get_size()
	_portal_material = ShaderMaterial.new()
	_portal_material.shader = PORTAL_SHADER
	_portal_material.render_priority = PORTAL_PRIORITY
	_portal_material.set_shader_parameter("island", panel.texture)
	_portal_material.set_shader_parameter("centre", Vector2(portal.x, portal.y) / size)
	_portal_material.set_shader_parameter("radii", Vector2(portal.z, portal.w) / size)
	_portal_material.set_shader_parameter("sealed", Vector3(PORTAL_SEALED.r, PORTAL_SEALED.g, PORTAL_SEALED.b))
	_portal_open = 0.0 if locked else 1.0
	_portal_material.set_shader_parameter("open", _portal_open)
	var quad := QuadMesh.new()
	quad.size = Vector2(portal.z, portal.w) * 2.0 * panel.pixel_size
	var mesh := MeshInstance3D.new()
	mesh.mesh = quad
	mesh.material_override = _portal_material
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.position = Vector3(portal.x - size.x * 0.5 + panel.offset.x,
		size.y * 0.5 - portal.y + panel.offset.y, 0.01) * panel.pixel_size
	panel.add_child(mesh)


## Le MONUMENT du stage remplace la maisonnette quand sa planche en fournit un :
## l'autel à gemme de la forêt, le temple de feu des dunes, le château du ciel.
## Une maisonnette de bois posée sur la banquise ne racontait rien.
##
## Le stage 9 n'a pas de planche : il garde la maisonnette, et c'est le bon
## repli — mieux vaut un décor de forêt qu'un trou au centre du labyrinthe.
func setup(p_tile_size: int, stage: int = 0) -> void:
	tile_size = p_tile_size
	_stage = stage
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
		if is_instance_valid(_panel):
			_panel.modulate = sprite.modulate
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	_unseal = maxf(0.0, _unseal - delta * 0.8)
	if is_instance_valid(_panel):
		_panel.position.y = PANEL_LIFT + sin(_time * BOB_SPEED) * BOB_HEIGHT
		_turn_portal(delta)
	queue_redraw()


## Scellé, le portail ne tourne pas : ce mouvement est le signe que la porte est ouverte.
func _turn_portal(delta: float) -> void:
	if _portal_material == null or (locked and _portal_open == 0.0):
		return
	_portal_open = move_toward(_portal_open, 0.0 if locked else 1.0, delta * PORTAL_OPENING_SPEED)
	_portal_phase = fmod(_portal_phase + delta * PORTAL_SPIN * _portal_open, TAU)
	_portal_material.set_shader_parameter("open", _portal_open)
	_portal_material.set_shader_parameter("phase", _portal_phase)


func _draw() -> void:
	var s := float(tile_size)
	if locked:
		return

	# Halo chaud des fenêtres, dessiné sous le sprite parce que le _draw du nœud
	# passe avant celui de ses enfants.
	draw_texture_rect(SoftTextures.glow(), Rect2(Vector2.ONE * -s * 3.0, Vector2.ONE * s * 6.0), false,
		Color(1.0, 0.78, 0.35, 0.28))
	if _unseal > 0.0:
		# Onde d'ouverture : elle part du seuil et s'élargit une seconde durant.
		var wave := 1.0 - _unseal
		draw_arc(Vector2.ZERO, s * (0.6 + 3.4 * wave), 0.0, TAU, 48,
			Color(1.0, 0.86, 0.48, _unseal * 0.85), 3.0 + 5.0 * _unseal)
