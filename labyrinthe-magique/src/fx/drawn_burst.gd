class_name DrawnBurst
extends Node2D

## UNE ANIMATION DESSINÉE POSÉE SUR UNE CASE — geyser, éclaboussure, frappe.
##
## Elle déroule ses images UNE fois sur la durée qu'on lui donne, sans tourner
## et sans boucler : ces dessins ont un HAUT et un BAS, et ils racontent une
## progression qui se termine.
##
## ⚠️ ELLE SE CALE SUR SON ANCRE, pas sur son centre. Le geyser jaillit du BAS
## de son image et l'éclair tombe du HAUT : centrer le dessin poserait l'effet
## une demi-case à côté de ce qu'il touche. L'ancre est relevée au découpage,
## sur la dernière image — celle où il ne reste que l'anneau au sol, dont le
## centre EST le point de contact.

@onready var body: Sprite2D = $Body

## LA FLUIDITÉ VIENT DU FONDU, pas du nombre d'images.
##
## Six images étalées sur une seconde font cinq images par seconde : un
## diaporama. On ne peut pas en dessiner plus — mais on peut faire se
## RECOUVRIR deux images consécutives, la suivante montant en opacité pendant
## que la précédente s'efface. L'œil recompose le mouvement, et une éruption de
## six images se lit comme une éruption continue.
##
## La taille suit le même chemin : elle enfle d'un cheveu entre deux images au
## lieu de sauter d'un cran.
var _blend: Sprite2D = null
## L'eau qui court dans la colonne, quand l'effet est liquide.
const FLOW := preload("res://assets/shaders/geyser_flow.gdshader")
var _flow: ShaderMaterial = null
var _rings := false

## LE MAGE DANS SON JET, et non derrière.
##
## Une colonne d'eau posée par-dessus le personnage l'EFFACE : pendant une
## seconde, le joueur ne sait plus où il est. Posée dessous, elle n'a plus
## aucune force — l'eau passerait derrière lui comme un décor.
##
## On la dédouble donc : une moitié DERRIÈRE, opaque, et une moitié DEVANT,
## translucide. Le mage se lit à travers, et l'effet l'enveloppe au lieu de le
## masquer. C'est le vieux truc des effets de transformation, et il ne coûte
## qu'un sprite de plus.
const FRONT_ALPHA := 0.45
const BEHIND_Z := -6
const FRONT_Z := 8

var _front: Sprite2D = null
var _frames: Array[Texture2D] = []
var _time := 0.0
var _total := 0.6
var _anchor := Vector2.ZERO
var _base_scale := Vector2.ONE


## `width_tiles` : largeur visée, en cases. On met à l'échelle sur la LARGEUR
## et non la hauteur — c'est l'empreinte au sol qui doit couvrir la zone, alors
## qu'une colonne d'eau ou un trait de foudre écraserait tout le reste si on
## calait sur leur hauteur.
## `liquid` : l'eau ONDULE dans le dessin et un anneau d'écume s'ouvre au sol.
## Voir `geyser_flow.gdshader`.
func setup(tile_size: int, width_tiles: float, duration: float,
		frames: Array, anchor: Vector2, wrap: bool = false,
		liquid: bool = false) -> void:
	_total = maxf(0.15, duration)
	for frame in frames:
		if frame != null:
			_frames.append(frame)
	var node: Sprite2D = get_node_or_null("Body")
	if node == null or _frames.is_empty():
		queue_free()
		return
	body = node
	body.texture = _frames[0]
	body.centered = false
	var factor := (tile_size * maxf(0.4, width_tiles)) / float(_frames[0].get_width())
	body.scale = Vector2(factor, factor)
	_base_scale = body.scale
	_anchor = anchor
	body.offset = -_anchor
	if liquid:
		_rings = true
		_flow = ShaderMaterial.new()
		_flow.shader = FLOW
		# Le shader est posé sur le NŒUD et non sur chaque sprite : les deux
		# images du fondu doivent onduler ENSEMBLE, sinon le fondu les fait
		# glisser l'une sur l'autre et l'eau tremble.
		self.material = _flow
	# L'image SUIVANTE, superposée : c'est elle qui fait le fondu.
	_blend = Sprite2D.new()
	_blend.centered = false
	_blend.offset = body.offset
	_blend.scale = body.scale
	_blend.modulate = Color(1, 1, 1, 0)
	add_child(_blend)
	if not wrap:
		return
	# La moitié DEVANT : même image, même calage, translucide et par-dessus.
	body.z_index = BEHIND_Z
	_front = Sprite2D.new()
	_front.texture = body.texture
	_front.centered = false
	_front.scale = body.scale
	_front.offset = body.offset
	_front.z_index = FRONT_Z
	_front.modulate = Color(1, 1, 1, FRONT_ALPHA)
	add_child(_front)


func _process(delta: float) -> void:
	_time += delta
	if _time >= _total or body == null:
		queue_free()
		return
	var t := _time / _total
	# Position CONTINUE dans la bande : la partie entière donne l'image, la
	# partie décimale le fondu vers la suivante.
	var progress := t * float(_frames.size() - 1)
	var index := clampi(int(progress), 0, _frames.size() - 1)
	var mix := progress - float(index)
	var frame := _frames[index]
	body.texture = frame
	if _blend != null:
		if index + 1 < _frames.size():
			_blend.texture = _frames[index + 1]
			_blend.modulate = Color(1, 1, 1, mix)
		else:
			_blend.modulate = Color(1, 1, 1, 0)
	# Le grossissement d'un cheveu entre deux images : sans lui, le fondu
	# suffit à lier les dessins mais l'éruption reste immobile entre deux pas.
	if _flow != null:
		_flow.set_shader_parameter("phase", _time)
		# L'ondulation faiblit avec l'éruption : une colonne qui retombe n'a
		# plus de pression.
		_flow.set_shader_parameter("force", 1.0 - 0.6 * t)
	if _rings:
		queue_redraw()
	var swell := 1.0 + 0.03 * mix
	body.scale = _base_scale * swell
	if _blend != null:
		_blend.scale = body.scale
	if _front != null:
		_front.texture = frame
		_front.scale = body.scale


func _draw() -> void:
	if not _rings or body == null or body.texture == null:
		return
	# L'ÉCUME AU SOL. Deux anneaux qui s'ouvrent depuis le pied de la colonne :
	# c'est ce qui rattache le jet au sol. Sans eux, l'eau semble tomber d'en
	# haut plutôt que jaillir d'en bas.
	var t := clampf(_time / _total, 0.0, 1.0)
	var span := body.scale.x * float(body.texture.get_width())
	for i in 2:
		var wave := clampf(t * 1.6 - float(i) * 0.22, 0.0, 1.0)
		if wave <= 0.0 or wave >= 1.0:
			continue
		var radius := span * (0.18 + 0.42 * wave)
		var fade := (1.0 - wave) * (1.0 - 0.35 * float(i))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32,
			Color(0.78, 0.94, 1.0, 0.5 * fade), maxf(1.5, span * 0.035), true)
		draw_arc(Vector2.ZERO, radius * 0.92, 0.0, TAU, 28,
			Color(1, 1, 1, 0.22 * fade), maxf(1.0, span * 0.018), true)
