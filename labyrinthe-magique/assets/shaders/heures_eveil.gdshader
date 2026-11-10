shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DU SEIGNEUR DES HEURES : un grand cadran s'imprime au sol sous lui, ses deux aiguilles s'emballent,
// douze traits de lumière jaillissent des heures, et l'onde d'or part au sol.

#include "res://assets/shaders/heures.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = H_TEAL;
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.3)) * vec2(1.0, 2.0);
	float open = smoothstep(0.0, 0.25, t);
	float fade = 1.0 - smoothstep(0.75, 1.0, t);
	// Le cadran : la face sarcelle translucide, les deux anneaux qui tournent.
	float dg = length(g);
	if (dg < 0.66 * open) {
		color = mix(H_DEEP, H_TEAL, dg / 0.66);
		a = 0.45 * fade;
	}
	if (h_dial(g, 0.74 * open, 0.09, t * 2.0, color)) {
		a = fade;
	}
	if (h_dial(g, 0.4 * open, 0.05, -t * 5.0, color)) {
		a = fade;
	}
	// Les aiguilles qui s'emballent.
	float spin = t * t * 40.0;
	float hand = h_hand(g, spin, 0.58 * open, 0.05);
	if (h_paint_hand(hand, 0.05, color)) {
		a = fade;
	}
	hand = h_hand(g, spin / 12.0 + 1.0, 0.36 * open, 0.065);
	if (h_paint_hand(hand, 0.065, color)) {
		a = fade;
	}
	// Douze traits de lumière montent des heures.
	float lift = smoothstep(0.12, 0.4, t) * (1.0 - smoothstep(0.55, 0.85, t));
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float ca = f / 12.0 * TAU;
		vec2 base = vec2(cos(ca) * 0.74, 0.3 + sin(ca) * 0.37);
		vec2 q = p - base;
		float beam = (i % 3 == 0 ? 0.05 : 0.03) - abs(q.x);
		float top = (i % 3 == 0 ? 1.3 : 0.8) * lift;
		if (beam > -0.01 && q.y < 0.0 && q.y > -top) {
			float k = -q.y / max(0.01, top);
			color = beam <= 0.0 ? H_RIM : (beam > 0.022 ? H_WHITE : H_BRIGHT);
			a = max(a, 1.0 - k * 0.7);
		}
	}
	// L'onde d'or.
	float front = 0.25 + smoothstep(0.45, 1.0, t) * 0.75;
	float width = 0.05 * step(0.45, t) * (1.0 - smoothstep(0.8, 1.0, t));
	float ring = width - abs(length((p - vec2(0.0, 0.3)) * vec2(1.0, 1.8)) - front);
	if (ring > -0.015 && width > 0.0) {
		color = ring <= 0.0 ? H_RIM : H_GOLD;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
