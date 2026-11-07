class_name GemVolley
extends SteelBlades

## La Gerbe de gemmes de l'Éveillé : les mêmes temps que la volée de lames de l'Archange, que le
## combat frappe d'après eux, mais ce sont des gemmes taillées qui tournoient et laissent un
## scintillement derrière elles.

var colour := Color("#7fe3ff")


func _draw_blade(at: Vector2, angle: float) -> void:
	var spin := angle + _time * 14.0
	var size := _tile * 0.3
	var long := Vector2.from_angle(spin) * size
	var wide := Vector2.from_angle(spin + PI * 0.5) * size * 0.62
	# Le sillage : trois éclats qui s'éteignent derrière la gemme.
	var behind := -Vector2.from_angle(angle) * _tile * 0.22
	for i in 3:
		var fade := 1.0 - float(i) / 3.0
		draw_circle(at + behind * float(i + 1), size * 0.22 * fade, Color(colour, 0.5 * fade))
	draw_colored_polygon(PackedVector2Array([at + long * 1.18, at + wide * 1.18, at - long * 1.18,
		at - wide * 1.18]), RIM)
	draw_colored_polygon(PackedVector2Array([at + long, at + wide, at - long, at - wide]), colour)
	# La table de la gemme, plus claire, et son reflet.
	draw_colored_polygon(PackedVector2Array([at + long * 0.45, at + wide * 0.45, at - long * 0.45,
		at - wide * 0.45]), Color(1.0, 1.0, 1.0, 0.85))
	draw_line(at - long * 0.6, at + wide * 0.6, Color(1.0, 1.0, 1.0, 0.9), 1.5)
