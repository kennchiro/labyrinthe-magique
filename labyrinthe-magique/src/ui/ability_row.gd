class_name AbilityRow
extends HBoxContainer

## Une ligne de la fiche de personnage : un sort, son icône, ses chiffres.
##
## Elle remplace le bloc de texte aligné à l'espace qui tenait lieu de fiche —
## sept lignes de « SKILL 2   Nom — chiffres » collées les unes aux autres, où
## rien ne se détachait de rien. Ce qui décide du choix d'un mage, c'est ce que
## font ses sorts : il fallait que ça se lise, pas que ça se déchiffre.
##
## Trois niveaux de lecture, et c'est tout le propos :
##   · l'ICÔNE, reconnue avant d'être lue — c'est elle qu'on retrouvera sur le
##     bouton, ce qui fait de cette fiche un apprentissage et pas une notice ;
##   · le NOM dans la couleur de l'élément, et le créneau en petit à côté ;
##   · les CHIFFRES à droite, en retrait, et la description en dessous.
##
## La description s'efface la première quand la place manque : elle dit à quoi
## SERT un sort, ce qui est précieux mais moins pressant que ce qu'il vaut.

## Côté de la pastille, en part de la hauteur de ligne. Elle ne peut pas la
## dépasser : c'est elle qui fixe la hauteur minimale de la ligne, et une
## pastille plus grande faisait déborder la liste hors de la fiche — le dernier
## sort, l'ULTIME, se retrouvait coupé en deux.
const ICON_RATIO := 0.96
## ⚠️ L'ICÔNE DÉBORDE DE SA PASTILLE, et ce n'est pas une coquille. Les icônes
## sont découpées pour les boutons RONDS du pad : `build_skill_icons.fitted()`
## les inscrit dans 70 % de leur image pour qu'elles ne sortent pas du cercle.
## Cadrée pile sur la pastille, l'icône n'en occupait donc que les deux tiers et
## les sorts se lisaient comme de petites taches de couleur. On la laisse mordre
## sur le bord — rien ne la coupe, et le dessin retrouve sa taille.
const ICON_BLEED := 0.15
## En dessous, l'icône ne dit plus rien : mieux vaut alors le texte seul.
const ICON_MIN := 22.0

var _icon: TextureRect = null
## Repli quand un mage n'a pas encore ses icônes : une pastille de sa couleur.
## Un trou à la place de l'image décalerait tout le texte d'une ligne à l'autre.
var _pastille: Panel = null
var _slot: Label = null
var _name: Label = null
var _numbers: Label = null
var _detail: Label = null


func _init() -> void:
	add_theme_constant_override("separation", 10)
	var frame := VBoxContainer.new()
	frame.add_theme_constant_override("separation", 0)
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# LA PASTILLE EST TOUJOURS LÀ, l'icône vient dedans. C'est elle qui tient la
	# colonne de gauche : sans fond, une icône claire et une icône sombre ne
	# commencent pas à la même place à l'œil, et la liste ondule. C'est aussi le
	# rappel du bouton rond qu'on retrouvera en jeu.
	_pastille = Panel.new()
	_pastille.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon = TextureRect.new()
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pastille.add_child(_icon)
	add_child(_pastille)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_slot = Label.new()
	_slot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name = Label.new()
	_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_numbers = Label.new()
	_numbers.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_numbers.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_numbers.add_theme_color_override("font_color", Color(0.66, 0.74, 0.92))
	head.add_child(_slot)
	head.add_child(_name)
	head.add_child(_numbers)

	_detail = Label.new()
	_detail.add_theme_color_override("font_color", Color(0.60, 0.67, 0.82))
	frame.add_child(head)
	frame.add_child(_detail)
	add_child(frame)


func fill(slot: String, ability: Ability, character_id: String, tint: Color) -> void:
	_slot.text = slot
	_slot.add_theme_color_override("font_color", Color(tint.r, tint.g, tint.b, 0.62))
	_name.text = ability.display_name
	_name.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0))
	_numbers.text = ability.summary()
	_detail.text = ability.description

	_icon.texture = UiIcons.for_ability(character_id, ability.id)
	# Sans icône — un mage dont la planche n'est pas encore découpée — la
	# pastille se remplit de sa couleur : la colonne tient quand même.
	var chip := StyleBoxFlat.new()
	chip.bg_color = Color(tint.r, tint.g, tint.b, 0.30 if _icon.texture == null else 0.13)
	chip.border_color = Color(tint.r, tint.g, tint.b, 0.42)
	chip.set_border_width_all(1)
	chip.set_corner_radius_all(64)
	_pastille.add_theme_stylebox_override("panel", chip)


## L'ULTIME se distingue : c'est le seul sort qui ne s'obtient pas, il se
## MÉRITE. Sans marque il se lisait comme un sixième bouton parmi six.
func mark_ultimate(kills: int) -> void:
	_slot.add_theme_color_override("font_color", Color("#ffd479"))
	var crown := StyleBoxFlat.new()
	crown.bg_color = Color(1.0, 0.83, 0.47, 0.16)
	crown.border_color = Color(1.0, 0.83, 0.47, 0.72)
	crown.set_border_width_all(2)
	crown.set_corner_radius_all(64)
	_pastille.add_theme_stylebox_override("panel", crown)
	_numbers.text += "  ·  à %d kills" % kills


## La fiche s'adapte à la place : hauteur de ligne, corps du texte, et la
## description qui s'efface quand il n'y a plus de quoi la loger.
func fit(row_height: float, body: int, detailed: bool) -> void:
	var side := maxf(ICON_MIN, row_height * ICON_RATIO)
	custom_minimum_size = Vector2(0.0, row_height)
	_pastille.custom_minimum_size = Vector2(side, side)
	_pastille.size = _pastille.custom_minimum_size
	var bleed := side * ICON_BLEED
	_icon.offset_left = -bleed
	_icon.offset_top = -bleed
	_icon.offset_right = bleed
	_icon.offset_bottom = bleed
	_slot.custom_minimum_size = Vector2(float(body) * 4.6, 0.0)
	_slot.add_theme_font_size_override("font_size", maxi(9, body - 3))
	_name.add_theme_font_size_override("font_size", body)
	_numbers.add_theme_font_size_override("font_size", maxi(9, body - 2))
	_detail.add_theme_font_size_override("font_size", maxi(9, body - 2))
	_detail.visible = detailed
