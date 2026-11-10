shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION : deux grands cercles de flamme saphir se croisent derrière lui (la roue dans la roue), tous leurs yeux
// s'ouvrent dans un éclair, et un anneau de flamme court au sol.

#include "res://assets/shaders/eden.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float life = 1.0 - smoothstep(0.7, 1.0, t);
	float grow = smoothstep(0.0, 0.35, t);
	vec4 color = vec4(0.0);
	// L'anneau au sol.
	vec2 g = vec2(p.x, (p.y - 0.45) * 2.4);
	float ground = smoothstep(0.06, 0.0, abs(length(g) - smoothstep(0.1, 0.6, t) * 0.95)) * life;
	color = e_over(vec4(e_flame(0.7), ground), color);
	// Les deux roues croisées, en ellipses inclinées.
	for (int k = 0; k < 2; k++) {
		float a = (float(k) * 2.0 - 1.0) * 0.7;
		vec2 q = vec2(p.x * cos(a) - (p.y + 0.15) * sin(a), p.x * sin(a) + (p.y + 0.15) * cos(a));
		q.y *= 2.6;
		float r = 0.82 * grow;
		float halo = smoothstep(0.16, 0.0, abs(length(q) - r));
		color = e_over(vec4(e_flame(0.6), halo * 0.6 * life), color);
		float rim = smoothstep(0.05, 0.0, abs(length(q) - r));
		color = e_over(vec4(E_GOLD, rim * life), color);
		for (int i = 0; i < 6; i++) {
			float b = float(i) * TAU / 6.0 + t * 2.0 * (float(k) * 2.0 - 1.0);
			vec2 at = vec2(cos(b), sin(b) / 2.6) * r;
			vec2 world = vec2(at.x * cos(-a) - at.y * sin(-a), at.x * sin(-a) + at.y * cos(-a)) - vec2(0.0, 0.15);
			float open = smoothstep(0.3, 0.45, t);
			color = e_over(e_eye(p - world, 0.1, open, step(0.01, open) * life), color);
		}
	}
	float flash = 1.0 - smoothstep(0.0, 0.35, abs(t - 0.38) * 2.0);
	color = e_over(vec4(E_CORE, e_glow(length(p + vec2(0.0, 0.15)), 0.8) * flash * 0.9), color);
	COLOR = color;
}
