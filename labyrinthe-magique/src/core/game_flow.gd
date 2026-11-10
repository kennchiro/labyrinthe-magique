class_name GameFlow
extends Node

## Routeur des écrans : accueil → sélection → jeu, et retour.
##
## Il tient UNE seule donnée entre deux écrans — le personnage choisi — et
## instancie les scènes à la demande. Le GameManager reste donc ce qu'il était,
## le chef d'orchestre d'UNE partie ; il n'a pas à savoir qu'il existe un menu.
##
## LIGNE DE COMMANDE : dès qu'un argument est passé (`-- --stage 2`, `--auto-walk`,
## `--screenshot`…), on entre DIRECTEMENT en jeu. Sans cette règle, chaque capture
## d'écran de développement s'arrêterait sur l'écran-titre et tout l'outillage de
## vérification visuelle serait à refaire. `--menu` force l'accueil quand c'est
## lui qu'on veut photographier.

const TITLE_SCENE := preload("res://scenes/menu/title_screen.tscn")
const SELECT_SCENE := preload("res://scenes/menu/character_select.tscn")
const STAGES_SCENE := preload("res://scenes/menu/stage_select.tscn")
const GAME_SCENE := preload("res://scenes/main.tscn")

var character_id := CharacterCatalog.default_id()
## Niveau par lequel commencer, en index PLAT. Renseigné par la sélection de
## stage ; zéro veut dire « au début de la campagne ».
var start_index := 0
## La dernière composition de l'arène, pour la retrouver en y revenant.
var _arena_setup := {}

var _current: Node = null


func _ready() -> void:
	Platform.apply_ui_scale(get_window())
	var args := OS.get_cmdline_user_args()
	var character_arg := args.find("--character")
	if character_arg >= 0 and character_arg + 1 < args.size():
		character_id = args[character_arg + 1]

	if "--demo" in args:
		start_game(true)
		if Screenshot.requested(args):
			_capture(args)
		return
	if args.is_empty() or "--menu" in args or "--select" in args or "--stages" in args \
			or _wants_arena(args):
		if _wants_arena(args):
			show_arena()
		elif "--stages" in args:
			show_stages()
		elif "--select" in args:
			show_select()
		else:
			show_title()
		# La capture doit fonctionner sur les menus aussi : DevTools n'existe
		# qu'à l'intérieur d'une partie, sans ça `--screenshot` ne répondrait
		# jamais ici et le processus tournerait sans fin.
		if Screenshot.requested(args):
			_capture(args)
	else:
		start_game()


func _capture(args: PackedStringArray) -> void:
	for i in Screenshot.frames(args):
		await RenderingServer.frame_post_draw
	Screenshot.save(self, args)
	get_tree().quit()


func show_title() -> void:
	var screen: TitleScreen = TITLE_SCENE.instantiate()
	screen.character_id = character_id
	_swap(screen)
	screen.start_requested.connect(start_game)
	screen.journey_requested.connect(show_stages)
	screen.select_requested.connect(show_select)
	screen.arena_requested.connect(show_arena)
	screen.settings_requested.connect(func() -> void:
		var panel := SettingsPanel.new()
		panel.character_id = character_id
		panel.closed.connect(panel.queue_free)
		screen.add_child(panel))


func show_select() -> void:
	var screen: CharacterSelect = SELECT_SCENE.instantiate()
	screen.hero_progress = HeroProgress.load_saved()
	# Revenu d'un essai d'un personnage caché, sans onglet : l'écran n'aurait rien à ouvrir.
	if character_id in CharacterCatalog.HIDDEN:
		character_id = CharacterCatalog.default_id()
	screen.character_id = character_id
	_swap(screen)
	screen.play_requested.connect(func(id: String) -> void:
		character_id = id
		start_game())
	screen.demo_requested.connect(func(id: String) -> void:
		character_id = id
		start_game(true))
	screen.back_requested.connect(func() -> void:
		character_id = screen.character_id
		show_title())


## L'écran des chapitres. La boussole peinte sur le deuxième bouton de la
## couverture désigne un VOYAGE : c'est ici qu'elle mène, et non une seconde
## fois vers le choix du mage comme au début.
func show_stages() -> void:
	var screen: StageSelect = STAGES_SCENE.instantiate()
	_swap(screen)
	screen.stage_chosen.connect(func(stage: int, episode: int) -> void:
		start_index = LevelConfig.flat_index(stage, episode)
		start_game())
	screen.back_requested.connect(show_title)


## L'ARÈNE (2026-11-09) : les héros se battent seuls, le joueur compose les équipes et regarde.
## Toute la composition vit dans l'écran lui-même ; on garde la dernière pour y revenir.
func show_arena() -> void:
	var screen := ArenaScreen.new()
	screen.last_setup = _arena_setup
	_swap(screen)
	screen.menu_requested.connect(func() -> void:
		_arena_setup = screen.last_setup
		show_title())


static func _wants_arena(args: PackedStringArray) -> bool:
	for arg in args:
		if arg.begins_with("--arena"):
			return true
	return false


func start_game(demo: bool = false) -> void:
	# Revenu au titre après un essai, START ne doit pas partir en vraie partie avec lui.
	if not demo and character_id in CharacterCatalog.HIDDEN:
		character_id = CharacterCatalog.default_id()
	var game: GameManager = GAME_SCENE.instantiate()
	# Renseigné AVANT l'entrée dans l'arbre : le _ready du GameManager démarre
	# immédiatement le premier niveau, il lui faut déjà son personnage.
	game.character_id = character_id
	game.demo = demo
	# UNE CARTE PAR FORME D'AËL. En jeu il n'y a qu'Aël : la carte dit seulement à quel niveau l'essayer.
	var form := CharacterCatalog.AEL_FORMS.find(character_id)
	if form >= 0:
		character_id = CharacterCatalog.AEL
		game.character_id = character_id
	if demo and character_id == "ael":
		game.hero_progress = HeroProgress.new()
		game.demo_hero_form = maxi(0, form)
		game.hero_progress.xp = HeroProgress.threshold(int(CharacterCatalog.AEL_FORM_LEVELS[game.demo_hero_form]))
	game.start_index = start_index
	# Le point d'entrée ne vaut que pour cette partie : revenir au menu et
	# appuyer sur START doit reprendre au début, pas au dernier stage choisi.
	start_index = 0
	_swap(game)
	game.menu_requested.connect(func() -> void:
		# Le jeu met l'arbre en pause pour afficher son écran de fin ; revenir au
		# menu doit le relâcher, sinon l'accueil s'affiche figé.
		get_tree().paused = false
		# Quitter un ESSAI ramène à la sélection : on était en train de choisir
		# son mage, on y retourne — l'accueil serait un détour.
		if demo:
			if game.character_id == "ael" and game.demo_hero_form >= 0:
				character_id = CharacterCatalog.AEL_FORMS[game.demo_hero_form]
			show_select()
		else:
			show_title())


func _swap(screen: Node) -> void:
	if _current != null:
		_current.queue_free()
	_current = screen
	add_child(screen)
