class_name ArenaHud
extends Control

## Ce qu'on lit pendant un match d'arène : la jauge de chaque équipe (Gemme-Cœur) ou les héros
## encore debout (Duel à mort), le temps, les chutes, puis le verdict. Il AFFICHE seulement :
## tout ce qu'il montre vient de l'`ArenaMatch` (règle n° 2).

signal quit_requested
signal speed_requested
signal replay_requested
signal teams_requested

const GOLD := Color("#ffd479")
const FEED_LIFE := 4.0

var arena: ArenaMatch = null
var speed := 1.0

var _speed_button: Button
var _quit_button: Button
var _timer: Label
var _feed: Array[Dictionary] = []
var _result: Control = null
## Un bouton d'Éveil par héros de l'équipe du joueur, posé sur sa carte du bas.
var _awaken_buttons := {}


func setup(p_arena: ArenaMatch) -> void:
	arena = p_arena
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_speed_button = _button("×1", Color("#9fe8b4"))
	_speed_button.pressed.connect(func() -> void: speed_requested.emit())
	_quit_button = _button("QUITTER", MenuStyle.EDGE)
	_quit_button.pressed.connect(func() -> void: quit_requested.emit())
	_timer = Label.new()
	_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_timer.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.06))
	_timer.add_theme_constant_override("outline_size", 6)
	_timer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_timer)
	arena.fighter_fell.connect(_on_fell)
	arena.fighter_awakening.connect(func(f: ArenaFighter) -> void:
		_feed.push_front({"text": "ÉVEIL : %s !" % f.awakening.awakened.display_name, "team": f.team, "life": FEED_LIFE})
		if _feed.size() > 4:
			_feed.resize(4))
	# L'ÉVEIL DE SON ÉQUIPE EST LA SEULE DÉCISION QUE LE JOUEUR GARDE pendant le match.
	if arena.manual_team >= 0:
		for fighter in arena.teams[arena.manual_team]:
			var f: ArenaFighter = fighter
			if f.awakening == null:
				continue
			var button := _button("ÉVEIL", GOLD)
			button.pressed.connect(func() -> void: arena.awaken(f))
			_awaken_buttons[f] = button
	resized.connect(_layout)
	_layout()


func set_speed(value: float) -> void:
	speed = value
	_speed_button.text = "×%d" % int(value)


func _on_fell(victim: ArenaFighter, killer: ArenaFighter) -> void:
	var text := "%s est tombé" % victim.stats.display_name
	if killer != null:
		text = "%s abat %s" % [killer.stats.display_name, victim.stats.display_name]
	_feed.push_front({"text": text, "team": killer.team if killer != null else 1 - victim.team, "life": FEED_LIFE})
	if _feed.size() > 4:
		_feed.resize(4)


func _process(delta: float) -> void:
	for entry in _feed:
		entry["life"] = float(entry["life"]) - delta / maxf(1.0, speed)
	_feed = _feed.filter(func(e: Dictionary) -> bool: return float(e["life"]) > 0.0)
	_refresh_awaken_buttons()
	if arena != null:
		var left := int(ceil(arena.time_left))
		_timer.text = "%d:%02d" % [left / 60, left % 60]
		_timer.add_theme_color_override("font_color", Color("#ff8a7a") if left <= 15 else Color.WHITE)
	queue_redraw()


## Le bouton dit où en est l'Éveil : la charge, prêt, éveillé (avec le temps qui reste), épuisé.
func _refresh_awaken_buttons() -> void:
	for f in _awaken_buttons:
		var fighter: ArenaFighter = f
		var button: Button = _awaken_buttons[f]
		var awakening := fighter.awakening
		button.visible = _result == null
		var ready := fighter.alive() and awakening.can_begin()
		button.disabled = not ready
		match awakening.state:
			Awakening.State.AWAKE:
				button.text = "%d s" % int(ceil(awakening.left))
			Awakening.State.CHARGING:
				button.text = "…"
			Awakening.State.EXHAUSTED:
				button.text = "Épuisé"
			_:
				button.text = "ÉVEIL" if ready else "%d %%" % int(awakening.charge_ratio() * 100.0)
		button.modulate = Color(1.25, 1.15, 0.85) if ready and int(Time.get_ticks_msec() / 350) % 2 == 0 else Color.WHITE


func _roster_box(team: int, slot: int) -> Rect2:
	var m := clampf(size.x * 0.012, 6.0, 16.0)
	var height := clampf(size.y * 0.09, 26.0, 46.0)
	var top := size.y - m - height
	var span := (size.x * 0.5 - m * 2.0)
	var card_w := minf(span / 3.0 - m * 0.5, size.x * 0.15)
	var x := m + float(slot) * (card_w + m * 0.5) if team == 0 \
		else size.x - m - float(slot + 1) * card_w - float(slot) * m * 0.5
	return Rect2(x, top, card_w, height)


func _bar_height() -> float:
	return clampf(size.y * 0.075, 22.0, 40.0)


func _layout() -> void:
	if _timer == null:
		return
	var m := clampf(size.x * 0.012, 6.0, 16.0)
	var bar := _bar_height()
	_speed_button.position = Vector2(size.x - m - bar * 1.4 - m - size.x * 0.13, m)
	_speed_button.size = Vector2(bar * 1.4, bar)
	_quit_button.position = Vector2(size.x - m - size.x * 0.13, m)
	_quit_button.size = Vector2(size.x * 0.13, bar)
	for button in [_speed_button, _quit_button]:
		(button as Button).add_theme_font_size_override("font_size", int(clampf(bar * 0.42, 10.0, 17.0)))
	_timer.position = Vector2(size.x * 0.5 - bar * 1.6, m)
	_timer.size = Vector2(bar * 3.2, bar)
	_timer.add_theme_font_size_override("font_size", int(clampf(bar * 0.62, 13.0, 24.0)))
	# Le bouton d'Éveil s'accroche AU-DESSUS de la carte de son héros : sur elle, il cacherait sa vie.
	for f in _awaken_buttons:
		var fighter: ArenaFighter = f
		var box := _roster_box(fighter.team, fighter.slot)
		var button: Button = _awaken_buttons[f]
		var height := clampf(box.size.y * 0.8, 22.0, 34.0)
		button.position = Vector2(box.position.x + box.size.x * 0.25, box.position.y - height - 4.0)
		button.size = Vector2(box.size.x * 0.5, height)
		button.add_theme_font_size_override("font_size", int(clampf(height * 0.45, 9.0, 15.0)))
	if _result != null:
		_build_result_layout()


func _draw() -> void:
	if arena == null:
		return
	var m := clampf(size.x * 0.012, 6.0, 16.0)
	var bar := _bar_height()
	var font := get_theme_default_font()
	var font_size := int(clampf(bar * 0.45, 10.0, 18.0))
	var gauge_w := size.x * 0.27
	# Les deux jauges, de part et d'autre du temps : bleus à gauche, rouges à droite.
	for team in 2:
		var color: Color = ArenaRules.TEAM_COLORS[team]
		var x := size.x * 0.5 - bar * 1.7 - gauge_w if team == 0 else size.x * 0.5 + bar * 1.7
		var box := Rect2(x, m + bar * 0.2, gauge_w, bar * 0.6)
		draw_rect(box.grow(2.0), Color(0.02, 0.03, 0.07, 0.85))
		var share := 0.0
		var text := ""
		if arena.mode == ArenaRules.Mode.HEART:
			share = arena.score[team] / ArenaRules.HEART_GOAL
			text = "%d" % int(arena.score[team])
		else:
			share = arena.life_share(team)
			text = "%d / %d debout" % [arena.alive_count(team), (arena.teams[team] as Array).size()]
		share = clampf(share, 0.0, 1.0)
		# La jauge des bleus se remplit vers le centre, celle des rouges aussi : elles se font face.
		var fill := Rect2(box.position + Vector2(box.size.x * (1.0 - share) if team == 0 else 0.0, 0.0),
			Vector2(box.size.x * share, box.size.y))
		draw_rect(fill, color)
		if arena.mode == ArenaRules.Mode.HEART and arena.holder == team:
			draw_rect(box.grow(2.0), Color(color, 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.008)), false, 2.0)
		var label := "%s  %s" % [ArenaRules.TEAM_NAMES[team], text]
		var width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var tx := box.position.x + 6.0 if team == 0 else box.end.x - width - 6.0
		draw_string_outline(font, Vector2(tx, box.end.y + font_size + 2.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 5, Color(0.02, 0.02, 0.06))
		draw_string(font, Vector2(tx, box.end.y + font_size + 2.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color.lerp(Color.WHITE, 0.3))
	# En bas : un bandeau par héros, avec sa vie et le retour qui se décompte.
	_draw_roster(m, font)
	# Les chutes récentes, en haut à gauche.
	# Sous les jauges et leurs noms, à gauche : au-dessus, il chevauchait la jauge des bleus.
	var feed_size := int(clampf(bar * 0.4, 9.0, 15.0))
	var y := m + bar * 1.2 + font_size + feed_size + 6.0
	for entry in _feed:
		var alpha := clampf(float(entry["life"]), 0.0, 1.0)
		var color: Color = ArenaRules.TEAM_COLORS[int(entry["team"])]
		draw_string_outline(font, Vector2(m, y), str(entry["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, feed_size, 4, Color(0.02, 0.02, 0.06, alpha))
		draw_string(font, Vector2(m, y), str(entry["text"]), HORIZONTAL_ALIGNMENT_LEFT, -1, feed_size, Color(color.lerp(Color.WHITE, 0.4), alpha))
		y += feed_size + 4


func _draw_roster(m: float, font: Font) -> void:
	var height := clampf(size.y * 0.09, 26.0, 46.0)
	var top := size.y - m - height
	var font_size := int(clampf(height * 0.32, 9.0, 15.0))
	for team in 2:
		var group: Array = arena.teams[team]
		for slot in group.size():
			var fighter: ArenaFighter = group[slot]
			var box := _roster_box(team, slot)
			var card_w := box.size.x
			var color: Color = ArenaRules.TEAM_COLORS[team]
			draw_rect(box, Color(0.03, 0.04, 0.09, 0.82))
			draw_rect(box, Color(color, 0.7), false, 1.5)
			var heading := fighter.stats.display_name
			draw_string(font, box.position + Vector2(5.0, font_size + 3.0), heading, HORIZONTAL_ALIGNMENT_LEFT, card_w - 10.0, font_size, Color.WHITE)
			var life := Rect2(box.position + Vector2(5.0, height - 9.0), Vector2(card_w - 10.0, 5.0))
			draw_rect(life, Color(0.0, 0.0, 0.0, 0.6))
			if fighter.alive():
				draw_rect(Rect2(life.position, Vector2(life.size.x * fighter.health.ratio(), life.size.y)), color)
				var tally := "%d · %s" % [fighter.tally_kills, ArenaRules.POSTURE_NAMES[fighter.posture]]
				draw_string(font, box.position + Vector2(5.0, font_size * 2.0 + 4.0), tally, HORIZONTAL_ALIGNMENT_LEFT, card_w - 10.0, maxi(8, font_size - 2), Color(0.75, 0.8, 0.95))
			elif arena.mode == ArenaRules.Mode.HEART and fighter.respawn_left < INF:
				draw_string(font, box.position + Vector2(5.0, font_size * 2.0 + 4.0), "retour dans %d s" % int(ceil(fighter.respawn_left)), HORIZONTAL_ALIGNMENT_LEFT, card_w - 10.0, maxi(8, font_size - 2), GOLD)
			else:
				draw_string(font, box.position + Vector2(5.0, font_size * 2.0 + 4.0), "hors combat", HORIZONTAL_ALIGNMENT_LEFT, card_w - 10.0, maxi(8, font_size - 2), Color(0.6, 0.6, 0.7))


# --- Le verdict ------------------------------------------------------------------------

func show_result() -> void:
	if _result != null:
		return
	_result = Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.03, 0.07, 0.86)
	_result.add_theme_stylebox_override("panel", style)
	add_child(_result)
	_result.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_result.mouse_filter = Control.MOUSE_FILTER_STOP
	var title := Label.new()
	title.name = "Title"
	var subtitle := Label.new()
	subtitle.name = "Subtitle"
	var table := Label.new()
	table.name = "Table"
	for label in [title, subtitle, table]:
		(label as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		(label as Label).add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.06))
		(label as Label).add_theme_constant_override("outline_size", 6)
		_result.add_child(label)
	match arena.winner:
		0:
			title.text = "VICTOIRE !"
			title.add_theme_color_override("font_color", GOLD)
		1:
			title.text = "DÉFAITE"
			title.add_theme_color_override("font_color", ArenaRules.TEAM_COLORS[1])
		_:
			title.text = "ÉGALITÉ"
	if arena.mode == ArenaRules.Mode.HEART:
		subtitle.text = "Gemme-Cœur  ·  %d contre %d" % [int(arena.score[0]), int(arena.score[1])]
	else:
		subtitle.text = "Duel à mort  ·  %d debout contre %d" % [arena.alive_count(0), arena.alive_count(1)]
	var lines := PackedStringArray()
	for fighter in arena.fighters:
		lines.append("%s %s — %d abattu%s, %d chute%s, %d dégâts, %d esquive%s" % [
			"●" if fighter.team == 0 else "○", fighter.stats.display_name,
			fighter.tally_kills, "s" if fighter.tally_kills > 1 else "",
			fighter.tally_deaths, "s" if fighter.tally_deaths > 1 else "", fighter.tally_damage,
			fighter.tally_dodges, "s" if fighter.tally_dodges > 1 else ""])
	table.text = "\n".join(lines)
	var replay := _button("REJOUER", GOLD)
	replay.reparent(_result)
	replay.name = "Replay"
	replay.pressed.connect(func() -> void: replay_requested.emit())
	var teams := _button("ÉQUIPES", Color("#9fc4ff"))
	teams.reparent(_result)
	teams.name = "Teams"
	teams.pressed.connect(func() -> void: teams_requested.emit())
	var menu := _button("MENU", MenuStyle.EDGE)
	menu.reparent(_result)
	menu.name = "Menu"
	menu.pressed.connect(func() -> void: quit_requested.emit())
	_build_result_layout()


func _build_result_layout() -> void:
	var w := size.x
	var h := size.y
	var title: Label = _result.get_node("Title")
	var subtitle: Label = _result.get_node("Subtitle")
	var table: Label = _result.get_node("Table")
	title.position = Vector2(0.0, h * 0.06)
	title.size = Vector2(w, h * 0.16)
	title.add_theme_font_size_override("font_size", int(clampf(h * 0.11, 22.0, 64.0)))
	subtitle.position = Vector2(0.0, h * 0.22)
	subtitle.size = Vector2(w, h * 0.08)
	subtitle.add_theme_font_size_override("font_size", int(clampf(h * 0.045, 12.0, 24.0)))
	table.position = Vector2(w * 0.1, h * 0.32)
	table.size = Vector2(w * 0.8, h * 0.44)
	table.add_theme_font_size_override("font_size", int(clampf(h * 0.04, 10.0, 18.0)))
	var bw := w * 0.2
	var bh := clampf(h * 0.1, 30.0, 52.0)
	var gap := w * 0.03
	var x := (w - bw * 3.0 - gap * 2.0) * 0.5
	for node_name in ["Replay", "Teams", "Menu"]:
		var button: Button = _result.get_node(node_name)
		button.position = Vector2(x, h - bh - h * 0.06)
		button.size = Vector2(bw, bh)
		button.add_theme_font_size_override("font_size", int(clampf(bh * 0.4, 12.0, 20.0)))
		x += bw + gap


func _button(text: String, accent: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	MenuStyle.apply(button, accent, 16)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := button.get_theme_stylebox(state) as StyleBoxFlat
		if box != null:
			box.content_margin_left = 6.0
			box.content_margin_right = 6.0
			box.content_margin_top = 4.0
			box.content_margin_bottom = 4.0
	add_child(button)
	return button
