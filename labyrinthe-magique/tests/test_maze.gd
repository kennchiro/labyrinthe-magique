extends SceneTree

## Tests d'invariants de la génération, exécutables sans ouvrir l'éditeur :
##   godot --headless --path . --script res://tests/test_maze.gd
##
## MazeGrid et MazeGenerator n'ayant aucune dépendance au moteur de scène,
## on peut valider 400 labyrinthes en une seconde. C'est exactement le
## bénéfice de la séparation données / rendu.

const ITERATIONS := 200

var _failures: Array[String] = []


func _init() -> void:
	for config in LevelConfig.all_levels():
		_test_level(config)
	_test_determinism()

	print("")
	if _failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT (%d labyrinthes par stage)" % ITERATIONS)
	else:
		print("❌  %d ÉCHEC(S) :" % _failures.size())
		for f in _failures:
			print("   - ", f)
	quit(0 if _failures.is_empty() else 1)


func _fail(msg: String) -> void:
	if _failures.size() < 20:
		_failures.append(msg)


func _test_level(config: LevelConfig) -> void:
	var dead_end_total := 0
	var floor_total := 0
	var gem_distance_total := 0
	var gem_distance_count := 0

	for i in ITERATIONS:
		var seed_value := 1000 + i
		var g := MazeGenerator.generate(config, seed_value)
		var tag := "%s seed=%d" % [config.level_name, seed_value]

		# 1. La bordure extérieure doit rester entièrement murée.
		for c in g.cols:
			if g.is_floor(c, 0) or g.is_floor(c, g.rows - 1):
				_fail("%s : trou dans la bordure horizontale" % tag)
				break
		for r in g.rows:
			if g.is_floor(0, r) or g.is_floor(g.cols - 1, r):
				_fail("%s : trou dans la bordure verticale" % tag)
				break

		# 2. Toute case praticable doit être reliée à la maison.
		#    Sans ça, le joueur peut spawner dans une poche fermée = niveau ingagnable.
		var cells := g.all_floor_cells()
		floor_total += cells.size()
		for cell in cells:
			if g.distance_at(cell) < 0:
				_fail("%s : case %s isolée de la maison" % [tag, cell])
				break

		# 3. Le mage commence CHEZ LUI : au centre de sa maison, avec une porte
		#    sud praticable pour en sortir. Il n'y a pas de victoire immédiate à
		#    craindre — l'arrivée à la maison n'est rapportée qu'en ENTRANT
		#    depuis l'extérieur, et la porte reste scellée sans les gemmes.
		if g.player_spawn != g.house_center:
			_fail("%s : spawn joueur %s au lieu du centre de la maison %s" %
				[tag, g.player_spawn, g.house_center])
		if not g.is_floor_v(g.player_spawn):
			_fail("%s : spawn joueur dans un mur" % tag)
		var door := g.house_center + Vector2i(0, 1)
		while g.in_bounds(door.x, door.y) and g.is_house(door):
			door.y += 1
		if not g.is_floor_v(door):
			_fail("%s : pas de porte sud — le mage ne peut pas sortir de chez lui" % tag)

		# 4. Portails : nombre demandé, tous distincts, tous praticables.
		if g.portals.size() != config.portal_count:
			_fail("%s : %d portails au lieu de %d" % [tag, g.portals.size(), config.portal_count])
		var seen := {}
		for p in g.portals:
			if not g.is_floor_v(p):
				_fail("%s : portail %s dans un mur" % [tag, p])
			if seen.has(p):
				_fail("%s : portail dupliqué en %s" % [tag, p])
			seen[p] = true

		# 5. Ennemis : nombre demandé, jamais sur le joueur.
		if g.enemy_spawns.size() != config.enemy_count:
			_fail("%s : %d ennemis au lieu de %d" % [tag, g.enemy_spawns.size(), config.enemy_count])
		for e in g.enemy_spawns:
			if e == g.player_spawn:
				_fail("%s : ennemi sur le spawn joueur" % tag)
			if not g.is_floor_v(e):
				_fail("%s : ennemi dans un mur" % tag)

		# 6. Gemmes : le compte exact, praticables, distinctes, jamais confondues
		#    avec un autre élément de jeu. Une gemme manquante = niveau
		#    INGAGNABLE, puisque la porte ne s'ouvre qu'au compte plein.
		if g.gems.size() != config.gem_count:
			_fail("%s : %d gemmes au lieu de %d — porte inouvrable" % [tag, g.gems.size(), config.gem_count])
		var gem_seen := {}
		for gem in g.gems:
			if not g.is_floor_v(gem):
				_fail("%s : gemme %s dans un mur" % [tag, gem])
			if g.distance_at(gem) < 0:
				_fail("%s : gemme %s inatteignable" % [tag, gem])
			if gem_seen.has(gem):
				_fail("%s : deux gemmes sur la même case %s" % [tag, gem])
			if g.is_house(gem) or g.portals.has(gem):
				_fail("%s : gemme %s sur la maison ou un portail" % [tag, gem])
			if gem == g.player_spawn or g.enemy_spawns.has(gem):
				_fail("%s : gemme %s sur un point d'apparition" % [tag, gem])
			gem_seen[gem] = true
			gem_distance_total += g.distance_at(gem)
			gem_distance_count += 1

		# 7. Potions : le compte exact, et jamais posées sur autre chose.
		if g.potions.size() != config.potion_count:
			_fail("%s : %d potions au lieu de %d" % [tag, g.potions.size(), config.potion_count])
		for potion in g.potions:
			if not g.is_floor_v(potion) or g.distance_at(potion) < 0:
				_fail("%s : potion %s hors du labyrinthe" % [tag, potion])
			if g.gems.has(potion) or g.portals.has(potion) or g.is_house(potion):
				_fail("%s : potion %s posée sur un autre objet" % [tag, potion])

		# 8. Le braiding a bien créé des boucles.
		for cell in cells:
			if g.floor_neighbors(cell).size() <= 1:
				dead_end_total += 1

	var dead_end_rate := float(dead_end_total) / maxf(1.0, float(floor_total))
	var gem_mean := float(gem_distance_total) / maxf(1.0, float(gem_distance_count))
	print("%s : %.1f%% de culs-de-sac · gemme à %.0f cases de la maison en moyenne" % [
		config.level_name, dead_end_rate * 100.0, gem_mean,
	])
	if dead_end_rate > 0.10:
		_fail("%s : trop de culs-de-sac (%.1f%%) — poursuite injuste" % [config.level_name, dead_end_rate * 100.0])


func _test_determinism() -> void:
	var config := LevelConfig.for_stage(1)
	var a := MazeGenerator.generate(config, 42)
	var b := MazeGenerator.generate(config, 42)
	if a.all_floor_cells() != b.all_floor_cells():
		_fail("déterminisme : même graine -> labyrinthes différents")
	if a.gems != b.gems or a.potions != b.potions:
		_fail("déterminisme : même graine -> gemmes ou potions ailleurs")
	if a.portals != b.portals or a.player_spawn != b.player_spawn or a.enemy_spawns != b.enemy_spawns:
		_fail("déterminisme : même graine -> placements différents")
	var c := MazeGenerator.generate(config, 43)
	if a.all_floor_cells() == c.all_floor_cells():
		_fail("déterminisme : graines différentes -> labyrinthe identique")
	print("déterminisme par graine : OK")
