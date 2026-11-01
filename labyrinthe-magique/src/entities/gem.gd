class_name Gem
extends Node2D

## Une gemme à ramasser. L'objectif du jeu : la porte de la maison ne s'ouvre
## que lorsqu'elles ont toutes été prises.
##
## Sept teintes franches, une par gemme, et la même couleur est reprise sur le
## sceau de la maison et dans le bandeau. Le joueur peut donc dire « il me
## manque la rouge » sans compter — et surtout, savoir d'un coup d'œil laquelle
## il vient de prendre.

const TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/gem_diamond.png"),
	preload("res://assets/sprites/gem_ruby.png"),
	preload("res://assets/sprites/gem_emerald.png"),
	preload("res://assets/sprites/gem_amethyst.png"),
	preload("res://assets/sprites/gem_topaz.png"),
	preload("res://assets/sprites/gem_sapphire.png"),
	preload("res://assets/sprites/gem_rose.png"),
]
## Teintes de halo correspondantes, une par texture.
const TINTS: Array[Color] = [
	Color("#96ecff"), Color("#ff4860"), Color("#4eec8c"),
	Color("#bc70ff"), Color("#ffca4c"), Color("#4a7aff"), Color("#ff7ad0"),
]
const TARGET_HEIGHT_TILES := 0.78
## Amplitude du flottement, en fraction de case. La gemme ne touche pas le sol :
## un objet posé au milieu d'un couloir se lit comme du décor, un objet qui
## lévite se lit comme un objectif.
const FLOAT_AMPLITUDE := 0.10

@onready var sprite: Sprite2D = $Sprite2D

var cell: Vector2i = Vector2i.ZERO
var tile_size: int = 32
var tint: Color = Color.WHITE
## Portée par un Rat : elle reste dans la liste des gemmes et sa `cell` le suit. La boussole,
## le sceau et les portails continuent donc de la viser, sans une ligne de plus.
var carried := false

var _time := 0.0


func setup(p_cell: Vector2i, p_tile_size: int, index: int) -> void:
	cell = p_cell
	tile_size = p_tile_size
	var slot: int = index % TEXTURES.size()
	tint = TINTS[slot]
	# Déphasage par gemme, pour qu'elles ne flottent pas toutes à l'unisson.
	_time = float(index) * 0.8

	sprite.texture = TEXTURES[slot]
	var factor := (tile_size * TARGET_HEIGHT_TILES) / float(sprite.texture.get_height())
	sprite.scale = Vector2(factor, factor)

	# Halo additif, comme les portails : une lueur, pas un disque de peinture.
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	self.material = material


func color() -> Color:
	return tint


func _process(delta: float) -> void:
	_time += delta
	var bob := sin(_time * 2.2)
	sprite.position = Vector2(0.0, bob * tile_size * FLOAT_AMPLITUDE - tile_size * 0.12)
	sprite.rotation = sin(_time * 1.1) * 0.12
	queue_redraw()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_time * 2.6)
	var centre := Vector2(0.0, -tile_size * 0.10)
	draw_circle(centre, tile_size * (0.62 + 0.10 * pulse), Color(tint.r, tint.g, tint.b, 0.10))
	draw_circle(centre, tile_size * (0.36 + 0.06 * pulse), Color(tint.r, tint.g, tint.b, 0.16))
