class_name ArenaView
extends Node2D

## Montre un `ArenaMatch` : le terrain, les héros, la gemme et les sorts. Elle ne décide de rien
## (règle n° 2) : le match fait avancer les héros, elle les suit.
##
## LES EFFETS SONT CEUX DU `Level`, sort par sort (2026-11-09). Chaque héros reçoit un `Level` HÔTE
## (`Level.host_arena`) : son `combat`, son nœud en guise de `player`, et des fantômes d'`Enemy` posés
## sur ses adversaires en guise d'`enemies`. Le Level dessine alors ses sorts exactement comme en
## campagne — et ses marques d'état (venin, entailles, étoiles…) sur les fantômes, donc sur les héros
## d'en face. L'arène ne garde pour elle que ce que le Level ne sait pas : les chutes, les retours.
##
## Les effets GÉNÉRIQUES (orbe, éclat peint, zone) restent en repli, avec `--arena-generic` : c'était
## la première version, et elle sert à comparer.

const TILE_SIZE := MazeRenderer.TILE_SIZE
const PLAYER_SCENE := preload("res://scenes/entities/player.tscn")
const ORB_SCENE := preload("res://scenes/entities/magic_orb.tscn")
const IMPACT_SCENE := preload("res://scenes/entities/impact_effect.tscn")
const ZONE_SCENE := preload("res://scenes/entities/zone_effect.tscn")
const SHOCKWAVE_SCENE := preload("res://scenes/fx/shockwave.tscn")
const ARC_SCENE := preload("res://scenes/fx/lightning_arc.tscn")
const DAMAGE_SCENE := preload("res://scenes/entities/damage_number.tscn")
const LEVEL_SCENE := preload("res://scenes/level.tscn")
const ENEMY_SCENE := preload("res://scenes/entities/enemy.tscn")
## Marge autour du terrain, en cases, pour que les héros du bord ne touchent pas l'écran.
const FRAME_MARGIN := 0.6
## Part de l'écran laissée à l'interface, en haut et en bas.
const HUD_TOP := 0.13
const HUD_BOTTOM := 0.17

var arena: ArenaMatch = null
var stage := 1

var _renderer: MazeRenderer
var _entities: Node2D
var _heart: ArenaHeart
var _camera: Camera2D
var _nodes: Array[Player] = []
var _tags: Array[ArenaTag] = []
## Par héros : sa matière (orbe, zone), ses zones et ses invocations en cours.
var _looks: Array[Dictionary] = []
var _zones: Array[Dictionary] = []
var _summons: Array[Dictionary] = []
var _shake := 0.0
## Un `Level` hôte d'effets par héros, dans l'ordre de `arena.fighters`.
var _hosts: Array[Level] = []
var custom_fx := true
## LA VUE EN VOLUME, comme les stages (2026-11-10, demande du joueur : « joli comme le stage »). Posée par
## `ArenaScreen` après `setup`, sauf avec `--2d` : sol et murs en 3D, lumière du stage, ambiance. Nulle,
## l'arène reste à plat.
var world: WorldStage = null
var _world_rows := 0.0
## Rangées vues en volume : assez pour la mêlée, jamais tout le Colisée d'un coup (les héros y
## deviendraient minuscules), et des rangées ENTIÈRES, la texture du sol se retaillant à chaque pas.
const WORLD_ROWS_MIN := 10.0
const WORLD_ROWS_MAX := 16.0


func setup(p_arena: ArenaMatch, p_stage: int) -> void:
	arena = p_arena
	stage = clampi(p_stage, 0, LevelConfig.STAGE_NAMES.size())
	_renderer = MazeRenderer.new()
	add_child(_renderer)
	if stage == ArenaRules.COLISEUM:
		_renderer.set_tiles(ArenaRules.COLISEUM_TILES)
	else:
		_renderer.set_stage(stage)
	_renderer.set_grid(arena.grid)
	_heart = ArenaHeart.new()
	_heart.z_index = 3
	add_child(_heart)
	_heart.setup(arena, TILE_SIZE)
	_heart.visible = arena.mode == ArenaRules.Mode.HEART
	_entities = Node2D.new()
	_entities.y_sort_enabled = true
	# Au même niveau que les `Entities` des hôtes : les effets s'y rangent par `z_index` (9 sous les
	# acteurs, 11 et 12 devant), comme dans le Level.
	_entities.z_index = 0
	add_child(_entities)
	# Les décors du Colisée : sur les murs et autour, jamais sur une case où l'on se bat.
	if stage == ArenaRules.COLISEUM:
		ArenaDecor.place(_entities, arena.grid, TILE_SIZE)
	_camera = Camera2D.new()
	add_child(_camera)
	_camera.make_current()
	custom_fx = not "--arena-generic" in OS.get_cmdline_user_args()
	for i in arena.fighters.size():
		_add_fighter(arena.fighters[i], i)
	if custom_fx:
		for i in arena.fighters.size():
			_add_host(arena.fighters[i], i)
	arena.fighter_fell.connect(_on_fell)
	arena.fighter_returned.connect(_on_returned)
	arena.fighter_awakening.connect(_on_awakening)
	arena.fighter_form_changed.connect(_on_form_changed)
	arena.fighter_dodged.connect(_on_dodged)
	get_viewport().size_changed.connect(_frame)
	_frame()


func _add_fighter(fighter: ArenaFighter, i: int) -> void:
	var node: Player = PLAYER_SCENE.instantiate()
	node.set_character(fighter.stats)
	_entities.add_child(node)
	node.setup(arena.grid, fighter.spawn, fighter.stats.move_speed, TILE_SIZE)
	node.mover = fighter.mover
	node.puppet = true
	_nodes.append(node)
	var tag := ArenaTag.new()
	node.add_child(tag)
	tag.setup(fighter, TILE_SIZE)
	_tags.append(tag)
	_looks.append(_load_look(fighter.stats))
	_zones.append({})
	_summons.append({})
	var combat := fighter.combat
	# Le héros touché clignote : le Level fait clignoter un fantôme invisible.
	combat.enemy_damaged.connect(func(index: int, dealt: int, _a: Ability) -> void:
		var target := _foe_node(i, index)
		if target != null and dealt > 0:
			target.play_hurt(0.18))
	if custom_fx:
		return
	combat.projectile_launched.connect(_on_projectile.bind(i))
	combat.projectile_hit.connect(_on_projectile_hit.bind(i))
	combat.blast_fired.connect(_on_blast.bind(i))
	combat.wave_launched.connect(_on_wave.bind(i))
	combat.line_erupted.connect(_on_line.bind(i))
	combat.zone_created.connect(_on_zone.bind(i))
	combat.zone_moved.connect(_on_zone_moved.bind(i))
	combat.zone_expired.connect(_on_zone_expired.bind(i))
	combat.enemy_damaged.connect(_on_damaged.bind(i))
	combat.chain_arced.connect(_on_chain.bind(i))
	combat.meteor_incoming.connect(_on_meteor.bind(i))
	combat.blink_performed.connect(_on_blink.bind(i))
	combat.player_shielded.connect(func(_a: int, _d: float) -> void: _ring(i, 1.1, 0.5))
	combat.player_made_immune.connect(func(_d: float) -> void: _ring(i, 1.3, 0.6))
	combat.player_healed.connect(func(_a: int) -> void: _ring(i, 0.9, 0.45))
	combat.summon_spawned.connect(_on_summon_spawned.bind(i))
	combat.summon_moved.connect(_on_summon_moved.bind(i))
	combat.summon_struck.connect(_on_summon_struck.bind(i))
	combat.summon_expired.connect(_on_summon_expired.bind(i))
	combat.summon_slain.connect(_on_summon_expired.bind(i))


## L'hôte d'effets d'un héros, et un fantôme par adversaire. Le fantôme partage le `GridMover` et la
## `Health` du héros d'en face : il est là où il est, et il meurt quand il meurt. Son dessin est caché,
## seules restent les marques que le Level lui pose.
func _add_host(fighter: ArenaFighter, i: int) -> void:
	var host: Level = LEVEL_SCENE.instantiate()
	add_child(host)
	var foes: Array[Enemy] = []
	for other in fighter.opponents:
		var ghost: Enemy = ENEMY_SCENE.instantiate()
		host.entities.add_child(ghost)
		ghost.setup_enemy(arena.grid, other.spawn, other.stats.move_speed, TILE_SIZE, 0, Bestiary.FALLBACK, 1)
		ghost.mover = other.mover
		ghost.puppet = true
		ghost.health = other.health
		ghost.target_height = _nodes[arena.fighters.find(other)].target_height
		ghost.shadow_radius = 0.0
		ghost.sprite.visible = false
		ghost.hide_health_bar = true
		ghost.snap_to_mover()
		foes.append(ghost)
	host.host_arena(arena.grid, fighter.stats, fighter.combat, fighter.context, _nodes[i], foes,
		LevelConfig.demo(maxi(1, stage)))
	_hosts.append(host)
	if fighter.awakening != null:
		fighter.awakening.reborn.connect(host.show_rebirth)
		fighter.awakening.shell_formed.connect(host.show_shell_formed)
		fighter.awakening.shell_broken.connect(host.show_shell_broken)


## Passe l'arène en volume : `world` reprend la vue 2D dans sa texture de sol. À appeler après `setup`,
## `world` déjà dans l'arbre. Les `Level` hôtes y entrent avec elle, et leurs effets sont redressés.
func enter_world(p_world: WorldStage) -> void:
	world = p_world
	var groups: Array = [_entities]
	for host in _hosts:
		groups.append(host.entities)
	world.adopt_view(self, _camera, _renderer, groups)
	for host in _hosts:
		host.world_stage = world
	world.build(arena.grid, stage, ArenaRules.COLISEUM_TILES if stage == ArenaRules.COLISEUM else "", false)
	if arena.mode == ArenaRules.Mode.HEART:
		world.add_glow(ArenaRules.HEART_CELL, 3.2, Color(1.0, 0.86, 0.55, 0.5))
	_heart.stand = CameraRules.stand_scale()
	_snap = true


## L'air du décor : vignette teintée, poussière. Sur un calque d'écran, sous l'interface.
func make_ambience() -> Ambience:
	var air := Ambience.new()
	air.set_stage_tint(_renderer.air_tint())
	air.set_stage(stage)
	air.set_focus(Vector2(0.5, 0.55))
	return air


## La matière de chaque héros, lue dans son dossier comme le fait `Level._load_character_fx`.
func _load_look(stats: CharacterStats) -> Dictionary:
	var folder := "res://assets/characters/%s/" % stats.id
	var look := {
		"orb": _texture_or_null(folder + "orb.png"), "orb_frames": 1, "orb_grows": false,
		"impact": _texture_or_null(folder + "impact.png"),
		"zone": _texture_or_null(folder + "zone.png"),
		"painted": str(PaintedFx.IMPACT.get(stats.id, "")),
		"escape": str(PaintedFx.ESCAPE.get(stats.id, "")),
		"color": Element.color(stats.element),
		"element": stats.element,
	}
	var meta := FileAccess.get_file_as_string(folder + "orb.json")
	if not meta.is_empty():
		var parsed: Variant = JSON.parse_string(meta)
		if parsed is Dictionary:
			look["orb_frames"] = maxi(1, int(parsed.get("frames", 1)))
			look["orb_grows"] = str(parsed.get("mode", "loop")) == "grow"
	return look


static func _texture_or_null(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null


## LA CAMÉRA SUIT LA MÊLÉE. Tout le terrain à l'écran rendait les héros minuscules (une
## quarantaine de pixels sur un écran de 720) : elle cadre les héros debout, et la gemme en
## Gemme-Cœur, avec une marge. Jamais plus près que `MIN_VIEW` cases, jamais au-delà du terrain
## entier, et toujours en douceur — un zoom qui saute à chaque chute donne mal au cœur.
const MIN_VIEW := Vector2(12.0, 7.0)
const VIEW_MARGIN := 3.0
const CAMERA_EASE := 2.5

var _snap := true


func _frame() -> void:
	_snap = true


## Ce qu'il faut voir : les héros debout et la gemme, avec une marge.
func _fight_box() -> Rect2:
	var tile := float(TILE_SIZE)
	var full := Rect2(Vector2(0.0, -FRAME_MARGIN * tile),
		Vector2(arena.grid.cols, arena.grid.rows + FRAME_MARGIN * 2.0) * tile)
	var box := Rect2()
	var first := true
	for i in arena.fighters.size():
		if not arena.fighters[i].alive():
			continue
		var at := _nodes[i].position
		box = Rect2(at, Vector2.ZERO) if first else box.expand(at)
		first = false
	if arena.mode == ArenaRules.Mode.HEART:
		var heart := cell_world(ArenaRules.HEART_CELL)
		box = Rect2(heart, Vector2.ZERO) if first else box.expand(heart)
		first = false
	if first:
		box = full
	return box.grow(VIEW_MARGIN * tile)


## En volume : la caméra inclinée des stages suit la mêlée. Le nombre de rangées suit la taille de la
## mêlée, lissé puis arrondi, pour que la texture du sol ne se retaille pas à chaque image.
func _aim_world(delta: float) -> void:
	var tile := float(TILE_SIZE)
	var box := _fight_box()
	var view := Vector2(world.get_viewport().get_visible_rect().size)
	var aspect := view.x / maxf(1.0, view.y)
	var share := 1.0 - HUD_TOP - HUD_BOTTOM
	var wanted := clampf(maxf(box.size.y / tile / share, box.size.x / tile / aspect),
		WORLD_ROWS_MIN, WORLD_ROWS_MAX)
	_world_rows = wanted if _snap else lerpf(_world_rows, wanted, minf(1.0, delta * CAMERA_EASE * 0.5))
	var centre := box.get_center()
	# La bande libre n'est pas centrée sur l'écran : le bas de l'interface est plus haut que le haut.
	centre.y += (HUD_BOTTOM - HUD_TOP) * 0.5 * _world_rows * tile
	var shake := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake * 6.0
	world.aim_rows(centre, roundf(_world_rows), Vector2(arena.grid.cols, arena.grid.rows) * tile, _snap, shake)
	_snap = false


func _aim(delta: float) -> void:
	if world != null:
		_aim_world(delta)
		return
	var view := get_viewport().get_visible_rect().size
	var usable := Vector2(view.x, view.y * (1.0 - HUD_TOP - HUD_BOTTOM))
	var tile := float(TILE_SIZE)
	var full := Rect2(Vector2(0.0, -FRAME_MARGIN * tile),
		Vector2(arena.grid.cols, arena.grid.rows + FRAME_MARGIN * 2.0) * tile)
	var box := _fight_box()
	# Au moins MIN_VIEW, puis au rapport de la bande libre, pour que le zoom ne rogne rien.
	var wanted := Vector2(maxf(box.size.x, MIN_VIEW.x * tile), maxf(box.size.y, MIN_VIEW.y * tile))
	var aspect := usable.x / maxf(1.0, usable.y)
	if wanted.x / wanted.y < aspect:
		wanted.x = wanted.y * aspect
	else:
		wanted.y = wanted.x / aspect
	wanted = Vector2(minf(wanted.x, full.size.x), minf(wanted.y, full.size.y))
	var zoom := minf(usable.x / wanted.x, usable.y / wanted.y)
	zoom = maxf(zoom, minf(usable.x / full.size.x, usable.y / full.size.y))
	var seen := usable / zoom
	var centre := box.get_center()
	# Le cadre ne sort pas du terrain : on voit un bord, jamais du vide au-delà.
	centre.x = clampf(centre.x, full.position.x + seen.x * 0.5, full.end.x - seen.x * 0.5) \
		if seen.x < full.size.x else full.get_center().x
	centre.y = clampf(centre.y, full.position.y + seen.y * 0.5, full.end.y - seen.y * 0.5) \
		if seen.y < full.size.y else full.get_center().y
	# Le terrain se centre dans la bande libre, pas dans l'écran : le haut et le bas ne font pas
	# la même hauteur.
	centre.y += (HUD_BOTTOM - HUD_TOP) * 0.5 * view.y / zoom
	var ease := 1.0 if _snap else minf(1.0, delta * CAMERA_EASE)
	_snap = false
	_camera.zoom = _camera.zoom.lerp(Vector2(zoom, zoom), ease)
	_camera.position = _camera.position.lerp(centre, ease)


func _process(delta: float) -> void:
	if arena == null:
		return
	_aim(delta)
	_shake = maxf(0.0, _shake - delta * 2.5)
	for k in _hosts.size():
		_hosts[k].host_tick(delta, arena.fighters[k].field)
		_shake = maxf(_shake, _hosts[k].host_shake() * 0.6)
	if world == null:
		_camera.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake * 6.0
	for i in arena.fighters.size():
		var fighter := arena.fighters[i]
		var node := _nodes[i]
		if fighter.alive():
			# Les sorts qui le figent (étourdissement) le teintent, comme les créatures.
			node.set_tint(Color(0.7, 0.8, 1.25) if fighter.stun_left > 0.0 else Color.WHITE)


func cell_world(cell: Vector2i) -> Vector2:
	return _renderer.cell_to_world(cell)


func _foe_node(i: int, index: int) -> Player:
	var fighter := arena.fighters[i]
	if index < 0 or index >= fighter.opponents.size():
		return null
	return _nodes[arena.fighters.find(fighter.opponents[index])]


func _cast_toward(i: int, at: Vector2) -> void:
	_nodes[i].play_cast(at)


# --- Les sorts -----------------------------------------------------------------------

func _on_projectile(ability: Ability, index: int, path: Array, duration: float, i: int) -> void:
	var points := PackedVector2Array()
	for cell in path:
		points.append(cell_world(cell))
	if points.is_empty():
		return
	_cast_toward(i, points[points.size() - 1])
	var look: Dictionary = _looks[i]
	if ability.bolt:
		for k in points.size() - 1:
			var arc: LightningArc = ARC_SCENE.instantiate()
			_entities.add_child(arc)
			arc.setup(points[k], points[k + 1], look["color"], float(TILE_SIZE) * 0.11)
	var orb: MagicOrb = ORB_SCENE.instantiate()
	_entities.add_child(orb)
	orb.setup(points, duration, TILE_SIZE, Element.color(ability.element), look["orb"],
		int(look["orb_frames"]), ability.projectile_scale, ability.trail_density, ability.flames,
		bool(look["orb_grows"]))
	orb.paint(ability.projectile_visual, ability.projectile_scale)


func _on_projectile_hit(ability: Ability, _index: int, cell: Vector2i, i: int) -> void:
	_burst(i, cell, maxf(0.7, ability.radius), 0.5, ability)


func _on_blast(ability: Ability, cell: Vector2i, i: int) -> void:
	_cast_toward(i, cell_world(cell))
	var radius := maxf(1.0, ability.radius)
	_burst(i, cell, radius, 0.6, ability)
	if ability.is_ultimate or radius >= 2.5:
		_wave(cell, radius, _looks[i]["color"], 0.6)
		_shake = maxf(_shake, 0.8 if ability.is_ultimate else 0.4)


func _on_wave(ability: Ability, path: Array, duration: float, i: int) -> void:
	if path.is_empty():
		return
	_cast_toward(i, cell_world(path[path.size() - 1]))
	for k in path.size():
		_later(duration * float(k) / float(maxi(1, path.size())), func() -> void:
			_burst(i, path[k], 0.8, 0.45, ability))


func _on_line(ability: Ability, path: Array, duration: float, i: int) -> void:
	_on_wave(ability, path, duration, i)


func _on_zone(zone_id: int, ability: Ability, cell: Vector2i, i: int) -> void:
	var look: Dictionary = _looks[i]
	var zone: ZoneEffect = ZONE_SCENE.instantiate()
	_entities.add_child(zone)
	zone.position = cell_world(cell)
	var painted := ZoneEffect.PAINTED_STYLES.has(ability.zone_style)
	zone.setup(TILE_SIZE, Element.color(ability.element), maxf(0.8, ability.radius),
		maxf(0.3, ability.duration), null if painted or ability.zone_style == "ombre" else look["zone"],
		ability.flames, ability.zone_style, ability.snare > 0.0)
	zone.z_index = -1
	_zones[i][zone_id] = zone


func _on_zone_moved(zone_id: int, cell: Vector2i, i: int) -> void:
	var zone: Node2D = _zones[i].get(zone_id)
	if zone != null and is_instance_valid(zone):
		zone.position = cell_world(cell)


func _on_zone_expired(zone_id: int, i: int) -> void:
	var zone: Node2D = _zones[i].get(zone_id)
	if zone != null and is_instance_valid(zone):
		zone.queue_free()
	_zones[i].erase(zone_id)


func _on_damaged(index: int, dealt: int, ability: Ability, i: int) -> void:
	var target := _foe_node(i, index)
	if target == null or dealt <= 0:
		return
	target.play_hurt(0.18)
	var number: DamageNumber = DAMAGE_SCENE.instantiate()
	_entities.add_child(number)
	number.position = target.position
	number.setup(dealt, Element.color(ability.element), TILE_SIZE, ability.is_ultimate)


func _on_chain(from_index: int, to_index: int, i: int) -> void:
	var a := _foe_node(i, from_index)
	var b := _foe_node(i, to_index)
	if a == null or b == null:
		return
	var arc: LightningArc = ARC_SCENE.instantiate()
	_entities.add_child(arc)
	arc.setup(a.position, b.position, _looks[i]["color"], float(TILE_SIZE) * 0.12)


func _on_meteor(cell: Vector2i, delay: float, ability: Ability, i: int) -> void:
	_later(delay, func() -> void:
		_burst(i, cell, maxf(1.0, ability.radius), 0.6, ability)
		_wave(cell, maxf(1.0, ability.radius), _looks[i]["color"], 0.5)
		_shake = maxf(_shake, 0.35))


## La fuite se voit aux deux bouts, là où il part et là où il arrive.
func _on_blink(from: Vector2i, to: Vector2i, i: int) -> void:
	var key := str(_looks[i]["escape"])
	for cell in [from, to]:
		if key != "":
			var burst := PaintedBurst.new()
			_entities.add_child(burst)
			burst.position = cell_world(cell)
			burst.setup(TILE_SIZE, 1.1, 0.6, float(cell.x * 7 + cell.y), key)
		else:
			_wave(cell, 1.0, _looks[i]["color"], 0.4)


func _ring(i: int, radius: float, seconds: float) -> void:
	_wave(arena.fighters[i].cell(), radius, _looks[i]["color"], seconds)


# --- Les invocations (l'Invocateur, la Faille, le Cyclone) ------------------------------

func _on_summon_spawned(id: int, kind_id: String, grid_position: Vector2, i: int) -> void:
	var visual := SummonVisual.new()
	visual.z_index = 10
	_entities.add_child(visual)
	var info := arena.fighters[i].combat.summon_info(id)
	visual.size_factor = float(info.get("scale", 1.0))
	visual.setup(kind_id, TILE_SIZE, str(info.get("look", "")))
	visual.position = (grid_position + Vector2(0.5, 0.5)) * float(TILE_SIZE)
	visual.modulate = Color.WHITE.lerp(ArenaRules.TEAM_COLORS[arena.fighters[i].team], 0.25)
	_summons[i][id] = visual


func _on_summon_moved(id: int, grid_position: Vector2, facing: Vector2i, i: int) -> void:
	var visual: SummonVisual = _summons[i].get(id)
	if visual != null and is_instance_valid(visual):
		visual.position = (grid_position + Vector2(0.5, 0.5)) * float(TILE_SIZE)
		visual.set_facing(facing)


func _on_summon_struck(id: int, _target: int, i: int) -> void:
	var visual: SummonVisual = _summons[i].get(id)
	if visual != null and is_instance_valid(visual):
		visual.flash_strike()


func _on_summon_expired(id: int, i: int) -> void:
	var visual: SummonVisual = _summons[i].get(id)
	if visual != null and is_instance_valid(visual):
		_wave(Vector2i((visual.position / float(TILE_SIZE)).floor()), 0.8, _looks[i]["color"], 0.35)
		visual.queue_free()
	_summons[i].erase(id)


# --- L'Éveil ---------------------------------------------------------------------------

## Le geste d'Éveil : la lumière monte sur lui pendant `Awakening.CHARGE_TIME`.
func _on_awakening(fighter: ArenaFighter) -> void:
	var i := arena.fighters.find(fighter)
	if i < 0:
		return
	if custom_fx:
		_hosts[i].show_awakening_charge()
		return
	_wave(fighter.cell(), 1.0, _looks[i]["color"], Awakening.CHARGE_TIME)
	_later(Awakening.CHARGE_TIME * 0.5, func() -> void:
		_wave(fighter.cell(), 1.6, Color("#ffd479"), Awakening.CHARGE_TIME * 0.6))


## La forme change : le sprite suit, et l'arrivée de la forme éveillée se voit de loin.
func _on_form_changed(fighter: ArenaFighter) -> void:
	var i := arena.fighters.find(fighter)
	if i < 0:
		return
	var node := _nodes[i]
	if custom_fx:
		# Le Level fait tout : le kit, les bandes, les effets de la forme, et sa grande entrée.
		_hosts[i].set_character(fighter.stats)
		node.set_growth(Awakening.GROWTH if fighter.stats.awakened and fighter.stats.id == CharacterCatalog.EARTH else 1.0)
		if fighter.stats.awakened:
			_hosts[i].show_awakening()
		else:
			_hosts[i].end_awakening()
		return
	node.set_character(fighter.stats)
	# Le Colosse grandit, comme dans le `Level`.
	node.set_growth(Awakening.GROWTH if fighter.stats.awakened and fighter.stats.id == CharacterCatalog.EARTH else 1.0)
	if fighter.stats.awakened:
		_wave(fighter.cell(), 3.0, _looks[i]["color"], 0.8)
		_wave(fighter.cell(), 2.0, Color("#ffd479"), 0.6)
		_shake = maxf(_shake, 0.7)
		var key := str(_looks[i]["painted"])
		if key != "":
			var burst := PaintedBurst.new()
			_entities.add_child(burst)
			burst.position = cell_world(fighter.cell())
			burst.setup(TILE_SIZE, 2.4, 0.9, float(i), key)


# --- Chutes et retours -------------------------------------------------------------------

func _on_fell(victim: ArenaFighter, _killer: ArenaFighter) -> void:
	var i := arena.fighters.find(victim)
	if i < 0:
		return
	var node := _nodes[i]
	_wave(victim.cell(), 1.6, ArenaRules.TEAM_COLORS[victim.team], 0.7)
	_shake = maxf(_shake, 0.5)
	var tween := node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, 0.5)


func _on_returned(fighter: ArenaFighter) -> void:
	var i := arena.fighters.find(fighter)
	if i < 0:
		return
	var node := _nodes[i]
	node.snap_to_mover()
	node.modulate.a = 1.0
	node.play_warp()
	_wave(fighter.spawn, 1.2, ArenaRules.TEAM_COLORS[fighter.team], 0.5)


## UN TIR MANQUÉ : « ESQUIVE » monte au-dessus du héros, et un souffle clair marque le pas de côté.
## Un tir manqué sans rien dire se lirait comme un sort cassé. Borné comme les éclats : six héros qui
## esquivent ensemble ne doivent pas couvrir la mêlée de texte.
func _on_dodged(fighter: ArenaFighter) -> void:
	var i := arena.fighters.find(fighter)
	if i < 0 or get_tree().get_node_count_in_group("arena_callout") >= 4:
		return
	_wave(fighter.cell(), 0.55, Color(0.85, 0.95, 1.0), 0.28)
	var label := Label.new()
	label.add_to_group("arena_callout")
	label.text = "ESQUIVE"
	label.add_theme_font_size_override("font_size", int(TILE_SIZE * 0.42))
	label.add_theme_color_override("font_color", Color(0.9, 0.97, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.08, 0.16))
	label.add_theme_constant_override("outline_size", 5)
	label.z_index = 30
	_entities.add_child(label)
	var width := label.get_theme_font("font").get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1,
		int(TILE_SIZE * 0.42)).x
	label.position = cell_world(fighter.cell()) + Vector2(-width * 0.5, -TILE_SIZE * 1.9)
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - TILE_SIZE * 0.6, 0.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.2)
	tween.chain().tween_callback(label.queue_free)


# --- Petits outils ----------------------------------------------------------------------

## SIX LANCEURS À LA FOIS. Aux rayons du `Level`, pensés pour un seul mage, les éclats couvraient
## la mêlée et cachaient les héros (vu en capture le 2026-11-09) : l'arène les borne, et refuse un
## éclat ordinaire de plus quand `MAX_BURSTS` sont déjà à l'écran. L'Extra passe toujours.
const MAX_BURSTS := 9
const HIT_RADIUS_MAX := 1.2
const BLAST_RADIUS_MAX := 2.2


## L'éclat d'un coup : le dessin peint du héros s'il en a un, sinon l'éclat de son élément.
func _burst(i: int, cell: Vector2i, radius: float, seconds: float, ability: Ability) -> void:
	if not ability.is_ultimate:
		if get_tree().get_node_count_in_group("arena_burst") >= MAX_BURSTS:
			return
		radius = minf(radius, BLAST_RADIUS_MAX if ability.kind == Ability.Kind.BLAST else HIT_RADIUS_MAX)
	var look: Dictionary = _looks[i]
	var key := str(look["painted"])
	if key != "":
		var burst := PaintedBurst.new()
		burst.add_to_group("arena_burst")
		burst.modulate.a = 0.85
		_entities.add_child(burst)
		burst.position = cell_world(cell)
		burst.setup(TILE_SIZE, radius, seconds, float(cell.x * 733 + cell.y * 199) * 0.001, key)
		return
	var impact: ImpactEffect = IMPACT_SCENE.instantiate()
	impact.add_to_group("arena_burst")
	_entities.add_child(impact)
	impact.position = cell_world(cell)
	impact.setup(TILE_SIZE, ability.element, radius, seconds, cell.x * 733 + cell.y * 199 + 1,
		look["impact"], ability.flames)


func _wave(cell: Vector2i, radius: float, tint: Color, seconds: float) -> void:
	var wave: Shockwave = SHOCKWAVE_SCENE.instantiate()
	_entities.add_child(wave)
	wave.position = cell_world(cell)
	wave.setup(TILE_SIZE, radius, Color(1.0, 1.0, 1.0, 0.9), tint, seconds)


func _later(seconds: float, action: Callable) -> void:
	if seconds <= 0.0:
		action.call()
		return
	get_tree().create_timer(seconds, false).timeout.connect(action)
