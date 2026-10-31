class_name Meteor
extends Node2D

## Une météore de la pluie volcanique : elle tombe du ciel et s'écrase.
##
## Le MARQUEUR AU SOL est le cœur de l'affaire. Un rocher qui apparaît et
## explose n'est pas un événement, c'est un dégât inexpliqué — le joueur voit
## sa barre de vie d'ennemi tomber sans comprendre d'où ça vient. Le cercle qui
## se resserre pendant la chute dit trois choses à la fois : quelque chose
## arrive, ça tombera LÀ, et dans combien de temps.
##
## Elle ne décide de rien : le CombatSystem a déjà fixé la case et l'instant de
## l'impact, ce nœud ne fait que rendre visible l'attente. La simulation
## d'équilibrage joue la même pluie sans instancier un seul de ces nœuds.

## Hauteur de chute, en cases.
##
## VINGT-DEUX, et non sept. À sept cases — 224 pixels — la météore naissait en
## plein écran : on la voyait apparaître, ce qui est exactement ce qu'une pierre
## tombée du ciel ne doit pas faire. Vingt-deux dépasse la demi-diagonale de la
## vue (40 x 22 cases), donc elle entre TOUJOURS par un bord, quel que soit
## l'endroit du labyrinthe où elle frappe.
const FALL_TILES := 22.0
## Pente de la chute, en cases de DÉCALAGE horizontal pour sept cases de
## descente. Une météore qui tombe droit se lit comme un objet lâché ; une
## météore qui arrive en biais a été JETÉE — et sa traîne dit d'où.
##
## Elle vient toujours du même côté, en haut à gauche : un ciel dont les pierres
## arrivent de partout n'a plus l'air d'un ciel.
##
## Autant que la hauteur, donc 45° : c'est l'angle sous lequel on dessine une
## météore depuis toujours, et c'est aussi celui de la traîne peinte sur la
## planche. Les deux doivent coïncider, sinon la boule glisse de travers
## derrière sa propre queue.
const SLANT_TILES := 22.0

@onready var rock: Sprite2D = $Rock

var _painted := false
var _tail: CPUParticles2D = null

const DROP := preload("res://assets/shaders/water_drop.gdshader")

var tile_size: int = 32
var _liquid := false
var _shimmer: ShaderMaterial = null

var _fall := 0.7
var _life := 0.0
## Bande d'images de la météore, quand elle en a une.
var _frames := 1
var _fps := 0.0
var _tint := Color(1.0, 0.55, 0.15)


## `p_size_tiles` : taille du corps qui tombe, en cases. Une météore du Feu
## remplit sa case et demie ; une goutte d'eau ne doit surtout pas — trente
## gouttes de cette taille effaceraient le labyrinthe. Mesuré en jeu.
## `p_liquid` : la goutte ONDULE en tombant, par shader. Voir `water_drop.gdshader`.
## `p_frames` > 1 : la texture est une BANDE, et la météore tourne sur elle-même
## pendant sa chute. Elle traverse l'écran en moins d'une seconde et c'est le
## seul moment où on la voit — une boule figée y ressemble à un autocollant.
func setup(p_tile_size: int, delay: float, texture: Texture2D, tint: Color,
		p_size_tiles: float = 1.6, p_liquid: bool = false,
		p_frames: int = 1, p_fps: float = 0.0) -> void:
	tile_size = p_tile_size
	_fall = maxf(0.1, delay)
	_tint = tint
	_liquid = p_liquid
	_frames = maxi(1, p_frames)
	_fps = p_fps
	if texture != null:
		rock.texture = texture
		rock.hframes = _frames
		rock.vframes = 1
		var extent := maxf(float(texture.get_width()) / float(_frames),
			float(texture.get_height()))
		var factor := (tile_size * p_size_tiles) / extent
		rock.scale = Vector2(factor, factor)
	if _liquid:
		var shimmer := ShaderMaterial.new()
		shimmer.shader = DROP
		rock.material = shimmer
		_shimmer = shimmer
	else:
		var material := CanvasItemMaterial.new()
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		rock.material = material

	# La traînée suit le rocher : c'est elle qui donne la vitesse. Un sprite qui
	# descend sans traîne semble glisser, pas tomber.
	var tail := FxTextures.flame_emitter(24, 0.35, float(tile_size) * 0.5,
		Color(1.0, 0.85, 0.45, 0.85), Color(0.9, 0.25, 0.04, 0.0), 0.0, 26.0)
	tail.local_coords = false
	# Les flammes fuient vers le HAUT-GAUCHE, à l'opposé de la chute : la traîne
	# doit être dans le dos de la pierre, pas au-dessus d'elle.
	tail.direction = Vector2(-1.0, -1.0).normalized()
	tail.initial_velocity_min = float(tile_size) * 0.3
	tail.initial_velocity_max = float(tile_size) * 1.4
	rock.add_child(tail)
	tail.emitting = true
	_tail = tail


## La météore du Feu, peinte comme sa Boule : sa pointe suit la chute au lieu de
## tourner, et sa chevelure est dans le dessin, qui remplace le panache de particules.
func paint(visual: String, size_tiles: float) -> void:
	var look: Dictionary = MagicOrb.PAINTED[visual]
	_painted = true
	rock.texture = MagicOrb.painted_quad()
	rock.hframes = 1
	rock.offset = Vector2(-float(look["lead"]), 0.0)
	rock.material = MagicOrb.painted_material(visual,
		float(Time.get_ticks_usec() % 1000) * 0.001)
	rock.scale = Vector2(float(look["length"]), float(look["height"])) \
		* float(tile_size) * size_tiles
	rock.rotation = Vector2(SLANT_TILES, FALL_TILES).angle()
	if _tail != null:
		_tail.queue_free()
		_tail = null
	# Une goutte ne tournoie pas et n'a pas de reflet à entretenir.
	_liquid = false
	_shimmer = null


func _process(delta: float) -> void:
	_life += delta
	if _frames > 1 and _fps > 0.0:
		rock.frame = int(_life * _fps) % _frames
	var progress := clampf(_life / _fall, 0.0, 1.0)
	# CHUTE LINÉAIRE, et c'est un revirement assumé.
	#
	# L'accélération quadratique était juste tant que la chute faisait sept
	# cases : sur une courte descente, une vitesse constante ne pèse rien. Sur
	# vingt-deux cases elle devient un défaut — à mi-parcours la météore n'a
	# couvert qu'un quart du chemin, elle est donc encore hors champ, et tout le
	# trajet visible se fait dans le dernier quart de seconde. On ne la voit pas
	# tomber, on la voit arriver.
	#
	# À vitesse constante sur une telle distance, elle traverse le ciel — ce qui
	# est précisément ce qu'on regarde.
	var eased := progress
	var remaining := 1.0 - eased
	rock.position = Vector2(-tile_size * SLANT_TILES * remaining,
		-tile_size * FALL_TILES * remaining)
	# UNE GOUTTE NE TOURNOIE PAS. Un caillou en chute libre pivote sur lui-même ;
	# une goutte garde sa pointe vers le bas et ondule. Le shader s'occupe du
	# reste.
	if _liquid:
		if _shimmer != null:
			_shimmer.set_shader_parameter("phase", _life)
	elif not _painted:
		rock.rotation += delta * 3.0
	queue_redraw()
	if _life >= _fall:
		queue_free()


func _draw() -> void:
	var progress := clampf(_life / _fall, 0.0, 1.0)
	# Le cercle se RESSERRE : c'est un compte à rebours qu'on lit sans chiffre.
	var radius := tile_size * (1.5 - 0.9 * progress)
	var glow := 0.35 + 0.5 * progress
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32,
		Color(_tint.r, _tint.g * 0.7, _tint.b * 0.4, glow), 2.0 + 2.0 * progress)
	draw_circle(Vector2.ZERO, radius * 0.9,
		Color(_tint.r, _tint.g * 0.5, _tint.b * 0.2, 0.10 * progress))
