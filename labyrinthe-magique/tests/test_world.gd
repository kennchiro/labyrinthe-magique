extends SceneTree

## La vue en volume : elle ne doit RIEN montrer de moins que le jeu 2D, et ce qui est
## peint sur le sol doit tomber exactement sur sa case.
##
##   godot --headless --path . --script res://tests/test_world.gd
##
## ⚠️ Ces chiffres se vérifient sans image : ce qui se juge à l'œil reste à capturer
## avec `--screenshot`.

const LEVEL_SCENE := preload("res://scenes/level.tscn")

var _failures := 0


func _initialize() -> void:
	await process_frame
	_test_camera_rules()
	_test_every_stage_has_walls()
	var host := Node.new()
	root.add_child(host)
	var level: Level = LEVEL_SCENE.instantiate()
	host.add_child(level)
	var world := WorldStage.new()
	host.add_child(world)
	world.adopt(level)
	level.world_stage = world
	level.load_level(LevelConfig.for_stage(1, 1), CharacterCatalog.fire(), 77)
	for i in 3:
		await process_frame
	_test_canvas_lines_up(world, level)
	_test_canvas_covers_the_view(world, level)
	_test_tap_finds_its_cell(world, level)
	_test_entities_stand_up(level)
	_test_monument_stands(world, level)
	_test_wall_rebuild(world, level)
	print("ÉCHECS : %d" % _failures if _failures > 0 else "TOUS LES TESTS PASSENT")
	quit(1 if _failures > 0 else 0)


func _reaches_corner(outlines: Array) -> bool:
	for outline: PackedVector2Array in outlines:
		for point in outline:
			if (point.x == 0.0 or point.x == 1.0) and (point.y == 0.0 or point.y == 1.0):
				return true
	return false


func _check(condition: bool, label: String) -> void:
	print(("ok    " if condition else "ÉCHEC ") + label)
	if not condition:
		_failures += 1


## Le jeu 2D montre 11 rangées, 5,5 de chaque côté du mage : on verrait sinon venir les
## poursuivants plus tard. La haie de devant ne doit pas non plus couvrir des pieds.
func _test_camera_rules() -> void:
	_check(CameraRules.rows_south() >= 5.5, "au moins 5,5 rangées au sud (%.2f)" % CameraRules.rows_south())
	_check(CameraRules.rows_north() >= 5.5, "au moins 5,5 rangées au nord (%.2f)" % CameraRules.rows_north())


## Dix planches, seize pièces chacune, deux variantes : une silhouette vide ferait un
## trou dans le labyrinthe de ce stage-là seulement. Et les pieds restent visibles.
func _test_every_stage_has_walls() -> void:
	var grid := MazeGenerator.generate(LevelConfig.for_stage(1, 1), 77)
	for stage in range(1, LevelConfig.STAGE_COUNT + 1):
		var view := MazeView3D.new()
		view.build(grid, stage, StageMood.of(stage))
		var complete := true
		for mask in 16:
			if view.outline_of(mask, 0).is_empty():
				complete = false
		_check(complete and view.triangle_count > 500,
			"stage %d : 16 pièces, %d triangles" % [stage, view.triangle_count])
		# Une croix face au sol garde ses encoches : une plaque carrée dépasserait des bras
		# voisins, sans flanc dessous. Entourée de haies, elle se referme.
		_check(StageMood.MOTION.has(stage) and Ambience.AIR.has(stage),
			"stage %d : la carte a son mouvement et son air" % stage)
		_check(not _reaches_corner(view.outline_of(15, 0)) and _reaches_corner(view.outline_of(15, 0, 15)),
			"stage %d : un carrefour n'a pas de coins en surplomb" % stage)
		var bar: PackedVector2Array = view.outline_of(5, 0)[0]
		var inset := 1.0
		for point in bar:
			inset = minf(inset, point.x)
		_check(CameraRules.worst_hidden_floor() < 0.5 + inset,
			"stage %d : pieds visibles (%.2f masqué pour %.2f de marge)" % [
				stage, CameraRules.worst_hidden_floor(), 0.5 + inset])
		view.free()


## Le point du monde lu dans la texture doit tomber, sur le quadrilatère couché, à
## l'endroit de ce même monde. Toute erreur ici décale TOUS les personnages de leur case.
func _test_canvas_lines_up(world: WorldStage, level: Level) -> void:
	var cell_centre := level.player.position
	var on_canvas := level.get_canvas_transform() * cell_centre
	var uv := on_canvas / Vector2(world._canvas.size)
	var plane := (world._ground.mesh as PlaneMesh).size
	var corner := Vector2(world._ground.position.x, world._ground.position.z) - plane * 0.5
	var on_plane := (corner + uv * plane) * WorldStage.CELL_PIXELS
	_check(on_plane.distance_to(cell_centre) < 0.51,
		"la texture tombe sur sa case (écart %.2f px)" % on_plane.distance_to(cell_centre))


## Les quatre coins de l'écran doivent viser le sol DANS la texture.
func _test_canvas_covers_the_view(world: WorldStage, level: Level) -> void:
	var span := Vector2(root.get_visible_rect().size)
	var plane := (world._ground.mesh as PlaneMesh).size
	var centre := Vector2(world._ground.position.x, world._ground.position.z)
	var area := Rect2(centre - plane * 0.5, plane)
	var inside := true
	for corner in [Vector2.ZERO, Vector2(span.x, 0.0), span, Vector2(0.0, span.y)]:
		var hit: Vector2 = world.screen_to_world(corner) / WorldStage.CELL_PIXELS
		if not area.has_point(hit):
			inside = false
			print("      coin %s hors texture : %s dans %s" % [corner, hit, area])
	_check(inside, "la texture couvre tout l'écran")


## Le chemin du doigt : la case à l'écran, relue depuis l'écran, est la même case.
func _test_tap_finds_its_cell(world: WorldStage, level: Level) -> void:
	var exact := true
	for cell: Vector2i in level.grid.all_floor_cells():
		var at := level.maze_renderer.cell_to_world(cell)
		if level.to_screen(at).distance_to(root.get_visible_rect().get_center()) > 200.0:
			continue
		if level.maze_renderer.world_to_cell(world.screen_to_world(level.to_screen(at))) != cell:
			exact = false
	_check(exact, "un tap retrouve la case visée")


func _test_entities_stand_up(level: Level) -> void:
	_check(is_equal_approx(level.player.scale.y, CameraRules.stand_scale()),
		"le mage est redressé (x%.2f)" % level.player.scale.y)
	_check(is_equal_approx(level.player.scale.x, 1.0), "sans être élargi")


## L'îlot debout : face à la caméra, sa roche au-dessus du sol, et plus aucun double couché.
func _test_monument_stands(world: WorldStage, level: Level) -> void:
	var panel: Sprite3D = null
	for child in world._glows.get_children():
		if child is Sprite3D and child.texture == level.house.sprite.texture:
			panel = child
	_check(panel != null, "l'îlot est debout dans la scène 3D")
	if panel == null:
		return
	_check(not level.house.sprite.visible, "sans son double couché sur le sol")
	var facing := panel.global_transform.basis.z.dot(world.camera.global_transform.basis.z)
	_check(facing > 0.999, "il fait face à la caméra (%.3f)" % facing)
	var below := (panel.texture.get_height() * 0.5 - panel.offset.y) * panel.pixel_size
	var lowest := House.PANEL_LIFT - House.BOB_HEIGHT - below * panel.global_transform.basis.y.y
	_check(lowest > 0.0, "sa roche reste au-dessus du sol (%.2f)" % lowest)
	var locked_tint := panel.modulate
	level.house.set_locked(0)
	_check(panel.modulate == House.TINT_OPEN and locked_tint == House.TINT_LOCKED,
		"il passe de la teinte scellée à la teinte ouverte")
	_check(panel.get_child_count() == 1, "son portail est posé sur lui")
	level.house.set_locked(1)
	for stage in range(1, 11):
		var image: Texture2D = load("res://assets/stages/props/stage_%d/maison/maison_0.png" % stage)
		var portal: Vector4 = House.PORTALS[stage]
		var bounds := Rect2(Vector2.ZERO, image.get_size())
		var ellipse := Rect2(portal.x - portal.z, portal.y - portal.w, portal.z * 2.0, portal.w * 2.0)
		_check(bounds.encloses(ellipse), "le portail du stage %d tombe dans son image" % stage)


## Un mur levé par la Terre doit apparaître en volume, sinon on bute sur du vide.
func _test_wall_rebuild(world: WorldStage, level: Level) -> void:
	var before := world.maze.triangle_count
	var cell: Vector2i = level.grid.all_floor_cells()[0]
	level.grid.set_cell(cell.x, cell.y, MazeGrid.Cell.WALL)
	var started := Time.get_ticks_usec()
	level.combat.wall_raised.emit(cell)
	var spent := (Time.get_ticks_usec() - started) / 1000.0
	_check(world.maze.triangle_count != before, "un mur levé change les haies (%d -> %d triangles)" % [
		before, world.maze.triangle_count])
	level.grid.set_cell(cell.x, cell.y, MazeGrid.Cell.FLOOR)
	level.combat.wall_fell.emit(cell)
	_check(world.maze.triangle_count == before, "un mur tombé les rend à l'identique")
	print("      reconstruction : %.1f ms" % spent)
