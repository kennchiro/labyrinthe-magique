class_name DamageNumber
extends Node2D

## Le nombre de dégâts qui s'envole au-dessus d'un ennemi touché.
##
## C'est la seule chose qui dit au joueur si son sort vaut mieux que son
## attaque de base. Sans ce chiffre, choisir entre deux compétences revient à
## deviner : la barre de vie descend, mais on ne sait pas de combien ni pourquoi.
##
## Il monte en ralentissant et s'efface : un texte qui reste immobile se confond
## avec l'interface, un texte qui file trop vite ne se lit pas.

const DURATION := 0.85
const RISE_TILES := 1.15

@onready var label: Label = $Label

var _life := 0.0


func setup(amount: int, color: Color, tile_size: int, critical: bool = false) -> void:
	label.text = str(amount)
	# Les gros coups sont plus gros : l'ultime doit se VOIR, pas se compter.
	var scale_factor := 1.0 + clampf(float(amount) / 120.0, 0.0, 0.9)
	label.add_theme_font_size_override("font_size", int(tile_size * 0.52 * scale_factor))
	label.add_theme_color_override("font_color", Color.WHITE if critical else color)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.06))
	label.add_theme_constant_override("outline_size", 6)
	label.position = Vector2(-90.0, -float(tile_size) * 1.35)
	label.size = Vector2(180.0, 30.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _process(delta: float) -> void:
	_life += delta
	if _life >= DURATION:
		queue_free()
		return
	var t := _life / DURATION
	# Montée qui ralentit, disparition sur le dernier tiers seulement : le
	# chiffre doit rester lisible pendant l'essentiel de sa vie.
	position.y -= delta * (1.0 - t) * 2.0 * RISE_TILES * 32.0
	modulate.a = 1.0 if t < 0.65 else 1.0 - (t - 0.65) / 0.35
