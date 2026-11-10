class_name ElementOrbs
extends Node2D

## LA ROUE DES ÉLÉMENTS (l'Éveil du Sorcier Suprême, l'Archimage Primordial) : quatre orbes, feu, eau, terre et
## air, tournent autour du mage pendant l'Éveil. L'orbe EN TÊTE (`set_lead`) est plus grosse et porte un halo :
## c'est l'élément de son prochain coup. Leur ombre est posée au sol.
##
## Chaque orbe est un quad peint (`primordial_orbe`). Le nœud vit dans `Entities` mais dessine en positions du monde :
## le `Level` remet son échelle à un après l'avoir ajouté, comme pour les corbeaux du Fléau. Les orbes qui passent
## DERRIÈRE le mage sont dessinées sous lui, celles de devant au-dessus.

const ORBIT := Vector2(0.9, 0.38)       # rayons de la ronde, en cases
const LIFT := 0.8                       # hauteur de la ronde au-dessus de ses pieds, en cases
const SIZE := 0.5                       # diamètre d'une orbe, en cases
const LEAD_SIZE := 0.72                 # celui de l'orbe en tête
const TURN := 1.7                       # radians par seconde
const POP_TIME := 0.25                  # l'orbe qui prend la tête enfle un instant
const LEAVE_TIME := 0.8
const COUNT := 4

var tile_size := 32
var _mage: Node2D = null
var _time := 0.0
var _lead := 0
var _pop := 0.0
var _leaving := -1.0
var _orbs: Array[Sprite2D] = []
var _weights: Array[float] = [1.0, 0.0, 0.0, 0.0]


func setup(mage: Node2D, p_tile_size: int) -> void:
	_mage = mage
	tile_size = p_tile_size
	for k in COUNT:
		var orb := Sprite2D.new()
		orb.texture = MagicOrb.painted_quad()
		var shaded := PaintedFx.make_material("primordial_orbe", float(k) * 0.37)
		shaded.set_shader_parameter("kind", k)
		orb.material = shaded
		orb.z_as_relative = false
		add_child(orb)
		_orbs.append(orb)
	_place()


## L'orbe en tête vient de changer : `rank` 0 feu, 1 eau, 2 terre, 3 air.
func set_lead(rank: int) -> void:
	_lead = posmod(rank, COUNT)
	_pop = POP_TIME


## L'Éveil s'achève : les orbes pâlissent, rétrécissent et tombent dans l'anneau.
func dismiss() -> void:
	if _leaving < 0.0:
		_leaving = 0.0


func _process(delta: float) -> void:
	_time += delta
	_pop = maxf(0.0, _pop - delta)
	if _leaving >= 0.0:
		_leaving += delta
	if _mage == null or not is_instance_valid(_mage) or _leaving >= LEAVE_TIME:
		queue_free()
		return
	for k in COUNT:
		_weights[k] = move_toward(_weights[k], 1.0 if k == _lead else 0.0, delta * 5.0)
	_place()
	queue_redraw()


func _place() -> void:
	if _mage == null or not is_instance_valid(_mage):
		return
	var tile := float(tile_size)
	var away := maxf(0.0, _leaving) / LEAVE_TIME
	for k in COUNT:
		var angle := _time * TURN + float(k) * TAU / float(COUNT)
		var ground := Vector2(cos(angle) * ORBIT.x, sin(angle) * ORBIT.y) * tile * (1.0 - away * 0.6)
		var bob := sin(_time * 2.6 + float(k) * 1.3) * 0.07 * tile
		var lift := -LIFT * tile * (1.0 - away) + bob
		var orb := _orbs[k]
		orb.position = _mage.position + ground + Vector2(0.0, lift)
		var size := lerpf(SIZE, LEAD_SIZE, _weights[k])
		if k == _lead and _pop > 0.0:
			size *= 1.0 + 0.35 * sin(_pop / POP_TIME * PI)
		size *= 1.0 - away * 0.7
		# Le quad déborde de l'orbe pour son halo : l'orbe en occupe 62 % du rayon.
		orb.scale = Vector2.ONE * size * tile / 0.62
		orb.z_index = 11 if sin(angle) > 0.0 else 9
		var shaded := orb.material as ShaderMaterial
		shaded.set_shader_parameter("lead", _weights[k])
		shaded.set_shader_parameter("fade", 1.0 - away)


func _draw() -> void:
	if _mage == null or not is_instance_valid(_mage):
		return
	var tile := float(tile_size)
	var away := maxf(0.0, _leaving) / LEAVE_TIME
	for k in COUNT:
		var angle := _time * TURN + float(k) * TAU / float(COUNT)
		var ground := Vector2(cos(angle) * ORBIT.x, sin(angle) * ORBIT.y) * tile * (1.0 - away * 0.6)
		draw_set_transform(_mage.position + ground, 0.0, Vector2(1.0, 0.45))
		draw_circle(Vector2.ZERO, tile * 0.13 * (1.0 + 0.4 * _weights[k]), Color(0.02, 0.0, 0.05, 0.26 * (1.0 - away)))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
