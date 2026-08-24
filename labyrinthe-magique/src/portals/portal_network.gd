class_name PortalNetwork
extends RefCounted

## Choix de la destination d'une téléportation. Logique pure, sans état.
##
## LA RÈGLE DES 20 % — et pourquoi elle est mesurable et non aléatoire.
##
## "Progression avantageuse" ne peut pas être un tirage au sort : il faut savoir
## si une destination rapproche vraiment DE CE QUE LE JOUEUR CHERCHE. C'est un
## champ de distances BFS qui le dit.
##
## Depuis que l'objectif est la collecte, ce champ n'est plus forcément celui de
## la maison : tant qu'il reste une gemme, c'est ELLE la cible, et un portail qui
## rapproche de la maison peut très bien éloigner de la gemme. Mesurer le gain
## sur la maison ferait mentir l'interface pendant les trois quarts de la partie.
## Le champ est donc passé par l'appelant ; à défaut, on retombe sur la maison
## (MazeGrid.distance_to_house), ce qui garde les mesures de tests inchangées.
##
##   20 % → destination à moins de 60 % de la distance actuelle : vrai gain.
##   80 % → destination COMPRISE entre 0,6× et 1,8× la distance actuelle.
##
## Le plafond à 1,8× évite les téléportations catastrophiques. Mais le PLANCHER
## à 0,6× dans la branche 80 % est tout aussi important : sans lui, un tirage
## "neutre" tomberait souvent sur un gros gain par hasard, et le taux réel de
## progression avantageuse monterait à plus de 50 %. La règle des 20 % ne
## voudrait plus rien dire, et le dilemme du joueur disparaîtrait.

const ADVANTAGE_CHANCE := 0.20
## Une destination est "avantageuse" en dessous de ce facteur de distance.
const ADVANTAGE_FACTOR := 0.6
## Au-delà, c'est un retour en arrière catastrophique : on l'exclut.
const MAX_SETBACK_FACTOR := 1.8
## Le joueur ne doit jamais réapparaître dans les bras d'un ennemi.
const PLAYER_SAFE_RADIUS := 5
## Symétriquement, un ennemi ne doit jamais réapparaître collé au joueur :
## une mort instantanée et incompréhensible n'est pas de la tension.
const ENEMY_SAFE_RADIUS := 4
## Probabilité qu'un ennemi qui traverse un portail décide de l'emprunter.
const ENEMY_USE_CHANCE := 0.5
## Et probabilité qu'il vise alors le portail le plus proche du joueur.
const ENEMY_SMART_CHANCE := 0.20


## Vrai quand AUCUNE destination ne tient sous le plafond de 1,8×, c'est-à-dire
## quand le portail de départ est déjà plus proche de la maison que tous les
## autres. Ce n'est pas un défaut : c'est structurel. Mais le joueur mérite d'en
## être averti avant de parier — l'interface s'en sert pour changer son message.
static func is_pure_gamble(grid: MazeGrid, from: Vector2i,
		objective_field: PackedInt32Array = PackedInt32Array()) -> bool:
	var current := _distance(grid, objective_field, from)
	var ceiling := int(current * MAX_SETBACK_FACTOR)
	for portal in _other_portals(grid, from):
		if _distance(grid, objective_field, portal) <= ceiling:
			return false
	return true


## Retourne {"cell": Vector2i, "advantageous": bool}.
static func pick_for_player(grid: MazeGrid, from: Vector2i, rng: RandomNumberGenerator,
		enemy_field: PackedInt32Array,
		objective_field: PackedInt32Array = PackedInt32Array()) -> Dictionary:
	var others := _other_portals(grid, from)
	if others.is_empty():
		return {"cell": from, "advantageous": false}

	var safe := _filter_far_from(grid, others, enemy_field, PLAYER_SAFE_RADIUS)
	var current := _distance(grid, objective_field, from)
	var advantage_max := int(current * ADVANTAGE_FACTOR)

	if rng.randf() < ADVANTAGE_CHANCE:
		var gains := _filter_distance(grid, safe, -1, advantage_max, objective_field)
		if not gains.is_empty():
			return _result(grid, gains[rng.randi_range(0, gains.size() - 1)], current, objective_field)
		# Aucun portail ne fait mieux : on offre au moins le plus proche possible.
		var best: Vector2i = safe[0]
		for p in safe:
			if _distance(grid, objective_field, p) < _distance(grid, objective_field, best):
				best = p
		return _result(grid, best, current, objective_field)

	var ceiling := int(current * MAX_SETBACK_FACTOR)

	var neutral := _filter_distance(grid, safe, advantage_max, ceiling, objective_field)
	if not neutral.is_empty():
		return _result(grid, neutral[rng.randi_range(0, neutral.size() - 1)], current, objective_field)

	# Plus aucune destination "neutre" : les seules qui tiennent sous le plafond
	# sont de gros gains. On les prend quand même. Le plafond de sécurité prime
	# sur le refus d'offrir un gain hors de la branche 20 % — envoyer le joueur
	# à l'autre bout de la carte alors qu'une destination raisonnable existait
	# serait exactement la téléportation catastrophique qu'on veut interdire.
	var bounded := _filter_distance(grid, safe, -1, ceiling, objective_field)
	if not bounded.is_empty():
		return _result(grid, bounded[rng.randi_range(0, bounded.size() - 1)], current, objective_field)

	# Vraiment aucune destination sous le plafond : le joueur est déjà plus
	# proche de la maison que tout le réseau. On limite alors les dégâts à la
	# moitié la plus proche, plutôt qu'un tirage dans tout le labyrinthe.
	return _result(grid, _least_bad(grid, safe, rng, objective_field), current, objective_field)


## Destination d'un ennemi. Vector2i.ZERO s'il ne prend pas le portail.
static func pick_for_enemy(grid: MazeGrid, from: Vector2i, rng: RandomNumberGenerator,
		player_field: PackedInt32Array) -> Vector2i:
	if rng.randf() >= ENEMY_USE_CHANCE:
		return Vector2i.ZERO

	var others := _other_portals(grid, from)
	if others.is_empty():
		return Vector2i.ZERO

	var safe := _filter_far_from(grid, others, player_field, ENEMY_SAFE_RADIUS)

	# C'est cette branche qui produit l'effet recherché : le joueur croit avoir
	# semé son poursuivant et le retrouve devant lui, sorti d'un autre portail.
	if rng.randf() < ENEMY_SMART_CHANCE:
		var closest: Vector2i = safe[0]
		var best := Pathfinder.value_at(grid, player_field, closest)
		for p in safe:
			var d := Pathfinder.value_at(grid, player_field, p)
			if d >= 0 and (best < 0 or d < best):
				best = d
				closest = p
		return closest

	return safe[rng.randi_range(0, safe.size() - 1)]


# --- Helpers -------------------------------------------------------------------

static func _other_portals(grid: MazeGrid, from: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for p in grid.portals:
		if p != from:
			out.append(p)
	return out


## Garde les cases à au moins `radius` de distance de chemin des sources du champ.
## Repli sur la liste complète plutôt que de renvoyer vide : mieux vaut une
## destination risquée qu'une téléportation qui ne se déclenche pas.
static func _filter_far_from(grid: MazeGrid, cells: Array[Vector2i],
		field: PackedInt32Array, radius: int) -> Array[Vector2i]:
	if field.is_empty():
		return cells
	var out: Array[Vector2i] = []
	for cell in cells:
		var d := Pathfinder.value_at(grid, field, cell)
		if d < 0 or d >= radius:
			out.append(cell)
	return out if not out.is_empty() else cells


## Distance à l'objectif courant. Champ vide -> la maison, comme avant la
## collecte : une seule fonction sert donc les deux régimes.
static func _distance(grid: MazeGrid, field: PackedInt32Array, cell: Vector2i) -> int:
	if field.is_empty():
		return grid.distance_at(cell)
	return Pathfinder.value_at(grid, field, cell)


## Bornes inclusives sur la distance à l'objectif ; -1 = pas de borne.
static func _filter_distance(grid: MazeGrid, cells: Array[Vector2i],
		above: int, below: int, field: PackedInt32Array) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for cell in cells:
		var d := _distance(grid, field, cell)
		if above >= 0 and d <= above:
			continue
		if below >= 0 and d > below:
			continue
		out.append(cell)
	return out


## Tire au hasard dans la moitié la plus proche de l'objectif : le recul reste
## imprévisible, mais borné.
static func _least_bad(grid: MazeGrid, cells: Array[Vector2i], rng: RandomNumberGenerator,
		field: PackedInt32Array) -> Vector2i:
	var sorted := cells.duplicate()
	sorted.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return _distance(grid, field, a) < _distance(grid, field, b))
	var pool_size := maxi(1, sorted.size() / 2)
	return sorted[rng.randi_range(0, pool_size - 1)]


static func _result(grid: MazeGrid, cell: Vector2i, current: int,
		field: PackedInt32Array) -> Dictionary:
	return {
		"cell": cell,
		"advantageous": _distance(grid, field, cell) <= int(current * ADVANTAGE_FACTOR),
	}
