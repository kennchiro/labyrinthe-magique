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
signal player_shielded(amount: int)
## Émis quand le geste est refusé, avec la raison : l'interface le dit au joueur
## au lieu de laisser croire à un bug.
signal use_refused(reason: String)
## Traits élémentaires — voir le bloc TRAITS plus bas. Les quatre premiers
## informent le Level (visuels) ET la simulation (physique) ; les deux derniers
## ne servent qu'aux visuels, la physique étant déjà appliquée ici même.
signal enemy_soaked(index: int, duration: float)
signal enemy_staggered(index: int, duration: float)
signal enemy_pushed(index: int, cell: Vector2i)
signal enemy_burning(index: int, duration: float)
signal chain_arced(from_index: int, to_index: int)

## Vitesse des projectiles, en cases par seconde. Trois fois le joueur : le tir
## se voit partir et arriver, sans jamais laisser le temps de fuir.
const PROJECTILE_SPEED := 16.0
## Recul appliqué aux structures dans le choix de cible. Plus grand que la plus
## longue portée du jeu : aucun ennemi à portée ne peut donc passer derrière une
## maison, quelle que soit la distance.
const STRUCTURE_PENALTY := 100
## Fréquence des dégâts d'une zone persistante.
const ZONE_TICK := 0.5

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

var _cooldowns := {}        # id de compétence -> secondes restantes
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


func _init(p_grid: MazeGrid, p_stats: CharacterStats, p_health: Health) -> void:
	grid = p_grid
	stats = p_stats
	health = p_health


# --- Ressources ------------------------------------------------------------------

func cooldown_left(ability: Ability) -> float:
	if ability == null:
		return 0.0
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
		else:
			_cooldowns[id] = left

	_update_projectiles(delta, context)
	_update_summons(delta, context)
	_update_zones(delta, context)
	_update_walls(delta)
	_update_burns(delta, context)
	_update_echoes(delta, context)
	for index in _stagger_locks.keys():
		var lock: float = _stagger_locks[index] - delta
		if lock <= 0.0:
			_stagger_locks.erase(index)
		else:
			_stagger_locks[index] = lock


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
		if float(zone["time_left"]) <= 0.0:
			_zones.remove_at(i)
			zone_expired.emit(int(zone["id"]))


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
			player_shielded.emit(ability.damage)
			fired = true
		Ability.Kind.HEAL:
			player_healed.emit(health.heal(ability.damage))
			fired = true
		Ability.Kind.WALL:
			fired = _cast_wall(ability, context)
		Ability.Kind.BLINK:
			fired = _cast_blink(ability, context)
		Ability.Kind.SUMMON:
			fired = _cast_summon(ability, context)

	if not fired:
		return false
	_cooldowns[ability.id] = ability.cooldown
	return true


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


func _already_targeted(index: int) -> bool:
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
	var duration := float(path.size() - 1) / PROJECTILE_SPEED
	_in_flight.append({"ability": ability, "target": target, "time_left": duration})
	projectile_launched.emit(ability, target, path, duration)
	return true


func _cast_blast(ability: Ability, context: CombatContext) -> bool:
	blast_fired.emit(ability, context.player_cell)
	_apply_area(ability, context.player_cell, context)
	return true


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

## `with_trait` est faux pour les dégâts DÉRIVÉS d'un trait — tick de brûlure,
## arc, écho. Sans ce frein, la brûlure rallumerait une brûlure et l'arc
## rebondirait d'ennemi en ennemi jusqu'au dernier : les traits ne se composent
## qu'avec le coup d'origine, jamais entre eux.
func _apply_damage(index: int, ability: Ability, context: CombatContext,
		with_trait: bool = true) -> void:
	if not context.enemy_alive(index):
		return
	var dealt := context.enemy_health[index].take(
		Damage.new(ability.damage, ability.element, "player"))
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
				enemy_soaked.emit(index, SOAK_DURATION)
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
	_apply_damage(best, arc, context, false)


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
		_apply_damage(index, tick, context, false)
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
		var repeat := Ability.make({"id": source.id + "_echo", "display_name": "Écho",
			"kind": source.kind, "element": Element.Kind.SUPREME,
			"damage": int(echo["damage"])})
		_apply_damage(int(echo["index"]), repeat, context, false)


## Explosions et zones : le rayon se mesure en DISTANCE DE CHEMIN, pas à vol
## d'oiseau. Une explosion qui traverse une haie pour toucher le couloir d'à côté
## serait incompréhensible dans un labyrinthe.
func _apply_area(ability: Ability, centre: Vector2i, context: CombatContext,
		reported: Ability = null) -> void:
	var field := Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		_apply_damage(i, ability, context)
		if reported != null and context.enemy_alive(i):
			# La zone rapporte la compétence D'ORIGINE et non sa tranche : c'est
			# elle que l'interface et les effets doivent nommer.
			enemy_damaged.emit(i, 0, reported)


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
