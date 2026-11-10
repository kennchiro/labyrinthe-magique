shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DU DRAGON PRIMORDIAL : il rugit vers le ciel, une colonne de flammes jaillit au-dessus de lui, et une
// onde de feu part au sol en dressant des langues de flamme tout autour.

#include "res://assets/shaders/premier.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float fade = 1.0 - smoothstep(0.7, 1.0, t);
	// L'onde de feu au sol, hérissée de flammes.
	vec2 g = (p - vec2(0.0, 0.62)) * vec2(1.0, 2.6);
	float r = smoothstep(0.0, 0.7, t) * 0.95;
	float band = 0.05 * fade - abs(length(g) - r);
	if (band > 0.0) {
		color = band > 0.03 ? P_YELLOW : P_MAGMA;
		a = 1.0;
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float an = f * TAU / 10.0 + seed;
		vec2 base = vec2(cos(an) * r, 0.62 + sin(an) * r / 2.6);
		vec3 c = color;
		if (fade > 0.05 && p_paint_tongue(p - base, 0.07, 0.3 * fade, c)) {
			color = c;
			a = 1.0;
		}
	}
	// La colonne de flammes au-dessus de sa gueule.
	float rise = smoothstep(0.0, 0.25, t) * (1.0 - smoothstep(0.5, 0.85, t));
	vec3 c = color;
	if (rise > 0.02 && p_paint_tongue(p - vec2(0.0, -0.35), 0.22 * rise, 0.65 * rise, c)) {
		color = c;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
