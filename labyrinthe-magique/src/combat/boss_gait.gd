class_name BossGait
extends RefCounted

## La démarche d'un boss : ce qui le fait avancer autrement que ses neuf voisins.
##
## `walk` avance sans s'arrêter. `steps` marche puis se pose : le poids d'un colosse.
## `rush` s'élance de temps en temps. `keep_away` s'arrête à distance du mage.
## `blink` disparaît et revient près de lui. `charge` fonce tout droit jusqu'au mur et y
## reste sonné. Aucun `Node` ici : le Level regarde le labyrinthe, Enemy applique.

enum Cue { NONE, BLINK, WANTS_CHARGE }

const RUSH_EVERY := 4.5
const RUSH_TIME := 0.9
const RUSH_FACTOR := 1.7
const BLINK_EVERY := 7.0
const CHARGE_EVERY := 6.0
## Il s'arrête et se ramasse avant de partir : on doit avoir le temps de quitter sa ligne.
const CHARGE_WINDUP := 0.8

## Le multiplicateur de sa vitesse de marche à cet instant.
var factor := 1.0
## Reste-t-il sur place ?
var holding := false
## À quelle distance du mage il s'arrête, en pas. 0 = il vient au contact.
var keep_away := 0
## La vitesse de charge, en multiple de sa marche, et le temps qu'il reste sonné.
var charge_factor := 1.0
var stun := 0.0

var _kind: String
var _move_time := 0.0
var _rest_time := 0.0
var _left := 0.0
var _windup_left := 0.0
var _charge := Vector2i.ZERO


func _init(stage: int) -> void:
	var boss := BossCatalog.of_stage(stage)
	_kind = str(boss["gait"])
	_move_time = float(boss.get("move", 0.0))
	_rest_time = float(boss.get("rest", 0.0))
	keep_away = int(boss.get("keep_away", 0))
	charge_factor = float(boss.get("charge_speed", 0.0)) / float(boss["speed"])
	stun = float(boss.get("stun", 0.0))
	match _kind:
		"steps":
			_left = _move_time
		"rush":
			_left = RUSH_EVERY
		"blink":
			_left = BLINK_EVERY
		"charge":
			_left = CHARGE_EVERY


## `busy` : il lance un sort ou il est ébranlé. Ses grands gestes attendent.
func tick(delta: float, busy: bool) -> Cue:
	match _kind:
		"steps":
			_tick_steps(delta)
		"rush":
			_tick_rush(delta)
		"blink":
			if not busy:
				_left -= delta
			if _left <= 0.0:
				_left = BLINK_EVERY
				return Cue.BLINK
		"charge":
			return _tick_charge(delta, busy)
	return Cue.NONE


func _tick_steps(delta: float) -> void:
	_left -= delta
	if _left <= 0.0:
		holding = not holding
		_left = _rest_time if holding else _move_time


func _tick_rush(delta: float) -> void:
	_left -= delta
	if _left <= 0.0:
		var rushing := factor <= 1.0
		factor = RUSH_FACTOR if rushing else 1.0
		_left = RUSH_TIME if rushing else RUSH_EVERY


func _tick_charge(delta: float, busy: bool) -> Cue:
	if _windup_left > 0.0:
		_windup_left -= delta
		if _windup_left <= 0.0:
			holding = false
			factor = charge_factor
		return Cue.NONE
	if _charge != Vector2i.ZERO or busy:
		return Cue.NONE
	_left -= delta
	return Cue.WANTS_CHARGE if _left <= 0.0 else Cue.NONE


## Le mage est dans sa ligne : il se ramasse, puis il part.
func start_charge(direction: Vector2i) -> void:
	_charge = direction
	_windup_left = CHARGE_WINDUP
	holding = true


func end_charge() -> void:
	_charge = Vector2i.ZERO
	_windup_left = 0.0
	holding = false
	factor = 1.0
	_left = CHARGE_EVERY


## La direction où il fonce, zéro tant qu'il ne fonce pas.
func charge_direction() -> Vector2i:
	return _charge if _windup_left <= 0.0 else Vector2i.ZERO


## Une charge en cours : il ne lance pas de sort en même temps.
func is_charging() -> bool:
	return _charge != Vector2i.ZERO
