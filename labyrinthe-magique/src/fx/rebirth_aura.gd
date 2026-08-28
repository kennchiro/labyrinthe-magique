class_name RebirthAura
extends Node2D

## L'AURA DE RENAISSANCE : elle dit, tant qu'elle brûle, que ses coups portent
## plus fort.
##
## Elle vit ATTACHÉE au mage et le suit partout, comme l'égide de la Terre — un
## bonus qui le suit ne peut pas être posé quelque part.
##
## DEUX TEMPS, UNE SEULE PLANCHE
##
## La bande a été dessinée comme un jaillissement : le cercle de runes s'allume,
## les quatre rubans montent en colonne, tout retombe, et sa dernière image est
## presque vide. Jouée en rond, elle s'éteindrait donc une fois par seconde.
##
## On la coupe en deux :
##
##     ACTIVATION   toutes les images, une fois   — le jaillissement
##     CHARGE       les images de pleine puissance, en rond — l'aura
##
## Les bornes de la boucle viennent du descripteur (`renaissance_aura.json`),
## jamais d'ici : redessiner la planche avec dix images ne doit demander aucune
## retouche du moteur.
##
## Elle ne fait AUCUN dégât et ne décide de rien. Si elle disparaît, le sort
## fonctionne exactement pareil.

## Opacité de la CHARGE, une fois le jaillissement passé.
##
## Presque pleine, et c'est le PLAN qui le permet : l'aura est dessinée DERRIÈRE
## le mage (voir `z_index` plus bas). Posée devant, il avait fallu la descendre
## à 0,58 et la colonne de lumière l'effaçait quand même — sur une seconde de
## jaillissement c'est un effet, sur trente secondes c'est un mage qu'on ne voit
## plus jouer. Derrière, elle peut brûler à plein sans rien cacher.
const CHARGE_ALPHA := 0.9
## Sous ce reste de temps, l'aura se met à battre : le joueur doit SENTIR que le
## bonus s'achève avant qu'il ne s'achève. C'est le seul avertissement qu'il a.
const WARNING := 4.0
## Hauteur de l'aura, en cases. Elle doit envelopper le corps sans déborder sur
## les couloirs voisins : c'est un effet SUR LUI, pas sur le labyrinthe.
const HEIGHT_TILES := 4.2
## Le cercle de runes se pose à ses PIEDS et non à sa ceinture : la planche est
## vue de dessus en légère plongée, la colonne monte donc depuis le sol.
const LIFT_TILES := 0.5

var tile_size: int = 32

var _sprite: Sprite2D = null
var _frames := 1
var _fps := 9.0
var _loop_first := 0
var _loop_last := 0
var _elapsed := 0.0
var _left := 0.0
var _total := 1.0


func setup(strip: Texture2D, frames: int, fps: float, loop: Array,
		p_tile_size: int, duration: float) -> void:
	tile_size = p_tile_size
	_frames = maxi(1, frames)
	_fps = maxf(1.0, fps)
	_total = maxf(0.5, duration)
	_left = _total
	# Bornes de boucle repliées sur la bande : un descripteur qui déborde doit
	# donner une aura moche, jamais un plantage.
	_loop_first = clampi(int(loop[0]) if loop.size() > 0 else 0, 0, _frames - 1)
	_loop_last = clampi(int(loop[1]) if loop.size() > 1 else _frames - 1,
		_loop_first, _frames - 1)
	# DERRIÈRE LE MAGE, et c'est tout l'écart avec l'égide de pierre.
	#
	# L'égide est une COQUE : elle se pose devant lui, translucide, parce que
	# c'est ce qu'une protection fait. Une aura de charge, non — elle jaillit du
	# corps et l'entoure ; le corps reste net devant elle. Devant, la colonne de
	# lumière noyait complètement le mage, vérifié à l'écran.
	#
	# ⚠️ MOINS UN, ET RELATIF AU MAGE. Le nœud est enfant de `player`, dont le
	# plan est 10 : l'aura tombe donc à 9, derrière lui et loin devant le
	# labyrinthe. Une valeur absolue négative la ferait passer SOUS le sol, qui
	# est au plan 0 — c'est le piège de ce jeu, et il a déjà servi.
	z_index = -1

	_sprite = Sprite2D.new()
	_sprite.texture = strip
	_sprite.hframes = _frames
	_sprite.vframes = 1
	add_child(_sprite)
	var cell := Vector2(strip.get_size()) / Vector2(float(_frames), 1.0)
	var factor := (float(tile_size) * HEIGHT_TILES) / maxf(1.0, cell.y)
	_sprite.scale = Vector2(factor, factor)
	_sprite.position = Vector2(0.0, -float(tile_size) * LIFT_TILES)
	# COMPOSITION NORMALE, et pas additive. C'est la troisième fois que la
	# question se pose dans ce jeu et la réponse ne change pas : l'additif
	# AJOUTE au fond au lieu de le couvrir, et sur l'herbe claire de la Forêt
	# une colonne de lumière dorée devient un voile blanchâtre invisible.


## Relancée avant l'échéance : le compteur repart à neuf, mais le jaillissement
## NE SE REJOUE PAS. Il raconte le passage d'un état à l'autre — le rejouer sur
## un mage déjà exalté dirait quelque chose de faux.
func refresh(duration: float) -> void:
	_total = maxf(0.5, duration)
	_left = _total


func stop() -> void:
	_left = 0.0


func _process(delta: float) -> void:
	if _sprite == null:
		return
	_elapsed += delta
	_left = maxf(0.0, _left - delta)
	if _left <= 0.0:
		queue_free()
		return

	var step := int(_elapsed * _fps)
	if step < _frames:
		# LE JAILLISSEMENT, à pleine opacité : c'est l'instant qu'on regarde.
		_sprite.frame = step
		_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		return

	# LA CHARGE : on tourne en rond sur les seules images de pleine puissance.
	var span := _loop_last - _loop_first + 1
	_sprite.frame = _loop_first + (step - _frames) % span
	var alpha := CHARGE_ALPHA
	if _left < WARNING:
		# Un battement de plus en plus vif à mesure que le temps manque. C'est
		# la même règle que l'orbite de l'égide qui se resserre : la fin d'un
		# bonus doit s'ANNONCER, sinon elle se découvre en perdant un combat.
		var urgency := 1.0 - _left / WARNING
		var beat := 0.5 + 0.5 * sin(_elapsed * (8.0 + 16.0 * urgency))
		alpha *= 0.35 + 0.65 * beat
	_sprite.modulate = Color(1.0, 1.0, 1.0, alpha)
