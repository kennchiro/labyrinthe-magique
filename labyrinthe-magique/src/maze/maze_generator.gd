class_name MazeGenerator
extends RefCounted

## Écart minimal, en distance de chemin, entre deux ennemis au démarrage.
const ENEMY_MIN_GAP := 8

## Génération du labyrinthe, en 8 passes :
##   1. Recursive Backtracker  -> un labyrinthe parfait (un seul chemin entre 2 points)
##   2. Maison au centre       -> on creuse la zone objectif
##   3. Braiding               -> on retire des culs-de-sac pour créer des boucles
##   4. Champ de distances     -> BFS depuis la maison, la donnée clé du jeu
##   5. Portails               -> placés espacés, via le champ de distances
##   5b. Repaires            -> deux maisons d'ennemis, aux coins opposés
##   6. Gemmes                 -> l'objectif : une par secteur, loin de la maison
##   7. Potions                -> au hasard, à l'écart des gemmes et des portails
##   8. Spawns                 -> joueur au point le plus reculé, ennemis loin de lui
##
## Tout est déterministe pour une graine donnée : indispensable pour reproduire
## un bug de génération ou rejouer exactement la même partie.


static func generate(config: LevelConfig, rng_seed: int = 0) -> MazeGrid:
	var rng := RandomNumberGenerator.new()
	if rng_seed == 0:
		rng.randomize()
	else:
		rng.seed = rng_seed

	var room_count: int = maxi(3, config.room_count)
	if room_count % 2 == 0:
		room_count += 1  # garantit l'existence d'une salle centrale

	var size := room_count * 2 + 1
	var grid := MazeGrid.new(size, size)

	_carve_perfect_maze(grid, room_count, rng)
	_carve_house(grid, config, room_count)
	_braid(grid, config.braid_ratio, rng)
	_compute_distance_field(grid)
	_place_portals(grid, config, rng)
	_place_lairs(grid)
	_place_gems(grid, config, rng)
	_place_potions(grid, config, rng)
	_place_spawns(grid, config, rng)
	return grid


# --- 1. Labyrinthe parfait -----------------------------------------------------
# Les "salles" vivent aux coordonnées impaires (2i+1, 2j+1) ; les cases paires
# entre elles sont les murs qu'on perce.

static func _carve_perfect_maze(grid: MazeGrid, room_count: int, rng: RandomNumberGenerator) -> void:
	var visited := {}
	var start := Vector2i(rng.randi_range(0, room_count - 1), rng.randi_range(0, room_count - 1))
	var stack: Array[Vector2i] = [start]
	visited[start] = true
	grid.set_cell(start.x * 2 + 1, start.y * 2 + 1, MazeGrid.Cell.FLOOR)

	while not stack.is_empty():
		var cur: Vector2i = stack[-1]
		var candidates: Array[Vector2i] = []
		for d in MazeGrid.NEIGHBORS:
			var n: Vector2i = cur + d
			if n.x >= 0 and n.x < room_count and n.y >= 0 and n.y < room_count and not visited.has(n):
				candidates.append(n)

		if candidates.is_empty():
			stack.pop_back()
			continue

		var nxt: Vector2i = candidates[rng.randi_range(0, candidates.size() - 1)]
		visited[nxt] = true

		var a := Vector2i(cur.x * 2 + 1, cur.y * 2 + 1)
		var b := Vector2i(nxt.x * 2 + 1, nxt.y * 2 + 1)
		grid.set_cell(b.x, b.y, MazeGrid.Cell.FLOOR)
		grid.set_cell((a.x + b.x) / 2, (a.y + b.y) / 2, MazeGrid.Cell.FLOOR)  # le mur entre les deux
		stack.append(nxt)


# --- 2. Maison centrale --------------------------------------------------------

static func _carve_house(grid: MazeGrid, config: LevelConfig, room_count: int) -> void:
	var center_room := room_count / 2
	var center := Vector2i(center_room * 2 + 1, center_room * 2 + 1)
	var radius: int = maxi(0, config.house_radius)

	grid.house_center = center
	grid.house_cells.clear()

	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			var p := center + Vector2i(dx, dy)
			if not grid.in_bounds(p.x, p.y):
				continue
			grid.set_cell(p.x, p.y, MazeGrid.Cell.FLOOR)
			grid.house_cells.append(p)

	# La PORTE, au sud : le mage commence la partie chez lui et doit pouvoir en
	# sortir. Le centre est en coordonnées impaires, donc la case au-delà du
	# seuil peut tomber sur une rangée de murs (parité paire) — on la perce.
	# Elle donne alors sur une case (impaire, impaire), toujours une salle.
	var door := center + Vector2i(0, radius + 1)
	if grid.in_bounds(door.x, door.y) and not grid.is_floor_v(door):
		grid.set_cell(door.x, door.y, MazeGrid.Cell.FLOOR)


# --- 3. Braiding : on casse les impasses --------------------------------------

static func _braid(grid: MazeGrid, ratio: float, rng: RandomNumberGenerator) -> void:
	if ratio <= 0.0:
		return

	var dead_ends: Array[Vector2i] = []
	for cell in grid.all_floor_cells():
		if grid.floor_neighbors(cell).size() <= 1:
			dead_ends.append(cell)

	_shuffle(dead_ends, rng)
	var to_open := int(round(dead_ends.size() * clampf(ratio, 0.0, 1.0)))

	for i in to_open:
		var cell: Vector2i = dead_ends[i]
		var options: Array[Vector2i] = []
		for d in MazeGrid.NEIGHBORS:
			var wall: Vector2i = cell + d
			var beyond: Vector2i = cell + d * 2
			# `beyond` in_bounds garantit qu'on ne perce jamais la bordure extérieure.
			if grid.in_bounds(beyond.x, beyond.y) and grid.is_wall(wall.x, wall.y) and grid.is_floor_v(beyond):
				options.append(wall)
		if options.is_empty():
			continue
		var w: Vector2i = options[rng.randi_range(0, options.size() - 1)]
		grid.set_cell(w.x, w.y, MazeGrid.Cell.FLOOR)


# --- 4. Champ de distances (BFS depuis la maison) ------------------------------

static func _compute_distance_field(grid: MazeGrid) -> void:
	grid.distance_to_house.fill(-1)
	var queue: Array[Vector2i] = []
	for p in grid.house_cells:
		if grid.is_floor_v(p):
			grid.set_distance(p, 0)
			queue.append(p)

	var head := 0
	while head < queue.size():
		var cur: Vector2i = queue[head]
		head += 1
		var d := grid.distance_at(cur) + 1
		for n in grid.floor_neighbors(cur):
			if grid.distance_at(n) == -1:
				grid.set_distance(n, d)
				queue.append(n)


# --- 5. Portails ---------------------------------------------------------------

static func _place_portals(grid: MazeGrid, config: LevelConfig, rng: RandomNumberGenerator) -> void:
	grid.portals.clear()

	var candidates: Array[Vector2i] = []
	for cell in grid.all_floor_cells():
		# On écarte la maison et son voisinage immédiat : un portail collé à
		# l'objectif viderait le jeu de son enjeu.
		if grid.distance_at(cell) < 4:
			continue
		candidates.append(cell)

	_shuffle(candidates, rng)
	var spacing: int = maxi(1, config.portal_min_spacing)

	for cell in candidates:
		if grid.portals.size() >= config.portal_count:
			break
		var too_close := false
		for placed in grid.portals:
			if absi(placed.x - cell.x) + absi(placed.y - cell.y) < spacing:
				too_close = true
				break
		if not too_close:
			grid.portals.append(cell)

	# Filet de sécurité : si l'espacement était trop exigeant pour ce labyrinthe,
	# on complète sans contrainte plutôt que de livrer un niveau sans portails.
	for cell in candidates:
		if grid.portals.size() >= config.portal_count:
			break
		if not grid.portals.has(cell):
			grid.portals.append(cell)


# --- 5b. Repaires d'ennemis ----------------------------------------------------
#
# Deux maisons, au plus près des coins HAUT-GAUCHE et BAS-DROITE. Les ennemis en
# sortent au lieu d'apparaître n'importe où : le joueur peut alors apprendre la
# carte, anticiper, et choisir de rester loin des coins. Une apparition au
# hasard, elle, ne s'apprend pas — elle se subit.
#
# Le coin exact est un mur (la bordure l'est toujours) : on prend la case
# praticable la plus proche, en distance à vol d'oiseau.

static func _place_lairs(grid: MazeGrid) -> void:
	grid.lairs.clear()
	for corner in [Vector2i(1, 1), Vector2i(grid.cols - 2, grid.rows - 2)]:
		var best := Vector2i(-1, -1)
		var best_distance := 1 << 30
		for cell in grid.all_floor_cells():
			if grid.is_house(cell) or grid.portals.has(cell) or grid.lairs.has(cell):
				continue
			# Jamais collé à la maison : un repaire dans la clairière d'arrivée
			# transformerait la victoire en embuscade.
			if grid.distance_at(cell) < 6:
				continue
			var distance: int = absi(cell.x - corner.x) + absi(cell.y - corner.y)
			if distance < best_distance:
				best_distance = distance
				best = cell
		if best.x >= 0:
			grid.lairs.append(best)


# --- 6. Gemmes -----------------------------------------------------------------
#
# Les gemmes sont l'objectif : la porte de la maison ne s'ouvre que lorsqu'elles
# sont toutes ramassées. Leur placement décide donc de la FORME de la partie —
# c'est lui, et non le labyrinthe, qui fait la longueur d'un niveau.

## Part de la distance maximale sous laquelle une gemme ne vaut pas le détour :
## posée trop près de la maison, elle se ramasse en passant et l'objectif ne
## change rien au trajet.
const GEM_MIN_DISTANCE_RATIO := 0.45

static func _place_gems(grid: MazeGrid, config: LevelConfig, rng: RandomNumberGenerator) -> void:
	grid.gems.clear()
	var target: int = maxi(1, config.gem_count)
	var min_distance: int = maxi(4, int(grid.max_distance() * GEM_MIN_DISTANCE_RATIO))
	var spacing: int = maxi(4, (grid.cols + grid.rows) / (target + 2))

	var candidates: Array[Vector2i] = []
	for cell in grid.all_floor_cells():
		# Les repaires en font partie : une gemme posée sur la maison des
		# ennemis serait un piège, pas un objectif.
		if grid.portals.has(cell) or grid.is_house(cell) or grid.lairs.has(cell):
			continue
		if grid.distance_at(cell) < min_distance:
			continue
		candidates.append(cell)
	_shuffle(candidates, rng)

	# Passe 1 — une gemme par SECTEUR angulaire autour de la maison. Sans cette
	# contrainte, un tirage purement aléatoire regroupe régulièrement toutes les
	# gemmes du même côté : la tournée dégénère en aller-retour et la moitié du
	# labyrinthe ne sert plus à rien.
	var used_sectors := {}
	for cell in candidates:
		if grid.gems.size() >= target:
			break
		var sector := _sector(grid, cell, target)
		if used_sectors.has(sector) or _too_close(grid.gems, cell, spacing):
			continue
		used_sectors[sector] = true
		grid.gems.append(cell)

	# Passes de repli : espacement seul, puis sans contrainte. Un niveau livré
	# avec moins de gemmes que prévu serait ingagnable — le compte prime.
	for pass_spacing in [spacing, spacing / 2, 0]:
		for cell in candidates:
			if grid.gems.size() >= target:
				return
			if grid.gems.has(cell) or _too_close(grid.gems, cell, pass_spacing):
				continue
			grid.gems.append(cell)


## Secteur angulaire d'une case vue depuis la maison, découpé en `count` parts.
static func _sector(grid: MazeGrid, cell: Vector2i, count: int) -> int:
	var offset := Vector2(cell - grid.house_center)
	var angle := fposmod(offset.angle(), TAU)
	return int(angle / (TAU / float(maxi(1, count))))


static func _too_close(placed: Array[Vector2i], cell: Vector2i, spacing: int) -> bool:
	for other in placed:
		if absi(other.x - cell.x) + absi(other.y - cell.y) < spacing:
			return true
	return false


# --- 7. Potions ----------------------------------------------------------------

static func _place_potions(grid: MazeGrid, config: LevelConfig, rng: RandomNumberGenerator) -> void:
	grid.potions.clear()
	for i in maxi(0, config.potion_count):
		var cell := pick_potion_cell(grid, rng)
		if cell.x >= 0:
			grid.potions.append(cell)


## Choisit une case libre pour une potion. Appelée à la génération ET en cours
## de partie, quand une potion consommée doit réapparaître ailleurs : c'est la
## même règle dans les deux cas, donc la même fonction.
## `player_cell` / `min_player_gap` évitent qu'une potion surgisse sous les pieds
## du joueur — cadeau gratuit — ou juste derrière lui, hors de sa vue.
## Retourne Vector2i(-1, -1) si le labyrinthe n'offre aucune place.
static func pick_potion_cell(grid: MazeGrid, rng: RandomNumberGenerator,
		player_cell: Vector2i = Vector2i(-1, -1), min_player_gap: int = 0) -> Vector2i:
	var candidates: Array[Vector2i] = []
	for cell in grid.all_floor_cells():
		if grid.is_occupied(cell) or grid.distance_at(cell) < 4:
			continue
		if player_cell.x >= 0 and absi(player_cell.x - cell.x) + absi(player_cell.y - cell.y) < min_player_gap:
			continue
		candidates.append(cell)
	if candidates.is_empty():
		return Vector2i(-1, -1)
	return candidates[rng.randi_range(0, candidates.size() - 1)]


## Repaire le plus éloigné du joueur : c'est de là que revient un ennemi tué.
## Le renvoyer dans la maison où le mage se tient serait une exécution.
static func farthest_lair(grid: MazeGrid, player_field: PackedInt32Array,
		fallback: Vector2i) -> Vector2i:
	var best := fallback
	var best_distance := -1
	for lair in grid.lairs:
		var distance := Pathfinder.value_at(grid, player_field, lair)
		if distance > best_distance:
			best_distance = distance
			best = lair
	return best


## Où faire réapparaître un ennemi neutralisé par le sort. On veut une case
## LOIN du joueur : le renvoyer sur son spawn d'origine le ferait surgir dans le
## dos du mage si celui-ci a fait le tour, et ressusciter sous son nez annulerait
## les dix secondes gagnées.
static func pick_enemy_respawn(grid: MazeGrid, rng: RandomNumberGenerator,
		player_field: PackedInt32Array, min_gap: int, fallback: Vector2i) -> Vector2i:
	var candidates: Array[Vector2i] = []
	for cell in grid.all_floor_cells():
		if grid.is_house(cell) or grid.portals.has(cell):
			continue
		if grid.distance_at(cell) < 5:
			continue
		if Pathfinder.value_at(grid, player_field, cell) < min_gap:
			continue
		candidates.append(cell)
	if candidates.is_empty():
		return fallback
	return candidates[rng.randi_range(0, candidates.size() - 1)]


# --- 8. Spawns -----------------------------------------------------------------

static func _place_spawns(grid: MazeGrid, config: LevelConfig, rng: RandomNumberGenerator) -> void:
	grid.enemy_spawns.clear()

	var occupied := grid.portals.duplicate()
	occupied.append_array(grid.gems)
	occupied.append_array(grid.potions)
	# Les repaires aussi : un ennemi de repli ne doit pas apparaître dans la
	# maison d'un autre.
	occupied.append_array(grid.lairs)

	# Joueur : CHEZ LUI. Le mage commence au centre de sa maison et en sort par
	# la porte sud — c'est sa maison, pas une ligne de départ tirée au sort.
	# L'ancienne règle (« le dernier 15 % le plus reculé ») faisait apparaître
	# le personnage n'importe où dans le labyrinthe, sans lecture possible.
	grid.player_spawn = grid.house_center
	occupied.append(grid.player_spawn)

	# Ennemis : l'écart se mesure en distance de CHEMIN, pas à vol d'oiseau.
	# Deux cases séparées de 7 en Manhattan peuvent être à 30 par les couloirs —
	# ou à 7 tout rond. Avec un rayon de détection de 8, la version Manhattan
	# laissait régulièrement les ennemis repérer le joueur dès la première
	# seconde : aucun répit, partie perdue d'avance.
	var player_field := Pathfinder.distance_field(grid, [grid.player_spawn] as Array[Vector2i])

	# On exige d'abord le double du rayon de détection, puis on relâche : sur un
	# petit labyrinthe très bouclé, la contrainte idéale peut être introuvable.
	var thresholds: Array[int] = [
		config.enemy_detection_radius * 2,
		int(config.enemy_detection_radius * 1.5),
		config.enemy_detection_radius,
		0,
	]
	# Les ennemis sortent de leurs repaires, en alternant d'un coin à l'autre.
	# On ne cherche donc plus une case « assez loin du joueur » : c'est la
	# position des maisons qui décide, et elle est la même à chaque partie.
	if not grid.lairs.is_empty():
		for i in config.enemy_count:
			grid.enemy_spawns.append(grid.lairs[i % grid.lairs.size()])
		return

	for threshold in thresholds:
		if grid.enemy_spawns.size() >= config.enemy_count:
			break
		_try_place_enemies(grid, config, rng, player_field, occupied, threshold)


static func _try_place_enemies(grid: MazeGrid, config: LevelConfig, rng: RandomNumberGenerator,
		player_field: PackedInt32Array, occupied: Array[Vector2i], min_path_gap: int) -> void:
	var candidates: Array[Vector2i] = []
	for cell in grid.all_floor_cells():
		if occupied.has(cell) or grid.is_house(cell) or grid.enemy_spawns.has(cell):
			continue
		# Pas collé à la maison : un ennemi campant l'objectif est injouable.
		if grid.distance_at(cell) < 6:
			continue
		if Pathfinder.value_at(grid, player_field, cell) < min_path_gap:
			continue
		candidates.append(cell)

	# Un champ BFS par ennemi déjà placé, calculé UNE fois : sans ça on referait
	# un BFS complet pour chaque case candidate testée.
	var placed_fields: Array[PackedInt32Array] = []
	for placed in grid.enemy_spawns:
		placed_fields.append(Pathfinder.distance_field(grid, [placed] as Array[Vector2i]))

	_shuffle(candidates, rng)
	for cell in candidates:
		if grid.enemy_spawns.size() >= config.enemy_count:
			return
		var too_close := false
		for field in placed_fields:
			var gap := Pathfinder.value_at(grid, field, cell)
			if gap >= 0 and gap < ENEMY_MIN_GAP:
				too_close = true
				break
		if not too_close:
			grid.enemy_spawns.append(cell)
			placed_fields.append(Pathfinder.distance_field(grid, [cell] as Array[Vector2i]))


# --- Utilitaire ----------------------------------------------------------------
# Fisher-Yates sur NOTRE rng : Array.shuffle() utiliserait le générateur global
# et casserait la reproductibilité par graine.

static func _shuffle(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
