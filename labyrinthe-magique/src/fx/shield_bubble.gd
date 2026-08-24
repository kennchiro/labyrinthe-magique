class_name ShieldBubble
extends Node2D

## La coque d'eau du Bouclier : la seule chose du jeu qui PROTÈGE au lieu de
## blesser, et qui n'avait aucun langage visuel.
##
## Elle doit dire trois choses en même temps, sans un mot :
##   qu'elle est là          — une bulle fermée autour du mage
##   ce qu'il en reste       — son épaisseur et son opacité fondent avec
##                             l'absorption restante, pas avec le temps
##   qu'elle va tomber       — elle bat plus vite dans sa dernière seconde
##
## L'OPACITÉ suit l'absorption et non la durée, et c'est le choix qui compte :
## un bouclier vidé en deux coups doit se voir disparaître tout de suite, même
## s'il lui restait vingt secondes au compteur.
##
## Elle est en mélange NORMAL et non additif. En additif, un intérieur plein
## éclaircit le mage au lieu de le teinter : on obtient un halo blanc qui efface
## le personnage, pas une coque d'eau qu'on voit à travers. Le bord, lui, reste
## FIN — une coque épaisse se lit comme un mur, alors qu'elle doit se lire
## comme une membrane.

const RIPPLES := 2

var tile_size: int = 32

var _tint := Color(0.45, 0.85, 1.0)
var _amount := 1.0
var _left := 0.0
var _total := 1.0
var _time := 0.0


func setup(p_tile_size: int, tint: Color, duration: float) -> void:
	tile_size = p_tile_size
	_tint = tint
	_total = maxf(0.1, duration)
	_left = _total
	_amount = 1.0


## Part d'absorption restante, de 1 à 0.
func set_amount(ratio: float) -> void:
	_amount = clampf(ratio, 0.0, 1.0)


func refresh(duration: float) -> void:
	_total = maxf(0.1, duration)
	_left = _total
	_amount = 1.0


func _process(delta: float) -> void:
	_time += delta
	_left = maxf(0.0, _left - delta)
	if _left <= 0.0 or _amount <= 0.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	# Le rayon ne bouge plus avec l'absorption : c'est l'OPACITÉ qui fond. Une
	# coque qui rétrécit donnait l'impression de se resserrer sur le mage,
	# alors qu'elle s'use.
	var radius := tile_size * 0.80
	var body := 0.34 * _amount
	var edge := 0.55 + 0.35 * _amount

	# La dernière seconde bat vite : c'est l'avertissement avant de redevenir
	# vulnérable, et il doit arriver AVANT le coup qui fait mal.
	if _left < 1.0:
		var warn := 0.5 + 0.5 * sin(_time * 20.0)
		edge *= 0.4 + 0.6 * warn
		body *= 0.4 + 0.6 * warn

	var centre := Vector2(0.0, -tile_size * 0.35)
	# Intérieur PLEIN, translucide : on voit le mage au travers, teinté d'eau.
	draw_circle(centre, radius, Color(_tint.r, _tint.g, _tint.b, body))
	# Bord fin et clair : une membrane, pas un mur.
	draw_arc(centre, radius, 0.0, TAU, 44,
		Color(minf(1.0, _tint.r + 0.4), minf(1.0, _tint.g + 0.25), 1.0, edge), 1.5)

	# Des ondes qui montent le long de la coque : une bulle parfaitement
	# immobile se lit comme un cercle dessiné, pas comme de l'eau.
	for i in RIPPLES:
		var phase := fposmod(_time * 0.7 + float(i) / float(RIPPLES), 1.0)
		draw_arc(centre, radius * (0.55 + 0.45 * phase),
			-PI * 0.85, -PI * 0.15, 18,
			Color(1.0, 1.0, 1.0, 0.26 * (1.0 - phase) * _amount), 1.0)
