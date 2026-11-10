class_name ArenaScreen
extends Node

## L'ARÈNE de bout en bout : la préparation, le match, le verdict. C'est un écran de `GameFlow`
## comme la sélection ou le jeu.
##
## Le match (`ArenaMatch`) décide, la vue (`ArenaView`) montre le terrain, le HUD (`ArenaHud`)
## affiche le reste : les trois couches de la règle n° 2. L'interface vit sur un `CanvasLayer`,
## sinon la caméra de la vue la déplacerait avec le terrain.
##
## Ligne de commande, pour les captures :
##   --arena                       l'écran de préparation
##   --arena-fight                 lance le match tout de suite
##   --arena-mode heart|duel  --arena-format 1|2|3  --arena-a fire,water  --arena-b peste,mort
##   --arena-stage N  --arena-speed 2  --arena-skip S (joue S secondes d'un coup)  --arena-result

signal menu_requested

## La dernière composition, gardée pour « Rejouer » et « Équipes ».
var last_setup := {}

var _ui: CanvasLayer
var _setup: ArenaSetup = null
var _view: ArenaView = null
var _world: WorldStage = null
var _ambience: Ambience = null
var _hud: ArenaHud = null
var _arena: ArenaMatch = null
var _speed := 1.0
var _seed := 1


func _ready() -> void:
	_ui = CanvasLayer.new()
	_ui.layer = 2
	add_child(_ui)
	var args := OS.get_cmdline_user_args()
	var preset := _setup_from_args(args)
	if not preset.is_empty():
		last_setup = preset
	if "--arena-fight" in args or "--arena-result" in args:
		start_match(last_setup if not last_setup.is_empty() else _default_setup())
		var skip := _number_after(args, "--arena-skip", 0.0)
		if "--arena-result" in args:
			skip = INF
		if skip > 0.0:
			_skip(skip)
		_speed = _number_after(args, "--arena-speed", 1.0)
		_apply_speed()
	else:
		show_setup()


func _exit_tree() -> void:
	# Le ×2 ne doit pas survivre à l'arène : le reste du jeu tournerait deux fois trop vite.
	Engine.time_scale = 1.0


func show_setup() -> void:
	_clear_match()
	_setup = ArenaSetup.new()
	_ui.add_child(_setup)
	_setup.load_setup(last_setup)
	_setup.fight_requested.connect(start_match)
	_setup.back_requested.connect(func() -> void: menu_requested.emit())


func start_match(setup: Dictionary) -> void:
	last_setup = setup.duplicate(true)
	if _setup != null:
		_setup.queue_free()
		_setup = null
	_clear_match()
	_seed += 1
	_arena = ArenaMatch.new(int(setup.get("mode", ArenaRules.Mode.HEART)),
		setup.get("team_a", []), setup.get("team_b", []), int(Time.get_ticks_msec() % 100000) + _seed)
	# L'Éveil des bleus est la décision du joueur. `--arena-auto` le rend aux héros, pour les captures.
	if not "--arena-auto" in OS.get_cmdline_user_args():
		_arena.manual_team = ArenaRules.TEAM_A
	_view = ArenaView.new()
	add_child(_view)
	_view.setup(_arena, int(setup.get("stage", ArenaRules.COLISEUM)))
	# La vue en volume des stages, sauf avec `--2d`.
	if WorldStage.requested():
		_world = WorldStage.new()
		add_child(_world)
		_view.enter_world(_world)
	_ambience = _view.make_ambience()
	(_world if _world != null else self).add_child(_ambience)
	_hud = ArenaHud.new()
	_ui.add_child(_hud)
	_hud.setup(_arena)
	_hud.set_speed(_speed)
	_hud.speed_requested.connect(func() -> void:
		_speed = 2.0 if _speed < 2.0 else 1.0
		_apply_speed())
	_hud.quit_requested.connect(func() -> void: menu_requested.emit())
	_hud.replay_requested.connect(func() -> void: start_match(last_setup))
	_hud.teams_requested.connect(show_setup)
	_arena.over.connect(func(_winner: int) -> void:
		# Le verdict s'affiche après un temps : on voit tomber le dernier héros avant.
		get_tree().create_timer(1.2).timeout.connect(func() -> void:
			if _hud != null and is_instance_valid(_hud):
				_hud.show_result()))


func _process(delta: float) -> void:
	# Le RALENTI de certains sorts (`Level._spawn_slow_motion`) rend ensuite l'allure normale, 1 :
	# sans ce rappel, le ×2 tombait au premier ralenti, le bouton disant toujours ×2.
	if _speed > 1.0 and is_equal_approx(Engine.time_scale, 1.0):
		Engine.time_scale = _speed
	if _arena == null or _arena.finished:
		return
	# Pas plus d'un trentième de seconde par pas : une image lente ne doit pas faire sauter
	# un héros par-dessus un sort.
	var left := delta
	while left > 0.0:
		var step := minf(left, 1.0 / 30.0)
		_arena.step(step)
		left -= step


func _apply_speed() -> void:
	Engine.time_scale = _speed
	if _hud != null:
		_hud.set_speed(_speed)


func _clear_match() -> void:
	Engine.time_scale = 1.0
	_speed = 1.0
	for node in [_view, _hud, _ambience, _world]:
		if node != null and is_instance_valid(node):
			(node as Node).queue_free()
	_view = null
	_hud = null
	_ambience = null
	_world = null
	_arena = null


## Joue `seconds` d'un coup, sans attendre l'image : pour capturer le milieu ou la fin d'un match.
func _skip(seconds: float) -> void:
	var limit := minf(seconds, ArenaRules.time_limit(_arena.mode) + 5.0)
	var t := 0.0
	while t < limit and not _arena.finished:
		_arena.step(1.0 / 60.0)
		t += 1.0 / 60.0
	if _arena.finished and _hud != null:
		_hud.show_result()


func _default_setup() -> Dictionary:
	return {
		"mode": ArenaRules.Mode.HEART, "format": 3, "stage": ArenaRules.COLISEUM,
		"team_a": [{"id": "ael", "posture": 0}, {"id": "fire", "posture": 1}, {"id": "water", "posture": 2}],
		"team_b": [{"id": "demon", "posture": 0}, {"id": "acier", "posture": 1}, {"id": "peste", "posture": 2}],
	}


func _setup_from_args(args: PackedStringArray) -> Dictionary:
	var touched := false
	var setup := _default_setup()
	var mode_at := args.find("--arena-mode")
	if mode_at >= 0 and mode_at + 1 < args.size():
		setup["mode"] = ArenaRules.Mode.DEATHMATCH if args[mode_at + 1] == "duel" else ArenaRules.Mode.HEART
		touched = true
	var format := int(_number_after(args, "--arena-format", 0.0))
	if format > 0:
		setup["format"] = clampi(format, 1, 3)
		touched = true
	var stage := int(_number_after(args, "--arena-stage", -1.0))
	if stage >= 0:
		setup["stage"] = stage
		touched = true
	for key in ["a", "b"]:
		var at := args.find("--arena-" + key)
		if at >= 0 and at + 1 < args.size():
			var picks := []
			var ids := args[at + 1].split(",")
			for i in ids.size():
				picks.append({"id": ids[i], "posture": i % 3})
			setup["team_" + key] = picks
			touched = true
	var count := int(setup["format"])
	setup["team_a"] = (setup["team_a"] as Array).slice(0, count)
	setup["team_b"] = (setup["team_b"] as Array).slice(0, count)
	return setup if touched or "--arena-fight" in args or "--arena-result" in args else {}


static func _number_after(args: PackedStringArray, flag: String, fallback: float) -> float:
	var at := args.find(flag)
	if at >= 0 and at + 1 < args.size() and args[at + 1].is_valid_float():
		return args[at + 1].to_float()
	return fallback
