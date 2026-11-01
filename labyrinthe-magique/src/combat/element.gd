class_name Element
extends RefCounted

## Les quatre éléments, plus la maîtrise des quatre.
##
## Un seul endroit décide de la couleur et du nom d'un élément : l'interface, les
## effets et les projectiles la lisent ici. Sans ça, le rouge du Mage de Feu finit
## par exister en cinq nuances différentes dans cinq fichiers.

enum Kind { FIRE, WATER, EARTH, SHADOW, THUNDER, AIR, SUPREME, TIME }

const COLORS := {
	Kind.FIRE: Color("#ff6a2a"),
	Kind.WATER: Color("#37c6ff"),
	Kind.EARTH: Color("#7bc043"),
	Kind.SHADOW: Color("#b06cff"),
	Kind.THUNDER: Color("#ffd93a"),
	Kind.AIR: Color("#cfe9ff"),
	Kind.SUPREME: Color("#ffd36a"),
	Kind.TIME: Color("#2fd6b8"),
}
const NAMES := {
	Kind.FIRE: "Feu",
	Kind.WATER: "Eau",
	Kind.EARTH: "Terre",
	Kind.SHADOW: "Ténèbres",
	Kind.THUNDER: "Foudre",
	Kind.AIR: "Air",
	Kind.SUPREME: "Suprême",
	Kind.TIME: "Temps",
}


static func color(kind: Kind) -> Color:
	return COLORS.get(kind, Color.WHITE)


## Le TRAIT de l'élément : ce que chaque coup du mage inflige en plus.
## Nom et phrase courte — l'écran de sélection les affiche, parce que c'est LE
## critère qui distingue les sept mages depuis que chaque élément marque ses
## coups. Les chiffres exacts vivent dans CombatSystem.
static func trait_name(kind: Kind) -> String:
	match kind:
		Kind.FIRE: return "Brûlure"
		Kind.WATER: return "Trempe"
		Kind.EARTH: return "Ébranlement"
		Kind.SHADOW: return "Ponction"
		Kind.THUNDER: return "Arc"
		Kind.AIR: return "Bourrasque"
		Kind.SUPREME: return "Écho"
		Kind.TIME: return "Retard"
	return ""


static func trait_hint(kind: Kind) -> String:
	match kind:
		Kind.FIRE: return "la cible brûle encore après le coup"
		Kind.WATER: return "la cible ralentit, trempée"
		Kind.EARTH: return "la cible s'arrête net un instant"
		Kind.SHADOW: return "le mage reprend un point de vie, de loin en loin"
		Kind.THUNDER: return "le coup saute à l'ennemi voisin"
		Kind.AIR: return "la cible est soufflée en arrière"
		Kind.SUPREME: return "le coup se répète en écho"
		Kind.TIME: return "la cible ralentit un court instant"
	return ""


static func label(kind: Kind) -> String:
	return NAMES.get(kind, "?")
