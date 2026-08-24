class_name TeleportSystem
extends RefCounted

## Orchestre les téléportations : cooldowns, invulnérabilité, exécution.
##
## Opère sur des GridMover et NON sur des Node : le système est donc utilisable
## en headless. C'est ce qui permet à tests/test_balance.gd de simuler des
## parties avec portails en utilisant EXACTEMENT le code du jeu, plutôt qu'une
## réimplémentation qui finirait par diverger de la vraie règle.

signal teleported(mover: GridMover, from_cell: Vector2i, to_cell: Vector2i, advantageous: bool)

## Empêche l'aller-retour infini entre deux portails.
const COOLDOWN := 1.5
## Le joueur ne peut pas être attrapé juste après avoir réapparu.
const INVULNERABILITY := 0.6

var grid: MazeGrid

var _rng := RandomNumberGenerator.new()
var _cooldowns := {}       # instance_id -> secondes restantes
var _invulnerable := {}    # instance_id -> secondes restantes


func _init(p_grid: MazeGrid, rng_seed: int = 0) -> void:
	grid = p_grid
	if rng_seed == 0:
		_rng.randomize()
	else:
		_rng.seed = rng_seed


func update(delta: float) -> void:
	_tick(_cooldowns, delta)
	_tick(_invulnerable, delta)


## La case "sous les pieds" : en cours de trajet, mover.cell est la case déjà
## quittée. On veut celle dont on est le plus proche.
func is_on_portal(mover: GridMover) -> bool:
	return grid.portals.has(mover.nearest_cell())


func cooldown_left(mover: GridMover) -> float:
	return float(_cooldowns.get(mover.get_instance_id(), 0.0))


func is_invulnerable(mover: GridMover) -> bool:
	return float(_invulnerable.get(mover.get_instance_id(), 0.0)) > 0.0


func grant_invulnerability(mover: GridMover, seconds: float) -> void:
	var key := mover.get_instance_id()
	_invulnerable[key] = maxf(float(_invulnerable.get(key, 0.0)), seconds)


func can_teleport(mover: GridMover) -> bool:
	return is_on_portal(mover) and cooldown_left(mover) <= 0.0


## Téléportation volontaire du joueur. Retourne false si elle n'a pas eu lieu.
## `objective_field` : champ de distances vers ce que le joueur cherche en ce
## moment (gemme ou maison). Vide -> la maison, cf. PortalNetwork.
func try_teleport_player(mover: GridMover, enemy_cells: Array[Vector2i],
		objective_field: PackedInt32Array = PackedInt32Array()) -> bool:
	if not can_teleport(mover):
		return false
	var from := mover.nearest_cell()
	var enemy_field := Pathfinder.distance_field(grid, enemy_cells)
	var choice := PortalNetwork.pick_for_player(grid, from, _rng, enemy_field, objective_field)
	var destination: Vector2i = choice["cell"]
	if destination == from:
		return false
	_execute(mover, from, destination, choice["advantageous"])
	_invulnerable[mover.get_instance_id()] = INVULNERABILITY
	return true


## Téléportation automatique d'un ennemi, avec son tirage d'utilisation.
func try_teleport_enemy(mover: GridMover, player_field: PackedInt32Array) -> bool:
	if not can_teleport(mover):
		return false
	var from := mover.nearest_cell()
	var destination := PortalNetwork.pick_for_enemy(grid, from, _rng, player_field)
	if destination == Vector2i.ZERO or destination == from:
		# Cooldown quand même : sinon on relancerait le tirage à chaque frame
		# tant que l'ennemi reste sur la case du portail.
		_cooldowns[mover.get_instance_id()] = COOLDOWN
		return false
	_execute(mover, from, destination, false)
	return true


func _execute(mover: GridMover, from: Vector2i, to: Vector2i, advantageous: bool) -> void:
	mover.teleport_to(to)
	_cooldowns[mover.get_instance_id()] = COOLDOWN
	teleported.emit(mover, from, to, advantageous)


static func _tick(timers: Dictionary, delta: float) -> void:
	for key in timers.keys():
		var remaining: float = timers[key] - delta
		if remaining <= 0.0:
			timers.erase(key)
		else:
			timers[key] = remaining
