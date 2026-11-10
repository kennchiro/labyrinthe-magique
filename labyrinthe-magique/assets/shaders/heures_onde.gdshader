shader_type canvas_item;
render_mode blend_mix;

// L'ONDE D'HORLOGE du Paradoxe : au bout de son trajet, le double éclate. Un cadran s'ouvre d'un coup en
// tournant, ses aiguilles s'emballent, huit éclats d'or partent, puis le cadran s'efface.

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
	float grow = 1.0 - pow(1.0 - clamp(t / 0.35, 0.0, 1.0), 3.0);
	float fade = 1.0 - smoothstep(0.55, 1.0, t);
	float d = length(p);
	// Le souffle sarcelle.
	float body = 0.8 * grow - d;
	if (body > 0.0) {
		color = mix(H_BRIGHT, H_PALE, smoothstep(0.3, 0.8, body));
		a = (0.25 + smoothstep(0.4, 0.8, body) * 0.6) * (1.0 - smoothstep(0.1, 0.45, t));
	}
	if (h_dial(p, 0.78 * grow, 0.07, t * 4.0 + seed, color)) {
		a = fade;
	}
	if (h_dial(p, 0.45 * grow, 0.04, -t * 7.0, color)) {
		a = fade * 0.9;
	}
	float hand = h_hand(p, t * 18.0 + seed, 0.6 * grow, 0.05);
	if (h_paint_hand(hand, 0.05, color)) {
		a = fade;
	}
	hand = h_hand(p, -t * 9.0 + 2.0, 0.4 * grow, 0.06);
	if (h_paint_hand(hand, 0.06, color)) {
		a = fade;
	}
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float ang = f / 8.0 * TAU + 0.2 + seed;
		vec2 dir = vec2(cos(ang), sin(ang));
		vec2 q = h_rot(p - dir * (0.3 + t * 0.75), -ang);
		float shard = 0.055 * (1.0 - t) - abs(q.y) - abs(q.x) * 0.35;
		if (shard > -0.01 && abs(q.x) < 0.16) {
			color = shard <= 0.0 ? H_RIM : H_GOLD;
			a = max(a, 1.0 - t);
		}
	}
	COLOR = vec4(color, a);
}
