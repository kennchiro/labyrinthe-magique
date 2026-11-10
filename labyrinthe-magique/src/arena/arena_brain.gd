class_name ArenaBrain
extends RefCounted

## Ce que décide un héros que personne ne pilote : où aller, et quel sort lancer.
##
## Le choix du sort reprend `test_balance._use_best_ability`, qui imite un joueur : se protéger
## quand on est bas, sinon frapper le plus fort possible. Le choix de la case dépend de la
## POSTURE donnée avant le match, puis de deux réflexes communs à tous : reculer quand on est
## presque mort et serré de près, et errer quand on est aveuglé.

## En dessous de cette part de vie, un héros serré de près recule et tente sa fuite.
const RETREAT_BELOW := 0.3
## « Serré de près », en distance de chemin.
const THREAT_RADIUS := 3
## Sans cible à moins de ça, un sort autre que l'attaque n'est pas lancé : il serait gâché.
const CAST_REACH := 5
## Un gardien qui voit un adversaire à cette distance de la gemme va le chercher.
const GUARD_SIGHT := 4


static func act(fighter: ArenaFighter, arena: ArenaMatch) -> void:
	if not fighter.can_act():
		return
	_think(fighter, arena)
	if fighter.dodge_left > 0.0:
		_steer_dodge(fighter)
	else:
		_steer(fighter)
	if fighter.lost_left > 0.0:
		return
	_cast(fighter, arena)


## Le champ de distances depuis le héros et sa destination, trois fois par seconde.
static func _think(fighter: ArenaFighter, arena: ArenaMatch) -> void:
	var now := arena.elapsed
	if now < fighter.think_left:
		return
	fighter.think_left = now + ArenaMatch.AI_REFRESH
	var grid := arena.grid
	fighter.field = Pathfinder.distance_field(grid, [fighter.cell()] as Array[Vector2i])
	fighter.context.player_field = fighter.field
	_choose_focus(fighter)
	var goal := _choose_goal(fighter, arena)
	if goal != fighter.goal or fighter.goal_field.is_empty():
		fighter.goal = goal
		fighter.goal_field = Pathfinder.distance_field(grid, [goal] as Array[Vector2i])


static func _choose_goal(fighter: ArenaFighter, arena: ArenaMatch) -> Vector2i:
	var here := fighter.cell()
	if fighter.lost_left > 0.0:
		# Il erre : une case voisine au hasard, tenue jusqu'à la prochaine décision.
		var options := arena.grid.floor_neighbors(here)
		return options[int(arena.randf_unit() * options.size()) % options.size()] if not options.is_empty() else here
	# RÉFLEXE COMMUN : on ne reste pas dans un sort adverse (zone posée, météore annoncé).
	if is_dangerous(fighter, here, arena):
		var refuge := _safe_cell(fighter, arena)
		if refuge != here:
			return refuge
	var nearest := _nearest_opponent(fighter)
	var nearest_distance := _distance(fighter, nearest)
	# RÉFLEXE COMMUN : presque mort et serré de près, il recule vers son socle.
	if fighter.health.ratio() < RETREAT_BELOW and nearest != null and nearest_distance <= THREAT_RADIUS:
		return fighter.spawn
	var heart := arena.mode == ArenaRules.Mode.HEART
	match fighter.posture:
		ArenaRules.Posture.GUARD:
			if heart:
				# Il tient la gemme, et ne la quitte que pour un adversaire qui s'en approche.
				if nearest != null and _distance_to_heart(arena, nearest) <= GUARD_SIGHT:
					return _battle_cell(fighter, nearest, arena)
				return _heart_spot(fighter, arena)
			# En duel, il couvre l'allié le plus blessé, et frappe ce qui l'approche.
			var ward := _weakest(fighter.allies)
			if nearest != null and nearest_distance <= CAST_REACH:
				return _battle_cell(fighter, nearest, arena)
			if ward != null:
				return ward.cell()
			return _battle_cell(fighter, nearest, arena) if nearest != null else here
		ArenaRules.Posture.HUNTER:
			var prey := _weakest(fighter.opponents)
			if prey != null:
				return _battle_cell(fighter, prey, arena)
		_:
			# L'assaillant : au contact de sa cible, sinon du plus proche ; sans personne en vue, à la gemme.
			if nearest != null and (not heart or nearest_distance <= CAST_REACH * 2):
				return _battle_cell(fighter, fighter.focus if fighter.focus != null else nearest, arena)
	if heart:
		return _heart_spot(fighter, arena)
	return _battle_cell(fighter, nearest, arena) if nearest != null else here


## Une case de la gemme, propre à chaque héros : trois alliés sur la même case se cachent.
static func _heart_spot(fighter: ArenaFighter, arena: ArenaMatch) -> Vector2i:
	var spots: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, -1), Vector2i(0, 1)]
	var side := -1 if fighter.team == 0 else 1
	var spot := ArenaRules.HEART_CELL + Vector2i(side, 0) + spots[fighter.slot % spots.size()]
	return spot if arena.grid.is_floor_v(spot) else ArenaRules.HEART_CELL


## Aller vers un adversaire, puis SE BATTRE EN BOUGEANT : à portée, le héros change de case toutes
## les `STRAFE_MIN` à `STRAFE_MAX` secondes dans sa bande de portée, de préférence hors de la ligne
## de l'adversaire, et jamais dans un sort posé. Un tireur garde ses distances face à un héros de
## contact ; un héros de contact tourne autour de sa proie. Planté sur une case, un héros prenait
## tout (demande du joueur, 2026-11-10).
##
## ⚠️ La bande s'arrête à portée de SES SORTS, pas seulement de son attaque. S'arrêter au bout de
## l'attaque (huit cases pour certains) laissait deux tireurs s'échanger leurs tirs de base à sept
## cases, sans jamais lancer un sort ni s'éveiller : tout ce qui n'est pas l'attaque attend un
## adversaire à `CAST_REACH` (mesuré le 2026-11-09, Feu contre Eau figés à sept cases trente secondes).
static func _battle_cell(fighter: ArenaFighter, target: ArenaFighter, arena: ArenaMatch) -> Vector2i:
	var reach := _attack_reach(fighter)
	var high := clampi(reach - 1, 1, CAST_REACH - 1)
	var distance := _distance(fighter, target)
	if distance < 0 or distance > high:
		fighter.strafe_cell = Vector2i(-1, -1)
		return target.cell()
	# Un tireur ne se laisse pas coller : jamais à moins de deux cases. Trois, face à un héros de contact,
	# a été essayé : Aël (portée 2) ne touchait plus personne, 13 % de duels gagnés (2026-11-10).
	var low := 2 if reach > ArenaRules.MELEE_REACH else 1
	low = mini(low, high)
	var held := fighter.strafe_cell
	if arena.elapsed < fighter.strafe_until and held.x >= 0 and _fits(fighter, target, held, low, high, arena):
		return held
	var best := fighter.cell()
	var best_score := -INF
	var here := fighter.cell()
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var c := here + Vector2i(dx, dy)
			if not arena.grid.in_bounds(c.x, c.y) or not arena.grid.is_floor_v(c):
				continue
			var steps := Pathfinder.value_at(arena.grid, fighter.field, c)
			if steps < 0 or steps > 2 or not _fits(fighter, target, c, low, high, arena):
				continue
			var score := arena.randf_unit()
			if c != here:
				score += 0.6
			# Hors de sa ligne, ses tirs doivent tourner : on s'y met.
			var there := target.cell()
			if c.x != there.x and c.y != there.y:
				score += 0.5
			if score > best_score:
				best_score = score
				best = c
	if best_score == -INF:
		# Rien dans la bande : trop près d'un héros de contact, on recule d'une case.
		best = _step_away(fighter, target, arena)
	fighter.strafe_cell = best
	fighter.strafe_until = arena.elapsed + lerpf(ArenaRules.STRAFE_MIN, ArenaRules.STRAFE_MAX, arena.randf_unit())
	return best


## Cette case tient-elle dans la bande de portée, libre et hors de danger ?
static func _fits(fighter: ArenaFighter, target: ArenaFighter, c: Vector2i, low: int, high: int, arena: ArenaMatch) -> bool:
	var d := _distance_from(target, c)
	if d < low or d > high:
		return false
	if is_dangerous(fighter, c, arena):
		return false
	for other in arena.fighters:
		if other != fighter and other.alive() and other.cell() == c:
			return false
	return true


static func _step_away(fighter: ArenaFighter, target: ArenaFighter, arena: ArenaMatch) -> Vector2i:
	var here := fighter.cell()
	var best := here
	var best_distance := _distance_from(target, here)
	for c in arena.grid.floor_neighbors(here):
		var d := _distance_from(target, c)
		if d > best_distance and not is_dangerous(fighter, c, arena):
			best_distance = d
			best = c
	return best


## Distance de chemin de `target` à une case, par son champ à lui ; à vol d'oiseau s'il n'en a pas encore.
static func _distance_from(target: ArenaFighter, c: Vector2i) -> int:
	if target.field.is_empty():
		var gap := c - target.cell()
		return absi(gap.x) + absi(gap.y)
	return Pathfinder.value_at(target.mover.grid, target.field, c)


## Une case où un sort adverse frappe : une zone posée par un adversaire, ou un météore annoncé.
static func is_dangerous(fighter: ArenaFighter, c: Vector2i, arena: ArenaMatch) -> bool:
	for other in fighter.opponents:
		if not other.alive():
			continue
		for zone in other.combat._zones:
			var ability: Ability = zone["ability"]
			var centre: Vector2i = zone["cell"]
			if _chebyshev(c, centre) <= maxi(1, int(ceil(ability.radius))):
				return true
	for danger in arena.dangers:
		if int(danger["team"]) == fighter.team and _chebyshev(c, danger["cell"]) <= int(danger["reach"]):
			return true
	return false


## La case sûre la plus proche, à quatre pas au plus.
static func _safe_cell(fighter: ArenaFighter, arena: ArenaMatch) -> Vector2i:
	var here := fighter.cell()
	var best := here
	var best_steps := 99
	for dy in range(-4, 5):
		for dx in range(-4, 5):
			var c := here + Vector2i(dx, dy)
			if not arena.grid.in_bounds(c.x, c.y) or not arena.grid.is_floor_v(c):
				continue
			var steps := Pathfinder.value_at(arena.grid, fighter.field, c)
			if steps < 0 or steps >= best_steps or is_dangerous(fighter, c, arena):
				continue
			best_steps = steps
			best = c
	return best


static func _chebyshev(a: Vector2i, b: Vector2i) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))


## UN TIR PART VERS LUI. S'il le voit venir (`DODGE_SPELL`, `DODGE_ATTACK`) et que son pas de côté
## est prêt, il sort de la ligne : une case perpendiculaire à l'arrivée du tir, libre et sûre. Sans
## case où aller, contre un sort, il lève son bouclier s'il en a un de prêt : il PARE au lieu d'esquiver.
static func incoming(victim: ArenaFighter, shooter: ArenaFighter, ability: Ability, path: Array,
		duration: float, arena: ArenaMatch) -> void:
	if not victim.can_act() or victim.lost_left > 0.0 or victim.dodge_left > 0.0:
		return
	if arena.elapsed < victim.dodge_ready_at or duration < ArenaRules.DODGE_REACTION:
		return
	var spell := ability != shooter.stats.attack
	if arena.randf_unit() > (ArenaRules.DODGE_SPELL if spell else ArenaRules.DODGE_ATTACK):
		return
	var side := _dodge_cell(victim, path, arena)
	if side == Vector2i(-1, -1):
		if spell:
			_parry(victim)
		return
	victim.dodge_cell = side
	victim.dodge_left = clampf(duration + 0.05, ArenaRules.DODGE_TIME, 0.6)
	victim.dodge_ready_at = arena.elapsed + ArenaRules.DODGE_COOLDOWN


static func _dodge_cell(victim: ArenaFighter, path: Array, arena: ArenaMatch) -> Vector2i:
	var from := victim.mover.decision_cell()
	var heading := Vector2i.ZERO
	if path.size() >= 2:
		var gap: Vector2i = path[-1] - path[-2]
		heading = Vector2i(signi(gap.x), signi(gap.y))
	var sides: Array[Vector2i] = []
	if heading == Vector2i.ZERO or (heading.x != 0 and heading.y != 0):
		sides = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	else:
		sides = [Vector2i(heading.y, heading.x), Vector2i(-heading.y, -heading.x)]
	var best := Vector2i(-1, -1)
	var best_score := -INF
	for side in sides:
		var c := from + side
		if not victim.mover.can_walk(c) or path.has(c) or is_dangerous(victim, c, arena):
			continue
		var taken := false
		for other in arena.fighters:
			if other != victim and other.alive() and other.cell() == c:
				taken = true
		if taken:
			continue
		# Vers là où il allait, de préférence.
		var score := arena.randf_unit()
		if not victim.goal_field.is_empty():
			score -= 0.3 * float(Pathfinder.value_at(arena.grid, victim.goal_field, c))
		if score > best_score:
			best_score = score
			best = c
	return best


static func _parry(victim: ArenaFighter) -> void:
	for ability in victim.stats.abilities:
		if ability == null or not victim.combat.can_use(ability):
			continue
		if ability.kind in [Ability.Kind.SHIELD, Ability.Kind.GUARD, Ability.Kind.MAGMA_SCALES]:
			if victim.combat.use(ability, victim.context):
				return


static func _steer_dodge(fighter: ArenaFighter) -> void:
	var mover := fighter.mover
	var from := mover.decision_cell()
	var gap := fighter.dodge_cell - from
	if from == fighter.dodge_cell or absi(gap.x) + absi(gap.y) != 1:
		# Arrivé, ou parti trop loin pour que ce pas ait encore un sens : il attend la fin de l'esquive.
		mover.desired_direction = Vector2i.ZERO if from == fighter.dodge_cell else mover.desired_direction
		return
	mover.desired_direction = gap


static func _steer(fighter: ArenaFighter) -> void:
	var mover := fighter.mover
	var from := mover.decision_cell()
	if fighter.goal_field.is_empty() or from == fighter.goal:
		mover.desired_direction = Vector2i.ZERO
		return
	var step := Pathfinder.step_toward(mover.grid, fighter.goal_field, from)
	# Le dernier pas sur la case d'un adversaire est refusé, comme pour les créatures.
	if step != Vector2i.ZERO:
		for other in fighter.opponents:
			if other.alive() and other.cell() == from + step:
				step = Vector2i.ZERO
				break
	mover.desired_direction = step


## Le sort à lancer : l'attaque dès qu'une cible est à portée, puis, serré de près, l'Extra s'il
## est chargé ou le meilleur sort ; la fuite quand il est presque mort.
static func _cast(fighter: ArenaFighter, arena: ArenaMatch) -> void:
	var combat := fighter.combat
	var context := fighter.context
	var stats := fighter.stats
	if stats.attack != null and combat.find_target(stats.attack, context) >= 0:
		# Plus lente qu'en campagne (`ATTACK_EXTRA`) : la recharge du jeu, plus le temps d'arène.
		if combat.use(stats.attack, context) and stats.attack.charges <= 1:
			combat._cooldowns[stats.attack.id] = combat.cooldown_left(stats.attack) + ArenaRules.ATTACK_EXTRA
	var nearest := _nearest_opponent(fighter)
	var distance := _distance(fighter, nearest)
	if nearest == null or distance < 0 or distance > CAST_REACH:
		return
	if fighter.health.ratio() < RETREAT_BELOW and distance <= THREAT_RADIUS and stats.escape != null:
		if combat.use(stats.escape, context):
			return
	# L'Éveil, dès qu'il est chargé et qu'un adversaire est là — sauf pour l'équipe du joueur, à qui
	# revient cette décision.
	# Jamais pendant une rengaine : changer de forme la défait (la Nuit écarlate restait sans fin).
	if fighter.awakening != null and arena.auto_awakens(fighter) and fighter.awakening.can_begin() \
			and fighter.combat._sheathe.is_empty():
		if arena.awaken(fighter):
			return
	var target := fighter.focus if fighter.focus != null and fighter.focus.alive() else nearest
	if stats.ultimate != null and fighter.kills.available():
		if fighter.ultimate_ready_since < 0.0:
			fighter.ultimate_ready_since = arena.elapsed
		if _ultimate_moment(fighter, arena, target) and combat.use(stats.ultimate, context):
			fighter.kills.spend()
			fighter.ultimate_ready_since = -1.0
			return
	else:
		fighter.ultimate_ready_since = -1.0
	_use_best_ability(fighter, arena, target)


## L'EXTRA AU BON MOMENT, et non dès qu'il est chargé : quand il prend deux adversaires ou plus, quand
## il peut achever (cible blessée ou tenue), en duel sur une cible entamée, ou en dernier recours quand
## le héros va tomber. Au bout de `ULTIMATE_PATIENCE`, il part quand même : gardé trop longtemps, il ne
## sert à rien.
static func _ultimate_moment(fighter: ArenaFighter, arena: ArenaMatch, target: ArenaFighter) -> bool:
	var ultimate := fighter.stats.ultimate
	var reach := maxi(CAST_REACH, maxi(ultimate.range, int(ceil(ultimate.radius))))
	var close := 0
	var standing := 0
	for other in fighter.opponents:
		if not other.alive():
			continue
		standing += 1
		var d := _distance(fighter, other)
		if d >= 0 and d <= reach:
			close += 1
	if close >= 2:
		return true
	if fighter.health.ratio() < ArenaRules.ULTIMATE_LAST_STAND:
		return true
	if arena.elapsed - fighter.ultimate_ready_since >= ArenaRules.ULTIMATE_PATIENCE:
		return true
	if target == null:
		return false
	var d := _distance(fighter, target)
	if d < 0 or d > reach:
		return false
	if target.health.ratio() <= ArenaRules.ULTIMATE_FINISH or _controlled(target):
		return true
	return standing == 1 and target.health.ratio() <= ArenaRules.ULTIMATE_DUEL


## LES COMBOS : sur une cible libre, le contrôle d'abord (étourdir, ralentir, enchaîner) ; sur une cible
## tenue, le plus gros coup d'abord. Le plus gros coup ATTEND un contrôle qui sera prêt dans
## `COMBO_WAIT` secondes, mais jamais plus de `COMBO_HOLD_MAX` : un sort gardé sans fin est un sort
## perdu. Se protéger quand il est bas passe avant tout, comme avant.
static func _use_best_ability(fighter: ArenaFighter, arena: ArenaMatch, target: ArenaFighter) -> void:
	var combat := fighter.combat
	var context := fighter.context
	var hurt := fighter.health.ratio() <= 0.5
	var defensive: Array[Ability] = []
	var control: Array[Ability] = []
	var damage: Array[Ability] = []
	for ability in fighter.stats.abilities:
		if ability == null or not combat.can_use(ability):
			continue
		if ability.self_cost > 0 and hurt:
			continue
		if ability.kind in [Ability.Kind.SHIELD, Ability.Kind.HEAL, Ability.Kind.HOURGLASS,
				Ability.Kind.TRANSFUSION, Ability.Kind.GUARD, Ability.Kind.MAGMA_SCALES, Ability.Kind.COIN]:
			defensive.append(ability)
		elif controls(ability):
			control.append(ability)
		else:
			damage.append(ability)
	if hurt:
		for ability in defensive:
			if combat.use(ability, context):
				return
	var held := target != null and _controlled(target)
	if not held:
		for ability in control:
			if combat.use(ability, context):
				fighter.combo_hold_since = -1.0
				return
	damage.sort_custom(func(a: Ability, b: Ability) -> bool: return a.damage > b.damage)
	var attack_damage := fighter.stats.attack.damage if fighter.stats.attack != null else 0
	var wait := not held and _control_soon(fighter)
	for ability in damage:
		var big := ability == damage[0] and ability.damage >= int(ceil(attack_damage * ArenaRules.COMBO_BIG))
		if big and wait:
			if fighter.combo_hold_since < 0.0:
				fighter.combo_hold_since = arena.elapsed
			if arena.elapsed - fighter.combo_hold_since < ArenaRules.COMBO_HOLD_MAX:
				continue
		if combat.use(ability, context):
			if big:
				fighter.combo_hold_since = -1.0
			return
	for ability in control:
		if combat.use(ability, context):
			return
	for ability in defensive:
		if combat.use(ability, context):
			return


## Un sort de contrôle : il étourdit, fige, ralentit, aveugle, enferme ou ramène.
static func controls(ability: Ability) -> bool:
	if ability.kind in [Ability.Kind.TIME_STOP, Ability.Kind.CAGES, Ability.Kind.HOOK,
			Ability.Kind.SOUL_CHAINS, Ability.Kind.GAOL, Ability.Kind.POSSESS]:
		return true
	return ability.stun_seconds > 0.0 or ability.chain_stun > 0.0 or ability.snap_stun > 0.0 \
		or ability.slam_stun > 0.0 or ability.end_blast_stun > 0.0 or ability.entry_freeze > 0.0 \
		or ability.clock_bomb_stun > 0.0 or ability.blind_seconds > 0.0 or ability.snare > 0.0 \
		or (ability.slow_duration > 0.0 and ability.slow_factor < 0.9)


## Un de ses contrôles sera-t-il prêt sous peu ?
static func _control_soon(fighter: ArenaFighter) -> bool:
	for ability in fighter.stats.abilities:
		if ability != null and controls(ability) and fighter.combat.cooldown_left(ability) <= ArenaRules.COMBO_WAIT:
			return true
	return false


## Tenu : étourdi, ralenti ou perdu. C'est le moment du gros coup.
static func _controlled(other: ArenaFighter) -> bool:
	return other != null and (other.stun_left > 0.0 or other.slow_left > 0.0 or other.lost_left > 0.0)


## LE CHOIX DE LA CIBLE, trois fois par seconde : parmi les adversaires à portée de combat, le plus
## blessé, puis le plus proche, et d'abord celui qu'un allié vise déjà ou qui est tenu. La cible reste
## un peu collante : changer d'avis à chaque décision dispersait les coups. `find_target` la préfère au
## plus proche par `CombatContext.focus`.
static func _choose_focus(fighter: ArenaFighter) -> void:
	var reach := maxi(_attack_reach(fighter), CAST_REACH) + 2
	var best: ArenaFighter = null
	var best_score := INF
	for other in fighter.opponents:
		if not other.alive():
			continue
		var d := _distance(fighter, other)
		if d < 0 or d > reach:
			continue
		var score := other.health.ratio() + ArenaRules.FOCUS_PER_CELL * float(d)
		if _controlled(other):
			score -= ArenaRules.FOCUS_HELD
		if other == fighter.focus:
			score -= ArenaRules.FOCUS_STICKY
		for ally in fighter.allies:
			if ally.alive() and ally.focus == other:
				score -= ArenaRules.FOCUS_TEAM
		if score < best_score:
			best_score = score
			best = other
	fighter.focus = best
	fighter.context.focus = fighter.opponents.find(best) if best != null else -1


static func _attack_reach(fighter: ArenaFighter) -> int:
	var attack := fighter.stats.attack
	if attack == null:
		return 1
	return maxi(1, maxi(attack.range, int(ceil(attack.radius))))


static func _nearest_opponent(fighter: ArenaFighter) -> ArenaFighter:
	var best: ArenaFighter = null
	var best_distance := 1 << 30
	for other in fighter.opponents:
		if not other.alive():
			continue
		var d := _distance(fighter, other)
		if d >= 0 and d < best_distance:
			best_distance = d
			best = other
	return best


static func _weakest(group: Array[ArenaFighter]) -> ArenaFighter:
	var best: ArenaFighter = null
	for other in group:
		if other.alive() and (best == null or other.health.ratio() < best.health.ratio()):
			best = other
	return best


static func _distance(fighter: ArenaFighter, other: ArenaFighter) -> int:
	if other == null or fighter.field.is_empty():
		return -1
	return Pathfinder.value_at(fighter.mover.grid, fighter.field, other.cell())


static func _distance_to_heart(arena: ArenaMatch, other: ArenaFighter) -> int:
	return Pathfinder.value_at(arena.grid, arena.heart_field, other.cell())
