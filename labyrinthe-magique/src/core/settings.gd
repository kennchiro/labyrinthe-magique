class_name Settings
extends RefCounted

## Les PRÉFÉRENCES du joueur — à ne pas confondre avec Progress, qui garde ses
## ACQUIS. La séparation n'est pas cosmétique : Progress refuse d'écrire sur le
## disque hors d'une sauvegarde chargée, parce que le gameplay le modifie. Un
## réglage, lui, ne change QUE quand le joueur presse le bouton d'options — il
## peut donc s'écrire immédiatement, même en session de développement.
##
## Aucune dépendance au moteur de scène en dehors de ConfigFile, comme Progress.

const PATH := "user://settings.cfg"

## Les trois façons de déplacer le mage au doigt.
const MOVE_STICK := "stick"
const MOVE_CROSS := "cross"
const MOVE_TAP := "tap"

## Un test travaille sur son propre fichier : il ne doit pas réécrire les réglages du
## joueur. `--settings-file` fait de même pour une capture.
static var path_override := ""

static var _loaded := false
static var _move_mode := MOVE_STICK
static var _touch_layout := TouchLayout.new()
static var _quest_seen := {}


## LE MANCHE RESTE LE DÉFAUT : la croix et le tap sont des options.
static func move_mode() -> String:
	# `--tap-move` et `--cross` forcent le mode pour une session de test, sans rien
	# écrire — même motif que `--touch` dans Platform.touch_ui().
	var args := OS.get_cmdline_user_args()
	if "--tap-move" in args:
		return MOVE_TAP
	if "--cross" in args:
		return MOVE_CROSS
	_ensure_loaded()
	return _move_mode


static func set_move_mode(mode: String) -> void:
	_ensure_loaded()
	_move_mode = mode
	_write("controls", "move_mode", mode)


## Déplacement « toucher le chemin » (façon Dota) ?
static func tap_to_move() -> bool:
	return move_mode() == MOVE_TAP


## La disposition en vigueur. Le manche et le pad gardent CET objet : `save_touch_layout`
## le modifie en place, et la partie en cours suit sans rien recharger.
static func touch_layout() -> TouchLayout:
	_ensure_loaded()
	return _touch_layout


static func save_touch_layout(edited: TouchLayout) -> void:
	_ensure_loaded()
	_touch_layout.custom = edited.to_data()
	_write("controls", "touch_layout", _touch_layout.to_data())


## LE CARNET DÉJÀ VU pour cet épisode. C'est une commodité d'affichage — savoir
## s'il faut ouvrir le briefing tout seul — et non un acquis du joueur : il vit
## donc ici et pas dans Progress, qui refuse d'écrire hors d'une sauvegarde
## chargée. Perdre ce réglage ne coûte au joueur qu'un panneau à refermer.
static func quest_seen(stage: int, episode: int) -> bool:
	# En session de développement le briefing s'ouvrirait à chaque capture et
	# masquerait le labyrinthe qu'on venait photographier. Même motif que
	# `Progress.persistent` : un argument de ligne de commande, et on ne touche
	# plus à rien. `--quest` le force à s'ouvrir pour le capturer exprès.
	var args := OS.get_cmdline_user_args()
	if "--quest" in args:
		return false
	if not args.is_empty():
		return true
	_ensure_loaded()
	return _quest_seen.has(_quest_key(stage, episode))


static func mark_quest_seen(stage: int, episode: int) -> void:
	if not OS.get_cmdline_user_args().is_empty():
		return
	_ensure_loaded()
	_quest_seen[_quest_key(stage, episode)] = true
	_write("quest", "seen", _quest_seen.keys())


static func _quest_key(stage: int, episode: int) -> String:
	return "%d.%d" % [stage, episode]


## Oublie ce qui est en mémoire : un test relit ainsi le fichier qu'il vient d'écrire.
static func forget() -> void:
	_loaded = false
	_move_mode = MOVE_STICK
	_touch_layout = TouchLayout.new()
	_quest_seen = {}


static func _path() -> String:
	if not path_override.is_empty():
		return path_override
	var args := OS.get_cmdline_user_args()
	var at := args.find("--settings-file")
	return args[at + 1] if at >= 0 and at + 1 < args.size() else PATH


static func _write(section: String, key: String, value: Variant) -> void:
	var file := ConfigFile.new()
	file.load(_path())
	file.set_value(section, key, value)
	file.save(_path())


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var file := ConfigFile.new()
	if file.load(_path()) == OK:
		# `tap_to_move` est l'ancienne clé, d'avant la croix : un joueur qui avait choisi
		# le tap le garde.
		var before := MOVE_TAP if bool(file.get_value("controls", "tap_to_move", false)) else MOVE_STICK
		var mode := str(file.get_value("controls", "move_mode", before))
		_move_mode = mode if mode in [MOVE_STICK, MOVE_CROSS, MOVE_TAP] else MOVE_STICK
		_touch_layout = TouchLayout.from_data(file.get_value("controls", "touch_layout", {}))
		for key in file.get_value("quest", "seen", []):
			_quest_seen[str(key)] = true
