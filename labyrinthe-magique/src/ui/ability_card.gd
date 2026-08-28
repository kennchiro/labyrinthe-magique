class_name AbilityCard
extends Panel

## Une CARTE de la fiche de personnage : un sort, son icône, ses chiffres.
##
## Elle remplace la ligne pleine largeur (`AbilityRow`, supprimée le 2026-08-28)
## et l'écart n'est pas cosmétique. La ligne posait le nom à gauche et ses
## chiffres contre le bord droit, à presque mille pixels de là : sur six sorts,
## ça faisait six allers-retours du regard. Les six cartes forment une grille
## 3 x 2 qu'on embrasse d'un coup d'œil.
##
## DEDANS, la carte est HORIZONTALE : l'icône à gauche sur toute la hauteur, le
## texte à droite, empilé en lignes ferrées à gauche. La première version posait
## l'icône AU-DESSUS du texte, centré ; elle n'y faisait qu'un tiers de la
## hauteur et se lisait comme une vignette de liste. Sur le flanc, elle tient
## toute la carte — c'est elle qu'on retrouvera sur le bouton en jeu, donc c'est
## elle qui doit se graver.
##
## Trois niveaux de lecture, du plus gros au plus fin :
##   · l'ICÔNE, reconnue avant d'être lue ;
##   · le NOM, avec son créneau en petit au-dessus ;
##   · les CHIFFRES, puis la description, qui s'efface la première.
##
## ⚠️ Ce qui dimensionne la carte n'est PAS le nom mais la ligne de chiffres :
## relevée jusqu'à 90 caractères sur la Rune des Ténèbres (« 10 dégâts/s · rayon
## 1.4 · 8 s · 3 charges · recharge 8 s · englue à 18 % tant qu'on y reste »),
## contre 23 pour le plus long des noms. Toute mise en page qui suppose une
## ligne de chiffres courte déborde sur ce mage-là et sur aucun autre.

## Part de la LARGEUR de la carte laissée à l'icône. Le dessin est carré et prend
## toute la hauteur disponible, mais jamais plus que cette part de largeur : au
## delà, la colonne de texte devient si étroite que la ligne de chiffres de la
## Rune passe à cinq lignes et ne tient plus dans la carte.
const ICON_WIDTH := 0.44
## En dessous, le dessin ne dit plus rien : on le retire et le texte prend tout.
const ICON_MIN := 30.0
## ⚠️ L'ICÔNE DÉBORDE DE SA BOÎTE, et ce n'est pas une coquille. Les icônes sont
## découpées pour les boutons RONDS du pad : `build_skill_icons.fitted()` les
## inscrit dans 70 % de leur image pour qu'elles ne sortent pas du cercle. Cadrée
## pile sur sa boîte, l'icône n'en occuperait donc que les deux tiers — c'est ce
## débordement qui lui rend sa taille, ici où aucun cercle ne la coupe.
##
## ⚠️ IL EST BORNÉ, et la carte ROGNE (`clip_contents`). Mesuré à 0,19 : le
## dessin arrivait à un pixel du bord de la carte et paraissait collé au voisin,
## la boîte du `TextureRect` sortant, elle, franchement dehors. Le rognage n'est
## pas la ceinture d'un réglage douteux — c'est ce qui garantit qu'aucune icône
## n'ira jamais s'imprimer sur la carte d'à côté, quel que soit le dessin livré.
const ICON_BLEED := 0.15

var _icon: TextureRect = null
var _slot: Label = null
var _name: Label = null
var _numbers: Label = null
var _detail: Label = null
var _unlock: Label = null

var _tint := Color.WHITE
var _is_ultimate := false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true

	# PAS DE DISQUE SOUS L'ICÔNE, pas de bordure : le dessin seul. La pastille
	# ronde rappelait le bouton du pad tactile, mais sur une icône qui occupe
	# toute la hauteur de la carte elle ne cerclait plus rien — elle rognait le
	# dessin et lui volait le quart de sa surface visible.
	_icon = TextureRect.new()
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon)

	_slot = _make_label(Color(1.0, 1.0, 1.0, 0.78))
	_name = _make_label(Color(0.95, 0.97, 1.0))
	_numbers = _make_label(Color(0.68, 0.76, 0.94))
	_unlock = _make_label(Color("#ffd479"))
	_detail = _make_label(Color(0.60, 0.67, 0.82))


## Les libellés sont ferrés à GAUCHE et empilés en lignes contre l'icône. Ils ont
## été centrés le temps d'une version, quand l'icône se posait au-dessus d'eux :
## centré sous un rond, un texte tient. À DROITE d'une icône il lui faut un bord
## commun, sinon chaque ligne démarre ailleurs et la colonne n'existe plus.
func _make_label(color: Color) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label


func fill(slot: String, ability: Ability, character_id: String, tint: Color) -> void:
	_tint = tint
	_is_ultimate = false
	_slot.text = slot
	_slot.add_theme_color_override("font_color", Color(tint.r, tint.g, tint.b, 0.82))
	_name.text = ability.display_name
	_numbers.text = ability.summary()
	_detail.text = ability.description
	_unlock.text = ""
	_icon.texture = UiIcons.for_ability(character_id, ability.id)
	_restyle()


## L'ULTIME se distingue : c'est le seul sort qui ne s'obtient pas, il se
## MÉRITE. Dans la grille il occupe la dernière case, en bas à droite — la place
## où l'œil finit sa course, et il faut qu'il y trouve autre chose qu'une sixième
## carte identique.
func mark_ultimate(kills: int) -> void:
	_is_ultimate = true
	_slot.add_theme_color_override("font_color", Color("#ffd479"))
	_unlock.text = "Se débloque à %d kills" % kills
	_restyle()


func _restyle() -> void:
	var box := StyleBoxFlat.new()
	if _is_ultimate:
		box.bg_color = Color(1.0, 0.83, 0.47, 0.09)
		box.border_color = Color(1.0, 0.83, 0.47, 0.66)
		box.set_border_width_all(2)
	else:
		box.bg_color = Color(_tint.r, _tint.g, _tint.b, 0.07)
		box.border_color = Color(_tint.r, _tint.g, _tint.b, 0.34)
		box.set_border_width_all(1)
	box.set_corner_radius_all(8)
	add_theme_stylebox_override("panel", box)

	# ⚠️ SANS DISQUE, UN MAGE SANS PLANCHE D'ICÔNES n'a plus rien à gauche de son
	# texte. La pastille colorée tenait aussi ce rôle de repli ; c'est maintenant
	# la teinte de la CARTE elle-même qui le porte, et la colonne de gauche se
	# referme pour rendre sa place au texte au lieu de laisser un trou. Un mage
	# sans icônes ne doit pas se lire comme un mage cassé.
	_icon.visible = _icon.texture != null


## La carte se pose et se dimensionne d'un bloc : le parent lui donne sa boîte,
## elle range son contenu dedans. Rien n'est ancré — la même carte doit tenir
## dans ~370 x 180 sur tablette et dans ~215 x 100 sur un téléphone en paysage.
##
## ⚠️ ELLE NE SE CONTENTE PAS DE POSER, ELLE CHERCHE. Une passe unique qui
## retirait ce qui dépasse a été essayée et jetée : elle effaçait la LIGNE DE
## CHIFFRES de la Rune et de l'Implosion — les deux sorts qui en ont le plus à
## dire — et laissait à la place un blanc au bas de la carte. Un ajustement qui
## sacrifie l'information la plus dense est exactement à l'envers.
##
## On essaie donc les réglages du plus généreux au plus serré, et on garde le
## PREMIER qui loge tout l'obligatoire. L'ORDRE DES SACRIFICES est cette liste,
## et c'est la seule chose qui compte quand la place manque :
##   1. la DESCRIPTION (à quoi sert le sort — précieux, moins pressant) ;
##   2. l'ICÔNE, qui rétrécit puis disparaît ;
##   3. le CORPS du texte, jusqu'à 9 points et pas moins.
## Le créneau, le nom, les chiffres et la ligne de déblocage ne partent JAMAIS :
## ils disent ce que vaut le sort, et c'est ce qui décide du choix d'un mage.
func fit(box: Vector2, body: int) -> void:
	size = box
	var pad := clampf(box.x * 0.04, 4.0, 9.0)

	# L'ordre est celui du commentaire ci-dessus, écrit à la main plutôt qu'en
	# boucles imbriquées : la description part AVANT que l'icône ne rétrécisse,
	# et une carte sans icône ne garde jamais sa description — elle serait alors
	# quatre lignes de texte gris, c'est-à-dire l'ancienne liste dans une case.
	var plans: Array = []
	for font in range(body, 8, -1):
		plans.append([font, ICON_WIDTH, true])
		plans.append([font, ICON_WIDTH, false])
		plans.append([font, ICON_WIDTH * 0.72, false])
		plans.append([font, 0.0, false])

	var chosen: Array = plans[plans.size() - 1]
	for plan in plans:
		var side := _icon_side(box, pad, float(plan[1]))
		if _content_height(_text_width(box, pad, side), int(plan[0]),
				bool(plan[2])) + pad * 2.0 <= box.y:
			chosen = plan
			break
	_apply(box, pad, int(chosen[0]), _icon_side(box, pad, float(chosen[1])),
		bool(chosen[2]))


## Le dessin est CARRÉ et prend toute la hauteur, tant qu'il ne mange pas plus
## que sa part de largeur. C'est la HAUTEUR qui commande — une carte est toujours
## plus large que haute, et une icône réglée sur la largeur déborderait en bas.
func _icon_side(box: Vector2, pad: float, share: float) -> float:
	if share <= 0.0:
		return 0.0
	return minf(box.y - pad * 1.4, box.x * share)


func _text_width(box: Vector2, pad: float, icon_side: float) -> float:
	var used: float = (icon_side + pad) if icon_side >= ICON_MIN else 0.0
	return box.x - pad * 2.0 - used


## Hauteur qu'occuperait le texte avec ce réglage. Les hauteurs sont DEMANDÉES à
## la police, jamais supposées : un nom de vingt caractères passe à la ligne dans
## une colonne étroite, et une hauteur codée en dur ferait chevaucher la ligne
## suivante sur un mage et pas sur les autres.
func _content_height(inner: float, font: int, detail: bool) -> float:
	var total := 0.0
	for entry in _lines(font, detail):
		total += _text_height(entry[0] as Label, inner, int(entry[1])) + 1.0
	return total


## Les libellés dans l'ordre de la carte, avec le corps de chacun. Le créneau et
## la description se lisent en retrait du nom ; les chiffres tiennent le milieu.
func _lines(font: int, detail: bool) -> Array:
	var lines: Array = [[_slot, maxi(8, font - 3)], [_name, font],
		[_numbers, maxi(8, font - 2)], [_unlock, maxi(8, font - 3)]]
	if detail:
		lines.append([_detail, maxi(8, font - 3)])
	return lines


func _text_height(label: Label, inner: float, font: int) -> float:
	if label.text.is_empty() or inner <= 0.0:
		return 0.0
	return label.get_theme_font(&"font").get_multiline_string_size(
		label.text, HORIZONTAL_ALIGNMENT_LEFT, inner, font).y


func _apply(box: Vector2, pad: float, font: int, icon_side: float, detail: bool) -> void:
	_icon.visible = _icon.texture != null and icon_side >= ICON_MIN
	var left := pad
	if _icon.visible:
		# Le débordement est SYMÉTRIQUE et sort de la boîte des deux côtés : le
		# dessin reste centré sur sa place, il ne glisse pas vers un bord.
		var bleed := icon_side * ICON_BLEED
		_icon.position = Vector2(pad - bleed, (box.y - icon_side) * 0.5 - bleed)
		_icon.size = Vector2(icon_side + bleed * 2.0, icon_side + bleed * 2.0)
		left += icon_side + pad

	var inner := box.x - pad - left
	# LE TEXTE EST CENTRÉ VERTICALEMENT contre l'icône. Deux cartes voisines
	# n'ont pas la même quantité de texte — la Rune en a trois fois plus que la
	# Translation — et calé en haut, chacun laisse un blanc de hauteur
	# différente : la grille paraît mal alignée alors que ses six cases sont
	# rigoureusement identiques.
	var y := maxf(pad, (box.y - _content_height(inner, font, detail)) * 0.5)

	_detail.visible = detail
	for entry in _lines(font, detail):
		var label: Label = entry[0]
		var size_pt := int(entry[1])
		label.visible = not label.text.is_empty()
		if not label.visible:
			continue
		label.add_theme_font_size_override("font_size", size_pt)
		var height := _text_height(label, inner, size_pt)
		label.position = Vector2(left, y)
		label.size = Vector2(inner, height)
		y += height + 1.0
