class_name CombatContext
extends RefCounted

## Photo de l'état du monde passée au CombatSystem à chaque frame.
##
## Le système de combat ne connaît NI le Level NI le moindre Node : il reçoit des
## cases, des points de vie et un champ de distances. C'est ce qui permet à la
## simulation d'équilibrage de faire combattre des joueurs fictifs en headless
## avec exactement les règles du jeu.

var grid: MazeGrid
var player_cell: Vector2i = Vector2i.ZERO
## Direction regardée : sert aux sorts qui partent devant (mur, translation).
var player_facing: Vector2i = Vector2i.DOWN
var enemy_cells: Array[Vector2i] = []
var enemy_health: Array[Health] = []
## Index à partir duquel les entrées ne sont plus des ennemis mais des
## STRUCTURES immobiles — les repaires, sur les niveaux où il faut les abattre.
## -1 quand il n'y en a pas.
##
## Elles vivent dans les mêmes tableaux que les ennemis, et ce n'est pas de la
## paresse : projectiles, dégâts, portée et zone marchent alors sur elles sans
## une ligne de code en double, et la simulation d'équilibrage les voit comme
## le jeu les voit. Le seul écart tient en une règle de ciblage — voir
## `CombatSystem.find_target`.
var structures_from := -1


## Cette cible est-elle une maison plutôt qu'une créature ?
func is_structure(index: int) -> bool:
	return structures_from >= 0 and index >= structures_from
## Champ de distances BFS depuis le joueur — déjà calculé par le Level pour l'IA,
## on le réutilise au lieu d'en refaire un.
var player_field := PackedInt32Array()


func _init(p_grid: MazeGrid) -> void:
	grid = p_grid


func enemy_alive(index: int) -> bool:
	return index >= 0 and index < enemy_health.size() and enemy_health[index].is_alive()
