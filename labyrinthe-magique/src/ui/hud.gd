class_name HUD
extends Control

## La barre du mage : un cadre peint, percé, que le jeu remplit par-dessous.
##
## Les images sont découpées par `tools/build_barre.py`, qui mesure aussi où sont
## les trous (`assets/ui/barre/barre.json`). Rien de la géométrie n'est écrit ici :
## un cadre redessiné déplace ses gouttières sans toucher à ce fichier.
##
## La jauge bleue n'est PAS du mana : c'est la recharge du portail. Le concept art
## montrait deux jauges, le jeu n'a qu'une ressource — plutôt que d'inventer une
## mécanique de mana pour remplir un pixel, on affiche l'information qui existe
## déjà et dont le joueur a réellement besoin.
##
## La rangée de gemmes est l'objectif : une par gemme du niveau, dans sa couleur.
## Sertissage vide = déjà ramassée, gemme posée = encore à trouver. C'est la MÊME
## information que le sceau au-dessus de la maison, montrée deux fois exprès : sur
## le bandeau on la lit en fuyant, sur la maison on la lit en arrivant.
##
## L'anneau autour du portrait compte les kills vers l'Extra Power, un cran par
## kill. Doré et pulsant, il dit « maintenant ».

const ART_PATH := "res://assets/ui/barre/"
## Largeur du cadre à l'écran. L'ancien bandeau faisait 300 x 106 : sur un téléphone,
## il cachait près d'un quart de la hauteur du labyrinthe.
const FRAME_WIDTH := 280.0

const PORTRAIT_BG := Color(0.10, 0.13, 0.24, 1.0)
const GAUGE_BG := Color(0.03, 0.03, 0.06, 1.0)
const HEALTH_LOST := Color(1.0, 0.86, 0.62, 0.85)
const SEPARATOR := Color(0.03, 0.03, 0.06, 0.9)
const TELEPORT_READY := Color(0.62, 0.94, 1.0, 0.5)
const RING_EMPTY := Color(0.24, 0.24, 0.32, 1.0)
const RING_FILL := Color("#a98bf0")
const GOLD := Color("#ffd15a")
const TEXT := Color(0.86, 0.9, 1.0)

## Portrait : le carré de la planche où tombent la tête et les épaules, en fractions.
## Les dix portraits ont la tête au même endroit, c'est ce qui permet une seule règle.
const PORTRAIT_CROP_Y := 0.04
const PORTRAIT_CROP_WIDTH := 0.62

## En dessous de cette largeur, un cran de vie n'est plus qu'une rayure : à 100 PV,
## la démo dessinait 99 traits et la jauge ne se lisait plus.
const MIN_SEGMENT := 6.0
const SHIELD_SHARE := 0.34
## Part de la vie maximale que la traînée rattrape par seconde.
const TRAIL_SPEED := 0.35
## À ce niveau de vie, la jauge se met à battre.
const LOW_HEALTH := 0.34

const GEM_SIZE := 14.0
const GEM_STEP := 14.0
## Une gemme teinte par multiplication s'assombrit : on part d'une couleur plus claire.
const GEM_LIGHTEN := 0.25
## Le nom long se serre avant de perdre son numéro de stage.
const TITLE_SIZES: Array[int] = [12, 11]
const ICON_SIZE := 13.0
const ROW_GAP := 3.0
const PADDING := 4.0

@onready var level_label: Label = $LevelLabel
@onready var counter_label: Label = $CounterLabel

var health := 1
var max_health := 1
## Absorption restante et absorption posée à l'origine. Le bouclier se dessine
## PAR-DESSUS la barre de vie et non à côté : c'est de la vie en sursis, pas une
## seconde jauge, et le joueur doit lire les deux d'un seul regard.
var shield := 0
var shield_max := 1
var teleport_ratio := 1.0
var teleport_ready := false
## Couleurs des gemmes encore à trouver, et nombre total dans le niveau.
var missing_gems: Array[Color] = []
var gem_total := 0
## Portrait peint du mage joué, ou à défaut son sprite de marche de face.
var portrait: Texture2D = null
var portrait_region := Rect2()
## Progression vers l'Extra Power. `kills_ready` déclenche la mise en valeur :
## un pouvoir débloqué dont personne ne s'aperçoit ne sert à rien.
var kills := 0
var kills_needed := 5
var kills_ready := false

## La vie qu'on vient de perdre reste affichée un instant : c'est ce qui fait voir
## la TAILLE du coup, qu'une jauge qui saute d'un cran ne montre pas.
var _trail := 1.0

var _frame: Texture2D = load(ART_PATH + "cadre_barre.png")
var _gauge_health: Texture2D = load(ART_PATH + "jauge_vie.png")
var _gauge_portal: Texture2D = load(ART_PATH + "jauge_portail.png")
var _gauge_shield: Texture2D = load(ART_PATH + "jauge_bouclier.png")
var _socket: Texture2D = load(ART_PATH + "sertissage.png")
var _gem: Texture2D = load(ART_PATH + "gemme.png")
var _icon_portal: Texture2D = load(ART_PATH + "icone_portail.png")
var _spark: Texture2D = load(ART_PATH + "eclat.png")

## Géométrie lue dans `barre.json`, en unités d'interface.
var _window := Rect2()
var _health_rect := Rect2()
var _portal_rect := Rect2()
var _ring_width := 3.0
var _title_row := Rect2()
var _bottom_row := Rect2()


func _ready() -> void:
	_read_layout()
	_place_labels()


func _read_layout() -> void:
	var text := FileAccess.get_file_as_string(ART_PATH + "barre.json")
	var meta: Dictionary = JSON.parse_string(text)
	size = Vector2(FRAME_WIDTH, FRAME_WIDTH * float(meta["aspect"]))
	_window = _scaled(meta["window"])
	_health_rect = _scaled(meta["health"])
	_portal_rect = _scaled(meta["portal"])
	_ring_width = float(meta["ring"]) * FRAME_WIDTH
	var left := _health_rect.position.x
	var width := _health_rect.size.x
	var plaque_top := float(meta["plaque_top"]) * size.y
	var plaque_bottom := float(meta["plaque_bottom"]) * size.y
	_title_row = Rect2(left, plaque_top, width, _health_rect.position.y - plaque_top)
	_bottom_row = Rect2(left, _portal_rect.end.y,
		width, plaque_bottom - _portal_rect.end.y)


func _scaled(fractions: Array) -> Rect2:
	return Rect2(float(fractions[0]) * size.x, float(fractions[1]) * size.y,
		float(fractions[2]) * size.x, float(fractions[3]) * size.y)


## Les libellés sont centrés sur leur rangée : leur hauteur de ligne dépasse celle
## de la plaque, et posés en haut ils mordraient sur le filet des gouttières.
func _place_labels() -> void:
	_center_label(level_label, _title_row)
	_center_label(counter_label, Rect2(_bottom_row.end.x - counter_width(),
		_bottom_row.position.y, counter_width(), _bottom_row.size.y))
	counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	counter_label.add_theme_color_override("font_color", TEXT)


func _center_label(label: Label, row: Rect2) -> void:
	var height := label.get_minimum_size().y
	label.position = Vector2(row.position.x, row.get_center().y - height * 0.5)
	label.size = Vector2(row.size.x, height)


static func counter_width() -> float:
	return 15.0


func _portal_icon_left() -> float:
	return _bottom_row.end.x - counter_width() - ICON_SIZE


## La place laissée aux gemmes, à gauche du compteur de portails.
func gem_room() -> float:
	return _portal_icon_left() - PADDING - _bottom_row.position.x


## Écart entre deux gemmes : elles se serrent plutôt que de passer sous les compteurs.
static func gem_step(room: float, count: int) -> float:
	if count <= 1:
		return GEM_STEP
	return minf(GEM_STEP, (room - GEM_SIZE) / float(count - 1))


static func segments_fit(width: float, maximum: int) -> bool:
	return maximum > 1 and width / float(maximum) >= MIN_SEGMENT


## Le bouclier part du BOUT de la vie restante : posé au bord de la jauge, il flottait
## loin d'elle à faible vie. S'il n'a plus la place, il recouvre la fin de la vie
## plutôt que de sortir de la gouttière.
static func shield_band(rect: Rect2, health_ratio: float, part: float) -> Rect2:
	var width := rect.size.x * SHIELD_SHARE * clampf(part, 0.0, 1.0)
	var start := rect.position.x + rect.size.x * clampf(health_ratio, 0.0, 1.0)
	start = minf(start, rect.end.x - width)
	return Rect2(start, rect.position.y, width, rect.size.y)


## Le bandeau montre le VRAI mage, dans son portrait peint. Une silhouette générique
## pour tous les personnages ne dit rien : on ne sait plus qui on incarne.
func set_character(stats: CharacterStats) -> void:
	var path := "res://assets/ui/portraits/portrait_%s.jpg" % stats.id
	if ResourceLoader.exists(path):
		portrait = load(path)
		var side := float(portrait.get_width()) * PORTRAIT_CROP_WIDTH
		portrait_region = Rect2((float(portrait.get_width()) - side) * 0.5,
			float(portrait.get_height()) * PORTRAIT_CROP_Y, side, side)
	else:
		portrait = load("res://assets/characters/%s/down.png" % stats.id)
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(
			"res://assets/characters/%s/frames.json" % stats.id))
		var cell: Array = (parsed as Dictionary)["cell"]
		portrait_region = Rect2(0.0, 0.0, float(cell[0]), float(cell[1]) * 0.7)
	queue_redraw()


func set_level(config: LevelConfig, number: int) -> void:
	level_label.text = _fitting_title(config)
	queue_redraw()


func set_shield(amount: int, posed: int = 0) -> void:
	shield = maxi(0, amount)
	if posed > 0:
		shield_max = posed
	queue_redraw()


func set_health(current: int, maximum: int) -> void:
	var previous := float(health) / float(max_health)
	health = current
	max_health = maxi(1, maximum)
	var ratio := float(health) / float(max_health)
	_trail = maxf(previous, ratio) if ratio < previous else ratio
	queue_redraw()


func set_gems(missing: Array[Color], total: int) -> void:
	missing_gems = missing
	gem_total = total
	queue_redraw()


func set_counters(portals: int) -> void:
	counter_label.text = str(portals)
	queue_redraw()


func set_kills(p_kills: int, needed: int, ready: bool) -> void:
	kills = p_kills
	kills_needed = maxi(1, needed)
	kills_ready = ready
	queue_redraw()


func set_teleport(ratio: float, ready: bool) -> void:
	teleport_ratio = clampf(ratio, 0.0, 1.0)
	teleport_ready = ready
	queue_redraw()


func _process(delta: float) -> void:
	var ratio := float(health) / float(max_health)
	if _trail > ratio:
		_trail = maxf(ratio, _trail - TRAIL_SPEED * delta)
		queue_redraw()
	elif kills_ready or _is_low():
		queue_redraw()


func _is_low() -> bool:
	return health > 0 and float(health) / float(max_health) <= LOW_HEALTH


func _pulse() -> float:
	return 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.006)


func _draw() -> void:
	_draw_portrait()
	_draw_health()
	_draw_teleport()
	# Le cadre passe PAR-DESSUS : c'est lui qui donne leur bord net aux jauges et au
	# portrait, qu'on n'a donc pas à découper.
	draw_texture_rect(_frame, Rect2(Vector2.ZERO, size), false)
	_draw_ring()
	_draw_gems()
	_draw_counters()


func _draw_portrait() -> void:
	var center := _window.get_center()
	var radius := _window.size.x * 0.5 + 1.0
	draw_circle(center, radius, PORTRAIT_BG)
	if portrait == null:
		return
	# Un disque texturé : `draw_texture_rect_region` ne sait dessiner que des rectangles,
	# et le cadre n'est percé qu'en rond.
	var points := PackedVector2Array()
	var uvs := PackedVector2Array()
	var texture_size := Vector2(portrait.get_size())
	for i in 40:
		var unit := Vector2.from_angle(TAU * float(i) / 40.0)
		points.append(center + unit * radius)
		var at := portrait_region.get_center() + unit * portrait_region.size * 0.5
		uvs.append(at / texture_size)
	draw_colored_polygon(points, Color.WHITE, uvs, portrait)


func _draw_health() -> void:
	var rect := _health_rect
	draw_rect(rect, GAUGE_BG)
	var ratio := float(health) / float(max_health)
	if _trail > ratio:
		draw_rect(Rect2(rect.position, Vector2(rect.size.x * _trail, rect.size.y)), HEALTH_LOST)
	if ratio > 0.0:
		var tint := Color.WHITE
		if _is_low():
			tint = Color(1.0, 1.0, 1.0).lerp(Color(1.0, 0.55, 0.5), _pulse())
		draw_texture_rect(_gauge_health,
			Rect2(rect.position, Vector2(rect.size.x * ratio, rect.size.y)), false, tint)
	if segments_fit(rect.size.x, max_health):
		for i in range(1, max_health):
			var x := rect.position.x + rect.size.x * float(i) / float(max_health)
			draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), SEPARATOR, 1.5)
	if shield > 0:
		var band := shield_band(rect, ratio, float(shield) / float(maxi(1, shield_max)))
		draw_texture_rect(_gauge_shield, band, false, Color(1.0, 1.0, 1.0, 0.85))


func _draw_teleport() -> void:
	var rect := _portal_rect
	draw_rect(rect, GAUGE_BG)
	if teleport_ratio <= 0.0:
		return
	var filled := Rect2(rect.position, Vector2(rect.size.x * teleport_ratio, rect.size.y))
	draw_texture_rect(_gauge_portal, filled, false)
	if teleport_ready:
		draw_rect(filled, TELEPORT_READY)


## Un cran par kill, à partir du haut, dans la gorge du médaillon : le joueur compte
## ce qu'il lui reste sans quitter le labyrinthe des yeux.
func _draw_ring() -> void:
	var center := _window.get_center()
	var radius := _window.size.x * 0.5 + _ring_width * 0.5
	var gap := 0.10
	var share := TAU / float(kills_needed)
	var color := RING_FILL
	if kills_ready:
		color = GOLD.lerp(Color.WHITE, _pulse() * 0.5)
	for i in kills_needed:
		var start := -PI * 0.5 + share * float(i) + gap * 0.5
		var lit := kills_ready or i < kills
		draw_arc(center, radius, start, start + share - gap, 16,
			color if lit else RING_EMPTY, _ring_width, true)
	if kills_ready:
		var spark := 15.0 + 5.0 * _pulse()
		var at := center + Vector2.from_angle(-PI * 0.25) * radius
		draw_texture_rect(_spark, Rect2(at - Vector2.ONE * spark * 0.5, Vector2.ONE * spark), false)


## Les gemmes ramassées d'abord (sertissage vide), puis celles qui manquent : la
## rangée se remplit donc de gauche à droite au fil de la partie, comme une barre de
## progression dont chaque cran a une couleur.
func _draw_gems() -> void:
	if gem_total <= 0:
		return
	var taken := gem_total - missing_gems.size()
	var step := gem_step(gem_room(), gem_total)
	var y := _bottom_row.get_center().y - GEM_SIZE * 0.5
	for i in gem_total:
		var at := Vector2(_bottom_row.position.x + step * float(i), y)
		var slot := Rect2(at, Vector2.ONE * GEM_SIZE)
		draw_texture_rect(_socket, slot, false)
		if i >= taken:
			draw_texture_rect(_gem, slot.grow(-1.5), false,
				missing_gems[i - taken].lightened(GEM_LIGHTEN))


func _draw_counters() -> void:
	var y := _bottom_row.get_center().y - ICON_SIZE * 0.5
	draw_texture_rect(_icon_portal,
		Rect2(Vector2(_portal_icon_left(), y), Vector2.ONE * ICON_SIZE), false)


## Titre du bandeau, dans la forme la plus longue QUI TIENT.
##
## Le bandeau a été réduit à la demande, et « STAGE 10 · ÉP. 2 — Le Château du
## Ciel » n'y entre pas : il s'affichait tronqué en « Le Château du Ci ». Un
## titre coupé se lit comme un bug.
##
## La forme courte et la plus petite taille tiennent pour les dix noms
## (`tests/test_hud.gd`). Le NOM du lieu est dans les deux formes, c'est lui que le
## joueur lit ; le numéro, il vient de le choisir au menu.
func _fitting_title(config: LevelConfig) -> String:
	if config.is_demo:
		# Le décor visité prime : en démo on regarde un stage, on ne joue pas un
		# terrain anonyme. Le mot DÉMO reste, il dit pourquoi on ne meurt pas.
		return "DÉMO — %s" % config.level_name
	var candidates := [
		"ST.%d · ÉP.%d — %s" % [config.stage, config.episode, config.level_name],
		"%d·%d — %s" % [config.stage, config.episode, config.level_name],
	]
	var font := level_label.get_theme_font("font")
	if font == null:
		return candidates[-1]
	for font_size in TITLE_SIZES:
		level_label.add_theme_font_size_override("font_size", font_size)
		for candidate in candidates:
			if font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1.0,
					font_size).x <= _title_row.size.x:
				return candidate
	return candidates[-1]
