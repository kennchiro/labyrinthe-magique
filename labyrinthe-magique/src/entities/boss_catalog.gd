class_name BossCatalog
extends RefCounted

## Le boss de chaque chapitre : la forme de son attaque de loin et sa démarche.
##
## Ce qu'il vaut au combat est dans `Bestiary`, comme toute créature. Ses planches sont
## découpées par `tools/build_bosses.py`, ses prompts dans `docs/prompts/boss/`.
##
## `pattern` et `count` : voir `BossFight`. `gait` : voir `BossGait`. `speed` : sa marche
## en cases par seconde, celle du mage est de 5. Elle ne suit pas le stage : sa taille et
## son apparence la décident, et le plus gros est le plus lent.

const BY_STAGE := [
	{"id": "boss_sylvain", "pattern": "trail", "count": 5, "speed": 1.5, "gait": "walk"},
	{"id": "boss_oiseau_tonnerre", "pattern": "line", "count": 7, "speed": 2.0, "gait": "rush"},
	{"id": "boss_scorpion", "pattern": "burrow", "count": 2, "speed": 2.6, "gait": "steps",
		"move": 0.55, "rest": 0.6},
	{"id": "boss_behemoth", "pattern": "wave", "count": 6, "speed": 1.5, "gait": "steps",
		"move": 1.0, "rest": 0.45},
	{"id": "boss_araignee", "pattern": "star", "count": 9, "speed": 1.9, "gait": "keep_away",
		"keep_away": 4},
	{"id": "boss_yeti", "pattern": "rain", "count": 6, "speed": 1.8, "gait": "charge",
		"charge_speed": 4.2, "stun": 1.4},
	{"id": "boss_mere_ronce", "pattern": "wall", "count": 5, "speed": 1.2, "gait": "walk"},
	{"id": "boss_idole", "pattern": "cross", "count": 4, "speed": 2.0, "gait": "steps",
		"move": 0.5, "rest": 0.8},
	{"id": "boss_roi_dechu", "pattern": "pursuit", "count": 2, "speed": 1.6, "gait": "blink"},
	{"id": "boss_chimere", "pattern": "combo", "count": 5, "speed": 2.3, "gait": "charge",
		"charge_speed": 4.4, "stun": 1.0, "enrage_below": 0.5, "enrage_factor": 1.3},
]

## Du stage 1 au stage 10, les durées annoncées dans les fiches : le dernier boss prévient
## moins longtemps et frappe plus souvent. Points de départ, à régler à l'essai.
const ALERT_FIRST := 1.6
const ALERT_LAST := 0.9
const EVERY_FIRST := 7.0
const EVERY_LAST := 4.0


static func of_stage(stage: int) -> Dictionary:
	return BY_STAGE[clampi(stage, 1, BY_STAGE.size()) - 1]


static func id_of(stage: int) -> String:
	return str(of_stage(stage)["id"])


static func alert_time(stage: int) -> float:
	return lerpf(ALERT_FIRST, ALERT_LAST, _progress(stage))


static func interval(stage: int) -> float:
	return lerpf(EVERY_FIRST, EVERY_LAST, _progress(stage))


static func _progress(stage: int) -> float:
	return float(clampi(stage, 1, BY_STAGE.size()) - 1) / float(BY_STAGE.size() - 1)
