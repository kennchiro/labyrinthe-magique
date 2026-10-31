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

static var _loaded := false
static var _tap_to_move := false
static var _quest_seen := {}


## Déplacement « toucher le chemin » (façon Dota) au lieu du manche analogique.
## FAUX PAR DÉFAUT : le manche reste le mode nominal, le tap est une option.
static func tap_to_move() -> bool:
	# `--tap-move` force le mode pour une session de test, sans rien écrire —
	# même motif que `--touch` dans Platform.touch_ui().
	if "--tap-move" in OS.get_cmdline_user_args():
		return true
	_ensure_loaded()
	return _tap_to_move


static func set_tap_to_move(enabled: bool) -> void:
	_ensure_loaded()
	_tap_to_move = enabled
	var file := ConfigFile.new()
	file.load(PATH)
	file.set_value("controls", "tap_to_move", enabled)
	file.save(PATH)


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
	var file := ConfigFile.new()
	file.load(PATH)
	file.set_value("quest", "seen", _quest_seen.keys())
	file.save(PATH)


static func _quest_key(stage: int, episode: int) -> String:
	return "%d.%d" % [stage, episode]


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var file := ConfigFile.new()
	if file.load(PATH) == OK:
		_tap_to_move = bool(file.get_value("controls", "tap_to_move", false))
		for key in file.get_value("quest", "seen", []):
			_quest_seen[str(key)] = true
