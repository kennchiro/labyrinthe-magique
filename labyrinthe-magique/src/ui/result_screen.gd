class_name ResultScreen
extends Control

## Écran de fin réutilisé pour VICTOIRE, GAME OVER et PAUSE.
## Un seul écran plutôt que trois : ils partagent 90 % de leur structure, et
## l'habillage de l'étape 8 ne sera à faire qu'une fois.

signal resume_requested
signal restart_requested
signal next_requested
signal menu_requested
## Le joueur veut changer de mode de déplacement. L'écran ne sait pas ce que
## c'est : il rapporte le geste, l'UIManager bascule le réglage et le libellé.
signal controls_requested

## Posé par l'UIManager : le choix du mode de déplacement n'a de sens que sur
## écran tactile, au clavier le bouton n'apparaît jamais.
var controls_available := false

@onready var title: Label = $Center/Panel/Title
@onready var subtitle: Label = $Center/Panel/Subtitle
@onready var stats: Label = $Center/Panel/Stats
@onready var resume_button: Button = $Center/Panel/Buttons/ResumeButton
@onready var restart_button: Button = $Center/Panel/Buttons/RestartButton
@onready var next_button: Button = $Center/Panel/Buttons/NextButton
@onready var menu_button: Button = $Center/Panel/Buttons/MenuButton
@onready var controls_button: Button = $Center/Panel/ControlsButton


func _ready() -> void:
	hide()
	resume_button.pressed.connect(func() -> void: resume_requested.emit())
	restart_button.pressed.connect(func() -> void: restart_requested.emit())
	next_button.pressed.connect(func() -> void: next_requested.emit())
	menu_button.pressed.connect(func() -> void: menu_requested.emit())
	controls_button.pressed.connect(func() -> void: controls_requested.emit())


func set_controls_label(text: String) -> void:
	controls_button.text = text


func show_result(title_text: String, subtitle_text: String, stats_text: String,
		color: Color, can_resume: bool, can_continue: bool,
		next_text: String = "Niveau suivant") -> void:
	next_button.text = next_text
	title.text = title_text
	title.add_theme_color_override("font_color", color)
	subtitle.text = subtitle_text
	stats.text = stats_text
	stats.visible = not stats_text.is_empty()
	resume_button.visible = can_resume
	next_button.visible = can_continue
	# Sur la PAUSE seulement : changer de mode de déplacement au milieu d'un
	# écran de victoire n'aurait rien à montrer, le niveau est déjà fini.
	controls_button.visible = can_resume and controls_available
	show()
	# Le bouton par défaut prend le focus : la touche Entrée et la manette
	# fonctionnent alors sans code de navigation supplémentaire.
	if can_resume:
		resume_button.grab_focus()
	elif can_continue:
		next_button.grab_focus()
	else:
		restart_button.grab_focus()
