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
## Les lignes de sorts, construites en code : leur nombre change d'un mage à
## l'autre, et chacune porte une icône, deux libellés et une description.
var _rows: VBoxContainer = null
var _ability_rows: Array[AbilityRow] = []
## Le TRAIT n'est pas un bouton : c'est une propriété du personnage, et il vit
## donc avec sa vie et sa vitesse plutôt qu'au milieu de ses sorts. Rangé parmi
## eux, il se lisait comme un septième sort qu'on cherchait en vain sur la barre.
var _trait_label: Label = null

var character_id := CharacterCatalog.default_id()

var _portraits: Array[CharacterPortrait] = []
var _selected_preview: CharacterPortrait


func _ready() -> void:
	for character in CharacterCatalog.all():
		var portrait := CharacterPortrait.new()
		portrait.custom_minimum_size = Vector2(116.0, 142.0)   # recalculé par _layout
		portrait.mouse_filter = Control.MOUSE_FILTER_STOP
		roster.add_child(portrait)
		portrait.setup(character)
		portrait.gui_input.connect(_on_portrait_input.bind(character.id))
		_portraits.append(portrait)

	# La fiche laisse voir le décor derrière elle. Opaque, elle posait une dalle
	# grise sur les deux tiers de l'écran et le fond peint ne servait plus à rien.
	var sheet := StyleBoxFlat.new()
	sheet.bg_color = Color(0.04, 0.05, 0.10, 0.74)
	sheet.border_color = Color(0.45, 0.52, 0.72, 0.55)
	sheet.set_border_width_all(1)
	sheet.set_corner_radius_all(10)
	sheet.set_content_margin_all(4)
	$Card.add_theme_stylebox_override("panel", sheet)

	MenuStyle.apply($Buttons/PlayButton, Color("#ffd479"), 22)
	MenuStyle.apply($Buttons/DemoButton, Color("#9fe8b4"), 20)
	MenuStyle.apply($Buttons/BackButton)
	$Buttons/PlayButton.pressed.connect(func() -> void: play_requested.emit(character_id))
	$Buttons/DemoButton.pressed.connect(func() -> void: demo_requested.emit(character_id))
	$Buttons/BackButton.pressed.connect(func() -> void: back_requested.emit())
	_trait_label = Label.new()
	_trait_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	$Card.add_child(_trait_label)
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 2)
	_rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Card.add_child(_rows)

	_selected_preview = CharacterPortrait.new()
	_selected_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Card.add_child(_selected_preview)
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


## Hauteur disponible dans la fiche, mesurée au dernier calcul de mise en page.
## La fiche s'enrichit quand il y a la place et se resserre sinon — même règle
## que pour le reste de cet écran.
var card_room := 0.0


func select(id: String) -> void:
	character_id = id
	var stats := CharacterCatalog.by_id(id)
	_selected_preview.setup(stats)
	_selected_preview.set_selected(true)
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

	_trait_label.text = "%s — %s" % [Element.trait_name(stats.element),
		Element.trait_hint(stats.element)]
	_trait_label.add_theme_color_override("font_color",
		Color(stats.color().r, stats.color().g, stats.color().b, 0.9))

	# LA FICHE COMPLÈTE, une ligne par bouton de la barre d'action — attaque,
	# les trois sorts, la fuite, l'ultime. Il manquait la FUITE dans la première
	# version, pourtant l'un des six boutons.
	var slots: Array = [["ATTAQUE", stats.attack]]
	for i in stats.abilities.size():
		slots.append(["SORT %d" % (i + 1), stats.abilities[i]])
	if stats.escape != null:
		slots.append(["FUITE", stats.escape])
	slots.append(["EXTRA", stats.ultimate])

	# Les lignes sont RECYCLÉES d'un mage à l'autre : les reconstruire à chaque
	# clic sur une vignette faisait clignoter la fiche entière.
	while _ability_rows.size() < slots.size():
		var row := AbilityRow.new()
		_rows.add_child(row)
		_ability_rows.append(row)
	for i in _ability_rows.size():
		var row: AbilityRow = _ability_rows[i]
		row.visible = i < slots.size()
		if not row.visible:
			continue
		row.fill(str(slots[i][0]), slots[i][1] as Ability, id, stats.color())
		if i == slots.size() - 1:
			row.mark_ultimate(stats.ultimate_required_kills)
	_layout()


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
	# La carte est au rapport 3:4, celui des portraits dessinés. C'était 0,86 du
	# temps où la vignette montrait un sprite carré : le portrait y serait rogné
	# sur les côtés jusqu'à manger les bras.
	# Et le partage se fait sur le NOMBRE DE MAGES, pas sur sept en dur — il y en
	# a huit depuis l'Invocateur, et la rangée débordait d'une vignette.
	var count := maxf(1.0, float(_portraits.size()))
	var width: float = clampf(
		(size.x - margin * 2.0 - 6.0 * (count - 1.0)) / count, 48.0, roster_height * 0.75)
	for portrait in _portraits:
		portrait.custom_minimum_size = Vector2(width, roster_height)
		portrait.size = portrait.custom_minimum_size
	roster.position = Vector2(margin, heading.position.y + heading_height + margin * 0.5)
	roster.size = Vector2(size.x - margin * 2.0, roster_height)
	roster.queue_sort()

	card.position = Vector2(margin, roster.position.y + roster_height + margin * 0.6)
	card.size = Vector2(size.x - margin * 2.0,
		maxf(120.0, size.y - card.position.y - button_height - margin * 2.0))
	card_room = card.size.y
	_layout_card(card)

	buttons.size = Vector2(minf(560.0, size.x - margin * 2.0), button_height)
	buttons.position = Vector2((size.x - buttons.size.x) * 0.5, size.y - button_height - margin)


## Les libellés suivent la hauteur de la fiche : sur un écran court, la
## description se retire pour laisser la place aux compétences, qui sont
## l'information qui décide du choix.
func _layout_card(card: Panel) -> void:
	var preview_width := clampf(card.size.x * 0.24, 78.0, 230.0)
	var preview_gap := 14.0
	var inner := card.size.x - 36.0 - preview_width - preview_gap
	_selected_preview.position = Vector2(card.size.x - preview_width - 18.0, 14.0)
	_selected_preview.size = Vector2(preview_width, maxf(80.0, card.size.y - 28.0))
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

	# LE TRAIT tient sur la ligne des caractéristiques : c'est une propriété du
	# personnage, pas un bouton.
	_trait_label.position = Vector2(18.0, y)
	_trait_label.size = Vector2(inner, 20.0)
	_trait_label.add_theme_font_size_override("font_size", 12 if compact else 13)
	y += 24.0

	# LA HAUTEUR DE LIGNE SE CALCULE, elle ne se choisit pas. Six sorts dans une
	# fiche de téléphone en paysage n'ont pas la place d'en dire autant que dans
	# une fiche de bureau : on répartit ce qu'il y a, et la DESCRIPTION est ce
	# qui s'efface en premier — elle dit à quoi sert un sort, ce qui est précieux
	# mais moins pressant que ce qu'il vaut.
	var visible_rows := 0
	for row in _ability_rows:
		if row.visible:
			visible_rows += 1
	var room := maxf(48.0, card.size.y - y - 12.0)
	var line := room / maxf(1.0, float(visible_rows))
	var detailed := line >= 34.0
	var body := 13 if line >= 30.0 else (12 if line >= 24.0 else 11)
	for row in _ability_rows:
		row.fit(clampf(line, 18.0, 46.0), body, detailed)
	_rows.position = Vector2(18.0, y)
	_rows.size = Vector2(inner, room)
