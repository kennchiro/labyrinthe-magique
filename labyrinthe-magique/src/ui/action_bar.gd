class_name ActionBar
extends Control

## Barre d'action du CLAVIER — Mac, Windows, Linux.
##
## Le jeu affichait ses six compétences uniquement sur téléphone, dans le pad
## tactile. Au clavier, elles existaient mais RIEN ne les montrait : un joueur
## sur Mac ne pouvait pas savoir qu'il avait trois sorts, encore moins lesquels
## étaient prêts. Les touches ne s'apprennent pas en les devinant.
##
## Elle affiche les mêmes entrées que le pad tactile — c'est l'UIManager qui les
## fabrique, une seule fois, pour les deux. La barre ne sait rien du jeu.
##
## Les libellés de touche sont lus dans l'InputMap au moment de l'affichage, et
## non écrits en dur : si une touche est rebindée, la barre suit. Une antisèche
## qui ment est pire que pas d'antisèche.

## Actions du moteur, dans l'ordre des slots de `CharacterStats.action_bar()`.
## `teleport` est bien la FRAPPE : la barre d'espace est contextuelle — elle
## prend le portail quand le mage est dessus, elle frappe partout ailleurs.
## L'action a gardé son nom d'origine, d'avant que le combat existe.
const ACTIONS := ["teleport", "skill_1", "skill_2", "skill_3", "escape_skill", "ultimate"]
## Slot renvoyé par l'UIManager quand la frappe devient « prendre le portail ».
const SLOT_PORTAL := -1

const TILE := Vector2(104.0, 50.0)
const GAP := 8.0
const MARGIN_BOTTOM := 16.0
## Tailles du nom du sort : sur une ligne tant qu'il reste lisible, puis sur deux.
const NAME_SIZE := 12
const NAME_ONE_LINE_MIN := 10
const NAME_SIZE_MIN := 8
const NAME_MARGIN := 3.0

var entries: Array[Dictionary] = []

var _keys: Array[String] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_keys = _key_labels()
	resized.connect(queue_redraw)


## Libellé de la première touche liée à chaque action. Vide si l'action n'a que
## des boutons de manette : la barre affichera alors le nom du sort seul, plutôt
## qu'un carré vide qui laisserait croire à une touche manquante.
func _key_labels() -> Array[String]:
	var out: Array[String] = []
	for action in ACTIONS:
		var label := ""
		if InputMap.has_action(action):
			for event in InputMap.action_get_events(action):
				if event is InputEventKey:
					var key := event as InputEventKey
					var code := key.physical_keycode if key.physical_keycode != 0 else key.keycode
					label = OS.get_keycode_string(code)
					break
		out.append(_short(label))
	return out


## « Space » tient mal dans une case de 74 pixels ; « ESPACE » non plus. On garde
## le symbole que tous les claviers portent.
func _short(label: String) -> String:
	match label:
		"Space": return "ESPACE"
		"Escape": return "ÉCH"
		_: return label.to_upper()


func set_entries(new_entries: Array[Dictionary]) -> void:
	entries = new_entries
	queue_redraw()


func _tile(index: int, count: int) -> Rect2:
	var total := float(count) * TILE.x + float(count - 1) * GAP
	var origin := Vector2((size.x - total) * 0.5, size.y - TILE.y - MARGIN_BOTTOM)
	return Rect2(origin + Vector2(float(index) * (TILE.x + GAP), 0.0), TILE)


func _draw() -> void:
	if entries.is_empty():
		return
	var font := get_theme_default_font()
	var count := entries.size()
	for index in count:
		_draw_slot(font, _tile(index, count), entries[index], index)


func _draw_slot(font: Font, rect: Rect2, entry: Dictionary, index: int) -> void:
	var color: Color = entry.get("color", Color.WHITE)
	var ready: bool = entry.get("ready", false)
	var locked: bool = entry.get("locked", false)
	var ratio: float = clampf(float(entry.get("ratio", 1.0)), 0.0, 1.0)

	draw_rect(rect, Color(0.05, 0.06, 0.11, 0.86))
	# La recharge REMPLIT la case par le bas : sur une tuile carrée, une barre
	# qui monte se lit mieux qu'un secteur qui tourne.
	if ratio < 1.0:
		var filled := Rect2(rect.position + Vector2(0.0, rect.size.y * (1.0 - ratio)),
			Vector2(rect.size.x, rect.size.y * ratio))
		draw_rect(filled, Color(color.r * 0.30, color.g * 0.30, color.b * 0.30, 0.85))
	else:
		draw_rect(rect.grow(-2.0),
			Color(color.r * 0.26, color.g * 0.26, color.b * 0.26, 0.90 if ready else 0.45))

	# L'icône occupe la GAUCHE de la case, le texte se décale à sa droite. Une
	# icône posée derrière le texte rendrait les deux illisibles.
	var icon: Texture2D = entry.get("icon", null)
	var text_left := 6.0
	if icon != null:
		var span := rect.size.y - 8.0
		draw_texture_rect(icon,
			Rect2(rect.position + Vector2(3.0, 4.0), Vector2(span, span)), false,
			Color(1, 1, 1, 0.95) if ready else Color(0.78, 0.8, 0.86, 0.8))
		text_left = span + 6.0

	var edge := color if ready else Color(0.38, 0.44, 0.58)
	draw_rect(rect, edge, false, 2.0 if ready else 1.0)
	if ready and bool(entry.get("highlight", false)):
		var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.005)
		draw_rect(rect.grow(2.0 + 2.0 * pulse), Color(color.r, color.g, color.b, 0.5 * pulse), false, 2.0)

	if font == null:
		return
	# Touche en haut, nom du sort en bas. Le nom est ce qui apprend le jeu ; la
	# touche est ce qui sert une fois qu'on le connaît.
	var key: String = _keys[index] if index < _keys.size() else ""
	if int(entry.get("slot", index)) == SLOT_PORTAL:
		key = _keys[0]
	var tint := Color(1, 1, 1) if ready else Color(0.62, 0.68, 0.80)
	if not key.is_empty():
		draw_string(font, rect.position + Vector2(text_left, 17.0), key,
			HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - text_left - 4.0, 14, tint)
	# Les charges se lisent en haut à droite de la case : « 3/5 ». C'est
	# l'information qui décide du prochain geste — poser un brasier de plus, ou
	# garder la dernière charge pour la sortie du repaire.
	var charges := int(entry.get("charges", -1))
	if charges >= 0:
		var stock := "%d/%d" % [charges, int(entry.get("charges_max", 1))]
		var stock_color := color if charges > 0 else Color(0.62, 0.66, 0.78)
		draw_string(font, rect.position + Vector2(rect.size.x - 34.0, 17.0), stock,
			HORIZONTAL_ALIGNMENT_RIGHT, 28.0, 12, stock_color)

	var label := str(entry.get("name", ""))
	if int(entry.get("slot", index)) == SLOT_PORTAL:
		label = "Portail"
	if locked:
		label = "verrouillé"
		tint = Color(0.55, 0.60, 0.72)
	var fit := fit_name(font, label, rect.size.x - text_left - NAME_MARGIN)
	var lines: PackedStringArray = fit["lines"]
	var baseline := rect.position.y + rect.size.y - 8.0 if lines.size() == 1 \
			else rect.position.y + rect.size.y - 6.0 - float(fit["size"]) - 1.0
	for line in lines:
		draw_string(font, Vector2(rect.position.x + text_left, baseline), line,
			HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - text_left - NAME_MARGIN, int(fit["size"]), tint)
		baseline += float(fit["size"]) + 1.0


## Le nom entier, jamais amputé : « Pas de… » n'apprend rien au joueur. Il rétrécit sur
## une ligne, puis passe sur deux, coupé là où les lignes s'équilibrent le mieux.
static func fit_name(font: Font, label: String, room: float) -> Dictionary:
	for font_size in range(NAME_SIZE, NAME_ONE_LINE_MIN - 1, -1):
		if _width(font, label, font_size) <= room:
			return {"lines": PackedStringArray([label]), "size": font_size}
	var words := label.split(" ", false)
	for font_size in range(NAME_SIZE - 1, NAME_SIZE_MIN - 1, -1):
		var best := PackedStringArray()
		var best_width := room
		for cut in range(1, words.size()):
			var first := " ".join(words.slice(0, cut))
			var second := " ".join(words.slice(cut))
			var widest := maxf(_width(font, first, font_size), _width(font, second, font_size))
			if widest <= best_width:
				best = PackedStringArray([first, second])
				best_width = widest
		if not best.is_empty():
			return {"lines": best, "size": font_size}
	return {"lines": PackedStringArray([label]), "size": NAME_SIZE_MIN}


static func _width(font: Font, text: String, font_size: int) -> float:
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
