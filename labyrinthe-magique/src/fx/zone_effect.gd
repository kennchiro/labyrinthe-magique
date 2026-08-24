class_name ZoneEffect
extends Node2D

## Surface qui brûle, gèle ou empoisonne pendant quelques secondes.
##
## Elle ne fait AUCUN dégât : le CombatSystem s'en charge, à sa propre cadence.
## Ce nœud ne fait que montrer où la zone se trouve et combien de temps il
## reste — sans quoi le joueur verrait ses ennemis fondre sans savoir pourquoi.

const RING_COUNT := 3

var tile_size: int = 32
var tint: Color = Color.WHITE
var radius_tiles := 2.0

var _time := 0.0
var _duration := 5.0


var _drawn: Texture2D = null


func setup(p_tile_size: int, p_tint: Color, p_radius: float, duration: float,
		p_drawn: Texture2D = null) -> void:
	_drawn = p_drawn
	tile_size = p_tile_size
	tint = p_tint
	radius_tiles = maxf(0.5, p_radius)
	_duration = maxf(0.1, duration)
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	self.material = material


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var life := 1.0 - _time / _duration
	# La zone PÂLIT en s'épuisant : c'est le seul indice qui dit au joueur
	# combien de temps il peut encore compter dessus.
	var pulse := 0.5 + 0.5 * sin(_time * 5.0)
	var radius := tile_size * radius_tiles
	# Le cercle DESSINÉ de la planche — l'anneau de feu, le cercle de pierres.
	# Il pulse et pâlit avec la zone : lui aussi doit dire le temps qui reste.
	if _drawn != null:
		var extent := maxf(float(_drawn.get_width()), float(_drawn.get_height()))
		var span := (radius * 2.0 / extent) * (0.94 + 0.06 * pulse)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(span, span))
		draw_texture(_drawn, -Vector2(_drawn.get_width(), _drawn.get_height()) * 0.5,
			Color(1, 1, 1, (0.55 + 0.25 * pulse) * life))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_circle(Vector2.ZERO, radius, Color(tint.r, tint.g, tint.b, 0.07 * life))
	for i in RING_COUNT:
		var phase := fposmod(_time * 0.6 + float(i) / float(RING_COUNT), 1.0)
		draw_arc(Vector2.ZERO, radius * (0.25 + 0.75 * phase), 0.0, TAU, 36,
			Color(tint.r, tint.g, tint.b, (0.30 + 0.15 * pulse) * life * (1.0 - phase)), 2.0)
