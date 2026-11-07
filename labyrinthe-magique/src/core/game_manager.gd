class_name GameManager
extends Node

## Machine à états du jeu et chef d'orchestre.
##
## Le Level rapporte des FAITS (« le joueur est entré dans la maison », « un
## ennemi est tombé »), le GameManager décide ce que ça VEUT DIRE, et
## l'UIManager l'affiche. Aucune des trois couches ne connaît l'intérieur des
## deux autres : le GameManager ne touche jamais un Label, l'UI ne connaît pas
## les règles, et le Level ignore ce qu'est une victoire.

enum State { PLAYING, PAUSED, VICTORY, DEFEAT }

## Slot du portail dans la barre d'action : il ne vient pas du personnage, c'est
## une mécanique du labyrinthe et non un sort.
const SLOT_PORTAL := -1
const SLOT_ATTACK := 0
## 1 à 3 : les sorts, tous disponibles dès le départ.
const SLOT_ESCAPE := 4
const SLOT_ULTIMATE := 5
## Le bouton dédié à la Transformation d'Aël, hors de l'éventail (`TransformButton`, touche T).
const SLOT_TRANSFORM := 6

signal state_changed(state: State)
signal level_started(config: LevelConfig, index: int)
## Le joueur veut revenir à l'accueil. Le GameManager ne sait pas ce qu'est un
## menu : il rapporte l'intention, le GameFlow s'en occupe.
signal menu_requested

## Répit accordé après un coup encaissé. À 1,4 s, l'ennemi qui venait de toucher
## le mage était encore collé à lui quand le répit s'achevait, et reprenait le
## point de vie suivant dans la foulée : trois vies n'en valaient qu'une.
## 2,2 s à 5 cases/s, c'est une intersection d'avance — de quoi vraiment fuir.
const HIT_INVULNERABILITY := 2.2

@onready var level: Level = $Level
@onready var ui: UIManager = $UI
@onready var dev_tools: Node = $DevTools

var levels: Array[LevelConfig] = []
var level_index := 0
var state: State = State.PLAYING
var elapsed := 0.0
## Personnage choisi. L'écran de sélection le posera ici ; en attendant, c'est
## le Mage Arcane — celui sur lequel tout l'équilibrage a été mesuré.
var character_id := CharacterCatalog.default_id()
var character: CharacterStats = null
var kills: KillSystem = null
## Le carnet de quête du niveau en cours. Reconstruit à chaque `start_level` —
## il ne porte que la config, il n'a donc rien à garder d'un niveau à l'autre.
var quest: QuestBook = null
## Sorts et stages acquis. Chargé une fois, sauvegardé à chaque déblocage.
var progress: Progress = null
## Graine imposée par la ligne de commande (0 = aléatoire). Sert à reproduire
## exactement un niveau, pour un rapport de bug ou une capture comparable.
var forced_seed := 0
## Niveau de départ, en index plat. Renseigné par la sélection de stage AVANT
## l'entrée dans l'arbre : `_ready` démarre immédiatement une partie.
var start_index := 0
## Mode démo : tout débloqué, rien de sauvegardé. Posé par le GameFlow AVANT
## l'entrée dans l'arbre.
var demo := false
## Forme choisie pour l’essai. -1 : déduite du niveau de développement.
var demo_hero_form := -1
var hero_progress: HeroProgress = null
var hero: HeroRuntime = null
## L'ÉVEIL d'un mage (2026-11-07), s'il en a un : le même bouton et la même touche que la
## transformation d'Aël. Nul pour Aël et pour les mages qui n'ont pas encore le leur.
var awakening: Awakening = null


func _ready() -> void:
	# Le GameManager et l'UI continuent de tourner quand l'arbre est en pause —
	# c'est ce qui permet à la pause et aux écrans de fin de rester réactifs.
	process_mode = Node.PROCESS_MODE_ALWAYS

	if WorldStage.requested():
		var world := WorldStage.new()
		add_child(world)
		world.adopt(level)
		level.world_stage = world

	var development := development_run()
	if hero_progress == null:
		hero_progress = HeroProgress.load_saved() if not demo and not development else HeroProgress.new()
	if demo or development:
		hero_progress.persistent = false
	if demo:
		# Progression FICTIVE, tout ouvert — et incapable d'écrire sur le
		# disque : un essai ne doit jamais toucher la partie du joueur.
		progress = Progress.everything()
		# Les dix stages, en terrain d'essai : la démo sert autant à essayer un
		# mage qu'à REGARDER un décor. On les prépare tous, le joueur passe de
		# l'un à l'autre sans repasser par le menu.
		levels = []
		for stage in range(1, LevelConfig.STAGE_COUNT + 1):
			levels.append(LevelConfig.demo(stage))
	else:
		progress = Progress.load_saved()
		if development:
			progress.persistent = false
		levels = LevelConfig.all_levels()
	level.player_reached_house.connect(_on_player_reached_house)
	level.player_caught.connect(on_player_caught)
	level.player_teleported.connect(_on_player_teleported)
	level.gem_collected.connect(_on_gem_collected)
	level.all_gems_collected.connect(_on_all_gems_collected)
	level.potion_collected.connect(_on_potion_collected)
	level.enemy_killed.connect(_on_enemy_killed)
	level.enemy_defeated.connect(_on_enemy_defeated)
	level.boss_appeared.connect(func(name: String) -> void:
		ui.flash("%s surgit !" % name, Color("#ff9a7a")))
	level.boss_defeated.connect(_on_boss_defeated)
	level.gem_stolen.connect(func() -> void:
		ui.flash("Un rat a volé une gemme !", Color("#ffd15a")))
	level.ability_refused.connect(_on_ability_refused)
	level.lair_destroyed.connect(_on_lair_destroyed)
	level.player_shielded.connect(func(amount: int) -> void:
		ui.set_shield(amount, amount)
		if amount > 0:
			ui.flash("%s — %d absorbés" % [_shield_name(), amount], Color("#9ef0ff")))
	level.player_empowered.connect(func(bonus: int, duration: float) -> void:
		ui.flash("EXALTÉ — +%d dégâts pendant %.0f s" % [bonus, duration],
			Color("#9ef0ff")))
	level.player_calmed.connect(func() -> void:
		ui.flash("L'exaltation retombe", Color("#7b8bb0")))

	ui.resume_requested.connect(resume)
	ui.restart_requested.connect(restart)
	ui.next_requested.connect(next_level)
	ui.pause_requested.connect(toggle_pause)
	ui.quest_requested.connect(toggle_quest)
	ui.action_requested.connect(use_slot)
	ui.menu_requested.connect(func() -> void: menu_requested.emit())

	if demo:
		# La barre de visite est branchée AVANT le premier niveau : `set_level`
		# y écrit le nom du décor, elle doit donc déjà exister.
		ui.show_demo_bar(demo_stage, demo_call_boss)
		if character_id == "ael":
			ui.show_demo_hero(demo_form)
	start_level(start_index)
	# Appelé explicitement : les _ready() des enfants s'exécutent AVANT celui du
	# parent, DevTools ne peut donc pas s'initialiser tout seul.
	dev_tools.apply_command_line()


# --- Cycle de vie ---------------------------------------------------------------

func start_level(index: int) -> void:
	if hero != null:
		hero.dispose()
	if awakening != null:
		awakening.dispose()
	awakening = null
	level_index = clampi(index, 0, levels.size() - 1)
	var config := levels[level_index]
	character = HeroCatalog.at_level(hero_progress.level()) if character_id == "ael" else CharacterCatalog.by_id(character_id)
	hero = null
	elapsed = 0.0

	# Le compteur d'ultime repart à chaque niveau : un pouvoir gardé d'un stage
	# à l'autre viderait le premier quart du suivant de toute tension.
	kills = KillSystem.new(character.ultimate_required_kills)
	kills.ultimate_ready.connect(_on_ultimate_ready)

	ui.hide_result()
	# ⚠️ LE CARNET SE FERME AU DÉPART D'UN NIVEAU. Sans ça il reste ouvert sur
	# la mission du PRÉCÉDENT : mesuré avec `--stage 3 --episode 2`, où DevTools
	# relance le niveau après le premier départ — la page annonçait encore
	# « Chapitre 1 · La Forêt » par-dessus les Dunes de Feu.
	ui.hide_quest()
	_set_state(State.PLAYING)
	level.progress = progress
	level.load_level(config, character, forced_seed)
	level.player_health.died.connect(_on_player_died)
	# Les soins et les pactes changent les PV hors de tout coup reçu.
	level.player_health.healed.connect(_on_player_health_changed)
	level.player_health.damaged.connect(_on_player_health_changed)
	if character_id == "ael":
		hero = HeroRuntime.new(hero_progress, level.combat)
		hero.character_changed.connect(_on_hero_changed)
		hero.progressed.connect(_on_hero_progressed)
		character = level.combat.stats
		level.set_character(character)

	if demo:
		level.player_health.minimum_current = 1

	# LE CARNET DE QUÊTE du niveau. Reconstruit à chaque départ : il ne porte que
	# la config, et une config recyclée d'un niveau à l'autre mentirait.
	quest = QuestBook.new(config)
	ui.set_quest_available(not config.is_demo)

	if hero == null and CharacterCatalog.awakening_of(character_id) != null:
		awakening = Awakening.new(character, CharacterCatalog.awakening_of(character_id), level.combat,
			level.combat_context)
		awakening.form_changed.connect(_on_awakening_form)
		awakening.changed.connect(_on_awakening_state)
		awakening.reborn.connect(_on_awakening_reborn)
		awakening.shell_formed.connect(level.show_shell_formed)
		awakening.shell_broken.connect(level.show_shell_broken)

	ui.set_character(character)
	ui.set_hero_progress(hero_progress if hero != null else null)
	if hero == null:
		ui.set_transform_state(false, {})
	ui.set_level(config, level_index + 1)
	ui.set_health(level.player_health.current, level.player_health.maximum)
	ui.set_shield(0)
	ui.hide_boss()
	ui.set_gems(level.missing_gem_colors(), level.gems_total)
	ui.set_counters(0)
	ui.set_kills(0, character.ultimate_required_kills, false)
	if demo:
		# L'ultime arrive CHARGÉ : la page d'essai sert à voir les sorts, pas à
		# les mériter — les kills du joueur, eux, se gagnent en campagne.
		kills.fill()
		ui.set_kills(kills.progress, character.ultimate_required_kills, kills.available())
		ui.flash("MODE DÉMO — sorts illimités, sans recharge", Color("#9fe8b4"))
	# LE CARNET S'OUVRE TOUT SEUL LA PREMIÈRE FOIS qu'on entre dans un épisode,
	# et une seule : un briefing qu'on doit refermer à chaque essai devient un
	# obstacle entre le joueur et sa partie. Le « déjà vu » vit dans Settings et
	# non dans Progress — c'est une commodité d'affichage, pas un acquis, et
	# Progress refuse d'écrire hors d'une sauvegarde chargée.
	if not config.is_demo and not Settings.quest_seen(config.stage, config.episode):
		Settings.mark_quest_seen(config.stage, config.episode)
		toggle_quest()
	if demo and hero != null and demo_hero_form >= 3:
		hero.transformation.begin(hero_progress.level(), demo_hero_form == 4)
	level_started.emit(config, level_index)


## Le niveau en cours. Raccourci : le GameManager le lit à plusieurs endroits et
## `levels[level_index]` répété masque ce qu'on cherche.
func config_of_level() -> LevelConfig:
	return levels[level_index]


func restart() -> void:
	start_level(level_index)


func next_level() -> void:
	# Dernier stage : on reboucle, en attendant les niveaux suivants.
	start_level(level_index + 1 if level_index + 1 < levels.size() else 0)


func resume() -> void:
	if state == State.PAUSED:
		ui.hide_result()
		ui.hide_quest()
		_set_state(State.PLAYING)


func toggle_pause() -> void:
	# Le carnet ouvert, le bouton de pause le REFERME au lieu d'empiler un
	# second écran par-dessus. Deux panneaux superposés dont un seul répond aux
	# clics est un bug que le joueur lit comme un jeu figé.
	if ui.quest_visible():
		resume()
		return
	if state == State.PLAYING:
		_set_state(State.PAUSED)
		ui.show_pause(levels[level_index], character)
	elif state == State.PAUSED:
		resume()


## LE CARNET MET LE JEU EN PAUSE, et ce n'est pas une facilité d'implémentation :
## lire sa mission pendant qu'un spectre vous court après n'est pas un choix,
## c'est une punition. Il réutilise l'état PAUSED plutôt que d'en inventer un —
## un troisième état voudrait dire trois transitions à tenir dans `_set_state`.
func toggle_quest() -> void:
	if ui.quest_visible():
		resume()
		return
	if state != State.PLAYING or quest == null:
		return
	_set_state(State.PAUSED)
	ui.show_quest(quest, level.gems_taken, level.lairs_remaining(), level.house_is_open())


# --- Règles ---------------------------------------------------------------------

func _on_player_reached_house() -> void:
	if state != State.PLAYING:
		return
	# La maison n'est plus une ligne d'arrivée mais une SERRURE : sans toutes les
	# gemmes, la porte reste scellée et le mage repart. C'est la seule règle de
	# victoire du jeu, et elle tient en une condition.
	if level.boss_is_due():
		level.summon_boss()
		return
	if not level.house_is_open():
		if level.boss_guards_door():
			ui.flash("Porte scellée — abats %s" % level.boss_name(), Color("#ff9a7a"))
			return
		var gems_left := level.gems_remaining()
		var lairs_left := level.lairs_remaining()
		if gems_left > 0:
			ui.flash("Porte scellée — il manque %d gemme%s" %
				[gems_left, "s" if gems_left > 1 else ""], Color("#9fb4e8"))
		else:
			ui.flash("Porte scellée — %d repaire%s tient%s encore" %
				[lairs_left, "s" if lairs_left > 1 else "", "" if lairs_left > 1 else "t"],
				Color("#9fb4e8"))
		return
	_set_state(State.VICTORY)
	progress.reach(config_of_level().stage, config_of_level().episode)
	if hero != null and not demo:
		hero.victory(config_of_level().stage, config_of_level().episode)
	ui.show_victory(elapsed, level.teleport_count, level.gems_total, kills.kills,
		level_index + 1 < levels.size())


## Un ennemi a touché le mage. Le contact coûte UN point de vie, quelle que soit
## l'espèce : la difficulté d'un stage se règle par le nombre de poursuivants et
## par les points de vie du mage, pas par des dégâts variables au corps à corps
## — un coup qui tue en deux fois moins de temps sans prévenir n'est pas lisible.
func on_player_caught() -> void:
	if state != State.PLAYING:
		return
	level.player_health.take(Damage.new(1, Element.Kind.SHADOW, "enemy"))
	ui.set_health(level.player_health.current, level.player_health.maximum)
	# Le coup a pu être encaissé par la coque : on remet l'absorption à jour
	# tout de suite, sinon la barre montrerait un bouclier déjà consommé.
	if level.combat != null:
		ui.set_shield(level.combat.shield_left())
	if level.player_health.is_alive():
		level.grant_player_invulnerability(HIT_INVULNERABILITY)
		ui.flash("Touché !", Color("#e05c4a"))


func _on_player_died() -> void:
	if state != State.PLAYING:
		return
	_set_state(State.DEFEAT)
	ui.show_defeat(elapsed, level.teleport_count, level.gems_taken, kills.kills)


func _set_state(new_state: State) -> void:
	state = new_state
	get_tree().paused = state != State.PLAYING
	state_changed.emit(state)


# --- Boucle et entrées -----------------------------------------------------------

func _process(delta: float) -> void:
	if state != State.PLAYING or level.player == null:
		return
	elapsed += delta
	if hero != null:
		hero.update(delta)
		ui.set_hero_progress(hero_progress, hero.transformation)
		ui.set_transform_state(hero_progress.level() >= 30, {"ratio": 1.0 if demo else hero.charge_ratio(),
			"ready": hero.can_transform(demo), "state": hero.transformation.state,
			"seconds": hero.transformation.left, "dragon": hero.next_is_dragon()})
		if demo:
			ui.set_demo_hero_state(3 if hero.transformation.state == Transformation.State.CHARGING else character.hero_form, hero_progress.level())
	if awakening != null:
		awakening.update(delta)
		ui.set_transform_state(true, _awakening_info())
	# Le joueur est recréé à chaque chargement : on relie ici plutôt que par
	# signal, pour ne pas avoir à gérer les reconnexions.
	level.player.touch_direction = ui.touch_direction()
	ui.set_counters(level.teleport_count)
	ui.set_action_state(_action_state())
	if ui.touch_mode:
		ui.show_beneath_controls(_watched_things())
	if level.boss_is_fighting():
		ui.show_boss(level.boss_name(), level.boss_health_ratio())
	if demo:
		ui.set_demo_boss_available(level.boss_can_be_called())


## Décrit la barre d'action complète pour l'interface : ce qui est prêt, ce qui
## recharge, ce qui manque de mana, et l'ultime verrouillé tant que les kills
## n'y sont pas.
func _action_state() -> Dictionary:
	var entries: Array[Dictionary] = []
	var bar := level.action_bar()
	for slot in bar.size():
		var ability: Ability = bar[slot]
		var is_ultimate := slot == SLOT_ULTIMATE
		var ready := level.can_use(slot) and (not is_ultimate or kills.available())
		ready = ready and (hero == null or hero.can_act()) and (awakening == null or awakening.can_act())
		if ability.kind == Ability.Kind.HERO_TRANSFORM:
			ready = ready and level.combat.hero_transform_allowed
		var ratio := level.combat.cooldown_ratio(ability)
		if is_ultimate:
			ratio = kills.ratio()
		# Le bouton principal sert de portail quand le mage est dessus : les
		# deux gestes ne se chevauchent jamais, un seul bouton suffit.
		var slot_id := slot
		var color := Element.color(ability.element)
		if slot == SLOT_ATTACK and level.player_can_teleport():
			slot_id = SLOT_PORTAL
			color = Color("#9ef0ff")
			ready = true
			ratio = 1.0
		entries.append({
			"slot": slot_id, "color": color, "ready": ready, "ratio": ratio,
			# Le nom sert à la barre du clavier : c'est lui qui apprend au joueur
			# ce que fait la touche. Le pad tactile l'ignore, faute de place.
			"name": ability.display_name,
			# -1 quand le sort n'a pas de charges : l'interface n'affiche
			# alors rien plutôt qu'un « 1/1 » qui n'apprend rien.
			# L'icône est cherchée par l'IDENTIFIANT du sort : un mage sans
			# planche d'icônes garde les pastilles colorées d'avant, sans que
			# rien n'ait à le savoir.
			"icon": UiIcons.for_ability(character.id, ability.id),
			"charges": level.combat.charges_left(ability) if level.combat != null else -1,
			"charges_max": ability.charges,
			"locked": is_ultimate and not kills.available(),
			"highlight": is_ultimate,
		})
	return {
		"entries": entries,
		"can_teleport": level.player_can_teleport(),
		"teleport_ratio": _teleport_ratio(),
		"on_portal": level.player_on_portal(),
		"gamble": level.player_teleport_is_gamble(),
		"can_attack": level.can_use(SLOT_ATTACK) and level.has_target(SLOT_ATTACK),
		"ultimate_ready": kills.available(),
	}


## 0 = vient de se téléporter, 1 = portail à nouveau disponible.
func _teleport_ratio() -> float:
	var left := level.player_teleport_cooldown()
	if left <= 0.0:
		return 1.0
	return clampf(1.0 - left / TeleportSystem.COOLDOWN, 0.0, 1.0)


## Stage suivant ou précédent, en démo seulement. Le tour est CYCLIQUE : arrivé
## au dixième on revient au premier, ce qui évite un bouton qui ne répond plus.
func demo_stage(step: int) -> void:
	if not demo or levels.size() < 2:
		return
	get_tree().paused = false
	start_level(posmod(level_index + step, levels.size()))


## Le boss du décor visité, en démo seulement.
func demo_call_boss() -> void:
	if demo and state == State.PLAYING:
		level.call_boss()


func _unhandled_input(event: InputEvent) -> void:
	# Mode « toucher le chemin » : un tap sur le labyrinthe est un ordre de
	# marche. Le pad de combat et le bouton de pause lisent leurs touches sans
	# les consommer, on écarte donc d'abord tout tap qui leur appartient.
	if event is InputEventScreenTouch and event.pressed \
			and state == State.PLAYING and ui.tap_move_active() \
			and not ui.touch_reserved(event.position):
		level.order_player_walk(event.position)
		return
	# Page précédente / suivante : le tour des décors au clavier. Elles ne
	# servent à rien hors démo, `demo_stage` s'en assure.
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_T and (hero != null or awakening != null):
			use_slot(SLOT_TRANSFORM)
			return
		if event.keycode == KEY_PAGEDOWN or event.keycode == KEY_BRACKETRIGHT:
			demo_stage(1)
			return
		if event.keycode == KEY_PAGEUP or event.keycode == KEY_BRACKETLEFT:
			demo_stage(-1)
			return
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart"):
		restart()
	elif event.is_action_pressed("teleport"):
		use_slot(SLOT_PORTAL if level.player_can_teleport() else SLOT_ATTACK)
	elif event.is_action_pressed("skill_1"):
		use_slot(1)
	elif event.is_action_pressed("skill_2"):
		use_slot(2)
	elif event.is_action_pressed("skill_3"):
		use_slot(3)
	elif event.is_action_pressed("escape_skill"):
		use_slot(SLOT_ESCAPE)
	elif event.is_action_pressed("ultimate"):
		use_slot(SLOT_ULTIMATE)


## Point d'entrée unique des gestes du joueur, clavier comme tactile.
func use_slot(slot: int) -> void:
	if state != State.PLAYING or (hero != null and not hero.can_act()) \
			or (awakening != null and not awakening.can_act()):
		return
	if slot == SLOT_PORTAL:
		level.try_teleport_player()
		return
	if slot == SLOT_TRANSFORM and awakening != null:
		# Rappuyer pendant l'Éveil le quitte : le joueur garde la main sur sa minute.
		if awakening.awake():
			awakening.finish()
		elif awakening.begin(demo):
			level.show_awakening_charge()
			var awakening_tint := Color("#55ddeb") if character_id == CharacterCatalog.WATER else Color("#ffb347")
			ui.flash("ÉVEIL : %s !" % awakening.awakened.display_name.to_upper(), awakening_tint)
		return
	if slot == SLOT_TRANSFORM:
		var dragon := hero != null and hero.next_is_dragon()
		if hero != null and hero.transform(demo):
			level.show_transformation_charge()
			ui.flash("ÉVEIL DU DRAGON !" if dragon else "TRANSFORMATION !", Color("#ffd15a"))
		return
	if slot == SLOT_ULTIMATE:
		if hero != null and hero.transformation.state == Transformation.State.EXHAUSTED:
			return
		if not kills.available():
			ui.flash("Extra Hit verrouillé — encore %d kills, ou une potion" % maxi(0,
				kills.needed - kills.progress), Color("#7b8bb0"))
			return
		# L'ultime n'est dépensé QUE s'il est réellement parti : un ultime perdu
		# parce qu'aucun ennemi n'était à portée serait une punition absurde.
		# En DÉMO il ne se dépense pas du tout — il est là pour être regardé.
		# LE PRISME ULTIME NE MET PLUS FIN À LA FORME (2026-11-04) : le joueur ne comprenait pas pourquoi
		# son Extra le détransformait. Le Prisme se dissipe quand sa jauge est vide, ou à 1 PV.
		var title := level.ability_at(slot).display_name
		if level.use_ability(slot):
			if not demo:
				kills.spend()
			ui.set_kills(kills.progress, kills.needed, demo)
			ui.flash("%s !" % title, Color("#ffd15a"))
		return
	level.use_ability(slot)


func _on_player_health_changed(_amount: int, _remaining: int) -> void:
	ui.set_health(level.player_health.current, level.player_health.maximum)


## Le nom du sort qui protège, pour le message : « Bouclier d'eau » valait pour tous avant le Dragon.
func _shield_name() -> String:
	if level != null and level.character != null:
		for ability: Ability in level.character.abilities:
			if ability.kind == Ability.Kind.MAGMA_SCALES or (ability.kind == Ability.Kind.SHIELD and not ability.immune):
				return ability.display_name
	return "Bouclier"


func _on_ability_refused(reason: String) -> void:
	match reason:
		"pacte":
			ui.flash("Le pacte ne prend pas ton dernier souffle", Color("#ff6b82"))
		"cible":
			ui.flash("Aucun ennemi à portée", Color("#7b8bb0"))
		"place":
			ui.flash("Pas de place pour ça ici", Color("#7b8bb0"))
		"sain":
			ui.flash("Aucun ennemi empoisonné à portée", Color("#7b8bb0"))
		"pleine":
			ui.flash("Déjà en pleine santé", Color("#7b8bb0"))
		"immobile":
			ui.flash("Aucune trace : marche d'abord", Color("#7b8bb0"))


# --- Progression -----------------------------------------------------------------

func _on_enemy_killed() -> void:
	if hero != null:
		hero.kill()
	if awakening != null:
		awakening.kill()
	kills.register_kill()
	ui.set_kills(kills.progress, kills.needed, kills.available())
	if not kills.available():
		ui.flash("EXTRA : %d / %d" % [kills.progress, kills.needed], Color("#c9a8ff"))


func _on_ultimate_ready() -> void:
	ui.flash("EXTRA POWER PRÊT !", Color("#ffd15a"))


func _on_gem_collected(collected: int, total: int) -> void:
	if hero != null and not demo:
		hero.gain(5)
	ui.set_gems(level.missing_gem_colors(), total)
	if collected < total:
		ui.flash("Gemme %d/%d" % [collected, total], Color("#9ef0ff"))


func _on_all_gems_collected() -> void:
	# Les gemmes ne suffisent plus quand les repaires font partie de l'objectif :
	# annoncer une porte ouverte qui ne l'est pas serait un mensonge d'interface.
	if level.lairs_remaining() > 0:
		ui.flash("Gemmes réunies — abattez encore %d repaire%s" %
			[level.lairs_remaining(), "s" if level.lairs_remaining() > 1 else ""],
			Color("#ff9a7a"))
		return
	if level.boss_guards_door():
		ui.flash("Retourne à la maison : %s t'y attend" % level.boss_name(), Color("#ff9a7a"))
		return
	ui.flash("La porte de la maison s'ouvre !", Color("#ffd479"))


func _on_boss_defeated() -> void:
	ui.hide_boss()
	var opens := "" if demo else " — la porte s'ouvre !"
	ui.flash("%s est vaincu%s" % [level.boss_name(), opens], Color("#ffd479"))


func _on_lair_destroyed(remaining: int) -> void:
	if remaining > 0:
		ui.flash("Repaire détruit — il en reste %d" % remaining, Color("#ffd479"))
	elif level.gems_remaining() > 0:
		ui.flash("Les repaires sont à terre — plus aucun ennemi ne reviendra",
			Color("#ffd479"))
	elif level.boss_guards_door():
		ui.flash("Retourne à la maison : %s t'y attend" % level.boss_name(), Color("#ff9a7a"))
	else:
		ui.flash("La porte de la maison s'ouvre !", Color("#ffd479"))


func _on_potion_collected() -> void:
	if not kills.drink_potion():
		ui.flash("Extra Power déjà prêt", Color("#7b8bb0"))
		return
	ui.set_kills(kills.progress, kills.needed, kills.available())
	if not kills.available():
		ui.flash("Potion — EXTRA : %d / %d" % [kills.progress, kills.needed], Color("#c9a8ff"))


func _on_player_teleported(advantageous: bool) -> void:
	# Retour immédiat sur le résultat du pari : c'est toute la mécanique du jeu.
	if advantageous:
		ui.flash("Le portail te rapproche !", Color("#8fe6ff"))
	else:
		ui.flash("Le portail t'éloigne…", Color("#e0a05c"))


func _on_enemy_defeated(species: String, boss: bool, at: Vector2) -> void:
	if hero != null and not demo:
		var amount := hero.defeat(species, boss)
		level.show_experience(at, amount)

func _on_hero_changed(next: CharacterStats) -> void:
	var before := character.hero_form
	character = next
	level.set_character(next)
	ui.set_character(next)
	# Changer de seuil conserve la fraction chargée ; revenir de Prisme vide la jauge.
	var charge := kills.ratio()
	kills.needed = next.ultimate_required_kills
	kills.progress = kills.needed if kills.charged else mini(kills.needed - 1, roundi(charge * kills.needed))
	if next.hero_form >= 3:
		kills.charged = true
	elif before >= 3:
		kills.spend()
	if demo:
		kills.fill()
		level.player_health.minimum_current = 1
	if next.hero_form != before:
		level.show_evolution()
		level.grant_player_invulnerability(0.8 if next.hero_form >= 3 else 1.5)
		ui.flash(next.display_name, Color("#b9efff"))
	ui.set_health(level.player_health.current, level.player_health.maximum)
	ui.set_kills(kills.progress, kills.needed, kills.available())

## Ce que le joueur ne doit pas perdre de vue, en coordonnées d'interface.
func _watched_things() -> Array[Dictionary]:
	var things: Array[Dictionary] = []
	for gem in level.gems:
		if is_instance_valid(gem) and not gem.carried:
			things.append({"at": level.to_screen(gem.position), "color": gem.tint})
	for potion in level.potions:
		if is_instance_valid(potion):
			things.append({"at": level.to_screen(potion.position), "color": Potion.TINT})
	for enemy in level.enemies:
		if is_instance_valid(enemy) and not enemy.dead:
			things.append({"at": level.to_screen(enemy.position), "color": Color("#ff5a4a")})
	return things


func _on_hero_progressed(_amount: int, levels_gained: int) -> void:
	ui.set_hero_progress(hero_progress)
	# Gagné avec la victoire, le niveau s'annonce sur son écran : `UIManager.show_victory`.
	if levels_gained > 0 and state != State.VICTORY:
		level.show_level_up(hero_progress.level())
		ui.flash("NIVEAU %d !" % hero_progress.level(), Color("#b9efff"))

func _exit_tree() -> void:
	if hero != null:
		hero.dispose()
	if awakening != null:
		awakening.dispose()


# --- L'Éveil des mages -------------------------------------------------------------

## Ce que montre le bouton : il reprend celui d'Aël, avec ses mots et sa minute.
func _awakening_info() -> Dictionary:
	var shown := Transformation.State.NORMAL
	match awakening.state:
		Awakening.State.CHARGING:
			shown = Transformation.State.CHARGING
		Awakening.State.AWAKE:
			shown = Transformation.State.PRISM
		Awakening.State.EXHAUSTED:
			shown = Transformation.State.EXHAUSTED
	return {"ratio": 1.0 if demo else awakening.charge_ratio(), "ready": awakening.can_begin(demo),
		"state": shown, "seconds": awakening.left, "max_seconds": Awakening.DURATION,
		"label_on": awakening.awakened.display_name.to_upper(), "label_ready": "ÉVEIL",
		"symbol": "water" if awakening.base.id == CharacterCatalog.WATER else "flame"}


func _on_awakening_form(next: CharacterStats) -> void:
	character = next
	level.set_character(next)
	ui.set_character(next)
	ui.set_health(level.player_health.current, level.player_health.maximum)
	ui.set_kills(kills.progress, kills.needed, kills.available())


func _on_awakening_state(next: Awakening.State) -> void:
	match next:
		Awakening.State.AWAKE:
			level.show_awakening()
		Awakening.State.EXHAUSTED:
			level.end_awakening()
			ui.flash("Épuisé", Color("#9a7b6a"))


func _on_awakening_reborn() -> void:
	level.show_rebirth()
	ui.flash("RENAISSANCE !", Color("#ffd27a"))
	ui.set_health(level.player_health.current, level.player_health.maximum)


static func development_run() -> bool:
	var args := OS.get_cmdline_args()
	return not OS.get_cmdline_user_args().is_empty() or "--script" in args or "-s" in args or "--headless" in args


## Le choix d’une forme est un outil de démo, jamais une modification de sauvegarde.
func demo_form(form: int) -> void:
	if not demo or character_id != "ael" or form < 0 or form >= CharacterCatalog.AEL_FORMS.size():
		return
	demo_hero_form = form
	hero_progress = HeroProgress.new()
	hero_progress.xp = HeroProgress.threshold(int(CharacterCatalog.AEL_FORM_LEVELS[form]))
	get_tree().paused = false
	start_level(level_index)
	ui.set_demo_hero_state(form, hero_progress.level())
