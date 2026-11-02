class_name KillSystem
extends RefCounted

## Compteur d'ennemis éliminés et charge de l'Extra Power, par les kills ou les potions.
##
## Le seuil est une DONNÉE, pas une constante : chaque personnage a le sien
## (le Sorcier Suprême doit en tuer plus, son ultime est démesuré), et un futur
## réglage de difficulté n'aura qu'à changer ce nombre.

## Une potion charge la moitié de la jauge, arrondie au-dessus. Une part et non un
## nombre fixe : le seuil va de 4 à 8 kills selon le mage.
const POTION_SHARE := 0.5

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
	_charge(1)
	kill_registered.emit(kills, needed)


## Retourne false si la jauge était déjà pleine : la potion n'a alors rien apporté.
func drink_potion() -> bool:
	if charged:
		return false
	_charge(ceili(float(needed) * POTION_SHARE))
	return true


func _charge(amount: int) -> void:
	if charged:
		return
	progress += amount
	if progress >= needed:
		progress = needed
		charged = true
		ultimate_ready.emit()


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
