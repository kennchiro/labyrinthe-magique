shader_type canvas_item;
render_mode blend_mix;

// LA LANCE DE FOUDRE, le projectile : une hampe d'éclair qui crépite, une pointe de lance blanche bordée
// de bleu, et des traits de vitesse derrière. UV.x va de la queue (0) à la pointe (1).

#include "res://assets/shaders/tempete.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

const float LENGTH = 2.0;

void fragment() {
	vec2 p = vec2(UV.x * LENGTH, (UV.y - 0.5));
	float flick = floor(TIME * 18.0);
	vec3 color = T_BLUE;
	float a = 0.0;
	// Les traits de vitesse.
	for (int i = 0; i < 2; i++) {
		float f = float(i) * 2.0 - 1.0;
		vec2 q = vec2(p.x - 0.05, p.y - f * 0.2);
		float line = q.x > 0.0 && q.x < 0.7 ? 0.018 * (q.x / 0.7) - abs(q.y) : -1.0;
		if (line > -0.008) {
			color = line <= 0.0 ? T_RIM : T_BLUE;
			a = 1.0;
		}
	}
	// La hampe : un éclair qui crépite.
	float shaft = t_bolt(p - vec2(0.15, 0.0), 1.45, 0.075, 0.22, seed, flick);
	if (shaft > -0.025) {
		color = shaft <= 0.0 ? T_RIM : t_bolt_color(shaft / 0.075);
		a = 1.0;
	}
	// La pointe : un fer de lance.
	vec2 q = p - vec2(1.62, 0.0);
	float tip = q.x > -0.12 && q.x < 0.36 ? (q.x < 0.0 ? 0.2 * (1.0 + q.x / 0.12) : 0.2 * (1.0 - q.x / 0.36)) - abs(q.y) : -1.0;
	if (tip > -0.025) {
		color = tip <= 0.0 ? T_RIM : (tip > 0.07 ? T_WHITE : (tip > 0.03 ? T_BLUE : T_BLUE_DEEP));
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
