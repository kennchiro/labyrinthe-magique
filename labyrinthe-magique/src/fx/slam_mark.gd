class_name SlamMark
extends Node2D

## LE CHOC CONTRE LA PIERRE : un éclat sec, à l'endroit exact où la course a
## été bloquée.
##
## C'est le seul indice qui apprend au joueur que le mur fait mal. Sans lui, le
## Grand souffle donne deux résultats différents — déplacer, ou tuer — sans que
## rien à l'écran ne dise pourquoi.
##
## Il est BLANC et bref, là où le reste du sort est bleu pâle et large : ce
## contraste est ce qui le rend lisible au milieu du souffle.

const LIFE := 0.28
const SHARDS := 7

var tile_size: int = 32

var _time := 0.0


func setup(p_tile_size: int) -> void:
	tile_size = p_tile_size
	z_index = 15


func _process(delta: float) -> void:
	_time += delta
	if _time >= LIFE:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := clampf(_time / LIFE, 0.0, 1.0)
	var fade := 1.0 - t
	# L'étoile d'impact : des traits courts qui partent du point de choc.
	for i in SHARDS:
		var angle := TAU * float(i) / float(SHARDS) + 0.3
		var away := Vector2(cos(angle), sin(angle) * 0.7)
		var inner := tile_size * (0.10 + 0.30 * t)
		var outer := inner + tile_size * 0.28 * fade
		draw_line(away * inner, away * outer,
			Color(1, 1, 1, 0.9 * fade), maxf(1.5, tile_size * 0.06), true)
	draw_circle(Vector2.ZERO, tile_size * 0.22 * (1.0 - t * 0.6),
		Color(1, 1, 1, 0.5 * fade * fade))
