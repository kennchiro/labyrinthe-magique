class_name HeroTestArena
extends RefCounted

## Placement reproductible pour vérifier les vrais sorts dans une vraie scène Level.
static func prepare(game: GameManager) -> bool:
	var level := game.level
	level.set_process(false)
	level.player.set_process(false)
	level.player.set_physics_process(false)
	var origin := Vector2i(-1, -1)
	var best := INF
	var center := Vector2(level.grid.cols, level.grid.rows) * 0.5
	for cell in level.grid.all_floor_cells():
		if level.grid.is_house(cell) or not level.grid.is_floor_v(cell + Vector2i.RIGHT) or not level.grid.is_floor_v(cell + Vector2i.RIGHT * 2):
			continue
		var distance := Vector2(cell).distance_squared_to(center)
		if distance < best:
			best = distance
			origin = cell
	if origin.x < 0 or level.enemies.is_empty():
		return false
	level.player.mover.teleport_to(origin)
	level.player.snap_to_mover()
	level.player._facing = Vector2i.RIGHT
	for enemy in level.enemies:
		enemy.set_process(false)
		enemy.set_physics_process(false)
		enemy.health.current = 0
	var target := level.enemies[0]
	target.set_dead(false)
	target.mover.teleport_to(origin + Vector2i.RIGHT)
	target.mover.direction = Vector2i.LEFT
	target.health.maximum = 20000
	target.health.current = 20000
	target.health.shield = 0
	target.health.plates = 0
	target.health.immune = false
	target.position = level.maze_renderer.cell_to_world(origin + Vector2i.RIGHT)
	level._refresh_ai()
	level._refresh_context()
	level._update_camera(true)
	return true
