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
		draw_string(font, rect.position + Vector2(6.0, 17.0), key,
			HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 10.0, 14, tint)
	var label := str(entry.get("name", ""))
	if int(entry.get("slot", index)) == SLOT_PORTAL:
		label = "Portail"
	if locked:
		label = "verrouillé"
		tint = Color(0.55, 0.60, 0.72)
	# Le nom rétrécit jusqu'à tenir. Godot COUPE au lieu de réduire, et un sort
	# affiché « Explosion d' » n'apprend rien — mieux vaut deux points de moins.
	var room := rect.size.x - 12.0
	var font_size := 12
	while font_size > 8 and font.get_string_size(
			label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x > room:
		font_size -= 1
	draw_string(font, rect.position + Vector2(6.0, rect.size.y - 8.0), label,
		HORIZONTAL_ALIGNMENT_LEFT, room, font_size, tint)
