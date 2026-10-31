class_name QuestPanel
extends Control

## Le CARNET ouvert : l'ordre du chapitre, les objectifs et leur avancement.
##
## Tout ce qu'il affiche vient de `QuestBook`, qui le déduit de `LevelConfig` —
## le panneau ne calcule rien et n'invente rien. Il ne fait que MONTRER, comme
## le veut la règle des trois couches : le `Level` rapporte des faits, le
## `GameManager` décide ce qu'ils veulent dire, l'interface affiche.
##
## ⚠️ Il est construit EN CODE et non en scène. Les objectifs sont en nombre
## variable — deux la plupart du temps, trois sur les deux épisodes à repaires —
## et un `.tscn` aurait dû prévoir des nœuds cachés qu'on n'aurait jamais vus,
## donc jamais vérifiés. Même raison que pour les lignes de sorts de la fiche.

signal close_requested

## Largeur du carnet, en part de l'écran, et ses bornes. Il ne prend pas tout
## l'écran : c'est un objet qu'on ouvre PAR-DESSUS le jeu, et voir le labyrinthe
## derrière rappelle qu'on y est toujours.
## Largeurs essayées, en part de l'écran, de la plus discrète à la plus large.
##
## ⚠️ LA PAGE S'ÉLARGIT AVANT DE RAPETISSER SON TEXTE, et c'est ce qui la sauve
## sur téléphone. Ce qui manque là-bas n'est pas la largeur mais la HAUTEUR :
## mesuré à 960 x 450 en tactile, il ne reste que 240 unités sous le bouton du
## carnet. Élargir de 46 % à 70 % de l'écran retire deux lignes de repli à
## chaque paragraphe et ne coûte qu'un peu du labyrinthe qu'on voit derrière —
## rapetisser le texte, ça, coûte au joueur.
const WIDTH_RATIOS := [0.46, 0.58, 0.70]
const WIDTH_MIN := 320.0
const WIDTH_MAX := 620.0
## Marge intérieure de la page, en pixels. Constante et non calculée : elle sert
## dans `open()` avant toute mise en page, donc avant qu'on sache quoi que ce
## soit de la taille finale.
const PADDING := 20.0
## Là où la page commence sous le bouton qui l'ouvre, et où elle doit s'arrêter
## pour ne pas couvrir le pad de combat en bas à droite.
const TOP_MARGIN := 86.0
const BOTTOM_MARGIN := 22.0

const GOLD := Color("#ffd479")
const PARCHMENT := Color(0.93, 0.90, 0.82)

var _scrim: ColorRect = null
var _sheet: Panel = null
var _title: Label = null
var _order: Label = null
var _goals: Control = null
var _footer: Label = null
var _close: Button = null
var _goal_rows: Array[Label] = []
## Corps nominal de chaque libellé, celui d'un grand écran. `_font()` en dérive
## les tailles réduites : sans cette mémoire, réduire deux fois de suite
## réduirait à partir de la valeur déjà réduite.
var _nominal := {}


func _ready() -> void:
	# La page reste vivante alors que l'arbre est en pause : c'est justement
	# quand le jeu est figé qu'elle se met en page et s'affiche.
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	# LE VOILE ARRÊTE LES CLICS, et c'est sa vraie fonction — l'assombrissement
	# n'est que le signe visible. Sans lui, un tap à côté du carnet passerait au
	# labyrinthe et ferait marcher le mage derrière une page ouverte.
	_scrim = ColorRect.new()
	_scrim.color = Color(0.02, 0.03, 0.07, 0.62)
	_scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_scrim)

	_sheet = Panel.new()
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.05, 0.06, 0.12, 0.96)
	box.border_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.62)
	box.set_border_width_all(2)
	box.set_corner_radius_all(10)
	_sheet.add_theme_stylebox_override("panel", box)
	add_child(_sheet)

	_title = _label(GOLD, 22)
	_order = _label(PARCHMENT, 15)
	_goals = Control.new()
	_goals.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sheet.add_child(_goals)
	_footer = _label(Color(0.62, 0.69, 0.85), 13)

	_close = Button.new()
	_close.text = "Fermer"
	_close.focus_mode = Control.FOCUS_NONE
	MenuStyle.apply(_close, GOLD, 17)
	_close.pressed.connect(func() -> void: close_requested.emit())
	_sheet.add_child(_close)

	get_viewport().size_changed.connect(_layout)


func _label(color: Color, size: int) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", size)
	_sheet.add_child(label)
	_nominal[label] = size
	return label


## Le panneau reçoit un carnet DÉJÀ rempli et l'avancement du moment. Il ne
## garde pas de référence au niveau : rouvert plus tard, il sera rerempli.
func open(book: QuestBook, gems_taken: int, lairs_left: int, house_open: bool) -> void:
	_title.text = book.title()
	_order.text = book.order()

	for row in _goal_rows:
		row.queue_free()
	_goal_rows.clear()
	for goal in book.objectives(gems_taken, lairs_left, house_open):
		var row := Label.new()
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_font_size_override("font_size", 15)
		_nominal[row] = 15
		# La CASE COCHÉE est un caractère, pas une image : elle doit rester
		# lisible à toute taille et survivre à une traduction. Un objectif fait
		# passe en doré et garde sa ligne — l'effacer volerait au joueur la seule
		# preuve qu'il avance.
		var mark: String = "☑" if bool(goal["done"]) else "☐"
		var tail: String = "" if str(goal["progress"]).is_empty() else "   %s" % goal["progress"]
		row.text = "%s  %s%s" % [mark, str(goal["text"]), tail]
		row.add_theme_color_override("font_color",
			GOLD if bool(goal["done"]) else PARCHMENT)
		_goals.add_child(row)
		_goal_rows.append(row)

	var footer := PackedStringArray()
	var novelty := book.novelty()
	if not novelty.is_empty():
		footer.append("Nouveau dans ce chapitre : %s." % ", ".join(novelty))
	var provisions := book.provisions()
	if not provisions.is_empty():
		footer.append(provisions)
	_footer.text = "\n".join(footer)
	_footer.visible = not _footer.text.is_empty()

	show()
	_layout()


## Largeur de la page pour cette part d'écran, bornée : sous WIDTH_MIN elle
## replierait chaque ligne en accordéon, au-delà de WIDTH_MAX elle couvrirait le
## labyrinthe sur un écran de bureau.
func _width_of(screen: Vector2, ratio: float) -> float:
	return clampf(screen.x * ratio, WIDTH_MIN, WIDTH_MAX)


## Mise en page CALCULÉE, comme partout ailleurs : la même page doit tenir sur
## une tablette et sur un téléphone en paysage de 450 unités de haut.
##
## ⚠️ ELLE CHERCHE SON RÉGLAGE au lieu de poser puis déborder. Mesuré à
## 960 x 450, chapitre 9 épisode 2 — le chapitre le plus bavard, dix gemmes et
## deux repaires : la page posée au corps nominal descendait sous l'écran et
## emportait le troisième objectif, les provisions ET le bouton « Fermer ». Une
## page dont on ne peut plus sortir est pire qu'une page tronquée.
##
## L'ORDRE DES SACRIFICES, du premier au dernier :
##   1. le CORPS du texte, jusqu'aux deux tiers de sa taille ;
##   2. les PROVISIONS et la nouveauté du chapitre — de l'agrément ;
##   3. l'ORDRE lui-même, l'ambiance : elle plante le décor, elle ne dit pas
##      quoi faire.
## Les OBJECTIFS et le bouton de fermeture ne partent jamais : ce sont les deux
## seules choses pour lesquelles on ouvre le carnet.
const SCALES := [1.0, 0.86, 0.74, 0.66]

func _layout() -> void:
	if not visible:
		return
	var screen := size
	var pad := PADDING
	# Le carnet ne descend jamais sur le pad de combat, en bas à droite.
	var room := screen.y - TOP_MARGIN - BOTTOM_MARGIN

	var width := _width_of(screen, float(WIDTH_RATIOS[WIDTH_RATIOS.size() - 1]))
	var scale := float(SCALES[SCALES.size() - 1])
	var with_order := false
	var with_footer := false
	# ⚠️ LE CONTENU EST LA BOUCLE EXTÉRIEURE, LE CORPS L'INTÉRIEURE, et l'inverse
	# a été essayé et jeté : il jetait l'ordre de mission à pleine taille de
	# texte, alors qu'un ordre en petit vaut mieux que pas d'ordre. On épuise
	# donc toutes les tailles avant de retirer quoi que ce soit.
	var found := false
	for plan in [[true, true], [true, false], [false, false]]:
		for step in SCALES:
			for ratio in WIDTH_RATIOS:
				var candidate := _width_of(screen, float(ratio))
				if _height_of(candidate - pad * 2.0, float(step),
						bool(plan[0]), bool(plan[1])) <= room:
					width = candidate
					scale = float(step)
					with_order = bool(plan[0])
					with_footer = bool(plan[1])
					found = true
					break
			if found:
				break
		if found:
			break
	var inner := width - pad * 2.0

	_order.visible = with_order
	_footer.visible = with_footer and not _footer.text.is_empty()
	var y := pad
	y += _place(_title, pad, y, inner, _font(_title, scale)) + 10.0
	if _order.visible:
		y += _place(_order, pad, y, inner, _font(_order, scale)) + 14.0

	_goals.position = Vector2(pad, y)
	var goals_height := 0.0
	for row in _goal_rows:
		goals_height += _place(row, 0.0, goals_height, inner, _font(row, scale)) + 6.0
	_goals.size = Vector2(inner, goals_height)
	y += goals_height + 8.0

	if _footer.visible:
		y += _place(_footer, pad, y, inner, _font(_footer, scale)) + 14.0

	_close.size = Vector2(minf(180.0, inner), maxf(38.0, 44.0 * scale))
	_close.position = Vector2(width - pad - _close.size.x, y)
	y += _close.size.y + pad

	# LE CARNET EST COLLÉ À DROITE, sous le bouton qui l'ouvre : c'est de là
	# qu'il sort, et une page qui s'ouvrirait au centre perdrait ce lien.
	_sheet.size = Vector2(width, y)
	_sheet.position = Vector2(screen.x - width - 18.0,
		clampf(TOP_MARGIN, 12.0, maxf(12.0, screen.y - y - 12.0)))


## Hauteur totale de la page pour un réglage donné, sans rien poser. Mesurer
## avant de placer est ce qui permet d'essayer plusieurs réglages sans que
## l'écran ne voie les essais.
func _height_of(inner: float, scale: float, with_order: bool, with_footer: bool) -> float:
	var total := PADDING * 2.0
	total += _text_height(_title, inner, _font(_title, scale)) + 10.0
	if with_order:
		total += _text_height(_order, inner, _font(_order, scale)) + 14.0
	for row in _goal_rows:
		total += _text_height(row, inner, _font(row, scale)) + 6.0
	total += 8.0
	if with_footer and not _footer.text.is_empty():
		total += _text_height(_footer, inner, _font(_footer, scale)) + 14.0
	return total + maxf(38.0, 44.0 * scale)


## Le corps d'un libellé à cette échelle. La taille nominale est celle posée à
## la création : on la réduit, on ne la réinvente pas — sinon deux endroits
## décideraient de la même chose.
func _font(label: Label, scale: float) -> int:
	return maxi(9, int(round(float(_nominal.get(label, 15)) * scale)))


## Pose un libellé et rend LA HAUTEUR QU'IL OCCUPE VRAIMENT.
##
## ⚠️ ON NE RELIT JAMAIS `label.size.y` APRÈS COUP, et c'est tout le piège. Un
## `Label` en repli automatique calcule sa taille MINIMALE d'après la largeur
## qu'il a DÉJÀ — zéro pour une ligne qu'on vient de créer — et la garde en cache
## jusqu'à l'image suivante ; `Control` refuse ensuite toute taille inférieure.
## Une ligne d'objectif se voyait ainsi imposer 722 pixels de haut, la hauteur
## qu'elle ferait à un caractère par ligne. Elle S'AFFICHAIT correctement (le
## texte se dessine en haut de sa boîte, le reste est vide), mais la mise en page
## avançait de 722 : les deux objectifs suivants et le bouton « Fermer »
## partaient sous l'écran, et la page paraissait tronquée.
##
## La police, elle, ne s'est jamais trompée. On se sert donc de SA mesure pour
## avancer, et la taille du libellé n'est plus qu'une boîte de dessin.
func _place(label: Label, x: float, y: float, inner: float, font: int) -> float:
	label.add_theme_font_size_override("font_size", font)
	var height := _text_height(label, inner, font)
	label.position = Vector2(x, y)
	label.size = Vector2(inner, height)
	return height


func _text_height(label: Label, inner: float, font: int) -> float:
	if label.text.is_empty() or inner <= 0.0:
		return 0.0
	return label.get_theme_font(&"font").get_multiline_string_size(
		label.text, HORIZONTAL_ALIGNMENT_LEFT, inner, font).y
