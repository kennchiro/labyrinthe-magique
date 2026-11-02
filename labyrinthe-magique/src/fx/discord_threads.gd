class_name DiscordThreads
extends Node2D

## Les fils de la Démone de la Discorde, tracés d'un ennemi à l'autre. Ils relient des corps qui
## bougent : un shader posé sur un quad ne les suivrait pas.
##
##   LA POSSESSION : quatre fils tombent de l'œil aux membres, et tirent par à-coups.
##   LE LIEN : une chaîne de maillons entre les enchaînés, où court une onde magenta.
##   LE CERCLE : une toile entre les ennemis présents, qui bat plus vite s'ils sont nombreux.
##   LE TROUBLE : un petit fil de plus au-dessus de la tête à chaque murmure.

## Hauteur de l'œil au-dessus de la case du possédé, en cases.
const EYE_HEIGHT := 1.15
## Hauteur du grand œil de l'extra au-dessus d'elle. C'est de lui que partent les fils.
const GREAT_EYE_HEIGHT := 3.0
const SILVER := Color("#c9d2d6")
const PALE := Color("#ffe3f1")
const MAGENTA := Color("#e8308f")
const DEEP := Color("#6a0f4a")
const BLACK := Color("#161a1c")
const LINK_GAP := 0.2
const SAG := 0.12
const GLOW := Color(0.91, 0.188, 0.561, 0.35)
## Les fils de l'extra partent d'elle et atteignent chaque ennemi en ce temps.
const LAUNCH_TIME := 0.32
const LAUNCH_HOLD := 0.3

var _enemies: Array = []
var _combat: CombatSystem = null
var _player: Node2D = null
var _tile := 64.0
var _launch_left := 0.0


func show_state(enemies: Array, combat: CombatSystem, tile_size: int, player: Node2D) -> void:
	_enemies = enemies
	_player = player
	_combat = combat
	_tile = float(tile_size)
	queue_redraw()


## L'extra vient de partir : un fil file vers chaque ennemi retourné.
func launch() -> void:
	_launch_left = LAUNCH_TIME + LAUNCH_HOLD


func _process(delta: float) -> void:
	_launch_left = maxf(0.0, _launch_left - delta)


func _draw() -> void:
	if _combat == null:
		return
	var clock := float(Time.get_ticks_msec()) * 0.001
	if _launch_left > 0.0:
		_draw_launch()
	for index: int in _combat.possessed_indices():
		_draw_strings(_body(index), clock + float(index))
	for web: Array in _combat.discord_webs():
		_draw_web(web, clock)
	_draw_chain(_combat.bond_members(), clock)
	for index in _enemies.size():
		var enemy: Enemy = _enemies[index]
		if enemy.dead or index in _combat.possessed_indices():
			continue
		var whispers := _combat.whispers_on(index)
		if whispers > 0:
			_draw_whispers(enemy.global_position, whispers, clock + float(index))


func _draw_launch() -> void:
	var run := minf(1.0, (LAUNCH_TIME + LAUNCH_HOLD - _launch_left) / LAUNCH_TIME)
	run = 1.0 - (1.0 - run) * (1.0 - run)
	var from := Vector2.ZERO
	if _player != null and is_instance_valid(_player):
		from = to_local(_player.global_position) + Vector2(0.0, -_tile * GREAT_EYE_HEIGHT)
	for index: int in _combat.possessed_indices():
		var at := _body(index)
		if at == Vector2.INF:
			continue
		var tip := from.lerp(at + Vector2(0.0, -_tile * 0.4), run)
		var points := _sagged(from, tip, 0.1 * (1.0 - run), 6)
		draw_polyline(points, GLOW, 7.0)
		draw_polyline(points, BLACK, 3.0)
		draw_polyline(points, SILVER, 1.4)
		draw_circle(tip, _tile * 0.08, MAGENTA)
		draw_circle(tip, _tile * 0.04, PALE)


func _body(index: int) -> Vector2:
	if index < 0 or index >= _enemies.size() or _enemies[index].dead:
		return Vector2.INF
	return to_local(_enemies[index].global_position)


func _draw_strings(at: Vector2, clock: float) -> void:
	if at == Vector2.INF:
		return
	var eye := at + Vector2(0.0, -_tile * EYE_HEIGHT)
	for i in 4:
		var side := (float(i) - 1.5) / 1.5
		var tug := sin(clock * 9.0 + float(i) * 1.7) * 0.05
		var hand := at + Vector2(side * _tile * 0.32, -_tile * (0.25 + tug) + absf(side) * -_tile * 0.08)
		var points := _sagged(eye + Vector2(side * _tile * 0.24, 0.0), hand, 0.04, 6)
		draw_polyline(points, GLOW, 6.0)
		draw_polyline(points, BLACK, 3.0)
		draw_polyline(points, SILVER, 1.4)
		var bead := fposmod(clock * 1.6 + float(i) * 0.27, 1.0)
		draw_circle(points[int(bead * float(points.size() - 1))], _tile * 0.03, MAGENTA)


func _draw_web(members: Array, clock: float) -> void:
	var bodies := PackedVector2Array()
	for index: int in members:
		var at := _body(index)
		if at != Vector2.INF:
			bodies.append(at + Vector2(0.0, -_tile * 0.3))
	var pace := 3.0 + float(bodies.size()) * 2.0
	var bright := 0.5 + 0.5 * sin(clock * pace)
	for a in bodies.size():
		for b in range(a + 1, bodies.size()):
			var points := _sagged(bodies[a], bodies[b], SAG, 8)
			draw_polyline(points, BLACK, 3.0)
			draw_polyline(points, DEEP.lerp(MAGENTA, bright), 1.6)
		draw_circle(bodies[a], _tile * 0.05, PALE.lerp(MAGENTA, bright))


func _draw_chain(members: Array, clock: float) -> void:
	var bodies := PackedVector2Array()
	for index: int in members:
		var at := _body(index)
		if at != Vector2.INF:
			bodies.append(at + Vector2(0.0, -_tile * 0.45))
	for a in range(bodies.size() - 1):
		_draw_links(bodies[a], bodies[a + 1], clock)
	if bodies.size() > 2:
		_draw_links(bodies[bodies.size() - 1], bodies[0], clock)


## Des maillons qui alternent à plat et de chant : c'est ce qui se lit comme une chaîne.
func _draw_links(from: Vector2, to: Vector2, clock: float) -> void:
	var length := from.distance_to(to)
	var count := maxi(2, int(length / (_tile * LINK_GAP)))
	var along := (to - from) / maxf(1.0, length)
	for i in count:
		var at := from.lerp(to, (float(i) + 0.5) / float(count))
		var pulse := 1.0 - minf(1.0, absf(fposmod(float(i) / float(count) - clock * 0.8, 1.0) - 0.5) * 8.0)
		var tint := SILVER.lerp(MAGENTA, pulse)
		var half := along * _tile * LINK_GAP * 0.42
		var side := Vector2(-along.y, along.x) * _tile * (0.045 if i % 2 == 0 else 0.015)
		var link := PackedVector2Array([at - half, at + side, at + half, at - side, at - half])
		draw_polyline(link, BLACK, 3.0)
		draw_polyline(link, tint, 1.4)


func _draw_whispers(world: Vector2, count: int, clock: float) -> void:
	var centre := to_local(world) + Vector2(0.0, -_tile * 1.05)
	for i in count:
		var angle := clock * 2.4 + float(i) * TAU / 3.0
		var at := centre + Vector2(cos(angle) * _tile * 0.26, sin(angle) * _tile * 0.08)
		var points := _sagged(at + Vector2(0.0, -_tile * 0.1), at + Vector2(0.0, _tile * 0.1), 0.03, 4)
		draw_polyline(points, BLACK, 3.0)
		draw_polyline(points, SILVER, 1.4)
		draw_circle(points[points.size() - 1], _tile * 0.035, MAGENTA)


## Un fil n'est pas une droite : il pend un peu entre ses deux bouts.
func _sagged(from: Vector2, to: Vector2, sag: float, steps: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in steps + 1:
		var t := float(i) / float(steps)
		points.append(from.lerp(to, t) + Vector2(0.0, sin(t * PI) * _tile * sag))
	return points
