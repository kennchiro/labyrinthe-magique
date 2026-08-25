class_name Implosion
extends Node2D

## L'ombre INSPIRE : le seul effet du jeu qui va vers l'intérieur.
##
## Une explosion se lit à ce qui s'écarte. Celle-ci doit se lire à ce qui se
## RASSEMBLE, puis à ce qui claque une fois tout arrivé au centre — sinon le
## joueur voit une détonation ordinaire et ne comprend pas pourquoi ses
## poursuivants ont changé de place.
##
## Trois pièces, et chacune dit une chose :
##   · l'anneau qui se REFERME donne la portée du souffle. C'est lui qui apprend
##     au joueur d'où le sort ramène — sans quoi il ne peut pas viser ;
##   · les volutes qui tombent vers le centre disent le SENS. Elles seules
##     distinguent l'aspiration de l'explosion, l'anneau étant symétrique ;
##   · le noyau noir qui gonfle puis crève dit le MOMENT. La détonation n'a lieu
##     qu'après, et l'onde de choc du sort s'en charge.
##
## Rien de tout cela n'est en additif. L'additif ne sait pas peindre du noir — il
## éclaircit toujours ce qu'il recouvre — et une ombre qui blanchit le sol en
## l'aspirant serait un contresens. On mélange, et le noyau assombrit vraiment.

## Temps de l'inspiration. Court : le sort touche à la frame zéro, cette phase
## n'est pas une attente mais une LECTURE — le temps qu'il faut pour voir d'où
## les créatures sont venues.
const GATHER := 0.34
## Temps de la retombée après le claquement.
const SNAP := 0.30
## Nombre de volutes. Assez pour lire un mouvement d'ensemble, pas assez pour
## masquer les créatures qu'on vient de rassembler — c'est elles qu'on veut voir.
const WISPS := 46
## Tours parcourus par une volute pendant sa chute.
##
## LA SPIRALE EST CE QUI FAIT LIRE L'ASPIRATION. Des volutes qui tombent en
## ligne droite vers le centre dessinent une étoile, et une étoile est
## symétrique : rien n'y dit si les branches entrent ou sortent. Dès qu'elles
## s'enroulent, le doute n'est plus possible — un tourbillon n'a qu'un sens.
const SPIN := 1.15
## Rayon minimal de la gorge, en part de la portée. Voir `_draw_gathering`.
const THROAT := 0.17

var _tint := Color("#b06cff")
var _reach := 64.0
var _time := 0.0
## Angle, distance de départ et retard de chaque volute.
var _wisps: Array[Vector3] = []


func setup(tile_size: int, pull_radius: float, tint: Color, seed_value: int) -> void:
	_tint = tint
	_reach = float(tile_size) * maxf(1.0, pull_radius)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in WISPS:
		# Les volutes ne partent PAS toutes du bord : une aspiration prend ce
		# qu'elle trouve, et un anneau parfait de volutes ressemblerait à une
		# figure géométrique plutôt qu'à un souffle.
		# Les retards s'étalent sur la MOITIÉ de la phase : plus serré, toutes
		# les volutes étaient arrivées aux deux tiers et la fin de l'inspiration
		# se jouait sur un écran vide, juste avant le claquement.
		_wisps.append(Vector3(rng.randf() * TAU, rng.randf_range(0.45, 1.0),
			rng.randf_range(0.0, 0.48)))
	set_process(true)


func _process(delta: float) -> void:
	_time += delta
	if _time >= GATHER + SNAP:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	if _time < GATHER:
		_draw_gathering(_time / GATHER)
	else:
		_draw_collapse((_time - GATHER) / SNAP)


func _draw_gathering(t: float) -> void:
	# LA NAPPE D'OMBRE, dessinée en premier : elle assombrit le sol sur toute la
	# portée du souffle. C'est elle qui dit « ce carré de labyrinthe m'appartient
	# maintenant », et elle donne aux volutes violettes de quoi se détacher — sur
	# un sol clair et chargé de décor, elles se perdaient.
	# LA GORGE NE SE REFERME PAS TOUT À FAIT. Deux versions ont fini sur un écran
	# vide juste avant le claquement : l'anneau atteignait zéro, les volutes
	# tombaient au même point, et il ne restait plus rien à regarder au moment
	# le plus important. On garde un fond de gorge — c'est aussi lui que
	# l'ouverture reprend à la frame suivante, ce qui supprime le saut.
	var closing: float = THROAT + (1.0 - THROAT) * pow(1.0 - t, 1.4)
	for ring in 4:
		var span := _reach * (1.0 - 0.18 * float(ring))
		draw_circle(Vector2.ZERO, span, Color(0.06, 0.02, 0.11, 0.07 + 0.05 * t))

	# L'anneau se referme en ACCÉLÉRANT : une contraction linéaire a l'air d'un
	# cercle qu'on redimensionne, pas d'une chose qui tombe vers un puits. Deux
	# anneaux décalés, parce qu'un seul trait ne montre pas qu'il TOURNE.
	draw_arc(Vector2.ZERO, _reach * closing, 0.0, TAU, 64,
		Color(_tint.r, _tint.g, _tint.b, 0.45 + 0.45 * t), 3.0 + 4.0 * t)
	draw_arc(Vector2.ZERO, _reach * (1.0 - t) * 0.80, SPIN * t * TAU,
		SPIN * t * TAU + TAU * 0.62, 40,
		Color(1.0, 0.92, 1.0, 0.30 * (1.0 - t)), 2.0)

	for wisp in _wisps:
		# Chaque volute a son propre retard : parties ensemble, elles feraient
		# une couronne qui rétrécit — encore une figure, pas un souffle.
		var own := clampf((t - wisp.z) / maxf(0.05, 1.0 - wisp.z), 0.0, 1.0)
		if own <= 0.0:
			continue
		# La volute part lentement et finit vite : c'est la chute dans un puits.
		# L'inverse — vite puis lentement — donne des volutes qui s'échouent au
		# bord du centre et y flottent.
		# Les volutes s'échouent SUR la gorge et non au centre : entassées sur un
		# point, elles formaient une bille et le tourbillon disparaissait.
		var fall: float = THROAT + (1.0 - THROAT) * (1.0 - pow(own, 1.5))
		var head := _point(wisp, fall)
		# La traînée relie où elle est à où elle ÉTAIT, en suivant la spirale :
		# une corde droite couperait la courbe et casserait le tourbillon.
		var mid := _point(wisp, minf(1.0, fall + 0.10))
		var tail := _point(wisp, minf(1.0, fall + 0.22))
		var glow := Color(_tint.r, _tint.g, _tint.b, 0.75 * own)
		draw_line(head, mid, glow, 3.2)
		draw_line(mid, tail, Color(glow.r, glow.g, glow.b, glow.a * 0.45), 2.0)
		draw_circle(head, 2.6 + 2.4 * own, Color(1.0, 0.88, 1.0, 0.85 * own))

	# Le noyau : il NOIRCIT au lieu d'éclairer. C'est la seule chose à l'écran
	# qui assombrit le sol, et c'est ce qui fait lire « ombre » plutôt que
	# « sort violet ».
	var core := _reach * 0.13 * (0.4 + t)
	draw_circle(Vector2.ZERO, core * 2.2, Color(0.05, 0.02, 0.09, 0.40 * t))
	draw_circle(Vector2.ZERO, core, Color(0.02, 0.0, 0.05, 0.70 + 0.25 * t))
	draw_arc(Vector2.ZERO, core, 0.0, TAU, 32,
		Color(_tint.r, _tint.g, _tint.b, 0.55 * t), 2.0)


## Position d'une volute pour un reste de chute donné (1 = au bord, 0 = au
## centre). La distance et l'angle sont liés : c'est ce lien qui fait la spirale.
func _point(wisp: Vector3, fall: float) -> Vector2:
	var angle: float = wisp.x + (1.0 - fall) * SPIN * TAU
	return Vector2(cos(angle), sin(angle)) * _reach * wisp.y * fall


func _draw_collapse(t: float) -> void:
	# Le noyau CRÈVE : il s'ouvre d'un coup et pâlit. L'onde de choc du sort part
	# au même instant, dessinée par `Shockwave` — celle-ci ne fait que le
	# raccord, sans quoi le noir disparaîtrait d'une frame à l'autre.
	#
	# La nappe se retire plus lentement que l'éclat : l'ombre reprend son sol,
	# elle ne s'évapore pas.
	var fade := 1.0 - t
	draw_circle(Vector2.ZERO, _reach * (1.0 - 0.35 * t),
		Color(0.06, 0.02, 0.11, 0.16 * fade))

	# L'ouverture REPREND LÀ OÙ L'ANNEAU S'EST REFERMÉ, au fond de la gorge.
	var opening: float = _reach * (THROAT + 0.46 * t)
	draw_circle(Vector2.ZERO, opening, Color(0.03, 0.0, 0.07, 0.72 * fade * fade))
	draw_arc(Vector2.ZERO, opening, 0.0, TAU, 48,
		Color(1.0, 0.94, 1.0, 0.85 * fade), 3.0 + 6.0 * fade)
	draw_arc(Vector2.ZERO, opening * 0.58, 0.0, TAU, 40,
		Color(_tint.r, _tint.g, _tint.b, 0.65 * fade), 4.0)

	# Les éclats que le noyau recrache : ce sont les mêmes volutes, reparties en
	# sens inverse. Peu nombreuses et courtes — le sort a ASPIRÉ, ce qui ressort
	# ne doit pas peser plus lourd que ce qui est entré.
	for i in range(0, _wisps.size(), 3):
		var wisp: Vector3 = _wisps[i]
		var direction := Vector2(cos(wisp.x), sin(wisp.x))
		var far: Vector2 = direction * opening * (1.0 + 0.9 * t)
		draw_line(far, far - direction * 9.0,
			Color(_tint.r, _tint.g, _tint.b, 0.7 * fade), 2.4)
