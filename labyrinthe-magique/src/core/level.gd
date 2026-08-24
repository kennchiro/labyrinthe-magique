class_name Level
extends Node2D

## Assemble un niveau : génération, rendu, entités, caméra, objets à ramasser.
## Ne contient AUCUNE règle de victoire/défaite — c'est le rôle du GameManager.
## Ici on ne fait que peupler, cadrer, et RAPPORTER des faits.

const PLAYER_SCENE := preload("res://scenes/entities/player.tscn")
const HOUSE_SCENE := preload("res://scenes/entities/house.tscn")
const ENEMY_SCENE := preload("res://scenes/entities/enemy.tscn")
const PORTAL_SCENE := preload("res://scenes/entities/portal.tscn")
const GEM_SCENE := preload("res://scenes/entities/gem.tscn")
const POTION_SCENE := preload("res://scenes/entities/potion.tscn")
const ORB_SCENE := preload("res://scenes/entities/magic_orb.tscn")
const TELEPORT_EFFECT_SCENE := preload("res://scenes/entities/teleport_effect.tscn")
const ZONE_EFFECT_SCENE := preload("res://scenes/entities/zone_effect.tscn")
const IMPACT_EFFECT_SCENE := preload("res://scenes/entities/impact_effect.tscn")
const LAIR_SCENE := preload("res://scenes/entities/enemy_lair.tscn")
const WARP_SCENE := preload("res://scenes/fx/warp_effect.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://scenes/entities/damage_number.tscn")
const TILE_SIZE := MazeRenderer.TILE_SIZE
## Nombre de cases visibles sur le PLUS PETIT côté de l'écran, en poursuite.
## Se baser sur la hauteur seule marchait en 16/9 mais rendait le jeu illisible
## en portrait : sur un écran vertical, 11 cases de haut donne un zoom énorme et
## deux couloirs visibles. Le petit côté garantit un cadrage cohérent partout.
## 11 : assez pour anticiper un virage, assez peu pour ne jamais voir tout le
## labyrinthe d'un coup.
const FOLLOW_VIEW_TILES := 11.0
## Vitesse de RÉFÉRENCE, en cases par seconde. Les ennemis en dérivent via
## LevelConfig.enemy_speed_ratio.
##
## Le joueur, lui, court à la vitesse de SON personnage. Faire dériver les
## ennemis de la vitesse du mage choisi les ralentirait avec le Mage de Terre :
## choisir un personnage lent supprimerait le risque au lieu de le créer.
const REFERENCE_SPEED := 5.0
## Le champ de distances du joueur n'est recalculé que 3 fois par seconde.
## Recalculer à chaque frame ne rendrait pas les ennemis meilleurs — mais le
## léger retard, lui, donne au joueur une vraie fenêtre pour semer un poursuivant
## en enchaînant deux virages.
const AI_REFRESH := 0.3
## Distance (en cases) à laquelle un ennemi touche le joueur. Une case pleine, et
## non 0,6 : depuis que l'ennemi refuse le dernier pas au lieu de monter sur le
## mage (Enemy._update_desired), un poursuivant arrêté sur la case voisine est
## exactement à 1,0 — à 0,6 il resterait planté là sans jamais rien faire.
const CATCH_DISTANCE := 1.05
## Distance (en cases) à laquelle un objet est ramassé. Plus généreuse que la
## capture : rater une gemme en passant dessus serait une injustice, se faire
## attraper de justesse est du jeu.
const PICKUP_DISTANCE := 0.7
## Délai avant qu'une potion consommée ne réapparaisse ailleurs. Le pouvoir doit
## revenir — sinon le stage devient un stage sans sort dès la première minute —
## mais assez lentement pour qu'une charge gaspillée se paie.
const POTION_RESPAWN_DELAY := 20.0
## Débord autorisé de la caméra au-delà du labyrinthe, en FRACTION de la vue.
## Sans débord, sur un niveau à peine plus grand que l'écran, le mage se
## retrouve collé au bord dès qu'il longe une bordure et ne voit plus rien
## devant lui. Exprimé en fraction et non en cases : une valeur en cases
## représente une part d'écran très différente selon le zoom, et remplissait un
## tiers de l'écran de vide en portrait.
const CAMERA_PADDING_RATIO := 0.12

signal level_loaded(config: LevelConfig)
## Émis quand le mage pose le pied sur une case de la maison. Le Level ne décide
## PAS que c'est une victoire — la porte peut être scellée. Il constate.
signal player_reached_house
## Émis quand un ennemi touche le joueur. Même principe : le Level constate.
signal player_caught
## Émis à chaque téléportation du joueur ; `advantageous` dit si elle l'a
## réellement rapproché de la maison — de quoi donner un retour au joueur.
signal player_teleported(advantageous: bool)
## Émis à chaque gemme ramassée, puis une fois de plus quand c'était la dernière.
signal gem_collected(collected: int, total: int)
signal all_gems_collected
## Une potion ramassée : elle débloque un sort, pour toujours.
signal potion_collected(skill_slot: int)
## Un ennemi vient d'encaisser, de mourir, ou de revenir avec la vague suivante.
signal enemy_damaged(dealt: int)
signal enemy_killed
signal enemy_respawned
signal lair_destroyed(remaining: int)
## Le joueur vient d'utiliser une compétence — de quoi l'annoncer et l'illustrer.
signal ability_used(ability: Ability)
signal ability_refused(reason: String)

@onready var maze_renderer: MazeRenderer = $MazeRenderer
@onready var decor: DecorLayer = $DecorLayer
@onready var entities: Node2D = $Entities
@onready var compass: Compass = $Compass
@onready var camera: Camera2D = $Camera2D

var grid: MazeGrid = null
var config: LevelConfig = null
var player: Player = null
var house: House = null
var enemies: Array[Enemy] = []
var portals: Array[Portal] = []
var lairs: Array[EnemyLair] = []
## Effets dessinés du personnage joué, chargés au démarrage du niveau depuis
## sa planche découpée. Nuls si absents — les effets procéduraux prennent alors
## le relais, comme avant.
var _orb_texture: Texture2D = null
var _orb_frames := 1
var _impact_texture: Texture2D = null
var _zone_texture: Texture2D = null
var gems: Array[Gem] = []
var potions: Array[Potion] = []
var teleport_system: TeleportSystem = null
var combat: CombatSystem = null
var combat_context: CombatContext = null
## Personnage joué et ses points de vie. Le Level les PORTE, le GameManager les
## interprète : c'est lui qui décide qu'à zéro la partie est perdue.
var character: CharacterStats = null
var player_health: Health = null
## Ce que le joueur a acquis définitivement. Posé par le GameManager avant le
## chargement : le Level ne sauvegarde rien lui-même, il ne fait que consulter.
var progress: Progress = Progress.new()
## Compteur affiché dans l'interface (le concept art montre un compteur de portails).
var teleport_count := 0
var gems_total := 0
var gems_taken := 0

var _player_field := PackedInt32Array()
## Champ de distances vers CE QUE LE JOUEUR CHERCHE : la gemme la plus proche,
## ou la maison une fois le sac plein. Les portails s'en servent pour décider ce
## qui compte comme un gain — sans lui, le jeu annoncerait « le portail te
## rapproche » en mesurant la distance à une maison encore verrouillée.
var _objective_field := PackedInt32Array()
var _objective_cell := Vector2i(-1, -1)
var _ai_timer := 0.0
var _potion_timer := 0.0
var _orbs := {}          # index d'ennemi -> MagicOrb en vol
var _zone_nodes := {}    # id de zone -> ZoneEffect affiché
## index d'ennemi -> secondes avant que la vague suivante ne le ramène.
var _respawns := {}
## Repaire -> index de l'ennemi qu'il est en train de faire sortir.
var _pending_release := {}
var _rng := RandomNumberGenerator.new()
## Le mage était-il sur une case de maison à sa dernière case ? Sert à ne
## rapporter l'arrivée à la maison qu'en TRANSITION — il y COMMENCE la partie.
var _player_was_in_house := false
var overview := false
## Mode test : caméra rivée au joueur, sans lissage ni recadrage. Sert à
## capturer l'animation image par image, où tout déplacement du cadre fausse la
## comparaison entre deux frames.
var debug_lock_camera := false
var debug_zoom := 0.0


func load_level(p_config: LevelConfig, p_character: CharacterStats, rng_seed: int = 0) -> void:
	config = p_config
	character = p_character if p_character != null else CharacterCatalog.shadow()
	grid = MazeGenerator.generate(config, rng_seed)
	_load_character_fx()
	maze_renderer.set_stage(config.stage)
	maze_renderer.set_grid(grid)
	# Le décor dérive de la même graine que le labyrinthe : rejouer une graine
	# redonne exactement la même forêt, props compris.
	var decor_seed := rng_seed if rng_seed != 0 else grid.cols * 7919 + grid.portals.size()
	decor.set_stage(config.stage)
	decor.build(grid, TILE_SIZE, decor_seed)
	_rng.seed = decor_seed

	for child in entities.get_children():
		entities.remove_child(child)
		child.queue_free()
	house = null
	player = null
	enemies.clear()
	portals.clear()
	lairs.clear()
	gems.clear()
	potions.clear()
	_orbs.clear()
	_zone_nodes.clear()
	_respawns.clear()
	teleport_count = 0
	gems_taken = 0
	gems_total = grid.gems.size()
	_player_field = PackedInt32Array()
	_objective_field = PackedInt32Array()
	_objective_cell = Vector2i(-1, -1)
	_ai_timer = 0.0
	_potion_timer = 0.0

	teleport_system = TeleportSystem.new(grid)
	teleport_system.teleported.connect(_on_teleported)

	# Les points de vie viennent du PERSONNAGE, le stage n'ajoute que sa marge.
	player_health = Health.new(character.base_health + config.player_health_bonus)
	combat = CombatSystem.new(grid, character, player_health)
	combat_context = CombatContext.new(grid)
	combat.projectile_launched.connect(_on_projectile_launched)
	combat.projectile_hit.connect(_on_projectile_hit)
	combat.blast_fired.connect(_on_blast_fired)
	combat.zone_created.connect(_on_zone_created)
	combat.zone_expired.connect(_on_zone_expired)
	combat.wall_raised.connect(_on_wall_changed)
	combat.wall_fell.connect(_on_wall_changed)
	combat.blink_performed.connect(_on_blink)
	combat.summon_spawned.connect(_on_summon_spawned)
	combat.summon_moved.connect(_on_summon_moved)
	combat.summon_struck.connect(_on_summon_struck)
	combat.summon_expired.connect(_on_summon_expired)
	combat.enemy_damaged.connect(_on_enemy_damaged)
	combat.enemy_killed.connect(_on_enemy_killed)
	combat.enemy_soaked.connect(_on_enemy_status.bind("soak"))
	combat.enemy_staggered.connect(_on_enemy_status.bind("stagger"))
	combat.enemy_burning.connect(_on_enemy_status.bind("burn"))
	combat.enemy_pushed.connect(_on_enemy_pushed)
	combat.chain_arced.connect(_on_chain_arced)
	combat.use_refused.connect(func(reason: String) -> void: ability_refused.emit(reason))

	for i in grid.portals.size():
		var portal: Portal = PORTAL_SCENE.instantiate()
		entities.add_child(portal)
		portal.position = maze_renderer.cell_to_world(grid.portals[i])
		portal.setup(grid.portals[i], TILE_SIZE, float(i) * 0.9, i)
		portals.append(portal)

	for i in grid.lairs.size():
		var lair: EnemyLair = LAIR_SCENE.instantiate()
		entities.add_child(lair)
		lair.position = maze_renderer.cell_to_world(grid.lairs[i])
		lair.setup(grid.lairs[i], TILE_SIZE, i,
			config.lair_health if config.must_destroy_lairs else 0,
			config.lair_opening_delay)
		lair.destroyed.connect(_on_lair_destroyed.bind(lair))
		# On lie le REPAIRE lui-même, pas son rang : c'est lui qui sait quel
		# ennemi il est en train de faire sortir.
		lair.released.connect(_on_lair_released.bind(lair))
		lairs.append(lair)

	for i in grid.gems.size():
		var gem: Gem = GEM_SCENE.instantiate()
		entities.add_child(gem)
		gem.position = maze_renderer.cell_to_world(grid.gems[i])
		gem.setup(grid.gems[i], TILE_SIZE, i)
		gems.append(gem)

	for cell in grid.potions:
		_spawn_potion(cell)

	house = HOUSE_SCENE.instantiate()
	entities.add_child(house)
	house.position = maze_renderer.cell_to_world(grid.house_center)
	house.setup(TILE_SIZE, config.stage)
	house.set_seal(missing_gem_colors())

	player = PLAYER_SCENE.instantiate()
	# Le personnage est posé AVANT l'entrée dans l'arbre : le _ready du joueur
	# charge sa planche, il lui faut déjà savoir lequel des sept il incarne.
	player.set_character(character)
	entities.add_child(player)
	player.setup(grid, grid.player_spawn, character.move_speed, TILE_SIZE)
	player.mover.cell_entered.connect(_on_player_cell_entered)
	compass.setup(TILE_SIZE)
	_player_was_in_house = grid.is_house(grid.player_spawn)
	_walk_player_out_of_house()

	for i in grid.enemy_spawns.size():
		var enemy: Enemy = ENEMY_SCENE.instantiate()
		entities.add_child(enemy)
		# Les gobelins occupent les premiers index : ce sont eux qu'on voit en
		# premier à l'écran, et c'est l'espèce qui donne son nom au stage 2.
		# L'espèce tourne dans le roster du stage : le stage montre donc toutes
		# ses créatures, la nouvelle comprise, avant d'en répéter une.
		var id := config.species_at(i)
		enemy.setup_enemy(grid, grid.enemy_spawns[i],
			REFERENCE_SPEED * config.enemy_speed(id), TILE_SIZE,
			config.enemy_detection_radius, id, config.enemy_health(id))
		enemies.append(enemy)
	_stagger_initial_spawns()
	_refresh_ai()

	_update_camera(true)
	level_loaded.emit(config)


func set_overview(value: bool) -> void:
	overview = value
	_update_camera(true)


func _process(delta: float) -> void:
	_update_camera(false)
	if teleport_system != null:
		teleport_system.update(delta)
	if combat != null:
		_refresh_context()
		combat.update(delta, combat_context)
	_update_respawns(delta)
	_update_ai(delta)
	_update_enemy_target()
	_update_portal_highlight()
	_update_enemy_portals()
	_update_pickups(delta)
	_update_orbs()
	_update_compass()
	_check_capture()


# --- Objectif : gemmes et potions ------------------------------------------------

func gems_remaining() -> int:
	return gems_total - gems_taken


## La maison du mage s'ouvre quand TOUT l'objectif est rempli : les gemmes, et —
## au dernier épisode des stages 3 et 9 — les repaires abattus.
func house_is_open() -> bool:
	return gems_remaining() <= 0 and lairs_remaining() <= 0


## Couleurs des gemmes qui restent à trouver — le sceau de la maison et le
## bandeau affichent exactement la même chose, à partir de cette seule source.
func missing_gem_colors() -> Array[Color]:
	var out: Array[Color] = []
	for gem in gems:
		if is_instance_valid(gem):
			out.append(gem.color())
	return out


func _update_pickups(delta: float) -> void:
	if player == null:
		return
	var player_position := player.mover.grid_position()

	for i in range(gems.size() - 1, -1, -1):
		var gem: Gem = gems[i]
		if not is_instance_valid(gem):
			gems.remove_at(i)
			continue
		if Vector2(gem.cell).distance_to(player_position) >= PICKUP_DISTANCE:
			continue
		_collect_gem(i)

	for i in range(potions.size() - 1, -1, -1):
		var potion: Potion = potions[i]
		if not is_instance_valid(potion):
			potions.remove_at(i)
			continue
		if Vector2(potion.cell).distance_to(player_position) >= PICKUP_DISTANCE:
			continue
		potions.remove_at(i)
		# La potion ne remplit plus une jauge : elle DÉBLOQUE le sort suivant,
		# définitivement. Une compétence acquise n'est pas un consommable.
		var gained := progress.unlock_next_skill()
		_spawn_effect(potion.cell, Potion.TINT)
		potion.queue_free()
		# Le compteur de réapparition ne démarre qu'ici : tant qu'une potion
		# traîne par terre, en faire pousser une deuxième n'a pas de sens.
		_potion_timer = POTION_RESPAWN_DELAY
		potion_collected.emit(gained)

	if config.potion_count > 0 and potions.size() < config.potion_count and _potion_timer > 0.0:
		_potion_timer -= delta
		if _potion_timer <= 0.0:
			var cell := MazeGenerator.pick_potion_cell(grid, _rng, player.current_cell(), 8)
			if cell.x >= 0:
				_spawn_potion(cell)
				_spawn_effect(cell, Potion.TINT)


## Ramassage d'une gemme, par son index. Un seul chemin de code, appelé par le
## joueur comme par les outils de développement : une victoire déclenchée en
## ligne de commande emprunte donc exactement la même route qu'une vraie.
func _collect_gem(index: int) -> void:
	var gem: Gem = gems[index]
	gems.remove_at(index)
	gems_taken += 1
	_spawn_effect(gem.cell, gem.color())
	gem.queue_free()
	house.set_seal(missing_gem_colors())
	# La cible change à l'instant du ramassage : boussole et portails doivent
	# viser la suivante tout de suite, pas au prochain rafraîchissement d'IA.
	_refresh_objective()
	gem_collected.emit(gems_taken, gems_total)
	if gems_remaining() == 0:
		all_gems_collected.emit()


## Réservé aux outils de développement : vide le sac d'un coup pour capturer
## l'écran de victoire sans jouer la tournée complète.
func debug_collect_all_gems() -> void:
	while not gems.is_empty():
		_collect_gem(gems.size() - 1)


func _spawn_potion(cell: Vector2i) -> void:
	var potion: Potion = POTION_SCENE.instantiate()
	entities.add_child(potion)
	potion.position = maze_renderer.cell_to_world(cell)
	potion.setup(cell, TILE_SIZE)
	potions.append(potion)


## Gemme la plus proche EN DISTANCE DE CHEMIN. `_player_field` mesure depuis le
## joueur : la valeur lue sur la case d'une gemme est donc le trajet réel.
func _nearest_gem() -> Gem:
	var best: Gem = null
	var best_distance := 1 << 30
	for gem in gems:
		if not is_instance_valid(gem):
			continue
		var distance := Pathfinder.value_at(grid, _player_field, gem.cell)
		if distance < 0:
			continue
		if distance < best_distance:
			best_distance = distance
			best = gem
	return best


func _update_compass() -> void:
	if player == null:
		return
	var gem := _nearest_gem()
	if gem == null:
		# Toutes ramassées : la boussole se retourne vers la maison, désormais
		# ouverte. Sans ça, elle disparaîtrait pile au moment où le joueur a le
		# plus besoin de savoir où il va.
		if house != null and not overview:
			compass.point_to(player.position, house.position, Color("#ffd479"))
		else:
			compass.clear()
		return
	compass.point_to(player.position, gem.position, gem.color())


# --- Combat ----------------------------------------------------------------------

## Compétences dans l'ordre du HUD : attaque, sorts 1 à 3, ultime.
func action_bar() -> Array[Ability]:
	return character.action_bar() if character != null else [] as Array[Ability]


func ability_at(slot: int) -> Ability:
	var bar := action_bar()
	return bar[slot] if slot >= 0 and slot < bar.size() else null


## Le geste est-il possible MAINTENANT ? La disponibilité de l'ULTIME ne se juge
## pas ici : elle dépend du compteur de kills, que le GameManager tient.
func can_use(slot: int) -> bool:
	var ability := ability_at(slot)
	if ability == null or combat == null:
		return false
	if not progress.skill_unlocked(slot):
		return false
	if not combat.can_use(ability):
		return false
	# Un projectile sans cible à portée serait un tir dans le vide : l'interface
	# doit pouvoir griser le bouton AVANT que le joueur n'appuie.
	if ability.kind == Ability.Kind.PROJECTILE:
		return combat.find_target(ability, combat_context) >= 0
	return true


## Retourne false si rien n'est parti — et dans ce cas aucune ressource n'a été
## consommée.
func use_ability(slot: int) -> bool:
	var ability := ability_at(slot)
	if ability == null or combat == null or player == null:
		return false
	_refresh_context()
	if not combat.use(ability, combat_context):
		return false
	player.play_cast()
	ability_used.emit(ability)
	return true


func _enemy_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for enemy in enemies:
		cells.append(enemy.current_cell())
	return cells


## Photo du monde passée au CombatSystem. Elle est refaite à chaque frame : les
## ennemis bougent, et un sort lancé sur des positions périmées taperait à côté.
func _refresh_context() -> void:
	if combat_context == null or player == null:
		return
	combat_context.player_cell = player.mover.nearest_cell()
	combat_context.player_facing = player.facing()
	combat_context.player_field = _player_field
	var cells := _enemy_cells()
	var healths: Array[Health] = []
	for enemy in enemies:
		healths.append(enemy.health)
	# Les repaires destructibles suivent les ennemis dans les MÊMES tableaux, et
	# tous y figurent — même abattus. Un tableau qui rétrécirait décalerait les
	# index sous les projectiles déjà en vol, qui iraient frapper le voisin.
	combat_context.structures_from = -1
	if config != null and config.must_destroy_lairs and not lairs.is_empty():
		combat_context.structures_from = cells.size()
		for lair in lairs:
			cells.append(lair.cell)
			healths.append(lair.health)
	combat_context.enemy_cells = cells
	combat_context.enemy_health = healths


# --- Vagues ----------------------------------------------------------------------

## Un ennemi tué revient. Le kill, lui, est déjà compté et ne se reprend pas :
## sans ce retour, un joueur patient nettoierait le labyrinthe et la poursuite —
## le cœur du jeu — disparaîtrait.
func _update_respawns(delta: float) -> void:
	for index in _respawns.keys():
		var left: float = _respawns[index] - delta
		if left > 0.0:
			_respawns[index] = left
			continue
		_respawns.erase(index)
		if index >= enemies.size():
			continue
		# L'ennemi ne réapparaît plus n'importe où : sa maison s'ouvre, et il en
		# sort. L'ouverture dure une seconde — c'est l'avertissement qui laisse
		# au joueur le temps de s'écarter du coin.
		if lairs.is_empty():
			_release_enemy(index, grid.enemy_spawns[index % grid.enemy_spawns.size()])
			continue
		var lair := _lair_for()
		if lair == null:
			if config.must_destroy_lairs and lairs_remaining() == 0:
				# Les deux maisons sont tombées : la vague s'arrête là. C'est
				# tout le prix de les avoir abattues.
				continue
			# Les deux maisons sont déjà en train de lâcher quelqu'un. On patiente
			# une seconde plutôt que d'écraser une sortie en cours : l'ennemi
			# écrasé ne reviendrait JAMAIS, sa file d'attente ayant été vidée.
			_respawns[index] = config.lair_queue_delay
			continue
		_pending_release[lair] = index
		lair.open()


## Les ennemis naissent tous sur les cases des repaires — il n'y en a que deux.
## Au-delà de deux ennemis, ils se superposeraient donc au démarrage, trois
## sprites sur une case. Les surnuméraires attendent leur tour DANS la maison et
## en sortent l'un après l'autre : le labyrinthe n'est jamais vide, et la règle
## « les ennemis viennent de leur maison » se voit dès la première seconde.
func _stagger_initial_spawns() -> void:
	if lairs.is_empty():
		return
	for i in range(lairs.size(), enemies.size()):
		enemies[i].set_dead(true)
		_respawns[i] = float(i - lairs.size() + 1) * config.initial_release_step


## Repaire le plus ÉLOIGNÉ du joueur : le renvoyer dans la maison où le mage se
## tient serait une exécution, pas une réapparition.
func _lair_for() -> EnemyLair:
	var best: EnemyLair = null
	var best_distance := -1
	for lair in lairs:
		if _pending_release.has(lair) or lair.is_opening() or lair.is_destroyed():
			continue
		var distance := Pathfinder.value_at(grid, _player_field, lair.cell)
		if distance > best_distance:
			best_distance = distance
			best = lair
	return best


## Une maison tombe. L'ennemi qu'elle allait lâcher est renvoyé dans la file :
## il sortira par l'autre, ou plus du tout si les deux sont à terre.
func _on_lair_destroyed(lair: EnemyLair) -> void:
	_spawn_impact(lair.cell, Element.Kind.SUPREME, 3.2, 1.4)
	if _pending_release.has(lair):
		_respawns[int(_pending_release[lair])] = config.lair_queue_delay
		_pending_release.erase(lair)
	lair_destroyed.emit(lairs_remaining())


## Combien de maisons tiennent encore. Zéro = la source est coupée.
func lairs_remaining() -> int:
	var left := 0
	for lair in lairs:
		if lair.is_vulnerable() and not lair.is_destroyed():
			left += 1
	return left


func _on_lair_released(lair: EnemyLair) -> void:
	if not _pending_release.has(lair):
		return
	var index := int(_pending_release[lair])
	_pending_release.erase(lair)
	_release_enemy(index, lair.cell)


func _release_enemy(index: int, cell: Vector2i) -> void:
	if index >= enemies.size():
		return
	var enemy: Enemy = enemies[index]
	enemy.revive_at(cell)
	enemy.player_field = _player_field
	_spawn_effect(cell, Color("#ff9a7a"))
	enemy_respawned.emit()


# --- Retours visuels du combat ---------------------------------------------------

func _load_character_fx() -> void:
	var folder := "res://assets/characters/%s/" % character.id
	_orb_texture = _texture_or_null(folder + "orb.png")
	_impact_texture = _texture_or_null(folder + "impact.png")
	_zone_texture = _texture_or_null(folder + "zone.png")
	_orb_frames = 1
	var meta := FileAccess.get_file_as_string(folder + "orb.json")
	var parsed: Variant = JSON.parse_string(meta)
	if parsed != null:
		_orb_frames = maxi(1, int((parsed as Dictionary).get("frames", 1)))


func _texture_or_null(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null


func _on_projectile_launched(ability: Ability, index: int, path: Array, duration: float) -> void:
	var points := PackedVector2Array()
	for cell in path:
		points.append(maze_renderer.cell_to_world(cell))
	var orb: MagicOrb = ORB_SCENE.instantiate()
	entities.add_child(orb)
	orb.setup(points, duration, TILE_SIZE, Element.color(ability.element),
		_orb_texture, _orb_frames)
	_orbs[index] = orb


func _on_projectile_hit(ability: Ability, index: int, cell: Vector2i) -> void:
	if _orbs.has(index):
		var orb: MagicOrb = _orbs[index]
		if is_instance_valid(orb):
			orb.burst()
		_orbs.erase(index)
	_spawn_impact(cell, ability.element, maxf(0.9, ability.radius),
		ImpactEffect.DURATION, _impact_texture)


func _on_blast_fired(ability: Ability, cell: Vector2i) -> void:
	# L'éclat prend le RAYON RÉEL du sort : le joueur doit voir jusqu'où il a
	# porté, sinon il ne peut pas apprendre à s'en servir.
	_spawn_impact(cell, ability.element, ability.radius, 0.75, _impact_texture)


func _on_zone_created(zone_id: int, ability: Ability, cell: Vector2i) -> void:
	var zone: ZoneEffect = ZONE_EFFECT_SCENE.instantiate()
	entities.add_child(zone)
	zone.position = maze_renderer.cell_to_world(cell)
	zone.setup(TILE_SIZE, Element.color(ability.element), ability.radius,
		ability.duration, _zone_texture)
	_zone_nodes[zone_id] = zone


func _on_zone_expired(zone_id: int) -> void:
	if _zone_nodes.has(zone_id):
		var zone: ZoneEffect = _zone_nodes[zone_id]
		if is_instance_valid(zone):
			zone.queue_free()
		_zone_nodes.erase(zone_id)


## Un mur de pierre change la forme du labyrinthe : le rendu doit être refait,
## et les champs de distances aussi — sinon les ennemis continuent de courir
## droit à travers la pierre qui vient d'apparaître.
func _on_wall_changed(_cell: Vector2i) -> void:
	maze_renderer.set_grid(grid)
	_refresh_ai()


## Le mage se translate. La colonne joue aux DEUX cases, celle qu'il quitte et
## celle où il arrive : sans l'annonce au départ, le joueur perd de vue son
## propre personnage et croit à un bug d'affichage.
## id d'invocation -> SummonVisual. Le CombatSystem chasse, ces nœuds montrent.
var _summon_nodes := {}


func _on_summon_spawned(id: int, kind_id: String, grid_position: Vector2) -> void:
	var visual := SummonVisual.new()
	visual.z_index = 10
	entities.add_child(visual)
	visual.setup(kind_id, TILE_SIZE)
	visual.position = (grid_position + Vector2(0.5, 0.5)) * float(TILE_SIZE)
	_summon_nodes[id] = visual
	_spawn_effect(Vector2i(grid_position.round()), Color("#b06cff"), 1.4)


func _on_summon_moved(id: int, grid_position: Vector2, facing: Vector2i) -> void:
	var visual: SummonVisual = _summon_nodes.get(id)
	if visual != null and is_instance_valid(visual):
		visual.position = (grid_position + Vector2(0.5, 0.5)) * float(TILE_SIZE)
		visual.set_facing(facing)


func _on_summon_struck(id: int, _target: int) -> void:
	var visual: SummonVisual = _summon_nodes.get(id)
	if visual != null and is_instance_valid(visual):
		visual.flash_strike()


func _on_summon_expired(id: int) -> void:
	var visual: SummonVisual = _summon_nodes.get(id)
	if visual != null and is_instance_valid(visual):
		_spawn_effect(Vector2i((visual.position / float(TILE_SIZE)).round()),
			Color("#7a5bc4"), 1.2)
		visual.queue_free()
	_summon_nodes.erase(id)


func _on_blink(_from: Vector2i, to: Vector2i) -> void:
	if player == null:
		return
	_spawn_warp(player.mover.nearest_cell())
	player.mover.teleport_to(to)
	player.snap_to_mover()
	_spawn_warp(to)
	player.play_warp()
	_refresh_ai()


func _spawn_warp(cell: Vector2i) -> void:
	var effect: WarpEffect = WARP_SCENE.instantiate()
	entities.add_child(effect)
	effect.position = maze_renderer.cell_to_world(cell)
	effect.setup(player.character_id, TILE_SIZE)


func _on_enemy_damaged(index: int, dealt: int, ability: Ability) -> void:
	var lair := _structure_at(index)
	if lair != null:
		lair.flash_hit()
		if dealt > 0:
			_spawn_damage_number(lair.position, dealt, ability)
		return
	if index >= enemies.size():
		return
	enemies[index].flash_hit()
	if dealt <= 0:
		return
	_spawn_damage_number(enemies[index].position, dealt, ability)
	enemy_damaged.emit(dealt)


func _spawn_damage_number(at: Vector2, dealt: int, ability: Ability) -> void:
	var number: DamageNumber = DAMAGE_NUMBER_SCENE.instantiate()
	entities.add_child(number)
	number.position = at
	number.setup(dealt, Element.color(ability.element), TILE_SIZE, ability.is_ultimate)


## La cible visée est-elle un repaire ? `null` si c'est une créature.
func _structure_at(index: int) -> EnemyLair:
	if combat_context == null or not combat_context.is_structure(index):
		return null
	var rank := index - combat_context.structures_from
	return lairs[rank] if rank < lairs.size() else null


## Un trait élémentaire a marqué un ennemi : on le montre. La physique est
## déjà faite dans le CombatSystem — ici on ne fait qu'habiller.
func _on_enemy_status(index: int, duration: float, status: String) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	var enemy: Enemy = enemies[index]
	match status:
		"soak": enemy.soak(duration)
		"stagger": enemy.stagger(duration)
		"burn": enemy.burn_glow(duration)


func _on_enemy_pushed(index: int, cell: Vector2i) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	var enemy: Enemy = enemies[index]
	enemy.mover.teleport_to(cell)
	enemy.snap_to_mover()
	_spawn_impact(cell, Element.Kind.AIR, 0.9, 0.5)


func _on_chain_arced(_from_index: int, to_index: int) -> void:
	if _structure_at(to_index) != null or to_index >= enemies.size():
		return
	_spawn_impact(enemies[to_index].current_cell(), Element.Kind.THUNDER, 0.8, 0.5)


func _on_enemy_killed(index: int) -> void:
	# Une maison abattue n'est pas un kill : elle ne compte pas pour l'ultime,
	# et elle ne revient pas. C'est `EnemyLair.destroyed` qui prend le relais.
	var lair := _structure_at(index)
	if lair != null:
		if _orbs.has(index):
			var struck: MagicOrb = _orbs[index]
			if is_instance_valid(struck):
				struck.burst()
			_orbs.erase(index)
		return
	if index >= enemies.size():
		return
	var enemy: Enemy = enemies[index]
	if _orbs.has(index):
		var orb: MagicOrb = _orbs[index]
		if is_instance_valid(orb):
			orb.burst()
		_orbs.erase(index)
	_spawn_impact(enemy.current_cell(), Element.Kind.SUPREME, 2.0, 0.8)
	enemy.set_dead(true)
	_respawns[index] = config.enemy_respawn_delay
	enemy_killed.emit()


## La cible bouge pendant le vol : on lui recolle le dernier point du trajet à
## chaque frame, sinon l'orbe irait exploser là où l'ennemi se tenait au tir.
func _update_orbs() -> void:
	for index in _orbs.keys():
		var orb: MagicOrb = _orbs[index]
		if not is_instance_valid(orb):
			_orbs.erase(index)
			continue
		if index < enemies.size():
			orb.retarget(enemies[index].position)


# --- Portails --------------------------------------------------------------------

## Le joueur est-il sur un portail utilisable maintenant ?
func player_can_teleport() -> bool:
	return player != null and teleport_system != null and teleport_system.can_teleport(player.mover)


func player_on_portal() -> bool:
	return player != null and teleport_system != null and teleport_system.is_on_portal(player.mover)


func player_teleport_cooldown() -> float:
	if player == null or teleport_system == null:
		return 0.0
	return teleport_system.cooldown_left(player.mover)


## Vrai si toute destination éloignera fortement le joueur — typiquement parce
## qu'il est déjà plus proche du but que le reste du réseau.
func player_teleport_is_gamble() -> bool:
	if player == null or not player_on_portal():
		return false
	return PortalNetwork.is_pure_gamble(grid, player.mover.nearest_cell(), _objective_field)


## Utilisée quand le joueur encaisse un coup sans mourir : sans ce répit, un
## ennemi collé lui retirerait tous ses points de vie dans la même seconde.
func grant_player_invulnerability(seconds: float) -> void:
	if player != null and teleport_system != null:
		teleport_system.grant_invulnerability(player.mover, seconds)


func try_teleport_player() -> bool:
	if player == null or teleport_system == null:
		return false
	return teleport_system.try_teleport_player(player.mover, _enemy_cells(), _objective_field)


func _update_portal_highlight() -> void:
	var ready := player_can_teleport()
	var current := player.mover.nearest_cell() if player != null else Vector2i(-1, -1)
	for portal in portals:
		portal.highlighted = ready and portal.cell == current


## L'ENTRÉE EN SCÈNE : le mage apparaît au centre de SA maison et en sort par
## la porte sud, en marchant — pas posé au hasard dans un couloir. On réutilise
## le suivi de chemin du mode « toucher le chemin » : la première entrée du
## joueur (clavier, manche, tap) reprend la main immédiatement, la sortie n'est
## donc jamais une cinématique qui retient le personnage.
func _walk_player_out_of_house() -> void:
	if player == null or not grid.is_house(player.mover.cell):
		return
	var exit := grid.house_center + Vector2i(0, 1)
	while grid.in_bounds(exit.x, exit.y) and grid.is_house(exit):
		exit.y += 1
	if not grid.is_floor_v(exit):
		return
	player.walk_to(exit, Pathfinder.distance_field(grid, [exit] as Array[Vector2i]))


## Ordre de déplacement du mode « toucher le chemin » : le joueur a tapé ce
## point de l'ÉCRAN, on le traduit en case et on donne au mage un champ de
## distances BFS à descendre — le même mécanisme que les poursuivants.
##
## La cible ne peut être qu'une case VISIBLE (on ne tape pas hors de l'écran,
## et la caméra ne montre que ~11 cases) : l'itinéraire reste local, ce mode ne
## résout pas le labyrinthe à la place du joueur.
##
## Rend faux si le tap ne désigne rien de praticable — mur, hors grille, ou
## case coupée du mage (un mur de pierre peut isoler un couloir) : donner un
## ordre inexécutable en silence se lirait comme une entrée perdue.
func order_player_walk(screen_point: Vector2) -> bool:
	if player == null or grid == null:
		return false
	var world := get_canvas_transform().affine_inverse() * screen_point
	var cell := maze_renderer.world_to_cell(world)
	if not grid.in_bounds(cell.x, cell.y) or not grid.is_floor_v(cell):
		return false
	var field := Pathfinder.distance_field(grid, [cell] as Array[Vector2i])
	if Pathfinder.value_at(grid, field, player.mover.decision_cell()) < 0:
		return false
	player.walk_to(cell, field)
	var marker := MoveMarker.new()
	# Enfant du Level et non d'Entities : le y-sort n'a pas à trier une marque
	# au sol. z entre les gemmes (4) et les acteurs (10) — sous les pieds.
	marker.z_index = 5
	add_child(marker)
	marker.position = maze_renderer.cell_to_world(cell)
	marker.setup(player, cell, TILE_SIZE)
	return true


## Appelé à chaque frame plutôt que sur un signal d'entrée de case : c'est le
## cooldown qui garantit un seul tirage par passage (TeleportSystem pose le
## cooldown même quand l'ennemi décide de NE PAS prendre le portail).
## Cet appel est identique à celui de la simulation d'équilibrage — le jeu et
## le test exercent donc strictement le même chemin de code.
func _update_enemy_portals() -> void:
	if teleport_system == null:
		return
	for enemy in enemies:
		if enemy.dead:
			continue
		if teleport_system.is_on_portal(enemy.mover):
			teleport_system.try_teleport_enemy(enemy.mover, _player_field)


func _on_teleported(mover: GridMover, from_cell: Vector2i, to_cell: Vector2i, advantageous: bool) -> void:
	var actor: Actor = player if (player != null and mover == player.mover) else null
	if actor == null:
		for enemy in enemies:
			if enemy.mover == mover:
				actor = enemy
				break
	if actor == null:
		return

	actor.snap_to_mover()
	for portal in portals:
		if portal.cell == from_cell:
			portal.flash_teleport()
	var tint: Color = Color("#8fe6ff") if actor == player else Color("#ff9a7a")
	_spawn_effect(from_cell, tint)
	_spawn_effect(to_cell, tint)

	if actor == player:
		teleport_count += 1
		# Un ordre de marche donné AVANT le saut visait l'ancien quartier : le
		# laisser courir ferait retraverser la moitié du labyrinthe tout seul.
		player.cancel_path()
		# Le champ d'IA date d'avant le saut : sans recalcul immédiat, les
		# ennemis convergeraient encore vers l'ancienne position pendant 300 ms.
		_refresh_ai()
		player_teleported.emit(advantageous)


## Éclat élémentaire : c'est lui qui distingue une boule de feu d'un jet d'eau.
## La graine dérive de la case touchée, donc deux impacts au même endroit se
## ressemblent — indispensable pour comparer deux captures d'écran.
func _spawn_impact(cell: Vector2i, element: Element.Kind, radius: float,
		duration: float = ImpactEffect.DURATION, drawn: Texture2D = null) -> void:
	var impact: ImpactEffect = IMPACT_EFFECT_SCENE.instantiate()
	entities.add_child(impact)
	impact.position = maze_renderer.cell_to_world(cell)
	impact.setup(TILE_SIZE, element, radius, duration, cell.x * 733 + cell.y * 199 + 1, drawn)


func _spawn_effect(cell: Vector2i, tint: Color, size_tiles: float = 1.7) -> void:
	var effect: TeleportEffect = TELEPORT_EFFECT_SCENE.instantiate()
	entities.add_child(effect)
	effect.position = maze_renderer.cell_to_world(cell)
	effect.setup(TILE_SIZE, tint, size_tiles)


func _update_ai(delta: float) -> void:
	if player == null or enemies.is_empty():
		return
	_ai_timer -= delta
	if _ai_timer <= 0.0:
		_ai_timer = AI_REFRESH
		_refresh_ai()


## La case du mage, à chaque frame. Le champ de distances de l'IA, lui, ne se
## recalcule que toutes les 300 ms — assez pour choisir un chemin, pas pour
## décider de s'arrêter devant quelqu'un qui bouge (voir Enemy._update_desired).
func _update_enemy_target() -> void:
	if player == null:
		return
	var cell := player.mover.nearest_cell()
	for enemy in enemies:
		enemy.player_cell = cell


func _refresh_ai() -> void:
	if player == null:
		return
	var sources: Array[Vector2i] = [player.current_cell()]
	_player_field = Pathfinder.distance_field(grid, sources)
	for enemy in enemies:
		enemy.player_field = _player_field
	_refresh_objective()


## Recalculé seulement quand la CIBLE change — pas à chaque frame, ni même à
## chaque rafraîchissement d'IA : entre deux gemmes, le champ reste valable.
func _refresh_objective() -> void:
	var gem := _nearest_gem()
	var cell := gem.cell if gem != null else grid.house_center
	if cell == _objective_cell and not _objective_field.is_empty():
		return
	_objective_cell = cell
	_objective_field = Pathfinder.distance_field(grid, [cell] as Array[Vector2i])


## Distance continue et non comparaison de cases : deux entités qui se croisent
## de face dans un couloir occupent des cases différentes à chaque frame et
## pourraient se traverser sans jamais partager une case.
func _check_capture() -> void:
	if player == null:
		return
	var sheltered := teleport_system != null and teleport_system.is_invulnerable(player.mover)
	var player_position := player.mover.grid_position()
	var touched := false
	for enemy in enemies:
		if enemy.dead:
			continue
		if enemy.mover.grid_position().distance_to(player_position) >= CATCH_DISTANCE:
			continue
		# Le coup part au contact, invulnérabilité ou non. Pendant le répit qui
		# suit un coup encaissé, le joueur doit VOIR que l'ennemi le frappe encore :
		# un gobelin collé qui ne fait rien pendant deux secondes se lit comme un
		# bug, pas comme un sursis. Le sursis, lui, reste entier — c'est `sheltered`
		# qui décide des dégâts, pas l'animation.
		enemy.strike()
		touched = true
	if touched and not sheltered:
		player_caught.emit()


func _update_camera(snap: bool) -> void:
	if grid == null:
		return
	var maze_px := maze_renderer.maze_pixel_size()
	var view := Vector2(get_viewport_rect().size)

	if overview or player == null:
		var zoom_fit := minf(view.x / maze_px.x, view.y / maze_px.y) * 0.95
		camera.zoom = Vector2(zoom_fit, zoom_fit)
		camera.position_smoothing_enabled = false
		camera.position = maze_px * 0.5
		return

	var zoom_value := minf(view.x, view.y) / (FOLLOW_VIEW_TILES * TILE_SIZE)
	if debug_zoom > 0.0:
		zoom_value = debug_zoom
	if debug_lock_camera:
		camera.zoom = Vector2(zoom_value, zoom_value)
		camera.position_smoothing_enabled = false
		camera.position = player.position
		return
	camera.zoom = Vector2(zoom_value, zoom_value)

	# Clamp manuel plutôt que limit_left/right/top/bottom : les limites de Godot
	# se comportent mal quand la vue est plus grande que le monde sur un axe
	# (tremblement au bord). Ici on décide explicitement, axe par axe :
	# soit on recentre sur le labyrinthe, soit on borde le joueur.
	var visible := view / zoom_value
	var target := player.position
	target.x = _clamp_axis(target.x, visible.x, maze_px.x, visible.x * CAMERA_PADDING_RATIO)
	target.y = _clamp_axis(target.y, visible.y, maze_px.y, visible.y * CAMERA_PADDING_RATIO)

	if snap:
		camera.position_smoothing_enabled = false
		camera.position = target
		camera.reset_smoothing()
		camera.position_smoothing_enabled = true
	else:
		camera.position = target


static func _clamp_axis(value: float, visible: float, world: float, padding: float) -> float:
	var low := visible * 0.5 - padding
	var high := world - visible * 0.5 + padding
	if low >= high:
		return world * 0.5   # le labyrinthe tient en entier : on le centre
	return clampf(value, low, high)


## En TRANSITION, pas par case : le mage COMMENCE la partie dans sa maison et
## en sort en la traversant — émettre à chaque case de maison ferait clignoter
## « Porte scellée » dès la frame zéro. On ne rapporte donc que l'ENTRÉE, quand
## la case précédente était dehors.
func _on_player_cell_entered(cell: Vector2i) -> void:
	var in_house := grid.is_house(cell)
	if in_house and not _player_was_in_house:
		player_reached_house.emit()
	_player_was_in_house = in_house
