class_name BossStrip
extends Sprite2D

## Une bande de huit images de boss, jouée une fois en un temps donné : son arrivée, son
## geste de loin, sa mort, ou un temps de la zone au sol.

signal finished

const FRAMES := 8

var _duration := 1.0
var _elapsed := 0.0
var _fade := 0.0
var _done := false


## `fade` : le temps de disparaître une fois la dernière image atteinte, à zéro le nœud
## reste sur sa dernière image et c'est son parent qui décide de la suite.
func play(strip: Texture2D, duration: float, fade: float = 0.0) -> void:
	texture = strip
	hframes = FRAMES
	frame = 0
	_duration = maxf(0.01, duration)
	_elapsed = 0.0
	_fade = fade
	_done = false
	modulate.a = 1.0


func _process(delta: float) -> void:
	if _done:
		return
	_elapsed += delta
	frame = mini(int(_elapsed / _duration * float(FRAMES)), FRAMES - 1)
	if _elapsed < _duration:
		return
	if _fade > 0.0 and _elapsed < _duration + _fade:
		modulate.a = 1.0 - (_elapsed - _duration) / _fade
		return
	_done = true
	finished.emit()
