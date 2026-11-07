class_name HeroProgress
extends RefCounted

## La progression permanente d’Aël. Les instances de test ne sauvegardent jamais.
const PATH := "user://hero.cfg"
## 80 depuis le Dragon d'or (2026-11-04) ; la courbe, 60 + 8 x N par niveau, se prolonge telle quelle.
const MAX_LEVEL := 80
var xp := 0
var victories: Dictionary = {}
var persistent := false
var _path := PATH

static func load_saved(path: String = PATH) -> HeroProgress:
	var out := HeroProgress.new()
	var file := ConfigFile.new()
	out._path = path
	var error := file.load(path)
	out.persistent = error == OK or error == ERR_FILE_NOT_FOUND
	if error == OK:
		out.xp = clampi(int(file.get_value("hero", "xp", 0)), 0, threshold(MAX_LEVEL))
		var won: Variant = file.get_value("hero", "victories", {})
		if won is Dictionary:
			out.victories = won
	return out

static func cost(at_level: int) -> int:
	return 60 + 8 * clampi(at_level, 1, MAX_LEVEL)

static func threshold(at_level: int) -> int:
	var n := clampi(at_level, 1, MAX_LEVEL) - 1
	return 60 * n + 4 * n * (n + 1)

func level() -> int:
	var result := 1
	while result < MAX_LEVEL and xp >= threshold(result + 1):
		result += 1
	return result

func form() -> int:
	return 2 if level() >= 20 else (1 if level() >= 10 else 0)

func ratio() -> float:
	if level() == MAX_LEVEL:
		return 1.0
	return float(xp - threshold(level())) / float(cost(level()))

## Retourne le nombre de niveaux franchis, même pour un gros gain d’XP.
func gain(amount: int) -> int:
	var before := level()
	xp = clampi(xp + maxi(0, amount), 0, threshold(MAX_LEVEL))
	if amount > 0:
		save()
	return level() - before

func win(stage: int, episode: int) -> int:
	var key := "%d:%d" % [stage, episode]
	var reward := 50 if victories.has(key) else 75
	victories[key] = true
	gain(reward)
	return reward

func save() -> void:
	if not persistent:
		return
	var file := ConfigFile.new()
	file.set_value("hero", "xp", xp)
	file.set_value("hero", "victories", victories)
	file.save(_path)
