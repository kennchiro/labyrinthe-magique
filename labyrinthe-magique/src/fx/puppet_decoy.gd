class_name PuppetDecoy
extends Node2D

## LA MARIONNETTE DU BALLET DES PANTINS (l'Éveil de la Démone de la Discorde) : une copie d'argent de la Reine,
## figée dans la pose qu'elle avait en partant, pendue par quatre fils à une petite croix qui la fait danser.
## Les ennemis s'y acharnent (le leurre vit dans `CombatSystem`), puis elle éclate en fils. Comme l'ombre du
## Seigneur du Néant, elle recopie le sprite : aucune planche à dessiner.

const SHADER := preload("res://assets/shaders/reine_pantin.gdshader")
const SILVER := Color("#c9d2d6")
const BLACK := Color("#161a1c")
const MAGENTA := Color("#e8308f")
## La croix flotte à cette hauteur au-dessus de ses pieds, en cases.
const CROSS_HEIGHT := 2.1
const CROSS_SIZE := 0.42
## Elle se balance au bout de ses fils.
const SWAY := 0.09
const SWAY_SPEED := 3.2
const FADE_TIME := 0.3

var _sprite: Sprite2D = null
var _material: ShaderMaterial = null
var _tile := 32
var _life := 0.0
var _seconds := 3.0


func setup(player: Player, tile: int, seconds: float) -> void:
	_tile = tile
	_seconds = seconds
	z_index = 9
	var source := player.sprite
	_sprite = Sprite2D.new()
	_sprite.texture = source.texture
	_sprite.hframes = source.hframes
	_sprite.vframes = source.vframes
	_sprite.frame = source.frame
	_sprite.flip_h = source.flip_h
	_sprite.scale = source.scale
	_sprite.offset = source.offset
	_sprite.centered = source.centered
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	_material.set_shader_parameter("fade", 0.0)
	_sprite.material = _material
	add_child(_sprite)


func _process(delta: float) -> void:
	_life += delta
	var swing := sin(_life * SWAY_SPEED) * SWAY
	_sprite.rotation = swing * 0.5
	_sprite.position = Vector2(swing * _tile * 0.6, sin(_life * SWAY_SPEED * 2.0) * _tile * 0.04)
	var fade := clampf((_life - (_seconds - FADE_TIME)) / FADE_TIME, 0.0, 1.0)
	_material.set_shader_parameter("fade", fade)
	modulate.a = 1.0 - fade
	queue_redraw()


func _draw() -> void:
	var t := float(_tile)
	var cross := Vector2(sin(_life * SWAY_SPEED + 0.6) * SWAY * t * 0.8, -CROSS_HEIGHT * t)
	var half := CROSS_SIZE * t
	var tilt := Vector2.RIGHT.rotated(sin(_life * SWAY_SPEED) * 0.25)
	var bar_a := cross - tilt * half
	var bar_b := cross + tilt * half
	var body := _sprite.position
	# Quatre fils : des bouts de la croix à ses mains, et du centre à sa tête.
	var ends := [bar_a, bar_b, cross + Vector2(0.0, -half * 0.5), cross]
	var holds := [body + Vector2(-0.32 * t, -0.62 * t), body + Vector2(0.32 * t, -0.62 * t),
		body + Vector2(0.0, -1.15 * t), body + Vector2(0.0, -0.9 * t)]
	for i in ends.size():
		draw_line(ends[i], holds[i], BLACK, 2.6)
		draw_line(ends[i], holds[i], SILVER if i < 3 else MAGENTA, 1.2)
	# La croix d'argent, cernée de noir.
	var up := Vector2(-tilt.y, tilt.x)
	for pair in [[bar_a, bar_b], [cross - up * half * 0.9, cross + up * half * 0.5]]:
		draw_line(pair[0], pair[1], BLACK, 5.0)
		draw_line(pair[0], pair[1], SILVER, 3.0)
	draw_circle(cross, 2.6, MAGENTA)
