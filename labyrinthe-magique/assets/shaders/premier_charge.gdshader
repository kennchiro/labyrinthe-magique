shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL DU DRAGON : un cercle de fissures de magma s'ouvre au sol sous ses pieds et monte en veines, puis
// le cœur de magma s'allume à travers ses côtes dans un éclair blanc chaud.

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
	// Les fissures au sol, couchées.
	vec2 g = (p - vec2(0.0, 0.62)) * vec2(1.0, 2.6);
	float d = length(g);
	float ang = atan(g.y, g.x);
	float open = smoothstep(0.0, 0.5, t);
	float ring = 0.03 * open - abs(d - 0.7);
	float crack = 0.016 - abs(fract(ang * 9.0 / TAU + seed) - 0.5) * d * 2.0;
	if (ring > 0.0 || (crack > 0.0 && d < 0.7 * open && d > 0.12)) {
		color = ring > 0.015 ? P_YELLOW : P_MAGMA;
		a = 1.0;
	}
	// Les veines qui montent le long de lui.
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		float x = (f / 4.0 - 0.5) * 0.7;
		float top = 0.6 - smoothstep(0.1, 0.7, t) * (1.1 + p_hash(f, seed) * 0.3);
		float wave = x + sin(p.y * 12.0 + f) * 0.04;
		if (p.y < 0.62 && p.y > top && abs(p.x - wave) < 0.018) {
			color = P_MAGMA;
			a = 1.0;
		}
	}
	// Le cœur qui s'allume.
	float heart = smoothstep(0.55, 0.85, t);
	vec2 h = p - vec2(0.0, -0.2);
	float core = 0.2 * heart - length(h) - abs(sin(atan(h.y, h.x) * 6.0)) * 0.08 * heart;
	if (core > 0.0) {
		color = core > 0.08 ? P_CORE : P_YELLOW;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
