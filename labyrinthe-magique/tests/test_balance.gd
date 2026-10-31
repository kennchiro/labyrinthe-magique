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
const CATCH_DISTANCE := 0.6
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

	var reference := CharacterCatalog.shadow()
	var levels := LevelConfig.all_levels()
	if quick:
		var sampled: Array = []
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
	print("── Viabilité des sept mages (Stage 2, explorateur)")
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

	var rate := float(wins) / float(ITERATIONS) * 100.0
	var caught_rate := float(caught) / float(ITERATIONS) * 100.0
	var mean_time := (float(frames_total) / float(maxi(wins, 1))) * DT
	print("   %-11s %-14s : %3d%% de victoires · %3d%% mort · %d bloqué · %3.0f s · %.1f gemmes · %.1f kills · %.1f portails%s" % [
		label, character.display_name, int(round(rate)), int(round(caught_rate)), timeouts,
		mean_time, float(gems_total) / float(ITERATIONS),
		float(kills_total) / float(ITERATIONS), float(portals_total) / float(ITERATIONS),
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
	# Progression FICTIVE : le bot commence sans sort et les débloque en
	# ramassant les potions, exactement comme un joueur. La sauvegarde du vrai
	# joueur n'est jamais touchée.
	var progress := Progress.new()
	var teleports := TeleportSystem.new(grid, rng_seed + 7)

	var movers: Array[GridMover] = []
	var brains: Array[EnemyAI] = []
	# LES ENNEMIS QUI LANCENT. Le système est le MÊME objet que celui du jeu :
	# la simulation ne réimplémente pas la règle, elle l'exécute. Sans lui, elle
	# mesurerait un jeu où le Golem de Lave ne jette jamais — et rendrait un
	# verdict rassurant sur une menace qu'elle n'a pas vue.
	var throws := ThrowSystem.new(grid)
	# Vitesse PAR ESPÈCE, comme le Level : un golem traîne, un serpent file.
	# La version à vitesse unique mesurait un autre jeu que celui qu'on joue.
	var base_speeds: Array[float] = []
	for i in grid.enemy_spawns.size():
		var enemy_speed := REFERENCE_SPEED * config.enemy_speed(config.species_at(i))
		base_speeds.append(enemy_speed)
		movers.append(GridMover.new(grid, grid.enemy_spawns[i], enemy_speed))
		brains.append(EnemyAI.new(config.enemy_detection_radius, rng_seed * 31 + i + 1))
		context.enemy_cells.append(grid.enemy_spawns[i])
		context.enemy_health.append(Health.new(config.enemy_health(config.species_at(i))))

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
	combat.enemy_staggered.connect(func(index: int, duration: float) -> void:
		staggered[index] = duration)
	combat.enemy_pushed.connect(func(index: int, cell: Vector2i) -> void:
		if index < movers.size():
			movers[index].teleport_to(cell))
	combat.enemy_killed.connect(func(index: int) -> void:
		kills.register_kill()
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
		for i in range(lair_count, movers.size()):
			# À zéro PV, l'ennemi est HORS JEU pour tout le reste de la boucle :
			# il ne menace pas, il n'est pas ciblable, et sa réapparition le
			# remet à plein. C'est exactement l'état « encore dans la maison ».
			context.enemy_health[i].current = 0
			respawns[i] = float(i - lair_count + 1) * config.initial_release_step

	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed

	var gem_fields := {}
	for gem in grid.gems:
		gem_fields[gem] = Pathfinder.distance_field(grid, [gem] as Array[Vector2i])
	var house_field := Pathfinder.distance_field(grid, [grid.house_center] as Array[Vector2i])
	var remaining := grid.gems.duplicate()
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

		if ai_timer <= 0.0:
			ai_timer = AI_REFRESH
			player_field = Pathfinder.distance_field(grid, [player.cell] as Array[Vector2i])
			# Un ennemi mort ne menace plus : il ne compte pas dans le champ de
			# danger que consultent les profils simulés.
			var threats: Array[Vector2i] = []
			for i in movers.size():
				if context.enemy_health[i].is_alive():
					threats.append(movers[i].cell)
			enemy_field = Pathfinder.distance_field(grid, threats)
		ai_timer -= DT

		# --- État du monde vu par le combat --------------------------------------
		context.player_cell = player.nearest_cell()
		context.player_facing = player.direction if player.direction != Vector2i.ZERO else Vector2i.DOWN
		context.player_field = player_field
		for i in movers.size():
			context.enemy_cells[i] = movers[i].cell

		teleports.update(DT)
		combat.update(DT, context)

		# Les ennemis vivants empruntent les portails (appel identique à Level).
		for i in movers.size():
			if not context.enemy_health[i].is_alive():
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
				_use_best_ability(combat, character, context, player_health, progress)

		# Acculé : le portail plutôt que la mort.
		if threat_here >= 0 and threat_here <= DESPERATION_RADIUS and teleports.can_teleport(player):
			if teleports.try_teleport_player(player, _living_cells(movers, context), objective_field):
				portal_uses += 1
				continue

		# --- Déplacement -----------------------------------------------------------
		if explorer:
			player.desired_direction = _explore(grid, player, objective_field, enemy_field,
				_objective_cell(grid, remaining), visits, rng)
		else:
			player.desired_direction = _expert(grid, player.decision_cell(), objective_field, enemy_field)
		player.update(DT)

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
				progress.unlock_next_skill()
				potion_timer = Level.POTION_RESPAWN_DELAY
		if config.potion_count > 0 and potions.size() < config.potion_count and potion_timer > 0.0:
			potion_timer -= DT
			if potion_timer <= 0.0:
				var cell := MazeGenerator.pick_potion_cell(grid, rng, player.cell, 8)
				if cell.x >= 0:
					potions.append(cell)

		# Victoire : toutes les gemmes ET la maison, comme dans le GameManager.
		if remaining.is_empty() and grid.is_house(player.cell):
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
				continue
			var mover: GridMover = movers[i]
			mover.speed = base_speeds[i]
			if soaked.has(i):
				soaked[i] = float(soaked[i]) - DT
				if float(soaked[i]) <= 0.0:
					soaked.erase(i)
				else:
					mover.speed = base_speeds[i] * float(
						soak_factors.get(i, CombatSystem.SOAK_FACTOR))
			mover.desired_direction = brains[i].decide(grid, mover.decision_cell(), mover.direction, player_field, DT)
			mover.update(DT)
			if mover.grid_position().distance_to(position) >= CATCH_DISTANCE or sheltered:
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
			var reach := int(Bestiary.of(config.species_at(i)).get("throw_range", 0))
			if reach <= 0 or not context.enemy_health[i].is_alive():
				shooters.append({"cell": Vector2i.ZERO, "range": 0})
				continue
			var tuning := Bestiary.of(config.species_at(i))
			shooters.append({"cell": movers[i].nearest_cell(), "range": reach,
				"reload": float(tuning["strike"]) + float(tuning["repos"]),
				"sweep": bool(tuning.get("sweep", false))})
		throws.aim(DT, shooters, player.nearest_cell())
		for cell in throws.advance(DT):
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
		context: CombatContext, health: Health, progress: Progress) -> void:
	var hurt := health.ratio() <= 0.5
	var defensive: Array[Ability] = []
	var offensive: Array[Ability] = []
	for slot in range(1, character.abilities.size() + 1):
		var ability: Ability = character.abilities[slot - 1]
		if not progress.skill_unlocked(slot) or not combat.can_use(ability):
			continue
		if ability.kind == Ability.Kind.SHIELD or ability.kind == Ability.Kind.HEAL:
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


func _objective_cell(grid: MazeGrid, remaining: Array[Vector2i]) -> Vector2i:
	return grid.house_center if remaining.is_empty() else remaining[0]


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
