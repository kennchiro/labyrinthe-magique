class_name TitleScreen
extends Control

## Écran d'accueil : la COUVERTURE dessinée, avec des zones tactiles posées
## exactement sur ses trois boutons peints.
##
## Pourquoi ne pas redessiner les boutons par-dessus ? Parce que l'illustration
## contient déjà les siens, cadre doré et icône compris. Superposer des boutons
## Godot donnerait deux boutons l'un sur l'autre. On garde donc de vrais Button
## (pour le focus clavier, la manette et l'accessibilité) mais TRANSPARENTS, et
## on les positionne en coordonnées normalisées : ils suivent l'image quelle que
## soit la résolution, en portrait comme en paysage.
##
## L'image est en 2:3. Sur un écran large elle est CONTENUE et non recadrée :
## recadrer sur du 16/9 couperait le haut et le bas, donc le titre et les trois
## boutons — c'est-à-dire tout l'écran.

signal start_requested
signal journey_requested
signal select_requested

const COVER := preload("res://assets/peso&cover/interface/couverture.png")

## Rectangles des boutons peints, en fraction de l'image (x0, y0, x1, y1).
const HOTSPOTS := {
	"StartButton": Rect2(0.242, 0.7075, 0.531, 0.0515),
	"JourneyButton": Rect2(0.242, 0.7985, 0.531, 0.0515),
	"SelectButton": Rect2(0.242, 0.8745, 0.531, 0.0515),
}
## Teinte des bords, quand l'image ne remplit pas l'écran.
const LETTERBOX := Color(0.035, 0.045, 0.085)

@onready var character_label: Label = $CharacterLabel

var character_id := CharacterCatalog.default_id()
## Trace les zones tactiles : `--debug` en ligne de commande.
var debug_hotspots := false

var _cover_rect := Rect2()
## Version « couvrante » de la même image, pour habiller les bords.
var _fill_rect := Rect2()


func _ready() -> void:
	debug_hotspots = "--debug" in OS.get_cmdline_user_args()
	for name in HOTSPOTS:
		var button: Button = get_node("Buttons/" + name)
		_make_transparent(button)
	$Buttons/StartButton.pressed.connect(func() -> void: start_requested.emit())
	$Buttons/JourneyButton.pressed.connect(func() -> void: journey_requested.emit())
	$Buttons/SelectButton.pressed.connect(func() -> void: select_requested.emit())

	resized.connect(_layout)
	_layout()
	set_character(character_id)


## Le bouton existe pour le clavier et la manette, pas pour être vu : c'est
## l'illustration qui le dessine. On garde seulement un voile au survol, sinon
## rien ne répondrait au doigt ni à la souris.
func _make_transparent(button: Button) -> void:
	var empty := StyleBoxEmpty.new()
	for state in ["normal", "disabled"]:
		button.add_theme_stylebox_override(state, empty)
	for state in ["hover", "pressed", "focus"]:
		var veil := StyleBoxFlat.new()
		veil.bg_color = Color(1, 1, 1, 0.10 if state == "hover" else 0.18)
		veil.set_corner_radius_all(8)
		button.add_theme_stylebox_override(state, veil)
	button.text = ""


func set_character(id: String) -> void:
	character_id = id
	var chosen := CharacterCatalog.by_id(id)
	character_label.text = "%s  ·  %s" % [chosen.display_name, Element.label(chosen.element)]
	character_label.add_theme_color_override("font_color", chosen.color())
	queue_redraw()


## Place l'image et les zones tactiles. Tout part du rectangle réellement occupé
## par la couverture : c'est lui qui bouge quand l'écran change de forme.
func _layout() -> void:
	var texture_size := Vector2(COVER.get_width(), COVER.get_height())
	var scale_factor: float = minf(size.x / texture_size.x, size.y / texture_size.y)
	var drawn := texture_size * scale_factor
	_cover_rect = Rect2((size - drawn) * 0.5, drawn)
	var cover_factor: float = maxf(size.x / texture_size.x, size.y / texture_size.y)
	var filled := texture_size * cover_factor
	_fill_rect = Rect2((size - filled) * 0.5, filled)

	for name in HOTSPOTS:
		var spot: Rect2 = HOTSPOTS[name]
		var button: Button = get_node("Buttons/" + name)
		button.position = _cover_rect.position + Vector2(spot.position.x, spot.position.y) * drawn
		button.size = Vector2(spot.size.x, spot.size.y) * drawn

	# Le nom du personnage courant se pose TOUT EN BAS, sur un bandeau sombre.
	# Les cinq mages sont déjà peints au milieu de l'illustration : y superposer
	# des vignettes ferait doublon et masquerait le dessin.
	var label_height: float = clampf(drawn.y * 0.028, 18.0, 34.0)
	character_label.position = Vector2(_cover_rect.position.x,
		_cover_rect.position.y + drawn.y * 0.958 - label_height * 0.5)
	character_label.size = Vector2(drawn.x, label_height)
	character_label.add_theme_font_size_override("font_size", int(label_height * 0.62))
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), LETTERBOX)
	# En paysage, l'illustration (2:3) ne couvre qu'un tiers de l'écran. Plutôt
	# que deux bandes noires, on remplit avec la couverture elle-même, agrandie
	# pour couvrir et fortement assombrie : l'œil lit un décor continu.
	if _fill_rect.size.x > _cover_rect.size.x + 1.0:
		draw_texture_rect(COVER, _fill_rect, false, Color(0.30, 0.32, 0.42, 1.0))
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.04, 0.09, 0.55))
	draw_texture_rect(COVER, _cover_rect, false)
	# Bandeau derrière le nom : sur un fond de feuillage, un texte nu ne se lit pas.
	var band := Rect2(character_label.position - Vector2(0.0, 3.0),
		character_label.size + Vector2(0.0, 6.0))
	draw_rect(band, Color(0.03, 0.04, 0.08, 0.72))
	if not debug_hotspots:
		return
	for name in HOTSPOTS:
		var button: Button = get_node("Buttons/" + name)
		draw_rect(Rect2(button.position, button.size), Color(0, 1, 0, 0.9), false, 2.0)
