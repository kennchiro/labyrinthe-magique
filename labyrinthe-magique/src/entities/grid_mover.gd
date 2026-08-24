class_name GridMover
extends RefCounted

## Déplacement verrouillé sur la grille — le cœur du "game feel" du jeu.
##
## Pourquoi pas CharacterBody2D + colliders ? Parce que dans des couloirs d'une
## case de large, la physique produit exactement le défaut qu'on veut éviter :
## le personnage frotte contre les murs et "accroche" aux intersections.
## Ici la collision est un simple test de case : elle est exacte par construction,
## un mur ne peut pas être traversé, et le comportement est identique à 5 fps
## comme à 240 fps.
##
## Aucune dépendance au moteur de scène : testable en headless (voir tests/).

signal cell_entered(cell: Vector2i)

var grid: MazeGrid
## Case quittée, et case visée. `progress` interpole entre les deux.
var cell: Vector2i
var next_cell: Vector2i
var direction: Vector2i = Vector2i.ZERO
## Direction demandée par le joueur ou l'IA. Bufferisée : appuyer un peu trop
## tôt avant une intersection fonctionne quand même.
var desired_direction: Vector2i = Vector2i.ZERO
var progress: float = 0.0
## En cases par seconde.
var speed: float = 5.0
var stop_when_idle := true
## Faut-il s'arrêter quand plus aucune direction n'est demandée ?
##
## À false, on obtient le comportement Pac-Man : le personnage continue tout
## droit jusqu'au prochain mur même sans input. Pratique pour une IA, mais
## déroutant au clavier — on lâche la touche et le mage part sans nous.
## À true (le défaut), relâcher l'input arrête le personnage AU PROCHAIN CENTRE
## DE CASE : on garde l'alignement sur la grille, et une pression brève fait
## avancer d'exactement une case.


func _init(p_grid: MazeGrid, start_cell: Vector2i, p_speed: float) -> void:
	grid = p_grid
	cell = start_cell
	next_cell = start_cell
	speed = p_speed


func is_moving() -> bool:
	return direction != Vector2i.ZERO


func can_walk(target: Vector2i) -> bool:
	return grid != null and grid.is_floor_v(target)


## Case où le prochain choix de direction sera fait. Le joueur et l'IA doivent
## tester la praticabilité depuis CETTE case, pas depuis `cell` : en cours de
## trajet, `cell` est la case qu'on a déjà quittée.
func decision_cell() -> Vector2i:
	return next_cell if is_moving() else cell


## Position continue, en coordonnées de grille (float). Le rendu la convertit
## en pixels — c'est le seul point de contact avec l'affichage.
func grid_position() -> Vector2:
	return Vector2(cell).lerp(Vector2(next_cell), progress)


## Case dont on est physiquement le plus proche. `cell` seul ne suffit pas :
## en cours de trajet c'est la case DÉJÀ QUITTÉE, donc un joueur à 90 % du
## chemin vers un portail ne serait pas considéré comme dessus.
func nearest_cell() -> Vector2i:
	var p := grid_position().round()
	return Vector2i(int(p.x), int(p.y))


func teleport_to(target: Vector2i) -> void:
	cell = target
	next_cell = target
	direction = Vector2i.ZERO
	progress = 0.0


func update(delta: float) -> void:
	if desired_direction != Vector2i.ZERO:
		if is_moving() and desired_direction == -direction:
			# Demi-tour instantané, sans attendre le centre de la case.
			# C'est LA mécanique qui rend une poursuite jouable : sans elle, fuir
			# imposerait de finir sa case avant de pouvoir reculer, ce qui suffit
			# à se faire rattraper.
			var previous := cell
			cell = next_cell
			next_cell = previous
			direction = desired_direction
			progress = 1.0 - progress
		elif not is_moving():
			_try_start(desired_direction)

	if not is_moving():
		return

	progress += speed * delta

	# `while` et non `if` : à très basse fréquence d'images, plusieurs cases
	# peuvent être franchies dans la même frame. Sans ça, on traverserait un mur.
	while progress >= 1.0:
		progress -= 1.0
		cell = next_cell
		cell_entered.emit(cell)

		if desired_direction == Vector2i.ZERO and stop_when_idle:
			direction = Vector2i.ZERO
			next_cell = cell
			progress = 0.0
			break

		var chosen := direction
		if desired_direction != Vector2i.ZERO and can_walk(cell + desired_direction):
			chosen = desired_direction

		if can_walk(cell + chosen):
			direction = chosen
			next_cell = cell + chosen
		else:
			# Mur droit devant : arrêt net, pile au centre de la case.
			direction = Vector2i.ZERO
			next_cell = cell
			progress = 0.0
			break


func _try_start(dir: Vector2i) -> void:
	if dir == Vector2i.ZERO or not can_walk(cell + dir):
		return
	direction = dir
	next_cell = cell + dir
	progress = 0.0
