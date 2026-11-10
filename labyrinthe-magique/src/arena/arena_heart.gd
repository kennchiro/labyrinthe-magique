class_name ArenaHeart
extends Node2D

## La GEMME-CŒUR au centre de l'arène, et le cercle qu'il faut tenir.
##
## Peinte (`assets/arena/gemme/`, `tools/build_arena.py`) : un socle et une gemme par état — libre,
## bleus, rouges, disputée. Le jeu garde ce qui BOUGE : la gemme flotte au-dessus de son socle, et le
## cercle à tenir pulse, aux couleurs de l'équipe qui la tient seule, blanc et rapide quand elle est
## disputée. Sans les images, elle est dessinée par le code, comme avant.

const NEUTRAL := Color(0.92, 0.94, 1.0)
const CONTESTED := Color(1.0, 1.0, 1.0)

const FOLDER := "res://assets/arena/gemme/"
## Hauteur de l'image (socle et gemme) à l'écran, en cases.
const PAINTED_HEIGHT := 2.1
const STATES := ["libre", "bleus", "rouges", "disputee"]

var arena: ArenaMatch = null
var tile := 32
## Redressement de la vue en volume (`CameraRules.stand_scale`) : la gemme est debout, le cercle couché.
var stand := 1.0
var _time := 0.0
var _gems: Array[Texture2D] = []
var _socles: Array[Texture2D] = []
var _ring: Texture2D = null


func setup(p_arena: ArenaMatch, p_tile: int) -> void:
	arena = p_arena
	tile = p_tile
	position = (Vector2(ArenaRules.HEART_CELL) + Vector2(0.5, 0.5)) * float(tile)
	for state in STATES:
		var gem := FOLDER + "gemme_%s.png" % state
		var socle := FOLDER + "socle_%s.png" % state
		if ResourceLoader.exists(gem) and ResourceLoader.exists(socle):
			_gems.append(load(gem))
			_socles.append(load(socle))
	if _gems.size() != STATES.size():
		_gems.clear()
		_socles.clear()
	if ResourceLoader.exists(FOLDER + "anneau.png"):
		_ring = load(FOLDER + "anneau.png")


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _tint() -> Color:
	if arena == null:
		return NEUTRAL
	match arena.holder:
		0, 1:
			return ArenaRules.TEAM_COLORS[arena.holder]
		2:
			return CONTESTED
	return NEUTRAL


func _draw() -> void:
	if arena == null:
		return
	var tint := _tint()
	var radius := (float(ArenaRules.HEART_RADIUS) + 0.5) * float(tile)
	var pulse := 0.5 + 0.5 * sin(_time * (9.0 if arena.holder == 2 else 2.4))
	# Le cercle à tenir, couché au sol.
	draw_circle(Vector2.ZERO, radius, Color(tint, 0.08 + 0.06 * pulse))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, Color(tint, 0.55 + 0.3 * pulse), 2.5, true)
	if _ring != null:
		# L'anneau gravé de la planche, couché au sol sous le cercle, qui tourne lentement.
		var side := radius * 1.55
		draw_set_transform(Vector2.ZERO, _time * 0.12, Vector2.ONE)
		draw_texture_rect(_ring, Rect2(Vector2(-side, -side) * 0.5, Vector2(side, side)), false, Color(tint, 0.55))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		for k in 12:
			var angle := _time * 0.35 + TAU * float(k) / 12.0
			draw_arc(Vector2.ZERO, radius - 5.0, angle, angle + 0.22, 6, Color(tint, 0.6), 2.0, true)
	if not _gems.is_empty():
		_draw_painted(pulse)
		return
	# Le socle.
	draw_set_transform(Vector2(0.0, tile * 0.18), 0.0, Vector2(1.0, 0.5))
	draw_circle(Vector2.ZERO, tile * 0.55, Color(0.25, 0.24, 0.3, 0.95))
	draw_arc(Vector2.ZERO, tile * 0.55, 0.0, TAU, 32, Color(tint, 0.9), 2.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# La gemme, qui flotte au-dessus du socle.
	var lift := -tile * (0.55 + 0.08 * sin(_time * 2.0))
	var h := tile * 0.42
	var w := tile * 0.28
	var top := Vector2(0.0, lift - h)
	var bottom := Vector2(0.0, lift + h * 0.7)
	var left := Vector2(-w, lift)
	var right := Vector2(w, lift)
	draw_circle(Vector2(0.0, lift), tile * (0.55 + 0.1 * pulse), Color(tint, 0.18))
	draw_colored_polygon(PackedVector2Array([top, right, bottom, left]), tint.lerp(Color.WHITE, 0.25))
	draw_colored_polygon(PackedVector2Array([top, Vector2(0.0, lift), left]), tint.lerp(Color.WHITE, 0.6))
	draw_colored_polygon(PackedVector2Array([Vector2(0.0, lift), right, bottom]), tint.darkened(0.25))
	draw_polyline(PackedVector2Array([top, right, bottom, left, top]), Color(0.05, 0.05, 0.1, 0.9), 1.5, true)


## Le socle posé sur sa case, la gemme qui flotte au-dessus. Les deux images ont la même boîte : sans
## flottement, elles retombent exactement l'une sur l'autre.
func _draw_painted(pulse: float) -> void:
	var state := 0
	match arena.holder:
		0, 1:
			state = 1 + arena.holder
		2:
			state = 3
	var socle := _socles[state]
	var width := PAINTED_HEIGHT * float(tile) * float(socle.get_width()) / float(socle.get_height())
	var height := PAINTED_HEIGHT * float(tile) * stand
	# Le bas de l'image au bas de la case.
	var box := Rect2(Vector2(-width * 0.5, float(tile) * 0.5 - height), Vector2(width, height))
	draw_texture_rect(socle, box, false)
	var lift := -float(tile) * (0.12 + 0.08 * sin(_time * 2.0))
	var tint := _tint()
	draw_circle(box.position + Vector2(width * 0.5, height * 0.35 + lift), float(tile) * (0.5 + 0.1 * pulse), Color(tint, 0.16))
	draw_texture_rect(_gems[state], Rect2(box.position + Vector2(0.0, lift), box.size), false)
