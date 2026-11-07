class_name TransformButton
extends Control

## Le bouton de la TRANSFORMATION d'Aël, à part de l'éventail des six sorts (demande du joueur,
## 2026-11-04) : son Extra garde la Nova, et la transformation a son geste à elle, comme dans DBZ.
##
## Il se pose à droite de la barre du mage : l'éventail est réglé et testé pour six boutons, et ce
## geste rare n'a pas à se trouver sous le pouce. Il se voit à partir du niveau 30 seulement.
## Il montre où en est la charge (ses kills depuis la dernière transformation), il bat quand il est
## prêt, il compte les secondes en Prisme, et il est éteint pendant l'épuisement. Au clavier : T.

signal pressed

const GOLD := Color("#f2c94c")
const PALE := Color("#fff4c8")
const RIM := Color("#16202b")
const DIM := Color("#5c6577")

## {"ratio": 0..1, "ready": bool, "state": Transformation.State, "seconds": float}
var info := {}
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(64.0, 76.0)
	size = custom_minimum_size


func set_info(next: Dictionary) -> void:
	info = next
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if visible:
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var touched := event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed
	var clicked := event is InputEventMouseButton and (event as InputEventMouseButton).pressed \
		and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
	if touched or clicked:
		pressed.emit()
		accept_event()


func _draw() -> void:
	var centre := Vector2(size.x * 0.5, 30.0)
	var radius := 26.0
	var state: int = info.get("state", Transformation.State.NORMAL)
	var ready: bool = info.get("ready", false)
	var ratio: float = info.get("ratio", 0.0)
	var in_prism := state == Transformation.State.PRISM or state == Transformation.State.CHARGING
	var tired := state == Transformation.State.EXHAUSTED
	var beat := 0.5 + 0.5 * sin(_time * 6.0)
	# Le halo qui bat quand il est prêt.
	if ready:
		draw_circle(centre, radius * (1.25 + 0.12 * beat), Color(GOLD, 0.25 + 0.2 * beat))
	draw_circle(centre, radius + 3.0, RIM)
	draw_circle(centre, radius, Color("#1d2638") if not ready else Color("#3a2e10"))
	# La jauge : la charge, ou les secondes de Prisme qui restent.
	var fill := ratio
	var gauge := GOLD if not tired else DIM
	if in_prism:
		fill = clampf(float(info.get("seconds", 0.0)) / float(info.get("max_seconds", Transformation.MAX_TIME)),
			0.0, 1.0)
		gauge = PALE
	if fill > 0.0:
		draw_arc(centre, radius - 3.0, -PI * 0.5, -PI * 0.5 + TAU * fill, 40, gauge, 4.0, true)
	# Le symbole : une gemme taillée entourée de quatre rayons, ou la flamme de l'Éveil des mages.
	var gem := Color(PALE if ready or in_prism else DIM)
	var s := radius * 0.42
	if info.get("symbol", "") == "flame":
		_draw_flame(centre, s, gem, ready or in_prism, beat)
		_draw_label(centre, radius, ready, in_prism, tired)
		return
	if info.get("symbol", "") == "water":
		_draw_water(centre, s, gem, ready or in_prism, beat)
		_draw_label(centre, radius, ready, in_prism, tired)
		return
	draw_colored_polygon(PackedVector2Array([centre + Vector2(0, -s * 1.3), centre + Vector2(s, 0),
		centre + Vector2(0, s * 1.3), centre + Vector2(-s, 0)]), gem)
	draw_colored_polygon(PackedVector2Array([centre + Vector2(0, -s * 0.6), centre + Vector2(s * 0.45, 0),
		centre + Vector2(0, s * 0.6), centre + Vector2(-s * 0.45, 0)]), Color(1, 1, 1, 0.85 if ready or in_prism else 0.3))
	for i in 4:
		var dir := Vector2.from_angle(PI * 0.25 + PI * 0.5 * float(i))
		draw_line(centre + dir * s * 1.25, centre + dir * s * (1.7 + 0.25 * beat * float(ready)), gem, 2.0)
	_draw_label(centre, radius, ready, in_prism, tired)


## Une flamme à trois langues, cœur pâle : l'Éveil.
func _draw_flame(centre: Vector2, s: float, tint: Color, lit: bool, beat: float) -> void:
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in 25:
		var t := float(i) / 24.0
		var angle := TAU * t
		var r := s * (1.15 + 0.35 * maxf(0.0, -sin(angle)) * (0.8 + 0.2 * beat * float(lit)))
		var tongue := 1.0 + 0.25 * maxf(0.0, -sin(angle * 3.0 + PI * 0.5))
		outer.append(centre + Vector2(cos(angle) * s * 0.95, sin(angle) * r * tongue))
		inner.append(centre + Vector2(cos(angle) * s * 0.45, sin(angle) * r * 0.55 + s * 0.2))
	draw_colored_polygon(outer, Color("#ff7a2a") if lit else tint)
	draw_colored_polygon(inner, Color(1.0, 0.95, 0.75, 0.95 if lit else 0.35))


## Une goutte cerclée d'une vague : l'Éveil de l'Eau.
func _draw_water(centre: Vector2, s: float, tint: Color, lit: bool, beat: float) -> void:
	var drop := PackedVector2Array([
		centre + Vector2(0.0, -s * 1.45), centre + Vector2(s * 0.68, -s * 0.05),
		centre + Vector2(s * 0.62, s * 0.68), centre + Vector2(0.0, s),
		centre + Vector2(-s * 0.62, s * 0.68), centre + Vector2(-s * 0.68, -s * 0.05),
	])
	draw_colored_polygon(drop, Color("#37c6ff") if lit else tint)
	var wave_y := centre.y + s * (0.36 + 0.08 * sin(_time * 5.0) * float(lit))
	draw_arc(Vector2(centre.x, wave_y), s * (0.72 + 0.08 * beat * float(lit)), PI * 0.12, PI * 0.88,
		24, Color("#e9ffff") if lit else Color(tint, 0.45), 2.4, true)


## Le libellé, sous le bouton.
func _draw_label(centre: Vector2, radius: float, ready: bool, in_prism: bool, tired: bool) -> void:
	var text := str(info.get("label_on", "PRISME")) if in_prism else ("ÉPUISÉ" if tired \
		else str(info.get("label_ready", "TRANSFO")))
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11).x
	draw_string(font, Vector2((size.x - width) * 0.5, centre.y + radius + 16.0), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, GOLD if ready or in_prism else DIM)
