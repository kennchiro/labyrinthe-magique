class_name Bestiary
extends RefCounted

## Les onze créatures du jeu, et ce qui les distingue.
##
## Aucune dépendance au moteur de scène : la simulation d'équilibrage compose
## les mêmes rosters que le jeu, avec les mêmes points de vie.
##
## Les planches sont dans `assets/enemies/<id>/`, découpées par
## `tools/build_bestiary.py` (et, pour le gobelin et le spectre, par
## `tools/build_characters.py`). Ce fichier ne dit RIEN de leur apparence : il
## dit ce qu'elles valent.
##
## Les valeurs sont des RAPPORTS, pas des absolus. Le spectre est l'unité — c'est
## sur lui que tout l'équilibrage a été mesuré, et `LevelConfig.hunter_health`
## reste la référence dont tout le reste se déduit. Un gobelin à 1,37 rend
## exactement les 185 PV mesurés au stage 2 pour 135 de base : le bestiaire
## n'a donc RIEN changé aux deux premiers stages.
##
## Les compétences sont DEVINÉES DU DESSIN, faute d'une fiche : un golem de
## pierre encaisse et traîne, un serpent file et casse, un minotaure charge.
## C'est la lecture qu'un joueur fera de la silhouette ; s'en écarter donnerait
## des monstres qui mentent sur ce qu'ils sont.

## `body` : hauteur du corps à l'écran, en pixels du monde. C'est elle qui fixe la taille
## de la créature ; `height` ne sert plus qu'à convertir sa foulée en cases.
##
## `stride` : cases couvertes par un CYCLE DE MARCHE complet.
##
## Il remplace `walk_fps` pour tout ce qui a des jambes — voir `Enemy`. Réglé sur
## la stature : un gobelin trottine à 1,7 case par cycle, un golem en couvre 2,8
## d'un pas. Les créatures qui FLOTTENT ou RAMPENT n'en ont pas et gardent leur
## cadence en secondes : une ondulation ne doit rien à la distance.
const SPECIES := {
	"hunter": {
		"name": "Spectre", "toughness": 1.00, "swiftness": 1.00, "height": 52.0, "body": 41.0,
		"walk_fps": 3.2, "strike": 0.60, "repos": 0.55, "windup": 0.32, "hover": true,
		"trait": "lévite lentement, charge son coup à bout de bras",
	},
	"goblin": {
		"name": "Gobelin", "toughness": 1.37, "swiftness": 1.00, "height": 50.0, "body": 39.5,
		"stride": 1.7, "walk_fps": 8.0, "strike": 0.22, "repos": 0.28, "windup": 0.18,
		"trait": "petit, coriace, frappe vite et souvent",
	},
	"serpent": {
		"name": "Serpent d'Émeraude", "toughness": 0.82, "swiftness": 1.16, "height": 46.0, "body": 38.8,
		"walk_fps": 7.0, "strike": 0.30, "repos": 0.30, "windup": 0.18,
		"trait": "file dans les couloirs, mais se brise au premier sort",
	},
	"ombre": {
		"name": "Ombre Encapuchonnée", "toughness": 1.10, "swiftness": 1.12, "height": 52.0, "body": 46.5,
		"walk_fps": 4.0, "strike": 0.45, "repos": 0.40, "windup": 0.24, "hover": true,
		"trait": "glisse sans bruit, rattrape en ligne droite",
	},
	"dragonnet": {
		"name": "Dragonnet de Feu", "toughness": 1.20, "swiftness": 1.14, "height": 50.0, "body": 42.5,
		"walk_fps": 6.0, "strike": 0.35, "repos": 0.35, "windup": 0.20,
		"trait": "vole, donc ne ralentit jamais dans les virages",
	},
	"golem": {
		"name": "Golem de Lave", "toughness": 1.90, "swiftness": 0.80, "height": 58.0, "body": 48.7,
		"stride": 2.8, "walk_fps": 4.5, "strike": 0.50, "repos": 0.55, "windup": 0.30,
		# LE SEUL DU BESTIAIRE QUI FRAPPE DE LOIN.
		#
		# Six cases, et en LIGNE DROITE seulement : il jette sa boule de lave
		# dans un couloir, pas à travers une haie. C'est ce qui en fait une
		# menace qu'on peut fuir — il suffit de sortir de l'axe — plutôt qu'une
		# taxe qu'on paie en traversant son stage.
		#
		# Il vise la case où le mage se TROUVE au moment du jet, jamais où il
		# sera : la boule est donc esquivable, et l'esquive est le seul geste
		# que ce monstre demande d'apprendre.
		"throw_range": 6, "throw_reload": 2.1,
		"trait": "une masse : on ne le sème pas, on l'use — et il jette de loin",
	},
	"archer": {
		"name": "Archer d'Os", "toughness": 1.05, "swiftness": 1.00, "height": 50.0, "body": 44.8,
		"stride": 2.0, "walk_fps": 6.5, "strike": 0.40, "repos": 0.34,
		# LE TIREUR PUR. Quatre cases en ligne droite, moins que la boule du Golem
		# de Lave : il faut qu'il s'approche, et qu'on puisse lui courir dessus.
		#
		# 2,2 s entre deux flèches : c'est cet intervalle qui ouvre la fenêtre pour
		# le charger. Il s'arrête dès qu'il a sa ligne et ne frappe jamais au
		# contact, sinon ses coups passeraient à côté de cet intervalle.
		"throw_range": 4, "throw_reload": 2.2, "arrow": true, "ranged_only": true,
		"trait": "tire à quatre cases en ligne droite, puis recharge",
	},
	"cristal": {
		"name": "Démon de Cristal", "toughness": 1.70, "swiftness": 0.86, "height": 56.0, "body": 50.7,
		"stride": 2.6, "walk_fps": 4.5, "strike": 0.45, "repos": 0.50, "windup": 0.28,
		"trait": "blindé de cristal, lourd à déplacer",
	},
	"minotaure": {
		"name": "Minotaure", "toughness": 1.60, "swiftness": 1.10, "height": 58.0, "body": 47.5,
		"stride": 2.6, "walk_fps": 7.0, "strike": 0.30, "repos": 0.36, "windup": 0.22, "impact_pose": 6,
		"trait": "charge : robuste ET rapide, la pire combinaison",
	},
	"chevalier": {
		"name": "Chevalier Noir", "toughness": 1.45, "swiftness": 1.02, "height": 54.0, "body": 50.4,
		"stride": 2.2, "walk_fps": 6.0, "strike": 0.34, "repos": 0.38, "windup": 0.22,
		"trait": "bouclier et lame, sans faiblesse marquée",
	},
	"givre": {
		"name": "Golem de Givre", "toughness": 2.00, "swiftness": 0.78, "height": 58.0, "body": 50.6,
		"stride": 2.8, "walk_fps": 4.2, "strike": 0.52, "repos": 0.58, "windup": 0.32, "impact_pose": 6,
		# LA RAFALE DE CRISTAUX : quatre cases devant lui, pas six.
		#
		# Moins loin que la boule du Golem de Lave, et c'est voulu : elle ne
		# frappe pas UNE case mais TOUTES celles du couloir devant lui. Reculer
		# ne sauve pas — il faut sortir de l'axe. À six cases, ce serait un
		# couloir entier interdit ; à quatre, c'est une menace qu'on lit.
		#
		# Elle court de case en case au lieu de tomber d'un coup : le joueur voit
		# les pointes venir vers lui, et celui qui est au bout a le temps de
		# s'écarter. C'est ce qui la rend juste.
		"throw_range": 4, "throw_reload": 2.2, "sweep": true,
		"trait": "le plus dur du bestiaire, et le plus lent",
	},
}

## Ce que chaque stage AJOUTE au bestiaire déjà rencontré.
##
## Le roster est CUMULATIF : le stage 7 contient encore le spectre du stage 1.
## C'est ce qui fait sentir la progression — non pas « d'autres ennemis » mais
## « les mêmes, plus quelque chose de neuf ».
const NEWCOMERS := [
	["hunter"],                  # stage 1
	["goblin"],                  # stage 2
	["serpent"],                 # stage 3
	["ombre"],                   # stage 4
	["dragonnet"],               # stage 5
	["golem"],                   # stage 6
	["archer"],                  # stage 7
	["cristal"],                 # stage 8
	["minotaure"],               # stage 9
	["chevalier", "givre"],      # stage 10
]

const FALLBACK := "hunter"
const DEFAULT_WINDUP := 0.20
const DEFAULT_IMPACT_POSE := 5


static func has(id: String) -> bool:
	return SPECIES.has(id)


static func of(id: String) -> Dictionary:
	return SPECIES.get(id, SPECIES[FALLBACK])


## Temps entre le début du coup et l'instant où il touche, en secondes.
##
## Quatre images d'armement à vingt images par seconde pour les plus vifs : plus
## court, le geste redevient un tressaillement. Plus long pour ce qui est lourd :
## c'est le prix de sa masse, et ce qui laisse le temps de le voir venir.
static func windup(id: String) -> float:
	return float(of(id).get("windup", DEFAULT_WINDUP))


## L'image de la planche d'attaque où le coup touche, de 1 à 8. Relevée sur les
## planches : c'est celle où l'arme arrive au bout de sa course.
static func impact_pose(id: String) -> int:
	return int(of(id).get("impact_pose", DEFAULT_IMPACT_POSE))


static func display_name(id: String) -> String:
	return str(of(id)["name"])


## Toutes les espèces rencontrées jusqu'à ce stage inclus.
static func roster(stage: int) -> Array[String]:
	var out: Array[String] = []
	for index in mini(maxi(stage, 1), NEWCOMERS.size()):
		for id in NEWCOMERS[index]:
			out.append(str(id))
	return out
