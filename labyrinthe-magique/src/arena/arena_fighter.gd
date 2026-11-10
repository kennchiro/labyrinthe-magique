class_name ArenaFighter
extends RefCounted

## Un héros dans l'arène : son corps sur la grille, sa vie, SON système de combat, et ce que
## les sorts adverses lui font subir.
##
## CHACUN A SON `CombatSystem`, et dans son `CombatContext` les héros d'en face tiennent la
## place des ennemis. Les sorts, les traits, les zones et les invocations marchent donc entre
## héros sans une ligne réécrite : c'est le même code qu'en campagne. L'ordre des adversaires
## ne change jamais, même quand l'un d'eux tombe — un index décalé enverrait un projectile en
## vol sur le voisin (même règle que les repaires et les gelées du `Level`).

var team := 0
var slot := 0
var stats: CharacterStats
var posture: ArenaRules.Posture = ArenaRules.Posture.ASSAULT
var spawn := Vector2i.ZERO

var mover: GridMover
var health: Health
var combat: CombatSystem
var context: CombatContext
var kills: KillSystem
## L'ÉVEIL, s'il en a un (`CharacterCatalog.awakening_of`). Nul pour Aël, dont la transformation passe
## par ses niveaux (`HeroRuntime`), et pour les mages dont l'Éveil n'est pas encore fait.
var awakening: Awakening = null
## La forme de départ : l'Éveil la remplace, la chute ou l'épuisement la rendent.
var base_stats: CharacterStats
var awaken_clock := 0.0
## Les adversaires, dans l'ordre FIXE des tableaux du contexte.
var opponents: Array[ArenaFighter] = []
var allies: Array[ArenaFighter] = []

## Ce que les sorts adverses lui font, décompté à chaque image.
var stun_left := 0.0
var slow_left := 0.0
var slow_factor := 1.0
## Aveuglé ou possédé : il erre et ne vise plus.
var lost_left := 0.0
var respawn_left := 0.0
var ultimate_clock := 0.0

## La décision de mouvement, rafraîchie trois fois par seconde comme l'IA des créatures.
var think_left := 0.0
var goal := Vector2i(-1, -1)
var goal_field := PackedInt32Array()
## Champ de distances depuis lui, que lit son combat (`player_field`).
var field := PackedInt32Array()
var wander := Vector2i.ZERO
## Le pas de côté en cours (`ArenaBrain.incoming`), et quand le prochain sera possible.
var dodge_left := 0.0
var dodge_cell := Vector2i(-1, -1)
var dodge_ready_at := 0.0
## La case de bataille tenue jusqu'à `strafe_until` (`ArenaBrain._battle_cell`).
var strafe_cell := Vector2i(-1, -1)
var strafe_until := 0.0
## La cible choisie (`ArenaBrain._choose_focus`), que vise aussi `find_target`.
var focus: ArenaFighter = null
## Depuis quand il garde son gros coup pour un combo, et depuis quand son Extra est prêt (-1 : non).
var combo_hold_since := -1.0
var ultimate_ready_since := -1.0

## Le bilan du match, pour l'écran de fin.
var tally_kills := 0
var tally_deaths := 0
var tally_damage := 0
var tally_dodges := 0

var _scaling := false


func _init(p_stats: CharacterStats, p_team: int, p_slot: int, grid: MazeGrid, seed_value: int,
		p_vigor: float = 1.0) -> void:
	stats = p_stats
	base_stats = p_stats
	team = p_team
	slot = p_slot
	spawn = ArenaRules.SPAWNS[team][slot]
	mover = GridMover.new(grid, spawn, stats.move_speed)
	health = Health.new(int(round(float(stats.base_health * ArenaRules.HP_PER_PV) * p_vigor)))
	combat = CombatSystem.new(grid, stats, health, seed_value)
	context = CombatContext.new(grid)
	kills = KillSystem.new(stats.ultimate_required_kills)
	# Les soins et les boucliers du jeu sont comptés en PV : on les remet à l'échelle de l'arène.
	health.healed.connect(_scale_heal)
	# `add_shield` garde le plus grand : on REMET le bouclier à sa valeur d'arène, qui peut être plus
	# petite que celle que le combat vient de poser (45 coups pour la Bulle).
	combat.player_shielded.connect(func(amount: int, _duration: float) -> void:
		health.shield = mini(amount * ArenaRules.SHIELD_PER_HIT,
			mini(ArenaRules.SHIELD_CAP, int(float(health.maximum) * ArenaRules.SHIELD_SHARE))))
	combat.player_made_immune.connect(func(seconds: float) -> void:
		if seconds > ArenaRules.IMMUNE_CAP:
			combat._immune_left = minf(combat._immune_left, ArenaRules.IMMUNE_CAP))
	# Ce qui DÉPLACE le lanceur passe par ces signaux, comme dans le `Level`.
	combat.blink_performed.connect(func(_from: Vector2i, to: Vector2i) -> void: _land_on(to))
	combat.dash_cut.connect(func(_from: Vector2i, to: Vector2i) -> void: _land_on(to))
	combat.comet_performed.connect(func(_from: Vector2i, to: Vector2i) -> void: _land_on(to))
	combat.flight_started.connect(func(_d: float, _a: Ability) -> void: mover.phases = true)
	combat.flight_ended.connect(func() -> void:
		mover.phases = false
		_land_on(_nearest_floor(mover.nearest_cell())))


func alive() -> bool:
	return health.is_alive()


func cell() -> Vector2i:
	return mover.nearest_cell()


func facing() -> Vector2i:
	return mover.direction if mover.direction != Vector2i.ZERO else (Vector2i.RIGHT if team == 0 else Vector2i.LEFT)


## Peut-il agir ? Ni mort, ni sonné, ni en plein geste d'Éveil.
func can_act() -> bool:
	return alive() and stun_left <= 0.0 and (awakening == null or awakening.can_act())


## L'Éveil, rattaché une fois le contexte rempli : la Renaissance du Phénix en a besoin pour son onde.
func attach_awakening() -> void:
	var form := CharacterCatalog.awakening_of(stats.id)
	if form == null or stats.id == CharacterCatalog.AEL:
		return
	awakening = Awakening.new(stats, form, combat, context)
	awakening.form_changed.connect(_take_form)
	# La coque du Seigneur des Marées vaut un demi-PV d’arène : un point de bouclier ne retiendrait rien.
	awakening.shell_formed.connect(func() -> void: health.add_shield(ArenaRules.SHIELD_CAP / 2))


func _take_form(next: CharacterStats) -> void:
	stats = next
	combat.change_form(next)


## Une marche de plus vers l'Éveil, seulement hors Éveil (même règle que `Awakening.kill`).
func charge_awakening(steps: int) -> void:
	if awakening != null and awakening.state == Awakening.State.NORMAL:
		awakening.charge = mini(awakening.charge + steps, Awakening.KILLS)


func stun(seconds: float) -> void:
	stun_left = maxf(stun_left, minf(seconds, ArenaRules.STUN_CAP))


func slow(seconds: float, factor: float) -> void:
	slow_left = maxf(slow_left, seconds)
	slow_factor = minf(slow_factor if slow_left > 0.0 else 1.0, clampf(factor, 0.1, 1.0))


func lose_track(seconds: float) -> void:
	lost_left = maxf(lost_left, seconds)


## Poussé, aspiré, ramené au crochet : la case vient du sort adverse.
func shove(to: Vector2i) -> void:
	if alive():
		_land_on(to)


func _land_on(to: Vector2i) -> void:
	mover.teleport_to(to if mover.grid.is_floor_v(to) or mover.phases else _nearest_floor(to))


func _nearest_floor(from: Vector2i) -> Vector2i:
	var grid := mover.grid
	if grid.is_floor_v(from):
		return from
	for reach in range(1, 6):
		for dy in range(-reach, reach + 1):
			for dx in range(-reach, reach + 1):
				var at := from + Vector2i(dx, dy)
				if grid.in_bounds(at.x, at.y) and grid.is_floor_v(at):
					return at
	return spawn


func _scale_heal(amount: int, _remaining: int) -> void:
	if _scaling or amount > ArenaRules.SMALL_HEAL:
		return
	_scaling = true
	health.heal(amount * (ArenaRules.HEAL_PER_PV - 1))
	_scaling = false


## De retour sur son socle, plein de vie, intouchable un instant.
func revive() -> void:
	health.current = health.maximum
	health.shield = 0
	health.plates = maxi(health.plates, stats.base_plates)
	mover.phases = false
	mover.teleport_to(spawn)
	stun_left = 0.0
	slow_left = 0.0
	lost_left = 0.0
	dodge_left = 0.0
	strafe_cell = Vector2i(-1, -1)
	focus = null
	context.focus = -1
	combo_hold_since = -1.0
	goal = Vector2i(-1, -1)
	think_left = 0.0
	combat.grant_immunity(ArenaRules.RESPAWN_SHIELD)
