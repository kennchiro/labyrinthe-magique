extends SceneTree

## Ce que le joueur VOIT d'un coup porté ou encaissé.
##   godot --headless --path . --script res://tests/test_animation.gd
##
## Une capture ne tombe jamais sur la bonne frame d'un geste de 0,2 s, et aucun de
## ces défauts ne fait échouer une règle du jeu. Les vrais nœuds sont donc posés
## dans une salle vide et interrogés frame par frame.

const PLAYER_SCENE := preload("res://scenes/entities/player.tscn")
const ENEMY_SCENE := preload("res://scenes/entities/enemy.tscn")
const TILE := 32
const FRAME := 1.0 / 60.0

var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var grid := MazeGrid.new(9, 9)
	for c in 9:
		for r in 9:
			grid.set_cell(c, r, MazeGrid.Cell.FLOOR)

	_test_strike_faces_the_player(grid)
	_test_lunge_when_stopped(grid)
	_test_flash_on_staggered(grid)
	_test_rest_gives_way_to_walk(grid)
	_test_cast_turns_the_mage(grid)
	_test_hurt_blinks_then_ends(grid)
	_test_body_keeps_its_scale(grid)
	await _test_death_fade(grid)
	_test_swing_timing()
	_test_impact_pose(grid)

	print("")
	if _failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT")
	else:
		print("❌  %d ÉCHEC(S) :" % _failures.size())
		for f in _failures:
			print("   - ", f)
	quit(0 if _failures.is_empty() else 1)


func _fail(msg: String) -> void:
	_failures.append(msg)


func _enemy(grid: MazeGrid, cell: Vector2i, species := "goblin") -> Enemy:
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	root.add_child(enemy)
	enemy.setup_enemy(grid, cell, 3.0, TILE, 5, species, 100)
	return enemy


func _player(grid: MazeGrid, cell: Vector2i) -> Player:
	var player: Player = PLAYER_SCENE.instantiate()
	root.add_child(player)
	player.setup(grid, cell, 5.0, TILE)
	return player


## L'ennemi regarde le mage quand il frappe, même s'il marchait ailleurs.
func _test_strike_faces_the_player(grid: MazeGrid) -> void:
	for gap in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var enemy := _enemy(grid, Vector2i(4, 4))
		enemy.player_cell = Vector2i(4, 4) + gap
		enemy.strike()
		enemy._apply_frame()
		var wanted: Texture2D = enemy._textures[_key(gap)]
		if enemy.sprite.texture != wanted:
			_fail("le coup vers %s ne montre pas la bande %s" % [gap, _key(gap)])
		enemy.free()
	print("coup : l'ennemi regarde le mage dans les quatre directions")


## Le poursuivant qui frappe est ARRÊTÉ : l'élan ne doit pas dépendre de sa marche.
func _test_lunge_when_stopped(_grid: MazeGrid) -> void:
	# Une seule case praticable : sans ça, l'IA part en patrouille et s'éloigne.
	var cell := MazeGrid.new(9, 9)
	cell.set_cell(4, 4, MazeGrid.Cell.FLOOR)
	var enemy := _enemy(cell, Vector2i(4, 4))
	enemy.player_cell = Vector2i(5, 4)
	enemy.strike()
	var home := enemy.position.x
	var furthest := 0.0
	for i in 12:
		enemy._process(FRAME)
		furthest = maxf(furthest, enemy.position.x - home)
	if furthest < TILE * Enemy.STRIKE_LUNGE * 0.5:
		_fail("élan absent à l'arrêt : %.2f px" % furthest)
	enemy.free()
	print("élan : %.1f px vers le mage, ennemi à l'arrêt" % furthest)


## Tous les coups de la Terre ébranlent : ils doivent quand même faire un éclair.
func _test_flash_on_staggered(grid: MazeGrid) -> void:
	var enemy := _enemy(grid, Vector2i(4, 4))
	enemy.stagger(1.0)
	enemy.flash_hit()
	enemy._process(FRAME)
	if enemy.sprite.modulate != Enemy.HIT_FLASH:
		_fail("pas d'éclair sur une créature ébranlée : %s" % enemy.sprite.modulate)
	for i in 20:
		enemy._process(FRAME)
	if enemy.sprite.modulate == Enemy.HIT_FLASH:
		_fail("l'éclair ne s'éteint pas sur une créature ébranlée")
	enemy.free()
	print("éclair : visible et bref sur une créature ébranlée")


## Une créature qui repart ne glisse pas, bras levé, pendant son repos.
func _test_rest_gives_way_to_walk(grid: MazeGrid) -> void:
	var enemy := _enemy(grid, Vector2i(4, 4))
	enemy.player_cell = Vector2i(5, 4)
	enemy.strike()
	enemy._strike = 0.0
	if not enemy._showing_strike():
		_fail("le repos à l'arrêt doit garder le geste")
	enemy.mover.desired_direction = Vector2i.LEFT
	enemy.mover.update(FRAME)
	if enemy._showing_strike():
		_fail("le repos en marche garde la pose de coup")
	enemy.free()
	print("repos : le geste s'efface dès que la créature repart")


## Le mage se tourne vers sa cible, puis retrouve son sens de marche.
func _test_cast_turns_the_mage(grid: MazeGrid) -> void:
	var player := _player(grid, Vector2i(4, 4))
	player._facing = Vector2i.DOWN
	player.play_cast(player.position + Vector2(-3.0 * TILE, -TILE))
	if player._direction_key() != "left":
		_fail("cible à gauche : le mage montre %s" % player._direction_key())
	player.play_cast(player.position + Vector2(0.0, -3.0 * TILE))
	if player._direction_key() != "up":
		_fail("cible au-dessus : le mage montre %s" % player._direction_key())
	player._attack_left = 0.0
	if player._direction_key() != "down":
		_fail("après le sort : le mage montre %s" % player._direction_key())
	player.play_cast()
	if player._direction_key() != "down":
		_fail("sort sans cible : le mage doit garder son sens")
	player.free()
	print("sort : le mage se tourne vers sa cible, puis revient")


## L'invulnérabilité se voit, puis le mage redevient normal.
func _test_hurt_blinks_then_ends(grid: MazeGrid) -> void:
	var player := _player(grid, Vector2i(4, 4))
	player.play_hurt(1.0)
	player._process(FRAME)
	if player.sprite.modulate != Player.HURT_TINT:
		_fail("pas d'éclair rouge au coup encaissé")
	var saw_blink := false
	for i in 70:
		player._process(FRAME)
		saw_blink = saw_blink or is_equal_approx(player.sprite.modulate.a, Player.HURT_BLINK_ALPHA)
	if not saw_blink:
		_fail("aucun clignotement pendant le répit")
	if player.sprite.modulate != Color.WHITE:
		_fail("le mage reste teinté après le répit : %s" % player.sprite.modulate)
	player.free()
	print("touché : éclair, clignotement, retour à la normale")


## La respiration et l'élan oscillent autour de l'échelle de repos, sans dériver.
func _test_body_keeps_its_scale(grid: MazeGrid) -> void:
	var player := _player(grid, Vector2i(4, 4))
	player.play_cast()
	var rest := player._sprite_scale
	if rest == Vector2.ONE:
		_fail("échelle de repos jamais renseignée")
	for i in 600:
		player._process(FRAME)
		var ratio: float = player.sprite.scale.y / rest.y
		if absf(ratio - 1.0) > 0.1:
			_fail("le corps s'écarte de son échelle : x%.3f" % ratio)
			break
	if player.sprite.position != Vector2.ZERO:
		_fail("le mage à l'arrêt reste décollé du sol : %s" % player.sprite.position)
	player.free()
	print("corps : 10 s sans dérive d'échelle")


func _test_death_fade(grid: MazeGrid) -> void:
	var enemy := _enemy(grid, Vector2i(4, 4))
	var fade := DeathFade.new()
	fade.setup(enemy.sprite, enemy.position)
	if fade.frame != enemy.sprite.frame or fade.offset != enemy.sprite.offset:
		_fail("la dépouille ne reprend pas la pose à l'écran")
	root.add_child(fade)
	enemy.free()
	var left := int(ceil(DeathFade.DURATION * 60.0)) + 2
	for i in left:
		if is_instance_valid(fade):
			fade._process(FRAME)
	await process_frame
	if is_instance_valid(fade):
		_fail("la dépouille ne disparaît pas")
	print("mort : la dépouille s'efface et libère son nœud")


## Le coup ne touche qu'à l'impact, et seulement si le mage est encore à portée.
func _test_swing_timing() -> void:
	var swing := MeleeSwing.new()
	if swing.tick(FRAME, 2.0, 1.05, 0.2, 1.0) != MeleeSwing.Event.NONE:
		_fail("un coup part hors de portée")
	if swing.tick(FRAME, 1.0, 1.05, 0.2, 1.0) != MeleeSwing.Event.STARTED:
		_fail("le coup ne part pas au contact")
	var landed := MeleeSwing.Event.NONE
	var frames := 0
	while swing.is_winding_up():
		landed = swing.tick(FRAME, 1.0, 1.05, 0.2, 1.0)
		frames += 1
	if landed != MeleeSwing.Event.LANDED or absf(frames * FRAME - 0.2) > FRAME * 1.5:
		_fail("impact après %d images, résultat %d" % [frames, landed])
	var dodged := MeleeSwing.new()
	dodged.tick(FRAME, 1.0, 1.05, 0.2, 1.0)
	var result := MeleeSwing.Event.NONE
	while dodged.is_winding_up():
		result = dodged.tick(FRAME, 2.5, 1.05, 0.2, 1.0)
	if result != MeleeSwing.Event.MISSED:
		_fail("le mage parti à 2,5 cases n'esquive pas")
	var cancelled := MeleeSwing.new()
	cancelled.tick(FRAME, 1.0, 1.05, 0.2, 1.0)
	cancelled.cancel()
	if cancelled.tick(FRAME, 1.0, 1.05, 0.2, 1.0) != MeleeSwing.Event.NONE:
		_fail("un coup annulé touche quand même, ou repart avant son délai")
	print("coup : armé au contact, porté à l'impact, esquivable")


## L'image d'impact est à l'écran à l'instant où le coup touche, pour chaque espèce.
func _test_impact_pose(grid: MazeGrid) -> void:
	for species in Bestiary.SPECIES.keys():
		var enemy := _enemy(grid, Vector2i(4, 4), species)
		enemy.player_cell = Vector2i(5, 4)
		enemy.strike()
		# Une fraction de frame après l'impact : pile dessus, l'arrondi décide.
		enemy._strike_rest -= Bestiary.windup(species) + 0.001
		enemy._apply_frame()
		var wanted: int = enemy._attack_poses[Bestiary.impact_pose(species) - 1]
		if enemy.sprite.frame != wanted:
			_fail("%s : image %d à l'impact, %d attendue" % [species, enemy.sprite.frame, wanted])
		enemy.free()
	print("coup : l'image d'impact coïncide avec les dégâts, pour les onze")


func _key(direction: Vector2i) -> String:
	match direction:
		Vector2i.LEFT:
			return "left"
		Vector2i.RIGHT:
			return "right"
		Vector2i.UP:
			return "up"
	return "down"
