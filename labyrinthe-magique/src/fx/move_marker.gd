class_name MoveMarker
extends Node2D

## Marque de destination du mode « toucher le chemin » : un anneau qui pulse sur
## la case visée, comme le clic de déplacement d'un Dota. Sans elle, on ne sait
## pas si le jeu a entendu le tap — et un mage qui part avec un temps de retard
## se lit comme une entrée perdue.
##
## Il se retire TOUT SEUL dès que l'ordre s'achève ou change : c'est lui qui
## surveille le joueur, et non le Level qui doit penser à le nettoyer sur chacun
## de ses chemins d'annulation (arrivée, entrée manuelle, téléportation).

const COLOR := Color(0.62, 0.94, 1.0)

var _player: Player = null
var _cell := Vector2i.ZERO
var _tile := 32.0
var _time := 0.0


func setup(player: Player, cell: Vector2i, tile: float) -> void:
	_player = player
	_cell = cell
	_tile = tile


func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player) \
			or not _player.has_path() or _player.path_goal() != _cell:
		queue_free()
		return
	_time += delta
	queue_redraw()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_time * 6.0)
	draw_arc(Vector2.ZERO, _tile * (0.30 + 0.10 * pulse), 0.0, TAU, 24,
		Color(COLOR.r, COLOR.g, COLOR.b, 0.50 + 0.30 * pulse), 3.0)
	draw_circle(Vector2.ZERO, _tile * 0.08, Color(COLOR.r, COLOR.g, COLOR.b, 0.85))
