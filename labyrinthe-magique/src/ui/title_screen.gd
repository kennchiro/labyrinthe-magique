class_name TitleScreen
extends Control

## Écran d'accueil : la COUVERTURE en paysage, et trois boutons dessinés par le
## jeu par-dessus.
##
## ⚠️ CE N'ÉTAIT PAS LE CAS AVANT, et le changement vaut d'être expliqué.
## L'ancienne couverture était un PORTRAIT 2:3 dont les trois boutons étaient
## PEINTS dans l'image ; le jeu posait des `Button` transparents dessus, à des
## rectangles relevés à la main. Deux défauts, tous deux mesurés :
##
##   · en paysage — la façon dont ce jeu se joue — l'illustration contenue dans
##     l'écran n'occupait que le TIERS CENTRAL, le reste étant rempli par
##     elle-même agrandie et assombrie. Deux tiers de l'écran pour un flou ;
##   · le texte des boutons était de la peinture. Il ne pouvait ni changer ni
##     rester net quand on l'agrandissait, et chaque nouvelle image obligeait à
##     re-mesurer trois rectangles à la main.
##
## La nouvelle image est en 16:9 et ne contient AUCUN bouton : son tiers
## inférieur central est laissé calme et sombre exprès. Le jeu y pose ses trois
## boutons avec `MenuStyle`, comme tous les autres menus — texte net à toute
## taille, libellés modifiables sans repasser par une image, et plus un seul
## rectangle à relever.

signal start_requested
signal journey_requested
signal select_requested

const COVER := preload("res://assets/peso&cover/interface/couverture_paysage.png")

## Les trois boutons, de haut en bas, avec leur libellé et leur teinte.
const ENTRIES := [
	["StartButton", "JOUER", "#ffd479", 1.0],
	["JourneyButton", "AVENTURE", "#9fe8b4", 0.88],
	["SelectButton", "CHOISIR SON MAGE", "#b9c8ff", 0.88],
]
## Les boutons sont en RANGÉE, tout en bas, et non en colonne au centre.
##
## ⚠️ Le prompt demandait un tiers inférieur calme ; l'illustration livrée met
## ses huit mages sur toute cette hauteur. Une colonne centrée en couvrait
## quatre — et ce sont eux qu'on est venu regarder. Une rangée basse ne mange
## qu'un bandeau, et les huit restent visibles.
const BUTTONS_TOP := 0.845
const BUTTON_HEIGHT := 0.082
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
	for entry in ENTRIES:
		var button: Button = get_node("Buttons/" + str(entry[0]))
		button.text = str(entry[1])
		MenuStyle.apply(button, Color(str(entry[2])), 22)
	$Buttons/StartButton.pressed.connect(func() -> void: start_requested.emit())
	$Buttons/JourneyButton.pressed.connect(func() -> void: journey_requested.emit())
	$Buttons/SelectButton.pressed.connect(func() -> void: select_requested.emit())

	resized.connect(_layout)
	_layout()
	set_character(character_id)


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

	# LES BOUTONS SUIVENT L'IMAGE, pas l'écran : ils se posent dans le bandeau
	# que l'illustration leur laisse, et ils y restent quelle que soit la forme
	# du viewport. Calés sur l'écran, ils remontaient dans les mages dès que le
	# rapport changeait.
	var height := drawn.y * BUTTON_HEIGHT
	var gap := drawn.x * 0.018
	# TROIS BOUTONS DE MÊME LARGEUR. Les dimensionner à leur importance était
	# joli et faux : c'est « CHOISIR SON MAGE », le plus long libellé, qui se
	# retrouvait dans le plus étroit. Une rangée régulière se lit mieux, et rien
	# ne risque de déborder quand un libellé change.
	var span := drawn.x * 0.235
	var widths: Array[float] = []
	for entry in ENTRIES:
		widths.append(span)
	var total: float = span * float(ENTRIES.size()) + gap * float(ENTRIES.size() - 1)
	var x := _cover_rect.position.x + (drawn.x - total) * 0.5
	var top := _cover_rect.position.y + drawn.y * BUTTONS_TOP
	for i in ENTRIES.size():
		var button: Button = get_node("Buttons/" + str(ENTRIES[i][0]))
		button.size = Vector2(widths[i], height)
		button.position = Vector2(x, top)
		button.add_theme_font_size_override("font_size",
			int(clampf(height * 0.36, 11.0, 23.0)))
		x += widths[i] + gap

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
	# VOILE SOUS LA RANGÉE. Les boutons sont translucides pour laisser voir le
	# décor ; posés sur un dallage éclairé par huit auras, ils s'y noyaient. Un
	# dégradé sombre les rattache au bas de l'image sans cacher les mages.
	var band_top := _cover_rect.position.y + _cover_rect.size.y * (BUTTONS_TOP - 0.035)
	var band_height := _cover_rect.size.y * (1.0 - BUTTONS_TOP + 0.035)
	for i in 8:
		var slice := band_height / 8.0
		draw_rect(Rect2(_cover_rect.position.x, band_top + slice * float(i),
			_cover_rect.size.x, slice + 1.0),
			Color(0.02, 0.03, 0.07, 0.10 + 0.07 * float(i)))

	# Bandeau derrière le nom : sur un fond de feuillage, un texte nu ne se lit pas.
	var band := Rect2(character_label.position - Vector2(0.0, 3.0),
		character_label.size + Vector2(0.0, 6.0))
	draw_rect(band, Color(0.03, 0.04, 0.08, 0.72))
	if not debug_hotspots:
		return
	for entry in ENTRIES:
		var button: Button = get_node("Buttons/" + str(entry[0]))
		draw_rect(Rect2(button.position, button.size), Color(0, 1, 0, 0.9), false, 2.0)
