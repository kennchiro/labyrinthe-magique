shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DE L'EMPEREUR : une colonne de flammes jaillit sous lui et monte, l'anneau de braise s'allume au-dessus
// de sa couronne, et une onde de cendres part au sol, ourlée de lave.

#include "res://assets/shaders/empereur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	// L'onde de cendres, couchée à ses pieds.
	vec2 g = (p - vec2(0.0, 0.62)) * vec2(1.0, 2.6);
	float d = length(g);
	float r = smoothstep(0.0, 0.7, t) * 0.95;
	float fade = 1.0 - smoothstep(0.65, 1.0, t);
	float band = 0.07 * fade - abs(d - r);
	if (band > 0.0) {
		color = band > 0.045 ? E_LAVA : E_ASH;
		a = 1.0;
	} else if (band > -0.014 && fade > 0.0) {
		color = E_BLACK;
		a = 1.0;
	}
	// La colonne de flammes : sept langues qui montent et retombent.
	float rise = smoothstep(0.0, 0.25, t) * (1.0 - smoothstep(0.55, 0.9, t));
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		float x = (f / 6.0 - 0.5) * 0.7;
		float h = rise * (0.7 + e_hash(f, seed) * 0.6) * (1.0 - abs(x) * 0.9);
		vec3 c = color;
		if (h > 0.02 && e_paint_tongue(p - vec2(x, 0.62), 0.12, h * 1.4, c)) {
			color = c;
			a = 1.0;
		}
	}
	// L'anneau de braise s'allume au-dessus de lui, pointe après pointe.
	float lit = smoothstep(0.2, 0.6, t) * fade;
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		if (f / 5.0 > lit * 1.1) {
			break;
		}
		float x = (f - 2.0) * 0.16;
		vec2 q = p - vec2(x, -0.82 + abs(f - 2.0) * 0.05);
		float s = e_spike(q, 0.05, 0.1);
		if (s > -0.15) {
			color = s <= 0.0 ? E_BLACK : (s > 0.45 ? E_PALE : E_EMBER);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
