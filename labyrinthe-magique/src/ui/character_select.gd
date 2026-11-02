class_name CharacterSelect
extends Control

## Écran de sélection des personnages, rangés par famille : un onglet Mage, un onglet
## Ange (`CharacterCatalog.CATEGORIES`).
##
## Une rangée de vignettes en haut, la FICHE COMPLÈTE du personnage choisi en
## dessous. Cinq fiches côte à côte tiendraient sur un écran de bureau et sur
## aucun téléphone ; une seule fiche à la fois tient partout, et laisse la place
## d'écrire ce qui compte vraiment : ce que fait chaque sort.

## LA GRILLE DES SORTS — trois colonnes, deux rangées, six cases. Le nombre est
## FIXE et ce n'est pas une limite d'affichage : un mage a toujours exactement
## six créneaux (attaque, trois sorts, fuite, ultime), c'est une règle du jeu.
const GRID_COLUMNS := 3
const GRID_ROWS := 2
## LA RANGÉE DÉFILE, avec un bouton de chaque côté. Rétrécir les cartes pour tout faire
## tenir n'avait plus de sens à dix mages : elles devenaient illisibles sur téléphone.
const ARROW_WIDTH := 48.0
const ARROW_GAP := 8.0
## Le liseré de la carte choisie dépasse de sa case : la fenêtre lui laisse cette marge.
const ROSTER_PAD := 8.0
const SLIDE_TIME := 0.2
const TAB_WIDTH := 92.0
const TAB_GAP := 6.0

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
## LES SIX SORTS EN GRILLE 3 x 2 (maquette du 2026-08-28), et non plus en six
## lignes pleine largeur. La ligne posait le nom à gauche et ses chiffres contre
## le bord droit : le regard traversait l'écran une fois par sort. La grille les
## empile dans une colonne étroite, et les six cartes se comparent d'un coup.
##
## Le conteneur est un `Control` NU, pas un `GridContainer` : c'est nous qui
## calculons la boîte de chaque carte, comme partout ailleurs dans cet écran.
## Un conteneur de Godot répartit à sa façon et se battrait avec `fit()`.
var _grid: Control = null
var _ability_cards: Array[AbilityCard] = []
## Le TRAIT n'est pas un bouton : c'est une propriété du personnage, et il vit
## donc avec sa vie et sa vitesse plutôt qu'au milieu de ses sorts. Rangé parmi
## eux, il se lisait comme un septième sort qu'on cherchait en vain sur la barre.
var _trait_label: Label = null

var character_id := CharacterCatalog.default_id()

var _portraits: Array[CharacterPortrait] = []
## Les cartes de l'onglet ouvert, les seules que la rangée fait défiler.
var _listed: Array[CharacterPortrait] = []
var _category := ""
var _tabs := {}
## Le dernier personnage choisi dans chaque onglet : revenir sur un onglet ne doit pas
## faire perdre le choix qu'on y avait fait.
var _chosen_in := {}
var _selected_preview: CharacterPortrait
## La fenêtre qui coupe la rangée, ses deux boutons, et où en est le défilement.
var _roster_window: Control = null
var _arrow_left: Button = null
var _arrow_right: Button = null
var _first_shown := 0
var _shown := 1
var _card_step := 1.0
var _slide: Tween = null


func _ready() -> void:
	_build_roster_slider()
	for character in CharacterCatalog.roster():
		var portrait := CharacterPortrait.new()
		portrait.custom_minimum_size = Vector2(116.0, 142.0)   # recalculé par _layout
		portrait.mouse_filter = Control.MOUSE_FILTER_STOP
		roster.add_child(portrait)
		portrait.setup(character)
		portrait.gui_input.connect(_on_portrait_input.bind(character.id))
		_portraits.append(portrait)
	_build_tabs()
	_open_category(CharacterCatalog.by_id(character_id).category)

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
	_grid = Control.new()
	_grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Card.add_child(_grid)

	_selected_preview = CharacterPortrait.new()
	_selected_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Card.add_child(_selected_preview)
	resized.connect(_layout)
	_layout()
	select(character_id)


func _build_tabs() -> void:
	var group := ButtonGroup.new()
	for category: String in CharacterCatalog.CATEGORIES:
		var info: Dictionary = CharacterCatalog.CATEGORIES[category]
		var tab := Button.new()
		tab.text = str(info["tab"])
		tab.toggle_mode = true
		tab.button_group = group
		# Le cadre du focus est sombre : dessiné par-dessus, il effacerait l'onglet ouvert.
		tab.focus_mode = Control.FOCUS_NONE
		MenuStyle.apply(tab, info["accent"], 16)
		for state in ["normal", "hover", "pressed", "focus", "disabled"]:
			var box: StyleBoxFlat = tab.get_theme_stylebox(state)
			box.content_margin_top = 2.0
			box.content_margin_bottom = 2.0
		tab.pressed.connect(_on_tab.bind(category))
		add_child(tab)
		_tabs[category] = tab


func _on_tab(category: String) -> void:
	if category == _category:
		return
	_open_category(category)
	var first: CharacterStats = CharacterCatalog.in_category(category)[0]
	select(str(_chosen_in.get(category, first.id)))


## Ne range que la rangée et l'onglet : c'est `select` qui remplit la fiche.
func _open_category(category: String) -> void:
	_category = category
	_listed.clear()
	for portrait in _portraits:
		portrait.visible = portrait.stats.category == category
		if portrait.visible:
			_listed.append(portrait)
	_first_shown = 0
	for key: String in _tabs:
		(_tabs[key] as Button).set_pressed_no_signal(key == category)


func _build_roster_slider() -> void:
	_roster_window = Control.new()
	_roster_window.clip_contents = true
	_roster_window.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_roster_window)
	roster.reparent(_roster_window, false)
	roster.alignment = BoxContainer.ALIGNMENT_BEGIN
	roster.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_arrow_left = _make_arrow("◀", -1)
	_arrow_right = _make_arrow("▶", 1)


func _make_arrow(glyph: String, way: int) -> Button:
	var arrow := Button.new()
	arrow.text = glyph
	MenuStyle.apply(arrow, Color("#ffd479"), 20)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box: StyleBoxFlat = arrow.get_theme_stylebox(state)
		box.content_margin_left = 2.0
		box.content_margin_right = 2.0
	arrow.pressed.connect(_on_arrow.bind(way))
	add_child(arrow)
	return arrow


## Un appui montre les cartes suivantes, en gardant une carte déjà vue comme repère.
func _on_arrow(way: int) -> void:
	_show_from(_first_shown + way * maxi(1, _shown - 1))


func _show_from(first: int, animated: bool = true) -> void:
	_first_shown = clampi(first, 0, maxi(0, _listed.size() - _shown))
	_arrow_left.disabled = _first_shown == 0
	_arrow_right.disabled = _first_shown + _shown >= _listed.size()
	var target := Vector2(ROSTER_PAD - float(_first_shown) * _card_step, ROSTER_PAD)
	if _slide != null:
		_slide.kill()
	if not animated or not is_inside_tree():
		roster.position = target
		return
	_slide = create_tween()
	_slide.tween_property(roster, "position", target, SLIDE_TIME) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## La carte choisie n'est jamais cachée, d'où que vienne la sélection.
func _reveal(id: String) -> void:
	for index in _listed.size():
		if _listed[index].stats.id != id:
			continue
		if index < _first_shown:
			_show_from(index)
		elif index >= _first_shown + _shown:
			_show_from(index - _shown + 1)


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
	if stats.category != _category:
		_open_category(stats.category)
	_chosen_in[stats.category] = id
	_selected_preview.setup(stats)
	_selected_preview.set_selected(true)
	for portrait in _portraits:
		portrait.set_selected(portrait.stats.id == id)

	# Le Héros d'essai n'a qu'une attaque : il ne lance jamais une vraie partie.
	$Buttons/PlayButton.disabled = id == CharacterCatalog.TEST
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
	if stats.ultimate != null:
		slots.append(["EXTRA", stats.ultimate])

	# Les cartes sont RECYCLÉES d'un mage à l'autre : les reconstruire à chaque
	# clic sur une vignette faisait clignoter la fiche entière.
	while _ability_cards.size() < slots.size():
		var card := AbilityCard.new()
		_grid.add_child(card)
		_ability_cards.append(card)
	for i in _ability_cards.size():
		var card: AbilityCard = _ability_cards[i]
		card.visible = i < slots.size()
		if not card.visible:
			continue
		card.fill(str(slots[i][0]), slots[i][1] as Ability, id, stats.color())
		if i == slots.size() - 1 and stats.ultimate != null:
			card.mark_ultimate(stats.ultimate_required_kills)
	_layout()
	_reveal(id)


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
	var heading_height := 40.0
	var button_height := 54.0
	var tab_x := margin
	for key: String in _tabs:
		var tab: Button = _tabs[key]
		tab.position = Vector2(tab_x, margin * 0.6)
		tab.size = Vector2(TAB_WIDTH, heading_height)
		tab_x += TAB_WIDTH + TAB_GAP
	# Le titre reste centré sur l'écran tant qu'il passe à côté des onglets.
	var font := heading.get_theme_font("font")
	var font_size := heading.get_theme_font_size("font_size")
	var title_width := font.get_string_size(heading.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var inset := tab_x + margin
	var title_room := size.x - inset * 2.0
	if title_room < title_width:
		title_room = maxf(0.0, size.x - inset - margin)
	heading.position = Vector2(inset, margin * 0.6)
	heading.size = Vector2(title_room, heading_height)

	var free_height := size.y - heading_height - button_height - margin * 4.0
	# La rangée prend un bon tiers, la fiche le reste : plus bas les vignettes
	# deviennent illisibles, plus haut la fiche ne tient plus.
	var roster_height: float = clampf(free_height * 0.36, 78.0, 168.0)
	# La carte est au rapport 3:4, celui des portraits dessinés. C'était 0,86 du
	# temps où la vignette montrait un sprite carré : le portrait y serait rogné
	# sur les côtés jusqu'à manger les bras.
	var width := roster_height * 0.75
	for portrait in _portraits:
		portrait.custom_minimum_size = Vector2(width, roster_height)
		portrait.size = portrait.custom_minimum_size
	var gap := float(roster.get_theme_constant("separation"))
	var count := _listed.size()
	_card_step = width + gap
	roster.size = Vector2(float(count) * _card_step - gap, roster_height)
	roster.queue_sort()

	var row_y := heading.position.y + heading_height + margin * 0.5
	var room := size.x - margin * 2.0 - (ARROW_WIDTH + ARROW_GAP) * 2.0
	_shown = clampi(int((room + gap) / _card_step), 1, count)
	var slides := _shown < count
	# Tout tient : plus de boutons, et la rangée se centre sur l'écran.
	_arrow_left.visible = slides
	_arrow_right.visible = slides
	var window_width := float(_shown) * _card_step - gap + ROSTER_PAD * 2.0
	_roster_window.position = Vector2((size.x - window_width) * 0.5, row_y - ROSTER_PAD)
	_roster_window.size = Vector2(window_width, roster_height + ROSTER_PAD * 2.0)
	var arrow_size := Vector2(ARROW_WIDTH, roster_height)
	_arrow_left.size = arrow_size
	_arrow_left.position = Vector2(_roster_window.position.x - ARROW_WIDTH - ARROW_GAP + ROSTER_PAD, row_y)
	_arrow_right.size = arrow_size
	_arrow_right.position = Vector2(_roster_window.position.x + window_width + ARROW_GAP - ROSTER_PAD, row_y)
	_show_from(_first_shown, false)

	card.position = Vector2(margin, row_y + roster_height + margin * 0.6)
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
	var y := 6.0

	# L'ÉLÉMENT MONTE SUR LA LIGNE DU NOM, à sa droite. Il tenait une ligne à lui
	# seul pour deux mots et cinq étoiles, et cette ligne-là coûtait vingt-deux
	# unités prises sur la grille des sorts — c'est-à-dire une ligne de
	# description dans chacune des six cartes. Un en-tête ne mérite pas ça.
	name_label.position = Vector2(18.0, y)
	name_label.size = Vector2(inner * 0.58, 30.0)
	name_label.add_theme_font_size_override("font_size", 24)
	element_label.position = Vector2(18.0 + inner * 0.60, y + 8.0)
	element_label.size = Vector2(inner * 0.40, 22.0)
	element_label.add_theme_font_size_override("font_size", 15)
	y += 32.0

	for entry in [[description_label, 18.0 if compact else 22.0, 13],
			[stats_label, 20.0, 13]]:
		var label: Label = entry[0]
		label.position = Vector2(18.0, y)
		label.size = Vector2(inner, float(entry[1]))
		label.add_theme_font_size_override("font_size", int(entry[2]))
		y += float(entry[1]) + 1.0
	description_label.visible = card.size.y > 170.0

	# LE TRAIT tient sur la ligne des caractéristiques : c'est une propriété du
	# personnage, pas un bouton.
	_trait_label.position = Vector2(18.0, y)
	_trait_label.size = Vector2(inner, 18.0)
	_trait_label.add_theme_font_size_override("font_size", 12 if compact else 13)
	y += 21.0

	# LA GRILLE SE CALCULE, elle ne se choisit pas. Trois colonnes, deux rangées,
	# gouttière à 4 % de la largeur disponible — les proportions de la maquette,
	# reportées en POURCENTAGE et non en pixels : la même grille doit tenir dans
	# une fiche de tablette (~1210 x 410) et de téléphone en paysage (~900 x 230).
	#
	# Les six cartes sont TOUJOURS toutes affichées. C'est le sens même de la
	# grille : on ne compare pas huit mages en faisant défiler leurs sorts.
	var room := maxf(60.0, card.size.y - y - 12.0)
	var gutter := clampf(inner * 0.02, 4.0, 16.0)
	var cell := Vector2((inner - gutter * float(GRID_COLUMNS - 1)) / float(GRID_COLUMNS),
		(room - gutter * float(GRID_ROWS - 1)) / float(GRID_ROWS))

	# LE CORPS DU TEXTE SUIT LA CARTE, pas l'écran. Une carte de 180 unités de
	# haut loge treize points ; à 100, il en faut dix, sinon le nom mange à lui
	# seul les deux tiers de la carte et les chiffres passent à la trappe.
	var body := 13 if cell.y >= 150.0 else (12 if cell.y >= 120.0 else
		(11 if cell.y >= 96.0 else 10))
	for i in _ability_cards.size():
		var slot_card: AbilityCard = _ability_cards[i]
		if not slot_card.visible:
			continue
		slot_card.position = Vector2(
			float(i % GRID_COLUMNS) * (cell.x + gutter),
			float(i / GRID_COLUMNS) * (cell.y + gutter))
		slot_card.fit(cell, body)
	_grid.position = Vector2(18.0, y)
	_grid.size = Vector2(inner, room)
