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
@export var main_radius: float = 56.0
@export var skill_radius: float = 38.0
@export var margin: Vector2 = Vector2(58.0, 58.0)

## [{slot, label, color, ready, ratio, locked, hint}] — reconstruit à chaque frame
## par l'UIManager. La barre ne sait rien du jeu, elle affiche ce qu'on lui donne.
var entries: Array[Dictionary] = []
## La disposition du joueur. Sans elle, l'éventail déduit ci-dessous.
var layout: TouchLayout = null
## Dessinée dans l'éditeur de disposition : elle se montre, mais ne lance rien.
var preview := false

var _touches := {}
var _pressed := -99


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func set_entries(new_entries: Array[Dictionary]) -> void:
	entries = new_entries
	queue_redraw()


## Centre du bouton d'un slot. Le principal est en bas à droite sous le pouce ;
## les cinq autres montent en ÉVENTAIL RÉGULIER au-dessus de lui.
##
## ⚠️ L'ÉVENTAIL EST RÉGULIER, et il a fallu ça. La version précédente posait les
## trois sorts sur un arc et la FUITE à part, « juste au-dessus de la frappe » —
## sauf que le troisième sort tombait exactement au même angle qu'elle : 196° +
## 2 x 37° = 270°, l'angle de la fuite. Leurs centres étaient à 10 px l'un de
## l'autre pour des rayons de 33 et 39, soit 62 px de RECOUVREMENT. On visait un
## sort, on déclenchait l'autre.
##
## Trois règles ont remplacé les trois placements séparés :
##   · un seul rayon pour tous les secondaires — deux rayons différents sur le
##     même angle, c'est exactement ce qui a produit le défaut ;
##   · un pas angulaire constant, choisi pour que la CORDE entre deux voisins
##     dépasse la somme de leurs rayons ;
##   · l'ordre suit le pouce : la FUITE au plus près de la frappe, l'ULTIME au
##     plus loin. On cherche la fuite quand on est déjà en train de se faire
##     rattraper ; l'ultime, on ne doit pas le déclencher par erreur.
##
## En coordonnées écran, l'axe Y descend : un arc qui MONTE a donc un sinus
## NÉGATIF, c'est-à-dire des angles entre 180° et 360°.
##
## Le jeu minimal entre deux boutons vaut 11,7 px avec ces valeurs, et
## `tests/test_pad.gd` le vérifie — c'est la seule chose qui empêche le défaut
## de revenir au prochain réglage.
## Rayon VISÉ de l'éventail. Il est réduit quand l'écran ne peut pas le tenir —
## voir `_fan_radius`.
const FAN_RADIUS := 205.0
const FAN_STEP := deg_to_rad(26.0)
const FAN_START := deg_to_rad(180.0)
## Les slots dans l'ordre de l'éventail, en partant de l'horizontale.
##
## La FUITE ouvre l'éventail, à hauteur du pouce : on la cherche quand on est
## déjà en train de se faire rattraper, ce n'est pas le moment de viser. Les
## trois sorts montent ensuite DANS L'ORDRE — 1, 2, 3 — comme sur la barre du
## clavier. L'ULTIME ferme la marche, tout en haut : c'est le plus long à
## atteindre, et c'est voulu, on ne doit pas le déclencher par erreur.
const FAN_ORDER := [4, 1, 2, 3, 5]


## Jeu minimal entre deux boutons voisins, en unités d'interface. Un doigt vise
## à quelques millimètres près : deux boutons qui se frôlent se confondent.
const FAN_GAP := 10.0
## Part de la fuite en plus des autres : on la vise dans l'urgence.
const ESCAPE_BONUS := 1.12
## Sinus du bouton le plus HAUT de l'éventail (258°), en valeur absolue.
const FAN_TOP := 0.978


## Toute la géométrie de l'éventail, DÉDUITE de la place disponible.
##
## ⚠️ RIEN ICI N'EST UNE CONSTANTE, et deux versions l'ont appris à leurs dépens.
## La barre est dessinée en unités d'interface, pas en pixels d'écran, et
## `Platform.apply_ui_scale` en change le nombre selon l'appareil : un téléphone
## en paysage n'offre qu'environ 690 x 330 unités là où son écran en fait 960 x
## 460. Un rayon d'éventail constant sortait par le haut — les trois boutons du
## haut étaient coupés net. Et le rabattre sans toucher aux boutons les faisait
## se chevaucher, ce qui est exactement le défaut qu'on répare.
##
## Une seule chaîne de conséquences, dans cet ordre :
##   1. deux voisins de l'éventail sont séparés par la CORDE de leur pas
##      angulaire ; il faut donc un rayon minimal pour les tenir écartés ;
##   2. l'écran, lui, impose un rayon maximal ;
##   3. quand le second est plus petit que le premier, ce sont les BOUTONS qui
##      rétrécissent, dans le même rapport. Jamais l'écart.
func _fan() -> Dictionary:
	var main := main_radius
	var skill := skill_radius
	var corner := Vector2(size.x - margin.x - main, size.y - margin.y - main)
	# Rayon qu'il faut pour que deux voisins ne se touchent pas.
	var needed: float = (skill * (1.0 + ESCAPE_BONUS) + FAN_GAP) \
		/ (2.0 * sin(FAN_STEP * 0.5))
	# Rayon que l'écran peut tenir.
	var edge := skill * ESCAPE_BONUS + 4.0
	var room: float = minf((corner.y - edge) / FAN_TOP, corner.x - skill - 4.0)
	if room < needed and needed > 0.0:
		# ⚠️ ON RÉSOUT, ON NE MET PAS À L'ÉCHELLE. Rétrécir les boutons dans le
		# rapport `room / needed` rétrécit AUSSI le jeu entre eux — il tombait à
		# 7 px sur un petit écran alors que la règle en demande 10, et le test le
		# disait. La corde disponible est connue : on en déduit le rayon de
		# bouton qui laisse le jeu ENTIER.
		var chord: float = 2.0 * room * sin(FAN_STEP * 0.5)
		var fitted: float = (chord - FAN_GAP) / (1.0 + ESCAPE_BONUS)
		var shrink: float = clampf(fitted / skill, 0.45, 1.0)
		main *= shrink
		skill *= shrink
		corner = Vector2(size.x - margin.x - main, size.y - margin.y - main)
		needed = (skill * (1.0 + ESCAPE_BONUS) + FAN_GAP) / (2.0 * sin(FAN_STEP * 0.5))
	return {"corner": corner, "main": main, "skill": skill,
		"radius": clampf(FAN_RADIUS, needed, maxf(needed, room))}


func _centre(slot_index: int) -> Vector2:
	var fallback := _fan_centre(slot_index)
	if layout == null:
		return fallback
	return layout.centre_of(TouchLayout.button_id(slot_index), size, fallback, _radius(slot_index))


func _fan_centre(slot_index: int) -> Vector2:
	var fan := _fan()
	var corner: Vector2 = fan["corner"]
	if slot_index == 0:
		return corner
	var rank := FAN_ORDER.find(slot_index)
	if rank < 0:
		return corner
	var angle := FAN_START + FAN_STEP * float(rank)
	return corner + Vector2(cos(angle), sin(angle)) * float(fan["radius"])


func _radius(slot_index: int) -> float:
	var fan := _fan()
	var chosen := layout.scale_of(TouchLayout.button_id(slot_index)) if layout != null else 1.0
	if slot_index == 0:
		return float(fan["main"]) * chosen
	# La fuite est un peu plus grosse que les sorts : on la vise dans l'urgence.
	return float(fan["skill"]) * (ESCAPE_BONUS if slot_index == 4 else 1.0) * chosen


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
	if not visible or preview:
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
	var fade := layout.alpha_of(TouchLayout.button_id(index)) if layout != null else 1.0

	# Fond dense et teinté de l'élément : à 72 % d'un bleu presque noir, les
	# boutons se lisaient comme des trous percés dans le labyrinthe.
	draw_circle(centre, radius, Color(0.06, 0.08, 0.14, 0.93 * fade))
	draw_circle(centre, radius * 0.94,
		Color(color.r * 0.30, color.g * 0.30, color.b * 0.30, (0.92 if ready else 0.55) * fade))
	# Le secteur de recharge tourne comme une aiguille : on voit d'un coup d'œil
	# combien il reste, sans lire de chiffre.
	# Sans icône, le disque coloré d'origine ; avec icône, seulement la
	# recharge — un disque plein par-dessus le dessin le masquerait.
	var has_icon: bool = entry.get("icon", null) != null
	if ratio < 1.0:
		draw_arc(centre, radius * 0.82, -PI * 0.5, -PI * 0.5 + TAU * ratio, 32,
			Color(color.r, color.g, color.b, 0.55 * fade), radius * 0.30)
	elif not has_icon:
		draw_circle(centre, radius * 0.66,
			Color(color.r, color.g, color.b, (0.55 if ready else 0.18) * fade))

	# L'ICÔNE au centre, à la place du disque coloré. Elle est grisée et
	# assombrie quand le sort n'est pas prêt : c'est la même information que la
	# couleur donnait avant, mais on sait enfin DE QUEL SORT il s'agit.
	var icon: Texture2D = entry.get("icon", null)
	if icon != null:
		var span := radius * 1.5
		var tint := Color(1, 1, 1, 0.95 * fade) if ready else Color(0.78, 0.8, 0.86, 0.8 * fade)
		draw_texture_rect(icon, Rect2(centre - Vector2(span, span) * 0.5,
			Vector2(span, span)), false, tint)

	var edge := color if ready else Color(0.42, 0.48, 0.62)
	if _pressed == index:
		edge = Color(1, 1, 1)
	edge.a *= fade
	draw_arc(centre, radius, 0.0, TAU, 40, edge, 3.0 if ready else 2.0)

	# Un ultime chargé pulse : c'est le seul bouton qui doit attirer l'œil au
	# milieu d'une poursuite.
	if ready and bool(entry.get("highlight", false)):
		var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.005)
		draw_arc(centre, radius * (1.12 + 0.10 * pulse), 0.0, TAU, 40,
			Color(color.r, color.g, color.b, 0.45 * pulse * fade), 3.0)

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
				Color(color, fade) if filled else Color(0.30, 0.34, 0.44, 0.85 * fade))

	if locked:
		# Cadenas : deux traits suffisent à dire « pas encore » sans police.
		var bar := radius * 0.30
		draw_rect(Rect2(centre - Vector2(bar, bar * 0.1), Vector2(bar * 2.0, bar * 1.1)),
			Color(0.75, 0.80, 0.92, 0.85 * fade))
		draw_arc(centre - Vector2(0.0, bar * 0.1), bar * 0.72, PI, TAU, 20,
			Color(0.75, 0.80, 0.92, 0.85 * fade), 3.0)
