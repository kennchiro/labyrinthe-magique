class_name PaintedBurst
extends Node2D

## L'éclat d'un sort peint au shader, propre à chaque mage.
##
## Elle ne porte PAS le rayon du sort au-delà de `MAX_RADIUS_TILES`. Le rayon réel d'un
## ultime couvrirait tout l'écran d'un calcul par pixel : c'est l'éclat tracé et l'onde
## de choc qui disent cette portée-là.

const MAX_RADIUS_TILES := 3.2
const MIN_RADIUS_TILES := 0.9
const FIRE_SPAN := 0.7
## L'explosion de chaque sort de feu vient de son rayon : le trait n'a qu'une gerbe, et
## seul l'ultime a des rayons. Sous ce seuil le coup est ordinaire, au-dessus c'est lui.
const SMALL_HIT_RADIUS := 1.0
const ULTIMATE_RADIUS := 5.0

var _material: ShaderMaterial = null
var _duration := 0.5
var _time := 0.0


static func make_material(key: String, seed_value: float, radius_tiles: float = 2.0) -> ShaderMaterial:
	var shaded := PaintedFx.make_material(key, seed_value)
	shaded.set_shader_parameter("solid", 1.0 if radius_tiles <= SMALL_HIT_RADIUS else 0.0)
	shaded.set_shader_parameter("rays", 0.9 if radius_tiles >= ULTIMATE_RADIUS else 0.0)
	return shaded


func setup(tile_size: int, radius_tiles: float, duration: float, seed_value: float,
		key: String = "fire_burst") -> void:
	_duration = maxf(0.1, duration)
	# SOUS les personnages (`z_index` 10) : opaque par-dessus, celle de l'ultime
	# effaçait le mage au moment le plus chargé de la partie.
	z_index = 9
	_material = make_material(key, seed_value, radius_tiles)
	var sprite := Sprite2D.new()
	sprite.texture = MagicOrb.painted_quad()
	sprite.material = _material
	# Le front s'arrête aux quatre cinquièmes du quad, et le rayon doit y tomber.
	var span := clampf(radius_tiles, MIN_RADIUS_TILES, MAX_RADIUS_TILES) * 2.0 \
		* float(tile_size) / 0.8
	# Le Feu finit en fumée sombre : au rayon entier du sort, elle couvrait la carte
	# une seconde durant. L'onde de choc dit déjà jusqu'où le sort porte.
	if key == "fire_burst":
		span *= FIRE_SPAN
	sprite.scale = Vector2(span, span)
	add_child(sprite)


## La durée réelle, pour le shader qui compte en secondes et non en part de sa vie.
func set_shader_seconds(seconds: float) -> void:
	_material.set_shader_parameter("seconds", seconds)


## Rallume un effet qui dure (le sol en feu du Dragon) : il reprend à `from_progress`, sans
## repasser par sa naissance, et s'éteint `seconds` plus tard.
func relight(seconds: float, from_progress: float) -> void:
	_duration = maxf(0.1, seconds / maxf(0.05, 1.0 - from_progress))
	_time = _duration * from_progress


## Le rayon réel, au-delà de `MAX_RADIUS_TILES`, pour la seule onde qui doit couvrir l'écran.
func span_tiles(tile_size: int, tiles: float) -> void:
	(get_child(0) as Sprite2D).scale = Vector2.ONE * tiles * 2.0 * float(tile_size) / 0.8


func _process(delta: float) -> void:
	_time += delta
	if _time >= _duration:
		queue_free()
		return
	_material.set_shader_parameter("progress", _time / _duration)
