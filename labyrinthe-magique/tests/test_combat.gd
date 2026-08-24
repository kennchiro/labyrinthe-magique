extends SceneTree

## Règles de combat, vérifiées sans ouvrir le jeu :
##   godot --headless --path . --script res://tests/test_combat.gd
##
## Health, KillSystem et CombatSystem n'ont aucune dépendance au moteur de scène.
## Ce que ce test protège, ce sont les promesses faites au joueur : un coup fait
## le nombre de dégâts annoncé, une explosion ne traverse pas une haie, un geste
## refusé ne coûte rien, et l'Extra Power arrive exactement au nombre de kills
## annoncé.

const DT := 1.0 / 60.0

var _failures: Array[String] = []


func _init() -> void:
	_test_health()
	_test_shield()
	_test_kill_system()
	_test_catalog()
	_test_no_dominance()
	_test_cooldown()
	_test_unlocks()
	_test_trajectory()
	_test_projectile_damage()
	_test_refusal_costs_nothing()
	_test_blast_respects_walls()
	_test_zone_damages_over_time()
	_test_wall_and_blink()
	_test_lairs_as_targets()
	_test_lair_boss_levels()
	_test_stage_unlocks()
	_test_elemental_traits()
	_test_summons()
	_test_rosters()
	_test_flat_index()
	_test_demo_free_use()
	_test_zone_snare()
	_test_charges()
	_test_volcanic_ultimate()
	_test_ultimate_thresholds()
	_test_ability_summaries()
	_test_water_promises()
	_test_empowerment()
	_test_shield_expiry()
	_test_lightning_chain()
	_test_thunder_field()
	_test_storm()
	_test_sky_judgement()

	print("")
	if _failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT")
	else:
		print("❌  %d ÉCHEC(S) :" % _failures.size())
		for f in _failures:
			print("   - ", f)
	quit(0 if _failures.is_empty() else 1)


func _fail(message: String) -> void:
	_failures.append(message)


# --- Points de vie ---------------------------------------------------------------

func _test_health() -> void:
	var health := Health.new(100)
	if health.take(Damage.new(30)) != 30 or health.current != 70:
		_fail("30 dégâts sur 100 PV ne laissent pas 70")
	health.take(Damage.new(1000))
	if health.is_alive() or health.current != 0:
		_fail("un coup surdimensionné ne descend pas les PV à zéro pile")
	# Un mort ne reprend pas de dégâts : sans ça, deux projectiles en vol sur la
	# même cible compteraient deux kills.
	if health.take(Damage.new(10)) != 0:
		_fail("un ennemi mort encaisse encore des dégâts")

	var healed := Health.new(50)
	healed.take(Damage.new(20))
	if healed.heal(999) != 20 or healed.current != 50:
		_fail("le soin dépasse le maximum de PV")
	print("points de vie : dégâts, mort définitive et soin plafonné : OK")


func _test_shield() -> void:
	var health := Health.new(100)
	health.add_shield(40)
	health.take(Damage.new(30))
	if health.current != 100 or health.shield != 10:
		_fail("le bouclier n'absorbe pas avant les PV (PV %d, bouclier %d)" % [health.current, health.shield])
	health.take(Damage.new(30))
	if health.current != 80 or health.shield != 0:
		_fail("le débordement du bouclier n'atteint pas les PV correctement")
	print("bouclier : absorbe d'abord, déborde ensuite : OK")


# --- Kills et ultime -------------------------------------------------------------

func _test_kill_system() -> void:
	var kills := KillSystem.new(5)
	for i in 4:
		kills.register_kill()
	if kills.available():
		_fail("l'ultime est prêt à 4 kills alors qu'il en faut 5")
	kills.register_kill()
	if not kills.available():
		_fail("l'ultime n'est pas prêt à 5 kills")
	if not kills.spend() or kills.available():
		_fail("l'ultime reste disponible après avoir été utilisé")
	if kills.kills != 5:
		_fail("le total de kills a été remis à zéro : il ne doit jamais redescendre")
	for i in 5:
		kills.register_kill()
	if not kills.available() or kills.kills != 10:
		_fail("le second ultime ne se recharge pas après 5 nouveaux kills")
	print("kills : ultime à 5, rechargeable, total cumulé : OK")


func _test_catalog() -> void:
	var characters := CharacterCatalog.all()
	# 7 mages élémentaires + l'Invocateur (ajouté par la session voisine — il ne
	# se bat pas lui-même, il délègue à ses invocations). Le compte protège
	# contre un doublon ou une disparition, pas contre l'évolution du roster.
	if characters.size() != 8:
		_fail("le catalogue contient %d personnages au lieu de 8" % characters.size())
	var seen := {}
	for character in characters:
		if seen.has(character.id):
			_fail("identifiant de personnage dupliqué : %s" % character.id)
		seen[character.id] = true
		if character.attack == null:
			_fail("%s n'a pas d'attaque de base" % character.id)
		if character.abilities.size() != 3:
			_fail("%s a %d compétences au lieu de 3" % [character.id, character.abilities.size()])
		if character.ultimate == null or not character.ultimate.is_ultimate:
			_fail("%s n'a pas d'ultime" % character.id)
		# La fuite n'est pas un luxe : sans elle, un couloir bouché est une
		# impasse et non une erreur du joueur.
		if character.escape == null or character.escape.kind != Ability.Kind.BLINK:
			_fail("%s n'a pas de sort de fuite" % character.id)
		if character.action_bar().size() != 6:
			_fail("%s : barre d'action de %d emplacements au lieu de 6" % [
				character.id, character.action_bar().size()])
		if character.base_health < 1 or character.move_speed <= 0.0:
			_fail("%s a des statistiques impossibles" % character.id)
		# L'attaque de base et la fuite n'ont pas de recharge prohibitive : elles
		# doivent rester disponibles en permanence, y compris au stage 1 où
		# aucune potion n'existe.
		if character.attack.cooldown > 1.0:
			_fail("l'attaque de base de %s met %.1f s à revenir" % [
				character.id, character.attack.cooldown])
		if character.escape.cooldown > 12.0:
			_fail("la fuite de %s met %.1f s à revenir" % [
				character.id, character.escape.cooldown])
	if CharacterCatalog.by_id("inconnu").id != CharacterCatalog.default_id():
		_fail("un identifiant inconnu ne retombe pas sur le personnage par défaut")
	# Chaque mage doit avoir ses planches découpées : un personnage jouable sans
	# sprite serait choisissable et invisible.
	for character in characters:
		if not DirAccess.dir_exists_absolute("res://assets/characters/" + character.id):
			_fail("%s n'a pas de planche découpée dans assets/characters/" % character.id)
	print("catalogue : %d personnages, chacun avec attaque + 3 sorts + ultime + planche : OK"
		% characters.size())


## AUCUN MAGE NE DOIT EN DOMINER UN AUTRE.
##
## « Dominer » a ici un sens précis : être au moins aussi bon sur les QUATRE
## axes mesurables — points de vie, vitesse, dégâts par seconde, portée — et
## strictement meilleur sur au moins un. Un tel personnage rend l'autre inutile :
## personne ne choisira jamais le dominé, et l'écran de sélection devient un
## piège pour qui ne lit pas les chiffres.
##
## Ce test a une histoire : le Mage de la Foudre et le Mage de l'Air, écrits en
## dernier, dominaient respectivement le Sorcier des Ténèbres et le Mage de
## l'Eau. La simulation d'équilibrage ne l'avait PAS signalé — elle mesurait des
## taux de victoire bruités par douze parties, où l'écart se noyait. Une
## comparaison de statistiques, elle, est exacte et instantanée.
func _test_no_dominance() -> void:
	var characters := CharacterCatalog.all()
	for strong in characters:
		for weak in characters:
			if strong.id == weak.id:
				continue
			# L'Invocateur est VOLONTAIREMENT faible sur ces quatre axes : sa
			# puissance vit dans ses invocations, que ces axes ne mesurent pas.
			# Le comparer ici, c'est peser un général au poids de son épée.
			if CharacterCatalog.INVOCATEUR in [strong.id, weak.id]:
				continue
			var axes := [
				[float(strong.base_health), float(weak.base_health)],
				[strong.move_speed, weak.move_speed],
				[_dps(strong), _dps(weak)],
				[float(strong.attack.range), float(weak.attack.range)],
			]
			var better := 0
			var worse := 0
			for axis in axes:
				if axis[0] > axis[1] + 0.01:
					better += 1
				elif axis[0] < axis[1] - 0.01:
					worse += 1
			if worse == 0 and better > 0:
				_fail("%s domine %s : meilleur sur %d axes, moins bon sur aucun" % [
					strong.display_name, weak.display_name, better])
	print("équilibre : aucun des %d mages n'en domine un autre" % characters.size())


func _dps(character: CharacterStats) -> float:
	return float(character.attack.damage) / maxf(0.05, character.attack.cooldown)


# --- Système de combat -----------------------------------------------------------

func _context(stats: CharacterStats) -> Array:
	var grid := MazeGenerator.generate(LevelConfig.for_stage(2), 4242)
	var health := Health.new(stats.base_health)
	var combat := CombatSystem.new(grid, stats, health)
	var context := CombatContext.new(grid)
	context.player_cell = grid.player_spawn
	context.player_facing = Vector2i.DOWN
	context.player_field = Pathfinder.distance_field(grid, [grid.player_spawn] as Array[Vector2i])
	return [grid, combat, context, health]


## Case praticable à exactement `steps` cases du joueur, en distance de chemin.
func _cell_at(grid: MazeGrid, field: PackedInt32Array, steps: int) -> Vector2i:
	for cell in grid.all_floor_cells():
		if Pathfinder.value_at(grid, field, cell) == steps:
			return cell
	return Vector2i(-1, -1)


func _add_enemy(context: CombatContext, cell: Vector2i, hp: int) -> void:
	context.enemy_cells.append(cell)
	context.enemy_health.append(Health.new(hp))


## La recharge est désormais la SEULE limite d'un sort : le mana a disparu avec
## la règle « un sort débloqué l'est pour toujours ». Ce test protège cette
## promesse — un sort acquis doit revenir tout seul, sans ressource à trouver.
func _test_cooldown() -> void:
	var stats := CharacterCatalog.fire()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 5), 400)

	var skill: Ability = stats.abilities[0]
	if not combat.can_use(skill):
		_fail("un sort acquis n'est pas utilisable alors que sa recharge est prête")
	if not combat.use(skill, context):
		_fail("le sort est refusé alors que la cible est là")
	if combat.use(skill, context):
		_fail("le sort repart immédiatement, sans recharge")
	for i in int(skill.cooldown / DT) + 4:
		combat.update(DT, context)
	if not combat.can_use(skill):
		_fail("le sort n'est pas revenu après sa recharge")
	print("recharge : seule limite d'un sort, %.0f s puis il revient" % skill.cooldown)


## Le déblocage, lui, est tenu par Progress — et il est DÉFINITIF.
func _test_unlocks() -> void:
	var progress := Progress.new()
	if progress.skill_unlocked(1):
		_fail("le premier sort est utilisable avant d'avoir trouvé une potion")
	if not progress.skill_unlocked(0) or not progress.skill_unlocked(4):
		_fail("la frappe ou la fuite est verrouillée : elles ne s'achètent pas")
	if progress.unlock_next_skill() != 1 or not progress.skill_unlocked(1):
		_fail("la première potion ne débloque pas le premier sort")
	if progress.skill_unlocked(2):
		_fail("une seule potion débloque plus d'un sort")
	progress.unlock_next_skill()
	progress.unlock_next_skill()
	if not progress.skill_unlocked(3):
		_fail("trois potions ne débloquent pas les trois sorts")
	if progress.unlock_next_skill() != -1:
		_fail("une quatrième potion débloque un quatrième sort inexistant")
	print("déblocage : une potion = un sort, acquis définitivement")


## Le trajet du projectile suit les COULOIRS. Un tir qui coupe à travers une
## haie viserait juste mais mentirait à l'œil.
func _test_trajectory() -> void:
	var parts := _context(CharacterCatalog.shadow())
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var target := _cell_at(grid, context.player_field, 9)
	if target.x < 0:
		return

	var path := combat.trajectory(context.player_cell, target)
	if path.is_empty() or path[0] != context.player_cell or path[-1] != target:
		_fail("la trajectoire ne relie pas le joueur à sa cible")
		return
	for i in range(1, path.size()):
		if not grid.is_floor_v(path[i]):
			_fail("la trajectoire traverse un mur en %s" % path[i])
			return
		var step: Vector2i = path[i] - path[i - 1]
		if absi(step.x) + absi(step.y) != 1:
			_fail("la trajectoire saute une case entre %s et %s" % [path[i - 1], path[i]])
			return
	print("trajectoire : %d cases, contiguë, sans traverser un mur : OK" % path.size())


func _test_projectile_damage() -> void:
	var stats := CharacterCatalog.shadow()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var target := _cell_at(grid, context.player_field, 8)
	_add_enemy(context, target, 100)

	# Dictionary et non un entier : une lambda GDScript capture les variables
	# locales par VALEUR, un compteur incrémenté dedans resterait à zéro.
	var events := {"kills": 0}
	combat.enemy_killed.connect(func(_i: int) -> void: events["kills"] += 1)

	if not combat.use(stats.attack, context):
		_fail("l'attaque de base est refusée sur une cible à 8 cases")
	if context.enemy_health[0].current != 100:
		_fail("l'ennemi perd des PV AVANT l'arrivée du projectile")

	# Vol du projectile : l'impact ne doit tomber qu'au bout du trajet.
	var elapsed := 0.0
	while context.enemy_health[0].current == 100 and elapsed < 3.0:
		combat.update(DT, context)
		elapsed += DT
	var expected := 8.0 / CombatSystem.PROJECTILE_SPEED
	if absf(elapsed - expected) > 0.12:
		_fail("temps de vol %.2f s au lieu de %.2f s" % [elapsed, expected])
	if context.enemy_health[0].current != 100 - stats.attack.damage:
		_fail("l'attaque n'inflige pas ses %d dégâts (PV restants %d)" % [
			stats.attack.damage, context.enemy_health[0].current])

	# Jusqu'à la mort : le kill doit être signalé une seule fois.
	for i in 600:
		combat.update(DT, context)
		if combat.can_use(stats.attack):
			combat.use(stats.attack, context)
		if not context.enemy_health[0].is_alive():
			break
	for i in 120:
		combat.update(DT, context)
	if context.enemy_health[0].is_alive():
		_fail("l'ennemi survit à une pluie d'attaques de base")
	if events["kills"] != 1:
		_fail("%d signaux de mort pour un seul ennemi" % events["kills"])
	print("projectile : vol de %.2f s, %d dégâts à l'impact, un seul kill signalé : OK" % [
		expected, stats.attack.damage])


func _test_refusal_costs_nothing() -> void:
	var stats := CharacterCatalog.shadow()
	var parts := _context(stats)
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]

	# Aucun ennemi : le tir ne part pas et ne coûte rien.
	if combat.use(stats.attack, context):
		_fail("un projectile part sans le moindre ennemi")
	if combat.cooldown_left(stats.attack) > 0.0:
		_fail("un tir refusé a quand même déclenché la recharge")
	var skill: Ability = stats.abilities[0]
	# La rune est une ZONE : elle part même sans cible, c'est un piège. En
	# revanche l'attaque, elle, exige une cible. On vérifie la distinction.
	if not combat.use(skill, context):
		_fail("une zone refuse de se poser faute de cible, alors que c'est un piège")
	if combat.cooldown_left(skill) <= 0.0:
		_fail("une zone posée ne déclenche pas sa recharge")
	print("geste refusé : aucune recharge déclenchée : OK")


func _test_blast_respects_walls() -> void:
	var stats := CharacterCatalog.shadow()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]

	# Un voisin DE L'AUTRE CÔTÉ d'une haie : collé au joueur à vol d'oiseau,
	# très loin par les couloirs. Il ne doit RIEN prendre.
	var behind_hedge := Vector2i(-1, -1)
	for direction in MazeGrid.NEIGHBORS:
		var wall: Vector2i = context.player_cell + direction
		var beyond: Vector2i = context.player_cell + direction * 2
		if grid.is_wall(wall.x, wall.y) and grid.is_floor_v(beyond):
			if Pathfinder.value_at(grid, context.player_field, beyond) > 6:
				behind_hedge = beyond
				break
	var close := _cell_at(grid, context.player_field, 2)
	_add_enemy(context, close, 100)
	if behind_hedge.x >= 0:
		_add_enemy(context, behind_hedge, 100)

	var blast: Ability = stats.abilities[2]
	combat.use(blast, context)
	if context.enemy_health[0].current >= 100:
		_fail("l'explosion ne touche pas un ennemi à 2 cases")
	if behind_hedge.x >= 0 and context.enemy_health[1].current < 100:
		_fail("l'explosion traverse une haie")
	if behind_hedge.x < 0:
		print("explosion : rayon en distance de chemin (aucune case de test derrière une haie)")
	else:
		print("explosion : touche à 2 cases, ne traverse pas la haie : OK")


func _test_zone_damages_over_time() -> void:
	var stats := CharacterCatalog.fire()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 500)

	var zone: Ability = stats.abilities[1]
	if not combat.use(zone, context):
		_fail("la zone ne se pose pas")
	var before: int = context.enemy_health[0].current
	for i in int(1.0 / DT):
		combat.update(DT, context)
	var dealt: int = before - context.enemy_health[0].current
	# Les dégâts sont annoncés PAR SECONDE : après une seconde, on doit y être
	# à un tick près.
	if absi(dealt - zone.damage) > zone.damage / 2 + 1:
		_fail("la zone inflige %d dégâts en 1 s au lieu de %d" % [dealt, zone.damage])

	# Et elle s'arrête à la fin de sa durée.
	for i in int(zone.duration / DT) + 10:
		combat.update(DT, context)
	var after: int = context.enemy_health[0].current
	for i in int(1.0 / DT):
		combat.update(DT, context)
	if context.enemy_health[0].current != after:
		_fail("la zone continue de brûler après sa durée")
	print("zone : %d dégâts par seconde pendant %.0f s puis extinction : OK" % [zone.damage, zone.duration])


func _test_wall_and_blink() -> void:
	var stats := CharacterCatalog.earth()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]

	# Le mur se dresse derrière le mage : on l'oriente donc vers une case libre.
	var wall_ability: Ability = stats.abilities[1]
	var placed := false
	for direction in MazeGrid.NEIGHBORS:
		var behind: Vector2i = context.player_cell - direction
		if grid.is_floor_v(behind) and not grid.is_occupied(behind):
			context.player_facing = direction
			placed = combat.use(wall_ability, context)
			if placed:
				if not grid.is_wall(behind.x, behind.y):
					_fail("le mur de pierre ne bouche pas la case")
				for i in int(wall_ability.duration / DT) + 10:
					combat.update(DT, context)
				if not grid.is_floor_v(behind):
					_fail("le mur de pierre ne disparaît jamais")
			break
	if not placed:
		print("mur de pierre : aucune case libre derrière le mage sur cette graine")
	else:
		print("mur de pierre : bouche la case %.0f s puis se retire : OK" % wall_ability.duration)

	# La translation s'arrête devant un mur au lieu de traverser.
	var blink := Ability.make({"id": "test_blink", "kind": Ability.Kind.BLINK, "range": 30,
		"cooldown": 0.0, "mana_cost": 0})
	var arrival := {"cell": Vector2i(-1, -1)}
	combat.blink_performed.connect(func(_from: Vector2i, to: Vector2i) -> void: arrival["cell"] = to)
	context.player_facing = Vector2i.RIGHT
	combat.use(blink, context)
	var landing: Vector2i = arrival["cell"]
	if landing.x >= 0:
		if not grid.is_floor_v(landing):
			_fail("la translation dépose le mage dans un mur")
		if grid.is_floor_v(landing + Vector2i.RIGHT):
			_fail("la translation s'arrête alors que le couloir continue")
		print("translation : glisse jusqu'au mur sans le traverser : OK")


# --- Repaires destructibles ------------------------------------------------------

## Les maisons d'ennemis partagent les tableaux du contexte avec les créatures.
## Ce que ce test protège, c'est la seule règle qui les distingue : un ennemi à
## portée passe TOUJOURS avant une maison, si près soit-elle. Sans elle, le mage
## tirerait sur une façade pendant qu'un gobelin lui monte dessus.
func _test_lairs_as_targets() -> void:
	var stats := CharacterCatalog.fire()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var attack: Ability = stats.attack

	var near := _cell_at(grid, context.player_field, 2)
	var far := _cell_at(grid, context.player_field, 6)
	# La maison est la PLUS PROCHE des deux cibles : c'est le cas piège.
	_add_enemy(context, far, 100)
	context.structures_from = context.enemy_cells.size()
	_add_enemy(context, near, 400)

	if combat.find_target(attack, context) != 0:
		_fail("le tir choisit la maison collée au mage plutôt que l'ennemi à portée")

	# Plus d'ennemi vivant : la maison redevient une cible légitime.
	context.enemy_health[0].take(Damage.new(999))
	if combat.find_target(attack, context) != 1:
		_fail("sans ennemi vivant, la maison n'est pas ciblée")

	# Et elle encaisse vraiment : sinon elle serait un décor invulnérable.
	var before: int = context.enemy_health[1].current
	combat.use(attack, context)
	for i in 240:
		combat.update(DT, context)
	if context.enemy_health[1].current >= before:
		_fail("un tir encaissé par une maison ne lui retire aucun point de vie")


## Les deux verrous de la campagne, et seulement eux : dernier épisode des
## stages 3 et 9. Une règle de fin de chapitre qui déborderait sur les niveaux
## ordinaires transformerait chaque partie en démolition.
func _test_lair_boss_levels() -> void:
	for level in LevelConfig.all_levels():
		var expected := level.episode == LevelConfig.EPISODES_PER_STAGE \
			and level.stage in LevelConfig.LAIR_BOSS_STAGES
		if level.must_destroy_lairs != expected:
			_fail("stage %d ép. %d : destruction des repaires = %s, attendu %s"
				% [level.stage, level.episode, level.must_destroy_lairs, expected])
		if level.must_destroy_lairs and level.lair_health < 300:
			_fail("stage %d : une maison à %d PV tombe trop vite pour être un enjeu"
				% [level.stage, level.lair_health])


## Ce que le menu a le droit de proposer. La règle qui compte est le « plus un » :
## sans lui, un joueur qui vient de boucler un stage ne pourrait pas choisir le
## suivant depuis le menu — celui-là même où il va.
func _test_stage_unlocks() -> void:
	# Aucune progression fabriquée ne doit pouvoir écrire sur le disque. Le
	# défaut inverse a déjà poussé la partie d'un joueur au stage 5 en lançant
	# simplement cette suite.
	if Progress.new().persistent or Progress.everything().persistent:
		_fail("une progression fabriquée en mémoire a le droit d'écrire la sauvegarde")

	var fresh := Progress.new()
	if not fresh.stage_unlocked(1) or fresh.stage_unlocked(2):
		_fail("une progression neuve n'ouvre pas exactement le stage 1")
	if fresh.episode_unlocked(1, 2):
		_fail("le second épisode du stage 1 est ouvert avant d'avoir gagné le premier")

	var mid := Progress.new()
	mid.reach(2, 1)
	if not mid.episode_unlocked(2, 2):
		_fail("stage 2 épisode 1 gagné : le second épisode reste fermé")
	if not mid.stage_unlocked(3):
		_fail("le stage suivant n'est pas proposé après une victoire")
	if mid.stage_unlocked(4):
		_fail("la campagne s'ouvre de deux crans au lieu d'un")
	if mid.episode_unlocked(3, 2):
		_fail("le second épisode d'un stage jamais joué est proposé")

	var deep := Progress.new()
	deep.reach(5, 2)
	for stage in range(1, 6):
		for episode in [1, 2]:
			if not deep.episode_unlocked(stage, episode):
				_fail("stage %d ép. %d fermé alors que le stage 5 est bouclé" % [stage, episode])


## Le menu choisit un (stage, épisode) ; le GameManager ne connaît qu'un index
## PLAT. Si la traduction se décale d'un cran, choisir « stage 3 » lance le
## stage 2 — un défaut qu'on ne voit qu'en jouant, et qu'on met longtemps à
## croire.
## Les invocations de l'Invocateur : elles naissent, chassent, tuent, et
## disparaissent à l'heure dite. Tout en headless — c'est la garantie que la
## simulation d'équilibrage les voit exactement comme le jeu.
func _test_summons() -> void:
	var stats := CharacterCatalog.invocateur()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var target := _cell_at(grid, context.player_field, 6)
	_add_enemy(context, target, 60)

	var events := {"spawned": 0, "expired": 0, "kills": 0}
	combat.summon_spawned.connect(func(_i: int, _k: String, _p: Vector2) -> void:
		events["spawned"] += 1)
	combat.summon_expired.connect(func(_i: int) -> void: events["expired"] += 1)
	combat.enemy_killed.connect(func(_i: int) -> void: events["kills"] += 1)

	var imps: Ability = stats.abilities[0]
	if not combat.use(imps, context):
		_fail("l'invocation des diablotins est refusée")
	if events["spawned"] != imps.summon_count:
		_fail("%d créatures nées pour %d demandées" % [events["spawned"], imps.summon_count])

	# Les diablotins doivent trouver l'ennemi à 6 cases et l'abattre — bien
	# avant leurs 120 s de vie. 25 s de marge : à 4,6 cases/s, l'aller dure
	# moins de 2 s, et 60 PV tombent en 6 coups.
	var elapsed := 0.0
	while context.enemy_health[0].is_alive() and elapsed < 25.0:
		combat.update(DT, context)
		elapsed += DT
	if context.enemy_health[0].is_alive():
		_fail("les diablotins n'ont pas abattu un ennemi immobile en 25 s")
	if events["kills"] != 1:
		_fail("%d kills signalés — les invocations doivent nourrir l'ultime" % events["kills"])

	# L'expiration : à 120 s pile, plus personne.
	var remaining := imps.duration - elapsed + 1.0
	var steps := int(remaining / DT)
	for i in steps:
		combat.update(DT, context)
	if combat.summon_count() != 0:
		_fail("%d créature(s) encore en vie après leurs 120 s" % combat.summon_count())
	if events["expired"] != imps.summon_count:
		_fail("%d expirations signalées pour %d créatures" % [
			events["expired"], imps.summon_count])

	# Le plafond : au-delà de MAX_SUMMONS, la plus ancienne cède la place.
	combat = CombatSystem.new(grid, stats, Health.new(10))
	context.enemy_health[0] = Health.new(100000)
	for i in 3:
		combat.use(Ability.make({
			"id": "imps_%d" % i, "kind": Ability.Kind.SUMMON,
			"summon_id": "imp", "summon_count": 2, "duration": 120.0,
		}), context)
	if combat.summon_count() != CombatSystem.MAX_SUMMONS:
		_fail("plafond : %d créatures au lieu de %d" % [
			combat.summon_count(), CombatSystem.MAX_SUMMONS])
	print("invocations : naissance, chasse, kill compté, mort à 120 s, plafond à %d : OK"
		% CombatSystem.MAX_SUMMONS)


## Chaque chapitre POSE RÉELLEMENT sa nouveauté, et chaque espèce du bestiaire
## entre en jeu quelque part.
##
## L'effectif d'un stage plafonne alors que le roster grandit : au stage 10, huit
## poursuivants pour onze espèces. Piocher dans l'ordre d'apparition faisait donc
## tomber les dernières — le Chevalier Noir et le Golem de Givre n'entraient
## JAMAIS en jeu, ni à l'épisode 1 ni au 2, alors qu'ils avaient leurs planches,
## leurs points de vie et leur ligne dans la fiche du bestiaire. Un défaut qu'on
## ne voit pas en jouant : il faut compter.
func _test_rosters() -> void:
	var seen := {}
	for stage in range(1, LevelConfig.STAGE_COUNT + 1):
		var newcomers: Array = Bestiary.NEWCOMERS[stage - 1]
		for episode in [1, 2]:
			var config := LevelConfig.for_stage(stage, episode)
			var used := {}
			for i in config.enemy_count:
				var id := config.species_at(i)
				used[id] = true
				seen[id] = true
			for id in newcomers:
				if not used.has(str(id)):
					_fail("stage %d épisode %d ne pose pas sa nouveauté (%s)" % [
						stage, episode, Bestiary.display_name(str(id))])
			for id in used:
				if not config.species.has(id):
					_fail("stage %d pose %s, qui n'est pas dans son roster" % [
						stage, Bestiary.display_name(str(id))])

	for group in Bestiary.NEWCOMERS:
		for id in group:
			if not seen.has(str(id)):
				_fail("%s n'entre jamais en jeu" % Bestiary.display_name(str(id)))
	print("rosters : les %d espèces entrent en jeu, chaque chapitre pose sa nouveauté : OK"
		% seen.size())


func _test_flat_index() -> void:
	var levels := LevelConfig.all_levels()
	if levels.size() != LevelConfig.STAGE_COUNT * LevelConfig.EPISODES_PER_STAGE:
		_fail("la campagne ne compte pas %d niveaux" %
			(LevelConfig.STAGE_COUNT * LevelConfig.EPISODES_PER_STAGE))
		return
	for stage in range(1, LevelConfig.STAGE_COUNT + 1):
		for episode in range(1, LevelConfig.EPISODES_PER_STAGE + 1):
			var level := levels[LevelConfig.flat_index(stage, episode)]
			if level.stage != stage or level.episode != episode:
				_fail("index plat de (%d, %d) tombe sur (%d, %d)"
					% [stage, episode, level.stage, level.episode])


# --- Traits élémentaires ----------------------------------------------------------

## Un sort d'essai : une explosion immédiate, sans temps de vol — c'est le
## déclencheur de trait le plus simple à mesurer.
func _trait_blast(element: Element.Kind, damage: int = 20) -> Ability:
	return Ability.make({"id": "essai_%d" % element, "kind": Ability.Kind.BLAST,
		"element": element, "damage": damage, "radius": 1.2, "cooldown": 0.0})


## Ce que ce bloc protège : chaque élément marque ses coups D'UN effet propre,
## et les traits ne se composent jamais entre eux. C'est toute la différence
## entre sept mages et sept teintes du même mage.
func _test_elemental_traits() -> void:
	# FEU — la brûlure ajoute ~30 % des dégâts, étalés.
	var parts := _context(CharacterCatalog.fire())
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 100)
	combat.use(_trait_blast(Element.Kind.FIRE), context)
	for i in 120:
		combat.update(DT, context)
	if context.enemy_health[0].current != 100 - 20 - 6:
		_fail("brûlure : attendu 74 PV après 20 de coup + 6 de feu, lu %d"
			% context.enemy_health[0].current)

	# EAU et TERRE — les signaux de statut, une seule fois chacun.
	parts = _context(CharacterCatalog.water())
	grid = parts[0]; combat = parts[1]; context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 400)
	var seen := {"soak": 0, "stagger": 0}
	combat.enemy_soaked.connect(func(_i: int, _d: float, _f: float) -> void: seen["soak"] += 1)
	combat.enemy_staggered.connect(func(_i: int, _d: float) -> void: seen["stagger"] += 1)
	combat.use(_trait_blast(Element.Kind.WATER), context)
	combat.use(_trait_blast(Element.Kind.EARTH), context)
	combat.use(_trait_blast(Element.Kind.EARTH), context)
	if seen["soak"] != 1:
		_fail("trempe : %d signal(s) au lieu de 1" % seen["soak"])
	# Le verrou anti-paralysie : deux ébranlements coup sur coup n'en font qu'un.
	if seen["stagger"] != 1:
		_fail("ébranlement : %d signal(s) — le verrou de 3 s ne tient pas" % seen["stagger"])

	# TÉNÈBRES — la ponction rend ~22 % des dégâts au mage.
	parts = _context(CharacterCatalog.shadow())
	grid = parts[0]; combat = parts[1]; context = parts[2]
	var caster: Health = parts[3]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 400)
	caster.take(Damage.new(2, Element.Kind.SHADOW, "test"))
	var before := caster.current
	combat.use(_trait_blast(Element.Kind.SHADOW, 20), context)
	if caster.current <= before:
		_fail("ponction : le mage des Ténèbres ne récupère rien")

	# FOUDRE — l'arc saute au voisin pour la moitié des dégâts.
	parts = _context(CharacterCatalog.thunder())
	grid = parts[0]; combat = parts[1]; context = parts[2]
	var near := _cell_at(grid, context.player_field, 1)
	_add_enemy(context, near, 100)
	var neighbour_field := Pathfinder.distance_field(grid, [near] as Array[Vector2i])
	_add_enemy(context, _cell_at(grid, neighbour_field, 2), 100)
	combat.use(_trait_blast(Element.Kind.THUNDER, 20), context)
	if context.enemy_health[1].current != 90:
		_fail("arc : le voisin devrait perdre 10 PV, lu %d" % (100 - context.enemy_health[1].current))

	# AIR — la bourrasque éloigne la cible le long du couloir.
	parts = _context(CharacterCatalog.air())
	grid = parts[0]; combat = parts[1]; context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 400)
	combat.use(_trait_blast(Element.Kind.AIR), context)
	var pushed := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[0])
	if pushed <= 1:
		_fail("bourrasque : l'ennemi est resté à %d case(s)" % pushed)

	# SUPRÊME — l'écho répète 40 % des dégâts, plus tard.
	parts = _context(CharacterCatalog.supreme())
	grid = parts[0]; combat = parts[1]; context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 100)
	combat.use(_trait_blast(Element.Kind.SUPREME, 20), context)
	if context.enemy_health[0].current != 80:
		_fail("écho : il frappe trop tôt")
	for i in 60:
		combat.update(DT, context)
	if context.enemy_health[0].current != 72:
		_fail("écho : attendu 72 PV après 20 + 8, lu %d" % context.enemy_health[0].current)

	# Les ZONES ne déclenchent aucun trait : un tick tous les 0,5 s ferait de
	# chaque statut une condition permanente.
	parts = _context(CharacterCatalog.fire())
	grid = parts[0]; combat = parts[1]; context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 400)
	var burns := {"count": 0}
	combat.enemy_burning.connect(func(_i: int, _d: float) -> void: burns["count"] += 1)
	combat.use(Ability.make({"id": "zone_essai", "kind": Ability.Kind.ZONE,
		"element": Element.Kind.FIRE, "damage": 10, "radius": 1.2,
		"duration": 2.0, "cooldown": 0.0}), context)
	for i in 150:
		combat.update(DT, context)
	if burns["count"] != 0:
		_fail("une zone de feu déclenche la brûlure (%d fois)" % burns["count"])

	# Les STRUCTURES ne reçoivent aucun trait : on ne repousse pas une maison.
	parts = _context(CharacterCatalog.air())
	grid = parts[0]; combat = parts[1]; context = parts[2]
	context.structures_from = 0
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 400)
	var moves := {"count": 0}
	combat.enemy_pushed.connect(func(_i: int, _c: Vector2i) -> void: moves["count"] += 1)
	combat.use(_trait_blast(Element.Kind.AIR), context)
	if moves["count"] != 0:
		_fail("une bourrasque a déplacé une maison")


## Le mode DÉMO n'a pas de recharge — et la campagne, elle, la garde. Ce test
## protège les deux moitiés de la promesse : un drapeau qui débraye les
## recharges partout viderait le jeu de sa gestion des sorts sans qu'aucune
## partie ne plante pour le signaler.
func _test_demo_free_use() -> void:
	var stats := CharacterCatalog.fire()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 5), 4000)
	var skill: Ability = stats.abilities[0]

	# Campagne : le second lancer est refusé, la recharge court.
	if not combat.use(skill, context):
		_fail("démo : le premier lancer est refusé alors que la cible est là")
	if combat.use(skill, context):
		_fail("campagne : le sort repart sans recharge")

	# Démo : autant de lancers qu'on veut, et la recharge affichée reste pleine.
	combat.free_use = true
	for i in 5:
		if not combat.use(skill, context):
			_fail("démo : le sort est refusé au lancer %d" % (i + 1))
			break
	if combat.cooldown_ratio(skill) < 1.0:
		_fail("démo : la barre de recharge n'est pas pleine")

	# Le terrain d'essai porte bien le drapeau, la campagne non.
	if not LevelConfig.demo().is_demo:
		_fail("le terrain d'essai n'est pas marqué comme démo")
	if LevelConfig.for_stage(1).is_demo:
		_fail("un stage de campagne est marqué comme démo")


## Le BRASIER PIÈGE de l'Aura ardente. Ce que ce test protège tient en une
## phrase : une créature prise doit ÊTRE LIBÉRÉE. Le piège tique deux fois par
## seconde pendant trente secondes ; sans verrou par créature, chaque tick la
## reprendrait et elle ne repartirait jamais — un sort qui retire un ennemi du
## jeu pour toujours, sans que rien ne plante pour le signaler.
func _test_zone_snare() -> void:
	var stats := CharacterCatalog.fire()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 4000)

	var aura: Ability = null
	for ability in stats.abilities:
		if ability.snare > 0.0:
			aura = ability
	if aura == null:
		_fail("aucune zone-piège dans le catalogue du Mage du Feu")
		return
	if aura.duration < 30.0:
		_fail("le brasier dure %.0f s au lieu de 30" % aura.duration)

	var holds := {"count": 0, "seconds": 0.0}
	var burns := {"count": 0, "seconds": 0.0}
	combat.enemy_staggered.connect(func(_i: int, d: float) -> void:
		holds["count"] += 1
		holds["seconds"] = d)
	combat.enemy_burning.connect(func(_i: int, d: float) -> void:
		burns["count"] += 1
		burns["seconds"] = d)

	combat.use(aura, context)
	# Six secondes sur place : le piège a tiqué douze fois.
	for i in 360:
		combat.update(DT, context)
	if holds["count"] != 1:
		_fail("le piège se réarme : %d immobilisations en 6 s (prison à vie)" % holds["count"])
	if absf(holds["seconds"] - 5.0) > 0.01:
		_fail("l'immobilisation dure %.1f s au lieu de 5" % holds["seconds"])
	if burns["count"] != 1 or absf(burns["seconds"] - 3.0) > 0.01:
		_fail("la brûlure de sortie : %d fois, %.1f s (attendu 1 fois, 3 s)"
			% [burns["count"], burns["seconds"]])

	# Passé le verrou (5 + 3 + 1 s de grâce), la créature peut être reprise :
	# le piège tient le terrain, il ne se vide pas après un seul passage.
	for i in 240:
		combat.update(DT, context)
	if holds["count"] < 2:
		_fail("le piège ne reprend plus personne après le premier passage")

	# « Sol embrasé » n'est PAS un piège : deux zones de feu qui retiendraient
	# toutes les deux ne se distingueraient plus l'une de l'autre.
	var plain: Ability = stats.abilities[1]
	if plain.snare > 0.0:
		_fail("%s retient aussi : les deux zones de feu font la même chose"
			% plain.display_name)


## Les CHARGES : cinq brasiers d'affilée, puis la recharge, puis les cinq
## reviennent d'un coup. Trois promesses distinctes, et chacune peut casser
## seule — d'où trois vérifications.
func _test_charges() -> void:
	var stats := CharacterCatalog.fire()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 4000)

	var aura: Ability = null
	for ability in stats.abilities:
		if ability.charges > 1:
			aura = ability
	if aura == null:
		_fail("aucun sort à charges dans le catalogue du Mage du Feu")
		return
	if aura.charges != 5:
		_fail("le brasier a %d charges au lieu de 5" % aura.charges)

	# 1. Cinq lancers passent, le sixième non.
	var fired := 0
	for i in 8:
		if combat.use(aura, context):
			fired += 1
		# Le petit délai entre charges s'écoule entre deux tentatives.
		for tick in 30:
			combat.update(DT, context)
	if fired != aura.charges:
		_fail("%d lancers d'affilée au lieu de %d" % [fired, aura.charges])
	if combat.charges_left(aura) != 0:
		_fail("il reste %d charge(s) après les avoir toutes dépensées"
			% combat.charges_left(aura))

	# 2. Tant qu'il restait une charge, le sort devait être PRÊT — c'est ce qui
	#    distingue un sort à charges d'un sort à recharge courte.
	if not combat.can_use(stats.attack):
		_fail("l'attaque de base est bloquée par la recharge du brasier")

	# 3. La recharge rend TOUTES les charges, pas une.
	for i in int(aura.cooldown / DT) + 30:
		combat.update(DT, context)
	if combat.charges_left(aura) != aura.charges:
		_fail("la recharge rend %d charge(s) au lieu de %d"
			% [combat.charges_left(aura), aura.charges])
	if not combat.can_use(aura):
		_fail("le brasier reste bloqué après sa recharge")

	# Un sort SANS charges garde son comportement d'origine : une charge, une
	# recharge. Le nouveau système ne doit rien changer aux six autres mages.
	var plain: Ability = stats.abilities[1]
	if combat.charges_left(plain) != -1:
		_fail("%s expose des charges alors qu'il n'en a pas" % plain.display_name)
	if not combat.use(plain, context):
		_fail("le sort ordinaire est refusé")
	if combat.use(plain, context):
		_fail("le sort ordinaire repart sans recharge")


## L'ULTIME VOLCANIQUE. Trois promesses, dont deux sont des EXCEPTIONS aux
## règles du jeu — c'est justement pour ça qu'elles ont besoin d'un test : une
## exception qui déborde sur les sorts ordinaires ne planterait rien, elle
## rendrait juste toutes les haies inutiles sans que personne ne le remarque.
func _test_volcanic_ultimate() -> void:
	var stats := CharacterCatalog.fire()
	var ultimate := stats.ultimate
	if not ultimate.pierces_walls:
		_fail("l'ultime du Feu ne traverse plus les murs")
	if ultimate.rain_count <= 0:
		_fail("l'ultime du Feu ne fait plus pleuvoir de météores")

	# 1. AUCUN autre sort du jeu ne perce les murs. C'est la promesse inverse,
	#    et c'est elle qui donne son prix à l'ultime.
	for character in CharacterCatalog.all():
		for ability in character.action_bar():
			if ability == null or ability.is_ultimate:
				continue
			if ability.pierces_walls:
				_fail("%s (%s) traverse les murs sans être un ultime"
					% [ability.display_name, character.display_name])
			if ability.rain_count > 0:
				_fail("%s fait pleuvoir sans être un ultime" % ability.display_name)

	# 2. Le souffle touche DERRIÈRE une haie — la seule chose du jeu qui le
	#    fasse. On place une cible hors d'atteinte par les couloirs mais proche
	#    à vol d'oiseau, et on vérifie qu'elle encaisse quand même.
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var walled := _cell_behind_hedge(grid, context.player_cell, ultimate.radius)
	if walled.x < 0:
		print("ultime volcanique : aucune case murée trouvée pour ce test")
	else:
		_add_enemy(context, walled, 4000)
		combat.use(ultimate, context)
		if context.enemy_health[0].current >= 4000:
			_fail("le souffle de l'ultime ne passe pas la haie")

	# 3. La pluie tombe ÉTALÉE dans le temps, pas d'un bloc : douze météores
	#    simultanées seraient un seul gros dégât, pas une pluie.
	var parts2 := _context(stats)
	var combat2: CombatSystem = parts2[1]
	var context2: CombatContext = parts2[2]
	var landings := {"count": 0, "first": -1.0, "last": -1.0}
	var clock := {"t": 0.0}
	combat2.meteor_landed.connect(func(_c: Vector2i, _a: Ability) -> void:
		landings["count"] += 1
		if landings["first"] < 0.0:
			landings["first"] = clock["t"]
		landings["last"] = clock["t"])
	combat2.use(ultimate, context2)
	for i in 400:
		clock["t"] = float(i) * DT
		combat2.update(DT, context2)
	if landings["count"] != ultimate.rain_count:
		_fail("%d météores tombées au lieu de %d"
			% [landings["count"], ultimate.rain_count])
	var window: float = landings["last"] - landings["first"]
	if window < ultimate.rain_duration * 0.4:
		_fail("les météores tombent en %.1f s : c'est un bloc, pas une pluie" % window)


## Case à portée À VOL D'OISEAU mais inatteignable par les couloirs dans ce
## rayon : exactement ce qu'un ultime doit pouvoir frapper et rien d'autre.
func _cell_behind_hedge(grid: MazeGrid, from: Vector2i, radius: float) -> Vector2i:
	var field := Pathfinder.distance_field(grid, [from] as Array[Vector2i])
	for cell in grid.all_floor_cells():
		if Vector2(cell - from).length() > radius:
			continue
		var walk := Pathfinder.value_at(grid, field, cell)
		if walk > radius + 3.0:
			return cell
	return Vector2i(-1, -1)


## LE SEUIL D'ULTIME SUIT LA CONSTITUTION : un mage fragile l'atteint plus tôt,
## un mage robuste le paie plus cher. Sans cette règle, les huit personnages
## exigeaient presque tous cinq kills et le compteur ne disait rien de celui
## qu'on jouait. Deux exceptions, chacune argumentée dans le catalogue.
func _test_ultimate_thresholds() -> void:
	# Trois exceptions, chacune argumentée dans le catalogue : l'ultime du
	# Suprême efface un stage, celui de l'Invocateur vient de ses créatures, et
	# celui de l'Eau est un ÉTAT de 30 s qui doit revenir souvent pour exister.
	var exceptions := {"supreme": 8, "invocateur": 6, "water": 2}
	for character in CharacterCatalog.all():
		var expected: int = exceptions.get(character.id, character.base_health + 1)
		if character.ultimate_required_kills != expected:
			_fail("%s : ultime à %d kills, attendu %d (constitution %d)"
				% [character.display_name, character.ultimate_required_kills,
					expected, character.base_health])

	# Le Mage du Feu a été réglé à la main sur demande : la règle doit lui
	# donner exactement ce chiffre, sinon elle a été écrite pour l'occasion.
	if CharacterCatalog.fire().ultimate_required_kills != 4:
		_fail("le Mage du Feu n'est plus à 4 kills")

	# Et les seuils doivent VARIER : une règle qui rendrait tout le monde égal
	# nous ramènerait au point de départ sans qu'aucun test ne s'en aperçoive.
	var seen := {}
	for character in CharacterCatalog.all():
		seen[character.ultimate_required_kills] = true
	if seen.size() < 3:
		_fail("les seuils d'ultime ne prennent que %d valeurs distinctes" % seen.size())


## La fiche de personnage doit MENTIONNER les particularités d'un sort : deux
## sorts aux mêmes chiffres ne se jouent pas pareil si l'un cloue sur place et
## l'autre traverse les murs. Un résumé muet là-dessus laisse le joueur choisir
## à l'aveugle.
func _test_ability_summaries() -> void:
	var fire := CharacterCatalog.fire()
	var brazier: Ability = fire.abilities[2]
	var text := brazier.summary()
	if not ("charges" in text and "cloue" in text):
		_fail("le résumé du brasier ne dit ni ses charges ni son piège : %s" % text)
	var ultimate := fire.ultimate.summary()
	if not ("MURS" in ultimate and "météores" in ultimate):
		_fail("le résumé de l'ultime ne dit ni les murs ni la pluie : %s" % ultimate)


## LE MAGE DE L'EAU TIENT SES PROMESSES.
##
## Trois de ses sorts annonçaient dans leur description un effet que le code ne
## produisait pas : le Cercle glacé « engluait » sans ralentir, le Geyser
## « régénérait » sans soigner, et la Vague « balayait le couloir devant » en
## explosant tout autour. Une description qui ment est pire qu'une description
## absente : le joueur construit sa tactique dessus.
func _test_water_promises() -> void:
	var stats := CharacterCatalog.water()

	# 1. LE GIVRE ralentit vraiment, et plus fort que la trempe de l'élément.
	var circle: Ability = null
	for ability in stats.abilities:
		if ability.slow_duration > 0.0:
			circle = ability
	if circle == null:
		_fail("le Cercle glacé ne ralentit toujours rien")
	else:
		if circle.slow_factor >= CombatSystem.SOAK_FACTOR:
			_fail("le givre (%.2f) ne ralentit pas plus que la trempe (%.2f)"
				% [circle.slow_factor, CombatSystem.SOAK_FACTOR])
		var parts := _context(stats)
		var grid: MazeGrid = parts[0]
		var combat: CombatSystem = parts[1]
		var context: CombatContext = parts[2]
		_add_enemy(context, _cell_at(grid, context.player_field, 1), 4000)
		var chills := {"count": 0, "factor": 1.0}
		combat.enemy_soaked.connect(func(_i: int, _d: float, f: float) -> void:
			chills["count"] += 1
			chills["factor"] = f)
		combat.use(circle, context)
		# Fenêtre PLUS COURTE que le verrou (durée du givre + 0,5 s), sinon une
		# seconde prise est légitime et le test se trompe de coupable.
		for i in 200:
			combat.update(DT, context)
		if chills["count"] != 1:
			_fail("le givre s'applique %d fois avant la fin du verrou" % chills["count"])
		# Et passé le verrou, la zone doit reprendre : elle tient le terrain dix
		# secondes, elle ne se vide pas après un seul passage.
		for i in 200:
			combat.update(DT, context)
		if chills["count"] < 2:
			_fail("le givre ne reprend plus personne après le premier passage")
		if absf(float(chills["factor"]) - circle.slow_factor) > 0.01:
			_fail("le givre annonce %.2f mais applique %.2f"
				% [circle.slow_factor, chills["factor"]])

	# 2. LE GEYSER soigne. On blesse le mage d'abord, sinon rien ne se voit.
	var parts2 := _context(stats)
	var combat2: CombatSystem = parts2[1]
	var context2: CombatContext = parts2[2]
	var caster: Health = parts2[3]
	if stats.ultimate.heal_self <= 0:
		_fail("le Geyser ne soigne toujours pas, malgré sa description")
	caster.take(Damage.new(2, Element.Kind.WATER, "test"))
	var before := caster.current
	combat2.use(stats.ultimate, context2)
	if caster.current <= before:
		_fail("le Geyser laisse le mage à %d PV" % caster.current)

	# 3. LA VAGUE DÉFERLE : elle avance devant le mage et frappe ce qu'elle
	#    traverse, elle n'explose pas autour de lui. Trois promesses distinctes,
	#    et la plus importante est la troisième — une vague qui frapperait tout
	#    d'un coup ne serait qu'un souffle sous un autre nom.
	var parts3 := _context(stats)
	var grid3: MazeGrid = parts3[0]
	var combat3: CombatSystem = parts3[1]
	var context3: CombatContext = parts3[2]
	var wave: Ability = stats.abilities[0]
	if wave.kind != Ability.Kind.WAVE:
		_fail("la Vague n'est pas un front qui déferle")
		return

	context3.player_facing = Vector2i.RIGHT
	var ahead := context3.player_cell + Vector2i.RIGHT
	var behind := context3.player_cell + Vector2i.LEFT
	if not grid3.is_floor_v(ahead) or not grid3.is_floor_v(behind):
		print("vague : pas de couloir droit pour ce test")
		return
	_add_enemy(context3, ahead, 4000)
	_add_enemy(context3, behind, 4000)

	# a) Rien n'est touché à l'instant du lancement : le front doit VOYAGER.
	combat3.use(wave, context3)
	if context3.enemy_health[0].current < 4000:
		_fail("la vague frappe avant d'avoir avancé : c'est une explosion")

	# b) Ce qui est DEVANT est emporté quand le front y arrive.
	for i in 90:
		combat3.update(DT, context3)
	if context3.enemy_health[0].current >= 4000:
		_fail("la vague n'emporte pas ce qui est sur son chemin")

	# c) EN FUYANT : le mage tourne le dos à son poursuivant, et la vague doit
	#    quand même partir vers LUI. C'est le défaut de la première version —
	#    elle suivait le regard, donc elle partait du mauvais côté au moment
	#    précis où l'on en avait besoin.
	var parts4 := _context(stats)
	var grid4: MazeGrid = parts4[0]
	var combat4: CombatSystem = parts4[1]
	var context4: CombatContext = parts4[2]
	var chaser := context4.player_cell + Vector2i.LEFT
	if grid4.is_floor_v(chaser) and grid4.is_floor_v(context4.player_cell + Vector2i.RIGHT):
		# Le mage FUIT vers la droite ; le poursuivant est à gauche.
		context4.player_facing = Vector2i.RIGHT
		_add_enemy(context4, chaser, 4000)
		combat4.use(wave, context4)
		for i in 90:
			combat4.update(DT, context4)
		if context4.enemy_health[0].current >= 4000:
			_fail("en fuyant, la vague part devant au lieu d'aller vers le poursuivant")

	# d) Et chaque ennemi n'encaisse QU'UNE FOIS. Sans mémoire des touchés, un
	#    ennemi resté dans le couloir prendrait un coup par case traversée.
	var taken: int = 4000 - context3.enemy_health[0].current
	if taken > wave.damage:
		_fail("la vague frappe %d fois le même ennemi (%d dégâts)"
			% [int(round(float(taken) / float(wave.damage))), taken])


## L'EXALTATION du Geyser : +10 sur chaque coup pendant 30 s.
##
## Le piège de ce genre de bonus est qu'il se MULTIPLIE sans qu'on s'en
## aperçoive : appliqué aux dégâts dérivés, il ajouterait +10 à chaque tic de
## brûlure, à chaque arc et à chaque écho. Rien ne planterait — les chiffres
## seraient juste faux, et l'équilibrage avec.
func _test_empowerment() -> void:
	var stats := CharacterCatalog.water()
	var ultimate := stats.ultimate
	if ultimate.empower_bonus <= 0:
		_fail("le Geyser n'exalte pas")
		return
	if absf(ultimate.empower_duration - 30.0) > 0.01:
		_fail("l'exaltation dure %.0f s au lieu de 30" % ultimate.empower_duration)

	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 9000)

	# 1. AVANT : le coup vaut ses dégâts nominaux.
	var probe := Ability.make({"id": "sonde", "kind": Ability.Kind.BLAST,
		"element": Element.Kind.WATER, "damage": 20, "radius": 1.2, "cooldown": 0.0})
	var before: int = context.enemy_health[0].current
	combat.use(probe, context)
	var plain: int = before - context.enemy_health[0].current
	if plain != 20:
		_fail("le coup de référence fait %d dégâts au lieu de 20" % plain)

	# 2. PENDANT : il vaut ses dégâts PLUS le bonus, une seule fois.
	combat.use(ultimate, context)
	if combat.empower_bonus() != ultimate.empower_bonus:
		_fail("l'exaltation annonce %d au lieu de %d"
			% [combat.empower_bonus(), ultimate.empower_bonus])
	before = context.enemy_health[0].current
	combat.use(probe, context)
	var boosted: int = before - context.enemy_health[0].current
	if boosted != 20 + ultimate.empower_bonus:
		_fail("le coup exalté fait %d dégâts au lieu de %d"
			% [boosted, 20 + ultimate.empower_bonus])

	# 3. APRÈS : elle retombe, et le coup redevient normal.
	for i in int(ultimate.empower_duration / DT) + 20:
		combat.update(DT, context)
	if combat.empower_bonus() != 0:
		_fail("l'exaltation ne retombe jamais")
	before = context.enemy_health[0].current
	combat.use(probe, context)
	if before - context.enemy_health[0].current != 20:
		_fail("le coup reste exalté après l'échéance")

	# 4. LE PIÈGE : le bonus ne touche PAS les dégâts dérivés. On le vérifie sur
	#    la brûlure du Feu, qui est le dérivé le plus facile à isoler.
	var fire := CharacterCatalog.fire()
	var burn_parts := _context(fire)
	var burn_grid: MazeGrid = burn_parts[0]
	var burn_combat: CombatSystem = burn_parts[1]
	var burn_context: CombatContext = burn_parts[2]
	_add_enemy(burn_context, _cell_at(burn_grid, burn_context.player_field, 1), 9000)
	var exalt := Ability.make({"id": "exalte", "kind": Ability.Kind.BLAST,
		"element": Element.Kind.WATER, "damage": 0, "radius": 0.1, "cooldown": 0.0,
		"empower_bonus": 10, "empower_duration": 30.0})
	burn_combat.use(exalt, burn_context)
	var hit := Ability.make({"id": "sonde_feu", "kind": Ability.Kind.BLAST,
		"element": Element.Kind.FIRE, "damage": 20, "radius": 1.2, "cooldown": 0.0})
	var start: int = burn_context.enemy_health[0].current
	burn_combat.use(hit, burn_context)
	for i in 200:
		burn_combat.update(DT, burn_context)
	# 30 de coup (20 + 10) puis la brûlure = 30 % des 30 dégâts infligés, en
	# trois tics. Le bonus ne doit s'ajouter à AUCUN de ces tics.
	var total: int = start - burn_context.enemy_health[0].current
	if total > 30 + 15:
		_fail("l'exaltation se multiplie sur la brûlure : %d dégâts au total" % total)


## LE BOUCLIER D'EAU EXPIRE. Signalé par l'utilisateur : « il ne fait rien ».
##
## Il faisait quelque chose — il absorbait — mais TROIS choses manquaient : sa
## durée était ignorée (posé, il tenait jusqu'à consommation, éventuellement une
## partie entière), rien ne l'affichait à l'écran, et rien ne le signalait au
## joueur. Ce test protège la première, la seule qui soit du domaine des règles.
func _test_shield_expiry() -> void:
	var stats := CharacterCatalog.water()
	var shield: Ability = null
	for ability in stats.abilities:
		if ability.kind == Ability.Kind.SHIELD:
			shield = ability
	if shield == null:
		_fail("le Mage de l'Eau n'a plus de bouclier")
		return
	if shield.duration <= 0.0:
		_fail("le bouclier n'a pas de durée")

	var parts := _context(stats)
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var caster: Health = parts[3]

	var fades := {"count": 0}
	combat.player_shield_faded.connect(func() -> void: fades["count"] += 1)
	combat.use(shield, context)
	if caster.shield != shield.damage:
		_fail("le bouclier absorbe %d au lieu de %d" % [caster.shield, shield.damage])

	# 1. Il tient pendant sa durée.
	for i in int((shield.duration - 0.5) / DT):
		combat.update(DT, context)
	if caster.shield <= 0:
		_fail("le bouclier tombe avant son échéance")

	# 2. Et il TOMBE à l'échéance — c'était le bug : il ne tombait jamais.
	for i in 80:
		combat.update(DT, context)
	if caster.shield != 0:
		_fail("le bouclier survit à son échéance : %d restants" % caster.shield)
	if fades["count"] != 1:
		_fail("la chute du bouclier n'est signalée qu'%d fois" % fades["count"])

	# 3. Vidé par les coups, il tombe AUSSI — sans quoi une coque à zéro
	#    resterait affichée et mentirait autant qu'une coque éternelle.
	var parts2 := _context(stats)
	var combat2: CombatSystem = parts2[1]
	var context2: CombatContext = parts2[2]
	var caster2: Health = parts2[3]
	var drained := {"count": 0}
	combat2.player_shield_faded.connect(func() -> void: drained["count"] += 1)
	combat2.use(shield, context2)
	caster2.take(Damage.new(shield.damage, Element.Kind.SHADOW, "test"))
	combat2.update(DT, context2)
	if drained["count"] != 1:
		_fail("un bouclier vidé par les coups ne se signale pas")
	# Et le mage n'a rien perdu : c'est tout l'intérêt de la coque.
	if caster2.current != caster2.maximum:
		_fail("le bouclier n'a pas absorbé : le mage est à %d PV" % caster2.current)


## LA CHAÎNE D'ÉCLAIRS CHAÎNE VRAIMENT.
##
## Elle s'appelait « Chaîne d'éclairs », promettait de sauter d'un ennemi à
## l'autre, et était une explosion circulaire. Trois promesses à tenir, et deux
## pièges silencieux à éviter : l'aller-retour entre deux voisins, et la chaîne
## qui ne s'épuise pas.
func _test_lightning_chain() -> void:
	var stats := CharacterCatalog.thunder()
	var chain: Ability = stats.abilities[0]
	if chain.kind != Ability.Kind.CHAIN:
		_fail("la Chaîne d'éclairs n'est toujours pas une chaîne")
		return
	if chain.chain_jumps <= 0:
		_fail("la chaîne ne fait aucun relais")

	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]

	# Une grappe d'ennemis proches les uns des autres : c'est le terrain de jeu
	# de ce sort, et le seul où ses relais peuvent s'enchaîner.
	var first := _cell_at(grid, context.player_field, 2)
	_add_enemy(context, first, 4000)
	var around := Pathfinder.distance_field(grid, [first] as Array[Vector2i])
	var placed := 1
	for cell in grid.all_floor_cells():
		if placed >= 4:
			break
		var step := Pathfinder.value_at(grid, around, cell)
		if step >= 1 and step <= 3 and cell != first:
			_add_enemy(context, cell, 4000)
			placed += 1
	if placed < 3:
		print("chaîne : pas assez de cases groupées pour ce test")
		return

	var arcs := {"count": 0}
	combat.chain_arced.connect(func(_f: int, _t: int) -> void: arcs["count"] += 1)
	combat.use(chain, context)
	for i in 60:
		combat.update(DT, context)

	# 1. Plusieurs créatures ont été touchées — c'est toute la promesse.
	var hurt := 0
	for health in context.enemy_health:
		if health.current < 4000:
			hurt += 1
	if hurt < 2:
		_fail("la chaîne n'a touché que %d créature(s)" % hurt)

	# 2. Elle s'ÉPUISE : le second maillon encaisse moins que le premier. Sans
	#    décroissance, grouper cinq ennemis les tuerait tous pour le prix d'un.
	var damages: Array[int] = []
	for health in context.enemy_health:
		if health.current < 4000:
			damages.append(4000 - health.current)
	damages.sort()
	if damages.size() >= 2 and damages[0] >= damages[damages.size() - 1]:
		_fail("la chaîne ne s'épuise pas : tous les maillons encaissent pareil")

	# 3. Le nombre d'arcs ne dépasse JAMAIS les relais annoncés. C'est le
	#    garde-fou contre l'aller-retour : sans mémoire des touchés, la chaîne
	#    rebondirait indéfiniment entre deux voisins.
	if arcs["count"] > chain.chain_jumps + 1:
		_fail("%d arcs pour %d relais annoncés : la chaîne fait des allers-retours"
			% [arcs["count"], chain.chain_jumps])

	# 4. Et chaque créature n'est touchée qu'une fois : ses dégâts ne peuvent
	#    pas dépasser ceux du premier maillon.
	for taken in damages:
		if taken > chain.damage:
			_fail("une créature encaisse %d dégâts pour un sort à %d : elle est touchée deux fois"
				% [taken, chain.damage])
			break


## LE CHAMP DE FOUDRE paralyse et électrocute — et n'est plus une seconde
## téléportation.
##
## Le Mage de la Foudre avait DEUX blinks : « Fulgurance » (5 cases) et sa fuite
## « Éclair fuyant » (7 cases). L'un était strictement inférieur à l'autre : il
## n'avait aucune raison d'exister. Ce test protège d'un retour en arrière, et
## vérifie que le champ se distingue du brasier du Feu.
func _test_thunder_field() -> void:
	var stats := CharacterCatalog.thunder()

	# 1. Un seul déplacement instantané dans le kit. Deux, c'est un sort perdu.
	var blinks := 0
	for ability in stats.action_bar():
		if ability != null and ability.kind == Ability.Kind.BLINK:
			blinks += 1
	if blinks > 1:
		_fail("le Mage de la Foudre a %d téléportations : l'une fait doublon" % blinks)

	var field: Ability = null
	for ability in stats.abilities:
		if ability.kind == Ability.Kind.ZONE and ability.snare > 0.0:
			field = ability
	if field == null:
		_fail("le Mage de la Foudre n'a pas de champ qui paralyse")
		return
	if absf(field.snare - 5.0) > 0.01:
		_fail("la paralysie dure %.1f s au lieu de 5" % field.snare)

	# 2. Il paralyse ET électrocute. Le brasier du Feu retient puis BRÛLE APRÈS ;
	#    le champ fait mal PENDANT — c'est ce qui les sépare.
	if field.damage <= 0:
		_fail("le champ paralyse sans faire de dégâts")
	if field.snare_burn > 0.0:
		_fail("le champ brûle après coup : c'est le brasier du Feu, pas lui")

	var brazier := CharacterCatalog.fire().abilities[2]
	if field.duration >= brazier.duration:
		_fail("le champ (%.0f s) dure autant que le brasier (%.0f s) : les deux zones se confondent"
			% [field.duration, brazier.duration])
	if field.damage <= brazier.damage:
		_fail("le champ (%d/s) ne frappe pas plus fort que le brasier (%d/s)"
			% [field.damage, brazier.damage])

	# 3. Il paralyse VRAIMENT, une fois par passage, comme toutes les zones-pièges.
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 4000)
	var holds := {"count": 0, "seconds": 0.0}
	combat.enemy_staggered.connect(func(_i: int, d: float) -> void:
		holds["count"] += 1
		holds["seconds"] = d)
	combat.use(field, context)
	for i in 200:
		combat.update(DT, context)
	if holds["count"] != 1:
		_fail("le champ paralyse %d fois avant la fin du verrou" % holds["count"])
	if absf(holds["seconds"] - field.snare) > 0.01:
		_fail("le champ annonce %.0f s de paralysie et en applique %.1f"
			% [field.snare, holds["seconds"]])
	if context.enemy_health[0].current >= 4000:
		_fail("le champ ne fait aucun dégât")

	# 4. La chaîne est à 1,8 s : le rythme du personnage.
	if absf(stats.abilities[0].cooldown - 1.8) > 0.01:
		_fail("la Chaîne d'éclairs recharge en %.1f s au lieu de 1,8"
			% stats.abilities[0].cooldown)


## L'ORAGE SUIT LE MAGE et frappe tout seul.
##
## C'est la première chose du jeu qui accompagne le joueur au lieu de l'attendre
## quelque part. Deux promesses fragiles : qu'il SUIVE (une zone posée serait un
## doublon du Champ de foudre), et qu'un second lancer ne double pas la cadence.
func _test_storm() -> void:
	var stats := CharacterCatalog.thunder()
	var storm: Ability = stats.abilities[2]
	if storm.kind != Ability.Kind.STORM:
		_fail("l'Orage n'est pas un nuage qui suit")
		return

	# Le Mage de la Foudre ne doit pas avoir DEUX zones posées : le Champ tient
	# le sol, l'Orage accompagne. C'est ce qui les sépare.
	var grounded := 0
	for ability in stats.abilities:
		if ability.kind == Ability.Kind.ZONE:
			grounded += 1
	if grounded > 1:
		_fail("le Mage de la Foudre a %d zones posées : elles font doublon" % grounded)

	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 9000)

	var strikes := {"count": 0}
	combat.storm_struck.connect(func(_i: int, _a: Ability) -> void: strikes["count"] += 1)
	combat.use(storm, context)

	# 1. La première décharge tombe TOUT DE SUITE : un sort qui ne fait rien
	#    pendant sa première seconde se lit comme un sort raté.
	combat.update(DT, context)
	if strikes["count"] != 1:
		_fail("l'orage ne frappe pas dès son invocation")

	# 2. Il frappe à CADENCE régulière, pas en rafale.
	for i in int(3.0 / DT):
		combat.update(DT, context)
	var expected := int(3.0 / storm.storm_interval)
	if absi(strikes["count"] - (expected + 1)) > 1:
		_fail("%d décharges en 3 s, attendu environ %d"
			% [strikes["count"], expected + 1])

	# 3. Il S'ARRÊTE à l'échéance.
	var dispersed := {"done": false}
	combat.storm_dispersed.connect(func() -> void: dispersed["done"] = true)
	for i in int(storm.duration / DT) + 20:
		combat.update(DT, context)
	if not dispersed["done"]:
		_fail("l'orage ne se disperse jamais")
	var settled: int = strikes["count"]
	for i in 120:
		combat.update(DT, context)
	if strikes["count"] != settled:
		_fail("l'orage frappe encore après s'être dispersé")

	# 4. Relancé, il REPART À NEUF sans doubler la cadence : deux nuages
	#    superposés frapperaient deux fois plus vite sans que rien ne le montre.
	var parts2 := _context(stats)
	var grid2: MazeGrid = parts2[0]
	var combat2: CombatSystem = parts2[1]
	var context2: CombatContext = parts2[2]
	_add_enemy(context2, _cell_at(grid2, context2.player_field, 2), 9000)
	var doubled := {"count": 0}
	combat2.storm_struck.connect(func(_i: int, _a: Ability) -> void: doubled["count"] += 1)
	combat2.use(storm, context2)
	combat2.use(storm, context2)
	for i in int(3.0 / DT):
		combat2.update(DT, context2)
	if doubled["count"] > expected + 3:
		_fail("deux invocations doublent la cadence : %d décharges en 3 s"
			% doubled["count"])


## LE JUGEMENT CÉLESTE lève un CIEL, il ne fait pas une explosion.
##
## La différence avec l'Embrasement du Feu est le cœur du sort : une météore
## tombe UNE fois et disparaît, un nuage s'installe et frappe tant qu'il est là.
## Si les nuages ne duraient pas, les deux ultimes seraient le même sort en deux
## couleurs.
func _test_sky_judgement() -> void:
	var stats := CharacterCatalog.thunder()
	var ultimate := stats.ultimate
	if ultimate.sky_clouds <= 0:
		_fail("le Jugement céleste ne lève aucun nuage")
		return
	if ultimate.sky_duration <= 0.0:
		_fail("les nuages du Jugement ne durent pas : c'est une averse, pas un ciel")

	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	for step in [2, 3, 4]:
		var cell := _cell_at(grid, context.player_field, step)
		if cell.x >= 0:
			_add_enemy(context, cell, 90000)

	var formed := {"count": 0}
	var faded := {"count": 0}
	var bolts := {"count": 0, "late": 0}
	var elapsed := {"t": 0.0}
	combat.sky_cloud_formed.connect(func(_c: Vector2i, _d: float, _a: Ability) -> void:
		formed["count"] += 1)
	combat.sky_cloud_faded.connect(func(_c: Vector2i) -> void: faded["count"] += 1)
	combat.sky_bolt.connect(func(_c: Vector2i, _i: int, _a: Ability) -> void:
		bolts["count"] += 1
		# Une frappe DEUX secondes après le lancement prouve que le nuage a
		# duré : une averse aurait déjà tout lâché.
		if elapsed["t"] > 2.0:
			bolts["late"] += 1)

	combat.use(ultimate, context)
	if formed["count"] != ultimate.sky_clouds:
		_fail("%d nuages formés au lieu de %d" % [formed["count"], ultimate.sky_clouds])

	for i in int((ultimate.sky_duration + 1.0) / DT):
		elapsed["t"] = float(i) * DT
		combat.update(DT, context)

	# 1. Les nuages FRAPPENT, et pas seulement à l'instant du lancement.
	if bolts["count"] <= 0:
		_fail("les nuages du Jugement ne foudroient personne")
	if bolts["late"] <= 0:
		_fail("aucune frappe après 2 s : les nuages ne durent pas")

	# 2. Ils se dissipent TOUS. Un nuage oublié frapperait jusqu'à la fin du
	#    niveau sans que rien ne le rappelle au joueur.
	if faded["count"] != ultimate.sky_clouds:
		_fail("%d nuages dissipés sur %d : il en reste au ciel"
			% [faded["count"], ultimate.sky_clouds])
	var settled: int = bolts["count"]
	for i in 200:
		combat.update(DT, context)
	if bolts["count"] != settled:
		_fail("le ciel foudroie encore après s'être dissipé")

	# 3. Il ne fait pas doublon avec l'Embrasement : celui du Feu fait tomber
	#    des météores UNE fois, celui-ci installe des nuages qui restent.
	var nova := CharacterCatalog.fire().ultimate
	if nova.sky_clouds > 0:
		_fail("l'ultime du Feu lève aussi des nuages : les deux se confondent")
	if ultimate.rain_count > 0:
		_fail("l'ultime de la Foudre fait aussi pleuvoir : c'est celui du Feu")
