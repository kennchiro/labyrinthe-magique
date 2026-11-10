shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DU MAÎTRE DU CASINO : un tapis vert de casino s'étend au sol sous lui, bordé d'or, et une pluie de
// pièces d'or jaillit de lui et retombe en tournant.

#include "res://assets/shaders/casino.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float fade = 1.0 - smoothstep(0.75, 1.0, t);
	vec2 g = (p - vec2(0.0, 0.62)) * vec2(1.0, 2.6);
	float d = length(g);
	float r = smoothstep(0.0, 0.5, t) * 0.9;
	if (d < r) {
		color = K_FELT;
		a = 0.75 * fade;
	}
	float rim = 0.035 * fade - abs(d - r);
	if (rim > 0.0) {
		color = rim > 0.018 ? K_GOLD : K_GOLD_DARK;
		a = 1.0;
	}
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float ang = f * TAU / 12.0 + k_hash(f, seed) * 0.5;
		float k = clamp(t * 1.3, 0.0, 1.0);
		float reach = k * (0.4 + k_hash(f + 1.0, seed) * 0.45);
		vec2 at = vec2(cos(ang) * reach, sin(ang) * reach * 0.4 - sin(k * 3.14159) * 0.6 + 0.2);
		vec2 q = vec2((p - at).x / max(abs(cos(t * 10.0 + f)), 0.2), (p - at).y);
		vec3 c = color;
		if (fade > 0.0 && k_paint_chip(q, 0.06, c)) {
			color = c;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
