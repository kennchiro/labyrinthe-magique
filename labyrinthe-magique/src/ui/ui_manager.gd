class_name UIManager
extends CanvasLayer

## Façade de l'interface. Le GameManager ne connaît QUE cette classe : il ne
## touche jamais un Label ni un Button directement. Refaire tout l'habillage ne
## demande donc aucune modification de la logique de jeu.

signal resume_requested
signal restart_requested
signal next_requested
signal pause_requested
signal menu_requested
## Le joueur ouvre ou ferme son carnet de quête. L'UIManager ne décide pas de la
## pause : c'est le GameManager qui arbitre, comme pour le bouton de pause.
signal quest_requested
## Slot demandé : -1 pour le portail, 0 l'attaque, 1 à 3 les sorts, 4 l'ultime.
signal action_requested(slot: int)

## Durée d'affichage d'un message ponctuel avant retour à l'invite normale.
const FLASH_DURATION := 1.4
## L'objectif, dit au début de chaque niveau : il n'apparaissait que dans la pause. En
## bandeau et non dans l'invite du bas, trop étroite entre le manche et l'éventail.
const OBJECTIVE_DURATION := 3.2
const OBJECTIVE_FADE := 0.8
## Hauteur que le bandeau se donne sous la barre du mage, sur deux lignes au besoin.
const OBJECTIVE_HEIGHT := 64.0

@onready var hud: HUD = $HUD
@onready var prompt_label: Label = $PromptLabel
@onready var stick: TouchStick = $TouchStick
@onready var combat_pad: CombatPad = $CombatPad
@onready var action_bar: ActionBar = $ActionBar
@onready var pause_button: Button = $PauseButton
@onready var quest_button: Button = $QuestButton
@onready var quest_panel: QuestPanel = $QuestPanel
@onready var result_screen: ResultScreen = $ResultScreen
@onready var debug_label: Label = $DebugLabel
## Barre de visite des décors, en démo seulement (voir `show_demo_bar`).
@onready var demo_bar: Control = $DemoBar

var touch_mode := false

var _flash_timer := 0.0
## La barre du boss, créée à sa première apparition : la plupart des niveaux n'en ont pas.
var _boss_bar: BossBar = null
## Le panneau des réglages, créé à son ouverture.
var _settings: SettingsPanel = null
var _character_id := CharacterCatalog.default_id()
var hero_demo_picker: HeroDemoPicker = null
## Le bouton de la Transformation d'Aël, à droite de la barre du mage. Caché pour tous les autres.
var transform_button: TransformButton = null
## Niveau du héros au début du niveau : la victoire dit s'il en a gagné un. -1 tant
## qu'aucune progression n'est arrivée depuis le début du niveau.
var _hero_rank_at_start := -1
var _objective_banner: Label = null
var _objective_fade: Tween = null
var _hero_rank := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Le support, pas la visibilité du manche : en mode « toucher le chemin »
	# le manche est rangé, mais l'écran reste tactile — pad de combat compris.
	touch_mode = Platform.touch_ui()
	combat_pad.visible = touch_mode
	# Au clavier, la barre remplace le pad : mêmes entrées, autre affichage.
	# Sans elle, un joueur sur Mac ne voyait aucune de ses six compétences.
	action_bar.visible = not touch_mode
	debug_label.visible = false
	result_screen.settings_available = touch_mode
	stick.layout = Settings.touch_layout()
	combat_pad.layout = Settings.touch_layout()
	_apply_control_scheme()
	if touch_mode:
		Platform.apply_ui_scale(get_window())
		_place_prompt()
		get_viewport().size_changed.connect(_place_prompt)
		get_viewport().size_changed.connect(_place_corner_buttons)
		_place_corner_buttons()
	result_screen.visibility_changed.connect(_refresh_controls)

	combat_pad.action_requested.connect(func(slot: int) -> void: action_requested.emit(slot))
	transform_button = TransformButton.new()
	transform_button.visible = false
	add_child(transform_button)
	transform_button.pressed.connect(func() -> void: action_requested.emit(GameManager.SLOT_TRANSFORM))
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	# Le bouton du carnet est habillé comme les boutons de menu : le bouton gris
	# par défaut de Godot se perd sur un labyrinthe clair, et celui-ci doit
	# s'attraper du pouce sans qu'on le cherche.
	MenuStyle.apply(quest_button, Color("#ffd479"), 22)
	quest_button.pressed.connect(func() -> void: quest_requested.emit())
	quest_panel.close_requested.connect(func() -> void: quest_requested.emit())
	result_screen.resume_requested.connect(func() -> void: resume_requested.emit())
	result_screen.restart_requested.connect(func() -> void: restart_requested.emit())
	result_screen.next_requested.connect(func() -> void: next_requested.emit())
	result_screen.menu_requested.connect(func() -> void: menu_requested.emit())
	result_screen.settings_requested.connect(open_settings)


func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta


# --- Bandeau ---------------------------------------------------------------------

func set_character(stats: CharacterStats) -> void:
	_character_id = stats.id
	hud.set_character(stats)


func set_level(config: LevelConfig, number: int) -> void:
	hud.set_level(config, number)
	_hero_rank_at_start = _hero_rank
	_flash_timer = 0.0
	prompt_label.text = ""
	if not config.is_demo:
		_show_objective(_objective(config))
	if demo_bar.visible:
		demo_bar.get_node("Label").text = "%d / %d — %s" % [
			config.stage, LevelConfig.STAGE_COUNT, config.level_name]


## Affiche la barre de visite des décors. Elle n'existe qu'en démo : en partie,
## deux flèches qui changent de stage seraient une triche, pas un outil.
func show_demo_bar(on_step: Callable, on_boss: Callable) -> void:
	demo_bar.visible = true
	MenuStyle.apply(demo_bar.get_node("Prev"), Color("#9fe8b4"), 22)
	MenuStyle.apply(demo_bar.get_node("Next"), Color("#9fe8b4"), 22)
	demo_bar.get_node("Prev").pressed.connect(func() -> void: on_step.call(-1))
	demo_bar.get_node("Next").pressed.connect(func() -> void: on_step.call(1))
	MenuStyle.apply(demo_bar.get_node("Boss"), Color("#ff9a7a"), 16)
	demo_bar.get_node("Boss").pressed.connect(on_boss)
	_layout_demo()
	get_viewport().size_changed.connect(_layout_demo)


## Le bouton laisse sa place à la barre de vie pendant le combat.
func set_demo_boss_available(available: bool) -> void:
	demo_bar.get_node("Boss").visible = available


func set_health(current: int, maximum: int) -> void:
	hud.set_health(current, maximum)


func set_shield(amount: int, posed: int = 0) -> void:
	hud.set_shield(amount, posed)


func set_counters(portals: int) -> void:
	hud.set_counters(portals)


func set_gems(missing: Array[Color], total: int) -> void:
	hud.set_gems(missing, total)


func set_kills(kills: int, needed: int, ready: bool) -> void:
	hud.set_kills(kills, needed, ready)


## `state` décrit la barre d'action complète. L'interface ne calcule rien : le
## GameManager lui dit ce qui est prêt, ce qui recharge et ce qui est verrouillé.
func set_action_state(state: Dictionary) -> void:
	hud.set_teleport(float(state["teleport_ratio"]), bool(state["can_teleport"]))
	combat_pad.set_entries(state["entries"])
	action_bar.set_entries(state["entries"])

	if _flash_timer > 0.0:
		return
	if bool(state["can_teleport"]) and bool(state["gamble"]):
		_set_prompt("%s  —  Portail risqué : tu es déjà proche" % action_key(), Color("#e0a05c"))
	elif bool(state["can_teleport"]):
		_set_prompt("%s  —  Téléportation" % action_key(), Color("#9ef0ff"))
	elif bool(state["on_portal"]):
		_set_prompt("Portail instable…", Color("#7b8bb0"))
	elif bool(state["ultimate_ready"]):
		_set_prompt("%s  —  EXTRA HIT prêt !" % _ultimate_key(), Color("#ffd15a"))
	elif bool(state["can_attack"]):
		_set_prompt("%s  —  Frapper" % action_key(), Color("#9ef0ff"))
	else:
		_set_prompt("", Color.WHITE)


## Gemmes, potions et ennemis à l'écran : le pad signale ceux qu'il cache.
func show_beneath_controls(things: Array[Dictionary]) -> void:
	if combat_pad.visible:
		combat_pad.show_beneath(things)


func flash(text: String, color: Color, duration := FLASH_DURATION) -> void:
	_set_prompt(text, color)
	_flash_timer = duration


## Direction demandée par le manche tactile. Vector2.ZERO doigt levé ou pouce au
## repos dans la zone morte — et depuis que le mage ne court plus tout seul, cela
## signifie « s'arrêter ». Manche rangé (mode tap) : toujours ZERO, donc inerte.
func touch_direction() -> Vector2:
	return stick.direction


## Le mode « toucher le chemin » est-il celui qui pilote le mage en ce moment ?
func tap_move_active() -> bool:
	return touch_mode and Settings.tap_to_move()


## Ce point de l'écran appartient-il à l'interface ? Le GameManager le demande
## avant de traduire un tap en ordre de marche : le pad de combat et le bouton
## de pause lisent leurs touches sans les consommer, un tap sur eux arriverait
## donc AUSSI au labyrinthe.
func touch_reserved(point: Vector2) -> bool:
	if combat_pad.visible and combat_pad.covers(point):
		return true
	if pause_button.visible and pause_button.get_global_rect().has_point(point):
		return true
	if quest_button.visible and quest_button.get_global_rect().has_point(point):
		return true
	if transform_button != null and transform_button.visible and transform_button.get_global_rect().has_point(point):
		return true
	if hero_demo_picker != null and hero_demo_picker.visible and (hero_demo_picker.get_global_rect().has_point(point) or hero_demo_picker.choice.get_popup().visible):
		return true
	if demo_bar.visible and (demo_bar.get_global_rect().has_point(point)
			or demo_bar.get_node("Boss").get_global_rect().has_point(point)):
		return true
	# ⚠️ LE CARNET OUVERT RÉSERVE TOUT L'ÉCRAN. Son voile arrête déjà les clics
	# de l'interface, mais le GameManager, lui, lit les taps SANS passer par les
	# nœuds : sans cette ligne, un tap sur la page ouverte ferait marcher le mage
	# derrière elle. C'est le piège déjà payé une fois avec le pad de combat.
	if quest_panel.visible or _settings != null:
		return true
	return false


func show_boss(boss_name: String, ratio: float) -> void:
	if _boss_bar == null:
		_boss_bar = BossBar.new()
		if demo_bar.visible:
			_boss_bar.top = BossBar.TOP_UNDER_DEMO_BAR
		add_child(_boss_bar)
	_boss_bar.visible = true
	_boss_bar.set_state(boss_name, ratio)


func hide_boss() -> void:
	if _boss_bar != null:
		_boss_bar.visible = false


## Ouvre les réglages par-dessus la pause. Les vraies commandes se rangent le temps de
## les régler : elles lisent leurs touches sans passer par les nœuds, et un doigt
## posé sur le panneau lancerait un sort derrière lui.
func open_settings() -> void:
	if _settings != null:
		return
	_settings = SettingsPanel.new()
	_settings.character_id = _character_id
	_settings.closed.connect(hide_settings)
	add_child(_settings)
	combat_pad.visible = false
	stick.set_enabled(false)


func hide_settings() -> void:
	if _settings == null:
		return
	_settings.queue_free()
	_settings = null
	_refresh_controls()


## Le panneau, pour les captures et les tests. Null quand il est fermé.
func settings_panel() -> SettingsPanel:
	return _settings


## Applique le mode de déplacement choisi : le manche ou la croix, rien au mode tap.
func _apply_control_scheme() -> void:
	stick.set_style(TouchStick.Style.CROSS if Settings.move_mode() == Settings.MOVE_CROSS
		else TouchStick.Style.ANALOG)
	stick.set_enabled(touch_mode and not Settings.tap_to_move() and _controls_shown())


## Les commandes se rangent derrière la pause, la victoire et les réglages. Elles lisent
## leurs touches sans passer par les nœuds : un sort posé sur « Menu » partait avec lui.
func _controls_shown() -> bool:
	return not result_screen.visible and _settings == null


func _refresh_controls() -> void:
	combat_pad.visible = touch_mode and _controls_shown()
	combat_pad.queue_redraw()
	_apply_control_scheme()


func _place_corner_buttons() -> void:
	_lay_corner(get_viewport().get_visible_rect().size)


func _lay_corner(view: Vector2) -> void:
	combat_pad.size = view
	TouchLayout.fit_corner(combat_pad)
	var right := -TouchLayout.corner_right
	var width := (TouchLayout.CORNER_SIZE.x - 6.0) * 0.5
	for button: Button in [pause_button, quest_button]:
		button.offset_top = TouchLayout.CORNER_SIZE.y - 60.0
		button.offset_bottom = TouchLayout.CORNER_SIZE.y
		button.offset_right = right
		button.offset_left = right - width
		right -= width + 6.0


# --- Écrans ----------------------------------------------------------------------

func show_victory(seconds: float, portals: int, gems: int, kills: int, has_next: bool) -> void:
	# Le dernier stage ne doit pas être un cul-de-sac : le bouton reste, il
	# renvoie simplement au début de l'aventure.
	var subtitle := "Toutes les gemmes, et la maison." if has_next else "Tu as terminé tous les stages."
	var next_text := "Niveau suivant" if has_next else "Rejouer depuis le début"
	# Le niveau gagné se dit ICI. Annoncé à part, il passait sous le voile de la victoire
	# et dans l'invite du bas, au même instant que le titre.
	if _hero_rank_at_start >= 0 and _hero_rank > _hero_rank_at_start:
		subtitle += "   Niveau %d atteint !" % _hero_rank
	_flash_timer = 0.0
	_set_prompt("", Color.WHITE)
	result_screen.show_result("VICTOIRE", subtitle,
		_stats(seconds, portals, gems, gems, kills), Color("#ffd479"), false, true, next_text)


func show_defeat(seconds: float, portals: int, gems: int, kills: int) -> void:
	result_screen.show_result("GAME OVER", "Tu as été rattrapé.",
		_stats(seconds, portals, gems, hud.gem_total, kills), Color("#e05c4a"), false, false)


func show_pause(config: LevelConfig, character: CharacterStats) -> void:
	result_screen.show_result("PAUSE", "%s  —  %s" % [character.display_name, config.level_name],
		_objective(config),
		Color("#9fb4e8"), true, false)


# --- Carnet de quête -------------------------------------------------------------

## Ouvre le carnet sur l'avancement du moment. L'UIManager ne va pas le chercher :
## le GameManager le lui donne, seul à savoir ce que le Level rapporte.
func show_quest(book: QuestBook, gems_taken: int, lairs_left: int, house_open: bool) -> void:
	quest_panel.open(book, gems_taken, lairs_left, house_open)


func hide_quest() -> void:
	quest_panel.hide()


func quest_visible() -> bool:
	return quest_panel.visible


## Le carnet n'a rien à dire hors campagne, et le bouton disparaît avec lui : en
## démo, la « mission » est d'essayer ses sorts, ce que la barre de démo montre
## déjà. Un bouton qui ouvre une page vide apprend à ne plus l'ouvrir.
func set_quest_available(available: bool) -> void:
	quest_button.visible = available
	if not available:
		quest_panel.hide()


func hide_result() -> void:
	hide_settings()
	result_screen.hide()


# --- Interne ---------------------------------------------------------------------

func _show_objective(text: String) -> void:
	if _objective_banner == null:
		_objective_banner = Label.new()
		_objective_banner.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		_objective_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_objective_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_objective_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_objective_banner.add_theme_font_size_override("font_size", 22)
		_objective_banner.add_theme_color_override("font_color", Color("#ffe6a8"))
		_objective_banner.add_theme_color_override("font_outline_color", Color(0.04, 0.05, 0.1, 0.9))
		_objective_banner.add_theme_constant_override("outline_size", 8)
		add_child(_objective_banner)
		move_child(_objective_banner, 0)
	# Sous la barre du mage, au-dessus du héros, et dans la largeur que l'éventail laisse.
	var top := TouchLayout.TOP_LEFT.y + 24.0
	var right := 24.0
	if combat_pad.visible:
		right = combat_pad.reach_from_right(top + OBJECTIVE_HEIGHT) + TouchLayout.GAP
	_objective_banner.offset_left = 24.0
	_objective_banner.offset_right = -right
	_objective_banner.offset_top = top
	_objective_banner.text = text
	_objective_banner.modulate.a = 1.0
	_objective_banner.visible = true
	if _objective_fade != null:
		_objective_fade.kill()
	_objective_fade = create_tween()
	_objective_fade.tween_interval(OBJECTIVE_DURATION)
	_objective_fade.tween_property(_objective_banner, "modulate:a", 0.0, OBJECTIVE_FADE)
	_objective_fade.tween_callback(_objective_banner.hide)


func _objective(config: LevelConfig) -> String:
	var lairs := ", abats les repaires" if config.must_destroy_lairs else ""
	return "Ramasse les %d gemmes%s, puis rentre à la maison." % [config.gem_count, lairs]


func _stats(seconds: float, portals: int, gems: int, total: int, kills: int) -> String:
	return "Temps : %.1f s   ·   Gemmes : %d/%d   ·   Kills : %d   ·   Portails : %d" % [
		seconds, gems, total, kills, portals]


## Nom de la touche d'action, tel que le joueur la voit sur SON support.
func action_key() -> String:
	return "Le bouton" if touch_mode else "[ESPACE]"


func _ultimate_key() -> String:
	return "Le bouton doré" if touch_mode else "[E]"


func escape_key() -> String:
	return "Le bouton du haut" if touch_mode else "[F]"


func _set_prompt(text: String, color: Color) -> void:
	prompt_label.text = text
	prompt_label.add_theme_color_override("font_color", color)


## L'invite du bas se place selon la FORME de l'écran.
##
## En paysage, la croix est à gauche et les boutons de combat à droite : le
## centre du bas est libre, l'invite y reste. En portrait les deux se partagent
## la même bande, et une invite laissée là passerait derrière la touche « haut ».
func _place_prompt() -> void:
	var view := get_viewport().get_visible_rect().size
	if view.x >= view.y:
		prompt_label.offset_top = -104.0
		prompt_label.offset_bottom = -64.0
		return
	prompt_label.offset_top = -(stick.margin.y + stick.radius * 2.4)
	prompt_label.offset_bottom = prompt_label.offset_top + 44.0


func set_hero_progress(progress: HeroProgress, transformation: Transformation = null) -> void:
	hud.set_hero_progress(progress, transformation)
	if progress != null:
		_hero_rank = progress.level()
		if _hero_rank_at_start < 0:
			_hero_rank_at_start = _hero_rank


## Le bouton de la Transformation : visible pour Aël à partir du niveau 30, à droite de la barre du mage.
func set_transform_state(shown: bool, info: Dictionary) -> void:
	if transform_button == null:
		return
	var changed := transform_button.visible != shown
	transform_button.visible = shown
	if not shown:
		if changed:
			_layout_demo()
		return
	transform_button.position = hud.position + Vector2(hud.size.x + 6.0, 0.0)
	transform_button.set_info(info)
	if changed:
		_layout_demo()


func show_demo_hero(on_form: Callable) -> void:
	if hero_demo_picker == null:
		hero_demo_picker = HeroDemoPicker.new()
		add_child(hero_demo_picker)
		hero_demo_picker.form_requested.connect(on_form)
	_layout_demo()

func set_demo_hero_state(form: int, rank: int) -> void:
	if hero_demo_picker != null:
		hero_demo_picker.set_form(form, rank)

## Le bandeau de visite évite le HUD à gauche et la pause à droite, même sur téléphone.
func _layout_demo() -> void:
	if not demo_bar.visible:
		return
	var view := get_viewport().get_visible_rect().size
	var narrow := view.x < 600.0
	var top := hud.position.y + hud.size.y + 30.0
	var width := minf(420.0, view.x - 32.0) if narrow else minf(420.0, view.x - 370.0)
	width = maxf(120.0, width)
	demo_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	# Le bouton de la Transformation tient à droite de la barre du mage : le bandeau se pousse d'autant.
	var beside := 304.0 + (70.0 if transform_button != null and transform_button.visible else 0.0)
	demo_bar.position = Vector2(16.0 if narrow else beside, top + (42.0 if hero_demo_picker != null else 0.0) if narrow else 16.0)
	demo_bar.size = Vector2(width, 44.0)
	var prev := demo_bar.get_node("Prev") as Button
	var next := demo_bar.get_node("Next") as Button
	var label := demo_bar.get_node("Label") as Label
	prev.position = Vector2.ZERO
	prev.size = Vector2(40, 44)
	next.position = Vector2(width - 40.0, 0)
	next.size = Vector2(40, 44)
	label.position = Vector2(44, 4)
	label.size = Vector2(maxf(20.0, width - 88.0), 36)
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var boss := demo_bar.get_node("Boss") as Button
	boss.position = Vector2(maxf(0.0, (width - 160.0) * 0.5), 50)
	boss.size = Vector2(minf(160.0, width), 36)
	if hero_demo_picker != null:
		hero_demo_picker.position = Vector2(16, top)
		hero_demo_picker.size = Vector2(minf(280.0, view.x - 32.0), 36)
