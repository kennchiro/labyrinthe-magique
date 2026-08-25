class_name GasPuff
extends Node2D

## Le gaz violet d'une Ombre maléfique, joué sur sa victime.
##
## Il vient de la planche de l'ombre (rangée du bas) et non d'un dessin
## procédural : la créature a un souffle DESSINÉ, et un nuage tracé au code
## à côté d'elle raconterait un autre sort que celui qu'on voit sortir de sa
## capuche.
##
## Les quatre poses se fondent l'une dans l'autre plutôt que de se succéder —
## même leçon que le portail de la Rune, où six images jouées sèchement
## donnaient six à-coups par tour. Deux calques, l'un qui s'efface pendant que
## l'autre paraît.

## Durée d'un nuage. Un peu plus que la cadence de frappe d'une ombre (1,1 s),
## pour que deux souffles d'affilée se recouvrent au lieu de clignoter.
const LIFE := 1.25

var _front: Sprite2D = null
var _back: Sprite2D = null
var _frames := 4
var _time := 0.0
var _scale := 1.0


func setup(tile_size: int, texture: Texture2D, frames: int, span_tiles: float = 1.6) -> void:
	_frames = maxi(1, frames)
	var cell := float(texture.get_width()) / float(_frames)
	_scale = (tile_size * span_tiles) / maxf(1.0, cell)
	for layer in 2:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.hframes = _frames
		# Le gaz est une MATIÈRE, pas une lueur : en additif il blanchirait la
		# créature qu'il recouvre au lieu de la voiler. Même règle que la flaque
		# d'ombre et que la rune.
		var material := CanvasItemMaterial.new()
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		sprite.material = material
		add_child(sprite)
		if layer == 0:
			_front = sprite
		else:
			_back = sprite
	set_process(true)


func _process(delta: float) -> void:
	_time += delta
	if _time >= LIFE:
		queue_free()
		return
	var progress := _time / LIFE
	# Les quatre poses sont un CYCLE DE VIE — il jaillit, il s'étale, il tourne,
	# il se dissipe — et non une boucle : on les traverse une fois, du début à
	# la fin, sur la durée du nuage.
	var position := progress * float(_frames - 1)
	var index := int(floor(position))
	var blend: float = position - floor(position)
	# Il monte un peu et grossit : un nuage figé sur place a l'air d'un décal.
	var rise := -progress * 6.0
	var swell := _scale * (0.72 + 0.38 * progress)
	var fade := clampf((1.0 - progress) * 2.2, 0.0, 1.0)

	_front.frame = index
	_back.frame = mini(_frames - 1, index + 1)
	_front.self_modulate = Color(1.0, 1.0, 1.0, fade * (1.0 - blend))
	_back.self_modulate = Color(1.0, 1.0, 1.0, fade * blend)
	for sprite in [_front, _back]:
		sprite.scale = Vector2(swell, swell)
		sprite.position.y = rise
