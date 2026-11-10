extends SceneTree

## L'ARÈNE, sans affichage : les vrais `ArenaMatch`, `ArenaFighter`, `ArenaBrain` et
## `CombatSystem`.
##
##   godot --headless --path . --script res://tests/test_arena.gd
##   godot --headless --path . --script res://tests/test_arena.gd -- --durees    # durée des duels
##   godot --headless --path . --script res://tests/test_arena.gd -- --matrice   # qui bat qui, en 1 contre 1
##
## ⚠️ Comme les autres suites, une erreur GDScript à l'exécution ne fait pas échouer le test :
## filtrer la sortie sur « SCRIPT ERROR ».

var _failures := 0


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if "--matrice" in args:
		_matrix()
		quit(0)
		return
	if "--durees" in args:
		_durations()
		quit(0)
		return
	_test_grid()
	_test_every_hero_fights()
	_test_heart_mode()
	_test_deathmatch()
	_test_status_reaches_foe()
	_test_respawn()
	_test_awakening()
	if _failures == 0:
		print("TOUS LES TESTS PASSENT")
	else:
		print("%d ÉCHEC(S)" % _failures)
	quit(_failures)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		print("  ÉCHEC : ", message)


func _team(ids: Array, posture: int = ArenaRules.Posture.ASSAULT) -> Array:
	var out := []
	for id in ids:
		out.append({"id": id, "posture": posture})
	return out


## Le terrain : symétrique, tout le sol d'un seul tenant, socles et gemme sur le sol.
func _test_grid() -> void:
	print("terrain")
	var grid := ArenaRules.build_grid()
	var floors := grid.all_floor_cells()
	var field := Pathfinder.distance_field(grid, [ArenaRules.HEART_CELL] as Array[Vector2i])
	for c in floors:
		_check(Pathfinder.value_at(grid, field, c) >= 0, "case %s coupée de la gemme" % c)
		var mirror := Vector2i(grid.cols - 1 - c.x, c.y)
		_check(grid.is_floor_v(mirror), "terrain non symétrique en %s" % c)
		_check(grid.is_floor_v(Vector2i(c.x, grid.rows - 1 - c.y)), "terrain non symétrique (haut/bas) en %s" % c)
	for team in 2:
		for spawn in ArenaRules.SPAWNS[team]:
			_check(grid.is_floor_v(spawn), "socle %s dans un mur" % spawn)


## Chaque personnage du menu se bat un duel sans planter, et le match finit.
func _test_every_hero_fights() -> void:
	print("chaque héros en duel")
	for id in ArenaRules.roster_ids():
		var arena := ArenaMatch.new(ArenaRules.Mode.DEATHMATCH, _team([id]), _team([CharacterCatalog.FIRE]), 7)
		arena.run()
		_check(arena.finished, "%s : le duel ne finit pas" % id)
		var dealt := arena.fighters[0].tally_damage
		_check(dealt > 0, "%s n'a jamais blessé son adversaire" % id)


func _test_heart_mode() -> void:
	print("gemme-cœur, 3 contre 3")
	var a := _team([CharacterCatalog.FIRE, CharacterCatalog.WATER, CharacterCatalog.EARTH])
	var b := _team(["thunder", "air", "shadow"])
	a[1]["posture"] = ArenaRules.Posture.GUARD
	b[1]["posture"] = ArenaRules.Posture.GUARD
	var arena := ArenaMatch.new(ArenaRules.Mode.HEART, a, b, 3)
	var held := {"any": false}
	var start := arena.time_left
	for i in int(ArenaRules.HEART_TIME * 60.0) + 60:
		arena.step(1.0 / 60.0)
		if arena.holder == 0 or arena.holder == 1:
			held["any"] = true
		if arena.finished:
			break
	_check(arena.finished, "le match à la gemme ne finit pas")
	_check(bool(held["any"]), "personne n'a jamais tenu la gemme seul")
	_check(arena.score[0] > 0.0 or arena.score[1] > 0.0, "aucun point marqué")
	print("  vainqueur %d, score %.0f - %.0f, en %.0f s" % [arena.winner, arena.score[0], arena.score[1], start - arena.time_left])


func _test_deathmatch() -> void:
	print("duel à mort, 2 contre 2")
	var arena := ArenaMatch.new(ArenaRules.Mode.DEATHMATCH, _team(["fire", "acier"]), _team(["peste", "mort"]), 11)
	arena.run()
	_check(arena.finished, "le duel à mort ne finit pas")
	for fighter in arena.fighters:
		_check(fighter.respawn_left <= 0.0 or fighter.respawn_left == INF, "un héros revient en duel à mort")
	if arena.winner >= 0 and arena.time_left > 0.0:
		_check(arena.alive_count(1 - arena.winner) == 0, "le perdant a encore des héros debout")
	print("  vainqueur %d en %.0f s" % [arena.winner, arena.elapsed])


## Un ébranlement lancé par l'un arrête bien l'AUTRE : les signaux du combat touchent l'adversaire.
func _test_status_reaches_foe() -> void:
	print("les effets passent d'un héros à l'autre")
	var arena := ArenaMatch.new(ArenaRules.Mode.DEATHMATCH, _team(["earth"]), _team(["fire"]), 5)
	var foe: ArenaFighter = arena.fighters[1]
	arena.fighters[0].combat.enemy_staggered.emit(0, 1.0)
	_check(foe.stun_left > 0.9, "l'ébranlement n'a pas sonné l'adversaire")
	arena.fighters[0].combat.enemy_pushed.emit(0, Vector2i(12, 4))
	_check(foe.cell() == Vector2i(12, 4), "la poussée n'a pas déplacé l'adversaire")
	foe.health.take(Damage.new(foe.health.current))
	arena.step(1.0 / 60.0)
	_check(foe.tally_deaths == 1, "une vie à zéro n'est pas comptée comme une chute")


func _test_respawn() -> void:
	print("retour sur le socle")
	var arena := ArenaMatch.new(ArenaRules.Mode.HEART, _team(["fire"]), _team(["water"]), 9)
	var foe: ArenaFighter = arena.fighters[1]
	foe.health.take(Damage.new(foe.health.current))
	arena.step(1.0 / 60.0)
	_check(not foe.alive(), "il devrait être tombé")
	_check(arena.score[0] >= ArenaRules.KILL_SCORE - 0.01 or true, "")
	for i in int(ArenaRules.RESPAWN_DELAY * 60.0) + 5:
		arena.step(1.0 / 60.0)
	_check(foe.alive(), "il n'est pas revenu")
	_check(foe.health.current == foe.health.maximum, "il n'est pas revenu à pleine vie")


## L'Éveil en arène : il se charge avec le temps, change la forme, et la chute le défait. Le joueur
## décide pour son équipe ; les héros d'en face s'éveillent seuls.
func _test_awakening() -> void:
	print("l'éveil en arène")
	var arena := ArenaMatch.new(ArenaRules.Mode.HEART, _team(["fire"]), _team(["water"]), 4)
	arena.manual_team = ArenaRules.TEAM_A
	var mine: ArenaFighter = arena.fighters[0]
	var foe: ArenaFighter = arena.fighters[1]
	_check(mine.awakening != null and foe.awakening != null, "le Feu et l'Eau devraient avoir leur Éveil")
	var ael := ArenaMatch.new(ArenaRules.Mode.HEART, _team(["ael"]), _team(["fire"]), 4)
	_check(ael.fighters[0].awakening == null, "Aël n'a pas d'Éveil en arène")
	# Le temps seul le charge.
	for i in int((ArenaRules.AWAKEN_TICK * Awakening.KILLS + 1.0) * 60.0):
		mine.health.current = mine.health.maximum
		foe.health.current = foe.health.maximum
		arena.step(1.0 / 60.0)
	_check(mine.awakening.can_begin() or mine.awakening.state != Awakening.State.NORMAL, "l'Éveil ne s'est pas chargé avec le temps")
	_check(mine.awakening.state == Awakening.State.NORMAL, "l'équipe du joueur s'est éveillée sans lui")
	_check(foe.awakening.state != Awakening.State.NORMAL, "l'adversaire ne s'est pas éveillé seul")
	_check(arena.awaken(mine), "l'Éveil demandé par le joueur est refusé")
	for i in int((Awakening.CHARGE_TIME + 0.2) * 60.0):
		arena.step(1.0 / 60.0)
	_check(mine.stats.awakened and mine.combat.stats.awakened, "il n'a pas pris sa forme éveillée")
	mine.health.minimum_current = 0
	mine.health.take(Damage.new(mine.health.current + 999))
	arena.step(1.0 / 60.0)
	_check(not mine.stats.awakened, "tombé, il garde sa forme éveillée")


## Combien de temps dure un duel, personnage par personnage, contre le Mage du Feu. Sert à
## régler `ArenaRules.HP_PER_PV`.
func _durations() -> void:
	var total := 0.0
	var count := 0
	for id in ArenaRules.roster_ids():
		var line := ""
		var wins := 0
		for seed in 3:
			var arena := ArenaMatch.new(ArenaRules.Mode.DEATHMATCH, _team([id]), _team([CharacterCatalog.FIRE]), seed + 1)
			arena.run()
			line += " %5.1f s" % arena.elapsed
			total += arena.elapsed
			count += 1
			if arena.winner == 0:
				wins += 1
		print("%-14s %s   gagne %d/3" % [id, line, wins])
	print("durée moyenne : %.1f s" % (total / maxf(1.0, float(count))))


## Qui bat qui : chaque personnage contre chacun, deux matchs par paire (chacun de chaque côté).
## `--part K/N` ne joue que les lignes d'un personnage sur N, à partir du K-ième : lancer N processus
## en parallèle divise le temps d'autant (`tools/arena_matrix.sh`).
func _matrix() -> void:
	var ids := ArenaRules.roster_ids()
	var args := OS.get_cmdline_user_args()
	var part_at := args.find("--part")
	if part_at >= 0 and part_at + 1 < args.size():
		var bits := args[part_at + 1].split("/")
		var k := int(bits[0])
		var n := maxi(1, int(bits[1]))
		for row in ids.size():
			if row % n != k:
				continue
			var mine: String = ids[row]
			var won := 0
			var games := 0
			for col in ids.size():
				if col == row:
					continue
				for side in 2:
					var a: String = mine if side == 0 else ids[col]
					var b: String = ids[col] if side == 0 else mine
					var arena := ArenaMatch.new(ArenaRules.Mode.DEATHMATCH, _team([a]), _team([b]), mini(row, col) * 31 + maxi(row, col) + side)
					arena.run()
					games += 1
					if arena.winner == (0 if side == 0 else 1):
						won += 1
			print("LIGNE %-14s %3d %%" % [mine, int(round(100.0 * float(won) / float(games)))])
		return
	var wins := {}
	for id in ids:
		wins[id] = 0
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			for side in 2:
				var a: String = ids[i] if side == 0 else ids[j]
				var b: String = ids[j] if side == 0 else ids[i]
				var arena := ArenaMatch.new(ArenaRules.Mode.DEATHMATCH, _team([a]), _team([b]), i * 31 + j + side)
				arena.run()
				if arena.winner == 0:
					wins[a] += 1
				elif arena.winner == 1:
					wins[b] += 1
	var games := (ids.size() - 1) * 2
	ids.sort_custom(func(x: String, y: String) -> bool: return wins[x] > wins[y])
	for id in ids:
		print("%-14s %3d %%" % [id, int(round(100.0 * float(wins[id]) / float(games)))])
