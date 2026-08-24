class_name StormCloud
extends Node2D

## Le nuage d'orage : il flotte au-dessus du mage et le suit partout.
##
## Attaché au personnage, donc il n'a rien à poursuivre — il EST sur lui. Ce qui
## demande du soin, en revanche, c'est qu'il ne l'écrase pas : le mage doit
## rester lisible sous son propre sort, sinon on perd son personnage dès qu'on
## invoque. D'où un nuage HAUT (une case et demie au-dessus), sombre plutôt que
## lumineux, et qui ne descend jamais sur la case du joueur.
##
## Il dit trois choses :
##   qu'il est là        — une masse sombre qui roule au-dessus de la tête
##   qu'il est chargé    — des lueurs internes qui pulsent entre deux décharges
##   qu'il va partir     — il pâlit et se disloque dans sa dernière seconde

const PUFFS := 5
## Hauteur du nuage au-dessus du mage, en cases.
const HEIGHT := 1.5

var tile_size: int = 32

var _tint := Color(0.55, 0.7, 1.0)
var _left := 0.0
var _total := 1.0
var _time := 0.0
## Monte à 1 au moment d'une décharge, puis retombe : c'est l'éclair interne.
var _flash := 0.0


func setup(p_tile_size: int, tint: Color, duration: float) -> void:
	tile_size = p_tile_size
	_tint = tint
	_total = maxf(0.1, duration)
	_left = _total


func refresh(duration: float) -> void:
	_total = maxf(0.1, duration)
	_left = _total


## Une décharge part : le nuage s'illumine de l'intérieur une fraction de
## seconde. C'est ce qui relie visuellement le nuage à l'éclair qui en tombe —
## sans quoi les deux semblent indépendants.
func discharge() -> void:
	_flash = 1.0


func stop() -> void:
	_left = 0.0


func _process(delta: float) -> void:
	_time += delta
	_flash = maxf(0.0, _flash - delta * 5.0)
	_left = maxf(0.0, _left - delta)
	if _left <= 0.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var fade := clampf(_left / _total, 0.0, 1.0)
	# Dislocation dans la dernière seconde : les bouffées s'écartent avant de
	# disparaître, ce qui annonce la fin du sort.
	var breaking := 1.0 - clampf(_left, 0.0, 1.0)
	var centre := Vector2(0.0, -tile_size * HEIGHT)

	for i in PUFFS:
		var angle := TAU * float(i) / float(PUFFS) + _time * 0.35
		var drift := Vector2(cos(angle), sin(angle) * 0.42)
		var spread := tile_size * (0.42 + 0.35 * breaking)
		var at := centre + drift * spread
		var size := tile_size * (0.34 - 0.05 * float(i % 2))
		# Un nuage d'orage est SOMBRE — mais pas noir. À 0,16 de luminosité il
		# se lisait comme un trou dans le décor plutôt que comme une masse.
		# Le corps est donc relevé, et une frange CLAIRE est posée par-dessus
		# sur son bord supérieur : c'est le relief qui le fait exister.
		var lit := 0.34 + 0.50 * _flash
		draw_circle(at, size, Color(_tint.r * lit, _tint.g * lit,
			minf(1.0, _tint.b * (lit + 0.22)), (0.72 + 0.22 * _flash) * fade))
		draw_arc(at, size * 0.94, PI * 1.12, TAU - PI * 0.12, 14,
			Color(minf(1.0, _tint.r + 0.35), minf(1.0, _tint.g + 0.35), 1.0,
				(0.30 + 0.45 * _flash) * fade), 2.0)

	# Lueurs internes entre deux décharges : le nuage se recharge.
	var pulse := 0.5 + 0.5 * sin(_time * 3.0)
	draw_circle(centre, tile_size * 0.30,
		Color(_tint.r, _tint.g, 1.0, (0.14 + 0.42 * _flash + 0.08 * pulse) * fade))
	# Deux crocs de charge sous le nuage, qui s'allument avant la décharge :
	# ils annoncent l'éclair une fraction de seconde avant qu'il ne tombe.
	if _flash > 0.05 or pulse > 0.8:
		var spark := maxf(_flash, (pulse - 0.8) * 3.0)
		for side in [-1.0, 1.0]:
			draw_line(centre + Vector2(side * tile_size * 0.16, tile_size * 0.12),
				centre + Vector2(side * tile_size * 0.24, tile_size * 0.34),
				Color(1.0, 1.0, 1.0, 0.55 * spark * fade), 2.0)
