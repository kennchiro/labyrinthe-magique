class_name CharacterSelect
extends Control

## Écran de sélection des sept mages.
##
## Une rangée de vignettes en haut, la FICHE COMPLÈTE du personnage choisi en
## dessous. Cinq fiches côte à côte tiendraient sur un écran de bureau et sur
## aucun téléphone ; une seule fiche à la fois tient partout, et laisse la place
## d'écrire ce qui compte vraiment : ce que fait chaque sort.

signal play_requested(character_id: String)
## Le terrain d'essai : mêmes sorts, rien d'enjeu. C'est ici qu'un joueur
## découvre ce que fait « Ébranlement » avant de choisir pour de bon.
signal demo_requested(character_id: String)
signal back_requested

@onready var roster: HBoxContainer = $Roster
@onready var name_label: Label = $Card/Name
@onready var element_label: Label = $Card/Element
@onready var description_label: Label = $Card/Description
@onready var stats_label: Label = $Card/Stats
@onready var abilities_label: Label = $Card/Abilities

var character_id := CharacterCatalog.default_id()

var _portraits: Array[CharacterPortrait] = []


func _ready() -> void:
	for character in CharacterCatalog.all():
		var portrait := CharacterPortrait.new()
		portrait.custom_minimum_size = Vector2(116.0, 142.0)   # recalculé par _layout
		portrait.mouse_filter = Control.MOUSE_FILTER_STOP
		roster.add_child(portrait)
		portrait.setup(character)
		portrait.gui_input.connect(_on_portrait_input.bind(character.id))
		_portraits.append(portrait)

	MenuStyle.apply($Buttons/PlayButton, Color("#ffd479"), 22)
	MenuStyle.apply($Buttons/DemoButton, Color("#9fe8b4"), 20)
	MenuStyle.apply($Buttons/BackButton)
	$Buttons/PlayButton.pressed.connect(func() -> void: play_requested.emit(character_id))
	$Buttons/DemoButton.pressed.connect(func() -> void: demo_requested.emit(character_id))
	$Buttons/BackButton.pressed.connect(func() -> void: back_requested.emit())
	resized.connect(_layout)
	_layout()
	select(character_id)


func _on_portrait_input(event: InputEvent, id: String) -> void:
	# Souris ET tactile : la sélection doit répondre au doigt comme au clic, et
	# `event.pressed` n'existe pas sur la classe de base InputEvent.
	var tapped := false
	if event is InputEventMouseButton:
		tapped = (event as InputEventMouseButton).pressed
	elif event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	if tapped:
		select(id)


func select(id: String) -> void:
	character_id = id
	var stats := CharacterCatalog.by_id(id)
	for portrait in _portraits:
		portrait.set_selected(portrait.stats.id == id)

	name_label.text = stats.display_name
	name_label.add_theme_color_override("font_color", stats.color())
	# Les étoiles disent la puissance d'un coup d'œil, là où « 4 » demanderait
	# de savoir sur combien.
	element_label.text = "%s   %s" % [
		Element.label(stats.element), "★".repeat(stats.power_level) + "☆".repeat(5 - stats.power_level)]
	element_label.add_theme_color_override("font_color", stats.color())
	description_label.text = stats.description

	stats_label.text = "Vie %d   ·   Vitesse %.1f   ·   Extra Power à %d kills" % [
		stats.base_health, stats.move_speed, stats.ultimate_required_kills]

	var lines: Array[String] = []
	# Le trait d'abord : c'est LE critère qui distingue les sept mages, les
	# chiffres des sorts ne viennent qu'ensuite.
	lines.append("TRAIT     %s — %s" % [Element.trait_name(stats.element),
		Element.trait_hint(stats.element)])
	lines.append("ATTAQUE   %s — %s" % [stats.attack.display_name, stats.attack.summary()])
	for i in stats.abilities.size():
		var ability: Ability = stats.abilities[i]
		lines.append("SKILL %d   %s — %s" % [i + 1, ability.display_name, ability.summary()])
	lines.append("EXTRA     %s — %s" % [stats.ultimate.display_name, stats.ultimate.summary()])
	abilities_label.text = "\n".join(lines)


## Les cinq vignettes doivent tenir sur la largeur DISPONIBLE. En portrait sur
## téléphone, une rangée dimensionnée pour un écran de bureau sort de l'écran :
## la cinquième vignette disparaît et la fiche se fait couper des deux côtés.
## Mise en page CALCULÉE, jamais ancrée en dur.
##
## En paysage sur téléphone, le viewport ne fait que ~450 unités de haut : une
## fiche posée à des offsets pensés pour un écran vertical passait sous les
## boutons, et la moitié des compétences se lisait à travers « JOUER ».
## On répartit donc la hauteur DISPONIBLE : titre, rangée, fiche, boutons.
func _layout() -> void:
	var heading: Label = $Heading
	var card: Panel = $Card
	var buttons: HBoxContainer = $Buttons

	var margin := 14.0
	var heading_height := 34.0
	var button_height := 54.0
	heading.position = Vector2(margin, margin * 0.6)
	heading.size = Vector2(size.x - margin * 2.0, heading_height)

	var free_height := size.y - heading_height - button_height - margin * 4.0
	# La rangée prend un bon tiers, la fiche le reste : plus bas les vignettes
	# deviennent illisibles, plus haut la fiche ne tient plus.
	var roster_height: float = clampf(free_height * 0.36, 78.0, 168.0)
	var width: float = clampf((size.x - margin * 2.0 - 6.0 * 8.0) / 7.0, 48.0, roster_height * 0.86)
	for portrait in _portraits:
		portrait.custom_minimum_size = Vector2(width, roster_height)
		portrait.size = portrait.custom_minimum_size
	roster.position = Vector2(margin, heading.position.y + heading_height + margin * 0.5)
	roster.size = Vector2(size.x - margin * 2.0, roster_height)

	card.position = Vector2(margin, roster.position.y + roster_height + margin * 0.6)
	card.size = Vector2(size.x - margin * 2.0,
		maxf(120.0, size.y - card.position.y - button_height - margin * 2.0))
	_layout_card(card)

	buttons.size = Vector2(minf(560.0, size.x - margin * 2.0), button_height)
	buttons.position = Vector2((size.x - buttons.size.x) * 0.5, size.y - button_height - margin)


## Les libellés suivent la hauteur de la fiche : sur un écran court, la
## description se retire pour laisser la place aux compétences, qui sont
## l'information qui décide du choix.
func _layout_card(card: Panel) -> void:
	var inner := card.size.x - 36.0
	var compact := card.size.y < 210.0
	var y := 8.0
	for entry in [[name_label, 30.0, 24], [element_label, 22.0, 15],
			[description_label, 20.0 if compact else 34.0, 13],
			[stats_label, 22.0, 13]]:
		var label: Label = entry[0]
		label.position = Vector2(18.0, y)
		label.size = Vector2(inner, float(entry[1]))
		label.add_theme_font_size_override("font_size", int(entry[2]))
		y += float(entry[1]) + 2.0
	description_label.visible = card.size.y > 170.0
	abilities_label.position = Vector2(18.0, y + 2.0)
	abilities_label.size = Vector2(inner, maxf(60.0, card.size.y - y - 12.0))
	abilities_label.add_theme_font_size_override("font_size", 12 if compact else 13)
