class_name GaolerChains
extends Node2D

## Les chaînes du Geôlier : celles qui le relient à ses proies, celles que la Geôle fait sortir du
## sol, et le Crochet en vol. Maillon par maillon, d'après `assets/characters/geolier/pieces/`.
##
## Elle ne décide de rien : le `CombatSystem` dit qui est enchaîné. Ici, on le montre.

const LINK := preload("res://assets/characters/geolier/pieces/maillon.png")
const HOOK := preload("res://assets/characters/geolier/pieces/crochet.png")
const CYAN := Color("#16e0e8")
const PALE := Color("#e6fdff")
const DEEP := Color("#0a6f7a")
## L'écart entre deux maillons et leur taille, en cases. Un sur deux est vu de profil.
const LINK_STEP := 0.2
const LINK_TILES := 0.24
const HOOK_TILES := 0.55
const HOOK_THROW := 0.16
const HOOK_HOLD := 0.34
## La Geôle : trois chaînes par proie, qui montent du sol en 0,25 s.
const GAOL_CHAINS := 3
const GAOL_RISE := 0.25
const BODY := 0.55

var _tile := 64.0
var _player: Node2D = null
var _enemies: Array = []
var _combat: CombatSystem = null
var _time := 0.0
var _stand := -1.0
var _hook_from := Vector2.ZERO
var _hook_enemy: Node2D = null
var _hook_left := 0.0
var _gaol_age := 99.0


func show_state(enemies: Array, combat: CombatSystem, player: Node2D, tile_size: int) -> void:
	# `WorldStage` étire ce qui entre dans `Entities` : ici, cela déplacerait les chaînes.
	if _stand < 0.0:
		_stand = scale.y
		scale = Vector2.ONE
	_enemies = enemies
	_combat = combat
	_player = player
	_tile = float(tile_size)
	queue_redraw()


func throw_hook(from: Vector2, enemy: Node2D) -> void:
	_hook_from = from
	_hook_enemy = enemy
	_hook_left = HOOK_THROW + HOOK_HOLD


func raise_gaol() -> void:
	_gaol_age = 0.0


func _process(delta: float) -> void:
	_time += delta
	_hook_left = maxf(0.0, _hook_left - delta)
	_gaol_age += delta


func _body(enemy: Node2D) -> Vector2:
	return enemy.position + Vector2(0.0, -BODY * _tile)


func _chest() -> Vector2:
	return _player.position + Vector2(0.0, -0.75 * _tile)


func _draw() -> void:
	if _combat == null or _player == null or not is_instance_valid(_player):
		return
	for index: int in _combat.soul_chain_members():
		if index < _enemies.size() and not (_enemies[index] as Enemy).dead:
			_draw_chain(_chest(), _body(_enemies[index]), 0.5 + 0.5 * sin(_time * 7.0 + float(index)), 0.1)
	var rise := clampf(_gaol_age / GAOL_RISE, 0.0, 1.0)
	for index: int in _combat.gaol_members():
		if index >= _enemies.size() or (_enemies[index] as Enemy).dead:
			continue
		var body := _body(_enemies[index])
		for c in GAOL_CHAINS:
			var angle := float(c) / float(GAOL_CHAINS) * TAU + float(index) * 0.7
			var ground: Vector2 = (_enemies[index] as Node2D).position \
				+ Vector2(cos(angle) * 0.75, sin(angle) * 0.35) * _tile
			_draw_chain(ground, ground.lerp(body, rise), 0.5 + 0.5 * sin(_time * 9.0 + angle), 0.04)
	_draw_hook()


func _draw_hook() -> void:
	if _hook_left <= 0.0 or _hook_enemy == null or not is_instance_valid(_hook_enemy):
		return
	var start := _chest()
	var elapsed := HOOK_THROW + HOOK_HOLD - _hook_left
	var tip: Vector2
	if elapsed < HOOK_THROW:
		tip = start.lerp(_hook_from, elapsed / HOOK_THROW)
	else:
		# Le crochet a pris : l'ennemi est déjà ramené, la chaîne se rétracte avec lui.
		tip = _body(_hook_enemy).lerp(start, (elapsed - HOOK_THROW) / HOOK_HOLD)
	_draw_chain(start, tip, 1.0, 0.0)
	var unit := HOOK_TILES * _tile / float(HOOK.get_height())
	draw_set_transform(tip, (tip - start).angle() + PI / 2.0, Vector2(unit, unit * _stand))
	draw_texture(HOOK, -Vector2(HOOK.get_size()) * 0.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Une chaîne : un filet de flamme froide dessous, puis les maillons, un sur deux de profil.
## `glow` bat entre 0 et 1, `sag` la fait pendre un peu au milieu.
func _draw_chain(from: Vector2, to: Vector2, glow: float, sag: float) -> void:
	var length := from.distance_to(to)
	if length < 2.0:
		return
	var steps := maxi(2, int(length / (LINK_STEP * _tile)))
	var points := PackedVector2Array()
	for s in steps + 1:
		var share := float(s) / float(steps)
		points.append(from.lerp(to, share) + Vector2(0.0, sin(share * PI) * sag * length))
	draw_polyline(points, DEEP, _tile * 0.16)
	draw_polyline(points, CYAN.lerp(PALE, glow * 0.6), _tile * 0.07)
	var unit := LINK_TILES * _tile / float(LINK.get_width())
	for s in steps:
		var at := (points[s] + points[s + 1]) * 0.5
		var angle := (points[s + 1] - points[s]).angle()
		var flat := 0.42 if s % 2 == 1 else 1.0
		draw_set_transform(at, angle, Vector2(unit, unit * flat * _stand))
		draw_texture(LINK, -Vector2(LINK.get_size()) * 0.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Les âmes qui courent le long de la chaîne : deux perles de flamme froide, du lanceur à la proie.
	for bead in 2:
		var share := fmod(_time * 1.6 + float(bead) * 0.5, 1.0)
		var at: Vector2 = points[int(share * float(steps))]
		draw_circle(at, _tile * 0.11, DEEP)
		draw_circle(at, _tile * 0.075, CYAN)
		draw_circle(at, _tile * 0.04, PALE)
