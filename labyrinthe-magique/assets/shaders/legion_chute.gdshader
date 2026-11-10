shader_type canvas_item;
render_mode blend_mix;

// LA GARGOUILLE TOMBE : un sceau marque le sol, l'onde de choc part, et des éclats de pierre volent.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

const vec3 STONE = vec3(0.55, 0.53, 0.58);
const vec3 STONE_DARK = vec3(0.3, 0.28, 0.33);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = L_DEEP;
	float a = 0.0;
	vec2 g = p * vec2(1.0, 1.9);
	float fade = 1.0 - smoothstep(0.7, 1.0, t);
	// Le sceau.
	if (l_seal(g, 0.6, 0.09, t * 2.0, 10.0, color)) {
		a = fade;
	}
	// Les fissures : huit traits qui partent du centre.
	float ang = atan(g.y, g.x);
	float crack = abs(fract(ang / TAU * 8.0 + seed) - 0.5);
	float dg = length(g);
	if (crack * dg < 0.025 && dg < 0.85 * smoothstep(0.0, 0.2, t) && dg > 0.1) {
		color = L_VIOLET;
		a = fade;
	}
	// L'onde de choc.
	float front = 0.2 + smoothstep(0.0, 0.6, t) * 0.75;
	float ring = 0.07 * (1.0 - smoothstep(0.4, 0.8, t)) - abs(dg - front);
	if (ring > -0.015) {
		color = ring <= 0.0 ? L_RIM : L_BONE;
		a = 1.0;
	}
	// Dix éclats de pierre qui volent puis retombent.
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float dir = f / 10.0 * TAU + l_hash(f, seed) * 0.5;
		float fly = smoothstep(0.0, 0.7, t);
		vec2 c = vec2(cos(dir), sin(dir) * 0.55) * (0.15 + fly * 0.7) - vec2(0.0, sin(fly * 3.14) * 0.35);
		vec2 q = l_rot(p - c, f * 1.7 + t * 9.0);
		float rock = 0.07 * (1.0 - smoothstep(0.75, 1.0, t)) - max(abs(q.x) * 1.3, abs(q.y));
		if (rock > -0.012) {
			color = rock <= 0.0 ? L_RIM : (q.y < 0.0 ? STONE : STONE_DARK);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
