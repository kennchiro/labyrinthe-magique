class_name CharacterPortrait
extends Control

## La carte d'un personnage dans l'écran de sélection : son portrait, son cadre,
## sa gemme d'élément.
##
## POURQUOI CE N'EST PLUS LE SPRITE DE JEU
##
## La vignette affichait la première pose de marche de face, prise dans la
## planche du mage. C'était le choix évident, et il était mauvais : ce sprite est
## dessiné VU DE DESSUS pour un jeu vu de dessus, on n'y voit donc pas le visage.
## Haut de 112 pixels dans une case de 142, il occupait un tiers de la surface et
## flottait au milieu d'une boîte vide. Aucun réglage de taille n'y pouvait rien
## — c'est le point de vue qui était faux, pas l'échelle.
##
## LE PARTAGE ENTRE LE DESSIN ET LE CODE
##
##   dessiné, un par mage  : le portrait, avec sa nappe de couleur élémentaire
##   dessiné, UNE FOIS     : le cadre, commun aux huit
##   tracé par le code     : la gemme, la lueur de sélection, et le nom
##
## Le cadre est unique et c'est délibéré : huit cadres dessinés séparément
## n'auraient jamais eu la même épaisseur ni la même gemme, et les huit cartes
## sont côte à côte à l'écran, là où le moindre écart se voit. Le nom reste du
## TEXTE (dessiné par CharacterSelect) : il doit rester lisible à toute taille,
## et il changerait de langue avant l'image.
##
## Un mage sans portrait garde l'ancien rendu — le sprite dans sa boîte. Rien
## n'oblige à fournir les huit planches d'un coup.

const CHARACTERS_PATH := "res://assets/characters/"
const PORTRAITS_PATH := "res://assets/ui/portraits/"
const FRAME_PATH := "res://assets/ui/portraits/"

var stats: CharacterStats = null
var selected := false

var _portrait: Texture2D = null
var _frame: Texture2D = null
## Fenêtre et sertissage du cadre, en FRACTIONS de la carte. Mesurés par
## `tools/build_menu.py` sur la planche même : selon l'épaisseur que le dessin
## donne à la bordure, le portrait doit se poser plus haut ou plus bas, et deux
## constantes écrites ici deviendraient fausses au premier cadre redessiné.
var _window := Rect2(0.13, 0.12, 0.73, 0.78)
var _socket := Rect2(0.44, 0.05, 0.12, 0.09)
var _has_socket := false

## Repli : le sprite de jeu, quand le mage n'a pas encore de portrait.
var _sprite: Texture2D = null
var _cell := Vector2(128.0, 112.0)
var _time := 0.0


func setup(p_stats: CharacterStats) -> void:
	stats = p_stats
	_portrait = null
	var portrait_path := PORTRAITS_PATH + "portrait_" + stats.visual_id() + ".jpg"
	if not ResourceLoader.exists(portrait_path):
		portrait_path = PORTRAITS_PATH + "portrait_" + stats.id + ".jpg"
	if ResourceLoader.exists(portrait_path):
		_portrait = load(portrait_path)
	var frame_path := FRAME_PATH + "cadre_carte.png"
	if ResourceLoader.exists(frame_path):
		_frame = load(frame_path)
		_read_frame_meta()
	if _portrait == null:
		_load_sprite()
	queue_redraw()


func _read_frame_meta() -> void:
	var text := FileAccess.get_file_as_string(FRAME_PATH + "cadre.json")
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		return
	var data: Dictionary = parsed
	if data.has("window"):
		var w: Array = data["window"]
		_window = Rect2(float(w[0]), float(w[1]), float(w[2]), float(w[3]))
	if data.has("socket"):
		var s: Array = data["socket"]
		_socket = Rect2(float(s[0]), float(s[1]), float(s[2]), float(s[3]))
		_has_socket = true


func _load_sprite() -> void:
	_sprite = load(CHARACTERS_PATH + stats.id + "/down.png")
	var text := FileAccess.get_file_as_string(CHARACTERS_PATH + stats.id + "/frames.json")
	var parsed: Variant = JSON.parse_string(text)
	if parsed != null:
		var cell: Array = (parsed as Dictionary)["cell"]
		_cell = Vector2(float(cell[0]), float(cell[1]))


func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if selected:
		queue_redraw()


func _draw() -> void:
	if stats == null:
		return
	if _portrait != null and _frame != null:
		_draw_card()
	else:
		_draw_fallback()


func _draw_card() -> void:
	var color := stats.color()
	var pulse := 0.5 + 0.5 * sin(_time * 2.4)
	var rect := Rect2(Vector2.ZERO, size)
	var window := Rect2(_window.position * size, _window.size * size)

	# Le portrait REMPLIT la fenêtre plutôt que d'y tenir en entier : la fenêtre
	# est un peu plus étroite que le dessin, et le laisser tenir en entier
	# laisserait deux bandes de vide sur les côtés. On rogne donc les côtés, où
	# il n'y a que la nappe de couleur — jamais le haut ni le bas, où sont la
	# tête et les pieds.
	var texture_size := Vector2(_portrait.get_size())
	var cover := maxf(window.size.x / texture_size.x, window.size.y / texture_size.y)
	var shown := window.size / cover
	draw_texture_rect_region(_portrait, window,
		Rect2((texture_size - shown) * 0.5, shown),
		Color.WHITE if selected else Color(0.66, 0.68, 0.78))

	# La GEMME derrière le cadre : son sertissage est un trou, l'anneau doré
	# repasse donc par-dessus et la sertit vraiment.
	if _has_socket:
		var socket := Rect2(_socket.position * size, _socket.size * size)
		var centre := socket.position + socket.size * 0.5
		var radius := minf(socket.size.x, socket.size.y) * 0.52
		draw_circle(centre, radius, color)
		draw_circle(centre, radius * 0.55, Color(1, 1, 1, 0.55))

	# LA CARTE CHOISIE DOIT SE VOIR DE LOIN. Trois indices qui se cumulent, parce
	# qu'un seul ne suffisait pas : huit cartes également lumineuses côte à côte,
	# on ne repérait pas celle qui était prise.
	if selected:
		# 1. un halo qui DÉBORDE, dessiné avec le cadre lui-même agrandi. Un halo
		#    rectangulaire ferait un carré lumineux là où la carte a des coins
		#    arrondis et un fleuron qui dépasse en haut.
		var spread := size * (0.05 + 0.015 * pulse)
		draw_texture_rect(_frame, Rect2(-spread, size + spread * 2.0), false,
			Color(color.r, color.g, color.b, 0.55))
	# 2. les cartes NON choisies reculent : plus sombres et légèrement désaturées.
	#    C'est le contraste entre elles qui désigne, pas la luminosité absolue.
	draw_texture_rect(_frame, rect, false,
		Color(1.3, 1.3, 1.3) if selected else Color(0.62, 0.62, 0.70))
	if selected:
		# 3. la couleur de l'élément repasse sur le cadre, qu'elle suit.
		draw_texture_rect(_frame, rect, false,
			Color(color.r, color.g, color.b, 0.32 + 0.20 * pulse))


func _draw_fallback() -> void:
	if _sprite == null:
		return
	var color := stats.color()
	var centre := size * 0.5
	var pulse := 0.5 + 0.5 * sin(_time * 2.4)

	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.07, 0.13, 0.85))
	if selected:
		draw_rect(Rect2(Vector2.ZERO, size), Color(color.r, color.g, color.b, 0.14 + 0.06 * pulse))
		draw_circle(centre, size.x * (0.52 + 0.05 * pulse), Color(color.r, color.g, color.b, 0.11))

	var target := size.y * 0.80
	var factor := target / _cell.y
	var drawn := _cell * factor
	draw_texture_rect_region(_sprite,
		Rect2(centre - Vector2(drawn.x * 0.5, drawn.y * 0.56), drawn),
		Rect2(Vector2.ZERO, _cell))

	var edge := color if selected else Color(0.32, 0.38, 0.52)
	draw_rect(Rect2(Vector2.ZERO, size), edge, false, 3.0 if selected else 1.5)
