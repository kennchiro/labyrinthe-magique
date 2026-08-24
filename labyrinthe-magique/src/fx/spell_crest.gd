class_name SpellCrest
extends Node2D

## Le BLASON du sort, affiché au lancement de l'Extra Power.
##
## Un ultime coûte quatre éliminations : le joueur doit VOIR qu'il vient de le
## dépenser, sans avoir à lire le bandeau. Le blason de la planche le dit d'un
## coup d'œil — c'est un dessin, pas un rond tracé en code.
##
## Il reste DROIT et TRANSPARENT : une emblème qui tourne se lit comme un objet
## ramassable qui vole, pas comme une signature. Il ne fait que paraître,
## respirer une fois, et s'effacer.

## Hauteur visée, en cases. Assez grand pour se voir, assez petit pour ne pas
## cacher le labyrinthe pendant que l'ultime frappe.
const TARGET_TILES := 2.6
## Il monte AU-DESSUS du mage. Posé sur lui, il lui couvrait le torse : on
## voyait le blason au lieu de voir le personnage lancer son sort.
const RISE_TILES := 1.8
const DURATION := 1.1
const PEAK_ALPHA := 0.55

@onready var sprite: Sprite2D = $Sprite2D

var _life := 0.0
var _tile := 32


func setup(tile_size: int, texture: Texture2D) -> void:
	_tile = tile_size
	var node: Sprite2D = get_node_or_null("Sprite2D")
	if node == null or texture == null:
		queue_free()
		return
	sprite = node
	sprite.texture = texture
	sprite.rotation = 0.0
	var factor := (tile_size * TARGET_TILES) / float(texture.get_height())
	sprite.scale = Vector2(factor, factor)
	sprite.modulate = Color(1, 1, 1, 0)


func _process(delta: float) -> void:
	_life += delta
	if _life >= DURATION or sprite == null:
		queue_free()
		return
	var t := _life / DURATION
	# Il paraît vite et s'efface lentement : l'apparition doit coïncider avec le
	# geste, la disparition ne doit pas couper l'ultime en deux.
	var alpha: float = PEAK_ALPHA * (
		clampf(t / 0.12, 0.0, 1.0) if t < 0.12 else 1.0 - (t - 0.12) / 0.88)
	sprite.modulate = Color(1, 1, 1, maxf(0.0, alpha))
	# Une seule respiration : il grandit d'un dixième puis se pose. Pas de
	# rotation — voir l'en-tête.
	var grow := 1.0 + 0.10 * sin(minf(t * 2.4, 1.0) * PI)
	var factor := (_tile * TARGET_TILES) / float(sprite.texture.get_height())
	sprite.scale = Vector2(factor * grow, factor * grow)
	sprite.position = Vector2(0.0, -_tile * RISE_TILES * (0.4 + 0.6 * t))
