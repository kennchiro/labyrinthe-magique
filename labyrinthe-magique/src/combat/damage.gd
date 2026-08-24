class_name Damage
extends RefCounted

## Un coup porté : combien, de quel élément, par qui.
##
## Un simple entier aurait suffi pour retirer des points de vie — mais pas pour
## afficher la bonne couleur de dégâts, ni pour qu'un futur ennemi résiste au feu.
## L'information voyage donc avec le coup, pas à côté.

var amount: int
var element: Element.Kind
## "player" ou "enemy" : sert à savoir qui a tué quoi, et donc à compter les kills.
var source: String


func _init(p_amount: int, p_element: Element.Kind = Element.Kind.SHADOW,
		p_source: String = "player") -> void:
	amount = maxi(0, p_amount)
	element = p_element
	source = p_source
