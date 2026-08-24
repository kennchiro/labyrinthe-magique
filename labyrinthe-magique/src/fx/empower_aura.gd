class_name EmpowerAura
extends Node2D

## L'aura d'un mage EXALTÉ : elle dit, tant qu'elle tourne, que les coups
## portent plus fort.
##
## Un bonus de dégâts est la seule chose d'un jeu d'action qu'on ne peut pas
## voir : les chiffres montent, mais rien à l'écran ne dit pourquoi. L'aura est
## donc obligatoire, pas décorative — sans elle, le joueur ne saurait ni qu'il
## est renforcé, ni quand ça s'arrête.
##
## Elle vit ATTACHÉE au mage et le suit ; elle s'éteint d'elle-même à
## l'échéance, et se rallume à neuf si l'ultime est relancé.

const RING_COUNT := 3

var tile_size: int = 32

var _tint := Color(0.5, 0.85, 1.0)
var _left := 0.0
var _total := 1.0
var _time := 0.0


func setup(p_tile_size: int, tint: Color, duration: float) -> void:
	tile_size = p_tile_size
	_tint = tint
	_total = maxf(0.1, duration)
	_left = _total
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	self.material = material


## Relancée : l'aura repart à plein plutôt que d'en démarrer une seconde.
func refresh(duration: float) -> void:
	_total = maxf(0.1, duration)
	_left = _total


func stop() -> void:
	_left = 0.0


func _process(delta: float) -> void:
	_time += delta
	_left = maxf(0.0, _left - delta)
	if _left <= 0.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	# Les anneaux MONTENT le long du mage plutôt que de s'étaler au sol : une
	# exaltation soulève, elle ne se répand pas — et au sol, elle se serait
	# confondue avec les zones de sorts.
	var fade := clampf(_left / _total, 0.0, 1.0)
	var glow := 0.35 + 0.3 * (0.5 + 0.5 * sin(_time * 4.0))
	for i in RING_COUNT:
		var phase := fposmod(_time * 0.8 + float(i) / float(RING_COUNT), 1.0)
		var height := -tile_size * (0.2 + 1.5 * phase)
		var radius := tile_size * (0.62 - 0.30 * phase)
		draw_arc(Vector2(0.0, height), radius, 0.0, TAU, 26,
			Color(_tint.r, _tint.g, _tint.b, glow * (1.0 - phase) * fade), 2.0)
	# Un dernier battement plus vif dans la dernière seconde : c'est le seul
	# avertissement que le joueur a avant de perdre son bonus.
	if _left < 1.0:
		var warn := 0.5 + 0.5 * sin(_time * 18.0)
		draw_arc(Vector2(0.0, -tile_size * 0.3), tile_size * 0.75, 0.0, TAU, 26,
			Color(1.0, 1.0, 1.0, 0.5 * warn * fade), 2.0)
