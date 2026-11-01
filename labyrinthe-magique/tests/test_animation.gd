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
	_test_animated_mage(grid)
	_test_impact_pose(grid)
	_test_painted_fire()
	_test_spell_names_fit()
	_test_roster_slider()

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


## La rangée des mages défile : aucune carte n'est hors d'atteinte, sur téléphone comme ailleurs.
func _test_roster_slider() -> void:
	var select: CharacterSelect = load("res://scenes/menu/character_select.tscn").instantiate()
	root.add_child(select)
	select.size = Vector2(844.0, 390.0)
	select._layout()
	if select._shown >= select._listed.size():
		_fail("sélection : à 844 de large, les cartes de l'onglet ne devraient pas tenir")
	if not select._arrow_left.disabled or select._arrow_right.disabled:
		_fail("sélection : au début, seul le bouton de droite doit être actif")
	var presses := 0
	while not select._arrow_right.disabled and presses < 20:
		select._on_arrow(1)
		presses += 1
	if select._first_shown + select._shown != select._listed.size():
		_fail("sélection : le bouton n'atteint pas le dernier mage")
	select._show_from(0, false)
	select.select(CharacterCatalog.PESTE)
	var last := select._listed.size() - 1
	if select._first_shown + select._shown <= last:
		_fail("sélection : le mage choisi reste caché")
	select.size = Vector2(4000.0, 900.0)
	select._layout()
	if select._arrow_left.visible:
		_fail("sélection : les boutons restent affichés alors que tout tient")
	select.free()
	print("sélection : la rangée défile et atteint tous les mages")


## Tout nom de sort tient en entier dans sa case, à côté de son icône.
func _test_spell_names_fit() -> void:
	var font := ThemeDB.fallback_font
	var room := ActionBar.name_room()
	for character in CharacterCatalog.all():
		for ability: Ability in [character.attack] + character.abilities:
			var fit := ActionBar.fit_name(font, ability.display_name, room)
			for line in fit["lines"]:
				var width := font.get_string_size(
					line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, int(fit["size"])).x
				if width > room:
					_fail("nom coupé : « %s » (%s) fait %d px pour %d" % [
						ability.display_name, character.id, int(width), int(room)])


## LE TRAIT ET LA BOULE DU FEU SONT PEINTS, ET LE RESTE NE L'EST PAS. Une clé mal
## écrite dans le catalogue retomberait sans bruit sur l'ancienne image.
func _test_painted_fire() -> void:
	var fire := CharacterCatalog.fire()
	for ability: Ability in [fire.attack, fire.abilities[0]]:
		if not MagicOrb.PAINTED.has(ability.projectile_visual):
			_fail("%s n'est pas peint : « %s »" % [ability.id, ability.projectile_visual])
			continue
		var orb: MagicOrb = load("res://scenes/entities/magic_orb.tscn").instantiate()
		root.add_child(orb)
		var path := PackedVector2Array([Vector2.ZERO, Vector2(320.0, 0.0)])
		orb.setup(path, 1.0, TILE, Color.ORANGE, null, 1, ability.projectile_scale,
			ability.trail_density, ability.flames)
		orb.paint(ability.projectile_visual, ability.projectile_scale)
		if not orb.sprite.material is ShaderMaterial:
			_fail("%s garde son matériau d'image" % ability.id)
		if orb.sprite.material.get_shader_parameter("noise") == null:
			_fail("%s n'a pas de bruit : il ne dessinerait rien" % ability.id)
		if orb.sprite.hframes != 1:
			_fail("%s découpe son quad en images" % ability.id)
		orb._process(1.0)
		var full: Vector2 = orb.sprite.scale
		if full.x <= full.y:
			_fail("%s n'atteint pas sa taille allongée : %s" % [ability.id, full])
		if orb.sprite.rotation != 0.0:
			_fail("%s ne vole pas dans le sens du trajet" % ability.id)
		orb.free()
	# Le sol et l'aura : un quad large de deux rayons, sans image ni anneaux tracés.
	for ability: Ability in [fire.abilities[1], fire.abilities[2]]:
		if not ZoneEffect.PAINTED_STYLES.has(ability.zone_style):
			_fail("%s n'est pas peint : « %s »" % [ability.id, ability.zone_style])
			continue
		var zone: ZoneEffect = load("res://scenes/entities/zone_effect.tscn").instantiate()
		root.add_child(zone)
		zone.setup(TILE, Color.ORANGE, ability.radius, ability.duration, null,
			ability.flames, ability.zone_style, ability.snare > 0.0)
		var span := float(TILE) * ability.radius * 2.0
		if zone._field == null or absf(zone._field.size.x - span) > 0.5:
			_fail("%s ne s'arrête pas au rayon du sort" % ability.id)
		zone.free()
	# CHAQUE SORT PEINT A SON PROPRE DESSIN : deux compétences ne partagent jamais un
	# même habillage, sinon on retombe sur des teintes au lieu d'éléments.
	var seen := {}
	for mage: CharacterStats in CharacterCatalog.all():
		# La Terre et l'Air gardent leurs dessins, les shaders s'y ajoutent.
		if Level.PAINTED_MAGES.has(mage.id) == Level.DRAWN_MAGES.has(mage.id):
			_fail("%s n'a pas le bon rendu" % mage.id)
		var shown: String = PaintedFx.IMPACT.get(mage.id, "")
		if not PaintedFx.SHADERS.has(shown):
			_fail("%s n'a pas d'éclat peint" % mage.id)
		if seen.has(shown):
			_fail("%s et %s partagent leur éclat" % [seen[shown], mage.id])
		seen[shown] = mage.id
		for ability: Ability in [mage.attack] + mage.abilities:
			for look: String in [ability.projectile_visual, ability.zone_style]:
				if not (MagicOrb.PAINTED.has(look) or ZoneEffect.PAINTED_STYLES.has(look)):
					continue
				if seen.has(look):
					_fail("%s et %s partagent le dessin « %s »" % [seen[look], ability.id, look])
				seen[look] = ability.id
	# L'explosion ne couvre pas l'écran, quel que soit le rayon du sort.
	var burst := PaintedBurst.new()
	root.add_child(burst)
	burst.setup(TILE, 7.0, 0.5, 0.0, "fire_burst")
	var drawn: Sprite2D = burst.get_child(0)
	if drawn.scale.x > float(TILE) * PaintedBurst.MAX_RADIUS_TILES * 2.0 / 0.8 + 0.5:
		_fail("l'explosion peinte dépasse son plafond : %s" % drawn.scale)
	burst._process(0.6)
	if not burst.is_queued_for_deletion():
		_fail("l'explosion peinte ne disparaît pas")
	burst.free()


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


## La planche animée du Feu : le geste déroule ses huit images, la marche ses huit
## pas, et le corps garde à l'écran la hauteur des mages à six poses.
func _test_animated_mage(grid: MazeGrid) -> void:
	var player: Player = PLAYER_SCENE.instantiate()
	player.set_character(CharacterCatalog.fire())
	root.add_child(player)
	player.setup(grid, Vector2i(4, 4), 5.0, TILE)
	if player._walk_poses.size() != 8 or player._attack_poses.size() != 8:
		_fail("le Feu n'a pas ses 8 pas et ses 8 attaques")
	var sheet: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://assets/characters/fire/frames.json"))
	var body: float = player.target_height * float(sheet["body_height"]) / player._cell.y
	if absf(body - Player.BODY_SCREEN_HEIGHT) > 1.0:
		_fail("corps du Feu à %.1f px au lieu de %.0f" % [body, Player.BODY_SCREEN_HEIGHT])
	if absf(player.sprite.scale.y * 112.0 - player.target_height) > 0.5:
		_fail("le sprite n'est pas à la hauteur demandée")
	player.play_cast()
	var seen := {}
	while player._attack_left > 0.0:
		player._process(FRAME)
		seen[player.sprite.frame] = true
	if seen.size() < 7:
		_fail("le geste ne montre que %d images" % seen.size())
	for frame: int in seen:
		if not player._attack_poses.has(frame) and frame != 0:
			_fail("image %d hors du geste" % frame)
	player._process(FRAME)
	if player.sprite.frame != 0:
		_fail("le mage ne revient pas au repos après le sort")
	player.mover.desired_direction = Vector2i.RIGHT
	seen.clear()
	for i in 60:
		player._animate(FRAME)
		player.mover.direction = Vector2i.RIGHT
		player.mover.next_cell = Vector2i(5, 4)
		player.mover.progress = 0.5
		seen[player.sprite.frame] = true
	if seen.size() < 8:
		_fail("la marche ne montre que %d images" % seen.size())
	player.free()
	print("feu : %d images de marche jouées, geste complet, taille conservée" % seen.size())


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
	print("coup : l'image d'impact coïncide avec les dégâts, pour les douze")


func _key(direction: Vector2i) -> String:
	match direction:
		Vector2i.LEFT:
			return "left"
		Vector2i.RIGHT:
			return "right"
		Vector2i.UP:
			return "up"
	return "down"
