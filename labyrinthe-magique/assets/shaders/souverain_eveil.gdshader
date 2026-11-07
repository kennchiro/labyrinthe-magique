shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DU SOUVERAIN : une colonne de vent l'enveloppe puis s'ouvre d'un coup, l'onde part au sol
// en croissants qui couchent tout, et un anneau d'or s'allume.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = S_SKY;
	float a = 0.0;
	// La colonne : des rubans serrés autour de lui, qui s'écartent au moment de s'ouvrir.
	float wrap = 1.0 - smoothstep(0.25, 0.4, t);
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		vec2 q = vec2(p.x, (p.y + 0.3 - f * 0.25) * 3.2);
		float rel;
		float arc = s_arc(q, 0.35 + (1.0 - wrap) * 0.6, TIME * 10.0 + f * 1.5, 2.8, 0.1 * wrap, rel);
		if (arc > -0.025 && wrap > 0.0) {
			color = arc <= 0.0 ? S_RIM : s_wind(arc / 0.1);
			a = 1.0;
		}
	}
	// L'onde au sol, en croissants.
	vec2 g = p * vec2(1.0, 1.5);
	float d = length(g);
	float front = 0.2 + smoothstep(0.25, 0.85, t) * 0.75;
	float fade = smoothstep(0.25, 0.3, t) * (1.0 - smoothstep(0.7, 1.0, t));
	float wav = 0.5 + 0.5 * cos(atan(g.y, g.x) * 8.0);
	float width = 0.07 * fade * smoothstep(0.2, 0.7, wav);
	float ring = width - abs(d - front);
	if (ring > -0.015 && width > 0.01) {
		color = ring <= 0.0 ? S_RIM : s_wind(ring / width);
		a = 1.0;
	}
	float gold = 0.035 * fade - abs(d - 0.3);
	if (gold > -0.012 && fade > 0.0) {
		color = gold <= 0.0 ? S_RIM : S_GOLD;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
