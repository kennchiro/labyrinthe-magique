class_name Transformation
extends RefCounted

## État logique de la transformation, partagé par le jeu et les simulations.
## DRAGON (2026-11-04) : le second palier, au niveau 80, pris depuis le Prisme par le même bouton.
enum State { NORMAL, CHARGING, PRISM, EXHAUSTED, DRAGON_CHARGING, DRAGON }
const CHARGE_TIME := 0.8
const START_TIME := 20.0
const MAX_TIME := 30.0
const EXHAUST_TIME := 3.0
const DRAGON_LEVEL := 80
const DRAGON_TIME := 15.0
const DRAGON_MAX := 20.0
signal changed(state: State)
var state := State.NORMAL
var left := 0.0
## La charge mène directement au Dragon : la carte du Dragon d'or, en démo.
var _straight_to_dragon := false

func begin(hero_level: int, straight_to_dragon := false) -> bool:
	if hero_level < 30 or state != State.NORMAL:
		return false
	_straight_to_dragon = straight_to_dragon and hero_level >= DRAGON_LEVEL
	_change_state(State.CHARGING, CHARGE_TIME)
	return true


## Du Prisme au Dragon d'or : une nouvelle charge, puis 15 secondes de dragon.
func ascend(hero_level: int) -> bool:
	if hero_level < DRAGON_LEVEL or state != State.PRISM:
		return false
	_change_state(State.DRAGON_CHARGING, CHARGE_TIME)
	return true


func transformed() -> bool:
	return state in [State.PRISM, State.DRAGON_CHARGING, State.DRAGON]

func update(delta: float) -> void:
	var remaining := maxf(0.0, delta)
	while state != State.NORMAL and remaining >= left:
		remaining -= left
		match state:
			State.CHARGING:
				if _straight_to_dragon:
					_change_state(State.DRAGON, DRAGON_TIME)
				else:
					_change_state(State.PRISM, START_TIME)
			State.PRISM: finish()
			State.DRAGON_CHARGING: _change_state(State.DRAGON, DRAGON_TIME)
			State.DRAGON: finish()
			State.EXHAUSTED: _change_state(State.NORMAL, 0.0)
	if state != State.NORMAL:
		left -= remaining

func kill() -> void:
	if state == State.PRISM:
		left = minf(MAX_TIME, left + 2.0)
	elif state == State.DRAGON:
		left = minf(DRAGON_MAX, left + 1.0)

func hit(remaining_health: int) -> void:
	if state != State.PRISM and state != State.DRAGON:
		return
	left = maxf(0.0, left - 3.0)
	if remaining_health <= 1 or left <= 0.0:
		finish()

func finish() -> void:
	if state in [State.PRISM, State.CHARGING, State.DRAGON_CHARGING, State.DRAGON]:
		_straight_to_dragon = false
		_change_state(State.EXHAUSTED, EXHAUST_TIME)

func _change_state(next: State, seconds: float) -> void:
	state = next
	left = seconds
	changed.emit(state)
