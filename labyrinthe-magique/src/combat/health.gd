class_name Health
extends RefCounted

## Points de vie d'une entité — ennemi comme joueur.
##
## Aucune dépendance au moteur de scène : la simulation d'équilibrage peut donc
## jouer des combats entiers en headless avec EXACTEMENT cette classe, au lieu
## d'une arithmétique parallèle qui finirait par diverger des règles du jeu.

signal damaged(amount: int, remaining: int)
signal healed(amount: int, remaining: int)
signal died

var maximum: int
var current: int
## Absorption temporaire (bouclier d'eau, écorce de terre…). Elle encaisse avant
## les points de vie et ne se régénère pas toute seule.
var shield: int = 0


func _init(p_maximum: int) -> void:
	maximum = maxi(1, p_maximum)
	current = maximum


func is_alive() -> bool:
	return current > 0


func ratio() -> float:
	return float(current) / float(maximum)


## Applique un coup. Retourne les dégâts RÉELLEMENT encaissés — l'appelant en a
## besoin pour afficher le bon nombre quand un bouclier a absorbé une partie.
func take(damage: Damage) -> int:
	if not is_alive() or damage.amount <= 0:
		return 0

	var left := damage.amount
	if shield > 0:
		var absorbed: int = mini(shield, left)
		shield -= absorbed
		left -= absorbed

	var dealt: int = mini(current, left)
	current -= dealt
	damaged.emit(damage.amount, current)
	if current <= 0:
		died.emit()
	return dealt + (damage.amount - left)


func heal(amount: int) -> int:
	if amount <= 0 or not is_alive():
		return 0
	var restored: int = mini(maximum - current, amount)
	current += restored
	if restored > 0:
		healed.emit(restored, current)
	return restored


func add_shield(amount: int) -> void:
	shield = maxi(shield, amount)
