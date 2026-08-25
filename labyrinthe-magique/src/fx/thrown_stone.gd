class_name ThrownStone
extends Node2D

## LE ROCHER OU LA GEMME que le mage lance, en vol.
##
## Il vole LENTEMENT — cinq cases par seconde, quand un projectile ordinaire du
## jeu en fait quinze. C'est délibéré : ce qui compte ici est qu'on VOIE la
## pierre tourner, son halo palpiter et sa poussière tomber. Un jet trop rapide
## ne laisse voir qu'un trait, et tout le travail de dessin est perdu.
##
## Le halo est un SHADER qui épouse la silhouette (`thrown_glow.gdshader`) : le
## rocher rond et la gemme pointue n'ont pas le même contour, et un halo
## circulaire posé derrière les trahirait tous les deux. Sa couleur dit ce qui
## arrive avant qu'on distingue la forme — vert pour la gemme, brun pour la
## pierre.

const GLOW := preload("res://assets/shaders/thrown_glow.gdshader")
## Cases par seconde. Lent, VOIR l'en-tête.
const SPEED_TILES := 5.0
const MIN_FLIGHT := 0.28
## Traces de poussière semées sur le trajet.
const GRIT := 6

@onready var body: Sprite2D = $Body

var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _life := 0.0
var _flight := 0.4
var _spin := 1.0
var _tint := Color(0.45, 1.0, 0.4)
var _grain := 32.0


func setup(from: Vector2, to: Vector2, texture: Texture2D, tile_size: int,
		tint: Color, spin: float) -> void:
	_from = from
	_to = to
	_tint = tint
	_spin = spin
	_grain = float(tile_size)
	var node: Sprite2D = get_node_or_null("Body")
	if node == null or texture == null:
		queue_free()
		return
	body = node
	body.texture = texture
	var span := (tile_size * 0.8) / float(texture.get_height())
	body.scale = Vector2(span, span)
	# La durée vient de la DISTANCE : deux cases se traversent deux fois plus
	# vite que quatre. Une durée fixe ferait ramper le jet de près et filer le
	# jet de loin.
	_flight = maxf(MIN_FLIGHT, (from.distance_to(to) / float(tile_size)) / SPEED_TILES)
	var material := ShaderMaterial.new()
	material.shader = GLOW
	material.set_shader_parameter("rim_color", tint)
	material.set_shader_parameter("rim_width", 2.5)
	body.material = material
	position = Vector2.ZERO


func _process(delta: float) -> void:
	_life += delta
	if _life >= _flight or body == null:
		queue_free()
		return
	var t := _life / _flight
	body.position = _from.lerp(_to, t)
	# Elle TOURNE en volant : c'est ce qui la distingue d'une image qu'on
	# translate, et ce qui lui donne son poids.
	body.rotation = _spin * t * TAU
	var material: ShaderMaterial = body.material
	if material != null:
		material.set_shader_parameter("phase", t)
	queue_redraw()


func _draw() -> void:
	if body == null:
		return
	var t := clampf(_life / _flight, 0.0, 1.0)
	var span := _to - _from
	var across := Vector2(-span.y, span.x).normalized()
	# La poussière arrachée au passage, dans la couleur du projectile. Elle
	# tombe derrière lui et s'éteint — c'est elle qui donne la vitesse à l'œil.
	for i in GRIT:
		var lag := 0.05 + 0.055 * float(i)
		var at := _from.lerp(_to, maxf(0.0, t - lag))
		var side := across * sin(float(i) * 2.1 + t * 7.0) * _grain * 0.1
		var life := 1.0 - float(i) / float(GRIT)
		draw_circle(at + side + Vector2(0.0, _grain * 0.05 * float(i) * 0.2),
			_grain * 0.06 * life,
			Color(_tint.r, _tint.g, _tint.b, 0.45 * life * (1.0 - t * 0.4)))
