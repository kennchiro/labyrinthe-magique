class_name Awakening
extends RefCounted

## L'ÉVEIL D'UN MAGE (2026-11-07) : une minute sous sa forme transformée, puis dix secondes
## d'épuisement, et six kills avant le suivant. Sans la charge, le joueur l'avait demandé avec
## « 1 min et 10 s de recharge » : il aurait été éveillé six secondes sur sept, et l'Éveil serait
## devenu sa forme normale.
##
## Sans scène, comme `Transformation` d'Aël : le jeu le pilote, et une simulation le pourrait.
## La forme éveillée vient de `CharacterCatalog.awakening_of` ; le changement de forme passe par
## `form_changed`, que le GameManager applique au `Level` (le kit, les bandes, les icônes).
##
## Traits propres à chaque forme, portés ici parce qu'ils vivent et meurent avec l'Éveil :
## - RENAISSANCE : un coup mortel le relève une fois à 2 PV, intouchable, dans une explosion, et
##   met fin à l'Éveil ;
## - la TRAÎNÉE DE BRAISES qu'il laisse derrière lui (`CombatSystem.start_embers`) ;
## - MARÉE HAUTE (le Seigneur des Marées) : une coque d'eau qui encaisse un coup entier et se reforme
##   `SHELL_REGROW` secondes après avoir cédé. Elle vit dans le bouclier de `Health`, avec la Bulle.

enum State { NORMAL, CHARGING, AWAKE, EXHAUSTED }

const CHARGE_TIME := 0.8
const DURATION := 60.0
const EXHAUST_TIME := 10.0
const KILLS := 6
const REBIRTH_HEALTH := 2
const REBIRTH_IMMUNITY := 1.5
const REBIRTH_DAMAGE := 40
const REBIRTH_RADIUS := 2.5
const EMBER_DAMAGE := 6
const EMBER_LIFE := 1.5
const SHELL_REGROW := 6.0

signal changed(state: State)
## La forme à appliquer : l'éveillée au réveil, la forme de base à l'épuisement.
signal form_changed(next: CharacterStats)
## Il vient de renaître : le jeu en montre l'effet.
signal reborn
## Marée haute : la coque vient de se reformer, ou de céder.
signal shell_formed
signal shell_broken

var state := State.NORMAL
var left := 0.0
var charge := 0
var base: CharacterStats = null
var awakened: CharacterStats = null
var combat: CombatSystem = null
var health: Health = null
## La photo du monde que lit le combat : il en faut une pour l'onde de la Renaissance.
var context: CombatContext = null

var _reborn_used := false
var _health_seen := 0
var _minimum_before := 0
var _shell_up := false
var _shell_wait := 0.0


func _init(p_base: CharacterStats, p_awakened: CharacterStats, p_combat: CombatSystem,
		p_context: CombatContext) -> void:
	base = p_base
	awakened = p_awakened
	combat = p_combat
	context = p_context
	health = combat.health
	_health_seen = health.current
	health.damaged.connect(_on_damaged)
	health.healed.connect(_on_healed)


func dispose() -> void:
	if health.damaged.is_connected(_on_damaged):
		health.damaged.disconnect(_on_damaged)
	if health.healed.is_connected(_on_healed):
		health.healed.disconnect(_on_healed)


## `free` : en démo, l'Éveil ne demande aucun kill.
func can_begin(free := false) -> bool:
	return state == State.NORMAL and (free or charge >= KILLS)


func charge_ratio() -> float:
	return clampf(float(charge) / float(KILLS), 0.0, 1.0)


func awake() -> bool:
	return state == State.AWAKE


## Pendant le geste d'Éveil, le mage ne lance rien.
func can_act() -> bool:
	return state != State.CHARGING


func begin(free := false) -> bool:
	if not can_begin(free):
		return false
	if not free:
		charge = 0
	_change(State.CHARGING, CHARGE_TIME)
	return true


## Le joueur le quitte, ou la Renaissance y met fin.
func finish() -> void:
	if state == State.CHARGING or state == State.AWAKE:
		_change(State.EXHAUSTED, EXHAUST_TIME)


func kill() -> void:
	if state == State.NORMAL:
		charge = mini(charge + 1, KILLS)


func update(delta: float) -> void:
	var elapsed := maxf(0.0, delta)
	if state == State.AWAKE and base.id == CharacterCatalog.WATER:
		_tend_shell(elapsed)
	var remaining := elapsed
	while state != State.NORMAL and remaining >= left:
		remaining -= left
		match state:
			State.CHARGING:
				_change(State.AWAKE, DURATION)
			State.AWAKE:
				_change(State.EXHAUSTED, EXHAUST_TIME)
			State.EXHAUSTED:
				_change(State.NORMAL, 0.0)
	if state != State.NORMAL:
		left -= remaining


func _change(next: State, seconds: float) -> void:
	var before := state
	state = next
	left = seconds
	if next == State.AWAKE:
		if base.id == CharacterCatalog.FIRE:
			_reborn_used = false
			_minimum_before = health.minimum_current
			# Le coup qui devrait le tuer le laisse à 1 PV : `_on_damaged` le relève ensuite.
			health.minimum_current = maxi(1, health.minimum_current)
			_health_seen = health.current
			combat.start_embers(DURATION, EMBER_DAMAGE, EMBER_LIFE)
		elif base.id == CharacterCatalog.WATER:
			_shell_up = false
			_shell_wait = 0.0
			_tend_shell(0.0)
		form_changed.emit(awakened)
	elif before == State.AWAKE or (before == State.CHARGING and next == State.EXHAUSTED):
		if before == State.AWAKE:
			if base.id == CharacterCatalog.FIRE:
				health.minimum_current = _minimum_before
				combat.stop_embers()
			if base.id == CharacterCatalog.WATER and _shell_up:
				# La coque s'en va avec l'Éveil ; une Bulle encore en place garde le reste.
				health.shield = maxi(0, health.shield - 1)
				_shell_up = false
				shell_broken.emit()
		form_changed.emit(base)
	changed.emit(state)


## La coque cède quand le bouclier tombe à zéro, et revient `SHELL_REGROW` secondes plus tard. Le
## bouclier est lu à chaque image : un coup, la fin d'une Bulle ou n'importe quoi d'autre peut le vider.
func _tend_shell(delta: float) -> void:
	if _shell_up:
		if health.shield <= 0:
			_shell_up = false
			_shell_wait = SHELL_REGROW
			shell_broken.emit()
		return
	_shell_wait -= delta
	if _shell_wait <= 0.0:
		health.add_shield(1)
		_shell_up = true
		shell_formed.emit()


func shell_up() -> bool:
	return _shell_up


func _on_damaged(amount: int, remaining: int) -> void:
	var before := _health_seen
	_health_seen = remaining
	if base.id != CharacterCatalog.FIRE or state != State.AWAKE or _reborn_used:
		return
	# Mortel : le coup aurait vidé ses PV, et il en a bien pris (une plaque ou un bouclier
	# qui encaisse tout laisse `remaining` égal à `before`).
	if before - amount <= 0 and remaining < before:
		_rebirth()


func _on_healed(_amount: int, remaining: int) -> void:
	_health_seen = remaining


## RENAISSANCE : relevé à 2 PV, intouchable, et l'onde part. L'Éveil s'achève.
func _rebirth() -> void:
	_reborn_used = true
	var missing := REBIRTH_HEALTH - health.current
	if missing > 0:
		health.heal(missing)
	_health_seen = health.current
	combat.grant_immunity(REBIRTH_IMMUNITY)
	if context != null:
		combat.erupt(Ability.make({"id": base.id + "_renaissance", "kind": Ability.Kind.BLAST,
			"element": base.element, "damage": REBIRTH_DAMAGE, "radius": REBIRTH_RADIUS}), context)
	reborn.emit()
	finish()
