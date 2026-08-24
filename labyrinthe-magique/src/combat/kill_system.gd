class_name KillSystem
extends RefCounted

## Compteur d'ennemis éliminés et déblocage de l'Extra Power.
##
## Le seuil est une DONNÉE, pas une constante : chaque personnage a le sien
## (le Sorcier Suprême doit en tuer plus, son ultime est démesuré), et un futur
## réglage de difficulté n'aura qu'à changer ce nombre.

signal kill_registered(total: int, needed: int)
signal ultimate_ready
signal ultimate_spent

## Total de la partie — il ne redescend JAMAIS. C'est le score.
var kills := 0
## Progression vers le prochain ultime, remise à zéro à chaque utilisation.
var progress := 0
var needed: int
var charged := false


func _init(p_needed: int = 5) -> void:
	needed = maxi(1, p_needed)


func register_kill() -> void:
	kills += 1
	if not charged:
		progress += 1
		if progress >= needed:
			progress = needed
			charged = true
			ultimate_ready.emit()
	kill_registered.emit(kills, needed)


func available() -> bool:
	return charged


## Consomme l'ultime. Retourne false s'il n'était pas prêt — l'interface s'en
## sert pour refuser le geste au lieu de gaspiller le pouvoir en silence.
func spend() -> bool:
	if not charged:
		return false
	charged = false
	progress = 0
	ultimate_spent.emit()
	return true


## 0.0 à 1.0 : de quoi remplir une jauge sans que l'interface refasse le calcul.
func ratio() -> float:
	return 1.0 if charged else float(progress) / float(needed)
