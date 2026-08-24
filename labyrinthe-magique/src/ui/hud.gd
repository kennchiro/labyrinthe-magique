class_name HUD
extends Control

## Bandeau d'information, dessiné à la main pour coller au cadre du concept art.
##
## La barre bleue n'est PAS du mana : c'est la recharge du portail. Le concept
## art montrait deux jauges, le jeu n'a qu'une ressource — plutôt que d'inventer
## une mécanique de mana pour remplir un pixel, on affiche l'information qui
## existe déjà et dont le joueur a réellement besoin.
##
## La rangée de pastilles, elle, est l'objectif : une par gemme du niveau, dans
## sa couleur. Éteinte = déjà ramassée, allumée = encore à trouver. C'est la
## MÊME information que le sceau au-dessus de la maison, montrée deux fois
## exprès : sur le bandeau on la lit en fuyant, sur la maison on la lit en
## arrivant.

const PANEL_BG := Color(0.05, 0.06, 0.11, 0.80)
const PANEL_EDGE := Color(0.42, 0.50, 0.75, 0.45)
const PORTRAIT_BG := Color(0.10, 0.13, 0.24, 1.0)
const HEALTH_BG := Color(0.20, 0.06, 0.07, 0.95)
const HEALTH_FILL := Color("#d9463c")
const TELEPORT_BG := Color(0.05, 0.11, 0.18, 0.95)
const TELEPORT_FILL := Color("#2b7fb5")
const TELEPORT_FILL_READY := Color("#9ef0ff")
## Pastille d'une gemme déjà ramassée : le contour reste, la couleur part.
const GEM_TAKEN := Color(0.22, 0.26, 0.36, 0.9)

## Gabarit du bandeau. Il occupait 71 % de la largeur d'un iPhone : sur un
## écran de téléphone, un panneau d'information qui mange les trois quarts du
## bord haut ne se lit pas mieux, il cache juste le labyrinthe. Ramené à ~56 %,
## avec des jauges plus fines et des pastilles plus serrées.
const PANEL_SIZE := Vector2(300.0, 106.0)
const PORTRAIT_CENTER := Vector2(32.0, 32.0)
const PORTRAIT_RADIUS := 21.0
const BAR_LEFT := 60.0
const BAR_RIGHT := 288.0
const GEM_ROW_Y := 58.0
const GEM_RADIUS := 6.0
const GEM_STEP := 16.0

@onready var level_label: Label = $LevelLabel
@onready var counter_label: Label = $CounterLabel
@onready var kills_label: Label = $KillsLabel

var health := 1
var max_health := 1
var teleport_ratio := 1.0
var teleport_ready := false
## Couleurs des gemmes encore à trouver, et nombre total dans le niveau.
var missing_gems: Array[Color] = []
var gem_total := 0
## Progression vers l'Extra Power. `kills_ready` déclenche la mise en valeur :
## un pouvoir débloqué dont personne ne s'aperçoit ne sert à rien.
## Portrait du mage joué, découpé dans sa planche de marche de face.
var portrait: Texture2D = null
var portrait_cell := Vector2(128.0, 112.0)

var unlocked_skills := 0

var kills := 0
var kills_needed := 5
var kills_ready := false
## Nombre de sorts acquis. Ils le sont DÉFINITIVEMENT : le bandeau affiche donc
## une progression (« SORTS : 2 / 3 »), pas une réserve qui se vide.


## Le bandeau montre le VRAI mage. Une silhouette générique pour les sept
## personnages ne dit rien : on ne sait plus qui on incarne dès qu'on relance.
func set_character(stats: CharacterStats) -> void:
	portrait = load("res://assets/characters/%s/down.png" % stats.id)
	var text := FileAccess.get_file_as_string(
		"res://assets/characters/%s/frames.json" % stats.id)
	var parsed: Variant = JSON.parse_string(text)
	if parsed != null:
		var cell: Array = (parsed as Dictionary)["cell"]
		portrait_cell = Vector2(float(cell[0]), float(cell[1]))
	queue_redraw()


func set_level(config: LevelConfig, number: int) -> void:
	level_label.text = _fitting_title(config)
	queue_redraw()


func set_health(current: int, maximum: int) -> void:
	health = current
	max_health = maxi(1, maximum)
	queue_redraw()


func set_gems(missing: Array[Color], total: int) -> void:
	missing_gems = missing
	gem_total = total
	queue_redraw()


func set_counters(portals: int, p_unlocked: int) -> void:
	unlocked_skills = p_unlocked
	counter_label.text = "Portails : %d" % portals
	_refresh_kills_label()
	queue_redraw()


func set_kills(p_kills: int, needed: int, ready: bool) -> void:
	kills = p_kills
	kills_needed = maxi(1, needed)
	kills_ready = ready
	_refresh_kills_label()
	queue_redraw()


func _refresh_kills_label() -> void:
	var text := "EXTRA POWER PRÊT !" if kills_ready else "KILLS : %d / %d" % [
		mini(kills, kills_needed), kills_needed]
	text += "   ·   SORTS : %d / 3" % unlocked_skills
	kills_label.text = text
	kills_label.add_theme_color_override("font_color",
		Color("#ffd15a") if kills_ready else Color(0.62, 0.72, 0.92))


func set_teleport(ratio: float, ready: bool) -> void:
	teleport_ratio = clampf(ratio, 0.0, 1.0)
	teleport_ready = ready
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, PANEL_SIZE), PANEL_BG)
	draw_rect(Rect2(Vector2.ZERO, PANEL_SIZE), PANEL_EDGE, false, 2.0)

	_draw_portrait(PORTRAIT_CENTER, PORTRAIT_RADIUS)
	_draw_health(Rect2(BAR_LEFT, 24.0, BAR_RIGHT - BAR_LEFT, 13.0))
	_draw_teleport(Rect2(BAR_LEFT, 41.0, BAR_RIGHT - BAR_LEFT, 7.0))
	_draw_gems()
	_draw_kills(Rect2(BAR_LEFT, 92.0, BAR_RIGHT - BAR_LEFT, 6.0))


func _draw_portrait(center: Vector2, radius: float) -> void:
	draw_circle(center, radius, PORTRAIT_BG)
	if portrait != null:
		# Cadré sur le HAUT du sprite : dans un disque de 21 px, un personnage
		# entier ne serait qu'une tache. On veut la tête et les épaules.
		var factor := (radius * 2.6) / portrait_cell.y
		var drawn := portrait_cell * factor
		draw_texture_rect_region(portrait,
			Rect2(center - Vector2(drawn.x * 0.5, drawn.y * 0.42), drawn),
			Rect2(Vector2.ZERO, portrait_cell))
	draw_arc(center, radius, 0.0, TAU, 32, PANEL_EDGE, 2.0)


func _draw_health(rect: Rect2) -> void:
	draw_rect(rect, HEALTH_BG)
	var ratio := float(health) / float(max_health)
	if ratio > 0.0:
		draw_rect(Rect2(rect.position, Vector2(rect.size.x * ratio, rect.size.y)), HEALTH_FILL)
	# Séparateurs quand le niveau accorde plusieurs points de vie. Aucun effet
	# avec une seule vie, mais passer à 3 PV ne demandera aucune modification ici.
	for i in range(1, max_health):
		var x := rect.position.x + rect.size.x * float(i) / float(max_health)
		draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), PANEL_BG, 2.0)
	draw_rect(rect, PANEL_EDGE, false, 1.0)


func _draw_teleport(rect: Rect2) -> void:
	draw_rect(rect, TELEPORT_BG)
	var fill := TELEPORT_FILL_READY if teleport_ready else TELEPORT_FILL
	if teleport_ratio > 0.0:
		draw_rect(Rect2(rect.position, Vector2(rect.size.x * teleport_ratio, rect.size.y)), fill)
	draw_rect(rect, PANEL_EDGE, false, 1.0)


## Les gemmes ramassées d'abord (éteintes), puis celles qui manquent : la rangée
## se remplit donc de gauche à droite au fil de la partie, comme une barre de
## progression dont chaque cran a une couleur.
func _draw_gems() -> void:
	if gem_total <= 0:
		return
	var taken := gem_total - missing_gems.size()
	var x := BAR_LEFT + GEM_RADIUS
	for i in gem_total:
		var centre := Vector2(x, GEM_ROW_Y)
		if i < taken:
			draw_circle(centre, GEM_RADIUS * 0.7, GEM_TAKEN)
			draw_arc(centre, GEM_RADIUS, 0.0, TAU, 18, PANEL_EDGE, 1.5)
		else:
			var color: Color = missing_gems[i - taken]
			draw_circle(centre, GEM_RADIUS * 1.45, Color(color.r, color.g, color.b, 0.18))
			draw_circle(centre, GEM_RADIUS, color)
			draw_arc(centre, GEM_RADIUS, 0.0, TAU, 18, Color(1, 1, 1, 0.55), 1.5)
		x += GEM_STEP


## Jauge de progression vers l'Extra Power. Pleine et dorée, elle dit « maintenant ».
func _draw_kills(rect: Rect2) -> void:
	draw_rect(rect, Color(0.06, 0.07, 0.12, 0.95))
	var ratio := 1.0 if kills_ready else clampf(float(kills) / float(kills_needed), 0.0, 1.0)
	if ratio > 0.0:
		var fill := Color("#ffd15a") if kills_ready else Color("#8a6bd8")
		draw_rect(Rect2(rect.position, Vector2(rect.size.x * ratio, rect.size.y)), fill)
	# Un cran par kill : le joueur compte ce qu'il lui reste sans lire le texte.
	for i in range(1, kills_needed):
		var x := rect.position.x + rect.size.x * float(i) / float(kills_needed)
		draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), PANEL_BG, 2.0)
	draw_rect(rect, PANEL_EDGE, false, 1.0)


## Titre du bandeau, dans la forme la plus longue QUI TIENT.
##
## Le bandeau a été réduit à la demande, et « STAGE 10 · ÉP. 2 — Le Château du
## Ciel » n'y entre pas : il s'affichait tronqué en « Le Château du Ci ». Un
## titre coupé se lit comme un bug.
##
## La forme abrégée est donc la forme NORMALE — elle tient pour les dix noms —
## et la seconde n'est qu'un filet : si un nom plus long arrivait un jour, le
## bandeau se resserrerait au lieu de couper. Le NOM du lieu est dans les deux,
## c'est lui que le joueur lit ; le numéro, il vient de le choisir au menu.
func _fitting_title(config: LevelConfig) -> String:
	if config.is_demo:
		return "DÉMO — Terrain d'essai"
	var candidates := [
		"ST.%d · ÉP.%d — %s" % [config.stage, config.episode, config.level_name],
		"%d·%d — %s" % [config.stage, config.episode, config.level_name],
	]
	var font := level_label.get_theme_font("font")
	var font_size := level_label.get_theme_font_size("font_size")
	if font == null:
		return candidates[-1]
	for candidate in candidates:
		if font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1.0,
				font_size).x <= level_label.size.x:
			return candidate
	return candidates[-1]
