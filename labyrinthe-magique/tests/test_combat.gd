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
	_test_free_shot()
	_test_blast_respects_walls()
	_test_zone_damages_over_time()
	_test_wall_and_blink()
	_test_lairs_as_targets()
	_test_lair_boss_levels()
	_test_stage_unlocks()
	_test_elemental_traits()
	_test_leech_is_not_immortality()
	_test_shadow_passage()
	_test_summons()
	_test_rosters()
	_test_flat_index()
	_test_demo_free_use()
	_test_zone_snare()
	_test_rune_drain()
	_test_shadow_implosion()
	_test_shadow_rift()
	_test_charges()
	_test_volcanic_ultimate()
	_test_ultimate_thresholds()
	_test_ability_summaries()
	_test_chrono()
	_test_peste()
	_test_lumiere()
	_test_mort()
	_test_etoiles()
	_test_acier()
	_test_demon()
	_test_discorde()
	_test_braise()
	_test_ecarlate()
	_test_geolier()
	_test_ciel()
	_test_cherubin()
	_test_awakening()
	_test_phoenix_kit()
	_test_tide_lord()
	_test_colossus()
	_test_tempest()
	_test_sovereign()
	_test_void_lord()
	_test_legion()
	_test_hours()
	_test_scourge()
	_test_primordial()
	_test_morning_star()
	_test_reaper()
	_test_firmament()
	_test_forge()
	_test_throne()
	_test_seraph()
	_test_archdemon()
	_test_queen()
	_test_emperor()
	_test_lord()
	_test_warden()
	_test_primal()
	_test_casino()
	_test_endless()
	_test_dragon()
	_test_croupier()
	_test_avide()
	_test_water_promises()
	_test_empowerment()
	_test_shield_expiry()
	_test_lightning_chain()
	_test_thunder_field()
	_test_storm()
	_test_air_cyclone()
	_test_sky_judgement()
	_test_earth_line()
	_test_earth_aegis()
	_test_earth_rift()
	_test_earth_quake()
	_test_air_tornado()
	_test_air_gust()
	_test_water_geysers()
	_test_archer()

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


# --- L'Archer d'Os -----------------------------------------------------------------

## IL TIRE DE PRÈS, ET IL RECHARGE. Portée courte, intervalle réel entre deux
## flèches, et une flèche qui rate celui qui s'est écarté.
func _test_archer() -> void:
	var tuning := Bestiary.of("archer")
	var reach := int(tuning.get("throw_range", 0))
	if reach <= 0 or reach >= int(Bestiary.of("golem")["throw_range"]):
		_fail("l'Archer doit tirer, moins loin que le Golem de Lave : portée %d" % reach)
	if not bool(tuning.get("ranged_only", false)):
		_fail("l'Archer frappe encore au contact")
	var reload := ThrowSystem.reload_of(tuning)
	if reload <= float(tuning["strike"]) + float(tuning["repos"]):
		_fail("l'Archer n'a pas d'intervalle : il tire dès la fin de son geste")

	# Un couloir droit assez long pour tirer à portée, et une case au-delà.
	var grid := MazeGenerator.generate(LevelConfig.for_stage(7), 4242)
	var from := Vector2i(-1, -1)
	for y in grid.rows:
		for x in grid.cols:
			var clear := true
			for i in reach + 2:
				clear = clear and grid.is_floor_v(Vector2i(x + i, y))
			if clear:
				from = Vector2i(x, y)
				break
		if from.x >= 0:
			break
	if from.x < 0:
		_fail("aucun couloir droit pour éprouver l'Archer")
		return
	var at_range := from + Vector2i(reach, 0)
	var too_far := from + Vector2i(reach + 1, 0)
	var shooter := {"cell": from, "range": reach, "reload": reload, "arrow": true}

	var throws := ThrowSystem.new(grid)
	if not throws.aim(DT, [shooter], too_far).is_empty():
		_fail("l'Archer tire au-delà de sa portée")

	# L'intervalle, mesuré entre les deux premiers tirs.
	var shots: Array[float] = []
	var elapsed := 0.0
	while elapsed < reload * 2.5:
		elapsed += DT
		if not throws.aim(DT, [shooter], at_range).is_empty():
			shots.append(elapsed)
	if shots.size() < 2:
		_fail("l'Archer ne retire pas : %d tir(s)" % shots.size())
	elif absf(shots[1] - shots[0] - reload) > DT * 2.0:
		_fail("intervalle de tir %.2f s au lieu de %.2f s" % [shots[1] - shots[0], reload])

	# ⚠️ Le rechargement court aussi quand il ne peut pas tirer : il se figeait
	# pendant le repos d'après coup, et le jeu tirait deux fois moins vite.
	var rested := ThrowSystem.new(grid)
	rested.aim(DT, [shooter], at_range)
	var idle := 0.0
	while idle < reload:
		idle += DT
		rested.aim(DT, [{"cell": from, "range": 0}], at_range)
	if rested.aim(DT, [shooter], at_range).is_empty():
		_fail("le rechargement se fige quand le tireur ne peut pas tirer")

	# La flèche tombe là où le mage était : un pas de côté suffit.
	var dodge := ThrowSystem.new(grid)
	dodge.aim(DT, [shooter], at_range)
	var landed: Array[Vector2i] = []
	var flown := 0.0
	while landed.is_empty() and flown < 2.0:
		flown += DT
		landed = dodge.advance(DT)
	if landed.is_empty() or landed[0] != at_range:
		_fail("la flèche ne tombe pas sur la case visée")
	elif not dodge.quiet_landings.has(at_range):
		_fail("la flèche explose en tombant")
	elif ThrowSystem.touches(at_range, Vector2(at_range) + Vector2(1.0, 0.0)):
		_fail("une case d'écart ne sauve pas de la flèche")
	elif not ThrowSystem.touches(at_range, Vector2(at_range)):
		_fail("la flèche rate celui qui n'a pas bougé")


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
	# se bat pas lui-même, il délègue à ses invocations), le Chronomancien, la Peste et le
	# Porte-Lumière, et l'Ange de la Mort. Le
	# compte protège contre un doublon ou une disparition, pas contre l'évolution du roster.
	if characters.size() != 24:
		_fail("le catalogue contient %d personnages au lieu de 24" % characters.size())
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
		# Le Battement d'ailes du Dragon le fait reculer d'un bond : c'est une fuite.
		if character.escape == null or not (character.escape.kind in [Ability.Kind.BLINK, Ability.Kind.SWAP,
				Ability.Kind.FLIGHT, Ability.Kind.WINGBEAT, Ability.Kind.LEAP]):
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


## L'Extra Power se charge de deux façons : les kills, et les potions.
func _test_unlocks() -> void:
	var kills := KillSystem.new(5)
	if not kills.drink_potion() or kills.progress != 3:
		_fail("une potion doit charger la moitié de la jauge, arrondie au-dessus")
	kills.register_kill()
	if kills.available():
		_fail("l'Extra est prêt avant d'avoir rempli sa jauge")
	kills.register_kill()
	if not kills.available():
		_fail("une potion et deux kills ne complètent pas une jauge de 5")
	if kills.drink_potion():
		_fail("une jauge pleine accepte encore une potion")
	var drunk := KillSystem.new(4)
	drunk.drink_potion()
	drunk.drink_potion()
	if not drunk.available():
		_fail("deux potions ne chargent pas l'Extra à elles seules")
	if drunk.kills != 0:
		_fail("une potion compte comme un kill au score")
	print("extra power : kills ou potions")


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

	# Aucun ennemi : un sort qui vise ne part pas et ne coûte rien.
	var fire := CharacterCatalog.fire()
	var fire_parts := _context(fire)
	var aimed: Ability = fire.abilities[0]
	if aimed.kind != Ability.Kind.PROJECTILE:
		_fail("le premier sort du Feu n'est plus un projectile, ce test ne vérifie plus rien")
	if fire_parts[1].use(aimed, fire_parts[2]):
		_fail("un sort qui vise part sans le moindre ennemi")
	if fire_parts[1].cooldown_left(aimed) > 0.0:
		_fail("un tir refusé a quand même déclenché la recharge")
	var skill: Ability = stats.abilities[0]
	# La rune est une ZONE : elle part même sans cible, c'est un piège.
	if not combat.use(skill, context):
		_fail("une zone refuse de se poser faute de cible, alors que c'est un piège")
	if combat.cooldown_left(skill) <= 0.0:
		_fail("une zone posée ne déclenche pas sa recharge")
	print("geste refusé : aucune recharge déclenchée : OK")


## L'attaque de base part sans cible, droit devant, et frappe ce qu'elle croise.
func _test_free_shot() -> void:
	var stats := CharacterCatalog.shadow()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var flights := {"path": []}
	combat.projectile_launched.connect(func(_a: Ability, target: int, path: Array, _d: float) -> void:
		flights["target"] = target
		flights["path"] = path)
	var hits := {"count": 0}
	combat.projectile_hit.connect(func(_a: Ability, _t: int, _c: Vector2i) -> void: hits["count"] += 1)

	# Un couloir droit de trois cases au moins devant le mage.
	for cell in grid.all_floor_cells():
		for direction in MazeGrid.NEIGHBORS:
			if grid.is_floor_v(cell + direction) and grid.is_floor_v(cell + direction * 2) \
					and grid.is_floor_v(cell + direction * 3):
				context.player_cell = cell
				context.player_facing = direction
				break
		if grid.is_floor_v(context.player_cell + context.player_facing * 3):
			break
	context.player_field = Pathfinder.distance_field(grid, [context.player_cell] as Array[Vector2i])

	if not combat.use(stats.attack, context):
		_fail("l'attaque de base refuse de partir sans ennemi")
	if combat.cooldown_left(stats.attack) <= 0.0:
		_fail("un tir libre ne déclenche pas la recharge")
	if int(flights["target"]) >= 0:
		_fail("un tir libre porte le numéro d'un ennemi")
	for step in flights["path"].size():
		var expected: Vector2i = context.player_cell + context.player_facing * step
		if flights["path"][step] != expected:
			_fail("un tir libre ne part pas droit devant : %s" % str(flights["path"]))
	if flights["path"].size() - 1 > stats.attack.range:
		_fail("un tir libre dépasse sa portée")

	# Un ennemi entre dans le couloir après le départ : il prend le coup.
	_add_enemy(context, context.player_cell + context.player_facing * 2, 100)
	for i in 300:
		combat.update(DT, context)
	if context.enemy_health[0].current != 100 - stats.attack.damage:
		_fail("un tir libre ne blesse pas l'ennemi croisé (PV %d)" % context.enemy_health[0].current)
	if hits["count"] != 1:
		_fail("%d impacts pour un seul tir libre" % hits["count"])

	# L'ennemi en vue reste visé : le tir suit le chemin jusqu'à lui.
	if not combat.use(stats.attack, context):
		_fail("l'attaque de base refuse un ennemi à portée")
	if int(flights["target"]) != 0:
		_fail("l'ennemi à portée n'est plus visé")
	print("tir libre : droit devant, frappe ce qu'il croise, l'ennemi à portée reste visé : OK")


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
	if absf(imps.duration - 30.0) > 0.01:
		_fail("les diablotins doivent durer 30 s, pas %.1f s" % imps.duration)
	var gargoyle: Ability = stats.abilities[1]
	if absf(gargoyle.duration - 40.0) > 0.01:
		_fail("la gargouille doit durer 40 s, pas %.1f s" % gargoyle.duration)
	if not combat.use(imps, context):
		_fail("l'invocation des diablotins est refusée")
	if events["spawned"] != imps.summon_count:
		_fail("%d créatures nées pour %d demandées" % [events["spawned"], imps.summon_count])

	# Les diablotins doivent trouver l'ennemi à 6 cases et l'abattre — bien
	# avant leurs 30 s de vie. 25 s de marge : à 4,6 cases/s, l'aller dure
	# moins de 2 s, et 60 PV tombent en 6 coups.
	# Ils suivent les couloirs : jamais de diagonale à travers le coin d'une haie.
	var off_axis := {"count": 0}
	var on_move := func(_id: int, at: Vector2, _facing: Vector2i) -> void:
		if absf(at.x - round(at.x)) > 0.01 and absf(at.y - round(at.y)) > 0.01:
			off_axis["count"] += 1
	combat.summon_moved.connect(on_move)
	var elapsed := 0.0
	while context.enemy_health[0].is_alive() and elapsed < 25.0:
		combat.update(DT, context)
		elapsed += DT
	combat.summon_moved.disconnect(on_move)
	if off_axis["count"] > 0:
		_fail("%d pas de diablotin hors de l'axe du couloir" % off_axis["count"])
	if context.enemy_health[0].is_alive():
		_fail("les diablotins n'ont pas abattu un ennemi immobile en 25 s")
	if events["kills"] != 1:
		_fail("%d kills signalés — les invocations doivent nourrir l'ultime" % events["kills"])

	# L'expiration : à 30 s pile, plus personne.
	var remaining := imps.duration - elapsed + 1.0
	var steps := int(remaining / DT)
	for i in steps:
		combat.update(DT, context)
	if combat.summon_count() != 0:
		_fail("%d créature(s) encore en vie après leurs 30 s" % combat.summon_count())
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
	print("invocations : diablotins 30 s, gargouille 40 s, chasse, kill et plafond à %d : OK"
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



## La RUNE du Sorcier des Ténèbres : elle RONGE ce qu'elle retient.
##
## Deux promesses, et chacune peut casser toute seule. Les dégâts doivent
## s'accumuler seconde après seconde tant que la créature est dessus — un
## prélèvement unique ferait un péage, pas un piège. Et l'englu doit être réarmé
## à CHAQUE frame, pas au tick de la zone : sa traînée est plus courte que
## l'intervalle des ticks, donc au tick l'ennemi retrouverait son allure deux
## fois par seconde. Le tout doit se couper net à la sortie.
func _test_rune_drain() -> void:
	var stats := CharacterCatalog.shadow()
	var parts := _context(stats)
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	# L'ennemi est SUR la rune : c'est la case du mage qui la reçoit.
	_add_enemy(context, context.player_cell, 4000)

	var rune: Ability = null
	for ability in stats.abilities:
		if ability.slow_sustained:
			rune = ability
	if rune == null:
		_fail("aucune zone à englu soutenu dans le catalogue du Sorcier des Ténèbres")
		return
	if rune.slow_factor > 0.2:
		_fail("la rune laisse %d %% d'allure : on la traverse encore" % int(rune.slow_factor * 100.0))
	if rune.slow_duration > 1.0:
		_fail("la traînée dure %.1f s : trop longue pour une sortie de rune" % rune.slow_duration)

	var soaks := {"count": 0, "factor": 1.0}
	combat.enemy_soaked.connect(func(_i: int, _d: float, f: float) -> void:
		soaks["count"] += 1
		soaks["factor"] = f)

	combat.use(rune, context)
	for i in 180:
		combat.update(DT, context)
	var lost: int = 4000 - context.enemy_health[0].current
	var expected: int = rune.damage * 3
	if absf(float(lost - expected)) > float(rune.damage):
		_fail("3 s dans la rune coûtent %d PV au lieu de ~%d : l'usure ne s'accumule pas"
			% [lost, expected])
	if soaks["count"] < 170:
		_fail("l'englu n'est réarmé que %d fois en 180 frames : il se compte au lieu de tenir"
			% soaks["count"])
	if not is_equal_approx(soaks["factor"], rune.slow_factor):
		_fail("l'englu posé vaut %.2f au lieu de %.2f" % [soaks["factor"], rune.slow_factor])

	# DEHORS : plus un dégât, plus un englu. Ce qui retient doit lâcher prise.
	var before: int = soaks["count"]
	var spared: int = context.enemy_health[0].current
	context.enemy_cells[0] = _cell_at(parts[0], context.player_field, 6)
	for i in 120:
		combat.update(DT, context)
	if soaks["count"] != before:
		_fail("la rune englue encore une créature qui en est sortie")
	if context.enemy_health[0].current != spared:
		_fail("la rune ronge encore une créature qui en est sortie")



## L'IMPLOSION D'OMBRE : elle ramène avant de frapper.
##
## Trois promesses. Le souffle porte PLUS LOIN que les dégâts, sinon il n'aurait
## aucun effet — ce qu'il attrape serait déjà dans l'explosion. Ce qu'il ramène
## doit encore trouver l'explosion en arrivant, donc l'ordre compte : aspirer
## PUIS frapper. Et il ne dépose personne SUR le mage, sous peine de deux
## sprites superposés et d'un coup gratuit.
func _test_shadow_implosion() -> void:
	var stats := CharacterCatalog.shadow()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]

	var burst: Ability = null
	for ability in stats.abilities:
		if ability.pull_radius > 0.0:
			burst = ability
	if burst == null:
		_fail("aucun sort à aspiration dans le catalogue du Sorcier des Ténèbres")
		return
	if burst.pull_radius <= burst.radius:
		_fail("le souffle (%s) ne porte pas plus loin que les dégâts (%s) : il ne sert à rien"
			% [burst.pull_radius, burst.radius])

	# Une créature HORS de portée des dégâts mais dans celle du souffle : c'est
	# le cas qui définit le sort.
	var far := _cell_at(grid, context.player_field, 4)
	if far.x < 0:
		_fail("aucune case à 4 pas du mage sur cette graine")
		return
	_add_enemy(context, far, 4000)
	# Et une autre COLLÉE au mage : elle ne doit pas lui monter dessus.
	var near := _cell_at(grid, context.player_field, 1)
	_add_enemy(context, near, 4000)

	var hauls := {"count": 0}
	combat.enemy_hauled.connect(func(_i: int, _c: Vector2i) -> void:
		hauls["count"] += 1)

	combat.use(burst, context)
	if hauls["count"] < 1:
		_fail("l'implosion n'a ramené personne alors qu'une créature était à 4 pas")
	var pulled := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[0])
	if pulled >= 4:
		_fail("la créature est restée à %d pas : elle n'a pas été aspirée" % pulled)
	if context.enemy_cells[0] == context.player_cell:
		_fail("l'implosion dépose une créature SUR le mage")
	if context.enemy_cells[1] == context.player_cell:
		_fail("l'implosion pousse sur le mage une créature déjà collée à lui")
	# ELLE NE LIVRE PAS SON LANCEUR. Ramenée au contact, la créature frappe dans
	# la seconde et le sort offre le coup qu'il devait éviter.
	if pulled < burst.pull_min:
		_fail("l'implosion dépose une créature à %d pas du mage, sa butée est à %d"
			% [pulled, burst.pull_min])
	# Et elle reste DANS l'explosion : une butée plus large que le rayon
	# rangerait la meute hors de portée de son propre sort.
	if float(burst.pull_min) > burst.radius:
		_fail("la butée (%d) dépasse le rayon (%s) : le sort range la meute hors de ses dégâts"
			% [burst.pull_min, burst.radius])

	# Ramenée À PORTÉE, elle doit avoir encaissé : c'est tout l'intérêt d'aspirer
	# avant de frapper. Une créature à 4 pas d'un sort de rayon 2,6 ne prend
	# rien si l'ordre est inversé.
	if context.enemy_health[0].current >= 4000:
		_fail("la créature ramenée n'a rien encaissé : l'explosion part avant l'aspiration")

	# L'OMBRE RESTE, ET ELLE EMPOISONNE. Trois secondes plus tard, la flaque doit
	# encore être là et la créature avoir perdu un PV par seconde — ni plus (un
	# demi-tick arrondi doublerait le chiffre annoncé), ni moins.
	if burst.residue_duration <= 0.0:
		_fail("l'implosion ne laisse aucune ombre derrière elle")
		return
	var poisons := {"count": 0, "duration": 0.0}
	combat.enemy_poisoned.connect(func(_i: int, d: float) -> void:
		poisons["count"] += 1
		poisons["duration"] = d)
	var after_blast: int = context.enemy_health[0].current
	for i in int(3.0 / DT):
		combat.update(DT, context)
	var bled: int = after_blast - context.enemy_health[0].current
	if poisons["count"] < 1:
		_fail("la flaque d'ombre n'empoisonne personne")
	if not is_equal_approx(poisons["duration"], burst.poison_duration):
		_fail("le poison annonce %.0f s au lieu de %.0f" % [poisons["duration"], burst.poison_duration])
	if absf(float(bled - burst.poison_damage * 3)) > float(burst.poison_damage):
		_fail("3 s de poison coûtent %d PV au lieu de ~%d : le tic n'est pas à la seconde"
			% [bled, burst.poison_damage * 3])

	# IL SUIT SA VICTIME DEHORS. Le poison est ce que l'on emporte, pas ce que
	# l'on subit sur place — sortir de la flaque ne doit pas l'effacer.
	var outside: int = context.enemy_health[0].current
	context.enemy_cells[0] = _cell_at(grid, context.player_field, 8)
	for i in int(3.0 / DT):
		combat.update(DT, context)
	if context.enemy_health[0].current >= outside:
		_fail("le poison s'arrête dès que la créature sort de l'ombre")


## LA FAILLE DES TÉNÈBRES : des portes s'ouvrent SUR LES PROIES.
##
## Quatre promesses. Les portes s'ouvrent près des poursuivants et non aux pieds
## du mage — c'est ce qui sépare cet ultime de l'Invocateur, dont les bêtes
## doivent traverser le labyrinthe. Chaque porte lâche deux ombres, jamais une.
## Le compte est PLAFONNÉ : une porte par ennemi viderait un stage tardif d'un
## seul geste. Et le sort est refusé quand il n'y a personne à chasser, sinon un
## ultime gagné en quatre kills se dépense dans un couloir vide.
func _test_shadow_rift() -> void:
	var stats := CharacterCatalog.shadow()
	var rift: Ability = stats.ultimate
	if rift.kind != Ability.Kind.SUMMON or rift.summon_portals <= 0:
		_fail("la Faille des ténèbres n'ouvre aucune porte")
		return
	if rift.summon_count < 2:
		_fail("une faille ne lâche que %d ombre" % rift.summon_count)
	if rift.duration < 120.0:
		_fail("les ombres ne tiennent que %.0f s au lieu de 120" % rift.duration)

	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]

	# 1. SANS PROIE, LE SORT EST REFUSÉ. Il ne coûte rien et ne pose rien.
	var refusals := {"count": 0}
	combat.use_refused.connect(func(_why: String) -> void: refusals["count"] += 1)
	if combat.use(rift, context):
		_fail("la Faille part alors qu'il n'y a personne à chasser")
	if refusals["count"] < 1:
		_fail("la Faille échoue en silence : le joueur ne saura pas pourquoi")

	# 2. AVEC DES PROIES : une porte par créature, plafonnée, deux ombres chacune.
	var prey_count := rift.summon_portals + 2
	for i in prey_count:
		_add_enemy(context, _cell_at(grid, context.player_field, 2 + i), 4000)
	var doors := {"count": 0, "cells": []}
	var born := {"count": 0}
	combat.rift_opened.connect(func(cell: Vector2i) -> void:
		doors["count"] += 1
		doors["cells"].append(cell))
	combat.summon_spawned.connect(func(_id: int, kind: String, _p: Vector2) -> void:
		born["count"] += 1
		if kind != rift.summon_id:
			_fail("la Faille fait sortir un « %s » au lieu d'une ombre" % kind))

	if not combat.use(rift, context):
		_fail("la Faille est refusée alors que %d créatures sont là" % prey_count)
	if doors["count"] != rift.summon_portals:
		_fail("%d portes ouvertes pour %d créatures : le plafond de %d ne tient pas"
			% [doors["count"], prey_count, rift.summon_portals])
	if born["count"] != rift.summon_portals * rift.summon_count:
		_fail("%d ombres sorties de %d portes : ce n'est pas %d par porte"
			% [born["count"], doors["count"], rift.summon_count])

	# 3. LES PORTES S'OUVRENT SUR LES PROIES, pas sur le mage. Sans quoi le sort
	#    redevient une invocation ordinaire et son trajet coûte le double.
	for cell in doors["cells"]:
		var to_player := Pathfinder.value_at(grid, context.player_field, cell)
		var to_prey := 999
		for enemy_cell in context.enemy_cells:
			to_prey = mini(to_prey, absi(cell.x - enemy_cell.x) + absi(cell.y - enemy_cell.y))
		if to_prey > 1:
			_fail("une porte s'ouvre à %d cases de toute proie" % to_prey)
		if to_player <= 1:
			_fail("une porte s'ouvre au pied du mage : c'est une invocation, pas une faille")

	# 4. ELLES CHASSENT VRAIMENT, et leur gaz empoisonne.
	var poisons := {"count": 0}
	combat.enemy_poisoned.connect(func(_i: int, _d: float) -> void: poisons["count"] += 1)
	var before := 0
	for health in context.enemy_health:
		before += health.current
	for i in int(12.0 / DT):
		combat.update(DT, context)
	var after := 0
	for health in context.enemy_health:
		after += health.current
	if after >= before:
		_fail("les ombres n'ont blessé personne en 12 s")
	if poisons["count"] < 1:
		_fail("le gaz des ombres n'empoisonne pas")


## LE CYCLONE DE L'AIR : trois colonnes qui chassent seules.
##
## Trois promesses. Elles sont TROIS — une seule se contourne. Elles vont droit
## sur les poursuivants, haies comprises, ce que rien d'autre chez ce mage ne
## fait. Et elles tiennent deux minutes, pendant que le mage court aux gemmes.
##
## ⚠️ Ce sort a d'abord été écrit comme un phénomène qui SUIT le mage, et jeté :
## si lentement qu'il le suive, ça reste le nuage d'orage du mage de la Foudre
## sous un autre dessin. Le test le vérifie encore — il doit être autonome.
func _test_air_cyclone() -> void:
	var stats := CharacterCatalog.air()
	var cyclone: Ability = stats.ultimate
	if cyclone.kind != Ability.Kind.SUMMON:
		_fail("le Cyclone n'est pas une invocation : il n'a rien d'autonome")
		return
	if cyclone.summon_count < 3:
		_fail("le Cyclone ne lève que %d colonne(s) au lieu de 3" % cyclone.summon_count)
	if cyclone.duration < 120.0:
		_fail("les colonnes ne tiennent que %.0f s au lieu de 120" % cyclone.duration)
	var kind: Dictionary = CombatSystem.SUMMON_KINDS.get(cyclone.summon_id, {})
	if kind.is_empty():
		_fail("la créature « %s » n'existe pas" % cyclone.summon_id)
		return
	if not bool(kind["flies"]):
		_fail("le Cyclone ne vole pas : il s'arrête aux haies comme tout le monde")
	if float(kind["speed"]) >= stats.move_speed:
		_fail("le Cyclone va à %s cases/s pour un mage à %s : il n'est pas lent"
			% [kind["speed"], stats.move_speed])

	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]

	# 1. TROIS COLONNES SE LÈVENT, et elles portent bien le bon nom.
	var born := {"count": 0}
	combat.summon_spawned.connect(func(_id: int, id_kind: String, _p: Vector2) -> void:
		born["count"] += 1
		if id_kind != cyclone.summon_id:
			_fail("le Cyclone lève un « %s »" % id_kind))
	if not combat.use(cyclone, context):
		_fail("le Cyclone est refusé")
		return
	if born["count"] != cyclone.summon_count:
		_fail("%d colonnes levées au lieu de %d" % [born["count"], cyclone.summon_count])

	# 2. ELLES CHASSENT SEULES, et elles vont chercher LOIN — une créature que
	#    le mage ne poursuit pas, à l'autre bout d'un couloir.
	var prey := _cell_at(grid, context.player_field, 9)
	if prey.x < 0:
		prey = _cell_at(grid, context.player_field, 6)
	_add_enemy(context, prey, 4000)
	var hits := {"count": 0}
	combat.summon_struck.connect(func(_id: int, _target: int) -> void:
		hits["count"] += 1)
	for i in int(20.0 / DT):
		combat.update(DT, context)
	if hits["count"] < 1:
		_fail("les colonnes n'ont frappé personne en 20 s : elles ne chassent pas")
	if context.enemy_health[0].current >= 4000:
		_fail("la créature poursuivie n'a rien encaissé")

	# 3. ELLES S'ÉTEIGNENT. Deux minutes, pas davantage.
	var gone := {"count": 0}
	combat.summon_expired.connect(func(_id: int) -> void: gone["count"] += 1)
	for i in int(cyclone.duration / DT):
		combat.update(DT, context)
	if gone["count"] < cyclone.summon_count:
		_fail("%d colonnes se sont éteintes sur %d" % [gone["count"], cyclone.summon_count])


## LE PASSAGE DU SORCIER DES TÉNÈBRES traverse, sa fuite glisse.
##
## Deux translations dans le même kit ont besoin de deux comportements, sinon la
## plus courte n'est qu'une version ratée de l'autre — et c'était le cas : 4
## cases toutes les 9 s à côté de 6 cases toutes les 6,5 s, sur le même geste.
func _test_shadow_passage() -> void:
	var stats := CharacterCatalog.shadow()
	var passage: Ability = null
	for ability in stats.abilities:
		if ability.kind == Ability.Kind.BLINK:
			passage = ability
	if passage == null:
		_fail("le Sorcier des Ténèbres n'a plus de translation")
		return
	if not passage.pierces_walls:
		_fail("le Passage ne traverse pas les murs : il redevient une fuite ratée")
	if stats.escape != null and stats.escape.pierces_walls:
		_fail("la FUITE traverse aussi : les deux sorts se confondent de nouveau")

	# Le cas qui fait le sort : une haie devant, du sol derrière.
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var jumped := {"to": Vector2i(-1, -1), "count": 0}
	combat.blink_performed.connect(func(_from: Vector2i, to: Vector2i) -> void:
		jumped["to"] = to
		jumped["count"] += 1)

	var found := false
	for cell in grid.all_floor_cells():
		for facing in MazeGrid.NEIGHBORS:
			if grid.is_floor_v(cell + facing):
				continue          # pas de haie devant : ce n'est pas le cas
			var beyond: Vector2i = cell + facing * 2
			if not grid.is_floor_v(beyond):
				continue          # rien derrière la haie non plus
			context.player_cell = cell
			context.player_facing = facing
			if not combat.use(passage, context):
				_fail("le Passage est refusé face à une haie qui a du sol derrière")
				return
			if jumped["to"] == cell:
				_fail("le Passage n'a pas bougé le mage")
			elif not grid.is_floor_v(jumped["to"]):
				_fail("le Passage dépose le mage DANS un mur : %s" % jumped["to"])
			found = true
			break
		if found:
			break
	if not found:
		print("passage : aucune haie franchissable sur cette graine")


## LA PONCTION NE REND PAS IMMORTEL.
##
## Elle rendait « 22 % des dégâts infligés », et c'était un défaut d'UNITÉS :
## `dealt` se compte en points de vie d'ENNEMI — 16 pour une orbe — quand le
## mage en a TROIS. Chaque coup porté le remettait donc à fond, sur un
## personnage dont la fiche annonce « encaisse mal ».
##
## Rien ne pouvait l'attraper : les deux nombres sont des entiers, l'appel est
## valide, et le soin est plafonné par le maximum du mage — le défaut ne se voit
## qu'en jouant, et il se lit comme de la chance.
func _test_leech_is_not_immortality() -> void:
	var stats := CharacterCatalog.shadow()
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 100000)

	# Le mage est à un point de la mort, et il frappe.
	health.take(Damage.new(stats.base_health - 1, Element.Kind.FIRE, "enemy"))
	if health.current != 1:
		_fail("le mage ne descend pas à 1 PV : %d" % health.current)
		return

	# 1. UN SEUL POINT PAR PONCTION, quelle que soit la force du coup.
	combat.use(stats.attack, context)
	for i in int(1.5 / DT):
		combat.update(DT, context)
	if health.current > 1 + CombatSystem.LEECH_HEAL:
		_fail("un coup rend %d PV : la Ponction se compte encore en dégâts d'ennemi"
			% (health.current - 1))

	# 2. ET PAS À CHAQUE COUP. Sur la durée du verrou, un seul soin.
	var after: int = health.current
	health.take(Damage.new(after - 1, Element.Kind.FIRE, "enemy"))
	var shots := 0
	for i in int((CombatSystem.LEECH_LOCK - 2.0) / DT):
		combat.update(DT, context)
		if combat.use(stats.attack, context):
			shots += 1
	if shots < 3:
		_fail("le test n'a tiré que %d fois : il ne prouve rien" % shots)
	if health.current > 1:
		_fail("la Ponction resoigne pendant son verrou : %d PV après %d coups"
			% [health.current, shots])

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

	# 1. AUCUN autre sort du jeu N'ATTEINT ce qu'une haie protège. C'est la
	#    promesse inverse, et c'est elle qui donne son prix à l'ultime.
	#
	#    ⚠️ LA RÈGLE PORTE SUR LA PORTÉE, PAS SUR LE DÉPLACEMENT. Elle a été
	#    précisée le 2026-08-28 : ce qu'elle protège, c'est qu'aucun sort ne
	#    FRAPPE à travers une haie — c'est ce qui rendrait l'ultime ordinaire.
	#    Une TRANSLATION qui franchit un mur ne frappe rien : elle déplace son
	#    lanceur, ça se voit entièrement, et ça ne retire rien à personne. Le
	#    Passage du Sorcier des Ténèbres en dépend pour exister (voir plus bas).
	for character in CharacterCatalog.all():
		for ability in character.action_bar():
			if ability == null or ability.is_ultimate:
				continue
			if ability.kind == Ability.Kind.BLINK:
				continue
			# L'EXCEPTION ÉCRITE : l'Archange du Ciel. Frapper par-dessus les haies EST son trait,
			# Vue d'en haut, choisi pour lui le 2026-11-03 ; il le paie de 3 PV et d'une portée courte,
			# et chacun de ses coups se voit tomber du ciel ou passer les haies.
			if ability.element == Element.Kind.SKY:
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


## Marche le mage de `steps` cases, à une par dixième de seconde.
func _walk_chrono(grid: MazeGrid, combat: CombatSystem, context: CombatContext, steps: int) -> void:
	var from := context.player_cell
	var previous := from
	for i in steps:
		for way: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next := context.player_cell + way
			if grid.is_floor_v(next) and next != previous:
				previous = context.player_cell
				context.player_cell = next
				break
		for tick in 6:
			combat.update(DT, context)


func _test_chrono() -> void:
	var chrono := CharacterCatalog.chrono()
	# RETOUR : il ramène à la case d'il y a 4 s, et refuse s'il n'a pas bougé.
	var parts := _context(chrono)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	var refused := {"reason": ""}
	combat.use_refused.connect(func(reason: String) -> void: refused["reason"] = reason)
	combat.update(DT, context)
	if combat.use(chrono.escape, context) or refused["reason"] != "immobile":
		_fail("retour : il part alors que le mage n'a pas bougé")
	var start := context.player_cell
	_walk_chrono(grid, combat, context, 3)
	var landed := {"cell": Vector2i(-1, -1)}
	combat.blink_performed.connect(func(_f: Vector2i, to: Vector2i) -> void: landed["cell"] = to)
	if not combat.use(chrono.escape, context) or landed["cell"] != start:
		_fail("retour : attendu %s, lu %s" % [start, landed["cell"]])

	# ÉCHO : le double frappe une fois ce qu'il croise sur la trace.
	parts = _context(chrono)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	start = context.player_cell
	combat.update(DT, context)
	if combat.use(chrono.abilities[1], context):
		_fail("écho : il part sans aucune trace")
	_walk_chrono(grid, combat, context, 3)
	_add_enemy(context, start, 500)
	if not combat.use(chrono.abilities[1], context):
		_fail("écho : il refuse une vraie trace")
	for i in 120:
		combat.update(DT, context)
	if context.enemy_health[0].current != 500 - chrono.abilities[1].damage:
		_fail("écho : attendu un seul coup, lu %d PV" % context.enemy_health[0].current)

	# SABLIER : la moitié des points perdus, arrondie au-dessus, et seulement à la fin.
	parts = _context(chrono)
	combat = parts[1]; context = parts[2]; health = parts[3]
	combat.use(chrono.abilities[2], context)
	for i in 3:
		health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	for i in int(chrono.abilities[2].duration / DT) - 5:
		combat.update(DT, context)
	if health.current != 1:
		_fail("sablier : il rend avant la fin (%d PV)" % health.current)
	for i in 10:
		combat.update(DT, context)
	if health.current != 3:
		_fail("sablier : attendu 3 PV après 3 coups, lu %d" % health.current)

	# ARRÊT DU TEMPS : tout ennemi vivant est figé, les jets aussi, puis tout repart.
	parts = _context(chrono)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 100)
	var frozen := {"duration": 0.0}
	combat.enemy_staggered.connect(func(_i: int, d: float) -> void: frozen["duration"] = d)
	combat.use(chrono.ultimate, context)
	if frozen["duration"] != chrono.ultimate.duration or combat.time_factor_at(start) != 0.0:
		_fail("arrêt du temps : les ennemis ou les jets ne sont pas figés")
	for i in int(chrono.ultimate.duration / DT) + 2:
		combat.update(DT, context)
	if combat.time_factor_at(start) != 1.0:
		_fail("arrêt du temps : le temps ne repart pas")

	# BULLE : les jets qui visent l'intérieur ralentissent, ceux d'ailleurs non.
	parts = _context(chrono)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	combat.use(chrono.abilities[0], context)
	if combat.time_factor_at(context.player_cell) != chrono.abilities[0].time_factor:
		_fail("bulle : un jet qui y tombe n'est pas ralenti")
	if combat.time_factor_at(context.player_cell + Vector2i(9, 0)) != 1.0:
		_fail("bulle : un jet loin d'elle est ralenti")
	print("chronomancien : retour, écho, sablier, arrêt du temps et bulle : OK")


func _test_peste() -> void:
	var peste := CharacterCatalog.peste()
	var trail: Ability = peste.abilities[0]
	var contagion: Ability = peste.abilities[1]
	var transfusion: Ability = peste.abilities[2]
	# VENIN : les doses s'additionnent, plafonnées, et prélèvent ensemble.
	var parts := _context(peste)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 1000)
	for i in 5:
		combat._apply_trait(0, 1, peste.attack, context)
	if combat.venom_doses(0) != CombatSystem.VENOM_MAX:
		_fail("venin : attendu %d doses, lu %d" % [CombatSystem.VENOM_MAX, combat.venom_doses(0)])
	for i in int(CombatSystem.VENOM_TICK / DT) + 2:
		combat.update(DT, context)
	if context.enemy_health[0].current != 1000 - CombatSystem.VENOM_MAX * CombatSystem.VENOM_DAMAGE:
		_fail("venin : les doses ne prélèvent pas ensemble (%d PV)" % context.enemy_health[0].current)

	# TRAÎNÉE : une flaque sur la case quittée, qui empoisonne ce qui marche dessus.
	parts = _context(peste)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	var start := context.player_cell
	combat.update(DT, context)
	combat.use(trail, context)
	_walk_chrono(grid, combat, context, 2)
	_add_enemy(context, start, 500)
	combat.update(DT, context)
	if combat.venom_doses(0) != 1:
		_fail("traînée : la flaque n'empoisonne pas (%d doses)" % combat.venom_doses(0))

	# CONTAGION : refusée sans foyer, elle donne ses doses aux voisins.
	parts = _context(peste)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 500)
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 500)
	if combat.use(contagion, context):
		_fail("contagion : elle part sans aucun ennemi empoisonné")
	combat._add_venom(0, context, 2)
	if not combat.use(contagion, context) or combat.venom_doses(1) != 2:
		_fail("contagion : le voisin a %d doses au lieu de 2" % combat.venom_doses(1))

	# TRANSFUSION : refusée en pleine santé, un point pour deux ennemis empoisonnés.
	health = parts[3]
	if combat.use(transfusion, context):
		_fail("transfusion : elle part en pleine santé")
	health.take(Damage.new(2, Element.Kind.SHADOW, "enemy"))
	var before := health.current
	if not combat.use(transfusion, context) or health.current != before + 1:
		_fail("transfusion : attendu %d PV, lu %d" % [before + 1, health.current])

	# BRUME : le nuage reste au départ et empoisonne.
	parts = _context(peste)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	for way: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if grid.is_floor_v(context.player_cell + way):
			context.player_facing = way
			break
	_add_enemy(context, context.player_cell, 500)
	if not combat.use(peste.escape, context):
		_fail("brume : le saut est refusé")
	for i in 3:
		combat.update(DT, context)
	if combat.venom_doses(0) != 1:
		_fail("brume : le nuage n'empoisonne pas")

	# PANDÉMIE : toute la carte, jamais les repaires, et le mort éclate en nuage.
	parts = _context(peste)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 9), 15)
	_add_enemy(context, _cell_at(grid, context.player_field, 12), 500)
	context.structures_from = 1
	var clouds := {"count": 0}
	combat.zone_created.connect(func(_i: int, _a: Ability, _c: Vector2i) -> void: clouds["count"] += 1)
	var kills := {"count": 0}
	combat.venom_killed.connect(func(_c: Vector2i) -> void: kills["count"] += 1)
	combat.use(peste.ultimate, context)
	if combat.venom_doses(1) != 0:
		_fail("pandémie : le repaire est empoisonné")
	if combat.venom_doses(0) != CombatSystem.VENOM_MAX:
		_fail("pandémie : la créature n'a pas toutes ses doses")
	for i in int(CombatSystem.VENOM_TICK / DT) + 2:
		combat.update(DT, context)
	if kills["count"] != 1 or clouds["count"] != 1:
		_fail("pandémie : %d mort(s) et %d nuage(s), attendu 1 et 1" % [kills["count"], clouds["count"]])
	print("mage de la peste : venin, traînée, contagion, transfusion, brume et pandémie : OK")


func _test_lumiere() -> void:
	var lumiere := CharacterCatalog.lumiere()
	var lance: Ability = lumiere.abilities[0]
	var sanctuary: Ability = lumiere.abilities[1]
	var wings: Ability = lumiere.abilities[2]
	var blinded := {}
	# IA : aveuglé, il ne suit plus le mage, puis reprend sa poursuite.
	var parts := _context(lumiere)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	var from := _cell_at(grid, context.player_field, 3)
	var brain := EnemyAI.new(8, 7)
	brain.blind_left = 0.2
	brain.decide(grid, from, Vector2i.ZERO, context.player_field, DT)
	if brain.state != EnemyAI.State.PATROL:
		_fail("aveuglement : l'ennemi poursuit encore")
	brain.blind_left = 0.0
	brain.decide(grid, from, Vector2i.ZERO, context.player_field, DT)
	if brain.state != EnemyAI.State.CHASE:
		_fail("aveuglement : l'ennemi ne reprend pas sa poursuite")

	# ÉBLOUISSEMENT : pas deux fois de suite sur la même créature.
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 1000)
	combat.enemy_blinded.connect(func(i: int, d: float) -> void:
		blinded[i] = int(blinded.get(i, 0)) + 1)
	combat._apply_trait(0, 1, lumiere.attack, context)
	combat._apply_trait(0, 1, lumiere.attack, context)
	if int(blinded.get(0, 0)) != 1:
		_fail("éblouissement : verrou absent, %d aveuglements d'affilée" % int(blinded.get(0, 0)))
	for i in int((CombatSystem.GLARE_SECONDS + CombatSystem.BLIND_LOCK) / DT) + 2:
		combat.update(DT, context)
	combat._apply_trait(0, 1, lumiere.attack, context)
	if int(blinded.get(0, 0)) != 2:
		_fail("éblouissement : il ne revient jamais après le verrou")

	# LANCE : elle touche ce qui est devant elle.
	parts = _context(lumiere)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	for way: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if grid.is_floor_v(context.player_cell + way):
			context.player_facing = way
			break
	_add_enemy(context, context.player_cell + context.player_facing, 500)
	if not combat.use(lance, context) or context.enemy_health[0].current != 500 - lance.damage:
		_fail("lance : l'ennemi en ligne n'est pas touché")

	# LANCE : elle tourne dans les couloirs jusqu'à sa proie, sans dépasser sa portée.
	parts = _context(lumiere)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	var far := _cell_at(grid, context.player_field, 7)
	var to_prey := Pathfinder.distance_field(grid, [far] as Array[Vector2i])
	context.player_facing = Pathfinder.step_toward(grid, to_prey, context.player_cell)
	_add_enemy(context, far, 500)
	var beam_path := {"cells": []}
	combat.beam_fired.connect(func(_from: Vector2i, cells: Array) -> void: beam_path["cells"] = cells)
	if not combat.use(lance, context) or context.enemy_health[0].current != 500 - lance.damage:
		_fail("lance : la proie au bout des couloirs n'est pas touchée")
	var route: Array = beam_path["cells"]
	if route.size() > lance.range:
		_fail("lance : le rayon dépasse sa portée (%d cases)" % route.size())
	var previous: Vector2i = context.player_cell
	for cell: Vector2i in route:
		if not grid.is_floor_v(cell) or absi(cell.x - previous.x) + absi(cell.y - previous.y) != 1:
			_fail("lance : le trajet traverse un mur ou saute une case")
		previous = cell

	# SANCTUAIRE : ce qui y entre est aveuglé.
	parts = _context(lumiere)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	blinded.clear()
	combat.enemy_blinded.connect(func(i: int, d: float) -> void: blinded[i] = d)
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 500)
	combat.use(sanctuary, context)
	for i in 3:
		combat.update(DT, context)
	if blinded.get(0, 0.0) != sanctuary.blind_seconds:
		_fail("sanctuaire : l'ennemi qui y entre n'est pas aveuglé")

	# AILES : un coup absorbé, puis l'éclair aveugle le contact.
	parts = _context(lumiere)
	grid = parts[0]; combat = parts[1]; context = parts[2]; health = parts[3]
	blinded.clear()
	combat.enemy_blinded.connect(func(i: int, d: float) -> void: blinded[i] = d)
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 500)
	combat.use(wings, context)
	var before := health.current
	health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	if health.current != before:
		_fail("ailes : le coup n'est pas absorbé")
	combat.update(DT, context)
	if blinded.get(0, 0.0) != wings.blind_seconds:
		_fail("ailes : l'attaquant n'est pas aveuglé")

	# ENVOL : par-dessus les haies, et l'atterrissage aveugle.
	if not lumiere.escape.pierces_walls or lumiere.escape.blind_radius <= 0:
		_fail("envol : il doit survoler les haies et aveugler en atterrissant")

	# L'AUBE : chaque créature de la carte, pas les repaires, malgré le verrou.
	parts = _context(lumiere)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	blinded.clear()
	_add_enemy(context, _cell_at(grid, context.player_field, 12), 500)
	_add_enemy(context, _cell_at(grid, context.player_field, 9), 500)
	context.structures_from = 1
	combat._blind(0, 0.1, context)
	combat.enemy_blinded.connect(func(i: int, d: float) -> void: blinded[i] = d)
	combat.use(lumiere.ultimate, context)
	for i in int((CombatSystem.DAWN_DELAY + 0.3) / DT):
		combat.update(DT, context)
	if blinded.get(0, 0.0) != lumiere.ultimate.blind_seconds:
		_fail("aube : l'ennemi n'est pas aveuglé, verrou compris")
	if context.enemy_health[0].current != 500 - lumiere.ultimate.damage:
		_fail("aube : l'ennemi lointain n'est pas touché")
	if blinded.has(1):
		_fail("aube : le repaire est aveuglé")
	print("porte-lumière : aveuglement, lance, sanctuaire, ailes et aube : OK")


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


## LES PICS DE TERRE COURENT DANS LE COULOIR, ils n'entourent pas le mage.
##
## Le sort était un souffle circulaire — la même mécanique que trois autres du
## jeu. Ces épreuves gardent les deux temps qui en font un sort de Terre : la
## gerbe qui FILE, et les pointes qui RESTENT.
func _test_earth_line() -> void:
	var stats := CharacterCatalog.earth()
	var spikes: Ability = stats.abilities[0]
	if spikes.kind != Ability.Kind.LINE:
		_fail("les Pics de terre ne courent pas : ce n'est pas une ligne")
		return
	if spikes.duration <= 0.0 or spikes.line_bite <= 0:
		_fail("les pics ne restent pas plantés : la moitié du sort manque")

	# 1. LE CHEMIN. On le relève d'abord à vide, sur une grille de graine fixe :
	#    il servira ensuite à poser une créature dessus.
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var route := {"path": [] as Array}
	combat.line_erupted.connect(func(_a: Ability, path: Array, _d: float) -> void:
		route["path"] = path)
	if not combat.use(spikes, context):
		_fail("les Pics de terre refusent de partir depuis le départ du mage")
		return
	var path: Array = route["path"]
	if path.size() < 2:
		_fail("la gerbe ne fait que %d case : ce n'est pas une ligne" % path.size())
		return
	# Chaque case du chemin est praticable et TOUCHE la précédente : une ligne
	# qui saute par-dessus un mur serait un sort qui traverse la pierre.
	var previous: Vector2i = context.player_cell
	for step in path:
		var cell: Vector2i = step
		if not grid.is_floor_v(cell):
			_fail("la gerbe passe dans un mur en %s" % cell)
		if absi(cell.x - previous.x) + absi(cell.y - previous.y) != 1:
			_fail("la gerbe saute de %s à %s" % [previous, cell])
		previous = cell

	# 2. L'ÉRUPTION frappe ce qu'elle croise, UNE SEULE FOIS — même une créature
	#    qui RECULE devant elle.
	#
	#    ⚠️ La première version de cette épreuve ne prouvait rien : elle posait
	#    une créature immobile, et une créature immobile n'est de toute façon à
	#    portée que d'une seule case. Sabotée, la mémoire des touchés n'a fait
	#    crier personne. On fait donc reculer la créature AU RYTHME de la gerbe,
	#    ce qui est le seul cas où cette mémoire compte.
	parts = _context(stats)
	combat = parts[1]
	context = parts[2]
	var victim: Vector2i = path[1]
	_add_enemy(context, victim, 900)
	var coups := {"n": 0, "total": 0}
	combat.enemy_damaged.connect(func(_i: int, dealt: int, _a: Ability) -> void:
		coups["n"] += 1
		coups["total"] += dealt)
	combat.use(spikes, context)
	var pas := spikes.range / maxf(1.0, spikes.line_speed) / float(path.size())
	var couru := 0.0
	for i in int(1.0 / DT):
		combat.update(DT, context)
		couru += DT
		var devant := int(couru / pas)
		if devant < path.size():
			context.enemy_cells[0] = path[devant]
	if coups["n"] == 0:
		_fail("la gerbe traverse la créature sans la toucher")
	var eruption: int = coups["total"]
	if eruption > spikes.damage + stats.attack.damage:
		_fail("la créature encaisse %d pour une gerbe à %d : elle est frappée à chaque case"
			% [eruption, spikes.damage])

	# 3. LES POINTES RESTENT. C'est le second temps du sort, celui qui en fait
	#    du terrain plutôt qu'un tir : la créature qui campe dessus continue
	#    d'être mordue longtemps après le passage de la gerbe.
	var plantes := {"posees": 0, "finies": 0}
	combat.zone_created.connect(func(_id: int, _a: Ability, _c: Vector2i) -> void:
		plantes["posees"] += 1)
	combat.zone_expired.connect(func(_id: int) -> void: plantes["finies"] += 1)
	parts = _context(stats)
	combat = parts[1]
	context = parts[2]
	_add_enemy(context, victim, 900)
	combat.zone_created.connect(func(_id: int, _a: Ability, _c: Vector2i) -> void:
		plantes["posees"] += 1)
	combat.zone_expired.connect(func(_id: int) -> void: plantes["finies"] += 1)
	var morsures := {"total": 0}
	combat.use(spikes, context)
	for i in int(0.6 / DT):
		combat.update(DT, context)
	combat.enemy_damaged.connect(func(_i: int, dealt: int, _a: Ability) -> void:
		morsures["total"] += dealt)
	for i in int((spikes.duration - 0.8) / DT):
		combat.update(DT, context)
	if plantes["posees"] != path.size():
		_fail("%d pics plantés pour %d cases parcourues"
			% [plantes["posees"], path.size()])
	if morsures["total"] <= 0:
		_fail("les pics plantés ne mordent pas ce qui reste dessus")

	# 4. Et ils s'effacent : un couloir hérissé pour toujours serait un mur, et
	#    le mage en a déjà un.
	for i in int(2.0 / DT):
		combat.update(DT, context)
	if plantes["finies"] != plantes["posees"]:
		_fail("%d pics sur %d se sont effacés : le couloir reste fermé"
			% [plantes["finies"], plantes["posees"]])
	var stables: int = morsures["total"]
	for i in int(1.5 / DT):
		combat.update(DT, context)
	if morsures["total"] != stables:
		_fail("les pics mordent encore après avoir disparu")


## L'ÉGIDE DE PIERRE est un RÉPIT, pas une réserve.
##
## C'est la seule immunité du jeu. Trois promesses la tiennent : rien ne
## l'entame, elle s'achève à l'heure dite, et la fenêtre où le mage est
## vulnérable reste plus longue que celle où il ne l'est pas — sans quoi le
## sort ne serait pas un sort mais un état permanent.
func _test_earth_aegis() -> void:
	var stats := CharacterCatalog.earth()
	var aegis: Ability = stats.abilities[1]
	if aegis.kind != Ability.Kind.SHIELD or not aegis.immune:
		_fail("l'Égide de pierre ne rend pas intouchable")
		return
	if aegis.cooldown <= aegis.duration:
		_fail("l'Égide dure %.0f s et revient toutes les %.0f s : l'immunité est permanente"
			% [aegis.duration, aegis.cooldown])

	var parts := _context(stats)
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]

	# 1. RIEN NE L'ENTAME. Le bouclier de l'Eau, lui, se serait vidé.
	var refuses := {"n": 0}
	health.deflected.connect(func() -> void: refuses["n"] += 1)
	combat.use(aegis, context)
	for coup in 12:
		health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	if health.current != stats.base_health:
		_fail("le mage intouchable perd des points de vie (%d sur %d)"
			% [health.current, stats.base_health])
	if refuses["n"] != 12:
		_fail("%d coups sur 12 seulement ont été refusés" % refuses["n"])

	# 2. ELLE S'ACHÈVE. Une immunité qu'on oublie d'éteindre ne se voit pas :
	#    le mage traverse le reste du niveau sans rien risquer et personne ne
	#    s'en aperçoit avant la fin de la partie.
	for i in int((aegis.duration - 1.0) / DT):
		combat.update(DT, context)
	if not health.immune:
		_fail("l'Égide s'est éteinte avant son heure")
	for i in int(2.0 / DT):
		combat.update(DT, context)
	if health.immune:
		_fail("l'Égide ne s'éteint jamais : le mage est invincible pour toujours")
	health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	if health.current != stats.base_health - 1:
		_fail("le mage encaisse encore une fois l'Égide tombée")

	# 3. Elle ne fait pas doublon avec le bouclier de l'Eau : l'un absorbe une
	#    quantité, l'autre offre un temps. Deux sorts qui protègent doivent se
	#    jouer différemment, sinon l'un des deux mages est une copie.
	var vague := CharacterCatalog.water().abilities[1]
	if vague.immune:
		_fail("le bouclier de l'Eau rend lui aussi intouchable : les deux se confondent")
	if vague.damage <= 0:
		_fail("le bouclier de l'Eau n'absorbe plus rien")


## L'ORBE TRAVAILLE TOUT SEUL : il s'installe autour du mage et fend le sol dès
## qu'une créature entre à portée.
##
## C'est le seul sort du jeu qui ATTAQUE sans qu'on vise. Trois promesses le
## tiennent : l'orbe dure, il ne frappe que ce qui approche, et son balayage est
## bien une faille de couloir — pas un dégât appliqué à distance.
func _test_earth_rift() -> void:
	var stats := CharacterCatalog.earth()
	var rift: Ability = stats.abilities[2]
	var spikes: Ability = stats.abilities[0]
	if rift.kind != Ability.Kind.TURRET or not rift.turret_sweep:
		_fail("les Éclats de cristal ne posent pas d'orbe qui balaie")
		return
	if rift.spike_life <= 0.0 or rift.spike_life >= rift.duration:
		_fail("les gerbes de l'orbe durent %.0f s pour un orbe de %.0f s : "
			% [rift.spike_life, rift.duration] + "le couloir ne se rouvre pas")

	# 1. UNE PROIE TROP LOIN NE DÉCLENCHE RIEN.
	#
	#    ⚠️ La première version de cette épreuve ne posait AUCUNE créature et
	#    vérifiait qu'il ne se passait rien : elle ne prouvait donc pas que la
	#    portée était respectée, seulement qu'un orbe seul reste tranquille.
	#    Sabotée (portée multipliée par cinq), elle n'a fait crier personne.
	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var lointaine := _cell_at(grid, context.player_field, rift.range + 4)
	if lointaine.x >= 0:
		_add_enemy(context, lointaine, 9000)
	var failles := {"n": 0, "cases": 0}
	combat.line_erupted.connect(func(_a: Ability, path: Array, _d: float) -> void:
		failles["n"] += 1
		failles["cases"] = path.size())
	if not combat.use(rift, context):
		_fail("l'orbe refuse de se poser")
		return
	for i in int(3.0 / DT):
		combat.update(DT, context)
	if failles["n"] > 0:
		_fail("l'orbe balaie le couloir vers une proie hors de portée")

	# 2. UNE PROIE ENTRE À PORTÉE : le balayage part TOUT SEUL, et il blesse.
	var proie := _cell_at(grid, context.player_field, 3)
	if proie.x < 0:
		_fail("pas de case à trois pas pour poser la proie")
		return
	_add_enemy(context, proie, 9000)
	var coups := {"total": 0}
	combat.enemy_damaged.connect(func(_i: int, dealt: int, _a: Ability) -> void:
		coups["total"] += dealt)
	for i in int(rift.turret_interval / DT + 4):
		combat.update(DT, context)
	if failles["n"] == 0:
		_fail("une créature est à portée et l'orbe ne fend rien")
	if coups["total"] < rift.damage:
		_fail("le balayage passe sous la créature sans la blesser (%d dégâts)"
			% coups["total"])
	# La faille suit le COULOIR jusqu'à elle : trois pas de marche, donc au
	# plus trois cases de gerbes. Un dégât appliqué à distance n'en lèverait
	# aucune.
	if failles["cases"] <= 0 or failles["cases"] > rift.range:
		_fail("la faille couvre %d cases pour une portée de %d"
			% [failles["cases"], rift.range])

	# 3. IL S'ÉTEINT, et le couloir cesse de s'ouvrir.
	for i in int(rift.duration / DT):
		combat.update(DT, context)
	var stables: int = failles["n"]
	for i in int(4.0 / DT):
		combat.update(DT, context)
	if failles["n"] != stables:
		_fail("l'orbe balaie encore après s'être éteint")

	# 4. Il ne fait pas doublon avec les Pics : ceux-là se VISENT, à la main,
	#    devant soi. Celui-ci travaille seul pendant qu'on fait autre chose.
	if spikes.kind == Ability.Kind.TURRET:
		_fail("les Pics de terre travaillent eux aussi tout seuls")
	if spikes.duration <= rift.spike_life:
		_fail("les gerbes des Pics ne tiennent pas plus que celles de l'orbe")


## LE SÉISME : le sol tremble, et les PAROIS cèdent.
##
## C'est un ultime de terrain, pas une détonation. Ses promesses : il dure, il
## fait tomber des pans de mur par vagues, ces pans blessent, et il s'arrête.
func _test_earth_quake() -> void:
	var stats := CharacterCatalog.earth()
	var quake := stats.ultimate
	if quake.quake_duration <= 0.0:
		_fail("le Séisme ne fait pas trembler la terre")
		return

	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	# Une créature LOIN du mage : elle ne doit rien encaisser de la détonation
	# initiale, seulement des éboulements. C'est ce qui prouve que le séisme
	# frappe le labyrinthe entier et pas un cercle autour du lanceur.
	var loin := _cell_at(grid, context.player_field, 12)
	if loin.x < 0:
		_fail("pas de case à douze pas pour poser la proie")
		return
	_add_enemy(context, loin, 90000)

	# On compte les pans par MOITIÉ de séisme : la promesse est que ça commence
	# en avalanche et finit en grondement.
	var pans := {"n": 0, "debut": 0, "fin": 0, "loin": 0}
	var horloge := {"t": 0.0}
	combat.quake_slide.connect(func(cell: Vector2i, _a: Ability) -> void:
		pans["n"] += 1
		if horloge["t"] < quake.quake_duration * 0.5:
			pans["debut"] += 1
		else:
			pans["fin"] += 1
		# Et le séisme secoue le LABYRINTHE, pas un cercle autour du mage : on
		# note ce qui cède au-delà de la portée de la détonation initiale.
		var distance := Pathfinder.value_at(grid, context.player_field, cell)
		if distance > int(quake.radius) + 2:
			pans["loin"] += 1)
	var secousse := {"duree": 0.0}
	combat.quake_started.connect(func(duration: float, _a: Ability) -> void:
		secousse["duree"] = duration)
	var degats := {"total": 0}
	combat.enemy_damaged.connect(func(_i: int, dealt: int, _a: Ability) -> void:
		degats["total"] += dealt)

	combat.use(quake, context)
	if not is_equal_approx(secousse["duree"], quake.quake_duration):
		_fail("la secousse annoncée dure %.1f s au lieu de %.1f"
			% [secousse["duree"], quake.quake_duration])
	for i in int(quake.quake_duration / DT):
		horloge["t"] = float(i) * DT
		combat.update(DT, context)

	if pans["n"] < 6:
		_fail("%d pans cèdent en %.0f s de séisme" % [pans["n"], quake.quake_duration])
	# L'AVALANCHE PUIS LE GRONDEMENT. C'est la texture du sort, et la seule
	# chose qui le sépare vraiment de la pluie du Feu — celle-ci tombe à cadence
	# égale du début à la fin.
	# ⚠️ Un simple « plus au début qu'à la fin » ne prouvait RIEN : la toute
	#    première vague part à l'instant zéro, ce qui suffit à faire pencher la
	#    moitié initiale même à cadence constante. Sabotée, l'épreuve passait.
	#    On exige donc un écart d'un tiers, que seule une vraie décélération
	#    produit.
	if float(pans["debut"]) < float(pans["fin"]) * 1.33:
		_fail("%d pans dans la première moitié contre %d dans la seconde : "
			% [pans["debut"], pans["fin"]] + "le séisme ne se calme pas assez")
	if pans["loin"] <= 0:
		_fail("aucun pan ne cède au-delà du souffle : ce n'est pas un séisme")
	# LE TREMBLEMENT BLESSE, même loin du lanceur. Sans ce fond continu,
	# l'ultime était un spectacle : mesuré, vingt-sept éboulements tirés au sort
	# sur six cents cases ne touchent une créature donnée qu'une fois sur cinq.
	if degats["total"] <= 0:
		_fail("une créature à douze pas traverse tout le Séisme sans une égratignure")
	if quake.quake_tremor <= 0:
		_fail("le tremblement lui-même ne fait rien : seuls les pans frappent")

	# Il S'ARRÊTE. Un séisme qui continue ferait trembler le reste du niveau.
	var stables: int = pans["n"]
	for i in int(4.0 / DT):
		combat.update(DT, context)
	if pans["n"] != stables:
		_fail("la terre tremble encore après la fin du Séisme")

	# Il ne fait pas doublon avec l'Embrasement du Feu : celui-là fait pleuvoir
	# des météores n'importe où, celui-ci effondre les parois.
	var nova := CharacterCatalog.fire().ultimate
	if nova.quake_duration > 0.0:
		_fail("l'ultime du Feu fait trembler la terre lui aussi")
	if quake.rain_count > 0:
		_fail("le Séisme fait pleuvoir des météores : c'est l'ultime du Feu")


## LA TORNADE AVANCE ET EMPORTE. C'est le pilier de l'Air : le déplacement.
##
## Rien d'autre dans le jeu ne fait parcourir des cases à une créature — le
## trait de l'élément la pousse de deux cases, une fois. Trois promesses : elle
## marche, elle charrie ce qu'elle attrape, et elle n'est pas une quatrième
## zone posée.
func _test_air_tornado() -> void:
	var stats := CharacterCatalog.air()
	var tornado: Ability = stats.abilities[0]
	if tornado.zone_travel <= 0.0:
		_fail("la Tornade ne bouge pas : c'est une zone posée de plus")
		return
	if not tornado.zone_carries:
		_fail("la Tornade n'emporte rien")

	# Les trois autres zones du jeu restent posées : c'est ce qui distingue
	# celle-ci, et rien n'empêcherait de le perdre en réglant un chiffre.
	for autre in [CharacterCatalog.fire().abilities[1],
			CharacterCatalog.water().abilities[2],
			CharacterCatalog.thunder().abilities[1]]:
		if autre.zone_travel > 0.0:
			_fail("« %s » se déplace elle aussi : l'Air perd son pilier"
				% autre.display_name)

	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	# Une créature juste devant le mage, sur le chemin de la tornade.
	var proie := _cell_at(grid, context.player_field, 1)
	if proie.x < 0:
		_fail("pas de case voisine pour poser la proie")
		return
	_add_enemy(context, proie, 9000)
	var depart := proie

	var marche := {"n": 0}
	combat.zone_moved.connect(func(_id: int, _c: Vector2i) -> void:
		marche["n"] += 1)
	var portee := {"n": 0}
	combat.enemy_pushed.connect(func(_i: int, _c: Vector2i) -> void:
		portee["n"] += 1)

	combat.use(tornado, context)
	for i in int(tornado.duration / DT):
		combat.update(DT, context)

	# 1. ELLE MARCHE, et pas d'une case ou deux.
	if marche["n"] < 3:
		_fail("la Tornade n'a changé de case que %d fois" % marche["n"])

	# 2. ELLE EMPORTE : la créature a fait du CHEMIN, bien plus que les deux
	#    cases du souffle élémentaire.
	var arrivee: Vector2i = context.enemy_cells[0]
	var voyage := Pathfinder.value_at(grid, Pathfinder.distance_field(grid,
		[depart] as Array[Vector2i]), arrivee)
	if portee["n"] <= 0:
		_fail("la créature n'a pas bougé d'un pouce")
	elif voyage <= CombatSystem.PUSH_CELLS:
		_fail("la créature a voyagé de %d cases, le simple souffle de l'Air en "
			% voyage + "fait %d : la Tornade n'emporte pas" % CombatSystem.PUSH_CELLS)

	# 3. Elle s'éteint, et la créature reste où elle a été lâchée.
	for i in int(2.0 / DT):
		combat.update(DT, context)
	if context.enemy_cells[0] != arrivee:
		_fail("la créature bouge encore après la fin de la Tornade")


## LE GRAND SOUFFLE PROJETTE, ET LE MUR FAIT LE RESTE.
##
## Le sort s'appelait « Bourrasque » — comme le TRAIT de l'élément — et
## annonçait qu'il balayait le couloir sans rien pousser. Trois promesses le
## tiennent maintenant : il projette loin, le choc contre la pierre coûte, et
## il ne fait pas doublon avec la Tornade.
func _test_air_gust() -> void:
	var stats := CharacterCatalog.air()
	var gust: Ability = stats.abilities[1]
	var tornado: Ability = stats.abilities[0]
	if gust.blow_cells <= 0:
		_fail("le Grand souffle ne projette rien : il « balaie » toujours à vide")
		return
	if gust.blow_cells <= CombatSystem.PUSH_CELLS:
		_fail("il projette de %d cases, le simple souffle de l'élément en fait %d"
			% [gust.blow_cells, CombatSystem.PUSH_CELLS])
	if gust.display_name == Element.trait_name(Element.Kind.AIR):
		_fail("le sort porte le nom du trait de l'élément : deux choses, un mot")

	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var proie := _cell_at(grid, context.player_field, 1)
	if proie.x < 0:
		_fail("pas de case voisine pour poser la proie")
		return
	_add_enemy(context, proie, 9000)

	var envoyes := {"n": 0}
	var plaques := {"n": 0}
	combat.enemy_pushed.connect(func(_i: int, _c: Vector2i) -> void:
		envoyes["n"] += 1)
	combat.enemy_slammed.connect(func(_i: int, _c: Vector2i) -> void:
		plaques["n"] += 1)
	var encaisse := {"total": 0}
	combat.enemy_damaged.connect(func(_i: int, dealt: int, _a: Ability) -> void:
		encaisse["total"] += dealt)

	combat.use(gust, context)
	if envoyes["n"] == 0:
		_fail("la créature collée au mage n'est pas projetée")
	var arrivee: Vector2i = context.enemy_cells[0]
	var voyage := Pathfinder.value_at(grid, Pathfinder.distance_field(grid,
		[proie] as Array[Vector2i]), arrivee)
	if voyage <= 0:
		_fail("la créature n'a pas quitté sa case")

	# LE CHOC. Selon le labyrinthe, la course peut être libre ou bloquée : on
	# vérifie la RÈGLE — si elle a été plaquée, elle a payé plus cher que le
	# souffle seul ; sinon, elle a fait toute la distance annoncée.
	if plaques["n"] > 0:
		if voyage >= gust.blow_cells:
			_fail("le choc a été compté alors que la course était libre")
		if encaisse["total"] <= gust.damage:
			_fail("plaquée contre la pierre, elle n'encaisse que %d — pas de choc"
				% encaisse["total"])
	elif voyage < gust.blow_cells:
		_fail("course écourtée à %d cases sur %d, et aucun choc compté"
			% [voyage, gust.blow_cells])

	# LE CHOC, POUR DE BON.
	#
	# ⚠️ La première version de cette épreuve ne vérifiait la règle du mur que
	#    SI le hasard du labyrinthe avait bloqué la course. Il ne l'avait pas
	#    fait : sabotée, elle n'a rien dit. On fabrique donc le cas — le mage
	#    devant un CUL-DE-SAC, la créature au fond. Elle ne peut aller nulle
	#    part, donc elle prend le mur.
	var impasse := Vector2i(-1, -1)
	for cell in grid.all_floor_cells():
		var issues := 0
		for side in MazeGrid.NEIGHBORS:
			if grid.is_floor_v(cell + side):
				issues += 1
		if issues == 1:
			impasse = cell
			break
	if impasse.x >= 0:
		parts = _context(stats)
		combat = parts[1]
		context = parts[2]
		# Le mage se place à l'entrée du cul-de-sac, la créature au fond.
		var entree := impasse
		for side in MazeGrid.NEIGHBORS:
			if grid.is_floor_v(impasse + side):
				entree = impasse + side
				break
		context.player_cell = entree
		context.player_field = Pathfinder.distance_field(grid,
			[entree] as Array[Vector2i])
		_add_enemy(context, impasse, 9000)
		var chocs := {"n": 0}
		var pris := {"total": 0}
		combat.enemy_slammed.connect(func(_i: int, _c: Vector2i) -> void:
			chocs["n"] += 1)
		combat.enemy_damaged.connect(func(_i: int, dealt: int, _a: Ability) -> void:
			pris["total"] += dealt)
		combat.use(gust, context)
		if chocs["n"] == 0:
			_fail("au fond d'un cul-de-sac, la créature n'est pas plaquée")
		if pris["total"] < gust.damage + gust.slam_damage:
			_fail("plaquée sans issue, elle n'encaisse que %d au lieu de %d"
				% [pris["total"], gust.damage + gust.slam_damage])

	# Il ne double pas la Tornade : elle EMMÈNE le long d'un couloir, il ÉCARTE
	# tout autour. Deux sorts de déplacement doivent se jouer autrement.
	if tornado.blow_cells > 0:
		_fail("la Tornade projette elle aussi : les deux sorts se confondent")
	if gust.zone_carries:
		_fail("le Grand souffle emporte lui aussi : c'est la Tornade")


## LES GEYSERS DU GEYSER : une SALVE sur le labyrinthe, pas une colonne sous le
## mage.
##
## La colonne unique montait sous ses pieds et l'EFFAÇAIT une seconde durant —
## le joueur perdait son propre personnage au moment le plus chargé de la
## partie. Neuf colonnes éparpillées frappent ce qui passe et ne cachent rien.
func _test_water_geysers() -> void:
	var stats := CharacterCatalog.water()
	var geyser := stats.ultimate
	if geyser.geyser_count <= 0:
		_fail("le Geyser ne fait jaillir aucune colonne")
		return
	if geyser.column_burst:
		_fail("la colonne sous les pieds du mage est toujours là : elle l'efface")

	var parts := _context(stats)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	# Des créatures un peu partout : avec neuf colonnes sur la carte, au moins
	# une doit tomber sur quelqu'un.
	for pas in [3, 5, 7, 9, 11, 13]:
		var cell := _cell_at(grid, context.player_field, pas)
		if cell.x >= 0:
			_add_enemy(context, cell, 90000)

	var colonnes := {"n": 0, "hors_sol": 0}
	var horloge := {"t": 0.0}
	var tardives := {"n": 0}
	combat.geyser_erupted.connect(func(cell: Vector2i, _a: Ability) -> void:
		colonnes["n"] += 1
		if not grid.is_floor_v(cell):
			colonnes["hors_sol"] += 1
		# UNE SALVE : tout part au lancement. Une colonne qui sortirait plus
		# tard ferait doublon avec la pluie, qui est l'autre moitié du sort.
		if horloge["t"] > 0.0:
			tardives["n"] += 1)

	combat.use(geyser, context)
	if colonnes["n"] < geyser.geyser_count - 2:
		_fail("%d colonnes sur %d ont jailli" % [colonnes["n"], geyser.geyser_count])
	if colonnes["hors_sol"] > 0:
		_fail("%d colonnes jaillissent dans un mur" % colonnes["hors_sol"])

	for i in int(2.0 / DT):
		horloge["t"] = float(i + 1) * DT
		combat.update(DT, context)
	if tardives["n"] > 0:
		_fail("%d colonnes sortent après le lancement : ce n'est plus une salve"
			% tardives["n"])


## La Sentence achève, le Glas marque, les âmes se récoltent et chassent, l'Heure dernière prend
## la moitié des PV de chaque ennemi.
func _test_mort() -> void:
	var mort := CharacterCatalog.mort()
	var moisson: Ability = mort.abilities[0]
	var glas: Ability = mort.abilities[1]
	var ames: Ability = mort.abilities[2]
	# SENTENCE : achevé sous le seuil, intact au-dessus, et jamais un repaire.
	var parts := _context(mort)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 100)
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 100)
	context.enemy_health[0].current = 25
	combat._apply_damage(0, mort.attack, context)
	if context.enemy_alive(0):
		_fail("sentence : la cible à 9 % n'est pas achevée")
	combat._apply_damage(1, mort.attack, context)
	if context.enemy_health[1].current != 100 - mort.attack.damage:
		_fail("sentence : une cible en bonne santé est touchée à tort")
	context.enemy_health[1].current = 40
	context.structures_from = 1
	combat._apply_damage(1, mort.attack, context)
	if context.enemy_health[1].current != 40 - mort.attack.damage:
		_fail("sentence : un repaire est achevé")

	# MOISSON : son seuil monte à 35 %.
	parts = _context(mort)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	var cell := _cell_at(grid, context.player_field, 1)
	context.player_facing = cell - context.player_cell
	_add_enemy(context, cell, 200)
	context.enemy_health[0].current = 110
	if not combat.use(moisson, context) or context.enemy_alive(0):
		_fail("moisson : la cible qu'elle fait passer à 32 % n'est pas achevée")

	# ÂMES : une par victime, trois au plus, et le lâcher les vide.
	if combat._souls != 1:
		_fail("âmes : le coup de grâce ne donne pas d'âme (%d)" % combat._souls)
	combat._souls = CombatSystem.SOUL_MAX
	combat._gain_soul()
	if combat._souls != CombatSystem.SOUL_MAX:
		_fail("âmes : le plafond ne tient pas")
	var sent := {"count": 0}
	combat.soul_sent.connect(func(_path: Array, _duration: float) -> void: sent["count"] += 1)
	if combat.use(ames, context):
		_fail("âmes : le sort part sans proie à portée")
	if combat._souls != CombatSystem.SOUL_MAX:
		_fail("âmes : le sort refusé a coûté ses âmes")
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 500)
	if not combat.use(ames, context) or int(sent["count"]) != 1 + CombatSystem.SOUL_MAX or combat._souls != 0:
		_fail("âmes : %d âmes lâchées au lieu de %d" % [int(sent["count"]), 1 + CombatSystem.SOUL_MAX])
	for i in 120:
		combat.update(DT, context)
	if context.enemy_health[1].current != 500 - ames.damage * (1 + CombatSystem.SOUL_MAX):
		_fail("âmes : les âmes n'ont pas frappé (%d PV)" % context.enemy_health[1].current)

	# GLAS : le marqué prend plus de dégâts, et la marque s'efface.
	parts = _context(mort)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 1000)
	combat.use(glas, context)
	for i in 40:
		combat.update(DT, context)
	if not combat._marked.has(0):
		_fail("glas : l'ennemi du cercle n'est pas marqué")
	var before: int = context.enemy_health[0].current
	combat._apply_damage(0, mort.attack, context, false, false)
	var expected := int(round(float(mort.attack.damage) * (1.0 + CombatSystem.MARK_BONUS)))
	if before - context.enemy_health[0].current != expected:
		_fail("glas : le marqué prend %d au lieu de %d" % [before - context.enemy_health[0].current, expected])

	# HEURE DERNIÈRE : la moitié des PV, et la Sentence juste après.
	parts = _context(mort)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 1000)
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 1000)
	context.enemy_health[1].current = 200
	combat.use(mort.ultimate, context)
	for i in int((CombatSystem.HOUR_DELAY + CombatSystem.HOUR_SWEEP) / DT) + 3:
		combat.update(DT, context)
	if context.enemy_health[0].current != 500:
		_fail("heure : %d PV au lieu de 500" % context.enemy_health[0].current)
	if context.enemy_alive(1):
		_fail("heure : la cible tombée à 10 % n'est pas achevée")
	print("ange de la mort : sentence, moisson, âmes, glas et heure dernière : OK")


## Le trait explose au troisième coup, les rayons brûlent par-dessus les haies, la Pluie tombe sur
## les ennemis, le Voile rend intouchable et la traînée brûle le trajet.
func _test_discorde() -> void:
	var discorde := CharacterCatalog.discorde()
	var oeil: Ability = discorde.abilities[0]
	var cercle: Ability = discorde.abilities[1]
	var lien: Ability = discorde.abilities[2]
	var parts := _context(discorde)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	combat.free_use = true
	var refused := [0]
	combat.use_refused.connect(func(_reason: String) -> void: refused[0] += 1)
	# SEULE, ELLE NE PEUT RIEN : aucun sort ne part dans le vide.
	for ability: Ability in [oeil, cercle, lien, discorde.escape]:
		if combat.use(ability, context):
			_fail("discorde : %s part sans aucun ennemi" % ability.id)
	if refused[0] != 4:
		_fail("discorde : %d refus au lieu de 4" % refused[0])
	# UN POSSÉDÉ FRAPPE SON VOISIN, et le voisin riposte.
	var cell := _cell_at(grid, context.player_field, 2)
	_add_enemy(context, cell, 5000)
	_add_enemy(context, cell, 5000)
	if not combat.use(oeil, context):
		_fail("discorde : le Mauvais Œil ne part pas")
	combat._update_discord(0.01, context)
	for i in 2:
		if context.enemy_health[i].current != 5000 - oeil.possess_strike:
			_fail("discorde : la mêlée laisse l'ennemi %d à %d PV" % [i, context.enemy_health[i].current])
	# SEUL AU MONDE, IL NE FRAPPE PERSONNE : la possession ne fait rien en duel.
	context.enemy_health[1].current = 0
	combat._possessed.clear()
	combat.use(oeil, context)
	var alone: int = context.enemy_health[0].current
	combat._update_discord(1.0, context)
	if context.enemy_health[0].current != alone:
		_fail("discorde : un possédé seul perd des PV")
	# UN BOSS NE SE POSSÈDE PAS, et il ne s'échange pas.
	parts = _context(discorde)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 5000)
	context.bosses[0] = true
	if combat.use(oeil, context) or combat.use(discorde.escape, context):
		_fail("discorde : un boss se laisse retourner")
	if not combat.use(discorde.ultimate, context) or not combat.possessed_indices().is_empty():
		_fail("discorde : la Grande Discorde prend le boss")
	# LE CERCLE MORD SELON LA FOULE.
	parts = _context(discorde)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	cell = _cell_at(grid, context.player_field, 2)
	for i in 3:
		_add_enemy(context, cell, 5000)
	combat.use(cercle, context)
	combat._update_zones(0.01, context)
	var expected := int(round(round(cercle.damage * CombatSystem.ZONE_TICK) * (1.0 + cercle.discord_bonus * 2.0)))
	if context.enemy_health[0].current != 5000 - expected:
		_fail("discorde : le cercle fait %d au lieu de %d" % [5000 - context.enemy_health[0].current, expected])
	# LE LIEN PARTAGE UNE FOIS, sans jamais se relancer.
	parts = _context(discorde)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	cell = _cell_at(grid, context.player_field, 2)
	for i in 3:
		_add_enemy(context, cell, 5000)
	if not combat.use(lien, context):
		_fail("discorde : le lien ne part pas")
	var hit := Ability.make({"id": "x", "kind": Ability.Kind.BLAST, "element": Element.Kind.CHARM, "damage": 100})
	combat._apply_damage(0, hit, context, false, false)
	if context.enemy_health[0].current != 4900 or context.enemy_health[1].current != 4950 \
			or context.enemy_health[2].current != 4950:
		_fail("discorde : le lien partage mal : %d, %d, %d" % [context.enemy_health[0].current,
			context.enemy_health[1].current, context.enemy_health[2].current])
	# L'ÉCHANGE : elle part sur la case de l'ennemi, et lui sur la sienne.
	parts = _context(discorde)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	cell = _cell_at(grid, context.player_field, 2)
	_add_enemy(context, cell, 5000)
	var arrived := [Vector2i(-1, -1)]
	combat.blink_performed.connect(func(_from: Vector2i, to: Vector2i) -> void: arrived[0] = to)
	var home := context.player_cell
	if not combat.use(discorde.escape, context) or arrived[0] != cell or context.enemy_cells[0] != home:
		_fail("discorde : l'échange ne croise pas les places")
	# AU TROISIÈME MURMURE, LA CIBLE EST TROUBLÉE, et sa possession dure plus longtemps.
	parts = _context(discorde)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 5000)
	for i in CombatSystem.WHISPER_MARKS:
		combat._apply_damage(0, discorde.attack, context)
	var seconds := [0.0]
	combat.enemy_possessed.connect(func(_index: int, duration: float) -> void: seconds[0] = duration)
	combat.use(oeil, context)
	if not is_equal_approx(seconds[0], oeil.possess_seconds + CombatSystem.TROUBLE_BONUS):
		_fail("discorde : une possession de %s s sur une cible troublée" % seconds[0])


func _test_braise() -> void:
	var braise := CharacterCatalog.braise()
	var chasseurs: Ability = braise.abilities[0]
	var plastron: Ability = braise.abilities[1]
	var rappel: Ability = braise.abilities[2]
	var parts := _context(braise)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	combat.free_use = true
	if health.plates != CombatSystem.PIECES_MAX or combat.armor_speed() != 0.0:
		_fail("braise : il ne commence pas en armure complète")
	# RIEN NE PART DANS LE VIDE : le rappel sans pièce lancée, ni les chasseurs sans proie.
	if combat.use(rappel, context) or combat.use(chasseurs, context):
		_fail("braise : un sort part sans objet")
	# UN COUP ÉJECTE UNE PIÈCE AU LIEU DE PRENDRE UN PV, et elle blesse autour de lui.
	var close := _cell_at(grid, context.player_field, 1)
	_add_enemy(context, close, 500)
	health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	combat.update(0.016, context)
	if health.current != braise.base_health or health.plates != 2:
		_fail("braise : un coup laisse %d PV et %d pièces" % [health.current, health.plates])
	if context.enemy_health[0].current != 500 - CombatSystem.EJECT_DAMAGE:
		_fail("braise : l'éjection laisse l'ennemi à %d PV" % context.enemy_health[0].current)
	if not is_equal_approx(combat.armor_speed(), CombatSystem.PIECE_SPEED_BONUS):
		_fail("braise : une pièce lancée donne %s de vitesse" % combat.armor_speed())
	# ELLE RENTRE SEULE, sans jamais blesser sur le chemin du retour automatique.
	var before := context.enemy_health[0].current
	for frame in 700:
		combat.update(0.016, context)
	if health.plates != CombatSystem.PIECES_MAX or context.enemy_health[0].current != before:
		_fail("braise : le retour seul laisse %d pièces, %d PV" % [health.plates, context.enemy_health[0].current])
	# LES GANTELETS CHASSENT PAR-DESSUS LES HAIES, et le rappel les ramène en frappant.
	parts = _context(braise)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.free_use = true
	var far := _cell_at(grid, context.player_field, 6)
	_add_enemy(context, far, 5000)
	if not combat.use(chasseurs, context) or health.plates != 1:
		_fail("braise : les chasseurs ne partent pas (%d pièces)" % health.plates)
	for frame in 120:
		combat.update(0.016, context)
	if context.enemy_health[0].current >= 5000:
		_fail("braise : les chasseurs n'ont pas frappé")
	var hurt := context.enemy_health[0].current
	if combat.use(chasseurs, context):
		_fail("braise : les chasseurs repartent sans gantelet")
	if not combat.use(rappel, context):
		_fail("braise : le rappel refuse ses gantelets")
	for frame in 120:
		combat.update(0.016, context)
	if health.plates != CombatSystem.PIECES_MAX or context.enemy_health[0].current > hurt - rappel.damage:
		_fail("braise : le rappel laisse %d pièces et %d PV" % [health.plates, context.enemy_health[0].current])
	# LE PLASTRON RETIENT LE PREMIER QUI PASSE, et ne fait que mordre un boss.
	parts = _context(braise)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var bites := {"stagger": 0.0, "boss": 0}
	combat.enemy_staggered.connect(func(_index: int, seconds: float) -> void: bites["stagger"] = seconds)
	if not combat.use(plastron, context) or combat.use(plastron, context):
		_fail("braise : le plastron part mal")
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 5000)
	for frame in 30:
		combat.update(0.016, context)
	if not is_equal_approx(float(bites["stagger"]), plastron.hold_seconds) or context.enemy_health[0].current >= 5000:
		_fail("braise : le plastron ne retient pas (%s s, %d PV)" % [bites["stagger"], context.enemy_health[0].current])
	parts = _context(braise)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	bites["stagger"] = 0.0
	combat.enemy_staggered.connect(func(_index: int, seconds: float) -> void: bites["stagger"] = seconds)
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 5000)
	context.bosses[0] = true
	combat.use(plastron, context)
	combat.update(0.016, context)
	if float(bites["stagger"]) > 0.0 or context.enemy_health[0].current != 5000 - CombatSystem.CHEST_BOSS_BITE:
		_fail("braise : le boss se laisse retenir (%d PV)" % context.enemy_health[0].current)
	# LE LEURRE ATTIRE PUIS EXPLOSE, et rend les ennemis au mage.
	parts = _context(braise)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var lured := {"field": 0}
	combat.decoy_field.connect(func(field: PackedInt32Array) -> void: lured["field"] = field.size())
	var home: Vector2i = context.player_cell
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 500)
	for facing: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		context.player_facing = facing
		if grid.is_floor_v(home + facing):
			break
	if not combat.use(braise.escape, context):
		_fail("braise : la coquille ne part pas")
	if int(lured["field"]) == 0:
		_fail("braise : le leurre n'attire personne")
	for frame in 200:
		combat.update(0.016, context)
	if int(lured["field"]) != 0 or context.enemy_health[0].current != 500 - braise.escape.damage:
		_fail("braise : le leurre laisse le champ %d et l'ennemi à %d PV" % [lured["field"], context.enemy_health[0].current])
	# LES CAGES BLOQUENT, PUIS ÉCRASENT. Le boss prend le coup sans être bloqué.
	parts = _context(braise)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var blocked := []
	combat.enemy_staggered.connect(func(index: int, _seconds: float) -> void: blocked.append(index))
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 5000)
	_add_enemy(context, _cell_at(grid, context.player_field, 4), 5000)
	context.bosses[1] = true
	combat.use(braise.ultimate, context)
	if blocked != [0]:
		_fail("braise : les cages bloquent %s" % str(blocked))
	if context.enemy_health[0].current != 5000:
		_fail("braise : les cages frappent trop tôt")
	for frame in 260:
		combat.update(0.016, context)
	for i in 2:
		if context.enemy_health[i].current != 5000 - braise.ultimate.damage:
			_fail("braise : les cages laissent l'ennemi %d à %d PV" % [i, context.enemy_health[i].current])


func _test_ecarlate() -> void:
	var ecarlate := CharacterCatalog.ecarlate()
	var pas: Ability = ecarlate.abilities[0]
	var garde: Ability = ecarlate.abilities[1]
	var rengaine: Ability = ecarlate.abilities[2]
	var parts := _context(ecarlate)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	combat.free_use = true
	# RENGAINER SUR RIEN NE COÛTE RIEN.
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 5000)
	if combat.use(rengaine, context):
		_fail("ecarlate : la rengaine part sans entaille")
	# LES ENTAILLES NE FONT RIEN SEULES, plafonnent, et éclatent après le silence.
	for i in 7:
		combat._apply_damage(0, ecarlate.attack, context)
	if combat.cuts_on(0) != CombatSystem.CUTS_MAX:
		_fail("ecarlate : %d entailles au lieu du plafond" % combat.cuts_on(0))
	var before := context.enemy_health[0].current
	if not combat.use(rengaine, context):
		_fail("ecarlate : la rengaine refuse des entailles")
	if context.enemy_health[0].current != before:
		_fail("ecarlate : la rengaine frappe avant le silence")
	for frame in 30:
		combat.update(0.016, context)
	if context.enemy_health[0].current != before - rengaine.cut_damage * CombatSystem.CUTS_MAX or combat.cuts_on(0) != 0:
		_fail("ecarlate : l'éclat laisse %d PV et %d entailles" % [context.enemy_health[0].current, combat.cuts_on(0)])
	# ELLES S'EFFACENT AVEC LE TEMPS.
	combat._apply_damage(0, ecarlate.attack, context)
	for frame in 520:
		combat.update(0.016, context)
	if combat.cuts_on(0) != 0:
		_fail("ecarlate : une entaille tient après %s s" % CombatSystem.CUT_SECONDS)
	# LA GARDE ANNULE UN SEUL COUP, riposte, et ne protège plus du suivant.
	var close := _cell_at(grid, context.player_field, 1)
	context.enemy_cells[0] = close
	before = context.enemy_health[0].current
	combat.use(garde, context)
	health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	combat.update(0.016, context)
	if health.current != ecarlate.base_health or context.enemy_health[0].current != before - garde.damage:
		_fail("ecarlate : la garde laisse %d PV, l'ennemi à %d" % [health.current, context.enemy_health[0].current])
	if combat.cuts_on(0) != garde.cuts or health.immune:
		_fail("ecarlate : la riposte pose %d entailles, immunité %s" % [combat.cuts_on(0), health.immune])
	health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	if health.current != ecarlate.base_health - 1:
		_fail("ecarlate : la garde pare un second coup")
	# LE PAS DE LAME COUPE CE QU'IL TRAVERSE, et la volte-face part dans son dos.
	parts = _context(ecarlate)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var moved := {"to": Vector2i(-1, -1)}
	combat.blink_performed.connect(func(_from: Vector2i, to: Vector2i) -> void: moved["to"] = to)
	var home: Vector2i = context.player_cell
	for facing: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		if grid.is_floor_v(home + facing):
			context.player_facing = facing
			break
	_add_enemy(context, home + context.player_facing, 5000)
	if not combat.use(pas, context) or context.enemy_health[0].current != 5000 - pas.damage or combat.cuts_on(0) != 1:
		_fail("ecarlate : le pas laisse l'ennemi à %d PV, %d entaille" % [context.enemy_health[0].current, combat.cuts_on(0)])
	var ahead := context.player_facing
	context.player_facing = -ahead
	if not combat.use(ecarlate.escape, context) or Vector2(moved["to"] - home).dot(Vector2(ahead)) <= 0.0:
		_fail("ecarlate : la volte-face part de face, vers %s" % str(moved["to"]))
	# LA DERNIÈRE RENGAINE PREND TOUT L'ÉCRAN, BOSS COMPRIS, après sa seconde de silence.
	parts = _context(ecarlate)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 5000)
	_add_enemy(context, _cell_at(grid, context.player_field, 20), 5000)
	context.bosses[1] = true
	if not combat.use(ecarlate.ultimate, context) or context.enemy_health[0].current != 5000:
		_fail("ecarlate : la dernière rengaine part mal")
	for frame in 80:
		combat.update(0.016, context)
	var full := 5000 - ecarlate.ultimate.cut_damage * ecarlate.ultimate.cuts
	if context.enemy_health[0].current != full or context.enemy_health[1].current != full:
		_fail("ecarlate : la dernière rengaine laisse %d et %d PV" % [context.enemy_health[0].current, context.enemy_health[1].current])


func _test_geolier() -> void:
	var geolier := CharacterCatalog.geolier()
	var crochet: Ability = geolier.abilities[0]
	var chaines: Ability = geolier.abilities[1]
	var souffle: Ability = geolier.abilities[2]
	var parts := _context(geolier)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	combat.free_use = true
	var stunned := {}
	combat.enemy_staggered.connect(func(index: int, seconds: float) -> void: stunned[index] = seconds)
	# RIEN NE PART DANS LE VIDE.
	if combat.use(crochet, context) or combat.use(chaines, context):
		_fail("geolier : un sort part sans ennemi")
	# LE CROCHET RAMÈNE LE PLUS ÉLOIGNÉ à une case de lui, par les couloirs, et le sonne.
	var far := _cell_at(grid, context.player_field, 7)
	var near := _cell_at(grid, context.player_field, 3)
	_add_enemy(context, near, 5000)
	_add_enemy(context, far, 5000)
	if not combat.use(crochet, context):
		_fail("geolier : le crochet ne part pas")
	if Pathfinder.value_at(grid, context.player_field, context.enemy_cells[1]) != 1 or context.enemy_cells[0] != near:
		_fail("geolier : le crochet pose l'ennemi à %d cases" % Pathfinder.value_at(grid, context.player_field, context.enemy_cells[1]))
	if not stunned.has(1) or context.enemy_health[1].current != 5000 - crochet.damage:
		_fail("geolier : le crochet ne sonne ni ne blesse")
	# AU TROISIÈME POING, L'ENTRAVE.
	stunned.clear()
	for i in CombatSystem.SHACKLE_HITS:
		combat._apply_damage(0, geolier.attack, context)
	if not is_equal_approx(float(stunned.get(0, 0.0)), CombatSystem.SHACKLE_SECONDS):
		_fail("geolier : pas d'entrave au troisième poing")
	# LES CHAÎNES RONGENT TANT QU'ELLES TIENNENT, puis lâchent.
	var before := context.enemy_health[0].current
	if not combat.use(chaines, context) or combat.soul_chain_members().size() != 2:
		_fail("geolier : les chaînes prennent %d ennemis" % combat.soul_chain_members().size())
	for frame in 420:
		combat.update(0.016, context)
	var lost := before - context.enemy_health[0].current
	if absi(lost - int(chaines.damage * chaines.duration)) > chaines.damage or not combat.soul_chain_members().is_empty():
		_fail("geolier : les chaînes retirent %d au lieu de %d" % [lost, int(chaines.damage * chaines.duration)])
	# LE SOUFFLE FIGE CE QU'IL TOUCHE, sauf un boss.
	parts = _context(geolier)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	stunned.clear()
	combat.enemy_staggered.connect(func(index: int, seconds: float) -> void: stunned[index] = seconds)
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 5000)
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 5000)
	context.bosses[1] = true
	combat.use(souffle, context)
	if not stunned.has(0) or stunned.has(1) or context.enemy_health[1].current >= 5000:
		_fail("geolier : le souffle fige %s" % str(stunned.keys()))
	# LA TRAVERSÉE PASSE UNE HAIE.
	var crossed := false
	var landed := {"to": Vector2i(-1, -1)}
	combat.blink_performed.connect(func(_from: Vector2i, to: Vector2i) -> void: landed["to"] = to)
	for home: Vector2i in grid.all_floor_cells():
		for facing: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
			if grid.is_floor_v(home + facing) or not grid.is_floor_v(home + facing * 2):
				continue
			context.player_cell = home
			context.player_facing = facing
			crossed = combat.use(geolier.escape, context) and landed["to"] != home \
				and not grid.is_floor_v(home + facing)
			break
		if crossed:
			break
	if not crossed:
		_fail("geolier : la traversée ne passe pas la haie")
	# LA GEÔLE CLOUE DANS SON RAYON, ROGNE, ET LÂCHE. Le boss brûle sans être cloué.
	parts = _context(geolier)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	stunned.clear()
	combat.enemy_staggered.connect(func(index: int, seconds: float) -> void: stunned[index] = seconds)
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 5000)
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 5000)
	context.bosses[1] = true
	combat.use(geolier.ultimate, context)
	if not stunned.has(0) or stunned.has(1):
		_fail("geolier : la geôle cloue %s" % str(stunned.keys()))
	for frame in 330:
		combat.update(0.016, context)
	var burned := int(geolier.ultimate.damage * geolier.ultimate.duration)
	for i in 2:
		if absi(5000 - context.enemy_health[i].current - burned) > geolier.ultimate.damage:
			_fail("geolier : la geôle retire %d à l'ennemi %d" % [5000 - context.enemy_health[i].current, i])
	if not combat.gaol_members().is_empty():
		_fail("geolier : la geôle ne lâche pas")


func _test_demon() -> void:
	var demon := CharacterCatalog.demon()
	var pacte: Ability = demon.abilities[0]
	var festin: Ability = demon.abilities[2]
	# LA RAGE : rien à pleine vie, le maximum à 1 PV, jamais sur un repaire.
	var parts := _context(demon)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 5000)
	combat._apply_damage(0, demon.attack, context)
	if context.enemy_health[0].current != 5000 - demon.attack.damage:
		_fail("rage : un coup à pleine vie fait %d dégâts" % (5000 - context.enemy_health[0].current))
	health.current = 1
	var before: int = context.enemy_health[0].current
	combat._apply_damage(0, demon.attack, context)
	var full_rage := int(round(float(demon.attack.damage) * (1.0 + CombatSystem.RAGE_MAX)))
	if before - context.enemy_health[0].current != full_rage:
		_fail("rage : un coup à 1 PV fait %d dégâts" % (before - context.enemy_health[0].current))
	before = context.enemy_health[0].current
	combat._apply_damage(0, demon.attack, context, false, false)
	if before - context.enemy_health[0].current != demon.attack.damage:
		_fail("rage : elle s'applique aux dégâts dérivés")
	context.structures_from = 0
	before = context.enemy_health[0].current
	combat._apply_damage(0, demon.attack, context)
	if before - context.enemy_health[0].current != demon.attack.damage:
		_fail("rage : elle s'applique à un repaire")
	# LE PACTE coûte 1 PV, renforce les coups, et ne prend jamais le dernier.
	parts = _context(demon)
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	if not combat.use(pacte, context) or health.current != health.maximum - pacte.self_cost:
		_fail("pacte : le prix n'est pas payé")
	if combat._empower_bonus != pacte.empower_bonus:
		_fail("pacte : les coups ne sont pas renforcés")
	parts = _context(demon)
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	health.current = 1
	if combat.can_use(pacte) or combat.use(pacte, context) or health.current != 1:
		_fail("pacte : il accepte de prendre le dernier PV")
	if combat.cooldown_left(pacte) > 0.0:
		_fail("pacte : un refus le met en recharge")
	# LE FESTIN ne soigne que s'il a mordu quelqu'un.
	parts = _context(demon)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	health.current = 2
	combat.use(festin, context)
	if health.current != 2:
		_fail("festin : il soigne dans le vide")
	parts = _context(demon)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	health.current = 2
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 5000)
	combat.use(festin, context)
	if health.current != 2 + festin.heal_self:
		_fail("festin : il ne soigne pas après avoir mordu")
	# LE DERNIER PACTE : 1 PV, intouchable, puis la moitié de ce qu'il a donné.
	parts = _context(demon)
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.use(demon.ultimate, context)
	if health.current != 1 or not health.immune:
		_fail("dernier pacte : %d PV, intouchable %s" % [health.current, health.immune])
	combat.update(demon.ultimate.last_pact_seconds + 0.1, context)
	if health.immune:
		_fail("dernier pacte : il reste intouchable après sa durée")
	if health.current != 1 + ceili(3 * demon.ultimate.last_pact_return):
		_fail("dernier pacte : il finit à %d PV sur 4" % health.current)


func _test_acier() -> void:
	var acier := CharacterCatalog.acier()
	var ailes: Ability = acier.abilities[0]
	var enclume: Ability = acier.abilities[1]
	var rempart: Ability = acier.abilities[2]
	# LES PLAQUES encaissent trois coups entiers avant les PV, et deux kills en reforgent une.
	var parts := _context(acier)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	for i in CombatSystem.PLATE_MAX:
		health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	if health.current != acier.base_health or health.plates != 0:
		_fail("plaques : %d PV et %d plaques après trois coups" % [health.current, health.plates])
	health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	if health.current != acier.base_health - 1:
		_fail("plaques : le quatrième coup ne touche pas les PV")
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 1)
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 1)
	combat._apply_damage(0, acier.attack, context)
	if health.plates != 0:
		_fail("plaques : un seul kill en reforge une")
	combat._apply_damage(1, acier.attack, context)
	if health.plates != 1:
		_fail("plaques : deux kills n'en reforgent pas une")
	# LE MARTEAU : l'onde touche sa cible à portée puis ses voisins.
	parts = _context(acier)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var far_cell := _cell_at(grid, context.player_field, acier.attack.range)
	_add_enemy(context, far_cell, 500)
	_add_enemy(context, far_cell, 500)
	if not combat.use(acier.attack, context):
		_fail("marteau : il ne part pas vers l'ennemi à portée")
	for i in 40:
		combat.update(0.02, context)
	if context.enemy_health[0].current != 500 - acier.attack.damage \
			or context.enemy_health[1].current != 500 - acier.attack.damage:
		_fail("marteau : l'onde ne touche pas sa cible et son voisin")
	# LES AILES-LAMES touchent une fois à l'aller et une fois au retour, jamais cinq.
	parts = _context(acier)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var next_to: Vector2i = context.player_cell + context.player_facing
	_add_enemy(context, next_to, 500)
	combat.use(ailes, context)
	for i in 60:
		combat.update(0.02, context)
	if context.enemy_health[0].current != 500 - ailes.damage * 2:
		_fail("ailes-lames : %d PV au lieu de %d" % [context.enemy_health[0].current, 500 - ailes.damage * 2])
	# L'ONDE D'ENCLUME court dans les couloirs : elle atteint et étourdit à portée, pas au-delà.
	parts = _context(acier)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 5), 500)
	_add_enemy(context, _cell_at(grid, context.player_field, enclume.range + 3), 500)
	var stunned := {"count": 0}
	combat.enemy_staggered.connect(func(_index: int, _duration: float) -> void: stunned["count"] += 1)
	combat.use(enclume, context)
	combat.update(0.1, context)
	if context.enemy_health[0].current != 500:
		_fail("enclume : l'onde frappe avant d'être arrivée")
	for i in 40:
		combat.update(0.05, context)
	if context.enemy_health[0].current != 500 - enclume.damage or int(stunned["count"]) != 1:
		_fail("enclume : elle n'a pas touché et étourdi l'ennemi à portée")
	if context.enemy_health[1].current != 500:
		_fail("enclume : elle frappe au-delà de sa portée")
	# LE REMPART : immobile, intouchable, il renvoie le coup, et la Charge est refusée.
	parts = _context(acier)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 500)
	combat.use(rempart, context)
	if not combat.player_rooted():
		_fail("rempart : il ne l'immobilise pas")
	if combat.use(acier.escape, context):
		_fail("rempart : la Charge part malgré lui")
	health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	combat.update(0.02, context)
	if health.plates != CombatSystem.PLATE_MAX or context.enemy_health[0].current != 500 - rempart.reflect_damage:
		_fail("rempart : le coup n'est pas renvoyé")
	combat.update(rempart.duration + 0.1, context)
	if combat.player_rooted():
		_fail("rempart : il reste immobile après sa durée")
	# L'ACIER EN FUSION remet les plaques, renforce les coups, et ses coups projettent.
	parts = _context(acier)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	health.plates = 0
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 5000)
	combat.use(acier.ultimate, context)
	if health.plates != CombatSystem.PLATE_MAX:
		_fail("fusion : les plaques ne sont pas pleines")
	var before: int = context.enemy_health[0].current
	combat._apply_damage(0, acier.attack, context)
	var dealt: int = before - context.enemy_health[0].current
	if dealt != int(round(float(acier.attack.damage) * CombatSystem.MOLTEN_DAMAGE)):
		_fail("fusion : le coup fait %d dégâts" % dealt)
	combat.update(acier.ultimate.molten_seconds + 0.1, context)
	if combat._molten_left > 0.0:
		_fail("fusion : elle ne s'éteint pas")
	print("archange d'acier : plaques, marteau, ailes, enclume, rempart et fusion : OK")


func _test_etoiles() -> void:
	var etoiles := CharacterCatalog.etoiles()
	var constellation: Ability = etoiles.abilities[0]
	var pluie: Ability = etoiles.abilities[1]
	var voile: Ability = etoiles.abilities[2]
	# ASTRE : la troisième étoile explose, et les marques repartent de zéro.
	var parts := _context(etoiles)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 1000)
	var attack := etoiles.attack.damage
	for i in 2:
		combat._apply_damage(0, etoiles.attack, context)
	if context.enemy_health[0].current != 1000 - attack * 2:
		_fail("astre : l'étoile a explosé trop tôt")
	combat._apply_damage(0, etoiles.attack, context)
	if context.enemy_health[0].current != 1000 - attack * 3 - CombatSystem.ASTRE_DAMAGE:
		_fail("astre : pas d'explosion au troisième coup (%d PV)" % context.enemy_health[0].current)
	if combat._star_marks.has(0):
		_fail("astre : les marques ne repartent pas de zéro")

	# CONSTELLATION : trois étoiles au plus, deux sur la même case refusées, et un rayon qui
	# touche en ligne droite ce qui se tient entre elles, même sans chemin.
	parts = _context(etoiles)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	var start: Vector2i = context.player_cell
	if not combat.use(constellation, context):
		_fail("constellation : la première étoile est refusée")
	combat._cooldowns.clear()
	if combat.use(constellation, context):
		_fail("constellation : deux étoiles sur la même case")
	var far := start + Vector2i(8, 0)
	combat._stars.append({"cell": far, "time_left": 10.0, "ability": constellation})
	_add_enemy(context, start + Vector2i(4, 0), 1000)
	_add_enemy(context, start + Vector2i(4, 3), 1000)
	for i in int(1.0 / DT):
		combat.update(DT, context)
	if context.enemy_health[0].current >= 1000:
		_fail("constellation : le rayon ne brûle pas l'ennemi sur sa ligne")
	if context.enemy_health[1].current != 1000:
		_fail("constellation : le rayon brûle un ennemi à trois cases de lui")
	combat._stars[0]["cell"] = start + Vector2i(1, 9)
	context.player_cell = _cell_at(grid, context.player_field, 3)
	combat._cooldowns.clear()
	combat._stars.append({"cell": start + Vector2i(9, 9), "time_left": 10.0, "ability": constellation})
	combat.use(constellation, context)
	if combat._stars.size() != CombatSystem.STAR_MAX:
		_fail("constellation : %d étoiles au lieu de %d" % [combat._stars.size(), CombatSystem.STAR_MAX])

	# PLUIE : ses étoiles tombent d'abord sur les ennemis à portée.
	parts = _context(etoiles)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 1000)
	if not combat.use(pluie, context) or combat._falling.size() != pluie.star_falls:
		_fail("pluie : elle ne prépare pas ses %d étoiles" % pluie.star_falls)
	for i in int((CombatSystem.STAR_FALL_LEAD + 0.1) / DT):
		combat.update(DT, context)
	if context.enemy_health[0].current > 1000 - pluie.damage:
		_fail("pluie : la première étoile n'a pas frappé l'ennemi")

	# VOILE : les coups la traversent.
	parts = _context(etoiles)
	combat = parts[1]; context = parts[2]
	var health: Health = parts[3]
	combat.use(voile, context)
	var before := health.current
	health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	if health.current != before:
		_fail("voile : le coup n'est pas traversé")

	# ÉTOILE FILANTE : la traînée brûle ce qui est sur le trajet.
	parts = _context(etoiles)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	for way: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if grid.is_floor_v(context.player_cell + way):
			context.player_facing = way
			break
	_add_enemy(context, context.player_cell + context.player_facing, 500)
	if not combat.use(etoiles.escape, context) or context.enemy_health[0].current != 500 - etoiles.escape.trail_damage:
		_fail("filante : la traînée ne brûle pas ce qui est sur le trajet")

	# NUIT ÉTERNELLE : une comète sur chaque ennemi, sans aveugler.
	parts = _context(etoiles)
	grid = parts[0]; combat = parts[1]; context = parts[2]
	var blinded := {"count": 0}
	combat.enemy_blinded.connect(func(_i: int, _d: float) -> void: blinded["count"] += 1)
	_add_enemy(context, _cell_at(grid, context.player_field, 4), 500)
	combat.use(etoiles.ultimate, context)
	for i in int((CombatSystem.DAWN_DELAY + 0.2) / DT):
		combat.update(DT, context)
	if context.enemy_health[0].current != 500 - etoiles.ultimate.damage or int(blinded["count"]) != 0:
		_fail("nuit : %d PV, %d aveuglements" % [context.enemy_health[0].current, int(blinded["count"])])
	print("ange des étoiles : astre, constellation, pluie, voile, filante et nuit : OK")


## L'ARCHANGE DU CIEL : ses coups passent par-dessus les haies, et l'Envol le rend intouchable.
func _test_avide() -> void:
	var avide := CharacterCatalog.avide()
	var gouffre: Ability = avide.abilities[0]
	var devorer: Ability = avide.abilities[1]
	var recracher: Ability = avide.abilities[2]
	var parts := _context(avide)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	combat.free_use = true
	# RIEN NE PART À VIDE : ni Dévorer sans proie, ni la Régurgitation sans bouchée.
	if combat.use(devorer, context) or combat.use(recracher, context):
		_fail("avide : un sort part à vide")
	# CHAQUE KILL EST UNE BOUCHÉE, et chaque bouchée frappe plus fort.
	var cell := _cell_at(grid, context.player_field, 4)
	for i in 3:
		_add_enemy(context, cell, 10)
		combat._apply_damage(i, avide.attack, context)
	if combat.bites() != 3:
		_fail("avide : %d bouchées après 3 kills" % combat.bites())
	_add_enemy(context, cell, 5000)
	combat._apply_damage(3, avide.attack, context)
	var expected := int(round(avide.attack.damage * (1.0 + CombatSystem.BITE_DAMAGE * 3.0)))
	if 5000 - context.enemy_health[3].current != expected:
		_fail("avide : avec 3 bouchées, la langue retire %d au lieu de %d" % [5000 - context.enemy_health[3].current, expected])
	# ELLES FONDENT SANS MANGER.
	for frame in int(CombatSystem.BITE_DECAY / 0.016) + 4:
		combat.update(0.016, context)
	if combat.bites() != 2:
		_fail("avide : %d bouchées après %s s de jeûne" % [combat.bites(), CombatSystem.BITE_DECAY])
	# LA RÉGURGITATION LES DÉPENSE TOUTES.
	var balls := {"count": 0}
	combat.regurgitated.connect(func(_from: Vector2i, cells: Array) -> void: balls["count"] = cells.size())
	if not combat.use(recracher, context) or balls["count"] != 2 or combat.bites() != 0:
		_fail("avide : la régurgitation lance %d boules, reste %d bouchées" % [balls["count"], combat.bites()])
	# DÉVORER : un blessé est avalé d'un coup et le soigne ; un ennemi en forme ne l'est pas.
	parts = _context(avide)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.free_use = true
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 1000)
	context.enemy_health[0].take(Damage.new(700, Element.Kind.FIRE, "test"))
	health.take(Damage.new(1, Element.Kind.FIRE, "enemy"))
	combat.use(devorer, context)
	if context.enemy_alive(0) or health.current != health.maximum or combat.bites() != 1:
		_fail("avide : Dévorer n'avale pas le blessé")
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 1000)
	combat.use(devorer, context)
	if not context.enemy_alive(1) or context.enemy_health[1].current != 1000 - int(round(devorer.damage * (1.0 + CombatSystem.BITE_DAMAGE))):
		_fail("avide : Dévorer avale un ennemi en forme")
	# LE GOUFFRE ASPIRE, puis mord en se refermant ; le boss ne bouge pas.
	parts = _context(avide)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var mouth := _cell_at(grid, context.player_field, 4)
	var mouth_field := Pathfinder.distance_field(grid, [mouth] as Array[Vector2i])
	var around := Vector2i(-1, -1)
	var boss_cell := Vector2i(-1, -1)
	for other in grid.all_floor_cells():
		if Pathfinder.value_at(grid, mouth_field, other) == 2 \
				and Pathfinder.value_at(grid, context.player_field, other) > 4:
			if around == Vector2i(-1, -1):
				around = other
			elif boss_cell == Vector2i(-1, -1):
				boss_cell = other
	_add_enemy(context, mouth, 5000)
	if around != Vector2i(-1, -1):
		_add_enemy(context, around, 5000)
	if boss_cell != Vector2i(-1, -1):
		_add_enemy(context, boss_cell, 5000)
		context.bosses[2] = true
	if not combat.use(gouffre, context):
		_fail("avide : le gouffre ne s'ouvre pas")
	for frame in int(gouffre.duration / 0.016) + 4:
		combat.update(0.016, context)
	if around != Vector2i(-1, -1) and Pathfinder.value_at(grid, mouth_field, context.enemy_cells[1]) >= 2:
		_fail("avide : le gouffre n'aspire pas")
	if boss_cell != Vector2i(-1, -1) and context.enemy_cells[2] != boss_cell:
		_fail("avide : le gouffre aspire un boss")
	if context.enemy_health[0].current >= 5000:
		_fail("avide : le gouffre ne mord pas en se refermant")
	# LE BOND sonne ce qui l'entoure à l'arrivée.
	parts = _context(avide)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	for facing: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		if grid.is_floor_v(context.player_cell + facing):
			context.player_facing = facing
			break
	var landed := {"to": context.player_cell}
	combat.blink_performed.connect(func(_from: Vector2i, to: Vector2i) -> void: landed["to"] = to)
	if not combat.use(avide.escape, context) or landed["to"] == context.player_cell:
		_fail("avide : le bond ne part pas")
	# LE FESTIN avale un ennemi à la fois, et finit.
	parts = _context(avide)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	for steps in [2, 3, 4]:
		_add_enemy(context, _cell_at(grid, context.player_field, steps), 50)
	var swallowed := {"count": 0}
	combat.feast_bite.connect(func(_index: int, _cell: Vector2i, _killed: bool) -> void: swallowed["count"] += 1)
	combat.use(avide.ultimate, context)
	for frame in int(avide.ultimate.duration / 0.016) + 4:
		combat.update(0.016, context)
	if swallowed["count"] != 3 or combat.feasting():
		_fail("avide : le festin avale %d ennemis" % swallowed["count"])
	print("l'avide : bouchées, gouffre, dévorer, régurgitation, bond et festin : OK")


func _test_croupier() -> void:
	var croupier := CharacterCatalog.croupier()
	var des: Ability = croupier.abilities[0]
	var piege: Ability = croupier.abilities[1]
	var piece: Ability = croupier.abilities[2]
	var parts := _context(croupier)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	combat.free_use = true
	# LE COUP DE CHANCE : environ un coup sur cinq, trois fois plus fort.
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 1000000)
	var lucky := {"count": 0}
	combat.lucky_hit.connect(func(_index: int, _cell: Vector2i) -> void: lucky["count"] += 1)
	var before := context.enemy_health[0].current
	for i in 400:
		combat._apply_damage(0, croupier.attack, context)
	var dealt := before - context.enemy_health[0].current
	var expected: int = croupier.attack.damage * (400 + int(lucky["count"]) * (CombatSystem.LUCK_MULT - 1))
	if lucky["count"] < 40 or lucky["count"] > 130 or dealt != expected:
		_fail("croupier : %d critiques sur 400, %d dégâts au lieu de %d" % [lucky["count"], dealt, expected])
	# LES DÉS : leur total fixe les dégâts, à un critique près.
	parts = _context(croupier)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	for facing: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		if grid.is_floor_v(context.player_cell + facing):
			context.player_facing = facing
			break
	_add_enemy(context, context.player_cell + context.player_facing, 5000)
	var roll := {"total": 0}
	combat.dice_rolled.connect(func(_from: Vector2i, _cells: Array, a: int, b: int) -> void:
		roll["total"] = a + b)
	if not combat.use(des, context) or roll["total"] < 2 or roll["total"] > 12:
		_fail("croupier : les dés ne roulent pas")
	else:
		var lost := 5000 - context.enemy_health[0].current
		if lost != des.damage * roll["total"] and lost != des.damage * roll["total"] * CombatSystem.LUCK_MULT:
			_fail("croupier : les dés (%d) retirent %d" % [roll["total"], lost])
	# LA CARTE PIÈGE se retourne sous le premier ennemi qui passe.
	parts = _context(croupier)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	_add_enemy(context, _cell_at(grid, context.player_field, 4), 5000)
	var flipped := {"suit": -1}
	combat.trap_flipped.connect(func(_cell: Vector2i, suit: int, _targets: Array) -> void: flipped["suit"] = suit)
	combat.use(piege, context)
	combat.update(0.016, context)
	if flipped["suit"] != -1 or combat.traps().size() != 1:
		_fail("croupier : la carte part sans personne")
	context.enemy_cells[0] = context.player_cell
	combat.update(0.016, context)
	if flipped["suit"] < 0 or context.enemy_health[0].current > 5000 - piege.damage or not combat.traps().is_empty():
		_fail("croupier : la carte piège ne se retourne pas")
	# PILE OU FACE : il gagne toujours quelque chose, et les deux côtés sortent.
	parts = _context(croupier)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.free_use = true
	var sides := {"face": 0, "pile": 0}
	combat.coin_flipped.connect(func(face: bool) -> void: sides["face" if face else "pile"] += 1)
	for i in 30:
		combat.use(piece, context)
		if not health.immune and combat.doubled_left() != piece.doubled_hits:
			_fail("croupier : la pièce ne donne rien")
			break
		combat._immune_left = 0.0
		health.immune = false
		combat._doubled_left = 0
	if sides["face"] == 0 or sides["pile"] == 0:
		_fail("croupier : la pièce tombe toujours du même côté (%s)" % str(sides))
	# LA ROULETTE : la bille tombe après la rotation, et chaque issue frappe tout l'écran.
	var outcomes := {}
	for attempt in 40:
		parts = _context(croupier)
		grid = parts[0]
		combat = parts[1]
		context = parts[2]
		combat._rng.seed = 1000 + attempt
		_add_enemy(context, _cell_at(grid, context.player_field, 3), 5000)
		var landed := {"result": -1}
		var burning := {}
		combat.roulette_landed.connect(func(result: int, _cells: Array) -> void: landed["result"] = result)
		combat.enemy_burning.connect(func(index: int, _seconds: float) -> void: burning[index] = true)
		combat.use(croupier.ultimate, context)
		for frame in int(CombatSystem.ROULETTE_SPIN / 0.016) + 2:
			combat.update(0.016, context)
		var result: int = landed["result"]
		outcomes[result] = true
		var hurt := context.enemy_health[0].current < 5000 or burning.has(0)
		if result < 0 or not hurt:
			_fail("croupier : la roulette (%d) ne frappe pas" % result)
			break
	if outcomes.size() < 2:
		_fail("croupier : la roulette ne sort que %s" % str(outcomes.keys()))
	print("croupier des enfers : chance, dés, carte piège, pile ou face et roulette : OK")


func _test_dragon() -> void:
	var dragon := CharacterCatalog.dragon()
	var souffle: Ability = dragon.abilities[0]
	var morsure: Ability = dragon.abilities[1]
	var ecailles: Ability = dragon.abilities[2]
	var parts := _context(dragon)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	combat.free_use = true
	# RIEN NE PART DANS LE VIDE.
	if combat.use(morsure, context):
		_fail("dragon : la morsure part sans ennemi")
	# TERRE BRÛLÉE : le crachat enflamme la case, la case ronge ce qui s'y tient, et lui y va plus vite.
	var cell := _cell_at(grid, context.player_field, 4)
	_add_enemy(context, cell, 5000)
	combat._apply_damage(0, dragon.attack, context)
	if not combat.fire_cells().has(cell):
		_fail("dragon : le crachat n'enflamme pas la case")
	var before := context.enemy_health[0].current
	for frame in 62:
		combat.update(0.016, context)
	var burnt := before - context.enemy_health[0].current
	if burnt < CombatSystem.FIRE_CELL_DAMAGE / 2:
		_fail("dragon : la case en feu ne retire que %d en une seconde" % burnt)
	context.player_cell = cell
	combat.update(0.016, context)
	if not is_equal_approx(combat.armor_speed(), dragon.move_speed * CombatSystem.INFERNO_SPEED):
		_fail("dragon : dans le feu, il gagne %s de vitesse" % combat.armor_speed())
	for frame in 260:
		combat.update(0.016, context)
	if combat.fire_cells().has(cell) or combat.armor_speed() != 0.0:
		_fail("dragon : la case brûle encore après %s s" % CombatSystem.FIRE_CELL_SECONDS)
	# LE SOUFFLE COURT DANS LE COULOIR, blesse ce qu'il croise et laisse ses cases en feu.
	parts = _context(dragon)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	for facing: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		if grid.is_floor_v(context.player_cell + facing):
			context.player_facing = facing
			break
	var lit := {"cells": []}
	combat.breath_cast.connect(func(_from: Vector2i, cells: Array, _seconds: float) -> void: lit["cells"] = cells)
	_add_enemy(context, context.player_cell + context.player_facing, 5000)
	if not combat.use(souffle, context) or lit["cells"].is_empty():
		_fail("dragon : le souffle ne part pas")
	elif context.enemy_health[0].current != 5000 - souffle.damage:
		_fail("dragon : le souffle retire %d" % (5000 - context.enemy_health[0].current))
	for burning: Vector2i in lit["cells"]:
		if not combat.fire_cells().has(burning):
			_fail("dragon : la case %s du souffle ne brûle pas" % burning)
			break
	# LA MORSURE BONDIT AU CONTACT, et une proie en feu le soigne.
	parts = _context(dragon)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.free_use = true
	var prey := _cell_at(grid, context.player_field, 3)
	_add_enemy(context, prey, 5000)
	combat._ignite_cells([prey], 5.0)
	health.take(Damage.new(1, Element.Kind.FIRE, "enemy"))
	var landed := {"to": context.player_cell}
	combat.blink_performed.connect(func(_from: Vector2i, to: Vector2i) -> void: landed["to"] = to)
	if not combat.use(morsure, context):
		_fail("dragon : la morsure ne part pas")
	var field := Pathfinder.distance_field(grid, [prey] as Array[Vector2i])
	if Pathfinder.value_at(grid, field, landed["to"]) != 1:
		_fail("dragon : la morsure le pose à %d cases de sa proie" % Pathfinder.value_at(grid, field, landed["to"]))
	if context.enemy_health[0].current != 5000 - morsure.damage or health.current != health.maximum:
		_fail("dragon : la morsure retire %d et rend %d PV" % [5000 - context.enemy_health[0].current,
			health.current - (health.maximum - 1)])
	# LES ÉCAILLES ENCAISSENT UN COUP, puis éclatent sur ce qui l'entoure.
	parts = _context(dragon)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.free_use = true
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 5000)
	combat.use(ecailles, context)
	health.take(Damage.new(1, Element.Kind.FIRE, "enemy"))
	combat.update(0.016, context)
	combat.update(0.016, context)
	if health.current != health.maximum or combat.scales_up() \
			or context.enemy_health[0].current != 5000 - ecailles.shard_damage:
		_fail("dragon : écailles — %d PV, éclats %d" % [health.current, 5000 - context.enemy_health[0].current])
	# LE BATTEMENT D'AILES REPOUSSE ET ENFLAMME, sauf le boss qui ne bouge pas ; et lui recule.
	parts = _context(dragon)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var close := _cell_at(grid, context.player_field, 1)
	var boss_cell := Vector2i(-1, -1)
	for other in grid.all_floor_cells():
		if other != close and Pathfinder.value_at(grid, context.player_field, other) == 1:
			boss_cell = other
	_add_enemy(context, close, 5000)
	if boss_cell != Vector2i(-1, -1):
		_add_enemy(context, boss_cell, 5000)
		context.bosses[1] = true
	var burning := {}
	combat.enemy_burning.connect(func(index: int, _seconds: float) -> void: burning[index] = true)
	combat.use(dragon.escape, context)
	if Pathfinder.value_at(grid, context.player_field, context.enemy_cells[0]) <= 1 or not burning.has(0):
		_fail("dragon : les ailes ne repoussent ni n'enflamment")
	if boss_cell != Vector2i(-1, -1) and context.enemy_cells[1] != boss_cell:
		_fail("dragon : les ailes déplacent un boss")
	# L'OMBRE : tout ce qui est à l'écran brûle, puis explose dans l'ordre de son passage.
	parts = _context(dragon)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 5000)
	_add_enemy(context, _cell_at(grid, context.player_field, 5), 5000)
	var columns := {"count": 0}
	combat.shadow_column.connect(func(_cell: Vector2i, _first: bool) -> void: columns["count"] += 1)
	combat.use(dragon.ultimate, context)
	for frame in 120:
		combat.update(0.016, context)
	if columns["count"] != 2:
		_fail("dragon : l'ombre fait jaillir %d colonnes au lieu de 2" % columns["count"])
	for i in 2:
		if 5000 - context.enemy_health[i].current < dragon.ultimate.damage:
			_fail("dragon : l'ombre ne retire que %d" % (5000 - context.enemy_health[i].current))
	print("dragon des abysses : sol en feu, souffle, morsure, écailles, ailes et ombre : OK")


func _test_ciel() -> void:
	var ciel := CharacterCatalog.ciel()
	var parts := _context(ciel)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	combat.free_use = true
	# Une case proche à vol d'oiseau, loin ou hors d'atteinte par les couloirs : derrière une haie.
	var behind := Vector2i(-1, -1)
	for cell in grid.all_floor_cells():
		var by_path := Pathfinder.value_at(grid, context.player_field, cell)
		if Vector2(cell - context.player_cell).length() <= ciel.abilities[2].radius \
				and (by_path < 0 or by_path > ciel.attack.range):
			behind = cell
			break
	if behind.x < 0:
		_fail("ciel : aucune case derrière une haie dans le labyrinthe d'essai")
		return
	# LA LANCE VISE PAR-DESSUS LA HAIE, et ne frappe qu'en touchant le sol.
	_add_enemy(context, behind, 5000)
	if combat.find_target(ciel.attack, context) != 0:
		_fail("ciel : la lance ne vise pas par-dessus la haie")
	combat.use(ciel.attack, context)
	if context.enemy_health[0].current != 5000:
		_fail("ciel : la lance frappe avant de tomber")
	for frame in 30:
		combat.update(0.016, context)
	if context.enemy_health[0].current >= 5000:
		_fail("ciel : la lance ne tombe pas")
	# LA CLOCHE ÉTOURDIT PAR-DESSUS LA HAIE, sauf un boss.
	var stunned := {}
	combat.enemy_staggered.connect(func(index: int, seconds: float) -> void: stunned[index] = seconds)
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 5000)
	context.bosses[1] = true
	var before := context.enemy_health[0].current
	combat.use(ciel.abilities[2], context)
	if not stunned.has(0) or stunned.has(1) or context.enemy_health[0].current >= before:
		_fail("ciel : la cloche étourdit %s" % str(stunned.keys()))
	# LES PLUMES NE REVIENNENT PAS.
	combat.use(ciel.abilities[0], context)
	for frame in 30:
		combat.update(0.016, context)
	if not combat._volleys.is_empty():
		_fail("ciel : les plumes reviennent")
	# LA COLONNE TOMBE SUR LA CIBLE et cloue ce qui l'entoure, sauf un boss.
	parts = _context(ciel)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var dazed := {}
	combat.enemies_dazed.connect(func(indices: Array, seconds: float, _ability: Ability) -> void:
		for index: int in indices:
			dazed[index] = seconds)
	var target := _cell_at(grid, context.player_field, 4)
	var side := Vector2i(-1, -1)
	for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if grid.is_floor_v(target + step) and target + step != context.player_cell:
			side = target + step
			break
	_add_enemy(context, target, 5000)
	_add_enemy(context, side, 5000)
	context.bosses[1] = true
	if not combat.use(ciel.abilities[1], context):
		_fail("ciel : la colonne ne part pas")
	for frame in 45:
		combat.update(0.016, context)
	if not dazed.has(0) or dazed.has(1) or context.enemy_health[1].current >= 5000:
		_fail("ciel : la colonne cloue %s" % str(dazed.keys()))
	# L'ENVOL : intouchable et plus rapide 3 s, puis il retombe et l'onde frappe autour de lui.
	parts = _context(ciel)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var health: Health = parts[3]
	combat.free_use = true
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 5000)
	if not combat.use(ciel.escape, context) or not combat.flying() or not health.immune \
			or combat.flight_speed() <= 1.0:
		_fail("ciel : l'Envol ne l'élève pas")
	for frame in 150:
		combat.update(0.016, context)
	if not combat.flying():
		_fail("ciel : il retombe avant la fin de l'Envol")
	for frame in 60:
		combat.update(0.016, context)
	if combat.flying() or health.immune:
		_fail("ciel : il ne retombe pas")
	if context.enemy_health[0].current != 5000 - ciel.escape.damage:
		_fail("ciel : l'atterrissage retire %d" % (5000 - context.enemy_health[0].current))
	# LE JUGEMENT : douze épées sur les ennemis de la carte, derrière les haies comprises.
	parts = _context(ciel)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	_add_enemy(context, behind, 5000)
	_add_enemy(context, _cell_at(grid, context.player_field, 9), 5000)
	combat.use(ciel.ultimate, context)
	for frame in 300:
		combat.update(0.016, context)
	var each := ciel.ultimate.rain_damage * ciel.ultimate.rain_count / 2
	for i in 2:
		if 5000 - context.enemy_health[i].current != each:
			_fail("ciel : le Jugement retire %d à l'ennemi %d au lieu de %d" % [
				5000 - context.enemy_health[i].current, i, each])


## LE CHÉRUBIN : sa flamme brûle derrière sa cible, l'œil brûle qui l'approche, et son jardin
## rejette tout ce qui n'est pas un boss.
func _test_cherubin() -> void:
	var cherubin := CharacterCatalog.cherubin()
	var parts := _context(cherubin)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	combat.free_use = true
	# LA FLAMME CONTINUE APRÈS SA CIBLE, et brûle ce qui se tient sur la suite de son trajet.
	var jet := {"path": []}
	combat.projectile_launched.connect(func(_a: Ability, _t: int, path: Array, _d: float) -> void:
		jet["path"] = path)
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 5000)
	_add_enemy(context, Vector2i(-5, -5), 5000)
	if not combat.use(cherubin.attack, context):
		_fail("cherubin : la flamme ne part pas")
	var path: Array = jet["path"]
	if path.size() <= 3:
		_fail("cherubin : la flamme s'arrête à sa cible (%d cases)" % path.size())
	else:
		context.enemy_cells[1] = path[path.size() - 1]
	for frame in 60:
		combat.update(0.016, context)
	if context.enemy_health[0].current >= 5000 or context.enemy_health[1].current >= 5000:
		_fail("cherubin : la flamme ne brûle pas derrière sa cible")
	# L'ŒIL S'OUVRE SUR LA CIBLE, et s'embrase quand elle arrive au contact.
	if not combat.eyes().has(0):
		_fail("cherubin : pas d'œil sur la cible")
	var before := context.enemy_health[0].current
	context.enemy_cells[0] = _cell_at(grid, context.player_field, 1)
	combat.update(0.016, context)
	if before - context.enemy_health[0].current != CombatSystem.EYE_DAMAGE or combat.eyes().has(0):
		_fail("cherubin : l'œil retire %d au contact" % (before - context.enemy_health[0].current))
	# LE GLAIVE TOURNOIE et frappe à chaque passage ce qui est à sa portée.
	before = context.enemy_health[0].current
	combat.use(cherubin.abilities[0], context)
	for frame in 70:
		combat.update(0.016, context)
	if before - context.enemy_health[0].current < cherubin.abilities[0].damage * 2:
		_fail("cherubin : le glaive ne retire que %d" % (before - context.enemy_health[0].current))
	# LES ROUES partent dans deux sens.
	var wheels := {"count": 0}
	combat.wave_launched.connect(func(_a: Ability, _p: Array, _d: float) -> void: wheels["count"] += 1)
	combat.use(cherubin.abilities[1], context)
	if int(wheels["count"]) != 2:
		_fail("cherubin : %d roue(s) au lieu de 2" % int(wheels["count"]))
	# LES AILES VOILÉES : intouchable, et l'ennemi au contact est repoussé.
	var near := _cell_at(grid, context.player_field, 1)
	context.enemy_cells[0] = near
	combat.use(cherubin.abilities[2], context)
	combat.update(0.016, context)
	if not health.immune or Pathfinder.value_at(grid, context.player_field, context.enemy_cells[0]) <= 1:
		_fail("cherubin : les ailes ne repoussent pas")
	# LE JARDIN : rejette l'ennemi hors du cercle et le brûle, laisse entrer le boss, rend 1 PV.
	parts = _context(cherubin)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.free_use = true
	health.current = health.maximum - 2
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 5000)
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 5000)
	context.bosses[1] = true
	var boss_cell := context.enemy_cells[1]
	if not combat.use(cherubin.ultimate, context):
		_fail("cherubin : le jardin ne se plante pas")
	var radius := cherubin.ultimate.radius
	if Vector2(context.enemy_cells[0] - context.player_cell).length() < radius \
			or context.enemy_health[0].current >= 5000:
		_fail("cherubin : le jardin ne rejette pas l'ennemi")
	if context.enemy_cells[1] != boss_cell:
		_fail("cherubin : le jardin rejette le boss")
	if health.current != health.maximum - 1:
		_fail("cherubin : le jardin ne rend pas 1 PV")
	for frame in 520:
		combat.update(0.016, context)
	if context.enemy_health[1].current >= 5000:
		_fail("cherubin : le boss ne brûle pas dans le jardin")
	if not combat.garden().is_empty():
		_fail("cherubin : le jardin ne se referme pas")


## L'ÉVEIL : six kills pour le lancer, une minute éveillé, dix secondes d'épuisement. La
## Renaissance relève le Phénix une fois à 2 PV, intouchable, et met fin à l'Éveil.
func _test_awakening() -> void:
	var base := CharacterCatalog.fire()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or not form.awakened or form.id != base.id or form.action_bar().size() != 6:
		_fail("éveil : pas de Phénix pour le Mage du Feu")
		return
	# Un Éveil n'existe que s'il a ses bandes : un mage éveillé sans planche serait invisible.
	for mage in CharacterCatalog.all():
		var awakened := CharacterCatalog.awakening_of(mage.id)
		if awakened == null:
			continue
		if not awakened.awakened or awakened.id != mage.id or awakened.action_bar().size() != 6:
			_fail("éveil : la forme de %s est mal formée" % mage.id)
		if not FileAccess.file_exists("res://assets/characters/%s_eveil/frames.json" % mage.id):
			_fail("éveil : %s s'éveille sans planche découpée" % mage.id)
	var parts := _context(base)
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	var awakening := Awakening.new(base, form, combat, context)
	var forms: Array = []
	awakening.form_changed.connect(func(next: CharacterStats) -> void: forms.append(next))
	if awakening.begin():
		_fail("éveil : il part sans kills")
	for i in Awakening.KILLS:
		awakening.kill()
	if not awakening.begin() or awakening.can_act():
		_fail("éveil : il ne part pas après %d kills" % Awakening.KILLS)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not awakening.awake() or forms.is_empty() or not (forms[-1] as CharacterStats).awakened:
		_fail("éveil : il ne s'éveille pas")
	# La Renaissance : le coup mortel le laisse à 2 PV, intouchable, et l'Éveil s'achève.
	var reborn := {"count": 0}
	awakening.reborn.connect(func() -> void: reborn["count"] += 1)
	health.take(Damage.new(health.current + 5))
	if int(reborn["count"]) != 1 or health.current != Awakening.REBIRTH_HEALTH or not health.immune:
		_fail("éveil : pas de Renaissance (%d PV)" % health.current)
	if awakening.state != Awakening.State.EXHAUSTED or (forms[-1] as CharacterStats).awakened:
		_fail("éveil : la Renaissance ne met pas fin à l'Éveil")
	if health.minimum_current != 0:
		_fail("éveil : il reste increvable après l'Éveil")
	awakening.update(Awakening.EXHAUST_TIME + 0.01)
	if awakening.state != Awakening.State.NORMAL or awakening.can_begin():
		_fail("éveil : l'épuisement ne rend pas la main, ou la charge reste pleine")
	# Sans coup mortel, la minute passe, puis l'épuisement.
	for i in Awakening.KILLS:
		awakening.kill()
	awakening.begin()
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	awakening.update(Awakening.DURATION - 1.0)
	if not awakening.awake():
		_fail("éveil : il s'achève avant la minute")
	awakening.update(1.1)
	if awakening.state != Awakening.State.EXHAUSTED:
		_fail("éveil : il dure plus d'une minute")
	awakening.dispose()


## Le kit du Phénix : la volée sur trois cibles, le Soleil qui explose deux fois et laisse du magma,
## les piliers qui frappent une fois chacun, et la Plongée qui explose aux deux bouts.
func _test_phoenix_kit() -> void:
	var phoenix := CharacterCatalog.fire_awakened()
	var parts := _context(phoenix)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	combat.free_use = true
	var launched := {"count": 0}
	combat.projectile_launched.connect(func(_a: Ability, _t: int, _p: Array, _d: float) -> void:
		launched["count"] += 1)
	for steps in [2, 3, 4]:
		_add_enemy(context, _cell_at(grid, context.player_field, steps), 5000)
	combat.use(phoenix.attack, context)
	if int(launched["count"]) != 3:
		_fail("phénix : la volée part sur %d cibles" % int(launched["count"]))
	for frame in 90:
		combat.update(0.016, context)
	for i in 3:
		if context.enemy_health[i].current >= 5000:
			_fail("phénix : la plume %d ne touche pas" % i)
	# Le Soleil captif.
	var echoes := {"count": 0, "magma": 0}
	combat.echo_blasted.connect(func(_c: Vector2i, _a: Ability) -> void: echoes["count"] += 1)
	combat.zone_created.connect(func(_id: int, zone: Ability, _c: Vector2i) -> void:
		if zone.zone_style == "magma_peint":
			echoes["magma"] += 1)
	var before := context.enemy_health[0].current
	combat.use(phoenix.abilities[0], context)
	for frame in 200:
		combat.update(0.016, context)
	if int(echoes["count"]) != 1 or int(echoes["magma"]) != 1:
		_fail("phénix : le soleil explose %d fois, magma %d" % [int(echoes["count"]), int(echoes["magma"])])
	if before - context.enemy_health[0].current < phoenix.abilities[0].damage + phoenix.abilities[0].echo_damage:
		_fail("phénix : le soleil ne retire que %d" % (before - context.enemy_health[0].current))
	# Les Colonnes de feu.
	parts = _context(phoenix)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var pillars := {"cells": []}
	combat.pillars_erupted.connect(func(cells: Array, _a: Ability) -> void: pillars["cells"] = cells)
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 5000)
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 5000)
	if not combat.use(phoenix.abilities[1], context) or (pillars["cells"] as Array).is_empty():
		_fail("phénix : les colonnes ne jaillissent pas")
	for i in 2:
		var lost := 5000 - context.enemy_health[i].current
		if lost != 0 and lost != phoenix.abilities[1].damage:
			_fail("phénix : une colonne frappe %d au lieu d'une fois" % lost)
	# La Plongée : elle explose là où il part.
	parts = _context(phoenix)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var plunged := false
	for home: Vector2i in grid.all_floor_cells():
		for facing: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
			if not grid.is_floor_v(home + facing) or not grid.is_floor_v(home - facing):
				continue
			context.player_cell = home
			context.player_facing = facing
			context.player_field = Pathfinder.distance_field(grid, [home] as Array[Vector2i])
			context.enemy_cells.clear()
			context.enemy_health.clear()
			_add_enemy(context, home - facing, 5000)
			plunged = combat.use(phoenix.escape, context)
			break
		if plunged:
			break
	if not plunged or context.enemy_health[0].current != 5000 - phoenix.escape.end_blast_damage:
		_fail("phénix : la plongée n'explose pas au départ")


## LE COLOSSE : il piétine ce qu'il touche, et chacun de ses sorts fait ce qu'il dit.
func _test_colossus() -> void:
	var base := CharacterCatalog.earth()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Colosse":
		_fail("colosse : pas d'éveil pour le Mage de la Terre")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	# Piétinement : un voisin est repoussé et blessé, une fois par seconde ; un boss encaisse sans bouger.
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.trampling():
		_fail("colosse : pas de piétinement à l'éveil")
	var beside: Array[Vector2i] = []
	for facing: Vector2i in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(context.player_cell + facing):
			beside.append(context.player_cell + facing)
	if beside.is_empty():
		_fail("colosse : aucune case voisine du départ")
		return
	_add_enemy(context, beside[0], 5000)
	combat.update(0.016, context)
	if context.enemy_health[0].current != 5000 - Awakening.TRAMPLE_DAMAGE:
		_fail("colosse : le piétinement retire %d" % (5000 - context.enemy_health[0].current))
	if context.enemy_cells[0] == beside[0]:
		_fail("colosse : le piétinement ne repousse pas")
	context.enemy_cells[0] = beside[0]
	combat.update(0.016, context)
	if context.enemy_health[0].current != 5000 - Awakening.TRAMPLE_DAMAGE:
		_fail("colosse : il piétine deux fois dans la même seconde")
	context.bosses[0] = true
	combat.update(CombatSystem.TRAMPLE_LOCK + 0.01, context)
	if context.enemy_cells[0] != beside[0] or context.enemy_health[0].current != 5000 - 2 * Awakening.TRAMPLE_DAMAGE:
		_fail("colosse : un boss piétiné doit encaisser sans bouger")
	awakening.finish()
	if combat.trampling():
		_fail("colosse : le piétinement survit à l'éveil")
	awakening.dispose()
	# La Faille part dans chaque couloir qui touche sa case, et frappe sur deux branches.
	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var branches := {"count": 0}
	combat.line_erupted.connect(func(_a: Ability, _p: Array, _d: float) -> void: branches["count"] += 1)
	for cell in beside.slice(0, 2):
		_add_enemy(context, cell, 5000)
	combat.use(form.abilities[0], context)
	for frame in 30:
		combat.update(0.016, context)
	if int(branches["count"]) != beside.size():
		_fail("colosse : la faille a %d branches pour %d couloirs" % [int(branches["count"]), beside.size()])
	for i in context.enemy_cells.size():
		if context.enemy_health[i].current > 5000 - form.abilities[0].damage:
			_fail("colosse : la faille épargne la branche %d" % i)
	# Le Bastion renvoie les coups, mais ne le cloue pas sur place comme le Rempart de l'Acier.
	if not combat.use(form.abilities[1], context) or not combat.health.immune:
		_fail("colosse : le bastion ne le rend pas intouchable")
	if combat.player_rooted():
		_fail("colosse : le bastion le cloue sur place")
	# La Tour de cristal tire sur trois ennemis à la fois.
	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	for steps in [2, 3, 4]:
		_add_enemy(context, _cell_at(grid, context.player_field, steps), 5000)
	combat.use(form.abilities[2], context)
	combat.update(0.016, context)
	for i in 3:
		if context.enemy_health[i].current >= 5000:
			_fail("colosse : la tour de cristal épargne l'ennemi %d" % i)
	# Le Cataclysme fait jaillir toutes ses colonnes de lave pendant le séisme.
	var columns := {"count": 0}
	combat.lava_column.connect(func(_c: Vector2i, _a: Ability) -> void: columns["count"] += 1)
	combat.use(form.ultimate, context)
	for frame in int((form.ultimate.quake_duration + 1.0) / 0.016):
		combat.update(0.016, context)
	if int(columns["count"]) != form.ultimate.lava_columns:
		_fail("colosse : %d colonnes de lave sur %d" % [int(columns["count"]), form.ultimate.lava_columns])
	# L'Éruption n'explose qu'à l'arrivée.
	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var bursts := {"count": 0}
	combat.eruption_burst.connect(func(_c: Vector2i, _a: Ability) -> void: bursts["count"] += 1)
	for facing: Vector2i in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(context.player_cell + facing):
			context.player_facing = facing
			break
	if not combat.use(form.escape, context) or int(bursts["count"]) != 1:
		_fail("colosse : l'éruption n'éclate pas une fois à l'arrivée (%d)" % int(bursts["count"]))


## L'AVATAR DE LA TEMPÊTE : chaque coup le charge et la cinquième charge fait tomber la foudre ; chacun
## de ses sorts fait ce qu'il dit.
func _test_tempest() -> void:
	var base := CharacterCatalog.thunder()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Avatar de la Tempête":
		_fail("tempête : pas d'éveil pour le Mage de la Foudre")
		return
	if form.move_speed <= base.move_speed:
		_fail("tempête : l'avatar n'est pas plus rapide")
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	# Surtension : cinq coups le chargent, l'attaque suivante appelle la foudre, et les charges retombent.
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	# Le jeu passe la forme éveillée au combat (`Level.set_character`) : ici, à la main.
	combat.stats = form
	combat.free_use = true
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 5000)
	var strikes := {"count": 0}
	combat.surge_struck.connect(func(_c: Vector2i) -> void: strikes["count"] += 1)
	for shot in Awakening.SURGE_CHARGES:
		combat.use(form.attack, context)
		for frame in 30:
			combat.update(0.016, context)
	if combat.surge_charges() != Awakening.SURGE_CHARGES:
		_fail("tempête : %d charges après %d coups" % [combat.surge_charges(), Awakening.SURGE_CHARGES])
	var before := context.enemy_health[0].current
	combat.use(form.attack, context)
	if int(strikes["count"]) != 1 or combat.surge_charges() != 0:
		_fail("tempête : la cinquième charge n'appelle pas la foudre")
	if before - context.enemy_health[0].current < Awakening.SURGE_DAMAGE:
		_fail("tempête : la foudre de surtension ne frappe pas")
	awakening.finish()
	awakening.update(0.016)
	awakening.dispose()
	# La Tempête en chaîne touche six ennemis sans faiblir, et paralyse chacun.
	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	# Sur UN chemin, une case d'écart : des cases prises au hasard à la bonne distance pouvaient être
	# sur des branches séparées de plus que la portée d'un saut.
	var path := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 8))
	for cell in path.slice(2, 8):
		_add_enemy(context, cell, 5000)
	var stunned := {"count": 0}
	combat.enemy_staggered.connect(func(_i: int, _s: float) -> void: stunned["count"] += 1)
	combat.use(form.abilities[0], context)
	for frame in 40:
		combat.update(0.016, context)
	var struck := 0
	for i in context.enemy_cells.size():
		if context.enemy_health[i].current < 5000:
			struck += 1
	if struck < 6 or int(stunned["count"]) < 6:
		_fail("tempête : la chaîne touche %d ennemis et en paralyse %d" % [struck, int(stunned["count"])])
	# La Cage électrique le suit.
	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var moved := {"count": 0}
	combat.zone_moved.connect(func(_id: int, _c: Vector2i) -> void: moved["count"] += 1)
	combat.use(form.abilities[1], context)
	for facing: Vector2i in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(context.player_cell + facing):
			context.player_cell += facing
			break
	combat.update(0.016, context)
	if int(moved["count"]) != 1:
		_fail("tempête : la cage ne le suit pas")
	# L'Œil du cyclone frappe trois cibles à chaque décharge.
	for steps in [1, 2, 3]:
		_add_enemy(context, _cell_at(grid, context.player_field, steps), 5000)
	var bolts := {"count": 0}
	combat.storm_struck.connect(func(_i: int, _a: Ability) -> void: bolts["count"] += 1)
	combat.use(form.abilities[2], context)
	combat.update(0.016, context)
	if int(bolts["count"]) != 3:
		_fail("tempête : l'œil du cyclone frappe %d cibles" % int(bolts["count"]))
	# Le Saut d'éclair frappe trois ennemis et le pose sur le dernier.
	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	for steps in [2, 3, 4]:
		_add_enemy(context, _cell_at(grid, context.player_field, steps), 5000)
	var landing := {"to": context.player_cell}
	combat.blink_performed.connect(func(_f: Vector2i, to: Vector2i) -> void: landing["to"] = to)
	if not combat.use(form.escape, context):
		_fail("tempête : le saut d'éclair refuse de partir")
	var hit := 0
	for i in context.enemy_cells.size():
		if context.enemy_health[i].current == 5000 - form.escape.hop_damage:
			hit += 1
	if hit != 3 or not context.enemy_cells.has(landing["to"]):
		_fail("tempête : le saut touche %d ennemis et ne finit pas sur le dernier" % hit)
	# La Colère du ciel : un éclair géant par ennemi.
	var wrath := {"count": 0}
	combat.wrath_bolt.connect(func(_c: Vector2i, _i: int) -> void: wrath["count"] += 1)
	combat.use(form.ultimate, context)
	for frame in 120:
		combat.update(0.016, context)
	if int(wrath["count"]) != 3:
		_fail("tempête : %d éclairs de colère pour 3 ennemis" % int(wrath["count"]))


## LE SOUVERAIN DES VENTS : plus rien ne l'approche, et chacun de ses sorts fait ce qu'il dit.
func _test_sovereign() -> void:
	var base := CharacterCatalog.air()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Souverain des Vents":
		_fail("souverain : pas d'éveil pour le Mage de l'Air")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	# Rempart de vent : un voisin est repoussé et ralenti, sans dégâts.
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	var beside := Vector2i(-1, -1)
	for facing: Vector2i in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(context.player_cell + facing):
			beside = context.player_cell + facing
			break
	_add_enemy(context, beside, 5000)
	var soaked := {"count": 0}
	combat.enemy_soaked.connect(func(_i: int, _d: float, _f: float) -> void: soaked["count"] += 1)
	combat.update(0.016, context)
	if context.enemy_cells[0] == beside or context.enemy_health[0].current != 5000 or int(soaked["count"]) != 1:
		_fail("souverain : le rempart de vent doit repousser et ralentir sans blesser")
	awakening.finish()
	awakening.dispose()
	# Le Croissant d'ouragan repousse ce qu'il touche.
	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var target := _cell_at(grid, context.player_field, 3)
	_add_enemy(context, target, 5000)
	combat.use(form.attack, context)
	for frame in 60:
		combat.update(0.016, context)
	if context.enemy_health[0].current >= 5000 or Pathfinder.value_at(grid, context.player_field, context.enemy_cells[0]) <= 3:
		_fail("souverain : le croissant ne repousse pas sa cible")
	# Le Grand vortex aspire vers lui ce qui l'entoure.
	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var pulls := {"count": 0}
	combat.enemy_pushed.connect(func(_i: int, _c: Vector2i) -> void: pulls["count"] += 1)
	var path := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 9))
	# À trois cases du mage, là où naît la tornade : hors de son rayon, mais à portée d'aspiration.
	_add_enemy(context, path[3] if path[0] == context.player_cell else path[2], 5000)
	combat.use(form.abilities[0], context)
	for frame in 200:
		combat.update(0.016, context)
	if int(pulls["count"]) == 0:
		_fail("souverain : le vortex n'aspire rien")
	# Le Cocon le rend intouchable et rejette.
	if not combat.use(form.abilities[2], context) or not combat.health.immune:
		_fail("souverain : le cocon ne le rend pas intouchable")
	# Le Vol du zéphyr rabat tout en retombant.
	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var near := _cell_at(grid, context.player_field, 1)
	_add_enemy(context, near, 5000)
	combat.use(form.escape, context)
	for frame in int(form.escape.duration / 0.016) + 5:
		combat.update(0.016, context)
	if combat.flying() or context.enemy_cells[0] == near:
		_fail("souverain : le vol ne retombe pas en rabattant")
	# L'Ouragan ouvre l'œil, une zone qui le suit.
	var eyes := {"count": 0}
	combat.zone_created.connect(func(_id: int, zone: Ability, _c: Vector2i) -> void:
		if zone.zone_style == "ouragan_peint" and zone.zone_follows:
			eyes["count"] += 1)
	combat.use(form.ultimate, context)
	if int(eyes["count"]) != 1:
		_fail("souverain : l'ouragan n'ouvre pas son œil")


## LE SEIGNEUR DU NÉANT : son ombre répète ses coups, et chacun de ses sorts fait ce qu'il dit.
func _test_void_lord() -> void:
	var base := CharacterCatalog.shadow()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Seigneur du Néant":
		_fail("néant : pas d'éveil pour le Sorcier des Ténèbres")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	# Le Double : l'attaque frappe, puis l'ombre la répète à moitié de sa force.
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.doubling():
		_fail("néant : pas de double à l'éveil")
	combat.stats = form
	combat.free_use = true
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 5000)
	var echoes := {"count": 0}
	combat.double_struck.connect(func(_i: int, _a: Ability) -> void: echoes["count"] += 1)
	combat.use(form.attack, context)
	for frame in 60:
		combat.update(0.016, context)
	var expected := form.attack.damage + int(round(float(form.attack.damage) * Awakening.DOUBLE_RATIO))
	if int(echoes["count"]) != 1 or 5000 - context.enemy_health[0].current < expected:
		_fail("néant : l'ombre ne répète pas l'attaque (%d coups, %d dégâts)" % [int(echoes["count"]),
			5000 - context.enemy_health[0].current])
	# Ni la fuite, ni l'Extra.
	combat.use(form.escape, context)
	for frame in 10:
		combat.update(0.016, context)
	if int(echoes["count"]) != 1:
		_fail("néant : l'ombre répète la fuite")
	awakening.finish()
	if combat.doubling():
		_fail("néant : le double survit à l'éveil")
	awakening.dispose()
	# Le Trou noir aspire, puis s'effondre et laisse sa flaque.
	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	var path := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 7))
	_add_enemy(context, path[mini(4, path.size() - 1)], 5000)
	_add_enemy(context, path[mini(7, path.size() - 1)], 5000)
	var collapsed := {"count": 0}
	combat.hole_collapsed.connect(func(_c: Vector2i, _a: Ability) -> void: collapsed["count"] += 1)
	var pulled := {"count": 0}
	combat.enemy_pushed.connect(func(_i: int, _c: Vector2i) -> void: pulled["count"] += 1)
	if not combat.use(form.abilities[2], context):
		_fail("néant : le trou noir refuse de s'ouvrir")
	for frame in int(form.abilities[2].hole_seconds / 0.016) + 5:
		combat.update(0.016, context)
	if int(collapsed["count"]) != 1 or int(pulled["count"]) == 0 or context.enemy_health[0].current > 5000 - form.abilities[2].damage:
		_fail("néant : le trou noir n'aspire pas puis ne s'effondre pas")
	# L'Éclipse ralentit tous les ennemis.
	var slowed := {"count": 0}
	combat.enemy_soaked.connect(func(_i: int, _d: float, _f: float) -> void: slowed["count"] += 1)
	combat.use(form.ultimate, context)
	if int(slowed["count"]) < 2:
		_fail("néant : l'éclipse ne ralentit pas les ennemis")


## LE MAÎTRE DES LÉGIONS : la Légion grandit le plafond et la force des créatures, et chacun de ses sorts
## fait ce qu'il dit.
func _test_legion() -> void:
	var base := CharacterCatalog.invocateur()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Maître des Légions":
		_fail("légion : pas d'éveil pour l'Invocateur")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.legion_active():
		_fail("légion : pas de légion à l'éveil")
	combat.stats = form
	combat.free_use = true
	_add_enemy(context, _cell_at(grid, context.player_field, 9), 5000)
	# La Nuée : quatre diablotins de la Légion, six au plus, et ceux qui cèdent la place explosent.
	var bursts := {"count": 0}
	combat.summon_burst.connect(func(_i: int, _c: Vector2i, _r: float) -> void: bursts["count"] += 1)
	var born := {"ids": []}
	combat.summon_spawned.connect(func(id: int, _k: String, _p: Vector2) -> void: born["ids"].append(id))
	combat.use(form.abilities[0], context)
	if combat.summon_count() != 4 or not bool(combat.summon_info(int(born["ids"][0])).get("legion", false)):
		_fail("légion : la Nuée n'appelle pas quatre diablotins de la Légion (%d)" % combat.summon_count())
	combat.use(form.abilities[0], context)
	if combat.summon_count() != Awakening.LEGION_CAP or int(bursts["count"]) != 2:
		_fail("légion : plafond %d au lieu de %d, %d explosions" % [combat.summon_count(),
			Awakening.LEGION_CAP, int(bursts["count"])])
	# La Marque désigne la proie.
	combat.use(form.attack, context)
	for frame in 90:
		combat.update(0.016, context)
	if combat.marked_prey() != 0:
		_fail("légion : la marque ne se pose pas sur la cible")
	awakening.finish()
	if combat.legion_active() or bool(combat.summon_info(int(born["ids"][-1])).get("legion", true)):
		_fail("légion : la légion survit à l'éveil")
	awakening.dispose()
	# La force de la Légion : un diablotin collé à sa proie frappe à LEGION_RATIO.
	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	combat.start_legion(60.0, Awakening.LEGION_RATIO, Awakening.LEGION_CAP)
	var path := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 8))
	_add_enemy(context, path[mini(4, path.size() - 1)], 5000)
	# La Gargouille colossale tombe près de la proie, blesse et étourdit.
	var dropped := {"count": 0}
	combat.summon_dropped.connect(func(_i: int, _c: Vector2i, _r: float) -> void: dropped["count"] += 1)
	var frozen := {"count": 0}
	combat.enemies_frozen.connect(func(list: Array, _s: float) -> void: frozen["count"] += list.size())
	combat.use(form.abilities[1], context)
	if int(dropped["count"]) != 1 or int(frozen["count"]) != 1 \
			or context.enemy_health[0].current > 5000 - form.abilities[1].summon_drop_damage:
		_fail("légion : la gargouille ne tombe pas sur la proie (%d PV)" % context.enemy_health[0].current)
	var struck := {"count": 0}
	combat.summon_struck.connect(func(_i: int, _t: int) -> void: struck["count"] += 1)
	var before := context.enemy_health[0].current
	for frame in 120:
		combat.update(0.016, context)
		if int(struck["count"]) > 0:
			break
	var expected := int(round(float(CombatSystem.SUMMON_KINDS["gargouille"]["damage"]) * Awakening.LEGION_RATIO))
	if int(struck["count"]) == 0 or before - context.enemy_health[0].current < expected:
		_fail("légion : la gargouille ne frappe pas à la force de la légion (%d)"
			% (before - context.enemy_health[0].current))
	# L'Échange : il prend la place de sa créature.
	var swapped := {"to": Vector2i(-1, -1)}
	combat.summon_swapped.connect(func(_i: int, _f: Vector2i, to: Vector2i) -> void: swapped["to"] = to)
	if not combat.use(form.escape, context) or swapped["to"] == Vector2i(-1, -1):
		_fail("légion : l'échange ne se fait pas")
	# La Porte des abysses fait sortir des diablotins.
	var count := combat.summon_count()
	combat.use(form.abilities[2], context)
	for frame in int((form.abilities[2].zone_spawn_every + 0.2) / 0.016):
		combat.update(0.016, context)
	if combat.summon_count() < count + 1:
		_fail("légion : la porte n'appelle aucun diablotin")
	# Le Roi-Dragon passe sur la rangée du mage et brûle ce qui s'y trouve.
	var row := Vector2i(-1, -1)
	for x in range(1, grid.cols - 1):
		var cell := Vector2i(x, context.player_cell.y)
		if grid.is_floor_v(cell) and absi(x - context.player_cell.x) >= 3 and absi(x - context.player_cell.x) <= 8:
			row = cell
			break
	if row == Vector2i(-1, -1):
		_fail("légion : aucune case libre sur la rangée du mage pour éprouver le roi-dragon")
	else:
		_add_enemy(context, row, 5000)
		var flown := {"count": 0}
		combat.dragon_flyover.connect(func(_c: Vector2i, _r: float, _w: float) -> void: flown["count"] += 1)
		var last := context.enemy_cells.size() - 1
		combat.use(form.ultimate, context)
		if int(flown["count"]) != 1 or context.enemy_health[last].current > 5000 - form.ultimate.flyover_damage:
			_fail("légion : le roi-dragon ne brûle pas la rangée")


## LE SEIGNEUR DES MARÉES : sa coque se reforme après avoir cédé, et chacun de ses sorts fait ce qu'il dit.
func _test_tide_lord() -> void:
	var base := CharacterCatalog.water()
	var form := CharacterCatalog.awakening_of(base.id)
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	# Marée haute.
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not awakening.shell_up() or health.shield != 1:
		_fail("marées : pas de coque à l'éveil (bouclier %d)" % health.shield)
	var before := health.current
	health.take(Damage.new(1))
	awakening.update(0.016)
	if health.current != before or awakening.shell_up():
		_fail("marées : la coque n'encaisse pas le coup")
	awakening.update(Awakening.SHELL_REGROW - 0.5)
	if awakening.shell_up():
		_fail("marées : la coque revient trop tôt")
	awakening.update(0.6)
	if not awakening.shell_up() or health.shield != 1:
		_fail("marées : la coque ne se reforme pas")
	awakening.finish()
	if health.shield != 0:
		_fail("marées : la coque reste après l'éveil")
	awakening.dispose()
	# Le Trident rebondit sur deux voisins.
	var tide := CharacterCatalog.water_awakened()
	parts = _context(tide)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.free_use = true
	var bounces := {"count": 0}
	combat.water_bounced.connect(func(_f: Vector2i, _t: Vector2i) -> void: bounces["count"] += 1)
	for steps in [2, 3, 4]:
		_add_enemy(context, _cell_at(grid, context.player_field, steps), 5000)
	combat.use(tide.attack, context)
	for frame in 90:
		combat.update(0.016, context)
	if int(bounces["count"]) != 2:
		_fail("marées : le trident rebondit %d fois" % int(bounces["count"]))
	# La Bulle des abysses rend 1 PV si elle tient.
	health.current = health.maximum - 1
	combat.use(tide.abilities[1], context)
	for frame in int(tide.abilities[1].duration / 0.016) + 10:
		combat.update(0.016, context)
	if health.current != health.maximum:
		_fail("marées : la bulle tenue ne rend pas de PV (%d/%d)" % [health.current, health.maximum])
	# Le Léviathan frappe dans sa bande, à travers les haies, et le soigne.
	parts = _context(tide)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.free_use = true
	var behind := Vector2i(-1, -1)
	for cell in grid.all_floor_cells():
		var by_path := Pathfinder.value_at(grid, context.player_field, cell)
		var offset: Vector2i = cell - context.player_cell
		if absi(offset.y) <= 2 and absi(offset.x) <= 6 and (by_path < 0 or by_path > 12):
			behind = cell
			break
	if behind.x < 0:
		_fail("marées : aucune case derrière une haie dans la bande")
		return
	_add_enemy(context, behind, 5000)
	health.current = health.maximum - 2
	combat.use(tide.ultimate, context)
	for frame in int(tide.ultimate.duration / 0.016) + 10:
		combat.update(0.016, context)
	if context.enemy_health[0].current != 5000 - tide.ultimate.damage:
		_fail("marées : le léviathan retire %d" % (5000 - context.enemy_health[0].current))
	if health.current != health.maximum:
		_fail("marées : le léviathan ne soigne pas")
	# Le Torrent suit le couloir et laisse un courant.
	var wakes := {"count": 0}
	combat.zone_created.connect(func(_id: int, zone: Ability, _c: Vector2i) -> void:
		if zone.zone_style == "courant_peint":
			wakes["count"] += 1)
	var landed := {"to": context.player_cell}
	combat.blink_performed.connect(func(_from: Vector2i, to: Vector2i) -> void: landed["to"] = to)
	for facing: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		if grid.is_floor_v(context.player_cell + facing):
			context.player_facing = facing
			break
	if not combat.use(tide.escape, context) or landed["to"] == context.player_cell or int(wakes["count"]) < 2:
		_fail("marées : le torrent ne file pas (%d courants)" % int(wakes["count"]))


## LE SEIGNEUR DES HEURES (l'Éveil du Chronomancien) : Temps accéléré, les Trois Aiguilles, le Dôme qui fige
## une fois, les deux doubles du Paradoxe et leur onde, le Rembobinage, la bombe-horloge et le Jugement.
func _test_hours() -> void:
	var base := CharacterCatalog.chrono()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Seigneur des Heures":
		_fail("heures : pas d'éveil pour le Chronomancien")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.haste_active():
		_fail("heures : pas de temps accéléré à l'éveil")
	combat.stats = form
	# Temps accéléré : 10 s du monde font 15 s de recharge.
	combat.use(form.abilities[2], context)
	for frame in 100:
		combat.update(0.1, context)
	var expected := form.abilities[2].cooldown - 10.0 * Awakening.HASTE_FACTOR
	if absf(combat.cooldown_left(form.abilities[2]) - expected) > 0.15:
		_fail("heures : la recharge ne file pas plus vite (%.2f au lieu de %.2f)"
			% [combat.cooldown_left(form.abilities[2]), expected])
	awakening.finish()
	if combat.haste_active():
		_fail("heures : le temps accéléré survit à l'éveil")
	awakening.dispose()

	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.free_use = true
	# Les Trois Aiguilles : un tir par cible, sur trois cibles.
	var path := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 10))
	for step in [3, 5, 7]:
		_add_enemy(context, path[mini(step, path.size() - 1)], 5000)
	var shots := {"count": 0}
	combat.projectile_launched.connect(func(_a: Ability, _t: int, _p: Array, _d: float) -> void:
		shots["count"] += 1)
	combat.use(form.attack, context)
	if int(shots["count"]) != 3:
		_fail("heures : les Trois Aiguilles partent sur %d cibles au lieu de 3" % int(shots["count"]))
	# Le Dôme fige une fois chaque créature qui entre, pas à chaque instant.
	var caught := {"count": 0}
	combat.stasis_caught.connect(func(_i: int, _s: float) -> void: caught["count"] += 1)
	combat.use(form.abilities[0], context)
	for frame in 60:
		combat.update(0.05, context)
	var inside := 0
	var field := Pathfinder.distance_field(grid, [context.player_cell] as Array[Vector2i])
	for cell in context.enemy_cells:
		if Pathfinder.value_at(grid, field, cell) <= int(form.abilities[0].radius):
			inside += 1
	if int(caught["count"]) != inside or inside == 0:
		_fail("heures : le dôme fige %d fois pour %d créatures dedans" % [int(caught["count"]), inside])
	# Le Paradoxe : après dix secondes de marche, deux doubles partent et explosent au bout.
	var walk := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 12))
	for cell: Vector2i in walk:
		context.player_cell = cell
		for frame in 8:
			combat.update(0.1, context)
	var doubles := {"count": 0}
	combat.echo_walked.connect(func(_a: Ability, _c: Array, _t: Array) -> void: doubles["count"] += 1)
	var waves := {"count": 0}
	combat.echo_burst.connect(func(_c: Vector2i, _r: float) -> void: waves["count"] += 1)
	combat.use(form.abilities[1], context)
	for frame in 130:
		combat.update(0.1, context)
	if int(doubles["count"]) != 2 or int(waves["count"]) != 2:
		_fail("heures : le paradoxe fait %d doubles et %d ondes au lieu de 2 et 2"
			% [int(doubles["count"]), int(waves["count"])])
	# Le Rembobinage rend ce qui a été perdu dans les 5 dernières secondes, pas plus.
	health.take(Damage.new(2, Element.Kind.FIRE, "enemy"))
	for frame in 10:
		combat.update(0.1, context)
	combat.use(form.abilities[2], context)
	if health.current != health.maximum:
		_fail("heures : le rembobinage ne rend pas les PV perdus (%d/%d)" % [health.current, health.maximum])
	health.take(Damage.new(1, Element.Kind.FIRE, "enemy"))
	for frame in 70:
		combat.update(0.1, context)
	combat.use(form.abilities[2], context)
	if health.current == health.maximum:
		_fail("heures : le rembobinage rend une blessure vieille de plus de 5 s")
	# Le Saut temporel laisse une bombe-horloge qui sonne et fige ce qui l'entoure.
	var walk_back := combat.trajectory(context.player_cell, grid.player_spawn)
	for cell: Vector2i in walk_back.slice(0, 6):
		context.player_cell = cell
		for frame in 8:
			combat.update(0.1, context)
	var departure := context.player_cell
	context.enemy_cells.clear()
	context.enemy_health.clear()
	_add_enemy(context, departure, 5000)
	var rang := {"count": 0}
	combat.clock_bomb_rang.connect(func(_i: int, _c: Vector2i, _r: float) -> void: rang["count"] += 1)
	var frozen := {"count": 0}
	combat.enemies_frozen.connect(func(list: Array, _s: float) -> void: frozen["count"] += list.size())
	if not combat.use(form.escape, context):
		_fail("heures : le saut temporel refuse de partir")
	for frame in int((form.escape.clock_bomb_delay + 0.2) / 0.05):
		combat.update(0.05, context)
	if int(rang["count"]) != 1 or int(frozen["count"]) != 1 \
			or context.enemy_health[0].current != 5000 - form.escape.clock_bomb_damage:
		_fail("heures : la bombe-horloge ne sonne pas sur place (%d PV)" % context.enemy_health[0].current)
	# Le Jugement : pendant l'arrêt les coups s'accumulent, puis tombent à 150 %.
	context.enemy_cells[0] = path[mini(4, path.size() - 1)]
	context.player_cell = grid.player_spawn
	context.player_field = Pathfinder.distance_field(grid, [context.player_cell] as Array[Vector2i])
	var before := context.enemy_health[0].current
	combat.use(form.ultimate, context)
	combat.use(form.attack, context)
	for frame in 40:
		combat.update(0.05, context)
	if context.enemy_health[0].current != before:
		_fail("heures : un coup porte pendant le jugement")
	for frame in int(form.ultimate.duration / 0.05) + 5:
		combat.update(0.05, context)
	var lost := before - context.enemy_health[0].current
	var hit := int(round(float(form.attack.damage) * form.ultimate.judgement_ratio))
	if lost != hit:
		_fail("heures : midi rend %d au lieu de %d" % [lost, hit])
	print("seigneur des heures : temps accéléré, aiguilles, dôme, paradoxe, rembobinage, bombe et jugement : OK")


## L'ARCHIDÉMON DU PACTE (l'Éveil du Démon du Pacte) : le Prix du Sang (la vie coule, jamais le dernier PV, un
## kill la rend, la Rage double), le Pacte écarlate, la Gueule de l'Abîme qui soigne par ennemi happé, les
## Fleuves de soufre, les Ailes du Pacte et l'Apocalypse de Sang avec ses serres.
## Les cases les plus proches de `start` par les couloirs, sans `start` ni la case du mage.
func _cluster(grid: MazeGrid, context: CombatContext, start: Vector2i, count: int) -> Array[Vector2i]:
	var field := Pathfinder.distance_field(grid, [start] as Array[Vector2i])
	var cells: Array[Vector2i] = []
	for cell in grid.all_floor_cells():
		if cell != context.player_cell and Pathfinder.value_at(grid, field, cell) >= 0:
			cells.append(cell)
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return Pathfinder.value_at(grid, field, a) < Pathfinder.value_at(grid, field, b))
	cells.resize(mini(cells.size(), count))
	return cells


## LA REINE DE LA DISCORDE : la contagion, l'Œil, la Toile, le Ballet et le Grand Bal.
func _test_queen() -> void:
	var base := CharacterCatalog.discorde()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Reine de la Discorde":
		_fail("reine : pas d'éveil pour la Démone de la Discorde")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.contagious():
		_fail("reine : la Discorde contagieuse ne commence pas avec l'Éveil")
	# Chaque coup trouble.
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 500)
	combat._apply_damage(0, form.attack, context)
	if combat.whispers_on(0) != CombatSystem.WHISPER_MARKS:
		_fail("reine : un seul coup ne trouble pas pendant l'Éveil")
	awakening.update(Awakening.DURATION)
	if combat.contagious():
		_fail("reine : la contagion survit à l'Éveil")
	# Hors de l'Éveil, la Démone garde son murmure en trois coups.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 500)
	combat._apply_damage(0, base.attack, context)
	if combat.whispers_on(0) != 1:
		_fail("reine : la Démone de base trouble dès le premier coup")

	# La contagion : un pantin meurt, ses fils sautent sur son voisin.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.start_contagion()
	var first := _cell_at(grid, context.player_field, 3)
	var near := _cluster(grid, context, first, 2)
	_add_enemy(context, near[0], 1)
	_add_enemy(context, near[1], 500)
	combat._possess(0, form.abilities[0], context)
	combat._apply_damage(0, form.attack, context)
	combat.update(0.01, context)
	if not combat.possessed_indices().has(1):
		_fail("reine : la possession ne saute pas du pantin mort à son voisin")

	# L'Œil de la Reine : la cible et ses deux voisins.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	for cell in _cluster(grid, context, _cell_at(grid, context.player_field, 3), 4):
		_add_enemy(context, cell, 500)
	if not combat.use(form.abilities[0], context):
		_fail("reine : l'Œil de la Reine ne part pas")
	if combat.possessed_indices().size() != 3:
		_fail("reine : l'Œil possède %d ennemis au lieu de 3" % combat.possessed_indices().size())

	# L'Arène s'ouvre sur une proie, la Toile enchaîne cinq ennemis.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	for cell in _cluster(grid, context, _cell_at(grid, context.player_field, 3), 6):
		_add_enemy(context, cell, 500)
	if not combat.use(form.abilities[1], context):
		_fail("reine : l'Arène de Discorde ne part pas")
	if not combat.use(form.abilities[2], context):
		_fail("reine : la Toile de Souffrance ne part pas")
	if combat.bond_members().size() != 5:
		_fail("reine : la Toile enchaîne %d ennemis au lieu de 5" % combat.bond_members().size())

	# Le Ballet : l'échange, puis la marionnette éclate sur l'ennemi resté à sa place.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.stats = form
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 500)
	if not combat.use(form.escape, context):
		_fail("reine : le Ballet des pantins ne part pas")
	for i in 40:
		combat.update(0.1, context)
	if context.enemy_health[0].current >= 500:
		_fail("reine : la marionnette du Ballet n'éclate pas")

	# Le Grand Bal : tous possédés, et chaque mort éclate sur ses voisins.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.stats = form
	near = _cluster(grid, context, _cell_at(grid, context.player_field, 3), 2)
	_add_enemy(context, near[0], 1)
	_add_enemy(context, near[1], 500)
	if not combat.use(form.ultimate, context):
		_fail("reine : le Grand Bal ne part pas")
	if not combat.ball_dancing() or combat.possessed_indices().size() != 2:
		_fail("reine : le Grand Bal ne possède pas tout le monde")
	combat._apply_damage(0, form.attack, context)
	var before := context.enemy_health[1].current
	combat.update(0.01, context)
	if before - context.enemy_health[1].current < form.ultimate.ball_burst_damage:
		_fail("reine : la mort d'un pantin n'éclate pas sur son voisin (%d dégâts)" % [
			before - context.enemy_health[1].current])
	for i in 100:
		combat.update(0.1, context)
	if combat.ball_dancing():
		_fail("reine : le Grand Bal ne s'arrête pas")
	print("reine de la discorde : contagion, œil, toile, ballet, grand bal : OK")


## L'EMPEREUR DES CENDRES : le Sillage de cendres, la gerbe des gantelets, la Forge, le Retour et l'Empire.
func _test_emperor() -> void:
	var base := CharacterCatalog.braise()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Empereur des Cendres":
		_fail("empereur : pas d'éveil pour le Roi de Braise")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.ashes_burning():
		_fail("empereur : le Sillage de cendres ne commence pas avec l'Éveil")
	# Une pièce arrachée revient en ASH_RETURN.
	health.take(Damage.new(1))
	combat.update(0.01, context)
	var loose := 0
	for piece in combat.pieces():
		if piece["state"] == CombatSystem.Piece.LOOSE:
			loose += 1
			if absf(float(piece["left"]) - CombatSystem.ASH_RETURN) > 0.05:
				_fail("empereur : la pièce arrachée revient en %.1f s" % float(piece["left"]))
	if loose != 1:
		_fail("empereur : un coup reçu n'arrache pas une pièce")
	# Elle vole, et laisse des cendres.
	for i in 10:
		combat.update(0.05, context)
	if combat.fire_cells().is_empty():
		_fail("empereur : la pièce qui vole ne laisse aucune cendre")
	# Dans ses cendres, il ne gagne pas l'allure du Dragon.
	combat.fire_cells()[context.player_cell] = 2.0
	combat.update(0.01, context)
	if combat.armor_speed() > CombatSystem.PIECE_SPEED_BONUS * float(CombatSystem.PIECES_MAX) + 0.001:
		_fail("empereur : ses cendres lui donnent l'allure du Dragon (%.2f)" % combat.armor_speed())
	awakening.update(Awakening.DURATION)
	if combat.ashes_burning():
		_fail("empereur : le Sillage survit à l'Éveil")

	# Les Gantelets de l'Empereur : la gerbe blesse aussi le voisin de la proie.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var near := _cluster(grid, context, _cell_at(grid, context.player_field, 3), 2)
	_add_enemy(context, near[0], 500)
	_add_enemy(context, near[1], 500)
	if not combat.use(form.abilities[0], context):
		_fail("empereur : les Gantelets ne partent pas")
	for i in 40:
		combat.update(0.05, context)
	if context.enemy_health[0].current >= 500 or context.enemy_health[1].current >= 500:
		_fail("empereur : la gerbe des gantelets ne touche pas les deux voisins")

	# La Forge impériale : elle aspire, mord, puis explose.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var far := _cell_at(grid, context.player_field, 3)
	_add_enemy(context, far, 500)
	if not combat.use(form.abilities[1], context):
		_fail("empereur : la Forge ne part pas")
	var start := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[0])
	combat.update(0.05, context)
	if Pathfinder.value_at(grid, context.player_field, context.enemy_cells[0]) >= start:
		_fail("empereur : la Forge n'aspire pas l'ennemi à 3 cases")
	var blew := {"n": 0}
	combat.forge_blew.connect(func(_c: Vector2i, _r: float) -> void: blew["n"] += 1)
	for i in 120:
		combat.update(0.05, context)
	if blew["n"] != 1:
		_fail("empereur : la Forge n'explose pas en recrachant (%d)" % blew["n"])

	# Le Retour de l'Empire : les trois pièces ensemble font partir l'onde.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 5), 5000)
	combat.use(form.abilities[0], context)
	combat.use(form.abilities[1], context)
	for i in 4:
		combat.update(0.05, context)
	var waves := {"n": 0}
	combat.empire_wave.connect(func(_c: Vector2i, _r: float) -> void: waves["n"] += 1)
	if not combat.use(form.abilities[2], context):
		_fail("empereur : le Retour de l'Empire ne part pas")
	for i in 60:
		combat.update(0.05, context)
	if waves["n"] != 1:
		_fail("empereur : le retour des trois pièces ne lance pas l'onde (%d)" % waves["n"])

	# L'Empire des Cendres : chaque cage éclate sur ses voisins.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	near = _cluster(grid, context, _cell_at(grid, context.player_field, 4), 2)
	_add_enemy(context, near[0], 1000)
	_add_enemy(context, near[1], 1000)
	if not combat.use(form.ultimate, context):
		_fail("empereur : l'Empire des Cendres ne part pas")
	combat.update(form.ultimate.duration + 0.05, context)
	var expected := form.ultimate.damage + form.ultimate.cage_burst_damage * 2
	if 1000 - context.enemy_health[0].current < expected:
		_fail("empereur : la cage n'éclate pas sur le voisin (%d dégâts, attendu %d)" % [
			1000 - context.enemy_health[0].current, expected])
	print("empereur des cendres : sillage, gantelets, forge, retour, empire : OK")


## Une direction où les deux cases devant le mage sont du sol, ou zéro.
func _open_way(grid: MazeGrid, from: Vector2i) -> Vector2i:
	for way: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if grid.is_floor_v(from + way) and grid.is_floor_v(from + way * 2) and grid.is_floor_v(from + way * 3):
			return way
	return Vector2i.ZERO


## LE SEIGNEUR ÉCARLATE : la Lame affûtée, l'écho du Pas, la Garde, les pétales, la Danse et la Nuit.
func _test_lord() -> void:
	var base := CharacterCatalog.ecarlate()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Seigneur Écarlate":
		_fail("seigneur : pas d'éveil pour le Chevalier Écarlate")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.keen():
		_fail("seigneur : la Lame affûtée ne commence pas avec l'Éveil")
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 1000)
	combat._apply_damage(0, form.attack, context)
	if combat.cuts_on(0) != 2:
		_fail("seigneur : un coup éveillé laisse %d entailles au lieu de 2" % combat.cuts_on(0))
	for i in 3:
		combat._apply_damage(0, form.attack, context)
	var before := context.enemy_health[0].current
	combat.update(0.01, context)
	if combat.cuts_on(0) != 0 or before - context.enemy_health[0].current < CombatSystem.KEEN_CUT_DAMAGE * 8:
		_fail("seigneur : huit entailles ne s'ouvrent pas seules (%d restent)" % combat.cuts_on(0))
	awakening.update(Awakening.DURATION)
	if combat.keen():
		_fail("seigneur : la Lame affûtée survit à l'Éveil")
	# Sans l'Éveil, le Chevalier garde ses cinq entailles et sa Rengaine.
	for i in 8:
		combat._apply_damage(0, base.attack, context)
	combat.update(0.01, context)
	if combat.cuts_on(0) != CombatSystem.CUTS_MAX:
		_fail("seigneur : hors Éveil, les entailles ne plafonnent pas à %d" % CombatSystem.CUTS_MAX)

	# Le Pas des Mille Lames : la lame fantôme repasse et entaille encore.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var way := _open_way(grid, context.player_cell)
	if way == Vector2i.ZERO:
		_fail("seigneur : pas de couloir pour le Pas")
		return
	context.player_facing = way
	_add_enemy(context, context.player_cell + way * 2, 1000)
	if not combat.use(form.abilities[0], context):
		_fail("seigneur : le Pas des Mille Lames ne part pas")
	var after_dash := context.enemy_health[0].current
	combat.update(form.abilities[0].dash_echo_delay + 0.05, context)
	if context.enemy_health[0].current >= after_dash:
		_fail("seigneur : la lame fantôme ne repasse pas")

	# La Garde du Seigneur pare deux coups, et riposte aux deux.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 1000)
	combat.use(form.abilities[1], context)
	var full := health.current
	health.take(Damage.new(1))
	combat.update(0.05, context)
	combat.update(CombatSystem.PARRY_LOCK + 0.05, context)
	health.take(Damage.new(1))
	combat.update(0.05, context)
	if health.current != full:
		_fail("seigneur : la Garde du Seigneur ne pare pas le second coup")
	if 1000 - context.enemy_health[0].current < form.abilities[1].damage * 2:
		_fail("seigneur : la Garde ne riposte pas à chaque parade")

	# La Rengaine écarlate : l'éclat entaille le voisin.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var near := _cluster(grid, context, _cell_at(grid, context.player_field, 3), 2)
	_add_enemy(context, near[0], 1000)
	_add_enemy(context, near[1], 1000)
	combat._add_cuts(0, 3)
	if not combat.use(form.abilities[2], context):
		_fail("seigneur : la Rengaine écarlate ne part pas")
	combat.update(CombatSystem.SHEATHE_SILENCE + 0.05, context)
	if combat.cuts_on(1) != form.abilities[2].petal_cuts:
		_fail("seigneur : les pétales-lames n'entaillent pas le voisin (%d)" % combat.cuts_on(1))

	# La Danse des pétales : le tourbillon entaille ce qui l'entoure.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	way = _open_way(grid, context.player_cell)
	context.player_facing = -way
	_add_enemy(context, context.player_cell - way, 1000)
	if not combat.use(form.escape, context):
		_fail("seigneur : la Danse des pétales ne part pas")
	for i in 10:
		combat.update(0.1, context)
	if context.enemy_health[0].current >= 1000 or combat.cuts_on(0) < form.escape.cuts:
		_fail("seigneur : le tourbillon de pétales n'entaille pas")

	# La Nuit Écarlate : huit entailles par ennemi, qui n'éclatent qu'à la fin.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.start_keen()
	_add_enemy(context, _cell_at(grid, context.player_field, 4), 1000)
	combat.use(form.ultimate, context)
	combat.update(0.05, context)
	if combat.cuts_on(0) != 8:
		_fail("seigneur : la Nuit Écarlate pose %d entailles au lieu de 8" % combat.cuts_on(0))
	combat.update(form.ultimate.duration, context)
	if 1000 - context.enemy_health[0].current < form.ultimate.cut_damage * 8:
		_fail("seigneur : la Nuit Écarlate n'ouvre pas les huit entailles")
	print("seigneur écarlate : lame affûtée, pas, garde, rengaine, danse, nuit : OK")


## LE GARDIEN DE L'ABÎME : le Poids des chaînes, les trois crochets, les chaînes qui cèdent, le givre, le Pas et l'Abîme.
func _test_warden() -> void:
	var base := CharacterCatalog.geolier()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Gardien de l'Abîme":
		_fail("gardien : pas d'éveil pour le Geôlier")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.abyss_open():
		_fail("gardien : le Poids des chaînes ne commence pas avec l'Éveil")
	var shackles := {"n": 0}
	combat.enemy_shackled.connect(func(_i: int, _s: float) -> void: shackles["n"] += 1)
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 1000)
	combat._apply_damage(0, base.attack, context)
	combat._apply_damage(0, base.attack, context)
	if shackles["n"] != 1:
		_fail("gardien : l'ennemi n'est pas entravé au deuxième coup")
	if not combat.held(0):
		_fail("gardien : l'entravé n'est pas tenu pour pris")
	var before := context.enemy_health[0].current
	combat._apply_damage(0, base.attack, context)
	var expected := int(round(float(base.attack.damage) * (1.0 + CombatSystem.ABYSS_HELD_BONUS)))
	if before - context.enemy_health[0].current != expected:
		_fail("gardien : un entravé prend %d au lieu de %d" % [before - context.enemy_health[0].current, expected])
	awakening.update(Awakening.DURATION)
	if combat.abyss_open():
		_fail("gardien : le Poids des chaînes survit à l'Éveil")

	# Les Crochets de l'Abîme : trois ennemis ramenés à la fois, chacun sur sa case.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	for steps in [4, 5, 6]:
		_add_enemy(context, _cell_at(grid, context.player_field, steps), 1000)
	if not combat.use(form.abilities[0], context):
		_fail("gardien : les Crochets ne partent pas")
	var spots := {}
	for i in 3:
		spots[context.enemy_cells[i]] = true
		if Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i]) > 3:
			_fail("gardien : le crochet %d n'a pas ramené sa proie" % i)
	if spots.size() != 3:
		_fail("gardien : deux proies des crochets tombent sur la même case")

	# Les Chaînes de l'Abîme cèdent en se resserrant.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 1000)
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 1000)
	var snapped := {"n": 0}
	combat.chains_snapped.connect(func(indices: Array, _s: float) -> void: snapped["n"] = indices.size())
	combat.use(form.abilities[1], context)
	for i in 80:
		combat.update(0.1, context)
	if snapped["n"] != 2:
		_fail("gardien : les chaînes ne se resserrent pas sur leurs deux proies (%d)" % snapped["n"])

	# L'Hiver de l'Abîme laisse sa plaque de givre.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var plates := {"n": 0}
	combat.zone_created.connect(func(_id: int, ability: Ability, _c: Vector2i) -> void:
		if ability.zone_style == "givre_abime":
			plates["n"] += 1)
	combat.use(form.abilities[2], context)
	if plates["n"] != 1:
		_fail("gardien : l'Hiver ne laisse pas de plaque de givre")

	# Le Pas de l'Abîme se reforme dans une onde de givre.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var waves := {"n": 0}
	combat.frost_wave.connect(func(_c: Vector2i, _r: float) -> void: waves["n"] += 1)
	for way: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		context.player_facing = way
		if combat.use(form.escape, context):
			break
	if waves["n"] != 1:
		_fail("gardien : le Pas de l'Abîme ne lance pas son onde de givre")

	# L'Abîme : il tire ses prisonniers vers lui, puis se referme sur eux.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var far := Vector2i(-1, -1)
	for cell in grid.all_floor_cells():
		var steps := Pathfinder.value_at(grid, context.player_field, cell)
		if steps >= 4 and Vector2(cell - context.player_cell).length() <= form.ultimate.radius:
			far = cell
			break
	if far == Vector2i(-1, -1):
		_fail("gardien : pas de case pour l'Abîme")
		return
	_add_enemy(context, far, 1000)
	var closed := {"n": 0}
	combat.abyss_closed.connect(func(_c: Array) -> void: closed["n"] += 1)
	combat.use(form.ultimate, context)
	var start := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[0])
	for i in 25:
		combat.update(0.1, context)
	if Pathfinder.value_at(grid, context.player_field, context.enemy_cells[0]) >= start:
		_fail("gardien : l'Abîme ne tire pas son prisonnier")
	for i in 50:
		combat.update(0.1, context)
	if closed["n"] != 1 or 1000 - context.enemy_health[0].current < form.ultimate.gaol_end_damage:
		_fail("gardien : l'Abîme ne se referme pas sur son prisonnier")
	print("gardien de l'abîme : poids des chaînes, crochets, chaînes, hiver, pas, abîme : OK")


## LE DRAGON PRIMORDIAL : le Feu primordial, la Bombe, le Souffle qui déborde, le Dévoreur, la Carapace, l'Envol
## et le Ciel en feu.
func _test_primal() -> void:
	var base := CharacterCatalog.dragon()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Dragon Primordial":
		_fail("primordial : pas d'éveil pour le Dragon des Abysses")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.primal():
		_fail("primordial : le Feu primordial ne commence pas avec l'Éveil")
	var spot := _cell_at(grid, context.player_field, 3)
	combat._ignite_cells([spot], 4.0)
	if absf(float(combat.fire_cells()[spot]) - 4.0 * CombatSystem.PRIMAL_FIRE_LONGER) > 0.01:
		_fail("primordial : ses cases ne brûlent pas deux fois plus longtemps")
	# Ce qui meurt dans le feu explose sur son voisin.
	var near := _cluster(grid, context, spot, 2)
	_add_enemy(context, spot, 1)
	_add_enemy(context, near[1] if near[0] == spot else near[0], 500)
	combat._apply_damage(0, base.attack, context)
	combat.update(0.01, context)
	if context.enemy_health[1].current > 500 - CombatSystem.PRIMAL_BURST_DAMAGE:
		_fail("primordial : la mort dans le feu n'explose pas sur le voisin")
	awakening.update(Awakening.DURATION)
	if combat.primal():
		_fail("primordial : le Feu primordial survit à l'Éveil")

	# Le Souffle primordial déborde sur les bords du couloir.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var spread := {"cells": 0}
	combat.breath_cast.connect(func(_f: Vector2i, cells: Array, _s: float) -> void: spread["cells"] = cells.size())
	var lit := false
	for way: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		context.player_facing = way
		if combat.use(form.abilities[0], context):
			lit = true
			break
	if not lit or spread["cells"] <= 0:
		_fail("primordial : le Souffle primordial ne part pas")

	# Le Dévoreur avale une proie en feu assez blessée.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var prey := _cell_at(grid, context.player_field, 2)
	_add_enemy(context, prey, 100)
	combat.fire_cells()[prey] = 5.0
	combat.use(form.abilities[1], context)
	if context.enemy_alive(0):
		_fail("primordial : le Dévoreur n'avale pas la proie en feu blessée")

	# La Carapace encaisse deux coups.
	parts = _context(base)
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.use(form.abilities[2], context)
	if health.shield != 2:
		_fail("primordial : la Carapace n'encaisse pas deux coups (%d)" % health.shield)

	# L'Envol retombe dans un anneau de feu.
	parts = _context(base)
	combat = parts[1]
	context = parts[2]
	combat.use(form.escape, context)
	if not combat.flying():
		_fail("primordial : l'Envol ne décolle pas")
	for i in 25:
		combat.update(0.1, context)
	if combat.flying() or not combat.fire_cells().has(context.player_cell):
		_fail("primordial : l'Envol ne retombe pas dans le feu")

	# Le Ciel en feu : un météore par proie, qui laisse le sol en feu.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var far := _cell_at(grid, context.player_field, 4)
	_add_enemy(context, far, 1000)
	combat.use(form.ultimate, context)
	for i in 40:
		combat.update(0.1, context)
	if 1000 - context.enemy_health[0].current < form.ultimate.damage:
		_fail("primordial : le météore ne frappe pas sa proie")
	if not combat.fire_cells().has(far):
		_fail("primordial : le point d'impact du météore ne reste pas en feu")
	print("dragon primordial : feu, souffle, dévoreur, carapace, envol, ciel en feu : OK")


## LE MAÎTRE DU CASINO : la Maison gagne toujours, les Dés du Diable, la Table piégée, la Pièce truquée, le leurre
## qui s'éteint et le Grand Jeu.
func _test_casino() -> void:
	var base := CharacterCatalog.croupier()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Maître du Casino":
		_fail("casino : pas d'éveil pour le Croupier des Enfers")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.house():
		_fail("casino : la Maison gagne toujours ne commence pas avec l'Éveil")
	var near := _cluster(grid, context, _cell_at(grid, context.player_field, 3), 2)
	_add_enemy(context, near[0], 100000)
	_add_enemy(context, near[1], 100000)
	var payouts := {"n": 0}
	combat.house_payout.connect(func(_c: Vector2i, _r: float) -> void: payouts["n"] += 1)
	for i in 40:
		combat._apply_damage(0, form.attack, context)
		combat.update(0.01, context)
	if payouts["n"] == 0 or context.enemy_health[1].current >= 100000:
		_fail("casino : aucun Coup de chance ne paie ses jetons sur le voisin")
	awakening.update(Awakening.DURATION)
	if combat.house():
		_fail("casino : la Maison survit à l'Éveil")

	# Les Dés du Diable roulent un troisième dé.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var dice := {"n": 0}
	combat.devil_die.connect(func(_f: Vector2i, _c: Array, _v: int, _t: bool) -> void: dice["n"] += 1)
	for way: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		context.player_facing = way
		if combat.use(form.abilities[0], context):
			break
	if dice["n"] != 1:
		_fail("casino : les Dés du Diable ne roulent pas de troisième dé")

	# La Table piégée pose ses cartes en croix.
	parts = _context(base)
	combat = parts[1]
	context = parts[2]
	combat.use(form.abilities[1], context)
	if combat.traps().size() < 2:
		_fail("casino : la Table piégée ne pose pas ses cartes en croix (%d)" % combat.traps().size())

	# La Pièce truquée donne les deux faces.
	parts = _context(base)
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.use(form.abilities[2], context)
	if not health.immune or combat.doubled_left() != form.abilities[2].doubled_hits:
		_fail("casino : la Pièce truquée ne donne pas les deux faces")

	# Le leurre du Grand tour de magie s'éteint, et explose sur ce qui l'entoure.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var start := context.player_cell
	for way: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		context.player_facing = way
		if combat.use(form.escape, context):
			break
	var lure_gone := {"n": 0}
	combat.decoy_blew.connect(func(_c: Vector2i, _r: float) -> void: lure_gone["n"] += 1)
	_add_enemy(context, _cluster(grid, context, start, 2)[1], 1000)
	for i in 30:
		combat.update(0.1, context)
	if lure_gone["n"] != 1:
		_fail("casino : la carte du Grand tour ne s'éteint jamais")

	# Le Grand Jeu fait tourner la roue trois fois.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 100000)
	var landed := {"n": 0}
	combat.roulette_landed.connect(func(_r: int, _c: Array) -> void: landed["n"] += 1)
	combat.use(form.ultimate, context)
	for i in 70:
		combat.update(0.1, context)
	if landed["n"] != form.ultimate.roulette_spins:
		_fail("casino : la roue du Grand Jeu tourne %d fois au lieu de %d" % [landed["n"], form.ultimate.roulette_spins])
	print("maître du casino : maison, dés, table, pièce, tour, grand jeu : OK")


## FAIM SANS FOND : la Faim sans fond, les Langues voraces, Tout dévorer, le Déluge de bile, le Bond et le Grand Festin.
func _test_endless() -> void:
	var base := CharacterCatalog.avide()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Faim Sans Fond":
		_fail("faim : pas d'éveil pour l'Avide")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.endless():
		_fail("faim : la Faim sans fond ne commence pas avec l'Éveil")
	for k in 6:
		_add_enemy(context, _cell_at(grid, context.player_field, 2), 1)
		combat._apply_damage(context.enemy_cells.size() - 1, base.attack, context)
	if combat.bites() != CombatSystem.ENDLESS_BITES:
		_fail("faim : il ne garde pas %d bouchées (%d)" % [CombatSystem.ENDLESS_BITES, combat.bites()])
	combat.update(CombatSystem.BITE_DECAY + 1.0, context)
	if combat.bites() != CombatSystem.ENDLESS_BITES:
		_fail("faim : ses bouchées fondent encore pendant l'Éveil")
	awakening.update(Awakening.DURATION)
	if combat.endless() or combat.bites() > CombatSystem.BITES_MAX:
		_fail("faim : la Faim sans fond survit à l'Éveil")

	# Les Langues voraces : trois langues, trois cibles.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var near := _cluster(grid, context, _cell_at(grid, context.player_field, 3), 3)
	for cell in near:
		_add_enemy(context, cell, 1000)
	combat.use(form.attack, context)
	for i in 30:
		combat.update(0.05, context)
	var hit := 0
	for i in 3:
		if context.enemy_health[i].current < 1000:
			hit += 1
	if hit < 3:
		_fail("faim : les Langues voraces ne touchent que %d cibles" % hit)

	# Tout dévorer : deux proies blessées avalées d'un coup.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	near = _cluster(grid, context, context.player_cell, 3)
	_add_enemy(context, near[1], 100)
	_add_enemy(context, near[2], 100)
	context.enemy_health[0].take(Damage.new(60))
	context.enemy_health[1].take(Damage.new(60))
	combat.use(form.abilities[1], context)
	if context.enemy_alive(0) or context.enemy_alive(1):
		_fail("faim : Tout dévorer n'avale pas les deux proies blessées")

	# Le Déluge de bile laisse ses flaques.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	_add_enemy(context, _cell_at(grid, context.player_field, 3), 1000)
	combat._bites = 3
	var puddles := {"n": 0}
	combat.zone_created.connect(func(_id: int, ability: Ability, _c: Vector2i) -> void:
		if ability.zone_style == "bile_peinte":
			puddles["n"] += 1)
	combat.use(form.abilities[2], context)
	if puddles["n"] < 1:
		_fail("faim : le Déluge de bile ne laisse pas de flaque")

	# Le Bond du prédateur mord à l'atterrissage.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	var way := _open_way(grid, context.player_cell)
	context.player_facing = way
	var landing := context.player_cell
	for _s in form.escape.range:
		if grid.is_floor_v(landing + way):
			landing += way
	var beside := _cluster(grid, context, landing, 2)[1]
	_add_enemy(context, beside, 1000)
	combat.use(form.escape, context)
	if context.enemy_health[0].current >= 1000:
		_fail("faim : le Bond du prédateur ne mord pas à l'atterrissage")

	# Le Grand Festin avale plus vite.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	for cell in _cluster(grid, context, _cell_at(grid, context.player_field, 2), 4):
		_add_enemy(context, cell, 1)
	combat.use(form.ultimate, context)
	for i in int((CombatSystem.FEAST_FIRST + form.ultimate.feast_gap * 2.0 + 0.2) / 0.05):
		combat.update(0.05, context)
	var eaten := 0
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i):
			eaten += 1
	if eaten < 3:
		_fail("faim : le Grand Festin n'avale que %d proies" % eaten)
	print("faim sans fond : faim, langues, dévorer, bile, bond, grand festin : OK")


func _test_archdemon() -> void:
	var base := CharacterCatalog.demon()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Archidémon du Pacte":
		_fail("archidémon : pas d'éveil pour le Démon du Pacte")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.blood_pricing():
		_fail("archidémon : le Prix du Sang ne commence pas avec l'Éveil")
	var full := health.current
	combat.update(Awakening.BLOOD_EVERY + 0.01, context)
	if health.current != full - 1:
		_fail("archidémon : sa vie ne coule pas (%d PV au lieu de %d)" % [health.current, full - 1])
	health.sacrifice(health.current - 1)
	combat.update(Awakening.BLOOD_EVERY + 0.01, context)
	if health.current != 1:
		_fail("archidémon : le Prix du Sang a pris le dernier PV")
	if absf(combat.rage_bonus() - CombatSystem.RAGE_MAX * Awakening.BLOOD_RAGE) > 0.001:
		_fail("archidémon : la Rage ne double pas à 1 PV (%.2f)" % combat.rage_bonus())
	_add_enemy(context, _cell_at(grid, context.player_field, 2), 1)
	combat._apply_damage(0, form.attack, context)
	if health.current != 2:
		_fail("archidémon : un kill ne lui rend pas 1 PV (%d PV)" % health.current)
	awakening.update(Awakening.DURATION)
	if combat.blood_pricing():
		_fail("archidémon : le Prix du Sang survit à l'Éveil")

	# Le Pacte écarlate : 1 PV, l'onde, et le renfort.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	_add_enemy(context, _cell_at(grid, context.player_field, 1), 500)
	var pact: Ability = form.abilities[0]
	if not combat.use(pact, context):
		_fail("archidémon : le Pacte écarlate ne part pas")
	if health.current != health.maximum - 1:
		_fail("archidémon : le Pacte écarlate ne coûte pas 1 PV")
	if context.enemy_health[0].current >= 500:
		_fail("archidémon : l'onde du Pacte écarlate ne blesse pas")
	if combat.empower_bonus() != pact.empower_bonus:
		_fail("archidémon : le Pacte écarlate ne renforce pas ses coups")

	# La Gueule de l'Abîme : 1 PV par ennemi happé, 2 au plus.
	var maw: Ability = form.abilities[2]
	for crowd: int in [1, 3]:
		parts = _context(base)
		grid = parts[0]
		combat = parts[1]
		context = parts[2]
		health = parts[3]
		health.sacrifice(health.current - 1)
		var near: Array[Vector2i] = []
		for cell in grid.all_floor_cells():
			var steps := Pathfinder.value_at(grid, context.player_field, cell)
			if steps >= 1 and steps <= 2 and near.size() < crowd:
				near.append(cell)
		for cell in near:
			_add_enemy(context, cell, 500)
		combat.use(maw, context)
		var expected := 1 + mini(maw.heal_self, near.size())
		if health.current != expected:
			_fail("archidémon : la Gueule rend %d PV pour %d ennemis (attendu %d)" % [
				health.current - 1, near.size(), expected - 1])

	# Les Fleuves de soufre partent dans tous les couloirs ; les Ailes s'envolent.
	parts = _context(base)
	combat = parts[1]
	context = parts[2]
	if not form.abilities[1].line_cross or not combat.use(form.abilities[1], context):
		_fail("archidémon : les Fleuves de soufre ne partent pas")
	if form.escape.kind != Ability.Kind.FLIGHT or not combat.use(form.escape, context) or not combat.flying():
		_fail("archidémon : les Ailes du Pacte ne s'envolent pas")

	# L'Apocalypse : 1 PV, intouchable, des serres qui tombent, et tout revient à la fin.
	parts = _context(base)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	_add_enemy(context, _cell_at(grid, context.player_field, 7), 5000)
	var struck := [0]
	combat.pact_claw_struck.connect(func(_cell: Vector2i) -> void: struck[0] += 1)
	combat.use(form.ultimate, context)
	if health.current != 1 or not health.immune:
		_fail("archidémon : l'Apocalypse ne le met pas à 1 PV, intouchable")
	for i in 30:
		combat.update(0.1, context)
	if struck[0] < 2 or context.enemy_health[0].current >= 5000:
		_fail("archidémon : les serres de l'Apocalypse ne tombent pas (%d)" % struck[0])
	for i in 60:
		combat.update(0.1, context)
	if health.current != health.maximum:
		_fail("archidémon : l'Apocalypse ne rend pas tout ce qu'il a donné (%d PV)" % health.current)
	print("archidémon du pacte : prix du sang, serres, pacte écarlate, gueule, fleuves, ailes et apocalypse : OK")


## LE SEIGNEUR DU FLÉAU (l'Éveil du Mage de la Peste) : le Miasme et son plafond de 5 doses, la gerbe du Crachat,
## les flaques du Sillage, l'Épidémie, la Saignée, la Nuée de corbeaux et la Grande Peste.
## L'ARCHIMAGE PRIMORDIAL (l'Éveil du Sorcier Suprême) : la roue tourne et porte le trait de l'orbe en tête, la
## Convergence se brise en quatre éclats, les sceaux le suivent, l'Apothéose double l'Écho, le Pas des éléments
## lance ses rayons, et la Genèse fait tomber ses météores dans l'ordre de la roue avant la nova.
## L'ÉTOILE DU MATIN : l'Éblouissement frappe plus fort l'aveuglé et aveugle ce qui reste collé, un coup sur trois
## du Trait aveugle, la Lance reste allumée, la Cathédrale soigne, l'Égide renvoie, le Trait de l'étoile aveugle, et le
## Soleil de midi lance ses rayons puis tombe.
## LE FAUCHEUR DES ÂMES : la Récolte achève sous 25 % et garde six âmes, qui frappent ce qui l'approche ; le croissant
## revient et frappe au retour, le Glas sonne trois fois, la Légion lâche trois âmes de plus, et Minuit passe deux fois.
func _test_reaper() -> void:
	var base := CharacterCatalog.mort()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Faucheur des Âmes":
		_fail("faucheur : pas d'éveil pour l'Ange de la Mort")
		return
	var parts := _context(base)
	var awakening := Awakening.new(base, form, parts[1], parts[2])
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not (parts[1] as CombatSystem).harvest_active():
		_fail("faucheur : pas de récolte à l'éveil")
	awakening.finish()
	if (parts[1] as CombatSystem).harvest_active():
		_fail("faucheur : la récolte survit à l'éveil")
	awakening.dispose()

	parts = _context(form)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	combat.free_use = true
	combat.start_harvest()
	# Six âmes au plus pendant la Récolte.
	for n in 8:
		combat._gain_soul()
	if combat.souls() != CombatSystem.HARVEST_SOULS:
		_fail("faucheur : %d âmes gardées au lieu de 6" % combat.souls())
	# La Sentence achève sous 25 % : un ennemi à 20 % tombe au premier croissant.
	var path := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 5))
	_add_enemy(context, path[-1], 1000)
	context.enemy_health[0].current = 200
	combat.use(form.attack, context)
	for frame in 80:
		combat.update(0.02, context)
	if context.enemy_alive(0):
		_fail("faucheur : un ennemi à 20 %% n'est pas achevé (%d PV)" % context.enemy_health[0].current)
	# Le croissant revient : ce qui se tient sur le chemin du retour est touché.
	context.enemy_cells.clear()
	context.enemy_health.clear()
	_add_enemy(context, path[-1], 5000)
	_add_enemy(context, path[2], 5000)
	var target_first := {"hit": false}
	combat.crescent_returned.connect(func(_p: Array, _d: float) -> void: target_first["hit"] = true)
	combat._souls = 0
	combat.use(form.attack, context)
	for frame in 150:
		combat.update(0.02, context)
	if not bool(target_first["hit"]) or context.enemy_health[1].current >= 5000:
		_fail("faucheur : le croissant ne frappe pas au retour")
	# Une âme en orbite frappe ce qui arrive à son contact.
	context.enemy_cells.clear()
	context.enemy_health.clear()
	var beside := Vector2i(-1, -1)
	for step: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if grid.is_floor_v(context.player_cell + step):
			beside = context.player_cell + step
	_add_enemy(context, beside, 5000)
	combat._gain_soul()
	combat.update(0.02, context)
	if combat.souls() != 0 or context.enemy_health[0].current >= 5000:
		_fail("faucheur : l'âme en orbite ne frappe pas (%d âmes)" % combat.souls())
	# Le Glas sonne trois fois, et marque ce qui est proche.
	var tolls := {"count": 0}
	combat.toll_rang.connect(func(_c: Vector2i, _r: float) -> void: tolls["count"] += 1)
	combat.use(form.abilities[1], context)
	for frame in 250:
		combat.update(0.02, context)
	if int(tolls["count"]) != form.abilities[1].toll_count:
		_fail("faucheur : le glas sonne %d fois" % int(tolls["count"]))
	# La Légion lâche trois âmes de plus que les siennes.
	var sent := {"count": 0}
	combat.soul_sent.connect(func(_p: Array, _d: float) -> void: sent["count"] += 1)
	combat._souls = 0
	combat.use(form.abilities[2], context)
	if int(sent["count"]) != form.abilities[2].souls_base:
		_fail("faucheur : la légion lâche %d âmes" % int(sent["count"]))
	# Minuit : deux passages de faux. Un ennemi indemne survit à 25 % ; un ennemi déjà blessé est achevé.
	context.enemy_cells.clear()
	context.enemy_health.clear()
	_add_enemy(context, path[-1], 1000)
	_add_enemy(context, path[-2], 1000)
	context.enemy_health[1].current = 700
	var passes := {"count": 0}
	combat.last_hour_struck.connect(func(_c: Vector2i) -> void: passes["count"] += 1)
	combat.use(form.ultimate, context)
	for frame in 200:
		combat.update(0.02, context)
	if int(passes["count"]) != 4 or not context.enemy_alive(0) or context.enemy_alive(1):
		_fail("faucheur : minuit frappe %d fois, PV %d et %d" % [int(passes["count"]),
			context.enemy_health[0].current, context.enemy_health[1].current])
	print("faucheur des âmes : récolte, croissant, âmes gardiennes, glas, légion et minuit : OK")


func _test_morning_star() -> void:
	var base := CharacterCatalog.lumiere()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Étoile du Matin":
		_fail("étoile du matin : pas d'éveil pour le Porte-Lumière")
		return
	var parts := _context(base)
	var awakening := Awakening.new(base, form, parts[1], parts[2])
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not (parts[1] as CombatSystem).dazzle_active():
		_fail("étoile du matin : pas d'éblouissement à l'éveil")
	awakening.finish()
	if (parts[1] as CombatSystem).dazzle_active():
		_fail("étoile du matin : l'éblouissement survit à l'éveil")
	awakening.dispose()

	parts = _context(form)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	combat.free_use = true
	combat.start_dazzle(60.0)
	var path := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 5))
	_add_enemy(context, path[-1], 5000)
	var hits := {"last": 0}
	combat.enemy_damaged.connect(func(_i: int, dealt: int, ability: Ability) -> void:
		if ability.id == form.attack.id:
			hits["last"] = dealt)
	# L'Éblouissement : le même trait fait 30 % de plus sur un aveuglé.
	combat._blind_locks.clear()
	combat.use(form.attack, context)
	for frame in 80:
		combat.update(0.02, context)
	var plain := int(hits["last"])
	combat._blind_locks.clear()
	combat._blind(0, 3.0, context, true)
	combat.use(form.attack, context)
	for frame in 80:
		combat.update(0.02, context)
	if int(hits["last"]) != int(round(float(plain) * (1.0 + CombatSystem.DAZZLE_BONUS))):
		_fail("étoile du matin : %d sur un aveuglé contre %d" % [int(hits["last"]), plain])
	# Ce qui reste collé à lui plus d'une seconde finit aveuglé.
	var beside := Vector2i(-1, -1)
	for step: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if grid.is_floor_v(context.player_cell + step):
			beside = context.player_cell + step
	_add_enemy(context, beside, 5000)
	combat._blind_locks.clear()
	for frame in 60:
		combat.update(0.02, context)
	if not combat.is_blinded(1):
		_fail("étoile du matin : collé à lui, l'ennemi n'est pas aveuglé")
	# La Lance de l'Aurore reste allumée : ce qui marche dessus ensuite brûle et ne voit plus.
	var walls := {"cells": []}
	combat.light_wall_raised.connect(func(cells: Array, _s: float) -> void: walls["cells"] = cells)
	combat.use(form.abilities[0], context)
	var lit: Array = walls["cells"]
	if lit.size() < 3:
		_fail("étoile du matin : la lance ne reste pas allumée")
	else:
		context.enemy_cells[1] = lit[1]
		combat._blind_locks.clear()
		var before := context.enemy_health[1].current
		for frame in 50:
			combat.update(0.02, context)
		if context.enemy_health[1].current >= before or not combat.is_blinded(1):
			_fail("étoile du matin : le mur de lumière ne brûle ni n'aveugle")
	# La Cathédrale de lumière lui rend un PV toutes les quatre secondes passées dedans.
	context.enemy_cells.clear()
	context.enemy_health.clear()
	health.take(Damage.new(2, Element.Kind.FIRE, "test"))
	var hurt := health.current
	combat.use(form.abilities[1], context)
	for frame in 215:
		combat.update(0.02, context)
	if health.current != hurt + 1:
		_fail("étoile du matin : la cathédrale rend %d PV en 4,3 s" % (health.current - hurt))
	# L'Égide solaire renvoie chaque coup encaissé en rayon.
	_add_enemy(context, beside, 5000)
	var rays := {"count": 0}
	combat.aegis_ray.connect(func(_f: Vector2i, _t: Vector2i) -> void: rays["count"] += 1)
	combat.use(form.abilities[2], context)
	health.take(Damage.new(1, Element.Kind.FIRE, "test"))
	combat.update(0.02, context)
	if int(rays["count"]) != 1 or context.enemy_health[0].current >= 5000:
		_fail("étoile du matin : l'égide renvoie %d rayons" % int(rays["count"]))
	# Le Soleil de midi : un rayon par seconde sur ce qui est à l'écran, puis il tombe.
	var sun := {"rays": 0, "set": 0}
	combat.sun_rays.connect(func(cells: Array) -> void: sun["rays"] += cells.size())
	combat.sun_set.connect(func(_c: Vector2i, _r: float) -> void: sun["set"] += 1)
	combat.use(form.ultimate, context)
	for frame in 450:
		combat.update(0.02, context)
	if int(sun["rays"]) < 7 or int(sun["set"]) != 1:
		_fail("étoile du matin : le soleil lance %d rayons et tombe %d fois" % [int(sun["rays"]), int(sun["set"])])
	print("étoile du matin : éblouissement, lance, cathédrale, égide et soleil de midi : OK")


func _test_primordial() -> void:
	var base := CharacterCatalog.supreme()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Archimage Primordial":
		_fail("archimage : pas d'éveil pour le Sorcier Suprême")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.wheel_active() or combat.wheel_rank() != 0:
		_fail("archimage : pas de roue à l'éveil")
	awakening.finish()
	if combat.wheel_active():
		_fail("archimage : la roue survit à l'éveil")
	awakening.dispose()

	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	combat.free_use = true
	combat.start_wheel(60.0)
	# La roue : la première attaque brûle (le feu), la deuxième trempe (l'eau), et elle a tourné deux fois.
	var path := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 5))
	_add_enemy(context, path[-1], 5000)
	var traits := {"burn": 0, "soak": 0}
	combat.enemy_burning.connect(func(_i: int, _s: float) -> void: traits["burn"] += 1)
	combat.enemy_soaked.connect(func(_i: int, _s: float, _f: float) -> void: traits["soak"] += 1)
	combat.use(form.attack, context)
	if combat.wheel_rank() != 1:
		_fail("archimage : la roue ne tourne pas après l'attaque")
	for frame in 80:
		combat.update(0.02, context)
	if int(traits["burn"]) < 1 or int(traits["soak"]) != 0:
		_fail("archimage : la première attaque ne porte pas le feu (%d brûlures, %d trempes)"
			% [int(traits["burn"]), int(traits["soak"])])
	combat.use(form.attack, context)
	for frame in 80:
		combat.update(0.02, context)
	if int(traits["soak"]) < 1 or combat.wheel_rank() != 2:
		_fail("archimage : la deuxième attaque ne porte pas l'eau")
	# La Grande Convergence se brise en quatre éclats, même sur deux cibles.
	_add_enemy(context, path[-2], 5000)
	var shards := {"count": 0}
	combat.element_shards_flew.connect(func(_f: Vector2i, t: Array, _r: Array) -> void: shards["count"] = t.size())
	combat.use(form.abilities[0], context)
	for frame in 150:
		combat.update(0.02, context)
	if int(shards["count"]) != form.abilities[0].element_shards:
		_fail("archimage : la convergence lâche %d éclats" % int(shards["count"]))
	# L'Apothéose : son Écho frappe deux fois.
	var echoes := {"count": 0}
	combat.enemy_damaged.connect(func(_i: int, _d: int, ability: Ability) -> void:
		if ability.id.ends_with("_echo"):
			echoes["count"] += 1)
	combat.use(form.abilities[2], context)
	echoes["count"] = 0
	combat.use(form.attack, context)
	for frame in 100:
		combat.update(0.02, context)
	if int(echoes["count"]) != 2:
		_fail("archimage : l'apothéose donne %d échos au lieu de 2" % int(echoes["count"]))
	# La Couronne des sceaux : quatre sceaux, qui le suivent quand il marche.
	context.enemy_cells.clear()
	context.enemy_health.clear()
	var zones := {"made": 0, "moved": 0}
	combat.zone_created.connect(func(_id: int, _a: Ability, _c: Vector2i) -> void: zones["made"] += 1)
	combat.zone_moved.connect(func(_id: int, _c: Vector2i) -> void: zones["moved"] += 1)
	combat.use(form.abilities[1], context)
	var walk := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 4))
	for cell: Vector2i in walk:
		context.player_cell = cell
		combat.update(0.1, context)
	if int(zones["made"]) != 4 or int(zones["moved"]) < 1:
		_fail("archimage : la couronne pose %d sceaux et les déplace %d fois" % [int(zones["made"]), int(zones["moved"])])
	# Le Pas des éléments : un rayon part de l'arrivée et frappe ce qui est dans son couloir.
	context.player_cell = grid.player_spawn
	context.player_field = Pathfinder.distance_field(grid, [context.player_cell] as Array[Vector2i])
	var facing := Vector2i.ZERO
	for direction: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]:
		if grid.is_floor_v(context.player_cell + direction):
			facing = direction
			break
	context.player_facing = facing
	var rays := {"paths": []}
	combat.element_rays_cast.connect(func(_f: Vector2i, p: Array, _r: Array) -> void: rays["paths"] = p)
	combat.use(form.escape, context)
	var found: Array = rays["paths"]
	if found.is_empty():
		_fail("archimage : le pas des éléments ne lance aucun rayon")
	else:
		var landing := context.player_cell
		context.player_cell = grid.player_spawn
		_add_enemy(context, (found[0] as Array)[0], 5000)
		combat.use(form.escape, context)
		if 5000 - context.enemy_health[0].current < form.escape.element_ray_damage:
			_fail("archimage : le rayon ne frappe pas ce qu'il traverse (arrivée %s)" % str(landing))
	# La Genèse : seize météores dans l'ordre de la roue, puis la nova.
	context.enemy_cells.clear()
	context.enemy_health.clear()
	context.player_cell = grid.player_spawn
	_add_enemy(context, path[-1], 50000)
	_add_enemy(context, path[-2], 50000)
	var genesis := {"ranks": [], "missed": [], "nova": 0}
	combat.element_meteor_struck.connect(func(c: Vector2i, rank: int, _r: float) -> void:
		genesis["ranks"].append(rank)
		if not context.enemy_cells.has(c):
			genesis["missed"].append(c))
	combat.primal_nova.connect(func(_c: Vector2i, _r: float) -> void: genesis["nova"] += 1)
	combat.use(form.ultimate, context)
	# La proie bouge après le lancement : chaque météore tombe quand même sur un ennemi, là où il est.
	context.enemy_cells[0] = path[path.size() / 2]
	for frame in 700:
		combat.update(0.02, context)
	if not (genesis["missed"] as Array).is_empty():
		_fail("archimage : des météores tombent à côté de la proie qui a bougé (%s)" % str(genesis["missed"]))
	var ranks: Array = genesis["ranks"]
	var ordered := ranks.size() == form.ultimate.rain_count
	for k in ranks.size():
		ordered = ordered and int(ranks[k]) == k % 4
	if not ordered or int(genesis["nova"]) != 1:
		_fail("archimage : la genèse fait tomber %s et %d nova" % [str(ranks), int(genesis["nova"])])
	print("archimage primordial : roue, convergence, apothéose, couronne, pas des éléments et genèse : OK")


func _test_scourge() -> void:
	var base := CharacterCatalog.peste()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Seigneur du Fléau":
		_fail("fléau : pas d'éveil pour le Mage de la Peste")
		return
	var parts := _context(base)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	var health: Health = parts[3]
	var awakening := Awakening.new(base, form, combat, context)
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not combat.miasma_active() or combat.venom_cap() != Awakening.MIASMA_CAP:
		_fail("fléau : pas de miasme à l'éveil")
	combat.stats = form
	combat.free_use = true
	# Le Miasme : une créature collée prend une dose par seconde, jusqu'à 5.
	var near := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 1))
	_add_enemy(context, near[-1], 5000)
	for frame in 70:
		combat.update(0.1, context)
	if combat.venom_doses(0) != Awakening.MIASMA_CAP:
		_fail("fléau : le miasme met %d doses au lieu de %d" % [combat.venom_doses(0), Awakening.MIASMA_CAP])
	awakening.finish()
	if combat.miasma_active() or combat.venom_cap() != CombatSystem.VENOM_MAX:
		_fail("fléau : le miasme survit à l'éveil")
	awakening.dispose()

	parts = _context(form)
	grid = parts[0]
	combat = parts[1]
	context = parts[2]
	health = parts[3]
	combat.free_use = true
	combat.start_miasma(60.0, 1.0, Awakening.MIASMA_CAP)
	var path := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 9))
	# Le Crachat éclate en gerbe : deux créatures côte à côte prennent chacune une dose.
	_add_enemy(context, path[mini(5, path.size() - 1)], 5000)
	_add_enemy(context, path[mini(6, path.size() - 1)], 5000)
	combat.use(form.attack, context)
	for frame in 80:
		combat.update(0.02, context)
	if combat.venom_doses(0) < 1 or combat.venom_doses(1) < 1:
		_fail("fléau : la gerbe du crachat n'empoisonne pas les deux (%d, %d)"
			% [combat.venom_doses(0), combat.venom_doses(1)])
	# L'Épidémie saute de l'une à l'autre et ajoute ses doses.
	var jumps := {"count": 0}
	combat.epidemic_jumped.connect(func(_f: Vector2i, _t: Vector2i) -> void: jumps["count"] += 1)
	var before := context.enemy_health[1].current
	combat.use(form.abilities[1], context)
	if int(jumps["count"]) != 2 or context.enemy_health[1].current != before - form.abilities[1].damage:
		_fail("fléau : l'épidémie fait %d sauts au lieu de 2" % int(jumps["count"]))
	# La Saignée fait éclater les doses, et le poison s'en va.
	var doses := combat.venom_doses(0)
	before = context.enemy_health[0].current
	health.take(Damage.new(2, Element.Kind.FIRE, "enemy"))
	var hurt := health.current
	var burst := {"count": 0}
	combat.bled.connect(func(c: Array, _d: Array, _h: int) -> void: burst["count"] = c.size())
	combat.use(form.abilities[2], context)
	if int(burst["count"]) != 2 or combat.venom_doses(0) != 0 \
			or before - context.enemy_health[0].current != doses * form.abilities[2].bleed_per_dose:
		_fail("fléau : la saignée ne fait pas éclater les doses (%d dégâts pour %d doses)"
			% [before - context.enemy_health[0].current, doses])
	if health.current <= hurt:
		_fail("fléau : la saignée ne rend aucun PV")
	# Le Sillage : ses flaques mettent deux doses.
	context.enemy_cells.clear()
	context.enemy_health.clear()
	combat.use(form.abilities[0], context)
	var walk := combat.trajectory(context.player_cell, _cell_at(grid, context.player_field, 4))
	for cell: Vector2i in walk:
		context.player_cell = cell
		combat.update(0.3, context)
	_add_enemy(context, walk[1], 5000)
	combat.update(0.05, context)
	if combat.venom_doses(0) != form.abilities[0].trail_doses:
		_fail("fléau : la flaque du sillage met %d doses" % combat.venom_doses(0))
	# La Nuée de corbeaux pique ce qu'elle survole.
	context.enemy_cells.clear()
	context.enemy_health.clear()
	context.player_cell = grid.player_spawn
	context.player_field = Pathfinder.distance_field(grid, [context.player_cell] as Array[Vector2i])
	var flown := {"to": Vector2i(-1, -1)}
	combat.flock_flew.connect(func(_f: Vector2i, to: Vector2i) -> void: flown["to"] = to)
	var facing := Vector2i.ZERO
	for direction: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]:
		for step in range(form.escape.range, 1, -1):
			var far: Vector2i = context.player_cell + direction * step
			if grid.is_floor_v(far) and not grid.is_occupied(far):
				facing = direction
				break
		if facing != Vector2i.ZERO:
			break
	context.player_facing = facing
	_add_enemy(context, context.player_cell + facing, 5000)
	if not combat.use(form.escape, context) or flown["to"] == Vector2i(-1, -1) \
			or context.enemy_health[0].current != 5000 - form.escape.flock_damage:
		_fail("fléau : la nuée ne pique pas ce qu'elle survole (%d PV)" % context.enemy_health[0].current)
	# La Grande Peste charge tout le monde au plafond et ralentit.
	var slowed := {"count": 0}
	combat.enemy_soaked.connect(func(_i: int, _d: float, f: float) -> void:
		if f == form.ultimate.plague_slow:
			slowed["count"] += 1)
	combat.use(form.ultimate, context)
	if combat.venom_doses(0) != Awakening.MIASMA_CAP or int(slowed["count"]) != 1:
		_fail("fléau : la grande peste ne charge pas au maximum (%d doses)" % combat.venom_doses(0))
	print("seigneur du fléau : miasme, crachat, épidémie, saignée, sillage, nuée et grande peste : OK")


## La Reine du Firmament : cinq étoiles, une figure fermée qui brûle ce qu'elle enferme, l'étoile éphémère du trait,
## le gros météore sur le plus solide, l'anneau de lune de l'Éclipse, l'étoile de la Comète et la galaxie.
func _test_firmament() -> void:
	var base := CharacterCatalog.etoiles()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Reine du Firmament":
		_fail("firmament : pas d'éveil pour l'Ange des Étoiles")
		return
	var parts := _context(base)
	var awakening := Awakening.new(base, form, parts[1], parts[2])
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not (parts[1] as CombatSystem).firmament_active():
		_fail("firmament : pas de firmament à l'éveil")
	awakening.finish()
	if (parts[1] as CombatSystem).firmament_active():
		_fail("firmament : le firmament survit à l'éveil")
	awakening.dispose()

	parts = _context(form)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	combat.free_use = true
	combat.start_firmament()
	# Cinq étoiles en pentagone autour d'un ennemi : la figure se ferme et le brûle, sans qu'un rayon le touche.
	var centre := context.player_cell
	var figure := {"points": []}
	combat.figure_changed.connect(func(points: Array) -> void: figure["points"] = points)
	for n in 6:
		var angle := -PI * 0.5 + TAU * float(n) / 5.0
		combat._plant_star(centre + Vector2i(roundi(cos(angle) * 4.0), roundi(sin(angle) * 4.0)), form.abilities[0])
	if combat._stars.size() != CombatSystem.FIRMAMENT_STARS:
		_fail("firmament : %d étoiles posées au lieu de 5" % combat._stars.size())
	if (figure["points"] as Array).size() < 3:
		_fail("firmament : la figure ne se ferme pas")
	_add_enemy(context, centre, 5000)
	for frame in 50:
		combat.update(0.02, context)
	var burnt := 5000 - context.enemy_health[0].current
	if burnt < 10 or burnt > 30:
		_fail("firmament : la figure brûle %d en une seconde au lieu de 20" % burnt)
	combat.stop_firmament()
	if combat._stars.size() != CombatSystem.STAR_MAX or not (figure["points"] as Array).is_empty():
		_fail("firmament : %d étoiles après l'éveil" % combat._stars.size())
	combat.start_firmament()
	combat._stars.clear()
	# Le Trait de comète : au troisième coup, une étoile éphémère s'allume sur la cible.
	context.enemy_cells.clear()
	context.enemy_health.clear()
	var near := _cell_at(grid, context.player_field, 2)
	var far := _cell_at(grid, context.player_field, 3)
	_add_enemy(context, near, 5000)
	for n in CombatSystem.ASTRE_MARKS:
		combat._add_star_mark(0, form.attack, context)
	if combat._sparks.size() != 1 or combat._sparks[0]["cell"] != near:
		_fail("firmament : pas d'étoile éphémère au troisième coup")
	combat._sparks.clear()
	# La Pluie de météores : le gros météore tombe sur l'ennemi le plus solide.
	_add_enemy(context, far, 9000)
	var meteor := {"cell": Vector2i(-1, -1)}
	combat.big_meteor_struck.connect(func(cell: Vector2i, _r: float) -> void: meteor["cell"] = cell)
	combat.use(form.abilities[1], context)
	for frame in 250:
		combat.update(0.02, context)
	if meteor["cell"] != far:
		_fail("firmament : le gros météore tombe en %s et non sur le plus solide" % str(meteor["cell"]))
	# L'Éclipse : à la fin, l'anneau de lune blesse et ralentit ce qui est proche.
	var ring := {"done": false, "slowed": false}
	combat.eclipse_ended.connect(func(_c: Vector2i, _r: float) -> void: ring["done"] = true)
	combat.enemy_soaked.connect(func(i: int, _s: float, _f: float) -> void: ring["slowed"] = ring["slowed"] or i == 0)
	var before := context.enemy_health[0].current
	combat.use(form.abilities[2], context)
	for frame in 160:
		combat.update(0.02, context)
	if not bool(ring["done"]) or not bool(ring["slowed"]) or context.enemy_health[0].current >= before:
		_fail("firmament : l'anneau de lune ne frappe pas")
	# La Comète pose une étoile là où elle arrive.
	combat._stars.clear()
	combat.use(form.escape, context)
	if combat._stars.size() != 1:
		_fail("firmament : la comète pose %d étoiles" % combat._stars.size())
	# Naissance d'une galaxie : chaque impact devient une étoile, reliée à ses voisines.
	var galaxy := {"cells": 0, "links": 0}
	combat.galaxy_changed.connect(func(cells: Array, links: Array) -> void:
		galaxy["cells"] = maxi(int(galaxy["cells"]), cells.size())
		galaxy["links"] = maxi(int(galaxy["links"]), links.size()))
	combat.use(form.ultimate, context)
	for frame in 200:
		combat.update(0.02, context)
	if int(galaxy["cells"]) != 2 or int(galaxy["links"]) != 1:
		_fail("firmament : galaxie de %d étoiles et %d liens" % [int(galaxy["cells"]), int(galaxy["links"])])
	print("reine du firmament : cinq étoiles, figure, étoile éphémère, météore, éclipse, comète et galaxie : OK")


## Le Forgeron Céleste : cinq plaques, une par kill, des éclats quand une plaque casse, le marteau qui étourdit un coup
## sur trois, la roue de lames, l'enclume qui tombe, le Bastion qui s'ouvre, la charge en fusion et le Cœur de la forge.
func _test_forge() -> void:
	var base := CharacterCatalog.acier()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Forgeron Céleste":
		_fail("forgeron : pas d'éveil pour l'Archange d'Acier")
		return
	var parts := _context(base)
	var awakening := Awakening.new(base, form, parts[1], parts[2])
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	var combat: CombatSystem = parts[1]
	if not combat.forge_active() or combat.plates_left() != CombatSystem.FORGE_PLATES:
		_fail("forgeron : %d plaques à l'éveil" % combat.plates_left())
	awakening.finish()
	if combat.forge_active() or combat.plates_left() != CombatSystem.PLATE_MAX:
		_fail("forgeron : %d plaques après l'éveil" % combat.plates_left())
	awakening.dispose()

	parts = _context(form)
	var grid: MazeGrid = parts[0]
	combat = parts[1]
	var context: CombatContext = parts[2]
	combat.free_use = true
	combat.start_forge()
	# Chaque kill reforge une plaque.
	combat.health.plates = 2
	combat._forge_plate()
	if combat.plates_left() != 3:
		_fail("forgeron : un kill ne reforge pas de plaque (%d)" % combat.plates_left())
	# Une plaque qui casse blesse ce qui est au contact.
	var beside := Vector2i(-1, -1)
	for step: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if grid.is_floor_v(context.player_cell + step):
			beside = context.player_cell + step
	_add_enemy(context, beside, 5000)
	combat.health.take(Damage.new(1, Element.Kind.FIRE, "test"))
	combat.update(0.02, context)
	if context.enemy_health[0].current != 5000 - CombatSystem.FORGE_SHARD_DAMAGE:
		_fail("forgeron : les éclats font %d" % (5000 - context.enemy_health[0].current))
	# Le Marteau du ciel étourdit un coup sur trois.
	var stuns := {"count": 0}
	combat.hammer_stunned.connect(func(_c: Vector2i, _r: float) -> void: stuns["count"] += 1)
	for n in 3:
		combat.use(form.attack, context)
		for frame in 60:
			combat.update(0.02, context)
	if int(stuns["count"]) != 1:
		_fail("forgeron : le marteau étourdit %d fois en trois coups" % int(stuns["count"]))
	# La Tempête : huit lames sur tout le tour.
	var thrown := {"dirs": []}
	combat.blades_thrown.connect(func(_c: Vector2i, dirs: Array, _r: int) -> void: thrown["dirs"] = dirs)
	combat.use(form.abilities[0], context)
	var dirs: Array = thrown["dirs"]
	if dirs.size() != 8 or (dirs[0] as Vector2).dot(dirs[4]) > -0.9:
		_fail("forgeron : la tempête n'est pas une roue de huit lames")
	# L'Enclume céleste tombe sur l'ennemi, puis l'onde part de l'impact.
	context.enemy_cells.clear()
	context.enemy_health.clear()
	var far := _cell_at(grid, context.player_field, 4)
	_add_enemy(context, far, 5000)
	var dropped := {"cell": Vector2i(-1, -1)}
	combat.anvil_dropped.connect(func(c: Vector2i, _r: float) -> void: dropped["cell"] = c)
	var wave := {"from": Vector2i(-1, -1)}
	combat.anvil_struck.connect(func(c: Vector2i, _l: Array) -> void: wave["from"] = c)
	combat.use(form.abilities[1], context)
	for frame in 60:
		combat.update(0.02, context)
	if dropped["cell"] != far or wave["from"] != far \
			or context.enemy_health[0].current > 5000 - form.abilities[1].anvil_drop_damage:
		_fail("forgeron : l'enclume tombe en %s (%d PV)" % [str(dropped["cell"]), context.enemy_health[0].current])
	# Le Bastion s'ouvre en gerbe, et rend une plaque.
	combat.health.plates = 3
	var opened := {"done": false}
	combat.bastion_opened.connect(func(_c: Vector2i, _r: float) -> void: opened["done"] = true)
	combat.use(form.abilities[2], context)
	for frame in 220:
		combat.update(0.02, context)
	if not bool(opened["done"]) or combat.plates_left() != 4:
		_fail("forgeron : le bastion ne s'ouvre pas (%d plaques)" % combat.plates_left())
	# La Charge du bélier laisse du métal en fusion.
	combat.use(form.escape, context)
	if combat._fire_cells.is_empty():
		_fail("forgeron : la charge ne laisse pas de métal en fusion")
	# Le Cœur de la forge : plaques pleines, et ses pas restent en fusion.
	combat._fire_cells.clear()
	combat.health.plates = 1
	combat.use(form.ultimate, context)
	combat.update(0.02, context)
	if combat.plates_left() != CombatSystem.FORGE_PLATES or not combat._fire_cells.has(context.player_cell):
		_fail("forgeron : le cœur de la forge laisse %d plaques" % combat.plates_left())
	print("forgeron céleste : forge vivante, éclats, marteau, tempête, enclume, bastion, bélier et cœur : OK")


## Le Gardien du Trône : l'œil qui brûle à deux cases, le couloir en feu, les quatre roues, les yeux des ailes,
## l'éclair à l'arrivée et l'épée qui tournoie sur le bord de l'Éden.
func _test_throne() -> void:
	var base := CharacterCatalog.cherubin()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Gardien du Trône":
		_fail("gardien : pas d'éveil pour le Chérubin")
		return
	var parts := _context(base)
	var awakening := Awakening.new(base, form, parts[1], parts[2])
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not (parts[1] as CombatSystem).throne_active():
		_fail("gardien : pas de regard du trône à l'éveil")
	awakening.finish()
	if (parts[1] as CombatSystem).throne_active():
		_fail("gardien : le regard survit à l'éveil")
	awakening.dispose()

	parts = _context(form)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	combat.free_use = true
	combat.start_throne()
	# Un œil brûle à deux cases, pour 35.
	var two := _cell_at(grid, context.player_field, 2)
	_add_enemy(context, two, 5000)
	combat._add_eye(0, context)
	combat.update(0.02, context)
	if context.enemy_health[0].current != 5000 - CombatSystem.THRONE_EYE_DAMAGE:
		_fail("gardien : l'œil à deux cases fait %d" % (5000 - context.enemy_health[0].current))
	# L'Épée flamboyante laisse le couloir en feu.
	combat.use(form.attack, context)
	for frame in 60:
		combat.update(0.02, context)
	if combat._fire_cells.is_empty():
		_fail("gardien : l'épée ne laisse pas le couloir en feu")
	combat._fire_cells.clear()
	# Les roues partent dans chaque direction ouverte.
	var open := 0
	for side: Vector2i in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(context.player_cell + side):
			open += 1
	var rolled := {"count": 0}
	combat.wave_launched.connect(func(_a: Ability, _p: Array, _d: float) -> void: rolled["count"] += 1)
	combat.use(form.abilities[1], context)
	if int(rolled["count"]) != open:
		_fail("gardien : %d roues pour %d couloirs" % [int(rolled["count"]), open])
	for frame in 100:
		combat.update(0.02, context)
	# Les Ailes du Trône : à la fin, un œil sur ce qui est proche.
	combat._eyes.clear()
	combat._eye_locks.clear()
	var eyed := {"done": false}
	combat.throne_eyes_opened.connect(func(_c: Vector2i, _r: float) -> void: eyed["done"] = true)
	combat.use(form.abilities[2], context)
	for frame in 160:
		combat.update(0.02, context)
	if not bool(eyed["done"]):
		_fail("gardien : les ailes ne s'ouvrent pas en yeux")
	# L'Aspect de l'éclair frappe à l'arrivée.
	context.enemy_cells.clear()
	context.enemy_health.clear()
	combat._eyes.clear()
	var fired := {"done": false}
	combat.blink_performed.connect(func(_f: Vector2i, _t: Vector2i) -> void: fired["done"] = true)
	combat.use(form.escape, context)
	if not bool(fired["done"]):
		_fail("gardien : l'éclair ne part pas")
	# L'Éden : l'épée du bord frappe ce qui est près d'elle.
	combat._garden = {}
	var cut := {"count": 0}
	combat.garden_sword_struck.connect(func(_c: Vector2i) -> void: cut["count"] += 1)
	var rim := context.player_cell + Vector2i(roundi(form.ultimate.radius), 0)
	_add_enemy(context, rim, 5000)
	combat.use(form.ultimate, context)
	for frame in 200:
		combat.update(0.02, context)
	if int(cut["count"]) < 1:
		_fail("gardien : l'épée du bord ne frappe pas")
	print("gardien du trône : regard, couloir en feu, quatre roues, yeux des ailes, éclair et épée du bord : OK")


## Le Séraphin : la marque du ciel, les deux lances, la pluie de plumes, la colonne qui reste, le carillon qui étourdit
## par-dessus les haies, les lances de l'Ascension et l'épée géante du Jugement dernier.
func _test_seraph() -> void:
	var base := CharacterCatalog.ciel()
	var form := CharacterCatalog.awakening_of(base.id)
	if form == null or form.display_name != "Séraphin":
		_fail("séraphin : pas d'éveil pour l'Archange du Ciel")
		return
	var parts := _context(base)
	var awakening := Awakening.new(base, form, parts[1], parts[2])
	awakening.begin(true)
	awakening.update(Awakening.CHARGE_TIME + 0.01)
	if not (parts[1] as CombatSystem).skies_active():
		_fail("séraphin : pas de ciel à l'éveil")
	awakening.finish()
	if (parts[1] as CombatSystem).skies_active():
		_fail("séraphin : le ciel survit à l'éveil")
	awakening.dispose()

	parts = _context(form)
	var grid: MazeGrid = parts[0]
	var combat: CombatSystem = parts[1]
	var context: CombatContext = parts[2]
	combat.free_use = true
	combat.start_skies()
	# Deux lances sur deux ennemis, et le second coup sur une cible marquée prend 20 % de plus.
	var near := _cell_at(grid, context.player_field, 2)
	var far := _cell_at(grid, context.player_field, 4)
	_add_enemy(context, near, 5000)
	_add_enemy(context, far, 5000)
	combat.use(form.attack, context)
	for frame in 30:
		combat.update(0.02, context)
	if context.enemy_health[0].current != 5000 - 18 or context.enemy_health[1].current != 5000 - 18:
		_fail("séraphin : les deux lances font %d et %d" % [5000 - context.enemy_health[0].current,
			5000 - context.enemy_health[1].current])
	combat._cooldowns.clear()
	combat.use(form.attack, context)
	for frame in 30:
		combat.update(0.02, context)
	if context.enemy_health[0].current != 5000 - 18 - 22:
		_fail("séraphin : la lance sur une cible marquée fait %d" % (5000 - 18 - context.enemy_health[0].current))
	# La Pluie de plumes : une plume par ennemi à portée.
	var feathers := {"count": 0}
	var counter := func(a: Ability, _t: int, _p: Array, _d: float) -> void:
		if a.projectile_visual == "plume_seraphin":
			feathers["count"] += 1
	combat.projectile_launched.connect(counter)
	combat.use(form.abilities[0], context)
	if int(feathers["count"]) != 2:
		_fail("séraphin : %d plumes pour deux ennemis" % int(feathers["count"]))
	combat.projectile_launched.disconnect(counter)
	for frame in 40:
		combat.update(0.02, context)
	# La Colonne du jugement reste allumée.
	var lingered := {"done": false}
	combat.column_lingered.connect(func(_c: Vector2i, _s: float, _r: float) -> void: lingered["done"] = true)
	combat.use(form.abilities[1], context)
	for frame in 50:
		combat.update(0.02, context)
	if not bool(lingered["done"]) or combat._columns.is_empty():
		_fail("séraphin : la colonne ne reste pas allumée")
	# Le Carillon sonne trois fois et étourdit.
	var stuns := {"count": 0}
	combat.enemy_staggered.connect(func(_i: int, _s: float) -> void: stuns["count"] += 1)
	var rings := {"count": 0}
	combat.toll_rang.connect(func(_c: Vector2i, _r: float) -> void: rings["count"] += 1)
	combat.use(form.abilities[2], context)
	for frame in 200:
		combat.update(0.02, context)
	if int(rings["count"]) != 3 or int(stuns["count"]) < 3:
		_fail("séraphin : le carillon sonne %d fois et étourdit %d fois" % [int(rings["count"]), int(stuns["count"])])
	# L'Ascension fait tomber des lances pendant le vol.
	var lances := {"count": 0}
	var lance_counter := func(a: Ability, _t: int, _p: Array, _d: float) -> void:
		if a.id == form.escape.id + "_lance":
			lances["count"] += 1
	combat.projectile_launched.connect(lance_counter)
	combat.use(form.escape, context)
	for frame in 260:
		combat.update(0.02, context)
	if int(lances["count"]) < 6:
		_fail("séraphin : %d lances pendant l'Ascension" % int(lances["count"]))
	# Le Jugement dernier finit par l'épée géante.
	var struck := {"done": false}
	combat.great_sword_struck.connect(func(_c: Vector2i, _r: float) -> void: struck["done"] = true)
	combat.use(form.ultimate, context)
	for frame in 400:
		combat.update(0.02, context)
	if not bool(struck["done"]):
		_fail("séraphin : l'épée géante ne tombe pas")
	print("séraphin : yeux du ciel, deux lances, plumes, colonne, carillon, ascension et épée géante : OK")
