class_name Element
extends RefCounted

## Les quatre éléments, plus la maîtrise des quatre.
##
## Un seul endroit décide de la couleur et du nom d'un élément : l'interface, les
## effets et les projectiles la lisent ici. Sans ça, le rouge du Mage de Feu finit
## par exister en cinq nuances différentes dans cinq fichiers.

enum Kind { FIRE, WATER, EARTH, SHADOW, THUNDER, AIR, SUPREME, TIME, POISON, LIGHT, DEATH, STARS, STEEL, BLOOD, CHARM, EMBER, BLADE, COLDFIRE, SKY }

const COLORS := {
	Kind.FIRE: Color("#ff6a2a"),
	Kind.WATER: Color("#37c6ff"),
	Kind.EARTH: Color("#7bc043"),
	Kind.SHADOW: Color("#b06cff"),
	Kind.THUNDER: Color("#ffd93a"),
	Kind.AIR: Color("#cfe9ff"),
	Kind.SUPREME: Color("#ffd36a"),
	Kind.TIME: Color("#2fd6b8"),
	Kind.POISON: Color("#b4f02a"),
	Kind.LIGHT: Color("#fff1b8"),
	Kind.DEATH: Color("#e2382a"),
	Kind.STARS: Color("#9db8ff"),
	Kind.STEEL: Color("#a9b6c6"),
	Kind.BLOOD: Color("#c8143c"),
	Kind.CHARM: Color("#e8308f"),
	Kind.EMBER: Color("#ff9a1f"),
	Kind.BLADE: Color("#fff6ee"),
	Kind.COLDFIRE: Color("#16e0e8"),
	Kind.SKY: Color("#34e07a"),
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
	Kind.POISON: "Poison",
	Kind.LIGHT: "Lumière",
	Kind.DEATH: "Mort",
	Kind.STARS: "Étoiles",
	Kind.STEEL: "Acier",
	Kind.BLOOD: "Sang",
	Kind.CHARM: "Envoûtement",
	Kind.EMBER: "Braise",
	Kind.BLADE: "Lame",
	Kind.COLDFIRE: "Flamme froide",
	Kind.SKY: "Ciel",
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
		Kind.POISON: return "Venin"
		Kind.LIGHT: return "Éblouissement"
		Kind.DEATH: return "Sentence"
		Kind.STARS: return "Astre"
		Kind.STEEL: return "Plaques"
		Kind.BLOOD: return "Rage"
		Kind.CHARM: return "Trouble"
		Kind.EMBER: return "Armure vivante"
		Kind.BLADE: return "Entailles"
		Kind.COLDFIRE: return "Entraves"
		Kind.SKY: return "Vue d'en haut"
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
		Kind.POISON: return "chaque coup ajoute une dose de poison, jusqu'à 3"
		Kind.LIGHT: return "de temps en temps, la cible aveuglée perd sa trace"
		Kind.DEATH: return "un ennemi presque mort est achevé d'un coup"
		Kind.STARS: return "chaque coup pose une étoile sur la cible ; à la troisième, elles explosent"
		Kind.STEEL: return "ses plaques encaissent les coups à la place de ses PV, et ses kills les reforgent"
		Kind.BLOOD: return "moins il lui reste de PV, plus ses coups sont forts"
		Kind.CHARM: return "trois murmures troublent la cible : elle ralentit, et sa possession dure plus longtemps"
		Kind.EMBER: return "ses pièces encaissent les coups et blessent autour d'elles ; plus il en a lancé, plus il court vite"
		Kind.BLADE: return "ses coups laissent des entailles, qui éclatent toutes quand il rengaine"
		Kind.COLDFIRE: return "au troisième poing sur le même ennemi, une entrave le cloue au sol"
		Kind.SKY: return "ses coups visés tombent du ciel : leur portée se mesure à vol d'oiseau, par-dessus les haies"
	return ""


static func label(kind: Kind) -> String:
	return NAMES.get(kind, "?")
