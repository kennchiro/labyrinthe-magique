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

## Hauteur de chute, en cases. Assez haut pour qu'elle sorte de l'écran au
## départ : une météore qui naît dans le champ n'a pas l'air de venir du ciel.
const FALL_TILES := 7.0

@onready var rock: Sprite2D = $Rock

var tile_size: int = 32

var _fall := 0.7
var _life := 0.0
var _tint := Color(1.0, 0.55, 0.15)


func setup(p_tile_size: int, delay: float, texture: Texture2D, tint: Color) -> void:
	tile_size = p_tile_size
	_fall = maxf(0.1, delay)
	_tint = tint
	if texture != null:
		rock.texture = texture
		var extent := maxf(float(texture.get_width()), float(texture.get_height()))
		var factor := (tile_size * 1.6) / extent
		rock.scale = Vector2(factor, factor)
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	rock.material = material

	# La traînée suit le rocher : c'est elle qui donne la vitesse. Un sprite qui
	# descend sans traîne semble glisser, pas tomber.
	var tail := FxTextures.flame_emitter(24, 0.35, float(tile_size) * 0.5,
		Color(1.0, 0.85, 0.45, 0.85), Color(0.9, 0.25, 0.04, 0.0), 0.0, 26.0)
	tail.local_coords = false
	tail.direction = Vector2(0.0, -1.0)      # les flammes fuient vers le HAUT
	tail.initial_velocity_min = float(tile_size) * 0.3
	tail.initial_velocity_max = float(tile_size) * 1.4
	rock.add_child(tail)
	tail.emitting = true


func _process(delta: float) -> void:
	_life += delta
	var progress := clampf(_life / _fall, 0.0, 1.0)
	# Chute ACCÉLÉRÉE : une descente linéaire ne pèse rien.
	var eased := progress * progress
	rock.position = Vector2(0.0, -tile_size * FALL_TILES * (1.0 - eased))
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
