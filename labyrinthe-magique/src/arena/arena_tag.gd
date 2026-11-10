class_name ArenaTag
extends Node2D

## Sous chaque héros de l'arène, l'anneau de son équipe ; au-dessus de sa tête, sa barre de vie.
##
## Six héros se ressemblent vite dans une mêlée, et rien dans leur dessin ne dit leur camp :
## l'anneau le dit. L'anneau passe SOUS le sprite (`show_behind_parent`), la barre par-dessus.

var fighter: ArenaFighter = null
var tile := 32
var _bar: Bar = null


func setup(p_fighter: ArenaFighter, p_tile: int) -> void:
	fighter = p_fighter
	tile = p_tile
	show_behind_parent = true
	_bar = Bar.new()
	_bar.tag = self
	get_parent().add_child.call_deferred(_bar)


func _process(_delta: float) -> void:
	queue_redraw()
	if _bar != null:
		_bar.queue_redraw()


func _draw() -> void:
	if fighter == null or not fighter.alive():
		return
	var color: Color = ArenaRules.TEAM_COLORS[fighter.team]
	draw_set_transform(Vector2(0.0, tile * 0.02), 0.0, Vector2(1.0, 0.45))
	# ÉVEILLÉ : un second anneau, doré, qui pulse. On doit voir de loin qui est sous sa grande forme.
	if fighter.awakening != null and fighter.awakening.awake():
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.006)
		draw_circle(Vector2.ZERO, tile * (0.62 + 0.06 * pulse), Color(1.0, 0.83, 0.47, 0.18))
		draw_arc(Vector2.ZERO, tile * (0.62 + 0.06 * pulse), 0.0, TAU, 40, Color(1.0, 0.83, 0.47, 0.9), 2.0, true)
	draw_circle(Vector2.ZERO, tile * 0.46, Color(color, 0.22))
	draw_arc(Vector2.ZERO, tile * 0.46, 0.0, TAU, 32, Color(color, 0.95), 2.5, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


class Bar extends Node2D:
	var tag: ArenaTag

	func _draw() -> void:
		var fighter := tag.fighter
		if fighter == null or not fighter.alive():
			return
		var actor := get_parent() as Actor
		var height := actor.target_height if actor != null else 58.0
		var width := float(tag.tile) * 0.95
		var top := -height - 7.0
		var color: Color = ArenaRules.TEAM_COLORS[fighter.team]
		var box := Rect2(-width * 0.5, top, width, 4.5)
		draw_rect(box.grow(1.2), Color(0.02, 0.03, 0.06, 0.85))
		var share := clampf(fighter.health.ratio(), 0.0, 1.0)
		draw_rect(Rect2(box.position, Vector2(width * share, box.size.y)), color.lerp(Color.WHITE, 0.15))
		if fighter.health.shield > 0:
			var shield := clampf(float(fighter.health.shield) / float(fighter.health.maximum), 0.0, 1.0)
			draw_rect(Rect2(box.position + Vector2(0.0, -2.5), Vector2(width * shield, 2.0)), Color(0.85, 0.95, 1.0, 0.95))
		# La charge de l'Éveil, en fil d'or sous la vie ; pleine, elle brille.
		var awakening := fighter.awakening
		if awakening != null and awakening.state == Awakening.State.NORMAL:
			var ready := awakening.can_begin()
			var glow := 0.6 + 0.4 * sin(Time.get_ticks_msec() * 0.01) if ready else 0.75
			draw_rect(Rect2(box.position + Vector2(0.0, box.size.y + 1.5), Vector2(width * awakening.charge_ratio(), 1.8)),
				Color(1.0, 0.83, 0.47, glow))
		# L'Extra chargé : un point doré au bout de la barre.
		if fighter.kills.available():
			draw_circle(Vector2(width * 0.5 + 4.0, top + 2.2), 2.6, Color("#ffd479"))
