class_name FootDust
extends Node2D

## La poussière des appuis. Le nœud reste à l'origine du monde et ne dépend donc pas du
## personnage : un nuage reste là où le pied s'est posé.

const LIFE := 0.3
const MAX_PUFFS := 8
const COLOUR := Color(0.86, 0.8, 0.66)

var _puffs: Array[Dictionary] = []


func _ready() -> void:
	top_level = true
	global_position = Vector2.ZERO
	z_index = -1


## `at` en coordonnées du monde, `away` la direction où part le nuage.
func puff(at: Vector2, away: Vector2, size: float) -> void:
	if _puffs.size() >= MAX_PUFFS:
		_puffs.pop_front()
	_puffs.append({"at": at, "away": away, "size": size, "age": 0.0})


func _process(delta: float) -> void:
	if _puffs.is_empty():
		return
	for puff_data in _puffs:
		puff_data["age"] += delta
	_puffs = _puffs.filter(func(p: Dictionary) -> bool: return p["age"] < LIFE)
	queue_redraw()


func _draw() -> void:
	for puff_data in _puffs:
		var done: float = puff_data["age"] / LIFE
		var size: float = puff_data["size"]
		var drift: Vector2 = puff_data["away"] * size * done * 1.4
		var centre: Vector2 = puff_data["at"] + drift + Vector2(0.0, -size * done * 0.5)
		draw_circle(centre, size * (0.45 + done * 0.6), Color(COLOUR, 0.42 * (1.0 - done)))
