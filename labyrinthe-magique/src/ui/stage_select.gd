class_name StageSelect
extends Control

## Choix du chapitre et de l'épisode.
##
## Dix cartes, cinq par rangée, chacune portant l'illustration de sa planche —
## c'est elle qui dit « voici l'endroit » avant même qu'on lise le nom. Une
## liste de dix libellés aurait tenu en dix lignes, mais un joueur ne se
## souvient pas d'avoir joué « le stage 6 » ; il se souvient des montagnes
## glacées.
##
## La grille est ENTIÈREMENT CALCULÉE, comme l'écran de sélection des mages :
## l'étirement varie du simple au triple entre portrait et paysage, une taille
## de carte constante ne peut pas marcher.
##
## Les stages non atteints restent VISIBLES mais éteints. Les masquer donnerait
## un menu qui change de forme à chaque victoire ; les montrer éteints dessine
## la route qui reste.

signal stage_chosen(stage: int, episode: int)
signal back_requested

const THUMBS := "res://assets/stages/thumbs/"
const COLUMNS := 5
const GAP := 10.0

var progress: Progress = null

var _selected := 1
var _cards: Array[Rect2] = []
var _thumbs: Array[Texture2D] = []
var _grid := Rect2()


func _ready() -> void:
	if progress == null:
		progress = Progress.load_saved()
	for index in range(1, LevelConfig.STAGE_COUNT + 1):
		_thumbs.append(load(THUMBS + "stage_%d.png" % index))
	_selected = clampi(progress.reached_stage + 1, 1, LevelConfig.STAGE_COUNT)

	MenuStyle.apply($Buttons/Episode1Button, Color("#ffd479"), 20)
	MenuStyle.apply($Buttons/Episode2Button, Color("#ffd479"), 20)
	MenuStyle.apply($Buttons/BackButton)
	$Buttons/Episode1Button.pressed.connect(func() -> void: _play(1))
	$Buttons/Episode2Button.pressed.connect(func() -> void: _play(2))
	$Buttons/BackButton.pressed.connect(func() -> void: back_requested.emit())

	resized.connect(_layout)
	_layout()
	_refresh()


func _play(episode: int) -> void:
	if progress.episode_unlocked(_selected, episode):
		stage_chosen.emit(_selected, episode)


func _layout() -> void:
	var margin := 14.0
	var heading: Label = $Heading
	var buttons: HBoxContainer = $Buttons
	heading.position = Vector2(margin, margin * 0.5)
	heading.size = Vector2(size.x - margin * 2.0, 32.0)

	var button_height := 52.0
	buttons.size = Vector2(minf(560.0, size.x - margin * 2.0), button_height)
	buttons.position = Vector2((size.x - buttons.size.x) * 0.5, size.y - button_height - margin)

	var top := heading.position.y + heading.size.y + margin * 0.5
	var bottom := buttons.position.y - margin * 0.8
	_grid = Rect2(margin, top, size.x - margin * 2.0, maxf(80.0, bottom - top))

	# La carte prend toute la hauteur disponible, dans des bornes de format.
	# L'illustration est presque 3:1 ; la carte peut aller jusqu'à 1,6:1 sans
	# jamais l'étirer, parce qu'elle est RECADRÉE au centre et non déformée.
	# Sans cette latitude, dix cartes larges laissaient la moitié de l'écran vide.
	var rows := int(ceil(float(LevelConfig.STAGE_COUNT) / float(COLUMNS)))
	var card_width := (_grid.size.x - GAP * float(COLUMNS - 1)) / float(COLUMNS)
	var card_height := clampf((_grid.size.y - GAP * float(rows - 1)) / float(rows),
		card_width / 2.9, card_width / 1.6)
	var used := Vector2(card_width * COLUMNS + GAP * (COLUMNS - 1),
		card_height * rows + GAP * (rows - 1))
	var origin := _grid.position + (_grid.size - used) * 0.5

	_cards.clear()
	for index in LevelConfig.STAGE_COUNT:
		var column := index % COLUMNS
		var row := index / COLUMNS
		_cards.append(Rect2(
			origin + Vector2(float(column) * (card_width + GAP), float(row) * (card_height + GAP)),
			Vector2(card_width, card_height)))
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var pressed := false
	var at := Vector2.ZERO
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		pressed = mouse.pressed
		at = mouse.position
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		pressed = touch.pressed
		at = touch.position
	if not pressed:
		return
	for index in _cards.size():
		if _cards[index].has_point(at):
			# Une carte éteinte se laisse quand même toucher : elle affiche alors
			# ce qu'il faut faire pour l'ouvrir, au lieu de ne rien répondre.
			_selected = index + 1
			_refresh()
			return


func _refresh() -> void:
	var name: String = LevelConfig.STAGE_NAMES[_selected - 1]
	var open := progress.stage_unlocked(_selected)
	$Heading.text = "STAGE %d  —  %s" % [_selected, name.to_upper()] if open \
		else "STAGE %d  —  VERROUILLÉ" % _selected
	$Hint.text = "" if open else \
		"Termine le stage %d pour ouvrir celui-ci." % maxi(1, progress.reached_stage + 1)
	$Buttons/Episode1Button.disabled = not progress.episode_unlocked(_selected, 1)
	$Buttons/Episode2Button.disabled = not progress.episode_unlocked(_selected, 2)
	queue_redraw()


func _draw() -> void:
	var font := get_theme_default_font()
	for index in _cards.size():
		var stage := index + 1
		var card := _cards[index]
		var open := progress.stage_unlocked(stage)
		var chosen := stage == _selected

		# L'illustration est peinte à la taille de la carte, puis assombrie si
		# le stage est fermé : c'est la même image, éteinte — le joueur voit ce
		# qui l'attend sans croire qu'il peut y aller.
		var tint := Color(1, 1, 1) if open else Color(0.30, 0.30, 0.38)
		draw_texture_rect_region(_thumbs[index], card, _center_crop(_thumbs[index], card.size), tint)
		draw_rect(card, Color(0.02, 0.02, 0.05, 0.0 if open else 0.35))

		var border := Color("#ffd479") if chosen else Color(0.42, 0.50, 0.75, 0.7)
		draw_rect(card, border, false, 3.0 if chosen else 1.5)

		# Bandeau du nom, en bas de la carte : posé À MÊME l'illustration, le
		# texte se perdrait dans les feuillages ou la neige.
		var band := Rect2(card.position + Vector2(0.0, card.size.y - 20.0),
			Vector2(card.size.x, 20.0))
		draw_rect(band, Color(0.03, 0.03, 0.07, 0.78))
		if font != null:
			var label := "%d · %s" % [stage, LevelConfig.STAGE_NAMES[stage - 1]]
			draw_string(font, band.position + Vector2(6.0, 14.0), label,
				HORIZONTAL_ALIGNMENT_LEFT, band.size.x - 10.0, 12,
				Color(1, 1, 1) if open else Color(0.62, 0.62, 0.72))

		if not open and font != null:
			draw_string(font, card.position + Vector2(8.0, 18.0), "✖",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.85, 0.55, 0.55))


## Fenêtre à prendre dans la vignette pour remplir la carte sans la déformer.
##
## Recadrer plutôt qu'étirer : ces illustrations ont toutes leur sujet au
## centre — le temple, le pont, le château. On peut donc leur rogner les bords
## sans rien perdre de ce qui identifie l'endroit, là où un étirement vertical
## se verrait immédiatement.
func _center_crop(texture: Texture2D, target: Vector2) -> Rect2:
	var source := texture.get_size()
	if target.x <= 0.0 or target.y <= 0.0:
		return Rect2(Vector2.ZERO, source)
	var wanted := target.x / target.y
	var size := source
	if source.x / source.y > wanted:
		size.x = source.y * wanted
	else:
		size.y = source.x / wanted
	return Rect2((source - size) * 0.5, size)
