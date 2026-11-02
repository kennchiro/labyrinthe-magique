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

## Hauteur du nuage au-dessus du mage, en cases.
const HEIGHT := 2.05
const QUAD_TILES := Vector2(2.2, 1.44)

var tile_size: int = 32

var _left := 0.0
var _total := 1.0
## Monte à 1 au moment d'une décharge, puis retombe : c'est l'éclair interne.
var _flash := 0.0
var _quad: Sprite2D = null


func setup(p_tile_size: int, duration: float) -> void:
	tile_size = p_tile_size
	_total = maxf(0.1, duration)
	_left = _total
	_quad = PaintedFx.add(self, "thunder_storm", QUAD_TILES * float(tile_size),
		Vector2(0.0, -float(tile_size) * HEIGHT))


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
	_flash = maxf(0.0, _flash - delta * 5.0)
	_left = maxf(0.0, _left - delta)
	if _left <= 0.0:
		queue_free()
		return
	var material: ShaderMaterial = _quad.material
	material.set_shader_parameter("flash", _flash)
	# Dislocation dans la dernière seconde : les bouffées s'écartent avant de
	# disparaître, ce qui annonce la fin du sort. Il pâlit aussi avec le temps qui reste.
	material.set_shader_parameter("breaking", 1.0 - clampf(_left, 0.0, 1.0))
	_quad.modulate.a = (0.6 + 0.4 * clampf(_left / _total, 0.0, 1.0)) * clampf(_left, 0.0, 1.0)
