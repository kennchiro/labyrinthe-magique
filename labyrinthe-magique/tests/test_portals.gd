extends SceneTree

## Vérifie la règle des 20 % en la MESURANT, et non en relisant le code.
##   godot --headless --path . --script res://tests/test_portals.gd
##
## Le risque avec une règle probabiliste, c'est de croire qu'elle est appliquée
## alors qu'un filtre mal posé la fausse. Ici on tire des dizaines de milliers
## de téléportations et on compte ce qui sort réellement.

const MAZES := 40
const DRAWS_PER_MAZE := 300

var _failures: Array[String] = []


func _init() -> void:
	for config in LevelConfig.all_levels():
		_measure_player_rule(config)
	_test_enemy_rule()
	_test_cooldown_and_invulnerability()

	print("")
	if _failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT")
	else:
		print("❌  %d ÉCHEC(S) :" % _failures.size())
		for f in _failures:
			print("   - ", f)
	quit(0 if _failures.is_empty() else 1)


func _fail(msg: String) -> void:
	if _failures.size() < 15:
		_failures.append(msg)


# --- La règle des 20 %, mesurée -------------------------------------------------

func _measure_player_rule(config: LevelConfig) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	var draws := 0
	var gains := 0
	var over_ceiling := 0
	var unavoidable := 0
	var self_teleports := 0
	var invalid := 0

	for m in MAZES:
		var grid := MazeGenerator.generate(config, 8000 + m)
		var empty_field := PackedInt32Array()
		for i in DRAWS_PER_MAZE:
			var from: Vector2i = grid.portals[rng.randi_range(0, grid.portals.size() - 1)]
			var current := grid.distance_at(from)
			var choice := PortalNetwork.pick_for_player(grid, from, rng, empty_field)
			var destination: Vector2i = choice["cell"]
			draws += 1

			if not grid.portals.has(destination):
				invalid += 1
			if destination == from:
				self_teleports += 1
			var arrival := grid.distance_at(destination)
			if arrival <= int(current * PortalNetwork.ADVANTAGE_FACTOR):
				gains += 1
			# Le plafond n'est parfois PAS atteignable : si le portail de départ
			# est plus proche de la maison que tous les autres, n'importe quelle
			# destination le dépasse. On sépare donc le cas structurel du vrai
			# dépassement — seul ce dernier serait un bug.
			if PortalNetwork.is_pure_gamble(grid, from):
				unavoidable += 1
			elif arrival > int(current * PortalNetwork.MAX_SETBACK_FACTOR):
				over_ceiling += 1

	var gain_rate := float(gains) / float(draws) * 100.0
	print("%s : %d tirages · %.1f%% de vrai gain (cible 20%%) · %d dépassements du plafond · %.1f%% de paris structurellement perdants" % [
		config.level_name, draws, gain_rate, over_ceiling,
		float(unavoidable) / float(draws) * 100.0,
	])

	if invalid > 0:
		_fail("%s : %d destinations qui ne sont pas des portails" % [config.level_name, invalid])
	if self_teleports > 0:
		_fail("%s : %d téléportations sur place" % [config.level_name, self_teleports])
	if gain_rate < 12.0 or gain_rate > 28.0:
		_fail("%s : taux de gain réel de %.1f%%, hors de la fourchette visée" % [config.level_name, gain_rate])
	# Zéro tolérance : dès qu'une destination sous le plafond existe, elle doit
	# être choisie.
	if over_ceiling > 0:
		_fail("%s : %d téléportations au-delà du plafond alors qu'une destination valide existait" % [config.level_name, over_ceiling])


# --- Les ennemis ne réapparaissent jamais sur le joueur --------------------------

func _test_enemy_rule() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var config := LevelConfig.for_stage(2)
	var taken := 0
	var too_close := 0
	var smart := 0

	for m in MAZES:
		var grid := MazeGenerator.generate(config, 9000 + m)
		var sources: Array[Vector2i] = [grid.player_spawn]
		var player_field := Pathfinder.distance_field(grid, sources)
		for i in DRAWS_PER_MAZE:
			var from: Vector2i = grid.portals[rng.randi_range(0, grid.portals.size() - 1)]
			var destination := PortalNetwork.pick_for_enemy(grid, from, rng, player_field)
			if destination == Vector2i.ZERO:
				continue
			taken += 1
			var gap := Pathfinder.value_at(grid, player_field, destination)
			if gap >= 0 and gap < PortalNetwork.ENEMY_SAFE_RADIUS:
				too_close += 1
			if gap >= 0 and gap <= 12:
				smart += 1

	var use_rate := float(taken) / float(MAZES * DRAWS_PER_MAZE) * 100.0
	print("ennemis : %.0f%% des portails croisés sont empruntés · %d sorties à moins de %d cases du joueur · %d%% de sorties menaçantes" % [
		use_rate, too_close, PortalNetwork.ENEMY_SAFE_RADIUS,
		int(float(smart) / float(maxi(taken, 1)) * 100.0),
	])
	if too_close > 0:
		_fail("%d ennemis réapparaissent collés au joueur (mort instantanée injuste)" % too_close)


# --- Pas d'aller-retour infini ---------------------------------------------------

func _test_cooldown_and_invulnerability() -> void:
	var config := LevelConfig.for_stage(1)
	var grid := MazeGenerator.generate(config, 555)
	var system := TeleportSystem.new(grid, 12345)
	var mover := GridMover.new(grid, grid.portals[0], 5.0)
	var no_enemies: Array[Vector2i] = []

	if not system.try_teleport_player(mover, no_enemies):
		_fail("cooldown : la première téléportation a échoué")
		return
	if system.try_teleport_player(mover, no_enemies):
		_fail("cooldown : téléportation immédiate autorisée — aller-retour infini possible")
	if not system.is_invulnerable(mover):
		_fail("invulnérabilité : absente juste après la téléportation")

	# On avance le temps jusqu'à expiration des deux minuteurs.
	for i in 120:
		system.update(1.0 / 60.0)
	if system.is_invulnerable(mover):
		_fail("invulnérabilité : toujours active après 2 s")
	if not system.can_teleport(mover):
		_fail("cooldown : toujours bloqué après 2 s")
	else:
		print("cooldown 1,5 s et invulnérabilité 0,6 s : OK")
