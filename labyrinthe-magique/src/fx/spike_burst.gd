class_name SpikeBurst
extends Node2D

## L'ÉRUPTION jouée image par image, depuis la planche animée.
##
## Six images : la fissure, la percée, la montée, la pleine hauteur, l'éclat,
## puis l'affaissement. Elles ont été découpées dans une BOÎTE COMMUNE — sinon
## la fissure large et basse et la gerbe haute et étroite n'auraient ni la même
## taille ni le même centre, et les pics sauteraient d'une image à l'autre.
##
## Deux matières alternent le long du couloir, cristal et pierre, décidées par
## la case : deux gerbes identiques côte à côte se lisent comme une image
## copiée-collée.

## Hauteur visée, en cases.
const TARGET_TILES := 1.7
## Durée de la montée (images 0 à 4) et de l'affaissement (image 5).
const RISE := 0.28
const FALL := 0.3

@onready var body: Sprite2D = $Body

var _frames: Array[Texture2D] = []
var _life := 0.0
var _total := 1.0
var _tile := 32


func setup(tile_size: int, duration: float, frames: Array) -> void:
	_tile = tile_size
	_total = maxf(RISE + FALL, duration)
	for frame in frames:
		if frame != null:
			_frames.append(frame)
	var node: Sprite2D = get_node_or_null("Body")
	if node == null or _frames.is_empty():
		queue_free()
		return
	body = node
	body.texture = _frames[0]
	var factor := (tile_size * TARGET_TILES) / float(_frames[0].get_height())
	body.scale = Vector2(factor, factor)
	# Ancrée sur sa BASE : la gerbe pousse vers le haut, ses gravats restent au
	# sol. Centrée, elle flotterait au-dessus de sa case.
	body.offset = Vector2(0.0, -float(_frames[0].get_height()) * 0.5)


func _process(delta: float) -> void:
	_life += delta
	if _life >= _total or body == null:
		queue_free()
		return
	var last := _frames.size() - 1
	var index := 0
	if _life < RISE:
		# La montée traverse les images 0 à l'avant-dernière.
		index = int((_life / RISE) * float(last))
	elif _life > _total - FALL:
		index = last            # l'affaissement
	else:
		index = maxi(0, last - 1)   # la pleine hauteur, tenue
	body.texture = _frames[clampi(index, 0, last)]
