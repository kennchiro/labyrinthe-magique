class_name CombatSystem
extends RefCounted

## Exécute les compétences : visée, temps de vol, dégâts, zones, murs, soins.
##
## Il remplace SpellSystem, dont il garde ce qui avait été mesuré et prouvé —
## la visée sur l'ennemi le plus proche EN DISTANCE DE CHEMIN, le trajet de
## l'orbe le long des couloirs, et l'impact différé par le temps de vol.
## Ce qui change : un coup au but ne « bannit » plus l'ennemi dix secondes, il
## lui retire des points de vie. Le bannissement n'avait plus de sens dès lors
## qu'on compte les ennemis éliminés.
##
## Aucune dépendance au moteur de scène : le Level écoute ses signaux pour
## fabriquer les orbes et les explosions, la simulation d'équilibrage les ignore.

signal projectile_launched(ability: Ability, target: int, path: Array, duration: float)
signal projectile_hit(ability: Ability, target: int, cell: Vector2i)
signal blast_fired(ability: Ability, cell: Vector2i)
## Un front DÉFERLE : le chemin qu'il va parcourir et le temps qu'il y mettra.
## Émis au lancement pour que le jeu puisse l'animer d'un bout à l'autre.
signal wave_launched(ability: Ability, path: Array, duration: float)
signal zone_created(zone_id: int, ability: Ability, cell: Vector2i)
signal zone_expired(zone_id: int)
signal wall_raised(cell: Vector2i)
signal wall_fell(cell: Vector2i)
signal blink_performed(from: Vector2i, to: Vector2i)
signal summon_spawned(id: int, kind_id: String, position: Vector2)
signal summon_moved(id: int, position: Vector2, facing: Vector2i)
signal summon_struck(id: int, target_index: int)
signal summon_expired(id: int)
signal enemy_damaged(index: int, dealt: int, ability: Ability)
signal enemy_killed(index: int)
signal player_healed(amount: int)
## Le bouclier est posé, avec sa durée. Il en avait une dans sa fiche (8 s) et
## le code l'IGNORAIT : une fois posé, il tenait jusqu'à ce qu'on le consomme,
## éventuellement une partie entière.
signal player_shielded(amount: int, duration: float)
## Il est tombé — épuisé par les coups, ou arrivé à échéance.
signal player_shield_faded
## Émis quand le geste est refusé, avec la raison : l'interface le dit au joueur
## au lieu de laisser croire à un bug.
signal use_refused(reason: String)
## Traits élémentaires — voir le bloc TRAITS plus bas. Les quatre premiers
## informent le Level (visuels) ET la simulation (physique) ; les deux derniers
## ne servent qu'aux visuels, la physique étant déjà appliquée ici même.
## Le facteur accompagne la durée : la trempe de l'élément Eau et le givre du
## Cercle glacé ralentissent tous deux, mais pas d'autant. Un signal qui ne
## porterait que la durée obligerait chaque récepteur à deviner de quel
## ralentissement il s'agit.
signal enemy_soaked(index: int, duration: float, factor: float)
signal enemy_staggered(index: int, duration: float)
signal enemy_pushed(index: int, cell: Vector2i)
signal enemy_burning(index: int, duration: float)
## Un arc SAUTE d'une créature à l'autre. `from_index` vaut -1 pour le premier
## trait, qui part du mage lui-même.
signal chain_arced(from_index: int, to_index: int)
## L'orage se lève au-dessus du mage, et il le suit.
signal storm_gathered(ability: Ability, duration: float)
signal storm_dispersed
## Une décharge tombe du nuage sur une créature.
signal storm_struck(index: int, ability: Ability)
## Un nuage du JUGEMENT se forme quelque part sur la carte, puis se dissipe.
signal sky_cloud_formed(cell: Vector2i, duration: float, ability: Ability)
signal sky_cloud_faded(cell: Vector2i)
## Il foudroie une créature sous lui.
signal sky_bolt(cell: Vector2i, index: int, ability: Ability)
## Une météore est en route : la case visée et le temps qu'elle met à tomber.
## Émis À L'AVANCE pour que le jeu puisse montrer la chute et marquer le sol —
## un rocher qui apparaît au sol sans prévenir n'est pas un événement, c'est un
## dégât inexpliqué.
signal meteor_incoming(cell: Vector2i, delay: float, ability: Ability)
signal meteor_landed(cell: Vector2i, ability: Ability)
## Le mage est EXALTÉ : ses coups portent plus fort pendant `duration`.
## L'interface doit le montrer — un bonus invisible n'est pas un pouvoir, c'est
## une bizarrerie de chiffres.
signal player_empowered(bonus: int, duration: float)
signal player_calmed

## Vitesse des projectiles, en cases par seconde. Trois fois le joueur : le tir
## se voit partir et arriver, sans jamais laisser le temps de fuir.
const PROJECTILE_SPEED := 16.0
## Recul appliqué aux structures dans le choix de cible. Plus grand que la plus
## longue portée du jeu : aucun ennemi à portée ne peut donc passer derrière une
## maison, quelle que soit la distance.
const STRUCTURE_PENALTY := 100
## Fréquence des dégâts d'une zone persistante.
const ZONE_TICK := 0.5
## Délai minimal entre deux charges d'un même sort.
##
## Court, mais pas nul : sur téléphone, une pression un peu longue est lue comme
## deux appuis, et sans ce garde-fou le joueur viderait deux charges sur la même
## case sans l'avoir voulu. Il ne se sent pas en jeu — on ne peut pas taper plus
## vite que ça utilement — mais il protège les charges des fausses manœuvres.
const CHARGE_GAP := 0.35

## --- INVOCATIONS ------------------------------------------------------------
##
## Les créatures de l'Invocateur. Elles vivent ICI et non dans le Level, pour la
## même raison que les projectiles et les zones : la simulation d'équilibrage
## doit les faire chasser en headless avec exactement les règles du jeu.
##
## Les marcheurs (imp, gargouille) descendent un champ de distances calculé
## depuis TOUS les ennemis vivants — le plus proche en chemin, pas à vol
## d'oiseau. Le dragon VOLE : il ignore les murs et va droit sur sa proie —
## c'est ce qui fait de lui l'ultime, aucun couloir ne le retarde.
##
##   speed   en cases/s ; reach  distance de frappe (cases, continue)
##   period  secondes entre deux coups ; damage  dégâts par coup
const SUMMON_KINDS := {
	"imp": {"speed": 4.6, "damage": 10, "period": 0.9, "reach": 1.1, "flies": false},
	"gargouille": {"speed": 4.0, "damage": 18, "period": 1.1, "reach": 1.1, "flies": false},
	"dragon": {"speed": 3.6, "damage": 34, "period": 1.3, "reach": 1.6, "flies": true},
}
## Créatures simultanées au maximum. Au-delà, la PLUS ANCIENNE disparaît : une
## armée sans plafond viderait le labyrinthe à la place du joueur.
const MAX_SUMMONS := 4
## Cadence de recalcul du champ des proies. 0,35 s comme l'IA ennemie : les
## invocations n'ont pas besoin d'être plus réactives que ce qu'elles chassent.
const SUMMON_FIELD_REFRESH := 0.35

## --- TRAITS ÉLÉMENTAIRES ---------------------------------------------------
##
## Chaque élément MARQUE ses coups d'un effet propre. C'est ce qui fait sept
## mages réellement différents : avant, tous tiraient le même projectile sous
## sept couleurs, et le choix du personnage était un choix de teinte.
##
##   FEU      brûlure — 30 % des dégâts en plus, étalés sur 1,5 s
##   EAU      trempe — la cible ralentit de 38 % pendant 2,2 s
##   TERRE    ébranlement — la cible s'arrête net 0,7 s
##   TÉNÈBRES ponction — le mage récupère 22 % des dégâts en vie
##   FOUDRE   arc — le coup saute au voisin (moitié des dégâts)
##   AIR      bourrasque — la cible est repoussée de 2 cases
##   SUPRÊME  écho — 40 % des dégâts se répètent 0,6 s plus tard
##
## Deux garde-fous, tous deux nés du papier avant la première partie :
##   - les ZONES ne déclenchent PAS de trait : une zone tique toutes les 0,5 s,
##     et un ébranlement par tick serait une paralysie permanente ;
##   - les STRUCTURES n'en reçoivent aucun : repousser une maison n'a pas de
##     sens, et la brûlure en aurait trop — un DoT gratuit sur un objectif fixe.
const BURN_RATIO := 0.30
const BURN_TICKS := 3
const BURN_TICK := 0.5
const SOAK_FACTOR := 0.62
const SOAK_DURATION := 2.2
const STAGGER_DURATION := 0.7
## Un même ennemi ne peut être ébranlé qu'une fois toutes les 3 s : sans ce
## verrou, le mage de Terre enchaînerait les arrêts et l'ennemi ne jouerait plus.
const STAGGER_LOCK := 3.0
const LEECH_RATIO := 0.22
const CHAIN_RANGE := 4
const CHAIN_RATIO := 0.5
const PUSH_CELLS := 2
const ECHO_RATIO := 0.40
const ECHO_DELAY := 0.6

var grid: MazeGrid
var stats: CharacterStats
var health: Health
## SORTS ILLIMITÉS — le mode démo. Aucune recharge : on vient y regarder les
## sorts sous toutes les coutures, pas les rationner. La campagne, elle, garde
## ses recharges ; ce drapeau n'est posé que par un LevelConfig en `is_demo`.
var free_use := false

var _cooldowns := {}        # id de compétence -> secondes restantes
var _charges := {}          # id -> charges restantes (sorts à charges)
var _refills := {}          # id -> charges à rendre quand la recharge finit
var _recover := {}          # id -> délai avant la charge suivante
var _in_flight: Array[Dictionary] = []
var _zones: Array[Dictionary] = []
var _walls: Array[Dictionary] = []
var _next_zone_id := 1
var _summons: Array[Dictionary] = []
var _next_summon_id := 1
## Champ de distances vers les proies, partagé par tous les marcheurs.
var _summon_field := PackedInt32Array()
var _summon_field_timer := 0.0
var _burning := {}                     # index -> {ticks, timer, damage}
var _echoes: Array[Dictionary] = []
var _stagger_locks := {}               # index -> secondes avant le prochain ébranlement
## index -> secondes avant qu'un piège de zone puisse le reprendre. Sans ce
## verrou, une créature immobilisée dans les flammes serait re-piégée à chaque
## tick et ne repartirait JAMAIS.
var _snare_locks := {}
var _meteors: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()
var _empower_bonus := 0
var _empower_left := 0.0
var _shield_left := 0.0
var _waves: Array[Dictionary] = []
var _chains: Array[Dictionary] = []
var _storm := {}
var _sky: Array[Dictionary] = []


## `p_seed` : la pluie de météores tire au sort ses cases. Le tirage doit être
## REPRODUCTIBLE — sinon la simulation d'équilibrage mesure un ultime différent
## à chaque partie, et deux captures du même sort ne se comparent plus.
func _init(p_grid: MazeGrid, p_stats: CharacterStats, p_health: Health,
		p_seed: int = 0) -> void:
	grid = p_grid
	stats = p_stats
	health = p_health
	_rng.seed = p_seed if p_seed != 0 else 60611


# --- Ressources ------------------------------------------------------------------

## Charges restantes, ou -1 si le sort n'en a pas. L'interface s'en sert pour
## afficher « 3/5 » : sans ce compte à l'écran, le joueur ne peut pas savoir
## combien de brasiers il lui reste, et il découvre la recharge par surprise.
func charges_left(ability: Ability) -> int:
	if ability == null or ability.charges <= 1:
		return -1
	if free_use:
		return ability.charges
	return int(_charges.get(ability.id, ability.charges))


func cooldown_left(ability: Ability) -> float:
	if ability == null or free_use:
		return 0.0
	# Tant qu'il reste une charge, le sort est PRÊT : la recharge d'un sort à
	# charges ne court qu'une fois la dernière dépensée.
	if ability.charges > 1 and charges_left(ability) > 0:
		return float(_recover.get(ability.id, 0.0))
	return float(_cooldowns.get(ability.id, 0.0))


func cooldown_ratio(ability: Ability) -> float:
	if ability == null or ability.cooldown <= 0.0:
		return 1.0
	return clampf(1.0 - cooldown_left(ability) / ability.cooldown, 0.0, 1.0)


## Le geste est-il possible MAINTENANT ?
##
## Seule la RECHARGE compte. Le mana a disparu avec la règle « un sort débloqué
## l'est pour toujours » : une compétence n'est plus un consommable, c'est un
## pouvoir. Ce qui reste hors de portée de cette classe : le déblocage (Progress)
## et la charge de l'ultime (KillSystem), que le GameManager consulte à part.
func can_use(ability: Ability) -> bool:
	if ability == null:
		return false
	return cooldown_left(ability) <= 0.0


# --- Boucle ----------------------------------------------------------------------

func update(delta: float, context: CombatContext) -> void:
	for id in _cooldowns.keys():
		var left: float = _cooldowns[id] - delta
		if left <= 0.0:
			_cooldowns.erase(id)
			# La recharge d'un sort à charges les rend TOUTES.
			if _refills.has(id):
				_charges[id] = int(_refills[id])
		else:
			_cooldowns[id] = left
	for id in _recover.keys():
		var gap: float = _recover[id] - delta
		if gap <= 0.0:
			_recover.erase(id)
		else:
			_recover[id] = gap

	_update_projectiles(delta, context)
	_update_summons(delta, context)
	_update_zones(delta, context)
	_update_walls(delta)
	_update_burns(delta, context)
	_update_echoes(delta, context)
	_update_meteors(delta, context)
	_update_waves(delta, context)
	_update_chains(delta, context)
	_update_storm(delta, context)
	_update_sky(delta, context)
	if _empower_left > 0.0:
		_empower_left = maxf(0.0, _empower_left - delta)
		if _empower_left <= 0.0:
			_empower_bonus = 0
			player_calmed.emit()
	if _shield_left > 0.0:
		_shield_left = maxf(0.0, _shield_left - delta)
		# Il tombe de DEUX façons : l'échéance, ou les coups qui l'ont vidé.
		# Les deux comptent — un bouclier à zéro qui resterait affiché mentirait
		# autant qu'un bouclier éternel.
		if _shield_left <= 0.0 or health.shield <= 0:
			_shield_left = 0.0
			health.shield = 0
			player_shield_faded.emit()
	for index in _stagger_locks.keys():
		var lock: float = _stagger_locks[index] - delta
		if lock <= 0.0:
			_stagger_locks.erase(index)
		else:
			_stagger_locks[index] = lock
	for index in _snare_locks.keys():
		var snare_lock: float = _snare_locks[index] - delta
		if snare_lock <= 0.0:
			_snare_locks.erase(index)
		else:
			_snare_locks[index] = snare_lock


func _update_projectiles(delta: float, context: CombatContext) -> void:
	for i in range(_in_flight.size() - 1, -1, -1):
		_in_flight[i]["time_left"] = float(_in_flight[i]["time_left"]) - delta
		if float(_in_flight[i]["time_left"]) > 0.0:
			continue
		var shot: Dictionary = _in_flight[i]
		_in_flight.remove_at(i)
		var index := int(shot["target"])
		var ability: Ability = shot["ability"]
		if not context.enemy_alive(index):
			continue
		var cell: Vector2i = context.enemy_cells[index]
		projectile_hit.emit(ability, index, cell)
		# Un projectile à rayon (boule de feu) explose : il touche aussi les
		# voisins. À rayon nul, il ne concerne que sa cible.
		if ability.radius > 0.0:
			_apply_area(ability, cell, context)
		else:
			_apply_damage(index, ability, context)


func _update_zones(delta: float, context: CombatContext) -> void:
	for i in range(_zones.size() - 1, -1, -1):
		var zone: Dictionary = _zones[i]
		zone["time_left"] = float(zone["time_left"]) - delta
		zone["tick"] = float(zone["tick"]) - delta
		if float(zone["tick"]) <= 0.0:
			zone["tick"] = ZONE_TICK
			# Les dégâts d'une zone sont exprimés PAR SECONDE : on n'en applique
			# que la fraction écoulée, sinon la cadence des ticks changerait la
			# puissance du sort.
			var ability: Ability = zone["ability"]
			var slice := Ability.make({
				"id": ability.id, "kind": ability.kind, "element": ability.element,
				"damage": int(round(ability.damage * ZONE_TICK)), "radius": ability.radius,
			})
			_apply_area(slice, zone["cell"], context, ability)
			if ability.snare > 0.0:
				_apply_snare(ability, zone["cell"], context)
			if ability.slow_duration > 0.0:
				_apply_chill(ability, zone["cell"], context)
		if float(zone["time_left"]) <= 0.0:
			_zones.remove_at(i)
			zone_expired.emit(int(zone["id"]))


## Le piège du brasier : ce qui entre est RETENU, puis repart en brûlant.
##
## Le verrou couvre l'immobilisation ET la brûlure qui suit, plus une seconde de
## grâce : sans elle, une créature libérée au bord des flammes serait reprise
## dans la foulée et le piège deviendrait une prison à vie.
func _apply_snare(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i) or _snare_locks.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		_snare_locks[i] = ability.snare + ability.snare_burn + 1.0
		enemy_staggered.emit(i, ability.snare)
		if ability.snare_burn > 0.0:
			# La brûlure part APRÈS la libération : on la programme, elle ne
			# commence pas pendant que la créature est encore prise.
			_echoes.append({"index": i, "time_left": ability.snare,
				"damage": 0, "ability": ability, "burn": ability.snare_burn})


## Le givre d'une zone : elle ne retient pas, elle ENGLUE. Même verrou que le
## piège — une fois par créature et par passage.
func _apply_chill(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i) or _snare_locks.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		_snare_locks[i] = ability.slow_duration + 0.5
		enemy_soaked.emit(i, ability.slow_duration, ability.slow_factor)


func _update_walls(delta: float) -> void:
	for i in range(_walls.size() - 1, -1, -1):
		_walls[i]["time_left"] = float(_walls[i]["time_left"]) - delta
		if float(_walls[i]["time_left"]) > 0.0:
			continue
		var cell: Vector2i = _walls[i]["cell"]
		_walls.remove_at(i)
		grid.set_cell(cell.x, cell.y, MazeGrid.Cell.FLOOR)
		wall_fell.emit(cell)


# --- Utilisation d'une compétence ------------------------------------------------

## Bonus de dégâts en cours, 0 quand le mage n'est pas exalté. L'interface s'en
## sert pour afficher les chiffres RÉELS de la barre d'action.
func empower_bonus() -> int:
	return _empower_bonus


func empower_left() -> float:
	return _empower_left


## Absorption restante, pour l'interface. Le joueur doit voir FONDRE sa coque :
## un bouclier qu'on ne voit pas s'user ne se gère pas.
func shield_left() -> int:
	return health.shield if health != null else 0


## Retourne true si la compétence est réellement partie. Sinon AUCUNE ressource
## n'est consommée — rater faute de cible n'est pas une faute du joueur.
func use(ability: Ability, context: CombatContext) -> bool:
	if ability == null:
		return false
	if cooldown_left(ability) > 0.0:
		use_refused.emit("recharge")
		return false
	var fired := false
	match ability.kind:
		Ability.Kind.PROJECTILE:
			fired = _cast_projectile(ability, context)
		Ability.Kind.BLAST:
			fired = _cast_blast(ability, context)
		Ability.Kind.ZONE:
			fired = _cast_zone(ability, context)
		Ability.Kind.SHIELD:
			health.add_shield(ability.damage)
			_shield_left = ability.duration
			player_shielded.emit(ability.damage, ability.duration)
			fired = true
		Ability.Kind.HEAL:
			player_healed.emit(health.heal(ability.damage))
			fired = true
		Ability.Kind.WALL:
			fired = _cast_wall(ability, context)
		Ability.Kind.BLINK:
			fired = _cast_blink(ability, context)
		Ability.Kind.WAVE:
			fired = _cast_wave(ability, context)
		Ability.Kind.CHAIN:
			fired = _cast_chain(ability, context)
		Ability.Kind.STORM:
			fired = _cast_storm(ability, context)
		Ability.Kind.SUMMON:
			fired = _cast_summon(ability, context)

	if not fired:
		return false
	if not free_use:
		_spend(ability)
	return true


## Ce que coûte un lancer. Un sort ordinaire part en recharge ; un sort à
## charges en consomme une, et n'entre en recharge qu'à la DERNIÈRE.
func _spend(ability: Ability) -> void:
	if ability.charges <= 1:
		_cooldowns[ability.id] = ability.cooldown
		return
	var left := charges_left(ability) - 1
	_charges[ability.id] = left
	_refills[ability.id] = ability.charges
	if left > 0:
		_recover[ability.id] = CHARGE_GAP
	else:
		_cooldowns[ability.id] = ability.cooldown


## Index de l'ennemi qui serait visé, -1 s'il n'y en a aucun à portée.
## Sert aussi à l'interface : elle grise le bouton plutôt que de laisser le
## joueur gaspiller un tir dans le vide.
func find_target(ability: Ability, context: CombatContext) -> int:
	var best := -1
	var best_distance := ability.range + 1 + STRUCTURE_PENALTY
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or _already_targeted(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance < 0 or distance > ability.range:
			continue
		# Une maison ne poursuit personne. Entre un ennemi sur les talons et un
		# repaire à abattre, c'est TOUJOURS l'ennemi qui prime : on l'obtient en
		# reculant les structures derrière toutes les créatures à portée, sans
		# les rendre inaccessibles pour autant.
		var score := distance + (STRUCTURE_PENALTY if context.is_structure(i) else 0)
		if score < best_distance:
			best_distance = score
			best = i
	return best


## Une cible déjà visée par un projectile en vol n'est pas re-visée : sans cette
## règle, deux orbes partiraient sur un ennemi qui n'en demandait qu'un, pendant
## que son voisin avance tranquillement.
##
## Elle SAUTE en démo. La règle protège d'un tir gaspillé pendant la recharge ;
## sans recharge il n'y a rien à gaspiller, et la refuser rendait le bouton mort
## dès qu'une orbe était en l'air — le joueur appuyait, rien ne partait.
func _already_targeted(index: int) -> bool:
	if free_use:
		return false
	for shot in _in_flight:
		if int(shot["target"]) == index:
			return true
	return false


func _cast_projectile(ability: Ability, context: CombatContext) -> bool:
	var target := find_target(ability, context)
	if target < 0:
		use_refused.emit("cible")
		return false
	var path := trajectory(context.player_cell, context.enemy_cells[target])
	if path.size() < 2:
		return false
	# La vitesse vient de la COMPÉTENCE : une boule de feu lourde met deux fois
	# plus de temps à arriver qu'une flèche, et ce délai est jouable — l'ennemi
	# a le temps de tourner le coin. La simulation le voit comme le joueur.
	var speed := PROJECTILE_SPEED * maxf(0.15, ability.projectile_speed)
	var duration := float(path.size() - 1) / speed
	_in_flight.append({"ability": ability, "target": target, "time_left": duration})
	projectile_launched.emit(ability, target, path, duration)
	return true


func _cast_blast(ability: Ability, context: CombatContext) -> bool:
	blast_fired.emit(ability, context.player_cell)
	_apply_area(ability, context.player_cell, context)
	if ability.rain_count > 0:
		_summon_rain(ability)
	if ability.sky_clouds > 0:
		_gather_sky(ability)
	if ability.heal_self > 0:
		var gained := health.heal(ability.heal_self)
		if gained > 0:
			player_healed.emit(gained)
	if ability.empower_bonus > 0 and ability.empower_duration > 0.0:
		# Relancer l'exaltation la REMET à neuf plutôt que de l'additionner :
		# deux ultimes coup sur coup ne doivent pas donner +20.
		_empower_bonus = ability.empower_bonus
		_empower_left = ability.empower_duration
		player_empowered.emit(_empower_bonus, _empower_left)
	return true


## La pluie de météores. Les cases sont tirées au sort parmi les praticables, et
## les délais étalés sur toute la durée : tombées ensemble, douze météores
## feraient un seul gros dégât et pas une pluie.
func _summon_rain(ability: Ability) -> void:
	var cells := grid.all_floor_cells()
	if cells.is_empty():
		return
	for i in ability.rain_count:
		var cell: Vector2i = cells[_rng.randi_range(0, cells.size() - 1)]
		var when := _rng.randf_range(0.0, ability.rain_duration)
		_meteors.append({"cell": cell, "time_left": when + ability.rain_fall,
			"ability": ability})
		meteor_incoming.emit(cell, when + ability.rain_fall, ability)


func _update_meteors(delta: float, context: CombatContext) -> void:
	for i in range(_meteors.size() - 1, -1, -1):
		_meteors[i]["time_left"] = float(_meteors[i]["time_left"]) - delta
		if float(_meteors[i]["time_left"]) > 0.0:
			continue
		var meteor: Dictionary = _meteors[i]
		_meteors.remove_at(i)
		var source: Ability = meteor["ability"]
		var cell: Vector2i = meteor["cell"]
		# Chaque météore est une petite explosion à part entière : mêmes règles
		# de rayon que n'importe quel sort de zone, avec ses propres chiffres.
		var strike := Ability.make({
			"id": source.id + "_meteore", "display_name": "Météore",
			"kind": Ability.Kind.BLAST, "element": source.element,
			"damage": source.rain_damage, "radius": source.rain_radius,
			"is_ultimate": true,
		})
		meteor_landed.emit(cell, source)
		_apply_area(strike, cell, context)


func _cast_zone(ability: Ability, context: CombatContext) -> bool:
	var id := _next_zone_id
	_next_zone_id += 1
	_zones.append({
		"id": id, "ability": ability, "cell": context.player_cell,
		"time_left": ability.duration, "tick": 0.0,
	})
	zone_created.emit(id, ability, context.player_cell)
	return true


## Le mur se dresse DERRIÈRE le mage, jamais devant : un joueur qui se mure la
## route et meurt le nez contre sa propre pierre ne comprendrait pas.
func _cast_wall(ability: Ability, context: CombatContext) -> bool:
	var cell: Vector2i = context.player_cell - context.player_facing
	if not grid.is_floor_v(cell) or grid.is_occupied(cell):
		use_refused.emit("place")
		return false
	grid.set_cell(cell.x, cell.y, MazeGrid.Cell.WALL)
	_walls.append({"cell": cell, "time_left": ability.duration})
	wall_raised.emit(cell)
	return true


## LE JUGEMENT CÉLESTE : des nuages se forment un peu partout et restent.
##
## Ils sont posés AU HASARD sur les cases praticables, comme la pluie du Feu —
## mais là où une météore tombe une fois et disparaît, un nuage s'installe et
## frappe tant qu'il est là. C'est la différence entre une averse et un ciel
## d'orage.
##
## Leurs instants de première décharge sont ÉTALÉS : formés en même temps, ils
## frapperaient tous à l'unisson et le ciel entier clignoterait au même rythme.
func _gather_sky(ability: Ability) -> void:
	var cells := grid.all_floor_cells()
	if cells.is_empty():
		return
	for i in ability.sky_clouds:
		var cell: Vector2i = cells[_rng.randi_range(0, cells.size() - 1)]
		_sky.append({
			"cell": cell, "ability": ability,
			"time_left": ability.sky_duration,
			"timer": _rng.randf_range(0.0, ability.sky_interval),
		})
		sky_cloud_formed.emit(cell, ability.sky_duration, ability)


func _update_sky(delta: float, context: CombatContext) -> void:
	for i in range(_sky.size() - 1, -1, -1):
		var cloud: Dictionary = _sky[i]
		cloud["time_left"] = float(cloud["time_left"]) - delta
		if float(cloud["time_left"]) <= 0.0:
			var gone: Vector2i = cloud["cell"]
			_sky.remove_at(i)
			sky_cloud_faded.emit(gone)
			continue
		cloud["timer"] = float(cloud["timer"]) - delta
		if float(cloud["timer"]) > 0.0:
			continue
		var ability: Ability = cloud["ability"]
		cloud["timer"] = ability.sky_interval

		# Chaque nuage ne voit que SOUS lui : c'est ce qui fait du Jugement un
		# ciel et non une frappe téléguidée. Un ennemi qui reste à découvert est
		# puni, un ennemi qui bouge peut passer entre les nuages.
		var centre: Vector2i = cloud["cell"]
		var field := Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
		var best := -1
		var best_distance := ability.sky_reach + 1
		for j in context.enemy_cells.size():
			if not context.enemy_alive(j) or context.is_structure(j):
				continue
			var distance := Pathfinder.value_at(grid, field, context.enemy_cells[j])
			if distance >= 0 and distance < best_distance:
				best_distance = distance
				best = j
		if best < 0:
			continue
		sky_bolt.emit(centre, best, ability)
		var strike := Ability.make({
			"id": ability.id + "_foudre", "display_name": ability.display_name,
			"kind": Ability.Kind.PROJECTILE, "element": ability.element,
			"damage": maxi(1, int(round(float(ability.damage) * 0.18))),
			"is_ultimate": true,
		})
		# Coup d'origine : chaque frappe du ciel peut donc rebondir sur un
		# voisin, comme tout ce que lance ce mage.
		_apply_damage(best, strike, context)


## L'ORAGE : un nuage qui suit le mage et foudroie tout seul.
##
## Relancer l'orage le REMET à neuf plutôt que d'en ouvrir un second : deux
## nuages superposés doubleraient la cadence sans que rien ne le montre à
## l'écran, et le joueur ne comprendrait pas pourquoi sa deuxième invocation
## semble plus forte que la première.
func _cast_storm(ability: Ability, context: CombatContext) -> bool:
	_storm = {
		"ability": ability, "time_left": ability.duration,
		# La première décharge tombe TOUT DE SUITE : un sort qui ne fait rien
		# pendant sa première seconde se lit comme un sort raté.
		"timer": 0.0,
	}
	storm_gathered.emit(ability, ability.duration)
	return true


func _update_storm(delta: float, context: CombatContext) -> void:
	if _storm.is_empty():
		return
	var ability: Ability = _storm["ability"]
	_storm["time_left"] = float(_storm["time_left"]) - delta
	if float(_storm["time_left"]) <= 0.0:
		_storm.clear()
		storm_dispersed.emit()
		return

	_storm["timer"] = float(_storm["timer"]) - delta
	if float(_storm["timer"]) > 0.0:
		return
	_storm["timer"] = ability.storm_interval

	# La cible est la plus proche DU MAGE : le nuage est au-dessus de lui et
	# frappe ce qui l'entoure. Un orage qui bombarderait la carte entière ne
	# récompenserait plus le fait de rester mobile — il jouerait tout seul.
	var best := -1
	var best_distance := ability.storm_range + 1
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance >= 0 and distance < best_distance:
			best_distance = distance
			best = i
	if best < 0:
		return
	storm_struck.emit(best, ability)
	# La décharge est un coup À PART ENTIÈRE : elle déclenche donc le trait de
	# l'élément, et chaque éclair peut rebondir sur un voisin. C'est ce qui rend
	# l'orage redoutable au milieu d'un groupe, et anodin sur un isolé.
	_apply_damage(best, ability, context)


## LA CHAÎNE D'ÉCLAIRS : elle saute d'une créature à l'autre, de proche en
## proche, en s'épuisant à chaque relais.
##
## Le parcours est calculé D'UN COUP au lancement, puis joué relais par relais.
## Le recalculer à chaque saut aurait laissé les ennemis bouger entre-temps : la
## chaîne aurait pu revenir en arrière ou changer d'avis en vol, ce qu'un éclair
## ne fait pas. Ici le trajet est décidé à l'instant du tir, et il s'accomplit.
##
## Chaque créature n'est touchée QU'UNE FOIS : sans cette mémoire, la chaîne
## ferait des allers-retours entre deux ennemis voisins jusqu'à épuisement du
## compteur de sauts.
func _cast_chain(ability: Ability, context: CombatContext) -> bool:
	var first := find_target(ability, context)
	if first < 0:
		use_refused.emit("cible")
		return false

	var hops: Array[int] = [first]
	var visited := {first: true}
	var current := first
	for jump in ability.chain_jumps:
		var next := _nearest_unvisited(current, visited, ability.chain_range, context)
		if next < 0:
			break
		visited[next] = true
		hops.append(next)
		current = next

	_chains.append({
		"ability": ability, "hops": hops, "index": 0, "timer": 0.0,
	})
	return true


## Créature vivante la plus proche de `origin` qui n'a pas encore été touchée.
## La distance se mesure en CHEMIN : la foudre suit les couloirs comme tout le
## reste du jeu — un arc qui traverserait une haie serait le privilège d'un
## ultime, pas d'un sort de rang 1.
func _nearest_unvisited(origin: int, visited: Dictionary, reach: int,
		context: CombatContext) -> int:
	var field := Pathfinder.distance_field(grid,
		[context.enemy_cells[origin]] as Array[Vector2i])
	var best := -1
	var best_distance := reach + 1
	for i in context.enemy_cells.size():
		if visited.has(i) or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and distance < best_distance:
			best_distance = distance
			best = i
	return best


func _update_chains(delta: float, context: CombatContext) -> void:
	for i in range(_chains.size() - 1, -1, -1):
		var chain: Dictionary = _chains[i]
		chain["timer"] = float(chain["timer"]) - delta
		if float(chain["timer"]) > 0.0:
			continue
		var ability: Ability = chain["ability"]
		var hops: Array = chain["hops"]
		var index := int(chain["index"])
		if index >= hops.size():
			_chains.remove_at(i)
			continue
		chain["index"] = index + 1
		chain["timer"] = ability.chain_delay

		var target := int(hops[index])
		# Le trait part du mage pour le premier relais, de la victime
		# précédente pour les suivants.
		chain_arced.emit(int(hops[index - 1]) if index > 0 else -1, target)
		if not context.enemy_alive(target):
			continue
		# La chaîne s'ÉPUISE : sans cette décroissance, grouper cinq ennemis
		# reviendrait à les tuer tous pour le prix d'un.
		var power := int(round(float(ability.damage) * pow(ability.chain_falloff, index)))
		var relay := Ability.make({
			"id": "%s_relais_%d" % [ability.id, index],
			"display_name": ability.display_name,
			"kind": Ability.Kind.PROJECTILE, "element": ability.element,
			"damage": maxi(1, power),
		})
		# JAMAIS le trait : ce sort EST la chaîne de l'élément Foudre. Le laisser
		# déclencher en plus l'arc du trait ferait partir un arc de trop et
		# frapperait un maillon deux fois — mesuré : 5 arcs pour 3 relais.
		# L'exaltation, elle, s'applique au premier maillon comme à tout coup
		# d'origine.
		_apply_damage(target, relay, context, false, index == 0)


## LA VAGUE : un front qui part droit devant et balaie tout son chemin.
##
## Elle ne vise pas — elle prend le couloir. C'est ce qui la sépare du
## projectile, qui cherche une cible, et du souffle, qui frappe tout d'un coup
## autour du lanceur. Ici l'ennemi VOIT venir, et peut encore s'écarter dans une
## intersection : la vague récompense le joueur qui l'aligne sur un couloir
## droit, pas celui qui appuie au hasard.
func _cast_wave(ability: Ability, context: CombatContext) -> bool:
	# LA VAGUE VA CHERCHER L'ENNEMI, elle ne part pas droit devant.
	#
	# Première version : elle suivait le regard du mage. Défaut de conception —
	# en FUYANT, on tourne le dos à ses poursuivants, et le sort partait donc
	# systématiquement du mauvais côté. Il fallait s'arrêter et se retourner
	# pour s'en servir : exactement ce qu'un sort de fuite doit éviter.
	#
	# Elle remonte désormais le COULOIR jusqu'à l'ennemi le plus proche, comme
	# un projectile — mais en frappant tout ce qu'elle croise en chemin. À
	# défaut de cible, elle part devant : un sort qui refuserait de sortir
	# faute d'ennemi visible serait un bouton mort.
	var path: Array[Vector2i] = []
	var target := find_target(ability, context)
	if target >= 0:
		var route := trajectory(context.player_cell, context.enemy_cells[target])
		for i in range(1, route.size()):
			if path.size() >= ability.range:
				break
			path.append(route[i])
	if path.is_empty():
		var cell := context.player_cell
		for step in ability.range:
			var next: Vector2i = cell + context.player_facing
			if not grid.is_floor_v(next):
				break
			cell = next
			path.append(cell)
	if path.is_empty():
		use_refused.emit("mur")
		return false
	var duration := float(path.size()) / maxf(1.0, ability.wave_speed)
	_waves.append({
		"ability": ability, "path": path, "index": 0,
		"step": duration / float(path.size()), "timer": 0.0,
		# Chaque ennemi n'est frappé QU'UNE FOIS par vague : sans cette mémoire,
		# un ennemi qui recule devant le front encaisserait à chaque case.
		"hit": {},
	})
	wave_launched.emit(ability, path, duration)
	return true


func _update_waves(delta: float, context: CombatContext) -> void:
	for i in range(_waves.size() - 1, -1, -1):
		var wave: Dictionary = _waves[i]
		wave["timer"] = float(wave["timer"]) - delta
		if float(wave["timer"]) > 0.0:
			continue
		wave["timer"] = float(wave["step"])
		var path: Array = wave["path"]
		var index := int(wave["index"])
		if index >= path.size():
			_waves.remove_at(i)
			continue
		wave["index"] = index + 1
		_break_on_wave(wave, path[index], context)


## Le front est arrivé sur une case : il frappe ce qui s'y trouve, et ce qui est
## à portée de sa largeur.
func _break_on_wave(wave: Dictionary, cell: Vector2i, context: CombatContext) -> void:
	var ability: Ability = wave["ability"]
	var already: Dictionary = wave["hit"]
	var field := Pathfinder.distance_field(grid, [cell] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or already.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		already[i] = true
		_apply_damage(i, ability, context)


func _cast_blink(ability: Ability, context: CombatContext) -> bool:
	var destination := context.player_cell
	for step in ability.range:
		var next: Vector2i = destination + context.player_facing
		if not grid.is_floor_v(next):
			break
		destination = next
	if destination == context.player_cell:
		use_refused.emit("mur")
		return false
	blink_performed.emit(context.player_cell, destination)
	return true


# --- Invocations ------------------------------------------------------------------

func _cast_summon(ability: Ability, context: CombatContext) -> bool:
	if not SUMMON_KINDS.has(ability.summon_id):
		push_error("Créature d'invocation inconnue : " + ability.summon_id)
		return false
	for i in maxi(1, ability.summon_count):
		# Les créatures naissent autour du mage, chacune sur sa case praticable :
		# empilées sur la sienne, on ne verrait qu'une seule invocation.
		var cell := _summon_spawn_cell(context, i)
		var summon := {
			"id": _next_summon_id, "kind": ability.summon_id,
			"position": Vector2(cell) , "cell": cell,
			"time_left": ability.duration, "strike_in": 0.6,
			"facing": Vector2i.DOWN, "target": -1,
		}
		_next_summon_id += 1
		_summons.append(summon)
		summon_spawned.emit(int(summon["id"]), ability.summon_id, summon["position"])
	# La plus ancienne cède la place au-delà du plafond — jamais la nouvelle :
	# un sort qui échoue parce qu'on l'a déjà lancé se lit comme une panne.
	while _summons.size() > MAX_SUMMONS:
		var oldest: Dictionary = _summons.pop_front()
		summon_expired.emit(int(oldest["id"]))
	# Le champ des proies est immédiatement rafraîchi : une créature qui reste
	# plantée une tierce de seconde à sa naissance a l'air cassée.
	_summon_field_timer = 0.0
	return true


func _summon_spawn_cell(context: CombatContext, offset: int) -> Vector2i:
	var candidates: Array[Vector2i] = []
	for step in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(context.player_cell + step):
			candidates.append(context.player_cell + step)
	if candidates.is_empty():
		return context.player_cell
	return candidates[offset % candidates.size()]


func _update_summons(delta: float, context: CombatContext) -> void:
	if _summons.is_empty():
		return
	_summon_field_timer -= delta
	if _summon_field_timer <= 0.0:
		_summon_field_timer = SUMMON_FIELD_REFRESH
		_refresh_summon_field(context)

	for i in range(_summons.size() - 1, -1, -1):
		var summon: Dictionary = _summons[i]
		summon["time_left"] = float(summon["time_left"]) - delta
		if float(summon["time_left"]) <= 0.0:
			_summons.remove_at(i)
			summon_expired.emit(int(summon["id"]))
			continue
		summon["strike_in"] = maxf(0.0, float(summon["strike_in"]) - delta)
		var stats: Dictionary = SUMMON_KINDS[summon["kind"]]
		var target := _nearest_prey(summon, context)
		summon["target"] = target
		if target >= 0 and _try_strike(summon, stats, target, context):
			continue
		_advance_summon(summon, stats, target, delta, context)


## La proie : l'ennemi vivant le plus proche. À VOL D'OISEAU pour le dragon qui
## vole, en distance de couloir pour les marcheurs — chacun sa géométrie.
func _nearest_prey(summon: Dictionary, context: CombatContext) -> int:
	var best := -1
	var best_score := 1e9
	var position: Vector2 = summon["position"]
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var score := position.distance_to(Vector2(context.enemy_cells[i]))
		if score < best_score:
			best_score = score
			best = i
	return best


func _try_strike(summon: Dictionary, stats: Dictionary, target: int,
		context: CombatContext) -> bool:
	var reach := float(stats["reach"])
	var position: Vector2 = summon["position"]
	if position.distance_to(Vector2(context.enemy_cells[target])) > reach:
		return false
	if float(summon["strike_in"]) > 0.0:
		return true
	summon["strike_in"] = float(stats["period"])
	summon_struck.emit(int(summon["id"]), target)
	# Les coups d'une créature ne déclenchent PAS de trait élémentaire : le
	# trait est la signature du mage, pas celle de ses bêtes — et un dragon qui
	# répandrait la brûlure du Feu brouillerait la lecture des personnages.
	var blow := Ability.make({
		"id": "summon_" + str(summon["kind"]), "kind": Ability.Kind.ZONE,
		"element": Element.Kind.SHADOW, "damage": int(stats["damage"]),
	})
	_apply_damage(target, blow, context, false)
	return true


func _advance_summon(summon: Dictionary, stats: Dictionary, target: int,
		delta: float, context: CombatContext) -> void:
	var position: Vector2 = summon["position"]
	var step := Vector2.ZERO
	if bool(stats["flies"]):
		# Le dragon ignore les murs : droit sur la proie.
		if target >= 0:
			step = (Vector2(context.enemy_cells[target]) - position)
	else:
		# Les marcheurs descendent le champ des proies, couloir par couloir.
		var cell := Vector2i(int(round(position.x)), int(round(position.y)))
		var towards := Pathfinder.step_toward(grid, _summon_field, cell)
		if towards != Vector2i.ZERO:
			# Viser le CENTRE de la case suivante : c'est ce qui garde la
			# créature alignée sur les couloirs sans lui écrire un GridMover.
			step = (Vector2(cell + towards) - position)
	if step.length() < 0.05:
		return
	step = step.normalized() * minf(float(stats["speed"]) * delta, step.length())
	summon["position"] = position + step
	if absf(step.x) > absf(step.y):
		summon["facing"] = Vector2i.RIGHT if step.x > 0.0 else Vector2i.LEFT
	elif step.y != 0.0:
		summon["facing"] = Vector2i.DOWN if step.y > 0.0 else Vector2i.UP
	summon_moved.emit(int(summon["id"]), summon["position"], summon["facing"])


func _refresh_summon_field(context: CombatContext) -> void:
	var sources: Array[Vector2i] = []
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			sources.append(context.enemy_cells[i])
	_summon_field = Pathfinder.distance_field(grid, sources) 		if not sources.is_empty() else PackedInt32Array()


## Le nombre de créatures encore en chasse — l'interface l'affiche.
func summon_count() -> int:
	return _summons.size()


# --- Dégâts ----------------------------------------------------------------------

## Deux freins, et il a fallu les SÉPARER.
##
## `with_trait` est faux pour les dégâts DÉRIVÉS — tick de brûlure, arc, écho.
## Sans lui, la brûlure rallumerait une brûlure et l'arc rebondirait d'ennemi en
## ennemi jusqu'au dernier : les traits ne se composent qu'avec le coup
## d'origine, jamais entre eux.
##
## `empowered` est faux pour les mêmes dégâts dérivés, mais PAS toujours en même
## temps que `with_trait`. Le cas qui a forcé la séparation : la Chaîne
## d'éclairs. C'est un sort qui chaîne DÉJÀ, donc son premier maillon ne doit
## pas déclencher en plus le trait de l'élément Foudre — sinon un arc
## supplémentaire part et une créature encaisse deux fois. Mais ce premier
## maillon, lui, doit bien profiter de l'exaltation du joueur. Un seul drapeau
## ne pouvait pas dire les deux.
func _apply_damage(index: int, ability: Ability, context: CombatContext,
		with_trait: bool = true, empowered: bool = true) -> void:
	if not context.enemy_alive(index):
		return
	# L'exaltation ne s'applique qu'au coup D'ORIGINE (`with_trait`), jamais aux
	# dégâts dérivés : sinon +10 s'ajouterait à chaque tic de brûlure, à chaque
	# arc et à chaque écho, et le bonus se multiplierait au lieu de s'ajouter.
	var power := ability.damage + (_empower_bonus if empowered else 0)
	var dealt := context.enemy_health[index].take(
		Damage.new(power, ability.element, "player"))
	enemy_damaged.emit(index, dealt, ability)
	if with_trait and dealt > 0 and ability.kind != Ability.Kind.ZONE \
			and not context.is_structure(index):
		_apply_trait(index, dealt, ability, context)
	if not context.enemy_health[index].is_alive():
		enemy_killed.emit(index)


func _apply_trait(index: int, dealt: int, ability: Ability, context: CombatContext) -> void:
	match ability.element:
		Element.Kind.FIRE:
			if context.enemy_alive(index):
				var per_tick := maxi(1, int(round(dealt * BURN_RATIO / float(BURN_TICKS))))
				_burning[index] = {"ticks": BURN_TICKS, "timer": BURN_TICK, "damage": per_tick}
				enemy_burning.emit(index, BURN_TICKS * BURN_TICK)
		Element.Kind.WATER:
			if context.enemy_alive(index):
				enemy_soaked.emit(index, SOAK_DURATION, SOAK_FACTOR)
		Element.Kind.EARTH:
			if context.enemy_alive(index) and not _stagger_locks.has(index):
				_stagger_locks[index] = STAGGER_LOCK
				enemy_staggered.emit(index, STAGGER_DURATION)
		Element.Kind.SHADOW:
			var gained := health.heal(maxi(1, int(round(dealt * LEECH_RATIO))))
			if gained > 0:
				player_healed.emit(gained)
		Element.Kind.THUNDER:
			_chain_to_neighbour(index, dealt, ability, context)
		Element.Kind.AIR:
			if context.enemy_alive(index):
				_push_away(index, context)
		Element.Kind.SUPREME:
			if context.enemy_alive(index):
				_echoes.append({"index": index, "time_left": ECHO_DELAY,
					"damage": maxi(1, int(round(dealt * ECHO_RATIO))), "ability": ability})


## L'arc de foudre : le coup saute à l'ennemi vivant le plus proche DE LA
## VICTIME — pas du mage. C'est ce qui fait du mage de la Foudre le spécialiste
## des meutes : plus les poursuivants se serrent, plus il rend cher ce
## regroupement.
func _chain_to_neighbour(index: int, dealt: int, ability: Ability,
		context: CombatContext) -> void:
	var field := Pathfinder.distance_field(grid,
		[context.enemy_cells[index]] as Array[Vector2i])
	var best := -1
	var best_distance := CHAIN_RANGE + 1
	for i in context.enemy_cells.size():
		if i == index or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and distance < best_distance:
			best_distance = distance
			best = i
	if best < 0:
		return
	chain_arced.emit(index, best)
	var arc := Ability.make({"id": ability.id + "_arc", "display_name": "Arc",
		"kind": ability.kind, "element": ability.element,
		"damage": maxi(1, int(round(dealt * CHAIN_RATIO)))})
	# Ni trait ni exaltation : c'est un dégât DÉRIVÉ du trait Foudre.
	_apply_damage(best, arc, context, false, false)


## La bourrasque : l'ennemi recule en SUIVANT le gradient de distance au mage —
## il est soufflé le long du couloir, jamais à travers une haie.
func _push_away(index: int, context: CombatContext) -> void:
	var cell: Vector2i = context.enemy_cells[index]
	for _step in PUSH_CELLS:
		var best := cell
		var here := Pathfinder.value_at(grid, context.player_field, cell)
		for direction in MazeGrid.NEIGHBORS:
			var next: Vector2i = cell + direction
			if not grid.is_floor_v(next) or grid.is_occupied(next):
				continue
			var value := Pathfinder.value_at(grid, context.player_field, next)
			if value > here:
				here = value
				best = next
		if best == cell:
			break
		cell = best
	if cell == context.enemy_cells[index]:
		return
	context.enemy_cells[index] = cell
	enemy_pushed.emit(index, cell)


func _update_burns(delta: float, context: CombatContext) -> void:
	for index in _burning.keys():
		if not context.enemy_alive(index):
			_burning.erase(index)
			continue
		var burn: Dictionary = _burning[index]
		burn["timer"] = float(burn["timer"]) - delta
		if float(burn["timer"]) > 0.0:
			continue
		burn["timer"] = BURN_TICK
		burn["ticks"] = int(burn["ticks"]) - 1
		var tick := Ability.make({"id": "burn", "display_name": "Brûlure",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.FIRE,
			"damage": int(burn["damage"])})
		# Ni trait ni exaltation : un tic de brûlure n'est pas un coup porté.
		_apply_damage(index, tick, context, false, false)
		if int(burn["ticks"]) <= 0:
			_burning.erase(index)


func _update_echoes(delta: float, context: CombatContext) -> void:
	for i in range(_echoes.size() - 1, -1, -1):
		_echoes[i]["time_left"] = float(_echoes[i]["time_left"]) - delta
		if float(_echoes[i]["time_left"]) > 0.0:
			continue
		var echo: Dictionary = _echoes[i]
		_echoes.remove_at(i)
		var source: Ability = echo["ability"]
		var index := int(echo["index"])
		# Une entrée « burn » n'est pas un écho : c'est la brûlure différée d'un
		# piège de zone, qui s'allume au moment où la créature est libérée.
		var burn_time := float(echo.get("burn", 0.0))
		if burn_time > 0.0:
			if context.enemy_alive(index):
				var ticks := maxi(1, int(round(burn_time / BURN_TICK)))
				var per_tick := maxi(1, int(round(source.damage * BURN_RATIO)))
				_burning[index] = {"ticks": ticks, "timer": BURN_TICK, "damage": per_tick}
				enemy_burning.emit(index, burn_time)
			continue
		var repeat := Ability.make({"id": source.id + "_echo", "display_name": "Écho",
			"kind": source.kind, "element": Element.Kind.SUPREME,
			"damage": int(echo["damage"])})
		# Ni trait ni exaltation : l'écho répète un coup, il n'en est pas un.
		_apply_damage(index, repeat, context, false, false)


## Explosions et zones : le rayon se mesure en DISTANCE DE CHEMIN, pas à vol
## d'oiseau. Une explosion qui traverse une haie pour toucher le couloir d'à côté
## serait incompréhensible dans un labyrinthe.
func _apply_area(ability: Ability, centre: Vector2i, context: CombatContext,
		reported: Ability = null) -> void:
	# UN ULTIME PASSE LES MURS. Ailleurs le rayon se mesure en distance de
	# chemin — une explosion ne doit pas traverser une haie. Ici on mesure à vol
	# d'oiseau : le souffle balaye le labyrinthe sans se soucier des couloirs.
	if ability.pierces_walls:
		for i in context.enemy_cells.size():
			if not context.enemy_alive(i):
				continue
			if Vector2(context.enemy_cells[i] - centre).length() > ability.radius:
				continue
			_apply_damage(i, ability, context)
			if reported != null and context.enemy_alive(i):
				enemy_damaged.emit(i, 0, reported)
		return

	var field := Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		if not _within_arc(ability, centre, context.enemy_cells[i], context):
			continue
		_apply_damage(i, ability, context)
		if reported != null and context.enemy_alive(i):
			# La zone rapporte la compétence D'ORIGINE et non sa tranche : c'est
			# elle que l'interface et les effets doivent nommer.
			enemy_damaged.emit(i, 0, reported)


## La cible est-elle dans l'OUVERTURE du souffle ?
##
## Mesuré à vol d'oiseau depuis le lanceur, et non le long du couloir : une
## vague balaie ce qui est DEVANT, et le joueur juge « devant » à ce qu'il voit,
## pas à la topologie du labyrinthe.
func _within_arc(ability: Ability, centre: Vector2i, target: Vector2i,
		context: CombatContext) -> bool:
	if ability.arc <= 0.0 or ability.arc >= 360.0:
		return true
	var facing := Vector2(context.player_facing)
	if facing.length() < 0.01 or target == centre:
		return true
	var to_target := Vector2(target - centre)
	return absf(rad_to_deg(facing.angle_to(to_target))) <= ability.arc * 0.5


## Chemin case par case d'un projectile, du joueur à la cible : un BFS depuis la
## CIBLE puis une descente du gradient — le même mécanisme que la poursuite des
## ennemis, réutilisé tel quel.
func trajectory(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [from]
	if from == to:
		return path
	var field := Pathfinder.distance_field(grid, [to] as Array[Vector2i])
	var current := from
	for _step in grid.cols * grid.rows:
		var direction := Pathfinder.step_toward(grid, field, current)
		if direction == Vector2i.ZERO:
			break
		current += direction
		path.append(current)
		if current == to:
			break
	return path
