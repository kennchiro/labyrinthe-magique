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
## 1 à 3 : les sorts, débloqués un par un par les potions.
const SLOT_ESCAPE := 4
const SLOT_ULTIMATE := 5

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


func _ready() -> void:
	# Le GameManager et l'UI continuent de tourner quand l'arbre est en pause —
	# c'est ce qui permet à la pause et aux écrans de fin de rester réactifs.
	process_mode = Node.PROCESS_MODE_ALWAYS

	if demo:
		# Progression FICTIVE, tout ouvert — et incapable d'écrire sur le
		# disque : un essai ne doit jamais toucher la partie du joueur.
		progress = Progress.everything(3)
		# Les dix stages, en terrain d'essai : la démo sert autant à essayer un
		# mage qu'à REGARDER un décor. On les prépare tous, le joueur passe de
		# l'un à l'autre sans repasser par le menu.
		levels = []
		for stage in range(1, LevelConfig.STAGE_COUNT + 1):
			levels.append(LevelConfig.demo(stage))
	else:
		progress = Progress.load_saved()
		levels = LevelConfig.all_levels()
	level.player_reached_house.connect(_on_player_reached_house)
	level.player_caught.connect(on_player_caught)
	level.player_teleported.connect(_on_player_teleported)
	level.gem_collected.connect(_on_gem_collected)
	level.all_gems_collected.connect(_on_all_gems_collected)
	level.potion_collected.connect(_on_potion_collected)
	level.enemy_killed.connect(_on_enemy_killed)
	level.ability_refused.connect(_on_ability_refused)
	level.lair_destroyed.connect(_on_lair_destroyed)
	level.player_shielded.connect(func(amount: int) -> void:
		ui.set_shield(amount, amount)
		if amount > 0:
			ui.flash("Bouclier d'eau — %d absorbés" % amount, Color("#9ef0ff")))
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
		ui.show_demo_bar(demo_stage)
	start_level(start_index)
	# Appelé explicitement : les _ready() des enfants s'exécutent AVANT celui du
	# parent, DevTools ne peut donc pas s'initialiser tout seul.
	dev_tools.apply_command_line()


# --- Cycle de vie ---------------------------------------------------------------

func start_level(index: int) -> void:
	level_index = clampi(index, 0, levels.size() - 1)
	var config := levels[level_index]
	character = CharacterCatalog.by_id(character_id)
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

	# LE CARNET DE QUÊTE du niveau. Reconstruit à chaque départ : il ne porte que
	# la config, et une config recyclée d'un niveau à l'autre mentirait.
	quest = QuestBook.new(config)
	ui.set_quest_available(not config.is_demo)

	ui.set_character(character)
	ui.set_level(config, level_index + 1)
	ui.set_health(level.player_health.current, level.player_health.maximum)
	ui.set_shield(0)
	ui.set_gems(level.missing_gem_colors(), level.gems_total)
	ui.set_counters(0, progress.unlocked_skills)
	ui.set_kills(0, character.ultimate_required_kills, false)
	if demo:
		# L'ultime arrive CHARGÉ : la page d'essai sert à voir les sorts, pas à
		# les mériter — les kills du joueur, eux, se gagnent en campagne.
		for i in character.ultimate_required_kills:
			kills.register_kill()
		ui.set_kills(kills.kills, character.ultimate_required_kills, kills.available())
		ui.flash("MODE DÉMO — sorts illimités, sans recharge", Color("#9fe8b4"))
	# LE CARNET S'OUVRE TOUT SEUL LA PREMIÈRE FOIS qu'on entre dans un épisode,
	# et une seule : un briefing qu'on doit refermer à chaque essai devient un
	# obstacle entre le joueur et sa partie. Le « déjà vu » vit dans Settings et
	# non dans Progress — c'est une commodité d'affichage, pas un acquis, et
	# Progress refuse d'écrire hors d'une sauvegarde chargée.
	if not config.is_demo and not Settings.quest_seen(config.stage, config.episode):
		Settings.mark_quest_seen(config.stage, config.episode)
		toggle_quest()
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
	if not level.house_is_open():
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
	# Le joueur est recréé à chaque chargement : on relie ici plutôt que par
	# signal, pour ne pas avoir à gérer les reconnexions.
	level.player.touch_direction = ui.touch_direction()
	ui.set_counters(level.teleport_count, progress.unlocked_skills)
	ui.set_action_state(_action_state())


## Décrit la barre d'action complète pour l'interface : ce qui est prêt, ce qui
## recharge, ce qui manque de mana, et l'ultime verrouillé tant que les kills
## n'y sont pas.
func _action_state() -> Dictionary:
	var entries: Array[Dictionary] = []
	var bar := level.action_bar()
	for slot in bar.size():
		var ability: Ability = bar[slot]
		var is_ultimate := slot == SLOT_ULTIMATE
		var locked := not progress.skill_unlocked(slot)
		var ready := level.can_use(slot) and (not is_ultimate or kills.available())
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
			"locked": locked or (is_ultimate and not kills.available()),
			"highlight": is_ultimate,
		})
	return {
		"entries": entries,
		"can_teleport": level.player_can_teleport(),
		"teleport_ratio": _teleport_ratio(),
		"on_portal": level.player_on_portal(),
		"gamble": level.player_teleport_is_gamble(),
		"can_attack": level.can_use(SLOT_ATTACK),
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
	if state != State.PLAYING:
		return
	if slot == SLOT_PORTAL:
		level.try_teleport_player()
		return
	if slot == SLOT_ULTIMATE:
		if not kills.available():
			ui.flash("Extra Hit verrouillé — encore %d kills" % maxi(0,
				kills.needed - kills.progress), Color("#7b8bb0"))
			return
		# L'ultime n'est dépensé QUE s'il est réellement parti : un ultime perdu
		# parce qu'aucun ennemi n'était à portée serait une punition absurde.
		# En DÉMO il ne se dépense pas du tout — il est là pour être regardé.
		if level.use_ability(slot):
			if not demo:
				kills.spend()
			ui.set_kills(kills.kills, kills.needed, demo)
			ui.flash("%s !" % level.ability_at(slot).display_name, Color("#ffd15a"))
		return
	level.use_ability(slot)


func _on_ability_refused(reason: String) -> void:
	match reason:
		"verrouillé":
			ui.flash("Sort verrouillé — trouve une potion", Color("#7b8bb0"))
		"cible":
			ui.flash("Aucun ennemi à portée", Color("#7b8bb0"))
		"place":
			ui.flash("Pas de place pour ça ici", Color("#7b8bb0"))


# --- Progression -----------------------------------------------------------------

func _on_enemy_killed() -> void:
	kills.register_kill()
	ui.set_kills(kills.kills, kills.needed, kills.available())
	if not kills.available():
		ui.flash("KILLS : %d / %d" % [kills.progress, kills.needed], Color("#c9a8ff"))


func _on_ultimate_ready() -> void:
	ui.flash("EXTRA POWER PRÊT !", Color("#ffd15a"))


func _on_gem_collected(collected: int, total: int) -> void:
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
	ui.flash("La porte de la maison s'ouvre !", Color("#ffd479"))


func _on_lair_destroyed(remaining: int) -> void:
	if remaining > 0:
		ui.flash("Repaire détruit — il en reste %d" % remaining, Color("#ffd479"))
	elif level.gems_remaining() > 0:
		ui.flash("Les repaires sont à terre — plus aucun ennemi ne reviendra",
			Color("#ffd479"))
	else:
		ui.flash("La porte de la maison s'ouvre !", Color("#ffd479"))


func _on_potion_collected(slot: int) -> void:
	if slot < 0:
		ui.flash("Tous tes sorts sont déjà acquis", Color("#7b8bb0"))
		return
	var ability := level.ability_at(slot)
	ui.flash("%s débloqué — pour toujours !" % ability.display_name, Color("#ffd15a"))


func _on_player_teleported(advantageous: bool) -> void:
	# Retour immédiat sur le résultat du pari : c'est toute la mécanique du jeu.
	if advantageous:
		ui.flash("Le portail te rapproche !", Color("#8fe6ff"))
	else:
		ui.flash("Le portail t'éloigne…", Color("#e0a05c"))
