class_name MeleeSwing
extends RefCounted

## Un coup au corps à corps : il part au contact et ne touche qu'à l'IMPACT.
##
## Les dégâts tombaient à la première image du geste, avant que l'arme ne bouge :
## le mage perdait ses PV pendant que le gobelin levait encore sa massue. Le coup
## s'arme donc d'abord, et celui qui sort de portée pendant l'armement l'a esquivé.
##
## Sans dépendance au moteur de scène : la simulation d'équilibrage joue le même
## coup que le jeu.

enum Event { NONE, STARTED, LANDED, MISSED }

## Portée de l'arme au-delà de la distance de contact, en cases. Un mage qui file
## devant un poursuivant reste touché ; seul celui qui croise ou qui prend
## vraiment le large esquive.
const REACH_MARGIN := 0.3

var _windup_left := 0.0
var _cooldown_left := 0.0


## À appeler à chaque image. `gap` est la distance au mage, `contact` la distance
## à laquelle le coup part, et `cycle` le temps entre deux coups.
func tick(delta: float, gap: float, contact: float, windup: float, cycle: float) -> Event:
	_cooldown_left = maxf(0.0, _cooldown_left - delta)
	if _windup_left > 0.0:
		_windup_left -= delta
		if _windup_left > 0.0:
			return Event.NONE
		_windup_left = 0.0
		return Event.LANDED if gap < contact + REACH_MARGIN else Event.MISSED
	if _cooldown_left <= 0.0 and gap < contact:
		_windup_left = maxf(delta, windup)
		_cooldown_left = maxf(cycle, windup)
		return Event.STARTED
	return Event.NONE


## La créature est morte, ou ébranlée : son coup n'aura pas lieu.
func cancel() -> void:
	_windup_left = 0.0


func is_winding_up() -> bool:
	return _windup_left > 0.0
