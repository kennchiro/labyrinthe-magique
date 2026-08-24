class_name WarpEffect
extends Node2D

## La colonne de téléportation du mage, découpée de sa planche.
##
## Le sort de FUITE déplaçait le mage d'un coup, à la frame près : on ne
## comprenait pas ce qui venait de se passer, et le joueur perdait de vue son
## propre personnage. Un déplacement instantané n'est lisible que s'il est
## ANNONCÉ au départ et CONFIRMÉ à l'arrivée.
##
## L'effet joue donc aux DEUX cases. Il monte vite (la colonne jaillit), tient,
## puis s'efface — pendant que le `Player`, lui, s'estompe au départ et
## réapparaît à l'arrivée. Aucun des deux ne suffit seul : la colonne sans le
## fondu donnerait un mage qui clignote au milieu d'un décor animé.
##
## Rendu en BLENDING ADDITIF, comme les portails : c'est ce qui fait qu'une
## colonne de lumière se lit comme de la lumière et non comme un autocollant.

const CHARACTERS_PATH := "res://assets/characters/"
## Encombrement visé, en cases, sur la PLUS GRANDE dimension du dessin.
##
## Pas la hauteur : les sept effets n'ont pas la même forme. Le feu est un
## anneau posé au sol, large et plat ; la terre est une colonne haute et
## étroite. Mis à l'échelle sur leur hauteur, l'anneau de feu débordait sur
## trois cases et recouvrait les haies voisines.
const TARGET_EXTENT_TILES := 2.3
const RISE := 0.14
const HOLD := 0.16
const FADE := 0.30

@onready var sprite: Sprite2D = $Sprite2D

var _time := 0.0
var _base_scale := 1.0


func setup(character_id: String, tile_size: int) -> void:
	var texture: Texture2D = load(CHARACTERS_PATH + character_id + "/warp.png")
	if texture == null:
		queue_free()
		return
	sprite.texture = texture
	var extent := maxf(float(texture.get_width()), float(texture.get_height()))
	_base_scale = (tile_size * TARGET_EXTENT_TILES) / extent
	# La colonne pose son pied sur la case : centrée, elle flotterait au-dessus.
	sprite.offset = Vector2(0.0, -texture.get_height() * 0.34)
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	sprite.material = material
	_apply(0.0)


func _apply(progress: float) -> void:
	var rise: float = clampf(progress / RISE, 0.0, 1.0)
	var alpha := 1.0
	if progress > RISE + HOLD:
		alpha = clampf(1.0 - (progress - RISE - HOLD) / FADE, 0.0, 1.0)
	# La colonne s'étire vers le haut en jaillissant, pas dans tous les sens :
	# une mise à l'échelle uniforme la ferait grossir comme un ballon.
	sprite.scale = Vector2(_base_scale * (0.55 + 0.45 * rise), _base_scale * rise)
	sprite.modulate = Color(1.0, 1.0, 1.0, alpha)


func _process(delta: float) -> void:
	_time += delta
	_apply(_time)
	if _time > RISE + HOLD + FADE:
		queue_free()
