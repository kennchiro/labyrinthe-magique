class_name Portal
extends Node2D

## Visuel d'un portail. Aucune logique : les destinations sont décidées par
## PortalNetwork, l'exécution par TeleportSystem.
##
## UNE SEULE BOUCLE, UNE SEULE COULEUR. Il y avait avant huit planches de six
## ÉTATS dessinés — repos, ouverture, ouvert, actif, saut, fermeture — soit
## quarante-huit images, une couleur par portail. Trois défauts, tous mesurés en
## capture dans le labyrinthe :
##
##   · il DÉBORDAIT du couloir. Réglé à 1,6 case de haut quand un couloir en
##     fait UNE : l'anneau montait sur les haies des deux côtés et l'on ne
##     voyait plus où marcher ;
##   · il SE DÉLAVAIT. Rendu en additif, un anneau clair posé sur le sable du
##     stage 3 devenait une tache pâle — l'additif ne sait qu'éclaircir, et sur
##     un sol déjà clair il n'a plus rien à ajouter ;
##   · huit teintes tirées de huit rangées d'une même planche ne faisaient pas
##     une famille.
##
## ⚠️ On perd le repère de couleur, et c'est un choix assumé : « le portail
## vert » était mémorisable dans un labyrinthe où l'on revient sur ses pas. La
## cohérence a été jugée plus précieuse.
##
## Les états ne sont plus DESSINÉS, ils sont JOUÉS sur la boucle unique : au
## repos elle tourne lentement et sombre, sous les pieds du mage elle s'anime et
## s'éclaire, au saut elle s'emballe. C'est ce qui les rend enfin cohérents entre
## eux — et huit images remplacent quarante-huit.

const PORTALS_PATH := "res://assets/portals/"
const ANIM_PATH := PORTALS_PATH + "portail_anim.json"
const SHEET_PATH := PORTALS_PATH + "portail_tour_%d.png"
## Hauteur visée, en cases. SOUS la case entière : le portail doit tenir entre
## deux murs, halo compris — c'était tout l'objet de la refonte.
const TARGET_HEIGHT_TILES := 0.95

## Cadences de rotation, en images par seconde, selon l'état.
const SPIN_IDLE := 3.5
const SPIN_READY := 9.0
const SPIN_FLASH := 20.0
## Durée de l'emballement au saut, et de la retombée quand le mage s'en va.
const TELEPORT_FLASH := 0.30
const CLOSE_DURATION := 0.45

@onready var sprite: Sprite2D = $Sprite2D

var tile_size: int = 32
var cell: Vector2i = Vector2i.ZERO
## Vrai quand le joueur est dessus et peut l'emprunter.
var highlighted := false

var _time := 0.0
var _spin := 0.0
var _frames := 8
var _base_scale := 1.0
var _flash := 0.0
var _closing := 0.0
var _was_highlighted := false


func setup(p_cell: Vector2i, p_tile_size: int, phase: float, index: int = 0) -> void:
	cell = p_cell
	tile_size = p_tile_size
	# Déphasage par portail : sinon tous tournent à l'unisson, ce qui fait
	# clignotant d'ambulance plutôt que forêt enchantée. C'est ce qui remplace
	# la couleur — ils sont identiques, ils ne sont pas synchrones.
	_time = phase
	_spin = phase * SPIN_IDLE

	var frames := _load_frames()
	if frames.is_empty():
		return
	sprite.texture = frames[0]
	_frames = frames.size()
	_sheet = frames
	_base_scale = (tile_size * TARGET_HEIGHT_TILES) / float(frames[0].get_height())
	sprite.scale = Vector2(_base_scale, _base_scale)

	# ⚠️ COMPOSITION NORMALE, pas additive. L'additif faisait de ce portail une
	# tache pâle sur les stages clairs : il n'ajoute de la lumière qu'à ce qui
	# est sombre. Le dessin, lui, se suffit — il est déjà lumineux.
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	sprite.material = material


var _sheet: Array[Texture2D] = []


func _load_frames() -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	var count := 8
	var text := FileAccess.get_file_as_string(ANIM_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if parsed != null:
		count = maxi(1, int((parsed as Dictionary).get("frames", 8)))
	for i in count:
		var path := SHEET_PATH % i
		if ResourceLoader.exists(path):
			frames.append(load(path))
	return frames


## Appelée par le Level quand un saut part d'ici : le portail s'emballe.
func flash_teleport() -> void:
	_flash = TELEPORT_FLASH


func _process(delta: float) -> void:
	_time += delta
	_flash = maxf(0.0, _flash - delta)
	# Le portail retombe quand le mage s'en va : sans cette détente, il resterait
	# vif derrière lui et l'on croirait pouvoir encore l'emprunter.
	if _was_highlighted and not highlighted:
		_closing = CLOSE_DURATION
	_was_highlighted = highlighted
	_closing = maxf(0.0, _closing - delta)
	if _sheet.is_empty():
		return

	# LA VITESSE DIT L'ÉTAT. On avance un compteur continu plutôt que de poser
	# un numéro d'image : changer de cadence ne doit pas faire sauter la
	# rotation en arrière.
	var speed := SPIN_IDLE
	if _flash > 0.0:
		speed = SPIN_FLASH
	elif highlighted:
		speed = SPIN_READY
	elif _closing > 0.0:
		speed = lerpf(SPIN_IDLE, SPIN_READY, _closing / CLOSE_DURATION)
	_spin += delta * speed
	sprite.texture = _sheet[int(_spin) % _frames]

	var pulse := 0.5 + 0.5 * sin(_time * 2.6)
	var swell := 1.0 + 0.04 * pulse
	var glow := 0.72 + 0.10 * pulse
	if highlighted:
		swell += 0.07
		glow = 1.05 + 0.12 * pulse
	elif _closing > 0.0:
		var back := _closing / CLOSE_DURATION
		swell += 0.07 * back
		glow = lerpf(glow, 1.05, back)
	if _flash > 0.0:
		var burst := _flash / TELEPORT_FLASH
		swell += 0.22 * burst
		glow = 1.05 + 0.85 * burst
	sprite.scale = Vector2(_base_scale * swell, _base_scale * swell)
	sprite.modulate = Color(glow, glow, glow)


## ⚠️ PLUS D'ANNEAU TRACÉ. Il en existait un, dessiné en code sous le portail
## pour dire « c'est CETTE case » — la lueur d'avant était large et floue, elle
## débordait sur deux couloirs et ne désignait rien. Le dessin actuel fait
## exactement une case : l'anneau ne disait plus que ce que le portail dit
## déjà, et deux cercles concentriques se lisaient comme un défaut de rendu.
