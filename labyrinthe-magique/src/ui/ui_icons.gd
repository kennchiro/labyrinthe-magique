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
	var requested_key := character_id + "/" + ability_id
	if _cache.has(requested_key):
		return _cache[requested_key]
	var direct_path := ICONS_PATH + requested_key + ".png"
	if ResourceLoader.exists(direct_path):
		var direct: Texture2D = load(direct_path)
		_cache[requested_key] = direct
		return direct
	if character_id == "ael":
		var evolved := {
			"eveille": ["ael_lame", "ael_gerbe", "ael_gardien", "ael_eclair", "ael_pas", "ael_rayon"],
			"ascendant": ["ael_double", "ael_pluie", "ael_sentinelle", "ael_onde", "ael_ailes", "ael_nova", "ael_transformation"],
			"prisme": ["ael_rafale", "ael_comete", "ael_barriere", "ael_orbite", "ael_transmission", "ael_ultime"],
			"dragon": ["ael_griffes", "ael_souffle", "ael_ecailles", "ael_chute", "ael_envol", "ael_rugissement"],
		}
		# Les charges du sort 2 (2026-11-06) n'ont pas encore d'icône peinte : elles prêtent celle du geste le plus
		# proche, la Ruée de l'Apprenti, jusqu'à ce que la planche arrive.
		var borrowed := {"ael_percee": "ael_rush", "ael_fente": "ael_rush", "ael_lames": "ael_rush"}
		if borrowed.has(ability_id):
			var stand_in := for_ability("ael", borrowed[ability_id])
			_cache[requested_key] = stand_in
			return stand_in
		for form: String in evolved:
			if ability_id in evolved[form]:
				var painted_id := "ael_transformation" if ability_id == "ael_nova" else ability_id
				var painted_path := ICONS_PATH + "ael_" + form + "/" + painted_id + ".png"
				if ResourceLoader.exists(painted_path):
					var painted := for_ability("ael_" + form, painted_id)
					_cache[requested_key] = painted
					return painted
		var groups := [
			["ael_slash", "ael_lame", "ael_double", "ael_rafale"],
			["ael_shard", "ael_wind_cut", "ael_gerbe", "ael_pluie", "ael_comete"],
			["ael_guard", "ael_parry", "ael_gardien", "ael_sentinelle", "ael_barriere"],
			["ael_rush", "ael_eclair", "ael_onde", "ael_orbite"],
			["ael_roll", "ael_pas", "ael_ailes", "ael_transmission"],
			["ael_great_slash", "ael_rayon", "ael_nova", "ael_transformation", "ael_ultime"],
		]
		for group: Array in groups:
			if ability_id in group:
				ability_id = group[0]
				break
	# L'ÉVEIL d'un mage : ses icônes sont découpées à côté des siennes, dans `<id>_eveil`.
	var awakened_path := ICONS_PATH + character_id + "_eveil/" + ability_id + ".png"
	if ResourceLoader.exists(awakened_path):
		var awakened: Texture2D = load(awakened_path)
		_cache[requested_key] = awakened
		return awakened
	var key := character_id + "/" + ability_id
	if _cache.has(key):
		return _cache[key]
	var path := ICONS_PATH + key + ".png"
	var texture: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_cache[key] = texture
	_cache[requested_key] = texture
	return texture
