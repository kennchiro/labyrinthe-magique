class_name DeathFade
extends Sprite2D

## La dernière image d'une créature abattue, qui blanchit, s'affaisse et s'efface.
##
## L'ennemi lui-même disparaît à la frame de sa mort : son nœud repart aussitôt
## attendre la vague suivante. Cette copie n'existe donc que pour l'œil, et la
## simulation d'équilibrage n'en sait rien.

const DURATION := 0.38
## Part de la durée passée en éclair blanc, avant l'effacement.
const FLASH_SHARE := 0.25

var _life := 0.0
var _home_scale := Vector2.ONE


## Copie la pose telle qu'elle était à l'écran au moment du coup fatal.
func setup(source: Sprite2D, at: Vector2) -> void:
	texture = source.texture
	hframes = source.hframes
	frame = source.frame
	offset = source.offset
	scale = source.scale
	position = at
	z_index = source.get_parent().z_index
	_home_scale = source.scale


func _process(delta: float) -> void:
	_life += delta
	var done := _life / DURATION
	if done >= 1.0:
		queue_free()
		return
	var fade := clampf((done - FLASH_SHARE) / (1.0 - FLASH_SHARE), 0.0, 1.0)
	var glow := 1.0 + 1.8 * (1.0 - fade)
	modulate = Color(glow, glow, glow, 1.0 - fade)
	# Les pieds sont sur l'origine du nœud : la créature s'écrase vers le sol au
	# lieu de rapetisser vers son milieu.
	scale = _home_scale * Vector2(1.0 + 0.18 * fade, 1.0 - 0.45 * fade)
