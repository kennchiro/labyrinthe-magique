class_name CharacterStats
extends Resource

## Tout ce qui distingue un personnage d'un autre. Même rôle que LevelConfig pour
## la difficulté : ajouter un sixième mage = ajouter une fabrique en bas de
## character_catalog.gd, pas une ligne de gameplay.

@export var id: String = ""
@export var display_name: String = ""
@export var element: Element.Kind = Element.Kind.SHADOW
## L'onglet de l'écran de sélection où il apparaît. Voir `CharacterCatalog.CATEGORIES`.
@export var category: String = "mage"
@export var description: String = ""
## 1 à 5, affiché en étoiles dans l'écran de sélection. Purement indicatif.
@export var power_level: int = 3

## Points de vie de BASE. Le stage y ajoute son bonus (LevelConfig), ce qui
## permet de durcir un niveau sans toucher aux personnages, et inversement.
@export var base_health: int = 3
## Vitesse du mage, en cases par seconde. Celle des ennemis ne s'en déduit PAS :
## elle est calée sur une vitesse de référence, sinon choisir le mage le plus
## lent ralentirait aussi ses poursuivants et supprimerait le risque.
@export var move_speed: float = 5.0

## Kills nécessaires pour recharger l'ultime.
@export var ultimate_required_kills: int = 5

@export var attack: Ability = null
## Sort de FUITE, commun aux sept mais coloré par chacun. Il ne se débloque pas :
## un jeu de poursuite doit toujours offrir une porte de sortie, sinon être
## coincé dans un couloir n'est pas une erreur du joueur mais une impasse.
@export var escape: Ability = null
## Les trois compétences de la barre d'action.
@export var abilities: Array[Ability] = []
@export var ultimate: Ability = null


func color() -> Color:
	return Element.color(element)


## Toutes les compétences dans l'ordre du HUD :
##   0 attaque · 1-3 sorts · 4 fuite · 5 ultime
func action_bar() -> Array[Ability]:
	var out: Array[Ability] = []
	if attack != null:
		out.append(attack)
	out.append_array(abilities)
	if escape != null:
		out.append(escape)
	if ultimate != null:
		out.append(ultimate)
	return out
