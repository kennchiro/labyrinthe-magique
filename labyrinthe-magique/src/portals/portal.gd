class_name Portal
extends Node2D

## Visuel d'un portail. Aucune logique : les destinations sont décidées par
## PortalNetwork, l'exécution par TeleportSystem.
##
## PEINT AU SHADER (`assets/shaders/portal.gdshader`), comme les sorts. Il était lu
## dans huit images d'une boucle unique, elles-mêmes venues de quarante-huit images
## en huit couleurs. Trois défauts mesurés en capture ont fixé ce qu'il doit rester :
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
## Les états sont JOUÉS sur un seul dessin : au repos il tourne lentement et sombre,
## sous les pieds du mage il s'anime et s'éclaire, au saut il s'emballe.

const SHADER := preload("res://assets/shaders/portal.gdshader")
const NOISE := preload("res://assets/shaders/fire_noise.png")
## Envergure, en cases. SOUS la case entière : le portail doit tenir entre deux
## murs — c'était tout l'objet de la refonte.
const TARGET_SIZE_TILES := 0.95

## Cadences de rotation, en tours de dessin par seconde, selon l'état.
const SPIN_IDLE := 0.7
const SPIN_READY := 2.2
const SPIN_FLASH := 7.0
## Durée de l'emballement au saut, et de la retombée quand le mage s'en va.
const TELEPORT_FLASH := 0.30
const CLOSE_DURATION := 0.45
## Vitesse à laquelle l'éclat suit l'état : il monte et descend sans clignoter.
const ENERGY_RISE := 8.0

@onready var sprite: Sprite2D = $Sprite2D

var tile_size: int = 32
var cell: Vector2i = Vector2i.ZERO
## Vrai quand le joueur est dessus et peut l'emprunter.
var highlighted := false

var _time := 0.0
var _spin := 0.0
var _energy := 0.0
var _flash := 0.0
var _closing := 0.0
var _was_highlighted := false
var _paint: ShaderMaterial


func setup(p_cell: Vector2i, p_tile_size: int, phase: float, index: int = 0) -> void:
	cell = p_cell
	tile_size = p_tile_size
	# ⚠️ Le portail est COUCHÉ sur le sol, contrairement aux personnages : la vue 2,5D
	# vient de le redresser en l'ajoutant aux entités, et un disque debout ne se lit
	# plus comme un passage sous les pieds. L'inclinaison de la caméra fait l'ellipse.
	scale = Vector2.ONE
	# Déphasage par portail : sinon tous tournent à l'unisson, ce qui fait
	# clignotant d'ambulance plutôt que forêt enchantée. C'est ce qui remplace
	# la couleur — ils sont identiques, ils ne sont pas synchrones.
	_time = phase
	_spin = phase * SPIN_IDLE

	_paint = ShaderMaterial.new()
	_paint.shader = SHADER
	_paint.set_shader_parameter("noise", NOISE)
	_paint.set_shader_parameter("seed", float(index) * 0.37)
	sprite.texture = MagicOrb.painted_quad()
	sprite.scale = Vector2.ONE * float(tile_size) * TARGET_SIZE_TILES
	sprite.material = _paint


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
	if _paint == null:
		return

	# LA VITESSE DIT L'ÉTAT. On avance un compteur continu plutôt que de poser
	# un angle : changer de cadence ne doit pas faire sauter la rotation en arrière.
	var speed := SPIN_IDLE
	if _flash > 0.0:
		speed = SPIN_FLASH
	elif highlighted:
		speed = SPIN_READY
	elif _closing > 0.0:
		speed = lerpf(SPIN_IDLE, SPIN_READY, _closing / CLOSE_DURATION)
	_spin += delta * speed

	var wanted := 1.0 if highlighted else _closing / CLOSE_DURATION
	_energy = move_toward(_energy, wanted, delta * ENERGY_RISE)
	_paint.set_shader_parameter("spin", _spin)
	_paint.set_shader_parameter("phase", _time)
	_paint.set_shader_parameter("energy", _energy)
	_paint.set_shader_parameter("burst", _flash / TELEPORT_FLASH)
