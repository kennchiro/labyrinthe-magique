class_name HeroRuntime
extends RefCounted

## Les règles d’Aël, sans scène : XP, évolution, transformation et retour.
signal character_changed(character: CharacterStats)
signal progressed(amount: int, levels_gained: int)
var progress: HeroProgress
var transformation := Transformation.new()
var combat: CombatSystem
var health: Health
var _form := 0
var evolution_left := 0.0
## LA TRANSFORMATION A SON BOUTON (2026-11-04), et sa propre charge : des kills depuis la dernière,
## à part de l'Extra, que l'Ascendant garde pour sa Nova.
const TRANSFORM_KILLS := 6
## Du Prisme au Dragon d'or (niveau 80) : des kills faits EN Prisme.
const DRAGON_KILLS := 8
var charge := 0
var _aura_plate := false
## Les écailles du Dragon d'or : une plaque de plus, perdue avec la forme.
var _scale_plate := false

func _init(saved: HeroProgress, system: CombatSystem) -> void:
	progress = saved
	combat = system
	health = combat.health
	_form = progress.form()
	transformation.changed.connect(_on_state)
	combat.hero_transformation_requested.connect(_begin)
	health.damaged.connect(_damaged)
	health.plate_torn.connect(_plate_torn)
	_refresh()

func gain(amount: int) -> void:
	var before := progress.form()
	var levels := progress.gain(amount)
	if before != progress.form():
		evolution_left = 1.5
		combat.grant_immunity(evolution_left)
		health.maximum += 1 if before == 0 else 0
		health.plates += 1 if progress.form() >= 2 and before < 2 else 0
	if levels > 0:
		health.heal(levels)
		_refresh()
	progressed.emit(amount, levels)

func defeat(species: String, boss := false) -> int:
	var amount := 150 if boss else maxi(1, roundi(10.0 * float(Bestiary.of(species).get("toughness", 1.0))))
	gain(amount)
	return amount

func victory(stage: int, episode: int) -> void:
	var key := "%d:%d" % [stage, episode]
	var amount := 50 if progress.victories.has(key) else 75
	progress.victories[key] = true
	gain(amount)

func update(delta: float) -> void:
	if evolution_left > 0.0:
		evolution_left = maxf(0.0, evolution_left - delta)
		if evolution_left <= 0.0:
			_refresh()
	transformation.update(delta)

func kill() -> void:
	transformation.kill()
	if transformation.state == Transformation.State.NORMAL and progress.level() >= 30:
		charge = mini(charge + 1, TRANSFORM_KILLS)
	elif transformation.state == Transformation.State.PRISM and progress.level() >= Transformation.DRAGON_LEVEL:
		charge = mini(charge + 1, DRAGON_KILLS)


## La charge du prochain palier : la Transformation, ou le Dragon d'or depuis le Prisme.
func charge_needed() -> int:
	return DRAGON_KILLS if transformation.state == Transformation.State.PRISM else TRANSFORM_KILLS


func charge_ratio() -> float:
	return float(charge) / float(charge_needed())


## Le prochain appui mènerait-il au Dragon d'or ?
func next_is_dragon() -> bool:
	return transformation.state == Transformation.State.PRISM and progress.level() >= Transformation.DRAGON_LEVEL


## `free` : en démo, la transformation ne demande aucun kill.
func can_transform(free := false) -> bool:
	if evolution_left > 0.0 or not (free or charge >= charge_needed()):
		return false
	if transformation.state == Transformation.State.NORMAL:
		return progress.level() >= 30
	return next_is_dragon()


func transform(free := false) -> bool:
	if not can_transform(free):
		return false
	var dragon := next_is_dragon()
	if not free:
		charge = 0
	if dragon:
		return transformation.ascend(progress.level())
	return transformation.begin(progress.level())

func finish() -> void:
	transformation.finish()

func can_act() -> bool:
	return evolution_left <= 0.0 and transformation.state != Transformation.State.CHARGING \
		and transformation.state != Transformation.State.DRAGON_CHARGING

func _on_state(state: Transformation.State) -> void:
	if state == Transformation.State.CHARGING or state == Transformation.State.DRAGON_CHARGING:
		combat.grant_immunity(Transformation.CHARGE_TIME)
	elif state == Transformation.State.DRAGON:
		health.minimum_current = 1
		if not _aura_plate:
			health.plates += 1
			_aura_plate = true
		health.plates += 1
		_scale_plate = true
	elif state == Transformation.State.PRISM:
		health.minimum_current = 1
		health.plates += 1
		_aura_plate = true
	elif state == Transformation.State.EXHAUSTED:
		health.minimum_current = 0
		# La plaque d’aura disparaît avec la forme, sans rendre une plaque déjà perdue.
		if _aura_plate:
			health.plates = maxi(0, health.plates - 1)
		if _scale_plate:
			health.plates = maxi(0, health.plates - 1)
		_aura_plate = false
		_scale_plate = false
		charge = 0
	_refresh()

func _refresh() -> void:
	var state := transformation.state
	var next := HeroCatalog.at_level(progress.level(),
		state == Transformation.State.PRISM or state == Transformation.State.DRAGON_CHARGING,
		state == Transformation.State.DRAGON)
	if state == Transformation.State.EXHAUSTED:
		next.move_speed *= 0.65
	elif state == Transformation.State.CHARGING or state == Transformation.State.DRAGON_CHARGING or evolution_left > 0.0:
		next.move_speed = 0.0
	_form = progress.form()
	combat.hero_transform_allowed = progress.level() >= 30 and transformation.state == Transformation.State.NORMAL and evolution_left <= 0.0
	combat.change_form(next)
	character_changed.emit(next)
	combat.plates_changed.emit(health.plates)

func _begin() -> void:
	if can_act():
		transformation.begin(progress.level())

func _damaged(_amount: int, remaining: int) -> void:
	transformation.hit(remaining)

func _plate_torn() -> void:
	_aura_plate = false
	combat.plates_changed.emit(health.plates)

func dispose() -> void:
	if health.plate_torn.is_connected(_plate_torn):
		health.plate_torn.disconnect(_plate_torn)
	if combat.hero_transformation_requested.is_connected(_begin):
		combat.hero_transformation_requested.disconnect(_begin)
	if health.damaged.is_connected(_damaged):
		health.damaged.disconnect(_damaged)
	if transformation.changed.is_connected(_on_state):
		transformation.changed.disconnect(_on_state)
