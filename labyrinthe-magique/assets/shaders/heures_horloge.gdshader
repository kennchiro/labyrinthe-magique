shader_type canvas_item;
render_mode blend_mix;

// TEMPS ACCÉLÉRÉ, le trait du Seigneur des Heures : une horloge sarcelle tourne au sol sous ses pieds, ses
// aiguilles à toute allure, la minute qu'il vit plus vite que le monde. Toute la minute de l'Éveil.

#include "res://assets/shaders/heures.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = p * vec2(1.0, 2.1);
	float show = smoothstep(0.0, 0.01, progress) * (1.0 - smoothstep(0.97, 1.0, progress));
	vec3 color = H_TEAL;
	float a = 0.0;
	float dg = length(g);
	if (dg < 0.62) {
		color = mix(H_DEEP, H_TEAL, dg / 0.62);
		a = 0.3;
		// La trotteuse laisse un éventail de lumière derrière elle.
		float sweep = fract((atan(g.y, g.x) - TIME * 6.0) / TAU);
		if (sweep > 0.82) {
			color = mix(color, H_BRIGHT, (sweep - 0.82) / 0.18);
			a = 0.3 + (sweep - 0.82) * 2.0;
		}
	}
	if (h_dial(g, 0.7, 0.085, TIME * 0.6, color)) {
		a = 0.95;
	}
	float hand = h_hand(g, TIME * 6.0, 0.56, 0.045);
	if (h_paint_hand(hand, 0.045, color)) {
		a = 1.0;
	}
	hand = h_hand(g, TIME * 0.5 + seed, 0.34, 0.06);
	if (h_paint_hand(hand, 0.06, color)) {
		a = 1.0;
	}
	if (dg < 0.07) {
		color = dg > 0.05 ? H_RIM : H_LIGHT;
		a = 1.0;
	}
	COLOR = vec4(color, a * show);
}
