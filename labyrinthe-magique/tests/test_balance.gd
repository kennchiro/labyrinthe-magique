extends SceneTree

## Simule des PARTIES COMPLÈTES en headless — déplacement, IA, portails, gemmes,
## potions, ET COMBAT — puis mesure le taux de réussite.
##   godot --headless --path . --script res://tests/test_balance.gd
##
## C'est un test d'équilibrage, pas de correction : il ne dit pas « le code
## marche », il dit « le jeu est jouable ».
##
## Il exécute les VRAIS systèmes (CombatSystem, TeleportSystem, EnemyAI,
## GridMover, Health) et non une arithmétique parallèle : une simulation qui
## réimplémente les règles finit toujours par mesurer un autre jeu que celui
## qu'on livre.
##
## Deux profils, parce qu'un seul ne suffit pas à juger :
##
##   EXPERT      — connaît le labyrinthe par cœur ET esquive. C'est le PLAFOND.
##                 S'il se fait rattraper souvent, le niveau est injuste.
##   EXPLORATEUR — découvre la carte, boussole en main : il sait dans quelle
##                 DIRECTION est la gemme la plus proche, jamais par où passer.
##                 C'est le taux qui compte vraiment.
##
## Les deux tirent dès qu'un ennemi entre à portée — c'est ce que fait un joueur —
## et lancent un sort quand ils sont serrés de près. Aucun ne fait de DÉTOUR pour
## aller chercher une potion : la mesure sous-estime donc la puissance des sorts,
## ce qui est le bon sens de l'erreur pour un équilibrage.

## 12 parties par configuration. C'est le test le plus lent de la suite, et de
## loin : chaque partie simule jusqu'à quatre minutes de jeu en recalculant deux
## champs de distances trois fois par seconde simulée, à la cadence du vrai jeu.
const ITERATIONS := 12
const DT := 1.0 / 60.0
const AI_REFRESH := 0.3
## La même distance que `Level.CATCH_DISTANCE`, avec le même refus du dernier pas.
## Avec un contact à 0,6 et des ennemis qui marchent sur le mage, la simulation
## faisait rater les coups croisés de face, que le jeu, lui, porte.
const CATCH_DISTANCE := 1.05
const PICKUP_DISTANCE := 0.7
const REFERENCE_SPEED := 5.0
const MAX_FRAMES := 240 * 60
## Répit après un coup encaissé — identique à GameManager.HIT_INVULNERABILITY.
const HIT_INVULNERABILITY := 2.2
## Distance de chemin à laquelle l'explorateur "aperçoit" son objectif.
const OBJECTIVE_SIGHT := 7
## À partir de quelle distance un ennemi devient dissuasif, et à quel point on
## préfère le détour au danger.
const DANGER_RADIUS := 4
const DANGER_WEIGHT := 5
const PANIC_RADIUS := 4
## Distance à laquelle un joueur simulé accepte de parier sur un portail.
const DESPERATION_RADIUS := 3
## Distance à laquelle il juge qu'un sort vaut mieux qu'une fuite.
const CAST_RADIUS := 6

var _failures: Array[String] = []
## Parties par profil. Réduit en passe rapide — voir `_init`.
var _runs := ITERATIONS


## Passe RAPIDE : un niveau sur quatre, un tiers des parties.
##
## ⚠️ ELLE NE REMPLACE PAS LA PASSE COMPLÈTE, et le dire n'est pas une clause de
## style. Ce test-ci est le seul qui juge l'équilibrage, et il n'a pas tourné
## une seule fois pendant que cinq sorts majeurs étaient réécrits — parce qu'il
## prend une demi-heure et que personne n'a une demi-heure au milieu d'une
## séance. Un test qu'on ne peut pas lancer est un test qu'on ne lance pas.
##
## La passe rapide existe pour qu'on le lance QUAND MÊME, et pour attraper la
## grosse dérive : un mage devenu injouable, un stage devenu impossible. Les
## écarts de quelques points, eux, demandent la passe complète.
const QUICK_ITERATIONS := 4
const QUICK_EVERY := 4


func _init() -> void:
	var quick := "--quick" in OS.get_cmdline_user_args()
	if quick:
		print("PASSE RAPIDE — un niveau sur %d, %d parties au lieu de %d." \
			% [QUICK_EVERY, QUICK_ITERATIONS, ITERATIONS])
		print("Elle attrape la grosse dérive, PAS les écarts de quelques points.")
		print("")
	_runs = QUICK_ITERATIONS if quick else ITERATIONS

	# `--mage ID` mesure ce mage-là sur tous les niveaux, à la place de l'étalon.
	var mage_arg := OS.get_cmdline_user_args().find("--mage")
	var reference := CharacterCatalog.by_id(OS.get_cmdline_user_args()[mage_arg + 1]) \
		if mage_arg >= 0 else CharacterCatalog.shadow()
	var levels := LevelConfig.all_levels()
	if quick:
		var sampled: Array[LevelConfig] = []
		for i in levels.size():
			if i % QUICK_EVERY == 0:
				sampled.append(levels[i])
		levels = sampled
	for config in levels:
		print("── %s   (%s)" % [config.level_name, reference.display_name])
		_run_profile(config, reference, false)
		_run_profile(config, reference, true)
		print("")

	# Les quatre autres mages sur le même stage : ce qu'on cherche ici n'est pas
	# l'égalité parfaite, c'est qu'aucun ne soit injouable.
	if not "--sans-viabilite" in OS.get_cmdline_user_args():
		print("── Viabilité des quinze mages (Stage 2, explorateur)")
		var stage := LevelConfig.for_stage(2)
		for character in CharacterCatalog.all():
			if character.id == reference.id:
				continue
			_run_profile(stage, character, true)
		print("")

	if _failures.is_empty():
		if _runs < ITERATIONS:
			print("✅  RIEN DE GROS N'A DÉRIVÉ — mais c'était la passe rapide.")
			print("    La passe complète reste à faire : sans --quick.")
		else:
			print("✅  ÉQUILIBRAGE DANS LES CLOUS")
	else:
		print("⚠️   %d ALERTE(S) D'ÉQUILIBRAGE :" % _failures.size())
		for f in _failures:
			print("   - ", f)
	quit(0 if _failures.is_empty() else 1)


func _run_profile(config: LevelConfig, character: CharacterStats, explorer: bool) -> void:
	var label := "EXPLORATEUR" if explorer else "EXPERT     "
	# Les niveaux où il faut ABATTRE les repaires ne se jugent PAS DU TOUT ici :
	# le bot ne sait pas démolir une maison, donc il ne finit jamais. Ni sa
	# victoire ni sa mortalité ne veulent alors rien dire — il erre jusqu'au
	# plafond de quatre minutes et son exposition n'est plus celle d'une partie,
	# c'est celle d'une partie sans fin. On affiche, on ne juge pas.
	var winnable := not config.must_destroy_lairs
	var wins := 0
	var caught := 0
	var timeouts := 0
	var frames_total := 0
	var gems_total := 0
	var kills_total := 0
	var portals_total := 0

	for i in _runs:
		var outcome := _simulate(config, character, 4000 + i, explorer)
		gems_total += int(outcome["gems"])
		kills_total += int(outcome["kills"])
		portals_total += int(outcome["portals"])
		match outcome["result"]:
			"win":
				wins += 1
				frames_total += int(outcome["frames"])
			"caught":
				caught += 1
			_:
				timeouts += 1

	var rate := float(wins) / float(_runs) * 100.0
	var caught_rate := float(caught) / float(_runs) * 100.0
	var mean_time := (float(frames_total) / float(maxi(wins, 1))) * DT
	print("   %-11s %-14s : %3d%% de victoires · %3d%% mort · %d bloqué · %3.0f s · %.1f gemmes · %.1f kills · %.1f portails%s" % [
		label, character.display_name, int(round(rate)), int(round(caught_rate)), timeouts,
		mean_time, float(gems_total) / float(_runs),
		float(kills_total) / float(_runs), float(portals_total) / float(_runs),
		"" if winnable else "   [repaires à abattre — chiffres non comparables]"])

	# LE CRITÈRE PORTE SUR LA MORT, PAS SUR LA VICTOIRE.
	#
	# Une partie "bloqué" est une partie où l'agent simulé s'est perdu ou oscille
	# devant un ennemi qui campe son chemin, jusqu'au plafond de quatre minutes.
	# C'est une limite de la navigation gloutonne — un humain contourne large,
	# passe en force, ou se souvient d'où il vient. Compter ces parties comme des
	# défaites ferait condamner un niveau parfaitement jouable dès qu'il devient
	# grand. On les affiche, on ne les juge pas.
	#
	# Le taux de MORT, lui, ne dépend pas de l'intelligence de l'agent : il dit
	# si les poursuivants sont trop rapides, trop nombreux ou trop coriaces.
	if not explorer and caught_rate > 15.0:
		_failures.append("%s / %s : l'EXPERT meurt %d%% du temps — niveau injuste" % [
			config.level_name, character.display_name, int(caught_rate)])
	if explorer and winnable and caught_rate > 60.0:
		_failures.append("%s / %s : l'EXPLORATEUR meurt %d%% du temps — trop punitif" % [
			config.level_name, character.display_name, int(caught_rate)])
	# Et un explorateur qui ne meurt JAMAIS sur un stage AVANCÉ, c'est un jeu
	# sans enjeu : la poursuite doit rester une menace réelle. Le stage
	# d'apprentissage échappe à cette règle — il est fait pour être franchi.
	# ⚠️ UN PROFIL QUI NE FINIT JAMAIS NE MESURE RIEN, et c'est le trou de ce
	# test : ses trois seuils portent sur le taux de MORT et sur le taux de
	# VICTOIRE. Quand l'explorateur se fait bloquer douze fois sur douze, il ne
	# meurt pas — non parce que le jeu est doux, mais parce qu'il erre jusqu'au
	# plafond de quatre minutes sans jamais approcher la maison. Ses 0 % de
	# morts rassurent sur une partie qui n'a pas eu lieu.
	#
	# Ce n'est pas une ALERTE — le bot a toujours été maladroit, et faire rougir
	# la suite noierait les vraies régressions. C'est un AVIS : il dit quelles
	# lignes du rapport ne veulent rien dire.
	if explorer and winnable and timeouts * 4 >= _runs * 3:
		print("      ↑ l'explorateur n'a rien fini ici (%d/%d bloqués) : ses chiffres "
			% [timeouts, _runs] + "ne disent rien du niveau")
	if explorer and not config.is_tutorial and caught_rate < 5.0 and rate > 80.0:
		_failures.append("%s / %s : l'EXPLORATEUR gagne %d%% sans jamais mourir — aucune tension" % [
			config.level_name, character.display_name, int(rate)])


func _simulate(config: LevelConfig, character: CharacterStats, rng_seed: int, explorer: bool) -> Dictionary:
	var grid := MazeGenerator.generate(config, rng_seed)
	var player := GridMover.new(grid, grid.player_spawn, character.move_speed)
	var player_health := Health.new(character.base_health + config.player_health_bonus)
	var combat := CombatSystem.new(grid, character, player_health, rng_seed * 31 + 7)
	var context := CombatContext.new(grid)
	var kills := KillSystem.new(character.ultimate_required_kills)
	var teleports := TeleportSystem.new(grid, rng_seed + 7)

	var movers: Array[GridMover] = []
	var brains: Array[EnemyAI] = []
	var swings: Array[MeleeSwing] = []
	# LES ENNEMIS QUI LANCENT. Le système est le MÊME objet que celui du jeu :
	# la simulation ne réimplémente pas la règle, elle l'exécute. Sans lui, elle
	# mesurerait un jeu où le Golem de Lave ne jette jamais — et rendrait un
	# verdict rassurant sur une menace qu'elle n'a pas vue.
	var throws := ThrowSystem.new(grid)
	# Vitesse PAR ESPÈCE, comme le Level : un golem traîne, un serpent file.
	# La version à vitesse unique mesurait un autre jeu que celui qu'on joue.
	var base_speeds: Array[float] = []
	var slots := config.slot_species(grid.enemy_spawns.size())
	for i in slots.size():
		var spawn := grid.enemy_spawns[i % grid.enemy_spawns.size()]
		var enemy_speed := REFERENCE_SPEED * config.enemy_speed(slots[i])
		base_speeds.append(enemy_speed)
		movers.append(GridMover.new(grid, spawn, enemy_speed))
		movers[i].phases = bool(Bestiary.of(slots[i]).get("phases", false))
		brains.append(EnemyAI.new(config.enemy_detection_radius, rng_seed * 31 + i + 1))
		swings.append(MeleeSwing.new())
		context.enemy_cells.append(spawn)
		context.enemy_health.append(Health.new(config.enemy_health(slots[i])))
		# Les petites gelées attendent hors jeu, sans réapparition.
		if Bestiary.is_droplet(slots[i]):
			context.enemy_health[i].current = 0

	# Les gemmes des rats, les nuages de la Vesse : les mêmes règles qu'en jeu.
	var carried := {}
	var acting := {}
	var spit_cooldowns := {}
	var spores := SporeClouds.new()
	var thief_field := PackedInt32Array()
	var gem_fields := {}
	var remaining := grid.gems.duplicate()
	var dirty := {"objective": false}

	var respawns := {}
	# Les traits élémentaires qui touchent au MOUVEMENT : la simulation les
	# applique comme le Level, sinon la trempe, l'ébranlement et la bourrasque
	# n'existeraient que pour le joueur humain et l'équilibrage mentirait.
	var soaked := {}
	var soak_factors := {}
	var staggered := {}
	# Le facteur est mémorisé avec la durée : la simulation ralentit exactement
	# comme le jeu, y compris pour le givre du Cercle glacé.
	combat.enemy_soaked.connect(func(index: int, duration: float, factor: float) -> void:
		soaked[index] = duration
		soak_factors[index] = factor)
	combat.enemy_blinded.connect(func(index: int, duration: float) -> void:
		brains[index].blind_left = duration
		swings[index].cancel())
	combat.enemy_possessed.connect(func(index: int, duration: float) -> void:
		brains[index].possess(duration)
		swings[index].cancel())
	combat.possession_field.connect(func(field: PackedInt32Array) -> void:
		for brain in brains:
			brain.possess_field = field)
	combat.enemy_swapped.connect(func(index: int, cell: Vector2i) -> void:
		if index < movers.size():
			movers[index].teleport_to(cell))
	combat.enemy_staggered.connect(func(index: int, duration: float) -> void:
		staggered[index] = duration)
	combat.enemy_pushed.connect(func(index: int, cell: Vector2i) -> void:
		if index < movers.size():
			movers[index].teleport_to(cell))
	combat.enemy_killed.connect(func(index: int) -> void:
		swings[index].cancel()
		if carried.has(index):
			carried.erase(index)
			var dropped := movers[index].nearest_cell()
			remaining.append(dropped)
			if not gem_fields.has(dropped):
				gem_fields[dropped] = Pathfinder.distance_field(grid, [dropped] as Array[Vector2i])
			dirty["objective"] = true
		if Bestiary.is_droplet(slots[index]):
			kills.register_kill()
			return
		# Une gelée qui se scinde ne compte pas : ses petites compteront. Mêmes règles que
		# `Level._split`, sinon la simulation donnerait trois kills par gelée.
		var tuning := Bestiary.of(slots[index])
		var waiting: Array[int] = []
		for other in slots.size():
			if slots[other] == str(tuning.get("splits_into", "")) \
					and waiting.size() < int(tuning.get("splits_count", 0)) \
					and not context.enemy_health[other].is_alive():
				waiting.append(other)
		if waiting.is_empty():
			kills.register_kill()
		else:
			var cells := CreatureRules.split_cells(grid, movers[index].nearest_cell(),
				player.nearest_cell(), waiting.size())
			for i in cells.size():
				movers[waiting[i]].teleport_to(cells[i])
				context.enemy_health[waiting[i]].current = context.enemy_health[waiting[i]].maximum
				brains[waiting[i]].state = EnemyAI.State.PATROL
				swings[waiting[i]].cancel()
		# Le délai de réapparition INCLUT l'ouverture de la maison : dans le jeu
		# la porte s'anime une seconde avant de lâcher la créature, et cette
		# seconde-là est du répit pour le joueur. L'oublier mesurait un jeu plus
		# dur que celui qu'on joue.
		respawns[index] = config.enemy_respawn_delay + config.lair_opening_delay)

	# Départ ÉCHELONNÉ, comme dans le Level : les ennemis naissent tous sur les
	# deux cases de repaire, et les surnuméraires y attendent leur tour. Sans
	# ça, la simulation lâchait sept poursuivants d'un bloc sur deux cases —
	# une meute que le jeu ne produit jamais.
	var lair_count := maxi(1, grid.lairs.size())
	if not grid.lairs.is_empty():
		for i in range(lair_count, grid.enemy_spawns.size()):
			# À zéro PV, l'ennemi est HORS JEU pour tout le reste de la boucle :
			# il ne menace pas, il n'est pas ciblable, et sa réapparition le
			# remet à plein. C'est exactement l'état « encore dans la maison ».
			context.enemy_health[i].current = 0
			respawns[i] = float(i - lair_count + 1) * config.initial_release_step

	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed

	for gem in grid.gems:
		gem_fields[gem] = Pathfinder.distance_field(grid, [gem] as Array[Vector2i])
	var house_field := Pathfinder.distance_field(grid, [grid.house_center] as Array[Vector2i])
	var potions := grid.potions.duplicate()
	var potion_timer := 0.0

	var visits := {}
	var portal_uses := 0
	var player_field := PackedInt32Array()
	var enemy_field := PackedInt32Array()
	var objective_field: PackedInt32Array = _objective_field(grid, gem_fields, house_field, remaining, player.cell)
	var ai_timer := 0.0

	for frame in MAX_FRAMES:
		# --- Réapparitions (mêmes règles que le Level) ---------------------------
		for index in respawns.keys():
			var left: float = respawns[index] - DT
			if left > 0.0:
				respawns[index] = left
				continue
			respawns.erase(index)
			# La créature sort de la maison la plus ÉLOIGNÉE du mage — la même
			# règle que le Level, par la même fonction. Sans repaire (aucun
			# labyrinthe n'en manque aujourd'hui, mais le repli existe), on
			# retombe sur l'ancienne apparition au hasard.
			var spot := grid.enemy_spawns[index]
			if not grid.lairs.is_empty():
				spot = MazeGenerator.farthest_lair(grid, player_field, spot)
			else:
				spot = MazeGenerator.pick_enemy_respawn(grid, rng, player_field,
					config.enemy_detection_radius * 2, grid.enemy_spawns[index])
			movers[index].teleport_to(spot)
			context.enemy_health[index].current = context.enemy_health[index].maximum
			brains[index].state = EnemyAI.State.PATROL
			swings[index].cancel()

		if ai_timer <= 0.0:
			ai_timer = AI_REFRESH
			player_field = Pathfinder.distance_field(grid, [player.cell] as Array[Vector2i])
			# Un ennemi mort ne menace plus : il ne compte pas dans le champ de
			# danger que consultent les profils simulés.
			var threats: Array[Vector2i] = []
			for i in movers.size():
				# Un Rat ne frappe pas : le bot ne le fuit pas, il le chasse.
				if context.enemy_health[i].is_alive() \
						and not bool(Bestiary.of(slots[i]).get("thief", false)):
					threats.append(CreatureRules.anchor_cell(grid, movers[i].cell, player.cell))
			enemy_field = Pathfinder.distance_field(grid, threats)
			thief_field = CreatureRules.stealable_field(grid, remaining, player_field)
			# Une gemme volée se poursuit : le bot vise aussi ses voleurs.
			if not carried.is_empty():
				var targets: Array[Vector2i] = remaining.duplicate()
				for index in carried:
					targets.append(movers[index].nearest_cell())
				objective_field = Pathfinder.distance_field(grid, targets)
		ai_timer -= DT

		# --- État du monde vu par le combat --------------------------------------
		context.player_cell = player.nearest_cell()
		context.player_facing = player.direction if player.direction != Vector2i.ZERO else Vector2i.DOWN
		context.player_field = player_field
		for i in movers.size():
			context.enemy_cells[i] = CreatureRules.anchor_cell(grid, movers[i].cell, player.cell)

		if bool(dirty["objective"]):
			dirty["objective"] = false
			objective_field = _objective_field(grid, gem_fields, house_field, remaining, player.cell)

		teleports.update(DT)
		combat.update(DT, context)

		# Les ennemis vivants empruntent les portails (appel identique à Level).
		for i in movers.size():
			if not context.enemy_health[i].is_alive() \
					or bool(Bestiary.of(slots[i]).get("no_portals", false)):
				continue
			if teleports.is_on_portal(movers[i]):
				teleports.try_teleport_enemy(movers[i], player_field)

		var threat_here := Pathfinder.value_at(grid, enemy_field, player.decision_cell())

		# --- Décisions de combat --------------------------------------------------
		# On tire dès qu'une cible est à portée : c'est ce que fait un joueur, et
		# l'attaque de base ne coûte rien.
		if combat.find_target(character.attack, context) >= 0:
			combat.use(character.attack, context)
		# Serré de près : l'ultime d'abord s'il est chargé, sinon un sort.
		if threat_here >= 0 and threat_here <= CAST_RADIUS:
			if kills.available() and combat.use(character.ultimate, context):
				kills.spend()
			else:
				_use_best_ability(combat, character, context, player_health)

		# Acculé : le portail plutôt que la mort.
		if threat_here >= 0 and threat_here <= DESPERATION_RADIUS and teleports.can_teleport(player):
			if teleports.try_teleport_player(player, _living_cells(movers, context), objective_field):
				portal_uses += 1
				continue

		# --- Déplacement -----------------------------------------------------------
		if explorer:
			player.desired_direction = _explore(grid, player, objective_field, enemy_field,
				_hunted_cell(grid, remaining, carried, movers), visits, rng)
		else:
			player.desired_direction = _expert(grid, player.decision_cell(), objective_field, enemy_field)
		player.speed = 0.0 if combat.player_rooted() else character.move_speed * spores.speed_factor(player.nearest_cell())
		player.update(DT)
		if combat.time_stop_left() <= 0.0:
			spores.advance(DT)

		# --- Ramassage --------------------------------------------------------------
		var position := player.grid_position()
		var picked := false
		for i in range(remaining.size() - 1, -1, -1):
			if Vector2(remaining[i]).distance_to(position) < PICKUP_DISTANCE:
				remaining.remove_at(i)
				picked = true
		if picked:
			objective_field = _objective_field(grid, gem_fields, house_field, remaining, player.cell)
		for i in range(potions.size() - 1, -1, -1):
			if Vector2(potions[i]).distance_to(position) < PICKUP_DISTANCE:
				potions.remove_at(i)
				kills.drink_potion()
				potion_timer = Level.POTION_RESPAWN_DELAY
		if config.potion_count > 0 and potions.size() < config.potion_count and potion_timer > 0.0:
			potion_timer -= DT
			if potion_timer <= 0.0:
				var cell := MazeGenerator.pick_potion_cell(grid, rng, player.cell, 8)
				if cell.x >= 0:
					potions.append(cell)

		# Victoire : toutes les gemmes ET la maison, comme dans le GameManager.
		if remaining.is_empty() and carried.is_empty() and grid.is_house(player.cell):
			return _outcome("win", frame, grid.gems.size(), kills.kills, portal_uses)

		# --- Ennemis -----------------------------------------------------------------
		var sheltered := teleports.is_invulnerable(player)
		for i in movers.size():
			if not context.enemy_health[i].is_alive():
				continue
			if staggered.has(i):
				# Un ennemi ébranlé ne bouge NI ne frappe : c'est tout l'achat.
				staggered[i] = float(staggered[i]) - DT
				if float(staggered[i]) <= 0.0:
					staggered.erase(i)
				swings[i].cancel()
				continue
			var mover: GridMover = movers[i]
			var species_tuning := Bestiary.of(slots[i])
			mover.speed = base_speeds[i]
			if soaked.has(i):
				soaked[i] = float(soaked[i]) - DT
				if float(soaked[i]) <= 0.0:
					soaked.erase(i)
				else:
					mover.speed = base_speeds[i] * float(
						soak_factors.get(i, CombatSystem.SOAK_FACTOR))
			acting[i] = maxf(0.0, float(acting.get(i, 0.0)) - DT)
			spit_cooldowns[i] = maxf(0.0, float(spit_cooldowns.get(i, 0.0)) - DT)
			var from := mover.decision_cell()
			var is_thief := bool(species_tuning.get("thief", false))
			var spit_reach := int(species_tuning.get("spit_reach", 0))
			if is_thief:
				mover.desired_direction = brains[i].decide_thief(grid, from, mover.direction,
					thief_field, player_field, carried.has(i), DT)
			elif bool(species_tuning.get("phases", false)):
				mover.desired_direction = brains[i].decide_phasing(grid, from, mover.direction,
					player_field, player.nearest_cell(), float(species_tuning["phase_reach"]), DT)
			else:
				mover.desired_direction = brains[i].decide(grid, from, mover.direction, player_field, DT)
			if from + mover.desired_direction == player.nearest_cell():
				mover.desired_direction = Vector2i.ZERO
			if float(acting[i]) > 0.0:
				mover.desired_direction = Vector2i.ZERO
			if spit_reach > 0 and CreatureRules.in_spit_reach(grid, player_field, from, spit_reach):
				mover.desired_direction = Vector2i.ZERO
				if float(acting[i]) <= 0.0 and float(spit_cooldowns[i]) <= 0.0 \
						and brains[i].blind_left <= 0.0 and combat.time_stop_left() <= 0.0:
					acting[i] = float(species_tuning["strike"])
					spit_cooldowns[i] = float(species_tuning["spit_reload"])
					spores.spit(CreatureRules.spit_cells(grid, mover.nearest_cell(), player_field),
						Bestiary.windup(slots[i]))
			var ranged_only := bool(species_tuning.get("ranged_only", false))
			if ranged_only and ThrowSystem.in_line(grid, mover.decision_cell(),
					player.nearest_cell(), int(species_tuning["throw_range"])):
				mover.desired_direction = Vector2i.ZERO
			mover.update(DT)
			# Le larcin, au passage sur la gemme.
			if is_thief and not carried.has(i) and brains[i].blind_left <= 0.0:
				var at := mover.nearest_cell()
				if remaining.has(at) and CreatureRules.may_steal(grid, player_field, at):
					remaining.erase(at)
					carried[i] = true
					acting[i] = float(species_tuning["strike"])
					dirty["objective"] = true
			# Aveuglé, il erre mais ne frappe pas, comme en jeu.
			if ranged_only or bool(species_tuning.get("harmless", false)) \
					or brains[i].blind_left > 0.0:
				continue
			# Le même coup qu'en jeu : armé au contact, porté à l'impact.
			var swing_event: MeleeSwing.Event = swings[i].tick(DT,
				mover.grid_position().distance_to(position), CATCH_DISTANCE,
				Bestiary.windup(slots[i]),
				ThrowSystem.reload_of(species_tuning))
			if swing_event != MeleeSwing.Event.LANDED or sheltered:
				continue
			player_health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
			if not player_health.is_alive():
				return _outcome("caught", frame, grid.gems.size() - remaining.size(),
					kills.kills, portal_uses)
			teleports.grant_invulnerability(player, HIT_INVULNERABILITY)
			sheltered = true
		# LES JETS, une fois les ennemis déplacés : ils visent où le mage EST à
		# la fin du tour, comme en jeu.
		var shooters: Array = []
		for i in movers.size():
			var reach := int(Bestiary.of(slots[i]).get("throw_range", 0))
			if reach <= 0 or not context.enemy_health[i].is_alive() or brains[i].blind_left > 0.0:
				shooters.append({"cell": Vector2i.ZERO, "range": 0})
				continue
			var tuning := Bestiary.of(slots[i])
			shooters.append({"cell": movers[i].nearest_cell(), "range": reach,
				"reload": ThrowSystem.reload_of(tuning),
				"sweep": bool(tuning.get("sweep", false))})
		if combat.time_stop_left() <= 0.0:
			throws.aim(DT, shooters, player.nearest_cell())
		for cell in throws.advance(DT, combat):
			if sheltered or not ThrowSystem.touches(cell, player.grid_position()):
				continue
			player_health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
			if not player_health.is_alive():
				return _outcome("caught", frame, grid.gems.size() - remaining.size(),
					kills.kills, portal_uses)
			teleports.grant_invulnerability(player, HIT_INVULNERABILITY)
			sheltered = true

	return _outcome("timeout", MAX_FRAMES, grid.gems.size() - remaining.size(),
		kills.kills, portal_uses)


## Choisit la compétence à lancer, au lieu de prendre systématiquement la
## première de la liste.
##
## Ce détail invalidait des mesures entières : le Mage de l'Eau a `water_wave`
## en premier, le bot la lançait toujours et n'a JAMAIS utilisé son bouclier de
## toute la campagne. On a donc « mesuré » l'effet d'une baisse du bouclier qui
## ne pouvait rien changer — les chiffres sont revenus rigoureusement
## identiques. Un instrument qui n'observe pas ce qu'on croit qu'il observe est
## pire qu'aucun instrument.
##
## L'ordre de préférence reproduit ce que fait un joueur : se protéger quand on
## est bas, sinon frapper le plus fort possible.
func _use_best_ability(combat: CombatSystem, character: CharacterStats,
		context: CombatContext, health: Health) -> void:
	var hurt := health.ratio() <= 0.5
	var defensive: Array[Ability] = []
	var offensive: Array[Ability] = []
	for slot in range(1, character.abilities.size() + 1):
		var ability: Ability = character.abilities[slot - 1]
		if not combat.can_use(ability):
			continue
		# Un joueur ne signe pas son pacte quand il lui reste à peine de quoi vivre.
		if ability.self_cost > 0 and hurt:
			continue
		if ability.kind in [Ability.Kind.SHIELD, Ability.Kind.HEAL, Ability.Kind.HOURGLASS,
				Ability.Kind.TRANSFUSION]:
			defensive.append(ability)
		else:
			offensive.append(ability)

	if hurt:
		for ability in defensive:
			if combat.use(ability, context):
				return
	# Sinon le sort le plus lourd : c'est ce que choisit un joueur qui veut se
	# débarrasser d'un poursuivant, pas celui qui veut faire durer.
	offensive.sort_custom(func(a: Ability, b: Ability) -> bool: return a.damage > b.damage)
	for ability in offensive:
		if combat.use(ability, context):
			return
	for ability in defensive:
		if combat.use(ability, context):
			return


func _outcome(result: String, frames: int, gems: int, kills: int, portals: int) -> Dictionary:
	return {"result": result, "frames": frames, "gems": gems, "kills": kills, "portals": portals}


func _living_cells(movers: Array[GridMover], context: CombatContext) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for i in movers.size():
		if context.enemy_health[i].is_alive():
			cells.append(movers[i].cell)
	return cells


## Champ vers la gemme la plus proche, ou vers la maison quand il n'en reste
## aucune — le même choix que la boussole du jeu.
func _objective_field(grid: MazeGrid, gem_fields: Dictionary, house_field: PackedInt32Array,
		remaining: Array[Vector2i], from: Vector2i) -> PackedInt32Array:
	if remaining.is_empty():
		return house_field
	var best: PackedInt32Array = gem_fields[remaining[0]]
	var best_distance := 1 << 30
	for gem in remaining:
		var field: PackedInt32Array = gem_fields[gem]
		var distance := Pathfinder.value_at(grid, field, from)
		if distance >= 0 and distance < best_distance:
			best_distance = distance
			best = field
	return best


## Ce que la boussole montre : la gemme, sinon celle qu'un rat emporte, sinon la maison.
func _hunted_cell(grid: MazeGrid, remaining: Array[Vector2i], carried: Dictionary,
		movers: Array[GridMover]) -> Vector2i:
	if not remaining.is_empty():
		return remaining[0]
	for index in carried:
		return movers[index].nearest_cell()
	return grid.house_center


## Joueur expert : descend vers son objectif, mais paie un lourd surcoût pour
## toute case proche d'un ennemi. Le détour l'emporte tant qu'il coûte moins
## cher que le danger — exactement l'arbitrage que fait un joueur humain.
func _expert(grid: MazeGrid, from: Vector2i, objective_field: PackedInt32Array,
		enemy_field: PackedInt32Array) -> Vector2i:
	var best_direction := Vector2i.ZERO
	var best_score := _threat_score(grid, from, objective_field, enemy_field)
	for d in MazeGrid.NEIGHBORS:
		var neighbour: Vector2i = from + d
		if not grid.is_floor_v(neighbour):
			continue
		var score := _threat_score(grid, neighbour, objective_field, enemy_field)
		if score < best_score:
			best_score = score
			best_direction = d
	return best_direction


func _threat_score(grid: MazeGrid, cell: Vector2i, objective_field: PackedInt32Array,
		enemy_field: PackedInt32Array) -> int:
	var score := Pathfinder.value_at(grid, objective_field, cell)
	if score < 0:
		return 1 << 20
	var enemy_distance := Pathfinder.value_at(grid, enemy_field, cell)
	if enemy_distance >= 0 and enemy_distance < DANGER_RADIUS:
		score += (DANGER_RADIUS - enemy_distance) * DANGER_WEIGHT
	return score


## Joueur qui découvre, boussole en main : il explore vers le moins connu, mais
## départage les couloirs à égalité par la DIRECTION de son objectif — ce que lui
## donne la flèche du jeu. Il fonce dès qu'il l'a en vue.
func _explore(grid: MazeGrid, player: GridMover, objective_field: PackedInt32Array,
		enemy_field: PackedInt32Array, objective: Vector2i,
		visits: Dictionary, rng: RandomNumberGenerator) -> Vector2i:
	var from := player.decision_cell()
	if Pathfinder.value_at(grid, objective_field, from) <= OBJECTIVE_SIGHT:
		return Pathfinder.step_toward(grid, objective_field, from)

	var threat := Pathfinder.value_at(grid, enemy_field, from)
	if threat >= 0 and threat <= PANIC_RADIUS:
		var flee_direction := Vector2i.ZERO
		var furthest := threat
		for d in MazeGrid.NEIGHBORS:
			var neighbour: Vector2i = from + d
			if not grid.is_floor_v(neighbour):
				continue
			var gap := Pathfinder.value_at(grid, enemy_field, neighbour)
			if gap > furthest:
				furthest = gap
				flee_direction = d
		if flee_direction != Vector2i.ZERO:
			return flee_direction

	visits[from] = int(visits.get(from, 0)) + 1
	var best_visits := 1 << 30
	var best_bearing := INF
	var options: Array[Vector2i] = []
	for d in MazeGrid.NEIGHBORS:
		if d == -player.direction:
			continue
		var neighbour: Vector2i = from + d
		if not grid.is_floor_v(neighbour):
			continue
		var seen := int(visits.get(neighbour, 0))
		# Distance à VOL D'OISEAU, comme la boussole : elle indique la direction,
		# jamais le chemin. C'est toute la différence avec l'expert.
		var bearing := Vector2(neighbour).distance_to(Vector2(objective))
		if seen < best_visits or (seen == best_visits and bearing < best_bearing - 0.01):
			best_visits = seen
			best_bearing = bearing
			options = [d]
		elif seen == best_visits and absf(bearing - best_bearing) <= 0.01:
			options.append(d)

	if options.is_empty():
		return -player.direction
	return options[rng.randi_range(0, options.size() - 1)]
