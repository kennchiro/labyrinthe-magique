extends SceneTree

## Le gabarit d'animation, et ce qu'il ne doit PAS toucher.
##   godot --headless --path . --script res://tests/test_motion.gd

const PLAYER_SCENE := preload("res://scenes/entities/player.tscn")
const TILE := 32
const FRAME := 1.0 / 60.0
## Les vrais personnages qui l'ont adopté, après essai du joueur.
const WITH_MOTION := ["demon"]

var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_profile()
	_test_others_untouched()
	await _test_walk()
	await _test_strike()
	if _failures.is_empty():
		print("TOUS LES TESTS PASSENT")
		quit(0)
		return
	for failure in _failures:
		print("ÉCHEC : ", failure)
	quit(1)


func _fail(message: String) -> void:
	_failures.append(message)


func _test_profile() -> void:
	var profile := MotionProfile.from_data({})
	if absf(profile.attack_duration() - 0.317) > 0.001:
		_fail("durée d'attaque : %.3f" % profile.attack_duration())
	var last := 0
	for i in 40:
		var pose := profile.attack_pose(float(i) * 0.01)
		if pose < last:
			_fail("le geste revient en arrière")
		last = pose
	if last != profile.attack_ms.size() - 1:
		_fail("le geste ne va pas au bout : %d" % last)
	if profile.attack_pose(0.067) != MotionProfile.IMPACT_POSE:
		_fail("l'impact n'arrive pas à 67 ms")
	if profile.lunge_at(0.02) != 0.0 or profile.lunge_at(profile.impact_time()) != 1.0:
		_fail("la poussée n'attend pas l'impact")
	if MotionProfile.from_data(null) != null:
		_fail("un personnage sans clé motion doit rester sans gabarit")
	var tuned := MotionProfile.from_data({"attack_ms": [10, 20], "impact_pose": 1})
	if tuned.attack_pose(0.015) != 1 or absf(tuned.impact_time() - 0.01) > 0.0001:
		_fail("les durées du descripteur sont ignorées")
	if not profile.dust or MotionProfile.from_data({"dust": false}).dust:
		_fail("la poussière ne suit pas le descripteur")


## Seuls les personnages déjà validés ont le gabarit, et le Héros d'essai n'en est pas un vrai.
func _test_others_untouched() -> void:
	for stats in CharacterCatalog.all():
		if stats.id == CharacterCatalog.TEST:
			_fail("le Héros d'essai compte parmi les vrais personnages")
		var text := FileAccess.get_file_as_string("res://assets/characters/%s/frames.json" % stats.id)
		if (JSON.parse_string(text) as Dictionary).has("motion") and stats.id not in WITH_MOTION:
			_fail("%s a reçu un gabarit" % stats.id)
	if CharacterCatalog.by_id(CharacterCatalog.TEST).id != CharacterCatalog.TEST:
		_fail("--character test ne donne pas le Héros d'essai")


func _player() -> Player:
	var grid := MazeGrid.new(9, 9)
	for y in range(1, 8):
		for x in range(1, 8):
			grid.set_cell(x, y, MazeGrid.Cell.FLOOR)
	var player: Player = PLAYER_SCENE.instantiate()
	player.set_character(CharacterCatalog.test_hero())
	root.add_child(player)
	player.setup(grid, Vector2i(1, 4), 5.1, TILE)
	return player


## Les pieds restent sur la case, et le corps garde le contact avec son ombre.
func _test_walk() -> void:
	var player := _player()
	player.debug_direction = Vector2.RIGHT
	var frames := {}
	var low := 0.0
	var seen := {}
	var heights := {}
	for pose in range(1, 9):
		seen[pose] = 0
		heights[pose] = 0.0
	for i in 40:
		player._process(FRAME)
		await process_frame
		frames[player.sprite.frame] = true
		if absf(player.sprite.skew) > 0.01:
			_fail("il penche dans sa course de profil : %.3f" % player.sprite.skew)
		low = minf(low, player.sprite.position.y)
		if seen.has(player.sprite.frame):
			seen[player.sprite.frame] += 1
			heights[player.sprite.frame] += player.sprite.position.y
		if player.position != player._world_position():
			_fail("le gabarit a déplacé le nœud")
	for pose in seen:
		heights[pose] /= maxf(1.0, float(seen[pose]))
	if frames.size() < 8:
		_fail("seulement %d images de course jouées" % frames.size())
	if low >= -1.0 or low < -2.5:
		_fail("rebond de profil de %.1f" % low)
	# Le corps est plus bas pieds écartés (images 2, 3, 6, 7 du cycle) que pieds rapprochés.
	var wide: float = (heights[2] + heights[3] + heights[6] + heights[7]) / 4.0
	var narrow: float = (heights[1] + heights[4] + heights[5] + heights[8]) / 4.0
	if wide <= narrow:
		_fail("rebond à contretemps : %.2f pieds écartés, %.2f rapprochés" % [wide, narrow])
	player.debug_direction = Vector2.ZERO
	for i in 90:
		player._process(FRAME)
		await process_frame
	if absf(player.sprite.skew) > 0.01:
		_fail("la penchée ne retombe pas : %.3f" % player.sprite.skew)
	player.queue_free()


## L'impact arrive à son heure, avec son arc, et une seule fois par geste.
func _test_strike() -> void:
	var player := _player()
	player.play_cast(player.position + Vector2.RIGHT * float(TILE) * 3.0)
	var arcs := 0
	var at_impact := 0.0
	var time := 0.0
	var impact_pose_seen := false
	var leaned := false
	for i in 30:
		player._process(FRAME)
		await process_frame
		time += FRAME
		var count := 0
		for child in player.get_children():
			if child is SlashArc:
				count += 1
		if count > arcs:
			at_impact = time
		arcs = maxi(arcs, count)
		leaned = leaned or absf(player.sprite.skew) > 0.02
		impact_pose_seen = impact_pose_seen or player.sprite.frame == 9 + MotionProfile.IMPACT_POSE
	if arcs != 1:
		_fail("%d arcs de lame au lieu d'un" % arcs)
	if absf(at_impact - 0.067) > 0.04:
		_fail("l'arc part à %.3f s" % at_impact)
	if not leaned:
		_fail("le coup ne penche pas le buste")
	if not impact_pose_seen:
		_fail("l'image d'impact n'est jamais montrée")
	player.queue_free()
