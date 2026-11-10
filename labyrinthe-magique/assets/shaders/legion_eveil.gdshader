shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DU MAÎTRE DES LÉGIONS : un grand sceau s'imprime au sol, six colonnes de runes en jaillissent,
// puis une onde d'or part au sol.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = L_DEEP;
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.3)) * vec2(1.0, 2.0);
	float open = smoothstep(0.0, 0.25, t);
	float fade = 1.0 - smoothstep(0.75, 1.0, t);
	// Le sceau, deux anneaux qui tournent en sens contraire.
	if (l_seal(g, 0.72 * open, 0.09, t * 3.0, 14.0, color)) {
		a = fade;
	}
	if (l_seal(g, 0.42 * open, 0.06, -t * 4.0, 8.0, color)) {
		a = fade;
	}
	// L'étoile tracée à l'intérieur : six branches d'or.
	float ang = atan(g.y, g.x) - t * 1.5;
	float star = abs(fract(ang / TAU * 6.0) - 0.5);
	float dg = length(g);
	if (dg < 0.33 * open && abs(star * dg * 6.0 - 0.0) < 0.06 && dg > 0.05) {
		color = L_GOLD;
		a = fade;
	}
	// Six colonnes de runes qui montent du bord du sceau.
	float lift = smoothstep(0.15, 0.4, t) * (1.0 - smoothstep(0.6, 0.85, t));
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float ca = f / 6.0 * TAU + 0.3;
		vec2 base = vec2(cos(ca) * 0.72, 0.3 + sin(ca) * 0.36);
		vec2 q = p - base;
		float column = 0.055 - abs(q.x);
		if (column > -0.012 && q.y < 0.0 && q.y > -1.2 * lift) {
			float k = -q.y / max(0.01, 1.2 * lift);
			color = column <= 0.0 ? L_RIM : (column > 0.03 ? L_PALE : L_VIOLET);
			a = 1.0 - k * 0.6;
		}
	}
	// L'onde d'or.
	float front = 0.2 + smoothstep(0.45, 1.0, t) * 0.8;
	float width = 0.05 * step(0.45, t) * (1.0 - smoothstep(0.8, 1.0, t));
	float ring = width - abs(length((p - vec2(0.0, 0.3)) * vec2(1.0, 1.8)) - front);
	if (ring > -0.015 && width > 0.0) {
		color = ring <= 0.0 ? L_RIM : L_GOLD;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
