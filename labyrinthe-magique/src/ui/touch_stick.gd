class_name TouchStick
extends Control

## Manche analogique tactile, à POSITION FIXE.
##
## Il remplace la croix directionnelle, qui remplaçait elle-même un joystick — et
## ce qui n'allait pas dans ce premier joystick, c'était qu'il FLOTTAIT : il
## naissait sous le doigt, donc sans repère à l'écran, et le pouce devait deviner
## où était son centre. Ici la base ne bouge jamais, le bouton montre en
## permanence où l'on pousse, et une zone morte laisse le pouce se reposer dessus
## sans faire partir le mage.
##
## Ce qui faisait la valeur de la croix est conservé :
##   appui bref     -> le mage avance d'exactement une case puis s'arrête
##   appui maintenu -> déplacement continu tant que le doigt pousse
##
## Il rend un vecteur CONTINU. C'est le Player qui le réduit à une direction
## cardinale (axe dominant, puis repli sur l'autre si le virage est bouché) : la
## grille n'accepte rien d'autre, et cette réduction servait déjà au clavier et à
## la manette.
##
## Le multi-touch est géré par index de doigt : sans ça, poser un second doigt
## sur un bouton de sort annulerait le déplacement.

const BASE_TEXTURE := preload("res://assets/ui/stick_base.png")
const KNOB_TEXTURE := preload("res://assets/ui/stick_knob.png")

## Rayon de la base, en pixels de mise en page. Le module de l'interface tactile
## (Platform.KEY_SIZE) : la base fait donc deux touches de large.
@export var radius: float = Platform.KEY_SIZE
## Marge depuis le coin bas-gauche.
@export var margin: Vector2 = Vector2(52.0, 52.0)
## Débattement du bouton, en fraction du rayon. Au-delà de 0,45 il sort de
## l'anneau intérieur et déborde sur les flèches.
const TRAVEL := 0.42
## En deçà de cette fraction du débattement, on considère le pouce au repos.
## Généreux : un pouce posé sur un manche n'est jamais parfaitement centré, et
## un mage qui part tout seul pendant qu'on lit la carte est un bug pour le joueur.
const DEAD_ZONE := 0.34
## La zone de saisie déborde la base : on ne vise pas un manche en jouant, on
## pose le pouce à peu près là où on sait qu'il est.
const GRAB := 1.25
## Retour au centre à la levée du doigt, en fraction par seconde.
const RETURN_SPEED := 18.0

var direction: Vector2 = Vector2.ZERO

## Index du doigt qui tient le manche, -1 si aucun.
var _finger := -1
var _offset := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_enabled(Platform.touch_ui())


## L'UIManager range le manche quand le joueur choisit le mode « toucher le
## chemin » — et le ressort à la bascule inverse, sans recharger la scène.
func set_enabled(enabled: bool) -> void:
	visible = enabled
	set_process_input(enabled)
	set_process(enabled)
	_finger = -1
	_offset = Vector2.ZERO
	direction = Vector2.ZERO
	queue_redraw()


func _origin() -> Vector2:
	return Vector2(margin.x + radius, size.y - margin.y - radius)


func _travel() -> float:
	return radius * TRAVEL


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _finger < 0 and event.position.distance_to(_origin()) <= radius * GRAB:
				_finger = event.index
				_move_to(event.position)
		elif event.index == _finger:
			_finger = -1
			direction = Vector2.ZERO
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == _finger:
		_move_to(event.position)


func _move_to(point: Vector2) -> void:
	var travel := _travel()
	_offset = (point - _origin()).limit_length(travel)
	direction = Vector2.ZERO if _offset.length() < travel * DEAD_ZONE else _offset / travel
	queue_redraw()


func _process(delta: float) -> void:
	# Retour au centre après la levée du doigt. Instantané, le bouton claque ;
	# ce court glissement suffit à le rendre matériel.
	if _finger >= 0 or _offset == Vector2.ZERO:
		return
	_offset = _offset.lerp(Vector2.ZERO, minf(1.0, delta * RETURN_SPEED))
	if _offset.length() < 0.5:
		_offset = Vector2.ZERO
	queue_redraw()


func _draw() -> void:
	var centre := _origin()
	var scale_factor := radius * 2.0 / float(BASE_TEXTURE.get_width())
	_draw_centred(BASE_TEXTURE, centre, scale_factor, 0.72 if _finger < 0 else 0.95)
	_draw_centred(KNOB_TEXTURE, centre + _offset, scale_factor, 0.88 if _finger < 0 else 1.0)


## Les deux textures sont recadrées autour du MÊME centre à la génération
## (tools/build_assets.py) : les poser toutes deux centrées suffit, il n'y a
## aucun décalage à connaître ici.
func _draw_centred(texture: Texture2D, centre: Vector2, factor: float, alpha: float) -> void:
	var extent := Vector2(texture.get_size()) * factor
	draw_texture_rect(texture, Rect2(centre - extent * 0.5, extent), false,
		Color(1.0, 1.0, 1.0, alpha))
