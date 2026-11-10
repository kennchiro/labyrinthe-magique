shader_type canvas_item;
render_mode blend_mix;

// LES TROIS AIGUILLES du Seigneur des Heures, le projectile : une aiguille d'horloge en or, pointe en losange
// à droite, contrepoids rond à la queue, suivie de deux échos sarcelle d'elle-même et d'un filet de sable vif.

#include "res://assets/shaders/heures.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;

// L'aiguille couchée, pointe à `tip` (en UV.x), longue de `len`.
float needle(vec2 uv, float tip, float len, float w) {
	vec2 q = vec2(uv.x - (tip - len), (uv.y - 0.5));
	return h_hand(q, 0.0, len, w);
}

void fragment() {
	vec3 color = H_TEAL;
	float a = 0.0;
	// Deux échos qui suivent, de plus en plus pâles.
	for (int i = 2; i >= 1; i--) {
		float f = float(i);
		float ghost = needle(UV, 0.96 - f * 0.17, 0.42, 0.11);
		if (ghost > 0.0) {
			color = f > 1.5 ? H_TEAL : H_BRIGHT;
			a = 0.55 - f * 0.18;
		}
	}
	// Le filet de sable vif.
	float grain = texture(noise, vec2(UV.x * 1.8 - TIME * 1.6 + seed, UV.y * 1.2 + seed)).r;
	float across = abs(UV.y - 0.5) * 2.0;
	float trail = smoothstep(0.0, 0.55, UV.x) * step(UV.x, 0.6);
	if (step(0.52 - trail * 0.2, grain) * step(across, 0.1 + UV.x * 0.5) * trail > 0.5 && a < 0.3) {
		color = mix(H_BRIGHT, H_PALE, smoothstep(0.6, 0.75, grain));
		a = 0.85 * trail;
	}
	float body = needle(UV, 0.98, 0.46, 0.13);
	if (h_paint_hand(body, 0.13, color)) {
		a = 1.0;
	}
	COLOR = vec4(color, a * COLOR.a);
}
