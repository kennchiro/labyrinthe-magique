extends SceneTree

## Contrôle visuel des effets d'Aël, image par image. D'abord l'Apprenti : la lame d'air du Tranche-vent,
## la traînée de la Ruée, la garde de la Parade et le grand cercle de l'Éveil de l'éclat. Puis ses formes :
## l'éveil de cristal, la gerbe de gemmes, la Frappe éclair, le Rayon, la pluie d'éclats, la sentinelle,
## l'onde prismatique, l'orbite, la comète, le dard du Prisme, et l'évolution elle-même. Un effet d'un
## tiers de seconde ne se juge pas en jeu.
##   godot --path . --resolution 1280x720 --script res://tools/preview_ael.gd -- /tmp/ael.png

const FRAME := 1.0 / 60.0
const TILE := 32
const COLUMNS := 8
const BOX := Vector2i(200, 150)
const ZOOM := 2.0
const STEEL := Color("#dff4ff")
const SHARD := Color("#8fe3ff")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var path := "/tmp/ael.png"
	if not OS.get_cmdline_user_args().is_empty():
		path = OS.get_cmdline_user_args()[0]
	RenderingServer.set_default_clear_color(Color("#3a4a3f"))
	# Chaque rangée : l'effet, et le nombre d'images à 60/s entre deux vignettes.
	# Dans l'ordre des formes : Apprenti, Éveillé, Ascendant, Prisme, puis l'évolution.
	var rows: Array = [[_wind_cut, 3], [_rush, 3], [_guard, 3], [_awaken, 3],
		[_wake, 3], [_gems, 5], [_plates, 4], [_line, 6], [_motes, 4], [_beam, 4],
		[_rain, 5], [_sentinel, 6], [_link, 3], [_wings, 4], [_nova, 5], [_gather, 6],
		[_dart, 2], [_burst, 4], [_sphere, 4], [_orbit, 5], [_throw, 3], [_transmit, 4], [_ultimate, 10],
		[_claws, 2], [_breath, 4], [_scales, 4], [_dive, 5], [_soar, 5], [_roar, 14], [_aura, 6],
		[_ascension, 10], [_dissipate, 8]]
	var sheet := Image.create(COLUMNS * BOX.x, rows.size() * BOX.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#3a4a3f"))
	for row in rows.size():
		var holder := Node2D.new()
		root.add_child(holder)
		holder.position = root.get_visible_rect().size * 0.5
		holder.scale = Vector2(ZOOM, ZOOM)
		rows[row][0].call(holder)
		for column in COLUMNS:
			await RenderingServer.frame_post_draw
			var image := root.get_texture().get_image()
			image.convert(Image.FORMAT_RGBA8)
			# La fenêtre peut être étirée : on découpe au centre de l'IMAGE, pas de la vue logique.
			var corner := image.get_size() / 2 - BOX / 2
			sheet.blit_rect(image, Rect2i(corner, BOX), Vector2i(column * BOX.x, row * BOX.y))
			for i in int(rows[row][1]):
				_step(holder)
		holder.queue_free()
		await process_frame
	sheet.save_png(path)
	print("  ", path)
	quit(0)


## Fait avancer à la main tout ce que la planche montre : les effets se jouent dans `_process`.
func _step(node: Node) -> void:
	for child in node.get_children():
		_step(child)
		if child.has_method("_process"):
			child._process(FRAME)


func _hero(at: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/characters/ael/right.png")
	sprite.hframes = 17
	sprite.frame = 1
	sprite.centered = true
	sprite.offset = Vector2(0.0, -40.0)
	sprite.scale = Vector2(0.4, 0.4)
	sprite.position = at
	return sprite


func _wind_cut(holder: Node2D) -> void:
	var crescent := FlyingCrescent.new()
	holder.add_child(crescent)
	crescent.setup(PackedVector2Array([Vector2(-70, 0), Vector2(70, 0)]), 0.3, TILE, STEEL)
	crescent.set_process(false)


func _rush(holder: Node2D) -> void:
	var hero := _hero(Vector2(55, 18))
	holder.add_child(hero)
	var streak := BladeStreak.new()
	holder.add_child(streak)
	streak.setup(Vector2(-60, 0), Vector2(55, 0), TILE, STEEL, hero, Vector2.ONE)
	streak.set_process(false)


func _guard(holder: Node2D) -> void:
	holder.add_child(_hero(Vector2(0, 20)))
	var guard := GuardFlash.new()
	holder.add_child(guard)
	guard.setup(float(TILE) * 0.75, STEEL, 0.6)
	guard.set_process(false)


func _awaken(holder: Node2D) -> void:
	holder.add_child(_hero(Vector2(0, 20)))
	for ring_data in [[2.0 * TILE, SHARD, 0.3], [1.2 * TILE, STEEL, 0.22]]:
		var ring := SlashArc.new()
		holder.add_child(ring)
		ring.setup_ring(ring_data[0], ring_data[1], ring_data[2])
		ring.set_process(false)
	var glint := GemGlint.new()
	holder.add_child(glint)
	glint.position = Vector2(0, 0)
	glint.setup(float(TILE) * 0.6, SHARD)
	glint.set_process(false)


const CYAN := Color("#7fe3ff")
const BLUE := Color("#a9dcff")
const GOLD := Color("#f2c94c")


func _gems(holder: Node2D) -> void:
	var home := Node2D.new()
	holder.add_child(home)
	var gems := GemVolley.new()
	gems.colour = CYAN
	holder.add_child(gems)
	gems.setup(Vector2.ZERO, [Vector2.RIGHT, Vector2(1, -1).normalized(), Vector2(1, 1).normalized()], 80.0, TILE, home)
	gems.set_process(false)


func _line(holder: Node2D) -> void:
	var line := CrystalLine.new()
	holder.add_child(line)
	line.setup(PackedVector2Array([Vector2(-80, 20), Vector2(-48, 20), Vector2(-16, 20), Vector2(16, 20),
		Vector2(48, 20), Vector2(80, 20)]), 0.3, 0.4, TILE, CYAN)
	line.set_process(false)


func _beam(holder: Node2D) -> void:
	var beam := PrismBeam.new()
	holder.add_child(beam)
	beam.setup(PackedVector2Array([Vector2(-90, 0), Vector2(-30, 0), Vector2(30, 0), Vector2(90, 0)]), TILE, CYAN, 0.45)
	beam.set_process(false)


func _rain(holder: Node2D) -> void:
	var shard := ShardRain.new()
	holder.add_child(shard)
	shard.position = Vector2(0, 40)
	shard.setup(0.45, TILE, BLUE)
	shard.set_process(false)


func _sentinel(holder: Node2D) -> void:
	var sentinel := CrystalSentinel.new()
	holder.add_child(sentinel)
	sentinel.position = Vector2(0, 40)
	sentinel.setup(TILE, BLUE)
	sentinel.set_process(false)


func _link(holder: Node2D) -> void:
	var link := PrismLink.new()
	holder.add_child(link)
	link.setup(Vector2(-80, 20), Vector2(80, -10), TILE, BLUE)
	link.set_process(false)


func _orbit(holder: Node2D) -> void:
	holder.add_child(_hero(Vector2(0, 30)))
	var orbit := ShardOrbit.new()
	holder.add_child(orbit)
	orbit.position = Vector2(0, 30)
	orbit.setup(TILE, GOLD, 6.0)
	orbit.set_process(false)


func _burst(holder: Node2D) -> void:
	var burst := StarBurst.new()
	holder.add_child(burst)
	burst.setup(TILE * 1.6, GOLD)
	burst.set_process(false)


func _dart(holder: Node2D) -> void:
	var dart := FlyingCrescent.new()
	holder.add_child(dart)
	dart.setup(PackedVector2Array([Vector2(-80, 0), Vector2(80, 0)]), 0.25, TILE, GOLD, FlyingCrescent.Style.LANCE)
	dart.set_process(false)


func _ascension(holder: Node2D) -> void:
	holder.add_child(_hero(Vector2(0, 45)))
	var burst := AscensionBurst.new()
	holder.add_child(burst)
	burst.position = Vector2(0, 45)
	burst.setup(TILE, GOLD)
	burst.set_process(false)


func _dissipate(holder: Node2D) -> void:
	holder.add_child(_hero(Vector2(0, 45)))
	var burst := AscensionBurst.new()
	holder.add_child(burst)
	burst.position = Vector2(0, 45)
	burst.setup(TILE, GOLD, true)
	burst.set_process(false)


func _guard_style(holder: Node2D, style: GuardFlash.Style, colour: Color) -> void:
	holder.add_child(_hero(Vector2(0, 20)))
	var guard := GuardFlash.new()
	holder.add_child(guard)
	guard.setup(float(TILE) * 0.75, colour, 0.6, style)
	guard.set_process(false)


func _plates(holder: Node2D) -> void:
	_guard_style(holder, GuardFlash.Style.PLATES, CYAN)


func _sphere(holder: Node2D) -> void:
	_guard_style(holder, GuardFlash.Style.SPHERE, GOLD)


func _streak(holder: Node2D, style: BladeStreak.Style, colour: Color) -> void:
	var hero := _hero(Vector2(55, 18))
	holder.add_child(hero)
	var streak := BladeStreak.new()
	holder.add_child(streak)
	streak.setup(Vector2(-60, 18), Vector2(55, 18), TILE, colour, hero, Vector2.ONE, style)
	streak.set_process(false)


func _motes(holder: Node2D) -> void:
	_streak(holder, BladeStreak.Style.MOTES, CYAN)


func _wings(holder: Node2D) -> void:
	_streak(holder, BladeStreak.Style.WINGS, BLUE)


func _transmit(holder: Node2D) -> void:
	_streak(holder, BladeStreak.Style.TRANSMIT, GOLD)


func _wake(holder: Node2D) -> void:
	var shard := FlyingCrescent.new()
	holder.add_child(shard)
	shard.setup(PackedVector2Array([Vector2(-80, 20), Vector2(80, 20)]), 0.3, TILE, CYAN, FlyingCrescent.Style.SHARD)
	shard.set_process(false)


func _nova(holder: Node2D) -> void:
	var nova := CrystalNova.new()
	holder.add_child(nova)
	nova.position = Vector2(0, 30)
	nova.setup(2.0 * TILE, TILE, BLUE)
	nova.set_process(false)


func _gather(holder: Node2D) -> void:
	holder.add_child(_hero(Vector2(0, 40)))
	var gather := GatherLight.new()
	holder.add_child(gather)
	gather.position = Vector2(0, 40)
	gather.setup(TILE, GOLD, 0.8)
	gather.set_process(false)


func _throw(holder: Node2D) -> void:
	var blade := BladeThrow.new()
	holder.add_child(blade)
	blade.setup(Vector2(-70, -10), Vector2(70, 10), TILE, GOLD)
	blade.set_process(false)


func _ultimate(holder: Node2D) -> void:
	holder.add_child(_hero(Vector2(0, 0)))
	var nova := PrismNova.new()
	holder.add_child(nova)
	var targets: Array[Vector2] = [Vector2(70, -20), Vector2(-60, 30)]
	nova.setup(90.0, TILE, targets)
	nova.set_process(false)


func _claws(holder: Node2D) -> void:
	var claws := ClawRake.new()
	holder.add_child(claws)
	claws.setup(Vector2.RIGHT, 70.0)
	claws.set_process(false)


func _breath(holder: Node2D) -> void:
	var breath := DragonBreath.new()
	holder.add_child(breath)
	breath.position = Vector2(-60, 0)
	breath.setup(Vector2.RIGHT, 150.0, deg_to_rad(35.0))
	breath.set_process(false)


func _scales(holder: Node2D) -> void:
	_guard_style(holder, GuardFlash.Style.SCALES, GOLD)


func _dive(holder: Node2D) -> void:
	_streak(holder, BladeStreak.Style.DIVE, GOLD)


func _soar(holder: Node2D) -> void:
	_streak(holder, BladeStreak.Style.SOAR, GOLD)


func _roar(holder: Node2D) -> void:
	holder.add_child(_hero(Vector2(0, 50)))
	var roar := DragonRoar.new()
	holder.add_child(roar)
	roar.position = Vector2(0, 50)
	roar.setup(110.0, TILE)
	roar.set_process(false)


func _aura(holder: Node2D) -> void:
	var aura := DragonAura.new()
	holder.add_child(aura)
	aura.position = Vector2(0, 40)
	aura.tile_size = TILE
	holder.add_child(_hero(Vector2(0, 40)))
	aura.set_process(false)

