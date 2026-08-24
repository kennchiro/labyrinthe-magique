class_name CombatPad
extends Control

## Barre d'action tactile : frappe, trois sorts, la FUITE, et l'Extra Hit.
##
## Dessinée à la main plutôt qu'assemblée en Button : chaque bouton doit montrer
## sa recharge (un secteur qui se remplit), son manque de mana et, pour l'ultime,
## sa charge en kills. Un Button standard ne sait rien afficher de tout ça, et
## cinq sous-nœuds par bouton coûteraient plus cher qu'un _draw.
##
## Comme TouchStick, elle suit chaque doigt par son index : poser le pouce sur une
## compétence ne doit pas annuler le déplacement en cours de l'autre main.

## Slot renvoyé quand le bouton principal sert à prendre un portail.
const SLOT_PORTAL := -1

signal action_requested(slot: int)

## Rayons des boutons, en pixels de viewport.
@export var main_radius: float = 52.0
@export var skill_radius: float = 33.0
@export var margin: Vector2 = Vector2(58.0, 58.0)

## [{slot, label, color, ready, ratio, locked, hint}] — reconstruit à chaque frame
## par l'UIManager. La barre ne sait rien du jeu, elle affiche ce qu'on lui donne.
var entries: Array[Dictionary] = []

var _touches := {}
var _pressed := -99


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func set_entries(new_entries: Array[Dictionary]) -> void:
	entries = new_entries
	queue_redraw()


## Centre du bouton d'un slot. Le principal est en bas à droite sous le pouce ;
## les compétences remontent en arc au-dessus de lui, l'ultime plus loin encore.
##
## Les rayons d'arc ne sont pas décoratifs : ils garantissent que deux boutons
## voisins NE SE TOUCHENT PAS. Une première version les posait à 118 px du
## centre avec 37° d'écart, soit une corde de 61 px pour des boutons de 66 —
## ils se chevauchaient, et on déclenchait un sort en visant l'autre.
## En coordonnées écran, l'axe Y descend : un arc qui MONTE a donc un sinus
## NÉGATIF, c'est-à-dire des angles entre 180° et 360°. Une première version
## partait de 196° en DÉCROISSANT — l'arc plongeait vers le bas et la troisième
## compétence sortait de l'écran.
const SKILL_ARC_STEP := deg_to_rad(37.0)
const SKILL_ARC_START := deg_to_rad(196.0)
## La FUITE est le geste d'urgence : elle se place juste AU-DESSUS de la frappe,
## là où le pouce tombe sans viser. On la cherche quand on est déjà en train de
## se faire rattraper — ce n'est pas le moment de chercher un bouton.
const ESCAPE_ANGLE := deg_to_rad(270.0)
## L'ultime, plein gauche et à l'écart : on ne doit pas le déclencher par erreur
## en visant une compétence.
const ULTIMATE_ANGLE := deg_to_rad(180.0)

func _centre(slot_index: int) -> Vector2:
	var corner := Vector2(size.x - margin.x - main_radius, size.y - margin.y - main_radius)
	if slot_index == 0:
		return corner
	if slot_index == 4:
		var near := main_radius + skill_radius * 1.9
		return corner + Vector2(cos(ESCAPE_ANGLE), sin(ESCAPE_ANGLE)) * near
	if slot_index == 5:
		# L'ultime est mis à l'écart : on ne doit pas le déclencher par erreur
		# en visant une compétence.
		var far := main_radius + skill_radius * 4.2
		return corner + Vector2(cos(ULTIMATE_ANGLE), sin(ULTIMATE_ANGLE)) * far
	var angle := SKILL_ARC_START + SKILL_ARC_STEP * (float(slot_index) - 1.0)
	var radius := main_radius + skill_radius * 2.2
	return corner + Vector2(cos(angle), sin(angle)) * radius


func _radius(slot_index: int) -> float:
	if slot_index == 0:
		return main_radius
	# La fuite est un peu plus grosse que les sorts : on la vise dans l'urgence.
	return skill_radius * 1.18 if slot_index == 4 else skill_radius


func _slot_at(point: Vector2) -> int:
	for i in entries.size():
		# Zone tactile élargie : viser un bouton sans regarder son pouce demande
		# de la tolérance. Le visuel, lui, reste à la taille nominale.
		if point.distance_to(_centre(i)) <= _radius(i) + 12.0:
			return i
	return -99


## Ce point tombe-t-il sur un bouton ? Le GameManager le demande avant de
## traduire un tap en ordre de marche : la barre lit ses touches dans _input
## sans les consommer, un tap sur un sort arriverait donc AUSSI au labyrinthe
## et enverrait le mage vers la case cachée sous le bouton.
func covers(point: Vector2) -> bool:
	return _slot_at(point) != -99


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			var index := _slot_at(event.position)
			if index != -99:
				_touches[event.index] = index
				_pressed = index
				_fire(index)
				queue_redraw()
		elif _touches.has(event.index):
			_touches.erase(event.index)
			_pressed = -99
			queue_redraw()


func _fire(index: int) -> void:
	if index < 0 or index >= entries.size():
		return
	var entry: Dictionary = entries[index]
	action_requested.emit(int(entry.get("slot", index)))


func _draw() -> void:
	for i in entries.size():
		_draw_button(i, entries[i])


func _draw_button(index: int, entry: Dictionary) -> void:
	var centre := _centre(index)
	var radius := _radius(index)
	var color: Color = entry.get("color", Color.WHITE)
	var ready: bool = entry.get("ready", false)
	var locked: bool = entry.get("locked", false)
	var ratio: float = clampf(float(entry.get("ratio", 1.0)), 0.0, 1.0)

	# Fond dense et teinté de l'élément : à 72 % d'un bleu presque noir, les
	# boutons se lisaient comme des trous percés dans le labyrinthe.
	draw_circle(centre, radius, Color(0.06, 0.08, 0.14, 0.93))
	draw_circle(centre, radius * 0.94,
		Color(color.r * 0.30, color.g * 0.30, color.b * 0.30, 0.92 if ready else 0.55))
	# Le secteur de recharge tourne comme une aiguille : on voit d'un coup d'œil
	# combien il reste, sans lire de chiffre.
	# Sans icône, le disque coloré d'origine ; avec icône, seulement la
	# recharge — un disque plein par-dessus le dessin le masquerait.
	var has_icon: bool = entry.get("icon", null) != null
	if ratio < 1.0:
		draw_arc(centre, radius * 0.82, -PI * 0.5, -PI * 0.5 + TAU * ratio, 32,
			Color(color.r, color.g, color.b, 0.55), radius * 0.30)
	elif not has_icon:
		draw_circle(centre, radius * 0.66,
			Color(color.r, color.g, color.b, 0.55 if ready else 0.18))

	# L'ICÔNE au centre, à la place du disque coloré. Elle est grisée et
	# assombrie quand le sort n'est pas prêt : c'est la même information que la
	# couleur donnait avant, mais on sait enfin DE QUEL SORT il s'agit.
	var icon: Texture2D = entry.get("icon", null)
	if icon != null:
		var span := radius * 1.5
		var tint := Color(1, 1, 1, 0.95) if ready else Color(0.55, 0.58, 0.66, 0.7)
		draw_texture_rect(icon, Rect2(centre - Vector2(span, span) * 0.5,
			Vector2(span, span)), false, tint)

	var edge := color if ready else Color(0.42, 0.48, 0.62)
	if _pressed == index:
		edge = Color(1, 1, 1)
	draw_arc(centre, radius, 0.0, TAU, 40, edge, 3.0 if ready else 2.0)

	# Un ultime chargé pulse : c'est le seul bouton qui doit attirer l'œil au
	# milieu d'une poursuite.
	if ready and bool(entry.get("highlight", false)):
		var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.005)
		draw_arc(centre, radius * (1.12 + 0.10 * pulse), 0.0, TAU, 40,
			Color(color.r, color.g, color.b, 0.45 * pulse), 3.0)

	# Les charges en PASTILLES autour du bouton plutôt qu'en chiffres : sur un
	# bouton de 33 px sous un pouce, « 3/5 » est illisible, alors qu'on compte
	# trois points d'un coup d'œil.
	var charges := int(entry.get("charges", -1))
	if charges >= 0:
		var total := maxi(1, int(entry.get("charges_max", 1)))
		var arc := PI * 0.62
		for pip in total:
			var angle := -PI * 0.5 - arc * 0.5 + arc * (float(pip) / maxf(1.0, float(total - 1)))
			var at := centre + Vector2(cos(angle), sin(angle)) * radius * 1.28
			var filled := pip < charges
			draw_circle(at, radius * 0.11,
				color if filled else Color(0.30, 0.34, 0.44, 0.85))

	if locked:
		# Cadenas : deux traits suffisent à dire « pas encore » sans police.
		var bar := radius * 0.30
		draw_rect(Rect2(centre - Vector2(bar, bar * 0.1), Vector2(bar * 2.0, bar * 1.1)),
			Color(0.75, 0.80, 0.92, 0.85))
		draw_arc(centre - Vector2(0.0, bar * 0.1), bar * 0.72, PI, TAU, 20,
			Color(0.75, 0.80, 0.92, 0.85), 3.0)
