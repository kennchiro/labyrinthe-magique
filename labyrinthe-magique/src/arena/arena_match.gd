class_name ArenaMatch
extends RefCounted

## Un match d'arène, du coup d'envoi au verdict. Aucun `Node` : `ArenaView` le montre,
## `tests/test_arena.gd` le joue sans affichage, et les deux exécutent ce même code.
##
## Le match DÉCIDE (qui marque, qui revient, qui gagne) ; la vue ne fait que montrer.

signal fighter_fell(victim: ArenaFighter, killer: ArenaFighter)
signal fighter_returned(fighter: ArenaFighter)
signal over(winner: int)
## Un héros change de forme (l'Éveil, ou son retour à la normale) : la vue redessine son sprite.
signal fighter_form_changed(fighter: ArenaFighter)
## Le geste d'Éveil commence : la vue et le HUD l'annoncent.
signal fighter_awakening(fighter: ArenaFighter)
## Un tir l'a manqué : il est sorti de sa ligne à temps.
signal fighter_dodged(fighter: ArenaFighter)

const AI_REFRESH := 0.3

var mode: ArenaRules.Mode = ArenaRules.Mode.HEART
var grid: MazeGrid
var teams: Array = [[], []]
var fighters: Array[ArenaFighter] = []
var score: Array[float] = [0.0, 0.0]
var time_left := 0.0
var elapsed := 0.0
## -1 personne, 0 ou 1 l'équipe qui tient la gemme seule, 2 disputée.
var holder := -1
var winner := -1
var finished := false
var heart_cells := {}
var heart_field := PackedInt32Array()
## L'équipe dont l'Éveil se déclenche À LA MAIN (celle du joueur) ; -1 : toutes s'éveillent seules,
## ce que font les tests.
var manual_team := -1
## Les coups ANNONCÉS (météores) : { team visée, cell, reach, time_left }. `ArenaBrain` les fuit.
var dangers: Array[Dictionary] = []

var _rng := RandomNumberGenerator.new()


## `team_a` et `team_b` : des dictionnaires { "id": String, "posture": ArenaRules.Posture }.
func _init(p_mode: ArenaRules.Mode, team_a: Array, team_b: Array, seed_value: int = 1) -> void:
	mode = p_mode
	grid = ArenaRules.build_grid()
	_rng.seed = seed_value
	time_left = ArenaRules.time_limit(mode)
	heart_field = Pathfinder.distance_field(grid, [ArenaRules.HEART_CELL] as Array[Vector2i])
	for c in grid.all_floor_cells():
		var d := Pathfinder.value_at(grid, heart_field, c)
		if d >= 0 and d <= ArenaRules.HEART_RADIUS:
			heart_cells[c] = true
	var picks := [team_a, team_b]
	for team in 2:
		for slot in mini(3, (picks[team] as Array).size()):
			var pick: Dictionary = picks[team][slot]
			var menu_id := str(pick.get("id", CharacterCatalog.FIRE))
			var stats := ArenaRules.fighter_stats(menu_id)
			var fighter := ArenaFighter.new(stats, team, slot, grid, seed_value * 97 + team * 13 + slot * 7 + 1,
				ArenaRules.vigor(menu_id))
			fighter.posture = int(pick.get("posture", ArenaRules.Posture.ASSAULT))
			teams[team].append(fighter)
			fighters.append(fighter)
	for fighter in fighters:
		for other in fighters:
			if other == fighter:
				continue
			if other.team == fighter.team:
				fighter.allies.append(other)
			else:
				fighter.opponents.append(other)
		for other in fighter.opponents:
			fighter.context.enemy_health.append(other.health)
			fighter.context.enemy_cells.append(other.cell())
			fighter.context.enemy_facings.append(other.facing())
		_wire(fighter)
		fighter.context.dodge_rule = _misses.bind(fighter)
		fighter.attach_awakening()
		if fighter.awakening != null:
			fighter.awakening.form_changed.connect(func(_next: CharacterStats) -> void:
				fighter_form_changed.emit(fighter))


## Ce que les sorts d'un héros font à ses adversaires. Le `Level` l'applique aux créatures,
## la simulation d'équilibrage aussi : ici, ce sont des héros qui le subissent.
func _wire(fighter: ArenaFighter) -> void:
	var combat := fighter.combat
	var foe := func(index: int) -> ArenaFighter:
		return fighter.opponents[index] if index >= 0 and index < fighter.opponents.size() else null
	var stun_one := func(index: int, seconds: float) -> void:
		var f: ArenaFighter = foe.call(index)
		if f != null:
			f.stun(seconds)
	var stun_many := func(indices: Array, seconds: float) -> void:
		for index in indices:
			stun_one.call(int(index), seconds)
	var move_one := func(index: int, to: Vector2i) -> void:
		var f: ArenaFighter = foe.call(index)
		if f != null:
			f.shove(to)
	combat.enemy_staggered.connect(stun_one)
	combat.enemy_shackled.connect(stun_one)
	combat.stasis_caught.connect(stun_one)
	combat.enemies_frozen.connect(stun_many)
	combat.chains_snapped.connect(stun_many)
	combat.soul_chains_cast.connect(stun_many)
	combat.cages_cast.connect(func(_c: Vector2i, indices: Array, seconds: float) -> void:
		stun_many.call(indices, seconds))
	combat.gaol_cast.connect(func(_c: Vector2i, indices: Array, _r: float, seconds: float) -> void:
		stun_many.call(indices, seconds))
	combat.enemies_dazed.connect(func(indices: Array, seconds: float, _a: Ability) -> void:
		stun_many.call(indices, seconds))
	combat.enemy_soaked.connect(func(index: int, seconds: float, factor: float) -> void:
		var f: ArenaFighter = foe.call(index)
		if f != null:
			f.slow(seconds, factor))
	# Un héros possédé ou aveuglé ne se retourne pas contre les siens (son combat ne connaît que
	# ses adversaires) : il perd sa cible et erre, comme une créature aveuglée.
	combat.enemy_blinded.connect(func(index: int, seconds: float) -> void:
		var f: ArenaFighter = foe.call(index)
		if f != null:
			f.lose_track(seconds))
	combat.enemy_possessed.connect(func(index: int, seconds: float) -> void:
		var f: ArenaFighter = foe.call(index)
		if f != null:
			f.lose_track(seconds))
	combat.enemy_pushed.connect(move_one)
	combat.enemy_slammed.connect(move_one)
	combat.enemy_hauled.connect(move_one)
	combat.enemy_swapped.connect(move_one)
	combat.enemy_hooked.connect(func(index: int, _from: Vector2i, to: Vector2i) -> void:
		move_one.call(index, to))
	combat.enemy_damaged.connect(func(_index: int, dealt: int, _a: Ability) -> void:
		fighter.tally_damage += maxi(0, dealt))
	# Le tir part : la cible le voit-elle venir ?
	combat.projectile_launched.connect(func(ability: Ability, index: int, path: Array, duration: float) -> void:
		var f: ArenaFighter = foe.call(index)
		if f != null:
			ArenaBrain.incoming(f, fighter, ability, path, duration, self))
	combat.projectile_dodged.connect(func(_a: Ability, index: int, _cell: Vector2i) -> void:
		var f: ArenaFighter = foe.call(index)
		if f != null:
			f.tally_dodges += 1
			fighter_dodged.emit(f))
	combat.meteor_incoming.connect(func(cell: Vector2i, delay: float, ability: Ability) -> void:
		dangers.append({"team": 1 - fighter.team, "cell": cell, "time_left": delay,
			"reach": maxi(1, int(ceil(ability.radius)))}))
	combat.enemy_killed.connect(func(index: int) -> void:
		var f: ArenaFighter = foe.call(index)
		if f != null:
			_fall(f, fighter))


## LE TIR ARRIVE : sa cible est-elle encore sur sa ligne ? Il a suivi les couloirs jusqu'à la case où
## elle se tenait au départ (`lane`). Touchée si elle y est restée, si elle a reculé tout droit dans le
## même couloir, ou si elle est dans le rayon de l'explosion ; esquivé si elle est sortie de côté.
## L'attaque de base pardonne `ATTACK_TOLERANCE` case : on ne l'évite qu'en le voulant.
func _misses(index: int, ability: Ability, lane: Array, shooter: ArenaFighter) -> bool:
	if index < 0 or index >= shooter.opponents.size():
		return false
	var here := shooter.opponents[index].cell()
	var aim: Vector2i = lane[-1]
	var tolerance := ArenaRules.ATTACK_TOLERANCE if ability == shooter.stats.attack else 0
	if _chebyshev(here, aim) <= maxi(tolerance, int(ceil(ability.radius))):
		return false
	if ability.from_sky:
		return true
	for c in lane:
		if _chebyshev(here, c) <= tolerance:
			return false
	if lane.size() >= 2:
		var heading: Vector2i = lane[-1] - lane[-2]
		for k in range(1, 4):
			if _chebyshev(here, aim + heading * k) <= tolerance:
				return false
	return true


static func _chebyshev(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


func _fall(victim: ArenaFighter, killer: ArenaFighter) -> void:
	if victim.respawn_left > 0.0:
		return
	victim.tally_deaths += 1
	victim.mover.desired_direction = Vector2i.ZERO
	victim.respawn_left = ArenaRules.RESPAWN_DELAY if mode == ArenaRules.Mode.HEART else INF
	# Tomber met fin à l'Éveil : il revient (ou reste au sol) sous sa forme de départ.
	if victim.awakening != null:
		victim.awakening.finish()
	if killer != null:
		killer.tally_kills += 1
		killer.kills.fill()
		killer.charge_awakening(ArenaRules.AWAKEN_KILL_STEPS)
		if mode == ArenaRules.Mode.HEART:
			score[killer.team] += ArenaRules.KILL_SCORE
	fighter_fell.emit(victim, killer)


func step(delta: float) -> void:
	if finished:
		return
	elapsed += delta
	time_left = maxf(0.0, time_left - delta)
	for fighter in fighters:
		_sense(fighter)
	for fighter in fighters:
		_tick_status(fighter, delta)
	for i in range(dangers.size() - 1, -1, -1):
		dangers[i]["time_left"] = float(dangers[i]["time_left"]) - delta
		if float(dangers[i]["time_left"]) <= 0.0:
			dangers.remove_at(i)
	for fighter in fighters:
		if fighter.alive():
			fighter.combat.update(delta, fighter.context)
			ArenaBrain.act(fighter, self)
	for fighter in fighters:
		_move(fighter, delta)
	# Un coup de zone, une brûlure ou un poison ne passent pas toujours par `enemy_killed` :
	# toute vie à zéro est une chute.
	for fighter in fighters:
		if not fighter.alive() and fighter.respawn_left <= 0.0:
			_fall(fighter, null)
	_respawn(delta)
	_score_heart(delta)
	_judge()


## Le monde tel que chaque combat le voit, remis à jour à chaque image.
func _sense(fighter: ArenaFighter) -> void:
	var context := fighter.context
	context.player_cell = fighter.cell()
	context.player_facing = fighter.facing()
	for i in fighter.opponents.size():
		var other := fighter.opponents[i]
		context.enemy_cells[i] = other.cell()
		context.enemy_facings[i] = other.facing()


func _tick_status(fighter: ArenaFighter, delta: float) -> void:
	fighter.stun_left = maxf(0.0, fighter.stun_left - delta)
	fighter.lost_left = maxf(0.0, fighter.lost_left - delta)
	fighter.slow_left = maxf(0.0, fighter.slow_left - delta)
	fighter.dodge_left = maxf(0.0, fighter.dodge_left - delta)
	if fighter.slow_left <= 0.0:
		fighter.slow_factor = 1.0
	if not fighter.alive():
		return
	fighter.ultimate_clock += delta
	if fighter.ultimate_clock >= ArenaRules.ULTIMATE_TICK:
		fighter.ultimate_clock = 0.0
		fighter.kills.drink_potion()
	if fighter.awakening != null:
		fighter.awakening.update(delta)
		fighter.awaken_clock += delta
		if fighter.awaken_clock >= ArenaRules.AWAKEN_TICK:
			fighter.awaken_clock = 0.0
			fighter.charge_awakening(1)


## L'Éveil d'un héros, à la demande du joueur ou de son cerveau. Refusé s'il n'est pas chargé.
func awaken(fighter: ArenaFighter) -> bool:
	if finished or fighter.awakening == null or not fighter.alive():
		return false
	if not fighter.awakening.begin():
		return false
	fighter_awakening.emit(fighter)
	return true


## Cet Éveil se décide-t-il seul ?
func auto_awakens(fighter: ArenaFighter) -> bool:
	return fighter.team != manual_team


func _move(fighter: ArenaFighter, delta: float) -> void:
	if not fighter.alive():
		return
	var combat := fighter.combat
	var pace := (fighter.stats.move_speed + combat.armor_speed()) * combat.flight_speed() * fighter.slow_factor
	if fighter.dodge_left > 0.0:
		pace *= ArenaRules.DODGE_BOOST
	fighter.mover.speed = 0.0 if combat.player_rooted() or fighter.stun_left > 0.0 else pace
	if fighter.stun_left > 0.0:
		fighter.mover.desired_direction = Vector2i.ZERO
	fighter.mover.update(delta)


func _respawn(delta: float) -> void:
	if mode != ArenaRules.Mode.HEART:
		return
	for fighter in fighters:
		if fighter.alive() or fighter.respawn_left == INF:
			continue
		fighter.respawn_left -= delta
		if fighter.respawn_left <= 0.0:
			fighter.respawn_left = 0.0
			fighter.revive()
			fighter_returned.emit(fighter)


func _score_heart(delta: float) -> void:
	if mode != ArenaRules.Mode.HEART:
		return
	var present := [0, 0]
	for fighter in fighters:
		if fighter.alive() and heart_cells.has(fighter.cell()):
			present[fighter.team] += 1
	if present[0] > 0 and present[1] > 0:
		holder = 2
	elif present[0] > 0:
		holder = 0
	elif present[1] > 0:
		holder = 1
	else:
		holder = -1
	if holder == 0 or holder == 1:
		score[holder] += ArenaRules.HEART_RATE * delta


func _judge() -> void:
	if mode == ArenaRules.Mode.HEART:
		for team in 2:
			if score[team] >= ArenaRules.HEART_GOAL:
				score[team] = ArenaRules.HEART_GOAL
				_finish(team)
				return
		if time_left <= 0.0:
			_finish(_leader(score[0], score[1]))
		return
	var standing := [alive_count(0), alive_count(1)]
	if standing[0] == 0 or standing[1] == 0:
		_finish(-1 if standing[0] == standing[1] else (0 if standing[0] > 0 else 1))
	elif time_left <= 0.0:
		# Au temps, la vie qui reste départage, en part de la vie de départ.
		_finish(_leader(life_share(0), life_share(1)))


func _leader(a: float, b: float) -> int:
	if is_equal_approx(a, b):
		return -1
	return 0 if a > b else 1


func _finish(team: int) -> void:
	finished = true
	winner = team
	over.emit(team)


func alive_count(team: int) -> int:
	var count := 0
	for fighter in teams[team]:
		if (fighter as ArenaFighter).alive():
			count += 1
	return count


## La part de vie qui reste à une équipe, de 0 à 1.
func life_share(team: int) -> float:
	var left := 0.0
	var full := 0.0
	for fighter in teams[team]:
		left += float((fighter as ArenaFighter).health.current)
		full += float((fighter as ArenaFighter).health.maximum)
	return left / maxf(1.0, full)


func is_heart_cell(cell: Vector2i) -> bool:
	return heart_cells.has(cell)


func randf_unit() -> float:
	return _rng.randf()


## Joue le match jusqu'au bout, sans affichage. Pour les tests et l'équilibrage.
func run(dt: float = 1.0 / 60.0) -> int:
	var limit := int((ArenaRules.time_limit(mode) + 5.0) / dt)
	for i in limit:
		step(dt)
		if finished:
			break
	return winner
