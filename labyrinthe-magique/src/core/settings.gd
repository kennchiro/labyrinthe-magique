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


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var file := ConfigFile.new()
	if file.load(PATH) == OK:
		_tap_to_move = bool(file.get_value("controls", "tap_to_move", false))
