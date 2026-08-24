class_name UiIcons
extends RefCounted

## Les icônes de sorts, cherchées par identifiant de compétence.
##
## `assets/icons/<personnage>/<id_du_sort>.png`, découpées par
## `tools/build_skill_icons.py`. Un personnage sans planche n'en a pas : les
## deux interfaces retombent alors sur les pastilles colorées d'avant, sans que
## rien ne casse. C'est ce qui permet d'habiller les mages un par un, au rythme
## où les planches arrivent, plutôt que d'attendre les huit.
##
## Les textures sont MISES EN CACHE : la barre d'action se redessine à chaque
## frame, et un `load()` par bouton et par image ferait des centaines d'accès
## disque par seconde.

const ICONS_PATH := "res://assets/icons/"

static var _cache := {}


static func for_ability(character_id: String, ability_id: String) -> Texture2D:
	if ability_id.is_empty():
		return null
	var key := character_id + "/" + ability_id
	if _cache.has(key):
		return _cache[key]
	var path := ICONS_PATH + key + ".png"
	var texture: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_cache[key] = texture
	return texture
