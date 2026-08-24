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
## Slot demandé : -1 pour le portail, 0 l'attaque, 1 à 3 les sorts, 4 l'ultime.
signal action_requested(slot: int)

## Durée d'affichage d'un message ponctuel avant retour à l'invite normale.
const FLASH_DURATION := 1.4

@onready var hud: HUD = $HUD
@onready var prompt_label: Label = $PromptLabel
@onready var stick: TouchStick = $TouchStick
@onready var combat_pad: CombatPad = $CombatPad
@onready var action_bar: ActionBar = $ActionBar
@onready var pause_button: Button = $PauseButton
@onready var result_screen: ResultScreen = $ResultScreen
@onready var debug_label: Label = $DebugLabel

var touch_mode := false

var _flash_timer := 0.0


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
	result_screen.controls_available = touch_mode
	_apply_control_scheme()
	if touch_mode:
		Platform.apply_ui_scale(get_window())
		_place_prompt()
		get_viewport().size_changed.connect(_place_prompt)

	combat_pad.action_requested.connect(func(slot: int) -> void: action_requested.emit(slot))
	pause_button.pressed.connect(func() -> void: pause_requested.emit())
	result_screen.resume_requested.connect(func() -> void: resume_requested.emit())
	result_screen.restart_requested.connect(func() -> void: restart_requested.emit())
	result_screen.next_requested.connect(func() -> void: next_requested.emit())
	result_screen.menu_requested.connect(func() -> void: menu_requested.emit())
	result_screen.controls_requested.connect(_on_controls_toggled)


func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta


# --- Bandeau ---------------------------------------------------------------------

func set_character(stats: CharacterStats) -> void:
	hud.set_character(stats)


func set_level(config: LevelConfig, number: int) -> void:
	hud.set_level(config, number)
	_flash_timer = 0.0
	prompt_label.text = ""


func set_health(current: int, maximum: int) -> void:
	hud.set_health(current, maximum)


func set_counters(portals: int, unlocked_skills: int) -> void:
	hud.set_counters(portals, unlocked_skills)


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


func flash(text: String, color: Color) -> void:
	_set_prompt(text, color)
	_flash_timer = FLASH_DURATION


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
	return false


func _on_controls_toggled() -> void:
	Settings.set_tap_to_move(not Settings.tap_to_move())
	_apply_control_scheme()


## Applique le mode de déplacement choisi : le manche ne s'affiche qu'en mode
## analogique, et le bouton d'options dit toujours le mode COURANT.
func _apply_control_scheme() -> void:
	stick.set_enabled(touch_mode and not Settings.tap_to_move())
	result_screen.set_controls_label("Déplacement : Toucher le chemin"
		if Settings.tap_to_move() else "Déplacement : Manche analogique")


# --- Écrans ----------------------------------------------------------------------

func show_victory(seconds: float, portals: int, gems: int, kills: int, has_next: bool) -> void:
	# Le dernier stage ne doit pas être un cul-de-sac : le bouton reste, il
	# renvoie simplement au début de l'aventure.
	var subtitle := "Toutes les gemmes, et la maison." if has_next else "Tu as terminé tous les stages."
	var next_text := "Niveau suivant" if has_next else "Rejouer depuis le début"
	result_screen.show_result("VICTOIRE", subtitle,
		_stats(seconds, portals, gems, gems, kills), Color("#ffd479"), false, true, next_text)


func show_defeat(seconds: float, portals: int, gems: int, kills: int) -> void:
	result_screen.show_result("GAME OVER", "Tu as été rattrapé.",
		_stats(seconds, portals, gems, hud.gem_total, kills), Color("#e05c4a"), false, false)


func show_pause(config: LevelConfig, character: CharacterStats) -> void:
	result_screen.show_result("PAUSE", "%s  —  %s" % [character.display_name, config.level_name],
		"Ramasse les %d gemmes pour ouvrir la porte." % config.gem_count,
		Color("#9fb4e8"), true, false)


func hide_result() -> void:
	result_screen.hide()


# --- Interne ---------------------------------------------------------------------

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
