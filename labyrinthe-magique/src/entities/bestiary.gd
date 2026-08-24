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

const SPECIES := {
	"hunter": {
		"name": "Spectre", "toughness": 1.00, "swiftness": 1.00, "height": 52.0,
		"walk_fps": 3.2, "strike": 0.60, "repos": 0.55,
		"trait": "lévite lentement, charge son coup à bout de bras",
	},
	"goblin": {
		"name": "Gobelin", "toughness": 1.37, "swiftness": 1.00, "height": 50.0,
		"walk_fps": 8.0, "strike": 0.22, "repos": 0.28,
		"trait": "petit, coriace, frappe vite et souvent",
	},
	"serpent": {
		"name": "Serpent d'Émeraude", "toughness": 0.82, "swiftness": 1.16, "height": 46.0,
		"walk_fps": 7.0, "strike": 0.30, "repos": 0.30,
		"trait": "file dans les couloirs, mais se brise au premier sort",
	},
	"ombre": {
		"name": "Ombre Encapuchonnée", "toughness": 1.10, "swiftness": 1.12, "height": 52.0,
		"walk_fps": 4.0, "strike": 0.45, "repos": 0.40,
		"trait": "glisse sans bruit, rattrape en ligne droite",
	},
	"dragonnet": {
		"name": "Dragonnet de Feu", "toughness": 1.20, "swiftness": 1.14, "height": 50.0,
		"walk_fps": 6.0, "strike": 0.35, "repos": 0.35,
		"trait": "vole, donc ne ralentit jamais dans les virages",
	},
	"golem": {
		"name": "Golem de Lave", "toughness": 1.90, "swiftness": 0.80, "height": 58.0,
		"walk_fps": 4.5, "strike": 0.50, "repos": 0.55,
		"trait": "une masse : on ne le sème pas, on l'use",
	},
	"archer": {
		"name": "Archer d'Os", "toughness": 1.05, "swiftness": 1.00, "height": 50.0,
		"walk_fps": 6.5, "strike": 0.28, "repos": 0.34,
		"trait": "sec et rapide du geste, fragile au contact",
	},
	"cristal": {
		"name": "Démon de Cristal", "toughness": 1.70, "swiftness": 0.86, "height": 56.0,
		"walk_fps": 4.5, "strike": 0.45, "repos": 0.50,
		"trait": "blindé de cristal, lourd à déplacer",
	},
	"minotaure": {
		"name": "Minotaure", "toughness": 1.60, "swiftness": 1.10, "height": 58.0,
		"walk_fps": 7.0, "strike": 0.30, "repos": 0.36,
		"trait": "charge : robuste ET rapide, la pire combinaison",
	},
	"chevalier": {
		"name": "Chevalier Noir", "toughness": 1.45, "swiftness": 1.02, "height": 54.0,
		"walk_fps": 6.0, "strike": 0.34, "repos": 0.38,
		"trait": "bouclier et lame, sans faiblesse marquée",
	},
	"givre": {
		"name": "Golem de Givre", "toughness": 2.00, "swiftness": 0.78, "height": 58.0,
		"walk_fps": 4.2, "strike": 0.52, "repos": 0.58,
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


static func has(id: String) -> bool:
	return SPECIES.has(id)


static func of(id: String) -> Dictionary:
	return SPECIES.get(id, SPECIES[FALLBACK])


static func display_name(id: String) -> String:
	return str(of(id)["name"])


## Toutes les espèces rencontrées jusqu'à ce stage inclus.
static func roster(stage: int) -> Array[String]:
	var out: Array[String] = []
	for index in mini(maxi(stage, 1), NEWCOMERS.size()):
		for id in NEWCOMERS[index]:
			out.append(str(id))
	return out
