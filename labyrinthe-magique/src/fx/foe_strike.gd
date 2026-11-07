class_name FoeStrike
extends Node2D

## LE COUP D'UN ENNEMI, peint au shader : l'armement sur lui, puis la forme du coup devant
## son arme, puis ce qui en reste.
##
## Le geste de la planche ne suffit pas : à la taille où le jeu affiche une créature, une
## massue qui s'abat se lit comme un tressaillement. Le joueur doit VOIR qu'il a été frappé,
## et surtout voir venir le coup pour l'esquiver.
##
## Une forme par façon de frapper (lame, choc au sol, morsure, souffle, éclaboussure, dard)
## et des couleurs par espèce. Les boss frappent en plus grand. Leurs zones de loin, elles,
## restent les images de leur planche (`BossZone`).

const SHADERS := {
	"foe_slash": preload("res://assets/shaders/foe_slash.gdshader"),
	"foe_smash": preload("res://assets/shaders/foe_smash.gdshader"),
	"foe_bite": preload("res://assets/shaders/foe_bite.gdshader"),
	"foe_breath": preload("res://assets/shaders/foe_breath.gdshader"),
	"foe_splash": preload("res://assets/shaders/foe_splash.gdshader"),
	"foe_sting": preload("res://assets/shaders/foe_sting.gdshader"),
	"foe_charge": preload("res://assets/shaders/foe_charge.gdshader"),
}

## `key` la forme, `light` `mid` `deep` ses trois aplats, `size` son rayon en cases, `extra`
## ses paramètres propres. Une créature absente d'ici ne frappe pas au contact.
const STYLES := {
	"hunter": {"key": "foe_slash", "light": Color("#f6e4ff"), "mid": Color("#b06cff"),
		"deep": Color("#4b1d7a"), "size": 1.1},
	"goblin": {"key": "foe_smash", "light": Color("#fff1c9"), "mid": Color("#d2a868"),
		"deep": Color("#5b3a1e"), "size": 1.0, "extra": {"cracks": 5.0}},
	"serpent": {"key": "foe_bite", "light": Color("#efffd6"), "mid": Color("#4ee07a"),
		"deep": Color("#145a2c"), "size": 1.0},
	"ombre": {"key": "foe_slash", "light": Color("#dfe2ff"), "mid": Color("#5f63e8"),
		"deep": Color("#1a1648"), "size": 1.15, "extra": {"claws": 2.0}},
	"dragonnet": {"key": "foe_breath", "light": Color("#fff3b0"), "mid": Color("#ff8a1f"),
		"deep": Color("#b3200b"), "size": 0.65},
	"golem": {"key": "foe_smash", "light": Color("#ffe2a0"), "mid": Color("#ff6a14"),
		"deep": Color("#5a1a06"), "size": 1.3, "extra": {"cracks": 7.0}},
	"cristal": {"key": "foe_smash", "light": Color("#eaf8ff"), "mid": Color("#5ab4ff"),
		"deep": Color("#7a2bd6"), "size": 1.25, "extra": {"cracks": 8.0}},
	"minotaure": {"key": "foe_smash", "light": Color("#ffe3cc"), "mid": Color("#ff4b2b"),
		"deep": Color("#5a1608"), "size": 1.45, "extra": {"cracks": 6.0}},
	"chevalier": {"key": "foe_slash", "light": Color("#f2e0ff"), "mid": Color("#a050ff"),
		"deep": Color("#2a0d40"), "size": 1.3},
	"givre": {"key": "foe_smash", "light": Color("#f4fdff"), "mid": Color("#8fdcff"),
		"deep": Color("#2a5c9a"), "size": 1.35, "extra": {"cracks": 8.0}},
	"seigneur": {"key": "foe_slash", "light": Color("#fff0b0"), "mid": Color("#ff5a1a"),
		"deep": Color("#6a0a0a"), "size": 1.7},
	"gelee": {"key": "foe_splash", "light": Color("#f0fffd"), "mid": Color("#3fe0d6"),
		"deep": Color("#0f6a78"), "size": 1.0},
	"gelee_petite": {"key": "foe_splash", "light": Color("#f0fffd"), "mid": Color("#3fe0d6"),
		"deep": Color("#0f6a78"), "size": 0.7},
	"raie": {"key": "foe_sting", "light": Color("#fff6d0"), "mid": Color("#ffc23a"),
		"deep": Color("#8a5a10"), "size": 1.15},
	# Les boss : deux à trois cases, et une onde de choc en plus (voir `Level`).
	"boss_sylvain": {"key": "foe_smash", "light": Color("#eaffc8"), "mid": Color("#6cc23a"),
		"deep": Color("#2c4a14"), "size": 2.6, "extra": {"cracks": 7.0}},
	"boss_oiseau_tonnerre": {"key": "foe_slash", "light": Color("#ffffff"), "mid": Color("#ffe03a"),
		"deep": Color("#3a6cff"), "size": 2.5, "extra": {"claws": 3.0}},
	"boss_scorpion": {"key": "foe_sting", "light": Color("#fff2c8"), "mid": Color("#f0a030"),
		"deep": Color("#6a3a10"), "size": 2.4},
	"boss_behemoth": {"key": "foe_splash", "light": Color("#eaffff"), "mid": Color("#3aa8ff"),
		"deep": Color("#0e3a7a"), "size": 2.6},
	"boss_araignee": {"key": "foe_smash", "light": Color("#f0fbff"), "mid": Color("#62d8ff"),
		"deep": Color("#7a2bd6"), "size": 2.5, "extra": {"cracks": 9.0}},
	"boss_yeti": {"key": "foe_smash", "light": Color("#ffffff"), "mid": Color("#a8e6ff"),
		"deep": Color("#3a6aa8"), "size": 2.8, "extra": {"cracks": 8.0}},
	"boss_mere_ronce": {"key": "foe_slash", "light": Color("#e8ffd0"), "mid": Color("#4f9a2a"),
		"deep": Color("#3a1a2a"), "size": 2.5, "extra": {"claws": 3.0}},
	"boss_idole": {"key": "foe_smash", "light": Color("#fff8d0"), "mid": Color("#ffc83a"),
		"deep": Color("#7a4a10"), "size": 2.6, "extra": {"cracks": 6.0}},
	"boss_roi_dechu": {"key": "foe_slash", "light": Color("#f2e6ff"), "mid": Color("#8f5bff"),
		"deep": Color("#2a1040"), "size": 2.6},
	"boss_chimere": {"key": "foe_breath", "light": Color("#fff3b0"), "mid": Color("#ff4a1a"),
		"deep": Color("#5a0a1a"), "size": 1.6},
}
const STRIKE_TIME := 0.5
const BOSS_STRIKE_TIME := 0.75
## Le coup tombe au bout de l'arme, là où se tient le mage : une créature s'arrête à une
## case de lui. Les boss portent un peu plus loin.
const REACH := 1.0
const BOSS_REACH := 1.25
## Où tombe le point d'impact dans chaque dessin, en part du rayon du quad, le long de son
## axe. Sans ça le coup se posait une case trop loin : le centre du quad n'est pas l'impact.
const ANCHORS := {"foe_slash": 0.35, "foe_bite": 0.3, "foe_sting": 0.45}
## Le souffle part de la gueule : c'est son bord arrière qu'on pose, pas son impact.
const BREATH_BACK := -0.85
const MOUTH := 0.3
## Les positions sont celles des PIEDS. Le corps se dessine au-dessus : un coup posé aux
## pieds du mage semblait tomber sous lui, mesuré sur capture.
const BODY_LIFT := 0.45
const BOSS_BODY_LIFT := 0.9
## La forme s'arrête aux quatre cinquièmes du quad, comme `PaintedBurst`.
const QUAD_FILL := 0.8

var _material: ShaderMaterial = null
var _duration := STRIKE_TIME
var _time := 0.0
var _follow: Node2D = null
var _lift := Vector2.ZERO


static func has_style(species: String) -> bool:
	return STYLES.has(species)


static func is_big(species: String) -> bool:
	return species.begins_with("boss_")


## Le coup qui tombe : devant `at`, dans le sens `facing`.
static func strike(parent: Node, species: String, at: Vector2, facing: Vector2i,
		tile_size: int) -> FoeStrike:
	var style: Dictionary = STYLES[species]
	var big := is_big(species)
	var fx := FoeStrike.new()
	parent.add_child(fx)
	var direction := Vector2(facing) if facing != Vector2i.ZERO else Vector2.DOWN
	var key := str(style["key"])
	var quad_radius := float(style["size"]) * float(tile_size) / QUAD_FILL
	var hit := (BOSS_REACH if big else REACH) * float(tile_size)
	if key == "foe_breath":
		hit = MOUTH * float(tile_size) - BREATH_BACK * quad_radius
	else:
		hit -= float(ANCHORS.get(key, 0.0)) * quad_radius
	fx.position = at + direction * hit + Vector2.UP * float(tile_size) * (BOSS_BODY_LIFT if big \
		else BODY_LIFT)
	# Devant les personnages : c'est le coup qu'on doit voir, pas le décor.
	fx.z_index = 11
	if key != "foe_smash" and key != "foe_splash":
		fx.rotation = direction.angle()
	fx._paint(key, style, float(style["size"]), BOSS_STRIKE_TIME if big else STRIKE_TIME,
		tile_size)
	return fx


## L'armement : posé SUR la créature, il la suit le temps du geste.
static func charge(enemy: Node2D, species: String, seconds: float, tile_size: int) -> FoeStrike:
	var style: Dictionary = STYLES[species]
	var fx := FoeStrike.new()
	enemy.get_parent().add_child(fx)
	fx._follow = enemy
	fx._lift = Vector2.UP * float(tile_size) * (BOSS_BODY_LIFT if is_big(species) else BODY_LIFT)
	fx.position = enemy.position + fx._lift
	fx.z_index = 11
	var size := 1.6 if is_big(species) else 0.75
	fx._paint("foe_charge", style, size, maxf(0.12, seconds), tile_size)
	return fx


func _paint(key: String, style: Dictionary, radius_tiles: float, seconds: float,
		tile_size: int) -> void:
	_duration = seconds
	_material = ShaderMaterial.new()
	_material.shader = SHADERS[key]
	_material.set_shader_parameter("seed", float(Time.get_ticks_usec() % 1000) * 0.001)
	_material.set_shader_parameter("light", style["light"])
	_material.set_shader_parameter("mid", style["mid"])
	_material.set_shader_parameter("deep", style["deep"])
	for parameter: String in style.get("extra", {}):
		_material.set_shader_parameter(parameter, style["extra"][parameter])
	var quad := Sprite2D.new()
	quad.texture = MagicOrb.painted_quad()
	quad.material = _material
	quad.scale = Vector2.ONE * radius_tiles * 2.0 * float(tile_size) / QUAD_FILL
	add_child(quad)


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration or (_follow != null and not is_instance_valid(_follow)):
		queue_free()
		return
	if _follow != null:
		position = _follow.position + _lift
	_material.set_shader_parameter("progress", _time / _duration)
