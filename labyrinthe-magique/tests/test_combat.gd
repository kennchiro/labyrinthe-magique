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
	_test_flat_index()

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
	combat.enemy_soaked.connect(func(_i: int, _d: float) -> void: seen["soak"] += 1)
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
