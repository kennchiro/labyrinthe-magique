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
const SHOCKWAVE_SCENE := preload("res://scenes/fx/shockwave.tscn")
const IMPLOSION_SCENE := preload("res://scenes/fx/implosion.tscn")
## Temps d'affichage d'une faille, en secondes. Juste de quoi voir sortir les
## deux ombres — voir `_on_rift_opened`.
const RIFT_SHOW := 2.4
const GAS_PUFF_SCENE := preload("res://scenes/fx/gas_puff.tscn")
const CYCLONE_SCENE := preload("res://scenes/fx/cyclone_column.tscn")
const BOLT_SCENE := preload("res://scenes/fx/bolt_strike.tscn")
const WARP_TRAIL_SCENE := preload("res://scenes/fx/warp_trail.tscn")
const METEOR_SCENE := preload("res://scenes/fx/meteor.tscn")
const COLUMN_SCENE := preload("res://scenes/fx/pressure_column.tscn")
const AURA_SCENE := preload("res://scenes/fx/empower_aura.tscn")
const BUBBLE_SCENE := preload("res://scenes/fx/shield_bubble.tscn")
const WAVE_SCENE := preload("res://scenes/fx/wave_front.tscn")
const ARC_SCENE := preload("res://scenes/fx/lightning_arc.tscn")
const CLOUD_SCENE := preload("res://scenes/fx/storm_cloud.tscn")
const SKY_SCENE := preload("res://scenes/fx/sky_cloud.tscn")
const CREST_SCENE := preload("res://scenes/fx/spell_crest.tscn")
const SPIKE_SCENE := preload("res://scenes/fx/earth_spike.tscn")
const TURRET_SCENE := preload("res://scenes/fx/crystal_turret.tscn")
const THROWN_SCENE := preload("res://scenes/fx/thrown_stone.tscn")
const BURST_SCENE := preload("res://scenes/fx/spike_burst.tscn")
const SLIDE_SCENE := preload("res://scenes/fx/rock_slide.tscn")
const TORNADO_SCENE := preload("res://scenes/fx/tornado.tscn")
const DRAWN_BURST_SCENE := preload("res://scenes/fx/drawn_burst.tscn")
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
## Une potion ramassée : le GameManager en charge l'Extra Power.
signal potion_collected
## Un ennemi vient d'encaisser, de mourir, ou de revenir avec la vague suivante.
signal enemy_damaged(dealt: int)
signal enemy_killed
signal enemy_defeated(species: String, boss: bool, at: Vector2)
signal enemy_respawned
signal gem_stolen
## Le boss du chapitre surgit, puis il tombe. Le GameManager dit ce que ça veut dire.
signal boss_appeared(name: String)
signal boss_defeated
signal lair_destroyed(remaining: int)
signal player_empowered(bonus: int, duration: float)
signal player_shielded(amount: int)
signal player_calmed
## Le joueur vient d'utiliser une compétence — de quoi l'annoncer et l'illustrer.
signal ability_used(ability: Ability)
signal ability_refused(reason: String)

@onready var maze_renderer: MazeRenderer = $MazeRenderer
@onready var decor: DecorLayer = $DecorLayer
@onready var entities: Node2D = $Entities
@onready var compass: Compass = $Compass
@onready var camera: Camera2D = $Camera2D

## La vue en volume, posée par le GameManager. Nulle avec `--2d` et dans les tests.
var world_stage: WorldStage = null
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
## Convergence élémentaire est le seul projectile du Suprême qui n'emploie pas
## l'orbe de son attaque de base : ses huit états racontent la fusion en vol.
var _convergence_orb_texture: Texture2D = null
var _convergence_orb_frames := 1
var _convergence_orb_grows := false
## Combien des frames de la bande sont du CHARGEMENT, et à quelle cadence la
## bande se joue. Lus dans `convergence_orb.json` : rallonger la charge d'une
## image ne doit demander qu'un dessin de plus, jamais une retouche du moteur.
var _convergence_charge_frames := 0
## Le SCEAU des Quatre Sceaux : un seul dessin, en gris, que `ZoneEffect` teinte
## à l'élément de chaque sceau. Voir `tools/build_sceaux.py`.
var _seal_texture: Texture2D = null
## L'incantation des Quatre Sceaux : la bande de charge et sa cadence, lues dans
## `sceaux_charge.json` — jamais codées ici, comme pour Convergence.
var _seal_charge_texture: Texture2D = null
var _seal_charge_frames := 0
var _seal_charge_fps := 8.0
## Les quatre boucles élémentaires, par nom d'élément. Chacune se joue par-dessus
## la gravure pendant toute la vie du sceau : c'est elle qui dit, sans lire la
## couleur, lequel des quatre garde ce passage.
var _seal_fx := {}
var _seal_fx_frames := 0
var _seal_fx_fps := 6.0
## L'ultime du Suprême : la météore aux quatre éléments et l'incantation qui
## l'annonce. Lues dans leurs descripteurs, jamais codées ici.
var _judgement_meteor: Texture2D = null
var _judgement_meteor_frames := 1
var _judgement_meteor_fps := 18.0
## L'ÉCLAT au but de chaque météore. C'est la planche livrée pour l'incantation :
## une explosion vue de dessus, qui ne racontait rien superposée au mage et qui
## est exactement ce qu'il fallait posée sur l'ennemi qu'on vient de frapper.
var _judgement_impact: Array[Texture2D] = []
## LE GESTE qui appelle le ciel : les quatre éléments orbitent autour du mage,
## décollent et quittent le cadre par le haut. Il se joue en entier AVANT que la
## première météore ne parte — l'attente vit dans `rain_delay`, côté combat, et
## la cadence ici : les deux se rencontrent dans `tools/build_jugement.py`, qui
## refuse de les laisser diverger.
var _judgement_charge: Texture2D = null
var _judgement_charge_frames := 0
var _judgement_charge_fps := 11.0
## L'AURA DE RENAISSANCE, dessinée : le jaillissement puis la charge. Ses bornes
## de boucle viennent du descripteur — jamais codées ici, comme partout ailleurs.
var _rebirth_strip: Texture2D = null
var _rebirth_frames := 0
var _rebirth_fps := 9.0
var _rebirth_loop: Array = []
var _convergence_fps := 12.0
var _convergence_impact_texture: Texture2D = null
## Les 9 frames de l'explosion prismatique, chargées depuis convergence_0..8.png.
## Quand elles existent, _spawn_impact les joue en séquence plutôt que d'afficher
## l'image statique — l'effet est beaucoup plus spectaculaire.
var _convergence_impact_frames: Array[Texture2D] = []
var _fire_orb_texture: Texture2D = null
var _fire_orb_frames := 1
var _fire_orb_grows := false
## La bande est une PROGRESSION et non une boucle : voir `orb.json`.
var _orb_grows := false
var _impact_texture: Texture2D = null
var _impact_frames: Array[Texture2D] = []
var _impact_anchor := Vector2.ZERO
var _geyser_frames: Array[Texture2D] = []
var _geyser_anchor := Vector2.ZERO
var _splash_frames: Array[Texture2D] = []
var _splash_anchor := Vector2.ZERO
## Ancre du dernier chargement : `_load_burst` la dépose ici. Un tableau et une
## ancre vont toujours ensemble, mais GDScript ne rend pas deux valeurs.
var _burst_anchor := Vector2.ZERO
var _zone_texture: Texture2D = null
## Le portail du mage. Il servait à la seule translation ; la Rune des Ténèbres
## le pose désormais AU SOL, ce qui lie visuellement les deux sorts d'un même
## personnage — c'est le même passage, ouvert pour soi ou laissé derrière soi.
var _warp_texture: Texture2D = null
## Bande d'images du portail posé au sol, et son nombre de poses.
var _rune_texture: Texture2D = null
var _rune_frames := 1
## Nuage dessiné de la planche, quand le personnage en a un.
var _cloud_texture: Texture2D = null
var _cloud_lit_texture: Texture2D = null
## Le blason du mage, quand sa planche en fournit un.
var _crest_texture: Texture2D = null
## Les pics et la terre soulevée, pour les sorts de la Terre.
var _spikes_texture: Texture2D = null
var _dust_texture: Texture2D = null
var _crystal_texture: Texture2D = null
var _tornado_texture: Texture2D = null
var _curl_texture: Texture2D = null
## Les deux moitiés du Grand souffle, six images chacune. « wave » et non
## « burst » : `_burst_frames` désigne déjà les gerbes de la Terre.
var _cone_frames: Array[Texture2D] = []
var _wave_frames: Array[Texture2D] = []
var _tornado_frames: Array[Texture2D] = []
## La colonne du Cyclone et sa décharge, quand le mage en a les dessins.
var _cyclone_frames: Array[Texture2D] = []
var _bolt_frames: Array[Texture2D] = []
var _shard_texture: Texture2D = null
var _boulder_texture: Texture2D = null
var _gem_texture: Texture2D = null
## matière -> six images d'éruption.
var _burst_frames := {}
var _aegis_texture: Texture2D = null
var _rock_texture: Texture2D = null
var _spark_texture: Texture2D = null
var gems: Array[Gem] = []
var potions: Array[Potion] = []
var teleport_system: TeleportSystem = null
var combat: CombatSystem = null
var combat_context: CombatContext = null
var _prism_aura: PrismAura = null
var _ael_dragon_aura: DragonAura = null
## Personnage joué et ses points de vie. Le Level les PORTE, le GameManager les
## interprète : c'est lui qui décide qu'à zéro la partie est perdue.
var character: CharacterStats = null
## Où part le sort qu'on est en train de lancer, renseigné par le signal du tir
## pendant `combat.use`. Reste nul pour un sort qui n'a pas de cible.
var _cast_target: Variant = null
var player_health: Health = null
## Ce que le joueur a acquis définitivement. Posé par le GameManager avant le
## chargement : le Level ne sauvegarde rien lui-même, il ne fait que consulter.
var progress: Progress = Progress.new()
## Compteur affiché dans l'interface (le concept art montre un compteur de portails).
var teleport_count := 0
var gems_total := 0
var gems_taken := 0

var _player_field := PackedInt32Array()
## La couche d'ambiance — vignette, halo, poussière. Créée au premier stage.
var _ambience: Ambience = null
## Champ de distances vers CE QUE LE JOUEUR CHERCHE : la gemme la plus proche,
## ou la maison une fois le sac plein. Les portails s'en servent pour décider ce
## qui compte comme un gain — sans lui, le jeu annoncerait « le portail te
## rapproche » en mesurant la distance à une maison encore verrouillée.
var _objective_field := PackedInt32Array()
var _objective_cell := Vector2i(-1, -1)
var _ai_timer := 0.0
var _potion_timer := 0.0
var _orbs := {}          # index d'ennemi -> MagicOrb en vol
var _crescents := {}     # index d'ennemi -> FlyingCrescent en vol (le Tranche-vent d'Aël)
var _ael_guard: GuardFlash = null
var _ael_orbit: ShardOrbit = null
## La dernière forme vue : l'évolution monte, le retour du Prisme retombe.
var _ael_form_seen := -1
## Le saut d'Aël en cours : la Ruée l'annonce par sa traînée juste après le saut, sinon c'est une roulade.
var _ael_blink := {}
var _summon_orbs := {}   # id d'invocation -> MagicOrb en vol
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
	# L'AMBIANCE prend l'air du stage : vignette teintée, halo du mage, poussière.
	if _ambience == null:
		_ambience = Ambience.new()
		# Sur un calque d'écran : dans la texture du sol, elle serait couchée avec lui.
		(world_stage if world_stage != null else self).add_child(_ambience)
	_ambience.set_stage_tint(maze_renderer.air_tint())
	_ambience.set_stage(config.stage)
	maze_renderer.set_grid(grid)
	if world_stage != null:
		world_stage.build(grid, config.stage)
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
	_has_thief = false
	_thief_field = PackedInt32Array()
	_spores = SporeClouds.new()
	for cloud in _spore_nodes:
		if is_instance_valid(cloud):
			cloud.queue_free()
	_spore_nodes.clear()
	_clear_boss()
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
	# La graine du niveau alimente le tirage des météores : rejouer une graine
	# redonne la même pluie, comme elle redonne le même labyrinthe.
	combat = CombatSystem.new(grid, character, player_health, rng_seed * 31 + 7)
	combat.free_use = config.is_demo
	combat_context = CombatContext.new(grid)
	combat.projectile_launched.connect(_on_projectile_launched)
	combat.projectile_hit.connect(_on_projectile_hit)
	combat.blast_fired.connect(_on_blast_fired)
	combat.wave_launched.connect(_on_wave_launched)
	combat.zone_created.connect(_on_zone_created)
	combat.seals_cast.connect(_on_seals_cast)
	combat.zone_expired.connect(_on_zone_expired)
	combat.wall_raised.connect(_on_wall_changed)
	combat.wall_fell.connect(_on_wall_changed)
	combat.blink_performed.connect(_on_blink)
	combat.comet_performed.connect(_ael_comet)
	combat.summon_spawned.connect(_on_summon_spawned)
	combat.summon_moved.connect(_on_summon_moved)
	combat.summon_struck.connect(_on_summon_struck)
	combat.summon_projectile_launched.connect(_on_summon_projectile_launched)
	combat.summon_projectile_hit.connect(_on_summon_projectile_hit)
	combat.summon_expired.connect(_on_summon_expired)
	combat.enemy_damaged.connect(_on_enemy_damaged)
	combat.enemy_killed.connect(_on_enemy_killed)
	combat.enemy_soaked.connect(_on_enemy_soaked)
	combat.enemy_staggered.connect(_on_enemy_status.bind("stagger"))
	combat.enemy_burning.connect(_on_enemy_status.bind("burn"))
	combat.enemy_pushed.connect(_on_enemy_pushed)
	combat.enemy_hauled.connect(_on_enemy_hauled)
	combat.enemy_poisoned.connect(_on_enemy_poisoned)
	combat.rift_opened.connect(_on_rift_opened)
	combat.chain_arced.connect(_on_chain_arced)
	combat.storm_gathered.connect(_on_storm_gathered)
	combat.storm_dispersed.connect(_on_storm_dispersed)
	combat.storm_struck.connect(_on_storm_struck)
	combat.sky_cloud_formed.connect(_on_sky_cloud_formed)
	combat.sky_cloud_faded.connect(_on_sky_cloud_faded)
	combat.sky_bolt.connect(_on_sky_bolt)
	combat.meteor_incoming.connect(_on_meteor_incoming)
	combat.incantation_cast.connect(_on_incantation_cast)
	combat.meteor_landed.connect(_on_meteor_landed)
	combat.player_empowered.connect(_on_player_empowered)
	combat.player_calmed.connect(_on_player_calmed)
	combat.player_shielded.connect(_on_player_shielded)
	combat.enemy_slammed.connect(_on_enemy_slammed)
	combat.zone_moved.connect(_on_zone_moved)
	combat.geyser_erupted.connect(_on_geyser_erupted)
	combat.quake_started.connect(_on_quake_started)
	combat.quake_slide.connect(_on_quake_slide)
	combat.turret_planted.connect(_on_turret_planted)
	combat.turret_fired.connect(_on_turret_fired)
	combat.turret_faded.connect(_on_turret_faded)
	combat.player_made_immune.connect(_on_player_made_immune)
	combat.player_immunity_faded.connect(_on_immunity_faded)
	combat.player_shield_faded.connect(_on_shield_faded)
	combat.echo_walked.connect(_on_echo_walked)
	combat.hourglass_turned.connect(_on_hourglass_turned)
	combat.hourglass_ended.connect(_on_hourglass_ended)
	combat.time_stopped.connect(_on_time_stopped)
	combat.enemy_venomed.connect(_on_enemy_venomed)
	combat.trail_started.connect(_on_trail_started)
	combat.puddle_laid.connect(_on_puddle_laid)
	combat.puddle_stepped.connect(_on_puddle_stepped)
	combat.contagion_spread.connect(_on_contagion_spread)
	combat.transfused.connect(_on_transfused)
	combat.pandemic_cast.connect(_on_pandemic_cast)
	combat.venom_killed.connect(_on_venom_killed)
	combat.enemy_blinded.connect(_on_enemy_blinded)
	combat.beam_fired.connect(_on_beam_fired)
	combat.wings_burst.connect(_on_wings_burst)
	combat.dawn_cast.connect(_on_dawn_cast)
	combat.dawn_struck.connect(_on_dawn_struck)
	combat.enemy_star_marks.connect(_on_enemy_star_marks)
	combat.astre_burst.connect(_on_astre_burst)
	combat.stars_changed.connect(_on_stars_changed)
	combat.star_falling.connect(_on_star_falling)
	combat.line_erupted.connect(_ael_line)
	combat.star_trail.connect(_on_star_trail)
	_on_stars_changed([])
	combat.enemy_sentenced.connect(_on_enemy_sentenced)
	combat.enemy_marked.connect(_on_enemy_marked)
	combat.souls_changed.connect(_on_souls_changed)
	combat.soul_sent.connect(_on_soul_sent)
	combat.soul_struck.connect(_on_soul_struck)
	combat.last_hour_cast.connect(_on_last_hour_cast)
	combat.last_hour_struck.connect(_on_last_hour_struck)
	_on_souls_changed(0)
	combat.plates_changed.connect(_on_plates_changed)
	combat.blades_thrown.connect(_on_blades_thrown)
	combat.blade_cut.connect(_on_blade_cut)
	combat.anvil_struck.connect(_on_anvil_struck)
	combat.rampart_reflected.connect(_on_blade_cut)
	combat.molten_started.connect(_on_molten_started)
	combat.molten_ended.connect(_on_molten_ended)
	combat.pact_signed.connect(_on_pact_signed)
	combat.enemy_possessed.connect(_on_enemy_possessed)
	combat.possession_field.connect(_on_possession_field)
	combat.great_discord_cast.connect(_on_great_discord)
	combat.brawl_struck.connect(_on_brawl_struck)
	combat.bond_struck.connect(_on_bond_struck)
	combat.enemy_swapped.connect(_on_enemy_swapped)
	combat.piece_ejected.connect(_on_piece_ejected)
	combat.piece_struck.connect(_on_piece_struck)
	combat.piece_recalled.connect(_on_piece_recalled)
	combat.piece_returned.connect(_on_piece_returned)
	combat.hunters_cast.connect(_on_hunters_cast)
	combat.chest_posed.connect(_on_chest_posed)
	combat.chest_bit.connect(_on_chest_bit)
	combat.chest_spat.connect(_on_chest_spat)
	combat.recall_cast.connect(_on_recall_cast)
	combat.decoy_posed.connect(_on_decoy_posed)
	combat.decoy_blew.connect(_on_decoy_blew)
	combat.decoy_field.connect(_on_decoy_field)
	combat.cages_cast.connect(_on_cages_cast)
	combat.cages_crushed.connect(_on_cages_crushed)
	combat.enemy_cuts.connect(_on_enemy_cuts)
	combat.dash_cut.connect(_on_dash_cut)
	combat.guard_raised.connect(_on_guard_raised)
	combat.guard_parried.connect(_on_guard_parried)
	combat.sheathe_begun.connect(_on_sheathe_begun)
	combat.cut_burst.connect(_on_cut_burst)
	combat.sheathe_ended.connect(_on_sheathe_ended)
	combat.enemy_shackled.connect(_on_enemy_shackled)
	combat.enemy_hooked.connect(_on_enemy_hooked)
	combat.enemies_frozen.connect(_on_enemies_frozen)
	combat.soul_chains_cast.connect(_on_soul_chains_cast)
	combat.gaol_cast.connect(_on_gaol_cast)
	combat.gaol_ended.connect(_on_gaol_ended)
	combat.ground_ignited.connect(_on_ground_ignited)
	combat.breath_cast.connect(_on_breath_cast)
	combat.dragon_bit.connect(_on_dragon_bit)
	combat.scales_raised.connect(_on_scales_raised)
	combat.scales_burst.connect(_on_scales_burst)
	combat.wings_beaten.connect(_on_wings_beaten)
	combat.dragon_shadow_cast.connect(_on_dragon_shadow_cast)
	combat.shadow_column.connect(_on_shadow_column)
	combat.shadow_ended.connect(_on_shadow_ended)
	combat.lucky_hit.connect(_on_lucky_hit)
	combat.dice_rolled.connect(_on_dice_rolled)
	combat.trap_posed.connect(_on_trap_posed)
	combat.trap_faded.connect(_on_trap_faded)
	combat.trap_flipped.connect(_on_trap_flipped)
	combat.coin_flipped.connect(_on_coin_flipped)
	combat.doubled_spent.connect(_on_doubled_spent)
	combat.roulette_spun.connect(_on_roulette_spun)
	combat.roulette_landed.connect(_on_roulette_landed)
	combat.bites_changed.connect(_on_bites_changed)
	combat.gulf_opened.connect(_on_gulf_opened)
	combat.gulf_closed.connect(_on_gulf_closed)
	combat.devoured.connect(_on_devoured)
	combat.regurgitated.connect(_on_regurgitated)
	combat.leap_landed.connect(_on_leap_landed)
	combat.feast_started.connect(_on_feast_started)
	combat.feast_bite.connect(_on_feast_bite)
	combat.feast_ended.connect(_on_feast_ended)
	combat.enemies_dazed.connect(_on_enemies_dazed)
	combat.flight_started.connect(_on_flight_started)
	combat.flight_ended.connect(_on_flight_ended)
	combat.flight_landed.connect(_on_flight_landed)
	combat.enemy_eyed.connect(_on_enemy_eyed)
	combat.eye_burst.connect(_on_eye_burst)
	combat.whirl_started.connect(_on_whirl_started)
	combat.whirl_cut.connect(_on_whirl_cut)
	combat.veil_repelled.connect(_on_veil_repelled)
	combat.garden_planted.connect(_on_garden_planted)
	combat.garden_repelled.connect(_on_garden_repelled)
	combat.garden_ended.connect(_on_garden_ended)
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
	house.set_locked(missing_gem_colors().size())
	if world_stage != null:
		world_stage.raise_monument(house, grid.house_center)

	player = PLAYER_SCENE.instantiate()
	# Le personnage est posé AVANT l'entrée dans l'arbre : le _ready du joueur
	# charge sa planche, il lui faut déjà savoir lequel des sept il incarne.
	player.set_character(character)
	entities.add_child(player)
	player.setup(grid, grid.player_spawn, character.move_speed, TILE_SIZE)
	_on_plates_changed(combat.plates_left())
	player.mover.cell_entered.connect(_on_player_cell_entered)
	compass.setup(TILE_SIZE)
	_player_was_in_house = grid.is_house(grid.player_spawn)
	_walk_player_out_of_house()

	var slots := config.slot_species(grid.enemy_spawns.size())
	for i in slots.size():
		var enemy: Enemy = ENEMY_SCENE.instantiate()
		entities.add_child(enemy)
		# Les gobelins occupent les premiers index : ce sont eux qu'on voit en
		# premier à l'écran, et c'est l'espèce qui donne son nom au stage 2.
		# L'espèce tourne dans le roster du stage : le stage montre donc toutes
		# ses créatures, la nouvelle comprise, avant d'en répéter une.
		var id := slots[i]
		enemy.setup_enemy(grid, grid.enemy_spawns[i % grid.enemy_spawns.size()],
			REFERENCE_SPEED * config.enemy_speed(id), TILE_SIZE,
			config.enemy_detection_radius, id, config.enemy_health(id))
		enemies.append(enemy)
		_has_thief = _has_thief or enemy.is_thief()
		if Bestiary.is_droplet(id):
			enemy.health.current = 0
			enemy.set_dead(true)
	_prepare_boss()
	_stagger_initial_spawns()
	_refresh_ai()

	_update_camera(true)
	level_loaded.emit(config)


func set_overview(value: bool) -> void:
	overview = value
	_update_camera(true)


func _process(delta: float) -> void:
	# LE HALO SUIT LE MAGE, en coordonnées d'ÉCRAN : la vignette et la lumière
	# vivent sur un CanvasLayer, elles ne connaissent ni la caméra ni le zoom.
	# C'est le Level qui fait la conversion — lui seul connaît les deux mondes.
	if _ambience != null and player != null:
		var view := Vector2(get_viewport().get_visible_rect().size)
		var at := to_screen(player.position)
		_ambience.set_focus(Vector2(at.x / maxf(1.0, view.x), at.y / maxf(1.0, view.y)))
	_update_camera(false)
	if teleport_system != null:
		teleport_system.update(delta)
	if combat != null:
		_refresh_context()
		combat.update(delta, combat_context)
		if _bubble != null and is_instance_valid(_bubble):
			_bubble.set_amount(float(combat.shield_left()) / float(_shield_max))
	# L'Arrêt du temps fige aussi ce qui allait sortir des repaires.
	var stopped := combat != null and combat.time_stop_left() > 0.0
	for lair in lairs:
		lair.set_process(not stopped)
	if not stopped:
		_update_respawns(delta)
	_update_stones()
	_update_ai(delta)
	_update_enemy_target()
	_update_portal_highlight()
	_update_enemy_portals()
	_update_thieves()
	_update_spores(delta, stopped)
	_update_rage()
	_update_discord_threads()
	_update_king_armor()
	_update_gaoler_chains()
	_update_dragon_aura()
	_update_avide_aura()
	_update_boss(delta, stopped)
	_update_pickups(delta)
	_update_orbs()
	_update_compass()
	_check_capture()
	_update_lava(delta)


# --- Objectif : gemmes et potions ------------------------------------------------

func gems_remaining() -> int:
	return gems_total - gems_taken


## La maison du mage s'ouvre quand TOUT l'objectif est rempli : les gemmes, et —
## au dernier épisode des stages 3 et 9 — les repaires abattus, puis le boss du chapitre.
func house_is_open() -> bool:
	return gems_remaining() <= 0 and lairs_remaining() <= 0 and not boss_guards_door()


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
	# En vol, il ne ramasse rien : une gemme survolée reste au sol.
	var aloft := combat != null and combat.flying()

	for i in range(gems.size() - 1, -1, -1):
		if aloft:
			break
		var gem: Gem = gems[i]
		if not is_instance_valid(gem):
			gems.remove_at(i)
			continue
		if gem.carried or Vector2(gem.cell).distance_to(player_position) >= PICKUP_DISTANCE:
			continue
		_collect_gem(i)

	for i in range(potions.size() - 1, -1, -1):
		if aloft:
			break
		var potion: Potion = potions[i]
		if not is_instance_valid(potion):
			potions.remove_at(i)
			continue
		if Vector2(potion.cell).distance_to(player_position) >= PICKUP_DISTANCE:
			continue
		potions.remove_at(i)
		_spawn_effect(potion.cell, Potion.TINT)
		potion.queue_free()
		# Le compteur de réapparition ne démarre qu'ici : tant qu'une potion
		# traîne par terre, en faire pousser une deuxième n'a pas de sens.
		_potion_timer = POTION_RESPAWN_DELAY
		potion_collected.emit()

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
	for enemy in enemies:
		if enemy.stolen == gem:
			enemy.stolen = null
	_spawn_effect(gem.cell, gem.color())
	gem.queue_free()
	house.set_locked(_house_seals())
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
	if not combat.can_use(ability):
		return false
	# Un sort sans cible à portée serait gaspillé : l'interface doit pouvoir griser
	# le bouton AVANT que le joueur n'appuie. L'attaque de base, elle, part toujours.
	if ability.kind == Ability.Kind.PROJECTILE and ability != character.attack:
		return has_target(slot)
	return true


## Un ennemi est-il à portée de ce geste, là, tout de suite ?
func has_target(slot: int) -> bool:
	var ability := ability_at(slot)
	return ability != null and combat != null \
		and combat.find_target(ability, combat_context) >= 0


## Retourne false si rien n'est parti — et dans ce cas aucune ressource n'a été
## consommée.
func use_ability(slot: int) -> bool:
	var ability := ability_at(slot)
	if ability == null or combat == null or player == null:
		return false
	_refresh_context()
	_cast_target = null
	if character.id == "ael" and ability == character.attack and ability.kind == Ability.Kind.BLAST:
		var target := combat.find_target(ability, combat_context)
		if target >= 0 and target < enemies.size():
			_cast_target = enemies[target].position
	if not combat.use(ability, combat_context):
		return false
	player.play_cast(_cast_target)
	# LE BLASON DE L'EXTRA. Il ne paraît que pour l'ultime, et seulement si la
	# planche du mage en fournit un : déposer un `crest.png` suffit à en donner
	# un au mage suivant, sans toucher au code.
	if ability.is_ultimate and _crest_texture != null and PAINTED_MAGES.has(character.id):
		_spawn_painted_burst(player.mover.nearest_cell(), 3.0, 0.9, "thunder_crest")
	elif ability.is_ultimate and _crest_texture != null:
		var crest: SpellCrest = CREST_SCENE.instantiate()
		entities.add_child(crest)
		crest.position = player.position
		crest.setup(TILE_SIZE, _crest_texture)
	ability_used.emit(ability)
	return true


func _enemy_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for enemy in enemies:
		var cell := enemy.current_cell()
		if enemy.phases() and player != null:
			cell = CreatureRules.anchor_cell(grid, cell, player.current_cell())
		cells.append(cell)
	return cells


## Photo du monde passée au CombatSystem. Elle est refaite à chaque frame : les
## ennemis bougent, et un sort lancé sur des positions périmées taperait à côté.
func _refresh_context() -> void:
	if combat_context == null or player == null:
		return
	combat_context.player_cell = _grounded(player.mover.nearest_cell())
	combat_context.player_facing = player.facing()
	combat_context.player_field = _player_field
	var cells := _enemy_cells()
	var healths: Array[Health] = []
	combat_context.bosses.clear()
	combat_context.enemy_facings.clear()
	for enemy in enemies:
		combat_context.enemy_facings.append(enemy.mover.direction)
		if enemy.is_boss():
			combat_context.bosses[healths.size()] = true
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
	# Face au boss, la vague s'arrête : ce qui tombe ne revient pas, sinon on ne verrait
	# plus ses zones au milieu de la meute.
	if boss_has_appeared():
		return
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
	# Seulement les poursuivants : les petites gelées, elles, attendent une mort.
	for i in range(lairs.size(), grid.enemy_spawns.size()):
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

## Le dernier élément du trait du Suprême et de ses météores : 0 feu, 1 eau, 2 terre, 3 air.
var _prism_rank := 0
var _meteor_rank := 0

## Les mages dont les sorts sont peints au shader et non lus dans leur planche.
##
## ⚠️ LA TERRE ET L'AIR N'Y SONT PAS, à la demande du joueur : leurs dessins restent, et
## les shaders ne font que s'y AJOUTER (`DRAWN_MAGES`).
const PAINTED_MAGES: Array[String] = ["fire", "shadow", "invocateur", "water", "thunder",
	"supreme", "chrono", "peste", "lumiere", "mort", "etoiles", "acier", "demon", "discorde", "braise", "ecarlate", "geolier", "ciel", "cherubin", "dragon", "croupier", "avide"]
const DRAWN_MAGES: Array[String] = ["earth", "air"]
const EARTH := "earth"
const AIR := "air"
const FIRE_BURST_TIME := 0.85
## Une météore peinte, à l'échelle de la Boule de feu : quatorze à 2,1 boucheraient
## le labyrinthe.
const METEOR_PAINTED_SCALE := 1.3


## LES SHADERS PEINTS SONT COMPILÉS AU CHARGEMENT, pas au premier tir.
##
## `gl_compatibility` n'a pas de précompilation : un shader se compile la première
## fois qu'il s'affiche, et le premier sort du joueur saccaderait. La doc de Godot
## prescrit de l'afficher une image pendant le chargement. Il l'est ici sur quelques
## pixels presque transparents, à peine une image.
func _warm_painted_shaders() -> void:
	if not PaintedFx.IMPACT.has(character.id) or not is_inside_tree():
		return
	var materials := PaintedFx.materials_of(character.id)
	for ability: Ability in [character.attack, character.escape] + character.abilities:
		if MagicOrb.PAINTED.has(ability.projectile_visual):
			materials.append(MagicOrb.painted_material(ability.projectile_visual, 0.0))
		if ZoneEffect.PAINTED_STYLES.has(ability.zone_style):
			materials.append(ZoneEffect.painted_material(ability.zone_style, 2.0, 0.0))
	materials.append(TeleportEffect.make_material())
	var layer := CanvasLayer.new()
	add_child(layer)
	for shaded in materials:
		var quad := Sprite2D.new()
		quad.texture = MagicOrb.painted_quad()
		quad.material = shaded
		quad.scale = Vector2(4.0, 4.0)
		quad.position = Vector2(4.0, 4.0)
		quad.modulate = Color(1.0, 1.0, 1.0, 1.0 / 255.0)
		layer.add_child(quad)
	await get_tree().process_frame
	await get_tree().process_frame
	layer.queue_free()


func _load_character_fx() -> void:
	_warm_painted_shaders()
	var folder := "res://assets/characters/%s/" % character.id
	_orb_texture = _texture_or_null(folder + "orb.png")
	_seal_texture = _texture_or_null(folder + "sceaux_seal.png")
	_seal_fx.clear()
	_seal_fx_frames = 0
	var fx_meta := FileAccess.get_file_as_string(folder + "sceaux_fx.json")
	var fx_parsed: Variant = _parse_optional(fx_meta)
	if fx_parsed is Dictionary:
		_seal_fx_frames = maxi(0, int(fx_parsed.get("frames", 0)))
		_seal_fx_fps = maxf(1.0, float(fx_parsed.get("fps", 6.0)))
		for name in (fx_parsed.get("elements", []) as Array):
			var fx := _texture_or_null(folder + "sceaux_fx_%s.png" % str(name))
			if fx != null:
				_seal_fx[str(name)] = fx
	_judgement_meteor = _texture_or_null(folder + "jugement_meteore.png")
	_judgement_meteor_frames = 1
	var jm: Variant = _parse_optional(
		FileAccess.get_file_as_string(folder + "jugement_meteore.json"))
	if jm is Dictionary:
		_judgement_meteor_frames = maxi(1, int(jm.get("frames", 1)))
		_judgement_meteor_fps = maxf(1.0, float(jm.get("fps", 18.0)))
	_judgement_impact.clear()
	var jc: Variant = _parse_optional(
		FileAccess.get_file_as_string(folder + "jugement_impact.json"))
	if jc is Dictionary:
		for rank in maxi(0, int(jc.get("frames", 0))):
			var one := _texture_or_null(folder + "jugement_impact_%d.png" % rank)
			if one != null:
				_judgement_impact.append(one)
	_rebirth_strip = _texture_or_null(folder + "renaissance_aura.png")
	_rebirth_frames = 0
	_rebirth_loop = []
	var jr: Variant = _parse_optional(
		FileAccess.get_file_as_string(folder + "renaissance_aura.json"))
	if jr is Dictionary:
		_rebirth_frames = maxi(0, int(jr.get("frames", 0)))
		_rebirth_fps = maxf(1.0, float(jr.get("fps", 9.0)))
		_rebirth_loop = jr.get("loop", []) as Array
	_judgement_charge = _texture_or_null(folder + "jugement_incantation.png")
	_judgement_charge_frames = 0
	var ji: Variant = _parse_optional(
		FileAccess.get_file_as_string(folder + "jugement_incantation.json"))
	if ji is Dictionary:
		_judgement_charge_frames = maxi(0, int(ji.get("frames", 0)))
		_judgement_charge_fps = maxf(1.0, float(ji.get("fps", 11.0)))
	_seal_charge_texture = _texture_or_null(folder + "sceaux_charge.png")
	_seal_charge_frames = 0
	var seal_meta := FileAccess.get_file_as_string(folder + "sceaux_charge.json")
	var seal_parsed: Variant = _parse_optional(seal_meta)
	if seal_parsed is Dictionary:
		_seal_charge_frames = maxi(0, int(seal_parsed.get("frames", 0)))
		_seal_charge_fps = maxf(1.0, float(seal_parsed.get("fps", 8.0)))
	_convergence_orb_texture = _texture_or_null(folder + "convergence_orb.png")
	_convergence_impact_texture = _texture_or_null(folder + "convergence_impact.png")
	_convergence_impact_frames.clear()
	# Les 9 frames d'explosion prismatique (convergence_0 → convergence_8).
	# On les charge si elles existent, sans crasher si elles sont absentes.
	for i in 9:
		var frame := _texture_or_null("%sconvergence_%d.png" % [folder, i])
		if frame != null:
			_convergence_impact_frames.append(frame)
	_convergence_orb_frames = 1
	_convergence_orb_grows = false
	var convergence_meta := FileAccess.get_file_as_string(folder + "convergence_orb.json")
	var convergence_parsed: Variant = _parse_optional(convergence_meta)
	if convergence_parsed is Dictionary:
		_convergence_orb_frames = maxi(1, int(convergence_parsed.get("frames", 1)))
		_convergence_orb_grows = String(convergence_parsed.get("mode", "loop")) == "grow"
		_convergence_charge_frames = maxi(0, int(convergence_parsed.get("charge_frames", 0)))
		_convergence_fps = maxf(1.0, float(convergence_parsed.get("fps", 12.0)))
	_fire_orb_texture = _texture_or_null("res://assets/characters/fire/orb.png")
	_fire_orb_frames = 1
	_fire_orb_grows = false
	var fire_orb_meta := FileAccess.get_file_as_string("res://assets/characters/fire/orb.json")
	var fire_orb_parsed: Variant = _parse_optional(fire_orb_meta)
	if fire_orb_parsed is Dictionary:
		_fire_orb_frames = maxi(1, int(fire_orb_parsed.get("frames", 1)))
		_fire_orb_grows = String(fire_orb_parsed.get("mode", "loop")) == "grow"
	_impact_texture = _texture_or_null(folder + "impact.png")
	# Ces mages n'ont jamais eu de planche d'effets. Le quad tient la place
	# du dessin que tout le reste du code attend : un mage peint ne l'affiche de toute façon pas.
	if _impact_texture == null and character.id in ["chrono", "peste", "lumiere", "mort", "etoiles", "acier", "demon", "discorde", "braise", "ecarlate", "geolier", "ciel", "cherubin", "dragon", "croupier", "avide", "test", "ael"]:
		_impact_texture = MagicOrb.painted_quad()
		_orb_texture = _impact_texture
	# Les EFFETS DESSINÉS ANIMÉS du personnage, quand sa planche en fournit :
	# la frappe au sol, le geyser, l'éclaboussure. Chacun vient avec son ANCRE,
	# le point du dessin qui doit tomber sur la case.
	_impact_frames = _load_burst(folder, "impact")
	_impact_anchor = _burst_anchor
	_geyser_frames = _load_burst(folder, "geyser")
	_geyser_anchor = _burst_anchor
	_splash_frames = _load_burst(folder, "splash")
	_splash_anchor = _burst_anchor
	_zone_texture = _texture_or_null(folder + "zone.png")
	_warp_texture = _texture_or_null(folder + "warp.png")
	_rune_texture = _texture_or_null(folder + "rune.png")
	_rune_frames = 1
	var rune_meta := FileAccess.get_file_as_string(folder + "rune.json")
	var rune_parsed: Variant = _parse_optional(rune_meta)
	if rune_parsed != null:
		_rune_frames = maxi(1, int((rune_parsed as Dictionary).get("frames", 1)))
	_cloud_texture = _texture_or_null(folder + "cloud_dark.png")
	_cloud_lit_texture = _texture_or_null(folder + "cloud.png")
	_crest_texture = _texture_or_null(folder + "crest.png")
	_spikes_texture = _texture_or_null(folder + "spikes.png")
	_dust_texture = _texture_or_null(folder + "dust.png")
	_crystal_texture = _texture_or_null(folder + "crystal.png")
	_tornado_texture = _texture_or_null(folder + "tornado.png")
	_curl_texture = _texture_or_null(folder + "curl.png")
	# ⚠️ ON VIDE AVANT DE REMPLIR. Ces tableaux sont des membres du Level, et
	# le chargement des textures est refait à chaque niveau : sans ce
	# nettoyage, les images s'EMPILENT — mesuré, douze images de cône au lieu
	# de six au deuxième niveau, et l'animation jouait deux fois plus vite.
	_cone_frames.clear()
	_wave_frames.clear()
	_tornado_frames.clear()
	_burst_frames.clear()
	for i in 6:
		var frame := _texture_or_null("%sblast_cone_%d.png" % [folder, i])
		if frame != null:
			_cone_frames.append(frame)
		var wave := _texture_or_null("%sblast_burst_%d.png" % [folder, i])
		if wave != null:
			_wave_frames.append(wave)
	# Le tour complet de la tornade, huit images.
	_cyclone_frames.clear()
	_bolt_frames.clear()
	for i in 8:
		var turn := _texture_or_null("%stornado_spin_%d.png" % [folder, i])
		if turn != null:
			_tornado_frames.append(turn)
		var spin := _texture_or_null("%scyclone_spin_%d.png" % [folder, i])
		if spin != null:
			_cyclone_frames.append(spin)
	for i in 4:
		var bolt := _texture_or_null("%scyclonebolt_bolt_%d.png" % [folder, i])
		if bolt != null:
			_bolt_frames.append(bolt)
	_shard_texture = _texture_or_null(folder + "shard.png")
	_boulder_texture = _texture_or_null(folder + "boulder.png")
	_gem_texture = _texture_or_null(folder + "gem.png")
	# Les deux éruptions de la planche animée, six images chacune.
	for matter in ["crystal", "stone"]:
		var suite: Array[Texture2D] = []
		for i in 6:
			var frame := _texture_or_null("%sspikes_%s_%d.png" % [folder, matter, i])
			if frame != null:
				suite.append(frame)
		if not suite.is_empty():
			_burst_frames[matter] = suite
	_aegis_texture = _texture_or_null(folder + "aegis.png")
	_rock_texture = _texture_or_null(folder + "rock.png")
	_spark_texture = _texture_or_null(folder + "spark.png")
	_orb_frames = 1
	# Une bande d'orbe se joue de DEUX façons, et le fichier le dit :
	#   "loop"  — les images se relaient sans fin (une comète qui bat) ;
	#   "grow"  — la première est la naissance du tir, la dernière sa pleine
	#             puissance : on les joue UNE fois et on tient la dernière.
	# Rejouer une progression en boucle ferait sauter le projectile de sa
	# pleine puissance à son étincelle de départ, en plein vol.
	_orb_grows = false
	var meta := FileAccess.get_file_as_string(folder + "orb.json")
	var parsed: Variant = _parse_optional(meta)
	if parsed != null:
		var data := parsed as Dictionary
		_orb_frames = maxi(1, int(data.get("frames", 1)))
		_orb_grows = String(data.get("mode", "loop")) == "grow"


## Beaucoup de ces fichiers n'existent que pour un mage : leur absence n'est pas une
## erreur, et l'écrire dans le journal à chaque niveau y noierait les vraies.
static func _parse_optional(text: String) -> Variant:
	return null if text.is_empty() else JSON.parse_string(text)


## Une animation dessinée du personnage : ses images et son ancre. Le tableau
## est vide quand la planche n'en fournit pas — le jeu retombe alors sur ses
## effets tracés en code, et rien ne casse.
func _load_burst(folder: String, name: String) -> Array[Texture2D]:
	_burst_anchor = Vector2.ZERO
	var suite: Array[Texture2D] = []
	var meta := FileAccess.get_file_as_string("%s%s_anim.json" % [folder, name])
	var parsed: Variant = _parse_optional(meta)
	if parsed == null:
		return suite
	var data := parsed as Dictionary
	for i in int(data.get("frames", 0)):
		var frame := _texture_or_null("%s%s_%d.png" % [folder, name, i])
		if frame != null:
			suite.append(frame)
	var point: Array = data.get("anchor", [0, 0])
	if point.size() == 2:
		_burst_anchor = Vector2(float(point[0]), float(point[1]))
	return suite


func _texture_or_null(path: String) -> Texture2D:
	return load(path) if ResourceLoader.exists(path) else null


func _on_projectile_launched(ability: Ability, index: int, path: Array, duration: float) -> void:
	if ability.from_sky and not path.is_empty():
		_cast_target = maze_renderer.cell_to_world(path[path.size() - 1])
		_sky_falls(ability, path[path.size() - 1], duration)
		return
	if ability.projectile_visual == "flamme_glaive" and not path.is_empty():
		_cast_target = maze_renderer.cell_to_world(path[path.size() - 1])
		_throw_sacred_flame(path, duration)
		return
	if ability.projectile_visual == "langue_fouet" and not path.is_empty():
		_cast_target = maze_renderer.cell_to_world(path[path.size() - 1])
		_lash_tongue(path, duration)
		return
	if ability.projectile_visual == "tranche_vent" and not path.is_empty():
		_throw_wind_cut(ability, index, path, duration)
		return
	if character.id == CharacterCatalog.AEL and ability == character.attack and not path.is_empty():
		_throw_wind_cut(ability, index, path, duration)
		return
	var points := PackedVector2Array()
	for cell in path:
		points.append(maze_renderer.cell_to_world(cell))
	if ability.projectile_visual == "onde_marteau":
		_spawn_hammer_strike(path, points, duration)
	if not points.is_empty():
		_cast_target = points[points.size() - 1]
	# UN ÉCLAIR NE VOYAGE PAS, IL RELIE — MAIS LE DARD, LUI, VOLE.
	#
	# L'attaque de base de la Foudre empruntait l'orbe générique : une bille
	# lumineuse qui traverse le couloir, incohérente pour cet élément et
	# indistincte de l'attaque du Feu. Elle est depuis tracée en TRAITS BRISÉS
	# le long du couloir, comme les relais de la Chaîne et la fuite.
	#
	# Les deux se complètent maintenant, et chacun dit une chose que l'autre ne
	# dit pas : le trait brisé donne la DÉCHARGE — instantanée, elle relie le
	# mage à sa cible d'un bout à l'autre du couloir — et le dard dessiné donne
	# le COUP, celui qui met un temps à arriver et qu'on peut voir venir. Sans
	# le trait, l'élément perd sa signature ; sans le dard, le joueur ne sait
	# pas à quel instant le coup porte.
	if ability.bolt:
		var tint := Element.color(ability.element)
		for i in points.size() - 1:
			var arc: LightningArc = ARC_SCENE.instantiate()
			entities.add_child(arc)
			arc.setup(points[i], points[i + 1], tint, float(TILE_SIZE) * 0.11)
	var orb: MagicOrb = ORB_SCENE.instantiate()
	entities.add_child(orb)
	var texture := _orb_texture
	var frames := _orb_frames
	var grows := _orb_grows
	var fps := 12.0
	var charge := 0
	if ability.projectile_visual == "convergence":
		if _convergence_orb_texture != null:
			texture = _convergence_orb_texture
			frames = _convergence_orb_frames
			grows = _convergence_orb_grows
			fps = _convergence_fps
			charge = _convergence_charge_frames

	orb.setup(points, duration, TILE_SIZE, Element.color(ability.element),
		texture, frames, ability.projectile_scale, ability.trail_density,
		ability.flames, grows, fps, charge)
	orb.paint(ability.projectile_visual, ability.projectile_scale)
	if ability.projectile_visual == "poing_braise":
		_arm_fist(orb, BRAISE_PIECES + "gant_ferme.png")
	elif ability.projectile_visual == "poing_spectral":
		_arm_fist(orb, GAOLER_PIECES + "poing.png")
	elif ability.projectile_visual == "crachat_magma":
		_arm_ball(orb, DRAGON_PIECES + "magma.png")
	elif ability.projectile_visual == "carte_tranchante":
		_arm_ball(orb, CROUPIER_PIECES + "dos.png")
	# LE TRAIT DU SUPRÊME CHANGE DE MATIÈRE À CHAQUE TIR, comme le dit sa fiche.
	if ability.projectile_visual == "trait_prisme":
		_prism_rank = (_prism_rank + 1) % 4
		(orb.sprite.material as ShaderMaterial).set_shader_parameter("kind", _prism_rank)
	_orbs[index] = orb


func _on_projectile_hit(ability: Ability, index: int, cell: Vector2i) -> void:
	if ability.from_sky:
		_sky_strikes(ability, cell)
		return
	if ability.projectile_visual == "onde_marteau":
		_spawn_painted_burst(cell, 1.5, 0.45, "acier_dash").z_index = 11
	if _crescents.has(index):
		var crescent: FlyingCrescent = _crescents.get(index)
		if crescent != null and is_instance_valid(crescent):
			crescent.burst()
		_crescents.erase(index)
		return
	if _orbs.has(index):
		var orb: MagicOrb = _orbs[index]
		if is_instance_valid(orb):
			orb.burst()
		_orbs.erase(index)
	# Une explosion à flammes dure DEUX FOIS plus longtemps qu'un éclat sec :
	# le flash tient un dixième de seconde, mais la fumée qui monte derrière est
	# ce qui fait qu'on y croit. À 0,55 s, tout était fini avant d'être vu.
	var impact_time := ImpactEffect.DURATION * (2.0 if ability.flames > 0.0 else 1.0)
	# LA FRAPPE DESSINÉE EST L'ÉTAT FINAL DU TIR.
	#
	# Un tir sans rayon — c'est le cas de toutes les attaques de base — posait
	# son dessin d'impact sur 0,9 case : noyé sous la lueur des particules, on
	# ne voyait que le dernier état du projectile. Signalé sur la Foudre, dont
	# la frappe au sol est justement le plus beau dessin d'impact du jeu.
	#
	# Et elle NE TOURNE PLUS : une frappe de foudre a un haut et un bas, la
	# faire pivoter sur elle-même la rendait absurde.
	if ability.bolt:
		_spawn_impact(cell, ability.element, 1.7, impact_time,
			_impact_texture, ability.flames, 0.0)
	else:
		var impact_texture := _impact_texture
		if ability.projectile_visual == "convergence" and _convergence_impact_texture != null:
			impact_texture = _convergence_impact_texture
		_spawn_impact(cell, ability.element, maxf(0.9, ability.radius),
			impact_time, impact_texture, ability.flames, 1.6,
			"convergence_burst" if ability.projectile_visual == "convergence_peinte" else "")
	# L'ASPIRATION SE DESSINE AVANT LES TRAÎNÉES. Le nœud est posé ici parce que
	# `blast_fired` part avant que les créatures ne soient déplacées : l'anneau
	# est donc déjà à l'écran quand les traînées le rejoignent.
	if ability.pull_radius > 0.0:
		var implosion: Implosion = IMPLOSION_SCENE.instantiate()
		entities.add_child(implosion)
		implosion.position = maze_renderer.cell_to_world(cell)
		implosion.setup(TILE_SIZE, ability.pull_radius,
			Element.color(ability.element), int(cell.x * 73 + cell.y * 31))
	if ability.shockwave:
		_spawn_shockwave(cell, ability)


## L'aura d'exaltation, ATTACHÉE au mage : elle le suit dans le labyrinthe.
## Relancer l'ultime la remet à neuf plutôt que d'en empiler une seconde.
var _aura: EmpowerAura = null
## L'aura DESSINÉE, quand le mage en a une planche. Elle double la précédente
## sans la remplacer : les anneaux calculés restent le repli de ceux qui n'ont
## pas de dessin, et le fond commun de tous les exaltés.
var _rebirth: RebirthAura = null


func _on_player_empowered(bonus: int, duration: float) -> void:
	if player == null:
		return
	if _aura != null and is_instance_valid(_aura):
		_aura.refresh(duration)
	else:
		_aura = AURA_SCENE.instantiate()
		player.add_child(_aura)
		_aura.setup(TILE_SIZE, Element.color(character.element), duration)
	# L'AURA DESSINÉE, quand le mage en a une.
	#
	# Elle est ATTACHÉE au mage — enfant de `player` et non d'`entities` — pour
	# la même raison que l'égide de pierre : un bonus qui le suit ne peut pas
	# être posé sur une case. Elle tient tout le temps du bonus, et son
	# jaillissement ne se rejoue pas quand on relance le sort.
	#
	# Le mage qui n'a pas de planche garde les anneaux calculés : le sort marche
	# exactement pareil, il est seulement moins beau.
	if _rebirth_strip != null and _rebirth_frames > 0:
		if _rebirth != null and is_instance_valid(_rebirth):
			_rebirth.refresh(duration)
		else:
			_rebirth = RebirthAura.new()
			player.add_child(_rebirth)
			_rebirth.setup(_rebirth_strip, _rebirth_frames, _rebirth_fps,
				_rebirth_loop, TILE_SIZE, duration)
			PaintedFx.cover(_rebirth, "rebirth_aura", Vector2(3.0, 3.6) * TILE_SIZE,
				Vector2(0.0, -1.1) * TILE_SIZE)
	player_empowered.emit(bonus, duration)


## La coque du bouclier, attachée au mage. Elle FOND avec l'absorption qui
## reste, pas avec le temps : un bouclier vidé en deux coups doit disparaître
## tout de suite, même s'il lui restait six secondes au compteur.
var _bubble: ShieldBubble = null
var _shield_max := 1


func _on_player_shielded(amount: int, duration: float) -> void:
	if player == null:
		return
	_shield_max = maxi(1, amount)
	# Les Écailles de magma ont leurs propres flammes (`_on_scales_raised`) : pas de bulle d'eau.
	if character.id == "dragon":
		player_shielded.emit(amount)
		return
	if character.id == "lumiere":
		_spawn_wings(duration)
		player_shielded.emit(amount)
		return
	# UN ÉTAT, UN VISUEL. Quand la protection vient d'une exaltation qui porte
	# déjà son aura dessinée, la coque ne paraît PAS : les deux disent la même
	# chose, elles se superposent sur le même corps, et la coque — qui se pose
	# devant lui — noyait le mage sous l'aura qui monte derrière.
	#
	# La jauge de l'interface, elle, reste : c'est ELLE qui dit combien de coups
	# restent absorbés, et c'est la seule chose que l'aura ne sait pas dire.
	if _rebirth != null and is_instance_valid(_rebirth):
		player_shielded.emit(amount)
		return
	if _bubble != null and is_instance_valid(_bubble):
		_bubble.refresh(duration)
	else:
		_bubble = BUBBLE_SCENE.instantiate()
		player.add_child(_bubble)
		_bubble.setup(TILE_SIZE, Element.color(character.element), duration)
		if character.id == AIR:
			PaintedFx.add(_bubble, "air_veil", Vector2(2.6, 2.6) * TILE_SIZE)
		else:
			PaintedFx.cover(_bubble, "water_bubble", Vector2(2.6, 2.6) * TILE_SIZE)
	player_shielded.emit(amount)


## Alterne cristal et pierre d'un tir à l'autre.
var _shard_flip := false

## Les cristaux plantés. Indexés par leur identifiant : deux cristaux peuvent
## tenir deux couloirs à la fois.
var _turret_nodes := {}


func _on_turret_planted(id: int, ability: Ability, cell: Vector2i) -> void:
	# DEUX FORMES pour un même sort. S'il ACCOMPAGNE le mage, ce sont des
	# pierres en ORBITE autour de lui : ce qui tourne est ce qui part, le stock
	# est visible, et le projectile est la pierre même qui vient de quitter le
	# cercle. Un cristal flottant crachait des éclats sortis de nulle part.
	#
	# Planté, c'est la colonne de cristal fichée dans le sol — aucun mage ne
	# s'en sert aujourd'hui, mais la forme existe et le rendu avec.
	if ability.turret_follows and player != null:
		var orbit := StoneOrbit.new()
		player.add_child(orbit)
		# L'ORBITE est faite de petits éclats, comme celle de l'Égide : c'est
		# la RÉSERVE du mage. Ce qui en part est le gros rocher rond ou la
		# grande gemme — et c'est ce contraste de taille qui fait qu'un jet se
		# remarque au milieu du cercle qui tourne.
		orbit.setup(TILE_SIZE, ability.duration, [_rock_texture, _spark_texture])
		_turret_nodes[id] = orbit
		_spawn_impact(cell, ability.element, 1.0, 0.45)
		return
	if character.id == CharacterCatalog.AEL:
		var sentinel := CrystalSentinel.new()
		entities.add_child(sentinel)
		sentinel.position = maze_renderer.cell_to_world(cell)
		sentinel.setup(TILE_SIZE, _ael_colour())
		_turret_nodes[id] = sentinel
		_shake(0.1, 0.3)
		return
	var turret: CrystalTurret = TURRET_SCENE.instantiate()
	entities.add_child(turret)
	turret.position = maze_renderer.cell_to_world(cell)
	turret.setup(TILE_SIZE, ability.duration, _crystal_texture)
	if character.id == EARTH:
		_spawn_painted_burst(cell, 1.2, 0.5, "earth_crack")
	_turret_nodes[id] = turret
	# La terre remuée, comme pour les Pics : ce qui perce le sol doit en
	# soulever.
	_spawn_impact(cell, ability.element, 1.0, 0.45)


func _on_turret_fired(id: int, ability: Ability, cell: Vector2i, index: int) -> void:
	if index >= enemies.size():
		return
	# L'orbe ne lance rien : il OUVRE LE SOL. Les gerbes sont dessinées par les
	# zones que le balayage plante ; ici, seule la réserve réagit — un éclat
	# quitte le cercle et l'anneau vert s'ouvre à sa place, pour que le joueur
	# rattache la faille à SON orbe et non au décor.
	if not _turret_nodes.has(id):
		return
	var node: Node2D = _turret_nodes[id]
	if is_instance_valid(node) and node is StoneOrbit:
		(node as StoneOrbit).launch(enemies[index].position)
	elif is_instance_valid(node) and node is CrystalSentinel:
		(node as CrystalSentinel).fire(enemies[index].position)


func _on_turret_faded(id: int) -> void:
	if not _turret_nodes.has(id):
		return
	# Les deux formes du sort s'éteignent différemment : l'orbite se resserre,
	# la colonne plantée s'affaisse dans le sol.
	var node: Node2D = _turret_nodes[id]
	if is_instance_valid(node):
		if node is StoneOrbit:
			(node as StoneOrbit).stop()
		elif node is CrystalSentinel:
			(node as CrystalSentinel).fade()
		elif node is CrystalTurret:
			(node as CrystalTurret).fade()
		else:
			node.queue_free()
	_turret_nodes.erase(id)


## L'égide de pierre. Elle vit ATTACHÉE au mage, comme la bulle et l'aura :
## l'immunité le suit, elle n'est pas posée quelque part.
var _aegis: EarthAegis = null


func _on_player_made_immune(duration: float) -> void:
	if player == null:
		return
	if character.id == "etoiles":
		_spawn_veil(duration)
		return
	if character.id == "acier":
		_spawn_on_player(duration, "acier_rampart", 1.05)
		return
	if character.id == "demon":
		_spawn_on_player(duration, "demon_veil", 1.1)
		return
	if character.id == "cherubin":
		_spawn_on_player(duration, "cherubin_voile", 0.9)
		_shake(0.12, 0.3)
		return
	if character.id == CharacterCatalog.AEL:
		_raise_guard(duration)
		return
	if _aegis != null and is_instance_valid(_aegis):
		_aegis.refresh(duration)
		return
	_aegis = EarthAegis.new()
	player.add_child(_aegis)
	_aegis.setup(TILE_SIZE, duration, _aegis_texture, _rock_texture,
		_spark_texture)
	if character.id == EARTH:
		_spawn_painted_burst(player.mover.nearest_cell(), 1.3, 0.5, "earth_crack")


# --- Aël, le héros principal ------------------------------------------------------
#
# ⚠️ AUCUN EFFET PARTAGÉ (demande du joueur, 2026-11-04). Chacun de ses 24 sorts a le sien : ni l'effet
# d'un autre personnage (la téléportation commune, l'éclat d'impact générique, la vague de l'Eau...),
# ni celui d'un autre de ses propres sorts. Chaque forme a sa matière : l'acier de l'Apprenti, le cristal
# cyan de l'Éveillé, le cristal bleu et or de l'Ascendant, la lumière d'or du Prisme.
# `tools/preview_ael.gd` les montre tous image par image.

const AEL_STEEL := Color("#dff4ff")
const AEL_SHARD := Color("#8fe3ff")
## La matière de chaque forme. Un seul endroit, comme `Element.COLORS`.
const AEL_FORM_COLORS := [Color("#dff4ff"), Color("#7fe3ff"), Color("#a9dcff"), Color("#f2c94c"), Color("#ffd15a")]


func _ael_colour() -> Color:
	return AEL_FORM_COLORS[clampi(character.hero_form, 0, AEL_FORM_COLORS.size() - 1)]


## Le Tranche-vent de l'Apprenti (un croissant d'air) et la Rafale du Prisme (un dard de lumière).
func _throw_wind_cut(ability: Ability, index: int, path: Array, duration: float) -> void:
	var points := PackedVector2Array()
	for cell in path:
		points.append(maze_renderer.cell_to_world(cell))
	_cast_target = points[points.size() - 1]
	var crescent := FlyingCrescent.new()
	entities.add_child(crescent)
	var style := FlyingCrescent.Style.LANCE if ability == character.attack else FlyingCrescent.Style.CRESCENT
	crescent.setup(points, duration, TILE_SIZE, _ael_colour(), style)
	_crescents[index] = crescent


## La Lame d'éclat de l'Éveillé : après le coup, trois éclats de cristal taillés filent en tournoyant au
## ras du sol, là où l'Eau déroulait sa vague.
func _crystal_wake(path: Array, duration: float) -> void:
	var points := PackedVector2Array([maze_renderer.cell_to_world(player.mover.nearest_cell())])
	for cell in path:
		points.append(maze_renderer.cell_to_world(cell))
	for i in 3:
		var shard := FlyingCrescent.new()
		entities.add_child(shard)
		shard.setup(points, duration * (1.0 + 0.12 * float(i)), TILE_SIZE, _ael_colour(),
			FlyingCrescent.Style.SHARD)
		shard.scale = Vector2.ONE * (1.0 - 0.18 * float(i))


## Ses trois protections : la garde en croix de l'Apprenti, les plaques de cristal de l'Éveillé, la
## sphère d'or du Prisme.
func _raise_guard(duration: float) -> void:
	if _ael_guard != null and is_instance_valid(_ael_guard):
		_ael_guard.queue_free()
	_ael_guard = GuardFlash.new()
	player.add_child(_ael_guard)
	_ael_guard.position = Vector2(0.0, -Player.BODY_SCREEN_HEIGHT * 0.5)
	var style := [GuardFlash.Style.CROSS, GuardFlash.Style.PLATES, GuardFlash.Style.PLATES,
		GuardFlash.Style.SPHERE, GuardFlash.Style.SCALES][clampi(character.hero_form, 0, 4)] as GuardFlash.Style
	_ael_guard.setup(float(TILE_SIZE) * 0.75, _ael_colour(), duration, style)
	_shake(0.08, 0.2)


## Un coup renvoyé. L'Apprenti riposte d'un tour de lame ; les plaques de l'Éveillé s'illuminent seules.
func _riposte(_cell: Vector2i) -> void:
	if _ael_guard != null and is_instance_valid(_ael_guard):
		_ael_guard.parry()
	if character.hero_form == 0:
		_ael_ring(float(TILE_SIZE) * 1.3, _ael_colour(), 0.16)


## Les coups du Dragon d'or qui passent par une explosion : ses Griffes de soleil, son Souffle, l'impact de
## sa Chute (que sa trace dessine déjà).
func _dragon_strike(ability: Ability) -> void:
	var facing := Vector2(combat_context.player_facing) if combat_context != null else Vector2.DOWN
	if ability == character.attack:
		var claws := ClawRake.new()
		entities.add_child(claws)
		claws.position = player.position + Vector2(0.0, -Player.BODY_SCREEN_HEIGHT * 0.4)
		claws.setup(facing, ability.radius * float(TILE_SIZE) * 1.5)
		return
	if ability.kind == Ability.Kind.COMET:
		_shake(0.35, 1.0)
		return
	var breath := DragonBreath.new()
	entities.add_child(breath)
	breath.position = player.position + Vector2(0.0, -Player.BODY_SCREEN_HEIGHT * 0.5)
	breath.setup(facing, ability.radius * float(TILE_SIZE), deg_to_rad(maxf(ability.arc, 40.0) * 0.5))
	_shake(0.3, 0.7)


## L'ARRÊT SUR IMAGE des Extras d'Aël : le jeu se fige un instant quand le grand coup part.
func _hit_stop(seconds: float) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(seconds, true, false, true).timeout
	Engine.time_scale = 1.0


## La charge de la Transformation, au bouton dédié : la lumière converge vers lui avant l'éclatement.
func show_transformation_charge() -> void:
	var gather := GatherLight.new()
	entities.add_child(gather)
	gather.position = player.position
	gather.setup(TILE_SIZE, AEL_FORM_COLORS[3], Transformation.CHARGE_TIME)
	_shake(0.8, 0.35)


## L'Extra de chaque forme qui passe par une explosion : le grand cercle de l'Apprenti, la Nova de
## cristal de l'Ascendant, et la charge de sa Transformation.
func _awaken_shard(ability: Ability) -> void:
	_hit_stop(0.06 + 0.02 * float(character.hero_form))
	if character.hero_form >= 4:
		var roar := DragonRoar.new()
		entities.add_child(roar)
		roar.position = player.position
		roar.setup(ability.radius * float(TILE_SIZE), TILE_SIZE)
		_shake(0.9, 2.0)
		return
	if character.hero_form >= 3:
		_prism_nova(ability)
		return
	if ability.kind == Ability.Kind.HERO_TRANSFORM:
		var gather := GatherLight.new()
		entities.add_child(gather)
		gather.position = player.position
		gather.setup(TILE_SIZE, AEL_FORM_COLORS[3], Transformation.CHARGE_TIME)
		_shake(0.8, 0.35)
		return
	if character.hero_form >= 1:
		var nova := CrystalNova.new()
		entities.add_child(nova)
		nova.position = player.position
		nova.setup(ability.radius * float(TILE_SIZE), TILE_SIZE, _ael_colour())
		_shake(0.3, 0.9)
		return
	var glint := GemGlint.new()
	player.add_child(glint)
	glint.position = Vector2(0.0, -Player.BODY_SCREEN_HEIGHT * 0.55)
	glint.setup(float(TILE_SIZE) * 0.6, AEL_SHARD)
	_ael_ring(ability.radius * float(TILE_SIZE), AEL_SHARD, 0.3)
	_ael_ring(ability.radius * float(TILE_SIZE) * 0.6, AEL_STEEL, 0.22)
	_shake(0.25, 0.8)


## Le Prisme ultime : une explosion de lasers, qui file droit sur chaque ennemi qu'elle touche.
func _prism_nova(ability: Ability) -> void:
	var reach := ability.radius * float(TILE_SIZE)
	var targets: Array[Vector2] = []
	for i in enemies.size():
		if combat_context.enemy_alive(i) and _structure_at(i) == null \
				and enemies[i].position.distance_to(player.position) <= reach:
			targets.append(enemies[i].position)
	var nova := PrismNova.new()
	entities.add_child(nova)
	nova.position = player.position
	nova.setup(reach, TILE_SIZE, targets)
	_shake(0.7, 1.8)


func _ael_ring(radius: float, colour: Color, seconds: float) -> void:
	var ring := SlashArc.new()
	player.add_child(ring)
	ring.position = Vector2(0.0, -Player.BODY_SCREEN_HEIGHT * 0.5)
	ring.setup_ring(radius, colour, seconds)
	ring.z_index = 2


## Les charges du sort 3. L'Éveillé file sur un trait de lumière et des aiguilles de cristal jaillissent
## derrière lui ; l'Ascendant passe comme une lumière réfractée, en deux traits brisés ; le Prisme lance devant
## lui une volée de lames de lumière qui le précèdent.
func _ael_charge(form: int, from: Vector2, to: Vector2) -> void:
	player.play_dash(from, 0.16)
	_shake(0.2, 0.6)
	if form == 1:
		var points := PackedVector2Array()
		var steps := maxi(2, int(from.distance_to(to) / float(TILE_SIZE)) + 1)
		for i in steps:
			points.append(from.lerp(to, float(i) / float(steps - 1)))
		var line := CrystalLine.new()
		entities.add_child(line)
		line.setup(points, 0.16, 0.8, TILE_SIZE, _ael_colour())
		return
	if form == 2:
		for side: float in [-1.0, 1.0]:
			var link := PrismLink.new()
			entities.add_child(link)
			var shift := (to - from).orthogonal().normalized() * float(TILE_SIZE) * 0.3 * side
			link.setup(from + shift, to + shift, TILE_SIZE, _ael_colour())
		return
	for i in 4:
		var blade := BladeThrow.new()
		entities.add_child(blade)
		var spread := (to - from).orthogonal().normalized() * float(TILE_SIZE) * 0.35 * (float(i) - 1.5)
		blade.setup(from + spread, to + spread + (to - from).normalized() * float(TILE_SIZE), TILE_SIZE, _ael_colour())


## Ses deux rayons : le Rayon de gemme de l'Éveillé, à facettes, et le Prisme ultime, une colonne d'or
## parcourue d'anneaux.
func _ael_beam(points: PackedVector2Array) -> void:
	var ultimate := character.hero_form >= 3
	var beam := PrismBeam.new()
	entities.add_child(beam)
	beam.setup(points, TILE_SIZE, _ael_colour(), 0.9 if ultimate else 0.7, ultimate)
	_shake(0.45 if ultimate else 0.18, 1.3 if ultimate else 0.5)


## La Frappe éclair : un trait au sol, et des aiguilles de cristal qui jaillissent derrière lui.
func _ael_line(ability: Ability, path: Array, duration: float) -> void:
	if character.id != CharacterCatalog.AEL or path.is_empty():
		return
	var points := PackedVector2Array()
	for cell in path:
		points.append(maze_renderer.cell_to_world(cell))
	var line := CrystalLine.new()
	entities.add_child(line)
	line.setup(points, maxf(duration, 0.05 * float(points.size())), maxf(1.0, ability.duration), TILE_SIZE,
		_ael_colour())
	_shake(0.12, 0.35)


func _spawn_star_burst(cell: Vector2i, size_tiles: float, colour: Color) -> void:
	var burst := StarBurst.new()
	entities.add_child(burst)
	burst.position = maze_renderer.cell_to_world(cell)
	burst.setup(float(TILE_SIZE) * size_tiles, colour)


## Ses sauts : il arrive tout de suite, et son dessin rattrape le trajet. Chaque forme a sa trace — la
## Ruée et la Roulade de l'Apprenti, le Pas de lumière de l'Éveillé, les Ailes de l'Ascendant, la Comète
## et la Transmission du Prisme. La Ruée et la Comète s'annoncent juste après le saut.
func _ael_leap(from: Vector2i, to: Vector2i) -> void:
	_ael_blink = {"from": maze_renderer.cell_to_world(from), "to": maze_renderer.cell_to_world(to),
		"rush": false, "comet": false}
	player.mover.teleport_to(to)
	player.snap_to_mover()
	_refresh_ai()
	_ael_land.call_deferred()


func _ael_land() -> void:
	if _ael_blink.is_empty() or player == null:
		return
	var from: Vector2 = _ael_blink["from"]
	var to: Vector2 = _ael_blink["to"]
	var form := character.hero_form
	# Le sort 3 de l'Éveillé, de l'Ascendant et du Prisme : une charge qui frappe en chemin, chacune à sa façon.
	if _ael_blink["rush"] and form >= 1 and form <= 3:
		_ael_charge(form, from, to)
		_ael_blink = {}
		return
	var style := BladeStreak.Style.GHOSTS
	if form >= 4:
		style = BladeStreak.Style.DIVE if _ael_blink["comet"] else BladeStreak.Style.SOAR
	elif _ael_blink["comet"]:
		style = BladeStreak.Style.COMET
	elif form == 1:
		style = BladeStreak.Style.MOTES
	elif form == 2:
		style = BladeStreak.Style.WINGS
	elif form >= 3:
		style = BladeStreak.Style.TRANSMIT
	elif not _ael_blink["rush"]:
		# La Roulade : c'est le corps qui roule, avec un nuage de poussière au départ et un tour de lame à l'arrivée.
		player.play_dash(from, 0.3, 1.0)
		_spawn_star_burst(maze_renderer.world_to_cell(from), 0.9, Color("#c9a77c"))
		_ael_ring(float(TILE_SIZE) * 0.9, AEL_STEEL, 0.25)
		_shake(0.1, 0.3)
		_ael_blink = {}
		return
	var streak := BladeStreak.new()
	entities.add_child(streak)
	streak.setup(from, to, TILE_SIZE, _ael_colour(), player.sprite, player.scale, style)
	# La Transmission ne glisse pas : il disparaît et reparaît. La Chute tombe du ciel sur sa case.
	if style != BladeStreak.Style.TRANSMIT and style != BladeStreak.Style.DIVE:
		player.play_dash(from, 0.18 if style == BladeStreak.Style.COMET else 0.12)
	_shake(0.18, 0.5)
	_ael_blink = {}


# --- Le Porte-Lumière -------------------------------------------------------------

## L'éclair de l'Aube couvre l'écran, et ses colonnes montent à cette hauteur.
const DAWN_TILES := 16.0
const DAWN_TIME := 1.6
const COLUMN_TIME := 0.42
const COLUMN_SIZE := Vector2(1.5, 7.0)

var _wings_cocoon: PaintedBurst = null


func _on_enemy_blinded(index: int, duration: float) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	enemies[index].blind(duration)


func _on_beam_fired(from: Vector2i, cells: Array) -> void:
	var points := PackedVector2Array([maze_renderer.cell_to_world(from)])
	for cell: Vector2i in cells:
		points.append(maze_renderer.cell_to_world(cell))
	if character.id == CharacterCatalog.AEL:
		_ael_beam(points)
		return
	var hits: Array[int] = []
	for enemy in enemies:
		var rank := cells.find(enemy.mover.nearest_cell())
		if rank >= 0:
			hits.append(rank + 1)
	var beam := LightBeam.new()
	entities.add_child(beam)
	beam.setup(points, hits, TILE_SIZE)


func _spawn_wings(duration: float) -> void:
	if _wings_cocoon != null and is_instance_valid(_wings_cocoon):
		_wings_cocoon.queue_free()
	_wings_cocoon = PaintedBurst.new()
	player.add_child(_wings_cocoon)
	_wings_cocoon.setup(TILE_SIZE, 1.2, duration, 0.0, "lumiere_wings")
	_wings_cocoon.position = Vector2(0.0, -TILE_SIZE * 0.55)
	_wings_cocoon.z_index = 2


func _on_wings_burst(cell: Vector2i) -> void:
	_spawn_painted_burst(cell, 1.6, 0.4, "lumiere_ring")
	_spawn_painted_burst(cell, 1.0, 0.5, "lumiere_feathers")


func _on_dawn_cast(cell: Vector2i) -> void:
	if character.id == "etoiles":
		_spawn_night(cell)
		return
	var dawn := _spawn_painted_burst(cell, 1.0, DAWN_TIME, "lumiere_dawn")
	dawn.scale = Vector2.ONE
	dawn.span_tiles(TILE_SIZE, DAWN_TILES)
	dawn.z_index = 12
	_spawn_painted_burst(cell, 1.0, 1.4, "lumiere_feathers")


## La colonne descend du ciel jusqu'aux pieds de l'ennemi, debout dans les deux vues.
func _on_dawn_struck(cell: Vector2i) -> void:
	if character.id == "etoiles":
		_spawn_comet(cell, COMET_TIME, COMET_SIZE)
		return
	var column := _spawn_painted_burst(cell, 1.0, COLUMN_TIME, "lumiere_column")
	var shaft := column.get_child(0) as Sprite2D
	shaft.scale = COLUMN_SIZE * TILE_SIZE
	shaft.position = Vector2(0.0, -COLUMN_SIZE.y * TILE_SIZE * 0.5)
	_spawn_painted_burst(cell, 1.3, 0.5, "lumiere_ring")


# --- L'Ange des Étoiles ------------------------------------------------------------

## La nuit couvre l'écran au-delà de ce que voit le joueur, comme l'Aube.
const NIGHT_TILES := 16.0
const NIGHT_TIME := 2.6
const COMET_TIME := 0.8
const COMET_SIZE := Vector2(3.0, 7.0)
const FALLING_SIZE := Vector2(2.2, 5.0)
## L'impact de la comète tombe à 45 % de sa vie (`etoiles_comet.gdshader`).
const COMET_LAND := 0.45
const VEIL_ALPHA := 0.62

var _constellation: Constellation = null


func _on_enemy_star_marks(index: int, count: int) -> void:
	if _structure_at(index) == null and index < enemies.size():
		enemies[index].set_star_marks(count)


func _on_astre_burst(cell: Vector2i) -> void:
	_spawn_painted_burst(cell, 1.5, 0.4, "etoiles_ring")
	_spawn_painted_burst(cell, 1.0, 0.35, "etoiles_impact").z_index = 11


func _on_stars_changed(cells: Array) -> void:
	if character == null or character.id != "etoiles":
		return
	if cells.is_empty() and (_constellation == null or not is_instance_valid(_constellation)):
		return
	if _constellation == null or not is_instance_valid(_constellation):
		_constellation = Constellation.new()
		entities.add_child(_constellation)
		_constellation.setup(TILE_SIZE)
	var points := PackedVector2Array()
	for cell: Vector2i in cells:
		points.append(maze_renderer.cell_to_world(cell))
	if points.size() > _constellation_size():
		_spawn_painted_burst(cells[-1], 1.2, 0.4, "etoiles_ring")
	_constellation.set_points(points)


func _constellation_size() -> int:
	return _constellation._points.size()


func _on_star_falling(cell: Vector2i, lead: float) -> void:
	if character.id == CharacterCatalog.AEL:
		var shard := ShardRain.new()
		entities.add_child(shard)
		shard.position = maze_renderer.cell_to_world(cell)
		shard.setup(lead, TILE_SIZE, _ael_colour())
		return
	_spawn_comet(cell, lead / COMET_LAND, FALLING_SIZE)


func _on_star_trail(from: Vector2i, to: Vector2i) -> void:
	# Chez Aël, c'est la Ruée qui frappe en chemin : sa traînée est celle de `_ael_leap`.
	if character.id == CharacterCatalog.AEL:
		_ael_blink["rush"] = true
		return
	var trail := StarTrail.new()
	entities.add_child(trail)
	trail.setup(maze_renderer.cell_to_world(from), maze_renderer.cell_to_world(to), TILE_SIZE,
		StarTrail.STEEL_COLORS if character.id == "acier" else {})


## La comète descend du ciel jusqu'au sol de sa case, debout dans les deux vues.
func _spawn_comet(cell: Vector2i, duration: float, size: Vector2) -> void:
	var comet := _spawn_painted_burst(cell, 1.0, duration, "etoiles_comet")
	var shaft := comet.get_child(0) as Sprite2D
	shaft.scale = size * TILE_SIZE
	shaft.position = Vector2(0.0, -size.y * TILE_SIZE * 0.43)
	comet.z_index = 11


func _spawn_veil(duration: float) -> void:
	var veil := PaintedBurst.new()
	player.add_child(veil)
	veil.setup(TILE_SIZE, 1.2, duration, 0.0, "etoiles_veil")
	veil.position = Vector2(0.0, -TILE_SIZE * 0.55)
	veil.z_index = 2
	player.modulate.a = VEIL_ALPHA


func _spawn_night(cell: Vector2i) -> void:
	var night := _spawn_painted_burst(cell, 1.0, NIGHT_TIME, "etoiles_night")
	night.scale = Vector2.ONE
	night.span_tiles(TILE_SIZE, NIGHT_TILES)


# --- Le Démon du Pacte --------------------------------------------------------------

const RAGE_AURA_SIZE := Vector2(2.2, 1.4)
const RAGE_SHADER := preload("res://assets/shaders/demon_rage.gdshader")
const PACT_TIME := 0.95
const FESTIN_TIME := 0.6
const LAST_PACT_TIME := 1.15

var _rage_aura: Sprite2D = null


func _on_pact_signed(cell: Vector2i) -> void:
	_spawn_painted_burst(cell, 1.0, PACT_TIME, "demon_pacte")


func _spawn_demon_blast(ability: Ability, cell: Vector2i) -> void:
	# La gueule passe SOUS lui : de la taille du sort, elle le cachait tout entier.
	var burst := _spawn_painted_burst(cell, ability.radius,
		LAST_PACT_TIME if ability.is_ultimate else FESTIN_TIME,
		"demon_dernier" if ability.is_ultimate else "demon_festin")
	if ability.is_ultimate:
		burst.z_index = 11
		_shake_total = 0.32
		_shake_left = _shake_total
		_shake_time = 0.0


## La Rage se lit sous ses pieds : le cercle grandit à chaque PV perdu, et rien à pleine vie.
func _update_rage() -> void:
	if character == null or character.id != "demon" or player == null:
		return
	# Le niveau se reconstruit au démarrage, et l'ancien mage n'est pas encore libéré à cet instant.
	if _rage_aura == null or not is_instance_valid(_rage_aura) or _rage_aura.get_parent() != player:
		var shaded := ShaderMaterial.new()
		shaded.shader = RAGE_SHADER
		_rage_aura = Sprite2D.new()
		_rage_aura.texture = MagicOrb.painted_quad()
		_rage_aura.material = shaded
		_rage_aura.scale = RAGE_AURA_SIZE * float(TILE_SIZE)
		_rage_aura.show_behind_parent = true
		player.add_child(_rage_aura)
	var rage := combat.rage_bonus() / CombatSystem.RAGE_MAX
	_rage_aura.visible = rage > 0.0
	(_rage_aura.material as ShaderMaterial).set_shader_parameter("rage", rage)


# --- La Démone de la Discorde -------------------------------------------------------

const EYE_RADIUS := 0.95
## L'entrée de l'extra reste autour d'elle : sur toute la carte, elle cachait ce qui se passait.
const GREAT_DISCORD_RADIUS := 1.7
const GREAT_DISCORD_TIME := 1.05
const SWAP_TIME := 0.5
const BRAWL_TIME := 0.3
const BRAWL_SCALE := 0.55

var _discord_threads: DiscordThreads = null


func _on_enemy_possessed(index: int, duration: float) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	var enemy: Enemy = enemies[index]
	enemy.possess(duration)
	if duration <= 0.0:
		return
	var eye := PaintedBurst.new()
	enemy.add_child(eye)
	eye.setup(TILE_SIZE, EYE_RADIUS, duration, float(index) * 0.37, "discorde_oeil")
	eye.set_shader_seconds(duration)
	eye.position = Vector2(0.0, -TILE_SIZE * DiscordThreads.EYE_HEIGHT)
	eye.z_index = 2


func _on_possession_field(field: PackedInt32Array) -> void:
	for enemy in enemies:
		if enemy.ai != null:
			enemy.ai.possess_field = field


func _on_great_discord(cell: Vector2i) -> void:
	var burst := _spawn_painted_burst(cell, GREAT_DISCORD_RADIUS, GREAT_DISCORD_TIME, "discorde_grande")
	# Il flotte au-dessus d'elle : plein, il la cacherait.
	burst.position.y -= TILE_SIZE * DiscordThreads.GREAT_EYE_HEIGHT
	burst.z_index = 11
	if _discord_threads != null and is_instance_valid(_discord_threads):
		_discord_threads.launch()
	_shake_total = 0.16
	_shake_left = _shake_total
	_shake_time = 0.0


func _on_brawl_struck(cell: Vector2i) -> void:
	# Petit : une mêlée en fait beaucoup, et de pleine taille ils cachaient les combattants.
	_spawn_painted_burst(cell, 0.9, BRAWL_TIME, "discorde_noeud").scale = Vector2.ONE * BRAWL_SCALE


func _on_bond_struck(cell: Vector2i) -> void:
	_spawn_painted_burst(cell, 0.9, BRAWL_TIME * 0.7, "discorde_noeud").scale = Vector2.ONE * BRAWL_SCALE


func _on_enemy_swapped(index: int, cell: Vector2i) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	var enemy: Enemy = enemies[index]
	_spawn_painted_burst(enemy.mover.nearest_cell(), 1.0, SWAP_TIME, "discorde_echange")
	_spawn_painted_burst(cell, 1.0, SWAP_TIME, "discorde_echange")
	enemy.mover.teleport_to(cell)
	enemy.snap_to_mover()


func _update_discord_threads() -> void:
	if character == null or character.id != "discorde":
		return
	if _discord_threads == null or not is_instance_valid(_discord_threads) \
			or _discord_threads.get_parent() != entities:
		_discord_threads = DiscordThreads.new()
		entities.add_child(_discord_threads)
		_discord_threads.z_index = 11
	_discord_threads.show_state(enemies, combat, TILE_SIZE, player)


# --- Le Geôlier --------------------------------------------------------------------

const GAOLER_PIECES := "res://assets/characters/geolier/pieces/"
const NOVA_RADIUS := 2.7
const NOVA_TIME := 0.6
const FROST_RADIUS := 0.9
const GAOL_RING_TIME_PAD := 0.1
const SHACKLE_TILES := 0.7

var _gaoler_chains: GaolerChains = null
var _gaol_flames: Array[PaintedBurst] = []
var _gaoler_aura: CPUParticles2D = null
const PALE_COLD := Color("#e6fdff")
const CYAN_COLD := Color("#16e0e8")
const DEEP_COLD := Color("#0a6f7a")
const GAOL_VEIL_TILES := 40.0
const GAOL_COLUMN_RADIUS := 1.1


func _update_gaoler_chains() -> void:
	if character == null or character.id != "geolier" or player == null:
		return
	if _gaoler_chains == null or not is_instance_valid(_gaoler_chains) \
			or _gaoler_chains.get_parent() != entities:
		_gaoler_chains = GaolerChains.new()
		entities.add_child(_gaoler_chains)
		_gaoler_chains.z_index = 11
	_gaoler_chains.show_state(enemies, combat, player, TILE_SIZE)
	_ensure_gaoler_aura()


## La flamme froide qui s'échappe de lui en permanence : de petites langues qui montent et s'éteignent.
func _ensure_gaoler_aura() -> void:
	if _gaoler_aura != null and is_instance_valid(_gaoler_aura) and _gaoler_aura.get_parent() == player:
		return
	_gaoler_aura = CPUParticles2D.new()
	player.add_child(_gaoler_aura)
	_gaoler_aura.position = Vector2(0.0, -TILE_SIZE * 0.6)
	_gaoler_aura.amount = 18
	_gaoler_aura.lifetime = 0.9
	_gaoler_aura.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_gaoler_aura.emission_sphere_radius = TILE_SIZE * 0.35
	_gaoler_aura.direction = Vector2.UP
	_gaoler_aura.spread = 25.0
	_gaoler_aura.gravity = Vector2(0.0, -TILE_SIZE * 1.2)
	_gaoler_aura.initial_velocity_min = TILE_SIZE * 0.2
	_gaoler_aura.initial_velocity_max = TILE_SIZE * 0.7
	_gaoler_aura.scale_amount_min = TILE_SIZE * 0.03
	_gaoler_aura.scale_amount_max = TILE_SIZE * 0.07
	var fade := Gradient.new()
	fade.set_color(0, PALE_COLD)
	fade.set_color(1, Color(CYAN_COLD, 0.0))
	_gaoler_aura.color_ramp = fade
	_gaoler_aura.emitting = true


## Une gerbe d'éclats de givre, pour les prises et les bris.
func _frost_shards(cell: Vector2i, count: int) -> void:
	var shards := CPUParticles2D.new()
	entities.add_child(shards)
	shards.position = maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.5)
	shards.z_index = 11
	shards.amount = count
	shards.lifetime = 0.7
	shards.one_shot = true
	shards.explosiveness = 1.0
	shards.spread = 180.0
	shards.gravity = Vector2(0.0, TILE_SIZE * 7.0)
	shards.initial_velocity_min = TILE_SIZE * 2.0
	shards.initial_velocity_max = TILE_SIZE * 5.5
	shards.angular_velocity_min = -400.0
	shards.angular_velocity_max = 400.0
	shards.scale_amount_min = TILE_SIZE * 0.04
	shards.scale_amount_max = TILE_SIZE * 0.1
	shards.color = PALE_COLD
	shards.finished.connect(shards.queue_free)
	shards.emitting = true


func _cold_streak(from: Vector2i, to: Vector2i, seconds: float) -> void:
	var streak := BladeDash.new()
	entities.add_child(streak)
	streak.setup(maze_renderer.cell_to_world(from), maze_renderer.cell_to_world(to), TILE_SIZE, seconds)
	streak.tint(PALE_COLD, CYAN_COLD, DEEP_COLD)


func _on_enemy_shackled(index: int, seconds: float) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	var enemy: Enemy = enemies[index]
	var shackle := Sprite2D.new()
	shackle.texture = load(GAOLER_PIECES + "manille.png")
	var unit := SHACKLE_TILES * float(TILE_SIZE) / float(shackle.texture.get_width())
	shackle.scale = Vector2(unit, unit * 0.5)
	shackle.z_index = -1
	shackle.material = KingArmor.metal_material(0.0)
	enemy.add_child(shackle)
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if is_instance_valid(shackle):
			shackle.queue_free())
	var cell := enemy.mover.nearest_cell()
	_front_burst(cell, 1.1, 0.4, "geolier_eclat")
	_spawn_painted_burst(cell, 1.3, 0.9, "geolier_givre")
	_frost_shards(cell, 12)
	_shake(0.14, 0.45)


func _on_enemy_hooked(index: int, from: Vector2i, to: Vector2i) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	var enemy: Enemy = enemies[index]
	if _gaoler_chains != null and is_instance_valid(_gaoler_chains):
		_gaoler_chains.throw_hook(maze_renderer.cell_to_world(from), enemy)
	_front_burst(from, 1.2, 0.4, "geolier_eclat")
	_cold_streak(from, to, 0.32)
	enemy.mover.teleport_to(to)
	enemy.snap_to_mover()
	_front_burst(to, 1.5, 0.55, "geolier_eclat")
	_spawn_painted_burst(to, 1.8, 1.0, "geolier_givre")
	_frost_shards(to, 16)
	_spawn_slow_motion(0.08, 0.25)
	_shake(0.26, 0.7)


func _on_enemies_frozen(indices: Array, seconds: float) -> void:
	# L'Archange du Ciel a ses propres marques, posées par `_on_enemies_dazed`.
	if character.id == "ciel":
		return
	if player != null:
		var cell := player.mover.nearest_cell()
		_front_burst(cell, NOVA_RADIUS, NOVA_TIME, "geolier_nova")
		_spawn_painted_burst(cell, NOVA_RADIUS + 0.4, 1.4, "geolier_givre")
		_spawn_wave(cell, NOVA_RADIUS * 3.0, 0.5, "geolier_onde")
		_frost_shards(cell, 22)
		_spawn_slow_motion(0.08, 0.25)
	for index: int in indices:
		if _structure_at(index) != null or index >= enemies.size():
			continue
		var enemy: Enemy = enemies[index]
		var shell := PaintedBurst.new()
		enemy.add_child(shell)
		shell.setup(TILE_SIZE, FROST_RADIUS, seconds, float(index) * 0.31, "geolier_gangue")
		shell.position = Vector2(0.0, -TILE_SIZE * 0.55)
		shell.z_index = 2
	_shake(0.28, 0.6)


func _on_soul_chains_cast(indices: Array, _seconds: float) -> void:
	if player != null:
		_front_burst(player.mover.nearest_cell(), 1.6, 0.5, "geolier_eclat")
		_spawn_wave(player.mover.nearest_cell(), 7.0, 0.45, "geolier_onde")
	for index: int in indices:
		if _structure_at(index) == null and index < enemies.size():
			var cell: Vector2i = (enemies[index] as Enemy).mover.nearest_cell()
			_front_burst(cell, 1.1, 0.4, "geolier_choc")
			_frost_shards(cell, 8)
	_shake(0.22, 0.5)


func _on_gaol_cast(cell: Vector2i, _indices: Array, radius: float, seconds: float) -> void:
	var veil := _spawn_painted_burst(cell, 3.0, seconds + GAOL_RING_TIME_PAD, "geolier_voile")
	veil.span_tiles(TILE_SIZE, GAOL_VEIL_TILES)
	veil.z_index = 3
	veil.position = player.position
	var ring := _spawn_painted_burst(cell, 3.0, seconds + GAOL_RING_TIME_PAD, "geolier_cercle")
	ring.span_tiles(TILE_SIZE, radius * 1.09)
	ring.z_index = 4
	ring.position = player.position
	_spawn_painted_burst(cell, 3.0, 1.6, "geolier_givre")
	_gaol_flames.clear()
	for index: int in _indices:
		if _structure_at(index) != null or index >= enemies.size():
			continue
		var enemy: Enemy = enemies[index]
		var flame := PaintedBurst.new()
		enemy.add_child(flame)
		flame.setup(TILE_SIZE, GAOL_COLUMN_RADIUS, seconds, float(index) * 0.21, "geolier_colonne")
		flame.position = Vector2(0.0, -TILE_SIZE * 0.6)
		flame.z_index = 2
		_gaol_flames.append(flame)
		_frost_shards(enemy.mover.nearest_cell(), 10)
	_front_burst(cell, 2.4, NOVA_TIME, "geolier_nova")
	_spawn_wave(cell, radius * 2.6, WAVE_TIME, "geolier_onde")
	if _gaoler_chains != null and is_instance_valid(_gaoler_chains):
		_gaoler_chains.raise_gaol()
	_shake(0.5, 0.9)


func _on_gaol_ended(cells: Array) -> void:
	for flame in _gaol_flames:
		if is_instance_valid(flame):
			flame.queue_free()
	_gaol_flames.clear()
	for cell: Vector2i in cells:
		_front_burst(cell, 1.6, 0.7, "geolier_eclat")
		_frost_shards(cell, 18)
	if player != null:
		_spawn_wave(player.mover.nearest_cell(), 18.0, WAVE_TIME, "geolier_onde")
	_spawn_slow_motion(0.12, 0.2)
	_shake(0.45, 0.85)


# --- Le Dragon des Abysses ---------------------------------------------------------

const DRAGON_PIECES := "res://assets/characters/dragon/pieces/"
const DRAGON_PALE := Color("#ffe36a")
const DRAGON_MAGMA := Color("#ff5a10")
const DRAGON_RED := Color("#d1200c")
const DRAGON_BLOOD := Color("#8a160c")
## Le sol en feu tient dans sa case.
const FIRE_TILE_RADIUS := 0.62
## Le souffle court d'une case à la suivante.
const BREATH_STEP := 0.055
const BALL_TILES := 0.62
const BITE_TILES := 1.6
const SHARD_TILES := 0.55
const SHARD_TIME := 0.38
## L'ombre de l'ultime : son envergure, et la distance qu'elle parcourt, en cases.
const SHADOW_SPAN := 10.0
const SHADOW_TRAVEL := 22.0
const DRAGON_VEIL_TILES := 40.0

var _fire_tiles := {}                  # case -> PaintedBurst du sol en feu
var _dragon_aura: CPUParticles2D = null
var _scales_shell: PaintedBurst = null
var _scales_flames: CPUParticles2D = null
var _dragon_veil: PaintedBurst = null


## Ses braises montent sans cesse ; dans le feu, elles redoublent, et c'est là qu'il va plus vite.
func _update_dragon_aura() -> void:
	if character == null or character.id != "dragon" or player == null:
		return
	if _dragon_aura == null or not is_instance_valid(_dragon_aura) or _dragon_aura.get_parent() != player:
		_dragon_aura = FxTextures.flame_emitter(18, 0.8, TILE_SIZE * 0.13, Color(DRAGON_PALE, 0.95),
			Color(DRAGON_RED, 0.0), -TILE_SIZE * 1.5, 35.0)
		player.add_child(_dragon_aura)
		_dragon_aura.position = Vector2(0.0, -TILE_SIZE * 0.7)
		_dragon_aura.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		_dragon_aura.emission_sphere_radius = TILE_SIZE * 0.35
		_dragon_aura.direction = Vector2.UP
		_dragon_aura.emitting = true
	var lit := combat.fire_cells().has(player.mover.nearest_cell())
	_dragon_aura.speed_scale = 2.0 if lit else 1.0
	_dragon_aura.modulate = Color(1.4, 1.2, 1.0) if lit else Color.WHITE


func _arm_ball(orb: MagicOrb, path: String) -> void:
	var texture: Texture2D = load(path)
	var ball := Sprite2D.new()
	ball.texture = texture
	var quad := orb.sprite.scale / MagicOrb.PAINTED_BIRTH_SCALE
	var unit := BALL_TILES * float(TILE_SIZE) / float(texture.get_height())
	ball.scale = Vector2(unit / quad.x, unit / quad.y)
	ball.position = Vector2(0.28, 0.0)
	orb.sprite.add_child(ball)
	ball.create_tween().set_loops().tween_property(ball, "rotation", TAU, 0.5).from(0.0)


func _flame_streak(from: Vector2i, to: Vector2i, seconds: float) -> void:
	var streak := BladeDash.new()
	entities.add_child(streak)
	streak.setup(maze_renderer.cell_to_world(from), maze_renderer.cell_to_world(to), TILE_SIZE, seconds)
	streak.tint(DRAGON_PALE, DRAGON_MAGMA, DRAGON_RED)


func _dragon_smoke_puff(cell: Vector2i, amount: int) -> void:
	var smoke := FxTextures.smoke_emitter(amount, 1.1, TILE_SIZE * 0.9, -TILE_SIZE * 0.8)
	var embers := FxTextures.flame_emitter(amount, 0.6, TILE_SIZE * 0.14, Color(DRAGON_PALE, 0.95),
		Color(DRAGON_RED, 0.0), -TILE_SIZE * 2.2, 180.0)
	embers.initial_velocity_min = TILE_SIZE * 0.8
	embers.initial_velocity_max = TILE_SIZE * 2.6
	for puff: CPUParticles2D in [smoke, embers]:
		entities.add_child(puff)
		puff.position = maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.4)
		puff.z_index = 11
		puff.one_shot = true
		puff.explosiveness = 0.85
		puff.emitting = true
		get_tree().create_timer(puff.lifetime + 0.4).timeout.connect(puff.queue_free)


## Une case qui brûle déjà repart pour sa nouvelle durée sans se rallumer : pas de clignement.
func _on_ground_ignited(cells: Array, seconds: float) -> void:
	for cell: Vector2i in cells:
		# Non typée : une case éteinte garde une référence libérée, qu'un type refuserait.
		var old: Variant = _fire_tiles.get(cell)
		if old != null and is_instance_valid(old):
			(old as PaintedBurst).relight(seconds, 0.12)
			continue
		var fire := _spawn_painted_burst(cell, FIRE_TILE_RADIUS, seconds, "dragon_brasier")
		fire.z_index = 8
		_fire_tiles[cell] = fire


func _on_breath_cast(from: Vector2i, cells: Array, _seconds: float) -> void:
	_front_burst(from, 1.1, 0.3, "dragon_choc")
	if not cells.is_empty():
		_flame_streak(from, cells[cells.size() - 1], 0.4)
	for k in cells.size():
		var cell: Vector2i = cells[k]
		get_tree().create_timer(BREATH_STEP * float(k)).timeout.connect(func() -> void:
			_spawn_painted_burst(cell, 1.1, 0.5, "dragon_explosion")
			_dragon_smoke_puff(cell, 8))
	_shake(0.4, 0.65)


func _on_dragon_bit(_index: int, cell: Vector2i, devoured: bool) -> void:
	var jaw := Sprite2D.new()
	jaw.texture = load(DRAGON_PIECES + "gueule.png")
	entities.add_child(jaw)
	jaw.position = maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.55)
	jaw.z_index = 12
	var unit := BITE_TILES * float(TILE_SIZE) / float(jaw.texture.get_width())
	var stand := CameraRules.stand_scale()
	jaw.scale = Vector2(unit * 0.45, unit * 0.45 * stand)
	var tween := jaw.create_tween()
	tween.tween_property(jaw, "scale", Vector2(unit, unit * stand), 0.13) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# La gueule se REFERME : elle s'écrase de haut en bas sur la proie.
	tween.tween_property(jaw, "scale", Vector2(unit * 1.1, unit * 0.12 * stand), 0.09) \
		.set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		_front_burst(cell, 1.4, 0.45, "dragon_explosion")
		_spawn_painted_burst(cell, 1.4, 1.0, "dragon_fissure")
		_spawn_slow_motion(0.08, 0.25)
		_shake(0.26, 0.8))
	tween.tween_property(jaw, "modulate:a", 0.0, 0.12)
	tween.tween_callback(jaw.queue_free)
	if devoured and player != null:
		# La flamme de la proie remonte jusqu'à lui : il se soigne en la dévorant.
		var home := player.mover.nearest_cell()
		get_tree().create_timer(0.25).timeout.connect(func() -> void:
			_flame_streak(cell, home, 0.35)
			_front_burst(home, 1.2, 0.55, "dragon_choc")
			_dragon_smoke_puff(home, 12))


func _free_scales_shell() -> void:
	if _scales_shell != null and is_instance_valid(_scales_shell):
		_scales_shell.queue_free()
	_scales_shell = null
	if _scales_flames != null and is_instance_valid(_scales_flames):
		_scales_flames.emitting = false
		var flames := _scales_flames
		get_tree().create_timer(flames.lifetime + 0.2).timeout.connect(func() -> void:
			if is_instance_valid(flames):
				flames.queue_free())
	_scales_flames = null


func _on_scales_raised(seconds: float) -> void:
	if player == null:
		return
	_free_scales_shell()
	# Le sol se fend de lave sous lui, et une couronne de flammes l'enveloppe tant qu'elles tiennent.
	_scales_shell = PaintedBurst.new()
	player.add_child(_scales_shell)
	_scales_shell.setup(TILE_SIZE, 1.2, seconds + 0.2, 0.7, "dragon_fissure")
	_scales_shell.z_index = -1
	_scales_flames = FxTextures.flame_emitter(70, 0.6, TILE_SIZE * 0.3, Color(DRAGON_PALE, 0.95),
		Color(DRAGON_RED, 0.0), -TILE_SIZE * 2.6, 20.0)
	player.add_child(_scales_flames)
	_scales_flames.position = Vector2(0.0, -TILE_SIZE * 0.35)
	_scales_flames.emission_shape = CPUParticles2D.EMISSION_SHAPE_RING
	_scales_flames.emission_ring_radius = TILE_SIZE * 0.42
	_scales_flames.emission_ring_inner_radius = TILE_SIZE * 0.3
	_scales_flames.direction = Vector2.UP
	_scales_flames.emitting = true
	var cell := player.mover.nearest_cell()
	_front_burst(cell, 1.3, 0.45, "dragon_choc")
	_dragon_smoke_puff(cell, 12)
	_shake(0.18, 0.45)


func _on_scales_burst(cell: Vector2i, count: int, radius: float) -> void:
	_free_scales_shell()
	var texture: Texture2D = load(DRAGON_PIECES + "ecaille.png")
	var centre := maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.5)
	var unit := SHARD_TILES * float(TILE_SIZE) / float(texture.get_height())
	for k in count:
		var angle := TAU * float(k) / float(count)
		var shard := Sprite2D.new()
		shard.texture = texture
		entities.add_child(shard)
		shard.position = centre
		shard.z_index = 12
		shard.scale = Vector2(unit, unit)
		# Dessinée pointe en haut : ce quart de tour la met dans l'axe de sa course.
		shard.rotation = angle + PI / 2.0
		var dir := Vector2(cos(angle), sin(angle))
		var tween := shard.create_tween()
		tween.tween_property(shard, "position", centre + dir * radius * float(TILE_SIZE), SHARD_TIME) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(shard, "scale", Vector2.ZERO, 0.14)
		tween.tween_callback(shard.queue_free)
	_front_burst(cell, 1.6, 0.5, "dragon_explosion")
	_spawn_wave(cell, radius * 2.4, 0.5, "dragon_onde")
	_dragon_smoke_puff(cell, 18)
	_spawn_slow_motion(0.06, 0.3)
	_shake(0.32, 0.75)


## Les ailes de flamme et d'ombre se déploient d'un coup autour de lui, puis s'effacent.
func _on_wings_beaten(cell: Vector2i, radius: float) -> void:
	var wings := Sprite2D.new()
	wings.texture = load(DRAGON_PIECES + "silhouette.png")
	entities.add_child(wings)
	wings.position = maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.6)
	wings.z_index = 8
	var unit := (radius * 2.0 + 1.4) * float(TILE_SIZE) / float(wings.texture.get_width())
	wings.scale = Vector2(unit, unit) * 0.35
	wings.modulate = Color(1.0, 0.6, 0.4, 0.92)
	var tween := wings.create_tween()
	tween.tween_property(wings, "scale", Vector2(unit, unit), 0.14) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(wings, "modulate:a", 0.0, 0.32)
	tween.tween_callback(wings.queue_free)
	_front_burst(cell, radius + 0.6, 0.5, "dragon_nova")
	_spawn_wave(cell, radius * 3.0, 0.45, "dragon_onde")
	_dragon_smoke_puff(cell, 22)
	_shake(0.3, 0.7)


func _on_dragon_shadow_cast(cell: Vector2i, direction: Vector2i, indices: Array, delay: float) -> void:
	if player == null:
		return
	var total := delay + CombatSystem.SHADOW_GAP * float(indices.size()) + 1.0
	if _dragon_veil != null and is_instance_valid(_dragon_veil):
		_dragon_veil.queue_free()
	_dragon_veil = _spawn_painted_burst(cell, 3.0, total, "dragon_voile")
	_dragon_veil.span_tiles(TILE_SIZE, DRAGON_VEIL_TILES)
	_dragon_veil.z_index = 3
	_dragon_veil.position = player.position
	# Le rugissement : la gorge s'embrase et la caméra tremble. Sous lui, pour ne pas le cacher.
	_spawn_painted_burst(cell, 1.8, 0.6, "dragon_explosion")
	_dragon_smoke_puff(cell, 24)
	_shake(0.8, 1.0)
	# L'ombre, couchée au sol : elle n'est pas redressée comme un personnage.
	var shadow := Sprite2D.new()
	shadow.texture = load(DRAGON_PIECES + "silhouette.png")
	entities.add_child(shadow)
	shadow.z_index = 20
	shadow.modulate = Color(0.03, 0.0, 0.0, 0.62)
	var unit := SHADOW_SPAN * float(TILE_SIZE) / float(shadow.texture.get_width())
	shadow.scale = Vector2(unit, unit)
	var axis := Vector2(direction).normalized()
	shadow.rotation = axis.angle() + PI / 2.0
	var centre := player.position
	shadow.position = centre - axis * SHADOW_TRAVEL * 0.5 * float(TILE_SIZE)
	var tween := shadow.create_tween()
	tween.tween_property(shadow, "position", centre + axis * SHADOW_TRAVEL * 0.5 * float(TILE_SIZE),
		delay * 1.6)
	tween.tween_callback(shadow.queue_free)


func _on_shadow_column(cell: Vector2i, first: bool) -> void:
	_front_burst(cell, 1.3, 0.9, "dragon_colonne")
	_front_burst(cell, 1.5, 0.5, "dragon_explosion")
	_spawn_painted_burst(cell, 1.6, 1.2, "dragon_fissure")
	_dragon_smoke_puff(cell, 10)
	_shake(0.22, 0.6)
	if first:
		_spawn_slow_motion(0.12, 0.25)


func _on_shadow_ended() -> void:
	if player != null:
		_spawn_wave(player.mover.nearest_cell(), 18.0, WAVE_TIME, "dragon_onde")
	_shake(0.4, 0.8)


# --- Le Croupier des Enfers -----------------------------------------------------------

const CROUPIER_PIECES := "res://assets/characters/croupier/pieces/"
const GOLD := Color("#e8b54a")
const GOLD_PALE := Color("#fff2c4")
const CARD_TILES := 0.62
const DIE_TILES := 0.6
const COIN_TILES := 0.75
const CHIP_TILES := 0.32
const WHEEL_TILES := 8.0
## La bille court près du bord de la roue, dans la couronne des cases.
const BALL_RING := 0.4
const ROULETTE_CELLS := 37
const FLIP_TIME := 0.18

var _traps_drawn := {}                 # case -> Sprite2D de la carte face cachée
var _card_decoy: Sprite2D = null
var _doubled_glow: CPUParticles2D = null
var _roulette_wheel: Sprite2D = null
var _roulette_ball: Sprite2D = null
var _roulette_veil: PaintedBurst = null


func _piece_sprite(texture_name: String, tiles: float, at: Vector2, z: int = 12) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = load(CROUPIER_PIECES + texture_name)
	entities.add_child(sprite)
	sprite.position = at
	sprite.z_index = z
	var unit := tiles * float(TILE_SIZE) / float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
	sprite.scale = Vector2(unit, unit)
	return sprite


## Un grand mot d'or au-dessus de la scène : le total des dés, ROUGE, NOIR, JACKPOT.
func _gold_words(text: String, at: Vector2, size_tiles: float, tint: Color = GOLD) -> void:
	var words := Label.new()
	words.text = text
	words.add_theme_font_size_override("font_size", int(size_tiles * float(TILE_SIZE)))
	words.add_theme_color_override("font_color", tint)
	words.add_theme_color_override("font_outline_color", Color("#15100f"))
	words.add_theme_constant_override("outline_size", int(float(TILE_SIZE) * 0.12))
	words.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words.z_index = 30
	entities.add_child(words)
	words.reset_size()
	words.position = at - Vector2(words.size.x * 0.5, words.size.y)
	words.pivot_offset = words.size * 0.5
	words.scale = Vector2.ONE * 0.4
	var tween := words.create_tween()
	tween.tween_property(words, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.7)
	tween.tween_property(words, "position:y", words.position.y - float(TILE_SIZE) * 0.6, 0.4)
	tween.parallel().tween_property(words, "modulate:a", 0.0, 0.4)
	tween.tween_callback(words.queue_free)


## Des cartes qui partent en éventail en tournant, puis s'effacent.
func _card_spray(cell: Vector2i, count: int) -> void:
	var centre := maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.5)
	for k in count:
		var card := _piece_sprite("dos.png", CARD_TILES * 0.6, centre)
		var angle := TAU * float(k) / float(count) + randf() * 0.4
		var reach := float(TILE_SIZE) * randf_range(0.8, 1.6)
		var tween := card.create_tween().set_parallel()
		tween.tween_property(card, "position", centre + Vector2(cos(angle), sin(angle) - 0.4) * reach, 0.45) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(card, "rotation", randf_range(-2.0, 2.0) * PI, 0.45)
		tween.tween_property(card, "modulate:a", 0.0, 0.25).set_delay(0.3)
		tween.chain().tween_callback(card.queue_free)


## Des pièces et des jetons qui jaillissent, puis retombent.
func _coin_spray(cell: Vector2i, count: int) -> void:
	var centre := maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.5)
	for k in count:
		var coin := _piece_sprite("face.png" if k % 2 == 0 else "jeton.png", CHIP_TILES, centre)
		var side := randf_range(-1.0, 1.0) * float(TILE_SIZE) * 0.9
		var peak := centre + Vector2(side * 0.5, -float(TILE_SIZE) * randf_range(0.7, 1.3))
		var land := centre + Vector2(side, float(TILE_SIZE) * 0.35)
		var tween := coin.create_tween()
		tween.tween_property(coin, "position", peak, 0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(coin, "position", land, 0.26).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(coin, "modulate:a", 0.0, 0.25)
		tween.tween_callback(coin.queue_free)


func _on_lucky_hit(_index: int, cell: Vector2i) -> void:
	_front_burst(cell, 1.25, 0.45, "croupier_eclat")
	_coin_spray(cell, 6)
	_shake(0.12, 0.35)


func _on_dice_rolled(from: Vector2i, cells: Array, first: int, second: int) -> void:
	if cells.is_empty():
		return
	var start := maze_renderer.cell_to_world(from) + Vector2(0.0, -TILE_SIZE * 0.4)
	var end_cell: Vector2i = cells[cells.size() - 1]
	var finish := maze_renderer.cell_to_world(end_cell) + Vector2(0.0, -TILE_SIZE * 0.4)
	var roll_time := 0.12 + 0.06 * float(cells.size())
	for side: float in [-1.0, 1.0]:
		var die := _piece_sprite("de.png", DIE_TILES, start + Vector2(side * TILE_SIZE * 0.22, 0.0))
		var tween := die.create_tween().set_parallel()
		tween.tween_property(die, "position", finish + Vector2(side * TILE_SIZE * 0.25, 0.0), roll_time) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(die, "rotation", side * TAU * 2.5, roll_time).set_ease(Tween.EASE_OUT)
		tween.chain().tween_interval(0.5)
		tween.chain().tween_property(die, "modulate:a", 0.0, 0.25)
		tween.chain().tween_callback(die.queue_free)
	for k in cells.size():
		var cell: Vector2i = cells[k]
		get_tree().create_timer(0.06 * float(k)).timeout.connect(func() -> void:
			_spawn_painted_burst(cell, 0.95, 0.4, "croupier_choc"))
	var double := first == second
	get_tree().create_timer(roll_time).timeout.connect(func() -> void:
		_gold_words("%d" % (first + second) + (" DOUBLE !" if double else ""),
			finish + Vector2(0.0, -TILE_SIZE * 0.9), 1.1 if double else 0.9)
		_front_burst(end_cell, 1.8 if double else 1.2, 0.5, "croupier_explosion" if double else "croupier_eclat")
		if double:
			_spawn_wave(end_cell, 7.0, 0.45, "croupier_onde")
			_spawn_slow_motion(0.08, 0.3)
		_shake(0.3 if double else 0.15, 0.7 if double else 0.4))


func _on_trap_posed(cell: Vector2i, _seconds: float) -> void:
	_on_trap_faded(cell)
	var at := maze_renderer.cell_to_world(cell)
	var card := _piece_sprite("dos.png", CARD_TILES, at + Vector2(0.0, -TILE_SIZE * 0.9), 8)
	var rest := card.scale * Vector2(1.0, 0.55)
	card.rotation = PI
	var tween := card.create_tween().set_parallel()
	tween.tween_property(card, "position", at, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(card, "rotation", 0.0, 0.3)
	tween.tween_property(card, "scale", rest, 0.3)
	tween.chain().tween_callback(func() -> void: _spawn_painted_burst(cell, 0.9, 0.35, "croupier_choc"))
	# Elle luit faiblement, pour qu'on la retrouve au sol.
	var glow := card.create_tween().set_loops()
	glow.tween_property(card, "modulate", Color(1.35, 1.2, 0.9), 0.6).set_delay(0.3)
	glow.tween_property(card, "modulate", Color.WHITE, 0.6)
	_traps_drawn[cell] = card


func _on_trap_faded(cell: Vector2i) -> void:
	# Non typée : une carte déjà libérée garde une référence qu'un type refuserait.
	var card: Variant = _traps_drawn.get(cell)
	_traps_drawn.erase(cell)
	if card != null and is_instance_valid(card):
		(card as Sprite2D).queue_free()


func _on_trap_flipped(cell: Vector2i, suit: int, targets: Array) -> void:
	_on_trap_faded(cell)
	var at := maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.7)
	var faces := ["as_feu.png", "dame_glace.png", "roi_foudre.png"]
	var figure := _piece_sprite(faces[suit], CARD_TILES * 1.5, at, 13)
	var full := figure.scale * Vector2(1.0, CameraRules.stand_scale())
	# Elle se dresse et se retourne d'un coup : sa largeur passe par zéro.
	figure.scale = Vector2(0.0, full.y)
	var tween := figure.create_tween()
	tween.tween_property(figure, "scale", full, FLIP_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.55)
	tween.tween_property(figure, "modulate:a", 0.0, 0.3)
	tween.tween_callback(figure.queue_free)
	_front_burst(cell, 1.2, 0.4, "croupier_eclat")
	match suit:
		CombatSystem.Suit.FIRE:
			for target: Vector2i in targets:
				_front_burst(target, 1.5, 0.55, "braise_explosion")
				_spawn_painted_burst(target, 1.6, 1.0, "braise_fissure")
		CombatSystem.Suit.ICE:
			for target: Vector2i in targets:
				_front_burst(target, 1.3, 0.45, "geolier_eclat")
				_spawn_painted_burst(target, 1.6, 1.1, "geolier_givre")
				_frost_shards(target, 12)
		CombatSystem.Suit.THUNDER:
			var from := at
			for target: Vector2i in targets:
				var to := maze_renderer.cell_to_world(target) + Vector2(0.0, -TILE_SIZE * 0.5)
				var arc: LightningArc = ARC_SCENE.instantiate()
				entities.add_child(arc)
				arc.setup(from, to, Color("#ffd93a"), float(TILE_SIZE) * 0.16, 0.45)
				_front_burst(target, 1.1, 0.4, "croupier_eclat")
				from = to
	_spawn_slow_motion(0.06, 0.3)
	_shake(0.28, 0.65)


## La pièce monte en tournant au-dessus de lui, ralentit, et retombe sur sa face.
func _on_coin_flipped(face: bool) -> void:
	if player == null:
		return
	var base := player.position + Vector2(0.0, -TILE_SIZE * 1.3)
	var coin := _piece_sprite("face.png", COIN_TILES, base, 14)
	var unit := coin.scale
	var face_texture: Texture2D = load(CROUPIER_PIECES + "face.png")
	var pile_texture: Texture2D = load(CROUPIER_PIECES + "pile.png")
	var spin := func(t: float) -> void:
		var turn := cos(t * TAU * 5.0)
		coin.scale = Vector2(unit.x * absf(turn), unit.y)
		coin.texture = face_texture if turn >= 0.0 else pile_texture
		coin.position = base + Vector2(0.0, -sin(t * PI) * float(TILE_SIZE) * 1.1)
	var tween := coin.create_tween()
	tween.tween_method(spin, 0.0, 1.0, 0.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func() -> void:
		coin.texture = face_texture if face else pile_texture
		coin.scale = unit * 1.25
		_gold_words("FACE !" if face else "PILE !", base + Vector2(0.0, -TILE_SIZE * 0.6), 0.5)
		if player != null:
			_front_burst(player.mover.nearest_cell(), 1.4, 0.5, "croupier_eclat")
			_coin_spray(player.mover.nearest_cell(), 5)
		_shake(0.18, 0.45)
		if not face:
			_raise_doubled_glow())
	tween.tween_interval(0.5)
	tween.tween_property(coin, "modulate:a", 0.0, 0.3)
	tween.tween_callback(coin.queue_free)
	_spawn_slow_motion(0.1, 0.4)


## Pile : une flamme d'or l'entoure tant qu'il lui reste des coups doublés.
func _raise_doubled_glow() -> void:
	_on_doubled_spent()
	if player == null or combat.doubled_left() <= 0:
		return
	_doubled_glow = FxTextures.flame_emitter(26, 0.5, TILE_SIZE * 0.14, Color(GOLD_PALE, 0.95),
		Color(GOLD, 0.0), -TILE_SIZE * 1.6, 60.0)
	player.add_child(_doubled_glow)
	_doubled_glow.position = Vector2(0.0, -TILE_SIZE * 0.45)
	_doubled_glow.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_doubled_glow.emission_sphere_radius = TILE_SIZE * 0.35
	_doubled_glow.emitting = true


func _on_doubled_spent() -> void:
	if _doubled_glow != null and is_instance_valid(_doubled_glow):
		_doubled_glow.queue_free()
	_doubled_glow = null


func _pose_card_decoy(cell: Vector2i, seconds: float) -> void:
	var at := maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.5)
	_card_decoy = _piece_sprite("dos.png", CARD_TILES * 1.3, at, 9)
	_card_decoy.scale *= Vector2(1.0, CameraRules.stand_scale())
	var tween := _card_decoy.create_tween().set_loops(maxi(1, int(seconds / 0.5)))
	tween.tween_property(_card_decoy, "modulate", Color(1.5, 1.3, 0.9), 0.25)
	tween.tween_property(_card_decoy, "modulate", Color.WHITE, 0.25)


func _free_roulette() -> void:
	for node: Node in [_roulette_wheel, _roulette_ball, _roulette_veil]:
		if node != null and is_instance_valid(node):
			node.queue_free()
	_roulette_wheel = null
	_roulette_ball = null
	_roulette_veil = null


## La roue apparaît au-dessus de la carte, tourne, ralentit, et la bille s'arrête en haut sur la case
## tirée : le zéro est en haut de l'image, le rouge 32 à sa droite, le noir 26 à sa gauche.
func _on_roulette_spun(cell: Vector2i, result: int, seconds: float) -> void:
	if player == null:
		return
	_free_roulette()
	var centre := player.position
	_roulette_veil = _spawn_painted_burst(cell, 3.0, seconds + 1.6, "croupier_voile")
	_roulette_veil.span_tiles(TILE_SIZE, 40.0)
	_roulette_veil.z_index = 3
	_roulette_veil.position = centre
	_roulette_wheel = _piece_sprite("roulette.png", WHEEL_TILES, centre, 20)
	_roulette_wheel.modulate = Color(1.0, 1.0, 1.0, 0.93)
	var full := _roulette_wheel.scale
	_roulette_wheel.scale = full * 0.2
	var step := TAU / float(ROULETTE_CELLS)
	var offset := 0.0
	if result == CombatSystem.Slot.RED:
		offset = -step
	elif result == CombatSystem.Slot.BLACK:
		offset = step
	var wheel_tween := _roulette_wheel.create_tween()
	wheel_tween.tween_property(_roulette_wheel, "scale", full, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	wheel_tween.parallel().tween_property(_roulette_wheel, "rotation", TAU * 5.0 + offset, seconds) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	_roulette_ball = _piece_sprite("bille.png", 0.42, centre, 21)
	var ring := WHEEL_TILES * BALL_RING * float(TILE_SIZE)
	var ball := _roulette_ball
	var orbit := func(angle: float) -> void:
		if is_instance_valid(ball):
			ball.position = centre + Vector2(cos(angle), sin(angle)) * ring
	ball.create_tween().tween_method(orbit, -PI / 2.0 + TAU * 7.0, -PI / 2.0, seconds) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_front_burst(cell, 1.6, 0.5, "croupier_eclat")
	_coin_spray(cell, 10)
	_shake(0.5, 0.6)


func _on_roulette_landed(result: int, cells: Array) -> void:
	var centre := player.position if player != null else Vector2.ZERO
	match result:
		CombatSystem.Slot.ZERO:
			_gold_words("JACKPOT !", centre + Vector2(0.0, -TILE_SIZE * 1.6), 1.0)
			for cell: Vector2i in cells:
				var to := maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.5)
				var arc: LightningArc = ARC_SCENE.instantiate()
				entities.add_child(arc)
				arc.setup(to + Vector2(0.0, -TILE_SIZE * 4.0), to, GOLD, float(TILE_SIZE) * 0.2, 0.5)
				_front_burst(cell, 1.8, 0.6, "croupier_explosion")
				_coin_spray(cell, 8)
			_spawn_slow_motion(0.16, 0.25)
			_shake(0.7, 1.0)
		CombatSystem.Slot.RED:
			_gold_words("ROUGE", centre + Vector2(0.0, -TILE_SIZE * 1.6), 0.9, Color("#ff4a3a"))
			for cell: Vector2i in cells:
				_front_burst(cell, 1.3, 0.9, "dragon_colonne")
				_front_burst(cell, 1.4, 0.5, "braise_explosion")
			_spawn_slow_motion(0.1, 0.3)
			_shake(0.5, 0.8)
		_:
			_gold_words("NOIR", centre + Vector2(0.0, -TILE_SIZE * 1.6), 0.9, Color("#d8d0c8"))
			for cell: Vector2i in cells:
				_front_burst(cell, 1.6, 0.6, "croupier_noir")
				_spawn_painted_burst(cell, 1.1, 2.0, "croupier_gangue")
			_spawn_slow_motion(0.1, 0.3)
			_shake(0.5, 0.8)
	if player != null:
		_spawn_wave(player.mover.nearest_cell(), 18.0, WAVE_TIME, "croupier_onde")
	for node: Node in [_roulette_wheel, _roulette_ball]:
		if node != null and is_instance_valid(node):
			var fade := node.create_tween()
			fade.tween_interval(0.6)
			fade.tween_property(node, "modulate:a", 0.0, 0.45)
			fade.tween_callback(node.queue_free)
	_roulette_wheel = null
	_roulette_ball = null


# --- L'Avide, Démon de la Faim ---------------------------------------------------------

const AVIDE_PIECES := "res://assets/characters/avide/pieces/"
const BILE := Color("#c8e830")
const BILE_PALE := Color("#f2ffb0")
const BILE_DEEP := Color("#5a7a12")
## La langue part du ventre, et s'épaissit avec lui.
const TONGUE_WIDTH := 0.42
const TONGUE_LIFT := 0.6
const GULF_FILL := 0.55
const JAW_TILES := 1.6
const BILE_BALL_TILES := 0.55
const FEAST_MOUTH_TILES := 4.5

var _avide_aura: CPUParticles2D = null
var _gulf_mouth: Sprite2D = null
var _feast_mouth: Sprite2D = null
var _feast_veil: PaintedBurst = null


func _avide_sprite(texture_name: String, tiles: float, at: Vector2, z: int = 12) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = load(AVIDE_PIECES + texture_name)
	entities.add_child(sprite)
	sprite.position = at
	sprite.z_index = z
	var unit := tiles * float(TILE_SIZE) / float(maxi(sprite.texture.get_width(), sprite.texture.get_height()))
	sprite.scale = Vector2(unit, unit)
	return sprite


## Une vapeur verte monte de lui ; plus il a mangé, plus elle est épaisse.
func _update_avide_aura() -> void:
	if character == null or character.id != "avide" or player == null:
		return
	if _avide_aura == null or not is_instance_valid(_avide_aura) or _avide_aura.get_parent() != player:
		_avide_aura = FxTextures.flame_emitter(14, 0.9, TILE_SIZE * 0.12, Color(BILE_PALE, 0.8),
			Color(BILE_DEEP, 0.0), -TILE_SIZE * 1.1, 40.0)
		player.add_child(_avide_aura)
		_avide_aura.position = Vector2(0.0, -TILE_SIZE * 0.55)
		_avide_aura.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		_avide_aura.emission_sphere_radius = TILE_SIZE * 0.3
		_avide_aura.direction = Vector2.UP
		_avide_aura.emitting = true
	_avide_aura.speed_scale = 1.0 + 0.3 * float(combat.bites())


func _bile_splash(cell: Vector2i, amount: int) -> void:
	var drops := FxTextures.flame_emitter(amount, 0.6, TILE_SIZE * 0.13, Color(BILE_PALE, 0.95),
		Color(BILE_DEEP, 0.0), TILE_SIZE * 5.0, 180.0, false)
	drops.initial_velocity_min = TILE_SIZE * 1.4
	drops.initial_velocity_max = TILE_SIZE * 3.2
	entities.add_child(drops)
	drops.position = maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.45)
	drops.z_index = 11
	drops.one_shot = true
	drops.explosiveness = 0.9
	drops.emitting = true
	get_tree().create_timer(drops.lifetime + 0.4).timeout.connect(drops.queue_free)


func _bile_streak(from: Vector2i, to: Vector2i, seconds: float) -> void:
	var streak := BladeDash.new()
	entities.add_child(streak)
	streak.setup(maze_renderer.cell_to_world(from), maze_renderer.cell_to_world(to), TILE_SIZE, seconds)
	streak.tint(BILE_PALE, BILE, BILE_DEEP)


func _refresh_growth() -> void:
	if player == null or character == null or character.id != "avide":
		return
	var target := 1.0 + CombatSystem.BITE_SIZE * float(combat.bites())
	if combat.feasting():
		target *= CombatSystem.FEAST_SIZE
	player.create_tween().tween_method(player.set_growth, player.growth, target, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_bites_changed(_count: int, gained: bool) -> void:
	_refresh_growth()
	if player == null:
		return
	var cell := player.mover.nearest_cell()
	if gained:
		_front_burst(cell, 1.1, 0.4, "avide_eclat")
		_bile_splash(cell, 8)
	else:
		_dragon_smoke_puff(cell, 6)


## La langue s'étire du ventre au bout de sa course, le long du couloir, puis se rétracte.
func _lash_tongue(path: Array, duration: float) -> void:
	if player == null or path.size() < 2:
		return
	var points := PackedVector2Array([player.position + Vector2(0.0, -TILE_SIZE * TONGUE_LIFT)])
	for k in range(1, path.size()):
		points.append(maze_renderer.cell_to_world(path[k]) + Vector2(0.0, -TILE_SIZE * 0.5))
	var tongue := Line2D.new()
	entities.add_child(tongue)
	# Elle dessine en positions du monde : le redressement de `WorldStage` la ferait glisser.
	tongue.scale = Vector2.ONE
	tongue.position = Vector2.ZERO
	tongue.z_index = 12
	tongue.texture = load(AVIDE_PIECES + "langue.png")
	tongue.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	tongue.width = TILE_SIZE * TONGUE_WIDTH * player.growth
	tongue.joint_mode = Line2D.LINE_JOINT_ROUND
	var reach := func(t: float) -> void:
		if is_instance_valid(tongue):
			tongue.points = _polyline_part(points, t)
	var out := clampf(duration, 0.1, 0.3)
	var tween := tongue.create_tween()
	tween.tween_method(reach, 0.05, 1.0, out).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	var end_cell: Vector2i = path[path.size() - 1]
	tween.tween_callback(func() -> void:
		_front_burst(end_cell, 0.95, 0.35, "avide_choc")
		_bile_splash(end_cell, 6))
	tween.tween_interval(0.06)
	tween.tween_method(reach, 1.0, 0.0, 0.14).set_ease(Tween.EASE_IN)
	tween.tween_callback(tongue.queue_free)


## Le début d'une ligne brisée, sur une part `t` de sa longueur.
func _polyline_part(points: PackedVector2Array, t: float) -> PackedVector2Array:
	var total := 0.0
	for k in range(1, points.size()):
		total += points[k - 1].distance_to(points[k])
	var left := total * clampf(t, 0.0, 1.0)
	var out := PackedVector2Array([points[0]])
	for k in range(1, points.size()):
		var piece := points[k - 1].distance_to(points[k])
		if left >= piece:
			out.append(points[k])
			left -= piece
			continue
		out.append(points[k - 1].lerp(points[k], left / maxf(piece, 0.001)))
		break
	if out.size() < 2:
		out.append(points[0] + Vector2(0.5, 0.0))
	return out


func _on_gulf_opened(cell: Vector2i, radius: float, seconds: float) -> void:
	_on_gulf_gone()
	var at := maze_renderer.cell_to_world(cell)
	_gulf_mouth = _avide_sprite("gouffre.png", radius * 2.0 * GULF_FILL, at, 7)
	var full := _gulf_mouth.scale
	_gulf_mouth.scale = Vector2.ZERO
	var tween := _gulf_mouth.create_tween().set_parallel()
	tween.tween_property(_gulf_mouth, "scale", full, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_gulf_mouth, "rotation", 0.8, seconds)
	_spawn_painted_burst(cell, radius, seconds + 0.3, "avide_fissure")
	_spawn_wave(cell, radius * 2.5, 0.5, "avide_onde")
	_bile_splash(cell, 14)
	_shake(0.3, 0.6)


func _on_gulf_gone() -> void:
	if _gulf_mouth != null and is_instance_valid(_gulf_mouth):
		_gulf_mouth.queue_free()
	_gulf_mouth = null


func _on_gulf_closed(cell: Vector2i, cells: Array) -> void:
	if _gulf_mouth != null and is_instance_valid(_gulf_mouth):
		var mouth := _gulf_mouth
		var close := mouth.create_tween()
		close.tween_property(mouth, "scale", mouth.scale * 1.15, 0.06)
		close.tween_property(mouth, "scale", Vector2.ZERO, 0.12).set_ease(Tween.EASE_IN)
		close.tween_callback(mouth.queue_free)
	_gulf_mouth = null
	_front_burst(cell, 1.8, 0.5, "avide_explosion")
	for target: Vector2i in cells:
		_front_burst(target, 1.0, 0.4, "avide_eclat")
		_bile_splash(target, 10)
	_spawn_slow_motion(0.08, 0.3)
	_shake(0.4, 0.85)


## La gueule du ventre s'ouvre sur la proie et se referme ; avalée, sa vie remonte jusqu'à lui.
func _on_devoured(_index: int, cell: Vector2i, swallowed: bool) -> void:
	var at := maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.55)
	var jaw := _avide_sprite("gueule.png", JAW_TILES, at, 12)
	var stand := CameraRules.stand_scale()
	var full := jaw.scale * Vector2(1.0, stand)
	jaw.scale = full * 0.4
	var tween := jaw.create_tween()
	tween.tween_property(jaw, "scale", full, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(jaw, "scale", Vector2(full.x * 1.1, full.y * 0.1), 0.1).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		_front_burst(cell, 1.3, 0.45, "avide_explosion")
		_bile_splash(cell, 14)
		_spawn_slow_motion(0.08, 0.25)
		_shake(0.28, 0.8))
	tween.tween_property(jaw, "modulate:a", 0.0, 0.12)
	tween.tween_callback(jaw.queue_free)
	if swallowed and player != null:
		var home := player.mover.nearest_cell()
		get_tree().create_timer(0.26).timeout.connect(func() -> void:
			_bile_streak(cell, home, 0.35)
			_front_burst(home, 1.1, 0.45, "avide_eclat"))


## Une boule par bouchée, lancée en cloche depuis son ventre, et chacune éclate à son tour.
func _on_regurgitated(_from: Vector2i, cells: Array) -> void:
	if player == null:
		return
	var start := player.position + Vector2(0.0, -TILE_SIZE * TONGUE_LIFT)
	for k in cells.size():
		var cell: Vector2i = cells[k]
		var finish := maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.3)
		var ball := _avide_sprite("bile.png", BILE_BALL_TILES, start, 13)
		var flight := 0.32 + 0.06 * float(k)
		var arc := func(t: float) -> void:
			if is_instance_valid(ball):
				ball.position = start.lerp(finish, t) + Vector2(0.0, -sin(t * PI) * TILE_SIZE * 1.4)
		var tween := ball.create_tween()
		tween.tween_method(arc, 0.0, 1.0, flight)
		tween.tween_callback(func() -> void:
			_front_burst(cell, 1.5, 0.5, "avide_explosion")
			_spawn_painted_burst(cell, 1.3, 1.2, "avide_fissure")
			_bile_splash(cell, 12)
			_shake(0.14, 0.4))
		tween.tween_callback(ball.queue_free)
	_dragon_smoke_puff(player.mover.nearest_cell(), 10)
	_shake(0.2, 0.5)


func _on_leap_landed(cell: Vector2i, radius: float) -> void:
	_front_burst(cell, radius + 0.8, 0.5, "avide_nova")
	_spawn_painted_burst(cell, radius + 0.6, 1.1, "avide_fissure")
	_spawn_wave(cell, radius * 3.0, 0.45, "avide_onde")
	_bile_splash(cell, 16)
	_shake(0.35, 0.8)


func _on_feast_started(seconds: float) -> void:
	if player == null:
		return
	_on_feast_ended()
	_refresh_growth()
	var cell := player.mover.nearest_cell()
	_feast_veil = _spawn_painted_burst(cell, 3.0, seconds + 0.6, "avide_voile")
	_feast_veil.span_tiles(TILE_SIZE, 40.0)
	_feast_veil.z_index = 3
	_feast_veil.position = player.position
	# DERRIÈRE lui (z 9, le mage est à 10) : le géant se dresse devant sa propre gueule, au lieu
	# d'être caché par elle.
	var at := player.position + Vector2(0.0, -TILE_SIZE * 1.9)
	_feast_mouth = _avide_sprite("gueule.png", FEAST_MOUTH_TILES, at, 9)
	_feast_mouth.modulate = Color(1.0, 1.0, 1.0, 0.88)
	var full := _feast_mouth.scale * Vector2(1.0, CameraRules.stand_scale())
	_feast_mouth.scale = Vector2(full.x, 0.0)
	_feast_mouth.create_tween().tween_property(_feast_mouth, "scale", full, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_feast_mouth.set_meta("full", full)
	_front_burst(cell, 2.0, 0.6, "avide_explosion")
	_spawn_wave(cell, 12.0, 0.5, "avide_onde")
	_shake(0.7, 1.0)


func _on_feast_bite(_index: int, cell: Vector2i, killed: bool) -> void:
	_front_burst(cell, 1.2, 0.4, "avide_eclat")
	_bile_splash(cell, 10)
	if _feast_mouth != null and is_instance_valid(_feast_mouth) and player != null:
		var mouth := _feast_mouth
		var full: Vector2 = mouth.get_meta("full")
		var chomp := mouth.create_tween()
		chomp.tween_property(mouth, "scale", Vector2(full.x * 1.08, full.y * 0.45), 0.08)
		chomp.tween_property(mouth, "scale", full, 0.16).set_trans(Tween.TRANS_BACK)
		var streak := BladeDash.new()
		entities.add_child(streak)
		streak.setup(maze_renderer.cell_to_world(cell), mouth.position, TILE_SIZE, 0.3)
		streak.tint(BILE_PALE, BILE, BILE_DEEP)
	_shake(0.22 if killed else 0.14, 0.6)


func _on_feast_ended() -> void:
	if _feast_mouth != null and is_instance_valid(_feast_mouth):
		var mouth := _feast_mouth
		var close := mouth.create_tween()
		close.tween_property(mouth, "scale", Vector2(mouth.scale.x, 0.0), 0.2).set_ease(Tween.EASE_IN)
		close.tween_callback(mouth.queue_free)
	_feast_mouth = null
	if _feast_veil != null and is_instance_valid(_feast_veil):
		_feast_veil.queue_free()
	_feast_veil = null
	if player != null and combat != null and not combat.feasting():
		_refresh_growth()
		_spawn_wave(player.mover.nearest_cell(), 14.0, WAVE_TIME, "avide_onde")
		_dragon_smoke_puff(player.mover.nearest_cell(), 18)


# --- Le Chevalier Écarlate ----------------------------------------------------------

const GUARD_RADIUS := 1.25
const PARRY_RADIUS := 2.6
const PARRY_TIME := 0.5
const SHEATHE_RADIUS := 1.6
## L'éclat grandit avec les entailles : de 1,1 case pour une, à 2,1 pour cinq.
const CUT_BURST_BASE := 0.85
const CUT_BURST_STEP := 0.25
const CUT_BURST_TIME := 0.62
const DASH_CUT_TIME := 0.36
## L'image se fige un instant à l'éclat final, comme le souffle retenu du coup de sabre.
const SHEATHE_SLOW := 0.22
const SHEATHE_SLOW_SCALE := 0.12

var _guard_ring: PaintedBurst = null
var _night_layer: CanvasLayer = null


func _on_enemy_cuts(index: int, count: int) -> void:
	if _structure_at(index) == null and index < enemies.size():
		enemies[index].set_cuts(count)


func _on_dash_cut(from: Vector2i, to: Vector2i) -> void:
	var streak := BladeDash.new()
	entities.add_child(streak)
	streak.setup(maze_renderer.cell_to_world(from), maze_renderer.cell_to_world(to), TILE_SIZE, DASH_CUT_TIME)
	_shake(0.12, 0.4)


func _on_guard_raised(seconds: float) -> void:
	_on_guard_down()
	var ring := PaintedBurst.new()
	player.add_child(ring)
	ring.setup(TILE_SIZE, GUARD_RADIUS, seconds, 0.3, "ecarlate_garde")
	ring.position = Vector2(0.0, -TILE_SIZE * 0.45)
	_guard_ring = ring


func _on_guard_down() -> void:
	if _guard_ring != null and is_instance_valid(_guard_ring):
		_guard_ring.queue_free()
	_guard_ring = null


func _on_guard_parried(cell: Vector2i) -> void:
	_on_guard_down()
	_front_burst(cell, PARRY_RADIUS, PARRY_TIME, "ecarlate_parade")
	_spawn_slow_motion(0.1, 0.15)
	_shake(0.26, 0.7)


func _on_sheathe_begun(cell: Vector2i, _cells: Array, seconds: float, final: bool) -> void:
	_front_burst(cell, SHEATHE_RADIUS, seconds, "ecarlate_fourreau")
	if final:
		_cover_with_night(seconds)
		_shake(0.2, 0.5)


func _on_cut_burst(cell: Vector2i, count: int) -> void:
	var burst := _front_burst(cell, CUT_BURST_BASE + CUT_BURST_STEP * float(count), CUT_BURST_TIME, "ecarlate_eclat")
	(burst.get_child(0) as Sprite2D).material.set_shader_parameter("count", float(count))


func _on_sheathe_ended(final: bool) -> void:
	if final:
		_lift_night()
		_spawn_wave_blade()
		_spawn_slow_motion(SHEATHE_SLOW, SHEATHE_SLOW_SCALE)
		_shake(0.6, 1.0)
	else:
		_spawn_slow_motion(0.08, 0.2)
		_shake(0.3, 0.7)


func _spawn_wave_blade() -> void:
	if player != null:
		_front_burst(player.mover.nearest_cell(), 3.0, PARRY_TIME, "ecarlate_parade").span_tiles(TILE_SIZE, WAVE_TILES)


func _spawn_slow_motion(seconds: float, factor: float) -> void:
	Engine.time_scale = factor
	get_tree().create_timer(seconds, true, false, true).timeout.connect(
		func() -> void: Engine.time_scale = 1.0)


## ⚠️ Sur la fenêtre elle-même : un CanvasLayer enfant du `Level` dessinerait dans la texture du sol.
func _cover_with_night(seconds: float) -> void:
	_lift_night()
	var view := get_tree().root.get_visible_rect().size
	var veil := ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shaded := ShaderMaterial.new()
	shaded.shader = load("res://assets/shaders/ecarlate_nuit.gdshader")
	shaded.set_shader_parameter("aspect", view.x / maxf(view.y, 1.0))
	shaded.set_shader_parameter("seed", 0.37)
	veil.material = shaded
	_night_layer = CanvasLayer.new()
	_night_layer.layer = 1
	_night_layer.add_child(veil)
	get_tree().root.add_child(_night_layer)
	var run := create_tween()
	run.tween_method(func(value: float) -> void: shaded.set_shader_parameter("progress", value),
		0.0, 1.0, seconds)


func _lift_night() -> void:
	if _night_layer != null and is_instance_valid(_night_layer):
		_night_layer.queue_free()
	_night_layer = null


func _exit_tree() -> void:
	_lift_night()


# --- Le Roi de Braise ---------------------------------------------------------------

const BRAISE_PIECES := "res://assets/characters/braise/pieces/"
const FIST_TILES := 0.82
const CHEST_BITE_RADIUS := 1.25
const RECALL_RADIUS := 2.6
const RECALL_TIME := 0.62
const HUNTERS_TIME := 0.5
const CHOC_TIME := 0.32
## L'explosion du leurre et des cages reste sous ce rayon : plus grande, elle cachait la mêlée.
const BLAST_TIME := 0.85
const CRUSH_BLAST_RADIUS := 1.55
const WAVE_TILES := 16.0
const WAVE_TIME := 0.8
const VEIL_TILES := 40.0
## Le ralenti du dernier instant des cages, en secondes réelles.
const CRUSH_SLOW := 0.16
const CRUSH_SLOW_SCALE := 0.2

var _king_armor: KingArmor = null
var _king_decoy: KingDecoy = null
var _king_cages: Array[KingCage] = []


func _update_king_armor() -> void:
	if character == null or character.id != "braise" or player == null:
		return
	if _king_armor == null or not is_instance_valid(_king_armor) or _king_armor.get_parent() != entities:
		_king_armor = KingArmor.new()
		entities.add_child(_king_armor)
		_king_armor.z_index = 11
	_king_armor.show_state(combat.pieces(), player, maze_renderer.cell_to_world(Vector2i.ZERO), TILE_SIZE)


## Le poing est un dessin posé sur la traînée peinte : il en suit le trajet et la rotation.
func _arm_fist(orb: MagicOrb, path: String) -> void:
	var texture: Texture2D = load(path)
	var fist := Sprite2D.new()
	fist.texture = texture
	var quad := orb.sprite.scale / MagicOrb.PAINTED_BIRTH_SCALE
	var unit := FIST_TILES * float(TILE_SIZE) / float(texture.get_height())
	fist.scale = Vector2(unit / quad.x, unit / quad.y)
	# Dessiné poing vers le haut à droite : ce quart de tour le met dans l'axe du vol.
	fist.rotation = PI / 4.0
	fist.position = Vector2(0.28, 0.0)
	fist.material = KingArmor.metal_material(0.25)
	orb.sprite.add_child(fist)


func _shake(seconds: float, power: float) -> void:
	_shake_total = seconds
	_shake_left = seconds
	_shake_time = 0.0
	_shake_power = power


func _front_burst(cell: Vector2i, radius: float, time: float, key: String) -> PaintedBurst:
	var burst := _spawn_painted_burst(cell, radius, time, key)
	burst.z_index = 11
	return burst


func _on_piece_ejected(cell: Vector2i) -> void:
	_front_burst(cell, 1.6, 0.5, "braise_explosion")
	_spawn_painted_burst(cell, 1.8, 1.0, "braise_fissure")
	_shake(0.28, 0.5)


func _on_piece_struck(cell: Vector2i) -> void:
	_front_burst(cell, 0.95, CHOC_TIME, "braise_choc")
	_shake(0.08, 0.2)


func _on_piece_recalled(cell: Vector2i) -> void:
	_front_burst(cell, 0.95, CHOC_TIME, "braise_choc")


## La dernière pièce rentre : tout l'écran le sent.
func _on_piece_returned(recalled: bool) -> void:
	if not recalled or player == null:
		return
	var cell := player.mover.nearest_cell()
	_front_burst(cell, 1.1, CHOC_TIME, "braise_choc")
	if combat.plates_left() == CombatSystem.PIECES_MAX:
		_spawn_painted_burst(cell, 2.4, 1.1, "braise_fissure")
		_spawn_wave(cell, WAVE_TILES * 0.5, WAVE_TIME * 0.7)
		_shake(0.3, 0.6)


func _spawn_wave(cell: Vector2i, tiles: float, time: float, key: String = "braise_onde") -> void:
	_front_burst(cell, 3.0, time, key).span_tiles(TILE_SIZE, tiles)


func _on_hunters_cast(cell: Vector2i) -> void:
	_front_burst(cell, 1.4, HUNTERS_TIME, "braise_rappel")
	_shake(0.12, 0.3)


func _on_chest_posed(cell: Vector2i) -> void:
	_spawn_painted_burst(cell, 1.9, 1.2, "braise_fissure")
	_spawn_wave(cell, 4.0, 0.45)
	_shake(0.18, 0.45)


func _on_chest_bit(cell: Vector2i, seconds: float) -> void:
	if seconds > 0.0:
		_front_burst(cell, CHEST_BITE_RADIUS, seconds, "braise_gueule")
	_front_burst(cell, 1.3, 0.45, "braise_explosion")
	_spawn_painted_burst(cell, 1.9, 1.3, "braise_fissure")
	_shake(0.24, 0.6)


func _on_chest_spat(cell: Vector2i) -> void:
	_front_burst(cell, 1.3, 0.45, "braise_choc")


func _on_recall_cast(cell: Vector2i) -> void:
	_front_burst(cell, RECALL_RADIUS, RECALL_TIME, "braise_rappel")
	_shake(0.3, 0.4)


func _on_decoy_posed(cell: Vector2i, seconds: float) -> void:
	_on_decoy_gone()
	if character.id == "croupier":
		_pose_card_decoy(cell, seconds)
		return
	_spawn_painted_burst(cell, 1.6, seconds, "braise_sceau")
	_king_decoy = KingDecoy.new()
	entities.add_child(_king_decoy)
	_king_decoy.position = maze_renderer.cell_to_world(cell)
	_king_decoy.setup(player, seconds)


func _on_decoy_gone() -> void:
	if _card_decoy != null and is_instance_valid(_card_decoy):
		_card_decoy.queue_free()
	_card_decoy = null
	if _king_decoy != null and is_instance_valid(_king_decoy):
		_king_decoy.queue_free()
	_king_decoy = null


func _on_decoy_blew(cell: Vector2i, radius: float) -> void:
	_on_decoy_gone()
	if character.id == "croupier":
		_front_burst(cell, 1.1, 0.45, "croupier_eclat")
		_card_spray(cell, 10)
		return
	_front_burst(cell, radius, BLAST_TIME, "braise_explosion")
	_spawn_painted_burst(cell, radius + 0.4, 1.4, "braise_fissure")
	_spawn_wave(cell, radius * 3.0, 0.5)
	KingCage.scatter(entities, maze_renderer.cell_to_world(cell), TILE_SIZE)
	_shake(0.4, 0.8)


func _on_decoy_field(field: PackedInt32Array) -> void:
	for enemy in enemies:
		if enemy.ai != null and not enemy.is_boss():
			enemy.ai.lure_field = field


func _on_cages_cast(cell: Vector2i, indices: Array, seconds: float) -> void:
	var veil := _spawn_painted_burst(cell, 3.0, seconds + 0.1, "braise_voile")
	veil.span_tiles(TILE_SIZE, VEIL_TILES)
	# Sous les acteurs et les cages, sur le sol : seul ce qui brûle reste éclairé.
	veil.z_index = 3
	veil.position = player.position
	_spawn_wave(cell, WAVE_TILES, WAVE_TIME)
	_spawn_painted_burst(cell, 2.6, 1.5, "braise_fissure")
	_front_burst(cell, 1.5, 0.45, "braise_explosion")
	_shake(0.45, 0.9)
	_king_cages.clear()
	var near: Array = indices.duplicate()
	var from := player.position
	near.sort_custom(func(a: int, b: int) -> bool:
		return (enemies[a] as Enemy).position.distance_squared_to(from) \
			< (enemies[b] as Enemy).position.distance_squared_to(from))
	var rank := 0
	for index: int in near:
		if index >= enemies.size():
			continue
		var cage := KingCage.new()
		entities.add_child(cage)
		cage.setup(enemies[index], TILE_SIZE, seconds, KingCage.FIRST_FALL + float(rank) * KingCage.FALL_STEP)
		cage.landed.connect(_on_cage_landed)
		_king_cages.append(cage)
		rank += 1


func _on_cage_landed(at: Vector2) -> void:
	var cell := Vector2i(((at - maze_renderer.cell_to_world(Vector2i.ZERO)) / float(TILE_SIZE)).round())
	_front_burst(cell, 1.1, CHOC_TIME, "braise_choc")
	_spawn_painted_burst(cell, 1.5, 1.0, "braise_fissure")
	_shake(0.16, 0.55)


func _on_cages_crushed(cells: Array) -> void:
	for cage in _king_cages:
		if is_instance_valid(cage):
			cage.crush()
	_king_cages.clear()
	for cell: Vector2i in cells:
		_front_burst(cell, CRUSH_BLAST_RADIUS, BLAST_TIME, "braise_explosion")
	if player != null:
		_spawn_wave(player.mover.nearest_cell(), WAVE_TILES * 1.3, WAVE_TIME)
	_shake(0.6, 1.0)
	# L'instant se dilate une fraction de seconde : ce sont les règles qui attendent aussi, mais
	# ce temps est trop court pour que l'équilibrage le sente.
	Engine.time_scale = CRUSH_SLOW_SCALE
	get_tree().create_timer(CRUSH_SLOW, true, false, true).timeout.connect(
		func() -> void: Engine.time_scale = 1.0)


# --- L'Archange d'Acier -------------------------------------------------------------

## Il grandit d'un quart et rougeoie tant que dure l'armure en fusion.
const MOLTEN_GROWTH := 1.25
const MOLTEN_TINT := Color(1.3, 0.82, 0.55)

var _plate_pips: PlatePips = null
var _plates_shown := -1
var _size_before_molten := Vector2.ONE


func _on_plates_changed(count: int) -> void:
	if character == null or player == null or (character.id != "acier" and not (character.id == "ael" and character.hero_form >= 2)):
		return
	# Le niveau se reconstruit au démarrage : l'ancien mage n'est pas encore libéré à cet instant,
	# et ses plaques sembleraient toujours valides.
	if _plate_pips == null or not is_instance_valid(_plate_pips) or _plate_pips.get_parent() != player:
		_plates_shown = -1
		_plate_pips = PlatePips.new()
		player.add_child(_plate_pips)
		_plate_pips.setup(TILE_SIZE, CombatSystem.PLATE_MAX)
	if character.id == "ael":
		_plate_pips.setup(TILE_SIZE, 2 if character.hero_form == 3 else 1)
		_plate_pips.set_count(count)
		_plates_shown = count
		return
	_plate_pips.set_count(count)
	if _plates_shown >= 0 and count != _plates_shown:
		var cell := player.mover.nearest_cell()
		if count < _plates_shown:
			_spawn_painted_burst(cell, 1.1, 0.35, "acier_impact").z_index = 11
		else:
			_spawn_painted_burst(cell, 1.1, 0.4, "acier_ring").z_index = 11
	_plates_shown = count


## Le coup au sol à ses pieds, et le sol qui se fend derrière l'onde jusqu'à sa cible.
func _spawn_hammer_strike(path: Array, points: PackedVector2Array, duration: float) -> void:
	_spawn_painted_burst(path[0], 1.3, 0.35, "acier_impact").z_index = 11
	var links := []
	for i in points.size() - 1:
		links.append({"from": points[i], "to": points[i + 1], "steps": i + 1})
	var cracks := SteelCracks.new()
	entities.add_child(cracks)
	cracks.setup(links, TILE_SIZE, float(points.size() - 1) / maxf(duration, 0.01))


func _on_blades_thrown(from: Vector2i, directions: Array, reach: int) -> void:
	if character.id == CharacterCatalog.AEL:
		var gems := GemVolley.new()
		gems.colour = _ael_colour()
		entities.add_child(gems)
		gems.setup(maze_renderer.cell_to_world(from), directions, float(reach * TILE_SIZE), TILE_SIZE, player)
		return
	if character.id == "ciel":
		_throw_feathers(from, directions, reach)
		return
	var volley := SteelBlades.new()
	entities.add_child(volley)
	volley.setup(maze_renderer.cell_to_world(from), directions, float(reach * TILE_SIZE), TILE_SIZE, player)


func _on_blade_cut(cell: Vector2i) -> void:
	if character.id == CharacterCatalog.AEL:
		_riposte(cell)
		return
	if character.id == "ciel":
		_front_burst(cell, 0.85, 0.32, "ciel_entaille")
		return
	_spawn_painted_burst(cell, 0.8, 0.28, "acier_impact").z_index = 11


func _on_anvil_struck(cell: Vector2i, links: Array) -> void:
	var drawn := []
	for link: Dictionary in links:
		drawn.append({"from": maze_renderer.cell_to_world(link["from"]),
			"to": maze_renderer.cell_to_world(link["to"]), "steps": link["steps"]})
	var cracks := SteelCracks.new()
	entities.add_child(cracks)
	cracks.setup(drawn, TILE_SIZE)
	_spawn_painted_burst(cell, 1.05, 0.6, "acier_anvil").z_index = 11


func _on_molten_started(duration: float) -> void:
	_spawn_on_player(duration, "acier_molten", 1.35)
	_spawn_painted_burst(player.mover.nearest_cell(), 1.6, 0.6, "acier_ring").z_index = 11
	_size_before_molten = player.scale
	player.set_tint(MOLTEN_TINT)
	create_tween().tween_property(player, "scale", _size_before_molten * MOLTEN_GROWTH, 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_molten_ended() -> void:
	player.set_tint(Color.WHITE)
	create_tween().tween_property(player, "scale", _size_before_molten, 0.6)


## Un effet peint qui vit attaché au mage et le suit dans ses déplacements.
func _spawn_on_player(duration: float, key: String, radius: float) -> void:
	var worn := PaintedBurst.new()
	player.add_child(worn)
	worn.setup(TILE_SIZE, radius, duration, 0.0, key)
	worn.position = Vector2(0.0, -TILE_SIZE * 0.55)
	worn.z_index = 2


# --- Le Chérubin -----------------------------------------------------------------

const GARDEN_SWORD_SIZE := Vector2(1.4, 3.2)
const GARDEN_NIGHT_TILES := 40.0
const EYE_HEIGHT := 1.45

var _eye_marks := {}                   # index d'ennemi -> PaintedBurst de l'œil ouvert
var _garden_nodes: Array[Node2D] = []


func _throw_sacred_flame(path: Array, duration: float) -> void:
	var points := PackedVector2Array()
	for cell in path:
		points.append(maze_renderer.cell_to_world(cell))
	var jet := SacredJet.new()
	entities.add_child(jet)
	jet.setup(points, duration, TILE_SIZE)


func _roll_wheel(path: Array, duration: float) -> void:
	var points := PackedVector2Array()
	points.append(maze_renderer.cell_to_world(player.mover.nearest_cell()))
	for cell in path:
		points.append(maze_renderer.cell_to_world(cell))
	var wheel := EzekielWheel.new()
	entities.add_child(wheel)
	wheel.setup(points, duration, TILE_SIZE, float(path.size()) * 0.13)
	_front_burst(player.mover.nearest_cell(), 1.0, 0.3, "cherubin_rejet")
	_shake(0.1, 0.3)


## L'œil reste ouvert au-dessus de l'ennemi tant que le CombatSystem le garde ; il se ferme ici.
func _on_enemy_eyed(index: int, open: bool) -> void:
	if _eye_marks.has(index):
		var old: Node = _eye_marks[index]
		if is_instance_valid(old):
			old.queue_free()
		_eye_marks.erase(index)
	if not open or _structure_at(index) != null or index >= enemies.size():
		return
	var eye := PaintedBurst.new()
	enemies[index].add_child(eye)
	eye.setup(TILE_SIZE, 0.9, 600.0, float(index) * 0.29, "cherubin_oeil")
	(eye.get_child(0) as Sprite2D).scale = Vector2(0.62, 0.42) * TILE_SIZE
	eye.position = Vector2(0.0, -TILE_SIZE * EYE_HEIGHT)
	eye.z_index = 3
	_eye_marks[index] = eye


func _on_eye_burst(cell: Vector2i) -> void:
	var burst := _spawn_painted_burst(cell, 1.0, 0.7, "cherubin_embrasement")
	var shaft := burst.get_child(0) as Sprite2D
	shaft.scale = Vector2(1.5, 2.2) * TILE_SIZE
	shaft.position = Vector2(0.0, -TILE_SIZE * 0.85)
	burst.z_index = 12
	_shake(0.1, 0.3)


func _on_whirl_started(duration: float, radius: float) -> void:
	if player == null:
		return
	var whirl := PaintedBurst.new()
	player.add_child(whirl)
	whirl.setup(TILE_SIZE, radius, duration, 0.0, "cherubin_tournoyant")
	whirl.set_shader_seconds(duration)
	whirl.position = Vector2(0.0, -TILE_SIZE * 0.4)
	whirl.z_index = 2
	_front_burst(player.mover.nearest_cell(), 1.2, 0.35, "cherubin_rejet")


func _on_whirl_cut(cell: Vector2i) -> void:
	_front_burst(cell, 0.9, 0.3, "cherubin_coupe")


func _on_veil_repelled(cell: Vector2i) -> void:
	_front_burst(cell, 1.0, 0.4, "cherubin_rejet")
	_shake(0.08, 0.25)


## L'éclair : une ligne de flammes reste au sol sur toute la course.
func _lightning_trail(from: Vector2i, to: Vector2i) -> void:
	var step := Vector2(to - from).normalized()
	var length := int(Vector2(to - from).length())
	for i in range(0, length + 1):
		var cell := from + Vector2i(roundi(step.x * i), roundi(step.y * i))
		var flame := _spawn_painted_burst(cell, 0.9, 0.9 + float(i) * 0.05, "cherubin_trainee")
		flame.z_index = 9
	_shake(0.14, 0.4)


## Le Jardin gardé : le décor s'assombrit, l'épée tombe et se plante, et le mur de flammes jaillit.
func _on_garden_planted(cell: Vector2i, radius: float, seconds: float) -> void:
	_on_garden_ended(cell)
	var night := _spawn_painted_burst(cell, 3.0, 1.6, "cherubin_nuit")
	night.span_tiles(TILE_SIZE, GARDEN_NIGHT_TILES)
	var ring := _spawn_painted_burst(cell, radius, seconds, "cherubin_jardin")
	ring.span_tiles(TILE_SIZE, radius)
	ring.z_index = 8
	var sword := _spawn_painted_burst(cell, 1.0, seconds, "cherubin_epee")
	var shaft := sword.get_child(0) as Sprite2D
	shaft.scale = GARDEN_SWORD_SIZE * TILE_SIZE
	shaft.position = Vector2(0.0, -(0.97 - 0.5) * GARDEN_SWORD_SIZE.y * TILE_SIZE)
	sword.z_index = 10
	_garden_nodes = [ring, sword]
	_front_burst(cell, 1.3, 0.6, "cherubin_choc")
	_spawn_wave(cell, radius, 0.5, "cherubin_rejet")
	_shake(0.45, 0.9)
	_spawn_slow_motion(0.12, 0.3)


func _on_garden_repelled(cell: Vector2i) -> void:
	_front_burst(cell, 1.0, 0.4, "cherubin_rejet")


func _on_garden_ended(_cell: Vector2i) -> void:
	_garden_nodes.clear()


# --- L'Archange du Ciel -------------------------------------------------------------

const SKY_PALE := Color("#f4fff8")
const SKY_GOLD := Color("#f2c14e")
## Ce qui tombe du ciel est dessiné dans un quad haut, (largeur, hauteur) en cases. Le sol y est
## à `SKY_GROUND` de la hauteur : c'est là que la pointe touche la case visée.
const LANCE_SIZE := Vector2(1.5, 5.0)
const SWORD_SIZE := Vector2(1.5, 5.5)
const PILLAR_SIZE := Vector2(3.6, 7.5)
const PILLAR_TIME := 1.0
## La part de `PILLAR_TIME` que met la colonne à toucher le sol (`ciel_colonne`).
const PILLAR_SLAM := 0.12
const SKY_GROUND := 0.97
const BELL_WAVE_TIME := 0.9
const JUDGEMENT_VEIL_TILES := 40.0
## L'Envol : de combien de cases le dessin s'élève, et de combien il grandit.
const FLIGHT_LIFT := 0.55
const FLIGHT_GROWTH := 1.12
const FLIGHT_RISE := 0.3
const FLIGHT_DROP := 0.2

var _flight_feathers: CPUParticles2D = null


## La case où il compte pour les ennemis et les sorts. En vol au-dessus d'une haie, c'est la case
## de sol la plus proche : depuis un mur, aucun champ de distances ne mène nulle part.
func _grounded(cell: Vector2i) -> Vector2i:
	if combat == null or not combat.flying() or grid.is_floor_v(cell):
		return cell
	return _nearest_floor(cell)


func _nearest_floor(cell: Vector2i) -> Vector2i:
	if grid.is_floor_v(cell):
		return cell
	for ring in range(1, 8):
		var best := Vector2i(-1, -1)
		var best_gap := INF
		for dx in range(-ring, ring + 1):
			for dy in range(-ring, ring + 1):
				var side := cell + Vector2i(dx, dy)
				var gap := Vector2(dx, dy).length()
				if gap < best_gap and grid.is_floor_v(side):
					best = side
					best_gap = gap
		if best.x >= 0:
			return best
	return cell


## Un coup qui tombe du ciel, debout dans les deux vues : sa pointe touche la case à la fin.
func _sky_drop(cell: Vector2i, key: String, size: Vector2, seconds: float) -> PaintedBurst:
	var drop := _spawn_painted_burst(cell, 1.0, seconds, key)
	var shaft := drop.get_child(0) as Sprite2D
	shaft.scale = size * TILE_SIZE
	shaft.position = Vector2(0.0, -(SKY_GROUND - 0.5) * size.y * TILE_SIZE)
	drop.z_index = 12
	return drop


## Ce qui se voit AVANT le coup : c'est ce qui dit au joueur que le coup a passé la haie.
func _sky_falls(ability: Ability, cell: Vector2i, duration: float) -> void:
	if ability.radius > 0.0:
		_spawn_painted_burst(cell, ability.radius, duration + PILLAR_TIME * 0.3, "ciel_cercle")
		var slam := create_tween()
		slam.tween_interval(maxf(0.0, duration - PILLAR_SLAM * PILLAR_TIME))
		slam.tween_callback(_sky_drop.bind(cell, "ciel_colonne", PILLAR_SIZE, PILLAR_TIME))
		return
	_spawn_painted_burst(cell, 0.75, duration + 0.12, "ciel_sceau")
	_sky_drop(cell, "ciel_lance", LANCE_SIZE, duration)


func _sky_strikes(ability: Ability, cell: Vector2i) -> void:
	if ability.radius > 0.0:
		_front_burst(cell, 1.7, 0.55, "ciel_choc")
		_sky_sparks(cell, 22)
		_shake(0.32, 0.75)
		_spawn_slow_motion(0.06, 0.3)
		return
	_front_burst(cell, 1.0, 0.42, "ciel_choc")
	_sky_sparks(cell, 6)


## Des éclats d'or qui jaillissent du point d'impact et retombent.
func _sky_sparks(cell: Vector2i, count: int) -> void:
	var sparks := CPUParticles2D.new()
	entities.add_child(sparks)
	sparks.position = maze_renderer.cell_to_world(cell) + Vector2(0.0, -TILE_SIZE * 0.3)
	sparks.z_index = 12
	sparks.amount = count
	sparks.lifetime = 0.6
	sparks.one_shot = true
	sparks.explosiveness = 1.0
	sparks.spread = 180.0
	sparks.gravity = Vector2(0.0, TILE_SIZE * 8.0)
	sparks.initial_velocity_min = TILE_SIZE * 2.0
	sparks.initial_velocity_max = TILE_SIZE * 5.0
	sparks.angular_velocity_min = -500.0
	sparks.angular_velocity_max = 500.0
	sparks.scale_amount_min = TILE_SIZE * 0.05
	sparks.scale_amount_max = TILE_SIZE * 0.11
	sparks.color = SKY_GOLD
	sparks.finished.connect(sparks.queue_free)
	sparks.emitting = true


func _throw_feathers(from: Vector2i, directions: Array, reach: int) -> void:
	var volley := SkyFeathers.new()
	entities.add_child(volley)
	volley.setup(maze_renderer.cell_to_world(from), directions, float(reach * TILE_SIZE), TILE_SIZE)


## La Cloche céleste : la cloche s'illumine à sa ceinture, puis trois anneaux passent les haies.
func _ring_the_bell(cell: Vector2i, ability: Ability) -> void:
	var bell := PaintedBurst.new()
	player.add_child(bell)
	bell.setup(TILE_SIZE, 0.9, 0.45, 0.0, "ciel_tinte")
	# À sa hanche, et derrière lui : la cloche sonne, elle ne le cache pas.
	bell.position = Vector2(TILE_SIZE * 0.35, -TILE_SIZE * 0.45)
	bell.scale = Vector2.ONE * 0.75
	bell.z_index = 1
	_spawn_wave(cell, ability.radius, BELL_WAVE_TIME, "ciel_onde")
	_shake(0.18, 0.35)


## Étourdis par la cloche, ou cloués par la colonne : deux marques différentes.
func _on_enemies_dazed(indices: Array, seconds: float, ability: Ability) -> void:
	if character == null or character.id != "ciel":
		return
	var pinned := ability.kind == Ability.Kind.PROJECTILE
	for index: int in indices:
		if _structure_at(index) != null or index >= enemies.size():
			continue
		var enemy: Enemy = enemies[index]
		var mark := PaintedBurst.new()
		enemy.add_child(mark)
		mark.setup(TILE_SIZE, 0.85, seconds, float(index) * 0.37, "ciel_clou" if pinned else "ciel_notes")
		if pinned:
			mark.z_index = -1
		else:
			mark.position = Vector2(0.0, -TILE_SIZE * 1.3)
			mark.z_index = 3


## Le Jugement : le ciel s'assombrit, six ailes s'ouvrent dans son dos, et l'écran encaisse.
func _open_six_wings(cell: Vector2i, ability: Ability) -> void:
	var total := ability.rain_delay + ability.rain_duration + ability.rain_fall + 0.4
	_spawn_painted_burst(cell, 3.0, total, "ciel_voile").span_tiles(TILE_SIZE, JUDGEMENT_VEIL_TILES)
	var wings := PaintedBurst.new()
	player.add_child(wings)
	wings.setup(TILE_SIZE, 2.4, total, 0.0, "ciel_ailes")
	wings.position = Vector2(0.0, -TILE_SIZE * 0.75)
	wings.z_index = -1
	_front_burst(cell, 1.4, 0.55, "ciel_choc")
	_sky_sparks(cell, 26)
	_shake(0.45, 0.9)
	_spawn_slow_motion(0.12, 0.3)


func _sword_incoming(cell: Vector2i, delay: float, ability: Ability) -> void:
	_spawn_painted_burst(cell, 0.95, delay + 0.1, "ciel_sceau_or")
	var fall := create_tween()
	fall.tween_interval(maxf(0.0, delay - ability.rain_fall))
	fall.tween_callback(_sky_drop.bind(cell, "ciel_epee", SWORD_SIZE, ability.rain_fall))


func _sword_landed(cell: Vector2i) -> void:
	_front_burst(cell, 1.35, 0.45, "ciel_choc")
	_sky_sparks(cell, 10)
	_shake(0.12, 0.4)


## L'Envol. Seul le dessin s'élève : l'ombre reste au sol et dit où il retombera.
func _on_flight_started(_duration: float, _ability: Ability) -> void:
	if player == null:
		return
	player.cancel_path()
	player.mover.phases = true
	# Ses ailes s'ouvrent DANS SON DOS, à hauteur d'épaules, et l'anneau du shader tombe au sol.
	var wings := PaintedBurst.new()
	player.add_child(wings)
	wings.setup(TILE_SIZE, 1.7, 0.55, 0.0, "ciel_envol")
	wings.position = Vector2(0.0, -TILE_SIZE * 0.9)
	wings.z_index = -1
	var rise := create_tween().set_parallel()
	rise.tween_property(player, "lift", FLIGHT_LIFT * TILE_SIZE, FLIGHT_RISE) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	rise.tween_property(player, "lift_scale", FLIGHT_GROWTH, FLIGHT_RISE)
	_flight_feathers = CPUParticles2D.new()
	player.add_child(_flight_feathers)
	_flight_feathers.position = Vector2(0.0, -TILE_SIZE * (FLIGHT_LIFT + 0.5))
	_flight_feathers.z_index = -1
	_flight_feathers.amount = 14
	_flight_feathers.lifetime = 0.9
	_flight_feathers.spread = 70.0
	_flight_feathers.direction = Vector2(0.0, 1.0)
	_flight_feathers.gravity = Vector2(0.0, TILE_SIZE * 1.5)
	_flight_feathers.initial_velocity_min = TILE_SIZE * 0.4
	_flight_feathers.initial_velocity_max = TILE_SIZE * 1.2
	_flight_feathers.angular_velocity_min = -200.0
	_flight_feathers.angular_velocity_max = 200.0
	_flight_feathers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_flight_feathers.emission_rect_extents = Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.2)
	_flight_feathers.scale_amount_min = TILE_SIZE * 0.05
	_flight_feathers.scale_amount_max = TILE_SIZE * 0.09
	_flight_feathers.color = SKY_PALE
	_flight_feathers.emitting = true


## Il retombe : posé sur la case de sol la plus proche s'il survolait une haie, AVANT que l'onde
## ne frappe (`CombatSystem._land` lit la case juste après ce signal).
func _on_flight_ended() -> void:
	if player == null:
		return
	var cell := player.mover.nearest_cell()
	var landing := _nearest_floor(cell)
	if landing != cell or not grid.is_floor_v(player.mover.cell) \
			or not grid.is_floor_v(player.mover.next_cell):
		player.mover.teleport_to(landing)
		player.snap_to_mover()
	player.mover.phases = false
	_refresh_context()
	_refresh_ai()
	var drop := create_tween().set_parallel()
	drop.tween_property(player, "lift", 0.0, FLIGHT_DROP).set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_IN)
	drop.tween_property(player, "lift_scale", 1.0, FLIGHT_DROP)
	if _flight_feathers != null and is_instance_valid(_flight_feathers):
		_flight_feathers.emitting = false
		var feathers := _flight_feathers
		get_tree().create_timer(1.0).timeout.connect(func() -> void:
			if is_instance_valid(feathers):
				feathers.queue_free())
	_flight_feathers = null


func _on_flight_landed(cell: Vector2i, ability: Ability) -> void:
	var ring := create_tween()
	ring.tween_interval(FLIGHT_DROP * 0.8)
	ring.tween_callback(func() -> void:
		_front_burst(cell, ability.radius + 0.3, 0.6, "ciel_atterrissage")
		_shake(0.22, 0.5))


# --- L'Ange de la Mort -------------------------------------------------------------

## L'éclipse couvre l'écran au-delà de ce que voit le joueur, comme l'Aube.
const HOUR_TILES := 16.0
const HOUR_TIME := 2.2
const SWEEP_TIME := 0.6
const SOUL_RETURN_TIME := 0.5

var _soul_orbit: SoulOrbit = null


func _spawn_sweep(ability: Ability, cell: Vector2i) -> void:
	var sweep := _spawn_painted_burst(cell, ability.radius, SWEEP_TIME, "mort_sweep")
	sweep.scale = Vector2.ONE
	sweep.rotation = Vector2(combat_context.player_facing).angle()
	sweep.z_index = 11


## La cible vire au noir sous l'entaille, part en plumes, et son âme file vers le mage.
func _on_enemy_sentenced(index: int) -> void:
	if index >= enemies.size():
		return
	var cell: Vector2i = enemies[index].current_cell()
	_spawn_painted_burst(cell, 1.5, 0.45, "mort_cut").z_index = 11
	_spawn_painted_burst(cell, 1.0, 0.5, "mort_feathers")
	var path := combat.trajectory(cell, player.mover.nearest_cell())
	if path.size() >= 2:
		_spawn_soul(path, SOUL_RETURN_TIME)


func _on_enemy_marked(index: int, duration: float) -> void:
	if _structure_at(index) == null and index < enemies.size():
		enemies[index].mark(duration)


func _on_souls_changed(count: int) -> void:
	if character == null or character.id != "mort" or player == null:
		return
	if _soul_orbit == null or not is_instance_valid(_soul_orbit):
		_soul_orbit = SoulOrbit.new()
		player.add_child(_soul_orbit)
		_soul_orbit.setup(TILE_SIZE)
	_soul_orbit.set_count(count)


func _on_soul_sent(path: Array, duration: float) -> void:
	_spawn_soul(path, duration)


func _spawn_soul(path: Array, duration: float) -> void:
	var points := PackedVector2Array()
	for cell: Vector2i in path:
		points.append(maze_renderer.cell_to_world(cell))
	var wisp := SoulWisp.new()
	entities.add_child(wisp)
	wisp.setup(points, TILE_SIZE, duration)


func _on_soul_struck(cell: Vector2i) -> void:
	_front_burst(cell, 1.6, 0.6, "mort_cut")
	_shake(0.1, 0.3)


func _on_last_hour_cast(cell: Vector2i) -> void:
	var hour := _spawn_painted_burst(cell, 1.0, HOUR_TIME, "mort_hour")
	hour.scale = Vector2.ONE
	hour.span_tiles(TILE_SIZE, HOUR_TILES)
	hour.z_index = 12


func _on_last_hour_struck(cell: Vector2i) -> void:
	_spawn_painted_burst(cell, 1.3, 0.45, "mort_cut").z_index = 13


# --- Le Mage de la Peste ---------------------------------------------------------

## Le rayon de l'onde de la Pandémie, en cases : elle doit balayer tout l'écran.
const PANDEMIC_TILES := 11.0
const THREAD_TIME := 0.5
const TRANSFUSION_TIME := 0.8


func _on_enemy_venomed(index: int, doses: int, duration: float) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	enemies[index].set_venom(doses, duration)


## Ses bottes fument tant que la Traînée dure.
func _on_trail_started(duration: float) -> void:
	var fumes := FxTextures.smoke_emitter(16, 0.6, TILE_SIZE * 0.4, -TILE_SIZE * 0.5)
	fumes.modulate = Element.color(Element.Kind.POISON)
	player.add_child(fumes)
	fumes.emitting = true
	get_tree().create_timer(duration).timeout.connect(fumes.queue_free)


## Une flaque est au sol : ni redressée par la vue 2,5D, ni au-dessus de qui marche dedans.
func _on_puddle_laid(cell: Vector2i, life: float) -> void:
	var puddle := _spawn_painted_burst(cell, 1.0, life, "peste_puddle")
	puddle.scale = Vector2.ONE
	puddle.z_index = 3


func _on_puddle_stepped(cell: Vector2i) -> void:
	_spawn_painted_burst(cell, 0.9, 0.28)


func _spawn_thread(from: Vector2i, to: Vector2i, duration: float) -> void:
	var path := combat.trajectory(from, to)
	if path.size() < 2:
		return
	var points := PackedVector2Array()
	for cell in path:
		points.append(maze_renderer.cell_to_world(cell))
	var thread := VenomThread.new()
	entities.add_child(thread)
	thread.setup(points, TILE_SIZE, duration)


func _on_contagion_spread(from: Vector2i, to: Vector2i) -> void:
	_spawn_painted_burst(from, 1.0, THREAD_TIME * 0.7)
	_spawn_thread(from, to, THREAD_TIME)
	get_tree().create_timer(THREAD_TIME * 0.62).timeout.connect(
		_spawn_painted_burst.bind(to, 0.9, 0.3))


## On voit d'où vient la vie qu'il reprend : les filets partent de chaque ennemi empoisonné.
func _on_transfused(cells: Array, _healed: int) -> void:
	var here := player.mover.nearest_cell()
	for cell: Vector2i in cells:
		_spawn_thread(cell, here, TRANSFUSION_TIME)
	var rising := PaintedBurst.new()
	player.add_child(rising)
	rising.setup(TILE_SIZE, 1.3, TRANSFUSION_TIME, 0.0, "peste_heal")
	rising.position = Vector2(0.0, -TILE_SIZE * 0.5)


func _on_pandemic_cast(cell: Vector2i) -> void:
	var wave := _spawn_painted_burst(cell, 1.0, 1.5, "peste_wave")
	wave.scale = Vector2.ONE
	wave.span_tiles(TILE_SIZE, PANDEMIC_TILES)


func _on_venom_killed(cell: Vector2i) -> void:
	_spawn_painted_burst(cell, 1.3, 0.85, "peste_dissolve")


# --- Le Chronomancien ------------------------------------------------------------

## Le dessin d'un jet doit tomber quand le jet tombe : même allure que `ThrowSystem`.
var _stones: Array[Dictionary] = []


func _update_stones() -> void:
	if combat == null:
		return
	for i in range(_stones.size() - 1, -1, -1):
		if not is_instance_valid(_stones[i]["ball"]):
			_stones.remove_at(i)
			continue
		(_stones[i]["ball"] as ThrownStone).time_scale = combat.time_factor_at(_stones[i]["cell"])


func _on_echo_walked(_ability: Ability, cells: Array, times: Array) -> void:
	var points := PackedVector2Array()
	for cell: Vector2i in cells:
		points.append(maze_renderer.cell_to_world(cell))
	var ghost := EchoGhost.new()
	entities.add_child(ghost)
	ghost.setup(points, times, player.walk_textures(), player.walk_poses(), player.pose_count(),
		player.sprite.scale, player.sprite.offset, TILE_SIZE)
	_spawn_painted_burst(cells[0], 1.0, 0.45)


func _on_hourglass_turned(duration: float) -> void:
	var ring := PaintedBurst.new()
	player.add_child(ring)
	ring.setup(TILE_SIZE, 1.2, duration, 0.0, "chrono_sand")
	# Sous le mage : relatif à son `z_index`, l'anneau reste au sol.
	ring.z_index = -1


func _on_hourglass_ended(healed: int) -> void:
	_spawn_painted_burst(player.mover.nearest_cell(), 1.6 if healed > 0 else 1.0, 0.5)


func _on_time_stopped(duration: float) -> void:
	_spawn_painted_burst(player.mover.nearest_cell(), PaintedBurst.MAX_RADIUS_TILES, duration,
		"chrono_stop")
	for enemy in enemies:
		enemy.time_freeze(duration)


func _on_immunity_faded() -> void:
	if character.id == "etoiles":
		player.modulate.a = 1.0
		return
	if character.id == "demon":
		# Le sceau se referme : ce qu'il rend revient à cet instant.
		_spawn_painted_burst(player.mover.nearest_cell(), 1.0, PACT_TIME * 0.6, "demon_pacte")
		return
	if character.id == "acier":
		return
	if _aegis != null and is_instance_valid(_aegis):
		_aegis.stop()
	_aegis = null


func _on_shield_faded() -> void:
	if _wings_cocoon != null and is_instance_valid(_wings_cocoon):
		_wings_cocoon.queue_free()
	_wings_cocoon = null
	if _bubble != null and is_instance_valid(_bubble):
		_bubble.queue_free()
	_bubble = null
	player_shielded.emit(0)


func _on_player_calmed() -> void:
	if _aura != null and is_instance_valid(_aura):
		_aura.stop()
	if _rebirth != null and is_instance_valid(_rebirth):
		_rebirth.stop()
	_rebirth = null
	player_calmed.emit()


## La crête part du mage et suit le chemin que le CombatSystem a tracé — les
## deux partagent la même durée, donc les dégâts tombent pile où on la voit.
func _on_wave_launched(ability: Ability, path: Array, duration: float) -> void:
	if player == null:
		return
	if ability.kind == Ability.Kind.WHEELS:
		_roll_wheel(path, duration)
		return
	if character.id == CharacterCatalog.AEL:
		_crystal_wake(path, duration)
		return
	var points := PackedVector2Array()
	points.append(maze_renderer.cell_to_world(player.mover.nearest_cell()))
	for cell in path:
		points.append(maze_renderer.cell_to_world(cell))
	var front: WaveFront = WAVE_SCENE.instantiate()
	entities.add_child(front)
	front.setup(points, duration, TILE_SIZE, Element.color(ability.element),
		ability.radius)


func _on_blast_fired(ability: Ability, cell: Vector2i) -> void:
	# Leur coup se voit par le geste et l'arc de lame, que joue `Player`.
	if character.id == CharacterCatalog.AEL and character.ultimate != null \
			and ability.id == character.ultimate.id:
		_awaken_shard(ability)
		return
	if character.id == CharacterCatalog.AEL and character.hero_form >= 4:
		_dragon_strike(ability)
		return
	# L'impact de la Comète est le seul éclatement en étoile d'Aël : rien de générique sur ses coups.
	if character.id == "ael" and ability != character.attack:
		if ability.kind == Ability.Kind.COMET:
			_spawn_star_burst(cell, maxf(1.0, ability.radius) * 1.4, _ael_colour())
			_shake(0.3, 0.9)
		return
	if character.id in ["test", "ael"]:
		return
	if character.id == "mort":
		_spawn_sweep(ability, cell)
		return
	if character.id == "demon":
		_spawn_demon_blast(ability, cell)
		return
	if character.id == "ciel":
		if ability.is_ultimate:
			_open_six_wings(cell, ability)
		else:
			_ring_the_bell(cell, ability)
		return
	# L'éclat prend le RAYON RÉEL du sort : le joueur doit voir jusqu'où il a
	# porté, sinon il ne peut pas apprendre à s'en servir.
	#
	# QUAND LE MAGE A UN BLASON, LUI SEUL ANNONCE L'EXTRA. Le dessin d'impact
	# est fait pour marquer une frappe d'une case ou deux ; étiré sur les six
	# cases de rayon d'un ultime, il devient une tache — et il doublait le
	# blason au même instant. On garde l'éclat tracé, qui dit la portée, et on
	# retire le sprite.
	var eclat := _impact_texture
	if ability.is_ultimate and _crest_texture != null:
		eclat = null
	# LE GRAND SOUFFLE A SON PROPRE DESSIN : rien d'autre par-dessus.
	#
	# L'éclat générique posait une tornade TOURNOYANTE au centre du mage — une
	# image qui pivote sur elle-même là où le sort chasse vers l'extérieur —
	# et ses grosses bulles blanches couvraient le cône et l'onde dessinés.
	# Signalé deux fois ; le sort se suffit.
	var souffle: bool = ability.blow_cells > 0 and not _cone_frames.is_empty()
	if souffle and character.id == AIR:
		var gust := _spawn_painted_burst(cell, ability.radius, 0.55, "air_gust")
		gust.rotation = Vector2(combat_context.player_facing).angle()
		gust.get_child(0).scale = Vector2(1.0, 1.4) * ability.radius * 2.0 * TILE_SIZE
		gust.get_child(0).position = Vector2(ability.radius * TILE_SIZE, 0.0)
		gust.z_index = 11
	elif not souffle:
		# L'Extra du Suprême a son propre coup : son étoile de tous les jours, étirée sur
		# un tel rayon, n'était plus qu'un aplat violet.
		_spawn_impact(cell, ability.element, ability.radius, 0.75, eclat,
			ability.flames, 1.6,
			"judgement_burst" if ability.is_ultimate and character.id == "supreme" else "")
	# LE CÔNE DEVANT, L'ONDE AUTOUR. Deux animations dessinées — la première
	# version traçait ses anneaux en code, ce qui donnait un rond pâle qui ne
	# disait ni la direction ni la force.
	#
	# ⚠️ Ce bloc a d'abord atterri dans `_on_projectile_hit` : les deux
	# fonctions se terminent par le même « if ability.shockwave », et j'ai
	# ancré dessus. Le Grand souffle n'est pas un projectile, donc rien ne
	# s'affichait — et rien ne criait non plus, puisque le code était valide.
	if souffle and not PAINTED_MAGES.has(character.id):
		var blast := WindBlast.new()
		entities.add_child(blast)
		blast.position = maze_renderer.cell_to_world(cell)
		blast.setup(TILE_SIZE, ability.radius, combat_context.player_facing,
			_cone_frames, _wave_frames)
		# UNE SECOUSSE COURTE. C'est le seul sort du jeu qui projette : la
		# caméra doit encaisser avec le labyrinthe, sinon le souffle n'a l'air
		# de rien peser. Bien plus brève et plus faible que le Séisme.
		_shake_total = 0.32
		_shake_left = _shake_total
		_shake_time = 0.0
	if ability.column_burst:
		var column: PressureColumn = COLUMN_SCENE.instantiate()
		entities.add_child(column)
		column.position = maze_renderer.cell_to_world(cell)
		column.setup(TILE_SIZE, ability.radius, Element.color(ability.element))
	if ability.shockwave:
		_spawn_shockwave(cell, ability)


## UN GEYSER JAILLIT quelque part sur la carte.
##
## Il n'y a plus de colonne sous les pieds du mage : elle l'effaçait une seconde
## durant. Ceux-ci sortent au hasard du labyrinthe, frappent ce qui passe, et
## laissent le joueur voir son personnage.
func _on_geyser_erupted(cell: Vector2i, ability: Ability) -> void:
	if PAINTED_MAGES.has(character.id):
		var column := _spawn_painted_burst(cell, 1.5, 0.85, "water_geyser")
		column.get_child(0).scale = Vector2(2.2, 4.4) * TILE_SIZE
		column.get_child(0).position = Vector2(0.0, -1.9) * TILE_SIZE
		column.z_index = 11
		return
	if _geyser_frames.is_empty():
		_spawn_impact(cell, ability.element, ability.geyser_radius, 0.7,
			_impact_texture)
		return
	var geyser: DrawnBurst = DRAWN_BURST_SCENE.instantiate()
	entities.add_child(geyser)
	geyser.position = maze_renderer.cell_to_world(cell)
	# Un peu plus rapide que la seconde entière : neuf colonnes qui traînent
	# ensemble sur l'écran deviennent un rideau.
	geyser.setup(TILE_SIZE, 2.0, 0.85, _geyser_frames, _geyser_anchor,
		false, true)


## L'incantation, jouée SUR le mage pendant que ses sceaux se gravent.
##
## Elle ne retarde rien : les quatre zones font déjà leur effet. C'est un récit,
## pas une mécanique — d'où le repli silencieux quand la planche manque.
## Le nom de fichier d'une boucle, depuis l'élément du sceau. Les quatre sont
## nommées en français comme les planches livrées — traduire ici plutôt que de
## renommer les planches garde le lien évident entre le dessin et son sort.
func _seal_fx_name(element: Element.Kind) -> String:
	match element:
		Element.Kind.FIRE:
			return "feu"
		Element.Kind.WATER:
			return "eau"
		Element.Kind.EARTH:
			return "terre"
		Element.Kind.AIR:
			return "air"
	return ""


func _on_seals_cast(cell: Vector2i) -> void:
	if PAINTED_MAGES.has(character.id):
		_spawn_painted_burst(cell, 1.2, 0.5, "convergence_burst")
		return
	if _seal_charge_texture == null or _seal_charge_frames <= 0:
		return
	var charge := SpellCharge.new()
	# Au-dessus des zones et des acteurs : c'est le geste du mage, il passe
	# devant ce qu'il vient de poser.
	charge.z_index = 14
	entities.add_child(charge)
	charge.position = maze_renderer.cell_to_world(cell)
	charge.setup(_seal_charge_texture, _seal_charge_frames, _seal_charge_fps,
		TILE_SIZE)


## L'incantation d'une pluie : le geste du mage, joué une fois, pendant que le
## ciel se prépare. Il dure exactement l'attente que le CombatSystem a imposée
## aux météores — les deux ne se parlent pas, ils partagent un nombre.
func _on_incantation_cast(cell: Vector2i, _ability: Ability) -> void:
	# Ses six ailes s'ouvrent déjà avec le sort (`_open_six_wings`).
	if character.id == "ciel":
		return
	if PAINTED_MAGES.has(character.id):
		_spawn_painted_burst(cell, 2.4, 0.8, "judgement_burst")
		return
	if _judgement_charge == null or _judgement_charge_frames <= 0:
		return
	var charge := SpellCharge.new()
	charge.z_index = 14
	entities.add_child(charge)
	charge.position = maze_renderer.cell_to_world(cell)
	# SEPT CASES, contre 4,5 pour un sort courant : c'est l'ultime, l'anneau
	# doit déborder largement autour du mage pour qu'on lise une orbite et pas
	# une aura collée à ses épaules.
	charge.setup(_judgement_charge, _judgement_charge_frames,
		_judgement_charge_fps, TILE_SIZE, 7.0)


func _on_zone_created(zone_id: int, ability: Ability, cell: Vector2i) -> void:
	# Les zones d'Aël sont dessinées par leurs sorts (`CrystalLine`, le sol en fusion de `DragonBreath`) :
	# jamais la nappe générique des autres personnages.
	if character.id == CharacterCatalog.AEL:
		return
	if ability.mark_seconds > 0.0:
		var bell := TollingBell.new()
		entities.add_child(bell)
		bell.position = maze_renderer.cell_to_world(cell)
		bell.setup(TILE_SIZE, ability.duration)
	# LES PICS NE SONT PAS UNE NAPPE. Une gerbe de pierre se dresse : elle a une
	# base au sol et une hauteur, là où le brasier et le cercle glacé s'étalent.
	# Elle a donc son propre nœud, avec son jaillissement et sa terre soulevée,
	# plutôt qu'un style de plus dans `ZoneEffect` — qui dessine en ADDITIF, ce
	# qui ferait briller la roche comme une flamme.
	# LA TORNADE a son propre dessin, et elle MARCHE : ce n'est pas une nappe
	# posée mais une colonne qui remonte le couloir.
	if ability.zone_style == "tornade":
		# La planche du TOUR si elle est là, l'image unique sinon : le sort
		# reste jouable même sans l'animation.
		var suite := _tornado_frames
		if suite.is_empty() and _tornado_texture != null:
			suite = [_tornado_texture] as Array[Texture2D]
		if suite.is_empty():
			return
		var tornado: Tornado = TORNADO_SCENE.instantiate()
		entities.add_child(tornado)
		tornado.position = maze_renderer.cell_to_world(cell)
		tornado.setup(TILE_SIZE, ability.duration, suite,
			Element.color(ability.element))
		if character.id == AIR:
			_spawn_painted_burst(cell, 1.3, 0.5, "air_streaks")
		_zone_nodes[zone_id] = tornado
		return
	# LA FAILLE joue la planche ANIMÉE : cristal et pierre en alternance selon
	# la case. Deux gerbes identiques côte à côte se lisent comme une image
	# copiée-collée ; alternées, le couloir se hérisse de deux matières.
	if ability.zone_style == "eruption" and not _burst_frames.is_empty():
		var matter := "crystal" if (cell.x + cell.y) % 2 == 0 else "stone"
		if not _burst_frames.has(matter):
			matter = _burst_frames.keys()[0]
		var burst: SpikeBurst = BURST_SCENE.instantiate()
		entities.add_child(burst)
		burst.position = maze_renderer.cell_to_world(cell)
		burst.setup(TILE_SIZE, ability.duration, _burst_frames[matter])
		if character.id == EARTH:
			_spawn_painted_burst(cell, 1.0, 0.45, "earth_crack")
		_zone_nodes[zone_id] = burst
		return
	if ability.zone_style == "pics":
		var spike: EarthSpike = SPIKE_SCENE.instantiate()
		entities.add_child(spike)
		spike.position = maze_renderer.cell_to_world(cell)
		spike.setup(TILE_SIZE, ability.duration, _spikes_texture, _dust_texture)
		if character.id == EARTH:
			_spawn_painted_burst(cell, 1.0, 0.45, "earth_crack")
		_zone_nodes[zone_id] = spike
		return
	var zone: ZoneEffect = ZONE_EFFECT_SCENE.instantiate()
	entities.add_child(zone)
	zone.position = maze_renderer.cell_to_world(cell)
	zone.setup(TILE_SIZE, Element.color(ability.element), ability.radius,
		ability.duration,
		# LA FLAQUE D'OMBRE N'A PAS DE DESSIN. Les autres zones posent le cercle
		# de leur planche — l'anneau de feu, le cercle de pierres ; celle-ci est
		# une absence, et n'importe quel motif lumineux par-dessus la ferait
		# ressembler à un sort qui s'allume.
		null if ability.zone_style == "ombre" or ZoneEffect.PAINTED_STYLES.has(ability.zone_style) else
		(_warp_texture if ability.zone_style == "portail" else
		(_seal_texture if ability.zone_style == "sceau" and _seal_texture != null
		else _zone_texture)),
		ability.flames, ability.zone_style, ability.snare > 0.0)
	# LA BOUCLE ÉLÉMENTAIRE par-dessus la gravure. Le sceau tient soixante
	# secondes : sans mouvement, quatre disques immobiles pendant une minute se
	# lisent comme du décor, pas comme un piège armé.
	if ability.zone_style == "sceau":
		# Le socle tombe sur le rayon du sort et le centre de sa case, la flamme
		# s'élève au-dessus.
		var span := ability.radius * 2.0 * TILE_SIZE / 0.68
		var seal := PaintedFx.cover(zone, "seal_flame", Vector2(span, span),
			Vector2(0.0, -span * 0.25))
		(seal.material as ShaderMaterial).set_shader_parameter("kind",
			PaintedFx.SEAL_KINDS.get(ability.element, 3))
	if ability.zone_style == "portail" and _rune_texture != null:
		# 4,5 images par seconde : un tour complet en une seconde et un tiers.
		# Plus vite, le portail devient une toupie ; plus lentement, le fondu
		# entre deux poses s'étire et l'anneau a l'air de flotter.
		zone.play_strip(_rune_texture, _rune_frames, 4.5)
	_zone_nodes[zone_id] = zone


## La zone qui MARCHE a changé de case : son rendu glisse jusque-là.
func _on_zone_moved(zone_id: int, cell: Vector2i) -> void:
	if not _zone_nodes.has(zone_id):
		return
	var node: Node2D = _zone_nodes[zone_id]
	if is_instance_valid(node) and node is Tornado:
		(node as Tornado).walk_to(maze_renderer.cell_to_world(cell))


func _on_zone_expired(zone_id: int) -> void:
	if _zone_nodes.has(zone_id):
		var zone: Node2D = _zone_nodes[zone_id]
		if is_instance_valid(zone):
			zone.queue_free()
		_zone_nodes.erase(zone_id)


## Un mur de pierre change la forme du labyrinthe : le rendu doit être refait,
## et les champs de distances aussi — sinon les ennemis continuent de courir
## droit à travers la pierre qui vient d'apparaître.
func _on_wall_changed(_cell: Vector2i) -> void:
	maze_renderer.set_grid(grid)
	if world_stage != null:
		world_stage.rebuild_walls()
	_refresh_ai()


## Le mage se translate. La colonne joue aux DEUX cases, celle qu'il quitte et
## celle où il arrive : sans l'annonce au départ, le joueur perd de vue son
## propre personnage et croit à un bug d'affichage.
## id d'invocation -> SummonVisual. Le CombatSystem chasse, ces nœuds montrent.
var _summon_nodes := {}


func _on_summon_spawned(id: int, kind_id: String, grid_position: Vector2) -> void:
	# LE CYCLONE N'EST PAS UNE CRÉATURE. Il chasse comme elles — c'est la même
	# machinerie, et c'est ce qui le rend autonome — mais il n'a ni faces ni
	# pose de coup : c'est une colonne qui tourne, posée par son PIED. Il lui
	# faut donc son propre nœud, et `SummonVisual` n'aurait rien su lire de lui
	# dans `allies.json`.
	if kind_id == "cyclone" and not _cyclone_frames.is_empty():
		var column: CycloneColumn = CYCLONE_SCENE.instantiate()
		entities.add_child(column)
		column.position = (grid_position + Vector2(0.5, 0.5)) * float(TILE_SIZE)
		column.setup(TILE_SIZE, _cyclone_frames, 1e9)
		if character.id == AIR:
			_spawn_painted_burst(Vector2i(grid_position.round()), 1.3, 0.5, "air_streaks")
		_summon_nodes[id] = column
		return
	var visual := SummonVisual.new()
	visual.z_index = 10
	entities.add_child(visual)
	visual.setup(kind_id, TILE_SIZE)
	visual.position = (grid_position + Vector2(0.5, 0.5)) * float(TILE_SIZE)
	_summon_nodes[id] = visual
	_spawn_effect(Vector2i(grid_position.round()), Color("#b06cff"), 1.4)


func _on_summon_moved(id: int, grid_position: Vector2, facing: Vector2i) -> void:
	var visual: Node2D = _summon_nodes.get(id)
	if visual == null or not is_instance_valid(visual):
		return
	visual.position = (grid_position + Vector2(0.5, 0.5)) * float(TILE_SIZE)
	# Une colonne qui tourne n'a pas de direction : la retourner ou la pivoter
	# lui ferait changer de sens de rotation en pleine course.
	if visual is SummonVisual:
		(visual as SummonVisual).set_facing(facing)


func _on_summon_struck(id: int, target: int) -> void:
	var node: Node2D = _summon_nodes.get(id)
	if node == null or not is_instance_valid(node):
		return
	# LA DÉCHARGE DU CYCLONE tombe SUR sa victime. La colonne, elle, ne fait
	# rien de particulier : elle tourne déjà, et un sursaut de plus se lirait
	# comme un raté d'animation.
	if node is CycloneColumn:
		if not _bolt_frames.is_empty() and target >= 0 and target < enemies.size():
			var bolt: BoltStrike = BOLT_SCENE.instantiate()
			entities.add_child(bolt)
			bolt.position = enemies[target].position
			bolt.setup(TILE_SIZE, _bolt_frames)
			_spawn_impact(enemies[target].current_cell(), Element.Kind.AIR, 0.9, 0.4)
		return
	var visual := node as SummonVisual
	visual.flash_strike()
	# LE GAZ SE POSE SUR LA VICTIME, pas sur celui qui souffle. La créature a sa
	# pose de souffle ; ce qui manque à l'écran est l'endroit où le nuage ARRIVE,
	# sans quoi on voit une ombre gesticuler et un ennemi perdre des points de
	# vie sans lien visible entre les deux.
	var gas: Texture2D = visual.gas_texture()
	if gas == null or target < 0 or target >= enemies.size():
		return
	var puff: GasPuff = GAS_PUFF_SCENE.instantiate()
	entities.add_child(puff)
	puff.position = enemies[target].position
	puff.setup(TILE_SIZE, gas, visual.gas_frames())


func _on_summon_projectile_launched(id: int, target: int, from: Vector2,
		to: Vector2, duration: float, ability: Ability) -> void:
	if target < 0 or target >= enemies.size():
		return
	var orb: MagicOrb = ORB_SCENE.instantiate()
	entities.add_child(orb)
	var points := PackedVector2Array([
		maze_renderer.cell_to_world(Vector2i(from.round())) +
			(Vector2(to) - Vector2(from)).normalized() * float(TILE_SIZE) * 1.15,
		maze_renderer.cell_to_world(Vector2i(to.round())),
	])
	orb.setup(points, duration, TILE_SIZE, Element.color(ability.element),
		_fire_orb_texture, _fire_orb_frames, ability.projectile_scale, ability.trail_density,
		ability.flames, _fire_orb_grows)
	_summon_orbs[id] = orb


func _on_summon_projectile_hit(id: int, target: int, cell: Vector2i,
		ability: Ability) -> void:
	if _summon_orbs.has(id):
		var orb: MagicOrb = _summon_orbs[id]
		if is_instance_valid(orb):
			orb.burst()
		_summon_orbs.erase(id)
	if target >= 0 and target < enemies.size():
		_spawn_impact(cell, Element.Kind.FIRE, 1.7, 0.65, null, 1.25)


func _on_summon_expired(id: int) -> void:
	var visual: Node2D = _summon_nodes.get(id)
	if visual != null and is_instance_valid(visual):
		_spawn_effect(Vector2i((visual.position / float(TILE_SIZE)).round()),
			Color("#7a5bc4"), 1.2)
		# La colonne RETOMBE au lieu de disparaître : elle a mis une demi-seconde
		# à se lever, elle ne peut pas s'éteindre en une frame.
		if visual is CycloneColumn:
			(visual as CycloneColumn).stop()
		else:
			visual.queue_free()
	_summon_nodes.erase(id)


func _on_blink(from: Vector2i, to: Vector2i) -> void:
	if player == null:
		return
	# La teinte vient de l'ÉLÉMENT du mage : les braises du Feu sont orange, le
	# Pas de l'ombre laisse une traînée violette, la Rafale une traînée blanche.
	# Un seul effet, sept lectures.
	if character.id == CharacterCatalog.AEL:
		_ael_leap(from, to)
		return
	var tint := Element.color(character.element)
	_spawn_warp(player.mover.nearest_cell(), tint, false)
	if character.id == "lumiere":
		var flight := LightArc.new()
		entities.add_child(flight)
		flight.setup(maze_renderer.cell_to_world(from), maze_renderer.cell_to_world(to), TILE_SIZE)
	elif character.id == "cherubin":
		_lightning_trail(from, to)
	elif character.id == "avide":
		# Le Bond bestial : une traînée d'ombre verte, et le sol se fend au départ.
		_bile_streak(from, to, 0.35)
		_spawn_painted_burst(from, 1.3, 1.0, "avide_fissure")
	elif character.id == "croupier":
		# Il s'efface dans une gerbe de cartes, et elles se rassemblent là où il reparaît.
		_card_spray(from, 12)
		_card_spray(to, 8)
	elif character.id == "dragon":
		# Le bond de la Morsure et le recul des ailes : une langue de feu, et le sol se fend au départ.
		_flame_streak(from, to, 0.3)
		_spawn_painted_burst(from, 1.3, 1.0, "dragon_fissure")
		_dragon_smoke_puff(from, 14)
	elif character.id == "geolier":
		# Une langue de flamme froide passe à travers la haie, et le givre court des deux côtés.
		_cold_streak(from, to, 0.45)
		_spawn_painted_burst(from, 1.4, 0.9, "geolier_givre")
		_spawn_painted_burst(to, 1.4, 0.9, "geolier_givre")
		_frost_shards(to, 12)
		_shake(0.14, 0.4)
	elif character.id in ["etoiles", "acier", "demon", "discorde", "braise", "ecarlate"]:
		pass
	elif character.id == "mort":
		var passage := DeathPassage.new()
		entities.add_child(passage)
		passage.setup(maze_renderer.cell_to_world(from), maze_renderer.cell_to_world(to), TILE_SIZE)
	else:
		_spawn_warp_trail(from, to, tint)
	player.mover.teleport_to(to)
	player.snap_to_mover()
	_spawn_warp(to, tint, true)
	_shake(0.16, 0.45)
	player.play_warp()
	_refresh_ai()


## La fuite se voit aux deux bouts : à une case et 0,42 s, on ne la voyait plus (revue du
## 2026-11-03, demande du joueur : un effet magique dramatique pour chaque sort).
const ESCAPE_RADIUS := 1.7
const ESCAPE_TIME := 0.7


## LA FUITE DE CHAQUE MAGE EST LA SIENNE : le Feu se défait en braises qui montent,
## l'Ombre se dissipe en fumée, l'Invocateur s'efface derrière un sceau.
func _spawn_painted_escape(cell: Vector2i) -> void:
	var at := maze_renderer.cell_to_world(cell)
	var puff: CPUParticles2D = null
	match character.id:
		"fire":
			puff = FxTextures.flame_emitter(64, 0.75, TILE_SIZE * 0.5,
				Color(1.0, 0.86, 0.3, 0.95), Color(0.85, 0.15, 0.02, 0.0), -TILE_SIZE * 1.6, 180.0)
			puff.initial_velocity_min = TILE_SIZE * 0.4
			puff.initial_velocity_max = TILE_SIZE * 2.4
		"shadow":
			puff = FxTextures.smoke_emitter(44, 0.9, TILE_SIZE * 1.5, -TILE_SIZE * 0.5)
			# Plus clair qu'avant : une fumée violet sombre disparaissait sur un sol sombre.
			puff.modulate = Color(0.85, 0.5, 1.25)
		_:
			_spawn_painted_burst(cell, ESCAPE_RADIUS, ESCAPE_TIME, str(PaintedFx.ESCAPE[character.id]))
			return
	entities.add_child(puff)
	puff.position = at
	puff.z_index = 9
	puff.one_shot = true
	puff.explosiveness = 0.92
	puff.emitting = true
	get_tree().create_timer(puff.lifetime + 0.3).timeout.connect(puff.queue_free)


func _spawn_warp(cell: Vector2i, tint: Color, arriving: bool) -> void:
	if PAINTED_MAGES.has(character.id):
		_spawn_painted_escape(cell)
		return
	if DRAWN_MAGES.has(character.id):
		_spawn_painted_burst(cell, ESCAPE_RADIUS, ESCAPE_TIME, str(PaintedFx.ESCAPE[character.id]))
	var effect: WarpEffect = WARP_SCENE.instantiate()
	entities.add_child(effect)
	effect.position = maze_renderer.cell_to_world(cell)
	effect.setup(player.character_id, TILE_SIZE, tint, arriving)


## La traînée qui RELIE les deux bouts. Sans elle, le joueur voit deux
## événements sans rapport et perd son propre personnage sur un écran chargé.
func _spawn_warp_trail(from: Vector2i, to: Vector2i, tint: Color) -> void:
	var path := combat.trajectory(from, to)
	if path.size() < 2:
		return
	var points := PackedVector2Array()
	for cell in path:
		points.append(maze_renderer.cell_to_world(cell))
	var trail: WarpTrail = WARP_TRAIL_SCENE.instantiate()
	entities.add_child(trail)
	# Le Pas du néant ouvre un trou noir à chaque bout : les grosses braises, entassées
	# sur la case, y faisaient une tache blanche par-dessus le visage du mage.
	if character.id == "invocateur":
		trail.setup(points, TILE_SIZE, tint, 0.14)
	else:
		trail.setup(points, TILE_SIZE, tint)
	# LE MAGE DE FOUDRE NE SE TÉLÉPORTE PAS : IL DEVIENT L'ÉCLAIR.
	#
	# Sa description le dit depuis toujours — « il devient foudre le temps d'un
	# battement de cils » — mais il empruntait la même traînée douce que les six
	# autres. On pose un arc électrique sur chaque tronçon du couloir : la
	# décharge suit les virages au lieu de couper à travers les murs.
	if character.element != Element.Kind.THUNDER:
		return
	for i in points.size() - 1:
		var arc: LightningArc = ARC_SCENE.instantiate()
		entities.add_child(arc)
		arc.setup(points[i], points[i + 1], tint, float(TILE_SIZE) * 0.13)


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


## La trempe porte désormais SON facteur : celui de l'élément Eau ralentit de
## 38 %, le givre du Cercle glacé bien davantage. Un seul canal, deux forces.
func _on_enemy_soaked(index: int, duration: float, factor: float) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	enemies[index].soak(duration, factor)


## ASPIRÉE vers le mage. La créature est déplacée d'un coup, comme pour un
## souffle — mais l'effet, lui, part de LÀ OÙ ELLE ÉTAIT et non de son point
## d'arrivée. Sans cette traînée, le joueur voit trois poursuivants changer de
## case sans raison et croit à un bug ; avec elle, il voit son sort les tirer.
## LA PORTE QUI S'OUVRE SUR UNE PROIE.
##
## Elle réutilise le portail de la Rune — même dessin, même rotation. Ce n'est
## pas une économie : c'est le même passage, ouvert pour soi au sol ou déchiré
## au loin, et le joueur doit le reconnaître. Deux portails différents pour le
## même mage donneraient deux sorts sans rapport.
##
## Elle ne dure que le temps de laisser sortir ce qu'elle contient. Une porte qui
## resterait ouverte deux minutes deviendrait un décor, et le joueur cesserait de
## regarder ce qui en sort.
func _on_rift_opened(cell: Vector2i) -> void:
	var rift: ZoneEffect = ZONE_EFFECT_SCENE.instantiate()
	entities.add_child(rift)
	rift.position = maze_renderer.cell_to_world(cell)
	rift.setup(TILE_SIZE, Element.color(Element.Kind.SHADOW), 1.2, RIFT_SHOW,
		_warp_texture, 0.0, "portail", false)
	if _rune_texture != null:
		rift.play_strip(_rune_texture, _rune_frames, 6.0)


func _on_enemy_poisoned(index: int, duration: float) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	enemies[index].poison_glow(duration)


func _on_enemy_hauled(index: int, cell: Vector2i) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	var enemy: Enemy = enemies[index]
	# La traînée suit le COULOIR et non la ligne droite : l'aspiration se mesure
	# en distance de chemin, donc une créature tirée depuis l'autre côté d'un
	# virage doit être vue passer par le virage. Une corde tendue à travers la
	# haie dirait que le sort traverse les murs, ce qu'il ne fait pas.
	var path := combat.trajectory(enemy.mover.decision_cell(), cell)
	var points := PackedVector2Array()
	for step in path:
		points.append(maze_renderer.cell_to_world(step))
	enemy.mover.teleport_to(cell)
	enemy.snap_to_mover()
	if points.size() >= 2:
		var trail: WarpTrail = WARP_TRAIL_SCENE.instantiate()
		entities.add_child(trail)
		trail.setup(points, TILE_SIZE, Element.color(Element.Kind.SHADOW))


## PLAQUÉE CONTRE LA PIERRE. L'éclat est posé sur la case où la course s'est
## arrêtée : c'est le seul indice qui apprend que le mur fait mal.
func _on_enemy_slammed(index: int, cell: Vector2i) -> void:
	if index >= enemies.size():
		return
	var mark := SlamMark.new()
	entities.add_child(mark)
	mark.position = maze_renderer.cell_to_world(cell)
	mark.setup(TILE_SIZE)
	if is_instance_valid(enemies[index]):
		enemies[index].flash_hit()


func _on_enemy_pushed(index: int, cell: Vector2i) -> void:
	if _structure_at(index) != null or index >= enemies.size():
		return
	var enemy: Enemy = enemies[index]
	enemy.mover.teleport_to(cell)
	enemy.snap_to_mover()
	# Le Chérubin rejette dans sa propre flamme (`garden_repelled`, `veil_repelled`).
	if character.id == "cherubin":
		return
	_spawn_impact(cell, Element.Kind.AIR, 0.9, 0.5)


## Une météore part : on montre sa chute et on marque le sol. Le nœud vit
## exactement le temps que le CombatSystem a fixé — les deux ne se parlent plus
## ensuite, ils partagent seulement le même délai.
func _on_meteor_incoming(cell: Vector2i, delay: float, ability: Ability) -> void:
	if character.id == "ciel":
		_sword_incoming(cell, delay, ability)
		return
	var meteor: Meteor = METEOR_SCENE.instantiate()
	entities.add_child(meteor)
	meteor.position = maze_renderer.cell_to_world(cell)
	# CE QUI TOMBE EST CE QUI ÉCLABOUSSE. Quand la planche du mage dessine sa
	# pluie, la goutte en vol est la PREMIÈRE image de son éclaboussure — celle
	# où elle est encore en l'air. Sinon, c'est l'orbe du personnage : une
	# comète qui tombe convient au Feu, pas à l'Eau.
	var falling := _orb_texture
	var liquid := not _splash_frames.is_empty()
	if liquid:
		falling = _splash_frames[0]
	# LA MÉTÉORE AUX QUATRE ÉLÉMENTS a sa propre planche, et elle TOURNE en
	# tombant. Elle passe avant le test de la goutte : le Suprême n'a pas
	# d'éclaboussure, mais si un jour il en avait une, c'est la boule qui doit
	# tomber, pas la première image de sa flaque.
	if ability.rain_hunts and _judgement_meteor != null:
		meteor.setup(TILE_SIZE, delay, _judgement_meteor,
			Element.color(ability.element), 2.8, false,
			_judgement_meteor_frames, _judgement_meteor_fps)
		meteor.paint("meteore_jugement", 1.6)
		_meteor_rank = (_meteor_rank + 1) % 4
		(meteor.rock.material as ShaderMaterial).set_shader_parameter("kind", _meteor_rank)
		return
	# PLUS PETITE quand c'est une goutte : trente météores à une case et demie
	# effaceraient le labyrinthe. Une goutte tient dans le tiers d'une case.
	meteor.setup(TILE_SIZE, delay, falling, Element.color(ability.element),
		0.55 if liquid else 1.6, liquid)
	if liquid:
		meteor.paint("goutte", 0.7)
	elif PAINTED_MAGES.has(character.id):
		meteor.paint("boule_peinte", METEOR_PAINTED_SCALE)


func _on_meteor_landed(cell: Vector2i, ability: Ability) -> void:
	if character.id == "ciel":
		_sword_landed(cell)
		return
	# CHAQUE GOUTTE A SA PROPRE ÉCLABOUSSURE quand le mage en a une : trente
	# gouttes qui tombent doivent se voir tomber, pas seulement compter des
	# dégâts. Le reste des mages garde l'éclat générique.
	# L'ÉCLAT DESSINÉ DU JUGEMENT. Il passe avant l'éclaboussure : le Suprême n'en
	# a pas, mais la règle doit être lisible — ce qui a une planche à soi la joue.
	if ability.rain_hunts and PAINTED_MAGES.has(character.id):
		_spawn_painted_burst(cell, maxf(1.6, ability.rain_radius), 0.55, "judgement_burst")
		return
	if not _splash_frames.is_empty() and PAINTED_MAGES.has(character.id):
		_spawn_painted_burst(cell, ability.rain_radius, 0.5, "water_splash")
		return
	if ability.rain_hunts and not _judgement_impact.is_empty():
		var strike: DrawnBurst = DRAWN_BURST_SCENE.instantiate()
		entities.add_child(strike)
		strike.position = maze_renderer.cell_to_world(cell)
		strike.setup(TILE_SIZE, maxf(2.4, ability.rain_radius * 1.8), 0.5,
			_judgement_impact, Vector2(0.5, 0.5))
		return
	if not _splash_frames.is_empty():
		var splash: DrawnBurst = DRAWN_BURST_SCENE.instantiate()
		entities.add_child(splash)
		splash.position = maze_renderer.cell_to_world(cell)
		splash.setup(TILE_SIZE, maxf(1.6, ability.rain_radius * 1.4), 0.55,
			_splash_frames, _splash_anchor)
	else:
		_spawn_impact(cell, ability.element, ability.rain_radius,
			ImpactEffect.DURATION * 1.6, _impact_texture, ability.flames)
	_spawn_shockwave(cell, Ability.make({
		"element": ability.element, "radius": ability.rain_radius * 1.1}))


## Les nuages du Jugement, posés sur la carte. Indexés par CASE : c'est la clé
## que le CombatSystem emploie, et deux nuages ne partagent jamais une case.
var _sky_clouds := {}


func _on_sky_cloud_formed(cell: Vector2i, duration: float, _ability: Ability) -> void:
	var cloud: SkyCloud = SKY_SCENE.instantiate()
	entities.add_child(cloud)
	cloud.position = maze_renderer.cell_to_world(cell)
	# Déphasage par case : sans lui, tous les nuages du ciel se balancent à
	# l'unisson et l'orage se lit comme une seule image répétée.
	cloud.setup(TILE_SIZE, duration, _cloud_texture, _cloud_lit_texture,
		float(cell.x * 7 + cell.y * 13) * 0.37)
	PaintedFx.cover(cloud, "thunder_cloud", Vector2(3.0, 1.9) * TILE_SIZE,
		Vector2(0.0, -SkyCloud.HEIGHT_TILES) * TILE_SIZE)
	_sky_clouds[cell] = cloud
	# Pas d'impact sous le nuage qui se forme : douze dessins de frappe surgis
	# d'un coup aux quatre coins de la carte, c'était du bruit, et ça annonçait
	# une frappe qui n'avait pas encore eu lieu. Le nuage qui se forme est
	# l'événement ; la frappe viendra.


func _on_sky_cloud_faded(cell: Vector2i) -> void:
	if not _sky_clouds.has(cell):
		return
	var cloud: SkyCloud = _sky_clouds[cell]
	if is_instance_valid(cloud):
		cloud.fade()
	_sky_clouds.erase(cell)


## La foudre tombe d'un nuage du ciel sur sa proie.
func _on_sky_bolt(cell: Vector2i, index: int, ability: Ability) -> void:
	if index >= enemies.size() or _structure_at(index) != null:
		return
	if _sky_clouds.has(cell):
		var cloud: SkyCloud = _sky_clouds[cell]
		if is_instance_valid(cloud):
			cloud.discharge()
	var from := maze_renderer.cell_to_world(cell) \
		+ Vector2(0.0, -TILE_SIZE * SkyCloud.HEIGHT_TILES)
	var arc: LightningArc = ARC_SCENE.instantiate()
	entities.add_child(arc)
	arc.setup(from, enemies[index].position, Element.color(ability.element),
		float(TILE_SIZE) * 0.16)
	# La frappe du Jugement est la MÊME que celle de l'attaque de base — même
	# dessin animé, même échelle : c'est le geste de l'élément, décliné du plus
	# petit coup au plus grand.
	_spawn_impact(enemies[index].current_cell(), ability.element, 1.7, 0.55,
		_impact_texture, 0.0, 0.0)


## Le nuage d'orage, ATTACHÉ au mage : il n'a rien à poursuivre, il est sur lui.
var _cloud: StormCloud = null


func _on_storm_gathered(ability: Ability, duration: float) -> void:
	if player == null:
		return
	if character.id == CharacterCatalog.AEL:
		if _ael_orbit != null and is_instance_valid(_ael_orbit):
			_ael_orbit.refresh(duration)
			return
		_ael_orbit = ShardOrbit.new()
		player.add_child(_ael_orbit)
		_ael_orbit.setup(TILE_SIZE, _ael_colour(), duration)
		return
	if _cloud != null and is_instance_valid(_cloud):
		_cloud.refresh(duration)
		return
	_cloud = CLOUD_SCENE.instantiate()
	player.add_child(_cloud)
	_cloud.setup(TILE_SIZE, duration)


func _on_storm_dispersed() -> void:
	if _ael_orbit != null and is_instance_valid(_ael_orbit):
		_ael_orbit.stop()
	_ael_orbit = null
	if _cloud != null and is_instance_valid(_cloud):
		_cloud.stop()
	_cloud = null


## Une décharge tombe. Le trait part du NUAGE et non du mage : c'est ce qui
## rend l'orage lisible comme une chose à part, et non comme une attaque de plus.
func _on_storm_struck(index: int, ability: Ability) -> void:
	if index >= enemies.size() or _structure_at(index) != null:
		return
	if character.id == CharacterCatalog.AEL:
		var from := player.position
		if _ael_orbit != null and is_instance_valid(_ael_orbit):
			from += _ael_orbit.strike() * player.scale
		var blade := BladeThrow.new()
		entities.add_child(blade)
		blade.setup(from, enemies[index].position, TILE_SIZE, _ael_colour())
		return
	if _cloud != null and is_instance_valid(_cloud):
		_cloud.discharge()
	var from := player.position + Vector2(0.0, -TILE_SIZE * StormCloud.HEIGHT)
	var arc: LightningArc = ARC_SCENE.instantiate()
	entities.add_child(arc)
	arc.setup(from, enemies[index].position, Element.color(ability.element),
		float(TILE_SIZE) * 0.22, 0.38)
	_spawn_impact(enemies[index].current_cell(), ability.element, 1.4, 0.6)
	_shake(0.1, 0.3)


## Le trait qui relie deux maillons de la chaîne. `from_index` vaut -1 quand
## l'arc part du mage lui-même — le premier relais.
func _on_chain_arced(from_index: int, to_index: int) -> void:
	if _structure_at(to_index) != null or to_index >= enemies.size():
		return
	var target := enemies[to_index]
	var start := player.position if from_index < 0 else Vector2.ZERO
	if from_index >= 0:
		if from_index >= enemies.size():
			return
		start = enemies[from_index].position
	if character.id == CharacterCatalog.AEL:
		var link := PrismLink.new()
		entities.add_child(link)
		link.setup(start, target.position, TILE_SIZE, _ael_colour())
		_shake(0.1, 0.3)
		return
	var arc: LightningArc = ARC_SCENE.instantiate()
	entities.add_child(arc)
	arc.setup(start, target.position, Element.color(Element.Kind.THUNDER),
		float(TILE_SIZE) * 0.24, 0.42)
	_spawn_impact(target.current_cell(), Element.Kind.THUNDER, 1.4, 0.6)
	_shake(0.12, 0.35)


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
	if index == _boss_index:
		enemy_defeated.emit(enemy.species, true, enemy.position)
		_on_boss_killed()
		return
	var fade := DeathFade.new()
	fade.setup(enemy.sprite, enemy.position)
	entities.add_child(fade)
	# L'éclat est à la couleur du mage. Il était celui du Suprême pour tout le monde,
	# et chaque mage finissait ses combats par le même feu d'artifice.
	_spawn_impact(enemy.current_cell(),
		character.element if character != null else Element.Kind.SUPREME, 2.0, 0.8)
	_drop_stolen_gem(enemy)
	enemy.set_dead(true)
	if Bestiary.is_droplet(enemy.species):
		enemy_defeated.emit(enemy.species, false, enemy.position)
		enemy_killed.emit()
		return
	_respawns[index] = config.enemy_respawn_delay
	if not _split(enemy):
		enemy_defeated.emit(enemy.species, false, enemy.position)
		enemy_killed.emit()


# --- Le boss du chapitre -----------------------------------------------------------

const BOSS_ENEMIES_PATH := "res://assets/enemies/%s/"
## Le temps de ses grands gestes, en secondes.
const BOSS_ARRIVAL_TIME := 2.2
const BOSS_DEATH_TIME := 1.8
const BOSS_DEATH_FADE := 0.7
## À combien de pas du mage il surgit : assez loin pour ne pas frapper à l'arrivée.
const BOSS_SPAWN_STEPS := 5
const BOSS_COVER_TILES := 1.6
const BOSS_COVER_ALPHA := 0.55
## Le Roi Déchu reparaît à cette distance du mage : assez loin pour qu'il voie d'où il vient.
const BOSS_BLINK_STEPS := 4
## Le mage est-il assez près dans sa ligne pour valoir une charge ?
const BOSS_CHARGE_SIGHT := 8
## Le Béhémoth rejette le mage de tant de cases.
const BOSS_PUSH_CELLS := 2

## Sa place dans `enemies`, réservée au chargement comme celle des petites gelées : les
## index du combat ne bougent jamais sous les projectiles en vol. -1 sans boss.
var _boss_index := -1
var _boss_fight: BossFight = null
var _boss_gait: BossGait = null
var _boss_beaten := false
var _boss_strips := {}
var _boss_scene_scale := 1.0
var _boss_scene_offset := Vector2.ZERO
var _boss_zones: Array[BossZone] = []
var _boss_scene: BossStrip = null


## Il garde la porte tant qu'il n'est pas tombé. En démo, seulement une fois appelé.
func boss_guards_door() -> bool:
	return _boss_index >= 0 and not _boss_beaten and (not config.is_demo or boss_has_appeared())


## Tout le reste est fait : c'est son tour.
func boss_is_due() -> bool:
	return boss_guards_door() and not boss_has_appeared() \
		and gems_remaining() <= 0 and lairs_remaining() <= 0


## En démo, on l'appelle quand on veut : aucune gemme ne le précède, et il revient après
## sa mort. Pas pendant sa chute, deux dessins du même boss se croiseraient.
func boss_can_be_called() -> bool:
	return config != null and config.is_demo and _boss_index >= 0 and not boss_has_appeared()


func boss_has_appeared() -> bool:
	return _boss_scene != null or _boss_fight != null


## Le boss est-il là, à combattre ? La barre de l'écran ne parle que de ça.
func boss_is_fighting() -> bool:
	return _boss_fight != null


func boss_name() -> String:
	return "" if _boss_index < 0 else Bestiary.display_name(enemies[_boss_index].species)


func boss_health_ratio() -> float:
	return 0.0 if _boss_index < 0 else enemies[_boss_index].health.ratio()


func _house_seals() -> int:
	return missing_gem_colors().size() + (1 if boss_guards_door() else 0)


func _clear_boss() -> void:
	_boss_index = -1
	_boss_fight = null
	_boss_gait = null
	_boss_beaten = false
	_boss_strips.clear()
	_boss_scene = null
	for zone in _boss_zones:
		if is_instance_valid(zone):
			zone.queue_free()
	_boss_zones.clear()


func _prepare_boss() -> void:
	if not config.has_boss():
		house.set_locked(_house_seals())
		return
	var id := BossCatalog.id_of(config.stage)
	# En démo, le vrai boss : le terrain d'essai change les PV de ses poursuivants, et on ne
	# saurait plus ce que vaut le combat qu'on vient essayer. Sa vitesse ne suit aucun stage.
	var fight_config := LevelConfig.for_stage(config.stage, LevelConfig.EPISODES_PER_STAGE) \
		if config.is_demo else config
	var enemy: Enemy = ENEMY_SCENE.instantiate()
	entities.add_child(enemy)
	enemy.setup_enemy(grid, grid.house_center, float(BossCatalog.of_stage(config.stage)["speed"]),
		TILE_SIZE, maxi(grid.cols, grid.rows), id, fight_config.enemy_health(id))
	enemy.health.current = 0
	enemy.set_dead(true)
	_boss_index = enemies.size()
	enemies.append(enemy)
	var folder := BOSS_ENEMIES_PATH % id
	for strip in ["arrival", "ranged_attack", "death", "warning", "impact", "fade"]:
		_boss_strips[strip] = load(folder + strip + ".png")
	var meta: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(
		folder + "special_frames.json"))
	# Même corps à l'écran que sur ses planches de marche : ces poses sont en cases de 256.
	_boss_scene_scale = float(Bestiary.of(id)["body"]) / float(meta["scene_body"])
	_boss_scene_offset = Vector2(0.0, float(meta["cell"][1]) * 0.5 - float(meta["scene_feet_y"]))
	house.set_locked(_house_seals())


## Le mage revient à la porte, tout est fait : le gardien surgit.
func summon_boss() -> void:
	if boss_is_due():
		_raise_boss()


## Le bouton de la démo : le mage n'a rien à finir avant, et la porte se ferme le temps
## du combat, comme en partie.
func call_boss() -> void:
	if not boss_can_be_called():
		return
	_boss_beaten = false
	_raise_boss()
	house.set_locked(_house_seals())


func _raise_boss() -> void:
	var cell := _boss_cell_at(BOSS_SPAWN_STEPS)
	_boss_scene = _boss_scene_at(maze_renderer.cell_to_world(cell))
	_boss_scene.play(_boss_strips["arrival"], BOSS_ARRIVAL_TIME)
	_boss_scene.finished.connect(_on_boss_arrived.bind(cell), CONNECT_ONE_SHOT)
	_spawn_effect(cell, Color("#ff9a7a"), 3.0)
	boss_appeared.emit(boss_name())


func _boss_scene_at(at: Vector2) -> BossStrip:
	var scene := BossStrip.new()
	scene.position = at
	scene.z_index = 10
	scene.offset = _boss_scene_offset
	entities.add_child(scene)
	# APRÈS l'entrée dans `entities` : la vue 2,5D y corrige déjà sa hauteur.
	scene.scale *= _boss_scene_scale
	return scene


## La case la plus proche de la maison à la bonne distance du mage.
func _boss_cell_at(steps: int) -> Vector2i:
	var field := Pathfinder.distance_field(grid, [player.mover.nearest_cell()])
	var best := grid.house_center
	var best_gap := 1 << 30
	for y in grid.rows:
		for x in grid.cols:
			var cell := Vector2i(x, y)
			# Pas sur l'îlot de la maison : il y marcherait sur le dessin du monument.
			if Pathfinder.value_at(grid, field, cell) != steps or grid.is_house(cell):
				continue
			var gap := absi(cell.x - grid.house_center.x) + absi(cell.y - grid.house_center.y)
			if gap < best_gap:
				best_gap = gap
				best = cell
	return best


func _on_boss_arrived(cell: Vector2i) -> void:
	_boss_scene.queue_free()
	var enemy := enemies[_boss_index]
	enemy.revive_at(cell)
	enemy.player_field = _player_field
	_boss_fight = BossFight.new(config.stage, cell.x * 31 + cell.y)
	_boss_gait = BossGait.new(config.stage)
	_boss_scene = null


func _update_boss(delta: float, stopped: bool) -> void:
	_boss_zones.assign(_boss_zones.filter(func(zone: Variant) -> bool: return is_instance_valid(zone)))
	for zone in _boss_zones:
		zone.set_process_mode(PROCESS_MODE_DISABLED if stopped else PROCESS_MODE_INHERIT)
	if _boss_fight == null or stopped or player == null:
		return
	var enemy := enemies[_boss_index]
	_keep_player_visible(enemy)
	var at := player.mover.nearest_cell()
	var free := not (enemy.is_staggered() or enemy.is_blinded())
	if _boss_fight.tick(delta, grid, at, enemy.mover.nearest_cell(),
			free and not _boss_gait.is_charging()):
		_on_boss_alert(enemy)
	if not _boss_fight.struck.is_empty():
		_on_boss_strike(enemy)
	var sheltered := teleport_system != null and teleport_system.is_invulnerable(player.mover)
	if _boss_fight != null and _boss_fight.on_wall(at) and not sheltered:
		player_caught.emit()
	_drive_boss_gait(delta, enemy, at, free)


## Le labyrinthe et le mage, c'est le Level qui les voit : `BossGait` ne fait que compter.
func _drive_boss_gait(delta: float, enemy: Enemy, at: Vector2i, free: bool) -> void:
	var gait := _boss_gait
	var from := enemy.mover.decision_cell()
	match gait.tick(delta, enemy.is_casting() or not free):
		BossGait.Cue.BLINK:
			_boss_blink(enemy)
		BossGait.Cue.WANTS_CHARGE:
			if ThrowSystem.in_line(grid, from, at, BOSS_CHARGE_SIGHT):
				gait.start_charge(Vector2i(signi(at.x - from.x), signi(at.y - from.y)))
				_spawn_effect(from, Color("#ff9a7a"), 2.0)
	var charge := gait.charge_direction()
	if charge != Vector2i.ZERO and not grid.is_floor_v(from + charge):
		gait.end_charge()
		enemy.stagger(gait.stun)
		charge = Vector2i.ZERO
	elif charge != Vector2i.ZERO and from + charge == at:
		gait.end_charge()
		charge = Vector2i.ZERO
	var boss := BossCatalog.of_stage(config.stage)
	var enraged := enemy.health.ratio() < float(boss.get("enrage_below", 0.0))
	enemy.gait_factor = gait.factor * (float(boss["enrage_factor"]) if enraged else 1.0)
	enemy.gait_charge = charge
	enemy.gait_hold = gait.holding or (gait.keep_away > 0
		and Pathfinder.value_at(grid, _player_field, enemy.mover.nearest_cell()) <= gait.keep_away)


func _boss_blink(enemy: Enemy) -> void:
	_spawn_effect(enemy.mover.nearest_cell(), Color("#8f7bff"), 2.5)
	var cell := _boss_cell_at(BOSS_BLINK_STEPS)
	enemy.mover.teleport_to(cell)
	enemy.snap_to_mover()
	_spawn_effect(cell, Color("#8f7bff"), 2.5)


## Le boss fait près de deux fois le mage : juste devant lui, il le cacherait entièrement.
## Le personnage joué n'est jamais masqué, le boss s'efface donc un peu.
func _keep_player_visible(enemy: Enemy) -> void:
	var gap := enemy.position - player.position
	var covers := gap.y > 0.0 and gap.y < TILE_SIZE * BOSS_COVER_TILES \
		and absf(gap.x) < TILE_SIZE * BOSS_COVER_TILES
	enemy.modulate.a = BOSS_COVER_ALPHA if covers else 1.0


func _on_boss_alert(enemy: Enemy) -> void:
	var fight := _boss_fight
	var strips := {"warning": _boss_strips["warning"], "impact": _boss_strips["impact"],
		"fade": _boss_strips["fade"]}
	for cell in fight.cells:
		var zone := BossZone.new()
		add_child(zone)
		zone.cell = cell
		zone.setup(maze_renderer.cell_to_world(cell), TILE_SIZE, strips,
			fight.alert_time + fight.delay_of(cell), fight.uses_bands(), fight.is_vertical(cell))
		_boss_zones.append(zone)
	enemy.play_cast(_boss_strips["ranged_attack"],
		fight.alert_time + fight.longest_delay() + BossZone.IMPACT_TIME,
		_boss_scene_scale, _boss_scene_offset)


func _on_boss_strike(enemy: Enemy) -> void:
	var fight := _boss_fight
	for cell in fight.struck:
		# La plus ancienne d'abord : le Roi Déchu peut marquer deux fois la même case.
		for zone in _boss_zones:
			if is_instance_valid(zone) and zone.cell == cell and not zone.is_striking():
				zone.strike(fight.linger)
				break
	var at := player.mover.nearest_cell()
	if fight.pattern == "burrow":
		var out := fight.burrow_exit(at)
		if out.x >= 0:
			enemy.mover.teleport_to(out)
			enemy.snap_to_mover()
	var sheltered := teleport_system != null and teleport_system.is_invulnerable(player.mover)
	# Le sol tremble à chaque volée, et plus fort sur le mage : c'est un boss qui frappe.
	_shake(0.22, 0.6 if at in fight.struck else 0.3)
	if at in fight.struck and not sheltered:
		player_caught.emit()
		_push_player(at, fight.push)


## La vague emporte le mage dans son sens, jusqu'à un mur s'il en trouve un.
func _push_player(from: Vector2i, direction: Vector2i) -> void:
	if direction == Vector2i.ZERO:
		return
	var to := from
	for i in BOSS_PUSH_CELLS:
		if not grid.is_floor_v(to + direction):
			break
		to += direction
	player.cancel_path()
	player.mover.teleport_to(to)
	player.snap_to_mover()


func _on_boss_killed() -> void:
	var enemy := enemies[_boss_index]
	_boss_beaten = true
	_boss_fight = null
	_boss_gait = null
	enemy.gait_factor = 1.0
	enemy.gait_hold = false
	enemy.gait_charge = Vector2i.ZERO
	for zone in _boss_zones:
		if is_instance_valid(zone) and not zone.is_striking():
			zone.queue_free()
	_boss_scene = _boss_scene_at(enemy.position)
	_boss_scene.play(_boss_strips["death"], BOSS_DEATH_TIME, BOSS_DEATH_FADE)
	_boss_scene.finished.connect(_on_boss_fallen, CONNECT_ONE_SHOT)
	enemy.set_dead(true)
	house.set_locked(_house_seals())
	enemy_killed.emit()
	boss_defeated.emit()


## Réservé aux outils de développement.
func debug_kill_boss() -> void:
	if boss_is_fighting():
		var enemy := enemies[_boss_index]
		enemy.health.take(Damage.new(enemy.health.current, Element.Kind.SUPREME, "debug"))
		_on_enemy_killed(_boss_index)


## Le mage peut l'avoir abattu depuis le seuil : il n'y entre plus, il y est déjà.
func _on_boss_fallen() -> void:
	_boss_scene.queue_free()
	_boss_scene = null
	# En démo, l'abattre n'est pas une fin : le mage reste sur le terrain.
	if not config.is_demo and player != null and grid.is_house(player.mover.nearest_cell()):
		player_reached_house.emit()


# --- Le Rat, la Gelée et la Vesse ---------------------------------------------------

var _has_thief := false
var _thief_field := PackedInt32Array()
var _spores := SporeClouds.new()
var _spore_nodes: Array[SporeCloud] = []
const STOLEN_GEM_HEIGHT := 1.05
const TINT_SLOWED := Color(0.86, 1.08, 0.62)


## La gemme suit son voleur. Sa `cell` bouge avec lui : tout ce qui la vise la suit donc.
func _update_thieves() -> void:
	if not _has_thief:
		return
	for enemy in enemies:
		if enemy.dead or not enemy.is_thief():
			continue
		var cell := enemy.mover.nearest_cell()
		if enemy.stolen != null:
			enemy.stolen.cell = cell
			enemy.stolen.position = enemy.position \
				+ Vector2.UP * float(TILE_SIZE) * STOLEN_GEM_HEIGHT
		elif not enemy.is_blinded() and not enemy.is_staggered() \
				and CreatureRules.may_steal(grid, _player_field, cell):
			_steal_gem_at(enemy, cell)


func _steal_gem_at(enemy: Enemy, cell: Vector2i) -> void:
	for gem in gems:
		if not is_instance_valid(gem) or gem.carried or gem.cell != cell:
			continue
		gem.carried = true
		enemy.stolen = gem
		enemy.strike()
		_spawn_effect(cell, gem.color())
		_refresh_thief_field()
		gem_stolen.emit()
		return


func _drop_stolen_gem(enemy: Enemy) -> void:
	if enemy.stolen == null:
		return
	var gem := enemy.stolen
	enemy.stolen = null
	gem.carried = false
	gem.cell = enemy.mover.nearest_cell()
	gem.position = maze_renderer.cell_to_world(gem.cell)
	_spawn_effect(gem.cell, gem.color())
	_refresh_thief_field()
	_refresh_objective()


func _refresh_thief_field() -> void:
	if not _has_thief:
		return
	var ground: Array[Vector2i] = []
	for gem in gems:
		if is_instance_valid(gem) and not gem.carried:
			ground.append(gem.cell)
	_thief_field = CreatureRules.stealable_field(grid, ground, _player_field)
	for enemy in enemies:
		if enemy.is_thief():
			enemy.gem_field = _thief_field


## Sa mort lâche ses deux petites, prises dans les places réservées. Rend faux si elles
## sont déjà toutes en jeu : la grande compte alors comme un kill ordinaire.
func _split(enemy: Enemy) -> bool:
	var tuning := Bestiary.of(enemy.species)
	var count := int(tuning.get("splits_count", 0))
	if count <= 0:
		return false
	var waiting: Array[Enemy] = []
	for other in enemies:
		if other.dead and other.species == str(tuning["splits_into"]) and waiting.size() < count:
			waiting.append(other)
	if waiting.is_empty():
		return false
	var cells := CreatureRules.split_cells(grid, enemy.mover.nearest_cell(),
		player.mover.nearest_cell() if player != null else Vector2i(-1, -1), waiting.size())
	for i in cells.size():
		_release_enemy(enemies.find(waiting[i]), cells[i])
	return true


func _update_spores(delta: float, stopped: bool) -> void:
	if player == null:
		return
	if not stopped:
		for enemy in enemies:
			if enemy.dead or not enemy.can_spit() or enemy.is_blinded() or enemy.is_staggered():
				continue
			var cell := enemy.mover.nearest_cell()
			if CreatureRules.in_spit_reach(grid, _player_field, cell, enemy.spit_reach()):
				enemy.spit()
				_spores.spit(CreatureRules.spit_cells(grid, cell, _player_field),
					Bestiary.windup(enemy.species))
		for cell in _spores.advance(delta):
			var cloud := SporeCloud.new()
			# Sous les pieds, comme la marque de marche : entre les gemmes et les acteurs.
			cloud.z_index = 5
			add_child(cloud)
			cloud.setup(maze_renderer.cell_to_world(cell), TILE_SIZE, SporeClouds.DURATION,
				float(cell.x * 13 + cell.y * 7))
			_spore_nodes.append(cloud)
	var factor := _spores.speed_factor(player.mover.nearest_cell())
	var pace := (character.move_speed + combat.armor_speed()) * combat.flight_speed()
	if factor < 1.0 and player.mover.speed >= pace:
		player.set_tint(TINT_SLOWED)
	elif factor >= 1.0 and player.mover.speed < pace and not combat.player_rooted():
		player.set_tint(Color.WHITE)
	player.mover.speed = 0.0 if combat.player_rooted() else pace * factor


## La cible bouge pendant le vol : on lui recolle le dernier point du trajet à
## chaque frame, sinon l'orbe irait exploser là où l'ennemi se tenait au tir.
func _update_orbs() -> void:
	for index in _orbs.keys():
		var orb: MagicOrb = _orbs[index]
		if not is_instance_valid(orb):
			_orbs.erase(index)
			continue
		# Un numéro négatif est un tir libre : il ne suit personne.
		if index >= 0 and index < enemies.size():
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
		player.play_hurt(seconds)
		# Une touche ne coupe pas un séisme en cours.
		if _shake_left <= 0.0:
			_shake_total = HIT_SHAKE_TIME
			_shake_left = HIT_SHAKE_TIME
			_shake_time = 0.0
			_shake_power = HIT_SHAKE_POWER


func try_teleport_player() -> bool:
	if player == null or teleport_system == null:
		return false
	# En vol, il passe au-dessus des portails sans les prendre.
	if combat != null and combat.flying():
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
## Pixels du monde -> coordonnées de l'interface, en 2D comme en volume.
func to_screen(world: Vector2) -> Vector2:
	return world_stage.world_to_screen(world) if world_stage != null \
		else get_canvas_transform() * world


func order_player_walk(screen_point: Vector2) -> bool:
	if player == null or grid == null:
		return false
	var world := world_stage.screen_to_world(screen_point) if world_stage != null \
		else get_canvas_transform().affine_inverse() * screen_point
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
		if enemy.dead or not enemy.uses_portals():
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
## L'onde de choc d'un sort lourd. Elle dit la PUISSANCE là où les particules
## disent la matière — c'est elle qui distingue « ça a explosé » de « ça a
## touché ». Réservée aux sorts qui la demandent : généralisée, elle ne
## signalerait plus rien.
func _spawn_shockwave(cell: Vector2i, ability: Ability) -> void:
	var wave: Shockwave = SHOCKWAVE_SCENE.instantiate()
	entities.add_child(wave)
	wave.position = maze_renderer.cell_to_world(cell)
	var tint := Element.color(ability.element)
	wave.setup(TILE_SIZE, maxf(1.2, ability.radius), Color(1.0, 0.96, 0.82), tint,
		0.40 + 0.05 * ability.radius)


func _spawn_impact(cell: Vector2i, element: Element.Kind, radius: float,
		duration: float = ImpactEffect.DURATION, drawn: Texture2D = null,
		flames: float = 0.0, spin: float = 1.6, painted_key: String = "") -> void:
	# LE VORTEX ROND DE `impact.png` N'EST PLUS JOUÉ pour un mage peint : son
	# explosion en shader prend la place, et l'éclat tracé garde le rayon réel.
	if drawn != null and drawn == _impact_texture and PAINTED_MAGES.has(character.id):
		drawn = null
		# Ni flammes ni fumée d'accompagnement : au-dessus du mage, elles le
		# cachaient, et le dessin peint s'en passe.
		flames = 0.0
		_spawn_painted_burst(cell, radius, duration, painted_key)
		# Ses ronds jaunes cachaient le mage, et l'éclaboussure dit déjà tout.
		if character.id in ["peste", "lumiere", "mort", "etoiles", "acier", "demon", "discorde", "braise", "ecarlate", "geolier", "ciel", "cherubin", "dragon", "croupier", "avide"]:
			return
		# Le Feu n'a plus besoin de l'éclat tracé : ses triangles jaunes flottaient
		# par-dessus les lobes et cassaient leur silhouette.
		if character.id == "fire":
			return
		# Le sceau de l'Invocateur non plus : ses pointes blanches en brouillaient le triangle.
		if character.id == "invocateur":
			return
	elif drawn != null and drawn == _impact_texture and DRAWN_MAGES.has(character.id):
		_spawn_painted_burst(cell, radius, duration)
	var impact: ImpactEffect = IMPACT_EFFECT_SCENE.instantiate()
	entities.add_child(impact)
	impact.position = maze_renderer.cell_to_world(cell)
	# TOUS les effets du mage qui demandaient sa frappe dessinée reçoivent la
	# version ANIMÉE dès qu'elle existe : l'attaque de base, les frappes du
	# Jugement céleste, les relais de la Chaîne. Le test se fait sur la texture
	# demandée plutôt qu'au cas par cas — un seul endroit à tenir.
	var suite: Array[Texture2D] = []
	if drawn != null and drawn == _impact_texture:
		suite = _impact_frames
	impact.setup(TILE_SIZE, element, radius, duration,
		cell.x * 733 + cell.y * 199 + 1, drawn, flames, spin,
		suite, _impact_anchor)


func _spawn_painted_burst(cell: Vector2i, radius: float, duration: float,
		key: String = "") -> PaintedBurst:
	# L'explosion du Feu joue quatre temps : trop courte, on n'en voit que le milieu.
	if key == "" and character.id == "fire" and radius > PaintedBurst.SMALL_HIT_RADIUS:
		duration = maxf(duration, FIRE_BURST_TIME)
	var burst := PaintedBurst.new()
	entities.add_child(burst)
	burst.position = maze_renderer.cell_to_world(cell)
	burst.setup(TILE_SIZE, radius, duration, float(cell.x * 733 + cell.y * 199) * 0.001,
		key if key != "" else str(PaintedFx.IMPACT[character.id]))
	return burst


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
	var cell := _grounded(player.mover.nearest_cell())
	for enemy in enemies:
		enemy.player_cell = cell


func _refresh_ai() -> void:
	if player == null:
		return
	var sources: Array[Vector2i] = [_grounded(player.current_cell())]
	_player_field = Pathfinder.distance_field(grid, sources)
	for enemy in enemies:
		enemy.player_field = _player_field
	_refresh_thief_field()
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
	var delta := get_process_delta_time()
	var touched := false
	_swings.resize(enemies.size())
	for i in enemies.size():
		var enemy := enemies[i]
		if _swings[i] == null:
			_swings[i] = MeleeSwing.new()
		var swing: MeleeSwing = _swings[i]
		# En vol, il est hors d'atteinte : personne ne lève le bras sur lui.
		if enemy.dead or enemy.ranged_only() or enemy.harmless() or enemy.is_staggered() \
				or enemy.is_blinded() or enemy.is_casting() or (combat != null and combat.flying()):
			swing.cancel()
			continue
		var gap := enemy.mover.grid_position().distance_to(player_position)
		# Le coup part au contact, invulnérabilité ou non. Pendant le répit qui
		# suit un coup encaissé, le joueur doit VOIR que l'ennemi le frappe encore :
		# un gobelin collé qui ne fait rien pendant deux secondes se lit comme un
		# bug, pas comme un sursis. Le sursis, lui, reste entier — c'est `sheltered`
		# qui décide des dégâts, pas l'animation.
		match swing.tick(delta, gap, CATCH_DISTANCE, Bestiary.windup(enemy.species),
				enemy.strike_cycle() + SWING_SYNC_MARGIN):
			MeleeSwing.Event.STARTED:
				enemy.strike()
				_foe_charge(enemy)
			MeleeSwing.Event.LANDED:
				touched = true
				_foe_strike(enemy, not sheltered)
			MeleeSwing.Event.MISSED:
				_foe_strike(enemy, false)
	if touched and not sheltered:
		player_caught.emit()
	_check_throws(player_position, sheltered)


## L'armement se voit sur la créature : c'est ce qui laisse le temps de l'esquiver.
func _foe_charge(enemy: Enemy) -> void:
	if FoeStrike.has_style(enemy.species):
		FoeStrike.charge(enemy, enemy.species, Bestiary.windup(enemy.species), TILE_SIZE)


## Le coup, qu'il touche ou non : le joueur doit voir où il est tombé. La caméra ne tremble
## que s'il touche, ou pour un boss, dont chaque coup ébranle le sol.
func _foe_strike(enemy: Enemy, hurts: bool) -> void:
	if not FoeStrike.has_style(enemy.species):
		return
	FoeStrike.strike(entities, enemy.species, enemy.position, enemy.strike_facing(), TILE_SIZE)
	if FoeStrike.is_big(enemy.species):
		var wave: Shockwave = SHOCKWAVE_SCENE.instantiate()
		entities.add_child(wave)
		wave.position = enemy.position + Vector2(enemy.strike_facing()) * float(TILE_SIZE) \
			* FoeStrike.BOSS_REACH + Vector2.UP * float(TILE_SIZE) * FoeStrike.BOSS_BODY_LIFT
		var style: Dictionary = FoeStrike.STYLES[enemy.species]
		wave.setup(TILE_SIZE, 2.4, style["light"], style["mid"], 0.55)
		_shake(0.32, 0.6 if hurts else 0.4)
	elif hurts:
		_shake(0.12, 0.22)


## LES BOULES DE LAVE, côté écran. La RÈGLE, elle, vit dans `ThrowSystem` —
## en RefCounted, pour que la simulation d'équilibrage joue le même jeu que le
## joueur. Ici on ne fait que montrer ce qu'elle décide.
var _throws: ThrowSystem = null
## Le coup en cours de chaque ennemi, au même index que `enemies`.
var _swings: Array[MeleeSwing] = []
## Une image de marge : le prochain coup ne doit pas partir pendant que l'ennemi
## finit son geste, il ne serait pas animé.
const SWING_SYNC_MARGIN := 0.02


func _check_throws(player_position: Vector2, _sheltered: bool) -> void:
	if _throws == null:
		_throws = ThrowSystem.new(grid)
	var shooters: Array = []
	for enemy in enemies:
		if enemy.dead or enemy.throw_range() <= 0 or not enemy.can_strike() or enemy.is_blinded():
			shooters.append({"cell": Vector2i.ZERO, "range": 0})
			continue
		shooters.append({"cell": enemy.mover.nearest_cell(),
			"range": enemy.throw_range(), "reload": enemy.strike_cycle(),
			"sweep": enemy.sweeps(), "arrow": enemy.fires_arrows()})
	var target := Vector2i(roundi(player_position.x), roundi(player_position.y))
	var opened: Array = [] if combat != null and combat.time_stop_left() > 0.0 \
		else _throws.aim(get_process_delta_time(), shooters, target)
	for shot in opened:
		# Le geste part sur l'ennemi qui a tiré : c'est lui qu'on doit voir armer.
		for enemy in enemies:
			if not enemy.dead and enemy.mover.nearest_cell() == shot["from"]:
				enemy.strike()
				break
		# LA RAFALE N'A PAS DE PROJECTILE À DESSINER : ce sont ses impacts, qui
		# se déclenchent case après case, qui la montrent.
		if bool(shot.get("sweep", false)):
			continue
		var ball: ThrownStone = THROWN_SCENE.instantiate()
		entities.add_child(ball)
		if bool(shot.get("arrow", false)):
			ball.setup_arrow(maze_renderer.cell_to_world(shot["from"]),
				maze_renderer.cell_to_world(shot["to"]), TILE_SIZE,
				Color(0.72, 0.4, 1.0), float(shot["flight"]))
			_stones.append({"ball": ball, "cell": shot["to"]})
			continue
		ball.setup(maze_renderer.cell_to_world(shot["from"]),
			maze_renderer.cell_to_world(shot["to"]), _lava_texture(), TILE_SIZE,
			Color(1.0, 0.45, 0.12), 0.6, float(shot["flight"]))
		_stones.append({"ball": ball, "cell": shot["to"]})
		# LA PIERRE ELLE-MÊME PASSE AU ROUGE. La teinte donnée à `setup` ne peint
		# que le halo du shader : le corps restait le caillou brun du Mage de la
		# Terre. De loin on lisait « un rocher » là où il faut lire « de la
		# lave » — et c'est en une fraction de seconde que le joueur décide de
		# sortir de l'axe.
		ball.modulate = Color(1.9, 0.85, 0.45)


## La pierre de la boule de lave, chargée UNE fois et gardée.
##
## ⚠️ ELLE NE VIENT PAS DU MAGE. Le premier jet utilisait `_rock_texture`, qui
## est lue dans le dossier du personnage CHOISI — et seul le Mage de la Terre en
## a une. Avec les sept autres, le golem lançait une boule invisible : le joueur
## perdait un point de vie sans rien voir venir, ce qui est le pire défaut qu'un
## coup puisse avoir.
var _lava_ball: Texture2D = null


func _lava_texture() -> Texture2D:
	if _lava_ball == null:
		_lava_ball = _texture_or_null("res://assets/characters/earth/rock.png")
	if _lava_ball == null:
		_lava_ball = FxTextures.soft_blob()
	return _lava_ball


func _update_lava(delta: float) -> void:
	if _throws == null:
		return
	var sheltered := teleport_system != null and player != null \
		and teleport_system.is_invulnerable(player.mover)
	for cell in _throws.advance(delta, combat):
		if not _throws.quiet_landings.has(cell):
			_spawn_impact(cell, Element.Kind.FIRE, 1.0, 0.55)
		if player == null or sheltered:
			continue
		if ThrowSystem.touches(cell, player.mover.grid_position()):
			player_caught.emit()


## LE TREMBLEMENT DE TERRE, à l'écran.
##
## Amplitude et FRÉQUENCE décroissent ensemble : la première seconde est une
## secousse serrée et violente, la dernière un balancement lourd. Faire décroître
## la seule amplitude donne une vibration régulière qui s'éteint — ça ne se lit
## pas comme un séisme, mais comme un moteur qu'on arrête.
##
## Le décalage est appliqué à la caméra APRÈS le suivi du mage, jamais à sa
## cible : sinon le lissage de la caméra avale la secousse et il ne reste qu'un
## flottement.
var _shake_left := 0.0
var _shake_total := 1.0
var _shake_time := 0.0
## 1 pour le séisme. Le même mécanisme sert au coup encaissé, en bien plus bref :
## à pleine force, chaque touche secouerait l'écran comme un sort de mage de Terre.
var _shake_power := 1.0
const HIT_SHAKE_TIME := 0.2
const HIT_SHAKE_POWER := 0.3


func _on_quake_started(duration: float, _ability: Ability) -> void:
	_shake_total = maxf(0.2, duration)
	_shake_left = _shake_total
	_shake_time = 0.0
	_shake_power = 1.0


func _on_quake_slide(cell: Vector2i, ability: Ability) -> void:
	var slide: RockSlide = SLIDE_SCENE.instantiate()
	entities.add_child(slide)
	slide.position = maze_renderer.cell_to_world(cell)
	# La graine vient de la CASE : deux captures du même séisme donnent le même
	# éboulement, ce qui permet de comparer deux images.
	slide.setup(TILE_SIZE, [_boulder_texture, _rock_texture, _gem_texture],
		_dust_texture, cell.x * 73 + cell.y * 31 + 1)
	_spawn_impact(cell, ability.element, ability.quake_radius, 0.5)
	# ET LA PIERRE JAILLIT : c'est le séisme qui la fait sortir. Les gerbes de
	# la planche animée servent ici comme pour la Faille — une matière ou
	# l'autre selon la case.
	if character.id == EARTH:
		_spawn_painted_burst(cell, ability.quake_radius, 0.7, "earth_quake")
	if _burst_frames.is_empty():
		return
	var matter := "crystal" if (cell.x + cell.y) % 2 == 0 else "stone"
	if not _burst_frames.has(matter):
		matter = _burst_frames.keys()[0]
	var burst: SpikeBurst = BURST_SCENE.instantiate()
	entities.add_child(burst)
	burst.position = maze_renderer.cell_to_world(cell)
	burst.setup(TILE_SIZE, 1.6, _burst_frames[matter])


## Le décalage de secousse du moment, ou zéro hors séisme.
func _shake_offset(delta: float) -> Vector2:
	if _shake_left <= 0.0:
		return Vector2.ZERO
	_shake_left = maxf(0.0, _shake_left - delta)
	_shake_time += delta
	var force := _shake_left / _shake_total
	# La force décroît en CARRÉ : la violence du départ doit s'entendre, et la
	# fin ne doit pas traîner.
	# Mesuré en capture : à 0,55 case le départ donnait quinze pixels de monde,
	# soit une secousse honnête mais pas un séisme. On veut que la première
	# seconde soit désagréable.
	var amplitude := TILE_SIZE * 0.75 * force * force * _shake_power
	var speed := 34.0 * (0.35 + 0.65 * force)
	return Vector2(
		sin(_shake_time * speed) * amplitude,
		cos(_shake_time * speed * 1.37 + 1.1) * amplitude * 0.8)


func _update_camera(snap: bool) -> void:
	if grid == null:
		return
	var maze_px := maze_renderer.maze_pixel_size()
	if world_stage != null:
		var mage := player.position if player != null else maze_px * 0.5
		world_stage.aim(mage, maze_px, overview or player == null, snap,
			_shake_offset(get_process_delta_time()))
		return
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
	# La secousse s'ajoute APRÈS le lissage : voir l'en-tête de `_shake_offset`.
	camera.offset = _shake_offset(get_process_delta_time())


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


func set_character(next: CharacterStats) -> void:
	character = next
	combat.change_form(next)
	player.set_character(next)
	player.mover.speed = next.move_speed
	if is_instance_valid(_prism_aura):
		_prism_aura.queue_free()
		_prism_aura = null
	if next.id == "ael" and next.hero_form == 3:
		_prism_aura = PrismAura.new()
		_prism_aura.tile_size = TILE_SIZE
		player.add_child(_prism_aura)
	if is_instance_valid(_ael_dragon_aura):
		_ael_dragon_aura.queue_free()
		_ael_dragon_aura = null
	if next.id == "ael" and next.hero_form == 4:
		_ael_dragon_aura = DragonAura.new()
		_ael_dragon_aura.tile_size = TILE_SIZE
		player.add_child(_ael_dragon_aura)
	_load_character_fx()

func show_experience(at: Vector2, amount: int) -> void:
	var number: DamageNumber = DAMAGE_NUMBER_SCENE.instantiate()
	entities.add_child(number)
	number.position = at
	number.setup(amount, Color("#b9efff"), TILE_SIZE)
	number.label.text = "+%d XP" % amount

## L'évolution et la transformation d'Aël : une colonne de lumière, des ondes, des rayons. Quand le
## Prisme se dissipe, la lumière retombe en éclats : on voit qu'il redevient lui-même.
func show_evolution() -> void:
	var form := character.hero_form
	var falling := _ael_form_seen > form
	var burst := AscensionBurst.new()
	entities.add_child(burst)
	burst.position = player.position
	burst.setup(TILE_SIZE, AEL_FORM_COLORS[maxi(form, _ael_form_seen)] if falling else _ael_colour(), falling)
	if falling:
		_shake(0.2, 0.5)
	else:
		_shake(0.5, 1.4 if form >= 3 else 1.0)
		# Le Dragon d'or s'éveille ailes ouvertes : elles se déploient et se replient sur lui.
		if form >= 4:
			var wings := BladeStreak.new()
			entities.add_child(wings)
			wings.setup(player.position, player.position, TILE_SIZE, _ael_colour(), player.sprite, player.scale,
				BladeStreak.Style.SOAR)
			_shake(0.8, 2.0)
	_ael_form_seen = form


func show_level_up(rank: int) -> void:
	var number: DamageNumber = DAMAGE_NUMBER_SCENE.instantiate()
	entities.add_child(number)
	number.position = player.position
	number.setup(0, Color("#b9efff"), TILE_SIZE)
	number.label.text = "NIVEAU %d !" % rank


func _ael_comet(from: Vector2i, to: Vector2i) -> void:
	_ael_leap(from, to)
	_ael_blink["comet"] = true
